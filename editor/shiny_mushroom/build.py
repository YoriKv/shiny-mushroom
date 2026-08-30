"""Assembling a project: the disassembly with its overlay laid over the top.

:mod:`shiny_mushroom.project` stores an edit as a file in a sparse ``overlay/``.
This is what turns that into a ROM, and the whole of it is one awkward fact:

**asar resolves ``incbin`` and ``incsrc`` from the working directory, not from
the include search path.** The build already reaches the extracted graphics and
music through ``--include``, because nothing in the source tree refers to them by
a path that exists -- but a level *does*. ``levels/105.mwl`` is found beside the
bank that includes it, and a copy of it on the include path is never looked at,
because the one in the tree was found first.

So an overlay cannot shadow the disassembly in place. The tree has to be
**merged** -- the checkout's files, then the project's over them -- and asar run
against that. Files are hard-linked where the filesystem allows it and copied
where it does not; the tree is kept between builds and reconciled rather than
rebuilt, and what has to be copied is copied several files at a time, because
mirroring is bound by per-file latency rather than by bandwidth.

The merged tree lives inside the project, not in the checkout. ``smw/src`` is the
reference the repository's byte-exactness gate is run over, and an editor that
wrote so much as a build intermediate into it would be the thing that broke the
gate.

**The measure of this module is that it changes nothing it is not asked to.** A
project with an empty overlay assembles to the pinned hashes for the release --
the same ones ``uv run smw check`` verifies -- because it runs the same passes,
over the same assembler, against the same files. There is one build path, not
the project's and the repository's.
"""

from __future__ import annotations

import hashlib
import json
import os
import shutil
from collections.abc import Callable, Iterable, Mapping
from concurrent.futures import ThreadPoolExecutor
from contextlib import suppress
from dataclasses import dataclass
from pathlib import Path

from shiny_mushroom import patches as asm_patches
from shiny_mushroom.project import (
    ASSETS_NAME,
    BUILD_STATE,
    OUTPUT_DIR,
    RAW_NAME,
    Project,
    forget_readings,
)
from smw_tools import asm_codec, asm_regions, features, graphics_memory, rom_tables
from smw_tools.asm_room import Run, run_for
from smw_tools.bases import DEFAULT_BASE, RomBase
from smw_tools.bases import base as rom_base
from smw_tools.build import build_rom, symbols_path
from smw_tools.level_graphics import FRAGMENT as LEVEL_GRAPHICS_FRAGMENT
from smw_tools.level_graphics import fragment_from_containers
from smw_tools.paths import GLOBAL_DIR
from smw_tools.rom_sizes import STOCK
from smw_tools.symbols import SymbolTable, load_symbols, stale_sources

#: Where a project's merged tree goes, inside the project folder. The output
#: directory and the state file below it are the *project's* names -- its folder,
#: and it reads the record itself to know what its cartridge is (see
#: :attr:`~shiny_mushroom.project.Project.features`) -- and are re-exported here
#: because this is the module that writes them.
TREE_DIR = "build-tree"

#: How many files the merge walks and copies at once.
#:
#: Mirroring is bound by per-file latency and not by bandwidth -- ten megabytes
#: across the WSL boundary is a thousand round trips of a couple of milliseconds
#: each, and the disk is idle for nearly all of it. Four in flight is where the
#: measured curve has flattened (fourteen seconds to a little over one); the
#: threads are asleep in ``read`` and ``write``, so the GIL is not what bounds
#: this.
WORKERS = 4


class BuildError(Exception):
    """The project could not be assembled.

    :attr:`log_path` is where the assembler's whole output went, for a failure
    that came out of running it -- see :class:`~smw_tools.asar.AsarError`,
    which is where it is written. ``None`` for everything else that stops a
    build, which has no compiler output to show.
    """

    def __init__(self, message: str, log_path: Path | None = None) -> None:
        super().__init__(message)
        self.log_path = log_path


@dataclass(frozen=True)
class Merged:
    """The tree an assembly runs over, and what went into it."""

    #: The merged tree, holding the game folder, its ``Global`` sibling and the
    #: assets.
    tree: Path

    #: The merged assets root inside it, which is what asar's include path is
    #: pointed at.
    assets: Path

    #: A digest of every file the build would read. Two merges that produce the
    #: same one would produce the same ROM, which is what lets the build be
    #: skipped -- see :func:`build`.
    fingerprint: str


@dataclass(frozen=True)
class Build:
    """What an assembly produced."""

    rom: Path
    warnings: tuple[str, ...] = ()

    #: Whether asar was actually run. ``False`` means the ROM that was already
    #: there is the one this would have produced -- see :func:`build`.
    rebuilt: bool = True


def rom_path(project: Project) -> Path:
    """Where ``project``'s own cartridge is, built or not.

    **This is the ROM the editor edits.** Not the reference cartridge -- that is
    only ever an asset source, read once and then not needed again -- but the
    one this project assembles from the disassembly, the extracted assets and
    its own overlay. A new project's is byte-identical to the reference cart,
    because its overlay is empty; from the first save they diverge, and what is
    on the canvas is what the project actually produces.
    """
    return (project.root / OUTPUT_DIR / project.target.output_name).resolve()


