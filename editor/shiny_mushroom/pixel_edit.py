"""Pixel editing over a surface of tiles: the picture, the tools' geometry,
and the rule that an edit to a tile is an edit to every cell that shows it.

A :class:`Surface` is a rectangle of 8x8 cells, each drawn from a **tile** --
a key into one shared store of 64-index pictures -- through its own flips and
its own palette row. The level's tiles are that shape
(:func:`shiny_mushroom.level_tiles.surface_of`): an area of Layer 1 draws
the same VRAM tile in many places, mirrored and recoloured, and a change to
the tile is what the level will show everywhere it is drawn. So the surface
keeps the tile once and every cell reads through it: painting a pixel of one
cell writes the tile, and every other cell showing that tile has moved by the
time the picture is next composed. A cell with no tile of its own -- an
animated tile, one past the files -- keeps its own pixels and takes no paint.

The shape tools return **coordinates**, never pixels (:func:`line`,
:func:`rect_outline`, :func:`rect_filled`, :func:`ellipse_outline`,
:func:`ellipse_filled`, :func:`flood_fill`); the caller pairs them with the
pen and hands the pairs to :meth:`Surface.painted`. That is what makes the
mask one rule -- a selection clips the coordinates before they reach the
surface -- and keeps the fill's walk apart from the write, so a fill of the
colour already there paints nothing and costs no step.

**A surface is immutable, and every operation returns a new one or ``self``.**
Undo is :class:`shiny_mushroom.edit.History` over it, which recognises a
no-op by identity, exactly as it does over a level.

Qt-free, like every module a document lives in.
"""

from __future__ import annotations

from collections.abc import Hashable, Iterable, Iterator, Mapping
from dataclasses import dataclass, field

from shiny_mushroom.graphics import Colour, redmean
from smw_tools.graphics import TILE_PIXELS, TILE_SIDE

__all__ = [
    "Cell",
    "Coord",
    "Region",
    "Surface",
    "ellipse_filled",
    "ellipse_outline",
    "flip_tile",
    "flood_fill",
    "line",
    "rect_filled",
    "rect_outline",
]

Coord = tuple[int, int]

#: Colours in one palette row, and how many rows a surface may draw through.
ROW_COLOURS = 16


# -- tiles ----------------------------------------------------------------------


def flip_tile(pixels: bytes, x_flip: bool, y_flip: bool) -> bytes:
    """``pixels`` -- 64 indices, row by row -- with the flips applied. Each
    flip is its own inverse, so this both puts a word's flips on and takes
    them off."""
    if not (x_flip or y_flip):
        return pixels
    rows = [pixels[y * TILE_SIDE : (y + 1) * TILE_SIDE] for y in range(TILE_SIDE)]
    if x_flip:
        rows = [row[::-1] for row in rows]
    if y_flip:
        rows.reverse()
    return b"".join(rows)


# -- the shapes -----------------------------------------------------------------


def line(x0: int, y0: int, x1: int, y1: int) -> list[Coord]:
    """Every pixel on the segment from ``(x0, y0)`` to ``(x1, y1)``, both
    ends included -- Bresenham's, which is also what joins one pencil sample
    to the next so a fast stroke leaves no gaps."""
    dx = abs(x1 - x0)
    dy = -abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx + dy
    pixels: list[Coord] = []
    while True:
        pixels.append((x0, y0))
        if x0 == x1 and y0 == y1:
            return pixels
        e2 = 2 * err
        if e2 >= dy:
            err += dy
            x0 += sx
        if e2 <= dx:
            err += dx
            y0 += sy


def _bounds(x0: int, y0: int, x1: int, y1: int) -> tuple[int, int, int, int]:
    """A drag's two corners as ``(left, top, right, bottom)``."""
    if x0 > x1:
        x0, x1 = x1, x0
    if y0 > y1:
        y0, y1 = y1, y0
    return x0, y0, x1, y1


