"""The Map16 tables as a document: read overlay-first, edited in memory, saved
as the ``.bin`` files the bank includes, and previewed as a byte patch.

**A Map16 tile is eight bytes and nothing else.** Four SNES tilemap words in
the order upper-left, lower-left, upper-right, lower-right, each
``vhopppcc cccccccc`` -- Y flip, X flip, priority, palette, ten bits of tile
number -- copied to the PPU tilemap verbatim
([map16.md](../../docs/smw/map16.md)). :class:`TileDefinition` is that record
as values and :meth:`TileDefinition.decode` / :meth:`TileDefinition.encode`
are the whole codec.

**A table is its own file, and the file is the editable form.**
``smw/src/SMW/GFX/Map16/<name>.bin`` are plain ``incbin``\\ s in
``Banks/Bank0D.asm``, so a copy in the overlay *is* the edit -- no codec, no
feature, no pointer to rewrite. Which file holds a tile under a tileset is
:func:`smw_tools.map16.table_offset`; this module adds only what an editor
needs on top of it: the files loaded overlay-first, a held copy to edit, the
difference against what was loaded (what a save writes) and against the
disassembly's own (what a save leaves in the overlay), and the patch that
shows the held tables over a cartridge image.

**The game reads the definitions off the cartridge every time it builds a
column.** ``SMW_InitializeMap16Pointers`` copies nothing but 512 16-bit
pointers into ``$7E0FBE``; the column builders read the eight bytes through
``[pointer]`` with bank ``$0D`` in the pointer's bank byte
(``LDY.b #SMW_Map16Data_Main>>16``, ``Banks/Bank05.asm``). So a patch over the
image is the whole preview: a level loaded after it shows the edit, and so does
any column scrolled in after it, with nothing to reload.
"""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

from smw_tools.map16 import TILE, TILESET_RUNS, TILESET_TABLES, table_offset

if TYPE_CHECKING:
    from shiny_mushroom.addresses import Addresses
    from smw_tools.symbols import SymbolTable


class Map16Error(ValueError):
    """A table the wrong size, a field out of range, or a file not loaded."""


#: Where the tables live, relative to the disassembly's game folder.
DIRECTORY = Path("GFX/Map16")

#: Bytes per tile definition, and how many tiles a tileset resolves.
DEF_SIZE = TILE
TILE_COUNT = 0x200
TILESET_COUNT = len(TILESET_TABLES)

#: Bit layout of one tilemap word.
_TILE_MASK = 0x03FF
_PALETTE_SHIFT = 10
_PRIORITY = 0x2000
_X_FLIP = 0x4000
_Y_FLIP = 0x8000


@dataclass(frozen=True)
class Run:
    """One placed run of table files: the label the run's first byte carries,
    where the stock build puts it, and the files it includes back to back."""

    label: str
    address: int
    files: tuple[str, ...]


#: The five runs ``Banks/Bank0D.asm`` places, in bank order. The addresses are
#: the ROM maps' own (``%DATATABLE_RT0n_SMW_Map16Data($0Dxxxx)`` in every
#: ``RomMap/ROM_Map_SMW_*.asm``), and every built symbol file agrees with them
#: -- ``test_map16_model.py`` pins that. Each run's files follow one another with
#: nothing between, so a file's address is the run's plus the sizes before it.
#:
#: ``Castle`` stands for whichever castle file the target includes: the PAL
#: rev 1 build reads ``Castle_PALRev1.bin`` at the same address, see
#: :func:`castle_file`.
RUNS: tuple[Run, ...] = (
    Run(
        "SMW_Map16Data_Global",
        0x0D8000,
        (
            "Global",
            "GreenPipes",
            "Global2",
            "SlopedPipeTiles",
            "VariableColorPipes",
            "YellowPipes",
            "PurplePipes",
            "Grassland",
            "Backgrounds",
        ),
    ),
    Run("SMW_Map16Data_Castle", 0x0DBC00, ("Castle", "Castle_Rest")),
    Run("SMW_Map16Data_Rope", 0x0DC800, ("Rope",)),
    Run("SMW_Map16Data_Underground", 0x0DD400, ("Underground",)),
    Run("SMW_Map16Data_GhostHouse", 0x0DE300, ("GhostHouse",)),
)

#: The two files that can stand at the castle run's first slot.
CASTLE_FILES = ("Castle", "Castle_PALRev1")

#: Every table file, by name, in bank order -- the PAL rev 1 castle beside the
#: file it replaces.
FILES: tuple[str, ...] = tuple(
    included
    for run in RUNS
    for name in run.files
    for included in (CASTLE_FILES if name == "Castle" else (name,))
)

#: The framework's ``ROMID`` for PAL rev 1 -- the one target whose
#: ``ver_is_pal_rev1`` conditional includes the other castle file.
_PAL_REV1_ROMID = "SMW_E2"


def castle_file(romid: str) -> str:
    """Which castle file a target's build includes at ``$0DBC00``, from the
    framework's own name for the target (:attr:`BuildTarget.romid`)."""
    return "Castle_PALRev1" if romid == _PAL_REV1_ROMID else "Castle"