def build(
    project: Project,
    on_progress: Callable[[str], None] | None = None,
    force: bool = False,
) -> Build:
    """Assemble ``project`` into a ROM, and say where it landed.

    The tree is merged first, then asar is run over it exactly as
    ``uv run smw build`` runs it over the checkout -- same passes, same
    defines, same assembler. A project with an empty overlay therefore assembles
    to the same bytes the checkout does, which is the property worth having: the
    editor's build path is the project's build path, not a second one that might
    disagree with it.

    **Skipped when nothing has changed.** The merge already has to fingerprint
    both trees to know what to copy, so asking whether asar has anything to do is
    free once it has run -- and the answer is usually no. That is what makes
    opening a project a fraction of a second rather than a few: the ROM from
    last time is the ROM this would produce. ``force`` runs it anyway, for a
    build whose inputs are unchanged but whose output is suspect.
    """
    # Absolute, both of them. asar is run with the merged tree as its working
    # directory, so a relative output path would be created relative to *that* --
    # and the include arguments that reach the extracted assets are worked out as
    # a path from the same directory, which only comes out right when it is a
    # real one.
    _patches_fit(project)
    merged = merge(project, on_progress=on_progress)
    tree = merged.tree.resolve()
    rom = rom_path(project)
    # The symbol file is a build product like the ROM: a project built before
    # symbols were emitted has a current fingerprint and no symbols, and the
    # fix is the same as for a missing ROM -- assemble again.
    if (
        not force
        and _current(project, merged.fingerprint)
        and rom.is_file()
        and symbol_file(project).is_file()
    ):
        if on_progress:
            on_progress("The ROM is already up to date.")
        return Build(rom=rom, rebuilt=False)
    try:
        result = build_rom(
            project.target_id,
            base=rom_base(project.base_id),
            output_dir=rom.parent,
            symbols="wla",
            on_progress=on_progress,
            game_dir=tree / project.base.name,
            assets_dir=merged.assets.resolve(),
            rom_size=project.rom_size,
            defines=defines_wanted(project),
        )
    except Exception as error:  # noqa: BLE001 - asar reports everything as one
        # The log travels with it where the assembler left one: the message is
        # the first few error lines, and the file is the rest of what it said.
        raise BuildError(str(error), getattr(error, "log_path", None)) from error
    # Before the state is recorded: a build whose tables cannot be resolved
    # must not be remembered as current, or the next attempt would skip the
    # assembly and this check with it.
    _verify_roles(project)
    _record(project, merged.fingerprint)
    return Build(rom=result.output_path, warnings=tuple(result.warnings))


def symbol_file(project: Project) -> Path:
    """Where ``project``'s build writes its symbol file, built or not.

    One file for any base. On a patched one the main pass writes the source's
    labels -- still the right addresses for pricing an asm region, since the
    patch edits bytes in place and never moves one -- and the patch pass
    merges its own labels in after them.
    """
    return symbols_path(
        rom_base(project.base_id), project.target, rom_path(project).parent
    )


def features_wanted(project: Project) -> tuple[str, ...]:
    """Which features the **next build** of ``project`` would produce: its
    base's, the ones it has switched on itself, and what every enabled patch
    claims to add.

    What the cartridge on disk *has* is :attr:`Project.features` -- this
    build's record of it. The two part company only while a build is owed,
    which :func:`needs_build` is true from the moment of: a toggled patch
    rewrites the generated hook and so the tree, and a switched feature is
    part of :func:`_current`'s question in its own right, since a define
    reaches the assembler rather than the tree.
    """
    return tuple(
        dict.fromkeys(
            rom_base(project.base_id).features
            + project.feature_state
            + asm_patches.provided_features(asm_patches.enabled_patches(project))
        )
    )


def defines_wanted(project: Project) -> tuple[tuple[str, str], ...]:
    """The asar defines ``project``'s build switches its features on with.

    Only the ones it asked for itself: a feature the base is built with is
    already in the source it assembles, and one a patch provides is written
    into the cartridge afterwards. Neither has a switch to throw, so throwing
    one would be a define nothing reads.

    Plus the one define that is a project setting rather than a feature's:
    how many graphics banks the managed graphics reserve
    (:func:`smw_tools.graphics_memory.bank_count_define`), handed over
    whenever the next build has the feature -- however it arrives -- since
    the count is the project's and the build reads it wherever the switch is.
    """
    base = rom_base(project.base_id)
    chosen = [
        feature_id
        for feature_id in project.feature_state
        if feature_id not in base.features
    ]
    try:
        defines = features.build_defines(chosen, base)
        banks = graphics_banks_wanted(project)
        if banks is not None:
            defines += (graphics_memory.bank_count_define(banks),)
        return defines
    except (features.FeatureError, graphics_memory.GraphicsMemoryError) as error:
        raise BuildError(str(error)) from error


def graphics_banks_wanted(project: Project) -> int | None:
    """How many graphics banks the **next build** reserves, or ``None`` for
    a build without the managed graphics: what :func:`_current` compares and
    :func:`_record` writes, since the count reaches the assembler as a
    define and moves bytes without moving a file."""
    if graphics_memory.FEATURE not in features_wanted(project):
        return None
    return project.graphics_banks


def asm_room(
    project: Project,
    region_id: str,
    symbols: SymbolTable | None = None,
    base: RomBase | None = None,
) -> int:
    """How many bytes ``region_id``'s fragment may occupy in ``project``.

    Read from the project's own build's symbol file -- the record of where
    *this* build placed the fragment and what it placed after it -- rather than
    from any literal. The file is written by every build (and its absence makes
    :func:`build` assemble again), so a project that is open has one; a caller
    without it has skipped the build, which is a defect worth hearing about.

    One number for the fragment rather than one per table: the tables inside it
    move each other, so only the total is a fact. Where the base pools several
    fragments into one run, what is left of it after the *others* is this
    fragment's -- and the others are counted at **this project's** rows, not the
    disassembly's, because a project that grew one of them has that much less to
    give this one.

    One fragment at a time, so the others are counted at what is *saved*. A
    window editing two members of one run at once needs
    :func:`asm_shared_rooms` instead, which prices them together; and for a
    save ask :func:`asm_runs`, since only the run knows whether the set of
    fragments being written fits.

    ``symbols`` is that build's symbol file where the caller already holds it.
    A report pricing every region -- the memory map, the source files list --
    reads ninety thousand lines once that way rather than once a row.

    ``base`` is the cartridge to read the fragment's run for, and is the
    project's own unless the caller is pricing another: a feature switch asks
    what the cartridge it is *going to* gives a fragment, read off the build
    it has, which is where the pooled runs are bounded either way.
    """
    return asm_shared_rooms(project, (region_id,), symbols, base)[0].room


