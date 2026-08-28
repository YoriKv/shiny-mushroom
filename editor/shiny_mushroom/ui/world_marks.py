"""What a Layer 1 tile does, drawn as a mark -- the world map's key, once.

The map wears these marks over the map itself
(:mod:`shiny_mushroom.ui.overworld_mode`) and the tile palette wears them over
its thumbnails, so a teal diagonal means "steps off to another map" wherever
it is met. The colours, the stroke weights and the words live here because one
fact shown in two keys is two facts to learn.

The **hues are one key; the shapes are not quite**. A map cell has room for
the numbers a level carries and marks them in place, where a thumbnail is
thirty-two pixels of artwork that is most of why one tile is picked over
another -- so the palette says the same things in the corners: an orange badge
top-left for a level tile, which the map says with the level's own number in
that corner. What is being said is the same; where there is room to say it is
not. A **warp** is the one mark that is the same shape in both: the magenta
wedge in the top-right corner, drawn into the thumbnail here and stroked over
the cell as an overlay, because there is no number to say it with and a mark
learnt in one key should be the mark met in the other.

Nothing here holds a model. It is handed a Map16 number -- the tilemap's own
byte -- and answers a colour, a sentence, or a marked copy of a picture; what
the number came from is the caller's business.
"""

from __future__ import annotations

from PySide6.QtCore import QPointF, QRectF, Qt
from PySide6.QtGui import QColor, QImage, QPainter, QPen, QPolygonF

from shiny_mushroom.level import BLOCK
from shiny_mushroom.overworld import (
    DESTROYED_CASTLE_TILE,
    MAP_EXIT_TILES,
    UNUSED_PIPE_TILE,
    TileFunction,
    is_level_tile,
    path_step,
    tile_function,
)
from shiny_mushroom.ui.canvas import SCREEN_NOTE_COLOR
from shiny_mushroom.ui.overlays import SELECTION_LINE

# A path tile draws its own step vector as a segment -- a diagonal path as a
# diagonal -- in a hue per function. The four have to be told apart at the
# width of a thin stroke, which needs a wider gap than a filled shape does:
# a near-white for plain ground paths (no hue at all, because that is the
# plain case), true blue for the swimming ones, violet for the climbing
# three, and teal where stepping onto the tile walks the player off to
# another map. Blue and teal are the closest pair, at fifty degrees of hue;
# anything between the two reads as one colour at a glance.
PATH_MARK_COLOR = QColor(0xD2, 0xD2, 0xD2)
WATER_MARK_COLOR = QColor(0x2E, 0x78, 0xFF)
CLIMB_MARK_COLOR = QColor(0xC0, 0x60, 0xFF)
EXIT_MARK_COLOR = QColor(0x00, 0xD0, 0x90)

#: A warp tile's hue -- the star and the two pipes. A destination, not a
#: line, so both keys wear it as the corner wedge rather than as a stroke.
WARP_MARK_COLOR = QColor(0xFF, 0x50, 0xE0)

#: A level tile's hue: the screen notes' orange, which already means "a
#: readout about this spot" everywhere else in the editor -- opaque here,
#: where the map's label wears it as a wash. A badge is a solid mark on a
#: picture the size of a thumbnail; a wash at that size is a smudge.
LEVEL_MARK_COLOR = QColor(SCREEN_NOTE_COLOR.rgb())

#: The two stroke weights of a mark, in device pixels: the black understroke
#: and the coloured line over it.
MARK_UNDER_WIDTH = 5.6
MARK_LINE_WIDTH = 2.4

#: Which hue each kind of path is stroked in. Off this table a tile carries no
#: path, whatever else it does.
_PATH_HUES = {
    TileFunction.PATH: PATH_MARK_COLOR,
    TileFunction.WATER_PATH: WATER_MARK_COLOR,
    TileFunction.CLIMB: CLIMB_MARK_COLOR,
}

#: How much of a thumbnail's side the corner marks take.
_BADGE = 5 / BLOCK

#: How long the warp wedge's legs are, as a fraction of the tile's side. One
#: number for both keys: the map hands it to the overlay
#: (:attr:`~shiny_mushroom.ui.canvas.Overlay.wedge`) against a 16-pixel cell,
#: the palette paints it into a thumbnail of whatever size the dock is showing,
#: and the triangle comes out the same triangle at both scales. Larger than a
#: badge because a triangle of a given side covers half of what a square does.
WARP_WEDGE = _BADGE * 1.4


def path_hue(tile: int) -> QColor | None:
    """The colour ``tile``'s path is stroked in -- ``None`` where it carries
    no path.

    Teal wherever stepping onto the tile leaves the map, whatever kind of
    path it is: where a step *goes* outranks how it is walked.
    """
    hue = _PATH_HUES.get(tile_function(tile))
    if hue is None:
        return None
    return EXIT_MARK_COLOR if tile in MAP_EXIT_TILES else hue


