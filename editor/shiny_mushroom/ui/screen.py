"""The widget a running game is drawn on.

Deliberately as dumb as :mod:`~shiny_mushroom.ui.canvas` is: it is handed a
picture and it paints it. It owns no emulator, no timer and no button state, so
it can be tested by handing it a frame and reading pixels back.

Two decisions about how the picture is scaled, and both are about level design
rather than about emulation:

- **Square pixels.** A real SNES stretches its 256 columns across a 4:3 screen,
  so a block is wider than it is tall. An editor's picture of the same level is
  not stretched, and a tool for checking whether a jump is possible should not
  disagree with the picture beside it about what a block looks like.
- **Whole-number scaling, nearest neighbour.** A half-scaled pixel is two
  different sizes across the screen, which turns a tile boundary into an
  artefact. Below 1:1 the whole-number rule would floor to zero, so a window
  smaller than a frame falls back to fitting it.
"""

from __future__ import annotations

from PySide6.QtCore import QRect, QSize, Qt
from PySide6.QtGui import QColor, QImage, QPainter
from PySide6.QtWidgets import QSizePolicy, QWidget

#: What the SNES hands over: 256 across, and the full 239 lines rather than the
#: 224 a television showed. Only a starting size -- every frame carries its own
#: dimensions and the widget follows them.
FRAME_WIDTH = 256
FRAME_HEIGHT = 239

#: How large the window opens. Two is legible on any screen this runs on and
#: leaves room for the toolbar beside it.
DEFAULT_SCALE = 2

#: Behind and around the picture. Not the theme's background: a letterbox that
#: changes with the palette reads as part of the game.
LETTERBOX = QColor(0, 0, 0)


class Screen(QWidget):
    """Shows one emulator frame at a time, scaled by a whole number."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._image = QImage()
        # The QImage does not copy what it is given, so the buffer has to be
        # kept alive for exactly as long as the image is. Dropping this is a
        # use-after-free that shows up as torn or garbage pixels rather than as
        # a crash.
        self._pixels: bytes | None = None
        self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        self.setMinimumSize(FRAME_WIDTH, FRAME_HEIGHT)
        # Painted edge to edge every time, so Qt need not clear it first.
        self.setAttribute(Qt.WidgetAttribute.WA_OpaquePaintEvent)

    # -- what is shown ------------------------------------------------------

    @property
    def image(self) -> QImage:
        """The frame currently on screen. Null until one arrives."""
        return self._image

    def set_frame(self, pixels: bytes, width: int, height: int) -> None:
        """Show one frame of ``width * height`` little-endian ``0xAARRGGBB``.

        That is ``Format_RGB32`` byte for byte on a little-endian host, which is
        why nothing here converts anything: the emulator's own buffer is already
        in Qt's format.
        """
        self._pixels = pixels
        self._image = QImage(pixels, width, height, QImage.Format.Format_RGB32)
        self.update()

    def clear(self) -> None:
        """Go back to the letterbox colour, holding no frame."""
        self._pixels = None
        self._image = QImage()
        self.update()

    # -- painting -----------------------------------------------------------

    def sizeHint(self) -> QSize:  # noqa: N802 - Qt override
        return QSize(FRAME_WIDTH * DEFAULT_SCALE, FRAME_HEIGHT * DEFAULT_SCALE)

    def frame_rect(self) -> QRect:
        """Where the picture goes: centred, whole-number scaled where it fits.

        Public because it is the whole of the layout decision and the only part
        of this widget with anything to get wrong.
        """
        if self._image.isNull():
            return QRect()
        width, height = self._image.width(), self._image.height()
        scale = min(self.width() // width, self.height() // height)
        if scale >= 1:
            size = QSize(width * scale, height * scale)
        else:
            # Smaller than one frame. Whole-number scaling would floor to zero
            # and show nothing, so fit instead and accept uneven pixels -- a
            # small picture is better than no picture.
            size = QSize(width, height).scaled(
                self.size(), Qt.AspectRatioMode.KeepAspectRatio
            )
        return QRect(
            (self.width() - size.width()) // 2,
            (self.height() - size.height()) // 2,
            size.width(),
            size.height(),
        )

    def paintEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        painter = QPainter(self)
        painter.fillRect(self.rect(), LETTERBOX)
        if self._image.isNull():
            return
        # Left off deliberately: smoothing a 256-pixel-wide frame blurs exactly
        # the tile edges someone is looking at.
        painter.setRenderHint(QPainter.RenderHint.SmoothPixmapTransform, False)
        painter.drawImage(self.frame_rect(), self._image)
