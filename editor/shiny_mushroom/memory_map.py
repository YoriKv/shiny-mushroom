"""What is in the project's cartridge, bank by bank, and what room is left.

The question this answers is the one every "region full" refusal raises and
none of them can answer on its own: *where would another hundred bytes go?*
A save is priced against one run of ROM and says so
(:class:`~smw_tools.asm_codec.AsmRegionFull`,
:class:`~shiny_mushroom.project_levels.LevelRegionFull`), which tells you that this
table is full without telling you that the bank it sits in has 1,499 bytes of
padding four placements along, or that the cartridge was expanded and bank
``$11`` is 32 KB of nothing.

**Three sources, and each is the only one that can answer its part.**

``RomMap/`` -- through :mod:`smw_tools.rom_map` -- is the skeleton. It places
every macro at a literal address and tiles the image exactly, so it says both
where the editable things sit and, just as usefully, what sits between them.
Cartridge padding is a placement in it like any other, which is what makes free
space something this can point at rather than something it has to go looking
for in the built bytes.

The **symbol file** is where the editable tables actually landed. Their
placements are inside larger routine macros -- ``level-names.asm`` is an
``incsrc`` in the middle of ``SMW_LevelNames`` -- so the map alone cannot cut a
table out of the routine that owns it, and a relocated table
(``docs/smw/table-relocation.md``) is not where the map says at all. Reading
the build's own record covers both without a special case for either.

The **project** is what those runs hold *now*: a level whose objects grew,
a table whose rows were added to. Room comes from the build, usage from the
overlay, and the two together are the only pair that says whether a save will
fit.

Qt-free, like everything outside :mod:`shiny_mushroom.ui`: this produces
numbers and names, and painting them is the dialog's job.

A **relocation** is the one place those three would disagree, and the build
settles it. Moving a table out of the placement ``RomMap/`` made for it leaves
that run empty, and the map goes on naming the macro that used to fill it -- so
the build labels the run instead (:data:`smw_tools.symbols.VACATED_PREFIX`) and
this reads the label, taking the extent from the map's own line. Room a feature
freed is then room the view offers, which is the whole reason to have freed it.

**What it does not show.** Only what the editor edits is named -- level data,
the editable asm tables, the graphics runs, and padding. Everything else the
cartridge is made of is one undifferentiated :data:`OTHER`, because naming a
hundred routines per bank would bury the few things a reader came for.

On a **patched base** the layout drawn is still the one the patch was applied
to. The symbol file carries the patch's own labels now -- its pass emits them
and the build merges them in behind a marker -- and the banks those labels
fall in are drawn as the patch's, whole (:func:`_pack_banks`). The fragment
prices stay right either way: the patch edits bytes in place and never moves
a label.
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass

from shiny_mushroom.build import built_symbols
from shiny_mushroom.project import Project
from smw_tools import asm_codec, asm_regions, asm_room, rom_map
from smw_tools.bases import RomBase
from smw_tools.graphics_memory import RUN0, STOCK_FILES
from smw_tools.levels import MANAGED_RUNS, LevelRegion, has_level_bank, level_regions
from smw_tools.rom_image import snes_to_pc
from smw_tools.symbols import SymbolTable, reservations, vacated

#: A run of ROM holding one or more level streams -- one bank macro's worth,
#: which is the unit that has a size limit (:class:`smw_tools.levels.LevelRegion`).
LEVEL_DATA = "level"

#: One editable asm fragment: the tables of one
#: :class:`~smw_tools.asm_codec.AsmRegion`, back to back.
DATA_TABLE = "table"

#: A run of compressed graphics files, packed end to end and priced against
#: what the next thing along leaves them. On a stock cartridge that is the one
#: run banks ``$08``-``$0B`` are, the 52 files against the fill that closes
#: them; where the graphics are managed
#: (``docs/smw/managed-graphics-memory.md``) it is that same run and one more
#: per graphics bank, the added files among the stock ones.
GRAPHICS = "graphics"

#: Cartridge padding, or a bank an expanded cartridge added above the game.
FREE = "free"

#: Everything else the cartridge is made of. Named by the macro that owns the
#: run, so hovering says what is in the way, but not coloured apart.
OTHER = "other"


@dataclass(frozen=True)
class Segment:
    """One run of ROM, and what the editor can say about it."""

    kind: str
    #: What to call it -- a region id for something editable, the ROM map's
    #: own macro name for everything else.
    name: str
    #: Its 24-bit SNES address.
    start: int
    #: How many bytes it runs for. A segment never crosses a bank: one that
    #: would is split, so a bank's segments always add up to the bank.
    size: int
    #: What the project's own data needs of it, where that is knowable, and
    #: ``None`` where it is not -- an unpriced table, or a run the editor does
    #: not own.
    used: int | None = None
    #: A note for the reader: which levels are in a region, why a table is not
    #: priced.
    detail: str = ""

    @property
    def end(self) -> int:
        """One past its last byte, in the image."""
        return snes_to_pc(self.start) + self.size

    @property
    def spare(self) -> int | None:
        """Bytes a save could still add to it, or ``None`` when unpriced.

        Negative is a real state and not an error: an overlay may hold rows
        that the next build will refuse, and that is exactly the moment this
        view is worth opening.
        """
        return None if self.used is None else self.size - self.used

    @property
    def editable(self) -> bool:
        return self.kind in (LEVEL_DATA, DATA_TABLE, GRAPHICS)


@dataclass(frozen=True)
class Bank:
    """One LoROM bank, and everything the map and the build put in it."""

    number: int
    segments: tuple[Segment, ...]

    @property
    def start(self) -> int:
        """The bank's first SNES address."""
        return rom_map.bank_start(self.number)

    @property
    def size(self) -> int:
        return rom_map.BANK_SIZE

    @property
    def label(self) -> str:
        return rom_map.bank_label(self.number)

    @property
    def free(self) -> int:
        """Padding, plus what the editable runs in it have still to spare.

        Both, because both are room -- the first for anything, the second for
        the thing that already owns it -- and a reader deciding where a table
        could grow needs the pair rather than either.
        """
        return sum(
            one.size if one.kind == FREE else max(one.spare or 0, 0)
            for one in self.segments
        )

    @property
    def padding(self) -> int:
        """Just the padding: room nothing has a claim on."""
        return sum(one.size for one in self.segments if one.kind == FREE)

    @property
    def editable(self) -> tuple[Segment, ...]:
        return tuple(one for one in self.segments if one.editable)


