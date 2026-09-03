"""An area of a level's Layer 1, or the whole of its Layer 2, as the 8x8
tiles it stands on, and the way back from each of those to the graphics
file it came out of.

The canvas draws a level out of the loader's answers: a Map16 tilemap, the
definitions its numbers index, and the VRAM the game uploaded. Every block
is four tilemap words, and every word names a VRAM tile, a palette row and
two flips. This module walks that chain **backwards** for a rectangle of
blocks: the word's tile number is a byte offset into VRAM, the offset falls
in one of the four layer slots, the slot holds a file the level's graphics
row (or its tileset) names, and the tile's place in the slot is its index in
that file. So a picture of the area, pixel-edited and handed back, is a set
of tiles to write into files -- the same files the Graphics window edits one
sheet at a time ([graphics-editing.md](../../docs/editor/graphics-editing.md)),
reached through what the level shows instead of through the file's own sheet.

Three things break the chain, and a cell that hits one is shown but never
written (:attr:`Cell.editable`):

- **A tile past the four slots.** A word can name tiles ``$000``-``$3FF``;
  the layer slots hold ``$000``-``$1FF``. Above that is not a file's.
- **A slot whose file the cartridge could not say**, or one the animated
  tiles own (:data:`shiny_mushroom.level_graphics.ANIMATED_TILES`): what
  VRAM holds there is `GFX33`'s, whatever file the slot names.
- **A file that could not be read** when the edit is applied.

What a file can *show* is not the sixteen indices VRAM can hold. A 4bpp
file holds sixteen; a 3bpp file eight, and the uploader moves some of its
tiles to indices 8-15 on the way in (:func:`smw_tools.graphics.masked_tiles`),
so a masked tile shows colour 0 and 8-15 and an unmasked one 0-7. An edit is
settled to what its tile can show (:func:`settle`) before it is written, so
the file holds what the level will draw.

Qt-free, like every module a document lives in.
"""

from __future__ import annotations

from collections.abc import Callable, Sequence
from dataclasses import dataclass

from shiny_mushroom.graphics import (
    KEYWORD,
    Colour,
    GraphicsError,
    read_png,
    redmean,
    rgba_line,
    write_png,
)
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level import BLOCK, TILE, Geometry, Raster, palette, snes_color
from shiny_mushroom.level_graphics import ANIMATED_TILES
from shiny_mushroom.pixel_edit import Cell as SurfaceCell
from shiny_mushroom.pixel_edit import Surface, flip_tile
from shiny_mushroom.rom_patches import SLOT_VRAM
from smw_tools import graphics as codec
from smw_tools.graphics import SLOT_BYTES, TILE_PIXELS, TILE_SIDE, TileFormat
from smw_tools.level_graphics import LAYER_SLOTS, SLOTS

__all__ = [
    "AREA_KIND",
    "Area",
    "Cell",
    "cells_of",
    "Edits",
    "FileTiles",
    "LevelTiles",
    "LevelTilesError",
    "export_png",
    "file_edits",
    "import_pixels",
    "import_png",
    "raster",
    "read_area",
    "settle",
    "showable",
    "surface_of",
    "surface_of_file",
    "tiles_of_file",
]


class LevelTilesError(GraphicsError):
    """An area's picture could not be read, or its edit could not be
    written as one set of tiles."""


#: Cells across and down a block: a Map16 block is four 8x8 tiles.
CELLS_PER_BLOCK = BLOCK // TILE

#: The bytes one 4bpp VRAM tile takes, which is how a word's tile number
#: indexes VRAM.
TILE_BYTES = TileFormat.PLANAR_4BPP.tile_bytes

#: Palette rows a layer word can name, and the colours in one.
PALETTE_ROWS = 8
ROW_COLOURS = 16

#: What an area's PNG records itself as, under ``shiny-mushroom``: the
#: ``kind`` a file's own sheet does not carry, so the two cannot be read
#: into each other by mistake.
AREA_KIND = "level-area"


