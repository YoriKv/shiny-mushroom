"""Capturing the overworld by running the game's own map code.

The same machine the level loader drives, asked for the world map instead: the
game is taken to the overworld, the map's tilemap and Layer 2 are read back, and
its sprites and the player's marker are captured by staging each one on screen
and harvesting the OAM it draws into. What comes back is a
:class:`~shiny_mushroom.overworld_snapshot.OverworldSnapshot`.

:class:`OverworldCapture` is mixed into
:class:`~shiny_mushroom.emu.smw.SmwLevelLoader` rather than standing alone:
every method here drives that session's core, savestates and title anchor.
"""

from __future__ import annotations

import logging
import time
from collections.abc import Mapping, Sequence
from dataclasses import replace
from pathlib import Path

from shiny_mushroom.addresses import (
    BACK_AREA_COLOR,
    GAME_MODE,
    INTRO_LEVEL_FLAG,
    MAP16_DEF_SIZE,
    MAP16_LOW,
    MARIO_MAP,
    NMI_IN_LEVEL,
    RamView,
)
from shiny_mushroom.emu.core import EmulatorUnavailable
from shiny_mushroom.emu.loading import LevelLoadError, _through, retry_load
from shiny_mushroom.emu.sprite_probe import (
    OAM_OBJECTS,
    _oam_object,
    _signed,
)
from shiny_mushroom.memtype import MemoryType
from shiny_mushroom.overworld import TILE_COUNT, TILEMAP_SIZE
from shiny_mushroom.overworld_snapshot import (
    MODE_LOAD_OVERWORLD,
    MODE_OVERWORLD,
    OW_DESTROY_TILES,
    OW_EVENT_ENTRY_COUNT,
    OW_EVENT_ENTRY_SIZE,
    OW_EVENT_FLAGS,
    OW_EVENT_FLAGS_SIZE,
    OW_LAYER1_X,
    OW_LAYER1_Y,
    OW_LAYER2,
    OW_LAYER2_SIZE,
    OW_LEVEL_TILE_SETTINGS,
    OW_LEVEL_TILE_SETTINGS_SIZE,
    OW_LIVE_SPRITE_ID,
    OW_LIVE_SPRITES,
    OW_LIVE_STATE,
    OW_LIVE_X_HI,
    OW_LIVE_X_LO,
    OW_PLAYER_X,
    OW_PLAYER_Y,
    OW_SHEETS_SIZE,
    OW_SPRITE_BOO_OFFSETS_SIZE,
    OW_SPRITE_DISABLE_SIZE,
    OW_SPRITE_SLOTS_SIZE,
    OW_SPRITE_SMOKE_POSITIONS_SIZE,
    OW_TRANSLEVELS,
    SUBMAP_COUNT,
    OverworldSnapshot,
)
from shiny_mushroom.rom_patches import patch_key
from shiny_mushroom.sprite_art import SpriteTile

#: Where a capture reports what it did -- see
#: :data:`shiny_mushroom.emu.smw._log`, which this follows.
_log = logging.getLogger(__name__)

#: How far an overworld sprite's OAM entries can sit from its own position
#: and still be its: sideways, above (flight height included) and below (the
#: white shadow oval rides ~55 under a leaping sprite). Tight enough that
#: the player's marker, kept away from the staging corner, cannot fall in.
OW_ART_REACH_X = 56
OW_ART_REACH_UP = 80
OW_ART_REACH_DOWN = 64

#: How long the load is given to hand over to the running overworld before
#: the capture gives up on framing its sprites: mode $0E arrives about 30
#: frames after $0C ends on the shipped cart.
OW_ART_MODE_FRAMES = 192

#: Where staged sprites are parked for the one framed capture, as screen
#: spots -- spread enough that nearest-spot attribution is unambiguous for
#: anything a sprite draws about itself, and pushed right and down so their
#: reach stays clear of the screen's top-left corner, where the overworld
#: keeps its own furniture (see :data:`OW_ART_DRESSING_X`).
OW_ART_SPOTS = tuple((x, y) for y in (72, 128, 184) for x in (96, 152, 208))

#: How many frames the staged sprites run before the one framed read -- past
#: the spawn transients, but early: measured on the shipped cart, nothing
#: gains from settling longer, and three types lose -- the Cheep Cheep's
#: surfacing splash is gone by ~40 frames, the cloud despawns by ~150, and
#: the smoke never re-draws once its first puffs dissipate.
OW_ART_SETTLE_FRAMES = 8

#: The screen corner the overworld dresses with its own flashing sprite-layer
#: furniture -- the border counter block and its neighbours -- which the
#: pre-stage baseline cannot catch because it animates. Entries inside it are
#: never a staged sprite's.
OW_ART_DRESSING_X = 60
OW_ART_DRESSING_Y = 52