@dataclass(frozen=True)
class MemoryMap:
    """Every bank of one project's cartridge, lowest first."""

    banks: tuple[Bank, ...]

    #: Whether the editable tables could be priced -- which needs the symbol
    #: file the project's own build writes. Without it the level regions and
    #: the padding are still exact, and the tables are absent rather than
    #: guessed at, so the view says so instead of showing a wrong picture.
    priced: bool

    #: How long the cartridge is, in bytes. Longer than the game whenever the
    #: project has been expanded, and the difference is the free banks on top.
    size: int

    #: How much of it is drawn. Short of :attr:`size` only on a cartridge past
    #: what LoROM can address (:data:`smw_tools.rom_map.ADDRESSABLE_BYTES`) --
    #: ``sa1`` at 6 MB or 8 MB, where the mapping is SA-1 Pack's own and this
    #: has no addresses to give. Said rather than silently omitted: a view that
    #: quietly stopped at 4 MB would read as a 4 MB cartridge.
    mapped: int

    @property
    def padding(self) -> int:
        return sum(bank.padding for bank in self.banks)

    @property
    def free(self) -> int:
        return sum(bank.free for bank in self.banks)

    def bank(self, number: int) -> Bank | None:
        return next((one for one in self.banks if one.number == number), None)


@dataclass(frozen=True)
class LevelBudgets:
    """Every run of ROM a project's level data is written into.

    What the memory map says about the level runs alone, for a reader working
    through the levels rather than the cartridge. Read on its own because it
    needs no symbol file: the runs are the ROM map's own placements and the
    pricing is the project's, so this is exact on a project that has never
    been built.
    """

    #: The runs, in ROM order.
    runs: tuple[Segment, ...]

    #: Whether the managed level banks are packing them -- the Growable
    #: levels feature. With it on the runs are the packer's, and a stream
    #: that grows takes its room from whatever the others leave; without it
    #: they are the bank macros the ROM map places, each packed to the byte
    #: on its own.
    packed: bool

    @property
    def size(self) -> int:
        return sum(one.size for one in self.runs)

    @property
    def used(self) -> int:
        return sum(one.used or 0 for one in self.runs)

    @property
    def spare(self) -> int:
        """What a save could still add, over all the runs at once -- negative
        where the streams already outrun them."""
        return self.size - self.used


