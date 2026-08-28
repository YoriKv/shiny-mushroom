"""The geometry every painted grid in the editor shares.

Four widgets draw a rectangle of equal cells from one pre-rendered image --
the graphics window's tile sheet
(:mod:`~shiny_mushroom.ui.tile_sheet`), the Map16 editor's two pickers
(:mod:`~shiny_mushroom.ui.cell_grid`), the VRAM column
(:mod:`~shiny_mushroom.ui.vram_slots`) and every palette
(:mod:`~shiny_mushroom.ui.palette_grid`) -- and each of them had written the
same two halves for itself:

**The zoom.** A picture magnified by a whole multiple of its own pixels is as
large as its own pixels, so it sizes itself rather than being sized by the
scroll area around it, and every change of zoom has to say so. That is
:class:`ZoomedPicture`: hold the zoom, refuse one below 1, take the size the
hint now asks for, repaint.

**The rows and columns.** Which cell a point is over, where a cell is drawn,
and how large the whole grid comes out -- one arithmetic over a column count,
a cell side and how many cells there are. That is :class:`ZoomedGrid`.

A subclass keeps what is actually its own: what it paints, and what a click
on it means. The widget owns no model in either case
([`architecture`](../../../docs/editor/architecture.md)).
"""

from __future__ import annotations

from PySide6.QtCore import QPoint, QRect, QSize
from PySide6.QtWidgets import QSizePolicy, QWidget


class ZoomedPicture(QWidget):
    """A picture drawn at a whole multiple of its own pixels, sized by itself.

    A subclass answers :meth:`sizeHint` with how large it is at the zoom it is
    at; everything else -- the minimum, the resize on a change, the refusal of
    a zoom below 1 -- follows from that.
    """

    def __init__(self, zoom: int = 1, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._zoom = zoom
        self.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)

    @property
    def zoom(self) -> int:
        return self._zoom

    def set_zoom(self, zoom: int) -> None:
        """Magnify by ``zoom``, a whole multiple of the picture's own pixels."""
        if zoom < 1:
            raise ValueError(f"a zoom is a positive whole number, not {zoom}")
        self._zoom = zoom
        self._resized()

    def _resized(self) -> None:
        """Take the size the hint now asks for.

        Inside a scroll area that does not resize its widget, the widget's own
        size is what scrolls -- and such an area sizes a child once, at
        ``setWidget``, so a picture that only announced a new hint would stay
        the size it was handed empty.
        """
        self.updateGeometry()
        self.resize(self.sizeHint())
        self.update()

    def minimumSizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return self.sizeHint()


class ZoomedGrid(ZoomedPicture):
    """``columns`` cells of ``cell`` source pixels a row, magnified ``zoom``.

    ``gutter`` is room left at the left of every row -- a palette's row
    numbers -- and is in widget pixels, the zoom being the picture's rather
    than the furniture's. How many cells there are is :attr:`count`, which a
    subclass sets as it takes an image.
    """

    def __init__(
        self,
        columns: int = 1,
        cell: int = 1,
        *,
        zoom: int = 1,
        gutter: int = 0,
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(zoom, parent)
        self._columns = max(1, columns)
        self._cell = cell
        self._gutter = gutter
        self._count = 0

    @property
    def columns(self) -> int:
        return self._columns

    @property
    def count(self) -> int:
        """How many cells are on offer."""
        return self._count

    @property
    def rows(self) -> int:
        """How many rows those cells make, the last one part-full."""
        return -(-self._count // self._columns)

    @property
    def scale(self) -> int:
        """A cell's side in widget pixels."""
        return self._cell * self._zoom

    def index_at(self, point: QPoint) -> int:
        """Which cell ``point`` (widget pixels) is over, or ``-1``."""
        x = point.x() - self._gutter
        if x < 0 or point.y() < 0:
            return -1
        column, row = x // self.scale, point.y() // self.scale
        if column >= self._columns:
            return -1
        index = row * self._columns + column
        return index if index < self._count else -1

    def rect_of(self, index: int) -> QRect:
        """Where cell ``index`` is drawn, in widget pixels."""
        row, column = divmod(index, self._columns)
        return QRect(
            self._gutter + column * self.scale, row * self.scale, self.scale, self.scale
        )

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return QSize(self._gutter + self._columns * self.scale, self.rows * self.scale)


__all__ = ["ZoomedGrid", "ZoomedPicture"]
