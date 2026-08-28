"""The event tables' slots as markers, and the drags that move them.

The stamp placements are artwork on the events view -- the replay draws them,
and stamp mode reaches them through the picture. The other event tables have
no artwork that says *a record is here*: a silent slot's block is pixels
indistinguishable from a placement's, its Layer 1 write indistinguishable from
the map's own ground, a destroyed-tile slot writes nothing at all until the
map's tile matches a ruin, and a substitution row is a cell that only changes
once its tile matches a pair. So each record gets a mark in the overlays' own
vector key, worn only while the Events row is the one being edited -- the
mode's furniture, like the warp diamonds, not a view of the map.

**Each table's mark is an outline around the record's footprint, in a hue of
its own, so the kinds of event work are told apart at a glance.** A placement
is bare artwork that answers a click; a silent slot's footprint wears the
slate blue, quieter than every other hue here -- placed offscreen with no
animation, so its mark whispers; a destroyed-tile slot's cell wears rubble
red: demolition; and an event's pass-1 substitution's cell wears gold -- one
tile becomes another. One shape for the three, because the shape is the
record's footprint and the footprint is what a drag moves; the hue and the
corner label are what say whose record it is. Every mark carries its event
number as that label, for whoever is tracing the event chain across a map
showing every event at once.

Only records naming an event the view replays are marked, and only records
that aim somewhere. A parked slot -- one whose event never runs -- or an idle
substitution row names a location that means nothing yet, and a mark on it
would be furniture about furniture; the table dialogs list every row, parked
and idle ones included, and re-aiming one is what brings its mark up.

The drags mirror the other records': a record is **grain-bound** -- a Layer 2
stamp moves in 8x8 tiles and cannot straddle the page seam, exactly as a
placement drag cannot, while a Layer 1 write, a destroyed cell and a
substitution cell move in 16x16 cells as a warp trigger does -- and the mode
commits one move when the button comes up.

Qt here, no model: handed a document, it answers rectangles.
"""

from __future__ import annotations

from collections.abc import Container, Iterable
from dataclasses import dataclass, replace

from PySide6.QtCore import QPoint, QRect
from PySide6.QtGui import QColor

from shiny_mushroom.level import BLOCK, TILE
from shiny_mushroom.overworld import (
    COLUMNS,
    DESTROY_TWO_CELL,
    LAYER2_ENTRY_COUNT,
    LAYER2_TILES,
    ROWS,
    SHEET_6X6_SIZE,
    SWAP_DOUBLED_PAIR,
    TILEMAP_SIZE,
    WorldMap,
    cell_at,
    cell_index,
    layer2_at,
    layer2_index,
)
from shiny_mushroom.overworld_fields import ruin_kind_at, swap_pair_at

#: A silent slot's hue: a slate blue desaturated below every other mark here.
#: The loud hues all say "this changes something you can watch happen"; a
#: silent slot is applied offscreen with no animation, so its mark is the
#: quiet one -- told from the paths' saturated water blue by weight of
#: colour.
SILENT_MARK_COLOR = QColor(0x88, 0xA8, 0xD8)

#: A destroyed-tile slot's hue: rubble red, for the one table whose whole job
#: is demolition. Redder than the secret exit's orange and the completed
#: mark's amber.
DESTROY_MARK_COLOR = QColor(0xF0, 0x30, 0x28)

#: The pass-1 substitution's hue: gold, yellower than the completed mark's
#: amber -- one tile swapped for another, in the warmest hue that is not
#: the demolition's.
SUBS_MARK_COLOR = QColor(0xFF, 0xD8, 0x20)

#: How far inside its footprint a record's coloured outline is drawn: one
#: **device** pixel, so the black line is the pixel immediately outside it --
#: two solid lines touching, which is the two-tone outline every record mark
#: wears (``OverworldMode._record_outline``). Device pixels, so the two stay
#: touching at every zoom rather than opening a band of artwork between them.
RECORD_OUTLINE_INSET = 1

