"""The icon set as a *font*: one bundled face, marks rasterized on demand.

The editor's icons are drawn from ``resources/fonts/material-symbols-subset.ttf``
rather than shipped as bitmaps or drawn by hand. One file covers the whole UI,
so reaching for a mark the editor does not draw yet is a codepoint rather than
a new asset; every size rasterizes from outlines, so a 20 px tool button and
the same mark on a 200% display are both crisp.

**The face is a variable font, and the editor draws it light.** Material
Symbols carries a ``wght`` axis, so the icons' stroke weight is a number here
rather than a property of which file was shipped: :data:`_WEIGHT` sets it once
for the app. A solid-weight set reads as heavy furniture next to the artwork
the editor exists to show, and at 20 px a dense mark fills in to a blob. The
other axes (``FILL``, ``GRAD``, ``opsz``) are left at their defaults.

The file ships **subset to the codepoints the editor actually draws**, which is
why a new :class:`~shiny_mushroom.ui.icons.Icon` has to be followed by
``packaging/subset_icon_font.py``: the mark is not in the bundled font until it
is, and until then it draws as nothing.

The face is registered from **bytes**, not a path: in a frozen build the
resources live inside the bundle, where a path-based load has nothing to open.
Registration needs a live ``QApplication``, so it happens on the first icon
rather than at import, and is retried if that first attempt came too early.

What :func:`icon_mask` hands back is a **mask** -- the mark as ink on
transparency -- because that is the shape a themed icon needs. One mask serves
both themes, and a caller that needs a second shade stamps the same mask twice:
:func:`palette_icon` bakes the normal and disabled inks of one action that way.

Marks are fitted by their **ink**, not by the font's metrics. An icon font's
line box is sized for text -- full ascent and descent, the same for every glyph
-- so drawing at ``pixelSize = box`` leaves a wide mark floating in a third of
the square it was given.
"""

from __future__ import annotations

from functools import lru_cache

from PySide6.QtCore import QByteArray, QPointF, QRect, QSize, Qt
from PySide6.QtGui import (
    QColor,
    QFont,
    QFontDatabase,
    QIcon,
    QImage,
    QPainter,
    QPalette,
    QPixmap,
)

from shiny_mushroom import resources
from shiny_mushroom.ui.icons import Icon, PadIcon

#: Any mark the editor can draw. Two enums rather than one because they are
#: two faces with two build steps -- see :mod:`shiny_mushroom.ui.icons`.
AnyIcon = Icon | PadIcon

#: Which face each enum's marks come out of.
_FONT_FILES: dict[type, tuple[str, ...]] = {
    Icon: ("fonts", "material-symbols-subset.ttf"),
    PadIcon: ("fonts", "promptfont-subset.otf"),
}

# The face's ``wght`` axis, which runs 100-700 with 400 the upstream default.
# See the module docstring for why the editor sits below it.
_WEIGHT = 300.0

# How much of its box a mark is allowed to fill. Fitting the ink to the *whole*
# box puts an antialiased edge on the boundary pixel, which reads as an icon
# that has been cut off -- worst in a row of square buttons, which sit close
# enough together to compare. The margin the hand-drawn pictograms these
# replaced had built into each of them, restored here as one number.
_FILL = 0.86

# The box :func:`icon_aspect` measures in. Large enough that the rasterizer's
# rounding onto the pixel grid is noise in the ratio it answers with.
_ASPECT_SAMPLE = 400

# How many render-and-measure passes the fit may take. Two normally land it; the
# cap is what guarantees the loop ends on a face whose rasterizer never settles.
_FIT_PASSES = 5

# The family name Qt reports for each registered face, resolved once. Kept as
# module state rather than an lru_cache so a failed load (no QApplication yet)
# is retried rather than remembered.
_families: dict[type, str] = {}


def icon_font_family(of: type = Icon) -> str | None:
    """The family ``of``'s marks are registered under, or ``None`` if the face
    could not load.

    ``None`` is a face the editor will draw nothing from -- callers fall back to
    an empty mask rather than to the system font, which would render one of
    these codepoints as a tofu box, or worse, as the plain arrow a controller
    mark is spelled with.
    """
    if of not in _families:
        font_id = QFontDatabase.addApplicationFontFromData(
            QByteArray(resources.read_bytes(*_FONT_FILES[of]))
        )
        families = QFontDatabase.applicationFontFamilies(font_id)
        # -1 (no application yet, or a corrupt face) yields an empty list.
        if families:
            _families[of] = families[0]
    return _families.get(of)


