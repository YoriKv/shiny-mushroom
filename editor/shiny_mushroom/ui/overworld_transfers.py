"""The world map's transfer triggers as marks, and the drag that moves one.

Two of the map's tables carry the player off a cell, and neither is a tile: the
**star and pipe warps** (``SMW_HandleOverworldStarPipeWarp``'s position table,
searched from the last entry down) and the **path exits**
(``SMW_HandleOverworldPathExits_Main``'s, matched against the walking player's
exact position). The tile is only what the player has to be standing on for the
entry to be read; *which* entry fires, and where it lands, is a row of the
game's own table.

So a trigger has no artwork of its own to draw, and drawing the tile it stands
over would say nothing about the entry -- three tiles serve twenty-seven warps.
Each entry is marked the way every other record-table row on this map is marked
(``OverworldMode._record_outline``): a **two-tone outline** around the cell it
fires on, with its **entry number in a box in the corner**. There is a record
here, this is its number, and the cell under it is not what it looks like.

**The hue says which table the record is a row of**: the map key's warp magenta
for a warp, its exit teal for a path exit -- the two hues the key already
spends on those transfers, and the two the connectors a selected cell draws are
already in. Both tables are marked at once, because "where does this map's
traffic go" is one question and the two tables are two halves of the answer;
what tells them apart is the colour, since an entry numbered ``05`` is a row of
both.

The number sits in the **top-right** corner, the one corner a world-map cell's
other readouts leave free: a level cell already carries its level number at the
top-left and its event at the bottom-left, and a trigger standing on a level
cell has to be readable over both.

**Where an entry leads is drawn only while it is selected.** Twenty-seven warps
and their exits all reaching across the page at once is spaghetti, not a graph;
the marks say where every record *is*, and the selection is what asks where one
of them *goes*. What that draws is a connector ending in a small ring on the
landing cell -- the segment's own endcap, one stroke of one pen, rather than an
arrowhead beside it: both transfers are one-way, and a line that stops in a
ring stops somewhere. It runs under the marks, an aside about one record
passing beneath every record there is.

:class:`TransferTable` is what makes one piece of code serve both: the tables
differ in how their bytes are packed and in nothing else the map does with
them, so the mark, the hit test, the drag, the arrow key and the clipboard are
written once and handed the table's own readers.

The marks are canvas overlays rather than pixels in the map's buffer, as the
sprite markers are: they sit in front of the picture and a drag moves them
without repainting anything. Only the Warps/Exits tab's rows are handed an
image (:func:`mark_image`), because a list row cannot be drawn as an overlay.

:class:`TransferDrag` is the one piece of state a drag needs. A trigger is
**cell-grained** -- both tables hold a grid position, and a path exit keeps its
own sub-cell offsets through a move -- so it snaps to the cell the pointer is
over, offset by wherever on the mark it was grabbed, and the mode commits a
single move when the button comes up.

Qt here, no model: handed a document, it answers rectangles and pictures.
"""

from __future__ import annotations

from collections.abc import Callable, Iterable
from dataclasses import dataclass, replace

from PySide6.QtCore import QPoint, QRect
from PySide6.QtGui import QColor, QImage, QPainter, QPen

from shiny_mushroom.level import BLOCK
from shiny_mushroom.overworld import (
    COLUMNS,
    EXIT_REGION,
    ROWS,
    WARP_REGION,
    WorldMap,
    exit_landing,
    exit_landing_place,
    exit_trigger,
    warp_landing,
    warp_landing_place,
    warp_trigger,
)
from shiny_mushroom.ui.canvas import MARK_OUTLINE, draw_label
from shiny_mushroom.ui.overworld_events import RECORD_OUTLINE_INSET
from shiny_mushroom.ui.world_marks import EXIT_MARK_COLOR, WARP_MARK_COLOR

#: What a warp's number box is filled with: the map key's warp magenta
#: (:data:`shiny_mushroom.ui.world_marks.WARP_MARK_COLOR`) in the screen
#: labels' wash, so the number reads as a readout about the mark it sits on.
#: The same statement the silent and destroyed-tile slots' labels make, in the
#: hue that says whose.
WARP_LABEL_COLOR = QColor(0xFF, 0x50, 0xE0, 0xD6)

