"""The custom tiles: Map16 pages past the stock two, and the objects that place them.

The stock game defines 512 Map16 tiles, pages ``$00`` and ``$01``, resolved
per tileset at level load. Lunar Magic adds pages ``$02`` upward as one flat
table -- a tile there is the same block in every level -- with a two-byte
*acts-like* word per tile naming the vanilla tile it borrows interaction
from, and four standard objects that put such tiles into a level: ``22`` and
``23`` place one page-0 or page-1 tile over a rectangle, ``27`` and ``29`` a
tile or a rectangle of consecutive tiles off any page. The
``custom-tiles`` feature (``Config/CustomTiles.asm``) gives this cartridge
the same: :data:`PAGES` pages from :data:`FIRST_PAGE`, their definitions and
acts-like words sliced by ``incbin`` out of one Lunar Magic ``.map16``
container the tree ships and a project overlays, and the four objects.

This module is the shared vocabulary: where the pages sit in a container,
how the cartridge's tables are laid out, and the grammar of the object
records -- which the editor's parser and the cartridge's routines have to
agree on byte for byte.
"""

from __future__ import annotations

from dataclasses import dataclass

from . import map16

#: The first custom page, and how many the cartridge holds.
FIRST_PAGE = 0x02
PAGES = 0x04

#: The tile numbers the pages cover.
FIRST_TILE = FIRST_PAGE * map16.PAGE
TILES = PAGES * map16.PAGE
END_TILE = FIRST_TILE + TILES

#: Bytes per acts-like entry: one 16-bit vanilla tile number.
ACTS_LIKE_ENTRY = 2

#: What the definitions and the acts-like words come to in the cartridge.
DEFINITION_BYTES = TILES * map16.TILE
ACTS_LIKE_BYTES = TILES * ACTS_LIKE_ENTRY

#: What a fresh custom tile acts like: Lunar Magic's own default for one,
#: the cement block.
ACTS_LIKE_DEFAULT = map16.ACTS_DEFAULT

#: How many acts-like lookups the cartridge chains before giving up: a
#: custom tile may act like another custom tile, and a cycle would otherwise
#: never end.
ACTS_LIKE_DEPTH = 8

#: Where the shipped container is, repository-relative to the game folder,
#: and the ``incbin`` ranges the config slices out of it.
CONTAINER = "GFX/Map16/CustomTiles.map16"
DEFINITIONS_OFFSET = map16.definitions_offset(FIRST_PAGE)
ACTS_LIKE_OFFSET = map16.acts_like_offset(FIRST_PAGE)

#: The tables' roles, in the order the block emits them.
ROLES = ("custom_tiles_definitions", "custom_tiles_acts_like")
LABELS = ("Definitions", "ActsLike")
NAMESPACE = "SMW_CustomTiles"


def definitions(container: bytes) -> bytes:
    """The cartridge's definition table, as sliced out of ``container``."""
    return container[DEFINITIONS_OFFSET : DEFINITIONS_OFFSET + DEFINITION_BYTES]


def acts_like(container: bytes) -> bytes:
    """The cartridge's acts-like table, as sliced out of ``container``."""
    return container[ACTS_LIKE_OFFSET : ACTS_LIKE_OFFSET + ACTS_LIKE_BYTES]


def shipped_container(tables: dict[str, bytes]) -> bytes:
    """The container the tree ships: the stock tables on pages 0 and 1, the
    custom pages empty, and every acts-like word Lunar Magic's default.

    :func:`map16.pack` parks PAL rev 1's castle table on page 2, where Lunar
    Magic's own export of the vanilla cartridge keeps it; here page 2 is the
    first custom page, so it is cleared to the empty tile like the rest."""
    packed = bytearray(map16.pack(tables))
    start = map16.definitions_offset(FIRST_PAGE)
    packed[start : start + DEFINITION_BYTES] = map16.EMPTY_TILE * TILES
    return bytes(packed)


def resolve_acts_like(table: bytes, tile: int) -> int:
    """The vanilla tile a custom ``tile`` acts like, chained as the cartridge
    chains it: a lookup that lands on another custom tile is looked up again,
    up to :data:`ACTS_LIKE_DEPTH` times, and a tile past the held pages -- or
    a chain that never lands -- is :data:`ACTS_LIKE_DEFAULT`."""
    for _ in range(ACTS_LIKE_DEPTH):
        if tile < FIRST_TILE:
            return tile
        if tile >= END_TILE:
            return ACTS_LIKE_DEFAULT
        at = (tile - FIRST_TILE) * ACTS_LIKE_ENTRY
        tile = table[at] | (table[at + 1] << 8)
    return tile if tile < FIRST_TILE else ACTS_LIKE_DEFAULT


