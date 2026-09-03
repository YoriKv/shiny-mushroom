"""The project's custom sprites, and the fragments the build reads them
through.

The same telling as :mod:`shiny_mushroom.project_code`, for the sprite
folders: what is in ``code/sprites/<kind>/`` is what the build assembles,
through fragments derived here on every build -- so a sprite file appearing
is a sprite assembled, and there is no list file to fall out of step.

**The folder says the kind and the name says the number.**
``code/sprites/normal/1A.asm`` is custom normal sprite ``$1A``'s code and
``1A.json`` beside it its properties, in PIXI's own JSON schema -- which is
what makes importing one of that tool's sprites a copy.
``code/sprites/extended/13.asm`` is a custom extended sprite, and so on per
kind; ``code/sprites/lib/`` is the library sprites may call and
``code/pixi/routines/`` the shared-routine macros.

**An entry point must be a label.** :func:`smw_tools.sprite_code.declared`
reads PIXI's ``print "MAIN", pc`` spelling too, but a rows table can only
name a label -- so a file carrying only the print form is refused with the
rewrite it needs, rather than assembled with a row into nothing.
"""

from __future__ import annotations

import json
from collections.abc import Iterable
from pathlib import Path

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.project import Project
from shiny_mushroom.project_code import (
    CodeError,
    Imported,
    _files,
    _number,
    _one_spelling,
    _text,
)
from smw_tools import level_code, sprite_code
from smw_tools.symbols import SymbolTable

#: The kind folders under ``code/sprites/``, in the grammar's own order.
#: ``normal`` is what PIXI calls a standard sprite.
KIND_FOLDERS = {
    kind: Path(sprite_code.SPRITES_DIR) / kind for kind in sprite_code.KINDS
}

LIBRARY = Path(sprite_code.LIB_DIR)
ROUTINES = Path(sprite_code.ROUTINES_DIR)

#: The fragments each folder is read through.
SPRITE_ROWS = Path(sprite_code.ROWS_FRAGMENT)
SPRITE_PROPERTIES = Path(sprite_code.PROPERTIES_FRAGMENT)
SPRITE_DATA = Path(sprite_code.DATA_FRAGMENT)
SPRITE_LIBRARY = Path(sprite_code.LIB_FRAGMENT)
PIXI_ROUTINES = Path(sprite_code.ROUTINES_FRAGMENT)


def _slug(kind: str, number: int) -> str:
    """The namespace one sprite's file is read inside, which is what makes
    two sprites' ``main`` labels two labels."""
    if kind == "normal":
        return f"CustomSpr{number:02X}"
    return f"Custom{sprite_code.KIND_TABLES[kind]}{number:02X}"


def _entries(kind: str, stem: str, text: str) -> tuple[str, ...]:
    """The entry points one file's rows may name, refused by name where
    they cannot be.

    Three refusals, each a sentence about the file: an entry point the kind
    cannot serve, none at all, and PIXI's print-only spelling, which the
    rows cannot reach and the import rewrites into a label.
    """
    allowed = (
        sprite_code.NORMAL_ENTRIES if kind == "normal" else sprite_code.KIND_ENTRIES
    )
    declared = sprite_code.declared(text)
    labelled = sprite_code.labelled(text)
    for entry in declared:
        if entry not in allowed:
            raise CodeError(
                f"{stem}.asm declares {entry}:, which a {kind} sprite cannot "
                f"run. It may declare {', '.join(allowed)}."
            )
    printed = [entry for entry in declared if entry not in labelled]
    if printed:
        raise CodeError(
            f"{stem}.asm declares {', '.join(printed)} with a print "
            f'directive ("print \\"MAIN\\", pc"), which only PIXI\'s own '
            f"patcher can read. Make it a label at the same position -- "
            f"{printed[0]}: -- which is what importing the sprite does."
        )
    if not declared:
        raise CodeError(
            f"{stem}.asm declares none of {', '.join(allowed)}, so nothing "
            f"would call it."
        )
    return tuple(entry for entry in allowed if entry in labelled)


