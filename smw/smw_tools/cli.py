"""Single entry point for every project command.

Installed as the ``smw`` console script, so commands are ``uv run smw <cmd>``
from anywhere in the repository.
"""

from __future__ import annotations

import argparse
import math
import os
import re
import shutil
import sys
import textwrap
from pathlib import Path

from . import annotate, map16
from .address_index import (
    ADDRESS_SPACES,
    SPACE_FOR_MEMORY,
    AddressIndex,
    IndexedSymbol,
    _memory_label_locations,
    _stored_spelling,
    build_address_index,
    format_addr,
    lookup_containing,
    parse_address,
)
from .annotations import (
    ENTRY_LABEL,
    annotation_for,
    format_annotation,
    routine_annotation,
    summarize,
)
from .bases import BASES, DEFAULT_BASE, BaseError, RomBase
from .bases import base as rom_base
from .bases import resolve as resolve_target
from .build import build_rom, build_symbols, stock_build
from .check import run_check
from .codegraph import (
    CodeGraph,
    accesses_by_addressing,
    build_graph,
    closure,
    routine_source,
    spilling_accesses,
)
from .features import FEATURES, build_defines, feature
from .memory_layout import MemoryLayout, build_memory_layout
from .paths import BUILD_DIR, GAME_DIR, WORK_ROOT
from .ram_map import RamMapError, cpu_address, window_address
from .rom_image import read_rom
from .rom_sizes import ROM_SIZES, RomSize, bytes_label, rom_size
from .run import close_emulator, run_in_emulator
from .symbols import Symbol, SymbolTable, load_symbols, stale_sources
from .verify_static import print_report, run_static_verification

#: Everything the analysis commands derive from a tree, cached **per base**.
#:
#: Keyed rather than singular because a base is not a global setting: `symbol`
#: builds the index against one and `xref` the graph against another in the same
#: process during tests, and a cache that ignored the base would hand the second
#: caller the first one's answers.
_graphs: dict[str, CodeGraph] = {}
_layouts: dict[str, MemoryLayout] = {}
_mem_locs: dict[str, dict[str, tuple[str, int]]] = {}


def graph(base: RomBase | None = None) -> CodeGraph:
    found = base or rom_base()
    if found.id not in _graphs:
        sys.stderr.write(f"building code graph ({found.id})... ")
        import time

        t = time.time()
        g = _graphs[found.id] = build_graph(found)
        sys.stderr.write(
            f"{len(g.routines)} routines, {len(g.memory)} memory labels, "
            f"{len(g.defines)} defines ({int((time.time() - t) * 1000)}ms)\n\n"
        )
    return _graphs[found.id]


def memory_layout(base: RomBase | None = None) -> MemoryLayout:
    found = base or rom_base()
    if found.id not in _layouts:
        _layouts[found.id] = build_memory_layout(found)
    return _layouts[found.id]


def _memory_locations(base: RomBase | None = None) -> dict[str, tuple[str, int]]:
    """Defining file and line of every RAM-map entry, keyed ``!Name``.

    The map is `!Name #= $address` defines rather than `skip`-anchored labels, so
    this goes through the one resolver that understands those -- a scan for
    `Name:` labels finds nothing here, and the entry's own documentation would
    silently never be printed.
    """
    found = base or rom_base()
    if found.id not in _mem_locs:
        _mem_locs[found.id] = {
            name: (file, line)
            for name, (file, line, _space, _addr) in _memory_label_locations(
                found
            ).items()
        }
    return _mem_locs[found.id]


def _location_of(
    g: CodeGraph, name: str, base: RomBase | None = None
) -> tuple[str, int] | None:
    r = g.routines.get(name)
    if r:
        return (r.file, r.line)
    return _memory_locations(base).get(name)


def _describe(
    g: CodeGraph, name: str, max_len: int = 58, base: RomBase | None = None
) -> str:
    """One-line description for a symbol, read from its comment block."""
    loc = _location_of(g, name, base)
    if loc is None:
        return ""
    r = g.routines.get(name)
    if r is not None and r.kind == "macro":
        # Only the block above the entry label describes the routine; the rest
        # describe a table inside it, and would read here as if they did not.
        doc = routine_annotation(loc[0], loc[1])
        return summarize(doc[1], max_len) if doc and doc[0] == ENTRY_LABEL else ""
    # A memory entry, or a Config routine: a label, documented from above.
    return summarize(annotation_for(loc[0], loc[1]), max_len)


def _print_routine_annotation(file: str, line: int) -> None:
    """Print a routine's documentation, which lives inside the macro body.

    Attributed to the label it sits above, because that is what it describes --
    only over `Main` is it about the routine as a whole.
    """
    doc = routine_annotation(file, line)
    if doc is None:
        print("")
        return
    label, ann = doc
    body = format_annotation(ann, "  ")
    if not body:
        print("")
        return
    print("")
    if label != ENTRY_LABEL:
        print(f"  documenting {label}, the first labelled thing inside it:")
    for line_text in body:
        print(line_text)
    print("")


def _print_annotation(file: str, line: int) -> None:
    """Print a label's own documentation, read from the comment block above it."""
    ann = annotation_for(file, line)
    if ann is None:
        print("")
        return
    meta = "  ".join(x for x in (ann.address, ann.size) if x)
    if meta:
        print(f"  {meta}")
    body = format_annotation(ann, "  ")
    if body:
        print("")
        for line_text in body:
            print(line_text)
    print("")


