"""Stand-in artwork for the sprites the cartridge draws nothing for.

Most of a level's sprite list can be *shown*: the probe makes each number draw
itself and the capture is composited over the picture. Some records have no
artwork to capture, and not because anything failed --

- a **spawner** is a shooter, a generator or one of the multi-sprite loaders. It
  puts sprites somewhere else, or later, or off the top of the screen; there is
  nothing at the record's own block to draw.
- a **command** is a layer scroll routine. It acts on a layer, not in the level.
- a **sprite** whose art the probe could not capture -- one that only draws
  after a trigger, or in a state the probe did not reach.

All three are in the level and all three do something, so leaving them invisible
is the one answer that is certainly wrong. What is drawn instead is a **glyph**:
a filled shape the size of a block with the sprite's number in it, which says
"there is a record here, this is its number, and this is not what it looks
like". The approach is Advynia's, whose numbered tiles solve the same problem in
a Yoshi's Island editor.

Shape and colour both carry the *kind*, rather than colour alone -- shape
survives being small, being over busy artwork, and being looked at by somebody
who does not separate the hues.

Qt-free, like everything it is composited into. A glyph is emitted as runs in
the same form :class:`~shiny_mushroom.sprites.SpritePlane` holds, so it costs
the same to lay down as captured artwork does and needs no second path through
the drawing code.
"""

from __future__ import annotations

from dataclasses import dataclass

from shiny_mushroom.level import BLOCK

#: What each character of a shape means. Outside is *left out* rather than
#: filled: a glyph stands in front of the level exactly as a sprite does, and a
#: circle boxed in its own backdrop would not read as a circle.
OUTSIDE = "."
OUTLINE = "#"
FILL = "o"

#: One dark line around every glyph, so a fill that happens to match the artwork
#: behind it still has an edge.
OUTLINE_COLOR = b"\x10\x10\x10"

#: The number, in white on all three fills -- each is dark enough to carry it.
TEXT_COLOR = b"\xff\xff\xff"


def _shape(*rows: str) -> tuple[str, ...]:
    """A block-sized mask, checked at import.

    A shape is written out as art because that is the only form in which it can
    be *reviewed*: a row of coordinates is not a picture of anything, and a
    glyph that is one pixel wrong is wrong in every level.
    """
    if len(rows) != BLOCK or any(len(row) != BLOCK for row in rows):
        raise ValueError(f"a shape is {BLOCK}x{BLOCK}, not {len(rows)} rows")
    written = set("".join(rows))
    if not written <= {OUTSIDE, OUTLINE, FILL}:
        raise ValueError("a shape is written with '.', '#' and 'o' only")
    return rows


#: A sprite that should have had artwork. Round, because it stands where a
#: sprite stands and is the same kind of thing as the ones around it.
CIRCLE = _shape(
    "......####......",
    "....##oooo##....",
    "..##oooooooo##..",
    "..#oooooooooo#..",
    ".#oooooooooooo#.",
    ".#oooooooooooo#.",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    ".#oooooooooooo#.",
    ".#oooooooooooo#.",
    "..#oooooooooo#..",
    "..##oooooooo##..",
    "....##oooo##....",
    "......####......",
)

#: A spawner. Square, because what is at the block is the machinery rather than
#: the sprite -- the thing it makes turns up elsewhere.
SQUARE = _shape(
    "################",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "################",
)

#: A command. Cornered off, the shape a sign is: it is not in the level at all,
#: it is an instruction to a layer that happens to be recorded at a block.
OCTAGON = _shape(
    "....########....",
    "...#oooooooo#...",
    "..#oooooooooo#..",
    ".#oooooooooooo#.",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    "#oooooooooooooo#",
    ".#oooooooooooo#.",
    "..#oooooooooo#..",
    "...#oooooooo#...",
    "....########....",
)


@dataclass(frozen=True)
class Glyph:
    """A shape and the colour it is filled with."""

    shape: tuple[str, ...]
    fill: bytes


#: A sprite the probe caught nothing for. Amber, the colour of a thing that is
#: missing rather than a thing that is a different sort of thing.
#:
#: The world map's sprite markers wear it too
#: (:func:`shiny_mushroom.ui.overworld_sprites.glyph_image`). "A sprite whose
#: artwork is unknown" is one statement, and a reader who has learnt the amber
#: circle in a level should not have to learn a second shape for the same
#: statement on the overworld.
MISSING = Glyph(CIRCLE, b"\xc0\x60\x00")

