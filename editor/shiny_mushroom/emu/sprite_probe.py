"""Making a sprite draw itself, and reading the tiles back.

A sprite's appearance exists only as code, so the only way to know what one
looks like is to run that code and read what it wrote. This module holds both
halves of that: the constants and pure helpers that say which sprites can be
drawn and which OAM entries belong to whom, and :class:`SpriteProbe`, the part
of the loader that stands a sprite somewhere on screen, calls the game's own
routines and harvests the result. What the result *is* --
:class:`~shiny_mushroom.sprite_art.SpriteTile` and
:class:`~shiny_mushroom.sprite_art.PlayerArt` -- is
:mod:`shiny_mushroom.sprite_art`, outside this package so that drawing a
capture needs no core.

:class:`SpriteProbe` is mixed into
:class:`~shiny_mushroom.emu.smw.SmwLevelLoader` rather than standing alone: the
capture drives the same core, savestates and scratch states a level load does,
and every method here reaches through the session that owns them.
"""

from __future__ import annotations

import logging
from collections.abc import Iterable, Iterator, Mapping
from pathlib import Path

from shiny_mushroom.addresses import (
    BLOCK_PIXELS,
    CAMERA_X,
    DEFAULT_ADDRESSES,
    FRAME_COUNTER_GLOBAL,
    FRAME_COUNTER_LOCAL,
    FRAME_COUNTER_POSE,
    GAME_MODE,
    MODE_IN_LEVEL,
    PLAYER_X,
    PLAYER_Y,
    SCREEN_BLOCKS,
    SPRITE_RECORD_SIZE,
    RamView,
)
from shiny_mushroom.emu.core import CPU_TYPE_SA1, CPU_TYPE_SNES, EmulatorUnavailable
from shiny_mushroom.emu.oam_writes import COLUMNS as OAM_COLUMNS
from shiny_mushroom.emu.oam_writes import condition as oam_condition
from shiny_mushroom.emu.oam_writes import parse as parse_oam_writes
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.memtype import MemoryType
from shiny_mushroom.metadata import SPRITES
from shiny_mushroom.sprite_art import PlayerArt, SpriteTile

#: Where a capture reports what it did -- see
#: :data:`shiny_mushroom.emu.smw._log`, which this follows.
_log = logging.getLogger(__name__)

# -- making a sprite draw itself --------------------------------------------
#
# A sprite's appearance exists only as code, so the only way to know it is to
# run that code and read what it wrote. The recipe is smw-editor's: clear the
# slots, zero the camera, put the sprite somewhere on screen, wipe the sprite
# half of the OAM buffer, and call the game's own routines.

#: ``SMW_ProcessNormalSprites_Main`` and
#: ``SMW_InitializeNormalSpriteRAMTables_Main``.
#:
#: **These are U-cart addresses**, taken from a built symbol file. The five
#: releases do not have to agree on them, so a sprite capture against another
#: release would be reading whatever is at these addresses there. The level
#: load itself has no such dependency -- it drives the game through work RAM --
#: which is why this is the only release-specific thing in the package.
PROCESS_SPRITES = DEFAULT_ADDRESSES.process_sprites
INIT_SPRITE_TABLES = DEFAULT_ADDRESSES.init_sprite_tables

#: Normal sprites index OAM from object 64, so their half of the buffer starts
#: at ``$7E0300``. ``OAM_TILE_SIZES`` is the unpacked size/9th-bit table for the
#: same objects, which is why it is offset by ``$40`` entries as well.
OAM_BUFFER = 0x000300
OAM_TILE_SIZES = 0x000420 + 0x40
OAM_OBJECTS = 64


#: Written over both OAM buffers before a capture.
#:
#: Not a sentinel: which entries a sprite drew comes from the trace, see
#: :mod:`shiny_mushroom.emu.oam_writes`. This is here because the game *reads
#: these buffers back* -- ``FinishOAMWrite`` has a mode that keeps the size bit
#: already in ``$0460`` -- so a probe that does not clear them lets one sprite
#: inherit another's. ``$F0`` would do as well; ``$E0`` is what smw-editor uses
#: and both are off-screen Y values the game itself parks tiles at.
OAM_EMPTY = 0xE0

#: A Y coordinate at or below which an OAM entry is not on screen, and so is not
#: part of what a sprite draws.
#:
#: **Provenance alone is not enough here, and this is why.** A sprite does not
#: only write the entries it uses -- it *parks* the ones its current pose does
#: not need, by storing an off-screen Y and leaving the other three bytes alone.
#: A park is a store like any other, so the trace credits the sprite with an
#: entry holding a stale tile or none at all.
#:
#: That was always true and always wrong; what made it visible is that **the two
#: bases park at different heights** -- measured, vanilla at ``$E0`` and ``sa1``
#: at ``$F0`` -- so the same sprite came back with the same tile at two
#: positions. Sprite ``$70`` in level ``$0C7`` is the case that found it.
#:
#: The screen is 224 lines, so a tile at ``$E0`` is below all of them whichever
#: value was used. Filtering on being off screen rather than on a magic number
#: is what makes this a fact about the picture instead of a sentinel.
OAM_OFFSCREEN_Y = 0xE0


# -- the player: where he starts, and what he looks like --------------------


#: ``$7E00D1``/``$7E00D3``, 16-bit each: the same position as of the frame that
#: has already run, where :data:`PLAYER_X` is the one being computed for the next
#: one. ``UpdateCurrentPlayerPositionRAM`` copies one to the other every frame,
#: and no frame of the game runs during a probe -- so both have to be written to
#: move the player as far as a sprite is concerned. Sprite code reads both:
#: ``CheckPlayerPositionRelativeToSprite`` takes these, the collision routines
#: take ``$94``.
PLAYER_CURRENT_X = 0x0000D1
PLAYER_CURRENT_Y = 0x0000D3

#: How far from the sprite being probed the player is stood, on both axes.
#:
#: **The player is an input to a capture, and sprites read it**: ``$4C`` the
#: exploding block shatters when the player is close, a Monty Mole emerges, and
#: anything that faces the player turns. Where a load happened to leave them is
#: not a fact about the sprite, so the probe decides it -- far, which is what a
#: sprite sitting in a level nobody has walked into yet is looking at, and what
#: makes the answer the same wherever in the level the record sits.
#:
#: **Far is a low byte, not a distance.** ``CheckPlayerPositionRelativeToSprite``
#: truncates the difference to eight bits before any sprite tests it -- ``$4C``'s
#: test is ``ADC #$60 : CMP #$C0`` over that byte alone -- so a player parked
#: thousands of pixels away still reads as adjacent whenever the low byte lands
#: in range, which is how the first attempt at this failed. The low byte here is
#: ``$80``, the farthest eight bits can express and outside every symmetric
#: window narrower than the whole 256. The rest of the offset makes it far in
#: sixteen bits too, for whatever compares those.
#:
#: **Up and to the left, which is the side a level is entered from**, and not an
#: arbitrary choice between two: which side the player is on decides what several
#: sprites do, and one of them decides whether to exist. ``$9F`` Banzai Bill's
#: whole Status01 routine is "if the player is to the right of me, erase myself"
#: -- it only ever flies left, so a player on the right is nobody to fly at, and
#: probing with one there loses the sprite outright. Facing follows the same
#: reasoning: a sprite waiting in a level is waiting for somebody who has not
#: arrived yet, and it looks the way it looks the moment they do.
PLAYER_PROBE_OFFSET = -0x0880