def icon_mask(icon: AnyIcon, box: QSize) -> QPixmap:
    """``icon`` as white ink on transparency, fitted and centred in ``box``.

    ``box`` is in **device** pixels: the caller decides the resolution, since it
    is the one that knows the display's scale and has to stamp the ratio onto
    the finished pixmap. White because only the alpha shape survives the stamp.

    The mark is measured **off its own pixels**, not off the font's metrics.
    ``QFontMetricsF.tightBoundingRect`` reports a bounding box that a variable
    face at a non-default axis position does not honour, and centring on that
    leaves marks visibly riding high in their boxes. Rasterizing and finding the
    alpha bounds is exact by construction, for any face and any axis, and the
    finished mark is *copied* into place rather than re-drawn, so what was
    measured is what lands.
    """
    mask = QPixmap(box)
    mask.fill(Qt.GlobalColor.transparent)
    family = icon_font_family(type(icon))
    if family is None or box.width() <= 0 or box.height() <= 0:
        return mask
    drawn = _fitted_ink(
        family, icon.value, round(box.width() * _FILL), round(box.height() * _FILL)
    )
    if drawn is None:  # a codepoint this face doesn't map
        return mask
    painter = QPainter(mask)
    painter.drawImage(
        (box.width() - drawn.width()) // 2,
        (box.height() - drawn.height()) // 2,
        drawn,
    )
    painter.end()
    return mask


def stamped(mask: QPixmap, color: QColor) -> QPixmap:
    """A copy of ``mask`` with ``color`` stamped through its alpha.

    The one operation every icon in the editor ends with: the font carries the
    shape and the palette carries the colour, so one mask serves both themes
    and, where a caller needs it, its own disabled shade as well. A copy per
    call because ``SourceIn`` overwrites what it is composited onto, and the
    caller usually stamps the same mask more than once.
    """
    pixmap = mask.copy()
    painter = QPainter(pixmap)
    painter.setCompositionMode(QPainter.CompositionMode.CompositionMode_SourceIn)
    painter.fillRect(pixmap.rect(), color)
    painter.end()
    return pixmap


def icon_pixmap(icon: AnyIcon, color: QColor, box: QSize, ratio: float) -> QPixmap:
    """``icon`` in ``color``, ``box`` **logical** units rendered at ``ratio``.

    The one call a widget needs to put a themed mark on screen: it decides the
    box and hands over the palette colour it wants, and gets back a pixmap that
    measures that box in layout units however many device pixels it holds.
    """
    mask = icon_mask(
        icon, QSize(round(box.width() * ratio), round(box.height() * ratio))
    )
    tinted = stamped(mask, color)
    tinted.setDevicePixelRatio(ratio)
    return tinted


def icon_aspect(icon: AnyIcon) -> float:
    """How wide ``icon``'s ink is for its own height, or 1.0 if it draws none.

    A mark that sits *beside text* wants a box of its own shape rather than a
    shared one: PromptFont's shoulders are labelled pills at nearly 8:3 while
    its d-pad is square, and one box wide enough for the widest leaves the
    square ones floating in the middle of it, a thumb's width from the words
    they belong to. Measured off the ink, like everything else here.
    """
    family = icon_font_family(type(icon))
    if family is None:
        return 1.0
    # Large enough that the rasterizer's rounding is noise in the ratio.
    ink = _fitted_ink(family, icon.value, _ASPECT_SAMPLE, _ASPECT_SAMPLE)
    if ink is None or not ink.height():
        return 1.0
    return ink.width() / ink.height()


def palette_icon(
    icon: AnyIcon,
    palette: QPalette,
    box: QSize,
    ratio: float,
    role: QPalette.ColorRole = QPalette.ColorRole.ButtonText,
) -> QIcon:
    """``icon`` as an action's face, in ``palette``'s active and disabled ink.

    Both shades are baked here rather than left to Qt, whose automatic fade
    barely touches a flat silhouette: a greyed button would look the same as a
    live one. The two come off one mask, so the fit is measured once.
    """
    device = QSize(round(box.width() * ratio), round(box.height() * ratio))
    mask = icon_mask(icon, device)
    built = QIcon()
    for group, mode in (
        (QPalette.ColorGroup.Active, QIcon.Mode.Normal),
        (QPalette.ColorGroup.Disabled, QIcon.Mode.Disabled),
    ):
        pixmap = stamped(mask, palette.color(group, role))
        pixmap.setDevicePixelRatio(ratio)
        built.addPixmap(pixmap, mode)
    return built


