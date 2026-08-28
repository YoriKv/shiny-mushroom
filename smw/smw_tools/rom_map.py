"""Where the ROM map puts every macro, and how much of what it puts there is
empty.

``RomMap/ROM_Map_SMW_<ROMID>.asm`` is the one statement of the cartridge's
layout: a flat list of ``%MACRO($XXXXXX)`` lines, one per routine or table,
each of them an ``org`` at a literal address that ``%InsertMacroAtXPosition``
guards with a ``warnpc``. **Nothing in the image is unplaced.** The list tiles
the whole 512 KB with no gaps and no overlaps, which is what makes it a memory
map rather than a table of contents -- a placement's run of ROM is the distance
to the next line, and there is no third thing it could be.

Two consumers read it and used to spell it twice:
:mod:`smw_tools.levels`, which needs the run each level-data macro gets, and
the editor's memory map, which needs every run there is. So the grammar lives
here once, and both ask.

**Free space is a placement like any other.** Each run of cartridge padding is
an ``%INLINEDATATABLE_RT<NN>_SMW_EmptySpace`` macro with a place in the map, so
the empty parts of the ROM are as located as the full ones. What the macro
*emits* is a few bytes of shipped garbage now and then, and then
``%SMW_FitOriginalFreespace`` for the rest -- which is why
:attr:`Placement.free` is read out of the macro's own byte-count define rather
than assumed to be the whole run. See ``docs/smw/rom-size.md`` for the other
kind of free space, the zero-filled banks an expanded cartridge adds above the
game.

Sizes are worked out in **file offsets**, not addresses. In LoROM the byte after
``$04:FFFF`` is ``$05:8000``, so subtracting one address from the next would
count the unmapped half of every bank -- 32 KB per bank of room that is not
there. It also gets bank ``$08`` right, where one 128 KB graphics blob runs
through four banks as a single placement.

No build required; this reads the source.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

from .bases import DEFAULT_TARGET, VANILLA, BuildTarget
from .paths import GAME_DIR
from .rom_image import pc_to_snes, snes_to_pc

#: ``%ROUTINE_SMW_WaitForHBlank($008439)`` -- a macro placed at a literal
#: address. The address is what makes it a placement: ``%BANK_START(!BANK_00)``
#: and the settings macros take other arguments and are not one.
PLACEMENT = re.compile(r"^\s*%(\w+)\(\s*\$([0-9A-Fa-f]+)\s*\)")

#: ``macro INLINEDATATABLE_RT00_SMW_EmptySpace(Address)`` -- the definition
#: whose byte count says how much of its run is padding.
_DEFINITION = re.compile(r"^macro\s+(\w+)\(")

#: ``!SMW_UBytes = $0F : !SMW_JBytes = $11 : ...``, all on one line. The same
#: line :mod:`smw_tools.verify_static` checks the fill files against, read here
#: for the release being asked about rather than for all of them.
_SIZES = re.compile(r"!([A-Za-z0-9_]+)Bytes\s*=\s*\$([0-9A-Fa-f]+)")

#: What names a macro as cartridge padding. Every one of them is an
#: ``INLINEDATATABLE``, but it is the suffix that carries the meaning.
EMPTY_SPACE = "_EmptySpace"

#: Where the macros the map places are defined. ``Routines/`` is included for
#: the same reason :mod:`smw_tools.verify_static` includes it: a bank is free
#: to keep a macro's body in a file of its own.
_MACRO_DIRS = ("Banks", "Routines")

#: One LoROM bank's worth of cartridge.
BANK_SIZE = 0x8000

#: How much cartridge plain LoROM can name: banks ``$00``-``$7F`` at
#: ``$8000``-``$FFFF``, which is 4 MB and where the address space stops.
#:
#: A cartridge may be longer -- ``sa1`` builds at 6 MB and 8 MB -- and what
#: reaches past this is SA-1 Pack's own MMC bank switching
#: (``docs/smw/rom-size.md``), which is a mapping this repository does not
#: model. So an offset above it has no address here, and a layout says it
#: could not place those bytes rather than naming them something they are not.
ADDRESSABLE_BYTES = 0x80 * BANK_SIZE


@dataclass(frozen=True)
class Placement:
    """One macro, where the map puts it, and the run of ROM that gives it."""

    #: The macro's name, without the ``%`` -- which is what the map places and
    #: so what names this run in a `warnpc` and in an error.
    macro: str

    #: Its 24-bit SNES address, exactly as the map writes it.
    start: int

    #: How many bytes it has, from here to the next placement. For the last
    #: line in the map that is the rest of its bank, which is the only run
    #: nothing bounds from above.
    size: int

    #: How many of those bytes are cartridge padding, from the macro's own
    #: byte-count define. Zero for everything that is not an
    #: :data:`EMPTY_SPACE` macro, and for one of those it is usually but not
    #: always the whole run -- a few carry shipped garbage in front of the fill.
    free: int = 0

    @property
    def bank(self) -> int:
        """The bank it starts in. A placement may run past the end of one:
        bank ``$08``'s compressed graphics are a single run through four."""
        return self.start >> 16

    @property
    def offset(self) -> int:
        """Where it begins in the headerless image."""
        return snes_to_pc(self.start)

    @property
    def end(self) -> int:
        """One past its last byte, in the image."""
        return self.offset + self.size

    @property
    def padding(self) -> bool:
        """Whether this is a run of cartridge padding rather than of game."""
        return self.macro.endswith(EMPTY_SPACE)

    @property
    def free_start(self) -> int:
        """Where its padding begins, in the image. The fill is emitted last, so
        anything the macro carries of its own sits in front of it."""
        return self.end - self.free


