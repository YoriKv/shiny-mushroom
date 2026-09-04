"""The child process that owns the emulator core.

This is the only module in the editor that loads native code, and it runs
nowhere near the Qt event loop. If Mesen segfaults -- a bad ROM, an ABI drift, a
genuine bug -- this process dies and
:class:`shiny_mushroom.emu.supervisor.EmulatorSupervisor` notices and restarts it.
The editor sees an exception on one call instead of losing the application and
whatever the user had open.

Two details make that isolation actually hold:

**stdout is claimed before anything else runs.** The protocol uses the process's
own stdout, and native libraries write to file descriptor 1 whenever they feel
like it -- one stray ``printf`` in the middle of a frame would desynchronise the
stream and look like corruption. So fd 1 is duplicated to a private descriptor
for our exclusive use and then pointed at stderr, where anything the core prints
is merely visible rather than damaging.

**Everything is done at the file-descriptor level.** A ``--windowed`` PyInstaller
build on Windows has no console, and ``sys.stdout`` there can be ``None``; the
descriptors the parent supplied still exist.
"""

from __future__ import annotations

import base64
import faulthandler
import io
import os
import sys
import tempfile
from pathlib import Path
from typing import Any

from shiny_mushroom import configure_logging
from shiny_mushroom import worker_protocol as protocol
from shiny_mushroom.brk import BrkRaised, BrkReport
from shiny_mushroom.worker_protocol import MODE_PLAY, MODE_RENDER, WORKER_FLAG

__all__ = ["WORKER_FLAG", "main"]


def _claim_stdout() -> io.BufferedWriter:
    """Take sole ownership of the protocol channel; send fd 1 to stderr."""
    private = os.dup(1)
    os.dup2(2, 1)
    return os.fdopen(private, "wb")


