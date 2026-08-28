"""The level data as three tabs: the numbers, the labels, and the files.

Level data reaches the ROM in three hops (:mod:`smw_tools.levels`) -- a level
number names a label, the label is defined above a container's stream, the
container is the ``.mwl`` the bytes come out of -- and each tab is one hop,
so a reader can follow a number to its file or a file back to its numbers.
What the rows say is built headlessly in :mod:`shiny_mushroom.level_data` and
:mod:`shiny_mushroom.level_files`; this file only draws them.

A view with gestures it does not perform itself: following a level number
asks the window to open that level, and every edit -- a pointer cell moved to
another file, a file renamed, restamped, added, deleted, reverted or restored
-- is a signal the window answers, because the window owns the project the
tables are written into and the unsaved-work question a reload has to ask
first. Modeless and kept, like the overworld tables: 512 numbers and 245
files are a place to work through, and reopening it where it was left beats
a fresh one per menu click.

What can be edited is what the project can write. A level number's three
entries are cells with a picker in them, since a remap is exactly one label
token moving inside a fixed-size table. A label is defined by the bank that
inserts it, or by the added-files fragment for a file the project adds -- so
labels come and go with files and are read here rather than edited. A file
the project added can be renamed, and any file restamped with the level
number it records; the game's own files keep the names the banks know them by.
"""

from __future__ import annotations

from collections.abc import Callable