def level_budgets(project: Project) -> LevelBudgets:
    """Where ``project``'s level data lives, and how full each run of it is
    -- the runs the ROM map places, and the packer's run in the level bank
    where the level memory is expanded."""
    packed = _packed_runs(project)
    runs = [one for one in _placed(project, packed) if one.kind == LEVEL_DATA]
    runs.extend(_level_bank_run(project, packed))
    return LevelBudgets(runs=tuple(runs), packed=project.level_memory_managed)


def memory_map(project: Project, symbols: SymbolTable | None = None) -> MemoryMap:
    """Lay out ``project``'s cartridge.

    ``symbols`` is the project's own build's symbol table, for a caller holding
    one already -- the window does, since it reads one for every level it opens.
    Left out, it is loaded here, and a project with no build is laid out without
    the editable tables rather than refused: the banks, the level data and the
    padding are all still true, and a project that has never been built is an
    ordinary state rather than a fault.
    """
    if symbols is None:
        symbols = _symbols(project)

    packed = _packed_runs(project)
    graphics = _graphics_runs(project)
    run0 = graphics[RUN0.start] if graphics is not None else _stock_graphics(project)
    segments = list(_placed(project, packed, run0))
    segments.extend(_expansion(project))
    over: list[Segment] = []
    if symbols is not None:
        # Reservations first, because the tables land *inside* one and have to
        # punch through it -- the other way round, a reservation would paint
        # over the tables it was made for. Then the tables and the runs they
        # left, which are the same move seen from either end.
        # The patch's banks go first, so anything that ever landed inside one
        # punches through it rather than under it.
        over = (
            _pack_banks(project, symbols)
            + _reserved(symbols)
            + _tables(project, symbols)
            + _vacated(project, symbols)
        )
    # The packer's run in the level bank lands inside that bank's reservation
    # the way the tables do, and is drawn with or without a build: it is
    # priced by the packer, not read off a symbol file.
    over += _level_bank_run(project, packed)
    # And the graphics banks' runs, each behind its head, for the same
    # reason and drawn the same way.
    over += _graphics_bank_runs(project, graphics)
    for one in over:
        segments = _punch(segments, one)

    banks = _by_bank(segments, project)
    return MemoryMap(
        banks=banks,
        priced=symbols is not None,
        size=project.rom_size.size,
        mapped=len(banks) * rom_map.BANK_SIZE,
    )


def _symbols(project: Project) -> SymbolTable | None:
    """The project's build's symbols, or ``None`` when it has not built one.

    Read rather than required, and silent about a file that will not parse: a
    memory map is a report, and the half of it that needs no symbols is worth
    showing on its own. Through
    :func:`~shiny_mushroom.build.built_symbols`, which is that reading and
    remembers it -- ninety thousand lines, and every report that prices a
    fragment asks for the same ones.
    """
    return built_symbols(project)


def _placed(
    project: Project,
    packed: dict[int, Segment] | None,
    run0: Segment | None = None,
) -> list[Segment]:
    """The ROM map's own placements, classified.

    The skeleton every other segment is laid over: it covers the game exactly,
    so anything punched into it replaces a run rather than filling a gap.
    ``packed`` is :func:`_packed_runs`' answer for the managed level banks,
    priced once by the caller and drawn here at each run the map places.

    ``run0`` is banks ``$08``-``$0B``, the graphics run every project has --
    the packer's first (:func:`_graphics_runs`) where they are managed,
    :func:`_stock_graphics`' where they are not. Left out, the graphics stay
    the map's own placements: :func:`level_budgets` asks this for the level
    runs alone and has no reason to pay for pricing them.
    """
    regions = {one.name: one for one in level_regions(project.base, project.target)}
    spare = _level_spare(project, regions.values())

    made: list[Segment] = []
    drawn_graphics = False
    for one in rom_map.placements(project.base, project.target):
        # On managed level banks the map's placements inside a run -- the
        # level macros and the padding between them -- are one run of packed
        # streams, drawn once, at the first placement the run holds.
        run = next((run for run in MANAGED_RUNS if run.holds(one.start)), None)
        if packed is not None and run is not None:
            if one.start == run.start:
                made.append(packed[run.start])
            continue
        # Banks $08-$0B are one run of graphics whichever way the project
        # builds them -- the placement and the fill fitted behind it are the
        # files and the room they may grow into, and the packer's first run is
        # the same four banks -- so both are drawn once, at the first
        # placement inside the run.
        if run0 is not None and RUN0.holds(one.start):
            if not drawn_graphics:
                made.append(run0)
                drawn_graphics = True
            continue
        if one.padding:
            # A padding macro is usually nothing but its fill, and now and then
            # carries a few bytes of shipped garbage in front of it. Those bytes
            # are in the cartridge and are not room, so they stay with the game.
            if one.free < one.size:
                made.append(
                    Segment(
                        kind=OTHER,
                        name=one.macro,
                        start=one.start,
                        size=one.size - one.free,
                        detail="bytes the cartridge ships, in front of its padding",
                    )
                )
            if one.free:
                made.append(
                    Segment(
                        kind=FREE,
                        name=one.macro,
                        start=rom_map.address_of(one.free_start),
                        size=one.free,
                        used=0,
                        detail="cartridge padding",
                    )
                )
            continue
        region = regions.get(one.macro)
        if region is not None:
            made.append(_level_segment(one, region, spare[region.name]))
            continue
        made.append(Segment(kind=OTHER, name=one.macro, start=one.start, size=one.size))
    return made


