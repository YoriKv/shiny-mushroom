"""Everything about editing the world map, given a canvas and two docks.

The world map mode's whole state machine, kept beside the window rather than in
it: the document and its history, the selection, the marquee, what is in hand,
and the picture. :class:`~shiny_mushroom.ui.main_window.MainWindow` owns *when*
this mode is active -- it swaps the canvas's picture and the docks' visibility
and routes gestures here while the world map is up -- and this class owns what
every gesture means once it arrives.

The canvas still owns no model: gestures arrive here as image-pixel points, and
everything painted goes back out as an image and overlays. The document is a
:class:`~shiny_mushroom.overworld.WorldMap` under the same identity contract as
a level, so :class:`~shiny_mushroom.edit.History` carries it unchanged -- one
history over every part, which is what makes an undo take back whichever kind
of edit came last.

**Which layer a gesture edits follows the palette's tab, and nothing else.**
The Layer 1 tab selects and places 16x16 cells; the Layer 2 tab selects and
places 8x8 entries; the two stamp tabs select and place event stamp
placements; the Sprites tab selects and places the markers; the Warps/Exits
tab selects and drags the star and pipe warp triggers **and the path exits**,
which are rows of the game's own position tables and place nothing -- a
cartridge has as many of either as its code scans. Both tables are drawn
at once there, told apart by hue: the warp magenta and the exit teal the
map's key already spends on them. Each layer is scenery to the others, the
events view included -- it shows the stamps drawn over the map, but what is
drawn never moves what a gesture edits. The toolbar's "Editing" box is the
same choice under another handle -- the window routes its picks to the tab.
What is armed is the dock's typed payload, so a click dispatches on what is
in hand rather than on bookkeeping of its own.

**A stamp sheet drawn whole is the one picture that is not the map.** Either
stamp tab offers it (:meth:`OverworldMode.set_sheet_view`), and while it is
up every gesture is on that sheet's entries -- there is nothing else under
the pointer to mean. It is the same document under a different picture, so
one history, one dirty flag and one Ctrl+S span both, and an undo made on the
map reaches an edit made on the sheet.

Edits re-render locally -- only the cells that changed are patched -- so no
placement costs an emulator round trip.
"""

from __future__ import annotations

from collections.abc import Callable, Sequence
from dataclasses import dataclass, replace
from enum import Enum, auto

from PySide6.QtCore import QObject, QPoint, QRect, QSize, Qt
from PySide6.QtGui import QColor, QImage

from shiny_mushroom.edit import History
from shiny_mushroom.fields import Action, Choice
from shiny_mushroom.hexnum import hexnum, hexspot
from shiny_mushroom.level import BLOCK, TILE, Blocks
from shiny_mushroom.overworld import (
    COLUMNS,
    DEFAULT_SPAWN,
    DESTROY_REGION,
    EXIT_REGION,
    HARDWIRED_TRANSLEVELS,
    NO_EVENT,
    PAGE_ROWS,
    REPLAYED_EVENTS,
    ROWS,
    SHEET_6X6_SIZE,
    SILENT_REGION,
    SPRITE_NAMES,
    SPRITE_SLOTS,
    STAMP_REGION,
    STAMP_ROW_BUDGET,
    STOCK_SHAPE,
    SUBMAP_NAMES,
    SWAPS_REGION,
    TILEMAP_SIZE,
    WALK_VECTORS,
    WARP_REGION,
    MapShape,
    OverworldSprite,
    StampPlacements,
    TileFunction,
    WorldMap,
    WorldPainters,
    boo_offsets,
    carried_rows,
    cell_at,
    cell_index,
    cell_place,
    cell_properties,
    changed_cells,
    changed_layer2,
    changed_stamps,
    decoded_placements,
    destroy_part,
    event_highlight_tiles,
    event_missed_tiles,
    event_snapshot,
    exit_entry_at,
    exit_links,
    exit_trigger,
    exits_part,
    layer2_at,
    layer2_cell,
    layer2_index,
    layer2_thumbnails,
    level_number,
    path_step,
    replayed,
    replayed_steps,
    repointed,
    sheet_at,
    sheet_blocks,
    sheet_grid,
    sheet_spot,
    sheet_tile,
    smoke_positions,
    spawn_cell,
    spawn_for_cell,
    sprite_disabled_on,
    stamp_block_raster,
    stamp_index,
    stamp_row_count,
    stamp_thumbnails,
    stamp_uses,
    submap_at,
    submap_page_cells,
    submap_region,
    submap_screen,
    submap_window,
    table_allows,
    table_capacity,
    tile_function,
    tile_thumbnails,
    warp_entry_at,
    warp_links,
    warp_trigger,
    warps_part,
    world_blocks,
)
from shiny_mushroom.overworld_fields import (
    DESTROY_ROW_DELETE,
    EXIT_PICK,
    EXIT_ROW_DELETE,
    LOAD_PATH,
    OPEN_LEVEL,
    SILENT_ROW_DELETE,
    SPRITE_MAX,
    SPRITE_MIN,
    STAMP_DELETE,
    STAMP_EVENT,
    STAMP_ORDER,
    WARP_PICK,
    WARP_ROW_DELETE,
    CellWalk,
    DestroyRow,
    ExitEntry,
    Layer2Entry,
    SilentRow,
    SpriteSlot,
    StampEntry,
    SubsRow,
    WarpEntry,
    all_silent_row_fields,
    all_subs_row_fields,
    cell_readouts,
    destroy_row_fields,
    exit_entry_fields,
    layer2_fields,
    link_fields,
    load_path_action,
    sprite_fields,
    stamp_rehomed,
    stamp_row_fields,
    walk_fields,
    warp_entry_fields,
)
from shiny_mushroom.overworld_snapshot import OverworldSnapshot
from shiny_mushroom.tile_clipboard import (
    FloatController,
    FloatingSelection,
    FloatStep,
    SelectionMark,
    TileClipboard,
    centred,
    landing,
    relative,
)
from shiny_mushroom.ui.canvas import (
    SCREEN_LINE_COLOR,
    SCREEN_NOTE_COLOR,
    Canvas,
    Overlay,
)
from shiny_mushroom.ui.canvas_view import CanvasView
from shiny_mushroom.ui.context_menu import SEPARATOR, Row
from shiny_mushroom.ui.gestures import box_between
from shiny_mushroom.ui.overlays import (
    DASH_LENGTH,
    MARQUEE_COLOR,
    PLACING_COLOR,
    PLACING_OPACITY,
    SELECTION_DASH,
    SELECTION_LINE,
)
from shiny_mushroom.ui.overworld_events import (
    DESTROY_LABEL_COLOR,
    DESTROY_MARK_COLOR,
    RECORD_OUTLINE_INSET,
    SILENT_LABEL_COLOR,
    SILENT_MARK_COLOR,
    SUBS_LABEL_COLOR,
    SUBS_MARK_COLOR,
    DestroyDrag,
    DestroyMarker,
    SilentDrag,
    SilentMarker,
    SubsDrag,
    SubsMarker,
    destroy_all_at,
    destroy_at,
    destroy_markers,
    silent_all_at,
    silent_at,
    silent_markers,
    silent_spot,
    subs_all_at,
    subs_at,
    subs_markers,
)
from shiny_mushroom.ui.overworld_picture import SheetPicture, WorldPicture
from shiny_mushroom.ui.overworld_sprites import (
    EMPTY_OPACITY,
    SpriteDrag,
    glyph_image,
    markers,
    player_marker_image,
    slot_at,
    sprite_art_image,
)
from shiny_mushroom.ui.overworld_transfers import (
    EXITS,
    WARPS,
    TransferDrag,
    TransferMarker,
    TransferTable,
    marker_at,
)
from shiny_mushroom.ui.overworld_transfers import mark_image as transfer_mark_image
from shiny_mushroom.ui.overworld_transfers import markers as transfer_markers
from shiny_mushroom.ui.properties import PropertiesDock
from shiny_mushroom.ui.render import raster_to_image
from shiny_mushroom.ui.tile_palette import (
    ICON,
    STAMP_TABS,
    Layer1Tile,
    Layer2Word,
    PaletteTab,
    SpritePick,
    StampBlock,
    TilePaletteDock,
    TransferRow,
)
from shiny_mushroom.ui.world_marks import (
    EXIT_MARK_COLOR,
    MARK_LINE_WIDTH,
    MARK_UNDER_WIDTH,
    WARP_MARK_COLOR,
    WARP_WEDGE,
    path_hue,
)
from smw_tools.features import OVERWORLD_TABLES_RELOCATED


class Kind(Enum):
    """What a selection's keys mean -- which part of the map they index."""

    CELLS = auto()  # Layer 1 16x16 cells, keyed by cell_index
    TILES = auto()  # Layer 2 8x8 tiles, keyed by layer2_index
    STAMPS = auto()  # event stamp placements, keyed by sheet offset
    SHEET = auto()  # stamp sheet entries drawn whole, keyed by sheet offset
    SPRITES = auto()  # sprite slots
    WARPS = auto()  # star and pipe warp entries, keyed by table entry
    EXITS = auto()  # path-exit entries, keyed by table entry
    SILENT = auto()  # silent-tile slots, keyed by slot
    DESTROY = auto()  # destroyed-tile slots, keyed by slot
    SUBS = auto()  # pass-1 substitution rows, keyed by event


@dataclass(frozen=True)
class Selection:
    """What is held: one kind at a time, however many keys.

    One kind rather than a mixed bag, because every consumer -- the ants, the
    properties panel, an attribute edit -- answers per kind, and a marquee
    that could catch two kinds would need a rule for what an edit to "the
    selection" means. Emptiness keeps the old spelling: ``if self.selection``.
    """

    kind: Kind
    keys: frozenset[int]

    def __bool__(self) -> bool:
        return bool(self.keys)


@dataclass(frozen=True)
class Room:
    """What a would-be document's run of ROM has to spare -- the answer the
    window's pricer gives the mode before a row is added.

    ``spare`` is bytes left in the region's run with the document's rows in
    place, negative by how much it would overflow; ``relocated`` whether the
    cartridge's overworld tables already sit in the expansion bank the
    relocation feature reserves -- which decides what the refusal suggests:
    the feature, or taking rows back out.
    """

    spare: int
    relocated: bool


@dataclass(frozen=True)
class Refusal:
    """Why a row was not added: what was refused, why, and what would help.

    The status line says it in one breath (:attr:`said`); a table dialog's
    footer button, where the click was, says it in a warning the remedy can
    be read from -- the same words, so the two never disagree.
    """

    what: str
    why: str
    remedy: str

    @property
    def said(self) -> str:
        return f"{self.what}: {self.why}. {self.remedy}"

    @property
    def headline(self) -> str:
        return f"{self.what}: {self.why}."


#: How the mode prices a would-be document against the cartridge: handed the
#: document and the region id of the table that grew, answers its run's
#: :class:`Room`, or ``None`` where nothing can -- a cartridge with no
#: project or no build behind it.
RoomPricer = Callable[[WorldMap, str], Room | None]

#: Where the mode gets the rows a level picker offers -- the window's, which
#: holds the tree that names the levels. See :attr:`OverworldMode.levels`.
LevelPicker = Callable[[], tuple[Choice, ...]]

#: The feature that gives the overworld's tables room to grow -- what a
#: refusal for room points at. Read off the declaration rather than spelled
#: out again, so a renamed feature cannot leave this pointing at a row that is
#: no longer called that.
RELOCATION_FEATURE = f"Project > Features > {OVERWORLD_TABLES_RELOCATED.name}"


def _spare_said(spare: int) -> str:
    """``N bytes spare in the run`` -- or over it, for a negative number."""
    if spare < 0:
        return f"{-spare:,} byte{'' if spare == -1 else 's'} over the run"
    return f"{spare:,} byte{'' if spare == 1 else 's'} spare in the run"


def _reordered(row: int, entry: int, to: int) -> int:
    """Where ``row`` lands once the placement at ``entry`` is moved to ``to``.

    The shuffle every list makes: the moved row goes where it was sent, and
    everything it stepped over closes up behind it or opens up in front.
    """
    if row == entry:
        return to
    if entry < row <= to:
        return row - 1
    if to <= row < entry:
        return row + 1
    return row


#: Holding nothing. The kind is arbitrary -- an empty selection has none.
EMPTY_SELECTION = Selection(Kind.CELLS, frozenset())

#: The two kinds that are rows of a transfer table -- the star and pipe warps,
#: and the path exits. One mode edits both, on one tab and one picture: what
#: makes them two *kinds* rather than one is that the tables number their
#: entries apiece, so a key means nothing without saying whose it is.
TRANSFER_KINDS = frozenset({Kind.WARPS, Kind.EXITS})

#: Which table each transfer kind is a row of -- the descriptor that answers
#: where an entry triggers and lands, what a move of it commits, and the hues
#: it is drawn in (:mod:`shiny_mushroom.ui.overworld_transfers`).
_TABLES = {Kind.WARPS: WARPS, Kind.EXITS: EXITS}


def _kind_of(table: TransferTable) -> Kind:
    """Which kind a marker of ``table`` is selected as -- :data:`_TABLES`
    read the other way, by identity, since a table is a descriptor rather
    than a value."""
    return Kind.EXITS if table is EXITS else Kind.WARPS


#: The kinds whose marquee is drawn while it is being swept.
#:
#: A box is worth drawing where the box and the selection are different
#: things: it reaches across the picture and catches whichever *records* it
#: touches, so it has to be visible while the ants are somewhere else. Boxing
#: a **tilemap** -- Layer 1's cells, Layer 2's tiles, a sheet's -- is not that.
#: Every spot inside the box is caught, so the ants already outline the box
#: itself and a second rectangle in another colour is one statement drawn
#: twice.
BOXED_KINDS = frozenset({Kind.SPRITES, Kind.STAMPS, Kind.WARPS, Kind.EXITS})

#: Why a drag over the stamps held nothing. Said rather than left silent: a
#: gesture that works on one picture and not on the next reads as broken, and
#: the focus is the whole difference between them.
BOX_NEEDS_FOCUS = "Focus one event to box its stamps"


@dataclass(frozen=True)
class WorldClipboard(TileClipboard):
    """What a world-map copy holds: a
    :class:`~shiny_mushroom.tile_clipboard.TileClipboard` -- values with
    relative geometry, because an index is an identity here and there is no
    record to carry one in -- plus which **kind** of entry was copied. The
    payload is a Map16 tile for cells, a 16-bit entry for Layer 2 tiles, a
    sprite number for sprites, and the units are the kind's own: cells, 8x8
    tiles, or map pixels.

    The kind is where the copy came *from*, which is not always where it
    goes: :data:`WORD_KINDS` land in whichever word picture is up.
    """

    kind: Kind


#: The kinds whose payload is a 16-bit tilemap word on a grid of 8x8 tiles:
#: Layer 2's tiles and a stamp sheet's entries.
#:
#: The same material in three editors -- Layer 2, the 6x6 sheet and the 2x2 --
#: because a stamp entry *is* a tilemap word, split across two parallel tables
#: only because the game stores it that way. So one clipboard serves all
#: three, and what a copy becomes is decided by the picture it is put down on
#: rather than the one it was taken off. Cells and sprites stay out: a Map16
#: tile counts in 16x16 cells and a sprite number is not a tile at all.
WORD_KINDS = frozenset({Kind.TILES, Kind.SHEET})


@dataclass(frozen=True)
class TransferCopy:
    """What a copy of transfer entries holds: **whole rows**, with the
    triggers' geometry relative to the copy's top-left corner.

    The deliberate contrast with :class:`WorldClipboard`, which holds values
    because a tilemap entry *is* only its value. A transfer is a record: its
    bytes are spread across its table's parallel sections, its entry number
    is an identity rather than a position, and where it lands is as much of
    it as where it fires. So a copy carries the row whole and a paste appends
    one -- the same shape a sprite copy would have if a sprite were more than
    a number, and nothing at all like a cell's.

    The geometry is the **trigger** cells', which is what the map shows and
    what a paste under the pointer lands on. The landing rides along inside
    the row and is not moved: two copies of a warp that fires on different
    cells and lands on the same one is the ordinary reason to copy one.
    """

    #: Which table the rows are of -- :attr:`Kind.WARPS` or
    #: :attr:`Kind.EXITS`. A paste puts them back in the table they came
    #: from and nowhere else: the two tables' rows are packed differently
    #: and are read by different code in the game.
    kind: Kind
    #: Each row as ``(dx, dy, record)`` from the copy's corner, the record
    #: being the entry's slice of each of its table's sections.
    entries: tuple[tuple[int, int, tuple[bytes, ...]], ...]
    #: Where that corner was taken from, in cells.
    origin: tuple[int, int]


#: What a copy of each kind is called in the status line.
_COPY_NOUNS = {
    Kind.CELLS: "cell",
    Kind.TILES: "tile",
    Kind.SHEET: "sheet tile",
    Kind.SPRITES: "sprite",
    Kind.WARPS: WARPS.noun,
    Kind.EXITS: EXITS.noun,
}

#: The kinds whose copy is a **record** rather than a spot on a grid: a
#: sprite in a slot, and a transfer as a row of its table.
#:
#: What they share is everything the paste path branches on. None of them
#: lands on a grid spot that can already be occupied, so none can float -- a
#: float is the right to keep moving tiles that overwrote something, and
#: there is nothing underneath a record. And each is short of somewhere to
#: go for a reason of its own -- no empty slot, no room in the run of ROM --
#: so each says its own shortfall rather than the tilemaps' "fell off the
#: edge".
RECORD_KINDS = frozenset({Kind.SPRITES, Kind.WARPS, Kind.EXITS})


def _cell_spot(x: int, y: int) -> int | None:
    """Layer 1's addressing for a paste's
    :func:`~shiny_mushroom.tile_clipboard.landing`: the cell's index, or
    ``None`` for a spot off the map."""
    return cell_index(x, y) if 0 <= x < COLUMNS and 0 <= y < ROWS else None


def _layer2_spot(tx: int, ty: int) -> int | None:
    """Layer 2's addressing for the same call, over the two stacked pages:
    ``ty`` runs to 128, submap half below the main."""
    if 0 <= tx < _LAYER2_SIDE and 0 <= ty < 2 * _LAYER2_SIDE:
        return layer2_index(tx, ty % _LAYER2_SIDE, ty >= _LAYER2_SIDE)
    return None


#: The tabs each kind is selected and edited on -- one kind per Editing row,
#: the stamps' row standing for both sheet tabs. Stamp placements and the
#: sheet entries behind them share those two: the row is the same material,
#: and the sheet-drawing button is which end of it the canvas is showing.
_LAYER_TABS = {
    Kind.CELLS: (PaletteTab.LAYER1,),
    Kind.TILES: (PaletteTab.LAYER2,),
    Kind.STAMPS: STAMP_TABS,
    Kind.SHEET: STAMP_TABS,
    Kind.SPRITES: (PaletteTab.SPRITES,),
    Kind.WARPS: (PaletteTab.TRANSFERS,),
    Kind.EXITS: (PaletteTab.TRANSFERS,),
    # The other two event tables are edited in the same mode as the stamps:
    # their slots are the Events row's records, marked and reached only there.
    Kind.SILENT: STAMP_TABS,
    Kind.DESTROY: STAMP_TABS,
    Kind.SUBS: STAMP_TABS,
}

#: The kinds whose records exist only on the events view -- the stamps drawn
#: by the replay, and the two event tables' slot marks beside them. A
#: selection of any goes down with the view: its keys mean nothing on the
#: base map.
EVENTS_VIEW_KINDS = frozenset({Kind.STAMPS, Kind.SILENT, Kind.DESTROY, Kind.SUBS})


@dataclass(frozen=True)
class EventRecord:
    """One row of the events view under the pointer: which table it is a row
    of, and which row.

    ``keys`` is the row's own address in its table -- ``(slot,)`` for a
    silent or destroyed-tile slot, ``(event,)`` for a substitution row, and
    ``(event, entry)`` for a stamp placement, whose table is per event. One
    shape for four tables, because what a click there has to answer is the
    same question four times: *which record did I mean*.
    """

    kind: Kind
    keys: tuple[int, ...]


@dataclass(frozen=True)
class StampDrag:
    """One stamp placement mid-drag: which entry, and where it is right now.

    Positions are 8x8 tiles over the two stacked pages -- ``ty`` runs to 128,
    submap half below the main -- because that is the space the pointer moves
    in; the Layer 2 buffer offset is derived once, at :attr:`destination`.
    ``anchor`` is the grabbed tile minus the placement's origin tile, so the
    block tracks the pointer without jumping, exactly as a sprite drag holds.

    A drag with ``entry < 0`` is a **new row on its way in** -- a Ctrl-drag
    duplicate -- carrying its sheet source in :attr:`sheet`; dropping it
    appends the row to ``event`` rather than moving anything.
    """

    event: int
    entry: int
    side: int
    anchor: tuple[int, int]
    tx: int
    ty: int
    sheet: int = -1

    def moved(self, point: QPoint) -> StampDrag:
        """This drag with the origin under ``point``, kept on the map and in
        one half -- a block cannot straddle the page seam, because the halves
        are separate tilemaps that only the picture stacks."""
        tx = point.x() // TILE - self.anchor[0]
        ty = point.y() // TILE - self.anchor[1]
        tx = max(0, min(_LAYER2_SIDE - self.side, tx))
        if ty < _LAYER2_SIDE:
            ty = max(0, min(_LAYER2_SIDE - self.side, ty))
        else:
            ty = max(_LAYER2_SIDE, min(2 * _LAYER2_SIDE - self.side, ty))
        return replace(self, tx=tx, ty=ty)

    @property
    def destination(self) -> int:
        """The Layer 2 buffer byte offset the current position means."""
        return (
            layer2_index(self.tx, self.ty % _LAYER2_SIDE, self.ty >= _LAYER2_SIDE) * 2
        )

    @property
    def rect(self) -> QRect:
        return QRect(self.tx * TILE, self.ty * TILE, self.side * TILE, self.side * TILE)


#: What the properties panel says with a map up and nothing picked.
NOTHING_SELECTED = "Click a tile of the map to see what it is."

#: The refusal for a click on an unstamped tile while the events view is on.
UNSTAMPED_NOTE = "That tile is the base map's -- turn Overworld Events off to edit it."

#: The refusal for a stamp gesture with the events view down.
NO_VIEW_NOTE = (
    "The events view is down -- pick an event in the Event box to see stamps."
)

#: The refusal for a stamp block placed with no event focused.
NO_FOCUS_NOTE = "Focus one event in the Event box to add a stamp to it."

#: What the properties panel says over a sheet with nothing picked.
NOTHING_SELECTED_SHEET = "Click a tile of the sheet to see what it is."

#: The refusal for a sprite placement with nowhere to land.
NO_EMPTY_SLOT = "Every sprite slot is in use -- delete or retype one first."


def placed_by_code_note(sprite: OverworldSprite) -> str:
    """Why a slot whose type places itself does not move.

    Said on every gesture that would move it -- a drag, a nudge, the
    placement that put it there -- because the marker looks like every other
    marker and the panel's rows are one glance away: the gesture is where a
    person finds out, so it is where the reason belongs.
    """
    return (
        f"{sprite.name} is placed by its own code -- {sprite.placed_by_code}. "
        "The slot's position is never drawn."
    )


def hidden_here_note(name: str, framed: str, appears_on: Sequence[str]) -> str:
    """What a placement says when the framed map's own table hides the type
    just placed.

    Not a refusal: the placement is exactly what the cartridge allows, and
    the game would spend the slot the same way. The marker is drawn either
    way -- the editor hides none of them -- so what earns a line is that the
    console will not draw it on the map being looked at, which the marker
    alone cannot say.
    """
    if not appears_on:
        return (
            f"{name} is hidden on every map -- the slot is spent. Tick a map "
            "in Appears on to show it."
        )
    return (
        f"{name} does not appear on {framed} -- the game draws it on "
        f"{', '.join(appears_on)}. Tick {framed} in Appears on to show it here."
    )


#: One page of the map, in pixels -- what the canvas's screen grid divides at.
PAGE = QSize(COLUMNS * BLOCK, COLUMNS * BLOCK)

#: The map's Layer 2 side in 8x8 tiles, per page.
_LAYER2_SIDE = 64

#: An invisible stroke, for overlays that are only their image -- the sprite
#: markers, whose glyph carries its own outline.
_NO_LINE = QColor(0, 0, 0, 0)

# The test-run marks, in the ants' two-line treatment -- black underneath so
# they survive any artwork, and a hue on top that neither the selection nor
# the marquee nor the ghost uses. Amber says "this level is already beaten";
# the warmer orange says "both exits are". Green says "the run starts here",
# and is only the fallback: where the capture answered the player's own
# figure, that figure standing on the cell is the mark.
SPAWN_MARK_COLOR = QColor(0x30, 0xE0, 0x50)
COMPLETED_MARK_COLOR = QColor(0xFF, 0xC8, 0x28)
SECRET_MARK_COLOR = QColor(0xFF, 0x70, 0x20)

# The connector lines' dash: a statement about the picture's geography --
# where a transfer leads -- not a mark on the document, so it is longer than
# the ants' and the two never read as one instrument.
CONNECTOR_DASH = 4

# The radius of the ring a transfer's connector ends in, in image pixels: a
# quarter of a block, so the circle is half a cell across and sits inside the
# landing cell rather than over its neighbours. The line's own endcap, not a
# second mark beside it -- see `OverworldMode._transfer_marks`.
LANDING_CAP = BLOCK / 4

#: The wash over what a framed submap's border hides: the parts of the
#: console screen the Layer 3 border covers, dimmed rather than blanked so
#: the map stays readable underneath while clearly not part of the view.
BORDER_MASK_COLOR = QColor(0x00, 0x00, 0x00, 0x96)

_washes: dict[int, QImage] = {}


def _wash_tile(color: QColor) -> QImage:
    """A wash's image: one translucent pixel, stretched over each strip it
    covers -- an overlay is a rectangle and a picture, and this is the
    smallest picture that fills one.

    Cached per colour, and the cache is what the marks are told apart by:
    every overlay of one wash carries the same image object, which is how a
    reader -- and a test -- says which wash a mark is.
    """
    tile = _washes.get(color.rgba())
    if tile is None:
        tile = QImage(1, 1, QImage.Format.Format_ARGB32)
        tile.fill(color.rgba())
        _washes[color.rgba()] = tile
    return tile


def border_mask() -> QImage:
    """The mask over what a framed submap's border hides."""
    return _wash_tile(BORDER_MASK_COLOR)


#: The wash over everything a focused event does not touch -- the events
#: view's "this event only" dimming, a shade deeper than the border mask so
#: the event's own tiles stand out plainly against the rest of the map.
FOCUS_DIM_COLOR = QColor(0x00, 0x00, 0x00, 0xA8)


def focus_dim() -> QImage:
    """The wash over the map the focused event leaves alone."""
    return _wash_tile(FOCUS_DIM_COLOR)


#: The tint over a focused event's conditional targets that miss -- the
#: substitution or destroy cell whose tile fails the condition. Lit like
#: the event's own tiles (the event names the cell), red because running
#: the event here would change nothing.
FOCUS_MISS_COLOR = QColor(0xD0, 0x28, 0x28, 0x66)


def focus_miss() -> QImage:
    """The tint over a focused event's conditional targets that miss."""
    return _wash_tile(FOCUS_MISS_COLOR)


def _focus_strips(tiles: frozenset[int]) -> list[QRect]:
    """The rects covering every 8x8 tile **not** in ``tiles``: full-width
    bands over tile rows the event leaves alone, merged down the page, and
    the runs between a row's kept tiles -- a handful of stretched washes
    rather than thousands of tile-sized ones. Tile-grained because the
    stamps land on the 8x8 grid: a 16x16 wash would leave a halo of
    untouched tiles lit around every unaligned stamp."""
    kept_rows: dict[int, list[int]] = {}
    for index in tiles:
        tx, ty, submap_area = layer2_at(index)
        row = ty + (_LAYER2_SIDE if submap_area else 0)
        kept_rows.setdefault(row, []).append(tx)
    width, height = _LAYER2_SIDE, 2 * _LAYER2_SIDE
    strips: list[QRect] = []
    band: int | None = None
    for y in range(height):
        kept = sorted(kept_rows.get(y, ()))
        if not kept:
            band = y if band is None else band
            continue
        if band is not None:
            strips.append(QRect(0, band * TILE, width * TILE, (y - band) * TILE))
            band = None
        cursor = 0
        for x in kept:
            if x > cursor:
                strips.append(QRect(cursor * TILE, y * TILE, (x - cursor) * TILE, TILE))
            cursor = x + 1
        if cursor < width:
            strips.append(QRect(cursor * TILE, y * TILE, (width - cursor) * TILE, TILE))
    if band is not None:
        strips.append(QRect(0, band * TILE, width * TILE, (height - band) * TILE))
    return strips


def _border_strips(screen: QRect, window: QRect) -> list[QRect]:
    """The four rects of ``screen`` outside ``window`` -- what the border
    covers, as strips the mask can be stretched over."""
    strips = [
        QRect(
            screen.x(),
            screen.y(),
            screen.width(),
            window.y() - screen.y(),
        ),
        QRect(
            screen.x(),
            window.y() + window.height(),
            screen.width(),
            screen.y() + screen.height() - window.y() - window.height(),
        ),
        QRect(
            screen.x(),
            window.y(),
            window.x() - screen.x(),
            window.height(),
        ),
        QRect(
            window.x() + window.width(),
            window.y(),
            screen.x() + screen.width() - window.x() - window.width(),
            window.height(),
        ),
    ]
    return [strip for strip in strips if strip.width() > 0 and strip.height() > 0]


