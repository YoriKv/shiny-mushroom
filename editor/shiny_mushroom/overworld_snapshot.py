"""What one overworld capture carries out of the emulator.

The overworld analogue of :class:`~shiny_mushroom.level_snapshot.LevelSnapshot`, and
under the same philosophy: the game's own loader resolves which graphics landed
in which VRAM slot, what each submap did to the palette, how the Layer 2
streams decompress and what the translevel scan handed out -- so the capture
reads the *results* out of RAM, and nothing downstream parses the cartridge.

The capture is taken with **no save file loaded and no events applied**, and
that is a feature twice over: the WRAM tilemap then equals the committed
``overworld/layer1/levels.bin`` byte for byte -- the exact table the editor
edits -- and the save-state tables carry the cleared-RAM answer, which the
properties panel labels as capture-time state rather than pretending it is the
player's.

The work-RAM offsets here are **vanilla** offsets from ``$7E0000``, like every
other constant in :mod:`shiny_mushroom.emu.smw`; a coprocessor base relocates
them, and :meth:`~shiny_mushroom.addresses.Addresses.at` is what turns one into
the memory it is actually in.

Outside :mod:`shiny_mushroom.emu` for :mod:`shiny_mushroom.level_snapshot`'s
reason: importing anything in that package loads the ctypes binding, and a
module that only wants to *read* a capture -- the world map, its renderer and
the ``ui`` side -- must not pay for a core to name the type.

The direction across the seam is one way. This module reaches
:mod:`shiny_mushroom.overworld` for the format facts the document defines;
the document names :class:`OverworldSnapshot` under ``TYPE_CHECKING`` only,
which is what keeps that from being a circle.
"""

from __future__ import annotations

from dataclasses import dataclass

from shiny_mushroom.addresses import MAP16_DEF_SIZE
from shiny_mushroom.overworld import TILEMAP_SIZE
from shiny_mushroom.sprite_art import PlayerArt, SpriteTile

#: The game modes an overworld load passes through: ``$0C`` runs the whole
#: load -- tilemaps, translevel scan, events, graphics, palettes -- and hands
#: over to the fades and then ``$0E``, the overworld running.
MODE_LOAD_OVERWORLD = 0x0C
MODE_OVERWORLD = 0x0E

#: The player-select menu's mode -- the one a test run requests. Its handler
#: does everything a boot needs done in one place, in-band: copies the save
#: buffer to the live tables, builds the Layer 2 buffer with pass-2 event
#: stamps, seeds the loadout, and enters the real ``$0B``-``$0E`` fade chain.
#: All it asks for is a confirm press on the controller.
MODE_PLAYER_SELECT = 0x0A

#: The translevel of every tilemap position, as the game's scan left it --
#: what the editor's own :func:`~shiny_mushroom.overworld.scan_translevels`
#: must agree with. One byte per cell, directly after the Layer 1 tilemap.
OW_TRANSLEVELS = 0x00D000

#: The post-clear walk direction of every tilemap position, built during the
#: scan by spreading the per-translevel ROM table over the map.
OW_DIRECTIONS = 0x00D800

#: Where the game keeps the Layer 2 tilemap (``$7F4000``): raw 8x8 SNES
#: tilemap entries, not Map16. Four ``$800``-byte pages per map in the
#: console's 64x64 arrangement -- top-left, top-right, bottom-left,
#: bottom-right -- main map first, the shared submap area at ``+$2000``.
#: The capture does not read it there: the game only decompresses it when a
#: save file is loaded, so the capture decodes the image's own streams into
#: the same arrangement.
OW_LAYER2 = 0x014000
OW_LAYER2_SIZE = 0x4000

#: Per-translevel save state: ``bmesudlr`` -- beaten, midway, two unused bits,
#: and which directions are walkable. 96 bytes; the two Special World global
#: flags live inside it at ``+$48``/``+$49``.
OW_LEVEL_TILE_SETTINGS = 0x001EA2
OW_LEVEL_TILE_SETTINGS_SIZE = 0x60

#: Which of the ``$6F`` events have fired, bit-packed.
OW_EVENT_FLAGS = 0x001F02
OW_EVENT_FLAGS_SIZE = 0x0E

# The per-translevel ROM tables the properties panel reads -- which event a
# level's clear fires (``$FF`` none; a secret exit fires the next one up), the
# ``nn112233`` walk the player takes afterwards, and the level-names pointer
# table, one word per translevel the name box can show (read off the image
# whatever the target; only the international word format is editable, see
# ``overworld.level_names`` in asm_regions) -- are read at **this cartridge's**
# entry counts rather than at a size named here. So are the event, silent and
# transfer tables below. `SmwLevelLoader.load_overworld`'s ``rows`` is the one
# place that asks, and `Addresses.counts` is what it asks.

