"""Whole-number zoom, shared by every window that magnifies a sheet of pixels.

The graphics files' tile sheet, the Map16 editor's block sheet and its VRAM
picker are all the same arrangement: a picture drawn at a whole multiple of
its own pixels, scrolled inside an area smaller than it is, with one control
saying how large. What that arrangement needs -- a ladder of zooms, a picker
that steps it, Ctrl and the wheel over the picture, and a scroll position that
holds still while the picture grows under it -- is here rather than in each
window, because a window that wrote its own got a different half of it each
time.

**A picker owns no picture.** It is *given* the pictures that follow it
(:meth:`ZoomPicker.drives`), which is what lets one setting drive several: the
Map16 editor's two grids are one zoom over two widgets, and neither of them
knows the other is there.

**Every zoom is anchored on something.** :class:`ZoomedArea` holds the pixel
under the pointer where it is, and the middle of the view when the zoom came
from the picker instead -- the same rule, and the same reason, as the canvas's
viewport (:mod:`shiny_mushroom.ui.canvas_view`): zooming in on something must
not also mean finding it again afterwards.

**Hold space, drag** pans, as it does on the canvas's viewport and by the same
rules: the key is claimed while the pointer is over the view whatever has the
focus, the drag never reaches the picture as a gesture, and the hand is shown
on the pointer for as long as the key is down.

The float ladder the level canvas zooms by is its own
(:data:`~shiny_mushroom.ui.canvas.ZOOM_LEVELS`, shown as a percentage by
:mod:`~shiny_mushroom.ui.zoom_bar`). A sheet of 8x8 tiles is not that: its
pixels are the unit, "3x" is what the reader is choosing, and a percentage
between two whole multiples would blur the very thing being looked at. Only
:class:`WheelSteps` is common to both, and both take it from here.
"""

from __future__ import annotations

from typing import Protocol

from PySide6.QtCore import QEvent, QObject, QPoint, Qt, Signal
from PySide6.QtGui import QKeyEvent, QMouseEvent, QWheelEvent
from PySide6.QtWidgets import (
    QApplication,
    QComboBox,
    QScrollArea,
    QSizePolicy,
    QWidget,
)

#: One detent of a mouse wheel, in eighths of a degree -- Qt's unit for
#: ``angleDelta``.
WHEEL_NOTCH = 120

#: The zooms a sheet is offered, smallest first. Whole multiples of the
#: picture's own pixels, so a tile is drawn at 8, 16, 24 or 32 across and
#: never between two of them.
ZOOMS: tuple[int, ...] = (1, 2, 3, 4)

#: What a sheet opens at: large enough to read an 8x8 tile, small enough that
#: a 16x32 sheet of them fits a window beside everything else.
DEFAULT_ZOOM = 2


class Zoomable(Protocol):
    """What a picture has to answer to be driven by a :class:`ZoomPicker`.

    Every picture the editor drives today answers it by inheriting
    :class:`~shiny_mushroom.ui.zoomed_grid.ZoomedPicture`, which is where the
    zoom itself and the resize that follows it live. This stays a protocol
    rather than becoming that import because a picker owns no picture: what
    it drives is anything that can be told a whole number and grow by it,
    which is also what lets a picker be tested against a stub widget with no
    grid behind it.
    """

    @property
    def zoom(self) -> int: ...

    def set_zoom(self, zoom: int, /) -> None: ...


class WheelSteps:
    """A wheel's motion, banked until it makes whole notches.

    Trackpads and free-spinning wheels send fractions of a detent, so a view
    that read every event as a step would run several rungs up the ladder on
    one flick. The count is truncated towards zero and the remainder kept, so
    reversing direction part-way through a notch does not carry the earlier
    motion into it.
    """

    def __init__(self) -> None:
        self._banked = 0

    def take(self, delta: int) -> int:
        """How many whole notches ``delta`` makes, counting what it was
        handed before -- and keeping what is left over."""
        self._banked += delta
        steps = int(self._banked / WHEEL_NOTCH)
        self._banked -= steps * WHEEL_NOTCH
        return steps


