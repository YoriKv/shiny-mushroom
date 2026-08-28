"""Running a level off the UI thread, sixty times a second.

The same arrangement as :mod:`~shiny_mushroom.ui.emulator`, out of the same
:class:`~shiny_mushroom.ui.emulator.SupervisorHost` and for the same reason:
:class:`~shiny_mushroom.emu.supervisor.PlaySupervisor` is blocking, and two of
its calls are long enough to freeze a window -- starting the worker and booting
the cart is a second or three, and entering a level is a third of a second.

What is different is that this one never stops. A loader is asked for a level
and answers once; a play session is asked for a picture every frame for as long
as the window is open. So the controller pumps **on its own thread**, and the
UI thread does nothing but draw what arrives and say which buttons are down.

**It also outlives the window.** The editor owns the session and the test
window borrows it: :meth:`PlayController.boot` starts the worker when the
cartridge is opened, so a run is asked of a machine that is already at the
title screen, and :meth:`PlayController.idle` puts it down when the window
closes rather than shutting it. Both ends of that are the same fact -- the
boot is three of the three and a bit seconds a cold run costs and has nothing
to do with which level was asked for, so it is worth paying early and worth
keeping. What ends a session is the cartridge changing;
:mod:`shiny_mushroom.ui.window.testing` is where that is decided.

The pump is a **long poll**: each round trip carries the buttons over and then
blocks until the worker latches the next frame, so frames arrive at the
emulator's own 16.7 ms cadence rather than at the beat frequency between it
and a poll timer -- measured, the polled version delivered frames in
alternating 12/24 ms steps. Pacing therefore lives with the frame source, and
this side just goes again the moment the event loop has drained.

Latency, since it is the one thing a design like this can get wrong: a key
press crosses to the pump thread as a queued call, waits for the in-flight
reply -- a frame period while the game runs, the wait's 30 ms bound when the
screen is still -- and is on the emulated pad with the next request. That is a
frame, occasionally two, which is a real console's own polling granularity.
"""

from __future__ import annotations

import logging
import time
from collections.abc import Iterable, Mapping
from pathlib import Path

from PySide6.QtCore import Qt, QTimer, Signal, Slot

from shiny_mushroom.emu.supervisor import PlaySupervisor
from shiny_mushroom.ui.emulator import SupervisorHost

_log = logging.getLogger(__name__)

#: How long the pump rests between round trips: not at all. The pump is a
#: **long poll** -- the worker holds each reply open until the next frame
#: lands (:data:`~shiny_mushroom.emu.play.FRAME_WAIT` bounds the hold) -- so
#: the pacing lives on the worker's side and the right cadence here is
#: "again, as soon as the event loop has drained". A zero-interval timer is
#: exactly that: each pump blocks in the pipe read for a frame period, and
#: queued button and pause changes get their turn between iterations. A
#: nonzero interval here would re-create the very beat frequency against the
#: emulator's 16.7 ms cadence that the long poll exists to remove.
PUMP_INTERVAL_MS = 0

#: How often the frame rate readout is recomputed, in seconds.
RATE_WINDOW = 0.5


