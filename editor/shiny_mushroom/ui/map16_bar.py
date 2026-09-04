"""The Tilemap editor's toolbar: which sheet is on the canvas, and at
which grain a gesture edits it.

The world bar's sibling, under the same contract: it emits what was picked
and that is all. The Sheet box lists the fifteen tilesets' views of the
Map16 tables -- one document, resolved through another tileset's files --
and the world map's two event stamp sheets; the Editing box picks between
the two grids every sheet carries: whole tiles (or blocks), or their 8x8
cells.
"""

from __future__ import annotations

from PySide6.QtCore import Signal
from PySide6.QtWidgets import QComboBox, QLabel, QToolBar, QWidget

from shiny_mushroom.hexnum import hexnum
from smw_tools.map16 import TILESET_TABLES

#: The Sheet box's rows past the tilesets: the custom tiles, then the 2x2
#: stamp sheet, then the 6x6 -- indexes :data:`SHEET_CUSTOM`,
#: :data:`SHEET_2X2` and :data:`SHEET_6X6`.
SHEET_CUSTOM = len(TILESET_TABLES)
CUSTOM_SHEET_NAME = "Custom tiles"
SHEET_2X2 = SHEET_CUSTOM + 1
SHEET_6X6 = SHEET_2X2 + 1
STAMP_SHEETS: tuple[tuple[int, str], ...] = (
    (SHEET_2X2, "Overworld 2x2 stamps"),
    (SHEET_6X6, "Overworld 6x6 stamps"),
)

#: The Editing box's rows, in order: index 0 selects whole tiles, 1 cells.
#: The first row is renamed per sheet (:meth:`Map16Bar.set_edit_rows`) --
#: a stamp sheet's whole unit is a block, and a 6x6 one is not 16x16.
EDIT_ROWS: tuple[str, ...] = ("Tiles (16x16)", "Cells (8x8)")


def edit_rows_for(noun: str, side: int) -> tuple[str, str]:
    """The two Editing rows for a sheet whose whole unit is a ``noun`` of
    ``side`` cells."""
    return (f"{noun.capitalize()}s ({side * 8}x{side * 8})", EDIT_ROWS[1])


class Map16Bar(QToolBar):
    """Picks a sheet to show and a grain to edit at. Owns no tables."""

    #: The user asked for this Sheet row: a tileset (0-14) or a stamp sheet
    #: (:data:`SHEET_2X2`, :data:`SHEET_6X6`).
    sheet_picked = Signal(int)

    #: The user asked to edit at this grain (an index into :data:`EDIT_ROWS`).
    editing_picked = Signal(int)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__("Tilemap", parent)
        self.setObjectName("map16-bar")
        self.setMovable(False)

        self._sheets = QComboBox()
        for tileset, table in enumerate(TILESET_TABLES):
            self._sheets.addItem(f"{hexnum(tileset)} - {table}")
        self._sheets.addItem(CUSTOM_SHEET_NAME)
        for _index, name in STAMP_SHEETS:
            self._sheets.addItem(name)
        self._sheets.setToolTip(
            "Which sheet the canvas shows: one FG/BG tileset's view of the "
            "Map16 tables -- most tiles are shared by every tileset, the "
            "tinted runs are each tileset's own -- the project's custom "
            "tiles, or one of the world map's event stamp sheets."
        )
        # `activated`, not `currentIndexChanged`: the latter also fires when
        # the index is moved from code, and the window moves it to follow
        # the mode.
        self._sheets.activated.connect(self.sheet_picked.emit)

        self._editing = QComboBox()
        for name in EDIT_ROWS:
            self._editing.addItem(name)
        self._editing.setToolTip("Which grain a gesture edits (keys 1-2)")
        self._editing.activated.connect(self.editing_picked.emit)

        for box in (self._sheets, self._editing):
            box.setSizeAdjustPolicy(QComboBox.SizeAdjustPolicy.AdjustToContents)

        self.addWidget(QLabel("Sheet "))
        self.addWidget(self._sheets)
        self.addWidget(QLabel(" Editing "))
        self.addWidget(self._editing)
        # Nothing to show until the mode is up with tables and a capture.
        self.setEnabled(False)

    @property
    def sheet(self) -> int:
        return self._sheets.currentIndex()

    def set_sheet(self, index: int) -> None:
        """Show ``index`` as the sheet on the canvas, without asking for it."""
        if 0 <= index < self._sheets.count():
            self._sheets.setCurrentIndex(index)

    def offer_custom_sheet(self, on: bool) -> None:
        """Arm or grey the custom tiles row: it needs a cartridge built with
        the feature."""
        model = self._sheets.model()
        item = model.item(SHEET_CUSTOM)  # type: ignore[attr-defined]
        if item is not None:
            item.setEnabled(on)

    def offer_stamp_sheets(self, on: bool) -> None:
        """Arm or grey the two stamp sheet rows: they need the world map to
        have been captured."""
        model = self._sheets.model()
        for index, _name in STAMP_SHEETS:
            item = model.item(index)  # type: ignore[attr-defined]
            if item is not None:
                item.setEnabled(on)

    @property
    def editing(self) -> int:
        """The shown Editing row, an index into :data:`EDIT_ROWS`."""
        return self._editing.currentIndex()

    def set_editing(self, index: int) -> None:
        """Show ``index`` as the grain in effect, without asking for it."""
        if 0 <= index < self._editing.count():
            self._editing.setCurrentIndex(index)

    def set_edit_rows(self, names: tuple[str, str]) -> None:
        """Name the two grains for the sheet on the canvas."""
        for index, name in enumerate(names):
            self._editing.setItemText(index, name)


__all__ = [
    "CUSTOM_SHEET_NAME",
    "EDIT_ROWS",
    "SHEET_2X2",
    "SHEET_6X6",
    "SHEET_CUSTOM",
    "STAMP_SHEETS",
    "Map16Bar",
    "edit_rows_for",
]
