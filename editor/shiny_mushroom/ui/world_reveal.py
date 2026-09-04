"""The reveal filter: a cap on how far into a focused event's animation the
events view has got.

An event's placements are a *sequence* -- the entry table's row order is the
order the blocks come up on screen -- and the one question that order raises
is which block lands when. The mode already answers it
(:meth:`~shiny_mushroom.ui.overworld_mode.OverworldMode.preview_event_step`),
and the Event Placements window asks it by selecting a row; this is the same
question asked where the answer is, so an animation can be stepped while
looking at the map rather than at a table beside it.

**It floats over the canvas rather than joining the world bar** because it is
about the picture and only sometimes there: it is up while the Events row is
the one being edited and gone otherwise, and a box that came and went from a
toolbar would move every other box along the row each time. The top-left
corner, in the viewport's own coordinates, so panning and zooming leave it
where it is -- it is chrome about what the canvas is showing, not something
drawn on the map.

The panel owns no map. It is told how many reveals the focused event has and
where the cap stands, and emits where the cap was moved to; what a cap costs
-- the replay, the twin, the marks -- is the mode's.
"""

from __future__ import annotations

from PySide6.QtCore import Signal
from PySide6.QtWidgets import QFrame, QHBoxLayout, QLabel, QSpinBox, QWidget

#: How far in from the viewport's top-left corner the panel sits. Enough
#: that it reads as floating over the map rather than as part of its edge.
REVEAL_MARGIN = 12

#: The cap that is no cap: the focused event whole, the way the events view
#: draws it with nothing stepping it. The spin box's floor, shown as a word
#: rather than as a number -- "reveal order <= 0" would name no reveal at
#: all, and this row means the opposite.
WHOLE = 0

#: What that floor reads as in the box.
WHOLE_TEXT = "All"


class RevealFilter(QFrame):
    """Caps which of a focused event's reveals the map shows. Owns no map."""

    #: The user moved the cap: show the reveals numbered up to and including
    #: this, or -- :data:`WHOLE` -- the event entire.
    capped = Signal(int)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setObjectName("reveal-filter")
        # Filled and framed: it sits on the map's own artwork, and an
        # unfilled panel would leave the tiles reading through the numbers.
        self.setFrameShape(QFrame.Shape.StyledPanel)
        self.setAutoFillBackground(True)

        self._rows = 0
        # Whether the box is being moved from code to show the mode's cap.
        # QSpinBox has no `activated` to tell a pick from a follow -- the
        # combo boxes' distinction -- so the guard makes it: mirroring the
        # mode must never ask the mode for the move back.
        self._following = False

        self._spin = QSpinBox()
        self._spin.setRange(WHOLE, WHOLE)
        self._spin.setSpecialValueText(WHOLE_TEXT)
        self._spin.setToolTip(
            "Show only the reveals up to this one. The event's later blocks, "
            "its tile swap and its silent tiles are still to come."
        )
        self._spin.valueChanged.connect(self._moved)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(8, 4, 8, 4)
        layout.setSpacing(6)
        self._label = QLabel("Reveal")
        layout.addWidget(self._label)
        layout.addWidget(self._spin)

        # Nothing to cap until a map is up with an event focused.
        self.setEnabled(False)
        self.hide()

    # -- what is on offer ----------------------------------------------------

    def follow(self, rows: int, cap: int) -> None:
        """Show a focused event's ``rows`` reveals, capped at ``cap`` --
        :data:`WHOLE` for the event entire.

        ``rows`` of zero is nothing to step: no event focused, or one with no
        placements. The box goes dead reading "All", which is the truth -- the
        map is showing everything the event has.
        """
        self._rows = rows
        self._following = True
        try:
            self._spin.setRange(WHOLE, rows)
            self._spin.setSuffix(f" of {rows}" if rows else "")
            self._spin.setValue(max(WHOLE, min(rows, cap)))
        finally:
            self._following = False
        self.setEnabled(rows > 0)
        self.setToolTip(
            ""
            if rows
            else "Focus an event in the toolbar's Event box to step its reveals"
        )
        # The row count changes the box's widest reading, and the panel is
        # laid out by hand rather than by a layout that would resize it.
        self.adjustSize()

    def place(self) -> None:
        """Put the panel in its corner of whatever it is parented to, on
        top of it."""
        self.move(REVEAL_MARGIN, REVEAL_MARGIN)
        self.raise_()

    @property
    def cap(self) -> int:
        """Where the cap stands: a reveal number, or :data:`WHOLE`."""
        return self._spin.value()

    def _moved(self, value: int) -> None:
        if not self._following:
            self.capped.emit(value)
