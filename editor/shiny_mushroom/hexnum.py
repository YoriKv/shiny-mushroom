"""How a number reads: ``$1F``, in the notation the format is written in.

Everything this editor shows is a number out of the cartridge -- an object
number, a settings byte, a screen, a position -- and every one of them is
written in hex with a ``$`` in front, in the disassembly, in every other editor
for this game, and in what anyone writing a hack has open beside them. Showing
one in decimal makes the panel the one place a person has to convert.

Said once, here: the padding is the *field's* -- a column is ``$01`` and a
destination ``$105``, so the digits are an argument rather than derived from
the value, which would make the same field read differently from one record to
the next.

Qt-free and dependency-free, like everything outside :mod:`shiny_mushroom.ui`.
"""

from __future__ import annotations


def hexnum(value: int, digits: int = 2) -> str:
    """``value`` as the format writes it, padded to ``digits``.

    Two digits by default, because that is the width almost everything here is:
    a byte. ``digits=0`` pads to nothing, for a number whose width says nothing
    -- an offset from a label, a value named in a sentence.

    A negative value keeps its sign *outside* the ``$`` -- ``-$040``, not the
    stored word -- because the fields that reach below zero are signed positions
    that are read and typed as signed numbers. The digits still pad the
    magnitude, so a column of them lines up.
    """
    if value < 0:
        return f"-${-value:0{digits}X}"
    return f"${value:0{digits}X}"


def hexbytes(data: bytes) -> str:
    """A run of bytes as text -- ``33 40 08 80 27``, the way the disassembly
    and a hex editor show a record.

    The one hex rendering here that carries no ``$``: what is being shown is
    the storage rather than a value, and a ``$`` on each byte would read as
    five numbers where there is one record. Two digits apiece and a single
    space between, so a column of records lines up.
    """
    return " ".join(f"{byte:02X}" for byte in data)


def hexspot(x: int, y: int, digits: int = 2) -> str:
    """A position, as ``($01, $02)`` -- both halves in the same width.

    A position is one fact said in two numbers, so it is rendered in one place
    rather than paired up at every call site. The comma is
    :data:`shiny_mushroom.fields.SEPARATOR`'s, so a position reads the same in
    a panel row as it does in a status line.
    """
    return f"({hexnum(x, digits)}, {hexnum(y, digits)})"
