"""The custom tiles as a document: one Lunar Magic ``.map16`` container, read
overlay-first, edited in memory, saved as the file the config ``incbin``\\ s,
and previewed as two byte patches.

**The container is the editable form, and the whole of it is the file.**
``smw/src/SMW/GFX/Map16/CustomTiles.map16`` is what ``Config/CustomTiles.asm``
slices the four custom pages and their acts-like words out of, so a copy in
the overlay *is* the edit -- exactly as a Map16 table's ``.bin`` is
(:mod:`shiny_mushroom.map16`) -- and Lunar Magic's own Map16 editor can open
the same bytes. What the cartridge holds of it, and where in the file that
sits, is :mod:`smw_tools.custom_tiles`; this module adds only what an editor
needs on top: a tile's eight bytes and its acts-like word read and written
by tile number, and the patch that shows a held container over a cartridge
image.

**A custom tile is a number from ``$200``.** Every function here takes the
tile's own number, the one the level tilemap holds and object ``27`` names,
and refuses one the cartridge does not hold.

Qt-free, like every module a document lives in.
"""

from __future__ import annotations

from collections.abc import Mapping
from pathlib import Path
from typing import TYPE_CHECKING

from smw_tools import custom_tiles as held
from smw_tools.map16 import TILE as DEF_SIZE

if TYPE_CHECKING:
    from shiny_mushroom.addresses import Addresses
    from smw_tools.symbols import SymbolTable

#: Where the container lives, relative to the disassembly's game folder.
CONTAINER = Path(held.CONTAINER)

#: The tiles the cartridge holds, as the numbers a level names them by.
FIRST_TILE = held.FIRST_TILE
END_TILE = held.END_TILE
TILE_COUNT = held.TILES
PAGES = held.PAGES
FIRST_PAGE = held.FIRST_PAGE

#: The two tables' labels, for a build's symbol file.
DEFINITIONS_LABEL = f"{held.NAMESPACE}_{held.LABELS[0]}"
ACTS_LIKE_LABEL = f"{held.NAMESPACE}_{held.LABELS[1]}"

#: What a custom tile may act like: any tile of the stock two pages or of the
#: pages held, which the cartridge chains through; a number past those is
#: answered by the default as though nothing were there.
ACTS_LIKE_MAX = END_TILE - 1


class CustomTilesError(ValueError):
    """A container the wrong size, or a tile the cartridge does not hold."""


def check(container: bytes) -> None:
    """Refuse anything that is not a whole Lunar Magic container."""
    if container[:4] != b"LM16":
        raise CustomTilesError("not a Lunar Magic .map16 container")
    if len(container) < held.ACTS_LIKE_OFFSET + held.ACTS_LIKE_BYTES:
        raise CustomTilesError(
            f"the container is {len(container):#x} bytes, too short to hold "
            "the custom pages' acts-like words"
        )


def is_custom(tile: int) -> bool:
    """Whether ``tile`` is on a page the cartridge holds."""
    return FIRST_TILE <= tile < END_TILE


def _at(tile: int) -> int:
    if not is_custom(tile):
        raise CustomTilesError(
            f"tile {tile:#05x} is not on a custom page the cartridge holds "
            f"({FIRST_TILE:#05x}-{END_TILE - 1:#05x})"
        )
    return held.DEFINITIONS_OFFSET + (tile - FIRST_TILE) * DEF_SIZE


def _acts_at(tile: int) -> int:
    _at(tile)
    return held.ACTS_LIKE_OFFSET + (tile - FIRST_TILE) * held.ACTS_LIKE_ENTRY


def definition_of(container: bytes, tile: int) -> bytes:
    """``tile``'s eight bytes: four tilemap words, upper left, lower left,
    upper right, lower right."""
    at = _at(tile)
    return container[at : at + DEF_SIZE]


def word_of(container: bytes, tile: int, quadrant: int) -> int:
    """One of ``tile``'s four words, by storage-order ``quadrant``."""
    at = _at(tile) + quadrant * 2
    return int.from_bytes(container[at : at + 2], "little")


