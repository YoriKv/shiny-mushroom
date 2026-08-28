"""The canvas's right-click menu: the rows, and the menu built from them.

The menu is a **second handle on gestures the editor already has**, never a
place where a new one lives. Cut, Copy, Duplicate and Delete are the Edit
menu's own actions, added to this menu as they are -- one object, one enabled
state, one shortcut printed beside the caption. Pick is the Alt+click
eyedropper; Set destination, Delete entry and their kin are the properties
panel's buttons, fired through the same committed-field path; the test-run rows
are the middle click. What the menu adds is only that the rows are found under
the pointer, on the thing they are about.

What that thing *is* belongs to whoever owns the document -- the window for a
level, the world map mode for the map -- so this module holds nothing but the
row and the builder: an owner describes its rows as values, and
:func:`build` turns them into a ``QMenu`` it can pop up.
"""

from __future__ import annotations

from collections.abc import Callable, Sequence
from dataclasses import dataclass

from PySide6.QtGui import QAction
from PySide6.QtWidgets import QMenu, QWidget


@dataclass(frozen=True)
class Row:
    """One row the owner of a document offers for the spot under the pointer.

    A value rather than a ``QAction`` so a Qt-free-looking description can be
    handed across from a ``QObject`` with no widget to parent an action on --
    and so a test can read the rows without a menu ever being shown.
    """

    text: str
    act: Callable[[], None]
    enabled: bool = True
    #: What to print beside the caption, for a row that is a gesture's twin:
    #: the key or the click that does the same thing without the menu.
    shortcut: str = ""


#: A separator between two groups of rows. Doubled, leading and trailing
#: separators are dropped by :func:`build`, so an owner can put one after
#: every group and let an empty group vanish with its separator.
SEPARATOR = None

#: What an owner describes: its own rows, the Edit menu's actions as they
#: are, and separators between the groups.
Rows = Sequence["Row | QAction | None"]


def build(parent: QWidget, rows: Rows) -> QMenu | None:
    """The menu ``rows`` describe, or ``None`` when there is nothing to show.

    An existing ``QAction`` is added as it is, so it keeps its enabled state,
    its shortcut and its slot; a :class:`Row` becomes an action owned by the
    menu, which is the right owner because the menu is built for one press
    and thrown away with it.
    """
    menu = QMenu(parent)
    pending_separator = False
    for row in rows:
        if row is SEPARATOR:
            pending_separator = not menu.isEmpty()
            continue
        if pending_separator:
            menu.addSeparator()
            pending_separator = False
        if isinstance(row, QAction):
            menu.addAction(row)
            continue
        # The gesture's name rides after a tab, which a menu renders in the
        # shortcut column -- printed, never bound: the canvas already answers
        # the gesture, and a second binding would fire it twice.
        text = f"{row.text}\t{row.shortcut}" if row.shortcut else row.text
        made = QAction(text, menu)
        made.setEnabled(row.enabled)
        # Without the `checked` flag `triggered` carries: a row's callback
        # takes nothing, and a bound argument it does take would be handed
        # the flag instead of its own value.
        made.triggered.connect(lambda _checked=False, act=row.act: act())
        menu.addAction(made)
    if menu.isEmpty():
        menu.deleteLater()
        return None
    return menu