@dataclass(frozen=True)
class Area:
    """A rectangle of blocks on Layer 1 or Layer 2: its top-left corner and
    its size, in blocks, and which layer it is on."""

    column: int
    row: int
    columns: int
    rows: int
    #: Which layer the blocks are on, 1 or 2. Layer 2's words come out of
    #: the other tilemap and the other definitions, and its shape is that
    #: layer's own -- a 32x27 pattern for a background
    #: (:func:`shiny_mushroom.level.layer2_shape`) -- which is whoever
    #: answers :attr:`~shiny_mushroom.ui.level_tiles_pane.TilesHost.words`
    #: to know. Both layers draw their tiles from the same four layer
    #: slots, so the chain back from a word is the same.
    layer: int = 1

    @property
    def cells(self) -> tuple[int, int]:
        """The area's size in 8x8 cells, across and down."""
        return self.columns * CELLS_PER_BLOCK, self.rows * CELLS_PER_BLOCK

    def clipped(self, shape: Geometry) -> Area | None:
        """This area held within ``shape``, or ``None`` where none of it
        lies on the level."""
        left = max(0, self.column)
        top = max(0, self.row)
        right = min(shape.columns, self.column + self.columns)
        bottom = min(shape.rows, self.row + self.rows)
        if right <= left or bottom <= top:
            return None
        return Area(left, top, right - left, bottom - top, self.layer)

    @classmethod
    def of_pixels(cls, left: int, top: int, right: int, bottom: int) -> Area:
        """The blocks a box of level pixels covers -- the far edge inclusive,
        as a dragged box is recorded."""
        first_column, first_row = left // BLOCK, top // BLOCK
        last_column, last_row = right // BLOCK, bottom // BLOCK
        return cls(
            first_column,
            first_row,
            last_column - first_column + 1,
            last_row - first_row + 1,
        )

    @classmethod
    def of_layer2(cls, shape: Geometry) -> Area:
        """The whole of a Layer 2 whose shape is ``shape``."""
        return cls(0, 0, shape.columns, shape.rows, 2)

    def describe(self) -> str:
        text = (
            f"{self.columns} x {self.rows} blocks at "
            f"({hexnum(self.column, 2)}, {hexnum(self.row, 2)})"
        )
        return f"Layer 2, {text}" if self.layer == 2 else text


@dataclass(frozen=True)
class Cell:
    """One 8x8 tile of the area: the word that placed it, where in VRAM and
    in which file it is, and its pixels as the level shows them."""

    #: The tilemap word, ``YXPCCCTT TTTTTTTT``.
    word: int
    #: Which of the four layer slots the tile is in, or ``None`` for a tile
    #: number past them.
    slot: int | None
    #: The tile's index within its slot -- and so within its file -- or the
    #: whole tile number when it is in no slot.
    index: int
    #: The file the slot holds, or ``None`` where the cartridge could not
    #: say or the tile is in no slot.
    file: int | None
    #: Whether an edit to this cell has a file tile to go to.
    editable: bool
    #: The 64 colour indices VRAM holds for the tile, flipped as the word
    #: flips them: what the level draws, row by row.
    pixels: bytes

    @property
    def tile(self) -> int:
        return self.word & 0x03FF

    @property
    def palette(self) -> int:
        """The word's palette row, 0-7."""
        return (self.word >> 10) & 0x07

    @property
    def x_flip(self) -> bool:
        return bool(self.word & 0x4000)

    @property
    def y_flip(self) -> bool:
        return bool(self.word & 0x8000)

    @property
    def source(self) -> tuple[int, int] | None:
        """``(file, index)`` -- where an edit goes -- or ``None``."""
        if not self.editable or self.file is None:
            return None
        return self.file, self.index

    def describe(self) -> str:
        """``tile $1A3: FG2 GFX15 tile $23, palette 2, X flip`` -- or why
        the cell is not a file's."""
        flips = ", ".join(
            name
            for name, on in (("X flip", self.x_flip), ("Y flip", self.y_flip))
            if on
        )
        held = f"tile {hexnum(self.tile, 3)}"
        if self.slot is None:
            where = "past the layer slots"
        elif self.file is None:
            where = f"{SLOTS[self.slot]}, file unknown"
        else:
            where = (
                f"{SLOTS[self.slot]} GFX{self.file:02X} tile {hexnum(self.index, 2)}"
            )
            if not self.editable:
                where += ", animated"
        text = f"{held}: {where}, palette {self.palette}"
        return f"{text}, {flips}" if flips else text


