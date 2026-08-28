"""A grid of same-sized cells painted from one image, with one cell selected.

The Map16 editor's two pickers -- the 512 blocks of a tileset and the 1024
8x8 tiles of a level's VRAM -- are the same widget over a different cell
size: a rectangle painted from a pre-rendered image, magnified whole rather
than a widget per cell, with a ring on the selected one, a tint over the
cells a caller marks and a hatch over the ones it calls unused. Painted for
:mod:`shiny_mushroom.ui.palette_grid`'s reason: an item view's column count
follows its width, and sixteen a row is the sheet's shape rather than the
window's.

The widget owns no model. It is handed the image and the marks and hands
back the index that was clicked.
"""

from __future__ import annotations

from collections.abc import Collection

from PySide6.QtCore import QRect, Qt, Signal
from PySide6.QtGui import (
    QColor,
    QImage,
    QKeyEvent,
    QMouseEvent,
    QPainter,
    QPaintEvent,
    QPen,
)
from PySide6.QtWidgets import QWidget

from shiny_mushroom.ui.hatching import hatch_unused
from shiny_mushroom.ui.zoomed_grid import ZoomedGrid

#: The tint over a marked cell, translucent enough to read the cell through.
MARK_TINT = QColor(80, 160, 255, 70)


class CellGrid(ZoomedGrid):
    """``columns`` cells of ``cell`` source pixels a row, magnified ``zoom``
    times, painted from the image :meth:`set_image` was last handed."""

    #: The selection moved by hand: the new index.
    picked = Signal(int)

    def __init__(self, columns: int, cell: int, parent: QWidget | None = None) -> None:
        super().__init__(columns, cell, parent=parent)
        self._image = QImage()
        self._marked: frozenset[int] = frozenset()
        self._unused: frozenset[int] = frozenset()
        self._selected = -1
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

    # -- what is shown --------------------------------------------------------

    def set_image(
        self,
        image: QImage,
        count: int,
        *,
        marked: Collection[int] = (),
        unused: Collection[int] = (),
    ) -> None:
        """Show ``image`` -- ``count`` cells of it, laid out as this grid is --
        tinting ``marked`` cells and hatching ``unused`` ones."""
        self._image = image
        self._count = count
        self._marked = frozenset(marked)
        self._unused = frozenset(unused)
        if self._selected >= count:
            self._selected = -1
        self._resized()

    @property
    def marked(self) -> frozenset[int]:
        return self._marked

    @property
    def unused(self) -> frozenset[int]:
        return self._unused

    # -- the selection --------------------------------------------------------

    @property
    def selected(self) -> int:
        """The selected cell, or -1."""
        return self._selected

    def select(self, index: int) -> None:
        """Move the selection without announcing it -- what a caller pushing
        state does; :attr:`picked` is for a hand on the grid."""
        self._selected = index if 0 <= index < self._count else -1
        self.update()

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
        super().mousePressEvent(event)

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
        if 0 <= self._selected < self._count:
            where = self.rect_of(self._selected)
            # Two rings, light over dark, so the ring reads on any cell.
            painter.setPen(QPen(QColor(0, 0, 0), 1))
            painter.drawRect(where.adjusted(0, 0, -1, -1))
            painter.setPen(QPen(QColor(255, 255, 255), 1))
            painter.drawRect(where.adjusted(1, 1, -2, -2))


__all__ = ["MARK_TINT", "CellGrid"]
