"""The parent-side handle on the emulator worker: spawn, call, survive.

The editor talks to the emulator only through this class, and this class never
imports :mod:`shiny_mushroom.emu.core`. That is the whole safety property: native
code lives in a child process, so the ways it can fail -- segfault, abort, hang,
ABI mismatch -- become an exception here rather than the end of the
application.

Failure handling is deliberately narrow. A dead worker is restarted and the
request is retried **once**, because the overwhelmingly likely cause of a first
crash is the request itself and retrying forever would just crash forever. A
second failure is reported. A worker that stops answering is treated as dead:
:func:`load` has a deadline, and a hang past it kills the process rather than
blocking the caller indefinitely.

Restarting is affordable precisely because the boot cost is small next to the
alternative: ~0.3 s to reopen the ROM and reach the title screen, against losing
the user's session.
"""

from __future__ import annotations

import base64
import logging
import signal
import subprocess
import sys
import threading
from collections.abc import Iterable, Mapping, Sequence
from pathlib import Path

from shiny_mushroom import worker_protocol as protocol
from shiny_mushroom.addresses import PIPE_TABLES
from shiny_mushroom.brk import BrkReport
from shiny_mushroom.emu import player_cache
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.overworld_snapshot import OverworldSnapshot
from shiny_mushroom.rom_patches import PlayerPosition
from shiny_mushroom.sprite_art import PlayerArt, SpriteTile, decode_tiles
from shiny_mushroom.worker_protocol import MODE_PLAY, MODE_RENDER, WORKER_FLAG

_log = logging.getLogger(__name__)

#: How long a worker asked to shut down gets to do it before it is stopped the
#: hard way. It has one message to finish and a core to release, which is
#: milliseconds; this is the bound on a worker that is not going to answer.
CLOSE_GRACE = 1.0


class EmulatorError(RuntimeError):
    """A request to the emulator failed and could not be recovered by retrying."""


class BrkError(EmulatorError):
    """The request failed because the cartridge hit a ``BRK``.

    An :class:`EmulatorError` first and foremost, so every caller that already
    handles a failed request keeps working and none of them has to learn about
    exceptions to carry on -- a sprite that will not draw is still a sprite
    that will not draw. What the ones that *do* care get is
    :attr:`report`: the registers, the stack and the exception number, ready
    for :mod:`shiny_mushroom.ui.brk_dialog`.
    """

    def __init__(self, message: str, report: BrkReport) -> None:
        super().__init__(message)
        self.report = report


#: Windows reports a native fault as its NTSTATUS rather than as a signal, and
#: the numbers are unrecognisable without the names. Only the ones a broken core
#: actually produces are listed; anything else is reported as its raw code.
_WINDOWS_FAULTS = {
    0xC0000005: "access violation",
    0xC0000009: "bad stack",
    0xC000001D: "illegal instruction",
    0xC0000025: "non-continuable exception",
    0xC0000026: "invalid disposition",
    0xC000008C: "array bounds exceeded",
    0xC0000094: "integer divide by zero",
    0xC00000FD: "stack overflow",
    0xC0000374: "heap corruption",
}


def crashed(code: int | None) -> bool:
    """Whether an exit status means the worker died rather than returned.

    A clean shutdown is ``0``; a worker that rejected a request still exits
    ``0``, because a refusal travels back down the pipe as a message. Anything
    else is the process being taken down -- by a signal on POSIX (a negative
    code), or by an unhandled native exception on Windows.
    """
    if code is None or code == 0:
        return False
    return code < 0 or code in _WINDOWS_FAULTS or code > 0xC0000000


def describe_exit(code: int | None) -> str:
    """An exit status in words, so a log line names the fault.

    ``SIGSEGV`` and ``heap corruption`` are the two this project has actually
    produced from the core, and telling them apart matters: the first is a bad
    pointer now, the second is one from some time ago.
    """
    if code is None:
        return "no exit status"
    if code == 0:
        return "exited cleanly"
    if code < 0:
        try:
            return f"killed by {signal.Signals(-code).name}"
        except ValueError:
            return f"killed by signal {-code}"
    if code in _WINDOWS_FAULTS:
        return f"{_WINDOWS_FAULTS[code]} (0x{code:08X})"
    if code > 0xC0000000:
        return f"native fault 0x{code:08X}"
    return f"exit code {code}"