from PySide6.QtCore import QModelIndex, Qt, QTimer, Signal
from PySide6.QtWidgets import (
    QAbstractItemView,
    QCheckBox,
    QComboBox,
    QDialog,
    QDialogButtonBox,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QSplitter,
    QStyleOptionViewItem,
    QTableWidget,
    QTableWidgetItem,
    QTabWidget,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level_data import LevelData, LevelLabelRow, LevelNumberRow
from shiny_mushroom.level_files import ContainerUse, LevelFileRow
from shiny_mushroom.ui.level_budgets import LevelBudgetFoot
from shiny_mushroom.ui.tables import (
    CELL_PADDING,
    PaddedCells,
    style_note,
    style_table,
    widen_widget_column,
)
from shiny_mushroom.ui.tips import wrap_tip
from smw_tools.levels import LEVEL_COUNT

TITLE = "Level Data"

#: The tabs, in the order the data is reached: a number names a label, a
#: label reaches a file.
NUMBERS_TAB = "Level &Numbers"
LABELS_TAB = "Level &Labels"
FILES_TAB = "Level &Files"

#: What each list is, said in the tab because the three-hop shape is the one
#: idea a reader has to be handed -- and, on the tabs that cannot add or
#: remove rows, why.
NUMBERS_HINT = (
    "Each row is one of the 512 level numbers. Double-click a Layer 1, "
    "Sprites or Layer 2 cell to point it at another file."
)
LABELS_HINT = (
    "Each row is a label a pointer entry can name: the stream it inserts, the "
    "bank run it lands in, and the numbers naming it. Select rows to delete a "
    "stream -- it becomes the empty level -- or restore one."
)
FILES_HINT = (
    "Each row is one .mwl container, which may serve several level numbers. "
    "Click a file to open it; select rows to delete, revert or restore them."
)

NUMBER_COLUMNS = ("Level", "Layer 1", "Sprites", "Layer 2", "Shares With")
LABEL_COLUMNS = ("Label", "Stream", "File", "Region", "Used By")
FILE_COLUMNS = ("File", "Level No.", "Size", "Extras", "Used By")

#: Kept under its old name: the file listing's link column.
COLUMNS = FILE_COLUMNS
FILE_COLUMN = FILE_COLUMNS.index("File")
LEVEL_COLUMN = NUMBER_COLUMNS.index("Level")
RECORDED_COLUMN = FILE_COLUMNS.index("Level No.")

#: Column tooltips, by header. Only the ones whose meaning is not their name.
_NUMBER_NOTES = {
    "Level": "The level number. Click it to open the level.",
    "Layer 1": (
        "The file the number's Layer 1 entry reaches. Double-click to point "
        "it elsewhere."
    ),
    "Sprites": (
        "The file the number's sprite entry reaches. Double-click to point it "
        "elsewhere."
    ),
    "Layer 2": (
        "What the number's Layer 2 entry names. Double-click to point it elsewhere."
    ),
    "Shares With": (
        "Other level numbers reading one of this number's files; saving "
        "rewrites them too."
    ),
}
_LABEL_NOTES = {
    "Label": "The label as the pointer tables spell it.",
    "Stream": "Which of the file's three streams the label inserts.",
    "Region": "The bank macro the stream is emitted inside.",
    "Used By": "Every level number whose pointer entries name this label.",
}
_FILE_NOTES = {
    "Level No.": (
        "The level number Lunar Magic recorded inside the file. The pointer "
        "tables, not this, decide which levels read it. Double-click to "
        "restamp."
    ),
    "Size": (
        "Every byte the build inserts from this file. Hover a cell for the "
        "streams it is made of."
    ),
    "Extras": (
        "Lunar Magic data the container carries that this build never "
        "inserts. Hover a cell for the size of each region."
    ),
    "File": "Click to open the first level number that reads this file's Layer 1.",
    "Used By": (
        "Level numbers reading this file; saving any of them rewrites it for all."
    ),
}

#: What the Extras tooltip says above the sizes, so the list is not read as a
#: cost: none of it reaches the ROM.
_CARRIED_NOTE = "Carried in the file, inserted by nothing:"

SHOW_DELETED = "Show &deleted files"

#: The cell flags of a value that may be picked or typed over, and of one
#: that is only read.
_READ_ONLY = Qt.ItemFlag.ItemIsSelectable | Qt.ItemFlag.ItemIsEnabled
_EDITABLE = _READ_ONLY | Qt.ItemFlag.ItemIsEditable

#: Where a cell's plain value is kept, beside the text that is drawn for it.
VALUE_ROLE = Qt.ItemDataRole.UserRole


class EditableCells(PaddedCells):
    """Cells whose value is picked from a list, or typed, and handed on.

    The delegate never writes the model. What a committed value *means* is a
    project edit the window makes and the table is then refilled from, so the
    cell shows the old value until the edit has landed, and still shows it
    when the window declines -- an unsaved-work question answered no. The
    commit is handed on after the editor has closed, because the window's
    answer may be a modal question or a refill, neither of which belongs
    inside a delegate's ``setModelData``.

    ``choices(row, column)`` answers ``(text, value)`` pairs for a cell picked
    from a list, or ``None`` for one typed into a line; ``current(row,
    column)`` the index of the pair the cell holds today, or ``-1``.
    """

    committed = Signal(int, int, object)

    def __init__(
        self,
        parent: QWidget,
        choices: Callable[[int, int], list[tuple[str, object]] | None],
        current: Callable[[int, int], int],
    ) -> None:
        super().__init__(parent)
        self._choices = choices
        self._current = current

    def createEditor(  # noqa: N802 - Qt override
        self, parent: QWidget, option: QStyleOptionViewItem, index: QModelIndex
    ) -> QWidget:
        offered = self._choices(index.row(), index.column())
        if offered is None:
            return QLineEdit(parent)
        box = QComboBox(parent)
        for text, value in offered:
            box.addItem(text, value)
        # A pick is a commit: nobody wants to click away from a combo to
        # make it take.
        box.activated.connect(lambda _index, box=box: self._took(box))
        return box

    def _took(self, box: QComboBox) -> None:
        self.commitData.emit(box)
        self.closeEditor.emit(box)

    def setEditorData(  # noqa: N802 - Qt override
        self, editor: QWidget, index: QModelIndex
    ) -> None:
        if isinstance(editor, QComboBox):
            editor.setCurrentIndex(self._current(index.row(), index.column()))
            return
        if isinstance(editor, QLineEdit):
            held = index.data(VALUE_ROLE)
            editor.setText("" if held is None else hexnum(int(held), 3))
            editor.selectAll()

    def setModelData(  # noqa: N802 - Qt override
        self, editor: QWidget, model: object, index: QModelIndex
    ) -> None:
        if isinstance(editor, QComboBox):
            value = editor.currentData()
        elif isinstance(editor, QLineEdit):
            value = _parsed_level(editor.text())
            if value is None or value == index.data(VALUE_ROLE):
                return
        else:
            return
        row, column = index.row(), index.column()
        QTimer.singleShot(0, lambda: self.committed.emit(row, column, value))


def _parsed_level(text: str) -> int | None:
    """A typed level number -- ``105``, ``$105`` or ``0x105`` -- or ``None``
    for anything that is not one."""
    held = text.strip().lower().removeprefix("$").removeprefix("0x")
    try:
        value = int(held, 16)
    except ValueError:
        return None
    return value if 0 <= value < LEVEL_COUNT else None


class LevelDataDialog(QDialog):
    """The three hops as tabs. Emits :attr:`level_activated` on a level
    click, and one request per edit the window is asked to make."""

    #: The level a followed number or file opens at. The dialog does not open
    #: levels -- what a click *means* belongs to the window, which owns the
    #: unsaved-work question a load has to ask first.
    level_activated = Signal(int)

    #: A Layer 1 or sprite cell picked another file: the level, then the
    #: Layer 1 target and the sprite target -- a
    #: :class:`~shiny_mushroom.level_pointers.StreamTarget`, or ``None`` for
    #: the stream left where it is.
    pointers_edited = Signal(int, object, object)

    #: A Layer 2 cell picked another entry: the level, and the
    #: :class:`~shiny_mushroom.layer2_table.Layer2Entry` chosen.
    layer2_edited = Signal(int, object)

    #: The Remap button, asking the window to run the remap flow -- carrying
    #: the level the selected file row opens at (``-1`` with no usable row,
    #: so the flow starts on the level being looked at) and the selected
    #: row's file (``""`` with none), which the pickers open on.
    remap_requested = Signal(int, str)

    #: The Add button, asking the window to run the add flow.
    add_requested = Signal()

    #: The Rename button, carrying the one selected added file's name.
    rename_requested = Signal(str)

    #: A file's recorded level number was typed over: the file, and the
    #: number to stamp it with.
    recorded_level_edited = Signal(str, int)

    #: The Delete, Revert and Restore buttons, each carrying the names of the
    #: selected rows it applies to: any file for Delete, an edited checkout
    #: file for Revert, a deleted one for Restore.
    delete_requested = Signal(list)
    revert_requested = Signal(list)
    restore_requested = Signal(list)

    #: The label tab's Delete and Restore, each carrying the selected labels
    #: it applies to, spelled as the rows show them.
    delete_labels_requested = Signal(list)
    restore_labels_requested = Signal(list)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle(TITLE)
        self.setMinimumSize(820, 480)
        self._data = LevelData(numbers=[], labels=[], files=[])
        #: Every file row the project has, and the ones on show: the same
        #: list with the deleted files left out until asked for.
        self._file_rows: list[LevelFileRow] = []
        self._number_rows: list[LevelNumberRow] = []
        self._label_rows: list[LevelLabelRow] = []

        # The tabs over the foot, in a splitter: the foot is the same under
        # all three -- which run a stream lands in is the hop past the last
        # tab -- and how much of the window it is worth is the reader's.
        self._split = QSplitter(Qt.Orientation.Vertical, self)
        self._split.setChildrenCollapsible(False)
        self._tabs = QTabWidget(self._split)
        self._tabs.addTab(self._build_numbers(), NUMBERS_TAB)
        self._tabs.addTab(self._build_labels(), LABELS_TAB)
        self._tabs.addTab(self._build_files(), FILES_TAB)
        self._split.addWidget(self._tabs)
        self._budgets = LevelBudgetFoot(self._split)
        self._split.addWidget(self._budgets)
        self._split.setStretchFactor(0, 1)
        self._split.setStretchFactor(1, 0)
        #: How many runs the foot was last sized for, and whether the reader
        #: has sized it since. The opening height is what the runs need, and
        #: the runs are not known until the first fill -- nor is their number
        #: fixed, since Growable levels packs eight bank macros into three.
        #: A handle the reader has moved is theirs, and is never moved back.
        self._foot_runs = -1
        self._foot_dragged = False
        self._split.splitterMoved.connect(self._foot_was_dragged)

        layout = QVBoxLayout(self)
        layout.addWidget(self._split, 1)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)
        self._sync_buttons()

    # -- building --------------------------------------------------------------

    def _page(
        self, hint: str, columns: tuple[str, ...], notes: dict[str, str]
    ) -> tuple[QWidget, QLineEdit, QTableWidget]:
        """A tab's skeleton: the hint, a filter box and the table under them.
        Returns the page, the filter box and the table."""
        page = QWidget(self)
        layout = QVBoxLayout(page)
        note = QLabel(hint, page)
        style_note(note)
        layout.addWidget(note)
        search = QLineEdit(page)
        search.setPlaceholderText("Filter rows")
        search.setClearButtonEnabled(True)
        layout.addWidget(search)
        table = QTableWidget(0, len(columns), page)
        table.setHorizontalHeaderLabels(columns)
        for column, name in enumerate(columns):
            held = notes.get(name)
            if held is not None:
                table.horizontalHeaderItem(column).setToolTip(wrap_tip(held))
        # The last column is the list of level numbers, which runs as wide as
        # its longest row: a centred title would sit off-screen in it.
        table.horizontalHeaderItem(len(columns) - 1).setTextAlignment(
            Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignVCenter
        )
        table.verticalHeader().setVisible(False)
        table.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        # The look every table in the editor shares, and the reason these
        # need it most: a selected row is washed rather than repainted, so a
        # link column's link is still a link in it. See
        # :mod:`shiny_mushroom.ui.tables`.
        style_table(table)
        layout.addWidget(table, 1)
        return page, search, table

    def _build_numbers(self) -> QWidget:
        page, self._number_search, self._numbers = self._page(
            NUMBERS_HINT, NUMBER_COLUMNS, _NUMBER_NOTES
        )
        self._numbers.setSelectionMode(QAbstractItemView.SelectionMode.SingleSelection)
        self._numbers.setEditTriggers(
            QAbstractItemView.EditTrigger.DoubleClicked
            | QAbstractItemView.EditTrigger.SelectedClicked
            | QAbstractItemView.EditTrigger.EditKeyPressed
        )
        cells = EditableCells(self._numbers, self._number_choices, self._number_current)
        cells.committed.connect(self._number_edited)
        self._numbers.setItemDelegate(cells)
        self._number_search.textChanged.connect(self._filter_numbers)
        return page

    def _build_labels(self) -> QWidget:
        page, self._label_search, self._labels = self._page(
            LABELS_HINT, LABEL_COLUMNS, _LABEL_NOTES
        )
        self._labels.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self._labels.setSelectionMode(QAbstractItemView.SelectionMode.ExtendedSelection)
        self._labels.setItemDelegate(PaddedCells(self._labels))
        self._label_search.textChanged.connect(self._filter_labels)

        actions = QHBoxLayout()
        self._delete_label = QPushButton("&Delete...", page)
        self._delete_label.setToolTip(
            wrap_tip(
                "Take the selected labels' streams out of the build; each becomes "
                "the empty level."
            )
        )
        self._delete_label.clicked.connect(self._delete_selected_labels)
        actions.addWidget(self._delete_label)
        self._restore_label = QPushButton("Res&tore", page)
        self._restore_label.setToolTip("Put the selected streams back into the build.")
        self._restore_label.clicked.connect(self._restore_selected_labels)
        actions.addWidget(self._restore_label)
        actions.addStretch()
        page.layout().addLayout(actions)
        self._labels.itemSelectionChanged.connect(self._sync_label_buttons)
        return page

    def _build_files(self) -> QWidget:
        page, self._file_search, self._files = self._page(
            FILES_HINT, FILE_COLUMNS, _FILE_NOTES
        )
        layout = page.layout()
        self._files.setEditTriggers(
            QAbstractItemView.EditTrigger.DoubleClicked
            | QAbstractItemView.EditTrigger.EditKeyPressed
        )
        # Sets of rows, because making room is several files at once.
        self._files.setSelectionMode(QAbstractItemView.SelectionMode.ExtendedSelection)
        cells = EditableCells(self._files, lambda _row, _column: None, lambda *_: -1)
        cells.committed.connect(self._file_edited)
        self._files.setItemDelegate(cells)
        self._file_search.textChanged.connect(self._filter_files)

        self._show_deleted = QCheckBox(SHOW_DELETED, page)
        self._show_deleted.setToolTip("Show deleted files, to restore one.")
        self._show_deleted.toggled.connect(self._refill_files)
        layout.addWidget(self._show_deleted)

        actions = QHBoxLayout()
        add = QPushButton("&Add a File...", page)
        add.setToolTip(
            wrap_tip(
                "Bring a new .mwl container into the project. A remap points a "
                "level number at it."
            )
        )
        add.clicked.connect(self.add_requested)
        actions.addWidget(add)
        self._rename = QPushButton("Re&name...", page)
        self._rename.setToolTip(
            wrap_tip(
                "Rename the selected added file; the level numbers reading it follow."
            )
        )
        self._rename.clicked.connect(self._rename_selected)
        actions.addWidget(self._rename)
        self._delete = QPushButton("&Delete...", page)
        self._delete.setToolTip(
            wrap_tip(
                "Take the selected files' level data out of the build. A shipped "
                "file can be restored; an added one is gone."
            )
        )
        self._delete.clicked.connect(self._delete_selected)
        actions.addWidget(self._delete)
        self._revert = QPushButton("Re&vert...", page)
        self._revert.setToolTip(
            wrap_tip(
                "Put the selected files back to what the game ships; saved "
                "edits are lost."
            )
        )
        self._revert.clicked.connect(self._revert_selected)
        actions.addWidget(self._revert)
        self._restore = QPushButton("Res&tore", page)
        self._restore.setToolTip("Put the selected files back into the build.")
        self._restore.clicked.connect(self._restore_selected)
        actions.addWidget(self._restore)
        actions.addStretch()
        remap = QPushButton("&Remap a Level...", page)
        remap.setToolTip(
            wrap_tip(
                "Point a level number at other files -- one for its layout, one "
                "for its sprites."
            )
        )
        remap.clicked.connect(self._remap)
        actions.addWidget(remap)
        layout.addLayout(actions)
        self._files.itemSelectionChanged.connect(self._sync_buttons)
        return page

    # -- filling it ----------------------------------------------------------

    def show_data(self, data: LevelData) -> None:
        """Replace every tab's contents with ``data``."""
        self._data = data
        self._refill_numbers()
        self._refill_labels()
        self._refill_files()
        self._refill_budgets()

    def _refill_budgets(self) -> None:
        """The foot, and how much of the window it opens taking.

        The opening height is what the runs need, and the runs are not known
        until the first fill -- but a handle the reader has moved is theirs,
        and is never moved back.
        """
        runs = self._budgets.show_budgets(self._data.budgets)
        if not self._foot_dragged and runs != self._foot_runs:
            self._split.setSizes(
                [self.height(), self._budgets.wanted_height(self.width())]
            )
        self._foot_runs = runs

    def _foot_was_dragged(self, *_where: int) -> None:
        self._foot_dragged = True

    @property
    def current_tab(self) -> str:
        """The open tab's title, as the ``*_TAB`` constants spell it."""
        return self._tabs.tabText(self._tabs.currentIndex())

    def open_tab(self, title: str) -> None:
        for index in range(self._tabs.count()):
            if self._tabs.tabText(index) == title:
                self._tabs.setCurrentIndex(index)
                return

    def _refill_numbers(self) -> None:
        rows = self._data.numbers
        self._number_rows = rows
        table = self._numbers
        table.setRowCount(len(rows))
        for index, row in enumerate(rows):
            table.setCellWidget(index, LEVEL_COLUMN, self._level_link(row))
            table.setItem(index, 0, _cell(""))
            table.setItem(index, 1, _stream_cell(row.layer1_label, row.layer1_file))
            table.setItem(index, 2, _stream_cell(row.sprites_label, row.sprites_file))
            table.setItem(index, 3, _layer2_cell(row))
            table.setItem(index, 4, _sharing_cell(row))
        table.resizeColumnsToContents()
        widen_widget_column(table, LEVEL_COLUMN)
        table.resizeRowsToContents()
        self._filter_numbers(self._number_search.text())

    def _refill_labels(self) -> None:
        rows = self._data.labels
        self._label_rows = rows
        table = self._labels
        table.setRowCount(len(rows))
        for index, row in enumerate(rows):
            table.setItem(index, 0, _label_cell(row))
            table.setItem(index, 1, _cell(row.kind_name))
            table.setItem(index, 2, _cell(row.container))
            table.setItem(index, 3, _region_cell(row))
            table.setItem(index, 4, _cell(_listed(row.used_by)))
        table.resizeColumnsToContents()
        table.resizeRowsToContents()
        self._filter_labels(self._label_search.text())
        self._sync_label_buttons()

    @property
    def showing_deleted(self) -> bool:
        return self._show_deleted.isChecked()

    def _refill_files(self, *_toggled: bool) -> None:
        keep = self.showing_deleted
        rows = [row for row in self._data.files if keep or not row.deleted]
        self._file_rows = rows
        table = self._files
        table.setRowCount(len(rows))
        for index, row in enumerate(rows):
            table.setCellWidget(index, FILE_COLUMN, self._file_link(row))
            table.setItem(index, 0, _cell(""))
            table.setItem(index, 1, self._recorded(row))
            table.setItem(index, 2, _size_cell(row))
            table.setItem(index, 3, _extras_cell(row))
            table.setItem(index, 4, _users_cell(row))
        table.resizeColumnsToContents()
        widen_widget_column(table, FILE_COLUMN)
        table.resizeRowsToContents()
        self._filter_files(self._file_search.text())
        self._sync_buttons()

    def _recorded(self, row: LevelFileRow) -> QTableWidgetItem:
        cell = _cell(
            "-" if row.recorded_level is None else hexnum(row.recorded_level, 3)
        )
        cell.setData(VALUE_ROLE, row.recorded_level)
        # A record the file carries, so a file that could not be read has
        # nothing to restamp, and a deleted one is not a file being edited.
        editable = row.recorded_level is not None and not row.deleted
        cell.setFlags(_EDITABLE if editable else _READ_ONLY)
        if not row.agrees:
            # A real fact about the cart, surfaced rather than smoothed over:
            # the tool's own record and the pointer tables disagree.
            cell.setToolTip(
                wrap_tip(
                    "Lunar Magic recorded a different level than the tables read "
                    "this file for. Double-click to restamp."
                )
            )
            cell.setText(cell.text() + " *")
        return cell

    def _level_link(self, row: LevelNumberRow) -> QLabel:
        """The level number, linked: the one route to the row's files."""
        text = f'<a href="{row.level:03X}">{hexnum(row.level, 3)}</a>'
        if row.remapped:
            text = f"{text} *"
        label = QLabel(text)
        label.setTextFormat(Qt.TextFormat.RichText)
        label.setTextInteractionFlags(Qt.TextInteractionFlag.LinksAccessibleByMouse)
        label.setContentsMargins(CELL_PADDING, 0, CELL_PADDING, 0)
        notes = []
        if row.remapped:
            notes.append("Remapped: this project's tables point it elsewhere.")
        if not row.placed:
            notes.append(
                "Not placed: an entry names a label nothing defines, so the "
                "number cannot be loaded until it is pointed at a file."
            )
        if notes:
            label.setToolTip(wrap_tip(" ".join(notes)))
        label.linkActivated.connect(self._followed_number)
        return label

    def _file_link(self, row: LevelFileRow) -> QLabel:
        """The container's name, linked when there is a level to open it at.

        The link is the file rather than the level numbers beside it: what a
        row *is* is a container, the numbers are only the routes to it, and
        opening one of forty-five split levels through its sprite number would
        put a different file's objects on the canvas.
        """
        level = _opens_at(row)
        text = row.name if level is None else f'<a href="{level:03X}">{row.name}</a>'
        if row.deleted:
            text = f"<s>{text}</s>"
        elif row.edited:
            text = f"{text} *"
        label = QLabel(text)
        label.setTextFormat(Qt.TextFormat.RichText)
        label.setTextInteractionFlags(Qt.TextInteractionFlag.LinksAccessibleByMouse)
        label.setContentsMargins(CELL_PADDING, 0, CELL_PADDING, 0)
        notes = []
        if row.added:
            notes.append("Added by this project; the checkout does not ship it.")
        if row.deleted:
            notes.append(
                "Deleted by this project: every level reading it loads empty, "
                "and its room goes to the other levels. Restore puts it back."
            )
        elif row.partly_deleted:
            gone = ", ".join(row.deleted_labels)
            notes.append(
                f"{len(row.deleted_labels)} of {len(row.labels)} streams deleted "
                f"({gone}): each loads empty, and its room goes to the other "
                f"levels. Restore puts them all back."
            )
        if row.edited:
            notes.append("Edited: the project holds a saved copy of this file.")
        if level is None:
            # A container the pointer tables never name: the cartridge reaches
            # it by handing the loader its address, so there is no level number
            # to open it at. A fact about this file, not a broken row.
            notes.append("No level number reads this file.")
        if notes:
            label.setToolTip(wrap_tip(" ".join(notes)))
        label.linkActivated.connect(self._followed_file)
        return label

    def _followed_number(self, target: str) -> None:
        _select_row_of(self._numbers, LEVEL_COLUMN, self.sender())
        self.level_activated.emit(int(target, 16))

    def _followed_file(self, target: str) -> None:
        _select_row_of(self._files, FILE_COLUMN, self.sender())
        self.level_activated.emit(int(target, 16))

    # -- filtering -------------------------------------------------------------

    def _filter_numbers(self, needle: str) -> None:
        _hide_unmatched(self._numbers, self._number_rows, needle, _number_text)

    def _filter_labels(self, needle: str) -> None:
        _hide_unmatched(self._labels, self._label_rows, needle, _label_text)

    def _filter_files(self, needle: str) -> None:
        _hide_unmatched(self._files, self._file_rows, needle, _file_text)

    # -- the number cells ----------------------------------------------------

    def _number_choices(self, row: int, column: int) -> list[tuple[str, object]]:
        """What a number's cell may be picked from: the files a stream can
        be pointed at, by name, or every Layer 2 entry."""
        if column == NUMBER_COLUMNS.index("Layer 1"):
            return [(one.container, one) for one in self._data.layer1_targets]
        if column == NUMBER_COLUMNS.index("Sprites"):
            return [(one.container, one) for one in self._data.sprite_targets]
        if column == NUMBER_COLUMNS.index("Layer 2"):
            return [(one.describe(), one) for one in self._data.layer2_choices]
        return []

    def _number_current(self, row: int, column: int) -> int:
        """Where the picker opens: the row's own file -- its label's entry
        where one is offered, any entry on the same file otherwise."""
        if not 0 <= row < len(self._number_rows):
            return -1
        held = self._number_rows[row]
        if column == NUMBER_COLUMNS.index("Layer 2"):
            return next(
                (
                    index
                    for index, one in enumerate(self._data.layer2_choices)
                    if one == held.layer2
                ),
                -1,
            )
        if column == NUMBER_COLUMNS.index("Layer 1"):
            offered, label, file = (
                self._data.layer1_targets,
                held.layer1_label,
                held.layer1_file,
            )
        elif column == NUMBER_COLUMNS.index("Sprites"):
            offered, label, file = (
                self._data.sprite_targets,
                held.sprites_label,
                held.sprites_file,
            )
        else:
            return -1
        by_label = next(
            (index for index, one in enumerate(offered) if one.label == label), -1
        )
        if by_label >= 0:
            return by_label
        return next(
            (index for index, one in enumerate(offered) if one.container == file), -1
        )

    def _number_edited(self, row: int, column: int, value: object) -> None:
        """A cell was picked: hand the window the move, unless the pick is
        the file the stream already reads -- the same container under any
        label is not an edit."""
        if not 0 <= row < len(self._number_rows) or value is None:
            return
        held = self._number_rows[row]
        if column == NUMBER_COLUMNS.index("Layer 2"):
            if value != held.layer2:
                self.layer2_edited.emit(held.level, value)
            return
        if column == NUMBER_COLUMNS.index("Layer 1"):
            if value.container != held.layer1_file:
                self.pointers_edited.emit(held.level, value, None)
        elif column == NUMBER_COLUMNS.index("Sprites"):
            if value.container != held.sprites_file:
                self.pointers_edited.emit(held.level, None, value)

    def _file_edited(self, row: int, column: int, value: object) -> None:
        if column == RECORDED_COLUMN and 0 <= row < len(self._file_rows):
            self.recorded_level_edited.emit(self._file_rows[row].name, int(value))

    # -- the file gestures -----------------------------------------------------

    def selected_rows(self) -> list[LevelFileRow]:
        """The file rows selected, in table order."""
        chosen = sorted({index.row() for index in self._files.selectedIndexes()})
        rows = self._file_rows
        return [rows[row] for row in chosen if 0 <= row < len(rows)]

    def _remap(self) -> None:
        """Ask for the remap flow, starting from the selected file row: its
        level where one reads it, and its file either way."""
        rows = self.selected_rows()
        row = self._files.currentRow()
        chosen = rows[0] if rows else None
        if chosen is None and 0 <= row < len(self._file_rows):
            chosen = self._file_rows[row]
        if chosen is None:
            self.remap_requested.emit(-1, "")
            return
        level = _opens_at(chosen)
        self.remap_requested.emit(-1 if level is None else level, chosen.name)

    def _rename_selected(self) -> None:
        rows = [row for row in self.selected_rows() if row.added]
        if len(rows) == 1:
            self.rename_requested.emit(rows[0].name)

    def _delete_selected(self) -> None:
        names = [row.name for row in self.selected_rows() if not row.deleted]
        if names:
            self.delete_requested.emit(names)

    def _revert_selected(self) -> None:
        names = [row.name for row in self.selected_rows() if row.edited]
        if names:
            self.revert_requested.emit(names)

    def _restore_selected(self) -> None:
        names = [row.name for row in self.selected_rows() if row.deleted_labels]
        if names:
            self.restore_requested.emit(names)

    def _sync_buttons(self) -> None:
        """Each button arms on the selected rows it has something to do to."""
        rows = self.selected_rows()
        self._rename.setEnabled(len(rows) == 1 and rows[0].added)
        self._delete.setEnabled(any(not row.deleted for row in rows))
        self._revert.setEnabled(any(row.edited for row in rows))
        # A partly deleted file restores too: every deleted label of it.
        self._restore.setEnabled(any(row.deleted_labels for row in rows))

    # -- the label gestures ----------------------------------------------------

    def selected_label_rows(self) -> list[LevelLabelRow]:
        """The label rows selected, in table order."""
        chosen = sorted({index.row() for index in self._labels.selectedIndexes()})
        rows = self._label_rows
        return [rows[row] for row in chosen if 0 <= row < len(rows)]

    def _delete_selected_labels(self) -> None:
        labels = [
            row.label
            for row in self.selected_label_rows()
            if not row.deleted and not row.added
        ]
        if labels:
            self.delete_labels_requested.emit(labels)

    def _restore_selected_labels(self) -> None:
        labels = [row.label for row in self.selected_label_rows() if row.deleted]
        if labels:
            self.restore_labels_requested.emit(labels)

    def _sync_label_buttons(self) -> None:
        """Delete arms on a bank's label not yet deleted -- an added file's
        two go with the file -- and Restore on a deleted one."""
        rows = self.selected_label_rows()
        self._delete_label.setEnabled(
            any(not row.deleted and not row.added for row in rows)
        )
        self._restore_label.setEnabled(any(row.deleted for row in rows))


