"""The project's hand-edited source files, as a dialog: add, open, remove --
and, on a tab apiece, the UberASM and PIXI files: create, import.

The overlay is the state and this is a view of it -- materializing a file
copies it, removing one deletes it -- so there is no OK/Cancel pair and
closing is the only way out, exactly as
:mod:`shiny_mushroom.ui.patches_dialog` works.
What the window needs afterwards is :attr:`SourceFilesDialog.overlay_changed`:
whether the set of files the build reads moved, which is what makes closing the
dialog a rebuild -- and :attr:`SourceFilesDialog.project`, which may not be
the one that went in, because a feature switched on from a tab can raise the
cartridge size and a project is frozen.

**Four tabs over one reading.** *All Files* is the overlay as it is, every
row; *UberASM* and *PIXI* are the same rows filtered to the kinds each
feature assembles (:data:`shiny_mushroom.source_files.UBERASM_KINDS`,
:data:`~shiny_mushroom.source_files.PIXI_KINDS`), with the buttons that only
make sense for those files: **Create** writes a file of the right shape from
a template, **Import** brings one in from outside rewritten to assemble here.
*AddmusicK* is the one list that is not the overlay's: the song packages in
the project's ``music/`` folder (:func:`~shiny_mushroom.source_files.music_rows`),
with **Import** copying a package in from elsewhere, samples and all -- what
compiles them is the Audio window's own Import, which needs the tool.
Each feature tab also says when its feature is off -- the files are then
assembled into nothing -- and offers the switch, so a person is never left
writing code no build reads.

**Editing happens elsewhere.** The file is handed to whatever the desktop opens
``.asm`` with; an asm author already has an editor, and one grown here would be
a worse one. So the dialog's job is to say which files are in play, which of
them the editor owns, and what is wrong with any of them -- see
:mod:`shiny_mushroom.source_files`, which answers all three and knows nothing
about Qt.

**Nothing watches the overlay**, so the dialog re-reads it whenever this
application is given the focus back: coming back from the editor a file was
handed to is exactly when a hand edit has just happened, and the list would
otherwise go on showing what was there before somebody left. A stat apiece
decides whether there is anything to re-read at all, which is what makes that
affordable every time -- see :meth:`SourceFilesDialog._recheck`.

**The application's focus, not this window's.** The dialog is modeless and
somebody who alt-tabs away from it comes back to whichever window they were
last in, which is usually the main one -- and this window, sitting behind it,
would go on showing what it showed before. So the hook is
``focusWindowChanged``, which fires for every window of this application and
not for the widgets inside one: the sweep runs when somebody comes back to
the application, wherever they land, and not on every click.
"""

from __future__ import annotations

from collections.abc import Iterable
from pathlib import Path

