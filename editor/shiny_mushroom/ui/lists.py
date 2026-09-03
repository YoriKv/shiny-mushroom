"""List widgets shared across the editor's panels.

One home for behaviour every tile-grid-shaped list wants, so a new panel
gets it by construction rather than by copying. :class:`RowScrollList` is
the ready-made widget and :class:`TileGrid` the grid of pictures every tile
palette in the editor is; :func:`scroll_by_rows` is the same wheel treatment
as a function, for a view that must subclass something else, and
:func:`add_tile` puts one picture in a grid.
"""

from __future__ import annotations

from collections.abc import Callable

from PySide6.QtCore import QRect, QSize, Qt, Signal
from PySide6.QtGui import (
    QIcon,
    QImage,
    QMouseEvent,
    QPainter,
    QPaintEvent,
    QPalette,
    QPixmap,
    QWheelEvent,
)
from PySide6.QtWidgets import QListView, QListWidget, QListWidgetItem

from shiny_mushroom.ui.gestures import RightGrab
from shiny_mushroom.ui.overlays import PLACING_COLOR
from shiny_mushroom.ui.ring import draw_ring


def scroll_by_rows(view: QListView, event: QWheelEvent) -> bool:
    """Scroll ``view`` one row per wheel notch, saying whether it applied.

    Qt scrolls by the device's own pixel delta whenever one is reported --
    a high-resolution wheel creeps a few pixels a notch over a grid
    hundreds of rows tall. The angle delta is the honest notch count, so
    the wheel is translated here: a notch is a row, scaled proportionally
    for smooth-scrolling devices that report fractions of one. The row is
    the grid's height, or the first row's own where there is no grid.

    ``False`` -- a horizontal wheel, or a view with nothing to measure a
    row by -- means the caller should fall back to Qt's own scrolling. The
    view wants ``ScrollPerPixel`` vertical scroll mode, so the translation
    lands where it says.
    """
    notches = event.angleDelta().y()
    row = view.gridSize().height()
    if row <= 0:
        model = view.model()
        if model is not None and model.rowCount():
            row = view.sizeHintForRow(0)
    if notches == 0 or row <= 0:
        return False
    bar = view.verticalScrollBar()
    bar.setValue(bar.value() - notches * row // 120)
    event.accept()
    return True


class RowScrollList(QListWidget):
    """A ``QListWidget`` scrolling one row per wheel notch.

    Vertical scrolling is put in per-pixel mode at construction --
    :func:`scroll_by_rows` needs it to move by exactly the rows it says.
    """

    def __init__(self, parent=None) -> None:  # noqa: ANN001 - QWidget
        super().__init__(parent)
        self.setVerticalScrollMode(QListView.ScrollMode.ScrollPerPixel)

    def wheelEvent(self, event: QWheelEvent) -> None:  # noqa: N802 - Qt override
        if not scroll_by_rows(self, event):
            super().wheelEvent(event)


class TileGrid(RowScrollList):
    """A list laid out as a tight grid of pictures, a cell to a tile.

    Every tile palette in the editor is one of these. IconMode's own layout
    reserves a text line under each icon and margins around it, and these
    items are only their picture -- so the cells are exactly the icon and
    the tiles abut, like the map or the sheet they were cut from. The
    scrollbar's arrows move a row too, matching the wheel.

    The right button works here as it does on the canvas: a right click
    picks the item under the pointer (:attr:`right_picked`, which the owner
    treats exactly as a left click), and a right drag sweeps a rectangle of
    the grid that becomes a stamp (:attr:`region_grabbed`). The grid only
    reports geometry and numbers; what the region *is* -- which payload the
    numbers spell -- belongs to the palette that owns the list.
    """

    #: A right press was released without travelling: the item under it.
    right_picked = Signal(QListWidgetItem)
    #: A right drag grabbed a rectangle of the grid: a list of
    #: ``(dx, dy, number)`` entries relative to its top-left cell, and the
    #: rectangle's width and height in cells. Only emitted while the view is
    #: a grid -- a page laid out as rows has no rectangle to grab -- and only
    #: for a region of more than one cell: a drag that covered exactly one
    #: is not a region, and arrives as :attr:`right_picked` instead, so no
    #: listener has to spell the degrade rule for itself.
    region_grabbed = Signal(list, int, int)

    def __init__(self, size: int, parent=None) -> None:  # noqa: ANN001 - QWidget
        super().__init__(parent)
        self.setViewMode(QListView.ViewMode.IconMode)
        self.setResizeMode(QListView.ResizeMode.Adjust)
        self.setMovement(QListView.Movement.Static)
        self.setUniformItemSizes(True)
        self.setSpacing(0)
        self._grab = RightGrab()
        # The picture is the cell, so the selection is drawn as the panels'
        # ring round it (`ui/ring.py`) rather than as the widget style's
        # fill, which is taken away here.
        colours = self.palette()
        colours.setColor(QPalette.ColorRole.Highlight, Qt.GlobalColor.transparent)
        self.setPalette(colours)
        #: The region a right drag last grabbed, as the first and last item
        #: index it covered: ringed while it is in hand, so the panel shows
        #: all of what was taken rather than the one cell last clicked.
        #: Dropped as soon as the selection moves by any other route.
        self._region: tuple[int, int] | None = None
        self.currentItemChanged.connect(self._drop_region)
        self.itemSelectionChanged.connect(self._drop_region)
        self.set_cell(size)

    def set_cell(self, size: int, *, grid: bool = True) -> None:
        """Lay the view out for icons ``size`` px square.

        With ``grid`` off there is no cell size and the items size themselves,
        which is what a palette wants on a page that reads as rows of named
        things rather than as a grid of pictures.
        """
        self.setIconSize(QSize(size, size))
        self.setGridSize(QSize(size, size) if grid else QSize())
        self.verticalScrollBar().setSingleStep(size)

    # -- the right button ----------------------------------------------------

    def mousePressEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if event.button() == Qt.MouseButton.RightButton:
            # Tracked here rather than handed to Qt: the stock handling
            # would move the selection, and what the press turned into --
            # a pick or a grab -- is only visible at the release.
            self._grab.begin(event.position().toPoint())
            return
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if self._grab.press is None:
            super().mouseMoveEvent(event)
            return
        if not self.gridSize().isValid():
            # A page laid out as rows has no rectangle to grab.
            return
        was_dragging = self._grab.dragging
        if self._grab.move(event.position().toPoint()):
            if not was_dragging:
                # The band replaces what was held, as a box on the canvas
                # does: the ring comes off the old pick the moment the drag
                # is one, so the panel never shows two selections at once.
                self._drop_region()
                super().clearSelection()
            self.viewport().update()

    def mouseReleaseEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if self._grab.press is None or event.button() != Qt.MouseButton.RightButton:
            super().mouseReleaseEvent(event)
            return
        ended = self._grab.end()
        assert ended is not None
        press, box = ended
        self.viewport().update()
        if box is None:
            item = self.itemAt(press)
            if item is not None:
                self.right_picked.emit(item)
            return
        covered = self._covered(box)
        if not covered:
            return
        if len(covered) == 1:
            # One cell is not a region: the short drag degrades to the pick
            # it started as -- the editor-wide rule, said here rather than
            # by every listener.
            self.right_picked.emit(self.item(covered[0]))
            return
        entries, width, height = self._region_of(covered)
        self._region = (covered[0], covered[-1])
        self.region_grabbed.emit(entries, width, height)

    # -- the grabbed region -------------------------------------------------

    def _covered(self, box: QRect) -> list[int]:
        """The items whose cells ``box`` touches, in list order -- measured
        off each item's own visual rectangle, so scrolling and wrapping
        cannot put a number in the wrong cell."""
        if not self.gridSize().isValid():
            return []
        return [
            index
            for index in range(self.count())
            if self.visualItemRect(self.item(index)).intersects(box)
        ]

    def _region_of(
        self, covered: list[int]
    ) -> tuple[list[tuple[int, int, int]], int, int]:
        """``covered`` as relative entries: each item's number at its offset
        in cells from the region's top-left, and the region's size."""
        cell = self.gridSize()
        placed = []
        for index in covered:
            rect = self.visualItemRect(self.item(index))
            number = self.item(index).data(Qt.ItemDataRole.UserRole)
            placed.append((rect.left(), rect.top(), number))
        left = min(x for x, _, _ in placed)
        top = min(y for _, y, _ in placed)
        entries = sorted(
            ((y - top) // cell.height(), (x - left) // cell.width(), number)
            for x, y, number in placed
        )
        width = max(dx for _, dx, _ in entries) + 1
        height = max(dy for dy, _, _ in entries) + 1
        return [(dx, dy, number) for dy, dx, number in entries], width, height

    def _region_within(
        self, box: QRect
    ) -> tuple[list[tuple[int, int, int]], int, int] | None:
        """The grid cells ``box`` covers, as relative entries, or ``None``
        where it covers none."""
        covered = self._covered(box)
        return self._region_of(covered) if covered else None

    def _items_rect(self, first: int, last: int) -> QRect:
        """The cells from item ``first`` to item ``last``, as drawn now."""
        return self.visualItemRect(self.item(first)).united(
            self.visualItemRect(self.item(last))
        )

    def grab_rect(self) -> QRect | None:
        """The whole cells the right drag in flight covers -- the band it
        draws, snapped to the grid as a selection is -- or ``None``."""
        box = self._grab.box()
        if box is None:
            return None
        covered = self._covered(box)
        if not covered:
            return None
        return self._items_rect(covered[0], covered[-1])

    def region_rect(self) -> QRect | None:
        """The region last grabbed, while it is still ringed."""
        if self._region is None:
            return None
        first, last = self._region
        if last >= self.count():
            self._region = None
            return None
        return self._items_rect(first, last)

    def _drop_region(self, *_args: object) -> None:
        if self._region is not None:
            self._region = None
            self.viewport().update()

    def clearSelection(self) -> None:  # noqa: N802 - Qt override
        """The owner put the hand down: the ring goes with the selection,
        which the stock call leaves untouched when nothing was current."""
        self._drop_region()
        super().clearSelection()

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        super().paintEvent(event)
        band = self.grab_rect()
        region = self.region_rect()
        current = self.currentItem()
        held = (
            self.visualItemRect(current)
            if region is None and current is not None and current.isSelected()
            else None
        )
        if band is None and region is None and held is None:
            return
        painter = QPainter(self.viewport())
        if held is not None:
            draw_ring(painter, held)
        if region is not None:
            draw_ring(painter, region)
        if band is not None:
            draw_ring(painter, band, PLACING_COLOR)


def add_tile(
    view: QListWidget,
    image: QImage,
    number: int,
    tooltip: str,
    *,
    size: int,
    text: str = "",
    decorate: Callable[[QImage, int], QImage] | None = None,
) -> QListWidgetItem:
    """Append one tile to ``view`` and hand its item back.

    ``image`` is scaled into a ``size`` square, ``number`` rides along in
    ``UserRole`` -- which is what a click on the row is read back as -- and
    ``tooltip`` is what a hover says.

    ``decorate`` is handed the scaled picture and the number, for a grid that
    draws something of its own over its tiles. After the scale, so its strokes
    land at the weight they are drawn at rather than being magnified with the
    artwork.

    A row with no ``text`` is given a size hint of exactly the icon: the
    default pads it out, which shows as a stripe of background between rows
    that are meant to abut.
    """
    scaled = image.scaled(size, size, Qt.AspectRatioMode.KeepAspectRatio)
    if decorate is not None:
        scaled = decorate(scaled, number)
    item = QListWidgetItem(QIcon(QPixmap.fromImage(scaled)), text)
    if not text:
        item.setSizeHint(QSize(size, size))
    item.setData(Qt.ItemDataRole.UserRole, number)
    item.setToolTip(tooltip)
    view.addItem(item)
    return item