def _level_segment(
    placed: rom_map.Placement, region: LevelRegion, spare: int
) -> Segment:
    """One bank macro's worth of level data, priced against the overlay."""
    streams = len(region.insertions)
    return Segment(
        kind=LEVEL_DATA,
        name=region.name,
        start=placed.start,
        size=placed.size,
        used=placed.size - spare,
        detail=f"{streams} level stream{'s' if streams != 1 else ''}",
    )


def _packed_runs(project: Project) -> dict[int, Segment] | None:
    """The managed level banks' runs as segments, by start address, or
    ``None`` on a project whose level banks are stock.

    Priced by :meth:`~shiny_mushroom.project.Project.level_packing`, the
    packer's own arithmetic over the project's streams: what each run holds
    is where the packing left it, and what the banks could not hold at all
    is charged to the last run, which is where the next save is refused.

    Three runs in the stock banks, and a fourth in the level bank where the
    cartridge has one -- :meth:`~shiny_mushroom.project.Project.level_runs`
    -- which the ROM map places nothing at: :func:`_level_bank_run` is what
    draws that one, over the reservation it sits in.
    """
    if not project.level_memory_managed:
        return None
    packing = project.level_packing()
    runs = project.level_runs()
    streams = [0] * len(runs)
    for placed in packing.placed:
        streams[next(i for i, run in enumerate(runs) if run.holds(placed.address))] += 1
    out = {}
    for index, run in enumerate(runs):
        used = packing.used[index] if index < len(packing.used) else 0
        if index == len(runs) - 1:
            used += packing.over
        where = "the level bank" if index >= len(MANAGED_RUNS) else "packed"
        out[run.start] = Segment(
            kind=LEVEL_DATA,
            name=f"managed level run {index}",
            start=run.start,
            size=max(run.size, 0),
            used=used,
            detail=(
                f"{streams[index]} level stream{'s' if streams[index] != 1 else ''}, "
                f"{where} end to end"
            ),
        )
    return out


def _level_bank_run(
    project: Project, packed: dict[int, Segment] | None
) -> list[Segment]:
    """The packer's run in the level bank, for a project whose level banks
    are managed: the one run the ROM map does not place, so it is laid over
    the bank's reservation here rather than found among the placements.

    Behind the palettes' blobs and up to the bank's end label, sized by the
    same arithmetic a save is refused by -- ``packed`` is
    :func:`_packed_runs`' answer, priced once for every run. Nothing on a
    project whose level banks are stock, and nothing on one whose cartridge
    has no expansion bank for the packing to overflow into: there the last
    run is bank ``$07``'s, which the ROM map places and ``packed`` has
    already drawn.
    """
    if packed is None or not has_level_bank(project.next_base):
        return []
    run = project.level_runs()[-1]
    if run.size <= 0:
        return []
    return [packed[run.start]]


