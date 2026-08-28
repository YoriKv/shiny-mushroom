"""The project's asm patches, as a dialog: toggle, order, add, import, remove.

Every action writes through to the project as it is made -- the manifest and
the files under ``patches/`` are the state, and the dialog is only a view of
them -- so there is no OK/Cancel pair and closing is the only way out. What
the window needs to know afterwards is :attr:`PatchesDialog.applied_changed`:
whether anything that reaches the *built cartridge* moved, which is what makes
closing the dialog a rebuild. Adding a patch disabled, or reordering two that
are off, changes nothing a build would notice and is deliberately not counted.
"""

from __future__ import annotations

from pathlib import Path

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QDialog,
    QDialogButtonBox,
    QFileDialog,
    QHBoxLayout,
    QInputDialog,
    QLabel,
    QListWidget,
    QListWidgetItem,
    QMessageBox,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import patches
from shiny_mushroom.build import symbol_file
from shiny_mushroom.project import Project
from shiny_mushroom.ui.dialogs import open_folder
from smw_tools.features import FeatureError, feature
from smw_tools.rom_sizes import STOCK
from smw_tools.symbols import SymbolTable, load_symbols

#: What a new patch opens as: enough to say where the labels come from and
#: where the room is, and nothing that assembles until the person writes some.
TEMPLATE = """\
; An asar patch, assembled at the end of the project's main pass. Every
; label of the game is in scope, so name what you change:
;
;     org SMW_LevelNames_Main
;         dw $0148
;
; `uv run smw symbol $05D796` (or a label) says what lives where.
; freecode/freedata need a ROM Size above stock.
; Patches apply top to bottom; later writes win.
"""

#: The item data slot holding the patch's id.
_ID_ROLE = Qt.ItemDataRole.UserRole