#: How many submaps share the lower page -- and how many palettes a full
#: capture carries, one per submap.
SUBMAP_COUNT = 7

#: The event system's shapes, as the capture reads them out of the image.
#: Pass 2's entry table: $173 entries of (dw sheet offset, dw destination
#: byte offset into the Layer 2 buffer); a sheet offset below $900 walks a
#: 6x6 block, above it a 2x2 at offset-$900.
OW_EVENT_ENTRY_COUNT = 0x173
OW_EVENT_ENTRY_SIZE = 4
#: The pointer table holds entry INDICES, not byte offsets: event n's slice is
#: Ptrs[n]..Ptrs[n+1], so the last addressable event has no slice of its own.
#: Pass 1's tables are one Layer 1 tilemap index per event and the before/after
#: substitution pair; zero is a real index, not "none" -- the game scans
#: whatever cell the entry names, and a zero-location event is inert on the
#: shipped map only because cell 0 matches no from-tile.
#: The concatenated stamp sheets -- $900 of 6x6 blocks, $400 of 2x2 -- and
#: the properties stream's decoded size: one byte per sheet byte.
OW_SHEETS_SIZE = 0xD00
OW_SHEET_6X6_SIZE = 0x900
#: How many events the load replays: $00-$6E.
OW_REPLAYED_EVENTS = 0x6F

#: The destroy-tile pass's ruin kinds: before/top/bottom triples. How many
#: slots its scan walks is the cartridge's to say -- the table's count, plus
#: what the stock scan reads past it (:attr:`Addresses.overreads`).
OW_DESTROY_TILES = 5

#: The silent-tile block is four parallel arrays -- event number (db), layer
#: flag (db), tilemap location (dw), tile number (dw) -- read whole and split
#: by those strides; six bytes a slot.

#: The sprite slot table: 13 slots of 5 bytes.
OW_SPRITE_SLOTS_SIZE = 65

#: The star/pipe warp tables are four parallel word tables -- trigger grid
#: column with the submap in the high byte, trigger grid row, landing pixel X
#: with the submap in bits 9-12, landing pixel Y -- and the path-exit tables
#: are trigger and landing as five-byte (pixel Y word, pixel X word, submap
#: byte) records plus the landing's (grid row, grid column) byte pair.

# -- the live overworld sprites, for the artwork capture ----------------------

#: The running overworld's sprite state: sixteen live slots -- the thirteen
#: table slots plus room the cloud spawner uses. The number per slot, then
#: the position tables, split low/high with X, Y and Z (height) each sixteen
#: entries apart.
OW_LIVE_SPRITES = 16
OW_LIVE_SPRITE_ID = 0x000DE5
OW_LIVE_X_LO = 0x000E35
OW_LIVE_X_HI = 0x000E65

#: The Layer 1 scroll mirrors ($210D/$210E), as signed words: what turns a
#: sprite's map position into its screen position.
OW_LAYER1_X = 0x00001A
OW_LAYER1_Y = 0x00001C

#: The per-slot state tables behind a live sprite -- the four miscellaneous
#: tables, then Z position, speeds and speed fractions, low and high halves
#: as the position tables split them. A number staged into a spare slot gets
#: these zeroed, which is the state a load-time spawn starts from.
OW_LIVE_STATE = (
    0x000DF5,
    0x000E05,
    0x000E15,
    0x000E25,
    0x000E55,
    0x000E85,
    0x000E95,
    0x000EA5,
    0x000EB5,
    0x000EC5,
    0x000ED5,
    0x000EE5,
)

#: The player's own map-pixel position words, live -- where his marker is
#: drawn, and so the spot a staged sprite must keep clear of.
OW_PLAYER_X = 0x001F17
OW_PLAYER_Y = 0x001F19

#: The disable-bits table's length: one byte per sprite number ``$01-$0A``.
#: The bytes themselves are read out of the image (the capture's
#: ``sprite_submap_disable``), so a base that edits the table is believed.
OW_SPRITE_DISABLE_SIZE = 10