class ZoomPicker(QComboBox):
    """Picks a whole-number zoom off a ladder, and drives what follows it.

    Owns no picture. A picture is registered with :meth:`drives` and told the
    zoom from then on, so one picker may drive several and none of them needs
    to know where the setting came from -- a menu, the wheel, or this box.
    """

    #: The zoom is about to move. The driven pictures have not been told yet,
    #: so whoever listens is looking at them at the size they still are --
    #: the moment to note anything the change would otherwise disturb.
    zoom_changing = Signal()

    #: The zoom moved, as a multiplier. The driven pictures are told first, so
    #: whoever listens is looking at a picture already at the new size.
    zoom_changed = Signal(int)

    def __init__(
        self,
        zooms: tuple[int, ...] = ZOOMS,
        zoom: int = DEFAULT_ZOOM,
        parent: QWidget | None = None,
    ) -> None:
        # Refused before the widget exists: a picker with no rung has no
        # zoom to answer with, and every member below would have to say so.
        if not zooms:
            raise ValueError("a zoom ladder needs at least one rung")
        super().__init__(parent)
        self._zooms = tuple(sorted(zooms))
        self._driven: list[Zoomable] = []
        for rung in self._zooms:
            self.addItem(f"{rung}x", rung)
        self.setSizeAdjustPolicy(QComboBox.SizeAdjustPolicy.AdjustToContents)
        self.currentIndexChanged.connect(self._picked)
        self.set_zoom(zoom)

    @property
    def zooms(self) -> tuple[int, ...]:
        """The ladder, smallest first."""
        return self._zooms

    @property
    def zoom(self) -> int:
        return int(self.currentData())

    def set_zoom(self, zoom: int) -> None:
        """Show ``zoom``, snapped to the nearest rung -- a caller restoring a
        remembered setting must not be able to ask for one that is not there.
        """
        nearest = min(self._zooms, key=lambda rung: (abs(rung - zoom), rung))
        self.setCurrentIndex(self._zooms.index(nearest))

    def step(self, steps: int) -> None:
        """Move ``steps`` rungs, stopping at either end of the ladder."""
        at = self._zooms.index(self.zoom) + steps
        self.setCurrentIndex(min(max(at, 0), len(self._zooms) - 1))

    def drives(self, *pictures: Zoomable) -> None:
        """Keep ``pictures`` at this zoom, from now on and at once."""
        self._driven += pictures
        for picture in pictures:
            picture.set_zoom(self.zoom)

    def _picked(self, _index: int) -> None:
        self.zoom_changing.emit()
        for picture in self._driven:
            picture.set_zoom(self.zoom)
        self.zoom_changed.emit(self.zoom)


