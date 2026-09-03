"""The Layer 2 word's attributes, as tool settings.

A ``vhopppcc cccccccc`` entry is a char plus four choices -- a palette row,
the two flips and priority -- and two panels place one: the overworld's tile
palette (:mod:`shiny_mushroom.ui.tile_palette`) and the Map16 editor's chars
dock (:mod:`shiny_mushroom.ui.map16_panel`). Both had written the same four
controls, the same composition of a char and them into a word, the same
round trip back out of a picked word, and the same strip of the arming row's
sixteen colours.

So they are here, in one widget: it holds the choices and says when they
move, and the panel around it decides what a word *means* -- which grid it
lands on, and what a placement of it writes. The widget owns no model.
"""

from __future__ import annotations

from collections.abc import Sequence

from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QCheckBox,
    QHBoxLayout,
    QSpinBox,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.ui.palette_grid import Swatch, SwatchGrid
from shiny_mushroom.ui.tips import wrap_tip

#: Colours in one palette row, and how large each swatch is drawn.
COLORS_PER_ROW = 16
SWATCH_CELL = 12

#: How many palette rows a Layer 2 word can name.
PALETTE_ROWS = 8


def layer2_word_of(
    char: int, palette_row: int, x_flip: bool, y_flip: bool, priority: bool
) -> int:
    """The 16-bit entry these attribute choices spell."""
    return (
        (char & 0x3FF)
        | ((palette_row & 0x07) << 10)
        | (0x2000 if priority else 0)
        | (0x4000 if x_flip else 0)
        | (0x8000 if y_flip else 0)
    )


class Layer2Attributes(QWidget):
    """The four tool settings a Layer 2 placement carries, and the colours
    of the row it places under.

    Checkboxes rather than the properties panel's yes/no combos: these set
    what the next placement will be, they do not edit a record.
    """

    #: A choice moved by hand. The owner re-arms what is held under it.
    changed = Signal()

    #: A colour in the strip was double-clicked: its CGRAM offset. The
    #: Palettes panel is where a colour is changed, and this is the way
    #: through to it -- emitted only where the strip carries offsets.
    colour_activated = Signal(int)

    def __init__(self, row_colours_tip: str, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._palette_row = QSpinBox()
        self._palette_row.setRange(0, PALETTE_ROWS - 1)
        self._palette_row.setPrefix("palette ")
        self._x_flip = QCheckBox("X flip")
        self._y_flip = QCheckBox("Y flip")
        self._priority = QCheckBox("Priority")
        self.set_controls_enabled(False)
        self._palette_row.valueChanged.connect(self.changed)
        self._x_flip.toggled.connect(self.changed)
        self._y_flip.toggled.connect(self.changed)
        self._priority.toggled.connect(self.changed)
        # The strip follows the row without waiting on the owner, so a pick
        # brings its own colours with it however the row was moved.
        self._palette_row.valueChanged.connect(self._show_row_colours)

        # A palette row is a *number* in the control above and a set of
        # colours on the picture, and the strip is what makes the two one
        # thing without a round trip through a redraw.
        self._row_colours = SwatchGrid(COLORS_PER_ROW, cell=SWATCH_CELL)
        self._row_colours.setToolTip(wrap_tip(row_colours_tip))
        self._row_colours.activated.connect(self._colour_activated)
        self._palette_rows: tuple[tuple[Swatch, ...], ...] = ()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(2)
        row = QHBoxLayout()
        row.setContentsMargins(0, 0, 0, 0)
        row.addWidget(self._palette_row)
        row.addWidget(self._x_flip)
        row.addWidget(self._y_flip)
        row.addWidget(self._priority)
        layout.addLayout(row)
        layout.addWidget(self._row_colours, 0, Qt.AlignmentFlag.AlignLeft)

    # -- what is set ----------------------------------------------------------

    @property
    def palette_row(self) -> int:
        return self._palette_row.value()

    def composed(self, char: int) -> int:
        """``char`` under the settings as they stand, as a Layer 2 word."""
        return layer2_word_of(
            char,
            self._palette_row.value(),
            self._x_flip.isChecked(),
            self._y_flip.isChecked(),
            self._priority.isChecked(),
        )

    def show_word(self, word: object) -> None:
        """Set the controls to ``word``'s attributes **without saying so**:
        a pick moves them, and re-arming from them would be the pick again.

        ``word`` is anything answering ``palette_row``, ``x_flip``,
        ``y_flip`` and ``priority`` -- a
        :class:`~shiny_mushroom.ui.tile_palette.Layer2Word`.
        """
        for control, value in (
            (self._palette_row, word.palette_row),
            (self._x_flip, word.x_flip),
            (self._y_flip, word.y_flip),
            (self._priority, word.priority),
        ):
            control.blockSignals(True)
            if isinstance(control, QSpinBox):
                control.setValue(value)
            else:
                control.setChecked(bool(value))
            control.blockSignals(False)
        # The controls were set with their signals blocked, so the strip is
        # moved by hand: a pick has to bring its own row's colours with it.
        self._show_row_colours()

    def set_controls_enabled(self, on: bool) -> None:
        """Arm or grey the four settings. The colour strip is not one of
        them: it says what the row *is*, which is true either way."""
        for control in (self._palette_row, self._x_flip, self._y_flip, self._priority):
            control.setEnabled(on)

    # -- the row's colours ----------------------------------------------------

    def set_palette_rows(self, rows: Sequence[Sequence[Swatch]]) -> None:
        """Offer the colours of each of the palette rows.

        All of them rather than the one on show, because the control moves
        between them and asking the window again per keystroke would be a
        round trip for a slice. Nothing hides the strip.
        """
        self._palette_rows = tuple(tuple(row) for row in rows)
        self._show_row_colours()

    @property
    def palette_rows(self) -> tuple[tuple[Swatch, ...], ...]:
        return self._palette_rows

    def _show_row_colours(self) -> None:
        which = self._palette_row.value()
        held = self._palette_rows[which] if which < len(self._palette_rows) else ()
        self._row_colours.set_swatches(held)
        self._row_colours.setVisible(bool(held))

    def _colour_activated(self, index: int) -> None:
        offset = self._row_colours.swatches[index].offset
        if offset is not None:
            self.colour_activated.emit(offset)


__all__ = [
    "COLORS_PER_ROW",
    "PALETTE_ROWS",
    "SWATCH_CELL",
    "Layer2Attributes",
    "layer2_word_of",
]