def is_shared(tile: int) -> bool:
    """Whether every tileset draws ``tile`` from the same bytes.

    The bitmask split and nothing else: ``$073``-``$0FF``, ``$107``-``$110``
    and ``$153``-``$16D`` are each tileset's own, everything else is one
    table for all fifteen. Tilesets 0 and 7 repoint eight shared numbers at
    ``SlopedPipeTiles`` at level load; those still answer shared here, because
    the override is the tileset's, not the table's -- :meth:`Map16Tables.file_of`
    is where it shows.
    """
    if not 0 <= tile < TILE_COUNT:
        raise Map16Error(f"Map16 tile {tile:#05x} is outside $000-$1FF")
    return not any(start <= tile < stop for start, stop in TILESET_RUNS)


# -- one tile ----------------------------------------------------------------


@dataclass(frozen=True)
class Quadrant:
    """One 8x8 quarter of a Map16 tile: an SNES tilemap word as values."""

    #: 10-bit tile number into the four graphics slots -- nothing the ROM
    #: ships exceeds ``$1FF``, but the field reaches ``$3FF``.
    tile: int
    #: Palette row, 0-7.
    palette: int
    priority: bool = False
    x_flip: bool = False
    y_flip: bool = False

    def __post_init__(self) -> None:
        if not 0 <= self.tile <= _TILE_MASK:
            raise Map16Error(f"tile {self.tile:#05x} does not fit ten bits")
        if not 0 <= self.palette <= 7:
            raise Map16Error(f"palette {self.palette} is not 0-7")

    @classmethod
    def from_word(cls, word: int) -> Quadrant:
        return cls(
            tile=word & _TILE_MASK,
            palette=(word >> _PALETTE_SHIFT) & 7,
            priority=bool(word & _PRIORITY),
            x_flip=bool(word & _X_FLIP),
            y_flip=bool(word & _Y_FLIP),
        )

    @property
    def word(self) -> int:
        return (
            self.tile
            | (self.palette << _PALETTE_SHIFT)
            | (_PRIORITY if self.priority else 0)
            | (_X_FLIP if self.x_flip else 0)
            | (_Y_FLIP if self.y_flip else 0)
        )


@dataclass(frozen=True)
class TileDefinition:
    """One Map16 tile: four quadrants in the order the game stores them."""

    upper_left: Quadrant
    lower_left: Quadrant
    upper_right: Quadrant
    lower_right: Quadrant

    @property
    def quadrants(self) -> tuple[Quadrant, Quadrant, Quadrant, Quadrant]:
        """Storage order: upper-left, lower-left, upper-right, lower-right."""
        return (self.upper_left, self.lower_left, self.upper_right, self.lower_right)

    @classmethod
    def decode(cls, data: bytes) -> TileDefinition:
        if len(data) != DEF_SIZE:
            raise Map16Error(f"a tile definition is {DEF_SIZE} bytes, not {len(data)}")
        words = [int.from_bytes(data[at : at + 2], "little") for at in range(0, 8, 2)]
        return cls(*(Quadrant.from_word(word) for word in words))

    def encode(self) -> bytes:
        return b"".join(q.word.to_bytes(2, "little") for q in self.quadrants)


def decode(data: bytes) -> TileDefinition:
    """Eight bytes to a :class:`TileDefinition`."""
    return TileDefinition.decode(data)


def encode(definition: TileDefinition) -> bytes:
    """A :class:`TileDefinition` to its eight bytes."""
    return definition.encode()


# -- the tables ---------------------------------------------------------------