class ZoomedArea(QScrollArea):
    """A scroll area over a picture the pointer can zoom.

    **Ctrl and the wheel** step the picker's ladder, anchored on the pointer.
    A bare wheel keeps its usual meaning and scrolls, which is what leaves the
    modifier free to mean zoom -- and what the same key does in the level view
    and in every browser.

    **Every move of the picker is followed**, whether it came from here, from
    the box or from another view the same picker drives: a change from
    somewhere else holds the middle of this view, so the second of two grids
    on one setting does not jump while the first is being zoomed.

    **Hold space, drag** pans. The rules are the level viewport's
    (:class:`~shiny_mushroom.ui.canvas_view.CanvasView`), since a gesture that
    means one thing on one picture has to mean it on every picture: the pointer
    arms it rather than the focus, so the key is watched for the whole
    application while the pointer is over this view and claimed from whatever
    else it was aimed at in this window; a press while it is held begins a pan
    that the picture never sees, so it cannot be mistaken for a click; and
    letting go of the key, or the window losing its activation, ends it.

    The picture is sized by itself rather than by the area
    (``setWidgetResizable(False)``): a sheet is exactly as large as its pixels
    at the zoom it is at, and what scrolls is the sheet inside the window onto
    it.
    """

    def __init__(
        self,
        picture: Zoomable,
        picker: ZoomPicker,
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        self._picture = picture
        self._picker = picker
        self._wheel = WheelSteps()
        # The pan: whether space is down, where a drag began in screen
        # pixels and the scroll it began from, whether the application's
        # keys are being watched, and the cursor the picture wore before the
        # hand went over it -- a canvas that shows a cross has to get it back.
        self._pan_held = False
        self._pan_origin: QPoint | None = None
        self._pan_scroll = (0, 0)
        self._watching = False
        self._picture_cursor = None
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)
        #: The zoom this view was last held at -- what the next change is
        #: measured from. Per view rather than per picker: one picker drives
        #: several, and each holds a point of its own.
        self._at = picker.zoom
        #: What to hold through the change this view is asking for, in
        #: viewport pixels; ``None`` for one that came from somewhere else,
        #: which holds the middle instead.
        self._anchor: QPoint | None = None
        #: Where the bars stood as the picker began to move, before the
        #: picture took its new size. A picture that shrinks pulls the bars
        #: in with it, and a hold measured from where they were clamped to
        #: would zoom out onto a different part of the picture.
        self._scrolled = (0, 0)
        picker.drives(picture)
        picker.zoom_changing.connect(self._picker_moving)
        picker.zoom_changed.connect(self._picker_moved)
        self.setWidget(picture)
        self.setWidgetResizable(False)
        self.setAlignment(Qt.AlignmentFlag.AlignTop | Qt.AlignmentFlag.AlignLeft)
        self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)

    # -- panning ----------------------------------------------------------------

    @property
    def panning(self) -> bool:
        """Whether a pan drag is in progress."""
        return self._pan_origin is not None

    @property
    def pan_held(self) -> bool:
        """Whether space is down over this view."""
        return self._pan_held

    def keyPressEvent(self, event: QKeyEvent) -> None:  # noqa: N802 - Qt override
        # Auto-repeat ignored on both edges: holding space is one gesture.
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
        # The release of a key held while the focus moves goes elsewhere, so
        # a space held across it would otherwise still read as held.
        self._set_pan_held(False)
        super().focusOutEvent(event)

    def enterEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        super().enterEvent(event)
        self._watch_the_keyboard()

    def leaveEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        super().leaveEvent(event)
        self._watch_the_keyboard()

    def _set_pan_held(self, held: bool) -> None:
        if held and not self._pan_held:
            picture = self.widget()
            self._picture_cursor = picture.cursor() if picture is not None else None
        self._pan_held = held
        if not held:
            self._pan_origin = None
        self._watch_the_keyboard()
        self._apply_cursor()

    def _watch_the_keyboard(self) -> None:
        """Listen to the whole application's keys only while a space press
        could be this view's: the pointer over it, or a hold already claimed
        whose release is owed wherever the pointer has gone since."""
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

    def _apply_cursor(self) -> None:
        picture = self.widget()
        if self.panning:
            shape = Qt.CursorShape.ClosedHandCursor
        elif self._pan_held:
            shape = Qt.CursorShape.OpenHandCursor
        else:
            self.viewport().unsetCursor()
            if picture is not None:
                if self._picture_cursor is not None:
                    picture.setCursor(self._picture_cursor)
                else:
                    picture.unsetCursor()
            return
        self.viewport().setCursor(shape)
        if picture is not None:
            picture.setCursor(shape)

    def eventFilter(self, watched: QObject, event: QEvent) -> bool:  # noqa: N802
        """Space aimed elsewhere in this window while the pointer is here, the
        window deactivating under a held key, and the picture's own mouse
        while a pan is armed. ``setWidget`` already installs this filter on
        the picture for the scroll area's own bookkeeping; the base call
        keeps that working."""
        kind = event.type()
        if kind in (QEvent.Type.KeyPress, QEvent.Type.KeyRelease):
            if self._claim_space_elsewhere(watched, event):
                return True
        elif kind == QEvent.Type.WindowDeactivate and watched is self.window():
            self._set_pan_held(False)
        elif watched is self.widget() and self._navigate(event):
            return True
        return super().eventFilter(watched, event)

    def _claim_space_elsewhere(self, watched: QObject, event: QKeyEvent) -> bool:
        """Take a space press aimed at another widget of this window while
        the pointer is over this view; and the release of a hold so claimed,
        wherever the pointer has gone since."""
        if event.key() != Qt.Key.Key_Space or event.isAutoRepeat():
            return False
        if self.hasFocus():
            return False
        window = self.window()
        if not (
            isinstance(watched, QWidget)
            and (watched is window or window.isAncestorOf(watched))
        ):
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

    def mousePressEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if not self._navigate(event):
            super().mousePressEvent(event)

    def mouseMoveEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if not self._navigate(event):
            super().mouseMoveEvent(event)

    def mouseReleaseEvent(self, event: QMouseEvent) -> None:  # noqa: N802 - Qt override
        if not self._navigate(event):
            super().mouseReleaseEvent(event)

    def _navigate(self, event: QEvent) -> bool:
        """Handle ``event`` as a pan, reporting whether it was consumed."""
        kind = event.type()
        if kind == QEvent.Type.MouseButtonPress:
            # Any click in the view is a claim on the keyboard too, so a
            # space pressed afterwards reaches here by Qt's own delivery.
            self.setFocus(Qt.FocusReason.MouseFocusReason)
            if not self._pan_held or event.button() != Qt.MouseButton.LeftButton:
                return False
            # Screen coordinates, and the scroll they started from, so the
            # drag cannot chase itself as the content moves under the pointer.
            self._pan_origin = event.globalPosition().toPoint()
            self._pan_scroll = (
                self.horizontalScrollBar().value(),
                self.verticalScrollBar().value(),
            )
            self._apply_cursor()
            return True
        if kind == QEvent.Type.MouseMove and self.panning:
            delta = event.globalPosition().toPoint() - self._pan_origin
            # Subtracted: the content follows the pointer, so the window onto
            # it moves the other way.
            self.horizontalScrollBar().setValue(self._pan_scroll[0] - delta.x())
            self.verticalScrollBar().setValue(self._pan_scroll[1] - delta.y())
            return True
        if kind == QEvent.Type.MouseButtonRelease and self.panning:
            # The drag ends; the key does not, so the hand stays open.
            self._pan_origin = None
            self._apply_cursor()
            return True
        return False

    # -- zooming ----------------------------------------------------------------

    def wheelEvent(self, event: QWheelEvent) -> None:  # noqa: N802 - Qt override
        if not event.modifiers() & Qt.KeyboardModifier.ControlModifier:
            # A bare wheel scrolls, and banks nothing towards a later zoom:
            # scrolling a long sheet must not leave a notch waiting to be
            # spent the moment Ctrl goes down.
            super().wheelEvent(event)
            return
        event.accept()
        steps = self._wheel.take(event.angleDelta().y())
        if steps:
            self.zoom_by(
                steps, self.viewport().mapFromGlobal(event.globalPosition().toPoint())
            )

    def zoom_by(self, steps: int, anchor: QPoint | None = None) -> None:
        """Step the ladder, holding ``anchor`` -- a point in viewport pixels,
        or the middle of the view -- where it is."""
        self._anchor = anchor
        try:
            self._picker.step(steps)
        finally:
            self._anchor = None

    def _picker_moving(self) -> None:
        self._scrolled = (
            self.horizontalScrollBar().value(),
            self.verticalScrollBar().value(),
        )

    def _picker_moved(self, zoom: int) -> None:
        """The picker moved -- here, in another view it drives, or in the box
        itself -- and the picture is already the new size: hold whatever this
        view was asked to hold, or the middle of it.

        Every view the picker drives is told, which is what keeps a second
        one from jumping when the first is zoomed.
        """
        before, self._at = self._at, zoom
        if before != zoom:
            held = self._anchor if self._anchor is not None else self._middle()
            self._hold(held, before, zoom)

    def _middle(self) -> QPoint:
        return self.viewport().rect().center()

    def _hold(self, anchor: QPoint, before: int, after: int) -> None:
        """Scroll so that whatever was under ``anchor`` at the ``before`` zoom
        is under it at the ``after`` one.

        Measured from where the bars stood before the picture changed size,
        not where they are now: on a zoom out the smaller picture has already
        clamped them short of where they were.

        Both bars are set even where one of them has nothing to scroll: a
        picture narrower than the viewport clamps to zero of its own accord,
        which is the answer -- all of it is visible either way.
        """
        for bar, was, offset in (
            (self.horizontalScrollBar(), self._scrolled[0], anchor.x()),
            (self.verticalScrollBar(), self._scrolled[1], anchor.y()),
        ):
            at = (was + offset) / before
            bar.setValue(round(at * after) - offset)


__all__ = [
    "DEFAULT_ZOOM",
    "WHEEL_NOTCH",
    "ZOOMS",
    "WheelSteps",
    "ZoomPicker",
    "ZoomedArea",
    "Zoomable",
]
