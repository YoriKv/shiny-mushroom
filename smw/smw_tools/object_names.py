"""What each level object number means, read out of the object dispatch tables.

`Bank0D.asm` names every object routine it dispatches to -- the tables are
`dl SMW_StandardObj05_Coins_Main` and its neighbours -- so the game's own
vocabulary for its objects is already written down. This reads those tables back
out, which is the only way to get the names without copying someone else's list
and hoping it agrees with this tree.

Six tables, all of them here:

- one extended-object table, indexed by the settings byte, and
- five standard-object tables, one per tileset group, indexed by object
  number - 1.

**This reads; it does not write.** The editor's `object-metadata.json` was
seeded from these tables once and is the source of truth from then on -- a
frozen build ships the app and not the source, and a name in that file is
allowed to read better than the routine it came from. What this is for now is
the check that keeps the two from parting company: `smw/tests/test_level_metadata.py`
asserts the bundled file names exactly the numbers these tables dispatch, so an
object gained, lost or renumbered in the disassembly fails with a line number
rather than by drawing the wrong thing.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

from .map16 import TILESET_TABLES
from .paths import SRC_DIR

#: The bank holding both the extended-object dispatcher and the five tileset
#: object tables.
OBJECT_BANK = SRC_DIR / "SMW" / "Banks" / "Bank0D.asm"

#: The five standard tables, by the label that starts them, in the order the
#: tileset dispatcher lists them. The key is the name the editor knows the group
#: by; which tileset numbers map to which group is `TILESET_GROUPS`.
STANDARD_TABLES = ("Grassland", "Castle", "Rope", "Underground", "GhostHouse")

#: Tileset number -> group, from `SMW_ProcessStandardAndTilesetSpecificObjects`'s
#: `TilesetPtrs`. Fifteen tilesets share five object tables.
#:
#: The same fifteen rows as :data:`smw_tools.map16.TILESET_TABLES`, which the
#: Map16 loader arrives at from a table of its own, so they are written down
#: once and `test_object_names` reads `TilesetPtrs` back out of the bank to
#: check that the two ROM facts still agree.
TILESET_GROUPS = dict(enumerate(TILESET_TABLES))

#: One entry of a dispatch table: `dl SMW_<anything>Obj<NN>_<Name>_Main`. The
#: prefix varies (Standard, Extended, Grassland, ...) and carries no information
#: the table's own position does not already give.
_ENTRY = re.compile(r"^\s*dl\s+SMW_\w*?Obj([0-9A-F]{2})_(\w+?)_Main", re.MULTILINE)

#: A run of capitals is one word (`ONOFF`, `PSwitch`), a capital after a
#: lowercase or a digit starts one (`TurnBlock`, `3upMoon`).
_WORD_BREAK = re.compile(r"(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])")

#: A dispatch entry that goes nowhere: `%SetDuplicateOrNullPointer($000000, X)`
#: puts label `X` at address zero, so the table entry naming it is a long jump
#: into the first bytes of bank `$00` and the cartridge is gone the moment the
#: loader takes it. The macro's other form aliases one routine to another --
#: `$98`-`$FF` are the door at `$47` -- and those are live entries, so only the
#: `$000000` form is read here.
#:
#: The extended table only. A nulled *standard* object would need naming by
#: tileset group as well as by number, so it would be a second field rather than
#: a member of this one; the bank has none.
_NULL_ENTRY = re.compile(
    r"^\s*%SetDuplicateOrNullPointer\(\$000000,"
    r"\s*SMW_ExtendedObj([0-9A-F]{2})_\w+?_Main\)",
    re.MULTILINE,
)


@dataclass(frozen=True)
class ObjectNames:
    """Every object name in the bank, by table."""

    #: Settings byte -> name, for objects whose number is 0.
    extended: dict[int, str]
    #: Group name -> {object number -> name}.
    standard: dict[str, dict[int, str]]
    #: The extended settings bytes whose dispatch entry is `$000000`, and so
    #: the records that take the cartridge down rather than drawing anything.
    #: See :data:`_NULL_ENTRY`.
    crashes: frozenset[int]


def readable(name: str) -> str:
    """A routine's name as prose: ``TurnBlockWithPSwitch`` -> ``Turn Block With
    PSwitch``."""
    return _WORD_BREAK.sub(" ", name)


def _table(text: str, label: str) -> dict[int, str]:
    """The `dl` entries following ``label:``, by the number in each name.

    Keyed on the number the routine's own name carries rather than on the
    entry's position: the two agree throughout the bank, and a name is checkable
    against the source while a position is not.

    The run stops at the first line that is not a `dl` -- the tables are
    contiguous, and reading past one means reading the next table's names into
    it. A `dl` that is not a named routine is skipped rather than ending the
    run, so a table with a raw hole in it keeps the entries after the hole.
    """
    lines = text.splitlines()
    start = next(n for n, line in enumerate(lines) if line.startswith(f"{label}:"))
    entries: dict[int, str] = {}
    for line in lines[start + 1 :]:
        if not line.lstrip().startswith("dl "):
            break
        match = _ENTRY.match(line)
        if match is not None:
            entries[int(match.group(1), 16)] = readable(match.group(2))
    return entries


def read_object_names(path: Path | None = None) -> ObjectNames:
    """Parse the six dispatch tables out of the object bank."""
    text = (path or OBJECT_BANK).read_text()
    return ObjectNames(
        extended=_table(text, "ExtendedObjectPtrs"),
        standard={group: _table(text, f"{group}Ptrs") for group in STANDARD_TABLES},
        crashes=frozenset(int(number, 16) for number in _NULL_ENTRY.findall(text)),
    )
