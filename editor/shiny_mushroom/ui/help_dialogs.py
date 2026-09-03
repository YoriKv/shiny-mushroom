"""The Help menu's two modal dialogs: the shortcut guide and About.

The guide is **generated from the live menu bar** rather than a hand-written
table. Every keyboard shortcut in this window is registered on a ``QAction``
that has a menu row, so walking the menus keeps the guide correct for free: a
new action with a key shows up here without anyone remembering to add it, and a
key that changes changes in one place.

**Hidden rows are read too.** Half of View and most of Level leave the menu
while the other environment is being edited -- the map's toggles are out while a
level is up, and the level's while the map is -- but both halves are keys this
application answers to, and the guide is read to find out what those are rather
than what can be pressed this second. The pairs that share a key say which
picture they mean in their own labels.

What no menu holds is appended as static sections, and is the genuinely
hand-maintained part: the bare editing keys the window filters off the canvas
(:meth:`~shiny_mushroom.ui.main_window.MainWindow._edit_keys`), the mouse
gestures the two canvases answer to, the keys a focused panel claims for
itself, and the test window's pad -- a separate window with a toolbar rather
than a menu bar of its own. A drag, a held modifier and a button that means four
different things by mode have no menu row that could say so.

An action whose menu label is rebuilt at runtime -- Save and Revert name the
document they would write, Test the one it would run -- sets a ``guideLabel``
property to pin the text the guide shows.
"""

from __future__ import annotations

import re