def rect_outline(x0: int, y0: int, x1: int, y1: int) -> list[Coord]:
    """The one-pixel border of the rectangle the drag spans, corners in."""
    x0, y0, x1, y1 = _bounds(x0, y0, x1, y1)
    pixels: list[Coord] = []
    for x in range(x0, x1 + 1):
        pixels.append((x, y0))
        if y1 != y0:
            pixels.append((x, y1))
    for y in range(y0 + 1, y1):
        pixels.append((x0, y))
        if x1 != x0:
            pixels.append((x1, y))
    return pixels


def rect_filled(x0: int, y0: int, x1: int, y1: int) -> list[Coord]:
    """Every pixel inside and on the rectangle the drag spans."""
    x0, y0, x1, y1 = _bounds(x0, y0, x1, y1)
    return [(x, y) for y in range(y0, y1 + 1) for x in range(x0, x1 + 1)]


def ellipse_outline(x0: int, y0: int, x1: int, y1: int) -> list[Coord]:
    """The ellipse inscribed in the drag's box, one pixel thick.

    Zingl's integer bounding-box ellipse: it takes the box's corners rather
    than a centre and two radii, so an even or odd extent and a box one
    pixel thin all come out right without a fractional centre.
    """
    x0, y0, x1, y1 = _bounds(x0, y0, x1, y1)
    a = x1 - x0
    b = y1 - y0
    b1 = b & 1
    dx = 4 * (1 - a) * b * b
    dy = 4 * (b1 + 1) * a * a
    err = dx + dy + b1 * a * a
    y0 += (b + 1) // 2
    y1 = y0 - b1
    a8 = 8 * a * a
    b8 = 8 * b * b
    pixels: list[Coord] = []
    while x0 <= x1:
        pixels.append((x1, y0))
        pixels.append((x0, y0))
        pixels.append((x0, y1))
        pixels.append((x1, y1))
        e2 = 2 * err
        if e2 <= dy:
            y0 += 1
            y1 -= 1
            dy += a8
            err += dy
        if e2 >= dx or 2 * err > dy:
            x0 += 1
            x1 -= 1
            dx += b8
            err += dx
    # A flat ellipse stops the loop early; walk the tips it left.
    while y0 - y1 <= b:
        pixels.append((x0 - 1, y0))
        pixels.append((x1 + 1, y0))
        y0 += 1
        pixels.append((x0 - 1, y1))
        pixels.append((x1 + 1, y1))
        y1 -= 1
    return pixels


def ellipse_filled(x0: int, y0: int, x1: int, y1: int) -> list[Coord]:
    """The filled ellipse: each scanline from the outline's leftmost pixel
    on that row to its rightmost, so the fill sits exactly inside the same
    curve :func:`ellipse_outline` draws."""
    spans: dict[int, tuple[int, int]] = {}
    for x, y in ellipse_outline(x0, y0, x1, y1):
        lo, hi = spans.get(y, (x, x))
        spans[y] = (min(lo, x), max(hi, x))
    pixels: list[Coord] = []
    for y, (lo, hi) in spans.items():
        pixels.extend((x, y) for x in range(lo, hi + 1))
    return pixels


