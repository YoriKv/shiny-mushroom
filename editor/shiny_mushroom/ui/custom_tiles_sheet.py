"""The Tilemap editor's sheet of custom tiles: the four pages past the stock
two, drawn from the project's Lunar Magic container.

A :class:`~shiny_mushroom.ui.map16_sheets.Sheet` like the tables' and the
world map's stamp sheets, over the same 8x8 cell grid: 1024 tiles, sixteen
to a row, four pages one under the other, walked by a snapshot
:class:`~shiny_mushroom.edit.History` of the environment's own whose
document is the container's bytes whole. Every gesture the mode has --
selection, the eyedropper, a stamp, the clipboard, the flips -- works here
unchanged, because a custom tile is four tilemap words like any other; what
the sheet adds is what a custom tile has that a stock one does not, the
acts-like word the properties panel edits
(:mod:`shiny_mushroom.custom_tiles_fields`).

The picture is drawn in the tables sheet's tileset -- the graphics a level
of that tileset would show the tiles with -- and the pages are tinted in
turn so the four read as four.
"""

from __future__ import annotations

from collections.abc import Callable, Mapping

from PySide6.QtCore import QRect
from PySide6.QtGui import QColor, QImage

from shiny_mushroom import custom_tiles
from shiny_mushroom.custom_tiles_fields import (
    CustomCellsEntry,
    CustomTilesEntry,
    custom_tile_fields,
)
from shiny_mushroom.edit import History
from shiny_mushroom.fields import Field
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level import BLOCK
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.map16 import TILESET_COUNT
from shiny_mushroom.map16_fields import QUADRANTS, cell_fields
from shiny_mushroom.ui.canvas import Overlay
from shiny_mushroom.ui.map16_render import (
    SHEET_COLUMNS,
    Viewed,
    blit_block,
    sheet_image,
)
from shiny_mushroom.ui.map16_sheets import BLANK_WORD, Cell, Sheet
from smw_tools.map16 import EMPTY_TILE, PAGE

#: The sheet in cells: sixteen tiles a row, the four pages stacked.
CELL_COLUMNS = SHEET_COLUMNS * 2
CELL_ROWS = custom_tiles.TILE_COUNT // SHEET_COLUMNS * 2

#: The word every cell of a blanked custom tile is put to: Lunar Magic's
#: empty tile, which the sheet draws as the cartridge draws it -- the
#: whole page starts as one, and hatching a thousand of them would say
#: nothing the picture does not.
EMPTY_WORD = int.from_bytes(EMPTY_TILE[:2], "little")

#: The tint over every other page, so the four read as four.
PAGE_TINT = QColor(80, 160, 255, 40)
_NO_LINE = QColor(0, 0, 0, 0)

#: Why the sheet cannot be shown, on the status line.
NO_CUSTOM_TILES = (
    "This cartridge has no custom tiles: switch the Custom tiles feature on "
    "under Project > Features and rebuild."
)