def _graphics_runs(project: Project) -> dict[int, Segment] | None:
    """The managed graphics banks' runs as segments, by start address, or
    ``None`` on a project whose graphics are stock.

    Priced by :meth:`~shiny_mushroom.project.Project.graphics_packing`, the
    packer's own arithmetic over every file the build inserts: what each run
    holds is where the packing left it, and what the banks could not hold at
    all is charged to the last run, which is where the next save is refused.

    Run 0 is the stock four banks whole, which the ROM map places and
    :func:`_placed` draws; the rest are one per graphics bank, behind the
    bank's head, which the map places nothing at -- :func:`_graphics_bank_runs`
    lays those over the banks' reservations.
    """
    if not project.graphics_managed:
        return None
    packing = project.graphics_packing()
    files = [0] * len(packing.runs)
    for placed in packing.placed.values():
        files[placed.run] += 1
    out = {}
    last = len(packing.runs) - 1
    for index, run in enumerate(packing.runs):
        used = packing.used[index] + (packing.over if index == last else 0)
        where = "the stock banks" if index == 0 else "a graphics bank"
        out[run.start] = Segment(
            kind=GRAPHICS,
            name=f"managed graphics run {index}",
            start=run.start,
            size=run.size,
            used=used,
            detail=(
                f"{files[index]} graphics file{'s' if files[index] != 1 else ''}, "
                f"packed end to end in {where}"
            ),
        )
    return out


def _stock_graphics(project: Project) -> Segment:
    """Banks ``$08``-``$0B`` as a stock cartridge holds them: the 52
    compressed graphics files, and the fill the ROM map closes the run with.

    One segment over both, because the fill is fitted
    (:func:`smw_tools.packed.fitted_tail`) -- it takes whatever is left of the
    run rather than a place in it, so the files may grow into it with no map
    edit, and those bytes are the graphics' slack rather than the bank's
    padding. Which makes this the same four banks, at the same addresses, that
    the packer's run 0 is on a project whose graphics are managed: the picture
    changes from one run to several when the feature goes on, and not from
    nothing to something.

    Priced by :meth:`~shiny_mushroom.project.Project.region_usage`, exactly as
    a save of a graphics file is, so what the view offers is what the next save
    will accept -- and at the same cost, one `stat` per file, which is a
    report's to pay.
    """
    used, _budget = project.region_usage(project.graphics_region)
    return Segment(
        kind=GRAPHICS,
        name=project.graphics_region,
        start=RUN0.start,
        size=RUN0.size,
        used=used,
        detail=f"{STOCK_FILES} graphics files, packed against the fill behind them",
    )


def _graphics_bank_runs(
    project: Project, graphics: dict[int, Segment] | None
) -> list[Segment]:
    """Each graphics bank as the map does not place it: its head, and the
    packer's run behind it -- ``graphics`` is :func:`_graphics_runs`' answer.

    The first bank's head is the loader's: the RATS tag, the pointer and
    format tables and the two stubs, at fixed offsets
    (``docs/smw/managed-graphics-memory.md``); every later bank's is its tag
    alone. Neither is room, so both are drawn as :data:`OTHER` -- over the
    bank's reservation on a built project, over the expansion bank's free
    space on one that has not built yet, which without this would offer the
    head as room. Nothing on a project whose graphics are stock.
    """
    if graphics is None:
        return []
    made: list[Segment] = []
    for index, (start, run) in enumerate(sorted(graphics.items())[1:], start=1):
        bank_start = rom_map.bank_start(start >> 16)
        head = start - bank_start
        if head > 0:
            made.append(
                Segment(
                    kind=OTHER,
                    name=f"graphics bank {index} head",
                    start=bank_start,
                    size=head,
                    detail=(
                        "the RATS tag, the pointer and format tables and the "
                        "loader's two stubs"
                        if index == 1
                        else "the bank's RATS tag"
                    ),
                )
            )
        made.append(run)
    return made


def _level_spare(project: Project, regions: Iterable[LevelRegion]) -> dict[str, int]:
    """How many bytes each level region has left, by name.

    Through :meth:`~shiny_mushroom.project.Project.level_room`, which measures
    the overlay's growth rather than the region's contents -- the stock total
    *is* the budget, so what is left is what this project has added, negated.
    Eight regions and eight directory reads, which is what a report can afford
    and a save could not.
    """
    return {region.name: project.level_room(region) for region in regions}