def _list_widths(
    title: str,
    hits: dict[str, int | None],
    g: CodeGraph,
    base: RomBase | None = None,
) -> None:
    """Like :func:`_list`, but says how sure each row is."""
    if not hits:
        return
    print(f"  {title} ({len(hits)})")
    rows = [
        (
            n,
            f"{r.file}:{r.line}" if (r := g.routines.get(n)) else "",
            "16-bit" if w == 16 else "width not determined",
            _describe(g, n, base=base),
        )
        for n, w in sorted(hits.items())
    ]
    name_w = max(len(r[0]) for r in rows)
    where_w = max(len(r[1]) for r in rows)
    how_w = max(len(r[2]) for r in rows)
    for name, where, how, desc in rows:
        line = f"    {name:<{name_w}}  {where:<{where_w}}  {how:<{how_w}}"
        if desc:
            line += f"  {desc}"
        print(line.rstrip())


def _print_coverage(
    g: CodeGraph, target: str, kind: str, base: RomBase | None = None
) -> None:
    """The three ways an access reaches ``target`` without naming it.

    A list keyed on operands is exhaustive only for accesses that named their
    destination. Three kinds do not, and all three are silent: a **16-bit**
    access to the entry above, which runs one byte past its own storage; an
    **indexed** one to a table that starts above, which lands wherever the index
    points; and an **indirect** one, whose destination is computed at runtime.
    The first is enumerable and the other two are only countable, so this states
    what it can and quantifies the rest -- an empty writer list is a fact about
    operands, and reading it as "nothing writes this" is the mistake worth
    spending several lines to prevent.
    """
    if kind == "write":
        past, one, many = "written", "writes", "write"
    else:
        past, one, many = "read", "reads", "read"
    layout = memory_layout(base)

    neighbour = layout.covered_by.get(target)
    if neighbour:
        entry = layout.entries[neighbour]
        where = format_addr(entry.addr) if entry.addr is not None else "?"
        hits = spilling_accesses(g, neighbour, kind)
        if hits:
            _list_widths(
                f"also {past} by a 16-bit access to {neighbour} "
                f"({where}, one byte) running into it",
                hits,
                g,
                base,
            )
        indexed = accesses_by_addressing(g, kind, "indexed")
        via_neighbour = sorted(r for r, syms in indexed.items() if neighbour in syms)
        if via_neighbour:
            _list(
                f"{past} at {neighbour}+index, which reaches this entry at index 1",
                via_neighbour,
                g,
                base,
            )
        if not hits and not via_neighbour:
            print(
                f"  {neighbour} ({where}) owns the byte directly above, and "
                f"nothing {one} it wide or indexed, so nothing spills in"
            )

    through = accesses_by_addressing(g, kind, "indirect")
    dereferencing = sorted(r for r, syms in through.items() if target in syms)
    if dereferencing:
        _list(f"{past} through {target} as a pointer", dereferencing, g, base)
    if through:
        print("")
        print(
            textwrap.fill(
                f"note: {len(through)} routines {many} through a pointer, to "
                f"destinations nothing static can name, and an indexed access "
                f"to any table starting above this entry can land on it. The "
                f"lists above are complete for accesses that named {target} -- "
                f"which is not the same as nothing else touching it.",
                width=78,
                initial_indent="  ",
                subsequent_indent="        ",
            )
        )


def _list(title: str, items, g: CodeGraph, base: RomBase | None = None) -> None:
    arr = sorted(items)
    print(f"  {title} ({len(arr)})")
    if not arr:
        print("    -")
        return
    # Column widths come from the rows actually present, so a list of defines
    # (which have no file:line) does not carry an empty 24-column gutter.
    rows = []
    for n in arr:
        r = g.routines.get(n)
        rows.append((n, f"{r.file}:{r.line}" if r else "", _describe(g, n, base=base)))
    name_w = max(len(r[0]) for r in rows)
    where_w = max((len(r[1]) for r in rows), default=0)
    for name, where, desc in rows:
        line = f"    {name:<{name_w}}  {where:<{where_w}}"
        if desc:
            line += f"  {desc}"
        print(line.rstrip())


# --------------------------------------------------------------------------


def _selection(args: argparse.Namespace) -> list[tuple[RomBase, list[str]]]:
    """Which bases to build, and which of each one's targets.

    **A bare ``--all`` means every target of every base.** The repository's rule
    is a statement about the tree, and a gate that quietly skipped a registered
    base would not be making it -- which is exactly what "all five releases"
    became the moment a sixth thing was registered. ``--base X --all`` scopes it
    back to one.

    Never a fixed count: a base with one target is not asked for releases it
    does not have.

    A bare ``version`` may still carry a base -- ``smw check vanilla/E0`` -- and
    when it does it wins over ``--base``, because it is the more specific of the
    two and disagreeing about it should not be resolved by argument order.

    ``--base`` alone still means that base: the default target is resolved
    against it rather than against the default base, so ``smw check --base sa1``
    cannot quietly check ``vanilla/U`` instead. A base with no target of that
    name says so, which is the same refusal a named one gets.
    """
    if args.all:
        chosen = [rom_base(args.base)] if args.base else list(BASES.values())
        return [(base, list(base.targets)) for base in chosen]
    base, target = resolve_target(args.version)
    if args.base and (args.version is None or "/" not in args.version):
        base = rom_base(args.base)
        target = base.target(target.id)
    return [(base, [target.id])]


