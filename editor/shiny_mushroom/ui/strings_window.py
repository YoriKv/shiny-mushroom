"""The Strings window: the game's text, edited as text.

Modelled on Shiny Egg's Strings panel: one tab per kind of text, each a
searchable list of entries with a line input per line, a byte budget under
it, and a Save that lights while there is something to save. Three tabs over
the two regions the international cartridges keep under the standard font
(:mod:`shiny_mushroom.strings`): the message boxes, which level shows which
of them, and the parts a level name is assembled from.

**The window owns the document, not the project.** It is handed a
:class:`~shiny_mushroom.strings.StringsDocument` and the runs of ROM its
regions are priced against, keeps the edited copy beside the last-saved one,
and says ``unsaved`` when they differ; saving and reverting are the main
window's, which owns the project and asks through :attr:`save_asked` and
:attr:`revert_asked`. The dot for that unsaved work is on *this* window's
title (:func:`~shiny_mushroom.ui.dialogs.mark_unsaved`), as the Map16
editor's and the Secondary Entrances window's are on theirs: a dot answers
for the document under it. Closing over unsaved edits asks Save, Discard or
Cancel through :meth:`_ask_to_save`, the seam the suite replaces.

What a message shows is drawn beside its lines: the eight-by-eighteen box
the game fills, spaces and all, because a message is laid out by hand with
spaces and the inputs alone do not show where a word lands.
"""

from __future__ import annotations

