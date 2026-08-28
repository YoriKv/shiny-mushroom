"""The marks the editor draws over a cell that is not ordinary art.

Three of them, one per thing the editor has to say without words, and all
three here so that the same statement looks the same wherever it is made:

:func:`hatch` -- **this is not yours to change.** Offset diagonals over the
picture, which stays readable under them: a palette swatch the game's own
code writes (:mod:`shiny_mushroom.ui.palette_grid`), a VRAM tile the animated
tiles own whatever file a slot names (:mod:`shiny_mushroom.ui.vram_slots`).
*This is on screen because it is what the level has, and nothing you do here
moves it.*

:func:`hatch_unused` -- **there is nothing here.** The cell is blanked to the
window's own colour and ruled: a Map16 block the tileset leaves undefined
(:mod:`shiny_mushroom.ui.cell_grid`). Not the same statement as the first,
and not drawn like it -- what is under it is not art being withheld, it is
the absence of art, so nothing shows through.

:func:`transparent_brush` -- **this pixel is transparent.** A checkerboard,
under colour 0 of a tile sheet (:mod:`shiny_mushroom.ui.tile_sheet`). The
first two say what a *reader* may do; this one says what a *pixel is*.

**The diagonals are drawn twice, dark then light one pixel along.** One
colour of line disappears into whatever it lands on, and these are drawn over
pictures that hold every colour -- a black hatch over a black swatch, or over
the dark half of a tile, is no hatch at all. Two offset lines cost one more
pass and are legible on both.

**A set of cells is hatched in one pass, not one pass each.** :func:`hatch`
takes a ``QRegion`` as readily as a rectangle, and rules its bounding box
through it: the diagonals then run on across the whole set rather than
restarting at every cell, which is both the cheaper drawing and the one that
reads as a single marked area.
"""

from __future__ import annotations

from PySide6.QtCore import QRect, Qt
from PySide6.QtGui import QBrush, QColor, QImage, QPainter, QPalette, QPen, QRegion

#: How far apart the diagonals are, in widget pixels. Close enough to read as
#: a texture over a swatch of twenty, open enough to leave what is under it
#: recognisable.
HATCH_STEP = 4

#: The two inks and how far each is shifted, in the order they go down. Both
#: are half-transparent, so what is hatched keeps its own colour.
HATCH_INKS: tuple[tuple[int, QColor], ...] = (
    (0, QColor(0, 0, 0, 130)),
    (1, QColor(255, 255, 255, 130)),
)

#: The two greys of the transparency checkerboard, and how large one square of
#: it is in the *picture's* own pixels -- half a tile, so it scales with the
#: sheet and a tile is always four squares across.
#:
#: A square rather than one of Qt's dither patterns, which are cut at one
#: pixel: at a sheet's zooms a per-pixel dither reads as noise laid over the
#: art rather than as the absence of art, which is the one thing it is there
#: to say.
CLEAR_LIGHT = QColor(0xB0, 0xB0, 0xB0)
CLEAR_DARK = QColor(0x98, 0x98, 0x98)
CLEAR_SQUARE = 4

#: The checkerboard, built once and shared -- see :func:`transparent_brush`.
_clear: QBrush | None = None


def hatch(painter: QPainter, where: QRect | QRegion, step: int = HATCH_STEP) -> None:
    """Rule ``where`` with diagonals: *not yours to change*.

    ``where`` may be one rectangle or a whole ``QRegion`` of them. Either way
    the drawing is clipped to it, so a caller may hatch part of a picture
    without touching the rest, and it leaves the painter as it found it. A
    region is ruled in one pass, its diagonals running on across every cell in
    it rather than restarting at each.
    """
    area = where if isinstance(where, QRegion) else QRegion(where)
    bounds = area.boundingRect()
    painter.save()
    painter.setClipRegion(area)
    for shift, colour in HATCH_INKS:
        painter.setPen(QPen(colour, 1))
        for start in range(0, bounds.width() + bounds.height(), step):
            painter.drawLine(
                bounds.left() + start + shift,
                bounds.top(),
                bounds.left() + shift,
                bounds.top() + start,
            )
    painter.restore()


def hatch_unused(painter: QPainter, where: QRect, palette: QPalette) -> None:
    """Blank ``where`` and rule it: *there is nothing here*.

    Drawn in the palette's own inks rather than fixed ones, unlike
    :func:`hatch`: nothing shows through, so there is no picture for a colour
    of line to disappear into and the mark can be the window's.
    """
    painter.fillRect(where, palette.window().color())
    painter.fillRect(where, QBrush(palette.mid().color(), Qt.BrushStyle.BDiagPattern))


def transparent_brush() -> QBrush:
    """The checkerboard colour 0 of a tile sheet is painted with: *transparent*.

    Built on first use rather than at import: a texture is a picture, and a
    module that paints one while it is being imported is a module that cannot
    be imported without the graphics stack up.
    """
    global _clear
    if _clear is None:
        side = CLEAR_SQUARE * 2
        texture = QImage(side, side, QImage.Format.Format_RGB32)
        texture.fill(CLEAR_LIGHT)
        painter = QPainter(texture)
        square = CLEAR_SQUARE
        painter.fillRect(square, 0, square, square, CLEAR_DARK)
        painter.fillRect(0, square, square, square, CLEAR_DARK)
        painter.end()
        _clear = QBrush(texture)
    return _clear


__all__ = [
    "CLEAR_DARK",
    "CLEAR_LIGHT",
    "CLEAR_SQUARE",
    "HATCH_INKS",
    "HATCH_STEP",
    "hatch",
    "hatch_unused",
    "transparent_brush",
]