from PySide6.QtCore import Qt
from PySide6.QtGui import QGuiApplication, QWindow
from PySide6.QtWidgets import (
    QAbstractItemView,
    QComboBox,
    QDialog,
    QDialogButtonBox,
    QFileDialog,
    QFormLayout,
    QHBoxLayout,
    QInputDialog,
    QLabel,
    QLineEdit,
    QMessageBox,
    QPushButton,
    QSpinBox,
    QTableWidget,
    QTableWidgetItem,
    QTabWidget,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import features, project_code, project_sprites, source_files
from shiny_mushroom.build import symbol_file
from shiny_mushroom.project import Project, ProjectError
from shiny_mushroom.project_code import CodeError
from shiny_mushroom.project_music import MUSIC_DIR, MUSIC_SUFFIXES
from shiny_mushroom.ui.dialogs import open_file, open_folder
from shiny_mushroom.ui.sprite_properties_dialog import SpritePropertiesDialog
from shiny_mushroom.ui.tables import PaddedCells, style_note, style_table
from shiny_mushroom.ui.tips import wrap_tip
from smw_tools.features import (
    CUSTOM_MUSIC,
    CUSTOM_SPRITES,
    FEATURES,
    UBERASM_SUPPORT,
    FeatureError,
)
from smw_tools.sprite_code import KINDS
from smw_tools.symbols import SymbolTable, load_symbols

TITLE = "Source Files"

#: The four tabs, by the name on each.
ALL = "All Files"
UBERASM = "UberASM"
PIXI = "PIXI"
MUSIC = "AddmusicK"

#: What each list is, and the one idea a reader has to be handed: these files
#: stand in for the disassembly's, and removing one puts the original back;
#: the feature tabs' files are the project's own and the folder says what
#: each is for.
HINT = (
    "Each row is a file of the project's own, used instead of the "
    "disassembly's at build time."
)
UBERASM_HINT = (
    "Code the project runs in a level, in a game mode or every frame, written "
    "the way UberASM Tool writes it. The folder says the kind and the filename "
    "the level or mode."
)
PIXI_HINT = (
    "The project's custom sprites, written the way PIXI writes them: a "
    "sprite's code and properties per number, the library they call and the "
    "shared routines."
)
MUSIC_HINT = (
    "The song packages in the project's music folder, each an MML file with "
    "its samples in a folder beside it, exactly as AddmusicK is handed them. "
    "Import in the Audio window compiles them into the cartridge."
)

COLUMNS = ("File", "Kind", "Status")

#: How much wider than its longest path the File column is drawn. The path is
#: what a row is picked by and the one column worth reading whole, so it gets
#: room for a deeper one than the overlay happens to hold today rather than
#: being cut to exactly what is in it.
FILE_COLUMN_ROOM = 2

_COLUMN_NOTES = {
    "Kind": (
        "Who writes the file. The editor keeps its own up to date; "
        "hand-edited is yours alone."
    ),
    "Status": (
        "What the editor makes of the file. One edited past what it can read "
        "is left alone and never overwritten."
    ),
}

#: The item data slot holding the row's overlay-relative path.
_PATH_ROLE = Qt.ItemDataRole.UserRole

#: The UberASM kinds as the asking names them, in the order offered.
CODE_KIND_NAMES = {
    "level": "Level",
    "gamemode": "Game mode",
    "global": "Global",
    "library": "Library",
    "macros": "Macro library",
}


class _Pane(QWidget):
    """One tab: a table over the rows of some kinds, and the buttons for
    them. The dialog owns the rows and every action; a pane only draws its
    share and says which row is picked."""

    def __init__(
        self,
        hint: str,
        kinds: tuple[str, ...] | None,
        feature_id: str | None,
        parent: QWidget | None = None,
        does: str = "assembled",
    ) -> None:
        super().__init__(parent)
        #: Which kinds this pane lists, ``None`` for every row.
        self.kinds = kinds
        #: The feature whose files these are, for the notice and the switch,
        #: and what a build with it does to them, for the notice's sentence.
        self.feature_id = feature_id
        self.does = does
        self.rows: list[source_files.SourceFileRow | source_files.MusicRow] = []

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        held = QLabel(hint)
        held.setWordWrap(True)
        style_note(held)
        layout.addWidget(held)

        notice = QHBoxLayout()
        self.notice = QLabel()
        self.notice.setWordWrap(True)
        style_note(self.notice)
        notice.addWidget(self.notice, 1)
        self.switch = QPushButton()
        notice.addWidget(self.switch)
        self.notice.setVisible(False)
        self.switch.setVisible(False)
        layout.addLayout(notice)

        self.table = QTableWidget(0, len(COLUMNS))
        self.table.setHorizontalHeaderLabels(COLUMNS)
        for column, name in enumerate(COLUMNS):
            note = _COLUMN_NOTES.get(name)
            if note is not None:
                self.table.horizontalHeaderItem(column).setToolTip(wrap_tip(note))
        self.table.verticalHeader().setVisible(False)
        self.table.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self.table.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self.table.setSelectionMode(QAbstractItemView.SelectionMode.SingleSelection)
        style_table(self.table)
        self.table.setItemDelegate(PaddedCells(self.table))
        layout.addWidget(self.table)

        self.moved = QLabel()
        style_note(self.moved)
        self.moved.setVisible(False)
        layout.addWidget(self.moved)

        #: The button row: the dialog puts its own on the left, and the
        #: three every pane has sit on the right.
        self.buttons = QHBoxLayout()
        self.buttons.addStretch()
        self.properties = QPushButton("&Properties...")
        self.buttons.addWidget(self.properties)
        self.open = QPushButton("&Open")
        self.buttons.addWidget(self.open)
        self.remove = QPushButton("&Remove File...")
        self.buttons.addWidget(self.remove)
        layout.addLayout(self.buttons)

    def add_button(self, button: QPushButton) -> None:
        """Put one of the dialog's buttons on the left of the row."""
        self.buttons.insertWidget(self.buttons.count() - 4, button)

    def fill(
        self, rows: Iterable[source_files.SourceFileRow | source_files.MusicRow]
    ) -> None:
        """Draw this pane's share of the rows, keeping the row somebody was
        on."""
        chosen = self.current_path()
        self.rows = [
            row for row in rows if self.kinds is None or row.kind in self.kinds
        ]
        self.moved.setVisible(False)
        self.table.setRowCount(len(self.rows))
        for index, row in enumerate(self.rows):
            for column, text in enumerate(
                (str(row.relative), row.name, row.note or "-")
            ):
                item = QTableWidgetItem(text)
                item.setData(_PATH_ROLE, row.relative)
                if row.problem:
                    item.setToolTip(row.note)
                self.table.setItem(index, column, item)
            if row.relative == chosen:
                self.table.setCurrentCell(index, 0)
        self.table.resizeColumnsToContents()
        self.table.setColumnWidth(0, self.table.columnWidth(0) * FILE_COLUMN_ROOM)

    def say_feature(self, off: bool) -> None:
        """Show the feature-off notice, or take it down."""
        if off and self.feature_id is not None:
            name = FEATURES[self.feature_id].name
            self.notice.setText(
                f"{name} is off, so none of these files is {self.does} until "
                f"it is turned on."
            )
            self.switch.setText(f"Turn On {name}")
        self.notice.setVisible(off)
        self.switch.setVisible(off)

    def current_path(self) -> Path | None:
        item = self.table.item(self.table.currentRow(), 0)
        return None if item is None else item.data(_PATH_ROLE)

    def current(self) -> source_files.SourceFileRow | source_files.MusicRow | None:
        index = self.table.currentRow()
        return self.rows[index] if 0 <= index < len(self.rows) else None

    def select(self, relative: Path) -> None:
        for index, row in enumerate(self.rows):
            if row.relative == relative:
                self.table.setCurrentCell(index, 0)
                return


class SourceFilesDialog(QDialog):
    """One project's overlay. Construct, ``exec``, then read
    :attr:`overlay_changed` and :attr:`project`."""

    def __init__(self, project: Project, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        #: The project as the dialog holds it. Not always the one handed in:
        #: a feature switched on from a tab may have grown the cartridge,
        #: and the window has to take the one handed back.
        self.project = project
        #: Whether the files the build reads moved -- a file materialized,
        #: created, removed, or put in or taken away from outside while
        #: somebody was in another window (:meth:`_recheck`) -- or a feature
        #: was switched. Editing one *in place* is not counted, though the
        #: dialog does notice it: the same file is in the build either way,
        #: and its fingerprint is what decides.
        self.overlay_changed = False
        self._rows: list[source_files.SourceFileRow] = []
        self._songs: list[source_files.MusicRow] = []
        #: What the overlay's files looked like when the list was last read --
        #: see :meth:`_recheck`, which is what an outside edit is noticed
        #: against, there being nothing watching them.
        self._stamps: dict[Path, tuple[int, int]] = {}

        # Every window of this application, so coming back to the main one
        # with this behind it re-reads too -- see :meth:`_focus_moved`. The
        # connection is owned by this dialog and goes when it does.
        app = QGuiApplication.instance()
        if app is not None:
            app.focusWindowChanged.connect(self._focus_moved)

        self.setWindowTitle(TITLE)
        self.setMinimumSize(760, 460)

        layout = QVBoxLayout(self)
        self._tabs = QTabWidget()
        self._panes: dict[str, _Pane] = {
            ALL: _Pane(HINT, None, None),
            UBERASM: _Pane(
                UBERASM_HINT, source_files.UBERASM_KINDS, UBERASM_SUPPORT.id
            ),
            PIXI: _Pane(PIXI_HINT, source_files.PIXI_KINDS, CUSTOM_SPRITES.id),
            MUSIC: _Pane(
                MUSIC_HINT,
                (source_files.SONG,),
                CUSTOM_MUSIC.id,
                does="carried in the cartridge",
            ),
        }
        for name, pane in self._panes.items():
            self._tabs.addTab(pane, name)
            pane.table.currentCellChanged.connect(lambda *_a: self._sync_buttons())
            pane.table.itemDoubleClicked.connect(lambda _item: self._open())
            pane.properties.clicked.connect(self._edit_properties)
            pane.open.clicked.connect(self._open)
            pane.remove.clicked.connect(self._delete)
            pane.switch.clicked.connect(self._switch_on)
        self._tabs.currentChanged.connect(lambda _index: self._sync_buttons())
        layout.addWidget(self._tabs)

        add = QPushButton("&Add a File...")
        add.setToolTip(
            wrap_tip(
                "Copy one of the disassembly's files into the project to edit "
                "by hand; the build reads the copy in its place."
            )
        )
        add.clicked.connect(self._add)
        self._panes[ALL].add_button(add)

        create_code = QPushButton("&Create...")
        create_code.setToolTip(
            wrap_tip(
                "Write a new code file of the kind and number you choose, with "
                "its entry points laid out, and open it."
            )
        )
        create_code.clicked.connect(self._create_code)
        self._panes[UBERASM].add_button(create_code)
        import_code = QPushButton("&Import...")
        import_code.setToolTip(
            wrap_tip(
                "Bring UberASM files in from elsewhere, rewritten to assemble "
                "here. You say which level or mode each one is for."
            )
        )
        import_code.clicked.connect(self._import_code)
        self._panes[UBERASM].add_button(import_code)

        create_sprite = QPushButton("&Create...")
        create_sprite.setToolTip(
            wrap_tip(
                "Write a new sprite of the kind and number you choose, with "
                "its entry points laid out and its properties beside it."
            )
        )
        create_sprite.clicked.connect(self._create_sprite)
        self._panes[PIXI].add_button(create_sprite)
        sprites = QPushButton("Import &Sprites...")
        sprites.setToolTip(
            wrap_tip(
                "Bring PIXI sprites into the project, rewritten to assemble "
                "here. A sprite's .json sibling comes along with it."
            )
        )
        sprites.clicked.connect(self._import_sprites)
        self._panes[PIXI].add_button(sprites)
        routines = QPushButton("Import Rou&tines...")
        routines.setToolTip(
            wrap_tip(
                "Bring PIXI's shared routines (%GetDrawInfo and its "
                "siblings) in from your copy of that tool."
            )
        )
        routines.clicked.connect(self._import_routines)
        self._panes[PIXI].add_button(routines)

        songs = QPushButton("&Import...")
        songs.setToolTip(
            wrap_tip(
                "Copy song packages into the project's music folder from "
                "wherever they are: each MML file and the sample folder it "
                "names beside itself, untouched. Import in the Audio window "
                "then compiles them."
            )
        )
        songs.clicked.connect(self._import_songs)
        self._panes[MUSIC].add_button(songs)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        folder = buttons.addButton(
            "Open &Folder", QDialogButtonBox.ButtonRole.ActionRole
        )
        folder.clicked.connect(self._open_folder)
        layout.addWidget(buttons)

        self._refill()

    # -- the list ------------------------------------------------------------

    def _pane(self) -> _Pane:
        """The tab in front, whose row the buttons act on."""
        pane = self._tabs.currentWidget()
        return pane if isinstance(pane, _Pane) else self._panes[ALL]

    def show_tab(self, name: str) -> None:
        self._tabs.setCurrentWidget(self._panes[name])

    @property
    def _table(self) -> QTableWidget:
        return self._pane().table

    @property
    def _open_button(self) -> QPushButton:
        return self._pane().open

    @property
    def _remove(self) -> QPushButton:
        return self._pane().remove

    @property
    def _properties(self) -> QPushButton:
        return self._pane().properties

    @property
    def _moved(self) -> QLabel:
        return self._pane().moved

    def _refill(self, stamps: dict[Path, tuple[int, int]] | None = None) -> None:
        """Read the overlay again, keeping the row somebody was on.

        Stamped *before* the rows are read rather than after, and given the
        sweep :meth:`_recheck` already took where there is one: a file that
        moves between the stat and the read is then reported at the next
        activation, rather than absorbed as though the list had always been
        showing it.
        """
        self._stamps = self._stamps_now() if stamps is None else stamps
        self._rows = source_files.rows(self.project)
        self._songs = source_files.music_rows(self.project)
        for pane in self._panes.values():
            pane.fill(self._songs if pane is self._panes[MUSIC] else self._rows)
            if pane.feature_id is not None:
                pane.say_feature(
                    bool(source_files.feature_off(self.project, pane.feature_id))
                )
        self._sync_buttons()

    def _current(self) -> source_files.SourceFileRow | source_files.MusicRow | None:
        return self._pane().current()

    def _held(self, row: source_files.SourceFileRow | source_files.MusicRow) -> Path:
        """Where one row's file is on disk: a package is under the project
        folder, everything else under the overlay."""
        if isinstance(row, source_files.MusicRow):
            return self.project.root / row.relative
        return self.project.overlay / row.relative

    def _open_folder(self) -> None:
        """The folder the tab in front lists: the music folder for the
        songs, the overlay for everything else."""
        if self._pane() is self._panes[MUSIC]:
            open_folder(self.project.make_music_folder())
        else:
            open_folder(self.project.overlay)

    def _stamps_now(self) -> dict[Path, tuple[int, int]]:
        """Every file any tab lists, stamped -- the overlay's and the
        packages' together, since either can move while somebody is away."""
        return {
            **source_files.overlay_stamps(self.project),
            **source_files.music_stamps(self.project),
        }

    def _sync_buttons(self) -> None:
        pane = self._pane()
        row = pane.current()
        pane.open.setEnabled(row is not None and row.editable)
        # A normal sprite's row offers its properties whether the sibling
        # exists yet or not -- opening the dialog on a sprite without one is
        # how one gets made.
        pane.properties.setEnabled(
            row is not None
            and (
                row.kind == source_files.SPRITE_META
                or (row.kind == source_files.SPRITE and "normal" in row.relative.parts)
            )
        )
        pane.properties.setVisible(
            pane.kinds is None or pane.kinds == source_files.PIXI_KINDS
        )
        # Every row, including the ones the editor writes for itself and the
        # stray that is editable by nobody: this is the list of what the
        # project holds, and being able to take a file out of it is the whole
        # of what removing means. What that costs is said in the question.
        pane.remove.setEnabled(row is not None)

    # -- what the buttons do --------------------------------------------------

    def _add(self) -> None:
        """Copy a file of the disassembly into the overlay and open it.

        Rooted at the game folder, because that is the tree whose files the
        overlay shadows by path -- the assets are reached another way and are
        not text to edit by hand.
        """
        chosen, _filter = QFileDialog.getOpenFileName(
            self,
            "Edit a source file",
            str(self.project.base),
            "asar sources (*.asm);;All files (*)",
        )
        if not chosen:
            return
        try:
            materialized = self.project.materialize_source(Path(chosen))
        except ProjectError as error:
            QMessageBox.warning(self, TITLE, str(error))
            return
        self.overlay_changed = True
        self._refill()
        self._select(materialized.relative_to(self.project.overlay))
        open_file(materialized)

    def _open(self) -> None:
        row = self._current()
        if row is None or not row.editable:
            return
        if not open_file(self._held(row)):
            QMessageBox.information(
                self,
                TITLE,
                "Nothing on this desktop is registered to open that file. "
                "Open Folder shows where it is.",
            )

    def _delete(self) -> None:
        row = self._current()
        if row is None:
            return
        asked = QMessageBox.question(
            self,
            "Remove file",
            f"Remove {row.relative} from the project?\n\n" + _consequence(row),
        )
        if asked != QMessageBox.StandardButton.Yes:
            return
        try:
            if isinstance(row, source_files.MusicRow):
                # A package is not in the build until the next compile reads
                # the folder again, so taking one out owes no rebuild.
                self.project.remove_music_package(row.relative.relative_to(MUSIC_DIR))
                self._refill()
                return
            self.project.revert_source(row.relative)
        except OSError as error:
            QMessageBox.warning(self, TITLE, str(error))
            return
        # A stray was never in the build, so removing one changes nothing it
        # would read -- and a rebuild that assembles the same bytes is not
        # worth making somebody wait for.
        if not row.stray:
            self.overlay_changed = True
        self._refill()

    def _edit_properties(self) -> None:
        """The selected sprite's properties, in the application.

        The metadata sibling is the editor's to write, so unlike the asm it
        gets a dialog rather than the desktop's editor -- and a sprite with
        no sibling yet gets one written, defaults and all, the moment OK is
        pressed.
        """
        row = self._current()
        if row is None:
            return
        try:
            number = int(row.relative.stem, 16)
        except ValueError:
            number = None
        dialog = SpritePropertiesDialog(
            self._held(row).with_suffix(".json"),
            self,
            project=self.project,
            number=number,
        )
        dialog.exec()
        if dialog.saved:
            self.overlay_changed = True
            self._refill()

    # -- UberASM ---------------------------------------------------------------

    def _create_code(self) -> None:
        dialog = CreateCodeDialog(self)
        if dialog.exec() != QDialog.DialogCode.Accepted:
            return
        self._make_code(dialog.kind, dialog.name)

    def _make_code(self, kind: str, name: str) -> Path | None:
        """Write the template, list it, open it, and offer the feature where
        the build would not assemble it."""
        try:
            landed = project_code.create_file(self.project, kind, name)
        except (CodeError, OSError) as error:
            QMessageBox.warning(self, "Create code", str(error))
            return None
        self.overlay_changed = True
        self._refill()
        self.show_tab(UBERASM)
        self._select(landed)
        open_file(self.project.overlay / landed)
        self._offer_feature(UBERASM_SUPPORT.id)
        return landed

    def _import_code(self) -> None:
        """Bring UberASM files in, each under the name the person gives it.

        The kind is asked once for the batch. What each file is *for* -- the
        level, the mode, the global stem -- is the one thing the file cannot
        say, and it is asked per file, prefilled from a filename that already
        says it.
        """
        kind, accepted = QInputDialog.getItem(
            self, "Import code", "Kind:", list(CODE_KIND_NAMES.values()), 0, False
        )
        if not accepted:
            return
        kind = next(key for key, name in CODE_KIND_NAMES.items() if name == kind)
        chosen, _filter = QFileDialog.getOpenFileNames(
            self, "Import code", "", "asar sources (*.asm);;All files (*)"
        )
        if not chosen:
            return
        named: list[tuple[Path, str]] = []
        for path in map(Path, chosen):
            name = self._ask_name(kind, path)
            if name is None:
                return
            named.append((path, name))
        self._bring_code(kind, named)

    def _ask_name(self, kind: str, path: Path) -> str | None:
        """What one imported file is for, in the kind's own terms, or
        ``None`` for a cancelled asking. A filename that already answers --
        ``105.asm`` for a level, ``statusbar.asm`` for a global -- is
        offered as the answer rather than asked again."""
        _folder, what, _entries = project_code.KINDS[kind]
        try:
            offered = project_code.stem_for(kind, path.stem)
        except CodeError:
            offered = "global" if kind == "global" else ""
        if kind == "global":
            names = sorted(project_code.GLOBAL_FILES)
            name, accepted = QInputDialog.getItem(
                self,
                "Import code",
                f"{path.name} is:",
                names,
                names.index(offered) if offered in names else 0,
                False,
            )
            return name if accepted else None
        while True:
            name, accepted = QInputDialog.getText(
                self, "Import code", f"{path.name}: {what}", text=offered
            )
            if not accepted:
                return None
            try:
                project_code.stem_for(kind, name)
            except CodeError as error:
                QMessageBox.warning(self, "Import code", str(error))
                continue
            return name

    def _bring_code(self, kind: str, named: Iterable[tuple[Path, str]]) -> None:
        notes: list[str] = []
        symbols = self._symbols()
        landed: Path | None = None
        for path, name in named:
            try:
                imported = project_code.import_file(
                    self.project, kind, path, name, symbols
                )
            except (CodeError, OSError) as error:
                QMessageBox.warning(self, "Import code", str(error))
                break
            notes += imported.notes
            landed = imported.landed[0]
        if landed is None:
            return
        self.overlay_changed = True
        self._refill()
        self.show_tab(UBERASM)
        self._select(landed)
        QMessageBox.information(self, "Import code", "\n".join(notes))
        self._offer_feature(UBERASM_SUPPORT.id)

    # -- PIXI ------------------------------------------------------------------

    def _create_sprite(self) -> None:
        dialog = CreateSpriteDialog(self.project, self)
        if dialog.exec() != QDialog.DialogCode.Accepted:
            return
        self._make_sprite(dialog.kind, dialog.number)

    def _make_sprite(self, kind: str, number: int) -> tuple[Path, ...]:
        """Write the template and, for a normal sprite, its properties;
        then open the properties on it, since the name and the acts-like
        number are the first things a new sprite wants."""
        try:
            landed = project_sprites.create_sprite(self.project, kind, number)
        except (CodeError, OSError) as error:
            QMessageBox.warning(self, "Create sprite", str(error))
            return ()
        self.overlay_changed = True
        self._refill()
        self.show_tab(PIXI)
        self._select(landed[0])
        open_file(self.project.overlay / landed[0])
        if kind == "normal":
            self._edit_properties()
        self._offer_feature(CUSTOM_SPRITES.id)
        return landed

    def _import_sprites(self) -> None:
        """Bring PIXI sprites in, converted to this build's own labels.

        The kind is asked once for the batch, because it is the one thing
        the files cannot say for themselves -- the folder is what carries it
        from then on.
        """
        kind, accepted = QInputDialog.getItem(
            self, "Import sprites", "Sprite kind:", list(KINDS), 0, False
        )
        if not accepted:
            return
        chosen, _filter = QFileDialog.getOpenFileNames(
            self, "Import sprites", "", "asar sources (*.asm);;All files (*)"
        )
        if not chosen:
            return
        try:
            imported = project_sprites.import_sprites(
                self.project, kind, [Path(path) for path in chosen], self._symbols()
            )
        except (CodeError, OSError) as error:
            QMessageBox.warning(self, "Import sprites", str(error))
            return
        self.overlay_changed = True
        self._refill()
        self.show_tab(PIXI)
        if imported.landed:
            self._select(imported.landed[0])
        QMessageBox.information(self, "Import sprites", "\n".join(imported.notes))
        self._offer_feature(CUSTOM_SPRITES.id)

    def _import_routines(self) -> None:
        chosen, _filter = QFileDialog.getOpenFileNames(
            self, "Import routines", "", "asar sources (*.asm);;All files (*)"
        )
        if not chosen:
            return
        try:
            imported = project_sprites.import_routines(
                self.project, [Path(path) for path in chosen]
            )
        except (CodeError, OSError) as error:
            QMessageBox.warning(self, "Import routines", str(error))
            return
        self.overlay_changed = True
        self._refill()
        self.show_tab(PIXI)
        QMessageBox.information(self, "Import routines", "\n".join(imported.notes))
        self._offer_feature(CUSTOM_SPRITES.id)

    # -- AddmusicK -------------------------------------------------------------

    def _import_songs(self) -> None:
        """Copy packages in from wherever they are. What is picked is the
        MML; the sample folder it names comes along from beside it."""
        chosen, _filter = QFileDialog.getOpenFileNames(
            self,
            "Import songs",
            "",
            f"AddmusicK songs ({' '.join(f'*{s}' for s in MUSIC_SUFFIXES)});;"
            f"All files (*)",
        )
        if not chosen:
            return
        self._bring_songs([Path(path) for path in chosen])

    def _bring_songs(self, paths: Iterable[Path]) -> None:
        """A package is data the folder keeps rather than a file the build
        reads, so bringing one in owes no rebuild: the Audio window's Import
        is what compiles it, and that is what the row says."""
        landed: list[Path] = []
        for path in paths:
            try:
                landed += self.project.add_music_package(path)
            except (ProjectError, OSError) as error:
                QMessageBox.warning(self, "Import songs", str(error))
                break
        if not landed:
            return
        self._refill()
        self.show_tab(MUSIC)
        self._select(MUSIC_DIR / landed[0])
        self._offer_feature(CUSTOM_MUSIC.id)

    def _symbols(self) -> SymbolTable | None:
        """The project build's own symbols, or ``None`` before a first build
        -- the import then leaves addresses as they are and says so."""
        path = symbol_file(self.project)
        if not path.is_file():
            return None
        try:
            return load_symbols(path)
        except OSError:
            return None

    # -- the feature switch ----------------------------------------------------

    def _offer_feature(self, feature_id: str) -> None:
        """After a file of ``feature_id`` was written: where the next build
        would not have the feature, ask to switch it on now, because a file
        just written is a file somebody expects the build to read."""
        if not source_files.feature_off(self.project, feature_id):
            return
        name = FEATURES[feature_id].name
        does = (
            "carry the song" if feature_id == CUSTOM_MUSIC.id else "assemble the file"
        )
        asked = QMessageBox.question(
            self,
            name,
            f"{name} is off, so the build will not {does}.\n\nTurn it on now?",
        )
        if asked == QMessageBox.StandardButton.Yes:
            self._enable(feature_id)

    def _switch_on(self) -> None:
        """The notice's own button: the tab in front knows its feature."""
        feature_id = self._pane().feature_id
        if feature_id is not None:
            self._enable(feature_id)

    def _enable(self, feature_id: str) -> bool:
        """Throw the switch, migration and all, and take the project handed
        back. A refusal is the feature dialog's own: every reason, and what
        to do about each."""
        try:
            done = features.enable(self.project, feature_id)
        except features.FeatureBlocked as blocked:
            listed = "\n\n".join(
                limit.reason + (f"\n{limit.remedy}" if limit.remedy else "")
                for limit in blocked.limits
            )
            QMessageBox.information(
                self, f"{FEATURES[feature_id].name} cannot be turned on", listed
            )
            return False
        except (FeatureError, ProjectError, OSError) as error:
            QMessageBox.warning(self, TITLE, str(error))
            return False
        self.project = done.project
        self.overlay_changed = True
        self._refill()
        if done.notes:
            QMessageBox.information(
                self, FEATURES[feature_id].name, "\n".join(done.notes)
            )
        return True

    # -- what moved while somebody was in another window ---------------------

    def _focus_moved(self, window: QWindow | None) -> None:
        """Read the overlay again when this application is given the focus.

        ``None`` is the application having no focused window at all, which is
        somebody leaving rather than arriving; anything else is a window of
        this application, since that is the only kind this signal reports.

        Its own picker and message box change the focus window too and are
        not a hand edit, but :meth:`_recheck` is a stat sweep that says
        nothing when nothing moved, so telling those from a return out of the
        editor would buy nothing.
        """
        if window is not None and self.isVisible():
            self._recheck()

    def _recheck(self) -> None:
        """Re-read the overlay if a file in it has moved, and say which.

        The sweep is what makes this cheap enough to run on every activation:
        an overlay nothing touched costs a stat apiece and stops there, and
        only a list that has actually moved is read and parsed again.
        """
        found = self._stamps_now()
        if found == self._stamps:
            return
        before = self._stamps
        rows = {row.relative: row for row in self._rows}
        moved = sorted(
            str(relative)
            for relative, stamp in found.items()
            if relative in before and before[relative] != stamp
        )
        self._refill(found)
        # Both readings, because a file that went away is only in the old one.
        rows.update({row.relative: row for row in self._rows})
        for relative in set(found) ^ set(before):
            # A file that appeared or went away is one the build reads
            # differently, so closing has to rebuild -- with the exemption
            # :meth:`_delete` makes, a stray having never been in one.
            row = rows.get(relative)
            if row is not None and not row.stray:
                self.overlay_changed = True
        self._say(moved)

    def _say(self, moved: list[str]) -> None:
        """Name the files whose contents moved, under each list.

        Only those: a file that appeared or went away moved the list itself,
        which is on show and needs no sentence written about it.
        """
        for pane in self._panes.values():
            pane.moved.setText(
                f"{'; '.join(moved)} changed on disk. The rows show what is there now."
                if moved
                else ""
            )
            pane.moved.setVisible(bool(moved))

    def _select(self, relative: Path) -> None:
        for pane in self._panes.values():
            pane.select(relative)


class CreateCodeDialog(QDialog):
    """Ask what kind of code file to create and what it is for. Construct,
    ``exec``, then read :attr:`kind` and :attr:`name`."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle("Create code")
        self.kind = "level"
        self.name = ""
        form = QFormLayout(self)
        self._kinds = QComboBox()
        for key, shown in CODE_KIND_NAMES.items():
            self._kinds.addItem(shown, key)
        self._kinds.currentIndexChanged.connect(lambda _i: self._kind_changed())
        form.addRow("Kind:", self._kinds)
        self._name = QLineEdit()
        form.addRow("For:", self._name)
        self._what = QLabel()
        self._what.setWordWrap(True)
        style_note(self._what)
        form.addRow("", self._what)
        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self._accept)
        buttons.rejected.connect(self.reject)
        form.addRow(buttons)
        self._kind_changed()

    def _kind_changed(self) -> None:
        kind = self._kinds.currentData()
        self._what.setText(project_code.KINDS[kind][1].capitalize() + ".")
        self._name.setText("global" if kind == "global" else "")
        self._name.setFocus()

    def _accept(self) -> None:
        kind = self._kinds.currentData()
        try:
            project_code.stem_for(kind, self._name.text())
        except CodeError as error:
            QMessageBox.warning(self, "Create code", str(error))
            return
        self.kind = kind
        self.name = self._name.text()
        self.accept()


class CreateSpriteDialog(QDialog):
    """Ask what kind of sprite to create and under which number. Construct,
    ``exec``, then read :attr:`kind` and :attr:`number`. The number offered
    is the kind's first free one."""

    def __init__(self, project: Project, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle("Create sprite")
        self._project = project
        self.kind = "normal"
        self.number = 0
        form = QFormLayout(self)
        self._kinds = QComboBox()
        for kind in KINDS:
            self._kinds.addItem(kind, kind)
        self._kinds.currentIndexChanged.connect(lambda _i: self._kind_changed())
        form.addRow("Kind:", self._kinds)
        self._number = QSpinBox()
        self._number.setDisplayIntegerBase(16)
        self._number.setPrefix("$")
        form.addRow("Number:", self._number)
        self._what = QLabel()
        self._what.setWordWrap(True)
        style_note(self._what)
        form.addRow("", self._what)
        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self._accept)
        buttons.rejected.connect(self.reject)
        form.addRow(buttons)
        self._kind_changed()

    def _kind_changed(self) -> None:
        kind = self._kinds.currentData()
        first, last = project_sprites.number_range(kind)
        self._number.setRange(first, last)
        try:
            self._number.setValue(project_sprites.next_free_number(self._project, kind))
        except CodeError:
            self._number.setValue(first)
        self._what.setText(
            f"A custom {kind} sprite is numbered ${first:02X} to ${last:02X}; "
            f"the number offered is the first free one."
        )

    def _accept(self) -> None:
        self.kind = self._kinds.currentData()
        self.number = self._number.value()
        self.accept()


def _consequence(row: source_files.SourceFileRow | source_files.MusicRow) -> str:
    """What removing one file costs, for the question that asks about it."""
    if isinstance(row, source_files.MusicRow):
        return (
            "The package and the sample folder it names are deleted. What the "
            "last Import compiled stays in the cartridge until the next one."
        )
    if row.stray:
        return "It stands in for nothing, so the build already ignores it."
    if row.kind in (source_files.SOURCE, source_files.REGION):
        return (
            "The build reads the disassembly's own copy again; any hand edits are lost."
        )
    if row.kind in source_files.UBERASM_KINDS + source_files.PIXI_KINDS:
        # The project's own asm and sprites: nothing ships behind them, and
        # the fragment the build reads them through is regenerated without
        # the file.
        return "The file is deleted; nothing ships in its place."
    if row.kind == source_files.GRAPHICS:
        # A file the project added has no shipped stream behind it.
        if row.added:
            return "The added file is deleted; nothing ships in its place."
        return (
            "The file goes back to the cartridge's own graphics; any tile-editor "
            "work on it is lost."
        )
    # A file the editor writes for itself: what goes with it is not a hand
    # edit but somebody's work in the level, palette, Map16 or world map
    # editor, and the question is the only place that gets said. Which of
    # them it is, the row's Kind column is already saying beside it.
    return (
        "The build reads the disassembly's own copy again; the editor's work "
        "in it is lost."
    )
