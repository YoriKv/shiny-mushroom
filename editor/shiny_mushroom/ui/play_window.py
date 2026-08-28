"""The window a level is tested in.

Opened from the editor with the level that is on the canvas and whatever edits
exist only in memory, so what is played is what is being looked at -- including
changes that have never reached a file. It is handed a
:class:`~shiny_mushroom.ui.play.PlayController`, which owns a second emulator
worker with a second core; the editor's own loader keeps running untouched in
its own process, so testing a level does not cost the picture of it.

**Handed one rather than building one, and it never shuts one down.** The
emulator behind a run is booted when the cartridge is opened and belongs to the
editor, which is what makes the window cheap to open and cheap to close: the
three seconds a cold worker costs have already been spent by the time Test
Level is pressed, and closing the window puts the session down
(:meth:`~shiny_mushroom.ui.play.PlayController.idle`) rather than throwing the
boot away.

The window is deliberately small in what it offers. Restart, pause, and a
loadout -- the three things somebody testing a level reaches for. Everything
else about the run comes from the cart.
"""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass, field
from pathlib import Path

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QAction, QCloseEvent, QKeyEvent, QKeySequence
from PySide6.QtWidgets import QComboBox, QLabel, QMainWindow, QToolBar, QWidget

from shiny_mushroom import APP_NAME
from shiny_mushroom.addresses import MODE_IN_LEVEL
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.overworld_snapshot import MODE_OVERWORLD
from shiny_mushroom.play_request import Buttons, PlayerState
from shiny_mushroom.ui.dialogs import warn
from shiny_mushroom.ui.play import PlayController
from shiny_mushroom.ui.screen import DEFAULT_SCALE, FRAME_HEIGHT, FRAME_WIDTH, Screen

#: Keyboard to pad. The arrows-plus-ZX layout every SNES emulator has shipped
#: with for twenty years, so a player's hands already know it: Z and X are the
#: buttons nearest the left hand and get the two Mario uses constantly -- Y to
#: run and spin, B to jump.
#:
#: Keyed by plain ``int`` rather than by ``Qt.Key``: a key event can carry a
#: value that is not in the enum at all, and converting one to look it up raises
#: instead of missing.
KEY_MAP: dict[int, Buttons] = {
    int(key): button
    for key, button in (
        (Qt.Key.Key_Up, Buttons.UP),
        (Qt.Key.Key_Down, Buttons.DOWN),
        (Qt.Key.Key_Left, Buttons.LEFT),
        (Qt.Key.Key_Right, Buttons.RIGHT),
        (Qt.Key.Key_Z, Buttons.Y),
        (Qt.Key.Key_X, Buttons.B),
        (Qt.Key.Key_A, Buttons.X),
        (Qt.Key.Key_S, Buttons.A),
        (Qt.Key.Key_Q, Buttons.L),
        (Qt.Key.Key_W, Buttons.R),
        (Qt.Key.Key_Return, Buttons.START),
        (Qt.Key.Key_Enter, Buttons.START),
        (Qt.Key.Key_Shift, Buttons.SELECT),
    )
}


def held_after(held: Buttons, key: int, down: bool) -> Buttons:
    """What is held once ``key`` goes down or comes up.

    Separated out because it is the only arithmetic in this window and the one
    thing that has to be right for a level to be controllable: the pad is told
    what is *down*, not what changed, so a button dropped from this set is a
    button nothing will ever release.
    """
    button = KEY_MAP.get(key)
    if button is None:
        return held
    return Buttons(held | button if down else held & ~button)


#: What the powerup picker offers, in the order the game numbers them.
POWERUPS = (("Small", 0), ("Big", 1), ("Cape", 2), ("Fire", 3))

#: Yoshi colours, as ``$7E0DC1`` holds them. Zero is no Yoshi, and the four
#: colours are the sprite numbers of the Yoshis the game carries between levels.
YOSHIS = (("No Yoshi", 0), ("Green Yoshi", 4), ("Yellow", 5), ("Blue", 6), ("Red", 7))

#: The one game mode that means "still in the level", and deliberately not
#: :data:`~shiny_mushroom.header.LEVEL_MODES`, which also counts the two the
#: loader passes through on its way in. The status bar is reporting whether the
#: run is *playable*, and a fade is not: anything else -- the death fade, the
#: overworld, a bonus game -- is said rather than quietly carried on through.
PLAYING_MODE = MODE_IN_LEVEL


