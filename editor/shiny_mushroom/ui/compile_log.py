"""What the assembler said, for a build that would not assemble.

A failed run of asar writes the whole of its output to one file -- see
:data:`smw_tools.asar.FAILURE_LOG` -- and this is the window over it. The
failure dialog carries the first few ``error:`` lines, which is what fits in a
sentence and is usually enough; this is the rest, for the times it is not.

**A box rather than a longer message.** The output of a build that broke on an
included file is a hundred lines with the same address in most of them, and the
thing anyone actually does with it is scroll to the first error and paste the
lot into a bug report. So it is a read-only text box: it scrolls, it selects,
Ctrl+A and Ctrl+C work in it, and the Copy button is there for the person who
did not think to try.
"""

from __future__ import annotations

from pathlib import Path

from PySide6.QtGui import QFontDatabase
from PySide6.QtWidgets import (
    QApplication,
    QDialog,
    QDialogButtonBox,
    QPlainTextEdit,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import APP_NAME
from shiny_mushroom.ui.dialogs import selectable_label

__all__ = ["CompileLogDialog", "show_compile_log"]

#: What the box opens at. Wide enough for asar's longest lines -- a path, a
#: line number and a sentence -- so the usual log needs no horizontal scrolling.
WIDTH = 900
HEIGHT = 560


class CompileLogDialog(QDialog):
    """One log file, in a box it can be scrolled through and copied out of."""

    def __init__(self, path: Path, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle(f"{APP_NAME} - Compiler Log")
        self.setModal(True)
        self.resize(WIDTH, HEIGHT)

        #: What was read, kept so the Copy button has something to copy and a
        #: test something to assert against.
        self.text = _read(path)

        self._view = QPlainTextEdit(self.text)
        self._view.setReadOnly(True)
        # Fixed-pitch, because asar's output is columns: a caret under the
        # character it means only lands there in a monospaced font.
        self._view.setFont(QFontDatabase.systemFont(QFontDatabase.SystemFont.FixedFont))
        # No wrapping, for the same reason. A wrapped line puts the caret under
        # the wrong character and turns a two-line error into five.
        self._view.setLineWrapMode(QPlainTextEdit.LineWrapMode.NoWrap)

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        copy = QPushButton("Copy")
        copy.setAutoDefault(False)
        copy.clicked.connect(self.copy)
        buttons.addButton(copy, QDialogButtonBox.ButtonRole.ActionRole)
        buttons.rejected.connect(self.reject)

        layout = QVBoxLayout(self)
        # The path is shown because the log outlives the dialog: someone who
        # wants it in their own editor, or attached to a report, needs to know
        # where it is.
        layout.addWidget(selectable_label(str(path)))
        layout.addWidget(self._view)
        layout.addWidget(buttons)

    def copy(self) -> None:
        """Put the whole log on the clipboard, selection or no selection."""
        clipboard = QApplication.clipboard()
        if clipboard is not None:
            clipboard.setText(self.text)


def _read(path: Path) -> str:
    """``path``'s text, or a sentence saying why there is none.

    Never raises: this is opened *from* a failure, and a second one behind a
    button is the worst moment to discover the reader has no error path.
    """
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError as error:
        return f"{path} could not be read: {error.strerror or error}"


def show_compile_log(parent: QWidget | None, path: Path) -> None:
    """Show ``path``'s contents, and wait to be closed."""
    CompileLogDialog(path, parent).exec()