@dataclass(frozen=True)
class SharedRoom:
    """One run of ROM, and the regions of it something is editing together.

    What a window holding several members of one run prices against. The two
    string tables are the case: a base that pools them gives them one run, so
    neither has a size of its own to be measured against and an edit to one is
    room the other no longer has. Priced apart, both bars read green over a
    document that will not fit -- and, worse, one reads red over a document
    that would, because the bytes the other just gave back are not in it.
    """

    #: The regions priced against the run together, in the order asked for.
    regions: tuple[str, ...]

    #: The bytes the run has for all of them: its size, less what it reserves
    #: and less every member that is *not* here, counted at the project's
    #: saved rows.
    room: int

    def spare(self, used: Mapping[str, int]) -> int:
        """What the run has left with :attr:`regions` at ``used`` bytes --
        negative by how much they overflow it. ``used`` is bytes per region
        id, as a document holds them now rather than as it was last saved."""
        return self.room - sum(used.get(region, 0) for region in self.regions)


def asm_shared_rooms(
    project: Project,
    region_ids: Iterable[str],
    symbols: SymbolTable | None = None,
    base: RomBase | None = None,
) -> tuple[SharedRoom, ...]:
    """``region_ids`` grouped by the run they share, and what each run holds.

    One :class:`SharedRoom` per run, in the order the regions were asked for;
    a region the base pools with none of the others gets one of its own, which
    is the whole of what :func:`asm_room` answers. Every member of a run that
    is *not* among ``region_ids`` is counted at this project's saved rows, for
    the reason :func:`asm_room` gives -- the caller holds the rest, unsaved,
    and prices them itself through :meth:`SharedRoom.spare`.

    ``symbols`` and ``base`` are :func:`asm_room`'s.
    """
    if base is None:
        base = project.cartridge_base
    if symbols is None:
        symbols = _symbols(project)
    wanted = tuple(region_ids)
    out: list[SharedRoom] = []
    grouped: set[str] = set()
    for region_id in wanted:
        if region_id in grouped:
            continue
        region = asm_regions.region_for(region_id, base)
        run = run_for(region, symbols, base)
        mine = tuple(one for one in wanted if one in run.members)
        grouped.update(mine)
        others = {
            member: asm_regions.region_for(member, base).fits(
                project.asm_rows(member), None
            )
            for member in run.members
            if member not in mine
        }
        out.append(SharedRoom(regions=mine, room=run.spare(others)))
    return tuple(out)


def asm_runs(project: Project, only: Iterable[str] | None = None) -> dict[str, Run]:
    """The run each of ``project``'s regions has to fit in, and who shares it.

    What a save is priced against. One number per *fragment* is not enough
    where a base pools several of them into one run: each may fit on its own
    and not together, and only the run knows that.

    Read from the project's own build's symbol file, like everything else here.
    ``only`` narrows the answer to those region ids -- a save of one surface
    asks about the regions it writes, and is not refused for a label some
    other fragment's run would need.
    """
    base = project.cartridge_base
    symbols = _symbols(project)
    wanted = None if only is None else set(only)
    return {
        region.id: run_for(region, symbols, base)
        for region in asm_regions.regions(base).values()
        if wanted is None or region.id in wanted
    }


def world_map_room(
    project: Project,
    models: Mapping[str, object],
    runs: Mapping[str, Run],
    region_id: str,
) -> int:
    """What ``region_id``'s run of ROM has to spare with ``models``' rows in
    place -- negative by how much it would overflow.

    What the world map mode asks before it adds a row: ``models`` is the
    would-be document's tables by region id
    (:func:`shiny_mushroom.project_overworld.world_region_models`), ``runs`` the
    project's build's runs (:func:`asm_runs`), and the answer is the run's
    :meth:`~smw_tools.Run.spare` over every member -- a member
    the document does not carry counted at the project's own rows, which is
    what :meth:`Project.save_world_map` will count it at.
    """
    base = project.cartridge_base
    run = runs[region_id]
    used: dict[str, int] = {}
    for member in run.members:
        model = models.get(member)
        if model is None:
            model = project.asm_rows(member)
        used[member] = asm_regions.region_for(member, base).fits(model, None)
    return run.spare(used)


#: The last symbol file parsed, by its path and the stamp it was parsed at.
#:
#: One entry, because the window has one project open and a report reads its
#: symbols several times over.
_SYMBOLS: dict[Path, tuple[tuple[int, int], SymbolTable]] = {}


def _symbols(project: Project) -> SymbolTable:
    """``project``'s own build's symbol file, parsed.

    **Remembered against the file's own stamp**, and that is the whole of the
    invalidation rule: size and modification time, the same trade
    :func:`_fingerprint` and the reconcile make, so a symbol file replaced by
    anything at all -- this build, another process, a hand copy -- is read
    again. Nothing here rests on who wrote it.

    Worth remembering because the file is ninety thousand lines and a fifth
    of a second to parse, while the ``stat`` that checks it is three
    milliseconds; and worth checking for exactly that reason, which is the
    opposite of the trade a fragment makes
    (:func:`smw_tools.asm_room.tree_text`), where the ``stat`` is most of the
    read. Every report that prices a fragment asks for this -- the Source
    Files listing, the memory map, a feature switch -- and each of them asked
    more than once.

    Nothing outside may write into the table it hands back; every reader here
    only looks labels up in it.
    """
    path = symbol_file(project)
    try:
        found = path.stat()
    except OSError as error:
        raise BuildError(f"{path} is missing -- build the project first") from error
    stamp = (found.st_size, found.st_mtime_ns)
    held = _SYMBOLS.get(path)
    if held is None or held[0] != stamp:
        held = _SYMBOLS[path] = (stamp, load_symbols(path))
    return held[1]


