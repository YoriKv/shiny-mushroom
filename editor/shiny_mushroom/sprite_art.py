"""What a sprite and the player look like, once something has drawn them.

The types a capture comes back as, and the two functions that put one through
a JSON header. A tile is five numbers -- no core, no cartridge, no Qt -- which
is what lets the editor draw a sprite from a capture taken in another process,
read one back off disk (:mod:`shiny_mushroom.emu.player_cache`) or hand one to
a future static renderer.

Outside :mod:`shiny_mushroom.emu` deliberately: importing anything in that
package loads the ctypes binding, and every module that paints a sprite --
:mod:`shiny_mushroom.preview`, :mod:`shiny_mushroom.sprites` and the ``ui``
side -- needs these types and nothing else from it. What *produces* them stays
where the core is: :class:`~shiny_mushroom.emu.sprite_probe.SpriteProbe` for a
level's sprites and the player,
:class:`~shiny_mushroom.emu.overworld_capture.OverworldCapture` for the map's.
"""

from __future__ import annotations

from collections.abc import Iterable, Sequence
from dataclasses import dataclass


@dataclass(frozen=True)
class SpriteTile:
    """One OAM object a sprite drew, placed relative to the sprite itself.

    A capture is a tuple of these **in ascending OAM object index**, which is
    front to back: the SNES draws a lower index in front of a higher one.
    Anything painting them has to go the other way -- see
    ``shiny_mushroom.sprites._back_to_front``.
    """

    #: Signed offset from the sprite's own position, in pixels.
    x: int
    y: int
    #: 0-511, indexing the sprite half of VRAM.
    tile: int
    #: ``YXPPCCCT``: the palette is bits 1-3 and selects CGRAM rows 8-15.
    attributes: int
    #: 16x16 rather than 8x8, which uses tiles ``n``, ``n+1``, ``n+16``,
    #: ``n+17``.
    large: bool

    @property
    def palette(self) -> int:
        """The CGRAM row, already offset into the sprite half."""
        return 8 + ((self.attributes >> 1) & 0x07)

    @property
    def x_flip(self) -> bool:
        return bool(self.attributes & 0x40)

    @property
    def y_flip(self) -> bool:
        return bool(self.attributes & 0x80)


def encode_tiles(tiles: Iterable[SpriteTile]) -> list[list[int | bool]]:
    """A capture as plain lists, small enough to ride in a JSON header.

    Positional and field-for-field with :func:`decode_tiles`, which is what
    makes a field added to :class:`SpriteTile` a change to both ends at once
    rather than a message the far side reads short.
    """
    return [[t.x, t.y, t.tile, t.attributes, t.large] for t in tiles]


def decode_tiles(rows: Iterable[Sequence[object]]) -> tuple[SpriteTile, ...]:
    """The capture :func:`encode_tiles` wrote, back as tiles."""
    return tuple(SpriteTile(*row) for row in rows)


@dataclass(frozen=True)
class PlayerArt:
    """What the player looks like, captured by making the game draw him.

    The tiles are placed relative to the player himself, exactly as
    :class:`SpriteTile` places a sprite's, so the same decoder draws both.

    **VRAM and CGRAM come with it, and that is the point rather than a
    convenience.** The player's tiles are DMA'd into the sprite pages per frame
    from his current pose, and a level snapshot's VRAM is taken in mode ``$13``
    -- before any of that has happened. Decoding these tiles against a
    snapshot's VRAM draws whatever else is at those tile numbers. So the
    memories captured *at the same moment as the tiles* travel with them.

    One capture serves every level: the player's graphics and his palette do
    not come from the level's tileset, which is why the editor takes this once
    and keeps it, rather than paying for it on every load the way sprite art is
    paid for.
    """

    tiles: tuple[SpriteTile, ...]
    vram: bytes
    cgram: bytes

    def __bool__(self) -> bool:
        """False when the capture found nothing, so a caller can treat a failed
        probe as "no marker" without inspecting its parts."""
        return bool(self.tiles)
