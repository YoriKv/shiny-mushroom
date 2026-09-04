"""What the custom tiles sheet's selections offer the properties panel.

The Map16 tables' two records (:mod:`shiny_mushroom.map16_fields`) over the
container instead of the table files: a :class:`CustomCellsEntry` is one or
many 8x8 cells, each an SNES tilemap word edited with the same field set the
tables' cells get -- :func:`~shiny_mushroom.map16_fields.cell_fields` reads
and writes a record through ``uniform`` and ``with_bits`` and nothing else,
so it takes this one as readily -- and a :class:`CustomTilesEntry` is one or
many 16x16 tiles, which is where a custom tile has something the stock ones
do not: an **acts-like** word of its own, edited here.

Both records hold the container's bytes rather than a document object: a
field write answers a new record over new bytes, and the sheet commits the
answer onto its history.

Qt-free, like every module a document lives in.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass, replace

from shiny_mushroom import custom_tiles
from shiny_mushroom.fields import Field, Number, readout
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.overworld_fields import MIXED


@dataclass(frozen=True)
class CustomCellsEntry:
    """One or many 8x8 cells under edit, keyed by ``(tile, quadrant)``."""

    container: bytes
    keys: frozenset[tuple[int, int]] = frozenset()

    def _word(self, key: tuple[int, int]) -> int:
        return custom_tiles.word_of(self.container, *key)

    def uniform(self, extract: Callable[[int], int]) -> int:
        """What ``extract`` answers over every key, or :data:`MIXED`."""
        values = {extract(self._word(key)) for key in self.keys}
        return values.pop() if len(values) == 1 else MIXED

    def with_bits(self, mask: int, bits: int) -> CustomCellsEntry:
        """This entry with ``mask``'s bits set to ``bits`` on every key."""
        changes = {key: (self._word(key) & ~mask & 0xFFFF) | bits for key in self.keys}
        return replace(self, container=custom_tiles.with_words(self.container, changes))


@dataclass(frozen=True)
class CustomTilesEntry:
    """One or many custom tiles under edit, keyed by tile number."""

    container: bytes
    keys: frozenset[int] = frozenset()

    def acts_like(self) -> int:
        """The acts-like word every key holds, or :data:`MIXED`."""
        values = {custom_tiles.acts_like_of(self.container, tile) for tile in self.keys}
        return values.pop() if len(values) == 1 else MIXED

    def resolved(self) -> str:
        """The vanilla tile every key finally acts like, chained as the
        cartridge chains it, or ``mixed``."""
        values = {
            custom_tiles.resolved_acts_like(self.container, tile) for tile in self.keys
        }
        return hexnum(values.pop(), 3) if len(values) == 1 else "mixed"

    def with_acts_like(self, value: int) -> CustomTilesEntry:
        """This entry with every key acting like ``value``."""
        container = self.container
        for tile in self.keys:
            container = custom_tiles.with_acts_like(container, tile, value)
        return replace(self, container=container)

    def definition(self) -> str:
        """The held bytes as hex, or ``mixed`` where the tiles differ."""
        values = {
            custom_tiles.definition_of(self.container, tile).hex().upper()
            for tile in self.keys
        }
        return values.pop() if len(values) == 1 else "mixed"


def custom_tile_fields(entry: CustomTilesEntry) -> list[Field]:
    """What one or many custom tiles offer: the acts-like word, which is
    theirs alone, and the definition whole -- its four words are edited at
    the cells grain, as a table tile's are."""
    del entry
    return [
        Field(
            key="acts-like",
            label="Acts like",
            kind=Number(0, custom_tiles.ACTS_LIKE_MAX, hexadecimal=True, digits=3),
            read=lambda e: e.acts_like(),
            write=lambda e, value: e.with_acts_like(value),
            hint="The Map16 tile this one borrows its interaction from: a "
            "stock tile on page 0 or 1, or another custom tile, which the "
            "game follows on to its own. Every collision sees that tile.",
        ),
        readout(
            "Resolved",
            lambda e: e.resolved(),
            hint="The stock tile the chain of acts-like words ends on -- the "
            "cement block where it never reaches one.",
        ),
        readout(
            "Definition",
            lambda e: e.definition(),
            hint="The eight held bytes: four tilemap words in storage order "
            "-- upper left, lower left, upper right, lower right. Switch "
            "to Cells (8x8) to edit them.",
        ),
    ]


__all__ = ["CustomCellsEntry", "CustomTilesEntry", "custom_tile_fields"]
