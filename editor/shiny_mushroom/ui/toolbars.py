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
"""

from __future__ import annotations

from collections.abc import Callable, Hashable, Iterable

from PySide6.QtGui import QAction
from PySide6.QtWidgets import QToolBar


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
    ) -> None:
        """Register ``bar`` as belonging to ``modes`` -- to every environment
        when ``None``. With ``hides`` off the bar is disabled rather than
        hidden outside its environments."""
        owners = None if modes is None else frozenset(modes)
        self._bars.append((bar, owners, hides))

    @property
    def mode(self) -> Hashable | None:
        """The environment last entered."""
        return self._mode

    def enter(self, mode: Hashable) -> None:
        """Put up ``mode``'s bars and take down every other environment's."""
        self._mode = mode
        self.reassert()

    def reassert(self) -> None:
        """Reapply the current environment's arrangement -- after
        ``restoreState``, which may have brought back another one's bars."""
        for bar, owners, hides in self._bars:
            up = owners is None or self._mode in owners
            if hides:
                bar.setVisible(up)
            else:
                bar.setEnabled(up)
