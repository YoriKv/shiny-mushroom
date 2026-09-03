"""Turning bytes into something the canvas can paint.

Two views live here, and the split between them is deliberate. The byte map is
format-free: it maps each byte to a shade of gray, which is not an
interpretation of anything - it is the view you want *before* you know how a
region is encoded, because structure shows up in it anyway (a run of $FF
padding, the diagonal banding of tile data, the flat blocks of a table).

The level view is the opposite: it knows exactly what it is looking at. The
decoding itself is not here, though - :mod:`shiny_mushroom.level` does that with
no Qt in it, and this module only wraps the result. Every per-format renderer
that lands later should split the same way, so that what is being read stays
testable without a display.
"""

from __future__ import annotations

from collections.abc import Sequence

from PySide6.QtGui import QImage, qRgb

from shiny_mushroom.graphics import Colour
from shiny_mushroom.level import Raster

# Wide enough that tile-shaped data lines up at 8, 16 and 32 pixels per row, and
# narrow enough to scroll rather than sprawl at 1x.
DEFAULT_WIDTH = 256


def bytes_to_image(data: bytes, width: int = DEFAULT_WIDTH) -> QImage:
    """Render ``data`` as a grayscale byte map, ``width`` bytes per row.

    A short final row is padded with zeroes: QImage reads a rectangle, and
    handing it a buffer that stops mid-row reads past the end of the allocation.
    """
    if width <= 0:
        raise ValueError(f"width must be positive, got {width}")
    if not data:
        return QImage()
    height = -(-len(data) // width)
    padded = data.ljust(height * width, b"\x00")
    # QImage does *not* copy the buffer it is handed - it points into it, and
    # PySide will free the temporary as soon as this function returns, leaving
    # the image reading freed memory. `.copy()` gives it storage it owns.
    return QImage(padded, width, height, width, QImage.Format.Format_Grayscale8).copy()


def raster_to_image(raster: Raster) -> QImage:
    """Wrap a decoded :class:`~shiny_mushroom.level.Raster` as a ``QImage``.

    The convenience for a caller that still holds one. **The window does not**:
    it paints the sprites and the player marker into a mutable copy of the
    decoded pixels and patches blocks into that same buffer as an edit moves
    them, so what it has to hand over is a buffer and a size rather than a
    raster -- :func:`pixels_to_image` below.
    """
    return pixels_to_image(raster.pixels, raster.width, raster.height)


def pixels_to_image(pixels, width: int, height: int) -> QImage:  # noqa: ANN001
    """The same from any RGB888 buffer, so a picture being drawn into
    repeatedly does not have to be copied to a ``bytes`` first.

    The stride is passed explicitly. Qt aligns its own scanlines to four bytes,
    and three bytes per pixel means most widths are not a multiple of that - so
    a QImage left to infer its stride reads the wrong byte for every row after
    the first and shears the picture diagonally.
    """
    if not pixels:
        return QImage()
    return QImage(
        pixels,
        width,
        height,
        width * 3,
        QImage.Format.Format_RGB888,
    ).copy()


def paletted_to_image(
    pixels: bytes, width: int, height: int, colours: Sequence[Colour]
) -> QImage:
    """One byte a pixel over a colour table: the pixel editor's picture,
    where a pixel is ``row * 16 + index`` and the table is every row's
    sixteen (:meth:`shiny_mushroom.pixel_edit.Surface.paletted`). The
    colours ride on the image, so the pixels are composed once and never
    per colour.

    The stride is explicit for the reason :func:`pixels_to_image` gives, and
    the table goes on the copy: it is a property of the image that owns its
    storage, not of the wrapper over a buffer about to be freed.
    """
    if not pixels:
        return QImage()
    image = QImage(pixels, width, height, width, QImage.Format.Format_Indexed8).copy()
    image.setColorTable([qRgb(r, g, b) for r, g, b in colours])
    return image
