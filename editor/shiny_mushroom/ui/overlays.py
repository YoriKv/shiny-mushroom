"""What is marked over a level, and in what colours.

The canvas strokes rectangles and knows nothing about what they stand for
(:class:`~shiny_mushroom.ui.canvas.Overlay`); the level model knows what an
object and a sprite are and nothing about how they look. This is the seam
between the two: it turns a level's contents into the geometry that gets
painted, and it is where every decision about *appearance* lives.

Nothing here touches the picture. Marking a sprite or selecting an object used
to mean re-rendering the level and stroking lines into the pixels, which cost a
full copy of a multi-megabyte raster per click and - fatally - reduced with the
artwork, so a one-pixel outline vanished at the zooms a level is surveyed at.
Overlays are drawn over the finished picture in device space instead, so they
stay one pixel wide at every zoom and a selection change is a repaint.

That is also what makes a drag affordable, and :class:`Floating` is where it is
said: a move in progress shifts the marks and leaves the pixels where they are,
so the whole gesture costs a repaint and the emulator is asked once, at the end.
"""

from __future__ import annotations

from collections.abc import Collection, Iterable, Mapping
from dataclasses import dataclass, replace
from functools import lru_cache

from PySide6.QtCore import QRect
from PySide6.QtGui import QColor, QImage

from shiny_mushroom.level import BLOCK
from shiny_mushroom.objects import LevelObject
from shiny_mushroom.sprite_art import SpriteTile
from shiny_mushroom.sprites import Sprite, bounds
from shiny_mushroom.ui.canvas import Overlay

#: One thin neutral line around everything the level contains, object and sprite
#: alike, and no second colour behind it. The overlay draws a box around
#: *everything*, so it is furniture rather than a marker: it has to be legible
#: when it is asked for and quiet while it is on, and a saturated colour
#: repeated sixty times over the artwork is neither. Grey also leaves the
#: selection's ants as the one thing in the picture that carries meaning.
#:
#: The same grey for both is deliberate. What a box is around is answered by
#: what is inside it and by the status bar on hover, not by a colour the reader
#: has to have learnt -- and a sprite's box is now its artwork's own outline,
#: which says "sprite" more plainly than any hue could.
OUTLINE_COLOR = QColor(0xA0, 0xA0, 0xA0)

# The selection is **marching ants**: one solid black line with a white dashed
# line painted on top of it, on the same rectangle. Two colours in alternation
# is what makes a selection readable over artwork of any colour -- a solid line
# of either one disappears into art that happens to match it, and the eye reads
# the alternation itself as "selected" rather than as another marker. It is also
# the shape every editor uses for this, so it needs no explaining. **Every
# selection on a canvas wears them** -- records, tiles, the Map16 sheet's
# cells, the map's stamps -- so the mark never has to be learnt twice. The
# panel grids are the one other surface, and they wear a still two-tone ring
# instead (`ui/ring.py`): the same on every panel, different from the canvas.
SELECTION_LINE = QColor(0x00, 0x00, 0x00)
SELECTION_DASH = QColor(0xFF, 0xFF, 0xFF)

#: Pixels per dash at 1:1. The canvas scales it with the picture and holds it
#: above two device pixels, so the ants keep their look where the level is
#: magnified and stay ants where it is reduced.
DASH_LENGTH = 2

#: What a drag is reaching for -- the selection box being swept, and the extent
#: a dragged edge is pulling an object to: the same black-and-dashes as the
#: ants, but in the blue the structural grid already uses rather than in white.
#:
#: It has to be told apart from the ants at a glance, because during a drag both
#: are on screen and they mean different things -- one is what is held, the other
#: is what is being reached for. Hue does that without a second line weight or a
#: fill, and this is the one colour in the editor that already means "a boundary
#: the editor drew".
#:
#: **The blue box never snaps; the ants always do.** A box is drawn only where
#: it and the selection are different things -- it reaches across the picture
#: by the pixel and catches whichever *records* it touches, so it has to be
#: seen while the ants are somewhere else. Boxing a tilemap is not that: every
#: cell inside the box is caught, so the ants already outline the box, snapped
#: to the grid, and a blue rectangle over them would be one statement drawn
#: twice. So the level's records, the map's sprites, stamps and transfers box
#: in blue; the level's Layer 2, the map's two layers and the Map16 sheets
#: sweep with the ants alone.
#:
#: One colour for both, because they are one statement. A marquee says "as far
#: as here" about a region and a resize says it about an edge, and a reader who
#: has learnt the blue once has learnt both.
MARQUEE_COLOR = QColor(0x00, 0x00, 0xFF)