def placements(
    root: Path | None = None, target: BuildTarget | None = None
) -> tuple[Placement, ...]:
    """Every macro ``target``'s ROM map places, in ROM order.

    ``root`` is the game folder, so a merged build tree or a project's own can
    be asked the same question as the checkout.

    The releases do not place the same things in the same order -- ``J`` moves
    most of bank ``$04`` along by two bytes and the PAL pair rewrites the front
    of bank ``$05`` -- so a layout is a fact about a target, and there is no
    answer for "the cartridge".
    """
    return placements_for(root or GAME_DIR, _romid(target))


def placements_for(root: Path, romid: str) -> tuple[Placement, ...]:
    """:func:`placements`, for a caller that already holds the framework's own
    name for the release.

    The ROMID is what the map file is named after and what the byte-count
    defines are keyed by, so it is the primitive and :func:`placements` is the
    convenience over it -- rather than a target being reduced to a ROMID and
    resolved back again by everything that has one already.
    """
    return _placements(root, romid)


def free_space(root: Path | None = None, target: BuildTarget | None = None) -> int:
    """How many bytes of ``target``'s cartridge are padding.

    The sum of what the padding macros declare, which is smaller than the sum
    of the runs they sit in: a handful of them carry shipped garbage in front
    of their fill, and those bytes are in the image whether anything reads them
    or not.
    """
    return sum(one.free for one in placements(root, target))


