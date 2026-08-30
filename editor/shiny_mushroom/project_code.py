"""The project's own asm, and the fragments the build reads it through.

A project writes routines into five folders and the build has to be told
about them. That telling is a fragment apiece, derived here from what is
actually in the folder -- so a file appearing is a file assembled, and a file
deleted is one the next build does not look for.

**A file's folder says what kind it is and its name says what it is for.**
``code/levels/105.asm`` is level ``$105``'s; ``code/gamemode/14.asm`` is game
mode ``$14``'s and ``code/gamemode/all.asm`` every mode's;
``code/global/global.asm`` and ``code/global/statusbar.asm`` are the tool's
two single files; ``code/uberasm/lib/math.asm`` is a library everything can
call and ``code/uberasm/macros/*.asm`` a macro library read once. There is
no list file, because a list file is a second place for the same fact to be
written down and to be wrong.

**What a file declares is a claim the assembler settles.** The entry points
are read as text, the way UberASM Tool reads them, and a label inside a false
``if`` is declared here and absent from the build. Whoever writes the rows
has to drop one the assembler could not find -- which is a build failure
naming the label, not a silent row into nothing. A label a file's kind
cannot serve -- ``end:`` in a level's file, ``nmi:`` in a game mode's -- is
refused by name for the same reason.
"""

from __future__ import annotations

from pathlib import Path

from shiny_mushroom.project import Project
from smw_tools import level_code

#: The folders a project writes into, under the game tree in the overlay.
LEVELS = Path(level_code.CODE_DIR)
GAMEMODES = Path(level_code.GAMEMODE_DIR)
GLOBAL = Path(level_code.GLOBAL_DIR)
LIBRARY = Path(level_code.LIB_DIR)
MACROS = Path(level_code.MACROS_DIR)

#: The fragments each is read through, and their shipped contents' shape.
LEVEL_ROWS = Path(level_code.ROWS_FRAGMENT)
LEVEL_DATA = Path(level_code.DATA_FRAGMENT)
GAMEMODE_ROWS = Path("code/gamemode/gamemode-code.asm")
GAMEMODE_DATA = Path("code/gamemode/gamemode-code-data.asm")
GLOBAL_ROWS = Path("code/global/global-code.asm")
GLOBAL_DATA = Path("code/global/global-code-data.asm")
LIBRARY_ROWS = Path(level_code.LIB_FRAGMENT)
MACROS_ROWS = Path(level_code.MACROS_FRAGMENT)

#: The game mode file that runs on every mode: the tool's ``*``.
EVERY_MODE = "all"

#: The two global files, by stem, and what each may declare: the tool's
#: ``global_code.asm`` carries ``init:`` and ``main:``, its
#: ``status_code.asm`` a ``main:`` of its own. One routine apiece, so the
#: fragment is defines rather than a table.
GLOBAL_FILES = {
    "global": {"init": "SMW_GlobalCode_Init", "main": "SMW_GlobalCode_Main"},
    "statusbar": {"main": "SMW_GlobalCode_Status"},
}


class CodeError(Exception):
    """A project's own asm that cannot be assembled as it stands."""


def _files(project: Project, folder: Path) -> dict[str, Path]:
    """Every ``.asm`` a project put in one of its folders, by stem."""
    held = project.overlay / project.base.name / folder
    if not held.is_dir():
        return {}
    return {
        found.stem: folder / found.name
        for found in sorted(held.glob("*.asm"))
        if found.is_file()
    }


def _text(project: Project, relative: Path) -> str:
    return (project.overlay / project.base.name / relative).read_text(
        encoding="utf-8", errors="replace"
    )


def _number(stem: str, limit: int, what: str) -> int:
    """The hexadecimal a file's name is, which is what it is for."""
    try:
        found = int(stem, 16)
    except ValueError:
        raise CodeError(
            f"{stem}.asm is in the {what} folder, where a file's name is the "
            f"{what} it runs in, written in hexadecimal"
        ) from None
    if not 0 <= found <= limit:
        raise CodeError(
            f"{stem}.asm names a {what} past ${limit:03X}, which the "
            f"cartridge does not have"
        )
    return found


