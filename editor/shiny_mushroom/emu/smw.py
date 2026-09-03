"""Driving Super Mario World's own level loader.

This is the choreography the emulator needs to turn a level number into a
loaded level, expressed entirely as writes the game itself performs. Every
address and every rule below was read out of the disassembly
(``smw/src/SMW/Routine_Macros_SMW.asm`` and ``RAM_Map_SMW.asm``) and then
confirmed against a running cart; ``docs/editor/emulator-worker.md`` records the
measurements.

The shape of a load:

1. Restore a savestate, so the machine is one the game itself produced. Starting
   from zeroed RAM is not a state SMW ever reaches and papering over that is a
   known source of one-tile-wrong bugs.
2. Patch the cartridge image in memory, if this is a preview of an edit.
3. Write the level request -- four bytes, no code injection, no trampoline.
4. Let the game run until it leaves game mode ``$12``.
5. Stop it dead and step one whole frame, so the frame's own rebuilding of OAM,
   animated tiles and animated colours has happened.
6. Read the memories back.

**Why stop at the end of mode ``$12``.** The load proper is modes ``$11``
(``LoadSublevel``) and ``$12`` (``PrepareLevel``); mode ``$13`` is thirty frames
of fade-in that changes nothing, and mode ``$14`` is the game being played. The
Map16 tilemap captured the frame mode ``$12`` ends is byte-identical to the one
after a full load, so stopping there is free correctness-wise and halves the
wall clock. It also means the stop condition is one byte of work RAM read once
per frame rather than a breakpoint, which keeps Mesen's structure-passing
exports -- the ones that shift between versions -- out of the binding entirely.

**Where the load stops is part of the answer, not an implementation detail.**
The Map16 tilemap is the only part of a snapshot that does not care: it is built
once by the object loop and then left alone. Everything the game rebuilds every
frame -- OAM, the animated tile blocks, the animated colours -- reads back
differently depending on where inside a frame the machine was stopped. The load
is allowed to stop wherever it lands, because :meth:`SmwLevelLoader._capture`
halts and steps one whole frame before reading, which puts the machine on a
boundary for a frame's worth of wall clock rather than a load's.

What a load comes back as is
:class:`~shiny_mushroom.level_snapshot.LevelSnapshot`, which is outside this
package because reading one needs no core.

What the session drives lives beside it rather than in it:
:mod:`~shiny_mushroom.addresses` says where a base keeps everything and
holds the RAM view a capture reads through,
:mod:`~shiny_mushroom.rom_patches` the byte arithmetic over a cartridge
image, :mod:`~shiny_mushroom.emu.sprite_probe` the sprite and player art
capture, :mod:`~shiny_mushroom.emu.overworld_capture` the world map's, and
:mod:`~shiny_mushroom.emu.loading` the waiting, failing and retrying all of
them share. The last two are mixed into :class:`SmwLevelLoader`, which is the
one session that owns the core.
"""

from __future__ import annotations

import logging
import time
from collections.abc import Iterator, Mapping
from contextlib import contextmanager
from dataclasses import dataclass, field, replace
from pathlib import Path
from typing import TYPE_CHECKING

from shiny_mushroom.hexnum import hexnum

if TYPE_CHECKING:
    from shiny_mushroom.overworld_snapshot import OverworldSnapshot

from shiny_mushroom.addresses import (
    BACK_AREA_COLOR,
    BRIGHTNESS_LAST_STEP,
    CAMERA_X,
    CAMERA_Y,
    DEFAULT_ADDRESSES,
    DISABLE_LAYER3_SCROLL,
    EMPTY_MAP16_TILE,
    FADE_IN,
    FADE_MODES,
    FADE_OUT,
    FRAME_COUNTER_GLOBAL,
    GAME_MODE,
    GRAPHICS_SLOTS,
    INTRO_LEVEL_FLAG,
    KEEP_MODE_TIMER,
    LAYER1_DATA_POINTER,
    LAYER1_X,
    LAYER1_Y,
    LAYER2_BG_HIGH,
    LAYER2_BG_LOW,
    LAYER2_BG_SIZE,
    LAYER2_DATA_POINTER,
    LAYER2_X,
    LAYER2_Y,
    LAYER3_SETTING,
    LAYER3_X,
    LAYER3_Y,
    LAYOUT_LAYER1_VERTICAL,
    LEVEL_LAYOUT_FLAGS,
    LOADED_GRAPHICS_FILES,
    MAP16_BANK,
    MAP16_DEF_SIZE,
    MAP16_HIGH,
    MAP16_LOW,
    MAP16_POINTERS,
    MAP16_SIZE,
    MAP16_TILE_COUNT,
    MARIO_MAP,
    MODE_FADE_TO_TITLE,
    MODE_LOAD_SUBLEVEL,
    MODE_PREPARE_LEVEL,
    MODE_PREPARE_TITLE,
    MODE_SHOW_NINTENDO,
    MOSAIC_DIRECTION,
    MOSAIC_FADE_MODES,
    MOSAIC_LAST_STEP,
    MOSAIC_MIRROR,
    NMI_IN_LEVEL,
    NO_ENTRANCE_ROOM,
    NO_GRAPHICS_FILE,
    PIPE_TABLES,
    PIPE_TILES,
    PLAYER_X,
    PLAYER_Y,
    POWERUP,
    REBUILD_BUDGET,
    REBUILD_LANDING_A,
    REBUILD_LANDING_B,
    REBUILD_STUB,
    SCREEN_BRIGHTNESS_MIRROR,
    SCREEN_TO_PLACE_CURRENT,
    SPRITE_LIST_POINTER,
    SUBLEVELS_ENTERED,
    TITLE_MODES,
    TITLE_REANCHOR_FRAMES,
    WRITE_LOG_CAPACITY,
    Addresses,
    RamView,
    _read_long,
)
from shiny_mushroom.brk import MAX_STACK, STACK_TOP, BrkReport
from shiny_mushroom.emu.core import (
    CPU_TYPE_SA1,
    READ_STAMP,
    WRITE_STAMP,
    CoreBroke,
    MesenCore,
)
from shiny_mushroom.emu.footprints import (
    NotObserved,
    attribute,
    attribute_writes,
    boundaries,
)
from shiny_mushroom.emu.loading import LevelLoadError, _through, retry_load
from shiny_mushroom.emu.overworld_capture import OverworldCapture
from shiny_mushroom.emu.sprite_probe import SpriteProbe
from shiny_mushroom.header import HEADER_SIZE
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.memtype import MemoryType
from shiny_mushroom.rom_patches import (
    BRANCH_ALWAYS,
    BRANCH_CARRY_CLEAR,
    BRANCH_NOT_EQUAL,
    PlayerPosition,
    _layer2_level_stream,
    _long,
    background_definitions,
    extra_byte_counts,
    layer1_base,
    layer2_is_background,
    level_request_bytes,
    needs_direct_request,
    object_stream,
    patched_image,
    patches_reach_graphics,
    patches_reach_level_graphics,
    patches_reach_sublevel_setup,
    sprite_base,
    sprite_stream,
)
from shiny_mushroom.sprite_art import SpriteTile

#: Where a load reports what it did. Nothing here configures logging -- a
#: library that installs a handler decides for the application that imports it.
#: The editor turns this on from ``SHINY_MUSHROOM_DEBUG``; see
#: ``docs/editor/emulator-worker.md``.
#:
#: ``INFO`` is one line per load, ``DEBUG`` adds the machine's condition at each
#: sprite capture and names every sprite whose routine did not return. That last
#: one is why this exists: a sprite that hangs and a sprite that legitimately
#: draws nothing both come back as no tiles, and without a log the difference is
#: invisible from outside.
_log = logging.getLogger(__name__)


#: How many frame steps :meth:`SmwLevelLoader._settle` will spend waiting for
#: the game's frame counter to move.
#:
#: Measured frame by frame on both bases, the palette is final within **one**
#: frame of the loader stopping and does not move again -- eight frames of
#: identical CGRAM after it, on five levels. So this is a bound on a step that
#: did not take, not a settling period: three is room for two that do not
#: without being a number that hides a machine which never advances.
SETTLE_FRAMES = 3


