"""The canvas's viewport: where you are looking at the image from.

The canvas is exactly as big as its image and knows nothing about being
scrolled; everything about *navigating* it - the scrollbars, hold-space-to-pan
and wheel zoom - lives here, in the scroll area that holds it. That split is the
same one the canvas already makes for the document: it paints, and something
else decides what a gesture means.

The gray around the image belongs to this widget for the same reason, but it is
**not** a dead margin: a gesture made on it is a gesture at the level, and is
handed to the canvas in the canvas's own coordinates rather than dropped. What
the surround says is "not the picture", which is a real answer - it is where a
click means nothing in particular, and where a drag begun outside the level
still begins.

Two gestures, chosen so that neither collides with editing the picture:

- **Hold space, drag** to pan. Space rather than the middle button because a
  drag is how every edit will be expressed too, and the held key is what
  distinguishes moving the paper from drawing on it - the same reason image
  editors settled on it. While it is held the events never reach the canvas, so
  a pan can never be mistaken for a click.

  **The pointer arms it, not the focus.** Reaching for space is not a claim on
  the keyboard, and a press that lands on the zoom box or the level picker
  instead would leave the gesture silently dead: the drag that follows takes
  focus, but the key that would have armed it has already been spent elsewhere,
  and no second press arrives while it is still held. So the key is watched for
  the whole application and claimed whenever the pointer is over this view --
  which is the rule every image editor already behaves by, and the one a hand
  cursor appearing under the pointer describes.
- **Ctrl and the wheel** to zoom, anchored on the cursor: the image pixel under
  the pointer stays under the pointer, so zooming in on something does not also
  require finding it again afterwards. A bare wheel keeps its usual meaning and
  scrolls, which is what leaves the modifier free to mean zoom - and what the
  same key does in every browser and editor.

**Every zoom is anchored on something**, which is why they all come through here
rather than going to the canvas: the pointer when there is one, and otherwise the
middle of the viewport, so the menu, the keyboard and the zoom box leave you
looking at what you were already looking at. A zoom left to the scrollbars
anchors on the top-left corner instead, and walks the view off towards the corner
of the level a step at a time.

The one thing an anchor gives way to is an axis that comes to fit: a picture
smaller than the viewport is centered by the scroll area, and there is nothing to
scroll and nothing worth holding - all of it is visible either way.
"""

from __future__ import annotations

from PySide6.QtCore import QEvent, QObject, QPoint, Qt
from PySide6.QtGui import QKeyEvent, QMouseEvent, QWheelEvent
from PySide6.QtWidgets import QApplication, QScrollArea, QWidget

from shiny_mushroom.ui.canvas import CANVAS_BACKGROUND, Canvas, zoom_level_after
from shiny_mushroom.ui.zooming import WheelSteps