def _served(
    stem: str, declared: tuple[str, ...], allowed: tuple[str, ...], what: str
) -> tuple[str, ...]:
    """``declared`` checked against what ``what`` can run: an entry point
    the kind cannot serve is refused by name, and none at all is refused
    too, because nothing would call the file."""
    for entry in declared:
        if entry not in allowed:
            raise CodeError(
                f"{stem}.asm declares {entry}:, which {what} code cannot run. "
                f"It may declare {', '.join(allowed)}."
            )
    if not declared:
        raise CodeError(
            f"{stem}.asm declares none of {', '.join(allowed)}, so nothing "
            f"would call it."
        )
    return declared


def level_fragments(project: Project) -> tuple[str, str]:
    """The rows naming each level's routines, and the data reading them.

    One row per entry point the file declares, so a file with only a
    ``main:`` costs one row and a file with all four costs four. The
    namespace is the level's, which is what makes two levels' ``main``
    labels two labels.
    """
    rows: dict[str, dict[int, str]] = {}
    data: list[str] = []
    for stem, relative in _files(project, LEVELS).items():
        if relative.name in (LEVEL_ROWS.name, LEVEL_DATA.name):
            continue  # the fragments themselves, which the build writes
        level = _number(stem, 0x1FF, "level")
        name = f"Level{level:03X}"
        declared = level_code.declared(_text(project, relative))
        for entry in _served(stem, declared, level_code.ENTRIES, "a level's"):
            rows.setdefault(entry, {})[level] = f"{name}_{entry}"
        data.append(level_code.namespaced(name, relative.as_posix()))
    return level_code.rows_fragment(rows), "".join(data)


def gamemode_fragments(project: Project) -> tuple[str, str]:
    """The same for the game modes: one row per entry point the file
    declares, and ``all.asm``'s routines ahead of every mode's own.

    ``init`` runs on a mode's first frame in place of ``main``, which runs
    on every frame after; ``end`` runs after the game's own routine. The
    cartridge keeps which frame is a mode's first, so a file may declare
    whichever it likes for whichever mode.
    """
    rows: dict[str, dict[int, str]] = {}
    every: dict[str, str] = {}
    data: list[str] = []
    for stem, relative in _files(project, GAMEMODES).items():
        if relative.name in (GAMEMODE_ROWS.name, GAMEMODE_DATA.name):
            continue
        declared = level_code.declared(_text(project, relative))
        if stem == EVERY_MODE:
            name = "GamemodeAll"
            for entry in _served(
                stem, declared, level_code.GAMEMODE_ENTRIES, "game mode"
            ):
                every[entry] = f"{name}_{entry}"
        else:
            mode = _number(stem, level_code.GAME_MODE_COUNT - 1, "game mode")
            name = f"Gamemode{mode:02X}"
            for entry in _served(
                stem, declared, level_code.GAMEMODE_ENTRIES, "game mode"
            ):
                rows.setdefault(entry, {})[mode] = f"{name}_{entry}"
        data.append(level_code.namespaced(name, relative.as_posix()))
    return level_code.gamemode_fragment(rows, every), "".join(data)


def global_fragments(project: Project) -> tuple[str, str]:
    """The defines naming the global routines, and the data reading them.

    Defines rather than rows, because there is one routine per entry point:
    each hook in ``Banks/`` asks whether its own was named, so an entry
    point nobody wrote costs no hook at all.
    """
    lines: list[str] = []
    data: list[str] = []
    for stem, relative in _files(project, GLOBAL).items():
        if relative.name in (GLOBAL_ROWS.name, GLOBAL_DATA.name):
            continue
        if stem not in GLOBAL_FILES:
            raise CodeError(
                f"{stem}.asm is in the global folder, which holds "
                f"{' and '.join(f'{name}.asm' for name in sorted(GLOBAL_FILES))} "
                f"and nothing else"
            )
        allowed = tuple(GLOBAL_FILES[stem])
        name = stem.capitalize()
        declared = level_code.declared(_text(project, relative))
        for entry in _served(stem, declared, allowed, f"{stem}.asm's"):
            lines.append(f"!{GLOBAL_FILES[stem][entry]} = {name}_{entry}\n")
        data.append(level_code.namespaced(name, relative.as_posix()))
    return "".join(lines), "".join(data)


def library_fragment(project: Project) -> str:
    """The fragment assembling the shared library, one file per line."""
    return level_code.lib_fragment(_files(project, LIBRARY))


def macros_fragment(project: Project) -> str:
    """The fragment reading the macro library, one file per line."""
    return level_code.macros_fragment(_files(project, MACROS))
