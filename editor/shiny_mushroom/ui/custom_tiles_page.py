"""The create panel's Custom Tiles page: a Map16 page's blocks as a library,
placed as Lunar Magic's direct-tile objects.

The Layer 2 palette's sibling (:mod:`shiny_mushroom.ui.level_palette`) under
the same contract: it offers blocks drawn as this level shows them, emits
what was picked, and owns nothing. What differs is what a pick *is*: not a
tile to paint into a pattern but a catalogue :class:`~shiny_mushroom.catalog.Entry`
for the object stream -- object ``22`` or ``23`` for a stock tile, ``27``
for a custom one -- so the window arms it exactly as it arms a row of the
object catalogue, and a click places a record the resize keys grow.

**A page picker over the grid**, because the tab offers more than one page:
the stock two, whose tiles the four-byte objects place a byte cheaper, and
the custom pages the cartridge holds. The right button works as it does on
every grid: a right click picks as a left one, and a right drag grabs a
rectangle of the page as one object -- ``27``'s "selection as it is" form
(:func:`~shiny_mushroom.catalog.direct_region`), the Tilemap editor's stamp
gesture with an object as the stamp.

**The grid is exactly sixteen tiles wide**, whatever the dock's width. A
grabbed region is read off the grid as drawn, and object ``27`` places a
rectangle of *consecutive* tile numbers sixteen to a row of the page -- so a
grid that wrapped at any other count would grab a box of tiles the object
cannot name. The list is held at that width, with room for its scrollbar,
and centred where the dock is wider; the thumbnails are the block's own
sixteen pixels at 1.5:1, big enough to read a block by. **The grid's width
is a rule about the grid, not a floor under the dock**: a page that made
the dock refuse to be dragged narrower than its own tab would size the
level editor's whole offer dock from the one tab, so the page clips where
the dock is narrower instead (:meth:`CustomTilesPage.minimumSizeHint`).
"""

from __future__ import annotations

from collections.abc import Mapping, Sequence

