"""The level picker: which level the canvas is showing.

A toolbar rather than a dock or a dialog because picking a level is the one
thing you do constantly while looking at one, and because it is the *only*
control the emulated loader needs -- everything else about a level comes from
the cart.

A row is a level and says its number, which is what everything else in the
editor calls a level. Beside it in the popup is the container it comes out of,
which the search looks through as well: the tree names its files for the place
they are, so typing "donut" finds ``$009`` through
``Level009_DonutPlains2_Main``. The closed box shows the number alone and stays
the width of one.

**The list is in two sections**, :data:`ORDINARY_LEVELS` and
:data:`PATCHED_LEVELS`. The 74 levels in the second are as real and as loadable
as the rest, but the game's own level request cannot name them -- a ``$00`` in
``$7E0109`` means "no override" and a low byte above ``$DB`` overflows the
loader's adjustment -- so the editor reaches them by patching a branch for the
length of the load. Filed apart because that is a real difference between them
and their neighbours: a hack that tests its levels in the game cannot send the
player to one from the overworld.
"""

from __future__ import annotations

from collections.abc import Mapping

from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import QComboBox, QLabel, QWidget

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level_files import ContainerNames
from shiny_mushroom.rom_patches import REQUESTABLE_LEVELS, needs_direct_request
from shiny_mushroom.ui.icons import Icon
from shiny_mushroom.ui.searchable_combo import SearchableComboBox, fill_sections
from shiny_mushroom.ui.toolbars import IconBar

#: Where the picker starts, and therefore the level a freshly opened cart is
#: shown as: opening a ROM loads this one without being asked, so it is the
#: first thing anybody sees of a cartridge.
DEFAULT_LEVEL = 0x001

#: The two sections the level list is in -- see the module docstring.
ORDINARY_LEVELS = "Levels"
PATCHED_LEVELS = "Levels the game's request cannot name"

#: What the second section means, on the heading itself: the difference is real
#: and is not about the data, so it is worth a sentence where it is read.
PATCHED_NOTE = (
    "The data is ordinary; the editor reaches it by patching the loader's "
    "branch for the load."
)

#: How many characters wide the picker's button is. A level number and no more:
#: the longest *item* in the list is a section heading, and a box sized to that
#: would be a hand's width of empty space around "$105".
PICKER_CHARACTERS = 6

#: The Editing box's rows: what a gesture on the level edits. Layer 1 and the
#: sprites are one mode -- they are what a level *is*, records placed and
#: selected together -- and Layer 2 is the other. What the second row *does*
#: depends on the level: a background is a tilemap painted through the level
#: palette, and a Layer 2 level is a second record stream worked exactly as
#: Layer 1 is. One row either way, because the question the user is asking is
#: "let me edit Layer 2". The world bar's Editing box is this box's sibling for
#: the other document.
EDITING_ROWS = ("Layer 1 & Sprites", "Layer 2")


