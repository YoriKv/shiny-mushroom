"""A small picture of one thing that could be placed.

What the create panel shows when the pointer rests on a row. Qt-free like the
rest of the model: a preview is a :class:`~shiny_mushroom.level.Raster`, and
turning one into a ``QImage`` is the ``ui`` side's job -- the same split
:mod:`shiny_mushroom.level` already makes for the level itself.

**Both kinds are drawn out of the level's own memories**, which is the whole
reason a preview is worth having rather than a bundled icon: the picture is
this cartridge's graphics under this level's header, so a hack that redrew its
tiles gets previews of what it drew. An object comes from the Map16 blocks it
was observed writing (:func:`object_preview`), a sprite from the tiles its own
drawing code was captured emitting (:func:`sprite_preview`).

Neither invents anything. An **object** the loader was seen drawing nothing for
has no preview at all, and the answer is ``None``. A **sprite** always has one,
because the canvas always draws it something: its artwork, its revealed form
stippled, or a numbered glyph -- and the preview goes through the same
:func:`~shiny_mushroom.sprites.plane` the level does, so the two cannot
disagree.
"""

from __future__ import annotations

from collections.abc import Collection, Mapping
from dataclasses import dataclass

from shiny_mushroom.level import (
    BLOCK,
    Blocks,
    Raster,
    geometry,
    pipe_tables,
    snes_color,
)
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.sprite_art import SpriteTile
from shiny_mushroom.sprites import Sprite, bounds, paint_into, plane


@dataclass(frozen=True)
class Thumbnail:
    """A picture of one entry, and where it sits against the record's own block.

    The offset is the whole reason this is a class rather than a raster. A
    preview is trimmed to what was actually drawn, and what was drawn does not
    have to start at the record's own block: a sprite's tile offsets are signed,
    so a Koopa reaches a block above the one its record names and a Banzai Bill
    several to the left. Handing back only the picture would leave every caller
    to guess that, and the placement ghost would put the artwork in the wrong
    place for exactly the sprites whose size makes it obvious.

    ``dx`` and ``dy`` are image pixels from the record's origin to the picture's
    top-left, so they are negative for anything reaching up or left.
    """

    raster: Raster
    dx: int = 0
    dy: int = 0

    @property
    def width(self) -> int:
        return self.raster.width

    @property
    def height(self) -> int:
        return self.raster.height


#: The largest preview worth building, in blocks. An object with a runaway
#: extent draws across the whole level, and a thumbnail of that is a few
#: megabytes of mostly one tile -- so it is refused rather than rendered. Well
#: past anything hand-placed: the widest thing in the stock cart's own levels
#: that a default settings byte produces is under a screen.
MAX_PREVIEW_BLOCKS = 32


def object_preview(
    snapshot: LevelSnapshot,
    blocks: Collection[tuple[int, int]],
    anchor: tuple[int, int] = (0, 0),
    painter: Blocks | None = None,
) -> Thumbnail | None:
    """The blocks an object drew, as a picture, trimmed to what it covers.

    ``blocks`` is what the loader was observed writing -- the same footprint the
    outlines are traced around (:mod:`shiny_mushroom.emu.footprints`), in
    ``(column, row)``. It is not the record's rectangle: a slope comes out as a
    slope and a pipe as an L, because that is what the trace saw.

    ``None`` when there is nothing to draw, and the two cases that produces are
    both real: an object that placed **no tiles** -- a screen exit, or one whose
    tiles all fell outside the level -- and one whose footprint is implausibly
    large, which means a runaway extent rather than a thing anyone wants a
    thumbnail of. A caller shows its own empty state; inventing a box of
    backdrop here would be a picture of nothing claiming to be a picture of
    something.

    **Gaps are filled with the level's back area colour**, not left transparent
    and not blacked out. That is exactly what is behind those blocks in the
    level, so an L-shaped object reads the way it will once placed.

    ``anchor`` is the object's own block, which is what the offset in the
    returned :class:`Thumbnail` is measured from -- an object that draws above or
    to the left of the block its record names is not unheard of, and the
    placement ghost has to put the picture where the object will actually be.

    ``painter`` is a :class:`~shiny_mushroom.level.Blocks` to decode through,
    for a caller drawing many previews out of one snapshot: it caches per
    *distinct* 8x8 tile and Map16 block, and a whole catalogue shares far more
    of both than it does not. One is made per call without it.
    """
    if not blocks:
        return None
    left = min(column for column, _row in blocks)
    right = max(column for column, _row in blocks)
    top = min(row for _column, row in blocks)
    bottom = max(row for _column, row in blocks)
    across, down = right - left + 1, bottom - top + 1
    if across > MAX_PREVIEW_BLOCKS or down > MAX_PREVIEW_BLOCKS:
        return None

    shape = geometry(snapshot)
    painter = painter or Blocks(snapshot, pipes=pipe_tables(snapshot), ghosts=True)
    backdrop = snes_color(snapshot.back_area_color) * BLOCK
    held = set(blocks)
    lines: list[bytes] = []
    for row in range(top, bottom + 1):
        drawn = [
            painter.rows(snapshot.tile(shape.index(column, row)), column)
            if (column, row) in held
            else None
            for column in range(left, right + 1)
        ]
        lines.extend(
            b"".join(backdrop if block is None else block[y] for block in drawn)
            for y in range(BLOCK)
        )
    return Thumbnail(
        Raster(across * BLOCK, down * BLOCK, b"".join(lines)),
        (left - anchor[0]) * BLOCK,
        (top - anchor[1]) * BLOCK,
    )


