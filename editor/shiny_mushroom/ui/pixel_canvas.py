"""The pixel editor's picture: an image at a whole-number zoom, the marks
over it, and the mouse reported in the image's own pixels.

Handed an image and paints it, exactly as every canvas here is
([`architecture`](../../../docs/editor/architecture.md)): what a pixel *is*,
what a press means and what a stroke writes belong to the editor. What is
here is the geometry -- a press at a widget point is a press on pixel
``(x, y)`` -- and four marks the editor sets and takes off again: the grid,
a selection ring, the hatch over cells that take no paint, and the pen's
preview on the pixel under the pointer.

Every gesture arrives as a signal in image pixels. A left drag is clamped to
the picture, so a stroke run off the edge keeps painting along it; a right
drag is not, and re-reports each new pixel as a press, which is how the
eyedropper sweeps.
"""

from __future__ import annotations

from collections.abc import Sequence
from enum import Enum

from PySide6.QtCore import QPoint, QRect, QSize, Qt, Signal
from PySide6.QtGui import (
    QColor,
    QImage,
    QMouseEvent,
    QPainter,
    QPaintEvent,
    QPen,
    QRegion,
)
from PySide6.QtWidgets import QWidget

from shiny_mushroom.ui.hatching import hatch
from shiny_mushroom.ui.ring import draw_ring
from shiny_mushroom.ui.zoomed_grid import ZoomedPicture
from smw_tools.graphics import TILE_SIDE

#: The pixel lattice, drawn faintly once a pixel is wide enough to have
#: edges, and the tile lattice over it, which is what the picture is made of.
PIXEL_GRID = QColor(0x80, 0x80, 0x80, 0x50)
TILE_GRID = QColor(0x40, 0x80, 0xFF, 0xA0)

#: A pixel is a grid cell once it is this many widget pixels wide.
PIXEL_GRID_ZOOM = 4


class GridMode(Enum):
    """What lattice is drawn over the picture. ``value`` is the settings
    key, and the order is the one ``G`` cycles through."""

    NONE = "none"
    #: The 8x8 tiles the picture is made of.
    TILES = "tiles"
    #: Every pixel, once a pixel is wide enough to have edges -- and the
    #: tiles over it.
    PIXELS = "pixels"

    def next(self) -> GridMode:
        members = list(GridMode)
        return members[(members.index(self) + 1) % len(members)]


#: The ring around the pen's target, so it shows on a pixel of its own colour.
PREVIEW_RING = QColor(0xFF, 0xFF, 0xFF, 0xC0)