#: ``$7E007E`` and ``$7E0080``, ``!RAM_SMW_Player_OnScreenPosXLo`` and ``_Y``.
#: Where the player is *on the screen*, written by the same routine that draws
#: him -- so an OAM entry minus this is that tile's offset from the player.
PLAYER_ON_SCREEN_X = 0x00007E
PLAYER_ON_SCREEN_Y = 0x000080

#: ``SMW_PlayerGFXRt_Main`` to the end of its code, from a built symbol file.
#: **U-cart addresses**, on the same terms as :data:`PROCESS_SPRITES`.
#:
#: The player is not a sprite: he is in none of the sprite tables and no sprite
#: number draws him, so the sprite capture never sees him. He is drawn by this
#: one routine, and its stores into the OAM buffer are exactly the tiles he is
#: made of -- which is what :meth:`SmwLevelLoader.capture_player_art` traces.
PLAYER_GFX_START = DEFAULT_ADDRESSES.player_gfx_start
PLAYER_GFX_END = DEFAULT_ADDRESSES.player_gfx_end

#: How far from the player's on-screen position one of his tiles can be before
#: it is taken to be parked rather than drawn.
#:
#: The routine writes every entry it owns on every frame, including the ones
#: this pose does not use, and parks those off the bottom of the screen -- at
#: ``y = $F0``, which is below a 239-line frame. Measured on small standing
#: Mario: two tiles at ``(+0,+1)`` and ``(+0,+17)`` are his, and five more sit
#: at ``y = $F0``. A box is used rather than a test for ``$F0`` because the
#: parking value is the routine's business and not a documented interface,
#: while "further from the player than he is tall" is a fact about the picture.
PLAYER_TILE_REACH_X = 32
PLAYER_TILE_REACH_UP = 32
PLAYER_TILE_REACH_DOWN = 48

#: The probe's step, in frames: what one wait step and one traced window cover.
#:
#: **Two, and not one.** A step ends on a frame boundary and the drawing routine
#: has not written its entries by the first one after mode ``$14`` is entered:
#: measured over six levels, five captures each, a one-frame window came back
#: empty *every* time and had to retry, while two, three and four never did. So
#: one frame is not cheaper -- it is the same work plus a wasted window -- and
#: anything above two is emulation nothing reads.
PLAYER_PROBE_FRAMES = 2

#: How far the probe will run the level to reach mode ``$14``, in frames. The
#: fade is wound forward rather than waited out
#: (:data:`SCREEN_BRIGHTNESS_MIRROR`), so one step is the ordinary case; this is
#: several times the thirty frames a fade takes, for a machine that arrives here
#: with something else to run through. A bound on a wait, not a duration.
PLAYER_PROBE_WAIT_FRAMES = 80

#: How many traced windows to give the drawing routine before concluding it is
#: not going to run. Each is :data:`PLAYER_PROBE_FRAMES` frames or a little
#: more -- see the phase shift in :meth:`SmwLevelLoader._probe_player`.
PLAYER_PROBE_TRIES = 8

#: Where SMW's ``$0300`` buffer lands in the OAM the PPU renders. The buffer is
#: the sprite half, and the sprite half starts at object 64 -- which is the same
#: offset :data:`OAM_TILE_SIZES` carries for the unpacked size table.
OAM_FIRST_SPRITE_OBJECT = 64

#: Where the high table starts in Mesen's 544-byte SNES OAM: 128 objects of four
#: bytes, then two bits per object of ninth-X-bit and size.
OAM_HIGH_TABLE = 512


#: Where the sprite is put, with the camera forced to the origin, so that an
#: OAM entry's coordinates are its offset from the sprite plus this. Far enough
#: from every edge that a big sprite is not clipped.
SPRITE_ORIGIN = 0x80

#: Console cycles one probe call may spend, against the ten frames
#: :data:`~shiny_mushroom.emu.core.CALL_BUDGET` allows any call. Tighter because
#: a sprite routine draws in a few thousand and a level has a dozen of them to
#: get through, and because a sprite number driven without what it expects is
#: the case that hangs -- ``$DB`` sends the main loop into a loop it never
#: leaves.
SPRITE_CALL_BUDGET = 2 * 47_000

#: Sprite numbers above this never draw: they are shooters, generators and
#: layer scroll commands.
LAST_DRAWING_SPRITE = 0xDF

#: ``$C9``-``$CA`` are shooters and ``$CB``-``$D9`` generators -- the same range
#: :class:`shiny_mushroom.sprites.SpriteKind` calls a spawner. They sit *below*
#: :data:`LAST_DRAWING_SPRITE` because ``$DA``-``$DF`` above them do draw, so
#: the exclusion has to be a hole rather than a ceiling.
FIRST_SPAWNER = 0xC9
LAST_SPAWNER = 0xD9

#: ``$DA``-``$DF`` in a sprite *stream* are not sprite numbers. ParseLevelSpriteList
#: converts them -- ``SBC #$DA / ADC #GreenKoopa`` -- and spawns the result
#: stunned, so a slot never holds one. Poking the raw number instead runs
#: whatever is at that index of the routine table: measured, ``$DB`` sends the
#: sprite main loop into a loop it never leaves.
STUNNED_SPRITE_FIRST = 0xDA
GREEN_KOOPA = 0x04

#: Which processors a probe's trace is logged for.
#:
#: Both, on every base, because asking a cartridge about a coprocessor it does
#: not have costs one stored option against a CPU that never executes -- whereas
#: getting it wrong the other way is silent. On ``sa1`` the main CPU's entire
#: contribution to a frame of sprite processing is the ``JML`` that hands the
#: work over: measured, 2 rows against 3092.
TRACED_CPUS = (CPU_TYPE_SNES, CPU_TYPE_SA1)