def built_symbols(project: Project) -> SymbolTable | None:
    """``project``'s build's symbols, or ``None`` where there are none to read.

    :func:`_symbols` for a caller that is writing a *report* rather than
    pricing a save: a project that has never been built, or whose symbol file
    will not parse, is an ordinary state there and the half of the report that
    needs no symbols is still worth showing.
    """
    try:
        return _symbols(project)
    except (BuildError, OSError, ValueError):
        return None


def role_addresses(project: Project) -> dict[str, int] | None:
    """Every :mod:`~smw_tools.rom_tables` role, where ``project``'s own build
    put it -- or ``None`` when the project has no symbol file to ask.

    Resolved from the symbol file rather than read from the declared literals,
    because the literals describe a cartridge nobody edited and this one is not
    necessarily it: a table that grew pushed the ones after it, or a patch
    relocated one, and either way the assembler is the record of where they
    ended up. **This is the primary answer**, not a correction to the
    declarations -- see :func:`_verify_roles`.

    ``None`` means the caller reads through the declarations, which is exactly
    as right as it was before the project was built -- and :func:`build` writes
    a symbol file every time, so an open project answers with the real thing.
    """
    if not symbol_file(project).is_file():
        return None
    try:
        return rom_tables.resolved(project.cartridge_base.tables, _symbols(project))
    except rom_tables.RomTableError as error:
        raise BuildError(str(error)) from error
    except features.FeatureError as error:
        raise BuildError(str(error)) from error


def role_counts(project: Project) -> dict[str, int] | None:
    """How many entries each growable table holds on ``project``'s own build,
    by role -- or ``None`` when the project has no symbol file to ask.

    The count of a table whose scan bound is the table's own length
    (:attr:`smw_tools.asm_regions.FixedTables.growable`) is declared nowhere:
    a save that grew it wrote more rows and the next assemble scanned them.
    So it is read the way :func:`role_addresses` reads a moved table's
    address -- off the distance between the build's own labels
    (:func:`smw_tools.asm_regions.measured_counts`) -- and handed to the same
    places: :meth:`~shiny_mushroom.addresses.Addresses.for_base`, so the
    capture reads every row the cartridge holds, and
    :meth:`~shiny_mushroom.overworld.MapShape.of`, so the document is checked
    against what it was built as.

    Only the growable regions' roles are answered; every other table's count
    is the format's, which the registry already declares.
    """
    if not symbol_file(project).is_file():
        return None
    base = project.cartridge_base
    symbols = _symbols(project)
    counts: dict[str, int] = {}
    try:
        for region in asm_regions.regions(base).values():
            if region.growable:
                counts.update(asm_regions.measured_counts(region, symbols, base))
    except asm_codec.AsmRegionError as error:
        raise BuildError(str(error)) from error
    return counts


def _verify_roles(project: Project) -> None:
    """Refuse a build whose tables cannot be resolved. Not one that moved them.

    **A table that moved is read where it moved to.** Every read of one goes
    through this build's own symbol file -- :func:`role_addresses` hands the
    answers to :meth:`~shiny_mushroom.addresses.Addresses.for_base`, and both the
    window and the emulator worker are built that way -- so the assembler's
    arithmetic is what the editor reads, not a literal written down beside it.
    That is the point of compiling from source: a table that grows pushes the
    ones after it, and their addresses follow. Refusing that would be refusing
    the feature.

    A declared address in :mod:`smw_tools.rom_tables` is the answer for a
    cartridge with **no build behind it** -- one opened by hand, or a project
    before its first assembly. It is not a claim about every build, and a
    project whose tables have drifted from it is not thereby wrong.

    What is still a defect is a role this build has no label for at all.
    Nothing can resolve it, the declaration is the only answer left, and a
    declaration for a table that is not there resolves, reads plausible bytes,
    and renders wrong three subsystems away. :func:`~smw_tools.rom_tables.resolved`
    is what says so, by name.
    """
    base = features.applied(
        rom_base(project.base_id), features_wanted(project), project.rom_size_id
    )
    try:
        rom_tables.resolved(base.tables, _symbols(project))
    except rom_tables.RomTableError as error:
        raise BuildError(str(error)) from error


def needs_build(project: Project) -> bool:
    """Whether :func:`build` would do any real work.

    **It answers by doing the merge**, which is everything a build does short
    of running asar: the tree is reconciled against the checkout, the overlay
    laid over it, the raw resources compiled and the patch hook written. There
    is no cheaper honest answer -- the question *is* whether the fingerprint of
    that tree matches what the last build recorded -- and the work is not
    wasted, since a build that follows starts from the tree this left behind.

    Under a second against the far longer assemble it saves, which is what
    makes it worth asking before offering to build.
    """
    if not rom_path(project).is_file() or not symbol_file(project).is_file():
        return True
    return not _current(project, merge(project).fingerprint)