def _select_row_of(table: QTableWidget, column: int, label: object) -> None:
    """Show the followed row as selected.

    Clicking a link puts focus in a cell widget and leaves the table's own
    selection wherever it was, so without this the row that was just opened
    is the one row not marked.
    """
    for row in range(table.rowCount()):
        if table.cellWidget(row, column) is not label:
            continue
        table.setCurrentCell(row, column)
        table.setFocus()
        return


def _hide_unmatched(
    table: QTableWidget, rows: list, needle: str, text_of: Callable[[object], str]
) -> None:
    """Hide every row whose words do not contain ``needle``, case blind.
    Hiding rather than refilling keeps the row indexes the edits are
    reported by stable."""
    wanted = needle.strip().lower()
    for index, row in enumerate(rows):
        table.setRowHidden(index, bool(wanted) and wanted not in text_of(row).lower())


def _number_text(row: LevelNumberRow) -> str:
    parts = [hexnum(row.level, 3), row.layer1_label, row.sprites_label]
    parts += [name for name in (row.layer1_file, row.sprites_file) if name]
    if row.layer2 is not None:
        parts += [row.layer2.label, row.layer2.describe()]
    return " ".join(parts)


def _label_text(row: LevelLabelRow) -> str:
    return " ".join(
        (row.label, row.kind_name, row.container, row.region, _listed(row.used_by))
    )


