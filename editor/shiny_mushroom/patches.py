"""User asm patches: asar sources stored with the project, assembled into its
cartridge.

A patch is a file. ``<project>/patches/<id>.asm`` holds the asar source and is
the patch's identity -- a file dropped in by hand is a patch like any other --
with an optional ``<id>.json`` sibling carrying a display name and description.
Which patches apply, and in what order, is the project's ``patches`` metadata:
``order`` is the stable apply-and-display order, ``enabled`` the subset that is
on, so toggling one never reorders the list.

**Applied by the build, never to the built file.** The disassembly's own hook
-- ``Custom/Asar_Patches_<GameID>.asm``, whose ``InsertIntegratedPatches``
macro the framework runs at the very end of the main pass -- is generated into
the project's merged tree with one ``incsrc`` per enabled patch, and the
``!Define_Global_ApplyAsarPatches`` switch is flipped in the tree's ROM map.
The end of the main pass is the one spot with both properties a patch wants:
every label of the game is already defined, so a patch says
``org SMW_LevelNames_Main`` rather than an address, and nothing assembles
after it, so what it writes is what the cartridge holds. Each patch is its own
file in the tree, so an assembler error names the patch and its line.

Nothing here touches ``smw/src/`` or the built ROM, and a project with no
enabled patches assembles exactly as if this module did not exist -- the
reconcile restores the stock hook and switch on every merge, and the build
only writes over them when there is something to apply.

**A patch may say what it changed about the cartridge**, as feature ids in its
metadata sibling -- ``"features": ["..."]``. That is the seam between a patch,
which is bytes the assembler places, and everything that *reads* the
cartridge: a patch which relocates a table or the code a capture traces has
made the editor's declarations wrong, and the id is what lets
:mod:`smw_tools.features` say how. Most patches change nothing the editor
reads and claim nothing.
"""

from __future__ import annotations

import re
from collections.abc import Iterable, Sequence
from dataclasses import dataclass
from json import JSONDecodeError, dumps, loads
from pathlib import Path

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.project import (
    NAME_PATTERN,
    Project,
    ProjectError,
    numbered_unique,
)
from smw_tools.symbols import SymbolTable, symbol_containing

#: The asar source's extension; the file's stem is the patch's id.
SOURCE_SUFFIX = ".asm"

#: The optional metadata sibling: ``{"name": ..., "description": ...}``.
META_SUFFIX = ".json"

#: What a patch id may look like: the project-name rule itself, for the same
#: reason -- it is a filename on every platform and a token in generated asm.
#: The same expression rather than a copy of it, so the two cannot drift.
ID_PATTERN = NAME_PATTERN

#: Directives that claim freespace. A patch using one needs room the stock
#: 512 KB cartridge does not have -- its gaps hold the shipped garbage bytes,
#: reinserted for byte-exactness -- so the build refuses the combination
#: rather than letting asar grow the image and fail the length check.
_FREESPACE = re.compile(r"\b(freecode|freedata|freespace)\b", re.IGNORECASE)


class PatchError(Exception):
    """A patch that cannot be stored or found."""


@dataclass(frozen=True)
class AsmPatch:
    """One asar patch the build assembles into the cartridge."""

    #: The filename stem, and the manifest's name for it.
    id: str

    #: What the person called it; the id when they called it nothing.
    name: str

    #: The asar source itself.
    source: str

    description: str = ""

    #: Which capabilities this patch adds, as ids into
    #: :data:`smw_tools.features.FEATURES` -- ``"features"`` in the metadata
    #: sibling.
    #:
    #: **What it moved, not what it does.** A patch that only writes bytes into
    #: tables the editor already knows provides nothing and needs no entry
    #: here; a patch that relocates a table, the code a capture traces or a
    #: RAM location has changed a fact everything downstream reads, and the id
    #: is how that fact reaches them -- see :mod:`smw_tools.features`.
    #:
    #: The ids are the *registry's*, not free text: a patch can claim only a
    #: capability this build has a declaration for, since the declaration is
    #: the half that says what the claim costs.
    provides: tuple[str, ...] = ()


@dataclass(frozen=True)
class UserPatch(AsmPatch):
    """A patch the person wrote, imported, or dropped into ``patches/``."""


