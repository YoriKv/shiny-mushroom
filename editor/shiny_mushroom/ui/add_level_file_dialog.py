"""Name a new level container and say what it starts from.

The Level Data window's add flow: a name -- a filename and half of two
generated labels, so the rule is the stricter of the two
(:data:`~shiny_mushroom.level_pointers.ADDED_NAME`) -- and one of three
starting points: a blank level, a copy of a container already in the tree, or
an ``.mwl`` from disk, which is how a level made in Lunar Magic or carried
out of another hack comes in. The dialog only chooses; reading the bytes and
filing the container is the window's
(:meth:`~shiny_mushroom.ui.main_window.MainWindow.add_level_file`), which
owns the project and the file-picker it may need.
"""

from __future__ import annotations

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

from shiny_mushroom.level_pointers import ADDED_NAME
from shiny_mushroom.ui.tables import style_note

TITLE = "Add a Level File"

HINT = "No level number reads the new container yet: remap one at it to open it."

#: The three kinds of starting point, as :attr:`AddLevelFileDialog.chosen_source`
#: spells them.
BLANK = "blank"
COPY = "copy"
FILE = "file"


class AddLevelFileDialog(QDialog):
    """Choose a name and a starting point for a new container.

    ``containers`` is every name already in the tree -- offered as copy
    sources, and the names the new one cannot take.
    """

    def __init__(
        self, containers: tuple[str, ...], parent: QWidget | None = None
    ) -> None:
        super().__init__(parent)
        self.setWindowTitle(TITLE)
        self._containers = containers

        layout = QVBoxLayout(self)
        hint = QLabel(HINT)
        hint.setWordWrap(True)
        style_note(hint)
        layout.addWidget(hint)

        form = QFormLayout()
        self._name = QLineEdit()
        self._name.setPlaceholderText("MyLevel")
        self._name.setToolTip(
            "Letters, digits and '_', starting with a letter or digit."
        )
        form.addRow("&Name:", self._name)

        self._source = QComboBox()
        self._source.addItem("A blank level", (BLANK, ""))
        self._source.addItem("An .mwl file on disk...", (FILE, ""))
        for name in containers:
            self._source.addItem(f"A copy of {name}.mwl", (COPY, name))
        form.addRow("&Start from:", self._source)
        layout.addLayout(form)

        self._buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        self._buttons.accepted.connect(self.accept)
        self._buttons.rejected.connect(self.reject)
        layout.addWidget(self._buttons)

        self._name.textChanged.connect(self._sync)
        self._sync()

    @property
    def chosen_name(self) -> str:
        return self._name.text().strip()

    @property
    def chosen_source(self) -> tuple[str, str]:
        """``(kind, detail)``: :data:`BLANK`, :data:`COPY` of the named
        container, or :data:`FILE` -- a path the window still has to ask for."""
        return self._source.currentData()

    def _sync(self) -> None:
        """OK arms only for a name that could work; the deeper refusals --
        a duplicate on disk, a stock-size cartridge -- are the project's, and
        arrive worded from there."""
        name = self.chosen_name
        usable = bool(ADDED_NAME.match(name)) and name.lower() not in {
            held.lower() for held in self._containers
        }
        self._buttons.button(QDialogButtonBox.StandardButton.Ok).setEnabled(usable)
