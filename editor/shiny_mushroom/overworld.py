"""The world map as a document: geometry, the tilemap, and what is derived.

The overworld's Layer 1 is not built from objects the way a level is. It is a
flat table of ``$800`` Map16 tile numbers, block-copied out of the cartridge at
load -- so the document here is that table and nothing else, and an edit is
"this cell now holds that tile".

**One index space covers both pages.** Indices ``$000-$3FF`` are the main map
and ``$400-$7FF`` are the *shared submap area*: all seven submaps live side by
side in one 512x512-pixel region, and which one the player "is on" only decides
where the camera looks. The editor therefore draws one picture, 32 cells wide
and 64 tall, main map on top -- a submap view is a viewport onto the bottom
half, never a different tilemap.

The game stores each page as four 16x16-cell quadrants (top-left, top-right,
bottom-left, bottom-right), which is why a cell's index is not ``y * 32 + x``:
:func:`cell_index` and :func:`cell_at` are the game's own bit-packing, and
everything position-shaped goes through them.

**Translevels are derived, not stored.** At load the game scans the pristine
tilemap in index order, handing out a counter -- starting at 1 -- to every cell
holding a level tile (Map16 ``$56-$80``). Placing or removing a level tile
therefore renumbers every level after it, which is why
:func:`scan_translevels` is recomputed from the document rather than read once
from the cartridge: what the properties panel shows must be what the game will
do with the map as edited, not as shipped.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass, replace
from enum import Enum
from functools import lru_cache
from typing import TYPE_CHECKING

from shiny_mushroom.hexnum import hexnum, hexspot
from shiny_mushroom.level import (
    BLOCK,
    TILE,
    Blocks,
    Raster,
    changed_offsets,
    over_holes,
    snes_color,
)
from smw_tools import asm_codec, asm_regions

if TYPE_CHECKING:
    # Annotations only, and it has to stay that way: the snapshot module reads
    # this one's format facts at import time, so naming it at runtime here
    # would close the circle.
    from shiny_mushroom.overworld_snapshot import OverworldSnapshot
    from smw_tools.bases import RomBase

#: How many cells the Layer 1 tilemap holds: two 32x32 pages.
TILEMAP_SIZE = 0x800

#: The Layer 2 tilemap whole, as the document carries it: both maps' worth of
#: interleaved 8x8 entries -- even byte the tile number, odd the ``YXPCCCTT``
#: attributes -- in the arrangement :func:`layer2_word` documents.
LAYER2_SIZE = 0x4000

#: How many 8x8 entries that is -- the index space :func:`layer2_index`
#: speaks, and the length of each of the two compressed streams the buffer
#: de-interleaves into.
LAYER2_ENTRY_COUNT = 0x2000

#: The event stamp sheets, concatenated as the game addresses them: ``$900``
#: of 6x6 blocks (36 bytes each, row-major), then ``$400`` of 2x2 blocks
#: (4 bytes each). One properties byte pairs with every sheet byte, at the
#: same offset.
SHEETS_SIZE = 0xD00
SHEET_6X6_SIZE = 0x900

#: How many events the overworld load replays: ``$00``-``$6E``.
REPLAYED_EVENTS = 0x6F

#: The word vanilla's own padding rows hold -- what a freshly numbered
#: level's name row starts as.
BLANK_LEVEL_NAME = 0x02C0

#: How many ruin kinds the destroyed-tiles block describes -- the
#: before/top/bottom triples ahead of its scan rows. Not part of
#: :class:`MapShape`: the routine's own search is an immediate (``LDX #$04``),
#: so no feature can grow it without rewriting the code, and the count is read
#: from the region that writes the table rather than written down twice.
DESTROY_TILES = asm_regions.entry_count("overworld_destroy_before")

#: The first ruin kind that is two cells tall. The routine's ``CPX #$0003``
#: decides, so kinds below this write only their bottom tile and their
#: top-tile bytes are dead.
DESTROY_TWO_CELL = 3

#: How many before/after pairs the pass-1 substitution ships with -- the
#: stock cartridge's count, read from the region that writes the table rather
#: than written down twice. A document's own is :attr:`MapShape.swaps`: the
#: three scans take the table's length as their bound, so the pairs add and
#: delete like the silent slots.
SWAP_PAIRS = asm_regions.entry_count("overworld_event_layer1_from")

#: The one substitution pair that writes two cells: a match at this index
#: writes the after-tile at the location *and* the next cell along -- the
#: routine's own ``CPX`` against the pair index, not a fact about the table,
#: so a grown table's new pairs are ordinary and a deleted earlier pair
#: moves whatever follows it into this place.
SWAP_DOUBLED_PAIR = 0x15


@dataclass(frozen=True)
class MapShape:
    """How many entries each of the world map's variable-length tables holds.

    **A fact about one cartridge, not about the game.** Every count here is
    baked into the code that scans its table, so no edit moves one -- but a
    patch that rewrites that code does, and declares the new number as a
    feature's entry count (:mod:`smw_tools.features`). A cartridge that grew
    its warp table has 64 warps to show, edit and save, and an editor holding
    27 would drop the rest on the floor.

    Two ways to one value. :meth:`of_parts` reads it **off the parts
    themselves** -- a table is a whole number of fixed-width entries, so its
    length says how many it holds -- which is what :attr:`WorldMap.shape` is
    and what makes a document unable to disagree with its own bytes. :meth:`of`
    reads it off a **cartridge**, for the caller that has one and not yet its
    parts: :meth:`WorldMap.read` holds every part to it.
    """

    #: The walk-directions table: one ``nn112233`` byte per translevel the
    #: scan can hand out.
    directions: int

    #: The level-events table: one event number per translevel, ``$FF`` for
    #: none -- ``LevelEventNumbers``.
    level_events: int

    #: The level-names pointer table: one 16-bit word per translevel the name
    #: box can show, on every target. The *word format* is version-forked --
    #: the Japanese build decodes it with its own routine -- so the document
    #: carries this part only on the international targets.
    level_names: int

    #: How many events own a slice of the stamp entry table -- one less than
    #: its pointer table's entries, whose last is a shared end marker.
    stamp_events: int

    #: The silent-tiles block: four parallel arrays of this many.
    silent: int

    #: The destroyed-tiles block's scan rows: one location word and one event
    #: number each. The ruin-kind triples ahead of them are
    #: :data:`DESTROY_TILES`, which no cartridge varies.
    destroy: int

    #: The pass-1 substitution's location table: one cell word per event the
    #: replay loop can reach. The before/after pairs it matches against are
    #: :data:`SWAP_PAIRS` on a stock cartridge -- a table that grows, since
    #: its scans take the table's own length as their bound.
    subs: int

    #: How many before/after pairs the substitution's scans walk.
    swaps: int

    #: How many entries each transfer's search walks.
    warps: int
    exits: int

    #: The tables that grow on this cartridge, by :mod:`smw_tools.asm_regions`
    #: id: their scan follows their rows and reads nothing past them, so a
    #: save may add and delete rows -- priced against the cartridge's room,
    #: which is the mode's question. The silent tiles, the swap pairs, the
    #: warps and the path exits on every build; the destroyed tiles on one
    #: that binds its scan to the table's labels
    #: (:attr:`~smw_tools.bases.RomBase.label_bound_scans`), which on a stock
    #: build reads eight entries past the table and cannot move or grow.
    grows: frozenset[str] = frozenset()

    @classmethod
    def of_parts(
        cls,
        *,
        directions: bytes = b"",
        level_events: bytes = b"",
        level_names: bytes = b"",
        events: StampPlacements = (),
        silent: bytes = b"",
        destroy: bytes = b"",
        subs: bytes = b"",
        swaps: bytes = b"",
        warps: bytes = b"",
        exits: bytes = b"",
    ) -> MapShape:
        """The shape these parts hold: each one's length over its stride.

        The whole of how a document knows its own shape -- and how a function
        handed one part rather than the document reads that part's section
        boundaries. A part left out counts zero, which is what an absent one
        holds.
        """
        return cls(
            directions=len(directions),
            level_events=len(level_events),
            level_names=len(level_names) // 2,
            stamp_events=len(events),
            silent=len(silent) // 6,
            # Three bytes an entry across both halves of the block, so the
            # scan rows are what is left once the ruin kinds are taken off.
            destroy=max(0, len(destroy) // 3 - DESTROY_TILES),
            subs=len(subs) // 2,
            swaps=len(swaps) // 2,
            warps=len(warps) // 8,
            exits=len(exits) // 12,
            grows=_grows(None),
        )

    @classmethod
    def of(
        cls, base: RomBase | None = None, counts: Mapping[str, int] | None = None
    ) -> MapShape:
        """The shape ``base``'s cartridge declares; the stock one for ``None``.

        Resolved through :mod:`smw_tools.asm_regions`, which owns every table's
        format and answers a grown one per base -- so this module never writes
        a count down. ``counts`` is what one build *measured* for the tables
        whose scan follows their rows, by role
        (:func:`shiny_mushroom.build.role_counts`), read in preference to the
        declaration: a cartridge that grew its silent block holds that many.
        """

        def count(role: str, base: RomBase | None) -> int:
            if counts is not None and role in counts:
                return counts[role]
            return asm_regions.entry_count(role, base)

        return cls(
            directions=count("overworld_level_directions", base),
            level_events=count("overworld_level_events", base),
            level_names=count("overworld_level_names", base),
            stamp_events=count("overworld_event_pointers", base) - 1,
            silent=count("overworld_silent_tiles", base),
            destroy=count("overworld_destroy_events", base),
            subs=count("overworld_event_layer1_locations", base),
            swaps=count("overworld_event_layer1_from", base),
            warps=count("overworld_warp_trigger_columns", base),
            exits=count("overworld_exit_triggers", base),
            grows=_grows(base),
        )

    # -- what the packed parts measure ---------------------------------------
    #
    # Every part is its entries end to end, so a size is a count times a
    # stride and a section boundary is a count times an offset. Written here
    # once so no reader multiplies by 8 and hopes.

    @property
    def level_names_size(self) -> int:
        return self.level_names * 2

    @property
    def silent_size(self) -> int:
        return self.silent * 6

    @property
    def destroy_size(self) -> int:
        return (DESTROY_TILES + self.destroy) * 3

    @property
    def subs_size(self) -> int:
        return self.subs * 2

    @property
    def swaps_size(self) -> int:
        return self.swaps * 2

    @property
    def warps_size(self) -> int:
        return self.warps * 8

    @property
    def exits_size(self) -> int:
        return self.exits * 12

    #: Where the warp part's second, third and fourth word tables start.
    @property
    def warp_rows_at(self) -> int:
        return self.warps * 2

    @property
    def warp_x_at(self) -> int:
        return self.warps * 4

    @property
    def warp_y_at(self) -> int:
        return self.warps * 6

    #: Where the exit part's landing records and grid pairs start.
    @property
    def exit_landings_at(self) -> int:
        return self.exits * 5

    @property
    def exit_cells_at(self) -> int:
        return self.exits * 10

    #: Where the silent block's layers, locations and tile numbers start.
    @property
    def silent_layers_at(self) -> int:
        return self.silent

    @property
    def silent_locations_at(self) -> int:
        return self.silent * 2

    @property
    def silent_tiles_at(self) -> int:
        return self.silent * 4

    #: Where the destroyed-tiles block's five tables start -- the three
    #: ruin-kind tables, then the scan's locations and event numbers.
    @property
    def destroy_top_at(self) -> int:
        return DESTROY_TILES

    @property
    def destroy_bottom_at(self) -> int:
        return DESTROY_TILES * 2

    @property
    def destroy_locations_at(self) -> int:
        return DESTROY_TILES * 3

    @property
    def destroy_events_at(self) -> int:
        return DESTROY_TILES * 3 + self.destroy * 2


def _grows(base: RomBase | None) -> frozenset[str]:
    """The regions whose tables grow on ``base`` -- the stock cartridge's for
    ``None`` -- :attr:`smw_tools.asm_codec.AsmRegion.grows`. The stock
    answer is held, since every document's own shape asks it."""
    if base is None:
        return _STOCK_GROWS
    return frozenset(
        region.id for region in asm_regions.regions(base).values() if region.grows
    )


_STOCK_GROWS: frozenset[str] = frozenset(
    region.id for region in asm_regions.regions().values() if region.grows
)


def table_allows(region_id: str, entries: int) -> bool:
    """Whether ``region_id``'s table may hold ``entries`` rows once its scan
    follows them: its stock count for a table that never grows, one up to its
    reader's reach for one that can --
    :meth:`smw_tools.asm_codec.AsmRegion.within_reach`, the registry's word
    on which is which. Whether it grows on the cartridge *in hand* is
    :attr:`MapShape.grows`, which the mode holds a document to first."""
    return asm_regions.region_for(region_id).within_reach(entries)


def table_capacity(region_id: str) -> int | None:
    """The most rows ``region_id``'s reader scans, or ``None`` for a table
    bounded by room alone."""
    return asm_regions.region_for(region_id).capacity


#: The stock cartridge's shape -- what a document reading its own parts comes
#: out with wherever nothing has grown a table, and the fallback for a caller
#: with no cartridge in hand: a synthetic document in a test, or one built
#: before a capture arrives.
STOCK_SHAPE = MapShape.of()

#: How many rows the cartridge's stamp entry table holds -- shared by every
#: event, which is why the mode meters additions against it. The save prices
#: the project's own room exactly; this is the shipped slot it starts from.
STAMP_ROW_BUDGET = 0x173


#: The document's stamp placements: one tuple of ``(sheet offset,
#: destination)`` word pairs per event that owns a slice.
StampPlacements = tuple[tuple[tuple[int, int], ...], ...]

#: The overworld sprite slot table: 13 slots of 5 bytes -- sprite number,
#: then X and Y as **signed** 16-bit map pixels in the one shared 512x512
#: space (Bowser ships at ``Y = -4``). Read once, at title load.
SPRITE_SLOTS = 13
SPRITE_STRIDE = 5
SPRITE_TABLE_SIZE = SPRITE_SLOTS * SPRITE_STRIDE

#: The sprite numbers' names, indexed by number -- ``$00`` is the empty slot.
SPRITE_NAMES = (
    "None",
    "Lakitu",
    "Blue Bird",
    "Cheep Cheep",
    "Piranha Plant",
    "Cloud",
    "Koopa Kid",
    "Smoke",
    "Bowser Sign",
    "Bowser",
    "Boo",
)


#: The seven maps, in the game's own submap order.
SUBMAP_NAMES = (
    "Main map",
    "Yoshi's Island",
    "Vanilla Dome",
    "Forest of Illusion",
    "Valley of Bowser",
    "Special World",
    "Star World",
)

#: Which maps each sprite number is *disabled* on -- the game's
#: ``DisableSpriteOnXSubmapFlags``, indexed by number minus one. Bit 7 is the
#: main map, bits 6 down to 1 the six submaps in :data:`SUBMAP_NAMES` order,
#: bit 0 unused; a **set** bit disables. Which map shows a sprite is a fact
#: about its *number*, not its slot. These are vanilla's bytes, and only the
#: **default**: a capture reads the cartridge's own table
#: (``OverworldSnapshot.sprite_submap_disable``) and the document carries it,
#: so a base that edits the asm table shows its markers on its own maps.
SPRITE_SUBMAP_DISABLE = (0x7F, 0x21, 0x7F, 0x7F, 0x7F, 0x77, 0x3F, 0xF7, 0xF7, 0x00)

#: Where the submap copy of a Boo in the last slots is drawn, relative to its
#: main-map position -- the game's ``SubmapBoo*PosOffset`` pairs, one per slot
#: from the end. The tables' length is why a ghost works in no other slot.
#: Vanilla's pairs, and only the **default**, exactly as
#: :data:`SPRITE_SUBMAP_DISABLE` is: a capture reads the cartridge's own two
#: tables and the document carries them, so a base that moves a ghost draws
#: its marker where that base puts it.
SUBMAP_BOO_OFFSETS = ((0x30, 0x20), (0x100, -0x90), (-0xF0, 0x10))

#: The Boo's sprite number -- the one type the offsets above apply to.
BOO_SPRITE = 0x0A

#: Where the smoke draws on each map, as absolute map pixels, one pair per
#: map in :data:`SUBMAP_NAMES` order -- the game's ``SMW_OWSpr07_Smoke``
#: ``MapXPos``/``MapYPos`` pairs. Vanilla's, and only the **default**, as
#: :data:`SPRITE_SUBMAP_DISABLE` is: a capture reads the cartridge's own two
#: tables and the document carries them.
#:
#: Not an offset like the ghost's. The smoke's routine writes these over its
#: slot's position every frame before drawing, so they *are* where a Smoke
#: marker belongs, and the slot's own position is never drawn. Their being
#: two entries long is the same fact as sprite $07's disable byte allowing
#: two maps: a third would read the animation table after them.
SMOKE_MAP_POSITIONS = ((0x38, 0x18A), (0x68, 0x6A))

#: The smoke's sprite number -- the one type the positions above apply to.
SMOKE_SPRITE = 0x07

#: The two numbers whose code places them off the trigger tile the player
#: walks onto, rather than from the slot table.
CHEEP_CHEEP_SPRITE = 0x03
KOOPA_KID_SPRITE = 0x06

#: Every number whose own code overwrites the position the slot table loads,
#: and where it puts it instead -- a phrase a panel row prints. A slot
#: holding one of these can be moved in the table all day and the game will
#: not draw it anywhere new, which is worth saying rather than leaving a
#: person to discover it in a test run.
PLACED_BY_CODE: dict[int, str] = {
    CHEEP_CHEEP_SPRITE: "where the trigger tile the player steps on puts it",
    KOOPA_KID_SPRITE: "where the trigger tile the player steps on puts it",
    SMOKE_SPRITE: "one fixed spot per map, from the game's own table",
}


def _paired_words(
    x_table: bytes, y_table: bytes, refusal: str
) -> tuple[tuple[int, int], ...]:
    """Two parallel tables of signed words zipped into pairs.

    The shape every one of these position tables has: the game indexes the X
    and the Y run together, so a pair needs a word from each. Either table
    empty answers empty, which reads at the call site as "nothing better than
    the vanilla default"; tables that cannot be walked together are
    ``refusal``, in the caller's own words.
    """
    if not x_table or not y_table:
        return ()
    if len(x_table) != len(y_table) or len(x_table) % 2:
        raise ValueError(refusal)
    return tuple(
        (
            int.from_bytes(x_table[at : at + 2], "little", signed=True),
            int.from_bytes(y_table[at : at + 2], "little", signed=True),
        )
        for at in range(0, len(x_table), 2)
    )


def smoke_positions(x_table: bytes, y_table: bytes) -> tuple[tuple[int, int], ...]:
    """The two ``SMW_OWSpr07_Smoke`` position tables zipped into ``(x, y)``
    pairs, one per map -- :func:`_paired_words`' contract, over absolute
    positions rather than offsets."""
    return _paired_words(
        x_table, y_table, "the smoke position tables are equal runs of signed words"
    )


def boo_offsets(x_table: bytes, y_table: bytes) -> tuple[tuple[int, int], ...]:
    """The two ``SubmapBoo*PosOffset`` tables zipped into ``(dx, dy)``
    pairs -- :func:`_paired_words`' contract."""
    return _paired_words(
        x_table, y_table, "the ghost offset tables are equal runs of signed words"
    )


@dataclass(frozen=True)
class OverworldSprite:
    """One slot of the sprite table, decoded. Positions are signed map
    pixels -- see :data:`SPRITE_TABLE_SIZE`."""

    slot: int
    sprite_id: int
    x: int
    y: int

    #: The cartridge's disable-bits table, attached by the document that
    #: decoded this slot so every consumer of a sprite answers with it.
    disable: tuple[int, ...] = SPRITE_SUBMAP_DISABLE

    #: The cartridge's ghost offsets, attached the same way and for the same
    #: reason -- they decide where this slot's submap copy is drawn when it
    #: holds a Boo, and how many slots from the end can hold one at all.
    boo_offsets: tuple[tuple[int, int], ...] = SUBMAP_BOO_OFFSETS

    #: The cartridge's per-map smoke positions, attached the same way. They
    #: decide where this slot is drawn -- on every map -- when it holds a
    #: Smoke, because that type's code ignores :attr:`x` and :attr:`y`.
    smoke_positions: tuple[tuple[int, int], ...] = SMOKE_MAP_POSITIONS

    @property
    def placed_by_code(self) -> str:
        """Where this slot's *type* puts itself, ignoring :attr:`x` and
        :attr:`y` -- empty for the types that are drawn where the slot says."""
        return PLACED_BY_CODE.get(self.sprite_id, "")

    @property
    def smoke_spots(self) -> tuple[tuple[int, int, int], ...]:
        """Where a Smoke draws, as ``(map, x, y)`` in map pixels -- one entry
        per map its table reaches and its disable byte allows, and empty for
        every other type.

        A map the type is enabled on but the table has no pair for answers
        nothing: the game reads past the table there, and what it finds is
        not a position this editor can claim to know.
        """
        if self.sprite_id != SMOKE_SPRITE:
            return ()
        return tuple(
            (map_id, x, y)
            for map_id, (x, y) in enumerate(self.smoke_positions)
            if map_id < len(SUBMAP_NAMES)
            and not sprite_disabled_on(self.disable, self.sprite_id, map_id)
        )

    @property
    def name(self) -> str:
        if self.sprite_id < len(SPRITE_NAMES):
            return SPRITE_NAMES[self.sprite_id]
        return hexnum(self.sprite_id)

    @property
    def appears_on(self) -> tuple[str, ...]:
        """The maps this slot's number shows on -- empty for an empty slot.

        A number past the disable table shows on every map, which is
        :func:`sprite_disabled_on`'s rule and therefore what the canvas
        draws: the panel saying "-" while both halves carry the marker
        would be the two disagreeing about one slot.
        """
        if self.sprite_id == 0:
            return ()
        return tuple(
            name
            for map_id, name in enumerate(SUBMAP_NAMES)
            if not sprite_disabled_on(self.disable, self.sprite_id, map_id)
        )


def sprite_disabled_on(disable: Sequence[int], number: int, map_id: int) -> bool:
    """Whether sprite ``number`` is disabled on the map ``map_id`` -- the main
    map ``0``, the six submaps ``1``-``6`` in :data:`SUBMAP_NAMES` order.

    The one place the table's bit order is read, because it is read from the
    markers, the panel, a placement and a framing decision, and four spellings
    of ``0x80 >> map_id`` is three chances to get it the wrong way round.

    A number the table has no row for -- an empty slot, or one past the end --
    is **not** disabled: an unknown number is not a claim that it is hidden,
    and answering "shown everywhere" keeps it findable rather than nowhere.
    """
    if not 1 <= number <= len(disable):
        return False
    return bool(disable[number - 1] & (0x80 >> map_id))