#: The window the player's marker can occupy around his own position. It
#: animates too -- the walk frames cycle even at rest -- so it is excluded by
#: where he stands, re-read at the capture frame. The same window is what the
#: player's *own* capture keeps: everything the harvest throws away as "his"
#: is exactly his marker -- see :meth:`SmwLevelLoader._overworld_player`.
OW_ART_PLAYER_X = 24
OW_ART_PLAYER_UP = 32
OW_ART_PLAYER_DOWN = 24

#: The PPU's OAM is **one frame behind** the position words: the game draws
#: into its own buffer over the frame and the NMI hands that buffer to the PPU
#: at the start of the next one. So a read is attributed against where the
#: sprites stood when it was drawn rather than where they stand now -- without
#: which every sprite that moves picks up a pixel of jitter.
OW_ART_OAM_LAG = 1

#: How many frames the player capture reads before conceding his marker is
#: not on this map's screen. Each try is one frame; his walk cycle holds no
#: blank frame, so more than a few reads means he is genuinely off screen.
OW_PLAYER_ART_TRIES = 4

#: Where the player is parked for his own capture, as a screen spot -- the
#: middle of the console screen, clear of the top-left dressing corner. A
#: cleared save stands him wherever the tables left him, which is measured to
#: be close enough to that corner for its furniture to fall in his window, so
#: he is staged the way the harvest stages its sprites rather than read where
#: he happens to stand.
OW_PLAYER_ART_SPOT = (128, 112)

#: Where the parked rows start: the game keeps unused OAM entries at Y
#: ``$E0`` and ``$F0``, both below the 224-line picture, so anything from
#: here down is nothing on screen whatever its X holds.
OAM_PARK_Y = 0xE0


#: The replay probe's own, higher allowance. Its choreography hijacks the
#: machine between frames, and the title anchor sits close to the SPC music
#: upload, so a single attempt wedges more often than a plain load hangs --
#: while each attempt is cheap, honest about failing, and enters from a
#: slightly different machine (its settle is wall-clock), so more tries is
#: exactly what converges.
REPLAY_ATTEMPTS = 5


