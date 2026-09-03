"""Which toolbars each editing environment puts up.

One registry and one switch: a bar is registered under the environments it
belongs to -- or under all of them -- and entering an environment puts its
bars up and takes every other environment's down. A new environment, or a
new bar, is one ``add`` call rather than another hand-written swap in the
window's chrome code.

Enablement is not owned here. Whether a bar has anything to offer -- a
cartridge to pick levels from, a captured map -- stays with the window,
which knows; this registry only answers whether the bar belongs on screen
in the current environment.

A bar can go down two ways, because Qt gives two. Hidden, freeing its row,
which is the default; or merely disabled, for a bar whose visibility is not
the mode's to take -- the find bar is the user's to show and hide, so the
mode only greys it.

``QMainWindow.restoreState`` restores toolbar visibility from the last
session, which can resurrect a bar the current environment keeps down;
:meth:`ModeToolbars.reassert` puts the environment's answer back on top.

:class:`IconBar` is the other half of what every bar here shares: the icon
size, the icon-only buttons, and re-baking the marks when the theme changes.
"""

from __future__ import annotations

from collections.abc import Callable, Hashable, Iterable

from PySide6.QtCore import QEvent, QSize, Qt
from PySide6.QtGui import QAction, QKeySequence
from PySide6.QtWidgets import QMainWindow, QToolBar, QWidget

from shiny_mushroom.ui.icon_font import palette_icon
from shiny_mushroom.ui.icons import Icon

#: The box every bar draws an action's mark in. One number for every toolbar,
#: because they sit on the same rows and a bar half a size out reads as a
#: mistake. Left to the platform default a bar stacked over the canvas would
#: take a visible bite out of the editing surface -- 24 px, and larger on some
#: desktops -- so every :class:`IconBar` says it.
ICON = 20

#: A square button wearing a menu action's mark, a touch larger than the mark.
BUTTON = 28


def add_action(bar: QToolBar, text: str, slot: Callable[[], object]) -> QAction:
    """Put a button on ``bar`` that calls ``slot``, and hand the action back.

    Handed back rather than dropped, because a bar's own buttons are what it
    greys as what they act on comes and goes -- there is nothing to step
    through until a cartridge is open.
    """
    action = QAction(text, bar)
    action.triggered.connect(slot)
    bar.addAction(action)
    return action


class IconBar(QToolBar):
    """A toolbar whose buttons wear marks from the icon font.

    **A baked pixmap goes stale.** The tint and the resolution are in it, so a
    theme switch or a drag to a differently scaled monitor leaves yesterday's
    colour at the wrong size. Every face a bar puts up registers itself here as
    it is added, and the whole row is re-baked when the palette changes -- one
    list rather than each bar spelling its buttons out a second time.

    The text stays on every action even though the buttons never show it: it is
    what a screen reader announces, and what Qt puts in the overflow menu when
    the bar is too narrow for its own row.
    """

    def __init__(self, title: str, parent: QWidget | None = None) -> None:
        super().__init__(title, parent)
        self.setIconSize(QSize(ICON, ICON))
        self.setToolButtonStyle(Qt.ToolButtonStyle.ToolButtonIconOnly)
        self._faces: list[tuple[QAction, Icon]] = []

    def add_icon_action(
        self, icon: Icon, text: str, slot: Callable[[], object]
    ) -> QAction:
        """Put a button wearing ``icon`` on the bar, and hand the action back."""
        return self.face(add_action(self, text, slot), icon)

    def wear(self, action: QAction, icon: Icon) -> QAction:
        """Put one of the window's menu actions on the bar as a square button
        wearing ``icon``.

        The action stays the menu's: it is checked, greyed and triggered
        there and here as one object, so there is nothing to keep in step.
        The menu row stays text-only, and the button -- which has no text --
        carries the row's key in its tooltip, once, though an action shared
        between bars passes here twice.
        """
        action.setIconVisibleInMenu(False)
        keys = action.shortcut()
        if not keys.isEmpty() and not action.property("tooltip-keyed"):
            native = keys.toString(QKeySequence.SequenceFormat.NativeText)
            action.setToolTip(f"{action.toolTip()} ({native})")
            action.setProperty("tooltip-keyed", True)
        self.addAction(action)
        self.face(action, icon)
        button = self.widgetForAction(action)
        if button is not None:
            button.setFixedSize(BUTTON, BUTTON)
        return action

    def face(self, action: QAction, icon: Icon) -> QAction:
        """Give ``action`` ``icon``'s mark and keep it in step with the theme.

        For an action the bar did not create -- a view toggle is one of the
        window's menu actions, and belongs to the menu.
        """
        self._faces.append((action, icon))
        self._bake(action, icon)
        return action

    def changeEvent(self, event: QEvent) -> None:  # noqa: N802 - Qt override
        super().changeEvent(event)
        # A theme switch hands every widget a new palette; the baked marks are
        # the one part of a bar Qt cannot recolour by itself.
        if event.type() == QEvent.Type.PaletteChange:
            for action, icon in self._faces:
                self._bake(action, icon)

    def _bake(self, action: QAction, icon: Icon) -> None:
        action.setIcon(
            palette_icon(
                icon,
                self.palette(),
                QSize(ICON, ICON),
                self.devicePixelRatioF() or 1.0,
            )
        )


class ModeToolbars:
    """The registry: which bars belong to which editing environment."""

    def __init__(self) -> None:
        self._bars: list[tuple[QToolBar, frozenset[Hashable] | None, bool]] = []
        self._mode: Hashable | None = None

    def add(
        self,
        bar: QToolBar,
        modes: Iterable[Hashable] | None = None,
        *,
        hides: bool = True,
        head: bool = False,
    ) -> None:
        """Register ``bar`` as belonging to ``modes`` -- to every environment
        when ``None``. With ``hides`` off the bar is disabled rather than
        hidden outside its environments. ``head`` registers it ahead of every
        bar so far, which is where :meth:`order` then keeps it."""
        owners = None if modes is None else frozenset(modes)
        entry = (bar, owners, hides)
        if head:
            self._bars.insert(0, entry)
        else:
            self._bars.append(entry)

    @property
    def mode(self) -> Hashable | None:
        """The environment last entered."""
        return self._mode

    def enter(self, mode: Hashable) -> None:
        """Put up ``mode``'s bars and take down every other environment's."""
        self._mode = mode
        self.reassert()

    def order(self, window: QMainWindow) -> None:
        """Put the bars back in registration order along their rows.

        A restored arrangement orders the bars it was saved with and leaves
        any it never knew where they were added -- after every other, for a
        layout saved before the bar existed. Every bar is fixed in place, so
        registration order is the only order there is, and re-adding each to
        its area in turn -- which moves a managed bar to the end -- restores
        it. Bars the window does not manage yet are left alone.
        """
        for bar, _owners, _hides in self._bars:
            area = window.toolBarArea(bar)
            if area != Qt.ToolBarArea.NoToolBarArea:
                window.addToolBar(area, bar)

    def reassert(self) -> None:
        """Reapply the current environment's arrangement -- after
        ``restoreState``, which may have brought back another one's bars."""
        for bar, owners, hides in self._bars:
            up = owners is None or self._mode in owners
            if hides:
                bar.setVisible(up)
            else:
                bar.setEnabled(up)