@dataclass
class CartSession:
    """A booted cart and the writes that ask it for a level.

    Everything here is common to *looking at* a level and to *playing* one:
    reaching the title screen once, restoring it, previewing edits to the
    cartridge image, and asking the game's own dispatcher to run a load.
    :class:`SmwLevelLoader` stops when the load is done and reads the memories
    out; :class:`~shiny_mushroom.emu.play.PlaySession` lets it carry on into the
    level. Neither restates the choreography.
    """

    core: MesenCore
    state_dir: Path

    #: Where **this cartridge's base** keeps everything read out of the image.
    #:
    #: A session is handed one rather than reading the module constants, because
    #: a project records the base it was built on and a ROM assembled from
    #: another one does not keep its tables in the same places. It defaults to
    #: the default base's, which is what a cartridge opened by hand has.
    addresses: Addresses = DEFAULT_ADDRESSES

    boot_timeout: float = 30.0

    #: A load takes about a fifth of a second, so anything approaching this is
    #: the cart hung rather than the cart being slow. Kept short deliberately:
    #: the recovery is a retry, and waiting half a minute to start it would be
    #: worse than the failure.
    load_timeout: float = 5.0

    #: How long the cart may go without running a frame of the game before an
    #: attempt is written off as hung, rather than waiting out
    #: :attr:`load_timeout`.
    #:
    #: A load legitimately runs with interrupts off, so the frame counter does
    #: stand still for part of one -- measured on an idle host, up to 193 ms on
    #: ``sa1`` and 114 ms on ``vanilla``, both from a cold title state. This is
    #: an order above that so that a busy host, where the same emulation takes
    #: several times the wall clock, is not called hung. What it buys is the
    #: cost of the failure: the retry starts in a second and a half instead of
    #: five, which is what makes retrying more than once affordable.
    stall_timeout: float = 1.5

    #: Seconds to let the machine run after restoring a state and before
    #: writing anything into it. See :meth:`restore`.
    settle: float = 0.004

    _title_state: Path | None = field(default=None, init=False)

    #: A frame boundary in the fade before mode ``$04``, the title preparation.
    #: :meth:`restore_boot` starts a cold run here so the preparation -- the one
    #: pass that reads the overworld sprite slot table -- runs over the image as
    #: previewed. ``None`` when the capture overshot the fade, in which case
    #: cold runs fall back to the title anchor and a slot edit does not show.
    _pretitle_state: Path | None = field(default=None, init=False)

    #: What the cartridge held where the last preview patched it, so the edit
    #: can be taken back. A savestate does not carry the ROM, so a patch applied
    #: for one load is still there for every load after it -- an edit would
    #: outlive the preview that asked for it, and there would be no way back to
    #: the cart short of restarting the worker.
    _pristine: dict[int, int] = field(default_factory=dict, init=False)

    #: ``BRK``\ s this session met and carried on past, waiting to be reported
    #: with whatever reply the request they happened during produces. A sprite
    #: whose code raises one is still a level that loads, so the exception
    #: rides *with* the answer rather than instead of it -- see
    #: :meth:`note_brk`.
    _brks: list[BrkReport] = field(default_factory=list, init=False)

    # -- the exception handler ---------------------------------------------

    def watch_for_brk(self) -> None:
        """Have the core stop at every ``BRK``, and report the ones it catches.

        Turned on once per session, at the point the cartridge is opened, so
        the machine is watched for the whole of its life rather than only
        during whatever somebody thought to guard. What it costs is measured in
        :meth:`~shiny_mushroom.emu.core.MesenCore.watch_for_brk`; what it buys
        is that a cartridge that hits a ``BRK`` says so, in the same words the
        BRK Exception Handler patch would have put on the screen, instead of
        looking like a routine that would not return.
        """
        self.core.on_break = self._brk_report
        self.core.watch_for_brk()

    def note_brk(self, report: object, during: str) -> None:
        """Keep a ``BRK`` that did not stop the request it happened during.

        The sprite probe's case, and the reason this exists: one custom sprite
        whose code raises an exception must not cost the level it is standing
        in -- the capture for that sprite comes back empty, the rest of the
        level renders, and the exception is reported beside it with the sprite
        it came from written on it.
        """
        if isinstance(report, BrkReport):
            self._brks.append(report.about(during))

    def taken_brks(self) -> list[BrkReport]:
        """Every kept ``BRK``, handed over and forgotten.

        Drained rather than read, because the next request is a different
        question: a report is carried by the reply to the request it happened
        during and by no other.
        """
        taken, self._brks = self._brks, []
        return taken

    def _brk_report(self, _source: int, cpu: int) -> BrkReport:
        """Read the stopped machine into a
        :class:`~shiny_mushroom.brk.BrkReport`.

        Called by the core while the ``BRK`` is still the next instruction --
        the registers are the ones it was reached with, and nothing has been
        pushed for it yet, so the stack below is the program's own.

        Everything is read through :attr:`addresses`, which is what makes the
        report right on a base that moved the memory: on ``sa1`` the powerup
        and the layer mirrors are not in work RAM at all.
        """
        core, where = self.core, self.addresses
        state = core.cpu_state(cpu)
        signature = self._program_byte(state.k, state.pc + 1)
        pairs = ((LAYER1_X, LAYER1_Y), (LAYER2_X, LAYER2_Y), (LAYER3_X, LAYER3_Y))
        stack_at, stack, complete = self._stack_dump(state.sp)
        return BrkReport(
            address=state.address,
            signature=signature,
            a=state.a,
            x=state.x,
            y=state.y,
            d=state.d,
            db=state.dbr,
            sp=state.sp,
            ps=state.ps,
            emulation=bool(state.emulation_mode),
            cpu="SA-1" if cpu == CPU_TYPE_SA1 else "SNES",
            game_mode=core.read(*where.at(GAME_MODE)),
            powerup=core.read(*where.at(POWERUP)),
            layers=tuple((self._word(x), self._word(y)) for x, y in pairs),
            stack=stack,
            stack_at=stack_at,
            stack_complete=complete,
        )

    def _program_byte(self, bank: int, address: int) -> int:
        """One byte of what the processor is about to execute.

        Read off the **CPU bus** rather than the cartridge image, because the
        two are not the same thing here: a byte in work RAM executes as
        readily as one in ROM -- this package runs its own stubs from there --
        and the signature byte of a ``BRK`` in a routine somebody copied into
        RAM is in neither the image nor any table.
        """
        return self.core.read(MemoryType.SNES_MEMORY, (bank << 16) | (address & 0xFFFF))

    def _word(self, offset: int) -> int:
        """Two bytes of work RAM, low first, through this base's map."""
        low = self.core.read(*self.addresses.at(offset))
        high = self.core.read(*self.addresses.at(offset + 1))
        return (high << 8) | low

    def _stack_dump(self, sp: int) -> tuple[int, bytes, bool]:
        """What is on the stack, as ``(first address, bytes, whole thing)``.

        A 65816 stack pointer names the next *free* byte, so what has been
        pushed and not pulled is everything above it up to where the stack was
        started -- which is what the handler patch dumps and what says who
        called whom. Capped at :data:`~shiny_mushroom.brk.MAX_STACK`, because a
        program that has just run away can have pushed thousands of bytes and
        the ones nearest the pointer are the ones that say why.
        """
        first = min(sp + 1, STACK_TOP + 1)
        last = min(first + MAX_STACK - 1, STACK_TOP)
        data = bytes(
            self.core.read(*self.addresses.at(at)) for at in range(first, last + 1)
        )
        return first, data, last >= STACK_TOP

    # -- boot --------------------------------------------------------------

    def prepare(self) -> None:
        """Run the cart up to the title screen and remember two states.

        Paid once per worker. Everything after it starts from a restore, so no
        later request pays the ~1.4 s boot again.

        The *pre-title* anchor is halted at a frame boundary in the fade out of
        Nintendo Presents, before mode ``$04`` has run -- so a run restored
        onto it replays the game's own title preparation, which is the one pass
        that reads the overworld sprite slot table (:meth:`restore_boot`). The
        *title* anchor is the arrival state everything else starts from.
        """
        if self._title_state is not None:
            return
        self.state_dir.mkdir(parents=True, exist_ok=True)
        booted = False

        def fading(mode: int) -> bool:
            # Armed by the Nintendo Presents modes -- seconds long, so the
            # poll cannot miss them -- because until the game has zeroed it,
            # the mode byte is whatever power-on RAM happened to hold, and a
            # leftover that reads as a later mode would end the wait over a
            # machine that is not running the game yet.
            nonlocal booted
            booted = booted or mode <= MODE_SHOW_NINTENDO
            return booted and mode >= MODE_FADE_TO_TITLE

        with self.core.running_free():
            self._wait_for(fading, self.boot_timeout, "the fade to the title screen")
        # The fade lasts dozens of frames against the poll's one, so the halt
        # lands well before mode $04; the frame step settles the machine on a
        # clean boundary, the way :meth:`restore` leaves one. Overshooting is
        # checked anyway, because an anchor past the title preparation would
        # not be wrong loudly -- it would be today's stale-sprites behaviour.
        self.core.halt()
        self.core.step_frame(1)
        self.core.halt()
        if self.core.read(*self.addresses.at(GAME_MODE)) < MODE_PREPARE_TITLE:
            state = self.state_dir / "pretitle.mst"
            self.core.save_state(state)
            self._pretitle_state = state
        else:
            _log.warning(
                "the pre-title anchor overshot the title preparation; "
                "overworld sprite slot edits will not reach this worker's runs"
            )
        with self.core.running_free():
            self._wait_for(
                lambda mode: mode in TITLE_MODES, self.boot_timeout, "the title screen"
            )
        state = self.state_dir / "title.mst"
        self.core.save_state(state)
        self._title_state = state

    def reanchor_title(self) -> None:
        """Move the title anchor a few clean frames on from where it was.

        A restore is deterministic, so an anchor that has once derailed a
        request will do it identically on every retry: it was saved at an
        unlucky spot -- mid-frame, with a title transition already in flight
        -- and :meth:`prepare` saves it off a machine the wait left
        *running*, so where it lands is the host scheduler's choice.
        Restoring it and stepping whole frames settles whatever was mid-air
        (the machine is its own here, un-hijacked, so an in-flight handler
        simply finishes), and the state saved there is a sound anchor for
        the retry. If the frames landed in an attract transition, the title
        is waited for again -- the attract loop always comes back to it.
        """
        state = self._title_state
        assert state is not None, "no title anchor to move"
        self.restore(state)
        self.core.step_frame(TITLE_REANCHOR_FRAMES)
        self.core.halt()
        if self.core.read(*self.addresses.at(GAME_MODE)) not in TITLE_MODES:
            with self.core.running_free():
                self._wait_for(
                    lambda mode: mode in TITLE_MODES,
                    self.boot_timeout,
                    "the title screen",
                )
        self.core.save_state(state)

    @property
    def title_state(self) -> Path:
        """The state every cold request starts from. Boots the cart if needed."""
        if self._title_state is None:
            self.prepare()
        assert self._title_state is not None
        return self._title_state

    def restore_boot(self) -> None:
        """Arrive at the title screen through the game's own preparation.

        A cold *run* starts here rather than on the title anchor: restoring
        the pre-title anchor and running to the title replays mode ``$04``
        over the image as :meth:`preview` left it, so a patched overworld
        sprite slot table -- read nowhere else -- reaches the machine. The
        loader's probes stay on the title anchor: they read sprites straight
        off the cartridge image, and the masked-call paths depend on exactly
        where that anchor sits relative to the SPC upload.

        Costs the title preparation and its fade-in over a plain restore --
        measured at ~0.65 s of wall clock per cold run at full speed, which
        is why callers ask for it only when their patches reach the slot
        table (:func:`patches_reach_title_load`) -- and ends halted on a
        frame boundary, exactly as :meth:`restore` does.
        """
        self.prepare()
        if self._pretitle_state is None:
            self.restore(self.title_state)
            return
        self.core.load_state(self._pretitle_state)
        with self.core.running_free():
            self._wait_for(
                lambda mode: mode in TITLE_MODES, self.boot_timeout, "the title screen"
            )
        self.core.halt()
        self.core.step_frame(1)
        self.core.halt()

    # -- the writes a request is made of -----------------------------------

    def restore(self, state: Path, frame: bool = True) -> None:
        """Put the machine back to ``state``, let it settle, and stop it dead.

        Both processors resume mid-instruction from a savestate, so something
        has to run before the machine is a machine again -- and **how much is
        measured in frames of the game, not in milliseconds of the host.** The
        game acts on the game mode once a frame, so a request written into a
        machine that has not completed one is written into a machine that was
        stopped part-way through being restored. On ``sa1`` that request is then
        simply never dispatched: the main CPU sits in SA-1 Pack's ``WAI`` in
        work RAM with the mode still ``$11`` and no frame of the game running.

        Which is why this steps a frame rather than sleeping. A sleep buys an
        amount of emulation that depends on how busy the host is -- 4 ms of it
        bought about a third of a frame on an idle ``sa1`` and less than that
        under load, which is why the failure arrived with load and looked like a
        flake. Measured with the two settles running side by side under the same
        contention, three processes each: **4 stalled attempts in every 24 loads
        on the sleep against 1 on the frame step**, and 690 ms per load against
        500. The saving is the stalls, not the load -- a load costs the same
        either way, and a frame step costs about as much as the sleep did.

        **It is not about where in the frame the halt lands.** Both settles stop
        the machine at the same instruction -- ``$00:1E8F``, inside SA-1 Pack's
        main loop -- with identical CPU state, interrupt bookkeeping included.
        What differs is only whether a whole frame of the game ran first.

        ``frame=False`` is for :meth:`SmwLevelLoader._rebuild`, which does not
        run the game at all: it calls the cartridge's loader routines over the
        machine the warm state left, and a frame of the game over that machine
        is one whose next call does not return. That path keeps the old settle,
        which is all it ever needed -- it is not writing a game mode.

        It ends with a **halt** rather than a pause either way, and that is the
        load-bearing part. ``Pause`` is a request: it returns while the
        emulation thread runs on to a convenient boundary, so a request written
        straight afterwards is racing a machine that is still executing -- the
        four bytes land, the game carries on from where it already was and
        overwrites the game mode, and the cart sits at the title screen until
        the deadline. :meth:`~shiny_mushroom.emu.core.MesenCore.halt` waits for
        the cycle counter to stop moving, which is the only honest signal that
        nothing is executing.
        """
        self.core.load_state(state)
        if frame:
            self.core.step_frame(1)
        else:
            with self.core.running_free():
                time.sleep(self.settle)
        self.core.halt()

    def preview(self, patches: Mapping[int, bytes] | None) -> None:
        """Put ``patches`` into the cartridge image, and take the last set out.

        Withdrawing first is what makes a preview a preview: the ROM is not part
        of a savestate, so an edit stays in the core's copy until something puts
        the original bytes back. Read after the restore, never before, or a byte
        patched twice is remembered as its own edit.
        """
        rom = MemoryType.SNES_PRG_ROM
        for offset, byte in self._pristine.items():
            self.core.write(rom, offset, byte)
        self._pristine.clear()
        if not patches:
            return
        for offset, data in patches.items():
            for index in range(len(data)):
                self._pristine[offset + index] = self.core.read(rom, offset + index)
        self.core.patch_rom(dict(patches))

    def previewed_image(self, patches: Mapping[int, bytes] | None) -> bytes:
        """The cartridge image as :meth:`preview` is about to leave it.

        For a reader that has to answer a question about the image a load is
        *asking for* before the load has been given it --
        :meth:`SmwLevelLoader._rebuildable`, the gate that decides whether the
        load may take the shortcut at all and therefore runs first. The core's
        own copy is not that image and is not the pristine one either: it holds
        the **previous** load's edit until this line withdraws it, so the two
        halves of what :meth:`preview` is about to do are both done here --
        :attr:`_pristine` put back, and ``patches`` laid over what is left.
        """
        image = bytearray(self.core.read_all(MemoryType.SNES_PRG_ROM))
        for offset, byte in self._pristine.items():
            image[offset] = byte
        return patched_image(bytes(image), patches)

    def _write_word(self, address: int, value: int) -> None:
        """A 16-bit little-endian value into work RAM, low byte first."""
        self._write_value(address, value, 2)

    def _write_long(self, address: int, value: int) -> None:
        """A 24-bit little-endian value into work RAM, low byte first."""
        self._write_value(address, value, 3)

    def _write_value(self, address: int, value: int, width: int) -> None:
        """``width`` bytes of ``value``, through the base's RAM map -- which is
        why this is a loop of single writes rather than one bulk one: a base
        with a coprocessor can keep two consecutive game addresses in two
        different memories."""
        for byte in range(width):
            self.core.write(
                *self.addresses.at(address + byte), (value >> (8 * byte)) & 0xFF
            )

    @contextmanager
    def over_scratch_state(self, name: str) -> Iterator[Path]:
        """Save the machine, run the block, and put the machine back.

        A probe tramples slots, the camera and OAM, and whatever runs after it
        -- another probe, a warm state captured from this machine -- is
        entitled to the machine it had. The path is yielded because a probe
        that drives several sprites restores it between them as well.
        """
        scratch = self.state_dir / name
        self.state_dir.mkdir(parents=True, exist_ok=True)
        self.core.save_state(scratch)
        try:
            yield scratch
        finally:
            self.core.load_state(scratch)
            scratch.unlink(missing_ok=True)

    def skip_entrance_room(self, level: int) -> None:
        """Set ``level``'s no-entrance-room bit in the cartridge image.

        It is one bit of a table the loader reads to decide *which room the
        player walks into*, and asking for a level usually means the level:
        without it the levels that have an entrance room load the doorway
        instead, and no amount of editing the level's own data changes what
        comes back.

        **Remembered like a preview patch, and withdrawn by the next one.**
        The bit lasts for the load it was set for and no longer, which is what
        lets a later run ask for the entrance room and get it -- left in the
        image, it would silently answer for every run of that level for the
        rest of the session. Called after :meth:`preview`, so the byte
        remembered here is the one the patches left, and a patch of this same
        byte keeps its own record of the original.
        """
        where = self.addresses
        offset = where.offset(where.secondary_header_entrance + level)
        entry = self.core.read(MemoryType.SNES_PRG_ROM, offset)
        if not entry & NO_ENTRANCE_ROOM:
            self._pristine.setdefault(offset, entry)
            self.core.patch_rom({offset: bytes([entry | NO_ENTRANCE_ROOM])})

    def request_level(self, level: int) -> None:
        """Write the four bytes that make the game load ``level``.

        No code injection and no trampoline: ``SpecifySublevelToLoad`` reads all
        of this itself, and the game's own dispatcher does the rest.

        **Only inside :meth:`direct_level_numbers`** for a level the plain
        request cannot spell, which is what makes the bytes
        :func:`level_request_bytes` returns for one mean what they say.
        """
        flag, map_index = level_request_bytes(level)
        where, write = self.addresses, self.core.write
        write(*where.at(SUBLEVELS_ENTERED), 0)
        write(*where.at(INTRO_LEVEL_FLAG), flag)
        write(*where.at(MARIO_MAP), map_index)
        write(*where.at(GAME_MODE), MODE_LOAD_SUBLEVEL)

    @contextmanager
    def direct_level_numbers(self, level: int) -> Iterator[None]:
        """Hold the cartridge able to be asked for ``level``, then put it back.

        A fifth of the cartridge is unreachable through ``$7E0109`` not for
        want of data but for how the request is spelled, and one branch is in
        the way of each half of it: the test that reads ``$00`` as "no
        override", and the one that skips the ``-$24`` adjustment. Whichever
        stands between the machine and this level is a ``BRA`` for the length
        of the load, and the game's own byte again afterwards -- the image is
        shared with a session that plays the cartridge, and a permanent ``BRA``
        there would mean a game that could never enter a level from the map.

        Nothing at all for the levels the plain request already reaches, which
        is all but 74 of them: their bytes go through the routine exactly as
        they did before, and the branch is never touched.

        Raises ``ValueError`` for a cartridge whose branch is not the game's.
        The alternative is worse than a refusal -- writing an unadjusted low
        byte to a routine that still subtracts ``$24`` loads a different level
        and says nothing -- and a hijacked branch is a real thing to find on a
        patched image.
        """
        if not needs_direct_request(level):
            yield
            return
        where, low = self.addresses, level & 0xFF
        address, opcode = (
            (where.level_override_branch, BRANCH_NOT_EQUAL)
            if low == 0x00
            else (where.level_adjust_branch, BRANCH_CARRY_CLEAR)
        )
        offset = where.offset(address)
        found = self.core.read(MemoryType.SNES_PRG_ROM, offset)
        if found != opcode:
            raise ValueError(
                f"level {hexnum(level, 3)} can only be asked for by patching the "
                f"branch at {hexnum(address, 6)}, which holds "
                f"{hexnum(found)} rather than the game's {hexnum(opcode)} -- "
                f"something has hijacked it"
            )
        self.core.patch_rom({offset: bytes([BRANCH_ALWAYS])})
        try:
            yield
        finally:
            self.core.patch_rom({offset: bytes([opcode])})

    # -- watching the game mode --------------------------------------------

    def _wait_for_load(self) -> None:
        """Run until the game has left mode ``$12``.

        Entering ``$12`` is required before leaving it counts: the request has
        only just been written, so the mode is still ``$11`` and "not $12" is
        true for a reason that has nothing to do with being finished.

        **This stops somewhere inside a frame, and that is fine because
        :meth:`_capture` finishes the frame before reading.** Driving the whole
        load a frame at a time was measured and rejected: the cost is
        ``step_frame``'s per-step handshake rather than the frames themselves,
        which run unthrottled here because :meth:`MesenCore.load_rom` leaves
        maximum speed set, so the 23 frames a load takes cost 351 ms against
        about 100 ms of free-running -- and the extra determinism it bought
        over one frame step at the end was one VRAM hash out of twelve.

        **How many frames run before the stop is a fact about the host, not
        about the game.** On an idle machine the counter reads ``$10`` at the
        end of every load, so all that is at stake is where inside the last
        frame the machine stopped, and one step settles that. Under contention
        the poll returns late and the free run carries on meanwhile, so the
        count itself moves -- see :meth:`_wait_for`. Anything read afterwards
        whose value depends on elapsed frames has to pin that for itself; the
        level captures do, by pinning the frame counters before probing.
        """
        self._wait_for(
            _through(MODE_PREPARE_LEVEL),
            self.load_timeout,
            "a loaded level",
            requested=True,
        )

    def _wind_fade_forward(self) -> None:
        """Put whatever fade the machine is in on its last step.

        Thirty frames stand between a loaded level and a running one, and
        between a loaded overworld and a running one -- the same routine both
        times. Winding it costs three writes and leaves one frame in its place.

        The game's own routine still runs it: what is written is the state it
        would have reached twenty-eight frames later, so its next step is the
        one that hands over to the mode after this. Nothing is forced -- the
        mode is not written and the handover is not skipped -- which is what
        keeps the machine one the game can carry on running.

        **Which way it is going is read rather than tabulated.** ``$0DAF`` is
        what the routine itself indexes its two directions with, so a fade out
        winds to ``$01`` on its way to ``$00`` exactly as a fade in winds to
        ``$0E`` on its way to ``$0F``, and neither direction is a special case
        here.

        **The mosaic is only wound for the two modes that step it.** Entering at
        ``Main`` rather than ``MosaicFade`` leaves the mosaic mirror alone but
        still writes ``$2106`` from it every step, so winding it during a plain
        fade would put a mosaic on a screen that was not going to have one.

        **Guarded on the mode**, because these bytes mean something else outside
        a fade: ``$0DAE`` is the live brightness the whole time, and writing a
        fade's worth of it into a machine that is not fading would dim a screen
        nobody asked to fade. Anywhere else this does nothing, and the caller's
        own bounded wait covers it.
        """
        core, where = self.core, self.addresses
        mode = core.read(*where.at(GAME_MODE))
        if mode not in FADE_MODES:
            return
        direction = FADE_OUT if core.read(*where.at(MOSAIC_DIRECTION)) else FADE_IN
        core.write(*where.at(SCREEN_BRIGHTNESS_MIRROR), BRIGHTNESS_LAST_STEP[direction])
        if mode in MOSAIC_FADE_MODES:
            core.write(*where.at(MOSAIC_MIRROR), MOSAIC_LAST_STEP[direction])
        # The routine steps every *other* frame, off this timer. Clearing it
        # spends the odd frame the machine happened to stop on.
        core.write(*where.at(KEEP_MODE_TIMER), 0)

    def _wait_for(
        self,
        predicate,
        timeout: float,
        description: str,
        requested: bool = False,
        floor: int = MODE_LOAD_SUBLEVEL,
    ) -> None:
        """Poll the game mode until ``predicate`` accepts it.

        ``requested`` says a level request has just been written, and turns on
        the two ways that can fail outright -- both of which are worth spotting
        early, because the recovery is a retry and the wait before it is dead
        time:

        - **The cart stops running the game.** The frame counter is bumped by
          the game's own VBlank handler, so a counter standing still means no
          frame of the game is being reached at all. On ``sa1`` the state is
          visible directly: the main CPU sits in SA-1 Pack's ``WAI`` in work
          RAM waiting for an interrupt that is not coming, with the game mode
          still ``$11``. Waiting longer does not change it.
        - **The cart goes back below ``floor``.** Every mode a level load
          passes through is ``$11`` or above, so a lower one means the request
          is gone -- measured, a cart that reset itself and walked ``$00``
          upward to the title screen. An *overworld* load runs through
          ``$0C``-``$0E``, all below ``$11``, which is what ``floor`` is for:
          that caller passes the overworld's own lowest legitimate mode.

        Off for the boot, where neither holds: the game is not running yet by
        definition and its modes start at ``$00``.

        The failure carries the *sequence* of modes rather than only the last,
        because that is what tells those two apart from a cart that was merely
        slow.
        """
        deadline = time.monotonic() + timeout
        seen: list[int] = []
        frame, moved = self._frame(), time.monotonic()
        while time.monotonic() < deadline:
            if self.core.broke_on_brk:
                # A cartridge stopped at a BRK is not going to reach another
                # game mode, and the stall detector below would spend
                # `stall_timeout` finding that out. The report is gathered here
                # rather than there because the evidence is the stopped machine
                # itself -- see `MesenCore.take_break`.
                raise CoreBroke(
                    f"the cartridge hit a BRK while waiting for {description}",
                    self.core.take_break(),
                )
            mode = self.core.read(*self.addresses.at(GAME_MODE))
            if not seen or seen[-1] != mode:
                seen.append(mode)
            if predicate(mode):
                return
            if requested:
                if mode < floor:
                    raise LevelLoadError(
                        f"the cart left the load without reaching {description} "
                        f"({self._modes(seen)}, {self._parked()})"
                    )
                now = self._frame()
                if now != frame:
                    frame, moved = now, time.monotonic()
                elif time.monotonic() - moved > self.stall_timeout:
                    raise LevelLoadError(
                        f"the cart stopped running the game before reaching "
                        f"{description} ({self._modes(seen)}, no frame in "
                        f"{self.stall_timeout:g}s, {self._parked()})"
                    )
            # Slow enough not to spin a core reading one byte, and on an idle
            # host fast enough to notice the mode within a frame of the write.
            #
            # **It is not a bound on the overshoot.** The sleep is a floor
            # rather than a period and the core free-runs through it, so a host
            # under load returns late and the game keeps going: measured, a
            # 30 ms sleep leaves an overworld load stopped anywhere from the
            # frame an idle host stops on to five frames past it. What is read
            # afterwards must not depend on which of those it was.
            time.sleep(0.002)
        raise LevelLoadError(
            f"the cart did not reach {description} within {timeout:g}s "
            f"({self._modes(seen)}, {self._parked()})"
        )

    def _frame(self) -> int:
        """The game's own frame counter, which only its VBlank handler moves."""
        return self.core.read(*self.addresses.at(FRAME_COUNTER_GLOBAL))

    @staticmethod
    def _modes(seen: list[int]) -> str:
        return "game modes " + " ".join(hexnum(mode) for mode in seen)

    def _parked(self) -> str:
        state = self.core.cpu_state()
        return f"stopped at {hexnum(state.k)}:{state.pc:04X}"


