"""Where a base keeps the game's *work RAM*, which is not always work RAM.

:mod:`rom_tables` answers "where is this table in the cartridge". This answers
the other half: **where does this base keep the byte the game calls
``$7E:0100``**. On the vanilla base that is work RAM at offset ``$0100`` and the
question is not worth asking. On a base with a coprocessor it is somewhere else
entirely -- SA-1 moves nearly all of SMW's work RAM into I-RAM and BW-RAM, and a
reader that assumed otherwise would read a byte of the right *number* out of the
wrong memory and report it with a straight face.

## Why the vanilla offset is the name

Every location is named by **its offset from ``$7E0000`` on the vanilla base** --
``$0100`` for the game mode, ``$C800`` for the Map16 tilemap -- and a map turns
that into a real memory and a real offset. The vanilla numbering is the durable
half for the same reason a table's *label* is in :mod:`rom_tables`: it is what
the disassembly's own RAM map calls the byte, it is what an emulator trace of a
mirrored bank yields, and it does not move when a base relocates the memory.

A RAM address appears in no symbol file -- the RAM map is ``!Name #= $address``
**defines** and asar emits **labels** -- so unlike :mod:`rom_tables` there is
nothing to cross-check these against. What there is instead is a cartridge:
``docs/smw/sa1/memory-map.md`` records the measurements that established the
SA-1 rules, taken by loading the same levels on both bases and diffing.

## Spaces rather than emulator memory types

A map answers a :class:`MemorySpace`, not a Mesen ``MemoryType``. The SA-1
memory map is a fact about the cartridge; which integer a particular emulator
build happens to file it under is not, and :mod:`smw_tools` must not know about
the emulator at all -- the dependency arrow points from the editor to here and
never back. ``shiny_mushroom.memtype`` is where a space becomes a type.
"""

from __future__ import annotations

from bisect import bisect_right
from dataclasses import dataclass
from enum import Enum

#: One past the last vanilla work-RAM offset: ``$7E0000``-``$7FFFFF`` is 128 KB.
WORK_RAM_SIZE = 0x20000


class MemorySpace(Enum):
    """A memory a base can keep the game's state in.

    Named for what the hardware calls them rather than for how they are reached,
    because the same bytes have several spellings under SA-1 -- BW-RAM is banks
    ``$40-$4F``, *and* an 8 kB window at ``$6000-$7FFF``, *and* the cartridge's
    save memory. One space, three ways to say it.
    """

    #: The console's own 128 KB, ``$7E0000``-``$7FFFFF``.
    WORK_RAM = "work_ram"

    #: SA-1 I-RAM: 2 KB at ``$3000-$37FF`` from either CPU. Offsets here are
    #: from ``$3000``.
    SA1_IRAM = "sa1_iram"

    #: SA-1 BW-RAM: 128 KB in banks ``$40-$41``. Offsets are from ``$40:0000``,
    #: so ``$41:C800`` is ``$1C800``.
    SA1_BWRAM = "sa1_bwram"


class RamMapError(LookupError):
    """A location this base's RAM map cannot answer for."""


@dataclass(frozen=True)
class RamLocation:
    """One byte, as the memory it is in and the offset within it."""

    space: MemorySpace
    offset: int


