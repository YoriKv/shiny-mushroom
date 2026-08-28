"""The Map16 editor: the 512 blocks of the level's tileset, one of them open
for editing, and the level's own graphics to build it out of.

**The window shows the model, drawn in the level's graphics.** The sheet is
:meth:`~shiny_mushroom.map16.Map16Tables.definition` for every tile under the
tileset the level on the canvas loads -- the tables as they are being edited,
not the snapshot's copy, which is the built cartridge -- rendered through
:class:`~shiny_mushroom.level.Blocks` over the snapshot's VRAM and CGRAM, so
a block looks as the game would draw it here. The shared/tileset boundary is
drawn: every tile of a tileset's own run is tinted, and the footer says which
file the selected one lives in and whether an edit to it changes every
tileset.

**The window owns its document.** The tables are loaded from the project
when it is built (:meth:`Project.map16_tables`), edited in place and kept on
a snapshot :class:`~shiny_mushroom.edit.History` of the window's own -- Ctrl+Z
here is the tables', never the level's, for the reason
[undo-redo.md](../../../docs/editor/undo-redo.md) gives every document a stack
of its own. Save writes them through the project and asks the window to load
the level again, which is where the saved patch is seen; Revert takes the
project's files out and re-reads. Nothing here touches the level's document.
"""

from __future__ import annotations

from collections.abc import Callable