def with_words(container: bytes, words: Mapping[tuple[int, int], int]) -> bytes:
    """The container with ``(tile, quadrant) -> word`` written in."""
    out = bytearray(container)
    for (tile, quadrant), word in words.items():
        at = _at(tile) + quadrant * 2
        out[at : at + 2] = (word & 0xFFFF).to_bytes(2, "little")
    return bytes(out)


def with_definition(container: bytes, tile: int, raw: bytes) -> bytes:
    """The container with ``tile``'s eight bytes replaced."""
    if len(raw) != DEF_SIZE:
        raise CustomTilesError(f"a definition is {DEF_SIZE} bytes, not {len(raw)}")
    at = _at(tile)
    return container[:at] + bytes(raw) + container[at + DEF_SIZE :]


def acts_like_of(container: bytes, tile: int) -> int:
    """The tile ``tile`` acts like, as its word says -- not chained."""
    at = _acts_at(tile)
    return int.from_bytes(container[at : at + 2], "little")


def with_acts_like(container: bytes, tile: int, acts: int) -> bytes:
    """The container with ``tile``'s acts-like word replaced."""
    at = _acts_at(tile)
    return container[:at] + (acts & 0xFFFF).to_bytes(2, "little") + container[at + 2 :]


def resolved_acts_like(container: bytes, tile: int) -> int:
    """The vanilla tile ``tile`` finally acts like, chained as the cartridge
    chains it (:func:`smw_tools.custom_tiles.resolve_acts_like`)."""
    return held.resolve_acts_like(held.acts_like(container), tile)


def definitions(container: bytes) -> bytes:
    """The cartridge's whole definition table, for a snapshot."""
    return held.definitions(container)


def changed_tiles(before: bytes, after: bytes) -> frozenset[int]:
    """Which custom tiles differ between two containers -- by definition or
    by acts-like word -- for a picture that repaints only those."""
    changed: set[int] = set()
    for tile in range(FIRST_TILE, END_TILE):
        if definition_of(before, tile) != definition_of(after, tile):
            changed.add(tile)
        elif acts_like_of(before, tile) != acts_like_of(after, tile):
            changed.add(tile)
    return frozenset(changed)


def addresses(
    where: Addresses, symbols: SymbolTable | None = None
) -> tuple[int, int] | None:
    """Where the two tables sit on ``where``'s cartridge -- out of its build's
    symbol file where there is one, the declaration otherwise -- or ``None``
    on a cartridge without the feature."""
    defs = where.custom_tiles_defs
    acts = where.custom_tiles_acts_like
    if symbols is not None:
        found = symbols.by_name.get(DEFINITIONS_LABEL)
        acted = symbols.by_name.get(ACTS_LIKE_LABEL)
        if found is not None and acted is not None:
            defs, acts = found.addr, acted.addr
    if defs is None or acts is None:
        return None
    return defs, acts


def patches(
    container: bytes,
    rom: bytes,
    where: Addresses,
    symbols: SymbolTable | None = None,
) -> dict[int, bytes]:
    """The held container over ``rom``: the definitions and the acts-like
    words, in place and same-size, wherever the image does not already hold
    them. Empty on a cartridge without the feature."""
    found = addresses(where, symbols)
    if found is None:
        return {}
    out: dict[int, bytes] = {}
    for address, data in zip(
        found, (held.definitions(container), held.acts_like(container)), strict=True
    ):
        offset = where.offset(address)
        if rom[offset : offset + len(data)] != data:
            out[offset] = data
    return out


__all__ = [
    "ACTS_LIKE_LABEL",
    "ACTS_LIKE_MAX",
    "CONTAINER",
    "DEFINITIONS_LABEL",
    "DEF_SIZE",
    "END_TILE",
    "FIRST_PAGE",
    "FIRST_TILE",
    "PAGES",
    "TILE_COUNT",
    "CustomTilesError",
    "acts_like_of",
    "addresses",
    "changed_tiles",
    "check",
    "definition_of",
    "definitions",
    "is_custom",
    "patches",
    "resolved_acts_like",
    "with_acts_like",
    "with_definition",
    "with_words",
    "word_of",
]