class PixelCanvas(ZoomedPicture):
    """The picture, magnified, with the editor's marks over it."""

    #: A button went down on pixel ``(x, y)``: ``x``, ``y``, the button.
    pixel_pressed = Signal(int, int, object)
    #: The left button is held and the pointer reached another pixel.
    pixel_moved = Signal(int, int)
    #: The left button came up, on this pixel.
    pixel_released = Signal(int, int)
    #: A double-click on this pixel.
    pixel_double_clicked = Signal(int, int)
    #: The pointer is over this pixel, or ``(-1, -1)`` for none.
    hovered = Signal(int, int)

    def __init__(self, zoom: int = 4, parent: QWidget | None = None) -> None:
        super().__init__(zoom, parent)
        self._image = QImage()
        self._grid = GridMode.PIXELS
        self._marquee: QRect | None = None
        self._locked: tuple[QRect, ...] = ()
        self._preview: QColor | None = None
        self._hover: tuple[int, int] | None = None
        self._dragging = False
        self._sampling = False
        self._last: tuple[int, int] | None = None
        self.setMouseTracking(True)
        self.setCursor(Qt.CursorShape.CrossCursor)

    # -- what is shown --------------------------------------------------------

    def set_image(self, image: QImage) -> None:
        resized = image.size() != self._image.size()
        self._image = image
        if resized:
            self._resized()
        else:
            self.update()

    @property
    def image(self) -> QImage:
        return self._image

    def set_grid(self, mode: GridMode) -> None:
        self._grid = mode
        self.update()

    @property
    def grid(self) -> GridMode:
        return self._grid

    def set_marquee(self, rect: QRect | None) -> None:
        """Ring ``rect`` -- image pixels -- or nothing."""
        self._marquee = None if rect is None else QRect(rect)
        self.update()

    @property
    def marquee(self) -> QRect | None:
        return self._marquee

    def set_locked(self, rects: Sequence[QRect]) -> None:
        """Hatch these rectangles -- image pixels -- as taking no paint."""
        self._locked = tuple(QRect(rect) for rect in rects)
        self.update()

    def set_preview(self, colour: QColor | None) -> None:
        """Show the pen's colour on the pixel under the pointer, or not."""
        self._preview = colour
        self.update()

    # -- geometry -------------------------------------------------------------

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        if self._image.isNull():
            return QSize(0, 0)
        return self._image.size() * self._zoom

    def pixel_at(self, point: QPoint, clamp: bool = False) -> tuple[int, int] | None:
        """Which image pixel ``point`` (widget pixels) is over; with
        ``clamp``, the nearest one for a point off the picture."""
        if self._image.isNull():
            return None
        x, y = point.x() // self._zoom, point.y() // self._zoom
        w, h = self._image.width(), self._image.height()
        if clamp:
            return max(0, min(x, w - 1)), max(0, min(y, h - 1))
        if 0 <= x < w and 0 <= y < h:
            return x, y
        return None

    def rect_of(self, rect: QRect) -> QRect:
        """Where ``rect`` (image pixels) is drawn, in widget pixels."""
        z = self._zoom
        return QRect(rect.x() * z, rect.y() * z, rect.width() * z, rect.height() * z)

    # -- gestures, for the mouse and for a test ---------------------------------

    def press(
        self, x: int, y: int, button: Qt.MouseButton = Qt.MouseButton.LeftButton
    ) -> None:
        """A button going down on pixel ``(x, y)``."""
        if button is Qt.MouseButton.LeftButton:
            self._dragging = True
            self._last = (x, y)
        elif button is Qt.MouseButton.RightButton:
            self._sampling = True
            self._last = (x, y)
        self.pixel_pressed.emit(x, y, button)

    def drag(self, x: int, y: int) -> None:
        """The pointer reaching pixel ``(x, y)`` with a button held. Not
        ``move``, which is every widget's own and how a layout places it."""
        if (x, y) == self._last:
            return
        self._last = (x, y)
        if self._dragging:
            self.pixel_moved.emit(x, y)
        elif self._sampling:
            self.pixel_pressed.emit(x, y, Qt.MouseButton.RightButton)

    def release(
        self, x: int, y: int, button: Qt.MouseButton = Qt.MouseButton.LeftButton
    ) -> None:
        if button is Qt.MouseButton.RightButton:
            self._sampling = False
            self._last = None
            return
        if button is not Qt.MouseButton.LeftButton or not self._dragging:
            return
        self._dragging = False
        self._last = None
        self.pixel_released.emit(x, y)

    def mousePressEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        pixel = self.pixel_at(event.position().toPoint())
        if pixel is None:
            super().mousePressEvent(event)
            return
        event.accept()
        self.press(*pixel, event.button())

    def mouseDoubleClickEvent(  # noqa: N802 - Qt override
        self, event: QMouseEvent
    ) -> None:
        pixel = self.pixel_at(event.position().toPoint())
        if pixel is None or event.button() is not Qt.MouseButton.LeftButton:
            super().mouseDoubleClickEvent(event)
            return
        event.accept()
        # Qt delivers press, release, double-click, release: the drag the
        # first press began is over, and the double-click stands in for it.
        self._dragging = False
        self._last = None
        self.pixel_double_clicked.emit(*pixel)

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        point = event.position().toPoint()
        buttons = event.buttons()
        if self._dragging and buttons & Qt.MouseButton.LeftButton:
            pixel = self.pixel_at(point, clamp=True)
            if pixel is not None:
                self.drag(*pixel)
        elif self._sampling and buttons & Qt.MouseButton.RightButton:
            pixel = self.pixel_at(point)
            if pixel is not None:
                self.drag(*pixel)
        self._track(self.pixel_at(point))
        super().mouseMoveEvent(event)

    def mouseReleaseEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        pixel = self.pixel_at(event.position().toPoint(), clamp=True)
        if pixel is None:
            super().mouseReleaseEvent(event)
            return
        event.accept()
        self.release(*pixel, event.button())

    def leaveEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        self._track(None)
        super().leaveEvent(event)

    def _track(self, pixel: tuple[int, int] | None) -> None:
        if pixel == self._hover:
            return
        self._hover = pixel
        self.hovered.emit(*(pixel if pixel is not None else (-1, -1)))
        if self._preview is not None:
            self.update()

    # -- painting -------------------------------------------------------------

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        if self._image.isNull():
            return
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.SmoothPixmapTransform, False)
        z = self._zoom
        painter.drawImage(QRect(QPoint(0, 0), self.sizeHint()), self._image)
        if self._locked:
            region = QRegion()
            for rect in self._locked:
                region = region.united(self.rect_of(rect))
            hatch(painter, region)
        if self._grid is not GridMode.NONE:
            self._paint_grid(painter)
        if self._marquee is not None and not self._marquee.isEmpty():
            draw_ring(painter, self.rect_of(self._marquee))
        if self._preview is not None and self._hover is not None:
            x, y = self._hover
            target = QRect(x * z, y * z, z, z)
            painter.fillRect(target, self._preview)
            painter.setPen(QPen(PREVIEW_RING, 1))
            painter.setBrush(Qt.BrushStyle.NoBrush)
            painter.drawRect(target.adjusted(0, 0, -1, -1))
        painter.end()

    def _paint_grid(self, painter: QPainter) -> None:
        z = self._zoom
        width, height = self.sizeHint().width(), self.sizeHint().height()
        if self._grid is GridMode.PIXELS and z >= PIXEL_GRID_ZOOM:
            painter.setPen(QPen(PIXEL_GRID, 1))
            for x in range(z, width, z):
                painter.drawLine(x, 0, x, height)
            for y in range(z, height, z):
                painter.drawLine(0, y, width, y)
        painter.setPen(QPen(TILE_GRID, 1))
        step = TILE_SIDE * z
        for x in range(step, width, step):
            painter.drawLine(x, 0, x, height)
        for y in range(step, height, step):
            painter.drawLine(0, y, width, y)


__all__ = ["PIXEL_GRID_ZOOM", "GridMode", "PixelCanvas"]