from PySide6.QtCore import QEvent, Qt
from PySide6.QtGui import QImage, QKeySequence, QPainter, QShortcut
from PySide6.QtWidgets import (
    QButtonGroup,
    QCheckBox,
    QDialog,
    QFormLayout,
    QGridLayout,
    QGroupBox,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QRadioButton,
    QSpinBox,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.edit import History
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level import BLOCK, TILE
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.map16 import (
    DEF_SIZE,
    FILES,
    TILE_COUNT,
    TILESET_COUNT,
    Map16Error,
    Map16Tables,
    Quadrant,
    TileDefinition,
    is_shared,
)
from shiny_mushroom.project import Project, ProjectError
from shiny_mushroom.ui.cell_grid import CellGrid
from shiny_mushroom.ui.dialogs import Choice, ask, ask_to_save, mark_unsaved, warn
from shiny_mushroom.ui.map16_render import (
    PICKER_COLUMNS,
    SHEET_COLUMNS,
    VRAM_TILES,
    Viewed,
    blit_block,
    block_image,
    picker_image,
    sheet_image,
)
from shiny_mushroom.ui.properties import HexSpinBox
from shiny_mushroom.ui.tables import style_note
from shiny_mushroom.ui.tips import wrap_tip
from shiny_mushroom.ui.zooming import ZoomedArea, ZoomPicker
from smw_tools.map16 import TILESET_TABLES

TITLE = "Map16 Tiles"
OBJECT_NAME = "map16-dialog"

#: How large the edited block is drawn beside its fields.
PREVIEW_SCALE = 4

#: What the Backgrounds fill and every never-written slot holds.
UNUSED = b"\xff" * DEF_SIZE

#: The four quadrants in the order the definition stores them, with where
#: each sits in the block (row, column).
QUADRANTS: tuple[tuple[str, str, int, int], ...] = (
    ("upper_left", "Upper-left", 0, 0),
    ("lower_left", "Lower-left", 1, 0),
    ("upper_right", "Upper-right", 0, 1),
    ("lower_right", "Lower-right", 1, 1),
)

SHARED_NOTE = (
    "Tile {tile} is in {file}.bin, shared by every tileset: an edit changes "
    "every level."
)
OWN_NOTE = "Tile {tile} is in {file}.bin, tileset {tileset}'s own."
#: The eight numbers tilesets 0 and 7 repoint at level load: shared by
#: :func:`~shiny_mushroom.map16.is_shared`'s reckoning, but the file under
#: them here is read by those two tilesets alone.
SLOPED_NOTE = (
    "Tile {tile} is in {file}.bin, read by tilesets $00 and $07: an edit "
    "changes only their levels."
)
UNUSED_NOTE = " Unused: every field is $FF."
NO_LEVEL = "Open a level: the sheet is drawn in the level's own graphics."
NO_TABLES = "Tileset {tileset} has no Map16 tables of its own to edit."
PICKER_HINT = "Graphics in VRAM under palette row {palette}: click to set {quadrant}."
SAVE_TIP = "Write the tables into the project and load the level again  (Ctrl+S)"
REVERT_TIP = "Take the project's Map16 files out, back to the disassembly's own."

UNDO_KEYS = (QKeySequence.StandardKey.Undo, QKeySequence.StandardKey.Redo)


class _QuadrantFields:
    """The five inputs of one quadrant, and the radio that makes it the
    picker's target."""

    def __init__(self, title: str, parent: QWidget) -> None:
        self.box = QGroupBox(parent)
        self.focus = QRadioButton(title, self.box)
        self.tile = HexSpinBox(3, self.box)
        self.tile.setRange(0, 0x3FF)
        self.palette = QSpinBox(self.box)
        self.palette.setRange(0, 7)
        self.palette.setKeyboardTracking(False)
        self.priority = QCheckBox("Priority", self.box)
        self.x_flip = QCheckBox("X flip", self.box)
        self.y_flip = QCheckBox("Y flip", self.box)
        form = QFormLayout()
        form.setContentsMargins(0, 0, 0, 0)
        form.addRow("Tile", self.tile)
        form.addRow("Palette", self.palette)
        flags = QHBoxLayout()
        for box in (self.priority, self.x_flip, self.y_flip):
            flags.addWidget(box)
        body = QVBoxLayout(self.box)
        body.addWidget(self.focus)
        body.addLayout(form)
        body.addLayout(flags)

    @property
    def inputs(self) -> tuple[QWidget, ...]:
        return (self.tile, self.palette, self.priority, self.x_flip, self.y_flip)

    def show(self, quadrant: Quadrant) -> None:
        self.tile.setValue(quadrant.tile)
        self.palette.setValue(quadrant.palette)
        self.priority.setChecked(quadrant.priority)
        self.x_flip.setChecked(quadrant.x_flip)
        self.y_flip.setChecked(quadrant.y_flip)

    def read(self) -> Quadrant:
        return Quadrant(
            tile=self.tile.value(),
            palette=self.palette.value(),
            priority=self.priority.isChecked(),
            x_flip=self.x_flip.isChecked(),
            y_flip=self.y_flip.isChecked(),
        )


class _Preview(QWidget):
    """The edited block, magnified."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._image = QImage()
        self.setFixedSize(BLOCK * PREVIEW_SCALE, BLOCK * PREVIEW_SCALE)

    def show_image(self, image: QImage) -> None:
        self._image = image
        self.update()

    @property
    def image(self) -> QImage:
        return self._image

    def paintEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.SmoothPixmapTransform, False)
        if not self._image.isNull():
            painter.drawImage(self.rect(), self._image)


class Map16Dialog(QDialog):
    """Edit the project's Map16 tables over the level on the canvas.

    Construct once per project with the window's reload door, then
    :meth:`show_snapshot` whenever the level on the canvas changes.
    """

    def __init__(
        self,
        project: Project,
        reload: Callable[[], None],
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        self.setObjectName(OBJECT_NAME)
        self.setModal(False)
        self.resize(1100, 720)
        self._project = project
        self._reload = reload
        self._tables = project.map16_tables()
        #: Whether the project holds saved tables -- what arms Revert. Read
        #: at the three moments it can change rather than per edit: it is
        #: sixteen stats, and the title is redrawn on every keystroke.
        self._saved_any = project.map16_edited
        self._history: History[dict[str, bytes]] = History(self._held())
        self._snapshot: LevelSnapshot | None = None
        self._tileset = 0
        self._clipboard: TileDefinition | None = None
        self._filling = False
        self._picker_images: dict[int, QImage] = {}
        #: The sheet as last drawn, kept so that an edit to one definition
        #: repaints one block of it rather than all 512, or ``None`` when
        #: there is none to keep.
        self._sheet_image: QImage | None = None

        # -- the sheet ------------------------------------------------------
        self._caption = QLabel(NO_LEVEL, self)
        self._caption.setWordWrap(True)
        # One picker over both grids: the blocks and the tiles they are built
        # from are read together, and a zoom that moved only one of them would
        # be a setting the eye has to correct for.
        #
        # Opening at 1x rather than the shared default, which is the one thing
        # this window wants of its own: all 512 blocks fit the pane at 1x, and
        # picking one out of the sheet is what somebody opens this to do. The
        # rest of the ladder is there for reading a block's pixels afterwards.
        self._zoom = ZoomPicker(zoom=1, parent=self)
        self._zoom.setToolTip("Ctrl and the wheel over either grid zoom too.")
        self._sheet = CellGrid(SHEET_COLUMNS, BLOCK, self)
        self._sheet.picked.connect(self._tile_picked)
        sheet_area = ZoomedArea(self._sheet, self._zoom)

        # -- the definition -------------------------------------------------
        self._preview = _Preview(self)
        self._tile_label = QLabel(self)
        self._tile_label.setWordWrap(True)
        self._quadrants: dict[str, _QuadrantFields] = {}
        # One group across the four boxes: radios are exclusive only among
        # siblings, and each quadrant's sits in a group box of its own.
        self._focus_group = QButtonGroup(self)
        grid = QGridLayout()
        for name, title, row, column in QUADRANTS:
            fields = _QuadrantFields(title, self)
            self._focus_group.addButton(fields.focus)
            fields.focus.toggled.connect(self._focus_changed)
            fields.tile.valueChanged.connect(self._quadrant_changed)
            fields.palette.valueChanged.connect(self._quadrant_changed)
            for box in (fields.priority, fields.x_flip, fields.y_flip):
                box.toggled.connect(self._quadrant_changed)
            for widget in fields.inputs:
                widget.installEventFilter(self)
            grid.addWidget(fields.box, row, column)
            self._quadrants[name] = fields
        self._copy = QPushButton("&Copy", self)
        self._copy.setToolTip("Hold this definition, to paste over another tile.")
        self._copy.clicked.connect(self.copy_definition)
        self._paste = QPushButton("&Paste", self)
        self._paste.setToolTip("Write the held definition over this tile.")
        self._paste.clicked.connect(self.paste_definition)
        self._undo = QPushButton("&Undo", self)
        self._undo.clicked.connect(self.undo)
        self._redo = QPushButton("Re&do", self)
        self._redo.clicked.connect(self.redo)
        clipboard = QHBoxLayout()
        for button in (self._copy, self._paste, self._undo, self._redo):
            clipboard.addWidget(button)
        clipboard.addStretch(1)

        head = QHBoxLayout()
        head.addWidget(self._preview, 0, Qt.AlignmentFlag.AlignTop)
        head.addWidget(self._tile_label, 1)
        editor = QVBoxLayout()
        editor.addLayout(head)
        editor.addLayout(grid)
        editor.addLayout(clipboard)
        editor.addStretch(1)

        # -- the picker -----------------------------------------------------
        self._picker_hint = QLabel(self)
        self._picker_hint.setWordWrap(True)
        self._picker = CellGrid(PICKER_COLUMNS, TILE, self)
        self._picker.picked.connect(self._vram_tile_picked)
        picker_area = ZoomedArea(self._picker, self._zoom)

        # -- the footer and the buttons ---------------------------------------
        self._footer = QLabel(self)
        style_note(self._footer)
        self._revert = QPushButton("&Revert", self)
        self._revert.setToolTip(wrap_tip(REVERT_TIP))
        self._revert.clicked.connect(self.revert)
        self._save = QPushButton("&Save", self)
        self._save.setToolTip(wrap_tip(SAVE_TIP))
        self._save.clicked.connect(self.save)
        close = QPushButton("Cl&ose", self)
        close.clicked.connect(self.close)
        buttons = QHBoxLayout()
        buttons.addWidget(self._footer, 1)
        buttons.addWidget(self._revert)
        buttons.addWidget(self._save)
        buttons.addWidget(close)

        left = QVBoxLayout()
        top = QHBoxLayout()
        top.addWidget(self._caption, 1)
        top.addWidget(QLabel("Zoom", self))
        top.addWidget(self._zoom)
        left.addLayout(top)
        left.addWidget(sheet_area, 1)
        right = QVBoxLayout()
        right.addWidget(self._picker_hint)
        right.addWidget(picker_area, 1)
        columns = QHBoxLayout()
        columns.addLayout(left, 2)
        columns.addLayout(editor, 0)
        columns.addLayout(right, 1)
        layout = QVBoxLayout(self)
        layout.addLayout(columns, 1)
        layout.addLayout(buttons)

        QShortcut(QKeySequence.StandardKey.Save, self, self._save_if_lit)
        QShortcut(QKeySequence.StandardKey.Close, self, self.close)
        QShortcut(QKeySequence.StandardKey.Undo, self, self.undo)
        QShortcut(QKeySequence.StandardKey.Redo, self, self.redo)

        self._quadrants["upper_left"].focus.setChecked(True)
        self._sheet.select(0)
        self._show_everything()

    # -- what the window holds --------------------------------------------------

    @property
    def project(self) -> Project:
        return self._project

    @property
    def tables(self) -> Map16Tables:
        """The tables as edited here."""
        return self._tables

    @property
    def unsaved(self) -> bool:
        return bool(self._tables.changed_files)

    @property
    def tileset(self) -> int:
        """The FG/BG tileset the sheet is drawn for -- the level's."""
        return self._tileset

    @property
    def selected(self) -> int:
        """The Map16 tile open in the editor."""
        return max(0, self._sheet.selected)

    @property
    def editable(self) -> bool:
        """Whether there is a level to draw with and a tileset with tables."""
        return self._snapshot is not None and self._tileset < TILESET_COUNT

    @property
    def focused_quadrant(self) -> str:
        """Which quadrant the picker sets -- a :data:`QUADRANTS` name."""
        for name, fields in self._quadrants.items():
            if fields.focus.isChecked():
                return name
        return "upper_left"

    @property
    def clipboard(self) -> TileDefinition | None:
        return self._clipboard

    @property
    def footer(self) -> str:
        return self._footer.text()

    @property
    def caption(self) -> str:
        return self._caption.text()

    @property
    def sheet(self) -> CellGrid:
        return self._sheet

    @property
    def picker(self) -> CellGrid:
        return self._picker

    @property
    def preview(self) -> QImage:
        return self._preview.image

    def definition(self) -> TileDefinition:
        """The selected tile's definition as held."""
        return self._tables.definition(self.selected, self._tileset)

    def show_snapshot(self, snapshot: LevelSnapshot) -> None:
        """Draw the sheet in ``snapshot``'s graphics, for its tileset.

        The held tables are kept: a level change is a change of graphics and
        of which tileset's run is open, never of the edit in hand.
        """
        self._snapshot = snapshot
        self._tileset = snapshot.fg_bg_tileset
        self._picker_images.clear()
        self._sheet_image = None
        self._show_everything()

    # -- selecting -------------------------------------------------------------

    def select(self, tile: int) -> None:
        """Open ``tile`` in the editor."""
        if not 0 <= tile < TILE_COUNT:
            raise Map16Error(f"Map16 tile {tile:#05x} is outside $000-$1FF")
        self._sheet.select(tile)
        self._show_definition()

    def _tile_picked(self, index: int) -> None:
        if index >= 0:
            self._show_definition()

    def focus_quadrant(self, name: str) -> None:
        self._quadrants[name].focus.setChecked(True)

    def _focus_changed(self, checked: bool) -> None:
        if checked:
            self._show_picker()

    # -- editing ---------------------------------------------------------------

    def _quadrant_changed(self, *_: object) -> None:
        if self._filling or not self.editable:
            return
        self.apply(
            TileDefinition(
                **{name: self._quadrants[name].read() for name, *_ in QUADRANTS}
            )
        )

    def apply(self, definition: TileDefinition) -> bool:
        """Make ``definition`` the selected tile's, as one undo step. False
        when it already was."""
        if not self.editable:
            return False
        tile = self.selected
        if self._tables.raw(tile, self._tileset) == definition.encode():
            return False
        self._tables.set_definition(tile, self._tileset, definition)
        self._history.commit(self._held())
        self._show_everything(changed=tile)
        return True

    def _vram_tile_picked(self, index: int) -> None:
        if index < 0 or not self.editable:
            return
        fields = self._quadrants[self.focused_quadrant]
        fields.tile.setValue(index)
        # A spin box already showing the number says nothing on setValue.
        self._quadrant_changed()

    def copy_definition(self) -> None:
        if self.editable:
            self._clipboard = self.definition()
            self._sync_buttons()

    def paste_definition(self) -> None:
        if self._clipboard is not None:
            self.apply(self._clipboard)

    def undo(self) -> None:
        if self._history.undo():
            self._restore(self._history.level)

    def redo(self) -> None:
        if self._history.redo():
            self._restore(self._history.level)

    @property
    def can_undo(self) -> bool:
        return self._history.can_undo

    @property
    def can_redo(self) -> bool:
        return self._history.can_redo

    def _held(self) -> dict[str, bytes]:
        """The held tables as one immutable step."""
        return {name: self._tables.file(name) for name in FILES}

    def _restore(self, held: dict[str, bytes]) -> None:
        for name, data in held.items():
            if self._tables.file(name) != data:
                self._tables.set_file(name, data)
        self._show_everything()

    # -- saving ----------------------------------------------------------------

    def save(self) -> bool:
        """Write the tables into the project and load the level again --
        where the project's saved patch is seen. False if the write failed."""
        try:
            self._project.save_map16(self._tables)
        except (ProjectError, Map16Error, OSError) as error:
            warn(self, "The Map16 tables could not be saved.", detail=str(error))
            return False
        # What was saved is now the base the history measures from.
        self._history.saved()
        self._saved_any = self._project.map16_edited
        self._sync_unsaved()
        self._reload()
        return True

    def _save_if_lit(self) -> None:
        if self._save.isEnabled():
            self.save()

    def revert(self) -> None:
        """Take the project's Map16 files out and re-read the disassembly's."""
        if not self._confirm(
            "Revert the Map16 tables?",
            "Every saved edit is taken out of the project, every edit in "
            "hand is lost, and so is the undo history.",
        ):
            return
        try:
            self._project.revert_map16()
            self._tables = self._project.map16_tables()
        except (ProjectError, Map16Error, OSError) as error:
            warn(self, "The Map16 tables could not be reverted.", detail=str(error))
            return
        self._saved_any = False
        self._history = History(self._held())
        self._show_everything()
        self._reload()

    def _confirm(self, message: str, detail: str = "") -> bool:
        """The seam the suite replaces: offscreen, a modal never returns."""
        return ask(self, message, detail)

    def _ask_to_save(self, message: str, detail: str = "") -> Choice:
        """The same seam for the unsaved-work question."""
        return ask_to_save(self, message, detail)

    def may_close(self) -> bool:
        """Ask about unsaved edits, and act on the answer. True to go on --
        what the window asks before the project goes, and what closing asks."""
        if not self.unsaved:
            return True
        answer = self._ask_to_save(
            "The Map16 tables have unsaved changes.",
            "Discarding reverts to the last save.",
        )
        if answer is Choice.CANCEL:
            return False
        if answer is Choice.DISCARD:
            self.discard()
            return True
        return self.save()

    def discard(self) -> None:
        """Put the tables back to what the project last held, and forget the
        steps that led away from it."""
        self._restore(self._history.base)
        self._history = History(self._held())
        self._show_everything()

    def closeEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        if not self.may_close():
            event.ignore()
            return
        super().closeEvent(event)

    # -- the keyboard ----------------------------------------------------------

    def eventFilter(self, watched, event) -> bool:  # noqa: N802, ANN001 - Qt override
        """Two things about the quadrant inputs.

        Focusing one makes its quadrant the picker's target, so the tile a
        hand is in is the tile a click sets. And a spin box claims Ctrl+Z for
        its own one-line typing history at the ``ShortcutOverride`` offer, as
        every spin box in the window does; declining the offer on its behalf
        is what lets the window's own undo run instead -- the tables', which
        is the document a hand here is editing.
        """
        if event.type() == QEvent.Type.FocusIn:
            for fields in self._quadrants.values():
                if watched in fields.inputs:
                    fields.focus.setChecked(True)
        elif event.type() == QEvent.Type.ShortcutOverride:
            pressed = QKeySequence(event.keyCombination())
            if any(pressed in QKeySequence.keyBindings(key) for key in UNDO_KEYS):
                event.ignore()
                return True
        return super().eventFilter(watched, event)

    # -- drawing ---------------------------------------------------------------

    def _show_everything(self, changed: int | None = None) -> None:
        """Redraw the window. ``changed`` is the one tile whose definition
        moved, where a caller knows -- the sheet is then repainted there
        rather than rebuilt."""
        self._show_sheet(changed)
        self._show_definition()
        self._show_picker()
        self._sync_unsaved()

    def _show_sheet(self, changed: int | None = None) -> None:
        # A grid handed a new image forgets a selection the image has no room
        # for, and an empty one has room for none -- so the tile the editor is
        # open on is put back after the sheet is handed over, or the ring
        # would be missing until somebody clicked.
        open_tile = self.selected
        if not self.editable:
            self._sheet_image = None
            self._sheet.set_image(QImage(), 0)
            if self._snapshot is None:
                self._caption.setText(NO_LEVEL)
            else:
                self._caption.setText(NO_TABLES.format(tileset=hexnum(self._tileset)))
            return
        assert self._snapshot is not None
        # 512 blocks is ~17 ms, and a spin box that steps asks for this on
        # every arrow key -- so the sheet is kept and the one block an edit
        # moved is painted into it. A caller that cannot say which block
        # moved, or one whose level or tileset changed, drops the picture and
        # this builds it again.
        if self._sheet_image is None or changed is None:
            self._sheet_image = sheet_image(self._viewed())
        else:
            blit_block(self._sheet_image, self._viewed(), changed)
        self._sheet.set_image(
            self._sheet_image,
            TILE_COUNT,
            marked=[tile for tile in range(TILE_COUNT) if not is_shared(tile)],
            unused=[
                tile
                for tile in range(TILE_COUNT)
                if self._tables.raw(tile, self._tileset) == UNUSED
            ],
        )
        self._sheet.select(open_tile)
        self._caption.setText(
            f"Tileset {hexnum(self._tileset)} ({TILESET_TABLES[self._tileset]}), "
            f"drawn as level {hexnum(self._snapshot.level, 3)} loads it. "
            "Tinted tiles are this tileset's own; the rest are shared."
        )

    def _show_definition(self) -> None:
        editable = self.editable
        for fields in self._quadrants.values():
            fields.box.setEnabled(editable)
        if not editable:
            self._tile_label.clear()
            self._footer.clear()
            self._preview.show_image(QImage())
            self._sync_buttons()
            return
        tile = self.selected
        raw = self._tables.raw(tile, self._tileset)
        definition = TileDefinition.decode(raw)
        self._filling = True
        try:
            for name, *_ in QUADRANTS:
                self._quadrants[name].show(getattr(definition, name))
        finally:
            self._filling = False
        self._tile_label.setText(f"Tile {hexnum(tile, 3)}")
        file, _ = self._tables.file_of(tile, self._tileset)
        note = (
            SLOPED_NOTE
            if file == "SlopedPipeTiles"
            else SHARED_NOTE
            if is_shared(tile)
            else OWN_NOTE
        ).format(tile=hexnum(tile, 3), file=file, tileset=hexnum(self._tileset))
        if raw == UNUSED:
            note += UNUSED_NOTE
        self._footer.setText(note)
        assert self._snapshot is not None
        self._preview.show_image(block_image(self._snapshot, raw))
        self._sync_buttons()

    def _show_picker(self) -> None:
        if not self.editable:
            self._picker.set_image(QImage(), 0)
            self._picker_hint.clear()
            return
        fields = self._quadrants[self.focused_quadrant]
        palette = fields.palette.value()
        image = self._picker_images.get(palette)
        if image is None:
            image = self._picker_images[palette] = picker_image(self._viewed(), palette)
        self._picker.set_image(image, VRAM_TILES)
        self._picker.select(fields.tile.value())
        self._picker_hint.setText(
            PICKER_HINT.format(palette=palette, quadrant=fields.focus.text().lower())
        )

    def _viewed(self) -> Viewed:
        assert self._snapshot is not None
        tables, tileset = self._tables, self._tileset
        return Viewed(self._snapshot, lambda tile: tables.raw(tile, tileset))

    def _sync_buttons(self) -> None:
        editable = self.editable
        self._copy.setEnabled(editable)
        self._paste.setEnabled(editable and self._clipboard is not None)
        self._undo.setEnabled(self._history.can_undo)
        self._redo.setEnabled(self._history.can_redo)

    def _sync_unsaved(self) -> None:
        self._save.setEnabled(self.unsaved)
        self._revert.setEnabled(self._saved_any or self.unsaved)
        mark_unsaved(self, TITLE, self.unsaved)

    @property
    def save_lit(self) -> bool:
        """Whether Save is offered -- for headless tests."""
        return self._save.isEnabled()
