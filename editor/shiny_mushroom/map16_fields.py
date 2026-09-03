"""What the Map16 editor's selections offer the properties panel.

Two records over the same held table bytes, one per editing grid. A
:class:`CellsEntry` is one or many 8x8 **cells** -- each key one SNES tilemap
word, read and written exactly as the overworld's Layer 2 entries are
(:func:`shiny_mushroom.overworld_fields.layer2_fields` is the model). A
:class:`TilesEntry` is one or many 16x16 **tiles** -- each key a whole
eight-byte definition, shown but not edited: a definition is its four
words, every one of which the cells grain edits a row at a time, so a tile
offers only what a cell cannot say -- where it lives and its bytes whole.

Both records hold an immutable mapping of file name to held bytes rather
than a :class:`~shiny_mushroom.map16.Map16Tables`: a field write answers a
new record over new bytes, the same value discipline every other record
keeps, and the mode diffs the answer against the tables it owns to commit.

The **cell grid** is the sheet at 8x8: 32 cells wide, 64 tall, row-major
keys. Which tile a cell belongs to and which quadrant of it the cell is are
:func:`cell_tile`'s arithmetic; :func:`cell_key` is the inverse, for a
clipboard entry landing geometrically.

Qt-free, like every module a document lives in.
"""

from __future__ import annotations

from collections.abc import Callable, Mapping
from dataclasses import dataclass, replace

from shiny_mushroom.fields import Field, Number, Switch, readout
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.map16 import DEF_SIZE, TILE_COUNT, file_of, is_shared
from shiny_mushroom.overworld_fields import (
    CHAR_MASK,
    MIXED,
    PALETTE_MASK,
    PRIORITY_MASK,
    X_FLIP_MASK,
    Y_FLIP_MASK,
)

#: The sheet's geometry: 16 tiles to a row, and the cell grid at twice that.
SHEET_COLUMNS = 16
SHEET_ROWS = TILE_COUNT // SHEET_COLUMNS
CELL_COLUMNS = SHEET_COLUMNS * 2
CELL_ROWS = SHEET_ROWS * 2

#: The four quadrants in **reading** order, each with its offset within the
#: tile and its index into the definition's storage order (upper-left,
#: lower-left, upper-right, lower-right).
QUADRANTS: tuple[tuple[str, str, int, int, int], ...] = (
    ("ul", "Upper left", 0, 0, 0),
    ("ur", "Upper right", 1, 0, 2),
    ("ll", "Lower left", 0, 1, 1),
    ("lr", "Lower right", 1, 1, 3),
)


def cell_spot(x: int, y: int) -> int | None:
    """The cell key at grid spot ``(x, y)``, or ``None`` off the sheet."""
    if 0 <= x < CELL_COLUMNS and 0 <= y < CELL_ROWS:
        return y * CELL_COLUMNS + x
    return None


def cell_at(key: int) -> tuple[int, int]:
    """``key``'s grid spot, :func:`cell_spot`'s inverse."""
    return key % CELL_COLUMNS, key // CELL_COLUMNS


