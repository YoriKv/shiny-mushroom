"""Drawing a loaded level, with no Qt in it.

The input is a :class:`~shiny_mushroom.level_snapshot.LevelSnapshot` and the output is a
plain RGB :class:`Raster`; making that into a ``QImage`` is
:mod:`shiny_mushroom.ui.render`'s job. Keeping the two apart is what lets this be
tested by handing it bytes and reading pixels back, with no display, no
application and no emulator behind it.

**Nothing here parses the cartridge.** Every decision a renderer would normally
have to reimplement -- which of the six Map16 definition tables a tile comes
from, which graphics file landed in which VRAM slot, what the tileset did to the
palette -- was already made by the game's own loader before the snapshot was
taken. What is left is mechanical: look a tile number up in the definitions the
loader resolved, read its four 8x8 tiles out of the VRAM it filled, and colour
them from the CGRAM it wrote.

The one decision the loader did not make is the pipe tiles', because the game
does not make it at load time either: it re-points them per column as it
buffers the level into VRAM, so a pipe's colour is a function of where it
stands and no single capture of the pointer table is an answer for the level.
:func:`pipe_table` is that choice, made again here out of the four tables the
snapshot carries.

Three layers are drawn here. :func:`render_level` is Layer 1 alone and is the
whole of what an editor needs most of the time; :func:`render_layers` puts the
background behind it and Layer 3 behind or in front of it. Layer 2 is the same
Map16 pipeline over different inputs -- a Layer 2 *level* sits further up this
same tilemap buffer, a *background* has its own two-screen buffer and its own
definition table in the cartridge -- and Layer 3 is not Map16 at all.

What none of it draws:

- **No sprites.** They are not in the tilemap at all; they are an object stream
  and per-sprite display code.
- **No colour maths.** A handful of level modes composite their layers with
  something other than a plain add, and are drawn here as though they did not.
- **The initial state.** Tiles the game rewrites during play -- a hit ``?``
  block becoming a used one -- are changes to a level being played, not to the
  level.
"""

from __future__ import annotations

from collections.abc import Iterable, Sequence
from dataclasses import dataclass
from functools import lru_cache
from typing import TYPE_CHECKING

from shiny_mushroom.addresses import (
    LAYER2_REGION_HORIZONTAL,
    LAYER2_REGION_VERTICAL,
    MAP16_DEF_SIZE,
    PIPE_TABLES,
    PIPE_TILES,
)

if TYPE_CHECKING:
    # Annotations only, and deliberately: this module turns a snapshot into
    # pixels and never makes one. `shiny_mushroom.overworld_snapshot` reaches
    # `shiny_mushroom.overworld`, which reaches this module, so naming the
    # overworld's type at runtime would be the circle.
    from shiny_mushroom.level_snapshot import LevelSnapshot
    from shiny_mushroom.overworld_snapshot import OverworldSnapshot

# -- the console's units ----------------------------------------------------

#: The PPU's tile, in pixels. Four of them make a Map16 block.
TILE = 8
BLOCK = 16

#: One 8x8 tile at 4bpp: eight rows of two bitplanes, then eight more.
BYTES_PER_TILE = 32

#: Colours per background palette row, and rows before the sprite half.
COLORS_PER_ROW = 16

# -- the Map16 tilemap's geometry -------------------------------------------
#
# One entry per 16x16 block, addressed screen by screen. Both layouts store a
# screen as consecutive rows of 16 columns; what differs is how many rows a
# screen has and whether a second half-screen sits beside it.

SCREEN_COLUMNS = 16

#: A horizontal screen is 16 columns of 27 rows.
HORIZONTAL_ROWS = 27
HORIZONTAL_STRIDE = 0x1B0

#: A vertical screen is 32 columns of 16 rows, stored as two 16-column halves
#: one after the other -- which is the ``+$100`` the object loader adds for
#: "right half".
VERTICAL_COLUMNS = 32
VERTICAL_ROWS = 16
VERTICAL_STRIDE = 0x200
VERTICAL_RIGHT_HALF = 0x100

#: Entries in the Map16 tilemap: ``$7EC800``-``$7F0000`` of block numbers, one
#: buffer for the whole level whatever its shape.
TILEMAP_ENTRIES = 0x3800

#: Screens Layer 1 gets **when Layer 2 is a level** -- when the level's Layer 2
#: is drawn by the same object routines into the same buffer. The cartridge's
#: per-screen pointer tables give Layer 1 the first sixteen horizontal screens
#: (or fourteen vertical ones) and Layer 2 the rest.
HORIZONTAL_LAYER2_SCREENS = 16
VERTICAL_LAYER2_SCREENS = 14

#: Screens Layer 1 gets when Layer 2 is a **background**, which is most levels.
#: The two halves of each pointer table are contiguous -- Layer 2's first
#: horizontal screen is ``$1B0*$10``, exactly where Layer 1's sixteenth ends --
#: so a level with no Layer 2 tilemap to collide with simply keeps going, and
#: the only bound left is the buffer. Real levels use it: level ``$001`` is
#: twenty screens long, and cutting it at sixteen both hides its last four
#: screens and shows them again as though they were behind its first four.
HORIZONTAL_SCREENS = TILEMAP_ENTRIES // HORIZONTAL_STRIDE
VERTICAL_SCREENS = TILEMAP_ENTRIES // VERTICAL_STRIDE

#: A Layer 2 background is two 16-column screens side by side, 27 rows tall --
#: exactly the width of the PPU's 64x64 tilemap, which is why it never needs a
#: scroll-time update. It repeats across and down whatever size the level is.
BACKGROUND_COLUMNS = 32
BACKGROUND_ROWS = 27

# -- Layer 3 ----------------------------------------------------------------
#
# Not Map16 and not the level's shape: a PPU tilemap the loader uploads whole,
# 64x64 8x8 tiles that repeat over the level. In BG mode 1 -- which is what
# every level runs in -- Layer 3 is **2bpp**, so none of the block pipeline
# above applies to it.

#: Byte offsets into the captured VRAM. The registers hold word addresses:
#: BG3's tilemap base is ``$14`` in units of ``$400`` words and its graphics
#: base is ``$04`` in units of ``$1000`` words.
LAYER3_TILEMAP = 0x14 * 0x400 * 2
LAYER3_GRAPHICS = 0x04 * 0x1000 * 2

#: One 8x8 tile at 2bpp: eight rows of two interleaved bitplanes.
BYTES_PER_2BPP_TILE = 16

#: Colours per 2bpp palette row. Eight rows of four, over CGRAM 0-31.
COLORS_PER_2BPP_ROW = 4

#: The tilemap is four 32x32 pages -- top-left, top-right, bottom-left,
#: bottom-right -- each ``$400`` words after the last.
LAYER3_PAGE = 32
LAYER3_PAGE_ENTRIES = LAYER3_PAGE * LAYER3_PAGE
LAYER3_TILES = 2 * LAYER3_PAGE

#: Pixel rows in the whole tilemap, which is what BG3's scroll indexes.
LAYER3_ROWS = LAYER3_TILES * TILE

#: The rows of the tilemap the status bar occupies, and the only ones an editor
#: has to leave out.
#:
#: The tilemap holds two things at once: the status bar and the level's own
#: Layer 3 -- a tide, a fog, a castle's windows. The console keeps them apart in
#: time rather than in space: the status bar is drawn with BG3 scrolled to zero,
#: and IRQ #1 -- armed at scanline ``$24`` -- rewrites the scroll from
#: ``$7E0022``/``$7E0024`` for the rest of the frame. So the status bar is
#: exactly the top of the tilemap, and everything from row 38 down belongs to
#: whichever level asked for it. Measured across every level that has a Layer 3:
#: the status bar's own image is rows 10-37 and nothing else is above 38.
#:
#: The level's half is **not** the bottom page. A tide's water starts at row
#: 256, but a tileset image sits wherever the loader's scroll puts it -- level
#: ``$009`` fills rows 192-415 and ``$01F`` rows 160-191, both of which straddle
#: or miss that boundary entirely.
LAYER3_STATUS_BAR_ROWS = 38