def stale_disassembly(project: Project) -> list[str]:
    """The disassembly files edited since ``project``'s cartridge was built,
    as paths relative to the source root it assembles.

    **A symbol file describes one assemble and nothing else.** Every address,
    every measured table count and every pool bound the editor reads comes out
    of it, and one written before the sources moved does not look wrong: it
    parses, resolves the names it does hold, and answers with the placements
    the tree had then. A label the disassembly has since renamed is simply
    absent, and whatever asked for it fails naming a label nobody here has
    typed -- see :func:`asm_runs`, which prices a save against exactly those.

    Modification times against the symbol file's, which is the reading
    :func:`smw_tools.symbols.stale_sources` already makes for the
    disassembly's own tools. The root is the project's own, not the module's
    idea of where the checkout is, for the same reason :func:`merge` takes it
    from the project: a project pointed at a fixture tree is asked about that
    tree.

    Empty for a project with no symbol file at all -- that is missing rather
    than stale, which :func:`needs_build` is the question for.
    """
    return stale_sources(symbol_file(project), root=project.base.parent)


def _state_file(project: Project) -> Path:
    return project.root / OUTPUT_DIR / BUILD_STATE


def _state(project: Project) -> dict:
    """What the last build recorded, or nothing at all.

    Nothing is not an error: a project built before a field existed, or not
    built at all, answers the same way -- with whatever each reader's own
    fallback is. This is the record of the *cartridge*, so a missing entry is
    always "the stock answer", never "unknown".
    """
    try:
        held = json.loads(_state_file(project).read_text("utf-8"))
    except (OSError, ValueError):
        return {}
    return held if isinstance(held, dict) else {}


def _current(project: Project, fingerprint: str) -> bool:
    """Whether the ROM on disk was built from exactly these inputs.

    The base is part of the question and not only the target: two bases can name
    a target the same thing, and a ROM built from one is not the ROM the other
    would produce.

    So is the cartridge size, and it is the one input that is not a file: the
    fingerprint is a digest of the tree, and resizing does not touch the tree.
    Without it, switching size would leave the ROM from before and report itself
    up to date.

    So are the features, for that same reason: a switched one reaches the
    assembler as a define, which moves bytes without moving a file. A feature
    a *patch* provides is in the tree and would be caught anyway, but the
    question is asked of the whole set rather than of the part that is not --
    one list is the honest description of what the cartridge would be.
    """
    state = _state(project)
    return bool(
        state
        and state.get("base", DEFAULT_BASE) == project.base_id
        and state.get("version") == project.target_id
        and state.get("rom_size", STOCK) == project.rom_size_id
        and _recorded_features(state) == features_wanted(project)
        and state.get("graphics_banks") == graphics_banks_wanted(project)
        and state.get("fingerprint") == fingerprint
    )


def _recorded_features(state: dict) -> tuple[str, ...]:
    """What a build state says its cartridge has, tolerantly -- the same
    reading :attr:`shiny_mushroom.project.Project.features` makes of it."""
    held = state.get("features")
    if not isinstance(held, list):
        return ()
    return tuple(dict.fromkeys(str(entry) for entry in held))


def _record(project: Project, fingerprint: str) -> None:
    # The features go in beside the base: they are as much what the cartridge
    # *is* as the base is, and the only record of it -- a built ROM does not
    # say what was patched into it, and a switched one is a define that left
    # no file behind at all. Which is why `_current` asks about them.
    state = {
        "base": project.base_id,
        "version": project.target_id,
        "rom_size": project.rom_size_id,
        "features": list(features_wanted(project)),
        "graphics_banks": graphics_banks_wanted(project),
        "fingerprint": fingerprint,
    }
    _state_file(project).write_text(json.dumps(state, indent=2) + "\n", "utf-8")
    # Not a write into the project folder proper, so the write count that
    # invalidates what a project remembers does not move for it -- and this
    # is the file `Project.features` reads.
    forget_readings()


def merge(
    project: Project,
    on_progress: Callable[[str], None] | None = None,
) -> Merged:
    """Materialise the tree to assemble, and say what went into it.

    Both halves of the source go in, because the framework's entry point is
    reached from the game folder as ``../Global/AssembleFile.asm`` and resolves
    its own siblings from there -- a merged ``SMW`` beside the checkout's
    ``Global`` would be two trees pretending to be one.

    **The assets go in too**, and the same way. They live outside the source tree
    and are reached through asar's include path rather than by ``incbin``\\ ing a
    path that exists, so they could in principle have been left where they are --
    but then a project could overlay a level and not a graphics file, which is an
    arbitrary line for the editor to draw. Merged, the include path points at the
    project's own set and anything it has replaced is simply what the build reads.

    **Kept between builds and reconciled, not rebuilt.** Mirroring eleven
    megabytes is nearly free when the two ends share a filesystem and can be
    hard-linked, and costs a real copy when they cannot -- which is the ordinary
    case here, since a project lives in the user's data directory and the
    checkout is wherever it was cloned. On WSL that is routinely ext4 against a
    mounted Windows drive, and no link can span the two.

    So the tree is reconciled against the checkout every time: a file is copied
    only when it is missing or has changed, and anything in the tree that is no
    longer in the source or the overlay is deleted. Deleting is the half that
    earns it -- without it, taking a level back out of the overlay would leave
    the edited container in the tree and every later build would assemble it.
    """
    tree = project.root / TREE_DIR
    if on_progress:
        on_progress("Merging the project over the disassembly...")
    stamps: dict[str, dict[Path, tuple[int, int]]] = {}
    # Taken from the project rather than from the module's own idea of where the
    # disassembly is, so a project pointed at a fixture tree merges that one --
    # which is what lets this be tested without mirroring eleven megabytes.
    for source in (project.base, project.base.parent / GLOBAL_DIR.name):
        stamps[source.name] = _reconcile(source, tree / source.name)
    stamps[ASSETS_NAME] = _reconcile(project.assets_base, tree / ASSETS_NAME)
    # The overlay last and over everything, because that is what "laid over"
    # means -- and its own contents are part of the fingerprint, so a save is a
    # reason to rebuild even though the disassembly has not moved.
    overlaid = _apply(project, tree)
    _compile_raw(project, tree)
    _derive_level_graphics(project, tree)
    _derive_code(project, tree)
    # After the reconcile put the stock hook and switch back: the patches are
    # compiled into the tree the way the raw resources are, and toggling one
    # is a reason to rebuild even though no tree file moved -- which is why
    # what was written comes back as part of the fingerprint.
    applied = _apply_patches(project, tree)
    return Merged(
        tree=tree,
        assets=tree / ASSETS_NAME,
        fingerprint=_fingerprint(stamps, overlaid, applied),
    )


