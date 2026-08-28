"""The project's hand-edited source files, as a dialog: add, open, remove.

The overlay is the state and this is a view of it -- materializing a file
copies it, removing one deletes it -- so there is no OK/Cancel pair and
closing is the only way out, exactly as
:mod:`shiny_mushroom.ui.patches_dialog` works.
What the window needs afterwards is :attr:`SourceFilesDialog.overlay_changed`:
whether the set of files the build reads moved, which is what makes closing the
dialog a rebuild.

**Editing happens elsewhere.** The file is handed to whatever the desktop opens
``.asm`` with; an asm author already has an editor, and one grown here would be
a worse one. So the dialog's job is to say which files are in play, which of
them the editor owns, and what is wrong with any of them -- see
:mod:`shiny_mushroom.source_files`, which answers all three and knows nothing
about Qt.

**Nothing watches the overlay**, so the dialog re-reads it whenever it is given
the focus back: coming back from the editor a file was handed to is exactly
when a hand edit has just happened, and the list would otherwise go on showing
what was there before somebody left. A stat apiece decides whether there is
anything to re-read at all, which is what makes that affordable on every
activation -- see :meth:`SourceFilesDialog._recheck`.
"""

from __future__ import annotations

from pathlib import Path

from PySide6.QtCore import QEvent, Qt
from PySide6.QtWidgets import (
    QAbstractItemView,
    QDialog,
    QDialogButtonBox,
    QFileDialog,
    QHBoxLayout,
    QLabel,
    QMessageBox,
    QPushButton,
    QTableWidget,
    QTableWidgetItem,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import source_files
from shiny_mushroom.project import Project, ProjectError
from shiny_mushroom.ui.dialogs import open_file, open_folder
from shiny_mushroom.ui.tables import PaddedCells, style_note, style_table
from shiny_mushroom.ui.tips import wrap_tip

TITLE = "Source Files"

#: What the list is, and the one idea a reader has to be handed: these files
#: stand in for the disassembly's, and removing one puts the original back.
HINT = (
    "Each row is a file of the project's own, used instead of the "
    "disassembly's at build time."
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


class SourceFilesDialog(QDialog):
    """One project's overlay. Construct, ``exec``, then read
    :attr:`overlay_changed`."""

    def __init__(self, project: Project, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._project = project
        #: Whether the files the build reads moved -- a file materialized,
        #: removed, or put in or taken away from outside while somebody was in
        #: another window (:meth:`_recheck`). Editing one *in place* is not
        #: counted, though the dialog does notice it: the same file is in the
        #: build either way, and its fingerprint is what decides.
        self.overlay_changed = False
        self._rows: list[source_files.SourceFileRow] = []
        #: What the overlay's files looked like when the list was last read --
        #: see :meth:`_recheck`, which is what an outside edit is noticed
        #: against, there being nothing watching them.
        self._stamps: dict[Path, tuple[int, int]] = {}
        self.setWindowTitle(TITLE)
        self.setMinimumSize(720, 420)

        layout = QVBoxLayout(self)
        hint = QLabel(HINT)
        style_note(hint)
        layout.addWidget(hint)

        self._table = QTableWidget(0, len(COLUMNS))
        self._table.setHorizontalHeaderLabels(COLUMNS)
        for column, name in enumerate(COLUMNS):
            note = _COLUMN_NOTES.get(name)
            if note is not None:
                self._table.horizontalHeaderItem(column).setToolTip(wrap_tip(note))
        self._table.verticalHeader().setVisible(False)
        self._table.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self._table.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self._table.setSelectionMode(QAbstractItemView.SelectionMode.SingleSelection)
        style_table(self._table)
        self._table.setItemDelegate(PaddedCells(self._table))
        self._table.currentCellChanged.connect(lambda *_a: self._sync_buttons())
        self._table.itemDoubleClicked.connect(lambda _item: self._open())
        layout.addWidget(self._table)

        self._moved = QLabel()
        style_note(self._moved)
        self._moved.setVisible(False)
        layout.addWidget(self._moved)

        row = QHBoxLayout()
        add = QPushButton("&Add a File...")
        add.clicked.connect(self._add)
        row.addWidget(add)
        row.addStretch()
        self._open_button = QPushButton("&Open")
        self._open_button.clicked.connect(self._open)
        row.addWidget(self._open_button)
        self._remove = QPushButton("&Remove File...")
        self._remove.clicked.connect(self._delete)
        row.addWidget(self._remove)
        layout.addLayout(row)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        folder = buttons.addButton(
            "Open &Folder", QDialogButtonBox.ButtonRole.ActionRole
        )
        folder.clicked.connect(lambda: open_folder(self._project.overlay))
        layout.addWidget(buttons)

        self._refill()

    # -- the list ------------------------------------------------------------

    def _refill(self, stamps: dict[Path, tuple[int, int]] | None = None) -> None:
        """Read the overlay again, keeping the row somebody was on.

        Stamped *before* the rows are read rather than after, and given the
        sweep :meth:`_recheck` already took where there is one: a file that
        moves between the stat and the read is then reported at the next
        activation, rather than absorbed as though the list had always been
        showing it.
        """
        chosen = self._current_path()
        self._stamps = (
            source_files.overlay_stamps(self._project) if stamps is None else stamps
        )
        self._rows = source_files.rows(self._project)
        self._moved.setVisible(False)
        self._table.setRowCount(len(self._rows))
        for index, row in enumerate(self._rows):
            self._fill_row(index, row)
            if row.relative == chosen:
                self._table.setCurrentCell(index, 0)
        self._table.resizeColumnsToContents()
        self._table.setColumnWidth(0, self._table.columnWidth(0) * FILE_COLUMN_ROOM)
        self._sync_buttons()

    def _fill_row(self, index: int, row: source_files.SourceFileRow) -> None:
        for column, text in enumerate((str(row.relative), row.name, row.note or "-")):
            item = QTableWidgetItem(text)
            item.setData(_PATH_ROLE, row.relative)
            if row.problem:
                item.setToolTip(row.note)
            self._table.setItem(index, column, item)

    def _current_path(self) -> Path | None:
        item = self._table.item(self._table.currentRow(), 0)
        return None if item is None else item.data(_PATH_ROLE)

    def _current(self) -> source_files.SourceFileRow | None:
        index = self._table.currentRow()
        return self._rows[index] if 0 <= index < len(self._rows) else None

    def _sync_buttons(self) -> None:
        row = self._current()
        self._open_button.setEnabled(row is not None and row.editable)
        # Every row, including the ones the editor writes for itself and the
        # stray that is editable by nobody: this is the list of what the
        # project holds, and being able to take a file out of it is the whole
        # of what removing means. What that costs is said in the question.
        self._remove.setEnabled(row is not None)

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
            str(self._project.base),
            "asar sources (*.asm);;All files (*)",
        )
        if not chosen:
            return
        try:
            materialized = self._project.materialize_source(Path(chosen))
        except ProjectError as error:
            QMessageBox.warning(self, TITLE, str(error))
            return
        self.overlay_changed = True
        self._refill()
        self._select(materialized.relative_to(self._project.overlay))
        open_file(materialized)

    def _open(self) -> None:
        row = self._current()
        if row is None or not row.editable:
            return
        if not open_file(self._project.overlay / row.relative):
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
            self._project.revert_source(row.relative)
        except OSError as error:
            QMessageBox.warning(self, TITLE, str(error))
            return
        # A stray was never in the build, so removing one changes nothing it
        # would read -- and a rebuild that assembles the same bytes is not
        # worth making somebody wait for.
        if not row.stray:
            self.overlay_changed = True
        self._refill()

    # -- what moved while somebody was in another window ---------------------

    def changeEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        """Read the overlay again when the dialog is given the focus back.

        This application's own picker and message box hand the focus back too
        and are not a hand edit, but :meth:`_recheck` is a stat sweep and says
        nothing when nothing moved, so telling those from a return out of the
        editor would buy nothing.
        """
        super().changeEvent(event)
        if event.type() == QEvent.Type.ActivationChange and self.isActiveWindow():
            self._recheck()

    def _recheck(self) -> None:
        """Re-read the overlay if a file in it has moved, and say which.

        The sweep is what makes this cheap enough to run on every activation:
        an overlay nothing touched costs a stat apiece and stops there, and
        only a list that has actually moved is read and parsed again.
        """
        found = source_files.overlay_stamps(self._project)
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
        """Name the files whose contents moved, under the list.

        Only those: a file that appeared or went away moved the list itself,
        which is on show and needs no sentence written about it.
        """
        self._moved.setText(
            f"{'; '.join(moved)} changed on disk. The rows show what is there now."
            if moved
            else ""
        )
        self._moved.setVisible(bool(moved))

    def _select(self, relative: Path) -> None:
        for index, row in enumerate(self._rows):
            if row.relative == relative:
                self._table.setCurrentCell(index, 0)
                return


def _consequence(row: source_files.SourceFileRow) -> str:
    """What removing one file costs, for the question that asks about it."""
    if row.stray:
        return "It stands in for nothing, so the build already ignores it."
    if row.kind in (source_files.SOURCE, source_files.REGION):
        return (
            "The build reads the disassembly's own copy again; any hand edits are lost."
        )
    if row.kind == source_files.GRAPHICS:
        # A file the project added has no shipped stream behind it.
        if row.added:
            return "The added file is deleted; nothing ships in its place."
        return (
            "The file goes back to the cartridge's own graphics; any tile-editor "
            "work on it is lost."
        )
    # A file the editor writes for itself: what goes with it is not a hand
    # edit but somebody's work in the level, palette or world map editor, and
    # the question is the only place that gets said. Which of them it is, the
    # row's Kind column is already saying beside it.
    return (
        "The build reads the disassembly's own copy again; the editor's work "
        "in it is lost."
    )