#: A path exit's, on the same rule: the key's exit teal
#: (:data:`shiny_mushroom.ui.world_marks.EXIT_MARK_COLOR`) -- what a tile that
#: steps off to another map is already stroked in -- in the same wash, so the
#: two boxes read as one family of mark in two hues.
EXIT_LABEL_COLOR = QColor(0x00, 0xD0, 0x90, 0xD6)


@dataclass(frozen=True)
class TransferTable:
    """One transfer table's answers: what its marks read, what a drag, a
    delete or a paste of one commits, and the two hues it is drawn in.

    A descriptor rather than a second copy of this module. The two tables are
    packed differently -- four parallel word tables against three byte-record
    ones -- and :mod:`shiny_mushroom.overworld` is where that difference is
    kept; everything the *map* does with an entry is the same work on either,
    so it is written once here and handed the readers it needs.

    ``moved`` is the document method a drag or an arrow key commits through,
    which is the one place the tables' own rules still show: a warp's trigger
    is a cell and nothing else, and a path exit's keeps the sub-cell offsets
    the walking player is matched against.

    ``row``, ``appended`` and ``deleted`` are what the clipboard works in.
    A transfer is a **record**, not a value on a grid -- its bytes are spread
    across its table's parallel sections and an entry number is an identity
    rather than a position -- so a copy carries the whole row and a paste
    appends one, on the terms :meth:`~shiny_mushroom.overworld.WorldMap.
    warp_row_appended` sets.
    """

    #: What one row is called in a status line or a heading: ``warp $05``.
    noun: str
    #: The outline's line, the connector's, and the landing dot's -- the map
    #: key's own hue for this transfer.
    mark: QColor
    #: The entry-number box's fill: the same hue in the labels' wash.
    label: QColor
    #: The :mod:`smw_tools.asm_regions` region the table's bytes are the ROM
    #: image of -- what an added row is priced against.
    region: str
    entries: Callable[[WorldMap], int]
    trigger: Callable[[WorldMap, int], tuple[int, int]]
    landing: Callable[[WorldMap, int], tuple[int, int]]
    landing_place: Callable[[WorldMap, int], str]
    moved: Callable[[WorldMap, int, int, int], WorldMap]
    row: Callable[[WorldMap, int], tuple[bytes, ...]]
    appended: Callable[[WorldMap, tuple[bytes, ...]], WorldMap]
    deleted: Callable[[WorldMap, int], WorldMap]


#: The star and pipe warps, as the map draws, drags and copies them.
WARPS = TransferTable(
    noun="warp",
    mark=WARP_MARK_COLOR,
    label=WARP_LABEL_COLOR,
    region=WARP_REGION,
    entries=lambda document: document.shape.warps,
    trigger=lambda document, entry: warp_trigger(document.warps, entry),
    landing=lambda document, entry: warp_landing(document.warps, entry),
    landing_place=lambda document, entry: warp_landing_place(document.warps, entry),
    moved=lambda document, entry, x, y: document.warp_trigger_moved(entry, x, y),
    row=lambda document, entry: document.warp_row(entry),
    appended=lambda document, row: document.warp_row_appended(row),
    deleted=lambda document, entry: document.warp_deleted(entry),
)

#: The path exits, on the same terms.
EXITS = TransferTable(
    noun="path exit",
    mark=EXIT_MARK_COLOR,
    label=EXIT_LABEL_COLOR,
    region=EXIT_REGION,
    entries=lambda document: document.shape.exits,
    trigger=lambda document, entry: exit_trigger(document.exits, entry),
    landing=lambda document, entry: exit_landing(document.exits, entry),
    landing_place=lambda document, entry: exit_landing_place(document.exits, entry),
    moved=lambda document, entry, x, y: document.exit_trigger_moved(entry, x, y),
    row=lambda document, entry: document.exit_row(entry),
    appended=lambda document, row: document.exit_row_appended(row),
    deleted=lambda document, entry: document.exit_deleted(entry),
)

_images: dict[tuple[str, int, int], QImage] = {}


