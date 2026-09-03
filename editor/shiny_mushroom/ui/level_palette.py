"""The level's tile palette: the Layer 2 background's blocks as a library.

The world map's tile palette's sibling for level mode, under the same
contract: it emits what was picked and does nothing else. No document, no
canvas, no placing -- what a click on the level means belongs to the window,
which owns the level document.

**A page of the create panel rather than a dock of its own.** A level's three
placeable things -- Layer 1's objects, the sprites and the background's blocks
-- are one question asked three ways, so they are three tabs of one panel and
not two panels taking turns in a spot. The tab and the level bar's Editing box
are then two handles on the same choice; which of them the user reached for is
not this widget's business, and picking the Layer 2 tab is what puts the level
in the mode that can place what it offers.

One library today -- the background's own page of 256 Map16 blocks, drawn as
this level would show them -- because the background is the one kind of Layer 2
made of tiles. A Layer 2 *object* level is a second record stream and is placed
from the create panel's catalogue instead, under the same tab and the same
mode; Layer 3 is a stock tilemap the header picks. Neither is a tile to offer
here.
"""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QImage
from PySide6.QtWidgets import (
    QLabel,
    QListWidgetItem,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.tile_clipboard import GridStamp
from shiny_mushroom.ui.lists import TileGrid, add_tile
from shiny_mushroom.ui.tile_palette import OutlinedSelection

#: Thumbnails at twice the block, matching the world map's palette.
ICON = 32

#: Why this page has nothing to offer, on its own hint line. A level whose
#: Layer 2 is an object stream does not see it: the create panel gives that
#: level's Layer 2 tab the object catalogue instead, so this page is only ever
#: shown for a level that has a background -- or for one whose background the
#: editor could not read out of the cartridge, which is what this says.
NO_BACKGROUND = "This level has no Layer 2 background to paint."

#: ...and why the Layer 2 *mode* is not on offer at all, said in one place for
#: the two that say it: the create panel's greyed Layer 2 tab and the status
#: line when the mode is asked for anyway. A level has one kind of Layer 2 or
#: the other, and both are editable, so this is left for the level that has
#: neither -- no cartridge yet, or a Layer 2 the editor could not read.
NO_LAYER2 = "This level has no Layer 2 for the editor to edit."
NOTHING_ARMED = (
    "Pick a tile, then click or drag to paint. "
    "Right-click or Alt+click picks up a tile."
)
ARMED = "Placing tile {number}. Drag paints; Shift keeps it; Esc puts it down."
ARMED_REGION = (
    "Placing a {w}x{h} grabbed region. Click stamps it; a drag paints with "
    "it; Esc puts it down."
)


@dataclass(frozen=True)
class BackgroundTile:
    """A background placement in hand: one Map16 block number, from the
    background's own page."""

    number: int


class LevelPalette(QWidget):
    """Offers the background's blocks. Owns no level."""

    #: The user picked a tile: a :class:`BackgroundTile`.
    armed = Signal(object)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)

        self._held: BackgroundTile | GridStamp | None = None

        self._list = TileGrid(ICON)
        self._list.setItemDelegate(OutlinedSelection(self._list))
        self._list.itemClicked.connect(self._picked)
        # The right button works on the offer as it does on the level: a
        # right click picks exactly as a left one, and a right drag grabs a
        # rectangle of the grid as a stamp.
        self._list.right_picked.connect(self._picked)
        self._list.region_grabbed.connect(self._region_grabbed)
        # Enter means "this one" as well, and arming is idempotent, so the
        # two paths cannot fight over a single row.
        self._list.itemActivated.connect(self._picked)

        self._hint = QLabel()
        self._hint.setWordWrap(True)

        layout = QVBoxLayout(self)
        # No margins of its own: it is a page of the create panel, whose layout
        # has already set the distance from the edge of the dock.
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self._list, 1)
        layout.addWidget(self._hint)
        self._show_state()

    # -- what is on offer ----------------------------------------------------

    def set_tiles(self, images: Sequence[QImage], first: int = 0) -> None:
        """Offer one tile per image, numbered from ``first`` -- the page's
        base, so what is armed is the full Map16 block number. Empty means
        the level has no background to edit."""
        self.disarm()
        self._list.clear()
        for offset, image in enumerate(images):
            number = first + offset
            add_tile(self._list, image, number, f"Tile {hexnum(number)}", size=ICON)
        self._show_state()

    @property
    def count(self) -> int:
        """How many tiles are offered -- the panel's own state, for tests."""
        return self._list.count()

    @property
    def hint(self) -> str:
        """The hint line's text, for tests."""
        return self._hint.text()

    # -- what is in hand -----------------------------------------------------

    @property
    def held(self) -> BackgroundTile | GridStamp | None:
        return self._held

    def arm(self, payload: BackgroundTile | GridStamp | None) -> None:
        """Put ``payload`` in hand, announcing it. Idempotent, so a click and
        Enter on the same row cannot fight. A grabbed region selects no row:
        no one row is what is in hand."""
        if payload == self._held:
            return
        self._held = payload
        self._show_state()
        if payload is not None:
            if isinstance(payload, BackgroundTile):
                self._select_row(payload.number)
            self.armed.emit(payload)

    def disarm(self) -> None:
        """Put the tile down **without announcing it** -- what the window
        calls once a placement has been made or cancelled, when it already
        knows.

        The current row goes with the selection: a list keeps a current item
        that is not selected, and Enter on it means "this one" -- so leaving
        it behind would let a keypress re-arm the tile just put down.
        """
        self._held = None
        self._list.clearSelection()
        self._list.setCurrentItem(None)
        self._show_state()

    def hold(self, payload: BackgroundTile | GridStamp | None) -> None:
        """Put ``payload`` back in hand **without announcing it**, and put the
        selection back on its row.

        :meth:`disarm`'s opposite, and for the same kind of caller: one that
        already knows, so announcing would be telling it what it just said.
        What a **redraw** of the offer uses -- the same tiles in new colours --
        since :meth:`set_tiles` drops the hand, which is right when the offer
        itself changed and wrong when only its pixels did. A grabbed region
        selects no row: no one row is what is in hand.
        """
        self._held = payload
        if isinstance(payload, BackgroundTile):
            self._select_row(payload.number)
        self._show_state()

    def pickup(self, payload: BackgroundTile) -> None:
        """The eyedropper's entry: select the row and arm it, exactly as
        clicking it would."""
        self._select_row(payload.number)
        self.arm(payload)

    def _select_row(self, number: int) -> None:
        for index in range(self._list.count()):
            item = self._list.item(index)
            if item.data(Qt.ItemDataRole.UserRole) == number:
                self._list.setCurrentItem(item)
                self._list.scrollToItem(item)
                return

    def _picked(self, item: QListWidgetItem) -> None:
        self.arm(BackgroundTile(item.data(Qt.ItemDataRole.UserRole)))

    def _region_grabbed(
        self, entries: list[tuple[int, int, int]], width: int, height: int
    ) -> None:
        """A right drag swept a rectangle of the offer: arm it whole, as the
        stamp the same drag would grab off the pattern. A one-cell drag
        never reaches here -- the grid degrades it to a pick."""
        self.arm(
            GridStamp(
                tuple((dx, dy, BackgroundTile(number)) for dx, dy, number in entries),
                width,
                height,
            )
        )

    def _show_state(self) -> None:
        if self._list.count() == 0:
            self._hint.setText(NO_BACKGROUND)
        elif self._held is None:
            self._hint.setText(NOTHING_ARMED)
        elif isinstance(self._held, GridStamp):
            self._hint.setText(
                ARMED_REGION.format(w=self._held.width, h=self._held.height)
            )
        else:
            self._hint.setText(ARMED.format(number=hexnum(self._held.number)))
