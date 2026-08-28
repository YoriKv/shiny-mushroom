"""The managed graphics banks: the packer's arithmetic, restated for pricing.

Under the ``managed-graphics-memory`` feature (``Config/ManagedGraphicsMemory.asm``)
the 52 compressed graphics files stop being one placement and become a
**sequence**, packed into runs: the stock four banks ``$08``-``$0B`` whole, and
then the *graphics banks* -- ``Config/GraphicsBank.asm``, as many whole
expansion banks as the build asks for -- each from its head to its last byte.
A file that would run past the end of the run being filled is placed at the
start of the next, the packing never goes back, and the files a project adds
are packed after the game's own. Every label follows its file, and the loader
reads a 256-row pointer table at the head of the first graphics bank.

This module carries the packer's rules so a save can be priced where a build
would refuse it, without a build -- :func:`pack` over :func:`runs_for` is
exactly ``%SMW_ManagedGraphicsFit`` -- and the layout the config fixes, which
a test holds against the config's own literals and, build-gated, against a
real assemble: the two head tables' offsets, the stubs' sizes, the runs.

**Nothing here declares where a file is.** They are read where the assembler
put them, through the pointer table and the build's own symbol file; what is
declared is the head, and the arithmetic that says where the rest will land.
"""

from __future__ import annotations

import re
from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from pathlib import Path

from . import graphics
from .bases import RomBase
from .packing import lay_out
from .rom_image import pc_to_snes, snes_to_pc
from .rom_sizes import ROM_SIZES

#: The feature under which the graphics are packed, by id -- the same string
#: :data:`smw_tools.features.MANAGED_GRAPHICS_MEMORY` declares, spelled here
#: so this module's imports stay its own.
FEATURE = "managed-graphics-memory"

#: The asar defines the config guards: the switch, the first graphics bank
#: and how many banks the run takes.
DEFINE = "Define_SMW_ManagedGraphicsMemory"
BANK_DEFINE = "Define_SMW_GraphicsBank"
COUNT_DEFINE = "Define_SMW_GraphicsBankCount"

#: How many banks past a base's reservation bank the first graphics bank is
#: -- the :attr:`~smw_tools.features.Feature.bank_offset` the feature
#: declares, restated so this module can name the bank without importing it;
#: a test holds the two equal. One past the level bank, which is one past the
#: reserved run: ``$12`` on a plain build, ``$13`` on ``sa1``.
BANK_OFFSET = 2

#: How many graphics banks a build takes when nobody has said.
DEFAULT_BANK_COUNT = 1

#: The bank above which the run may not reach: the work RAM mirror ends at
#: ``$3F``, and the loader's stubs run from the first bank.
LAST_USABLE_BANK = 0x3F

#: The file numbers. The game's own are ``$00``-``$33``; a project may add
#: ``$34``-``$FE``. ``$FF`` is the "no file" sentinel the upload cache holds
#: under the feature and never a file. How many the game ships is
#: :data:`smw_tools.graphics.FILE_NUMBERS`' own count, so the two cannot
#: come to disagree about where the added numbers start.
STOCK_FILES = len(graphics.FILE_NUMBERS)
FIRST_ADDED = STOCK_FILES
LAST_ADDED = 0xFE
#: The one number in that range no level can name: Lunar Magic writes ``$7F``
#: into a container's ExGFX slot for "no file" (:mod:`smw_tools.level_graphics`
#: reads it as the tileset's), so a file numbered ``$7F`` could be added and
#: never loaded. Refused up front instead.
UNNAMEABLE = 0x7F
SENTINEL = 0xFF
FILE_ROWS = 0x100

#: The order the stock placement inserts its files, which is the order the
#: packing lays them: the two boot-time files first, then the numbered run.
STOCK_ORDER: tuple[int, ...] = (0x32, 0x33, *range(0x32))

