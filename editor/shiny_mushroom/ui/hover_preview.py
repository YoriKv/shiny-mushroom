"""The magnified picture that appears beside a row the pointer is resting on.

A frameless window rather than a tooltip, because a tooltip is text: Qt sizes it
to a string, styles it by the platform, and hides it again on a timer that has
nothing to do with where the pointer is. This is a picture, it stays while the
pointer stays, and it is placed against the panel rather than against the
cursor.

**Pinned to the panel's edge, tracking only the row's height.** A popup that
followed the pointer in both axes would sit over the list it is describing, and
one anchored to the pointer would jump about as the hand moved along a row.
Beside the panel and level with the row is the placement every editor with a
picture list has converged on, and it leaves the list itself readable.

Left of the panel by preference and right of it where there is no room -- the
create dock can be docked on either side of the window, and a popup hung off
the left edge of a dock against the left edge of the screen is off the screen.

The zoom is a **whole multiple**, chosen to fill the box: this is pixel art
displayed at a few times its size, and a fractional scale lands source pixels on
uneven numbers of device pixels -- exactly the reasoning
:mod:`shiny_mushroom.ui.canvas` gives for its own ladder. Anything already
larger than the box is shown at 1:1 rather than reduced, because a preview is a
thing to look *at* and half a sprite's pixels is not a better look at it.
"""

from __future__ import annotations

from PySide6.QtCore import QPoint, QRect, Qt
from PySide6.QtGui import QGuiApplication, QImage, QPainter, QPaintEvent
from PySide6.QtWidgets import QWidget

#: The box the picture is zoomed to fill, in device pixels. Big enough that a
#: one-block object is a legible 4x and small enough that a wide one still sits
#: beside the panel rather than across the window.
PREVIEW_BOX = 128

#: Room around the picture, and the border drawn at the edge of it.
PREVIEW_PADDING = 6

#: How long the pointer has to stay on a row with **no picture yet** before the
#: game is asked for one, in milliseconds. Nothing waits on this to be *shown*:
#: a picture already rendered goes up the moment the row is entered. What waits
#: is the ask, which costs an emulator round trip -- and sweeping down a list of
#: two hundred names is not two hundred requests to probe one.
REST_MS = 180


class HoverPreview(QWidget):
    """A magnified copy of one catalogue entry's render.

    Handed a :class:`QImage` and a rectangle to sit beside; owns no model and
    does not know what it is showing a picture of.
    """

    def __init__(self, parent: QWidget | None = None) -> None:
        # Tool rather than Popup: a Popup grabs the mouse, which would take the
        # pointer off the list the moment this appeared and close it again.
        super().__init__(parent, Qt.WindowType.ToolTip)
        self.setAttribute(Qt.WidgetAttribute.WA_ShowWithoutActivating, True)
        self.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        self._image = QImage()
        self._zoom = 1

    @property
    def image(self) -> QImage:
        """What is on show. Null when nothing is."""
        return self._image

    @property
    def zoom(self) -> int:
        """The whole multiple the picture is drawn at."""
        return self._zoom

    def show_image(self, image: QImage, beside: QRect, at: QPoint) -> None:
        """Show ``image`` beside ``beside``, level with ``at``.

        ``beside`` is the panel's rectangle in screen coordinates and ``at`` is
        the pointer, also in screen coordinates -- so only its ``y`` is read.
        Held inside ``beside``'s vertical span, so a row near either end of a
        long list still gets a popup that is fully on the screen, and flipped
        to the panel's other side where the preferred one has no room.
        """
        if image.isNull():
            self.hide()
            return
        self._image = image
        self._zoom = _fits(image.width(), image.height())
        side = PREVIEW_PADDING * 2
        width = image.width() * self._zoom + side
        height = image.height() * self._zoom + side
        self.resize(width, height)
        lowest = max(beside.top(), beside.bottom() - height)
        top = min(max(beside.top(), at.y() - height // 2), lowest)
        self.move(_beside(beside, width), top)
        self.show()
        self.update()

    def paintEvent(self, event: QPaintEvent) -> None:  # noqa: N802 - Qt override
        painter = QPainter(self)
        painter.fillRect(self.rect(), self.palette().toolTipBase())
        painter.setPen(self.palette().mid().color())
        painter.drawRect(self.rect().adjusted(0, 0, -1, -1))
        if self._image.isNull():
            return
        # Stated rather than assumed, exactly as the canvas states it: a smoothed
        # upscale of pixel art is wrong in a way that is easy to introduce and
        # hard to notice.
        painter.setRenderHint(QPainter.RenderHint.SmoothPixmapTransform, False)
        painter.drawImage(
            QRect(
                PREVIEW_PADDING,
                PREVIEW_PADDING,
                self._image.width() * self._zoom,
                self._image.height() * self._zoom,
            ),
            self._image,
        )


def _beside(panel: QRect, width: int) -> int:
    """Where a popup ``width`` wide goes beside ``panel``: its left edge.

    Left of the panel, which keeps the list it describes readable -- and right
    of it instead where the left would put the popup off the screen, which is
    what a dock on the left-hand edge does. Clamped to the screen either way,
    because a panel wider than the room left over has neither side to offer.
    """
    left = panel.left() - width
    screen = QGuiApplication.screenAt(panel.center()) or QGuiApplication.primaryScreen()
    if screen is None:
        return left
    area = screen.availableGeometry()
    if left < area.left():
        left = panel.right()
    return max(area.left(), min(left, area.right() - width))


def _fits(width: int, height: int) -> int:
    """The largest whole multiple of a ``width`` x ``height`` picture that fits
    the box, and never less than 1:1."""
    if width <= 0 or height <= 0:
        return 1
    return max(1, min(PREVIEW_BOX // width, PREVIEW_BOX // height))
