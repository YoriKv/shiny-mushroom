"""Field descriptors for the world map's editable records.

The properties panel renders whatever :class:`~shiny_mushroom.fields.Field`
list it is handed; these are the world map's, kept Qt-free beside the model
the way ``objects.py`` and ``sprites.py`` keep the level's. A record here is a
tiny frozen view -- the document plus the selected keys -- and ``applied``
answers with a record holding the **edited document**, which is what the mode
commits.

A multi-selection edits every key in one operation, one undo step. Reading a
mixed attribute answers :data:`MIXED`, a value outside every field's range --
so writing any real value back counts as an edit for every key rather than
being skipped as "already there", and a flag row part-fills its box until a
click decides it.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass, replace

from shiny_mushroom.fields import (
    Action,
    Choice,
    Choices,
    Field,
    Flags,
    Number,
    Switch,
    choices,
    readout,
)
from shiny_mushroom.hexnum import hexnum, hexspot
from shiny_mushroom.level_files import numbered_levels
from shiny_mushroom.level_names import (
    NameTables,
    decode,
    indices,
    part_options,
    word_for,
)
from shiny_mushroom.overworld import (
    COLUMNS,
    DESTROY_TILES,
    DESTROY_TWO_CELL,
    LAYER2_ENTRY_COUNT,
    LAYER2_TILES,
    MAP_EXIT_TILES,
    NO_EVENT,
    PAGE_ROWS,
    ROWS,
    SPRITE_NAMES,
    SPRITE_SLOTS,
    SUBMAP_NAMES,
    SWAP_DOUBLED_PAIR,
    TILEMAP_SIZE,
    WALK_DIRECTIONS,
    WALK_REGULAR_SHIFT,
    WALK_SECRET_SHIFT,
    TileFunction,
    WorldMap,
    cell_at,
    cell_index,
    event_conflicts,
    event_summary,
    exit_entry_at,
    exit_landing_place,
    exit_trigger,
    exit_trigger_submap,
    layer2_at,
    layer2_index,
    level_number,
    sheet_block_count,
    sheet_offset,
    sprite_disabled_on,
    tile_function,
    warp_entry_at,
    warp_landing_place,
    warp_trigger,
    warp_trigger_submap,
)

#: What a mixed attribute reads as across a multi-selection.
MIXED = -1


#: The Layer 2 entry's bit layout -- ``YXPCCCTT TTTTTTTT``. Spelled once,
#: here: the palette dock composes words with its own copy of these masks and
#: nothing else in the editor reads the bits directly.
CHAR_MASK = 0x03FF
PALETTE_MASK = 0x1C00
PRIORITY_MASK = 0x2000
X_FLIP_MASK = 0x4000
Y_FLIP_MASK = 0x8000


@dataclass(frozen=True)
class Layer2Entry:
    """One or many Layer 2 tiles under edit: the document, and their keys."""

    document: WorldMap
    keys: frozenset[int]

    def _word(self, key: int) -> int:
        return self.document.layer2_entry(key)

    def _placed(self, changes: dict[int, int]) -> WorldMap:
        return self.document.layer2_placed(changes)

    def uniform(self, extract: Callable[[int], int]) -> int:
        """What ``extract`` answers over every key, or :data:`MIXED`."""
        values = {extract(self._word(key)) for key in self.keys}
        return values.pop() if len(values) == 1 else MIXED


@dataclass(frozen=True)
class StampEntry(Layer2Entry):
    """One or many event stamp bytes under edit, keyed by sheet offset.

    A stamp pairs a tile byte with a ``YXPCCCTT`` byte -- exactly a Layer 2
    entry's two halves -- so it reads and edits as the same word and
    :func:`layer2_fields` describes it unchanged; only where the word lives
    differs.
    """

    def _word(self, key: int) -> int:
        return self.document.stamp_word(key)

    def _placed(self, changes: dict[int, int]) -> WorldMap:
        return self.document.stamp_words_placed(changes)


def _with_bits(entry: Layer2Entry, mask: int, bits: int) -> Layer2Entry:
    """``entry`` with ``mask``'s bits set to ``bits`` on every key."""
    changes = {key: (entry._word(key) & ~mask & 0xFFFF) | bits for key in entry.keys}
    return replace(entry, document=entry._placed(changes))


def _flag(entry: Layer2Entry, key: str, label: str, mask: int, hint: str) -> Field:
    return Field(
        key=key,
        label=label,
        kind=Switch(),
        read=lambda e, mask=mask: e.uniform(lambda word: 1 if word & mask else 0),
        write=lambda e, value, mask=mask: _with_bits(e, mask, mask if value else 0),
        hint=hint,
    )