def cell_tile(key: int) -> tuple[int, int]:
    """Which tile a cell belongs to, and which storage-order quadrant of it
    the cell is."""
    x, y = cell_at(key)
    tile = (y // 2) * SHEET_COLUMNS + x // 2
    # Storage order runs down each column first: UL, LL, UR, LR.
    quadrant = (x % 2) * 2 + y % 2
    return tile, quadrant


def cell_key(tile: int, quadrant: int) -> int:
    """The cell key of ``tile``'s storage-order ``quadrant`` --
    :func:`cell_tile`'s inverse."""
    x = (tile % SHEET_COLUMNS) * 2 + quadrant // 2
    y = (tile // SHEET_COLUMNS) * 2 + quadrant % 2
    return y * CELL_COLUMNS + x


def tile_spot(x: int, y: int) -> int | None:
    """The tile number at sheet grid spot ``(x, y)``, or ``None`` off it."""
    if 0 <= x < SHEET_COLUMNS and 0 <= y < SHEET_ROWS:
        return y * SHEET_COLUMNS + x
    return None


def tile_at(tile: int) -> tuple[int, int]:
    """``tile``'s sheet grid spot, :func:`tile_spot`'s inverse."""
    return tile % SHEET_COLUMNS, tile // SHEET_COLUMNS


def file_note(tile: int, tileset: int, castle: str) -> str:
    """Where ``tile``'s bytes live and how far an edit of them reaches --
    the footer the old dialog carried, now a heading's and status line's.

    Three answers, not two: the numbers tilesets 0 and 7 repoint at
    ``SlopedPipeTiles`` at level load answer shared by
    :func:`~shiny_mushroom.map16.is_shared`'s reckoning -- the override is
    the tileset's, not the table's -- but an edit of that file reaches only
    those two tilesets' levels, and the note says so.
    """
    name, _ = file_of(tile, tileset, castle)
    if name == "SlopedPipeTiles":
        return f"{name}.bin — read by tilesets $00 and $07 only"
    return (
        f"{name}.bin — shared by every tileset"
        if is_shared(tile)
        else f"{name}.bin — this tileset's own"
    )


@dataclass(frozen=True)
class _Words:
    """Held file bytes read and written as tilemap words.

    The base both records share: a word is named by ``(file, byte offset)``,
    and a write answers a new mapping with those words replaced.
    """

    files: Mapping[str, bytes]
    tileset: int
    castle: str

    def word_in(self, name: str, at: int) -> int:
        data = self.files[name]
        return int.from_bytes(data[at : at + 2], "little")

    def _written(self, changes: Mapping[tuple[str, int], int]) -> dict[str, bytes]:
        edited: dict[str, bytearray] = {}
        for (name, at), word in changes.items():
            held = edited.setdefault(name, bytearray(self.files[name]))
            held[at : at + 2] = (word & 0xFFFF).to_bytes(2, "little")
        return {
            name: bytes(edited[name]) if name in edited else data
            for name, data in self.files.items()
        }


@dataclass(frozen=True)
class CellsEntry(_Words):
    """One or many 8x8 cells under edit, keyed by the cell grid."""

    keys: frozenset[int] = frozenset()

    def _place(self, key: int) -> tuple[str, int]:
        tile, quadrant = cell_tile(key)
        name, at = file_of(tile, self.tileset, self.castle)
        return name, at + quadrant * 2

    def _word(self, key: int) -> int:
        return self.word_in(*self._place(key))

    def uniform(self, extract: Callable[[int], int]) -> int:
        """What ``extract`` answers over every key, or :data:`MIXED`."""
        values = {extract(self._word(key)) for key in self.keys}
        return values.pop() if len(values) == 1 else MIXED

    def with_bits(self, mask: int, bits: int) -> CellsEntry:
        """This entry with ``mask``'s bits set to ``bits`` on every key."""
        changes = {
            self._place(key): (self._word(key) & ~mask & 0xFFFF) | bits
            for key in self.keys
        }
        return replace(self, files=self._written(changes))


@dataclass(frozen=True)
class TilesEntry(_Words):
    """One or many 16x16 tiles under edit, keyed by tile number."""

    keys: frozenset[int] = frozenset()

    def _place(self, tile: int, quadrant: int) -> tuple[str, int]:
        name, at = file_of(tile, self.tileset, self.castle)
        return name, at + quadrant * 2

    def word_of(self, tile: int, quadrant: int) -> int:
        return self.word_in(*self._place(tile, quadrant))

    def raw(self, tile: int) -> bytes:
        """One tile's eight held bytes."""
        name, at = file_of(tile, self.tileset, self.castle)
        return self.files[name][at : at + DEF_SIZE]

    def unused(self) -> bool:
        """Whether every key holds the all-``$FF`` unused definition."""
        return all(self.raw(tile) == b"\xff" * DEF_SIZE for tile in self.keys)

    def _one(self, of: Callable[[int], str]) -> str:
        """What ``of`` answers over every key, or ``mixed``."""
        answers = {of(tile) for tile in self.keys}
        return answers.pop() if len(answers) == 1 else "mixed"

    def file(self) -> str:
        """Where the tiles' bytes live and how far an edit reaches, or
        ``mixed`` across files."""
        return self._one(lambda tile: file_note(tile, self.tileset, self.castle))

    def definition(self) -> str:
        """The held bytes as hex, or ``mixed`` where the tiles differ."""
        return self._one(lambda tile: self.raw(tile).hex().upper())


def _mixed_hex(value: int, digits: int) -> str:
    return "mixed" if value == MIXED else hexnum(value, digits)


def _cell_flag(entry: CellsEntry, key: str, label: str, mask: int, hint: str) -> Field:
    return Field(
        key=key,
        label=label,
        kind=Switch(),
        read=lambda e, mask=mask: e.uniform(lambda word: 1 if word & mask else 0),
        write=lambda e, value, mask=mask: e.with_bits(mask, mask if value else 0),
        hint=hint,
    )


def cell_fields(entry: CellsEntry) -> list[Field]:
    """What one or many cells offer for editing: the Layer 2 entry's own
    set, over a definition's word -- with the char editable here, because a
    cell of the sheet has no palette to be placed from until the Map16 dock
    arms one."""
    return [
        Field(
            key="cell-tile",
            label="Tile",
            kind=Number(0, CHAR_MASK, hexadecimal=True, digits=3),
            read=lambda e: e.uniform(lambda word: word & CHAR_MASK),
            write=lambda e, value: e.with_bits(CHAR_MASK, value & CHAR_MASK),
            hint="The 8x8 char this cell names, into the four graphics slots.",
        ),
        Field(
            key="palette-row",
            label="Palette row",
            kind=Number(0, 7),
            read=lambda e: e.uniform(lambda word: (word >> 10) & 7),
            write=lambda e, value: e.with_bits(PALETTE_MASK, (value & 7) << 10),
            hint="Which sixteen-colour row the char's pixels index.",
        ),
        _cell_flag(
            entry, "x-flip", "X flip", X_FLIP_MASK, "Mirror the char left to right."
        ),
        _cell_flag(
            entry, "y-flip", "Y flip", Y_FLIP_MASK, "Mirror the char top to bottom."
        ),
        _cell_flag(
            entry,
            "priority",
            "Priority",
            PRIORITY_MASK,
            "Draw this char in front of lower-priority layers.",
        ),
        readout(
            "Entry",
            lambda e: _mixed_hex(e.uniform(lambda word: word), 4),
            hint="The raw tilemap word, attributes included.",
        ),
    ]


def tile_fields(entry: TilesEntry) -> list[Field]:
    """What one or many tiles offer: only what the cells grain cannot say.

    A definition is its four words, and each of them is edited at the
    Cells grain as one row apiece -- char, palette row, flips, priority.
    Repeating those here four times over, prefixed by corner, said the same
    thing twice; what is left is the tile's own.
    """
    del entry
    return [
        readout(
            "File",
            lambda e: e.file(),
            hint="The table file holding this definition, and how far an "
            "edit of it reaches.",
        ),
        readout(
            "Definition",
            lambda e: e.definition(),
            hint="The eight held bytes: four tilemap words in storage order "
            "-- upper left, lower left, upper right, lower right. Switch "
            "to Cells (8x8) to edit them.",
        ),
    ]