def user_patches(project: Project) -> tuple[UserPatch, ...]:
    """Every patch in ``project``'s folder, in apply order.

    The manifest's order first, skipping entries whose file has gone; then
    anything in the folder the manifest has not met, alphabetically -- so a
    hand-dropped file appears without a registration step, at the end where
    it changes nothing that came before it.

    A name the manifest lists twice is one patch. The manifest is stored
    unvalidated (:attr:`~shiny_mushroom.project.Project.patch_state`) and this
    is what reconciles it against the files that exist -- and a patch loaded
    twice would be ``incsrc``\\ ed twice, which is an assembler error rather
    than a duplicate row.
    """
    order, _ = project.patch_state
    found = {
        path.stem: path
        for path in sorted(project.patches_dir.glob(f"*{SOURCE_SUFFIX}"))
        if ID_PATTERN.match(path.stem)
    }
    listed = list(dict.fromkeys(name for name in order if name in found))
    listed += [name for name in found if name not in order]
    return tuple(_load(project, name, found[name]) for name in listed)


def enabled_patches(project: Project) -> tuple[UserPatch, ...]:
    """The patches the next build applies, in apply order."""
    _, enabled = project.patch_state
    return tuple(patch for patch in user_patches(project) if patch.id in enabled)


def provided_features(patches: Iterable[AsmPatch]) -> tuple[str, ...]:
    """Every feature ``patches`` claim to add, in apply order, deduplicated.

    What the **next build** would produce when given the enabled set; what the
    cartridge on screen actually has is what its build recorded -- see
    :attr:`shiny_mushroom.project.Project.features`. The two differ while a
    build is owed, which the fingerprint already notices: turning a patch on
    rewrites the generated hook, so the project is out of date the moment a
    claim changes.
    """
    return tuple(
        dict.fromkeys(feature_id for patch in patches for feature_id in patch.provides)
    )


def _load(project: Project, patch_id: str, source_path: Path) -> UserPatch:
    try:
        source = source_path.read_text("utf-8")
    except OSError as error:
        raise PatchError(f"{source_path.name} cannot be read: {error}") from error
    meta: dict = {}
    meta_path = source_path.with_suffix(META_SUFFIX)
    try:
        held = loads(meta_path.read_text("utf-8"))
        if isinstance(held, dict):
            meta = held
    except (OSError, JSONDecodeError):
        # A missing or hand-mangled sibling costs the prose, not the patch.
        meta = {}
    return UserPatch(
        id=patch_id,
        name=str(meta.get("name") or patch_id),
        source=source,
        description=str(meta.get("description") or ""),
        provides=_provided(meta.get("features")),
    )


def _provided(held: object) -> tuple[str, ...]:
    """The ``features`` list of a metadata sibling, as ids.

    Read leniently, like the name and the description above it: the sibling is
    a hand-editable file, and a mangled one costs the claim rather than the
    patch. What the ids *mean* is checked where it matters -- an id no
    :mod:`smw_tools.features` declaration answers for is refused when the
    cartridge is read through it, with the feature named, rather than here
    where the answer would be "this patch will not load".
    """
    if not isinstance(held, list):
        return ()
    return tuple(dict.fromkeys(str(entry) for entry in held if str(entry)))


def add_patch(
    project: Project,
    name: str,
    source: str,
    description: str = "",
    enabled: bool = False,
    provides: Iterable[str] = (),
) -> UserPatch:
    """Store a new patch and register it at the end of the order.

    The id is the name, spelled as a filename -- lowercased, punctuation to
    hyphens -- and made unique against what is already there, so adding never
    overwrites. ``enabled`` is explicit because the two ways in disagree: a
    catalogue add is on, an import is off until the person looks at it.

    ``provides`` is what the patch changes about the cartridge, as feature ids
    -- see :attr:`AsmPatch.provides`. An imported file says nothing, which is
    the honest answer for a patch nobody has read: a claim is a statement that
    the editor should read the ROM differently, and only whoever knows what
    the patch does can make it.
    """
    patch_id = _unique_id(project, _slug(name))
    project.patches_dir.mkdir(parents=True, exist_ok=True)
    _source_path(project, patch_id).write_text(source, "utf-8")
    claimed = _provided(list(provides))
    meta: dict[str, object] = {"name": name}
    if description:
        meta["description"] = description
    if claimed:
        meta["features"] = list(claimed)
    _source_path(project, patch_id).with_suffix(META_SUFFIX).write_text(
        dumps(meta, indent=2) + "\n", "utf-8"
    )
    order, on = project.patch_state
    project.set_patch_state(
        [*order, patch_id], [*on, patch_id] if enabled else list(on)
    )
    return UserPatch(
        id=patch_id,
        name=name,
        source=source,
        description=description,
        provides=claimed,
    )