def sprite_fragments(project: Project) -> tuple[str, str, str]:
    """The rows naming each sprite's routines, the properties each number
    carries, and the data reading the files.

    The rows grammar itself refuses a number another kind's table cannot
    hold or the game already dispatches
    (:func:`smw_tools.sprite_code.rows_fragment`); what is decided here is
    only what each file contributes. A ``.json`` with no ``.asm`` beside it
    is a properties-only sprite -- an acts-like reskin with no code of its
    own -- and is as real as any other.
    """
    rows: dict[str, dict[int, str]] = {}
    kinds: dict[str, dict[int, str]] = {}
    properties: list[str] = []
    data: list[str] = []
    for kind, folder in KIND_FOLDERS.items():
        numbers = (
            sprite_code.NORMAL_NUMBERS
            if kind == "normal"
            else (sprite_code.KIND_NUMBERS)
        )
        numbered: dict[int, str] = {}
        for stem, relative in _files(project, folder).items():
            number = _number(stem, numbers - 1, f"custom {kind} sprite")
            _one_spelling(numbered, number, stem, f"custom {kind} sprite")
            slug = _slug(kind, number)
            text = _text(project, relative)
            for entry in _entries(kind, stem, text):
                held = rows if kind == "normal" else kinds
                held.setdefault(entry if kind == "normal" else kind, {})[number] = (
                    f"{slug}_{entry}"
                )
            data.append(level_code.namespaced(slug, relative.as_posix()))
        if kind != "normal":
            continue
        for stem, relative in _metadata(project, folder).items():
            number = _number(stem, numbers - 1, f"custom {kind} sprite")
            slug = _slug(kind, number)
            try:
                meta = json.loads(_text(project, relative))
            except json.JSONDecodeError as error:
                raise CodeError(
                    f"{stem}.json does not parse as a sprite's properties: {error}"
                ) from None
            if not isinstance(meta, dict):
                raise CodeError(
                    f"{stem}.json does not hold a sprite's properties: the "
                    f"file is a JSON {type(meta).__name__}, not an object"
                )
            properties.append(f"; sprite ${number:02X}")
            try:
                properties.append(sprite_code.properties_defines(slug, meta))
            except sprite_code.SpriteCodeError as error:
                raise CodeError(f"{stem}.json: {error}") from None
            except (TypeError, ValueError) as error:
                raise CodeError(
                    f"{stem}.json does not hold a sprite's properties: {error}"
                ) from None
            properties.append(f"%SMW_CustomSpriteProperties(${number:02X}, {slug})\n")
    try:
        rows_text = sprite_code.rows_fragment(rows, kinds)
    except sprite_code.SpriteCodeError as error:
        raise CodeError(str(error)) from None
    return rows_text, "\n".join(properties), "".join(data)


def _metadata(project: Project, folder: Path) -> dict[str, Path]:
    """Every ``.json`` a project put beside its sprites, by stem."""
    held = project.overlay / project.base.name / folder
    if not held.is_dir():
        return {}
    return {
        found.stem: folder / found.name
        for found in sorted(held.glob("*.json"))
        if found.is_file()
    }


__all__ = ["Imported"]


def number_range(kind: str) -> tuple[int, int]:
    """The first and last number a custom sprite of ``kind`` may have: the
    whole byte for a normal sprite, and for every other kind the numbers
    past the game's own table, which a custom row may not shadow."""
    if kind not in KIND_FOLDERS:
        raise CodeError(
            f"{kind} is not a sprite kind; they are {', '.join(KIND_FOLDERS)}"
        )
    if kind == "normal":
        return 0, sprite_code.NORMAL_NUMBERS - 1
    return sprite_code.VANILLA_COUNTS[kind], sprite_code.KIND_NUMBERS - 1


def next_free_number(project: Project, kind: str) -> int:
    """The first number of ``kind``'s custom range no file in its folder
    claims -- what a created or nameless imported sprite lands under."""
    first, last = number_range(kind)
    taken = {
        held
        for held in (_hex(stem) for stem in _files(project, KIND_FOLDERS[kind]))
        if held is not None
    } | {
        held
        for held in (_hex(stem) for stem in _metadata(project, KIND_FOLDERS[kind]))
        if held is not None
    }
    for number in range(first, last + 1):
        if number not in taken:
            return number
    raise CodeError(f"every {kind} sprite number is already taken")


