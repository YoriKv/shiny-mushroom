"""Symbol-file parsing.

asar can emit labels in WLA or no$sns format. WLA is the one to prefer: it is
line-oriented, unambiguous, and gives bank:addr directly. A symbol file is
authoritative in a way that grepping the source is not -- it reflects what the
assembler actually resolved, including everything that moved because a version
conditional shifted bytes around.
"""

from __future__ import annotations

import re
from bisect import bisect_right
from collections.abc import Callable, Iterable, Sequence
from dataclasses import dataclass, field
from pathlib import Path

WLA_LINE = re.compile(r"^([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4})\s+(\S+)")

#: What :func:`merge_pack_labels` writes before a patch pass's labels, and what
#: the parser uses to tell them from the assemble's own. One comment line
#: inside ``[labels]``; every label after it is the patch's.
PACK_MARKER = "merged by smw_tools.symbols.merge_pack_labels"


def _default_root() -> Path:
    """The default base's source tree, resolved late so a redirected base wins."""
    from .codegraph import resolve_base  # noqa: PLC0415 -- avoids an import cycle

    return resolve_base().src_root


@dataclass(frozen=True)
class Symbol:
    #: 24-bit SNES address.
    addr: int
    name: str
    #: Whether a patch pass placed it, rather than the assemble -- read off
    #: :data:`PACK_MARKER` in the file, so a consumer can ask where the patch's
    #: own code landed without a declaration saying so beside the base.
    pack: bool = False


@dataclass
class SymbolTable:
    by_name: dict[str, Symbol] = field(default_factory=dict)
    #: Sorted ascending by address. Multiple names can share one address.
    by_addr: list[Symbol] = field(default_factory=list)


def parse_wla_symbols(text: str) -> list[Symbol]:
    out: list[Symbol] = []
    in_labels = False
    pack = False
    for raw in text.split("\n"):
        line = raw.strip()
        if line.startswith("["):
            in_labels = line.lower() == "[labels]"
            pack = False
            continue
        if not in_labels or not line:
            continue
        if line.startswith(";"):
            if PACK_MARKER in line:
                pack = True
            continue
        m = WLA_LINE.match(line)
        if not m:
            continue
        out.append(
            Symbol(
                addr=(int(m.group(1), 16) << 16) | int(m.group(2), 16),
                name=m.group(3),
                pack=pack,
            )
        )
    return out


def load_symbols(sym_path: Path | str) -> SymbolTable:
    p = Path(sym_path)
    if not p.exists():
        raise FileNotFoundError(
            f"symbol file not found at {p} -- run `smw build --symbols` first"
        )
    syms = parse_wla_symbols(p.read_text(encoding="latin-1"))
    table = SymbolTable()
    for s in syms:
        table.by_name.setdefault(s.name, s)
    table.by_addr = sorted(syms, key=lambda s: s.addr)
    return table


def merge_pack_labels(main_sym: Path, pack_sym: Path, provenance: str) -> None:
    """Fold a patch pass's labels into ``main_sym``'s ``[labels]`` section.

    The main pass's symbol file describes the source assemble, whose labels the
    patch edits in place and never moves; the patch pass's describes only what
    the patch itself placed. Merged, one file describes the whole cartridge,
    which is what lets a patched base have a symbol table of its own instead of
    borrowing its source's.

    Anonymous labels -- asar's ``:pos_*``/``:neg_*`` and macro-local names, all
    prefixed ``:`` -- are dropped from the patch's contribution: they are
    meaningless outside the file that assembled them and collide with the main
    pass's own by construction. A *named* collision is an error rather than a
    shadowing, because either file's answer would be wrong for the other's
    address and nothing downstream could tell.
    """
    added = [
        s for s in parse_wla_symbols(pack_sym.read_text(encoding="latin-1"))
        if not s.name.startswith(":")
    ]
    lines = main_sym.read_text(encoding="latin-1").split("\n")
    named = {
        s.name
        for s in parse_wla_symbols("\n".join(lines))
        if not s.name.startswith(":")
    }
    clash = sorted({s.name for s in added} & named)
    if clash:
        raise ValueError(
            f"{provenance} defines {len(clash)} label(s) the assemble also "
            f"defines, starting with {clash[0]} -- the merged symbol file "
            f"cannot say which address such a name means"
        )

    # Into the section, not onto the file: WLA files carry more sections after
    # [labels], so appending at the end would file the labels under whichever
    # section happens to be last.
    end = len(lines)
    in_labels = False
    for i, raw in enumerate(lines):
        line = raw.strip()
        if line.startswith("["):
            if in_labels:
                end = i
                break
            in_labels = line.lower() == "[labels]"
    if not in_labels and end == len(lines):
        raise ValueError(f"{main_sym} has no [labels] section to merge into")

    merged = [
        *lines[:end],
        f"; {provenance} -- {PACK_MARKER}",
        *(
            f"{s.addr >> 16:02X}:{s.addr & 0xFFFF:04X} {s.name}"
            for s in sorted(added, key=lambda s: s.addr)
        ),
        *lines[end:],
    ]
    main_sym.write_text("\n".join(merged), encoding="latin-1", newline="\n")