@dataclass(frozen=True)
class RamMap:
    """How a base's vanilla work-RAM offsets reach real memories."""

    #: How the arrangement is spelled, for messages.
    id: str

    #: What ``D`` holds while the game runs, and therefore what a routine driven
    #: out of band has to be entered with. Zero on a console; ``$3000`` under
    #: SA-1 Pack, which leaves direct-page accesses unrewritten and moves the
    #: direct page itself into I-RAM instead. Entering a routine with the wrong
    #: one is silent: every ``LDA $19`` in it reads a byte of the right number
    #: out of the wrong memory.
    direct_page: int = 0x0000

    #: How many sprite slots this base's engine has. Twelve on a console; More
    #: Sprites raises it to 22 under SA-1 Pack, and a probe that cleared only
    #: twelve would leave ten slots live to draw over the one it is capturing.
    sprite_slots: int = 12

    def place(self, offset: int) -> RamLocation:
        """Where the byte at vanilla work-RAM ``offset`` actually is."""
        raise NotImplementedError

    def slot(self, table: int, slot: int) -> RamLocation:
        """Where slot ``slot`` of the sprite table based at vanilla ``table`` is.

        Separate from :meth:`place` because a sprite table is the one thing that
        **grows** rather than merely moving: slots 12 to 21 exist on a base with
        More Sprites and have no vanilla offset at all, so there is no number to
        pass to :meth:`place` for them. Asking for a slot this base does not have
        raises, rather than running off the end of the table into its neighbour.

        The bound is checked here for every base and the lookup left to
        :meth:`_slot`, so a base cannot answer for a slot it does not have by
        forgetting to check.
        """
        if not 0 <= slot < self.sprite_slots:
            raise RamMapError(
                f"{self.id} has {self.sprite_slots} sprite slots, so there is no "
                f"slot {slot}"
            )
        return self._slot(table, slot)

    def _slot(self, table: int, slot: int) -> RamLocation:
        """``slot`` of ``table``, the bound already checked.

        The default is the whole of it for a base that did not move the tables:
        one byte per slot, so the slot is an offset from the table.
        """
        return self.place(table + slot)

    def space_at(self, address: int) -> MemorySpace | None:
        """Which memory a CPU address reaches, or ``None`` for one this map does
        not answer for.

        The counterpart to :meth:`place` for a caller working in *addresses*
        rather than entries: the memory map resolves to numbers, and a number
        alone does not say whether ``$6100`` is unmapped, a hardware register or
        -- on a base that relocated low RAM -- the game's own state. That is the
        question the analysis tools ask of every RAM-map entry once the base has
        decided where it landed.

        ``None`` is an answer and not a failure: it means the address is not RAM
        this base keeps game state in, leaving the caller's other rules -- ROM,
        SRAM, the register file -- to speak for it.
        """
        raise NotImplementedError

    def low_ram_offset(self, effective: int) -> int | None:
        """The vanilla low-RAM offset a traced effective address names, if any.

        The inverse of :meth:`place`, for the one job that needs it: a trace row
        reports where an instruction *stored*, and the capture has to decide
        which of the game's own bytes that was. ``None`` for an address that
        names no vanilla low-RAM byte -- which is an answer, not a failure, and
        far better than a plausible number.

        Only low RAM, because that is what a trace is read for here and because
        it is the part every base spells differently. The sprite tables are
        deliberately outside it: their inverse is ambiguous once a base has more
        slots than vanilla had bytes, and nothing asks.
        """
        raise NotImplementedError

    def _boundaries(self) -> tuple[int, ...]:
        """Every offset at which this map's answer changes rule, sorted.

        What :meth:`region`'s interior check walks: between two neighbouring
        boundaries the map is a single rule, so a run with no boundary strictly
        inside it is answered by its endpoints alone. Empty for a map that is
        one rule throughout.
        """
        return ()

    def region(self, offset: int, size: int) -> RamLocation:
        """Where a whole run of ``size`` bytes is, as one location.

        **Raises rather than answering for a run whose bytes are not all
        where its endpoints say.** A caller reading the Map16 tilemap wants
        14 kB in one slice; under a base that had put part of it somewhere
        else, answering with the first part's location would hand back the
        right number of bytes with the wrong ones in them, which is the
        failure this whole module exists to prevent. The endpoints agreeing
        is not enough on its own -- a relocated or refused range strictly
        inside the run leaves them agreeing over bytes that are not theirs,
        which is what the boundary check catches. No region the editor reads
        is split on any base declared here.
        """
        if size <= 0:
            raise RamMapError(f"a region is at least one byte, not {size}")
        start = self.place(offset)
        end = self.place(offset + size - 1)
        if end.space is not start.space or end.offset - start.offset != size - 1:
            raise RamMapError(
                f"{self.id}: ${offset:05X}+{size} is not one run -- it starts in "
                f"{start.space.value} at ${start.offset:05X} and ends in "
                f"{end.space.value} at ${end.offset:05X}"
            )
        bounds = self._boundaries()
        inside = bisect_right(bounds, offset)
        if inside < len(bounds) and bounds[inside] < offset + size:
            raise RamMapError(
                f"{self.id}: ${offset:05X}+{size} is not one run -- the map's "
                f"answer changes at ${bounds[inside]:05X}, inside it"
            )
        return start


