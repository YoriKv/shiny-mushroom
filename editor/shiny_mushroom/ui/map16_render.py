"""The Map16 editor's pictures: the sheet of 512 blocks, one block, and the
level's VRAM under a palette row.

Split out of the dialog (:mod:`shiny_mushroom.ui.map16_dialog`) because a
raster is not a window: what these need is a snapshot's VRAM and CGRAM and a
way of reading a definition, so they can be built -- and read back pixel by
pixel -- with no dialog around them.

**The definitions come from the tables being edited, not from the capture.**
:class:`~shiny_mushroom.level.Blocks` reads a snapshot; :class:`Viewed` is a
snapshot whose definitions are somebody else's, which is what lets an edit in
hand be drawn before it is saved.

**A sheet is redrawn a block at a time where one block moved.** Rendering all
512 is ~17 ms, which is a keystroke's worth of lag on a spin box that steps;
:func:`blit_block` paints the one block that changed into the sheet already
on screen.
"""

from __future__ import annotations

from collections.abc import Callable

from PySide6.QtGui import QImage, QPainter

from shiny_mushroom.level import BLOCK, TILE, Blocks, Raster
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.map16 import TILE_COUNT
from shiny_mushroom.ui.render import raster_to_image

#: The sheet's shape: sixteen blocks a row, as Lunar Magic pages them.
SHEET_COLUMNS = 16
#: The picker's: sixteen 8x8 tiles a row, 1024 of them in a level's VRAM.
PICKER_COLUMNS = 16
VRAM_TILES = 0x400


class Viewed:
    """A snapshot whose definitions are the held tables' -- what
    :class:`~shiny_mushroom.level.Blocks` reads: ``definition``, ``vram``,
    ``cgram`` and ``back_area_color`` and nothing else."""

    def __init__(
        self, snapshot: LevelSnapshot, definition: Callable[[int], bytes]
    ) -> None:
        self.vram = snapshot.vram
        self.cgram = snapshot.cgram
        self.back_area_color = snapshot.back_area_color
        self.definition = definition
        self.layer2_definition = definition


def sheet_image(viewed: Viewed) -> QImage:
    """The whole tileset: :data:`TILE_COUNT` blocks,
    :data:`SHEET_COLUMNS` to a row."""
    blocks = Blocks(viewed)
    lines: list[bytes] = []
    for row in range(TILE_COUNT // SHEET_COLUMNS):
        drawn = [
            blocks.rows(row * SHEET_COLUMNS + column) for column in range(SHEET_COLUMNS)
        ]
        lines.extend(b"".join(block[y] for block in drawn) for y in range(BLOCK))
    return raster_to_image(
        Raster(
            SHEET_COLUMNS * BLOCK, TILE_COUNT // SHEET_COLUMNS * BLOCK, b"".join(lines)
        )
    )


def blit_block(sheet: QImage, viewed: Viewed, tile: int) -> None:
    """Redraw ``tile`` where it sits in ``sheet``, leaving the other 511
    blocks alone -- what an edit to one definition costs."""
    rows = Blocks(viewed).rows(tile)
    block = raster_to_image(Raster(BLOCK, BLOCK, b"".join(rows)))
    painter = QPainter(sheet)
    painter.drawImage(
        tile % SHEET_COLUMNS * BLOCK, tile // SHEET_COLUMNS * BLOCK, block
    )
    painter.end()


def block_image(snapshot: LevelSnapshot, raw: bytes) -> QImage:
    """One block on its own, drawn from ``raw`` -- the definition under the
    editor's fields, which may be one nobody has committed."""
    rows = Blocks(Viewed(snapshot, lambda _: raw)).rows(0)
    return raster_to_image(Raster(BLOCK, BLOCK, b"".join(rows)))


def picker_image(viewed: Viewed, palette: int) -> QImage:
    """The level's whole VRAM as 8x8 tiles under one palette row --
    :data:`VRAM_TILES` of them, :data:`PICKER_COLUMNS` to a row."""
    blocks = Blocks(viewed)
    lines: list[bytes] = []
    for row in range(VRAM_TILES // PICKER_COLUMNS):
        tiles = [
            blocks.tile_rows((row * PICKER_COLUMNS + column) | (palette << 10))
            for column in range(PICKER_COLUMNS)
        ]
        lines.extend(b"".join(tile[y] for tile in tiles) for y in range(TILE))
    return raster_to_image(
        Raster(
            PICKER_COLUMNS * TILE,
            VRAM_TILES // PICKER_COLUMNS * TILE,
            b"".join(lines),
        )
    )


__all__ = [
    "PICKER_COLUMNS",
    "SHEET_COLUMNS",
    "VRAM_TILES",
    "Viewed",
    "blit_block",
    "block_image",
    "picker_image",
    "sheet_image",
]
