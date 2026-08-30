"""Figures the assembler declares, read from the files that declare them.

A handful of sizes are facts both sides of this project need: asar needs them
to place what follows and to assert what it emitted, and this package needs
them to say where a table ended up, what a switch costs a run, and whether a
save will fit. A stub's length, a block's size, the head of a reservation --
each is one number that must mean the same thing to the assembler and to the
editor pricing a dialog against it.

**So it is declared once, in the asm, and read here.** That is the opposite
trade from :mod:`smw_tools.bases` and :mod:`smw_tools.features`, where an
address is held rather than discovered -- and it is the same trade for the
same reason. A held address describes a cartridge nothing here builds, and a
test is the only thing that could ever check it; these figures are ones the
build *asserts* at the spot it emits them, so the honest single copy is the
one asar reads. What was here before was a second copy of each, held equal by
a test -- which catches the drift a release later rather than at the assert.

Every figure is the shipped one, unedited, because that is what a declared
address is: a project that reworded a message or dressed a level reads its
own build's symbol file.

Two readers over one parse:

- :func:`define` -- any literal define ``SMW/Config/`` states, by its own
  name. For a stub whose size belongs to the file that emits it.
- :func:`block` -- an occupant's block in a packed run, from
  ``Config/PackedRuns.asm``. Those are declared together rather than in each
  occupant's own file because an occupant is read past the blocks of whichever
  occupants ahead of it the cartridge has, so a block is the run's business
  and not one file's.

Only literal defines are read. An expression would be a figure computed twice
-- once by asar and once here -- which is exactly what this module exists to
stop.
"""

from __future__ import annotations

import re
from collections.abc import Mapping
from functools import cache
from types import MappingProxyType

from .paths import GAME_DIR

#: Where the declarations are: the config folder, and the one file in it that
#: declares the packed runs' blocks.
CONFIG_DIR = GAME_DIR / "Config"
BLOCKS = CONFIG_DIR / "PackedRuns.asm"

#: What a block's define is called: this, then the occupant's name.
BLOCK_PREFIX = "Define_SMW_Block_"

#: A literal define, which is the only form this module reads.
_DEFINE = re.compile(r"^!(Define_\w+)[ \t]*#=[ \t]*\$([0-9A-Fa-f]+)[ \t]*$", re.M)


class DefineError(Exception):
    """A define the assembler's files do not state, or state twice."""


@cache
def defines() -> Mapping[str, int]:
    """Every literal define ``SMW/Config/`` states, by name.

    Read once, on first use. One namespace over every file, which is what the
    assembler has too: a name stated twice is refused here rather than
    resolved to whichever file was read last.
    """
    found: dict[str, int] = {}
    for path in sorted(CONFIG_DIR.glob("*.asm")):
        for name, value in _DEFINE.findall(path.read_text(encoding="utf-8")):
            if name in found:
                raise DefineError(f"!{name} is stated twice, once in {path.name}")
            found[name] = int(value, 16)
    if not found:
        raise DefineError(f"{CONFIG_DIR} states no defines")
    return MappingProxyType(found)


def define(name: str) -> int:
    """One define, by the name the asm gives it without its ``!``."""
    try:
        return defines()[name]
    except KeyError:
        raise DefineError(
            f"SMW/Config/ states no !{name}. A figure this package prices "
            "anything by is the assembler's declaration, read rather than "
            "restated."
        ) from None


def block(name: str) -> int:
    """The block ``name`` occupies in its packed run, unedited.

    Named the way ``Config/PackedRuns.asm`` names it -- the define without
    :data:`BLOCK_PREFIX` -- so a reader finds the figure and the comment that
    says what it covers in one search.
    """
    try:
        return defines()[BLOCK_PREFIX + name]
    except KeyError:
        raise DefineError(
            f"{BLOCKS.name} declares no {BLOCK_PREFIX}{name}. Every occupant "
            "of a packed run declares its block there, and nothing else "
            "declares one -- a run priced as though an occupant's bytes were "
            "free is the failure this mechanism exists to prevent."
        ) from None
