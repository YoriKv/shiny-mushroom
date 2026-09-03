"""Level > Edit Test Controls: what drives the test window's pad, and where
it came from.

The bindings are the person's rather than the project's -- somebody who plays
on a controller plays on it in every cartridge they open -- so they live in
:mod:`shiny_mushroom.ui.settings` beside the theme and the view toggles, and
the readers at the top of this module are how the test window gets them.

**The dialog reads and imports; it does not rebind.** What it offers is the set
the editor ships with and the set an installed MesenCE already has, because
somebody who has spent an evening arranging their controller in an emulator has
already answered this question and should not be asked it twice. Binding a key
at a time is a different feature and this is not half of it.

Import is a whole-set replacement, not a merge. A configuration is one person's
answer for all twelve buttons, and half of one grafted onto half of the
editor's defaults is an arrangement neither of them chose.
"""

from __future__ import annotations

from pathlib import Path

from PySide6.QtCore import QEvent, QSize, Qt
from PySide6.QtGui import QPalette
from PySide6.QtWidgets import (
    QAbstractItemView,
    QDialog,
    QDialogButtonBox,
    QFileDialog,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QTableWidget,
    QTableWidgetItem,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom import APP_NAME, mesen_config, mesen_keys, pads
from shiny_mushroom.pad_bindings import BUTTON_ORDER, DEFAULT_BINDINGS, Bindings
from shiny_mushroom.play_request import Buttons
from shiny_mushroom.ui.dialogs import warn
from shiny_mushroom.ui.icon_font import icon_aspect, palette_icon
from shiny_mushroom.ui.icons import PadIcon
from shiny_mushroom.ui.settings import (
    load_int_setting,
    load_str_setting,
    save_int_setting,
    save_str_setting,
)
from shiny_mushroom.ui.tables import PaddedCells, style_note, style_table

TITLE = f"{APP_NAME} - Test Controls"

#: The bindings themselves, as :meth:`Bindings.to_json` writes them.
BINDINGS_KEY = "input/bindings"

#: How far a stick travels before it counts as pushed, as the five-step number
#: Mesen stores rather than the multiplier it means: it is imported alongside
#: the bindings and belongs to them, and storing the step keeps this preference
#: readable next to the file it came from.
DEADZONE_KEY = "input/deadzone"

#: Where the last import came from, so the dialog can say so and the chooser
#: can start there.
SOURCE_KEY = "input/imported-from"

COLUMNS = ("Button", "Keyboard", "Controller")

#: How tall a button's mark is drawn. Its *width* is its own -- see
#: :func:`~shiny_mushroom.ui.icon_font.icon_aspect` -- because these are marks
#: beside words rather than buttons in a row: a shared box wide enough for a
#: shoulder's labelled pill would leave the d-pad floating away from its name.
#: One height, so the column still reads as a column.
PAD_MARK_HEIGHT = 20

#: The widest a mark may come out, which is what the view is told to reserve.
#: Only a ceiling: each mark is handed over at its own width, and Qt lays out
#: the decoration it actually got.
PAD_MARK_LIMIT = QSize(PAD_MARK_HEIGHT * 3, PAD_MARK_HEIGHT)

#: Which mark each button wears. The two enums are named alike on purpose --
#: they are the same twelve buttons -- and ``test_controls`` asserts they stay
#: that way, so this is a lookup rather than a table to keep in step.
PAD_ICONS = {button: PadIcon[button.name] for button in BUTTON_ORDER}

NOTE = (
    "The test window reads these while a run is on screen. Import takes the "
    "bindings out of a MesenCE settings.json -- keyboard and controller both, "
    "for SNES controller port 1."
)


def bindings() -> Bindings:
    """What the test window drives its pad with.

    The shipped defaults until somebody imports over them, and the shipped
    defaults again if what is stored is not readable -- a preference written by
    a newer build, or hand-edited into nonsense, must leave the window
    controllable rather than dead.
    """
    stored = load_str_setting(BINDINGS_KEY)
    return (stored and Bindings.from_json(stored)) or DEFAULT_BINDINGS


def deadzone() -> float:
    """The stick threshold the bindings were imported with, as a multiplier."""
    return mesen_config.deadzone_ratio(
        load_int_setting(DEADZONE_KEY, mesen_config.DEFAULT_STEP)
    )


def save(found: Bindings, *, deadzone_step: int, source: str) -> None:
    """Write an imported or restored set. ``source`` is empty for the defaults."""
    save_str_setting(BINDINGS_KEY, found.to_json())
    save_int_setting(DEADZONE_KEY, deadzone_step)
    save_str_setting(SOURCE_KEY, source)


class ControlsDialog(QDialog):
    """The twelve buttons, what holds each, and the offer to import a set.

    A form like every other dialog here: it edits a set of its own and writes
    it on OK, so an import looked at and thought better of leaves the stored
    bindings alone.
    """

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle(TITLE)

        self._bindings = bindings()
        self._deadzone_step = load_int_setting(DEADZONE_KEY, mesen_config.DEFAULT_STEP)
        self._source = load_str_setting(SOURCE_KEY)

        layout = QVBoxLayout(self)

        self._table = QTableWidget(len(BUTTON_ORDER), len(COLUMNS))
        self._table.setHorizontalHeaderLabels(COLUMNS)
        self._table.verticalHeader().setVisible(False)
        self._table.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self._table.setSelectionMode(QAbstractItemView.SelectionMode.NoSelection)
        style_table(self._table)
        self._table.setItemDelegate(PaddedCells(self._table))
        self._table.setIconSize(PAD_MARK_LIMIT)
        layout.addWidget(self._table, 1)

        note = QLabel(NOTE)
        style_note(note)
        layout.addWidget(note)

        #: What was imported, and what this machine has to read a pad with.
        #: Both are facts about the set on screen rather than about the form,
        #: so they sit with the rows and not in a status bar.
        self._where = QLabel()
        style_note(self._where)
        layout.addWidget(self._where)

        row = QHBoxLayout()
        row.setContentsMargins(0, 0, 0, 0)
        self._import = QPushButton("&Import from MesenCE...")
        self._import.setAutoDefault(False)
        self._import.clicked.connect(self._choose)
        row.addWidget(self._import)
        self._defaults = QPushButton("Restore &Defaults")
        self._defaults.setAutoDefault(False)
        self._defaults.clicked.connect(self._restore)
        row.addWidget(self._defaults)
        row.addStretch(1)
        layout.addLayout(row)

        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

        self._sync()
        self.resize(520, 420)

    # -- what is on screen ---------------------------------------------------

    @property
    def shown(self) -> Bindings:
        """The set the dialog is showing, which OK would write."""
        return self._bindings

    def _sync(self) -> None:
        for row, button in enumerate(BUTTON_ORDER):
            bound = self._bindings.for_button(button)
            cells = (
                button.name.title(),
                _named(code for code in bound if not mesen_keys.is_pad(code)),
                _named(code for code in bound if mesen_keys.is_pad(code)),
            )
            for column, text in enumerate(cells):
                item = QTableWidgetItem(text)
                item.setTextAlignment(
                    Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignVCenter
                )
                self._table.setItem(row, column, item)
            self._mark(row, button)
        self._table.resizeColumnsToContents()
        self._where.setText(self._provenance())

    def _mark(self, row: int, button: Buttons) -> None:
        """Put ``button``'s own mark beside its name.

        The name alone is ambiguous in this table and nowhere else: the row
        called "Y" sits next to a Keyboard column that is also full of single
        letters, and a drawn button says which kind of thing the row is about
        before it is read. The marks are baked from the palette like every
        other icon in the editor, so a theme switch redraws them.
        """
        item = self._table.item(row, 0)
        if item is None:
            return
        mark = PAD_ICONS[button]
        width = max(1, round(PAD_MARK_HEIGHT * icon_aspect(mark)))
        item.setIcon(
            palette_icon(
                mark,
                self.palette(),
                QSize(width, PAD_MARK_HEIGHT),
                self.devicePixelRatioF() or 1.0,
                QPalette.ColorRole.Text,
            )
        )

    def changeEvent(self, event: QEvent) -> None:  # noqa: N802 - Qt override
        super().changeEvent(event)
        if event.type() == QEvent.Type.PaletteChange:
            for row, button in enumerate(BUTTON_ORDER):
                self._mark(row, button)

    def _provenance(self) -> str:
        """One line: where this set came from, and what can read a pad here."""
        came = (
            f"Imported from {self._source}."
            if self._source
            else ("The editor's own layout -- nothing has been imported.")
        )
        reader = pads.open_pads(self.deadzone_ratio)
        try:
            return f"{came}  {reader.describe()}"
        finally:
            reader.close()

    @property
    def deadzone_ratio(self) -> float:
        """The stick threshold on screen, as :mod:`shiny_mushroom.pads` wants
        it."""
        return mesen_config.deadzone_ratio(self._deadzone_step)

    # -- the two things it does ----------------------------------------------

    def _restore(self) -> None:
        self._bindings = DEFAULT_BINDINGS
        self._deadzone_step = mesen_config.DEFAULT_STEP
        self._source = ""
        self._sync()

    def _choose(self) -> None:
        start = self._source or str(mesen_config.find_settings() or Path.home())
        chosen, _filter = QFileDialog.getOpenFileName(
            self, f"{APP_NAME} - Import MesenCE Controls", start, mesen_config.FILTER
        )
        if chosen:
            self.import_from(Path(chosen))

    def import_from(self, path: Path) -> None:
        """Read ``path`` into the form, or say why it could not be read.

        Public so the flow can be driven without a file chooser, which under
        Qt's offscreen platform is the only way to drive it at all.
        """
        try:
            found = mesen_config.read(path)
        except mesen_config.MesenConfigError as error:
            self._alert("That is not a MesenCE configuration.", detail=str(error))
            return
        self._bindings = found.bindings
        self._deadzone_step = mesen_config.deadzone_step(found.deadzone)
        self._source = str(path)
        self._sync()
        if not found.is_pad:
            self._alert(
                "SNES port 1 is not set to a controller in that configuration.",
                detail=f"It is a {found.controller or 'peripheral'}, so what was "
                "imported is whatever its buttons are bound to. The bindings are "
                "on screen; Cancel leaves the stored ones alone.",
            )

    def accept(self) -> None:
        """Write the form to the store, then close."""
        save(self._bindings, deadzone_step=self._deadzone_step, source=self._source)
        super().accept()

    def _alert(self, message: str, *, detail: str = "") -> None:
        """This dialog's one modal failure surface -- see
        :mod:`shiny_mushroom.ui.dialogs` for why it is a method."""
        warn(self, message, detail=detail)


def _named(codes) -> str:
    """One cell's worth of key names, or a dash where nothing is bound.

    A dash rather than a blank: an unbound half is an answer, and an empty cell
    reads as one the table failed to fill in.
    """
    return ", ".join(mesen_keys.key_name(code) for code in codes) or "--"