#: One ghost-offset table's length: three signed words, one per slot the
#: game will draw a submap Boo for. Read out of the image for the same
#: reason the disable bits are -- the offsets decide where a marker lands,
#: and a base that moves a ghost is believed rather than assumed vanilla.
OW_SPRITE_BOO_OFFSET_COUNT = 3
OW_SPRITE_BOO_OFFSETS_SIZE = OW_SPRITE_BOO_OFFSET_COUNT * 2

#: One smoke-position table's length: a word per map the smoke draws on, and
#: vanilla's two are the main map and Yoshi's Island. Read out of the image
#: like the two tables above, and for a sharper reason -- the smoke's routine
#: overwrites its slot's position with these every frame, so they are the
#: only thing that says where a Smoke marker belongs.
OW_SPRITE_SMOKE_MAP_COUNT = 2
OW_SPRITE_SMOKE_POSITIONS_SIZE = OW_SPRITE_SMOKE_MAP_COUNT * 2

# -- a test run's save state -------------------------------------------------

#: The save buffer at ``$7E1F49``: a byte-for-byte image of ``$1EA2-$1F2E``
#: that the save file is written from and the player-select handler copies
#: back over the live tables. A test run stages a fabricated one here.
OW_SAVE_BUFFER = 0x001F49
OW_SAVE_BUFFER_SIZE = 0x8D

#: Offsets within that image. Tile settings and event flags open it (one
#: padding byte after the flags is saved too); then per-player state, Mario's
#: and Luigi's interleaved: which submap each is on, the walk-animation words
#: (a new game seeds ``$0002``), the pixel X/Y position words in the shared
#: 512x512 map space, and the same positions divided by 16.
BUF_TILE_SETTINGS = 0x00
BUF_EVENT_FLAGS = 0x60
BUF_MARIO_MAP = 0x6F
BUF_LUIGI_MAP = 0x70
BUF_MARIO_ANIMATION = 0x71
BUF_LUIGI_ANIMATION = 0x73
BUF_MARIO_X = 0x75
BUF_LUIGI_X = 0x79
BUF_MARIO_GRID_X = 0x7D
BUF_LUIGI_GRID_X = 0x81

#: The player's live position, as the loaded tables hold it: grid-aligned
#: (pixel over 16) X and Y words. What decides which node "beat this level"
#: means.
OW_MARIO_GRID_X = 0x001F1F
OW_MARIO_GRID_Y = 0x001F21

#: The two menu decisions the player-select screen makes -- put back to
#: one-player Mario after a staged run, whatever the title screen left the
#: menu cursor holding.
TWO_PLAYER_GAME = 0x000DB2
CURRENT_CHARACTER = 0x000DB3

#: The six bytes that fake a level exit on a running overworld. Process
#: ``$00`` then derives the level from the tile the player stands on, sets
#: its beaten bit, runs the event ``$1DEA`` names (incremented itself for a
#: secret exit) and unlocks the walk the exit reveals.
OW_EXIT_LEVEL_ACTION = 0x000DD5  # $01 a normal exit, $02 the secret one
OW_ACTIVATE_EVENT = 0x0013CE  # doubles as the in-level midpoint flag
OW_EVENT_PASSED = 0x001DE9
OW_CURRENT_EVENT = 0x001DEA
OW_PROCESS = 0x0013D9
OW_EVENT_PROCESS = 0x001B86

#: Which event a level's clear fires when its table says "none".
OW_NO_EVENT = 0xFF


def save_buffer(
    tile_settings: bytes,
    event_flags: bytes,
    submap: int,
    x: int,
    y: int,
) -> bytes:
    """A fabricated save-buffer image: both players on ``submap``, standing
    at map pixel ``(x, y)``, with the given save tables. The animation words
    carry the new-game seed; everything else unset is zero, as a fresh file's
    is."""
    buffer = bytearray(OW_SAVE_BUFFER_SIZE)
    buffer[BUF_TILE_SETTINGS : BUF_TILE_SETTINGS + len(tile_settings)] = tile_settings
    buffer[BUF_EVENT_FLAGS : BUF_EVENT_FLAGS + len(event_flags)] = event_flags
    buffer[BUF_MARIO_MAP] = submap
    buffer[BUF_LUIGI_MAP] = submap
    for base in (BUF_MARIO_ANIMATION, BUF_LUIGI_ANIMATION):
        buffer[base] = 0x02
    for base in (BUF_MARIO_X, BUF_LUIGI_X):
        buffer[base] = x & 0xFF
        buffer[base + 1] = (x >> 8) & 0xFF
        buffer[base + 2] = y & 0xFF
        buffer[base + 3] = (y >> 8) & 0xFF
    for base in (BUF_MARIO_GRID_X, BUF_LUIGI_GRID_X):
        buffer[base] = (x >> 4) & 0xFF
        buffer[base + 1] = (x >> 12) & 0xFF
        buffer[base + 2] = (y >> 4) & 0xFF
        buffer[base + 3] = (y >> 12) & 0xFF
    return bytes(buffer)


