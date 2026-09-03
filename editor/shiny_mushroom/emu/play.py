"""Playing a level, rather than looking at it.

Same cart, same core, same four-byte level request as
:mod:`shiny_mushroom.emu.smw` -- and then the opposite ending. The loader stops
the moment the level exists and reads its memories out; this lets the game carry
on into mode ``$14``, drops the emulator back to console speed and hands the
controller to whoever is watching the window.

What a run is *asked* for -- the pad, the loadout and the run's own options --
is :mod:`shiny_mushroom.play_request`, outside this package so the window that
reads a keyboard does not load a core to name a button.

**What is skipped, and what is not.** The boot sequence is: power-on, the
Nintendo logo, the title screen, the file select, the overworld, and only then a
level. All of it is skipped -- a savestate taken at the title screen once per
session is restored in about five milliseconds, and writing ``$11`` into the
game mode makes the game's own dispatcher run the load from there.

What is *not* skipped is the load itself: modes ``$11`` and ``$12``, the loader
proper. Those run unmodified, at whatever speed the host manages, because they
are what puts the level on the machine.

``$13``, the mosaic fade, is not run out either. It is thirty frames -- measured,
153 ms of a 354 ms entry -- and every one of them is fast-forwarded rather than
watched, since :meth:`PlaySession.enter` runs at maximum speed and nothing is
painted until it returns. So the fade is **wound to its last step** and the
game's own routine makes the handover a frame later, which is
:meth:`~shiny_mushroom.emu.smw.CartSession._wind_fade_forward` and is not a
reproduction of the end of the fade: nothing writes the game mode, and what the
level looks like on arrival is what ``MosaicFade`` left, not what this module
guessed.

The rest is bought back a better way: a savestate is taken the instant the level
becomes playable and reused whenever the same level is asked for with the same
edits, which is exactly what happens when a level is tested twice in a row. That
path is a restore and nothing else.

**Starting at the midway point is deliberately not offered.** It would be one
byte -- ``$7E13CE``, ``!RAM_SMW_Flag_GotMidpoint`` -- except that the loader
clears it: bank ``$05`` runs ``STZ !RAM_SMW_Flag_GotMidpoint`` whenever
``!RAM_SMW_Counter_SublevelsEntered`` is zero, and a request made this way sets
that counter to zero on purpose. So a flag written before the load does not
survive it, and an option that silently started the player at the ordinary
entrance would be worse than not having one.
"""

from __future__ import annotations

import hashlib
import logging
import threading
import time
import zlib
from collections.abc import Callable, Mapping
from dataclasses import dataclass, field
from pathlib import Path

from shiny_mushroom.addresses import (
    GAME_MODE,
    INTRO_LEVEL_FLAG,
    MARIO_MAP,
    MODE_FADE_IN,
    MODE_IN_LEVEL,
    MOSAIC_MIRROR,
)
from shiny_mushroom.brk import BrkReport
from shiny_mushroom.emu.core import MASTER_VOLUME, ControllerState, MemoryType
from shiny_mushroom.emu.loading import retry_load
from shiny_mushroom.emu.smw import CartSession
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.overworld_snapshot import (
    CURRENT_CHARACTER,
    MODE_OVERWORLD,
    MODE_PLAYER_SELECT,
    OW_ACTIVATE_EVENT,
    OW_CURRENT_EVENT,
    OW_EVENT_FLAGS,
    OW_EVENT_PASSED,
    OW_EVENT_PROCESS,
    OW_EXIT_LEVEL_ACTION,
    OW_LEVEL_TILE_SETTINGS,
    OW_MARIO_GRID_X,
    OW_MARIO_GRID_Y,
    OW_NO_EVENT,
    OW_PROCESS,
    OW_SAVE_BUFFER,
    OW_TRANSLEVELS,
    TWO_PLAYER_GAME,
    save_buffer,
    standing_index,
)
from shiny_mushroom.play_request import (
    Buttons,
    PlayerState,
    PlayOptions,
)
from shiny_mushroom.rom_patches import level_request_bytes, patches_reach_title_load

_log = logging.getLogger(__name__)