def flood_fill(
    surface: Surface, x: int, y: int, bounds: tuple[int, int, int, int] | None = None
) -> list[Coord]:
    """Every pixel of the 4-connected region of ``surface`` that shows the
    index under ``(x, y)``.

    A scanline seed fill -- spans rather than a pixel a call, so a flat
    region the size of the picture cannot blow the stack. It reads and
    returns; the caller paints, which is what lets a fill be one step and a
    fill in the colour already there be none.

    ``bounds`` -- ``(left, top, right, bottom)``, inclusive -- confines the
    walk: a selection is the fill's edge, so a region that leaves the box and
    comes back does not drag the outside in, and a seed outside the box fills
    nothing.
    """
    w, h = surface.width, surface.height
    x0, y0, x1, y1 = bounds if bounds is not None else (0, 0, w - 1, h - 1)
    x0, y0 = max(0, x0), max(0, y0)
    x1, y1 = min(w - 1, x1), min(h - 1, y1)
    if not (x0 <= x <= x1 and y0 <= y <= y1):
        return []
    picture = surface.indices()
    target = picture[y * w + x]
    visited = bytearray(w * h)
    pixels: list[Coord] = []
    stack: list[Coord] = [(x, y)]
    while stack:
        sx, sy = stack.pop()
        if visited[sy * w + sx]:
            continue
        line_at = sy * w
        left = sx
        while (
            left > x0
            and not visited[line_at + left - 1]
            and picture[line_at + left - 1] == target
        ):
            left -= 1
        right = sx
        while (
            right < x1
            and not visited[line_at + right + 1]
            and picture[line_at + right + 1] == target
        ):
            right += 1
        for px in range(left, right + 1):
            visited[line_at + px] = 1
            pixels.append((px, sy))
        for px in range(left, right + 1):
            for ny in (sy - 1, sy + 1):
                if (
                    y0 <= ny <= y1
                    and not visited[ny * w + px]
                    and picture[ny * w + px] == target
                ):
                    stack.append((px, ny))
    return pixels


# -- a rectangle of pixels on its own --------------------------------------------


@dataclass(frozen=True)
class Region:
    """A ``width`` x ``height`` rectangle of colour indices, row by row: what
    a selection lifts off the surface, and what a paste puts back. Owned by
    nobody -- a region has no tiles, no rows, and no flips."""

    width: int
    height: int
    pixels: bytes

    def __post_init__(self) -> None:
        if len(self.pixels) != self.width * self.height:
            raise ValueError(
                f"a {self.width}x{self.height} region is {self.width * self.height} "
                f"pixels, not {len(self.pixels)}"
            )

    def get(self, x: int, y: int) -> int:
        return self.pixels[y * self.width + x]

    def rows(self) -> list[bytes]:
        w = self.width
        return [self.pixels[y * w : (y + 1) * w] for y in range(self.height)]

    def flipped_h(self) -> Region:
        return Region(self.width, self.height, b"".join(r[::-1] for r in self.rows()))

    def flipped_v(self) -> Region:
        return Region(self.width, self.height, b"".join(reversed(self.rows())))

    def transposed(self) -> Region:
        rows = self.rows()
        return Region(
            self.height,
            self.width,
            bytes(rows[y][x] for x in range(self.width) for y in range(self.height)),
        )

    def rotated_cw(self) -> Region:
        return self.flipped_v().transposed()

    def rotated_ccw(self) -> Region:
        return self.flipped_h().transposed()


# -- the surface ----------------------------------------------------------------


@dataclass(frozen=True)
class Cell:
    """One 8x8 cell of a surface: which tile it draws, how, and through which
    palette row.

    ``tile`` is the key of the tile in the surface's store, or ``None`` for a
    cell that is shown but not anyone's to change, whose pixels are then
    ``own``. ``allowed`` is the indices the tile can hold -- ``None`` for all
    sixteen -- so a pen carrying an index the file cannot store lands as the
    nearest colour it can (:meth:`Surface.painted`).
    """

    tile: Hashable | None
    row: int
    x_flip: bool = False
    y_flip: bool = False
    allowed: tuple[int, ...] | None = None
    own: bytes = field(default=b"\x00" * TILE_PIXELS, repr=False)

    @property
    def editable(self) -> bool:
        return self.tile is not None

    def local(self, lx: int, ly: int) -> int:
        """The offset into the tile's own pixels for the cell's pixel
        ``(lx, ly)`` -- the flips taken back off."""
        if self.x_flip:
            lx = TILE_SIDE - 1 - lx
        if self.y_flip:
            ly = TILE_SIDE - 1 - ly
        return ly * TILE_SIDE + lx