class OverworldCapture:
    """The loader's overworld capture.

    Mixed into :class:`~shiny_mushroom.emu.smw.SmwLevelLoader`, whose core,
    savestates and title anchor every method here drives.
    """

    def load_overworld(
        self, palettes: bool = True, patches: Mapping[int, bytes] | None = None
    ) -> OverworldSnapshot:
        """Run the game's overworld load and read the results out.

        The same philosophy as :meth:`load`: game mode ``$0C`` is the game's
        own overworld loader -- tilemaps, the translevel scan, graphics and
        palettes -- so driving it and reading RAM afterwards answers questions
        no static parse could, on any cartridge this session can boot.

        **No save file is selected first**, deliberately. The save tables are
        zeroed before the request, so no events replay and the captured Layer 1
        tilemap equals the cartridge's own table byte for byte -- which is the
        table the editor edits -- and the save-state slices carry the all-clear
        answer they are documented to.

        ``palettes`` pays six more short loads for the other submaps' CGRAM,
        one palette per submap. ``patches`` are previewed over the cartridge
        image for every load the capture makes, exactly as :meth:`load`
        previews them for a level -- withdrawn first, applied next, and left
        for the next request to withdraw -- which is how a project's edited
        graphics file reaches the map: the load decompresses the map's files
        out of the image as patched. The whole capture is cached for the
        session **under the set of patches it was made with**: the overworld
        is one place, and only the image it is read from changes.
        """
        key = patch_key(patches)
        held = self._overworld if key == self._overworld_patches else None
        if held is not None and (held.submap_cgram or not palettes):
            return held

        snapshot = self._capture_overworld(palettes, patches)
        self._overworld = snapshot
        self._overworld_patches = key
        return snapshot

    def _capture_overworld(
        self, palettes: bool, patches: Mapping[int, bytes] | None
    ) -> OverworldSnapshot:
        """The loads behind :meth:`load_overworld`, which answers from its
        cache first. Every one of them previews ``patches``."""
        started = time.monotonic()
        title = self.title_state
        self._overworld_attempt(title, 0, patches)
        where = self.addresses
        ram = RamView(self.core, where)
        rom = self.core.read_all(MemoryType.SNES_PRG_ROM)

        def table(address: int, size: int) -> bytes:
            base = where.offset(address)
            return rom[base : base + size]

        def rows(role: str, stride: int = 1, scanned: bool = False) -> bytes:
            """One of the cartridge's own tables, whole.

            Both halves from the base: the address its build put the table at,
            and how many entries it holds -- which a feature that grew it
            declares (:mod:`smw_tools.features`), or its build's symbol file
            measured. A capture that read the format's count off a cartridge
            holding more would hand the editor a table it then wrote back
            short. ``scanned`` reads the window the game's *scan* reads, which
            on a stock build runs past the destroyed-tiles table.
            """
            entries = where.counts[role]
            if scanned:
                entries += where.overreads.get(role, 0)
            return table(where.roles[role], entries * stride)

        snapshot = OverworldSnapshot(
            tiles=ram.slice(MAP16_LOW, TILEMAP_SIZE),
            map16_defs=table(where.overworld_map16_defs, TILE_COUNT * MAP16_DEF_SIZE),
            vram=self.core.read_all(MemoryType.SNES_VIDEO_RAM),
            cgram=self.core.read_all(MemoryType.SNES_CG_RAM),
            layer2=self._overworld_layer2(rom),
            back_area_color=ram.word(BACK_AREA_COLOR),
            translevels=ram.slice(OW_TRANSLEVELS, TILEMAP_SIZE),
            directions=ram.slice(OW_TRANSLEVELS + TILEMAP_SIZE, TILEMAP_SIZE),
            tile_settings=ram.slice(
                OW_LEVEL_TILE_SETTINGS, OW_LEVEL_TILE_SETTINGS_SIZE
            ),
            event_flags=ram.slice(OW_EVENT_FLAGS, OW_EVENT_FLAGS_SIZE),
            level_events=rows("overworld_level_events"),
            level_names=rows("overworld_level_names", 2),
            level_directions=rows("overworld_level_directions"),
            event_entries=table(
                where.overworld_event_tile_entries,
                OW_EVENT_ENTRY_COUNT * OW_EVENT_ENTRY_SIZE,
            ),
            event_pointers=rows("overworld_event_pointers", 2),
            event_l1_locations=rows("overworld_event_layer1_locations", 2),
            event_l1_from=rows("overworld_event_layer1_from"),
            event_l1_to=rows("overworld_event_layer1_to"),
            event_stamps=table(where.overworld_event_tiles, OW_SHEETS_SIZE),
            event_stamp_props=self._overworld_stamp_props(rom),
            # The window the scan reads: the table, and on a stock build the
            # eight entries past it -- so the port walks what the console walks.
            destroy_events=rows("overworld_destroy_events", 1, scanned=True),
            destroy_locations=rows("overworld_destroy_locations", 2, scanned=True),
            destroy_before=table(where.overworld_destroy_before, OW_DESTROY_TILES),
            destroy_top=table(where.overworld_destroy_top, OW_DESTROY_TILES),
            destroy_bottom=table(where.overworld_destroy_bottom, OW_DESTROY_TILES),
            silent_tiles=rows("overworld_silent_tiles", 6),
            sprite_slots=table(where.overworld_sprite_slots, OW_SPRITE_SLOTS_SIZE),
            sprite_submap_disable=table(
                where.overworld_sprite_submap_disable, OW_SPRITE_DISABLE_SIZE
            ),
            sprite_boo_x_offsets=table(
                where.overworld_sprite_boo_x_offsets, OW_SPRITE_BOO_OFFSETS_SIZE
            ),
            sprite_boo_y_offsets=table(
                where.overworld_sprite_boo_y_offsets, OW_SPRITE_BOO_OFFSETS_SIZE
            ),
            sprite_smoke_x_positions=table(
                where.overworld_sprite_smoke_x_positions,
                OW_SPRITE_SMOKE_POSITIONS_SIZE,
            ),
            sprite_smoke_y_positions=table(
                where.overworld_sprite_smoke_y_positions,
                OW_SPRITE_SMOKE_POSITIONS_SIZE,
            ),
            warp_trigger_columns=rows("overworld_warp_trigger_columns", 2),
            warp_trigger_rows=rows("overworld_warp_trigger_rows", 2),
            warp_landings_x=rows("overworld_warp_landings_x", 2),
            warp_landings_y=rows("overworld_warp_landings_y", 2),
            exit_triggers=rows("overworld_exit_triggers", 5),
            exit_landings=rows("overworld_exit_landings", 5),
            exit_landing_cells=rows("overworld_exit_landing_cells", 2),
        )
        # The player's marker, read off the map the load just stood up. Before
        # the harvest, which shares the wait for the running mode and then
        # steps on past the read frame.
        rows, player_vram, player_cgram = self._overworld_player()
        snapshot = replace(
            snapshot,
            player_art=rows,
            player_vram=player_vram,
            player_cgram=player_cgram,
        )
        if palettes:
            # The sprite artwork rides the palette loads: each submap is
            # visited anyway, and each visit frames the sprites its map shows.
            art: dict[int, tuple[SpriteTile, ...]] = {}
            self._harvest_overworld_sprites(0, art)
            cgrams = [snapshot.cgram]
            for submap in range(1, SUBMAP_COUNT):
                self._overworld_attempt(title, submap, patches)
                cgrams.append(self.core.read_all(MemoryType.SNES_CG_RAM))
                if not snapshot.player_art:
                    # A main map that framed the player off screen: the next
                    # submap gets its own chance to catch his marker.
                    rows, player_vram, player_cgram = self._overworld_player()
                    snapshot = replace(
                        snapshot,
                        player_art=rows,
                        player_vram=player_vram,
                        player_cgram=player_cgram,
                    )
                self._harvest_overworld_sprites(submap, art)
            snapshot = replace(
                snapshot,
                submap_cgram=tuple(cgrams),
                sprite_art=tuple(
                    (
                        number,
                        tuple((t.x, t.y, t.tile, t.attributes, t.large) for t in tiles),
                    )
                    for number, tiles in sorted(art.items())
                ),
            )

        snapshot = replace(snapshot, duration=time.monotonic() - started)
        _log.info(
            "the overworld loaded in %.0f ms: %d submap palette(s)",
            snapshot.duration * 1000,
            len(snapshot.submap_cgram) or 1,
        )
        return snapshot

    def _overworld_layer2(self, rom: bytes) -> bytes:
        """The Layer 2 tilemap, decoded out of the cartridge image.

        Not read from RAM, deliberately: the game only decompresses the two
        streams into ``$7F4000`` when a save file is loaded, and this capture
        never selects one -- mode ``$0C`` merely replays events over whatever
        the buffer holds, which after an attract demo is scratch. Decoding the
        image's own streams gives exactly what the game's decoder would leave
        with no events applied, and follows any preview patch of them.
        """
        from smw_tools.rle import Variant, decompress

        where = self.addresses
        half = OW_LAYER2_SIZE // 2

        def stream(address: int) -> bytes:
            base = where.offset(address)
            decoded, _ = decompress(
                rom[base : base + OW_LAYER2_SIZE], Variant.RLE2, size=half
            )
            return decoded

        buffer = bytearray(OW_LAYER2_SIZE)
        buffer[0::2] = stream(where.overworld_layer2_tiles)
        buffer[1::2] = stream(where.overworld_layer2_properties)
        return bytes(buffer)

    def _overworld_stamp_props(self, rom: bytes) -> bytes:
        """The event stamps' properties, decoded out of the cartridge image.

        LC_RLE1 rather than the Layer 2 pair's RLE2, decompressed to one byte
        per sheet byte -- the same read-from-the-image reasoning as
        :meth:`_overworld_layer2`: the game only builds the ``$7F0000``
        buffer once per Layer 2 load, and decoding the image's own stream
        follows any preview patch of it.
        """
        from smw_tools.rle import Variant, decompress

        base = self.addresses.offset(self.addresses.overworld_event_properties)
        # A double-size window: RLE1's worst case runs slightly *over* the
        # decoded size, so a literal-heavy preview-patched stream would
        # truncate out of a size-exact slice and fail its decode.
        decoded, _ = decompress(
            rom[base : base + 2 * OW_SHEETS_SIZE], Variant.RLE1, size=OW_SHEETS_SIZE
        )
        return decoded

    def _overworld_attempt(
        self, title: Path, submap: int, patches: Mapping[int, bytes] | None = None
    ) -> None:
        """One overworld load, retried the way a level load is.

        The failure mode is the same one :meth:`_attempting` documents -- a
        request written into a machine that never dispatches it -- and so is
        the recovery: back to the title state and try again.
        """

        def run(_attempt: int) -> None:
            self._request_overworld(title, submap, patches)
            # One frame of the game, for the same reason a level capture takes
            # one: the loader parks placeholders that the frame's own handlers
            # replace, and the palette upload rides the NMI. Inside the retry,
            # because a machine that cannot run a frame is a wedged load:
            # reading the tables it half-built would be a plausible wrong
            # answer, and the retry is the recovery.
            if not self._settle():
                raise LevelLoadError("the game could not run a frame after the load")

        retry_load(
            run,
            "the overworld",
            lambda _attempt: self.reanchor_title(),
            "retrying from a fresh title anchor",
        )
        self._game_runnable = True

    def _request_overworld(
        self, title: Path, submap: int, patches: Mapping[int, bytes] | None = None
    ) -> None:

        self.restore(title)
        self.preview(patches)
        if patches:
            # Mode $0C uploads the map's graphics through the same routine a
            # level's go through, slot cache included: a slot the title state
            # already holds one of the map's files in would keep the file the
            # savestate expanded rather than the one the image now carries.
            # Per request, because every submap's load restores the title
            # state and its cache with it.
            self._forget_graphics()
        where, write = self.addresses, self.core.write
        # The load replays whatever these tables claim happened, and the title
        # state's are whatever the attract demo left. All-clear is the capture
        # this method documents, so it is written rather than assumed.
        write(*where.at(INTRO_LEVEL_FLAG), 0)
        for offset in range(OW_EVENT_FLAGS_SIZE):
            write(*where.at(OW_EVENT_FLAGS + offset), 0)
        for offset in range(OW_LEVEL_TILE_SETTINGS_SIZE):
            write(*where.at(OW_LEVEL_TILE_SETTINGS + offset), 0)
        write(*where.at(MARIO_MAP), submap)
        write(*where.at(GAME_MODE), MODE_LOAD_OVERWORLD)

        with self.core.running_free():
            self._wait_for(
                _through(MODE_LOAD_OVERWORLD),
                self.load_timeout,
                "a loaded overworld",
                requested=True,
                floor=MODE_LOAD_OVERWORLD,
            )

    def _harvest_overworld_sprites(
        self, submap: int, art: dict[int, tuple[SpriteTile, ...]]
    ) -> None:
        """Capture the sprites this submap processes, in one framed pass.

        Every number not yet answered is parked on a screen spot of its own,
        the game draws a frame, and each number keeps whatever landed
        nearest its spot -- the game's own code drawing the game's own
        sprites, palette, shadow and height included, as they stand on their
        first running frame. A number that draws nothing that frame keeps
        its glyph, and gets another chance on the next submap that shows it.

        A number the cartridge's own slot table never spawned -- vanilla
        ships no Lakitu, bird, plant or cloud -- is staged by *retyping* a
        spare slot: its number written over an empty slot whose state tables
        are zeroed, which is the state a load-time spawn starts from. Every
        touched byte is put back afterwards.
        """
        candidates = self._overworld_candidates(submap, art)
        if not candidates or not self._overworld_running():
            return
        where, write = self.addresses, self.core.write
        saved = self._stage_overworld_slots(candidates)
        try:
            # Fast-forward to the settled frame first, in place: behaviours
            # advance wherever their sprites stand, and the staging at the
            # end moves them for only the two frames of the read.
            for _ in range(OW_ART_SETTLE_FRAMES):
                self._settle()
            art.update(self._framed_overworld_sprites(candidates))
        finally:
            for offset, value in saved:
                write(*where.at(offset), value)

    @staticmethod
    def _oam_entries(oam: bytes) -> list[tuple[int, int, int, int, bool]]:
        """Every on-screen OAM object, as ``(x, y, tile, attributes, large)``.
        Entries at the park rows the game keeps unused tiles on are left out."""
        found = []
        for obj in range(2 * OAM_OBJECTS):
            entry = _oam_object(oam, obj)
            if entry[1] < OAM_PARK_Y:
                found.append(entry)
        return found

    @staticmethod
    def _within_reach(x: int, y: int, of_x: int, of_y: int) -> bool:
        """Whether screen spot ``(x, y)`` is inside the window an overworld
        sprite at ``(of_x, of_y)`` can draw in."""
        return (
            -OW_ART_REACH_X <= _signed(x - of_x, 0x200) <= OW_ART_REACH_X
            and -OW_ART_REACH_UP <= _signed(y - of_y, 0x100) <= OW_ART_REACH_DOWN
        )

    def _framed_overworld_sprites(
        self, candidates: dict[int, int]
    ) -> dict[int, tuple[SpriteTile, ...]]:
        """One frame of the running overworld with ``candidates`` -- sprite
        number to live slot -- parked on their own spots, read back off the
        PPU's OAM.

        Two settles between the staging and the read -- the first frame
        draws the parked sprites into the game's buffer, the second puts
        that buffer on the PPU -- and then a second read four frames later,
        each number keeping its fuller answer: several sprites blink or draw
        in short windows, and two phases of a read catch what one misses.
        Three things on the screen are never a staged
        sprite's and are dropped: entries visible *before* the staging (the
        still parts of the screen's dressing), entries in the top-left
        corner the overworld furnishes with flashing counters the baseline
        cannot catch, and entries in the player's own window -- his marker
        cycles its walk frames even at rest. Everything else goes to the
        candidate whose spot is nearest, measured against positions re-read
        a frame before the OAM was, because sprites move themselves and the
        PPU's copy is a frame behind them (:data:`OW_ART_OAM_LAG`).
        """

        where, write = self.addresses, self.core.write
        ram = RamView(self.core, where)
        scroll_x = _signed(ram.word(OW_LAYER1_X), 0x10000)
        scroll_y = _signed(ram.word(OW_LAYER1_Y), 0x10000)

        baseline = frozenset(
            self._oam_entries(self.core.read_all(MemoryType.SNES_SPRITE_RAM))
        )
        saved = []
        for spot, slot in enumerate(candidates.values()):
            x_lo, x_hi = OW_LIVE_X_LO + slot, OW_LIVE_X_HI + slot
            y_lo, y_hi = x_lo + OW_LIVE_SPRITES, x_hi + OW_LIVE_SPRITES
            saved.extend((offset, ram[offset]) for offset in (x_lo, x_hi, y_lo, y_hi))
            staged_x = (scroll_x + OW_ART_SPOTS[spot][0]) & 0xFFFF
            staged_y = (scroll_y + OW_ART_SPOTS[spot][1]) & 0xFFFF
            write(*where.at(x_lo), staged_x & 0xFF)
            write(*where.at(x_hi), staged_x >> 8)
            write(*where.at(y_lo), staged_y & 0xFF)
            write(*where.at(y_hi), staged_y >> 8)
        try:
            found: dict[int, tuple[SpriteTile, ...]] = {}
            for step in (2, 4):
                for _ in range(step - OW_ART_OAM_LAG):
                    self._settle()
                # Read a frame before the OAM the read is attributed to, so
                # the positions are the ones the frame was drawn with.
                where_they_were = self._overworld_screen(candidates)
                for _ in range(OW_ART_OAM_LAG):
                    self._settle()
                entries = self._oam_entries(
                    self.core.read_all(MemoryType.SNES_SPRITE_RAM)
                )
                drawn = self._attributed_frame(entries, *where_they_were, baseline)
                for number, tiles in drawn.items():
                    if len(tiles) > len(found.get(number, ())):
                        found[number] = tiles
            return found
        finally:
            for offset, value in saved:
                write(*where.at(offset), value)

    def _overworld_screen(
        self, candidates: dict[int, int]
    ) -> tuple[dict[int, tuple[int, int]], tuple[int, int]]:
        """Where each candidate stands on the console screen right now, and
        where the player does -- both as the Layer 1 scroll makes them, which
        is the frame an OAM entry's own coordinates are in.

        Read as one slice of the position tables rather than four reads a
        slot, because a recording asks for this every frame.
        """

        view = RamView(self.core, self.addresses)
        now_x = _signed(view.word(OW_LAYER1_X), 0x10000)
        now_y = _signed(view.word(OW_LAYER1_Y), 0x10000)
        # X low, Y low, X high, Y high, one run of sixteen entries each.
        span = OW_LIVE_X_HI + 2 * OW_LIVE_SPRITES - OW_LIVE_X_LO
        table = view.slice(OW_LIVE_X_LO, span)
        high = OW_LIVE_X_HI - OW_LIVE_X_LO
        screen = {}
        for number, slot in candidates.items():
            x = table[slot] | (table[high + slot] << 8)
            y = table[OW_LIVE_SPRITES + slot] | (
                table[high + OW_LIVE_SPRITES + slot] << 8
            )
            screen[number] = (
                _signed(x, 0x10000) - now_x,
                _signed(y, 0x10000) - now_y,
            )
        player = (
            _signed(view.word(OW_PLAYER_X), 0x10000) - now_x,
            _signed(view.word(OW_PLAYER_Y), 0x10000) - now_y,
        )
        return screen, player

    def _attributed_frame(
        self,
        entries: Sequence[tuple[int, int, int, int, bool]],
        screen: dict[int, tuple[int, int]],
        player: tuple[int, int],
        baseline: frozenset[tuple[int, int, int, int, bool]],
    ) -> dict[int, tuple[SpriteTile, ...]]:
        """One frame of the PPU's OAM, attributed to the staged candidates.

        The read half of :meth:`_framed_overworld_sprites`, which owns the
        staging around it and the ``baseline`` it reads before staging.
        ``screen`` says where each candidate stood **when the frame was
        drawn**, which is a frame earlier than when it was read -- see
        :data:`OW_ART_OAM_LAG`.
        """
        player_x, player_y = player
        found: dict[int, list[SpriteTile]] = {number: [] for number in screen}
        for x, y, tile, attributes, large in entries:
            if (x, y, tile, attributes, large) in baseline:
                continue
            if x < OW_ART_DRESSING_X and y < OW_ART_DRESSING_Y:
                continue
            if (
                abs(_signed(x - player_x, 0x200)) <= OW_ART_PLAYER_X
                and -OW_ART_PLAYER_UP
                <= _signed(y - player_y, 0x100)
                <= OW_ART_PLAYER_DOWN
            ):
                continue
            near = [
                number
                for number, (sx, sy) in screen.items()
                if self._within_reach(x, y, sx, sy)
            ]
            if not near:
                continue
            number = min(
                near,
                key=lambda n: max(
                    abs(_signed(x - screen[n][0], 0x200)),
                    abs(_signed(y - screen[n][1], 0x100)),
                ),
            )
            sx, sy = screen[number]
            found[number].append(
                SpriteTile(
                    x=_signed(x - sx, 0x200),
                    y=_signed(y - sy, 0x100),
                    tile=tile,
                    attributes=attributes,
                    large=large,
                )
            )
        return {number: tuple(tiles) for number, tiles in found.items() if tiles}

    def _overworld_candidates(
        self, submap: int, answered: Mapping[int, object]
    ) -> dict[int, int]:
        """Which numbers this map can be asked for, and in which live slot.

        The slot table's own, then a spare slot retyped for every number the
        cartridge never spawned -- vanilla ships no Lakitu, bird, plant or
        cloud -- up to the number of staging spots there are. Numbers already
        in ``answered`` are skipped, which is what makes a later map cost
        nothing once the first ones have covered everything.
        """

        where = self.addresses
        ids = RamView(self.core, where).slice(OW_LIVE_SPRITE_ID, OW_LIVE_SPRITES)
        # The image's own disable table, so a base that edits it stages the
        # numbers its maps actually show.
        rom = self.core.read_all(MemoryType.SNES_PRG_ROM)
        offset = where.offset(where.overworld_sprite_submap_disable)
        disable = bytes(rom[offset : offset + OW_SPRITE_DISABLE_SIZE])

        def shown(number: int) -> bool:
            return number > len(disable) or not (disable[number - 1] & (0x80 >> submap))

        candidates: dict[int, int] = {}
        for slot in range(OW_LIVE_SPRITES):
            number = ids[slot]
            if not number or number in answered or number in candidates:
                continue
            if shown(number) and len(candidates) < len(OW_ART_SPOTS):
                candidates[number] = slot
        spare = [slot for slot in range(OW_LIVE_SPRITES) if not ids[slot]]
        for number in range(1, len(disable) + 1):
            if number in answered or number in candidates or not spare:
                continue
            if shown(number) and len(candidates) < len(OW_ART_SPOTS):
                candidates[number] = spare.pop(0)
        return candidates

    def _stage_overworld_slots(
        self, candidates: dict[int, int]
    ) -> list[tuple[int, int]]:
        """Retype every slot ``candidates`` asks for that does not already
        hold its number, and answer what the bytes were.

        A retyped slot gets its state tables zeroed, which is the state a
        load-time spawn starts from. The caller writes the answer back.
        """

        where, write = self.addresses, self.core.write
        view = RamView(self.core, where)
        saved: list[tuple[int, int]] = []
        for number, slot in candidates.items():
            if view[OW_LIVE_SPRITE_ID + slot] == number:
                continue
            offsets = [OW_LIVE_SPRITE_ID + slot]
            offsets += [table + slot for table in OW_LIVE_STATE]
            saved.extend((offset, view[offset]) for offset in offsets)
            write(*where.at(OW_LIVE_SPRITE_ID + slot), number)
            for table in OW_LIVE_STATE:
                write(*where.at(table + slot), 0)
        return saved

    def _overworld_running(self) -> bool:
        """Wind the load's fade forward until the overworld is running, which
        is the only mode that processes -- and so draws -- its sprites."""

        for _ in range(OW_ART_MODE_FRAMES):
            if RamView(self.core, self.addresses)[GAME_MODE] == MODE_OVERWORLD:
                return True
            self._wind_fade_forward()
            self._settle()
        return False

    def _overworld_player(
        self,
    ) -> tuple[tuple[tuple[int, int, int, int, bool], ...], bytes, bytes]:
        """The player's marker off the running map, with the memories that
        decode it -- the overworld's :meth:`capture_player_art`.

        Nothing is traced: every OAM entry inside the player's own window
        (the ones the sprite harvest throws away as his) *is* his marker, so
        the capture is reading them relative to his position words. He *is*
        staged, exactly as the harvest stages its sprites: a cleared save
        stands him wherever the tables left him, measured close enough to
        the screen's dressed top-left corner that its furniture fell inside
        his window, so his position words are parked mid-screen for the read
        and put back after. VRAM and CGRAM are read on the same frame because
        his walk frames are DMA'd per frame, exactly the level marker's
        reason. Empty when nothing was caught -- the caller may try again on
        the next submap load, and no marker is never worth failing the
        capture.
        """

        if not self._overworld_running():
            _log.debug("the player capture never saw the overworld running")
            return (), b"", b""
        where, write = self.addresses, self.core.write
        ram = RamView(self.core, where)
        staged_x = (
            _signed(ram.word(OW_LAYER1_X), 0x10000) + OW_PLAYER_ART_SPOT[0]
        ) & 0xFFFF
        staged_y = (
            _signed(ram.word(OW_LAYER1_Y), 0x10000) + OW_PLAYER_ART_SPOT[1]
        ) & 0xFFFF
        offsets = (OW_PLAYER_X, OW_PLAYER_X + 1, OW_PLAYER_Y, OW_PLAYER_Y + 1)
        saved = [(offset, ram[offset]) for offset in offsets]
        self._write_word(OW_PLAYER_X, staged_x)
        self._write_word(OW_PLAYER_Y, staged_y)
        try:
            for _ in range(OW_PLAYER_ART_TRIES):
                # Two frames, the harvest's reason: the first draws the moved
                # marker into the game's buffer, the second puts it on the PPU.
                self._settle()
                self._settle()
                # His position and the scroll re-read at the read frame, in
                # case the game moved either under the staging.
                view = RamView(self.core, where)
                player_x = _signed(view.word(OW_PLAYER_X), 0x10000) - _signed(
                    view.word(OW_LAYER1_X), 0x10000
                )
                player_y = _signed(view.word(OW_PLAYER_Y), 0x10000) - _signed(
                    view.word(OW_LAYER1_Y), 0x10000
                )
                rows = tuple(
                    (
                        _signed(x - player_x, 0x200),
                        _signed(y - player_y, 0x100),
                        tile,
                        attributes,
                        large,
                    )
                    for x, y, tile, attributes, large in self._oam_entries(
                        self.core.read_all(MemoryType.SNES_SPRITE_RAM)
                    )
                    # The dressed corner stays out even here: its counters
                    # flash, and a frame can put one inside any window.
                    if not (x < OW_ART_DRESSING_X and y < OW_ART_DRESSING_Y)
                    and abs(_signed(x - player_x, 0x200)) <= OW_ART_PLAYER_X
                    and -OW_ART_PLAYER_UP
                    <= _signed(y - player_y, 0x100)
                    <= OW_ART_PLAYER_DOWN
                )
                if rows:
                    return (
                        rows,
                        self.core.read_all(MemoryType.SNES_VIDEO_RAM),
                        self.core.read_all(MemoryType.SNES_CG_RAM),
                    )
        finally:
            for offset, value in saved:
                write(*where.at(offset), value)
        _log.debug("the player capture found no marker at his position")
        return (), b"", b""

    def probe_replayed_overworld(self) -> tuple[bytes, bytes]:
        """Run the game's own full event replay and read both tilemaps back.

        A testing probe, and the whole proof that the editor's replay port
        agrees with the cartridge: every event is flagged, the Layer 2
        builder -- decompression plus pass 2, which the game runs at file
        select -- is driven through its JSL-able wrapper, and then mode
        ``$0C`` replays pass 1 the way every overworld load does. What comes
        back is the state the player would stand on with everything beaten.
        """
        # The same retry every load in this file gets, with more attempts:
        # what goes wrong here is the title anchor sitting mid-music-upload,
        # where the hijacked NMI can walk into an SPC handshake nothing will
        # answer -- and the attempt's own settle sleep is wall-clock, so
        # every retry enters from a slightly different machine and the wedge
        # does not repeat deterministically. Each failure also nudges the
        # anchor a few frames (see :meth:`reanchor_title`), which is what
        # unsticks the rarer failure that does repeat.
        for attempt in range(REPLAY_ATTEMPTS):
            try:
                return self._replay_attempt()
            except (EmulatorUnavailable, LevelLoadError) as failure:
                if attempt == REPLAY_ATTEMPTS - 1:
                    raise
                self.reanchor_title()
                _log.warning(
                    "the replay probe failed on attempt %d of %d (%s); "
                    "retrying from a fresh title anchor",
                    attempt + 1,
                    REPLAY_ATTEMPTS,
                    failure,
                )
        raise AssertionError("unreachable")

    def _replay_attempt(self) -> tuple[bytes, bytes]:
        # ``frame=False``, the same entry the level rebuild uses, because a
        # frame step halts exactly on the frame boundary -- where the next
        # VBlank NMI is already latched, and a latched NMI beats a stub's
        # first instruction. This game runs its whole frame from the NMI
        # handler, and a frame run over this state wedges: the title state is
        # saved mid-music-upload, and the handler walks into an SPC handshake
        # the hijacked upload never answers. A mid-frame halt makes that a
        # rare escape instead of a certain one, and the retry above catches
        # the rest -- with the request staged under the mask, an escape
        # before the resume wedges into an error, and one in the resume's
        # own spin can only dispatch the mode $0C load early, whose pass-1
        # operations are idempotent over a built buffer.
        self.restore(self.title_state, frame=False)
        self.preview(None)
        where, write = self.addresses, self.core.write
        write(*where.at(INTRO_LEVEL_FLAG), 0)
        for offset in range(OW_EVENT_FLAGS_SIZE):
            write(*where.at(OW_EVENT_FLAGS + offset), 0xFF)
        write(*where.at(MARIO_MAP), 0)
        # The rebuild's own chain, with NMI left masked at its tail: from here
        # to :meth:`MesenCore.resume_interrupts` no frame of the game can run,
        # so nothing sees the staged request until it is complete. The mode
        # goes in under that mask, and the first frame after the resume
        # dispatches it -- pass 1 after pass 2, the order every real load
        # runs them in.
        self._call_chain([(where.overworld_layer2_loader, True)], resume=False)
        write(*where.at(GAME_MODE), MODE_LOAD_OVERWORLD)
        self.core.resume_interrupts(NMI_IN_LEVEL)

        def done(mode: int) -> bool:
            # The mode was staged before interrupts came back, so the load may
            # already be underway -- or over -- when this wait starts. Done is
            # a mode *above* $0C, not merely "not $0C": the staged request can
            # be lost to the title state's own in-flight frame, and the title
            # mode it leaves behind must fall through to the floor guard and
            # fail the attempt -- "not $0C" declared it success and read the
            # title's leftovers as the replay's answer.
            return mode > MODE_LOAD_OVERWORLD

        with self.core.running_free():
            self._wait_for(
                done,
                self.load_timeout,
                "a replayed overworld",
                requested=True,
                floor=MODE_LOAD_OVERWORLD,
            )
        # The probe's whole answer is the tables the load built, so a machine
        # that cannot run a frame afterwards -- the wedge the retry exists
        # for -- must fail rather than be read: its tables are half-built,
        # and half-built is a plausible wrong answer.
        if not self._settle():
            raise LevelLoadError("the game could not run a frame after the replay")
        self._game_runnable = True
        ram = RamView(self.core, where)
        return (
            ram.slice(MAP16_LOW, TILEMAP_SIZE),
            ram.slice(OW_LAYER2, OW_LAYER2_SIZE),
        )
