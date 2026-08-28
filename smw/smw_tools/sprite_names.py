"""What each sprite number means, read out of the sprite dispatch tables.

The game names every sprite routine it dispatches to, so its own vocabulary for
its sprites is already written down -- `.NorSpr02B_Chuck` and its neighbours.
This reads those tables back out, which is the only way to get the names without
copying someone else's list and hoping it agrees with this tree.

A level's sprite number is not one index but four, because the loader
(`SMW_ParseLevelSpriteList`) splits the range and hands each part to a different
dispatcher. The four tables here are those parts:

- **normal sprites**, `NormalSpriteNormalPtrs` in Bank01, indexed by the sprite
  number itself,
- **shooters**, `ShooterSprPtrs` in Bank02, indexed by a shooter ID,
- **generators**, `GeneratorSprPtrs` in Bank02, indexed by a generator ID, and
- **layer scroll commands**, the layer 1 table in
  `SMW_InitializeScrollSprites`, indexed by a scroll ID.

Turning a level's sprite number into the right index is the loader's business
and is done in `shiny_mushroom.sprites`, which is where that arithmetic is
documented; what belongs here is only the reading of the tables.

**This reads; it does not write.** The editor's `sprite-metadata.json` was
seeded from these tables once and is the source of truth from then on -- a
frozen build ships the app and not the source, and a name in that file is
allowed to read better than the routine it came from. What this is for now is
the check that keeps the two from parting company
(`smw/tests/test_level_metadata.py`), and the categories, which are checked
against the routine names rather than against the displayed ones: whether a
routine is *named* `Unused` is a fact about the disassembly and not something a
nicer label may quietly change.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

from .object_names import readable
from .paths import SRC_DIR

#: The banks each table lives in.
NORMAL_BANK = SRC_DIR / "SMW" / "Banks" / "Bank01.asm"
SPAWNER_BANK = SRC_DIR / "SMW" / "Banks" / "Bank02.asm"
SCROLL_BANK = SRC_DIR / "SMW" / "Banks" / "Bank05.asm"

#: The layer 1 scroll table has no label of its own beyond the address it was
#: found at, so it is named the way the disassembly names it.
SCROLL_TABLE = "Ptrs05BCF0"

#: One entry of a dispatch table. The number and name come from whichever of the
#: two names on the line carries them -- the local label where the table has
#: one, the routine it points at where it does not. Both spell the same thing.
_ENTRY = re.compile(r"(?:^\.|SMW_)(?:NorSpr|ShooterSpr|GenSpr)([0-9A-F]{2,3})_(\w+?)_")

#: Lines that sit inside a table without being entries: asar's `base`, comments,
#: and the blank lines between them.
_SKIP = re.compile(r"^\s*(;|base\b|$)")


@dataclass(frozen=True)
class SpriteNames:
    """Every sprite name in the four tables, by the index its own dispatcher
    uses."""

    #: Sprite number -> name, for `$00`-`$C8`.
    normal: dict[int, str]
    #: Shooter ID -> name.
    shooter: dict[int, str]
    #: Generator ID -> name.
    generator: dict[int, str]
    #: Sprite number -> name, for the layer scroll commands. Their own IDs count
    #: from zero, but every entry's name carries the sprite number instead, and
    #: that is what the editor looks one up by.
    scroll: dict[int, str]


def _table(text: str, label: str, first: int) -> dict[int, str]:
    """The `dw` entries following ``label:``, by the number in each name.

    Keyed on the number the routine's own name carries rather than on the
    entry's position -- a name is checkable against the source while a position
    is not. The two are then required to agree: the run has to start at ``first``
    and count up by one, so an entry gained, lost or reordered fails here rather
    than renaming every sprite after it.

    The run stops at the first line that is neither an entry nor the padding a
    table is allowed to contain (`base`, comments, blanks).
    """
    lines = text.splitlines()
    start = next(n for n, line in enumerate(lines) if line.startswith(f"{label}:"))
    entries: dict[int, str] = {}
    for line in lines[start + 1 :]:
        if _SKIP.match(line):
            continue
        match = _ENTRY.search(line)
        if match is None or " dw " not in line.replace("\t", " "):
            break
        number = int(match.group(1), 16)
        expected = first + len(entries)
        if number != expected:
            raise ValueError(
                f"{label}: entry {len(entries)} names ${number:02X}, "
                f"expected ${expected:02X}"
            )
        entries[number] = readable(match.group(2))
    if not entries:
        raise ValueError(f"{label}: no entries")
    return entries


def read_sprite_names(
    normal: Path | None = None,
    spawner: Path | None = None,
    scroll: Path | None = None,
) -> SpriteNames:
    """Parse the four dispatch tables out of the three banks that hold them."""
    spawners = (spawner or SPAWNER_BANK).read_text()
    return SpriteNames(
        normal=_table((normal or NORMAL_BANK).read_text(), "NormalSpriteNormalPtrs", 0),
        shooter=_table(spawners, "ShooterSprPtrs", 1),
        generator=_table(spawners, "GeneratorSprPtrs", 1),
        scroll=_table((scroll or SCROLL_BANK).read_text(), SCROLL_TABLE, 0xE7),
    )
