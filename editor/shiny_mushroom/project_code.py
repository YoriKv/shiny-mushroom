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

import re
from collections.abc import Iterable
from dataclasses import dataclass
from pathlib import Path

from shiny_mushroom.project import Project
from smw_tools import level_code
from smw_tools.symbols import SymbolTable

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


@dataclass(frozen=True)
class Imported:
    """What bringing outside files in did: where each landed, and the notes
    that say what was rewritten -- kept at the top of the stored file as
    well, because they matter most the day the routine misbehaves."""

    landed: tuple[Path, ...]
    notes: tuple[str, ...]


#: The five kinds a person creates or imports a file as, keyed by the word
#: the dialog and the tests use, each with the folder it lands in, what its
#: name is (for the sentence that asks), and the entry points a file of it
#: may declare -- none for the two libraries, whose labels are the caller's.
#: The level and game mode kinds name a number; the global kind one of the
#: tool's two stems; the libraries any name asar can read as a namespace.
KINDS: dict[str, tuple[Path, str, tuple[str, ...]]] = {
    "level": (LEVELS, "the level number, in hexadecimal", level_code.ENTRIES),
    "gamemode": (
        GAMEMODES,
        f"the game mode number, in hexadecimal, or {EVERY_MODE} for every mode",
        level_code.GAMEMODE_ENTRIES,
    ),
    "global": (GLOBAL, "global or statusbar", ("init", "main")),
    "library": (LIBRARY, "the library's name", ()),
    "macros": (MACROS, "the macro file's name", ()),
}

#: A name a library or macro file may have: asar reads it as a namespace,
#: and a label in it is reached as ``<name>_<label>``.
_NAME = re.compile(r"[A-Za-z_]\w*\Z")


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


def _one_spelling(seen: dict[int, str], number: int, stem: str, what: str) -> None:
    """Two stems that are one number -- ``1.asm`` and ``01.asm`` -- would be
    one set of rows with the later file silently winning; refused by name."""
    if number in seen:
        raise CodeError(
            f"{seen[number]}.asm and {stem}.asm are both {what} "
            f"${number:X}: one file per {what}, in one spelling."
        )
    seen[number] = stem


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
    numbered: dict[int, str] = {}
    for stem, relative in _files(project, LEVELS).items():
        if relative.name in (LEVEL_ROWS.name, LEVEL_DATA.name):
            continue  # the fragments themselves, which the build writes
        level = _number(stem, 0x1FF, "level")
        _one_spelling(numbered, level, stem, "level")
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
    numbered: dict[int, str] = {}
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
            _one_spelling(numbered, mode, stem, "game mode")
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


def stem_for(kind: str, name: str) -> str:
    """The filename a file of ``kind`` called ``name`` gets, refused with a
    sentence where ``name`` is not one the folder accepts.

    A number is normalised to the spelling the fragments expect -- three
    digits for a level, two for a game mode -- so ``5`` and ``005`` cannot
    both be created and then refused as one level spelled twice.
    """
    if kind not in KINDS:
        raise CodeError(f"{kind} is not a code kind; they are {', '.join(KINDS)}")
    name = name.strip()
    if not name:
        raise CodeError(f"A {kind} file needs a name: {KINDS[kind][1]}.")
    if kind == "level":
        return f"{_named_number(name, 0x1FF, 'level'):03X}"
    if kind == "gamemode":
        if name.lower() == EVERY_MODE:
            return EVERY_MODE
        return f"{_named_number(name, level_code.GAME_MODE_COUNT - 1, 'game mode'):02X}"
    if kind == "global":
        if name.lower() not in GLOBAL_FILES:
            raise CodeError(
                f"The global folder holds "
                f"{' and '.join(f'{held}.asm' for held in sorted(GLOBAL_FILES))} "
                f"and nothing else, so a global file is one of those."
            )
        return name.lower()
    if not _NAME.match(name):
        raise CodeError(
            f"{name} cannot name a {kind} file: the name is a namespace, so it "
            f"is letters, digits and underscores, not starting with a digit."
        )
    return name


def _named_number(name: str, limit: int, what: str) -> int:
    """:func:`_number` for a name that is not a file yet, refused in the
    asking's own words rather than the folder's."""
    try:
        found = int(name.removeprefix("$"), 16)
    except ValueError:
        raise CodeError(
            f"{name} is not a {what} number: one is written in hexadecimal, "
            f"$000 to ${limit:03X}."
        ) from None
    if not 0 <= found <= limit:
        raise CodeError(
            f"{name} names a {what} past ${limit:03X}, which the cartridge "
            f"does not have."
        )
    return found