#: What is being placed but is not in the level yet -- the ghost the create
#: panel arms and the pointer carries around. The same two-line treatment as the
#: ants and the marquee, black underneath so it survives bright artwork, and a
#: third hue over it.
#:
#: A third hue rather than a reuse, because a placement is a third statement and
#: all three can be on screen at once: white ants say "this is held", blue says
#: "this is what a gesture is reaching for", and cyan says "this is not in the
#: level yet". Cyan is the one colour left that no console palette in this game
#: makes much of, which is what keeps a ghost legible over the artwork it is
#: about to land on.
PLACING_COLOR = QColor(0x28, 0xE0, 0xFF)


@dataclass(frozen=True)
class Floating:
    """Records lifted off the picture, and how far they have been carried.

    A drag that moves something shows where it would land **before** anything
    is committed, and the picture is the one part that cannot follow: it is the
    game's own work and costs an emulator round trip. So the outlines are
    detached from the level for the length of the gesture -- they are drawn
    ``(columns, rows)`` blocks from where their records still are, over a
    picture that has not changed -- and the document is left alone until the
    button comes up.

    Blocks rather than pixels, because a block is the unit an edit lands on:
    the level format has no finer position for a record, so an outline that
    followed the pointer by the pixel would be showing a placement that cannot
    happen.

    ``uids`` is what is being carried and is not the same as what is selected:
    a screen exit's position bits are the screen it acts on, so it stays where
    it is while the rest of the selection moves around it.
    """

    uids: Collection[int]
    columns: int
    rows: int

    def carried(self, record: LevelObject | Sprite) -> bool:
        return record.uid in self.uids

    def shift(self, overlay: Overlay) -> Overlay:
        """``overlay`` moved by the step, box and traced blocks alike."""
        dx, dy = self.columns * BLOCK, self.rows * BLOCK
        return replace(
            overlay,
            rect=overlay.rect.translated(dx, dy),
            cells=tuple(cell.translated(dx, dy) for cell in overlay.cells),
        )


@dataclass(frozen=True)
class Stretching:
    """One record's edge in the hand, and how far it has been pulled.

    The sibling of :class:`Floating`, and it cannot work the same way. A move
    carries the shape the object already drew; a resize *changes* that shape,
    and what an object draws is the game's own work -- so which blocks a wider
    ledge covers is not known until the loader has been asked again. There is
    nothing to shift.

    What is drawn instead is the extent being reached for: the outline's box
    with its far edge where the pointer has taken it, in the same blue as the
    marquee, which is already what "a boundary the editor drew" looks like
    here. The ants stay around what the object still is, so the two together
    say what is held and what it is being pulled to.

    Blocks, and the far edges only. A width and a height are extents from the
    record's own corner, so how far they reach is the whole of what an edge
    drag can say -- see ``MainWindow._grip_at`` for why the near edges are not
    offered.
    """

    uid: int
    columns: int
    rows: int

    def holds(self, record: LevelObject | Sprite) -> bool:
        return record.uid == self.uid

    def reaching(self, box: QRect) -> QRect:
        """``box`` with its right and bottom edges pulled out by the step."""
        return box.adjusted(0, 0, self.columns * BLOCK, self.rows * BLOCK)


#: How solid the ghost's artwork is. Enough to read what it is and what colour
#: it is, and short of enough to be mistaken for something already placed --
#: which matters because it is drawn over a level full of the same artwork. The
#: dashed line around it is what carries "not yet", and the wash is what stops
#: the picture arguing with it.
PLACING_OPACITY = 0.7