def remove_patch(project: Project, patch_id: str) -> None:
    """Delete the patch's files and drop it from the manifest."""
    _source_path(project, patch_id).unlink(missing_ok=True)
    _source_path(project, patch_id).with_suffix(META_SUFFIX).unlink(missing_ok=True)
    order, enabled = project.patch_state
    project.set_patch_state(
        [name for name in order if name != patch_id],
        [name for name in enabled if name != patch_id],
    )


def set_enabled(project: Project, patch_id: str, enabled: bool) -> None:
    """Turn one patch on or off, without moving anything."""
    if not _source_path(project, patch_id).is_file():
        raise PatchError(f"{patch_id} is not one of this project's patches")
    order, on = project.patch_state
    now = [name for name in on if name != patch_id]
    if enabled:
        now.append(patch_id)
    project.set_patch_state(list(order), now)


def reorder_patches(project: Project, order: Sequence[str]) -> None:
    """Set the apply order. Names not in ``order`` keep their place after it."""
    held, enabled = project.patch_state
    kept = [name for name in dict.fromkeys(order)]
    kept += [name for name in held if name not in kept]
    project.set_patch_state(kept, list(enabled))


def uses_freespace(source: str) -> bool:
    """Whether ``source`` claims freespace -- room only an expanded cart has."""
    lines = (line.partition(";")[0] for line in source.split("\n"))
    return any(_FREESPACE.search(line) for line in lines)


def hook_text(game_id: str, patches: Iterable[AsmPatch]) -> str:
    """The generated ``Asar_Patches_<GameID>.asm``: one include per patch.

    The patches ride ``InsertIntegratedPatches`` -- the end of the main pass,
    where every label is defined and nothing assembles afterwards. The
    post-assembly macro is left empty: that pass re-includes only the ROM map,
    so a patch there would resolve no label of the game's.
    """
    lines = [
        "; Written by the editor -- the project's enabled patches, in order.",
        f"macro {game_id}_InsertIntegratedPatches()",
    ]
    for patch in patches:
        lines.append(f'incsrc "Patches/User/{patch.id}{SOURCE_SUFFIX}"')
    lines += [
        "endmacro",
        "",
        f"macro {game_id}_ApplyPatchesPostAssembly()",
        "endmacro",
    ]
    return "\n".join(lines) + "\n"


@dataclass(frozen=True)
class Imported:
    """A community patch, rewritten for this build, and what the rewrite did."""

    source: str
    notes: tuple[str, ...]


#: A whole-line mapper directive. The framework has already set the memory
#: mapping by the time the hook runs, and a patch re-declaring one mid-assembly
#: would remap everything after itself.
_MAPPER = re.compile(
    r"^\s*(lorom|hirom|exlorom|exhirom|sa1rom|fullsa1rom|norom|fastrom|slowrom)\s*$",
    re.IGNORECASE,
)

#: ``autoclean`` un-claims the freespace a previous application left in the
#: ROM being patched. Every build here assembles from pristine sources, so
#: there is never a previous application to clean.
_AUTOCLEAN = re.compile(r"^(\s*)autoclean\s+", re.IGNORECASE)

#: A line the assembler evaluates while it is reading, rather than emitting:
#: a conditional, an assertion, a loop bound. A label is not static there --
#: asar refuses one with ``Elabel_in_conditional`` -- so an address on such a
#: line stays the number it was. The idiom this exists for is the SA-1 test
#: every second community patch opens with, ``if read1($00FFD5) == $23``:
#: rewritten to a label it does not assemble at all.
_STATIC_ONLY = re.compile(
    r"^\s*(?:(?:if|elseif|while|assert)\b|![A-Za-z0-9_]+\s*#=)", re.IGNORECASE
)

#: A 24-bit address literal in operand position -- six hex digits, not an
#: immediate (``#$``) and not part of a longer literal.
_LONG_ADDRESS = re.compile(r"(?<![#$\w])\$([0-9A-Fa-f]{6})\b")

#: A token spelled like one of the disassembly's own labels, for telling a
#: symbolic patch's typo from its intent.
_LABEL_TOKEN = re.compile(r"\b(?:SMW|GLOBAL)_\w+\b")


