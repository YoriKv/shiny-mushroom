"""The app-wide light/dark appearance, in one palette applied in one place.

The editor themes through **QPalette**, not a stylesheet. Every widget already
draws from palette roles, so handing the application a different palette
re-colors the whole UI without a per-widget rule anywhere. The only literals
left are the ones that are deliberately *not* theme colors - the canvas backing
and its grid - which have to read the same against the artwork whichever theme
is on.

**Light is the platform's own look**, unchanged: its palette is the active
style's ``standardPalette()``, which is where Qt was already getting it.

**Dark is derived, not tabulated.** ``QPalette(QColor)`` computes a whole
palette from one surface color - window, button, text, and the Light/Mid/Dark/
Shadow bevel shades all fall out of it - so the constants below are only the
handful whose derived value is wrong for a dark UI (Qt's derivation assumes the
seed is a *button* color on a light desktop). That keeps one seed as the thing
to turn when the dark theme wants to be lighter or warmer.

Dark also forces the **Fusion** style. The native Windows and macOS styles paint
many controls from platform colors and ignore the application palette, so a dark
palette under them comes out half-light; Fusion honours the palette everywhere
and ships on every platform Qt does. ``setColorScheme`` is requested alongside
for the parts a palette cannot reach - most visibly the Windows title bar - and
is a no-op where the platform cannot honour it, which is exactly why the palette
is built by hand rather than left to Qt's own dark scheme.
"""

from __future__ import annotations

from enum import Enum

from PySide6.QtCore import Qt
from PySide6.QtGui import QColor, QPalette
from PySide6.QtWidgets import QApplication, QProxyStyle, QStyle, QStyleFactory

# App-wide and remembered across launches: the theme is a property of the person
# using the editor, not of what they have open.
THEME_KEY = "view/theme"


class Theme(Enum):
    """The app's appearance. ``value`` is the stable string persisted in app
    settings under :data:`THEME_KEY`."""

    LIGHT = "light"
    DARK = "dark"


# The one color the dark palette is derived from: the surface behind everything
# that is not an input. Dark enough that the canvas is the brightest thing in the
# window, light enough that the bevel shades Qt derives from it still separate a
# raised control from its background.
_DARK_SURFACE = QColor(0x35, 0x35, 0x35)

# What Qt's derivation gets wrong for a dark UI, and nothing more.
#
# - Base/AlternateBase: derived pure black, which reads as a hole punched in the
#   window. A shade *under* the surface keeps the same figure/ground relation the
#   light theme has, without the contrast jump. The alternate is a step *up*
#   rather than a hair off the base: it is what separates one table row from the
#   next now that the tables band instead of ruling a grid
#   (:mod:`shiny_mushroom.ui.tables`), and a difference of five values is not a
#   separation on a dark surface.
# - Highlight: the derived navy is nearly the surface color, so a selected row
#   would barely show.
# - ToolTip*: Qt keeps the light desktop's pale yellow, the one surface that
#   would still flash white.
# - PlaceholderText: derived as full-strength Text, which makes a hint look like
#   a value.
# - Link: the default blue is too dark to read on the surface.
_DARK_BASE = QColor(0x2B, 0x2B, 0x2B)
_DARK_ALTERNATE = QColor(0x34, 0x34, 0x34)
_DARK_HIGHLIGHT = QColor(0x2A, 0x6E, 0xB8)
_DARK_TOOLTIP_BASE = QColor(0x3C, 0x3C, 0x3C)
_DARK_TOOLTIP_TEXT = QColor(0xE6, 0xE6, 0xE6)
_DARK_PLACEHOLDER = QColor(0xFF, 0xFF, 0xFF, 0x66)
_DARK_LINK = QColor(0x54, 0xA6, 0xFF)
# Disabled ink. Qt derives this by *darkening* the text color, which on a dark
# surface lands a shade off black - a disabled label would be less readable than
# no label at all. Grayed toward the surface instead, the direction that reads as
# "off" on a dark UI.
_DARK_DISABLED_TEXT = QColor(0x7A, 0x7A, 0x7A)
_DARK_DISABLED_HIGHLIGHT = QColor(0x45, 0x45, 0x45)