#: The slots' event labels: each mark's own hue in the screen labels' wash,
#: so the number reads as a readout about the mark it sits on -- the same
#: statement a level cell's event label makes, in the hue that says whose.
SILENT_LABEL_COLOR = QColor(0x88, 0xA8, 0xD8, 0xD6)
DESTROY_LABEL_COLOR = QColor(0xF0, 0x30, 0x28, 0xD6)
SUBS_LABEL_COLOR = QColor(0xFF, 0xD8, 0x20, 0xD6)


@dataclass(frozen=True)
class SilentMarker:
    """One silent slot drawn: which slot, the event that places it, and its
    footprint -- a whole sheet block for a Layer 2 slot, one cell for a
    Layer 1 write.

    ``origin`` and ``side`` count in the slot's own grain (8x8 tiles or
    16x16 cells) on the stacked picture, ``stamped`` saying which.
    """

    slot: int
    event: int
    stamped: bool
    origin: tuple[int, int]
    side: int

    @property
    def rect(self) -> QRect:
        grain = TILE if self.stamped else BLOCK
        x, y = self.origin
        return QRect(x * grain, y * grain, self.side * grain, self.side * grain)


def silent_spot(document: WorldMap, slot: int) -> tuple[int, int, bool, int]:
    """Where ``slot`` lands: ``(x, y, stamped, side)`` in its layer's own
    grain on the stacked picture -- clamped, since the game reads whatever
    location the table holds."""
    _event, layer, location, tile = document.silent_entry(slot)
    if layer & 1:
        side = 2 if tile >= SHEET_6X6_SIZE else 6
        tx, ty, submap_area = layer2_at(min(location // 2, LAYER2_ENTRY_COUNT - 1))
        return tx, ty + (LAYER2_TILES if submap_area else 0), True, side
    x, y = cell_at(min(location, TILEMAP_SIZE - 1))
    return x, y, False, 1


def silent_markers(
    document: WorldMap,
    shown: Container[int],
    moved: SilentDrag | None = None,
) -> list[SilentMarker]:
    """Every silent slot naming a ``shown`` event, in slot order.

    ``moved`` substitutes an in-flight drag's spot for its slot, so the mark
    tracks the pointer while the document waits for the release.
    """
    found: list[SilentMarker] = []
    for slot in range(document.shape.silent):
        event = document.silent_entry(slot)[0]
        if event not in shown:
            continue
        x, y, stamped, side = silent_spot(document, slot)
        if moved is not None and moved.slot == slot:
            x, y = moved.x, moved.y
        found.append(SilentMarker(slot, event, stamped, (x, y), side))
    return found


def silent_all_at(shown: Iterable[SilentMarker], point: QPoint) -> list[SilentMarker]:
    """Every silent slot whose mark is under ``point``, **topmost first**.

    The lowest-numbered slot is on top: the game applies the block from the
    last slot down, so the lowest slot's write lands last and is the one on
    the picture. The whole stack rather than its top, because a click that
    cycles has to know what is under what -- :func:`silent_at` is this
    list's head.
    """
    return [marker for marker in shown if marker.rect.contains(point)]


def silent_at(shown: Iterable[SilentMarker], point: QPoint) -> int | None:
    """The silent slot a click at ``point`` takes, or ``None`` -- the
    topmost of :func:`silent_all_at`, which is the slot the console shows."""
    found = silent_all_at(shown, point)
    return found[0].slot if found else None


@dataclass(frozen=True)
class DestroyMarker:
    """One destroyed-tile slot drawn: which slot, the event that fires it,
    and the cell it crushes -- two cells tall where the map's tile there is
    a two-cell ruin's, since the demolition writes the row below too."""

    slot: int
    event: int
    cell: tuple[int, int]
    tall: bool

    @property
    def rect(self) -> QRect:
        x, y = self.cell
        return QRect(x * BLOCK, y * BLOCK, BLOCK, BLOCK * (2 if self.tall else 1))


def destroy_markers(
    document: WorldMap,
    shown: Container[int],
    moved: DestroyDrag | None = None,
) -> list[DestroyMarker]:
    """Every destroy slot naming a ``shown`` event, in slot order --
    ``moved`` substituting an in-flight drag's cell, footprint and all, so
    the mark grows to two cells the moment it hovers a castle."""
    found: list[DestroyMarker] = []
    for slot in range(document.shape.destroy):
        event, location = document.destroy_entry(slot)
        if event not in shown:
            continue
        if moved is not None and moved.slot == slot:
            location = cell_index(moved.x, moved.y)
        kind = ruin_kind_at(document, location)
        found.append(
            DestroyMarker(
                slot,
                event,
                cell_at(min(location, TILEMAP_SIZE - 1)),
                kind is not None and kind >= DESTROY_TWO_CELL,
            )
        )
    return found


def destroy_all_at(
    shown: Iterable[DestroyMarker], point: QPoint
) -> list[DestroyMarker]:
    """Every destroy slot whose mark is under ``point``, **topmost first** --
    the highest-numbered where two share a cell, since the scan searches
    from the top down and that slot is the one that fires."""
    return [marker for marker in reversed(list(shown)) if marker.rect.contains(point)]


def destroy_at(shown: Iterable[DestroyMarker], point: QPoint) -> int | None:
    """The destroy slot a click at ``point`` takes, or ``None`` -- the
    topmost of :func:`destroy_all_at`."""
    found = destroy_all_at(shown, point)
    return found[0].slot if found else None


@dataclass(frozen=True)
class SubsMarker:
    """One event's pass-1 substitution drawn: the event, and the cell its
    tile swap aims at -- two cells wide where the map's tile there matches
    the doubled pair, which writes the next cell along too."""

    event: int
    cell: tuple[int, int]
    doubled: bool

    @property
    def rect(self) -> QRect:
        x, y = self.cell
        return QRect(x * BLOCK, y * BLOCK, BLOCK * (2 if self.doubled else 1), BLOCK)


def subs_markers(
    document: WorldMap,
    shown: Iterable[int],
    moved: SubsDrag | None = None,
) -> list[SubsMarker]:
    """Every shown event's substitution row that aims somewhere, in event
    order -- ``moved`` substituting an in-flight drag's cell, footprint and
    all, so the mark widens the moment it hovers the doubled pair's tile.

    A location of zero is skipped: the table's idle value, which the game
    does scan (cell 0 never matches on the shipped map), but a mark on cell
    (0, 0) for every idle event would bury the corner of the map -- the same
    rule the focused view's red tint follows, and the table dialog is where
    an idle event is aimed somewhere.
    """
    found: list[SubsMarker] = []
    shape = document.shape
    for event in shown:
        if not 0 <= event < shape.subs:
            continue
        location = document.subs_cell(event)
        if moved is not None and moved.event == event:
            location = cell_index(moved.x, moved.y)
        if location == 0:
            continue
        pair = swap_pair_at(document, location)
        found.append(
            SubsMarker(
                event,
                cell_at(min(location, TILEMAP_SIZE - 1)),
                pair == SWAP_DOUBLED_PAIR,
            )
        )
    return found


def subs_all_at(shown: Iterable[SubsMarker], point: QPoint) -> list[SubsMarker]:
    """Every substitution row whose mark is under ``point``, **topmost
    first** -- the highest-numbered event where two aim at one cell,
    matching the drawing order: pass 1 runs the events ascending, so the
    later event's write is the one on the picture."""
    return [marker for marker in reversed(list(shown)) if marker.rect.contains(point)]


def subs_at(shown: Iterable[SubsMarker], point: QPoint) -> int | None:
    """The substitution row a click at ``point`` takes, or ``None`` -- the
    topmost of :func:`subs_all_at`."""
    found = subs_all_at(shown, point)
    return found[0].event if found else None


@dataclass(frozen=True)
class SubsDrag:
    """A substitution row mid-drag: cell-grained like a destroyed-tile slot
    -- the table holds a Layer 1 cell index -- keyed by the event whose row
    it is."""

    event: int
    anchor: QPoint
    x: int
    y: int

    @classmethod
    def begun(cls, document: WorldMap, event: int, point: QPoint) -> SubsDrag:
        x, y = cell_at(min(document.subs_cell(event), TILEMAP_SIZE - 1))
        return cls(event, point - QPoint(x * BLOCK, y * BLOCK), x, y)

    def moved(self, point: QPoint) -> SubsDrag:
        left = point.x() - self.anchor.x()
        top = point.y() - self.anchor.y()
        return replace(
            self,
            x=max(0, min(COLUMNS - 1, left // BLOCK)),
            y=max(0, min(ROWS - 1, top // BLOCK)),
        )

    @property
    def location(self) -> int:
        return cell_index(self.x, self.y)


@dataclass(frozen=True)
class SilentDrag:
    """A silent slot mid-drag: the slot, and where its landing is right now.

    Grain-bound: a Layer 2 slot moves in 8x8 tiles and is clamped to one
    page half exactly as a placement drag is -- a block cannot straddle the
    seam the picture stacks -- and a Layer 1 slot moves in 16x16 cells.
    ``anchor`` is the grabbed grid spot minus the landing's origin, so the
    footprint tracks the pointer without jumping.
    """

    slot: int
    stamped: bool
    side: int
    anchor: tuple[int, int]
    x: int
    y: int

    @classmethod
    def begun(cls, document: WorldMap, slot: int, point: QPoint) -> SilentDrag:
        x, y, stamped, side = silent_spot(document, slot)
        grain = TILE if stamped else BLOCK
        anchor = (point.x() // grain - x, point.y() // grain - y)
        return cls(slot, stamped, side, anchor, x, y)

    def moved(self, point: QPoint) -> SilentDrag:
        """This drag with the landing under ``point``, kept on the map and
        -- for a stamp -- in one half."""
        grain = TILE if self.stamped else BLOCK
        x = point.x() // grain - self.anchor[0]
        y = point.y() // grain - self.anchor[1]
        if self.stamped:
            x = max(0, min(LAYER2_TILES - self.side, x))
            if y < LAYER2_TILES:
                y = max(0, min(LAYER2_TILES - self.side, y))
            else:
                y = max(LAYER2_TILES, min(2 * LAYER2_TILES - self.side, y))
        else:
            x = max(0, min(COLUMNS - 1, x))
            y = max(0, min(ROWS - 1, y))
        return replace(self, x=x, y=y)

    @property
    def location(self) -> int:
        """The table word the current spot means, in the layer's own
        encoding: a Layer 2 buffer byte offset, or a Layer 1 cell index."""
        if self.stamped:
            return (
                layer2_index(self.x, self.y % LAYER2_TILES, self.y >= LAYER2_TILES) * 2
            )
        return cell_index(self.x, self.y)


@dataclass(frozen=True)
class DestroyDrag:
    """A destroyed-tile slot mid-drag: cell-grained, like a warp trigger --
    the table holds a Layer 1 cell index. ``anchor`` is where inside the
    grabbed cell the pointer took hold, in image pixels."""

    slot: int
    anchor: QPoint
    x: int
    y: int

    @classmethod
    def begun(cls, document: WorldMap, slot: int, point: QPoint) -> DestroyDrag:
        _event, location = document.destroy_entry(slot)
        x, y = cell_at(min(location, TILEMAP_SIZE - 1))
        return cls(slot, point - QPoint(x * BLOCK, y * BLOCK), x, y)

    def moved(self, point: QPoint) -> DestroyDrag:
        left = point.x() - self.anchor.x()
        top = point.y() - self.anchor.y()
        return replace(
            self,
            x=max(0, min(COLUMNS - 1, left // BLOCK)),
            y=max(0, min(ROWS - 1, top // BLOCK)),
        )

    @property
    def location(self) -> int:
        return cell_index(self.x, self.y)
