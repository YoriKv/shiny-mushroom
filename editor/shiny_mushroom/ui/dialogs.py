"""The message boxes the editor ever puts up, and the small parts every dialog
needs, built in one place.

A warning that something did not work, a question before something that cannot
be taken back, and the offer to save work that is about to be thrown away.
Everything user-facing that is not a purpose-built dialog is one of those three,
and all three are here so that what a failure, a confirmation and an unsaved-work
prompt *look* like is one decision rather than one per call site. The two pieces
of furniture at the end -- a label worth copying out of, and the handover of a
folder to the desktop -- are here for the same reason: several dialogs want
each, and each has one detail that is easy to leave out.

**They are functions, and every window still wraps them in a method of its
own.** That is not indirection for its own sake: under Qt's offscreen platform a
modal ``exec()`` never returns, so the suite replaces the method and any dialog a
test reaches becomes an assertion instead of a hang. A window is the thing a test
holds, so the method on the window is the seam it can reach -- one per window,
because the two windows are opened and closed independently and a test that
drives one must not be blind to the other's. What the methods no longer carry is
seven lines of ``QMessageBox`` assembly each.
"""

from __future__ import annotations

from enum import Enum
from pathlib import Path

from PySide6.QtCore import Qt, QUrl
from PySide6.QtGui import QDesktopServices, QFont
from PySide6.QtWidgets import QComboBox, QLabel, QMessageBox, QSpinBox, QWidget

from shiny_mushroom import APP_NAME


class Choice(Enum):
    """What to do with work that is about to be thrown away."""

    SAVE = "save"
    DISCARD = "discard"
    CANCEL = "cancel"


def warn(
    parent: QWidget | None, message: str, *, title: str = APP_NAME, detail: str = ""
) -> None:
    """Say that something did not work, and wait to be acknowledged."""
    box = QMessageBox(parent)
    box.setIcon(QMessageBox.Icon.Warning)
    box.setWindowTitle(title)
    box.setText(message)
    if detail:
        box.setInformativeText(detail)
    box.exec()


def inform(
    parent: QWidget | None, message: str, *, title: str = APP_NAME, detail: str = ""
) -> None:
    """Report something asked for -- a check's findings, a clean bill --
    and wait to be acknowledged. :func:`warn`'s shape without the alarm."""
    box = QMessageBox(parent)
    box.setIcon(QMessageBox.Icon.Information)
    box.setWindowTitle(title)
    box.setText(message)
    if detail:
        box.setInformativeText(detail)
    box.exec()


def ask(parent: QWidget | None, message: str, detail: str = "") -> bool:
    """Ask before something that cannot be taken back. ``True`` to go ahead.

    Cancel is the default button, so a confirmation dismissed by reflex --
    Return, Escape, the window's own close -- keeps the work rather than
    discarding it.
    """
    box = QMessageBox(parent)
    box.setIcon(QMessageBox.Icon.Warning)
    box.setWindowTitle(APP_NAME)
    box.setText(message)
    if detail:
        box.setInformativeText(detail)
    box.setStandardButtons(
        QMessageBox.StandardButton.Ok | QMessageBox.StandardButton.Cancel
    )
    box.setDefaultButton(QMessageBox.StandardButton.Cancel)
    return box.exec() == QMessageBox.StandardButton.Ok


def ask_to_save(parent: QWidget | None, message: str, detail: str = "") -> Choice:
    """Offer to save work that is about to be thrown away.

    Save is the default button and Cancel the escape one, so a prompt answered
    by reflex keeps the work either way -- Return by writing it, Escape by not
    going anywhere. Only Discard, which has to be aimed at, loses it.
    """
    box = QMessageBox(parent)
    box.setIcon(QMessageBox.Icon.Warning)
    box.setWindowTitle(APP_NAME)
    box.setText(message)
    if detail:
        box.setInformativeText(detail)
    buttons = QMessageBox.StandardButton
    box.setStandardButtons(buttons.Save | buttons.Discard | buttons.Cancel)
    box.setDefaultButton(buttons.Save)
    box.setEscapeButton(buttons.Cancel)
    answered = box.exec()
    if answered == buttons.Save:
        return Choice.SAVE
    return Choice.DISCARD if answered == buttons.Discard else Choice.CANCEL