#: How many passes of the sprite main loop a probe runs after the init call.
#:
#: A pass is one frame's worth of sprite processing and nothing else: the machine
#: is halted with interrupts silenced, so no frame of the *game* runs between
#: them. The first is spent on the sprite's own initialisation -- it enters at
#: status Init, runs that, and is moved to Normal without drawing -- so the
#: earliest a sprite can draw is the second, and the picture read back is always
#: the last pass's, because the OAM buffer is cleared up front.
#:
#: **Three, because a sprite's first frame of being itself can be a transient
#: the game replaces on its next one.** ``$15`` and ``$16``, the fixed-movement
#: Cheep Cheeps, are the measured case: their routine branches on
#: ``!RAM_SMW_NorSpr_InLiquidFlag``, a fresh slot has it clear, and nothing sets
#: it until ``HandleNormalSpriteLevelCollision``'s buoyancy pass has run once --
#: so frame one is the fish flopping out of water, in a *different tile page*
#: from the swimming fish, and frame two is the fish the level holds. Two passes
#: captured the flop; three capture the fish, and match what ``$17`` -- which
#: never takes that branch -- drew all along. It also settles ``$3D`` Rip Van
#: Fish to asleep and ``$95`` Clappin' Chuck to clapping, both of which are what
#: those sprites do in a level.
#:
#: **Whether the sprite is in water is still the game's answer, not the probe's.**
#: In the two levels that place a ``$15`` out of water, three passes leave it
#: flopping.
#:
#: The extra pass costs nothing measurable -- 1944 ms against 1917 for four whole
#: level loads. It buys another frame of the sprite's *state* and not another
#: frame of its travel, because :meth:`SmwLevelLoader._draw_sprite` stands the
#: sprite back on its record at the top of every pass; the same method also stops
#: early for a sprite that has stopped being itself.
SPRITE_MAIN_PASSES = 3


#: Sprite slot tables, one byte per slot. ``$7E009E`` is the sprite number and
#: ``$7E14C8`` its status; ``$01`` is Init, which makes the game run the
#: sprite's own initialisation and then move it to Normal.
#:
#: **How many slots there are is the base's answer**, not a constant here --
#: More Sprites raises it from twelve to 22. See ``Addresses.sprite_slots``.
SPRITE_ID = 0x00009E
SPRITE_STATUS = 0x0014C8
SPRITE_STATUS_INIT = 0x01
SPRITE_Y_LO = 0x0000D8
SPRITE_X_LO = 0x0000E4
SPRITE_Y_HI = 0x0014D4
SPRITE_X_HI = 0x0014E0


#: Cluster sprites: ``$7E1892`` is twenty slots of sprite ID and ``$7E18B8`` the
#: flag that makes ProcessNormalSprites run them at all.
#:
#: They have to be cleared before a probe because they are drawn **from inside
#: the routine the probe calls**: ProcessNormalSprites ends by running the
#: cluster loop, so a level that has any -- a boo ceiling, a boo ring, a candle
#: flame -- draws them into the same OAM the probe is watching, and every one of
#: their tiles is then attributed to whichever sprite is being probed. Measured
#: on level $004: the message box came back with 21 tiles, one its own and
#: twenty boos scattered across the screen.
CLUSTER_SLOTS = 20
CLUSTER_SPRITE_ID = 0x001892
RUN_CLUSTER_SPRITES = 0x0018B8


