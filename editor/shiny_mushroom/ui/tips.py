"""Line breaks for tooltips.

Qt lays a plain-text tooltip out on one line however long it is, so a
sentence of explanation comes out as a bar the width of the screen. Every
tooltip carrying more than a few words goes through :func:`wrap_tip`, which
breaks it into a column narrow enough to read.

The width is a column, not a limit: a tooltip long enough to need several
lines of it is a tooltip that has not been cut down far enough.
"""

from __future__ import annotations

from textwrap import fill

#: Characters a wrapped tooltip line may hold. Wide enough that most of the
#: editor's tooltips stay one line, narrow enough that the rest read as a
#: paragraph rather than a ruler.
WIDTH = 62


def wrap_tip(text: str) -> str:
    """``text`` broken into lines of at most :data:`WIDTH` characters.

    Idempotent: whitespace is collapsed first, so wrapping an already
    wrapped tooltip gives the same answer.
    """
    return fill(text, WIDTH)
