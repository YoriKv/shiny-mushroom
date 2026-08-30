"""File > Settings: the preferences that are the person's rather than a
project's, in one window.

The store behind it is :mod:`shiny_mushroom.ui.settings`, and the division of
labour is that module's: it says how a preference is written and read back, and
this one says which preferences there are and what they are called on screen.
A setting lives here when it belongs to *whoever is using the editor* -- where
their emulator is, how they like things -- rather than to what they have open,
which belongs in the project.

**A row is a key, a widget and a line of prose.** Nothing is applied as it is
typed: the dialog is a form, OK writes it and Cancel writes nothing, so a path
half-typed and thought better of leaves the preference as it was.

Not every preference is here. The ones a menu already carries -- the theme, the
grid, the view toggles -- are set by triggering the row that shows them, and a
second place to change them would be a second thing to keep in step.
"""

from __future__ import annotations

from pathlib import Path

from PySide6.QtWidgets import (
    QDialog,
    QDialogButtonBox,
    QFileDialog,
    QFormLayout,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import APP_NAME
from shiny_mushroom.ui.settings import load_str_setting, save_str_setting
from shiny_mushroom.ui.tables import style_note

TITLE = f"{APP_NAME} - Settings"

#: Where the external emulator's executable is kept. Empty until somebody sets
#: one: there is no default worth guessing at, and a wrong guess would be a
#: menu row that fails rather than one that explains itself.
EMULATOR_KEY = "emulator/external"

EMULATOR_NOTE = (
    "Level > Test Level Externally builds the project's cartridge and opens it "
    "here. Leave it empty to use the editor's own test window only."
)

#: What a file chooser offers for the executable. Windows and macOS both have a
#: shape a program takes; on Linux it is any file with the bit set, so the
#: filter is only ever a convenience and every one of them ends in "All files".
EMULATOR_FILTER = (
    "Emulators (*.exe *.app *.AppImage);;Applications (*.app);;All files (*)"
)


def external_emulator() -> Path | None:
    """The emulator a test run outside the editor uses, if one is set.

    ``None`` for an empty preference, which is the ordinary state: the setting
    has no default, and every caller has something to say about that rather
    than a fallback to reach for.
    """
    stored = load_str_setting(EMULATOR_KEY).strip()
    return Path(stored) if stored else None


class SettingsDialog(QDialog):
    """The application's preferences, as a form.

    Reads the store when it opens and writes it only on OK, so what it shows is
    what is stored and what is stored is what was accepted.
    """

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle(TITLE)

        layout = QVBoxLayout(self)
        form = QFormLayout()

        self._emulator = QLineEdit(load_str_setting(EMULATOR_KEY))
        self._emulator.setPlaceholderText("No external emulator set")
        self._emulator.setMinimumWidth(360)
        browse = QPushButton("&Browse...")
        browse.setAutoDefault(False)
        browse.clicked.connect(self._choose_emulator)
        row = QHBoxLayout()
        row.setContentsMargins(0, 0, 0, 0)
        row.addWidget(self._emulator)
        row.addWidget(browse)
        holder = QWidget()
        holder.setLayout(row)
        form.addRow("&External emulator:", holder)
        layout.addLayout(form)

        note = QLabel(EMULATOR_NOTE)
        style_note(note)
        layout.addWidget(note)

        # Says what is wrong with the path in the box without refusing it:
        # OK stays armed, because a path may well be right on the machine the
        # preference is being set for and wrong on the one setting it.
        self._warning = QLabel()
        style_note(self._warning)
        layout.addWidget(self._warning)

        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

        self._emulator.textChanged.connect(self._sync)
        self._sync()

    @property
    def emulator_path(self) -> str:
        """What is in the box, as it would be stored."""
        return self._emulator.text().strip()

    def set_emulator_path(self, path: str | Path) -> None:
        """Put ``path`` in the box.

        Public so the flow can be driven without a file chooser, which under
        Qt's offscreen platform is the only way to drive it at all.
        """
        self._emulator.setText(str(path))

    def accept(self) -> None:
        """Write the form to the store, then close."""
        save_str_setting(EMULATOR_KEY, self.emulator_path)
        super().accept()

    def _choose_emulator(self) -> None:
        chosen, _filter = QFileDialog.getOpenFileName(
            self,
            f"{APP_NAME} - External Emulator",
            self.emulator_path,
            EMULATOR_FILTER,
        )
        if chosen:
            self.set_emulator_path(chosen)

    def _sync(self) -> None:
        """Say whether what is typed is there, and nothing more than that."""
        typed = self.emulator_path
        missing = bool(typed) and not Path(typed).exists()
        self._warning.setText("There is nothing at that path." if missing else "")