#: The formats the format table speaks. The first two are a slot's worth of
#: tiles -- 128 of them, 3bpp the stock upload path and 4bpp the straight
#: copy the feature adds -- and are what a VRAM slot can load. The other two
#: are the shapes of the game's two boot-time files, which no slot loads:
#: the animated tiles' 384 tiles of 3bpp and the player's 744 of 4bpp. Every
#: size is taken from :mod:`smw_tools.graphics` rather than restated.
FORMAT_3BPP = 0
FORMAT_4BPP = 1
FORMAT_ANIMATED = 2
FORMAT_PLAYER = 3
DECOMPRESSED_SIZES: dict[int, int] = {
    FORMAT_3BPP: graphics.DEFAULT_SIZE,
    FORMAT_4BPP: graphics.SLOT_BYTES,
    FORMAT_ANIMATED: graphics.decompressed_size(graphics.ANIMATED_TILES_FILE),
    FORMAT_PLAYER: graphics.decompressed_size(graphics.PLAYER_FILE),
}

#: The formats a project's own file may declare, which is what the formats
#: fragment carries: 4bpp, and the animated tiles' shape. A 3bpp slot file
#: is every row's default and is left out of the fragment rather than
#: declared, and the player's shape is the game's own file's and nothing a
#: project adds -- ``Config/ManagedGraphicsMemory.asm``'s macro refuses the
#: same two.
DECLARED_FORMATS: tuple[int, ...] = (FORMAT_4BPP, FORMAT_ANIMATED)

#: The formats too large for the decompression buffer, which decompress to
#: the WRAM staging area at ``$7E2000`` instead -- what the pointer stub
#: reads the format byte for besides the upload path, and the rule a caller
#: asking the decompressor for such a file relies on
#: (``Config/ManagedGraphicsMemory.asm``). Spelled as the comparison the
#: stub makes: a format below this is a slot's file.
FIRST_STAGED_FORMAT = FORMAT_ANIMATED

#: The head of the first graphics bank, as offsets from the bank's base,
#: exactly as ``Config/ManagedGraphicsMemory.asm`` and ``Config/GraphicsBank.asm``
#: state them -- a test holds the files to these. The run starts past the
#: RATS tag; the pointer table is ``$100`` long pointers, the format table
#: ``$100`` bytes, then the two stubs, then the streams.
BANK_RUN = 0x8008
POINTERS_OFFSET = BANK_RUN
FORMATS_OFFSET = POINTERS_OFFSET + 3 * FILE_ROWS
STUBS_OFFSET = FORMATS_OFFSET + FILE_ROWS
POINTER_STUB_BYTES = 0x38
UPLOAD_STUB_BYTES = 0x26
STUB_BYTES = POINTER_STUB_BYTES + UPLOAD_STUB_BYTES
HEAD_BYTES = STUBS_OFFSET + STUB_BYTES - BANK_RUN
STREAMS_OFFSET = BANK_RUN + HEAD_BYTES
BANK_END = 0xFFFF

#: The two fragments the editor regenerates, relative to the game folder,
#: and the grammar of their lines.
ADDED_FRAGMENT = Path("graphics/added/added-graphics.asm")
FORMATS_FRAGMENT = Path("graphics/added/formats.asm")
_ADDED_LINE = re.compile(r"^\s*%SMW_AddedGraphics\(\s*GFX([0-9A-F]{2})\s*\)")
_FORMAT_LINE = re.compile(
    r"^\s*%SMW_GraphicsFormat\(\s*GFX([0-9A-F]{2})\s*,\s*(\d+)\s*\)"
)


class GraphicsMemoryError(ValueError):
    """A packing the graphics banks cannot make."""


class GraphicsMemoryFull(GraphicsMemoryError):
    """A file found no run: what the build would refuse at."""

    def __init__(self, number: int, size: int, over: int) -> None:
        self.number = number
        self.size = size
        #: How many bytes found no run, this file and everything after it.
        self.over = over
        super().__init__(
            f"{graphics.name_for(number)} ({size:,} bytes) fits no run of the "
            f"graphics "
            f"banks; {over:,} bytes have nowhere to go"
        )