@dataclass(frozen=True)
class SpriteSpot:
    """One place a slot is drawn on the stacked picture, and which half of it
    that is.

    ``submap_half`` is carried rather than derived from ``y``: a sprite the
    game puts above the shared page's top edge -- Bowser, at Y = -4 -- has
    its submap copy drawn *over* the main map's page, and the two halves are
    told apart by which map they are the copy for, not by where they land.
    """

    x: int
    y: int
    submap_half: bool


def sprite_spots(sprite: OverworldSprite) -> tuple[SpriteSpot, ...]:
    """Where a slot shows on the editor's stacked picture, as pixel origins.

    The main-map copy at ``(x, y)`` when the number is enabled there, and the
    submap copy at ``(x, y + 512)`` -- the shared submap area is the picture's
    bottom half -- when it is enabled on any submap, with the cartridge's own
    ghost offsets applied to a Boo in the last slots its tables reach. An
    empty slot answers both copies, so all thirteen stay findable.

    A Smoke is the exception, and answers its own table instead: its code
    overwrites the slot's position every frame with the pair for the map
    being drawn, so it gets one spot per map that table reaches -- which is
    not the same coordinate twice, and need not be near the stored position
    at all. A table that reaches no enabled map falls back to the stored
    position, on the principle every other empty answer here follows: a slot
    that draws nowhere is a slot nobody can click.
    """
    if sprite.sprite_id == SMOKE_SPRITE and sprite.smoke_spots:
        return tuple(
            SpriteSpot(x, y + (PAGE_ROWS * 16 if map_id else 0), bool(map_id))
            for map_id, x, y in sprite.smoke_spots
        )
    on_main = not sprite_disabled_on(sprite.disable, sprite.sprite_id, 0)
    on_submaps = any(
        not sprite_disabled_on(sprite.disable, sprite.sprite_id, map_id)
        for map_id in range(1, len(SUBMAP_NAMES))
    )
    spots = []
    if on_main:
        spots.append(SpriteSpot(sprite.x, sprite.y, False))
    if on_submaps:
        dx = dy = 0
        first_ghost_slot = SPRITE_SLOTS - len(sprite.boo_offsets)
        if sprite.sprite_id == BOO_SPRITE and sprite.slot >= first_ghost_slot:
            dx, dy = sprite.boo_offsets[sprite.slot - first_ghost_slot]
        spots.append(SpriteSpot(sprite.x + dx, sprite.y + dy + PAGE_ROWS * 16, True))
    if not spots:
        spots.append(SpriteSpot(sprite.x, sprite.y, False))
    return tuple(spots)


#: The map in cells: 32 across, and two 32-row pages stacked.
COLUMNS = 32
ROWS = 64
PAGE_ROWS = 32

#: The Map16 numbers the translevel scan counts as "a level lives here".
#: ``$80`` is the last enterable one; ``$81`` up are decorations again.
FIRST_LEVEL_TILE = 0x56
LAST_LEVEL_TILE = 0x80

#: How many Map16 tiles the overworld defines -- the length of its definition
#: table, ``$00-$C0``. The tilemap byte could name up to ``$FF``; past this,
#: there is no definition to draw.
TILE_COUNT = 0xC1

#: Translevels above this belong to the submap area, and a level number is
#: derived differently there -- see :func:`level_number`.
LAST_MAIN_MAP_TRANSLEVEL = 0x24


# -- what the walker does with a Layer 1 tile ---------------------------------
#
# The game classifies tiles by number, in ``SMW_SharedOverworldPathTables``
# and the overworld processes of Bank04. Restated here as editor metadata --
# the overlays and the properties panel read it, nothing edits it:
#
# - ``$01-$51`` are **path tiles**. Per tile, ``DATA_049FEB`` holds the
#   walking pose (horizontal, vertical, the two swimming poses, climbing)
#   and ``DATA_049EA7`` how far the player moves crossing it -- the step
#   pair below, which is what draws a diagonal path as a diagonal.
# - ``$56-$80`` are the **level tiles** the translevel scan counts, with
#   three special numbers: ``$5B`` warps as a pipe, ``$5F`` as a star, and
#   ``$6A-$6D`` and ``$80`` stand the player swimming.
# - ``$81`` is the destroyed castle (enterable with L+R outside Japan) and
#   ``$82`` the unused second pipe; ``$83`` up block the walker entirely.
# - Stepping onto a tile in :data:`MAP_EXIT_TILES` walks the player off to
#   another map -- ``DATA_049426``, Lunar Magic's "exit level tiles".


class TileFunction(Enum):
    """What the walking engine does with a Layer 1 tile the player is on.
    Values are the words the properties panel shows."""

    NONE = "decoration"
    PATH = "path"
    WATER_PATH = "water path"
    CLIMB = "climbing path"
    LEVEL = "level"
    WATER_LEVEL = "water level"
    STAR_WARP = "star warp"
    PIPE_WARP = "pipe warp"
    DESTROYED_CASTLE = "destroyed castle"


#: The walking pose per path tile ``$01-$51`` -- ``DATA_049FEB``: ``$00``
#: vertical, ``$04`` horizontal, ``$08``/``$0C`` the swimming pair, ``$14``
#: climbing.
_PATH_POSES = bytes(
    [
        0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x04, 0x04, 0x04, 0x04, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00,
        0x00, 0x04, 0x04, 0x08, 0x08, 0x08, 0x0C, 0x0C, 0x08, 0x08, 0x08, 0x08,
        0x08, 0x0C, 0x0C, 0x08, 0x08, 0x08, 0x08, 0x0C, 0x08, 0x08, 0x08, 0x0C,
        0x08, 0x0C, 0x14, 0x14, 0x14, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x08, 0x00,
    ]
)  # fmt: skip

#: How far the player moves crossing path tile ``$01 + index``, as signed
#: map pixels ``(dx, dy)`` walking right along a horizontal path or down a
#: vertical one -- ``DATA_049EA7``. The pair is the tile's path drawn as a
#: vector: ``(16, -8)`` is a diagonal climbing right.
PATH_STEPS: tuple[tuple[int, int], ...] = (
    (16, -8), (16, 0), (16, -4), (16, 0), (16, -4), (16, 0),
    (8, -4), (12, -12), (-4, 4), (4, -4), (-8, 16), (0, 16),
    (-4, 8), (-4, 8), (-4, 16), (0, 16), (-8, 4), (-4, 16),
    (0, 16), (16, 8), (16, 4), (16, 4), (8, 4), (12, 12),
    (4, 4), (4, 4), (8, 16), (-4, -8), (-4, -8), (4, 16),
    (-8, -4), (4, 16), (-12, -12), (12, -12), (16, 0), (0, 16),
    (0, 16), (16, 0), (16, 0), (-4, 8), (-4, 8), (0, 16),
    (16, -4), (16, -4), (-4, 4), (4, -4), (-8, 16), (0, 16),
    (-4, 16), (16, 4), (16, 0), (4, 16), (4, 4), (-4, -8),
    (4, 4), (16, 8), (12, -12), (0, 16), (-4, 16), (16, 0),
    (4, 16), (16, -8), (0, 16), (0, 16), (-4, 16), (16, 0),
    (0, 16), (0, 16), (0, 16), (0, 16), (0, 16), (0, 16),
    (4, -4), (4, 4), (4, 4), (0, 16), (0, 16), (16, 0),
    (16, 0), (-4, 16), (-4, 4),
)  # fmt: skip

#: The path tiles that walk the player off to another map -- ``DATA_049426``.
#: A fact *beside* the function: an exit tile is still a path (or climbing)
#: tile, and :func:`tile_function` answers that.
MAP_EXIT_TILES = frozenset({0x25, 0x40, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x4D})

#: The two pipe-warp numbers: the level tile ``$5B``, and the unused ``$82``.
PIPE_TILES = frozenset({0x5B, 0x82})

#: The pipe warp no map places -- the second of :data:`PIPE_TILES`, past the
#: level tiles, so the translevel scan never counts it.
UNUSED_PIPE_TILE = 0x82

#: The star-warp level tile.
STAR_TILE = 0x5F

#: The level tiles the player stands swimming on: ``$6A-$6D`` and ``$80``.
WATER_LEVEL_TILES = frozenset({0x6A, 0x6B, 0x6C, 0x6D, 0x80})

#: The destroyed castle, enterable with L+R held outside the Japanese release.
DESTROYED_CASTLE_TILE = 0x81


def tile_function(tile: int) -> TileFunction:
    """What the walker does with Map16 number ``tile``."""
    if tile == STAR_TILE:
        return TileFunction.STAR_WARP
    if tile in PIPE_TILES:
        return TileFunction.PIPE_WARP
    if tile in WATER_LEVEL_TILES:
        return TileFunction.WATER_LEVEL
    if tile == DESTROYED_CASTLE_TILE:
        return TileFunction.DESTROYED_CASTLE
    if is_level_tile(tile):
        return TileFunction.LEVEL
    if 0 < tile <= len(_PATH_POSES):
        pose = _PATH_POSES[tile - 1]
        if pose == 0x14:
            return TileFunction.CLIMB
        if pose in (0x08, 0x0C):
            return TileFunction.WATER_PATH
        return TileFunction.PATH
    return TileFunction.NONE


def path_step(tile: int) -> tuple[int, int] | None:
    """The path a tile carries, as its step vector -- ``None`` off the path
    range."""
    if 0 < tile <= len(PATH_STEPS):
        return PATH_STEPS[tile - 1]
    return None


#: Where each submap's camera starts, as the game's own signed 16-bit scroll
#: pair (X, Y) in pixels -- read from ``SMW_GameMode0C_LoadOverworld``'s
#: tables. The main map's pair is zero there and overridden elsewhere; a
#: negative coordinate points into the border above or left of the map.
#: Nothing edits it; :func:`submap_region` and :func:`submap_screen` frame
#: the editor's view with it.
SUBMAP_CAMERAS: tuple[tuple[int, int], ...] = (
    (0x0000, 0x0000),  # Main map
    (-0x0011, -0x0028),  # Yoshi's Island
    (-0x0011, 0x0080),  # Vanilla Dome
    (-0x0011, 0x0128),  # Forest of Illusion
    (0x00F0, -0x0028),  # Valley of Bowser
    (0x00F0, 0x0080),  # Special World
    (0x00F0, 0x0128),  # Star World
)

#: The console screen a submap camera frames, in pixels.
_SCREEN = (256, 224)

#: What the submap border leaves open, as a rect in screen pixels. On a
#: submap the game draws a Layer 3 border over the screen
#: (``smw/src/SMW/images/overworld/border.bin``, a stripe image): opaque
#: filler over the top five tile rows, the bottom two, and two columns down
#: each side, with the thin golden frame line drawn on the open rect's
#: outermost tiles. The submap cameras sit 168 pixels apart vertically --
#: exactly this window's height -- so the windows tile the shared page.
SUBMAP_BORDER_WINDOW = (16, 40, 224, 168)


def submap_region(submap: int) -> tuple[int, int, int, int]:
    """The stacked picture's pixel rect that *is* one map, as
    ``(left, top, width, height)``.

    The main map is its whole page -- its camera follows the player over all
    of it. A submap is the one fixed screen its camera frames, from
    :data:`SUBMAP_CAMERAS`, clamped to the shared page and moved down a page
    because the submap area is the picture's bottom half; a camera hanging
    past the page's edge shows border there, not map.
    """
    if submap == 0:
        return (0, 0, COLUMNS * BLOCK, PAGE_ROWS * BLOCK)
    x, y = SUBMAP_CAMERAS[submap]
    left, top = max(0, x), max(0, y)
    right = min(COLUMNS * BLOCK, x + _SCREEN[0])
    bottom = min(PAGE_ROWS * BLOCK, y + _SCREEN[1])
    return (left, PAGE_ROWS * BLOCK + top, right - left, bottom - top)


def submap_screen(submap: int) -> tuple[int, int, int, int]:
    """The console screen a submap's fixed camera frames, on the stacked
    picture, as ``(left, top, width, height)`` -- **unclamped**, unlike
    :func:`submap_region`: the parts hanging past the page's edges are where
    the console shows border, which is exactly what a framing hint is for."""
    x, y = SUBMAP_CAMERAS[submap]
    return (x, PAGE_ROWS * BLOCK + y, *_SCREEN)


def submap_window(submap: int) -> tuple[int, int, int, int]:
    """The map a submap actually shows: :func:`submap_screen` trimmed to
    what the Layer 3 border leaves open (:data:`SUBMAP_BORDER_WINDOW`), on
    the stacked picture. The rest of the screen is the border's."""
    x, y = SUBMAP_CAMERAS[submap]
    left, top, width, height = SUBMAP_BORDER_WINDOW
    return (x + left, PAGE_ROWS * BLOCK + y + top, width, height)


def cell_index(x: int, y: int) -> int:
    """The tilemap index of the cell at ``(x, y)``.

    ``x`` is ``0-31`` and ``y`` ``0-63``, counted in cells from the top-left of
    the main map; rows 32 and below are the submap area. The packing is the
    game's: low nibbles interleaved, then bit 8 for the right half, bit 9 for
    the bottom half of a page, bit 10 for the page.
    """
    if not (0 <= x < COLUMNS and 0 <= y < ROWS):
        raise ValueError(f"no cell at {hexspot(x, y)}")
    ym = y % PAGE_ROWS
    return (
        (x & 0x0F)
        | ((x & 0x10) << 4)
        | ((ym & 0x0F) << 4)
        | (0x200 if ym & 0x10 else 0)
        | (0x400 if y >= PAGE_ROWS else 0)
    )


def cell_at(index: int) -> tuple[int, int]:
    """Where a tilemap index lands, as the ``(x, y)`` :func:`cell_index` takes."""
    if not 0 <= index < TILEMAP_SIZE:
        raise ValueError(f"no cell with index {index:#x}")
    x = (index & 0x0F) | ((index & 0x100) >> 4)
    y = ((index >> 4) & 0x0F) | ((index & 0x200) >> 5)
    if index & 0x400:
        y += PAGE_ROWS
    return x, y


# -- where the warps and exits lead -------------------------------------------
#
# Both transfers are keyed on the player's *position*, not on the tile: the
# tile is the trigger, and Bank04's tables say where each spot leads. The
# tables are document parts -- captured off the cartridge, editable, and
# saved as asm-region fragments -- packed here in ROM order:
#
# - ``warps``: eight bytes an entry, across four parallel word tables --
#   trigger grid column with the submap in the high byte, trigger grid row,
#   landing pixel X with the submap in bits 9-12, landing pixel Y. Each
#   direction of a two-way pipe is its own entry, and the Special World's
#   one-way doors are honestly one-way.
# - ``exits``: twelve bytes an entry -- the trigger and landing as five-byte
#   (pixel Y, pixel X, submap) records, then the landing's (grid row, grid
#   column) pairs, which the shipped table deviates from ``pixel >> 4`` on
#   where a landing sits mid-walk.
#
# How many entries either holds is the cartridge's own answer, so every size
# and section boundary below comes from a :class:`MapShape` -- the document's
# own, read off the part it is splitting.
#
# Cells on the stacked picture, submap positions a page down. A destination
# is an ``(x, y)`` pair rather than a cell index: one shipped exit lands a
# row *below* the shared page -- the player walks in from the border -- so
# it may name a cell the tilemap does not have.


def _packed_words(values: Iterable[int]) -> bytes:
    return b"".join(value.to_bytes(2, "little") for value in values)


def _word(data: bytes, at: int) -> int:
    """The little-endian word at ``at``, over what ``data`` actually holds.

    A word past the end reads as zero and one straddling it as its low byte:
    every table below is a capture's, and a truncated one is a part the
    document declines rather than a crash in the middle of drawing.
    """
    return int.from_bytes(data[at : at + 2], "little")


#: The shipped tables, as the default parts a document without a capture
#: carries -- the same bytes as ``overworld/tables/star-pipe-warps.asm`` and
#: ``path-exits.asm``, exactly as :data:`SPRITE_SUBMAP_DISABLE` restates the
#: disable table.
VANILLA_WARPS: bytes = _packed_words(
    (
        0x0011, 0x000A, 0x0009, 0x000B, 0x0012, 0x000A, 0x0007, 0x020A, 0x0203,
        0x0410, 0x0412, 0x041C, 0x0414, 0x0612, 0x0200, 0x0612, 0x0010, 0x0617,
        0x0014, 0x061C, 0x0014, 0x061C, 0x0617, 0x0511, 0x0511, 0x0414, 0x0106,
        # trigger grid rows
        0x0007, 0x0003, 0x0010, 0x000E, 0x0017, 0x0018, 0x0012, 0x0014, 0x000B,
        0x0003, 0x0001, 0x0009, 0x0009, 0x001D, 0x000E, 0x0018, 0x000F, 0x0016,
        0x0010, 0x0018, 0x0002, 0x001D, 0x0018, 0x0013, 0x0011, 0x0003, 0x0007,
        # landing pixel X with the submap in bits 9-12
        0x04A8, 0x0438, 0x0908, 0x0928, 0x09C8, 0x0948, 0x0D28, 0x0118, 0x00A8,
        0x0098, 0x00B8, 0x0128, 0x00A8, 0x0078, 0x0D28, 0x0408, 0x0D78, 0x0108,
        0x0DC8, 0x0148, 0x0DC8, 0x0948, 0x0B18, 0x0D78, 0x0268, 0x0DC8, 0x0D28,
        # landing pixel Y
        0x0148, 0x00B8, 0x0038, 0x0018, 0x0098, 0x0098, 0x01D8, 0x0078, 0x0038,
        0x0108, 0x00E8, 0x0178, 0x0188, 0x0128, 0x0188, 0x00E8, 0x0168, 0x00F8,
        0x0188, 0x0108, 0x01D8, 0x0038, 0x0138, 0x0188, 0x0078, 0x01D8, 0x01D8,
    )
)  # fmt: skip

_VANILLA_EXIT_POSITIONS = (
    # (trigger Y, X, submap), then the landings in the same shape
    (0x0140, 0x0028, 0), (0x0150, 0x0058, 0), (0x0010, 0x0048, 1),
    (0x0010, 0x0098, 1), (0x00A0, 0x00D8, 0), (0x0140, 0x0058, 2),
    (0x0090, 0x01E8, 4), (0x0160, 0x00E8, 0), (0x00A0, 0x01C8, 0),
    (0x0160, 0x0088, 3), (0x0108, 0x0190, 0), (0x01E8, 0x0010, 3),
    (0x0110, 0x01C8, 0), (0x01F0, 0x0088, 3),
    (0x0000, 0x0048, 1), (0x0000, 0x0098, 1), (0x0150, 0x0028, 0),
    (0x0160, 0x0058, 0), (0x0150, 0x0058, 2), (0x0090, 0x00D8, 0),
    (0x0150, 0x00E8, 0), (0x00A0, 0x01E8, 4), (0x0150, 0x0088, 3),
    (0x00B0, 0x01C8, 0), (0x01E8, 0x0000, 3), (0x0108, 0x01A0, 0),
    (0x0200, 0x0088, 3), (0x0100, 0x01C8, 0),
)  # fmt: skip

_VANILLA_EXIT_CELLS = (
    (0x00, 0x04), (0x00, 0x09), (0x14, 0x02), (0x15, 0x05), (0x14, 0x05),
    (0x09, 0x0D), (0x15, 0x0E), (0x09, 0x1E), (0x15, 0x08), (0x0A, 0x1C),
    (0x1E, 0x00), (0x10, 0x19), (0x1F, 0x08), (0x10, 0x1C),
)  # fmt: skip

VANILLA_EXITS: bytes = b"".join(
    y.to_bytes(2, "little") + x.to_bytes(2, "little") + bytes([submap])
    for y, x, submap in _VANILLA_EXIT_POSITIONS
) + b"".join(bytes([row, column]) for row, column in _VANILLA_EXIT_CELLS)


def warps_part(
    trigger_columns: bytes,
    trigger_rows: bytes,
    landings_x: bytes,
    landings_y: bytes,
) -> bytes | None:
    """The warp tables joined into the document's part, or ``None`` when the
    capture did not carry them whole.

    Whole is the four tables agreeing on a whole number of entries, not a
    count: how many the cartridge has is what the capture just read, and the
    part is what tells the document -- see :class:`MapShape`.
    """
    sections = (trigger_columns, trigger_rows, landings_x, landings_y)
    entries = len(trigger_columns) // 2
    if not entries or any(len(section) != entries * 2 for section in sections):
        return None
    return b"".join(sections)


def exits_part(triggers: bytes, landings: bytes, cells: bytes) -> bytes | None:
    """The exit tables joined into the document's part, or ``None`` --
    :func:`warps_part`'s rule, on this transfer's three tables."""
    entries = len(cells) // 2
    if (
        not entries
        or len(triggers) != entries * 5
        or len(landings) != entries * 5
        or len(cells) != entries * 2
    ):
        return None
    return triggers + landings + cells


def destroy_part(
    before: bytes,
    top: bytes,
    bottom: bytes,
    locations: bytes,
    events: bytes,
    slots: int,
) -> bytes | None:
    """The destroyed-tiles tables joined into the document's part, or ``None``
    when the capture did not carry them whole.

    ``slots`` is how many scan rows the *table* holds, which the capture
    cannot say for itself: the game scans past its own table, so the two
    windows it reads are longer than the tables in them and run on into what
    the bank has next. The part carries the tables; the overread is the
    replay's business -- see :func:`event_snapshot`.
    """
    kinds = (before, top, bottom)
    if slots <= 0 or any(len(kind) != DESTROY_TILES for kind in kinds):
        return None
    if len(locations) < slots * 2 or len(events) < slots:
        return None
    return b"".join(kinds) + locations[: slots * 2] + events[:slots]


def warp_sections(warps: bytes) -> tuple[bytes, bytes, bytes, bytes]:
    """The part split back into its four ROM tables, in section order.

    The split is the part's own length: four equal word tables, so a
    cartridge with more warps splits its own longer part correctly without
    anything here being told how many it has.
    """
    each = len(warps) // 4
    return (
        warps[:each],
        warps[each : each * 2],
        warps[each * 2 : each * 3],
        warps[each * 3 :],
    )


def exit_sections(exits: bytes) -> tuple[bytes, bytes, bytes]:
    """The part split back into its three ROM tables, in section order --
    :func:`warp_sections`' rule at this transfer's 5/5/2 strides."""
    entries = len(exits) // 12
    return (
        exits[: entries * 5],
        exits[entries * 5 : entries * 10],
        exits[entries * 10 :],
    )


#: How many bytes one entry takes in each of the warp tables' four sections,
#: and in each of the exit tables' three -- what a :func:`transfer_row` slice
#: is cut at, and the strides :func:`warp_sections` and :func:`exit_sections`
#: split the parts on.
WARP_STRIDES = (2, 2, 2, 2)
EXIT_STRIDES = (5, 5, 2)