def template(kind: str, number: int) -> str:
    """A sprite of ``kind`` with nothing in it yet but the right shape:
    a header saying what it is and what it may declare, and the entry
    points as labels returning at once -- labels, because that is the one
    spelling the rows can name, where PIXI's own ``print "MAIN", pc`` is
    not."""
    if kind == "normal":
        head = (
            f"; Custom sprite ${number:02X}, run through Custom sprites (PIXI).\n"
            f"; It may declare init: and main:, and carriable:, kicked:, "
            f"carried:, mouth:\n"
            f"; and goal: for the carry statuses -- each a label returning with "
            f"RTL, X the\n"
            f"; sprite slot. The defines are PIXI's own: !sprite_status,x, "
            f"!extra_bits,x,\n"
            f"; %SubHorzPos() and the routines the project imported.\n"
        )
        entries = ("init", "main")
    else:
        head = (
            f"; Custom {kind} sprite ${number:02X}, run through Custom sprites "
            f"(PIXI).\n"
            f"; It declares main:, a label returning with RTL, run where the "
            f"game runs\n"
            f"; its own {kind} sprites, X the slot.\n"
        )
        entries = ("main",)
    return head + "".join(f"\n{entry}:\n\tRTL\n" for entry in entries)


def create_sprite(project: Project, kind: str, number: int) -> tuple[Path, ...]:
    """Write an empty sprite of ``kind`` under ``number``: the code from
    :func:`template` and, for a normal sprite, a properties sibling that
    acts like the unused sprite -- the defaults the properties dialog
    shows, written down so the row exists to open it on.

    Refused where the number is not the kind's to give, or where either
    file is already there: creating is how a sprite starts, not a way to
    start somebody's over.
    """
    first, last = number_range(kind)
    if not first <= number <= last:
        raise CodeError(
            f"A custom {kind} sprite is numbered ${first:02X} to ${last:02X}; "
            f"${number:02X} is not one."
        )
    if kind == "normal" and number == sprite_code.GOAL_TAPE:
        raise CodeError(
            f"${number:02X} is the goal tape, the one number the custom bit "
            f"cannot mark: Lunar Magic spends both of its extra bits on secret "
            f"exits."
        )
    folder = project.overlay / project.base.name / KIND_FOLDERS[kind]
    code = folder / f"{number:02X}.asm"
    meta = folder / f"{number:02X}.json"
    for held in (code, meta):
        if held.exists():
            raise CodeError(f"{KIND_FOLDERS[kind] / held.name} already exists.")
    folder.mkdir(parents=True, exist_ok=True)
    code.write_text(template(kind, number), encoding="utf-8", newline="\n")
    landed = [code.relative_to(project.overlay)]
    if kind == "normal":
        meta.write_text(
            json.dumps(
                {
                    "ActLike": sprite_code.DEFAULT_ACTS_LIKE,
                    sprite_code.EXTRA_BYTES_KEY: 0,
                },
                indent=1,
            )
            + "\n",
            encoding="utf-8",
            newline="\n",
        )
        landed.append(meta.relative_to(project.overlay))
    return tuple(landed)