#: What a title wears while the document under it has work that is not
#: written yet -- the platform-neutral spelling of the dot every editor
#: marks an unsaved document with.
UNSAVED_MARK = "* "


def mark_unsaved(window: QWidget, title: str, unsaved: bool) -> None:
    """Put ``title`` on ``window``, marked while ``unsaved``.

    **A window's dot answers for its own document.** The Map16 editor's marks
    the tables, the Secondary Entrances window's the entrances, the Strings
    window's the text -- the same rule the main window's title follows for
    the view it sits over, and the reason a window's edits are not fed to
    somebody else's title, where the dot would point at nothing on screen.
    """
    window.setWindowTitle(f"{UNSAVED_MARK}{title}" if unsaved else title)


def selectable_label(text: str = "", *, font: QFont | None = None) -> QLabel:
    """A label whose text can be dragged out of it with the mouse.

    For the two things a dialog shows that are worth pasting somewhere else:
    what a slow job is doing and how it failed -- asar's or the extractor's own
    complaint, the one thing worth putting in a bug report -- and a readout that
    exists to be checked against another tool, which is what ``font`` is for.
    A plain ``QLabel`` cannot be copied out of at all, and wraps nothing, so a
    complaint of any length would run off the side of the dialog.
    """
    label = QLabel(text)
    label.setWordWrap(True)
    label.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
    if font is not None:
        label.setFont(font)
    return label


def open_folder(folder: Path) -> bool:
    """Show ``folder`` in the desktop's file manager, making it first if it is
    not there yet.

    Reports whether the handover worked, and never raises: both ways it can
    fail are ordinary, and a slot is not a place an exception has anywhere to
    go. The folder may be uncreatable -- a project on read-only media -- and
    there may be no file manager to hand it to, which is the case under Qt's
    offscreen platform and is not guaranteed on a bare Linux desktop either.
    """
    try:
        folder.mkdir(parents=True, exist_ok=True)
    except OSError:
        return False
    return QDesktopServices.openUrl(QUrl.fromLocalFile(str(folder)))


def open_file(path: Path) -> bool:
    """Hand ``path`` to whatever the desktop opens that kind of file with.

    What "edit this by hand" means in practice: an asm author already has an
    editor and wants this file in it, so the application's job is to get out of
    the way rather than to grow a text editor of its own.

    Reports whether the handover worked and never raises, for
    :func:`open_folder`'s reasons -- there may be nothing registered for the
    file, which is the case under Qt's offscreen platform -- with the one
    addition that a file that is not there is refused before asking, since the
    desktop's answer to that is a dialog nobody asked for.
    """
    if not path.is_file():
        return False
    return QDesktopServices.openUrl(QUrl.fromLocalFile(str(path)))


class WheelNeedsFocus:
    """A control the wheel only moves while it has the keyboard.

    Qt's own combo boxes and spin boxes step on a wheel notch under the
    pointer, focused or not, and a control in a dialog like these writes its
    value the moment it moves. So a wheel rolled across the dialog on the way
    somewhere else would make an edit, and the only sign would be a readout
    nobody was looking at yet. Unfocused, the notch is passed on instead -- to
    a scroll area if there ever is one, and to nothing otherwise.

    The focus policy goes with it: without it the wheel *takes* the focus and
    the guard would only ever turn away the first notch.
    """

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

    def wheelEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        if self.hasFocus():
            super().wheelEvent(event)
        else:
            event.ignore()


class ChoiceBox(WheelNeedsFocus, QComboBox):
    """A field whose value is one of a named set."""


class NumberBox(WheelNeedsFocus, QSpinBox):
    """A field whose value is a number."""