@dataclass(frozen=True)
class Placing:
    """Something not in the level yet, held over where it would land.

    The third of the marks a gesture carries, and the only one whose subject is
    not in the document at all: :class:`Floating` moves records that exist and
    :class:`Stretching` pulls an edge of one, while this is a record that will
    not exist until the button comes down.

    **It shows the thing itself where the thing is known.** ``art`` is the
    preview rendered from the level's own memories -- the blocks an object was
    traced drawing, or the tiles a sprite's own code emitted -- and where there
    is one, the ghost is that picture at its own size rather than a box of the
    record's claimed extent. Which is a change of footing worth stating: the
    record's rectangle was what was *available* before anything had been probed,
    and it is wrong for most objects and for every sprite bigger than a block.
    Now that the picture has been measured, drawing the measurement is the
    honest mark and the rectangle is the fallback.

    ``column`` and ``row`` are the block the record would be placed on.
    ``offset`` is where the picture sits against it, in image pixels, and is
    signed: a Koopa's artwork starts a block above the record that names it.
    """

    column: int
    row: int
    columns: int
    rows: int
    art: QImage | None = None
    offset: tuple[int, int] = (0, 0)

    @property
    def box(self) -> QRect:
        """The rectangle it would fill, in image pixels.

        The picture's own where there is one, so the outline lands on the
        artwork rather than around the block it is anchored to.
        """
        if self.art is not None and not self.art.isNull():
            return QRect(
                self.column * BLOCK + self.offset[0],
                self.row * BLOCK + self.offset[1],
                self.art.width(),
                self.art.height(),
            )
        return QRect(
            self.column * BLOCK,
            self.row * BLOCK,
            self.columns * BLOCK,
            self.rows * BLOCK,
        )


def outlined(
    obj: LevelObject, drawn: Mapping[int, frozenset[tuple[int, int]]] | None = None
) -> QRect:
    """The rectangle ``obj`` is outlined by, in image pixels.

    Around the blocks it drew where those are known and around its record's box
    where they are not -- which is exactly what :func:`level_overlays` marks it
    with. Public because a gesture aimed at an object's edge has to be aimed at
    the edge the eye can see, and for most objects the record's own rectangle is
    one block whatever it drew.
    """
    return _outline(obj, drawn or {}, OUTLINE_COLOR).rect


def level_overlays(
    objects: Iterable[LevelObject] = (),
    sprites: Iterable[Sprite] = (),
    selected: Iterable[LevelObject | Sprite] = (),
    sprite_art: Mapping[int, tuple[SpriteTile, ...]] | None = None,
    drawn: Mapping[int, frozenset[tuple[int, int]]] | None = None,
    marquee: QRect | None = None,
    floating: Floating | None = None,
    stretching: Stretching | None = None,
    placing: Placing | None = None,
) -> list[Overlay]:
    """Everything marked over a level, in paint order.

    The whole set, and therefore the statement of what the two halves below add
    up to. **The window does not call this**: a gesture rebuilds only
    :func:`moving_overlays` and reuses the resting marks it cached when the
    gesture began -- see :func:`resting_overlays` for what that is worth. What
    is here is the composition itself, which is the thing worth being able to
    read and to test in one piece.

    Each argument is independent and any of them can be empty: the object boxes
    are a mode, the sprite markers are another, and the selection is neither -
    with both modes off a selected object is still outlined, and it is then the
    only thing that is, which is the point of having the modes.

    ``sprite_art`` is the same capture the picture was composited from, and it
    is what a sprite's box is measured from - so the outline lands on the
    artwork rather than on the block the record names. Without it every sprite
    falls back to its block, which is what a byte map and an empty window have.

    ``drawn`` maps an object's uid to the blocks it actually drew
    (:mod:`shiny_mushroom.emu.footprints`). Given it, an object is outlined
    around what it drew - a slope as a slope, a pipe as an L - instead of around
    the rectangle its record admits to, which for most objects is one block.
    Keyed by **uid** rather than by stream offset, because an offset is a
    property of the bytes and every edit rewrites them: a record deleted from
    the middle shifts every offset after it, and each survivor would inherit
    its neighbour's tiles. The same map :func:`shiny_mushroom.objects.stack_at`
    is hit-tested against, so what is outlined is what a click reaches.

    ``selected`` is however many objects and sprites are held. Every one of them
    is marked the same way, because what the ants say is "this is part of what
    the next gesture will move", and that is the same statement for all of them
    -- there is deliberately no second colour for a primary one, because there
    is no primary one.

    ``marquee`` is the selection box being dragged, in image pixels. Drawn last
    of all: it is the only mark that is about the gesture rather than about the
    level, and it has to stay readable over the ants of everything it has just
    caught.

    ``floating`` is a move still in the hand (:class:`Floating`). Every mark
    around a record it names is drawn a step away from where that record is,
    and nothing else moves -- so what is dragged reads as lifted off the level
    rather than as part of it, which is exactly what it is until the button
    comes up. A record is shifted wherever it appears, box and ants together,
    because two outlines around the same thing in two places is a picture of a
    bug rather than of a gesture.

    ``stretching`` is a resize still in the hand (:class:`Stretching`), drawn
    as the extent the dragged edge is reaching for.

    ``placing`` is something armed but not yet placed (:class:`Placing`), drawn
    where a click would put it.

    The selection comes after the boxes so its ants survive every outline drawn
    over them.
    """
    return [
        *resting_overlays(objects, sprites, sprite_art, drawn, floating),
        *moving_overlays(
            objects,
            sprites,
            selected,
            sprite_art,
            drawn,
            marquee,
            floating,
            stretching,
            placing,
        ),
    ]