class _UnderlinedMnemonics(QProxyStyle):
    """Show every menu's mnemonic underline without holding Alt down.

    Windows (and any desktop whose theme asks for it) hides the underlines until
    Alt is pressed - the platform's "underline access keys" setting - so a menu
    looks as though it has no keyboard route at all until you already know to
    reach for one. Everything else is delegated: this changes no other part of
    the style it wraps.
    """

    def styleHint(  # noqa: N802 - Qt override
        self,
        hint: QStyle.StyleHint,
        option=None,  # noqa: ANN001 - QStyleOption
        widget=None,  # noqa: ANN001 - QWidget
        returnData=None,  # noqa: ANN001, N803 - QStyleHintReturn
    ) -> int:
        if hint == QStyle.StyleHint.SH_UnderlineShortcut:
            return 1
        return super().styleHint(hint, option, widget, returnData)


def blended(over: QColor, under: QColor, amount: float) -> QColor:
    """``over`` mixed ``amount`` of the way onto ``under``, opaque.

    The one arithmetic behind every colour in the editor that is *derived from
    the palette* rather than written down: a washed table selection, a greyed
    note, the memory map's flat ground, an ARAM run the engine merely keeps.
    Each of those has to hold up on both the light surface and the dark one, and
    a literal that reads right against one is a smear against the other -- so
    they are all stated as a distance from a palette role, and computed here.

    Opaque rather than an alpha brush: an item view's selection is painted by
    the style, and not every style composites a translucent ``Highlight`` the
    same way -- while every one of them fills with a solid colour identically.
    """
    return QColor(
        *(
            round(below + (above - below) * amount)
            for above, below in (
                (over.red(), under.red()),
                (over.green(), under.green()),
                (over.blue(), under.blue()),
            )
        )
    )


def dark_palette() -> QPalette:
    """The dark theme's palette: derived from :data:`_DARK_SURFACE`, then the
    handful of roles whose derived value is wrong for a dark UI (see above)."""
    palette = QPalette(_DARK_SURFACE)
    palette.setColor(QPalette.ColorRole.Base, _DARK_BASE)
    palette.setColor(QPalette.ColorRole.AlternateBase, _DARK_ALTERNATE)
    palette.setColor(QPalette.ColorRole.Highlight, _DARK_HIGHLIGHT)
    palette.setColor(QPalette.ColorRole.HighlightedText, Qt.GlobalColor.white)
    palette.setColor(QPalette.ColorRole.ToolTipBase, _DARK_TOOLTIP_BASE)
    palette.setColor(QPalette.ColorRole.ToolTipText, _DARK_TOOLTIP_TEXT)
    palette.setColor(QPalette.ColorRole.PlaceholderText, _DARK_PLACEHOLDER)
    palette.setColor(QPalette.ColorRole.Link, _DARK_LINK)
    for role in (
        QPalette.ColorRole.WindowText,
        QPalette.ColorRole.Text,
        QPalette.ColorRole.ButtonText,
        QPalette.ColorRole.HighlightedText,
    ):
        palette.setColor(QPalette.ColorGroup.Disabled, role, _DARK_DISABLED_TEXT)
    palette.setColor(
        QPalette.ColorGroup.Disabled,
        QPalette.ColorRole.Highlight,
        _DARK_DISABLED_HIGHLIGHT,
    )
    return palette


def apply_theme(theme: Theme) -> None:
    """Put ``theme`` on the running application, live.

    A switch changes two things - the style and the palette - and **the palette
    has to be installed first**. Qt propagates an application palette through the
    event loop rather than inside ``setPalette``, and installing a style in
    between re-polishes every widget against the palette it already has: the
    queued PaletteChange is then considered satisfied and never delivered. Any
    widget that bakes a palette color into a pixmap listens for exactly that
    event, so in the other order it would keep yesterday's colors until something
    else invalidated it.

    Which is also why the style is *built* before it is installed: a light
    theme's palette is the style's own ``standardPalette()``, so it has to be
    asked of the new style, not the outgoing one.
    """
    app = QApplication.instance()
    if app is None:  # nothing to theme yet (import-time, or a headless caller)
        return
    dark = theme is Theme.DARK
    # For the parts of the UI a palette cannot reach. Requested before the
    # palette is read back, since a platform that honours it regenerates the
    # style's standard palette to match.
    app.styleHints().setColorScheme(
        Qt.ColorScheme.Dark if dark else Qt.ColorScheme.Light
    )
    # A QProxyStyle with no base resolves to the platform's default style, which
    # is what the light theme wants; dark passes Fusion in as the base instead.
    style = _UnderlinedMnemonics(QStyleFactory.create("Fusion") if dark else None)
    app.setPalette(dark_palette() if dark else style.standardPalette())
    app.setStyle(style)
