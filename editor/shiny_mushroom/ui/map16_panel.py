"""The Map16 environment's VRAM panel: the sheet's graphics as 8x8 chars,
and what is in hand with its attributes.

The tile palette's sibling for the Map16 environment and the offer dock's
third page (:mod:`shiny_mushroom.ui.offer_dock`), under the same contract:
it emits what was picked and that is all. The picker shows the whole VRAM
under the arming palette row -- the picture is handed in by the
mode, which owns the capture and the render -- and the controls beside it
are the attributes of **what is in hand**: palette row, the two flips,
priority. What is held is a :class:`~shiny_mushroom.ui.tile_palette
.Layer2Word` -- the same 16-bit ``vhopppcc cccccccc`` payload the
overworld's Layer 2 places, because a Map16 quadrant and a stamp sheet
entry *are* that word -- or a :class:`~shiny_mushroom.tile_clipboard
.GridStamp` of them: a whole tile, a block, or a region grabbed by a right
drag over the sheet or over this picker.

**The controls act on the hand.** Moving the palette row or the priority
sets it on every word held; ticking a flip mirrors what is held as a
picture (:mod:`shiny_mushroom.ui.map16_words`), so a block in hand paints
mirrored rather than as four tiles each flipped in its own corner. Picking
something up sets the controls to its attributes first, so the boxes
always read as a description of the hand.
"""

from __future__ import annotations

from collections.abc import Collection, Sequence