@dataclass(frozen=True)
class OverworldRun:
    """Everything a world-map test run is made of.

    The editor computes all of it -- the save tables from its marks, the spawn
    from its marker, the patches from its documents -- and this window only
    carries it to the controller, the same division of labour a level's
    patches get.
    """

    submap: int
    x: int
    y: int
    tile_settings: bytes
    event_flags: bytes
    patches: Mapping[int, bytes] = field(default_factory=dict)


class PlayWindow(QMainWindow):
    """A running level, its controls, and the keyboard that drives it."""

    #: The window is closing. The editor listens so it can drop its reference
    #: and take the session back -- the worker is not going anywhere, and the
    #: next run is asked of the machine this one left.
    closed = Signal()

    def __init__(
        self,
        session: PlayController,
        rom: Path,
        level: int | None,
        patches: Mapping[int, bytes] | None = None,
        parent: QWidget | None = None,
        *,
        overworld: OverworldRun | None = None,
    ) -> None:
        super().__init__(parent)
        self._rom = rom
        self._level = level if level is not None else 0
        # Includes the entrance patch when the editor has been told to start
        # somewhere other than the level's own entrance: a start is a cartridge
        # edit like any other, and this window neither knows nor decides that.
        self._patches = dict(patches or {})
        #: When set, the window is testing the world map rather than a level;
        #: :meth:`test` and :meth:`test_overworld` switch it either way.
        self._overworld = overworld
        self._buttons = Buttons.NONE
        self._closing = False

        self.screen = Screen()
        self.setCentralWidget(self.screen)

        self._build_toolbar()
        # Both permanent, so neither is covered by the loading and completion
        # lines the status bar shows over them. The notice is what this run
        # could not be made to carry (:meth:`set_notice`); the readout is
        # where the game is and how fast.
        self._notice = QLabel()
        self._notice.setVisible(False)
        self.statusBar().addPermanentWidget(self._notice)
        self._status = QLabel()
        self.statusBar().addPermanentWidget(self._status)

        self.setWindowTitle(self._title())
        self.resize(FRAME_WIDTH * DEFAULT_SCALE + 24, FRAME_HEIGHT * DEFAULT_SCALE + 96)
        # The screen takes the keyboard, so arrows and Z do not go to the
        # toolbar's combo boxes -- which would step through powerups instead of
        # moving the player.
        self.screen.setFocusPolicy(Qt.FocusPolicy.StrongFocus)
        self.screen.setFocus()

        self._apply_run_chrome()
        self._controller = session
        self._controller.entered.connect(self._entered)
        self._controller.frame.connect(self.screen.set_frame)
        self._controller.status.connect(self._show_status)
        self._controller.beaten.connect(self._beaten)
        self._controller.failed.connect(self._failed)
        # Through the same door a Restart goes through, and saying the same
        # thing: the window no longer starts an emulator, so there is no
        # starting-one to report -- what is being waited for is the level,
        # whether or not the boot behind it has already happened.
        self.restart()

    def _title(self) -> str:
        what = "the world map" if self._overworld else hexnum(self._level, 3)
        return f"Testing {what} - {self._rom.name} - {APP_NAME}"

    # -- construction -------------------------------------------------------

    def _build_toolbar(self) -> None:
        bar = QToolBar("Test", self)
        bar.setObjectName("play-bar")
        bar.setMovable(False)
        self.addToolBar(Qt.ToolBarArea.TopToolBarArea, bar)

        self._restart_action = QAction("&Restart", self)
        self._restart_action.setShortcut(QKeySequence("Ctrl+R"))
        self._restart_action.triggered.connect(self.restart)
        bar.addAction(self._restart_action)

        self._pause_action = QAction("&Pause", self)
        self._pause_action.setShortcut(QKeySequence("F6"))
        self._pause_action.setCheckable(True)
        self._pause_action.toggled.connect(self._set_paused)
        bar.addAction(self._pause_action)

        bar.addSeparator()
        #: The loadout half of the toolbar, hidden on a world-map run --
        #: powerups mean nothing while nobody is in a level -- and the
        #: completion half, hidden on a level run for the mirrored reason.
        self._loadout_actions: list[QAction] = []
        self._powerup = self._picker(bar, "Power ", POWERUPS)
        self._yoshi = self._picker(bar, " ", YOSHIS)

        self._complete_action = QAction("Complete &Level", self)
        self._complete_action.setShortcut(QKeySequence("F7"))
        self._complete_action.triggered.connect(lambda: self._complete(False))
        bar.addAction(self._complete_action)
        self._secret_action = QAction("Secret E&xit", self)
        self._secret_action.setShortcut(QKeySequence("Shift+F7"))
        self._secret_action.triggered.connect(lambda: self._complete(True))
        bar.addAction(self._secret_action)

    def _picker(self, bar: QToolBar, label: str, entries) -> QComboBox:
        """A combo that changes the player's loadout where they stand.

        Applied immediately rather than at the next restart, because the reason
        to want a cape is usually the jump directly in front of you.
        """
        self._loadout_actions.append(bar.addWidget(QLabel(label)))
        combo = QComboBox()
        for text, value in entries:
            combo.addItem(text, value)
        # Never keyboard-focusable: the keys that step a combo are the keys that
        # move the player.
        combo.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        combo.activated.connect(lambda _index: self._send_loadout())
        self._loadout_actions.append(bar.addWidget(combo))
        return combo

    def _apply_run_chrome(self) -> None:
        """Show the controls that mean something for this kind of run."""
        world = self._overworld is not None
        for action in self._loadout_actions:
            action.setVisible(not world)
        self._complete_action.setVisible(world)
        self._secret_action.setVisible(world)

    def set_notice(self, text: str, detail: str = "") -> None:
        """Say what this run is *not* showing, for as long as it is not.

        The editor patches its held edits into the cartridge the run boots
        (:meth:`~shiny_mushroom.ui.main_window.MainWindow.test_patches`), and
        a part that has outgrown the room the image gives it cannot be patched
        in -- so the run shows the cartridge's own and the edit is invisible
        here while standing on the canvas. Somebody who is not told that reads
        it as the test window ignoring their work.

        Standing rather than transient, and in **this** window rather than the
        editor's status bar: this window opens over that one, and the fact
        stays true for the whole run. ``""`` takes it back down.
        """
        self._notice.setText(text)
        self._notice.setToolTip(detail or text)
        self._notice.setVisible(bool(text))

    # -- the session --------------------------------------------------------

    @property
    def player(self) -> PlayerState:
        """The loadout the toolbar currently describes."""
        return PlayerState(
            powerup=self._powerup.currentData(), yoshi=self._yoshi.currentData()
        )

    def test(self, level: int, patches: Mapping[int, bytes]) -> None:
        """Play ``level`` with these edits, replacing whatever is running.

        How an already-open window is reused. It takes the level as well as the
        edits because the editor's canvas may well have moved on since it was
        opened, and restarting the level somebody is no longer looking at is
        worse than not reusing the window at all. Reused across run kinds too:
        a window that was testing the world map becomes a level's.
        """
        self._level = level
        self._patches = dict(patches)
        self._overworld = None
        self._apply_run_chrome()
        self.setWindowTitle(self._title())
        self.restart()

    def test_overworld(self, run: OverworldRun) -> None:
        """Walk the world map as ``run`` describes it, replacing whatever is
        running -- :meth:`test`'s sibling for the other kind of run."""
        self._overworld = run
        self._apply_run_chrome()
        self.setWindowTitle(self._title())
        self.restart()

    def restart(self) -> None:
        """Load the run again, with whatever edits are held now."""
        what = "the world map" if self._overworld else f"level {hexnum(self._level, 3)}"
        self.statusBar().showMessage(f"Loading {what}...")
        self._request()

    def _request(self) -> None:
        self._pause_action.setChecked(False)
        self._release_keys()
        if self._overworld is not None:
            run = self._overworld
            self._controller.enter_overworld(
                run.submap,
                run.x,
                run.y,
                run.tile_settings,
                run.event_flags,
                dict(run.patches),
            )
            return
        self._controller.enter(
            self._level,
            self._patches,
            {"player": vars(self.player)},
        )

    def _entered(self, entry: dict) -> None:
        how = "restored" if entry.get("reused") else "loaded"
        what = (
            "World map"
            if self._overworld
            else f"Level {hexnum(entry.get('level', self._level), 3)}"
        )
        self.statusBar().showMessage(
            f"{what} {how} in {entry.get('duration', 0.0) * 1000:.0f} ms",
            4000,
        )
        self.screen.setFocus()

    def _complete(self, secret: bool) -> None:
        """Beat the level the player stands on, so its map event plays."""
        self._controller.beat_level(secret)
        self.screen.setFocus()

    def _beaten(self, result: dict) -> None:
        if not result.get("done"):
            reason = result.get("message", "refused")
            self.statusBar().showMessage(f"Cannot complete: {reason}", 4000)
            return
        translevel = int(result.get("translevel", 0))
        event = result.get("event")
        played = "no event to play" if event is None else f"event {hexnum(event)}"
        self.statusBar().showMessage(
            f"Beat translevel {hexnum(translevel)} -- {played}", 4000
        )

    def _send_loadout(self) -> None:
        self._controller.set_loadout(vars(self.player))
        self.screen.setFocus()

    def _set_paused(self, paused: bool) -> None:
        self._pause_action.setText("Resu&me" if paused else "&Pause")
        if paused:
            # A held button that is never released because the game stopped
            # reading is a button still held when it starts again.
            self._release_keys()
        self._controller.set_paused(paused)
        self.screen.setFocus()

    def _show_status(self, status: dict) -> None:
        mode = int(status.get("game_mode", 0))
        # A world-map run walks into levels and back out -- that is what it is
        # for -- so both of its steady states get said by name.
        if mode == PLAYING_MODE:
            where = "in the level"
        elif self._overworld and mode == MODE_OVERWORLD:
            where = "on the map"
        else:
            where = f"game mode {hexnum(mode)}"
        rate = float(status.get("fps", 0.0))
        state = "paused" if status.get("paused") else f"{rate:.0f} fps"
        self._status.setText(f"{where}    {state}")

    def _failed(self, message: str) -> None:
        if self._closing:
            # Shutting down races the pump; a worker that goes away while the
            # window is closing is the window closing, not a failure.
            return
        self.statusBar().clearMessage()
        what = "world map" if self._overworld else "level"
        self._alert(f"The {what} could not be tested.", detail=message)
        self.close()

    # -- the keyboard -------------------------------------------------------

    def keyPressEvent(self, event: QKeyEvent) -> None:  # noqa: N802 - Qt override
        if event.isAutoRepeat() or not self._hold(event.key(), True):
            super().keyPressEvent(event)

    def keyReleaseEvent(self, event: QKeyEvent) -> None:  # noqa: N802 - Qt override
        if event.isAutoRepeat() or not self._hold(event.key(), False):
            super().keyReleaseEvent(event)

    def _hold(self, key: int, down: bool) -> bool:
        """Press or release one mapped key. False if it is not one of ours."""
        if key not in KEY_MAP:
            return False
        held = held_after(self._buttons, key, down)
        if held is not self._buttons:
            self._buttons = held
            self._controller.set_buttons(int(held))
        return True

    def _release_keys(self) -> None:
        """Let go of everything. Used whenever the window stops watching keys.

        Losing focus mid-jump would otherwise leave the button held: the pad is
        told what is down, not what changed, so nothing ever arrives to say
        the key came back up.
        """
        if self._buttons is not Buttons.NONE:
            self._buttons = Buttons.NONE
            self._controller.set_buttons(0)

    def focusOutEvent(self, event) -> None:  # noqa: N802, ANN001 - Qt override
        self._release_keys()
        super().focusOutEvent(event)

    # -- shutdown -----------------------------------------------------------

    def _alert(self, message: str, *, detail: str = "") -> None:
        """This window's one modal failure surface.

        Its own method rather than the main window's, because a test drives one
        window at a time and the method is the seam it replaces -- see
        :mod:`shiny_mushroom.ui.dialogs` for why the seam is a method at all.
        """
        warn(self, message, detail=detail)

    def closeEvent(self, event: QCloseEvent) -> None:  # noqa: N802 - Qt override
        """Put the session down and let the editor have it back.

        Not shut down: the worker is the editor's, and the boot in it is what
        the next run would otherwise wait three seconds for. What closing does
        is stop the pump and pause the machine -- and take this window off the
        session's signals first, so a frame in flight is not delivered to a
        window on its way out.

        Once, whatever asks: a second close event over a window that has
        already given the session back would disconnect what is no longer
        connected, which raises.
        """
        if self._closing:
            super().closeEvent(event)
            return
        self._closing = True
        self._controller.entered.disconnect(self._entered)
        self._controller.frame.disconnect(self.screen.set_frame)
        self._controller.status.disconnect(self._show_status)
        self._controller.beaten.disconnect(self._beaten)
        self._controller.failed.disconnect(self._failed)
        self._controller.idle()
        self.closed.emit()
        super().closeEvent(event)