def cmd_build(args: argparse.Namespace) -> int:
    symbols = "wla" if args.symbols else None
    wanted = tuple(args.feature or ())
    for base, versions in _selection(args):
        _build_one_base(base, versions, symbols, args.rom_size, wanted)
    return 0


def _feature_size(wanted: tuple[str, ...], size: RomSize, base: RomBase) -> RomSize:
    """``size``, or a refusal naming the feature this cartridge has no room for.

    Asked before the build rather than after, because the refusal costs a
    quarter of a minute to reach otherwise and says less than this can: the
    assembler knows the define it was given and not which feature asked for it,
    or what to pass instead.
    """
    for feature_id in wanted:
        found = feature(feature_id)
        needs = found.needs
        if needs is not None and size.size < needs.size:
            raise BaseError(
                f"{feature_id} needs a cartridge of at least {needs.label} and "
                f"{base.id} was asked for {size.label} -- add --rom-size "
                f"{needs.id}"
            )
    return size


def _build_one_base(
    base: RomBase,
    versions: list[str],
    symbols: str | None,
    size_id: str | None,
    wanted: tuple[str, ...] = (),
) -> None:
    # Resolved per base, because the stock size is the base's own: `sa1` has no
    # 512 KB cartridge to default to.
    asked = rom_size(size_id) if size_id else ROM_SIZES[base.stock_size]
    size = _feature_size(wanted, asked, base)
    for v in versions:
        r = build_rom(
            v,
            base=base,
            symbols=symbols,
            rom_size=size,
            defines=build_defines(wanted, base),
            on_progress=lambda m: print(f"> {m}"),
        )
        img = read_rom(r.output_path)
        expectation = base.target(v).expectation
        wrong = expectation.mismatches(img)
        rel = os.path.relpath(r.output_path, WORK_ROOT)
        if size.id != base.stock_size:
            # An expanded cartridge is not the one the hash describes, so saying
            # it "DIFFERS from pinned hash" would report a deliberate choice as
            # a failure. What is worth reporting instead is the room it bought.
            verdict = (
                f"assembled at {size.label}, "
                f"{bytes_label(base.room(size.id))} free over stock"
            )
        elif wanted:
            # Nor is a cartridge with a feature switched on, and a base whose
            # stock size is already expanded -- `sa1` -- reaches this branch
            # rather than the one above.
            verdict = f"assembled with {', '.join(wanted)}"
        elif not expectation.pinned:
            verdict = "assembled (pins no bytes)"
        else:
            verdict = "OK byte-exact" if not wrong else "DIFFERS from pinned hash"
        print(f"  {rel}  crc32 {img.crc32}  {verdict}")
        if r.symbols_path:
            print(f"  {os.path.relpath(r.symbols_path, WORK_ROOT)}")


def cmd_check(args: argparse.Namespace) -> int:
    selection = _selection(args)
    results: list[tuple[str, object]] = []
    for base, versions in selection:
        if len(selection) > 1:
            print(f"\n=== base {base.id} ===")
        for result in run_check(
            versions,
            base=base,
            reference_path=args.reference,
            show_diff=not args.quiet,
            stage=False if args.no_stage else None,
        ):
            results.append((base.id, result))

    bad = [(base_id, r) for base_id, r in results if not r.exact]
    print("")
    if bad:
        # Named as `<base>/<target>`, because "E0 failed" is ambiguous the
        # moment two bases can both have a target of that name.
        print(
            f"FAIL  {len(bad)} of {len(results)} build(s) do not match the pinned "
            f"hashes: {', '.join(f'{b}/{r.version}' for b, r in bad)}"
        )
        return 1
    print(f"OK    {len(results)} of {len(results)} build(s) byte-exact")
    return 0


def cmd_play(args: argparse.Namespace) -> int:
    base, target = resolve_target(args.version)
    return run_in_emulator(
        target.id,
        base=base,
        no_build=args.no_build,
        seconds=args.seconds,
    )


def cmd_stop(args: argparse.Namespace) -> int:
    close_emulator()
    print("emulator closed")
    return 0


def cmd_verify_static(args: argparse.Namespace) -> int:
    print(
        "> static verification: freespace fill sizes, include path casing, "
        "palette branches\n"
    )
    report = run_static_verification(rom_base(args.base))
    print_report(report)
    return 1 if report.error_count else 0


def _ram_spaces(base: RomBase) -> list[str]:
    """The RAM spaces this base has, in the order they should be searched.

    Read off the base's own RAM map rather than listed, so a base with a
    coprocessor offers its memories and one without is not asked about spaces it
    has none of.
    """
    probes = (0x7E0000, base.ram_map.direct_page, 0x006000, 0x400000)
    found: list[str] = []
    for probe in probes:
        memory = base.ram_map.space_at(probe)
        space = SPACE_FOR_MEMORY[memory] if memory else None
        if space and space not in found:
            found.append(space)
    return found


def _rom_bound(base: RomBase) -> int:
    """One past the last ROM address this base's stock cartridge maps."""
    return base.address_map.address(ROM_SIZES[base.stock_size].size - 1) + 1