class CanvasView(QScrollArea):
    """A scroll area around a :class:`~shiny_mushroom.ui.canvas.Canvas`, with
    space-drag panning and Ctrl+wheel zoom."""

    def __init__(self, canvas: Canvas, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.canvas = canvas
        self.setWidget(canvas)
        self.setAlignment(Qt.AlignmentFlag.AlignCenter)
        # Click and tab both have to be able to land here, or space arrives at
        # whatever else took focus - the level bar's spin box, most likely - and
        # panning silently does nothing.
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)
        # ...and when it did not land here, space is taken back off whatever it
        # did land on. Watched application-wide because a key event goes to the
        # focused widget and nowhere near this one; the gate is in
        # _claim_space_elsewhere, which is what keeps it from being a global
        # keyboard grab. Installed only while it could fire -- see
        # :meth:`_watch_the_keyboard`.
        self._watching = False

        # The canvas is exactly as big as its image, so what surrounds it is this
        # viewport. Painting it the canvas's own backing gray makes the two meet
        # seamlessly when the image is smaller than the window, instead of the
        # image sitting on a window-colored slab.
        viewport = self.viewport()
        viewport.setAutoFillBackground(True)
        palette = viewport.palette()
        palette.setColor(viewport.backgroundRole(), CANVAS_BACKGROUND)
        viewport.setPalette(palette)

        self._pan_held = False
        self._pan_origin: QPoint | None = None
        self._pan_scroll = (0, 0)
        self._wheel = WheelSteps()
        # What the pointer says the picture is offering where it is standing --
        # an object's edge under it, and nothing otherwise. Set from outside;
        # arbitrated here, because panning is the other thing that claims the
        # cursor and only this widget knows about both.
        self._hover: Qt.CursorShape | None = None

    # -- going somewhere ----------------------------------------------------

    def _middle(self) -> QPoint:
        """The middle of the viewport, in viewport coordinates."""
        viewport = self.viewport()
        return QPoint(viewport.width() // 2, viewport.height() // 2)

    def _settle(self) -> None:
        """Lay the scroll area out now rather than next time round the event
        loop.

        A picture that changes size can bring a scrollbar in or take one away,
        and until that has happened the viewport is still the one that is about
        to stop existing -- so its middle is half a scrollbar off where it is
        going to be. Asked for of this widget alone, and it is a layout rather
        than an event loop: nothing else runs.
        """
        QApplication.sendEvent(self, QEvent(QEvent.Type.LayoutRequest))

    def _pixel_under(self, at: QPoint) -> tuple[float, float]:
        """The image pixel beneath viewport point ``at``, as a fraction.

        Fractional on purpose: it is the thing an anchored zoom has to hold
        still, and rounding it to whole pixels first would let the anchor creep
        by up to a pixel per step.
        """
        origin = self.canvas.pos()
        zoom = self.canvas.zoom
        return ((at.x() - origin.x()) / zoom, (at.y() - origin.y()) / zoom)

    def _put(self, pixel: tuple[float, float], at: QPoint) -> None:
        """Scroll so that image ``pixel`` lies under viewport point ``at``.

        Expressed as a *move of the canvas's corner* rather than as an absolute
        scroll value, because the two are only the same while the picture
        overflows the viewport. Below that the scroll area centers the canvas
        instead, and a scroll value of zero no longer means the corner is at the
        viewport's -- which is what made an anchored zoom jump by half the
        surrounding gray the moment an axis came to fit.

        Clamped by the scrollbars themselves, so a point near an edge comes as
        close as the picture allows instead of scrolling past it, and a picture
        small enough to fit ignores the request entirely: it is already all
        visible, and where it sits is the scroll area's business.
        """
        zoom = self.canvas.zoom
        for bar, want, offset, corner in (
            (self.horizontalScrollBar(), pixel[0], at.x(), lambda: self.canvas.x()),
            (self.verticalScrollBar(), pixel[1], at.y(), lambda: self.canvas.y()),
        ):
            # Where the corner would have to be, against where it is. Scrolling
            # moves the content the other way, hence the subtraction. Read one
            # axis at a time: setting either bar can add or remove the other,
            # which moves the corner again.
            bar.setValue(bar.value() + corner() - round(offset - want * zoom))

    def center_on(self, pos: QPoint) -> None:
        """Scroll so that image pixel ``pos`` is in the middle of the viewport.

        In the canvas's **image** coordinates, not its device ones, because
        everything that has somewhere to go names a block or a pixel of the
        level -- and the zoom between the two is this widget's business rather
        than the caller's.

        Settled first, because this is called with a picture that has just
        arrived: a level of a different size to the last one is a viewport of a
        different size too.
        """
        self._settle()
        self._put((pos.x(), pos.y()), self._middle())

    @property
    def looking_at(self) -> QPoint:
        """The image pixel in the middle of the viewport.

        The inverse of :meth:`center_on`, and what anything remembering *where
        you were* records: in image coordinates, so a place noted at 5x still
        means the same part of the level when it is returned to at a quarter.

        Measured from where the canvas actually sits, so a picture the scroll
        area has centered answers with the pixel that is genuinely in the middle
        rather than with the one the scrollbars imply.
        """
        x, y = self._pixel_under(self._middle())
        return QPoint(round(x), round(y))

    # -- panning ------------------------------------------------------------

    @property
    def panning(self) -> bool:
        """Whether a pan drag is in progress."""
        return self._pan_origin is not None

    def keyPressEvent(self, event: QKeyEvent) -> None:  # noqa: N802 - Qt override
        # Auto-repeat ignored on both edges: holding space is one gesture, and
        # the repeats would otherwise re-arm it between a press and its release.
        if event.key() == Qt.Key.Key_Space and not event.isAutoRepeat():
            self._set_pan_held(True)
            event.accept()
            return
        super().keyPressEvent(event)

    def keyReleaseEvent(self, event: QKeyEvent) -> None:  # noqa: N802 - Qt override
        if event.key() == Qt.Key.Key_Space and not event.isAutoRepeat():
            self._set_pan_held(False)
            event.accept()
            return
        super().keyReleaseEvent(event)

    def focusOutEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        # The release of a key held while the window changes goes to whatever
        # took focus, so a space held across an alt-tab would still read as held
        # on the way back - with the hand cursor to match.
        self._set_pan_held(False)
        super().focusOutEvent(event)

    def _set_pan_held(self, held: bool) -> None:
        self._pan_held = held
        if not held:
            self._pan_origin = None
        self._watch_the_keyboard()
        self._apply_cursor()

    def enterEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        super().enterEvent(event)
        self._watch_the_keyboard()

    def leaveEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        super().leaveEvent(event)
        self._watch_the_keyboard()

    def _watch_the_keyboard(self) -> None:
        """Listen to the whole application's keys, or stop listening.

        A filter on the application is asked about **every event of every
        object** in the program -- building one table editor's worth of
        cells is tens of thousands of them -- and each question costs a
        call out of Qt and into Python whatever the answer. So the filter
        is only installed while it could say yes.

        Which is: while the pointer is on this view, the condition
        :meth:`_claim_space_elsewhere` already puts on the press; or while
        a hold claimed that way is still down, since the release is owned
        wherever the pointer has gone since, and so is the window
        deactivating out from under it.
        """
        wanted = self._pan_held or self.underMouse()
        if wanted == self._watching:
            return
        application = QApplication.instance()
        if application is None:
            return
        self._watching = wanted
        if wanted:
            application.installEventFilter(self)
        else:
            application.removeEventFilter(self)

    def set_hover_cursor(self, shape: Qt.CursorShape | None) -> None:
        """What the pointer looks like over the picture, where panning leaves it
        free.

        The window sets this for the gestures the *picture* offers -- a held
        object's edge under the pointer, which is how an edge drag is found at
        all, since an edge looks no different from the middle of an object.
        ``None`` gives it back.

        Panning still wins: space is held to move the paper rather than to work
        on it, and it has to say so wherever the pointer happens to be.
        """
        if shape == self._hover:
            return
        self._hover = shape
        self._apply_cursor()

    def _apply_cursor(self) -> None:
        """Show the pan state on the pointer, over both the image and the
        surround -- and what the picture offers where it does not."""
        if self.panning:
            shape = Qt.CursorShape.ClosedHandCursor
        elif self._pan_held:
            shape = Qt.CursorShape.OpenHandCursor
        elif self._hover is not None:
            # The picture's own, so only the picture: there is no edge to take
            # hold of out on the gray, and a resize cursor over it would be
            # offering a gesture that is not there.
            self.viewport().unsetCursor()
            self.canvas.setCursor(self._hover)
            return
        else:
            self.viewport().unsetCursor()
            self.canvas.unsetCursor()
            return
        self.viewport().setCursor(shape)
        self.canvas.setCursor(shape)

    # -- input --------------------------------------------------------------

    def eventFilter(self, watched: QObject, event: QEvent) -> bool:  # noqa: N802
        """Intercept the canvas's own input, and space aimed anywhere else.

        A widget inside a scroll area gets the mouse itself, so without this the
        view would only ever see gestures made on the gray surround.
        ``setWidget`` already installs this filter for the scroll area's own
        bookkeeping (resizes, layout requests); the base call keeps that working.

        This is also installed on the application, so ``watched`` is usually
        some widget with no connection to the canvas at all. Everything below
        says no to those quickly and hands them back untouched.
        """
        kind = event.type()
        if kind in (QEvent.Type.KeyPress, QEvent.Type.KeyRelease):
            if self._claim_space_elsewhere(watched, event):
                return True
        elif kind == QEvent.Type.WindowDeactivate and watched is self.window():
            # The release of a key held across an alt-tab is delivered to
            # whatever the next window is, so it never comes back here. Focus
            # covers only the case where the view had it; this covers the rest.
            self._set_pan_held(False)
        elif watched is self.canvas and self._navigate(event):
            return True
        return super().eventFilter(watched, event)

    def _claim_space_elsewhere(self, watched: QObject, event: QKeyEvent) -> bool:
        """Take a space press aimed at another widget, when this view is what
        the pointer is on.

        Declined unless every one of these holds, which is what stops it being a
        keyboard grab over the whole application:

        - it is space, and not the auto-repeat of a press already claimed;
        - the key was going to *this window* -- so a dialog, a menu and an open
          dropdown all keep their own space;
        - this view does not already have the key, in which case Qt's own
          delivery is the right path and :meth:`keyPressEvent` handles it;
        - the pointer is over this view.

        The last is asked of the **press only**. A hold claimed here is owned
        until it is let go, or moving the pointer off the picture mid-gesture
        would eat the release and leave the hand stuck open.
        """
        if event.key() != Qt.Key.Key_Space or event.isAutoRepeat():
            return False
        if self.hasFocus() or not self._in_this_window(watched):
            return False
        if event.type() == QEvent.Type.KeyRelease:
            if not self._pan_held:
                return False
            self._set_pan_held(False)
            return True
        if not self.underMouse():
            return False
        self._set_pan_held(True)
        return True

    def _in_this_window(self, watched: QObject) -> bool:
        window = self.window()
        return isinstance(watched, QWidget) and (
            watched is window or window.isAncestorOf(watched)
        )

    # Events over the surround arrive here instead, through viewportEvent.
    def mousePressEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if self._navigate(event):
            return
        # The gray is part of the same surface as the picture, not a dead margin
        # around it: a press there is the canvas's to interpret, and it says
        # there is nothing under the pointer. Handed over in the canvas's own
        # coordinates, which for the surround are outside its widget - negative
        # above and to the left of the image, past its size below and right.
        self.canvas.press_at(self._on_canvas(event), event.button(), event.modifiers())
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        # A gesture begun on the surround is grabbed by the *viewport*, so the
        # rest of it arrives here rather than at the canvas -- which is why the
        # press is not the only part that has to be handed over. A gesture begun
        # on the picture is grabbed by the canvas and never reaches this, so
        # there is no double reporting.
        if not self._navigate(event):
            self.canvas.move_to(self._on_canvas(event))
            super().mouseMoveEvent(event)

    def mouseReleaseEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if not self._navigate(event):
            self.canvas.release_at(self._on_canvas(event), event.button())
            super().mouseReleaseEvent(event)

    def _on_canvas(self, event: QMouseEvent) -> QPoint:
        """An event on the surround, in the canvas's own coordinates -- which out
        there are outside its widget: negative above and to the left of the
        image, past its size below and right."""
        return self.canvas.mapFrom(self.viewport(), event.position().toPoint())

    def wheelEvent(self, event: QWheelEvent) -> None:  # noqa: N802 - Qt override
        if not self._navigate(event):
            super().wheelEvent(event)

    def _navigate(self, event: QEvent) -> bool:
        """Handle ``event`` as navigation, reporting whether it was consumed."""
        kind = event.type()
        if kind == QEvent.Type.MouseButtonPress:
            return self._begin_pan(event)
        if kind == QEvent.Type.MouseMove and self.panning:
            self._pan_to(event)
            return True
        if kind == QEvent.Type.MouseButtonRelease and self.panning:
            # The drag ends; the key does not. Letting go of the button with
            # space still down leaves the hand open, ready for the next one.
            self._pan_origin = None
            self._apply_cursor()
            return True
        if kind == QEvent.Type.Wheel:
            return self._wheel_zoom(event)
        return False

    def _begin_pan(self, event: QMouseEvent) -> bool:
        # Any click in the view is also a claim on the keyboard: the picture is
        # what the user is working in, so space has to reach here afterwards.
        self.setFocus(Qt.FocusReason.MouseFocusReason)
        if not self._pan_held or event.button() != Qt.MouseButton.LeftButton:
            return False
        # Screen coordinates, and the scroll offsets they started from, so the
        # drag stays continuous where it crosses between the image and the
        # surround - and so it cannot chase itself as the content moves under
        # the pointer.
        self._pan_origin = event.globalPosition().toPoint()
        self._pan_scroll = (
            self.horizontalScrollBar().value(),
            self.verticalScrollBar().value(),
        )
        self._apply_cursor()
        return True

    def _pan_to(self, event: QMouseEvent) -> None:
        delta = event.globalPosition().toPoint() - self._pan_origin
        # Subtracted: the content follows the pointer, which means the window
        # onto it moves the other way.
        self.horizontalScrollBar().setValue(self._pan_scroll[0] - delta.x())
        self.verticalScrollBar().setValue(self._pan_scroll[1] - delta.y())

    def _wheel_zoom(self, event: QWheelEvent) -> bool:
        # Without the modifier the wheel is left to the scroll area, so the
        # accumulator is not touched either: a bare scroll must not bank motion
        # towards a later zoom.
        if not event.modifiers() & Qt.KeyboardModifier.ControlModifier:
            return False
        delta = event.angleDelta().y()
        if delta == 0:
            # A purely horizontal wheel is a scroll, and stays one.
            return False
        steps = self._wheel.take(delta)
        if steps:
            self._zoom_by(
                steps, self.viewport().mapFromGlobal(event.globalPosition().toPoint())
            )
        return True

    def zoom_in(self) -> None:
        """Zoom in a step, about the middle of the viewport."""
        self._zoom_by(+1)

    def zoom_out(self) -> None:
        """Zoom out a step, about the middle of the viewport."""
        self._zoom_by(-1)

    def set_zoom(self, zoom: float) -> None:
        """Zoom to ``zoom``, keeping the middle of the viewport where it is.

        What every zoom that did not come from the pointer goes through -- the
        menu, the keyboard, the zoom box. A zoom asked for without saying where
        still has an answer to "so where does this leave me looking": at what
        you were already looking at. Left to the scrollbars it would be the
        top-left corner that stayed put instead, which walks the view off
        towards the corner of the level a step at a time.
        """
        self._zoom_to(zoom)

    def _zoom_by(self, steps: int, anchor: QPoint | None = None) -> None:
        """Step ``steps`` along the zoom ladder, about ``anchor``."""
        self._zoom_to(zoom_level_after(self.canvas.zoom, steps), anchor)

    def _zoom_to(self, zoom: float, anchor: QPoint | None = None) -> None:
        """Zoom, keeping the image pixel under ``anchor`` under ``anchor``.

        ``anchor`` is a point in the viewport -- the pointer, for a wheel zoom.
        ``None`` means the middle, and is not the same as passing the middle:
        a zoom can bring a scrollbar in or take one away, which moves the middle,
        and what a middle-anchored zoom has to hold is the middle it *ends* with.

        Held still by scrolling rather than by any offset of the canvas's own:
        the canvas is placed by this scroll area, so the only thing that can
        move it is where the scrollbars are. When an axis comes to fit, nothing
        can -- the scroll area centers it -- so the anchor gives way on that
        axis, which is the right answer: all of it is visible either way.

        The pixel is read *before* the canvas resizes and put back afterwards,
        rather than the scroll values being scaled by the ratio of the two
        zooms, because that ratio is only the whole story while both axes
        overflow. Across the point where one starts or stops fitting it is not.
        """
        at = self._middle() if anchor is None else anchor
        pixel = self._pixel_under(at)
        before = self.canvas.zoom
        self.canvas.set_zoom(zoom)
        if self.canvas.zoom == before:
            return
        self._settle()
        self._put(pixel, self._middle() if anchor is None else anchor)