# -- the objects -------------------------------------------------------------

#: The four direct-tile objects, and the one Lunar Magic reserves for
#: user-defined objects. Every one is three bytes plus what its form adds.
DIRECT_PAGE0 = 0x22
DIRECT_PAGE1 = 0x23
DIRECT_LOW_PAGES = 0x27
DIRECT_HIGH_PAGES = 0x29
USER_DEFINED = 0x2D

#: Objects ``22``/``23``: byte 3 is the tile's low byte, the page is the
#: object's own low bit, and the settings byte is ``HHHHWWWW``.
DIRECT_TILE_SIZE = 4

#: Object ``2D``: two bytes the cartridge reads past and draws nothing from.
USER_DEFINED_SIZE = 5

#: The high page bit object ``29`` adds to byte 3's six page bits.
HIGH_PAGE_BIT = 0x40

#: Byte 3's page bits, under the two form bits.
PAGE_MASK = 0x3F

#: The multi-screen form's settings byte: seven bits of width, less one,
#: under the bit that adds the conditional byte.
WIDE_WIDTH_MASK = 0x7F


@dataclass(frozen=True)
class Form:
    """One shape of object ``27``/``29``, by byte 3's top two bits."""

    #: The value of those bits.
    code: int
    #: The record's whole length in bytes, with the standard three.
    size: int
    #: Whether the settings byte is the object's size (``HHHHWWWW``) rather
    #: than the selection's (``hhhhwwww``).
    sized: bool
    #: Whether a fifth byte carries the selection's size (``hhhhwwww``).
    selection_byte: bool
    #: Whether the settings byte is a seven-bit width and a sixth byte the
    #: height -- the multi-screen form.
    wide: bool


#: Byte 3's top two bits, ``ff``, as the wiki spells them:
#:
#: - ``00`` a single tile over ``HHHHWWWW`` blocks;
#: - ``01`` an ``hhhhwwww`` rectangle of consecutive tiles, placed as it is;
#: - ``10`` an ``hhhhwwww`` rectangle tiled over ``HHHHWWWW`` blocks;
#: - ``11`` the same over ``0WWWWWWW`` by ``HHHHHHHH`` blocks, the width in
#:   the settings byte and the height in a sixth; with the settings byte's
#:   high bit set an eighth byte names a conditional flag, which this
#:   cartridge reads past and ignores.
FORMS: tuple[Form, ...] = (
    Form(code=0, size=5, sized=True, selection_byte=False, wide=False),
    Form(code=1, size=5, sized=False, selection_byte=False, wide=False),
    Form(code=2, size=6, sized=True, selection_byte=True, wide=False),
    Form(code=3, size=7, sized=True, selection_byte=True, wide=True),
)

#: The form whose settings byte's high bit adds the conditional byte.
CONDITIONAL_FORM = 3
CONDITIONAL_BIT = 0x80
CONDITIONAL_SIZE = 8

#: The widest and tallest a multi-screen object may be: the width is seven
#: bits, and the height, though eight, is counted down through a signed
#: byte by Lunar Magic and by this cartridge alike, so past 128 rows it
#: stops after two.
WIDE_MAX_WIDTH = 0x80
WIDE_MAX_HEIGHT = 0x80


def form_of(byte3: int) -> Form:
    """The form byte 3 names."""
    return FORMS[byte3 >> 6]


def record_size(number: int, settings: int, byte3: int | None) -> int:
    """How long a standard object's record is, given its number, its
    settings byte and -- for the direct-tile objects -- its fourth byte.

    Three for every stock object; the direct-tile objects and the reserved
    one are what Lunar Magic lengthened."""
    if number in (DIRECT_PAGE0, DIRECT_PAGE1):
        return DIRECT_TILE_SIZE
    if number == USER_DEFINED:
        return USER_DEFINED_SIZE
    if number in (DIRECT_LOW_PAGES, DIRECT_HIGH_PAGES):
        if byte3 is None:
            return 5
        form = form_of(byte3)
        if form.code == CONDITIONAL_FORM and settings & CONDITIONAL_BIT:
            return CONDITIONAL_SIZE
        return form.size
    return 3


def is_direct(number: int) -> bool:
    """Whether ``number`` is one of the four direct-tile objects."""
    return number in (DIRECT_PAGE0, DIRECT_PAGE1, DIRECT_LOW_PAGES, DIRECT_HIGH_PAGES)