#: ``$0000``-``$1FFF`` of banks ``$00``-``$3F`` is the same memory as
#: ``$7E0000``-``$7E1FFF``, so a store into it is traced under whichever data
#: bank the code held -- measured, ``$01``, ``$02`` and ``$03``, never ``$7E``.
LOW_RAM_END = 0x2000

#: The direct page, which is the first page of low RAM and the one part of it
#: SA-1 Pack moves somewhere other than the BW-RAM window.
LOW_RAM_PAGE = 0x100


def _work_ram_at(address: int) -> MemorySpace | None:
    """Whether a CPU address reaches the console's own memory.

    The rule every base shares, because work RAM is the console's and no
    cartridge moves it -- what a base with a coprocessor changes is how much of
    the game is still *in* it.
    """
    bank, low = address >> 16, address & 0xFFFF
    if bank in (0x7E, 0x7F):
        return MemorySpace.WORK_RAM
    # The low 8 kB is mirrored into the first quarter of the address space, and
    # again above the bit-7 mirror. That is the spelling the source uses for
    # everything on the direct page.
    if (bank & 0x7F) <= 0x3F and low < LOW_RAM_END:
        return MemorySpace.WORK_RAM
    return None


@dataclass(frozen=True)
class WorkRam(RamMap):
    """The console's own memory, and nothing moved: the identity map."""

    id: str = "work RAM"

    def place(self, offset: int) -> RamLocation:
        if not 0 <= offset < WORK_RAM_SIZE:
            raise RamMapError(f"${offset:05X} is outside work RAM's 128 KB")
        return RamLocation(MemorySpace.WORK_RAM, offset)

    def space_at(self, address: int) -> MemorySpace | None:
        return _work_ram_at(address)

    def low_ram_offset(self, effective: int) -> int | None:
        low = effective & 0xFFFF
        return low if low < LOW_RAM_END else None


#: The ranges SA-1 Pack moves, as ``(first, last, space, destination)`` over
#: vanilla work-RAM offsets. Everything not covered stays in work RAM.
#:
#: Read from ``docs/smw/sa1/memory-map.md``'s eight translation rules and
#: confirmed against a running cartridge. Three of the four BW-RAM ranges keep
#: **the same numeric offset**, because BW-RAM banks ``$40``/``$41`` take over
#: from ``$7E``/``$7F`` at the same addresses -- that is a pleasing accident of
#: the pack's design and not something to rely on, which is why each range says
#: where it goes rather than being written as an identity.
_SA1_RANGES: tuple[tuple[int, int, MemorySpace, int], ...] = (
    # The sprite-loaded flags move *and widen*, 128 entries to 255, and are the
    # only place in the remap where an addressing mode changes. First, because
    # they sit inside the low-RAM range below.
    (0x01938, 0x019B7, MemorySpace.SA1_BWRAM, 0x18A00),
    # SMW's direct page. `D` is set to $3000 at boot, so `LDA $19` still works
    # and only absolute and long accesses were rewritten -- but the *bytes* are
    # in I-RAM either way, which is all a reader cares about.
    (0x00000, 0x000FF, MemorySpace.SA1_IRAM, 0x00000),
    # Low RAM, reached as the BW-RAM window at $6100-$7FFF or as $40:0100 long.
    (0x00100, 0x01FFF, MemorySpace.SA1_BWRAM, 0x00100),
    # Map16 tilemap, low byte then high byte.
    (0x0C800, 0x0FFFF, MemorySpace.SA1_BWRAM, 0x0C800),
    (0x1C800, 0x1FFFF, MemorySpace.SA1_BWRAM, 0x1C800),
    # The wiggler segment buffer, which is the one range that lands somewhere
    # numerically unrelated.
    (0x19A7B, 0x19C7A, MemorySpace.SA1_BWRAM, 0x18800),
)

#: How many vanilla bytes a sprite slot table occupies -- one per slot, twelve
#: slots. The relocated tables are 22 bytes; the vanilla *numbering* is still 12,
#: which is what these ranges are in.
_SLOT_TABLE_SIZE = 12

