"""A reusable editor over one fixed ROM table: rows of records, columns of
fields.

The game's overworld tables are rows of typed values -- 27 warp entries, 14
path exits, and the event stamp rows, of which a map holds hundreds -- and
this is the one widget that shows any of them: a grid whose columns are
:class:`~shiny_mushroom.fields.Field` descriptors and whose rows are records
over the document, exactly the contract the properties panel already speaks.
Declaring a new table is a records builder and a fields function; the dialog
contributes no knowledge of any table.

**It owns no document.** A committed cell emits ``edited(row, key, value)``
-- and, for a table built ``reorderable``, a row handle dragged to a new
place emits ``reordered(row, to)`` -- and changes nothing itself: whoever
owns the document applies the field,
commits to the history, and calls :meth:`refresh` with rebuilt records. That
is what lets an undo, a destination pick or a second window move the table
under this one and have it follow: the dialog is a *view* of the document,
refreshed like the panel, never a second copy of it.

**Only the rows on screen are built.** The records live in a model and the
cells are painted from it; a live editor is opened over each cell of the
visible span and closed again as it scrolls away, so the widget count follows
the viewport rather than the table. It has to: the event rows are hundreds of
records of four columns, one of them a picker of 320 blocks, and a widget per
cell of that is a second of work every time the rows change. What the user
sees is unchanged -- every cell on screen is a live control, as it has always
been.

**And scrolled a row at a time**, unlike every other table in the editor. A
scroll bar step here moves and repaints the control in every visible cell and
re-runs the recycler above; per pixel that is 23 passes a row and seventy a
wheel notch, where what is being scrolled is records and a record is a row.

Modeless, deliberately: an edit lands on the map's connectors and the
properties panel while the dialog is up, and a modal grid over a table would
hide exactly the feedback the edit is for. Escape closes it, as it closes any
dialog.
"""

from __future__ import annotations

from collections.abc import Callable, Sequence

