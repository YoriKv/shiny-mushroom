"""Where you have been: Back and Forward over the levels you have opened.

A browser's trail over *level* views (:mod:`shiny_mushroom.navigation`): each
place is a level and the corner of it you were looking at, so going back
restores the view rather than only the level. The world map sits outside it --
the mode toggle is already the way back out of the map.

The mouse's two side buttons walk it as well as the Go menu's rows, which is
why the window's own ``mousePressEvent`` is here: it is the one gesture in the
Go menu the menu cannot show.
"""

from __future__ import annotations

from PySide6.QtCore import Qt

from shiny_mushroom.level import BLOCK
from shiny_mushroom.navigation import Place
from shiny_mushroom.ui.gestures import block_center
from shiny_mushroom.ui.window.modes import EditorMode

__all__ = ["Trailing"]


class Trailing:
    """:class:`~shiny_mushroom.ui.main_window.MainWindow`'s trail half."""

    @property
    def _may_walk_the_trail(self) -> bool:
        """Whether Back and Forward mean anything at all just now.

        The trail is a browser over *level* views, so the world map sits
        outside it: Back would have to leave the mode implicitly, and the
        toggle already is the way back. Asked here as well as in
        :meth:`sync_go_menu` because the menu rows are not the only door --
        the mouse's side buttons come straight in.
        """
        return self._mode is not EditorMode.WORLD

    def go_back(self) -> None:
        """Return to the last place you were looking at."""
        if self._may_walk_the_trail and self._may_leave_for(self._trail.behind):
            self._travel(self._trail.back())

    def go_forward(self) -> None:
        """Go forward again, after going back."""
        if self._may_walk_the_trail and self._may_leave_for(self._trail.ahead):
            self._travel(self._trail.forward())

    def mousePressEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        """The mouse's two side buttons walk the trail, as they do in a browser.

        A window-wide gesture rather than the picture's, which is why it is
        caught here: every widget that does not want a press leaves it to its
        parent, so a button nothing else claims arrives at the window whether
        it was pressed over the level, over the gray around it or over a dock.
        The canvas declines them outright -- see
        :data:`~shiny_mushroom.ui.canvas.SIDE_BUTTONS` -- because a picture
        that accepted them would be where they stopped.

        Not a shortcut on the two menu rows, because a shortcut is a key: Qt
        has no way to say "this action is also that button", so the buttons are
        the one gesture in the Go menu that the menu cannot show.
        """
        if event.button() == Qt.MouseButton.BackButton:
            self.go_back()
        elif event.button() == Qt.MouseButton.ForwardButton:
            self.go_forward()
        else:
            super().mousePressEvent(event)

    def _travel(self, place: Place | None) -> None:
        """Go to ``place``: its level, scrolled to where you were.

        Two paths, and which one is taken is the whole of the complication --
        the same one a search jump has. A place in the level already on the
        canvas needs no load and is reached at once; anywhere else has to wait
        for an emulator round trip, so the place is *held* and served when the
        load comes back.

        Note the current view **before** leaving, so that coming back the other
        way returns to where you actually were rather than to wherever this
        level last opened.
        """
        if place is None:
            return
        self._note_where_we_are_looking()
        if place.level == self._level and self._snapshot is not None:
            self._going_to = None
            self.view.center_on(block_center(place.column, place.row))
            return
        self._going_to = place
        self.load_level(place.level)

    def _note_where_we_are_looking(self) -> None:
        """Update the place you are standing on with the view you have of it.

        What makes Back restore a *view* rather than only a level. Read at the
        moment of leaving rather than followed continuously, because the answer
        only matters when somewhere else is about to be asked for.
        """
        looking = self.view.looking_at
        self._trail.look_at(looking.x() // BLOCK, looking.y() // BLOCK)

    def _arrive(self, level: int) -> None:
        """Record that a level has been arrived at, and serve a pending travel.

        A load that was asked for **by** the trail must not be recorded as a new
        place: it would truncate the forward branch it just walked into, so
        Forward would stop working the moment Back was used.
        """
        going, self._going_to = self._going_to, None
        if going is not None and going.level == level:
            self.view.center_on(block_center(going.column, going.row))
            return
        looking = self.view.looking_at
        self._trail.record(Place(level, looking.x() // BLOCK, looking.y() // BLOCK))

    def sync_go_menu(self) -> None:
        # Ctrl+M is symmetric with what `_may_walk_the_trail` refuses: the way
        # out of the world map is the toggle that led into it.
        walkable = self._may_walk_the_trail
        self.menu_actions.go_back.setEnabled(walkable and self._trail.can_go_back)
        self.menu_actions.go_forward.setEnabled(walkable and self._trail.can_go_forward)