def resting_overlays(
    objects: Iterable[LevelObject] = (),
    sprites: Iterable[Sprite] = (),
    sprite_art: Mapping[int, tuple[SpriteTile, ...]] | None = None,
    drawn: Mapping[int, frozenset[tuple[int, int]]] | None = None,
    floating: Floating | None = None,
) -> list[Overlay]:
    """The marks around everything a gesture is **not** holding.

    Split out because this is the expensive half and the half that cannot change
    while a drag is in progress. Each object is outlined around the blocks it
    drew, which on a crowded level is thousands of rectangles -- and while
    :func:`_traced` keeps the tracing of a footprint that has not moved, the list
    itself is still rebuilt whole. A drag touches nothing in the document, so a
    caller can build this once when the gesture starts and rebuild only
    :func:`moving_overlays` as the pointer travels.
    """
    art = sprite_art or {}
    cells = drawn or {}
    resting = [
        Overlay(_sprite_box(sprite, art), OUTLINE_COLOR)
        for sprite in sprites
        if floating is None or not floating.carried(sprite)
    ]
    resting += [
        _outline(obj, cells, OUTLINE_COLOR)
        for obj in objects
        if floating is None or not floating.carried(obj)
    ]
    return resting


def moving_overlays(
    objects: Iterable[LevelObject] = (),
    sprites: Iterable[Sprite] = (),
    selected: Iterable[LevelObject | Sprite] = (),
    sprite_art: Mapping[int, tuple[SpriteTile, ...]] | None = None,
    drawn: Mapping[int, frozenset[tuple[int, int]]] | None = None,
    marquee: QRect | None = None,
    floating: Floating | None = None,
    stretching: Stretching | None = None,
    placing: Placing | None = None,
) -> list[Overlay]:
    """The marks a gesture moves: what is carried, what is selected, the box.

    Small by construction -- a handful of records rather than a level's worth --
    which is what makes it affordable to rebuild on every step of a drag.

    The selection's ants are here whether or not they are being carried, because
    a marquee changes what is selected on every frame of itself while leaving
    every outline in :func:`resting_overlays` exactly where it already was.

    **Each record's shape is traced once and worn three times.** The grey box,
    the ants' black line and their white dashes are the same outline in three
    colours, and tracing it means turning every block the object drew into a
    rectangle -- 576 of them for the largest object on level ``$105``. Doing that
    per overlay rather than per record was 2.8 ms on every step of a drag, which
    at a pointer crossing a block every few frames is the difference between a
    drag that keeps up and one that stutters.
    """
    art = sprite_art or {}
    cells = drawn or {}
    shapes: dict[int, Overlay] = {}

    def shape(thing: LevelObject | Sprite) -> Overlay:
        """``thing``'s outline in the resting colour, traced at most once."""
        if thing.uid not in shapes:
            shapes[thing.uid] = (
                Overlay(_sprite_box(thing, art), OUTLINE_COLOR)
                if isinstance(thing, Sprite)
                else _outline(thing, cells, OUTLINE_COLOR)
            )
        return shapes[thing.uid]

    carried = [
        thing
        for group in (sprites, objects)
        for thing in group
        if floating is not None and floating.carried(thing)
    ]
    moving = [floating.shift(shape(thing)) for thing in carried]
    for thing in selected:
        worn = shape(thing)
        for color, dash in ((SELECTION_LINE, 0), (SELECTION_DASH, DASH_LENGTH)):
            ants = replace(worn, color=color, dash=dash)
            moving.append(_placed(ants, thing, floating))
        # Over its own ants, and around the same traced shape they are: what a
        # resize is reaching for is only legible beside what the object still
        # is.
        if stretching is not None and stretching.holds(thing):
            reaching = stretching.reaching(worn.rect)
            moving += [
                Overlay(reaching, SELECTION_LINE),
                Overlay(reaching, MARQUEE_COLOR, dash=DASH_LENGTH),
            ]
    if marquee is not None:
        moving += [
            Overlay(marquee, SELECTION_LINE),
            Overlay(marquee, MARQUEE_COLOR, dash=DASH_LENGTH),
        ]
    # Last of everything, including the marquee: the ghost is the only mark
    # about a record that is not in the level, and it has to stay readable over
    # whatever it is about to be dropped on top of.
    if placing is not None:
        box = placing.box
        moving += [
            Overlay(box, SELECTION_LINE, image=placing.art, opacity=PLACING_OPACITY),
            Overlay(box, PLACING_COLOR, dash=DASH_LENGTH),
        ]
    return moving


