"""The world map a project saves, and the files it is spread across.

One of :class:`~shiny_mushroom.project.Project`'s subjects, in a module of
its own -- the Layer 1 and Layer 2 tilemaps, the event stamp sheets, the
sprite slots, and the dozen asm regions the rest of the map lives in. The
paths, the sizes and the region ids are here beside the methods that read
and write them, and :data:`OVERWORLD_PARTS` is the one list that says which
region each part of the document is, so nothing can name two.

**A mixin rather than a view**, for the reason
:mod:`shiny_mushroom.project_graphics` gives: every caller still asks the
project, and ``self`` is that project.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

from shiny_mushroom.overworld import (
    DESTROY_REGION,
    DESTROY_TILES,
    EXIT_REGION,
    LEVEL_NAMES_REGION,
    SILENT_REGION,
    STAMP_REGION,
    SUBS_REGION,
    SWAPS_REGION,
    TRANSLEVEL_LEVELS_COUNT,
    TRANSLEVEL_LEVELS_REGION,
    WARP_REGION,
    MapShape,
    destroy_from_model,
    destroy_region_model,
    exit_region_model,
    exits_from_model,
    level_names_from_model,
    level_names_region_model,
    silent_from_model,
    silent_region_model,
    subs_from_model,
    subs_region_model,
    swaps_from_model,
    swaps_region_model,
    table_allows,
    translevel_levels_from_model,
    translevel_levels_region_model,
    warp_region_model,
    warps_from_model,
)
from shiny_mushroom.project_files import RAW_NAME, ProjectError, _now, _remembered
from smw_tools import asm_regions, asm_room, packed

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence


#: The asm regions a world-map save writes -- the walk-directions and
#: level-events tables, the Layer 2 event placements, the star/pipe warp and
#: path-exit tables, the destroyed- and silent-tile blocks, and which maps show
#: each sprite number, by their `smw_tools.asm_regions` ids. The six with
#: codecs in :mod:`shiny_mushroom.overworld` are that module's constants, so an
#: id and its codec cannot name different regions.
OVERWORLD_WALK_REGION = "overworld.walk_directions"
OVERWORLD_EVENTS_REGION = "overworld.level_events"
OVERWORLD_NAMES_REGION = LEVEL_NAMES_REGION
OVERWORLD_STAMP_REGION = STAMP_REGION
OVERWORLD_SILENT_REGION = SILENT_REGION
OVERWORLD_DESTROY_REGION = DESTROY_REGION
OVERWORLD_SUBS_REGION = SUBS_REGION
OVERWORLD_SWAPS_REGION = SWAPS_REGION
OVERWORLD_WARP_REGION = WARP_REGION
OVERWORLD_EXIT_REGION = EXIT_REGION
OVERWORLD_SPRITE_MAPS_REGION = "overworld.sprite_submaps"
OVERWORLD_TRANSLEVELS_REGION = TRANSLEVEL_LEVELS_REGION


def _rows_model(part) -> tuple[tuple[int, ...]]:
    """A flat byte table as its region's model: one row, of bytes."""
    return (tuple(part),)


def _rows_bytes(model) -> bytes:
    """A one-row model back as the flat byte table the editor holds."""
    (rows,) = model
    return bytes(rows)


def _as_held(part):
    """A part whose editable form *is* its region's model."""
    return part


@dataclass(frozen=True)
class OverworldPart:
    """One overworld table the editor keeps as an editable asm region.

    Four facts and nothing else: what a save calls the part, which region of
    the disassembly it is written into, and the pair of functions that turn the
    editor's form into that region's model and back again.

    Three loops read this -- a world-map save, the overlay listing beside it,
    and :func:`shiny_mushroom.cart_patches.world_parts_from_project` -- and
    another table added to any one of them without the others is a part that
    saves and never previews, or previews and never reverts.
    """

    #: The keyword :meth:`Project.save_world_map` takes the part as, and the
    #: field :class:`~shiny_mushroom.cart_patches.WorldParts` holds it in.
    name: str

    #: Its `smw_tools.asm_regions` id.
    region: str

    #: The editable form as the region's model, for saving.
    to_model: Callable[[object], object]

    #: The region's model back as the editable form, for reading one back.
    from_model: Callable[[object], object]


