"""The Layer 2 pointer table, as something the editor can read and repoint.

``levels/pointers/layer2.asm`` is 512 lines, one per level number in order, and
unlike its Layer 1 and sprite siblings it mixes two grammars -- which is why
:mod:`smw_tools.levels` deliberately leaves it alone::

    dw SMW_Backgrounds_Layer2_Bonus : db $FF    ; 000
    dl SMW_LEVEL_L2_009                         ; 009

The first form is a **background**: the bank byte is spent saying so (``$FF``),
the word is an address in bank ``$0C``, and the label names one of the
seventeen LC_RLE1 tilemaps under ``levels/backgrounds/``. The second is **level
data**: a full pointer to a Layer 2 object stream pulled out of an ``.mwl``
container exactly as Layer 1 is. What kind a level's entry is decides the
level's shape -- see ``layer2_background`` wherever a level is loaded -- so
repointing an entry is not a cosmetic edit.

Repointing is all this module does write. An entry is only ever pointed at a
label the table (or the stock table) already names, so the edit is three bytes
of a fixed-size table moving inside it: no stream is created or destroyed, no
region is priced, and every other line of the file -- tabs, comments, order --
comes through byte for byte. A changed line borrows the formatting of a line
that already points at the same label, so the rewritten file reads as if it had
always said so.
"""

from __future__ import annotations

import re
from collections.abc import Iterable
from dataclasses import dataclass

from shiny_mushroom.hexnum import hexnum
from smw_tools.levels import NAMESPACE

#: What the two kinds of label start with. Used only to shorten a label into a
#: name a person can pick from a list; a label with neither prefix is shown as
#: it is spelled, so a hacked tree still lists correctly.
BACKGROUND_PREFIX = "SMW_Backgrounds_Layer2_"
LEVEL_PREFIX = "SMW_LEVEL_L2_"

#: The two grammars, one per line. The background form's ``$FF`` is required
#: literally: it is the byte the loader tests, and a table entry with any other
#: bank in that position would be a pointer this module does not understand.
_BACKGROUND = re.compile(r"^\s*dw\s+(\S+)\s*:\s*db\s+\$FF\b")
_LEVEL = re.compile(r"^\s*dl\s+(\S+)")


class Layer2TableError(ValueError):
    """A table that could not be read, or an entry it cannot point at."""


@dataclass(frozen=True)
class Layer2Entry:
    """One thing a level's Layer 2 can be pointed at: a label, and which of the
    two grammars carries it."""

    label: str
    background: bool

    @property
    def name(self) -> str:
        """The label without its family prefix -- ``Mountains``, ``009`` --
        or, for a stream outside either family, without the namespace the
        tables spell every label with: ``UnusedLevelData_LavaCaveL2``."""
        prefix = BACKGROUND_PREFIX if self.background else LEVEL_PREFIX
        if self.label.startswith(prefix):
            return self.label[len(prefix) :]
        if self.label.startswith(NAMESPACE):
            return self.label[len(NAMESPACE) :]
        return self.label

    def describe(self) -> str:
        """The entry as a list offers it, saying which kind it is."""
        kind = "Background" if self.background else "Level data"
        return f"{kind}: {self.name}"


@dataclass(frozen=True)
class RepointMark:
    """A Layer 2 repoint, carried beside its undo step.

    The pointer is a *project* fact -- a line of ``levels/pointers/layer2.asm``
    -- not a field of the document, so the document snapshots the history
    holds cannot take it back by themselves: whichever way a walk crosses this
    step, the table has to be rewritten to the end being stepped onto. The
    mark is how the window recognises the boundary, and it is handed back to
    the walk itself so it stays on the boundary whichever stack the step is
    on -- an undo files it with the step's redo half and a redo files it back.
    """

    before: Layer2Entry
    after: Layer2Entry