def _plausible_spaces(base: RomBase, addr: int, had_bank: bool) -> list[str]:
    """Which of ``base``'s address spaces a bare number could belong to.

    ARAM, VRAM and DSP are 16-bit spaces that overlap everything, so a 24-bit
    address is never offered against them -- doing so answers "$00A6C0" with an
    ARAM sample table, which is noise dressed up as a result. Ask for them
    explicitly with --space, or give a bare 16-bit address.

    **The base decides the RAM half.** ``$6100`` is unmapped on ``vanilla`` and
    the game's low RAM on ``sa1``; asking the base's own map is what keeps the
    second from being reported as the first.
    """
    ram = _ram_spaces(base)
    if not had_bank:
        return [*ram, "mmio", "aram", "vram", "dsp"]
    memory = base.ram_map.space_at(addr)
    if memory:
        return [SPACE_FOR_MEMORY[memory]]
    bank = addr >> 16
    off = addr & 0xFFFF
    if bank == 0x70:
        return ["sram"]
    if off >= 0x8000:
        # Through the base's own map, so a LoROM mirror resolves and a bank the
        # base stopped mirroring at does not. Bounded by the stock cartridge:
        # past that there is no ROM to have put anything in.
        try:
            in_rom = base.address_map.offset(addr)
        except ValueError:
            return []
        return ["rom"] if in_rom < ROM_SIZES[base.stock_size].size else []
    if bank <= 0x3F and 0x2100 <= off <= 0x43FF:
        return ["mmio"]
    return []


def _mapping_summary(base: RomBase) -> str:
    """What ``base`` maps where, for the message an unmapped address gets."""
    rom = (
        f"ROM ${base.address_map.address(0):06X}-${_rom_bound(base) - 1:06X} "
        f"(upper halves of banks)"
    )
    ram = ", ".join(
        f"{space} {where}"
        for space, where in (
            ("wram", "$7E-$7F"),
            ("iram", "$3000-$37FF"),
            ("bwram", "$40-$4F, window $6000-$7FFF"),
        )
        if space in _ram_spaces(base)
    )
    return f"{base.address_map.id}: {rom}, {ram}, SRAM $70:0000, registers $2100-$43FF"


def _symbols_for(base: RomBase) -> Path:
    """This base's symbol file, built or rebuilt if it is missing or stale.

    Per base, because the addresses in it are: the RAM map resolves against the
    base's own defines, so a symbol file built for ``vanilla`` describes a
    different cartridge from one built for ``sa1``, in the same shape.

    The index takes file:line from the current tree but every *address* from this
    file, so a stale one answers exactly like a right answer with the addresses
    of an older build. Rebuilt rather than refused, because that is already what
    a missing one does and the fix is the same either way. A build made with a
    feature switched on or at another size is the same trap with a record
    beside it, and :func:`~smw_tools.build.stock_build` replaces it first.
    """
    built = stock_build(base, on_progress=lambda m: print(f"> {m}"))
    if built is None or built.symbols_path is None:
        print(f"> no symbol file for {base.id} yet, building one")
    elif stale := stale_sources(sym_path := built.symbols_path, root=base.src_root):
        print(
            f"> {len(stale)} source file(s) changed since {base.id}'s symbol file "
            f"was built, starting with {stale[0]} -- rebuilding it"
        )
    else:
        return sym_path
    return build_symbols(base, on_progress=lambda m: print(f"> {m}"))


def _relocated_to(base: RomBase, ix: AddressIndex, addr: int) -> list[IndexedSymbol]:
    """Entries a **post-build patch** put at ``addr``, which the source did not.

    The index holds what the assembler resolved, and on a patched base that is
    only half the story: a patch moves memory again afterwards, so an address
    read off a running cartridge -- a trace, a watch, a crash -- can name a byte
    that appears nowhere in the assembled map. Those moves were measured rather
    than derived (see :mod:`~smw_tools.ram_map`), so this asks the map forwards
    for every entry instead of trying to invert it, which is both exact and
    cheap enough at two thousand entries.

    Entries the map refuses are skipped in silence here: an unmeasured table is
    reported when someone asks for it by name, not guessed at from an address
    that might belong to something else entirely.
    """
    found: list[IndexedSymbol] = []
    for s in ix.symbols:
        if s.vanilla_offset is None or s.name in base.ram_map.role_names:
            continue
        try:
            at = base.ram_map.place(s.vanilla_offset)
        except RamMapError:
            continue
        if addr in ({cpu_address(at)} | ({w} if (w := window_address(at)) else set())):
            # Already the source's own answer, so not a relocation at all.
            if s.addr != addr:
                found.append(s)
    return found


