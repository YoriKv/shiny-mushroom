"""An address -> source location index over the whole tree.

Neither half of this is available on its own. The symbol file knows what address
every label resolved to but not where it is written; the source knows where
labels are written but not what they resolve to (that is the assembler's
arithmetic). Joining them is what lets an address -- from a trace log, a
debugger watch, a crash, a memory map -- be pointed back at the exact line that
defines it.

ADDRESS SPACES ARE NOT INTERCHANGEABLE. $0000 is a valid address in nine
different spaces here, and the assembler resolves labels in all of them into one
flat number line. Matching purely on the number silently maps a WRAM reference
onto a VRAM or DSP label. Every lookup must carry a space.

AND NEITHER ARE BASES. The RAM map is written against
``!Define_SMW_LowRAMLocation`` and ``!Define_SMW_DirectPageLocation``, which a
base sets before the map is included -- ``sa1`` moves the game's low RAM to
``$6000`` and its direct page to ``$3000``. An index built without the base's
defines resolves every entry to vanilla's address, which parses, prints and
cross-references exactly like a right answer. So every lookup carries a base
too, and the two bases genuinely disagree: ``$7E0100`` is the game mode on
``vanilla`` and nothing at all on ``sa1``, where it is ``$40:0100``.

Requires a symbol file: ``smw build --symbols``.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import TYPE_CHECKING

from .codegraph import (
    GAME_DEFINES,
    RAM_MAP,
    SRAM_MAP,
    build_graph,
    resolve_base,
)
from .ram_map import (
    BWRAM_BANK,
    BWRAM_BANK_END,
    MemorySpace,
    RamLocation,
    cpu_address,
    window_address,
)
from .symbols import containing, load_symbols

if TYPE_CHECKING:
    from .bases import RomBase

#: rom   -- cartridge, as the base's own address map reaches it
#: wram  -- $7E-$7F, and the $00-$3F:0000-1FFF mirror
#: iram  -- SA-1 I-RAM, $3000-$37FF, on a base that has one
#: bwram -- SA-1 BW-RAM, banks $40-$4F and the window at $6000-$7FFF
#: sram  -- $70:0000
#: aram  -- SPC700-local
#: vram  -- PPU-local
#: mmio  -- 65816 hardware registers, $2100-$43FF
#: dsp   -- SPC700 DSP registers
ADDRESS_SPACES = (
    "rom",
    "wram",
    "iram",
    "bwram",
    "sram",
    "aram",
    "vram",
    "mmio",
    "dsp",
)

#: The RAM map's memories, as this module's space ids. Two vocabularies because
#: they answer different questions -- :mod:`ram_map` says which *memory* a byte
#: is in, and an index entry says which *address space* a number was resolved in
#: -- and this is the single place they are joined.
SPACE_FOR_MEMORY: dict[MemorySpace, str] = {
    MemorySpace.WORK_RAM: "wram",
    MemorySpace.SA1_IRAM: "iram",
    MemorySpace.SA1_BWRAM: "bwram",
}


@dataclass(frozen=True)
class IndexedSymbol:
    name: str
    #: 24-bit address. WRAM is normalised to the $7E form; others as resolved.
    addr: int
    #: The address exactly as the assembler resolved it, before normalisation.
    raw_addr: int
    space: str
    kind: str  # 'routine' | 'memory'
    #: Path relative to src/.
    file: str
    #: 1-indexed line of the defining label.
    line: int
    #: The entry's offset into vanilla's work RAM, set for every memory entry
    #: that names a work-RAM byte -- whether or not this base moved it. ``None``
    #: for a routine, and for an entry (a register, SRAM) that names no work-RAM
    #: byte.
    #:
    #: This is the durable name for the byte -- what the disassembly's comments,
    #: an emulator watch on a stock cartridge and every community memory map
    #: call it -- and keeping it is what lets a relocated entry be reported as
    #: *moved* rather than as an unrelated address.
    vanilla_offset: int | None = None


@dataclass
class AddressIndex:
    symbols: list[IndexedSymbol] = field(default_factory=list)
    by_name: dict[str, IndexedSymbol] = field(default_factory=dict)
    #: Keyed by ``(space, addr)`` -- use lookup() rather than indexing directly.
    by_space_addr: dict[tuple[str, int], list[IndexedSymbol]] = field(
        default_factory=dict
    )
    #: Each space's symbols, sorted ascending by address -- what
    #: :func:`lookup_containing` bisects.
    by_space: dict[str, list[IndexedSymbol]] = field(default_factory=dict)
    #: Labels with no address, i.e. excluded from this build by a version conditional.
    unresolved: list[str] = field(default_factory=list)


def normalize_wram(addr: int) -> int:
    """Fold the bank-$00 WRAM mirror onto the $7E form.

    The low 8 KiB of WRAM is reachable as $7E:0000-1FFF and, more cheaply, as
    $00-$3F:0000-1FFF. The source uses the mirror; external references almost
    always use the $7E form. Applied to WRAM only -- doing it by number alone
    would rewrite ARAM $0500 into WRAM $7E0500.
    """
    off = addr & 0xFFFF
    if (addr >> 16) <= 0x3F and off < 0x2000:
        return 0x7E0000 | off
    return addr


#: BW-RAM's 128 kB image; its banks are :mod:`ram_map`'s. The banks' 1 MB of
#: addresses wraps the image eight times over, which is why folding starts with
#: a modulo.
_BWRAM_SIZE = 0x20000


def normalize_bwram(addr: int) -> int:
    """Fold a bank spelling of BW-RAM onto the spelling the index stores.

    All of BW-RAM is reachable through banks $40-$4F, but its first 8 kB is
    also the window at $6000, and the window is how the source spells
    everything stored there -- so that is the address the index holds. A query
    in the bank form ($40:0100 for the byte the source calls $6100) folds onto
    the window where one exists, and onto the canonical bank address above it.
    16-bit window spellings and every other space pass through unchanged.
    """
    if not BWRAM_BANK <= addr >> 16 < BWRAM_BANK_END:
        return addr
    at = RamLocation(MemorySpace.SA1_BWRAM, (addr - (BWRAM_BANK << 16)) % _BWRAM_SIZE)
    w = window_address(at)
    return w if w is not None else cpu_address(at)


def _stored_spelling(space: str, addr: int) -> int:
    """The one spelling of ``addr`` the index stores for ``space``."""
    if space == "wram":
        return normalize_wram(addr)
    if space == "bwram":
        return normalize_bwram(addr)
    return addr


def work_ram_offset(addr: int) -> int | None:
    """``addr`` as an offset into work RAM's 128 kB, or ``None`` if it is outside.

    The durable name for a byte of the game's state -- see
    :mod:`~smw_tools.ram_map` -- and what a base's RAM map is keyed on, so this is
    the step between an address the map file resolved to and a question that map
    can answer. ``None`` for a register or an SRAM entry, which name no
    work-RAM byte and are the same on every base anyway.
    """
    folded = normalize_wram(addr)
    return folded - 0x7E0000 if folded >> 16 in (0x7E, 0x7F) else None


#: The space an entry's own prefix states, where no address could. A VRAM
#: address is a plain 16-bit word into the PPU's own memory, so `$1000` says
#: nothing that separates it from work RAM -- only the name does. `!RAM_` is
#: deliberately absent: which memory *that* lands in is the base's answer, not
#: the prefix's.
_SPACE_FOR_PREFIX = {"!VRAM_": "vram"}


def _space_for_memory_entry(base: RomBase, name: str, file: str, addr: int) -> str:
    """Which address space a RAM-map entry belongs to.

    Derived from the address rather than the file: this tree groups the whole
    map under Memory/WRAM_*.asm regardless of what a given entry addresses, so
    the filename no longer separates the spaces the way our own layout did.
    The exception is a prefix that names a memory outright --
    :data:`_SPACE_FOR_PREFIX`.

    And derived against the **base**, because the same file resolves to
    different numbers on each: ``$6100`` is unmapped on ``vanilla`` and the
    game's low RAM on ``sa1``. The base's RAM map is asked first and its answer
    taken, since it is the only thing that knows which memories this cartridge
    has; SRAM and the register file are the console's and are the same either
    way.
    """
    for prefix, space in _SPACE_FOR_PREFIX.items():
        if name.startswith(prefix):
            return space
    if Path(file).name == SRAM_MAP or 0x700000 <= addr < 0x780000:
        return "sram"
    if 0x2100 <= addr <= 0x21FF or 0x4200 <= addr <= 0x44FF:
        return "mmio"
    memory = base.ram_map.space_at(addr)
    # An address the base's RAM map does not claim is still in the map file, so
    # it is still RAM of some kind -- an entry above what a coprocessor took
    # over, most likely. Reported as work RAM, which is what it was.
    return SPACE_FOR_MEMORY[memory] if memory else "wram"


#: `!RAM_SMW_Flag_Lagging #= $000010`, or `#= !Other+$01`. The RAM map defines
#: with asar's `#=`, which evaluates at the point of definition -- a plain `=`
#: would be substituted as text and flip the sign of a relative entry's offset
#: inside a subtraction. A handful of entries that cannot be evaluated there
#: still use `=`, so both spellings have to parse. A quoted right-hand side is
#: an *access spelling* (`!RAM_SMW_NorSpr_XPosLo_x = "!RAM_SMW_NorSpr_XPosLo,x"`),
#: which names a table and a mode rather than an address, and is not an entry.
#: A trailing comment is part of the line and not of the expression: an entry
#: with one is still an entry, or `smw symbol` answers for its neighbour.
_RAM_ENTRY = re.compile(r"^\s*!([A-Za-z0-9_]+)\s*#?=\s*([^;\"]+?)\s*(?:;.*)?$")

#: ``if defined("Define_SMW_LowRAMLocation") == 0``: the map's own guard around
#: every default a base is allowed to override. Forty of them, and they are why
#: a base sets where work RAM lives with a ``--define`` rather than a second copy
#: of the file.
_GUARD = re.compile(r'^\s*if\s+defined\("([A-Za-z0-9_]+)"\)\s*==\s*0\s*$')
#: ``if defined("Define_SMW_SA1")``: a block a base *opts into* -- the SA-1
#: sprite-table layout is one -- read only on a base that set the name.
_OPT_IN = re.compile(r'^\s*if\s+defined\("([A-Za-z0-9_]+)"\)\s*$')
_IF = re.compile(r"^\s*if\b")
_ENDIF = re.compile(r"^\s*endif\b")


#: A `!Name` reference inside a right-hand side.
_REFERENCE = re.compile(r"!([A-Za-z0-9_]+)")


def _evaluate(expr: str, sym: dict[str, int]) -> int | None:
    """One right-hand side, against the entries resolved so far.

    ``None`` for anything that cannot be worked out here, **a name this table
    has never seen included**. Substituting zero for an unknown one is what
    turns an entry written against a define set elsewhere into a confident
    ``$000000``: an address that parses, prints and cross-references exactly
    like a right answer. A few dozen entries are relative to an asar *label*
    rather than a define, and there is no arithmetic here that could reach one.
    """
    if any(name not in sym for name in _REFERENCE.findall(expr)):
        return None
    resolved = _REFERENCE.sub(
        lambda g: str(sym[g.group(1)]),
        expr.replace("$", "0x"),
    )
    try:
        return int(eval(resolved, {"__builtins__": {}}, {}))  # noqa: S307
    except Exception:
        return None


#: `incsrc "Memory/WRAM_DirectPage.asm"` in the RAM map.
_INCSRC = re.compile(r'^\s*incsrc\s+"([^"]+)"')


def ram_map_order(base: RomBase | None = None) -> dict[str, int]:
    """The RAM map's include order, as ``src/``-relative path -> position.

    This is the tree's own statement of which file is authoritative for an
    address, and of the order the map's arithmetic runs in: the region maps
    first, the catch-all last. **A thousand entries are written relative to an
    earlier one**, so a walk in any other order -- a sorted glob over
    ``Memory/``, say -- resolves those against entries that have not been seen
    yet. Reading it here rather than hardcoding a list means a reordered or
    renamed include is followed rather than silently ignored.
    """
    rom_base = resolve_base(base)
    folder = f"{rom_base.game_folder}/"
    path = rom_base.src_root / folder / RAM_MAP
    if not path.is_file():
        return {}
    # The `incsrc` spellings verbatim, under the game folder: forward slashes on
    # every platform, which is what makes these keys comparable with the
    # ``src/``-relative paths the rest of this module hands out.
    names = [
        f"{folder}{m.group(1)}"
        for m in (
            _INCSRC.match(ln) for ln in path.read_text(encoding="latin-1").split("\n")
        )
        if m
    ]
    return {name: i for i, name in enumerate(names)}


def _seed_defines(rom_base: RomBase, sym: dict[str, int]) -> None:
    """Add the game's own defines file to ``sym``, in its own order.

    The map is written against names the ROM map sets before it -- a VRAM
    entry's page, a save file's length -- and those live in the defines file
    rather than in the map. Without them those entries have no address at all.
    """
    path = rom_base.src_root / rom_base.game_folder / GAME_DEFINES
    if not path.is_file():
        return
    for raw in path.read_text(encoding="latin-1").split("\n"):
        m = _RAM_ENTRY.match(raw)
        if m is None:
            continue
        value = _evaluate(m.group(2).strip(), sym)
        if value is not None:
            sym.setdefault(m.group(1), value)


def _memory_label_locations(
    base: RomBase | None = None,
) -> dict[str, tuple[str, int, str, int]]:
    """Address, line and space for every RAM-map entry, **on ``base``**.

    The map is `!Name #= $address` defines rather than `skip`-anchored labels, so
    addresses come from evaluating the right-hand side instead of from summing
    skip sizes. Most of the entries are relative to an earlier one
    (`!X #= !Y+$01`), which is why this resolves as it goes and keeps a running
    symbol table -- **and why the files are walked in the map's own ``incsrc``
    order** (:func:`ram_map_order`) rather than in whatever order the directory
    lists them.

    **The base's source defines are seeded in first**, then the game's defines
    file, and the map's own ``if defined(...) == 0`` guards are honoured so the
    seeded value survives the default beneath it -- which is exactly what asar
    does with them -- while a block a base opts into, ``if defined(...)``
    with no comparison, is read only on a base that set the name. That is
    the whole of how a base relocates work RAM: ``sa1`` passes a direct page
    of ``$3000`` and a low RAM of ``$6000``, and the entries written against
    those two follow, along with the thousand more
    written against *them*.

    An entry whose right-hand side names something no file read here defines is
    left out rather than given a number -- see :func:`_evaluate`.

    Defines are not labels, so they never reach asar's .sym output; this is the
    only source for them.
    """
    rom_base = resolve_base(base)
    out: dict[str, tuple[str, int, str, int]] = {}
    #: The names the base set on the command line, which the map's own guarded
    #: defaults must not overwrite.
    given: dict[str, int] = {}
    for name, value in rom_base.source_defines:
        seeded = _evaluate(value, given)
        if seeded is not None:
            given[name] = seeded
    sym: dict[str, int] = dict(given)
    _seed_defines(rom_base, sym)

    root = rom_base.src_root / rom_base.game_folder
    included = [rom_base.src_root / rel for rel in ram_map_order(rom_base)]
    # Anything under Memory/ the map does not name, after everything it does.
    # asar never sees such a file, so there is no order it belongs in; reading it
    # last is what keeps a half-written map answering for the entries it has.
    named = set(included)
    files = [
        *included,
        *sorted(p for p in (root / "Memory").glob("*.asm") if p not in named),
    ]
    sram = root / SRAM_MAP
    if sram.is_file():
        files.append(sram)
    for f in files:
        if not f.is_file():
            continue
        # Forward slashes on every platform: these paths are matched against the
        # `incsrc "..."` spellings the sources carry, so a Windows separator here
        # would miss every one of them.
        rel = f.relative_to(rom_base.src_root).as_posix()
        #: Depth of the guarded block currently being overridden, and the name it
        #: guards. Counted rather than flagged so a conditional nested inside one
        #: cannot end it early.
        depth, overridden = 0, ""
        for i, raw in enumerate(f.read_text(encoding="latin-1").split("\n")):
            if depth:
                if _IF.match(raw):
                    depth += 1
                elif _ENDIF.match(raw):
                    depth -= 1
                    if not depth:
                        overridden = ""
                    continue
            elif guard := _GUARD.match(raw):
                # Only a guard over something already defined is overridden --
                # by the base on its command line, or by a block above that
                # the base opted into. Every other one is the default taking
                # effect, which is what happens on a base that said nothing.
                if guard.group(1) in sym:
                    depth, overridden = 1, guard.group(1)
                continue
            elif opt_in := _OPT_IN.match(raw):
                # A block for a base that set the name: read as plain lines on
                # that base, its own `endif` then falling through harmlessly;
                # skipped whole on any other.
                if opt_in.group(1) not in given and opt_in.group(1) not in sym:
                    depth, overridden = 1, ""
                continue
            m = _RAM_ENTRY.match(raw)
            if not m:
                continue
            name, expr = m.group(1), m.group(2).strip()
            if name == overridden:
                # The default is where the entry is *written*, so the line is
                # still recorded -- with the value that actually took, not the
                # one asar skipped past.
                addr = sym[name]
            elif depth:
                # Some other entry inside an overridden guard. Nothing in this
                # tree has one, and guessing at it would put a wrong address in
                # the index rather than leave a name out of it.
                continue
            else:
                evaluated = _evaluate(expr, sym)
                if evaluated is None:
                    continue
                addr = evaluated
                sym[name] = addr
            # Keyed with the `!` so it matches how the code graph records a
            # define; the bare name is what expressions above refer to.
            if f"!{name}" not in out:
                out[f"!{name}"] = (
                    rel,
                    i + 1,
                    _space_for_memory_entry(rom_base, f"!{name}", rel, addr),
                    addr,
                )
    return out


def build_address_index(
    sym_path: Path | str, base: RomBase | None = None
) -> AddressIndex:
    """Every symbol of ``base``, by name and by address.

    ``sym_path`` must be the symbol file of a build **of this base**, since that
    is where every ROM address comes from -- see
    :func:`~smw_tools.build.symbols_path`, which is what names it.
    """
    rom_base = resolve_base(base)
    g = build_graph(rom_base)
    sym = load_symbols(sym_path)
    mem_locs = _memory_label_locations(rom_base)
    # The same map on the base a byte is *named* after, so an entry this base
    # moved can say where it moved from. Skipped when the base did not move
    # anything, where it would be the same walk twice for no answer.
    moved = bool(rom_base.source_defines)
    vanilla_locs = _memory_label_locations(resolve_base()) if moved else mem_locs

    ix = AddressIndex()

    def add(
        name: str,
        kind: str,
        file: str,
        line: int,
        space: str,
        raw: int | None = None,
        vanilla_offset: int | None = None,
    ) -> None:
        """Record ``name``. ``raw`` supplies the address when .sym cannot."""
        if raw is None:
            s = sym.by_name.get(name)
            if s is None:
                # Version-exclusive labels legitimately have no address here.
                ix.unresolved.append(name)
                return
            raw = s.addr
        addr = _stored_spelling(space, raw)
        ix.symbols.append(
            IndexedSymbol(
                name=name,
                addr=addr,
                raw_addr=raw,
                space=space,
                kind=kind,
                file=file,
                line=line,
                vanilla_offset=vanilla_offset,
            )
        )

    # A routine is a macro, and macros are not labels, so no routine name ever
    # appears in .sym. Its address is that of the first label inside it, which
    # asar flattened to `<namespace>_<label>` -- conventionally `_Main`.
    for name, r in g.routines.items():
        # Every routine indexed here is ROM. `base` appears in Banks/ too, but
        # in this tree it aliases pointer tables (`GameModePtrs: base $000000`)
        # rather than marking ARAM-resident code -- the SPC700 engine lives in
        # SPC700/*.asm and is assembled in a separate pass, which this index does
        # not read. Inferring ARAM from a `base` region here mislabels ordinary
        # 65816 routines, so it is deliberately not done.
        space = "rom"
        raw: int | None = None
        if r.kind == "label":
            # A Config routine's name is the label itself, so it appears in
            # .sym directly -- but only on a build with its feature define on.
            # A stock symbol file has no entry for it, and the node then stands
            # in the graph with no address on this build.
            entry = sym.by_name.get(name)
            raw = entry.addr if entry else None
        elif r.namespace:
            entry = sym.by_name.get(f"{r.namespace}_Main")
            if entry is None:
                candidates = [
                    s for n, s in sym.by_name.items() if n.startswith(f"{r.namespace}_")
                ]
                entry = min(candidates, key=lambda s: s.addr) if candidates else None
            raw = entry.addr if entry else None
        if raw is None:
            ix.unresolved.append(name)
        else:
            add(name, "routine", r.file, r.line, space, raw=raw)

    # RAM entries are defines, which never reach .sym; their addresses come from
    # evaluating the map itself.
    for name in g.memory:
        loc = mem_locs.get(name)
        if loc:
            vanilla = vanilla_locs.get(name)
            add(
                name,
                "memory",
                loc[0],
                loc[1],
                loc[2],
                raw=loc[3],
                vanilla_offset=work_ram_offset(vanilla[3]) if vanilla else None,
            )
        else:
            ix.unresolved.append(name)

    for s in ix.symbols:
        ix.by_space_addr.setdefault((s.space, s.addr), []).append(s)
        ix.by_space.setdefault(s.space, []).append(s)
        ix.by_name.setdefault(s.name, s)
    for ordered in ix.by_space.values():
        ordered.sort(key=lambda s: s.addr)

    return ix


def lookup(ix: AddressIndex, space: str, addr: int) -> list[IndexedSymbol]:
    a = _stored_spelling(space, addr)
    return ix.by_space_addr.get((space, a), [])


def lookup_containing(ix: AddressIndex, space: str, addr: int) -> IndexedSymbol | None:
    """The symbol covering ``addr`` within the same space.

    Used when an external reference points into the middle of a table or routine
    rather than at its head.
    """
    ordered = ix.by_space.get(space)
    if ordered is None:
        # An index assembled by hand rather than by build_address_index. Sorting
        # here costs a pass; answering None would be a wrong answer.
        ordered = sorted(
            (s for s in ix.symbols if s.space == space), key=lambda s: s.addr
        )
    return containing(ordered, _stored_spelling(space, addr), lambda s: s.addr)


def parse_address(text: str) -> int | None:
    """Parse ``$7E0DBE``, ``7E0DBE``, ``$0DBE`` into a 24-bit address."""
    m = re.fullmatch(r"\$?([0-9A-Fa-f]{2,6})", text.strip())
    return int(m.group(1), 16) if m else None


def format_addr(addr: int) -> str:
    """``$05D000``. :func:`smw_tools.symbols.format_bank_addr` writes the other
    spelling, ``$05:D000``."""
    return f"${addr:06X}"