def bank_count(root: Path | None = None, target: BuildTarget | None = None) -> int:
    """How many banks the map reaches into -- the size of the game itself.

    An expanded cartridge is longer than this and the map says nothing about
    the difference, because nothing places anything up there: the banks above
    the game are zeroes, which is exactly what makes them usable.
    """
    placed = placements(root, target)
    if not placed:
        return 0
    return -(-max(one.end for one in placed) // BANK_SIZE)


def _romid(target: BuildTarget | None) -> str:
    """The framework's name for the release being asked about.

    Reduced to the ROMID here rather than held as a target, for the reason
    :func:`smw_tools.levels._romid` does it: that string is the whole of what
    the map file is named after and what the byte-count defines are keyed by,
    and it keeps the cache key below hashable and small.
    """
    return (target or VANILLA.target(DEFAULT_TARGET)).romid


@lru_cache(maxsize=8)
def _placements(root: Path, romid: str) -> tuple[Placement, ...]:
    """Read one release's map, and size every line in it.

    Cached: the memory map asks for all of it at once and
    :mod:`smw_tools.levels` asks again per save, and it is two file reads plus
    a walk of the bank sources.
    """
    path = root / "RomMap" / f"ROM_Map_{romid}.asm"
    if not path.is_file():
        return ()
    lines = [
        (match.group(1), int(match.group(2), 16))
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines()
        if (match := PLACEMENT.match(line))
    ]
    if not lines:
        return ()

    padding = _padding_sizes(root, romid)
    offsets = [snes_to_pc(addr) for _name, addr in lines]
    # The last line has nothing above it, so what bounds it is the end of its
    # own bank -- the `warnpc` `%BANK_END` writes.
    offsets.append(-(-offsets[-1] // BANK_SIZE) * BANK_SIZE)

    made = []
    for index, (name, addr) in enumerate(lines):
        size = offsets[index + 1] - offsets[index]
        # Capped rather than trusted: the define states how much the macro
        # fills, and a fill longer than the run it sits in is an assembly that
        # would not have built. Reporting it as more free space than the
        # cartridge has is the one answer that helps nobody.
        free = min(padding.get(name, 0), size) if name.endswith(EMPTY_SPACE) else 0
        made.append(Placement(macro=name, start=addr, size=size, free=free))
    return tuple(made)


@lru_cache(maxsize=8)
def _padding_sizes(root: Path, romid: str) -> dict[str, int]:
    """Padding macro -> how many bytes of ``romid`` it fills.

    Keyed by the macro's own name rather than by the region number its
    ``%SMW_InsertOriginalFreespace`` call carries. The two agree today, and
    keying by the name is what keeps a renumbered region from being read as a
    different one's size.

    The define sits inside the macro body, so a definition seen without one
    before its ``endmacro`` declares nothing -- which is right for every macro
    that is not padding, and is how they are all skipped without a second
    pattern.
    """
    sizes: dict[str, int] = {}
    for name in _MACRO_DIRS:
        directory = root / name
        if not directory.is_dir():
            continue
        for path in sorted(directory.glob("*.asm")):
            _read_padding(path, romid, sizes)
    return sizes


def _read_padding(path: Path, romid: str, into: dict[str, int]) -> None:
    """Add one file's padding declarations to ``into``."""
    current: str | None = None
    # latin-1 for the reason verify_static reads these the same way: the bank
    # sources carry the framework's own comments, and a stray byte in one is
    # not a reason to be unable to say how big a fill is.
    for line in path.read_text(encoding="latin-1").split("\n"):
        if (found := _DEFINITION.match(line)) is not None:
            current = found.group(1)
        elif line.startswith("endmacro"):
            current = None
        elif current is not None and (declared := dict(_SIZES.findall(line))):
            if romid in declared:
                into[current] = int(declared[romid], 16)
            current = None


def address_of(offset: int) -> int:
    """The SNES address a reader reaches ``offset`` at.

    :func:`smw_tools.rom_image.pc_to_snes` for all but the last two banks of a
    4 MB cartridge, which it spells ``$7E`` and ``$7F`` -- the two banks LoROM
    gives to **work RAM**. Those bytes are cartridge and they exist, but the
    only way to address them is the mirror above ``$80``, so that is what they
    are called here.

    Kept out of ``pc_to_snes`` rather than fixed there: that function is the
    plain arithmetic and a good deal of the tooling round-trips through it, so
    what changes is what a *layout* calls an address rather than what the
    conversion does.

    Past :data:`ADDRESSABLE_BYTES` there is no answer, and ``pc_to_snes``'s --
    which wraps back onto bank ``$00``'s mirror -- is a plausible-looking wrong
    one. Refused instead.
    """
    if not 0 <= offset < ADDRESSABLE_BYTES:
        raise ValueError(
            f"offset {offset:#x} is past what LoROM can address; "
            f"the mapping up there belongs to whatever patch reaches it"
        )
    address = pc_to_snes(offset)
    return address | 0x800000 if (address >> 16) in (0x7E, 0x7F) else address


def bank_label(bank: int) -> str:
    """``$04``, as a bank is spelled everywhere else in this repository.

    ``bank`` counts banks up the image, so the top two of a 4 MB cartridge come
    back as ``$FE`` and ``$FF``: the numbers a reader would have to use, and
    the ones :func:`address_of` gives.
    """
    return f"${address_of(bank * BANK_SIZE) >> 16:02X}"


def bank_start(bank: int) -> int:
    """The first SNES address in ``bank``."""
    return address_of(bank * BANK_SIZE)