import re
from collections.abc import Callable, Mapping, Sequence

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFontDatabase, QKeySequence, QPalette, QShortcut
from PySide6.QtWidgets import (
    QCheckBox,
    QComboBox,
    QDialog,
    QFormLayout,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QListWidget,
    QListWidgetItem,
    QPushButton,
    QScrollArea,
    QSplitter,
    QTableWidget,
    QTableWidgetItem,
    QTabWidget,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.build import SharedRoom
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.strings import (
    MESSAGES,
    NAMES,
    Font,
    StringsDocument,
    TextError,
    message_cost,
    message_slots,
    price,
    slots_of,
)
from shiny_mushroom.ui.dialogs import Choice, ask_to_save, mark_unsaved
from shiny_mushroom.ui.memory_map_dialog import BudgetBar
from shiny_mushroom.ui.tables import style_note, style_table
from shiny_mushroom.ui.tips import wrap_tip
from smw_tools.asm_strings import (
    MESSAGE_LINES,
    MESSAGE_WIDTH,
    NAME_LABELS,
    message_label,
)

#: How many translevels the overworld's per-translevel tables describe. A
#: slot byte's seven bits reach past them, so a slot can name a translevel
#: none of them has a row for -- :meth:`StringsWindow._level_picker` names
#: such a value rather than dropping it.
TRANSLEVELS = 0x60

TITLE = "Strings"

#: Found by name in tests.
OBJECT_NAME = "strings-window"

#: What each tab is, said once at its top.
MESSAGE_HINT = (
    "Eight lines of up to 18 characters. The messages share one run of ROM, "
    "so trimming one frees bytes for another."
)
NAME_HINT = (
    "A level's name is up to three parts, one per group. Which parts a level "
    "uses is set in Level Load Path."
)
SLOT_HINT = (
    "A box shows the first slot naming its level and message number; a level "
    "in no slot falls through to slot 0."
)

SLOT_COLUMNS = ("Slot", "Level", "Message 2", "Shows", "Note")

#: A Level row for a translevel past :data:`TRANSLEVELS`, and what it is.
PAST_THE_TABLE = "(past the table)"
PAST_THE_TABLE_TIP = (
    "No overworld row describes this level, so the game reads past the end "
    "of its tables."
)

#: What the add and remove buttons say while the cartridge cannot grow.
FIXED_NOTE = "Growable strings (Project > Features) is needed to add slots or messages."

#: How the three name groups are headed, in fragment order.
NAME_GROUPS = (
    ("First part", 0x1E),
    ("Second part", 0x0E),
    ("Third part", 0x0C),
    ("None", 1),
)

#: A tile the font has no character for, in the box preview -- and the
#: ``[XX]`` spelling it replaces there, so the box keeps its width.
TOKEN_MARK = "▯"
_TOKEN_SHOWN = re.compile(r"\[[0-9A-Fa-f]{2}\]")


def _mono() -> QFontDatabase.SystemFont:
    return QFontDatabase.systemFont(QFontDatabase.SystemFont.FixedFont)


class _LineInput(QLineEdit):
    """One string's input: text in, a problem said in red."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setFont(_mono())
        self._problem = ""

    @property
    def problem(self) -> str:
        return self._problem

    def set_problem(self, problem: str) -> None:
        """Colour the input for ``problem``, or clear it for ``""``."""
        if problem == self._problem:
            return
        self._problem = problem
        self.setToolTip(problem)
        if problem:
            bad = QPalette(self.palette())
            bad.setColor(QPalette.ColorRole.Base, Qt.GlobalColor.darkRed)
            bad.setColor(QPalette.ColorRole.Text, Qt.GlobalColor.white)
            self.setPalette(bad)
        else:
            self.setPalette(QPalette())


class StringsWindow(QDialog):
    """The game's text. Construct once, ``show_document`` as often as the
    project's text changes, and read :attr:`document` back on a save."""

    #: The window wants its document written into the project.
    save_asked = Signal()
    #: The window wants a region's edit taken back out of the project, by
    #: region id -- the disassembly's own text is what comes back.
    revert_asked = Signal(str)

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setObjectName(OBJECT_NAME)
        self.setModal(False)
        self.resize(760, 560)
        self._font: Font | None = None
        self._document = StringsDocument()
        self._baseline = StringsDocument()
        self._rooms: tuple[SharedRoom, ...] = ()
        self._grows = False
        self._name_of: Callable[[int], str | None] = lambda _: None
        self._labels: dict[int, str] = {}
        self._message = 0
        self._filling = False

        layout = QVBoxLayout(self)
        self._tabs = QTabWidget(self)
        layout.addWidget(self._tabs, 1)
        self._tabs.addTab(self._build_messages(), "&Messages")
        self._tabs.addTab(self._build_slots(), "Message &Slots")
        self._tabs.addTab(self._build_names(), "&Level Names")

        bottom = QHBoxLayout()
        self._status = QLabel(self)
        style_note(self._status)
        bottom.addWidget(self._status, 1)
        self._revert = QPushButton("&Revert", self)
        self._revert.setToolTip("Put this tab's text back to the disassembly's own.")
        self._revert.clicked.connect(self._revert_current)
        bottom.addWidget(self._revert)
        self._save = QPushButton("&Save", self)
        self._save.setToolTip("Write the text into the project  (Ctrl+S)")
        self._save.clicked.connect(self.save_asked.emit)
        bottom.addWidget(self._save)
        close = QPushButton("&Close", self)
        close.clicked.connect(self.close)
        bottom.addWidget(close)
        layout.addLayout(bottom)

        QShortcut(QKeySequence.StandardKey.Save, self, self._save_if_lit)
        QShortcut(QKeySequence.StandardKey.Close, self, self.close)
        self._tabs.currentChanged.connect(lambda _: self._sync())
        self._sync()

    # -- building --------------------------------------------------------------

    def _build_messages(self) -> QWidget:
        page = QWidget(self)
        layout = QVBoxLayout(page)
        hint = QLabel(MESSAGE_HINT, page)
        style_note(hint)
        layout.addWidget(hint)
        split = QSplitter(page)
        layout.addWidget(split, 1)

        left = QWidget(split)
        left_layout = QVBoxLayout(left)
        left_layout.setContentsMargins(0, 0, 0, 0)
        self._message_search = QLineEdit(left)
        self._message_search.setPlaceholderText("Search messages")
        self._message_search.setClearButtonEnabled(True)
        self._message_search.textChanged.connect(self._filter_messages)
        left_layout.addWidget(self._message_search)
        self._message_list = QListWidget(left)
        self._message_list.setWordWrap(True)
        self._message_list.setHorizontalScrollBarPolicy(
            Qt.ScrollBarPolicy.ScrollBarAlwaysOff
        )
        self._message_list.currentRowChanged.connect(self._pick_message)
        left_layout.addWidget(self._message_list, 1)
        grow = QHBoxLayout()
        self._add_message = QPushButton("&Add message", left)
        self._add_message.clicked.connect(self._message_added)
        grow.addWidget(self._add_message)
        self._delete_message = QPushButton("&Delete message", left)
        self._delete_message.clicked.connect(self._message_deleted)
        grow.addWidget(self._delete_message)
        left_layout.addLayout(grow)
        split.addWidget(left)

        right = QWidget(split)
        right_layout = QVBoxLayout(right)
        # A left margin, so the row labels stand off the list beside them
        # rather than against the splitter's handle.
        right_layout.setContentsMargins(12, 0, 0, 0)
        self._message_title = QLabel(right)
        self._message_title.setTextFormat(Qt.TextFormat.PlainText)
        # Wrapped: a message named after a long level would otherwise be the
        # width the whole window had to be.
        self._message_title.setWordWrap(True)
        right_layout.addWidget(self._message_title)
        form = QFormLayout()
        self._message_lines: list[_LineInput] = []
        for row in range(MESSAGE_LINES):
            edit = _LineInput(right)
            edit.textEdited.connect(
                lambda text, row=row: self._message_line_edited(row, text)
            )
            self._message_lines.append(edit)
            form.addRow(f"Line {row + 1}", edit)
        right_layout.addLayout(form)
        self._box = QLabel(right)
        self._box.setFont(_mono())
        self._box.setTextFormat(Qt.TextFormat.PlainText)
        self._box.setFrameShape(QLabel.Shape.StyledPanel)
        self._box.setToolTip("The box as the game draws it.")
        right_layout.addWidget(self._box, 0, Qt.AlignmentFlag.AlignHCenter)
        self._message_cost = QLabel(right)
        style_note(self._message_cost)
        right_layout.addWidget(self._message_cost)
        right_layout.addStretch(1)
        split.addWidget(right)
        split.setStretchFactor(0, 1)
        split.setStretchFactor(1, 2)
        split.setSizes([300, 460])

        self._message_budget = self._budget_bar(page)
        layout.addWidget(self._message_budget)
        return page

    def _build_slots(self) -> QWidget:
        page = QWidget(self)
        layout = QVBoxLayout(page)
        hint = QLabel(SLOT_HINT, page)
        style_note(hint)
        layout.addWidget(hint)
        table = QTableWidget(0, len(SLOT_COLUMNS), page)
        table.setHorizontalHeaderLabels(SLOT_COLUMNS)
        table.verticalHeader().setVisible(False)
        table.setSelectionMode(QTableWidget.SelectionMode.NoSelection)
        style_table(table)
        self._slot_table = table
        self._slot_levels: list[QComboBox | None] = []
        self._slot_seconds: list[QCheckBox | None] = []
        self._slot_messages: list[QComboBox] = []
        layout.addWidget(table, 1)
        grow = QHBoxLayout()
        self._add_slot = QPushButton("Add &slot", page)
        self._add_slot.clicked.connect(self._slot_added)
        grow.addWidget(self._add_slot)
        self._remove_slot = QPushButton("Remove last sl&ot", page)
        self._remove_slot.clicked.connect(self._slot_removed)
        grow.addWidget(self._remove_slot)
        grow.addStretch(1)
        layout.addLayout(grow)
        return page

    def _build_names(self) -> QWidget:
        page = QWidget(self)
        layout = QVBoxLayout(page)
        hint = QLabel(NAME_HINT, page)
        style_note(hint)
        layout.addWidget(hint)
        self._name_search = QLineEdit(page)
        self._name_search.setPlaceholderText("Search level name parts")
        self._name_search.setClearButtonEnabled(True)
        self._name_search.textChanged.connect(self._filter_names)
        layout.addWidget(self._name_search)
        scroll = QScrollArea(page)
        scroll.setWidgetResizable(True)
        inner = QWidget(scroll)
        self._name_form = QFormLayout(inner)
        self._name_inputs: list[_LineInput] = []
        self._name_rows: list[tuple[QLabel, _LineInput]] = []
        self._name_headings: list[QLabel] = []
        index = 0
        for heading, count in NAME_GROUPS:
            head = QLabel(heading, inner)
            head.setStyleSheet("font-weight: bold")
            self._name_form.addRow(head)
            self._name_headings.append(head)
            for _ in range(count):
                edit = _LineInput(inner)
                edit.textEdited.connect(
                    lambda text, at=index: self._name_edited(at, text)
                )
                label = QLabel(_name_row_label(index), inner)
                label.setToolTip(NAME_LABELS[index])
                self._name_form.addRow(label, edit)
                self._name_inputs.append(edit)
                self._name_rows.append((label, edit))
                index += 1
        scroll.setWidget(inner)
        layout.addWidget(scroll, 1)
        self._name_budget = self._budget_bar(page)
        layout.addWidget(self._name_budget)
        return page

    def _budget_bar(self, parent: QWidget) -> BudgetBar:
        """A byte budget under a tab. What it is priced against is the
        document's, so :meth:`show_document` writes the tip."""
        return BudgetBar(parent=parent)

    # -- the document ----------------------------------------------------------

    def show_document(
        self,
        font: Font,
        document: StringsDocument,
        rooms: Sequence[SharedRoom],
        name_of: Callable[[int], str | None] | None = None,
        grows: bool = False,
    ) -> None:
        """Take a freshly read document as both held and last-saved.

        ``rooms`` is the runs the document's regions are priced against
        (:func:`shiny_mushroom.build.asm_shared_rooms`) -- one per run, so
        two regions sharing one are measured against it together and an edit
        to either moves both bars. Empty for a project with no build to price
        against, and a region in none of them is shown unpriced.

        ``name_of`` names a translevel where the world map has a name for it,
        for the slot rows and for saying who shows each message; ``grows``
        whether the cartridge's search follows the tables, so slots and
        messages may be added and taken away.
        """
        self._font = font
        self._document = document
        self._baseline = document
        self._rooms = tuple(rooms)
        for region_id, bar in (
            (MESSAGES, self._message_budget),
            (NAMES, self._name_budget),
        ):
            run = self._run_of(region_id)
            bar.setToolTip(
                wrap_tip(
                    "What the text occupies of its run of ROM."
                    if run is None or len(run.regions) == 1
                    else "What the text occupies of the run it shares with the "
                    "rest of the game's text."
                )
            )
        self._grows = grows
        for button in (
            self._add_message,
            self._delete_message,
            self._add_slot,
            self._remove_slot,
        ):
            button.setEnabled(grows)
            button.setToolTip("" if grows else wrap_tip(FIXED_NOTE))
        if name_of is not None:
            self._name_of = name_of
        self._relabel()
        self._tabs.setTabEnabled(0, bool(document.messages))
        self._tabs.setTabEnabled(1, bool(document.messages))
        self._tabs.setTabEnabled(2, bool(document.names))
        self._fill_message_list()
        self._fill_slots()
        self._fill_names()
        if self._message >= len(document.messages):
            self._message = 0
        self._message_list.setCurrentRow(self._message)
        self._show_message()
        self._sync()

    def set_saved(self, document: StringsDocument) -> None:
        """The project now holds ``document``: it is the new baseline."""
        self._baseline = document
        self._sync()

    def restore(self, document: StringsDocument) -> None:
        """Put ``document`` back as the held one over whatever baseline the
        window has -- an edit carried across a reopen of the cartridge."""
        self._document = document
        self._relabel()
        self._fill_message_list()
        self._fill_slots()
        self._fill_names()
        self._show_message()
        self._sync()

    def discard(self) -> None:
        """Put the held document back to the last-saved one."""
        self._document = self._baseline
        self._relabel()
        self._fill_message_list()
        self._fill_slots()
        self._fill_names()
        self._show_message()
        self._sync()

    @property
    def document(self) -> StringsDocument:
        return self._document

    @property
    def baseline(self) -> StringsDocument:
        """What the project last held -- what :attr:`unsaved` compares to."""
        return self._baseline

    @property
    def unsaved(self) -> bool:
        return self._document != self._baseline

    @property
    def problems(self) -> tuple[str, ...]:
        """Every reason the document cannot be saved as it stands."""
        return tuple(self._problems())

    @property
    def save_lit(self) -> bool:
        """Whether Save is offered -- for headless tests."""
        return self._save.isEnabled()

    def current_tab(self) -> str:
        """The region the front tab edits -- the slots are the messages'."""
        return NAMES if self._tabs.currentIndex() == 2 else MESSAGES

    def _relabel(self) -> None:
        """Who shows each message, off the document's own slot tables."""
        self._labels = {
            index: "; ".join(slot.describe(self._name_of) for slot in held)
            for index, held in message_slots(self._document).items()
        }

    def select_message(self, index: int) -> None:
        self._message_list.setCurrentRow(index)

    # -- messages --------------------------------------------------------------

    def _fill_message_list(self) -> None:
        self._filling = True
        self._message_list.clear()
        for index, lines in enumerate(self._document.messages):
            item = QListWidgetItem(self._message_row_text(index, lines))
            item.setData(Qt.ItemDataRole.UserRole, index)
            item.setToolTip("\n".join(lines))
            self._message_list.addItem(item)
        self._filling = False
        self._filter_messages(self._message_search.text())

    def _message_row_text(self, index: int, lines: tuple[str, ...]) -> str:
        who = self._labels.get(index, "")
        first = next((line.strip() for line in lines if line.strip()), "")
        head = f"{index:02X}  {who}" if who else f"{index:02X}"
        return f"{head}\n    {first}" if first else head

    def _filter_messages(self, needle: str) -> None:
        needle = needle.strip().lower()
        for row in range(self._message_list.count()):
            item = self._message_list.item(row)
            index = item.data(Qt.ItemDataRole.UserRole)
            haystack = " ".join(
                (
                    f"{index:02X}",
                    message_label(index),
                    self._labels.get(index, ""),
                    *self._document.messages[index],
                )
            ).lower()
            item.setHidden(bool(needle) and needle not in haystack)

    def _pick_message(self, row: int) -> None:
        if self._filling or row < 0:
            return
        item = self._message_list.item(row)
        self._message = item.data(Qt.ItemDataRole.UserRole)
        self._show_message()

    def _show_message(self) -> None:
        if not self._document.messages:
            self._message_title.setText("")
            for edit in self._message_lines:
                edit.setText("")
                edit.setEnabled(False)
            self._box.setText("")
            self._message_cost.setText("")
            return
        index = self._message
        lines = self._document.messages[index]
        who = self._labels.get(index, "")
        self._message_title.setText(
            f"Message {index:02X} ({message_label(index)})"
            + (f" -- {who}" if who else "")
        )
        for edit, line in zip(self._message_lines, lines, strict=True):
            edit.setEnabled(True)
            if edit.text() != line:
                edit.setText(line)
        self._refresh_message_readout()

    def _message_line_edited(self, row: int, text: str) -> None:
        self._document = self._document.with_message_line(self._message, row, text)
        item = self._message_list.item(self._list_row(self._message))
        if item is not None:
            lines = self._document.messages[self._message]
            item.setText(self._message_row_text(self._message, lines))
            item.setToolTip("\n".join(lines))
        shown = self._message_choice_text(self._message)
        for combo in self._slot_messages:
            combo.setItemText(self._message, shown)
        self._refresh_message_readout()
        self._sync()

    def _list_row(self, index: int) -> int:
        for row in range(self._message_list.count()):
            if self._message_list.item(row).data(Qt.ItemDataRole.UserRole) == index:
                return row
        return -1

    def _refresh_message_readout(self) -> None:
        if self._font is None or not self._document.messages:
            return
        lines = self._document.messages[self._message]
        for row, (edit, line) in enumerate(
            zip(self._message_lines, lines, strict=True), start=1
        ):
            edit.set_problem(self._line_problem(line, f"Line {row}"))
        self._box.setText("\n".join(self._box_row(line) for line in lines))
        self._message_cost.setText(
            f"This message: {message_cost(self._font, lines):,} bytes"
        )

    def _box_row(self, line: str) -> str:
        shown = _TOKEN_SHOWN.sub(TOKEN_MARK, line)
        return shown[:MESSAGE_WIDTH].ljust(MESSAGE_WIDTH)

    def _line_problem(
        self, line: str, where: str, width: int | None = MESSAGE_WIDTH
    ) -> str:
        assert self._font is not None
        bad = self._font.unspellable(line)
        if bad:
            return f"{where}: the font cannot spell {bad!r}"
        if width is not None and self._font.width(line) > width:
            return (
                f"{where}: {self._font.width(line)} characters, and a line "
                f"holds {width} at most"
            )
        return ""

    # -- slots -----------------------------------------------------------------

    def _message_choice_text(self, index: int) -> str:
        lines = self._document.messages[index]
        first = next((line.strip() for line in lines if line.strip()), "")
        return f"{index:02X}  {first}" if first else f"{index:02X}"

    def _level_picker(self, parent: QWidget, translevel: int) -> QComboBox:
        """A slot's Level picker, showing ``translevel``.

        A value past the tables gets a row of its own, named for what it is,
        rather than being dropped for the first row of the table: the
        document keeps the byte the cartridge holds, an edit to another
        control in the row writes that same byte back, and what is wrong is
        on screen for whoever did not put it there.
        """
        picker = QComboBox(parent)
        for value in range(TRANSLEVELS):
            name = self._name_of(value)
            picker.addItem(f"{hexnum(value)}  {name}" if name else hexnum(value), value)
        if translevel >= TRANSLEVELS:
            picker.addItem(f"{hexnum(translevel)}  {PAST_THE_TABLE}", translevel)
            picker.setItemData(
                picker.count() - 1,
                wrap_tip(PAST_THE_TABLE_TIP),
                Qt.ItemDataRole.ToolTipRole,
            )
        picker.setCurrentIndex(picker.findData(translevel))
        return picker

    def _fill_slots(self) -> None:
        """Build the slot rows from the document, once per document."""
        self._filling = True
        table = self._slot_table
        table.setRowCount(0)
        self._slot_levels, self._slot_seconds, self._slot_messages = [], [], []
        for slot in slots_of(self._document):
            row = table.rowCount()
            table.insertRow(row)
            table.setItem(row, 0, _cell(hexnum(slot.number)))
            if slot.number < self._document.level_slots:
                level = self._level_picker(table, slot.translevel or 0)
                level.currentIndexChanged.connect(
                    lambda _, at=slot.number: self._slot_level_edited(at)
                )
                table.setCellWidget(row, 1, level)
                second = QCheckBox(table)
                second.setChecked(slot.second)
                second.setToolTip("Shown for the level's second message box")
                second.clicked.connect(
                    lambda _=False, at=slot.number: self._slot_level_edited(at)
                )
                table.setCellWidget(row, 2, second)
            else:
                level, second = None, None
                table.setItem(row, 1, _cell(slot.describe(self._name_of)))
                table.setItem(row, 2, _cell(""))
            self._slot_levels.append(level)
            self._slot_seconds.append(second)
            message = QComboBox(table)
            for index in range(len(self._document.messages)):
                message.addItem(self._message_choice_text(index), index)
            message.setCurrentIndex(self._document.pointers[slot.number])
            message.currentIndexChanged.connect(
                lambda _, at=slot.number: self._slot_message_edited(at)
            )
            table.setCellWidget(row, 3, message)
            self._slot_messages.append(message)
            table.setItem(row, 4, _cell(slot.note))
        table.resizeColumnsToContents()
        self._filling = False

    def _slot_level_edited(self, slot: int) -> None:
        if self._filling:
            return
        level, second = self._slot_levels[slot], self._slot_seconds[slot]
        assert level is not None and second is not None
        self._document = self._document.with_slot_level(
            slot, level.currentData(), second.isChecked()
        )
        self._slots_changed()

    def _slot_message_edited(self, slot: int) -> None:
        if self._filling:
            return
        index = self._slot_messages[slot].currentData()
        self._document = self._document.with_slot_message(slot, index)
        self._slots_changed()

    def _slots_changed(self) -> None:
        """The slot tables moved: the message rows say who shows them."""
        self._relabel()
        for index in range(len(self._document.messages)):
            item = self._message_list.item(self._list_row(index))
            if item is not None:
                lines = self._document.messages[index]
                item.setText(self._message_row_text(index, lines))
        # The riding-Yoshi row follows the slot before it.
        riding = self._slot_table.rowCount() - 2
        if riding >= 0:
            held = slots_of(self._document)[self._document.level_slots]
            self._slot_table.item(riding, 1).setText(held.describe(self._name_of))
        self._show_message()
        self._sync()

    def select_slot_message(self, slot: int, index: int) -> None:
        """Pick message ``index`` for slot ``slot`` -- the gesture, for tests."""
        self._slot_messages[slot].setCurrentIndex(index)

    # -- growing ---------------------------------------------------------------

    def _regrow(self, document: StringsDocument, message: int | None = None) -> None:
        """Take a document whose table shapes changed: every list is rebuilt,
        since the rows and the pickers' choices are the shapes."""
        self._document = document
        if message is not None:
            self._message = message
        self._relabel()
        self._fill_message_list()
        self._fill_slots()
        if self._message >= len(document.messages):
            self._message = max(len(document.messages) - 1, 0)
        self._message_list.setCurrentRow(self._list_row(self._message))
        self._show_message()
        self._sync()

    def _message_added(self) -> None:
        if not self._grows:
            return
        grown = self._document.with_message_added()
        self._regrow(grown, len(grown.messages) - 1)

    def _message_deleted(self) -> None:
        if not self._grows or not self._document.messages:
            return
        try:
            self._regrow(self._document.without_message(self._message))
        except TextError as error:
            self._status.setText(str(error))

    def _slot_added(self) -> None:
        if not self._grows:
            return
        self._regrow(self._document.with_slot_added())

    def _slot_removed(self) -> None:
        if not self._grows:
            return
        try:
            self._regrow(self._document.without_last_slot())
        except TextError as error:
            self._status.setText(str(error))

    # -- names -----------------------------------------------------------------

    def _fill_names(self) -> None:
        for edit, name in zip(self._name_inputs, self._document.names, strict=False):
            edit.setEnabled(True)
            if edit.text() != name:
                edit.setText(name)
        for edit in self._name_inputs[len(self._document.names) :]:
            edit.setText("")
            edit.setEnabled(False)
        self._refresh_name_readout()
        self._filter_names(self._name_search.text())

    def _name_edited(self, index: int, text: str) -> None:
        self._document = self._document.with_name(index, text)
        self._refresh_name_readout()
        self._sync()

    def _refresh_name_readout(self) -> None:
        if self._font is None:
            return
        for index, (edit, name) in enumerate(
            zip(self._name_inputs, self._document.names, strict=False)
        ):
            edit.set_problem(
                self._line_problem(name, _name_row_label(index), width=None)
            )

    def _filter_names(self, needle: str) -> None:
        needle = needle.strip().lower()
        for index, (label, edit) in enumerate(self._name_rows):
            haystack = " ".join((label.text(), NAME_LABELS[index], edit.text())).lower()
            hidden = bool(needle) and needle not in haystack
            label.setVisible(not hidden)
            edit.setVisible(not hidden)

    # -- the footer ------------------------------------------------------------

    def _problems(self) -> list[str]:
        if self._font is None:
            return []
        out = []
        for index, lines in enumerate(self._document.messages):
            for row, line in enumerate(lines, start=1):
                found = self._line_problem(line, f"Message {index:02X}, line {row}")
                if found:
                    out.append(found)
        for index, name in enumerate(self._document.names):
            found = self._line_problem(name, _name_row_label(index), width=None)
            if found:
                out.append(found)
        used = price(self._font, self._document)
        for run in self._rooms:
            over = -run.spare(used)
            if over > 0:
                out.append(_over_line(run, over))
        return out

    def _run_of(self, region_id: str) -> SharedRoom | None:
        """The run ``region_id`` is priced against, or ``None`` where nothing
        prices it -- a project with no build, or a target whose build has no
        such fragment."""
        for run in self._rooms:
            if region_id in run.regions:
                return run
        return None

    def _room_of(self, region_id: str, used: Mapping[str, int]) -> int | None:
        """How many bytes ``region_id`` may occupy with the rest of its run
        at ``used`` -- ``None`` where :meth:`_run_of` has nothing.

        Not a number the region has of its own where a run is shared: what
        the others hold *now* comes off it, so shrinking one is room the
        other may take and growing one is room it has lost.
        """
        run = self._run_of(region_id)
        if run is None:
            return None
        return run.room - sum(
            used.get(other, 0) for other in run.regions if other != region_id
        )

    def _sync(self) -> None:
        """Every readout that depends on the whole document."""
        mark_unsaved(self, TITLE, self.unsaved)
        if self._font is None:
            self._save.setEnabled(False)
            self._revert.setEnabled(False)
            return
        used = price(self._font, self._document)
        for region_id, bar in (
            (MESSAGES, self._message_budget),
            (NAMES, self._name_budget),
        ):
            held = used.get(region_id, 0)
            room = self._room_of(region_id, used)
            if room is None:
                bar.show_budget(
                    held, None, f"{held:,} bytes (no build to price against)"
                )
            else:
                over = held - room
                bar.show_budget(
                    held,
                    max(room, 0),
                    f"{held:,} / {room:,} bytes"
                    + (f" -- {over:,} over" if over > 0 else ""),
                )
        problems = self._problems()
        self._status.setText(problems[0] if problems else "")
        self._light_save(self.unsaved and not problems)
        self._revert.setEnabled(self.current_tab() in used)

    def _light_save(self, lit: bool) -> None:
        self._save.setEnabled(lit)
        if lit:
            palette = QPalette(self._save.palette())
            palette.setColor(
                QPalette.ColorRole.Button,
                palette.color(QPalette.ColorRole.Highlight),
            )
            palette.setColor(
                QPalette.ColorRole.ButtonText,
                palette.color(QPalette.ColorRole.HighlightedText),
            )
            self._save.setPalette(palette)
        else:
            self._save.setPalette(QPalette())

    def _save_if_lit(self) -> None:
        if self._save.isEnabled():
            self.save_asked.emit()

    def _revert_current(self) -> None:
        self.revert_asked.emit(self.current_tab())

    # -- closing ---------------------------------------------------------------

    def _ask_to_save(self, message: str, detail: str = "") -> Choice:
        """The seam the suite replaces: offscreen, a modal never returns."""
        return ask_to_save(self, message, detail)

    def closeEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        if not self.unsaved:
            super().closeEvent(event)
            return
        answer = self._ask_to_save(
            "The strings have unsaved changes.",
            "Discarding reverts to the last save.",
        )
        if answer is Choice.CANCEL:
            event.ignore()
            return
        if answer is Choice.DISCARD:
            self.discard()
            super().closeEvent(event)
            return
        if self._problems():
            # Save was chosen over text that cannot be saved: the window
            # stays, with the reason under the inputs.
            event.ignore()
            return
        self.save_asked.emit()
        if self.unsaved:
            # The save was refused and has said why; the window stays.
            event.ignore()
            return
        super().closeEvent(event)


#: What the footer calls each region's text.
_TEXT = {MESSAGES: "messages", NAMES: "level names"}


def _over_line(run: SharedRoom, over: int) -> str:
    """The footer's line for text that will not fit the run it is in."""
    what = " and ".join(_TEXT.get(one, one) for one in run.regions)
    where = "their run of ROM" if len(run.regions) == 1 else "the run they share"
    return f"The {what} are {over:,} bytes over {where}"


def _name_row_label(index: int) -> str:
    """A name part's row label: its index within its group, in hex, which
    is the value the level's name word carries for it."""
    at = index
    for _, count in NAME_GROUPS[:-1]:
        if at < count:
            return f"{at + 1:X}"
        at -= count
    return "-"


def _cell(text: str) -> QTableWidgetItem:
    item = QTableWidgetItem(text)
    item.setFlags(Qt.ItemFlag.ItemIsEnabled)
    return item
