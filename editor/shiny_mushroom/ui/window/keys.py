"""Who gets a key.

Three answers, and the window has to give all three: the bare keys that belong
to the picture, the two commands that belong to the *document* wherever the
keyboard is, and everything else, which belongs to whichever widget has the
focus.
"""

from __future__ import annotations

from contextlib import suppress

from PySide6.QtCore import QEvent, Qt
from PySide6.QtGui import QKeyEvent, QKeySequence
from PySide6.QtWidgets import QMenu, QWidget

from shiny_mushroom.ui.gestures import ARROWS
from shiny_mushroom.ui.window.modes import EditorMode

__all__ = ["KeyRouting"]


class KeyRouting:
    """:class:`~shiny_mushroom.ui.main_window.MainWindow`'s keyboard half."""

    def _edit_keys(self, event: QKeyEvent) -> bool:
        """Handle a key aimed at the picture, reporting whether it was ours.

        Filtered off the view rather than bound as menu shortcuts, because the
        keys an editor wants here -- the arrows, plus and minus, Backspace --
        are *bare* keys other widgets in this window legitimately use, and a
        bare key has no modifier to tell the two uses apart. A shortcut on the
        window would fire while the level number is being typed into the
        toolbar's spin box. Reaching them only when the picture has the keyboard
        is the whole gate.

        Delete is the exception and is bound on the window as well, so it
        deletes what is held from wherever the keyboard is. It can be, because a
        box being typed into *claims* Delete for itself and the shortcut then
        does not fire -- see :meth:`eventFilter` for that negotiation, which the
        arrows and Backspace have no equivalent of. It is still answered here,
        for the presses that reach the view with the action disabled.
        """
        key = event.key()
        shifted = bool(event.modifiers() & Qt.KeyboardModifier.ShiftModifier)
        step = ARROWS.get(key)
        if step is not None and shifted and self._placing is not None:
            # Something in hand: the resize keys shape what the next click
            # places, exactly as they would shape it once placed.
            self.resize_placing(*step)
            return True
        if step is not None:
            if not self._selection:
                # Nothing to move or resize, so the arrow means what it means
                # everywhere else: scroll. Claiming it here would leave the
                # view unable to scroll with the keyboard over an empty
                # selection -- the world branch of :meth:`eventFilter` falls
                # through for the same reason.
                return False
            columns, rows = step
            if shifted:
                self.resize_selection(columns, rows)
            else:
                self.nudge_selection(columns, rows)
            return True
        if key == Qt.Key.Key_V and not (
            event.modifiers() & ~Qt.KeyboardModifier.ShiftModifier
        ):
            # The held object's variant, or the armed one's: forward, and
            # back with Shift. A bare key like the arrows, and for their
            # reason: it is the picture's while the picture has the
            # keyboard, and nobody else's.
            if not self._selection and self._placing is None:
                return False
            self.cycle_variant(-1 if shifted else 1)
            return True
        if key in (Qt.Key.Key_Delete, Qt.Key.Key_Backspace):
            self.delete_selection()
            return True
        if key == Qt.Key.Key_Escape:
            # One key, two things to put down, and the order is the order they
            # were picked up in: arming a placement already dropped the
            # selection, so the thing in hand is the only thing Escape can mean
            # while one is armed.
            if self._area_pick is not None:
                self._cancel_area_pick()
            elif self._bg_placing is not None:
                self._bg_stop_placing()
            elif self._placing is not None:
                self._stop_placing()
            elif self._painting:
                self._bg_hand.land()
                self._bg_select(frozenset())
            else:
                self._select(frozenset())
            return True
        # The unshifted spellings too: '=' is what '+' is printed on, and '_'
        # what '-' is, so an editor that only took the shifted ones would be
        # asking for a modifier that changes nothing.
        if key in (Qt.Key.Key_Plus, Qt.Key.Key_Equal):
            self.reorder_selection(+1)
            return True
        if key in (Qt.Key.Key_Minus, Qt.Key.Key_Underscore):
            self.reorder_selection(-1)
            return True
        return False

    def _of_this_window(self, widget: QWidget) -> bool:
        """Whether ``widget`` belongs to this window or a dialog of its --
        by walking parents, since ``isAncestorOf`` stops at the window
        boundary a modeless dialog sits behind."""
        seen: QWidget | None = widget
        while seen is not None:
            if seen is self:
                return True
            seen = seen.parentWidget()
        return False

    def _adopt_shortcuts(self, dialog: QWidget) -> None:
        """Give ``dialog`` the window's own keyboard.

        A modeless dialog is its own window, and a window-context shortcut
        is dead in any window but its own -- so Ctrl+Z over a table editor
        would take back a spin box's last keystroke while the menu's Undo
        sits inert. Adding the menu bar's actions to the dialog makes them
        fire there too: the *same* action objects, so what is greyed out is
        greyed out everywhere, and the ``ShortcutOverride`` filter settles
        undo and redo exactly as it does over the panels.

        A dialog that must keep a key for itself simply keeps claiming it
        the way any widget does -- a spin box's Delete, the dialog's own
        Escape -- since a claimed key never reaches the shortcut at all.

        The menus are walked as widgets, never through ``QAction.menu()``:
        PySide6 hands that menu back with ownership attached, and the
        garbage collector then deletes the real menu out of the bar.
        """
        dialog.addActions(
            [
                action
                for menu in self.menuBar().findChildren(QMenu)
                for action in menu.actions()
                # A submenu's own row and a separator carry no shortcut, so
                # keying on the shortcut also skips everything unkeyed.
                if action.shortcuts()
            ]
        )

    @property
    def hand_armed(self) -> bool:
        """Whether the mode in front has a tool in hand -- a record or a
        tile to place, a stamp, a Map16 word."""
        if self._mode is EditorMode.WORLD:
            return self._world.armed
        if self._mode is EditorMode.MAP16:
            return self._map16.armed
        return (
            self._placing is not None
            or self._bg_placing is not None
            or self._area_pick is not None
        )

    def put_hand_down(self) -> None:
        """Put down whatever the mode in front has in hand, and nothing
        else: the selection stays, unlike Escape over the picture, which
        takes the hand first and the selection on the next press."""
        if self._mode is EditorMode.WORLD:
            self._world.stop_placing()
        elif self._mode is EditorMode.MAP16:
            self._map16.stop_placing()
        elif self._area_pick is not None:
            # A pick for the Level Graphics dialog's tiles page is a hand
            # too: putting it down brings the dialog back with no area.
            self._cancel_area_pick()
        else:
            self._stop_all_placing()

    def _wants_the_level_key(self, event: QKeyEvent) -> bool:
        """Whether ``event`` is a key the level's own commands must answer,
        whatever is holding the keyboard.

        Undo and redo, and only those. They are commands about the *document*
        rather than about whatever widget the hands happen to be in, and the
        widgets this window and its table editors are full of -- every spin
        box in the properties panel, the level number, the search box --
        claim Ctrl+Z for their own one-line text history. Left to Qt, an
        undo pressed while a field has the keyboard takes back a character
        nobody was typing instead of the edit the user is looking at.

        **Only while the action is enabled.** With nothing to undo there is
        nothing to take the key for, and a field may as well have it.

        A panel that genuinely needs one of these for itself is the exception
        this leaves room for: it would be named here, and everything else keeps
        the level's answer. There is no such panel yet.
        """
        pressed = QKeySequence(event.keyCombination())
        return any(
            action.isEnabled() and pressed in action.shortcuts()
            for action in (self.menu_actions.undo, self.menu_actions.redo)
        )

    def _follow_the_keyboard(self, old, now) -> None:  # noqa: ANN001 - Qt's widgets
        """Watch whatever holds the keyboard, and stop watching what let it go.

        The offer Qt makes before running a shortcut goes to the **focus
        object** and to nothing else, so that one widget is the only thing
        worth listening to. Watching it rather than the application is the
        difference between being asked about one widget's keys and being
        asked about every event in the program: an application-wide filter
        is called for all of them, each call crossing out of Qt and into
        Python, and putting one table editor's cells on screen is tens of
        thousands.

        The view keeps its own filter through this -- that half is about the
        keys aimed at the picture, and has nothing to do with focus.
        """
        if old is not None and old is not self.view:
            with suppress(RuntimeError):
                # A widget can lose the keyboard by being destroyed, and the
                # signal carries it as it goes.
                old.removeEventFilter(self)
        if now is not None:
            now.installEventFilter(self)

    def eventFilter(self, watched, event) -> bool:  # noqa: N802, ANN001 - Qt override
        """Two filters, on two objects, answering two different questions.

        **On the view**: take the bare editing keys off it before it scrolls on
        them. A scroll area answers the arrows by scrolling, which is the right
        answer when nothing is selected and the wrong one when something is.
        Watching the view rather than the application is what makes those keys
        the picture's alone -- see :meth:`_edit_keys`.

        **On whatever holds the keyboard**: settle who owns a level command's
        key. Before running a shortcut, Qt offers the key to the focused
        widget as a ``ShortcutOverride``, and a widget that answers "mine"
        gets it as an ordinary press instead -- which is how a spin box keeps
        Ctrl+Z for its own text. The offer is made to the widget, not to this
        window, so it can only be caught on the widget -- which is what
        :meth:`_follow_the_keyboard` keeps this filter sitting on. Leaving it
        *ignored* is what says "not yours", and consuming it stops anything
        downstream saying otherwise; Qt then runs the window's own action.
        Nothing is claimed the other way, so every key this window does not
        name -- Delete in a field being typed into, and the rest of them --
        still belongs to whoever has the keyboard.

        The gate is the widget's ancestry, not this window being active: the
        table editors are their own windows carrying the same actions -- see
        :meth:`_adopt_shortcuts` -- and undo pressed in one of their spin
        boxes means the document there too.
        """
        if (
            event.type() == QEvent.Type.ShortcutOverride
            and isinstance(watched, QWidget)
            and self._of_this_window(watched)
            and self._wants_the_level_key(event)
        ):
            event.ignore()
            return True
        if (
            event.type() == QEvent.Type.KeyPress
            and event.key() == Qt.Key.Key_Escape
            and not event.modifiers()
            and watched is not self.view
            and isinstance(watched, QWidget)
            and watched.window() is self
            and self.hand_armed
        ):
            # Escape puts the tool down from wherever the keyboard is in this
            # window -- a palette's list, a search box, a spin box -- because
            # the ghost is on the picture whoever has the keys, and reaching
            # for the canvas first to put it down is a step nobody meant.
            # Only while something is in hand: with nothing armed the key is
            # the widget's own, as it always was. A table editor is its own
            # window and keeps Escape to close itself.
            self.put_hand_down()
            return True
        if watched is self.view and event.type() == QEvent.Type.KeyPress:
            if self._mode is EditorMode.WORLD:
                # Escape, and the arrows while a sprite is selected -- those
                # nudge it, a map pixel a press, eight with Shift. Any other
                # arrow falls through to the view's scrolling, the right
                # answer for a selection that cannot be moved.
                if event.key() == Qt.Key.Key_Escape and self._world.escape():
                    return True
                # Backspace deletes here as it does over the level; Delete
                # itself arrives through the menu action's shortcut.
                if event.key() == Qt.Key.Key_Backspace and self._world.can_copy:
                    self._world.delete_selection()
                    return True
                steps = {
                    Qt.Key.Key_Left: (-1, 0),
                    Qt.Key.Key_Right: (1, 0),
                    Qt.Key.Key_Up: (0, -1),
                    Qt.Key.Key_Down: (0, 1),
                }
                step = steps.get(event.key())
                if step is not None:
                    by = (
                        8
                        if event.modifiers() & Qt.KeyboardModifier.ShiftModifier
                        else 1
                    )
                    if self._world.arrow(step[0] * by, step[1] * by):
                        return True
            elif self._mode is EditorMode.MAP16:
                # Escape puts the tool, the float and the selection down in
                # that order; Backspace deletes, as it does everywhere. The
                # arrows fall through to the view's scrolling.
                if event.key() == Qt.Key.Key_Escape and self._map16.escape():
                    return True
                if event.key() == Qt.Key.Key_Backspace and self._map16.can_copy:
                    self._map16.delete_selection()
                    return True
            elif self._doc is not None and self._edit_keys(event):
                return True
        return super().eventFilter(watched, event)