def _print_relocation(base: RomBase, s: IndexedSymbol) -> None:
    """What else is true about where a relocated entry lives.

    Two different moves reach the same byte and only one of them is in the
    source. The map file resolves against the base's defines, so a base that set
    them assembles the entry somewhere other than vanilla's ``$7E`` address --
    that is the first line, and the vanilla number is worth printing because it
    is what the comments, the community maps and every trace of a stock
    cartridge call this byte.

    The second is the one no reading of the source can find: a post-build patch
    moves things again, after the assembler is done. :mod:`ram_map` holds what
    was measured on the running cartridge, so where it disagrees with what the
    source assembled, the source is not the answer -- and where it refuses,
    nothing here knows and saying so is the only honest reply.
    """
    if s.kind != "memory" or s.vanilla_offset is None:
        return
    vanilla = 0x7E0000 + s.vanilla_offset
    if s.addr != vanilla:
        print(f"  {'':5} {format_addr(vanilla)} on {DEFAULT_BASE}")
    if s.name in base.ram_map.role_names:
        # A bound, not a byte: the relocation of the page it points into says
        # nothing about it, and the source's value is the measured one.
        return
    try:
        at = base.ram_map.place(s.vanilla_offset)
    except RamMapError as error:
        print(f"  note: {error}")
        return
    spellings = {cpu_address(at)} | ({w} if (w := window_address(at)) else set())
    if s.addr not in spellings:
        print(
            f"  note: on a running {base.id} cartridge this byte is at "
            f"{format_addr(cpu_address(at))} -- the address above is what the "
            f"source assembled, and the patch moves it after that"
        )


def cmd_symbol(args: argparse.Namespace) -> int:
    query = args.query
    base = rom_base(args.base)
    sym_path = _symbols_for(base)
    sys.stderr.write("indexing... ")
    import time

    t = time.time()
    ix: AddressIndex = build_address_index(sym_path, base)
    sys.stderr.write(
        f"{len(ix.symbols)} symbols ({int((time.time() - t) * 1000)}ms)\n\n"
    )
    g = graph(base)

    want_space = args.space
    hits: list[IndexedSymbol]

    if query in ix.by_name:
        hits = [s for s in ix.symbols if s.name == query]
    else:
        addr = parse_address(query)
        if addr is None:
            # A routine the graph knows but the symbol file does not: excluded
            # from this build by a version or feature define. The node and its
            # edges stand; only the address is missing.
            if r := g.routines.get(query):
                print(f"  {query}  {r.file}:{r.line}")
                print(
                    f"  no address in this build's symbol file -- a define "
                    f"this {base.id} build does not set excludes it\n\n"
                    f"  full detail: smw xref {query}"
                )
                return 0
            # A label inside a routine -- a data table, a branch target --
            # which the index does not key but the symbol file spells as
            # `<namespace>_<label>`. Asked for by either spelling.
            inner = _inner_labels_named(load_symbols(sym_path), query)
            if _print_inner_labels(inner, g):
                return 0
            print(
                f'error: "{query}" is neither a known symbol nor an address '
                f"-- try: smw xref --search {query}",
                file=sys.stderr,
            )
            return 1
        had_bank = len(query.lstrip("$")) > 4
        spaces = [want_space] if want_space else _plausible_spaces(base, addr, had_bank)
        if not spaces:
            print(
                f"error: {format_addr(addr)} is not a mapped address on a "
                f"{base.id} cartridge\n  ({_mapping_summary(base)})",
                file=sys.stderr,
            )
            return 1
        in_spaces = set(spaces)
        # Fold the query onto the spelling the index stores per space
        # ($40:0100 -> the $6100 window), the way lookup() does.
        want = {sp: _stored_spelling(sp, addr) for sp in in_spaces}
        hits = [
            s for s in ix.symbols if s.space in in_spaces and s.addr == want[s.space]
        ]
        if not hits and (relocated := _relocated_to(base, ix, addr)):
            hits = relocated
            print(
                f"  nothing the source assembles to {format_addr(addr)} -- "
                f"showing what a running {base.id} cartridge keeps there\n"
            )
        if not hits and "rom" in in_spaces:
            # An exact label at the address that the index does not key: a
            # table or a branch target inside a routine. Better than the
            # routine it falls inside, which is what the walk below answers.
            table = load_symbols(sym_path)
            exact = [s for s in table.by_addr if s.addr == addr]
            if _print_inner_labels(exact, g):
                return 0
        if not hits:
            for sp in spaces:
                c = lookup_containing(ix, sp, addr)
                if c:
                    hits.append(c)
            if hits:
                print(
                    f"  no label at {format_addr(addr)} exactly -- showing the "
                    f"symbol it falls inside\n"
                )
            else:
                print(
                    f"error: nothing at or below {format_addr(addr)} in "
                    f"{'/'.join(spaces)}",
                    file=sys.stderr,
                )
                return 1

    if want_space:
        hits = [s for s in hits if s.space == want_space]
    if not hits:
        print(f'error: no match in address space "{want_space}"', file=sys.stderr)
        return 1

    for s in hits:
        print(f"  {s.name}")
        mirrored = (
            f" (assembled as {format_addr(s.raw_addr)})" if s.addr != s.raw_addr else ""
        )
        print(f"  {s.space:<5} {format_addr(s.addr)}{mirrored}   {s.file}:{s.line}")
        _print_relocation(base, s)
        # A bank routine's line is its `macro` line, which never has a block
        # above it; a Config routine's is its label, documented from above like
        # a memory entry.
        rt = g.routines.get(s.name)
        if s.kind == "routine" and rt is not None and rt.kind == "macro":
            _print_routine_annotation(s.file, s.line)
        else:
            _print_annotation(s.file, s.line)

        def brief(label: str, names: list[str]) -> None:
            if not names:
                return
            shown = ", ".join(names[:8])
            more = ", ..." if len(names) > 8 else ""
            print(f"  {label:<11}({len(names)}) {shown}{more}")

        if s.kind == "routine":
            brief("called by ", sorted(g.callers.get(s.name, ())))
            brief("calls     ", sorted(g.calls.get(s.name, ())))
            brief("reads     ", sorted(g.reads.get(s.name, ())))
            brief("writes    ", sorted(g.writes.get(s.name, ())))
        else:
            brief("read by   ", sorted(n for n, v in g.reads.items() if s.name in v))
            brief("written by", sorted(n for n, v in g.writes.items() if s.name in v))
        print(f"\n  full detail: smw xref {s.name}")
        if len(hits) > 1:
            print("")
    return 0


