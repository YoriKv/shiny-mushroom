"""The zoom control: how much of the picture you are looking at, and how large.

A toolbar of its own rather than another widget on the level bar, for one
reason: the level bar is disabled whenever there is nothing to ask for - no cart
open, or a load in flight - and the zoom is not a level operation. A byte map
zooms, and so does a level while its neighbour is still loading. Qt lays the two
bars out side by side on the same row, so they read as one strip regardless.

Zoom is shown as a **percentage**, the unit every editor of this kind uses:
"25%" says what it does to the picture without a fraction in it, where the same
setting as a multiplier is "0.25x" - a number the eye has to convert before it
means anything. The multiplier is the canvas's business and stops here
(:func:`~shiny_mushroom.ui.canvas.from_percent`).

The spin box **steps the canvas's ladder** rather than counting: its arrows and
the Up/Down keys move one level, and a typed number snaps to the nearest one.
The ladder is the whole of what the canvas supports
(:data:`~shiny_mushroom.ui.canvas.ZOOM_LEVELS`), so an in-between percentage
would be a setting that silently did something else.
"""

from __future__ import annotations

from PySide6.QtCore import Signal
from PySide6.QtWidgets import QLabel, QSpinBox, QToolBar, QWidget

from shiny_mushroom.ui.canvas import (
    DEFAULT_ZOOM,
    ZOOM_LEVELS,
    as_percent,
    from_percent,
    zoom_level_after,
)


class ZoomSpinBox(QSpinBox):
    """A percentage picked off :data:`~shiny_mushroom.ui.canvas.ZOOM_LEVELS`.

    A plain integer spin, which is the other half of what percent buys: every
    level is a whole number of them, so there are no decimals to show, to parse,
    or to round.
    """

    def __init__(self, zoom: float = DEFAULT_ZOOM, parent: QWidget | None = None):
        super().__init__(parent)
        self.setRange(as_percent(ZOOM_LEVELS[0]), as_percent(ZOOM_LEVELS[-1]))
        self.setSuffix("%")
        # Commit on Enter, focus-out or a step, not per keystroke: typing "400"
        # must not re-render the canvas at 4% on the way through.
        self.setKeyboardTracking(False)
        self.set_zoom(zoom)

    @property
    def zoom(self) -> float:
        """The multiplier the shown percentage stands for."""
        return from_percent(self.value())

    def set_zoom(self, zoom: float) -> None:
        self.setValue(as_percent(zoom))

    def valueFromText(self, text: str) -> int:  # noqa: N802 - Qt override
        """Snap typed text onto the nearest level, keeping the current one if it
        cannot be read as a number at all."""
        # The suffix is stripped defensively: which of the two sides sheds it is
        # a Qt implementation detail, and a stray "%" would make the whole entry
        # unreadable rather than merely off-ladder.
        cleaned = text.strip().removesuffix(self.suffix()).strip()
        try:
            typed = int(cleaned)
        except ValueError:
            return self.value()
        return as_percent(zoom_level_after(from_percent(typed)))

    def stepBy(self, steps: int) -> None:  # noqa: N802 - Qt override
        self.setValue(as_percent(zoom_level_after(self.zoom, steps)))


class ZoomBar(QToolBar):
    """Picks a zoom. Owns no canvas: it reports what was asked for and is told
    what took effect."""

    #: The user picked this zoom, as a multiplier. Whoever is listening decides
    #: what the canvas actually ends up at - which is why the bar does not update
    #: itself from this, and waits to be told (:meth:`set_zoom`).
    zoom_requested = Signal(float)

    def __init__(self, zoom: float = DEFAULT_ZOOM, parent: QWidget | None = None):
        super().__init__("Zoom", parent)
        # Named so Qt can save and restore it with the window state, and fixed
        # in place like the level bar it sits beside.
        self.setObjectName("zoom-bar")
        self.setMovable(False)

        self._zoom = ZoomSpinBox(zoom)
        self._zoom.valueChanged.connect(
            lambda percent: self.zoom_requested.emit(from_percent(percent))
        )
        self.addWidget(QLabel("Zoom "))
        self.addWidget(self._zoom)

    @property
    def zoom(self) -> float:
        """The zoom currently shown, as a multiplier."""
        return self._zoom.zoom

    def set_zoom(self, zoom: float) -> None:
        """Show ``zoom`` without asking for it.

        Signals are blocked rather than relied on to settle: the canvas snaps
        what it is given, so echoing its answer back here would otherwise ask it
        for that same zoom a second time.
        """
        blocked = self._zoom.blockSignals(True)
        try:
            self._zoom.set_zoom(zoom)
        finally:
            self._zoom.blockSignals(blocked)
