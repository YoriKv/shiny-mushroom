"""What the editor is editing: the two mode enums the whole window routes by.

Here rather than in :mod:`shiny_mushroom.ui.main_window` so the window's
sections (:mod:`shiny_mushroom.ui.window`) can ask the mode question without
importing the window they are mixed into.
"""

from __future__ import annotations

from enum import Enum, auto

__all__ = ["EditorMode", "LevelEditing"]


class EditorMode(Enum):
    """What the central view is editing: a level, the world map, or the
    Map16 tables.

    Members of the window's own state rather than a registry of views: the
    canvas and the properties dock are shared, and this is the
    discriminator the gesture dispatchers route by -- and the key each
    toolbar is registered under in :attr:`MainWindow.toolbars`. Every
    transition between the two non-level modes routes through LEVEL, so no
    pair of them ever has to know how to unwind the other's chrome.
    """

    LEVEL = auto()
    WORLD = auto()
    MAP16 = auto()


class LevelEditing(Enum):
    """What a gesture on the level edits, within :attr:`EditorMode.LEVEL`.

    Two members because a level has two kinds of editable data. The records
    -- Layer 1's objects and the sprites, placed and selected together,
    because together they are what a level *is* -- and the Layer 2
    background, a shared tilemap painted through the level palette. The
    level bar's Editing box and Edit > Level Editing are the two handles on
    this, exactly as the world bar's box mirrors the tile palette's tab.
    """

    RECORDS = auto()
    LAYER2 = auto()
