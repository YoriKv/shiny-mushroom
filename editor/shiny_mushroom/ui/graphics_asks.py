"""What the Graphics window asks for before it can add, rename or duplicate
a file: a number, a name, a format and a starting point.

A different job from showing the catalogue
(:mod:`shiny_mushroom.ui.graphics_dialog`), and none of it touches that
window: each ask is a field that knows one rule and a form around it, and
what an accepted ask hands back is an answer the project may take.

**One rule in one place, and it is the project's.** A number is what
:meth:`~shiny_mushroom.project.Project.add_graphics` accepts and a name what
:func:`~shiny_mushroom.project_graphics.check_graphics_name` accepts, read by the
field rather than restated here. A form greys its OK button on the field's
reading, so a caller that got an accepted dialog has an answer it need not
check again.
"""

from __future__ import annotations

from collections.abc import Callable, Iterable
from pathlib import Path

from PySide6.QtCore import Signal
from PySide6.QtWidgets import (
    QComboBox,
    QDialog,
    QDialogButtonBox,
    QFormLayout,
    QLabel,
    QLineEdit,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.project import ProjectError
from shiny_mushroom.project_graphics import check_graphics_name
from shiny_mushroom.ui.tables import style_note
from shiny_mushroom.ui.tips import wrap_tip
from smw_tools import graphics_memory
from smw_tools.graphics import TileFormat

#: The starting points an added file is offered, as
#: :attr:`AddGraphicsFileDialog.chosen_source` spells them.
BLANK = "blank"
FILE = "file"

#: The formats an added file may be, in the order the add dialog offers them.
ADDED_FORMATS = (TileFormat.PLANAR_3BPP, TileFormat.PLANAR_4BPP)

#: What a name for one of the project's own graphics files may be, where the
#: field has nothing to refuse. The refusals themselves are the project's
#: words (:func:`~shiny_mushroom.project_graphics.check_graphics_name`).
NAME_NOTE = "A file name and no folder in it; .bin is added where it is left off."

#: What a number for an added file may be, said once: the field's tooltip
#: where a form asks for more than the number, and a line of its own where
#: the number is all that is asked.
RANGE_NOTE = (
    f"Hex, ${graphics_memory.FIRST_ADDED:02X} to "
    f"${graphics_memory.LAST_ADDED:02X}, except "
    f"${graphics_memory.UNNAMEABLE:02X}, which a level spells 'no file' "
    f"with. The lowest free number is offered."
)


_FORMAT_NAMES = {
    TileFormat.PLANAR_2BPP: "2bpp",
    TileFormat.PLANAR_3BPP: "3bpp",
    TileFormat.PLANAR_4BPP: "4bpp",
    TileFormat.MODE7_3BPP: "Mode 7",
}


def format_name(fmt: TileFormat) -> str:
    return _FORMAT_NAMES[fmt]


def parse_number(text: str) -> int | None:
    """A file number as somebody typed it -- ``$34``, ``34``, ``0x34``, hex
    either way -- or ``None`` for text that is not one."""
    cleaned = text.strip().lstrip("$")
    if cleaned.lower().startswith("0x"):
        cleaned = cleaned[2:]
    try:
        return int(cleaned, 16) if cleaned else None
    except ValueError:
        return None


def free_number(taken: Iterable[int]) -> int | None:
    """The lowest file number a project may still add, or ``None`` when
    every one is taken -- the number
    :meth:`~shiny_mushroom.project.Project.add_graphics` picks for itself,
    by the same rule (:func:`smw_tools.graphics_memory.addable`)."""
    held = set(taken)
    return next(
        (
            number
            for number in range(
                graphics_memory.FIRST_ADDED, graphics_memory.LAST_ADDED + 1
            )
            if number not in held and graphics_memory.addable(number)
        ),
        None,
    )


def answered[T](dialog: QDialog, answer: Callable[[], T]) -> T | None:
    """Ask ``dialog``, hand back ``answer()`` where it was accepted and
    ``None`` where it was taken back, and let the dialog go.

    Every ask here is parented to the window so that it opens over it, which
    makes the window its owner: without the delete, each one would leave a
    dialog alive until the window itself closed.
    """
    accepted = dialog.exec() == QDialog.DialogCode.Accepted.value
    held = answer() if accepted else None
    dialog.deleteLater()
    return held


class FileNumberEdit(QLineEdit):
    """Where a number for a file the project adds is typed.

    One rule in one place, and it is the project's: what may be typed is
    what :meth:`~shiny_mushroom.project.Project.add_graphics` accepts --
    hex, in the added range, never the number no level could name
    (:func:`smw_tools.graphics_memory.addable`), and not a number the
    project already adds. Whatever asks greys its OK button on
    :attr:`usable` rather than refusing after the typing, which is what
    makes :attr:`number` a number the project may take wherever an ask was
    accepted.

    ``taken`` is every number the project already adds; the lowest free one
    is offered to begin with.
    """

    #: :attr:`usable` changed -- what the asker's OK button follows.
    usability_changed = Signal(bool)

    def __init__(self, taken: Iterable[int], parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._taken = frozenset(taken)
        self.setToolTip(wrap_tip(RANGE_NOTE))
        lowest = free_number(self._taken)
        if lowest is not None:
            self.setText(f"${lowest:02X}")
        self._usable = self.usable
        self.textChanged.connect(lambda _text: self._sync())

    @property
    def number(self) -> int | None:
        """The number typed, or ``None`` for text that is not one."""
        return parse_number(self.text())

    @property
    def usable(self) -> bool:
        """Whether the number is one the project may add. The deeper
        refusals -- a packing the banks cannot hold -- are the project's,
        and arrive worded from there."""
        number = self.number
        return (
            number is not None
            and graphics_memory.addable(number)
            and number not in self._taken
        )

    def _sync(self) -> None:
        usable = self.usable
        if usable != self._usable:
            self._usable = usable
            self.usability_changed.emit(usable)


class FileNumberDialog(QDialog):
    """Ask for a number for a file the project adds, and nothing else: the
    rename's ask and the duplicate's.

    ``hint`` says what the number is for, in the caller's words; the range
    is the field's own (:data:`RANGE_NOTE`). The OK button follows the
    field, so :attr:`chosen_number` on an accepted dialog is always a number
    the project may take.
    """

    def __init__(
        self,
        title: str,
        hint: str,
        taken: Iterable[int],
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        self.setWindowTitle(title)

        layout = QVBoxLayout(self)
        self._hint = QLabel(hint)
        self._hint.setWordWrap(True)
        style_note(self._hint)
        layout.addWidget(self._hint)

        form = QFormLayout()
        self._number = FileNumberEdit(taken)
        form.addRow("&Number:", self._number)
        layout.addLayout(form)

        said = QLabel(RANGE_NOTE)
        said.setWordWrap(True)
        style_note(said)
        layout.addWidget(said)

        self._buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        self._buttons.accepted.connect(self.accept)
        self._buttons.rejected.connect(self.reject)
        layout.addWidget(self._buttons)

        ok = self._buttons.button(QDialogButtonBox.StandardButton.Ok)
        ok.setEnabled(self._number.usable)
        self._number.usability_changed.connect(ok.setEnabled)

    @property
    def chosen_number(self) -> int | None:
        """The number typed, or ``None`` for text that is not one."""
        return self._number.number

    def set_number(self, text: str) -> None:
        self._number.setText(text)


class FileNameEdit(QLineEdit):
    """Where a name for one of the project's own graphics files is typed.

    One rule in one place, and it is the project's
    (:func:`~shiny_mushroom.project_graphics.check_graphics_name`): a file name and
    not a path, and not a name the set's raw folder already holds. What it
    refuses, it refuses in words -- :attr:`refusal`, which the ask shows --
    since a greyed button over a name says less than one over a number.

    ``taken`` is every name the folder holds already, the file being renamed
    left out.
    """

    def __init__(self, taken: Iterable[str], parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._taken = tuple(taken)
        self.setToolTip(wrap_tip(NAME_NOTE))

    @property
    def wanted(self) -> str | None:
        """The file name typed, suffix and all, or ``None`` where it is not
        one the project would take."""
        try:
            return check_graphics_name(self.text(), self._taken)
        except ProjectError:
            return None

    @property
    def refusal(self) -> str:
        """Why the name typed is not one, in the project's words, or ``""``
        where it is."""
        try:
            check_graphics_name(self.text(), self._taken)
        except ProjectError as error:
            return f"{error}."
        return ""

    @property
    def usable(self) -> bool:
        return self.wanted is not None


class FileNameDialog(QDialog):
    """Ask for a name for one of the project's own graphics files.

    ``hint`` says what the name is for; ``name`` is what the file is called
    now, offered to be typed over. The OK button follows the field, and what
    the field refuses is said under it rather than left to be guessed.
    """

    def __init__(
        self,
        title: str,
        hint: str,
        taken: Iterable[str],
        name: str = "",
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        self.setWindowTitle(title)

        layout = QVBoxLayout(self)
        self._hint = QLabel(hint)
        self._hint.setWordWrap(True)
        style_note(self._hint)
        layout.addWidget(self._hint)

        form = QFormLayout()
        self._name = FileNameEdit(taken)
        self._name.setText(Path(name).stem)
        form.addRow("&Name:", self._name)
        layout.addLayout(form)

        self._said = QLabel(NAME_NOTE)
        self._said.setWordWrap(True)
        style_note(self._said)
        layout.addWidget(self._said)

        self._buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        self._buttons.accepted.connect(self.accept)
        self._buttons.rejected.connect(self.reject)
        layout.addWidget(self._buttons)

        # Every keystroke, not only the ones that flip the button: what the
        # field refuses it refuses in words, and stale words are worse than
        # none.
        self._name.textChanged.connect(lambda _text: self._sync())
        self._sync()

    @property
    def chosen_name(self) -> str | None:
        """The file name typed, suffix and all, or ``None`` for one the
        project would not take."""
        return self._name.wanted

    def set_name(self, text: str) -> None:
        self._name.setText(text)

    def _sync(self) -> None:
        ok = self._buttons.button(QDialogButtonBox.StandardButton.Ok)
        ok.setEnabled(self._name.usable)
        self._said.setText(self._name.refusal or NAME_NOTE)


class AddGraphicsFileDialog(QDialog):
    """Choose a number, a format and a starting point for a new file.

    ``taken`` is every number the project already adds: the ones the new
    file cannot take, and what the default number is the lowest past. The
    dialog only chooses; reading a PNG and filing the raw form is
    :meth:`GraphicsDialog.add_file`'s.
    """

    def __init__(self, taken: Iterable[int], parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle("Add a Graphics File")

        layout = QVBoxLayout(self)
        hint = QLabel("Nothing loads the new file until a level's tileset names it.")
        hint.setWordWrap(True)
        style_note(hint)
        layout.addWidget(hint)

        form = QFormLayout()
        self._number = FileNumberEdit(taken)
        form.addRow("&Number:", self._number)

        self._format = QComboBox()
        for fmt in ADDED_FORMATS:
            self._format.addItem(format_name(fmt), fmt)
        self._format.setToolTip(
            wrap_tip("3bpp is expanded on upload; 4bpp goes to VRAM as it is.")
        )
        form.addRow("&Format:", self._format)

        self._source = QComboBox()
        self._source.addItem("Blank tiles", BLANK)
        self._source.addItem("A PNG on disk...", FILE)
        form.addRow("&Start from:", self._source)
        layout.addLayout(form)

        self._buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        self._buttons.accepted.connect(self.accept)
        self._buttons.rejected.connect(self.reject)
        layout.addWidget(self._buttons)

        ok = self._buttons.button(QDialogButtonBox.StandardButton.Ok)
        ok.setEnabled(self._number.usable)
        self._number.usability_changed.connect(ok.setEnabled)

    @property
    def chosen_number(self) -> int | None:
        """The number typed, or ``None`` for text that is not one."""
        return self._number.number

    @property
    def chosen_format(self) -> TileFormat:
        return self._format.currentData()

    @property
    def chosen_source(self) -> str:
        """:data:`BLANK`, or :data:`FILE` -- a path the caller still has to
        ask for."""
        return self._source.currentData()

    def set_number(self, text: str) -> None:
        self._number.setText(text)

    def set_format(self, fmt: TileFormat) -> None:
        self._format.setCurrentIndex(ADDED_FORMATS.index(fmt))

    def set_source(self, source: str) -> None:
        self._source.setCurrentIndex(0 if source == BLANK else 1)

    @property
    def usable(self) -> bool:
        """Whether the number is one the project may add -- the field's own
        reading (:attr:`FileNumberEdit.usable`), which the OK button
        follows."""
        return self._number.usable


__all__ = [
    "ADDED_FORMATS",
    "BLANK",
    "FILE",
    "NAME_NOTE",
    "RANGE_NOTE",
    "AddGraphicsFileDialog",
    "FileNameDialog",
    "FileNameEdit",
    "FileNumberDialog",
    "FileNumberEdit",
    "answered",
    "format_name",
    "free_number",
    "parse_number",
]