def _inner_labels_named(table: SymbolTable, query: str) -> list[Symbol]:
    """The symbol-file labels ``query`` names: the flattened spelling
    exactly, or the bare label as its file spells it, `_<label>`-suffixed by
    whichever namespaces hold one."""
    if found := table.by_name.get(query):
        return [found]
    suffix = f"_{query}"
    return sorted(
        (s for s in table.by_name.values() if s.name.endswith(suffix)),
        key=lambda s: s.addr,
    )


def _print_inner_labels(found: list[Symbol], g: CodeGraph) -> bool:
    """Print the labels the index does not key -- the ones inside a routine
    -- naming the routine each sits in. False when there are none."""
    if not found:
        return False
    for s in found:
        owner = max(
            (
                name
                for name, r in g.routines.items()
                if r.namespace and s.name.startswith(f"{r.namespace}_")
            ),
            key=len,
            default=None,
        )
        print(f"  {s.name}")
        inside = f"   a label inside {owner}" if owner else ""
        print(f"  rom   {format_addr(s.addr)}{inside}")
        if owner:
            print(f"\n  full detail: smw xref {owner}")
        if len(found) > 1:
            print("")
    return True


def cmd_xref(args: argparse.Namespace) -> int:
    base = rom_base(args.base)
    g = graph(base)

    if args.stats:
        edges = sum(len(v) for v in g.calls.values())
        print(f"  routines       {len(g.routines)}")
        print(f"  memory labels  {len(g.memory)}")
        print(f"  defines        {len(g.defines)}")
        print(f"  call edges     {edges}")
        top = sorted(g.callers.items(), key=lambda kv: -len(kv[1]))[:15]
        print("\n  most-called routines")
        for n, c in top:
            print(f"    {len(c):>5}  {n}")
        return 0

    if args.search:
        rx = re.compile(args.search, re.IGNORECASE)
        hits = (
            [(n, "routine") for n in g.routines if rx.search(n)]
            + [(n, "memory") for n in g.memory if rx.search(n)]
            + [(n, "define") for n in g.defines if rx.search(n)]
        )
        for n, kind in sorted(hits):
            r = g.routines.get(n)
            where = (
                f"{r.file}:{r.line}" if r else (g.memory.get(n) or g.defines.get(n, ""))
            )
            print(f"  {kind:<8} {n}  {where}")
        print(f"\n  {len(hits)} match(es)")
        return 0

    # Both flags may be given at once, and both are answered: asking who reads
    # an address and who writes it is one question about it, and dropping the
    # second silently would answer half of it under a heading that looks whole.
    asked = False
    for key, mapping, verb in (
        ("readers", g.reads, "read"),
        ("writers", g.writes, "write"),
    ):
        target = getattr(args, key)
        if not target:
            continue
        asked = True
        hits = [n for n, s in mapping.items() if target in s]
        if target not in g.memory and target not in g.defines:
            print(f"  note: {target} is not a known memory label or define\n")
        _list(f"routines that {verb} {target}", hits, g, base)
        print("")
        _print_coverage(g, target, "write" if key == "writers" else "read", base)
    if asked:
        return 0

    name = args.name
    if not name:
        print(
            "error: xref needs a symbol name, --search <regex>, "
            "--readers/--writers <name>, or --stats",
            file=sys.stderr,
        )
        return 1

    r = g.routines.get(name)
    if r:
        print(f"  {name}  {r.file}:{r.line}-{r.end_line}")
        if r.kind == "macro":
            _print_routine_annotation(r.file, r.line)
        else:
            # A Config routine is a label, documented from above.
            _print_annotation(r.file, r.line)
        _list("called by", g.callers.get(name, ()), g, base)
        _list("calls", g.calls.get(name, ()), g, base)
        _list("reads", g.reads.get(name, ()), g, base)
        _list("writes", g.writes.get(name, ()), g, base)
        accs = g.accesses.get(name, ())
        for kind, label in (("write", "writes"), ("read", "reads")):
            through = sorted(
                {
                    a.symbol
                    for a in accs
                    if a.addressing == "indirect" and a.kind == kind
                }
            )
            if through:
                _list(
                    f"{label} through a pointer, to an address not named here",
                    through,
                    g,
                    base,
                )
        # A 16-bit store to a one-byte entry writes the next entry too, and this
        # is the only place the routine's own view of that is shown.
        spills = sorted(
            {
                f"{a.symbol} -> {victim}"
                for a in accs
                if a.kind == "write" and a.width == 16 and a.addressing == "direct"
                for victim, entry in memory_layout(base).covered_by.items()
                if entry == a.symbol
            }
        )
        if spills:
            print(f"  writes 16-bit over a one-byte entry ({len(spills)})")
            for s in spills:
                print(f"    {s}")
        return 0

    if name in g.memory or name in g.defines:
        where = g.memory.get(name) or g.defines.get(name)
        print(f"  {name}  defined in {where}")
        loc = _location_of(g, name, base)
        if loc:
            _print_annotation(loc[0], loc[1])
        else:
            print("")
        _list("read by", [n for n, s in g.reads.items() if name in s], g, base)
        _list("written by", [n for n, s in g.writes.items() if name in s], g, base)
        _list("referenced by", g.referenced_by.get(name, ()), g, base)
        print("")
        _print_coverage(g, name, "write", base)
        return 0

    print(
        f'error: unknown symbol "{name}" -- try: smw xref --search {name}',
        file=sys.stderr,
    )
    return 1