class _Session:
    """The worker's state: one core, one session, for the process's lifetime."""

    def __init__(self) -> None:
        self.core = None
        self.loader = None
        self.play = None
        self._state_dir: tempfile.TemporaryDirectory | None = None

    def open_rom(
        self,
        rom: Path,
        mode: str = MODE_RENDER,
        *,
        audio: bool = True,
        base_id: str | None = None,
        target_id: str | None = None,
        role_addresses: dict[str, int] | None = None,
        features: list[str] | None = None,
        role_counts: dict[str, int] | None = None,
    ) -> dict[str, Any]:
        # Imported here, not at module scope, so that a worker which is only
        # ever asked to report its unavailability does not need the library to
        # exist -- and so an import error arrives as a protocol reply rather
        # than a process that dies before saying anything.
        from shiny_mushroom.addresses import Addresses
        from shiny_mushroom.emu.core import MesenCore
        from shiny_mushroom.emu.play import PlaySession
        from shiny_mushroom.emu.smw import SmwLevelLoader

        if self.core is not None:
            raise RuntimeError("this worker already has a ROM open")
        if mode not in (MODE_RENDER, MODE_PLAY):
            raise RuntimeError(f"unknown worker mode {mode!r}")

        # Resolved before the core is built, so a base this build does not have
        # -- or a feature it does not declare -- is refused while the process
        # still has nothing open, rather than after a ROM is loaded, where the
        # failure reads as a bad cartridge. The overrides are the project
        # build's own per-role answers and the features what that build put in
        # the cartridge: between them, what keeps a patched ROM readable.
        #
        # The cartridge's *size* is the third such fact, and the one nobody
        # has to send: it is the length of the file about to be opened, so it
        # is read off that rather than threaded down the protocol beside the
        # other two -- and a ROM opened by hand is answered as exactly as a
        # project's own build.
        addresses = Addresses.for_rom(
            Path(rom), base_id, target_id, role_addresses, features or (), role_counts
        )
        playing = mode == MODE_PLAY
        self.core = MesenCore(
            video=playing,
            audio=playing and audio,
        )
        if playing:
            # Before the ROM: the console builds its control devices from the
            # settings as it is constructed, which is what LoadRom does.
            self.core.attach_controller()
        self.core.load_rom(rom)
        self._state_dir = tempfile.TemporaryDirectory(prefix="shiny_mushroom-states-")
        state_dir = Path(self._state_dir.name)
        if playing:
            self.play = PlaySession(
                core=self.core, state_dir=state_dir, addresses=addresses
            )
            session = self.play
        else:
            self.loader = SmwLevelLoader(
                core=self.core, state_dir=state_dir, addresses=addresses
            )
            session = self.loader
        # Before the boot, so a cartridge that BRKs on its way to the title
        # screen is reported as that rather than as a cart that never booted.
        session.watch_for_brk()
        if playing:
            self.play.open()
        else:
            self.loader.prepare()
        return {"version": list(self.core.version), "mode": mode}

    # -- playing -----------------------------------------------------------

    def _playing(self):
        if self.play is None:
            raise RuntimeError("this worker is not a play session")
        return self.play

    def _rendering(self):
        if self.loader is None:
            raise RuntimeError("no ROM is open")
        return self.loader

    def enter_level(
        self, level: int, patches: dict[int, bytes], options: dict[str, Any]
    ) -> tuple[dict[str, Any], list[bytes]]:
        from shiny_mushroom.play_request import PlayerState, PlayOptions

        player = PlayerState(**options.get("player", {}))
        entry = self._playing().enter(
            level,
            patches or None,
            PlayOptions(
                player=player,
                entrance_room=bool(options.get("entrance_room", False)),
            ),
        )
        return {
            "level": entry.level,
            "duration": entry.duration,
            "reused": entry.reused,
            "game_mode": entry.game_mode,
        }, []

    def loadout(self, player: dict[str, Any]) -> tuple[dict[str, Any], list[bytes]]:
        from shiny_mushroom.play_request import PlayerState

        self._playing().apply_loadout(PlayerState(**player))
        return {}, []

    def enter_overworld(
        self, request: dict[str, Any]
    ) -> tuple[dict[str, Any], list[bytes]]:
        entry = self._playing().enter_overworld(
            int(request["submap"]),
            int(request["x"]),
            int(request["y"]),
            base64.b64decode(request["tile_settings"]),
            base64.b64decode(request["event_flags"]),
            _patches(request) or None,
        )
        return {
            "duration": entry.duration,
            "reused": entry.reused,
            "game_mode": entry.game_mode,
        }, []

    def enter_cartridge(self) -> tuple[dict[str, Any], list[bytes]]:
        """Run the cartridge itself, from its title screen and with no edits."""
        entry = self._playing().enter_cartridge()
        return {"duration": entry.duration, "game_mode": entry.game_mode}, []

    def brk_note(self) -> dict[str, Any]:
        """``{"brks": [...]}`` for whatever the session kept, or nothing."""
        session = self.play or self.loader
        reports = session.taken_brks() if session is not None else []
        return {"brks": [report.as_dict() for report in reports]} if reports else {}

    def carry_on_past_brk(self) -> tuple[dict[str, Any], list[bytes]]:
        """Execute the ``BRK`` the run is stopped at and let it carry on."""
        self._playing().carry_on_past_brk()
        return {}, []

    def beat_level(self, secret: bool) -> tuple[dict[str, Any], list[bytes]]:
        return dict(self._playing().complete_level(secret)), []

    def peek(self, offset: int, length: int) -> tuple[dict[str, Any], list[bytes]]:
        """A work-RAM window, for tests that assert on the machine's state."""
        from shiny_mushroom.addresses import RamView

        session = self._playing()
        return {}, [RamView(session.core, session.addresses).slice(offset, length)]

    def slots(self, table: int) -> tuple[dict[str, Any], list[bytes]]:
        """Every sprite slot of one table, for tests that assert on them.

        Separate from :meth:`peek` because :meth:`peek` names bytes by their
        vanilla work-RAM offset and slots 12-21 do not have one -- they exist
        only on a base with More Sprites. See
        :meth:`shiny_mushroom.addresses.RamView.slots`.
        """
        from shiny_mushroom.addresses import RamView

        session = self._playing()
        return {}, [RamView(session.core, session.addresses).slots(table)]

    def pump(
        self, buttons: int, seen: int, paused: bool | None
    ) -> tuple[dict[str, Any], list[bytes]]:
        """One turn of the play loop: buttons in, the next picture out.

        Everything the window needs per frame in one round trip, because the
        alternative is three, and this one runs sixty times a second. A long
        poll: the buttons land first, then the reply is **held until the next
        frame** (or the wait's timeout), so frames cross the pipe at the
        emulator's own cadence -- see
        :meth:`~shiny_mushroom.emu.play.PlaySession.await_frame`.
        """
        session = self._playing()
        if paused is not None:
            session.set_paused(paused)
        session.set_buttons(buttons)
        frame = session.await_frame(seen)
        header = {
            "sequence": frame.sequence if frame else seen,
            "presented": session.presented,
            "paused": session.paused,
            "game_mode": session.game_mode(),
        }
        # A run stopped at a BRK draws no frames, so the pump is the one thing
        # still crossing the pipe and the only place the window can be told.
        # Carried on every pump while the machine is stopped, because the
        # window may have been closed and reopened over the same session.
        report = session.brk()
        if report is not None:
            header["brk"] = report.as_dict()
        if frame is None:
            return header, []
        header["width"] = frame.width
        header["height"] = frame.height
        return header, [frame.pixels]

    # -- rendering ---------------------------------------------------------

    def load_level(
        self, level: int, patches: dict[int, bytes], footprints: bool = False
    ) -> tuple[dict[str, Any], list[bytes]]:
        from shiny_mushroom.sprite_art import encode_tiles

        snapshot = self._rendering().load(level, patches or None, footprints=footprints)
        header = {
            "level": snapshot.level,
            "duration": snapshot.duration,
            "screen_mode": snapshot.screen_mode,
            "back_area_color": snapshot.back_area_color,
            # Small enough for the JSON header: a level has a handful of
            # distinct sprite numbers and each draws a few tiles. The bulk
            # blobs below are the memories, which are not.
            "sprite_art": {
                str(number): encode_tiles(tiles)
                for number, tiles in snapshot.sprite_art.items()
            },
            # The custom sprites' extra-byte stride, off the cartridge's own
            # count table: whoever parses this snapshot's stream needs it.
            "extra_counts": {
                str(number): count for number, count in snapshot.extra_counts.items()
            },
            # One list of tilemap offsets per object. A couple of thousand small
            # integers for a whole level, so the header carries it rather than
            # earning another blob.
            "footprints": [sorted(cells) for cells in snapshot.footprints],
            # Which kind of Layer 2 the level has, and where the loader left
            # Layer 3. Small, and none of it is derivable on the far side: the
            # kind comes from the cartridge's pointer table and the scroll from
            # work RAM, and a snapshot that arrives without them renders every
            # level as though its Layer 2 were a level and it had no Layer 3.
            "layer2_background": snapshot.layer2_background,
            "layer3_setting": snapshot.layer3_setting,
            "layer3_x": snapshot.layer3_x,
            "layer3_y": snapshot.layer3_y,
            # The camera the Layer 3 scroll above is expressed against. Without
            # it that scroll cannot be placed on the level at all -- see
            # `shiny_mushroom.level.layer3_origin`.
            "camera": [snapshot.camera_x, snapshot.camera_y],
            # Where the game put the player. Two numbers, so the header rather
            # than a blob, and not derivable on the far side: the entrance is a
            # pair of indices into tables in bank $05 and a vertical level
            # ignores one of them.
            "spawn": [snapshot.spawn.x, snapshot.spawn.y],
        }
        blobs = [
            snapshot.header,
            snapshot.map16_low,
            snapshot.map16_high,
            snapshot.map16_defs,
            snapshot.vram,
            snapshot.cgram,
            snapshot.sprites,
            snapshot.objects,
            snapshot.layer2_low,
            snapshot.layer2_high,
            snapshot.layer2_defs,
            # The Layer 2 object stream and the five bytes in front of it, for
            # the levels whose Layer 2 is a level. Cut out of the cartridge
            # rather than out of RAM, so the far side cannot re-derive them
            # from anything else in this reply.
            snapshot.layer2_header,
            snapshot.layer2_objects,
            # The four pipe tables, concatenated: the framing carries a flat
            # list of blobs and not a nested one, and they are all the same
            # length, so the far side divides rather than being told where the
            # cuts are. Not derivable there -- they are four bank $0D tables
            # the capture followed the cartridge's own pointers to.
            b"".join(snapshot.pipe_definitions),
            # The custom tiles' definitions, one flat table off the cartridge
            # where it carries the feature and empty where it does not.
            snapshot.custom_defs,
        ]
        return header, blobs

    def load_overworld(
        self, palettes: bool = True, patches: dict[int, bytes] | None = None
    ) -> tuple[dict[str, Any], list[bytes]]:
        snapshot = self._rendering().load_overworld(
            palettes=palettes, patches=patches or None
        )
        header = {
            "duration": snapshot.duration,
            "back_area_color": snapshot.back_area_color,
            # How many equal slices the submap-palette blob divides into. The
            # blob is their concatenation because the framing carries a flat
            # list of blobs, not a nested one.
            "submaps": len(snapshot.submap_cgram),
            # The sprite artwork rows, JSON-shaped: a few hundred small ints
            # ride the header rather than earning a blob format of their own.
            "sprite_art": [
                [number, [list(row) for row in rows]]
                for number, rows in snapshot.sprite_art
            ],
            # The player's marker rows, the same JSON shape without a number.
            "player_art": [list(row) for row in snapshot.player_art],
        }
        blobs = [
            snapshot.tiles,
            snapshot.map16_defs,
            snapshot.vram,
            snapshot.cgram,
            snapshot.layer2,
            snapshot.translevels,
            snapshot.directions,
            snapshot.tile_settings,
            snapshot.event_flags,
            snapshot.level_events,
            snapshot.level_directions,
            snapshot.event_entries,
            snapshot.event_pointers,
            snapshot.event_l1_locations,
            snapshot.event_l1_from,
            snapshot.event_l1_to,
            snapshot.event_stamps,
            snapshot.event_stamp_props,
            snapshot.destroy_events,
            snapshot.destroy_locations,
            snapshot.destroy_before,
            snapshot.destroy_top,
            snapshot.destroy_bottom,
            snapshot.silent_tiles,
            snapshot.sprite_slots,
            snapshot.sprite_submap_disable,
            snapshot.sprite_boo_x_offsets,
            snapshot.sprite_boo_y_offsets,
            snapshot.sprite_smoke_x_positions,
            snapshot.sprite_smoke_y_positions,
            b"".join(snapshot.submap_cgram),
            snapshot.player_vram,
            snapshot.player_cgram,
            snapshot.warp_trigger_columns,
            snapshot.warp_trigger_rows,
            snapshot.warp_landings_x,
            snapshot.warp_landings_y,
            snapshot.exit_triggers,
            snapshot.exit_landings,
            snapshot.exit_landing_cells,
            snapshot.level_names,
        ]
        return header, blobs

    def replayed_overworld(self) -> tuple[dict[str, Any], list[bytes]]:
        tiles, layer2 = self._rendering().probe_replayed_overworld()
        return {}, [tiles, layer2]

    def player_art(self) -> tuple[dict[str, Any], list[bytes]]:
        """What the player looks like, for a marker at the level's start.

        Asked for after a level is loaded, because the probe needs one running
        -- and asked for once, because the answer does not vary with the level.
        """
        from shiny_mushroom.sprite_art import encode_tiles

        art = self._rendering().capture_player_art()
        header = {"tiles": encode_tiles(art.tiles)}
        # The memories from the moment of the capture, not the level's: the
        # player's tiles are DMA'd per frame and a level snapshot's VRAM was
        # taken before that happened.
        return header, [art.vram, art.cgram]

    def sprite_artwork(
        self, numbers: list[int], level: int, header: bytes
    ) -> tuple[dict[str, Any], list[bytes]]:
        """Capture artwork for sprite numbers the loaded level does not hold.

        What a catalogue preview needs. ``level`` and ``header`` come from the
        parent rather than being re-derived here, so the answers land in the
        same cache the level's own capture fills and neither side probes a
        number the other already has.

        Tiles only, and no memories: the caller is drawing these against the
        level's own VRAM and CGRAM, which it already has from the load.
        """
        from shiny_mushroom.sprite_art import encode_tiles

        art = self._rendering().artwork_for(numbers, level, header)
        return {
            "sprite_art": {
                str(number): encode_tiles(tiles) for number, tiles in art.items()
            }
        }, []

    def close(self) -> None:
        if self.core is not None:
            self.core.release()
            self.core = None
        self.loader = None
        self.play = None
        if self._state_dir is not None:
            self._state_dir.cleanup()
            self._state_dir = None


