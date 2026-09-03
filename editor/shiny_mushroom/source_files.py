"""What a project's overlay holds, as rows a viewer can show -- and which of
those files a person may edit by hand.

The overlay is whole-file shadowing with no registry: what is in it is what the
build reads. That is what makes hand editing possible at all -- a copy of a bank
file dropped in shadows the disassembly's, assembles in its place, and deleting
it reverts -- and it is also why this module exists, because nothing else says
*which* of those files the editor writes for itself.

**Ownership is by file, and the emitter's grammar is the fence.** The editor
only ever writes whole files it owns: the ``.mwl`` containers, the palette and
world-map binaries, and the asm fragments under ``overworld/tables/`` that
:mod:`smw_tools.asm_regions` splits out of their banks. Everything else in the
source tree is nobody's but the person editing it. For the fragments the two
overlap, and the grammar decides: a hand edit that still parses is
indistinguishable from a structured save and is simply read back, and one that
does not is refused by the save path
(:class:`~shiny_mushroom.project.HandEditedRegion`) rather than overwritten.

So a region the editor cannot read is a *row with a problem*, not a broken
project -- as is a file that shadows nothing, which is what a typo'd path in
the overlay produces: it is copied into the merged tree, asar never reads it,
and the build succeeds having quietly assembled stock.

**The raw area is rows too, on its own terms.** A file under ``raw/`` shadows
nothing -- the build compresses it over the merged tree rather than copying it
-- so what it stands in for is the compressed file it compiles to, and what it
is priced against is the run of ROM that file's whole region shares: the row
shows the encoded size beside the shipped one and the region's total beside
its budget, the same numbers a save is refused on, so a file cannot promise a
save the build then refuses.
A tile editor's ``.pal`` beside a raw graphics file is not a row and not a
stray: :attr:`~shiny_mushroom.project.Project.changed`, the walk these rows
are read off, leaves it out (:func:`~shiny_mushroom.project_graphics.is_sidecar`).

**The ``code/`` folders hold asm a project writes rather than edits**, and
none of it shadows anything the disassembly ships: a level's, a game
mode's and the global routines, the custom sprites by kind with their
properties siblings, and the libraries and shared routines any of them may
call. Everywhere else in the overlay a file that shadows nothing is a
stray the build ignores; here the build reads it, through a fragment the
editor regenerates from whatever is in the folder. So a file appearing
there *is* a file assembled, which is what makes the dialog's scan on
being given the focus back worth running: a routine written in somebody's
own editor arrives as a row that says the build will take it.

Qt-free, like everything outside :mod:`shiny_mushroom.ui`: the dialog draws
these rows and decides nothing.

"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from shiny_mushroom import palettes
from shiny_mushroom.build import BuildError, asm_room, built_symbols, features_wanted
from shiny_mushroom.project import RAW_NAME, Project, ProjectError, scanning_once
from shiny_mushroom.project_overworld import (
    OVERWORLD_DEFINITIONS,
    OVERWORLD_EVENT_2X2,
    OVERWORLD_EVENT_6X6,
    OVERWORLD_LAYER1,
    OVERWORLD_SPRITES,
)
from smw_tools import asm_codec, asm_regions, graphics, level_code, packed, sprite_code
from smw_tools.bases import RomBase
from smw_tools.bases import base as rom_base
from smw_tools.features import CUSTOM_SPRITES, FEATURES, UBERASM_SUPPORT, FeatureError
from smw_tools.levels import LEVELS_DIR

#: What owns a row, which is the whole of what a viewer has to decide about it:
#: whether to offer it for hand editing, and which door reverts it.
SOURCE = "source"
REGION = "table"
LEVEL = "level"
PALETTE = "palettes"
WORLD_MAP = "world map"
#: The raw area's two kinds: a graphics file, which a tile editor works on in
#: place, and the compressed tilemaps and tables, whose editor is in the
#: application.
GRAPHICS = "graphics"
PACKED = "packed"
#: The project's own asm, which shadows nothing the disassembly ships: a
#: level's routines and the shared library they may call. The build reads
#: each through a fragment the editor regenerates, so unlike a file that
#: shadows nothing anywhere else in the overlay, these are not strays.
CODE = "code"
GAMEMODE_CODE = "gamemode code"
GLOBAL_CODE = "global code"
LIBRARY = "library"
MACRO_LIBRARY = "macro library"
#: The custom sprites' own four: a sprite's code, the properties sibling
#: beside it (PIXI's own JSON schema), the library sprites may call, and
#: the shared-routine macros the dialect gives them.
SPRITE = "custom sprite"
SPRITE_META = "sprite properties"
SPRITE_LIBRARY = "sprite library"
PIXI_ROUTINE = "shared routine"

#: How each kind is worth naming to somebody looking at the list.
KIND_NAMES = {
    SOURCE: "hand-edited",
    REGION: "editable table",
    LEVEL: "level",
    PALETTE: "palettes",
    WORLD_MAP: "world map",
    GRAPHICS: "graphics file",
    PACKED: "compressed data",
    CODE: "level code",
    GAMEMODE_CODE: "game mode code",
    GLOBAL_CODE: "global code",
    LIBRARY: "library",
    MACRO_LIBRARY: "macro library",
    SPRITE: "custom sprite",
    SPRITE_META: "sprite properties",
    SPRITE_LIBRARY: "sprite library",
    PIXI_ROUTINE: "shared routine",
}

#: The project's own asm folders, the kind a file in each is, the fragment
#: the build reads it through, the entry points a file there may declare --
#: none for the kinds whose labels are the caller's business -- and the
#: reader that finds them. Two grammars read entry points: the level code's
#: (labels only) and the custom sprites' (PIXI's ``print`` spelling too).
_CODE_FOLDERS = (
    (Path(level_code.LIB_DIR), LIBRARY, Path(level_code.LIB_FRAGMENT), (), None),
    (
        Path(level_code.MACROS_DIR),
        MACRO_LIBRARY,
        Path(level_code.MACROS_FRAGMENT),
        (),
        None,
    ),
    (
        Path(level_code.CODE_DIR),
        CODE,
        Path(level_code.DATA_FRAGMENT),
        level_code.ENTRIES,
        level_code.declared,
    ),
    (
        Path(level_code.GAMEMODE_DIR),
        GAMEMODE_CODE,
        Path(level_code.GAMEMODE_DIR) / "gamemode-code-data.asm",
        level_code.GAMEMODE_ENTRIES,
        level_code.declared,
    ),
    (
        Path(level_code.GLOBAL_DIR),
        GLOBAL_CODE,
        Path(level_code.GLOBAL_DIR) / "global-code-data.asm",
        ("init", "main"),
        level_code.declared,
    ),
    *(
        (
            Path(sprite_code.SPRITES_DIR) / kind,
            SPRITE,
            Path(sprite_code.DATA_FRAGMENT),
            sprite_code.NORMAL_ENTRIES
            if kind == "normal"
            else sprite_code.KIND_ENTRIES,
            sprite_code.declared,
        )
        for kind in sprite_code.KINDS
    ),
    (
        Path(sprite_code.LIB_DIR),
        SPRITE_LIBRARY,
        Path(sprite_code.LIB_FRAGMENT),
        (),
        None,
    ),
    (
        Path(sprite_code.ROUTINES_DIR),
        PIXI_ROUTINE,
        Path(sprite_code.ROUTINES_FRAGMENT),
        (),
        None,
    ),
)

#: The kinds :data:`_CODE_FOLDERS` names -- plus the sprite metadata
#: sibling, which no folder entry carries because it is not asm -- which is
#: what a row of one of them is tested for.
_CODE_KINDS = tuple({kind: None for _f, kind, _r, _e, _d in _CODE_FOLDERS}) + (
    SPRITE_META,
)

#: The two features' own kinds, which is what each tab of the dialog lists,
#: and the feature each kind's files are assembled by -- the one whose
#: switch being off makes every file of the kind a file no build reads.
UBERASM_KINDS = (CODE, GAMEMODE_CODE, GLOBAL_CODE, LIBRARY, MACRO_LIBRARY)
PIXI_KINDS = (SPRITE, SPRITE_META, SPRITE_LIBRARY, PIXI_ROUTINE)
FEATURE_OF = {
    **{kind: UBERASM_SUPPORT.id for kind in UBERASM_KINDS},
    **{kind: CUSTOM_SPRITES.id for kind in PIXI_KINDS},
}

#: Where a sprite's properties sibling lives and the fragment it is read
#: through: only a normal sprite has one, because only the normal tables
#: carry properties.
_SPRITE_META_FOLDER = Path(sprite_code.SPRITES_DIR) / "normal"

#: The world-map binaries the editor writes through
#: :meth:`~shiny_mushroom.project.Project.save_world_map`.
_WORLD_MAP_FILES = (
    OVERWORLD_LAYER1,
    OVERWORLD_DEFINITIONS,
    OVERWORLD_EVENT_6X6,
    OVERWORLD_EVENT_2X2,
    OVERWORLD_SPRITES,
)


@dataclass(frozen=True)
class SourceFileRow:
    """One file in the overlay: what it is, who owns it, and what is wrong."""

    #: The overlay's own spelling -- ``SMW/code/Bank00.asm`` -- which carries
    #: the name of the tree it belongs to and is the row's identity. What
    #: :meth:`~shiny_mushroom.project.Project.revert_source` takes, so a file
    #: that shadows nothing can still be removed.
    relative: Path

    #: The base-tree file it stands in for, or ``None`` for one that stands in
    #: for nothing -- see :attr:`stray`. For a raw resource, the compressed
    #: file it compiles to.
    shadows: Path | None

    #: Which of :data:`SOURCE` and its siblings owns it.
    kind: str

    #: What the editor makes of it, phrased for a person, or ``""`` when there
    #: is nothing to say. Carries the parse failure's own file-and-line text
    #: for a fragment that has left the grammar.
    note: str = ""

    #: Whether :attr:`note` is something to act on rather than merely true.
    problem: bool = False

    #: Whether the row is byte-for-byte the disassembly's own. Not a problem
    #: -- materializing a file to edit it produces exactly this, and so does
    #: editing one back to where it started -- but worth saying, because such
    #: a file still costs a build and changes nothing.
    unchanged: bool = False

    #: Whether the file is one the project adds rather than a copy of one the
    #: game ships -- a graphics file packed into the managed graphics banks,
    #: which the build compresses from scratch and which has no stock stream
    #: to go back to, so removing it deletes the file outright.
    added: bool = False

    @property
    def stray(self) -> bool:
        """Whether it shadows nothing the build would read."""
        return self.shadows is None

    @property
    def editable(self) -> bool:
        """Whether to offer this one for hand editing.

        The editor's own binaries are not text and have a proper editor in the
        application; a stray has no meaning to give an editor. A fragment is
        offered -- editing one within the grammar is supported, and being able
        to open one that has left it is how it gets fixed. So is a graphics
        file: its raw form is the planar layout every tile editor reads.

        Decided by :func:`_editable`, which :func:`stamps` asks straight off a
        classification rather than off a row.
        """
        return _editable(self.shadows, self.kind)

    @property
    def name(self) -> str:
        """The kind, named for a person."""
        return KIND_NAMES[self.kind]


def rows(project: Project) -> list[SourceFileRow]:
    """Every file the project's overlay holds, in overlay order.

    The ``raw/`` area is read on its own terms -- see :func:`_raw_row` --
    because it shadows nothing by design: the build compresses it over the
    tree rather than copying it, so the shadowing side's questions have the
    wrong answer there.

    **One reading of the overlay for the whole listing**
    (:func:`~shiny_mushroom.project.scanning_once`). Every row of an editable
    table is read and priced as a save would be, and pricing one fragment
    reads every other member of the run it shares -- so a project whose
    fragments share one run asks for the same handful of files dozens of
    times over. The block makes those one read each and holds the listing to
    a tree that cannot change while it is being listed.
    """
    with scanning_once():
        owners = _owners(project)
        priced = _rooms(project)
        wanted = features_wanted(project)
        usage: dict[str, tuple[int, int] | None] = {}
        return [
            _raw_row(project, relative, usage)
            if relative.parts[0] == RAW_NAME
            else _row(project, relative, owners, priced, wanted)
            for relative in project.changed
        ]


def feature_off(project: Project, feature_id: str) -> str:
    """What to say when ``feature_id``'s files are in the project and the
    next build would not have the feature -- ``""`` when it would.

    The next build's reading (:func:`~shiny_mushroom.build.features_wanted`)
    rather than the cartridge's: a switch thrown since the last build is
    already the answer to whether the files are worth writing.
    """
    if feature_id in features_wanted(project):
        return ""
    return _feature_off_note(feature_id)


def _feature_off_note(feature_id: str) -> str:
    return (
        f"only a build with {FEATURES[feature_id].name} assembles it -- "
        f"turn the feature on under Project > Features"
    )


def stamps(project: Project) -> dict[Path, tuple[int, int]]:
    """``(size, mtime_ns)`` for every hand-editable file in the overlay.

    What an external edit moves. **The cheap half of :func:`rows`**: the walk,
    one classification apiece (:func:`_classified`) and the ``stat`` the stamp
    itself is -- a stat or two a file over an overlay that holds what has been
    edited and nothing else. Nothing here reads a file's contents or parses a
    fragment, which is the whole of what the listing spends its time on.

    Classified through the same :func:`_classified` the rows are, so which
    files a person may edit is one decision rather than two that could come to
    disagree.

    The build's fingerprint is what actually decides whether asar runs again;
    this only exists so the window can *say* that something moved under it
    without walking eleven megabytes to find out.
    """
    found: dict[Path, tuple[int, int]] = {}
    with scanning_once():
        owners = _owners(project)
        for relative in project.changed:
            shadows, kind = _classified(project, relative, owners)
            if not _editable(shadows, kind):
                continue
            try:
                stat = (project.overlay / relative).stat()
            except OSError:
                continue
            found[relative] = (stat.st_size, stat.st_mtime_ns)
    return found


def overlay_stamps(project: Project) -> dict[Path, tuple[int, int]]:
    """``(size, mtime_ns)`` for every file :func:`rows` would list.

    The walk and a stat apiece, with nothing classified, read or parsed -- so
    a viewer can ask whether the list it is showing still holds without
    re-reading every fragment to find out.

    Wider than :func:`stamps`, which answers a different question: what the
    *build* has not taken in yet, and so classifies each file to count only
    the ones the editor does not write for itself.
    """
    found: dict[Path, tuple[int, int]] = {}
    for relative in project.changed:
        try:
            stat = (project.overlay / relative).stat()
        except OSError:
            continue
        found[relative] = (stat.st_size, stat.st_mtime_ns)
    return found


def carried_by_a_run(relative: Path) -> bool:
    """Whether a hand edit to this overlay file reaches a test run with no
    build in between.

    The raw area is the one part of the overlay a run *patches* rather than
    waits on: every load re-encodes the project's raw files into the image the
    emulator boots, in place or relocated
    (:func:`~shiny_mushroom.cart_patches.saved_graphics_patch`), so a repainted
    graphics file is on the canvas and in the run alike, whoever wrote it. Every
    other hand-editable file is assembler text, and only a build carries that.
    """
    return relative.parts[0] == RAW_NAME


def _editable(shadows: Path | None, kind: str) -> bool:
    """Whether a file of this shape is one to offer for hand editing.

    The rule itself, in one place: :attr:`SourceFileRow.editable` asks it of a
    finished row and :func:`stamps` of a classification, so what the dialog
    offers and what the window watches are the same set by construction.
    """
    return shadows is not None and kind in (SOURCE, REGION, GRAPHICS, *_CODE_KINDS)


def _classified(
    project: Project,
    relative: Path,
    owners: dict[Path, tuple[str, str | None]],
) -> tuple[Path | None, str]:
    """What one overlay path stands in for and what owns it.

    The cheap half of a row, and the whole of what :func:`_editable` turns on:
    registries the project has already read and a ``stat`` or two, with no
    file's contents read. A row's :attr:`~SourceFileRow.note` is the expensive
    half -- pricing a fragment's run, comparing a file against the one it
    shadows, encoding a raw file -- and none of it moves this answer.

    Both row builders take their ``shadows`` and ``kind`` from the same two
    classifications this dispatches to.
    """
    if relative.parts[0] == RAW_NAME:
        found = _raw_file(project, relative)
        return (None, SOURCE) if found is None else (found.shadows, found.kind)
    shadows, kind, _region_id = _source_file(project, relative, owners)
    return shadows, kind


def _base(project: Project) -> RomBase:
    """The base to read the project's shape through, degrading exactly as the
    window does when a recorded feature will not resolve.

    A project whose build claimed a feature this one has no declaration for is
    a state the editor supports -- it reads such a cartridge as a stock base
    and says so -- so listing its files must not be the one thing that raises.
    Nothing here depends on a feature's tables anyway: which files exist is the
    same either way, and a row's own reading is skipped where it is not.
    """
    try:
        return project.cartridge_base
    except FeatureError:
        return rom_base(project.base_id)


def _owners(project: Project) -> dict[Path, tuple[str, str | None]]:
    """Which files the editor writes for itself, by base-relative path, as
    ``(kind, region id)``.

    Built from the same declarations the save paths write through, so a file
    cannot be owned here and unowned there.
    """
    owned: dict[Path, tuple[str, str | None]] = {}
    for region_id, region in asm_regions.regions(_base(project)).items():
        for path in region.files:
            owned[path] = (REGION, region_id)
    for relative in palettes.FILES:
        owned[relative] = (PALETTE, None)
    for relative in _WORLD_MAP_FILES:
        owned[relative] = (WORLD_MAP, None)
    return owned


def _rooms(project: Project) -> dict[str, int] | None:
    """The run of ROM this project's own build gave each region's fragment, or
    ``None`` when there is no build to ask.

    A project that has never been built cannot price anything -- the room is
    read out of the symbol file that build wrote -- and that is an ordinary
    state, not a fault: it just means a row says nothing about room.
    """
    # Read once, not once a row: the file is ninety thousand lines and every
    # region would otherwise parse it again -- and remembered past this
    # listing, so the memory map and a feature switch share the reading.
    symbols = built_symbols(project)
    if symbols is None:
        return None
    priced: dict[str, int] = {}
    for region_id in asm_regions.regions(_base(project)):
        try:
            priced[region_id] = asm_room(project, region_id, symbols)
        except (BuildError, FeatureError, asm_codec.AsmRegionError, OSError):
            # A region this build placed nothing for prices nothing. Every
            # other row still has its room.
            continue
    return priced


def _source_file(
    project: Project,
    relative: Path,
    owners: dict[Path, tuple[str, str | None]],
) -> tuple[Path | None, str, str | None]:
    """The shadowing side's classification: the base-tree file one overlay
    entry stands in for, what owns it, and -- for an editable table -- which
    region's fragment it is a file of.

    A path lookup and the declarations, all of it already in hand: nothing
    here reads a file. ``None`` shadows is the typo'd overlay path, which
    nothing further is asked of.
    """
    shadows = project.shadowed(relative)
    if shadows is None:
        return (*_project_asm(project, relative), None)

    # The registries are keyed the way the game folder spells its own files,
    # so only an entry in that tree can match one -- an asset is nobody's but
    # the graphics editor's, and reaches the overlay through ``raw/`` anyway.
    kind, region_id = SOURCE, None
    if relative.parts[0] == project.base.name:
        inner = Path(*relative.parts[1:])
        kind, region_id = owners.get(inner, (SOURCE, None))
        if region_id is None:
            # A file no declaration lists but a region's shape claims -- an
            # added message of a grown set.
            for held_id, region in asm_regions.regions(_base(project)).items():
                if region.owns(inner):
                    kind, region_id = REGION, held_id
                    break
        if inner.is_relative_to(LEVELS_DIR) and inner.suffix == ".mwl":
            kind = LEVEL
    return shadows, kind, region_id


def _project_asm(project: Project, relative: Path) -> tuple[Path | None, str]:
    """A file the project wrote into one of its own asm folders, and the
    fragment the build reads it through -- or ``(None, SOURCE)`` for a path
    that really does shadow nothing.

    The one place a file that shadows nothing is still a file the build
    reads. What makes that true is the fragment: the editor regenerates it
    from whatever is in the folder, so a file appearing there is a file
    assembled, and saying "the build ignores it" would be a lie the moment
    somebody dropped one in.
    """
    if relative.parts[:1] != (project.base.name,):
        return None, SOURCE
    inner = Path(*relative.parts[1:])
    for folder, kind, fragment, _entries, _reader in _CODE_FOLDERS:
        if inner.parent == folder and inner.suffix == ".asm":
            return Path(project.base.name) / fragment, kind
    if inner.parent == _SPRITE_META_FOLDER and inner.suffix == ".json":
        return (
            Path(project.base.name) / sprite_code.PROPERTIES_FRAGMENT,
            SPRITE_META,
        )
    return None, SOURCE


def _row(
    project: Project,
    relative: Path,
    owners: dict[Path, tuple[str, str | None]],
    priced: dict[str, int] | None,
    wanted: tuple[str, ...],
) -> SourceFileRow:
    shadows, kind, region_id = _source_file(project, relative, owners)
    if kind in _CODE_KINDS:
        return _code_row(project, relative, shadows, kind, wanted)
    if shadows is None:
        return SourceFileRow(
            relative=relative,
            shadows=None,
            kind=kind,
            note="shadows no disassembly file, so the build ignores it",
            problem=True,
        )

    held = project.overlay / relative
    unchanged = _same(held, shadows)
    if kind == REGION and region_id is not None:
        note, problem = _region_note(project, region_id, held, priced)
    else:
        note, problem = "", False
    if not note and unchanged:
        note = "identical to the disassembly's own"
    return SourceFileRow(
        relative=relative,
        shadows=shadows,
        kind=kind,
        note=note,
        problem=problem,
        unchanged=unchanged,
    )


def _code_row(
    project: Project,
    relative: Path,
    fragment: Path | None,
    kind: str,
    wanted: tuple[str, ...],
) -> SourceFileRow:
    """One file of the project's own asm.

    Added rather than shadowing: there is no stock file behind it, so
    removing it deletes it outright, exactly as an added graphics file is
    removed. What is worth saying about one is whether the build will run
    any of it -- a level's code file that declares no entry point is
    assembled and never called, which is silent otherwise, and a file of a
    feature the next build does not have is assembled into nothing at all,
    which is said first because it makes every other note moot.
    """
    if FEATURE_OF[kind] not in wanted:
        return SourceFileRow(
            relative=relative,
            shadows=fragment,
            kind=kind,
            note=_feature_off_note(FEATURE_OF[kind]),
            problem=True,
            added=True,
        )
    note = ""
    try:
        text = (project.overlay / relative).read_text(
            encoding="utf-8", errors="replace"
        )
    except OSError:
        text = ""
    if kind == SPRITE_META:
        note = _meta_note(text)
    else:
        inner = Path(*relative.parts[1:])
        entries, reader = next(
            (held, held_reader)
            for folder, held_kind, _r, held, held_reader in _CODE_FOLDERS
            if held_kind == kind and folder == inner.parent
        )
        if entries and reader is not None:
            declared = reader(text)
            if not any(entry in entries for entry in declared):
                note = f"declares no {', '.join(entries)} label, so nothing calls it"
            elif kind == SPRITE and not any(
                entry in entries for entry in sprite_code.labelled(text)
            ):
                note = (
                    "declares its entry points with print directives, which "
                    "only PIXI's own patcher reads -- make each a label at "
                    "the same position"
                )
    return SourceFileRow(
        relative=relative,
        shadows=fragment,
        kind=kind,
        note=note,
        problem=bool(note),
        added=True,
    )


def _meta_note(text: str) -> str:
    """What to say about a sprite's properties sibling: whether it still
    parses as one. The vocabulary is PIXI's own JSON schema, and a key the
    mapping does not carry simply defaults -- so the only thing that can be
    wrong with one is not being a JSON object at all."""
    import json

    try:
        meta = json.loads(text)
    except json.JSONDecodeError as error:
        return f"does not parse as a sprite's properties: {error}"
    if not isinstance(meta, dict):
        return (
            f"does not hold a sprite's properties: the file is a JSON "
            f"{type(meta).__name__}, not an object"
        )
    return ""


def _region_note(
    project: Project,
    region_id: str,
    held: Path,
    priced: dict[str, int] | None,
) -> tuple[str, bool]:
    """What to say about an editable table: whether the editor can still read
    it, and whether what it holds still fits the run of ROM it is placed in.

    Read and priced exactly as a save would -- :meth:`Project.asm_rows` parses
    the overlay's own fragment, and the emit that follows is the save path's
    pricing step -- so a row cannot promise a save that then refuses.
    """
    try:
        model = project.asm_rows(region_id)
    except FeatureError:
        # The cartridge is being read as a stock base and the window has
        # already said why; a table's own reading has nothing to add to it.
        return "", False
    except asm_codec.AsmRegionError as error:
        return (
            f"hand-edited past what the editor can read, so it is left alone: {error}",
            True,
        )
    except OSError as error:
        return f"could not be read: {error}", True

    room = None if priced is None else priced.get(region_id)
    if room is None:
        return "", False
    base = _base(project)
    region = asm_regions.region_for(region_id, base)
    try:
        region.emit(model, room, base)
    except asm_codec.AsmRegionFull as error:
        return (
            f"{error.used:,} bytes in a run of {error.room:,} -- "
            f"{error.used - error.room:,} must come back out",
            True,
        )
    except asm_codec.AsmRegionError as error:
        return f"cannot be written back: {error}", True
    return "", False


@dataclass(frozen=True)
class _RawFile:
    """One path of the raw area before any of it is read: the resource it is
    the editable form of, the compressed file it stands in for, and what owns
    it."""

    #: The registry's entry for it, which is what the row is priced through,
    #: and the key it is filed under -- the overlay spelling without ``raw/``.
    resource: packed.Packed
    key: Path

    #: :data:`GRAPHICS` or :data:`PACKED`.
    kind: str

    #: The compressed file it stands in for -- its baseline, or for an added
    #: file the stream the build will write -- and ``None`` for one no build
    #: reads, which is a stray like any other.
    shadows: Path | None

    #: Where it compiles to, relative to its tree, and the shipped file it is
    #: measured against, which may not exist.
    compiled: Path
    baseline: Path

    #: Whether it is a graphics file of a set this target's build does not
    #: read -- carried along, and compiled into nothing this target assembles.
    wrong_set: bool


def _raw_file(project: Project, relative: Path) -> _RawFile | None:
    """The raw area's classification, and ``None`` for a path under ``raw/``
    the registry does not know -- a stray by the same rule
    :func:`smw_tools.packed.budget` prices by: not in the build, so the build
    ignores it.

    A registry lookup, made over one already read for the gather
    (:meth:`~shiny_mushroom.project_graphics.GraphicsFiles.resource_for`), and
    a ``stat`` for the baseline. What the file itself holds is the row's
    business, not this.
    """
    key = Path(*relative.parts[1:])
    try:
        resource = project.resource_for(key)
    except packed.PackedError:
        return None
    kind = GRAPHICS if resource.root == packed.ASSETS_ROOT else PACKED
    wrong_set = kind == GRAPHICS and resource.relative.parent.name != graphics.set_for(
        project.target_id
    )
    compiled = Path(resource.root) / resource.relative
    baseline = resource.baseline_path(project.base, project.assets_base)
    # An added file is measured against no shipped stream and stands in for
    # the compressed file it compiles to, which is what makes it a file of the
    # build's rather than a stray. Every other one stands in for its baseline,
    # and a baseline the build has not got makes it a stray -- a graphics file
    # of another set included, which this target compiles nothing from.
    stands_in = baseline if baseline.is_file() else None
    return _RawFile(
        resource=resource,
        key=key,
        kind=kind,
        shadows=compiled if resource.added and not wrong_set else stands_in,
        compiled=compiled,
        baseline=baseline,
        wrong_set=wrong_set,
    )


def _raw_row(
    project: Project,
    relative: Path,
    usage: dict[str, tuple[int, int] | None],
) -> SourceFileRow:
    """One file of the raw area: what it compiles to, and whether its region
    still fits the run of ROM the build has for it.

    Classified by :func:`_raw_file` and then priced exactly as a save is --
    the file through the encoder, its region through
    :meth:`~shiny_mushroom.project.Project.region_usage` -- so the row and the
    refusal cannot disagree. ``usage`` remembers each region's answer across
    one listing, since every file in a region shares it.
    """
    found = _raw_file(project, relative)
    if found is None:
        return SourceFileRow(
            relative=relative,
            shadows=None,
            kind=SOURCE,
            note="is no compressed file the build reads, so the build ignores it",
            problem=True,
        )
    resource, kind, compiled = found.resource, found.kind, found.compiled
    if found.wrong_set:
        held_set = resource.relative.parent.name
        return SourceFileRow(
            relative=relative,
            shadows=found.shadows,
            kind=kind,
            note=f"compiles to {compiled}, of the {held_set} set, which "
            f"the {project.target_id} build does not read",
            problem=True,
        )
    if resource.added:
        return _added_row(project, relative, resource, compiled)
    baseline = found.baseline
    if found.shadows is None:
        # No baseline: nothing ships in its place and nothing reads it.
        return SourceFileRow(
            relative=relative,
            shadows=None,
            kind=kind,
            note=f"compiles to {compiled}, which the build does not read, so "
            f"the build ignores it",
            problem=True,
        )
    try:
        raw = project.raw(found.key)
        shipped = baseline.read_bytes()
        encoded = resource.encode(raw, shipped)
    except (packed.PackedError, OSError) as error:
        return SourceFileRow(
            relative=relative,
            shadows=baseline,
            kind=kind,
            note=f"compiles to {compiled}, but could not be read: {error}",
            problem=True,
        )
    unchanged = encoded == shipped
    if resource.region not in usage:
        try:
            usage[resource.region] = project.region_usage(resource.region)
        except (packed.PackedError, OSError):
            usage[resource.region] = None
    priced = usage[resource.region]
    if unchanged:
        note = (
            f"compiles to {compiled}; identical to the shipped file decompressed, "
            f"so the build keeps the cartridge's own {len(shipped):,} bytes"
        )
        problem = False
    elif priced is not None and priced[0] > priced[1]:
        used, budget = priced
        note = (
            f"compiles to {compiled}, {len(encoded):,} bytes against "
            f"{len(shipped):,} shipped; its run needs {used:,} bytes and has "
            f"{budget:,} -- {used - budget:,} must come back out"
        )
        problem = True
    else:
        note = (
            f"compiles to {compiled}, {len(encoded):,} bytes against "
            f"{len(shipped):,} shipped"
        )
        if priced is not None:
            used, budget = priced
            note += f"; its run holds {used:,} of {budget:,}"
        problem = False
    return SourceFileRow(
        relative=relative,
        shadows=baseline,
        kind=kind,
        note=note,
        problem=problem,
        unchanged=unchanged,
    )


def _added_row(
    project: Project, relative: Path, resource: packed.Packed, compiled: Path
) -> SourceFileRow:
    """One graphics file the project adds: no shipped stream to be measured
    against, so the row says what it encodes to and that the managed
    graphics banks pack it -- or, on a project whose next build has no
    such banks, that nothing will. It stands in for the compressed file it
    compiles to, which is what makes it a file of the build's rather than a
    stray, and :attr:`SourceFileRow.added` says which kind it is."""
    key = Path(*relative.parts[1:])
    try:
        encoded = len(resource.encode(project.raw(key), None))
    except (packed.PackedError, ProjectError, OSError) as error:
        return SourceFileRow(
            relative=relative,
            shadows=compiled,
            kind=GRAPHICS,
            added=True,
            note=f"compiles to {compiled}, but could not be read: {error}",
            problem=True,
        )
    fmt = packed.format_for_size(resource.raw_size or 0)
    what = (
        f"an added {fmt.name.replace('PLANAR_', '').lower()} file"
        if fmt
        else "an added file"
    )
    if not project.graphics_managed:
        return SourceFileRow(
            relative=relative,
            shadows=compiled,
            kind=GRAPHICS,
            added=True,
            note=f"compiles to {compiled}, {what}, which only a build with "
            f"Growable graphics reads -- turn it on under Project > Features",
            problem=True,
        )
    return SourceFileRow(
        relative=relative,
        shadows=compiled,
        kind=GRAPHICS,
        added=True,
        note=f"compiles to {compiled}, {what} of {encoded:,} bytes, packed "
        f"into the graphics banks after the game's own files",
        problem=False,
    )


def _same(held: Path, baseline: Path) -> bool:
    """Whether two files hold the same bytes, size first."""
    try:
        if held.stat().st_size != baseline.stat().st_size:
            return False
        return held.read_bytes() == baseline.read_bytes()
    except OSError:
        return False