# -- work RAM, as offsets into the 128 KB array ($7E0000 is 0) ---------------
#
# The player's loadout. These are the *current* values, not the per-character
# copies at $0DB4-$0DBD: the game copies one into the other on the **overworld**
# (bank $04), not during a level load, so a request made the way this module
# makes one never runs the copy and the per-character bytes would go nowhere.

#: ``$7E0019``, ``!RAM_SMW_Player_CurrentPowerUp``. 0 small, 1 big, 2 cape,
#: 3 fire. Written after the load, which is the same thing a mushroom does.
CURRENT_POWERUP = 0x000019

#: ``$7E0DBE``, ``!RAM_SMW_Player_CurrentLifeCount``. **One less than the number
#: on the status bar**: the counter is drawn with an ``INC`` in front of it, and
#: death is ``DEC`` then ``BPL``, so ``$00`` is the last life and ``$FF`` is game
#: over. A new save file gets ``$04``.
CURRENT_LIFE_COUNT = 0x000DBE

#: ``$7E0DBF``, ``!RAM_SMW_Player_CurrentCoinCount``.
CURRENT_COIN_COUNT = 0x000DBF

#: ``$7E0DC1``, ``!RAM_SMW_Yoshi_CarryOverLevelsFlag``. Non-zero is a Yoshi
#: colour, and brings one into the level.
YOSHI_CARRY_OVER = 0x000DC1

#: ``$7E0DC2``, ``!RAM_SMW_Player_CurrentItemBox``. A sprite number, drawn in
#: the reserve box.
CURRENT_ITEM_BOX = 0x000DC2

#: ``!MosaicSizeAndBGEnable_PixelSize16x16``, and the whole of what game mode
#: ``$0F`` leaves behind for the fade *in* to unwind. See :meth:`_load`.
FADE_OUT_MOSAIC = 0xF0

#: How long :meth:`PlaySession.await_frame` holds a pump reply open. Just
#: under two frame periods: long enough that the next frame lands inside the
#: wait even through the scheduling jitter a frame's arrival carries
#: (measured p95 ~27 ms on a loaded host), short enough that a paused or
#: static screen still heartbeats status -- and short enough to bound the
#: one cost a long poll has, which is that a button change arriving while a
#: reply is held waits for it to return.
FRAME_WAIT = 0.03


def controller_state(buttons: Buttons | int) -> ControllerState:
    """Turn a bitmask into the structure Mesen's input override takes."""
    held = Buttons(buttons)
    return ControllerState(
        a=bool(held & Buttons.A),
        b=bool(held & Buttons.B),
        x=bool(held & Buttons.X),
        y=bool(held & Buttons.Y),
        l=bool(held & Buttons.L),
        r=bool(held & Buttons.R),
        mic=False,
        unused=False,
        up=bool(held & Buttons.UP),
        down=bool(held & Buttons.DOWN),
        left=bool(held & Buttons.LEFT),
        right=bool(held & Buttons.RIGHT),
        select=bool(held & Buttons.SELECT),
        start=bool(held & Buttons.START),
    )


@dataclass(frozen=True)
class Frame:
    """One picture the emulator drew, and how to tell it from the next one."""

    #: Increments only when the picture actually changed. A window that has
    #: seen this number has nothing to redraw.
    sequence: int
    width: int
    height: int

    #: ``width * height`` little-endian ``0xAARRGGBB`` words -- Qt's
    #: ``Format_RGB32`` byte for byte.
    pixels: bytes


@dataclass(frozen=True)
class Entry:
    """What a request to enter a level cost and where it left the game."""

    level: int
    duration: float

    #: Whether this was a savestate restore rather than a full load. Reported
    #: rather than inferred from the duration, which also moves with the host.
    reused: bool

    #: ``$7E0100`` once the level is playable. ``$14`` unless something is
    #: wrong, and worth carrying so a caller does not have to ask separately.
    game_mode: int


@dataclass(frozen=True)
class OverworldEntry:
    """What a request to enter the overworld cost and where it left the game.

    :class:`Entry` without the level, because a map run has none: the mode to
    expect while it runs is ``$0E``.
    """

    duration: float
    reused: bool
    game_mode: int


@dataclass(frozen=True)
class CartridgeEntry:
    """What a request to run the cartridge itself cost, and where it left it.

    :class:`OverworldEntry` without the reuse, because there is nothing to
    reuse: the run is the title anchor the boot already took, restored.
    """

    duration: float
    game_mode: int


