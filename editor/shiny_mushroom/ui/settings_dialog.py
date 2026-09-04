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

#: Where the person's own AddmusicK is. Empty until somebody sets one, for the
#: emulator's reason and one more: this editor does not ship AddmusicK and does
#: not look for it, so there is nowhere a default could honestly point.
ADDMUSICK_KEY = "music/addmusick"

ADDMUSICK_NOTE = (
    "Project > Audio > AddmusicK compiles a project's music with AddmusicK, which "
    "is not part of this editor. Point at the folder the tool was unpacked "
    "into, or at the executable inside it. Importing a song needs it; playing "
    "one already imported does not."
)

#: What a file chooser offers. The tool is a folder as much as a program --
#: it reads its own asm, samples and lists from beside itself -- so either end
#: is accepted and the filter only saves a person some scrolling.
ADDMUSICK_FILTER = "AddmusicK (AddmusicK* addmusick*);;All files (*)"


def external_emulator() -> Path | None:
    """The emulator a test run outside the editor uses, if one is set.

    ``None`` for an empty preference, which is the ordinary state: the setting
    has no default, and every caller has something to say about that rather
    than a fallback to reach for.
    """
    stored = load_str_setting(EMULATOR_KEY).strip()
    return Path(stored) if stored else None


def addmusick_tool() -> Path | None:
    """The AddmusicK installation an import compiles with, if one is set.

    ``None`` for an empty preference, which is the ordinary state and the one a
    fresh install is in: nothing here is bundled, so a project can only compile
    music once somebody has said where their own copy is.
    """
    stored = load_str_setting(ADDMUSICK_KEY).strip()
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

        self._addmusick = QLineEdit(load_str_setting(ADDMUSICK_KEY))
        self._addmusick.setPlaceholderText("No AddmusicK set")
        self._addmusick.setMinimumWidth(360)
        find = QPushButton("B&rowse...")
        find.setAutoDefault(False)
        find.clicked.connect(self._choose_addmusick)
        music_row = QHBoxLayout()
        music_row.setContentsMargins(0, 0, 0, 0)
        music_row.addWidget(self._addmusick)
        music_row.addWidget(find)
        music_holder = QWidget()
        music_holder.setLayout(music_row)
        form.addRow("&AddmusicK:", music_holder)

        music_note = QLabel(ADDMUSICK_NOTE)
        music_note.setWordWrap(True)
        style_note(music_note)
        layout.addWidget(music_note)

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
        self._addmusick.textChanged.connect(self._sync)
        self._sync()

    @property
    def addmusick_path(self) -> str:
        """What is in the AddmusicK box, as it would be stored."""
        return self._addmusick.text().strip()

    def set_addmusick_path(self, path: str | Path) -> None:
        """Put ``path`` in the AddmusicK box."""
        self._addmusick.setText(str(path))

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
        save_str_setting(ADDMUSICK_KEY, self.addmusick_path)
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

    def _choose_addmusick(self) -> None:
        chosen, _filter = QFileDialog.getOpenFileName(
            self,
            f"{APP_NAME} - AddmusicK",
            self.addmusick_path,
            ADDMUSICK_FILTER,
        )
        if chosen:
            self.set_addmusick_path(chosen)

    def _sync(self) -> None:
        """Say what is not there, and nothing more than that.

        Both rows warn rather than refuse, for the same reason: a path may be
        right on the machine the preference is being set for and wrong on the
        one setting it.
        """
        gone = [
            what
            for what, typed in (
                ("emulator", self.emulator_path),
                ("AddmusicK", self.addmusick_path),
            )
            if typed and not Path(typed).exists()
        ]
        self._warning.setText(
            "" if not gone else f"There is nothing at the {' or the '.join(gone)} path."
        )