def transfer_row(
    sections: tuple[bytes, ...], strides: tuple[int, ...], entry: int
) -> tuple[bytes, ...]:
    """One entry's whole record: its slice of each of the transfer's parallel
    tables, in section order.

    A transfer is a record spread across two, three or four tables, and every
    caller that carries one whole -- the clipboard, an append -- wants all of
    it or none. Which tables and which strides is the transfer's business
    (:data:`WARP_STRIDES`, :data:`EXIT_STRIDES`); cutting the row is the same
    arithmetic either way.
    """
    return tuple(
        section[entry * stride : (entry + 1) * stride]
        for section, stride in zip(sections, strides, strict=True)
    )


def transfer_appended(
    sections: tuple[bytes, ...], row: tuple[bytes, ...], strides: tuple[int, ...]
) -> bytes:
    """The transfer's part with ``row`` added as its last entry -- each
    section with that section's slice of the row on its end, joined back into
    the one part the document keeps.

    The last entry is the one the game's search tries first, in both tables:
    a row appended here answers its cell over any earlier entry standing on
    the same one.
    """
    if len(row) != len(strides) or any(
        len(part) != stride for part, stride in zip(row, strides, strict=True)
    ):
        raise ValueError(f"a transfer row is {strides} bytes, not {row}")
    return b"".join(section + part for section, part in zip(sections, row, strict=True))


#: The :mod:`smw_tools.asm_regions` regions the document's parts are the ROM
#: image of -- the ids every codec below and the stamp tables' one resolve
#: through.
WARP_REGION = "overworld.star_pipe_warps"
SILENT_REGION = "overworld.silent_tiles"
DESTROY_REGION = "overworld.destroyed_tiles"
EXIT_REGION = "overworld.path_exits"
LEVEL_NAMES_REGION = "overworld.level_names"
STAMP_REGION = "overworld.layer2_events"
SUBS_REGION = "overworld.event_tile_locations"
SWAPS_REGION = "overworld.event_tile_swaps"
TRANSLEVEL_LEVELS_REGION = "overworld.translevel_levels"

#: The remap table's shape: one word per translevel, `$60` rows -- the
#: ``translevel-remap`` feature's own table, fixed because everything else
#: indexed by translevel is.
TRANSLEVEL_LEVELS_COUNT = 0x60
TRANSLEVEL_LEVELS_SIZE = TRANSLEVEL_LEVELS_COUNT * 2


@lru_cache(maxsize=8)
def _sized_region(region_id: str, entries: int) -> asm_codec.AsmRegion:
    """``region_id``'s region with ``entries`` rows in each of its sections.

    The count is the data's own rather than the stock format's: a cartridge
    whose feature grew one of these tables has a longer part, and the region
    has to be told so before its codec will read or write one -- see
    :meth:`~smw_tools.asm_codec.AsmRegion.with_entry_counts`. One number
    sizes every section, because every region reached from here is a set of
    parallel tables one loop indexes.
    """
    # The declared lookup rather than `region_for`: the format is the
    # registry's whatever cartridge is in hand, and the translevel-levels
    # region is withheld from `regions()` on a base without its feature.
    region = asm_regions.declared_region(region_id)
    return region.with_entry_counts(dict.fromkeys(region.entry_counts(), entries))


def _region_model(  # noqa: ANN202 - the region codec's shape
    region_id: str, sections: tuple[bytes, ...], entries: int
):
    """``sections`` as ``region_id``'s model, through the region's own codec.

    What a row of one of these tables *is* -- how wide its values are and how
    they group -- is declared once, in :mod:`smw_tools.asm_regions`, which is
    also what emits and parses the fragment a save writes. Reading the part
    through the same codec is what stops a stride here from drifting from the
    one the fragment is written at.
    """
    region = _sized_region(region_id, entries)
    return region.decode(dict(zip(region.sections, sections, strict=True)))


def _region_bytes(region_id: str, model) -> bytes:  # noqa: ANN001 - codec shape
    """``region_id``'s model back as the document's part, sections in table
    order -- :func:`_region_model`'s inverse, through the same codec.

    The count is the model's own and no room is given, so nothing is priced:
    this packs a document part, and what a save must fit is asked where the
    save is, against the project's own symbol file.
    """
    entries = len(model[0]) if model else 0
    region = _sized_region(region_id, entries)
    images = region.encode(model)
    return b"".join(images[role] for role in region.sections)


def warp_region_model(warps: bytes) -> tuple[tuple[int, ...], ...]:
    """The part as the ``overworld.star_pipe_warps`` region's model: four
    tuples of words."""
    return _region_model(
        WARP_REGION, warp_sections(warps), MapShape.of_parts(warps=warps).warps
    )


def warps_from_model(model: tuple[tuple[int, ...], ...]) -> bytes:
    """The region's model packed back into the document's part."""
    return _region_bytes(WARP_REGION, model)


def silent_region_model(silent: bytes) -> tuple[tuple[int, ...], ...]:
    """The part as the ``overworld.silent_tiles`` region's model: the event
    numbers and layers as bytes, the locations and tile numbers as words."""
    return _region_model(
        SILENT_REGION, silent_sections(silent), MapShape.of_parts(silent=silent).silent
    )


def silent_from_model(model: tuple[tuple[int, ...], ...]) -> bytes:
    """The region's model packed back into the document's part."""
    return _region_bytes(SILENT_REGION, model)


def silent_sections(silent: bytes) -> tuple[bytes, bytes, bytes, bytes]:
    """The part as its four per-section ROM images, in table order.

    Split by the part's own length -- six bytes a slot across the four
    parallel arrays -- so a cartridge with a longer block splits its own,
    exactly as :func:`warp_sections` does.
    """
    slots = len(silent) // 6
    return (
        silent[:slots],
        silent[slots : slots * 2],
        silent[slots * 2 : slots * 4],
        silent[slots * 4 : slots * 6],
    )


@lru_cache(maxsize=4)
def _destroy_region(slots: int) -> asm_codec.AsmRegion:
    """The destroyed-tiles region with ``slots`` scan rows.

    Its own helper rather than :func:`_sized_region`, which sizes every
    section alike: this region is two tables of different lengths, and the
    ruin-kind triples are :data:`DESTROY_TILES` whatever the scan holds.
    """
    region = asm_regions.region_for(DESTROY_REGION)
    return region.with_entry_counts(
        {
            "overworld_destroy_locations": slots,
            "overworld_destroy_events": slots,
        }
    )


def destroy_region_model(destroy: bytes) -> tuple[tuple[int, ...], ...]:
    """The part as the ``overworld.destroyed_tiles`` region's model: the
    three ruin-kind tables as bytes, then the scan's location words and
    event numbers."""
    slots = MapShape.of_parts(destroy=destroy).destroy
    region = _destroy_region(slots)
    return region.decode(
        dict(zip(region.sections, destroy_sections(destroy), strict=True))
    )


def destroy_from_model(model: tuple[tuple[int, ...], ...]) -> bytes:
    """The region's model packed back into the document's part."""
    region = _destroy_region(len(model[-1]) if model else 0)
    images = region.encode(model)
    return b"".join(images[role] for role in region.sections)


def destroy_sections(destroy: bytes) -> tuple[bytes, bytes, bytes, bytes, bytes]:
    """The part as its five per-section ROM images, in table order --
    before, top and bottom tiles, then the scan's locations and events.

    Split by the part's own length, like :func:`silent_sections`: three bytes
    an entry across both halves, with the ruin kinds fixed, so a cartridge
    whose scan table grew splits its own.
    """
    shape = MapShape.of_parts(destroy=destroy)
    return (
        destroy[: shape.destroy_top_at],
        destroy[shape.destroy_top_at : shape.destroy_bottom_at],
        destroy[shape.destroy_bottom_at : shape.destroy_locations_at],
        destroy[shape.destroy_locations_at : shape.destroy_events_at],
        destroy[shape.destroy_events_at : shape.destroy_size],
    )


def subs_region_model(subs: bytes) -> tuple[tuple[int, ...], ...]:
    """The part as the ``overworld.event_tile_locations`` region's model:
    one tuple of cell words, one per event."""
    return _region_model(SUBS_REGION, (subs,), MapShape.of_parts(subs=subs).subs)


def subs_from_model(model) -> bytes:  # noqa: ANN001 - the region codec's shape
    """The region's model packed back into the document's part."""
    return _region_bytes(SUBS_REGION, model)


def swaps_region_model(swaps: bytes) -> tuple[tuple[int, ...], ...]:
    """The part as the ``overworld.event_tile_swaps`` region's model: the
    before tiles and the after tiles, as many of each as the part holds."""
    return _region_model(
        SWAPS_REGION, swap_sections(swaps), MapShape.of_parts(swaps=swaps).swaps
    )


def swaps_from_model(model) -> bytes:  # noqa: ANN001 - the region codec's shape
    """The region's model packed back into the document's part."""
    return _region_bytes(SWAPS_REGION, model)


def swap_sections(swaps: bytes) -> tuple[bytes, bytes]:
    """The part as its two per-section ROM images -- the before tiles, then
    the after tiles -- split by the part's own length like every other
    section split here."""
    half = len(swaps) // 2
    return swaps[:half], swaps[half:]


def exit_region_model(exits: bytes):  # noqa: ANN201 - the region codec's shape
    """The part as the ``overworld.path_exits`` region's model: two tuples
    of (pixel Y, pixel X, submap) rows and one of (grid row, column) pairs."""
    return _region_model(
        EXIT_REGION, exit_sections(exits), MapShape.of_parts(exits=exits).exits
    )


def exits_from_model(model) -> bytes:  # noqa: ANN001 - the region codec's shape
    """The region's model packed back into the document's part."""
    return _region_bytes(EXIT_REGION, model)


def level_names_region_model(level_names: bytes) -> tuple[tuple[int, ...], ...]:
    """The part as the ``overworld.level_names`` region's model: one tuple
    of words."""
    return _region_model(
        LEVEL_NAMES_REGION,
        (level_names,),
        MapShape.of_parts(level_names=level_names).level_names,
    )


def level_names_from_model(model) -> bytes:  # noqa: ANN001 - the region codec's shape
    """The region's model packed back into the document's part."""
    return _region_bytes(LEVEL_NAMES_REGION, model)