def cmd_closure(args: argparse.Namespace) -> int:
    base = rom_base(args.base)
    g = graph(base)
    name = args.routine
    if name not in g.routines:
        print(
            f'error: unknown routine "{name}" -- try: smw xref --search {name}',
            file=sys.stderr,
        )
        return 1

    depth = args.depth if args.depth is not None else math.inf
    reached = closure(g, name, depth)
    by_depth = sorted(reached.items(), key=lambda kv: (kv[1], kv[0]))

    suffix = f" within depth {depth}" if args.depth is not None else ""
    print(f"  {name}: {len(reached)} routine(s) reachable{suffix}\n")
    name_w = max(len(n) for n, _ in by_depth)
    for n, d in by_depth:
        r = g.routines[n]
        where = f"{r.file}:{r.line}"
        desc = _describe(g, n, 54, base)
        line = f"    {d:>2}  {n:<{name_w}}  {where:<24}"
        if desc:
            line += f"  {desc}"
        print(line.rstrip())

    if args.source:
        print("\n" + "=" * 70)
        for n, _ in by_depth:
            print(f"\n; ---- {n} ----")
            print(routine_source(g, n, base) or "; (source unavailable)")
    return 0


def cmd_annotate(args: argparse.Namespace) -> int:
    stats = annotate.run(
        args.table or annotate.DEFAULT_TSV,
        section=args.section,
        apply=args.apply,
        limit=args.limit,
        width=args.width,
    )

    def pad(n: int) -> str:
        return str(n).rjust(6)

    print(f"  rows in table        {pad(stats.rows)}")
    print(f"  not applicable       {pad(stats.not_applicable)}   other hardware")
    print(f"  distinct addresses   {pad(stats.targets)}")
    print(f"    resolved           {pad(stats.resolved)}")
    print(f"    no line there      {pad(stats.unresolved)}   unnamed, or mid-table")
    print(f"    line already taken {pad(stats.ambiguous)}   claimed by another")
    print(f"    already documented {pad(stats.already_present)}")
    verb = "annotated" if args.apply else "would annotate"
    print(f"  {verb:20} {pad(stats.edited)}   across {stats.files_touched} file(s)")
    if args.report:
        path = Path(args.report)
        path.write_text(
            "\n".join(
                ["# no line there"]
                + stats.unresolved_addrs
                + ["", "# line already taken"]
                + stats.ambiguous_addrs
            )
            + "\n"
        )
        print(f"  unresolved written to {path}")
    if not args.apply:
        print("\n  (dry run -- pass --apply to write)")
    return 0


def cmd_clean(args: argparse.Namespace) -> int:
    shutil.rmtree(BUILD_DIR, ignore_errors=True)
    print(f"removed {os.path.relpath(BUILD_DIR, WORK_ROOT)}/")
    return 0


def cmd_map16(args: argparse.Namespace) -> int:
    """Convert between the tree's Map16 tables and a Lunar Magic container."""
    tables_dir = GAME_DIR / "GFX" / "Map16"

    if args.action == "pack":
        tables = {path.stem: path.read_bytes() for path in tables_dir.glob("*.bin")}
        container = map16.pack(tables)
        Path(args.path).write_bytes(container)
        vanilla = map16.container_sha1(container) == map16.VANILLA_SHA1
        print(
            f"wrote {args.path}  {len(container):,} bytes from {len(tables)} tables"
            f"  ({'vanilla' if vanilla else 'edited'})"
        )
        return 0

    tables = map16.unpack(Path(args.path).read_bytes())
    for name, blob in sorted(tables.items()):
        target = tables_dir / f"{name}.bin"
        changed = not target.exists() or target.read_bytes() != blob
        target.write_bytes(blob)
        print(f"  {name:<20} {len(blob):>6,} bytes  {'changed' if changed else 'same'}")
    where = os.path.relpath(tables_dir, WORK_ROOT)
    print(f"unpacked {len(tables)} tables into {where}/")
    return 0


# --------------------------------------------------------------------------


#: Repeated on every command that assembles or reads a base's tree.
_BASE_HELP = f"which ROM base to use (default {DEFAULT_BASE})"


