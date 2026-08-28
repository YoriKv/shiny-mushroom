"""Where you have been, so you can get back there.

A level editor is browsed as much as it is edited. Following a screen exit,
stepping through search results, or picking a level to check something in all
take you somewhere else, and every one of them is a move you will want to undo
*as a move* -- without undoing an edit, and without having to remember which
level you came from and where in it you were looking.

So this is a browser's back button and nothing more ambitious: a trail of places
with a finger in it. Going somewhere new truncates whatever was ahead, exactly
as a browser does, because a trail that kept both branches would need a way to
say which one Forward means.

**It is not the undo stack, and the two must not be confused.** Undo takes back a
change to the level; this takes back a change of *view*. They are different
questions with different answers -- undoing an edit should not scroll the window,
and going back should not resurrect a deleted object -- which is why they are
separate stacks rather than one interleaved history.

Qt-free, like everything outside :mod:`shiny_mushroom.ui`: a place is a level
number and a point, and the trail is a list.
"""

from __future__ import annotations

from dataclasses import dataclass

#: How many places are remembered. Older ones fall off the back. A hundred is
#: far more than anyone retraces by hand, and each entry is three integers -- so
#: this is a bound on nothing in particular, kept because an unbounded list that
#: grows for the whole session is the kind of thing nobody notices until it is
#: measured.
TRAIL_LIMIT = 100


@dataclass(frozen=True)
class Place:
    """A level and where in it you were looking.

    ``column`` and ``row`` are **blocks**, not pixels or scroll offsets: the zoom
    is a property of the person rather than of the trail, and a place recorded at
    5x has to still mean the same part of the level when you come back to it at a
    quarter.
    """

    level: int
    column: int
    row: int


class Trail:
    """Somewhere you have been, and the places either side of it."""

    def __init__(self, limit: int = TRAIL_LIMIT) -> None:
        self._places: list[Place] = []
        #: Where in the trail you are standing. ``-1`` is "nowhere yet", which is
        #: what an empty trail and a cleared one both are.
        self._at = -1
        self._limit = limit

    @property
    def current(self) -> Place | None:
        """Where you are, as far as this knows."""
        return self._places[self._at] if 0 <= self._at < len(self._places) else None

    @property
    def places(self) -> tuple[Place, ...]:
        """The whole trail, oldest first. For a readout and for tests."""
        return tuple(self._places)

    @property
    def can_go_back(self) -> bool:
        return self._at > 0

    @property
    def can_go_forward(self) -> bool:
        return -1 < self._at < len(self._places) - 1

    @property
    def behind(self) -> Place | None:
        """Where Back would take you, without going there.

        For a caller that has to know what a step costs before taking it: a step
        into another level throws away the level in hand, which is a question to
        put *before* the finger has moved.
        """
        return self._places[self._at - 1] if self.can_go_back else None

    @property
    def ahead(self) -> Place | None:
        """Where Forward would take you, without going there."""
        return self._places[self._at + 1] if self.can_go_forward else None

    def record(self, place: Place) -> None:
        """Arrive somewhere new.

        Arriving where you already are is **not** a new entry -- it refreshes the
        one you are on. Scrolling around a level and re-recording would otherwise
        fill the trail with the same level over and over, and Back would walk
        through a dozen views of one place before reaching the level you actually
        came from.
        """
        here = self.current
        if here is not None and here.level == place.level:
            self._places[self._at] = place
            return
        # Anything ahead is a branch you have left. A trail that kept it would
        # need a way to say which way Forward goes.
        del self._places[self._at + 1 :]
        self._places.append(place)
        del self._places[: max(0, len(self._places) - self._limit)]
        self._at = len(self._places) - 1

    def look_at(self, column: int, row: int) -> None:
        """Note that you have scrolled, without going anywhere.

        What makes Back restore a *view* rather than just a level: the place you
        are standing on is updated as you move around it, so leaving and coming
        back returns you to where you were looking rather than to wherever the
        level happened to open.
        """
        here = self.current
        if here is not None:
            self._places[self._at] = Place(here.level, column, row)

    def back(self) -> Place | None:
        """Step back one place, or ``None`` if there is nowhere to go."""
        if not self.can_go_back:
            return None
        self._at -= 1
        return self._places[self._at]

    def forward(self) -> Place | None:
        """Step forward again, or ``None`` if you are at the end of the trail."""
        if not self.can_go_forward:
            return None
        self._at += 1
        return self._places[self._at]

    def clear(self) -> None:
        """Forget everywhere. What closing a cartridge does: the trail is of
        places in *that* cart, and level ``$105`` of the next one is somewhere
        else entirely."""
        self._places.clear()
        self._at = -1