#: Every overworld part that is an asm region, in the order a save writes them.
OVERWORLD_PARTS: tuple[OverworldPart, ...] = (
    OverworldPart("directions", OVERWORLD_WALK_REGION, _rows_model, _rows_bytes),
    OverworldPart("level_events", OVERWORLD_EVENTS_REGION, _rows_model, _rows_bytes),
    OverworldPart(
        "level_names",
        OVERWORLD_NAMES_REGION,
        level_names_region_model,
        level_names_from_model,
    ),
    OverworldPart(
        "translevel_levels",
        OVERWORLD_TRANSLEVELS_REGION,
        translevel_levels_region_model,
        translevel_levels_from_model,
    ),
    OverworldPart("events", OVERWORLD_STAMP_REGION, _as_held, _as_held),
    OverworldPart(
        "silent", OVERWORLD_SILENT_REGION, silent_region_model, silent_from_model
    ),
    OverworldPart(
        "destroy", OVERWORLD_DESTROY_REGION, destroy_region_model, destroy_from_model
    ),
    OverworldPart("subs", OVERWORLD_SUBS_REGION, subs_region_model, subs_from_model),
    OverworldPart(
        "swaps", OVERWORLD_SWAPS_REGION, swaps_region_model, swaps_from_model
    ),
    OverworldPart("warps", OVERWORLD_WARP_REGION, warp_region_model, warps_from_model),
    OverworldPart("exits", OVERWORLD_EXIT_REGION, exit_region_model, exits_from_model),
    OverworldPart(
        "sprite_disable", OVERWORLD_SPRITE_MAPS_REGION, _rows_model, _rows_bytes
    ),
)


def world_region_models(document) -> dict[str, object]:  # noqa: ANN001 - a WorldMap
    """Every overworld table ``document`` carries as its region's model, by
    region id -- the parts a save writes and a room check prices, read
    through :data:`OVERWORLD_PARTS` so the two cannot name different
    regions. A part the document does not carry is left out: the sprite
    disable table alone is defaulted rather than carried, so it is always
    there."""
    models: dict[str, object] = {}
    for part in OVERWORLD_PARTS:
        held = getattr(document, part.name)
        if part.name == "sprite_disable":
            models[part.region] = part.to_model(bytes(held))
        elif held:
            models[part.region] = part.to_model(held)
    return models


#: The overworld's Layer 1 tilemap and its Map16 definition table, relative to
#: the game tree. Plain fixed-size ``incbin``\ s, so their overlay story is the
#: simple one: a same-size copy at the same relative path, which the build's
#: merge picks up with no compilation step. The sizes *are* the whole room
#: check -- a fixed-size ``incbin`` cannot grow.
OVERWORLD_LAYER1 = Path("overworld/layer1/levels.bin")
OVERWORLD_DEFINITIONS = Path("overworld/layer1/tiles.bin")
OVERWORLD_LAYER1_SIZE = 0x800

#: The overworld's Layer 2 streams, as the keys :meth:`Project.save_raw`
#: speaks -- the compressed-resource registry's spelling, under the game
#: tree's overlay name. The document's interleaved ``$4000`` buffer
#: de-interleaves into these two ``$2000`` raw streams.
OVERWORLD_LAYER2_TILES_KEY = Path("SMW/overworld/layer2/tiles.bin")
OVERWORLD_LAYER2_PROPS_KEY = Path("SMW/overworld/layer2/properties.bin")

#: The event stamp sheets -- plain fixed-size ``incbin``\ s like the Layer 1
#: pair -- and the compressed properties stream that pairs one byte with every
#: sheet byte. The document keeps the sheets concatenated (``$900`` of 6x6
#: blocks, then ``$400`` of 2x2); the tree keeps them as two files.
OVERWORLD_EVENT_6X6 = Path("overworld/layer2/events/6x6Tiles.bin")
OVERWORLD_EVENT_2X2 = Path("overworld/layer2/events/2x2Tiles.bin")
OVERWORLD_EVENT_6X6_SIZE = 0x900
OVERWORLD_EVENT_2X2_SIZE = 0x400
OVERWORLD_EVENT_PROPS_KEY = Path("SMW/overworld/layer2/events/properties.bin")