class Map16Tables:
    """Every table file, held for editing.

    Three copies of each file are kept apart on purpose. **Held** is what the
    editor changes. **Loaded** is what was read in -- the overlay's copy where
    the project has one, the disassembly's otherwise -- and the difference
    between the two is what a save has to write. **Stock** is always the
    disassembly's own, and the difference against *it* is what a save leaves
    in the overlay: a file edited back to stock is deleted from the overlay
    rather than kept as a copy, so the overlay stays the diff.

    Which castle file is held under the name ``Castle`` is the target's
    business (:func:`castle_file`); the other one is loaded too, so a project
    that changes target keeps both.
    """

    def __init__(
        self,
        loaded: Mapping[str, bytes],
        stock: Mapping[str, bytes],
        *,
        castle: str = "Castle",
    ) -> None:
        if castle not in CASTLE_FILES:
            raise Map16Error(f"{castle!r} is not a castle table")
        missing = [name for name in FILES if name not in loaded or name not in stock]
        if missing:
            raise Map16Error(f"table(s) not loaded: {', '.join(missing)}")
        for name in FILES:
            if len(loaded[name]) != len(stock[name]):
                raise Map16Error(
                    f"{name}.bin is {len(loaded[name]):#x} bytes, "
                    f"not {len(stock[name]):#x}"
                )
        self.castle = castle
        self._stock = {name: bytes(stock[name]) for name in FILES}
        self._loaded = {name: bytes(loaded[name]) for name in FILES}
        self._held = {name: bytearray(loaded[name]) for name in FILES}

    @classmethod
    def load(
        cls, base: Path, overlay: Path | None = None, *, castle: str = "Castle"
    ) -> Map16Tables:
        """Read every table out of ``base`` (the disassembly's game folder),
        taking ``overlay``'s copy of a file over it wherever one exists --
        the same rule the build applies when it lays the overlay over the tree.
        """
        stock: dict[str, bytes] = {}
        loaded: dict[str, bytes] = {}
        for name in FILES:
            relative = DIRECTORY / f"{name}.bin"
            stock[name] = (base / relative).read_bytes()
            shadow = None if overlay is None else overlay / relative
            loaded[name] = (
                shadow.read_bytes()
                if shadow is not None and shadow.is_file()
                else stock[name]
            )
        return cls(loaded, stock, castle=castle)

    # -- by tile ------------------------------------------------------------

    def file_of(self, tile: int, tileset: int) -> tuple[str, int]:
        """Which held file defines ``tile`` under ``tileset``, and the byte
        offset of its eight bytes there -- :func:`smw_tools.map16.table_offset`
        with the target's castle file substituted."""
        try:
            name, at = table_offset(tile, tileset)
        except ValueError as error:
            raise Map16Error(str(error)) from error
        return (self.castle if name == "Castle" else name), at

    def raw(self, tile: int, tileset: int) -> bytes:
        name, at = self.file_of(tile, tileset)
        return bytes(self._held[name][at : at + DEF_SIZE])

    def definition(self, tile: int, tileset: int) -> TileDefinition:
        return TileDefinition.decode(self.raw(tile, tileset))

    def set_definition(
        self, tile: int, tileset: int, definition: TileDefinition
    ) -> None:
        name, at = self.file_of(tile, tileset)
        self._held[name][at : at + DEF_SIZE] = definition.encode()

    # -- by file ------------------------------------------------------------

    def file(self, name: str) -> bytes:
        """The held bytes of one table."""
        return bytes(self._held[name])

    def stock(self, name: str) -> bytes:
        """The disassembly's bytes of one table."""
        return self._stock[name]

    def set_file(self, name: str, data: bytes) -> None:
        """Replace one table whole -- how the pipe blocks, which no tile
        number reaches, are edited."""
        if name not in self._held:
            raise Map16Error(f"no Map16 table called {name!r}")
        if len(data) != len(self._stock[name]):
            raise Map16Error(
                f"{name}.bin is {len(self._stock[name]):#x} bytes, not {len(data):#x}"
            )
        self._held[name][:] = data

    @property
    def changed_files(self) -> dict[str, bytes]:
        """Every table that differs from what was loaded -- what a save
        writes."""
        return {
            name: bytes(held)
            for name, held in self._held.items()
            if held != self._loaded[name]
        }

    @property
    def edited(self) -> tuple[str, ...]:
        """Every table that differs from the disassembly's -- what a save
        leaves in the overlay."""
        return tuple(name for name in FILES if self.differs_from_stock(name))

    def differs_from_stock(self, name: str) -> bool:
        return self._held[name] != self._stock[name]

    def mark_saved(self) -> None:
        """Take the held tables as what is now on disk, so
        :attr:`changed_files` measures from the save."""
        self._loaded = {name: bytes(held) for name, held in self._held.items()}

    # -- over a cartridge ------------------------------------------------------

    def addresses(self, symbols: SymbolTable | None = None) -> dict[str, int]:
        """Where each included file starts in the cartridge, as a CPU address.

        Each run's first byte carries a label, and a symbol file -- the
        assembler's record of the very image being patched -- says where that
        build put it; without one the stock placement is read, which every
        shipped target and every base's build agree on today. The files inside
        a run follow one another, so the rest is the stock sizes added up.
        The castle file that is not this target's has no address at all.
        """
        out: dict[str, int] = {}
        for run in RUNS:
            found = None if symbols is None else symbols.by_name.get(run.label)
            at = run.address if found is None else found.addr
            for name in run.files:
                held = self.castle if name == "Castle" else name
                out[held] = at
                at += len(self._stock[held])
        return out

    def patches(
        self,
        rom: bytes,
        where: Addresses,
        symbols: SymbolTable | None = None,
    ) -> dict[int, bytes]:
        """The held tables over ``rom``, as ``{image offset: bytes}`` -- one
        entry per included file whose bytes the image does not already hold.

        Every file is the size the disassembly ships, so each patch is
        in-place and moves nothing. Measured against the image rather than
        against stock, so a file put back to stock after a build that carried
        an edit is patched back too. An image too short to hold a file gets no
        patch for it: that is not a cartridge these addresses mean anything
        in, and the honest answer is nothing rather than a write off its end.
        """
        out: dict[int, bytes] = {}
        for name, address in self.addresses(symbols).items():
            held = bytes(self._held[name])
            at = where.offset(address)
            if len(rom) < at + len(held):
                continue
            if rom[at : at + len(held)] != held:
                out[at] = held
        return out