def _tables(project: Project, symbols: SymbolTable) -> list[Segment]:
    """The editable asm fragments, where this build put them.

    A fragment is an ``incsrc`` inside a bigger macro, so the ROM map cannot
    cut one out of the routine that owns it -- and a relocated one is not in
    the bank the map names at all. The symbol file is what says where the
    tables really are, and :func:`_table_extent` how far each of them runs.

    A region this target routes around, or one this build placed nothing for,
    is left out rather than drawn at a guessed address.
    """
    base = project.cartridge_base
    made: list[Segment] = []
    for region_id, region in asm_regions.regions(base).items():
        if not region.applies_to(project.target_id):
            continue
        try:
            start = _table_start(region, base, symbols)
            run = asm_room.run_for(region, symbols, base)
            size = _table_extent(region, base, symbols)
        except (KeyError, asm_codec.AsmRegionError):
            continue
        made.append(
            Segment(
                kind=DATA_TABLE,
                name=region_id,
                start=start,
                size=size,
                used=_table_used(project, region_id, region),
                detail=_table_detail(region, run),
            )
        )
    return made


def _table_start(
    region: asm_codec.AsmRegion, base: RomBase, symbols: SymbolTable
) -> int:
    """Where this build put the front of ``region``'s fragment.

    The lowest of its tables, because a fragment is emitted as one run of them
    and which one comes first is the fragment's business, not the map's.
    """
    return min(
        symbols.by_name[base.table(role).label].addr for role in region.emitted_sections
    )


def _table_extent(
    region: asm_codec.AsmRegion, base: RomBase, symbols: SymbolTable
) -> int:
    """How much ROM this build gave ``region``'s fragment, for drawing.

    :func:`smw_tools.asm_room.bounds`, which is the one rule: from the
    fragment's first emitted table to the first symbol above it that is none
    of its emitted sections'. For a fragment the ROM map bounds itself that is
    its whole run -- the next placement is an ``org`` -- and the slack behind
    its rows draws as room it may grow into.

    **A fragment in a pool gets the same reading**, and it is what makes the
    pool a picture. The members are emitted back to back, so the run's slack
    is not any one of theirs -- it is at the end, past the last of them, and
    any that grows pushes the rest into it. Drawing each of them at the
    *shared* total is what this did first, and overlapping thirty-kilobyte
    slots in a thirty-two kilobyte bank is not a picture: laid over each other
    by :func:`_punch`, three of the overworld's fragments disappeared entirely
    and the survivors were whichever happened to be drawn last. Nor is the
    next member the edge: a shared run holds bytes that are nobody's rows --
    the stubs the relocated strings emit ahead of their tables, the tables the
    assembler derives beside them, the Layer 2 divider table after the entries
    -- and a fragment drawn as far as the next member would take them for its
    own slack. :attr:`~smw_tools.bases.TablePool.reserved` is the pool's total
    of those, and each carries a label, which is where the fragment below it
    stops.

    So the pooled fragments tile what they occupy, whatever lies between two
    of them stays the reservation :func:`_reserved` drew -- in the way, which
    is what it is -- and the last of them carries the slack they share, the
    only symbol above it being the label that ends the pool.
    :func:`_table_detail` is what says that slack is shared.
    """
    start, end = asm_room.bounds(region, symbols, base)
    return end - start


def _table_used(
    project: Project, region_id: str, region: asm_codec.AsmRegion
) -> int | None:
    """How much of its run the project's own rows take up, or ``None``.

    The bytes a save is priced at -- :meth:`~smw_tools.asm_codec.AsmRegion.fits`,
    the fragment's emitted sections -- and nothing else, so that the drawing
    and the pricing count one set of bytes. A section the fragment carries
    but does not write, the Layer 2 divider table, is the pool's
    :attr:`~smw_tools.bases.TablePool.reserved` and is drawn as the
    reservation it sits in, not as this fragment's rows.

    ``None`` for a fragment that has been hand-edited out of the emitter's
    grammar: the rows cannot be counted, and the run of ROM is still worth
    drawing. The reason goes in the segment's detail rather than being lost.
    """
    try:
        return region.fits(project.asm_rows(region_id), None)
    except (asm_codec.AsmRegionError, OSError):
        return None