def sprite_preview(
    number: int,
    art: Mapping[int, tuple[SpriteTile, ...]],
    vram: bytes,
    cgram: bytes,
    back_area_color: int,
) -> Thumbnail:
    """What a sprite looks like on the canvas, as a picture.

    **The level's own answer, not a second one.** It goes through
    :func:`~shiny_mushroom.sprites.plane` -- the same function that draws the
    sprites in the level -- so the three things it can produce here are the three
    it produces there, and a preview cannot disagree with what the canvas will
    show once the sprite is placed:

    - the sprite's **own artwork**, wherever the probe captured any;
    - its **revealed form, stippled**, for the ones the game draws nothing for
      until something reveals them -- an invisible mushroom previews as the
      ghosted mushroom it becomes;
    - a **glyph** with its number, for the ones there is nothing honest to draw
      at all: a shooter, a generator, a scroll command, or one the probe could
      not make draw.

    So this never answers ``None``. It used to, and that was a preview saying
    "no picture" about a sprite the canvas draws a numbered box for -- two
    answers to one question. The glyph *is* what you will see.

    The box is :func:`~shiny_mushroom.sprites.bounds`', which falls back to the
    record's own block when there is no artwork -- and that is exactly the box a
    glyph is painted in, so the picture and its size agree either way.

    Placed against the level's **back area colour** rather than a checkerboard
    or black: it is what the sprite will stand in front of, and a preview on a
    colour the level does not have would misrepresent every dark sprite.
    """
    # Where to stand the sprite so that nothing it draws lands at a negative
    # coordinate. Tile offsets are signed and reach above and to the left of the
    # record's block, so this is derived from the capture rather than guessed at
    # with a margin that would be too small for one sprite and wasteful for the
    # rest.
    reach = bounds(_at_origin(number), art)
    column = max(0, -(-max(0, -reach.left) // BLOCK))
    row = max(0, -(-max(0, -reach.top) // BLOCK))
    origin = _at_origin(number, column, row)
    box = bounds(origin, art)

    painted = plane(
        box.left + box.width,
        box.top + box.height,
        [origin],
        art,
        vram,
        cgram,
    )
    backdrop = snes_color(back_area_color)
    pixels = bytearray(backdrop * (painted.width * painted.height))
    paint_into(pixels, painted.width, painted.height, painted)
    return Thumbnail(
        _cropped(
            Raster(painted.width, painted.height, bytes(pixels)),
            box.left,
            box.top,
            box.width,
            box.height,
        ),
        box.left - column * BLOCK,
        box.top - row * BLOCK,
    )


def _at_origin(number: int, column: int = 0, row: int = 0) -> Sprite:
    """A sprite record built only to ask where its artwork reaches.

    Nothing is placed and nothing is written: the fields a stream computes are
    left at their defaults, exactly as
    :class:`~shiny_mushroom.sprites.Sprite` allows for a record built by hand to
    ask a question about geometry.
    """
    return Sprite(number=number, column=column, row=row, screen=0, extra_bits=0)


def _cropped(raster: Raster, left: int, top: int, width: int, height: int) -> Raster:
    """``raster``'s ``(left, top, width, height)`` rectangle, in pixels."""
    stride = raster.stride
    lines = [
        raster.pixels[
            (top + y) * stride + left * 3 : (top + y) * stride + (left + width) * 3
        ]
        for y in range(height)
    ]
    return Raster(width, height, b"".join(lines))


def previews_from[K](
    snapshot: LevelSnapshot,
    footprints: Mapping[K, tuple[tuple[int, int], Collection[tuple[int, int]]]],
) -> dict[K, Thumbnail]:
    """Every object preview a probe's footprints yield, under the same keys.

    The bulk path behind the create panel's object thumbnails: one probe load
    puts the whole catalogue in one snapshot, and this turns its footprints into
    pictures in one pass -- **sharing one
    :class:`~shiny_mushroom.level.Blocks`** across all of them, so an 8x8 tile
    decoded for one object is not decoded again for the next. A catalogue shares
    most of its tiles; without the sharing the work is done once per object
    instead of once per tile.

    ``footprints`` maps each key to ``(anchor, blocks)`` -- the object's own
    block and what it drew -- because a picture without the offset between them
    cannot be put back where the object will be.

    Objects with nothing to show are simply absent rather than present with a
    ``None``: a caller asking "is there a preview for this" should get one
    answer, and a missing key already is that answer.
    """
    painter = Blocks(snapshot, pipes=pipe_tables(snapshot), ghosts=True)
    made: dict[K, Thumbnail] = {}
    for key, (anchor, blocks) in footprints.items():
        drawn = object_preview(snapshot, blocks, anchor, painter)
        if drawn is not None:
            made[key] = drawn
    return made
