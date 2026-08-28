"""The world map's sprite markers and the gestures that move them.

Each slot is drawn at every spot its type appears -- the main-map half, the
submap half, or both, with the ghost offsets applied where the game applies
them -- wearing the artwork the capture answered for its number, and the level
editor's own numbered glyph (:data:`shiny_mushroom.glyphs.MISSING`) where it
answered none -- the same amber circle a level's uncaptured sprite wears,
because it is the same statement about the same kind of gap.
Empty slots draw dimmed, so all thirteen stay findable and re-typeable.
The player's captured figure gets the same image treatment for the spawn
marker, through :func:`player_marker_image`.

The markers are canvas overlays rather than pixels in the map's buffer: they
sit in front of the picture the way the game's sprites sit in front of its
layers, and a drag moves them without repainting anything.

:class:`SpriteDrag` is the one piece of state a drag needs -- which slot was
grabbed, where on the marker, and where it is now -- kept here so the mode
commits a single move when the button comes up.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass, replace

from PySide6.QtCore import QPoint, QRect
from PySide6.QtGui import QImage

from shiny_mushroom import glyphs
from shiny_mushroom.level import BLOCK
from shiny_mushroom.overworld import OverworldSprite, WorldMap, sprite_markers
from shiny_mushroom.overworld import sprite_spots as _spots
from shiny_mushroom.rom_patches import PlayerPosition
from shiny_mushroom.sprite_art import PlayerArt, SpriteTile
from shiny_mushroom.sprites import (
    Bounds,
    Sprite,
    SpritePlane,
    artwork,
    bounds,
    plane,
    player_bounds,
    player_plane,
)

#: How see-through an empty slot's marker is. Present enough to find, faint
#: enough that the thirteen do not read as thirteen sprites.
EMPTY_OPACITY = 0.35

_images: dict[int, QImage] = {}


def glyph_image(sprite_id: int) -> QImage:
    """The marker for one sprite number, cached -- a glyph with the number
    in it, block-sized, transparent outside its shape."""
    held = _images.get(sprite_id)
    if held is not None:
        return held
    image = QImage(BLOCK, BLOCK, QImage.Format.Format_ARGB32)
    image.fill(0)
    grid = glyphs.pixels(glyphs.MISSING, f"{sprite_id:02X}")
    for y, row in enumerate(grid):
        for x, color in enumerate(row):
            if color is not None:
                image.setPixel(x, y, 0xFF000000 | int.from_bytes(color, "big"))
    _images[sprite_id] = image
    return image


def sprite_art_image(
    number: int,
    art: Mapping[int, tuple[SpriteTile, ...]],
    vram: bytes,
    cgram: bytes,
) -> tuple[QImage, QPoint] | None:
    """One captured sprite as a transparent image, and where its top-left
    corner sits relative to the sprite's own position.

    Through :func:`~shiny_mushroom.sprites.plane`, the same decoder that
    draws a level's sprites -- but composed into an ARGB image rather than
    runs over a picture, because a marker is a canvas overlay and moves
    without repainting the map. ``None`` where the capture has nothing --
    including tiles that decode to no opaque pixel at all, which would be an
    invisible marker -- so the glyph stays the fallback for everything that
    does not actually render.
    """
    tiles, _ = artwork(number, art)
    if not tiles:
        return None
    # Stand the record on a block that puts every pixel at a nonnegative
    # coordinate: tile offsets are signed and reach above and left.
    probe = bounds(Sprite(number=number, column=0, row=0, screen=0, extra_bits=0), art)
    column = (max(0, -probe.left) + BLOCK - 1) // BLOCK
    row = (max(0, -probe.top) + BLOCK - 1) // BLOCK
    record = Sprite(number=number, column=column, row=row, screen=0, extra_bits=0)
    box = bounds(record, art)
    drawn = plane(
        box.left + box.width, box.top + box.height, [record], art, vram, cgram
    )
    if not drawn.runs:
        return None
    return _plane_image(drawn, box), QPoint(probe.left, probe.top)


def player_marker_image(art: PlayerArt) -> tuple[QImage, QPoint] | None:
    """The captured player as a transparent image, and where its top-left
    corner sits relative to the position he stands at.

    :func:`sprite_art_image`'s treatment for the one figure that is not a
    sprite record: laid out by :func:`~shiny_mushroom.sprites.player_plane`,
    against the VRAM and CGRAM that travelled with the capture. ``None`` when
    the capture answered nothing drawable, so the caller keeps whatever it
    showed without one.
    """
    if not art:
        return None
    probe = player_bounds(art.tiles, PlayerPosition(0, 0))
    at = PlayerPosition(max(0, -probe.left), max(0, -probe.top))
    box = player_bounds(art.tiles, at)
    drawn = player_plane(
        box.left + box.width, box.top + box.height, art.tiles, at, art.vram, art.cgram
    )
    if not drawn.runs:
        return None
    return _plane_image(drawn, box), QPoint(probe.left, probe.top)


def _plane_image(drawn: SpritePlane, box: Bounds) -> QImage:
    """A decoded plane's runs as a transparent ARGB image of ``box``."""
    image = QImage(box.width, box.height, QImage.Format.Format_ARGB32)
    image.fill(0)
    stride = drawn.width * 3
    for offset, pixels in drawn.runs:
        y = offset // stride - box.top
        x = (offset % stride) // 3 - box.left
        for i in range(len(pixels) // 3):
            r, g, b = pixels[i * 3 : i * 3 + 3]
            image.setPixel(x + i, y, 0xFF000000 | (r << 16) | (g << 8) | b)
    return image


@dataclass(frozen=True)
class Marker:
    """One drawn instance of a slot: where it sits, and what it is.

    ``submap_half`` says which copy this is -- the shared submap area's, or
    the main map's. Carried because the two halves are drawn under different
    palettes, the main map's and the framed submap's.
    """

    sprite: OverworldSprite
    rect: QRect
    submap_half: bool = False


def markers(
    document: WorldMap,
    moved: SpriteDrag | None = None,
    boxes: Mapping[int, QRect] | None = None,
) -> list[Marker]:
    """Every marker instance the map shows, in slot order.

    ``moved`` substitutes an in-flight drag's position for its slot, so the
    marker tracks the pointer while the document waits for the release.
    ``boxes`` is each sprite number's drawn box relative to its position --
    the captured artwork's reach -- and a number without one keeps the
    glyph's block.
    """
    found: list[Marker] = []
    for sprite in sprite_markers(document):
        if moved is not None and moved.slot == sprite.slot:
            sprite = replace(sprite, x=moved.x, y=moved.y)
        box = (boxes or {}).get(sprite.sprite_id, QRect(0, 0, BLOCK, BLOCK))
        for spot in _spots(sprite):
            found.append(
                Marker(
                    sprite,
                    box.translated(spot.x, spot.y),
                    submap_half=spot.submap_half,
                )
            )
    return found


def slot_at(shown: Iterable[Marker], point: QPoint) -> int | None:
    """The slot whose marker is under ``point``, or ``None``.

    Later slots win an overlap -- they are drawn later, so the one on top is
    the one picked. The markers are handed in rather than built here, because
    whether a marker is *reachable* is the caller's: the world map mode
    answers nothing at all while another layer is being edited.
    """
    held: int | None = None
    for marker in shown:
        if marker.rect.contains(point):
            held = marker.sprite.slot
    return held


@dataclass(frozen=True)
class SpriteDrag:
    """A marker mid-drag: the slot, and where its position is right now.

    ``anchor`` is the canvas point minus the document position at the grab --
    it folds together where on the marker the pointer took hold and which
    copy (main half, submap half, ghost-offset) was grabbed, so the marker
    tracks the pointer without jumping, and a drag of the submap copy still
    moves the one shared position.
    """

    slot: int
    anchor: QPoint
    x: int
    y: int

    @classmethod
    def begun(cls, document: WorldMap, slot: int, point: QPoint) -> SpriteDrag:
        # The anchor is measured against the document position, not the
        # grabbed copy's rectangle: each copy sits at position plus a fixed
        # display offset, so the offset cancels and the grip holds on
        # whichever copy was taken.
        sprite = document.sprite(slot)
        return cls(
            slot,
            point - QPoint(sprite.x, sprite.y),
            sprite.x,
            sprite.y,
        )

    def moved(self, point: QPoint) -> SpriteDrag:
        """This drag with the position under ``point``, in map pixels."""
        return SpriteDrag(
            self.slot,
            self.anchor,
            point.x() - self.anchor.x(),
            point.y() - self.anchor.y(),
        )
