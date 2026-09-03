"""The icon marks the editor draws, as codepoints in the bundled icon font.

Qt-free on purpose, so a table that declares what a bar puts on screen -- the
view bars' :data:`~shiny_mushroom.ui.view_bar.ICONS`, say -- can name a
button's face as plain data beside its action and its key;
:mod:`shiny_mushroom.ui.icon_font` is the half that needs a QPainter.

The face is **Material Symbols Outlined** (Apache 2.0), subset to exactly the
codepoints below -- see ``packaging/subset_icon_font.py``, which reads this
enum, so **adding a member here means re-running that script** or the new icon
draws as nothing. ``tests/test_icon_font.py`` fails loudly when it does.

Members are named for what the mark *is to the editor*, not for what upstream
calls it: the two are unrelated (``mood`` is a face, ``filter_frames`` a frame
inside a frame), and naming ours after theirs would mean renaming every call
site the next time the font changes. Each comment carries the upstream name,
which is what to search for at
<https://fonts.google.com/icons?icon.style=Outlined>.

Codepoints are spelled as escapes because they sit in the private-use block and
would otherwise be an invisible glyph in the source.

Not to be confused with :mod:`shiny_mushroom.glyphs`, which is what the *canvas*
draws where the cartridge draws nothing.
"""

from __future__ import annotations

from enum import Enum


class Icon(Enum):
    """One mark in the bundled font. ``value`` is the character to draw."""

    # The view toggles' layer numerals. A framed digit rather than a stack of
    # rectangles: the number is what tells 2 from 3, and it survives 20 pixels.
    LAYER_1 = "\ue3d0"  # filter_1
    LAYER_2 = "\ue3d1"  # filter_2
    LAYER_3 = "\ue3d2"  # filter_3

    # The sprite layer, and the two outlines drawn over it. The outlines are one
    # family on purpose -- the same corner frame, one around a figure and one
    # around nothing -- because that is the difference between them: an outline
    # around a sprite, and an outline around whatever an object drew.
    SPRITE = "\ue24e"  # mood - a face: the artwork itself
    SPRITE_OUTLINE = "\uf8a6"  # frame_person
    OBJECT_OUTLINE = "\ue3c2"  # crop_free

    # The rest of the view toggles.
    SCREENS = "\ue8ec"  # view_column - a strip divided into screens
    TILE_MARKS = "\ue941"  # arrow_right_alt - walk arrows, path steps, warps
    FRAME = "\ue3de"  # filter_frames - a window in a screen: the border mask

    # The three editing environments, on the mode bar: a stage with scenery,
    # a folded map, and a sheet of tiles. Each is what its canvas shows, not
    # what its data is called -- "Map16" would be a grid either way.
    LEVEL = "\ue3f7"  # landscape
    WORLD_MAP = "\ue55b"  # map
    MAP16 = "\ue3ec"  # grid_on

    # Stepping through a list, and asking for what is selected: the level bar
    # and the find bar wear the same pair, because they do the same thing to
    # two different lists.
    PREVIOUS = "\ue408"  # chevron_left
    NEXT = "\ue409"  # chevron_right
    RELOAD = "\ue5d5"  # refresh

    # A disclosure's own marks. Solid triangles rather than chevrons: they sit
    # inline at the head of a line of text, where a stroked mark reads as part
    # of the sentence.
    FOLDED = "\ue5df"  # arrow_right
    UNFOLDED = "\ue5c5"  # arrow_drop_down

    # The pixel editor's three tools that are a picture of a thing rather than
    # of a shape: the shape tools draw their own face, since a line is its own
    # best icon.
    PENCIL = "\ue3c9"  # edit
    FILL = "\ue23a"  # format_color_fill
    EYEDROPPER = "\ue3b8"  # colorize


class PadIcon(Enum):
    """One SNES button's mark, in the bundled controller font.

    A second face, because the icon set has no controller in it: **PromptFont**
    (SIL OFL), subset by ``packaging/subset_prompt_font.py``, which reads this
    enum for the same reason the other script reads :class:`Icon`.

    The two faces do not collide. Material Symbols lives entirely in the
    private-use block; every mark below is at a real Unicode codepoint outside
    it, so nothing here can be shadowed by a mark there.

    **The face buttons are named for where they sit, not for their letter, and
    the SNES disagrees with the pad PromptFont was named after.** Its
    ``gamepad-y`` is "Button Up" and its ``gamepad-x`` is "Button Left" -- the
    modern Nintendo and Xbox arrangement. A SNES pad puts **X on top and Y on
    the left**, and A on the right with B below, so each member below takes the
    glyph for the *position its button occupies on a SNES pad* and the upstream
    name in the comment reads like the opposite. It is: that is the point.

    Spelled as escapes like :class:`Icon`'s, though these are real Unicode
    arrows rather than private-use marks: written literally they would read as
    arrows in the source, and every one of them draws a button.
    """

    UP = "\u219f"  # dpad-up
    DOWN = "\u21a1"  # dpad-down
    LEFT = "\u219e"  # dpad-left
    RIGHT = "\u21a0"  # dpad-right

    # The diamond, by position. See the class docstring before "fixing" these.
    X = "\u21a5"  # gamepad-y -- the top of the diamond, which on a SNES is X
    Y = "\u21a4"  # gamepad-x -- the left, which on a SNES is Y
    A = "\u21a6"  # gamepad-b -- the right, which on a SNES is A
    B = "\u21a7"  # gamepad-a -- the bottom, which on a SNES is B

    # The shoulders and the two in the middle, which need no such translation:
    # the SNES is the pad these were drawn for.
    L = "\u219c"  # nintendo-left-shoulder
    R = "\u219d"  # nintendo-right-shoulder
    SELECT = "\u21f7"  # gamepad-select
    START = "\u21f8"  # gamepad-start