def import_sprites(
    project: Project,
    kind: str,
    paths: Iterable[Path],
    symbols: SymbolTable | None,
) -> Imported:
    """Bring PIXI sprites into ``kind``'s folder, rewritten to assemble here.

    Three rewrites, each mechanical: ``print "MAIN", pc`` declarations
    become labels at the same position, ROM literals become this build's own
    labels (:func:`shiny_mushroom.patches.convert_import`, which leaves RAM
    and conditional-line addresses alone), and a ``.json`` sibling in that
    tool's own schema is copied beside the code unchanged -- the properties
    fragment reads it as it stands.

    The number is the file's own name where that is a hexadecimal the kind
    can hold, and the next free number in the folder where it is not --
    counting from the kind's first custom number, so an imported extended
    sprite cannot shadow one of the game's own.
    """
    from shiny_mushroom.patches import convert_import

    if kind not in KIND_FOLDERS:
        raise CodeError(
            f"{kind} is not a sprite kind; they are {', '.join(KIND_FOLDERS)}"
        )
    folder = project.overlay / project.base.name / KIND_FOLDERS[kind]
    landed: list[Path] = []
    notes: list[str] = []
    for path in paths:
        number = _import_number(project, kind, path.stem)
        text = sprite_code.prints_to_labels(path.read_text(encoding="latin-1"))
        # Refused here, by name, rather than by every build after: a file
        # declaring an entry point this dispatch does not build -- an
        # extended sprite's cape routine, say -- must not land at all.
        _entries(kind, path.stem, text)
        converted = convert_import(text, symbols)
        header = f"; Imported from {path.name}.\n" + "".join(
            f"; import: {note}\n" for note in converted.notes
        )
        folder.mkdir(parents=True, exist_ok=True)
        target = folder / f"{number:02X}.asm"
        target.write_text(header + converted.source, encoding="utf-8", newline="\n")
        landed.append(target.relative_to(project.overlay))
        notes.append(f"{path.name} -> {KIND_FOLDERS[kind] / target.name}")
        notes += [f"  {note}" for note in converted.notes]
        sibling = path.with_suffix(".json")
        if kind == "normal" and sibling.is_file():
            meta = folder / f"{number:02X}.json"
            meta.write_text(
                sibling.read_text(encoding="latin-1"), encoding="utf-8", newline="\n"
            )
            landed.append(meta.relative_to(project.overlay))
            notes.append(f"  {sibling.name} copied beside it")
    return Imported(tuple(landed), tuple(notes))


def import_routines(project: Project, paths: Iterable[Path]) -> Imported:
    """Bring PIXI's shared routines into ``code/pixi/routines/``.

    One rewrite: that tool assembles each routine inside a generated macro,
    so its labels are macro-scoped (``?main``, ``?.loop``); read as a bare
    file those are errors, and the ``?`` comes off
    (:func:`smw_tools.sprite_code.plain_labels`). The stored name is the
    macro a sprite calls it by -- PIXI spells it from every path part under
    its ``routines/`` folder, so ``routines/Spawn/Sprite.asm`` is
    ``%SpawnSprite()`` and lands as ``SpawnSprite.asm`` -- and a name that
    could not be a macro is refused before anything is written.
    """
    folder = project.overlay / project.base.name / ROUTINES
    landed: list[Path] = []
    notes: list[str] = []
    for path in paths:
        name = _routine_name(path)
        try:
            sprite_code.routines_fragment([name])  # refuses a bad name
        except sprite_code.SpriteCodeError as error:
            raise CodeError(str(error)) from None
        folder.mkdir(parents=True, exist_ok=True)
        target = folder / f"{name}.asm"
        target.write_text(
            sprite_code.plain_labels(path.read_text(encoding="latin-1")),
            encoding="utf-8",
            newline="\n",
        )
        landed.append(target.relative_to(project.overlay))
        notes.append(f"{path.name} -> {ROUTINES / target.name}")
    return Imported(tuple(landed), tuple(notes))


def _routine_name(path: Path) -> str:
    """The macro name PIXI gives a shared routine: every path part under
    the tool's ``routines/`` folder, concatenated in order. A file picked
    from anywhere else keeps its own stem."""
    gathered: list[str] = []
    for part in path.parent.parts[::-1][:3]:
        if part.lower() == "routines":
            return "".join(reversed(gathered)) + path.stem
        gathered.append(part)
    return path.stem


def _import_number(project: Project, kind: str, stem: str) -> int:
    """The number an imported file lands under.

    The file's own name where it already is one, because that is the
    convention the folders run on; otherwise the first free number of the
    kind's custom range, so a folder full of ``Thwomp.asm``-style names
    imports without a collision.
    """
    first, last = number_range(kind)
    found = _hex(stem)
    if found is not None and first <= found <= last:
        return found
    return next_free_number(project, kind)


def _hex(stem: str) -> int | None:
    try:
        return int(stem, 16)
    except ValueError:
        return None


