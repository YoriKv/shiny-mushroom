"""Everything needed to draw a level, as bytes, with no machine attached.

This is the seam the renderer sits behind. A snapshot is plain frozen data --
tilemaps, definitions, VRAM, CGRAM, the streams the level was built from -- and
is meant to outlive whatever produced it: a real core today
(:class:`~shiny_mushroom.emu.smw.SmwLevelLoader`), a static parser later, and
the two diffable against each other because they are the same type.

Outside :mod:`shiny_mushroom.emu` deliberately. Importing anything in that
package loads the ctypes binding, and the editor's rule is that native code
loads only in the emulator worker's process; a module that only wants to *read*
a snapshot -- :mod:`shiny_mushroom.level`, :mod:`shiny_mushroom.preview` and
the ``ui`` side -- must not pay for a core to name the type. The overworld's
answer to this file is
:class:`~shiny_mushroom.overworld_snapshot.OverworldSnapshot`.

Nothing here imports Qt: turning a snapshot into a picture is the ``ui`` side's
job.
"""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass, field

from shiny_mushroom.addresses import (
    LAYER2_REGION_HORIZONTAL,
    LAYER2_REGION_VERTICAL,
    LAYOUT_LAYER1_VERTICAL,
    MAP16_DEF_SIZE,
    MAP16_TILE_COUNT,
)
from shiny_mushroom.header import field_value
from shiny_mushroom.rom_patches import (
    LAYER2_PALETTE_BIT,
    LAYER2_PALETTE_TILESET,
    PlayerPosition,
)
from shiny_mushroom.sprite_art import SpriteTile
from smw_tools.custom_tiles import END_TILE as END_CUSTOM_TILE
from smw_tools.custom_tiles import FIRST_TILE as FIRST_CUSTOM_TILE


def _definition(table: bytes, tile: int) -> bytes:
    """One Map16 tile's eight bytes, out of ``table``.

    Zero-padded past the end of the table rather than raising or coming back
    short: a hacked tilemap can name a tile the tileset does not define, and a
    blank block beats an exception -- or four bytes a caller unpacks as two
    entries -- out of the middle of a draw. Zeros point every quarter at VRAM
    tile 0, which is what the console would show for an undefined tile too.
    The same rule
    :meth:`~shiny_mushroom.overworld_snapshot.OverworldSnapshot.definition`
    follows, because the tilemaps are read the same way.
    """
    start = tile * MAP16_DEF_SIZE
    return table[start : start + MAP16_DEF_SIZE].ljust(MAP16_DEF_SIZE, b"\x00")


def _custom_definition(table: bytes, tile: int) -> bytes:
    """A custom tile's eight bytes out of the cartridge's table, or the zero
    definition for one past the pages it holds -- what the cartridge itself
    draws there (``SMW_CustomTiles_Undefined``)."""
    if not FIRST_CUSTOM_TILE <= tile < END_CUSTOM_TILE:
        return bytes(MAP16_DEF_SIZE)
    return _definition(table, tile - FIRST_CUSTOM_TILE)