def _tile_of(cell: Cell) -> tuple[int, int]:
    """Which custom tile ``cell`` belongs to, and which storage-order
    quadrant of it the cell is."""
    x, y = cell
    tile = custom_tiles.FIRST_TILE + (y // 2) * SHEET_COLUMNS + x // 2
    return tile, (x % 2) * 2 + y % 2


class CustomTilesSheet(Sheet):
    """The custom tiles: 1024 of them, sixteen a row, one container as the
    document."""

    noun = "tile"
    side = 2
    columns = CELL_COLUMNS
    rows = CELL_ROWS

    def __init__(self) -> None:
        self.history: History[bytes] | None = None
        self._snapshot_for: Callable[[int], LevelSnapshot | None] | None = None
        self._snapshot: LevelSnapshot | None = None
        self._tileset = 0
        self._image = QImage()
        #: The container the picture was last painted from.
        self._shown: bytes | None = None
        self._tint = QImage(1, 1, QImage.Format.Format_ARGB32_Premultiplied)
        self._tint.fill(PAGE_TINT)

    # -- lifecycle ---------------------------------------------------------

    def show(
        self,
        container: bytes,
        snapshot_for: Callable[[int], LevelSnapshot | None],
        tileset: int,
    ) -> None:
        custom_tiles.check(container)
        self._snapshot_for = snapshot_for
        self._tileset = tileset if 0 <= tileset < TILESET_COUNT else 0
        self.history = History(container)
        self._image = QImage()
        self._shown = None

    def forget(self) -> None:
        self.history = None
        self._snapshot_for = None
        self._snapshot = None
        self._image = QImage()
        self._shown = None

    def set_tileset(self, tileset: int) -> None:
        """Draw the tiles with ``tileset``'s graphics: the same document,
        another picture."""
        if not 0 <= tileset < TILESET_COUNT or tileset == self._tileset:
            return
        self._tileset = tileset
        self._image = QImage()
        self._shown = None

    @property
    def tileset(self) -> int:
        return self._tileset

    # -- the contract -------------------------------------------------------

    @property
    def ready(self) -> bool:
        return self.history is not None and self._snapshot is not None

    @property
    def shown(self) -> bool:
        """Whether the sheet holds a document at all -- the cartridge has
        the feature and the project's container was read."""
        return self.history is not None

    @property
    def label(self) -> str:
        first = custom_tiles.FIRST_PAGE
        last = first + custom_tiles.PAGES - 1
        return f"Custom tiles, pages {hexnum(first)}-{hexnum(last)}"

    @property
    def document(self) -> bytes:
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

    def word(self, document: object, cell: Cell) -> int:
        assert isinstance(document, bytes)
        return custom_tiles.word_of(document, *_tile_of(cell))

    def with_words(self, document: object, words: Mapping[Cell, int]) -> object:
        assert isinstance(document, bytes)
        changes = {
            _tile_of(cell): word for cell, word in words.items() if self.holds(cell)
        }
        if all(custom_tiles.word_of(document, *key) == w for key, w in changes.items()):
            return document
        return custom_tiles.with_words(document, changes)

    def blank(self, whole_blocks: bool) -> int:
        return EMPTY_WORD if whole_blocks else BLANK_WORD

    def commit(self, document: object) -> bool:
        assert self.history is not None
        assert isinstance(document, bytes)
        if document == self.document:
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
        self._image = QImage()
        self._shown = None
        return True

    def _viewed_of(self, container: bytes) -> Viewed:
        assert self._snapshot is not None
        return Viewed(
            self._snapshot,
            lambda index: custom_tiles.definition_of(
                container, custom_tiles.FIRST_TILE + index
            ),
        )

    def viewed(self) -> Viewed:
        return self._viewed_of(self.document)

    def render(self, document: object) -> QImage:
        assert isinstance(document, bytes)
        self._image = sheet_image(self._viewed_of(document), custom_tiles.TILE_COUNT)
        self._shown = document
        return self._image

    def patch(self, document: object) -> QImage:
        assert isinstance(document, bytes)
        if self._image.isNull() or self._shown is None:
            return self.render(document)
        changed = custom_tiles.changed_tiles(self._shown, document)
        self._shown = document
        if not changed:
            return self._image
        viewed = self._viewed_of(document)
        for tile in sorted(changed):
            blit_block(self._image, viewed, tile - custom_tiles.FIRST_TILE)
        return self._image

    def overlays(self) -> list[Overlay]:
        rows = PAGE // SHEET_COLUMNS
        return [
            Overlay(
                QRect(0, page * rows * BLOCK, SHEET_COLUMNS * BLOCK, rows * BLOCK),
                _NO_LINE,
                image=self._tint,
            )
            for page in range(custom_tiles.PAGES)
            if page % 2
        ]

    def entry(
        self, document: object, cells: frozenset[Cell], blocks: frozenset[int]
    ) -> tuple[str, list[Field], object]:
        assert isinstance(document, bytes)
        if blocks:
            tiles = frozenset(custom_tiles.FIRST_TILE + block for block in blocks)
            record = CustomTilesEntry(document, tiles)
            if len(tiles) == 1:
                (tile,) = tiles
                heading = f"Custom tile {hexnum(tile, 3)}"
            else:
                heading = f"{len(tiles)} custom tiles"
            return heading, custom_tile_fields(record), record
        keys = frozenset(_tile_of(cell) for cell in cells)
        record = CustomCellsEntry(document, keys)
        if len(keys) == 1:
            ((tile, quadrant),) = keys
            corner = next(
                title for _s, title, _dx, _dy, q in QUADRANTS if q == quadrant
            )
            heading = f"Custom tile {hexnum(tile, 3)}, {corner.lower()} cell"
        else:
            heading = f"{len(keys)} cells"
        return heading, cell_fields(record), record

    def document_of(self, entry: object) -> object:
        assert isinstance(entry, (CustomTilesEntry, CustomCellsEntry))
        return entry.container

    def note(self, document: object, cell: Cell) -> str:
        tile, quadrant = _tile_of(cell)
        corner = next(short for short, _t, _dx, _dy, q in QUADRANTS if q == quadrant)
        return (
            f"Custom tile {hexnum(tile, 3)} {corner.upper()}  "
            f"char {hexnum(self.word(document, cell) & 0x3FF, 3)}  "
            f"page {hexnum(tile >> 8)} -- shared by every level"
        )


__all__ = ["CELL_COLUMNS", "CELL_ROWS", "NO_CUSTOM_TILES", "CustomTilesSheet"]
