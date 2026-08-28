"""The level's pixels, and everything painted over them.

One buffer is the level as :mod:`shiny_mushroom.level` drew it and nothing else;
the other is that with the sprites and the player marker on top, and it is the
one the canvas shows. Keeping the two apart is what lets an edit rewrite a
handful of blocks instead of re-rendering a level -- and what stops a sprite that
has moved leaving its old pixels behind forever.

That invariant is the whole reason this is an object rather than four fields on
the window. Every write goes into the clean copy and every repaint starts from
it, and there is now one place where that can be got wrong instead of three.

**It decides nothing.** Which layers are on, whether the sprites are shown,
where the player is standing -- all of that arrives as an argument, because they
are answers about the level and the person looking at it rather than about a
buffer. What this owns is the buffers, the sprite plane cached beside them, and
the arithmetic of getting from one to the other.
"""

from __future__ import annotations

from PySide6.QtGui import QImage

from shiny_mushroom.level import render_layers
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.rom_patches import PlayerPosition
from shiny_mushroom.sprite_art import PlayerArt
from shiny_mushroom.sprites import Sprite, SpritePlane, paint_into, plane, player_plane
from shiny_mushroom.ui.render import pixels_to_image


class Picture:
    """The two buffers a level is shown through, and the plane over them."""

    def __init__(self) -> None:
        # The level as the renderer drew it, and that with the sprites and the
        # player over it. Two, so a patch always lands on pixels nothing has
        # been painted over -- see :meth:`compose`.
        self._clean: bytearray | None = None
        self._composed: bytearray | None = None
        self._size: tuple[int, int] | None = None
        # What the level's sprites paint, decoded once, beside everything it
        # was decoded from -- see :meth:`_sprite_plane`.
        self._plane: SpritePlane | None = None
        self._plane_from: tuple | None = None

    @property
    def drawn(self) -> bool:
        """Whether there is a level in here to patch or repaint."""
        return self._clean is not None and self._size is not None

    @property
    def clean(self) -> bytes | None:
        """The level's own pixels, with nothing painted over them.

        Read-only to callers by convention -- it is handed out for comparison
        and for tests, and writing into it behind :meth:`patch` would put the
        picture out of step with the snapshot it was drawn from.
        """
        return None if self._clean is None else bytes(self._clean)

    @property
    def plane(self) -> SpritePlane | None:
        """The sprite plane as currently cached, or ``None`` before one is."""
        return self._plane

    def forget(self) -> None:
        """Drop everything. There is no level, so there are no pixels of one."""
        self._clean = None
        self._composed = None
        self._size = None
        self._plane = None
        self._plane_from = None

    def render(
        self, snapshot: LevelSnapshot, *, layer2: bool, layer3: bool, layer1: bool
    ) -> None:
        """Draw the whole level again from ``snapshot``.

        The expensive way -- 11 to 37 ms, Layer 1 alone against Layer 1
        composited over the other two -- and an edit does not use it: see
        :meth:`patch`. It is still the cheap half of a reload,
        which costs the emulator ~260 ms, so there is no reason to cache a
        second picture of the same level.
        """
        raster = render_layers(snapshot, layer2=layer2, layer3=layer3, layer1=layer1)
        self._clean = bytearray(raster.pixels)
        self._composed = bytearray(raster.pixels)
        self._size = (raster.width, raster.height)

    def patch(self, runs: tuple[tuple[int, bytes], ...]) -> None:
        """Redraw only the blocks an edit changes.

        Four of level ``$105``'s 8,640 for a single-object move, so a refresh is
        a few dozen row writes plus the sprites rather than ~37 ms of drawing a
        level that is already on the canvas.

        Written into the **clean** buffer, never the composed one: see
        :meth:`compose` for why there are two.
        """
        if self._clean is None:
            return
        for offset, pixels in runs:
            self._clean[offset : offset + len(pixels)] = pixels

    def compose(
        self,
        snapshot: LevelSnapshot,
        sprites: tuple[Sprite, ...],
        *,
        show_sprites: bool,
        player_art: PlayerArt | None,
        marker: PlayerPosition | None,
    ) -> QImage | None:
        """Lay the sprites and the player over the level, as a ``QImage``.

        **The second buffer is not an optimisation.** Painting into one buffer
        and patching it later works only as long as nothing painted *over* the
        patch ever moves -- and a dragged sprite would leave its old pixels
        behind forever, because no block underneath it changed. Starting
        each repaint from the clean copy costs 0.5 ms for six megabytes and
        removes the whole class of ghost. It is also what lets the player marker
        move for a repaint rather than a re-render.

        The sprites go on in full every time, because a block that moved can sit
        under one -- writing the block over it would leave a hole where the
        sprite is. Laying the whole plane down again is 1.5 ms and needs no
        reasoning about which sprite overlaps what.

        ``None`` when there is nothing drawn yet, which is the same answer as
        "there is no level".
        """
        if self._clean is None or self._size is None:
            return None
        if self._composed is None or len(self._composed) != len(self._clean):
            self._composed = bytearray(self._clean)
        else:
            self._composed[:] = self._clean
        width, height = self._size
        if show_sprites:
            paint_into(
                self._composed,
                width,
                height,
                self._sprite_plane(snapshot, sprites, width, height),
            )
        # The player goes on last, over everything, because he is where the
        # level *starts* -- something standing in front of it rather than part
        # of it. Decoded on every repaint rather than cached: he is two tiles,
        # he moves whenever the marker does, and a plane keyed on his position
        # would be rebuilt as often as it was used.
        if marker is not None and player_art:
            paint_into(
                self._composed,
                width,
                height,
                player_plane(
                    width,
                    height,
                    player_art.tiles,
                    marker,
                    player_art.vram,
                    player_art.cgram,
                ),
            )
        return pixels_to_image(self._composed, width, height)

    def _sprite_plane(
        self,
        snapshot: LevelSnapshot,
        sprites: tuple[Sprite, ...],
        width: int,
        height: int,
    ) -> SpritePlane:
        """What this level's sprites paint, decoded on demand and kept.

        **Kept beside everything it was decoded from, and rebuilt when any of it
        moves.** A cache invalidated by somebody else calling in is one that goes
        stale the first time a path forgets to -- and one did: a refresh dropped
        the plane on the arriving *snapshot's* sprite stream changing, so a load
        that came back with a stale stream left the old plane in place, and the
        canvas went on drawing deleted sprites and drawing nothing for new ones.
        So the cache is a function of its inputs and nothing tells it anything:
        the records, their captured artwork, and the two memories they are
        decoded against.

        The size goes in as well, because it is the other thing that makes a
        plane's offsets wrong -- a header edit that changes the level's length.

        **The comparison is cheap against what it saves.** A few dozen frozen
        records, a dozen captures and a memcmp of 64 KB, against the ~9 ms of
        decoding -- and it is only reached on a repaint, which already copies
        megabytes. What it buys is that the plane survives every reload that
        changed none of it, which is every object edit.
        """
        from_ = (sprites, snapshot.sprite_art, snapshot.vram, snapshot.cgram)
        if (
            self._plane is None
            or self._plane_from != from_
            or (self._plane.width, self._plane.height) != (width, height)
        ):
            self._plane = plane(
                width,
                height,
                sprites,
                snapshot.sprite_art,
                snapshot.vram,
                snapshot.cgram,
            )
            self._plane_from = from_
        return self._plane