def screen_overlays(rect: QRect) -> list[Overlay]:
    """The ants around a whole selected screen.

    The same two lines a held record wears, because it is the same statement:
    this is what the panel is describing and what an edit will land on. What
    differs is only its size -- a screen is the largest thing the editor lets
    you hold, and giving it a mark of its own would say it was a different
    *kind* of holding.
    """
    return [
        Overlay(rect, SELECTION_LINE),
        Overlay(rect, SELECTION_DASH, dash=DASH_LENGTH),
    ]


def _placed(
    overlay: Overlay, record: LevelObject | Sprite, floating: Floating | None
) -> Overlay:
    """``overlay`` where its record is, or a step away while it is being
    carried."""
    if floating is None or not floating.carried(record):
        return overlay
    return floating.shift(overlay)


def _outline(
    obj: LevelObject,
    drawn: Mapping[int, frozenset[tuple[int, int]]],
    color: QColor,
    dash: int = 0,
) -> Overlay:
    """One object's outline: around the blocks it drew where those are known,
    and around its record's rectangle where they are not.

    An object that drew *nothing* - a screen exit, a screen jump, or one whose
    tiles all fell outside the level - keeps its record's box, so it stays
    visible and selectable rather than vanishing from the picture.
    """
    blocks = drawn.get(obj.uid)
    if not blocks:
        return Overlay(_box(obj), color, dash=dash)
    bounding, cells = _traced(blocks)
    return Overlay(bounding, color, dash=dash, cells=cells)


@lru_cache(maxsize=256)
def _traced(blocks: frozenset[tuple[int, int]]) -> tuple[QRect, tuple[QRect, ...]]:
    """A set of blocks as its rectangles and the box around them.

    **Kept, keyed on the blocks themselves**, because the whole set is retraced
    far more often than any of it moves: every commit and every edit's refresh
    rebuilds the marks around a level's records, and an edit moves one of them.
    Measured on level ``$105``, tracing the other ninety-one again was 2.8 ms of
    each, twice per edit -- and a footprint is carried through an edit as the
    same frozenset, so the ones that did not move are found here by identity.

    The rectangles are shared between everything drawn from one footprint, which
    is what :func:`moving_overlays` already relied on when it traced a held
    record once and wore it three times. Nothing writes into an overlay's
    geometry: a shift or a resize hands back rectangles of its own.
    """
    cells = tuple(
        QRect(column * BLOCK, row * BLOCK, BLOCK, BLOCK)
        for column, row in sorted(blocks)
    )
    bounding = cells[0]
    for cell in cells[1:]:
        bounding = bounding.united(cell)
    return bounding, cells


def _box(obj: LevelObject) -> QRect:
    """An object's footprint, in image pixels."""
    return QRect(
        obj.column * BLOCK, obj.row * BLOCK, obj.width * BLOCK, obj.height * BLOCK
    )


def _sprite_box(sprite: Sprite, art: Mapping[int, tuple[SpriteTile, ...]]) -> QRect:
    """A sprite's footprint, in image pixels: the box its artwork fills, or its
    block when it draws nothing. The measuring is
    :func:`shiny_mushroom.sprites.bounds`, so the outline and the hit test are
    the same rectangle."""
    box = bounds(sprite, art)
    return QRect(box.left, box.top, box.width, box.height)