@dataclass(frozen=True)
class Run:
    """One run of ROM the managed graphics pack files into.

    The first run spans four banks, and a file may straddle a bank boundary
    inside it as the shipped files do -- the decompressor follows the bank
    -- so its addresses are LoROM's, ``$08FFFF`` followed by ``$098000``, and
    its size is counted in the image's bytes rather than as a difference of
    addresses. :func:`advance` is the cursor's step.
    """

    #: Its 24-bit SNES address, and one past its last byte.
    start: int
    end: int

    @property
    def size(self) -> int:
        """How many bytes of the image the run holds."""
        return snes_to_pc(self.end - 1) + 1 - snes_to_pc(self.start)

    @property
    def bank(self) -> int:
        return self.start >> 16

    def holds(self, address: int) -> bool:
        """Whether ``address`` falls inside this run."""
        return self.start <= address < self.end


#: The first run: the stock four banks whole. Literal, exactly as
#: ``Config/ManagedGraphicsMemory.asm`` states it; a test holds the two
#: against each other and against every ROM map.
RUN0 = Run(0x088000, 0x0C0000)


@dataclass(frozen=True)
class Placement:
    """One file, where the packer put it."""

    #: Which run, by index into the runs the packer was given.
    run: int
    #: Its 24-bit SNES address, where its label lands.
    address: int
    size: int

    @property
    def end(self) -> int:
        """One past its last byte, LoROM's way -- see :func:`advance`."""
        return advance(self.address, self.size)


def is_managed(base: RomBase) -> bool:
    """Whether ``base``'s graphics are packed -- see :func:`pack`."""
    return FEATURE in base.features


def graphics_bank(base: RomBase) -> int:
    """The first graphics bank on ``base``: two past its reservation bank,
    ``$12`` on a plain build and ``$13`` on ``sa1``."""
    return base.reservation_bank + BANK_OFFSET


def bank_count_define(banks: int) -> tuple[str, str]:
    """The ``--define`` pair that asks the assembler for ``banks`` graphics
    banks, in the shape :func:`smw_tools.build.build_rom` takes. The default
    count needs none, and the config refuses fewer than one."""
    if banks < 1:
        raise GraphicsMemoryError("the managed graphics need at least one bank")
    return (COUNT_DEFINE, str(banks))


def last_bank(base: RomBase, banks: int = DEFAULT_BANK_COUNT) -> int:
    """The highest bank ``banks`` graphics banks reach on ``base``."""
    if banks < 1:
        raise GraphicsMemoryError("the managed graphics need at least one bank")
    found = graphics_bank(base) + banks - 1
    if found > LAST_USABLE_BANK:
        raise GraphicsMemoryError(
            f"{banks} graphics banks from ${graphics_bank(base):02X} reach "
            f"${found:02X}, past bank ${LAST_USABLE_BANK:02X} where the work "
            f"RAM mirror ends"
        )
    return found


def rom_size_for(base: RomBase, banks: int = DEFAULT_BANK_COUNT) -> str:
    """The smallest cartridge of ``base``'s ladder every one of ``banks``
    graphics banks exists in, as a :mod:`smw_tools.rom_sizes` id.

    One bank is what the feature's ``min_rom_size`` says; the count is what
    raises it further. A count no size of the base reaches is refused.
    """
    needed = (last_bank(base, banks) + 1) * 0x8000
    for size_id in base.sizes:
        if ROM_SIZES[size_id].size >= needed:
            return size_id
    raise GraphicsMemoryError(
        f"{banks} graphics banks need a {needed // 1024} KB cartridge, which "
        f"{base.id} cannot be built at"
    )