def template(kind: str, stem: str) -> str:
    """A file of ``kind`` with nothing in it yet but the right shape: a
    header saying what it is and what it may declare, and each entry point
    the kind serves as a label that returns at once.

    The globals return with ``RTS`` -- UberASM Tool's convention for those
    two tags, which the hooks call intra-bank for exactly that reason -- and
    everything else with ``RTL``. A library file declares no entry point,
    because its labels are whatever the caller reaches for.
    """
    if kind == "level":
        head = (
            f"; Level ${int(stem, 16):03X}'s code, run through UberASM Support.\n"
            f"; It may declare load:, init:, main: and nmi:, each returning "
            f"with RTL;\n"
            f"; an entry point not written here costs nothing.\n"
        )
        return head + _entries(("init", "main"), "RTL")
    if kind == "gamemode":
        which = (
            "every game mode"
            if stem == EVERY_MODE
            else f"game mode ${int(stem, 16):02X}"
        )
        head = (
            f"; Code for {which}, run through UberASM Support.\n"
            f"; It may declare init: (the mode's first frame), main: (every "
            f"frame after)\n"
            f"; and end: (after the game's own routine), each returning with "
            f"RTL.\n"
        )
        return head + _entries(("init", "main"), "RTL")
    if kind == "global":
        allowed = tuple(GLOBAL_FILES[stem])
        what = (
            "The global code: init: runs once at boot, main: every frame"
            if stem == "global"
            else "The status bar code: main: runs whenever the counters are drawn"
        )
        head = (
            f"; {what}.\n"
            f"; UberASM Tool's convention for this file: each routine returns "
            f"with RTS.\n"
        )
        return head + _entries(allowed, "RTS")
    if kind == "library":
        return (
            f"; Library {stem}: every label here is reached from any code file "
            f"as {stem}_<label>,\n"
            f"; and the file is assembled whether anything calls it or not.\n"
            f"; A routine is a label returning with RTL:\n"
            f";\n"
            f";   routine:\n"
            f";       RTL\n"
        )
    return (
        "; Macros and defines for the project's code, read once ahead of "
        "every file.\n"
        "; A macro is called as %name() from any code file:\n"
        ";\n"
        ";   macro name()\n"
        ";   endmacro\n"
    )


def _entries(entries: Iterable[str], returns: str) -> str:
    return "".join(f"\n{entry}:\n\t{returns}\n" for entry in entries)


def create_file(project: Project, kind: str, name: str) -> Path:
    """Write an empty file of ``kind`` called ``name`` into its folder, from
    :func:`template`, and say where it landed, relative to the overlay.

    A file already there is refused rather than overwritten: creating is
    how a routine starts, and somebody's routine is not a thing to start
    over by mistake.
    """
    stem = stem_for(kind, name)
    folder = KINDS[kind][0]
    target = project.overlay / project.base.name / folder / f"{stem}.asm"
    if target.exists():
        raise CodeError(f"{folder / target.name} already exists.")
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(template(kind, stem), encoding="utf-8", newline="\n")
    return target.relative_to(project.overlay)


def import_file(
    project: Project,
    kind: str,
    path: Path,
    name: str,
    symbols: SymbolTable | None,
) -> Imported:
    """Bring one UberASM file in from outside, as ``kind`` under ``name``,
    rewritten to assemble here.

    One rewrite, the sprites' own: ROM literals become this build's labels
    (:func:`shiny_mushroom.patches.convert_import`, which leaves RAM and
    conditional-line addresses alone). What the file declares is checked
    first, the way the build checks it -- a global ``nmi:``, a level ``end:``
    -- so a file the kind cannot run is refused here by name rather than by
    every build after. The name is the caller's to give, because the file
    cannot say it: UberASM Tool's list file carried the level number, and
    ``Wallkick.asm`` says nothing about which level wanted it.
    """
    from shiny_mushroom.patches import convert_import

    stem = stem_for(kind, name)
    folder, _what, allowed = KINDS[kind]
    text = path.read_text(encoding="latin-1")
    if allowed:
        if kind == "global":
            allowed = tuple(GLOBAL_FILES[stem])
        _served(path.stem, level_code.declared(text), allowed, f"{kind} code")
    target = project.overlay / project.base.name / folder / f"{stem}.asm"
    if target.exists():
        raise CodeError(f"{folder / target.name} already exists.")
    converted = convert_import(text, symbols)
    header = f"; Imported from {path.name}.\n" + "".join(
        f"; import: {note}\n" for note in converted.notes
    )
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(header + converted.source, encoding="utf-8", newline="\n")
    landed = target.relative_to(project.overlay)
    notes = (f"{path.name} -> {folder / target.name}",) + tuple(
        f"  {note}" for note in converted.notes
    )
    return Imported((landed,), notes)


#: The folders a project's code goes in, all five.
FOLDERS = (LEVELS, GAMEMODES, GLOBAL, LIBRARY, MACROS)


def make_folders(project: Project) -> tuple[Path, ...]:
    """Make every code folder exist, empty if need be -- what switching the
    feature on does, so the place a file goes is there to find before
    anybody has written one. Says which were made, relative to the overlay."""
    made = []
    for folder in FOLDERS:
        held = project.overlay / project.base.name / folder
        if not held.is_dir():
            held.mkdir(parents=True, exist_ok=True)
            made.append(held.relative_to(project.overlay))
    return tuple(made)


def carried(project: Project) -> tuple[Path, ...]:
    """Every code file the project holds, across all five folders -- what
    keeps UberASM Support's switch down while there are any."""
    found: list[Path] = []
    for folder in FOLDERS:
        held = project.overlay / project.base.name / folder
        if not held.is_dir():
            continue
        found += sorted(
            path.relative_to(project.overlay)
            for path in held.iterdir()
            if path.is_file() and path.suffix == ".asm"
        )
    return tuple(found)


def library_fragment(project: Project) -> str:
    """The fragment assembling the shared library, one file per line."""
    return level_code.lib_fragment(_files(project, LIBRARY))


def macros_fragment(project: Project) -> str:
    """The fragment reading the macro library, one file per line."""
    return level_code.macros_fragment(_files(project, MACROS))
