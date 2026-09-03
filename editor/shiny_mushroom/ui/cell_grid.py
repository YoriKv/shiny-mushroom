"""A grid of same-sized cells painted from one image, with a selection ringed.

The Map16 editor's two pickers -- the 512 blocks of a tileset and the 1024
8x8 tiles of a level's VRAM -- are the same widget over a different cell
size: a rectangle painted from a pre-rendered image, magnified whole rather
than a widget per cell, with the panels' two-tone ring on the selection --
one cell, or the rectangle of them a right drag grabbed -- a tint over the
cells a caller marks, a blanking hatch over the ones it calls unused and a
see-through hatch over the ones it calls spoken for -- a level's animated
tiles, which the VRAM holds but no file gives. Painted for
:mod:`shiny_mushroom.ui.palette_grid`'s reason: an item view's column count
follows its width, and sixteen a row is the sheet's shape rather than the
window's.

The widget owns no model. It is handed the image and the marks and hands
back the index that was clicked.
"""

from __future__ import annotations

from collections.abc import Collection

from PySide6.QtCore import QPoint, QRect, Qt, Signal
from PySide6.QtGui import (
    QColor,
    QImage,
    QKeyEvent,
    QMouseEvent,
    QPainter,
    QPaintEvent,
    QRegion,
)
from PySide6.QtWidgets import QWidget

from shiny_mushroom.ui.gestures import RightGrab
from shiny_mushroom.ui.hatching import hatch, hatch_unused
from shiny_mushroom.ui.overlays import PLACING_COLOR
from shiny_mushroom.ui.ring import draw_ring
from shiny_mushroom.ui.zoomed_grid import ZoomedGrid

#: The tint over a marked cell, translucent enough to read the cell through.
MARK_TINT = QColor(80, 160, 255, 70)