@dataclass
class SmwLevelLoader(SpriteProbe, OverworldCapture, CartSession):
    """Loads levels by running the cart, reusing state between requests.

    Two savestates matter. The *title* state is taken once and is the cold
    starting point: every graphics slot will be reloaded from it. A *warm* state
    is taken after each successful load and reused when the same level is asked
    for again -- which is exactly what an editor does between edits -- because
    SMW skips graphics files already present and mode ``$11`` does not
    invalidate that cache. Measured, the difference is 114 ms against 76 ms.

    Warm reuse is deliberately restricted to the same level number. Reusing one
    level's state to load another would probably work and would probably be
    faster, but "probably" is not a basis for a renderer: it has not been
    verified to produce output identical to a cold load, and a subtly stale
    tileset is precisely the failure this whole approach exists to avoid.

    **A patched load can use neither**, which is why the sprite capture is
    cached separately: an edit invalidates the warm state, and the capture is
    more than half of what a load costs. See :attr:`_art`.
    """

    #: How many post-load states to keep. Each is about 100 KB on disk.
    warm_cache_size: int = 8

    _warm: dict[int, Path] = field(default_factory=dict, init=False)

    #: Whether a frame of the *game* may be run on the machine as it stands.
    #:
    #: False after a rebuild, and that is the whole of what it is for. A rebuild
    #: calls the loader's routines over a state that was already in mode ``$14``,
    #: so the machine is mid-surgery: the object loop uses the direct page as
    #: scratch, and stepping a frame runs the main loop over it. See
    #: :meth:`_capture`, which refuses its settling frame for this reason --
    #: this is the same refusal, available to the paths that come *after* a load
    #: rather than during one. A hovered sprite is captured on whatever machine
    #: the last load left, so it needs the answer as much as the load did.
    _game_runnable: bool = field(default=True, init=False)

    #: How many sprite captures to keep. A few tiles each, and one entry per
    #: *sprite number* rather than per level, so this is a bound on nothing
    #: much; it exists so a session that visits every level in the cartridge
    #: does not keep all of them.
    art_cache_size: int = 512

    #: Captured sprite artwork, keyed by everything it is a function of --
    #: ``(level, header, number, position)``. See :meth:`_sprite_art` for why
    #: that key is the whole of it, and why this cache is worth having.
    _art: dict[tuple[int, bytes, int, tuple[int, int]], tuple[SpriteTile, ...]] = field(
        default_factory=dict, init=False
    )

    #: Keys that have drawn nothing **once**, and so are not in :attr:`_art` yet.
    #: A second empty answer is what puts one there -- see :meth:`_remember_art`.
    _silent: set[tuple[int, bytes, int, tuple[int, int]]] = field(
        default_factory=set, init=False
    )

    #: How many traced object loops to keep. One list of block offsets per
    #: object, so a few kilobytes for the largest level.
    trace_cache_size: int = 16

    #: What the object loop drew, keyed by ``(level, header, object stream)``.
    #: See :meth:`_trace_key`.
    _traces: dict[tuple[int, bytes, bytes], tuple[frozenset[int], ...]] = field(
        default_factory=dict, init=False
    )

    #: The header each warm state was captured with. A rebuild starts on a
    #: machine holding that level's graphics and does not load any, so it is
    #: only valid while the header still asks for the same ones.
    _warm_headers: dict[int, bytes] = field(default_factory=dict, init=False)

    #: The level the machine is currently sitting in, so that letting it run on
    #: knows which one to put back when it ends.
    _current: int | None = field(default=None, init=False)

    #: The overworld capture, held for the session once taken: the overworld
    #: is one place, and re-entering the mode should not cost seven loads
    #: again. Keyed on :attr:`_overworld_patches`, because the one thing that
    #: does change what a capture shows is the image it was run over.
    _overworld: OverworldSnapshot | None = field(default=None, init=False)

    #: The patches :attr:`_overworld` was captured under, as
    #: :func:`patch_key` spells them -- a project's edited graphics files,
    #: today. A capture made under one set is not an answer for another: the
    #: game decompresses the map's files into VRAM during the load, so a
    #: patched file shows only in a capture run over the patched image.
    _overworld_patches: tuple[tuple[int, bytes], ...] = field(default=(), init=False)

    #: Whether the core's write log -- the patched-in one, see
    #: :meth:`MesenCore.set_write_log_range` -- has been pointed at the Map16
    #: low table. Armed once; the registration survives restores.
    _write_log_armed: bool = field(default=False, init=False)

    # -- loading -----------------------------------------------------------

    def load(
        self,
        level: int,
        patches: Mapping[int, bytes] | None = None,
        footprints: bool = False,
    ) -> LevelSnapshot:
        """Load ``level``, optionally previewing edits to the cartridge image.

        ``patches`` maps an offset in the headerless ROM to the bytes to put
        there. They are applied to the core's copy only; nothing on disk
        changes and no rebuild happens, so previewing an edit costs a level
        load rather than an asar pass.

        ``footprints`` reads which blocks each object drew out of the core's
        write log after the loop has run (:attr:`LevelSnapshot.footprints`) --
        or, on a core without the patch, which it left visible out of the
        access counters. Off by default not for cost -- the read is ~2 ms on a
        ~50 ms refresh -- but because the answer has no consumer on a plain
        render: it is asked for when something is going to be selected or
        outlined.
        """
        title = self.title_state
        # Raises for a level this path cannot express, before anything is done
        # to the machine.
        level_request_bytes(level)
        started = time.monotonic()

        # A patched image invalidates any warm state, which was captured with
        # the unpatched bytes already expanded into WRAM and VRAM.
        warm = None if patches else self._warm.get(level)

        # The shortcut where it applies -- the same routines the game mode would
        # have run, without the graphics and palette work an edit cannot reach.
        # It cannot hang the way a game mode can (it is one bounded call), so it
        # is outside the retry; a failure here is a bug, not a flaky handshake.
        rebuild = self._rebuildable(level, patches)
        if rebuild is not None:
            return self._finish(
                level,
                started,
                self._rebuild(rebuild, level, patches, footprints),
                patches,
                settle=False,
            )

        traced = self._attempting(warm, title, level, patches, footprints)
        return self._finish(level, started, traced, patches)

    def _attempting(
        self,
        warm: Path | None,
        title: Path,
        level: int,
        patches: Mapping[int, bytes] | None,
        footprints: bool,
    ) -> tuple[frozenset[int], ...]:
        """Run the game mode, retrying a cart that stops running the game.

        The failure is a machine that never dispatches the request: the mode
        stays ``$11``, no frame of the game runs, and on ``sa1`` the main CPU
        can be seen parked in SA-1 Pack's ``WAI``. It comes of forcing a game
        mode onto a machine restored mid-frame, so which state the request was
        written into is the whole of what varies -- and restoring the title
        state, on a machine allowed to settle, is what clears it.

        So every retry goes back to the title state, and the state that
        produced the failure is not tried again as it stands: a warm one is
        dropped, and the title anchor itself is **moved** -- a restore is
        deterministic, so a title state that has failed once would fail every
        retry identically (see :meth:`reanchor_title`). Retried at all only
        for this: a level number that cannot be requested raises before any
        of this runs, so reaching here means the machine hung rather than the
        request being wrong.
        """

        def run(attempt: int) -> tuple[frozenset[int], ...]:
            return self._attempt(
                title if attempt else (warm or title), level, patches, footprints
            )

        def recover(attempt: int) -> None:
            # The warm state is only ever the first attempt's, so which one
            # failed says which of the two anchors has to go.
            if warm is not None and attempt == 0:
                self._warm.pop(level, None)
                self._warm_headers.pop(level, None)
                warm.unlink(missing_ok=True)
            else:
                self.reanchor_title()

        return retry_load(
            run, f"level {hexnum(level, 3)}", recover, "retrying from the title screen"
        )

    def _finish(
        self,
        level: int,
        started: float,
        traced: tuple[frozenset[int], ...],
        patches: Mapping[int, bytes] | None,
        settle: bool = True,
    ) -> LevelSnapshot:
        """Read the machine back, whichever way the level got there.

        ``patches`` is not decoration: a warm state is only taken from an
        **unpatched** load. One captured after a preview holds that edit already
        expanded into work RAM, so the next load starting from it would layer a
        second edit over the first -- and a rebuild starting from it would be
        rebuilding the wrong level. It has no default for that reason.
        """
        # Timed *around* the capture and not up to it. The capture is a sprite
        # probe, and a probe is a savestate and three traced calls per sprite
        # number -- on a cold level $105, 367 ms against the 250 the load itself
        # takes. A duration that stopped before it was the smaller half of what
        # the caller waited for, reported as the whole.
        snapshot = replace(
            self._capture(level, 0.0, traced, settle=settle),
            duration=time.monotonic() - started,
        )

        if not patches:
            self._remember_warm(level)
            self._warm_headers[level] = snapshot.header
        self._current = level
        drew = sum(1 for tiles in snapshot.sprite_art.values() if tiles)
        # Named, not just counted. A sprite drawn as a glyph is a number whose
        # capture came back empty, and which one it was is the whole question --
        # a count of them cannot be told apart from a level that legitimately
        # holds a trigger or a warp hole.
        silent = ", ".join(
            hexnum(number)
            for number, tiles in sorted(snapshot.sprite_art.items())
            if not tiles
        )
        # The two stream lengths are here because a load that came back with the
        # *wrong* level is otherwise indistinguishable in a log from one that
        # came back with the right one: they are what a caller previewing an
        # edit can check its own bytes against. See `_run_loader`, where a
        # rebuild resolves the sprite list pointer rather than carrying it.
        _log.info(
            "level $%03X loaded in %.0f ms: %d sprite numbers, %d with art%s, "
            "%d objects, streams %d/%d bytes%s",
            level,
            snapshot.duration * 1000,
            len(snapshot.sprite_art),
            drew,
            f", none for {silent}" if silent else "",
            len(snapshot.footprints),
            len(snapshot.objects),
            len(snapshot.sprites),
            " (previewing edits)" if patches else "",
        )
        return snapshot

    # -- rebuilding a level without the game mode --------------------------

    def _rebuild(
        self,
        state: Path,
        level: int,
        patches: Mapping[int, bytes] | None,
        trace: bool,
    ) -> tuple[frozenset[int], ...]:
        """Rebuild the tilemap by calling the loader, not by running the game.

        The same routines the cartridge runs, in the same order, on a machine
        that already holds this level's graphics -- so what is skipped is
        exactly what an object or sprite edit cannot change: graphics
        decompression, the palette upload, the PPU tile buffering and the mode
        ``$13`` fade. Measured on level ``$105``, 149 ms of game-mode path
        becomes 30 ms of loader.

        It is not a faster loader. It is the same loader with the parts an edit
        does not reach left out, which is why the answer is byte-identical
        rather than merely close -- verified over eleven levels and three edits
        each, across both orientations, Layer 2 *levels*, a Layer 3 tide level
        and a header edit.

        Everything the routines need beyond the four values written here they
        re-derive from the level's five header bytes, so this follows a header
        edit rather than having to be told about one. What it cannot follow is
        a header edit's *graphics*, which is why :meth:`_rebuildable` refuses
        one.
        """
        # Without a frame of the game: the routines below are called over this
        # machine rather than run by it, and one that has been let run a frame
        # from a warm state is one whose first call does not return. See
        # `CartSession.restore`.
        self._arm_write_log()
        self.restore(state, frame=False)
        self.preview(patches)
        key, remembered = self._traced_before(level, trace)

        self._clear_tilemap()
        # One read of the patched image for both: they follow two of its pointer
        # tables, and it is half a megabyte.
        rom = self.core.read_all(MemoryType.SNES_PRG_ROM)
        self._prime_loader(level, rom)
        self._run_loader(level, rom)
        # And from here the machine is not one the game can be run on. See
        # :attr:`_game_runnable`; the next full load is what clears it.
        self._game_runnable = False
        if not trace:
            return ()
        return self._traced_after(level, key, remembered)

    def _rebuildable(
        self, level: int, patches: Mapping[int, bytes] | None
    ) -> Path | None:
        """The state to rebuild ``level`` over, or None to run the game mode.

        Four things have to hold, and each of them is a way the shortcut would
        be wrong rather than merely slow:

        - **There is a warm state for this level.** The rebuild does not load
          graphics, so it has to start on a machine already holding this
          level's. Another level's would render the right tilemap with the
          wrong artwork, silently.
        - **The header has not changed** -- the header *this load is asking
          for*, which is the one its patches carry and not the one sitting in
          the core's copy of the cartridge. Those are different bytes at this
          point, because the patches are applied by :meth:`preview` further
          down and what the image holds until then is the previous load's edit.
          Read from the core's copy, the check could never see the change it
          exists to catch: a header edit is exactly the case where the tileset
          *has* moved and its graphics are the point of it, and measured, a
          rebuild after one gives the right tilemap over 3.5 KB of the previous
          tileset's VRAM. :meth:`~CartSession.previewed_image` is the image to
          ask.
        - **There is something to preview.** An unpatched load is what
          *captures* the warm state, and it is not the path an edit takes.
        - **The patch stays out of the sublevel setup tables.** What the rebuild
          does not run is ``SMW_SpecifySublevelToLoad``, and an edit to what
          *that* reads is one it can only answer with the previous load's
          value -- see :func:`sublevel_setup_tables` for the whole list and why
          the rest of it is safe.
        - **The patch touches no graphics file.** The other thing the rebuild
          does not run is the graphics upload, and the warm state holds the
          unpatched file already expanded into VRAM -- see
          :func:`patches_reach_graphics`.
        - **The patch touches no level graphics row.** The same upload is
          where a row is read: the overlay that lays a level's eight slots
          over its tilesets' files, and the stub that expands the level's own
          animated tiles into WRAM -- see
          :func:`patches_reach_level_graphics`.
        """
        if not self.addresses.driven.rebuild:
            # A base on which nothing has established that the setup here
            # reaches the memory the object loop reads. No base in the registry
            # declares that today; a feature that moved the loop could. The
            # fallback is the full load, which is slower and never wrong --
            # see `DrivenPaths.rebuild`.
            return None
        if not patches:
            return None
        if patches_reach_sublevel_setup(patches, self.addresses):
            return None
        warm = self._warm.get(level)
        if warm is None or self._warm_headers.get(level) is None:
            return None
        # The image as this load will see it, which is what all three questions
        # below are about: which files the graphics pointers name, where the
        # level's record is, and what its first five bytes say. Each is a
        # pointer or a window followed *through* the edit rather than around
        # it -- a stream that grew is relocated and repointed through the same
        # table it is read from -- and none of them is a question about the
        # image the core happens to be holding, which is the last load's.
        image = self.previewed_image(patches)
        if patches_reach_graphics(patches, image, where=self.addresses):
            return None
        if patches_reach_level_graphics(patches, image, where=self.addresses):
            return None
        try:
            base = layer1_base(image, level, where=self.addresses)
        except ValueError:
            return None
        if image[base : base + HEADER_SIZE] != self._warm_headers[level]:
            return None
        return warm

    def _clear_tilemap(self) -> None:
        """Empty the Map16 buffer, as ``SMW_InitializeLevelData`` does.

        One ``read_all`` and one ``write_all`` -- 0.15 ms -- in place of 512
        unrolled passes of 56 long stores, which is about a third of what a
        whole ``LoadSublevel`` costs.

        **The fill value is the one assumption in the whole rebuild**, and it is
        not a free one: the empty tile is what a *merging* object reads when it
        looks at the cell it is about to write, and
        ``SMW_StandardObj13_GroundEdgesAndVine`` tests for ``$25`` by name. Fill
        with anything else and 18% of the cart's objects quietly draw a
        different tile -- observed, when this was first written to read the fill
        back from the cartridge instead and got ``$00``: sixty-two entries came
        out wrong, and all but one of them were merge decisions rather than the
        fill itself.

        So it is stated here rather than derived, and it is what
        :meth:`_rebuildable`'s whole justification rests on being checkable: a
        cartridge whose buffer this does not describe produces a tilemap that
        differs from a full load, which is exactly what `tmp/verify_rebuild.py`
        compares.
        """
        self._fill(MAP16_LOW, bytes([EMPTY_MAP16_TILE]) * MAP16_SIZE)
        self._fill(MAP16_HIGH, bytes(MAP16_SIZE))

    def _fill(self, offset: int, data: bytes) -> None:
        """Write a run of bytes into whichever memory this base keeps it in.

        Whole-memory rather than byte at a time: 14 kB of ``SetMemoryValue`` is
        slower than the level load it is trying to avoid. Which memory is the
        base's answer, so on SA-1 this splices BW-RAM and on vanilla work RAM,
        with the same two calls either way.
        """
        memory, at = self.addresses.at(offset)
        held = bytearray(self.core.read_all(memory))
        held[at : at + len(data)] = data
        self.core.write_all(memory, bytes(held))

    def _prime_loader(self, level: int, rom: bytes) -> None:
        """Put back the values ``LoadSublevel`` sets before the loop runs.

        **Both layer pointers come from the patched image's own tables**, which
        is the same trap :meth:`_run_loader` describes for the sprite list:
        ``SMW_SpecifySublevelToLoad`` is what copies ``Layer1DataPtrs`` and
        ``Layer2DataPtrs`` into ``$65`` and ``$68``, it runs at the top of the
        game mode rather than inside the loader, and so a rebuild never runs it.

        For Layer 1 the warm state's copy is useless because the loop walks it
        to the end of the stream and leaves it there. For Layer 2 it is worse
        than useless: it is where the *previous* load's Layer 2 was, so a
        repointed Layer 2 came back as the background it used to have. The bank
        byte is part of the same three, which also puts back the ``$FF``
        "this level's Layer 2 is a background" marker that a load overwrites
        with ``$0C`` -- see ``LM_JMLHere_OriginalBG``.
        """
        where = self.addresses
        write = self.core.write
        self._write_long(
            LAYER1_DATA_POINTER, where.address(layer1_base(rom, level, where=where))
        )
        entry = where.offset(where.layer2_pointers + level * 3)
        for byte in range(3):
            write(*where.at(LAYER2_DATA_POINTER + byte), rom[entry + byte])
        # LoadSublevel STZs this; BeginLoadingLevelData does not.
        write(*where.at(SCREEN_TO_PLACE_CURRENT), 0)

    def _run_loader(self, level: int, rom: bytes) -> None:
        """The two routines that build a level's tilemaps, as one call.

        ``SMW_InitializeLevelLayer3`` is not optional even for a level with no
        Layer 3: ``GenerateInteractiveTideWater`` inside it zeroes ``$B0``
        bytes in each of sixteen Layer 2 screens, and without it a tide level
        comes back 2,816 bytes different.

        **The sprite list pointer is resolved here, from the patched image.**
        Only ``SMW_SpecifySublevelToLoad`` writes it, and that runs at the top
        of the game mode rather than inside the loader -- so a rebuild does not
        set it, and the object loop uses that direct-page word as scratch. Left
        alone it comes back holding opcode bytes and :meth:`_capture` follows it
        into nowhere; carried across from the state being rebuilt over it points
        at where this level's sprites were **before the edit**, which is the
        same trap :meth:`_prime_loader` avoids for Layer 1. A stream that has
        grown is relocated by :func:`level_patch` and the pointer table
        repointed, so the old pointer still resolves -- to the pre-edit stream.
        Every sprite edit that grew the stream then came back invisible: the
        picture is the game's, but which sprites are in the level is read
        through this word.

        So it is worked out the way the game works it out, off the table
        :func:`sprite_base` follows, and written after the call rather than
        before it because the loop is what tramples it.
        """
        address = self.addresses.address(sprite_base(rom, level, where=self.addresses))
        self._call_chain(
            [
                (self.addresses.begin_loading_level_data, False),
                (self.addresses.initialize_level_layer3, False),
            ]
        )
        self._write_long(SPRITE_LIST_POINTER, address)
        # An INC rather than a store, so chained rebuilds count it up and wrap
        # every 256 -- at which point Layer 3 starts scrolling on its own.
        self.core.write(*self.addresses.at(DISABLE_LAYER3_SCROLL), 0)

    def _call_chain(
        self, targets: list[tuple[int, bool]], *, resume: bool = True
    ) -> None:
        """Run cartridge routines back to back in one call, with NMI masked.

        ``targets`` is ``(address, ends_in_rtl)``. **Most of the loader ends in
        ``RTS``**, and :meth:`~shiny_mushroom.emu.core.MesenCore.call` reaches
        its target with a ``JSL`` -- so an ``RTS`` keeps the program bank and
        returns into ``$05:2003``, which is PPU register space and will not
        execute. Each one therefore gets a return address pushed by hand and a
        landing **in its own bank**. Banks ``$00``-``$3F`` mirror the low 8 KB
        of work RAM and window BW-RAM's first 8 KB, so a landing in either is
        reachable from bank ``$00`` and bank ``$05`` at once -- which is one
        address on a console and another on a cartridge that moved the memory,
        and why the landings are offsets
        :meth:`~shiny_mushroom.addresses.Addresses.landing` resolves rather than
        numbers. On ``sa1`` the S-CPU fetches these two blocks out of the
        BW-RAM window, measured.

        ``SEP #$30`` before each, because these routines take their register
        widths from the caller and the game's own callers are 8-bit throughout.
        Entering ``InitializeLevelLayer3`` straight off the object loop's
        ``RTS`` leaves the accumulator 16-bit, and it silently skips the tide's
        tilemap writes.

        One call rather than one per routine: the game's own loader runs with
        NMI off (mode ``$11`` opens with ``STZ $4200``), so it is masked for the
        whole chain and put back inside it.

        ``resume=False`` leaves NMI masked at the tail. For a caller that has
        more to stage before a frame of the game may run: the spin after the
        chain sits in the pause's host latency, and with NMI live every VBlank
        in it runs a whole frame -- this game runs its frame from the NMI
        handler -- over whatever the chain left. Such a caller puts the
        setting back with :meth:`MesenCore.resume_interrupts` when it is
        ready.
        """
        where = self.addresses
        # Keyed by where the block is *written* -- the memory and offset a core
        # write takes -- because the stub is a work-RAM address and a landing is
        # an offset this base places, and the two need not be the same memory.
        blocks: dict[tuple[MemoryType, int], bytes] = {}
        spare = [REBUILD_LANDING_A, REBUILD_LANDING_B]
        # One landing per routine that ends in RTS, and there are two of them.
        # A third would be given the landing the tail block is written at and
        # silently overwritten -- a chain that runs the wrong code rather than
        # one that fails -- so it is refused instead.
        returning = sum(1 for _, rtl in targets if not rtl)
        if returning > len(spare):
            raise ValueError(
                f"a call chain has {len(spare)} landing addresses, so it can "
                f"hold that many routines ending in RTS, not {returning}"
            )
        # The stub is work RAM by name and deliberately so: this is 65816 to be
        # *executed*, not game state to be read, and a base that moved the
        # game's memory did not move the console's. `$7E:2000` upward is
        # untouched even under SA-1 Pack, which runs its own interrupt handlers
        # and call gate from work RAM for the same reason -- code there leaves
        # the ROM bus free. The landings cannot be: they have to sit where an
        # `RTS` in bank $05 can reach them, which is the low mirror or the
        # BW-RAM window, and what is dead there is a fact about the base.
        into = (MemoryType.SNES_WORK_RAM, REBUILD_STUB & 0xFFFF)
        body = bytes((0xA9, 0x00, 0x8D, 0x00, 0x42))  # LDA #$00 : STA $4200
        for index, (target, rtl) in enumerate(targets):
            if rtl:
                body += bytes((0x22, *_long(target)))  # JSL
                continue
            landing = REBUILD_LANDING_B if index == len(targets) - 1 else spare.pop(0)
            back = where.landing(landing) - 1  # RTS pulls the word and adds one
            blocks[into] = (
                body
                + bytes((0xE2, 0x30))  # SEP #$30
                + bytes((0xF4, back & 0xFF, (back >> 8) & 0xFF))  # PEA
                + bytes((0x5C, *_long(target)))  # JML
            )
            into, body = where.at(landing), b""
        # ... : STA $4200 : RTL, back to the core's own stub.
        tail = bytes((0xA9, NMI_IN_LEVEL, 0x8D, 0x00, 0x42)) if resume else b""
        blocks[into] = body + tail + bytes((0x6B,))
        for (memory, at), data in blocks.items():
            for offset, byte in enumerate(data):
                self.core.write(memory, at + offset, byte)
        self.core.call(
            REBUILD_STUB,
            budget=REBUILD_BUDGET,
            direct_page=self.addresses.direct_page,
        )

    def _arm_write_log(self) -> None:
        """Point the core's write log at the Map16 low table, once.

        Called before the restore that begins every load: arming resets the
        log's entries and the restore resets them again alongside the counters,
        while the registration itself survives both. On a core without the
        patch this is a no-op and :meth:`_observed_footprints` stays on the
        counters' one-stamp answer.
        """
        if self._write_log_armed or not self.core.has_write_log:
            return
        self.core.set_write_log_range(
            *self.addresses.at(MAP16_LOW), MAP16_SIZE, WRITE_LOG_CAPACITY
        )
        self._write_log_armed = True

    def _observed_footprints(self, level: int) -> tuple[frozenset[int], ...]:
        """What each object drew, read out of the core's own bookkeeping.

        The cheap half of a refresh, and the reason there is no trace logger in
        this path any more: ~2 ms against ~70. The mechanism is
        :mod:`shiny_mushroom.emu.footprints` -- the object stream's own read
        stamps are the clock, the tilemap's writes are on that same clock, and
        the attribution is a bucketing.

        On a patched core (:attr:`MesenCore.has_write_log`) the writes come
        from the write log -- every write with its stamp -- so a cell drawn by
        one object and drawn over by a later one is credited to both, and the
        footprints are what each object *drew*. The counters' one-stamp column
        is the fallback, for an unpatched core or an overflowed log, and it
        loses exactly the overdrawn cells.

        Both layers' streams when Layer 2 is objects rather than a background,
        because the loop runs once per layer and the answer is indexed across
        both, in the order the loop reached them.

        A stream the counters do not describe -- one this load did not walk --
        raises :class:`~shiny_mushroom.emu.footprints.NotObserved`, and that is
        reported as "no footprints" rather than as a wrong list. Every reader
        already falls back to a record's own rectangle when it has no trace for
        it, so the editor degrades to boxes instead of drawing lies.
        """
        where = self.addresses
        rom = self.core.read_all(MemoryType.SNES_PRG_ROM)
        base = layer1_base(rom, level, where=where)
        streams = [(base + HEADER_SIZE, object_stream(rom, base + HEADER_SIZE))]
        if not layer2_is_background(rom, level, where=where):
            # A Layer 2 *level* is a second object stream drawn by a second pass
            # of the same loop, so its records need boundaries of their own --
            # and its pointer, like Layer 1's, addresses a five-byte header with
            # the records after it. Found by asking the machine rather than the
            # table: the loop's reads begin exactly five bytes past where the
            # pointer points.
            entry = where.offset(where.layer2_pointers + level * 3)
            layer2 = where.offset(_read_long(rom, entry)) + HEADER_SIZE
            streams.append((layer2, object_stream(rom, layer2)))

        def read_stamps(offset: int, length: int):  # noqa: ANN202
            return self.core.access_stamps(
                MemoryType.SNES_PRG_ROM, offset, length, READ_STAMP
            )

        try:
            bounds = boundaries(read_stamps, streams)
        except NotObserved as unobserved:
            _log.warning("no footprints for level $%03X: %s", level, unobserved)
            return ()
        if self._write_log_armed:
            entries, overflow = self.core.write_log()
            if not overflow:
                _, at = self.addresses.at(MAP16_LOW)
                writes = ((address - at, stamp) for address, stamp in entries)
                return tuple(attribute_writes(writes, bounds))
            _log.warning(
                "the write log overflowed; level $%03X's footprints fall back "
                "to last-writer attribution",
                level,
            )
        written = self.core.access_stamps(
            *self.addresses.at(MAP16_LOW), MAP16_SIZE, WRITE_STAMP
        )
        return tuple(attribute(written, bounds))

    def _attempt(
        self,
        state: Path,
        level: int,
        patches: Mapping[int, bytes] | None,
        trace: bool,
    ) -> tuple[frozenset[int], ...]:
        self._arm_write_log()
        self.restore(state)
        self.preview(patches)
        if patches:
            # A patch may be a graphics file, and the slot cache the state
            # carries would have the upload skipped over it -- the title
            # state's own intro level shares files with most tilesets. A
            # patched load never starts warm, so what this costs is the slots
            # the title screen happened to share.
            self._forget_graphics()
        # For every request, patched or not: an editor asking for a level means
        # the level, not the doorway the player would walk in through.
        self.skip_entrance_room(level)
        # After the patches and before the run: the cartridge image is final
        # here, so the bytes the loop is about to read are readable, and they
        # are what decides whether it has to be watched at all.
        key, remembered = self._traced_before(level, trace)
        with self.direct_level_numbers(level):
            self.request_level(level)
            with self.core.running_free():
                self._wait_for_load()
        if not trace:
            return ()
        return self._traced_after(level, key, remembered)

    def _forget_graphics(self) -> None:
        """Empty the game's graphics upload cache, so the load that follows
        uploads every slot from the image as it now stands -- see
        :data:`LOADED_GRAPHICS_FILES`."""
        where = self.addresses
        for slot in range(GRAPHICS_SLOTS):
            self.core.write(*where.at(LOADED_GRAPHICS_FILES + slot), NO_GRAPHICS_FILE)

    def _traced_before(
        self, level: int, trace: bool
    ) -> tuple[tuple[int, bytes, bytes] | None, tuple[frozenset[int], ...] | None]:
        """This load's cache key and whatever is already filed under it.

        Asked **before** the run, and it has to be: the key is read off the
        cartridge image the run is about to read, and by the end of the load
        the loader has been through it and the image may have moved on.
        """
        key = self._trace_key(level) if trace else None
        return key, (None if key is None else self._traces.get(key))

    def _traced_after(
        self,
        level: int,
        key: tuple[int, bytes, bytes] | None,
        remembered: tuple[frozenset[int], ...] | None,
    ) -> tuple[frozenset[int], ...]:
        """The footprints for the load that has just run.

        Read afterwards rather than observed as it happens: the counters are
        already kept, so nothing has to be arranged before the loop runs.
        **Before the capture**, which restores a savestate for the sprite probe
        -- and a savestate restore zeroes every counter.
        """
        if remembered is not None:
            return remembered
        traced = self._observed_footprints(level)
        if key is not None:
            self._traces[key] = traced
            for stale in list(self._traces)[: -self.trace_cache_size]:
                del self._traces[stale]
        return traced

    def _trace_key(self, level: int) -> tuple[int, bytes, bytes] | None:
        """What the object loop's output is a function of, read off the image.

        ``(level, header, object stream)``, and that is the whole of it: the
        loop clears the tilemap before it starts (``SMW_InitializeLevelData``),
        the routines it dispatches to are the cartridge's own, and which table
        it dispatches through is the header's tileset. So a load whose bytes
        match one already traced draws the same blocks, and does not have to be
        watched doing it -- which is worth about 75 ms, the trace being ~60 ms
        of slower emulation plus ~15 of reading the log back.

        **An edit does not make this stale by halves.** Measured across five
        levels and four kinds of step, moving one object changes that object's
        footprint and no other object's -- but the object stream is one stream,
        so any object edit misses here and is traced afresh. What hits is a
        sprite-only edit, an undo or redo back to a stream already seen, and
        opening a level again.

        ``None`` for an image these offsets mean nothing in -- a byte map, or a
        stub -- which is the same guard :meth:`_capture` needs and the reason
        this can be asked before the level has loaded.
        """
        where = self.addresses
        rom = self.core.read_all(MemoryType.SNES_PRG_ROM)
        if len(rom) <= where.offset(where.layer1_pointers) + 3:
            return None
        try:
            base = layer1_base(rom, level, where=where)
        except ValueError:
            return None
        return (
            level,
            rom[base : base + HEADER_SIZE],
            object_stream(rom, base + HEADER_SIZE),
        )

    # -- results -----------------------------------------------------------

    def _settle(self) -> bool:
        """Advance the game by one frame, saying whether one actually ran.

        The loader stops with a placeholder in the palette where an animated
        colour goes, and the frame's own handler is what replaces it, so
        everything read afterwards depends on one frame of the game having run.

        **Asking for a frame is not the same as getting one.** ``step_frame``
        advances the emulator, but the machine it advances can be one where the
        game's per-frame work does not complete -- and on a base with a
        coprocessor that is not hypothetical: a step can land while the main CPU
        is spinning in the pack's ``ram_sa1_call`` gate waiting on the second
        processor. Measured on ``sa1``, one blind step left level ``$0C7`` with
        the placeholder still in CGRAM colour ``$64`` and sprite palette 8
        entirely blank, for 200 differing pixels -- intermittently, roughly once
        in five loads, which is exactly the shape that survives a test suite.

        So the frame is asked for by its effect: step until **the game's own
        frame counter moves**. That is a fact about the game rather than about
        the emulator's pacing, it costs the same single step in the ordinary
        case, and it cannot be satisfied by a step that did nothing.

        Bounded rather than trusting, because a machine that will never advance
        -- one paused mid-surgery, say -- must not spin here. Falling out of
        the loop is logged, and what it means is the caller's call: for a
        level picture a stale animated colour is a worse picture, not a broken
        one, so the capture carries on; the overworld probes fail the attempt
        instead, because their whole answer is the tables the load built.

        The halt is not decoration either. ``running_free`` ends on a pause,
        which is a request rather than a stop, so without it the step is armed
        on a core that is still executing -- and ``step_frame`` warns that a
        wait which only looks for "paused" is satisfied by the state it started
        in.
        """
        core, at = self.core, self.addresses.at(FRAME_COUNTER_GLOBAL)
        core.halt()
        before = core.read(*at)
        for _ in range(SETTLE_FRAMES):
            core.step_frame(1)
            core.halt()
            if core.read(*at) != before:
                return True
        _log.warning(
            "the game did not advance a frame in %d steps; the palette may "
            "still hold the loader's placeholder",
            SETTLE_FRAMES,
        )
        return False

    def _capture(
        self,
        level: int,
        duration: float,
        footprints: tuple[frozenset[int], ...] = (),
        settle: bool = True,
    ) -> LevelSnapshot:
        # One whole frame between the loader finishing and anything being read.
        #
        # The loader leaves the palette holding a placeholder where an animated
        # colour goes, and only the frame's own handler replaces it. CGRAM
        # colour $64 is the one that shows: HandlePaletteAnimation writes the
        # Yoshi coin's flashing colour there every frame from a yellow-to-white
        # ramp, and until it has run the level palette's $7C3F -- magenta --
        # is what a coin renders with. Measured over twelve loads of one level,
        # reading where the loader stopped gave the placeholder eight times and
        # a real flash colour four; one frame first gives a real one every time.
        #
        # It costs a frame of gameplay, which at a level's first frame is the
        # player standing still.
        #
        # **The frame is asked for by its effect, not by its count** -- see
        # :meth:`_settle`. A step that does not actually advance the game leaves
        # the placeholder in place, and the placeholder is a whole magenta coin.
        #
        # **A rebuild passes ``settle=False``, and must.** The frame is a frame
        # of the *game*, and after a rebuild the machine is not a machine the
        # game can be run on: the loader's routines have been called over a
        # state that was already in mode $14, so stepping it runs the main loop
        # mid-surgery and it uses the direct page as scratch -- which is where
        # the sprite list pointer lives, and following it afterwards lands
        # outside the cartridge. It is also unnecessary there: the state a
        # rebuild starts from was itself captured after a step, so the animated
        # colour it exists to fetch is already in CGRAM.
        where = self.addresses
        if settle:
            self._settle()
            # A frame of the game has just run on this machine, so a frame of it
            # can run again -- which is what the sprite capture's retry needs to
            # know, and what a rebuild takes away. See :attr:`_game_runnable`.
            self._game_runnable = True
        ram = RamView(self.core, where)
        rom = self.core.read_all(MemoryType.SNES_PRG_ROM)
        base = layer1_base(rom, level, where=where)
        extra_counts = extra_byte_counts(rom, where=self.addresses)
        stream = self._sprite_stream(ram, rom, extra_counts)
        layer2_start = _layer2_level_stream(rom, level, where=where)
        return LevelSnapshot(
            level=level,
            header=rom[base : base + HEADER_SIZE],
            objects=object_stream(rom, base + HEADER_SIZE),
            map16_low=ram.slice(MAP16_LOW, MAP16_SIZE),
            map16_high=ram.slice(MAP16_HIGH, MAP16_SIZE),
            map16_defs=self._map16_definitions(ram, rom),
            pipe_definitions=self._pipe_definitions(rom),
            vram=self.core.read_all(MemoryType.SNES_VIDEO_RAM),
            cgram=self.core.read_all(MemoryType.SNES_CG_RAM),
            sprites=stream,
            screen_mode=ram[LEVEL_LAYOUT_FLAGS],
            back_area_color=ram.word(BACK_AREA_COLOR),
            # Free: the memory is already copied, and these are the two words in
            # it the loader wrote the player's starting position into.
            spawn=PlayerPosition(ram.word(PLAYER_X), ram.word(PLAYER_Y)),
            sprite_art=self._sprite_art(
                level,
                rom[base : base + HEADER_SIZE],
                stream,
                bool(ram[LEVEL_LAYOUT_FLAGS] & LAYOUT_LAYER1_VERTICAL),
                extra_counts,
            ),
            extra_counts=extra_counts,
            footprints=footprints,
            # Layer 2 costs nothing to carry: a background's tilemap is already
            # in the RAM read above, a Layer 2 level is already inside the
            # Map16 buffer, and the definitions are a fixed slice of the
            # cartridge. No extra round trip and no extra emulation.
            layer2_low=ram.slice(LAYER2_BG_LOW, LAYER2_BG_SIZE),
            layer2_high=ram.slice(LAYER2_BG_HIGH, LAYER2_BG_SIZE),
            layer2_defs=background_definitions(rom, where=where),
            layer2_background=layer2_is_background(rom, level, where=where),
            layer2_header=layer2_start[0] if layer2_start else b"",
            layer2_objects=layer2_start[1] if layer2_start else b"",
            layer3_setting=ram[LAYER3_SETTING],
            layer3_x=ram.word(LAYER3_X),
            layer3_y=ram.word(LAYER3_Y),
            camera_x=ram.word(CAMERA_X),
            camera_y=ram.word(CAMERA_Y),
            duration=duration,
        )

    def _sprite_stream(
        self, ram: RamView, rom: bytes, counts: Mapping[int, int] = {}
    ) -> bytes:
        """Copy the loaded level's sprite stream out of the cartridge.

        Followed from the pointer **the game resolved**, not from
        :func:`sprite_base`'s table, so a cart that repointed it while loading is
        obeyed. Where the stream ends is :func:`sprite_stream`'s answer either
        way, walked with the cartridge's own extra-byte stride.
        """
        pointer = _read_long(ram, SPRITE_LIST_POINTER)
        return sprite_stream(rom, self.addresses.offset(pointer), counts)

    def _map16_definitions(self, ram: RamView, rom: bytes) -> bytes:
        """Follow the game's own Map16 pointer table into the cartridge.

        Reading it whole rather than one entry at a time is why this is cheap:
        both memories arrive in a single copy each, and the 512 lookups after
        that are Python. Resolving the same table by simulating the bitmask and
        the per-tileset bases would reimplement a decision the cart has already
        made, and would be wrong for any hack that patched it.
        """
        table = ram.slice(MAP16_POINTERS, MAP16_TILE_COUNT * 2)
        definitions = []
        for tile in range(MAP16_TILE_COUNT):
            pointer = table[tile * 2] | (table[tile * 2 + 1] << 8)
            # Every entry the loader writes points into the upper half of bank
            # $0D, so the address map's guard never fires here in practice. Left
            # unguarded deliberately: a pointer below $8000 would mean the table
            # was read before it was built, and a wrong picture is a worse
            # answer to that than an error.
            base = self.addresses.offset(MAP16_BANK | pointer)
            definitions.append(rom[base : base + MAP16_DEF_SIZE])
        return b"".join(definitions)

    def _pipe_definitions(self, rom: bytes) -> tuple[bytes, ...]:
        """The four pipe tables, followed from the cartridge's own pointers.

        Off ``PipeMap16Ptrs`` rather than off four declared table addresses, so
        a cartridge that repointed one is obeyed the same way
        :meth:`_map16_definitions` obeys a repointed Map16 pointer table.
        """
        base = self.addresses.offset(self.addresses.pipe_map16_pointers)
        tables = []
        for entry in range(PIPE_TABLES):
            pointer = rom[base + entry * 2] | (rom[base + entry * 2 + 1] << 8)
            start = self.addresses.offset(MAP16_BANK | pointer)
            tables.append(rom[start : start + len(PIPE_TILES) * MAP16_DEF_SIZE])
        return tuple(tables)

    def _remember_warm(self, level: int) -> None:
        if level not in self._warm and len(self._warm) >= self.warm_cache_size:
            # Plain FIFO. An editor works on one level at a time, so which
            # entry goes is not worth a policy.
            oldest = next(iter(self._warm))
            self._warm.pop(oldest).unlink(missing_ok=True)
        state = self.state_dir / f"warm-{level:03X}.mst"
        self.core.save_state(state)
        self._warm[level] = state
