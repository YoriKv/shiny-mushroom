"""What a copy of tilemap entries holds, and where a paste puts them back.

Two editors paint tilemaps -- the world map, over its cells, Layer 2 tiles
and sprites, and the level's Layer 2 background mode, over its repeating
pattern -- and a copy means the same thing in both: **values with relative
geometry**. Each entry is ``(dx, dy, payload)`` from the copy's top-left
corner, and the corner's own position rides along so a paste with the pointer
nowhere can land beside where the copy was taken. What the payload *is* -- a
Map16 tile, a 16-bit tilemap word, a pattern byte -- stays each editor's
business, exactly as which grid the coordinates count in does.

The window's level-records clipboard is the deliberate contrast: it holds
records, because a record has an identity beyond its value. A tilemap entry
is only its value, so this is the whole of what a copy needs to keep.

A copy that has landed is not finished with, either: it stays in hand as a
:class:`FloatingSelection`, and :class:`FloatController` is the whole of what
the two editors do with one -- lifting, carrying, settling and taking it back
-- over hooks each answers for its own grid.

Qt-free, like every module a document lives in: geometry is arithmetic, and
arithmetic is testable without a window.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import Callable, Iterable
from dataclasses import dataclass
from enum import Enum, auto


@dataclass(frozen=True)
class TileClipboard:
    """One copy: entries relative to the copy's top-left corner, and where
    that corner was taken from. The units are the caller's grid's own."""

    entries: tuple[tuple[int, int, int], ...]
    origin: tuple[int, int]


@dataclass(frozen=True)
class GridStamp:
    """A rectangle of tiles in hand, grabbed off a picture or a panel by a
    right drag: a brush, where :class:`TileClipboard` is a copy.

    The same relative geometry as a clipboard -- ``(dx, dy, payload)`` from
    the grabbed region's top-left corner -- but the payloads are the armed
    payload dataclasses of the surface it came from (a ``Layer1Tile``, a
    ``Layer2Word``, a ``BackgroundTile``), because a stamp *is* an armed
    tool: it travels through the same hand the single-tile payloads do, and
    the leaf type is what says which grid it lands on. One stamp holds one
    leaf type; :attr:`width` and :attr:`height` are the grabbed rectangle in
    grid units, for the ghost that shows where it will land.
    """

    entries: tuple[tuple[int, int, object], ...]
    width: int
    height: int

    @property
    def leaf(self) -> object:
        """The first payload, which is every payload's type: what material
        the stamp lays down."""
        return self.entries[0][2]


@dataclass(frozen=True)
class SelectionMark[S]:
    """What was held when an edit was made -- put back when an undo or a redo
    comes back to that edit's document. ``History``'s per-step mark, in the
    one shape both tilemap editors need.

    An undo restores what the edit was made **from**, which for almost every
    edit is a selection sitting on the document the undo just restored: the
    tiles go home and the ants go home with them.

    :attr:`carried` is the exception, and the reason it is here. What a paste
    was made from is the *clipboard*, not anything on the document -- so
    undoing one puts it back **into hand**, floating at :attr:`anchor`, where
    a drag can carry it somewhere better. It is in hand rather than on the
    document because the undo took its values off the document; nothing shows
    until it moves, and its first move commits a step of its own.
    """

    #: What was selected, in the caller's own spelling: the level's pattern
    #: blocks, or the world map's kind-and-keys.
    selection: S
    #: A paste owed back to the hand, as a clipboard's relative entries.
    #: Empty for every edit whose selection is on the document itself.
    carried: tuple[tuple[int, int, int], ...] = ()
    #: Where the carried paste's top-left corner sits, in the caller's grid.
    anchor: tuple[int, int] = (0, 0)


@dataclass(frozen=True)
class FloatingSelection[T]:
    """A selection in flight: a paste still in hand, or tiles a drag lifted
    off the document -- either way, the one edit a drag may yet move.

    The floated values are already **in** the document once anything has
    landed -- committed, so a save or a mode switch can never lose them --
    and what floats is the right to keep moving them as *the same step*:
    each move rewrites the float's one history entry (``History.replace``)
    rather than adding another, so however far it travels, one undo takes
    the whole journey back. Landing -- a new selection, a click away --
    writes nothing; it only gives that right up.

    A **lift** additionally owes :attr:`holes`: the spots its tiles came
    from, held blank while the float is in the air. Deleting a float is the
    one gesture that reaches for ``base`` -- it writes only the hole a move
    owed, so a deleted paste puts back what was beneath and a deleted lift
    stays the deletion it looks like.
    """

    #: The document before the float existed -- what a drag re-derives each
    #: move from, and what deleting the float writes its holes over.
    base: T
    #: The document as the float last wrote it. The float only owns the top
    #: of the stack while this *is* the present; an edit from anywhere else
    #: -- there should be none, but the check is what makes that a fact --
    #: lands the float instead of rewriting someone else's step.
    doc: T
    #: The values, relative to the float's top-left corner -- a clipboard's
    #: ``entries``, or a lift's tiles in the shape they were held in.
    entries: tuple[tuple[int, int, int], ...]
    #: Where the corner currently sits, in the caller's grid.
    anchor: tuple[int, int]
    #: Whether ``doc`` differs from ``base`` at all. A paste of values onto
    #: their own kind commits nothing, and a float over nothing has no step
    #: to rewrite -- its first real move commits one.
    committed: bool
    #: Where a lift took its tiles from, as the caller's grid spots -- the
    #: hole a move owes, blanked for as long as the float is up. Empty for
    #: a paste, which took nothing off the document.
    holes: tuple[tuple[int, int], ...] = ()
    #: What an undo of the float's step restores -- a :class:`SelectionMark`,
    #: carried here because the float is the only thing that still knows what
    #: came before it: a lift remembers the settled selection it was picked
    #: up from, a paste the fact that it came off the clipboard.
    mark: SelectionMark | None = None


def floated(
    held: FloatingSelection,
    anchor: tuple[int, int],
    spot: Callable[[int, int], int | None],
) -> dict[int, int]:
    """Everything the float writes with its corner at ``anchor``: the holes
    a lift owes blanked first, the carried values on top -- so a float
    dragged back over its own hole refills it, and one carried exactly home
    changes nothing at all, which is what lets the caller's no-op discipline
    (an operation returns ``self``) collapse the step."""
    placed: dict[int, int] = {}
    for x, y in held.holes:
        index = spot(x, y)
        if index is not None:
            placed[index] = 0
    placed.update(landing(held.entries, anchor, spot))
    return placed


def clamped(
    entries: Iterable[tuple[int, int, int]],
    anchor: tuple[int, int],
    columns: int,
    rows: int,
) -> tuple[int, int]:
    """The nearest anchor to ``anchor`` at which every entry stays on a
    ``columns`` x ``rows`` grid -- what keeps a dragged float from hanging
    off the picture, or from wrapping a repeating pattern onto itself. A
    copy larger than the grid pins to its top-left edge instead."""
    spots = list(entries)
    left = min(dx for dx, _, _ in spots)
    top = min(dy for _, dy, _ in spots)
    right = max(dx for dx, _, _ in spots)
    bottom = max(dy for _, dy, _ in spots)
    return (
        max(-left, min(anchor[0], columns - 1 - right)),
        max(-top, min(anchor[1], rows - 1 - bottom)),
    )


def centred(
    entries: Iterable[tuple[int, int, int]], middle: tuple[int, int]
) -> tuple[int, int]:
    """The anchor that puts a copy's middle at ``middle`` -- a grid spot, in
    the caller's own units.

    Where a paste lands with the pointer off the picture: **centred on the
    viewport**, not beside the origin, which is the record paste's fallback.
    The origin may be a scroll away, and a paste that lands off-screen looks
    exactly like a gesture that did nothing.
    """
    right = max(dx for dx, _, _ in entries)
    bottom = max(dy for _, dy, _ in entries)
    return middle[0] - right // 2, middle[1] - bottom // 2


def relative(
    spots: Iterable[tuple[int, int, int]],
) -> tuple[tuple[tuple[int, int, int], ...], tuple[int, int]]:
    """``(x, y, payload)`` spots as a clipboard's two fields: the same spots
    from their bounding box's top-left corner, and that corner.

    A tuple rather than a :class:`TileClipboard` so a caller with a field of
    its own to add -- the world map says which *kind* of entry it copied --
    builds its dataclass in one expression: ``WorldClipboard(*relative(...))``.
    """
    spots = list(spots)
    left = min(x for x, _, _ in spots)
    top = min(y for _, y, _ in spots)
    return tuple((x - left, y - top, what) for x, y, what in spots), (left, top)


def landing(
    entries: Iterable[tuple[int, int, int]],
    anchor: tuple[int, int],
    spot: Callable[[int, int], int | None],
) -> dict[int, int]:
    """Where each entry goes when the copy's corner lands at ``anchor``:
    the caller's tilemap index to the payload to put there.

    ``spot`` is the caller's addressing -- what index, if any, its grid keeps
    at ``(x, y)``. ``None`` drops the entry, which is how a paste hanging off
    the world map's edge loses only the part that fell off; a grid that wraps,
    like the level background's repeating pattern, simply never answers it.
    """
    placed: dict[int, int] = {}
    for dx, dy, what in entries:
        index = spot(anchor[0] + dx, anchor[1] + dy)
        if index is not None:
            placed[index] = what
    return placed


class FloatStep(Enum):
    """What a settle or a cancel did with the float's one history step --
    all the editor needs back to say what happened."""

    #: Nothing floated, or the drag left the float where it already was.
    NOTHING = auto()
    #: Given up: a stranger holds the top of the stack, or the write was
    #: refused. The float landed where it was and nothing was written.
    LANDED = auto()
    #: The step now says where the float is.
    WRITTEN = auto()


class FloatController[S, T](ABC):
    """The floating selection's machinery, over one editor's grid.

    A paste stays in hand after it lands, and a drag on a settled selection
    lifts it into the same state: committed once anything has landed -- a
    save or a mode switch can never lose it -- but still the one edit a drag
    may move, each move rewriting the float's single history step rather
    than adding another. See :class:`FloatingSelection` for the shape, its
    ``holes`` for what a lift owes, and ``History.replace`` for the step's
    arithmetic.

    The gestures are here; what a gesture *means* stays with the editor that
    owns the document, and so does every redraw. A subclass answers for one
    grid -- what index a spot keeps, how a document is written, what the
    selection is in its own spelling -- in whichever units it already counts
    in, and the controller never sees a pixel: callers divide by their own
    block size before they arrive.
    """

    def __init__(self) -> None:
        #: What is in hand, or ``None`` with nothing floating.
        self.held: FloatingSelection[T] | None = None
        #: A drag of it in flight: the grab's offset from the float's corner.
        self.grab: tuple[int, int] | None = None
        #: The corner the pointer is offering, while a drag is carrying it.
        self.anchor: tuple[int, int] | None = None
        #: The working copy the picture currently shows.
        self.shown: T | None = None

    # -- what the editor answers ----------------------------------------------

    @abstractmethod
    def document(self) -> T:
        """The document as it stands."""

    @abstractmethod
    def selection(self) -> S:
        """What is held, in the editor's own spelling."""

    @abstractmethod
    def select(self, selection: S) -> None:
        """Hold ``selection`` instead."""

    @abstractmethod
    def nothing(self) -> S:
        """The empty selection."""

    @abstractmethod
    def spot(self, x: int, y: int) -> int | None:
        """The grid's addressing: what index, if any, it keeps at a spot."""

    @abstractmethod
    def bounds(self) -> tuple[int, int]:
        """The grid's size, in its own units -- what a float clamps to."""

    @abstractmethod
    def place(self, document: T, placed: dict[int, int]) -> T:
        """``placed`` written into the float's own layer of ``document``."""

    @abstractmethod
    def covering(
        self, entries: tuple[tuple[int, int, int], ...], anchor: tuple[int, int]
    ) -> S:
        """The selection ``entries`` make with their corner at ``anchor`` --
        what the ants ride, for a float and for a paste alike."""

    @abstractmethod
    def spots(self) -> Iterable[tuple[int, int, int]]:
        """What the selection holds, as ``(x, y, payload)`` in the grid's
        units -- the values a lift picks up, and the spots it owes back."""

    @abstractmethod
    def show(self, previous: T, current: T) -> None:
        """Repaint from the document the picture shows to ``current``."""

    @abstractmethod
    def holds(self, document: T) -> bool:
        """Whether the history's present is ``document`` -- what makes "no
        gesture commits over a float" a fact rather than an assumption."""

    @abstractmethod
    def replace(
        self, held: FloatingSelection[T], document: T, mark: SelectionMark[S]
    ) -> None:
        """Rewrite the float's own step as ``document``."""

    @abstractmethod
    def commit(
        self, held: FloatingSelection[T], document: T, mark: SelectionMark[S]
    ) -> bool:
        """Start the float's step at ``document``, reporting whether it took."""

    @abstractmethod
    def abandon(self, previous: T) -> None:
        """Put the picture back to the document after giving the float up."""

    def ready(self) -> bool:
        """Whether there is a document for a float to be over at all."""
        return True

    def carrying(self, selection: S) -> None:  # noqa: B027 - optional
        """Told which selection a float is about to be built for, before it
        exists -- for an editor whose grid depends on what is held."""

    def hovering(self, anchor: tuple[int, int]) -> None:  # noqa: B027 - optional
        """Told where a carried float now sits, after the picture and the
        ants have followed it there."""

    def moved(self, held: FloatingSelection[T], anchor: tuple[int, int]) -> T:
        """The document a settle at ``anchor`` writes. Overridden by an
        editor with tables to carry beside the tiles."""
        return self.place(held.base, floated(held, anchor, self.spot))

    def finished(  # noqa: B027 - optional
        self, held: FloatingSelection[T], anchor: tuple[int, int], previous: T
    ) -> None:
        """Told the settle wrote its step, with the document the picture was
        last shown -- for whatever reads what the write moved."""

    def rewrite(
        self, held: FloatingSelection[T], document: T, mark: SelectionMark[S]
    ) -> None:
        """Rewrite the float's step as ``document`` for a cancel, which has
        no drag behind it and so nothing on the picture to catch up from."""
        self.replace(held, document, mark)

    def write(
        self, held: FloatingSelection[T], document: T, mark: SelectionMark[S]
    ) -> None:
        """Start a step at ``document`` for a cancel."""
        self.commit(held, document, mark)

    # -- the gestures ---------------------------------------------------------

    def mark(self) -> SelectionMark[S]:
        """The selection as it stands, as an undo step's restore point.

        A paste **not yet written** rides along in it -- one an undo put back
        into hand, whose values are on no document to be selected. Walking
        the stack past it and back would otherwise drop it, and a paste
        dropped is a paste that has to be pasted again. A float already
        written needs nothing: its values are in the document, and the spots
        they sit on are the selection.
        """
        held = self.held
        if held is not None and not held.committed and not held.holes:
            return SelectionMark(self.selection(), held.entries, held.anchor)
        return SelectionMark(self.selection())

    def restore(self, mark: object) -> None:
        """Put the selection back to what ``mark`` describes. Anything that
        is not a mark leaves it alone -- a step that spelled none had nothing
        the selection needed telling."""
        if not isinstance(mark, SelectionMark):
            return
        self.land()
        self.select(mark.selection)
        if mark.carried and self.ready():
            # A paste back into hand. Uncommitted, because the undo took its
            # values off the document: nothing shows until it moves, and its
            # first move commits a step of its own.
            self.carrying(mark.selection)
            document = self.document()
            self.held = FloatingSelection(
                document, document, mark.carried, mark.anchor, False, mark=mark
            )

    def land(self) -> None:
        """Fix the floating selection where it is. Nothing to write: its
        edits are already the document's, and landing only gives up the
        right to keep moving them as one step. Safe with nothing floating."""
        self.held = None
        self.grab = None
        self.anchor = None
        self.shown = None

    def lift(self) -> None:
        """Pick the held values up into a float: they come along in the
        selection's own shape, and the spots they leave are owed as holes --
        blank for as long as the float is in the air. Nothing commits until
        the float first lands somewhere else."""
        spots = list(self.spots())
        entries, origin = relative(spots)
        document = self.document()
        self.held = FloatingSelection(
            document,
            document,
            entries,
            origin,
            False,
            holes=tuple((x, y) for x, y, _ in spots),
            # Where the values were picked up from: what an undo of the move
            # this lift is the start of goes back to.
            mark=self.mark(),
        )

    def take(self, x: int, y: int) -> None:
        """Take hold of the selection at grid spot ``(x, y)`` -- lifting a
        settled one into a float first. The caller has already decided the
        spot is on it."""
        if self.held is None:
            self.lift()
        held = self.held
        assert held is not None
        self.grab = (x - held.anchor[0], y - held.anchor[1])
        self.anchor = held.anchor
        self.shown = self.document()

    def carry(
        self,
        base: T,
        entries: tuple[tuple[int, int, int], ...],
        anchor: tuple[int, int],
        mark: SelectionMark[S],
    ) -> None:
        """Take a landed paste into hand: committed -- ``base`` is what it
        landed on -- but floating, the one edit a drag may still move."""
        document = self.document()
        self.held = FloatingSelection(
            base, document, entries, anchor, document is not base, mark=mark
        )

    def hover(self, x: int, y: int) -> None:
        """Show the carried float with the pointer at grid spot ``(x, y)``:
        the picture and the ants move now, the document when the button
        comes up."""
        held = self.held
        grab = self.grab
        if held is None or grab is None or not self.ready():
            return
        columns, rows = self.bounds()
        anchor = clamped(held.entries, (x - grab[0], y - grab[1]), columns, rows)
        if anchor == self.anchor:
            return
        self.anchor = anchor
        display = self.place(held.base, floated(held, anchor, self.spot))
        previous = self._showing()
        if display is not previous:
            self.show(previous, display)
            self.shown = display
        # The ants ride the carried values alone -- the holes a lift owes are
        # part of what the float writes, but not part of what is held.
        self.select(self.covering(held.entries, anchor))
        self.hovering(anchor)

    def settle(self) -> FloatStep:
        """Write the carried float where the drag left it -- still as its one
        step, rewritten in place rather than added to.

        The step's restore point moves with it: a lift keeps pointing at the
        spots it was picked up from, and a paste follows the float, so an
        undo puts it back into hand where the drag left it rather than where
        it first landed.
        """
        held = self.held
        anchor = self.anchor
        previous = self._showing()
        self.grab = None
        self.anchor = None
        self.shown = None
        if held is None or anchor is None or anchor == held.anchor:
            # A drag that went nowhere; the picture never moved either.
            return FloatStep.NOTHING
        document = self.moved(held, anchor)
        mark = (
            held.mark
            if held.holes
            else SelectionMark(self.selection(), held.entries, anchor)
        )
        if held.committed and self.holds(held.doc):
            self.replace(held, document, mark)
        elif held.committed:
            # Something else committed over the float's step -- no gesture
            # can, but rewriting a stranger's step is worse than landing,
            # and the check is what makes "no gesture can" a fact.
            return self._give_up(previous)
        elif document is not held.base and not self.commit(held, document, mark):
            # The float had changed nothing until this move, and the write of
            # the move was refused: put the hover's pixels back.
            return self._give_up(previous)
        self.finished(held, anchor, previous)
        now = self.document()
        self.held = FloatingSelection(
            held.base,
            now,
            held.entries,
            anchor,
            now is not held.base,
            holes=held.holes,
            mark=mark,
        )
        return FloatStep.WRITTEN

    def cancel(self) -> FloatStep:
        """Write only the hole a move owed -- what delete means over a float.
        A deleted paste owes nothing, so what was beneath comes back and its
        step collapses; a deleted lift keeps its hole, which is exactly the
        deletion the gesture asked for."""
        held = self.held
        previous = self._showing()
        self.land()
        if held is None:
            return FloatStep.NOTHING
        self.select(self.nothing())
        target = self.place(
            held.base,
            dict.fromkeys(
                (
                    index
                    for index in (self.spot(x, y) for x, y in held.holes)
                    if index is not None
                ),
                0,
            ),
        )
        # What is left is the hole, so the step goes back to what the float
        # was lifted out of -- the spots, held again.
        if held.committed and self.holds(held.doc):
            self.rewrite(held, target, held.mark)
        elif held.committed:
            # A stranger holds the step, so nothing was taken out and nothing
            # is claimed -- `settle` refuses on the same test.
            self.abandon(previous)
            return FloatStep.LANDED
        elif target is not held.base:
            # A lift that never moved: deleting it is the plain delete it
            # looks like, one step of its own.
            self.write(held, target, held.mark)
        return FloatStep.WRITTEN

    def _showing(self) -> T:
        """The document the picture shows: the float's working copy while a
        drag has one up, the held document otherwise."""
        return self.shown if self.shown is not None else self.document()

    def _give_up(self, previous: T) -> FloatStep:
        self.land()
        self.abandon(previous)
        return FloatStep.LANDED