#: The sprite slot table -- a plain fixed-size ``incbin`` like the Layer 1
#: pair. 13 slots of (number, X, Y).
OVERWORLD_SPRITES = Path("overworld/sprites/slots.bin")
OVERWORLD_SPRITES_SIZE = 65
#: 8 bytes for each of the overworld's :data:`shiny_mushroom.overworld.TILE_COUNT`
#: Map16 tiles. A literal rather than the import, to keep the emulator package
#: out of this module's import graph for one number.
OVERWORLD_DEFINITIONS_SIZE = 0xC1 * 8


class WorldMapFiles:
    """A project's world map: what it reads for one, and what a save of one
    writes.

    Mixed into :class:`~shiny_mushroom.project.Project`, whose overlay,
    plain-``incbin`` primitives and asm-region group every method here goes
    through -- ``self`` is that project.
    """

    def overworld_tiles(self) -> bytes:
        """The overworld's Layer 1 tilemap the build would read."""
        return self._plain(OVERWORLD_LAYER1, OVERWORLD_LAYER1_SIZE)

    def overworld_definitions(self) -> bytes:
        """The overworld's Map16 definition table, 8 bytes per tile.

        Nothing edits it, so the read-through is formality -- but the
        formality is what keeps this true the day something does.
        """
        return self._plain(OVERWORLD_DEFINITIONS, OVERWORLD_DEFINITIONS_SIZE)

    def overworld_layer2(self) -> bytes:
        """The overworld's Layer 2 tilemap the build would read, interleaved
        the way the console keeps it: even byte the tile number, odd the
        attributes -- the shape the document and the renderer speak."""
        tiles = self.raw(OVERWORLD_LAYER2_TILES_KEY)
        properties = self.raw(OVERWORLD_LAYER2_PROPS_KEY)
        buffer = bytearray(len(tiles) + len(properties))
        buffer[0::2] = tiles
        buffer[1::2] = properties
        return bytes(buffer)

    def overworld_stamps(self) -> bytes:
        """The two event stamp sheets the build would read, concatenated the
        way the console keeps them -- ``$900`` of 6x6 blocks then ``$400`` of
        2x2, which is the shape the document and the replay speak."""
        return self._plain(OVERWORLD_EVENT_6X6, OVERWORLD_EVENT_6X6_SIZE) + self._plain(
            OVERWORLD_EVENT_2X2, OVERWORLD_EVENT_2X2_SIZE
        )

    def overworld_stamp_props(self) -> bytes:
        """The stamp sheets' properties in their editable form: one
        ``YXPCCCTT`` byte at every sheet offset."""
        return self.raw(OVERWORLD_EVENT_PROPS_KEY)

    def overworld_sprites(self) -> bytes:
        """The overworld's sprite slot table the build would read."""
        return self._plain(OVERWORLD_SPRITES, OVERWORLD_SPRITES_SIZE)

    def save_overworld(self, tiles: bytes) -> Path:
        """Write the overworld's Layer 1 tilemap alone -- the phase-one save,
        kept as a name for :meth:`save_world_map`'s simplest call."""
        written = self.save_world_map(tiles=tiles)
        return written[0] if written else self.overlaid(self.base / OVERWORLD_LAYER1)

    def save_world_map(
        self,
        *,
        tiles: bytes,
        layer2: bytes | None = None,
        stamps: bytes | None = None,
        stamp_props: bytes | None = None,
        sprites: bytes | None = None,
        directions: bytes | None = None,
        level_events: bytes | None = None,
        level_names: bytes | None = None,
        translevel_levels: bytes | None = None,
        events: tuple | None = None,
        silent: bytes | None = None,
        destroy: bytes | None = None,
        subs: bytes | None = None,
        swaps: bytes | None = None,
        warps: bytes | None = None,
        exits: bytes | None = None,
        sprite_disable: Sequence[int] | None = None,
        asm_runs: dict[str, asm_room.Run] | None = None,
    ) -> list[Path]:
        """Write the world map into the overlay: every part given, or nothing.

        Sizes are validated before anything is written. The compressed parts
        go first, under one joint rollback (:meth:`_save_raws`) -- they are
        the only parts that can be refused, and a
        :class:`~smw_tools.packed.RegionFull` must leave the overlay exactly
        as it was, plain parts included, which writing the infallible parts
        last guarantees without unwinding them.

        The asm-region parts are the ones :data:`OVERWORLD_PARTS` names,
        one keyword each. The ones that differ from the disassembly's own
        rows are priced against ``asm_runs`` (from
        :func:`shiny_mushroom.build.asm_runs`) **before any file moves**,
        so an :class:`~smw_tools.asm_codec.AsmRegionFull` keeps the
        every-part-or-nothing promise -- and only those need a run at
        all, so a map whose tables are stock saves without a build. They are
        priced by :meth:`_emit_asm_regions` and written last by
        :meth:`_write_asm_regions`, whose identity rule keeps an untouched
        table out of the overlay.

        A part byte-equal to what the build already reads is skipped, so an
        untouched part never appears in :meth:`raw_edits` or turns
        :attr:`overworld_edited` on.
        """
        if len(tiles) != OVERWORLD_LAYER1_SIZE:
            raise ProjectError(
                f"an overworld tilemap is {OVERWORLD_LAYER1_SIZE:#x} bytes, "
                f"not {len(tiles):#x}"
            )
        if layer2 is not None and len(layer2) != 2 * packed.OVERWORLD_LAYER2_SIZE:
            raise ProjectError(
                f"a Layer 2 tilemap is {2 * packed.OVERWORLD_LAYER2_SIZE:#x} "
                f"bytes, not {len(layer2):#x}"
            )
        sheets = OVERWORLD_EVENT_6X6_SIZE + OVERWORLD_EVENT_2X2_SIZE
        if stamps is not None and len(stamps) != sheets:
            raise ProjectError(
                f"the event stamp sheets are {sheets:#x} bytes, not {len(stamps):#x}"
            )
        if stamp_props is not None and len(stamp_props) != sheets:
            raise ProjectError(
                f"the event stamp properties are {sheets:#x} bytes, "
                f"not {len(stamp_props):#x}"
            )
        if sprites is not None and len(sprites) != OVERWORLD_SPRITES_SIZE:
            raise ProjectError(
                f"the sprite table is {OVERWORLD_SPRITES_SIZE} bytes, "
                f"not {len(sprites)}"
            )
        # Every variable-length table against this **cartridge's** shape, not
        # the stock format: a project whose feature grew one holds more rows
        # than the game ships with, and a part that is not its length would be
        # emitted as a fragment the game reads past the end of. The tables
        # whose scan follows their rows are held to what the scan can reach
        # instead -- growing one is the point of them.
        shape = MapShape.of(self.cartridge_base)
        fixed = [
            ("walk-directions table", directions, shape.directions, 1),
            ("level-events table", level_events, shape.level_events, 1),
            ("level-names table", level_names, shape.level_names, 2),
            ("translevel-levels table", translevel_levels, TRANSLEVEL_LEVELS_COUNT, 2),
            ("substitution locations", subs, shape.subs, 2),
        ]
        grown = [
            ("silent-tiles block", silent, 6, 0, OVERWORLD_SILENT_REGION),
            ("substitution pairs", swaps, 2, 0, OVERWORLD_SWAPS_REGION),
            ("warp tables", warps, 8, 0, OVERWORLD_WARP_REGION),
            ("exit tables", exits, 12, 0, OVERWORLD_EXIT_REGION),
        ]
        # The destroyed-tiles block grows only where this cartridge's scan
        # follows its rows; a stock scan reads a literal count past the table.
        if OVERWORLD_DESTROY_REGION in shape.grows:
            grown.append(
                (
                    "destroyed-tiles block",
                    destroy,
                    3,
                    DESTROY_TILES * 3,
                    OVERWORLD_DESTROY_REGION,
                )
            )
        else:
            fixed.append(
                ("destroyed-tiles block", destroy, DESTROY_TILES + shape.destroy, 3)
            )
        for name, part, entries, stride in fixed:
            if part is not None and len(part) != entries * stride:
                raise ProjectError(
                    f"the {name} is {entries * stride:#x} bytes on this "
                    f"cartridge, not {len(part):#x}"
                )
        for name, part, stride, head, region_id in grown:
            if part is not None and (
                len(part) < head
                or (len(part) - head) % stride
                or not table_allows(region_id, (len(part) - head) // stride)
            ):
                raise ProjectError(
                    f"the {name} holds {(len(part) - head) / stride:g} entries, "
                    f"which its scan cannot reach"
                )

        # The asm parts that differ from the disassembly's rows are priced
        # now -- emit is pure, so a save that will not fit raises here,
        # before anything below has written a byte.
        given = {
            "directions": directions,
            "level_events": level_events,
            "level_names": level_names,
            "translevel_levels": translevel_levels,
            "events": events,
            "silent": silent,
            "destroy": destroy,
            "subs": subs,
            "swaps": swaps,
            "warps": warps,
            "exits": exits,
            "sprite_disable": sprite_disable,
        }
        models: dict[str, object] = {
            part.region: part.to_model(given[part.name])
            for part in OVERWORLD_PARTS
            if given[part.name] is not None
            # A base without the fragment cannot carry the edit -- the part is
            # dropped rather than failing every other part.
            and self.asm_region_stock(part.region) is not None
        }
        emitted = self._emit_asm_regions(models, asm_runs or {})

        raws: list[tuple[Path, bytes]] = []
        if layer2 is not None:
            even, odd = bytes(layer2[0::2]), bytes(layer2[1::2])
            if even != self.raw(OVERWORLD_LAYER2_TILES_KEY):
                raws.append((OVERWORLD_LAYER2_TILES_KEY, even))
            if odd != self.raw(OVERWORLD_LAYER2_PROPS_KEY):
                raws.append((OVERWORLD_LAYER2_PROPS_KEY, odd))
        if stamp_props is not None and stamp_props != self.raw(
            OVERWORLD_EVENT_PROPS_KEY
        ):
            raws.append((OVERWORLD_EVENT_PROPS_KEY, stamp_props))

        plains: list[tuple[Path, bytes, int]] = [
            (OVERWORLD_LAYER1, tiles, OVERWORLD_LAYER1_SIZE)
        ]
        if stamps is not None:
            plains.append(
                (
                    OVERWORLD_EVENT_6X6,
                    stamps[:OVERWORLD_EVENT_6X6_SIZE],
                    OVERWORLD_EVENT_6X6_SIZE,
                )
            )
            plains.append(
                (
                    OVERWORLD_EVENT_2X2,
                    stamps[OVERWORLD_EVENT_6X6_SIZE:],
                    OVERWORLD_EVENT_2X2_SIZE,
                )
            )
        if sprites is not None:
            plains.append((OVERWORLD_SPRITES, sprites, OVERWORLD_SPRITES_SIZE))

        # The plain comparisons happen *before* any write: `_plain` can raise
        # -- an off-size or missing file under a damaged overlay -- and a
        # raise after `_save_raws` would leave the raw group written with
        # nothing to roll it back, against the every-part-or-nothing promise.
        # Past this line the only fallible step is `_save_raws`, which
        # unwinds itself.
        changed_plains = [
            (relative, data, size)
            for relative, data, size in plains
            if data != self._plain(relative, size)
        ]
        written: list[Path] = []
        if raws:
            written += self._save_raws(raws)
        for relative, data, size in changed_plains:
            written.append(self._save_plain(relative, data, size))
        written += self._write_asm_regions(emitted)
        if written:
            self._write_metadata({"modified": _now()})
        return written

    def revert_world_map(self) -> list[Path]:
        """Take every world map edit back out of the overlay. Deleting the
        files is the revert, exactly as it is for a level."""
        gone = []
        for held in self._world_map_overlays():
            if held.is_file():
                held.unlink()
                gone.append(held)
        if gone:
            self._write_metadata({"modified": _now()})
        return gone

    @property
    @_remembered
    def overworld_edited(self) -> bool:
        """Whether this project has saved any part of the world map -- a `stat`
        per part, so remembered (:func:`_remembered`)."""
        return any(held.is_file() for held in self._world_map_overlays())

    def _world_map_overlays(self) -> list[Path]:
        """Every overlay file a world map save can produce."""
        return [
            self.overlaid(self.base / OVERWORLD_LAYER1),
            self.overlaid(self.base / OVERWORLD_EVENT_6X6),
            self.overlaid(self.base / OVERWORLD_EVENT_2X2),
            self.overlaid(self.base / OVERWORLD_SPRITES),
            *(
                # The declared lookup: the listing is about overlay files,
                # and a feature's own fragment is a file whatever cartridge
                # is in hand.
                self.overlaid(self.base / asm_regions.declared_region(part.region).path)
                for part in OVERWORLD_PARTS
            ),
            self.overlay / RAW_NAME / OVERWORLD_LAYER2_TILES_KEY,
            self.overlay / RAW_NAME / OVERWORLD_LAYER2_PROPS_KEY,
            self.overlay / RAW_NAME / OVERWORLD_EVENT_PROPS_KEY,
        ]
