"""A sheet of tiles, painted: the picture at a zoom, colour 0 hatched where
that is asked for, and the tiles that differ from the shipped file outlined.

Handed an image and paints it, exactly as the canvas is
([`architecture`](../../../docs/editor/architecture.md)): what a tile *is*,
which palette it is drawn under and what an edit means belong to the dialog
that owns the file. That is what lets this be tested by handing it a picture
and reading pixels back, with no project behind it.

The hatch is not painted into the pixels. Colour 0 is drawn as the palette's
colour 0 by :func:`shiny_mushroom.graphics.raster`, and where it sits is a
second, index-valued picture of the same tiles -- so the hatch is a clip
region cut from that picture and a brush
(:func:`shiny_mushroom.ui.hatching.transparent_brush`), rather than a pixel
loop in Python over every sheet redraw.
"""

from __future__ import annotations

from PySide6.QtCore import QPoint, QRect, QSize, Qt, Signal
from PySide6.QtGui import (
    QBitmap,
    QColor,
    QImage,
    QMouseEvent,
    QPainter,
    QPaintEvent,
    QPen,
    QRegion,
    qRgb,
)
from PySide6.QtWidgets import QWidget

from shiny_mushroom.ui.hatching import transparent_brush
from shiny_mushroom.ui.zoomed_grid import ZoomedGrid
from shiny_mushroom.ui.zooming import DEFAULT_ZOOM
from smw_tools.graphics import TILE_SIDE

#: The outline a changed tile wears, and how wide.
CHANGED_PEN = QColor(0xFF, 0x40, 0x40)


class TileSheet(ZoomedGrid):
    """A sheet of tiles at a whole-number zoom. Owns no file."""

    #: The pointer is over a tile: its index, or ``-1`` when over nothing.
    hovered = Signal(int)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(16, TILE_SIDE, zoom=DEFAULT_ZOOM, parent=parent)
        self._image = QImage()
        #: Where colour 0 is, as a region in sheet pixels -- cut once per
        #: sheet and scaled at paint time, or ``None`` for an empty sheet.
        self._zero: QRegion | None = None
        self._changed: frozenset[int] = frozenset()
        #: Whether colour 0 is drawn as the hatch. Off to begin with: a sheet
        #: shows what the game draws, and the hatch is the question "which of
        #: this is transparent?" asked of a sheet already on screen.
        self._hatched = False
        self._hover = -1
        self.setMouseTracking(True)

    # -- what is shown --------------------------------------------------------

    def set_sheet(
        self,
        image: QImage,
        indices: QImage | None,
        columns: int,
        count: int,
        changed: set[int] | frozenset[int] = frozenset(),
    ) -> None:
        """Show ``image`` -- the tiles ``columns`` to a row, ``count`` of them
        -- with ``changed`` outlined.

        ``indices`` is the same sheet with each pixel's *colour index* as its
        grey level, which is where the hatch is cut from; ``None`` hatches
        nothing.
        """
        self._image = image
        self._columns = max(1, columns)
        self._count = count
        self._changed = frozenset(changed)
        self._zero = None
        if indices is not None and not indices.isNull():
            # MaskOutColor, for a region of the pixels that *are* colour 0:
            # the two halves each invert. The mask sets a bit per pixel it
            # masks out, and QBitmap.fromImage flips any mask whose colour
            # table reads black-then-white -- which is every mask Qt cuts.
            # Asking for the colour outright therefore hatches the seven
            # other colours and leaves colour 0 bare.
            mask = indices.createMaskFromColor(qRgb(0, 0, 0), Qt.MaskMode.MaskOutColor)
            self._zero = QRegion(QBitmap.fromImage(mask))
        self._hover = -1
        self._resized()

    def set_hatched(self, hatched: bool) -> None:
        """Whether colour 0 is drawn as a hatch rather than as its colour."""
        self._hatched = hatched
        self.update()

    @property
    def hatched(self) -> bool:
        return self._hatched

    # -- geometry ------------------------------------------------------------

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        """As large as the sheet's own pixels at this zoom -- the picture
        rather than the grid, so a sheet whose last row is part-full is still
        exactly as tall as it was drawn."""
        if self._image.isNull():
            return QSize(0, 0)
        return self._image.size() * self._zoom

    # -- events --------------------------------------------------------------

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        index = self.index_at(event.position().toPoint())
        if index != self._hover:
            self._hover = index
            self.hovered.emit(index)
        super().mouseMoveEvent(event)

    def leaveEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        if self._hover != -1:
            self._hover = -1
            self.hovered.emit(-1)
        super().leaveEvent(event)

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        if self._image.isNull():
            return
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.SmoothPixmapTransform, False)
        target = QRect(QPoint(0, 0), self.sizeHint())
        painter.drawImage(target, self._image)
        if self._hatched and self._zero is not None:
            painter.save()
            # The region was cut in sheet pixels; the zoom is a transform on
            # the painter rather than a second region per zoom -- and the
            # brush follows it, so a square of the hatch is the same fraction
            # of a tile however large the tile is drawn.
            painter.scale(self._zoom, self._zoom)
            painter.setClipRegion(self._zero)
            painter.fillRect(self._image.rect(), transparent_brush())
            painter.restore()
        if self._changed:
            pen = QPen(CHANGED_PEN)
            pen.setWidth(1)
            painter.setPen(pen)
            painter.setBrush(Qt.BrushStyle.NoBrush)
            for index in self._changed:
                if index < self._count:
                    painter.drawRect(self.rect_of(index).adjusted(0, 0, -1, -1))
        painter.end()


__all__ = ["CHANGED_PEN", "TileSheet"]