# The tile marks: what a Layer 1 tile does under the walker, drawn in the
# overlays' own vector key -- thin fixed-weight strokes over a black
# understroke, the ants' two-line survivability worn by lines instead of
# boxes. A level tile's walk-off directions are small arrows at the cell's
# edges: white for the regular exit, and the secret exit in the test-run
# marks' orange, because that hue already means "the secret exit" here.
WALK_CLEAR_COLOR = QColor(0xFF, 0xFF, 0xFF)
WALK_SECRET_COLOR = SECRET_MARK_COLOR

# The path hues, the warp wedge's magenta and the two stroke weights are the
# tile palette's as well, so they live in `world_marks` -- one key, worn here
# over the map and there over the thumbnails.

# A level cell carries two readouts, and they are told apart by corner and by
# colour rather than by being read. The **level number** is the identity of the
# thing -- what every other part of the editor calls it, and what a reader is
# looking for when they scan the map -- so it takes the top-left corner a screen
# number takes, in the screen notes' orange. The **event** its clear fires is a
# fact about the cell rather than its name, so it sits in the opposite corner in
# a quiet grey, present for whoever is tracing the event chain and out of the way
# of everyone else.
LEVEL_LABEL_COLOR = SCREEN_NOTE_COLOR
EVENT_LABEL_COLOR = QColor(0x50, 0x50, 0x50, 0xD6)


class _WorldFloat(FloatController[Selection, WorldMap]):
    """What the world map has in hand.

    The mode's answers for
    :class:`~shiny_mushroom.tile_clipboard.FloatController`, over whichever of
    the three grids that can float the float is on: :attr:`kind` says which,
    and means nothing while nothing floats.

    A Layer 1 float carries the **repoint** inside its one step: every settle
    re-derives ``repointed(base, moved)``, so the per-level tables follow the
    tiles at every position the float ever holds -- a save mid-float is as
    consistent as any commit -- and one undo takes tiles and tables back
    together, exactly as :meth:`OverworldMode._commit` promises.
    """

    def __init__(self, mode: OverworldMode) -> None:
        super().__init__()
        self.mode = mode
        #: Which grid the float's numbers count in -- Layer 1 cells, Layer 2
        #: tiles or a stamp sheet's own.
        self.kind: Kind = Kind.TILES
        #: What the last settle's repoint moved, for :meth:`finished` to say.
        self._renumbers: dict[int, int] = {}

    def ready(self) -> bool:
        return self.mode.ready

    def document(self) -> WorldMap:
        return self.mode.document

    def selection(self) -> Selection:
        return self.mode.selection

    def select(self, selection: Selection) -> None:
        self.mode.selection = selection

    def nothing(self) -> Selection:
        return EMPTY_SELECTION

    def spot(self, x: int, y: int) -> int | None:
        return self.mode._spot_of(self.kind)(x, y)

    def bounds(self) -> tuple[int, int]:
        return self.mode._bounds_of(self.kind)

    def place(self, document: WorldMap, placed: dict[int, int]) -> WorldMap:
        if self.kind is Kind.CELLS:
            return document.placed(placed)
        if self.kind is Kind.SHEET:
            return document.stamp_words_placed(placed)
        return document.layer2_placed(placed)

    def covering(
        self, entries: tuple[tuple[int, int, int], ...], anchor: tuple[int, int]
    ) -> Selection:
        return Selection(self.kind, frozenset(landing(entries, anchor, self.spot)))

    def spots(self) -> list[tuple[int, int, int]]:
        document = self.mode.document
        if self.kind is Kind.CELLS:
            return [
                (*cell_at(index), document.tile(index))
                for index in sorted(self.mode.selection.keys)
            ]
        if self.kind is Kind.SHEET:
            return [
                (*sheet_tile(offset), document.stamp_word(offset))
                for offset in sorted(self.mode.selection.keys)
            ]
        spots = []
        for index in sorted(self.mode.selection.keys):
            tx, ty, submap_area = layer2_at(index)
            spots.append(
                (
                    tx,
                    ty + (_LAYER2_SIDE if submap_area else 0),
                    document.layer2_entry(index),
                )
            )
        return spots

    def show(self, previous: WorldMap, current: WorldMap) -> None:
        self.mode._redraw(previous, current)

    def holds(self, document: WorldMap) -> bool:
        history = self.mode.history
        return history is not None and history.level is document

    def carrying(self, selection: Selection) -> None:
        # The kind rides in the selection, which is the one place a world map
        # keeps it.
        self.kind = selection.kind

    def hovering(self, anchor: tuple[int, int]) -> None:
        self.mode._refresh_marks()
        self.mode._status(f"Floating selection -> {hexspot(*anchor)}")

    def moved(
        self, held: FloatingSelection[WorldMap], anchor: tuple[int, int]
    ) -> WorldMap:
        """The settle's document, with Layer 1's tables carried along.

        The repoint runs against ``base`` on **every** settle, so however many
        times the float moves, the tables always say what the tiles' *current*
        positions mean and never accumulate a stale renumber from a position
        it only passed through. The repoint cannot see that the carried levels
        are the same levels -- at the hole each looks deleted, at the landing
        fresh -- so :func:`~shiny_mushroom.overworld.carried_rows` follows it,
        moving each carried level's own rows to its new number.
        """
        moved = super().moved(held, anchor)
        self._renumbers = {}
        if self.kind is not Kind.CELLS:
            return moved
        moved, self._renumbers = repointed(held.base, moved)
        if held.holes:
            # A lift owes holes, and each hole names the level whose tile the
            # float carries: entries and holes were built side by side, so the
            # pairs are the identity the scan lacks. A paste owes none -- its
            # levels really are fresh.
            moved, carried = carried_rows(
                held.base,
                moved,
                [
                    (cell_index(hx, hy), cell_index(anchor[0] + dx, anchor[1] + dy))
                    for (hx, hy), (dx, dy, _) in zip(
                        held.holes, held.entries, strict=True
                    )
                    if _cell_spot(anchor[0] + dx, anchor[1] + dy) is not None
                ],
            )
            self._renumbers.update(carried)
        return moved

    def replace(
        self,
        held: FloatingSelection[WorldMap],
        document: WorldMap,
        mark: SelectionMark[Selection],
    ) -> None:
        assert self.mode.history is not None
        self.mode.history.replace(document, mark)

    def commit(
        self,
        held: FloatingSelection[WorldMap],
        document: WorldMap,
        mark: SelectionMark[Selection],
    ) -> bool:
        # The document is repointed already, so the raw commit and not
        # `OverworldMode._commit`, which would repoint the repointed tables a
        # second time.
        assert self.mode.history is not None
        self.mode.history.commit(document, mark)
        return True

    def finished(
        self,
        held: FloatingSelection[WorldMap],
        anchor: tuple[int, int],
        previous: WorldMap,
    ) -> None:
        if self._renumbers:
            self.mode._say_renumbered(self._renumbers)
        # The hover painted the tiles; what the repoint moved is rows, so this
        # catches up whatever reads them -- the events twin here, the
        # level-number labels through the settle the caller makes.
        self.mode._redraw(previous)
        self.mode._refresh_stamp_offers(held.base)

    def abandon(self, previous: WorldMap) -> None:
        self.mode._redraw(previous)

    def rewrite(
        self,
        held: FloatingSelection[WorldMap],
        document: WorldMap,
        mark: SelectionMark[Selection],
    ) -> None:
        # A Layer 1 hole is a level tile gone, so the repoint runs here too.
        assert self.mode.history is not None
        before = self.mode.document
        document, renumbers = repointed(held.base, document)
        self.mode.history.replace(document, mark)
        if renumbers:
            self.mode._say_renumbered(renumbers)
        self.mode._redraw(before)

    def write(
        self,
        held: FloatingSelection[WorldMap],
        document: WorldMap,
        mark: SelectionMark[Selection],
    ) -> None:
        self.mode._commit(document, mark)


