"""The arithmetic behind the window's gestures, with no window in it.

A click, a drag and an arrow key all end up asking the same few questions --
which of a stack of records this one is about, how far an edge has actually been
pulled, where a copy lands, what rectangle two corners make. None of those needs
a document, a canvas or an emulator, and every one of them used to be a private
method reachable only by building a window around it.

So they are here: ordinary functions over ordinary values, which is what makes
them checkable one at a time. What a gesture *means* -- when a drag is a move
and when it is a resize, what a placement puts down -- stays with whatever owns
the document, because that is a decision about the level rather than about
geometry.

Qt's own value types are used freely. ``QPoint`` and ``QRect`` are arithmetic,
not widgets, and the whole point of this module is that it can be exercised
without a display.
"""

from __future__ import annotations

from collections.abc import Callable, Collection, Sequence
from enum import Flag, auto

from PySide6.QtCore import QPoint, QRect, Qt

from shiny_mushroom.fields import Field
from shiny_mushroom.level import BLOCK
from shiny_mushroom.objects import LevelObject
from shiny_mushroom.sprites import Sprite
from shiny_mushroom.tile_clipboard import GridStamp

# What each arrow key steps, in blocks. One block, because that is the unit a
# level is built in: the object stream addresses blocks, the tilemap is blocks,
# and a nudge that moved a pixel would be a nudge that cannot be written down.
ARROWS = {
    Qt.Key.Key_Left: (-1, 0),
    Qt.Key.Key_Right: (1, 0),
    Qt.Key.Key_Up: (0, -1),
    Qt.Key.Key_Down: (0, 1),
}

# How far a copy lands from the thing it was copied from, in blocks, when there
# is no pointer to aim it at. Diagonal so the original shows along both edges,
# and one block because that is the smallest step the level format has: any
# further and the copy would arrive somewhere nobody pointed at.
COPY_OFFSET = (1, 1)


class Grip(Flag):
    """Which of a held object's edges a gesture has taken hold of.

    **The far edges only.** A width and a height are extents measured from the
    record's own corner, so the right and bottom edges are the two the settings
    byte can actually move. Dragging the left one is a different edit -- grow
    the extent *and* move the record the other way, so the far edge stays put --
    and it is a different edit against the wrong anchor for any object that does
    not grow right and down from its position. It would also collide with the
    gesture that is already there: a drag begun on a held object moves it, and
    an object one block wide is all edge.
    """

    RIGHT = auto()
    BOTTOM = auto()


#: What the pointer says each grip is. The corner takes the diagonal that
#: matches which way it grows -- down and to the right.
GRIP_CURSORS = {
    Grip.RIGHT: Qt.CursorShape.SizeHorCursor,
    Grip.BOTTOM: Qt.CursorShape.SizeVerCursor,
    Grip.RIGHT | Grip.BOTTOM: Qt.CursorShape.SizeFDiagCursor,
}

#: How near an object's edge counts as being on it, in **device** pixels: what
#: the hand can aim at is a distance on the screen, not in the picture, and a
#: level is worked at anything from a quarter to eight times its own size.
GRIP_REACH_PX = 6

#: ...but never more than half a block in the picture, whatever the zoom says.
#: At a quarter zoom six device pixels is a block and a half, and a grip that
#: deep would swallow the object it belongs to: a drag anywhere near a small
#: ledge would resize it instead of moving it. Reduced beyond that, an edge is
#: simply too small to aim at and the keyboard is the way to resize -- which is
#: the honest answer rather than a gesture that fires when it was not meant.
GRIP_REACH_MAX = BLOCK // 2