def translevel_levels_region_model(part: bytes) -> tuple[tuple[int, ...], ...]:
    """The part as the ``overworld.translevel_levels`` region's model: one
    tuple of words."""
    return _region_model(TRANSLEVEL_LEVELS_REGION, (part,), len(part) // 2)


def translevel_levels_from_model(model) -> bytes:  # noqa: ANN001 - codec shape
    """The region's model packed back into the document's part."""
    return _region_bytes(TRANSLEVEL_LEVELS_REGION, model)


def _check_part(
    name: str, part: bytes | None, stride: int, entries: int | None
) -> None:
    """Refuse a part that is not this table's shape.

    ``entries`` is the cartridge's count where the caller had one, and the
    part must be exactly that; without one the only claim a part can fail is
    its own format -- a whole number of fixed-width entries. See
    :meth:`WorldMap.read`.
    """
    if part is None:
        return
    if entries is not None:
        if len(part) != entries * stride:
            raise ValueError(
                f"the {name} is {entries * stride:#x} bytes on this cartridge, "
                f"not {len(part):#x}"
            )
    elif stride > 1 and len(part) % stride:
        raise ValueError(
            f"the {name} is {stride} bytes an entry, and {len(part):#x} is not "
            f"a whole number of them"
        )


def _check_grown_part(
    name: str, part: bytes | None, stride: int, region: str, head: int = 0
) -> None:
    """Refuse a growable part its table's reader could not scan.

    Not the cartridge's count: a table whose scan follows its rows holds
    whatever the last save gave it, and a part is right as long as it is a
    whole number of entries from one up to the reader's reach --
    :func:`table_allows`. ``head`` is what precedes the rows in the part (the
    destroyed-tiles block's ruin kinds). See :meth:`WorldMap.read`.
    """
    if part is None:
        return
    if len(part) < head or (len(part) - head) % stride:
        raise ValueError(
            f"the {name} is {stride} bytes an entry, and {len(part):#x} is not "
            f"a whole number of them"
        )
    if not table_allows(region, (len(part) - head) // stride):
        raise ValueError(
            f"the {name} holds {(len(part) - head) // stride} entries, which its "
            f"scan cannot reach"
        )


def _picture_cell(x: int, y: int, submap: int) -> tuple[int, int]:
    """A grid position on one map, as the stacked picture's cell."""
    return x, y + (PAGE_ROWS if submap else 0)


def _exit_record(exits: bytes, at: int) -> tuple[int, int]:
    """The picture cell the five-byte exit record at ``at`` names.

    The record is (pixel Y, pixel X, submap) in that order, and both the
    trigger and the landing sections hold it -- which is why the offset is
    the argument and the section is the caller's.
    """
    return _picture_cell(
        _word(exits, at + 2) >> 4, _word(exits, at) >> 4, exits[at + 4]
    )


@lru_cache(maxsize=8)
def warp_links(warps: bytes) -> Mapping[int, tuple[int, int]]:
    """Every warp's link: trigger cell index to destination ``(x, y)`` cell.

    The game searches its tables from the last entry down and takes the
    first match, so a later entry shadows an earlier one at the same spot --
    which insertion order reproduces here.
    """
    links: dict[int, tuple[int, int]] = {}
    for entry, (x, y) in enumerate(_warp_triggers(warps)):
        if 0 <= x < COLUMNS and 0 <= y < ROWS:
            links[cell_index(x, y)] = warp_landing(warps, entry)
    return links


def warp_landing(warps: bytes, entry: int) -> tuple[int, int]:
    """Where warp ``entry`` lands, as a picture ``(x, y)`` cell."""
    shape = MapShape.of_parts(warps=warps)
    packed = _word(warps, shape.warp_x_at + entry * 2)
    pixel_y = _word(warps, shape.warp_y_at + entry * 2)
    return _picture_cell((packed & 0x1FF) >> 4, pixel_y >> 4, (packed >> 9) & 0x0F)


def warp_landing_submap(warps: bytes, entry: int) -> int:
    """Which map warp ``entry`` lands on -- the stored bits, which in the
    viewport overlaps can honestly differ from the nearest camera's answer."""
    at = MapShape.of_parts(warps=warps).warp_x_at
    return (_word(warps, at + entry * 2) >> 9) & 0x0F


def _stored_place(x: int, y: int, submap: int) -> str:
    """A landing named on its *stored* map -- :func:`cell_place`'s reading
    for the transfers, whose tables carry the byte the overlapping viewports
    make undeducible from the cell."""
    where = SUBMAP_NAMES[submap] if submap < len(SUBMAP_NAMES) else f"map {submap}"
    return f"{hexspot(x, y)} on {where}"


def warp_landing_place(warps: bytes, entry: int) -> str:
    """Where warp ``entry`` lands, named on the landing's stored map."""
    x, y = warp_landing(warps, entry)
    return _stored_place(x, y, warp_landing_submap(warps, entry))


def exit_landing_place(exits: bytes, entry: int) -> str:
    """Where exit ``entry`` lands, named on the landing's stored map."""
    x, y = exit_landing(exits, entry)
    at = MapShape.of_parts(exits=exits).exit_landings_at
    return _stored_place(x, y, exits[at + entry * 5 + 4])


@lru_cache(maxsize=8)
def exit_links(exits: bytes) -> Mapping[int, tuple[int, int]]:
    """Every path exit's link, in :func:`warp_links`' shape and on its
    last-entry-wins terms."""
    links: dict[int, tuple[int, int]] = {}
    for entry, (x, y) in enumerate(_exit_triggers(exits)):
        if 0 <= x < COLUMNS and 0 <= y < ROWS:
            links[cell_index(x, y)] = exit_landing(exits, entry)
    return links


def exit_landing(exits: bytes, entry: int) -> tuple[int, int]:
    """Where exit ``entry`` lands, as a picture ``(x, y)`` cell -- from the
    landing pixels, which is where the walk-in actually shows the player."""
    at = MapShape.of_parts(exits=exits).exit_landings_at + entry * 5
    return _exit_record(exits, at)


def warp_trigger(warps: bytes, entry: int) -> tuple[int, int]:
    """Where warp ``entry`` triggers, as a picture ``(x, y)`` cell."""
    trigger = _word(warps, entry * 2)
    row = _word(warps, MapShape.of_parts(warps=warps).warp_rows_at + entry * 2)
    return _picture_cell(trigger & 0xFF, row, trigger >> 8)


def exit_trigger(exits: bytes, entry: int) -> tuple[int, int]:
    """Where path exit ``entry`` triggers, as a picture ``(x, y)`` cell."""
    return _exit_record(exits, entry * 5)


def exit_trigger_submap(exits: bytes, entry: int) -> int:
    """Which map path exit ``entry``'s trigger stands on -- the stored byte,
    on :func:`warp_trigger_submap`'s terms."""
    return exits[entry * 5 + 4]


def warp_trigger_submap(warps: bytes, entry: int) -> int:
    """Which map warp ``entry``'s trigger stands on -- the stored byte, not
    a derivation: the submap viewports overlap, and the shipped table names
    Vanilla Dome for a cell the nearest camera would call the Forest's."""
    return _word(warps, entry * 2) >> 8


@lru_cache(maxsize=8)
def _warp_triggers(warps: bytes) -> tuple[tuple[int, int], ...]:
    """Every warp's trigger cell, in table order. Cached: the panel asks
    which entry a cell triggers on every cursor move, and the table does not
    move under it."""
    return tuple(warp_trigger(warps, entry) for entry in range(len(warps) // 8))


@lru_cache(maxsize=8)
def _exit_triggers(exits: bytes) -> tuple[tuple[int, int], ...]:
    """Every path exit's trigger cell, in table order -- :func:`_warp_triggers`
    on this transfer's records."""
    return tuple(_exit_record(exits, entry * 5) for entry in range(len(exits) // 12))


def warp_entry_at(warps: bytes, index: int) -> int | None:
    """The warp entry triggered standing on cell ``index``, or ``None`` --
    the highest matching entry, as the game's own search answers."""
    spot = cell_at(index)
    found = _warp_triggers(warps)
    for entry in reversed(range(len(found))):
        if found[entry] == spot:
            return entry
    return None


def exit_entry_at(exits: bytes, index: int) -> int | None:
    """The path-exit entry triggered at cell ``index``, or ``None``."""
    spot = cell_at(index)
    found = _exit_triggers(exits)
    for entry in reversed(range(len(found))):
        if found[entry] == spot:
            return entry
    return None


#: The shipped links, for the cartridge-shaped facts tests pin and for any
#: caller with no document in hand.
WARP_LINKS: Mapping[int, tuple[int, int]] = warp_links(VANILLA_WARPS)
EXIT_LINKS: Mapping[int, tuple[int, int]] = exit_links(VANILLA_EXITS)


def cell_place(x: int, y: int) -> str:
    """A cell named the way a person reads the map: its coordinates, on the
    map whose camera would show them."""
    if y < PAGE_ROWS:
        return f"{hexspot(x, y)} on {SUBMAP_NAMES[0]}"
    submap = submap_at(x * BLOCK + BLOCK // 2, (y - PAGE_ROWS) * BLOCK + BLOCK // 2)
    return f"{hexspot(x, y)} on {SUBMAP_NAMES[submap]}"


def is_level_tile(tile: int) -> bool:
    """Whether the translevel scan counts this Map16 number as a level."""
    return FIRST_LEVEL_TILE <= tile <= LAST_LEVEL_TILE


@lru_cache(maxsize=8)
def scan_translevels(tiles: bytes) -> bytes:
    """The translevel of every cell, ``0`` where no level is.

    The game's own load-time scan: walk the tilemap in index order and hand a
    counter, starting at 1, to every level tile. Cached because every edit asks
    again and the answer only changes when the tilemap does.
    """
    found = bytearray(TILEMAP_SIZE)
    number = 1
    for index, tile in enumerate(tiles):
        if is_level_tile(tile):
            found[index] = number & 0xFF
            number += 1
    return bytes(found)


def level_number(translevel: int, submap_area: bool, levels: bytes = b"") -> int | None:
    """The level a translevel loads, or ``None`` for "no level here".

    Main-map translevels are the level number outright. A submap translevel
    drops the main map's count and gains the submap bit -- which the game keys
    off where the *player* stands, so a main-map numbered translevel walked to
    from the submap area would resolve differently; the committed map never
    does that, and this answers for cells in their own area.

    ``levels`` is the remap table where the cartridge carries one
    (:attr:`WorldMap.translevel_levels`, the ``translevel-remap`` feature):
    the row is the answer, whole, and can spell what the arithmetic cannot --
    ``$000``, and the ``$0DC``-``$0FF`` bands -- because the game reads it
    instead of computing. Empty reads as the stock computation.
    """
    if translevel == 0:
        return None
    if levels:
        at = translevel * 2
        if at + 2 > len(levels):
            return None
        return int.from_bytes(levels[at : at + 2], "little")
    if translevel > LAST_MAIN_MAP_TRANSLEVEL:
        translevel -= LAST_MAIN_MAP_TRANSLEVEL
    return translevel + (0x100 if submap_area else 0)


# -- the translevel repoint ---------------------------------------------------
#
# Placing or removing a level tile renumbers every later level, and four ROM
# tables are indexed by that number. Two of them the document carries and the
# repoint below moves: the walk directions and the level events. Two of them
# the game's *code* hardwires and no table shuffle can fix -- the repoint's
# caller warns instead:

#: The translevel the game compares against ``$7E13BF`` for the Valley of
#: Bowser earthquake cue -- ``!Define_SMW_LevelID_EarthquakeEvent``.
EARTHQUAKE_TRANSLEVEL = 0x18

#: The two translevels whose save bytes double as the Special World global
#: flags (``!RAM_SMW_Overworld_LevelTileSettings+$48``/``+$49``): whatever
#: levels wear these numbers share their save slots with those flags.
SPECIAL_FLAG_TRANSLEVELS = (0x48, 0x49)

#: The hardwired numbers with the words a warning names them by.
HARDWIRED_TRANSLEVELS = {
    EARTHQUAKE_TRANSLEVEL: "the earthquake cue",
    SPECIAL_FLAG_TRANSLEVELS[0]: "a Special World flag slot",
    SPECIAL_FLAG_TRANSLEVELS[1]: "a Special World flag slot",
}


def translevel_moves(before: bytes, after: bytes) -> dict[int, int]:
    """Which levels a tilemap edit renumbered: old translevel to new, for
    every cell numbered in both scans whose number changed. A level tile
    placed or removed shows up in the *other* levels' moves, not its own."""
    old = scan_translevels(before)
    new = scan_translevels(after)
    return {
        was: now
        for was, now in zip(old, new, strict=True)
        if was and now and was != now
    }


def repointed_translevel_rows(
    before: bytes, after: bytes, table: bytes, default: int, width: int = 1
) -> bytes:
    """``table`` -- one ``width``-byte row per translevel -- with its rows
    following the renumber from tilemap ``before`` to ``after``.

    Every cell numbered in both scans keeps its row; a cell whose level tile
    is new gets ``default`` (little-endian over the row). Rows no scan
    reaches keep their bytes, so a tilemap edit that renumbers nothing
    returns ``table`` itself -- the identity contract every no-op diff
    downstream keys off.
    """
    old = scan_translevels(before)
    new = scan_translevels(after)
    out = bytearray(table)
    blank = default.to_bytes(width, "little")
    for was, now in zip(old, new, strict=True):
        if not now or (now + 1) * width > len(out):
            continue
        if was and (was + 1) * width <= len(table):
            out[now * width : (now + 1) * width] = table[
                was * width : (was + 1) * width
            ]
        else:
            out[now * width : (now + 1) * width] = blank
    if out == table:
        return table
    return bytes(out)


def repointed_translevel_levels(before: bytes, after: bytes, table: bytes) -> bytes:
    """The remap table's rows following the renumber from ``before`` to
    ``after`` -- :func:`repointed_translevel_rows` with the one default a
    static byte cannot spell: a fresh level tile starts at the arithmetic's
    answer for its own cell, which is what the cartridge loads with no table
    at all, rather than at some fixed level every new tile would share.
    """
    old = scan_translevels(before)
    new = scan_translevels(after)
    out = bytearray(table)
    for cell, (was, now) in enumerate(zip(old, new, strict=True)):
        if not now or (now + 1) * 2 > len(out):
            continue
        if was and (was + 1) * 2 <= len(table):
            out[now * 2 : now * 2 + 2] = table[was * 2 : was * 2 + 2]
        else:
            fresh = level_number(now, cell >= TILEMAP_SIZE // 2) or 0
            out[now * 2 : now * 2 + 2] = fresh.to_bytes(2, "little")
    if out == table:
        return table
    return bytes(out)


@dataclass(frozen=True)
class WorldMap:
    """The world map as a document: every part of it the editor can edit.

    Immutable like :class:`~shiny_mushroom.edit.Level`, and under the same
    contract: an operation returns a new document, or **``self`` when it had
    nothing to do**, which is the identity
    :class:`~shiny_mushroom.edit.History` keys no-ops off. Nothing here needs
    a uid -- no part ever inserts or deletes, so an index *is* an identity.

    One document rather than one per part, so one history carries every kind
    of edit and one dirty flag answers for all of them. A part can be absent
    (``b""``) -- a phase-one document, or a synthetic one in a test -- and an
    operation on an absent part **raises** rather than silently doing nothing.
    """

    #: The Layer 1 tilemap: ``$800`` Map16 numbers, one per cell.
    tiles: bytes

    #: The Layer 2 tilemap: ``$4000`` bytes of interleaved 8x8 entries, even
    #: byte the tile number, odd the ``YXPCCCTT`` attributes -- see
    #: :func:`layer2_word` for the arrangement. Empty when not carried.
    layer2: bytes = b""

    #: The event stamp sheets and their properties, ``$D00`` bytes each --
    #: what the revealed paths look like. Carried as a pair: every sheet byte
    #: has a properties byte at the same offset.
    stamps: bytes = b""
    stamp_props: bytes = b""

    #: The sprite slot table, 65 bytes -- see :data:`SPRITE_TABLE_SIZE`.
    sprites: bytes = b""

    #: The per-translevel walk-directions table, ``$71`` bytes -- which way
    #: the player walks after clearing each level.
    directions: bytes = b""

    #: The per-translevel event table, ``$60`` bytes -- which event each
    #: level's clear fires, ``$FF`` for none; the secret exit fires the next
    #: number up with no table of its own.
    level_events: bytes = b""

    #: The per-translevel level-name words, ``$BA`` bytes -- carried only on
    #: the international targets, whose word format the editable region
    #: speaks. :meth:`level_name` / :meth:`level_name_set` read and write a
    #: row; the repoint keeps the rows with their levels. What a word says is
    #: :mod:`shiny_mushroom.level_names`' business.
    level_names: bytes = b""

    #: The per-translevel level numbers, ``$C0`` bytes of ``$60`` words --
    #: which level each translevel loads. Carried only on a cartridge with
    #: the ``translevel-remap`` feature, whose table this is; empty
    #: everywhere else, where the game computes the number and
    #: :func:`level_number`'s arithmetic is the truth.
    #: :meth:`translevel_level` / :meth:`translevel_level_set` read and write
    #: a row; :meth:`level_of` answers the way the cartridge in hand does,
    #: table or arithmetic; the repoint keeps the rows with their levels.
    translevel_levels: bytes = b""

    #: The star/pipe warp and path-exit tables, packed as the module header
    #: describes. Defaulted to the shipped tables rather than absent, like
    #: :attr:`sprite_disable`: the connectors and the properties panel read
    #: them on every cell, and vanilla's answer is the right one wherever a
    #: capture supplied nothing better.
    warps: bytes = VANILLA_WARPS
    exits: bytes = VANILLA_EXITS

    #: The Layer 2 event placements: where each event stamps its blocks.
    #: Empty when not carried, like every other part.
    events: StampPlacements = ()

    #: The silent-tiles block, ``$108`` bytes: the four parallel tables of
    #: the offscreen tiles flagged events place with no animation -- event
    #: numbers, layers, locations, tile numbers. Empty when not carried.
    silent: bytes = b""

    #: The destroyed-tiles block, ``$3F`` bytes: the ruin kinds' before, top
    #: and bottom tiles -- :data:`DESTROY_TILES` of each -- then the scan's
    #: location words and event numbers, laid out as the ROM lays them out.
    #: Empty when not carried.
    destroy: bytes = b""

    #: The pass-1 substitution's location table, ``$E0`` bytes: one cell word
    #: per event, naming where the event substitutes a Layer 1 tile. What
    #: appears there is whatever :attr:`swaps` maps the current tile onto --
    #: the location says *where* and never *what*. Empty when not carried.
    subs: bytes = b""

    #: The substitution's before/after pairs: the from-tiles, then as many
    #: matching to-tiles -- ``$2C`` bytes on a stock cartridge, and a table
    #: whose scans follow its rows, so the pairs add and delete -- shared by
    #: every event -- the game's own arrangement, so an edit here changes
    #: every substitution landing on that tile at once. Empty when not
    #: carried.
    swaps: bytes = b""

    #: Which maps show each sprite number -- the cartridge's own table where
    #: a capture supplied one, vanilla's otherwise. Defaulted rather than
    #: absent, like :attr:`warps`: every sprite decoded from the document
    #: answers ``appears_on`` and its map spots through it, so there is no
    #: state where the markers have nothing to go on.
    #:
    #: Editable through :meth:`sprite_disable_set`, and saved as the
    #: ``overworld.sprite_submaps`` asm region. One row per sprite *number*,
    #: so an edit moves every slot holding that number at once -- which is
    #: the game's own arrangement and not this editor's simplification.
    sprite_disable: tuple[int, ...] = SPRITE_SUBMAP_DISABLE

    #: Where a submap draws a ghost, relative to its main-map position --
    #: the cartridge's own pairs where a capture supplied them, vanilla's
    #: otherwise. Context on the same terms as :attr:`sprite_disable`.
    sprite_boo_offsets: tuple[tuple[int, int], ...] = SUBMAP_BOO_OFFSETS

    #: Where the smoke draws on each map -- the cartridge's own pairs where a
    #: capture supplied them, vanilla's otherwise. Context on the same terms
    #: as :attr:`sprite_disable`.
    sprite_smoke_positions: tuple[tuple[int, int], ...] = SMOKE_MAP_POSITIONS

    @property
    def shape(self) -> MapShape:
        """How many entries each of this document's tables holds.

        **Read off the parts**, not carried beside them: every table is a
        whole number of fixed-width entries, so its length is the count, and
        a document cannot disagree with its own bytes about how much of it
        there is. A part this document does not carry counts zero, which is
        what every operation on one already refuses over.

        What checks a part against the *cartridge* is :meth:`read`, once,
        where the shape it is supposed to have is known.
        """
        return MapShape.of_parts(
            directions=self.directions,
            level_events=self.level_events,
            level_names=self.level_names,
            events=self.events,
            silent=self.silent,
            destroy=self.destroy,
            subs=self.subs,
            swaps=self.swaps,
            warps=self.warps,
            exits=self.exits,
        )

    @classmethod
    def read(
        cls,
        tiles: bytes,
        *,
        layer2: bytes | None = None,
        stamps: bytes | None = None,
        stamp_props: bytes | None = None,
        sprites: bytes | None = None,
        directions: bytes | None = None,
        level_events: bytes | None = None,
        level_names: bytes | None = None,
        translevel_levels: bytes | None = None,
        events: StampPlacements | None = None,
        silent: bytes | None = None,
        destroy: bytes | None = None,
        subs: bytes | None = None,
        swaps: bytes | None = None,
        sprite_disable: bytes | None = None,
        sprite_boo_offsets: Sequence[tuple[int, int]] | None = None,
        sprite_smoke_positions: Sequence[tuple[int, int]] | None = None,
        warps: bytes | None = None,
        exits: bytes | None = None,
        shape: MapShape | None = None,
    ) -> WorldMap:
        """The document these parts' bytes describe.

        ``shape`` is the **cartridge's** own -- :meth:`MapShape.of` over the
        base its ROM was built from -- and every variable-length part is
        checked against it, so a capture that read the wrong number of entries
        is refused here rather than saved back short.

        Without one the parts decide, and each is checked only for holding a
        whole number of entries: a synthetic map in a test, and a document
        built before any capture, have no cartridge to be right about. Either
        way :attr:`shape` afterwards is what the parts hold.
        """
        if len(tiles) != TILEMAP_SIZE:
            raise ValueError(
                f"a world map is {TILEMAP_SIZE:#x} bytes, not {len(tiles):#x}"
            )
        if layer2 is not None and len(layer2) != LAYER2_SIZE:
            raise ValueError(
                f"a Layer 2 tilemap is {LAYER2_SIZE:#x} bytes, not {len(layer2):#x}"
            )
        if (stamps is None) != (stamp_props is None):
            raise ValueError("the stamp sheets and their properties are a pair")
        for name, part in (("sheets", stamps), ("properties", stamp_props)):
            if part is not None and len(part) != SHEETS_SIZE:
                raise ValueError(
                    f"the stamp {name} are {SHEETS_SIZE:#x} bytes, not {len(part):#x}"
                )
        if sprites is not None and len(sprites) != SPRITE_TABLE_SIZE:
            raise ValueError(
                f"the sprite table is {SPRITE_TABLE_SIZE} bytes, not {len(sprites)}"
            )
        _check_part(
            "walk-directions table", directions, 1, shape.directions if shape else None
        )
        _check_part(
            "level-events table", level_events, 1, shape.level_events if shape else None
        )
        _check_part(
            "level-names table", level_names, 2, shape.level_names if shape else None
        )
        _check_part(
            "translevel-levels table",
            translevel_levels,
            2,
            TRANSLEVEL_LEVELS_COUNT,
        )
        if events is not None and events != ():
            if shape is not None and len(events) != shape.stamp_events:
                raise ValueError(
                    f"the stamp placements name {shape.stamp_events} events, "
                    f"not {len(events)}"
                )
            for event in events:
                for sheet, destination in event:
                    if not (0 <= sheet <= 0xFFFF and 0 <= destination <= 0xFFFF):
                        raise ValueError("a stamp placement is two words")
        # The growable parts are held to what their scans reach, not to the
        # cartridge's count: a save that grew one is ahead of the build it
        # was priced against until the next assemble, and is still the edit.
        _check_grown_part("silent-tiles block", silent, 6, SILENT_REGION)
        # The destroyed-tiles block grows only on a cartridge whose build binds
        # its scan to the table -- the stock scan reads eight entries past it,
        # and a part that is not its length would put the over-read elsewhere.
        if shape is not None and DESTROY_REGION not in shape.grows:
            _check_part(
                "destroyed-tiles block", destroy, 3, DESTROY_TILES + shape.destroy
            )
        else:
            _check_grown_part(
                "destroyed-tiles block",
                destroy,
                3,
                DESTROY_REGION,
                head=DESTROY_TILES * 3,
            )
        _check_part("substitution locations", subs, 2, shape.subs if shape else None)
        # The pairs travel with the locations -- the replay reads them as one
        # mechanism, and a lone half would preview the disassembly's other
        # half under an edit the console will not make.
        if (subs is None) != (swaps is None):
            raise ValueError(
                "the substitution locations and their swap pairs are a pair"
            )
        _check_grown_part("substitution pairs", swaps, 2, SWAPS_REGION)
        if sprite_disable is not None and len(sprite_disable) != len(
            SPRITE_SUBMAP_DISABLE
        ):
            raise ValueError(
                f"the sprite disable table is {len(SPRITE_SUBMAP_DISABLE)} "
                f"bytes, not {len(sprite_disable)}"
            )
        if sprite_boo_offsets is not None:
            if len(sprite_boo_offsets) > SPRITE_SLOTS:
                raise ValueError(
                    f"the ghost offsets reach {len(sprite_boo_offsets)} slots, "
                    f"past the {SPRITE_SLOTS} the table has"
                )
            for pair in sprite_boo_offsets:
                if len(pair) != 2 or not all(-0x8000 <= n <= 0x7FFF for n in pair):
                    raise ValueError("a ghost offset is a pair of signed words")
        if sprite_smoke_positions is not None:
            if len(sprite_smoke_positions) > len(SUBMAP_NAMES):
                raise ValueError(
                    f"the smoke positions reach {len(sprite_smoke_positions)} "
                    f"maps, past the {len(SUBMAP_NAMES)} there are"
                )
            for pair in sprite_smoke_positions:
                if len(pair) != 2 or not all(-0x8000 <= n <= 0x7FFF for n in pair):
                    raise ValueError("a smoke position is a pair of signed words")
        # The two parts that fall back to the shipped tables rather than to
        # absence are checked **after** the fallback: what the document will
        # hold is what has to be this cartridge's shape, and a cartridge whose
        # feature grew its warp table is not one vanilla's 27 rows describe.
        held_warps = bytes(warps) if warps else VANILLA_WARPS
        held_exits = bytes(exits) if exits else VANILLA_EXITS
        _check_grown_part("warp tables", held_warps, 8, WARP_REGION)
        _check_grown_part("exit tables", held_exits, 12, EXIT_REGION)
        return cls(
            bytes(tiles),
            layer2=bytes(layer2) if layer2 else b"",
            stamps=bytes(stamps) if stamps else b"",
            stamp_props=bytes(stamp_props) if stamp_props else b"",
            sprites=bytes(sprites) if sprites else b"",
            directions=bytes(directions) if directions else b"",
            level_events=bytes(level_events) if level_events else b"",
            level_names=bytes(level_names) if level_names else b"",
            translevel_levels=bytes(translevel_levels) if translevel_levels else b"",
            events=tuple(tuple(tuple(pair) for pair in event) for event in events)
            if events
            else (),
            silent=bytes(silent) if silent else b"",
            destroy=bytes(destroy) if destroy else b"",
            subs=bytes(subs) if subs else b"",
            swaps=bytes(swaps) if swaps else b"",
            sprite_disable=tuple(sprite_disable)
            if sprite_disable
            else SPRITE_SUBMAP_DISABLE,
            sprite_boo_offsets=tuple(
                (int(dx), int(dy)) for dx, dy in sprite_boo_offsets
            )
            if sprite_boo_offsets
            else SUBMAP_BOO_OFFSETS,
            sprite_smoke_positions=tuple(
                (int(x), int(y)) for x, y in sprite_smoke_positions
            )
            if sprite_smoke_positions
            else SMOKE_MAP_POSITIONS,
            warps=held_warps,
            exits=held_exits,
        )

    def tile(self, index: int) -> int:
        """The Map16 number in this cell."""
        if not 0 <= index < TILEMAP_SIZE:
            raise ValueError(f"no cell with index {index:#x}")
        return self.tiles[index]

    def placed(self, cells: Mapping[int, int]) -> WorldMap:
        """This map with each index holding its given tile.

        Returns ``self`` when nothing changes -- an empty mapping, or tiles
        that are already there.
        """
        changed = bytearray(self.tiles)
        for index, tile in cells.items():
            if not 0 <= index < TILEMAP_SIZE:
                raise ValueError(f"no cell with index {index:#x}")
            if not 0 <= tile <= 0xFF:
                raise ValueError(f"no Map16 tile {tile:#x} on the overworld")
            changed[index] = tile
        if changed == self.tiles:
            return self
        return replace(self, tiles=bytes(changed))

    def filled(self, indices: Iterable[int], tile: int) -> WorldMap:
        """This map with one tile stamped over every given cell."""
        return self.placed({index: tile for index in indices})

    def layer2_entry(self, index: int) -> int:
        """The 16-bit entry behind Layer 2's 8x8 tile ``index`` -- see
        :func:`layer2_index` for the index space."""
        self._require_layer2()
        if not 0 <= index < LAYER2_ENTRY_COUNT:
            raise ValueError(f"no Layer 2 entry with index {index:#x}")
        return self.layer2[index * 2] | (self.layer2[index * 2 + 1] << 8)

    def layer2_placed(self, entries: Mapping[int, int]) -> WorldMap:
        """This map with each Layer 2 index holding its given 16-bit entry.

        The same contract as :meth:`placed`: ``self`` when nothing changes.
        """
        self._require_layer2()
        changed = bytearray(self.layer2)
        for index, word in entries.items():
            if not 0 <= index < LAYER2_ENTRY_COUNT:
                raise ValueError(f"no Layer 2 entry with index {index:#x}")
            if not 0 <= word <= 0xFFFF:
                raise ValueError(f"a Layer 2 entry is 16 bits, not {word:#x}")
            changed[index * 2] = word & 0xFF
            changed[index * 2 + 1] = word >> 8
        if changed == self.layer2:
            return self
        return replace(self, layer2=bytes(changed))

    def _require_layer2(self) -> None:
        if not self.layer2:
            raise ValueError("this document carries no Layer 2")

    def stamp_entry(self, offset: int) -> tuple[int, int]:
        """The stamp sheet's ``(tile, properties)`` pair at ``offset``."""
        self._require_stamps()
        if not 0 <= offset < SHEETS_SIZE:
            raise ValueError(f"no stamp sheet byte at {offset:#x}")
        return self.stamps[offset], self.stamp_props[offset]

    def stamp_placed(self, cells: Mapping[int, tuple[int, int]]) -> WorldMap:
        """This map with each sheet offset holding its ``(tile, properties)``
        pair -- both parts written together, because the game reads them as
        one entry. The same contract as :meth:`placed`.
        """
        self._require_stamps()
        tiles = bytearray(self.stamps)
        props = bytearray(self.stamp_props)
        for offset, (tile, prop) in cells.items():
            if not 0 <= offset < SHEETS_SIZE:
                raise ValueError(f"no stamp sheet byte at {offset:#x}")
            if not (0 <= tile <= 0xFF and 0 <= prop <= 0xFF):
                raise ValueError("a stamp entry is two bytes: tile, properties")
            tiles[offset] = tile
            props[offset] = prop
        if tiles == self.stamps and props == self.stamp_props:
            return self
        return replace(self, stamps=bytes(tiles), stamp_props=bytes(props))

    def stamp_word(self, offset: int) -> int:
        """The sheet entry at ``offset`` as one 16-bit tilemap word.

        The spelling Layer 2 uses -- a stamp entry is the same format, split
        across two parallel tables only because the game stores it that way,
        so everything that draws or edits an entry speaks words and the bit
        layout stays in here.
        """
        tile, prop = self.stamp_entry(offset)
        return tile | (prop << 8)

    def stamp_words_placed(self, words: Mapping[int, int]) -> WorldMap:
        """:meth:`stamp_placed` over whole words, the shape
        :meth:`stamp_word` reads back."""
        return self.stamp_placed(
            {offset: (word & 0xFF, word >> 8) for offset, word in words.items()}
        )

    def _require_stamps(self) -> None:
        if not self.stamps:
            raise ValueError("this document carries no event stamps")

    def sprite(self, slot: int) -> OverworldSprite:
        """Slot ``slot`` of the sprite table, decoded."""
        self._require_sprites()
        if not 0 <= slot < SPRITE_SLOTS:
            raise ValueError(f"no sprite slot {slot}")
        at = slot * SPRITE_STRIDE
        x = int.from_bytes(self.sprites[at + 1 : at + 3], "little", signed=True)
        y = int.from_bytes(self.sprites[at + 3 : at + 5], "little", signed=True)
        return OverworldSprite(
            slot,
            self.sprites[at],
            x,
            y,
            disable=self.sprite_disable,
            boo_offsets=self.sprite_boo_offsets,
            smoke_positions=self.sprite_smoke_positions,
        )

    def sprite_replaced(self, slot: int, sprite_id: int) -> WorldMap:
        """This map with ``slot`` holding sprite ``sprite_id``, position kept.
        The same contract as :meth:`placed`."""
        self._require_sprites()
        if not 0 <= slot < SPRITE_SLOTS:
            raise ValueError(f"no sprite slot {slot}")
        if not 0 <= sprite_id < len(SPRITE_NAMES):
            raise ValueError(f"no overworld sprite {sprite_id:#x}")
        changed = bytearray(self.sprites)
        changed[slot * SPRITE_STRIDE] = sprite_id
        if changed == self.sprites:
            return self
        return replace(self, sprites=bytes(changed))

    def sprite_moved(self, slot: int, x: int, y: int) -> WorldMap:
        """This map with ``slot`` at signed map pixel ``(x, y)``.
        The same contract as :meth:`placed`."""
        self._require_sprites()
        if not 0 <= slot < SPRITE_SLOTS:
            raise ValueError(f"no sprite slot {slot}")
        for name, value in (("X", x), ("Y", y)):
            if not -0x8000 <= value <= 0x7FFF:
                raise ValueError(f"a sprite's {name} is a signed word, not {value}")
        changed = bytearray(self.sprites)
        at = slot * SPRITE_STRIDE
        changed[at + 1 : at + 3] = x.to_bytes(2, "little", signed=True)
        changed[at + 3 : at + 5] = y.to_bytes(2, "little", signed=True)
        if changed == self.sprites:
            return self
        return replace(self, sprites=bytes(changed))

    def _require_sprites(self) -> None:
        if not self.sprites:
            raise ValueError("this document carries no overworld sprites")

    def direction(self, translevel: int) -> int:
        """The ``nn112233`` walk byte for ``translevel``."""
        self._require_directions()
        if not 0 <= translevel < len(self.directions):
            raise ValueError(f"no walk-direction entry {translevel:#x}")
        return self.directions[translevel]

    def direction_set(self, translevel: int, value: int) -> WorldMap:
        """This map with ``translevel``'s walk byte set.
        The same contract as :meth:`placed`."""
        self._require_directions()
        if not 0 <= translevel < len(self.directions):
            raise ValueError(f"no walk-direction entry {translevel:#x}")
        if not 0 <= value <= 0xFF:
            raise ValueError(f"a walk byte is 8 bits, not {value:#x}")
        changed = bytearray(self.directions)
        changed[translevel] = value
        if changed == self.directions:
            return self
        return replace(self, directions=bytes(changed))

    def _require_directions(self) -> None:
        if not self.directions:
            raise ValueError("this document carries no walk directions")

    def level_event(self, translevel: int) -> int:
        """The event number ``translevel``'s clear fires, ``$FF`` for none."""
        self._require_level_events()
        if not 0 <= translevel < len(self.level_events):
            raise ValueError(f"no level-event entry {translevel:#x}")
        return self.level_events[translevel]

    def level_event_set(self, translevel: int, value: int) -> WorldMap:
        """This map with ``translevel``'s event number set.
        The same contract as :meth:`placed`."""
        self._require_level_events()
        if not 0 <= translevel < len(self.level_events):
            raise ValueError(f"no level-event entry {translevel:#x}")
        if not 0 <= value <= 0xFF:
            raise ValueError(f"an event number is 8 bits, not {value:#x}")
        changed = bytearray(self.level_events)
        changed[translevel] = value
        if changed == self.level_events:
            return self
        return replace(self, level_events=bytes(changed))

    def level_name(self, translevel: int) -> int:
        """The name word ``translevel``'s level-name box is assembled from --
        the row of the per-translevel table, as a little-endian word. What
        the word *says* is :mod:`shiny_mushroom.level_names`' business."""
        self._require_level_names()
        if not 0 <= translevel < len(self.level_names) // 2:
            raise ValueError(f"no level-name entry {translevel:#x}")
        return int.from_bytes(
            self.level_names[translevel * 2 : translevel * 2 + 2], "little"
        )

    def level_name_set(self, translevel: int, word: int) -> WorldMap:
        """This map with ``translevel``'s name word set.
        The same contract as :meth:`placed`."""
        self._require_level_names()
        if not 0 <= translevel < len(self.level_names) // 2:
            raise ValueError(f"no level-name entry {translevel:#x}")
        if not 0 <= word <= 0xFFFF:
            raise ValueError(f"a name word is 16 bits, not {word:#x}")
        changed = bytearray(self.level_names)
        changed[translevel * 2 : translevel * 2 + 2] = word.to_bytes(2, "little")
        if changed == self.level_names:
            return self
        return replace(self, level_names=bytes(changed))

    def _require_level_names(self) -> None:
        if not self.level_names:
            raise ValueError("this document carries no level-names table")

    def level_of(self, translevel: int, submap_area: bool) -> int | None:
        """The level ``translevel`` loads on this document's cartridge: its
        remap row where the table is carried, the arithmetic where not --
        the one question every "Level" readout asks."""
        return level_number(translevel, submap_area, self.translevel_levels)

    def translevel_level(self, translevel: int) -> int:
        """The remap table's row for ``translevel``."""
        self._require_translevel_levels()
        if not 0 <= translevel < len(self.translevel_levels) // 2:
            raise ValueError(f"no translevel-level entry {translevel:#x}")
        at = translevel * 2
        return int.from_bytes(self.translevel_levels[at : at + 2], "little")

    def translevel_level_set(self, translevel: int, level: int) -> WorldMap:
        """This map with ``translevel``'s level number set.
        The same contract as :meth:`placed`.

        Any of the 512 levels, including the ones the stock arithmetic cannot
        spell -- the table is read whole, which is half of what it is for.
        """
        self._require_translevel_levels()
        if not 0 <= translevel < len(self.translevel_levels) // 2:
            raise ValueError(f"no translevel-level entry {translevel:#x}")
        if not 0 <= level <= 0x1FF:
            raise ValueError(f"a level number is $000-$1FF, not {level:#x}")
        changed = bytearray(self.translevel_levels)
        changed[translevel * 2 : translevel * 2 + 2] = level.to_bytes(2, "little")
        if changed == self.translevel_levels:
            return self
        return replace(self, translevel_levels=bytes(changed))

    def _require_translevel_levels(self) -> None:
        if not self.translevel_levels:
            raise ValueError(
                "this document carries no translevel-levels table -- the "
                "cartridge computes its level numbers"
            )

    def sprite_disable_set(self, number: int, value: int) -> WorldMap:
        """This map with sprite ``number``'s disable byte set -- which maps
        that sprite appears on. The same contract as :meth:`placed`.

        The row is the *number's*, so this moves every slot holding it. The
        low bit is nothing the game reads; it is kept rather than masked,
        because the byte written back is the cartridge's own.
        """
        if not 1 <= number <= len(self.sprite_disable):
            raise ValueError(f"no sprite disable entry for number {number:#x}")
        if not 0 <= value <= 0xFF:
            raise ValueError(f"a disable byte is 8 bits, not {value:#x}")
        if self.sprite_disable[number - 1] == value:
            return self
        changed = list(self.sprite_disable)
        changed[number - 1] = value
        return replace(self, sprite_disable=tuple(changed))

    def _require_level_events(self) -> None:
        if not self.level_events:
            raise ValueError("this document carries no level-events table")

    def stamp_relocated(self, event: int, entry: int, destination: int) -> WorldMap:
        """This map with one stamp placement pointing at ``destination`` --
        a byte offset into the Layer 2 buffer, even because the buffer's
        entries are words. The same contract as :meth:`placed`.

        Only the destination moves: which sheet block an entry draws is the
        stamp's *contents*, edited through :meth:`stamp_placed`.
        """
        self._require_events()
        if not 0 <= event < len(self.events):
            raise ValueError(f"no event {event:#x} in the placements")
        if not 0 <= entry < len(self.events[event]):
            raise ValueError(f"event {event:#x} has no placement {entry}")
        if not 0 <= destination < LAYER2_SIZE or destination % 2:
            raise ValueError(f"{destination:#x} is not a Layer 2 buffer offset")
        sheet, held = self.events[event][entry]
        if held == destination:
            return self
        placements = list(self.events[event])
        placements[entry] = (sheet, destination)
        events = list(self.events)
        events[event] = tuple(placements)
        return replace(self, events=tuple(events))

    def stamp_reblocked(self, event: int, entry: int, sheet: int) -> WorldMap:
        """This map with one stamp placement drawing the block at ``sheet``
        -- the block's first byte, whose side of the ``$900`` boundary is
        also its size. The same contract as :meth:`placed`.

        Only the block changes: where the entry stamps it is the
        destination, moved through :meth:`stamp_relocated`.
        """
        self._require_events()
        if not 0 <= event < len(self.events):
            raise ValueError(f"no event {event:#x} in the placements")
        if not 0 <= entry < len(self.events[event]):
            raise ValueError(f"event {event:#x} has no placement {entry}")
        if not 0 <= sheet < SHEETS_SIZE:
            raise ValueError(f"no stamp sheet byte at {sheet:#x}")
        held, destination = self.events[event][entry]
        if held == sheet:
            return self
        placements = list(self.events[event])
        placements[entry] = (sheet, destination)
        events = list(self.events)
        events[event] = tuple(placements)
        return replace(self, events=tuple(events))

    def stamp_inserted(self, event: int, sheet: int, destination: int) -> WorldMap:
        """This map with a new placement appended to ``event``'s rows.

        Appended, so the new block reveals last -- row order is the
        animation. No budget check here: the document is data, the mode
        meters the shipped slot, and a save prices the project's own room.
        """
        self._require_events()
        if not 0 <= event < len(self.events):
            raise ValueError(f"no event {event:#x} in the placements")
        if not 0 <= sheet < SHEETS_SIZE:
            raise ValueError(f"no stamp sheet byte at {sheet:#x}")
        if not 0 <= destination < LAYER2_SIZE or destination % 2:
            raise ValueError(f"{destination:#x} is not a Layer 2 buffer offset")
        events = list(self.events)
        events[event] = (*events[event], (sheet, destination))
        return replace(self, events=tuple(events))

    def stamp_deleted(self, event: int, entry: int) -> WorldMap:
        """This map with one placement taken out of ``event``'s rows; the
        later rows close the gap, so their reveal order moves up one."""
        self._require_events()
        if not 0 <= event < len(self.events):
            raise ValueError(f"no event {event:#x} in the placements")
        if not 0 <= entry < len(self.events[event]):
            raise ValueError(f"event {event:#x} has no placement {entry}")
        events = list(self.events)
        rows = list(events[event])
        del rows[entry]
        events[event] = tuple(rows)
        return replace(self, events=tuple(events))

    def stamp_reordered(self, event: int, entry: int, to: int) -> WorldMap:
        """This map with one placement moved to position ``to`` of its
        event's reveal order. The same contract as :meth:`placed`."""
        self._require_events()
        if not 0 <= event < len(self.events):
            raise ValueError(f"no event {event:#x} in the placements")
        rows = list(self.events[event])
        if not (0 <= entry < len(rows) and 0 <= to < len(rows)):
            raise ValueError(f"event {event:#x} has no such placements to reorder")
        if to == entry:
            return self
        rows.insert(to, rows.pop(entry))
        events = list(self.events)
        events[event] = tuple(rows)
        return replace(self, events=tuple(events))

    def _require_events(self) -> None:
        if not self.events:
            raise ValueError("this document carries no stamp placements")

    def silent_entry(self, slot: int) -> tuple[int, int, int, int]:
        """Silent slot ``slot`` decoded: ``(event, layer, location, tile)``.

        ``layer`` is the game's byte -- bit 0 set means a Layer 2 stamp,
        clear a single Layer 1 write; ``location`` indexes the layer's own
        tilemap and ``tile`` is a Map16 number or a sheet source with it.
        """
        self._require_silent()
        shape = self.shape
        if not 0 <= slot < shape.silent:
            raise ValueError(f"no silent-tile slot {slot}")
        return (
            self.silent[slot],
            self.silent[shape.silent_layers_at + slot],
            _word(self.silent, shape.silent_locations_at + slot * 2),
            _word(self.silent, shape.silent_tiles_at + slot * 2),
        )

    def silent_entry_set(
        self, slot: int, event: int, layer: int, location: int, tile: int
    ) -> WorldMap:
        """This map with silent slot ``slot`` holding the given entry whole.
        The same contract as :meth:`placed`."""
        self._require_silent()
        shape = self.shape
        if not 0 <= slot < shape.silent:
            raise ValueError(f"no silent-tile slot {slot}")
        if not 0 <= event <= 0xFF:
            raise ValueError(f"an event number is 8 bits, not {event:#x}")
        if layer not in (0, 1):
            raise ValueError(f"a silent tile's layer is 0 or 1, not {layer}")
        for name, value in (("location", location), ("tile", tile)):
            if not 0 <= value <= 0xFFFF:
                raise ValueError(f"a silent tile's {name} is a word, not {value:#x}")
        changed = bytearray(self.silent)
        changed[slot] = event
        changed[shape.silent_layers_at + slot] = layer
        at = shape.silent_locations_at + slot * 2
        changed[at : at + 2] = location.to_bytes(2, "little")
        at = shape.silent_tiles_at + slot * 2
        changed[at : at + 2] = tile.to_bytes(2, "little")
        if changed == self.silent:
            return self
        return replace(self, silent=bytes(changed))

    def silent_entry_inserted(
        self, event: int, layer: int, location: int, tile: int
    ) -> WorldMap:
        """This map with a new silent slot appended, holding the given entry.
        Refused past what the block may hold (:func:`table_allows`) -- the
        scan's own reach; what fits the cartridge's run of ROM is the save's
        question, and the mode's before it."""
        self._require_silent()
        shape = self.shape
        if not table_allows(SILENT_REGION, shape.silent + 1):
            raise ValueError(
                f"the silent-tiles block cannot hold {shape.silent + 1} slots"
            )
        grown = self.silent[: shape.silent_layers_at] + b"\0"
        grown += self.silent[shape.silent_layers_at : shape.silent_locations_at] + b"\0"
        grown += (
            self.silent[shape.silent_locations_at : shape.silent_tiles_at] + b"\0\0"
        )
        grown += self.silent[shape.silent_tiles_at :] + b"\0\0"
        return replace(self, silent=grown).silent_entry_set(
            shape.silent, event, layer, location, tile
        )

    def silent_entry_deleted(self, slot: int) -> WorldMap:
        """This map with silent slot ``slot`` taken out, the later slots
        closing up by one. Refused below one slot, which the scan cannot do
        without -- an unwanted last slot is parked on an event that never
        runs instead."""
        self._require_silent()
        shape = self.shape
        if not 0 <= slot < shape.silent:
            raise ValueError(f"no silent-tile slot {slot}")
        if not table_allows(SILENT_REGION, shape.silent - 1):
            raise ValueError("the silent-tiles block cannot lose its last slot")
        events = bytearray(self.silent[: shape.silent_layers_at])
        layers = bytearray(
            self.silent[shape.silent_layers_at : shape.silent_locations_at]
        )
        locations = bytearray(
            self.silent[shape.silent_locations_at : shape.silent_tiles_at]
        )
        tiles = bytearray(self.silent[shape.silent_tiles_at :])
        del events[slot]
        del layers[slot]
        del locations[slot * 2 : slot * 2 + 2]
        del tiles[slot * 2 : slot * 2 + 2]
        return replace(self, silent=bytes(events + layers + locations + tiles))

    def _require_silent(self) -> None:
        if not self.silent:
            raise ValueError("this document carries no silent-tiles block")

    def destroy_entry(self, slot: int) -> tuple[int, int]:
        """Destroy slot ``slot`` decoded: ``(event, location)``.

        ``location`` is a Layer 1 cell index -- the ruin's *top* cell, since a
        two-cell ruin writes the row below as well.
        """
        self._require_destroy()
        shape = self.shape
        if not 0 <= slot < shape.destroy:
            raise ValueError(f"no destroyed-tile slot {slot}")
        return (
            self.destroy[shape.destroy_events_at + slot],
            _word(self.destroy, shape.destroy_locations_at + slot * 2),
        )

    def destroy_entry_set(self, slot: int, event: int, location: int) -> WorldMap:
        """This map with destroy slot ``slot`` holding the given row whole.
        The same contract as :meth:`placed`."""
        self._require_destroy()
        shape = self.shape
        if not 0 <= slot < shape.destroy:
            raise ValueError(f"no destroyed-tile slot {slot}")
        if not 0 <= event <= 0xFF:
            raise ValueError(f"an event number is 8 bits, not {event:#x}")
        if not 0 <= location <= 0xFFFF:
            raise ValueError(
                f"a destroyed tile's location is a word, not {location:#x}"
            )
        changed = bytearray(self.destroy)
        changed[shape.destroy_events_at + slot] = event
        at = shape.destroy_locations_at + slot * 2
        changed[at : at + 2] = location.to_bytes(2, "little")
        if changed == self.destroy:
            return self
        return replace(self, destroy=bytes(changed))

    def destroy_ruin(self, kind: int) -> tuple[int, int, int]:
        """Ruin kind ``kind`` decoded: ``(before, top, bottom)`` Map16 tiles.

        The scan matches a cell against ``before``; a kind at or past index 3
        is two cells tall and writes ``top`` where it matched and ``bottom``
        the row below, and a shorter one writes only ``bottom``.
        """
        self._require_destroy()
        shape = self.shape
        if not 0 <= kind < DESTROY_TILES:
            raise ValueError(f"no ruin kind {kind}")
        return (
            self.destroy[kind],
            self.destroy[shape.destroy_top_at + kind],
            self.destroy[shape.destroy_bottom_at + kind],
        )

    def destroy_ruin_set(
        self, kind: int, before: int, top: int, bottom: int
    ) -> WorldMap:
        """This map with ruin kind ``kind`` holding the given triple whole.
        The same contract as :meth:`placed`."""
        self._require_destroy()
        shape = self.shape
        if not 0 <= kind < DESTROY_TILES:
            raise ValueError(f"no ruin kind {kind}")
        for name, value in (("before", before), ("top", top), ("bottom", bottom)):
            if not 0 <= value <= 0xFF:
                raise ValueError(f"a ruin's {name} tile is a byte, not {value:#x}")
        changed = bytearray(self.destroy)
        changed[kind] = before
        changed[shape.destroy_top_at + kind] = top
        changed[shape.destroy_bottom_at + kind] = bottom
        if changed == self.destroy:
            return self
        return replace(self, destroy=bytes(changed))

    def _require_destroy(self) -> None:
        if not self.destroy:
            raise ValueError("this document carries no destroyed-tiles block")

    def destroy_entry_inserted(self, event: int, location: int) -> WorldMap:
        """This map with a new destroy slot appended, holding the given entry
        -- the highest-numbered slot, which the scan tries first. Refused past
        what the table's reader could reach (:func:`table_allows`); whether
        the cartridge's scan follows the rows at all, and what fits its run,
        are the mode's questions before this."""
        self._require_destroy()
        shape = self.shape
        if not table_allows(DESTROY_REGION, shape.destroy + 1):
            raise ValueError(
                f"the destroyed-tiles block cannot hold {shape.destroy + 1} slots"
            )
        if not 0 <= event <= 0xFF:
            raise ValueError(f"an event number is 8 bits, not {event:#x}")
        if not 0 <= location <= 0xFFFF:
            raise ValueError(f"a destroy location is a word, not {location:#x}")
        kinds = self.destroy[: shape.destroy_locations_at]
        locations = self.destroy[shape.destroy_locations_at : shape.destroy_events_at]
        events = self.destroy[shape.destroy_events_at :]
        return replace(
            self,
            destroy=kinds
            + locations
            + location.to_bytes(2, "little")
            + events
            + bytes([event]),
        )

    def destroy_entry_deleted(self, slot: int) -> WorldMap:
        """This map with destroy slot ``slot`` taken out, the later slots
        closing up by one. Refused below one slot, which the scan cannot do
        without -- an unwanted last slot is parked on an event that never
        runs instead."""
        self._require_destroy()
        shape = self.shape
        if not 0 <= slot < shape.destroy:
            raise ValueError(f"no destroyed-tile slot {slot}")
        if not table_allows(DESTROY_REGION, shape.destroy - 1):
            raise ValueError("the destroyed-tiles block cannot lose its last slot")
        kinds = self.destroy[: shape.destroy_locations_at]
        locations = bytearray(
            self.destroy[shape.destroy_locations_at : shape.destroy_events_at]
        )
        events = bytearray(self.destroy[shape.destroy_events_at :])
        del locations[slot * 2 : slot * 2 + 2]
        del events[slot]
        return replace(self, destroy=kinds + bytes(locations) + bytes(events))

    def subs_cell(self, event: int) -> int:
        """The cell index event ``event``'s substitution aims at.

        Zero is the table's idle value -- the game still scans cell 0, so
        "no substitution" is only as true as cell 0 matching no from-tile.
        """
        self._require_subs()
        if not 0 <= event < self.shape.subs:
            raise ValueError(f"no substitution row for event {event:#x}")
        return _word(self.subs, event * 2)

    def subs_cell_set(self, event: int, location: int) -> WorldMap:
        """This map with event ``event``'s substitution aimed at
        ``location``. The same contract as :meth:`placed`."""
        self._require_subs()
        if not 0 <= event < self.shape.subs:
            raise ValueError(f"no substitution row for event {event:#x}")
        if not 0 <= location <= 0xFFFF:
            raise ValueError(f"a substitution location is a word, not {location:#x}")
        changed = bytearray(self.subs)
        changed[event * 2 : event * 2 + 2] = location.to_bytes(2, "little")
        if changed == self.subs:
            return self
        return replace(self, subs=bytes(changed))

    def swap_pair(self, pair: int) -> tuple[int, int]:
        """Substitution pair ``pair`` decoded: ``(before, after)`` Map16
        tiles. The scan matches a location's tile against ``before`` from the
        last pair down; :data:`SWAP_DOUBLED_PAIR` writes the next cell too."""
        self._require_subs()
        pairs = self.shape.swaps
        if not 0 <= pair < pairs:
            raise ValueError(f"no substitution pair {pair}")
        return self.swaps[pair], self.swaps[pairs + pair]

    def swap_pair_set(self, pair: int, before: int, after: int) -> WorldMap:
        """This map with substitution pair ``pair`` holding the given tiles.
        The same contract as :meth:`placed`."""
        self._require_subs()
        pairs = self.shape.swaps
        if not 0 <= pair < pairs:
            raise ValueError(f"no substitution pair {pair}")
        for name, value in (("before", before), ("after", after)):
            if not 0 <= value <= 0xFF:
                raise ValueError(f"a pair's {name} tile is a byte, not {value:#x}")
        changed = bytearray(self.swaps)
        changed[pair] = before
        changed[pairs + pair] = after
        if changed == self.swaps:
            return self
        return replace(self, swaps=bytes(changed))

    def swap_pair_inserted(self, before: int, after: int) -> WorldMap:
        """This map with a new substitution pair appended -- the table's last
        row, which the scans try first. Refused past what the table may hold
        (:func:`table_allows`); what fits the cartridge's run of ROM is the
        save's question, and the mode's before it."""
        self._require_subs()
        pairs = self.shape.swaps
        if not table_allows(SWAPS_REGION, pairs + 1):
            raise ValueError(f"the substitution pairs cannot hold {pairs + 1} rows")
        for name, value in (("before", before), ("after", after)):
            if not 0 <= value <= 0xFF:
                raise ValueError(f"a pair's {name} tile is a byte, not {value:#x}")
        froms, tos = self.swaps[:pairs], self.swaps[pairs:]
        return replace(self, swaps=froms + bytes([before]) + tos + bytes([after]))

    def swap_pair_deleted(self, pair: int) -> WorldMap:
        """This map with substitution pair ``pair`` taken out, the later
        pairs closing up -- so the doubled pair's place, fixed in the game's
        code, may come to hold another pair's tiles, as the table's note says.
        Refused below one pair, which the scans cannot do without."""
        self._require_subs()
        pairs = self.shape.swaps
        if not 0 <= pair < pairs:
            raise ValueError(f"no substitution pair {pair}")
        if not table_allows(SWAPS_REGION, pairs - 1):
            raise ValueError("the substitution pairs cannot lose their last row")
        froms, tos = bytearray(self.swaps[:pairs]), bytearray(self.swaps[pairs:])
        del froms[pair]
        del tos[pair]
        return replace(self, swaps=bytes(froms + tos))

    def _require_subs(self) -> None:
        if not self.subs:
            raise ValueError("this document carries no substitution tables")

    def warp_retargeted(self, entry: int, x: int, y: int) -> WorldMap:
        """This map with warp ``entry`` landing on the cell at ``(x, y)``.

        The landing is the node's center pixel, with the submap decided the
        way :func:`spawn_for_cell` decides one -- the nearest camera, since
        the viewports overlap. The same contract as :meth:`placed`.
        """
        shape = self.shape
        if not 0 <= entry < shape.warps:
            raise ValueError(f"no warp entry {entry}")
        landing = spawn_for_cell(x, y)
        changed = bytearray(self.warps)
        at = shape.warp_x_at + entry * 2
        changed[at : at + 2] = (landing.x | (landing.submap << 9)).to_bytes(2, "little")
        at = shape.warp_y_at + entry * 2
        changed[at : at + 2] = landing.y.to_bytes(2, "little")
        if changed == self.warps:
            return self
        return replace(self, warps=bytes(changed))

    def exit_retargeted(self, entry: int, x: int, y: int) -> WorldMap:
        """This map with path exit ``entry`` landing on the cell at ``(x, y)``.

        The landing position is the node's center like a warp's, and the grid
        pair follows it as ``pixel >> 4`` -- the shipped rows that deviate
        stay as they are until retargeted. The same contract as :meth:`placed`.
        """
        shape = self.shape
        if not 0 <= entry < shape.exits:
            raise ValueError(f"no path-exit entry {entry}")
        landing = spawn_for_cell(x, y)
        changed = bytearray(self.exits)
        at = shape.exit_landings_at + entry * 5
        changed[at : at + 2] = landing.y.to_bytes(2, "little")
        changed[at + 2 : at + 4] = landing.x.to_bytes(2, "little")
        changed[at + 4] = landing.submap
        at = shape.exit_cells_at + entry * 2
        changed[at] = landing.y >> 4
        changed[at + 1] = landing.x >> 4
        if changed == self.exits:
            return self
        return replace(self, exits=bytes(changed))

    def warp_trigger_moved(self, entry: int, x: int, y: int) -> WorldMap:
        """This map with warp ``entry`` triggering on the cell at ``(x, y)``.

        The stored submap follows the page, not the viewport: a move within
        the submap half keeps the entry's own submap -- the viewports overlap,
        so deriving one could silently rename the map the shipped table chose
        -- and only a move onto the half whose byte cannot be right picks a
        new one (main page forces the main map; a main-map entry moved onto
        the submap half starts from the nearest camera, correctable through
        :meth:`warp_trigger_mapped`). The same contract as :meth:`placed`.
        """
        shape = self.shape
        if not 0 <= entry < shape.warps:
            raise ValueError(f"no warp entry {entry}")
        if not (0 <= x < COLUMNS and 0 <= y < ROWS):
            raise ValueError(f"no cell at {hexspot(x, y)}")
        held = warp_trigger_submap(self.warps, entry)
        if y < PAGE_ROWS:
            submap = 0
        elif held:
            submap = held
        else:
            submap = submap_at(x * 16 + 8, (y % PAGE_ROWS) * 16 + 8)
        changed = bytearray(self.warps)
        changed[entry * 2 : entry * 2 + 2] = (x | (submap << 8)).to_bytes(2, "little")
        at = shape.warp_rows_at + entry * 2
        changed[at : at + 2] = (y % PAGE_ROWS).to_bytes(2, "little")
        if changed == self.warps:
            return self
        return replace(self, warps=bytes(changed))

    def warp_trigger_mapped(self, entry: int, submap: int) -> WorldMap:
        """This map with warp ``entry``'s trigger standing on ``submap``.

        The trigger's grid position stays; which page of the picture the cell
        is on follows the map, since submap zero *is* the main page. The same
        contract as :meth:`placed`.
        """
        if not 0 <= entry < self.shape.warps:
            raise ValueError(f"no warp entry {entry}")
        if not 0 <= submap < len(SUBMAP_NAMES):
            raise ValueError(f"no submap {submap}")
        changed = bytearray(self.warps)
        changed[entry * 2 + 1] = submap
        if changed == self.warps:
            return self
        return replace(self, warps=bytes(changed))

    def warp_row(self, entry: int) -> tuple[bytes, ...]:
        """Warp ``entry``'s whole record -- its slice of each of the four
        tables, which is everything a copy of it has to carry."""
        if not 0 <= entry < self.shape.warps:
            raise ValueError(f"no warp entry {entry}")
        return transfer_row(warp_sections(self.warps), WARP_STRIDES, entry)

    def warp_row_appended(self, row: tuple[bytes, ...]) -> WorldMap:
        """This map with ``row`` -- a :meth:`warp_row` record -- added as the
        last warp, which the search tries first, so it answers its cell over
        any earlier entry on the same one.

        Refused past what the search reaches (:func:`table_allows`); what
        fits the cartridge's run of ROM is the mode's question first.
        """
        shape = self.shape
        if not table_allows(WARP_REGION, shape.warps + 1):
            raise ValueError(f"the warp tables cannot hold {shape.warps + 1} entries")
        return replace(
            self,
            warps=transfer_appended(warp_sections(self.warps), row, WARP_STRIDES),
        )

    def warp_duplicated(self, entry: int) -> WorldMap:
        """This map with a copy of warp ``entry`` appended, on
        :meth:`warp_row_appended`'s terms -- so the copy answers the cell
        until it is moved."""
        return self.warp_row_appended(self.warp_row(entry))

    def warp_deleted(self, entry: int) -> WorldMap:
        """This map with warp ``entry`` taken out of all four tables, the
        later entries closing up -- and renumbering, which is the canvas
        selection's and the Warps/Exits tab's to follow. Refused below one
        entry."""
        shape = self.shape
        if not 0 <= entry < shape.warps:
            raise ValueError(f"no warp entry {entry}")
        if not table_allows(WARP_REGION, shape.warps - 1):
            raise ValueError("the warp tables cannot lose their last entry")
        kept = []
        for section in warp_sections(self.warps):
            held = bytearray(section)
            del held[entry * 2 : entry * 2 + 2]
            kept.append(bytes(held))
        return replace(self, warps=b"".join(kept))

    def exit_row(self, entry: int) -> tuple[bytes, ...]:
        """Path exit ``entry``'s whole record -- :meth:`warp_row`'s contract
        on this transfer's three tables, sub-cell pixel offsets and all."""
        if not 0 <= entry < self.shape.exits:
            raise ValueError(f"no path-exit entry {entry}")
        return transfer_row(exit_sections(self.exits), EXIT_STRIDES, entry)

    def exit_row_appended(self, row: tuple[bytes, ...]) -> WorldMap:
        """This map with ``row`` added as the last path exit --
        :meth:`warp_row_appended`'s contract on this transfer's tables."""
        shape = self.shape
        if not table_allows(EXIT_REGION, shape.exits + 1):
            raise ValueError(f"the exit tables cannot hold {shape.exits + 1} entries")
        return replace(
            self,
            exits=transfer_appended(exit_sections(self.exits), row, EXIT_STRIDES),
        )

    def exit_duplicated(self, entry: int) -> WorldMap:
        """This map with a copy of path exit ``entry`` appended, on
        :meth:`exit_row_appended`'s terms."""
        return self.exit_row_appended(self.exit_row(entry))

    def exit_deleted(self, entry: int) -> WorldMap:
        """This map with path exit ``entry`` taken out of all three tables,
        the later entries closing up. Refused below one entry."""
        shape = self.shape
        if not 0 <= entry < shape.exits:
            raise ValueError(f"no path-exit entry {entry}")
        if not table_allows(EXIT_REGION, shape.exits - 1):
            raise ValueError("the exit tables cannot lose their last entry")
        triggers, landings, cells = (
            bytearray(section) for section in exit_sections(self.exits)
        )
        del triggers[entry * 5 : entry * 5 + 5]
        del landings[entry * 5 : entry * 5 + 5]
        del cells[entry * 2 : entry * 2 + 2]
        return replace(self, exits=bytes(triggers + landings + cells))

    def exit_trigger_moved(self, entry: int, x: int, y: int) -> WorldMap:
        """This map with path exit ``entry`` triggering on the cell at
        ``(x, y)``.

        The trigger is matched against the walking player's *exact* pixel
        position, and where inside the cell that pixel falls depends on the
        path the player arrives by -- the shipped rows carry both conventions
        -- so the entry keeps its own sub-cell offsets and only the cell
        moves. The stored submap follows :meth:`warp_trigger_moved`'s rule.
        """
        shape = self.shape
        if not 0 <= entry < shape.exits:
            raise ValueError(f"no path-exit entry {entry}")
        if not (0 <= x < COLUMNS and 0 <= y < ROWS):
            raise ValueError(f"no cell at {hexspot(x, y)}")
        at = entry * 5
        pixel_y, pixel_x = _word(self.exits, at), _word(self.exits, at + 2)
        held = self.exits[at + 4]
        if y < PAGE_ROWS:
            submap = 0
        elif held:
            submap = held
        else:
            submap = submap_at(x * 16 + 8, (y % PAGE_ROWS) * 16 + 8)
        changed = bytearray(self.exits)
        changed[at : at + 2] = (((y % PAGE_ROWS) << 4) | (pixel_y & 0xF)).to_bytes(
            2, "little"
        )
        changed[at + 2 : at + 4] = ((x << 4) | (pixel_x & 0xF)).to_bytes(2, "little")
        changed[at + 4] = submap
        if changed == self.exits:
            return self
        return replace(self, exits=bytes(changed))

    def exit_trigger_mapped(self, entry: int, submap: int) -> WorldMap:
        """This map with path exit ``entry``'s trigger standing on ``submap``
        -- :meth:`warp_trigger_mapped`'s contract."""
        if not 0 <= entry < self.shape.exits:
            raise ValueError(f"no path-exit entry {entry}")
        if not 0 <= submap < len(SUBMAP_NAMES):
            raise ValueError(f"no submap {submap}")
        changed = bytearray(self.exits)
        changed[entry * 5 + 4] = submap
        if changed == self.exits:
            return self
        return replace(self, exits=bytes(changed))

    @property
    def translevels(self) -> bytes:
        """What the scan hands out over this map as it stands -- see
        :func:`scan_translevels`."""
        return scan_translevels(self.tiles)


def repointed(before: WorldMap, document: WorldMap) -> tuple[WorldMap, dict[int, int]]:
    """``document`` with its per-translevel rows following the renumber from
    ``before``'s tilemap, and the moves that drove them.

    What makes a Layer 1 edit safe to make: the walk-directions,
    level-events and level-names tables are indexed by the derived
    translevel, so when an edit renumbers the levels, each level's rows move
    with it -- a fresh level tile starts with no walks, no event and the
    blank name. The two hardwired numbers
    (:data:`HARDWIRED_TRANSLEVELS`) cannot be fixed by any table shuffle;
    the caller reads the moves and says so.
    """
    if document.tiles == before.tiles:
        return document, {}
    moves = translevel_moves(before.tiles, document.tiles)
    if not moves:
        return document, {}
    changed: dict[str, bytes] = {}
    if document.directions:
        changed["directions"] = repointed_translevel_rows(
            before.tiles, document.tiles, document.directions, 0
        )
    if document.level_events:
        changed["level_events"] = repointed_translevel_rows(
            before.tiles, document.tiles, document.level_events, NO_EVENT
        )
    if document.level_names:
        changed["level_names"] = repointed_translevel_rows(
            before.tiles,
            document.tiles,
            document.level_names,
            BLANK_LEVEL_NAME,
            width=2,
        )
    if document.translevel_levels:
        changed["translevel_levels"] = repointed_translevel_levels(
            before.tiles, document.tiles, document.translevel_levels
        )
    changed = {
        part: rows
        for part, rows in changed.items()
        if rows is not getattr(document, part)
    }
    if changed:
        document = replace(document, **changed)
    return document, moves


def carried_rows(
    before: WorldMap, document: WorldMap, pairs: Iterable[tuple[int, int]]
) -> tuple[WorldMap, dict[int, int]]:
    """``document`` with each carried level's rows following its tile, and
    the moves that did it -- old translevel to new, where they differ.

    :func:`repointed` maps rows cell-wise, which is right for every level
    that stayed put and wrong for one an edit **carried**: at its old cell
    the level looks deleted and at its new cell it looks fresh, so its rows
    would be dropped for defaults. The gesture that moved it knows the
    identity the scan cannot see -- ``pairs`` are ``(from_cell, to_cell)``
    indexes -- and this writes each carried level's ``before`` rows at its
    new number, over whatever the cell-wise map put there. Composed *after*
    :func:`repointed`, in the same edit, so one undo still takes the tiles
    and every table back together. A pair whose cells carry no level in
    the matching scan says nothing and is skipped.
    """
    old = scan_translevels(before.tiles)
    new = scan_translevels(document.tiles)
    numbered = [
        (old[from_cell], new[to_cell])
        for from_cell, to_cell in pairs
        if old[from_cell] and new[to_cell]
    ]
    moves = {was: now for was, now in numbered if was != now}
    changed: dict[str, bytes] = {}
    for part, width in (
        ("directions", 1),
        ("level_events", 1),
        ("level_names", 2),
        ("translevel_levels", 2),
    ):
        source = getattr(before, part)
        held = getattr(document, part)
        if not source or not held:
            continue
        rows = bytearray(held)
        for was, now in numbered:
            if (was + 1) * width > len(source) or (now + 1) * width > len(held):
                continue
            rows[now * width : (now + 1) * width] = source[
                was * width : (was + 1) * width
            ]
        if bytes(rows) != held:
            changed[part] = bytes(rows)
    if changed:
        document = replace(document, **changed)
    return document, moves


# -- drawing -----------------------------------------------------------------
#
# The same machinery a level is drawn with, over the overworld's inputs. Layer
# 1 is Map16 through the overworld's own definition table, which is exactly
# what :class:`~shiny_mushroom.level.Blocks` does given a snapshot whose
# ``definition`` answers from that table. Layer 2 is the part a level renderer
# cannot do: a raw 8x8 tilemap, four tiles behind each cell, composed under
# Layer 1 through its transparent pixels.
#
# **The composition is an approximation, stated:** on hardware Layer 2 is on
# the subscreen and reaches the picture through colour *addition* wherever the
# main screen shows backdrop. Adding onto a black backdrop is the identity, so
# everywhere the backdrop is black this picture is exact; over a non-black
# backdrop the real console would show layer-2-plus-backdrop where this shows
# layer 2 alone. For an editor's picture that is the right trade against
# emulating per-pixel screen math.

#: One overworld map's Layer 2 half: four $800-byte pages of 8x8 entries.
LAYER2_MAP_BYTES = 0x2000

#: A map's Layer 2 side in 8x8 tiles: 64 across, 64 down.
LAYER2_TILES = 64


def world_blocks(snapshot: OverworldSnapshot) -> Blocks:
    """The tile/block cache the map is drawn out of.

    :class:`~shiny_mushroom.level.Blocks` only reads ``definition``, ``vram``,
    ``cgram`` and ``back_area_color``, all of which an overworld snapshot
    answers -- so the level's whole decoding pipeline is reused unchanged.
    Build one per snapshot and hand it to every call that draws, or let each
    call build its own and merely repeat some decoding.
    """
    return Blocks(snapshot)


def layer2_index(tx: int, ty: int, submap_area: bool) -> int:
    """The Layer 2 entry index of 8x8 tile ``(tx, ty)`` of one map.

    The buffer is stored exactly as the console's 64x64 tilemap is addressed:
    four 32x32 pages -- top-left, top-right, bottom-left, bottom-right -- and
    the shared submap area's whole arrangement again after the main map's.
    The index doubles as the offset into each of the two compressed streams,
    which is why edits and saves both speak it.
    """
    if not (0 <= tx < LAYER2_TILES and 0 <= ty < LAYER2_TILES):
        raise ValueError(f"no Layer 2 tile at {hexspot(tx, ty)}")
    page = (ty // 32) * 2 + (tx // 32)
    return (
        (LAYER2_ENTRY_COUNT // 2 if submap_area else 0)
        + page * 0x400
        + (ty % 32) * 32
        + (tx % 32)
    )


def layer2_at(index: int) -> tuple[int, int, bool]:
    """Where a Layer 2 entry index lands: the ``(tx, ty, submap_area)``
    :func:`layer2_index` takes."""
    if not 0 <= index < LAYER2_ENTRY_COUNT:
        raise ValueError(f"no Layer 2 entry with index {index:#x}")
    submap_area = index >= LAYER2_ENTRY_COUNT // 2
    within = index & 0xFFF
    page, offset = divmod(within, 0x400)
    row, column = divmod(offset, 32)
    return (page % 2) * 32 + column, (page // 2) * 32 + row, submap_area


def layer2_cell(index: int) -> int:
    """The 16x16 cell whose picture the 8x8 tile at ``index`` sits under --
    what a Layer 2 edit hands :func:`world_runs` to repaint."""
    tx, ty, submap_area = layer2_at(index)
    return cell_index(tx // 2, ty // 2 + (PAGE_ROWS if submap_area else 0))


def layer2_word(layer2: bytes, tx: int, ty: int, submap_area: bool) -> int:
    """The SNES tilemap entry behind 8x8 tile ``(tx, ty)`` of one map.

    :func:`layer2_index` is the addressing; this reads the interleaved buffer
    through it. A short buffer answers zero, so a synthetic snapshot needs no
    Layer 2.
    """
    offset = layer2_index(tx, ty, submap_area) * 2
    if offset + 1 >= len(layer2):
        return 0
    return layer2[offset] | (layer2[offset + 1] << 8)


def changed_layer2(before: bytes, after: bytes) -> list[int]:
    """Which Layer 2 entries two buffers disagree about, as entry indices --
    :func:`changed_cells`' diff, over the two bytes an entry holds."""
    return sorted({offset // 2 for offset in changed_offsets(before, after)})


@dataclass(frozen=True)
class WorldPainters:
    """The two block caches one world picture is drawn from.

    The picture stacks two pages, and the game colours them independently:
    the main map is only ever shown under its own palette, while the shared
    submap area is drawn by each submap in turn under that submap's. So the
    pages get a cache each -- ``main`` for the top page, ``submap`` for the
    bottom -- and framing a submap recolours the bottom page alone, which is
    both what the console shows and half the pixels to redraw.

    The two are the same object while the main map is framed, so drawing one
    palette costs exactly what drawing one palette used to.
    """

    main: Blocks
    submap: Blocks

    def page(self, row: int) -> Blocks:
        """Whichever cache draws cell row ``row``."""
        return self.submap if row >= PAGE_ROWS else self.main


def _painters(
    painter: Blocks | WorldPainters | None, snapshot: OverworldSnapshot
) -> WorldPainters:
    """``painter`` as a pair, whichever of the two it was given as.

    A bare :class:`~shiny_mushroom.level.Blocks` -- what a caller with one
    palette in mind hands over, tests included -- draws both pages, which is
    the behaviour there was before the pages were split.
    """
    if isinstance(painter, WorldPainters):
        return painter
    blocks = painter if painter is not None else Blocks(snapshot)
    return WorldPainters(blocks, blocks)


def _cell_rows(
    snapshot: OverworldSnapshot,
    blocks: Blocks,
    tiles: bytes,
    layer2: bytes,
    index: int,
    show_layer1: bool = True,
    show_layer2: bool = True,
) -> tuple[bytes, ...]:
    """One cell of the composited picture, as sixteen rows of RGB.

    The two ``show_`` flags are the editor's layer toggles: a hidden Layer 2
    leaves the backdrop in Layer 1's transparent pixels, exactly what the
    console shows with the layer disabled, and a hidden Layer 1 is the
    background alone.
    """
    if show_layer1:
        drawn = blocks.rows(tiles[index])
        holes = blocks.holes(tiles[index])
        if not show_layer2 or not any(holes):
            return drawn
    elif not show_layer2:
        row = snes_color(snapshot.back_area_color) * BLOCK
        return (row,) * BLOCK

    x, y = cell_at(index)
    submap_area = y >= PAGE_ROWS
    tx, ty = x * 2, (y % PAGE_ROWS) * 2
    quarters = [
        blocks.tile_rows(layer2_word(layer2, tx + dx, ty + dy, submap_area))
        for dy in range(2)
        for dx in range(2)
    ]
    rows = [bytearray(quarters[0][r] + quarters[1][r]) for r in range(TILE)] + [
        bytearray(quarters[2][r] + quarters[3][r]) for r in range(TILE)
    ]
    if show_layer1:
        over_holes(rows, drawn, holes)
    return tuple(bytes(line) for line in rows)


def render_world(
    snapshot: OverworldSnapshot,
    tiles: bytes,
    layer2: bytes | None = None,
    painter: Blocks | WorldPainters | None = None,
    show_layer1: bool = True,
    show_layer2: bool = True,
) -> Raster:
    """The whole map, 512 x 1024: the main map atop the shared submap area.

    ``tiles`` -- and ``layer2``, when the document carries one -- are the
    document's rather than the snapshot's, because the picture follows the
    edit and the snapshot is what was captured. ``layer2=None`` falls back to
    the capture's, which is what a phase-one document shows. The ``show_``
    flags hide a layer -- see :func:`_cell_rows`.

    ``painter`` may be a :class:`WorldPainters` pair, which draws each page
    under its own palette; one :class:`~shiny_mushroom.level.Blocks` draws
    both pages under the one it holds.
    """
    painters = _painters(painter, snapshot)
    behind = layer2 if layer2 is not None else snapshot.layer2
    lines: list[bytes] = []
    for y in range(ROWS):
        blocks = painters.page(y)
        drawn = [
            _cell_rows(
                snapshot,
                blocks,
                tiles,
                behind,
                cell_index(x, y),
                show_layer1,
                show_layer2,
            )
            for x in range(COLUMNS)
        ]
        lines.extend(b"".join(cell[r] for cell in drawn) for r in range(BLOCK))
    return Raster(COLUMNS * BLOCK, ROWS * BLOCK, b"".join(lines))


@lru_cache(maxsize=1)
def submap_page_cells() -> tuple[int, ...]:
    """Every cell of the shared submap page, in render order.

    What a palette pick repaints: the main map's page is drawn under palette
    0 whatever is framed, so a pick cannot move a pixel above this band and
    :func:`world_runs` over it lands exactly what a whole
    :func:`render_world` would have.
    """
    return tuple(
        cell_index(x, y) for y in range(PAGE_ROWS, ROWS) for x in range(COLUMNS)
    )


def world_runs(
    snapshot: OverworldSnapshot,
    tiles: bytes,
    cells: Iterable[int],
    layer2: bytes | None = None,
    painter: Blocks | WorldPainters | None = None,
    show_layer1: bool = True,
    show_layer2: bool = True,
) -> tuple[tuple[int, bytes], ...]:
    """Just these cells, as ``(offset, pixels)`` runs into the whole map's
    picture -- sixteen runs per cell, the shape
    :meth:`~shiny_mushroom.ui.picture.Picture.patch` takes.

    What an edit costs to draw: a placement changes a handful of cells, and
    patching those beats re-rendering half a megabyte of picture. The
    ``show_`` flags -- and the painter, which decides each cell's palette by
    the page it sits on -- must match the render the patch lands on.
    """
    painters = _painters(painter, snapshot)
    behind = layer2 if layer2 is not None else snapshot.layer2
    stride = COLUMNS * BLOCK * 3
    runs = []
    for index in cells:
        x, y = cell_at(index)
        rows = _cell_rows(
            snapshot, painters.page(y), tiles, behind, index, show_layer1, show_layer2
        )
        start = y * BLOCK * stride + x * BLOCK * 3
        runs.extend((start + r * stride, rows[r]) for r in range(BLOCK))
    return tuple(runs)


def changed_cells(before: bytes, after: bytes) -> list[int]:
    """Which cells two tilemaps disagree about -- what to hand
    :func:`world_runs` after an edit. One Map16 number a cell, so the tilemap's
    byte offsets are its cells."""
    return changed_offsets(before, after)


def tile_thumbnails(
    snapshot: OverworldSnapshot, painter: Blocks | None = None
) -> list[Raster]:
    """Every defined overworld tile as its own 16x16 raster, in tile order --
    what the palette dock shows. Transparency renders as the backdrop, which
    is what the tile would show placed over nothing."""
    blocks = painter if painter is not None else Blocks(snapshot)
    return [
        Raster(BLOCK, BLOCK, b"".join(blocks.rows(number)))
        for number in range(TILE_COUNT)
    ]


def layer2_thumbnails(
    snapshot: OverworldSnapshot,
    words: Iterable[int],
    painter: Blocks | None = None,
) -> list[Raster]:
    """Each 16-bit Layer 2 entry as its own 8x8 raster, in the given order --
    what the palette dock's Layer 2 tab shows.

    An entry, not a bare tile number: the palette row, the flips and the
    priority bit are all in the word, so the caller composes the attributes
    it is offering and the thumbnail is exactly what a placement would draw.
    """
    blocks = painter if painter is not None else Blocks(snapshot)
    return [Raster(TILE, TILE, b"".join(blocks.tile_rows(word))) for word in words]


def stamp_block_raster(document: WorldMap, sheet: int, painter: Blocks) -> Raster:
    """One stamp block as a raster, from its start offset ``sheet`` -- drawn
    from the document's sheet and properties bytes, so an edited stamp
    previews as it would show."""
    side = 2 if sheet >= SHEET_6X6_SIZE else 6
    tiles = [
        painter.tile_rows(document.stamp_word(sheet + within))
        for within in range(side * side)
    ]
    pixels = bytearray()
    for row in range(side):
        for py in range(TILE):
            for column in range(side):
                pixels += tiles[row * side + column][py]
    return Raster(side * TILE, side * TILE, bytes(pixels))


def stamp_thumbnails(
    document: WorldMap,
    snapshot: OverworldSnapshot,
    *,
    small: bool,
    painter: Blocks | None = None,
) -> list[Raster]:
    """Every block of one stamp sheet as its own raster, in block order --
    what the palette dock's stamp tabs show: the 2x2 sheet's 256 blocks, or
    the 6x6 sheet's 64."""
    blocks = painter if painter is not None else Blocks(snapshot)
    base = SHEET_6X6_SIZE if small else 0
    stride = 4 if small else 36
    return [
        stamp_block_raster(document, base + block * stride, blocks)
        for block in range(sheet_block_count(small=small))
    ]


# -- the event replay ---------------------------------------------------------
#
# The game replays every flagged event on every overworld load, in the order
# of the event numbers: pass 1 walks the Layer 1 side -- the single-tile
# substitution, then the destroyed-castle check, then the silent offscreen
# tiles -- and pass 2 stamps the 6x6/2x2 sheet blocks into Layer 2. This is
# that replay, ported for display. It reads the snapshot's tables, with the
# document's own standing in wherever it carries them (:func:`event_snapshot`
# -- the stamp placements, the silent block, the destroyed tiles) and the stamp
# *contents* from the document as well, so an edit to any of them previews
# everywhere it is used. What the capture alone can say -- the pass-1
# substitution's tables, and the ROM past the destroy block that its scan
# over-reads -- stays the capture's.
#
# What the port deliberately reproduces includes the game's own oddities: the
# destroy scan reads past its table (a shipped off-by-$8), a substitution
# match at pair $15 writes the next cell too, and the silent scan applies
# every matching entry. What it cannot see it skips: a glitch entry naming a
# location off the map writes nothing here, where the game would corrupt RAM.


def sheet_at(offset: int) -> tuple[int, int, int, bool]:
    """Where a sheet offset lands: ``(block, row, column, small)`` -- a 6x6
    block below ``$900``, a 2x2 block above it."""
    if not 0 <= offset < SHEETS_SIZE:
        raise ValueError(f"no stamp sheet byte at {offset:#x}")
    if offset < SHEET_6X6_SIZE:
        block, within = divmod(offset, 36)
        row, column = divmod(within, 6)
        return block, row, column, False
    block, within = divmod(offset - SHEET_6X6_SIZE, 4)
    row, column = divmod(within, 2)
    return block, row, column, True


def sheet_offset(block: int, row: int, column: int, *, small: bool) -> int:
    """The inverse of :func:`sheet_at`."""
    side = 2 if small else 6
    if not (0 <= row < side and 0 <= column < side):
        raise ValueError(f"no ({row}, {column}) in a {side}x{side} block")
    base = SHEET_6X6_SIZE if small else 0
    if not 0 <= block < sheet_block_count(small=small):
        raise ValueError(f"no block {block} in the {side}x{side} sheet")
    return base + block * side * side + row * side + column


# -- the stamp sheets as a picture --------------------------------------------
#
# A sheet is a flat run of entries the game only ever reads a block at a time,
# so drawing one whole means choosing a wrap. Each sheet gets the wrap that
# makes it square -- the 6x6 sheet's 64 blocks as 8 x 8, the 2x2 sheet's 256
# as 16 x 16 -- and every function below counts from that sheet's own corner:
# the two are separate pictures, never one stacked buffer, because a byte
# belongs to exactly one of them and the block sides do not divide each other.

#: How many blocks each sheet's picture lays across before wrapping.
SHEET_ACROSS_6X6 = 8
SHEET_ACROSS_2X2 = 16


def sheet_block_count(*, small: bool) -> int:
    """How many blocks one sheet holds -- its own size over one block's.

    The one place the two sheets' block arithmetic is spelled: everything
    that counts, draws, offsets into or lists them asks here.
    """
    if small:
        return (SHEETS_SIZE - SHEET_6X6_SIZE) // 4
    return SHEET_6X6_SIZE // 36


def sheet_blocks(*, small: bool) -> tuple[int, int, int]:
    """One sheet's picture in blocks: ``(across, down, side in 8x8 tiles)``."""
    count = sheet_block_count(small=small)
    if small:
        return SHEET_ACROSS_2X2, count // SHEET_ACROSS_2X2, 2
    return SHEET_ACROSS_6X6, count // SHEET_ACROSS_6X6, 6


def sheet_grid(*, small: bool) -> tuple[int, int]:
    """One sheet's picture in 8x8 tiles: ``(columns, rows)``."""
    across, down, side = sheet_blocks(small=small)
    return across * side, down * side


def sheet_tile(offset: int) -> tuple[int, int]:
    """Where a sheet offset draws, as an 8x8 tile ``(column, row)`` of the
    picture of **its own** sheet."""
    block, row, column, small = sheet_at(offset)
    across, _down, side = sheet_blocks(small=small)
    return (block % across) * side + column, (block // across) * side + row


def sheet_spot(tx: int, ty: int, *, small: bool) -> int | None:
    """The sheet offset drawn at tile ``(tx, ty)``, or ``None`` off the
    picture -- the addressing a paste and a float count in."""
    across, down, side = sheet_blocks(small=small)
    if not (0 <= tx < across * side and 0 <= ty < down * side):
        return None
    bx, column = divmod(tx, side)
    by, row = divmod(ty, side)
    return sheet_offset(by * across + bx, row, column, small=small)


def render_sheet(
    document: WorldMap,
    snapshot: OverworldSnapshot,
    *,
    small: bool,
    painter: Blocks | None = None,
) -> Raster:
    """One whole stamp sheet as a picture, drawn from the document's own
    bytes -- what the sheet editor puts on the canvas.

    No layers and no backdrop: a sheet entry is a bare tilemap word, and a
    transparent char draws exactly the transparent colour the block would
    show stamped over nothing, which is the honest picture of the byte.
    """
    blocks = painter if painter is not None else Blocks(snapshot)
    across, down, side = sheet_blocks(small=small)
    columns, rows = across * side, down * side
    lines: list[bytes] = []
    for ty in range(rows):
        by, row = divmod(ty, side)
        drawn = [
            blocks.tile_rows(
                document.stamp_word(
                    sheet_offset(by * across + tx // side, row, tx % side, small=small)
                )
            )
            for tx in range(columns)
        ]
        lines.extend(b"".join(tile[r] for tile in drawn) for r in range(TILE))
    return Raster(columns * TILE, rows * TILE, b"".join(lines))


def sheet_runs(
    document: WorldMap,
    snapshot: OverworldSnapshot,
    offsets: Iterable[int],
    *,
    small: bool,
    painter: Blocks | None = None,
) -> tuple[tuple[int, bytes], ...]:
    """Just these offsets, as ``(offset, pixels)`` runs into that sheet's
    whole picture -- eight runs a tile, what :func:`render_sheet` costs to
    keep up to date after an edit.

    Offsets belonging to the *other* sheet are skipped rather than refused:
    an edit spanning both is one document change, and each picture patches
    the half that is its own.
    """
    blocks = painter if painter is not None else Blocks(snapshot)
    columns, _rows = sheet_grid(small=small)
    stride = columns * TILE * 3
    runs = []
    for offset in offsets:
        if (offset >= SHEET_6X6_SIZE) is not small:
            continue
        tx, ty = sheet_tile(offset)
        tile = blocks.tile_rows(document.stamp_word(offset))
        start = ty * TILE * stride + tx * TILE * 3
        runs.extend((start + r * stride, tile[r]) for r in range(TILE))
    return tuple(runs)


def changed_stamps(before: bytes, after: bytes) -> list[int]:
    """Which sheet offsets two stamp parts disagree about. Byte-shaped like
    :func:`changed_cells`; call it for the sheets and the properties and
    union the answers."""
    return changed_cells(before, after)


def changed_sprites(before: bytes, after: bytes) -> list[int]:
    """Which slots two sprite tables disagree about."""
    return [
        slot
        for slot in range(SPRITE_SLOTS)
        if before[slot * SPRITE_STRIDE : (slot + 1) * SPRITE_STRIDE]
        != after[slot * SPRITE_STRIDE : (slot + 1) * SPRITE_STRIDE]
    ]


def sprite_markers(document: WorldMap) -> tuple[OverworldSprite, ...]:
    """Every slot of the document's sprite table, decoded -- empty slots
    included, so all thirteen stay findable on the canvas."""
    return tuple(document.sprite(slot) for slot in range(SPRITE_SLOTS))


def _stamp_walk(destination: int, source: int) -> Iterable[tuple[int, int]]:
    """One stamp's writes, as ``(layer2 entry index, sheet offset)`` pairs.

    ``destination`` is the entry table's byte offset into the Layer 2 buffer;
    ``source`` decides the block size by the ``$900`` threshold. The walk is
    row-major through :func:`layer2_index`, which is the same arrangement the
    game's page-carry arithmetic steps through -- implemented via the
    geometry rather than re-porting the carries, so the two cannot disagree.

    Out-of-range table data is **skipped, not reproduced**: a tile carried
    off a page's edge (the game's carry wraps it into the next page or off
    the buffer entirely), a sheet offset past ``$D00`` (the game reads
    whatever ROM follows the sheets), and a destination outside the buffer
    all yield nothing. Vanilla's tables stay in range -- the byte-exact
    replay probe is the proof -- so the divergence only shows against a
    hacked table, and drawing nothing beats drawing an invented answer.
    """
    if not 0 <= destination < LAYER2_SIZE:
        return
    side = 2 if source >= SHEET_6X6_SIZE else 6
    tx0, ty0, submap_area = layer2_at(destination // 2)
    offset = source
    for row in range(side):
        for column in range(side):
            tx, ty = tx0 + column, ty0 + row
            if tx < LAYER2_TILES and ty < LAYER2_TILES and offset < SHEETS_SIZE:
                yield layer2_index(tx, ty, submap_area), offset
            offset += 1


def _pass2_entries(entries: bytes, pointers: bytes, event: int) -> range:
    """Event ``event``'s slice of the entry table, as entry indices.

    Clipped to entries the table actually holds, so a corrupt pointer names
    nothing rather than reading past the capture -- which is why every walk of
    the table starts here rather than from the pointer pair itself.
    """
    if (event + 2) * 2 > len(pointers):
        return range(0)
    held = len(entries) // 4
    return range(
        min(_word(pointers, event * 2), held),
        min(_word(pointers, (event + 1) * 2), held),
    )


def _pass2_stamps(
    entries: bytes, pointers: bytes, event: int, rows: int | None = None
) -> Iterable[tuple[int, int, int]]:
    """Event ``event``'s pass-2 writes, as ``(entry, layer2 index, sheet
    offset)`` triples in table order.

    :func:`_pass2_entries`' clipped slice unpacked into ``(source,
    destination)`` and walked by :func:`_stamp_walk` -- the four things that
    replay, preview, highlight or hit-test a stamp all read the table this
    way, so they cannot disagree about what an event places. ``rows`` stops
    after that many entry-table rows, for the animation mid-reveal.
    """
    found = _pass2_entries(entries, pointers, event)
    if rows is not None:
        found = found[: max(rows, 0)]
    for entry in found:
        source = _word(entries, entry * 4)
        destination = _word(entries, entry * 4 + 2)
        for index, offset in _stamp_walk(destination, source):
            yield entry, index, offset


def _write_stamp(
    l2: bytearray, stamps: bytes, props: bytes, index: int, offset: int
) -> None:
    """One stamped Layer 2 entry written into ``l2``.

    Skipped where the buffer is short of it: a synthetic snapshot may carry
    less than :data:`LAYER2_SIZE`, and a replay is a picture, not a claim
    about memory the document does not hold.
    """
    at = index * 2
    if at + 1 < len(l2):
        l2[at] = stamps[offset]
        l2[at + 1] = props[offset]


def _substitute(l1: bytearray, snapshot: OverworldSnapshot, event: int) -> None:
    """Pass 1's single-tile substitution, match at pair $15 doubled.

    A location of zero is **not** "no location": ``CODE_04DA49`` loads the
    table entry and scans unconditionally, so a zero-location event reads
    cell 0 and substitutes it if it matches a from-tile. Vanilla's cell 0
    never matches, which is the only reason the difference is invisible on
    the shipped map -- an edited map with a changeable tile there changes on
    the console, so it must change here too.
    """
    locations = snapshot.event_l1_locations
    if (event + 1) * 2 > len(locations):
        return
    index = _word(locations, event * 2)
    if index >= len(l1):
        return
    current = l1[index]
    for pair in range(len(snapshot.event_l1_from) - 1, -1, -1):
        if snapshot.event_l1_from[pair] == current:
            l1[index] = snapshot.event_l1_to[pair]
            if pair == SWAP_DOUBLED_PAIR and index + 1 < len(l1):
                l1[index + 1] = snapshot.event_l1_to[pair]
            return


def _destroy(l1: bytearray, snapshot: OverworldSnapshot, event: int) -> None:
    """The destroyed-tile check: a castle crushed at load, two cells tall
    for the taller ruins."""
    table = snapshot.destroy_events
    slot = next(
        (found for found in range(len(table) - 1, -1, -1) if table[found] == event),
        None,
    )
    if slot is None or (slot + 1) * 2 > len(snapshot.destroy_locations):
        return
    location = _word(snapshot.destroy_locations, slot * 2)
    if location >= len(l1):
        return
    before = snapshot.destroy_before
    tile = next(
        (
            found
            for found in range(len(before) - 1, -1, -1)
            if before[found] == l1[location]
        ),
        None,
    )
    if tile is None:
        return
    if tile >= DESTROY_TWO_CELL:
        l1[location] = snapshot.destroy_top[tile]
        location += 0x10
        if location >= len(l1):
            return
    l1[location] = snapshot.destroy_bottom[tile]


def _silent(
    l1: bytearray,
    l2: bytearray,
    snapshot: OverworldSnapshot,
    stamps: bytes,
    props: bytes,
    event: int,
) -> None:
    """The offscreen tiles a flagged event places with no animation --
    every matching entry, a Layer 1 write or a Layer 2 stamp each."""
    block = snapshot.silent_tiles
    if len(block) < 6:
        return
    numbers, layers, locations, tile_numbers = silent_sections(block)
    for found in range(len(numbers) - 1, -1, -1):
        if numbers[found] != event:
            continue
        location = _word(locations, found * 2)
        tile = _word(tile_numbers, found * 2)
        if layers[found] & 1:
            for index, offset in _stamp_walk(location, tile):
                _write_stamp(l2, stamps, props, index, offset)
        elif location < len(l1):
            l1[location] = tile & 0xFF


def apply_events(
    tiles: bytes,
    layer2: bytes,
    snapshot: OverworldSnapshot,
    stamps: bytes,
    props: bytes,
    events: Iterable[int],
) -> tuple[bytes, bytes]:
    """Both tilemaps with the given events replayed, in the game's order.

    Returns the **input objects** when nothing changed -- the identity
    contract every diff downstream keys off.
    """
    chosen = [event for event in sorted(set(events)) if 0 <= event < REPLAYED_EVENTS]
    l1 = bytearray(tiles)
    l2 = bytearray(layer2)
    # Pass 2 first: the game runs it when the Layer 2 buffer is built -- at
    # file select -- and pass 1 afterwards, in the overworld load itself. So
    # a silent tile's stamp lands ON TOP of pass 2's where they overlap.
    for event in chosen:
        for _entry, index, offset in _pass2_stamps(
            snapshot.event_entries, snapshot.event_pointers, event
        ):
            _write_stamp(l2, stamps, props, index, offset)
    for event in chosen:
        _substitute(l1, snapshot, event)
        _destroy(l1, snapshot, event)
        _silent(l1, l2, snapshot, stamps, props, event)
    out_tiles = tiles if l1 == tiles else bytes(l1)
    out_layer2 = layer2 if l2 == layer2 else bytes(l2)
    return out_tiles, out_layer2


@lru_cache(maxsize=4)
def placement_tables(placements: StampPlacements) -> tuple[bytes, bytes]:
    """The entry and pointer tables these placements encode to.

    Derived through the region codec rather than by a copy of its arithmetic,
    so the replay, the preview patch and a save cannot disagree about what
    the placements mean in bytes.
    """
    from smw_tools.asm_regions import EventStamps, region_for  # noqa: PLC0415

    region = region_for(STAMP_REGION)
    assert isinstance(region, EventStamps)
    # No room: what these have to fit is asked where a save is priced, and a
    # replay has to draw whatever the document holds either way.
    images = region.encode(placements)
    return images[region.entries_role], images[region.pointers_role]


def decoded_placements(entries: bytes, pointers: bytes) -> StampPlacements | None:
    """The placements a capture's tables describe, or ``None`` for tables the
    codec refuses -- a cart whose event system a hijack rebuilt reads as
    "not carried" rather than as an error, exactly like an absent part.
    """
    from smw_tools.asm_codec import AsmRegionError  # noqa: PLC0415
    from smw_tools.asm_regions import region_for  # noqa: PLC0415

    region = region_for(STAMP_REGION)
    try:
        return region.decode(
            {region.sections[0]: entries, region.sections[1]: pointers}
        )
    except AsmRegionError:
        return None


def event_snapshot(document: WorldMap, snapshot: OverworldSnapshot):
    """``snapshot`` with the document's stamp placements standing in.

    Everything stamp-shaped -- the replay, :func:`stamp_index`, the hit-tests
    behind it -- reads the capture's entry and pointer tables. A document
    that carries placements is ahead of that capture, so its consumers are
    handed a snapshot whose tables are the document's own, and every one of
    them stays a pure function of bytes. The capture's object comes back
    unchanged when the document carries nothing or agrees with it, keeping
    the caches downstream warm.
    """
    changes: dict[str, bytes] = {}
    if document.events:
        entries, pointers = placement_tables(document.events)
        if entries != snapshot.event_entries or pointers != snapshot.event_pointers:
            changes["event_entries"] = entries
            changes["event_pointers"] = pointers
    if document.silent and document.silent != snapshot.silent_tiles:
        changes["silent_tiles"] = document.silent
    if document.subs and document.subs != snapshot.event_l1_locations:
        changes["event_l1_locations"] = document.subs
    if document.swaps:
        before, after = swap_sections(document.swaps)
        if before != snapshot.event_l1_from:
            changes["event_l1_from"] = before
        if after != snapshot.event_l1_to:
            changes["event_l1_to"] = after
    if document.destroy:
        # The two scans read past their tables -- $18 slots over a $10-entry
        # one -- so the capture's windows run on into what follows in ROM: the
        # location words into the event numbers, the event numbers into
        # whatever the bank has next. The document owns the block, so its own
        # bytes stand in for the head of each window and the capture's tail
        # for the ROM past the block's end.
        shape = MapShape.of_parts(destroy=document.destroy)
        before, top, bottom, *_rest = destroy_sections(document.destroy)
        run = document.destroy[shape.destroy_locations_at :]
        for name, own in (
            ("destroy_before", before),
            ("destroy_top", top),
            ("destroy_bottom", bottom),
            ("destroy_locations", run),
            ("destroy_events", run[shape.destroy * 2 :]),
        ):
            captured = getattr(snapshot, name)
            window = own + captured[len(own) :]
            if window != captured:
                changes[name] = window
    if not changes:
        return snapshot
    return replace(snapshot, **changes)


def replayed(
    document: WorldMap, snapshot: OverworldSnapshot, events: Iterable[int]
) -> tuple[bytes, bytes]:
    """The document's map with events replayed: what the events view shows.

    The stamp contents and placements come from the **document** where it
    carries them, so an edited stamp previews everywhere it is used and a
    moved one previews where it moved to; what it does not carry falls back
    to the capture's baselines.
    """
    snapshot = event_snapshot(document, snapshot)
    return apply_events(
        document.tiles,
        document.layer2 or snapshot.layer2,
        snapshot,
        document.stamps or snapshot.event_stamps,
        document.stamp_props or snapshot.event_stamp_props,
        events,
    )


def replayed_steps(
    document: WorldMap, snapshot: OverworldSnapshot, event: int, steps: int
) -> tuple[bytes, bytes]:
    """The document's map mid-animation: ``event`` alone, stopped just after
    its ``steps``-th entry-table stamp lands.

    What the screen shows at that moment of the reveal, in the game's own
    order: the demolition the event writes before any stamp, then the first
    ``steps`` rows in table order. The Layer 1 substitution and the silent
    tiles run *after* the animation, so they are deliberately absent --
    which is why ``steps`` past the event's last row is not the same picture
    as :func:`replayed` with the event whole. Sources follow the document
    exactly as :func:`replayed`'s do.
    """
    snapshot = event_snapshot(document, snapshot)
    stamps = document.stamps or snapshot.event_stamps
    props = document.stamp_props or snapshot.event_stamp_props
    tiles = document.tiles
    layer2 = document.layer2 or snapshot.layer2
    l1 = bytearray(tiles)
    l2 = bytearray(layer2)
    if 0 <= event < REPLAYED_EVENTS:
        _destroy(l1, snapshot, event)
        for _entry, index, offset in _pass2_stamps(
            snapshot.event_entries, snapshot.event_pointers, event, steps
        ):
            _write_stamp(l2, stamps, props, index, offset)
    out_tiles = tiles if l1 == tiles else bytes(l1)
    out_layer2 = layer2 if l2 == layer2 else bytes(l2)
    return out_tiles, out_layer2


def stamp_row_count(events: StampPlacements) -> int:
    """How many entry-table rows these placements encode to -- what a meter
    holds against :data:`STAMP_ROW_BUDGET`."""
    return sum(len(event) for event in events)


def event_touched_tiles(
    document: WorldMap, snapshot: OverworldSnapshot, event: int
) -> tuple[int, ...]:
    """The 8x8 Layer 2 tiles ``event`` changes when it runs alone on the
    document's map -- the focused view's own picture, where every other
    event is left unrun, so nothing of this event's is hidden or set up by
    another's. A changed Layer 1 cell counts as its four tiles, so the one
    answer covers both layers on the grid the stamps land on -- 16x16 cells
    would light a halo of untouched tiles around every unaligned stamp."""
    if not 0 <= event < REPLAYED_EVENTS:
        raise ValueError(f"no event {event:#x} to replay")
    with_it = replayed(document, snapshot, (event,))
    without = replayed(document, snapshot, ())
    tiles = set(changed_layer2(without[1], with_it[1]))
    for cell in changed_cells(without[0], with_it[0]):
        tiles.update(_cell_tiles(cell))
    return tuple(sorted(tiles))


def _cell_tiles(cell: int) -> tuple[int, ...]:
    """A Map16 cell as its four 8x8 Layer 2 tiles -- the stamps' grid."""
    x, y = cell_at(cell)
    submap_area = y >= PAGE_ROWS
    tx, ty = x * 2, (y % PAGE_ROWS) * 2
    return tuple(
        layer2_index(tx + dx, ty + dy, submap_area)
        for dy in range(2)
        for dx in range(2)
    )


def event_highlight_tiles(
    document: WorldMap, snapshot: OverworldSnapshot, event: int
) -> tuple[int, ...]:
    """The 8x8 tiles the focused view lights for ``event``: everything its
    lone replay changes, plus the **whole footprint** of every block it
    stamps -- entry-table rows and silent slots, and a silent Layer 1
    write's cell. A stamp is one thing, so a byte of it that happens to
    equal the base lights with the rest rather than reading as a hole.

    The conditional mechanisms -- pass 1's substitution and the
    destroyed-tile check -- stay diff-only: whether they write at all is
    decided by the map's own tile, and lighting their target while nothing
    fires would claim a cell the event does not change.
    """
    tiles = set(event_touched_tiles(document, snapshot, event))
    shot = event_snapshot(document, snapshot)
    tiles.update(
        index
        for _entry, index, _offset in _pass2_stamps(
            shot.event_entries, shot.event_pointers, event
        )
    )
    numbers, layers, locations, tile_numbers = silent_sections(shot.silent_tiles)
    for slot, number in enumerate(numbers):
        if number == event:
            location = _word(locations, slot * 2)
            if layers[slot] & 1:
                tiles.update(
                    index
                    for index, _offset in _stamp_walk(
                        location, _word(tile_numbers, slot * 2)
                    )
                )
            elif location < TILEMAP_SIZE:
                tiles.update(_cell_tiles(location))
    return tuple(sorted(tiles))


def event_missed_tiles(
    document: WorldMap, snapshot: OverworldSnapshot, event: int
) -> tuple[int, ...]:
    """The conditional targets ``event`` aims at and misses on this map:
    the pass-1 substitution's cell when its tile matches no from-entry, and
    the destroyed-tile check's cell when its tile is no ruin's before-tile.
    The focused view tints these rather than lighting them plainly -- the
    event names the cell, but running it here would change nothing.

    A substitution location of zero is skipped: the table's idle value,
    which the game does scan (cell 0 never matches on the shipped map), but
    tinting cell (0, 0) for every idle event would read as information
    while carrying none -- and a zero-location substitution that *fires*
    is the diff's to report.
    """
    if not 0 <= event < REPLAYED_EVENTS:
        raise ValueError(f"no event {event:#x} to replay")
    shot = event_snapshot(document, snapshot)
    l1 = bytearray(document.tiles)
    missed: set[int] = set()
    locations = shot.event_l1_locations
    if (event + 1) * 2 <= len(locations):
        index = _word(locations, event * 2)
        if 0 < index < len(l1):
            if l1[index] in shot.event_l1_from:
                # Fired -- apply it, so the destroy check below reads the
                # tile the game's own per-event sequence would.
                _substitute(l1, shot, event)
            else:
                missed.update(_cell_tiles(index))
    table = shot.destroy_events
    slot = next(
        (found for found in range(len(table) - 1, -1, -1) if table[found] == event),
        None,
    )
    if slot is not None and (slot + 1) * 2 <= len(shot.destroy_locations):
        location = _word(shot.destroy_locations, slot * 2)
        if location < len(l1) and l1[location] not in shot.destroy_before:
            missed.update(_cell_tiles(location))
    return tuple(sorted(missed))


def _chosen_events(events: Iterable[int] | None) -> tuple[int, ...]:
    """``events`` as a replay-ordered cache key: every replayed event when
    ``None``, else the valid ones ascending -- :func:`apply_events`' order."""
    if events is None:
        return tuple(range(REPLAYED_EVENTS))
    return tuple(event for event in sorted(set(events)) if 0 <= event < REPLAYED_EVENTS)


def stamp_index(
    snapshot: OverworldSnapshot, events: Iterable[int] | None = None
) -> Mapping[int, tuple[int, int, int]]:
    """Every stamped Layer 2 entry, mapped back to the sheet byte behind it.

    ``{layer2 entry index: (event, entry, sheet offset)}``, built in replay
    order so the **last writer wins** -- which is what the player would see,
    and therefore what a click on the events view should select. Only the
    given ``events`` count (every one for ``None``), so a focused view's
    clicks resolve against the events it actually replays. A silent tile's
    stamp has no entry-table row and carries ``entry = -1 - slot`` instead,
    the slot recoverable for :func:`silent_stamp_block`.
    """
    return _stamp_index(
        snapshot.event_entries,
        snapshot.event_pointers,
        snapshot.silent_tiles,
        _chosen_events(events),
    )


@lru_cache(maxsize=4)
def _stamp_index(
    entries: bytes, pointers: bytes, silent: bytes, shown: tuple[int, ...]
) -> dict[int, tuple[int, int, int]]:
    found: dict[int, tuple[int, int, int]] = {}
    # Pass 2 first and silent tiles after, matching :func:`apply_events`'
    # replay order, so an overlap resolves to the byte the player would see.
    for event in shown:
        for entry, index, offset in _pass2_stamps(entries, pointers, event):
            found[index] = (event, entry, offset)
    if len(silent) >= 6:
        numbers, layers, locations, tile_numbers = silent_sections(silent)
        for event in shown:
            for slot in range(len(numbers) - 1, -1, -1):
                if numbers[slot] != event or not layers[slot] & 1:
                    continue
                for index, offset in _stamp_walk(
                    _word(locations, slot * 2), _word(tile_numbers, slot * 2)
                ):
                    found[index] = (event, -1 - slot, offset)
    return found


def silent_stamp_block(silent: bytes, slot: int) -> tuple[int, int]:
    """A silent Layer 2 slot's block: ``(sheet source, side)`` -- the whole
    block a click on any of its tiles should select, since the slot has no
    entry-table row to stand for it."""
    if not 0 <= slot < len(silent) // 6:
        raise ValueError(f"no silent-tile slot {slot}")
    source = _word(silent, (len(silent) // 6) * 4 + slot * 2)
    return source, (2 if source >= SHEET_6X6_SIZE else 6)


def stamp_uses(
    snapshot: OverworldSnapshot, events: Iterable[int] | None = None
) -> Mapping[int, tuple[int, ...]]:
    """Every used sheet byte, mapped to the Layer 2 entries it shows at.

    The inverse of :func:`stamp_index`, over its last-writer answers within
    the same ``events`` set: an entry appears under the sheet offset the
    player would actually see there, so editing that byte repaints exactly
    these places. Cached on the same inputs as the index -- the hover status
    line and the selection ants ask on every cursor move.
    """
    return _stamp_uses(
        snapshot.event_entries,
        snapshot.event_pointers,
        snapshot.silent_tiles,
        _chosen_events(events),
    )


@lru_cache(maxsize=4)
def _stamp_uses(
    entries: bytes, pointers: bytes, silent: bytes, shown: tuple[int, ...]
) -> dict[int, tuple[int, ...]]:
    uses: dict[int, list[int]] = {}
    for destination, (_event, _entry, offset) in _stamp_index(
        entries, pointers, silent, shown
    ).items():
        uses.setdefault(offset, []).append(destination)
    return {offset: tuple(sorted(found)) for offset, found in uses.items()}


# -- what the properties panel says about a cell ------------------------------

#: How the game spells a two-bit walk direction, in its own encoding order.
WALK_DIRECTIONS = ("up", "down", "left", "right")

#: Where each exit's walk code sits in the ``nn112233`` byte. The last two
#: fields are unused in the shipped game, and nothing shows or writes them.
WALK_REGULAR_SHIFT = 6
WALK_SECRET_SHIFT = 4

#: Which way each walk code points, as a cell step, in the same order.
WALK_VECTORS = ((0, -1), (0, 1), (-1, 0), (1, 0))

#: The "no event" entry in the level-events table.
NO_EVENT = 0xFF


def cell_properties(
    document: WorldMap, snapshot: OverworldSnapshot, index: int
) -> tuple[str, list[tuple[str, str]]]:
    """One cell described as read-only ``(heading, rows)`` --
    the shape :meth:`~shiny_mushroom.ui.properties.PropertiesDock.show_properties`
    takes.

    **Every row survives an edit truthfully.** Position and tile come from the
    document; the translevel and level number are recomputed by the scan over
    the document as it stands; and the walk and event rows index fixed ROM
    tables *by that recomputed translevel* -- which is exactly the lookup the
    game will do with the map as edited. Nothing here reads a position-indexed
    WRAM table that an edit would silently stale.

    The per-translevel *save state* (beaten, midway, events fired) is
    deliberately absent: the capture never loads a save file, so those tables
    are all-clear by construction and a row of constant zeros would read as
    information while carrying none.
    """
    x, y = cell_at(index)
    submap_area = y >= PAGE_ROWS
    tile = document.tile(index)
    # The transfers are position-keyed, so the destination is the cell's
    # even where the tile was moved off it -- and a trigger tile parked on
    # an unlinked cell is honestly a trigger with nowhere to go.
    function = tile_function(tile).value
    warp = warp_entry_at(document.warps, index)
    if warp is not None:
        function += f", warps to {warp_landing_place(document.warps, warp)}"
    elif tile == STAR_TILE or tile in PIPE_TILES:
        function += ", no warp destination at this cell"
    exit_entry = exit_entry_at(document.exits, index)
    if exit_entry is not None:
        function += f", exits to {exit_landing_place(document.exits, exit_entry)}"
    elif tile in MAP_EXIT_TILES:
        function += ", exits the map -- no destination at this cell"
    rows = [
        ("Area", "Submaps" if submap_area else "Main map"),
        ("Tile", hexnum(tile)),
        ("Function", function),
    ]
    translevel = document.translevels[index]
    if translevel:
        level = document.level_of(translevel, submap_area)
        rows.append(("Level", hexnum(level, 3) if level is not None else "none"))
        rows.append(("Translevel", hexnum(translevel)))
        walk_table = document.directions or snapshot.level_directions
        rows.append(("Clear walk", walk_summary(walk_table, translevel)))
        events_table = document.level_events or snapshot.level_events
        rows.append(("Event", event_summary(events_table, translevel)))
    elif is_level_tile(tile):
        # Every level tile is numbered by the scan, so an unnumbered one means
        # the document and the derivation disagree -- say so rather than hide.
        rows.append(("Level", "unnumbered"))
    return f"World map cell {hexspot(x, y)}", rows


def walk_summary(directions: bytes, translevel: int) -> str:
    """The ``nn112233`` walk byte in words: the regular exit's two bits, then
    the secret exit's -- one row, as a read-only readout shows it. The
    per-exit editors read the same two fields through
    :data:`WALK_REGULAR_SHIFT` and :data:`WALK_SECRET_SHIFT`."""
    if translevel >= len(directions):
        return "unknown"
    value = directions[translevel]
    regular = WALK_DIRECTIONS[(value >> WALK_REGULAR_SHIFT) & 3]
    secret = WALK_DIRECTIONS[(value >> WALK_SECRET_SHIFT) & 3]
    return f"{regular} (secret exit: {secret})"


def event_conflicts(events: bytes, translevel: int, last: int) -> list[str]:
    """Where this level's event numbering collides with another level's.

    A secret exit fires ``N + 1`` with no table of its own, so a two-exit
    level consumes two consecutive numbers -- and nothing in the game
    cross-checks the table for overlaps. ``last`` is the highest translevel
    the scan hands out, so unreachable padding rows accuse nobody.
    """
    if not 0 <= translevel < len(events):
        return []
    value = events[translevel]
    if value == NO_EVENT:
        return []
    found = []
    for other in range(1, min(last + 1, len(events))):
        if other == translevel:
            continue
        held = events[other]
        if held == NO_EVENT:
            continue
        if held == value:
            found.append(f"event {hexnum(value)} is also translevel {hexnum(other)}'s")
        if held == value + 1:
            found.append(
                f"the secret exit's {hexnum(value + 1)} is "
                f"translevel {hexnum(other)}'s own event"
            )
        if held + 1 == value:
            found.append(
                f"event {hexnum(value)} is also "
                f"translevel {hexnum(other)}'s secret-exit event"
            )
    return found


def event_summary(events: bytes, translevel: int) -> str:
    """Which event this level's clear fires. A secret exit fires the next
    event up, with no table of its own.

    Spelled once, here, because the read-only readout and the editable
    field's quoting row both say it and a level that reads two different
    events off one table is worse than either answer.
    """
    if translevel >= len(events):
        return "unknown"
    value = events[translevel]
    if value == NO_EVENT:
        return "none"
    return f"{hexnum(value)} (secret exit: {hexnum(value + 1)})"


def world_checks(
    document: WorldMap,
    snapshot: OverworldSnapshot,
    shape: MapShape = STOCK_SHAPE,
) -> list[str]:
    """Every cross-check the game itself never makes, over the map as edited.

    ``shape`` is the cartridge's own table extents -- see :class:`MapShape` --
    which is what the level-count caps are judged against: a cap holds over a
    part the document does not carry.

    Empty means clean. Facts rather than fixes, one line each: a level count
    past what the save block or the names table can hold, a clear that
    walks onto nothing walkable, an event number past the replay's last, a
    numbering collision (:func:`event_conflicts`), an event that changes
    nothing on the map, and an event that changes the map with no level to
    fire it. Walkability is judged over the **replayed** tilemap -- a tile
    an event reveals counts, exactly as the player finds it.
    """
    said: list[str] = []
    translevels = document.translevels
    events_table = document.level_events or snapshot.level_events
    directions = document.directions or snapshot.level_directions
    last = max(translevels)
    # The level count is capped by RAM, not by any ROM table: the save
    # block is $60 bytes with the event flags directly behind it, and the
    # names table stops three rows earlier still.
    save_cap = LEVEL_TILE_SETTINGS_SIZE - 1
    if last > save_cap:
        over = last - save_cap
        said.append(
            f"the map numbers {last} levels -- the {over} past translevel "
            f"{hexnum(save_cap)} write their save bytes into the event flags"
        )
    # The names table's extent is the **cartridge's**, not the document's: the
    # cap holds whether or not this document carries the part -- the Japanese
    # target's names are its own routine's and never reach the document at all,
    # and the name box still reads past the table there.
    names_cap = shape.level_names - 1
    if last > names_cap:
        over = last - names_cap
        said.append(
            f"{over} level{'' if over == 1 else 's'} past translevel "
            f"{hexnum(names_cap)} -- the name box reads past the level-names table"
        )
    shown, _ = replayed(document, snapshot, range(REPLAYED_EVENTS))
    fired: set[int] = set()
    for held in range(1, min(last + 1, len(events_table))):
        value = events_table[held]
        if value != NO_EVENT:
            fired.add(value)
            fired.add(value + 1)
    for index, translevel in enumerate(translevels):
        if not translevel:
            continue
        x, y = cell_at(index)
        level = document.level_of(translevel, y >= PAGE_ROWS)
        who = (
            f"level {hexnum(level, 3)} at {hexspot(x, y)}"
            if level is not None
            else f"the level at {hexspot(x, y)}"
        )
        if translevel < len(directions):
            byte = directions[translevel]
            walks = [("clear", (byte >> 6) & 3)]
            if (byte >> 4) & 3 != walks[0][1]:
                walks.append(("secret exit", (byte >> 4) & 3))
            for which, code in walks:
                dx, dy = WALK_VECTORS[code]
                nx, ny = x + dx, y + dy
                stood = (
                    shown[cell_index(nx, ny)]
                    if 0 <= nx < COLUMNS and 0 <= ny < ROWS
                    else None
                )
                if stood is None or tile_function(stood) is TileFunction.NONE:
                    said.append(
                        f"{who}: the {which} walks "
                        f"{WALK_DIRECTIONS[code]} onto nothing walkable"
                    )
        if translevel >= len(events_table):
            continue
        value = events_table[translevel]
        if value == NO_EVENT:
            continue
        if value >= REPLAYED_EVENTS:
            said.append(
                f"{who}: fires event {hexnum(value)}, past the last replayed event $6E"
            )
            continue
        if value == REPLAYED_EVENTS - 1:
            said.append(
                f"{who}: the secret exit's event $6F is past the last replayed event"
            )
        for conflict in event_conflicts(events_table, translevel, last):
            said.append(f"{who}: {conflict}")
        if not event_touched_tiles(document, snapshot, value):
            said.append(f"{who}: event {hexnum(value)} changes nothing on the map")
    for event in range(REPLAYED_EVENTS):
        if event not in fired and event_touched_tiles(document, snapshot, event):
            said.append(f"event {hexnum(event)} changes the map, and no level fires it")
    return said


# -- test runs ---------------------------------------------------------------

#: The save-state tables' sizes: one ``bmesudlr`` byte per translevel, and the
#: bit-packed event flags. The same facts as the capture's
#: ``OW_LEVEL_TILE_SETTINGS_SIZE``/``OW_EVENT_FLAGS_SIZE``, restated on this
#: side of the seam.
LEVEL_TILE_SETTINGS_SIZE = 0x60
EVENT_FLAG_BYTES = 0x0E


@dataclass(frozen=True)
class WorldSpawn:
    """Where a test run puts the player, in the game's own terms: a submap,
    and a map-pixel position on the page that submap views."""

    submap: int
    x: int
    y: int


#: A new game's spawn, from the cartridge's ``InitialOWPlayerPos``: standing
#: before Yoshi's House on the Yoshi's Island submap.
DEFAULT_SPAWN = WorldSpawn(1, 0x68, 0x78)


def submap_at(x: int, y: int) -> int:
    """Which submap shows the shared-page pixel ``(x, y)``.

    The nearest camera by viewport center, because the seven viewports
    overlap -- containment alone would answer two submaps for a pixel in the
    overlap, and the nearer camera is the one a player would call that spot's
    map.
    """
    best, nearest = 1, None
    for submap in range(1, len(SUBMAP_CAMERAS)):
        camera_x, camera_y = SUBMAP_CAMERAS[submap]
        distance = abs(x - camera_x - 128) + abs(y - camera_y - 112)
        if nearest is None or distance < nearest:
            best, nearest = submap, distance
    return best


def spawn_for_cell(x: int, y: int) -> WorldSpawn:
    """The spawn standing on the cell at ``(x, y)``: the node's center pixel,
    with the submap decided by which half of the picture the cell is on."""
    pixel_x = x * 16 + 8
    pixel_y = (y % PAGE_ROWS) * 16 + 8
    submap = 0 if y < PAGE_ROWS else submap_at(pixel_x, pixel_y)
    return WorldSpawn(submap, pixel_x, pixel_y)


def spawn_cell(spawn: WorldSpawn) -> tuple[int, int]:
    """The picture cell a spawn stands on -- :func:`spawn_for_cell` read
    backwards, with every submap landing on the shared lower page."""
    return spawn.x // 16, spawn.y // 16 + (PAGE_ROWS if spawn.submap else 0)


def save_tables(
    tiles: bytes,
    level_events: bytes,
    level_directions: bytes,
    initial_flags: Iterable[tuple[int, int]],
    completed: Mapping[int, bool],
) -> tuple[bytes, bytes]:
    """The save-state tables a test run starts from.

    A new game's baseline -- zeros plus the cartridge's initial walkability
    pairs -- with each of ``completed``'s levels beaten on top: the beaten
    bit, the walk its clear reveals, and its event flagged as already run.

    ``completed`` maps a **cell index** to whether the secret exit is beaten
    too. Cells rather than translevels, because an edit renumbers translevels
    while a cell keeps naming the same node; a mark whose cell no longer
    holds a level tile is silently skipped. A secret mark beats both exits:
    both walks revealed, both events flagged -- a secret exit fires the next
    event up.
    """
    settings = bytearray(LEVEL_TILE_SETTINGS_SIZE)
    flags = bytearray(EVENT_FLAG_BYTES)
    for translevel, walkable in initial_flags:
        if translevel < LEVEL_TILE_SETTINGS_SIZE:
            settings[translevel] |= walkable
    translevels = scan_translevels(bytes(tiles))
    for cell, secret in completed.items():
        translevel = translevels[cell] if 0 <= cell < TILEMAP_SIZE else 0
        if not translevel or translevel >= LEVEL_TILE_SETTINGS_SIZE:
            continue
        settings[translevel] |= 0x80
        for secret_exit in (False, True) if secret else (False,):
            if translevel < len(level_directions):
                shift = 4 if secret_exit else 6
                walk = (level_directions[translevel] >> shift) & 3
                settings[translevel] |= 1 << (3 - walk)
            event = (
                level_events[translevel] if translevel < len(level_events) else NO_EVENT
            )
            if event == NO_EVENT:
                continue
            fired = event + 1 if secret_exit else event
            if fired >> 3 < EVENT_FLAG_BYTES:
                flags[fired >> 3] |= 0x80 >> (fired & 7)
    return bytes(settings), bytes(flags)