@dataclass(frozen=True)
class LevelTiles:
    """An area read into its cells, in reading order across the area."""

    area: Area
    #: The area's cells, :attr:`columns` to a row.
    cells: tuple[Cell, ...]
    #: The four layer slots' files as the row has them, ``None`` where the
    #: cartridge could not say.
    files: tuple[int | None, ...]
    #: The level's backdrop, 15-bit BGR -- what colour 0 shows.
    backdrop: int
    #: The level's CGRAM, 512 bytes.
    cgram: bytes

    @property
    def columns(self) -> int:
        return self.area.cells[0]

    @property
    def rows(self) -> int:
        return self.area.cells[1]

    @property
    def width(self) -> int:
        return self.columns * TILE_SIDE

    @property
    def height(self) -> int:
        return self.rows * TILE_SIDE

    def colour(self, row: int, index: int) -> Colour:
        """What palette ``row``'s colour ``index`` draws as: the backdrop for
        colour 0, since a transparent pixel shows the PPU's fixed colour and
        never CGRAM's own."""
        if index == 0:
            return _colour(snes_color(self.backdrop))
        return _colour(palette(self.cgram)[row * ROW_COLOURS + index])

    def summary(self) -> str:
        """``24 x 6 blocks at ($10, $14): 288 tiles, 250 editable``, with the
        reasons for the rest where there are any."""
        total = len(self.cells)
        editable = sum(1 for cell in self.cells if cell.editable)
        text = f"{self.area.describe()}: {total} tiles, {editable} editable"
        if editable == total:
            return text
        reasons = []
        animated = sum(
            1
            for cell in self.cells
            if cell.slot is not None and cell.file is not None and not cell.editable
        )
        past = sum(1 for cell in self.cells if cell.slot is None)
        unknown = sum(
            1 for cell in self.cells if cell.slot is not None and cell.file is None
        )
        if animated:
            reasons.append(f"{animated} animated")
        if past:
            reasons.append(f"{past} past the layer slots")
        if unknown:
            reasons.append(f"{unknown} in a slot whose file is unknown")
        return f"{text} ({', '.join(reasons)})"


def _colour(rgb: bytes) -> Colour:
    return rgb[0], rgb[1], rgb[2]


# -- reading an area ----------------------------------------------------------


def read_area(
    area: Area,
    words: Sequence[int],
    vram: bytes,
    cgram: bytes,
    backdrop: int,
    files: Sequence[int | None],
) -> LevelTiles:
    """The area's cells from its blocks' ``words`` -- four per block in
    storage order, upper-left, lower-left, upper-right, lower-right, block
    after block across each row of the area -- read out of ``vram`` under
    the slots' ``files`` (the row's four layer entries, in slot order).

    The words come from whoever holds the level
    (:meth:`shiny_mushroom.level.Blocks.words`), since which definition a
    block reads and which pipe table a column chose are the renderer's
    decisions and are made once, there.
    """
    across, down = area.cells
    wanted = area.columns * area.rows * 4
    if len(words) != wanted:
        raise LevelTilesError(
            f"{area.describe()} is {wanted} tilemap words, not {len(words)}"
        )
    grid: list[Cell | None] = [None] * (across * down)
    for block, at in enumerate(range(0, len(words), 4)):
        column, row = block % area.columns, block // area.columns
        upper_left, lower_left, upper_right, lower_right = words[at : at + 4]
        placed = (
            (0, 0, upper_left),
            (0, 1, lower_left),
            (1, 0, upper_right),
            (1, 1, lower_right),
        )
        for dx, dy, word in placed:
            x = column * CELLS_PER_BLOCK + dx
            y = row * CELLS_PER_BLOCK + dy
            grid[y * across + x] = _cell(word, vram, files)
    cells = tuple(cell for cell in grid if cell is not None)
    return LevelTiles(area, cells, tuple(files[:LAYER_SLOTS]), backdrop, bytes(cgram))