def extra_byte_counts(project: Project) -> dict[int, int]:
    """How many extra bytes each custom number's records carry, from the
    metadata siblings -- the *next* build's stride. The built cartridge's
    own answer is its count table
    (:func:`shiny_mushroom.rom_patches.extra_byte_counts`), and the two
    differ for exactly as long as a build is owed.

    A sibling that does not parse contributes nothing here rather than
    raising: this is a report's reading, and the build is where the file's
    problem is refused with its name on it.
    """
    found: dict[int, int] = {}
    for stem, relative in _metadata(project, KIND_FOLDERS["normal"]).items():
        try:
            number = int(stem, 16)
            meta = json.loads(_text(project, relative))
            count = int(meta.get(sprite_code.EXTRA_BYTES_KEY, 0))
        except (ValueError, OSError, json.JSONDecodeError):
            continue
        if 0 < count <= sprite_code.EXTRA_BYTE_LIMIT and 0 <= number <= 0xFF:
            found[number] = count
    return found


def custom_placements(project: Project, number: int) -> tuple[int, ...]:
    """Every level whose sprite stream places custom sprite ``number``.

    What blocks an extra-byte count change: the streams were encoded under
    the count as it stands, and a cartridge reading them under another
    misparses every record behind the first custom one -- so the count may
    only move while no stream places the number. Walked with the current
    counts, which is what the streams were written under.
    """
    from shiny_mushroom.level import ANY_SHAPE
    from shiny_mushroom.sprites import parse_sprites

    counts = extra_byte_counts(project)
    levels: list[int] = []
    for level in range(0x200):
        streams = project.level_streams(level)
        if streams is None:
            continue
        _layer1, sprites = streams
        for record in parse_sprites(sprites, ANY_SHAPE, True, counts):
            if record.custom and record.number == number:
                levels.append(level)
                break
    return tuple(levels)


def custom_names(project: Project) -> dict[int, str]:
    """The project's custom normal sprites, each under the project's own
    name for it.

    The numbers are the files': ``code/sprites/normal/1A.asm`` and a
    properties-only ``1A.json`` both put ``$1A`` within a level's reach, so
    the two sets are read together. The name is the metadata sibling's --
    an editor-written ``Name``, or the ``Collection`` entry an imported
    PIXI file carries -- and the plain "Custom sprite $NN" where neither
    says anything, so one place decides what a number is called and the
    catalogue and the records cannot disagree about it.

    A stem that is not a number contributes nothing rather than raising,
    :func:`extra_byte_counts`'s rule: this is a report's reading, and the
    build is where a bad file is refused with its name on it.
    """
    folder = KIND_FOLDERS["normal"]
    metadata = _metadata(project, folder)
    found: dict[int, str] = {}
    for stem in sorted(set(_files(project, folder)) | set(metadata)):
        number = _hex(stem)
        if number is None or not 0 <= number < sprite_code.NORMAL_NUMBERS:
            continue
        named = _named(project, metadata.get(stem))
        found[number] = named or f"Custom sprite {hexnum(number)}"
    return found


def _named(project: Project, relative: Path | None) -> str:
    """What one metadata sibling calls its sprite, or nothing at all."""
    if relative is None:
        return ""
    try:
        meta = json.loads(_text(project, relative))
    except (OSError, CodeError, json.JSONDecodeError):
        return ""
    if not isinstance(meta, dict):
        return ""
    named = meta.get("Name")
    if isinstance(named, str) and named.strip():
        return named.strip()
    collection = meta.get("Collection")
    if isinstance(collection, list):
        for entry in collection:
            held = entry.get("Name") if isinstance(entry, dict) else None
            if isinstance(held, str) and held.strip():
                return held.strip()
    return ""


def carried(project: Project) -> tuple[Path, ...]:
    """Every sprite file the project holds -- code, metadata and library --
    which is what keeps the feature's switch down while there are any."""
    found: list[Path] = []
    for folder in (*KIND_FOLDERS.values(), LIBRARY):
        held = project.overlay / project.base.name / folder
        if not held.is_dir():
            continue
        found += sorted(
            path.relative_to(project.overlay)
            for path in held.iterdir()
            if path.is_file() and path.suffix in (".asm", ".json")
        )
    return tuple(found)


def library_fragment(project: Project) -> str:
    """The fragment assembling the sprite library, one file per line."""
    return sprite_code.lib_fragment(_files(project, LIBRARY))


def routines_fragment(project: Project) -> str:
    """The fragment giving each shared routine its macro and its body."""
    try:
        return sprite_code.routines_fragment(_files(project, ROUTINES))
    except sprite_code.SpriteCodeError as error:
        raise CodeError(str(error)) from None