@dataclass(frozen=True)
class Raster:
    """A picture as 8-bit RGB, three bytes per pixel, rows top to bottom."""

    width: int
    height: int
    pixels: bytes

    @property
    def stride(self) -> int:
        """Bytes per row. Every consumer of ``pixels`` needs this to read it."""
        return self.width * 3


@dataclass(frozen=True)
class Geometry:
    """The shape of a level in blocks, and where each block's entry lives.

    Separated from the drawing because it is the part that is easy to get
    subtly wrong and cheap to test: an off-by-one screen stride still produces
    a picture, just one assembled out of the wrong parts of the level.
    """

    columns: int
    rows: int
    vertical: bool

    @property
    def screen(self) -> tuple[int, int]:
        """One screen's ``(columns, rows)`` in blocks.

        Not square, and not the same shape in the two layouts: a horizontal
        screen is the level's full 27-row height and 16 columns of it, a
        vertical one the full 32-column width and 16 rows of it. Both are 256
        tilemap entries, which is the ``$100`` the object loader adds for the
        far half.
        """
        if self.vertical:
            return VERTICAL_COLUMNS, VERTICAL_ROWS
        return SCREEN_COLUMNS, HORIZONTAL_ROWS

    @property
    def screens(self) -> int:
        """How many screens long this level is.

        Counted from the level's own extent rather than from the sixteen (or
        fourteen) the tilemap buffer is divided into: what a screen number
        addresses here is a screen the level *has*, which is what the header's
        screen count says and what the canvas draws a cell for.
        """
        columns, rows = self.screen
        length, cell = (self.rows, rows) if self.vertical else (self.columns, columns)
        return max(1, -(-length // cell))

    def screen_of(self, column: int, row: int) -> int:
        """Which screen the block at ``(column, row)`` sits on.

        Screens advance along the level's long axis and only that one: across
        in a horizontal level, down in a vertical one. The other axis is one
        screen wide by definition, which is why only one coordinate is read.

        This is the same number an object record carries and a screen exit is
        indexed by, so a position read off the status bar can be matched
        against the object list without arithmetic.
        """
        if self.vertical:
            return row // VERTICAL_ROWS
        return column // SCREEN_COLUMNS

    def index(self, column: int, row: int) -> int:
        """The Map16 tilemap offset holding the block at ``(column, row)``."""
        if self.vertical:
            screen, within = divmod(row, VERTICAL_ROWS)
            half, column = divmod(column, SCREEN_COLUMNS)
            return (
                screen * VERTICAL_STRIDE
                + half * VERTICAL_RIGHT_HALF
                + within * SCREEN_COLUMNS
                + column
            )
        screen, column = divmod(column, SCREEN_COLUMNS)
        return screen * HORIZONTAL_STRIDE + row * SCREEN_COLUMNS + column

    def block_at(self, index: int) -> tuple[int, int] | None:
        """The block a Map16 tilemap offset holds, or ``None`` for one outside
        this level.

        The inverse of :meth:`index`, and needed because the loader reports what
        it wrote in tilemap offsets while everything above works in blocks. A
        level does not fill its buffer -- the tilemap is a fixed 16 or 14 screens
        whatever the header says -- so an offset past the end is a real answer,
        not an error.
        """
        if index < 0:
            return None
        if self.vertical:
            screen, within = divmod(index, VERTICAL_STRIDE)
            half, within = divmod(within, VERTICAL_RIGHT_HALF)
            row, column = divmod(within, SCREEN_COLUMNS)
            column += half * SCREEN_COLUMNS
            row += screen * VERTICAL_ROWS
        else:
            screen, within = divmod(index, HORIZONTAL_STRIDE)
            row, column = divmod(within, SCREEN_COLUMNS)
            column += screen * SCREEN_COLUMNS
        if column >= self.columns or row >= self.rows:
            return None
        return column, row


#: A stand-in for a real level's geometry, for asking a record what it *says*
#: rather than what it can be changed to.
#:
#: A readout never writes, so which axis a screen counts along cannot change a
#: word of it -- and demanding the real shape for it would push the level's
#: geometry into every status line and test that only wants to read a record.
#: The widest a horizontal level gets, so nothing a caller reads is bounded
#: tighter than the format allows.
ANY_SHAPE = Geometry(columns=SCREEN_COLUMNS * 32, rows=HORIZONTAL_ROWS, vertical=False)


def level_shape(screen_count: int, vertical: bool, layer2_background: bool) -> Geometry:
    """How big a level of this description is, in blocks.

    The screen count is clamped rather than trusted, and what it is clamped to
    depends on what the level's Layer 2 is. A Layer 2 *level* shares the tilemap
    with Layer 1 and takes everything above screen ``$10`` (``$0E`` down), so
    Layer 1 stops there. A Layer 2 *background* lives in its own buffer and
    leaves the whole tilemap to Layer 1, which then only runs out at the end of
    it -- and levels do run past sixteen screens.

    Three plain values rather than a snapshot, because a level can be described
    without one having been loaded: all three are readable straight off the
    cartridge, which is what lets every level in a ROM be measured at once.
    :func:`geometry` is this for a level that *has* been loaded.
    """
    if vertical:
        limit = VERTICAL_SCREENS if layer2_background else VERTICAL_LAYER2_SCREENS
        screens = min(max(screen_count, 1), limit)
        return Geometry(VERTICAL_COLUMNS, screens * VERTICAL_ROWS, True)
    limit = HORIZONTAL_SCREENS if layer2_background else HORIZONTAL_LAYER2_SCREENS
    screens = min(max(screen_count, 1), limit)
    return Geometry(screens * SCREEN_COLUMNS, HORIZONTAL_ROWS, False)


def geometry(snapshot: LevelSnapshot) -> Geometry:
    """How big ``snapshot``'s Layer 1 is, in blocks.

    The loaded level's answer, and the one to prefer wherever there is a
    snapshot: ``vertical`` comes from the flags byte the game's own header
    parser wrote, rather than from the table that parser indexed.
    """
    return level_shape(
        snapshot.screen_count, snapshot.vertical, snapshot.layer2_background
    )


def snes_color(value: int) -> bytes:
    """One 15-bit SNES colour (``0BBBBBGG GGGRRRRR``) as three RGB bytes.

    The top three bits are replicated into the bottom three rather than shifted
    up and left zero: ``$1F`` has to come back as ``$FF``, or the brightest
    colour the console can show renders as a light grey.
    """
    channels = (value & 0x1F, (value >> 5) & 0x1F, (value >> 10) & 0x1F)
    return bytes((channel << 3) | (channel >> 2) for channel in channels)


@lru_cache(maxsize=16)
def palette(cgram: bytes) -> tuple[bytes, ...]:
    """CGRAM read as 256 colours, each three RGB bytes.

    Padded to the full 256 so that indexing it is total. A real snapshot always
    carries the console's whole 512-byte CGRAM; a short one is a synthetic
    snapshot, and rendering it black beats raising out of the middle of a draw.

    **Kept, keyed on the memory itself.** A level's colours are read again for
    every :class:`Blocks`, every sprite plane and every preview drawn out of the
    same snapshot -- a dozen times over a single edit, each one 256 colours
    converted from the same 512 bytes. The cache is small because the answer is
    a function of the CGRAM and nothing else, and a handful of distinct ones are
    live at a time: the level's, a recoloured copy of it, and the player
    capture's. A tuple rather than a list, because a shared answer must not be
    something a caller can write into.
    """
    colors = tuple(
        snes_color(cgram[n * 2] | (cgram[n * 2 + 1] << 8))
        for n in range(len(cgram) // 2)
    )
    return colors + (b"\x00\x00\x00",) * max(0, 256 - len(colors))


def pipe_table(column: int) -> int:
    """Which of the four pipe tables a Layer 1 block at ``column`` is drawn from.

    The cartridge's own arithmetic -- ``LSR #3 : AND #$0006`` over the number
    of the column being buffered -- which is one table per screen, cycling
    every four screens: the level's own "variable" colour, green, yellow,
    purple. So the same pipe object is a different colour in the fifth screen
    of a level than in the fourth, and that is the game rather than the
    editor.
    """
    return (column // SCREEN_COLUMNS) % PIPE_TABLES


def pipe_tables(snapshot: LevelSnapshot) -> tuple[bytes, ...]:
    """The four pipe tables to draw ``snapshot``'s Layer 1 with, if any.

    Empty for a vertical level, where the cartridge never swaps them: the code
    that does is on the horizontal arm of
    ``SMW_CalculateRowOrColumnOfTilemapToUpdate`` and the vertical arm jumps
    past it, so a vertical level's pipes are whatever
    ``InitializeMap16Pointers`` left -- which is what the capture holds.
    """
    return () if snapshot.vertical else snapshot.pipe_definitions


#: Map16 number -> the block it is a picture of once something reveals it, for
#: the blocks the cartridge draws nothing at all for until then.
#:
#: Both halves of every pair are read out of one table, ``Tiles`` in
#: ``SMW_StandardObjXX_Generic1RepeatedTileObject``, which is the low byte of
#: the tile objects ``$01``-``$0E`` place -- page ``$00`` for objects ``$01``
#: to ``$07`` and page ``$01`` for the rest. So each invisible block is paired
#: with the block another object in the same table places to hold the same
#: thing: the invisible coin block with the coin question block, the invisible
#: jumping note block with the jumping note block, and the coins a P-switch
#: turns on with plain coins.
#:
#: **Not every invisible block has one.** Extended objects ``$11``, ``$12``,
#: ``$16`` and ``$19``-``$1C`` place blocks that are equally blank -- ``$022``,
#: ``$024``, ``$029`` and ``$06F``-``$072`` -- and what they turn into has to
#: be read out of the block interaction code rather than guessed from a name,
#: which is the same bargain :data:`shiny_mushroom.sprites.REVEALS` makes.
GHOST_TILES = {
    0x021: 0x124,  # invisible coin block -> coin question block (object $0A)
    0x023: 0x113,  # invisible note block -> jumping note block  (object $08)
    0x02A: 0x02B,  # invisible P-switch coin -> coin            (object $05)
}


#: What :class:`Blocks` caches a drawn block under. A block number on its own
#: for every tile whose picture the number settles, and the number beside the
#: pipe table its column chose for the eight it does not -- see
#: :func:`pipe_table`.
type _Key = int | tuple[int, int]


#: What :meth:`Blocks.cover` answers: a block that hides nothing of what is
#: behind it, one that hides all of it, and one that does neither.
BLANK, SOLID, PARTLY = 0, 1, 2


def _stipple(row: int) -> tuple[int, ...]:
    """Which pixels of a block's row ``row`` a ghost leaves out.

    Every other one, on a checkerboard measured in the *picture's* coordinates
    rather than the block's -- which costs nothing to arrange, because a block
    stands at a multiple of sixteen and sixteen is even, so the two parities are
    the same. That is what keeps two ghosted blocks side by side one pattern
    instead of two.
    """
    return tuple(x for x in range(BLOCK) if (x + row) & 1)


class Blocks:
    """The two caches a level is drawn out of, for one snapshot.

    A level is tens of thousands of blocks drawn from at most 512 distinct
    definitions, and each of those from at most a few hundred distinct 8x8
    tiles, so decoding per occurrence would do the same work thousands of times
    over. With the caches the per-pixel work happens once per *distinct* tile
    and the rest is concatenation.

    Only ``definition``, ``vram``, ``cgram`` and ``back_area_color`` are read
    of the snapshot -- which is why an
    :class:`~shiny_mushroom.overworld_snapshot.OverworldSnapshot` draws through the
    same cache, with ``layer2`` necessarily ``False``: the overworld's Layer 2
    is not Map16 and has no definition table to point this at.

    ``ghosts`` draws the blocks in :data:`GHOST_TILES` -- which the cartridge
    draws nothing for -- as the block each becomes, at half strength. Pass it
    exactly where ``pipes`` is passed and for the same reason: both are
    decisions about a **level's Layer 1**, and a Map16 sheet or a Layer 2
    definition table is a different set of numbers meaning different things.
    """

    def __init__(
        self,
        snapshot: LevelSnapshot | OverworldSnapshot,
        layer2: bool = False,
        pipes: Sequence[bytes] = (),
        ghosts: bool = False,
    ) -> None:
        self._snapshot = snapshot
        # Which set of definitions a tile number means. A Layer 2 background is
        # the one case where they are not the ones the loader resolved, because
        # it has a table of its own -- see LevelSnapshot.layer2_definition.
        self._definition = snapshot.layer2_definition if layer2 else snapshot.definition
        # The pipe tiles' four, for a caller that has a column to choose with:
        # `pipe_tables`, and empty everywhere the choice is not this drawing's
        # to make -- the overworld, a Map16 sheet, a vertical level.
        self._pipes = pipes
        # Empty for the same reason, so that one lookup answers "is this block
        # ghosted here" wherever a number is turned into pixels.
        self._ghosts = GHOST_TILES if ghosts else {}
        self._colors = palette(snapshot.cgram)
        self._backdrop = snes_color(snapshot.back_area_color)
        self._tiles: dict[int, tuple[bytes, ...]] = {}
        self._blocks: dict[_Key, tuple[bytes, ...]] = {}
        self._tile_holes: dict[int, tuple[bytes, ...]] = {}
        self._holes: dict[_Key, tuple[tuple[tuple[int, int], ...], ...]] = {}
        # What a block covers -- see :meth:`cover`. Kept beside the pixels
        # because it is asked once per *occurrence* where those are asked once
        # per distinct block: a level is five sixths sky, and answering "is
        # there anything here at all" by walking sixteen rows of runs every
        # time was a third of what compositing cost.
        self._cover: dict[_Key, int] = {}

    def tile_rows(self, word: int) -> tuple[bytes, ...]:
        rows = self._tiles.get(word)
        if rows is None:
            rows = self._tiles[word] = _tile_rows(
                word, self._snapshot.vram, self._colors, self._backdrop
            )
        return rows

    def tile_holes(self, word: int) -> tuple[bytes, ...]:
        rows = self._tile_holes.get(word)
        if rows is None:
            rows = self._tile_holes[word] = _tile_holes(word, self._snapshot.vram)
        return rows

    def _key(self, number: int, column: int | None) -> _Key:
        """What this block is cached under: its number, or its number and the
        pipe table its column chose -- the one block whose picture is not a
        function of the number alone. See :func:`pipe_table`.
        """
        if column is None or not self._pipes or number not in PIPE_TILES:
            return number
        return number, pipe_table(column)

    def _quarters(self, key: _Key, of):  # noqa: ANN001, ANN202
        """One block's four tiles, in the order they are drawn.

        Upper-left, lower-**left**, upper-right, lower-right -- the order the
        definition is stored in, which is not the order it is drawn in, and the
        single most productive way to get a level's picture subtly wrong.

        A ghosted block reads the definition of the block it *becomes*, and is
        still cached under its own number: what is drawn changes, what the
        tilemap holds does not.
        """
        if isinstance(key, tuple):
            number, table = key
            start = (number - PIPE_TILES.start) * MAP16_DEF_SIZE
            definition = self._pipes[table][start : start + MAP16_DEF_SIZE]
        else:
            definition = self._definition(self._ghosts.get(key, key))
        return (
            of(definition[n] | (definition[n + 1] << 8))
            for n in range(0, len(definition), 2)
        )

    def rows(self, number: int, column: int | None = None) -> tuple[bytes, ...]:
        """One Map16 block as sixteen rows of RGB, cached by block number.

        ``column`` is where in the level the block stands, and is only ever
        read of a pipe tile -- pass it wherever Layer 1 is being drawn.
        """
        key = self._key(number, column)
        rows = self._blocks.get(key)
        if rows is None:
            upper_left, lower_left, upper_right, lower_right = self._quarters(
                key, self.tile_rows
            )
            drawn = [upper_left[y] + upper_right[y] for y in range(TILE)] + [
                lower_left[y] + lower_right[y] for y in range(TILE)
            ]
            if key in self._ghosts:
                drawn = [self._half(line, y) for y, line in enumerate(drawn)]
            rows = self._blocks[key] = tuple(drawn)
        return rows

    def _half(self, line: bytes, row: int) -> bytes:
        """One row of a ghosted block: every other pixel of it replaced by the
        backdrop, which is what :meth:`rows` fills transparency with.

        Left out rather than blended, exactly as a hidden sprite's pixels are:
        a blend of the picture would compound wherever the picture is drawn
        twice, and a written pixel cannot. Zoomed out the checkerboard averages
        to the half strength it stands for; at 1:1 it reads as a ghost.
        """
        pixels = bytearray(line)
        for x in _stipple(row):
            pixels[x * 3 : x * 3 + 3] = self._backdrop
        return bytes(pixels)

    def holes(
        self, number: int, column: int | None = None
    ) -> tuple[tuple[tuple[int, int], ...], ...]:
        """Where a block lets what is behind it through: per pixel row, the
        ``(start, stop)`` runs of transparent pixels.

        Sixteen empty tuples for a solid block -- which is the cheap answer the
        compositing loop tests for first -- and one full-width run per row for a
        block that draws nothing at all.

        A ghosted block lets through everywhere its half strength leaves out, so
        what is behind it shows between its pixels rather than the backdrop
        :meth:`rows` had to put there -- the same answer for the same reason as
        for the pixels its own tiles never drew.
        """
        key = self._key(number, column)
        holes = self._holes.get(key)
        if holes is None:
            upper_left, lower_left, upper_right, lower_right = self._quarters(
                key, self.tile_holes
            )
            flags = [upper_left[y] + upper_right[y] for y in range(TILE)] + [
                lower_left[y] + lower_right[y] for y in range(TILE)
            ]
            if key in self._ghosts:
                flags = [self._gaps(line, y) for y, line in enumerate(flags)]
            holes = self._holes[key] = tuple(_runs(line) for line in flags)
        return holes

    @staticmethod
    def _gaps(flags: bytes, row: int) -> bytes:
        """One row of a ghosted block's transparency mask: what its tiles never
        drew, plus what :meth:`_half` leaves out."""
        mask = bytearray(flags)
        for x in _stipple(row):
            mask[x] = 1
        return bytes(mask)

    def cover(self, number: int, column: int | None = None) -> int:
        """How much of what is behind a block it hides: :data:`BLANK`,
        :data:`SOLID`, or :data:`PARTLY` for everything in between.

        The question every compositing loop asks first, and cached per block
        because the two cheap answers are what make the loop cheap: a blank
        block is skipped entirely and what is behind it shows, and a solid one
        is sixteen slice assignments with nothing to reason about. Measured on
        level ``$105``, that is 7,172 blocks of 8,640 skipped and 1,225 copied
        whole, leaving 243 to be drawn around their holes.
        """
        key = self._key(number, column)
        answer = self._cover.get(key)
        if answer is None:
            holes = self.holes(number, column)
            if not any(holes):
                answer = SOLID
            elif all(run == ((0, BLOCK),) for run in holes):
                answer = BLANK
            else:
                answer = PARTLY
            self._cover[key] = answer
        return answer

    def blank(self, number: int, column: int | None = None) -> bool:
        """Whether a block is transparent everywhere, so there is nothing to
        draw of it over what is already there."""
        return self.cover(number, column) == BLANK


def over_holes(
    rows: list[bytearray],
    drawn: Sequence[bytes],
    holes: Sequence[Sequence[tuple[int, int]]],
) -> None:
    """Lay ``drawn`` over ``rows`` everywhere the block is opaque.

    ``holes`` is :meth:`Blocks.holes`' answer for the block being drawn, so a
    row with no runs is copied whole -- the cheap case -- and every other row
    is copied around its transparent runs, leaving what is already there
    showing through. The world map composites the same way over its own
    Layer 2, which is why the loop lives here rather than in either picture.
    """
    for y, runs in enumerate(holes):
        if not runs:
            rows[y][:] = drawn[y]
            continue
        cursor = 0
        for first, last in runs:
            rows[y][cursor * 3 : first * 3] = drawn[y][cursor * 3 : first * 3]
            cursor = last
        rows[y][cursor * 3 :] = drawn[y][cursor * 3 :]


def render_level(snapshot: LevelSnapshot) -> Raster:
    """Draw ``snapshot``'s Layer 1 whole, at one device pixel per SNES pixel.

    Built a row of blocks at a time out of :class:`_Blocks`.
    """
    shape = geometry(snapshot)
    blocks = Blocks(snapshot, pipes=pipe_tables(snapshot), ghosts=True)

    lines: list[bytes] = []
    for row in range(shape.rows):
        drawn = [
            blocks.rows(snapshot.tile(shape.index(column, row)), column)
            for column in range(shape.columns)
        ]
        lines.extend(b"".join(block[y] for block in drawn) for y in range(BLOCK))
    return Raster(shape.columns * BLOCK, shape.rows * BLOCK, b"".join(lines))


def _layer2_index(
    snapshot: LevelSnapshot, shape: Geometry, column: int, row: int
) -> int:
    """Which Layer 2 tilemap entry sits behind the block at ``(column, row)``.

    The two kinds of Layer 2 are addressed differently and neither is the
    caller's problem. A **background** is a 32x27 pattern that repeats across
    and down however big the level is, stored as two 16-column screens. A Layer
    2 **level** is the level's own shape, drawn by the same object routines into
    the same buffer as Layer 1, so it is indexed exactly as Layer 1 is.
    """
    if not snapshot.layer2_background:
        return shape.index(column, row)
    return background_index(column, row)


def layer2_block_at(shape: Geometry, index: int) -> tuple[int, int] | None:
    """The block a Layer 2 **level**'s tilemap offset names, or ``None`` for
    one outside the level.

    :meth:`Geometry.block_at` shifted by the region, which is the whole of what
    makes Layer 2's half of the Map16 buffer readable in the level's own
    coordinates -- the loader reports what a Layer 2 object drew in offsets
    into the one buffer, and those land above the region rather than below it.
    Meaningless for a level whose Layer 2 is a background, which has a buffer
    of its own; :func:`background_at` is that one's inverse.
    """
    region = LAYER2_REGION_VERTICAL if shape.vertical else LAYER2_REGION_HORIZONTAL
    return shape.block_at(index - region)


def background_index(column: int, row: int) -> int:
    """Which background pattern entry repeats at block ``(column, row)``.

    The pattern's own addressing, shared by the renderer and an edit: a
    32x27 repeat stored as two 16-column screens, so one entry answers for
    every place the pattern lands on the level.
    """
    screen, within = divmod(column % BACKGROUND_COLUMNS, SCREEN_COLUMNS)
    return (
        screen * HORIZONTAL_STRIDE + (row % BACKGROUND_ROWS) * SCREEN_COLUMNS + within
    )


def background_at(index: int) -> tuple[int, int]:
    """Which pattern cell ``index`` names, as ``(column, row)`` of the 32x27
    repeat -- :func:`background_index`'s inverse, for whatever needs the
    entry's geometry back: a copy's relative shape, a repeat's first block.
    """
    screen, within = divmod(index, HORIZONTAL_STRIDE)
    row, column = divmod(within, SCREEN_COLUMNS)
    return screen * SCREEN_COLUMNS + column, row


def background_page(snapshot: LevelSnapshot) -> int:
    """Which Map16 page this level's background reads from, 0 or 1.

    A property of where the stream sits in ROM, not of anything in it: the
    loader fills the whole high-byte buffer with one value before it
    decompresses, so any entry answers for all of them. Zero for a snapshot
    with no background, which offers page zero's tiles and is not wrong.
    """
    return snapshot.layer2_high[0] & 1 if snapshot.layer2_high else 0


def background_tiles(snapshot: LevelSnapshot) -> range:
    """The tile numbers a background edit can place: its own page's 256.

    The page and not all 512, because the stored stream carries low bytes
    alone -- an entry from the other page could be shown but never saved, and
    an offer that cannot be kept is not an offer.
    """
    first = background_page(snapshot) * 0x100
    return range(first, first + 0x100)


def background_thumbnails(snapshot: LevelSnapshot) -> list[Raster]:
    """Each placeable background tile as one block of RGB, in
    :func:`background_tiles` order.

    What the palette's library is built from. Colour 0 comes back as the back
    area colour, exactly as the layer is composited over it, so a thumbnail is
    the tile as this level would show it.
    """
    blocks = Blocks(snapshot, layer2=True)
    return [
        Raster(BLOCK, BLOCK, b"".join(blocks.rows(number)))
        for number in background_tiles(snapshot)
    ]


def render_layers(
    snapshot: LevelSnapshot,
    layer2: bool = True,
    layer3: bool = False,
    layer1: bool = True,
) -> Raster:
    """The level with the layers behind and in front of it, composited.

    With only Layer 1 on this is :func:`render_level` -- byte for byte, and
    there is a test holding it to that -- because Layer 1's transparent pixels
    show the back area colour either way. Each layer switched on replaces some
    of that backdrop with something; Layer 1 switched off leaves the layers
    behind it in plain sight, which is what the toggle is *for* -- seeing the
    background under the level standing in front of it.

    **The console's arrangement is not the drawing order**, and it is worth
    knowing why the obvious drawing is nonetheless right. For an ordinary level
    mode Layer 1 is on the main screen, Layer 2 is alone on the *subscreen*, and
    Layer 2 only reaches the picture through colour math adding the subscreen to
    the backdrop. That collapses to "Layer 2 behind Layer 1" because the
    subscreen's own backdrop is black, so the addition is a no-op wherever Layer
    2 is transparent and the PPU substitutes the fixed colour there -- which is
    the back area colour this fills with.

    Where it does *not* collapse is the handful of modes whose colour math is
    not a plain add: the dark-BG modes halve Layer 2, and one mode subtracts.
    Those are drawn here at full strength, so their backgrounds come out
    brighter than the console shows them. Stated rather than corrected, because
    an editor is a picture of the level's contents and not of the PPU.

    **Layer 3 goes behind Layer 2, not merely behind Layer 1.** BG3 with its
    priority bit clear is the bottom-most layer the console draws, so a level
    that has both -- a Layer 2 object level under a tileset's own Layer 3
    image, which is what Donut Plains 2 is -- shows its Layer 2 platform *over*
    the cave behind it. Drawn the other way round the platform came back buried
    under the background, tinted by it, and looked like a rendering fault
    rather than like a platform.
    """
    if layer1 and not layer2 and not layer3:
        # Nothing behind Layer 1, so nothing to keep its transparency for.
        # Short-circuited rather than allowed to fall through: with nothing
        # under them the level's transparent pixels are the backdrop, which
        # makes the whole picture one pass of joined rows -- against filling it
        # with the backdrop first and then laying every block that is not sky
        # around its own holes. Measured on level $105, 11 ms against 19.
        return render_level(snapshot)

    shape = geometry(snapshot)
    width, height = shape.columns * BLOCK, shape.rows * BLOCK
    stride = width * 3
    picture = bytearray(snes_color(snapshot.back_area_color) * (width * height))

    # Layer 3 goes behind everything or in front of everything, and the header
    # says which: the priority bit is what a tide's water surface needs to be
    # seen through, and a castle's windows need the opposite.
    if layer3 and not snapshot.layer3_in_front:
        paint_layer3(snapshot, picture, width, height)

    if layer2:
        _paint_layer2(snapshot, shape, picture, stride)

    if layer1:
        _paint_layer1(snapshot, shape, picture, stride)

    if layer3 and snapshot.layer3_in_front:
        paint_layer3(snapshot, picture, width, height)
    return Raster(width, height, bytes(picture))


def _paint_layer1(
    snapshot: LevelSnapshot, shape: Geometry, picture: bytearray, stride: int
) -> None:
    """Lay Layer 1 over whatever is in ``picture``, keeping its transparency.

    Block by block through :func:`_lay_blocks`, and the column goes with each
    one because Layer 1 is where a pipe's colour is decided by where it stands
    -- see :func:`pipe_table`.
    """
    blocks = Blocks(snapshot, pipes=pipe_tables(snapshot), ghosts=True)
    _lay_blocks(
        blocks,
        picture,
        stride,
        (
            (column, row, snapshot.tile(shape.index(column, row)), column)
            for row in range(shape.rows)
            for column in range(shape.columns)
        ),
    )


def _paint_layer2(
    snapshot: LevelSnapshot, shape: Geometry, picture: bytearray, stride: int
) -> None:
    """Lay Layer 2 over whatever is in ``picture``, keeping its transparency.

    The same loop as Layer 1's, over the other tilemap and the other set of
    definitions -- and with no column, because none of the decisions a column
    settles are Layer 2's to make.
    """
    blocks = Blocks(snapshot, layer2=True)
    _lay_blocks(
        blocks,
        picture,
        stride,
        (
            (
                column,
                row,
                snapshot.layer2_tile(_layer2_index(snapshot, shape, column, row)),
                None,
            )
            for row in range(shape.rows)
            for column in range(shape.columns)
        ),
    )


def _lay_blocks(
    blocks: Blocks,
    picture: bytearray,
    stride: int,
    cells: Iterable[tuple[int, int, int, int | None]],
    /,
) -> None:
    """Lay each of ``cells`` -- ``(column, row, block number, pipe column)`` --
    over what is already in ``picture``, keeping its transparency.

    **What a block covers decides how it is drawn**, and the two cheap answers
    are most of a level: a blank block is not drawn at all, so what is behind it
    shows through without a pixel being written, and a solid one is sixteen
    slice assignments. Only a block that is partly see-through is copied around
    its holes, which on level ``$105`` is 243 of 8,640.

    That is why this is one loop rather than a row of blocks joined into a line
    and copied around the row's gaps: the join built every pixel of every row
    including the five sixths of them that are sky, and working out where the
    holes in a whole row were cost more than drawing what was not sky.
    """
    for column, row, number, at in cells:
        cover = blocks.cover(number, at)
        if cover == BLANK:
            continue
        drawn = blocks.rows(number, at)
        left = row * BLOCK * stride + column * BLOCK * 3
        if cover == SOLID:
            for y in range(BLOCK):
                base = left + y * stride
                picture[base : base + BLOCK * 3] = drawn[y]
            continue
        holes = blocks.holes(number, at)
        for y in range(BLOCK):
            base = left + y * stride
            line = drawn[y]
            gaps = holes[y]
            if not gaps:
                picture[base : base + BLOCK * 3] = line
                continue
            cursor = 0
            for first, last in gaps:
                if first > cursor:
                    picture[base + cursor * 3 : base + first * 3] = line[
                        cursor * 3 : first * 3
                    ]
                cursor = last
            if cursor < BLOCK:
                picture[base + cursor * 3 : base + BLOCK * 3] = line[cursor * 3 :]


def render_layer3(snapshot: LevelSnapshot) -> tuple[Raster, tuple[bytes, ...]]:
    """Layer 3 as the console holds it: the whole 64x64 tilemap, 512x512 pixels,
    with a per-row transparency mask beside it.

    Not a picture of the level -- a picture of the *pattern* that repeats over
    it, which is what Layer 3 is. Whatever the level asked for is in there
    (a tide, a fog, the castle smashers) and so is the status bar, because the
    loader builds that into the same tilemap. Trimming it is the caller's
    decision and :func:`paint_layer3` makes it.

    Returned with the mask rather than pre-composited because Layer 3 is mostly
    transparent, and a caller that drew the transparent pixels as backdrop
    would paint a 512x512 box of sky over the level.

    **Kept, keyed on the three memories it is a function of.** A quarter of a
    megapixel decoded whole, and an *edit* asks for it: patching the four blocks
    a move changed goes through :class:`_Composite`, which needs the pattern to
    put back over them -- so a level with a Layer 3 was decoding all of it and
    throwing it away on every arrow-key repeat, ~6 ms of the edit's own budget.
    Nothing else about the snapshot reaches it, which is what lets the key be
    these three: the tilemap and the graphics are in VRAM, the colours in CGRAM,
    and the backdrop is what a transparent pixel would show.
    """
    return _layer3_raster(snapshot.vram, snapshot.cgram, snapshot.back_area_color)


@lru_cache(maxsize=4)
def _layer3_raster(
    vram: bytes, cgram: bytes, back_area_color: int
) -> tuple[Raster, tuple[bytes, ...]]:
    """:func:`render_layer3`'s body, over what it actually reads."""
    colors = palette(cgram)
    backdrop = snes_color(back_area_color)
    width = LAYER3_TILES * TILE
    lines: list[bytes] = []
    masks: list[bytes] = []
    cache: dict[int, tuple[tuple[bytes, ...], tuple[bytes, ...]]] = {}
    for row in range(LAYER3_TILES):
        decoded = []
        for column in range(LAYER3_TILES):
            word = _layer3_entry(vram, column, row)
            tile = cache.get(word)
            if tile is None:
                tile = cache[word] = (
                    _tile_rows_2bpp(word, vram, colors, backdrop),
                    _tile_holes_2bpp(word, vram),
                )
            decoded.append(tile)
        for y in range(TILE):
            lines.append(b"".join(pixels[y] for pixels, _ in decoded))
            masks.append(b"".join(flags[y] for _, flags in decoded))
    return Raster(width, width, b"".join(lines)), tuple(masks)


def _layer3_entry(vram: bytes, column: int, row: int) -> int:
    """One tilemap word, from whichever of the four 32x32 pages holds it.

    The pages are laid out top-left, top-right, bottom-left, bottom-right, so
    the page is picked by the *high* bit of each coordinate and the position
    within it by the low five -- not by treating the tilemap as 64 entries per
    row, which reads the top-right page as the right half of the top-left one.
    """
    page = (column // LAYER3_PAGE) + (row // LAYER3_PAGE) * 2
    within = (row % LAYER3_PAGE) * LAYER3_PAGE + (column % LAYER3_PAGE)
    at = LAYER3_TILEMAP + (page * LAYER3_PAGE_ENTRIES + within) * 2
    if at + 1 >= len(vram):
        return 0
    return vram[at] | (vram[at + 1] << 8)


def _2bpp_planes(word: int, vram: bytes) -> bytes:
    """The sixteen bytes of one Layer 3 tile, from BG3's own graphics base."""
    base = LAYER3_GRAPHICS + (word & 0x03FF) * BYTES_PER_2BPP_TILE
    planes = vram[base : base + BYTES_PER_2BPP_TILE]
    if len(planes) < BYTES_PER_2BPP_TILE:
        planes = planes.ljust(BYTES_PER_2BPP_TILE, b"\x00")
    return planes


def _tile_rows_2bpp(
    word: int, vram: bytes, colors: Sequence[bytes], backdrop: bytes
) -> tuple[bytes, ...]:
    """One 2bpp tilemap entry as eight rows of RGB.

    The entry is the same ``YXPCCCTT TTTTTTTT`` word a 4bpp one is, but two
    bitplanes make **four** colours and the palette field therefore selects a
    row of four rather than of sixteen -- so Layer 3 lives in CGRAM ``$00``-``$1F``
    and reading it with the 4bpp stride colours it out of the sprite palettes.
    """
    planes = _2bpp_planes(word, vram)
    row_base = ((word >> 10) & 0x07) * COLORS_PER_2BPP_ROW
    x_flip = word & 0x4000
    rows = []
    for y in range(TILE):
        plane0, plane1 = planes[y * 2], planes[y * 2 + 1]
        pixels = []
        for x in range(TILE):
            bit = x if x_flip else TILE - 1 - x
            index = ((plane0 >> bit) & 1) | (((plane1 >> bit) & 1) << 1)
            pixels.append(backdrop if index == 0 else colors[row_base + index])
        rows.append(b"".join(pixels))
    if word & 0x8000:
        rows.reverse()
    return tuple(rows)


def _tile_holes_2bpp(word: int, vram: bytes) -> tuple[bytes, ...]:
    """Which pixels of a 2bpp entry are transparent, 1 where colour 0 came out."""
    planes = _2bpp_planes(word, vram)
    x_flip = word & 0x4000
    rows = []
    for y in range(TILE):
        opaque = planes[y * 2] | planes[y * 2 + 1]
        rows.append(
            bytes(
                0 if (opaque >> (x if x_flip else TILE - 1 - x)) & 1 else 1
                for x in range(TILE)
            )
        )
    if word & 0x8000:
        rows.reverse()
    return tuple(rows)


def layer3_origin(snapshot: LevelSnapshot) -> int:
    """Which row of the Layer 3 tilemap belongs at the level's row 0.

    BG3's scroll is a **screen** offset, so it says nothing on its own about
    where the pattern falls on the level: the console shows tilemap row
    ``layer3_y + line`` on screen line ``line``, and that line is level row
    ``camera_y + line``. Subtracting the camera the capture was taken at is what
    turns the one into the other, and it is the whole of the arithmetic.

    Negative is ordinary and means the pattern starts above the level -- level
    ``$002`` is loaded with the camera at ``$C0`` and its tide scrolled to
    ``$40``, so its water surface belongs 128 rows *below* where the scroll
    alone would put it, at level row 384 rather than 256.

    **It is the alignment at the moment of the load and nothing more.** Only a
    Layer 3 that follows the camera (``Layer3YPos = Layer1YPos``, which is what
    an auto-scrolling background does) is fixed against the level at all; a tide
    and a tileset image are fixed against the *screen*, so they slide over the
    level as the camera moves and no single row is the right one to draw them
    at. This is the row the player sees them at when the level opens.
    """
    return (snapshot.layer3_y % LAYER3_ROWS) - snapshot.camera_y


def layer3_column(snapshot: LevelSnapshot) -> int:
    """Which column of the Layer 3 tilemap belongs at the level's column 0.

    The across-axis counterpart of :func:`layer3_origin`, and the same
    arithmetic: the console shows tilemap column ``layer3_x + line`` at screen
    column ``line``, which is level column ``camera_x + line``. Reading the
    scroll on its own would slide the pattern by wherever the camera happened
    to be when the capture was taken.

    Not wrapped, because the pattern *does* repeat across -- the painters take
    it modulo the tilemap's width -- and negative is as ordinary here as it is
    for a row.
    """
    return snapshot.layer3_x - snapshot.camera_x


def paint_layer3(
    snapshot: LevelSnapshot, picture: bytearray, width: int, height: int
) -> None:
    """Draw the level's Layer 3 into ``picture``, keeping its transparency.

    Nothing happens for a level that asked for no Layer 3. The tilemap still
    holds the status bar in that case, and drawing that over a level would be a
    picture of the console rather than of the level.

    The pattern is placed by :func:`layer3_origin` and :func:`layer3_column`,
    and repeats **across** but
    not down: BG3 scrolls horizontally with the camera in every level that has
    one, so the repeat is what the console shows, while vertically the scroll
    either holds still or tracks the camera exactly -- so the tilemap's 512 rows
    are all there is, and repeating them down the level would invent water no
    console ever drew.
    """
    if not snapshot.layer3_setting:
        return
    raster, masks = render_layer3(snapshot)
    origin = layer3_origin(snapshot)
    column = layer3_column(snapshot)
    stride = width * 3
    solid = (1 << (stride * 8)) - 1
    rows: dict[int, tuple[int, int] | None] = {}
    for y in range(height):
        source = origin + y
        if not LAYER3_STATUS_BAR_ROWS <= source < LAYER3_ROWS:
            continue
        ready = rows.get(source, ())
        if ready == ():
            ready = rows[source] = _layer3_row(
                raster, masks[source], source, width, column, solid
            )
        if ready is None:
            continue
        keep, drawn = ready
        at = y * stride
        # Blended as one big integer rather than run by run. Layer 3's water is
        # a *dither* of opaque and transparent pixels -- which is how the
        # console makes it look translucent -- so a row of it is hundreds of
        # runs a few pixels wide, and copying them one at a time costs a second
        # per level. Two bitwise operations on a 12 KB integer is the same
        # answer at C speed.
        current = int.from_bytes(picture[at : at + stride], "big")
        picture[at : at + stride] = ((current & keep) | drawn).to_bytes(stride, "big")


def _layer3_row(
    raster: Raster, mask: bytes, source: int, width: int, offset: int, solid: int
) -> tuple[int, int] | None:
    """One row of Layer 3, tiled to ``width`` and ready to blend.

    Returns ``(keep, drawn)``: a mask of the pixels already in the picture that
    survive, and the Layer 3 pixels that replace the rest. ``None`` when the row
    is transparent all the way across, which is most of a tide.
    """
    if not any(1 - flag for flag in mask):
        return None
    turn = (offset % raster.width) * 3
    line = raster.pixels[source * raster.stride : (source + 1) * raster.stride]
    line = line[turn:] + line[:turn]
    # `mask` is 1 where the pixel is transparent, so the bytes are $FF where
    # Layer 3 has something to draw.
    stencil = b"".join(b"\x00\x00\x00" if flag else b"\xff\xff\xff" for flag in mask)
    stencil = stencil[turn:] + stencil[:turn]

    repeats = -(-width // raster.width)
    opaque = int.from_bytes((stencil * repeats)[: width * 3], "big")
    drawn = int.from_bytes((line * repeats)[: width * 3], "big") & opaque
    return solid ^ opaque, drawn


class _Composite:
    """Draws one block the way :func:`render_layers` draws the whole level.

    Only :func:`block_runs` needs this. The whole-picture painters above work a
    picture row at a time because that is what makes a level cheap to draw; a
    single block is the opposite shape, and expressing it through them would
    mean rebuilding the level to move a coin. Sixteen pixels wide is small
    enough that the plain loop is the fast version.
    """

    def __init__(
        self, snapshot: LevelSnapshot, layer2: bool, layer3: bool, layer1: bool = True
    ) -> None:
        self._snapshot = snapshot
        self._shape = geometry(snapshot)
        self._layer1 = (
            Blocks(snapshot, pipes=pipe_tables(snapshot), ghosts=True)
            if layer1
            else None
        )
        self._layer2 = Blocks(snapshot, layer2=True) if layer2 else None
        self._backdrop = snes_color(snapshot.back_area_color)
        self._raster = self._masks = None
        self._origin = self._column = 0
        if layer3 and snapshot.layer3_setting:
            self._raster, self._masks = render_layer3(snapshot)
            self._origin = layer3_origin(snapshot)
            self._column = layer3_column(snapshot)

    def rows(self, column: int, row: int) -> tuple[bytes, ...]:
        """One block of the composited picture, as sixteen rows of RGB."""
        rows = [bytearray(self._backdrop * BLOCK) for _ in range(BLOCK)]
        if not self._snapshot.layer3_in_front:
            self._blend(rows, column, row)

        if self._layer2 is not None:
            index = _layer2_index(self._snapshot, self._shape, column, row)
            number = self._snapshot.layer2_tile(index)
            if not self._layer2.blank(number):
                over_holes(rows, self._layer2.rows(number), self._layer2.holes(number))

        if self._layer1 is not None:
            number = self._snapshot.tile(self._shape.index(column, row))
            over_holes(
                rows,
                self._layer1.rows(number, column),
                self._layer1.holes(number, column),
            )

        if self._snapshot.layer3_in_front:
            self._blend(rows, column, row)
        return tuple(bytes(line) for line in rows)

    def _blend(self, rows: list[bytearray], column: int, row: int) -> None:
        """Put this block's window of the Layer 3 pattern over ``rows``."""
        if self._masks is None:
            return
        assert self._raster is not None
        top, left = row * BLOCK, column * BLOCK
        for y in range(BLOCK):
            source = self._origin + top + y
            if not LAYER3_STATUS_BAR_ROWS <= source < LAYER3_ROWS:
                continue
            mask = self._masks[source]
            line = self._raster.pixels[
                source * self._raster.stride : (source + 1) * self._raster.stride
            ]
            for x in range(BLOCK):
                at = (self._column + left + x) % self._raster.width
                if not mask[at]:
                    rows[y][x * 3 : x * 3 + 3] = line[at * 3 : at * 3 + 3]


#: How much of a tilemap to compare at a time when diffing two snapshots. Whole
#: chunks are compared as slices, at C speed, and only a chunk that differs is
#: walked byte by byte -- which is the right shape for this because an edit
#: leaves 99% of a level identical.
DIFF_CHUNK = 4096


def changed_blocks(
    before: LevelSnapshot,
    after: LevelSnapshot,
    shape: Geometry,
    layer3: bool = False,
) -> list[tuple[int, int]] | None:
    """Which blocks of the picture two snapshots disagree about.

    What makes an edit affordable to *draw*. A level's picture is a few
    megabytes and rendering one is 11 to 37 ms, but an edit changes almost none
    of it: measured on level ``$105``, moving one object changes **4** of 8,640
    blocks, and moving the largest object in the level -- one that drew 576
    blocks -- also changes 4, because it redraws itself identically everywhere
    except at the two edges. Patching those over the picture already on the
    canvas is ~0.4 ms against ~37.

    ``None`` means "redraw everything", and it is returned for anything the
    *whole* picture is drawn from: the backdrop colour, the Map16 or background
    definitions, the graphics or palettes, Layer 3's placement, the level's
    shape. Each of those changes blocks whose tilemap entries did not move, so
    a diff of the tilemap alone would miss them. A header edit lands here, which
    is correct: it can change any of them.

    **The diff is of the tilemaps, not of what the editor believes it edited.**
    Diffing the objects' footprints instead would be both slower and wrong:
    slower because the union of an object's old and new footprint is hundreds of
    blocks where the tilemap difference is four, and wrong because a block the
    edit *vacated* is only discovered by noticing that its old entry changed.
    Deletions, insertions and the screen jumps an encoder invents are all
    covered by the same comparison, with nothing to remember.
    """
    if (
        before.back_area_color != after.back_area_color
        or before.map16_defs != after.map16_defs
        or before.layer2_defs != after.layer2_defs
        or before.layer2_background != after.layer2_background
        or before.layer3_setting != after.layer3_setting
        or (before.layer3_x, before.layer3_y) != (after.layer3_x, after.layer3_y)
        or (before.camera_x, before.camera_y) != (after.camera_x, after.camera_y)
        or before.vram != after.vram
        or before.cgram != after.cgram
        or geometry(before) != shape
        or geometry(after) != shape
    ):
        return None
    if layer3 and before.layer3_in_front != after.layer3_in_front:
        return None

    blocks: set[tuple[int, int]] = set()
    # A Layer 2 *level* is drawn by the same object routines into the same
    # buffer, above Layer 1's screens -- so an offset up there is a block of
    # this picture too, at the same place, and dropping it because `block_at`
    # says it is off the end would silently miss every Layer 2 edit.
    region = (
        VERTICAL_LAYER2_SCREENS * VERTICAL_STRIDE
        if shape.vertical
        else HORIZONTAL_LAYER2_SCREENS * HORIZONTAL_STRIDE
    )
    layer2_level = not after.layer2_background
    for old, new in (
        (before.map16_low, after.map16_low),
        (before.map16_high, after.map16_high),
    ):
        for offset in changed_offsets(old, new):
            at = shape.block_at(offset)
            if at is None and layer2_level and offset >= region:
                at = shape.block_at(offset - region)
            if at is not None:
                blocks.add(at)

    if after.layer2_background:
        for old, new in (
            (before.layer2_low, after.layer2_low),
            (before.layer2_high, after.layer2_high),
        ):
            for offset in changed_offsets(old, new):
                blocks.update(background_blocks(shape, offset))

    return sorted(blocks)


def changed_offsets(before: bytes, after: bytes) -> list[int]:
    """Byte offsets at which two buffers differ, ascending.

    Chunked, because the common answer is "nowhere": comparing
    :data:`DIFF_CHUNK` bytes at a time skips a whole chunk per slice compare
    and only walks the bytes of a chunk that disagrees. A buffer the other
    runs past differs at every offset past the shorter one's end.
    """
    if before == after:
        return []
    found: list[int] = []
    for base in range(0, max(len(before), len(after)), DIFF_CHUNK):
        old, new = before[base : base + DIFF_CHUNK], after[base : base + DIFF_CHUNK]
        if old == new:
            continue
        found.extend(
            base + n
            for n in range(max(len(old), len(new)))
            if old[n : n + 1] != new[n : n + 1]
        )
    return found


def background_blocks(shape: Geometry, index: int) -> list[tuple[int, int]]:
    """Every block one Layer 2 *background* entry is drawn at.

    A background is a single 32x27 pattern repeated across and down the whole
    level, so one changed entry is one block per repeat rather than one block --
    which is the difference between patching a level correctly and leaving the
    old tile everywhere but the first screen. The same fan-out puts the
    selection's ants on every repeat of a selected entry, for the same reason:
    every one of those blocks is what an edit to it will repaint.
    """
    column, row = background_at(index)
    return [
        (c, r)
        for r in range(row % BACKGROUND_ROWS, shape.rows, BACKGROUND_ROWS)
        for c in range(column % BACKGROUND_COLUMNS, shape.columns, BACKGROUND_COLUMNS)
    ]


def block_runs(
    snapshot: LevelSnapshot,
    positions: Iterable[tuple[int, int]],
    layer2: bool = False,
    layer3: bool = False,
    layer1: bool = True,
) -> tuple[tuple[int, bytes], ...]:
    """Just these blocks, as ``(offset, pixels)`` runs into a whole level's
    picture -- one run per pixel row of each block, sixteen per block.

    What a redraw is for when almost nothing has changed. A single-object move
    reaches four blocks of the thousands a level holds, and drawing the rest
    again to move those is the difference between ~37 ms and ~0.4.

    The offsets are absolute, so a caller writes them into a picture of this
    level's size and nothing else.

    The layer flags have to match what the picture being patched was drawn
    with, and that is the whole reason they are here: over a composited
    picture, a run of Layer 1 pixels would paint this block's transparency as
    flat backdrop and punch a hole in the background behind it -- and over a
    picture drawn without Layer 1, a run *with* it would paint the level back
    in one block at a time.
    """
    shape = geometry(snapshot)
    stride = shape.columns * BLOCK * 3
    draw = (
        _Composite(snapshot, layer2, layer3, layer1).rows
        if layer2 or layer3 or not layer1
        else _plain_block(snapshot, shape)
    )
    runs = []
    for column, row in positions:
        rows = draw(column, row)
        start = row * BLOCK * stride + column * BLOCK * 3
        runs.extend((start + y * stride, rows[y]) for y in range(BLOCK))
    return tuple(runs)


def _plain_block(snapshot: LevelSnapshot, shape: Geometry):  # noqa: ANN202
    """Layer 1's blocks alone, which is what an uncomposited picture holds."""
    blocks = Blocks(snapshot, pipes=pipe_tables(snapshot), ghosts=True)

    def rows(column: int, row: int) -> tuple[bytes, ...]:
        return blocks.rows(snapshot.tile(shape.index(column, row)), column)

    return rows


def _tile_holes(word: int, vram: bytes) -> tuple[bytes, ...]:
    """Which pixels of one tilemap entry are transparent: eight rows of eight
    flags, 1 where colour 0 came out.

    Kept apart from :func:`_tile_rows` rather than returned beside it so the
    layer-1-only path stays exactly what it was. Only a layer with something
    behind it needs this, and it needs no palette to compute -- transparency is
    a property of the bitplanes, not of the colours they index.
    """
    base = (word & 0x03FF) * BYTES_PER_TILE
    x_flip = word & 0x4000
    y_flip = word & 0x8000

    planes = vram[base : base + BYTES_PER_TILE]
    if len(planes) < BYTES_PER_TILE:
        planes = planes.ljust(BYTES_PER_TILE, b"\x00")

    rows = []
    for y in range(TILE):
        plane0, plane1 = planes[y * 2], planes[y * 2 + 1]
        plane2, plane3 = planes[16 + y * 2], planes[16 + y * 2 + 1]
        # A pixel is transparent exactly when all four planes are clear, so the
        # four bytes can be tested together rather than a bit at a time.
        opaque = plane0 | plane1 | plane2 | plane3
        flags = bytes(
            0 if (opaque >> (x if x_flip else TILE - 1 - x)) & 1 else 1
            for x in range(TILE)
        )
        rows.append(flags)
    if y_flip:
        rows.reverse()
    return tuple(rows)


def _runs(flags: bytes) -> tuple[tuple[int, int], ...]:
    """``flags`` as ``(start, stop)`` runs of set entries.

    What turns a per-pixel mask into slice assignments: a block of sky is one
    run of sixteen rather than sixteen decisions, and a fully opaque block is no
    runs at all, which is the answer the caller wants most often.
    """
    runs: list[tuple[int, int]] = []
    start: int | None = None
    for x, flag in enumerate(flags):
        if flag and start is None:
            start = x
        elif not flag and start is not None:
            runs.append((start, x))
            start = None
    if start is not None:
        runs.append((start, len(flags)))
    return tuple(runs)


def _tile_rows(
    word: int, vram: bytes, colors: Sequence[bytes], backdrop: bytes
) -> tuple[bytes, ...]:
    """One SNES tilemap entry decoded into eight rows of RGB.

    The entry is ``YXPCCCTT TTTTTTTT``: a 10-bit tile number, a 3-bit palette
    row, a priority bit that only orders it against sprites, and the two flips.

    Colour 0 of every row is transparent, and what shows through is the PPU's
    fixed colour rather than CGRAM colour 0 -- which the game forces to black
    and never displays.
    """
    base = (word & 0x03FF) * BYTES_PER_TILE
    row_base = ((word >> 10) & 0x07) * COLORS_PER_ROW
    x_flip = word & 0x4000
    y_flip = word & 0x8000

    planes = vram[base : base + BYTES_PER_TILE]
    if len(planes) < BYTES_PER_TILE:
        # Only reachable from a truncated VRAM, which means a synthetic
        # snapshot: a real one is always the console's full 64 KB.
        planes = planes.ljust(BYTES_PER_TILE, b"\x00")

    rows = []
    for y in range(TILE):
        # 4bpp is two pairs of bitplanes: 0 and 1 interleaved over the first
        # 16 bytes, 2 and 3 over the second.
        plane0, plane1 = planes[y * 2], planes[y * 2 + 1]
        plane2, plane3 = planes[16 + y * 2], planes[16 + y * 2 + 1]
        pixels = []
        for x in range(TILE):
            bit = x if x_flip else TILE - 1 - x
            index = (
                ((plane0 >> bit) & 1)
                | (((plane1 >> bit) & 1) << 1)
                | (((plane2 >> bit) & 1) << 2)
                | (((plane3 >> bit) & 1) << 3)
            )
            pixels.append(backdrop if index == 0 else colors[row_base + index])
        rows.append(b"".join(pixels))
    if y_flip:
        rows.reverse()
    return tuple(rows)