def build_parser() -> argparse.ArgumentParser:
    default = rom_base()
    versions = ", ".join(f"{v}={t.label}" for v, t in default.targets.items())
    p = argparse.ArgumentParser(
        prog="smw",
        description="Super Mario World disassembly",
        epilog=f"Bases: {', '.join(BASES)}\n{DEFAULT_BASE} targets: {versions}",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = p.add_subparsers(dest="command", metavar="<command>")

    b = sub.add_parser("build", help="assemble one release (default U) into build/")
    b.add_argument("version", nargs="?", help="J, U, SS, E0 or E1, or <base>/<target>")
    b.add_argument("--base", choices=list(BASES), help=_BASE_HELP)
    b.add_argument(
        "--all", action="store_true", help="assemble every target of every base"
    )
    b.add_argument("--symbols", action="store_true", help="also emit a WLA symbol file")
    b.add_argument(
        "--rom-size",
        choices=list(ROM_SIZES),
        help="assemble a larger cartridge (default 512kb, the stock size)",
    )
    b.add_argument(
        "--feature",
        action="append",
        metavar="ID",
        choices=list(FEATURES) or None,
        help="build with a feature switched on; repeat for more than one",
    )
    b.set_defaults(func=cmd_build)

    c = sub.add_parser("check", help="assemble, then verify against the pinned hashes")
    c.add_argument("version", nargs="?", help="J, U, SS, E0 or E1, or <base>/<target>")
    c.add_argument("--base", choices=list(BASES), help=_BASE_HELP)
    c.add_argument(
        "--all", action="store_true", help="verify every target of every base"
    )
    c.add_argument("--reference", help="also diff against a dump on disk")
    c.add_argument("--quiet", action="store_true", help="suppress per-region diff")
    c.add_argument(
        "--no-stage",
        action="store_true",
        help="assemble in place rather than from a scratch copy of the sources",
    )
    c.set_defaults(func=cmd_check)

    v = sub.add_parser(
        "verify-static", help="checks the byte gate cannot make, without building"
    )
    v.add_argument("--base", choices=list(BASES), help=_BASE_HELP)
    v.set_defaults(func=cmd_verify_static)

    s = sub.add_parser("symbol", help="look a symbol up by name or address")
    s.add_argument("query", help="a label name, or an address like $7E0DBE")
    s.add_argument(
        "--space", choices=list(ADDRESS_SPACES), help="restrict to one address space"
    )
    s.add_argument("--base", choices=list(BASES), help=_BASE_HELP)
    s.set_defaults(func=cmd_symbol)

    x = sub.add_parser("xref", help="callers, callees, reads and writes for one symbol")
    x.add_argument("name", nargs="?", help="symbol to describe")
    x.add_argument("--search", metavar="REGEX", help="list symbols matching a pattern")
    x.add_argument("--readers", metavar="NAME", help="routines that read NAME")
    x.add_argument("--writers", metavar="NAME", help="routines that write NAME")
    x.add_argument("--stats", action="store_true", help="graph summary")
    x.add_argument("--base", choices=list(BASES), help=_BASE_HELP)
    x.set_defaults(func=cmd_xref)

    cl = sub.add_parser(
        "closure", help="a routine plus everything it transitively calls"
    )
    cl.add_argument("routine")
    cl.add_argument("--depth", type=int, help="limit traversal depth")
    cl.add_argument("--source", action="store_true", help="print the source of the set")
    cl.add_argument("--base", choices=list(BASES), help=_BASE_HELP)
    cl.set_defaults(func=cmd_closure)

    pl = sub.add_parser("play", help="build and boot in Mesen")
    pl.add_argument("version", nargs="?", help="J, U, SS, E0 or E1, or <base>/<target>")
    pl.add_argument("--seconds", type=float, help="close the emulator after N seconds")
    pl.add_argument("--no-build", action="store_true", help="reuse the existing build")
    pl.set_defaults(func=cmd_play)

    st = sub.add_parser("stop", help="close a running emulator")
    st.set_defaults(func=cmd_stop)

    an = sub.add_parser(
        "annotate", help="fold an address-keyed reference table in as comments"
    )
    an.add_argument(
        "--table", help=f"TSV to read (default {annotate.DEFAULT_TSV.name})"
    )
    an.add_argument("--section", help="restrict to one section: RAM, ROM, Regs, SRAM")
    an.add_argument("--apply", action="store_true", help="write; otherwise a dry run")
    an.add_argument("--limit", type=int, help="stop after this many insertions")
    an.add_argument(
        "--width", type=int, default=annotate.DEFAULT_WIDTH, help="comment width"
    )
    an.add_argument("--report", metavar="PATH", help="write unresolved addresses here")
    an.set_defaults(func=cmd_annotate)

    cn = sub.add_parser("clean", help="remove build/")
    cn.set_defaults(func=cmd_clean)

    m16 = sub.add_parser(
        "map16",
        help="convert the Map16 tables to and from a Lunar Magic .map16 container",
        description=(
            "The tree holds one file per Map16 table under SMW/GFX/Map16/, which is "
            "what the build includes. Lunar Magic interchanges the same data as a "
            "single .map16 container; pack produces one and unpack reads one back."
        ),
    )
    m16.add_argument("action", choices=("pack", "unpack"))
    m16.add_argument("path", help="the .map16 container to write, or to read")
    m16.set_defaults(func=cmd_map16)

    return p


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if not getattr(args, "command", None):
        parser.print_help()
        return 1
    try:
        return args.func(args)
    except (ValueError, FileNotFoundError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