class OverworldMode(QObject):
    """The world map's document, selection and gestures, behind the window."""

    def __init__(
        self,
        canvas: Canvas,
        view: CanvasView,
        properties: PropertiesDock,
        palette: TilePaletteDock,
        status: Callable[[str], None],
        changed: Callable[[], None],
    ) -> None:
        super().__init__()
        self._canvas = canvas
        self._view = view
        self._properties = properties
        self._palette = palette
        self._status = status
        #: Told after anything the window reflects elsewhere -- a commit, an
        #: undo, a save -- so action enablement and the title bar follow.
        self._changed = changed

        self._snapshot: OverworldSnapshot | None = None
        #: The block cache the framed map's palette draws from -- the shared
        #: submap page, and every offer the dock previews. Rebuilt per
        #: palette pick.
        self._painter: Blocks | None = None
        #: And the main map's, palette 0's, built once with the capture: the
        #: game only ever shows that page under its own colours, so framing a
        #: submap leaves it alone. See
        #: :class:`~shiny_mushroom.overworld.WorldPainters`.
        self._main_painter: Blocks | None = None
        self.history: History[WorldMap] | None = None
        self._shape: MapShape = STOCK_SHAPE
        self.selection: Selection = EMPTY_SELECTION
        self._marquee: tuple[QPoint, QPoint] | None = None
        self._marquee_from: frozenset[int] = frozenset()
        self._marquee_kind: Kind = Kind.CELLS
        #: What is in hand, exactly as the palette armed it, and where the
        #: pointer is offering to put it -- a cell index for a Layer 1 tile, a
        #: Layer 2 entry index for a word, a pixel pair for a sprite.
        self._placing: Layer1Tile | Layer2Word | SpritePick | None = None
        self._placing_at: int | tuple[int, int] | None = None
        #: The armed thing's picture, for the ghost. A Layer 1 tile reuses its
        #: palette thumbnail; a Layer 2 word is rendered when armed.
        self._placing_image: QImage | None = None
        #: A paint stroke in progress: the document plus everything the drag
        #: has crossed, committed whole when the button comes up.
        self._stroke: WorldMap | None = None
        #: A tile paste or lift still in hand -- committed, but the one edit
        #: a drag may move, each move rewriting its single history step. See
        #: :class:`_WorldFloat`.
        self._hand = _WorldFloat(self)
        self._picture = WorldPicture()
        #: One stamp sheet drawn whole, when the palette asked for it on the
        #: canvas. The map's picture is kept beside it rather than dropped,
        #: so coming back costs a ``set_image`` and no render.
        self._sheet = SheetPicture()
        self._sheet_up = False
        #: Whether the palette's tab was a stamp tab when it last changed --
        #: what tells leaving the stamps from a move between two other
        #: layers, which the events view has no business following. See
        #: :meth:`_tab_changed`.
        self._on_stamps = palette.tab in STAMP_TABS
        self._thumbnails: list[QImage] = []
        #: Whether what the dock offers still shows the colours the map does --
        #: see :meth:`recolour`, which is the one thing that lets them part.
        self._offers_stale = False
        #: The replayed parts the events twin was last drawn from, so an edit
        #: patches only what the replay disagrees about. ``None`` whenever the
        #: twin does not exist.
        self._replayed: tuple[bytes, bytes] | None = None
        #: The one event the events view is focusing, and the 8x8 tiles it owns
        #: on the shown picture -- everything else washes out while a focus
        #: is held. ``None`` shows every event undimmed.
        self._focus_event: int | None = None
        self._focus_tiles: tuple[int, ...] = ()
        #: The focused event's conditional targets that miss on this
        #: map, tinted rather than lit -- see `_refocus`.
        self._focus_missed: tuple[int, ...] = ()
        #: The entry-table row the focused event's animation preview is
        #: stopped after, or ``None`` with no preview up -- see
        #: :meth:`preview_event_step`.
        self._preview_step: int | None = None
        #: A sprite marker mid-drag, committed once at release.
        self._sprite_drag: SpriteDrag | None = None
        #: A stamp placement mid-drag, committed once at release.
        self._stamp_drag: StampDrag | None = None
        #: A warp or path-exit trigger mid-drag, committed once at release.
        self._transfer_drag: TransferDrag | None = None
        #: A silent-tile slot mid-drag, committed once at release.
        self._silent_drag: SilentDrag | None = None
        #: A destroyed-tile slot mid-drag, committed once at release.
        self._destroy_drag: DestroyDrag | None = None
        #: A substitution row mid-drag, committed once at release.
        self._subs_drag: SubsDrag | None = None
        #: Which entry-table row the last stamp click landed on, as
        #: ``(event, entry within the event)`` -- what the panel's placement
        #: fields act on. A sheet block can be stamped at many places, so the
        #: selection's sheet offset alone cannot say which row was meant;
        #: the click can. ``None`` whenever no single row was named.
        #: Which entry-table rows the last stamp gesture named, as
        #: ``(event, entry)``. A click notes the one it hit and a box the
        #: ones it caught: a stamp selection's keys are *sheet bytes*, which
        #: cannot say which placement of a repeated block was meant, so the
        #: gesture's own answer is kept beside them -- see
        #: :meth:`_held_placements`.
        self._stamp_hits: frozenset[tuple[int, int]] = frozenset()
        #: A destination pick in flight: which transfer ("warp" or "exit"),
        #: its table entry, and the trigger cell whose panel started it. The
        #: next click on a cell retargets the entry there; Escape or a right
        #: click puts the gesture down like anything else in hand.
        self._picking_link: tuple[str, int, int] | None = None
        #: Test-run state, held for the session like the level editor's test
        #: start: where a middle click put the spawn (a cell index, or None
        #: for the game's default), and which levels are marked complete --
        #: cell index to "the secret exit too". Cells rather than translevels,
        #: because an edit renumbers translevels under the marks.
        self.test_spawn: int | None = None
        self.completed: dict[int, bool] = {}
        #: Which map is framed -- the whole picture stays drawn, and the
        #: chosen map's region wears the frame and, for a submap, the camera
        #: hint -- and which submap's palette the picture is drawn with.
        #: Separate, because the palette can be picked on its own to preview
        #: a map under other colours.
        self._submap = 0
        self._region = QRect(*submap_region(0))
        self._palette_index = 0
        #: Whether a gesture frames for itself: with the flag up, a click or
        #: grab on another map's ground switches the frame (and so the
        #: palette) to that map before the gesture lands.
        self._auto_select = True
        #: Whether the sprite markers are drawn at all -- the sprite layer's
        #: own toggle, beside the two tile layers'.
        self._show_sprites = True
        #: Whether the framing marks are drawn -- the framed map's box, and
        #: a submap's border mask -- and whether the tile marks are. View
        #: toggles like the layers', held per session like them. The tile
        #: marks start down: they cover the map they describe, and are asked
        #: for when a path is the question rather than the picture.
        self._show_frame = True
        self._show_tile_marks = False
        #: The markers' pictures and boxes, per sprite number: the captured
        #: artwork where the cartridge answered one, drawn under the framed
        #: map's palette. A number outside these keeps the numbered glyph and
        #: its one-block box.
        self._sprite_images: dict[int, tuple[QImage, QPoint]] = {}
        self._sprite_boxes: dict[int, QRect] = {}
        #: The same artwork under palette 0, for the copies standing on the
        #: main map's page -- the same dict object while the main map is
        #: framed. See :meth:`_build_sprite_visuals`.
        self._main_sprite_images: dict[int, tuple[QImage, QPoint]] = {}
        #: The player's captured figure and its corner offset, for the spawn
        #: marker -- decoded once per capture, against the capture's own
        #: memories rather than the palette in effect, exactly as the level's
        #: marker is. ``None`` keeps the green box as the spawn mark.
        self._player_image: tuple[QImage, QPoint] | None = None
        #: The mode's own clipboard, like the window's for the level: what
        #: was copied outlives the selection it came from, and a reload. Only
        #: closing the cartridge drops it.
        self.clipboard: WorldClipboard | TransferCopy | None = None
        #: Where the pointer last was over the picture, for a paste to land
        #: under it. ``None`` whenever it is off the canvas.
        self._cursor: QPoint | None = None
        #: Whether a properties-panel edit is mid-commit -- see
        #: :meth:`commit_field` for why the describe must wait it out.
        self._panel_commit = False
        #: How a row added to one of the growable tables is priced against
        #: the cartridge's room -- the window's, which holds the project and
        #: its build; ``None`` while there is neither, when the stock
        #: cartridge's shape is all the mode can hold a table to.
        self.price_room: RoomPricer | None = None
        #: Where the Level picker on a level cell gets its rows -- the
        #: window's, the same list the toolbar's Level box is filled from;
        #: ``None`` while there is no cartridge tree to name them, when the
        #: picker falls back to bare numbers.
        self.level_choices: LevelPicker | None = None
        #: What a level cell's Level Load Path button asks for -- the
        #: window's, since the mode owns no windows. ``None`` leaves the
        #: button dead, which is what a headless test wiring none gets.
        self.open_load_path: Callable[[], None] | None = None
        #: What a level cell's Open Level button asks for -- the window's for
        #: the same reason, since the load replaces the document the canvas
        #: holds. ``None`` leaves the button dead, as above.
        self.open_level: Callable[[int], None] | None = None

        palette.armed.connect(self._armed)
        palette.tab_changed.connect(self._tab_changed)

    # -- state the window reads ----------------------------------------------

    @property
    def ready(self) -> bool:
        """Whether a map has been shown and gestures mean anything."""
        return self.history is not None

    @property
    def levels(self) -> tuple[Choice, ...]:
        """The rows a level picker offers, or empty with no tree behind it --
        what a :class:`~shiny_mushroom.overworld_fields.CellWalk` carries."""
        return self.level_choices() if self.level_choices is not None else ()

    @property
    def document(self) -> WorldMap:
        assert self.history is not None
        return self.history.level

    @property
    def snapshot(self) -> OverworldSnapshot | None:
        """The capture the mode stands on -- what a test run reads its ROM
        tables from. None until a map has been shown."""
        return self._snapshot

    @property
    def edited(self) -> bool:
        """Whether the map differs from what was loaded or last saved."""
        return self.history is not None and self.history.edited

    @property
    def image(self) -> QImage | None:
        """The picture as it stands -- what entering the mode shows: the
        sheet while one is up, the map otherwise."""
        if self._sheet_up and self._sheet.image is not None:
            return self._sheet.image
        return self._picture.image

    @property
    def shown_tiles(self) -> bytes:
        """The Layer 1 tilemap the canvas is showing: the replayed one while
        the events view is up, the document's otherwise.

        The one authority for every system that reads tiles beside the
        picture -- the tile marks, the status line -- so nothing describes a
        tile the pixels are not showing. Layer 2's twin authority is
        :meth:`_stamps_shot`. The translevels stay the document's on either
        view: the game scans them from the pristine tilemap before any event
        replays.
        """
        if self._picture.showing_events and self._replayed is not None:
            return self._replayed[0]
        return self.document.tiles

    # -- showing a map --------------------------------------------------------

    def show(
        self,
        snapshot: OverworldSnapshot,
        tiles: bytes | None = None,
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
        warps: bytes | None = None,
        exits: bytes | None = None,
        shape: MapShape | None = None,
        sprite_disable: Sequence[int] | None = None,
    ) -> None:
        """Take a snapshot and stand the mode up on it.

        The optional parts are the project's saved ones when there are any,
        so a saved edit reopens as the edit and the history's base is what is
        on disk -- the snapshot's own parts are the cartridge's. The stamp
        pair travels together: a caller with only half falls back to the
        snapshot for both, since the document refuses a lone half.

        ``shape`` is how many entries this cartridge's tables hold -- the
        window's, resolved from the base its ROM was built on. Every part is
        checked against it, so a capture or a saved fragment that does not fit
        this cartridge is refused here instead of being edited and written
        back short. ``None`` lets the parts decide, which is all a synthetic
        capture can claim.
        """
        self._snapshot = snapshot
        #: The cartridge's shape, kept for what the document's own cannot say:
        #: which tables grow on this cartridge (:attr:`MapShape.grows`) -- a
        #: synthetic capture's is the stock one.
        self._shape = shape if shape is not None else STOCK_SHAPE
        # Palette 0 explicitly rather than the capture's own CGRAM: the map
        # opens framed on the main map, and that is the palette every later
        # pick of it resolves to.
        cgrams = snapshot.submap_cgram or (snapshot.cgram,)
        self._main_painter = world_blocks(replace(snapshot, cgram=cgrams[0]))
        self._painter = self._main_painter
        if stamps is None or stamp_props is None:
            stamps, stamp_props = snapshot.event_stamps, snapshot.event_stamp_props
        if sprites is None:
            sprites = snapshot.sprite_slots
        # Whether the capture carried the table at all, not whether it is the
        # stock length: how many entries this cartridge has is what the capture
        # just read, and `WorldMap.read` is where the two are held to `shape`.
        if directions is None and snapshot.level_directions:
            directions = snapshot.level_directions
        if level_events is None and snapshot.level_events:
            level_events = snapshot.level_events
        if events is None and snapshot.event_entries and snapshot.event_pointers:
            events = decoded_placements(snapshot.event_entries, snapshot.event_pointers)
        if silent is None and snapshot.silent_tiles:
            silent = snapshot.silent_tiles
        # The substitution's two tables travel together, like the stamp pair:
        # the document refuses a lone half, so a caller with only one falls
        # back to the capture for both -- and a capture that answered only
        # half leaves the part absent rather than handing the document one.
        if subs is None or swaps is None:
            subs = snapshot.event_l1_locations
            swaps = snapshot.event_l1_from + snapshot.event_l1_to
        if not subs or not swaps:
            subs = swaps = b""
        if destroy is None:
            destroy = destroy_part(
                snapshot.destroy_before,
                snapshot.destroy_top,
                snapshot.destroy_bottom,
                snapshot.destroy_locations,
                snapshot.destroy_events,
                (shape or STOCK_SHAPE).destroy,
            )
        if warps is None:
            warps = warps_part(
                snapshot.warp_trigger_columns,
                snapshot.warp_trigger_rows,
                snapshot.warp_landings_x,
                snapshot.warp_landings_y,
            )
        if exits is None:
            exits = exits_part(
                snapshot.exit_triggers,
                snapshot.exit_landings,
                snapshot.exit_landing_cells,
            )
        document = WorldMap.read(
            tiles if tiles is not None else snapshot.tiles,
            layer2=layer2 if layer2 is not None else snapshot.layer2,
            # `or None`: a synthetic snapshot with no event capture leaves the
            # part absent rather than handing the document an empty pair.
            stamps=stamps or None,
            stamp_props=stamp_props or None,
            sprites=sprites or None,
            directions=directions or None,
            level_events=level_events or None,
            # No snapshot fallback: whether the captured words are the
            # editable format is a fact about the *target*, which the window
            # decides -- the J build's names are its own.
            level_names=level_names or None,
            translevel_levels=translevel_levels or None,
            events=events or None,
            silent=silent or None,
            destroy=destroy or None,
            subs=subs or None,
            swaps=swaps or None,
            sprite_disable=sprite_disable
            if sprite_disable is not None
            else snapshot.sprite_submap_disable or None,
            sprite_boo_offsets=boo_offsets(
                snapshot.sprite_boo_x_offsets, snapshot.sprite_boo_y_offsets
            )
            or None,
            sprite_smoke_positions=smoke_positions(
                snapshot.sprite_smoke_x_positions, snapshot.sprite_smoke_y_positions
            )
            or None,
            warps=warps,
            exits=exits,
            shape=shape,
        )
        self.history = History(document)
        self.selection = EMPTY_SELECTION
        self._marquee = None
        self._placing = None
        self._placing_at = None
        self._placing_image = None
        self._stroke = None
        self._hand.land()
        self._sprite_drag = None
        self._stamp_drag = None
        self._transfer_drag = None
        self._silent_drag = None
        self._destroy_drag = None
        self._subs_drag = None
        self._stamp_hits = frozenset()
        self._picking_link = None
        self._submap = 0
        self._region = QRect(*submap_region(0))
        self._palette_index = 0
        self._show_sprites = True
        self._show_frame = True
        self._show_tile_marks = False
        self._focus_event = None
        self._focus_tiles = ()
        self._focus_missed = ()
        self._preview_step = None

        self._replayed = None
        self._picture.render(
            snapshot, document.tiles, document.layer2 or None, self._painters
        )
        if self._picture.showing_events:
            # The view survives a reload: the twin was just invalidated, so
            # it is drawn afresh from the new capture's replay.
            self._render_events()
        self._thumbnails = [
            raster_to_image(raster)
            for raster in tile_thumbnails(snapshot, painter=self._painter)
        ]
        # A new map is a new document, and the sheet picture was of the old
        # one's bytes: it goes down with them.
        self._sheet.forget()
        self._sheet_up = False
        self._palette.set_tiles(self._thumbnails)
        self._palette.set_layer2(self._draw_layer2)
        self._palette.set_stamps(self._draw_stamps if self.document.stamps else None)
        self._palette.set_sheet_editing(False)
        self._build_sprite_visuals()
        self._player_image = player_marker_image(snapshot.player())
        self._palette.set_sprites(self._sprite_offers())
        self._palette.set_transfers(self._transfer_offers())
        self.activate()
        self._changed()

    def forget(self) -> None:
        """Drop the held map: the cartridge it came from is going away.

        The palette empties too -- its thumbnails were drawn from that
        cartridge's graphics. The canvas is left alone: whoever closes the
        cartridge decides what it shows next.
        """
        self._snapshot = None
        self._painter = None
        self._main_painter = None
        self.history = None
        self.selection = EMPTY_SELECTION
        self._marquee = None
        self._placing = None
        self._placing_at = None
        self._placing_image = None
        self._stroke = None
        self._hand.land()
        self._sprite_drag = None
        self._stamp_drag = None
        self._transfer_drag = None
        self._silent_drag = None
        self._destroy_drag = None
        self._subs_drag = None
        self._stamp_hits = frozenset()
        self._picking_link = None
        self.test_spawn = None
        self.completed = {}
        self._submap = 0
        self._region = QRect(*submap_region(0))
        self._palette_index = 0
        self._show_sprites = True
        self._show_frame = True
        self._show_tile_marks = False
        self.clipboard = None
        self._cursor = None
        self._picture.forget()
        self._sheet.forget()
        self._sheet_up = False
        self._replayed = None
        self._focus_event = None
        self._focus_tiles = ()
        self._focus_missed = ()
        self._preview_step = None
        self._thumbnails = []
        self._sprite_images = {}
        self._main_sprite_images = {}
        self._sprite_boxes = {}
        self._player_image = None
        self._palette.set_tiles([])
        self._palette.set_layer2(None)
        self._palette.set_stamps(None)
        self._palette.set_sheet_editing(False)
        self._palette.set_sprites([])
        self._palette.set_transfers([])
        self._view.set_hover_cursor(None)

    def activate(self) -> None:
        """Put this mode's picture and marks on the canvas.

        The window calls it on entering the mode; :meth:`show` calls it because
        showing a map *is* entering. The canvas is shared with the level, so
        nothing here runs while the mode is dormant -- the window routes
        gestures only while it is up.
        """
        if self._sheet_up and self._sheet.image is not None:
            _across, _down, side = sheet_blocks(small=self._sheet.small)
            self._canvas.set_image(self._sheet.image)
            self._canvas.set_screen_size(QSize(side * TILE, side * TILE), labels=False)
            self._canvas.set_screen_notes({})
        elif self._picture.image is not None:
            self._canvas.set_image(self._picture.image)
            self._canvas.set_screen_size(PAGE)
            self._canvas.set_screen_notes(self._screen_notes())
        else:
            return
        self._refresh_marks()
        self._describe_selection()

    # -- the events view -------------------------------------------------------

    @property
    def events_view(self) -> bool:
        """Whether the canvas shows the map with every event replayed."""
        return self._picture.showing_events

    def set_events_view(self, on: bool) -> None:
        """Show the map as an overworld load would build it -- every event
        replayed, or with a focus that one event alone -- or the base map
        the document edits.

        Every event rather than a save file's subset, because the capture
        never loads a save: a per-save view would be pretence; the focus is
        the deliberate exception, one event isolated by hand. Leaving the
        view puts down a stamp selection with it -- its keys mean nothing on
        the base map.
        """
        if not self.ready or on == self._picture.showing_events:
            return
        if not on:
            # The focus is a statement about the replayed picture, so it goes
            # down with the view, and the step preview with the focus.
            self._focus_event = None
            self._focus_tiles = ()
            self._focus_missed = ()
            self._preview_step = None
        if on and not self._picture.has_events:
            self._render_events()
        elif on:
            # The twin may still hold another focus's replay -- bring it
            # back to the set this showing replays.
            self._retwin(self.document)
        image = self._picture.show_events(on)
        if image is not None:
            self._canvas.set_image(image)
        if not on and self.selection.kind in EVENTS_VIEW_KINDS and self.selection:
            self.selection = EMPTY_SELECTION
            self._settle_selection()
        else:
            # The tile marks read the shown tilemap, which the toggle just
            # swapped from under them.
            self._refresh_marks()
        self._changed()

    @property
    def focus_event(self) -> int | None:
        """The one event the events view is focusing, or ``None`` for all."""
        return self._focus_event

    def set_focus_event(self, event: int | None) -> None:
        """Show ``event`` alone on the events view, or back to every event.

        The view replays only the focused event, every other one left
        unrun, and everything the event itself does not touch washes out --
        so which tiles belong to it reads straight off the picture.
        Focusing turns the events view on -- the focus is a statement about
        the replayed picture -- and leaving the view puts the focus down.
        """
        if not self.ready:
            return
        if event is not None and not 0 <= event < REPLAYED_EVENTS:
            raise ValueError(f"no event {event:#x} to focus")
        if event == self._focus_event:
            if event is not None and not self._picture.showing_events:
                self.set_events_view(True)
            return
        self._focus_event = event
        # The step preview is a reading of one event's animation; it does
        # not survive the focus moving to another.
        self._preview_step = None
        if event is not None and not self._picture.showing_events:
            # The focus is set first, so the view goes up already replaying
            # the focused event alone.
            self.set_events_view(True)
            self._refocus()
        elif self._picture.has_events:
            if self._retwin(self.document) and self._picture.image is not None:
                self._canvas.set_image(self._picture.image)
        else:
            self._refocus()
        if event is None:
            self._status("Showing every event")
        else:
            count = len(self._focus_tiles)
            said = (
                f"Focusing event {hexnum(event)} alone -- "
                f"{count} tile{'' if count == 1 else 's'} on the shown map"
            )
            if self._focus_missed:
                said += "; the red tint is a conditional write that misses here"
            self._status(said)
        self._refresh_marks()
        self._changed()

    def _shown_events(self) -> tuple[int, ...] | range:
        """The events the view replays: every one, or the focused event
        alone, the others left unrun."""
        if self._focus_event is None:
            return range(REPLAYED_EVENTS)
        return (self._focus_event,)

    @property
    def preview_step(self) -> int | None:
        """The entry-table row the animation preview is stopped after, or
        ``None`` with no preview up."""
        return self._preview_step

    def preview_event_step(self, entry: int | None) -> None:
        """Freeze the focused event's reveal animation just after row
        ``entry`` lands, or put the preview down with ``None``.

        The twin shows what the screen shows at that moment of the reveal:
        the demolition the event writes at its start, then the rows up to
        and including ``entry`` -- the later rows, the Layer 1 tile swap and
        the silent tiles, which the game runs after the animation, still to
        come. Only the replayed picture changes: the focus wash, the stamp
        hit-tests and the use counts stay the whole event's, because the
        preview is a reading of the animation rather than a different shown
        set. Nothing to preview without a focused event.
        """
        if not self.ready:
            return
        if entry is not None and (
            self._focus_event is None
            or not 0 <= self._focus_event < len(self.document.events)
        ):
            return
        if entry == self._preview_step:
            return
        self._preview_step = entry
        if (
            self._picture.has_events
            and self._retwin(self.document)
            and self._picture.image is not None
        ):
            self._canvas.set_image(self._picture.image)
        # The tile marks read the shown tilemap, which the preview swaps.
        self._refresh_marks()
        if entry is None:
            if self._focus_event is not None:
                self._status(f"Event {hexnum(self._focus_event)} whole again")
        else:
            total = len(self.document.events[self._focus_event])
            self._status(
                f"Event {hexnum(self._focus_event)} stopped after reveal "
                f"{entry + 1} of {total} -- later rows, the tile swap and "
                f"the silent tiles still to come"
            )

    def _refocus(self, document: WorldMap | None = None) -> None:
        """Recompute the tiles the focused event owns on the shown picture
        -- whole stamps, not just the bytes that change the base."""
        if self._focus_event is None:
            self._focus_tiles = ()
            self._focus_missed = ()
            return
        assert self._snapshot is not None
        held = document if document is not None else self.document
        self._focus_tiles = event_highlight_tiles(
            held, self._snapshot, self._focus_event
        )
        lit = set(self._focus_tiles)
        # The lit tiles win where the two overlap: a stamped tile the event
        # owns outright is not also a refusal.
        self._focus_missed = tuple(
            index
            for index in event_missed_tiles(held, self._snapshot, self._focus_event)
            if index not in lit
        )

    def _replay_shown(self, source: WorldMap) -> tuple[bytes, bytes]:
        """The twin's parts: the shown events replayed whole, or -- with a
        step preview up -- the focused event's animation stopped early."""
        assert self._snapshot is not None
        if self._focus_event is not None and self._preview_step is not None:
            return replayed_steps(
                source, self._snapshot, self._focus_event, self._preview_step + 1
            )
        return replayed(source, self._snapshot, self._shown_events())

    def _render_events(self) -> None:
        """Draw the events twin from the document as it stands."""
        assert self._snapshot is not None
        tiles, layer2 = self._replay_shown(self.document)
        self._replayed = (tiles, layer2)
        self._picture.render_events(
            self._snapshot, tiles, layer2 or None, self._painters
        )

    def _retwin(self, source: WorldMap) -> bool:
        """Bring the events twin and the focus wash up to date with
        ``source`` and the shown event set; ``True`` when pixels changed.

        A fresh replay diffed against the last, patched cell by cell -- which
        is what lets a stamp edit, whose base cells never change, repaint
        every place the stamp shows, and a focus switch repaint only what the
        events it added or dropped touch.
        """
        assert self._snapshot is not None
        fresh = self._replay_shown(source)
        stale, self._replayed = self._replayed, fresh
        # The focus follows the same document the twin was patched from,
        # so the wash never outlines a stale replay.
        self._refocus(source)
        twin_cells = self._parts_between(stale, fresh) if stale else []
        if not twin_cells:
            return False
        self._picture.patch_events(
            self._snapshot,
            fresh[0],
            fresh[1] or None,
            twin_cells,
            self._painters,
        )
        return True

    # -- one sheet on the canvas ----------------------------------------------

    @property
    def sheet_view(self) -> bool:
        """Whether the canvas is showing a stamp sheet instead of the map."""
        return self._sheet_up

    @property
    def sheet_small(self) -> bool:
        """Which sheet is up: the 2x2 sheet when true, the 6x6 otherwise.
        Meaningless with the map on the canvas."""
        return self._sheet.small

    def set_sheet_view(self, on: bool, small: bool = False) -> None:
        """Put one whole stamp sheet on the canvas, or give the canvas back
        to the map.

        The same document under a different picture -- one history, one
        dirty flag, one Ctrl+S -- so the swap commits nothing and an undo
        reaches across it. What does change is what the pixels *are*: the
        map's frame, tile marks, sprite markers and event set all describe
        cells that are not on the canvas, so they stay behind with it, and a
        selection made on one picture is put down rather than carried to
        the other, whose grid its keys mean nothing in.

        The block grid rides the canvas's screen grid: a sheet's cells are
        its blocks, drawn as boundaries and nothing more -- what a block is
        is said by the status line and the properties heading, over the
        artwork the eye is here for.
        """
        if not self.ready or not self.document.stamps:
            on = False
        if on == self._sheet_up and (not on or small == self._sheet.small):
            return
        # A tool, a float and a selection all belong to the picture they were
        # taken up over: the sheet's grid is not the map's, and a key means
        # nothing across the swap.
        self.stop_placing()
        self._hand.land()
        self.selection = EMPTY_SELECTION
        self._marquee = None
        self._stamp_hits = frozenset()
        self._cursor = None
        self._sheet_up = on
        if on:
            assert self._snapshot is not None
            self._canvas.set_image(
                self._sheet.render(
                    self.document, self._snapshot, small=small, painter=self._painter
                )
            )
            _across, _down, side = sheet_blocks(small=small)
            self._canvas.set_screen_size(QSize(side * TILE, side * TILE), labels=False)
            self._canvas.set_screen_notes({})
            self._status(
                f"Drawing the {side}x{side} stamp sheet -- "
                "every block that uses a tile changes with it"
            )
        else:
            self._sheet.forget()
            # Whatever was drawn on the sheet shows wherever its block is
            # stamped, and the twin was left alone while the map was off the
            # canvas: one replay brings it back to the document.
            if self._picture.has_events:
                self._retwin(self.document)
            if self._picture.image is not None:
                self._canvas.set_image(self._picture.image)
            self._canvas.set_screen_size(PAGE)
            self._canvas.set_screen_notes(self._screen_notes())
        self._palette.set_sheet_editing(on)
        self._settle_selection()

    def _sheet_of(self, point: QPoint) -> int | None:
        """The sheet offset under ``point`` on the sheet picture."""
        return self._sheet_spot(point.x() // TILE, point.y() // TILE)

    def _sheet_spot(self, tx: int, ty: int) -> int | None:
        """The shown sheet's addressing for a paste's
        :func:`~shiny_mushroom.tile_clipboard.landing`."""
        return sheet_spot(tx, ty, small=self._sheet.small)

    # -- layers, submaps and palettes -----------------------------------------

    @property
    def layer1_shown(self) -> bool:
        return self._picture.layer1_shown

    @property
    def layer2_shown(self) -> bool:
        return self._picture.layer2_shown

    def set_layer1_shown(self, on: bool) -> None:
        """Draw the map with Layer 1 in or out of the picture."""
        self._set_layers(on, self._picture.layer2_shown)

    def set_layer2_shown(self, on: bool) -> None:
        """Draw the map with Layer 2 in or out of the picture."""
        self._set_layers(self._picture.layer1_shown, on)

    def _set_layers(self, layer1: bool, layer2: bool) -> None:
        if not self.ready or self._snapshot is None:
            return
        if (layer1, layer2) == (self._picture.layer1_shown, self._picture.layer2_shown):
            return
        self._picture.set_layers(layer1, layer2)
        self._redraw_everything()

    @property
    def submap(self) -> int:
        """The submap the toolbar last framed."""
        return self._submap

    @property
    def palette_index(self) -> int:
        """Which submap's palette the picture is drawn with."""
        return self._palette_index

    @property
    def _painters(self) -> WorldPainters:
        """The pair the picture is drawn from: the main map's page under
        palette 0, the shared submap page under the framed submap's."""
        assert self._main_painter is not None and self._painter is not None
        return WorldPainters(self._main_painter, self._painter)

    @property
    def palette_cgrams(self) -> tuple[bytes, ...]:
        """One CGRAM per submap when the capture carried them; the base
        capture's alone otherwise, so index 0 always answers."""
        if self._snapshot is None:
            return ()
        return self._snapshot.submap_cgram or (self._snapshot.cgram,)

    def go_to_submap(self, submap: int) -> None:
        """Frame ``submap``, under its own palette.

        The whole stacked picture stays drawn and editable -- every
        coordinate stays what it was, the selection survives, and every
        sprite marker keeps drawing. Framing is the main map's frame box,
        or a submap's border mask, over the chosen map's region, the view
        centred on it, and the palette following.
        """
        if not self.ready:
            return
        self._submap = submap
        self._region = QRect(*submap_region(submap))
        self.set_palette(min(submap, len(self.palette_cgrams) - 1))
        self._view.center_on(self._region.center())
        # The frame moved, even when the palette pick redrew nothing.
        self._refresh_marks()

    @property
    def auto_select(self) -> bool:
        """Whether gestures frame the map they land on."""
        return self._auto_select

    def set_auto_select(self, on: bool) -> None:
        self._auto_select = on

    def _auto_frame(self, point: QPoint) -> None:
        """Frame the map whose ground ``point`` is on, palette following and
        the view staying put -- the gesture is already looking there.

        Only while nothing is in hand: framing brings the palette, and a
        palette switch puts the hand down (see :meth:`set_palette`), which
        would cost a placement its brush mid-gesture. And only over the map:
        a point on a sheet names a sheet entry, not a place on any submap.
        """
        if self._sheet_up or not self._auto_select or self._placing is not None:
            return
        if point.y() < PAGE_ROWS * BLOCK:
            submap = 0
        else:
            submap = submap_at(point.x(), point.y() - PAGE_ROWS * BLOCK)
        if submap == self._submap:
            return
        self._submap = submap
        self._region = QRect(*submap_region(submap))
        self.set_palette(min(submap, len(self.palette_cgrams) - 1))
        self._refresh_marks()
        # The window's bar shows the framed map; told so it follows.
        self._changed()

    @property
    def sprites_shown(self) -> bool:
        return self._show_sprites

    def set_sprites_shown(self, on: bool) -> None:
        """Draw the sprite markers, or put the whole sprite layer away.

        An overlay change only -- the markers sit in front of the picture --
        so no re-render. A held sprite selection goes down with the layer:
        ants around something invisible describe nothing.
        """
        if not self.ready or on == self._show_sprites:
            return
        self._show_sprites = on
        if not on and self.selection.kind is Kind.SPRITES and self.selection:
            self.selection = EMPTY_SELECTION
            self._settle_selection()
            return
        self._refresh_marks()

    @property
    def frame_shown(self) -> bool:
        return self._show_frame

    def set_frame_shown(self, on: bool) -> None:
        """Draw the framing marks -- the framed map's box and a submap's
        border mask -- or put them away. Overlays only, so no re-render."""
        if not self.ready or on == self._show_frame:
            return
        self._show_frame = on
        self._refresh_marks()

    @property
    def tile_marks_shown(self) -> bool:
        return self._show_tile_marks

    def set_tile_marks_shown(self, on: bool) -> None:
        """Draw the tile marks -- every level tile's walk arrows, every
        path tile's step, the warp boxes -- or put them away. Overlays
        only, like the frame."""
        if not self.ready or on == self._show_tile_marks:
            return
        self._show_tile_marks = on
        self._refresh_marks()

    @staticmethod
    def _screen_notes() -> dict[int, str]:
        """The page labels: the two pages named for what they are. The
        shared page stays "Submaps" whichever submap is framed -- all seven
        live on it, and the frame box already says which one is picked."""
        return {0: SUBMAP_NAMES[0], 1: "Submaps"}

    def set_palette(self, index: int) -> None:
        """Draw everything with submap ``index``'s palette.

        Everything, not just the map: the dock's thumbnails are offers of
        what a placement will draw, so they follow the palette too. What is
        armed is put down first -- its ghost was drawn under the old colours,
        and the dock's refill drops its held row anyway.
        """
        if not self.ready or self._snapshot is None:
            return
        cgrams = self.palette_cgrams
        index = max(0, min(index, len(cgrams) - 1))
        if index == self._palette_index:
            return
        self._palette_index = index
        self.stop_placing()
        # Only the shared page's cache moves: the main map keeps palette 0's,
        # which is the one the game ever shows it under -- see
        # :class:`~shiny_mushroom.overworld.WorldPainters`. Index 0 reuses
        # that cache rather than decoding the same graphics twice.
        self._painter = (
            self._main_painter
            if index == 0
            else world_blocks(replace(self._snapshot, cgram=cgrams[index]))
        )
        self._repaint_submap_page()
        self._refresh_offers()

    def recolour(self, snapshot: OverworldSnapshot, offers: bool = True) -> None:
        """Show the map already loaded under ``snapshot``'s colours.

        What a palette edit does to the world map: the document, the history
        and the selection are untouched -- only the CGRAMs the picture is
        coloured from have moved -- so this is a redraw and not a reload.

        Both painters go, unlike a palette *pick*: a colour edit can move the
        main map's page as well as the framed submap's, so there is no half of
        the picture that is known not to have changed.

        ``offers`` is what a **live preview** turns off. Everything the dock
        offers -- a thumbnail per tile, the sprite artwork, the 8x8 sheet -- is
        redrawn by :meth:`_refresh_offers`, and a colour dragged in the picker
        asks for this eight times a second. The map itself follows every frame;
        the offers catch up when the pick is finished, which is the one moment
        anybody looks at them.
        """
        if self._snapshot is None:
            return
        if snapshot is not self._snapshot:
            self._snapshot = snapshot
            cgrams = self.palette_cgrams
            index = max(0, min(self._palette_index, len(cgrams) - 1))
            self._main_painter = world_blocks(replace(snapshot, cgram=cgrams[0]))
            self._painter = (
                self._main_painter
                if index == 0
                else world_blocks(replace(snapshot, cgram=cgrams[index]))
            )
            self._player_image = player_marker_image(snapshot.player())
            self._redraw_everything()
            self._offers_stale = True
        # Asked even where the colours did not move, because a drag that ends
        # on the frame it started leaves the offers owing a redraw all the same.
        if offers and self._offers_stale:
            self._refresh_offers()
            self._offers_stale = False

    def _refresh_offers(self) -> None:
        """Redraw everything the dock offers, under the palette now in force.

        The thumbnails are offers of what a placement will draw, so they follow
        the colours exactly as the map does -- and so do the sprite markers and
        the 8x8 sheet, when one is up.
        """
        assert self._snapshot is not None
        self._thumbnails = [
            raster_to_image(raster)
            for raster in tile_thumbnails(self._snapshot, painter=self._painter)
        ]
        self._palette.set_tiles(self._thumbnails)
        self._palette.set_layer2(self._draw_layer2)
        self._palette.set_stamps(self._draw_stamps if self.document.stamps else None)
        if self._sheet_up:
            # The sheet is drawn under the framed map's palette, like every
            # offer the dock previews, so a pick moves its pixels too.
            self._canvas.set_image(
                self._sheet.render(
                    self.document,
                    self._snapshot,
                    small=self._sheet.small,
                    painter=self._painter,
                )
            )
        self._build_sprite_visuals()
        self._palette.set_sprites(self._sprite_offers())
        self._refresh_marks()

    def _build_sprite_visuals(self) -> None:
        """Decode the capture's sprite artwork, once per palette the picture
        is drawn under.

        Two sets, because the picture is drawn under two palettes: the
        main-map half's markers wear palette 0's colours like the page they
        stand on, and the shared half's the framed submap's. One set while
        the main map is framed, where the two palettes are the same one.

        The boxes come off the framed set alone -- they are what a click is
        tested against, and a marker's reach is its tiles' geometry, which no
        palette moves.
        """
        self._sprite_images = {}
        self._main_sprite_images = {}
        self._sprite_boxes = {}
        if self._snapshot is None:
            return
        art = self._snapshot.sprite_tiles()
        cgrams = self.palette_cgrams
        cgram = cgrams[self._palette_index] if cgrams else self._snapshot.cgram
        for number in art:
            made = sprite_art_image(number, art, self._snapshot.vram, cgram)
            if made is None:
                continue
            image, corner = made
            self._sprite_images[number] = (image, corner)
            self._sprite_boxes[number] = QRect(
                corner.x(), corner.y(), image.width(), image.height()
            )
        if self._palette_index == 0 or not cgrams:
            self._main_sprite_images = self._sprite_images
            return
        for number in art:
            made = sprite_art_image(number, art, self._snapshot.vram, cgrams[0])
            if made is not None:
                self._main_sprite_images[number] = made

    def _sprite_offers(self) -> list[tuple[int, QImage]]:
        """The sprites tab's rows: every placeable number, pictured.

        Under the framed palette, like every other offer the dock makes: what
        a placement draws is a statement about the map being edited.
        """
        return [
            (number, self._marker_image(number))
            for number in range(1, len(SPRITE_NAMES))
        ]

    def _marker_image(self, sprite_id: int, main_half: bool = False) -> QImage:
        """What a marker (and the tab, and the ghost) shows for a number.

        ``main_half`` picks the main map's palette rather than the framed
        map's -- the marker copies standing on the top page, which is drawn
        under palette 0 whatever is framed.
        """
        held = (self._main_sprite_images if main_half else self._sprite_images).get(
            sprite_id
        )
        return held[0] if held is not None else glyph_image(sprite_id)

    def _repaint_submap_page(self) -> None:
        """Redraw the shared submap page under the palette just picked.

        What a palette pick actually changes: the main map's page is drawn
        under palette 0 whatever is framed, so half the picture -- and the
        half above the one the pick is about -- cannot have moved. The runs
        land exactly what a whole render would have put there; see
        :func:`~shiny_mushroom.overworld.submap_page_cells`.

        The twin moves with the base while it is the picture on screen, and
        is dropped when it is not: it would be a page out of date in the old
        palette, and :meth:`set_events_view` draws it again on demand rather
        than a replay and a second render being paid for here.
        """
        assert self._snapshot is not None
        cells = submap_page_cells()
        self._picture.patch(
            self._snapshot,
            self.document.tiles,
            self.document.layer2 or None,
            cells,
            self._painters,
        )
        if not self._picture.has_events:
            pass
        elif self._picture.showing_events and self._replayed is not None:
            self._picture.patch_events(
                self._snapshot,
                self._replayed[0],
                self._replayed[1] or None,
                cells,
                self._painters,
            )
        else:
            self._picture.forget_events()
        if self._picture.image is not None:
            self._canvas.set_image(self._picture.image)

    def _redraw_everything(self) -> None:
        """Render both buffers afresh and put the active one on the canvas."""
        assert self._snapshot is not None
        self._picture.render(
            self._snapshot,
            self.document.tiles,
            self.document.layer2 or None,
            self._painters,
        )
        # The render drops the twin. Drawn again only for a view that is
        # showing it -- one that is not gets it back from
        # :meth:`set_events_view`, which renders on demand, rather than
        # paying a replay and a second full render on every palette switch
        # for a picture nobody is looking at.
        if self._picture.showing_events:
            self._render_events()
        if self._picture.image is not None:
            self._canvas.set_image(self._picture.image)

    # -- gestures, routed from the window -------------------------------------

    def clicked(self, point: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        self._auto_frame(point)
        # Any click lands the floating paste: what follows is a new gesture,
        # and the float's one step is no longer the one being refined.
        self._hand.land()
        if self._picking_link is not None:
            self._finish_link_pick(point)
            return
        if modifiers & Qt.KeyboardModifier.AltModifier:
            self.pick_up(point)
            return
        if self._placing is not None:
            self._place(point, modifiers)
            return
        kind = self._active_kind()
        if kind in TRANSFER_KINDS:
            # Both tables are on the picture: the mark under the pointer is
            # which of them the click means, as it is for a drag and for the
            # status line. The tab's own kind decides only what a box catches.
            found = self._transfer_at(point)
            if found is not None:
                kind = _kind_of(found.table)
        index = self._key_of(point, kind)
        if kind is Kind.STAMPS:
            # The four event tables stack on one picture, so a click there
            # answers with **one of the records under it** -- the topmost,
            # and the next one down when that is what is already held. The
            # selection is the row itself: a placement's block of sheet
            # bytes, a slot, an event. The block's own bytes stay reachable
            # through the sheets and the eyedropper.
            records = self._records_at(point)
            if records:
                self._select_record(self._cycled(records))
                if len(records) > 1:
                    self._say_cycling(records)
                return
            # Nothing of the document's own here. A stamped tile still
            # selects its sheet byte below -- a silent tile's block on a
            # cartridge carrying no placements is the case that reaches it --
            # and the noted row goes down with the gesture that noted it.
            self._stamp_hits = frozenset()
        if index is None:
            if kind is Kind.STAMPS and self._tile_of(point) is not None:
                self._status(
                    UNSTAMPED_NOTE if self._picture.showing_events else NO_VIEW_NOTE
                )
            # A spot with nothing selectable on it -- an unstamped tile,
            # bare map on the sprites tab: a plain click holds nothing,
            # exactly as a click off the picture does. Shift keeps the
            # selection, as `clicked_away` keeps it.
            if not modifiers & Qt.KeyboardModifier.ShiftModifier and self.selection:
                self.selection = EMPTY_SELECTION
                self._settle_selection()
            return
        if (
            modifiers & Qt.KeyboardModifier.ShiftModifier
            and self.selection.kind is kind
        ):
            self.selection = Selection(kind, self.selection.keys ^ {index})
        else:
            self.selection = Selection(kind, frozenset({index}))
        self._settle_selection()

    def clicked_away(self, modifiers: Qt.KeyboardModifier) -> None:
        if modifiers & Qt.KeyboardModifier.ShiftModifier:
            return
        self._hand.land()
        self.selection = EMPTY_SELECTION
        self._settle_selection()

    def drag_begun(
        self,
        point: QPoint,
        modifiers: Qt.KeyboardModifier = Qt.KeyboardModifier.NoModifier,
    ) -> None:
        self._auto_frame(point)
        if isinstance(self._placing, (SpritePick, StampBlock)):
            # One sprite -- or one entry-table row -- per click: a stroke of
            # thirteen slots or a row per crossed tile is never what a drag
            # means.
            self._place(point, Qt.KeyboardModifier.NoModifier)
            return
        if self._placing is not None:
            # A stroke: paint everything the drag crosses, on a working copy.
            # The document is untouched until the button comes up, so the
            # whole stroke is one undo step -- see :meth:`drag_ended`.
            self._stroke = self.document
            self._paint(point)
            return
        # A drag that takes hold of a Layer 1 or Layer 2 selection carries
        # it whole -- lifted into a float first when it is not one yet --
        # and one from anywhere else fixes a float where it sits. Shift
        # always boxes, the convention every selection here keeps.
        if not modifiers & Qt.KeyboardModifier.ShiftModifier and self._grab_float(
            point
        ):
            return
        self._hand.land()
        # A drag that takes hold of a marker moves the sprite -- the marquee
        # never catches one, so the two gestures cannot collide.
        slot = self._slot_at(point)
        if slot is not None:
            self.selection = Selection(Kind.SPRITES, frozenset({slot}))
            # Unless the type places itself: the drag would write a position
            # the game overwrites before it draws, so it is refused with the
            # reason rather than accepted and quietly undone by the console.
            placed = self.document.sprite(slot).placed_by_code
            if placed:
                self._status(placed_by_code_note(self.document.sprite(slot)))
            else:
                self._sprite_drag = SpriteDrag.begun(self.document, slot, point)
            self._settle_selection()
            return
        # A drag that takes hold of a trigger mark moves that entry of
        # whichever table it is a row of -- cell-grained, since both tables
        # hold a grid position.
        found = self._transfer_at(point)
        if found is not None:
            self.selection = Selection(_kind_of(found.table), frozenset({found.entry}))
            self._transfer_drag = TransferDrag.begun(
                self.document, found.table, found.entry, point
            )
            self._settle_selection()
            return
        # A drag that takes hold of an event record moves it: a placement's
        # stamped block, a silent slot's landing in its layer's own grain, a
        # destroyed-tile slot's or a substitution's cell like a warp trigger
        # -- one undo step at the drop. Which record is the one a click there
        # would take (:meth:`_grabbed_record`), so a row reached by clicking
        # down through an overlap is the row the drag then carries. Only in
        # stamp mode: a stamp on the picture is scenery to every other layer,
        # so a Layer 2 drag under one boxes the tiles it crosses.
        #
        # With Ctrl a placement duplicates instead of moving: the copy joins
        # the focused event when one is held, the source's own otherwise.
        record = self._grabbed_record(point)
        self._stamp_hits = frozenset()
        if record is not None:
            if record.kind is Kind.STAMPS:
                event, entry = record.keys
                drag = self._placement_drag(event, entry, point)
                self._stamp_hits = frozenset({(event, entry)})
                # Taking hold of a placement selects the row it stands on.
                keys = self._placement_keys(event, entry)
                if modifiers & Qt.KeyboardModifier.ControlModifier:
                    duplicated = self._duplicating(drag)
                    if duplicated is None:
                        return
                    drag = duplicated
                    self._stamp_hits = frozenset()
                self.selection = Selection(Kind.STAMPS, keys)
                self._stamp_drag = drag
            elif record.kind is Kind.SILENT:
                (slot,) = record.keys
                self.selection = Selection(Kind.SILENT, frozenset({slot}))
                self._silent_drag = SilentDrag.begun(self.document, slot, point)
            elif record.kind is Kind.DESTROY:
                (slot,) = record.keys
                self.selection = Selection(Kind.DESTROY, frozenset({slot}))
                self._destroy_drag = DestroyDrag.begun(self.document, slot, point)
            else:
                (subs_event,) = record.keys
                self.selection = Selection(Kind.SUBS, frozenset({subs_event}))
                self._subs_drag = SubsDrag.begun(self.document, subs_event, point)
            self._settle_selection()
            return
        if self._active_kind() is Kind.STAMPS and self._focus_event is None:
            # A box needs a rule for what "the selection" means across entry
            # tables, and the events view showing every event's work at once
            # has none to offer. Focusing one *is* that rule -- see
            # :meth:`_boxed_placements` -- so the box waits for a focus rather
            # than inventing an answer.
            self._status(BOX_NEEDS_FOCUS)
            return
        self._marquee = (point, point)
        self._marquee_kind = self._active_kind()
        if (
            self._marquee_kind in TRANSFER_KINDS
            and self.selection.kind in TRANSFER_KINDS
            and modifiers & Qt.KeyboardModifier.ShiftModifier
        ):
            # Both transfer tables are on the picture, and a shift-box adds
            # to what is held: the table already selected is the one being
            # added to, whichever of the two a bare box would have caught.
            self._marquee_kind = self.selection.kind
        # A bare marquee replaces the selection, as a bare click does; shift
        # is what says "as well as", on box and click alike -- except over the
        # stamps, where a click has no shift either: a placement is held whole
        # and two of them are two entry-table rows, not a bigger one.
        self._marquee_from = (
            self.selection.keys
            if modifiers & Qt.KeyboardModifier.ShiftModifier
            and self._marquee_kind is not Kind.STAMPS
            and self.selection.kind is self._marquee_kind
            else frozenset()
        )

    def drag_moved(self, point: QPoint) -> None:
        if self._stroke is not None:
            self._paint(point)
            return
        if self._hand.grab is not None:
            self._float_hover(point)
            return
        if self._sprite_drag is not None:
            self._sprite_drag = self._sprite_drag.moved(point)
            self._status(self._drag_status())
            self._refresh_marks()
            return
        if self._transfer_drag is not None:
            self._transfer_drag = self._transfer_drag.moved(point)
            drag = self._transfer_drag
            self._status(
                f"{drag.table.noun} {hexnum(drag.entry)} -> "
                f"{cell_place(drag.x, drag.y)}"
            )
            self._refresh_marks()
            return
        if self._stamp_drag is not None:
            self._stamp_drag = self._stamp_drag.moved(point)
            drag = self._stamp_drag
            what = "new stamp" if drag.entry < 0 else "stamp"
            self._status(
                f"event {hexnum(drag.event)} {what} -> {hexspot(drag.tx, drag.ty)}"
            )
            self._refresh_marks()
            return
        if self._silent_drag is not None:
            self._silent_drag = self._silent_drag.moved(point)
            drag = self._silent_drag
            self._status(f"silent slot {drag.slot} -> {hexspot(drag.x, drag.y)}")
            self._refresh_marks()
            return
        if self._destroy_drag is not None:
            self._destroy_drag = self._destroy_drag.moved(point)
            drag = self._destroy_drag
            self._status(
                f"destroyed tile slot {drag.slot} -> {cell_place(drag.x, drag.y)}"
            )
            self._refresh_marks()
            return
        if self._subs_drag is not None:
            self._subs_drag = self._subs_drag.moved(point)
            drag = self._subs_drag
            self._status(
                f"event {hexnum(drag.event)} substitution -> "
                f"{cell_place(drag.x, drag.y)}"
            )
            self._refresh_marks()
            return
        if self._marquee is None:
            return
        self._marquee = (self._marquee[0], point)
        self.selection = self._boxed()
        self._settle_selection()

    def drag_ended(self, point: QPoint) -> None:
        if self._stroke is not None:
            self._paint(point)
            stroke, self._stroke = self._stroke, None
            # The tool stays in hand: a stroke is how many of one tile get
            # laid, and right-click or Escape is the way to put it down.
            self._commit(stroke, self._hand.mark())
            return
        if self._hand.grab is not None:
            self._float_hover(point)
            self._settle_float()
            return
        if self._sprite_drag is not None:
            drag, self._sprite_drag = self._sprite_drag.moved(point), None
            self._commit(
                self.document.sprite_moved(
                    drag.slot, self._pixel(drag.x), self._pixel(drag.y)
                )
            )
            self._refresh_marks()
            self._describe_selection()
            return
        if self._transfer_drag is not None:
            drag, self._transfer_drag = self._transfer_drag.moved(point), None
            self._commit(drag.table.moved(self.document, drag.entry, drag.x, drag.y))
            self._refresh_marks()
            self._describe_selection()
            return
        if self._stamp_drag is not None:
            drag, self._stamp_drag = self._stamp_drag.moved(point), None
            if drag.entry < 0:
                # A duplicate dropping: the new row appends, revealed last.
                self._stamp_hits = frozenset(
                    {(drag.event, len(self.document.events[drag.event]))}
                )
                self._commit(
                    self.document.stamp_inserted(
                        drag.event, drag.sheet, drag.destination
                    )
                )
                self._say_row_count(drag.event, "added", self.document.events)
            else:
                self._commit(
                    self.document.stamp_relocated(
                        drag.event, drag.entry, drag.destination
                    )
                )
            self._refresh_marks()
            self._describe_selection()
            return
        if self._silent_drag is not None:
            drag, self._silent_drag = self._silent_drag.moved(point), None
            # The move rewrites the location alone; the rest of the slot --
            # its event, layer and tile -- rides along unchanged.
            event, layer, _location, tile = self.document.silent_entry(drag.slot)
            self._commit(
                self.document.silent_entry_set(
                    drag.slot, event, layer & 1, drag.location, tile
                )
            )
            self._refresh_marks()
            self._describe_selection()
            return
        if self._destroy_drag is not None:
            drag, self._destroy_drag = self._destroy_drag.moved(point), None
            event, _location = self.document.destroy_entry(drag.slot)
            self._commit(
                self.document.destroy_entry_set(drag.slot, event, drag.location)
            )
            self._refresh_marks()
            self._describe_selection()
            return
        if self._subs_drag is not None:
            drag, self._subs_drag = self._subs_drag.moved(point), None
            self._commit(self.document.subs_cell_set(drag.event, drag.location))
            self._refresh_marks()
            self._describe_selection()
            return
        if self._marquee is None:
            return
        self._marquee = (self._marquee[0], point)
        self.selection = self._boxed()
        self._marquee = None
        self._settle_selection()

    def cursor_moved(self, point: QPoint) -> None:
        # Followed continuously so a paste can land under the pointer -- the
        # same reason the level editor notes it (see `MainWindow._note_pointer`).
        self._cursor = QPoint(point)
        # A marker under the pointer describes itself while the sprite layer
        # is being edited -- the same reach a click has -- unless something
        # is being placed.
        if self._placing is None:
            slot = self._slot_at(point)
            if slot is not None:
                sprite = self.document.sprite(slot)
                self._status(
                    f"slot {sprite.slot}  {sprite.name}  "
                    f"{hexspot(sprite.x, sprite.y, 3)}"
                )
                return
        if isinstance(self._placing, SpritePick):
            spot = (point.x(), point.y())
            if spot != self._placing_at:
                self._placing_at = spot
                self._refresh_marks()
            self._status(hexspot(point.x(), point.y(), 3))
            return
        if isinstance(self._placing, StampBlock):
            # A block in hand lands on any tile -- its ghost is the block's
            # own footprint, clamped to the page half like a stamp drag.
            drag = self._block_drop(self._placing, point)
            spot = (drag.tx, drag.ty)
            if spot != self._placing_at:
                self._placing_at = spot
                self._refresh_marks()
            self._status(hexspot(drag.tx, drag.ty))
            return
        kind = self._active_kind()
        if kind in TRANSFER_KINDS:
            # Both tables are on the picture at once, so what the pointer is
            # over is what gets described -- the tab's own kind only decides
            # which table a box would catch.
            found = self._transfer_at(point)
            if found is not None:
                kind = _kind_of(found.table)
        index = self._key_of(point, kind)
        if kind is Kind.STAMPS and self._placing is None:
            said = self._record_status(point, index)
            if said is not None:
                self._status(said)
                return
        if index is None:
            if kind is Kind.SPRITES:
                # Bare map on the sprite layer: nothing to describe, but the
                # pointer is still somewhere a paste can land.
                self._status(hexspot(point.x(), point.y(), 3))
                return
            if kind in TRANSFER_KINDS:
                # Bare map in transfer mode: the cell, since a trigger is
                # dropped onto one and a landing picked on one.
                cell = self._cell_of(point)
                self._status("" if cell is None else cell_place(*cell_at(cell)))
                return
            if kind is Kind.STAMPS and self._tile_of(point) is not None:
                # A real tile, just not a stamped one: say so rather than
                # falling silent, and put the ghost down -- there is nothing
                # here a stamp edit could land on.
                self._status(
                    UNSTAMPED_NOTE if self._picture.showing_events else NO_VIEW_NOTE
                )
                if self._placing_at is not None:
                    self._placing_at = None
                    self._refresh_marks()
                return
            self.cursor_left()
            return
        self._status(self._described_at(kind, index))
        if self._placing is not None:
            # The ghost sits on the tile under the pointer -- for a stamp,
            # that is the use being pointed at, not the sheet byte behind it.
            spot = self._tile_of(point) if kind is Kind.STAMPS else index
            if spot != self._placing_at:
                self._placing_at = spot
                self._refresh_marks()

    def cursor_left(self) -> None:
        self._cursor = None
        self._status("")
        if self._placing_at is not None:
            self._placing_at = None
            self._refresh_marks()

    def note_pointer(self, point: QPoint) -> None:
        """Take ``point`` as where the pointer is, for a paste to land on.

        What a context menu's Paste says: the pointer left the picture for
        the menu, and the place it left from is the place the row is about.
        """
        self._cursor = QPoint(point)

    def right_clicked(self) -> bool:
        """Put down what is in hand, reporting whether there was anything.

        The right button's first meaning, and the only one it has while a
        tile, a sprite, a block or a destination pick is armed. With nothing
        armed it means the context menu instead, which is the window's to
        show -- so ``False`` is "nothing was put down, ask what is here".
        A floating paste is not "in hand" in this sense: it is a selection,
        and the menu's rows are about it.
        """
        if self._picking_link is None and self._placing is None:
            return False
        self.stop_placing()
        return True

    @property
    def can_pick(self) -> bool:
        """Whether the eyedropper has a hand to fill on the current tab --
        see :meth:`pick_up` for the one tab that arms nothing."""
        return self._sheet_up or self._palette.tab is not PaletteTab.TRANSFERS

    def select_under(self, point: QPoint) -> None:
        """Hold what is under ``point``, unless it is held already.

        What a right click does before its menu opens: the rows are about the
        thing under the pointer, so that thing is selected first -- exactly
        as a plain click would select it -- and a selection the pointer is
        already on is kept whole, so a group is not collapsed to the one
        record the menu was opened over. Nothing under the pointer keeps the
        selection too: the menu's Paste and the test-run rows need no
        selection, and dropping one to show them would be a gesture nobody
        made.
        """
        if not self.ready or self._placing is not None or self._picking_link:
            return
        kind = self._active_kind()
        if kind in TRANSFER_KINDS:
            found = self._transfer_at(point)
            if found is not None:
                kind = _kind_of(found.table)
        if kind is Kind.STAMPS:
            records = self._records_at(point)
            if not records:
                return
            if self._selected_record() in records:
                return
        else:
            index = self._key_of(point, kind)
            if index is None:
                return
            if self.selection.kind is kind and index in self.selection.keys:
                return
        self.clicked(point, Qt.KeyboardModifier.NoModifier)

    def context_rows(self, point: QPoint | None) -> list[Row | None]:
        """The mode's own rows for the context menu at ``point``: the
        eyedropper, the properties panel's buttons for what is held, and the
        middle click's test-run setup -- each the gesture it names, reached
        from under the pointer. The clipboard rows are the window's, since
        they are the Edit menu's own actions.
        """
        if not self.ready:
            return []
        rows: list[Row | None] = []
        if self.can_pick:
            rows.append(
                Row(
                    "Pick",
                    lambda: None if point is None else self.pick_up(point),
                    enabled=point is not None,
                    shortcut="Alt+click",
                )
            )
        rows.append(SEPARATOR)
        # The panel's buttons -- Set destination..., Delete entry, Delete row
        # -- fired exactly as the buttons fire them: the key, and a one.
        for field in self._properties.actions():
            assert isinstance(field.kind, Action)
            if field.key == LOAD_PATH:
                # The window offers this one itself, further down the menu,
                # as the Level menu's own row -- a button here would double it.
                continue
            rows.append(
                Row(
                    field.kind.caption,
                    lambda key=field.key: self.commit_field(key, 1),
                )
            )
        rows.append(SEPARATOR)
        if point is not None and not self._sheet_up:
            index = self._cell_of(point)
            if index is not None:
                rows.append(
                    Row(
                        "Test run starts at the game's own spawn"
                        if self.test_spawn == index
                        else "Start test runs here",
                        lambda: self.middle_clicked(
                            point, Qt.KeyboardModifier.NoModifier
                        ),
                        shortcut="Middle-click",
                    )
                )
                if self.document.translevels[index]:
                    state = self.completed.get(index)
                    rows.append(
                        Row(
                            "Mark complete for test runs"
                            if state is None
                            else "Mark complete with the secret exit"
                            if state is False
                            else "Unmark complete for test runs",
                            lambda: self.middle_clicked(
                                point, Qt.KeyboardModifier.ControlModifier
                            ),
                            shortcut="Ctrl+middle-click",
                        )
                    )
        return rows

    # -- test-run setup -------------------------------------------------------

    def middle_clicked(self, point: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        """A middle click is test-run setup, as it is in the level editor:
        plain sets or clears the spawn, Ctrl on a level tile cycles whether it
        counts as already complete. A sheet has no cells to start a run on,
        so the click means nothing there."""
        if not self.ready or self._sheet_up:
            return
        self._auto_frame(point)
        index = self._cell_of(point)
        if index is None:
            return
        if modifiers & Qt.KeyboardModifier.ControlModifier:
            self._cycle_completed(index)
        else:
            self._toggle_spawn(index)
        self._refresh_marks()
        self._changed()

    def _toggle_spawn(self, index: int) -> None:
        """Middle-clicking the marked cell clears it, like the level's start."""
        if self.test_spawn == index:
            self.test_spawn = None
            self._status("Test run starts at the game's own spawn")
            return
        self.test_spawn = index
        x, y = cell_at(index)
        spawn = spawn_for_cell(x, y)
        self._status(
            f"Test run starts at {hexspot(x, y)} on {SUBMAP_NAMES[spawn.submap]}"
        )

    def _cycle_completed(self, index: int) -> None:
        """Unmarked, complete, complete with the secret exit, unmarked."""
        translevel = self.document.translevels[index]
        if not translevel:
            self._status("Only a level tile can be marked complete")
            return
        level = self.document.level_of(translevel, bool(index & 0x400))
        if level is None:
            self._status("This tile's translevel is past the remap table")
            return
        state = self.completed.get(index)
        if state is None:
            self.completed[index] = False
            said = "complete"
        elif state is False:
            self.completed[index] = True
            said = "complete with the secret exit"
        else:
            del self.completed[index]
            self._status(f"Level {hexnum(level, 3)} no longer marked complete")
            return
        self._status(f"Level {hexnum(level, 3)} marked {said}{self._event_note(index)}")

    def _level_events_table(self) -> bytes:
        """The level-events rows everything event-shaped quotes: the
        document's where it carries them, the capture's otherwise."""
        if self.ready and self.document.level_events:
            return self.document.level_events
        return b"" if self._snapshot is None else self._snapshot.level_events

    def _event_note(self, index: int) -> str:
        """Which events a mark counts as already run, for the status line."""
        if self._snapshot is None:
            return ""
        translevel = self.document.translevels[index]
        events = self._level_events_table()
        if translevel >= len(events) or events[translevel] == NO_EVENT:
            return ""
        event = events[translevel]
        if self.completed.get(index):
            return f" -- events {hexnum(event)} and {hexnum(event + 1)} already run"
        return f" -- event {hexnum(event)} already run"

    def arrow(self, dx: int, dy: int) -> bool:
        """Nudge the selection by ``(dx, dy)``, in whatever unit the records
        it holds are kept in. Reports whether the key meant anything, so the
        window can let an idle press scroll.

        Each record moves in the grain its own table keeps: a sprite in map
        pixels, which is what its slot stores; a warp or path-exit trigger in
        **cells**; a stamp placement in **8x8 tiles**, the grid its block
        sits on; an event table's slot in whichever of the two its layer
        works in. Same rhythm throughout -- one a press, eight with Shift --
        because the step is a statement about the record and not about the
        picture.
        """
        if not self.ready or not self.selection:
            return False
        if self.selection.kind in TRANSFER_KINDS:
            return self._nudge_transfers(dx, dy)
        if self.selection.kind is Kind.STAMPS:
            return self._nudge_stamps(dx, dy)
        if self.selection.kind is Kind.SILENT:
            return self._nudge_silent(dx, dy)
        if self.selection.kind is Kind.DESTROY:
            return self._nudge_destroy(dx, dy)
        if self.selection.kind is Kind.SUBS:
            return self._nudge_subs(dx, dy)
        if self.selection.kind is not Kind.SPRITES:
            return False
        document = self.document
        moved = False
        for slot in sorted(self.selection.keys):
            sprite = document.sprite(slot)
            # A self-placing type is nudged nowhere, for the reason a drag of
            # one is refused -- and the key is still claimed, so the map does
            # not scroll out from under a selection that meant to move.
            if sprite.placed_by_code:
                self._status(placed_by_code_note(sprite))
                continue
            moved = True
            document = document.sprite_moved(
                slot, self._pixel(sprite.x + dx), self._pixel(sprite.y + dy)
            )
        if moved:
            self._commit(document)
        return True

    def _nudge_transfers(self, dx: int, dy: int) -> bool:
        """Move every selected trigger ``(dx, dy)`` cells, one undo step --
        the selection's own table, since a selection holds one kind.

        Held inside the picture per entry rather than refused as a group: a
        run of triggers walked into the edge should stop there, not stop the
        ones beside it moving. A path exit keeps its sub-cell offsets through
        the move, which is its table's rule and not this one's.
        """
        table = _TABLES[self.selection.kind]
        document = self.document
        for entry in sorted(self.selection.keys):
            x, y = table.trigger(document, entry)
            document = table.moved(
                document,
                entry,
                max(0, min(COLUMNS - 1, x + dx)),
                max(0, min(ROWS - 1, y + dy)),
            )
        self._commit(document)
        return True

    def _nudge_stamps(self, dx: int, dy: int) -> bool:
        """Move every held placement ``(dx, dy)`` 8x8 tiles, one undo step --
        the grain a stamp drag moves in, and held on the map and inside one
        page half the same way, since a block cannot straddle the seam.

        Only the rows the selection actually stands on: its keys are sheet
        bytes, and a box may have caught several rows or the bytes of none at
        all (:meth:`_held_placements`). None of them means the key was not
        this gesture's to claim, so the map scrolls instead.
        """
        held = sorted(self._held_placements())
        if not held:
            return False
        document = self.document
        for event, entry in held:
            side, tx, ty = self._placement_spot(document, event, entry)
            moved = StampDrag(event, entry, side, (0, 0), tx, ty).moved(
                QPoint((tx + dx) * TILE, (ty + dy) * TILE)
            )
            document = document.stamp_relocated(event, entry, moved.destination)
        self._commit(document)
        return True

    def _nudge_silent(self, dx: int, dy: int) -> bool:
        """Move the selected silent slot ``(dx, dy)`` in its layer's own
        grain -- 8x8 tiles for a stamp, held to its page half like a stamp
        drag, 16x16 cells for a Layer 1 write -- because the step is a
        statement about the record, exactly as a warp trigger's is."""
        (slot,) = self.selection.keys
        event, layer, _location, tile = self.document.silent_entry(slot)
        x, y, stamped, side = silent_spot(self.document, slot)
        drag = SilentDrag(slot, stamped, side, (0, 0), x, y)
        grain = TILE if stamped else BLOCK
        moved = drag.moved(QPoint((x + dx) * grain, (y + dy) * grain))
        self._commit(
            self.document.silent_entry_set(slot, event, layer & 1, moved.location, tile)
        )
        return True

    def _nudge_destroy(self, dx: int, dy: int) -> bool:
        """Move the selected destroyed-tile slot ``(dx, dy)`` cells."""
        (slot,) = self.selection.keys
        event, location = self.document.destroy_entry(slot)
        x, y = cell_at(min(location, TILEMAP_SIZE - 1))
        self._commit(
            self.document.destroy_entry_set(
                slot,
                event,
                cell_index(
                    max(0, min(COLUMNS - 1, x + dx)),
                    max(0, min(ROWS - 1, y + dy)),
                ),
            )
        )
        return True

    def _nudge_subs(self, dx: int, dy: int) -> bool:
        """Move the selected event's substitution cell ``(dx, dy)`` cells."""
        (event,) = self.selection.keys
        x, y = cell_at(min(self.document.subs_cell(event), TILEMAP_SIZE - 1))
        self._commit(
            self.document.subs_cell_set(
                event,
                cell_index(
                    max(0, min(COLUMNS - 1, x + dx)),
                    max(0, min(ROWS - 1, y + dy)),
                ),
            )
        )
        return True

    @staticmethod
    def _pixel(value: int) -> int:
        """A dragged or nudged coordinate, kept inside the fields' range."""
        return max(SPRITE_MIN, min(SPRITE_MAX, value))

    def _drag_status(self) -> str:
        assert self._sprite_drag is not None
        sprite = self.document.sprite(self._sprite_drag.slot)
        spot = hexspot(
            self._pixel(self._sprite_drag.x), self._pixel(self._sprite_drag.y), 3
        )
        return f"slot {sprite.slot}  {sprite.name}  {spot}"

    def escape(self) -> bool:
        """Escape means "put that down", then "hold nothing". Reports whether
        it meant anything, so the window can pass an idle press along.

        A destination pick is a gesture in hand like an armed tile, and is
        asked about first: arming one drops the hand it was armed from, so
        the selection it is about is all that is left to find otherwise --
        and putting *that* down would leave the pick armed, ready to
        retarget the entry on the next click nobody meant as one.
        """
        if self._picking_link is not None or self._placing is not None:
            self.stop_placing()
            return True
        if self.selection:
            # Putting the selection down is also what sets a floating paste.
            self._hand.land()
            self.selection = EMPTY_SELECTION
            self._settle_selection()
            return True
        return False

    # -- placement ------------------------------------------------------------

    def _armed(self, payload: object) -> None:
        if isinstance(payload, Layer1Tile):
            self._placing = payload
            self._placing_image = self._thumbnails[payload.number]
        elif isinstance(payload, SpritePick):
            self._placing = payload
            self._placing_image = self._marker_image(payload.sprite_id)
        elif isinstance(payload, Layer2Word):
            assert self._snapshot is not None
            self._placing = payload
            (raster,) = layer2_thumbnails(
                self._snapshot, [payload.word], painter=self._painter
            )
            self._placing_image = raster_to_image(raster)
        elif isinstance(payload, StampBlock):
            assert self._painter is not None
            self._placing = payload
            self._placing_image = raster_to_image(
                stamp_block_raster(self.document, payload.sheet, self._painter)
            )
        else:
            return
        self._placing_at = None
        self._hand.land()
        self.selection = EMPTY_SELECTION
        self._view.set_hover_cursor(Qt.CursorShape.CrossCursor)
        self._settle_selection()

    def stop_placing(self) -> None:
        """Put down what is in hand, if anything -- a destination pick
        included, which is a gesture in hand the way an armed tile is. The
        floating paste lands too: every caller means "the gesture is over"."""
        self._hand.land()
        if self._picking_link is not None:
            self._picking_link = None
            self._status("The destination pick was put down")
        if self._placing is None:
            return
        if self._stroke is not None:
            # A stroke abandoned mid-drag: the pixels painted for feedback
            # belong to a document that will never be committed.
            stroke, self._stroke = self._stroke, None
            self._redraw(stroke)
        self._placing = None
        self._placing_at = None
        self._placing_image = None
        self._palette.disarm()
        self._view.set_hover_cursor(None)
        self._refresh_marks()

    def _place(self, point: QPoint, modifiers: Qt.KeyboardModifier) -> None:
        placed = self._applied(self.document, point)
        if placed is None:
            return
        self._commit(placed, self._hand.mark())
        # Shift keeps the tool -- the level editor's convention -- and a plain
        # click places once.
        if not modifiers & Qt.KeyboardModifier.ShiftModifier:
            self.stop_placing()

    def _paint(self, point: QPoint) -> None:
        """One step of a stroke: the working copy gains this spot's tile and
        the picture follows, for feedback the document has not committed."""
        assert self._stroke is not None
        painted = self._applied(self._stroke, point)
        if painted is None or painted is self._stroke:
            return
        before, self._stroke = self._stroke, painted
        self._redraw(before, painted)

    def _applied(self, to: WorldMap, point: QPoint) -> WorldMap | None:
        """``to`` with what is in hand placed under ``point``, or ``None``
        where there is nothing to land on -- a spot off the map, or, for a
        sprite, a map with no table.

        A Layer 2 word always lands on the map's own tilemap: the events
        view draws stamps over it, but drawing is not editing -- the stamps
        are edited in stamp mode.
        """
        assert self._placing is not None
        if isinstance(self._placing, SpritePick):
            if not to.sprites:
                self._status("This map carries no sprite table to place into.")
                return None
            slot = next(
                (
                    slot
                    for slot in range(SPRITE_SLOTS)
                    if to.sprite(slot).sprite_id == 0
                ),
                None,
            )
            if slot is None:
                self._status(NO_EMPTY_SLOT)
                return None
            # Positions live in the one shared 512x512 space; a click on the
            # picture's submap half names the same spot its bottom copy shows.
            page = PAGE_ROWS * BLOCK
            x = self._pixel(point.x())
            y = self._pixel(point.y() - (page if point.y() >= page else 0))
            placed = to.sprite_replaced(slot, self._placing.sprite_id).sprite_moved(
                slot, x, y
            )
            self._say_if_hidden_here(placed.sprite(slot))
            return placed
        if isinstance(self._placing, Layer1Tile):
            index = self._cell_of(point)
            if index is None:
                return None
            return to.placed({index: self._placing.number})
        if isinstance(self._placing, StampBlock):
            if not to.events:
                self._status("This map carries no event placements to add to.")
                return None
            if self._focus_event is None:
                self._status(NO_FOCUS_NOTE)
                return None
            if self._no_stamp_room(to):
                return None
            drag = self._block_drop(self._placing, point)
            # The new row appends, revealed last -- and becomes the
            # selection, so the panel opens on the placement just made.
            self._stamp_hits = frozenset(
                {(self._focus_event, len(to.events[self._focus_event]))}
            )
            self.selection = Selection(
                Kind.STAMPS,
                frozenset(
                    range(self._placing.sheet, self._placing.sheet + drag.side**2)
                ),
            )
            placed = to.stamp_inserted(
                self._focus_event, self._placing.sheet, drag.destination
            )
            self._say_row_count(self._focus_event, "added", placed.events)
            return placed
        if self._sheet_up:
            offset = self._sheet_of(point)
            if offset is None:
                return None
            return to.stamp_words_placed({offset: self._placing.word})
        if not to.layer2:
            # A document that carries no Layer 2. The palette offers the tab
            # whatever the map holds, so the reach is refused here as the
            # sprite and stamp tables are above -- said, not raised.
            self._status("This map carries no Layer 2 to place into.")
            return None
        index = self._tile_of(point)
        if index is None:
            return None
        return to.layer2_placed({index: self._placing.word})

    def _block_drop(self, block: StampBlock, point: QPoint) -> StampDrag:
        """Where the armed block would land from ``point``: its origin on
        the pointed-at tile, clamped to the page half exactly as a stamp
        drag is -- the same geometry, so the ghost and the drop agree."""
        event = self._focus_event if self._focus_event is not None else 0
        return StampDrag(event, -1, block.side, (0, 0), 0, 0, block.sheet).moved(point)

    def pick_up(self, point: QPoint) -> None:
        """The eyedropper: put what is under the pointer in hand, on its tab.

        Each layer picks its own, whatever the picture is showing: Layer 2
        picks the map's own entry even where a stamp is drawn over it, and a
        stamp tab picks the whole block behind the stamped tile, armed to be
        placed again. Over a sheet it picks that entry, which is the only
        thing there. A sprite marker answers first on the sprite layer, as
        it does for a click; on the tile layers it is scenery.

        A map carrying no Layer 2 keeps every gesture on cells -- see
        :meth:`_active_kind` -- and the eyedropper with them. The transfer
        row has no eyedropper at all: its tab arms nothing, so there is no
        hand for one to fill.
        """
        if self._sheet_up:
            offset = self._sheet_of(point)
            if offset is not None:
                self._palette.pickup(Layer2Word(self.document.stamp_word(offset)))
            return
        if self._palette.tab is PaletteTab.TRANSFERS:
            return
        slot = self._slot_at(point)
        if slot is not None and self.document.sprite(slot).sprite_id:
            self._palette.pickup(SpritePick(self.document.sprite(slot).sprite_id))
            return
        if self._palette.tab in STAMP_TABS:
            offset = self._stamp_of(point)
            if offset is not None:
                _block, row, column, small = sheet_at(offset)
                side = 2 if small else 6
                self._palette.pickup(StampBlock(offset - (row * side + column)))
            return
        if self._palette.tab is PaletteTab.LAYER2 and self.document.layer2:
            index = self._tile_of(point)
            if index is not None:
                self._palette.pickup(Layer2Word(self.document.layer2_entry(index)))
            return
        index = self._cell_of(point)
        if index is not None:
            self._palette.pickup(Layer1Tile(self.document.tile(index)))

    # -- editable properties ---------------------------------------------------

    def _say_if_hidden_here(self, sprite: OverworldSprite) -> None:
        """Say where a just-placed sprite will actually draw, when that is not
        under the pointer.

        The marker is under the pointer whatever the framed map's table says,
        so this line is the only thing that tells the placement apart from
        one the console would show. A type that places itself says that
        instead, and says it whichever map is framed: the click chose a slot
        and a number, and nothing else about it took.
        """
        if sprite.placed_by_code:
            self._status(placed_by_code_note(sprite))
            return
        if not sprite_disabled_on(
            self.document.sprite_disable, sprite.sprite_id, self._submap
        ):
            return
        self._status(
            hidden_here_note(sprite.name, SUBMAP_NAMES[self._submap], sprite.appears_on)
        )

    def commit_field(self, key: str, value: int) -> None:
        """The properties panel edited ``key``: apply it to the selection.

        The same no-op discipline as the level's `_commit_field`: a value
        already in place commits nothing and refreshes nothing. The pick
        keys are the exception -- an :class:`~shiny_mushroom.fields.Action`
        carries no value, so they start the destination gesture instead.
        """
        if not self.ready:
            return
        if key in (WARP_PICK, EXIT_PICK):
            self._begin_link_pick(key)
            return
        if key == LOAD_PATH:
            if self.open_load_path is not None:
                self.open_load_path()
            return
        if key == OPEN_LEVEL:
            level = self._selected_cell_level()
            if self.open_level is not None and level is not None:
                self.open_level(level)
            return
        if key == STAMP_DELETE:
            self._delete_stamp_row()
            return
        if key == STAMP_ORDER:
            self._reorder_stamp_row(value)
            return
        if key == STAMP_EVENT:
            self._rehome_stamp_row(value)
            return
        if key == SILENT_ROW_DELETE:
            if self.selection.kind is Kind.SILENT and len(self.selection.keys) == 1:
                (slot,) = self.selection.keys
                self.delete_silent_row(slot)
            return
        if key == DESTROY_ROW_DELETE:
            if self.selection.kind is Kind.DESTROY and len(self.selection.keys) == 1:
                (slot,) = self.selection.keys
                self.delete_destroy_row(slot)
            return
        if key == WARP_ROW_DELETE:
            if self.selection.kind is Kind.WARPS and len(self.selection.keys) == 1:
                (warp,) = self.selection.keys
                self.delete_warp_row(warp)
            return
        if key == EXIT_ROW_DELETE:
            if self.selection.kind is Kind.EXITS and len(self.selection.keys) == 1:
                (path_exit,) = self.selection.keys
                self.delete_exit_row(path_exit)
            return
        if self.selection.kind is Kind.SPRITES and len(self.selection.keys) == 1:
            (slot,) = self.selection.keys
            describe = sprite_fields

            def rebuild(document: WorldMap) -> object:
                return SpriteSlot(document, slot)
        elif self.selection.kind is Kind.WARPS and len(self.selection.keys) == 1:
            # `warp`, not `entry`: the record built below is bound to that
            # name, and this closure is called again after it -- see the
            # refresh at the end.
            (warp,) = self.selection.keys
            describe = warp_entry_fields

            def rebuild(document: WorldMap) -> object:
                return WarpEntry(document, warp)
        elif self.selection.kind is Kind.EXITS and len(self.selection.keys) == 1:
            # `path_exit`, not `entry`, for the reason the warp above is not.
            (path_exit,) = self.selection.keys
            describe = exit_entry_fields

            def rebuild(document: WorldMap) -> object:
                return ExitEntry(document, path_exit)
        elif self.selection.kind is Kind.SILENT and len(self.selection.keys) == 1:
            (silent_slot,) = self.selection.keys
            describe = all_silent_row_fields

            def rebuild(document: WorldMap) -> object:
                return SilentRow(document, silent_slot)
        elif self.selection.kind is Kind.DESTROY and len(self.selection.keys) == 1:
            (destroy_slot,) = self.selection.keys
            describe = destroy_row_fields

            def rebuild(document: WorldMap) -> object:
                return DestroyRow(document, destroy_slot)
        elif self.selection.kind is Kind.SUBS and len(self.selection.keys) == 1:
            (subs_event,) = self.selection.keys
            describe = all_subs_row_fields

            def rebuild(document: WorldMap) -> object:
                return SubsRow(document, subs_event)
        elif self.selection.kind in (Kind.TILES, Kind.SHEET, Kind.STAMPS):
            on_tiles = self.selection.kind is Kind.TILES
            record = Layer2Entry if on_tiles else StampEntry
            describe = (
                layer2_fields
                if on_tiles or self.selection.kind is Kind.SHEET
                else self._stamp_fields
            )

            def rebuild(document: WorldMap) -> object:
                # The keys read live rather than captured: a placement
                # field that swaps the block leaves the selection standing
                # on another block's bytes, re-read below before the panel
                # is refreshed.
                return record(document, self.selection.keys)
        elif self._described_cell() is not None:
            index = self._described_cell()
            level_events = self._level_events_table()
            describe = self._cell_fields

            def rebuild(document: WorldMap) -> object:
                return CellWalk(document, index, level_events, self.levels)
        else:
            return
        entry = rebuild(self.document)
        field = next((found for found in describe(entry) if found.key == key), None)
        if field is None:
            return
        edited = field.applied(entry, value)
        if edited is entry:
            return
        # The commit must not rebuild the panel: the edit arrived from one
        # of its widgets, and `_describe_selection`'s rebuild would delete
        # that widget inside its own signal -- Qt then walks back into the
        # dead spin box and crashes. Suppress the describe and refresh the
        # rows in place instead, which also keeps the keyboard in the box.
        self._panel_commit = True
        try:
            self._commit(edited.document)
        finally:
            self._panel_commit = False
        if self.selection.kind is Kind.STAMPS and self._stamp_hits:
            # A placement field may have moved the row or swapped its block:
            # the selection is the rows it named, so its bytes are re-read
            # off them and the ants follow the footprint.
            self._reselect_placements()
            self._refresh_marks()
        refreshed = rebuild(self.document)
        self._properties.refresh(describe(refreshed), refreshed)

    def commit_table_field(self, record, fields_for, key: str, value: int) -> None:  # noqa: ANN001
        """A table editor committed one cell: apply it to the document.

        Generic over any table whose rows are field records against the
        document -- the record and its fields function come from whoever
        opened the table, and the same no-op discipline as
        :meth:`commit_field` keeps an untouched cell out of the history.
        The panel refreshes through the commit's own settle, so a table
        edit on the selected trigger's row updates its "Warps to" too.
        """
        if not self.ready:
            return
        field = next((found for found in fields_for(record) if found.key == key), None)
        if field is None:
            return
        edited = field.applied(record, value)
        if edited is record:
            return
        self._commit(edited.document)

    def show_cell(self, index: int) -> None:
        """A table's row click: put the ants on the cell at ``index`` and
        bring it into view -- the panel describes the cell through the
        selection's own settle."""
        if not self.ready or not 0 <= index < TILEMAP_SIZE:
            return
        x, y = cell_at(index)
        self.selection = Selection(Kind.CELLS, frozenset({index}))
        self._settle_selection()
        self._view.center_on(QPoint(x * BLOCK + BLOCK // 2, y * BLOCK + BLOCK // 2))

    def show_warp_trigger(self, entry: int) -> None:
        """The warp table's row click: ``entry``'s trigger cell, shown."""
        if not self.ready or not self.document.warps:
            return
        if not 0 <= entry < self.document.shape.warps:
            return
        self.show_cell(cell_index(*warp_trigger(self.document.warps, entry)))

    def show_exit_trigger(self, entry: int) -> None:
        """The exit table's row click: ``entry``'s trigger cell, shown."""
        if not self.ready or not self.document.exits:
            return
        if not 0 <= entry < self.document.shape.exits:
            return
        self.show_cell(cell_index(*exit_trigger(self.document.exits, entry)))

    def select_transfer(self, row: TransferRow) -> None:
        """The Warps/Exits tab's row pick: select that entry and bring its
        trigger into view.

        The tab's rows are how an entry parked under an event stamp or a page
        away is reached at all, so the pick moves the view as a table's row
        click does -- and selects the *entry*, since that is what the mode
        edits and what the panel then offers. The row says which table it
        came from, because the two number their entries apiece.
        """
        if not self.ready:
            return
        kind = Kind.EXITS if row.exits else Kind.WARPS
        table = _TABLES[kind]
        if not 0 <= row.entry < table.entries(self.document):
            return
        x, y = table.trigger(self.document, row.entry)
        self.selection = Selection(kind, frozenset({row.entry}))
        self._settle_selection()
        self._view.center_on(QPoint(x * BLOCK + BLOCK // 2, y * BLOCK + BLOCK // 2))

    # -- the clipboard ---------------------------------------------------------
    #
    # Copy, cut, paste and delete over whatever is held, one kind at a time --
    # except that the three tilemap-word pictures share one clipboard, so a
    # paste of a :data:`WORD_KINDS` copy takes the kind of wherever it lands.
    # A stamp selection is deliberately outside all four: a sheet byte is used
    # in many places at once, so "cut it" and "paste it there" have no honest
    # meaning -- editing one goes through the properties panel instead.

    @property
    def can_copy(self) -> bool:
        """Whether a copy (and so a cut or a delete) has something to take."""
        return bool(self.selection) and self.selection.kind in _COPY_NOUNS

    @property
    def can_paste(self) -> bool:
        """Whether a paste has something to put, into a part the map carries.

        A copy of a :data:`WORD_KINDS` kind goes wherever words go -- Layer 2
        or either stamp sheet, whichever picture is up -- so only the part it
        would land in has to be there. Every other copy belongs to the
        picture it was taken off: a cell's Map16 tile counts in a grid the
        sheets do not have, a sprite is not a tile, and a transfer row goes
        back into the one table it is packed for.
        """
        if not self.ready or self.clipboard is None:
            return False
        kind = self._paste_kind(self.clipboard.kind)
        if (kind is Kind.SHEET) is not self._sheet_up:
            return False
        if kind is Kind.TILES and not self.document.layer2:
            return False
        if kind is Kind.SHEET and not self.document.stamps:
            return False
        if kind is Kind.SPRITES and not self.document.sprites:
            return False
        if kind in TRANSFER_KINDS and not _TABLES[kind].entries(self.document):
            return False
        return True

    def _paste_kind(self, held: Kind) -> Kind:
        """Which kind a paste of a ``held`` copy lands as.

        Its own, except that a tilemap word goes into whichever word picture
        is on the canvas -- the whole of what makes Layer 2 and the two stamp
        sheets one clipboard. Between the sheets there is nothing to decide:
        both are :attr:`Kind.SHEET`, and the shown sheet's own addressing is
        what a landing counts in.
        """
        if held not in WORD_KINDS:
            return held
        return Kind.SHEET if self._sheet_up else Kind.TILES

    def copy_selection(self) -> None:
        """Take a copy of everything held: values with relative geometry for
        the tilemaps and the sprites, whole rows for the transfers."""
        if not self.can_copy:
            return
        kind, keys = self.selection.kind, sorted(self.selection.keys)
        if kind in TRANSFER_KINDS:
            self._copy_transfers(kind, keys)
            return
        if kind is Kind.CELLS:
            spots = [(*cell_at(index), self.document.tile(index)) for index in keys]
        elif kind is Kind.TILES:
            spots = []
            for index in keys:
                tx, ty, submap_area = layer2_at(index)
                spots.append(
                    (
                        tx,
                        ty + (_LAYER2_SIDE if submap_area else 0),
                        self.document.layer2_entry(index),
                    )
                )
        elif kind is Kind.SHEET:
            spots = [
                (*sheet_tile(offset), self.document.stamp_word(offset))
                for offset in keys
            ]
        else:
            spots = []
            for slot in keys:
                sprite = self.document.sprite(slot)
                spots.append((sprite.x, sprite.y, sprite.sprite_id))
        self.clipboard = WorldClipboard(*relative(spots), kind)
        noun = _COPY_NOUNS[kind]
        self._status(f"Copied {len(spots)} {noun}{'' if len(spots) == 1 else 's'}")
        self._changed()

    def _copy_transfers(self, kind: Kind, entries: list[int]) -> None:
        """Take a copy of the held transfer entries as a
        :class:`TransferCopy`: each row whole, keyed on where its trigger
        fires so a paste can land them under the pointer in the shape they
        were copied in."""
        table = _TABLES[kind]
        spots = [
            (*table.trigger(self.document, entry), table.row(self.document, entry))
            for entry in entries
        ]
        left = min(x for x, _, _ in spots)
        top = min(y for _, y, _ in spots)
        self.clipboard = TransferCopy(
            kind,
            tuple((x - left, y - top, row) for x, y, row in spots),
            (left, top),
        )
        noun = _COPY_NOUNS[kind]
        self._status(f"Copied {len(spots)} {noun}{'' if len(spots) == 1 else 's'}")
        self._changed()

    def cut_selection(self) -> None:
        """Copy, then delete -- in that order, as the level editor cuts."""
        if not self.can_copy:
            return
        self.copy_selection()
        self.delete_selection()

    def delete_selection(self) -> None:
        """Take everything held out of the map's part: a cell goes to tile
        ``$00``, a Layer 2 tile to entry ``$0000``, a sprite to the empty
        slot -- each part's own spelling of "nothing here".

        A **transfer** has no such spelling: an entry is a row of a table,
        and a table with a blank row in it is a table whose search still
        reads that row. So deleting one takes the row *out*, the entries
        after it closing up and renumbering -- what
        :meth:`delete_warp_row` does, in one undo step for the whole
        selection.

        A **floating** paste is the exception: deleting it puts back what
        was beneath, an undo of the paste's step rather than a blanking of
        the ground under it -- see :meth:`_cancel_float`.
        """
        if self._hand.held is not None:
            self._cancel_float()
            return
        if not self.can_copy:
            return
        kind, keys = self.selection.kind, self.selection.keys
        if kind in TRANSFER_KINDS:
            self._delete_transfers(kind, keys)
            return
        if kind is Kind.CELLS:
            edited = self.document.placed(dict.fromkeys(keys, 0))
        elif kind is Kind.TILES:
            edited = self.document.layer2_placed(dict.fromkeys(keys, 0))
        elif kind is Kind.SHEET:
            edited = self.document.stamp_words_placed(dict.fromkeys(keys, 0))
        else:
            edited = self.document
            for slot in keys:
                edited = edited.sprite_replaced(slot, 0)
        # Undoing the deletion brings what was taken back held, which is
        # where the gesture started.
        mark = self._hand.mark()
        self.selection = EMPTY_SELECTION
        self._commit_or_settle(edited, mark)

    def _delete_transfers(self, kind: Kind, entries: frozenset[int]) -> None:
        """Take the held transfer entries out of their table, as one step.

        Highest first, so each deletion renumbers only entries already gone
        -- the same reason the table dialog deletes a column at a time from
        the bottom. The table's floor stops the last row from going: a
        cartridge's code scans a table with a length, and a table with no
        rows is a scan over the bytes after it.
        """
        table = _TABLES[kind]
        edited = self.document
        gone = 0
        for entry in sorted(entries, reverse=True):
            if not table_allows(table.region, table.entries(edited) - 1):
                break
            edited = table.deleted(edited, entry)
            gone += 1
        noun = _COPY_NOUNS[kind]
        if not gone:
            self._status(f"The {noun} tables keep at least one entry")
            return
        # Undoing the deletion brings what was taken back held, as every
        # other delete here does.
        mark = self._hand.mark()
        self.selection = EMPTY_SELECTION
        self._commit_or_settle(edited, mark)
        left = len(entries) - gone
        short = "" if not left else f" -- {left} kept, a table keeps at least one entry"
        self._status(
            f"Deleted {gone} {noun}{'' if gone == 1 else 's'}{short}"
            f"{self._spare_said(table.region)}"
        )

    def paste(self) -> None:
        """Land the clipboard under the pointer, or beside where it was taken.

        What lands becomes the selection, as a level paste holds what
        arrived. Parts that would fall off the picture are left out; sprites
        land in empty slots, as many as there are.

        A tilemap word lands as whatever the picture under it holds, so a
        copy taken off Layer 2 pastes into either stamp sheet and a copy off
        a sheet pastes into Layer 2 or the other sheet. Falling off the edge
        is the ordinary case there -- the 6x6 sheet's picture is 48 tiles
        across and the 2x2 sheet's 32 -- so what was dropped is said.

        A transfer's rows are **appended** to their own table, priced against
        the cartridge's room a row at a time: what stops one is no room, not
        an edge, and that is what gets said.
        """
        if not self.can_paste:
            return
        # Landing a second paste's float, and putting the armed tile down
        # with it: a drag paints while one is in hand, so a float pasted
        # under it could never be grabbed.
        self.stop_placing()
        held = self.clipboard
        assert held is not None
        kind = self._paste_kind(held.kind)
        if kind in TRANSFER_KINDS:
            assert isinstance(held, TransferCopy)
            self._paste_transfers(held, kind)
            return
        assert isinstance(held, WorldClipboard)
        landed: set[int] = set()
        if kind is Kind.SPRITES:
            edited = self.document
            empty = [
                slot
                for slot in range(SPRITE_SLOTS)
                if edited.sprite(slot).sprite_id == 0
            ]
            ax, ay = self._paste_anchor(held, kind)
            page = PAGE_ROWS * BLOCK
            if ay >= page:
                # The pointer was on the submap half; positions live in the
                # one shared space its bottom copies show.
                ay -= page
            for dx, dy, sprite_id in held.entries:
                if not empty:
                    break
                slot = empty.pop(0)
                edited = edited.sprite_replaced(slot, sprite_id).sprite_moved(
                    slot, self._pixel(ax + dx), self._pixel(ay + dy)
                )
                landed.add(slot)
            if len(landed) < len(held.entries):
                short = len(held.entries) - len(landed)
                self._status(
                    f"Only {len(landed)} of {len(held.entries)} pasted -- "
                    f"{short} more empty slot{'' if short == 1 else 's'} needed"
                )
        elif kind is Kind.CELLS:
            anchor = self._paste_anchor(held, kind)
            placing = landing(held.entries, anchor, _cell_spot)
            landed.update(placing)
            edited = self.document.placed(placing)
        elif kind is Kind.SHEET:
            anchor = self._paste_anchor(held, kind)
            entries = landing(held.entries, anchor, self._sheet_spot)
            landed.update(entries)
            edited = self.document.stamp_words_placed(entries)
        else:
            anchor = self._paste_anchor(held, kind)
            entries = landing(held.entries, anchor, _layer2_spot)
            landed.update(entries)
            edited = self.document.layer2_placed(entries)
        if kind not in RECORD_KINDS and len(landed) < len(held.entries):
            # A record says its own shortfall above, in the terms that
            # stopped it. Everything else fell off the picture.
            short = len(held.entries) - len(landed)
            self._status(
                f"Only {len(landed)} of {len(held.entries)} pasted -- "
                f"{short} fell off the edge"
            )
        if landed:
            # The paste lands on its own layer: what arrived is the selection,
            # and a selection only means anything on the layer being edited. A
            # tab already on that layer is left where it is -- the two stamp
            # tabs are one layer at two block sizes, and switching between
            # them mid-paste would re-render the sheet and clear the selection
            # under a float addressed in the other size.
            tabs = _LAYER_TABS[kind]
            if self._palette.tab not in tabs:
                self._palette.set_tab(tabs[0])
            self.selection = Selection(kind, frozenset(landed))
        mark = None
        kept: tuple[tuple[int, int, int], ...] = ()
        if kind not in RECORD_KINDS and landed:
            # Only the entries that landed float; a part clipped off at the
            # picture's edge is gone, and a move must not resurrect it.
            spot = self._spot_of(kind)
            kept = tuple(
                (dx, dy, what)
                for dx, dy, what in held.entries
                if spot(anchor[0] + dx, anchor[1] + dy) is not None
            )
            # What the paste was made from is the clipboard, so that is what
            # an undo of it gives back: the copy, floating here again.
            mark = SelectionMark(self.selection, kept, anchor)
        base = self.document
        self._commit_or_settle(edited, mark)
        if kind not in RECORD_KINDS and landed:
            # A tile paste stays in hand: committed -- for cells, repointed
            # by the commit it just rode -- but floating, the one edit a
            # drag may still move.
            self._hand.kind = kind
            self._hand.carry(base, kept, anchor, mark)

    def _paste_transfers(self, held: TransferCopy, kind: Kind) -> None:
        """Land a transfer copy: each row appended to its own table, its
        trigger moved to where the copy's shape puts it under the pointer.

        **Appended, not placed.** A transfer has no spot on the map that it
        occupies -- any number of entries may name one cell, and the game
        takes the highest-numbered that does -- so a paste adds rows rather
        than overwriting anything, and what lands is the selection.

        Priced a row at a time against the cartridge's run of ROM, since
        that is what a table growing costs and the run is shared. A copy that
        runs out of room part-way lands what fitted and says what did not:
        the alternative is refusing the whole paste over its last row, which
        loses the rows that would have fitted for nothing.

        The trigger moves through the table's own ``moved``, so a pasted path
        exit keeps the sub-cell offsets its row carries and both tables pick
        their stored submap by the page the cell is on. A row whose cell
        falls off the picture is dropped, exactly as a tilemap paste's is.
        """
        table = _TABLES[kind]
        stock = STOCK_SHAPE.exits if kind is Kind.EXITS else STOCK_SHAPE.warps
        ax, ay = self._paste_anchor(held, kind)
        edited = self.document
        landed: set[int] = set()
        for dx, dy, row in held.entries:
            x, y = ax + dx, ay + dy
            if not (0 <= x < COLUMNS and 0 <= y < ROWS):
                continue
            if not table_allows(table.region, table.entries(edited) + 1):
                break
            grown = table.appended(edited, row)
            if self._no_room_for(
                f"a {table.noun}", grown, table.region, table.entries(grown) <= stock
            ):
                break
            entry = table.entries(grown) - 1
            edited = table.moved(grown, entry, x, y)
            landed.add(entry)
        noun = _COPY_NOUNS[kind]
        if not landed:
            self._status(f"Nothing pasted -- no room for a {noun}")
            return
        if self._palette.tab not in _LAYER_TABS[kind]:
            self._palette.set_tab(_LAYER_TABS[kind][0])
        # The rows first, then the ants on them: the entries the paste made
        # do not exist until the commit lands, and a selection naming one
        # before then is a readout of a table row that is not there yet.
        self._commit(edited, self._hand.mark())
        self.selection = Selection(kind, frozenset(landed))
        self._settle_selection()
        short = len(held.entries) - len(landed)
        said = "" if not short else f" -- {short} more had nowhere to go"
        self._status(
            f"Pasted {len(landed)} {noun}{'' if len(landed) == 1 else 's'}{said}"
            f"{self._spare_said(table.region)}"
        )

    def _paste_anchor(
        self, held: WorldClipboard | TransferCopy, kind: Kind
    ) -> tuple[int, int]:
        """Where the copy's top-left lands, in the units of the grid it is
        landing on -- ``kind``'s, which is not always the clipboard's own.

        Under the pointer when it is on the picture, and
        :func:`~shiny_mushroom.tile_clipboard.centred` on the viewport
        otherwise. A sprite's units are pixels and the tile kinds' their own
        grid's; either way what comes back is on the picture that is up.
        """
        if kind is Kind.SPRITES:
            if self._cursor is not None:
                return self._cursor.x(), self._cursor.y()
            middle = self._view.looking_at
            return middle.x(), middle.y()
        side = self._side_of(kind)
        bound_x, bound_y = self._bounds_of(kind)
        if self._cursor is not None:
            x, y = self._cursor.x() // side, self._cursor.y() // side
        else:
            middle = self._view.looking_at
            x, y = centred(held.entries, (middle.x() // side, middle.y() // side))
        return max(0, min(bound_x - 1, x)), max(0, min(bound_y - 1, y))

    def _commit_or_settle(
        self, edited: WorldMap, mark: SelectionMark | None = None
    ) -> None:
        """Commit ``edited``, and settle even when it changes nothing: the
        callers just moved the selection, and a no-op commit settles nothing."""
        before = self.document
        self._commit(edited, mark)
        if self.document is before:
            self._settle_selection()

    # -- the floating selection -------------------------------------------------
    #
    # The machinery is :class:`_WorldFloat` over
    # :class:`~shiny_mushroom.tile_clipboard.FloatController`, shared with the
    # level's Layer 2 painting mode. What is left here is what the gestures
    # mean: which of them land a float, which grid a point is read in, and
    # what the status bar says.

    def _spot_of(self, kind: Kind) -> Callable[[int, int], int | None]:
        """A kind's grid addressing: what index, if any, it keeps at a spot."""
        if kind is Kind.CELLS:
            return _cell_spot
        if kind is Kind.SHEET:
            return self._sheet_spot
        return _layer2_spot

    def _bounds_of(self, kind: Kind) -> tuple[int, int]:
        """A kind's grid size, in its own units -- what a float clamps to and
        a pointerless paste centres in."""
        if kind is Kind.CELLS or kind in TRANSFER_KINDS:
            return COLUMNS, ROWS
        if kind is Kind.SHEET:
            return sheet_grid(small=self._sheet.small)
        return _LAYER2_SIDE, 2 * _LAYER2_SIDE

    @staticmethod
    def _side_of(kind: Kind) -> int:
        """A kind's grid step in pixels, for reading a point into it. A
        transfer's is the cell's: both tables hold a grid position."""
        return BLOCK if kind is Kind.CELLS or kind in TRANSFER_KINDS else TILE

    def _cancel_float(self) -> None:
        """Delete the float: what a move owed comes back, and the gesture's
        own count is what the status line says."""
        held = self._hand.held
        noun = _COPY_NOUNS[self._hand.kind]
        if self._hand.cancel() is FloatStep.NOTHING:
            return
        assert held is not None
        self._status(
            f"Deleted {len(held.holes)} {noun}{'' if len(held.holes) == 1 else 's'}"
            if held.holes
            else "Removed the floating paste"
        )
        self._settle_selection()

    def _grab_float(self, point: QPoint) -> bool:
        """Take hold of the tile selection when ``point`` is on one of its
        tiles -- lifting a settled selection into a float first -- reporting
        whether the drag is now carrying it."""
        kind = self.selection.kind
        if kind not in (Kind.CELLS, Kind.TILES, Kind.SHEET) or not self.selection:
            return False
        if kind is Kind.TILES and not self.document.layer2:
            return False
        if self._hand.held is not None and self._hand.kind is not kind:
            return False
        side = self._side_of(kind)
        gx, gy = point.x() // side, point.y() // side
        index = self._spot_of(kind)(gx, gy)
        if index is None or index not in self.selection.keys:
            return False
        self._hand.kind = kind
        self._hand.take(gx, gy)
        return True

    def _float_hover(self, point: QPoint) -> None:
        """Show the carried float under the pointer."""
        side = self._side_of(self._hand.kind)
        self._hand.hover(point.x() // side, point.y() // side)

    def _settle_float(self) -> None:
        """Write the carried float where the drag left it, and put everything
        that reads the selection back in step."""
        if self._hand.settle() is not FloatStep.NOTHING:
            self._settle_selection()

    # -- undo, redo, save ------------------------------------------------------

    def undo(self) -> None:
        self._walk(back=True)

    def redo(self) -> None:
        self._walk(back=False)

    def saved(self) -> None:
        """Take the document as it stands to be the saved one."""
        assert self.history is not None
        self.history.saved()
        self._changed()

    def _walk(self, back: bool) -> None:
        """One step along the stack, with the selection walking beside the
        document: what is held now goes to the step being left, and whatever
        the step being restored held comes back -- a paste among the things
        that can, back into hand. See :meth:`_mark`.

        The **picture** walks with them: a step made on a stamp sheet is
        undone with that sheet on the canvas, one made on the map with the
        map -- :meth:`_follow_mark`."""
        assert self.history is not None
        # A floating paste lands before the walk: it is the top of the stack,
        # so the undo that follows takes the whole paste back in one press.
        # What it was is read off first, being part of the state a step back
        # here should find again.
        mark = self._hand.mark()
        self._hand.land()
        before = self.history.level
        moved = self.history.undo(mark) if back else self.history.redo(mark)
        if not moved:
            return
        self._follow_mark(self.history.mark)
        self._hand.restore(self.history.mark)
        self._redraw(before)
        self._refresh_stamp_offers(before)
        self._refresh_transfer_offers(before)
        self._settle_selection()
        if self._hand.held is not None:
            self._status("The paste is back in hand -- drag it to place it")

    def _follow_mark(self, mark: object) -> None:
        """Put the picture a restored mark was made on back on the canvas,
        and arm the Editing row that goes with it.

        An undo whose edit is on a picture nobody is looking at has, to the
        eye, not happened; and a float restored into a picture whose grid its
        numbers do not count in is worse than invisible -- a Layer 2 paste
        held over a stamp sheet would drag against map coordinates the sheet
        never shows. So the walk goes to the mark's own picture *before* the
        mark is put back, which is also what keeps the armed row honest: a
        paste lands on its own layer, and an undo of one comes back to it.

        A step whose mark held nothing names no picture -- an empty selection
        is spelled the same on every one of them -- so the canvas is left
        where the user put it.
        """
        if not isinstance(mark, SelectionMark):
            return
        selection = mark.selection
        if not selection.keys:
            return
        if selection.kind is Kind.SHEET:
            # Which sheet is in the keys: an offset belongs to exactly one,
            # and a selection is made on one picture, so any key answers.
            small = min(selection.keys) >= SHEET_6X6_SIZE
            self.set_sheet_view(True, small=small)
            tabs = (PaletteTab.STAMPS_2X2 if small else PaletteTab.STAMPS_6X6,)
        else:
            self.set_sheet_view(False)
            tabs = _LAYER_TABS[selection.kind]
        # After the picture, never before: the tab drives the canvas while a
        # sheet is up, so a tab set first would swap the sheet under the walk.
        if self._palette.tab not in tabs:
            self._palette.set_tab(tabs[0])

    def _no_stamp_room(self, document: WorldMap) -> bool:
        """Whether ``document``'s shared entry table has no room for one more
        row, the refusal said when it has not: every event's rows come out of
        one table, so this is the same answer wherever a row is being added.

        Priced against the cartridge's own run of ROM where the window can
        price one -- a relocated table has a bank to grow into -- and held
        to the stock slot's ``$173`` rows otherwise, which is the whole of
        the room a stock cartridge gives the table.
        """
        return self._stamp_room_refusal(document) is not None

    def _stamp_room_refusal(self, document: WorldMap) -> Refusal | None:
        """Why one more stamp row will not fit ``document``'s shared entry
        table, or ``None`` where it will -- :meth:`_no_stamp_room` as the
        table editor's footer wants it, with the reason to show."""
        grown = document.stamp_inserted(0, 0, 0) if document.events else document
        return self._no_room_for(
            "a stamp row",
            grown,
            STAMP_REGION,
            stamp_row_count(grown.events) <= STAMP_ROW_BUDGET,
        )

    def _no_room_for(
        self, what: str, grown: WorldMap, region_id: str, stock_fits: bool
    ) -> Refusal | None:
        """Why ``grown`` -- the document with one more row in ``region_id``'s
        table -- no longer fits that table's run of ROM, said on the status
        line and handed back; ``None`` where it fits.

        ``stock_fits`` is whether the grown table still fits the stock
        cartridge's slot, which is all there is to hold it to where nothing
        can price the real run -- no project, or none built yet. What the
        refusal suggests is what would help: the relocation feature where the
        tables still sit in their stock slots, which every one of them fills
        to the byte; taking rows back out where they are already in the bank
        and the shared run is spent all the same.
        """
        room = self.price_room(grown, region_id) if self.price_room else None
        if room is None:
            if stock_fits:
                return None
            refusal = Refusal(
                f"No room for {what}",
                "a stock cartridge's table fills its run of ROM to the byte",
                f"Build the project to price the real room, or turn on "
                f"{RELOCATION_FEATURE} and rebuild",
            )
        elif room.spare >= 0:
            return None
        elif room.relocated:
            refusal = Refusal(
                f"No room for {what}",
                f"the overworld tables' shared run is {-room.spare:,} "
                f"byte{'' if room.spare == -1 else 's'} short",
                "Delete rows first",
            )
        else:
            refusal = Refusal(
                f"No room for {what}",
                "the table fills its run of ROM to the byte",
                f"Turn on {RELOCATION_FEATURE} and rebuild",
            )
        self._status(refusal.said)
        return refusal

    def stamp_meter(self) -> str:
        """The shared entry table's meter: its rows, and what is left to
        grow into -- bytes spare in the run where the window can price it,
        the stock slot's row budget otherwise."""
        used = stamp_row_count(self.document.events)
        spare = self._spare(STAMP_REGION)
        if spare is None:
            return f"{hexnum(used, 3)} of {hexnum(STAMP_ROW_BUDGET, 3)} rows used"
        return f"{hexnum(used, 3)} rows, {_spare_said(spare)}"

    def _spare(self, region_id: str) -> int | None:
        """Bytes ``region_id``'s run has left with the document as it stands,
        or ``None`` where nothing can say."""
        if self.price_room is None or not self.ready:
            return None
        room = self.price_room(self.document, region_id)
        return None if room is None else room.spare

    def _say_row_count(self, event: int, what: str, events: StampPlacements) -> None:
        """Say what happened to an event's rows, with the shared table's
        meter -- the one readout every add and delete answers with."""
        self._status(f"Event {hexnum(event)} row {what} -- {self.stamp_meter()}")

    # -- the other growable event tables: silent slots and swap pairs -------

    def add_silent_row(self) -> Refusal | None:
        """The silent table's add: append a slot, duplicating the last one so
        the new row lands somewhere findable -- parked on the focused event
        where one is held, since that is whose slots the table is showing.
        Refused with the reason said, and handed back for the table to show,
        when the block is at its scan's reach or its run of ROM has no room."""
        if not self.ready or not self.document.silent:
            return None
        shape = self.document.shape
        capacity = table_capacity(SILENT_REGION)
        if capacity is not None and shape.silent >= capacity:
            refusal = Refusal(
                "No room for a silent slot",
                f"the block is at the {capacity} slots its scan reaches",
                "Retarget a slot instead",
            )
            self._status(refusal.said)
            return refusal
        event, layer, location, tile = self.document.silent_entry(shape.silent - 1)
        if self._focus_event is not None:
            event = self._focus_event
        # The layer masked to the bit the game reads, as every edit of the
        # byte is: a parked slot's byte may carry anything above it.
        grown = self.document.silent_entry_inserted(event, layer & 1, location, tile)
        refusal = self._no_room_for(
            "a silent slot", grown, SILENT_REGION, shape.silent < STOCK_SHAPE.silent
        )
        if refusal is not None:
            return refusal
        self._commit(grown)
        self._status(
            f"Silent slot {shape.silent} added -- {shape.silent + 1} slots"
            f"{self._spare_said(SILENT_REGION)}"
        )
        return None

    def delete_silent_row(self, slot: int) -> None:
        """Take one slot out of the silent block, from the panel's action or
        the table's column; the slots after it close up, and a canvas
        selection standing on one of them renumbers with the block -- or
        goes down with the slot it stood on."""
        if not self.ready or not self.document.silent:
            return
        shape = self.document.shape
        if not 0 <= slot < shape.silent:
            return
        if not table_allows(SILENT_REGION, shape.silent - 1):
            self._status(
                "The silent-tiles block keeps at least one slot -- park it on "
                "an event that never runs"
            )
            return
        if self.selection.kind is Kind.SILENT:
            kept = frozenset(
                held - 1 if held > slot else held
                for held in self.selection.keys
                if held != slot
            )
            self.selection = Selection(Kind.SILENT, kept) if kept else EMPTY_SELECTION
        self._commit(self.document.silent_entry_deleted(slot))
        self._status(
            f"Silent slot {slot} deleted -- {shape.silent - 1} slots"
            f"{self._spare_said(SILENT_REGION)}"
        )

    def add_swap_row(self) -> Refusal | None:
        """The pairs table's add: append a pair that changes nothing -- tile
        $00 onto itself -- to be aimed by editing; an appended pair is the
        one the scans try first, so a copy of the last would shadow it.
        Refused with the reason said, and handed back for the table to show,
        when the run has no room."""
        if not self.ready or not self.document.subs:
            return None
        pairs = self.document.shape.swaps
        if not table_allows(SWAPS_REGION, pairs + 1):
            refusal = Refusal(
                "No room for a substitution pair",
                "the table is at what its scans reach",
                "Retarget a pair instead",
            )
            self._status(refusal.said)
            return refusal
        grown = self.document.swap_pair_inserted(0, 0)
        refusal = self._no_room_for(
            "a substitution pair", grown, SWAPS_REGION, pairs < STOCK_SHAPE.swaps
        )
        if refusal is not None:
            return refusal
        self._commit(grown)
        self._status(
            f"Substitution pair {hexnum(pairs)} added -- {pairs + 1} pairs"
            f"{self._spare_said(SWAPS_REGION)}"
        )
        return None

    def delete_swap_row(self, pair: int) -> None:
        """Take one pair out of the table; the later pairs close up."""
        if not self.ready or not self.document.subs:
            return
        pairs = self.document.shape.swaps
        if not 0 <= pair < pairs:
            return
        if not table_allows(SWAPS_REGION, pairs - 1):
            self._status("The substitution pairs keep at least one pair")
            return
        self._commit(self.document.swap_pair_deleted(pair))
        self._status(
            f"Substitution pair {hexnum(pair)} deleted -- {pairs - 1} pairs"
            f"{self._spare_said(SWAPS_REGION)}"
        )

    # -- the destroyed tiles, and the two transfers' tables ------------------

    def _not_grown_here(self, what: str, region_id: str, table: str) -> Refusal | None:
        """The refusal for a table whose scan does not follow its rows on
        this cartridge -- the destroyed tiles on a stock build, which reads a
        literal count past the table -- or ``None`` where it does."""
        if region_id in self._shape.grows:
            return None
        refusal = Refusal(
            f"No adding or deleting {what}",
            f"this cartridge's scan reads a fixed number of {table} rows, and "
            f"past them",
            f"Turn on {RELOCATION_FEATURE} and rebuild: that binds the scan "
            f"to the table, so its rows add and delete",
        )
        self._status(refusal.said)
        return refusal

    def add_destroy_row(self) -> Refusal | None:
        """The destroyed-tiles table's add: append a slot, duplicating the
        last one -- parked on the focused event where one is held. Refused,
        with the reason said and handed back, on a cartridge whose scan does
        not follow the rows, at the scan's reach, or for room."""
        if not self.ready or not self.document.destroy:
            return None
        refusal = self._not_grown_here(
            "a destroyed-tile slot", DESTROY_REGION, "destroyed-tile"
        )
        if refusal is not None:
            return refusal
        shape = self.document.shape
        capacity = table_capacity(DESTROY_REGION)
        if capacity is not None and shape.destroy >= capacity:
            refusal = Refusal(
                "No room for a destroyed-tile slot",
                f"the block is at the {capacity} slots its scan reaches",
                "Retarget a slot instead",
            )
            self._status(refusal.said)
            return refusal
        event, location = self.document.destroy_entry(shape.destroy - 1)
        if self._focus_event is not None:
            event = self._focus_event
        grown = self.document.destroy_entry_inserted(event, location)
        refusal = self._no_room_for(
            "a destroyed-tile slot", grown, DESTROY_REGION, False
        )
        if refusal is not None:
            return refusal
        self._commit(grown)
        self._status(
            f"Destroyed-tile slot {shape.destroy} added -- {shape.destroy + 1} slots"
            f"{self._spare_said(DESTROY_REGION)}"
        )
        return None

    def delete_destroy_row(self, slot: int) -> Refusal | None:
        """Take one slot out of the destroyed-tiles block; the slots after it
        close up, and a canvas selection on one of them renumbers -- or goes
        down with the slot. Refused on a cartridge whose scan does not follow
        the rows, and below one slot."""
        if not self.ready or not self.document.destroy:
            return None
        refusal = self._not_grown_here(
            "a destroyed-tile slot", DESTROY_REGION, "destroyed-tile"
        )
        if refusal is not None:
            return refusal
        shape = self.document.shape
        if not 0 <= slot < shape.destroy:
            return None
        if not table_allows(DESTROY_REGION, shape.destroy - 1):
            self._status(
                "The destroyed-tiles block keeps at least one slot -- park it "
                "on an event that never runs"
            )
            return None
        if self.selection.kind is Kind.DESTROY:
            kept = frozenset(
                held - 1 if held > slot else held
                for held in self.selection.keys
                if held != slot
            )
            self.selection = Selection(Kind.DESTROY, kept) if kept else EMPTY_SELECTION
        self._commit(self.document.destroy_entry_deleted(slot))
        self._status(
            f"Destroyed-tile slot {slot} deleted -- {shape.destroy - 1} slots"
            f"{self._spare_said(DESTROY_REGION)}"
        )
        return None

    def add_warp_row(self) -> Refusal | None:
        """The warp table's add: append a copy of the last entry -- the one
        the search tries first, so the copy answers its cell until it is
        moved. Refused, with the reason said and handed back, at the search's
        reach or for room."""
        if not self.ready or not self.document.warps:
            return None
        shape = self.document.shape
        if not table_allows(WARP_REGION, shape.warps + 1):
            refusal = Refusal(
                "No room for a warp",
                f"the tables are at the {table_capacity(WARP_REGION)} entries "
                f"the search reaches",
                "Move an entry instead",
            )
            self._status(refusal.said)
            return refusal
        grown = self.document.warp_duplicated(shape.warps - 1)
        refusal = self._no_room_for(
            "a warp", grown, WARP_REGION, shape.warps < STOCK_SHAPE.warps
        )
        if refusal is not None:
            return refusal
        self._commit(grown)
        self._status(
            f"Warp {hexnum(shape.warps)} added -- {shape.warps + 1} entries"
            f"{self._spare_said(WARP_REGION)}"
        )
        return None

    def delete_warp_row(self, entry: int) -> None:
        """Take one warp out of the tables, from the panel's action or the
        table's column; the entries after it close up, and a canvas selection
        on one of them renumbers -- or goes down with the entry."""
        if not self.ready or not self.document.warps:
            return
        shape = self.document.shape
        if not 0 <= entry < shape.warps:
            return
        if not table_allows(WARP_REGION, shape.warps - 1):
            self._status("The warp tables keep at least one entry")
            return
        if self.selection.kind is Kind.WARPS:
            kept = frozenset(
                held - 1 if held > entry else held
                for held in self.selection.keys
                if held != entry
            )
            self.selection = Selection(Kind.WARPS, kept) if kept else EMPTY_SELECTION
        self._commit(self.document.warp_deleted(entry))
        self._status(
            f"Warp {hexnum(entry)} deleted -- {shape.warps - 1} entries"
            f"{self._spare_said(WARP_REGION)}"
        )

    def add_exit_row(self) -> Refusal | None:
        """The exit table's add: append a copy of the last entry, exactly as
        :meth:`add_warp_row` does -- sub-cell pixel offsets and all, since a
        trigger is matched against the walking player's exact position."""
        if not self.ready or not self.document.exits:
            return None
        shape = self.document.shape
        if not table_allows(EXIT_REGION, shape.exits + 1):
            refusal = Refusal(
                "No room for a path exit",
                f"the tables are at the {table_capacity(EXIT_REGION)} entries "
                f"the search reaches",
                "Move an entry instead",
            )
            self._status(refusal.said)
            return refusal
        grown = self.document.exit_duplicated(shape.exits - 1)
        refusal = self._no_room_for(
            "a path exit", grown, EXIT_REGION, shape.exits < STOCK_SHAPE.exits
        )
        if refusal is not None:
            return refusal
        self._commit(grown)
        self._status(
            f"Path exit {hexnum(shape.exits)} added -- {shape.exits + 1} entries"
            f"{self._spare_said(EXIT_REGION)}"
        )
        return None

    def delete_exit_row(self, entry: int) -> None:
        """Take one path exit out of the tables, from the panel's action or
        the table's column; the entries after it close up, and a canvas
        selection on one of them renumbers -- or goes down with the entry,
        exactly as :meth:`delete_warp_row` leaves the warps."""
        if not self.ready or not self.document.exits:
            return
        shape = self.document.shape
        if not 0 <= entry < shape.exits:
            return
        if not table_allows(EXIT_REGION, shape.exits - 1):
            self._status("The exit tables keep at least one entry")
            return
        if self.selection.kind is Kind.EXITS:
            kept = frozenset(
                held - 1 if held > entry else held
                for held in self.selection.keys
                if held != entry
            )
            self.selection = Selection(Kind.EXITS, kept) if kept else EMPTY_SELECTION
        self._commit(self.document.exit_deleted(entry))
        self._status(
            f"Path exit {hexnum(entry)} deleted -- {shape.exits - 1} entries"
            f"{self._spare_said(EXIT_REGION)}"
        )

    def _spare_said(self, region_id: str) -> str:
        """``, N bytes spare in the run`` for a status line, or nothing where
        nothing can price the run."""
        spare = self._spare(region_id)
        return "" if spare is None else f", {_spare_said(spare)}"

    def _commit(self, document: WorldMap, mark: SelectionMark | None = None) -> None:
        """Make ``document`` the present, as one undo step.

        ``mark`` is what an undo of that step puts the selection back to --
        see :meth:`_mark`. A step without one leaves the selection alone,
        which is what a sprite's own keys, unmoved by any edit, want.
        """
        assert self.history is not None
        before = self.history.level
        # A Layer 1 edit that renumbers the levels carries the walk and
        # event rows along -- part of the same commit, so one undo takes
        # back the tiles and the tables together.
        document, moves = repointed(before, document)
        if not self.history.commit(document, mark):
            return
        if moves:
            self._say_renumbered(moves)
        self._redraw(before, document)
        self._refresh_stamp_offers(before)
        self._refresh_transfer_offers(before)
        self._settle_selection()

    def _refresh_stamp_offers(self, before: WorldMap) -> None:
        """Redraw the palette's stamp thumbnails when an edit -- or an undo
        -- changed the sheet bytes they are drawn from."""
        if (
            before.stamps != self.document.stamps
            or before.stamp_props != self.document.stamp_props
        ):
            self._palette.refresh_stamps()

    def _refresh_transfer_offers(self, before: WorldMap) -> None:
        """Re-offer the Warps/Exits tab's rows when an edit -- or an undo --
        moved a trigger or a landing: the rows read the tables out, so a row
        that did not follow the map would be a stale readout."""
        if before.warps != self.document.warps or before.exits != self.document.exits:
            self._palette.set_transfers(self._transfer_offers())

    def _transfer_offers(self) -> list[tuple[TransferRow, str, QImage]]:
        """The Warps/Exits tab's rows: every entry of both tables the document
        carries, the warps then the path exits, each numbered as it is on the
        map and saying where it triggers and where it lands.

        The table is named in the row rather than left to the mark's hue: a
        list is read as words, and ``$05`` is a row of both tables.
        """
        if not self.ready:
            return []
        rows: list[tuple[TransferRow, str, QImage]] = []
        for kind in (Kind.WARPS, Kind.EXITS):
            table = _TABLES[kind]
            for entry in range(table.entries(self.document)):
                x, y = table.trigger(self.document, entry)
                rows.append(
                    (
                        TransferRow(kind is Kind.EXITS, entry),
                        f"{table.noun.capitalize()} {hexnum(entry)}  "
                        f"{hexspot(x, y)} -> "
                        f"{table.landing_place(self.document, entry)}",
                        transfer_mark_image(table, entry, ICON),
                    )
                )
        return rows

    def _say_renumbered(self, moves: dict[int, int]) -> None:
        """The repoint's status line: how many levels moved, and any
        hardwired number -- compared in the game's code, beyond a table
        shuffle -- that names a different level now."""
        count = len(moves)
        said = (
            f"{count} level{'' if count == 1 else 's'} renumbered -- "
            "their per-level rows moved with them"
        )
        crossed = sorted(
            found
            for found in HARDWIRED_TRANSLEVELS
            if found in moves or found in moves.values()
        )
        if crossed:
            names = ", ".join(
                f"{hexnum(found)} ({HARDWIRED_TRANSLEVELS[found]})" for found in crossed
            )
            said += f". Hardwired in code, unmoved: {names}"
        self._status(said)

    # -- internals -------------------------------------------------------------

    def _active_kind(self) -> Kind:
        """What a bare click or marquee selects: the palette tab's kind.

        The tab -- the world bar's Editing box under another handle -- is the
        whole gate. What the picture is showing never moves it: the events
        view is a *view*, so Layer 2 edits the map's own tilemap whether or
        not stamps are drawn over it, exactly as the level editor's Layer 2
        mode edits Layer 2 whichever layers are on.

        A part only counts once the document carries it -- a map shown
        without a Layer 2 (a synthetic test snapshot) keeps every gesture on
        cells rather than raising out of an entry read.

        A sheet on the canvas is the one thing that *does* move it, and only
        because the map is not on the canvas at all: every pixel under the
        pointer is a sheet entry, so there is nothing else a gesture there
        could mean.
        """
        if self._sheet_up:
            return Kind.SHEET
        if self._palette.tab is PaletteTab.SPRITES:
            return Kind.SPRITES
        if self._palette.tab is PaletteTab.TRANSFERS:
            # Which of the two a *click* means is decided by the mark under
            # it; this is what a box catches and what an empty stretch of map
            # falls back to, so the warps answer while there are any.
            if self.ready and self.document.warps:
                return Kind.WARPS
            if self.ready and self.document.exits:
                return Kind.EXITS
            return Kind.CELLS
        if self._palette.tab in STAMP_TABS:
            if self.ready and self.document.stamps:
                return Kind.STAMPS
            return Kind.CELLS
        if (
            self._palette.tab is PaletteTab.LAYER2
            and self.ready
            and self.document.layer2
        ):
            return Kind.TILES
        return Kind.CELLS

    def _tab_changed(self, _tab: object) -> None:
        """The palette switched layers: a selection means nothing off the
        layer it was made on, and a tool in hand goes down with the tab it
        came from -- the dock already dropped its row, this drops the ghost.

        Opening a stamp tab raises the events view: the stamps only exist on
        the replayed picture, so asking for them is asking for it -- the same
        statement focusing an event makes. **Leaving the stamps puts it back
        down**, every event or a focused one alike: the ask went with the
        tab, and another layer is edited over the map the document holds, not
        over a picture the replay wrote. Only leaving *the stamps* does that
        -- a move between two other layers says nothing about the view, so a
        hand-raised one stays up.

        While a sheet is on the canvas the tab **is** the sheet, so moving
        between the two stamp tabs swaps which one is drawn, and leaving them
        puts the map back: the layer being edited has to be one the picture
        is of.
        """
        on_stamps, was_stamps = self._palette.tab in STAMP_TABS, self._on_stamps
        self._on_stamps = on_stamps
        self.stop_placing()
        if self._sheet_up:
            self.set_sheet_view(
                on_stamps, small=self._palette.tab is PaletteTab.STAMPS_2X2
            )
            if not on_stamps:
                # The map is back on the canvas; the view the stamps raised
                # goes down with them, as it does off the sheet.
                self.set_events_view(False)
            return
        if (
            on_stamps
            and self.ready
            and self.document.stamps
            and not self._picture.showing_events
        ):
            self.set_events_view(True)
        elif was_stamps and not on_stamps:
            self.set_events_view(False)
        if self.selection and self._palette.tab not in _LAYER_TABS[self.selection.kind]:
            self.selection = EMPTY_SELECTION
            self._settle_selection()
        else:
            # The transfer triggers are furniture drawn only while their own
            # row is armed, so moving on or off it changes the picture with
            # no selection changing hands.
            self._refresh_marks()

    def _key_of(self, point: QPoint, kind: Kind) -> int | None:
        if kind is Kind.CELLS:
            return self._cell_of(point)
        if kind is Kind.STAMPS:
            return self._stamp_of(point)
        if kind is Kind.SHEET:
            return self._sheet_of(point)
        if kind is Kind.SPRITES:
            return self._slot_at(point)
        if kind in TRANSFER_KINDS:
            found = self._transfer_at(point)
            if found is None or _kind_of(found.table) is not kind:
                return None
            return found.entry
        return self._tile_of(point)

    def _visible_markers(self, moved: SpriteDrag | None = None) -> list:
        """The marker instances the picture draws: every one of them, while
        the sprite layer is on.

        Framing does not filter them. A marker is where a slot's bytes put
        it, and a slot the framed map's table hides is still the slot being
        edited -- hiding its marker took the thing under the pointer away
        mid-edit and made a slot's own position unfindable. Which maps a
        type draws on is said in the properties panel and in
        :func:`hidden_here_note`, where saying it costs nothing.
        """
        if not self._show_sprites or not self.ready or not self.document.sprites:
            return []
        return markers(self.document, moved, boxes=self._sprite_boxes)

    def _transfer_markers(
        self, kind: Kind, moved: TransferDrag | None = None
    ) -> list[TransferMarker]:
        """One transfer table's triggers as the picture draws them: every
        entry, while the transfers are the layer being edited.

        Only then. A trigger is not a layer of the map -- it is a row of a
        position table, and forty outlined cells over the artwork would be
        furniture on every other gesture. The connectors a
        *cell* selection draws (:meth:`_connector_marks`) stay the way in
        from anywhere else, one transfer at a time.
        """
        if self._sheet_up or not self.ready:
            return []
        if self._palette.tab is not PaletteTab.TRANSFERS:
            return []
        return transfer_markers(self.document, _TABLES[kind], moved)

    def _all_transfer_markers(
        self, moved: TransferDrag | None = None
    ) -> list[TransferMarker]:
        """Both tables' triggers, the warps first and the path exits over
        them -- the order the picture draws them in, and so the order a click
        resolves them by."""
        return self._transfer_markers(Kind.WARPS, moved) + self._transfer_markers(
            Kind.EXITS, moved
        )

    def _transfer_at(self, point: QPoint) -> TransferMarker | None:
        """The transfer entry whose mark is under ``point``, or ``None``.

        Within a table the highest-numbered wins a shared cell, as the game's
        own search answers and as the drawing order shows; between the two,
        the exit does, because it is the one drawn on top. Nothing in either
        table says anything about the other -- a cell can honestly be both,
        and the marker on top is the one the click takes.
        """
        return marker_at(self._all_transfer_markers(self._transfer_drag), point)

    def _shown_records(self) -> tuple[int, ...] | range | None:
        """The events whose silent and destroyed-tile slots are on the
        picture, or ``None`` for none at all.

        The slots are the Events row's own records, so their marks are the
        mode's furniture exactly as the warp marks are the warp row's:
        drawn while the stamps are the layer being edited and the events
        view holds the picture, over the map alone. What is shown follows
        the Event box the way every stamp does -- the focused event's slots,
        or every replayed event's without a focus. A parked slot names a
        location that means nothing yet, so it stays with the table dialogs.
        """
        if (
            self._sheet_up
            or not self.ready
            or not self._picture.showing_events
            or self._palette.tab not in STAMP_TABS
        ):
            return None
        return self._shown_events()

    def _silent_markers(self, moved: SilentDrag | None = None) -> list[SilentMarker]:
        """The silent slots the picture marks -- every shown one, a drag's
        spot standing in for its slot."""
        shown = self._shown_records()
        if shown is None or not self.document.silent:
            return []
        return silent_markers(self.document, shown, moved)

    def _destroy_markers(self, moved: DestroyDrag | None = None) -> list[DestroyMarker]:
        """The destroyed-tile slots the picture marks, the same way."""
        shown = self._shown_records()
        if shown is None or not self.document.destroy:
            return []
        return destroy_markers(self.document, shown, moved)

    def _silent_at(self, point: QPoint) -> int | None:
        """The silent slot whose mark is under ``point``, or ``None``."""
        return silent_at(self._silent_markers(), point)

    def _destroy_at(self, point: QPoint) -> int | None:
        """The destroyed-tile slot whose mark is under ``point``, or
        ``None``."""
        return destroy_at(self._destroy_markers(), point)

    def _grab_silent(self, point: QPoint) -> SilentDrag | None:
        """The silent slot under ``point`` taken hold of, or ``None``."""
        slot = self._silent_at(point)
        if slot is None:
            return None
        return SilentDrag.begun(self.document, slot, point)

    def _grab_destroy(self, point: QPoint) -> DestroyDrag | None:
        """The destroyed-tile slot under ``point`` taken hold of, or
        ``None``."""
        slot = self._destroy_at(point)
        if slot is None:
            return None
        return DestroyDrag.begun(self.document, slot, point)

    def _subs_markers(self, moved: SubsDrag | None = None) -> list[SubsMarker]:
        """The substitution rows the picture marks -- every shown event's
        that aims somewhere, a drag's cell standing in for its row."""
        shown = self._shown_records()
        if shown is None or not self.document.subs:
            return []
        return subs_markers(self.document, shown, moved)

    def _subs_at(self, point: QPoint) -> int | None:
        """The event whose substitution mark is under ``point``, or
        ``None``."""
        return subs_at(self._subs_markers(), point)

    def _grab_subs(self, point: QPoint) -> SubsDrag | None:
        """The substitution row under ``point`` taken hold of, or
        ``None``."""
        event = self._subs_at(point)
        if event is None:
            return None
        return SubsDrag.begun(self.document, event, point)

    def _slot_at(self, point: QPoint) -> int | None:
        """The slot whose *shown* marker is under ``point``; later slots win
        an overlap, as they draw on top. Only while the sprite layer is the
        one being edited -- on the tile layers a marker is scenery, and the
        gesture belongs to the tile under it -- and never over a sheet,
        whose picture carries no markers at all."""
        if self._sheet_up or self._palette.tab is not PaletteTab.SPRITES:
            return None
        return slot_at(self._visible_markers(), point)

    def _walk_cell(self) -> int | None:
        """The one selected cell whose walk directions are editable, or
        ``None``: the selection must be a single cell, the document must
        carry the table, and the cell must hold a numbered level -- an
        unnumbered translevel has no row in a per-translevel table."""
        if (
            not self.ready
            or self.selection.kind is not Kind.CELLS
            or len(self.selection.keys) != 1
            or not self.document.directions
        ):
            return None
        (index,) = self.selection.keys
        translevel = self.document.translevels[index]
        if not 0 < translevel < self.document.shape.directions:
            return None
        return index

    def _selected_cell_level(self) -> int | None:
        """Which level the selected cell loads, or ``None`` where the panel's
        Open Level button has nothing to open.

        Read the way the game reads it -- the remap row where the cartridge
        carries one, the arithmetic otherwise -- so the button opens the
        level the panel's own Level row names.
        """
        index = self._walk_cell()
        if index is None:
            return None
        return level_number(
            self.document.translevels[index],
            cell_at(index)[1] >= PAGE_ROWS,
            self.document.translevel_levels,
        )

    def _described_cell(self) -> int | None:
        """The one selected cell the panel shows *fields* for, or ``None``:
        a walk cell, or any cell that triggers a warp or a path exit."""
        if (
            not self.ready
            or self.selection.kind is not Kind.CELLS
            or len(self.selection.keys) != 1
        ):
            return None
        (index,) = self.selection.keys
        if (
            self._walk_cell() == index
            or warp_entry_at(self.document.warps, index) is not None
            or exit_entry_at(self.document.exits, index) is not None
        ):
            return index
        return None

    def _cell_fields(self, record: CellWalk) -> list:
        """One cell's panel rows: the walk fields where the cell is a
        numbered level, the bare readouts otherwise, whatever transfer the
        cell triggers appended -- see
        :func:`~shiny_mushroom.overworld_fields.link_fields` -- and, on a
        cell that loads a level, the button that traces its load path."""
        walk = self._walk_cell() == record.index
        fields = (
            walk_fields(record, open_level=self.open_level is not None)
            if walk
            else cell_readouts()
        ) + link_fields(record)
        if record.translevel:
            fields.append(load_path_action())
        return fields

    def _begin_link_pick(self, key: str) -> None:
        """A panel button asked for a destination: arm the pick, so the next
        click on a cell retargets the selected trigger's entry there.

        Which entry is asked of the selection, whichever kind it is: in
        transfer mode the selected *entry* is the answer, and over the map it
        is the one the selected cell triggers. The two spellings of "this
        warp" mean the same row, so the pick that follows is the same
        gesture.
        """
        if self.selection.kind in TRANSFER_KINDS and len(self.selection.keys) == 1:
            table = _TABLES[self.selection.kind]
            (entry,) = self.selection.keys
            index = cell_index(*table.trigger(self.document, entry))
            kind = "warp" if self.selection.kind is Kind.WARPS else "exit"
        else:
            index = self._described_cell()
            if index is None:
                return
            if key == WARP_PICK:
                kind, entry = "warp", warp_entry_at(self.document.warps, index)
            else:
                kind, entry = "exit", exit_entry_at(self.document.exits, index)
            if entry is None:
                return
        # Whatever else was in hand goes down first -- two armed gestures
        # would race for the same click.
        self.stop_placing()
        self._picking_link = (kind, entry, index)
        x, y = cell_at(index)
        self._status(
            f"Click where the {kind} at {hexspot(x, y)} should land -- Esc cancels"
        )

    def _finish_link_pick(self, point: QPoint) -> None:
        """The armed pick's click: retarget the entry to the cell under it."""
        assert self._picking_link is not None
        kind, entry, source = self._picking_link
        self._picking_link = None
        index = self._cell_of(point)
        if index is None:
            self._status("The pick landed off the map -- the destination is unchanged")
            return
        x, y = cell_at(index)
        retargeted = (
            self.document.warp_retargeted
            if kind == "warp"
            else self.document.exit_retargeted
        )(entry, x, y)
        # Commit-or-settle: picking the destination it already has is not an
        # edit, but the panel and the status line still answer the gesture.
        self._commit_or_settle(retargeted)
        sx, sy = cell_at(source)
        self._status(f"The {kind} at {hexspot(sx, sy)} now lands at {cell_place(x, y)}")

    def _stamps_shot(self) -> OverworldSnapshot:
        """The snapshot everything stamp-shaped reads: the capture with the
        document's placements standing in, so a moved stamp hit-tests and
        outlines where it moved to."""
        assert self._snapshot is not None
        return event_snapshot(self.document, self._snapshot)

    def _stamp_of(self, point: QPoint) -> int | None:
        """The sheet byte stamped where ``point`` falls, or ``None`` for a
        tile no event stamps -- the base map's own -- and for the events
        view down, where no stamp is on the picture to be hit."""
        if not self._picture.showing_events:
            return None
        index = self._tile_of(point)
        if index is None:
            return None
        found = stamp_index(self._stamps_shot(), self._shown_events()).get(index)
        return None if found is None else found[2]

    @staticmethod
    def _placement_spot(document: WorldMap, event: int, entry: int) -> tuple[int, ...]:
        """A placement's block: ``(side, tx, ty)`` in 8x8 tiles over the two
        stacked pages -- the space a drag, a nudge and a hit test all count
        in, derived once here so the three agree."""
        sheet, destination = document.events[event][entry]
        tx, ty, submap_area = layer2_at(destination // 2)
        return (
            2 if sheet >= SHEET_6X6_SIZE else 6,
            tx,
            ty + (_LAYER2_SIDE if submap_area else 0),
        )

    def _placement_drag(self, event: int, entry: int, point: QPoint) -> StampDrag:
        """The placement at ``(event, entry)`` taken hold of at ``point``."""
        side, tx, ty = self._placement_spot(self.document, event, entry)
        anchor = (point.x() // TILE - tx, point.y() // TILE - ty)
        return StampDrag(event, entry, side, anchor, tx, ty)

    def _placements_at(self, point: QPoint) -> list[tuple[int, int]]:
        """Every placement whose block covers the tile under ``point``,
        **topmost first** -- the reverse of the replay, since the last row to
        land is the one on the picture.

        The whole stack rather than the row the replay left showing
        (:func:`~shiny_mushroom.overworld.stamp_index`), because a click that
        cycles has to reach what is under it. The same guards a drag has: a
        placement is only movable where the document carries the table, the
        events view holds the picture, and the stamps are the layer being
        edited. A silent tile's block is not here -- it has no entry-table
        row, and :meth:`_records_at` names its slot instead.
        """
        if (
            self._active_kind() is not Kind.STAMPS
            or not self.document.events
            or not self._picture.showing_events
        ):
            return []
        index = self._tile_of(point)
        if index is None:
            return []
        tx, ty, submap_area = layer2_at(index)
        ty += _LAYER2_SIDE if submap_area else 0
        found: list[tuple[int, int]] = []
        for event in self._shown_events():
            if not 0 <= event < len(self.document.events):
                continue
            for entry in range(len(self.document.events[event])):
                side, ox, oy = self._placement_spot(self.document, event, entry)
                if ox <= tx < ox + side and oy <= ty < oy + side:
                    found.append((event, entry))
        found.reverse()
        return found

    def _records_at(self, point: QPoint) -> tuple[EventRecord, ...]:
        """Every event record under ``point``, **topmost first**.

        The order the picture stacks them in, which is the order a click
        resolves them and the order clicks cycle through them. The **stamp
        layer** answers first, being artwork rather than an outline over it:
        a silent slot's own block over the placements, because the game
        writes the silent tiles after the reveal has run. Then the marks over
        the map -- the silent slots whose write is a Layer 1 cell, the
        destroyed-tile slots, the substitution rows -- each in its own
        table's order (:func:`~shiny_mushroom.ui.overworld_events.silent_all_at`
        and the two beside it).
        """
        silent = silent_all_at(self._silent_markers(), point)
        found = [
            EventRecord(Kind.SILENT, (marker.slot,))
            for marker in silent
            if marker.stamped
        ]
        found += [EventRecord(Kind.STAMPS, at) for at in self._placements_at(point)]
        found += [
            EventRecord(Kind.SILENT, (marker.slot,))
            for marker in silent
            if not marker.stamped
        ]
        found += [
            EventRecord(Kind.DESTROY, (marker.slot,))
            for marker in destroy_all_at(self._destroy_markers(), point)
        ]
        found += [
            EventRecord(Kind.SUBS, (marker.event,))
            for marker in subs_all_at(self._subs_markers(), point)
        ]
        return tuple(found)

    def _selected_record(self) -> EventRecord | None:
        """The one event record the selection stands on, or ``None``.

        What lets the cycle keep no state of its own: a click on an overlap
        asks what is already held and takes the next one down from it, so
        anything else that changes the selection -- a box, a table dialog's
        row click, an undo -- puts the next click back at the top by itself.
        """
        if self.selection.kind is Kind.STAMPS:
            placement = self._selected_placement()
            return None if placement is None else EventRecord(Kind.STAMPS, placement)
        if self.selection.kind not in EVENTS_VIEW_KINDS:
            return None
        if len(self.selection.keys) != 1:
            return None
        (key,) = self.selection.keys
        return EventRecord(self.selection.kind, (key,))

    def _cycled(self, records: tuple[EventRecord, ...]) -> EventRecord:
        """Which record a click takes: the topmost, or the **next one down**
        where what is already held is one of them.

        So a click on an overlap picks what the picture shows there, and
        clicking again walks down through the stack and round to the top --
        which is the only way to reach a placement under a silent tile's
        block, or the substitution row a destroyed cell is drawn over.
        """
        held = self._selected_record()
        if held in records:
            return records[(records.index(held) + 1) % len(records)]
        return records[0]

    def _select_record(self, record: EventRecord) -> None:
        """Hold ``record`` and settle: the row's own keys, and the noted
        entry-table row a placement's panel rows are about."""
        if record.kind is Kind.STAMPS:
            event, entry = record.keys
            self._stamp_hits = frozenset({(event, entry)})
            self.selection = Selection(Kind.STAMPS, self._placement_keys(event, entry))
        else:
            self._stamp_hits = frozenset()
            self.selection = Selection(record.kind, frozenset(record.keys))
        self._settle_selection()

    def _grabbed_record(self, point: QPoint) -> EventRecord | None:
        """Which event record a drag from ``point`` takes hold of, or
        ``None`` where there is nothing under it to move.

        The **held** one where the selection stands on a record under the
        pointer, so a row reached by clicking down through an overlap is the
        row the drag then carries; the topmost otherwise, which is what the
        picture shows there.
        """
        records = self._records_at(point)
        if not records:
            return None
        held = self._selected_record()
        return held if held in records else records[0]

    def _say_cycling(self, records: tuple[EventRecord, ...]) -> None:
        """The status line for a click that landed on a stack of records:
        which one is held, where in the stack it is, and that clicking again
        goes on down it. Said only where there is more than one, since that
        is the only time the gesture has anything to offer."""
        held = self._selected_record()
        if held is None:
            return
        self._status(
            f"{self._record_said(held)} -- {records.index(held) + 1} of "
            f"{len(records)} here, click again for the next"
        )

    @staticmethod
    def _record_said(record: EventRecord) -> str:
        """What one record is called in the cycling note."""
        if record.kind is Kind.STAMPS:
            event, entry = record.keys
            return f"event {hexnum(event)} stamp row {entry}"
        if record.kind is Kind.SILENT:
            return f"silent slot {record.keys[0]}"
        if record.kind is Kind.DESTROY:
            return f"destroyed tile slot {record.keys[0]}"
        return f"event {hexnum(record.keys[0])} substitution"

    def _entry_within(self, event: int, held: int) -> int | None:
        """The global entry index ``held`` as a slot within ``event``, or
        ``None`` where it is not one of that event's.

        The pointer table is the placements' own prefix sums, so the fold is
        the sum of every earlier event's rows -- and the range check is what
        keeps a stale index off a document that has moved under it.
        """
        entry = held - sum(len(each) for each in self.document.events[:event])
        return entry if 0 <= entry < len(self.document.events[event]) else None

    def _placement_keys(self, event: int, entry: int) -> frozenset[int]:
        """The selection keys stamp mode gives a placement: every sheet byte
        of the row's block."""
        sheet, _destination = self.document.events[event][entry]
        side = 2 if sheet >= SHEET_6X6_SIZE else 6
        return frozenset(range(sheet, sheet + side * side))

    def _held_placements(self) -> frozenset[tuple[int, int]]:
        """The entry-table rows the selection stands on, or nothing.

        The noted rows must still name rows of the document as it stands, and
        together they must still account for exactly the selection's keys --
        otherwise the selection has moved on since the gesture that noted
        them, and what it holds is bytes rather than placements.
        """
        if self.selection.kind is not Kind.STAMPS or not self.document.events:
            return frozenset()
        for event, entry in self._stamp_hits:
            if not 0 <= event < len(self.document.events):
                return frozenset()
            if not 0 <= entry < len(self.document.events[event]):
                return frozenset()
        if self._held_keys() != self.selection.keys:
            return frozenset()
        return self._stamp_hits

    def _held_keys(self) -> frozenset[int]:
        """Every sheet byte of every noted row's block, together."""
        return frozenset().union(
            frozenset(), *(self._placement_keys(*at) for at in self._stamp_hits)
        )

    def _selected_placement(self) -> tuple[int, int] | None:
        """The one entry-table row the selection stands on, or ``None`` where
        it stands on several or on none -- a box may catch more than one, and
        the panel's per-placement rows only mean anything about one."""
        held = self._held_placements()
        if len(held) != 1:
            return None
        (placement,) = held
        return placement

    def _reselect_placements(self) -> None:
        """Re-read the selection off the rows still held, after an edit that
        moved them. Nothing held means nothing selected."""
        keys = self._held_keys()
        self.selection = Selection(Kind.STAMPS, keys) if keys else EMPTY_SELECTION

    def _stamp_fields(self, record: StampEntry) -> list:
        """A stamp selection's panel rows: the shared word fields, and --
        when the click named exactly one entry-table row -- that
        placement's own reveal-order, delete and meter rows."""
        fields = list(layer2_fields(record))
        placement = self._selected_placement()
        if placement is not None:
            fields += stamp_row_fields(self.document, *placement, self.stamp_meter())
        return fields

    def _duplicating(self, drag: StampDrag) -> StampDrag | None:
        """The grabbed placement turned into a new row's drag, joining its
        own event -- or ``None`` with the refusal said, when the shared
        table has no room left."""
        if self._no_stamp_room(self.document):
            return None
        sheet, _destination = self.document.events[drag.event][drag.entry]
        self._status(
            f"Duplicating into event {hexnum(drag.event)} -- drop to add the row"
        )
        return replace(drag, event=drag.event, entry=-1, sheet=sheet)

    def _delete_stamp_row(self) -> None:
        """The panel's delete action: take the clicked placement out of its
        event. The selection goes down with the row -- the sheet byte it
        held may no longer be shown anywhere."""
        placement = self._selected_placement()
        if placement is None:
            return
        self.delete_event_row(*placement)

    def add_event_row(self, event: int) -> Refusal | None:
        """The table editor's add: append a row to ``event`` -- reveal
        order is the animation, so a new block starts at the end --
        duplicating the event's last placement so the fresh row lands
        somewhere visible, or stamping the first 6x6 block at the
        picture's corner when the event has none. Refused with the reason
        said, and handed back for the table to show, when the shared table
        has no room."""
        if not self.ready or not 0 <= event < len(self.document.events):
            return None
        refusal = self._stamp_room_refusal(self.document)
        if refusal is not None:
            return refusal
        rows = self.document.events[event]
        sheet, destination = rows[-1] if rows else (0, 0)
        self._commit(self.document.stamp_inserted(event, sheet, destination))
        self._say_row_count(event, "added", self.document.events)
        return None

    def delete_event_row(self, event: int, entry: int) -> None:
        """Take one placement out of ``event``, from the panel's action or
        the table editor's column. The canvas selection goes down with the
        row when it named it, and renumbers with it when it named a later
        one."""
        if not self.ready or not 0 <= event < len(self.document.events):
            return
        if not 0 <= entry < len(self.document.events[event]):
            return
        held = self._stamp_hits
        self._stamp_hits = frozenset(
            (at, row - 1 if at == event and row > entry else row)
            for at, row in held
            if (at, row) != (event, entry)
        )
        self._commit(self.document.stamp_deleted(event, entry))
        if self._stamp_hits != held:
            # The row the selection stood on is gone, or renumbered under it:
            # the keys are re-read off what is left, which is nothing when the
            # deleted row was all there was. Settled again afterwards, because
            # the commit above answered the selection as it stood before this
            # rewrote it -- the ants and the panel would be the old row's.
            self._reselect_placements()
            self._settle_selection()
        self._say_row_count(event, "deleted", self.document.events)

    def reorder_event_row(self, event: int, entry: int, to: int) -> None:
        """The table editor's reveal-order commit: move one placement in
        its event's animation, the canvas selection's row renumbering with
        the shuffle."""
        if not self.ready or not 0 <= event < len(self.document.events):
            return
        rows = len(self.document.events[event])
        if not 0 <= entry < rows:
            return
        to = max(0, min(to, rows - 1))
        edited = self.document.stamp_reordered(event, entry, to)
        if edited is self.document:
            return
        self._stamp_hits = frozenset(
            (at, _reordered(row, entry, to) if at == event else row)
            for at, row in self._stamp_hits
        )
        self._commit(edited)

    def rehome_event_row(self, event: int, entry: int, to: int) -> None:
        """Move one placement to event ``to``, appended so it reveals last
        -- the table editor's Event column and the panel's Event field. The
        canvas selection follows the row to its new event, and a later row
        of the old event it named renumbers with the rows."""
        if not self.ready or not 0 <= event < len(self.document.events):
            return
        if not 0 <= entry < len(self.document.events[event]):
            return
        if not 0 <= to < len(self.document.events) or to == event:
            return
        edited = stamp_rehomed(self.document, event, entry, to)
        landed = len(edited.events[to]) - 1
        self._stamp_hits = frozenset(
            (to, landed)
            if (at, row) == (event, entry)
            else (at, row - 1 if at == event and row > entry else row)
            for at, row in self._stamp_hits
        )
        self._commit(edited)
        self._say_row_count(to, f"moved from event {hexnum(event)}", edited.events)

    def _rehome_stamp_row(self, value: int) -> None:
        """The panel's Event spin: move the clicked placement to that event.
        The panel is rebuilt rather than refreshed in place -- the row it
        described is another event's now, and every closure named the old
        one -- which is safe here because the spin box's commit has
        returned by the time the describe runs."""
        placement = self._selected_placement()
        if placement is None:
            return
        self.rehome_event_row(*placement, value)

    def _reorder_stamp_row(self, value: int) -> None:
        """The panel's reveal-order spin: move the clicked placement to that
        position in its event's animation, and keep the panel's widgets --
        the edit arrived from one of them, exactly :meth:`commit_field`'s
        trap, so the describe is suppressed and the rows refresh in place."""
        placement = self._selected_placement()
        if placement is None:
            return
        event, entry = placement
        rows = len(self.document.events[event])
        to = max(0, min(value - 1, rows - 1))
        edited = self.document.stamp_reordered(event, entry, to)
        if edited is self.document:
            return
        self._stamp_hits = frozenset({(event, to)})
        self._panel_commit = True
        try:
            self._commit(edited)
        finally:
            self._panel_commit = False
        record = StampEntry(self.document, self.selection.keys)
        self._properties.refresh(self._stamp_fields(record), record)

    def _cell_of(self, point: QPoint) -> int | None:
        x, y = point.x() // BLOCK, point.y() // BLOCK
        if not (0 <= x < COLUMNS and 0 <= y < ROWS):
            return None
        return cell_index(x, y)

    def _tile_of(self, point: QPoint) -> int | None:
        tx, ty = point.x() // TILE, point.y() // TILE
        if not (0 <= tx < _LAYER2_SIDE and 0 <= ty < 2 * _LAYER2_SIDE):
            return None
        return layer2_index(tx, ty % _LAYER2_SIDE, ty >= _LAYER2_SIDE)

    def _boxed(self) -> Selection:
        """What the marquee holds as it stands.

        Stamp mode is the one kind whose keys are not what the box catches:
        the keys are sheet bytes, and the *placements* it caught are noted
        beside them, because a block used twice in one event has one set of
        bytes and two footprints. Every other kind is its keys and nothing
        else, added to whatever a shift-box started from.
        """
        if self._marquee_kind is Kind.STAMPS:
            self._stamp_hits = self._boxed_placements()
            return Selection(Kind.STAMPS, self._held_keys())
        if self._marquee_kind in TRANSFER_KINDS:
            return self._boxed_transfers()
        return Selection(self._marquee_kind, self._marquee_from | self._caught())

    def _boxed_transfers(self) -> Selection:
        """What a box over the transfers holds: the warps it touches, or the
        path exits where it touches no warp.

        Both tables are on the picture and a box can cross either, but a
        selection holds one kind (:class:`Selection`) -- so the two are ranked
        rather than mixed. The warps first, being the more numerous table and
        the one an empty stretch of map falls back to; a box meaning the
        exits is drawn where no warp is, and the status line says which kind
        it came away with. A shift-box adds to what is held, so it catches
        that table alone -- see :meth:`drag_started`.
        """
        assert self._marquee is not None
        box = box_between(*self._marquee)
        caught = {
            kind: frozenset(
                marker.entry
                for marker in self._transfer_markers(kind)
                if box.intersects(marker.rect)
            )
            for kind in (Kind.WARPS, Kind.EXITS)
        }
        if self._marquee_from:
            kind = self._marquee_kind
            return Selection(kind, self._marquee_from | caught[kind])
        kind = Kind.WARPS if caught[Kind.WARPS] else Kind.EXITS
        return Selection(kind, caught[kind])

    def _boxed_placements(self) -> frozenset[tuple[int, int]]:
        """Every placement of the focused event the box touches.

        One event's, because that is what makes a box over the stamps mean
        something: the selection is one entry table's rows, so the panel and
        the table editor have one row list to act on. The focus is what picks
        it -- :meth:`_shown_events` is that event alone, so the index the box
        is read against holds nothing else and the rule needs no second test.
        """
        assert self._marquee is not None
        box = box_between(*self._marquee)
        found = set()
        for index, (event, held, _offset) in stamp_index(
            self._stamps_shot(), self._shown_events()
        ).items():
            # A silent tile's stamp has no entry-table row to hold.
            if held < 0 or not box.intersects(self._tile_rect(index)):
                continue
            entry = self._entry_within(event, held)
            if entry is not None:
                found.add((event, entry))
        return frozenset(found)

    def _caught(self) -> frozenset[int]:
        """Every spot of the marquee's kind its box intersects.

        Stamp mode is not here -- its box catches placements rather than
        spots, and :meth:`_boxed_placements` is that; nor are the transfers,
        which rank two tables and answer with the kind as well as the keys
        (:meth:`_boxed_transfers`). So the grid is the kind's own: 8x8 tiles
        on Layer 2 and on a sheet, 16x16 cells on Layer 1. The sprite markers
        catch by their own reach instead of by a grid, since a record is
        somewhere rather than being a cell.
        """
        assert self._marquee is not None
        box = box_between(*self._marquee)
        if self._marquee_kind is Kind.SPRITES:
            return frozenset(
                marker.sprite.slot
                for marker in self._visible_markers()
                if box.intersects(marker.rect)
            )
        on_sheet = self._marquee_kind is Kind.SHEET
        on_tiles = self._marquee_kind is Kind.TILES or on_sheet
        side = TILE if on_tiles else BLOCK
        if on_sheet:
            columns, rows = sheet_grid(small=self._sheet.small)
        elif on_tiles:
            columns, rows = _LAYER2_SIDE, 2 * _LAYER2_SIDE
        else:
            columns, rows = COLUMNS, ROWS
        left, right = box.left() // side, box.right() // side
        top, bottom = box.top() // side, box.bottom() // side
        spots = [
            (x, y)
            for y in range(max(0, top), min(rows - 1, bottom) + 1)
            for x in range(max(0, left), min(columns - 1, right) + 1)
        ]
        if on_sheet:
            found = (self._sheet_spot(x, y) for x, y in spots)
            return frozenset(offset for offset in found if offset is not None)
        if on_tiles:
            return frozenset(
                layer2_index(x, y % _LAYER2_SIDE, y >= _LAYER2_SIDE) for x, y in spots
            )
        return frozenset(cell_index(x, y) for x, y in spots)

    def _cells_between(self, before: WorldMap, after: WorldMap) -> list[int]:
        """Every 16x16 cell two documents' pictures disagree about -- their
        drawn parts through :meth:`_parts_between`, which is the same diff
        over the replayed pair."""
        return self._parts_between(
            (before.tiles, before.layer2), (after.tiles, after.layer2)
        )

    def _stamps_between(self, before: WorldMap, after: WorldMap) -> list[int]:
        """Every sheet offset two documents' stamp entries disagree about --
        both tables, since the game reads them as one entry."""
        if not before.stamps or not after.stamps:
            return []
        moved = set(changed_stamps(before.stamps, after.stamps))
        moved.update(changed_stamps(before.stamp_props, after.stamp_props))
        return sorted(moved)

    def _redraw(self, before: WorldMap, after: WorldMap | None = None) -> None:
        """Bring the picture on the canvas up to date with the change from
        ``before`` to ``after`` -- the document, unless a stroke's or a
        float's working copy is ahead of it.

        The one call every edit path makes, so which picture is up is
        decided in a single place. The map's events twin is left alone while
        a sheet is: a stamp edit moves it wherever the block is used, and
        re-replaying per stroke step for a picture nobody is looking at is
        exactly the work :meth:`set_sheet_view` does once on the way back.
        """
        source = after if after is not None else self.document
        if self._sheet_up:
            self._repaint_sheet(self._stamps_between(before, source), of=source)
            return
        self._repaint(self._cells_between(before, source), of=source)

    def _repaint_sheet(self, offsets: list[int], of: WorldMap | None = None) -> None:
        """Patch just these entries into the sheet's picture and show it."""
        if not offsets or self._sheet.image is None:
            return
        assert self._snapshot is not None
        source = of if of is not None else self.document
        image = self._sheet.patch(source, self._snapshot, offsets, self._painter)
        if image is not None:
            self._canvas.set_image(image)

    def _repaint(self, cells: list[int], of: WorldMap | None = None) -> None:
        """Patch just these cells into the picture and show it.

        ``of`` is the document to draw from -- the held one, unless a
        stroke's working copy is ahead of it. When the events twin exists it
        is patched too -- :meth:`_retwin`.
        """
        assert self._snapshot is not None
        source = of if of is not None else self.document
        patched = False
        if cells:
            self._picture.patch(
                self._snapshot,
                source.tiles,
                source.layer2 or None,
                cells,
                self._painters,
            )
            patched = True
        if self._picture.has_events:
            patched = self._retwin(source) or patched
        if patched and self._picture.image is not None:
            self._canvas.set_image(self._picture.image)

    @staticmethod
    def _parts_between(
        before: tuple[bytes, bytes], after: tuple[bytes, bytes]
    ) -> list[int]:
        """Every 16x16 cell two ``(tiles, layer2)`` pairs disagree about: a
        Layer 1 cell each, and the cell each changed Layer 2 entry sits in."""
        cells = set(changed_cells(before[0], after[0]))
        cells.update(
            layer2_cell(index) for index in changed_layer2(before[1], after[1])
        )
        return sorted(cells)

    def _draw_layer2(self, words: Sequence[int]) -> list[QImage]:
        """The palette's Layer 2 thumbnailer, over this snapshot's graphics."""
        if self._snapshot is None:
            return []
        return [
            raster_to_image(raster)
            for raster in layer2_thumbnails(
                self._snapshot, words, painter=self._painter
            )
        ]

    def _draw_stamps(self, small: bool) -> list[QImage]:
        """The palette's stamp thumbnailer: one image per block of the asked
        sheet, drawn from the document's own bytes."""
        if self._snapshot is None or not self.ready or not self.document.stamps:
            return []
        return [
            raster_to_image(raster)
            for raster in stamp_thumbnails(
                self.document, self._snapshot, small=small, painter=self._painter
            )
        ]

    def _settle_selection(self) -> None:
        self._refresh_marks()
        self._describe_selection()
        self._changed()

    def _refresh_marks(self) -> None:
        self._canvas.set_overlays(self._overlays())

    def _selection_rects(self) -> tuple[QRect, ...]:
        if self.selection.kind is Kind.SPRITES:
            # The ants ride every copy of the selected slots, drag included.
            return tuple(
                marker.rect
                for marker in self._visible_markers(self._sprite_drag)
                if marker.sprite.slot in self.selection.keys
            )
        if self.selection.kind in TRANSFER_KINDS:
            # The ants ride the trigger marks, drag included -- the cell the
            # entry names, not the cell it lands on, which wears the ring.
            return tuple(
                marker.rect
                for marker in self._transfer_markers(
                    self.selection.kind, self._transfer_drag
                )
                if marker.entry in self.selection.keys
            )
        if self.selection.kind is Kind.SILENT:
            # The ants ride the slot's own mark, drag included.
            return tuple(
                marker.rect
                for marker in self._silent_markers(self._silent_drag)
                if marker.slot in self.selection.keys
            )
        if self.selection.kind is Kind.DESTROY:
            return tuple(
                marker.rect
                for marker in self._destroy_markers(self._destroy_drag)
                if marker.slot in self.selection.keys
            )
        if self.selection.kind is Kind.SUBS:
            return tuple(
                marker.rect
                for marker in self._subs_markers(self._subs_drag)
                if marker.event in self.selection.keys
            )
        if self.selection.kind is Kind.TILES:
            return tuple(
                self._tile_rect(index) for index in sorted(self.selection.keys)
            )
        if self.selection.kind is Kind.SHEET:
            return tuple(
                QRect(tx * TILE, ty * TILE, TILE, TILE)
                for tx, ty in (
                    sheet_tile(offset) for offset in sorted(self.selection.keys)
                )
            )
        if self.selection.kind is Kind.STAMPS:
            held = self._held_placements()
            if held:
                # The gesture named placements: the ants ride their own
                # footprints, not the block's other uses.
                return tuple(self._placement_rect(*at) for at in sorted(held))
            # A stamp byte is selected everywhere it is used: the ants are
            # honest about what an edit to it will repaint.
            uses = stamp_uses(self._stamps_shot(), self._shown_events())
            return tuple(
                self._tile_rect(index)
                for offset in sorted(self.selection.keys)
                for index in uses.get(offset, ())
            )
        return tuple(
            QRect(x * BLOCK, y * BLOCK, BLOCK, BLOCK)
            for x, y in sorted(cell_at(index) for index in self.selection.keys)
        )

    def _placement_rect(self, event: int, entry: int) -> QRect:
        """Where one entry-table row's block sits on the map."""
        sheet, destination = self.document.events[event][entry]
        side = 2 if sheet >= SHEET_6X6_SIZE else 6
        tx, ty, submap_area = layer2_at(destination // 2)
        ty += _LAYER2_SIDE if submap_area else 0
        return QRect(tx * TILE, ty * TILE, side * TILE, side * TILE)

    @staticmethod
    def _tile_rect(index: int) -> QRect:
        tx, ty, submap_area = layer2_at(index)
        return QRect(
            tx * TILE,
            (ty + (_LAYER2_SIDE if submap_area else 0)) * TILE,
            TILE,
            TILE,
        )

    def _overlays(self) -> list[Overlay]:
        if self._sheet_up:
            return self._sheet_overlays()
        marks: list[Overlay] = []
        # The focus wash first, directly over the picture: everything the
        # focused event does not touch dims, and every mark -- the frame,
        # the tile marks, the ants -- stays at full strength on top.
        if self._picture.showing_events and self._focus_event is not None:
            # A missed conditional target stays lit -- the event names the
            # cell -- so it is kept out of the dim and tinted red instead:
            # running the event here would change nothing.
            kept = frozenset(self._focus_tiles) | frozenset(self._focus_missed)
            for strip in _focus_strips(kept):
                marks.append(Overlay(strip, _NO_LINE, image=focus_dim()))
            for index in self._focus_missed:
                marks.append(
                    Overlay(self._tile_rect(index), _NO_LINE, image=focus_miss())
                )
        # The frame next, under every mark. The main map's is its page's
        # box in the screen grid's treatment. A submap's camera is fixed on
        # one console screen, and the Layer 3 border covers most of that
        # screen's edges -- so its frame is the strips the border covers,
        # washed out, and the window they leave open is the frame's only
        # edge: no box of its own, so the mark never reads as a selection.
        # The mask is unclamped: a strip hanging past the page still says
        # "the console shows border here", wherever it falls on the picture.
        if self._show_frame:
            if self._submap:
                screen = QRect(*submap_screen(self._submap))
                window = QRect(*submap_window(self._submap))
                for strip in _border_strips(screen, window):
                    marks.append(Overlay(strip, _NO_LINE, image=border_mask()))
            else:
                marks.append(Overlay(self._region, SCREEN_LINE_COLOR))
        # The tile marks next, still scenery: how the paths connect.
        if self._show_tile_marks:
            marks += self._tile_marks()
        # The sprite markers, so the selection ants and the placing
        # ghost draw over them. Every shown slot, dimmed where empty.
        for marker in self._visible_markers(self._sprite_drag):
            marks.append(
                Overlay(
                    marker.rect,
                    _NO_LINE,
                    image=self._marker_image(
                        marker.sprite.sprite_id, main_half=not marker.submap_half
                    )
                    if marker.sprite.sprite_id
                    else glyph_image(0),
                    opacity=1.0 if marker.sprite.sprite_id else EMPTY_OPACITY,
                )
            )
        # The test-run marks, under the selection so its ants stay on top:
        # amber for a completed level, orange for one beaten both ways, and
        # the spawn marker last of the three, over any mark it shares a cell
        # with. The marker is the player's own captured figure standing where
        # the run starts -- the game's default spawn until a middle click
        # moves it, exactly the level marker's contract -- and a capture that
        # answered no figure keeps the green box, then only for a moved spawn:
        # the default needs no box saying where it already is.
        for index, secret in sorted(self.completed.items()):
            marks += self._test_mark(
                index, SECRET_MARK_COLOR if secret else COMPLETED_MARK_COLOR
            )
        if self._player_image is not None:
            image, corner = self._player_image
            x, y = (
                cell_at(self.test_spawn)
                if self.test_spawn is not None
                else spawn_cell(DEFAULT_SPAWN)
            )
            # Anchored at the node's center pixel, the position the game's
            # own position words hold for a player standing on a cell -- the
            # captured tiles carry their offsets from exactly that point.
            anchor = QPoint(x * BLOCK + BLOCK // 2, y * BLOCK + BLOCK // 2)
            box = QRect(anchor + corner, image.size())
            marks.append(Overlay(box, _NO_LINE, image=image))
        elif self.test_spawn is not None:
            marks += self._test_mark(self.test_spawn, SPAWN_MARK_COLOR)
        # The warp and path-exit triggers and where each of them leads,
        # while the transfers are what is being edited -- under the ants,
        # which mark the one selected entry on top of them.
        marks += self._transfer_marks()
        # The other event tables' records, while the stamps are -- each in
        # its own key, so the kinds of event work are told apart at a glance
        # on the one picture that shows them all. Drawn in the reverse of
        # the order a click resolves them, so the mark on top is the one a
        # click there selects.
        marks += self._subs_marks()
        marks += self._destroy_marks()
        marks += self._silent_marks()
        # Where a selected warp or exit cell leads, under the ants.
        marks += self._connector_marks()
        marks += self._ant_marks()
        marks += self._marquee_marks()
        if self._placing is not None and self._placing_at is not None:
            if isinstance(self._placing, SpritePick):
                x, y = self._placing_at
                box = self._sprite_boxes.get(
                    self._placing.sprite_id, QRect(0, 0, BLOCK, BLOCK)
                ).translated(x, y)
            elif isinstance(self._placing, Layer1Tile):
                x, y = cell_at(self._placing_at)
                box = QRect(x * BLOCK, y * BLOCK, BLOCK, BLOCK)
            elif isinstance(self._placing, StampBlock):
                tx, ty = self._placing_at
                side = self._placing.side * TILE
                box = QRect(tx * TILE, ty * TILE, side, side)
            else:
                tx, ty, submap_area = layer2_at(self._placing_at)
                box = QRect(
                    tx * TILE,
                    (ty + (_LAYER2_SIDE if submap_area else 0)) * TILE,
                    TILE,
                    TILE,
                )
            marks.append(
                Overlay(
                    box,
                    SELECTION_LINE,
                    image=self._placing_image,
                    opacity=PLACING_OPACITY,
                )
            )
            marks.append(Overlay(box, PLACING_COLOR, dash=DASH_LENGTH))
        if self._stamp_drag is not None:
            # The block's footprint at the pointer, in the placing treatment:
            # the move lands where the outline sits.
            box = self._stamp_drag.rect
            marks.append(Overlay(box, SELECTION_LINE))
            marks.append(Overlay(box, PLACING_COLOR, dash=DASH_LENGTH))
        return marks

    def _marquee_marks(self) -> list[Overlay]:
        """The box being swept, where its kind is one that draws one -- see
        :data:`BOXED_KINDS`. Nothing at all otherwise, drag or no drag."""
        if self._marquee is None or self._marquee_kind not in BOXED_KINDS:
            return []
        box = box_between(*self._marquee)
        return [
            Overlay(box, SELECTION_LINE),
            Overlay(box, MARQUEE_COLOR, dash=DASH_LENGTH),
        ]

    def _ant_marks(self) -> list[Overlay]:
        """The selection's marching ants: one bounding stroke carrying every
        held spot's own box, in whichever grid the kind counts in."""
        if not self.selection:
            return []
        cells = self._selection_rects()
        if not cells:
            return []
        bounding = cells[0]
        for cell in cells[1:]:
            bounding = bounding.united(cell)
        return [
            Overlay(bounding, color, dash=dash, cells=cells)
            for color, dash in ((SELECTION_LINE, 0), (SELECTION_DASH, DASH_LENGTH))
        ]

    def _sheet_overlays(self) -> list[Overlay]:
        """What rides a sheet's picture: the selection's ants, a marquee in
        flight, and the ghost of the word in hand.

        Nothing else. The frame, the tile marks, the sprite markers, the
        connectors and the focus wash are all statements about a map that is
        not on the canvas -- and the block grid is the canvas's own screen
        grid, set up with the picture.
        """
        marks = self._ant_marks()
        marks += self._marquee_marks()
        if self._placing is not None and isinstance(self._placing_at, int):
            tx, ty = sheet_tile(self._placing_at)
            box = QRect(tx * TILE, ty * TILE, TILE, TILE)
            marks.append(
                Overlay(
                    box,
                    SELECTION_LINE,
                    image=self._placing_image,
                    opacity=PLACING_OPACITY,
                )
            )
            marks.append(Overlay(box, PLACING_COLOR, dash=DASH_LENGTH))
        return marks

    def _tile_marks(self) -> list[Overlay]:
        """One mark per functional tile: what the walker does with it.

        A path tile draws its own step vector -- the game's, so a diagonal
        path reads as a diagonal -- hued by function, and in the exit teal
        where stepping onto it leaves the map. A warp tile wears the tile
        palette's own magenta wedge in its top-right corner -- the one mark
        drawn the same shape in both keys, since it has no number to be said
        with -- clear of the two labels a level cell carries on its left. A
        numbered level tile wears an arrow per exit at the edge its clear
        walks off, the secret exit's only where it differs -- the table
        carries a value either way, and a second arrow repeating the first
        would be noise on every level without a secret exit -- and its
        clear's event number as a label, for the levels that fire one. A level
        cell also wears its **level number** in its top-left corner, and its
        event in the opposite one -- name and consequence, told apart by corner
        and colour rather than by being read. The functions
        read the **shown** tilemap, so the events view marks the paths the
        replay reveals; the arrows stay the document's, as the translevels
        do.
        """
        walk_table = self.document.directions or (
            self._snapshot.level_directions if self._snapshot else b""
        )
        translevels = self.document.translevels
        marks: list[Overlay] = []
        for index, tile in enumerate(self.shown_tiles):
            function = tile_function(tile)
            if function is TileFunction.NONE:
                continue
            x, y = cell_at(index)
            left, top = x * BLOCK, y * BLOCK
            hue = path_hue(tile)
            if hue is not None:
                step = path_step(tile)
                assert step is not None
                box = QRect(left, top, BLOCK, BLOCK)
                marks += self._two_stroke(box, hue, line=step)
                continue
            if function in (TileFunction.STAR_WARP, TileFunction.PIPE_WARP):
                marks.append(
                    Overlay(
                        QRect(left, top, BLOCK, BLOCK),
                        WARP_MARK_COLOR,
                        wedge=BLOCK * WARP_WEDGE,
                    )
                )
            translevel = translevels[index]
            # What the level is called, in the corner a screen number takes.
            # Its *level* number rather than the translevel the tables are
            # indexed by: that is what the level list, the title bar and every
            # dialog name it, and a submap cell's two numbers differ.
            level = self.document.level_of(translevel, bool(index & 0x400))
            if level is not None:
                marks.append(
                    Overlay(
                        QRect(left, top, BLOCK, BLOCK),
                        LEVEL_LABEL_COLOR,
                        label=f"{level:03X}",
                    )
                )
            if translevel and translevel < len(walk_table):
                byte = walk_table[translevel]
                regular, secret = (byte >> 6) & 3, (byte >> 4) & 3
                marks += self._two_stroke(
                    self._arrow_box(left, top, regular),
                    WALK_CLEAR_COLOR,
                    arrow=WALK_VECTORS[regular],
                )
                if secret != regular:
                    marks += self._two_stroke(
                        self._arrow_box(left, top, secret),
                        WALK_SECRET_COLOR,
                        arrow=WALK_VECTORS[secret],
                    )
            # The event the level's clear fires, in the far corner from the
            # level number so the two never collide. Indexed by the translevel
            # the scan just handed out, so an edit that renumbers the levels
            # moves every label with them on the next refresh.
            events = self._level_events_table()
            if translevel and translevel < len(events):
                event = events[translevel]
                if event != NO_EVENT:
                    marks.append(
                        Overlay(
                            QRect(left, top, BLOCK, BLOCK),
                            EVENT_LABEL_COLOR,
                            label=f"{event:02X}",
                            label_bottom=True,
                        )
                    )
        return marks

    def _transfer_marks(self) -> list[Overlay]:
        """Every warp and path-exit entry, while the transfers are the layer
        being edited: a two-tone outline on its trigger cell with its entry
        number boxed in the corner, in its own table's hue -- and, for the
        entries that are **selected**, where each one leads.

        Every record is marked at once, because "which cells carry the player
        off this map" is the question the mode is opened to answer. Where
        they go is a different question, asked of one record at a time:
        twenty-seven warps and their exits all reaching across the page would
        be spaghetti rather than a graph, so the connector is the selection's
        and follows it, exactly as a selected *cell*'s connector does
        (:meth:`_connector_marks`).

        **The hue is which table**, magenta for a warp and teal for a path
        exit, because the entry numbers cannot be: the tables number their
        rows apiece, so two marks reading ``05`` are two records and the
        colour is what says so. Both are the map key's own hues for those
        transfers, the ones the connectors and the tile marks already wear.

        The connector ends in a **ring on the landing cell** -- the segment's
        own endcap (:attr:`~shiny_mushroom.ui.canvas.Overlay.line_cap`), one
        stroke of one pen, rather than an arrowhead drawn beside it: both
        transfers are one-way, each direction of a two-way pipe being its own
        entry, and a line that stops in a ring stops somewhere without a
        second mark to read. Drawn under the marks, because a connector is an
        aside about one record and the marks are every record there is.
        """
        marks: list[Overlay] = []
        leads: list[Overlay] = []
        for marker in self._all_transfer_markers(self._transfer_drag):
            marks += self._record_outline(marker.rect, marker.table.mark)
            marks.append(
                Overlay(
                    marker.rect,
                    marker.table.label,
                    label=f"{marker.entry:02X}",
                    label_right=True,
                )
            )
            span = marker.span
            if self._transfer_held(marker) and span != (0, 0):
                leads += self._two_stroke(
                    marker.rect | marker.landing_rect,
                    marker.table.mark,
                    line=span,
                    line_cap=LANDING_CAP,
                )
        # The connectors under every mark, not among them: a landing cell is
        # very often a trigger of its own, and a line crossing a mark is an
        # aside crossing the record it is about.
        return leads + marks

    def _transfer_held(self, marker: TransferMarker) -> bool:
        """Whether ``marker``'s entry is the selected one -- what decides
        that its connector is drawn."""
        return (
            self.selection.kind is _kind_of(marker.table)
            and marker.entry in self.selection.keys
        )

    def _silent_marks(self) -> list[Overlay]:
        """Every shown silent slot's mark: an outline in the silent slate
        around the slot's footprint -- the block it stamps, or the one cell
        its Layer 1 write lands on -- with the slot's event as a corner
        label.

        Drawn lowest slot last, on top, matching what a click selects --
        the game applies the block from the last slot down, so the lowest
        slot's write is the one on the picture.
        """
        marks: list[Overlay] = []
        for marker in reversed(self._silent_markers(self._silent_drag)):
            marks += self._record_outline(marker.rect, SILENT_MARK_COLOR)
            marks.append(
                Overlay(
                    marker.rect,
                    SILENT_LABEL_COLOR,
                    label=f"{marker.event:02X}",
                )
            )
        return marks

    def _destroy_marks(self) -> list[Overlay]:
        """Every shown destroyed-tile slot's mark: an outline in the rubble
        red around the cell the demolition crushes -- both cells, where the
        map's tile there is a two-cell ruin's -- with the slot's event as a
        corner label.

        Drawn in slot order, so the highest-numbered slot -- the one the
        scan finds first -- lands on top, matching what a click selects.
        """
        marks: list[Overlay] = []
        for marker in self._destroy_markers(self._destroy_drag):
            marks += self._record_outline(marker.rect, DESTROY_MARK_COLOR)
            marks.append(
                Overlay(marker.rect, DESTROY_LABEL_COLOR, label=f"{marker.event:02X}")
            )
        return marks

    def _subs_marks(self) -> list[Overlay]:
        """Every shown substitution row's mark: an outline in the
        substitution gold around the cell the event's tile swap aims at --
        both cells, where the map's tile there matches the doubled pair --
        with the event as a corner label.

        Drawn in event order, so the highest-numbered event -- the one whose
        write pass 1 lands last -- sits on top, matching what a click
        selects.
        """
        marks: list[Overlay] = []
        for marker in self._subs_markers(self._subs_drag):
            marks += self._record_outline(marker.rect, SUBS_MARK_COLOR)
            marks.append(
                Overlay(marker.rect, SUBS_LABEL_COLOR, label=f"{marker.event:02X}")
            )
        return marks

    @staticmethod
    def _record_outline(box: QRect, color: QColor) -> list[Overlay]:
        """An event-table record's mark: a solid outline around its
        footprint, in its table's hue, over a black line just outside it.

        Two solid lines touching rather than the ants' dashes: a record's
        mark is furniture about the spot and not a selection, and a solid box
        in a hue the ants never wear cannot be mistaken for one.
        The black outer line is what keeps the colour legible over artwork
        of any brightness -- and it is the line the ants replace when the
        record is selected, so the hue stays beside them.
        """
        return [
            Overlay(box, SELECTION_LINE),
            Overlay(box, color, inset=RECORD_OUTLINE_INSET),
        ]

    def _connector_marks(self) -> list[Overlay]:
        """Where each selected warp or exit cell leads: a dashed connector
        to the destination cell, and a box around it.

        Selection-driven rather than always on -- forty connectors crossing
        the page seam at once would be spaghetti, and "where does this go"
        is asked of one tile at a time. Both transfers are keyed on the
        game's hardcoded *positions*, so the connector follows the cell,
        exactly as the transfer would, wherever the trigger tile is.
        """
        if self.selection.kind is not Kind.CELLS:
            return []
        marks: list[Overlay] = []
        for index in sorted(self.selection.keys):
            for links, color in (
                (warp_links(self.document.warps), WARP_MARK_COLOR),
                (exit_links(self.document.exits), EXIT_MARK_COLOR),
            ):
                destination = links.get(index)
                if destination is None:
                    continue
                x1, y1 = cell_at(index)
                x2, y2 = destination
                here = QRect(x1 * BLOCK, y1 * BLOCK, BLOCK, BLOCK)
                there = QRect(x2 * BLOCK, y2 * BLOCK, BLOCK, BLOCK)
                # The united box centres the segment on the two cells'
                # midpoint, which is what the line primitive draws around.
                span = ((x2 - x1) * BLOCK, (y2 - y1) * BLOCK)
                marks.append(
                    Overlay(
                        here | there,
                        SELECTION_LINE,
                        width=MARK_LINE_WIDTH,
                        line=span,
                    )
                )
                marks.append(
                    Overlay(
                        here | there,
                        color,
                        width=MARK_LINE_WIDTH,
                        dash=CONNECTOR_DASH,
                        line=span,
                    )
                )
                marks.append(Overlay(there, SELECTION_LINE))
                marks.append(Overlay(there, color, dash=DASH_LENGTH))
        return marks

    @staticmethod
    def _two_stroke(
        box: QRect,
        color: QColor,
        arrow: tuple[int, int] | None = None,
        line: tuple[int, int] | None = None,
        line_cap: float = 0.0,
    ) -> list[Overlay]:
        """One vector mark worn twice: the black understroke, then the
        colour over it -- the ants' two lines, worn by strokes."""
        return [
            Overlay(
                box,
                SELECTION_LINE,
                width=MARK_UNDER_WIDTH,
                arrow=arrow,
                line=line,
                line_cap=line_cap,
            ),
            Overlay(
                box,
                color,
                width=MARK_LINE_WIDTH,
                arrow=arrow,
                line=line,
                line_cap=line_cap,
            ),
        ]

    @staticmethod
    def _arrow_box(left: int, top: int, code: int) -> QRect:
        """Where a walk arrow sits: the half-block box against the cell's
        edge in the walk's own direction."""
        dx, dy = WALK_VECTORS[code]
        side = BLOCK // 2
        return QRect(left + 4 + dx * 4, top + 4 + dy * 4, side, side)

    @staticmethod
    def _test_mark(index: int, color: QColor) -> list[Overlay]:
        """One test-run mark: the ants' two-line treatment in its own hue."""
        x, y = cell_at(index)
        box = QRect(x * BLOCK, y * BLOCK, BLOCK, BLOCK)
        return [
            Overlay(box, SELECTION_LINE),
            Overlay(box, color, dash=DASH_LENGTH),
        ]

    def _record_status(self, point: QPoint, index: int | None) -> str | None:
        """The status line for a silent or destroyed-tile mark under the
        pointer, or ``None`` where a placement outranks them or nothing
        record-shaped is there.

        A placement's tile keeps its stamp-byte line -- the placement is
        what a click there selects -- so the marks only answer where the
        pixels under the pointer are theirs.
        """
        if index is not None:
            tile = self._tile_of(point)
            found = (
                stamp_index(self._stamps_shot(), self._shown_events()).get(tile)
                if tile is not None
                else None
            )
            if found is not None and found[1] >= 0:
                return None
        slot = self._silent_at(point)
        if slot is not None:
            event = self.document.silent_entry(slot)[0]
            x, y, stamped, _side = silent_spot(self.document, slot)
            spot = f"tile {hexspot(x, y)}" if stamped else cell_place(x, y)
            return f"silent slot {slot}  event {hexnum(event)}  {spot}"
        slot = self._destroy_at(point)
        if slot is not None:
            event, location = self.document.destroy_entry(slot)
            x, y = cell_at(min(location, TILEMAP_SIZE - 1))
            return (
                f"destroyed tile slot {slot}  event {hexnum(event)}  {cell_place(x, y)}"
            )
        found = self._subs_at(point)
        if found is not None:
            x, y = cell_at(min(self.document.subs_cell(found), TILEMAP_SIZE - 1))
            return f"event {hexnum(found)} substitution  {cell_place(x, y)}"
        return None

    def _described_at(self, kind: Kind, index: int) -> str:
        """The status line for the spot under the pointer."""
        if kind in TRANSFER_KINDS:
            table = _TABLES[kind]
            x, y = table.trigger(self.document, index)
            return (
                f"{table.noun} {hexnum(index)}  {hexspot(x, y)} -> "
                f"{table.landing_place(self.document, index)}"
            )
        if kind is Kind.TILES:
            word = self.document.layer2_entry(index) if self.document.layer2 else 0
            tx, ty, submap_area = layer2_at(index)
            spot = hexspot(tx, ty + (_LAYER2_SIDE if submap_area else 0))
            return "  ".join([spot, *self._word_parts(word)])
        if kind in (Kind.STAMPS, Kind.SHEET):
            places = len(
                stamp_uses(self._stamps_shot(), self._shown_events()).get(index, ())
            )
            named = f"stamp {hexnum(index, 3)}"
            if kind is Kind.SHEET:
                tx, ty = sheet_tile(index)
                named = f"{hexspot(tx, ty)}  {named}"
            return "  ".join(
                [
                    named,
                    *self._word_parts(self.document.stamp_word(index)),
                    f"{places} place{'' if places == 1 else 's'}",
                ]
            )
        x, y = cell_at(index)
        return f"{hexspot(x, y)}  tile {hexnum(self.shown_tiles[index])}"

    @staticmethod
    def _word_parts(word: int) -> list[str]:
        parts = [f"tile {hexnum(word & 0x3FF, 3)}", f"pal {(word >> 10) & 7}"]
        if word & 0x4000:
            parts.append("X flip")
        if word & 0x8000:
            parts.append("Y flip")
        if word & 0x2000:
            parts.append("priority")
        return parts

    def _describe_selection(self) -> None:
        if not self.ready or self._panel_commit:
            return
        if not self.selection:
            self._properties.show_nothing(
                NOTHING_SELECTED_SHEET if self._sheet_up else NOTHING_SELECTED
            )
            return
        if self.selection.kind is Kind.TILES:
            self._describe_tiles()
            return
        if self.selection.kind is Kind.SHEET:
            self._describe_sheet()
            return
        if self.selection.kind is Kind.STAMPS:
            self._describe_stamps()
            return
        if self.selection.kind is Kind.SPRITES:
            self._describe_sprites()
            return
        if self.selection.kind in TRANSFER_KINDS:
            self._describe_transfers()
            return
        if self.selection.kind is Kind.SILENT:
            self._describe_silent()
            return
        if self.selection.kind is Kind.DESTROY:
            self._describe_destroy()
            return
        if self.selection.kind is Kind.SUBS:
            self._describe_subs()
            return
        if len(self.selection.keys) == 1:
            assert self._snapshot is not None
            (index,) = self.selection.keys
            heading, rows = cell_properties(self.document, self._snapshot, index)
            if self._described_cell() == index:
                # A level cell with the walk table in hand, or a warp or
                # exit trigger: the same facts, with the editable rows --
                # walk directions, destination picks -- in place.
                record = CellWalk(
                    self.document,
                    index,
                    self._level_events_table(),
                    self.levels,
                )
                self._properties.show_fields(heading, self._cell_fields(record), record)
                return
            self._properties.show_properties(heading, rows)
            return
        spots = sorted(cell_at(index) for index in self.selection.keys)
        columns = 1 + max(x for x, _ in spots) - min(x for x, _ in spots)
        rows_tall = 1 + max(y for _, y in spots) - min(y for _, y in spots)
        distinct = {self.document.tile(index) for index in self.selection.keys}
        self._properties.show_properties(
            "World map",
            [
                ("Selected", f"{len(self.selection.keys)} cells"),
                ("Extent", f"{columns} x {rows_tall}"),
                ("Tiles", f"{len(distinct)} distinct"),
            ],
        )

    def _describe_tiles(self) -> None:
        """One or many Layer 2 tiles: the editable attribute fields."""
        entry = Layer2Entry(self.document, self.selection.keys)
        if len(self.selection.keys) == 1:
            (index,) = self.selection.keys
            tx, ty, submap_area = layer2_at(index)
            heading = (
                f"Layer 2 tile {hexspot(tx, ty + (_LAYER2_SIDE if submap_area else 0))}"
            )
        else:
            heading = f"{len(self.selection.keys)} Layer 2 tiles -- edits apply to all"
        self._properties.show_fields(heading, layer2_fields(entry), entry)

    def _describe_sheet(self) -> None:
        """One or many sheet entries: the Layer 2 word fields over the sheet.

        The heading counts what an edit will reach -- a sheet entry is drawn
        at every place its block is stamped, so one byte is never local.
        """
        entry = StampEntry(self.document, self.selection.keys)
        if len(self.selection.keys) == 1:
            (offset,) = self.selection.keys
            tx, ty = sheet_tile(offset)
            places = len(
                stamp_uses(self._stamps_shot(), self._shown_events()).get(offset, ())
            )
            heading = (
                f"Sheet {hexnum(offset, 3)} {hexspot(tx, ty)} -- "
                f"used at {places} place{'' if places == 1 else 's'}"
            )
        else:
            heading = f"{len(self.selection.keys)} sheet tiles -- edits apply to all"
        self._properties.show_fields(heading, layer2_fields(entry), entry)

    def _describe_stamps(self) -> None:
        """The selected event stamp bytes: the Layer 2 word fields, over the
        sheet rather than the map's own tilemap.

        A placement heads with its entry-table row -- and still says when the
        block shows elsewhere, since a recolour follows the artwork
        everywhere. A silent slot's block, which has no row, heads with what
        its bytes reach instead.
        """
        entry = StampEntry(self.document, self.selection.keys)
        shot = self._stamps_shot()
        shown = self._shown_events()
        uses = stamp_uses(shot, shown)
        placement = self._selected_placement()
        if placement is not None:
            event, row = placement
            sheet, _destination = self.document.events[event][row]
            heading = (
                f"Event {hexnum(event)} stamp {hexnum(sheet, 3)} -- "
                f"row {row + 1} of {len(self.document.events[event])}"
            )
            places = len(uses.get(sheet, ()))
            if places > 1:
                heading += f", used at {places} places"
            self._properties.show_fields(heading, self._stamp_fields(entry), entry)
            return
        held = self._held_placements()
        events = {at for at, _row in held}
        if len(held) > 1 and len(events) == 1:
            # A box's catch: one event's rows, however many blocks between
            # them. Counted in placements rather than in bytes, because
            # placements are what the gesture picked out.
            (event,) = events
            self._properties.show_fields(
                f"Event {hexnum(event)} -- {len(held)} placements, "
                f"{len(self.selection.keys)} stamp bytes; edits apply to all",
                self._stamp_fields(entry),
                entry,
            )
            return
        if len(self.selection.keys) == 1:
            (offset,) = self.selection.keys
            places = len(uses.get(offset, ()))
            events = {
                event
                for event, _entry, used in stamp_index(shot, shown).values()
                if used == offset
            }
            where = f"used at {places} place{'' if places == 1 else 's'}"
            if len(events) == 1:
                (event,) = events
                heading = f"Event {hexnum(event)} stamp {hexnum(offset, 3)} -- {where}"
            else:
                heading = f"Stamp {hexnum(offset, 3)} -- {len(events)} events, {where}"
        else:
            heading = f"{len(self.selection.keys)} event stamps -- edits apply to all"
        self._properties.show_fields(heading, self._stamp_fields(entry), entry)

    def _describe_transfers(self) -> None:
        """One warp or path-exit entry with its editable trigger, its landing
        and the pick that moves it; a box's catch of several as a readout,
        since the entries are edited one each."""
        table = _TABLES[self.selection.kind]
        if len(self.selection.keys) > 1:
            entries = sorted(self.selection.keys)
            self._properties.show_properties(
                f"{len(entries)} {table.noun} triggers",
                [
                    ("Entries", ", ".join(hexnum(entry) for entry in entries)),
                    (
                        "Land at",
                        ", ".join(
                            table.landing_place(self.document, entry)
                            for entry in entries
                        ),
                    ),
                ],
            )
            return
        (entry,) = self.selection.keys
        x, y = table.trigger(self.document, entry)
        heading = (
            f"{table.noun.capitalize()} {hexnum(entry)} -- "
            f"triggers at {cell_place(x, y)}"
        )
        if self.selection.kind is Kind.EXITS:
            path_exit = ExitEntry(self.document, entry)
            self._properties.show_fields(
                heading, exit_entry_fields(path_exit), path_exit
            )
            return
        record = WarpEntry(self.document, entry)
        self._properties.show_fields(heading, warp_entry_fields(record), record)

    def _describe_silent(self) -> None:
        """The selected silent slot: the same editable columns its table row
        offers -- event, layer, X/Y in the layer's own grain, and the tile
        or block it places."""
        (slot,) = self.selection.keys
        record = SilentRow(self.document, slot)
        event = self.document.silent_entry(slot)[0]
        heading = f"Silent slot {slot} -- event {hexnum(event)}"
        self._properties.show_fields(heading, all_silent_row_fields(record), record)

    def _describe_destroy(self) -> None:
        """The selected destroyed-tile slot: its table row's columns --
        event, the cell, and the readouts for what stands there and what
        the demolition writes."""
        (slot,) = self.selection.keys
        record = DestroyRow(self.document, slot)
        event = self.document.destroy_entry(slot)[0]
        heading = f"Destroyed tile slot {slot} -- event {hexnum(event)}"
        self._properties.show_fields(heading, destroy_row_fields(record), record)

    def _describe_subs(self) -> None:
        """The selected event's substitution row: its table columns -- the
        cell, and the readouts for what stands there and what the swap
        writes."""
        (event,) = self.selection.keys
        record = SubsRow(self.document, event)
        heading = f"Tile substitution -- event {hexnum(event)}"
        self._properties.show_fields(heading, all_subs_row_fields(record), record)

    def _describe_sprites(self) -> None:
        """One sprite slot with its editable type and position; a marquee's
        catch of several as a readout, since the slots are edited one each."""
        if len(self.selection.keys) > 1:
            names = [
                self.document.sprite(slot).name for slot in sorted(self.selection.keys)
            ]
            self._properties.show_properties(
                f"{len(names)} sprite slots",
                [("Slots", ", ".join(str(s) for s in sorted(self.selection.keys)))]
                + [("Sprites", ", ".join(sorted(set(names))))],
            )
            return
        (slot,) = self.selection.keys
        record = SpriteSlot(self.document, slot)
        sprite = self.document.sprite(slot)
        heading = f"Sprite slot {slot} -- {sprite.name}"
        self._properties.show_fields(heading, sprite_fields(record), record)
