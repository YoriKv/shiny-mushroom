"""Running level loads off the UI thread.

:class:`~shiny_mushroom.emu.supervisor.EmulatorSupervisor` is blocking by design --
it writes a request down a pipe and waits for the reply -- and the wait is long
enough to matter: about two seconds the first time, while the worker starts and
boots the cart to the title screen, and a fifth of a second for every load after
that. On the UI thread the first of those is an application that appears to have
crashed.

So the supervisor lives on a thread of its own and this class is the only thing
that touches it. Requests arrive as a queued signal and results leave the same
way, which is the whole reason the class exists: Qt marshals both across the
thread boundary, so nothing here needs a lock of its own.

The isolation is unrelated to the worker process. That one is about surviving a
segfault in native code; this one is about not blocking a repaint. They stack:
a crash costs a restart, and neither costs a frozen window.

The pairing itself -- a supervisor, the thread it is spoken to on, and winding
the two up together -- is :class:`SupervisorHost`, and the play window's pump in
:mod:`shiny_mushroom.ui.play` is its other user: the same arrangement for the
same reason, saying something else to a worker of its own.
"""

from __future__ import annotations

import logging
from collections.abc import Iterable, Mapping
from pathlib import Path

from PySide6.QtCore import QObject, QThread, Signal, Slot

from shiny_mushroom.emu.supervisor import BrkError, EmulatorSupervisor
from shiny_mushroom.project import cache_root

_log = logging.getLogger(__name__)

#: How long :meth:`SupervisorHost.shutdown` waits for an in-flight call to
#: finish before giving up on a clean stop. One bound for both hosts, and it is
#: the longest of the calls either makes: comfortably past a load, past the
#: worker's boot and past a play session's start, so closing a window during any
#: of them is not a hard stop.
SHUTDOWN_TIMEOUT_MS = 8000


class SupervisorHost(QObject):
    """A blocking supervisor, and the thread its calls are made on.

    What running the emulator for the canvas and running it for a play session
    have in common -- which is not the interesting part of either, and is the
    part that has to be right. A supervisor writes down a pipe and waits, so it
    lives on a thread of its own, the object that speaks to it is moved there,
    and the two are wound up together.

    **Parentless, deliberately**: an object with a parent cannot be moved to
    another thread, and Qt reports that at runtime rather than at construction.
    A subclass builds its supervisor, connects whatever it needs to the thread,
    and calls :meth:`_start` last.
    """

    def __init__(self, supervisor: EmulatorSupervisor, name: str) -> None:
        super().__init__()
        self._supervisor = supervisor
        self._thread = QThread()
        self._thread.setObjectName(name)

    def _start(self) -> None:
        """Move onto the thread and run it -- the last thing a subclass's
        ``__init__`` does, so nothing is still being connected once the thread
        is live."""
        self.moveToThread(self._thread)
        self._thread.start()

    def shutdown(self) -> None:
        """Stop the thread and close the worker. Safe to call twice.

        The thread is stopped first. Closing the supervisor while a call is
        still running would block on the lock that call is holding, and the
        wait is the bounded version of the same thing.

        **The worker is closed even when the bound ran out.** A wait that
        expired means a call is not coming back, and the choice is then between
        a pipe shut under it and a worker process that outlives the editor
        which started it. The second is worse: it holds a core, a window handle
        and a sound device, and nothing is left that would ever close it.
        """
        if self._thread.isRunning():
            self._thread.quit()
            self._thread.wait(SHUTDOWN_TIMEOUT_MS)
        self._supervisor.close()


