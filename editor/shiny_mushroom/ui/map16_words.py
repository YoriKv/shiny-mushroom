"""What is in the Map16 environment's hand, and what the attribute controls
do to it.

Everything the environment draws with is 16-bit tilemap words -- one
:class:`~shiny_mushroom.ui.tile_palette.Layer2Word`, or a
:class:`~shiny_mushroom.tile_clipboard.GridStamp` of them: a whole Map16
tile is a 2x2 stamp of its four quadrant words, a 6x6 stamp block a 6x6 one.
One material, so the VRAM dock's palette row, X flip, Y flip and priority
controls mean the same thing whatever is held: the row and the priority are
**set** on every word, and a flip **mirrors** what is held as a picture --
the words change places and each one's own flip bit toggles, which is what
makes a flipped block draw as the mirror image rather than as four tiles
each mirrored in its own corner.

Qt-free arithmetic over frozen payloads, so the rules can be tested without
a widget around them.
"""

from __future__ import annotations

from collections.abc import Mapping

from shiny_mushroom.overworld_fields import (
    PALETTE_MASK,
    PRIORITY_MASK,
    X_FLIP_MASK,
    Y_FLIP_MASK,
)
from shiny_mushroom.tile_clipboard import GridStamp
from shiny_mushroom.ui.tile_palette import Layer2Word

#: What the hand can hold.
Payload = Layer2Word | GridStamp


def words_of(payload: Payload) -> list[int]:
    """Every word ``payload`` carries, in entry order."""
    if isinstance(payload, Layer2Word):
        return [payload.word]
    return [leaf.word for _dx, _dy, leaf in payload.entries]


def _map(payload: Payload, change: callable) -> Payload:  # type: ignore[valid-type]
    if isinstance(payload, Layer2Word):
        return Layer2Word(change(payload.word))
    return GridStamp(
        tuple(
            (dx, dy, Layer2Word(change(leaf.word))) for dx, dy, leaf in payload.entries
        ),
        payload.width,
        payload.height,
    )


def with_palette(payload: Payload, row: int) -> Payload:
    """``payload`` with every word under palette ``row``."""
    bits = (row & 7) << 10
    return _map(payload, lambda word: (word & ~PALETTE_MASK & 0xFFFF) | bits)


def with_priority(payload: Payload, on: bool) -> Payload:
    """``payload`` with every word's priority bit set to ``on``."""
    bits = PRIORITY_MASK if on else 0
    return _map(payload, lambda word: (word & ~PRIORITY_MASK & 0xFFFF) | bits)


def mirrored(payload: Payload, x: bool = False, y: bool = False) -> Payload:
    """``payload`` mirrored as a picture: the entries change places across
    the axis and each word's own flip bit toggles. A single word has no
    places to change, so it just toggles."""
    toggle = (X_FLIP_MASK if x else 0) | (Y_FLIP_MASK if y else 0)
    if not toggle:
        return payload
    if isinstance(payload, Layer2Word):
        return Layer2Word(payload.word ^ toggle)
    return GridStamp(
        tuple(
            (
                payload.width - 1 - dx if x else dx,
                payload.height - 1 - dy if y else dy,
                Layer2Word(leaf.word ^ toggle),
            )
            for dx, dy, leaf in payload.entries
        ),
        payload.width,
        payload.height,
    )


def attributes_of(payload: Payload) -> Layer2Word:
    """One word standing for ``payload``'s attributes -- what the controls
    show when it is picked up: the first word's palette row, and each flag
    only where every word carries it. The char is the first word's."""
    words = words_of(payload)
    first = words[0]
    palette = first & PALETTE_MASK
    flags = 0
    for mask in (PRIORITY_MASK, X_FLIP_MASK, Y_FLIP_MASK):
        if all(word & mask for word in words):
            flags |= mask
    return Layer2Word((first & 0x3FF) | palette | flags)


def mirrored_words(
    words: Mapping[tuple[int, int], int], x: bool = False, y: bool = False
) -> dict[tuple[int, int], int]:
    """A rectangle of placed words -- ``(column, row)`` to word -- mirrored
    as a picture within its own bounding box: :func:`mirrored` over a
    selection rather than a hand. A single row mirrored across Y is itself,
    every word's bit toggled, which is what a one-cell-tall picture is."""
    if not words or not (x or y):
        return dict(words)
    left = min(cx for cx, _ in words)
    right = max(cx for cx, _ in words)
    top = min(cy for _, cy in words)
    bottom = max(cy for _, cy in words)
    toggle = (X_FLIP_MASK if x else 0) | (Y_FLIP_MASK if y else 0)
    return {
        (left + right - cx if x else cx, top + bottom - cy if y else cy): word ^ toggle
        for (cx, cy), word in words.items()
    }


def flipped_words(
    words: Mapping[tuple[int, int], int], x: bool = False, y: bool = False
) -> dict[tuple[int, int], int]:
    """Each word flipped in place -- the bit toggled, nothing moved."""
    toggle = (X_FLIP_MASK if x else 0) | (Y_FLIP_MASK if y else 0)
    return {at: word ^ toggle for at, word in words.items()}


__all__ = [
    "Payload",
    "attributes_of",
    "flipped_words",
    "mirrored",
    "mirrored_words",
    "with_palette",
    "with_priority",
    "words_of",
]