def _compile_raw(project: Project, tree: Path) -> None:
    """Compress the overlay's raw resources over the merged tree's baselines.

    The one part of the overlay that is compiled rather than copied. Graphics,
    the Layer 2 background tilemaps and the overworld's Layer 2 tables all reach
    the build compressed, and the form worth *keeping* is the decompressed one
    -- so the project holds raw bytes and this turns them back into what the
    `incbin` reads. :mod:`smw_tools.packed` is the registry of which files those
    are and which codec each uses; see
    :data:`~shiny_mushroom.project.RAW_NAME`.

    **It runs after the reconciliation and after the overlay**, which is what
    makes it idempotent: the reconcile has just put the baseline back, so every
    build compresses from the same starting point rather than from the last
    build's output.

    Byte-exactness survives this. `Packed.encode` hands back the baseline
    untouched whenever the raw form still decodes to it, so a project that has
    edited nothing -- and one that has edited something back to where it started
    -- writes the cartridge's own bytes and assembles to the pinned hashes.

    A graphics file the project adds has no baseline in the tree -- the
    reconcile has just taken last build's stream out, since no source holds
    it -- so it is encoded from scratch to `assets/GFX/<set>/GFXnn.lz2`,
    where the added-files fragment inserts it
    (:func:`smw_tools.graphics_memory.asset_relative`).
    """
    known = project.packed_resources()
    for relative in project.raw_edits():
        resource = known[relative]
        raw = (project.overlay / RAW_NAME / relative).read_bytes()
        destination = tree / resource.root / resource.relative
        baseline = destination.read_bytes() if destination.is_file() else None
        compiled = resource.encode(raw, baseline)
        destination.parent.mkdir(parents=True, exist_ok=True)
        # The reconcile may have left a hard link to the checkout's own file
        # here, and writing through it would write into the checkout.
        destination.unlink(missing_ok=True)
        destination.write_bytes(compiled)


def _derive_level_graphics(project: Project, tree: Path) -> None:
    """Write the per-level graphics fragment the containers imply into the
    merged tree, over whatever the checkout or the overlay put there.

    The rows live in the level containers -- each ``.mwl``'s ExGFX words
    (:attr:`~shiny_mushroom.mwl.Container.graphics_row`) -- and the fragment
    ``Config/LevelGraphics.asm`` reads them through is derived from them
    here, on every build, the way :func:`_compile_raw` compiles the raws:
    after the reconcile and the overlay, so the containers read are the ones
    the build assembles. Nothing has to be kept in step, and a stale copy in
    an overlay never reaches the assembler. The containers are already in
    the fingerprint, so a row saved is a reason to rebuild.

    With no level naming a file the fragment is the checkout's own -- a
    comment and no line -- put back where the overlay had laid one over it.
    The levels are resolved through the project rather than the tree, since
    the tree's banks do not define the containers a project adds.
    """
    game = tree / project.base.name
    files = {
        level: game / where.layer1.relative_to(project.base)
        for level, where in project.level_map().items()
    }
    text = fragment_from_containers(game, project.target.romid, files)
    destination = game / LEVEL_GRAPHICS_FRAGMENT
    shipped = project.base / LEVEL_GRAPHICS_FRAGMENT
    # Unlinked first either way: the reconcile may have left a hard link to
    # the checkout's own file here, and writing through it would write into
    # the checkout -- and a stale copy the overlay laid over it must go.
    destination.unlink(missing_ok=True)
    if text is None:
        if shipped.is_file():
            _link_or_copy(str(shipped), str(destination))
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(text, encoding="utf-8", newline="\n")