class LevelLoader(SupervisorHost):
    """One emulator, on one thread, serving one level request at a time."""

    #: A level loaded. Carries the ``LevelSnapshot``, as ``object`` because Qt
    #: has no meta-type for it and does not need one to hand it across.
    loaded = Signal(object)

    #: A level did not load, with the reason already made presentable.
    failed = Signal(str)

    #: The probe came back, with a ``PlayerArt`` or with ``None``. Silent on
    #: failure as far as the user is concerned -- the marker is furniture, and a
    #: level that loaded is not worth an alert because the figure drawn on it
    #: could not be captured -- but it **arrives either way**, because the window
    #: holds the level locked until it does. See ``MainWindow._hold_player_art``.
    player_art_ready = Signal(object)

    #: A catalogue probe came back, as a ``LevelSnapshot`` of a level that is
    #: **not** the one on the canvas: it holds the whole tileset's objects laid
    #: out on a scratch grid, so its footprints say what each one draws.
    #:
    #: Its own signal rather than :attr:`loaded`, and that is the whole point --
    #: everything connected to `loaded` would otherwise draw the probe over the
    #: level the user is looking at.
    catalog_probed = Signal(object)

    #: Artwork for sprite numbers the level does not hold, as
    #: ``{number: tiles}``. Silent on failure: a preview that cannot be drawn is
    #: a row with no popup, which is already what an un-probed row looks like.
    sprite_art_ready = Signal(object)

    #: The overworld loaded. Carries the ``OverworldSnapshot``. Failures come
    #: back on :attr:`failed`, exactly as a level's do -- the window's handler
    #: unlocks either kind.
    overworld_loaded = Signal(object)

    #: The cartridge hit one or more ``BRK``\ s while answering a request,
    #: as a list of ``BrkReport``. Its own signal because it is orthogonal to
    #: every other one here: the same load can come back with a snapshot *and*
    #: an exception a custom sprite raised while being drawn, and the window
    #: has to show both.
    broke = Signal(object)

    def __init__(
        self,
        rom: Path,
        base_id: str | None = None,
        target_id: str | None = None,
        role_addresses: Mapping[str, int] | None = None,
        features: Iterable[str] = (),
        art_cache: Path | None = None,
        role_counts: Mapping[str, int] | None = None,
    ) -> None:
        # The application's cache directory unless a caller says otherwise. This
        # is where the choice belongs: the supervisor is a handle on a worker and
        # has no business knowing where this machine keeps its data, and the
        # window has no business knowing that a capture is worth keeping.
        super().__init__(
            EmulatorSupervisor(
                rom,
                base_id=base_id,
                target_id=target_id,
                role_addresses=role_addresses,
                features=features,
                art_cache=cache_root() if art_cache is None else art_cache,
                role_counts=role_counts,
            ),
            "shiny-mushroom-emu",
        )
        self._start()

    def _note_brks(self, error: BaseException | None = None) -> None:
        """Report whatever the request just answered ran into.

        Called after every request, failed or not, which is the only place that
        works: a ``BRK`` a load survived rides on the reply and one that
        stopped it rides on the exception, and the window wants them on the
        same signal either way.
        """
        reports = self._supervisor.taken_brks()
        if isinstance(error, BrkError):
            reports.append(error.report)
        if reports:
            self.broke.emit(reports)

    @Slot(int, object)
    def load(self, level: int, patches: dict[int, bytes] | None = None) -> None:
        """Load ``level``. Runs on the loader's thread, never on the caller's.

        ``patches`` is written over the emulator's own copy of the cartridge
        before the load and over nothing on disk -- which is how an edited level
        is drawn at all: the picture is made by running the game's own loader,
        so the only way to see an edit is to give the loader the edited bytes.
        See :func:`~shiny_mushroom.rom_patches.level_patch`.

        Nothing is raised out of here. This is the end of a queued call, so
        there is no caller left to catch anything -- an exception would reach
        Qt's unhandled-exception path and be printed to a console that a
        windowed build does not have.
        """
        try:
            # With footprints: the editor lets you click an object, and without
            # them a click only lands on the one block the record names. Worth
            # the extra ~80 ms here, where a level is being opened to work on.
            snapshot = self._supervisor.load_level(
                level, patches or None, footprints=True
            )
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            self._note_brks(error)
            self.failed.emit(str(error))
        else:
            self._note_brks()
            self.loaded.emit(snapshot)

    @Slot(object)
    def load_overworld(self, patches: dict[int, bytes] | None = None) -> None:
        """Capture the overworld, serialised with :meth:`load` by sharing its
        thread. Cached on the worker under ``patches`` -- the project's edited
        graphics, previewed the way :meth:`load` previews them -- so only the
        first request for a given set pays the seven short loads it costs."""
        try:
            snapshot = self._supervisor.load_overworld(patches=patches or None)
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            self._note_brks(error)
            self.failed.emit(str(error))
        else:
            self._note_brks()
            self.overworld_loaded.emit(snapshot)

    @Slot()
    def player_art(self) -> None:
        """Capture what the player looks like, once a level is up.

        Asked for after a level has loaded, because the probe needs one to run,
        and asked for once a cartridge: the answer does not vary with the level.
        Serialised with :meth:`load` by sharing its thread.

        Often no emulation at all: the supervisor keeps a capture per cartridge
        in the application's cache directory, so only the first launch over a
        given ROM pays the probe.

        **Answers even when it found nothing.** The window treats this as the
        second half of a cartridge's first load and keeps the level locked until
        it comes back, so a probe that failed quietly would leave the editor
        waiting on a reply that was never going to arrive.
        """
        try:
            art = self._supervisor.player_art()
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            _log.debug("no player artwork: %s", error)
            art = None
        self._note_brks()
        self.player_art_ready.emit(art or None)

    @Slot(int, object)
    def probe_catalog(self, level: int, patches: dict[int, bytes] | None) -> None:
        """Load a scratch level holding the whole tileset's objects at once.

        The same request :meth:`load` makes, with the object stream replaced --
        so one round trip yields what every object in the catalogue draws
        instead of one per object. It comes back on :attr:`catalog_probed`
        rather than :attr:`loaded` because it is not a level anybody asked to
        look at.

        **Failure is silence.** The previews are an aid, and a level that is
        open and working is not worth an alert because a thumbnail could not be
        made. What the user sees is rows with no popup, which is what they saw
        before the probe was asked for.
        """
        try:
            snapshot = self._supervisor.load_level(
                level, patches or None, footprints=True
            )
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            # `None` rather than silence: the parent chains the batches, and a
            # reply that never came would stop the ones after this one too.
            _log.debug("no object catalogue previews: %s", error)
            self._note_brks(error)
            self.catalog_probed.emit(None)
        else:
            self._note_brks()
            self.catalog_probed.emit(snapshot)

    @Slot(object, int, object)
    def probe_sprite_art(self, numbers: list[int], level: int, header: bytes) -> None:
        """Capture artwork for sprite numbers the loaded level does not hold.

        A few at a time, driven by the pointer resting on a row: each one is a
        savestate restore and three traced calls, so the whole catalogue is
        never asked for at once.

        Serialised with :meth:`load` by sharing its thread, which is what keeps
        a hover from arriving in the middle of a level load.
        """
        try:
            art = self._supervisor.sprite_artwork(numbers, level, header)
        except Exception as error:  # noqa: BLE001 - a thread boundary reports everything
            _log.debug("no sprite artwork for %s: %s", numbers, error)
            self._note_brks(error)
        else:
            self._note_brks()
            self.sprite_art_ready.emit(art)