from PySide6.QtCore import QSize, Qt, Signal
from PySide6.QtGui import QImage
from PySide6.QtWidgets import (
    QComboBox,
    QHBoxLayout,
    QLabel,
    QListWidgetItem,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.catalog import Entry, direct_region, direct_tile
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.ui.lists import TileGrid, add_tile
from shiny_mushroom.ui.tile_palette import OutlinedSelection
from smw_tools.map16 import PAGE

#: Thumbnails at 1.5:1 with the artwork: a Map16 block is sixteen pixels
#: square, and sixteen of them at twenty-four take a dock a level editor
#: can still work beside.
ICON = 24

#: Tiles to a row of a Map16 page, and so of the grid.
COLUMNS = 16

#: What the hint line says with nothing to offer, nothing in hand, and
#: something in hand.
NO_CUSTOM_TILES = "Load a level to place tiles into it."

#: Why the create panel's Custom Tiles tab is greyed, said where a greyed tab
#: is the only thing to ask. The four direct-tile objects are the feature's own
#: -- the stock two pages are placeable only through them -- so a cartridge
#: without it has nothing this tab could put in a level, not even a page-0 tile.
NO_FEATURE = (
    "This cartridge has no custom tiles: switch the Custom tiles feature on "
    "under Project > Features and rebuild."
)
NOTHING_ARMED = (
    "Pick a tile, then click the level to place it; the arrow keys and the "
    "properties panel grow it. A right drag grabs a rectangle to place whole."
)
ARMED = "Placing {what}. Click places it; Shift keeps it; right-click stops."


class CustomTilesPage(QWidget):
    """Offers a Map16 page's blocks as direct-tile objects. Owns no level."""

    #: The user picked a tile or grabbed a region: a catalogue ``Entry``.
    armed = Signal(object)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        #: Every page on offer, by page number, as one thumbnail per tile.
        self._pages: dict[int, Sequence[QImage]] = {}
        self._held: Entry | None = None

        self._page = QComboBox()
        self._page.setToolTip(
            "Which Map16 page the grid shows: the game's own two, or the "
            "project's custom pages."
        )
        self._page.activated.connect(lambda _index: self._show_page())

        self._list = TileGrid(ICON)
        self._list.setItemDelegate(OutlinedSelection(self._list))
        # Sixteen to a row, always: the region grab reads the drawn grid.
        self._list.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOn)
        # Two pixels of slack: the viewport must hold sixteen and not
        # seventeen, and the frame and scrollbar are the style's own sizes.
        self._list.setFixedWidth(
            COLUMNS * ICON
            + 2
            + 2 * self._list.frameWidth()
            + self._list.verticalScrollBar().sizeHint().width()
        )
        self._list.itemClicked.connect(self._picked)
        self._list.right_picked.connect(self._picked)
        self._list.region_grabbed.connect(self._region_grabbed)
        self._list.itemActivated.connect(self._picked)

        self._hint = QLabel()
        self._hint.setWordWrap(True)

        picker = QWidget()
        row = QHBoxLayout(picker)
        row.setContentsMargins(0, 0, 0, 0)
        row.addWidget(QLabel("Page "))
        row.addWidget(self._page, 1)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(picker)
        layout.addWidget(self._list, 1, Qt.AlignmentFlag.AlignHCenter)
        layout.addWidget(self._hint)
        self._show_state()

    def minimumSizeHint(self) -> QSize:  # noqa: N802 - Qt's name
        """As tall as the page needs and as narrow as the dock likes.

        The grid is held at sixteen tiles, which is wider than the other
        offer pages ask for -- and a fixed width is a minimum as well as a
        maximum, so left alone this one page would set the floor for the
        whole offer dock, tile palette and world map included. The dock is
        one dock; a page clipped at the edges is this tab's problem to have.
        """
        return QSize(0, super().minimumSizeHint().height())

    # -- what is on offer ----------------------------------------------------

    def set_pages(self, pages: Mapping[int, Sequence[QImage]]) -> None:
        """Offer ``pages`` -- page number to one image per tile -- keeping
        the page shown where it is still offered. Empty means there is no
        level to place into."""
        self.disarm()
        shown = self.page
        self._pages = {page: tuple(images) for page, images in sorted(pages.items())}
        self._page.clear()
        for page in self._pages:
            label = f"{hexnum(page)}" + ("" if page >= 2 else "  (game's own)")
            self._page.addItem(label, page)
        if shown in self._pages:
            self._page.setCurrentIndex(list(self._pages).index(shown))
        self._show_page()

    @property
    def page(self) -> int:
        """The page the grid shows, or -1 with nothing offered."""
        data = self._page.currentData()
        return -1 if data is None else int(data)

    def show_page(self, page: int) -> None:
        """Turn the grid to ``page``, where it is offered."""
        if page in self._pages:
            self._page.setCurrentIndex(list(self._pages).index(page))
            self._show_page()

    @property
    def count(self) -> int:
        """How many tiles the grid shows -- the page's own state, for tests."""
        return self._list.count()

    @property
    def hint(self) -> str:
        return self._hint.text()

    def _show_page(self) -> None:
        self.disarm()
        self._list.clear()
        page = self.page
        for offset, image in enumerate(self._pages.get(page, ())):
            number = page * PAGE + offset
            add_tile(
                self._list,
                image,
                number,
                f"Tile {hexnum(number, 3 if number < 0x200 else 4)}",
                size=ICON,
            )
        self._show_state()

    # -- what is in hand -----------------------------------------------------

    @property
    def held(self) -> Entry | None:
        return self._held

    def arm(self, entry: Entry | None) -> None:
        """Put ``entry`` in hand and say so. Idempotent, so a click and Enter
        on the same row cannot fight."""
        if entry is None:
            self.disarm()
            return
        if self._held is not None and self._held == entry:
            return
        self._held = entry
        self._show_state()
        self.armed.emit(entry)

    def pick_up(self, entry: Entry, tile: int) -> None:
        """Turn the grid to ``tile``'s page, highlight it, and arm ``entry``:
        the right button's pick-up of a direct-tile object already in the
        level, arriving where a pick of the same tile by hand would.

        A tile on a page this cartridge does not hold is still armed -- the
        record under the pointer is what was picked up -- and the grid stays
        where it is, having nothing to show for it.
        """
        self.show_page(tile // PAGE)
        if self.page == tile // PAGE:
            self._list.setCurrentRow(tile % PAGE)
        self.arm(entry)

    def disarm(self) -> None:
        """Empty the hand, silently: what the window says when a placement
        put the tool down."""
        self._held = None
        self._list.clearSelection()
        self._show_state()

    def _picked(self, item: QListWidgetItem) -> None:
        number = int(item.data(Qt.ItemDataRole.UserRole))
        self.arm(direct_tile(number))

    def _region_grabbed(
        self, entries: list[tuple[int, int, int]], width: int, height: int
    ) -> None:
        """A right drag swept a rectangle of the page: arm it whole as one
        object, from its top-left tile. Anything past sixteen a side is what
        the form cannot say, and is cut to it."""
        if not entries:
            return
        left = min(dx for dx, _dy, _n in entries)
        top = min(dy for _dx, dy, _n in entries)
        base = next(n for dx, dy, n in entries if dx == left and dy == top)
        self.arm(direct_region(base, min(width, 16), min(height, 16)))

    def _show_state(self) -> None:
        if not self._pages:
            self._hint.setText(NO_CUSTOM_TILES)
        elif self._held is not None:
            self._hint.setText(ARMED.format(what=self._held.name))
        else:
            self._hint.setText(NOTHING_ARMED)


__all__ = [
    "ARMED",
    "COLUMNS",
    "ICON",
    "NOTHING_ARMED",
    "NO_CUSTOM_TILES",
    "NO_FEATURE",
    "CustomTilesPage",
]
