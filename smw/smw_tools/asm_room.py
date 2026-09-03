"""How much ROM a fragment has to grow into, off the build's own symbol file.

**A fragment's room comes from a symbol file, not from a literal.** The tables
inside one come out of a single ``incsrc``, back to back, so a table that grows
pushes the ones after it along and the assembler recomputes every address that
follows. What bounds them is the first thing that cannot move -- the next
placement the ROM map made, which is an ``org`` -- or, where nothing follows,
the end of the bank. :func:`room` measures that run off the symbol file of the
build being edited, and a model is priced against the whole of it rather than
against the gap to the next label. Every placement is guarded by an
``assert pc() <=``, so a fragment that outgrows its run is an assembler error
either way; the point of pricing first is to refuse with the region named
instead.

**A label moves when the rows before it do, and that is the mechanism working.**
Nothing pads, so the tables after a grown one shift by exactly what it grew, and
every read of one goes through the build's own symbol file
(:func:`smw_tools.rom_tables.resolved`) rather than through a literal. A table
that has to stay put is one the ROM map places itself, and those are the
boundaries this measures to.
"""

from __future__ import annotations

from bisect import bisect_right
from collections.abc import Mapping
from dataclasses import dataclass
from itertools import islice
from typing import TYPE_CHECKING

from .asm_codec import AsmRegion, AsmRegionError
from .asm_regions import region_for

if TYPE_CHECKING:
    from pathlib import Path

    from .bases import RomBase
    from .symbols import SymbolTable


#: What a fragment says in a tree that is not being written to, by the tree
#: and the region as it was read for.
_TREE_TEXTS: dict[tuple[Path, AsmRegion], str] = {}


def tree_text(region: AsmRegion, tree: Path) -> str:
    """``region``'s fragment as ``tree`` holds it -- every one of its
    :attr:`~AsmRegion.files`, joined in ROM order, which is the text
    :meth:`~AsmRegion.parse` reads.

    **For a base tree, which does not move under a build.** Remembered on
    that assumption, and on nothing else: no ``stat`` checks it, because on
    the filesystem this is measured for a ``stat`` costs 3.2 ms against a
    read's 4.5 and checking would eat most of the win. A caller reading a
    tree something *is* writing to -- a project's overlay -- must not come
    here; :meth:`shiny_mushroom.project.Project._region_text` is that side's
    reading, and it is invalidated by the writes it can see.

    Worth remembering because a fragment is read far more often than once:
    pricing one member of a pool reads every other member, the editor asks
    the disassembly's own rows to decide whether a save is an edit at all,
    and a listing does both for all twenty-one regions.
    """
    key = (tree, region)
    held = _TREE_TEXTS.get(key)
    if held is None:
        held = _TREE_TEXTS[key] = region.read(
            lambda path: (tree / path).read_text(encoding="utf-8")
        )
    return held


def fragment_text(base: RomBase, region: AsmRegion) -> str:
    """``region``'s fragment as the base tree holds it -- :func:`tree_text`
    of ``base``'s own game folder."""
    return tree_text(region, base.game_dir)


@dataclass(frozen=True)
class Run:
    """A run of ROM, and every fragment that has to fit in it.

    One fragment on a stock cartridge, where the ROM map bounds each of them
    itself. Several where a base declares a :class:`~smw_tools.bases.TablePool`
    -- fragments emitted one after another with nothing placed between, so one
    that grows pushes the rest and only the total is bounded.
    """

    #: How many bytes the run holds.
    size: int

    #: The regions sharing it, by id, in the order they are laid out.
    members: tuple[str, ...]

    #: Bytes of it that no member's **emitted** sections occupy and that are
    #: not slack -- see :attr:`~smw_tools.bases.TablePool.reserved`. A member
    #: is :meth:`AsmRegion.fits` bytes of the run and nothing else, so what
    #: :func:`bounds` stops a member at is where this begins.
    reserved: int = 0

    def spare(self, used: Mapping[str, int]) -> int:
        """What is left of the run once every member's rows are in it.

        ``used`` is bytes per region id -- what each one's rows occupy now, or
        would after a save. Negative means the run is over-full by that much.
        """
        return (
            self.size
            - self.reserved
            - sum(used.get(member, 0) for member in self.members)
        )