@dataclass(frozen=True)
class LevelSnapshot:
    """Everything needed to draw a level, and nothing about how to draw it.

    This is the seam. Whatever produces one of these -- a real core today, a
    static parser later -- the renderer's input is the same, and the two can be
    diffed against each other because they are the same type.

    The Map16 tilemap is the level's tile *layout*; the Map16 definitions say
    which four 8x8 tiles each of its entries stands for; VRAM and CGRAM are the
    graphics and colours the game decompressed and uploaded for it. Together
    they are enough to draw the level and nothing has to be parsed out of the
    cartridge to do it. Deliberately not included: a screenshot. The PPU draws a
    256x224 window, which is a fraction of a level and the wrong shape for an
    editor.
    """

    level: int
    header: bytes
    map16_low: bytes
    map16_high: bytes

    #: 512 x 8 bytes, indexed by Map16 tile number -- the definitions the game's
    #: own pointer table resolved to, flattened. Flattened rather than left as
    #: pointers because the pointers are only meaningful next to the cartridge
    #: they index, and this type is meant to outlive the core that produced it.
    map16_defs: bytes

    vram: bytes
    cgram: bytes

    #: The level's sprite stream verbatim -- a one-byte header, three-byte
    #: records, terminator. Carried raw because reading it needs no emulator and
    #: no cartridge: see :mod:`shiny_mushroom.sprites`.
    sprites: bytes

    #: The level's Layer 1 object stream verbatim, from the first record to the
    #: terminator -- the five header bytes are :attr:`header` and are not
    #: repeated here. This is the level's *source*: the tilemap above is what
    #: the loader made of it, and carries no record of which object wrote which
    #: block. Read by :mod:`shiny_mushroom.objects`.
    objects: bytes

    #: ``$7E005B`` as the loader left it. Bit 0 selects the level's geometry.
    screen_mode: int

    #: The PPU fixed colour, 15-bit BGR. The backdrop a transparent pixel shows.
    back_area_color: int

    #: The four pipe tables, each :data:`~shiny_mushroom.addresses.PIPE_TILES`
    #: definitions long and in the order ``PipeMap16Ptrs`` holds them. Carried
    #: beside :attr:`map16_defs` rather than folded into it because the pipe
    #: tiles are the one case where a level does not have *a* definition: which
    #: of these four a pipe block is drawn from is decided by its column, every
    #: time the level is drawn -- see
    #: :data:`~shiny_mushroom.addresses.PIPE_TILES`.
    #:
    #: Empty on a snapshot made before this was captured, and on the overworld,
    #: which is what makes the renderer fall back to :attr:`map16_defs`.
    pipe_definitions: tuple[bytes, ...] = ()

    #: The custom tiles' definitions -- eight bytes a tile from
    #: :data:`~shiny_mushroom.custom_tiles.FIRST_TILE` -- read off the
    #: cartridge where it carries the feature, and empty otherwise. A tile
    #: number past the stock two pages resolves here; past what this holds
    #: it is the zero definition the console shows for one too.
    custom_defs: bytes = b""

    #: Where the player starts, as the game itself worked it out during this
    #: load -- see :data:`~shiny_mushroom.addresses.PLAYER_X`. The editor draws
    #: him there, and a test run begins there unless the run overrides it. A
    #: :class:`~shiny_mushroom.rom_patches.PlayerPosition`, so
    #: it cannot be read as the floor he stands on; ``spawn.feet`` is that.
    spawn: PlayerPosition = PlayerPosition(0, 0)

    #: What each sprite number in this level draws, keyed by number, captured by
    #: making the game draw it. Empty for a number that draws nothing -- which
    #: is a real answer for a trigger like WarpHole, and *not* an answer for a
    #: sprite that was only missing its context, so a reader must treat it as
    #: "nothing was found" rather than "there is nothing to find".
    #:
    #: One capture per level rather than a cache keyed by sprite number: the
    #: same number looks different under a different sprite tileset, and the
    #: tileset belongs to the level.
    sprite_art: Mapping[int, tuple[SpriteTile, ...]] = field(default_factory=dict)

    #: How many extra bytes each custom number's records carry -- the built
    #: cartridge's own count table, read at load so every reader of this
    #: snapshot's sprite stream walks it with the stride the cartridge does.
    #: Empty on a build without the feature.
    extra_counts: Mapping[int, int] = field(default_factory=dict)

    #: Which blocks each object drew, as Map16 tilemap offsets, indexed the same
    #: way :attr:`objects` parses -- entry *n* belongs to the *n*th record.
    #:
    #: Empty unless the load was asked for them
    #: (:meth:`~shiny_mushroom.emu.smw.SmwLevelLoader.load`), because
    #: collecting them costs about half a load again. Empty is a usable
    #: answer everywhere: without it an object is known only by the block its
    #: record names, which is where the editor started.
    #:
    #: The record's own size field covers just the ``$01``-``$0E`` family; this
    #: covers all of them, because it is what the game's own routines did rather
    #: than what the format admits to. See
    #: :mod:`shiny_mushroom.emu.footprints`.
    footprints: tuple[frozenset[int], ...] = ()

    #: The Layer 2 background's tilemap as the loader decompressed it: two 16x27
    #: screens of Map16 numbers, low bytes and high, which repeat across and
    #: down the level. Empty when the level's Layer 2 is a *level* -- then Layer
    #: 2 is in :attr:`map16_low` with Layer 1, above
    #: :data:`LAYER2_REGION_HORIZONTAL`.
    layer2_low: bytes = b""
    layer2_high: bytes = b""

    #: The definitions a background's tile numbers index, from the cartridge's
    #: fixed background table. Separate from :attr:`map16_defs` because they are
    #: a different 512 tiles, not a different view of the same ones.
    layer2_defs: bytes = b""

    #: Whether this level's Layer 2 is a background rather than an object
    #: stream. From the cartridge's Layer 2 pointer table, not from RAM: the
    #: loader overwrites the pointer's bank byte with the background bank as it
    #: goes, so the ``$FF`` that marked it is gone by the time a capture runs.
    layer2_background: bool = False

    #: The Layer 2 object stream, when the level has one -- the records alone,
    #: cut out of the image exactly as :attr:`objects` is and readable by the
    #: same parser, because a Layer 2 level is a second pass of the same loop.
    #: Empty for a level whose Layer 2 is a background.
    layer2_objects: bytes = b""

    #: The five bytes in front of that stream: the Layer 2 region's own copy of
    #: a level header, which the loader steps over without reading. Carried so
    #: an edit can put the region back byte for byte.
    layer2_header: bytes = b""

    #: ``$7E1BE3`` as the loader left it -- whether the level asked for a Layer
    #: 3, and which kind. Zero for most levels.
    layer3_setting: int = 0

    #: Where the loader left Layer 3's scroll -- a *screen* offset into the
    #: 64x64 tilemap, not a level one. Lining it up against the level needs
    #: :attr:`camera_y` as well; see :func:`shiny_mushroom.level.layer3_origin`.
    layer3_x: int = 0
    layer3_y: int = 0

    #: ``$7E001A`` / ``$7E001C``, the Layer 1 scroll the loader left: where the
    #: camera is looking at the moment this capture was taken. It is what turns
    #: a screen offset into a level one, and every layer whose scroll is
    #: expressed against the screen needs it.
    camera_x: int = 0
    camera_y: int = 0

    #: Wall-clock seconds the load took, for the status bar and for regression
    #: tests that would otherwise not notice a tenfold slowdown.
    duration: float = 0.0

    def tile(self, index: int) -> int:
        """The 16-bit Map16 tile number at ``index``."""
        return self.map16_low[index] | (self.map16_high[index] << 8)

    def layer2_tile(self, index: int) -> int:
        """The 16-bit Map16 tile number Layer 2 holds at ``index``.

        Indexed into whichever buffer this level's Layer 2 lives in, so a caller
        works in tilemap offsets and does not have to know which kind it got.
        """
        if self.layer2_background:
            return self.layer2_low[index] | (self.layer2_high[index] << 8)
        start = (
            LAYER2_REGION_VERTICAL if self.vertical else LAYER2_REGION_HORIZONTAL
        ) + index
        return self.map16_low[start] | (self.map16_high[start] << 8)

    def layer2_definition(self, tile: int) -> bytes:
        """The eight bytes defining Layer 2's Map16 tile ``tile``.

        A background reads its own table and a Layer 2 level reads Layer 1's,
        because a Layer 2 level is drawn by the same object routines out of the
        same tileset.

        **A Layer 2 level under tileset $03 is drawn a palette bit higher**,
        which is not in the definitions and is why it is applied here. The
        routine that turns Map16 blocks into BG2's tilemap words
        (``SMW_BufferScrollingTiles_Layer2``, both the initial build and every
        scroll after it) ``ORA``s ``$1000`` into all four words of every
        block when the level's FG/BG tileset is ``$03``, and does it for a
        Layer 2 *level* only -- the background arm of the same routine has no
        such step. So the cave's grey-green rock is drawn on Layer 1 and the
        same block comes out yellow on Layer 2, which is what Donut Plains 2's
        moving platform is.
        """
        if self.layer2_background:
            return _definition(self.layer2_defs, tile)
        definition = self.definition(tile)
        if self.fg_bg_tileset != LAYER2_PALETTE_TILESET:
            return definition
        # The high byte of each little-endian tilemap word, which is where the
        # palette's top bit sits.
        return bytes(
            byte | LAYER2_PALETTE_BIT if at % 2 else byte
            for at, byte in enumerate(definition)
        )

    def definition(self, tile: int) -> bytes:
        """The eight bytes defining Map16 tile ``tile``: the loader's own for
        the stock two pages, the custom tiles' table past them."""
        if tile >= MAP16_TILE_COUNT:
            return _custom_definition(self.custom_defs, tile)
        return _definition(self.map16_defs, tile)

    @property
    def screen_count(self) -> int:
        """Screens in the level -- the header's ``screens`` field."""
        return field_value(self.header, "screens")

    @property
    def level_mode(self) -> int:
        """The header's ``level_mode`` field: picks geometry and screen tables."""
        return field_value(self.header, "level_mode")

    @property
    def layer3_in_front(self) -> bool:
        """The header's ``layer3_priority`` field: Layer 3 drawn over all.

        The bit the loader turns into BG mode ``$01`` or ``$09``. Set, Layer 3
        is drawn in front of everything -- which is what a tide's water surface
        wants; clear, it sits behind Layer 1.
        """
        return bool(field_value(self.header, "layer3_priority"))

    @property
    def fg_bg_tileset(self) -> int:
        """The header's ``fg_bg_tileset`` field: graphics slots and Map16."""
        return field_value(self.header, "fg_bg_tileset")

    @property
    def sprite_tileset(self) -> int:
        """Header byte 2 bits 3-0: which four files land in SP1-SP4.

        **A different field from :attr:`fg_bg_tileset`, chosen independently**,
        and that independence is the whole reason a sprite's graphics are a
        question worth asking. The level tileset picks the object dispatch
        table, the tileset-specific Map16 definitions *and* the FG/BG graphics
        row together, so an object offered for this level cannot be drawn out of
        graphics that are not here. A sprite can: its artwork comes from
        ``SpriteGFXList`` indexed by this byte, and nothing ties the two nibbles
        together.
        """
        return field_value(self.header, "sprite_tileset")

    @property
    def vertical(self) -> bool:
        """Whether Layer 1 is a vertical level.

        Read from the flags byte rather than derived from the level mode: the
        mode is only an index into a table in the cartridge, and this is what
        that lookup produced on the machine that ran the load.
        """
        return bool(self.screen_mode & LAYOUT_LAYER1_VERTICAL)