def mark_image(table: TransferTable, entry: int, side: int) -> QImage:
    """The mark for one entry of ``table`` as a ``side``-square picture,
    cached -- the map's own two-tone outline with the entry number boxed in
    its top-right corner, in the table's hue and transparent inside.

    For the Warps/Exits tab's rows, which take an icon rather than an
    overlay. Drawn at the size it is shown at, and the number box at the
    fixed device size the map draws it at, so the row wears the mark the map
    wears rather than a scaled copy of it.
    """
    held = _images.get((table.noun, entry, side))
    if held is not None:
        return held
    image = QImage(side, side, QImage.Format.Format_ARGB32_Premultiplied)
    image.fill(0)
    painter = QPainter(image)
    # The far edge back a pixel, exactly as the canvas takes it back: Qt
    # strokes a rectangle through the pixel past the box it is given.
    box = QRect(0, 0, side - 1, side - 1)
    painter.setPen(QPen(MARK_OUTLINE, 1.0))
    painter.drawRect(box)
    painter.setPen(QPen(table.mark, 1.0))
    inset = RECORD_OUTLINE_INSET
    painter.drawRect(box.adjusted(inset, inset, -inset, -inset))
    draw_label(painter, f"{entry:02X}", box.right(), box.top(), table.label, right=True)
    painter.end()
    _images[(table.noun, entry, side)] = image
    return image


@dataclass(frozen=True)
class TransferMarker:
    """One entry drawn: which table and entry, the cell it triggers on, and
    the cell it lands the player on.

    Both are picture cells on the stacked 512x1024 map, so the connector
    between them is geometry the caller can draw without asking the document
    anything further.
    """

    table: TransferTable
    entry: int
    trigger: tuple[int, int]
    landing: tuple[int, int]

    @property
    def rect(self) -> QRect:
        """The block the mark outlines: the trigger cell."""
        x, y = self.trigger
        return QRect(x * BLOCK, y * BLOCK, BLOCK, BLOCK)

    @property
    def landing_rect(self) -> QRect:
        x, y = self.landing
        return QRect(x * BLOCK, y * BLOCK, BLOCK, BLOCK)

    @property
    def span(self) -> tuple[int, int]:
        """Trigger to landing, in image pixels -- the connector's extent."""
        return (
            (self.landing[0] - self.trigger[0]) * BLOCK,
            (self.landing[1] - self.trigger[1]) * BLOCK,
        )


def markers(
    document: WorldMap,
    table: TransferTable,
    moved: TransferDrag | None = None,
) -> list[TransferMarker]:
    """Every entry of ``table`` as a marker, in the table's own order.

    ``moved`` substitutes an in-flight drag's cell for its entry, so the
    mark tracks the pointer while the document waits for the release. A drag
    of the *other* table's entry is nothing to do with these markers, so it
    stands in for nothing.
    """
    found: list[TransferMarker] = []
    for entry in range(table.entries(document)):
        trigger = table.trigger(document, entry)
        if moved is not None and moved.table is table and moved.entry == entry:
            trigger = (moved.x, moved.y)
        found.append(
            TransferMarker(table, entry, trigger, table.landing(document, entry))
        )
    return found


def marker_at(shown: Iterable[TransferMarker], point: QPoint) -> TransferMarker | None:
    """The marker whose mark is under ``point``, or ``None``.

    Later wins an overlap, which is not only a drawing order: the game
    searches each table from the last entry down and takes the first match,
    so where two entries of one table share a cell the higher-numbered one is
    the one that fires. Clicking picks the entry the console would. Across
    the two tables it is the drawing order that decides, and the caller sets
    that by the order it hands the markers in.
    """
    held: TransferMarker | None = None
    for marker in shown:
        if marker.rect.contains(point):
            held = marker
    return held


@dataclass(frozen=True)
class TransferDrag:
    """A trigger mid-drag: which table's entry, and the cell it sits on right
    now.

    ``anchor`` is where inside the grabbed block the pointer took hold, in
    image pixels. Subtracting it before dividing by the block is what makes
    the mark move a cell when the pointer moves a cell, wherever on it the
    grip was taken -- rather than jumping so the pointer lands at a corner.
    """

    table: TransferTable
    entry: int
    anchor: QPoint
    x: int
    y: int

    @classmethod
    def begun(
        cls,
        document: WorldMap,
        table: TransferTable,
        entry: int,
        point: QPoint,
    ) -> TransferDrag:
        x, y = table.trigger(document, entry)
        return cls(table, entry, point - QPoint(x * BLOCK, y * BLOCK), x, y)

    def moved(self, point: QPoint) -> TransferDrag:
        """This drag with the trigger on the cell under ``point``, held
        inside the picture: a table row has to name a cell that exists."""
        left = point.x() - self.anchor.x()
        top = point.y() - self.anchor.y()
        return replace(
            self,
            x=max(0, min(COLUMNS - 1, left // BLOCK)),
            y=max(0, min(ROWS - 1, top // BLOCK)),
        )