def standing_index(grid_x: int, grid_y: int, submap: int) -> int:
    """The tilemap index under a player at grid position ``(grid_x, grid_y)``.

    The game's own packing -- low nibbles interleaved, bit 8 the right half,
    bit 9 the bottom half of a page, bit 10 the page -- and the same
    arithmetic as :func:`shiny_mushroom.overworld.cell_index`, which a test
    pins. Written out rather than delegated because the three arguments come
    straight off live work RAM: a byte the running game left out of range is
    masked here, where ``cell_index`` refuses a position no cell has.
    """
    return (
        (grid_x & 0x0F)
        | ((grid_x & 0x10) << 4)
        | ((grid_y & 0x0F) << 4)
        | (0x200 if grid_y & 0x10 else 0)
        | (0x400 if submap else 0)
    )


@dataclass(frozen=True)
class OverworldSnapshot:
    """Everything needed to draw and describe the overworld, and nothing else.

    The same seam as :class:`~shiny_mushroom.level_snapshot.LevelSnapshot`: whatever
    produces one -- the real core today, anything else later -- the renderer's
    input is the same type, and a synthetic one small enough to build by hand
    in a test draws through the same code as a captured one.
    """

    #: The Layer 1 tilemap: ``$800`` Map16 numbers, one per cell, equal to the
    #: committed ``levels.bin`` because no events were applied at capture.
    tiles: bytes

    #: The overworld's Map16 definition table, 8 bytes per tile, read at the
    #: label the game's own display path dereferences
    #: (``overworld_map16_definitions`` in :mod:`smw_tools.rom_tables`).
    #: :data:`~shiny_mushroom.overworld.TILE_COUNT` tiles long; a number past
    #: the end is answered with zeros by :meth:`definition`.
    map16_defs: bytes

    vram: bytes
    cgram: bytes

    #: The Layer 2 tilemap with no events applied, in the arrangement
    #: :data:`OW_LAYER2` documents -- decoded from the image's own streams.
    layer2: bytes

    #: The PPU fixed colour, 15-bit BGR: what a transparent pixel shows.
    back_area_color: int

    #: The game's own scan results and save-state tables, carried for
    #: cross-checks and the properties panel. The first two are *capture-time*
    #: answers -- an edit renumbers translevels, so the editor recomputes them
    #: and these only prove the port agrees with the game.
    translevels: bytes = b""
    directions: bytes = b""
    tile_settings: bytes = b""
    event_flags: bytes = b""

    #: The two per-translevel ROM tables, read straight off the cartridge
    #: image -- fixed data, safe to index by a *recomputed* translevel.
    level_events: bytes = b""
    level_directions: bytes = b""

    #: The level-names pointer table, one word per translevel -- the
    #: cartridge's bytes at its own target's address; the *word format* is
    #: version-forked, which the editor accounts for by target.
    level_names: bytes = b""

    #: The event system, read off the image for the editor's own replay.
    #: The entry/pointer pair and the pass-1 tables are display data --
    #: which cells each event touches is not editable; the sheets and their
    #: properties are the ROM's baselines of the *editable* stamp contents,
    #: the properties RLE1-decoded to one byte per sheet byte.
    event_entries: bytes = b""
    event_pointers: bytes = b""
    event_l1_locations: bytes = b""
    event_l1_from: bytes = b""
    event_l1_to: bytes = b""
    event_stamps: bytes = b""
    event_stamp_props: bytes = b""

    #: The destroy-tile pass's tables (windows sized to what the game's own
    #: glitchy scans read) and the silent-tile block, whole.
    destroy_events: bytes = b""
    destroy_locations: bytes = b""
    destroy_before: bytes = b""
    destroy_top: bytes = b""
    destroy_bottom: bytes = b""
    silent_tiles: bytes = b""

    #: The sprite slot table: 13 slots of (number, X lo/hi, Y lo/hi), read
    #: from ROM -- the game reads it once, at title load.
    sprite_slots: bytes = b""

    #: The star/pipe warp tables, four parallel word runs of
    #: as many entries as this cartridge holds, and the path-exit tables -- two
    #: runs of five-byte position records and the landing grid pairs, at
    #: of its own entries. Read off the cartridge image, so a
    #: base or a preview patch that moves a warp is believed;
    #: :mod:`shiny_mushroom.overworld` decodes and edits them.
    warp_trigger_columns: bytes = b""
    warp_trigger_rows: bytes = b""
    warp_landings_x: bytes = b""
    warp_landings_y: bytes = b""
    exit_triggers: bytes = b""
    exit_landings: bytes = b""
    exit_landing_cells: bytes = b""

    #: Which maps show each sprite number: the disable-bits table, one byte
    #: per number, a set bit disabling. A fact about the number, not the
    #: slot -- and the cartridge's own answer, not vanilla's.
    sprite_submap_disable: bytes = b""

    #: Where a submap draws its copy of a ghost, relative to that ghost's
    #: main-map position: the two offset tables, three signed words each, for
    #: the last three sprite slots. The cartridge's own answer, like the
    #: disable bits above.
    sprite_boo_x_offsets: bytes = b""
    sprite_boo_y_offsets: bytes = b""

    #: Where the smoke draws on each map: the two per-map position tables, a
    #: word each per map. Not an offset like the ghost's -- the smoke's
    #: routine writes these over its slot's position every frame, so they are
    #: absolute, and the slot's own position is never drawn.
    sprite_smoke_x_positions: bytes = b""
    sprite_smoke_y_positions: bytes = b""

    #: One CGRAM per submap, in submap order, because each submap loads its
    #: own palette. :attr:`cgram` is submap 0's. Empty when the capture was
    #: asked not to pay for the extra loads.
    submap_cgram: tuple[bytes, ...] = ()

    #: What each sprite number the map holds looks like, captured by framing
    #: the running game's own sprites one at a time: ``(number, rows)`` pairs,
    #: each row an OAM object as ``(x, y, tile, attributes, large)`` relative
    #: to the sprite's own position. Raw rows rather than
    #: :class:`~shiny_mushroom.sprite_art.SpriteTile`, which is the shape the
    #: worker's frame carries them in and hands back unchanged --
    #: :meth:`sprite_tiles` decodes them. Captured with the palettes, and
    #: empty without them.
    sprite_art: tuple[tuple[int, tuple[tuple[int, int, int, int, bool], ...]], ...] = ()

    #: What the player's own marker looks like, read off the running map's OAM
    #: in :attr:`sprite_art`'s raw-row shape, relative to his position words.
    #: His VRAM and CGRAM travel with the rows for the level capture's reason
    #: (see :class:`~shiny_mushroom.sprite_art.PlayerArt`): the walk frames are
    #: DMA'd per frame, so only the memories of the read frame decode them.
    #: :meth:`player` assembles the three. Empty when nothing was caught.
    player_art: tuple[tuple[int, int, int, int, bool], ...] = ()
    player_vram: bytes = b""
    player_cgram: bytes = b""

    #: Wall-clock seconds the capture took.
    duration: float = 0.0

    def tile_at(self, index: int) -> int:
        """The Map16 number in this cell, as captured."""
        if not 0 <= index < TILEMAP_SIZE:
            raise ValueError(f"no cell with index {index:#x}")
        return self.tiles[index]

    def sprite_tiles(self):  # noqa: ANN201
        """:attr:`sprite_art` decoded, as sprite number to
        :class:`~shiny_mushroom.sprite_art.SpriteTile` rows -- the shape
        every sprite renderer takes."""
        return {
            number: tuple(SpriteTile(*row) for row in rows)
            for number, rows in self.sprite_art
        }

    def player(self):  # noqa: ANN201
        """The player's marker as a
        :class:`~shiny_mushroom.sprite_art.PlayerArt` -- the shape the
        level's marker already draws through, falsy when the capture caught
        nothing."""
        return PlayerArt(
            tiles=tuple(SpriteTile(*row) for row in self.player_art),
            vram=self.player_vram,
            cgram=self.player_cgram,
        )

    def definition(self, tile: int) -> bytes:
        """The eight bytes defining Map16 tile ``tile``.

        Zero-padded past the end of the table rather than raising: a hacked
        tilemap can name a tile past the 193 defined ones, and a blank block
        beats an exception out of the middle of a draw. Zeros point every
        quarter at VRAM tile 0 -- whatever that holds is what the console
        would show for an undefined tile too.
        """
        start = tile * MAP16_DEF_SIZE
        return self.map16_defs[start : start + MAP16_DEF_SIZE].ljust(
            MAP16_DEF_SIZE, b"\x00"
        )
