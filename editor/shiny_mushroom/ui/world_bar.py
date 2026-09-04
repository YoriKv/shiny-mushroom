"""The world map's toolbar: which map is shown, under which palette.

The level bar's sibling for the other mode, and under the same contract: it
emits what was picked and that is all. It holds no snapshot and no mode --
the window routes a pick to the world map mode, which owns what showing a
map or switching a palette costs.

The two boxes are deliberately separate. The map picker chooses which map
the canvas draws -- the main map, or one submap, and nothing else -- and
brings that map's palette with it, because that is what the map looks like
in the game. The palette picker then moves on its own, so any map can be
previewed under any submap's colours; the next map pick puts the pair back
in step. The auto-select check beside the picker offers to make gestures
frame for themselves -- a click on another map's ground switching to that
map -- with the mode owning what following a gesture costs.

The editing box is a mirror, not an owner: the tile palette's tab is the
one truth about which layer gestures edit, and this box restates it where
the map and palette pickers already live. A pick here is routed to the
palette's tab; a tab switch there is shown back here.
"""

from __future__ import annotations

from collections.abc import Sequence

from PySide6.QtCore import Signal
from PySide6.QtWidgets import QCheckBox, QComboBox, QLabel, QToolBar, QWidget

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.overworld import REPLAYED_EVENTS, SUBMAP_NAMES
from shiny_mushroom.ui.tile_palette import STAMP_TABS, PaletteTab

#: What the event box's fixed rows mean on the :attr:`WorldBar.event_picked`
#: wire and in :meth:`WorldBar.set_event`: every event replayed, or none of
#: them -- the base map, the events view down.
EVERY_EVENT = -1
NO_EVENTS = -2

#: The Editing box's rows: each names the palette tabs it stands for. The
#: two stamp tabs share one "Events" row -- they are one mode over two
#: sheets, and the box mirrors modes, not sheets; "Events" because placing
#: an event's blocks is what the mode is for, the stamps only its material.
#: "Warps/Exits" is the one row that places nothing from a palette -- there is
#: no arming a transfer, only picking one -- and is a mode all the same: the
#: entries are dragged, retargeted, cut and pasted, which is editing.
EDIT_ROWS: tuple[tuple[str, tuple[PaletteTab, ...]], ...] = (
    ("Layer 1", (PaletteTab.LAYER1,)),
    ("Layer 2", (PaletteTab.LAYER2,)),
    ("Sprites", (PaletteTab.SPRITES,)),
    ("Events", STAMP_TABS),
    ("Warps/Exits", (PaletteTab.TRANSFERS,)),
)


def edit_row_of(tab: PaletteTab) -> int:
    """The Editing box row that stands for ``tab``."""
    for index, (_name, tabs) in enumerate(EDIT_ROWS):
        if tab in tabs:
            return index
    raise ValueError(f"no Editing row shows {tab}")


