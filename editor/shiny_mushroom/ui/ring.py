"""The two-tone ring the panel grids mark a selection with.

The canvases draw a selection as marching ants -- see `overlays.py` for why
-- but a panel grid is not a picture: its cells abut, they are small, and a
dashed line over a 16-pixel cell reads as noise rather than as a mark. So
every panel grid -- the Map16 editor's VRAM picker and the tile palettes'
lists -- draws its selection as **one ring in two tones**: a black line
outside a white one, on the cell or the rectangle of cells held, so it shows
on a cell of any colour and stands still. The same ring on every panel, so
the mark reads the same whichever grid it is on; a different mark from the
canvas, because it is a different surface.

A right drag's band is the same ring with the placing colour inside: what it
sweeps becomes a tool, not a selection, as on every canvas.
"""

from __future__ import annotations

from PySide6.QtCore import QRect
from PySide6.QtGui import QColor, QPainter, QPen

from shiny_mushroom.ui.overlays import SELECTION_DASH, SELECTION_LINE


def draw_ring(painter: QPainter, where: QRect, inner: QColor = SELECTION_DASH) -> None:
    """Ring ``where``: a one-pixel :data:`SELECTION_LINE` stroke outside a
    one-pixel ``inner`` one."""
    painter.setPen(QPen(SELECTION_LINE, 1))
    painter.drawRect(where.adjusted(0, 0, -1, -1))
    painter.setPen(QPen(inner, 1))
    painter.drawRect(where.adjusted(1, 1, -2, -2))


__all__ = ["draw_ring"]