def describe_request(request: Mapping[str, object]) -> str:
    """A request in one short phrase, for the line that reports a crash.

    The operation alone is not enough to go back to: every render is ``load``,
    and what distinguishes the one that killed the worker is the level, whether
    it was previewing an edit, and which sprite numbers were being driven. So
    those are named -- and nothing else is, because the payload is a patch table
    and two memories, and a log line is not the place for them.
    """
    op = request.get("op", "a request")
    detail = []
    if "level" in request:
        detail.append(f"level {hexnum(int(request['level']), 3)}")
    patches = request.get("patches")
    if patches:
        assert isinstance(patches, Mapping)
        detail.append(f"{len(patches)} patch(es)")
    numbers = request.get("numbers")
    if isinstance(numbers, Sequence) and not isinstance(numbers, str | bytes):
        detail.append("sprites " + ", ".join(hexnum(int(number)) for number in numbers))
    return f"{op}" + (f" ({', '.join(detail)})" if detail else "")


def _worker_command() -> list[str]:
    """How to start a worker, from a checkout or from a frozen build.

    Frozen, there is no separate interpreter: the application executable
    re-invokes itself with a flag that ``shiny_mushroom/__main__.py`` checks before
    it imports Qt. From source, ``-m`` starts the worker module directly, which
    keeps Qt out of the child entirely.
    """
    if getattr(sys, "frozen", False):
        return [sys.executable, WORKER_FLAG]
    return [sys.executable, "-m", "shiny_mushroom.emu.worker"]