class CellGrid(ZoomedGrid):
    """``columns`` cells of ``cell`` source pixels a row, magnified ``zoom``
    times, painted from the image :meth:`set_image` was last handed."""

    #: The selection moved by hand: the new index.
    picked = Signal(int)

    #: A right press was released without travelling: the index under it.
    #: The owner treats it exactly as a left click's pick.
    right_picked = Signal(int)

    #: A right drag grabbed a rectangle of the grid: ``(dx, dy, index)``
    #: entries relative to its top-left cell, and its width and height in
    #: cells -- the same contract :class:`~shiny_mushroom.ui.lists.TileGrid`
    #: keeps, so a palette built on either grid grabs stamps the same way,
    #: the one-cell degrade to :attr:`right_picked` included.
    region_grabbed = Signal(list, int, int)

    def __init__(self, columns: int, cell: int, parent: QWidget | None = None) -> None:
        super().__init__(columns, cell, parent=parent)
        self._image = QImage()
        self._marked: frozenset[int] = frozenset()
        self._unused: frozenset[int] = frozenset()
        self._spoken_for: frozenset[int] = frozenset()
        self._selected = -1
        #: The selection's size in cells: one by one for a picked cell, the
        #: region's for a grabbed one. :attr:`_selected` is its top-left.
        self._extent = (1, 1)
        #: The right button's press and travel. The box it draws is whole
        #: cells, exactly as the selection ring is: a grab is of cells, so
        #: nothing between two of them is worth showing.
        self._grab = RightGrab()
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

    # -- what is shown --------------------------------------------------------

    def set_image(
        self,
        image: QImage,
        count: int,
        *,
        marked: Collection[int] = (),
        unused: Collection[int] = (),
        spoken_for: Collection[int] = (),
    ) -> None:
        """Show ``image`` -- ``count`` cells of it, laid out as this grid is --
        tinting ``marked`` cells, blanking ``unused`` ones and ruling
        ``spoken_for`` ones with the *not yours to change* hatch, the picture
        still readable under it."""
        self._image = image
        self._count = count
        self._marked = frozenset(marked)
        self._unused = frozenset(unused)
        self._spoken_for = frozenset(spoken_for)
        if self._selected >= 0 and self._selection_last() >= count:
            self._selected, self._extent = -1, (1, 1)
        self._resized()

    @property
    def marked(self) -> frozenset[int]:
        return self._marked

    @property
    def unused(self) -> frozenset[int]:
        return self._unused

    @property
    def spoken_for(self) -> frozenset[int]:
        return self._spoken_for

    # -- the selection --------------------------------------------------------

    @property
    def selected(self) -> int:
        """The selected cell -- the top-left one of a selected region -- or
        -1."""
        return self._selected

    @property
    def extent(self) -> tuple[int, int]:
        """The selection's width and height in cells; ``(1, 1)`` for one."""
        return self._extent

    def select(self, index: int) -> None:
        """Move the selection to one cell without announcing it -- what a
        caller pushing state does; :attr:`picked` is for a hand on the
        grid."""
        self.select_region(index, 1, 1)

    def select_region(self, index: int, width: int, height: int) -> None:
        """Select the ``width`` x ``height`` cells whose top-left is
        ``index``, without announcing it."""
        if 0 <= index < self._count:
            self._selected, self._extent = index, (max(1, width), max(1, height))
        else:
            self._selected, self._extent = -1, (1, 1)
        self.update()

    def _selection_last(self) -> int:
        """The bottom-right cell of the selection."""
        width, height = self._extent
        return self._selected + (height - 1) * self._columns + width - 1

    def _selection_rect(self) -> QRect | None:
        if not 0 <= self._selected < self._count:
            return None
        return self.rect_of(self._selected).united(self.rect_of(self._selection_last()))

    def _pick(self, index: int) -> None:
        if index == self._selected:
            return
        self.select(index)
        self.picked.emit(self._selected)

    # -- input ----------------------------------------------------------------

    def mousePressEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if event.button() == Qt.MouseButton.LeftButton:
            index = self.index_at(event.position().toPoint())
            if index >= 0:
                self._pick(index)
        elif event.button() == Qt.MouseButton.RightButton:
            # Tracked rather than answered: what the press turned into -- a
            # pick or a region grab -- is only visible at the release.
            self._grab.begin(event.position().toPoint())
            return
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if self._grab.press is None:
            super().mouseMoveEvent(event)
            return
        was_dragging = self._grab.dragging
        if self._grab.move(event.position().toPoint()):
            if not was_dragging:
                # The band replaces what was held, as a box on the canvas
                # does: the ring comes off the old pick the moment the drag
                # is one. Quietly -- what is in hand is the release's to say.
                self.select(-1)
            self.update()

    def mouseReleaseEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if self._grab.press is None or event.button() != Qt.MouseButton.RightButton:
            super().mouseReleaseEvent(event)
            return
        ended = self._grab.end()
        assert ended is not None
        press, box = ended
        self.update()
        if box is None:
            index = self.index_at(press)
            if index >= 0:
                self.right_picked.emit(index)
            return
        self._grab_region(self._snapped(box))

    def _cell_at(self, point: QPoint) -> tuple[int, int]:
        """The column and row under ``point``, clamped into the grid, so a
        drag that ran off it reaches the edge rather than past it."""
        column = (point.x() - self._gutter) // self.scale
        row = point.y() // self.scale
        return (
            max(0, min(column, self._columns - 1)),
            max(0, min(row, self.rows - 1)),
        )

    def _snapped(self, box: QRect) -> QRect:
        """``box`` grown to the whole cells its corners are in, each clamped
        into the grid: a drag that ran off it reaches the edge rather than
        past it."""
        ax, ay = self._cell_at(box.topLeft())
        bx, by = self._cell_at(box.bottomRight())
        return self.rect_of(ay * self._columns + ax).united(
            self.rect_of(by * self._columns + bx)
        )

    def grab_rect(self) -> QRect | None:
        """The whole cells the right drag in flight covers, or ``None``."""
        box = self._grab.box()
        return None if box is None else self._snapped(box)

    def _grab_region(self, box: QRect) -> None:
        """Every cell ``box`` covers, as relative entries -- the grid's own
        arithmetic, so the zoom cannot misplace a cell.

        The box is clamped into the grid first: a drag past an edge grabs
        what it covered, with the offsets and the stamp's size measured over
        the surviving cells alone -- otherwise the entries would sit offset
        from the pointer when placed, or declare a size the stamp does not
        have. The same rule :meth:`TileGrid._region_within` keeps.
        """
        side = self._cell * self._zoom
        rows = -(-self._count // self._columns)
        left = max(box.left() // side, 0)
        top = max(box.top() // side, 0)
        right = min(box.right() // side, self._columns - 1)
        bottom = min(box.bottom() // side, rows - 1)
        entries: list[tuple[int, int, int]] = []
        for dy in range(bottom - top + 1):
            for dx in range(right - left + 1):
                index = (top + dy) * self._columns + (left + dx)
                if 0 <= index < self._count:
                    entries.append((dx, dy, index))
        if not entries:
            return
        if len(entries) == 1:
            # One cell is not a region: the short drag degrades to the pick
            # it started as -- the editor-wide rule, said here rather than
            # by every listener.
            self.right_picked.emit(entries[0][2])
            return
        width = max(dx for dx, _, _ in entries) + 1
        height = max(dy for _, dy, _ in entries) + 1
        # The region stays ringed: what is in hand is these cells, and the
        # grid shows all of them rather than the one last clicked.
        self.select_region(entries[0][2], width, height)
        self.region_grabbed.emit(entries, width, height)

    def keyPressEvent(self, event: QKeyEvent) -> None:  # noqa: N802 - Qt override
        steps = {
            Qt.Key.Key_Left: -1,
            Qt.Key.Key_Right: 1,
            Qt.Key.Key_Up: -self._columns,
            Qt.Key.Key_Down: self._columns,
        }
        by = steps.get(event.key())
        if by is None or self._selected < 0:
            super().keyPressEvent(event)
            return
        moved = self._selected + by
        if 0 <= moved < self._count:
            self._pick(moved)

    # -- painting -------------------------------------------------------------

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.SmoothPixmapTransform, False)
        if not self._image.isNull():
            painter.drawImage(
                QRect(
                    0,
                    0,
                    self._image.width() * self._zoom,
                    self._image.height() * self._zoom,
                ),
                self._image,
            )
        for index in self._marked:
            painter.fillRect(self.rect_of(index), MARK_TINT)
        for index in self._unused:
            hatch_unused(painter, self.rect_of(index), self.palette())
        if self._spoken_for:
            # One region, one pass: the diagonals run on across a run of
            # cells rather than restarting at each, and the mark stays one
            # device pixel wide at every zoom.
            region = QRegion()
            for index in self._spoken_for:
                region = region.united(self.rect_of(index))
            hatch(painter, region)
        held = self._selection_rect()
        if held is not None:
            draw_ring(painter, held)
        band = self.grab_rect()
        if band is not None:
            draw_ring(painter, band, PLACING_COLOR)


__all__ = ["MARK_TINT", "CellGrid"]