class WorldBar(QToolBar):
    """Picks a map to show and a palette to draw under. Owns no map."""

    #: The user asked to show this map (an index into SUBMAP_NAMES).
    submap_picked = Signal(int)

    #: The user toggled whether gestures frame the map they land on.
    auto_select_picked = Signal(bool)

    #: The user asked for this submap's palette, on its own.
    palette_picked = Signal(int)

    #: The user asked to edit this layer (an index into :data:`EDIT_ROWS`).
    layer_picked = Signal(int)

    #: The user asked the events view to show this event alone, or
    #: EVERY_EVENT or NO_EVENTS.
    event_picked = Signal(int)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__("World Map", parent)
        self.setObjectName("world-bar")
        self.setMovable(False)

        self._submaps = QComboBox()
        for name in SUBMAP_NAMES:
            self._submaps.addItem(name)
        # `activated`, not `currentIndexChanged`: the latter also fires when
        # the index is moved from code, and the window moves it to follow the
        # mode.
        self._submaps.activated.connect(self.submap_picked.emit)

        # `clicked`, not `toggled`, for the combos' reason: `set_auto_select`
        # must show the mode's stance without asking for it back. Through a
        # lambda reading the box, not `auto_select_picked.emit` itself:
        # `clicked`'s bool is a C++ default argument, so a direct connection
        # binds the zero-argument overload and every real click raises
        # instead of delivering.
        self._auto = QCheckBox("Auto-select map")
        self._auto.setToolTip(
            "Clicking a tile, sprite or stamp switches to the map it is on."
        )
        self._auto.setChecked(True)
        self._auto.clicked.connect(
            lambda: self.auto_select_picked.emit(self._auto.isChecked())
        )

        self._palettes = QComboBox()
        self._palettes.activated.connect(self.palette_picked.emit)

        self._layers = QComboBox()
        self._layers.setToolTip("Which part of the map a gesture edits (keys 1-5)")
        for name, _tabs in EDIT_ROWS:
            self._layers.addItem(name)
        self._layers.activated.connect(self.layer_picked.emit)

        # The events-view stance: "None" for the base map, "All" for every
        # event, then one row per replayed event -- that event alone. The box
        # is the *ask* -- picking a row also asks for the events view up or
        # down, which the window routes to the mode.
        self._events = QComboBox()
        self._events.addItem("None")
        self._events.addItem("All")
        for number in range(REPLAYED_EVENTS):
            self._events.addItem(hexnum(number))
        self._events.activated.connect(lambda index: self.event_picked.emit(index - 2))

        # Every box sizes to its longest row: the names are the interface,
        # and a box that shows "Ma..." says nothing.
        for box in (self._submaps, self._palettes, self._layers, self._events):
            box.setSizeAdjustPolicy(QComboBox.SizeAdjustPolicy.AdjustToContents)

        self.addWidget(QLabel("Map "))
        self.addWidget(self._submaps)
        self.addWidget(QLabel(" "))
        self.addWidget(self._auto)
        self.addWidget(QLabel(" Palette "))
        self.addWidget(self._palettes)
        self.addWidget(QLabel(" Editing "))
        self.addWidget(self._layers)
        self.addWidget(QLabel(" Event "))
        self.addWidget(self._events)
        # Nothing to show until the world map mode is up with a capture.
        self.setEnabled(False)

    # -- what is on offer ----------------------------------------------------

    def set_palettes(self, cgrams: Sequence[bytes]) -> None:
        """Offer one row per palette, numbered and named for its submap;
        empty is "no capture". A capture without the per-submap loads offers
        its single palette, greyed: there is nothing to switch.

        The number leads because it is what a palette *is* to the game -- the
        row a submap's load is written to -- while the name only says which
        map wears it; a capture with more palettes than named maps still has
        a number for every row.
        """
        self._palettes.clear()
        for index in range(len(cgrams)):
            name = SUBMAP_NAMES[index] if index < len(SUBMAP_NAMES) else ""
            self._palettes.addItem(f"{index} - {name}" if name else f"{index}")
        self._palettes.setEnabled(self._palettes.count() > 1)

    # -- what is picked ------------------------------------------------------

    @property
    def submap(self) -> int:
        return self._submaps.currentIndex()

    @property
    def auto_select(self) -> bool:
        """Whether gestures should frame the map they land on."""
        return self._auto.isChecked()

    def set_auto_select(self, on: bool) -> None:
        """Show the auto-select stance in effect, without asking for it."""
        self._auto.setChecked(on)

    @property
    def palette_index(self) -> int:
        return self._palettes.currentIndex()

    @property
    def layer(self) -> int:
        """The shown Editing row, an index into :data:`EDIT_ROWS`."""
        return self._layers.currentIndex()

    def set_submap(self, index: int) -> None:
        """Show ``index`` as the map on the canvas, without asking for it."""
        self._submaps.setCurrentIndex(index)

    def set_palette(self, index: int) -> None:
        """Show ``index`` as the palette in effect, without asking for it."""
        if 0 <= index < self._palettes.count():
            self._palettes.setCurrentIndex(index)

    def set_layer(self, tab: PaletteTab) -> None:
        """Show ``tab``'s row as the layer being edited, without asking
        for it."""
        self._layers.setCurrentIndex(edit_row_of(tab))

    @property
    def event(self) -> int:
        """The shown row: an event number, EVERY_EVENT or NO_EVENTS."""
        return self._events.currentIndex() - 2

    def set_event(self, pick: int) -> None:
        """Show ``pick`` -- the :attr:`event` encoding -- as the stance in
        effect, without asking for it."""
        index = pick + 2
        if 0 <= index < self._events.count():
            self._events.setCurrentIndex(index)
