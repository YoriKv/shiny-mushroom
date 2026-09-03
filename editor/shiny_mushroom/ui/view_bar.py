"""The view bars: the View toggles as rows of square icon buttons.

The same :class:`~PySide6.QtGui.QAction` objects the menu shows, added to a
toolbar -- which is the whole design. A button and its menu row check, uncheck,
enable and disable together because they *are* one action, so there is no state
here to keep in step and nothing for the window to sync.

**Each editing environment gets a bar of its own.** The level's toggles mean
nothing over the world map -- they are preferences about a picture that is not
on the canvas -- so the window builds one bar per environment from the rows
declared here (:data:`LEVEL_BUTTONS`, :data:`WORLD_BUTTONS`) and its toolbar
registry swaps them with the rest of the mode's chrome -- see
:mod:`shiny_mushroom.ui.toolbars`. The screens toggle appears in both rows,
because the page grid is the world map's screens.

The marks come from the bundled icon font
(:mod:`shiny_mushroom.ui.icon_font`), so a toggle's face is a codepoint in
:data:`ICONS` rather than a routine that draws it. The menu rows stay text-only
(``setIconVisibleInMenu(False)``) -- no other row there has an icon.
"""

from __future__ import annotations

from collections.abc import Sequence

from PySide6.QtWidgets import QWidget

from shiny_mushroom.ui.icons import Icon
from shiny_mushroom.ui.menus import Actions
from shiny_mushroom.ui.toolbars import IconBar

#: Each toggle's mark, by its :class:`Actions` field name. The level's layers
#: and the world map's wear the same numerals: they are the same statement
#: about two pictures, and a toggle that meant something else in the other
#: environment would be the surprise.
ICONS: dict[str, Icon] = {
    "layer1": Icon.LAYER_1,
    "layer2": Icon.LAYER_2,
    "layer3": Icon.LAYER_3,
    "sprites": Icon.SPRITE,
    "sprite_outlines": Icon.SPRITE_OUTLINE,
    "objects": Icon.OBJECT_OUTLINE,
    "screens": Icon.SCREENS,
    "world_layer1": Icon.LAYER_1,
    "world_layer2": Icon.LAYER_2,
    "world_sprites": Icon.SPRITE,
    "world_tile_marks": Icon.TILE_MARKS,
    "world_frame": Icon.FRAME,
}

#: The rows the window builds its bars from: one per editing environment,
#: each entry an :class:`Actions` field name with a mark in :data:`ICONS`.
#: In the order their Shift+digits count -- see :func:`menus.build` -- so a
#: button's place in the row is the number that reaches it, with no gaps in
#: either row. The events view is in neither: it has a handle in the world
#: bar's Event box already, and carries no key.
LEVEL_BUTTONS = (
    "layer1",
    "layer2",
    "layer3",
    "sprites",
    "objects",
    "sprite_outlines",
    "screens",
)
WORLD_BUTTONS = (
    "world_layer1",
    "world_layer2",
    "world_sprites",
    "world_tile_marks",
    "world_frame",
    "screens",
)


class ViewBar(IconBar):
    """One environment's view options, as square buttons. Owns no state of its
    own: every button is one of the window's menu actions."""

    def __init__(
        self,
        actions: Actions,
        buttons: Sequence[str],
        title: str,
        name: str,
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(title, parent)
        # Named so Qt can save and restore it with the window state, like the
        # other bars.
        self.setObjectName(name)
        self.setMovable(False)

        for field in buttons:
            self.wear(getattr(actions, field), ICONS[field])