from PySide6.QtCore import Qt
from PySide6.QtGui import QAction, QKeySequence, QPixmap
from PySide6.QtWidgets import (
    QDialog,
    QDialogButtonBox,
    QFrame,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QMenu,
    QScrollArea,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import APP_NAME, __version__, mesen_keys, resources
from shiny_mushroom.pad_bindings import BUTTON_ORDER
from shiny_mushroom.ui.controls_dialog import bindings as pad_bindings

__all__ = ["AboutDialog", "ShortcutGuide", "shortcut_sections"]

AUTHOR = "Epi"
HOMEPAGE = "https://github.com/YoriKv/shiny-mushroom"
SA1_PACK = "https://github.com/VitorVilela7/SMW-SA1-Pack"

# The keys and gestures the level canvas answers to, in the order a hand finds
# them: look around, pick something out, move it, put it down.
#
# Every row that is not universal names the mode it belongs to, because the same
# button means different things across the level's two editing modes -- Layer 1
# & Sprites, where the selection is records out of the object and sprite
# streams, and Layer 2, where it is blocks of a pattern. Which one is up is the
# question this section exists to answer.
PIXEL_EDITOR: tuple[tuple[str, str], ...] = (
    ("Pan the view", "Hold Space + drag"),
    ("Pick a tool", "1 to 9, top to bottom of the rail"),
    ("Paint, draw or fill with the tool", "Drag or click"),
    ("Take the colour under the pointer", "Right-click, with any tool"),
    ("Select a rectangle; a square", "Drag with Select; Shift + drag"),
    ("Select the whole tile", "Double-click with Select"),
    ("Move the selected pixels", "Drag from inside the selection"),
    ("Land moved pixels, or drop the selection", "Esc, or click away"),
    ("Cut, copy, paste, delete, select all", "Ctrl+X, Ctrl+C, Ctrl+V, Del, Ctrl+A"),
    ("Flip the selection", "H, V"),
    ("Rotate a square selection", "C, X"),
    ("Undo, redo a stroke", "Ctrl+Z, Ctrl+Y"),
    ("Zoom, anchored on the pointer", "Ctrl + Scroll, Ctrl+=, Ctrl+-"),
    ("Grid: none, tiles, pixels", "G"),
    ("Change the selected colour", "Double-click a swatch"),
    ("Write the picture into its tiles", "Ctrl+S"),
)

LEVEL_CANVAS: tuple[tuple[str, str], ...] = (
    ("Pan the view", "Hold Space + drag"),
    ("Zoom, anchored on the pointer", "Ctrl + Scroll"),
    ("Select what is under the pointer", "Click"),
    ("Add to or take from the selection", "Shift + click"),
    ("Pick the next thing down a stack", "Click it again"),
    ("Box a selection", "Drag"),
    ("Move what is held", "Drag from on it"),
    ("Resize the held object", "Drag its right or bottom edge"),
    ("Nudge the selection a block", "Arrow keys"),
    ("Resize the held object a block", "Shift + arrows"),
    ("Cycle the held object's variant, forward or back", "V, Shift + V"),
    # Both also shape what the Create panel armed: the ghost is what the
    # next click places, so the keys that would shape it placed shape it
    # in hand.
    ("Resize or re-variant what is in hand", "Shift + arrows, V, Shift + V"),
    ("Bring forward / send back", "+ / -"),
    ("Delete the selection", "Del or Backspace"),
    # One key, several things to put down, and the order is the order they were
    # picked up in -- see `MainWindow._edit_keys`.
    ("Put down what is in hand, or the selection", "Esc"),
    # The eyedropper: over a record it arms the Create panel, over the Layer 2
    # pattern the tile. On the surround -- or over nothing it can pick -- the
    # same button puts the tool down instead.
    ("Pick up what is under the pointer", "Right-click or Alt + click"),
    ("Put the tool down", "Esc, or right-click over nothing"),
    ("Place what the Create panel armed", "Click"),
    ("Place it and keep the tool armed", "Shift + click"),
    ("Open the level a held screen exit leads to", "Double-click"),
    # Not the canvas's own gesture in the sense the rest are: it names where a
    # test run starts rather than editing anything, and the same click on the
    # marked block takes the override away again.
    ("Set or clear where a test run starts", "Middle-click"),
    # The window's, not the canvas's -- the picture declines the two side
    # buttons so they reach the window from wherever they were pressed. Listed
    # here because Qt cannot bind a button to an action, so the Go menu's rows
    # cannot show them (see `MainWindow.mousePressEvent`).
    ("Back / forward along the trail", "Mouse 4 / Mouse 5"),
    ("Paint with the armed tile (Layer 2)", "Click or drag"),
)

# The world map's canvas. Its selection is a row of one of the map's tables --
# a path exit, a warp trigger, a sprite, an event's placement -- which is what
# makes a nudge a pixel rather than a block: those records address the map in
# pixels, and eight of them is a tile.
WORLD_CANVAS: tuple[tuple[str, str], ...] = (
    ("Select what is under the pointer", "Click"),
    ("Add to or take from the selection", "Shift + click"),
    ("Pick the next record down a stack", "Click it again"),
    ("Box a selection", "Drag"),
    ("Move the record under the pointer", "Drag"),
    ("Duplicate a placement instead of moving it", "Ctrl + drag"),
    ("Nudge a pixel / eight pixels", "Arrow keys / Shift + arrows"),
    ("Delete the selection", "Del or Backspace"),
    ("Put down what is in hand, or the selection", "Esc"),
    ("Place what the Tiles panel armed", "Click or drag"),
    ("Flip the selected Layer 2 block: mirrored as one picture", "H, V"),
    ("Flip each selected Layer 2 tile where it stands", "Shift + H, Shift + V"),
    ("Pick up what is under the pointer", "Right-click or Alt + click"),
    ("Put the tool down", "Esc, or right-click over nothing"),
    ("Open the level a held tile loads", "Double-click"),
    ("Set or clear where a test run starts", "Middle-click"),
    ("Cycle a level's completion for the test run", "Ctrl + middle-click"),
)

# The Tilemap editor's canvas: its gestures over the sheet's two grids,
# with the VRAM dock holding what a click draws.
MAP16_CANVAS: tuple[tuple[str, str], ...] = (
    ("Select a tile or cell", "Click"),
    ("Box a rectangle of them", "Drag"),
    ("Edit whole tiles, or their 8x8 cells", "1, 2"),
    ("Flip the selected block: mirrored as one picture", "H, V"),
    ("Flip each selected tile where it stands", "Shift + H, Shift + V"),
    ("Delete the selection", "Del or Backspace"),
    ("Put down what is in hand, or the selection", "Esc"),
    ("Draw with what is in hand", "Click or drag"),
    ("Pick up the cell's word or the whole tile", "Right-click or Alt + click"),
    ("Grab a region as a stamp -- the VRAM grid too", "Right-drag"),
)

# Keys a focused widget claims for itself, which is why they are not on the menu
# bar: while one has the keyboard the canvas's own bare keys are none of its
# business, and the arrows mean the swatch grid or the picker's list rather than
# the selection behind the panel.
PANEL_KEYS: tuple[tuple[str, str], ...] = (
    ("Move the colour selection", "Arrow keys"),
    ("Edit the selected colour", "Enter or double-click"),
    ("Step the level picker's list", "Up / Down, PgUp / PgDn"),
    ("Give the picture back the keyboard", "Esc"),
    ("Close a table editor", "Esc"),
    # The one bare key the canvas shares: a tool in hand is on the picture
    # whoever has the keyboard, so the key that puts it down works from any
    # widget in the window -- see `KeyRouting.eventFilter`.
    ("Put down what is in hand, wherever the keyboard is", "Esc"),
)

# The test window's own keys. It is a second top-level window with a toolbar
# rather than a menu bar, so nothing above can reach it -- and while it has the
# keyboard the arrows are the pad's, not the editor's. The pad half is read from
# the stored bindings so the two cannot drift apart -- and so that a guide
# opened after somebody has imported their MesenCE controls shows theirs rather
# than the ones the editor ships with. The toolbar half is the three things
# somebody testing a level reaches for.
TEST_WINDOW: tuple[tuple[str, str], ...] = (
    ("Restart the run", "Ctrl+R"),
    ("Pause", "F6"),
    ("Complete the level / take the secret exit", "F7 / Shift+F7"),
)


def _pad_keys() -> list[tuple[str, str]]:
    """The pad, as ``(button, what presses it)`` in the pad's own order.

    Read from the stored bindings rather than written out again, so a rebinding
    -- or an import over the lot of them -- is a rebinding here too. A button
    can have several codes on it, keyboard and controller both, so each row is
    a list rather than a single key.

    Named in Mesen's spelling, which is the spelling the Test Controls dialog
    shows and the spelling the file the bindings came from uses. A button
    nothing is bound to is left out: an empty row says less than no row.
    """
    found = pad_bindings()
    rows: list[tuple[str, str]] = []
    for button in BUTTON_ORDER:
        bound = found.for_button(button)
        if not bound:
            continue
        # "Pad", because a pad button and the key that presses it are often the
        # same word -- Up is pressed with Up -- and a row reading "Up  Up" says
        # nothing about which of the two columns is the keyboard.
        rows.append(
            (
                f"Pad {button.name.title()}",
                " / ".join(mesen_keys.key_name(code) for code in bound),
            )
        )
    return rows


def _key_text(action: QAction) -> str:
    """The key or keys ``action`` answers to, or ``""`` when it has none.

    All of them, not the first: an action carries a second sequence here only
    where one was added on purpose -- Ctrl+= beside Ctrl++ because the shifted
    spelling is the same physical key, Ctrl+Shift+Z beside the platform's own
    redo -- and the point of adding it was that a hand might reach for it.
    """
    return " / ".join(
        sequence.toString(QKeySequence.SequenceFormat.NativeText)
        for sequence in action.shortcuts()
    )


def _label_text(action: QAction) -> str:
    pinned = action.property("guideLabel")
    text = str(pinned) if pinned else action.text()
    # "&" marks the mnemonic and "&&" is an escaped one, so a single pass that
    # drops the marker and keeps what follows it settles both: "&Save" is Save,
    # and "Layer 1 && Sprites" is Layer 1 & Sprites.
    return re.sub(r"&(.)", r"\1", text).strip()


def _menu_entries(menu: QMenu, prefix: str = "") -> list[tuple[str, str]]:
    """Every ``(label, keys)`` pair in ``menu``, submenus flattened in place.

    Actions with no key are dropped -- they are reachable by mouse and the menu
    itself is their documentation. A submenu's *own* key is kept where it has
    one, since a key that acts on a whole group belongs to the group rather than
    to any one of its rows.

    **A submenu's rows are named after it**, because flattening otherwise loses
    the only thing that told two of them apart: the two Editing groups are the
    same layers under the same digits, and which picture they mean is the name
    of the group they are in rather than anything on the row.
    """
    entries: list[tuple[str, str]] = []
    for action in menu.actions():
        if action.isSeparator():
            continue
        label = prefix + _label_text(action)
        submenu = action.menu()
        if submenu is not None:
            keys = _key_text(action)
            if keys:
                entries.append((label, keys))
            entries.extend(_menu_entries(submenu, f"{label} - "))
            continue
        keys = _key_text(action)
        if keys:
            entries.append((label, keys))
    return entries


def shortcut_sections(window) -> list[tuple[str, list[tuple[str, str]]]]:  # noqa: ANN001 - QMainWindow
    """The guide's contents: one section per menu, then the canvases and panels.

    Separated from the dialog so the mapping can be tested without opening a
    modal, which the offscreen platform can never answer.
    """
    sections: list[tuple[str, list[tuple[str, str]]]] = []
    for action in window.menuBar().actions():
        menu = action.menu()
        if menu is None:
            continue
        entries = _menu_entries(menu)
        if entries:
            sections.append((_label_text(action), entries))
    sections.append(("Level Canvas", list(LEVEL_CANVAS)))
    sections.append(("World Map Canvas", list(WORLD_CANVAS)))
    sections.append(("Tilemap Canvas", list(MAP16_CANVAS)))
    sections.append(("Panels (while focused)", list(PANEL_KEYS)))
    sections.append(("Mushroom Paint", list(PIXEL_EDITOR)))
    sections.append(("Test Window", [*TEST_WINDOW, *_pad_keys()]))
    return sections


def _section_widget(title: str, entries: list[tuple[str, str]]) -> QWidget:
    """One titled two-column section: names on the left, keys on the right."""
    box = QWidget()
    layout = QVBoxLayout(box)
    layout.setContentsMargins(0, 0, 0, 0)
    layout.setSpacing(2)
    heading = QLabel(title)
    font = heading.font()
    font.setBold(True)
    heading.setFont(font)
    layout.addWidget(heading)
    rule = QFrame()
    rule.setFrameShape(QFrame.Shape.HLine)
    rule.setFrameShadow(QFrame.Shadow.Sunken)
    layout.addWidget(rule)
    grid = QGridLayout()
    grid.setContentsMargins(0, 0, 0, 0)
    grid.setHorizontalSpacing(18)
    grid.setVerticalSpacing(1)
    grid.setColumnStretch(0, 1)
    for row, (name, keys) in enumerate(entries):
        grid.addWidget(QLabel(name), row, 0)
        key_label = QLabel(keys)
        key_label.setAlignment(
            Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter
        )
        key_label.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
        grid.addWidget(key_label, row, 1)
    layout.addLayout(grid)
    return box


def _balanced_columns(
    sections: list[tuple[str, list[tuple[str, str]]]], count: int = 2
) -> list[list[tuple[str, list[tuple[str, str]]]]]:
    """Split sections across ``count`` columns, keeping each column's height even.

    Sections stay whole and in order; each goes to whichever column is shortest
    so far. View alone is longer than most of the others together, so a naive
    halfway split would leave one column nearly empty.
    """
    columns: list[list[tuple[str, list[tuple[str, str]]]]] = [[] for _ in range(count)]
    heights = [0] * count
    for section in sections:
        target = heights.index(min(heights))
        columns[target].append(section)
        heights[target] += len(section[1]) + 2  # rows plus the heading and rule
    return columns


class ShortcutGuide(QDialog):
    """Help > Shortcuts: every key the app answers to, in one modal page."""

    def __init__(
        self,
        sections: list[tuple[str, list[tuple[str, str]]]],
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        self.setWindowTitle(f"{APP_NAME} - Shortcuts")
        self.setAttribute(Qt.WidgetAttribute.WA_DeleteOnClose)

        body = QWidget()
        columns = QHBoxLayout(body)
        columns.setContentsMargins(12, 12, 12, 12)
        columns.setSpacing(28)
        for column in _balanced_columns(sections):
            lane = QVBoxLayout()
            lane.setSpacing(14)
            for title, entries in column:
                lane.addWidget(_section_widget(title, entries))
            lane.addStretch(1)
            columns.addLayout(lane)

        # Scrolled rather than sized to fit: the list grows with the app, and a
        # short screen must still be able to reach the buttons.
        scroll = QScrollArea()
        scroll.setWidget(body)
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.Shape.NoFrame)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        buttons.accepted.connect(self.accept)

        layout = QVBoxLayout(self)
        layout.addWidget(scroll)
        layout.addWidget(buttons)
        # **Sized from what it holds**, rather than to a number that was wide
        # enough on the day it was written: the columns are as wide as the
        # longest label and key in them, and a page that needs a horizontal
        # scrollbar to read a key is not a reference. Capped at the screen it
        # opens on, which is the only thing that can make it too wide; the
        # height is a starting size, and the scroll area is what makes it one.
        room = self.screen().availableSize()
        wanted = (
            body.sizeHint().width()
            + scroll.verticalScrollBar().sizeHint().width()
            + 2 * layout.contentsMargins().left()
        )
        self.resize(min(wanted, room.width() - 80), min(700, room.height() - 80))


class AboutDialog(QDialog):
    """Help > About: what this is, which version, who wrote it, what it is
    built on, and the license."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle(f"About {APP_NAME}")
        self.setAttribute(Qt.WidgetAttribute.WA_DeleteOnClose)

        icon = QLabel()
        pixmap = QPixmap()
        pixmap.loadFromData(resources.read_bytes("icons", "app.png"))
        icon.setPixmap(
            pixmap.scaled(
                64,
                64,
                Qt.AspectRatioMode.KeepAspectRatio,
                Qt.TransformationMode.SmoothTransformation,
            )
        )
        icon.setAlignment(Qt.AlignmentFlag.AlignTop)

        # One rich-text label rather than a stack of them: it keeps the links
        # clickable and the whole thing selectable for a bug report.
        text = QLabel(
            f"<h2 style='margin-bottom:2px'>{APP_NAME} {__version__}</h2>"
            "<p style='margin-top:0'>A Super Mario World romhack editor.</p>"
            f"<p>By <b>{AUTHOR}</b><br>"
            f"<a href='{HOMEPAGE}'>{HOMEPAGE}</a></p>"
            "<p>An SA-1 project is built with <b>SA-1 Pack</b> by Vitor Vilela"
            " and contributors, used here with the author's permission.<br>"
            f"<a href='{SA1_PACK}'>{SA1_PACK}</a></p>"
            "<p>The interface icons are <b>Material Symbols</b> by Google,"
            " under the Apache License 2.0, and the controller marks are"
            " <b>PromptFont</b> by Yukari Hafner, under the SIL Open Font"
            " License.</p>"
            "<p>Released under the GPLv3. Built on Python and Qt via PySide6,"
            " which is licensed under the LGPLv3; levels are loaded and tested"
            " on the Mesen SNES core, which is GPLv3. Super Mario World is"
            " Nintendo's, and no game data is distributed with this editor.</p>"
        )
        text.setWordWrap(True)
        text.setOpenExternalLinks(True)
        text.setTextInteractionFlags(
            Qt.TextInteractionFlag.TextBrowserInteraction
            | Qt.TextInteractionFlag.TextSelectableByMouse
        )

        top = QHBoxLayout()
        top.setSpacing(14)
        top.addWidget(icon)
        top.addWidget(text, 1)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        buttons.accepted.connect(self.accept)

        layout = QVBoxLayout(self)
        layout.addLayout(top)
        layout.addWidget(buttons)
        self.setMinimumWidth(440)