class PlayController(SupervisorHost):
    """One play session, on one thread, pumped by a timer that lives there.

    Built by the editor rather than by the window that shows it, and kept for
    as long as the cartridge it booted is the open one -- see the module
    docstring.
    """

    #: The level is up and running. Carries the worker's reply: level, duration,
    #: whether a savestate was reused, and the game mode it ended in.
    entered = Signal(dict)

    #: A new picture: pixels, width, height.
    frame = Signal(object, int, int)

    #: Once a pump interval: ``{"game_mode": int, "paused": bool, "fps": float}``.
    status = Signal(dict)

    #: A "beat this level" request was answered -- with the event now playing,
    #: or with the reason it was refused. See
    #: :meth:`~shiny_mushroom.emu.play.PlaySession.complete_level`.
    beaten = Signal(dict)

    #: Something went wrong and the session is over. Nothing is retried -- see
    #: :class:`~shiny_mushroom.emu.supervisor.PlaySupervisor`.
    failed = Signal(str)

    # -- requests, crossed to the play thread --------------------------------
    #
    # The window calls the plain methods below on the UI thread; each emits
    # one of these, and the auto connection -- receiver on the play thread,
    # emitter elsewhere -- delivers the matching slot over there. The signals
    # are what keep every blocking supervisor call, the pump timer and all of
    # this object's state on the one thread it exists for: a direct call
    # would run on the caller's thread instead, freezing the window for the
    # length of a boot, parenting the timer where a held-open menu or a
    # window drag starves it, and turning the pump's fields into shared
    # state.
    _boot_requested = Signal()
    _enter_requested = Signal(int, object, object)
    _overworld_requested = Signal(int, int, int, object, object, object)
    _beat_requested = Signal(bool)
    _buttons_requested = Signal(int)
    _paused_requested = Signal(bool)
    _loadout_requested = Signal(object)
    _idle_requested = Signal()

    def __init__(
        self,
        rom: Path,
        *,
        audio: bool = True,
        base_id: str | None = None,
        target_id: str | None = None,
        role_addresses: Mapping[str, int] | None = None,
        features: Iterable[str] = (),
        role_counts: Mapping[str, int] | None = None,
    ) -> None:
        super().__init__(
            PlaySupervisor(
                rom,
                audio=audio,
                base_id=base_id,
                target_id=target_id,
                role_addresses=role_addresses,
                features=features,
                role_counts=role_counts,
            ),
            "shiny-mushroom-play",
        )
        self._timer: QTimer | None = None
        self._buttons = 0
        self._seen = 0
        self._paused: bool | None = None
        self._stopped = False
        self._rate_at = 0.0
        self._rate_from = 0
        self._fps = 0.0
        self._boot_requested.connect(self._boot)
        self._enter_requested.connect(self._enter)
        self._overworld_requested.connect(self._enter_overworld)
        self._beat_requested.connect(self._beat_level)
        self._buttons_requested.connect(self._set_buttons)
        self._paused_requested.connect(self._set_paused)
        self._loadout_requested.connect(self._set_loadout)
        self._idle_requested.connect(self._idle)
        # ``finished`` is emitted from the ending thread itself, so a direct
        # connection runs :meth:`_halt` there -- the one thread a timer may be
        # stopped from. Without this the timer is still active when the
        # thread dies, and destroying it later from the UI thread warns.
        self._thread.finished.connect(self._halt, Qt.ConnectionType.DirectConnection)
        self._start()

    # -- requests from the window ------------------------------------------

    def boot(self) -> None:
        """Start the worker and boot the cartridge, before there is a run.

        Everything a first run waits for that has nothing to do with which
        level was asked for: the process, the core, the ROM and the cart's own
        boot to the title screen -- three seconds of the three and a bit a
        cold run costs, against a fifth for the level itself. Asked for when
        the cartridge is opened, so the wait is spent while somebody is
        looking at their level rather than at a black screen.

        Returns at once; the boot happens on the play thread.
        """
        self._boot_requested.emit()

    def enter(
        self,
        level: int,
        patches: Mapping[int, bytes] | None,
        options: Mapping[str, object] | None,
    ) -> None:
        """Ask for ``level``. Returns at once; the reply is :attr:`entered`."""
        self._enter_requested.emit(level, patches, options)

    def enter_overworld(
        self,
        submap: int,
        x: int,
        y: int,
        tile_settings: bytes,
        event_flags: bytes,
        patches: Mapping[int, bytes] | None,
    ) -> None:
        """Ask for the world map. Returns at once; the reply is
        :attr:`entered`."""
        self._overworld_requested.emit(
            submap, x, y, tile_settings, event_flags, patches
        )

    def beat_level(self, secret: bool) -> None:
        """Ask to beat the level underfoot. The reply is :attr:`beaten`."""
        self._beat_requested.emit(bool(secret))

    def set_buttons(self, buttons: int) -> None:
        """Hold exactly these buttons, from the next pump on."""
        self._buttons_requested.emit(int(buttons))

    def set_paused(self, paused: bool) -> None:
        self._paused_requested.emit(bool(paused))

    def set_loadout(self, player: Mapping[str, object]) -> None:
        """Change the powerup and the rest without reloading the level."""
        self._loadout_requested.emit(dict(player))

    def idle(self) -> None:
        """Stop pumping and leave the machine paused, still booted.

        What a window does on its way out instead of shutting the session
        down. The boot behind a run is the same boot the next run wants, so
        closing the test window costs the picture rather than the emulator --
        and the savestate the worker took when the level became playable is
        still there, which is what makes the run after a close a restore.

        Paused rather than merely unwatched, because a game nobody is looking
        at is still a game making noise and burning a core.
        """
        self._idle_requested.emit()

    # -- on the play thread ------------------------------------------------

    @Slot()
    def _boot(self) -> None:
        """Start the worker and boot the cart. Runs on the play thread.

        **Quiet when it does not take.** Nothing has been asked for yet, and
        the supervisor starts a fresh worker per request -- so a boot that
        failed costs the run that follows it the boot it would have paid
        anyway, and that run reports the failure where somebody is waiting for
        an answer.
        """
        if self._stopped:
            return
        try:
            self._supervisor.start()
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            _log.debug("the play worker did not boot ahead of a run: %s", error)

    @Slot(int, object, object)
    def _enter(
        self,
        level: int,
        patches: Mapping[int, bytes] | None,
        options: Mapping[str, object] | None,
    ) -> None:
        """Load ``level`` and start pumping. Runs on the play thread.

        Also the restart path: entering again while a level is running replaces
        it, which is what "test it again with the edit I just made" means.
        """
        if self._stopped:
            return
        try:
            entry = self._supervisor.enter_level(level, patches, options)
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            self.failed.emit(str(error))
            return
        # The picture is about to be a different level's, so the last sequence
        # number seen belongs to nothing. Asking for 0 gets the next frame
        # whatever its number.
        self._seen = 0
        self._paused = False
        self.entered.emit(entry)
        self._start_timer()

    @Slot(int, int, int, object, object, object)
    def _enter_overworld(
        self,
        submap: int,
        x: int,
        y: int,
        tile_settings: bytes,
        event_flags: bytes,
        patches: Mapping[int, bytes] | None,
    ) -> None:
        """Boot onto the world map and start pumping.

        :meth:`_enter`'s overworld sibling, and the same restart path: entering
        again replaces whatever is running, map or level.
        """
        if self._stopped:
            return
        try:
            entry = self._supervisor.enter_overworld(
                submap, x, y, tile_settings, event_flags, patches
            )
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            self.failed.emit(str(error))
            return
        self._seen = 0
        self._paused = False
        self.entered.emit(entry)
        self._start_timer()

    @Slot(bool)
    def _beat_level(self, secret: bool) -> None:
        """Beat the level the player stands on, so its map event plays."""
        if self._stopped:
            return
        try:
            result = self._supervisor.beat_level(secret)
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            self.failed.emit(str(error))
            return
        self.beaten.emit(result)

    @Slot(int)
    def _set_buttons(self, buttons: int) -> None:
        """Hold exactly these buttons. Sent with the next pump."""
        self._buttons = int(buttons)

    @Slot(bool)
    def _set_paused(self, paused: bool) -> None:
        self._paused = bool(paused)

    @Slot(object)
    def _set_loadout(self, player: Mapping[str, object]) -> None:
        """Change the powerup and the rest without reloading the level."""
        if self._stopped:
            return
        try:
            self._supervisor.set_loadout(player)
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            self.failed.emit(str(error))

    @Slot()
    def _idle(self) -> None:
        """Pause the machine and stop pumping. Runs on the play thread.

        The pause rides a pump like every other one -- it is what the worker
        reads it from -- so one goes over with nothing held before the timer
        stops. A session that was never entered has no pump to stop and is
        left exactly as it is: asking one for a frame would start the very
        worker this is putting down.
        """
        if self._stopped or self._timer is None:
            return
        self._stop_timer()
        self._buttons = 0
        self._paused = True
        try:
            self._supervisor.pump(0, self._seen, True)
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            self.failed.emit(str(error))

    # -- the pump ----------------------------------------------------------

    def _start_timer(self) -> None:
        if self._timer is not None:
            return
        # Built here rather than in __init__ so that it belongs to the thread
        # that will service it. A QTimer created on the UI thread fires there,
        # which would put every pump back on the thread this class exists to
        # keep clear.
        self._timer = QTimer(self)
        # At a zero interval the timer fires whenever the event loop is idle,
        # so its precision hardly matters -- the frame wait inside each pump
        # is what paces the loop. Precise is kept anyway: it is free, and a
        # coarse timer's batching would add a wakeup's slack to the one place
        # this thread is not already blocked.
        self._timer.setTimerType(Qt.TimerType.PreciseTimer)
        self._timer.timeout.connect(self._pump)
        self._timer.start(PUMP_INTERVAL_MS)

    @Slot()
    def _pump(self) -> None:
        if self._stopped:
            return
        paused, self._paused = self._paused, None
        try:
            header, pixels = self._supervisor.pump(self._buttons, self._seen, paused)
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            self._halt()
            self.failed.emit(str(error))
            return
        sequence = int(header.get("sequence", self._seen))
        if pixels is not None:
            self._seen = sequence
            self.frame.emit(pixels, int(header["width"]), int(header["height"]))
        self.status.emit(
            {
                "game_mode": header.get("game_mode", 0),
                "paused": header.get("paused", False),
                "fps": self._rate(int(header.get("presented", sequence))),
            }
        )

    def _rate(self, sequence: int) -> float:
        """Frames a second, from the emulator's delivery counter.

        Counted from ``presented`` -- every frame the emulator handed over,
        duplicates included -- so the number reads as *emulator* health: a
        steady 60 when pacing is right. Deliberately not the distinct-picture
        count: vanilla SMW drops frames to its own slowdown and a menu shows
        the same picture for seconds, and a readout that sagged for either
        looked like a delivery problem while measuring the game. The lag
        itself is still visible where it belongs -- in the picture, exactly
        as on a console.
        """
        now = time.monotonic()
        if now - self._rate_at >= RATE_WINDOW:
            if self._rate_at:
                self._fps = (sequence - self._rate_from) / (now - self._rate_at)
            self._rate_at, self._rate_from = now, sequence
        return self._fps

    # -- shutdown ----------------------------------------------------------

    def _stop_timer(self) -> None:
        """Stop pumping, from the thread the timer belongs to."""
        if self._timer is not None:
            self._timer.stop()
            self._timer = None

    def _halt(self) -> None:
        self._stopped = True
        self._stop_timer()

    def shutdown(self) -> None:
        """Stop pumping, then stop the thread and close the worker as
        :meth:`~shiny_mushroom.ui.emulator.SupervisorHost.shutdown` does.

        The flag is set from here rather than only on the play thread because
        the point is to stop *before* the thread is asked to quit: a pump that
        starts after the quit is posted still runs to completion, and it is a
        pipe round trip on a worker that is about to be shut from under it.
        """
        self._stopped = True
        super().shutdown()
