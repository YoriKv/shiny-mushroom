"""A fixed-size asm table whose rows each name one token, and nothing else.

Several of the disassembly's tables are the same shape: a header comment, then
one directive per row naming a single symbol -- a label the level pointer tables
point a level's stream at, a define the level music table gives a header setting,
a song label a music value resolves to. What an edit *is* in every one of them is
the same: **one token moves, and nothing else in the file changes.**

That is worth a type of its own because of what it rules out. The row count is
the format -- position is the index -- so nothing is ever added or removed, no
region is priced, and no other row moves. A rewritten file therefore differs from
the one it was read from in exactly the token that changed: the directive is the
table's, and the row keeps its own trailing comment.

**A row may name a token no row currently names**, which is the point rather than
an edge case: pointing a music value at a song only one other value plays, or a
level at a container reached by address, is precisely what these edits are for.
Whether a token *means* anything is the caller's business -- this only moves it.

:class:`~shiny_mushroom.level_pointers.PointerTable` is this with the level
tables' own vocabulary over it; :mod:`shiny_mushroom.music_tables` is the audio
tables'.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

#: One row: the directive with its leading whitespace, the token, and everything
#: after it -- the alignment and the trailing comment, which a rewrite keeps
#: (:func:`_realigned` says what "keeps" means when the token changes length).
ENTRY = re.compile(r"^(\s*d[bwl]\s+)(\S+)(.*)$")


class TokenTableError(ValueError):
    """A table that is not one row per token, or a row that is not there."""


@dataclass(frozen=True)
class TokenTable:
    """One table as its lines and as its tokens, kept together so a rewrite can
    replace one row without re-deriving the rest.

    ``preamble`` is everything above the first row -- the header comment, and the
    label the table is reached by -- preserved verbatim. From the first row on,
    every line must *be* a row: a line that is neither would renumber every row
    below it, because a row's index is its position.
    """

    preamble: tuple[str, ...]
    lines: tuple[str, ...]
    tokens: tuple[str, ...]

    #: What a row is called in this table's own errors, singular and plural.
    #: Overridden by a subclass whose rows are levels, settings or values, so a
    #: refusal reads in the vocabulary the caller thinks in.
    noun = "row"
    plural = "rows"

    @classmethod
    def read(cls, text: str):
        """Parse a table, refusing any line past the preamble that is not a
        row."""
        preamble: list[str] = []
        lines: list[str] = []
        tokens: list[str] = []
        for number, line in enumerate(text.splitlines()):
            found = ENTRY.match(line)
            if found is None:
                if lines:
                    raise cls._error(
                        f"line {number + 1} of the table is not a "
                        f"{cls.noun}: {line.strip()!r}"
                    )
                preamble.append(line)
                continue
            lines.append(line)
            tokens.append(found.group(2))
        if not lines:
            raise cls._error(f"the table has no {cls.plural} at all")
        return cls(preamble=tuple(preamble), lines=tuple(lines), tokens=tuple(tokens))

    @classmethod
    def _error(cls, message: str) -> TokenTableError:
        """The exception this table raises, so a subclass can keep its own."""
        return TokenTableError(message)

    def text(self) -> str:
        return "\n".join(self.preamble + self.lines) + "\n"

    def token(self, row: int) -> str:
        """What ``row`` names."""
        if not 0 <= row < len(self.tokens):
            raise self._error(f"the table has no {self.noun} {row}")
        return self.tokens[row]

    def rows_naming(self, token: str) -> tuple[int, ...]:
        """Every row that names ``token``, in order."""
        return tuple(row for row, held in enumerate(self.tokens) if held == token)

    def repointed(self, row: int, token: str):
        """This table with ``row`` naming ``token``.

        Only the token moves: the directive is the table's, and the line keeps
        its own trailing comment -- in the *column* it was in, where the table
        aligns with spaces (:func:`_realigned`).
        """
        if self.token(row) == token:
            return self
        found = ENTRY.match(self.lines[row])
        assert found is not None  # every held line parsed on the way in
        lines = list(self.lines)
        lines[row] = (
            found.group(1)
            + token
            + _realigned(found.group(3), len(token) - len(found.group(2)))
        )
        tokens = list(self.tokens)
        tokens[row] = token
        return type(self)(
            preamble=self.preamble, lines=tuple(lines), tokens=tuple(tokens)
        )


def _realigned(rest: str, grew: int) -> str:
    """What follows the token, with a space-aligned comment kept in its column.

    A table that aligns its comments with **spaces** has a column, and a token
    of a different length would shift every comment below it out of line with
    the one row that changed -- so the padding absorbs the difference, down to
    the single space that is the least a comment may follow code by.

    A table that aligns with **tabs** has no column to keep: where a tab stop
    lands depends on what is in front of it, so re-counting them would be
    guessing at a width the file does not state. Those come through untouched,
    which is what the level pointer tables have always done.
    """
    if not rest.startswith(" "):
        return rest
    padding = len(rest) - len(rest.lstrip(" "))
    return " " * max(padding - grew, 1) + rest[padding:]
