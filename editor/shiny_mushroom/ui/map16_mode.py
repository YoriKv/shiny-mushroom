"""The Map16 editing environment: a sheet of tilemap words on the main
canvas.

The overworld mode's sibling, under the same shape: the window routes
gestures here whole while :attr:`EditorMode.MAP16` is up, and this owns what
each one means. What is on the canvas is one :class:`~shiny_mushroom.ui
.map16_sheets.Sheet` -- the Map16 tables seen through one tileset, or one of
the world map's two event stamp sheets -- and the sheet answers where the
words live and whose history an edit lands on; everything a gesture means
is written once, here, over an 8x8 grid grouped into blocks.

**One sheet, two grains.** The Editing box picks whether a gesture
addresses whole **tiles** -- a block of the sheet's side, a Map16 tile's
2x2 cells or a 6x6 stamp block's 36 -- or their 8x8 **cells**
(:class:`Grain`). Keys 1 and 2 pick the same rows.

**The gestures are a tilemap editor's.** A click selects the unit under the
pointer and a drag sweeps a rectangle of them -- a selection is always a
rectangle, drawn as one two-tone ring. The properties panel edits what is
held; H and V flip each held word in place, Shift+H and Shift+V mirror the
selection as a picture; cut, copy and paste go through an in-app clipboard,
and a paste lands at the selection's corner (or under the pointer) as one
undo step. The hand is the drawing tool: picking a char in the VRAM dock,
or picking something up off the sheet with the right button, arms it, and
then a click lays it, a drag paints a stroke (one undo step) and Esc puts it
down. The right button is the editor-wide eyedropper
([`right-click.md`](../../docs/editor/right-click.md)): a click picks up
the unit under the pointer -- a cell's word, or a whole tile as a block in
hand -- and a drag grabs a region as a stamp. The dock's palette, flip and
priority controls act on whatever is in hand.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass
from enum import Enum, auto
from typing import TYPE_CHECKING

from PySide6.QtCore import QObject, QPoint, QRect, QSize, Qt
from PySide6.QtGui import QImage, QPainter

from shiny_mushroom.hexnum import hexspot
from shiny_mushroom.level import TILE, Blocks, Raster
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.map16 import TILESET_COUNT, Map16Tables
from shiny_mushroom.tile_clipboard import GridStamp, TileClipboard, relative
from shiny_mushroom.ui.canvas import Canvas, Overlay
from shiny_mushroom.ui.canvas_view import CanvasView
from shiny_mushroom.ui.custom_tiles_sheet import NO_CUSTOM_TILES, CustomTilesSheet
from shiny_mushroom.ui.gestures import grab_stamp, snapped_box
from shiny_mushroom.ui.map16_bar import (
    SHEET_2X2,
    SHEET_6X6,
    SHEET_CUSTOM,
    edit_rows_for,
)
from shiny_mushroom.ui.map16_panel import Map16Panel
from shiny_mushroom.ui.map16_picture import PickerCache
from shiny_mushroom.ui.map16_render import ANIMATED_CHARS
from shiny_mushroom.ui.map16_sheets import Cell, Sheet, StampSheet, TablesSheet
from shiny_mushroom.ui.map16_words import (
    Payload,
    flipped_words,
    mirrored,
    mirrored_words,
)
from shiny_mushroom.ui.overlays import (
    DASH_LENGTH,
    PLACING_COLOR,
    PLACING_OPACITY,
    SELECTION_DASH,
    SELECTION_LINE,
)
from shiny_mushroom.ui.properties import PropertiesDock
from shiny_mushroom.ui.render import raster_to_image
from shiny_mushroom.ui.tile_palette import Layer2Word

if TYPE_CHECKING:
    from shiny_mushroom.ui.overworld_mode import OverworldMode

NOTHING_SELECTED = "Nothing selected"

#: What picking a stamp sheet says while the world map has never been
#: captured: the sheets are drawn in the map's graphics, and edited on the
#: map's own document, so there has to be one.
NO_WORLD_MAP = (
    "Open the world map once (Go > World Map) first: the stamp sheets are "
    "drawn from its capture and edited on its document."
)


class Grain(Enum):
    """Which grid a gesture addresses: whole tiles, or their cells."""

    TILES = auto()
    CELLS = auto()


#: The Editing box's rows, in :data:`~shiny_mushroom.ui.map16_bar.EDIT_ROWS`
#: order.
GRAINS: tuple[Grain, ...] = (Grain.TILES, Grain.CELLS)


@dataclass(frozen=True)
class Map16Clipboard(TileClipboard):
    """A copy off a sheet: cells with their words, and which grain the copy
    was taken at -- a tiles copy pastes at the tiles grain, snapped to
    whole blocks, so a paste of tiles keeps them tiles."""

    blocks: bool = False


class Map16Mode(QObject):
    """Owns the Map16 gestures and their sheets while the mode is up."""

    def __init__(
        self,
        canvas: Canvas,
        view: CanvasView,
        properties: PropertiesDock,
        dock: Map16Panel,
        status: Callable[[str], None],
        changed: Callable[[], None],
        world: OverworldMode | None = None,
    ) -> None:
        super().__init__()
        self._canvas = canvas
        self._view = view
        self._properties = properties
        self._dock = dock
        self._status = status
        self._changed = changed
        self._world = world

        self._snapshot_for: Callable[[int], LevelSnapshot | None] | None = None
        self._tables = TablesSheet()
        #: The project's custom tiles, shown where the cartridge carries the
        #: feature and the project's container was read.
        self._custom = CustomTilesSheet()
        self._stamp_sheets = {
            SHEET_2X2: StampSheet(world, small=True),
            SHEET_6X6: StampSheet(world, small=False),
        }
        self._sheet: Sheet = self._tables
        #: The Sheet box row on the canvas: a tileset, or a stamp sheet's row.
        self._sheet_index = 0

        self.grain: Grain = Grain.TILES
        #: What is held: keys in the grain's own grid -- a block's index at
        #: the tiles grain, a cell's at the cells grain -- and always the
        #: keys of one rectangle.
        self.selection: frozenset[int] = frozenset()
        #: A marquee in flight: the unit it was anchored on, and the unit
        #: the pointer is over now.
        self._marquee: tuple[tuple[int, int], tuple[int, int]] | None = None
        #: A right drag in flight, as the two corners it was made from. It
        #: is drawn and grabbed as whole units at the grain in force
        #: (:func:`snapped_box`), so its box snaps as it is dragged.
        self._stamp_grab: tuple[QPoint, QPoint] | None = None
        self._cursor: QPoint | None = None
        #: What is in hand and the cell its top-left corner is offering to
        #: land on.
        self._placing: Payload | None = None
        self._placing_at: Cell | None = None
        self._placing_image: QImage | None = None
        #: Whether the payload arriving from the dock is one this mode
        #: picked up off the sheet: it lands at the grain it was taken at,
        #: where a char picked in the dock means cells.
        self._picking = False
        #: A paint stroke in progress: the document plus everything the drag
        #: has crossed, committed whole when the button comes up.
        self._stroke: object | None = None
        self.clipboard: Map16Clipboard | None = None
        self._picker_cache = PickerCache()

        dock.armed.connect(self._armed)
        dock.rearmed.connect(self._rearmed)
        dock.attributes_moved.connect(self._repaint_picker)

    # -- what the mode holds ---------------------------------------------------

    @property
    def sheet(self) -> Sheet:
        return self._sheet

    @property
    def sheet_index(self) -> int:
        """The Sheet box row on the canvas."""
        return self._sheet_index

    @property
    def on_stamps(self) -> bool:
        """Whether the canvas shows one of the world map's stamp sheets."""
        return isinstance(self._sheet, StampSheet)

    @property
    def on_custom(self) -> bool:
        """Whether the canvas shows the custom tiles' sheet."""
        return self._sheet is self._custom

    @property
    def custom_ready(self) -> bool:
        """Whether the custom tiles' sheet can be shown at all: the
        cartridge carries the feature and the project's container was
        read."""
        return self._custom.shown

    @property
    def custom_edited(self) -> bool:
        """Whether the custom tiles differ from their last save -- asked
        about apart from the tables, since they are saved apart."""
        return self._custom.edited

    @property
    def ready(self) -> bool:
        return self._sheet.ready

    @property
    def document(self) -> object:
        return self._sheet.document

    @property
    def edited(self) -> bool:
        """Whether the sheet on the canvas differs from its last save."""
        return self._sheet.edited

    @property
    def tables_edited(self) -> bool:
        """Whether the Map16 tables differ from their last save -- what
        leaving the environment asks about; a stamp sheet's edits are the
        world map's and asked about with it."""
        return self._tables.edited

    @property
    def can_undo(self) -> bool:
        return self.ready and self._sheet.can_undo

    @property
    def can_redo(self) -> bool:
        return self.ready and self._sheet.can_redo

    @property
    def tables(self) -> Map16Tables | None:
        return self._tables.tables

    @property
    def history(self):  # noqa: ANN201 - the tables' own stack
        return self._tables.history

    @property
    def tileset(self) -> int:
        return self._tables.tileset

    @property
    def castle(self) -> str:
        return self._tables.castle

    def raw_of(self, tile: int) -> bytes:
        return self._tables.raw_of(tile)

    def word_of(self, cell: Cell) -> int:
        return self._sheet.word(self.document, cell)

    # -- lifecycle -------------------------------------------------------------

    def show(
        self,
        tables: Map16Tables,
        snapshot_for: Callable[[int], LevelSnapshot | None],
        tileset: int,
        container: bytes | None = None,
    ) -> None:
        """Stand the mode up over ``tables``, drawing with what
        ``snapshot_for`` answers per tileset. One document per project: a
        second entry reuses :meth:`activate` instead. ``container`` is the
        project's custom tiles where the cartridge carries the feature, and
        ``None`` greys that sheet."""
        self._snapshot_for = snapshot_for
        self._tables.show(tables, snapshot_for, tileset)
        if container is None:
            self._custom.forget()
        else:
            self._custom.show(container, snapshot_for, self._tables.tileset)
        self._sheet = self._tables
        self._sheet_index = self._tables.tileset
        self.selection = frozenset()
        self.grain = Grain.TILES
        self._forget_gestures()
        self._picker_cache.clear()
        self.activate()

    def forget(self) -> None:
        """Drop everything: the project is going, or already gone."""
        self._snapshot_for = None
        self._tables.forget()
        self._custom.forget()
        self._sheet = self._tables
        self._sheet_index = 0
        self.selection = frozenset()
        self.clipboard = None
        self._forget_gestures()
        self._picker_cache.clear()
        self._dock.set_picker(QImage())

    def drop_world(self) -> None:
        """The world map went: a stamp sheet on the canvas has nothing left
        to draw, so the tables come back."""
        if self.on_stamps:
            self.set_sheet(self._tables.tileset)

    def _forget_gestures(self) -> None:
        self._marquee = None
        self._stamp_grab = None
        self._cursor = None
        self._placing = None
        self._placing_at = None
        self._placing_image = None
        self._stroke = None
        self._dock.disarm()
        self._view.set_hover_cursor(None)

    def _capture_changed(self, offers: bool = True) -> bool:
        """Re-read the capture and redraw everything drawn from it, saying
        whether there was one to read.

        **Three pictures come out of the capture, not one**, and they move
        together whenever it does: the sheet, the VRAM picker's 1024 chars,
        and the armed tool's follow-the-pointer ghost. Every path that
        changes the capture -- entering the mode, a palette edit, another
        sheet -- goes through here, so a new one cannot redraw the sheet and
        leave the other two showing the capture before it.

        ``offers`` off holds the picker back, for a picker drag's frames:
        the 1024-char sheet is the expensive half and nobody is looking at
        it mid-drag.
        """
        if not self._sheet.capture():
            return False
        self._canvas.set_image(self._sheet.render(self._showing()))
        if offers:
            self._picker_cache.clear()
            self._repaint_picker(self._dock.attributes)
        if self._placing is not None:
            self._placing_image = self._payload_image(self._placing)
        return True

    def activate(self) -> None:
        """Put the sheet on the canvas -- entering the mode, or coming back
        to it with the document as it was left."""
        if self.on_stamps and self._world is not None:
            self._world.lend_canvas()
        if not self._capture_changed():
            return
        # No screen grid: the lattice View > Grid draws (key G) is the one
        # grid over the artwork.
        self._canvas.set_screen_size(QSize(), labels=False)
        self._canvas.set_screen_notes({})
        self._refresh_marks()
        self._describe_selection()

    def recolour(self, offers: bool = True) -> None:
        """The palette document moved: redraw the sheet in the new colours.
        The document, the selection and the hand all stay."""
        if self.ready and self._capture_changed(offers):
            self._refresh_marks()

    def set_sheet(self, index: int) -> bool:
        """The Sheet box picked a row: a tileset's view of the tables, or a
        stamp sheet. The selection goes down -- its keys count in the sheet
        being left -- and so does the tool; the clipboard travels, since a
        word is a word on every sheet. Says whether the row could be shown."""
        if index in self._stamp_sheets:
            wanted: Sheet = self._stamp_sheets[index]
            if not wanted.ready:
                self._status(NO_WORLD_MAP)
                self._changed()
                return False
        elif index == SHEET_CUSTOM:
            wanted = self._custom
            if not self._custom.shown:
                self._status(NO_CUSTOM_TILES)
                self._changed()
                return False
            # Drawn with the tileset the tables were last shown in.
            self._custom.set_tileset(self._tables.tileset)
        elif 0 <= index < TILESET_COUNT:
            wanted = self._tables
            self._tables.set_tileset(index)
        else:
            return False
        if wanted is self._sheet and index == self._sheet_index:
            return True
        self.stop_placing()
        self._sheet = wanted
        self._sheet_index = index
        self.selection = frozenset()
        self._marquee = None
        self._picker_cache.clear()
        self.activate()
        self._changed()
        return True

    def set_tileset(self, tileset: int) -> None:
        """Show ``tileset``'s tables: the same document, resolved through
        another tileset's files."""
        if 0 <= tileset < TILESET_COUNT and self.ready:
            self.set_sheet(tileset)

    def set_grain(self, index: int) -> None:
        """The Editing box picked a grain: gestures now address that grid.
        The selection goes down -- its keys count in the other grid."""
        grain = GRAINS[index] if 0 <= index < len(GRAINS) else Grain.TILES
        if grain is self.grain or not self.ready:
            return
        self.grain = grain
        self.selection = frozenset()
        self._marquee = None
        self._placing_at = None
        self._refresh_marks()
        self._describe_selection()
        self._changed()

    @property
    def edit_rows(self) -> tuple[str, str]:
        """What the Editing box's two rows are called for this sheet."""
        return edit_rows_for(self._sheet.noun, self._sheet.side)

    # -- geometry --------------------------------------------------------------

    def _unit(self) -> int:
        """Cells to the grain's unit."""
        return self._sheet.side if self.grain is Grain.TILES else 1

    def _unit_at(self, point: QPoint, clamp: bool = False) -> tuple[int, int] | None:
        """The grain's unit under ``point`` -- or the nearest one, clamped
        into the sheet, for a drag that ran off it."""
        side = self._unit() * TILE
        ux, uy = point.x() // side, point.y() // side
        across = self._sheet.columns // self._unit()
        down = self._sheet.rows // self._unit()
        if clamp:
            return max(0, min(ux, across - 1)), max(0, min(uy, down - 1))
        if 0 <= ux < across and 0 <= uy < down:
            return ux, uy
        return None

    def _key_of_unit(self, unit: tuple[int, int]) -> int:
        ux, uy = unit
        if self.grain is Grain.TILES:
            return uy * self._sheet.across + ux
        return uy * self._sheet.columns + ux

    def _unit_of_key(self, key: int) -> tuple[int, int]:
        across = (
            self._sheet.across if self.grain is Grain.TILES else self._sheet.columns
        )
        return key % across, key // across

    def _key_of(self, point: QPoint) -> int | None:
        unit = self._unit_at(point)
        return None if unit is None else self._key_of_unit(unit)

    def _cells_of_key(self, key: int) -> list[Cell]:
        if self.grain is Grain.TILES:
            return self._sheet.block_cells(key)
        return [self._sheet.cell_of(key)]

    def _key_rect(self, key: int) -> QRect:
        ux, uy = self._unit_of_key(key)
        side = self._unit() * TILE
        return QRect(ux * side, uy * side, side, side)

    def _selection_cells(self) -> frozenset[Cell]:
        return frozenset(
            cell for key in self.selection for cell in self._cells_of_key(key)
        )

    def _selection_rect(self) -> QRect | None:
        if not self.selection:
            return None
        rects = [self._key_rect(key) for key in self.selection]
        bounding = rects[0]
        for rect in rects[1:]:
            bounding = bounding.united(rect)
        return bounding

    # -- painting --------------------------------------------------------------

    def _showing(self) -> object:
        """What the picture should draw: a stroke's working copy, or the
        document."""
        return self._stroke if self._stroke is not None else self.document

    def _repaint(self) -> None:
        """Bring the picture up to date with what should be drawn -- the
        sheet patches the cells that moved.

        The VRAM picker and the armed tool's ghost are left alone: they
        draw from the capture and never from the words moving here.
        :meth:`_capture_changed` is where they go stale, and the one place
        that redraws them.
        """
        if not self.ready:
            return
        self._canvas.set_image(self._sheet.patch(self._showing()))

    def _repaint_picker(self, attributes: int) -> None:
        """Draw the picker under ``attributes`` -- the palette row and the
        flips the dock is arming, as a word with char zero."""
        if not self.ready:
            return
        # The animated tiles are the level's: the world map has no animator
        # over its sheets' VRAM.
        self._dock.set_picker(
            self._picker_cache.image(self._sheet.viewed(), attributes),
            frozenset() if self.on_stamps else ANIMATED_CHARS,
        )

    # -- marks -----------------------------------------------------------------

    def _refresh_marks(self) -> None:
        self._canvas.set_overlays(self._overlays())

    def _overlays(self) -> list[Overlay]:
        marks: list[Overlay] = list(self._sheet.overlays())
        held = self._selection_rect()
        if held is not None:
            # The selection's ants, as on every canvas: one rectangle,
            # since a selection here is always one.
            marks.append(Overlay(held, SELECTION_LINE))
            marks.append(Overlay(held, SELECTION_DASH, dash=DASH_LENGTH))
        if self._stamp_grab is not None:
            box = snapped_box(*self._stamp_grab, self._unit() * TILE)
            marks.append(Overlay(box, SELECTION_LINE))
            marks.append(Overlay(box, PLACING_COLOR, dash=DASH_LENGTH))
        # The marquee draws no box of its own: it snaps to the grain and
        # selects as it sweeps, so the ants above are already its outline --
        # a blue rectangle over them would be one statement drawn twice.
        if self._placing is not None and self._placing_at is not None:
            box = self._ghost_rect()
            marks.append(
                Overlay(
                    box,
                    SELECTION_LINE,
                    image=self._placing_image,
                    opacity=PLACING_OPACITY,
                )
            )
            marks.append(Overlay(box, PLACING_COLOR, dash=DASH_LENGTH))
        return marks

    def _ghost_rect(self) -> QRect:
        placing, at = self._placing, self._placing_at
        assert placing is not None and at is not None
        width, height = self._payload_size(placing)
        return QRect(at[0] * TILE, at[1] * TILE, width * TILE, height * TILE)

    @staticmethod
    def _payload_size(payload: Payload) -> tuple[int, int]:
        if isinstance(payload, GridStamp):
            return payload.width, payload.height
        return 1, 1

    # -- the hand --------------------------------------------------------------

    def _armed(self, payload: object) -> None:
        """Take ``payload`` in hand -- from the dock's picker, or picked up
        off the sheet. A char picked in the dock is a cell, so the grain
        follows it; something picked up lands at the grain it was taken at."""
        if not self.ready or not isinstance(payload, (Layer2Word, GridStamp)):
            return
        self._placing = payload
        self._placing_image = self._payload_image(payload)
        if not self._picking and self.grain is not Grain.CELLS:
            self.grain = Grain.CELLS
        self._placing_at = None
        self.selection = frozenset()
        self._marquee = None
        self._view.set_hover_cursor(Qt.CursorShape.CrossCursor)
        if self._cursor is not None:
            self._offer_at(self._cursor)
        self._refresh_marks()
        self._describe_selection()
        self._changed()

    def _rearmed(self, payload: object) -> None:
        """The dock's controls moved what is in hand: the same tool, in new
        attributes -- the ghost follows, the grain and the selection stay."""
        if self._placing is None or not isinstance(payload, (Layer2Word, GridStamp)):
            return
        self._placing = payload
        self._placing_image = self._payload_image(payload)
        self._refresh_marks()

    def _payload_image(self, payload: Payload) -> QImage:
        blocks = Blocks(self._sheet.viewed())
        if isinstance(payload, Layer2Word):
            rows = blocks.tile_rows(payload.word)
            return raster_to_image(Raster(TILE, TILE, b"".join(rows)))
        image = QImage(
            payload.width * TILE,
            payload.height * TILE,
            QImage.Format.Format_ARGB32_Premultiplied,
        )
        image.fill(Qt.GlobalColor.transparent)
        painter = QPainter(image)
        for dx, dy, leaf in payload.entries:
            assert isinstance(leaf, Layer2Word)
            rows = blocks.tile_rows(leaf.word)
            painter.drawImage(
                QRect(dx * TILE, dy * TILE, TILE, TILE),
                raster_to_image(Raster(TILE, TILE, b"".join(rows))),
            )
        painter.end()
        return image

    @property
    def armed(self) -> bool:
        """Whether a word or a stamp is in hand."""
        return self._placing is not None

    def stop_placing(self) -> None:
        """Put down what is in hand, if anything. Every caller means "the
        gesture is over"."""
        if self._stroke is not None:
            # A stroke abandoned mid-drag: the cells painted for feedback
            # belong to a document that will never be committed.
            self._stroke = None
            self._repaint()
        if self._placing is None:
            return
        self._placing = None
        self._placing_at = None
        self._placing_image = None
        self._dock.disarm()
        self._view.set_hover_cursor(None)
        self._refresh_marks()

    def escape(self) -> bool:
        """Esc: the tool down first, then the selection -- reporting whether
        the press meant anything."""
        if not self.ready:
            return False
        if self._placing is not None or self._stroke is not None:
            self.stop_placing()
            return True
        if self.selection:
            self._select(frozenset())
            return True
        return False

    # -- selection -------------------------------------------------------------

    def _select(self, keys: frozenset[int]) -> None:
        if keys == self.selection:
            return
        self.selection = keys
        self._refresh_marks()
        self._describe_selection()
        self._changed()

    def _describe_selection(self) -> None:
        if not self.ready or not self.selection:
            self._properties.show_nothing(NOTHING_SELECTED)
            return
        if self.grain is Grain.TILES:
            heading, fields, record = self._sheet.entry(
                self.document, frozenset(), self.selection
            )
        else:
            heading, fields, record = self._sheet.entry(
                self.document, self._selection_cells(), frozenset()
            )
        self._properties.show_fields(heading, fields, record)

    def _say_selected(self) -> None:
        held = self._selection_rect()
        if held is None:
            return
        side = self._unit() * TILE
        across, down = held.width() // side, held.height() // side
        noun = self._sheet.noun if self.grain is Grain.TILES else "cell"
        count = across * down
        self._status(
            f"Selected {across}x{down} {noun}s from "
            f"{hexspot(held.left() // side, held.top() // side)} "
            f"({count} {noun}{'' if count == 1 else 's'})"
        )

    def commit_field(self, key: str, value: int) -> None:
        """The properties panel edited ``key``: apply it to the selection,
        with the level editor's no-op discipline."""
        if not self.ready or not self.selection:
            return
        if self.grain is Grain.TILES:
            _heading, fields, record = self._sheet.entry(
                self.document, frozenset(), self.selection
            )
        else:
            _heading, fields, record = self._sheet.entry(
                self.document, self._selection_cells(), frozenset()
            )
        field = next((found for found in fields if found.key == key), None)
        if field is None:
            return
        edited = field.applied(record, value)
        if edited is not record:
            self._commit(self._sheet.document_of(edited))
        self._describe_selection()

    # -- committing ------------------------------------------------------------

    def _commit(self, document: object) -> bool:
        """Make ``document`` the present, repainting what moved."""
        if not self._sheet.commit(document):
            return False
        self._repaint()
        self._changed()
        return True

    def undo(self) -> None:
        self._walk(back=True)

    def redo(self) -> None:
        self._walk(back=False)

    def _walk(self, back: bool) -> None:
        if not self.ready:
            return
        self.stop_placing()
        took = self._sheet.undo() if back else self._sheet.redo()
        if not took:
            return
        self._repaint()
        self._refresh_marks()
        self._describe_selection()
        self._changed()

    def saved(self) -> None:
        """A save wrote the Map16 tables: the dirty measure moves, the stack
        stays -- and the project's tables now hold what the document does.
        A stamp sheet's save is the world map's, and says so there."""
        self._tables.saved()
        self._changed()

    def custom_saved(self) -> None:
        """A save wrote the custom tiles: the same, for that document."""
        self._custom.saved()
        self._changed()

    @property
    def held_container(self) -> bytes | None:
        """The custom tiles as the document holds them, or ``None`` where
        the sheet was never shown -- what a preview and a test run have to
        agree with, saved or not."""
        return self._custom.document if self._custom.shown else None

    def show_custom(self, container: bytes) -> None:
        """Put ``container`` under the custom tiles' sheet afresh -- a
        revert's re-read -- with its history and the hand dropped."""
        if self._snapshot_for is None:
            return
        self.stop_placing()
        self._custom.show(container, self._snapshot_for, self._tables.tileset)
        if self.on_custom:
            self.selection = frozenset()
            self.activate()
        self._changed()

    @property
    def held_tables(self) -> Map16Tables | None:
        """The tables with the document written into them, or ``None`` where
        the environment was never opened -- what a preview and a test run
        have to agree with, saved or not."""
        return self._tables.held_tables

    def write_tables(self) -> Map16Tables:
        """The project's tables with the document written into them -- what
        a save hands to :meth:`Project.save_map16`."""
        tables = self.held_tables
        assert tables is not None
        return tables

    # -- gestures --------------------------------------------------------------

    def clicked(self, point: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        if not self.ready:
            return
        if modifiers & Qt.KeyboardModifier.AltModifier:
            # The keyboard spelling of the right button.
            self.pick_up(point)
            return
        if self._placing is not None:
            self._place(point)
            return
        key = self._key_of(point)
        self._select(frozenset() if key is None else frozenset({key}))
        self._say_selected()

    def clicked_away(self, modifiers: Qt.KeyboardModifier) -> None:
        del modifiers
        self._select(frozenset())

    def drag_begun(self, point: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        if not self.ready:
            return
        if modifiers & Qt.KeyboardModifier.AltModifier:
            return
        if self._placing is not None:
            # A stroke: paint everything the drag crosses, on a working
            # copy; the document commits whole when the button comes up.
            self._stroke = self.document
            self._paint(point)
            return
        anchor = self._unit_at(point, clamp=True)
        assert anchor is not None
        self._marquee = (anchor, anchor)
        self._select(self._boxed())

    def drag_moved(self, point: QPoint) -> None:
        if self._stroke is not None:
            self._paint(point)
            return
        if self._marquee is None:
            return
        current = self._unit_at(point, clamp=True)
        assert current is not None
        self._marquee = (self._marquee[0], current)
        self._select(self._boxed())
        self._refresh_marks()

    def drag_ended(self, point: QPoint) -> None:
        if self._stroke is not None:
            self._paint(point)
            stroke, self._stroke = self._stroke, None
            # The feedback painted the picture already; the commit is what
            # makes it the document's answer, one step for the whole stroke.
            self._commit(stroke)
            return
        if self._marquee is None:
            return
        self.drag_moved(point)
        self._marquee = None
        self._refresh_marks()
        self._say_selected()

    def cursor_moved(self, point: QPoint) -> None:
        self._cursor = QPoint(point)
        if not self.ready:
            return
        cell = (point.x() // TILE, point.y() // TILE)
        if not self._sheet.holds(cell):
            self.cursor_left()
            return
        self._status(self._sheet.note(self.document, cell))
        if self._placing is not None:
            self._offer_at(point)

    def _offer_at(self, point: QPoint) -> None:
        """Move the ghost to where a click would land the hand."""
        landing = self._landing(point)
        if landing != self._placing_at:
            self._placing_at = landing
            self._refresh_marks()

    def cursor_left(self) -> None:
        self._cursor = None
        self._status("")
        if self._placing_at is not None:
            self._placing_at = None
            self._refresh_marks()

    def right_clicked(self, point: QPoint | None) -> None:
        """The eyedropper: pick up what is under the pointer, and put the
        hand down where there is nothing to pick."""
        if not self.ready:
            return
        if point is not None and self.pick_up(point):
            return
        self.stop_placing()

    def pick_up(self, point: QPoint) -> bool:
        """Arm what is under the pointer, at the grain in force: a cell's
        word, or a whole tile as a block of its cells -- into the dock, so
        its controls show what is held."""
        key = self._key_of(point)
        if key is None:
            return False
        self._picking = True
        try:
            self._dock.pickup(self._payload_of_key(key))
        finally:
            self._picking = False
        return True

    def _payload_of_key(self, key: int) -> Payload:
        cells = self._cells_of_key(key)
        if len(cells) == 1:
            return Layer2Word(self.word_of(cells[0]))
        left = min(cx for cx, _ in cells)
        top = min(cy for _, cy in cells)
        side = self._unit()
        return GridStamp(
            tuple(
                (cx - left, cy - top, Layer2Word(self.word_of((cx, cy))))
                for cx, cy in cells
            ),
            side,
            side,
        )

    def right_drag_begun(self, point: QPoint) -> None:
        if not self.ready:
            return
        self._stamp_grab = (QPoint(point), QPoint(point))
        self._refresh_marks()

    def right_drag_moved(self, point: QPoint) -> None:
        if self._stamp_grab is None:
            return
        self._stamp_grab = (self._stamp_grab[0], QPoint(point))
        self._refresh_marks()

    def right_drag_ended(self, point: QPoint) -> None:
        if self._stamp_grab is None:
            return
        start, _ = self._stamp_grab
        self._stamp_grab = None
        self._refresh_marks()
        # Grabbed at the cell grain whatever the Editing box says, over the
        # box of whole units the drag swept: a region of tiles is their
        # cells, and a stamp lands by its cells.
        snapped = snapped_box(start, point, self._unit() * TILE)

        def payload_at(x: int, y: int) -> object | None:
            if not self._sheet.holds((x, y)):
                return None
            return Layer2Word(self.word_of((x, y)))

        grab_stamp(snapped, TILE, payload_at, self.pick_up, self._grabbed)

    def _grabbed(self, stamp: GridStamp) -> None:
        self._picking = True
        try:
            self._dock.pickup(stamp)
        finally:
            self._picking = False

    # -- placement -------------------------------------------------------------

    def _landing(self, point: QPoint) -> Cell | None:
        """The cell the hand's top-left corner lands on for ``point``: the
        grain's unit under the pointer."""
        unit = self._unit_at(point)
        if unit is None:
            return None
        return unit[0] * self._unit(), unit[1] * self._unit()

    def _place(self, point: QPoint) -> None:
        placed = self._applied(self.document, point)
        if placed is not None:
            self._commit(placed)

    def _paint(self, point: QPoint) -> None:
        assert self._stroke is not None
        painted = self._applied(self._stroke, point)
        if painted is None or painted is self._stroke:
            return
        self._stroke = painted
        self._repaint()

    def _applied(self, to: object, point: QPoint) -> object | None:
        placing = self._placing
        assert placing is not None
        at = self._landing(point)
        if at is None:
            return None
        words: dict[Cell, int] = {}
        if isinstance(placing, Layer2Word):
            words[at] = placing.word
        else:
            for dx, dy, leaf in placing.entries:
                cell = (at[0] + dx, at[1] + dy)
                assert isinstance(leaf, Layer2Word)
                if self._sheet.holds(cell):
                    words[cell] = leaf.word
        if not words:
            return None
        return self._sheet.with_words(to, words)

    # -- the marquee -----------------------------------------------------------

    def _boxed(self) -> frozenset[int]:
        assert self._marquee is not None
        (ax, ay), (bx, by) = self._marquee
        return frozenset(
            self._key_of_unit((ux, uy))
            for uy in range(min(ay, by), max(ay, by) + 1)
            for ux in range(min(ax, bx), max(ax, bx) + 1)
        )

    # -- transforms ------------------------------------------------------------

    def flip(self, x: bool = False, y: bool = False, mirror: bool = False) -> None:
        """H / V: flip each held word in place; with ``mirror``, the
        selection as one picture. A hand is flipped rather than the
        selection while there is one."""
        if not self.ready:
            return
        if self._placing is not None:
            flipped = mirrored(self._placing, x=x, y=y)
            if not mirror and isinstance(flipped, GridStamp):
                # In place: the words stay where they are.
                flipped = GridStamp(
                    tuple(
                        (dx, dy, leaf)
                        for (dx, dy, _), (_, _, leaf) in zip(
                            self._placing.entries, flipped.entries, strict=True
                        )
                    ),
                    flipped.width,
                    flipped.height,
                )
            self._picking = True
            try:
                self._dock.pickup(flipped)
            finally:
                self._picking = False
            return
        cells = self._selection_cells()
        if not cells:
            return
        words = {cell: self.word_of(cell) for cell in cells}
        changed = (
            mirrored_words(words, x=x, y=y)
            if mirror
            else flipped_words(words, x=x, y=y)
        )
        self._commit(self._sheet.with_words(self.document, changed))
        self._describe_selection()

    # -- the clipboard ---------------------------------------------------------

    @property
    def can_copy(self) -> bool:
        return self.ready and bool(self.selection)

    @property
    def can_paste(self) -> bool:
        return self.ready and self.clipboard is not None

    def copy_selection(self) -> None:
        if not self.can_copy:
            return
        cells = self._selection_cells()
        entries, origin = relative(
            (cx, cy, self.word_of((cx, cy))) for cx, cy in sorted(cells)
        )
        self.clipboard = Map16Clipboard(
            entries, origin, blocks=self.grain is Grain.TILES
        )
        count = len(self.selection)
        noun = self._sheet.noun if self.grain is Grain.TILES else "cell"
        self._status(f"Copied {count} {noun}{'' if count == 1 else 's'}")

    def cut_selection(self) -> None:
        if not self.can_copy:
            return
        self.copy_selection()
        self.delete_selection()

    def delete_selection(self) -> None:
        """Blank what is held: the unused definition for Map16 tiles, word
        zero for everything else."""
        if not self.ready or not self.selection:
            return
        blank = self._sheet.blank(self.grain is Grain.TILES)
        self._commit(
            self._sheet.with_words(
                self.document, dict.fromkeys(self._selection_cells(), blank)
            )
        )
        self._describe_selection()

    def paste(self) -> None:
        """Land the clipboard at the selection's corner -- or under the
        pointer, or centred in the view -- as one undo step, and select
        what landed. A copy of tiles lands on whole tiles."""
        if not self.can_paste:
            return
        self.stop_placing()
        held = self.clipboard
        assert held is not None
        grain = Grain.TILES if held.blocks else Grain.CELLS
        if grain is not self.grain:
            self.grain = grain
        unit = self._unit()
        corner = self._selection_rect()
        if corner is not None:
            anchor = (corner.left() // TILE, corner.top() // TILE)
        elif self._cursor is not None:
            landing = self._landing(self._cursor)
            anchor = landing if landing is not None else (0, 0)
        else:
            middle = self._view.looking_at
            width = max(dx for dx, _, _ in held.entries) + 1
            height = max(dy for _, dy, _ in held.entries) + 1
            anchor = (
                max(0, middle.x() // TILE - width // 2),
                max(0, middle.y() // TILE - height // 2),
            )
        # Snapped to the grain's units: a copy of tiles lands on whole tiles
        # wherever the corner was.
        anchor = (anchor[0] // unit * unit, anchor[1] // unit * unit)
        words = {
            (anchor[0] + dx, anchor[1] + dy): word
            for dx, dy, word in held.entries
            if self._sheet.holds((anchor[0] + dx, anchor[1] + dy))
        }
        if not words:
            self._status("Nothing pasted -- the copy fell off the sheet")
            return
        self._commit(self._sheet.with_words(self.document, words))
        # The landed rectangle, in the grain's own keys.
        if grain is Grain.TILES:
            keys = frozenset(self._sheet.block_at(cell) for cell in words)
        else:
            keys = frozenset(self._sheet.cell_index(cell) for cell in words)
        self.selection = keys
        self._refresh_marks()
        self._describe_selection()
        self._changed()
        if len(words) < len(held.entries):
            short = len(held.entries) - len(words)
            self._status(
                f"Only {len(words)} of {len(held.entries)} pasted -- "
                f"{short} fell off the edge"
            )
        else:
            self._say_selected()


__all__ = [
    "GRAINS",
    "NO_WORLD_MAP",
    "Grain",
    "Map16Clipboard",
    "Map16Mode",
]