def _dispatch(
    session: _Session, request: dict[str, Any]
) -> tuple[dict[str, Any], list[bytes]]:
    """Answer one request, turning a cartridge that stopped into a report.

    Every op crosses this line, so the translation from "the core stopped at a
    break" to "the cartridge raised exception ``$2A`` at ``$01A4C7``" is made
    once. What the core gathered while the machine was stopped is already a
    :class:`~shiny_mushroom.brk.BrkReport` -- the session built it -- so all
    that happens here is that it is put on an exception the reply knows how to
    carry.

    Recognised by what it carries rather than by its class, which is what keeps
    :mod:`shiny_mushroom.emu.core` out of this module's imports:
    :class:`~shiny_mushroom.emu.core.CoreBroke` is the only exception in the
    editor with a report for evidence.
    """
    try:
        return _serve(session, request)
    except Exception as exc:
        evidence = getattr(exc, "evidence", None)
        if isinstance(evidence, BrkReport):
            raise BrkRaised(evidence) from exc
        raise


def _serve(
    session: _Session, request: dict[str, Any]
) -> tuple[dict[str, Any], list[bytes]]:
    op = request.get("op")
    if op == "ping":
        return {"pong": True}, []
    if op == "open":
        return session.open_rom(
            Path(request["rom"]),
            request.get("mode", MODE_RENDER),
            audio=bool(request.get("audio", True)),
            base_id=request.get("base"),
            target_id=request.get("target"),
            role_addresses=request.get("addresses"),
            features=request.get("features"),
            role_counts=request.get("counts"),
        ), []
    if op == "load":
        return session.load_level(
            int(request["level"]),
            _patches(request),
            bool(request.get("footprints", False)),
        )
    if op == "overworld":
        return session.load_overworld(
            bool(request.get("palettes", True)), _patches(request)
        )
    if op == "overworld_replay":
        return session.replayed_overworld()
    if op == "player_art":
        return session.player_art()
    if op == "sprite_art":
        return session.sprite_artwork(
            [int(number) for number in request["numbers"]],
            int(request["level"]),
            base64.b64decode(request["header"]),
        )
    if op == "enter":
        return session.enter_level(
            int(request["level"]), _patches(request), request.get("options", {})
        )
    if op == "enter_overworld":
        return session.enter_overworld(request)
    if op == "enter_cartridge":
        return session.enter_cartridge()
    if op == "carry_on_past_brk":
        return session.carry_on_past_brk()
    if op == "beat_level":
        return session.beat_level(bool(request.get("secret", False)))
    if op == "peek":
        return session.peek(int(request["offset"]), int(request["length"]))
    if op == "slots":
        return session.slots(int(request["table"]))
    if op == "loadout":
        return session.loadout(request.get("player", {}))
    if op == "pump":
        return session.pump(
            int(request.get("buttons", 0)),
            int(request.get("seen", 0)),
            request.get("paused"),
        )
    raise RuntimeError(f"unknown request {op!r}")