def _file_text(row: LevelFileRow) -> str:
    parts = [row.name, *(hexnum(use.level, 3) for use in row.used_by)]
    if row.recorded_level is not None:
        parts.append(hexnum(row.recorded_level, 3))
    return " ".join(parts)


def _cell(text: str) -> QTableWidgetItem:
    cell = QTableWidgetItem(text)
    cell.setFlags(_READ_ONLY)
    return cell


def _listed(levels: tuple[int, ...]) -> str:
    return ", ".join(hexnum(level, 3) for level in levels) or "-"


def _stream_cell(label: str, container: str | None) -> QTableWidgetItem:
    """A number's Layer 1 or sprite entry, as the file it reaches -- the
    name a person works in -- with the label it does it through in the
    tooltip. An entry naming a label nothing defines shows the label."""
    cell = _cell(container if container is not None else label)
    cell.setFlags(_EDITABLE)
    cell.setToolTip(label if container is not None else f"{label} - defined by nothing")
    return cell


def _layer2_cell(row: LevelNumberRow) -> QTableWidgetItem:
    entry = row.layer2
    if entry is None:
        cell = _cell("-")
        cell.setToolTip("The Layer 2 table has no entry for this number.")
        return cell
    cell = _cell(entry.describe())
    cell.setFlags(_EDITABLE)
    if entry.background:
        cell.setToolTip(f"{entry.label} - a background tilemap, not a file.")
    elif row.layer2_file is not None:
        cell.setToolTip(f"{entry.label} - level data out of {row.layer2_file}.mwl.")
    else:
        cell.setToolTip(f"{entry.label} - defined by nothing.")
    return cell