#: The sprite tables More Sprites relocated, as ``(vanilla base, SA-1 address)``.
#:
#: The general range rules cannot express these and must not be allowed to try:
#: ``$7E:009E`` is on the direct page, so the rule would place it at I-RAM
#: ``$009E`` -- which under More Sprites holds Y speed, a different table whose
#: bytes are the right size and entirely the wrong meaning.
#:
#: **Every entry here was measured on a running cartridge**, not read out of
#: upstream's ``docs/Sprite-Remap.md``, and by independent methods:
#:
#: - the first three from the cartridge's own direct-page pointers. More Sprites
#:   keeps ``$B4``, ``$CC`` and ``$EE`` pointing at the three tables it took off
#:   the direct page, updated as each sprite starts executing, so a booted
#:   machine states their addresses itself.
#: - the rest by driving sprites on both bases and comparing the two
#:   instruction traces **at shared program counters**: the same routine at the
#:   same address reads ``$1540,x`` on vanilla and ``$32C6,x`` here, which pairs
#:   the two spellings without either document being involved. ``$B6`` is the
#:   one entry that pairing cannot see -- its direct-page operand does not
#:   change, only ``D`` under it -- so it is paired through the traced
#:   *effective addresses* of the same instruction at the same address instead.
#:
#: Both agree with upstream everywhere they overlap it, and nothing measured
#: contradicts it. See ``docs/smw/sa1/sprites.md``.
#: A mapping rather than pairs because both readers want it that way: a lookup
#: by table for :meth:`Sa1Ram._slot`, and a walk for :meth:`Sa1Ram.place`.
_SA1_SPRITE_TABLES: dict[int, int] = {
    0x0009E: 0x3200,  # sprite number
    0x000AA: 0x309E,  # Y speed
    0x000B6: 0x30B6,  # X speed
    0x000C2: 0x30D8,  # sprite state
    0x000D8: 0x3216,  # Y position, low
    0x000E4: 0x322C,  # X position, low
    0x014C8: 0x3242,  # status
    0x014D4: 0x3258,  # Y position, high
    0x014E0: 0x326E,  # X position, high
    0x014EC: 0x74C8,
    0x014F8: 0x74DE,  # X position, fraction
    0x01504: 0x74F4,
    0x0151C: 0x3284,
    0x01528: 0x329A,
    0x01534: 0x32B0,  # powerup blink-fall flag
    0x01540: 0x32C6,
    0x0154C: 0x32DC,
    0x01558: 0x32F2,
    0x01564: 0x3308,
    0x01570: 0x331E,
    0x0157C: 0x3334,
    0x01588: 0x334A,  # blocked status
    0x01594: 0x3360,
    0x015A0: 0x3376,
    0x015AC: 0x338C,
    0x015B8: 0x7520,  # slope being stood on
    0x015C4: 0x7536,
    0x015D0: 0x754C,  # on Yoshi's tongue
    0x015DC: 0x7562,  # object-collision disable
    0x015EA: 0x33A2,
    0x015F6: 0x33B8,
    0x01602: 0x33CE,
    0x0160E: 0x33E4,
    0x0161A: 0x7578,
    0x01626: 0x758E,  # consecutive kills
    0x01632: 0x75A4,  # behind-scenery flag
    0x0163E: 0x33FA,
    0x0164A: 0x75BA,  # in liquid
    0x01656: 0x75D0,  # Tweaker byte 1
    0x01662: 0x75EA,  # Tweaker byte 2
    0x0166E: 0x7600,  # Tweaker byte 3
    0x0167A: 0x7616,  # Tweaker byte 4
    0x01686: 0x762C,  # Tweaker byte 5
    0x0186C: 0x7642,
    0x0187B: 0x3410,
    0x0190F: 0x7658,  # Tweaker byte 6
    0x01FD6: 0x766E,  # unused table
    0x01FE2: 0x7FD6,
}

#: The one table upstream says was relocated and nothing here has watched move.
#: **Refused rather than mapped**, on the same grounds the whole set was before
#: any of it was measured: the general rules would answer for it with a
#: neighbouring table's address, silently. No instruction in the game names it
#: -- the init routine deliberately skips it and the code graph shows no reader
#: -- so no driven probe can pair it. The machinery stays because a future base
#: will need it before its own measurements exist.
_SA1_SPRITE_UNCONFIRMED: tuple[int, ...] = (
    0x01510,
)


