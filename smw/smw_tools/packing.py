"""One walk for the runs the managed banks pack into.

The level streams (:mod:`smw_tools.levels`) and the graphics files
(:mod:`smw_tools.graphics_memory`) are laid out by the same rule, which is the
assembler's: items go in the order they are given, back to back from ``head``
bytes into the first run; an item that would run past the end of the run being
filled moves the layout on to the next run that holds it; the layout never goes
back. An item left when the runs are spent is left over, and so is everything
after it -- whether that is a refusal or a number to report is the caller's.

Each module keeps its own runs, its own placement type and its own error. What
is here is the walk, and the two things a caller has to say about its own
arithmetic: how far a placed item moves the cursor (:func:`lay_out`'s ``step``,
which is LoROM's for a run that spans banks) and how the bytes of a run are
counted (:meth:`Layout.used`, which is a difference of addresses for every run
but that one).
"""

from __future__ import annotations

from collections.abc import Callable, Iterable, Sequence
from dataclasses import dataclass
from typing import Protocol


class Run(Protocol):
    """A run of ROM to pack into: its 24-bit SNES address, and its last."""

    start: int
    end: int


@dataclass(frozen=True)
class Slot[T]:
    """One item, and where the layout put it."""

    item: T
    #: Which run of the layout's runs, by index.
    run: int
    #: Its 24-bit SNES address.
    address: int
    size: int


@dataclass(frozen=True)
class Layout[T]:
    """What :func:`lay_out` made of the items it was given."""

    #: Every item that found a run, in the order they were laid.
    placed: tuple[Slot[T], ...]

    #: The items that found none, with their sizes, in order. Empty is the
    #: layout that assembles.
    leftover: tuple[tuple[T, int], ...]

    #: Where the layout left each run -- the address past its last placed
    #: item, or the run's own start where it placed none. One per run.
    stops: tuple[int, ...]

    def used(self, runs: Sequence[Run]) -> tuple[int, ...]:
        """How many bytes of each of ``runs`` the layout took.

        A difference of addresses, so this is the answer for a run inside one
        bank. A run that spans banks holds fewer bytes than its addresses
        span, and :attr:`stops` is what to read for one of those.
        """
        return tuple(
            stop - run.start for stop, run in zip(self.stops, runs, strict=True)
        )


def _forward(address: int, size: int) -> int:
    """The cursor's step through a run that does not cross a bank."""
    return address + size


def lay_out[T](
    items: Iterable[T],
    size_of: Callable[[T], int],
    runs: Sequence[Run],
    head: int = 0,
    step: Callable[[int, int], int] = _forward,
) -> Layout[T]:
    """Lay ``items`` into ``runs``, back to back from ``head`` into the first.

    The fit is the assembler's own test, ``pc()+size > end`` over the SNES
    address, and ``step`` is what the cursor does after a placed item --
    :func:`smw_tools.graphics_memory.advance` where a run spans banks, plain
    addition where it does not.

    ``size_of`` answers each item's size, so a caller pricing edited copies of
    what it is packing prices them itself.
    """
    placed: list[Slot[T]] = []
    leftover: list[tuple[T, int]] = []
    stops = [run.start for run in runs]
    index = 0
    cursor = runs[0].start + head
    for item in items:
        size = size_of(item)
        if leftover:
            leftover.append((item, size))
            continue
        while index < len(runs) and cursor + size > runs[index].end:
            stops[index] = cursor
            index += 1
            if index < len(runs):
                cursor = runs[index].start
        if index >= len(runs):
            leftover.append((item, size))
            continue
        placed.append(Slot(item=item, run=index, address=cursor, size=size))
        cursor = step(cursor, size)
    if index < len(runs):
        stops[index] = cursor
    return Layout(placed=tuple(placed), leftover=tuple(leftover), stops=tuple(stops))