@lru_cache(maxsize=256)
def _fitted_ink(family: str, text: str, width: int, height: int) -> QImage | None:
    """``text`` rasterized as large as it fits ``width`` x ``height``, cropped
    to its ink.

    ``None`` when the mark puts no pixels down at all -- a codepoint missing
    from the face, which is what a member added to
    :class:`~shiny_mushroom.ui.icons.Icon` without re-running
    ``packaging/subset_icon_font.py`` looks like from here.

    Converges rather than solving: each pass renders, measures what it actually
    got, and rescales by the shortfall. The rasterizer rounds outlines onto the
    pixel grid, so the relation between pixel size and ink size is only nearly
    linear and a single division would land a pixel out either way; two passes
    are normally enough, and :data:`_FIT_PASSES` caps it.

    Cached, and safely: the ink carries neither the palette colour nor the
    device ratio, which are the two things a baked icon goes stale over. A
    ``QImage`` rather than a ``QPixmap`` so the cache holds nothing that needs a
    live window system to outlive the application.
    """
    size = max(1, height)
    best: QImage | None = None
    for _ in range(_FIT_PASSES):
        drawn = _render(family, text, size)
        if drawn is None:
            return None
        if drawn.width() <= width and drawn.height() <= height:
            best = drawn
            # Room to spare in both directions means the next pass grows it; a
            # pass that cannot grow (the scale rounds back to this size) is the
            # fixed point, so stop there rather than rendering it again.
            scale = min(width / drawn.width(), height / drawn.height())
            grown = max(1, int(size * scale))
            if grown <= size:
                break
            size = grown
        else:
            # Over its room: shrink by the overshoot, at least a pixel, so a
            # rounding that lands on the same size cannot loop.
            scale = min(width / drawn.width(), height / drawn.height())
            size = max(1, min(int(size * scale), size - 1))
    return best if best is not None else drawn


def _render(family: str, text: str, size: int) -> QImage | None:
    """``text`` at ``size``, cropped to the pixels it actually inked.

    The scratch is twice the pixel size square with the baseline placed a half
    size in, which is room enough for any mark in an icon face (they are drawn
    to roughly the em box) without measuring one first.
    """
    scratch = QImage(size * 2, size * 2, QImage.Format.Format_ARGB32_Premultiplied)
    scratch.fill(Qt.GlobalColor.transparent)
    painter = QPainter(scratch)
    painter.setRenderHint(QPainter.RenderHint.TextAntialiasing)
    painter.setPen(QColor(Qt.GlobalColor.white))
    painter.setFont(_icon_font(family, size))
    painter.drawText(QPointF(size * 0.5, size * 1.5), text)
    painter.end()
    bounds = _ink_bounds(scratch)
    return None if bounds is None else scratch.copy(bounds)


def _ink_bounds(image: QImage) -> QRect | None:
    """The tightest rectangle holding every non-transparent pixel, or ``None``.

    Read a row of alpha at a time rather than pixel by pixel: this runs for
    every icon the editor bakes, and ``pixelColor`` per pixel over even a small
    scratch is the difference between imperceptible and a visible hitch on a
    theme switch.
    """
    alpha = image.convertToFormat(QImage.Format.Format_Alpha8)
    top, bottom, left, right = None, None, alpha.width(), -1
    for y in range(alpha.height()):
        row = bytes(alpha.constScanLine(y))[: alpha.width()]
        if not any(row):
            continue
        top = y if top is None else top
        bottom = y
        left = min(left, next(x for x, a in enumerate(row) if a))
        right = max(
            right, len(row) - 1 - next(x for x, a in enumerate(reversed(row)) if a)
        )
    if top is None:
        return None
    return QRect(left, top, right - left + 1, bottom - top + 1)


def _icon_font(family: str, pixel_size: int) -> QFont:
    """The icon face at ``pixel_size``, on the editor's weight."""
    font = QFont(family)
    font.setPixelSize(pixel_size)
    font.setVariableAxis(QFont.Tag("wght"), _WEIGHT)
    return font