def _cell(word: int, vram: bytes, files: Sequence[int | None]) -> Cell:
    tile = word & 0x03FF
    at = tile * TILE_BYTES
    held = vram[at : at + TILE_BYTES].ljust(TILE_BYTES, b"\x00")
    pixels = flip_tile(
        codec.decode_tiles(TileFormat.PLANAR_4BPP, held)[0],
        bool(word & 0x4000),
        bool(word & 0x8000),
    )
    slot = next(
        (
            n
            for n, base in enumerate(SLOT_VRAM[:LAYER_SLOTS])
            if base <= at < base + SLOT_BYTES
        ),
        None,
    )
    if slot is None:
        return Cell(word, None, tile, None, False, pixels)
    index = (at - SLOT_VRAM[slot]) // TILE_BYTES
    file = files[slot] if slot < len(files) else None
    editable = file is not None and index not in ANIMATED_TILES[slot]
    return Cell(word, slot, index, file, editable, pixels)


# -- the surface the pixel editor paints ---------------------------------------


def surface_of(tiles: LevelTiles, read: Callable[[int], FileTiles | None]) -> Surface:
    """The area as a :class:`~shiny_mushroom.pixel_edit.Surface`: each cell
    drawing its file tile, keyed ``(file, index)``, through the word's flips
    and palette row -- so painting one cell of a tile repaints every cell the
    area draws it in. A cell with no file tile to go to, or whose file
    ``read`` cannot give, keeps its pixels and takes no paint; the indices a
    cell may hold are what its tile can show (:func:`showable`), so the pen
    lands as the file will store it.
    """
    files: dict[int, FileTiles | None] = {}
    store: dict[tuple[int, int], bytes] = {}
    cells: list[SurfaceCell] = []
    for cell in tiles.cells:
        source = cell.source
        held = None
        if source is not None:
            number, index = source
            if number not in files:
                files[number] = read(number)
            held = files[number]
            if held is None or index >= len(held.tiles):
                source = None
        if source is None or held is None:
            cells.append(SurfaceCell(None, cell.palette, own=cell.pixels))
            continue
        upright = flip_tile(cell.pixels, cell.x_flip, cell.y_flip)
        store.setdefault(source, upright)
        cells.append(
            SurfaceCell(
                source,
                cell.palette,
                cell.x_flip,
                cell.y_flip,
                showable(held.format, held.is_masked(source[1])),
            )
        )
    palette = tuple(
        tuple(tiles.colour(row, index) for index in range(ROW_COLOURS))
        for row in range(PALETTE_ROWS)
    )
    return Surface(tiles.columns, tiles.rows, tuple(cells), store, palette)