def _derive_code(project: Project, tree: Path) -> None:
    """Write the fragments the project's own asm is read through into the
    merged tree, over whatever the checkout or the overlay put there.

    The same shape as :func:`_derive_level_graphics` and for the same
    reason: what a project wrote is in its folders, and the fragments that
    name it are derived from them on every build rather than kept in step.
    A file appearing in one of those folders is a file the next build
    assembles, and a stale fragment in an overlay never reaches the
    assembler.

    A folder with nothing in it derives the empty fragment, which is what
    the checkout ships -- so a project with no code of its own assembles
    exactly the cartridge the disassembly does.

    The files themselves are copied by :func:`_apply` like any other overlay
    entry; only the fragments naming them are written here.
    """
    from shiny_mushroom import project_code
    from smw_tools import level_code

    game = tree / project.base.name
    derived = {
        project_code.LEVEL_ROWS: None,
        project_code.LEVEL_DATA: None,
        project_code.GAMEMODE_ROWS: None,
        project_code.GAMEMODE_DATA: None,
        project_code.GLOBAL_ROWS: None,
        project_code.GLOBAL_DATA: None,
        project_code.LIBRARY_ROWS: None,
        project_code.MACROS_ROWS: None,
    }
    # What a project's own asm cannot be is a build failure with a sentence
    # in it, not a traceback: the file is in the person's hands and the
    # reason is about the file, so it reaches them the way an assembler
    # error does.
    try:
        rows, data = project_code.level_fragments(project)
        derived[project_code.LEVEL_ROWS] = rows
        derived[project_code.LEVEL_DATA] = data
        rows, data = project_code.gamemode_fragments(project)
        derived[project_code.GAMEMODE_ROWS] = rows
        derived[project_code.GAMEMODE_DATA] = data
        rows, data = project_code.global_fragments(project)
        derived[project_code.GLOBAL_ROWS] = rows
        derived[project_code.GLOBAL_DATA] = data
        derived[project_code.LIBRARY_ROWS] = project_code.library_fragment(project)
        derived[project_code.MACROS_ROWS] = project_code.macros_fragment(project)
    except (project_code.CodeError, level_code.LevelCodeError) as why:
        raise BuildError(str(why)) from None

    for relative, text in derived.items():
        destination = game / relative
        shipped = project.base / relative
        # Unlinked first: the reconcile may have left a hard link to the
        # checkout's own file here, and writing through it would write into
        # the checkout -- and a stale copy the overlay laid over it must go.
        destination.unlink(missing_ok=True)
        destination.parent.mkdir(parents=True, exist_ok=True)
        # The shipped file's prose is kept in front of what is derived, so a
        # reader who opens the merged tree finds the fragment explaining
        # itself rather than a bare list of macro calls.
        prose = shipped.read_text(encoding="utf-8") if shipped.is_file() else ""
        destination.write_text(prose + text, encoding="utf-8", newline="\n")


def _fingerprint(
    stamps: dict[str, dict[Path, tuple[int, int]]],
    overlaid: dict[Path, tuple[int, int]],
    patches: str = "",
) -> str:
    """A stable digest of everything the build reads.

    Size and modification time rather than contents, which is the same trade the
    reconciliation makes and for the same reason: hashing eleven megabytes to
    decide whether to spend half a minute assembling it is most of the cost of
    assembling it. ``patches`` is the one content-hashed part: the sources are
    small, and their being applied at all is metadata no file's stamp carries.
    """
    digest = hashlib.sha256()
    for name, found in sorted(stamps.items()):
        for relative, (size, mtime) in sorted(found.items()):
            digest.update(f"{name}/{relative.as_posix()}:{size}:{mtime}\n".encode())
    for relative, (size, mtime) in sorted(overlaid.items()):
        digest.update(f"overlay/{relative.as_posix()}:{size}:{mtime}\n".encode())
    digest.update(f"patches:{patches}\n".encode())
    return digest.hexdigest()


def _reconcile(source: Path, destination: Path) -> dict[Path, tuple[int, int]]:
    """Bring ``destination`` into line with ``source``, moving as little as
    possible, and report what the source held.

    Compared on size and modification time rather than on contents: reading
    eleven megabytes to decide whether to write it costs most of what writing it
    would, and the checkout is a git working tree whose files change by being
    rewritten rather than in place. The stamps are handed back because the build
    wants exactly the same measurement to decide whether it has anything to do.

    Copying runs :data:`WORKERS` files at a time. Each one is a round trip that
    the thread spends asleep, so they overlap almost perfectly and the first
    merge of a project -- the only one that copies everything -- is the
    difference between a quarter of a minute and a second or two.
    """
    destination.mkdir(parents=True, exist_ok=True)
    have = _stamps(destination)
    want = _stamps(source)
    stale = [
        relative for relative, stamp in want.items() if have.get(relative) != stamp
    ]
    # Directories first and in one pass: mkdir is itself a round trip, and the
    # copies would otherwise repeat it once per file in the same folder.
    for parent in {(destination / relative).parent for relative in stale}:
        parent.mkdir(parents=True, exist_ok=True)

    def copy(relative: Path) -> None:
        target = destination / relative
        target.unlink(missing_ok=True)
        _link_or_copy(str(source / relative), str(target))

    _spread(copy, stale)
    for relative in have.keys() - want.keys():
        gone = destination / relative
        gone.unlink(missing_ok=True)
        # And the directory it was the last thing in, up as far as it empties.
        for parent in gone.parents:
            if parent == destination:
                break
            with suppress(OSError):
                parent.rmdir()
    return want


def _stamps(root: Path) -> dict[Path, tuple[int, int]]:
    """Every file under ``root``, as its relative path and ``(size, mtime)``.

    Walked with :func:`os.scandir` rather than :meth:`Path.rglob`, which is not
    a style preference: scandir carries each entry's kind and stat from the
    directory read it already did, and asking eleven megabytes' worth of paths
    for their own ``stat()`` afterwards is three times the wall clock on a
    filesystem mounted across the WSL boundary -- which is where this project's
    checkout usually is.

    A directory at a time is still a round trip, so the tree is read a level at
    a time with :data:`WORKERS` of them in flight. This is the measurement
    :func:`needs_build` makes, so it is paid on every launch whether or not
    anything is assembled afterwards.
    """
    found: dict[Path, tuple[int, int]] = {}
    if not root.is_dir():
        return found

    def scan(directory: Path) -> tuple[list[Path], list[tuple[Path, tuple[int, int]]]]:
        directories: list[Path] = []
        files: list[tuple[Path, tuple[int, int]]] = []
        with os.scandir(directory) as entries:
            for entry in entries:
                if entry.is_dir(follow_symlinks=False):
                    directories.append(Path(entry.path))
                    continue
                stat = entry.stat()
                path = Path(entry.path).relative_to(root)
                files.append((path, (stat.st_size, stat.st_mtime_ns)))
        return directories, files

    pending = [root]
    while pending:
        level, pending = pending, []
        for directories, files in _spread(scan, level):
            pending += directories
            found.update(files)
    return found


