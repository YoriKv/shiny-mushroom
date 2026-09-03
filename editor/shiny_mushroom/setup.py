"""What has to be true before a level can be edited, and how to make it true.

**A fresh checkout cannot draw a single level.** The disassembly's graphics,
music and samples are not in it: they are copyrighted cartridge data, so they
are gitignored, and the tree reaches them through asar's include path from an
``assets/`` folder that starts out empty. Until someone supplies a reference
cartridge there is nothing to extract them from, nothing to build, and nothing
to run in the emulator.

So the editor has a **first run**, and this is its model. Three states, and the
app is always in exactly one:

1. **No assets.** Ask for a reference cartridge, check it is one of the five
   releases, and slice it. **This is the only thing the reference cartridge is
   ever for**: once its graphics, music and samples are on disk it is not
   needed again, and it can be moved or deleted without breaking anything.
2. **Assets, no project.** There is something to build a cartridge *from* and
   nowhere to keep the work.
3. **A project.** Editing, saving and building all work.

Any of the five releases will do, and several can be extracted side by side:
each release's graphics go into their own set under ``assets/GFX`` and the
music and samples are the same bytes in every cartridge, so a second cart adds
to what is on disk rather than replacing it. A project is built for **one**
release -- its target, chosen when it is made -- and can only be made for one
whose assets are there; two projects on two releases coexist because each
reads its own set.

The cartridge the editor actually opens is **the project's own**, assembled from
the disassembly, those assets and the project's overlay -- see
:func:`~shiny_mushroom.build.rom_path`. A new project's plays exactly what the
reference cart plays, because its overlay is empty and the features it starts
with (:data:`NEW_PROJECT_FEATURES`) only change where the game's own data is
placed; from the first save they diverge, and what is on the canvas is what the
project produces rather than what somebody once dumped.

**Every one of them has to be got through before the editor opens.** A half-set-up
app is a degenerate state rather than a lesser one: with no assets there is
nothing to build a cartridge from and so no picture, and a level edited with no
project open is work with nowhere to go that looks exactly like work being kept.
There is no useful thing the app does in either, so it does not offer to sit in
them -- see :meth:`~shiny_mushroom.ui.main_window.MainWindow.require_setup`, which
loops until the answer is :attr:`Stage.READY` or the person gives up and the app
quits.

Qt-free, like everything outside :mod:`shiny_mushroom.ui`: the dialogs ask these
questions and show the answers, and every judgement about what is ready is made
here where it can be tested without a window.

The extraction itself is :mod:`smw_tools.extract`'s -- the disassembly's own
extractor, not a second copy of it. What this adds is the part
an editor needs and a command line does not: deciding whether the step is
necessary at all, and refusing a cartridge that is not a release before
spending a minute on it.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass
from enum import Enum
from pathlib import Path

from shiny_mushroom.project import Project, projects
from smw_tools.bases import DEFAULT_BASE, DEFAULT_TARGET, RomBase
from smw_tools.extract import (
    ExtractError,
    assets_ready,
    extract,
    extractions,
    record_extraction,
)
from smw_tools.features import MANAGED_LEVEL_MEMORY
from smw_tools.paths import ASSETS_DIR, GAME_DIR, asar_binary
from smw_tools.rom_image import read_rom
from smw_tools.rom_versions import ALL_VERSIONS, ROM_VERSIONS, identify

#: The base and target a project is made on when nobody has chosen. Taken from
#: :mod:`smw_tools.bases` rather than written again here, so the editor's idea
#: of the default cannot drift from the one the build assembles.
BASE = DEFAULT_BASE
TARGET = DEFAULT_TARGET

#: What a project the editor starts asks its build for, as ids into
#: :data:`smw_tools.features.FEATURES`.
#:
#: Growable levels is here because the alternative is the trap it removes: on
#: the stock packing the levels are seven fixed groups, so an object added to
#: one level is paid for by another in the same group, and the first edit
#: someone makes can be refused for a reason that has nothing to do with the
#: level they are editing. With it on the levels are one budget and nothing
#: moves until a level grows.
#:
#: It is a *start*, not a rule: Project > Features switches it back off from
#: the first moment the project is open, while the levels still fit the stock
#: runs. And it is this path's decision rather than
#: :meth:`~shiny_mushroom.project.Project.create`'s, which makes a project
#: folder that asks for nothing.
NEW_PROJECT_FEATURES: tuple[str, ...] = (MANAGED_LEVEL_MEMORY.id,)

#: Where the asset extractor's own scripts live, relative to the game folder.
ASAR_SCRIPTS = GAME_DIR / "AsarScripts"


class Stage(Enum):
    """How far along a first run is. Ordered, so ``<`` means "not as far"."""

    NEEDS_ASSETS = 0
    NEEDS_PROJECT = 1
    READY = 2

    def __lt__(self, other: Stage) -> bool:
        return self.value < other.value


class SetupError(Exception):
    """A cartridge could not be used, or the extraction failed."""


@dataclass(frozen=True)
class Readiness:
    """What is in place, and therefore what the app can offer."""

    stage: Stage

    #: The releases whose assets are on disk, in :data:`ALL_VERSIONS` order.
    #: What a new project may be made for; empty is :attr:`Stage.NEEDS_ASSETS`.
    versions: tuple[str, ...] = ()

    #: How many projects there are. What decides whether the app offers to open
    #: one or only to make one.
    projects: int = 0

    @property
    def has_assets(self) -> bool:
        return self.stage > Stage.NEEDS_ASSETS


def ready_versions() -> tuple[str, ...]:
    """The releases whose assets are on disk, in :data:`ALL_VERSIONS` order.

    Asked of the disk each time rather than remembered, because the answer
    moves: an extraction adds one, and a deleted assets folder takes them all
    away without touching the record that says they were extracted.
    """
    return tuple(version for version in ALL_VERSIONS if assets_ready(version))


def available_targets(base: RomBase) -> tuple[str, ...]:
    """Which of ``base``'s targets a project can be made for right now: those
    whose asset set is on disk, in the base's own order.

    A target's assets are its *release's* -- ``sa1/U`` reads what ``vanilla/U``
    reads -- so the question is asked of the target id, which is the release.
    """
    return tuple(target for target in base.targets if assets_ready(target))


def extracted_from(cart: Path, version: str) -> bool:
    """Whether ``cart`` is the very cartridge the assets on disk came from.

    By hash rather than by path, so a cartridge that has been *moved* is
    recognised as the same one and does not have to be sliced again -- a minute
    of work to arrive back where it started.
    """
    record = extractions().get(version)
    if record is None or not assets_ready(version):
        return False
    try:
        return read_rom(cart).sha1 == record.sha1
    except OSError:
        return False


def readiness() -> Readiness:
    """Work out which of the three states the app is in.

    Any release's assets will do for the first state: a project is made for
    whichever releases are there, so one is enough to have something to build.
    """
    versions = ready_versions()
    if not versions:
        return Readiness(stage=Stage.NEEDS_ASSETS)
    found = len(projects())
    return Readiness(
        stage=Stage.NEEDS_PROJECT if found == 0 else Stage.READY,
        versions=versions,
        projects=found,
    )


def carries_copier_header(cart: Path) -> bool:
    """Whether ``cart`` is a headered dump -- an ``.smc`` with 512 bytes in
    front of the cartridge.

    Only so the dialog can *say* it took one off: nothing downstream needs
    asking, because :func:`~smw_tools.rom_image.read_rom` normalises the header
    away and everything here works on the bytes it returns. Unreadable answers
    ``False``; whether the file can be read at all is :func:`inspect`'s to say,
    with the error message.
    """
    try:
        return read_rom(cart).had_copier_header
    except OSError:
        return False


def inspect(cart: Path, wanted: str | None = None) -> str:
    """Which release ``cart`` is, or raise saying why it is no use.

    Checked **before** extracting rather than after, because extracting takes a
    minute and a hacked cartridge would produce assets that are not the ones the
    disassembly's byte-exactness is defined against -- a failure that surfaces
    much later as a build that does not match its pinned hash.

    Identified by hash, because the five releases are not distinguishable from
    their headers in any way that survives a hack.

    **A headered dump is one of the five.** The 512-byte copier header is not
    cartridge data -- it is a floppy copier's note about the dump -- so it is
    taken off before the hash is taken and before a byte is sliced, and an
    ``.smc`` is accepted exactly where the ``.sfc`` of the same cartridge is.
    Hashing the file as it lies would refuse every headered dump as "not one of
    the five", which is a file-format detail wearing the words for a hack.

    Any of the five is accepted unless ``wanted`` names one, in which case the
    others are refused **and named**: that is the dialog asked on behalf of a
    project that needs a particular release's assets, and extracting another's
    would leave it exactly as unready as it was, with the dialog reporting
    success on every pass.
    """
    try:
        image = read_rom(cart)
    except OSError as error:
        raise SetupError(f"{cart.name} could not be read: {error.strerror}") from error
    found = identify(image.sha1)
    if found is None:
        raise SetupError(
            f"{cart.name} is not one of the five Super Mario World releases.\n"
            f"Its SHA-1 is {image.sha1}, which matches none of them."
        )
    if wanted is not None and found != wanted:
        raise SetupError(
            f"{cart.name} is the {ROM_VERSIONS[found].label} release; this "
            f"project is built for {ROM_VERSIONS[wanted].label}.\n"
            f"Supply the {wanted} cartridge instead."
        )
    return found


def prepare(
    cart: Path,
    wanted: str | None = None,
    on_progress: Callable[[str], None] | None = None,
) -> str:
    """Extract ``cart``'s assets so the disassembly can be built for its release.

    Returns the release it turned out to be. Its graphics land in that
    release's own set and the music and samples in the shared folders, so what
    was extracted from another cartridge before is left exactly as it was: a
    second release is *added*. ``wanted`` is passed through to :func:`inspect`,
    which refuses any other release before a byte is written.

    Blocking, and about a minute. Nothing here is threaded -- keeping the work
    off the UI thread is the window's problem, and giving this its own thread as
    well would mean two answers to the same question.
    """
    found = inspect(cart, wanted)
    if extracted_from(cart, found):
        # The very cartridge these assets came from, handed over again -- which
        # is what pointing the editor at a ROM that has simply *moved* looks
        # like. Re-slicing it is a minute of work to arrive back where it
        # started, so the record is refreshed and nothing else is touched.
        record_extraction(version=found, rom=cart, count=extractions()[found].files)
        if on_progress:
            on_progress(f"Already extracted from this cartridge ({found}).")
        return found
    if on_progress:
        on_progress(f"Extracting assets from {ROM_VERSIONS[found].label}...")
    try:
        written = extract(
            asar_bin=asar_binary(),
            asar_scripts_dir=ASAR_SCRIPTS,
            rom_path=cart,
            version=found,
            dest_root=ASSETS_DIR,
        )
    except (ExtractError, OSError) as error:
        raise SetupError(f"The assets could not be extracted: {error}") from error
    if on_progress:
        on_progress(f"Extracted {len(written)} files.")
    return found


def start_project(
    name: str,
    base: Path = GAME_DIR,
    base_id: str = BASE,
    target_id: str = TARGET,
) -> Project:
    """Make a project, once there is something for it to be a project *of*.

    Refused before the assets for ``target_id``'s release are there -- that
    release's, not any release's: a project reads its own target's graphics
    set, and one made for a release that has not been extracted is a folder
    that looks like it works and does not, with the failure surfacing as a
    build that cannot find a file rather than as the missing step it is.

    The project it makes asks its build for :data:`NEW_PROJECT_FEATURES`.
    """
    if not assets_ready(target_id):
        named = ROM_VERSIONS.get(target_id)
        label = named.label if named else target_id
        raise SetupError(
            f"No graphics for {label} yet. Supply that reference cartridge "
            f"first and the editor will extract them."
        )
    project = Project.create(name, base=base, base_id=base_id, target_id=target_id)
    project.set_feature_state(NEW_PROJECT_FEATURES)
    return project