from PySide6.QtCore import Signal
from PySide6.QtGui import QImage
from PySide6.QtWidgets import (
    QHBoxLayout,
    QLabel,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level import TILE
from shiny_mushroom.tile_clipboard import GridStamp
from shiny_mushroom.ui.cell_grid import CellGrid
from shiny_mushroom.ui.layer2_attributes import Layer2Attributes
from shiny_mushroom.ui.map16_render import PICKER_COLUMNS, VRAM_TILES
from shiny_mushroom.ui.map16_words import (
    Payload,
    attributes_of,
    mirrored,
    with_palette,
    with_priority,
)
from shiny_mushroom.ui.palette_grid import Swatch
from shiny_mushroom.ui.tile_palette import Layer2Word
from shiny_mushroom.ui.zooming import ZoomedArea, ZoomPicker

#: What the colour strip is for: the arming row as the sheet's own picture
#: draws it -- the level's colours over the Map16 tables, the framed
#: submap's over a stamp sheet.
ROW_COLOURS_TIP = "Colours of the arming palette row, as the sheet draws them."

NO_TABLES = "Open a project and a level to edit its Map16 tables."
NOTHING_ARMED = (
    "Pick an 8x8 char to draw with, or right-click the sheet to pick up "
    "what is there. The controls below set the hand's palette row, flips "
    "and priority."
)
ARMED = (
    "Placing char {what}. Click or drag draws it into the sheet's cells; "
    "Esc puts it down."
)
ARMED_REGION = (
    "Placing a {w}x{h} region. Click stamps it; a drag paints with it; "
    "Esc puts it down."
)


class Map16Panel(QWidget):
    """Offers the VRAM's chars, and holds what is in hand. Owns no model."""

    #: Something was picked, or the hand's attributes moved: put this in
    #: hand. Carries a :class:`Layer2Word` or a :class:`GridStamp` of them.
    armed = Signal(object)

    #: The controls moved what is in hand: the same thing, in new
    #: attributes. Carries the payload. Not :attr:`armed`, which is a fresh
    #: pick: the mode keeps its grain and its ghost's place for this one.
    rearmed = Signal(object)

    #: The arming attributes moved -- the palette row, a flip: the picker
    #: wants repainting under them, so each char shows as a click would lay
    #: it. Carries :attr:`attributes`. The mode answers with
    #: :meth:`set_picker`.
    attributes_moved = Signal(int)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        # The offer dock takes its title from the page it turns to.
        self.setWindowTitle("VRAM")

        self._held: Payload | None = None

        self._zoom = ZoomPicker(zoom=2)
        self._picker = CellGrid(PICKER_COLUMNS, TILE)
        self._picker.setToolTip(
            "The sheet's VRAM as 8x8 chars. Hatched chars are the level's "
            "animated tiles: the game redraws them every frame, so a cell "
            "drawn from one animates."
        )
        self._picker.picked.connect(self._picked)
        self._picker.right_picked.connect(self._picked)
        self._picker.region_grabbed.connect(self._region_grabbed)
        self._area = ZoomedArea(self._picker, self._zoom)

        # The hand's attributes, and the colours of the row it paints under
        # -- the same widget the tile palette places its Layer 2 words with.
        self._attributes = Layer2Attributes(ROW_COLOURS_TIP)
        self._attributes.changed.connect(self._attributes_changed)
        #: The controls as last seen, so a change can say *which* moved: a
        #: flip is a mirror, not a setting, and only a flip that moved
        #: mirrors the hand.
        self._settings = self._read_settings()

        self._hint = QLabel(NO_TABLES)
        self._hint.setWordWrap(True)

        layout = QVBoxLayout(self)
        top = QHBoxLayout()
        top.addStretch(1)
        top.addWidget(QLabel("Zoom "))
        top.addWidget(self._zoom)
        layout.addLayout(top)
        layout.addWidget(self._area, 1)
        layout.addWidget(self._attributes)
        layout.addWidget(self._hint)

    # -- what is on offer ----------------------------------------------------

    def set_picker(self, image: QImage, spoken_for: Collection[int] = ()) -> None:
        """Show ``image`` -- the VRAM under the arming attributes -- keeping
        the picked char picked. Empty clears the offer. ``spoken_for`` are
        the chars no file gives -- a level's animated tiles -- hatched so a
        reader knows a char drawn from one will animate."""
        count = 0 if image.isNull() else VRAM_TILES
        # The grid keeps a selection that still fits, a grabbed region
        # included, so nothing here has to put it back.
        self._picker.set_image(image, count, spoken_for=spoken_for)
        self._attributes.set_controls_enabled(bool(count))
        self._show_state()

    def set_palette_rows(self, rows: Sequence[Sequence[Swatch]]) -> None:
        """Offer the colours of each of the eight palette rows."""
        self._attributes.set_palette_rows(rows)

    @property
    def offering(self) -> bool:
        return self._picker.count > 0

    # -- what is in hand -----------------------------------------------------

    @property
    def held(self) -> Payload | None:
        return self._held

    @property
    def palette_row(self) -> int:
        return self._attributes.palette_row

    @property
    def attributes(self) -> int:
        """What the controls are arming, as a Layer 2 word with char zero:
        the palette row, the flips and the priority."""
        return self._composed(0)

    def arm(self, payload: Payload | None) -> None:
        """Put ``payload`` in hand, announcing it. Idempotent."""
        if payload == self._held:
            return
        self._held = payload
        self._show_state()
        if payload is not None:
            self.armed.emit(payload)

    def disarm(self) -> None:
        """Put down what is in hand **without saying so** -- the mode calls
        this once a placement is cancelled, and already knows."""
        self._held = None
        self._picker.select(-1)
        self._show_state()

    def pickup(self, payload: Payload) -> None:
        """The eyedropper's entry: set the controls to the payload's
        attributes, select its char where it is one, and arm it."""
        self._set_attributes(attributes_of(payload))
        if isinstance(payload, Layer2Word) and 0 <= payload.char < self._picker.count:
            self._picker.select(payload.char)
        else:
            self._picker.select(-1)
        self.arm(payload)

    # -- internals -----------------------------------------------------------

    def _composed(self, char: int) -> int:
        return self._attributes.composed(char)

    def _picked(self, index: int) -> None:
        self.arm(Layer2Word(self._composed(index)))

    def _region_grabbed(
        self, entries: list[tuple[int, int, int]], width: int, height: int
    ) -> None:
        """A right drag swept a rectangle of the chars: arm it whole, each
        char under the controls' attributes. A one-cell drag never reaches
        here -- the grid degrades it to a pick."""
        self.arm(
            GridStamp(
                tuple(
                    (dx, dy, Layer2Word(self._composed(char)))
                    for dx, dy, char in entries
                ),
                width,
                height,
            )
        )

    def _read_settings(self) -> tuple[int, bool, bool, bool]:
        word = Layer2Word(self._composed(0))
        return word.palette_row, word.x_flip, word.y_flip, word.priority

    def _attributes_changed(self) -> None:
        """A control moved by hand: apply the one that moved to the hand,
        and ask for the picker under the new attributes."""
        was, now = self._settings, self._read_settings()
        self._settings = now
        self.attributes_moved.emit(self.attributes)
        held = self._held
        if held is None:
            return
        row, x_flip, y_flip, priority = now
        if row != was[0]:
            held = with_palette(held, row)
        if priority != was[3]:
            held = with_priority(held, priority)
        if x_flip != was[1] or y_flip != was[2]:
            held = mirrored(held, x=x_flip != was[1], y=y_flip != was[2])
        self._held = held
        self._show_state()
        self.rearmed.emit(held)

    def _set_attributes(self, word: Layer2Word) -> None:
        self._attributes.show_word(word)
        self._settings = self._read_settings()
        # The controls moved with their signals blocked; the picker still
        # has to follow them.
        self.attributes_moved.emit(self.attributes)

    def _show_state(self) -> None:
        if not self.offering:
            self._hint.setText(NO_TABLES)
        elif self._held is None:
            self._hint.setText(NOTHING_ARMED)
        elif isinstance(self._held, GridStamp):
            self._hint.setText(
                ARMED_REGION.format(w=self._held.width, h=self._held.height)
            )
        else:
            self._hint.setText(ARMED.format(what=hexnum(self._held.char, 3)))


__all__ = ["Map16Panel"]