class EmulatorSupervisor:
    """A restartable emulator worker with a ROM open.

    Not thread-safe by construction, but serialised: one lock guards the pipe,
    so a UI thread and a background render thread cannot interleave frames on
    it. Concurrency beyond that would need more than one worker, and one core
    per process is a hard constraint of the library.
    """

    #: What the worker is asked to be when it opens the ROM. Subclasses that
    #: want a different kind of core change this rather than the open request.
    mode = MODE_RENDER

    #: Whether a request that crashes the worker is retried once. True is right
    #: for a stateless one -- the whole request is in the message, so replaying
    #: it costs a restart and nothing else.
    retry_on_crash = True

    def __init__(
        self,
        rom: Path,
        timeout: float = 60.0,
        *,
        base_id: str | None = None,
        target_id: str | None = None,
        role_addresses: Mapping[str, int] | None = None,
        features: Iterable[str] = (),
        art_cache: Path | None = None,
        role_counts: Mapping[str, int] | None = None,
    ) -> None:
        self.rom = Path(rom)
        self.timeout = timeout
        #: Where :meth:`player_art` files what it captured, or ``None`` to
        #: capture it afresh every session. Passed in rather than defaulted to a
        #: directory, so that nothing acquires an on-disk cache by merely
        #: constructing a supervisor -- a test, a script and the editor should
        #: not have to opt *out* of writing to somebody's data directory.
        self.art_cache = art_cache
        #: Which ROM base ``rom`` was assembled from, or ``None`` for the
        #: default. It travels with the ``open`` request because the worker's
        #: loader resolves every cartridge address through it -- a project
        #: records the base it was built on, and a ROM from another one does not
        #: keep its pointer tables in the same places. See
        #: :class:`~shiny_mushroom.addresses.Addresses`.
        self.base_id = base_id
        #: Which of the base's targets, for the tables that move per version
        #: -- carried for the same reason and to the same place.
        self.target_id = target_id
        #: The project build's own answer per role, resolved from its symbol
        #: file, or ``None`` for a cartridge that has none. Rides the ``open``
        #: request so the worker reads a cartridge whose patches moved a table
        #: at the addresses that build actually used -- see
        #: :func:`shiny_mushroom.build.role_addresses`.
        self.role_addresses = dict(role_addresses) if role_addresses else None
        #: And that build's answer for how many entries its growable tables
        #: hold, measured off the same symbol file -- see
        #: :func:`shiny_mushroom.build.role_counts`. Rides the ``open``
        #: request for the same reason, so the capture reads every row.
        self.role_counts = dict(role_counts) if role_counts else None
        #: Which capabilities beyond the stock game this cartridge has, as
        #: feature ids -- see :mod:`smw_tools.features`. Rides the ``open``
        #: request beside the base for the same reason: they amend what the
        #: base declares, and a capture reading a cartridge through the
        #: unamended declarations is wrong in the same silent way.
        self.features = tuple(features)
        self._process: subprocess.Popen[bytes] | None = None
        self._lock = threading.Lock()
        self._version: tuple[int, int, int] | None = None
        #: How the last worker ended, kept because :meth:`_terminate` drops the
        #: process handle and the exit status is the whole diagnosis.
        self._last_exit: int | None = None
        #: Requests answered by the current worker, and deaths over the session.
        #: Both are in the crash line: the core's two known faults are heap
        #: corruption, which is a pointer from some time ago rather than now, so
        #: "how much had this worker done" is part of identifying it -- and a
        #: second death in a session is a different report from a first.
        self._served = 0
        self._deaths = 0
        #: ``BRK``\ s the worker met and carried on past, waiting for whoever
        #: asked to collect them -- see :meth:`taken_brks`. Kept here rather
        #: than raised because the request they happened during *succeeded*:
        #: the level loaded, and one of its sprites raised an exception.
        self._brks: list[BrkReport] = []

    def taken_brks(self) -> list[BrkReport]:
        """Every ``BRK`` reported since this was last asked, and forget them."""
        with self._lock:
            taken, self._brks = self._brks, []
        return taken

    # -- lifecycle ---------------------------------------------------------

    @property
    def core_version(self) -> tuple[int, int, int] | None:
        """The vendored core's version, once a worker has been started."""
        return self._version

    def start(self) -> None:
        with self._lock:
            self._ensure_worker()

    def close(self) -> None:
        """Shut the worker down, waiting briefly before insisting.

        **Closing stdin is the whole shutdown, and killing is the fallback.**
        A worker blocked in :func:`~shiny_mushroom.worker_protocol.read_message`
        sees the end of its input, returns, and runs its own cleanup -- which
        releases the core and removes the two temporary directories a session
        makes, the core's home and the savestate directory. Killed instead,
        both are left behind, once per session the editor opens.
        """
        with self._lock:
            self._shutdown()

    def __enter__(self) -> EmulatorSupervisor:
        self.start()
        return self

    def __exit__(self, *_exc: object) -> None:
        self.close()

    # -- requests ----------------------------------------------------------

    def load_level(
        self,
        level: int,
        patches: Mapping[int, bytes] | None = None,
        footprints: bool = False,
    ) -> LevelSnapshot:
        """Load a level, previewing ROM edits if any are given.

        ``patches`` maps an offset in the headerless cartridge image to the
        bytes to place there; they apply to the worker's in-memory copy only.

        ``footprints`` asks the worker to trace the object loop, so the snapshot
        can say which blocks each object drew. It costs about half a load again,
        so it is asked for when something will be selected rather than always.
        """
        request = {
            "op": "load",
            "level": int(level),
            "patches": _encode(patches),
            "footprints": bool(footprints),
        }
        header, blobs = self._request(request)
        (
            head,
            low,
            high,
            defs,
            vram,
            cgram,
            sprites,
            objects,
            layer2_low,
            layer2_high,
            layer2_defs,
            layer2_header,
            layer2_objects,
            pipes,
        ) = blobs
        return LevelSnapshot(
            level=header["level"],
            header=head,
            map16_low=low,
            map16_high=high,
            map16_defs=defs,
            pipe_definitions=_split(pipes, PIPE_TABLES),
            vram=vram,
            cgram=cgram,
            sprites=sprites,
            objects=objects,
            sprite_art={
                int(number): decode_tiles(tiles)
                for number, tiles in header.get("sprite_art", {}).items()
            },
            extra_counts={
                int(number): int(count)
                for number, count in header.get("extra_counts", {}).items()
            },
            screen_mode=header["screen_mode"],
            back_area_color=header["back_area_color"],
            footprints=tuple(
                frozenset(cells) for cells in header.get("footprints", ())
            ),
            layer2_low=layer2_low,
            layer2_high=layer2_high,
            layer2_defs=layer2_defs,
            layer2_background=bool(header["layer2_background"]),
            layer2_header=layer2_header,
            layer2_objects=layer2_objects,
            layer3_setting=header["layer3_setting"],
            layer3_x=header["layer3_x"],
            layer3_y=header["layer3_y"],
            camera_x=header.get("camera", (0, 0))[0],
            camera_y=header.get("camera", (0, 0))[1],
            spawn=PlayerPosition(*header.get("spawn", (0, 0))),
            duration=header.get("duration", 0.0),
        )

    def load_overworld(
        self, palettes: bool = True, patches: Mapping[int, bytes] | None = None
    ) -> OverworldSnapshot:
        """Capture the overworld, as the game's own loader builds it.

        Cached on the worker for the session under the ``patches`` it was made
        with, so only the first call for a given set pays the loads. The
        patches are the same kind :meth:`load_level` takes -- offsets in the
        headerless image, applied to the worker's copy only -- and are what a
        project's edited graphics files ride in on. ``palettes`` asks for
        every submap's CGRAM rather than only the main map's -- see
        :meth:`SmwLevelLoader.load_overworld`.
        """
        header, blobs = self._request(
            {
                "op": "overworld",
                "palettes": bool(palettes),
                "patches": _encode(patches),
            }
        )
        (
            tiles,
            defs,
            vram,
            cgram,
            layer2,
            translevels,
            directions,
            settings,
            event_flags,
            level_events,
            level_directions,
            event_entries,
            event_pointers,
            event_l1_locations,
            event_l1_from,
            event_l1_to,
            event_stamps,
            event_stamp_props,
            destroy_events,
            destroy_locations,
            destroy_before,
            destroy_top,
            destroy_bottom,
            silent_tiles,
            sprite_slots,
            sprite_submap_disable,
            sprite_boo_x_offsets,
            sprite_boo_y_offsets,
            sprite_smoke_x_positions,
            sprite_smoke_y_positions,
            submaps,
            player_vram,
            player_cgram,
            warp_trigger_columns,
            warp_trigger_rows,
            warp_landings_x,
            warp_landings_y,
            exit_triggers,
            exit_landings,
            exit_landing_cells,
            level_names,
        ) = blobs
        count = int(header.get("submaps", 0))
        each = len(submaps) // count if count else 0
        return OverworldSnapshot(
            tiles=tiles,
            map16_defs=defs,
            vram=vram,
            cgram=cgram,
            layer2=layer2,
            back_area_color=header["back_area_color"],
            translevels=translevels,
            directions=directions,
            tile_settings=settings,
            event_flags=event_flags,
            level_events=level_events,
            level_directions=level_directions,
            event_entries=event_entries,
            event_pointers=event_pointers,
            event_l1_locations=event_l1_locations,
            event_l1_from=event_l1_from,
            event_l1_to=event_l1_to,
            event_stamps=event_stamps,
            event_stamp_props=event_stamp_props,
            destroy_events=destroy_events,
            destroy_locations=destroy_locations,
            destroy_before=destroy_before,
            destroy_top=destroy_top,
            destroy_bottom=destroy_bottom,
            silent_tiles=silent_tiles,
            sprite_slots=sprite_slots,
            sprite_submap_disable=sprite_submap_disable,
            sprite_boo_x_offsets=sprite_boo_x_offsets,
            sprite_boo_y_offsets=sprite_boo_y_offsets,
            sprite_smoke_x_positions=sprite_smoke_x_positions,
            sprite_smoke_y_positions=sprite_smoke_y_positions,
            warp_trigger_columns=warp_trigger_columns,
            warp_trigger_rows=warp_trigger_rows,
            warp_landings_x=warp_landings_x,
            warp_landings_y=warp_landings_y,
            exit_triggers=exit_triggers,
            exit_landings=exit_landings,
            exit_landing_cells=exit_landing_cells,
            level_names=level_names,
            submap_cgram=tuple(
                submaps[n * each : (n + 1) * each] for n in range(count)
            ),
            sprite_art=tuple(
                (
                    int(number),
                    tuple(
                        (int(x), int(y), int(tile), int(attrs), bool(large))
                        for x, y, tile, attrs, large in rows
                    ),
                )
                for number, rows in header.get("sprite_art", ())
            ),
            player_art=tuple(
                (int(x), int(y), int(tile), int(attrs), bool(large))
                for x, y, tile, attrs, large in header.get("player_art", ())
            ),
            player_vram=player_vram,
            player_cgram=player_cgram,
            duration=header.get("duration", 0.0),
        )

    def probe_replayed_overworld(self) -> tuple[bytes, bytes]:
        """The overworld with every event replayed by the game itself --
        ``(layer 1 tilemap, layer 2 buffer)``. A testing probe; see
        :meth:`SmwLevelLoader.probe_replayed_overworld`."""
        _header, blobs = self._request({"op": "overworld_replay"})
        tiles, layer2 = blobs
        return tiles, layer2

    def player_art(self) -> PlayerArt:
        """What the player looks like, captured from the running level.

        Only meaningful once a level has been loaded -- the probe needs one to
        run -- and worth asking for exactly once: the answer is the same for
        every level, and it costs a savestate and ~65 ms of emulation.

        **And once a cartridge rather than once a session**, where
        :attr:`art_cache` says where to keep it: the capture is a fact about the
        ROM's bytes, so a later launch over the same ones reads it back and the
        probe never runs. A cache miss is a capture, which is what every session
        used to be -- see :mod:`shiny_mushroom.emu.player_cache`.
        """
        key = ""
        if self.art_cache is not None:
            key = player_cache.key_for(self.rom, self.base_id, self.target_id)
            cached = player_cache.read(self.art_cache, key)
            if cached is not None:
                _log.debug("player artwork came from the cache, not the emulator")
                return cached
        header, blobs = self._request({"op": "player_art"})
        vram, cgram = blobs
        art = PlayerArt(
            tiles=decode_tiles(header.get("tiles", ())),
            vram=vram,
            cgram=cgram,
        )
        if self.art_cache is not None:
            player_cache.write(self.art_cache, key, art)
        return art

    def sprite_artwork(
        self, numbers: Sequence[int], level: int, header: bytes
    ) -> dict[int, tuple[SpriteTile, ...]]:
        """Artwork for sprite numbers the loaded level does not hold.

        What the create panel's previews need for the two hundred sprites a
        level does not contain. ``level`` and ``header`` say which level's
        graphics the capture is under, so the worker's answers land in the same
        cache the level's own capture fills.

        Costs a savestate restore and three traced calls **per number**, so this
        is asked for a few at a time. A number that drew nothing comes back with
        an empty tuple rather than missing, which is what stops a caller
        re-asking for it every time the pointer passes.
        """
        header_out, _ = self._request(
            {
                "op": "sprite_art",
                "numbers": [int(number) for number in numbers],
                "level": int(level),
                "header": base64.b64encode(header).decode("ascii"),
            }
        )
        return {
            int(number): decode_tiles(tiles)
            for number, tiles in header_out.get("sprite_art", {}).items()
        }

    # -- plumbing ----------------------------------------------------------

    def _request(self, request: dict) -> tuple[dict, list[bytes]]:
        with self._lock:
            try:
                return self._attempt(request)
            except (protocol.ProtocolError, BrokenPipeError, OSError) as first:
                # The worker died mid-request. Read before the restart below,
                # which starts the next worker's count.
                served = self._served
                self._terminate()
                # Said out loud whichever way this goes. A native fault that is
                # recovered from is invisible otherwise -- the user sees a slow
                # load and nothing else -- and "it crashed but carried on" is
                # exactly the thing worth knowing when a render looks wrong.
                self._deaths += 1
                _log.warning(
                    "the emulator worker died during %s (%s) after answering %d "
                    "request(s); death %d this session; %s. Any native "
                    "traceback is on stderr, above this line.",
                    describe_request(request),
                    describe_exit(self._last_exit),
                    served,
                    self._deaths,
                    "restarting and retrying once"
                    if self.retry_on_crash
                    else "not retrying",
                )
                if not self.retry_on_crash:
                    raise EmulatorError(
                        f"the emulator worker stopped ({first}).{self._crash_detail()}"
                    ) from first
                # Restart and try once more: a transient crash should not need
                # the user to do anything, and a reproducible one will fail
                # again immediately below.
                try:
                    return self._attempt(request)
                except (protocol.ProtocolError, BrokenPipeError, OSError) as second:
                    raise EmulatorError(
                        f"the emulator worker crashed twice on the same request "
                        f"({first}; then {second}).{self._crash_detail()}"
                    ) from second

    def _attempt(self, request: dict) -> tuple[dict, list[bytes]]:
        self._ensure_worker()
        assert (
            self._process is not None and self._process.stdin and self._process.stdout
        )

        protocol.write_message(self._process.stdin, request)
        header, blobs = self._read_with_deadline()
        self._served += 1
        # Kept whichever way the reply goes: a BRK the request survived rides
        # on the success, and one that stopped it rides on the error below.
        self._brks.extend(
            BrkReport.from_dict(entry) for entry in header.get("brks", ())
        )
        if not header.get("ok"):
            # A clean error from the worker: the request was bad, or the load
            # failed. The process is fine, so do not restart it.
            message = header.get("error", "the emulator reported an unknown error")
            brk = header.get("brk")
            if isinstance(brk, dict):
                raise BrkError(message, BrkReport.from_dict(brk))
            raise EmulatorError(message)
        return header, blobs

    def _read_with_deadline(self) -> tuple[dict, list[bytes]]:
        """Wait for a reply, treating silence past the deadline as a hang.

        The read runs on a helper thread because a pipe read cannot be given a
        timeout portably. If it overruns, the worker is killed, which unblocks
        the helper by closing the pipe underneath it.
        """
        result: list[tuple[dict, list[bytes]]] = []
        failure: list[BaseException] = []
        assert self._process is not None and self._process.stdout
        stream = self._process.stdout

        def read() -> None:
            try:
                result.append(protocol.read_message(stream))
            except BaseException as exc:  # noqa: BLE001 - handed to the caller
                failure.append(exc)

        thread = threading.Thread(target=read, daemon=True, name="emu-read")
        thread.start()
        thread.join(self.timeout)
        if thread.is_alive():
            self._terminate()
            raise EmulatorError(
                f"the emulator did not answer within {self.timeout:g}s and was stopped"
            )
        if failure:
            raise failure[0]
        return result[0]

    def _ensure_worker(self) -> None:
        if self._process is not None and self._process.poll() is None:
            return
        if self._process is not None:
            # Died between requests rather than during one, so no reader saw a
            # broken pipe and nothing above has reported it. That is the quiet
            # case and the one most worth a line: the next load simply starts a
            # new worker and looks slow.
            self._last_exit = self._process.returncode
            _close_pipes(self._process)
            if crashed(self._last_exit):
                _log.warning(
                    "the emulator worker died between requests (%s); starting a "
                    "fresh one",
                    describe_exit(self._last_exit),
                )
        # A fresh worker has answered nothing, and the crash line reports what
        # *this* one had done before it died rather than the session's total.
        self._served = 0
        self._process = subprocess.Popen(
            _worker_command(),
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            # stderr is left attached to ours: a faulthandler traceback from a
            # native crash is the only diagnostic there will be, and swallowing
            # it into a pipe nobody drains would deadlock a crashing worker.
            stderr=None,
        )
        header, _ = self._attempt_open()
        self._version = tuple(header.get("version", ())) or None

    def _open(self) -> dict:
        """What else the ``open`` request carries. Extended by subclasses."""
        request = {"mode": self.mode}
        if self.base_id is not None:
            request["base"] = self.base_id
        if self.target_id is not None:
            request["target"] = self.target_id
        if self.role_addresses is not None:
            request["addresses"] = self.role_addresses
        if self.role_counts is not None:
            request["counts"] = self.role_counts
        if self.features:
            request["features"] = list(self.features)
        return request

    def _attempt_open(self) -> tuple[dict, list[bytes]]:
        assert (
            self._process is not None and self._process.stdin and self._process.stdout
        )
        protocol.write_message(
            self._process.stdin, {"op": "open", "rom": str(self.rom), **self._open()}
        )
        header, blobs = self._read_with_deadline()
        if not header.get("ok"):
            self._terminate()
            raise EmulatorError(
                header.get("error", "the emulator could not open the ROM")
            )
        return header, blobs

    def _shutdown(self) -> None:
        """End the worker by taking its input away, and insist only if it hangs.

        The graceful path is what runs the worker's own cleanup; see
        :meth:`close` for what is leaked without it. Closing stdin is safe in a
        way closing stdout is not -- nothing here reads from it, so there is no
        buffered object whose lock a reader thread might be holding.
        """
        process = self._process
        if process is not None and process.poll() is None:
            if process.stdin is not None:
                try:
                    process.stdin.close()
                except OSError:
                    pass
            try:
                process.wait(timeout=CLOSE_GRACE)
            except subprocess.TimeoutExpired:
                _log.debug("the emulator worker did not exit on its own; stopping it")
        self._terminate()

    def _terminate(self) -> None:
        """Stop the worker the hard way, in the one order that cannot deadlock.

        The process is killed *before* its pipes are closed. A reader thread
        blocked in ``stdout.read()`` holds that buffered object's lock, so
        closing it from here would wait for a read that is itself waiting for a
        process we have not stopped yet. Killing first sends the reader an EOF,
        which lets it finish and release the lock.

        That order is why this is the fallback rather than the ordinary ending:
        a healthy worker killed here never reaches its own cleanup. An ordinary
        close goes through :meth:`_shutdown` first.
        """
        process, self._process = self._process, None
        if process is None:
            return
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait(timeout=5)
        # Recorded before the handle goes: `_crash_detail` used to read it off
        # `self._process`, which this method had already set to None, so every
        # crash was reported without the one fact that identifies it.
        self._last_exit = process.returncode
        _close_pipes(process)

    def _crash_detail(self) -> str:
        if self._last_exit is None:
            return ""
        return (
            f" Worker {describe_exit(self._last_exit)}; "
            "any native traceback is on stderr."
        )