@dataclass(frozen=True)
class Layer2Table:
    """The table as its lines and as its entries, kept together so a rewrite
    can replace one line without re-deriving the rest."""

    lines: tuple[str, ...]
    entries: tuple[Layer2Entry, ...]

    @classmethod
    def read(cls, text: str) -> Layer2Table:
        """Parse the table, refusing any line that is neither grammar.

        Refusing rather than skipping, because a skipped line would renumber
        every level below it: the level number *is* the line's position.
        """
        lines = text.splitlines()
        entries = []
        for number, line in enumerate(lines):
            entries.append(_parse(line, number))
        return cls(lines=tuple(lines), entries=tuple(entries))

    def text(self) -> str:
        return "\n".join(self.lines) + "\n"

    def entry(self, level: int) -> Layer2Entry:
        """What ``level``'s Layer 2 points at."""
        if not 0 <= level < len(self.entries):
            raise Layer2TableError(
                f"the Layer 2 table has no entry for level {hexnum(level, 3)}"
            )
        return self.entries[level]

    def levels_pointing(self, entry: Layer2Entry) -> tuple[int, ...]:
        """Every level number whose entry is ``entry``, in order."""
        return tuple(level for level, held in enumerate(self.entries) if held == entry)

    def choices(self) -> tuple[Layer2Entry, ...]:
        """Everything the table points at, once each: backgrounds first by
        name, then level data. The order a picker shows."""
        return choices(self)

    def repointed(
        self, level: int, entry: Layer2Entry, donors: Layer2Table | None = None
    ) -> Layer2Table:
        """This table with ``level``'s entry replaced by ``entry``.

        The new line borrows its spelling from a line that already points at
        ``entry`` -- its directive, its tabs, everything up to the trailing
        level-number comment -- so the rewritten file differs from the original
        in exactly the one line that changed. ``donors`` is a second table to
        borrow from when this one has no such line any more: repointing the
        only reader of a stream away from it and later back would otherwise
        strand the stream un-nameable, so the caller passes the stock table.

        A label no line in either table points at -- a Layer 2 stream the
        banks insert that no level number has ever read -- borrows a line of
        the same *kind* instead, with its label swapped in: the grammar is the
        line's, and the label is the only thing a kind's lines differ in.
        """
        current = self.entry(level)
        if current == entry:
            return self
        line = _donor_line(self, entry) or (
            _donor_line(donors, entry) if donors is not None else None
        )
        if line is None:
            line = _kind_line(self, entry) or (
                _kind_line(donors, entry) if donors is not None else None
            )
        if line is None:
            raise Layer2TableError(f"no line in the table points at {entry.label}")
        head, found, _comment = line.rpartition(";")
        rewritten = f"{head};" if found else f"{line}\t;"
        lines = list(self.lines)
        lines[level] = f"{rewritten} {level:03X}"
        entries = list(self.entries)
        entries[level] = entry
        return Layer2Table(lines=tuple(lines), entries=tuple(entries))


def choices(
    *tables: Layer2Table, extra: Iterable[Layer2Entry] = ()
) -> tuple[Layer2Entry, ...]:
    """Everything any of ``tables`` points at, and ``extra`` besides, ordered
    as one picker list.

    The union matters when one of them is an edited copy: an entry repointed
    away from everywhere still has to be offered, or the edit could never be
    taken back. ``extra`` is what no table has to name to be pointable -- the
    Layer 2 streams the banks insert under a label nothing reads yet.
    """
    found = {entry for table in tables for entry in table.entries} | set(extra)
    return tuple(sorted(found, key=lambda e: (not e.background, e.name)))


def _parse(line: str, number: int) -> Layer2Entry:
    if found := _BACKGROUND.match(line):
        return Layer2Entry(label=found.group(1), background=True)
    if found := _LEVEL.match(line):
        return Layer2Entry(label=found.group(1), background=False)
    raise Layer2TableError(
        f"line {number} of the Layer 2 table is neither a background nor a "
        f"level pointer: {line.strip()!r}"
    )


def _donor_line(table: Layer2Table, entry: Layer2Entry) -> str | None:
    for held, line in zip(table.entries, table.lines, strict=True):
        if held == entry:
            return line
    return None


def _kind_line(table: Layer2Table, entry: Layer2Entry) -> str | None:
    """A line of ``entry``'s kind with ``entry``'s label in place of its own,
    or ``None`` when the table has no line of that kind to borrow."""
    grammar = _BACKGROUND if entry.background else _LEVEL
    for held, line in zip(table.entries, table.lines, strict=True):
        if held.background != entry.background:
            continue
        found = grammar.match(line)
        if found is not None:
            return line[: found.start(1)] + entry.label + line[found.end(1) :]
    return None
