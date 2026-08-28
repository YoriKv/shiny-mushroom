"""The palette panel: the colours on screen, and the colours in the file.

Two tabs, because a palette is two questions and only one of them is about
what is being looked at.

**Level**, or **Map** over a world map, is CGRAM as the console holds it for
whatever is on the canvas -- sixteen rows of sixteen, backgrounds above sprites
-- with the backdrop beside it, since the colour behind everything is the PPU's
fixed colour and not a CGRAM entry at all. It is where a colour is found by
pointing at the thing that is wearing it. The tab is named for what it is
showing, which the window says: see :meth:`PaletteDock.set_scene_title`.

**Sets** is the palette file as the disassembly names it: every run of colours
in ``palettes/smw.pal``, editable whether or not anything on screen is using
it. It is the only way to reach Bowser's eight fade steps, the ending palettes
or the unused blue gradient -- and the only way to edit at all when the canvas
is showing a screen whose palette load this editor does not model.

**The panel owns no document.** It is handed swatches and hands back "this
colour became that" -- what a colour change *means*, and the fact that it means
it for every level sharing the run, belongs to the window. Which is what lets
it be tested by handing it colours and reading signals back.
"""

from __future__ import annotations

from collections.abc import Callable, Sequence
from enum import Enum

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QColor, QPalette
from PySide6.QtWidgets import (
    QCheckBox,
    QColorDialog,
    QDockWidget,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QScrollArea,
    QTabWidget,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.level import snes_color
from shiny_mushroom.ui.palette_grid import Swatch, SwatchGrid
from shiny_mushroom.ui.tips import wrap_tip

#: Found by name in tests and by the View menu's dock list.
OBJECT_NAME = "palette-dock"

#: CGRAM's shape: sixteen rows of sixteen, backgrounds then sprites.
CGRAM_COLUMNS = 16

#: How wide a run of the file is drawn before it wraps. Sixteen matches the
#: scene grid, so a set of twelve reads as most of a palette row -- which is
#: what it is.
SET_COLUMNS = 16

#: Said wherever a colour is edited, because it is the one thing about editing
#: palettes in this game that is not obvious and cannot be undone by being
#: careful: the stock game has no per-level palette.
GLOBAL_WARNING = "Colours are shared: every level using this palette changes with it."

#: And its opposite, over a level that wears a palette of its own: the Level
#: tab is then that level's blob, and an edit there touches nothing else.
CUSTOM_NOTE = "This level wears its own palette: these colours are its alone."

#: What the tick means, said where it is ticked.
CUSTOM_TIP = (
    "Give this level its own palette, from the colours on screen. Untick to "
    "go back to the shared ones."
)

NOTHING_SELECTED = "Pick a colour. Double-click or press Return to change it."

#: What the first tab is called. Which of the two it wears is the window's to
#: say -- the panel owns no document and cannot know whether the canvas is a
#: level or a world map.
LEVEL_TITLE = "Level"
MAP_TITLE = "Map"

#: On the Save button, which lights while there is something for it to do.
SAVE_TIP = "Write the colours into the project. Lit while something here is unsaved."


class PaletteTab(Enum):
    """Which question the panel is being asked."""

    SCENE = "scene"
    SETS = "sets"


class PaletteDock(QDockWidget):
    """Offers the game's colours for editing. Owns no palette."""

    #: A colour is being dragged towards: ``(offset, value)``. Fired as often
    #: as the picker moves, and **not** a step -- what a preview is for.
    previewed = Signal(int, int)

    #: A colour change is finished: ``(offset, value)``. One undo step.
    committed = Signal(int, int)

    #: The picker was cancelled after previewing ``offset``: put it back to
    #: what it was, without recording anything.
    cancelled = Signal(int)

    #: Put one colour back to the game's own.
    reset_asked = Signal(int)

    #: Put every colour back.
    reset_all_asked = Signal()

    #: The user moved between the two tabs: a :class:`PaletteTab`.
    tab_changed = Signal(object)

    #: A colour was selected anywhere in the panel -- its byte offset in the
    #: palette file, or ``None`` when the selection was cleared. What tells the
    #: window that the colours are the document being worked in.
    picked = Signal(object)

    #: The "custom palette for this level" tick was thrown -- by hand, so a
    #: redraw pushing state through :meth:`set_custom` never fires it. What it
    #: means -- copying the scene in, or putting the level back on the shared
    #: colours -- belongs to the window, like every other edit here.
    custom_toggled = Signal(bool)

    #: The Save button was pressed. The save itself belongs to the window,
    #: like the palette it writes.
    save_asked = Signal()

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__("Palettes", parent)
        self.setObjectName(OBJECT_NAME)

        self._scene = SwatchGrid(CGRAM_COLUMNS, numbered=True)
        self._scene.picked.connect(self._scene_picked)
        self._scene.activated.connect(lambda _: self._ask(self._scene))

        self._backdrop = SwatchGrid(1)
        self._backdrop.picked.connect(self._backdrop_picked)
        self._backdrop.activated.connect(lambda _: self._ask(self._backdrop))

        self._custom = QCheckBox("Custom palette for this level")
        self._custom.setToolTip(wrap_tip(CUSTOM_TIP))
        # `clicked` rather than `toggled`: only a hand on the box means
        # anything, and `set_custom` pushes state through it on every redraw.
        # Through a lambda reading the box, not `custom_toggled.emit` itself:
        # `clicked`'s bool is a C++ default argument, so a direct connection
        # binds the zero-argument overload and every real click raises
        # instead of delivering.
        self._custom.clicked.connect(
            lambda: self.custom_toggled.emit(self._custom.isChecked())
        )
        self._custom.setVisible(False)

        self._sets: list[SwatchGrid] = []
        self._set_shape: tuple[tuple[str, int], ...] = ()
        self._titles: tuple[str, ...] = ()
        # A grid rather than a column: the name beside its colours rather than
        # above them fits fifty runs in half the scrolling, and the strips line
        # up so two sets can be compared down the page.
        self._sets_layout = QGridLayout()
        self._sets_layout.setContentsMargins(0, 0, 0, 0)
        self._sets_layout.setHorizontalSpacing(8)
        self._sets_layout.setVerticalSpacing(3)
        self._sets_layout.setColumnStretch(2, 1)

        self._hint = QLabel(NOTHING_SELECTED)
        self._hint.setWordWrap(True)
        self._warning = QLabel(GLOBAL_WARNING)
        self._warning.setWordWrap(True)
        self._change = QPushButton("Change...")
        self._change.clicked.connect(lambda: self._ask(self._active))
        self._reset = QPushButton("Revert")
        self._reset.clicked.connect(self._reset_selected)
        self._reset_all = QPushButton("Revert All")
        self._reset_all.clicked.connect(self.reset_all_asked.emit)
        self._save = QPushButton("Save")
        self._save.setToolTip(wrap_tip(SAVE_TIP))
        self._save.setEnabled(False)
        self._save.clicked.connect(self.save_asked.emit)

        self._tabs = QTabWidget()
        self._tabs.addTab(self._scene_page(), LEVEL_TITLE)
        self._tabs.addTab(self._sets_page(), "Sets")
        self._tabs.currentChanged.connect(self._tab_changed)

        buttons = QHBoxLayout()
        buttons.addWidget(self._change)
        buttons.addWidget(self._reset)
        buttons.addWidget(self._reset_all)
        buttons.addStretch(1)
        buttons.addWidget(self._save)

        body = QVBoxLayout()
        body.setContentsMargins(6, 6, 6, 6)
        body.addWidget(self._tabs, 1)
        body.addWidget(self._hint)
        body.addWidget(self._warning)
        body.addLayout(buttons)
        holder = QWidget()
        holder.setLayout(body)
        self.setWidget(holder)

        #: What `set_custom` last pushed -- see :attr:`custom`.
        self._custom_state: bool | None = None
        #: What `set_unsaved` last pushed -- see :attr:`unsaved`.
        self._unsaved = False
        #: Asked before the panel closes -- see :meth:`set_close_guard`.
        self._close_guard: Callable[[], bool] | None = None
        #: Which grid the buttons act on -- whichever was last picked in.
        self._active: SwatchGrid = self._scene
        #: The offset `picked` last announced, so a redraw that changes nothing
        #: says nothing -- see :meth:`_show_state`.
        self._announced: int | None = None
        #: Whether a pick is being routed to one grid -- see :meth:`_picked_in`.
        self._routing = False
        self._show_state()

    # -- the two pages -------------------------------------------------------

    def _scene_page(self) -> QWidget:
        """CGRAM, with the backdrop beside it under its own caption -- the
        colour behind everything is not one of the 256 and must not look as
        though it were."""
        beside = QVBoxLayout()
        beside.setContentsMargins(0, 0, 0, 0)
        caption = QLabel("Back\narea")
        caption.setAlignment(Qt.AlignmentFlag.AlignHCenter)
        caption.setToolTip(
            wrap_tip(
                "The colour shown wherever a tile is transparent. Not one of the 256."
            )
        )
        beside.addWidget(caption)
        beside.addWidget(self._backdrop, 0, Qt.AlignmentFlag.AlignHCenter)
        beside.addStretch(1)

        row = QHBoxLayout()
        row.setContentsMargins(0, 0, 0, 0)
        row.addWidget(self._scene, 0, Qt.AlignmentFlag.AlignTop)
        row.addSpacing(10)
        row.addLayout(beside)
        row.addStretch(1)
        body = QVBoxLayout()
        body.setContentsMargins(0, 0, 0, 0)
        body.addWidget(self._custom)
        body.addLayout(row, 1)
        page = QWidget()
        page.setLayout(body)
        return _scrolled(page)

    def _sets_page(self) -> QWidget:
        page = QWidget()
        page.setLayout(self._sets_layout)
        return _scrolled(page)

    # -- what is on offer ----------------------------------------------------

    def set_scene(self, swatches: Sequence[Swatch], backdrop: Swatch | None) -> None:
        """Offer the 256 colours on screen, and the backdrop beside them.

        ``backdrop`` is ``None`` on a screen with no back area colour to
        speak of -- the world map -- and its swatch is then empty rather than
        black, which would be a colour it is not.
        """
        self._scene.set_swatches(swatches)
        self._backdrop.set_swatches([backdrop] if backdrop is not None else [])
        self._show_state()

    def set_scene_title(self, title: str) -> None:
        """Name the first tab: :data:`LEVEL_TITLE` or :data:`MAP_TITLE`.

        The colours it shows are a level's or a world map's, and which of those
        is on the canvas is the window's to know.
        """
        self._tabs.setTabText(0, title)

    def set_custom(self, state: bool | None) -> None:
        """Show the per-level tick as ``state`` says, or hide it on ``None``.

        ``None`` is a canvas the tick has no meaning over -- the world map, no
        level, no project. Pushing state through here fires nothing: only a
        hand on the box emits :attr:`custom_toggled`.
        """
        self._custom_state = state
        self._custom.setVisible(state is not None)
        self._custom.setChecked(bool(state))
        self._update_warning()

    @property
    def custom(self) -> bool | None:
        """What the tick shows -- ``None`` while it is hidden.

        The pushed state rather than ``isVisible``, which is false for every
        widget of a window nobody has shown -- a headless test would read a
        shown tick as a hidden one.
        """
        return self._custom_state

    def _update_warning(self) -> None:
        """Which truth the footer tells: shared colours, unless the Level tab
        is showing a level that wears its own."""
        custom = self.tab is PaletteTab.SCENE and self.custom
        self._warning.setText(CUSTOM_NOTE if custom else GLOBAL_WARNING)

    def set_unsaved(self, state: bool) -> None:
        """Light the Save button, or put it out.

        Whether the colours hold changes the project has not written is the
        window's to say -- the panel owns no palette -- so the state is pushed
        here, and the button is the panel's one word about it: lit and
        pressable while there is something to save, grey once there is not.
        """
        self._unsaved = state
        self._save.setEnabled(state)
        if state:
            lit = QPalette(self._save.palette())
            lit.setColor(
                QPalette.ColorRole.Button, lit.color(QPalette.ColorRole.Highlight)
            )
            lit.setColor(
                QPalette.ColorRole.ButtonText,
                lit.color(QPalette.ColorRole.HighlightedText),
            )
            self._save.setPalette(lit)
        else:
            # A palette with nothing resolved, so the button goes back to
            # inheriting the theme's -- including the next theme's.
            self._save.setPalette(QPalette())

    @property
    def unsaved(self) -> bool:
        """What the Save button shows -- the pushed state, for headless tests,
        for the same reason :attr:`custom` is."""
        return self._unsaved

    def set_close_guard(self, guard: Callable[[], bool] | None) -> None:
        """Have ``guard`` asked before the panel closes; False keeps it open.

        Whether closing would lose anything -- and the asking about it -- is
        the window's, like everything else about the document. A guard rather
        than a signal, because the answer has to come back before the close
        can go on.
        """
        self._close_guard = guard

    def closeEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        if self._close_guard is not None and not self._close_guard():
            event.ignore()
            return
        super().closeEvent(event)

    def set_sets(self, groups: Sequence[tuple[str, Sequence[Swatch]]]) -> None:
        """Offer the file's named runs, one strip each.

        Rebuilt only when the runs themselves change. A colour edit changes
        every strip's colours and none of their shapes, and rebuilding fifty
        widgets for it would throw the selection away on every drag frame.
        """
        shape = tuple((title, len(swatches)) for title, swatches in groups)
        if shape != self._set_shape:
            self._rebuild_sets(groups)
            self._set_shape = shape
        for grid, (_, swatches) in zip(self._sets, groups, strict=True):
            grid.set_swatches(swatches)
        self._show_state()

    def _rebuild_sets(self, groups: Sequence[tuple[str, Sequence[Swatch]]]) -> None:
        while self._sets_layout.count():
            held = self._sets_layout.takeAt(0).widget()
            if held is not None:
                held.deleteLater()
        self._sets = []
        self._titles = tuple(title for title, _ in groups)
        for row, (title, swatches) in enumerate(groups):
            grid = SwatchGrid(min(SET_COLUMNS, max(1, len(swatches))))
            grid.picked.connect(lambda index, g=grid: self._set_picked(g, index))
            grid.activated.connect(lambda _, g=grid: self._ask(g))
            label = QLabel(title)
            self._sets_layout.addWidget(
                label,
                row,
                0,
                Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter,
            )
            self._sets_layout.addWidget(
                grid, row, 1, Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignVCenter
            )
            self._sets.append(grid)
        self._sets_layout.setRowStretch(len(groups), 1)

    @property
    def titles(self) -> tuple[str, ...]:
        """What the file's runs are called, in file order -- for tests, and for
        anything that wants to know what is on offer."""
        return self._titles

    # -- which tab -----------------------------------------------------------

    @property
    def tab(self) -> PaletteTab:
        return list(PaletteTab)[self._tabs.currentIndex()]

    def set_tab(self, tab: PaletteTab) -> None:
        self._tabs.setCurrentIndex(list(PaletteTab).index(tab))

    def _tab_changed(self, index: int) -> None:
        self._active = self._scene if index == 0 else self._first_set()
        self._show_state()
        self._update_warning()
        self.tab_changed.emit(list(PaletteTab)[index])

    def _first_set(self) -> SwatchGrid:
        """Whichever strip holds the selection, or the first if none does.

        Not simply the first: a colour picked in strip twenty keeps its ring
        across a trip to the Level tab and back, and handing the buttons strip
        zero would leave that ring drawn with "Change..." greyed out.
        """
        held = next((grid for grid in self._sets if grid.selected >= 0), None)
        if held is not None:
            return held
        return self._sets[0] if self._sets else self._scene

    # -- what is selected ----------------------------------------------------

    @property
    def selected_offset(self) -> int | None:
        """Where the selected colour lives in the palette file."""
        return self._active.selected_offset

    def show_offset(self, offset: int) -> bool:
        """Point the panel at one colour of the file, saying whether it found
        one -- how a swatch strip elsewhere in the window opens this on itself.

        The scene first, because a colour that is on screen is the one someone
        pointing at it means; the file's own runs otherwise.
        """
        if self._scene.select_offset(offset):
            self.set_tab(PaletteTab.SCENE)
            self._scene_picked(self._scene.selected)
            return True
        for grid in self._sets:
            if grid.select_offset(offset):
                self.set_tab(PaletteTab.SETS)
                self._set_picked(grid, grid.selected)
                return True
        return False

    def _scene_picked(self, index: int) -> None:
        self._picked_in(self._scene, index)

    def _backdrop_picked(self, index: int) -> None:
        self._picked_in(self._backdrop, index)

    def _set_picked(self, grid: SwatchGrid, index: int) -> None:
        self._picked_in(grid, index)

    def _picked_in(self, grid: SwatchGrid, index: int) -> None:
        """``grid`` gained or lost the selection: make it the one selection.

        **One pick, one announcement.** Taking the highlight out of the other
        grids is how a pick moves it, so every real pick re-enters here once
        per grid it clears -- each of those runs reporting a grid with nothing
        selected, and one of them the grid that was active a moment ago. Left
        to speak for themselves they made the panel announce a state it was
        never in: `picked(None)` in the middle of a pick, which
        `MainWindow._entered_palettes` reads as "the palettes were left".
        """
        if index < 0:
            # Either the routing below, which will say what happened when it is
            # finished, or the active grid genuinely losing its selection.
            if not self._routing and grid is self._active:
                self._show_state()
            return
        self._routing = True
        try:
            for other in (self._scene, self._backdrop, *self._sets):
                if other is not grid:
                    other.select(-1)
            self._active = grid
        finally:
            self._routing = False
        self._show_state()

    # -- changing one ---------------------------------------------------------

    def _ask(self, grid: SwatchGrid) -> None:
        """Put the colour picker up for ``grid``'s selection.

        Previews live: every move of the picker is announced, so the canvas
        shows the colour before the dialog is closed. **One undo step per
        pick**, on OK -- a drag records nothing, and Cancel puts the colour
        back without recording anything either.
        """
        offset = grid.selected_offset
        if offset is None:
            return
        was = grid.swatches[grid.selected].color
        red, green, blue = snes_color(was)
        dialog = QColorDialog(QColor(red, green, blue), self)
        dialog.setOption(QColorDialog.ColorDialogOption.ShowAlphaChannel, False)
        dialog.currentColorChanged.connect(
            lambda color: self.previewed.emit(offset, _to_snes(color))
        )
        try:
            if dialog.exec():
                self.committed.emit(offset, _to_snes(dialog.selectedColor()))
            else:
                self.cancelled.emit(offset)
        finally:
            # Parented to the dock, so without this every colour change leaves
            # a dialog alive for the life of the window.
            dialog.deleteLater()

    def _reset_selected(self) -> None:
        offset = self._active.selected_offset
        if offset is not None:
            self.reset_asked.emit(offset)

    # -- what the panel says about itself -------------------------------------

    def _show_state(self) -> None:
        """Redraw what the panel says about itself, announcing a **change**.

        ``picked`` fires only where the selection actually moved. It used to
        fire on every call, and `_show_state` runs at the end of every
        `set_scene` and `set_sets` -- so a level refresh, a world map arriving
        or a preview frame re-announced whatever was still selected, and
        `MainWindow._entered_palettes` read that as "the palettes are being
        worked in". Leaving the panel then did not stick: the next redraw took
        Ctrl+Z and Ctrl+S straight back to the colours.
        """
        offset = self._active.selected_offset
        self._change.setEnabled(offset is not None)
        self._reset.setEnabled(offset is not None)
        self._hint.setText(
            NOTHING_SELECTED
            if offset is None
            else self._active.swatches[self._active.selected].tip
        )
        if offset != self._announced:
            self._announced = offset
            self.picked.emit(offset)

    @property
    def hint(self) -> str:
        """What the panel is saying, for tests."""
        return self._hint.text()


def _scrolled(page: QWidget) -> QScrollArea:
    area = QScrollArea()
    area.setWidgetResizable(True)
    area.setWidget(page)
    return area


def _to_snes(color: QColor) -> int:
    """A picked colour as the console stores it.

    The bottom three bits of each channel are gone -- the SNES has five --
    which is why the swatch redraws in the colour that was *stored* rather
    than in the colour that was chosen.
    """
    return (
        ((color.blue() >> 3) << 10) | ((color.green() >> 3) << 5) | (color.red() >> 3)
    )