def block_center(column: int, row: int) -> QPoint:
    """The middle of block ``(column, row)``, in image pixels.

    What every "go and look at this" hands the view: a search result, a place
    on the trail, the level a jump landed in. The middle rather than the corner
    because it is what the *view* centres on, and a corner would leave the
    thing being looked at half a block off centre at every zoom.
    """
    return QPoint(column * BLOCK + BLOCK // 2, row * BLOCK + BLOCK // 2)


def box_between(start: QPoint, end: QPoint) -> QRect:
    """The rectangle two dragged corners make.

    Normalised here rather than as a drag is recorded, because a drag is
    naturally kept as the two corners it was made from and a box drawn upwards
    and to the left has a negative width. The far edge is **inclusive**, so a
    box that has not moved is still one pixel rather than nothing -- which is
    also what lets a caller read ``right()`` and ``bottom()`` back as the
    coordinates the drag actually reached.
    """
    left, right = sorted((start.x(), end.x()))
    top, bottom = sorted((start.y(), end.y()))
    return QRect(left, top, right - left + 1, bottom - top + 1)


def snapped_box(start: QPoint, end: QPoint, side: int) -> QRect:
    """The box two dragged pixels make, grown outward to whole cells of
    ``side`` pixels.

    What a right drag over a tile grid *draws* on every surface: the cells it
    would grab, exactly as a selection there is drawn -- the pixels the
    pointer travelled between say nothing a cell does not. The far edge is
    inclusive, like :func:`box_between`'s, so the box covers every cell
    either corner is in.
    """
    box = box_between(start, end)
    left, top = box.left() // side, box.top() // side
    right, bottom = box.right() // side, box.bottom() // side
    return QRect(
        left * side, top * side, (right - left + 1) * side, (bottom - top + 1) * side
    )


#: How far a right press travels, in widget pixels, before it is a grab
#: rather than a click. The picture's own drag threshold, for the panels'
#: grids.
GRAB_THRESHOLD = 4


class RightGrab:
    """The right button over a grid widget: a press, its travel, its release
    -- up to what they mean, which is the widget's.

    The three panel grids each tracked this for themselves. A press is held
    until the release, because what it turned into -- a pick or a grab -- is
    only visible then; a press that travels :data:`GRAB_THRESHOLD` is a grab
    from there on, and its box is the two corners it was made from.
    """

    def __init__(self) -> None:
        self.press: QPoint | None = None
        #: Where the grab has reached, once the press has travelled far
        #: enough to be one -- ``None`` while it is still a press.
        self.reached: QPoint | None = None

    @property
    def dragging(self) -> bool:
        return self.reached is not None

    def begin(self, pos: QPoint) -> None:
        self.press, self.reached = QPoint(pos), None

    def move(self, pos: QPoint) -> bool:
        """Follow the pointer, reporting whether a grab is in flight."""
        if self.press is None:
            return False
        if self.reached is None:
            travelled = pos - self.press
            if max(abs(travelled.x()), abs(travelled.y())) < GRAB_THRESHOLD:
                return False
        self.reached = QPoint(pos)
        return True

    def box(self) -> QRect | None:
        """The box in flight, or ``None`` while the press has not travelled."""
        if self.press is None or self.reached is None:
            return None
        return box_between(self.press, self.reached)

    def end(self) -> tuple[QPoint, QRect | None] | None:
        """The release: where it was pressed and the box it swept -- ``None``
        for a press that never travelled -- or ``None`` with no press held.
        Forgets the press either way."""
        press, box = self.press, self.box()
        self.press, self.reached = None, None
        return None if press is None else (press, box)


def grab_stamp(
    box: QRect,
    side: int,
    payload_at: Callable[[int, int], object | None],
    pick: Callable[[QPoint], object],
    arm: Callable[[GridStamp], object],
) -> None:
    """Turn a right drag's ``box`` into what the drag grabbed -- the one
    spelling of the editor-wide convention
    ([`right-click.md`](../../../docs/editor/right-click.md)).

    ``box`` is in image pixels over a grid of ``side``-pixel cells;
    ``payload_at(column, row)`` answers the value under a cell, or ``None``
    off the grid. A region of payloads is handed to ``arm`` as a
    :class:`GridStamp`; exactly one covered cell is not a region, so the
    short drag degrades to ``pick`` at the box's corner -- the eyedropper
    the gesture started as; none at all does nothing. The stamp's offsets
    and size are measured over the covered cells alone, so a box hanging
    off the grid cannot place its content beside the pointer or declare a
    size the stamp does not have.
    """
    left, top = box.left() // side, box.top() // side
    columns = box.right() // side - left + 1
    rows = box.bottom() // side - top + 1
    entries: list[tuple[int, int, object]] = []
    for dy in range(rows):
        for dx in range(columns):
            payload = payload_at(left + dx, top + dy)
            if payload is not None:
                entries.append((dx, dy, payload))
    if not entries:
        return
    if len(entries) == 1:
        pick(box.topLeft())
        return
    least_x = min(dx for dx, _, _ in entries)
    least_y = min(dy for _, dy, _ in entries)
    placed = tuple((dx - least_x, dy - least_y, leaf) for dx, dy, leaf in entries)
    width = max(dx for dx, _, _ in placed) + 1
    height = max(dy for _, dy, _ in placed) + 1
    arm(GridStamp(placed, width, height))


def landing_beside(origin: tuple[int, int] | None) -> tuple[int, int]:
    """Where a copy of a group starting at ``origin`` lands with no pointer to
    aim it at: :data:`COPY_OFFSET` from where it came from.

    ``None`` -- a group with no position at all, a screen exit on its own -- is
    answered with the top-left corner, which the landing then ignores: there is
    nothing in such a group for an anchor to move.
    """
    if origin is None:
        return (0, 0)
    return (origin[0] + COPY_OFFSET[0], origin[1] + COPY_OFFSET[1])


def next_in_stack(
    stack: Sequence[LevelObject | Sprite], selection: Collection[int]
) -> LevelObject | Sprite:
    """The next thing down from whatever in ``stack`` is already selected.

    A click that lands on nothing already held takes the **top** of the stack -
    what the user is looking at. A click on something already selected steps to
    the next thing down and round again, which is how the ground under a ledge
    under a pipe is reached by clicking it a second time rather than by
    switching layers off.

    Measured against the *whole* selection, not one primary record: with several
    things held, a click on any of them steps past that one. So the cycle stays
    right however the selection was assembled.
    """
    for index, thing in enumerate(stack):
        if thing.uid in selection:
            return stack[(index + 1) % len(stack)]
    return stack[0]


def pulled_to(
    record: LevelObject,
    sizes: dict[str, Field],
    columns: int,
    rows: int,
) -> tuple[LevelObject, tuple[int, int]]:
    """``record`` with its extents stepped, and how far they *actually* moved.

    Both halves of the answer, from one place, because a resize drag needs the
    two of them to agree: the record is what gets committed when the button
    comes up, and the trimmed step is what the outline is drawn reaching for
    while it is still down. Deriving the second from the first -- the value the
    field ended up at, against the one it started from -- is what makes a drag
    past the end of the nibble stop the mark where the object is going to stop.

    An extent this object does not have contributes nothing rather than
    something approximate: a pipe has no width to pull, so pulling its right
    edge moves nothing and the mark says so.
    """
    edited = record
    reached = []
    for key, delta in (("width", columns), ("height", rows)):
        field = sizes.get(key)
        if field is None:
            reached.append(0)
            continue
        value = field.value(record)
        wanted = field.clamped(value + delta)
        edited = field.applied(edited, wanted)
        reached.append(wanted - value)
    return edited, (reached[0], reached[1])


def grip_within(
    pos: QPoint, box: QRect, sizes: Collection[str], zoom: float
) -> Grip | None:
    """Which of ``box``'s far edges image pixel ``pos`` is on, if any.

    The reach is a distance **on the screen** rather than in the picture: what a
    hand can aim at does not change with the zoom, while a level is worked at
    anything from a quarter of its size to eight times it. It is held under half
    a block either way -- see :data:`GRIP_REACH_MAX` -- and under half the box,
    so a grip can never reach across the thing it belongs to and turn every drag
    on a small ledge into a resize.

    Along the edge it is the same reach again, past both ends: a corner is where
    two edges are both in reach, and that is what makes it grow the object in
    both directions at once rather than being a third case with its own
    arithmetic.

    ``sizes`` is which extents the object's settings byte can actually move, so
    an edge with no field behind it is not offered -- see
    ``MainWindow._sizable``.
    """
    reach = max(1, min(GRIP_REACH_MAX, round(GRIP_REACH_PX / zoom)))
    across = min(reach, max(1, box.width() // 2))
    down = min(reach, max(1, box.height() // 2))
    grip = Grip(0)
    if (
        "width" in sizes
        and abs(pos.x() - box.right()) <= across
        and box.top() - reach <= pos.y() <= box.bottom() + reach
    ):
        grip |= Grip.RIGHT
    if (
        "height" in sizes
        and abs(pos.y() - box.bottom()) <= down
        and box.left() - reach <= pos.x() <= box.right() + reach
    ):
        grip |= Grip.BOTTOM
    return grip or None