def _table_detail(region: asm_codec.AsmRegion, run: asm_room.Run) -> str:
    """What the fragment is, and -- where it shares its run -- who with.

    The sharing has to be said: a pooled fragment is drawn at what it occupies
    and the last of them at what it occupies plus everyone's slack, so without
    this the reader would take that slack for one fragment's own.
    """
    tables = len(region.sections)
    made = f"{tables} table{'s' if tables != 1 else ''} in {region.path.name}"
    others = len(run.members) - 1
    if others < 1:
        return made
    return (
        f"{made}; shares a {run.size:,}-byte run with {others} other "
        f"fragment{'s' if others != 1 else ''}"
    )


def _reserved(symbols: SymbolTable) -> list[Segment]:
    """The runs this build set aside behind a RATS tag.

    **Reserved is neither free nor full**, and drawn as :data:`OTHER` because
    that is the closer of the two: asar's freespace search steps over the whole
    reservation, so a patch cannot have it, and it is only room at all for the
    tables it was made for -- each of which punches its own slot out of this
    and shows the slack it has. What is left over is the part of the
    reservation nothing has claimed yet.

    Without this an expanded bank would be drawn free from end to end and the
    slack between two slots would read as room anything could take, which is
    the one answer a reservation exists to prevent.
    """
    return [
        Segment(
            kind=OTHER,
            name=name,
            start=start,
            size=end - start,
            detail="reserved behind a RATS tag for the tables placed in it",
        )
        for name, start, end in reservations(symbols)
    ]


def _vacated(project: Project, symbols: SymbolTable) -> list[Segment]:
    """The runs a relocation emptied, as free space.

    **The label says where and the ROM map says how far.** A vacated run is a
    placement the map still makes and the build no longer fills, so its extent
    is that line's own -- exact, and needing none of the "distance to the next
    symbol" reasoning a fragment's room needs, which would run past the
    placement wherever the next macro does not begin with a label.

    A label on an address the map places nothing at is ignored rather than
    guessed at: it would mean the two files disagree about the layout, and a
    report is the wrong place to find that out.
    """
    placed = {
        one.start: one for one in rom_map.placements(project.base, project.target)
    }
    made: list[Segment] = []
    for symbol in vacated(symbols):
        run = placed.get(symbol.addr)
        if run is None:
            continue
        made.append(
            Segment(
                kind=FREE,
                name=symbol.name,
                start=symbol.addr,
                size=run.size,
                used=0,
                detail=f"left empty by a relocated table, from {run.macro}",
            )
        )
    return made


def _pack_banks(project: Project, symbols: SymbolTable) -> list[Segment]:
    """The expansion banks a patch pass's own code landed in, whole.

    Read from the build rather than declared beside the base: the patch pass
    merges its labels into the symbol file behind a marker
    (:data:`smw_tools.symbols.PACK_MARKER`), so which banks the patch took is
    the same kind of fact as where a relocated table went -- the build's own
    record, and a build against a different patch revision follows by itself.

    Each bank is drawn whole and :data:`OTHER`: the patch's blocks are found
    by asar's freespace search rather than placed, so where they fall within
    the bank is the patch's business and no run of it is anyone else's to
    offer. A project with no build draws no patch bank -- absent rather than
    guessed, like the tables, and the window's no-build line says the picture
    is partial.
    """
    patch = project.cartridge_base.patch
    if patch is None:
        return []
    placed = rom_map.bank_count(project.base, project.target)
    total = _banks(project)
    banks = sorted(
        {
            one.addr >> 16
            for one in symbols.by_addr
            if one.pack and placed <= one.addr >> 16 < total
        }
    )
    return [
        Segment(
            kind=OTHER,
            name=patch.label,
            start=rom_map.bank_start(bank),
            size=rom_map.BANK_SIZE,
            detail=f"{patch.label}'s own code, landed after the source",
        )
        for bank in banks
    ]


def _expansion(project: Project) -> list[Segment]:
    """The banks an expanded cartridge adds above the game.

    Zeroes, and nothing in the tree writes to them
    (``docs/smw/rom-size.md``), so the whole of each is room -- which is the
    point of asking for one. Drawn per bank rather than as one long run,
    because a bank is what a table can be reached in with a data-bank switch
    and a run spanning several would suggest otherwise. A bank a patch pass
    took is not room, and :func:`_pack_banks` is what lays it over these.
    """
    placed = rom_map.bank_count(project.base, project.target)
    total = _banks(project)
    return [
        Segment(
            kind=FREE,
            name=f"bank {rom_map.bank_label(bank)}",
            start=rom_map.bank_start(bank),
            size=rom_map.BANK_SIZE,
            used=0,
            detail="added by expanding the cartridge",
        )
        for bank in range(placed, total)
    ]