def convert_import(source: str, symbols: SymbolTable | None) -> Imported:
    """Rewrite a community patch in this disassembly's own terms.

    Two dialects arrive here and both leave assemblable. A patch written
    against raw vanilla addresses -- ``org $05D796``, ``JSL $05E000`` -- has
    each 24-bit ROM literal rewritten as the label at or below it plus an
    offset, so it keeps meaning the same thing in a build where that label
    moves. A patch already written against labels passes through, its
    ``SMW_``/``GLOBAL_`` tokens checked against the symbol file so a typo is
    a note at import rather than an assembler error a build later.

    Mapper directives are dropped -- the framework has set the mapping, and a
    ``lorom`` mid-assembly would remap everything after itself -- and
    ``autoclean`` is dropped because every build assembles from pristine
    sources. An address on a line the assembler evaluates as it reads --
    ``if``, ``elseif``, ``while``, ``assert`` -- is left alone whatever it
    points at, because a label is not static there and asar refuses one.

    Each leaves a note, as does everything left alone: a RAM literal
    (RAM does not move under a patch), an address below any label of its
    bank, and a ``freecode``/``freedata`` claim, which needs a ROM size above
    stock. With no ``symbols`` in hand nothing is rewritten, and the one note
    says so.
    """
    if symbols is None:
        return Imported(
            source=source,
            notes=("Not converted to labels -- build the project first.",),
        )
    notes: list[str] = []
    counts = {"converted": 0, "ram": 0, "static": 0}

    def symbolize(match: re.Match[str], line_number: int) -> str:
        address = int(match.group(1), 16)
        if (address >> 16) in (0x7E, 0x7F):
            counts["ram"] += 1
            return match.group(0)
        found = symbol_containing(symbols, address)
        if found is None or (found.addr >> 16) != (address >> 16):
            notes.append(
                f"line {line_number}: no label covers {hexnum(address, 6)}; left as is"
            )
            return match.group(0)
        counts["converted"] += 1
        offset = address - found.addr
        return found.name if not offset else f"{found.name}+{hexnum(offset, 0)}"

    out: list[str] = []
    for number, raw in enumerate(source.split("\n"), start=1):
        code, marker, comment = raw.partition(";")
        if _MAPPER.match(code):
            notes.append(
                f"line {number}: dropped {code.strip()} -- the build's "
                f"mapping is already set"
            )
            continue
        cleaned, took = _AUTOCLEAN.subn(r"\1", code)
        if took:
            notes.append(
                f"line {number}: dropped autoclean -- every build starts pristine"
            )
        if _STATIC_ONLY.match(cleaned):
            counts["static"] += len(_LONG_ADDRESS.findall(cleaned))
            converted = cleaned
        else:
            converted = _LONG_ADDRESS.sub(
                lambda match, at=number: symbolize(match, at), cleaned
            )
        unknown = [
            token
            for token in _LABEL_TOKEN.findall(converted)
            if token not in symbols.by_name
        ]
        for token in unknown:
            notes.append(f"line {number}: {token} is not in this build's symbols")
        out.append(converted + marker + comment)
    text = "\n".join(out)
    if counts["converted"]:
        notes.insert(0, f"{counts['converted']} address(es) rewritten as labels.")
    if counts["ram"]:
        notes.append(
            f"{counts['ram']} RAM address(es) left as is -- RAM does not "
            f"move under a patch."
        )
    if counts["static"]:
        notes.append(
            f"{counts['static']} address(es) left as is on a conditional -- "
            f"the assembler wants a number there, not a label."
        )
    if uses_freespace(text):
        notes.append("Claims freespace, so it needs a ROM Size above stock.")
    return Imported(source=text, notes=tuple(notes))


def _source_path(project: Project, patch_id: str) -> Path:
    if not ID_PATTERN.match(patch_id):
        raise PatchError(f"{patch_id!r} is not a patch id")
    return project.patches_dir / f"{patch_id}{SOURCE_SUFFIX}"


def _slug(name: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")[:64]
    if not slug or not ID_PATTERN.match(slug):
        raise PatchError(f"{name!r} does not spell a patch id")
    return slug


def _unique_id(project: Project, slug: str) -> str:
    try:
        return numbered_unique(slug, lambda name: _source_path(project, name).exists())
    except ProjectError as error:
        # The loop is shared with project names; the exception this module's
        # callers catch is not.
        raise PatchError(str(error)) from error