class PatchesDialog(QDialog):
    """One project's patches. Construct, ``exec``, then read
    :attr:`applied_changed`."""

    def __init__(self, project: Project, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._project = project
        #: Whether what the build applies moved: a toggle, an enabled patch
        #: removed, or the enabled patches' order changed.
        self.applied_changed = False
        self.setWindowTitle("Patches")
        self.setMinimumSize(460, 320)

        layout = QVBoxLayout(self)
        hint = QLabel(
            "Checked patches are assembled in, top to bottom, at the next build."
        )
        hint.setWordWrap(True)
        layout.addWidget(hint)

        self._list = QListWidget()
        self._list.itemChanged.connect(self._toggled)
        self._list.currentRowChanged.connect(lambda _row: self._sync_buttons())
        layout.addWidget(self._list)

        row = QHBoxLayout()
        new = QPushButton("&New...")
        new.clicked.connect(self._new)
        row.addWidget(new)
        importer = QPushButton("&Import...")
        importer.clicked.connect(self._import)
        row.addWidget(importer)
        row.addStretch()
        self._up = QPushButton("&Up")
        self._up.clicked.connect(lambda: self._move(-1))
        row.addWidget(self._up)
        self._down = QPushButton("&Down")
        self._down.clicked.connect(lambda: self._move(+1))
        row.addWidget(self._down)
        self._remove = QPushButton("&Remove")
        self._remove.clicked.connect(self._delete)
        row.addWidget(self._remove)
        layout.addLayout(row)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        folder = buttons.addButton(
            "Open &Folder", QDialogButtonBox.ButtonRole.ActionRole
        )
        folder.clicked.connect(self._open_folder)
        layout.addWidget(buttons)

        self._refill()

    # -- the list ------------------------------------------------------------

    def _refill(self) -> None:
        chosen = self._current_id()
        self._list.blockSignals(True)
        self._list.clear()
        _, enabled = self._project.patch_state
        for patch in patches.user_patches(self._project):
            item = QListWidgetItem(patch.name)
            item.setData(_ID_ROLE, patch.id)
            item.setFlags(item.flags() | Qt.ItemFlag.ItemIsUserCheckable)
            item.setCheckState(
                Qt.CheckState.Checked
                if patch.id in enabled
                else Qt.CheckState.Unchecked
            )
            item.setToolTip(self._describe(patch))
            self._list.addItem(item)
            if patch.id == chosen:
                self._list.setCurrentItem(item)
        self._list.blockSignals(False)
        self._sync_buttons()

    def _describe(self, patch: patches.UserPatch) -> str:
        lines = [patch.id if patch.name == patch.id else f"{patch.name} ({patch.id})"]
        if patch.description:
            lines.append(patch.description)
        if patches.uses_freespace(patch.source):
            lines.append(
                "Claims freespace"
                + (
                    " - needs a ROM Size above stock"
                    if self._project.rom_size_id == STOCK
                    else ""
                )
            )
        # What the patch says it changed about the cartridge, named the way the
        # declaration names it -- a claim is a statement that the editor should
        # read the ROM differently, and it belongs where the person turns the
        # patch on. An id this build has no declaration for is shown as it was
        # written: the refusal that matters happens where the cartridge is read.
        for feature_id in patch.provides:
            try:
                lines.append(f"Adds: {feature(feature_id).name}")
            except FeatureError:
                lines.append(f"Claims the unknown feature {feature_id}")
        return "\n".join(lines)

    def _current_id(self) -> str | None:
        item = self._list.currentItem()
        return item.data(_ID_ROLE) if item is not None else None

    def _ids(self) -> list[str]:
        return [
            self._list.item(row).data(_ID_ROLE) for row in range(self._list.count())
        ]

    def _enabled_ids(self) -> list[str]:
        return [patch.id for patch in patches.enabled_patches(self._project)]

    def _sync_buttons(self) -> None:
        row = self._list.currentRow()
        self._up.setEnabled(row > 0)
        self._down.setEnabled(0 <= row < self._list.count() - 1)
        self._remove.setEnabled(row >= 0)

    # -- what the buttons do ---------------------------------------------------

    def _toggled(self, item: QListWidgetItem) -> None:
        patches.set_enabled(
            self._project,
            item.data(_ID_ROLE),
            item.checkState() == Qt.CheckState.Checked,
        )
        self.applied_changed = True
        # The freespace note may have just started mattering.
        self._refill()

    def _move(self, delta: int) -> None:
        row = self._list.currentRow()
        landing = row + delta
        if row < 0 or not 0 <= landing < self._list.count():
            return
        order = self._ids()
        order[row], order[landing] = order[landing], order[row]
        before = self._enabled_ids()
        patches.reorder_patches(self._project, order)
        if self._enabled_ids() != before:
            self.applied_changed = True
        self._refill()
        self._list.setCurrentRow(landing)

    def _delete(self) -> None:
        item = self._list.currentItem()
        if item is None:
            return
        patch_id = item.data(_ID_ROLE)
        asked = QMessageBox.question(
            self,
            "Remove patch",
            f"Delete {patch_id}.asm from the project's patches?",
        )
        if asked != QMessageBox.StandardButton.Yes:
            return
        was_on = item.checkState() == Qt.CheckState.Checked
        patches.remove_patch(self._project, patch_id)
        if was_on:
            self.applied_changed = True
        self._refill()

    def _new(self) -> None:
        name, accepted = QInputDialog.getText(self, "New patch", "Name:")
        if not accepted or not name.strip():
            return
        try:
            added = patches.add_patch(self._project, name.strip(), TEMPLATE)
        except patches.PatchError as error:
            QMessageBox.warning(self, "New patch", str(error))
            return
        self._refill()
        self._select(added.id)

    def _import(self) -> None:
        """Bring outside patches in, converted to this build's own labels.

        Both dialects convert -- see
        :func:`shiny_mushroom.patches.convert_import` -- and what the
        conversion did is kept, as comment lines at the top of the stored
        source as well as in the summary shown here: the notes matter most
        the day the patch misbehaves, which is long after any dialog closed.
        """
        chosen, _filter = QFileDialog.getOpenFileNames(
            self, "Import patches", "", "asar patches (*.asm);;All files (*)"
        )
        if not chosen:
            return
        symbols = self._symbols()
        report: list[str] = []
        last: str | None = None
        for path in map(Path, chosen):
            try:
                imported = patches.convert_import(path.read_text("utf-8"), symbols)
                noted = "".join(f"; import: {note}\n" for note in imported.notes)
                last = patches.add_patch(
                    self._project,
                    path.stem,
                    f"; Imported from {path.name}.\n{noted}\n{imported.source}",
                    description=f"Imported from {path.name}",
                ).id
                report += [path.name, *(f"  {note}" for note in imported.notes)]
            except (OSError, UnicodeDecodeError, patches.PatchError) as error:
                report.append(f"{path.name}: {error}")
        if report:
            QMessageBox.information(self, "Import patches", "\n".join(report))
        self._refill()
        if last is not None:
            self._select(last)

    def _symbols(self) -> SymbolTable | None:
        """The project build's own symbols, or ``None`` before a first build."""
        path = symbol_file(self._project)
        if not path.is_file():
            return None
        try:
            return load_symbols(path)
        except OSError:
            return None

    def _select(self, patch_id: str) -> None:
        for row in range(self._list.count()):
            if self._list.item(row).data(_ID_ROLE) == patch_id:
                self._list.setCurrentRow(row)
                return

    def _open_folder(self) -> None:
        open_folder(self._project.patches_dir)
