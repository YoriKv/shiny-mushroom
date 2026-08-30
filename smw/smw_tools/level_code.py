"""What a project's own code may say, and the fragments it is read through.

``Config/LevelCode.asm``, ``Config/GameModeCode.asm`` and
``Config/UberASM.asm`` assemble a project's routines out of fragments the
editor regenerates -- the rows naming each level's or mode's routine per
entry point, the routines themselves, the macro library and the shared
library. This module is their grammar: what a file may declare, and the
text of each fragment.

Nothing here parses 65816, and nothing here rewrites a file. A file is
asar's to understand, and the placements that read it check the one thing
a text scan could not -- that an ``org`` into the game came back -- against
the assembled position rather than the source.
"""

from __future__ import annotations

import re
from collections.abc import Iterable, Mapping

#: The folders a project's own asm lives in, relative to the game folder,
#: and the fragments the build reads each through. None of these folders'
#: files shadow anything the disassembly ships -- they are the project's own
#: -- so this is what tells a reader that the build reads them at all.
CODE_DIR = "code/levels"
GAMEMODE_DIR = "code/gamemode"
GLOBAL_DIR = "code/global"
LIB_DIR = "code/uberasm/lib"
MACROS_DIR = "code/uberasm/macros"
DATA_FRAGMENT = "code/levels/level-code-data.asm"
LIB_FRAGMENT = "code/uberasm/lib.asm"
MACROS_FRAGMENT = "code/uberasm/macros.asm"

#: The fragment naming each level's routine, which the editor regenerates
#: from the files in :data:`CODE_DIR` and is nobody's to hand-edit.
ROWS_FRAGMENT = "code/levels/level-code.asm"

#: The entry points a level may have, in the order it reaches them. The
#: fragment names one table per entry point and ``Config/LevelCode.asm``
#: emits them in this order.
ENTRIES = ("load", "init", "main", "nmi")

#: The entry points a game mode may have: its first frame, every frame
#: after in front of the game's own routine, and every frame behind it
#: (``Config/GameModeCode.asm``).
GAMEMODE_ENTRIES = ("init", "main", "end")

#: Every label the tool this copies treats as an entry point anywhere, so a
#: file declaring one its kind cannot serve is refused by name rather than
#: assembled with the label ignored.
ALL_ENTRIES = ("load", "init", "main", "end", "nmi")

#: How many game modes the game dispatches, which is the length of
#: ``SMW_InitAndMainLoop``'s pointer table; the assembler checks the two
#: agree. A mode past the last has no routine of the game's to run around.
GAME_MODE_COUNT = 0x2A

#: A label at the start of a line, which is how an entry point is declared.
#: The same textual reading UberASM Tool does, and it has the same hole: a
#: label inside a false ``if`` is still a label here, so what a file declares
#: is a claim the assembler settles (:func:`declared`).
_ENTRY = re.compile(rf"^({'|'.join(ALL_ENTRIES)}):", re.M)


class LevelCodeError(Exception):
    """A file that cannot be a project's code, or a fragment that cannot
    be written."""


def declared(source: str) -> tuple[str, ...]:
    """The entry points ``source`` declares, in :data:`ALL_ENTRIES` order.

    A textual reading, so it is a claim rather than a fact: a label inside a
    false ``if`` is declared here and absent from the build. Whoever
    generates the rows has to drop one the assembler could not find.
    """
    found = set(_ENTRY.findall(source))
    return tuple(entry for entry in ALL_ENTRIES if entry in found)


def namespaced(name: str, relative: str) -> str:
    """One file, read inside a namespace of its own, so its labels are its.

    Nested, so a file that opens namespaces of its own stays inside this
    one: with asar's default, the file's first ``namespace off`` would pop
    ours and everything after it would be assembled bare.
    """
    return (
        f"namespace nested on\n"
        f"namespace {name}\n"
        f'\tincsrc "{relative}"\n'
        f"namespace off\n"
        f"namespace nested off\n"
    )


def rows_fragment(rows: Mapping[str, Mapping[int, str]]) -> str:
    """The fragment naming each level's routine, one line per row.

    ``rows`` is the routine label per level per entry point. Lines come in
    entry-point order and then level order, which is a reading order and
    nothing else -- the macro places each row at its own address, so the
    fragment may say them in any order at all.
    """
    lines = []
    for entry in ENTRIES:
        for level in sorted(rows.get(entry, {})):
            lines.append(
                f"%SMW_LevelCode({entry.capitalize()}, "
                f"${level:03X}, {rows[entry][level]})\n"
            )
    return "".join(lines)


def gamemode_fragment(
    rows: Mapping[str, Mapping[int, str]], every: Mapping[str, str] = {}
) -> str:
    """The fragment naming each game mode's routines, one macro line apiece.

    ``rows`` is the routine label per mode per entry point, ``every`` the
    routine per entry point that runs on every mode ahead of the mode's own
    -- the tool's ``*``. A mode the game does not dispatch is refused by
    name: there would be no routine of the game's to run around.
    """
    lines = []
    for entry in GAMEMODE_ENTRIES:
        if entry in every:
            lines.append(
                f"%SMW_GameModeCodeAll({entry.capitalize()}, {every[entry]})\n"
            )
        for mode in sorted(rows.get(entry, {})):
            if not 0 <= mode < GAME_MODE_COUNT:
                raise LevelCodeError(
                    f"the game does not dispatch mode ${mode:02X}, so there is "
                    f"nothing of the game's to run around. It dispatches $00 to "
                    f"${GAME_MODE_COUNT - 1:02X}."
                )
            lines.append(
                f"%SMW_GameModeCode({entry.capitalize()}, ${mode:02X}, "
                f"{rows[entry][mode]})\n"
            )
    return "".join(lines)


def lib_fragment(names: Iterable[str]) -> str:
    """The fragment that assembles the shared library, one file per line.

    Each is read inside a namespace of its own name, which is what makes a
    library file's labels reachable the way UberASM Tool makes them
    reachable -- ``math.asm``'s ``sqrt`` is ``math_sqrt`` to every level
    that calls it -- without the file having to prefix anything by hand.

    Order is the folder's, sorted, and means nothing: asar resolves every
    label in the assembly, so a library file may call another's whatever
    order they are read in. That is the one thing this has over the tool it
    copies.
    """
    return "".join(namespaced(name, f"{LIB_DIR}/{name}.asm") for name in sorted(names))


def macros_fragment(names: Iterable[str]) -> str:
    """The fragment that reads the project's macro library, one file per
    line and once: asar's macros and defines are global, so this is the one
    place such a file may be included from."""
    return "".join(f'incsrc "{MACROS_DIR}/{name}.asm"\n' for name in sorted(names))