from PySide6.QtCore import QAbstractTableModel, QEvent, QModelIndex, Qt, Signal
from PySide6.QtGui import QBrush, QFontMetrics, QPalette
from PySide6.QtWidgets import (
    QAbstractItemView,
    QApplication,
    QCheckBox,
    QDialog,
    QFrame,
    QHBoxLayout,
    QHeaderView,
    QLabel,
    QLineEdit,
    QPushButton,
    QTableView,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.fields import Field
from shiny_mushroom.ui.properties import (
    control_changed,
    field_widget,
    fill_field_widget,
)
from shiny_mushroom.ui.tables import (
    CELL_PADDING,
    PaddedCells,
    selection_wash,
    style_note,
    style_table,
)
from shiny_mushroom.ui.tips import wrap_tip

#: How tall the dialog opens, in pixels: enough grid for a dozen rows before
#: the scroll bar earns its keep, and short enough to sit beside the canvas.
OPENING_HEIGHT = 480

#: What a column asks for beyond the widest thing in it: the cell's padding on
#: both sides, which is the room a control is placed *inside*, plus a little
#: slack -- a control's size hint is a lower bound, and a picker measured a few
#: pixels short would have its longest name clipped in every row.
COLUMN_SLACK = 6
COLUMN_PADDING = 2 * CELL_PADDING + COLUMN_SLACK

#: How many rows from each end of a table its columns are sized against --
#: see :meth:`TableEditorDialog._size_columns`.
SIZING_ROWS = 12


class _Rows(QAbstractTableModel):
    """The records and their fields, as a table Qt can lay out.

    The descriptors are rebuilt with the records rather than per lookup: a
    field closes over the record it describes, so the two travel together,
    and asking a fields function per painted cell would rebuild a row's
    closures dozens of times a scroll.
    """

    def __init__(
        self,
        parent: QWidget,
        reorderable: bool,
        handle_hint: str | None,
        index_label: Callable[[int], str] | None = None,
    ) -> None:
        super().__init__(parent)
        # What the index column reads and says, held rather than asked of
        # the dialog: Qt paints from a model long after a dialog's own C++
        # object is gone, and a model that reaches back into its widget
        # crashes on the way out.
        self._reorderable = reorderable
        self._handle_hint = handle_hint
        self._index_label = index_label
        self._selected: int | None = None
        self._records: list[object] = []
        self._fields: list[list[Field]] = []
        self._keys: list[str] = []

    # -- what it holds --------------------------------------------------------

    def set_table(
        self,
        fields_for: Callable[[object], list[Field]],
        records: Sequence[object],
    ) -> None:
        """Take a whole new table: other records, and possibly other
        columns. A reset, because nothing about the old rows survives it."""
        self.beginResetModel()
        self._records = list(records)
        self._fields = [list(fields_for(record)) for record in self._records]
        self._keys = [found.key for found in self._fields[0]] if self._fields else []
        self.endResetModel()

    def set_records(
        self,
        fields_for: Callable[[object], list[Field]],
        records: Sequence[object],
    ) -> set[tuple[int, int]]:
        """Take the same table's records again -- an edit rewrites every one
        of them -- and report the cells whose control changed with them.

        A row's field can swap a number for a choice, or one list of choices
        for another, when another of its cells is edited -- an editor already
        open over that cell is then the wrong control, and the dialog rebuilds
        those and no others. See
        :func:`~shiny_mushroom.ui.properties.control_changed`.
        """
        fresh = [list(fields_for(record)) for record in records]
        changed = {
            (row, column)
            for row, (was, now) in enumerate(zip(self._fields, fresh, strict=False))
            for column, (before, after) in enumerate(zip(was, now, strict=False))
            if control_changed(before, after)
        }
        self._records = list(records)
        self._fields = fresh
        if self._records and self._keys:
            self.dataChanged.emit(
                self.index(0, 0),
                self.index(len(self._records) - 1, len(self._keys) - 1),
            )
        return changed

    @property
    def keys(self) -> list[str]:
        """The column keys, in order."""
        return self._keys

    def column_of(self, key: str) -> int | None:
        """Which column a field key is in, or ``None`` for one this table
        does not show -- a folded-away column reads as absent, not as an
        error."""
        return self._keys.index(key) if key in self._keys else None

    def record(self, row: int) -> object:
        return self._records[row]

    def select(self, row: int | None) -> None:
        """Move the highlight to one row, or off every row with ``None``.

        Two repaints per row, because a selection shows in two places: the
        index column's accent, which is header data, and the wash behind the
        row's own cells, which is cell data.
        """
        was, self._selected = self._selected, row
        for section in (was, row):
            if section is None:
                continue
            self.headerDataChanged.emit(Qt.Orientation.Vertical, section, section)
            if self._keys:
                self.dataChanged.emit(
                    self.index(section, 0),
                    self.index(section, len(self._keys) - 1),
                    [Qt.ItemDataRole.BackgroundRole],
                )

    def field(self, row: int, column: int) -> Field | None:
        if not 0 <= row < len(self._fields):
            return None
        held = self._fields[row]
        return held[column] if 0 <= column < len(held) else None

    # -- what Qt asks it ------------------------------------------------------

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:  # noqa: N802, B008
        return 0 if parent.isValid() else len(self._records)

    def columnCount(self, parent: QModelIndex = QModelIndex()) -> int:  # noqa: N802, B008
        return 0 if parent.isValid() else len(self._keys)

    def data(  # noqa: D102 - Qt's own contract
        self, index: QModelIndex, role: int = Qt.ItemDataRole.DisplayRole
    ) -> object:
        found = self.field(index.row(), index.column())
        if found is None:
            return None
        if role == Qt.ItemDataRole.DisplayRole:
            return found.text(self._records[index.row()])
        if role == Qt.ItemDataRole.ToolTipRole:
            return wrap_tip(found.hint) if found.hint else None
        if role == Qt.ItemDataRole.BackgroundRole and index.row() == self._selected:
            # The view holds no selection of its own (the dialog owns what one
            # is), so the wash a styled table would paint for a selected row is
            # asked for here instead -- and painted edge to edge, under the
            # controls' own padding, by :meth:`_Cells.paint`.
            return QBrush(selection_wash())
        return None

    def headerData(  # noqa: N802, D102 - Qt's own contract
        self,
        section: int,
        orientation: Qt.Orientation,
        role: int = Qt.ItemDataRole.DisplayRole,
    ) -> object:
        if orientation == Qt.Orientation.Horizontal:
            return self._column_header(section, role)
        return self._row_header(section, role)

    def _column_header(self, section: int, role: int) -> object:
        found = self.field(0, section)
        if found is None:
            return None
        if role == Qt.ItemDataRole.DisplayRole:
            return found.label
        if role == Qt.ItemDataRole.ToolTipRole:
            return wrap_tip(found.hint) if found.hint else None
        if role == Qt.ItemDataRole.FontRole:
            font = QApplication.font()
            font.setBold(True)
            return font
        return None

    def _row_header(self, section: int, role: int) -> object:
        """The index column: the row's place, and the highlight a selected
        row wears.

        A reorderable table counts from 1 and wears a grip, because there
        the order *is* a value -- "row 1 plays first" is how the owner's
        prose counts it. Anywhere else the number is the record's index,
        counted from 0 like every other index in the editor -- unless the
        owner said how to write it, for a table whose index is a number the
        format itself spells another way.
        """
        if role == Qt.ItemDataRole.DisplayRole:
            if self._reorderable:
                return f"≡ {section + 1}"
            return self._index_label(section) if self._index_label else str(section)
        if role == Qt.ItemDataRole.ToolTipRole:
            return self._handle_hint
        if section != self._selected:
            return None
        palette = QApplication.palette()
        if role == Qt.ItemDataRole.BackgroundRole:
            return palette.brush(QPalette.ColorRole.Highlight)
        if role == Qt.ItemDataRole.ForegroundRole:
            return palette.brush(QPalette.ColorRole.HighlightedText)
        return None

    def flags(self, index: QModelIndex) -> Qt.ItemFlag:  # noqa: D102 - Qt's contract
        if not index.isValid():
            return Qt.ItemFlag.NoItemFlags
        # Editable everywhere, because every cell carries its control
        # whether or not the field behind it can be written: what a
        # read-only field looks like is `field_widget`'s answer -- a label
        # -- not a reason for the cell to refuse an editor.
        return (
            Qt.ItemFlag.ItemIsEnabled
            | Qt.ItemFlag.ItemIsSelectable
            | Qt.ItemFlag.ItemIsEditable
        )


class _Cells(PaddedCells):
    """The cells' controls: the properties panel's own widget factory, over
    one cell at a time.

    ``createEditor`` is the whole of it -- :func:`field_widget` already
    builds the right control for a descriptor and already emits a committed
    value, so the delegate wires that straight to the dialog's signal and
    keeps :meth:`setModelData` empty. Nothing is written through the model:
    the dialog owns no document, and a cell's commit is a *question* for
    whoever does.
    """

    def __init__(self, dialog: TableEditorDialog) -> None:
        super().__init__(dialog)
        self._dialog = dialog

    def paint(self, painter: object, option: object, index: QModelIndex) -> None:
        """Draw the cell only where no control is standing on it.

        A view paints a cell's text under its persistent editors, which is
        invisible under an opaque control and shows through a readout's
        label as the same words twice, a pixel apart. It is also work
        nobody sees: on this table every cell in view carries a control.

        The cell's *background* is drawn either way -- a selected row's wash
        is the one thing under a control that is meant to show, in the
        padding around it and through every readout's transparent label.
        """
        if self._dialog.view.isPersistentEditorOpen(index):
            brush = index.data(Qt.ItemDataRole.BackgroundRole)
            if brush is not None:
                painter.fillRect(option.rect, brush)
            return
        super().paint(painter, option, index)

    def createEditor(  # noqa: N802 - Qt's name
        self, parent: QWidget, option: object, index: QModelIndex
    ) -> QWidget | None:
        model = self._dialog.rows
        found = model.field(index.row(), index.column())
        if found is None:
            return None
        row = index.row()
        widget = field_widget(
            found,
            model.record(row),
            lambda key, value, row=row: self._dialog.edited.emit(row, key, value),
        )
        if isinstance(widget, QLabel):
            # A readout in a panel wraps to the dock's width; a readout in a
            # table row is one line of a row, and wrapping it would spill
            # over the row below rather than making the row taller.
            widget.setWordWrap(False)
        widget.setParent(parent)
        if found.hint:
            widget.setToolTip(wrap_tip(found.hint))
        return widget

    def setEditorData(self, editor: QWidget, index: QModelIndex) -> None:  # noqa: N802
        """Put the record's current value back into the control on show.

        Called by the view for every open editor a ``dataChanged`` covers,
        which is what makes a refresh follow the document without rebuilding
        anything -- and what keeps the keyboard in the box being typed in.
        Signals are blocked for the fill, because writing a record's own
        value into the box showing it is not an edit of it.
        """
        model = self._dialog.rows
        found = model.field(index.row(), index.column())
        if found is None:
            return
        editor.blockSignals(True)
        try:
            fill_field_widget(found, editor, model.record(index.row()))
        finally:
            editor.blockSignals(False)

    def setModelData(  # noqa: N802 - Qt's name
        self, editor: QWidget, model: object, index: QModelIndex
    ) -> None:
        """Nothing: the control emits its own commit, and the model is a
        view of a document this dialog does not own."""


class _Handles(QHeaderView):
    """The index column: where a row's place reads out, the target a click
    selects it by, and -- where the order is itself a value -- the grip a
    drag moves it with.

    One widget for the whole column rather than one per row, which is the
    same trade the cells make: a table of hundreds of rows has one of these.
    """

    def __init__(self, dialog: TableEditorDialog) -> None:
        super().__init__(Qt.Orientation.Vertical, dialog.view)
        self._dialog = dialog
        # Fixed sections, or the header measures every row it has to size --
        # which is the O(rows) work this whole widget exists to avoid.
        self.setSectionResizeMode(QHeaderView.ResizeMode.Fixed)
        self.setSectionsClickable(False)
        self.setHighlightSections(False)
        if dialog.reorderable:
            self.setCursor(Qt.CursorShape.OpenHandCursor)
        elif dialog.selectable:
            self.setCursor(Qt.CursorShape.PointingHandCursor)

    def mousePressEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        row = self.logicalIndexAt(event.position().toPoint())
        if event.button() != Qt.MouseButton.LeftButton or row < 0:
            super().mousePressEvent(event)
            return
        if self._dialog.reorderable:
            self.setCursor(Qt.CursorShape.ClosedHandCursor)
            self._dialog._grab_row(row)
        elif self._dialog.selectable:
            self._dialog._toggle_row(row)
        event.accept()

    def mouseMoveEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        if not self._dialog.reorderable:
            super().mouseMoveEvent(event)
            return
        # The press grabbed the mouse, so these keep arriving outside the
        # header -- mapped through the screen to the table's own viewport,
        # whose coordinates the rows are placed in. Through the screen
        # because the two viewports are siblings, not one inside the other.
        on_screen = self.viewport().mapToGlobal(event.position().toPoint())
        point = self._dialog.view.viewport().mapFromGlobal(on_screen)
        self._dialog._drag_row_to(point.y())
        event.accept()

    def mouseReleaseEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        if not self._dialog.reorderable or event.button() != Qt.MouseButton.LeftButton:
            super().mouseReleaseEvent(event)
            return
        self.setCursor(Qt.CursorShape.OpenHandCursor)
        self._dialog._drop_row()
        event.accept()


class TableEditorDialog(QDialog):
    """One table's rows and columns, editable in place.

    Emits :attr:`edited` with the row index, the field's key and the
    committed value; applying the edit is the owner's business, exactly as
    it is for the properties panel.

    ``index_label`` is how the index column writes a row's number, for a
    table whose index is itself a value of the format -- an entrance number
    is ``$0C0`` everywhere else it is written, so a column of decimals
    beside it would be a second way of saying the same thing.

    ``toggles`` are check boxes over the table, as ``(key, caption, hint)``:
    a switched one emits :attr:`switched` and the owner answers by handing
    over other records. They carry a hint where a footer action does not,
    because a filter has to say what it is taking away.
    """

    #: ``(row, key, value)`` for a cell the user committed.
    edited = Signal(int, str, int)

    #: The key of a footer action button the user pressed -- table-level
    #: work like adding a row, dispatched by the owner exactly as a cell's
    #: :class:`~shiny_mushroom.fields.Action` is.
    acted = Signal(str)

    #: ``(key, checked)`` for a check box over the table the user switched --
    #: a filter, whose answer is which records the owner hands back.
    switched = Signal(str, bool)

    #: ``(row, to)`` for a handle dragged to a new place: move that row to
    #: position ``to``. Applying it is the owner's business, like a cell's.
    reordered = Signal(int, int)

    #: The record row now selected, or ``None`` -- only a ``selectable``
    #: table emits it. A click on a row's index column -- the drag handle,
    #: or the plain index where nothing reorders -- toggles its selection; a
    #: click on the dialog's background, the window deactivating (a click
    #: off the table), the dialog closing and a rebuild of the rows all put
    #: it down. What a selection *means* is the owner's business.
    selected = Signal(object)

    def __init__(
        self,
        title: str,
        note: str = "",
        actions: Sequence[tuple[str, str]] = (),
        toggles: Sequence[tuple[str, str, str]] = (),
        reorderable: bool = False,
        selectable: bool = False,
        index_label: Callable[[int], str] | None = None,
        parent=None,  # noqa: ANN001
    ) -> None:
        super().__init__(parent)
        self.setWindowTitle(title)
        self.setModal(False)

        #: Whether the rows carry drag handles instead of plain indexes --
        #: for a table whose row order is itself a value the owner keeps.
        self.reorderable = reorderable
        #: Whether a row can be selected by clicking its index column.
        self.selectable = selectable

        layout = QVBoxLayout(self)
        if note:
            said = QLabel(note)
            style_note(said)
            layout.addWidget(said)
        #: What the table is currently *of*, for a table whose rows follow
        #: a pick elsewhere -- hidden until :meth:`set_heading` says
        #: something.
        self._heading = QLabel("")
        heading_font = self._heading.font()
        heading_font.setBold(True)
        self._heading.setFont(heading_font)
        self._heading.hide()
        layout.addWidget(self._heading)

        #: The check boxes over the table, by key. Over rather than under it
        #: because what they change is the rows: a filter is read with the
        #: table, where a footer action is done to it.
        self._toggles: dict[str, QCheckBox] = {}
        if toggles:
            switches = QHBoxLayout()
            for key, caption, hint in toggles:
                box = QCheckBox(caption)
                box.setToolTip(wrap_tip(hint))
                box.toggled.connect(
                    lambda checked, key=key: self.switched.emit(key, checked)
                )
                switches.addWidget(box)
                self._toggles[key] = box
            switches.addStretch(1)
            layout.addLayout(switches)

        self._view = QTableView()
        self._rows = _Rows(self, reorderable, self._handle_hint(), index_label)
        self._view.setModel(self._rows)
        self._view.setItemDelegate(_Cells(self))
        self._view.setVerticalHeader(_Handles(self))
        # The dialog owns what a selection is -- one record row, toggled by
        # its handle -- so the view offers none of its own, and no cell is
        # opened for editing by a click: every cell on screen already holds
        # its control.
        self._view.setSelectionMode(QAbstractItemView.SelectionMode.NoSelection)
        self._view.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        # The look every table in the editor shares -- banding instead of a
        # grid, padding inside a cell, and a selection that tints rather than
        # repaints. See :mod:`shiny_mushroom.ui.tables`.
        style_table(self._view)
        # A row at a time, against the per-pixel scrolling every other table
        # in the editor wants. This is the one view that carries a *widget*
        # in every visible cell, and each step of the scroll bar moves and
        # repaints all of them and re-runs the recycler below -- so a
        # 23-pixel row asks for 23 of those where one would do, and a wheel
        # notch for seventy. What is scrolled here is records, and a record
        # is a row.
        self._view.setVerticalScrollMode(QAbstractItemView.ScrollMode.ScrollPerItem)
        layout.addWidget(self._view)

        #: Which row is selected -- ``None`` outside a selection.
        self._selected: int | None = None
        #: The handle drag in flight: the row picked up, and where it would
        #: land -- ``None`` outside one.
        self._drag_from: int | None = None
        self._drag_to: int | None = None
        #: The line a drag shows at the edge the grabbed row would land on.
        self._indicator = QFrame(self._view.viewport())
        self._indicator.setAutoFillBackground(True)
        self._indicator.setBackgroundRole(QPalette.ColorRole.Highlight)
        self._indicator.hide()

        #: The cells holding a live control, as ``(row, column)``, and the
        #: one row kept alive past the viewport -- see :meth:`widget_for`.
        #: One, so that asking for cells cannot itself grow into the
        #: table-sized pile of widgets this dialog exists to avoid.
        self._open: set[tuple[int, int]] = set()
        self._pinned: int | None = None
        #: Set while the model is being replaced. A reset makes the view
        #: drop every editor it holds, and it does that *after* the model
        #: has said so -- so a control opened in the middle of one (a
        #: scrollbar appearing is enough to ask for it) is dropped with the
        #: rest, leaving the dialog's account of them wrong and the cells
        #: blank. Nothing is opened until the reset is over.
        self._resetting = False
        self._view.verticalScrollBar().valueChanged.connect(self._sync_editors)
        self._view.viewport().installEventFilter(self)

        #: The footer's buttons by key, so an owner whose actions are not
        #: always offered can arm them -- a Save that lights only while
        #: there is something to save.
        self._buttons: dict[str, QPushButton] = {}
        if actions:
            footer = QHBoxLayout()
            for key, caption in actions:
                button = QPushButton(caption)
                button.clicked.connect(
                    lambda _checked=False, key=key: self.acted.emit(key)
                )
                footer.addWidget(button)
                self._buttons[key] = button
            footer.addStretch(1)
            layout.addLayout(footer)
        self.resize(self.sizeHint().width(), OPENING_HEIGHT)
        #: Whether the dialog has been sized to its columns; once only, so
        #: reopening keeps the size the user left it at.
        self._sized = False
        #: The column set the widths on show were measured for.
        self._laid_out: list[str] = []

        #: How the rows are described, kept for :meth:`refresh`.
        self._fields_for: Callable[[object], list[Field]] | None = None

    # -- what the parts are, for the model and the header --------------------

    @property
    def view(self) -> QTableView:
        return self._view

    @property
    def rows(self) -> _Rows:
        return self._rows

    @property
    def selected_row(self) -> int | None:
        """The record row selected, or ``None``."""
        return self._selected

    def _handle_hint(self) -> str | None:
        """What the index column's tooltip says it is good for."""
        if self.reorderable:
            return (
                "Click to select; drag to reorder"
                if self.selectable
                else "Drag to reorder"
            )
        return "Click to select" if self.selectable else None

    # -- what it shows ------------------------------------------------------

    def set_toggle(self, key: str, checked: bool) -> None:
        """Switch one check box, as clicking it would -- :attr:`switched` is
        emitted, so the owner's filter follows either way."""
        box = self._toggles.get(key)
        if box is not None:
            box.setChecked(checked)

    def toggle_checked(self, key: str) -> bool:
        """Whether one check box is on -- ``False`` for a key this table has
        none for."""
        box = self._toggles.get(key)
        return box is not None and box.isChecked()

    def set_action_enabled(self, key: str, enabled: bool) -> None:
        """Arm or grey one footer action. Nothing for a key this table has
        no button for, so an owner may ask about an action it did not
        declare."""
        button = self._buttons.get(key)
        if button is not None:
            button.setEnabled(enabled)

    def action_enabled(self, key: str) -> bool:
        """Whether one footer action is offered -- for headless tests."""
        button = self._buttons.get(key)
        return button is not None and button.isEnabled()

    def set_heading(self, text: str) -> None:
        """Say what the rows are currently *of* -- shown over the grid, and
        put away with an empty string."""
        self._heading.setText(text)
        self._heading.setVisible(bool(text))

    def show_rows(
        self,
        fields_for: Callable[[object], list[Field]],
        records: Sequence[object],
    ) -> None:
        """Take a whole new table: one row per record, one column per field.

        Every record must describe the same columns -- the header is read
        off the first one, which is what makes this a table rather than a
        stack of panels.
        """
        self._fields_for = fields_for
        # The selection and any grab die with the rows they named.
        self.select_row(None)
        self._drag_from = self._drag_to = None
        self._indicator.hide()
        # A reset closes every editor the view had open, so the dialog's
        # account of them starts empty too.
        self._open.clear()
        self._pinned = None
        held = self._view.verticalScrollBar().value()
        self._resetting = True
        try:
            self._rows.set_table(fields_for, records)
        finally:
            self._resetting = False
        if not records:
            return
        # The columns are laid out when the set of them changes -- one
        # event's rows drop the Event column the all-events view leads with
        # -- and not merely when the records do: a table whose columns
        # resized under every deleted row would shuffle itself while it was
        # being worked on. The *dialog* is sized once, so reopening keeps
        # the size the user left it at.
        if self._laid_out != self._rows.keys:
            self._laid_out = list(self._rows.keys)
            wanted = self._size_columns()
            if not self._sized:
                self._sized = True
                self._size_to(wanted)
        self._view.verticalScrollBar().setValue(held)
        self._sync_editors()

    def refresh(self, records: Sequence[object]) -> None:
        """Put the records' current values back into the controls on show.

        After a commit every record is a different object -- an edit is a
        rewrite -- and the cells follow without being rebuilt, which keeps
        the keyboard in the box being typed in. Falls back to a whole new
        table when the columns, or the number of rows, are no longer the
        ones on show.
        """
        if self._fields_for is None:
            return
        if (
            not records
            or len(records) != self._rows.rowCount()
            or [found.key for found in self._fields_for(records[0])] != self._rows.keys
        ):
            self.show_rows(self._fields_for, records)
            return
        for row, column in self._rows.set_records(self._fields_for, records):
            # A cell whose control changed under it: the one on show is
            # the wrong widget, and filling it would read the new field
            # through it.
            if (row, column) in self._open:
                index = self._rows.index(row, column)
                self._view.closePersistentEditor(index)
                self._open_editor(index)

    # -- only the rows on screen ---------------------------------------------

    def _sync_editors(self) -> None:
        """Keep a live control on every cell of the visible span, and on no
        other -- the whole of what makes this dialog's cost the viewport's
        rather than the table's."""
        columns = self._rows.columnCount()
        count = self._rows.rowCount()
        if self._resetting or not columns or not count:
            return
        # Counted from the row height rather than read off the bottom of
        # the viewport: a view whose layout has not run yet reports nothing
        # there, and "nothing" must not read as "every row" -- which is the
        # one way this could quietly go back to building the whole table.
        # The sections are a fixed size, so the count is exact.
        step = max(self._view.verticalHeader().defaultSectionSize(), 1)
        first = max(self._view.rowAt(0), 0)
        last = min(count - 1, first + self._view.viewport().height() // step + 1)
        span = set(range(first, last + 1))
        if self._pinned is not None:
            span.add(self._pinned)
        wanted = {
            (row, column) for row in span if row < count for column in range(columns)
        }
        for spot in self._open - wanted:
            self._view.closePersistentEditor(self._rows.index(*spot))
        for spot in wanted - self._open:
            self._open_editor(self._rows.index(*spot))
        self._open = wanted

    def _open_editor(self, index: QModelIndex) -> None:
        """Put a live control on one cell, showing what it shows.

        Qt selects the text of any editor it opens over a cell -- the
        gesture that opens one is usually "I am about to retype this". Here
        every cell on screen carries its control whether or not anyone is
        editing it, so a table of highlighted values would read as a table
        of half-typed ones; the selection is put down as each control
        arrives, and clicking or tabbing into one still selects as it does
        anywhere else in the editor.
        """
        self._view.openPersistentEditor(index)
        editor = self._view.indexWidget(index)
        if editor is None:
            return
        typing = (
            editor if isinstance(editor, QLineEdit) else editor.findChild(QLineEdit)
        )
        if typing is not None:
            typing.deselect()

    def _size_columns(self) -> int:
        """Give every column the width its control asks for and the rows the
        height one stands up in, and say what the whole table wants.

        A control is built for the first row of each column and measured;
        what the *other* rows need is then taken from their text alone,
        widened by the furniture -- the frame, the arrows, the drop-down --
        that first control wears around its own. Building one per row would
        be exactly the O(rows) pass this view is here to avoid, and sizing
        to row 0 alone would cut off every longer readout below it.

        Even the text is read from both ends of the table rather than all
        of it: :data:`SIZING_ROWS` rows from the top and the bottom, which
        is where a column's extremes are -- a row's own number, a name
        table's longest entry -- without walking hundreds of records to
        decide a width.
        """
        header = self._view.horizontalHeader()
        metrics = QFontMetrics(header.font())
        # Every section back to a plain width first: the stretch belongs to
        # whichever column is last *now*, and a table that came back with
        # more columns than it had would leave it stranded in the middle.
        header.setSectionResizeMode(QHeaderView.ResizeMode.Interactive)
        sampled = self._sizing_rows()
        widths: list[int] = []
        height = self._view.verticalHeader().minimumSectionSize()
        for column in range(self._rows.columnCount()):
            label = self._rows.headerData(
                column, Qt.Orientation.Horizontal, Qt.ItemDataRole.DisplayRole
            )
            asks = metrics.horizontalAdvance(str(label or ""))
            texts = [
                metrics.horizontalAdvance(self.cell_text(row, self._rows.keys[column]))
                for row in sampled
            ]
            # Measured off the table, not in it: a sample left parented to
            # the viewport is a widget the view knows nothing about, sitting
            # in the corner over the first row until the event loop gets
            # round to deleting it.
            sample = self._view.itemDelegate().createEditor(
                None, None, self._rows.index(0, column)
            )
            if sample is not None:
                # Polished first: an unparented control has not yet been
                # through its style, and Fusion's combo asks for a dozen
                # pixels less than it draws in until it has.
                sample.ensurePolished()
                hint = sample.sizeHint()
                height = max(height, hint.height())
                furniture = max(0, hint.width() - texts[0])
                asks = max(asks, hint.width(), furniture + max(texts))
                sample.deleteLater()
            widths.append(asks + COLUMN_PADDING)
            self._view.setColumnWidth(column, widths[-1])
        self._view.verticalHeader().setDefaultSectionSize(height)
        # Width beyond what the columns ask for goes to *nothing*: the dialog
        # opens sized to its own table, and a note long enough to make it wider
        # than that would otherwise stretch whichever column happened to be
        # last into half a dialog of empty box.
        # The index column by its *hint*, not its width: the first sizing runs
        # before the dialog is ever shown, where a header that has not been
        # laid out is nought pixels wide -- and a table asked for that much too
        # little opens with a horizontal scroll bar over a column it could have
        # had the room for.
        header_column = self._view.verticalHeader()
        return (
            sum(widths)
            + max(header_column.width(), header_column.sizeHint().width())
            + self._view.verticalScrollBar().sizeHint().width()
            + 2 * self._view.frameWidth()
        )

    def _sizing_rows(self) -> list[int]:
        """Which rows the columns are sized against: both ends of the
        table, and the whole of a table short enough to be both."""
        count = self._rows.rowCount()
        edge = min(count, SIZING_ROWS)
        return sorted({*range(edge), *range(max(0, count - edge), count)})

    def _size_to(self, table: int) -> None:
        """Open wide enough for a table of that width, and no wider than the
        screen it opens on."""
        edges = self.layout().contentsMargins()
        width = table + edges.left() + edges.right()
        screen = self.screen()
        if screen is not None:
            width = min(width, screen.availableGeometry().width())
        self.resize(width, OPENING_HEIGHT)

    def eventFilter(self, watched, event) -> bool:  # noqa: ANN001, N802 - Qt override
        """The table's viewport resizing -- the dialog shown, resized, or
        laid out for the first time -- changes which rows are on screen, and
        each of those needs its controls."""
        if watched is self._view.viewport() and event.type() == QEvent.Type.Resize:
            self._sync_editors()
        return super().eventFilter(watched, event)

    # -- dragging a row to reorder ------------------------------------------
    #
    # The handles report in, the dialog decides: which row a drag is over,
    # where the indicator line sits, and whether letting go means anything.
    # Nothing moves until the owner applies the emitted reorder and hands
    # back rebuilt records -- the drag is a *question*, exactly as a cell
    # edit is.

    def _grab_row(self, row: int) -> None:
        self._drag_from = row
        self._drag_to = row

    def _drag_row_to(self, y: int) -> None:
        """Track the drag: ``y``, in the viewport's coordinates, picks the
        row the grab would land on; the indicator shows the landing edge."""
        if self._drag_from is None:
            return
        to = self._row_under(y)
        self._drag_to = to
        if to == self._drag_from:
            self._indicator.hide()
            return
        top = self._view.rowViewportPosition(to)
        # The row is popped out before it is put back, so landing *on* a row
        # above means its top edge and on one below means its bottom.
        edge = top if to < self._drag_from else top + self._view.rowHeight(to)
        self._indicator.setGeometry(0, edge - 1, self._view.viewport().width(), 2)
        self._indicator.show()
        self._indicator.raise_()
        # Dragging past the viewport's edge walks the scroll along.
        self._view.scrollTo(
            self._rows.index(to, 0), QAbstractItemView.ScrollHint.EnsureVisible
        )

    def _drop_row(self) -> None:
        held, to = self._drag_from, self._drag_to
        self._drag_from = self._drag_to = None
        self._indicator.hide()
        if held is None or to is None:
            return
        if to != held:
            # The rows are about to renumber under the selection.
            self.select_row(None)
            self.reordered.emit(held, to)
        elif self.selectable:
            # A press and release that moved nowhere: the handle's click,
            # toggling the row's selection.
            self._toggle_row(held)

    def _row_under(self, y: int) -> int:
        """Which record row a viewport ``y`` is over, clamped to the table."""
        row = self._view.rowAt(y)
        if row >= 0:
            return row
        return 0 if y < 0 else max(self._rows.rowCount() - 1, 0)

    # -- selecting a row -----------------------------------------------------

    def _toggle_row(self, row: int) -> None:
        """The index column's click -- handle or plain index alike: select
        its row, or put a selection already on it down."""
        self.select_row(None if row == self._selected else row)

    def select_row(self, row: int | None) -> None:
        """Select one record row -- its handle wears the accent and its cells
        the wash -- or put the selection down with ``None``; :attr:`selected`
        says so either way. A no-op outside a ``selectable`` table and when
        nothing changes."""
        if not self.selectable or row == self._selected:
            return
        self._selected = row
        self._rows.select(row)
        self.selected.emit(row)

    def mousePressEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        """A press no widget claimed -- the dialog's background -- puts the
        row selection down."""
        self.select_row(None)
        super().mousePressEvent(event)

    def changeEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        """Deactivating -- a click off the table, onto the canvas or another
        window -- puts the row selection down with the window's focus."""
        if event.type() == QEvent.Type.ActivationChange and not self.isActiveWindow():
            self.select_row(None)
        super().changeEvent(event)

    def closeEvent(self, event) -> None:  # noqa: ANN001, N802 - Qt override
        self.select_row(None)
        super().closeEvent(event)

    # -- what is on show, for tests and for focus ----------------------------

    @property
    def heading(self) -> str:
        """What the line over the table says -- empty where it says nothing,
        which is also when it is not shown."""
        return self._heading.text()

    def row_label(self, row: int) -> str:
        """What the index column reads at one row."""
        if not 0 <= row < self._rows.rowCount():
            return ""
        return str(
            self._rows.headerData(
                row, Qt.Orientation.Vertical, Qt.ItemDataRole.DisplayRole
            )
        )

    def cell_text(self, row: int, key: str) -> str:
        """What one cell is showing."""
        index = self._index_of(row, key)
        if index is None:
            return ""
        return str(self._rows.data(index, Qt.ItemDataRole.DisplayRole) or "")

    def widget_for(self, row: int, key: str) -> QWidget | None:
        """The control showing one cell, for tests and for focus.

        A cell outside the visible span has none until it is asked for --
        the whole point of the recycling -- so asking opens one and keeps
        that row alive until another is asked for or the rows are replaced.
        ``None`` only for a row or a column this table does not show.
        """
        index = self._index_of(row, key)
        if index is None:
            return None
        if self._pinned != row:
            self._pinned = row
            self._sync_editors()
        spot = (index.row(), index.column())
        if spot not in self._open:
            self._open_editor(index)
            self._open.add(spot)
        return self._view.indexWidget(index)

    def _index_of(self, row: int, key: str) -> QModelIndex | None:
        column = self._rows.column_of(key)
        if column is None or not 0 <= row < self._rows.rowCount():
            return None
        return self._rows.index(row, column)

    def keyPressEvent(self, event) -> None:  # noqa: ANN001, N802 - a QKeyEvent
        """Escape closes the dialog even from inside a spin box -- the value
        being typed is committed by the focus change, exactly the panel's
        rule, and undo is what takes it back."""
        if event.key() == Qt.Key.Key_Escape:
            self.close()
            event.accept()
            return
        super().keyPressEvent(event)