def tile_note(tile: int) -> str:
    """What the walker does with ``tile``, in words -- the palette's tooltip
    line. The function first, then what is true beside it."""
    notes = [tile_function(tile).value]
    if tile in MAP_EXIT_TILES:
        notes.append("steps off to another map")
    if tile == DESTROYED_CASTLE_TILE:
        notes.append("entered with L+R outside Japan")
    if tile == UNUSED_PIPE_TILE:
        notes.append("unused")
    return ", ".join(notes)


def marked_tile(image: QImage, tile: int) -> QImage:
    """``image`` with ``tile``'s function drawn over it, or ``image`` itself
    where the tile is decoration.

    A thumbnail rather than the map, so the marks are painted into the pixels
    instead of over them at a fixed device weight -- but a path keeps the
    map's weights and its own step vector, scaled by how much larger than a
    block the thumbnail is, so a tile shown at twice the console's pixels
    wears the line the map wears at 2x. A level and a warp go to their
    corners, where they cover artwork the middle of the picture would.

    The destroyed castle wears no badge though the walker enters it: the
    translevel scan hands it no number, and a badge that means "a level is
    here" would be claiming one. :func:`tile_note` says what it is instead.
    """
    hue = path_hue(tile)
    function = tile_function(tile)
    warp = function in (TileFunction.STAR_WARP, TileFunction.PIPE_WARP)
    level = is_level_tile(tile)
    if hue is None and not warp and not level:
        return image

    marked = image.convertToFormat(QImage.Format.Format_ARGB32_Premultiplied)
    side = min(marked.width(), marked.height())
    painter = QPainter(marked)
    if hue is not None:
        step = path_step(tile)
        assert step is not None  # every path tile has a step
        _stroke_step(painter, marked, step, side / BLOCK, hue)
    if level:
        _draw_badge(painter, side, function)
    if warp:
        _draw_wedge(painter, marked, side)
    painter.end()
    return marked


def _stroke_step(
    painter: QPainter,
    image: QImage,
    step: tuple[int, int],
    scale: float,
    hue: QColor,
) -> None:
    """The step vector through the picture's centre, worn twice: the black
    understroke, then the colour over it -- the map's two lines."""
    center = QPointF(image.width() / 2, image.height() / 2)
    half = QPointF(step[0] * scale / 2, step[1] * scale / 2)
    painter.setRenderHint(QPainter.RenderHint.Antialiasing, True)
    for color, width in ((SELECTION_LINE, MARK_UNDER_WIDTH), (hue, MARK_LINE_WIDTH)):
        pen = QPen(color, width)
        pen.setCapStyle(Qt.PenCapStyle.RoundCap)
        painter.setPen(pen)
        painter.drawLine(center - half, center + half)
    painter.setRenderHint(QPainter.RenderHint.Antialiasing, False)


def _draw_badge(painter: QPainter, side: float, function: TileFunction) -> None:
    """The level badge: a filled corner square, the paths' blue where the
    level is stood on swimming and the levels' orange otherwise.

    The corner the map puts the level *number* in, because that is the corner
    a reader already looks to for "which level is this" -- there is no number
    to put there in a palette of tiles, where a tile is not yet anywhere.
    """
    color = (
        WATER_MARK_COLOR if function is TileFunction.WATER_LEVEL else LEVEL_MARK_COLOR
    )
    badge = QRectF(1.0, 1.0, side * _BADGE, side * _BADGE)
    painter.setPen(QPen(SELECTION_LINE, 1.0))
    painter.setBrush(color)
    painter.drawRect(badge)
    painter.setBrush(Qt.BrushStyle.NoBrush)


def _draw_wedge(painter: QPainter, image: QImage, side: float) -> None:
    """The warp wedge: a filled triangle in the top-right corner.

    A corner rather than the middle, where a box sat over the artwork that is
    most of why a tile is picked -- and the corner opposite the level badge,
    because the star and the pipe are both, and two marks about one tile have
    to sit apart to both be read. A triangle rather than a second square: what
    a mark *is* should be readable without comparing its colour to the one in
    the other corner. The map strokes the same triangle over the cell, at the
    same :data:`WARP_WEDGE` of the side.
    """
    reach = side * WARP_WEDGE
    right, top = image.width() - 1.0, 1.0
    wedge = QPolygonF(
        [
            QPointF(right - reach, top),
            QPointF(right, top),
            QPointF(right, top + reach),
        ]
    )
    painter.setRenderHint(QPainter.RenderHint.Antialiasing, True)
    painter.setPen(QPen(SELECTION_LINE, 1.0))
    painter.setBrush(WARP_MARK_COLOR)
    painter.drawPolygon(wedge)
    painter.setBrush(Qt.BrushStyle.NoBrush)
    painter.setRenderHint(QPainter.RenderHint.Antialiasing, False)