def surface_of_file(held: FileTiles, row: int, cgram: bytes, backdrop: int) -> Surface:
    """File ``held``'s sheet as a surface, sixteen tiles to a row under
    palette ``row`` of ``cgram`` -- the shape the Graphics window draws a
    file in, each cell its own tile keyed ``(file, index)``. The tiles are
    held as VRAM shows them, the uploader's bit 3 on a masked tile's
    coloured pixels, so the pen lands as the level draws it; a short last
    row is padded with cells nobody may paint."""
    columns = 16
    rows = -(-len(held.tiles) // columns) or 1
    cells: list[SurfaceCell] = []
    store: dict[tuple[int, int], bytes] = {}
    for index, tile in enumerate(held.tiles):
        masked = held.is_masked(index)
        shown = tile
        if held.format is not TileFormat.PLANAR_4BPP and masked:
            shown = bytes(pixel | 8 if pixel else 0 for pixel in tile)
        store[(held.number, index)] = shown
        cells.append(
            SurfaceCell(
                (held.number, index), row, allowed=showable(held.format, masked)
            )
        )
    while len(cells) < columns * rows:
        cells.append(SurfaceCell(None, row))
    colours = palette(cgram)
    back = _colour(snes_color(backdrop))
    palette_rows = tuple(
        tuple(
            back if index == 0 else _colour(colours[r * ROW_COLOURS + index])
            for index in range(ROW_COLOURS)
        )
        for r in range(len(colours) // ROW_COLOURS)
    )
    return Surface(columns, rows, tuple(cells), store, palette_rows)


def tiles_of_file(surface: Surface, held: FileTiles) -> list[bytes]:
    """File ``held``'s tiles as ``surface`` now draws them, in the file's own
    indices -- the uploader's bit 3 taken back off a masked tile -- the
    whole file, ready to save."""
    return [
        _file_index(
            held.format,
            held.is_masked(index),
            surface.tiles.get((held.number, index), tile),
        )
        for index, tile in enumerate(held.tiles)
    ]


def cells_of(surface: Surface, tiles: LevelTiles) -> list[bytes]:
    """The area's cells as ``surface`` now draws them -- 64 VRAM-space
    indices each, flipped as the level shows them, the shape
    :func:`file_edits` takes -- with a cell the surface could not edit
    handed back as ``tiles`` read it."""
    if (surface.columns, surface.rows) != (tiles.columns, tiles.rows):
        raise LevelTilesError(
            f"the surface is {surface.columns}x{surface.rows} cells, and this "
            f"area is {tiles.columns}x{tiles.rows}"
        )
    return [
        surface.cell_pixels(n) if surface.cells[n].editable else cell.pixels
        for n, cell in enumerate(tiles.cells)
    ]


# -- the picture --------------------------------------------------------------


def raster(tiles: LevelTiles, indices: bool = False) -> Raster:
    """The area as the level draws it: each cell under its own palette row,
    colour 0 the backdrop. With ``indices``, each pixel's colour index as
    its grey level instead -- the picture a hatch is cut from."""
    width = tiles.width
    lines = [bytearray(width * 3) for _ in range(tiles.height)]
    colours: dict[tuple[int, int], bytes] = {}
    for n, cell in enumerate(tiles.cells):
        left = (n % tiles.columns) * TILE_SIDE
        top = (n // tiles.columns) * TILE_SIDE
        for y in range(TILE_SIDE):
            line = lines[top + y]
            for x in range(TILE_SIDE):
                index = cell.pixels[y * TILE_SIDE + x]
                if indices:
                    rgb = bytes((index, index, index))
                else:
                    key = (cell.palette, index)
                    rgb = colours.get(key)
                    if rgb is None:
                        rgb = colours[key] = bytes(tiles.colour(*key))
                at = (left + x) * 3
                line[at : at + 3] = rgb
    return Raster(width, tiles.height, b"".join(bytes(line) for line in lines))


# -- PNG is a spelling ---------------------------------------------------------


def _entries(tiles: LevelTiles) -> list[Colour]:
    """The 128 colours an area's PNG carries: the eight layer rows in order,
    colour 0 of each the backdrop. A pixel's value is ``row * 16 + index``,
    so the picture keeps every index exactly and still draws in a viewer as
    the level does."""
    return [
        tiles.colour(row, index)
        for row in range(PALETTE_ROWS)
        for index in range(ROW_COLOURS)
    ]


def export_png(tiles: LevelTiles, name: str = "") -> bytes:
    """The area as an indexed PNG, 128 colours: the eight palette rows in
    order, so the pixel value is the row and the index at once
    (:func:`_entries`). The ``shiny-mushroom`` text names it an area of
    ``name`` and gives its size in cells, which :func:`import_png` checks."""
    width = tiles.width
    scanlines = []
    for y in range(tiles.height):
        line = bytearray(width)
        cell_row = y // TILE_SIDE
        within = (y % TILE_SIDE) * TILE_SIDE
        for column in range(tiles.columns):
            cell = tiles.cells[cell_row * tiles.columns + column]
            base = cell.palette * ROW_COLOURS
            at = column * TILE_SIDE
            line[at : at + TILE_SIDE] = bytes(
                base + index for index in cell.pixels[within : within + TILE_SIDE]
            )
        scanlines.append(bytes(line))
    text = (f"name={name};kind={AREA_KIND};cells={tiles.columns}x{tiles.rows}").encode(
        "latin-1"
    )
    plte = b"".join(bytes(colour) for colour in _entries(tiles))
    return write_png(
        width,
        tiles.height,
        3,
        8,
        scanlines,
        [(b"PLTE", plte), (b"tEXt", KEYWORD + b"\0" + text)],
    )


def import_png(png: bytes, tiles: LevelTiles) -> list[bytes]:
    """The cells a PNG spells for this area, as 64 VRAM-space indices each --
    still flipped as the level shows them, and not yet settled to what each
    cell's file can hold (:func:`file_edits` does both).

    A picture this module exported is read by its values: the row half of
    each says which palette row the pixel was painted from, and a pixel
    painted from the cell's own row keeps its index exactly. A pixel painted
    from another row, and every pixel of any other picture -- one an editor
    flattened, or one that was never an area -- is matched by colour: the
    baseline's index where the colour is still what that index draws, the
    nearest of the row's colours otherwise (:func:`_match`).

    The picture must be the area's own size. One that records itself as a
    file's sheet, or as an area of another size, is refused as the wrong
    kind of picture.
    """
    picture = read_png(png)
    _check_kind(picture.text, tiles)
    if (picture.width, picture.height) != (tiles.width, tiles.height):
        raise LevelTilesError(
            f"the picture is {picture.width}x{picture.height}, and this area "
            f"is {tiles.width}x{tiles.height}"
        )
    own = picture.colour_type == 3 and AREA_KIND in picture.text
    if own:
        plte = picture.palette
        rows = [
            _indexed_line(line, plte, tiles, y) for y, line in enumerate(picture.rows)
        ]
        return _cells_from(rows, tiles, indexed=True)
    rows = [rgba_line(line, picture.channels, picture.width) for line in picture.rows]
    if picture.colour_type == 3:
        rows = [_paletted(line, picture.palette) for line in picture.rows]
    return _cells_from(rows, tiles, indexed=False)


def import_pixels(
    pixels: bytes, width: int, height: int, tiles: LevelTiles
) -> list[bytes]:
    """The cells a picture of plain pixels spells -- ``pixels`` RGBA, four
    bytes each, rows top to bottom: the clipboard's bitmap, matched by colour
    as :func:`import_png` matches a flattened picture."""
    if len(pixels) != width * height * 4:
        raise LevelTilesError(
            f"the picture is {width}x{height} and {len(pixels):,} bytes, not "
            f"the {width * height * 4:,} four bytes a pixel makes"
        )
    if (width, height) != (tiles.width, tiles.height):
        raise LevelTilesError(
            f"the picture is {width}x{height}, and this area is "
            f"{tiles.width}x{tiles.height}"
        )
    rows = [bytes(pixels[y * width * 4 : (y + 1) * width * 4]) for y in range(height)]
    return _cells_from(rows, tiles, indexed=False)


def _check_kind(text: str, tiles: LevelTiles) -> None:
    if not text:
        return
    recorded = dict(part.split("=", 1) for part in text.split(";") if "=" in part)
    if "format" in recorded or "tiles" in recorded:
        origin = recorded.get("name") or "a file"
        raise LevelTilesError(
            f"PNG was exported from {origin}'s own sheet, not from an area of a level"
        )
    cells = recorded.get("cells")
    wanted = f"{tiles.columns}x{tiles.rows}"
    if cells is not None and cells != wanted:
        raise LevelTilesError(
            f"PNG was exported from an area of {cells} tiles, and this one is {wanted}"
        )


def _paletted(line: bytes, plte: bytes) -> bytes:
    """An indexed scanline as RGBA through its own palette, opaque."""
    out = bytearray(len(line) * 4)
    for x, value in enumerate(line):
        at = value * 3
        out[x * 4 : x * 4 + 3] = plte[at : at + 3].ljust(3, b"\x00")
        out[x * 4 + 3] = 255
    return bytes(out)


def _indexed_line(line: bytes, plte: bytes, tiles: LevelTiles, y: int) -> bytes:
    """One of an area PNG's own scanlines as ``(value, r, g, b, a)`` runs --
    the value kept beside the colour, so a pixel from the cell's own row is
    read exactly and any other by colour."""
    out = bytearray(len(line) * 5)
    for x, value in enumerate(line):
        at = value * 3
        out[x * 5] = value
        out[x * 5 + 1 : x * 5 + 4] = plte[at : at + 3].ljust(3, b"\x00")
        out[x * 5 + 4] = 255
    return bytes(out)


def _cells_from(rows: Sequence[bytes], tiles: LevelTiles, indexed: bool) -> list[bytes]:
    """Scanlines into the cells they cross: five bytes a pixel with a value
    in front when ``indexed``, four RGBA otherwise."""
    step = 5 if indexed else 4
    out = [bytearray(TILE_PIXELS) for _ in tiles.cells]
    nearest: dict[tuple[int, Colour], int] = {}
    for y, line in enumerate(rows):
        cell_row = y // TILE_SIDE
        within = (y % TILE_SIDE) * TILE_SIDE
        for x in range(tiles.width):
            n = cell_row * tiles.columns + x // TILE_SIDE
            cell = tiles.cells[n]
            at = within + x % TILE_SIDE
            pixel = line[x * step : (x + 1) * step]
            if indexed:
                value = pixel[0]
                if value // ROW_COLOURS == cell.palette:
                    out[n][at] = value % ROW_COLOURS
                    continue
                pixel = pixel[1:]
            out[n][at] = _match(
                tiles,
                cell.palette,
                (pixel[0], pixel[1], pixel[2]),
                pixel[3],
                cell.pixels[at],
                nearest,
            )
    return [bytes(cell) for cell in out]


def _match(
    tiles: LevelTiles,
    row: int,
    colour: Colour,
    alpha: int,
    base_index: int,
    nearest: dict[tuple[int, Colour], int],
) -> int:
    """One pixel's index under palette ``row``: 0 for a transparent one, the
    baseline's index where the colour is still what that draws, the nearest
    of the row's sixteen otherwise."""
    if alpha == 0:
        return 0
    if tiles.colour(row, base_index) == colour:
        return base_index
    found = nearest.get((row, colour))
    if found is None:
        found = min(
            range(ROW_COLOURS),
            key=lambda index: redmean(colour, tiles.colour(row, index)),
        )
        nearest[(row, colour)] = found
    return found


# -- writing the edit back -----------------------------------------------------


@dataclass(frozen=True)
class FileTiles:
    """One graphics file as an edit needs it: its layout, its tiles as the
    project holds them, and which of them the uploader masks -- every tile
    (``None``), some, or none."""

    number: int
    format: TileFormat
    tiles: tuple[bytes, ...]
    masked: frozenset[int] | None

    def is_masked(self, index: int) -> bool:
        return self.masked is None or index in self.masked


def showable(fmt: TileFormat, masked: bool) -> tuple[int, ...]:
    """The VRAM indices a tile of this kind can show: all sixteen for a 4bpp
    file; 0 and 8-15 for a masked 3bpp tile, whose non-zero pixels the
    uploader moves up; 0-7 for an unmasked one."""
    if fmt is TileFormat.PLANAR_4BPP:
        return tuple(range(ROW_COLOURS))
    if masked:
        return (0, *range(8, ROW_COLOURS))
    return tuple(range(8))


def settle(
    tiles: LevelTiles, cell: Cell, pixels: bytes, fmt: TileFormat, masked: bool
) -> bytes:
    """``pixels`` as the cell's tile can show them: an index the tile cannot
    hold becomes the showable one nearest it in colour, under the cell's
    own palette row."""
    allowed = showable(fmt, masked)
    if len(allowed) == ROW_COLOURS:
        return pixels
    keep = set(allowed)
    moved: dict[int, int] = {}
    out = bytearray(pixels)
    for at, index in enumerate(pixels):
        if index in keep:
            continue
        found = moved.get(index)
        if found is None:
            colour = tiles.colour(cell.palette, index)
            found = min(
                allowed,
                key=lambda other: redmean(colour, tiles.colour(cell.palette, other)),
            )
            moved[index] = found
        out[at] = found
    return bytes(out)


def _file_index(fmt: TileFormat, masked: bool, pixels: bytes) -> bytes:
    """Settled VRAM-space pixels as the file stores them: a 3bpp file keeps
    three bits, the uploader's bit 3 taken back off a masked tile."""
    if fmt is TileFormat.PLANAR_4BPP:
        return pixels
    return bytes(index & 0x07 for index in pixels) if masked else pixels


@dataclass(frozen=True)
class Edits:
    """What an area's edit writes: each file's tiles, whole, for the files
    that changed; how many file tiles that moves; and the count of cells
    that changed, and of those whose change had nowhere to go."""

    files: dict[int, list[bytes]]
    written: int
    changed: int
    dropped: int


def file_edits(
    tiles: LevelTiles,
    cells: Sequence[bytes],
    read: Callable[[int], FileTiles | None],
) -> Edits:
    """The tiles ``cells`` -- one 64-index picture per cell, as
    :func:`import_png` hands them back -- write into the files, through
    ``read`` for each file the area touches.

    Each cell's pixels are unflipped into the file's own orientation and
    settled to what its tile can show; a cell that then matches the file's
    tile changes nothing. **A tile the area shows more than once** takes one
    edit: the cells that still match the file win nothing, a cell that
    changed it wins, and two cells that changed it differently are refused
    together as a :class:`LevelTilesError` naming the tile -- the picture
    cannot say which of them was meant. A cell with no file tile to go to
    (:attr:`Cell.editable`, or a file ``read`` could not give) is counted as
    dropped rather than refused, so the rest of the edit still lands.
    """
    if len(cells) != len(tiles.cells):
        raise LevelTilesError(
            f"the area is {len(tiles.cells)} cells, and the edit is {len(cells)}"
        )
    files: dict[int, FileTiles | None] = {}
    proposals: dict[tuple[int, int], dict[bytes, int]] = {}
    changed = dropped = 0
    for cell, pixels in zip(tiles.cells, cells, strict=True):
        if pixels == cell.pixels:
            continue
        changed += 1
        source = cell.source
        if source is None:
            dropped += 1
            continue
        number, index = source
        if number not in files:
            files[number] = read(number)
        held = files[number]
        if held is None or index >= len(held.tiles):
            dropped += 1
            continue
        masked = held.is_masked(index)
        upright = flip_tile(pixels, cell.x_flip, cell.y_flip)
        stored = _file_index(
            held.format, masked, settle(tiles, cell, upright, held.format, masked)
        )
        if stored == held.tiles[index]:
            continue
        counts = proposals.setdefault((number, index), {})
        counts[stored] = counts.get(stored, 0) + 1
    conflicts = [
        f"GFX{number:02X} tile {hexnum(index, 2)} ({len(counts)} ways)"
        for (number, index), counts in sorted(proposals.items())
        if len(counts) > 1
    ]
    if conflicts:
        shown = ", ".join(conflicts[:6])
        more = f" and {len(conflicts) - 6} more" if len(conflicts) > 6 else ""
        raise LevelTilesError(
            f"the area draws the same tile in more than one place, and the "
            f"picture edits it differently in each: {shown}{more}. Make the "
            f"copies agree, or edit one of them alone."
        )
    out: dict[int, list[bytes]] = {}
    for (number, index), counts in proposals.items():
        held = files[number]
        assert held is not None
        if number not in out:
            out[number] = list(held.tiles)
        (stored,) = counts
        out[number][index] = stored
    return Edits(out, len(proposals), changed, dropped)