#: Every offset at which the SA-1 map's answer changes rule, sorted: both ends
#: of each moved range and of each sprite table, measured and refused alike.
_SA1_BOUNDARIES: tuple[int, ...] = tuple(
    sorted(
        {
            edge
            for table in (*_SA1_SPRITE_TABLES, *_SA1_SPRITE_UNCONFIRMED)
            for edge in (table, table + _SLOT_TABLE_SIZE)
        }
        | {
            edge
            for first, last, _, _ in _SA1_RANGES
            for edge in (first, last + 1)
        }
    )
)


#: The two windows an SA-1 address can land in, as seen from either CPU.
#:
#: I-RAM is 2 kB at ``$3000``; the BW-RAM window is 8 kB at ``$6000`` whose page
#: register is left at zero, so ``$74C8`` and ``$40:14C8`` are the same byte.
#: Named because they are the boundaries of both directions of the translation
#: -- :func:`_sa1_address` going out and :meth:`Sa1Ram.low_ram_offset` coming
#: back -- and two spellings of one boundary is how they drift apart.
_IRAM, _IRAM_END = 0x3000, 0x3800
_WINDOW, _WINDOW_END = 0x6000, 0x8000

#: How much of I-RAM is SMW's direct page. Above it is the scratch the two CPUs
#: share and then the sprite tables, which are not a direct translation.
_IRAM_DIRECT_PAGE = 0x100


#: BW-RAM's own banks, which is the only spelling that reaches all 128 kB of it.
#: The window at ``$6000`` sees whichever 8 kB page its register selects, and
#: SA-1 Pack leaves that at zero -- so the window is a second name for the first
#: page and nothing above it has one.
BWRAM_BANK, BWRAM_BANK_END = 0x40, 0x50


def _sa1_address(address: int) -> RamLocation:
    """One SA-1 address, as the memory it is in."""
    if _IRAM <= address < _IRAM_END:
        return RamLocation(MemorySpace.SA1_IRAM, address - _IRAM)
    if _WINDOW <= address < _WINDOW_END:
        return RamLocation(MemorySpace.SA1_BWRAM, address - _WINDOW)
    raise RamMapError(f"${address:04X} is neither I-RAM nor the BW-RAM window")


#: Where each memory begins as the CPU addresses it.
#:
#: I-RAM and BW-RAM are reachable from either processor at these addresses; work
#: RAM only from the S-CPU. Every one of them is the spelling that can name the
#: *whole* memory, which is why BW-RAM is here as its banks and not as its
#: window -- see :func:`window_address`.
_SPACE_ORIGIN: dict[MemorySpace, int] = {
    MemorySpace.WORK_RAM: 0x7E0000,
    MemorySpace.SA1_IRAM: _IRAM,
    MemorySpace.SA1_BWRAM: BWRAM_BANK << 16,
}


def cpu_address(at: RamLocation) -> int:
    """``at`` as an address the CPU reaches it by."""
    return _SPACE_ORIGIN[at.space] + at.offset


def window_address(at: RamLocation) -> int | None:
    """``at``'s second, 16-bit spelling, for the one memory that has one.

    BW-RAM's first 8 kB is also the window at ``$6000``, and that is how the
    disassembly writes SMW's relocated low RAM -- so a caller comparing a source
    address against a measured location has to accept either. ``None`` for
    anything with a single spelling.
    """
    if at.space is MemorySpace.SA1_BWRAM and at.offset < _WINDOW_END - _WINDOW:
        return _WINDOW + at.offset
    return None