class PlaySupervisor(EmulatorSupervisor):
    """A second worker, with a second core, running a level for someone to play.

    A second one rather than another request to the first because a core is
    built for video and sound or for neither, at construction, and there is one
    core per process. So testing a level costs a process and its boot -- which
    is why the window keeps it alive between runs rather than starting one per
    press.

    **A crash is not retried here.** The loader's requests are stateless, so
    replaying one after a restart gives the same answer; a play session's are
    not. Replaying "give me the next frame" against a worker that has just been
    restarted would answer for a machine sitting at the title screen, which
    reads as the level having vanished. Reporting it and letting the window
    close is the honest ending.
    """

    mode = MODE_PLAY
    retry_on_crash = False

    def __init__(
        self,
        rom: Path,
        timeout: float = 60.0,
        *,
        audio: bool = True,
        base_id: str | None = None,
        target_id: str | None = None,
        role_addresses: Mapping[str, int] | None = None,
        features: Iterable[str] = (),
        role_counts: Mapping[str, int] | None = None,
    ) -> None:
        super().__init__(
            rom,
            timeout,
            base_id=base_id,
            target_id=target_id,
            role_addresses=role_addresses,
            features=features,
            role_counts=role_counts,
        )
        self.audio = audio

    def _open(self) -> dict:
        return {**super()._open(), "audio": self.audio}

    def enter_level(
        self,
        level: int,
        patches: Mapping[int, bytes] | None = None,
        options: Mapping[str, object] | None = None,
    ) -> dict:
        """Load ``level`` and leave the game running in it.

        Returns the reply header: the level, what it cost, whether a savestate
        was reused instead of loading, and the game mode it ended in.
        """
        header, _ = self._request(
            {
                "op": "enter",
                "level": int(level),
                "patches": _encode(patches),
                "options": dict(options or {}),
            }
        )
        return header

    def enter_overworld(
        self,
        submap: int,
        x: int,
        y: int,
        tile_settings: bytes,
        event_flags: bytes,
        patches: Mapping[int, bytes] | None = None,
    ) -> dict:
        """Boot onto the world map and leave the game running there.

        ``tile_settings`` and ``event_flags`` are the save-state tables the
        run starts from, ``(submap, x, y)`` where the player stands. Returns
        the reply header: what it cost, whether a savestate was reused, and
        the game mode it ended in.
        """
        header, _ = self._request(
            {
                "op": "enter_overworld",
                "submap": int(submap),
                "x": int(x),
                "y": int(y),
                "tile_settings": base64.b64encode(tile_settings).decode(),
                "event_flags": base64.b64encode(event_flags).decode(),
                "patches": _encode(patches),
            }
        )
        return header

    def enter_cartridge(self) -> dict:
        """Run the cartridge itself, from its title screen and with no edits.

        The third kind of run, and the one that asks for nothing: no level, no
        map, no patches -- see
        :meth:`~shiny_mushroom.emu.play.PlaySession.enter_cartridge`. Returns
        the reply header: what it cost and the game mode it left.
        """
        header, _ = self._request({"op": "enter_cartridge"})
        return header

    def carry_on_past_brk(self) -> None:
        """Execute the ``BRK`` this run is stopped at and let it carry on.

        The other answer to a report -- see
        :meth:`~shiny_mushroom.emu.play.PlaySession.carry_on_past_brk`. Nothing
        is asked of the machine first: it is stopped *at* the instruction, and
        the next thing it does is execute it.
        """
        self._request({"op": "carry_on_past_brk"})

    def beat_level(self, secret: bool = False) -> dict:
        """Beat the level the player stands on, so its map event plays.

        Returns ``{"done": ..., "message"/"translevel"/"event": ...}`` -- a
        refusal is an answer here, not an error, because "you are not on a
        level" is something the window's status line says, not a crash.
        """
        header, _ = self._request({"op": "beat_level", "secret": bool(secret)})
        return header

    def peek(self, offset: int, length: int) -> bytes:
        """A work-RAM window, for tests that assert on the machine's state."""
        _, blobs = self._request(
            {"op": "peek", "offset": int(offset), "length": int(length)}
        )
        return blobs[0] if blobs else b""

    def slots(self, table: int) -> bytes:
        """Every sprite slot of the table based at vanilla ``table``.

        However many this base has -- twelve on a console, 22 under More
        Sprites -- which is why this is not :meth:`peek`: that takes a vanilla
        work-RAM offset, and the ten slots the pack adds have none.
        """
        _, blobs = self._request({"op": "slots", "table": int(table)})
        return blobs[0] if blobs else b""

    def set_loadout(self, player: Mapping[str, object]) -> None:
        """Write the player's powerup, lives, coins and the rest, live.

        The level keeps running. This is the same five writes entering it
        makes, so it is how somebody gets a cape without reloading.
        """
        self._request({"op": "loadout", "player": dict(player)})

    def pump(
        self, buttons: int = 0, seen: int = 0, paused: bool | None = None
    ) -> tuple[dict, bytes | None]:
        """One turn of the play loop, and the next picture once there is one.

        Buttons, pause state and the frame in a single round trip, because this
        runs sixty times a second and three would be three times the syscalls.
        A long poll: the worker holds the reply until a frame newer than
        ``seen`` is latched or its short wait runs out, so this call blocks
        for up to a frame period -- that is the pacing, not a defect. A reply
        without pixels means the wait timed out (a paused game, a still
        screen), which is what keeps a quarter of a megabyte from being
        shipped thirty times a second to redraw the same thing.
        """
        request: dict = {"op": "pump", "buttons": int(buttons), "seen": int(seen)}
        if paused is not None:
            request["paused"] = bool(paused)
        header, blobs = self._request(request)
        return header, (blobs[0] if blobs else None)


def _close_pipes(process: subprocess.Popen[bytes]) -> None:
    """Give back the two descriptors a worker's handle holds."""
    for stream in (process.stdin, process.stdout):
        if stream is not None:
            try:
                stream.close()
            except OSError:
                pass


def _split(blob: bytes, parts: int) -> tuple[bytes, ...]:
    """``blob`` as ``parts`` equal slices, or nothing if it is empty.

    What the worker's concatenation is undone with: the framing carries a flat
    list of blobs, so a fixed number of equal-length tables travels as one.
    """
    if not blob:
        return ()
    size = len(blob) // parts
    return tuple(blob[n * size : (n + 1) * size] for n in range(parts))


def _encode(patches: Mapping[int, bytes] | None) -> dict[str, str]:
    return {
        str(offset): base64.b64encode(data).decode()
        for offset, data in (patches or {}).items()
    }
