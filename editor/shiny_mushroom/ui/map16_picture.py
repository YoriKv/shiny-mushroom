"""The Map16 environment's canvas picture, and its VRAM picker's cache.

The sheet of 512 blocks held as one image and patched a block at a time
(:func:`shiny_mushroom.ui.map16_render.blit_block` -- rendering all 512 is a
keystroke's worth of lag), with the all-``$FF`` unused definitions hatched
into the picture itself: the hatch is a fact about the bytes, so it travels
with them. The tint over the tileset-specific runs is *not* baked in -- it is
scenery the canvas draws as overlays, and :data:`TILESET_RUN_RECTS` is their
geometry.

The picker cache keeps one rendered VRAM sheet per palette row, dropped
whole whenever the VRAM or the tables behind it move.
"""

from __future__ import annotations

from PySide6.QtCore import QRect
from PySide6.QtGui import QBrush, QColor, QImage, QPainter, Qt

from shiny_mushroom.level import BLOCK
from shiny_mushroom.map16 import DEF_SIZE, TILE_COUNT, TILESET_RUNS
from shiny_mushroom.ui.map16_render import (
    SHEET_COLUMNS,
    Viewed,
    blit_block,
    picker_image,
    sheet_image,
)
from shiny_mushroom.ui.map16_words import PALETTE_MASK, X_FLIP_MASK, Y_FLIP_MASK

#: The all-$FF definition, which the sheet hatches as *there is nothing here*.
UNUSED = b"\xff" * DEF_SIZE

#: The hatch's inks: fixed, not the widget palette's, because the sheet is an
#: image on the canvas rather than a widget with a palette of its own.
_UNUSED_FILL = QColor(0x60, 0x60, 0x60)
_UNUSED_LINES = QColor(0x80, 0x80, 0x80)


def _block_rect(tile: int) -> QRect:
    return QRect(
        tile % SHEET_COLUMNS * BLOCK, tile // SHEET_COLUMNS * BLOCK, BLOCK, BLOCK
    )


def _run_rects() -> tuple[QRect, ...]:
    """The tileset-specific runs as row strips of the sheet, in image
    pixels -- what the canvas tints so "this tileset's own" is visible."""
    rects: list[QRect] = []
    for start, stop in TILESET_RUNS:
        tile = start
        while tile < stop:
            row_end = min(stop, (tile // SHEET_COLUMNS + 1) * SHEET_COLUMNS)
            first = _block_rect(tile)
            rects.append(QRect(first.x(), first.y(), (row_end - tile) * BLOCK, BLOCK))
            tile = row_end
    return tuple(rects)


#: Computed once: the runs are the bitmask split and never move.
TILESET_RUN_RECTS: tuple[QRect, ...] = _run_rects()


def hatch_unused(painter: QPainter, rect: QRect) -> None:
    painter.fillRect(rect, _UNUSED_FILL)
    painter.fillRect(rect, QBrush(_UNUSED_LINES, Qt.BrushStyle.BDiagPattern))


class Map16Picture:
    """The sheet, held and patched rather than re-rendered.

    ``render`` draws the whole picture; ``patch`` repaints only the named
    blocks. Both take the unused set from the caller, who holds the tables
    -- the picture knows pixels, not bytes.
    """

    def __init__(self) -> None:
        self._image = QImage()

    @property
    def image(self) -> QImage:
        return self._image

    @property
    def ready(self) -> bool:
        return not self._image.isNull()

    def forget(self) -> None:
        self._image = QImage()

    def render(self, viewed: Viewed, unused: frozenset[int]) -> QImage:
        self._image = sheet_image(viewed)
        painter = QPainter(self._image)
        for tile in unused:
            hatch_unused(painter, _block_rect(tile))
        painter.end()
        return self._image

    def patch(
        self, viewed: Viewed, tiles: frozenset[int], unused: frozenset[int]
    ) -> QImage:
        """Repaint ``tiles`` in place -- or the whole sheet if it was never
        rendered, which a caller need not distinguish."""
        if not self.ready:
            return self.render(viewed, unused)
        for tile in sorted(tiles):
            if not 0 <= tile < TILE_COUNT:
                continue
            blit_block(self._image, viewed, tile)
            if tile in unused:
                painter = QPainter(self._image)
                hatch_unused(painter, _block_rect(tile))
                painter.end()
        return self._image


#: The attribute bits a picker sheet is drawn under: the palette row and
#: the two flips. Priority draws nothing, so a sheet is not kept per it.
PICKER_ATTRIBUTES = PALETTE_MASK | X_FLIP_MASK | Y_FLIP_MASK


class PickerCache:
    """One rendered VRAM picker sheet per set of drawn attributes -- the
    palette row and the flips the hand is arming."""

    def __init__(self) -> None:
        self._images: dict[int, QImage] = {}

    def clear(self) -> None:
        self._images.clear()

    def image(self, viewed: Viewed, attributes: int) -> QImage:
        drawn = attributes & PICKER_ATTRIBUTES
        held = self._images.get(drawn)
        if held is None:
            held = picker_image(viewed, drawn)
            self._images[drawn] = held
        return held