@dataclass(frozen=True)
class Surface:
    """``columns`` x ``rows`` cells drawn out of ``tiles``, under ``palette``
    -- eight rows of sixteen colours, or however many the cells name.

    ``tiles`` is read and never written; :meth:`painted` hands back a surface
    holding a new store with the changed tiles replaced.
    """

    columns: int
    rows: int
    cells: tuple[Cell, ...]
    tiles: Mapping[Hashable, bytes]
    palette: tuple[tuple[Colour, ...], ...]

    def __post_init__(self) -> None:
        wanted = self.columns * self.rows
        if len(self.cells) != wanted:
            raise ValueError(
                f"a {self.columns}x{self.rows} surface is {wanted} cells, "
                f"not {len(self.cells)}"
            )

    # -- geometry ----------------------------------------------------------------

    @property
    def width(self) -> int:
        return self.columns * TILE_SIDE

    @property
    def height(self) -> int:
        return self.rows * TILE_SIDE

    def contains(self, x: int, y: int) -> bool:
        return 0 <= x < self.width and 0 <= y < self.height

    def cell_index(self, x: int, y: int) -> int:
        """Which cell the pixel ``(x, y)`` is in."""
        return (y // TILE_SIDE) * self.columns + x // TILE_SIDE

    def cell_at(self, x: int, y: int) -> Cell:
        return self.cells[self.cell_index(x, y)]

    def cells_showing(self, tile: Hashable) -> tuple[int, ...]:
        """The indices of every cell drawing ``tile`` -- the cells an edit to
        one of them reaches."""
        return tuple(n for n, cell in enumerate(self.cells) if cell.tile == tile)

    # -- reading -----------------------------------------------------------------

    def cell_pixels(self, n: int) -> bytes:
        """Cell ``n``'s 64 indices as it is drawn: its tile through its flips,
        or its own pixels."""
        cell = self.cells[n]
        if cell.tile is None:
            return cell.own
        return flip_tile(self.tiles[cell.tile], cell.x_flip, cell.y_flip)

    def get(self, x: int, y: int) -> int:
        """The colour index shown at ``(x, y)``."""
        cell = self.cell_at(x, y)
        at = cell.local(x % TILE_SIDE, y % TILE_SIDE)
        source = cell.own if cell.tile is None else self.tiles[cell.tile]
        return source[at]

    def editable(self, x: int, y: int) -> bool:
        return self.contains(x, y) and self.cell_at(x, y).editable

    def colour(self, row: int, index: int) -> Colour:
        return self.palette[row][index]

    def colour_at(self, x: int, y: int) -> Colour:
        return self.colour(self.cell_at(x, y).row, self.get(x, y))

    def indices(self) -> bytes:
        """The picture as one index a pixel, row by row -- the colour index
        alone, whatever row the cell draws it through."""
        w = self.width
        out = bytearray(w * self.height)
        for n in range(len(self.cells)):
            pixels = self.cell_pixels(n)
            left = (n % self.columns) * TILE_SIDE
            top = (n // self.columns) * TILE_SIDE
            for y in range(TILE_SIDE):
                at = (top + y) * w + left
                out[at : at + TILE_SIDE] = pixels[y * TILE_SIDE : (y + 1) * TILE_SIDE]
        return bytes(out)

    def paletted(self) -> bytes:
        """The picture as one byte a pixel, ``row * 16 + index``: an indexed
        image over :meth:`colour_table`, which is how it is drawn without
        composing a colour per pixel."""
        w = self.width
        out = bytearray(w * self.height)
        tables = {
            row: bytes(range(row * ROW_COLOURS, (row + 1) * ROW_COLOURS))
            + bytes(range(ROW_COLOURS, 256))
            for row in range(len(self.palette))
        }
        for n, cell in enumerate(self.cells):
            pixels = self.cell_pixels(n).translate(tables[cell.row])
            left = (n % self.columns) * TILE_SIDE
            top = (n // self.columns) * TILE_SIDE
            for y in range(TILE_SIDE):
                at = (top + y) * w + left
                out[at : at + TILE_SIDE] = pixels[y * TILE_SIDE : (y + 1) * TILE_SIDE]
        return bytes(out)

    def colour_table(self) -> tuple[Colour, ...]:
        """The colours :meth:`paletted` indexes: every row's sixteen, in
        order."""
        return tuple(colour for row in self.palette for colour in row)

    def region(self, x: int, y: int, width: int, height: int) -> Region:
        """The rectangle at ``(x, y)`` as its own picture; what falls outside
        the surface is index 0.

        Read a cell row at a time rather than a pixel at a time: a float is
        lifted and laid down again on every move of a drag, and a marquee
        can be the whole picture.
        """
        width, height = max(0, width), max(0, height)
        out = bytearray(width * height)
        for _cell, cx, cy, left, top, right, bottom in self._cells_under(
            x, y, width, height
        ):
            pixels = self.cell_pixels(cy * self.columns + cx)
            lx0, lx1 = left - cx * TILE_SIDE, right - cx * TILE_SIDE
            for py in range(top, bottom):
                ly = py - cy * TILE_SIDE
                at = (py - y) * width + (left - x)
                out[at : at + lx1 - lx0] = pixels[
                    ly * TILE_SIDE + lx0 : ly * TILE_SIDE + lx1
                ]
        return Region(width, height, bytes(out))

    def _cells_under(
        self, x: int, y: int, width: int, height: int
    ) -> Iterator[tuple[Cell, int, int, int, int, int, int]]:
        """Every cell the rectangle touches, with the part of it that lies
        on the cell: the cell, its column and row, and the rectangle's
        ``left, top, right, bottom`` (exclusive) clipped to the cell."""
        x0, y0 = max(x, 0), max(y, 0)
        x1, y1 = min(x + width, self.width), min(y + height, self.height)
        if x0 >= x1 or y0 >= y1:
            return
        for cy in range(y0 // TILE_SIDE, (y1 - 1) // TILE_SIDE + 1):
            for cx in range(x0 // TILE_SIDE, (x1 - 1) // TILE_SIDE + 1):
                yield (
                    self.cells[cy * self.columns + cx],
                    cx,
                    cy,
                    max(cx * TILE_SIDE, x0),
                    max(cy * TILE_SIDE, y0),
                    min(cx * TILE_SIDE + TILE_SIDE, x1),
                    min(cy * TILE_SIDE + TILE_SIDE, y1),
                )

    # -- writing -----------------------------------------------------------------

    def painted(self, strokes: Iterable[tuple[int, int, int]]) -> Surface:
        """This surface with each ``(x, y, index)`` written -- into the tile
        the pixel's cell draws, so every cell showing that tile moves with
        it. ``self`` when nothing changed.

        A pixel off the surface, or on a cell that is not a tile's, is left
        alone. An index the cell's tile cannot hold is settled to the
        allowed index nearest it in colour under that cell's own row, so
        what is shown is what the file will hold. Where two strokes reach
        the same pixel of one tile, the last wins.
        """
        changed: dict[Hashable, bytearray] = {}
        settled: dict[tuple[int, tuple[int, ...], int], int] = {}
        for x, y, index in strokes:
            if not self.contains(x, y):
                continue
            cell = self.cell_at(x, y)
            if cell.tile is None:
                continue
            if cell.allowed is not None and index not in cell.allowed:
                key = (cell.row, cell.allowed, index)
                found = settled.get(key)
                if found is None:
                    found = settled[key] = self.landing_index(cell, index)
                index = found
            tile = changed.get(cell.tile)
            if tile is None:
                tile = changed[cell.tile] = bytearray(self.tiles[cell.tile])
            tile[cell.local(x % TILE_SIDE, y % TILE_SIDE)] = index
        return self._with_changed(changed)

    def landing_index(self, cell: Cell, index: int) -> int:
        """What ``index`` lands as on ``cell``: itself where the tile can
        hold it, else the allowed index nearest it in colour under the
        cell's row."""
        if cell.allowed is None or index in cell.allowed:
            return index
        wanted = self.colour(cell.row, index)
        return min(
            cell.allowed,
            key=lambda other: redmean(wanted, self.colour(cell.row, other)),
        )

    def filled(self, pixels: Iterable[Coord], index: int) -> Surface:
        """Every pixel of ``pixels`` painted ``index``."""
        return self.painted((x, y, index) for x, y in pixels)

    def cleared(self, x: int, y: int, width: int, height: int) -> Surface:
        """The rectangle at ``(x, y)`` painted index 0 -- what a cut leaves."""
        width, height = max(0, width), max(0, height)
        return self.blitted(Region(width, height, bytes(width * height)), x, y)

    def blitted(self, region: Region, x: int, y: int) -> Surface:
        """``region`` laid down with its top-left at ``(x, y)`` -- what a
        floating selection writes when it lands. Every rule of
        :meth:`painted` holds; it is written a cell row at a time, since a
        float is laid down on every move of a drag."""
        changed: dict[Hashable, bytearray] = {}
        tables: dict[tuple[int, tuple[int, ...] | None], bytes | None] = {}
        w = region.width
        for cell, cx, cy, left, top, right, bottom in self._cells_under(
            x, y, w, region.height
        ):
            if cell.tile is None:
                continue
            key = (cell.row, cell.allowed)
            if key not in tables:
                tables[key] = self._settling_table(cell)
            table = tables[key]
            tile = changed.get(cell.tile)
            if tile is None:
                tile = changed[cell.tile] = bytearray(self.tiles[cell.tile])
            lx0, lx1 = left - cx * TILE_SIDE, right - cx * TILE_SIDE
            if cell.x_flip:
                lx0, lx1 = TILE_SIDE - lx1, TILE_SIDE - lx0
            for py in range(top, bottom):
                at = (py - y) * w + (left - x)
                span = region.pixels[at : at + right - left]
                if table is not None:
                    span = span.translate(table)
                if cell.x_flip:
                    span = span[::-1]
                ly = py - cy * TILE_SIDE
                if cell.y_flip:
                    ly = TILE_SIDE - 1 - ly
                tile[ly * TILE_SIDE + lx0 : ly * TILE_SIDE + lx1] = span
        return self._with_changed(changed)

    def _settling_table(self, cell: Cell) -> bytes | None:
        """A translation of every index to the one it lands as on ``cell``,
        or ``None`` where the tile holds all sixteen."""
        if cell.allowed is None:
            return None
        return bytes(
            self.landing_index(cell, i) if i < ROW_COLOURS else i for i in range(256)
        )

    def _with_changed(self, changed: Mapping[Hashable, bytearray]) -> Surface:
        moved = {
            key: bytes(tile)
            for key, tile in changed.items()
            if bytes(tile) != self.tiles[key]
        }
        if not moved:
            return self
        return Surface(
            self.columns, self.rows, self.cells, {**self.tiles, **moved}, self.palette
        )

    def with_colour(self, row: int, index: int, colour: Colour) -> Surface:
        """This surface with palette ``row``'s ``index`` drawn as ``colour``
        -- the same tiles, recoloured. ``self`` when it already is."""
        if self.palette[row][index] == tuple(colour):
            return self
        colours = list(self.palette[row])
        colours[index] = tuple(colour)
        palette = list(self.palette)
        palette[row] = tuple(colours)
        return Surface(self.columns, self.rows, self.cells, self.tiles, tuple(palette))

    def with_tiles(self, tiles: Mapping[Hashable, bytes]) -> Surface:
        """This surface over another store -- the same cells reading fresh
        tiles, which is what a re-read after a save hands over."""
        return Surface(self.columns, self.rows, self.cells, dict(tiles), self.palette)