def _patches(request: dict[str, Any]) -> dict[int, bytes]:
    return {
        int(offset): base64.b64decode(data)
        for offset, data in request.get("patches", {}).items()
    }


def main() -> int:
    """Serve requests until the parent closes the pipe."""
    out = _claim_stdout()
    stdin = os.fdopen(os.dup(0), "rb")

    # A native crash otherwise leaves nothing but a return code. This puts the
    # C-level stack on stderr, which the supervisor captures and attaches to the
    # error it raises.
    faulthandler.enable(file=sys.stderr)

    # The loader logs from *this* process, so the handler has to be installed
    # here too -- the parent's does the child no good across a pipe. Stdout is
    # the protocol channel and claimed above, so this goes to stderr, which the
    # supervisor already captures.
    configure_logging()

    session = _Session()
    try:
        while True:
            try:
                request, _ = protocol.read_message(stdin)
            except protocol.ProtocolError:
                return 0  # the parent went away; that is a normal shutdown
            try:
                header, blobs = _dispatch(session, request)
            except Exception as exc:  # noqa: BLE001 - the boundary reports everything
                reply: dict[str, Any] = {
                    "ok": False,
                    "error": f"{type(exc).__name__}: {exc}",
                }
                # A request that failed because the cartridge hit a BRK comes
                # with the whole report, so the editor can put the exception in
                # front of somebody instead of "the routine did not return".
                report = getattr(exc, "report", None)
                if isinstance(report, BrkReport):
                    reply["brk"] = report.as_dict()
                protocol.write_message(out, reply)
            else:
                # Every successful reply carries whatever BRKs the request met
                # and carried on past -- one custom sprite's exception does not
                # stop a level from loading, and the level's reply is where the
                # editor is listening.
                protocol.write_message(
                    out, {"ok": True, **header, **session.brk_note()}, blobs
                )
    finally:
        session.close()


if __name__ == "__main__":
    raise SystemExit(main())