def _sharing_cell(row: LevelNumberRow) -> QTableWidgetItem:
    cell = _cell(_listed(row.shares_with))
    if row.split:
        cell.setToolTip(
            wrap_tip(
                f"Layer 1 out of {row.layer1_file}.mwl, sprites out of "
                f"{row.sprites_file}.mwl: a level made of two files."
            )
        )
    return cell


def _label_cell(row: LevelLabelRow) -> QTableWidgetItem:
    cell = _cell(row.label)
    notes = []
    if row.added:
        notes.append(
            "Defined by the added-files fragment this project generates; it "
            "goes with its file."
        )
    if row.deleted:
        notes.append(
            "Deleted: the label inserts the empty level. Restore puts it back."
        )
        cell.setText(f"{row.label} (deleted)")
    if notes:
        cell.setToolTip(wrap_tip(" ".join(notes)))
    return cell


def _region_cell(row: LevelLabelRow) -> QTableWidgetItem:
    if row.region:
        return _cell(row.region)
    cell = _cell("(added files)" if row.added else "-")
    cell.setToolTip(
        wrap_tip(
            "Packed after the game's own streams by the managed level banks."
            if row.added
            else "No bank macro the ROM map places emits this stream."
        )
    )
    return cell


def _extras_cell(row: LevelFileRow) -> QTableWidgetItem:
    """What the container carries beyond the streams the build reads.

    Only the differing part is written in the cell -- every file has a palette
    region, and a column repeating that 245 times is a column saying nothing.
    The tooltip is the whole of it, sizes included, so the quiet cell is a
    reading of the file rather than a gap in one.
    """
    cell = _cell(", ".join(row.extras) or "-")
    if row.carries:
        sizes = "\n".join(f"{part.name}: {part.size:,} bytes" for part in row.carries)
        cell.setToolTip(f"{_CARRIED_NOTE}\n{sizes}")
    return cell