@dataclass
class PlaySession(CartSession):
    """A cart booted, put into a level, and left running for someone to play.

    One of these owns a core with a software renderer attached, so it cannot
    share a process with the loader's -- Mesen keeps its emulator in a
    file-scope singleton and there is one per process. That is why "test this
    level" is a second worker rather than another request to the first.
    """

    #: How many playable-level states to keep. Each is about 100 KB on disk,
    #: and an editor tests a handful of levels in a session.
    ready_cache_size: int = 4

    _ready: dict[str, Path] = field(default_factory=dict, init=False)
    _ready_order: list[str] = field(default_factory=list, init=False)

    _latest: Frame | None = field(default=None, init=False)
    _sequence: int = field(default=0, init=False)
    _presented: int = field(default=0, init=False)
    _checksum: int = field(default=0, init=False)
    #: Guards the four fields above, which are written from Mesen's render
    #: thread and read from the worker's -- and carries the wake-up
    #: :meth:`await_frame` blocks on, which is what makes the pump a long
    #: poll rather than a timer racing the emulator's own cadence.
    _frame_lock: threading.Condition = field(
        default_factory=threading.Condition, init=False
    )

    _buttons: Buttons = field(default=Buttons.NONE, init=False)
    _paused: bool = field(default=False, init=False)

    #: The ``BRK`` this run is stopped at, once it has been read off the
    #: machine. Held rather than reported and forgotten: the machine is still
    #: stopped at it, and what happens next is the player's to say -- see
    #: :meth:`brk`.
    _brk: BrkReport | None = field(default=None, init=False)

    # -- lifecycle ---------------------------------------------------------

    def open(self) -> None:
        """Boot the cart and start receiving frames.

        The boot happens at full speed and with nothing on screen worth
        watching, so it is done before video is asked for rather than after --
        which also means the first frame the window ever sees is one from the
        level, not thirty seconds of Nintendo logo replayed at 300 fps.

        **And with nothing worth hearing either, so the sound is off for it.**
        The intro is a couple of seconds of the game's own audio played at
        whatever speed the host manages, which is a noise rather than music --
        and this worker is booted when a *cartridge* is opened, nowhere near a
        window anybody asked for, so a machine that made that noise would make
        it at a moment nothing on screen explains. Put back either way: a boot
        that raised would otherwise leave a core that plays a level in silence.
        """
        self.core.set_volume(0)
        try:
            self.prepare()
        finally:
            self.core.set_volume(MASTER_VOLUME)
        self.core.capture_video(self._receive)

    # -- the exception handler ---------------------------------------------

    def brk(self) -> BrkReport | None:
        """The ``BRK`` this run is stopped at, or ``None`` while it is running.

        Read off the machine the first time it is asked for and then held, so
        the pump can go on answering -- with no frames, because none are being
        drawn -- while the window puts the report in front of somebody.
        """
        if self._brk is None and self.core.broke_on_brk:
            report = self.core.peek_break()
            assert isinstance(report, BrkReport)
            self._brk = report
        return self._brk

    def carry_on_past_brk(self) -> None:
        """Execute the ``BRK`` and let the run continue, which is what the
        player asked for when they read the report and chose to go on.

        Where that lands is the cartridge's business: a hack carrying the BRK
        Exception Handler patch shows its own screen, and one carrying nothing
        goes wherever an unset vector points. Both are the run they kept.
        """
        self._brk = None
        self.core.resume_break()

    def drop_brk(self) -> None:
        """Let the machine go and stop it dead, forgetting the report.

        What every new run does first: a session stopped at a ``BRK`` has its
        emulation thread blocked inside the break, and nothing -- not a
        restore, not a patch -- reaches a machine in that state.
        """
        self._brk = None
        self.core.let_break_go()

    # -- entering a level --------------------------------------------------

    def enter(
        self,
        level: int,
        patches: Mapping[int, bytes] | None = None,
        options: PlayOptions | None = None,
    ) -> Entry:
        """Put the game into ``level`` and leave it running.

        ``patches`` are byte edits to the cartridge image, applied to this
        core's copy only -- the same channel the loader's previews use, and the
        way an edit that exists nowhere but the editor's memory gets tested.
        """
        options = options or PlayOptions()
        self.prepare()
        # Raises for a level this path cannot express, before the machine is
        # asked to do anything with it.
        level_request_bytes(level)

        def stage() -> None:
            # After the preview and before the load, which is what makes the
            # bit last for this run alone -- see `skip_entrance_room`.
            if not options.entrance_room:
                self.skip_entrance_room(level)

        def load() -> None:
            self._loading(level, patches_reach_title_load(patches, self.addresses))
            self.apply_loadout(options.player)

        duration, reused, mode = self._enter(
            self._ready_key(level, patches, options), patches, load, stage
        )
        return Entry(level=level, duration=duration, reused=reused, game_mode=mode)

    def _enter(
        self,
        key: str,
        patches: Mapping[int, bytes] | None,
        load: Callable[[], None],
        stage: Callable[[], None] | None = None,
    ) -> tuple[float, bool, int]:
        """Put the game somewhere and leave it running, as ``(cost, reused,
        game mode)``.

        The choreography a level run and a map run share, which is all of it
        but the ``load`` that does the walking and the ``stage`` a level needs
        before it. ``key`` says what this run *is*: a savestate filed under it
        is this same run already made, and restoring one is the whole of the
        second-press cost.
        """
        started = time.monotonic()
        # A machine stopped at a BRK is one no restore reaches, and the run
        # being asked for now is the answer to the report the last one ended
        # with.
        self.drop_brk()
        self.prepare()
        ready = self._ready.get(key)

        with self.core.at_maximum_speed():
            # Whatever was being played is about to be replaced, and patching a
            # cartridge under a running game means it can read a half-applied
            # edit before the restore throws that machine away.
            self.core.halt()
            # The cartridge has to hold the same bytes it held when a reused
            # state was captured: a savestate does not carry the ROM, so the
            # edits have to be put back either way.
            self.preview(patches)
            if stage is not None:
                stage()
            if ready is not None:
                self.restore(ready)
            else:
                load()
                self._remember_ready(key)

        mode = self.core.read(*self.addresses.at(GAME_MODE))
        self._paused = False
        # Started rather than resumed: a resume can be swallowed by a pause
        # still in flight (`MesenCore.start`), and here that is a run that opens
        # frozen.
        self.core.start()
        return time.monotonic() - started, ready is not None, mode

    def _loading(self, level: int, through_title: bool) -> None:
        """Enter the level, retrying a cart that stops running the game.

        The same failure the loader retries, for the same reason: a game mode
        forced onto a machine restored mid-frame is sometimes never dispatched,
        and every attempt starts from the boot anchor because that is what
        clears it. See :meth:`~shiny_mushroom.emu.smw.SmwLevelLoader._attempting`.
        """
        retry_load(
            lambda _attempt: self._load(level, through_title),
            f"level {hexnum(level, 3)}",
        )

    def _load(self, level: int, through_title: bool = False) -> None:
        """Title screen to playable level, through the game's own state machine.

        **The mosaic mirror is primed first, and the level is drawn wrong
        without it.** Mode ``$13``'s fade in and mode ``$0F``'s fade out are a
        matched pair: the fade out grows the mosaic to 16x16 and the fade in
        steps it back down by one size per step, fifteen steps, ending on 1x1.
        But the loop's exit test is on the *brightness*, not on the size -- so
        a fade in that starts from anything other than 16x16 stops with the
        mosaic still on.

        Entering from the overworld runs ``$0F`` first, so the pair balances.
        Jumping straight to ``$11`` skips it, and the fade then runs from a
        mirror of ``$00``: the first step wraps it to ``$F0`` and the fifteenth
        leaves it at ``$10``. That is ``$2106 = $13`` -- layers 1 and 2 at 2x2
        for the whole session, since nothing writes that register again until
        the next fade. It reads as a level whose blocks and background are
        drawn at half resolution while the sprites and the status bar are
        sharp, which is exactly what it is.

        ``through_title`` starts the run at
        :meth:`~shiny_mushroom.emu.smw.CartSession.restore_boot` rather than
        the title anchor, so the title preparation has read the patched
        cartridge -- asked for when the patches reach the world map's sprite
        slots, whose only reader is that preparation, for the walk out of
        this level onto the map. Not asked for otherwise: the boot costs
        ~0.65 s of wall clock a plain restore does not.
        """
        if through_title:
            self.restore_boot()
        else:
            self.restore(self.title_state)
        # Held over the request and the wait that runs the loader, and no
        # longer: what it patches is read by SpecifySublevelToLoad, which is
        # done by the time the machine reaches the fade, and what the player
        # is handed after that has to behave like the game.
        with self.direct_level_numbers(level):
            self.request_level(level)
            # Where mode $0F would have left it, had it run. Still written even
            # though the wind below lands the mosaic on the same place: it is
            # what covers a machine that reached $14 without this seeing $13 at
            # all.
            self.core.write(*self.addresses.at(MOSAIC_MIRROR), FADE_OUT_MOSAIC)
            # **In two waits, so the fade can be wound on a stopped machine.**
            # The thirty frames of $13 are fast-forwarded rather than watched --
            # `enter` runs at maximum speed and nothing paints until it returns
            # -- so they are a third of what starting a test run costs and
            # nothing sees them. Winding them out is worth a halt and a start;
            # winding them *into* a running machine is not, because the fade
            # routine would be reading those bytes between the writes.
            with self.core.running_free():
                self._wait_for(
                    lambda mode: mode in (MODE_FADE_IN, MODE_IN_LEVEL),
                    self.load_timeout,
                    "a level to fade in",
                    requested=True,
                )
        self.core.halt()
        self._wind_fade_forward()
        with self.core.running_free():
            # Straight to $14 rather than stopping where the loader stops: $13
            # is the fade, and a player wants to arrive after it. Waiting for
            # $14 directly is unambiguous here because the machine was at the
            # title screen a moment ago, so it cannot already be in a level.
            self._wait_for(
                lambda mode: mode == MODE_IN_LEVEL,
                self.load_timeout,
                "a playable level",
                requested=True,
            )
        # The loadout is written next, and a paused-but-not-stopped machine
        # would run on and redraw the status bar from the old values -- the same
        # race CartSession.restore ends with a halt to avoid.
        self.core.halt()

    def apply_loadout(self, player: PlayerState) -> None:
        """Write the loadout, once the level is up.

        After the load rather than before it, because the loader is what would
        overwrite these: it copies nothing into them, but it does reset the
        powerup as part of setting the player up. Writing them here is the same
        thing a mushroom or a 1-up does mid-level, and the status bar redraws
        from them on the next frame.

        Which is also why it is worth calling again later. Handing someone a
        cape while they are standing in the level they are testing is the same
        five writes, and it saves reloading to find out whether the jump works
        with one.
        """
        # Through the base's RAM map like every other access: the loadout is
        # ordinary game state, and on a base with a coprocessor half of it is in
        # I-RAM and half in BW-RAM.
        write, where = self.core.write, self.addresses
        write(*where.at(CURRENT_POWERUP), player.powerup)
        # The counter is one less than the number drawn; see CURRENT_LIFE_COUNT.
        write(*where.at(CURRENT_LIFE_COUNT), max(player.lives - 1, 0))
        write(*where.at(CURRENT_COIN_COUNT), player.coins)
        write(*where.at(CURRENT_ITEM_BOX), player.item_box)
        write(*where.at(YOSHI_CARRY_OVER), player.yoshi)

    # -- entering the overworld --------------------------------------------

    def enter_overworld(
        self,
        submap: int,
        x: int,
        y: int,
        tile_settings: bytes,
        event_flags: bytes,
        patches: Mapping[int, bytes] | None = None,
    ) -> OverworldEntry:
        """Put the game onto the world map and leave it running.

        The map state arrives the way a save file's would: ``tile_settings``
        and ``event_flags`` are the per-translevel and per-event save tables,
        and ``(submap, x, y)`` is where the player stands, as a map pixel in
        the shared 512x512 space. ``patches`` are the same cartridge edits a
        level run takes -- an edited world map rides in as one.
        """
        options = (submap, x, y)

        def load() -> None:
            self._loading_overworld(
                submap,
                x,
                y,
                tile_settings,
                event_flags,
                patches_reach_title_load(patches, self.addresses),
            )

        duration, reused, mode = self._enter(
            self._overworld_key(options, tile_settings, event_flags, patches),
            patches,
            load,
        )
        return OverworldEntry(duration=duration, reused=reused, game_mode=mode)

    def _loading_overworld(
        self,
        submap: int,
        x: int,
        y: int,
        tile_settings: bytes,
        event_flags: bytes,
        through_title: bool,
    ) -> None:
        """The same retry :meth:`_loading` gives a level, for the same flake."""
        retry_load(
            lambda _attempt: self._load_overworld(
                submap, x, y, tile_settings, event_flags, through_title
            ),
            "the overworld",
        )

    def _load_overworld(
        self,
        submap: int,
        x: int,
        y: int,
        tile_settings: bytes,
        event_flags: bytes,
        through_title: bool = False,
    ) -> None:
        """Title screen to a walkable map, through the game's own boot.

        The request is game mode ``$0A`` with a fabricated save buffer staged
        at ``$1F49`` -- the player-select handler then does everything a boot
        from a save file does, in-band: copies the buffer over the live
        tables, decompresses and stamps the Layer 2 buffer (which nothing
        after file select ever rebuilds), seeds a new game's loadout, and
        walks the real ``$0B``-``$0E`` fade chain, so no mirror needs
        priming. All the menu wants is a confirm press, fed to it through the
        controller override in pulses so a press *edge* lands on some frame
        whatever the emulation speed.

        ``through_title`` starts the run at
        :meth:`~shiny_mushroom.emu.smw.CartSession.restore_boot`, asked for
        when the patches reach the sprite slot table: that table is read at
        title load and nowhere in the ``$0A``-``$0E`` chain, so restored past
        the title preparation an edited copy would never reach the run. Not
        asked for otherwise -- the boot costs ~0.65 s of wall clock a plain
        restore does not.
        """
        if through_title:
            self.restore_boot()
        else:
            self.restore(self.title_state)
        where, write = self.addresses, self.core.write
        staged = save_buffer(tile_settings, event_flags, submap, x, y)
        for offset, byte in enumerate(staged):
            write(*where.at(OW_SAVE_BUFFER + offset), byte)
        write(*where.at(INTRO_LEVEL_FLAG), 0)
        write(*where.at(GAME_MODE), MODE_PLAYER_SELECT)

        def confirmed(mode: int) -> bool:
            if mode == MODE_PLAYER_SELECT:
                pulse = int(time.monotonic() * 25) & 1
                self.set_buttons(Buttons.START if pulse else Buttons.NONE)
            else:
                self.set_buttons(Buttons.NONE)
            return mode == MODE_OVERWORLD

        try:
            with self.core.running_free():
                self._wait_for(
                    confirmed,
                    self.load_timeout,
                    "a walkable overworld",
                    requested=True,
                    floor=MODE_PLAYER_SELECT,
                )
        finally:
            self.set_buttons(Buttons.NONE)
        self.core.halt()
        # The menu's cursor chose these -- whatever the title screen left it
        # holding -- so put them back to a one-player game as Mario.
        write(*where.at(TWO_PLAYER_GAME), 0)
        write(*where.at(CURRENT_CHARACTER), 0)

    # -- running the cartridge ---------------------------------------------

    def enter_cartridge(self) -> CartridgeEntry:
        """Put the game back to its title screen and leave it running.

        The cartridge itself rather than a document off the canvas: nothing is
        patched and nothing is warped to, so what is played is the image the
        worker booted, from the screen the game boots to. That is what makes
        it the internal half of File > Test ROM, whose external half hands the
        same file to somebody else's emulator.

        The withdrawal is the whole of the work. The title anchor is where
        every cold request already starts from
        (:meth:`~shiny_mushroom.emu.smw.CartSession.prepare`) and was taken
        over the unpatched image, so its RAM is the cartridge's own -- but the
        ROM is not part of a savestate, and the last run's edits sit in the
        core's copy until :meth:`~shiny_mushroom.emu.smw.CartSession.preview`
        puts the original bytes back.
        """
        started = time.monotonic()
        self.drop_brk()
        self.prepare()
        with self.core.at_maximum_speed():
            # Before the image changes under it, for :meth:`_enter`'s reason:
            # a running game can read a half-withdrawn edit.
            self.core.halt()
            self.preview(None)
            self.restore(self.title_state)
        mode = self.core.read(*self.addresses.at(GAME_MODE))
        self._paused = False
        # Started rather than resumed -- :meth:`_enter` says why.
        self.core.start()
        return CartridgeEntry(duration=time.monotonic() - started, game_mode=mode)

    def complete_level(self, secret: bool = False) -> dict[str, object]:
        """Beat the level the player stands on, so its map event plays.

        The six writes a real level exit leaves for the overworld's process
        machine, plus resetting that machine to its entry process: it then
        derives the level from the tile under the player, sets its beaten
        bit, runs the event -- incrementing the number itself for a secret
        exit -- and unlocks the walk that exit reveals. Refused, with a
        ``message`` the window can put on its status line, when the game is
        not on the map, the player is not standing on a level, or that
        exit's event has already run.
        """
        core, where = self.core, self.addresses
        was_paused = self._paused
        core.halt()
        try:
            read = core.read
            if read(*where.at(GAME_MODE)) != MODE_OVERWORLD:
                return {"done": False, "message": "not on the map"}
            grid_x = read(*where.at(OW_MARIO_GRID_X))
            grid_y = read(*where.at(OW_MARIO_GRID_Y))
            submap = read(*where.at(MARIO_MAP))
            index = standing_index(grid_x, grid_y, submap)
            translevel = read(*where.at(OW_TRANSLEVELS + index))
            if not translevel:
                return {"done": False, "message": "not standing on a level"}
            event = read(
                MemoryType.SNES_PRG_ROM,
                where.offset(where.overworld_level_events) + translevel,
            )
            settings = read(*where.at(OW_LEVEL_TILE_SETTINGS + translevel))
            if event == OW_NO_EVENT:
                # No event to replay, so beating it twice would show nothing.
                if settings & 0x80:
                    return {"done": False, "message": "already beaten"}
                fired = None
            else:
                fired = event + 1 if secret else event
                if read(*where.at(OW_EVENT_FLAGS + (fired >> 3))) & (
                    0x80 >> (fired & 7)
                ):
                    return {"done": False, "message": "already complete"}
            write = core.write
            write(*where.at(OW_EXIT_LEVEL_ACTION), 2 if secret else 1)
            write(*where.at(OW_ACTIVATE_EVENT), 1)
            write(*where.at(OW_EVENT_PASSED), 1)
            write(*where.at(OW_CURRENT_EVENT), event)
            write(*where.at(OW_PROCESS), 0)
            write(*where.at(OW_EVENT_PROCESS), 0)
            return {"done": True, "translevel": translevel, "event": fired}
        finally:
            # A paused run stays paused -- the writes hold, and the event
            # plays on unpause -- rather than this control unpausing it.
            if not was_paused:
                core.start()

    def _overworld_key(
        self,
        options: tuple[int, int, int],
        tile_settings: bytes,
        event_flags: bytes,
        patches: Mapping[int, bytes] | None,
    ) -> str:
        """:meth:`_ready_key`'s overworld sibling.

        The discriminator keeps a map run's state from ever answering for a
        level run's; the tables are hashed whole because they *are* the run,
        the way a level number is a level run's identity.
        """
        return self._key(("overworld", options), patches, tile_settings, event_flags)

    # -- the reusable end of a load ----------------------------------------

    def _ready_key(
        self,
        level: int,
        patches: Mapping[int, bytes] | None,
        options: PlayOptions,
    ) -> str:
        """What makes two requests the same request.

        The patches are hashed rather than compared because a preview can be
        the whole object stream, and a cache key should not be the size of the
        thing it is about.

        A start position needs no special handling here: it reaches a run as a
        cartridge patch, because SMW has no in-level teleport -- see
        :func:`~shiny_mushroom.rom_patches.entrance_patch` -- so it is already part
        of the digest, and a run started somewhere else is correctly a
        different level to load rather than the same one moved.
        """
        return self._key((level, options), patches)

    def _key(
        self,
        identity: object,
        patches: Mapping[int, bytes] | None,
        *tables: bytes,
    ) -> str:
        """The digest both keys are: what was asked for, then what was patched.

        ``identity`` is whatever names the request in short -- a level number
        and its options, a submap and a position. ``tables`` is for a run whose
        starting state *is* bytes rather than a description of them, which is
        the overworld's two save tables; each is followed by a separator, so no
        two splits of the same bytes can collide.
        """
        digest = hashlib.blake2b(digest_size=16)
        digest.update(repr(identity).encode())
        for table in tables:
            digest.update(table)
            digest.update(b"|")
        for offset in sorted(patches or {}):
            digest.update(offset.to_bytes(4, "big"))
            digest.update(patches[offset])
        return digest.hexdigest()

    def _remember_ready(self, key: str) -> None:
        if key in self._ready:
            return
        if len(self._ready_order) >= self.ready_cache_size:
            oldest = self._ready_order.pop(0)
            self._ready.pop(oldest).unlink(missing_ok=True)
        state = self.state_dir / f"ready-{key}.mst"
        self.core.save_state(state)
        self._ready[key] = state
        self._ready_order.append(key)

    # -- pictures ----------------------------------------------------------

    def _receive(self, width: int, height: int, pixels: bytes) -> None:
        """Latch a frame. **Runs on Mesen's render thread.**

        The checksum is what keeps a paused emulator quiet: the renderer keeps
        calling whether or not anything moved -- every device frame while the
        game runs, about 30 a second while it is paused -- and without this a
        window sitting on a paused game would be handed a quarter of a
        megabyte thirty times a second to draw the same picture. The
        ``presented`` counter deliberately counts *before* that dedupe: it is
        the emulator's own delivery rate, which is what the frame-rate
        readout reports -- see :meth:`presented`.
        """
        checksum = zlib.crc32(pixels)
        with self._frame_lock:
            self._presented += 1
            if self._latest is not None and checksum == self._checksum:
                return
            self._checksum = checksum
            self._sequence += 1
            self._latest = Frame(self._sequence, width, height, pixels)
            self._frame_lock.notify_all()

    def frame(self, seen: int = 0) -> Frame | None:
        """The newest picture, or ``None`` if ``seen`` is already it."""
        with self._frame_lock:
            latest = self._latest
        if latest is None or latest.sequence == seen:
            return None
        return latest

    def await_frame(self, seen: int = 0, timeout: float = FRAME_WAIT) -> Frame | None:
        """The next picture that is not ``seen``, waited for.

        What turns the pump into a long poll: instead of answering "nothing
        yet" and letting the caller's clock decide when to ask again, the
        reply is held until the render thread latches a new frame -- so
        frames cross the pipe at the emulator's own cadence, not at the beat
        frequency between it and a poll timer. ``None`` after ``timeout``,
        which is what keeps a paused emulator, a static screen or a lag
        frame from stalling the loop; the timed-out reply still carries the
        game mode and pause state, so it doubles as the status heartbeat.
        """
        deadline = time.monotonic() + timeout
        with self._frame_lock:
            while True:
                latest = self._latest
                if latest is not None and latest.sequence != seen:
                    return latest
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    return None
                self._frame_lock.wait(remaining)

    @property
    def presented(self) -> int:
        """How many frames the emulator has delivered, duplicates included.

        The device rate, and deliberately not :attr:`Frame.sequence`'s
        distinct-picture count: a frame the game lagged through and a static
        menu both re-present the same picture, and a rate that dropped for
        either read as the *emulator* faltering when it was the game --
        vanilla SMW loses ~7 frames a second to its own slowdown in ordinary
        play. This counts what the emulator produced; whether the game filled
        every frame is the game's business, visible in the picture itself.
        """
        with self._frame_lock:
            return self._presented

    # -- being played ------------------------------------------------------

    def set_buttons(self, buttons: Buttons | int) -> None:
        """Hold exactly these buttons until told otherwise.

        Only written through when it changes: the override reaches the core
        through the debugger, and there is no reason to go through it sixty
        times a second to say the same thing.
        """
        held = Buttons(buttons)
        if held == self._buttons:
            return
        self._buttons = held
        self.core.set_buttons(controller_state(held))

    @property
    def paused(self) -> bool:
        return self._paused

    def set_paused(self, paused: bool) -> None:
        if paused == self._paused:
            return
        self._paused = paused
        if paused:
            self.core.pause()
        else:
            self.core.start()

    def game_mode(self) -> int:
        """``$7E0100``. ``$14`` while the level is being played."""
        return self.core.read(*self.addresses.at(GAME_MODE))