class LevelBar(IconBar):
    """Picks a level and asks for it. Owns no snapshot and no emulator."""

    #: The user asked for this level. Whoever is listening decides what that
    #: costs and whether it can be served at all.
    level_requested = Signal(int)

    #: The user asked to edit this part of the level (an index into
    #: :data:`EDITING_ROWS`).
    editing_picked = Signal(int)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__("Level", parent)
        # Named so Qt can save and restore it with the window state later, and
        # fixed in place: with one toolbar there is nothing to rearrange.
        self.setObjectName("level-bar")
        self.setMovable(False)

        #: Which containers each level reads, empty until a cart says -- what
        #: the rows are described and searched by, never what they are called.
        self._files: dict[int, ContainerNames] = {}

        self._levels = SearchableComboBox()
        self._levels.setSizeAdjustPolicy(
            QComboBox.SizeAdjustPolicy.AdjustToMinimumContentsLengthWithIcon
        )
        self._levels.setMinimumContentsLength(PICKER_CHARACTERS)
        self._fill_levels()
        # `activated`, not `currentIndexChanged`: the latter also fires when the
        # index is moved from code, so stepping with the buttons below would
        # request the level twice.
        self._levels.activated.connect(lambda _index: self.request())
        self._levels.currentIndexChanged.connect(lambda _index: self._show_level())

        # `activated` for the combos' shared reason: `set_editing` must show
        # the mode in effect without asking for it back.
        self._editing = QComboBox()
        self._editing.setToolTip("Which part of the level a gesture edits")
        for name in EDITING_ROWS:
            self._editing.addItem(name)
        self._editing.activated.connect(self.editing_picked.emit)

        self.addWidget(QLabel("Level "))
        self.addWidget(self._levels)
        self._previous = self.add_icon_action(
            Icon.PREVIOUS, "&Previous", lambda: self._step(-1)
        )
        self._next = self.add_icon_action(Icon.NEXT, "&Next", lambda: self._step(+1))
        self._reload = self.add_icon_action(Icon.RELOAD, "&Load", self.request)
        self.addWidget(QLabel(" Editing "))
        self.addWidget(self._editing)
        self._update_steps()
        self._show_level()

    # -- what is selected ---------------------------------------------------

    @property
    def level(self) -> int:
        """The level currently picked, whether or not it has been loaded."""
        return self._levels.currentData()

    def set_level(self, level: int) -> None:
        """Select ``level`` without asking for it."""
        index = self._levels.findData(level)
        if index >= 0:
            self._levels.setCurrentIndex(index)
            self._update_steps()

    def request(self) -> None:
        """Ask for the selected level."""
        self.level_requested.emit(self.level)

    # -- the rows ------------------------------------------------------------

    def show_files(self, files: Mapping[int, ContainerNames]) -> None:
        """Say which container each level reads, in its tooltip and its search.

        Taken rather than looked up: which container a level resolves to is a
        question about a source tree and a release, and the bar has neither.
        """
        self._files = dict(files)
        self._fill_levels()
        self._update_steps()
        self._show_level()

    def _fill_levels(self) -> None:
        """Rebuild the list, keeping whatever level was picked.

        The steps are the caller's to update: this runs during construction,
        before there are any buttons to enable.
        """
        selected = self.level if self._levels.count() else DEFAULT_LEVEL
        # Silenced while it is half-built: a refill passes through an empty box
        # and through every heading, and neither is a level anyone picked.
        self._levels.blockSignals(True)
        try:
            fill_sections(
                self._levels,
                [
                    (
                        PATCHED_LEVELS
                        if needs_direct_request(level)
                        else ORDINARY_LEVELS,
                        hexnum(level, 3),
                        level,
                        self._detail(level),
                    )
                    for level in sorted(REQUESTABLE_LEVELS, key=needs_direct_request)
                ],
                selected,
            )
            for row in range(self._levels.count()):
                if self._levels.is_heading(row):
                    if self._levels.itemText(row) == PATCHED_LEVELS:
                        self._levels.setItemData(
                            row, PATCHED_NOTE, Qt.ItemDataRole.ToolTipRole
                        )
                    continue
                self._levels.setItemData(
                    row,
                    self._about(self._levels.itemData(row)),
                    Qt.ItemDataRole.ToolTipRole,
                )
        finally:
            self._levels.blockSignals(False)

    def _detail(self, level: int) -> str:
        """What the popup writes beside the row: the container the level comes
        out of, where that says more than the number already has.

        The tree names most of its files for the place they are, and the ones
        still named by number would put ``$001   001`` in the list -- a column
        of the row repeating itself.
        """
        files = self._files.get(level)
        if files is None or files.layer1 == f"{level:03X}":
            return ""
        return files.layer1

    def _about(self, level: int) -> str:
        """What a row says beyond its number: the container it comes out of,
        and the second one where a level's two streams are in two files."""
        files = self._files.get(level)
        if files is None:
            return f"Level {hexnum(level, 3)}"
        if files.split:
            return f"{files.layer1}, sprites from {files.sprites}"
        return files.layer1

    def _show_level(self) -> None:
        """Say on the closed box what the popup says on the row."""
        self._levels.setToolTip(self._about(self.level))

    # -- what is being edited ------------------------------------------------

    @property
    def editing(self) -> int:
        """The shown Editing row, an index into :data:`EDITING_ROWS`."""
        return self._editing.currentIndex()

    def set_editing(self, index: int) -> None:
        """Show ``index`` as the mode in effect, without asking for it."""
        self._editing.setCurrentIndex(index)

    def offer_layer2(self, on: bool) -> None:
        """Whether the Layer 2 row can be picked at all -- off only for a level
        with no Layer 2 the editor can edit, neither pattern nor records."""
        # The combo's default model is a QStandardItemModel, so the row can
        # be greyed without swapping the model out.
        item = self._editing.model().item(1)
        if item is not None:
            item.setEnabled(on)

    def _step(self, direction: int) -> None:
        """Move one level along, over the heading between the two sections."""
        index = self._levels.step_from(self._levels.currentIndex(), direction)
        if index >= 0:
            self._levels.setCurrentIndex(index)
            self._update_steps()
            self.request()

    def _update_steps(self) -> None:
        index = self._levels.currentIndex()
        self._previous.setEnabled(self._levels.step_from(index, -1) >= 0)
        self._next.setEnabled(self._levels.step_from(index, +1) >= 0)