def _oam_object(oam: bytes, obj: int) -> tuple[int, int, int, int, bool]:
    """One object out of the PPU's OAM, as ``(x, y, tile, attributes, large)``.

    Four bytes hold all of it but two bits, which live in the high table --
    bit 0 the ninth X bit, bit 1 the size -- packed four objects to a byte.
    Splitting an entry between two tables is the SNES's doing, and every reader
    of OAM here has to undo it the same way.
    """
    low = obj * 4
    high = oam[OAM_HIGH_TABLE + obj // 4] >> ((obj % 4) * 2)
    return (
        oam[low] | ((high & 0x01) << 8),
        oam[low + 1],
        oam[low + 2] | ((oam[low + 3] & 0x01) << 8),
        oam[low + 3],
        bool(high & 0x02),
    )


def _signed(value: int, modulus: int) -> int:
    """``value`` wrapped into the signed half of ``modulus``."""
    value %= modulus
    return value - modulus if value >= modulus // 2 else value


def _player_away(level: int) -> int:
    """Where to stand the player on one axis, given the sprite's position on it.

    :data:`PLAYER_PROBE_OFFSET` away, except where that would be off the front of
    the level -- for a sprite in the first few screens there is no room behind it
    to back off into. What is given up there is the distance and not the low byte
    every sprite's test actually reads, because the shortfall is taken in whole
    screens: the player ends up nearer, still ``$80`` away as far as eight bits
    can say, and still behind the sprite unless it stands within ``$80`` of the
    level's own edge.
    """
    away = level + PLAYER_PROBE_OFFSET
    return away if away >= 0 else away % 0x100


def can_draw(number: int) -> bool:
    """Whether driving this sprite number can produce a picture of itself.

    **The one gate every probe goes through**, whether the number came out of a
    level's stream or out of the catalogue: a number that fails this is answered
    with no artwork and is never poked into a slot.

    Above ``$DF`` a number is a layer scroll command. The loader never turns one
    into a sprite at all -- it reads the record and sets a scrolling mode -- so
    there is no sprite whose picture this could be. Writing the raw number into
    a slot regardless runs whatever the sprite routine table holds at that
    index, which draws *something*, and that something is a picture of a sprite
    the game never puts there.

    **Shooters and generators are excluded too**, which is the same judgement
    :class:`shiny_mushroom.sprites.SpriteKind` already makes: what they put on
    screen is the sprite they spawn, not themselves. Driving one in isolation
    produces an answer that is not reproducible -- measured, ``$D9`` came back
    with one tile on some loads of ``$001`` and none on others -- and that tile
    is not the generator's appearance in any case. They keep the block-sized
    marker every sprite with no captured art gets.
    """
    return number <= LAST_DRAWING_SPRITE and not FIRST_SPAWNER <= number <= LAST_SPAWNER


def _sprite_records(stream: bytes) -> Iterator[tuple[int, int, int]]:
    """Each ``(first, second, number)`` record of a sprite stream, in order.

    The one walk everything that reads a stream makes, so a number and the
    position it was read at can never come from two different readings of the
    same bytes.
    """
    cursor = 1  # past the stream's header byte
    while cursor + SPRITE_RECORD_SIZE <= len(stream) and stream[cursor] != 0xFF:
        first, second, number = stream[cursor : cursor + SPRITE_RECORD_SIZE]
        yield first, second, number
        cursor += SPRITE_RECORD_SIZE


def _sprite_numbers(stream: bytes) -> list[int]:
    """The distinct sprite numbers a stream carries, in ascending order.

    A reading of the stream and nothing else: which of them is worth driving is
    :func:`can_draw`'s, and which of them drags a second number along with it is
    :func:`with_revealed_forms`'. Both are asked once, of every number a capture
    is asked for, wherever it came from -- see
    :meth:`SmwLevelLoader._artwork`.
    """
    return sorted({number for _first, _second, number in _sprite_records(stream)})


def with_revealed_forms(numbers: Iterable[int]) -> list[int]:
    """``numbers``, each followed by the number it turns into if it has one.

    **A hidden sprite's revealed form is captured as well**, even though nothing
    may hold a record of it: ``$C7`` draws nothing, so the only thing that can
    be shown for it is the ``$74`` Mushroom it turns into, and a level with an
    invisible mushroom in it need not contain a visible one -- nor need the row
    the pointer is resting on in the catalogue.

    It is captured **under its own number** rather than under the hidden
    sprite's, so a capture still means "what number N draws" throughout; doing
    the substitution is :mod:`shiny_mushroom.sprites`' business, and it needs
    both entries present to do it.

    Distinct, in the order given, with each revealed form beside the sprite that
    asked for it.
    """
    return list(
        dict.fromkeys(
            found
            for number in dict.fromkeys(numbers)
            for found in (number, SPRITES.reveals.get(number))
            if found is not None
        )
    )


def _drawing_sprite_positions(
    stream: bytes, vertical: bool = False
) -> dict[int, tuple[int, int]]:
    """Where in the level each drawable number first appears, in pixels.

    A probe puts the sprite somewhere and runs its code, and **some sprites read
    their own position to decide what to draw**. ``$8C`` is the plain case: it
    tests bit 4 of its X and is a fireplace when the bit is clear and an
    invisible side-exit enabler when it is set, so probing it at a made-up
    position draws Yoshi's House's flame into levels that have no fireplace in
    them.

    The first record wins where a number appears more than once. That is a real
    limitation rather than a rounding of one -- the same number at two positions
    can draw two different things -- but the capture is keyed by number and one
    probe per number is what makes a load affordable.
    """
    positions: dict[int, tuple[int, int]] = {}
    for first, second, number in _sprite_records(stream):
        if number in positions:
            continue
        # The loader's own decoding, and the same axis swap parse_sprites makes.
        screen = (second & 0x0F) | ((first << 3) & 0x10)
        along = (screen * SCREEN_BLOCKS + (second >> 4)) * BLOCK_PIXELS
        across = ((first >> 4) | ((first & 0x01) << 4)) * BLOCK_PIXELS
        positions[number] = (across, along) if vertical else (along, across)
    # A revealed form is probed at the hidden sprite's own position, since it is
    # where it would appear and the level may hold no record of it to place it
    # from. Its own record wins where there is one.
    for number, becomes in SPRITES.reveals.items():
        if number in positions and becomes not in positions:
            positions[becomes] = positions[number]
    return positions


def slot_sprite_number(number: int) -> int:
    """What a stream number becomes once the loader has spawned it.

    Only ``$DA``-``$DF`` change, and they change into Koopas.
    """
    if number < STUNNED_SPRITE_FIRST:
        return number
    return number - STUNNED_SPRITE_FIRST + GREEN_KOOPA


class SpriteProbe:
    """The loader's sprite and player art capture.

    Mixed into :class:`~shiny_mushroom.emu.smw.SmwLevelLoader`, whose core,
    savestates and scratch states every method here drives.
    """

    # -- what the player looks like ----------------------------------------

    def capture_player_art(self) -> PlayerArt:
        """Make the game draw the player, and read the tiles back.

        Asked for once and kept, not taken with every load: unlike a sprite,
        the player's graphics and palette do not come from the level's tileset.

        **The level has to be running, not merely loaded.** A load stops in mode
        ``$13``, the fade, where the player's drawing routine has not run yet --
        measured, tracing it there yields no OAM writes at all. So the machine
        is run on until mode ``$14`` first, which is also what puts his tiles in
        VRAM: they are DMA'd there per frame from his pose, so a probe that ran
        earlier would come back with correct tile *numbers* pointing at somebody
        else's pixels.

        **The fade is wound forward rather than waited out**, which is nearly the
        whole cost of this: thirty frames of emulation at ~5 ms each was 240 ms
        of a 300 ms capture, against ~65 ms for the whole thing now. See
        :data:`SCREEN_BRIGHTNESS_MIRROR` for the three bytes and
        :meth:`_wind_fade_forward` for what it does not assume.

        Everything this disturbs is put back from a savestate, on the same terms
        as the sprite probe: the frames run here move the level on, and the next
        thing to read this machine would otherwise see a level part way into
        being played.
        """
        if not self.addresses.driven.player_art:
            # A base on which nothing has established that his tiles end up
            # somewhere this reads. No base in the registry declares that today
            # -- the check stands because "the probe came back empty" and "the
            # probe was never wired up here" are the same picture otherwise, and
            # the window says which one it is. An empty capture is what a failed
            # probe already looks like, and no marker is drawn for one -- see
            # :class:`PlayerArt.__bool__`.
            _log.debug(
                "no player capture: %s has no wired-up probe",
                self.addresses.ram.id,
            )
            return PlayerArt(tiles=(), vram=b"", cgram=b"")
        with self.over_scratch_state("pre-player-art.mst"):
            try:
                return self._probe_player()
            except EmulatorUnavailable as unavailable:
                # One marker is never worth a level. The caller gets "nothing
                # was found" and draws no player rather than failing the load.
                _log.debug("player capture did not return: %s", unavailable)
                return PlayerArt((), b"", b"")

    def _probe_player(self) -> PlayerArt:
        """One pass: run the level, trace the drawing routine, read the tiles."""
        core = self.core
        where = self.addresses
        core.halt()
        self._wind_fade_forward()
        for _ in range(PLAYER_PROBE_WAIT_FRAMES // PLAYER_PROBE_FRAMES):
            if core.read(*where.at(GAME_MODE)) == MODE_IN_LEVEL:
                break
            core.step_frame(PLAYER_PROBE_FRAMES)
        else:
            _log.debug("player capture never reached mode $14")
            return PlayerArt((), b"", b"")

        # **Traced until he is actually drawn, not once.** Reaching mode $14 is
        # not the same as the player being on screen in it, and the routine
        # writes its entries either way -- it parks the ones the pose does not
        # use off the bottom. Measured over repeated loads, about one capture in
        # six landed on a frame where *every* entry was parked and came back
        # empty, which is never a fact about the player: he is always drawn
        # eventually. So the loop's test is whether a tile came back, not
        # whether the routine ran. Each attempt is four frames, so waiting costs
        # a few milliseconds and only in the case that would otherwise fail.
        log = self.state_dir / "player-oam.trace"
        condition = oam_condition((where.player_gfx_start, where.player_gfx_end))
        ram = RamView(core, where)
        tiles: tuple[SpriteTile, ...] = ()
        for attempt in range(PLAYER_PROBE_TRIES):
            with core.tracing(log, condition, OAM_COLUMNS, cpus=TRACED_CPUS):
                core.step_frame(PLAYER_PROBE_FRAMES)
            core.halt()
            with log.open(errors="replace") as rows:
                written = parse_oam_writes(rows, where.ram)
            tiles = self._player_tiles(
                core.read_all(MemoryType.SNES_SPRITE_RAM),
                (ram.word(PLAYER_ON_SCREEN_X), ram.word(PLAYER_ON_SCREEN_Y)),
                self._player_entries(written),
            )
            if tiles:
                break
            _log.debug("player capture: nothing drawn on attempt %d", attempt)
        else:
            _log.debug("player capture found no tiles near the player")

        return PlayerArt(
            tiles,
            core.read_all(MemoryType.SNES_VIDEO_RAM),
            core.read_all(MemoryType.SNES_CG_RAM),
        )

    def _player_entries(
        self, written: frozenset[int]
    ) -> frozenset[tuple[int, int, int, bool]]:
        """What his routine put in the OAM buffer entries the trace says it
        wrote -- ``(x, tile, attributes, large)``, an entry's whole content bar
        its Y.

        **This is how one figure is told from the rest of the picture**, and it
        is provenance rather than proximity: the entries come from the trace of
        his drawing routine, so a sprite standing where he starts contributes
        nothing to it. :meth:`_player_tiles` then looks for these on screen.

        The Y is deliberately left out, and is the reason this reads four bytes
        rather than taking the whole entry. The game clears the buffer's Y bytes
        to ``$F0`` at the top of every frame and refills them as the frame's
        work runs, and a probe halts at a fixed point that can fall between the
        two -- measured on ``sa1``, his entries came back with the right X and
        tile number and a parked Y. Nothing else in an entry is rewritten from
        scratch each frame, so the rest of it is his whichever side of the clear
        the read landed on.

        Read through :meth:`~shiny_mushroom.addresses.Addresses.at`, so a base
        that keeps low RAM somewhere else is read where it keeps it, and
        ``written``'s offsets stay vanilla ones -- see
        :mod:`shiny_mushroom.emu.oam_writes`.
        """
        where = self.addresses
        oam_memory, oam_at = where.at(OAM_BUFFER)
        sizes_memory, sizes_at = where.at(OAM_TILE_SIZES)
        buffer = self.core.read_all(oam_memory)
        sizes = (
            buffer if sizes_memory is oam_memory else self.core.read_all(sizes_memory)
        )
        entries = set()
        for object_index in range(OAM_OBJECTS):
            # The trace's offsets are vanilla ones whatever base they came off,
            # so which entry he claimed is asked in vanilla numbering and the
            # bytes are then read at wherever this base keeps them -- the same
            # two numberings :meth:`_sprite_tiles` keeps apart.
            claimed = OAM_BUFFER + object_index * 4
            if not any(claimed + byte in written for byte in range(4)):
                continue
            entry = oam_at + object_index * 4
            size = sizes[sizes_at + object_index]
            entries.add(
                (
                    buffer[entry] | ((size & 0x01) << 8),
                    buffer[entry + 2] | ((buffer[entry + 3] & 0x01) << 8),
                    buffer[entry + 3],
                    bool(size & 0x02),
                )
            )
        return frozenset(entries)

    @staticmethod
    def _player_tiles(
        oam: bytes,
        on_screen: tuple[int, int],
        entries: frozenset[tuple[int, int, int, bool]],
    ) -> tuple[SpriteTile, ...]:
        """His entries as the PPU is rendering them, relative to him.

        **Which tiles are his** is :meth:`_player_entries`, and so the trace of
        his drawing routine. **Where they are** is read from the OAM the PPU
        renders, which is a different memory and the reason this is reliable:
        it is only ever replaced wholesale, by the NMI upload, so it always
        holds one whole frame where the buffer can be caught mid-refill.

        **He is found in it by what he looks like, not by which object he
        became.** The buffer at ``$0300`` is the sprite half of OAM on a stock
        cartridge -- entry ``n`` is object ``64 + n``, fixed by the game's own
        allocator -- and that is an assumption about the *allocator* rather than
        about the game. Under SA-1 Pack, MaxTile composites four priority
        buffers into the PPU's 128 objects at end of frame, and measured on
        ``sa1`` the same two tiles land at objects **125 and 126**, at a place
        that depends on how much else drew that frame. So every object is
        searched and the ones carrying his entries' contents are his, which no
        base has to declare and which reads a stock cartridge identically.

        The cost is that the OAM is the *previous* frame's picture while the
        on-screen position is this one's, so a tile can come back a pixel from
        where it was drawn. For a marker showing where a level starts, that is
        not worth another frame step to remove.

        Everything further from him than he is tall is one of the entries the
        routine parked off screen for a pose that does not use it -- kept out
        here rather than out of the search, because a parked entry and a drawn
        one can hold the same tile -- see :data:`PLAYER_TILE_REACH_X`.

        **What the two filters together do not rule out** is another sprite's
        object standing within reach of him and carrying one of his entries'
        four bytes exactly -- the same X, the same tile, the same attributes and
        the same size. Nothing measured has produced one, and the cost of one
        would be a stray tile beside the marker rather than a wrong marker; the
        alternative is to trust which object an allocator assigned, which is the
        assumption this replaced.
        """
        on_screen_x, on_screen_y = on_screen
        tiles = []
        for object_index in range(2 * OAM_OBJECTS):
            x, y, tile, attributes, large = _oam_object(oam, object_index)
            if (x, tile, attributes, large) not in entries:
                continue
            offset_x = _signed(x - on_screen_x, 0x200)
            offset_y = _signed(y - on_screen_y, 0x100)
            if not -PLAYER_TILE_REACH_X <= offset_x <= PLAYER_TILE_REACH_X:
                continue
            if not -PLAYER_TILE_REACH_UP <= offset_y <= PLAYER_TILE_REACH_DOWN:
                continue
            tiles.append(
                SpriteTile(
                    x=offset_x,
                    y=offset_y,
                    tile=tile,
                    attributes=attributes,
                    large=large,
                )
            )
        return tuple(tiles)

    # -- what each sprite in this level looks like -------------------------

    def _sprite_art(
        self, level: int, header: bytes, stream: bytes, vertical: bool
    ) -> dict[int, tuple[SpriteTile, ...]]:
        """This level's sprite artwork: :meth:`_artwork` for what its stream
        holds, each number where its first record stands.

        **The capture is the expensive half of a load** -- measured on level
        ``$105``, 367 ms of 645 for twelve numbers, because each one is a
        savestate restore and three traced ``call``s. It is also the half an
        edit almost never changes, which is what the cache is for.
        """
        return self._artwork(
            _sprite_numbers(stream),
            level,
            header,
            _drawing_sprite_positions(stream, vertical),
        )

    def artwork_for(
        self, numbers: Iterable[int], level: int, header: bytes
    ) -> dict[int, tuple[SpriteTile, ...]]:
        """Capture artwork for sprite numbers **not in the loaded level**.

        What a catalogue preview needs, and the level's own capture cannot give
        it: :meth:`_sprite_art` asks for the numbers a level's stream holds, and
        the create panel offers two hundred it does not.

        The same :meth:`_artwork` and so the same cache, keyed the same way, so
        a number that is in the level and one that was hovered are one entry and
        neither is captured twice. Nothing is known about where a hovered number
        would stand, so every one of them is stood at :data:`SPRITE_ORIGIN` --
        which is the same default a record the stream reader cannot place gets.

        Asked for a few numbers at a time, on demand, and never for the whole
        catalogue at once: each is a savestate restore and three traced calls,
        ~30 ms, so probing all 166 the cartridge places would be five seconds.
        """
        return self._artwork(numbers, level, header, {})

    def _artwork(
        self,
        numbers: Iterable[int],
        level: int,
        header: bytes,
        where: Mapping[int, tuple[int, int]],
    ) -> dict[int, tuple[SpriteTile, ...]]:
        """Artwork for ``numbers`` under this level's graphics, captured once
        per number and kept.

        **The one path to a capture**, whether the numbers came out of a level's
        stream or off the row the pointer is resting on. Everything that decides
        what a capture *means* is here rather than at either caller, because two
        of them drifted apart once already: the catalogue drove scroll commands
        the stream reader had always refused, which fabricated artwork for them
        and eventually took the core down.

        Three things happen to a number before it is driven, in this order:

        - :func:`with_revealed_forms` adds the sprite a hidden one turns into,
          which is the only picture there is for it;
        - :func:`can_draw` decides whether driving it can answer at all. One
          that cannot is answered with no artwork and is never poked into a
          slot, and is not cached either -- that is a fact about the number, not
          about this level;
        - ``where`` says where to stand it, defaulting to :data:`SPRITE_ORIGIN`.

        **The key is ``(level, header, number, position)``**, which is the whole
        of what a capture is a function of: what a sprite draws is decided by
        its number, by the graphics and palettes the level's header asked for,
        and by where in the level it stands. Nothing else a preview patches is
        among them.

        **Position is in the key because it has to be, not for safety.**
        Measured across seven levels, moving a sprite changes what it draws for
        3 of 40 numbers -- with an unmoved reload as the control, so the
        capture's own jitter is not being counted. It is rare and it is not
        subtle: ``$8C`` in Yoshi's House draws a two-tile fireplace where it
        stands and **nothing at all** a block to the right, because it tests
        bit 4 of its own X and is a side-exit enabler when that bit is set. A
        key without the position would leave a fireplace on the canvas that the
        game does not draw. See :func:`_drawing_sprite_positions`.

        **Per number rather than per level**, which is what makes editing
        sprites affordable as well as objects: moving one sprite re-captures
        that one number and keeps the other eleven, instead of paying for the
        level again. Moving an *object* touches none of them -- measured over
        four levels, an object edit leaves every number's artwork byte-identical,
        which is why the object stream is not in the key.

        Which is what makes an edited level affordable at all: a patched load
        can never reuse a warm state -- that state was captured with the
        cartridge's own bytes already expanded into memory -- so without this a
        refresh pays for every sprite in the level again to redraw a block that
        moved.

        It is also **more** reproducible than capturing every time, not less.
        Measured over five loads of level ``$001``, a capture taken from the
        title state and one taken from a warm state disagree by a pixel of ``y``
        and by which frame of a two-frame pose the sprite was on -- so the
        outline around a sprite already moved when a level was merely revisited.
        Caching settles it on the first answer for as long as the level's own
        bytes say the same thing.

        Every number asked for is in the answer, in the order it was asked for,
        with the revealed forms beside the sprites that dragged them in. One
        that drew nothing is an empty tuple rather than an absent key, so a
        caller can tell "asked and got nothing" from "not asked yet" and does
        not queue it again every time the pointer passes.
        """
        wanted = with_revealed_forms(numbers)
        if not self.addresses.driven.sprite_art:
            # No artwork is the honest answer, and the editor already draws a
            # block-sized marker for a sprite it has none for.
            _log.debug(
                "no sprite capture: %s has no wired-up probe", self.addresses.ram.id
            )
            return dict.fromkeys(wanted, ())
        keys = {
            number: (
                level,
                header,
                number,
                where.get(number, (SPRITE_ORIGIN, SPRITE_ORIGIN)),
            )
            for number in wanted
            if can_draw(number)
        }
        found: dict[int, tuple[SpriteTile, ...]] = {
            number: () for number in wanted if number not in keys
        }
        found |= {
            number: self._art[key] for number, key in keys.items() if key in self._art
        }
        missing = [number for number in keys if number not in found]
        if missing:
            probed = self._capture_sprite_art(missing, where)
            for number in missing:
                found[number] = probed.get(number, ())
                self._remember_art(keys[number], found[number])
            for stale in list(self._art)[: -self.art_cache_size]:
                del self._art[stale]
            for stale in list(self._silent)[: -self.art_cache_size]:
                self._silent.discard(stale)
        # In the order they were asked for, so a reader sees the same mapping
        # whether it was captured or remembered.
        return {number: found[number] for number in wanted}

    def _remember_art(
        self,
        key: tuple[int, bytes, int, tuple[int, int]],
        tiles: tuple[SpriteTile, ...],
    ) -> None:
        """Keep a capture, and **keep "nothing" only the second time it is seen.**

        A capture that comes back empty is either the truth about the sprite or a
        probe that failed, and one observation cannot tell them apart. Cached
        immediately, a failure is permanent: the key is
        ``(level, header, number, position)``, none of which an idle editor
        changes, so every later refresh is answered out of the cache and the
        sprite is a glyph until it is moved again. That is the difference between
        a rare flake and a sprite that has visibly stopped being drawn.

        **And the protection that catches this on a cold load is off for an
        edit.** :meth:`_capture_sprite_art` retries a batch that drew nothing at
        all, but only when the game can be run on this machine and only for a
        batch of two or more -- and an edit is neither: it reaches the machine
        through :meth:`_rebuild`, which clears :attr:`_game_runnable`, and it
        re-probes just the number whose position moved.

        So the second observation comes from the next refresh instead of from an
        immediate retry, which needs no frame of the game and so is available on
        the path a rebuild leaves behind. A number that genuinely draws nothing
        settles into the cache one probe later than it used to and stays there;
        a number that failed once is asked again and answers.
        """
        if tiles or key in self._silent:
            self._art[key] = tiles
            self._silent.discard(key)
            return
        self._silent.add(key)

    def _capture_sprite_art(
        self, numbers: list[int], where: Mapping[int, tuple[int, int]]
    ) -> dict[int, tuple[SpriteTile, ...]]:
        """Make the game draw each of ``numbers`` and read the tiles back.

        Done at the end of the load, because the machine is already holding this
        level's sprite graphics and palettes -- which is why the answer belongs
        to the level and not to the sprite number alone.

        Measured as free of the game mode: capturing at the end of mode ``$12``,
        where the loader stops, gives byte-identical results to doing it in mode
        ``$14`` twenty frames later, so the fade does not have to be paid for.

        **A capture fails all at once or not at all, and it is retried when it
        does.** Every probe restores the same pre-probe savestate, so whatever
        makes ``ProcessNormalSprites`` fail to return is a property of that
        state rather than of a sprite: measured over six loads of one level, a
        bad state lost all ten drawable sprites and a good one lost none. Losing
        every sprite is never a fact about a level, so it is worth one more
        state and one more pass; a level where some sprites draw and others do
        not is the ordinary case and is left alone.

        **That sentence needs more than one sprite to be a sentence.** Judged
        over the numbers *this* call probed, and a caller can ask for one --
        a hovered row, or the single number a sprite edit moved. With a batch of
        one, "none of them drew" and "this sprite draws nothing" are the same
        observation, and the second is an ordinary answer: a trigger, a warp
        hole, a shooter's spawn. Retrying there spends a second pass, roughly 30
        ms, to be told the same true thing again. So the evidence is only read as
        evidence when there was a batch to lose.

        **And only on a machine the game can be run on**, which is what
        :attr:`_game_runnable` says. The retry advances a frame, and after a
        rebuild that frame is a frame of the game over a machine mid-surgery --
        exactly the step :meth:`_capture` refuses for itself, and for the same
        reason.
        """
        if not numbers:
            return {}
        art = self._probe_sprites(numbers, where)
        if any(art.values()) or len(numbers) < 2 or not self._game_runnable:
            return art
        _log.warning(
            "sprite capture drew nothing for any of %d numbers (%s); retrying",
            len(numbers),
            ", ".join(hexnum(n) for n in numbers),
        )
        # A frame first, or the retry is the previous attempt again: the state
        # every probe restores is saved from a machine that has not moved since,
        # so retrying without advancing it reproduces the failure by
        # construction. Whether one frame is enough is not established -- the
        # failure is roughly one load in sixty, which is too rare to have been
        # measured either way.
        self.core.halt()
        self.core.step_frame(1)
        return self._probe_sprites(numbers, where)

    def _probe_sprites(
        self, numbers: list[int], where: Mapping[int, tuple[int, int]]
    ) -> dict[int, tuple[SpriteTile, ...]]:
        """One pass over ``numbers``, from one pre-probe state."""
        with self.over_scratch_state("pre-sprite-art.mst") as scratch:
            if _log.isEnabledFor(logging.DEBUG):
                state = self.core.cpu_state()
                _log.debug(
                    "sprite capture from mode $%02X, frames $%02X/$%02X, %s",
                    self.core.read(*self.addresses.at(GAME_MODE)),
                    self.core.read(*self.addresses.at(FRAME_COUNTER_GLOBAL)),
                    self.core.read(*self.addresses.at(FRAME_COUNTER_LOCAL)),
                    state,
                )
            return {
                number: self._draw_sprite(
                    number, scratch, where.get(number, (SPRITE_ORIGIN, SPRITE_ORIGIN))
                )
                for number in numbers
            }

    def _draw_sprite(
        self, number: int, scratch: Path, at: tuple[int, int]
    ) -> tuple[SpriteTile, ...]:
        """One sprite, drawn by its own code, as tiles relative to itself.

        ``at`` is where the sprite sits in the level, in pixels. It is written
        as the sprite's real position and the camera is moved to match, rather
        than both being faked, because a sprite may read its own coordinates:
        see :func:`_drawing_sprite_positions`.
        """
        core = self.core
        where = self.addresses
        core.load_state(scratch)
        # Stop the machine before setting anything up. Everything below is a
        # write into the game's own memory, and a running game undoes all of it
        # -- it clears OAM every frame, re-derives the camera from the player,
        # and processes the sprite slots -- so the probe would be configuring a
        # machine that keeps overwriting the configuration.
        core.halt()
        # And keep the frame's own handler out of the probe. `call` runs the
        # routine wherever in the frame the machine happens to be, so a VBlank
        # can land inside it -- and a sprite drawn across one comes back with
        # tiles parked offscreen or with a neighbour's. See
        # `MesenCore.silence_interrupts`; the savestate restore in
        # `_probe_sprites` is what puts $4200 back.
        core.silence_interrupts()
        write = core.write

        # **Every slot this base has, not every slot vanilla had.** More Sprites
        # raises the cap to 22, and the ten past the twelfth are as capable of
        # drawing over the capture as the first twelve -- see
        # `RamMap.sprite_slots`.
        for slot in range(where.sprite_slots):
            write(*where.slot(SPRITE_STATUS, slot), 0)
        # Everything else that draws from inside the routine the probe calls.
        # See CLUSTER_SPRITE_ID.
        write(*where.at(RUN_CLUSTER_SPRITES), 0)
        for slot in range(CLUSTER_SLOTS):
            write(*where.at(CLUSTER_SPRITE_ID + slot), 0)

        # The sprite at its own position in the level, and the camera placed so
        # that it lands :data:`SPRITE_ORIGIN` inside the screen -- comfortably
        # away from every edge, because a sprite whose tiles fall outside the
        # screen is one the game parks rather than draws. Both are needed: the
        # screen position is what makes it draw at all, the level position is
        # what some sprites read to decide *what* to draw.
        level_x, level_y = at
        camera_x, camera_y = (
            max(0, level_x - SPRITE_ORIGIN),
            max(0, level_y - SPRITE_ORIGIN),
        )
        for offset, value in ((0, camera_x), (2, camera_y)):
            self._write_word(CAMERA_X + offset, value)
        driven = slot_sprite_number(number)
        write(*where.slot(SPRITE_ID, 0), driven)
        self._stand_probe(level_x, level_y)
        write(*where.slot(SPRITE_STATUS, 0), SPRITE_STATUS_INIT)
        # Same pose every time, whatever frame the load stopped on.
        write(*where.at(FRAME_COUNTER_GLOBAL), FRAME_COUNTER_POSE)
        write(*where.at(FRAME_COUNTER_LOCAL), FRAME_COUNTER_POSE)

        # Both OAM buffers are cleared first, and **not** as a sentinel -- the
        # trace is what says which entries the sprite drew, and measured across
        # four levels every one of 323 entries it drew had all four of its bytes
        # written, so nothing here is looking for a leftover $E0.
        #
        # They are cleared because the game reads them back. FinishOAMWrite is
        # documented in its own comment as taking "80+ = manually set via $0460"
        # for the tile size, and on that path it loads the existing $0460 entry,
        # masks it and stores it again -- so a sprite can inherit the size and
        # position a previous frame left rather than setting its own. Measured
        # over twenty loads each: without this, level $001 came back degraded on
        # seven of them and $105 on one; with it, neither lost a sprite.
        for byte in range(OAM_OBJECTS * 4):
            write(*where.at(OAM_BUFFER + byte), OAM_EMPTY)
        for object_index in range(OAM_OBJECTS):
            write(*where.at(OAM_TILE_SIZES + object_index), 0)

        # Init, then the main loop: the first pass runs the sprite's own
        # initialisation and moves it to Normal, and the rest are it being
        # itself. See SPRITE_MAIN_PASSES for why that is more than one.
        #
        # Traced, so that what comes back is what *this sprite's code* wrote
        # rather than whatever the buffer holds afterwards.
        log = self.state_dir / "sprite-oam.trace"
        condition = oam_condition(where.traced.sprite_gfx)
        try:
            with core.tracing(log, condition, OAM_COLUMNS, cpus=TRACED_CPUS):
                core.call(
                    where.init_sprite_tables,
                    budget=SPRITE_CALL_BUDGET,
                    direct_page=where.direct_page,
                )
                for _ in range(SPRITE_MAIN_PASSES):
                    core.halt()
                    # **A pass the sprite would begin as a different number is
                    # not this sprite's pass.** A sprite can write over its own
                    # `SpriteID`: $4C, the exploding block, shatters into the
                    # enemy it holds when the player is near, and $C7 becomes a
                    # mushroom on contact. Both draw themselves before that, so
                    # the honest picture is the last pass that started out as
                    # the number asked for -- without this, $4C captures as the
                    # Koopa inside it rather than as the block a level shows.
                    if core.read(*where.slot(SPRITE_ID, 0)) != driven:
                        break
                    # **Sprite and player stood back where they belong at the
                    # top of every pass**, so that what the extra pass buys is
                    # another frame of the sprite's *state* and not another frame
                    # of its travel. A sprite moves itself while it is being
                    # probed and OAM is written from where it is, so without this
                    # the tiles come back offset by however far it got -- and by
                    # more the longer the probe runs, because gravity keeps
                    # accelerating it. Measured, an unpinned third pass put a
                    # falling $4F eight pixels below the block its record names.
                    #
                    # It does not make the capture a lie about a moving sprite:
                    # a sprite's own code decides its speed from its state every
                    # frame, and where a record puts it is where the editor draws
                    # it. What is left is whatever it travels *within* the pass
                    # before drawing, which is one frame's worth at most and does
                    # not grow.
                    #
                    # The player is rewritten with it because sprite code moves
                    # that too -- a carried or line-guided sprite writes $94.
                    self._stand_probe(level_x, level_y)
                    core.call(
                        where.process_sprites,
                        budget=SPRITE_CALL_BUDGET,
                        direct_page=where.direct_page,
                    )
        except EmulatorUnavailable as unavailable:
            _log.debug("sprite $%02X did not return: %s", number, unavailable)
            # A sprite driven without whatever it expects can fail to return --
            # measured on a raw $DA-$DF number before those were translated. It
            # is caught rather than fatal because one sprite that will not draw
            # must not cost the level: the answer is "nothing was found", and
            # the caller restores the machine either way.
            return ()
        # `call` ends on a pause, which is a request rather than a stop, so the
        # machine can still be executing while the buffer is read. Nothing was
        # measured going wrong here, but the read below is the whole result and
        # a halt costs a fraction of a millisecond.
        core.halt()
        with log.open(errors="replace") as rows:
            written = parse_oam_writes(rows, where.ram)

        oam_memory, oam_at = where.at(OAM_BUFFER)
        sizes_memory, sizes_at = where.at(OAM_TILE_SIZES)
        buffer = core.read_all(oam_memory)
        sizes = buffer if sizes_memory is oam_memory else core.read_all(sizes_memory)
        # Where the sprite is on screen, which is what an OAM coordinate is
        # measured from. Not SPRITE_ORIGIN: near the start of a level the camera
        # cannot back off that far and the sprite sits closer in. The position
        # written is the position it drew from, because every pass stands it back
        # there first.
        origin_x, origin_y = level_x - camera_x, level_y - camera_y
        tiles = []
        for object_index in range(OAM_OBJECTS):
            # The trace's offsets are vanilla ones whatever base they came off,
            # so which entry a sprite claimed is asked in vanilla numbering and
            # the bytes are then read at wherever this base keeps them.
            claimed = OAM_BUFFER + object_index * 4
            entry = oam_at + object_index * 4
            # Any of the four: a sprite that set a tile number and left the
            # position alone has still claimed the entry, and dropping it would
            # lose a tile that is genuinely on screen.
            if not any(claimed + byte in written for byte in range(4)):
                continue
            y = buffer[entry + 1]
            # Written, but parked rather than drawn -- see OAM_OFFSCREEN_Y.
            if y >= OAM_OFFSCREEN_Y:
                continue
            size = sizes[sizes_at + object_index]
            x = buffer[entry] | ((size & 0x01) << 8)
            tiles.append(
                SpriteTile(
                    # Signed, and wrapped through the 9-bit X the PPU uses: a
                    # tile hanging off the sprite's left is a large X, not a
                    # negative one.
                    x=_signed(x - origin_x, 0x200),
                    y=_signed(y - origin_y, 0x100),
                    tile=buffer[entry + 2] | ((buffer[entry + 3] & 0x01) << 8),
                    attributes=buffer[entry + 3],
                    large=bool(size & 0x02),
                )
            )
        return tuple(tiles)

    def _stand_probe(self, level_x: int, level_y: int) -> None:
        """Put slot 0 where its record says, and the player out of its way.

        Both, together, because where the player is only means anything relative
        to the sprite -- see :data:`PLAYER_PROBE_OFFSET`.

        The sprite's high byte is the coordinate's alone here: the extra bits
        that ride in it for a sprite the loader spawned from a record are not
        something the probe puts there.
        """
        where = self.addresses
        for table, value in (
            (SPRITE_X_LO, level_x),
            (SPRITE_Y_LO, level_y),
        ):
            self.core.write(*where.slot(table, 0), value & 0xFF)
        for table, value in (
            (SPRITE_X_HI, level_x),
            (SPRITE_Y_HI, level_y),
        ):
            self.core.write(*where.slot(table, 0), (value >> 8) & 0xFF)
        away_x, away_y = _player_away(level_x), _player_away(level_y)
        for address, value in (
            (PLAYER_X, away_x),
            (PLAYER_Y, away_y),
            (PLAYER_CURRENT_X, away_x),
            (PLAYER_CURRENT_Y, away_y),
        ):
            self._write_word(address, value)