def bounds(region: AsmRegion, symbols: SymbolTable, base: RomBase) -> tuple[int, int]:
    """Where ``region``'s fragment starts and where the first thing that is
    not its own begins.

    The fragment begins at its first emitted table and ends at the first
    symbol above it that is none of its **emitted** sections' -- for a region
    in no pool the next placement the ROM map made, which is an ``org`` and
    cannot be pushed, and so the whole of its run; for a pooled one whatever
    the assembler's cursor put next, a sibling fragment or the pool's end.
    Where nothing follows in the bank, the bank's own end is the boundary.

    **Emitted sections only, which is the one meaning of "own" everywhere.** A
    section a fragment carries but does not write -- the Layer 2 divider
    table, derived and placed directly after the entries -- bounds the
    fragment like any other label, so it is :attr:`Run.reserved` bytes in a
    pool rather than the fragment's: :meth:`AsmRegion.fits` prices the
    fragment at the same emitted sections, and the editor's memory map draws
    it to this edge, so the divider is counted once, by the pool, and never by
    a member as well.
    """
    starts = []
    for role in region.emitted_sections:
        label = base.table(role).label
        found = symbols.by_name.get(label)
        if found is None:
            raise AsmRegionError(f"{label} is not in the symbol file")
        starts.append(found.addr)
    first, own = min(starts), set(starts)
    end = (first & 0xFF0000) + 0x10000
    # `by_addr` is sorted, so the first symbol above the fragment is a few
    # steps from where `first` falls rather than a walk of the whole file --
    # which this is asked for once per member of a pool.
    at = bisect_right(symbols.by_addr, first, key=lambda symbol: symbol.addr)
    for symbol in islice(symbols.by_addr, at, None):
        if symbol.addr >= end:
            break
        if symbol.addr not in own:
            return first, symbol.addr
    # A bank with nothing above the fragment is the whole point of relocating
    # one: the run is everything left in it.
    return first, end


def run_for(region: AsmRegion, symbols: SymbolTable, base: RomBase) -> Run:
    """The run ``region`` has to fit in, and who else is in it.

    **Not the gap to the next label.** A fragment's tables are emitted back to
    back out of one ``incsrc``, and where a base pools several fragments they
    are emitted back to back too, so what a fragment can grow into is bounded by
    the first thing that *cannot* move -- a placement the ROM map made -- and
    shared with everything movable in between.

    Read from a symbol file rather than declared, because a build is the record
    of where its own placements landed. The build the symbols describe must be
    the build being priced -- the caller owns that freshness, the same way
    ``test_rom_tables`` does.
    """
    for pool in base.pools:
        if region.id not in pool.regions:
            continue
        edges = []
        for label in (pool.start_label, pool.end_label):
            found = symbols.by_name.get(label)
            if found is None:
                raise AsmRegionError(
                    f"{label} bounds a pool and is not in the symbol file"
                )
            edges.append(found.addr)
        start, end = edges
        placed = {
            member: bounds(region_for(member, base), symbols, base)[0]
            for member in pool.regions
        }
        return Run(
            size=end - start,
            members=tuple(sorted(pool.regions, key=lambda m: placed[m])),
            reserved=pool.reserved,
        )
    start, end = bounds(region, symbols, base)
    return Run(size=end - start, members=(region.id,))


def room(region: AsmRegion, symbols: SymbolTable, base: RomBase) -> int:
    """How many bytes ``region``'s fragment may occupy on its own.

    Its run, less whatever the *other* members of that run occupy -- so a
    fragment in no pool gets the whole of its run, which is what a stock
    cartridge gives every one of them.

    The other members are counted at ``base``'s own rows, which is the answer
    for the cartridge as the disassembly has it. A caller holding edited rows --
    an editor project -- wants them counted at *those*, and
    ``shiny_mushroom.build.asm_room`` is the reading that does; a caller pricing
    a save wants :meth:`Run.spare` over the whole set it is writing.
    """
    run = run_for(region, symbols, base)
    if len(run.members) == 1 and not run.reserved:
        return run.size
    others = {
        member: _shipped_size(member, base)
        for member in run.members
        if member != region.id
    }
    # Through `spare` rather than by subtraction, so what the run reserves for
    # something that is nobody's fragment is taken off here too.
    return run.spare(others)


#: What a fragment's shipped rows occupy, by the tree it was read from and the
#: region as that tree's base has it.
_SHIPPED_SIZES: dict[tuple[Path, AsmRegion], int] = {}


def _shipped_size(member: str, base: RomBase) -> int:
    """What ``member``'s rows occupy on ``base``, as the base tree holds them.

    Remembered, on :func:`tree_text`'s assumption and for its reason: what
    the answer turns on is the tree and the region's shape, neither of which
    moves under a running build. The read is remembered there and the parse
    here, so pricing one member of a ten-fragment pool costs neither nine
    reads nor nine parses. A caller holding *edited* rows prices those itself
    (``shiny_mushroom.build.asm_room``) rather than asking here.
    """
    region = region_for(member, base)
    key = (base.game_dir, region)
    held = _SHIPPED_SIZES.get(key)
    if held is None:
        rows = region.parse(fragment_text(base, region), base)
        held = _SHIPPED_SIZES[key] = region.fits(rows, None)
    return held