def bank_count_for(base: RomBase, size_id: str) -> int:
    """How many graphics banks ``size_id`` has room for on ``base``: every
    bank from the first graphics bank to the cartridge's end, capped where
    the work RAM mirror ends. Zero for a size the first bank is not in."""
    first = graphics_bank(base)
    top = min(ROM_SIZES[size_id].size // 0x8000 - 1, LAST_USABLE_BANK)
    return max(0, top - first + 1)


def runs_for(base: RomBase, banks: int = DEFAULT_BANK_COUNT) -> tuple[Run, ...]:
    """The runs ``base``'s packer fills, in order: the stock four banks, then
    each of ``banks`` graphics banks -- the first from behind its head, the
    rest from past their RATS tag.

    A graphics bank's run ends *at* the bank's last byte rather than past it:
    ``%SMW_ManagedGraphicsFit`` measures against ``$xxFFFF`` and the fill
    stops there, so that one byte is never packed into and the run is a byte
    shorter than the bank behind the tag.
    """
    first = graphics_bank(base)
    last_bank(base, banks)
    runs = [RUN0]
    for index in range(banks):
        bank = (first + index) << 16
        start = STREAMS_OFFSET if index == 0 else BANK_RUN
        runs.append(Run(bank | start, bank | BANK_END))
    return tuple(runs)


def order(added: Iterable[int] = ()) -> tuple[int, ...]:
    """The order the packing lays the files: the stock ones as the placement
    inserts them, then the added numbers ascending."""
    extra = sorted(set(added))
    for number in extra:
        check_added_number(number)
    return (*STOCK_ORDER, *extra)


def check_added_number(number: int) -> None:
    if not FIRST_ADDED <= number <= LAST_ADDED:
        raise GraphicsMemoryError(
            f"{graphics.name_for(number)} cannot be an added file: the game's "
            f"own are {graphics.name_for(0)}-{graphics.name_for(STOCK_FILES - 1)}, "
            f"an added one is {graphics.name_for(FIRST_ADDED)}-"
            f"{graphics.name_for(LAST_ADDED)}, and ${SENTINEL:02X} is "
            f"never a file"
        )
    if number == UNNAMEABLE:
        raise GraphicsMemoryError(
            f"{graphics.name_for(UNNAMEABLE)} cannot be an added file: a level "
            f"container "
            f"spells 'no file' as ${UNNAMEABLE:02X} in its ExGFX slot, so no "
            f"level could ever name it"
        )


def addable(number: int) -> bool:
    """Whether ``number`` may be an added file (:func:`check_added_number`)."""
    try:
        check_added_number(number)
    except GraphicsMemoryError:
        return False
    return True


def advance(address: int, size: int) -> int:
    """``address`` plus ``size`` bytes of image, LoROM's way: a step off the
    end of a bank lands at the next bank's ``$8000``, which is where the
    assembler's cursor goes with the bank-crossing check off."""
    return pc_to_snes(snes_to_pc(address) + size)


def pack(sizes: Mapping[int, int], runs: tuple[Run, ...]) -> dict[int, Placement]:
    """Lay the files of ``sizes`` into ``runs`` the way the managed banks do.

    ``sizes`` is compressed size by file number, and must hold every stock
    number; any number past them is an added file. The packer's own
    arithmetic (``%SMW_ManagedGraphicsFit``): stock files in the placement's
    order and then added numbers ascending, back to back from the first
    run's start; a file that would run past the end of the run being filled
    moves the packing to the next run; the packing never goes back. A file
    left over when the runs are spent is :class:`GraphicsMemoryFull`, which
    is what the build refuses at.

    The fit is the assembler's own test, ``pc()+size > end`` over the SNES
    address, which is exact for every file shorter than a bank -- and the
    step after a file is :func:`advance`, so a file that ends at a bank's
    edge inside the first run is followed at the next bank's start, as the
    assembler follows it.

    ``runs`` is the cartridge's -- :func:`runs_for`. The result is by file
    number, each where its label lands.
    """
    missing = [n for n in STOCK_ORDER if n not in sizes]
    if missing:
        raise GraphicsMemoryError(
            "no size for the stock files "
            + ", ".join(graphics.name_for(n) for n in missing)
        )
    laid = lay_out(
        order(n for n in sizes if n >= STOCK_FILES),
        lambda number: sizes[number],
        runs,
        step=advance,
    )
    if laid.leftover:
        number, size = laid.leftover[0]
        raise GraphicsMemoryFull(
            number, size, sum(each for _number, each in laid.leftover)
        )
    return {
        slot.item: Placement(run=slot.run, address=slot.address, size=slot.size)
        for slot in laid.placed
    }


def free_address(placed: Mapping[int, Placement], runs: tuple[Run, ...]) -> int:
    """Where the packed data ends -- ``SMW_ManagedGraphics_Free`` -- for a
    packing :func:`pack` made: one past the last file, or the first run's
    start with nothing packed."""
    if not placed:
        return runs[0].start
    last = max(placed.values(), key=lambda one: (one.run, one.address))
    return last.end


def spare(placed: Mapping[int, Placement], runs: tuple[Run, ...]) -> int:
    """How many bytes the packing has left: the rest of the run it ended in
    and every run after it. What one more byte of any file may take before
    the next run boundary moves a file along; a file that crosses one wastes
    the tail of the run it left, so this is an upper bound."""
    if not placed:
        return sum(run.size for run in runs)
    last = max(placed.values(), key=lambda one: (one.run, one.address))
    left = snes_to_pc(runs[last.run].end - 1) + 1 - snes_to_pc(last.end)
    return left + sum(run.size for run in runs[last.run + 1 :])


def player_files_share_a_bank(placed: Mapping[int, Placement]) -> bool:
    """Whether GFX33 ends in the bank GFX32 starts in, which the build
    asserts: the boot-time decompression of the pair reads GFX32 with the
    bank GFX33's stream ended in, so a packing that parts them is refused
    by the assembler and should be refused before it."""
    return (placed[0x33].end - 1) >> 16 == placed[0x32].address >> 16


def asset_relative(directory: str, number: int) -> Path:
    """An added file's stream within an assets root, ``GFX/SMW_U/GFX34.lz2``:
    the same path rule the stock files follow (:func:`graphics.baseline_relative`),
    for the numbers that function refuses because no set ships them. The
    suffix names the family of the set, as for the stock files."""
    check_added_number(number)
    family = graphics.family_for_set(directory)
    name = graphics.name_for(number)
    return Path("GFX") / directory / f"{name}.{family.name.lower()}"


def decompressed_size(fmt: int) -> int:
    """What a file of format ``fmt`` decompresses to, and its raw form's length."""
    try:
        return DECOMPRESSED_SIZES[fmt]
    except KeyError:
        raise GraphicsMemoryError(
            f"no graphics format {fmt}; 0 is 3bpp and 1 is 4bpp"
        ) from None


def added_numbers(text: str) -> list[int]:
    """The file numbers ``text`` -- an added-graphics fragment -- lists, in
    its order. Refuses a number that cannot be added."""
    found = [
        int(match.group(1), 16)
        for line in text.splitlines()
        if (match := _ADDED_LINE.match(line))
    ]
    for number in found:
        check_added_number(number)
    return found


def formats(text: str) -> dict[int, int]:
    """File number -> format for every line of ``text``, a formats fragment.
    A number left out is 3bpp, and a line declaring a format an added file
    cannot be is refused, exactly as the macro's own assert refuses it."""
    found: dict[int, int] = {}
    for line in text.splitlines():
        match = _FORMAT_LINE.match(line)
        if match is None:
            continue
        number, fmt = int(match.group(1), 16), int(match.group(2))
        check_added_number(number)
        if fmt not in DECLARED_FORMATS:
            declared = ", ".join(str(one) for one in DECLARED_FORMATS)
            raise GraphicsMemoryError(
                f"{graphics.name_for(number)} declares format {fmt}: the "
                f"formats fragment declares {declared}, and a file it leaves "
                f"out is 3bpp"
            )
        found[number] = fmt
    return found


def added_rows(numbers: Iterable[int]) -> list[str]:
    """The added-graphics fragment's lines for ``numbers``, ascending, one
    ``%SMW_AddedGraphics(GFXnn)`` each -- what the editor writes."""
    return [
        f"%SMW_AddedGraphics({graphics.name_for(n)})\n" for n in sorted(set(numbers))
    ]


def format_rows(by_number: Mapping[int, int]) -> list[str]:
    """The formats fragment's lines: one ``%SMW_GraphicsFormat(GFXnn, code)``
    per file whose format code is not the ordinary 3bpp slot's, ascending;
    a 3bpp file is left out, which is what the grammar reads."""
    return [
        f"%SMW_GraphicsFormat({graphics.name_for(n)}, {fmt})\n"
        for n, fmt in sorted(by_number.items())
        if fmt != FORMAT_3BPP
    ]