#: A shooter, a generator, or one of the multi-sprite loaders.
SPAWNER = Glyph(SQUARE, b"\x20\x50\xc0")

#: A layer scroll command.
COMMAND = Glyph(OCTAGON, b"\x70\x20\xb0")


# -- the number inside -------------------------------------------------------

#: The digits, 4x7 each. Only hex is here because only a sprite number is ever
#: written with them, and a byte is two digits -- which is what decides the
#: layout below and is why there is no general text rendering in this module.
DIGIT_WIDTH = 4
DIGIT_HEIGHT = 7

#: Where the two digits of a byte go: 4 wide with one column between them is 9
#: of the 16, and seven rows of the sixteen, both as near centred as whole
#: pixels allow.
DIGIT_ORIGINS = ((3, 4), (8, 4))

_FONT = {
    "0": (".##.", "#..#", "#..#", "#..#", "#..#", "#..#", ".##."),
    "1": (".#..", "##..", ".#..", ".#..", ".#..", ".#..", "###."),
    "2": (".##.", "#..#", "...#", "..#.", ".#..", "#...", "####"),
    "3": (".##.", "#..#", "...#", ".##.", "...#", "#..#", ".##."),
    "4": ("#..#", "#..#", "#..#", "####", "...#", "...#", "...#"),
    "5": ("####", "#...", "#...", "###.", "...#", "#..#", "###."),
    "6": (".##.", "#...", "#...", "###.", "#..#", "#..#", ".##."),
    "7": ("####", "...#", "..#.", "..#.", ".#..", ".#..", ".#.."),
    "8": (".##.", "#..#", "#..#", ".##.", "#..#", "#..#", ".##."),
    "9": (".##.", "#..#", "#..#", ".###", "...#", "...#", "###."),
    "A": (".##.", "#..#", "#..#", "####", "#..#", "#..#", "#..#"),
    "B": ("###.", "#..#", "#..#", "###.", "#..#", "#..#", "###."),
    "C": (".##.", "#..#", "#...", "#...", "#...", "#..#", ".##."),
    "D": ("###.", "#..#", "#..#", "#..#", "#..#", "#..#", "###."),
    "E": ("####", "#...", "#...", "###.", "#...", "#...", "####"),
    "F": ("####", "#...", "#...", "###.", "#...", "#...", "#..."),
}


def pixels(glyph: Glyph, label: str) -> list[list[bytes | None]]:
    """The glyph as block-sized rows of colours, ``None`` where it is see-through.

    Built as a grid and turned into runs afterwards rather than emitted
    directly, because the number is drawn *over* the fill: a digit's pixel has
    to replace one already decided, which a stream of runs cannot do.
    """
    grid: list[list[bytes | None]] = [
        [
            {OUTSIDE: None, OUTLINE: OUTLINE_COLOR, FILL: glyph.fill}[character]
            for character in row
        ]
        for row in glyph.shape
    ]
    for character, (left, top) in zip(label, DIGIT_ORIGINS, strict=True):
        for y, row in enumerate(_FONT[character]):
            for x, lit in enumerate(row):
                if lit == OUTLINE:
                    grid[top + y][left + x] = TEXT_COLOR
    return grid


def draw(
    runs: list[tuple[int, bytes]],
    width: int,
    height: int,
    left: int,
    top: int,
    glyph: Glyph,
    label: str,
) -> None:
    """Append the runs that paint ``glyph`` with ``label`` in it at ``(left, top)``.

    The same run form the captured artwork uses -- a byte offset into a raster
    of this size and the colours to write there -- so a plane holding both is
    laid down in one pass, in one order, and nothing downstream knows which
    sprites were drawn and which were stood in for.

    Always solid. A glyph stands for a record whose artwork is *unknown*, which
    is not the claim a half-strength sprite makes -- that one the game draws and
    hides.
    """
    stride = width * 3
    for y, row in enumerate(pixels(glyph, label)):
        line = top + y
        if not 0 <= line < height:
            continue
        run: list[bytes] = []
        start = 0
        for x, color in enumerate(row):
            column = left + x
            # See-through, or off the edge of the picture. Either one ends the
            # run being gathered, exactly as a transparent tile pixel does.
            if color is None or not 0 <= column < width:
                if run:
                    runs.append((start, b"".join(run)))
                    run = []
                continue
            if not run:
                start = line * stride + column * 3
            run.append(color)
        if run:
            runs.append((start, b"".join(run)))