def _punch(segments: list[Segment], into: Segment) -> list[Segment]:
    """Lay ``into`` over ``segments``, trimming whatever it covers.

    The skeleton is complete, so an overlay always lands on something: a table
    replaces the middle of the routine macro that ``incsrc``s it, or the front
    of a reserved bank. Anything it half-covers keeps the half it still has,
    and anything it covers whole goes.
    """
    start, end = snes_to_pc(into.start), into.end
    made: list[Segment] = []
    for one in segments:
        low, high = snes_to_pc(one.start), one.end
        if high <= start or low >= end:
            made.append(one)
            continue
        if low < start:
            made.append(_trimmed(one, low, start))
        if high > end:
            made.append(_trimmed(one, end, high))
    made.append(into)
    return sorted(made, key=lambda one: snes_to_pc(one.start))


def _trimmed(segment: Segment, start: int, end: int) -> Segment:
    """What is left of ``segment`` between two offsets.

    The usage goes with it only where nothing was taken away: a fraction of a
    priced run is not priced, and reporting a share of the total as though it
    were measured would be a number nobody could act on.
    """
    whole = snes_to_pc(segment.start) == start and segment.end == end
    return Segment(
        kind=segment.kind,
        name=segment.name,
        start=rom_map.address_of(start),
        size=end - start,
        used=segment.used if whole else None,
        detail=segment.detail,
    )


def _split(segment: Segment, start: int, end: int) -> Segment:
    """One bank's worth of ``segment``, carrying the share of its usage that
    lands in that bank.

    Unlike :func:`_trimmed`, which is cutting a run down and cannot say what
    is left of a number it did not measure, this hands the pieces of a run
    around and every byte is accounted to one of them. A run that crosses a
    bank is a run that is *packed* -- the four banks of graphics are the only
    one the map places -- so its used bytes are at its front, and what a bank
    holds of it is the overlap with them. Which is what puts the spare bytes
    in the bank they are actually in: the graphics' room is all in ``$0B``,
    and a piece that forgot its usage would offer it nowhere.

    The last piece keeps whatever is left over, uncapped, so a run the overlay
    has already outgrown still reports a negative :attr:`~Segment.spare`
    rather than a full last bank.
    """
    used = segment.used
    if used is not None:
        used = max(used - (start - snes_to_pc(segment.start)), 0)
        if end < segment.end:
            used = min(used, end - start)
    return Segment(
        kind=segment.kind,
        name=segment.name,
        start=rom_map.address_of(start),
        size=end - start,
        used=used,
        detail=segment.detail,
    )


def _banks(project: Project) -> int:
    """How many banks of ``project``'s cartridge this can place.

    Every one of them, up to the 4 MB plain LoROM can name. An ``sa1`` project
    at 6 MB or 8 MB is longer than that, and the banks past it are reached
    through SA-1 Pack's own MMC -- a mapping nothing here models, so they are
    left out and :attr:`MemoryMap.mapped` says so.
    """
    length = min(project.rom_size.size, rom_map.ADDRESSABLE_BYTES)
    return length // rom_map.BANK_SIZE


def _by_bank(segments: list[Segment], project: Project) -> tuple[Bank, ...]:
    """Cut the flat layout into banks, splitting anything that crosses one.

    Bank ``$08``'s compressed graphics are a single 128 KB run through four
    banks, and a picture drawn per bank has to show it as four. A segment is
    split rather than filed under the bank it starts in, so every bank's
    segments add up to the bank exactly -- which is what lets the bar be drawn
    without a scale of its own -- and each piece carries its share of the run's
    usage (:func:`_split`), so the room at the end of one lands in the bank
    that has it.
    """
    rows: dict[int, list[Segment]] = {number: [] for number in range(_banks(project))}
    for one in segments:
        offset, end = snes_to_pc(one.start), one.end
        while offset < end:
            number = offset // rom_map.BANK_SIZE
            stop = min(end, (number + 1) * rom_map.BANK_SIZE)
            if number in rows:
                rows[number].append(_split(one, offset, stop))
            offset = stop
    return tuple(
        Bank(number=number, segments=tuple(rows[number])) for number in sorted(rows)
    )
