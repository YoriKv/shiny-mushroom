"""`The cartridge raised an exception`: what a ``BRK`` says, in a window.

The editor's answer to the BRK Exception Handler patch. That patch is asm a
hack puts *in its own cartridge* so that a ``BRK`` paints its registers on the
SNES screen instead of hanging the console; this is the same report, read off
the emulator by :mod:`shiny_mushroom.brk` and shown here -- so a project gets it
without carrying a handler, and gets it from the editor's own runs as well as
from a test.

**Two audiences, one window.** A test run's player is offered the choice the
patch never could: carry on past the ``BRK``, or stop. A render's is offered
nothing, because there is nothing left to decide -- the sprite that raised it
has already failed to draw and the level is already on the canvas. Which one
this is, is what ``resumable`` says.

The stack is behind a disclosure, because it is the only part that is long and
the only part most readers will not want: what a report is usually read for is
the first two lines, and those are at the top in the size they deserve.
"""

from __future__ import annotations

from PySide6.QtCore import QEvent, QSize, Qt
from PySide6.QtGui import QFont, QFontDatabase, QGuiApplication
from PySide6.QtWidgets import (
    QDialog,
    QDialogButtonBox,
    QGroupBox,
    QLabel,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

from shiny_mushroom.brk import BrkReport
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.ui.dialogs import selectable_label
from shiny_mushroom.ui.icon_font import palette_icon
from shiny_mushroom.ui.icons import Icon

#: What the window is called when a run is stopped at the ``BRK`` and when one
#: is merely being reported.
TITLE_STOPPED = "The test run hit a BRK"
TITLE_REPORT = "The cartridge hit a BRK"

#: What the byte after the opcode is, said once in the window that shows it.
#: The number is the only part of the exception that reaches the editor -- the
#: sentence that would explain it lives in the cartridge author's own handler --
#: so what it *is* has to be said, or the report shows a number and no way in.
SIGNATURE_HINT = (
    "BRK is two bytes: the opcode, and a second byte the processor fetches and "
    "ignores. Code that raises one puts its own exception number there, so this "
    "number means whatever the routine that raised it meant by it."
)

#: The disclosure's mark, in the box it is drawn in. Small: it sits at the head
#: of a line of the report, so it is read as the line's own bullet rather than
#: as a button of its own, and a mark the height of the text is what does that.
#: The face's own arrow icons would be sized for tree branches.
FOLD_MARK = QSize(12, 12)

#: What carrying on past a ``BRK`` does, said where the button is.
CONTINUE_HINT = (
    "Continue executes the BRK and lets the run go on, which lands wherever "
    "this cartridge's BRK vector points -- its own handler's screen, if it has "
    "one. Stop leaves the run where it is."
)


def mono() -> QFont:
    """The fixed font the readouts use, as the platform ships it."""
    return QFontDatabase.systemFont(QFontDatabase.SystemFont.FixedFont)


class BrkDialog(QDialog):
    """One report, shown. Answers whether the run was told to carry on."""

    def __init__(
        self,
        report: BrkReport,
        parent: QWidget | None = None,
        *,
        resumable: bool = False,
        others: int = 0,
    ) -> None:
        super().__init__(parent)
        self._report = report
        # Declared before the layout is built: a palette change during
        # construction reaches changeEvent before the stack section exists,
        # and a report without a stack never grows one.
        self._stack_toggle: QPushButton | None = None
        self.setWindowTitle(TITLE_STOPPED if resumable else TITLE_REPORT)
        self.setMinimumWidth(460)

        layout = QVBoxLayout(self)

        headline = selectable_label(f"BRK {hexnum(report.signature)} at {report.where}")
        heading_font = headline.font()
        heading_font.setBold(True)
        headline.setFont(heading_font)
        layout.addWidget(headline)

        layout.addWidget(selectable_label(report.message))
        if report.during:
            layout.addWidget(selectable_label(f"Raised while {report.during}."))
        if others:
            layout.addWidget(
                selectable_label(
                    f"{others} more exception{'s' if others > 1 else ''} were "
                    f"raised in the same pass; this is the first."
                )
            )

        hint = selectable_label(SIGNATURE_HINT)
        hint.setWordWrap(True)
        layout.addWidget(hint)

        layout.addWidget(self._registers(report))
        layout.addWidget(self._state(report))
        if report.stack:
            for widget in self._stack(report):
                layout.addWidget(widget)

        buttons = QDialogButtonBox()
        copy = QPushButton("&Copy")
        copy.setAutoDefault(False)
        copy.clicked.connect(self._copy)
        buttons.addButton(copy, QDialogButtonBox.ButtonRole.ActionRole)
        if resumable:
            # Rejecting is stopping, which is also what closing the window
            # means: a run nobody answered for is a run left where it stopped.
            buttons.addButton("&Continue", QDialogButtonBox.ButtonRole.AcceptRole)
            buttons.addButton("&Stop run", QDialogButtonBox.ButtonRole.RejectRole)
            note = selectable_label(CONTINUE_HINT)
            note.setWordWrap(True)
            layout.addWidget(note)
        else:
            buttons.addButton(QDialogButtonBox.StandardButton.Close)
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

    # -- the readouts ------------------------------------------------------

    def _registers(self, report: BrkReport) -> QGroupBox:
        """The processor, as it stood one instruction before the ``BRK``."""
        box = QGroupBox("Registers")
        inside = QVBoxLayout(box)
        rows = [
            f"A  {hexnum(report.a, 4)}    X  {hexnum(report.x, 4)}    "
            f"Y  {hexnum(report.y, 4)}",
            f"D  {hexnum(report.d, 4)}    B  {hexnum(report.db)}      "
            f"S  {hexnum(report.sp, 4)}",
            f"P  {hexnum(report.ps)}  {report.flags()}"
            + ("   emulation mode" if report.emulation else ""),
        ]
        if report.cpu != "SNES":
            rows.append(f"Ran on the {report.cpu}")
        inside.addWidget(self._block("\n".join(rows)))
        return box

    def _state(self, report: BrkReport) -> QGroupBox:
        """The game's own state: where the layers are, and what Mario is."""
        box = QGroupBox("The game")
        inside = QVBoxLayout(box)
        rows = [
            f"Layer {number}  {hexnum(x, 4)} {hexnum(y, 4)}"
            for number, (x, y) in enumerate(report.layers, start=1)
        ]
        rows.append(
            f"Powerup  {hexnum(report.powerup)}    "
            f"Game mode  {hexnum(report.game_mode)}"
        )
        inside.addWidget(self._block("\n".join(rows)))
        return box

    def _stack(self, report: BrkReport) -> tuple[QPushButton, QLabel]:
        """What had been pushed and not pulled, behind a disclosure.

        Folded away to start with: it is the longest part of the report and the
        least often wanted, and a window that opens at the size of its stack
        dump buries the two lines that say what happened. A flat toggle rather
        than a framed group, so a report nobody unfolds costs one line.
        """
        block = self._block("\n".join(report.stack_rows()))
        block.setVisible(False)
        toggle = QPushButton(report.stack_heading())
        toggle.setIconSize(FOLD_MARK)
        toggle.setCheckable(True)
        toggle.setFlat(True)
        toggle.setAutoDefault(False)
        toggle.setStyleSheet("text-align: left;")

        def unfold(open_: bool) -> None:
            block.setVisible(open_)
            self._mark_stack()
            # The window was sized for a folded dump, so it has to grow into
            # the one it is now showing rather than scroll it away.
            self.adjustSize()

        toggle.toggled.connect(unfold)
        self._stack_toggle = toggle
        self._stack_block = block
        self._mark_stack()
        return toggle, block

    def _mark_stack(self) -> None:
        """Put the disclosure's mark on the toggle, in the theme's own ink.

        Baked from the palette, so it is redrawn when the palette changes --
        the pixmap has the tint and the resolution in it.
        """
        toggle = self._stack_toggle
        if toggle is None:
            return
        toggle.setIcon(
            palette_icon(
                Icon.UNFOLDED if toggle.isChecked() else Icon.FOLDED,
                self.palette(),
                FOLD_MARK,
                self.devicePixelRatioF() or 1.0,
            )
        )

    def changeEvent(self, event: QEvent) -> None:  # noqa: N802 - Qt override
        super().changeEvent(event)
        if event.type() == QEvent.Type.PaletteChange:
            self._mark_stack()

    def _block(self, text: str) -> QLabel:
        """One monospaced, selectable readout."""
        label = selectable_label(text, font=mono())
        label.setWordWrap(False)
        label.setTextFormat(Qt.TextFormat.PlainText)
        return label

    def _copy(self) -> None:
        """The whole report on the clipboard, as
        :meth:`~shiny_mushroom.brk.BrkReport.as_text` writes it."""
        clipboard = QGuiApplication.clipboard()
        if clipboard is not None:
            clipboard.setText(self._report.as_text())


def show_brk(
    parent: QWidget | None,
    report: BrkReport,
    *,
    resumable: bool = False,
    others: int = 0,
) -> bool:
    """Show ``report``. True if the run was told to carry on past the ``BRK``.

    False for every other ending, which is the safe reading of all of them:
    Stop, the window closed, and a report nobody was offered a choice about.
    """
    dialog = BrkDialog(report, parent, resumable=resumable, others=others)
    return bool(dialog.exec()) and resumable


__all__ = ["CONTINUE_HINT", "SIGNATURE_HINT", "BrkDialog", "show_brk"]
