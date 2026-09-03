"""The mode bar: the three editing environments as a row of square buttons.

The Go menu's own rows -- Level, World Map, Map16 Tiles -- put on a toolbar
the way the view bars put the View toggles on one (:mod:`view_bar`): the same
:class:`~PySide6.QtGui.QAction` objects, so a button and its menu row check,
grey and trigger together and the window syncs nothing twice. The window
keeps the checks true to the mode (:meth:`MainWindow.sync_mode_rows`), which
is why the three are not an exclusive :class:`~PySide6.QtGui.QActionGroup`:
a checked row's key toggles it *off* -- Ctrl+2 is the way out of the map as
well as in -- and an exclusive group would refuse the uncheck.

Registered under every environment, since it is how each is reached from
the others, and leftmost on the row so it reads as the row's heading: the
bar beside it is whichever environment's picker is up.
"""

from __future__ import annotations

from PySide6.QtWidgets import QWidget

from shiny_mushroom.ui.icons import Icon
from shiny_mushroom.ui.menus import Actions
from shiny_mushroom.ui.toolbars import IconBar

#: Each environment's mark, by its :class:`Actions` field name, in the order
#: the buttons sit -- which is also the order Ctrl+Tab walks them.
ICONS: dict[str, Icon] = {
    "level_mode": Icon.LEVEL,
    "world_map": Icon.WORLD_MAP,
    "map16_mode": Icon.MAP16,
}


class ModeBar(IconBar):
    """The three environments' rows as buttons. Owns no state: every button
    is one of the window's menu actions."""

    def __init__(self, actions: Actions, parent: QWidget | None = None) -> None:
        super().__init__("Editor", parent)
        # Named so Qt can save and restore it with the window state, and
        # fixed in place like the rest of the row.
        self.setObjectName("mode-bar")
        self.setMovable(False)
        for field, icon in ICONS.items():
            self.wear(getattr(actions, field), icon)