def layer2_fields(entry: Layer2Entry) -> list[Field]:
    """What one or many Layer 2 tiles offer for editing.

    The char itself is a readout -- changing which tile is drawn is a
    placement, from the palette -- and the attributes are the editable half,
    because recolouring or flipping a region in place is what a selection is
    *for*.
    """
    return [
        readout(
            "Tile",
            lambda e: _mixed_hex(e.uniform(lambda word: word & CHAR_MASK), 3),
            hint="The 8x8 char the entry names. Place from the palette to change it.",
        ),
        Field(
            key="palette-row",
            label="Palette row",
            kind=Number(0, 7),
            read=lambda e: e.uniform(lambda word: (word >> 10) & 7),
            write=lambda e, value: _with_bits(e, PALETTE_MASK, (value & 7) << 10),
            hint="Which sixteen-colour row the char's pixels index.",
        ),
        _flag(
            entry,
            "x-flip",
            "X flip",
            X_FLIP_MASK,
            "Mirror the char left to right.",
        ),
        _flag(
            entry,
            "y-flip",
            "Y flip",
            Y_FLIP_MASK,
            "Mirror the char top to bottom.",
        ),
        _flag(
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


def _mixed_hex(value: int, digits: int) -> str:
    return "mixed" if value == MIXED else hexnum(value, digits)


#: The placement fields' keys the mode commits itself rather than through
#: the generic field path: a reorder renumbers the row the closures were
#: built over, a delete takes it away entirely, and a move to another event
#: re-homes it -- each one changes which row the canvas selection stands on.
STAMP_ORDER = "stamp-order"
STAMP_DELETE = "stamp-delete"
STAMP_EVENT = "stamp-event"

#: Every block the stamp sheets hold, by its first byte -- the palette
#: tabs' own libraries as one picker, the 6x6 blocks below ``$900`` and
#: the 2x2 blocks above.
_BLOCK_CHOICES = tuple(
    Choice(sheet_offset(block, 0, 0, small=False), f"6x6 {hexnum(block)}")
    for block in range(sheet_block_count(small=False))
) + tuple(
    Choice(sheet_offset(block, 0, 0, small=True), f"2x2 {hexnum(block)}")
    for block in range(sheet_block_count(small=True))
)

#: The placement columns' keys -- shared by the event table's rows and the
#: panel's placement fields, which describe the same entry-table row.
PLACEMENT_BLOCK = "event-row-block"
PLACEMENT_X = "event-row-x"
PLACEMENT_Y = "event-row-y"


def placement_fields[T](at: Callable[[T], tuple[int, int]]) -> list[Field]:
    """The fields one entry-table row offers wherever it is described: which
    sheet block it stamps, and where on the picture it lands.

    ``at`` says which row a record stands for -- ``(event, entry)`` -- so the
    same three fields serve the event table, whose record *is* the row, and
    the properties panel, whose record is the selected stamp bytes with the
    row the click resolved beside them. The write goes through the
    document's own row operations either way, so the record keeps whatever
    else it carries.

    X and Y speak the stacked picture's 8x8 grid -- the main map's 64 rows
    above the shared submap area's -- exactly as a Layer 2 selection does.
    """

    def spot(r: T) -> tuple[int, int]:
        event, entry = at(r)
        _sheet, destination = r.document.events[event][entry]
        tx, ty, submap_area = layer2_at(destination // 2)
        return tx, ty + (LAYER2_TILES if submap_area else 0)

    def moved(r: T, x: int, y: int) -> T:
        event, entry = at(r)
        destination = layer2_index(x, y % LAYER2_TILES, y >= LAYER2_TILES) * 2
        return replace(
            r, document=r.document.stamp_relocated(event, entry, destination)
        )

    def reblocked(r: T, value: int) -> T:
        event, entry = at(r)
        return replace(r, document=r.document.stamp_reblocked(event, entry, value))

    return [
        Field(
            key=PLACEMENT_BLOCK,
            label="Stamps",
            kind=Choices(_BLOCK_CHOICES),
            read=lambda r: r.document.events[at(r)[0]][at(r)[1]][0],
            write=reblocked,
            hint="Which sheet block the row stamps.",
        ),
        Field(
            key=PLACEMENT_X,
            label="X",
            kind=Number(0, LAYER2_TILES - 1, hexadecimal=True),
            read=lambda r: spot(r)[0],
            write=lambda r, value: moved(r, value, spot(r)[1]),
            hint="The block's left edge, in 8x8 tiles.",
        ),
        Field(
            key=PLACEMENT_Y,
            label="Y",
            kind=Number(0, 2 * LAYER2_TILES - 1, hexadecimal=True),
            read=lambda r: spot(r)[1],
            write=lambda r, value: moved(r, spot(r)[0], value),
            hint="The block's top edge: $00-$3F main map, $40-$7F submap area.",
        ),
    ]


def stamp_row_fields(
    document: WorldMap, event: int, entry: int, meter: str
) -> list[Field]:
    """What the one entry-table row behind a clicked stamp byte offers: its
    place in the event's reveal animation, the event it belongs to, the
    block and spot the table's own columns edit, a way out of the table,
    and the shared table's own meter -- ``meter``, the mode's reading of
    how full the table is against the cartridge's room.

    The mode resolves *which* placement the click meant -- a sheet block can
    be stamped at many places -- and these close over it, rebuilt on every
    describe so a reorder or a delete never leaves them naming a moved row.
    The reveal order, the event and the delete are committed by the mode
    itself (:data:`STAMP_ORDER`, :data:`STAMP_EVENT`, :data:`STAMP_DELETE`):
    each changes which row the selection stands on.
    """
    rows = len(document.events[event])
    return [
        readout(
            "Placement",
            lambda r: (
                f"event {hexnum(event)}, row {entry + 1} "
                f"of {len(r.document.events[event])}"
            ),
            hint="The entry-table row that stamps this block here.",
        ),
        Field(
            key=STAMP_ORDER,
            label="Reveal order",
            kind=Number(1, rows),
            read=lambda r: entry + 1,
            write=lambda r, value: replace(
                r, document=r.document.stamp_reordered(event, entry, value - 1)
            ),
            hint="Where this block comes up in the event's animation.",
        ),
        Field(
            key=STAMP_EVENT,
            label="Event",
            kind=Number(0, document.shape.stamp_events - 1, hexadecimal=True),
            read=lambda r: event,
            write=lambda r, value: replace(
                r, document=stamp_rehomed(r.document, event, entry, value)
            ),
            hint="Which event's animation this row belongs to. Picking "
            "another moves the row there, to reveal last.",
        ),
        *placement_fields(lambda r: (event, entry)),
        Field(
            key=STAMP_DELETE,
            label="Row",
            kind=Action("Delete row"),
            hint="Delete this placement. The sheet block itself stays.",
        ),
        readout(
            "Rows",
            lambda r: meter,
            hint="The entry table every event shares.",
        ),
    ]


def stamp_rehomed(document: WorldMap, event: int, entry: int, to: int) -> WorldMap:
    """``document`` with ``event``'s row ``entry`` moved to event ``to``,
    appended so it reveals last -- the one row operation two tables share.
    Its own event is no move at all."""
    if to == event:
        return document
    sheet, destination = document.events[event][entry]
    return document.stamp_deleted(event, entry).stamp_inserted(to, sheet, destination)


#: The event-rows table's delete column -- the mode commits it itself
#: rather than through the generic field path, so the canvas selection can
#: follow the rows it renumbers. Reveal order has no column: the table's
#: row order *is* the reveal order, and dragging a row's handle commits
#: through the mode the same way. The all-events view's Event column is
#: the mode's for the same reason: moving a row to another event renumbers
#: the rows on both sides.
EVENT_ROW_DELETE = "event-row-delete"
EVENT_ROW_EVENT = "event-row-event"


@dataclass(frozen=True)
class EventRow:
    """One entry-table row of one event under edit: the document, the
    event, and the row's place in its reveal order. The table editor's
    record -- rows insert, delete and reorder, so a commit rebuilds every
    record rather than trusting a row number an edit may have moved."""

    document: WorldMap
    event: int
    entry: int


def event_placement_rows(document: WorldMap, event: int) -> list[EventRow]:
    """One event's placements as table rows, in the reveal order that is
    also the animation."""
    return [
        EventRow(document, event, entry) for entry in range(len(document.events[event]))
    ]


def event_row_fields(record: EventRow) -> list[Field]:
    """One placement as table columns: which sheet block it stamps, where
    on the picture it lands, and a way out of the table. Its place in the
    animation is the row itself -- the table sits in reveal order, and the
    row's drag handle is what moves it."""
    return [
        *placement_fields(lambda r: (r.event, r.entry)),
        Field(
            key=EVENT_ROW_DELETE,
            label="Row",
            kind=Action("Delete row"),
            hint="Delete this placement. The sheet block itself stays.",
        ),
    ]


def all_event_placement_rows(document: WorldMap) -> list[EventRow]:
    """Every event's placements as table rows: replay order, each event's
    rows in its own reveal order -- the all-events view's row set."""
    return [
        EventRow(document, event, entry)
        for event in range(len(document.events))
        for entry in range(len(document.events[event]))
    ]


def all_event_row_fields(record: EventRow) -> list[Field]:
    """The all-events view's columns: the same row, led by which event it
    belongs to -- editable, since with no event focused the column is the
    only way to say where a row goes."""

    def rehomed(r: EventRow, to: int) -> EventRow:
        moved = stamp_rehomed(r.document, r.event, r.entry, to)
        if moved is r.document:
            return r
        return replace(r, document=moved, event=to, entry=len(moved.events[to]) - 1)

    return [
        Field(
            key=EVENT_ROW_EVENT,
            label="Event",
            kind=Number(0, record.document.shape.stamp_events - 1, hexadecimal=True),
            read=lambda r: r.event,
            write=rehomed,
            hint="Which event's animation this row belongs to. Picking "
            "another moves the row there, to reveal last.",
        ),
        *event_row_fields(record),
    ]


#: How a silent slot's layer byte reads -- bit 0 set stamps a Layer 2
#: block, clear writes one Layer 1 tile.
_SILENT_LAYERS = (Choice(0, "Layer 1"), Choice(1, "Layer 2"))

#: The silent table's delete column -- the mode commits it itself rather
#: than through the generic field path, so a canvas selection standing on
#: a later slot renumbers with the block. Added slots come from the table's
#: footer action, which is the dialog's.
SILENT_ROW_DELETE = "silent-row-delete"


@dataclass(frozen=True)
class SilentRow:
    """One slot of the silent-tiles block under edit. The table editor's
    record -- the slot number is the identity, and since the block's scan
    follows its rows a delete renumbers the slots after it, so a commit
    rebuilds every record rather than trusting a slot an edit may have
    moved."""

    document: WorldMap
    slot: int


def silent_rows(document: WorldMap, event: int | None = None) -> list[SilentRow]:
    """Every silent slot as a table row -- or only ``event``'s slots."""
    return [
        SilentRow(document, slot)
        for slot in range(document.shape.silent)
        if event is None or document.silent_entry(slot)[0] == event
    ]


def _silent_changed(record: SilentRow, **parts: int) -> SilentRow:
    """``record`` with the given parts of its slot rewritten, the rest kept.

    The kept layer is masked to bit 0, which is the only bit the game -- and
    every read here -- decides the layer by. A cartridge whose block stores
    a wider byte would otherwise have an edit to any *other* column refused
    by the setter it is carried through.
    """
    event, layer, location, tile = record.document.silent_entry(record.slot)
    held = {"event": event, "layer": layer & 1, "location": location, "tile": tile}
    held.update(parts)
    return replace(
        record, document=record.document.silent_entry_set(record.slot, **held)
    )


def _silent_spot(record: SilentRow) -> tuple[int, int]:
    """Where the slot lands, in its layer's own grid on the stacked picture
    -- 16x16 cells for Layer 1, 8x8 tiles for Layer 2. An out-of-range
    location (the game reads whatever is there) reads clamped."""
    _event, layer, location, _tile = record.document.silent_entry(record.slot)
    if layer & 1:
        tx, ty, submap_area = layer2_at(min(location // 2, LAYER2_ENTRY_COUNT - 1))
        return tx, ty + (LAYER2_TILES if submap_area else 0)
    return cell_at(min(location, TILEMAP_SIZE - 1))


def _silent_row_fields(record: SilentRow, with_event: bool) -> list[Field]:
    _event, layer, _location, _tile = record.document.silent_entry(record.slot)
    stamped = bool(layer & 1)

    def moved(r: SilentRow, x: int, y: int) -> SilentRow:
        if r.document.silent_entry(r.slot)[1] & 1:
            location = layer2_index(x, y % LAYER2_TILES, y >= LAYER2_TILES) * 2
        else:
            location = cell_index(x, y)
        return _silent_changed(r, location=location)

    fields = [
        readout(
            "Slot",
            lambda r: str(r.slot),
            hint="The slot's place in the block; where two write one spot, "
            "the lower number lands last.",
        )
    ]
    if with_event:
        fields.append(
            Field(
                key="silent-event",
                label="Event",
                kind=Number(0, 0xFF, hexadecimal=True),
                read=lambda r: r.document.silent_entry(r.slot)[0],
                write=lambda r, value: _silent_changed(r, event=value),
                hint="The event whose flag places this tile. Above $6E parks the slot.",
            )
        )
    fields += [
        Field(
            key="silent-layer",
            label="Layer",
            kind=Choices(_SILENT_LAYERS),
            read=lambda r: r.document.silent_entry(r.slot)[1] & 1,
            write=lambda r, value: _silent_changed(r, layer=value),
            hint="Layer 2 stamps a sheet block; Layer 1 writes one Map16 tile.",
        ),
        Field(
            key="silent-x",
            label="X",
            kind=Number(
                0, LAYER2_TILES - 1 if stamped else COLUMNS - 1, hexadecimal=True
            ),
            read=lambda r: _silent_spot(r)[0],
            write=lambda r, value: moved(r, value, _silent_spot(r)[1]),
            hint="The landing's left edge: 8x8 tiles for Layer 2, 16x16 cells "
            "for Layer 1.",
        ),
        Field(
            key="silent-y",
            label="Y",
            kind=Number(
                0, 2 * LAYER2_TILES - 1 if stamped else ROWS - 1, hexadecimal=True
            ),
            read=lambda r: _silent_spot(r)[1],
            write=lambda r, value: moved(r, _silent_spot(r)[0], value),
            hint="The landing's top edge, main map above the submap area.",
        ),
        Field(
            key="silent-tile",
            label="Tile",
            kind=Choices(_BLOCK_CHOICES) if stamped else Number(0, 0xFF, True),
            read=lambda r: r.document.silent_entry(r.slot)[3],
            write=lambda r, value: _silent_changed(r, tile=value),
            hint="The sheet block a Layer 2 slot stamps, or the tile a Layer "
            "1 slot writes.",
        ),
        Field(
            key=SILENT_ROW_DELETE,
            label="Slot",
            kind=Action("Delete slot"),
            hint="Delete this slot; the rest close up. At least one slot stays.",
        ),
    ]
    return fields


def silent_row_fields(record: SilentRow) -> list[Field]:
    """A focused event's silent slot as table columns -- the event is the
    focus, so no column repeats it."""
    return _silent_row_fields(record, with_event=False)


def all_silent_row_fields(record: SilentRow) -> list[Field]:
    """The all-events view's columns: the same slot, led by the event that
    places it."""
    return _silent_row_fields(record, with_event=True)


#: The destroyed-tiles table's delete column -- committed by the mode, like
#: the silent table's, so a canvas selection standing on a later slot
#: renumbers with the block. Offered only where the cartridge's scan follows
#: the rows: on a stock build it reads a literal 24 slots over the 16 the
#: table has, and the mode refuses with the relocation feature named.
DESTROY_ROW_DELETE = "destroy-row-delete"


@dataclass(frozen=True)
class DestroyRow:
    """One slot of the destroyed-tiles scan under edit -- which event crushes
    the ruin at which cell.

    The table editor's record. The slot number is the identity; on a
    cartridge whose scan follows the rows a delete renumbers the slots after
    it, so a commit rebuilds every record rather than trusting a slot an edit
    may have moved.
    """

    document: WorldMap
    slot: int


def destroy_rows(document: WorldMap) -> list[DestroyRow]:
    """Every destroy slot as a table row."""
    return [DestroyRow(document, slot) for slot in range(document.shape.destroy)]


def _destroy_changed(record: DestroyRow, **parts: int) -> DestroyRow:
    """``record`` with the given parts of its slot rewritten, the rest kept."""
    event, location = record.document.destroy_entry(record.slot)
    held = {"event": event, "location": location}
    held.update(parts)
    return replace(
        record, document=record.document.destroy_entry_set(record.slot, **held)
    )


def _destroy_spot(record: DestroyRow) -> tuple[int, int]:
    """The cell the slot crushes -- the ruin's top cell, since a two-cell
    ruin writes the row below as well. An out-of-range location (the game
    writes wherever it points) reads clamped."""
    _event, location = record.document.destroy_entry(record.slot)
    return cell_at(min(location, TILEMAP_SIZE - 1))


def ruin_kind_at(document: WorldMap, location: int) -> int | None:
    """Which ruin kind the map's tile at ``location`` matches, or ``None``.

    Highest kind first, which is the routine's own search order, so a table
    that lists one tile twice resolves here the way it resolves in the game.
    """
    if location >= TILEMAP_SIZE:
        return None
    tile = document.tiles[location]
    return next(
        (
            kind
            for kind in range(DESTROY_TILES - 1, -1, -1)
            if document.destroy_ruin(kind)[0] == tile
        ),
        None,
    )


def _destroy_becomes(record: DestroyRow) -> str:
    """What the cell turns into when this slot fires, read off the map as it
    stands -- or ``--`` where its tile is no ruin's before-tile, which is the
    slot aiming at nothing."""
    _event, location = record.document.destroy_entry(record.slot)
    kind = ruin_kind_at(record.document, location)
    if kind is None:
        return "--"
    _before, top, bottom = record.document.destroy_ruin(kind)
    if kind >= DESTROY_TWO_CELL:
        return f"{hexnum(top)} / {hexnum(bottom)}"
    return hexnum(bottom)


def destroy_row_fields(record: DestroyRow) -> list[Field]:
    """One destroy slot as table columns."""
    return [
        readout(
            "Slot",
            lambda r: str(r.slot),
            hint="The slot's place in the block; where two name one event, "
            "the higher number wins.",
        ),
        Field(
            key="destroy-event",
            label="Event",
            kind=Number(0, 0xFF, hexadecimal=True),
            read=lambda r: r.document.destroy_entry(r.slot)[0],
            write=lambda r, value: _destroy_changed(r, event=value),
            hint="The event whose flag crushes this cell. Above $6E parks the slot.",
        ),
        Field(
            key="destroy-x",
            label="X",
            kind=Number(0, COLUMNS - 1, hexadecimal=True),
            read=lambda r: _destroy_spot(r)[0],
            write=lambda r, value: _destroy_changed(
                r, location=cell_index(value, _destroy_spot(r)[1])
            ),
            hint="The ruin's cell, in 16x16 cells.",
        ),
        Field(
            key="destroy-y",
            label="Y",
            kind=Number(0, ROWS - 1, hexadecimal=True),
            read=lambda r: _destroy_spot(r)[1],
            write=lambda r, value: _destroy_changed(
                r, location=cell_index(_destroy_spot(r)[0], value)
            ),
            hint="The ruin's top cell, main map above the submap area.",
        ),
        readout(
            "Tile",
            lambda r: hexnum(r.document.tile(cell_index(*_destroy_spot(r)))),
            hint="What the map holds in that cell now.",
        ),
        readout(
            "Becomes",
            _destroy_becomes,
            hint="What the cell turns into. Dashes where the tile matches no ruin.",
        ),
        Field(
            key=DESTROY_ROW_DELETE,
            label="Slot",
            kind=Action("Delete slot"),
            hint="Delete this slot; the rest close up. At least one slot stays.",
        ),
    ]


@dataclass(frozen=True)
class RuinRow:
    """One ruin kind under edit: the tile the scan matches, and the pair it
    writes. Shared by every destroy slot that lands on such a tile, which is
    the game's own arrangement and not this editor's simplification."""

    document: WorldMap
    kind: int


def ruin_rows(document: WorldMap) -> list[RuinRow]:
    """Every ruin kind as a table row."""
    return [RuinRow(document, kind) for kind in range(DESTROY_TILES)]


def _ruin_changed(record: RuinRow, **parts: int) -> RuinRow:
    """``record`` with the given tiles of its kind rewritten, the rest kept."""
    before, top, bottom = record.document.destroy_ruin(record.kind)
    held = {"before": before, "top": top, "bottom": bottom}
    held.update(parts)
    return replace(
        record, document=record.document.destroy_ruin_set(record.kind, **held)
    )


def ruin_row_fields(record: RuinRow) -> list[Field]:
    """One ruin kind as table columns. The top tile is offered only where the
    routine writes one: its ``CPX #$0003`` makes the byte dead for the first
    three kinds, and a box that changed nothing would say otherwise."""
    tall = record.kind >= DESTROY_TWO_CELL
    return [
        readout(
            "Kind",
            lambda r: f"{r.kind} -- {'two cells' if tall else 'one cell'}",
            hint="The kind's fixed place in the tables. Kind "
            f"{DESTROY_TWO_CELL} up is two cells tall.",
        ),
        Field(
            key="ruin-before",
            label="Before",
            kind=Number(0, 0xFF, hexadecimal=True),
            read=lambda r: r.document.destroy_ruin(r.kind)[0],
            write=lambda r, value: _ruin_changed(r, before=value),
            hint="The Map16 tile a destroy slot has to find to fire.",
        ),
        Field(
            key="ruin-top",
            label="Top",
            kind=Number(0, 0xFF, hexadecimal=True),
            read=lambda r: r.document.destroy_ruin(r.kind)[1],
            write=(lambda r, value: _ruin_changed(r, top=value)) if tall else None,
            hint="The tile written where the match was found. Dead for the "
            f"kinds below {DESTROY_TWO_CELL}, which write only a bottom tile."
            if tall
            else "Dead for this kind: the routine writes a top tile only "
            f"from kind {DESTROY_TWO_CELL} up.",
        ),
        Field(
            key="ruin-bottom",
            label="Bottom",
            kind=Number(0, 0xFF, hexadecimal=True),
            read=lambda r: r.document.destroy_ruin(r.kind)[2],
            write=lambda r, value: _ruin_changed(r, bottom=value),
            hint="The tile written at the ruin's base.",
        ),
    ]


@dataclass(frozen=True)
class SubsRow:
    """One event's pass-1 substitution under edit: the cell the event aims
    its Layer 1 tile swap at.

    The table editor's record. The table is indexed by event number, so the
    event is the row's identity and nothing inserts or deletes -- an event
    is aimed somewhere, or left on the table's idle location 0.
    """

    document: WorldMap
    event: int


def subs_rows(document: WorldMap, event: int | None = None) -> list[SubsRow]:
    """Every event's substitution row -- or only ``event``'s."""
    return [
        SubsRow(document, held)
        for held in range(document.shape.subs)
        if event is None or held == event
    ]


def _subs_spot(record: SubsRow) -> tuple[int, int]:
    """The cell the row aims at. An out-of-range location (the game writes
    wherever it points) reads clamped, like a destroy slot's."""
    return cell_at(min(record.document.subs_cell(record.event), TILEMAP_SIZE - 1))


def _subs_moved(record: SubsRow, x: int, y: int) -> SubsRow:
    return replace(
        record, document=record.document.subs_cell_set(record.event, cell_index(x, y))
    )


def swap_pair_at(document: WorldMap, location: int) -> int | None:
    """Which substitution pair the map's tile at ``location`` matches, or
    ``None`` -- highest pair first, the routine's own search order, so a
    tile listed twice resolves here the way it resolves in the game."""
    if location >= TILEMAP_SIZE:
        return None
    tile = document.tiles[location]
    return next(
        (
            pair
            for pair in range(document.shape.swaps - 1, -1, -1)
            if document.swap_pair(pair)[0] == tile
        ),
        None,
    )


def _subs_becomes(record: SubsRow) -> str:
    """What the aimed-at cell turns into, read off the map as it stands --
    or ``--`` where its tile matches no pair, which is the substitution
    aiming at nothing."""
    location = record.document.subs_cell(record.event)
    pair = swap_pair_at(record.document, location)
    if pair is None:
        return "--"
    after = record.document.swap_pair(pair)[1]
    if pair == SWAP_DOUBLED_PAIR:
        return f"{hexnum(after)}, next cell too"
    return hexnum(after)


def _subs_row_fields(record: SubsRow, with_event: bool) -> list[Field]:
    fields: list[Field] = []
    if with_event:
        fields.append(
            readout(
                "Event",
                lambda r: hexnum(r.event),
                hint="One substitution per event; the row's place is fixed. "
                "Above $6E never fires.",
            )
        )
    fields += [
        Field(
            key="subs-x",
            label="X",
            kind=Number(0, COLUMNS - 1, hexadecimal=True),
            read=lambda r: _subs_spot(r)[0],
            write=lambda r, value: _subs_moved(r, value, _subs_spot(r)[1]),
            hint="The aimed-at cell, in 16x16 cells.",
        ),
        Field(
            key="subs-y",
            label="Y",
            kind=Number(0, ROWS - 1, hexadecimal=True),
            read=lambda r: _subs_spot(r)[1],
            write=lambda r, value: _subs_moved(r, _subs_spot(r)[0], value),
            hint="The aimed-at cell, main map above the submap area.",
        ),
        readout(
            "Tile",
            lambda r: hexnum(r.document.tile(cell_index(*_subs_spot(r)))),
            hint="What the map holds in that cell now.",
        ),
        readout(
            "Becomes",
            _subs_becomes,
            hint="What the cell turns into. Dashes where the tile matches no pair.",
        ),
    ]
    return fields


def subs_row_fields(record: SubsRow) -> list[Field]:
    """A focused event's substitution row as table columns -- the event is
    the focus, so no column repeats it."""
    return _subs_row_fields(record, with_event=False)


def all_subs_row_fields(record: SubsRow) -> list[Field]:
    """The all-events view's columns: the same row, led by the event it
    belongs to."""
    return _subs_row_fields(record, with_event=True)


#: The pairs table's delete column -- committed by the mode, like the
#: silent table's, so the rows renumber under one history step.
SWAP_ROW_DELETE = "swap-row-delete"


@dataclass(frozen=True)
class SwapRow:
    """One substitution pair under edit: the tile the scan matches, and the
    tile it writes. Shared by every event whose location lands on such a
    tile, which is the game's own arrangement and not this editor's
    simplification."""

    document: WorldMap
    pair: int


def swap_rows(document: WorldMap) -> list[SwapRow]:
    """Every substitution pair as a table row."""
    return [SwapRow(document, pair) for pair in range(document.shape.swaps)]


def _swap_changed(record: SwapRow, **parts: int) -> SwapRow:
    """``record`` with the given tiles of its pair rewritten, the rest kept."""
    before, after = record.document.swap_pair(record.pair)
    held = {"before": before, "after": after}
    held.update(parts)
    return replace(record, document=record.document.swap_pair_set(record.pair, **held))


def swap_row_fields(record: SwapRow) -> list[Field]:
    """One substitution pair as table columns."""
    doubled = record.pair == SWAP_DOUBLED_PAIR
    return [
        readout(
            "Pair",
            lambda r: (
                hexnum(r.pair) + (" -- writes the next cell too" if doubled else "")
            ),
            hint="The pair's place in the tables. A tile listed twice "
            "resolves to the higher pair -- the routine's search order. "
            f"Pair {hexnum(SWAP_DOUBLED_PAIR)} alone writes two adjacent "
            "cells, the routine's compare and not the table's, so whichever "
            "pair sits there doubles.",
        ),
        Field(
            key="swap-before",
            label="Before",
            kind=Number(0, 0xFF, hexadecimal=True),
            read=lambda r: r.document.swap_pair(r.pair)[0],
            write=lambda r, value: _swap_changed(r, before=value),
            hint="The Map16 tile a substitution has to find to fire.",
        ),
        Field(
            key="swap-after",
            label="After",
            kind=Number(0, 0xFF, hexadecimal=True),
            read=lambda r: r.document.swap_pair(r.pair)[1],
            write=lambda r, value: _swap_changed(r, after=value),
            hint="The tile written where the match was found.",
        ),
        Field(
            key=SWAP_ROW_DELETE,
            label="Pair",
            kind=Action("Delete pair"),
            hint="Delete this pair; the rest close up. At least one pair stays.",
        ),
    ]


#: How far off the 512-pixel map a sprite may be placed. The shipped table
#: already goes off it -- Bowser sits at ``Y = -4`` -- so a ``0-511`` box
#: would refuse what the cartridge ships; this margin covers the borders the
#: camera can show.
SPRITE_MIN, SPRITE_MAX = -64, 575


@dataclass(frozen=True)
class SpriteSlot:
    """One sprite slot under edit: the document, and which slot."""

    document: WorldMap
    slot: int


#: The editable map-flags field's key -- the generic field path commits it.
SPRITE_MAPS = "sprite-maps"

#: The map bits as the panel offers them: the mask each map owns in the
#: disable byte, named. The row shows where a sprite **appears**, which is the
#: byte inverted -- the inversion lives in the field's read and write, so the
#: widget never has to know the table says the opposite.
_MAP_BITS = Flags(
    tuple((0x80 >> map_id, name) for map_id, name in enumerate(SUBMAP_NAMES))
)


def _slots_sharing(record: SpriteSlot, number: int) -> tuple[int, ...]:
    """The other slots holding ``number`` -- the ones an edit here moves too."""
    return tuple(
        slot
        for slot in range(SPRITE_SLOTS)
        if slot != record.slot and record.document.sprite(slot).sprite_id == number
    )


def _map_rows(record: SpriteSlot) -> list[Field]:
    """The panel's "Appears on" rows: the seven maps as switches when the
    slot holds a type the table has a row for, a readout otherwise.

    An empty slot has no type, and a type is what the table is indexed by --
    so there is nothing to offer until the slot holds one, and offering seven
    dead boxes would say there was.
    """

    def sprite(r: SpriteSlot):  # noqa: ANN202 - a local shorthand
        return r.document.sprite(r.slot)

    def shown(r: SpriteSlot) -> int:
        disable, number = r.document.sprite_disable, sprite(r).sprite_id
        held = 0
        for map_id, (mask, _) in enumerate(_MAP_BITS.bits):
            if not sprite_disabled_on(disable, number, map_id):
                held |= mask
        return held

    def show_on(r: SpriteSlot, value: int) -> SpriteSlot:
        number = sprite(r).sprite_id
        held = r.document.sprite_disable[number - 1]
        # The disable byte is the inverse over the bits the row offers; the
        # rest of it -- the low bit the game never reads -- is the
        # cartridge's and rides through.
        disabled = (held & ~_MAP_BITS.mask | ~value & _MAP_BITS.mask) & 0xFF
        return replace(r, document=r.document.sprite_disable_set(number, disabled))

    number = record.document.sprite(record.slot).sprite_id
    if not 1 <= number <= len(record.document.sprite_disable):
        return [
            readout(
                "Appears on",
                lambda r: ", ".join(sprite(r).appears_on) or "-",
                hint="The maps this slot's type is enabled on. An empty slot "
                "has no type.",
            )
        ]
    sharing = _slots_sharing(record, number)
    return [
        Field(
            key=SPRITE_MAPS,
            label="Appears on",
            kind=_MAP_BITS,
            read=shown,
            write=show_on,
            hint="Which maps show this sprite; the position is the same on each.",
        ),
        readout(
            "Shared with",
            lambda _r: (
                ("slots " if len(sharing) > 1 else "slot ")
                + ", ".join(str(slot) for slot in sharing)
                if sharing
                else "no other slot"
            ),
            hint="The other slots holding this type. Changing the maps above "
            "changes these too.",
        ),
    ]


def _drawn_at(record: SpriteSlot) -> str:
    """Where a self-placing slot is really drawn, as the panel prints it.

    A Smoke reads its per-map table, so the row names every map and the spot
    on it. The two that place themselves off a trigger tile have no one spot
    to name, and say so in the words :data:`PLACED_BY_CODE` gives them.
    """
    sprite = record.document.sprite(record.slot)
    spots = sprite.smoke_spots
    if not spots:
        return sprite.placed_by_code
    return "; ".join(
        f"{hexspot(x, y, 3)} on {SUBMAP_NAMES[map_id]}" for map_id, x, y in spots
    )


def sprite_fields(record: SpriteSlot) -> list[Field]:
    """What one sprite slot offers for editing.

    Positions are decimal: they are map pixels the way a person drags them,
    not table bytes. "Appears on" edits the game's own table, whose row is the
    *type's*: retyping the slot moves to another row, and switching a map
    moves every slot on this one -- which the rows under it name.
    """

    def sprite(r: SpriteSlot):  # noqa: ANN202 - a local shorthand
        return r.document.sprite(r.slot)

    def moved(r: SpriteSlot, x: int, y: int) -> SpriteSlot:
        return replace(r, document=r.document.sprite_moved(r.slot, x, y))

    placed = sprite(record).placed_by_code
    if placed:
        # The type writes its own position over the slot's before it draws,
        # so the two bytes are readouts: offering a spin box would offer an
        # edit the console throws away. What it does with them instead is
        # the row underneath.
        position = [
            readout(
                "X",
                lambda r: hexnum(sprite(r).x, 3),
                hint="The slot table's X. This type overwrites it, so nothing "
                "reads it.",
            ),
            readout(
                "Y",
                lambda r: hexnum(sprite(r).y, 3),
                hint="The slot table's Y, overwritten the same way.",
            ),
            readout(
                "Drawn at",
                _drawn_at,
                hint="Where the sprite's own code puts it -- what the markers follow.",
            ),
        ]
    else:
        position = [
            Field(
                key="sprite-x",
                label="X",
                kind=Number(SPRITE_MIN, SPRITE_MAX, hexadecimal=True, digits=3),
                read=lambda r: sprite(r).x,
                write=lambda r, value: moved(r, value, sprite(r).y),
                hint="Map pixels from the left edge, in the shared 512x512 space.",
            ),
            Field(
                key="sprite-y",
                label="Y",
                kind=Number(SPRITE_MIN, SPRITE_MAX, hexadecimal=True, digits=3),
                read=lambda r: sprite(r).y,
                write=lambda r, value: moved(r, sprite(r).x, value),
                hint="Map pixels from the top edge; the range reaches off the map.",
            ),
        ]

    return [
        Field(
            key="sprite-type",
            label="Type",
            kind=Choices(
                tuple(Choice(number, name) for number, name in enumerate(SPRITE_NAMES))
            ),
            read=lambda r: sprite(r).sprite_id,
            write=lambda r, value: replace(
                r, document=r.document.sprite_replaced(r.slot, value)
            ),
            hint="Which sprite this slot holds.",
        ),
        *position,
        *_map_rows(record),
    ]


@dataclass(frozen=True)
class CellWalk:
    """One level cell under edit: the document, the cell, and the events
    table the panel's readout quotes.

    The record is the *cell*, not the translevel: the translevel is derived
    from the map as it stands, so it re-derives after every commit the way
    the properties panel's rows do.
    """

    document: WorldMap
    index: int
    level_events: bytes
    #: The levels the Level picker offers, as
    #: :func:`~shiny_mushroom.level_files.level_choices` builds them -- number
    #: and the container the level comes out of. Carried on the record because
    #: it is what the *cartridge* holds rather than what the map does, and
    #: nothing below has one to ask; empty falls back to bare numbers, which is
    #: every level said as well as it can be said without a tree to name it.
    levels: tuple[Choice, ...] = ()

    @property
    def translevel(self) -> int:
        return self.document.translevels[self.index]


_WALK_CHOICES = tuple(
    Choice(code, name.capitalize()) for code, name in enumerate(WALK_DIRECTIONS)
)


def _level_text(record: CellWalk) -> str:
    """Which level a cell's translevel loads, or ``none``."""
    _x, y = cell_at(record.index)
    found = level_number(
        record.translevel, y >= PAGE_ROWS, record.document.translevel_levels
    )
    return hexnum(found, 3) if found is not None else "none"


#: The editable level-number field's key -- the generic field path commits it.
LEVEL_NUMBER = "level-number"


def _level_number_rows(record: CellWalk) -> list[Field]:
    """The Level row: an editable number on a cartridge whose
    ``translevel-remap`` table the document carries -- remapping the tile is
    editing its row -- and the derived readout everywhere else, where the
    game computes the number and there is nothing to point elsewhere."""
    document = record.document
    if not (
        document.translevel_levels
        and record.translevel < len(document.translevel_levels) // 2
    ):
        return [
            readout(
                "Level", _level_text, hint="The level this cell's translevel loads."
            )
        ]
    return [
        Field(
            key=LEVEL_NUMBER,
            label="Level",
            # The same picker the toolbar's Level box is, filled from the same
            # rows: a level is remembered as a place rather than as a number,
            # so a tile remapped to a typed $0CB is a remap nobody can check.
            kind=Choices(record.levels or numbered_levels(), searchable=True),
            read=lambda r: r.document.translevel_level(r.translevel),
            write=lambda r, value: replace(
                r, document=r.document.translevel_level_set(r.translevel, value)
            ),
            hint="The level this tile loads -- any of the 512, per tile.",
        )
    ]


def _walk_field(key: str, label: str, shift: int, hint: str) -> Field:
    def written(record: CellWalk, value: int) -> CellWalk:
        held = record.document.direction(record.translevel)
        byte = (held & ~(3 << shift) & 0xFF) | ((value & 3) << shift)
        return replace(
            record, document=record.document.direction_set(record.translevel, byte)
        )

    return Field(
        key=key,
        label=label,
        kind=Choices(_WALK_CHOICES),
        read=lambda r: (r.document.direction(r.translevel) >> shift) & 3,
        write=written,
        hint=hint,
    )


def cell_readouts() -> list[Field]:
    """The two rows every described cell opens with, whatever else it offers."""
    return [
        readout(
            "Area",
            lambda r: "Submaps" if cell_at(r.index)[1] >= PAGE_ROWS else "Main map",
            hint="Which page of the shared tilemap the cell is on.",
        ),
        readout(
            "Tile",
            lambda r: hexnum(r.document.tile(r.index)),
            hint="The Map16 tile this cell holds.",
        ),
    ]


#: The editable event field's key -- the generic field path commits it.
LEVEL_EVENT = "level-event"


def _event_rows(record: CellWalk) -> list[Field]:
    """The panel's event rows: an editable number with a live collision
    readout when the document carries the table, the quoting readout
    otherwise -- a capture-less test document still describes itself."""

    def event(r: CellWalk) -> str:
        return event_summary(r.level_events, r.translevel)

    def checks(r: CellWalk) -> str:
        value = r.document.level_event(r.translevel)
        if value == NO_EVENT:
            return "fires no event"
        found = event_conflicts(
            r.document.level_events, r.translevel, max(r.document.translevels)
        )
        if found:
            return "; ".join(found)
        return f"secret exit fires {hexnum(value + 1)} -- no collisions"

    if not (
        record.document.level_events
        and record.translevel < record.document.shape.level_events
    ):
        return [
            readout(
                "Event",
                event,
                hint="Which event the clear fires; the secret exit fires the "
                "next one up.",
            )
        ]
    return [
        Field(
            key=LEVEL_EVENT,
            label="Event",
            kind=Number(0, 0xFF, hexadecimal=True),
            read=lambda r: r.document.level_event(r.translevel),
            write=lambda r, value: replace(
                r, document=r.document.level_event_set(r.translevel, value)
            ),
            hint="Which event a regular clear fires; $FF for none. A secret "
            "exit fires the next number up.",
        ),
        readout(
            "Event checks",
            checks,
            hint="Where this level's event numbering collides with another's.",
        ),
    ]


#: The name pickers' keys, in part order -- the generic field path commits
#: them like any other cell.
NAME_PART_KEYS = ("name-part1", "name-part2", "name-part3")

_NAME_PART_HINTS = (
    "The first word -- the world or owner half, ending in its own space tile.",
    "The middle word -- HOUSE, ISLAND, CASTLE and their kin.",
    "The last part -- a digit or closing word; (none) ends the name early.",
)


def name_fields(record: CellWalk, tables: NameTables | None) -> list[Field]:
    """The level-name rows: the box text as it assembles, and the three part
    pickers behind it.

    Empty where there is nothing to say: a document with no names table (the
    Japanese target's own format), or a cartridge whose part tables could
    not be read. A translevel past the table's reach gets the readout alone,
    which is also what the overflow check warns about.
    """
    document = record.document
    if tables is None or not document.level_names:
        return []

    def word(r: CellWalk) -> int:
        return r.document.level_name(r.translevel)

    name = readout(
        "Name",
        lambda r: decode(word(r), tables) or "(blank)",
        hint="The 19-character name box, from the three parts below. Parts "
        "are shared between levels.",
    )
    if record.translevel >= document.shape.level_names:
        return [
            readout(
                "Name",
                lambda r: "past the names table",
                hint="The names table ends before this translevel; the box "
                "would read past it.",
            )
        ]
    rows = [name]
    for which, key, label in zip(
        range(3), NAME_PART_KEYS, ("Part 1", "Part 2", "Part 3"), strict=True
    ):

        def read(r: CellWalk, which: int = which) -> int:
            return indices(word(r))[which]

        def written(r: CellWalk, value: int, which: int = which) -> CellWalk:
            parts = list(indices(word(r)))
            parts[which] = value
            return replace(
                r,
                document=r.document.level_name_set(r.translevel, word_for(*parts)),
            )

        rows.append(
            Field(
                key=key,
                label=label,
                kind=choices(part_options(tables, which)),
                read=read,
                write=written,
                hint=_NAME_PART_HINTS[which],
            )
        )
    return rows


def _level_columns(record: CellWalk, open_level: bool = False) -> list[Field]:
    """What a level offers wherever it is described: where it stands in the
    numbering, what it loads, its event, and which way each of its exits walks
    off -- the columns the cell panel and the per-level table both carry, so
    the two cannot describe one level differently.

    ``open_level`` adds the button that opens the level itself, beside the
    number naming it. The panel offers it and the table does not: a column of
    buttons, one per row, is a table of ways to close the table.
    """
    return [
        readout(
            "Translevel",
            lambda r: hexnum(r.translevel),
            hint="Placing or removing level tiles renumbers it.",
        ),
        *_level_number_rows(record),
        *([open_level_action()] if open_level else []),
        *_event_rows(record),
        _walk_field(
            "walk-regular",
            "After clear",
            WALK_REGULAR_SHIFT,
            "Which way the player walks off the level after its regular exit.",
        ),
        _walk_field(
            "walk-secret",
            "After secret",
            WALK_SECRET_SHIFT,
            "Which way after the secret exit, for the levels that have one.",
        ),
    ]


def walk_fields(record: CellWalk, open_level: bool = False) -> list[Field]:
    """What one level cell offers for editing: the two walk directions its
    clear can take and its event number, over readouts of what the cell is.

    The walk byte's last two fields are unused in the shipped game and are
    carried through unchanged, exactly as the read-only panel leaves them
    unshown.

    ``open_level`` is :func:`_level_columns`' -- the cell panel's button, off
    wherever the level is already the one being looked at.
    """
    return [*cell_readouts(), *_level_columns(record, open_level)]


def level_rows(
    document: WorldMap, level_events: bytes, levels: tuple[Choice, ...] = ()
) -> list[CellWalk]:
    """Every numbered level as a table row, in the scan's own order.

    Keyed by cell, so a commit re-derives the translevel rather than
    trusting a row number an edit may have renumbered. Rows past the
    level-events table's reach are left out -- their columns would differ,
    and a table is one column set -- which on any sane map excludes nothing.
    """
    return [
        CellWalk(document, index, level_events, levels)
        for index, translevel in enumerate(document.translevels)
        if 0 < translevel < document.shape.level_events
    ]


def level_row_fields(record: CellWalk) -> list[Field]:
    """One level's row of the per-level tables: where it stands, then the same
    columns the cell panel edits."""

    def spot(r: CellWalk) -> str:
        x, y = cell_at(r.index)
        return hexspot(x, y)

    return [
        readout("Cell", spot, hint="Where the level tile stands on the map."),
        *_level_columns(record),
    ]


@dataclass(frozen=True)
class WarpEntry:
    """One row of the star/pipe warp tables under edit: the document, and
    which entry. The table editor's record -- the entry number is the
    identity, and a delete renumbers the entries after it, so a commit
    rebuilds every record rather than trusting a number an edit may have
    moved."""

    document: WorldMap
    entry: int


#: The warp and exit tables' delete columns -- committed by the mode, so a
#: canvas selection standing on a later warp renumbers with the table.
WARP_ROW_DELETE = "warp-row-delete"
EXIT_ROW_DELETE = "exit-row-delete"


def warp_trigger_rows(document: WorldMap) -> list[WarpEntry]:
    """Every warp entry as a table row, in the tables' own order."""
    return [WarpEntry(document, entry) for entry in range(document.shape.warps)]


def warp_trigger_fields(record: WarpEntry) -> list[Field]:
    """One warp entry's trigger as table columns: the cell it stands on, the
    map it stands on, and where it lands.

    The map is a column of its own, never derived: the submap viewports
    overlap, and the trigger only fires for a player whose *current map*
    matches the stored byte -- the shipped table names Vanilla Dome for a
    cell the nearest camera would call the Forest's. The picture page
    follows the map (submap zero is the main page), so picking a map can
    move the row between halves, exactly as editing Y across the page
    boundary re-homes the map.
    """
    return [*_warp_columns(), _warp_landing(), _warp_delete()]


def _warp_delete() -> Field:
    return Field(
        key=WARP_ROW_DELETE,
        label="Entry",
        kind=Action("Delete entry"),
        hint="Delete this warp; the rest close up. At least one entry stays.",
    )


def warp_entry_fields(record: WarpEntry) -> list[Field]:
    """One warp entry as the **properties panel's** rows: the table's own
    columns, what its trigger cell actually holds, and the pick that moves
    the landing.

    The tile readout is the panel's and not the table's, because it is the
    one thing about an entry that no column of the table can hold: the
    transfer is keyed on the *position*, and the game only reads its table
    at all for a player pressing a button while standing on a star or a
    pipe. An entry parked anywhere else is a row that can never fire, which
    nothing in the table's own bytes says.
    """
    return [
        *_warp_columns(),
        _warp_trigger_tile(),
        _warp_landing(),
        Field(
            key=WARP_PICK,
            label="Warp landing",
            kind=Action("Set destination..."),
            hint="Pick the landing: the next click on a cell puts the "
            "destination there.",
        ),
        _warp_delete(),
    ]


@dataclass(frozen=True)
class ExitEntry:
    """One row of the path-exit tables under edit: the document, and which
    entry -- :class:`WarpEntry`'s contract on the other transfer."""

    document: WorldMap
    entry: int


def exit_trigger_rows(document: WorldMap) -> list[ExitEntry]:
    """Every path-exit entry as a table row, in the tables' own order."""
    return [ExitEntry(document, entry) for entry in range(document.shape.exits)]


def exit_trigger_fields(record: ExitEntry) -> list[Field]:
    """One path exit's trigger as table columns: the cell it fires at, the
    map it stands on, where it lands, and a way out of the table.

    The cell, not the pixel: the game matches the walking player's exact
    position, and where inside the cell that falls depends on the path the
    player arrives by, so an entry keeps its own sub-cell offsets and only
    the cell is offered -- a new entry copies a shipped one's. The map is a
    column for :func:`warp_trigger_fields`' reason.
    """
    return [*_exit_columns(), _exit_landing(), _exit_delete()]


def exit_entry_fields(record: ExitEntry) -> list[Field]:
    """One path exit as the **properties panel's** rows --
    :func:`warp_entry_fields` on the other table: the table's own columns,
    what its trigger cell actually holds, and the pick that moves the
    landing."""
    return [
        *_exit_columns(),
        _exit_trigger_tile(),
        _exit_landing(),
        Field(
            key=EXIT_PICK,
            label="Exit landing",
            kind=Action("Set destination..."),
            hint="Pick the landing: the next click on a cell puts the "
            "destination there.",
        ),
        _exit_delete(),
    ]


def _exit_columns() -> list[Field]:
    """The trigger's three editable columns: its cell, and its map."""

    def spot(r: ExitEntry) -> tuple[int, int]:
        return exit_trigger(r.document.exits, r.entry)

    def moved(r: ExitEntry, x: int, y: int) -> ExitEntry:
        return replace(r, document=r.document.exit_trigger_moved(r.entry, x, y))

    return [
        Field(
            key="exit-x",
            label="X",
            kind=Number(0, COLUMNS - 1, hexadecimal=True),
            read=lambda r: spot(r)[0],
            write=lambda r, value: moved(r, value, spot(r)[1]),
            hint="The trigger cell's column.",
        ),
        Field(
            key="exit-y",
            label="Y",
            kind=Number(0, ROWS - 1, hexadecimal=True),
            read=lambda r: spot(r)[1],
            write=lambda r, value: moved(r, spot(r)[0], value),
            hint="The trigger cell's row: $00-$1F main map, $20-$3F submap half.",
        ),
        Field(
            key="exit-map",
            label="Map",
            kind=Choices(
                tuple(Choice(number, name) for number, name in enumerate(SUBMAP_NAMES))
            ),
            read=lambda r: exit_trigger_submap(r.document.exits, r.entry),
            write=lambda r, value: replace(
                r, document=r.document.exit_trigger_mapped(r.entry, value)
            ),
            hint="The map the player must be walking on for this entry to match.",
        ),
    ]


def _exit_landing() -> Field:
    return readout(
        "Lands at",
        lambda r: exit_landing_place(r.document.exits, r.entry),
        hint="Where walking onto the trigger lands the player. Set "
        "destination... retargets it.",
    )


def _exit_delete() -> Field:
    return Field(
        key=EXIT_ROW_DELETE,
        label="Entry",
        kind=Action("Delete entry"),
        hint="Delete this exit; the rest close up. At least one entry stays.",
    )


def _exit_trigger_tile() -> Field:
    """What an exit's trigger cell holds, and whether the game would ever
    look at this entry there -- :func:`_warp_trigger_tile` on the tiles that
    step off the map."""

    def named(r: ExitEntry) -> str:
        x, y = exit_trigger(r.document.exits, r.entry)
        tile = r.document.tile(cell_index(x, y))
        function = tile_function(tile)
        if tile in MAP_EXIT_TILES:
            return f"{hexnum(tile)}  {function.value}, steps off to another map"
        return f"{hexnum(tile)}  {function.value} -- nothing exits from here"

    return readout(
        "Trigger tile",
        named,
        hint="The Map16 tile the trigger stands on. Only a tile that steps "
        "off the map fires.",
    )


def _warp_trigger_tile() -> Field:
    """What the trigger cell holds, and whether the game would ever look at
    this entry there."""

    def named(r: WarpEntry) -> str:
        x, y = warp_trigger(r.document.warps, r.entry)
        tile = r.document.tile(cell_index(x, y))
        function = tile_function(tile)
        if function in (TileFunction.STAR_WARP, TileFunction.PIPE_WARP):
            return f"{hexnum(tile)}  {function.value}"
        return f"{hexnum(tile)}  {function.value} -- nothing warps from here"

    return readout(
        "Trigger tile",
        named,
        hint="The Map16 tile the trigger stands on. Only a star or pipe tile fires.",
    )


def _warp_columns() -> list[Field]:
    """The trigger's three editable columns: its cell, and its map."""

    def moved(r: WarpEntry, x: int, y: int) -> WarpEntry:
        return replace(r, document=r.document.warp_trigger_moved(r.entry, x, y))

    return [
        Field(
            key="trigger-x",
            label="X",
            kind=Number(0, COLUMNS - 1, hexadecimal=True),
            read=lambda r: warp_trigger(r.document.warps, r.entry)[0],
            write=lambda r, value: moved(
                r, value, warp_trigger(r.document.warps, r.entry)[1]
            ),
            hint="The trigger cell's column.",
        ),
        Field(
            key="trigger-y",
            label="Y",
            kind=Number(0, ROWS - 1, hexadecimal=True),
            read=lambda r: warp_trigger(r.document.warps, r.entry)[1],
            write=lambda r, value: moved(
                r, warp_trigger(r.document.warps, r.entry)[0], value
            ),
            hint="The trigger cell's row: $00-$1F main map, $20-$3F submap half.",
        ),
        Field(
            key="trigger-map",
            label="Map",
            kind=Choices(
                tuple(Choice(number, name) for number, name in enumerate(SUBMAP_NAMES))
            ),
            read=lambda r: warp_trigger_submap(r.document.warps, r.entry),
            write=lambda r, value: replace(
                r, document=r.document.warp_trigger_mapped(r.entry, value)
            ),
            hint="The map the player must be standing on for this entry to match.",
        ),
    ]


def _warp_landing() -> Field:
    return readout(
        "Lands at",
        lambda r: warp_landing_place(r.document.warps, r.entry),
        hint="Where this entry puts the player. Set destination... retargets it.",
    )


#: The keys a destination pick arrives on -- the mode dispatches these to a
#: click-the-cell gesture rather than to a written value.
WARP_PICK = "warp-pick"
EXIT_PICK = "exit-pick"


def link_fields(record: CellWalk) -> list[Field]:
    """What a warp or exit trigger cell adds: where the transfer lands, and
    a pick to move it.

    Empty for a cell that triggers neither, so a caller can append this to
    any cell's fields. Both transfers are keyed on the cell's *position* --
    the destination row survives a tile edit truthfully, exactly as the
    read-only panel's did.
    """
    fields: list[Field] = []
    if warp_entry_at(record.document.warps, record.index) is not None:
        fields.append(
            readout(
                "Warps to",
                lambda r: warp_landing_place(
                    r.document.warps, warp_entry_at(r.document.warps, r.index)
                ),
                hint="Where this star or pipe lands the player.",
            )
        )
        fields.append(
            Field(
                key=WARP_PICK,
                label="Warp landing",
                kind=Action("Set destination..."),
                hint="Pick the landing: the next click on a cell puts the "
                "destination there.",
            )
        )
    if exit_entry_at(record.document.exits, record.index) is not None:
        fields.append(
            readout(
                "Exits to",
                lambda r: exit_landing_place(
                    r.document.exits, exit_entry_at(r.document.exits, r.index)
                ),
                hint="Where walking onto this exit tile carries the player.",
            )
        )
        fields.append(
            Field(
                key=EXIT_PICK,
                label="Exit landing",
                kind=Action("Set destination..."),
                hint="Pick the landing: the next click on a cell puts the "
                "destination there.",
            )
        )
    return fields


#: The key a cell panel's Level Load Path button arrives on -- an action the
#: mode passes to the window, which owns the window it opens.
LOAD_PATH = "load-path"


def load_path_action() -> Field:
    """The button a level cell carries: open the Level Load Path window on
    the level this tile loads.

    A row rather than a menu item because the panel is where the cell is
    already described, and the chain is the one fact about it the panel
    cannot draw: the tables, the files and the entrance are three documents
    away.
    """
    return Field(
        key=LOAD_PATH,
        label="Load chain",
        kind=Action("Level Load Path..."),
        hint="Trace what this tile loads, top to bottom.",
    )


#: The key a cell panel's Open Level button arrives on -- an action the mode
#: passes to the window, which owns the document the level would replace.
OPEN_LEVEL = "open-level"


def open_level_action() -> Field:
    """The button beside a level cell's number: leave the map and open that
    level.

    Beside the number rather than under the panel, because the number is what
    it acts on -- a tile remapped to another level opens the level the row
    now names.
    """
    return Field(
        key=OPEN_LEVEL,
        label="Open",
        kind=Action("Open Level"),
        hint="Leave the world map and edit the level this tile loads.",
    )
