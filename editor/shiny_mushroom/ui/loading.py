"""The modal the editor waits behind while a level opens.

Opening a level is a round trip to the emulator, and the first one of a
cartridge is three: the worker starts and boots the cart to the title screen,
the game's own loader runs the level, and a probe runs it far enough to capture
what the player looks like -- and only when the last of those lands is the level
really open: the document, the outlines *and* the spawn marker, which is where a
test run starts and what a middle click moves.

Nothing in that window can be edited. :meth:`MainWindow._commit` refuses while a
level is being opened, because an edit made then would apply to a level on its
way out or to one whose marker is not on it yet -- and it refused *silently*,
which is what this fixes. A modal says the editor is not ready, and being modal
is what makes the refusal a last line rather than the only one: the keystroke
never reaches the window in the first place.

**Every load that replaces the level**, not only the slow first one. Switching
levels is nearer a fifth of a second, and the status bar's bar and the disabled
view already say so -- but neither reaches the keyboard, and an arrow key or a
Delete typed into a level that is still arriving is refused in silence just the
same. The difference between the two loads is how long the window is out of
reach, not what happens to an edit made while it is. A **refresh** -- the reload
an edit itself asks for -- is not one of these and is never locked at all.

**Shown the moment the load starts, with no wait first.** The obvious economy is
``QProgressDialog``'s: hold it back a few hundred milliseconds so a load that
answers quickly never puts anything on the screen. What that buys is a modal
that does not flash on a fast switch; what it costs is a window at the start of
*every* load where the keyboard reaches an editor that will refuse it, which is
the whole defect this exists to close. The flash is the cheaper of the two, so
there is no threshold to tune and no interval in which an edit can be made and
turned away.

**Shown, never ``exec``'d.** What dismisses it is a reply from the loader's
thread, which arrives as a queued signal on the event loop that is already
running -- and a nested loop of its own is both unnecessary for that and the one
thing the suite cannot get out of, since ``exec()`` never returns under Qt's
offscreen platform.
"""

from __future__ import annotations

from PySide6.QtCore import Qt
from PySide6.QtGui import QCloseEvent
from PySide6.QtWidgets import QDialog, QLabel, QProgressBar, QVBoxLayout, QWidget

from shiny_mushroom import APP_NAME
from shiny_mushroom.hexnum import hexnum

#: What the dialog says while the worker starts, the cart boots and the game's
#: own loader runs the level. One line for all three: they are one wait as far
#: as anybody watching is concerned, and the emulator reports no progress
#: through them that could be shown.
BOOTING = "Starting the emulator and running the level loader."

#: And for every level after the first, where the emulator is already up and the
#: wait is the level loader alone. A separate line rather than the one above for
#: all of them, because a switch that claimed to be starting an emulator would be
#: describing work nobody is doing.
LOADING = "Running the level loader."

#: And while the probe that follows a cartridge's first level captures the
#: player. Named separately because it is the part that has no picture of its
#: own: the level is already on the canvas and the marker is what is missing.
CAPTURING = "Capturing the player for the start marker."

#: And while the world map is captured: the game's own overworld loader runs
#: once per submap palette, which is several short loads as one wait.
LOADING_WORLD = "Running the overworld loader."


class LevelLoadingDialog(QDialog):
    """An indeterminate wait with no way out of it.

    Indeterminate for the same reason the status bar's bar is: the emulator runs
    the cart's own loader and either finishes or does not, and a bar that crept
    along on a timer would be an invention.

    No way out because there is nothing to cancel. The request is with a thread
    that answers in order and cannot be told to abandon one, so a Cancel button
    would either lie or leave the editor holding half a level. It is dismissed
    by the load ending -- :meth:`finish` -- and by nothing else, which is why
    both the close button and Escape are taken off it.

    One dialog for the window's life rather than one per load: :meth:`begin` and
    :meth:`finish` put it up and take it down, and ``isVisible`` is therefore the
    whole of "is a load being covered".
    """

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setWindowTitle(f"{APP_NAME} - Opening a level")
        self.setModal(True)
        self.setWindowFlag(Qt.WindowType.WindowCloseButtonHint, False)

        self._heading = QLabel()
        self._status = QLabel()
        self._status.setWordWrap(True)
        self._progress = QProgressBar()
        self._progress.setRange(0, 0)
        self._progress.setTextVisible(False)

        layout = QVBoxLayout(self)
        layout.addWidget(self._heading)
        layout.addWidget(self._status)
        layout.addWidget(self._progress)

    @property
    def status(self) -> str:
        """Which part of the load it is reporting."""
        return self._status.text()

    def begin(self, level: int, booting: bool = False) -> None:
        """Cover ``level``'s load, from the moment it is asked for.

        ``booting`` is the cartridge's first level, where the wait includes the
        worker starting and the cart running to the title screen.
        """
        self._heading.setText(f"Opening level {hexnum(level, 3)}.")
        self.report(BOOTING if booting else LOADING)
        self.show()
        self.raise_()

    def begin_overworld(self) -> None:
        """Cover the world map's capture, from the moment it is asked for."""
        self._heading.setText("Opening the world map.")
        self.report(LOADING_WORLD)
        self.show()
        self.raise_()

    def report(self, what: str) -> None:
        """Change the line under the heading."""
        self._status.setText(what)

    def finish(self) -> None:
        """Let the level go. Safe when it was never up."""
        self.hide()

    def reject(self) -> None:
        """Refuse Escape. There is nothing to cancel; see the class docstring."""

    def closeEvent(self, event: QCloseEvent) -> None:  # noqa: N802 - Qt's name
        """And refuse the window manager, for the same reason.

        :meth:`finish` hides rather than closes, so this never turns a finished
        load away.
        """
        event.ignore()


__all__ = ["BOOTING", "CAPTURING", "LOADING", "LOADING_WORLD", "LevelLoadingDialog"]