def _size_cell(row: LevelFileRow) -> QTableWidgetItem:
    """What the file costs in ROM, right-aligned so sizes compare down the
    column, with the streams it is made of in the tooltip -- ``-`` for a
    stream the build never inserts, which is most Layer 2 cells."""
    cell = _cell(f"{row.rom_size:,}")
    cell.setTextAlignment(Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter)
    parts = (
        ("Layer 1", row.layer1_size),
        ("Sprites", row.sprite_size),
        ("Layer 2", row.layer2_size),
    )
    lines = [
        f"{name}: {'-' if size is None else f'{size:,} bytes'}" for name, size in parts
    ]
    if row.deleted:
        lines.append("Deleted: the build inserts the empty level instead.")
    elif row.partly_deleted:
        lines.append(
            "Deleted: " + ", ".join(row.deleted_labels) + " -- inserted as the "
            "empty level."
        )
    cell.setToolTip("\n".join(lines))
    return cell


def _users_cell(row: LevelFileRow) -> QTableWidgetItem:
    """Every level number that reads the container, read rather than clicked:
    the row opens through its file, which is the one of them that always means
    this container's own objects."""
    return _cell(", ".join(_user(use) for use in row.used_by) or "-")


def _user(use: ContainerUse) -> str:
    """One level number.

    The suffix marks the forty-five split levels: a number reading only this
    file's sprites is a different claim from reading the level out of it, and
    a row that did not say which would overstate the sharing.
    """
    text = hexnum(use.level, 3)
    if use.partial:
        text += " (layer 1)" if use.layer1 else " (sprites)"
    return text


def _opens_at(row: LevelFileRow) -> int | None:
    """The level a click on the file opens, or ``None`` for a container no
    level number reaches at all.

    Its Layer 1 readers first: they are the numbers that show the container's
    own header and objects. A file read only for its sprites still opens --
    at the level that reads them -- because a row that could not be followed
    at all would be worse than one that opens beside its sprites.

    ``None`` is the thirty-odd containers the pointer tables never name: the
    enemy roll-call screens, the no-Yoshi cutscenes, Chocolate Island 2's
    sub-levels and the unused levels, all of which the cartridge reaches by
    handing the loader their address directly.
    """
    for wanted in (True, False):
        for use in row.used_by:
            if use.layer1 is wanted:
                return use.level
    return None