@dataclass(frozen=True)
class Sa1Ram(RamMap):
    """SA-1 Pack's remap: most of work RAM in I-RAM and BW-RAM instead.

    The C-CPU cannot reach work RAM at all, so every piece of state a routine
    moved to the second processor had to move first. What is left in work RAM is
    the S-CPU's stack, the interrupt handlers the pack runs from RAM, and
    ``$7E:2000-$7E:C7FF`` -- which is why a Layer 2 background's tilemap is still
    read from the console's own memory on this base.
    """

    id: str = "SA-1"

    #: `D` is set here at boot, so the game's direct-page accesses were left
    #: alone by the remap and reach I-RAM instead of page zero.
    direct_page: int = 0x3000

    #: More Sprites, which is what the relocations below are in aid of.
    sprite_slots: int = 22

    def place(self, offset: int) -> RamLocation:
        if not 0 <= offset < WORK_RAM_SIZE:
            raise RamMapError(f"${offset:05X} is outside work RAM's 128 KB")
        for base in _SA1_SPRITE_UNCONFIRMED:
            if base <= offset < base + _SLOT_TABLE_SIZE:
                raise RamMapError(
                    f"{self.id} relocates the sprite table at ${base:05X} and "
                    f"nothing here has watched it move -- see "
                    f"docs/smw/sa1/sprites.md. ${offset:05X} is refused rather "
                    f"than read out of a neighbouring table."
                )
        for base, address in _SA1_SPRITE_TABLES.items():
            if base <= offset < base + _SLOT_TABLE_SIZE:
                return _sa1_address(address + (offset - base))
        for first, last, space, destination in _SA1_RANGES:
            if first <= offset <= last:
                return RamLocation(space, destination + (offset - first))
        return RamLocation(MemorySpace.WORK_RAM, offset)

    def _boundaries(self) -> tuple[int, ...]:
        return _SA1_BOUNDARIES

    def _slot(self, table: int, slot: int) -> RamLocation:
        """As :meth:`RamMap._slot`, but reaching all 22 of the relocated slots.

        Slots 12 and up have no vanilla offset to add to, so the relocated base
        is looked up first and the slot indexed on *it* -- which is also why
        ``table`` stays a vanilla address here: it is the durable name for a
        table whatever base is answering.

        A table that is not in the relocated set is somewhere the general rules
        answer for and has not grown, so only vanilla's twelve slots exist on
        it -- the base's 22-slot bound was already passed, and adding a larger
        slot to an unmoved table would index into its neighbour.
        """
        address = _SA1_SPRITE_TABLES.get(table)
        if address is None:
            if slot >= _SLOT_TABLE_SIZE:
                raise RamMapError(
                    f"{self.id} did not relocate the table at ${table:05X}, so "
                    f"it has only vanilla's {_SLOT_TABLE_SIZE} slots -- there "
                    f"is no slot {slot}"
                )
            return super()._slot(table, slot)
        return _sa1_address(address + slot)

    def space_at(self, address: int) -> MemorySpace | None:
        bank, low = address >> 16, address & 0xFFFF
        if BWRAM_BANK <= bank < BWRAM_BANK_END:
            return MemorySpace.SA1_BWRAM
        if (bank & 0x7F) <= 0x3F:
            if _IRAM <= low < _IRAM_END:
                return MemorySpace.SA1_IRAM
            if _WINDOW <= low < _WINDOW_END:
                return MemorySpace.SA1_BWRAM
        # What is left over is still the console's: this base moved most of the
        # game's state off work RAM but not all of it, and $7E:2000-$7E:C7FF is
        # read from the same place it always was.
        return _work_ram_at(address)

    def low_ram_offset(self, effective: int) -> int | None:
        if ((effective >> 16) & 0x7F) > 0x3F:
            # Only banks $00-$3F and their $80 mirrors see I-RAM and the
            # window. $40+ is BW-RAM spelled long, and $7E is the console's own
            # memory -- still in use on this base, naming no relocated byte.
            return None
        low = effective & 0xFFFF
        if _IRAM <= low < _IRAM + _IRAM_DIRECT_PAGE:
            # I-RAM holds the direct page here. Above it is the shared scratch
            # and then the sprite tables, which this deliberately does not
            # answer for -- see `RamMap.low_ram_offset`.
            return low - _IRAM
        if _WINDOW + LOW_RAM_PAGE <= low < _WINDOW_END:
            # Twenty of the measured sprite tables live *inside* the window,
            # and their bytes are not the low RAM its arithmetic would name --
            # $74C8 is the relocated table from $14EC, where vanilla's $14C8 is
            # status, in I-RAM. The unmeasured table cannot be excluded the
            # same way: only its vanilla offset is known.
            for home in _SA1_SPRITE_TABLES.values():
                if home <= low < home + self.sprite_slots:
                    return None
            # The rest of the window is where $7E:0100-$7E:1FFF went. Its first
            # page is not part of that move and names no vanilla byte.
            return low - _WINDOW
        # Anything else naming low RAM is the pack's own -- its stack, its
        # interrupt handlers, the code it runs from work RAM -- and corresponds
        # to no vanilla byte.
        return None