def stale_sources(
    sym_path: Path | str,
    relatives: Iterable[str] | None = None,
    root: Path | None = None,
) -> list[str]:
    """Source files edited since ``sym_path`` was written, relative to ``src/``.

    A symbol file is a snapshot of one assemble, and everything read out of it is
    only true of the tree that produced it. Nothing about a stale one *looks*
    stale: it parses, resolves every name, and answers -- with addresses from
    before the edit, and no indication that is what they are. That is the failure
    this exists to make impossible, and it is worth a walk of the tree to catch.

    ``relatives`` restricts the comparison to named files, which is what a caller
    that knows exactly which files its answer depends on should pass. The default
    is every ``.asm`` in the tree, for callers whose answers could move with any
    of them.

    ``root`` is the source tree the paths are relative to, defaulting to the
    default base's. A base that assembles a different tree has to name it, or
    the walk reports on files its symbol file was never built from.

    A missing symbol file is not stale -- it is absent, which is a different
    problem with a different fix, and left to the caller to notice.
    """
    sym = Path(sym_path)
    try:
        cut = sym.stat().st_mtime
    except OSError:
        return []

    src = root if root is not None else _default_root()
    if relatives is None:
        relatives = (
            str(p.relative_to(src)).replace("\\", "/") for p in src.rglob("*.asm")
        )

    out: list[str] = []
    for rel in relatives:
        try:
            if (src / rel).stat().st_mtime > cut:
                out.append(rel)
        except OSError:
            # A file the symbol file names but that is no longer there. The build
            # is what should report that, in the language of the assembler.
            continue
    return sorted(out)


def format_bank_addr(addr: int) -> str:
    """``$05:D000``. :func:`smw_tools.address_index.format_addr` writes the
    other spelling, ``$05D000``, and the two are named apart so an import from
    the wrong module cannot quietly change what a tool prints."""
    return f"${addr >> 16:02X}:{addr & 0xFFFF:04X}"


def containing[T](ordered: Sequence[T], addr: int, key: Callable[[T], int]) -> T | None:
    """The last entry of ``ordered`` at or below ``addr``, or ``None``.

    ``ordered`` must be sorted ascending by ``key``. What an address *belongs
    to*, which is the question an external reference into the middle of a table
    or a routine asks.
    """
    idx = bisect_right(ordered, addr, key=key)
    return ordered[idx - 1] if idx else None


def symbol_containing(table: SymbolTable, addr: int) -> Symbol | None:
    """The symbol at or immediately below ``addr`` -- what an address belongs to."""
    return containing(table.by_addr, addr, lambda s: s.addr)


#: What a build calls a run of ROM it deliberately left empty.
#:
#: Relocating a table moves it out of the placement ``RomMap/`` made for it and
#: leaves that run behind, and **nothing else in the image says so**: the map
#: goes on naming the macro that used to fill it, and a run with nothing in it
#: has no symbol of its own to be found by. So the build labels it -- see
#: ``Config/OverworldTableRelocation.asm`` -- and this is the spelling the two
#: sides agree on, checked by ``smw/tests/test_overworld_table_relocation.py``.
#:
#: A label rather than a declaration beside the feature because *which* runs a
#: build emptied is a property of that build: a cartridge assembled without the
#: relocation emits none of these, and one that gains a second relocation
#: answers with its runs too, for nothing.
VACATED_PREFIX = "SMW_Vacated"


#: The label pairs that bracket a run of ROM a build has **reserved**: set
#: aside behind a RATS tag so asar's freespace search steps over it, including
#: the unused part, which is the room being reserved.
#:
#: Reserved is neither free nor full, and reporting it as either is wrong in a
#: way that costs someone a build: as free, because a patch told to take it
#: would find asar had refused; as full, because the whole point of the tag is
#: that the tables inside may grow into it.
#:
#: A list rather than a rule, because a RATS tag is a shape in the image and
#: not a spelling in a symbol file -- ``%RATSTagStart`` takes whatever pair of
#: labels its caller hands it. One line per reservation, checked the same
#: way, each the pair its Config file's %RATSTagStart names -- and one
#: reservation may be several features' room: the three growable features
#: share the run ``Config/ReservedBank.asm`` brackets, and the custom level
#: palettes and the managed level banks the bank ``Config/LevelBank.asm``
#: does. The managed graphics take several banks, one tag each
#: (``Config/GraphicsBank.asm``), read as one run by the labels at the first
#: bank's head and the last bank's end.
RESERVATIONS: tuple[tuple[str, str], ...] = (
    ("SMW_ReservedBankStart", "SMW_ReservedBankEnd"),
    ("SMW_LevelBankStart", "SMW_LevelBankEnd"),
    ("SMW_GraphicsBankStart", "SMW_GraphicsBankEnd"),
)


#: How long a RATS tag is: ``"STAR"`` and two words, ahead of the label that
#: names what it protects (``%RATSTagStart``). Part of the reserved run rather
#: than something in front of it -- the tag is bytes in the image, and a report
#: that left it out would offer eight bytes nothing can have.
RATS_TAG_SIZE = 8


def reservations(table: SymbolTable) -> tuple[tuple[str, int, int], ...]:
    """Every run this build reserved, as ``(name, start, end)`` in ROM order.

    ``start`` is the tag's own first byte, :data:`RATS_TAG_SIZE` below the
    label, because what is unavailable is the tag and what it protects together.

    A pair only one half of which resolved is left out: the cartridge does not
    have that reservation, which is the ordinary answer for a build with the
    feature that makes it switched off.
    """
    found = []
    for start, end in RESERVATIONS:
        low, high = table.by_name.get(start), table.by_name.get(end)
        if low is not None and high is not None and high.addr > low.addr:
            found.append((start, low.addr - RATS_TAG_SIZE, high.addr))
    return tuple(sorted(found, key=lambda one: one[1]))


def vacated(table: SymbolTable) -> tuple[Symbol, ...]:
    """Every run this build labelled as one it left empty, in ROM order.

    The extent is not here: a label says where a run begins and the ROM map
    says how long the placement it emptied was, so joining the two is the
    caller's -- :func:`shiny_mushroom.memory_map.memory_map` is the one that
    does it.
    """
    return tuple(
        symbol for symbol in table.by_addr if symbol.name.startswith(VACATED_PREFIX)
    )
