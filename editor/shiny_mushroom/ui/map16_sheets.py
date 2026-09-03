"""The sheets the Map16 environment draws on: the Map16 tables, and the
overworld's two event stamp sheets.

All three are pictures of 16-bit tilemap words on an 8x8 grid, grouped into
blocks of one side -- a Map16 tile is 2x2 cells, a 2x2 stamp block 2x2, a
6x6 block 6x6 -- and the environment's gestures, selection, clipboard and
hand are written once over that shape. What differs is where the words
live and whose history an edit lands on, and that is what a :class:`Sheet`
answers:

- :class:`TablesSheet` -- the fifteen Map16 table files, an immutable
  mapping of file name to bytes walked by a snapshot
  :class:`~shiny_mushroom.edit.History` of the environment's own; the
  tileset picks which file a tile number resolves to, never the document.
- :class:`StampSheet` -- one of the world map's two stamp sheets, drawn from
  the **world map's own document** and committed onto **its** history
  through :meth:`~shiny_mushroom.ui.overworld_mode.OverworldMode
  .commit_stamps`, so a sheet edit shows at every place the block is
  stamped and an undo pressed over the map takes it back. The world map has
  to have been captured once (Go > World Map) for the sheet to have a
  document and graphics to draw with.

Each sheet holds its own picture and patches it against the document it
last drew, so an edit costs the cells that moved and never a re-render.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import Callable, Mapping
from typing import TYPE_CHECKING

from PySide6.QtGui import QColor, QImage

from shiny_mushroom.edit import History
from shiny_mushroom.fields import Field
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level import TILE, Blocks
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.map16 import (
    DEF_SIZE,
    FILES,
    TILE_COUNT,
    TILESET_COUNT,
    Map16Tables,
    file_of,
)
from shiny_mushroom.map16_fields import (
    CELL_COLUMNS,
    CELL_ROWS,
    QUADRANTS,
    CellsEntry,
    TilesEntry,
    cell_fields,
    cell_spot,
    cell_tile,
    file_note,
    tile_fields,
)
from shiny_mushroom.overworld import (
    WorldMap,
    changed_stamps,
    render_sheet,
    sheet_at,
    sheet_blocks,
    sheet_grid,
    sheet_offset,
    sheet_runs,
    sheet_spot,
)
from shiny_mushroom.overworld_fields import StampEntry, layer2_fields
from shiny_mushroom.overworld_snapshot import OverworldSnapshot
from shiny_mushroom.ui.canvas import Overlay
from shiny_mushroom.ui.map16_picture import (
    TILESET_RUN_RECTS,
    UNUSED,
    Map16Picture,
)
from shiny_mushroom.ui.map16_render import Viewed
from shiny_mushroom.ui.render import pixels_to_image

if TYPE_CHECKING:
    from shiny_mushroom.ui.overworld_mode import OverworldMode

#: The tint over the tileset-specific runs -- the tables sheet's own mark,
#: drawn by the canvas as overlays so the picture stays the artwork.
RUN_TINT = QColor(80, 160, 255, 70)

_NO_LINE = QColor(0, 0, 0, 0)

#: The word a blanked cell is put to.
BLANK_WORD = 0
#: The word every cell of a blanked Map16 tile is put to: the unused
#: all-``$FF`` definition, which the sheet hatches.
UNUSED_WORD = 0xFFFF

Cell = tuple[int, int]


class Sheet(ABC):
    """One picture of words: where they live, whose history they land on,
    and how the picture is kept up to date."""

    #: What one block of the sheet is called on the status line and in the
    #: properties heading.
    noun: str
    #: Cells to a block's side.
    side: int
    #: The picture in cells.
    columns: int
    rows: int

    @property
    @abstractmethod
    def ready(self) -> bool: ...

    @property
    @abstractmethod
    def label(self) -> str:
        """The sheet as the status line names it."""

    @property
    @abstractmethod
    def document(self) -> object: ...

    @property
    @abstractmethod
    def edited(self) -> bool: ...

    @property
    @abstractmethod
    def can_undo(self) -> bool: ...

    @property
    @abstractmethod
    def can_redo(self) -> bool: ...

    @abstractmethod
    def word(self, document: object, cell: Cell) -> int:
        """The word drawn at ``cell``."""

    @abstractmethod
    def with_words(self, document: object, words: Mapping[Cell, int]) -> object:
        """``document`` with ``words`` written -- the same document back when
        nothing would change, which is what keeps a no-op out of the history."""

    def blank(self, whole_blocks: bool) -> int:
        """The word a delete writes; ``whole_blocks`` when whole blocks are
        being blanked rather than single cells."""
        del whole_blocks
        return BLANK_WORD

    @abstractmethod
    def commit(self, document: object) -> bool: ...

    @abstractmethod
    def undo(self) -> bool: ...

    @abstractmethod
    def redo(self) -> bool: ...

    @abstractmethod
    def capture(self) -> bool:
        """Re-read the graphics the sheet draws with, saying whether there
        are any: the capture moved, or the sheet is being shown."""

    @abstractmethod
    def viewed(self) -> object:
        """What :class:`~shiny_mushroom.level.Blocks` draws a word from --
        the VRAM and CGRAM behind the picture, for the picker and the ghost."""

    @abstractmethod
    def render(self, document: object) -> QImage:
        """The whole picture, from the capture as it stands."""

    @abstractmethod
    def patch(self, document: object) -> QImage:
        """The picture with the cells on which ``document`` differs from
        what was last drawn repainted -- or rendered whole, where nothing
        was drawn yet."""

    def overlays(self) -> list[Overlay]:
        """Marks the sheet always wears, under the selection's."""
        return []

    @abstractmethod
    def entry(
        self, document: object, cells: frozenset[Cell], blocks: frozenset[int]
    ) -> tuple[str, list[Field], object]:
        """The properties panel's heading, fields and record for a
        selection: ``blocks`` when whole blocks are held, ``cells``
        otherwise."""

    @abstractmethod
    def document_of(self, entry: object) -> object:
        """The document a field edit's answer carries."""

    @abstractmethod
    def note(self, document: object, cell: Cell) -> str:
        """The status line for the pointer over ``cell``."""

    # -- block geometry, the same for every sheet ------------------------------

    @property
    def across(self) -> int:
        return self.columns // self.side

    @property
    def down(self) -> int:
        return self.rows // self.side

    def block_at(self, cell: Cell) -> int:
        """Which block ``cell`` belongs to, in picture order."""
        return (cell[1] // self.side) * self.across + cell[0] // self.side

    def block_cells(self, block: int) -> list[Cell]:
        """Every cell of ``block``, in reading order."""
        left = block % self.across * self.side
        top = block // self.across * self.side
        return [
            (left + dx, top + dy) for dy in range(self.side) for dx in range(self.side)
        ]

    def cell_index(self, cell: Cell) -> int:
        return cell[1] * self.columns + cell[0]

    def cell_of(self, index: int) -> Cell:
        return index % self.columns, index // self.columns

    def holds(self, cell: Cell) -> bool:
        return 0 <= cell[0] < self.columns and 0 <= cell[1] < self.rows


# -- the Map16 tables -----------------------------------------------------------


def files_with_words(
    files: Mapping[str, bytes],
    tileset: int,
    castle: str,
    changes: Mapping[int, int],
) -> Mapping[str, bytes]:
    """``files`` with cell ``changes`` -- cell key to word -- written under
    ``tileset``. The same mapping back when nothing would change."""
    edited: dict[str, bytearray] = {}
    for key, word in changes.items():
        tile, quadrant = cell_tile(key)
        name, at = file_of(tile, tileset, castle)
        held = edited.setdefault(name, bytearray(files[name]))
        held[at + quadrant * 2 : at + quadrant * 2 + 2] = (word & 0xFFFF).to_bytes(
            2, "little"
        )
    if all(bytes(data) == files[name] for name, data in edited.items()):
        return files
    return {
        name: bytes(edited[name]) if name in edited else data
        for name, data in files.items()
    }


class TablesSheet(Sheet):
    """The Map16 tables: 512 tiles, sixteen a row, resolved through one
    tileset's files and walked by a history of the environment's own."""

    noun = "tile"
    side = 2
    columns = CELL_COLUMNS
    rows = CELL_ROWS

    def __init__(self) -> None:
        #: The project's tables, written only on the way to a save; the
        #: editable document is the history's.
        self.tables: Map16Tables | None = None
        self.history: History[Mapping[str, bytes]] | None = None
        #: How the sheet gets a snapshot to draw a tileset with -- the
        #: window's, which owns the capture and the per-tileset VRAM swap.
        self._snapshot_for: Callable[[int], LevelSnapshot | None] | None = None
        self._snapshot: LevelSnapshot | None = None
        self._tileset = 0
        self._picture = Map16Picture()
        #: The definitions the picture was last painted from, per file --
        #: what a diff for a one-block repaint is measured against.
        self._shown: Mapping[str, bytes] = {}
        #: ``(name, offset) -> tile`` under the current tileset, for turning
        #: a file diff back into the blocks to repaint. Rebuilt per tileset.
        self._tile_map: dict[tuple[str, int], int] | None = None
        self._tint = QImage(1, 1, QImage.Format.Format_ARGB32_Premultiplied)
        self._tint.fill(RUN_TINT)

    # -- lifecycle ---------------------------------------------------------

    def show(
        self,
        tables: Map16Tables,
        snapshot_for: Callable[[int], LevelSnapshot | None],
        tileset: int,
    ) -> None:
        self.tables = tables
        self._snapshot_for = snapshot_for
        self._tileset = tileset if 0 <= tileset < TILESET_COUNT else 0
        self.history = History({name: tables.file(name) for name in FILES})
        self._tile_map = None
        self._picture.forget()

    def forget(self) -> None:
        self.tables = None
        self.history = None
        self._snapshot_for = None
        self._snapshot = None
        self._tile_map = None
        self._picture.forget()

    @property
    def tileset(self) -> int:
        return self._tileset

    def set_tileset(self, tileset: int) -> None:
        """Resolve tile numbers through ``tileset``'s files: the same
        document, another picture."""
        if not 0 <= tileset < TILESET_COUNT or tileset == self._tileset:
            return
        self._tileset = tileset
        self._tile_map = None
        self._picture.forget()

    @property
    def castle(self) -> str:
        return "Castle" if self.tables is None else self.tables.castle

    # -- the contract -------------------------------------------------------

    @property
    def ready(self) -> bool:
        return self.history is not None and self._snapshot is not None

    @property
    def label(self) -> str:
        return f"Map16 tables, tileset {hexnum(self._tileset)}"

    @property
    def document(self) -> Mapping[str, bytes]:
        assert self.history is not None
        return self.history.level

    @property
    def edited(self) -> bool:
        return self.history is not None and self.history.edited

    @property
    def can_undo(self) -> bool:
        return self.history is not None and self.history.can_undo

    @property
    def can_redo(self) -> bool:
        return self.history is not None and self.history.can_redo

    def raw_of(self, tile: int, files: Mapping[str, bytes] | None = None) -> bytes:
        name, at = file_of(tile, self._tileset, self.castle)
        return (files if files is not None else self.document)[name][at : at + DEF_SIZE]

    def word(self, document: object, cell: Cell) -> int:
        assert isinstance(document, Mapping)
        key = cell_spot(*cell)
        assert key is not None
        tile, quadrant = cell_tile(key)
        name, at = file_of(tile, self._tileset, self.castle)
        data = document[name]
        return int.from_bytes(data[at + quadrant * 2 : at + quadrant * 2 + 2], "little")

    def with_words(self, document: object, words: Mapping[Cell, int]) -> object:
        assert isinstance(document, Mapping)
        changes: dict[int, int] = {}
        for cell, word in words.items():
            key = cell_spot(*cell)
            if key is not None:
                changes[key] = word
        return files_with_words(document, self._tileset, self.castle, changes)

    def blank(self, whole_blocks: bool) -> int:
        return UNUSED_WORD if whole_blocks else BLANK_WORD

    def commit(self, document: object) -> bool:
        assert self.history is not None
        assert isinstance(document, Mapping)
        if document is self.document or dict(document) == dict(self.document):
            return False
        return self.history.commit(document)

    def undo(self) -> bool:
        return self.history is not None and self.history.undo()

    def redo(self) -> bool:
        return self.history is not None and self.history.redo()

    def saved(self) -> None:
        if self.history is not None:
            self.history.saved()

    def capture(self) -> bool:
        if self.history is None or self._snapshot_for is None:
            return False
        fresh = self._snapshot_for(self._tileset)
        if fresh is None:
            return False
        self._snapshot = fresh
        self._picture.forget()
        return True

    def viewed(self) -> Viewed:
        assert self._snapshot is not None
        return Viewed(self._snapshot, self.raw_of)

    def _viewed_of(self, files: Mapping[str, bytes]) -> Viewed:
        assert self._snapshot is not None
        return Viewed(self._snapshot, lambda tile: self.raw_of(tile, files))

    def _unused(self, files: Mapping[str, bytes]) -> frozenset[int]:
        return frozenset(
            tile for tile in range(TILE_COUNT) if self.raw_of(tile, files) == UNUSED
        )

    def render(self, document: object) -> QImage:
        assert isinstance(document, Mapping)
        self._shown = document
        return self._picture.render(self._viewed_of(document), self._unused(document))

    def patch(self, document: object) -> QImage:
        assert isinstance(document, Mapping)
        if not self._picture.ready:
            return self.render(document)
        tiles = self._changed_tiles(document)
        self._shown = document
        if not tiles:
            return self._picture.image
        return self._picture.patch(
            self._viewed_of(document), tiles, self._unused(document)
        )

    def _tiles_by_place(self) -> dict[tuple[str, int], int]:
        if self._tile_map is None:
            self._tile_map = {
                file_of(tile, self._tileset, self.castle): tile
                for tile in range(TILE_COUNT)
            }
        return self._tile_map

    def _changed_tiles(self, current: Mapping[str, bytes]) -> frozenset[int]:
        shown = self._shown
        places = self._tiles_by_place()
        changed: set[int] = set()
        for name, data in current.items():
            before = shown.get(name)
            if before is None or before == data:
                continue
            for at in range(0, len(data), DEF_SIZE):
                if data[at : at + DEF_SIZE] != before[at : at + DEF_SIZE]:
                    tile = places.get((name, at))
                    if tile is not None:
                        changed.add(tile)
        return frozenset(changed)

    def overlays(self) -> list[Overlay]:
        return [Overlay(rect, _NO_LINE, image=self._tint) for rect in TILESET_RUN_RECTS]

    def entry(
        self, document: object, cells: frozenset[Cell], blocks: frozenset[int]
    ) -> tuple[str, list[Field], object]:
        assert isinstance(document, Mapping)
        if blocks:
            record = TilesEntry(document, self._tileset, self.castle, blocks)
            if len(blocks) == 1:
                (tile,) = blocks
                heading = f"Map16 tile {hexnum(tile, 3)}"
            else:
                heading = f"{len(blocks)} Map16 tiles"
            return heading, tile_fields(record), record
        keys = frozenset(self.cell_index(cell) for cell in cells)
        record = CellsEntry(document, self._tileset, self.castle, keys)
        if len(keys) == 1:
            (key,) = keys
            tile, quadrant = cell_tile(key)
            corner = next(
                title for _s, title, _dx, _dy, q in QUADRANTS if q == quadrant
            )
            heading = f"Tile {hexnum(tile, 3)}, {corner.lower()} cell"
        else:
            heading = f"{len(keys)} cells"
        return heading, cell_fields(record), record

    def document_of(self, entry: object) -> object:
        assert isinstance(entry, (TilesEntry, CellsEntry))
        return entry.files

    def note(self, document: object, cell: Cell) -> str:
        key = cell_spot(*cell)
        assert key is not None
        tile, quadrant = cell_tile(key)
        corner = next(short for short, _t, _dx, _dy, q in QUADRANTS if q == quadrant)
        return (
            f"Tile {hexnum(tile, 3)} {corner.upper()}  "
            f"char {hexnum(self.word(document, cell) & 0x3FF, 3)}  "
            f"{file_note(tile, self._tileset, self.castle)}"
        )

    # -- the project's tables ------------------------------------------------

    @property
    def held_tables(self) -> Map16Tables | None:
        """The tables with the document written into them, or ``None`` where
        the sheet was never shown -- what a preview, a test run and a save
        are handed. The same object every time."""
        if self.tables is None or self.history is None:
            return None
        for name, data in self.document.items():
            if self.tables.file(name) != data:
                self.tables.set_file(name, data)
        return self.tables


# -- the overworld's stamp sheets --------------------------------------------


class StampSheet(Sheet):
    """One of the world map's stamp sheets, wrapped to a square -- the 6x6
    sheet's 64 blocks as 8 x 8, the 2x2 sheet's 256 as 16 x 16 -- edited
    on the world map's own document and history."""

    noun = "block"

    def __init__(self, world: OverworldMode | None, small: bool) -> None:
        self._world = world
        self.small = small
        across, down, side = sheet_blocks(small=small)
        self.side = side
        self.columns, self.rows = sheet_grid(small=small)
        self._snapshot: OverworldSnapshot | None = None
        self._pixels = bytearray()
        self._image: QImage | None = None
        self._shown: WorldMap | None = None

    @property
    def ready(self) -> bool:
        world = self._world
        return (
            world is not None
            and world.ready
            and bool(world.document.stamps)
            and world.framed_snapshot is not None
        )

    @property
    def size(self) -> str:
        """The sheet's name in the world map's own spelling: ``2x2``, ``6x6``."""
        return f"{self.side}x{self.side}"

    @property
    def label(self) -> str:
        return f"{self.size} stamp sheet"

    @property
    def document(self) -> WorldMap:
        assert self._world is not None
        return self._world.document

    @property
    def edited(self) -> bool:
        return self._world is not None and self._world.edited

    @property
    def can_undo(self) -> bool:
        world = self._world
        return (
            world is not None and world.history is not None and world.history.can_undo
        )

    @property
    def can_redo(self) -> bool:
        world = self._world
        return (
            world is not None and world.history is not None and world.history.can_redo
        )

    def offset(self, cell: Cell) -> int | None:
        return sheet_spot(cell[0], cell[1], small=self.small)

    def block_offsets(self, block: int) -> list[int]:
        return [
            sheet_offset(block, row, column, small=self.small)
            for row in range(self.side)
            for column in range(self.side)
        ]

    def word(self, document: object, cell: Cell) -> int:
        assert isinstance(document, WorldMap)
        offset = self.offset(cell)
        assert offset is not None
        return document.stamp_word(offset)

    def with_words(self, document: object, words: Mapping[Cell, int]) -> object:
        assert isinstance(document, WorldMap)
        changes: dict[int, int] = {}
        for cell, word in words.items():
            offset = self.offset(cell)
            if offset is not None:
                changes[offset] = word & 0xFFFF
        return document.stamp_words_placed(changes)

    def commit(self, document: object) -> bool:
        assert self._world is not None
        assert isinstance(document, WorldMap)
        return self._world.commit_stamps(document)

    def _walked(self, step: Callable[[], None]) -> bool:
        assert self._world is not None
        before = self._world.document
        step()
        return self._world.document is not before

    def undo(self) -> bool:
        assert self._world is not None
        return self._walked(self._world.undo)

    def redo(self) -> bool:
        assert self._world is not None
        return self._walked(self._world.redo)

    def capture(self) -> bool:
        if not self.ready:
            return False
        assert self._world is not None
        self._snapshot = self._world.framed_snapshot
        self._image = None
        return True

    def viewed(self) -> OverworldSnapshot:
        assert self._snapshot is not None
        return self._snapshot

    def render(self, document: object) -> QImage:
        assert isinstance(document, WorldMap)
        assert self._snapshot is not None
        picture = render_sheet(
            document, self._snapshot, small=self.small, painter=Blocks(self._snapshot)
        )
        self._pixels = bytearray(picture.pixels)
        self._image = pixels_to_image(self._pixels, picture.width, picture.height)
        self._shown = document
        return self._image

    def patch(self, document: object) -> QImage:
        assert isinstance(document, WorldMap)
        shown = self._shown
        if self._image is None or shown is None:
            return self.render(document)
        moved = set(changed_stamps(shown.stamps, document.stamps))
        moved.update(changed_stamps(shown.stamp_props, document.stamp_props))
        self._shown = document
        if not moved:
            return self._image
        assert self._snapshot is not None
        for at, pixels in sheet_runs(
            document,
            self._snapshot,
            sorted(moved),
            small=self.small,
            painter=Blocks(self._snapshot),
        ):
            self._pixels[at : at + len(pixels)] = pixels
        self._image = pixels_to_image(
            self._pixels, self.columns * TILE, self.rows * TILE
        )
        return self._image

    def entry(
        self, document: object, cells: frozenset[Cell], blocks: frozenset[int]
    ) -> tuple[str, list[Field], object]:
        assert isinstance(document, WorldMap)
        if blocks:
            offsets = frozenset(
                offset for block in blocks for offset in self.block_offsets(block)
            )
            if len(blocks) == 1:
                (block,) = blocks
                heading = f"{self.size} block {hexnum(block)} -- every cell"
            else:
                heading = f"{len(blocks)} {self.side}x{self.side} blocks -- every cell"
        else:
            offsets = frozenset(
                offset for cell in cells if (offset := self.offset(cell)) is not None
            )
            if len(offsets) == 1:
                (offset,) = offsets
                block, row, column, _small = sheet_at(offset)
                heading = f"{self.size} block {hexnum(block)}, cell ({row}, {column})"
            else:
                heading = f"{len(offsets)} sheet cells"
        record = StampEntry(document, offsets)
        return heading, layer2_fields(record), record

    def document_of(self, entry: object) -> object:
        assert isinstance(entry, StampEntry)
        return entry.document

    def note(self, document: object, cell: Cell) -> str:
        offset = self.offset(cell)
        if offset is None:
            return ""
        block, row, column, _small = sheet_at(offset)
        assert isinstance(document, WorldMap)
        return (
            f"{self.size} block {hexnum(block)} ({row}, {column})  "
            f"sheet {hexnum(offset, 3)}  "
            f"char {hexnum(document.stamp_word(offset) & 0x3FF, 3)}"
        )


__all__ = [
    "BLANK_WORD",
    "RUN_TINT",
    "UNUSED_WORD",
    "Cell",
    "Sheet",
    "StampSheet",
    "TablesSheet",
    "files_with_words",
]