def _spread(work: Callable, over: Iterable) -> list:
    """Run ``work`` over ``over``, :data:`WORKERS` at a time, in order.

    A pool per call rather than one shared between them: these are filesystem
    round trips and the threads are idle between merges, so keeping four alive
    for the life of the editor would buy nothing. The results come back in the
    order they went in, which is what lets a caller that cares about ordering --
    the fingerprint, say -- stay indifferent to how many ran at once.
    """
    items = list(over)
    if len(items) < 2:
        return [work(item) for item in items]
    with ThreadPoolExecutor(min(WORKERS, len(items))) as pool:
        return list(pool.map(work, items))


def _link_or_copy(source: str, destination: str) -> None:
    try:
        os.link(source, destination)
    except OSError:
        shutil.copy2(source, destination)


def _apply_patches(project: Project, tree: Path) -> str:
    """Compile the enabled patches into the merged tree, and say which.

    Three writes, all inside the tree and none of them when no patch is on:
    each enabled patch's source under ``Custom/Patches/User/``, the generated
    hook over ``Custom/Asar_Patches_<GameID>.asm``, and the
    ``!Define_Global_ApplyAsarPatches`` switch flipped in the target's ROM
    map. The reconcile undoes all three on the next merge -- the hook and the
    map by restoring the checkout's copies, the patch files by deleting what
    the source does not hold -- which is what keeps a project that turned its
    patches off assembling byte-exact again.

    The returned token digests the applied set -- ids, order and contents --
    for the fingerprint: enabling, reordering or editing a patch must be a
    reason to rebuild, and none of those moves a file the stamps cover.
    """
    enabled = asm_patches.enabled_patches(project)
    if not enabled:
        return ""
    base = rom_base(project.base_id)
    game = tree / project.base.name
    user_dir = game / "Custom" / "Patches" / "User"
    user_dir.mkdir(parents=True, exist_ok=True)
    for patch in enabled:
        source = user_dir / f"{patch.id}{asm_patches.SOURCE_SUFFIX}"
        # Unlinked first, everywhere below: the reconcile may have left a hard
        # link to the checkout's own file here, and writing through it would
        # write into the checkout.
        source.unlink(missing_ok=True)
        source.write_text(patch.source, "utf-8")
    hook = game / "Custom" / f"Asar_Patches_{base.game_id}.asm"
    hook.unlink(missing_ok=True)
    hook.write_text(asm_patches.hook_text(base.game_id, enabled), "utf-8")
    rom_map = game / "RomMap" / f"ROM_Map_{project.target.romid}.asm"
    off = "!Define_Global_ApplyAsarPatches = !FALSE"
    text = rom_map.read_text("utf-8")
    if off not in text:
        raise BuildError(
            f"{rom_map.name} does not hold the ApplyAsarPatches switch this "
            f"build knows how to flip"
        )
    rom_map.unlink()
    rom_map.write_text(
        text.replace(off, "!Define_Global_ApplyAsarPatches = !TRUE", 1), "utf-8"
    )
    digest = hashlib.sha256()
    for patch in enabled:
        digest.update(f"{patch.id}\n{patch.source}\n".encode())
    return digest.hexdigest()


def _patches_fit(project: Project) -> None:
    """Refuse a freespace-claiming patch on a cartridge with no freespace.

    The stock 512 KB image's gaps hold the shipped garbage bytes, reinserted
    for byte-exactness, so they are not free -- asar would grow the image to
    satisfy ``freecode`` and the length check would fail the build with a
    message about size. This is the same refusal, worded at the cause.
    """
    if project.rom_size_id != STOCK:
        return
    needy = [
        patch.name
        for patch in asm_patches.enabled_patches(project)
        if asm_patches.uses_freespace(patch.source)
    ]
    if needy:
        raise BuildError(
            f"{', '.join(needy)} claim(s) freespace; the stock cartridge has "
            f"none -- choose a larger size under ROM Size"
        )


def _apply(project: Project, tree: Path) -> dict[Path, tuple[int, int]]:
    """Write the project's changed files over the merged tree, and report them.

    The overlay mirrors the tree's own shape -- ``SMW/...`` and ``assets/...`` --
    so this is a copy at the same relative path rather than a routing decision.
    Which is the point of the overlay being laid out that way; see
    :attr:`~shiny_mushroom.project.Project.roots`.

    A hard link would be wrong here even where it worked: the overlay's files
    are the project's, and linking them into a tree that gets deleted and rebuilt
    is one ``rmtree`` away from taking the project's own data with it.

    **The raw resources are the exception**, and the only one: they shadow no
    file the build reads, so copying them at their own relative path would put a
    ``gfx/`` nothing assembles into the tree. They are still counted here --
    they belong in the fingerprint, since editing one is a reason to rebuild --
    and :func:`_compile_raw` is what actually puts them in. A tile editor's
    ``.pal`` beside one is neither copied nor counted: :attr:`Project.changed`
    leaves it out (:func:`~shiny_mushroom.project_graphics.is_sidecar`), so rewriting
    the palette is not a reason to rebuild.
    """
    applied: dict[Path, tuple[int, int]] = {}
    for relative in project.changed:
        source = project.overlay / relative
        if relative.parts[0] == RAW_NAME:
            stat = source.stat()
            applied[relative] = (stat.st_size, stat.st_mtime_ns)
            continue
        destination = tree / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        # Removed first: the mirror left a hard link here, and writing through it
        # would write into the checkout's own file.
        destination.unlink(missing_ok=True)
        shutil.copy2(source, destination)
        stat = source.stat()
        applied[relative] = (stat.st_size, stat.st_mtime_ns)
    return applied
