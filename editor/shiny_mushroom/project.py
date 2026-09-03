"""A project: the folder an edit is saved into, laid over the disassembly.

**Nothing the editor saves touches ``smw/src/``.** A project is a folder of its
own holding a ``project.json`` and a sparse ``overlay/`` -- a mirror of the game
folder containing only the files that have been changed. Saving level ``$105``
writes ``overlay/levels/105.mwl`` and nothing else; a build assembles the tree
as *base then overlay*, so every file nobody has touched is still the
disassembly's own.

That is worth the indirection for three reasons, and they are the whole design:

- **The checkout stays byte-exact.** ``smw/`` is the reference, and the one rule
  the repository has is that it builds all five releases to the pinned hashes.
  An editor that wrote into it would break that with the first save, and the
  gate that catches it runs for four minutes.
- **An edit is reviewable and revertible as a file.** The overlay *is* the diff:
  what is in it is what has been changed, and deleting a file from it puts that
  level back to stock. There is no separate record to keep in step.
- **Several hacks can share one disassembly.** The base is read-only, so a
  project is just a folder, and the expensive thing -- a checkout with its
  extracted assets -- is not copied per project.

Qt-free, like everything outside :mod:`shiny_mushroom.ui`: a project is a
directory layout and a JSON file, and both are testable by handing this a
``tmp_path``.

The container a level's bytes live in is :mod:`smw_tools.levels`'s business, and
rewriting one is :mod:`shiny_mushroom.mwl`'s. This module knows only that a
level resolves to some files under the game folder, and that a saved one goes to
the same relative path under the overlay.

**A project is more than one subject, and each has a module.** Here are the
folder and its ``project.json``, the overlay primitives every subject writes
through, the Map16 tables, the game's colours, the editable asm regions and
the listing. The rest are mixed into :class:`Project` from beside it --
:mod:`shiny_mushroom.project_levels`,
:mod:`shiny_mushroom.project_graphics` and
:mod:`shiny_mushroom.project_overworld` -- so a caller still asks the
project for all of it and each subject is read in one place. The write and
cache primitives they share are :mod:`shiny_mushroom.project_files`; the four
of those a caller outside the package asks for -- :class:`ProjectError`,
:data:`RAW_NAME`, :func:`forget_readings` and :func:`scanning_once` -- are
published here as well, because this module is the face and that one is the
plumbing. A name of that module nothing outside it asks for is not.
"""

from __future__ import annotations

import json
import re
import shutil
from collections.abc import Callable, Iterable, Mapping
from dataclasses import dataclass, replace
from pathlib import Path

from shiny_mushroom import level_graphics, level_palettes, map16, palettes

# Every `x as x` from `project_files` is published from here on purpose, and
# the redundant alias is what says so -- see the module docstring. The plain
# names from it are this module's own use of it, and nothing else.
from shiny_mushroom.project_files import RAW_NAME as RAW_NAME
from shiny_mushroom.project_files import ProjectError as ProjectError
from shiny_mushroom.project_files import (
    _now,
    _remembered,
    _scanned,
    _string_list,
    _write_atomic,
)
from shiny_mushroom.project_files import forget_readings as forget_readings
from shiny_mushroom.project_files import scanning_once as scanning_once
from shiny_mushroom.project_graphics import GraphicsFiles, is_sidecar
from shiny_mushroom.project_levels import LevelFiles
from shiny_mushroom.project_music import MusicFiles
from shiny_mushroom.project_overworld import WorldMapFiles
from smw_tools import asm_codec, asm_regions, asm_room
from smw_tools.bases import (
    BASES,
    DEFAULT_BASE,
    DEFAULT_TARGET,
    BuildTarget,
    RomBase,
)
from smw_tools.bases import base as rom_base
from smw_tools.features import applied
from smw_tools.paths import ASSETS_DIR, GAME_DIR, data_dir
from smw_tools.rom_sizes import ROM_SIZES, STOCK, RomSize

#: The project's own metadata file, and the directory the overlay lives in.
PROJECT_FILE = "project.json"
OVERLAY_DIR = "overlay"

#: Where the project's asm patches live -- see :attr:`Project.patches_dir`.
PATCHES_DIR = "patches"

#: Where its build puts the ROM, the symbol file and the state below.
OUTPUT_DIR = "build"

#: What the build records about the cartridge it produced -- the base, the
#: target, the size, the features and the fingerprint of its inputs. Written
#: by :func:`shiny_mushroom.build.build`; read here because two of those are
#: what the *project* is read through afterwards, and the folder is its own.
BUILD_STATE = ".build-state.json"

#: Feature ids an update merged into another, read as what they became so
#: a project saved before the merge keeps its switch: the three code
#: features and the UberASM dialect are one ``uberasm`` feature
#: (UberASM Support) now, and the PIXI dialect rode into
#: ``custom-sprites`` (Custom sprites (PIXI)) the same way.
MERGED_FEATURES = {
    "level-code": "uberasm",
    "gamemode-code": "uberasm",
    "global-code": "uberasm",
    "pixi": "custom-sprites",
}

#: Where the custom level palettes live inside the game tree's namespace --
#: overlay files that shadow nothing, like the added containers, one
#: ``<level>.pal`` of :data:`shiny_mushroom.level_palettes.SIZE` bytes per
#: level that wears one. Deleting the file *is* the removal.
LEVEL_PALETTES_DIR = Path("palettes/levels")

#: What such a file is called: the level number, three upper-case hex digits.
LEVEL_PALETTE_NAME = re.compile(r"^[0-9A-F]{3}\.pal$")

#: What the overlay files the extracted graphics, music and samples under. They
#: live outside the source tree, so the overlay needs a name for them that cannot
#: collide with the game folder's own -- see :attr:`Project.roots`.
ASSETS_NAME = "assets"

#: What a project may be called. Lowercase letters and digits with ``-`` and
#: ``_`` between them, starting alphanumeric -- the safe intersection of what
#: Windows, macOS and Linux all accept, with no spaces, no reserved punctuation
#: and no trailing-dot pitfalls. The folder name **is** the project's name, so
#: this is a filesystem rule rather than a style preference. The same
#: expression is stated as :data:`smw_tools.features.ID_PATTERN` for its own
#: reasons; a test pins the two equal.
NAME_PATTERN = re.compile(r"^[a-z0-9][a-z0-9_-]{0,63}$")

#: Names Windows reserves for devices. A folder called ``con`` cannot be created
#: there, and finding that out at save time is worse than refusing it up front.
RESERVED_NAMES = frozenset(
    {"con", "prn", "aux", "nul"}
    | {f"com{digit}" for digit in range(1, 10)}
    | {f"lpt{digit}" for digit in range(1, 10)}
)

#: What a project is called when nobody has said.
DEFAULT_NAME = "new-shiny"


class HandEditedRegion(ProjectError):
    """A region the editor owns whose overlay fragment has been hand-edited
    past the emitter's grammar, so a structured save refuses to write over it.

    The editor's fragments are whole-file overlay entries it rewrites from a
    model, so a save is an overwrite -- and for a region whose document
    *defaults* rather than carries (the warp, exit and sprite-disable tables),
    a fragment that did not parse leaves the document holding vanilla, which
    would otherwise be written back as a revert and **delete** the hand-edited
    file. Refusing here is what keeps the grammar the ownership fence: what
    the editor can read it may rewrite, and what it cannot it leaves alone.
    """

    def __init__(self, region_id: str, path: Path, reason: str) -> None:
        self.region_id = region_id
        #: The overlay fragment, which is the file to fix or revert.
        self.path = path
        #: The parse failure, which names the line.
        self.reason = reason
        super().__init__(
            f"{region_id} is hand-edited past what the editor can read "
            f"({reason}). Fix or revert {path}; nothing was saved."
        )


def valid_name(name: str) -> bool:
    """Whether ``name`` can be a project folder on every platform."""
    return bool(NAME_PATTERN.match(name)) and name not in RESERVED_NAMES


def _stock_size(base_id: str) -> str:
    """The size ``base_id`` builds when nobody has chosen one.

    Tolerant of a base this build does not have, because :func:`projects` lists
    one of those rather than refusing it -- and a listing still has to say
    something for the size column.
    """
    return BASES[base_id].stock_size if base_id in BASES else STOCK


def _check_rom_size(base_id: str, rom_size_id: str, of: str = "a project") -> None:
    """Refuse a size the project's base cannot be assembled at.

    **The ladder is the base's, not the module's**: ``vanilla`` runs 512 KB to
    4 MB and ``sa1`` 1 MB to 8 MB, and they overlap without agreeing -- there is
    no 512 KB SA-1 cartridge and no 8 MB LoROM one. So this is one question
    rather than "does the size exist" and "may this base be resized" separately.
    See :attr:`smw_tools.bases.RomBase.sizes`.
    """
    offered = rom_base(base_id).sizes
    if rom_size_id not in offered:
        raise ProjectError(
            f"{of} names the ROM size {rom_size_id!r}; the ROM base "
            f"{base_id!r} offers {', '.join(offered)}"
        )


#: Where :func:`projects_root` answers, when something has redirected it. Only
#: :func:`use_projects_root` sets it.
_root: Path | None = None


def use_projects_root(root: Path | None) -> None:
    """Point every later :func:`projects_root` call somewhere else.

    **For tests**, and for the same reason
    :func:`~shiny_mushroom.ui.settings.use_store` exists: without it a test run
    creates folders in the developer's own application-data directory and lists
    the projects they are actually working on. ``None`` puts it back.
    """
    global _root
    _root = root


def projects_root() -> Path:
    """Where projects are kept: the platform's application-data directory.

    Computed here rather than asked of Qt, because this module is Qt-free and
    the emulator worker imports things beside it. The three answers are the
    conventional ones, and each honours the environment variable its platform
    uses so a person who has moved their data directory is followed.
    """
    if _root is not None:
        return _root
    return _data_dir() / "projects"


#: Where :func:`cache_root` answers, when something has redirected it. Its own
#: variable rather than a sibling of ``_root``, because the two are redirected
#: for different reasons: a test points projects somewhere to keep a listing
#: honest, and points the cache somewhere to keep a capture out of the
#: developer's own.
_cache: Path | None = None


def use_cache_root(root: Path | None) -> None:
    """Point every later :func:`cache_root` call somewhere else. **For tests**,
    on the same terms as :func:`use_projects_root`."""
    global _cache
    _cache = root


def cache_root() -> Path:
    """Where derived data that can always be recomputed is kept.

    Beside the projects rather than inside one, because what is filed here is a
    property of a **cartridge** and several projects can share one -- the player
    capture (:mod:`shiny_mushroom.emu.player_cache`) is the whole of it today.

    Deleting it costs time and nothing else, which is the property that decides
    what may live here: anything a person would miss belongs in their project.
    """
    if _cache is not None:
        return _cache
    return _data_dir() / "cache"


def _data_dir() -> Path:
    """This application's data directory, by each platform's own convention.

    One rule, in `smw_tools.paths`, because a frozen build extracts cart assets
    into this same directory and that has to be the same directory: projects,
    the cache and the assets are one application's state and are found together
    or not at all.
    """
    return data_dir()


@dataclass(frozen=True)
class Project(GraphicsFiles, LevelFiles, MusicFiles, WorldMapFiles):
    """One project folder, and what can be written into it.

    The **folder name is the identity**, not anything stored inside it. A
    ``project.json`` whose name has drifted from its folder -- which is what
    renaming the folder outside the app produces -- would otherwise make every
    path here point at somewhere that no longer exists, and the folder is the
    thing that actually has to be found.
    """

    root: Path

    #: The disassembly's game folder, which the overlay is laid over. Held so a
    #: test can point a project at a fixture tree, and so a build can ask a
    #: project what it was made against.
    base: Path = GAME_DIR

    #: The extracted graphics, music and samples, which the overlay lies over
    #: too. Separate from :attr:`base` because they are separate on disk and are
    #: reached differently by the build -- see :attr:`roots`.
    assets_base: Path = ASSETS_DIR

    #: Which ROM base and target this project's overlay is written against,
    #: recorded in ``project.json``.
    #:
    #: **An overlay is only meaningful against the tree whose paths it is
    #: expressed in.** ``overlay/SMW/levels/105.mwl`` shadows a file that exists
    #: at that path in *this* base; laid over another it would shadow nothing, or
    #: something else, and the build would quietly assemble stock levels. So the
    #: identity is stored rather than assumed, and :meth:`open` refuses a project
    #: whose base this build does not have.
    base_id: str = DEFAULT_BASE
    target_id: str = DEFAULT_TARGET

    #: How large a cartridge this project assembles into -- see
    #: :mod:`smw_tools.rom_sizes`.
    #:
    #: **Unlike the base, this one changes.** An overlay is written in its base's
    #: paths and means nothing laid over another, which is why :attr:`base_id` is
    #: fixed at creation; the size decides only how far the image is padded past
    #: the last thing in it. Every address the overlay's files land at is where
    #: it was, so switching is a rebuild rather than a migration -- see
    #: :meth:`set_rom_size`.
    #:
    #: Which sizes there are to choose from is the **base's** ladder, and the
    #: two do not agree: ``sa1`` has no 512 KB cartridge and ``vanilla`` no 8 MB
    #: one. The default here is the default base's stock, and every other path
    #: resolves it against the base actually in hand.
    rom_size_id: str = STOCK

    @property
    def rom_size(self) -> RomSize:
        """The cartridge size this project builds, as a value rather than a
        name.

        Checked on the way out, because :func:`projects` lists what a
        ``project.json`` records without validating it -- see :attr:`buildable`.
        """
        _check_rom_size(self.base_id, self.rom_size_id, of=self.name)
        return ROM_SIZES[self.rom_size_id]

    @property
    def target(self) -> BuildTarget:
        """The target this project builds, as a value rather than a name.

        Everything that depends on *which release* -- which level containers the
        tree places, which graphics set the assets come from, what the ROM is
        called -- goes through here.
        """
        return rom_base(self.base_id).target(self.target_id)

    @property
    def spec(self) -> str:
        """What this project is built on, in the ``<base>/<target>`` spelling
        the command line uses: ``vanilla/U``.

        The whole identity in one string, which is what a list of projects has
        room to show. It is the **stored** pair rather than a resolved one, so a
        project naming a base this build does not have still says which -- see
        :attr:`buildable`.
        """
        return f"{self.base_id}/{self.target_id}"

    @property
    @_remembered
    def features(self) -> tuple[str, ...]:
        """Which capabilities this project's **cartridge** has beyond the stock
        game, as ids into :data:`smw_tools.features.FEATURES`.

        Its build's own record, in :data:`BUILD_STATE`: what a cartridge is was
        decided when it was assembled, and a patch turned on since is a claim
        about the next one. A project with no build answers with its base's own
        features, which is what a cartridge assembled from the stock tree has.

        Asked once per project write (:func:`_remembered`), because
        :attr:`cartridge_base` is asked of every editable asm region a patch
        gather touches and this is a file read apiece. The record is written
        by a build rather than by a save, so
        :func:`shiny_mushroom.build.merge` drops the readings when it lays
        one down.
        """
        try:
            held = json.loads((self.root / OUTPUT_DIR / BUILD_STATE).read_text("utf-8"))
        except (OSError, ValueError):
            held = None
        if not isinstance(held, dict) or not isinstance(held.get("features"), list):
            return rom_base(self.base_id).features if self.buildable else ()
        return tuple(
            dict.fromkeys(
                MERGED_FEATURES.get(one, one) for one in _string_list(held["features"])
            )
        )

    @property
    def rom_size_built(self) -> str:
        """How long this project's **cartridge** is, as a
        :mod:`smw_tools.rom_sizes` id.

        Its build's own record, exactly as :attr:`features` is and read out of
        the same file: what a cartridge is was decided when it was assembled,
        and :attr:`rom_size_id` is a claim about the next one. A project with
        no build answers with its base's stock size, which is what a cartridge
        assembled from the stock tree is.
        """
        try:
            held = json.loads((self.root / OUTPUT_DIR / BUILD_STATE).read_text("utf-8"))
        except (OSError, ValueError):
            held = None
        stock = rom_base(self.base_id).stock_size if self.buildable else STOCK
        if not isinstance(held, dict):
            return stock
        size = held.get("rom_size")
        return size if isinstance(size, str) and size in ROM_SIZES else stock

    @property
    def cartridge_base(self) -> RomBase:
        """This project's base as its **cartridge** is: the declared base with
        :attr:`features` folded in -- see :mod:`smw_tools.features`.

        The one place anything reading or writing this project's tables
        resolves a base, so a feature reaches the addresses, the traced code
        ranges, the RAM map and every table's entry count at once -- and the
        cartridge's **size** with them, since a feature that uses an expansion
        bank where there is one has less room where there is not -- and it is
        the size that build recorded, for the reason :attr:`features` is the
        set that build recorded.
        """
        return applied(rom_base(self.base_id), self.features, self.rom_size_built)

    @property
    def buildable(self) -> bool:
        """Whether this build has the base, target and size this project names.

        False is not corruption: it is a project made by a build that had a base
        this one does not, and the answer is to say so rather than to hide the
        project or to lay its overlay over the default -- see :meth:`open`.
        """
        return (
            self.base_id in BASES
            and self.target_id in BASES[self.base_id].targets
            and self.rom_size_id in BASES[self.base_id].sizes
        )

    @property
    def name(self) -> str:
        return self.root.name

    @property
    def overlay(self) -> Path:
        return self.root / OVERLAY_DIR

    # -- the folder ---------------------------------------------------------

    @classmethod
    def create(
        cls,
        name: str,
        root: Path | None = None,
        base: Path = GAME_DIR,
        assets_base: Path = ASSETS_DIR,
        base_id: str = DEFAULT_BASE,
        target_id: str = DEFAULT_TARGET,
        rom_size_id: str | None = None,
    ) -> Project:
        """Make a new project folder, refusing to overwrite one.

        ``root`` is the directory projects are kept in, defaulting to
        :func:`projects_root`; passing one is how a test avoids writing into a
        real application-data directory.

        ``base_id`` and ``target_id`` are written into ``project.json`` and
        cannot be changed afterwards -- see :attr:`base_id`. ``rom_size_id`` is
        written there too and *can*, through :meth:`set_rom_size`; ``None``
        means the base's own stock size, which is 512 KB for ``vanilla`` and
        1 MB for ``sa1``.

        The folder this makes asks its build for nothing: a project *the
        editor* starts carries the features
        :data:`shiny_mushroom.setup.NEW_PROJECT_FEATURES` names, which is
        that path's decision and not this one's.
        """
        if not valid_name(name):
            raise ProjectError(
                f"{name!r} is not a usable project name: lowercase letters, "
                f"digits, '-' and '_', starting with a letter or digit"
            )
        folder = (root or projects_root()) / name
        if folder.exists():
            raise ProjectError(f"there is already a project called {name!r}")
        rom_size_id = rom_size_id or _stock_size(base_id)
        _check_rom_size(base_id, rom_size_id)
        project = cls(
            root=folder,
            base=base,
            assets_base=assets_base,
            base_id=base_id,
            target_id=target_id,
            rom_size_id=rom_size_id,
        )
        project.overlay.mkdir(parents=True)
        project._write_metadata(
            {
                "created": _now(),
                "modified": _now(),
                "base": base_id,
                "target": target_id,
                "rom_size": rom_size_id,
            }
        )
        return project

    @classmethod
    def open(
        cls,
        folder: Path,
        base: Path = GAME_DIR,
        assets_base: Path = ASSETS_DIR,
    ) -> Project:
        """Open an existing project folder.

        **A project made against a base this build does not have cannot be
        opened.** Falling back to the default would lay its overlay over a tree
        whose paths mean something else: every shadowed file would shadow
        nothing, the build would succeed, and it would quietly assemble stock
        levels. Refusing names the base that is missing instead.
        """
        if not (folder / PROJECT_FILE).is_file():
            raise ProjectError(f"{folder} is not a project folder")
        project = cls(
            root=folder, base=base, assets_base=assets_base
        )._with_stored_ids()
        if project.base_id not in BASES:
            raise ProjectError(
                f"{folder.name!r} was made against the ROM base "
                f"{project.base_id!r}, which this build does not have -- "
                f"expected one of {', '.join(BASES)}"
            )
        if project.target_id not in rom_base(project.base_id).targets:
            raise ProjectError(
                f"{folder.name!r} was made against {project.spec}, and "
                f"{project.base_id} has no target {project.target_id!r}"
            )
        # Refused rather than quietly built at the stock size: the size decides
        # how much room the cartridge has, and assembling a project smaller than
        # it asked for is a build that can fail for a reason nothing named.
        _check_rom_size(project.base_id, project.rom_size_id, of=folder.name)
        return project

    @property
    def stored_ids(self) -> tuple[str, str, str]:
        """The base, target and ROM size ``project.json`` records, unvalidated.

        Absent means a project made before that field was recorded. Every
        project made before the base was was ``vanilla/U``, the only thing the
        editor could build; every one made before the size was was the stock
        cartridge, for the same reason.

        Unvalidated deliberately, and read in one place: :meth:`open` is what
        refuses a base this build does not have, and :func:`projects` is what
        lists one anyway. Both need the same strings first, and a second copy of
        this fallback is a second place for them to disagree.
        """
        stored = self.metadata
        base_id = stored.get("base", DEFAULT_BASE)
        return (
            base_id,
            stored.get("target", DEFAULT_TARGET),
            # Against the base's own ladder, not the module's: a project that
            # predates the field is its base's stock cartridge, and `sa1`'s is
            # a megabyte rather than the shipped 512 KB.
            stored.get("rom_size") or _stock_size(base_id),
        )

    def _with_stored_ids(self) -> Project:
        """This project with the ids its ``project.json`` records applied.

        What :meth:`open` then validates and :func:`projects` deliberately does
        not: both need the same three strings put on the same project first,
        and doing it twice is two places for them to differ.
        """
        base_id, target_id, rom_size_id = self.stored_ids
        return replace(
            self, base_id=base_id, target_id=target_id, rom_size_id=rom_size_id
        )

    def set_rom_size(self, rom_size_id: str) -> Project:
        """Record a different cartridge size, and hand back the project that
        builds it.

        **Nothing in the overlay moves.** Expanding pads the image out past the
        last thing in it and changes three bytes of the header; every address a
        level, a graphics file or a table lands at is where it was. So this is a
        stored preference and a rebuild, not a migration -- and switching back
        assembles exactly what it did before.

        Frozen like the rest of this class, so the caller has to take the
        project handed back. The one already in hand still names the old size,
        which is what makes "set it, then build the old one" impossible to write
        by accident.
        """
        _check_rom_size(self.base_id, rom_size_id, of=self.name)
        self._write_metadata({"modified": _now(), "rom_size": rom_size_id})
        return replace(self, rom_size_id=rom_size_id)

    @property
    @_remembered
    def metadata(self) -> dict:
        """What ``project.json`` says, or an empty mapping if it cannot be read.

        A file someone has hand-edited, or one written by a newer build, must
        not stop a project from opening -- the folder and the overlay are what
        the project actually is, and everything here is description.
        """
        try:
            found = json.loads((self.root / PROJECT_FILE).read_text("utf-8"))
        except (OSError, ValueError):
            return {}
        return found if isinstance(found, dict) else {}

    def _write_metadata(self, extra: dict) -> None:
        # The folder's name last, over whatever the file claimed: the folder is
        # the identity, and a stored name that has drifted from it is stale
        # rather than authoritative.
        merged = {**self.metadata, **extra, "name": self.name}
        _write_atomic(self.root / PROJECT_FILE, json.dumps(merged, indent=2) + "\n")

    # -- what is in the overlay ---------------------------------------------

    @property
    def roots(self) -> dict[str, Path]:
        """The base trees the overlay lies over, by the name it files them under.

        Two, and they are not alike: the source tree is ``incbin``\\ ed by paths
        that exist inside it, while the assets are reached through asar's include
        search path from outside it. The overlay keeps them apart by name for
        exactly that reason -- ``overlay/SMW/levels/105.mwl`` and
        ``overlay/assets/GFX/SMW_U/x.lz2`` are unambiguous, where one flat mirror
        of both would not be.
        """
        return {self.base.name: self.base, ASSETS_NAME: self.assets_base}

    def overlaid(self, path: Path) -> Path:
        """Where a file of a base tree lives in this project's overlay.

        Raises :class:`ProjectError` for a path in neither, which is a caller
        asking about a file this project has no opinion on rather than a
        condition worth silently inventing an answer for.
        """
        for name, root in self.roots.items():
            if path.is_relative_to(root):
                return self.overlay / name / path.relative_to(root)
        raise ProjectError(f"{path} is not in anything this project lies over")

    def source(self, path: Path) -> Path:
        """The file the build would read for ``path``: the overlay's copy if
        there is one, and the base tree's otherwise.

        The whole of what "laid over" means, in one function. Everything that
        reads a level -- the editor opening one, a build assembling one -- goes
        through here, so a project is never half applied.
        """
        overlaid = self.overlaid(path)
        return overlaid if overlaid.is_file() else path

    def _shadow_or_revert(
        self, relative: Path, content: str | bytes, stock: str | bytes
    ) -> Path | None:
        """Lay ``content`` over the base tree's ``relative``, or take the
        overlay's copy away where it says exactly what ``stock`` says, and
        answer the file that moved -- ``None`` for content already stock with
        no copy to take away.

        **The overlay holds only what differs.** A file edited back to the
        disassembly's own is a file *removed*, exactly as
        :meth:`revert_level` removes a container, so a project put back
        reverts to nothing rather than to a copy of stock. Metadata is the
        caller's, so a save of several parts stamps once.

        Bytes are refused off-size, :meth:`_save_plain`'s check for
        :meth:`_save_plain`'s reason: what is written this way is a
        fixed-size ``incbin``, and a same-size copy cannot move a byte of
        the ROM map. Text has no such rule -- what it lays over is asm.
        """
        destination = self.overlaid(self.base / relative)
        if content == stock:
            if not destination.is_file():
                return None
            destination.unlink()
            return destination
        if isinstance(content, bytes) and len(content) != len(stock):
            raise ProjectError(
                f"{relative} is {len(stock):#x} bytes, not {len(content):#x}"
            )
        destination.parent.mkdir(parents=True, exist_ok=True)
        _write_atomic(destination, content)
        return destination

    @property
    def changed(self) -> list[Path]:
        """Every file this project has changed, relative to the **overlay root**
        -- so each one carries the name of the tree it belongs to.

        The overlay *is* the diff, so this is a directory walk rather than a
        comparison -- what is in it is what has been edited. The one thing
        the walk leaves out is a tile editor's palette sidecar
        (:func:`is_sidecar`): under :data:`RAW_NAME` only a registry key is a
        build input, and the sidecar is put there for another program to
        read. This is the walk every reading of the overlay shares -- the
        build's fingerprint, the Source Files rows, the stamps the window
        watches -- so it is excluded here and nowhere else.
        """
        if not self.overlay.is_dir():
            return []
        return sorted(
            relative
            for found in self.overlay.rglob("*")
            if found.is_file()
            and not is_sidecar(relative := found.relative_to(self.overlay))
        )

    def shadowed(self, relative: Path) -> Path | None:
        """The base-tree file one overlay entry stands in for, by its
        :attr:`changed` spelling -- and ``None`` for an entry that stands in
        for nothing.

        The inverse of :meth:`overlaid`, and the one question that catches a
        typo'd overlay path: such a file is copied into the merged tree, asar
        never reads it, and the build succeeds having quietly assembled stock.
        ``None`` for :data:`RAW_NAME` too, which shadows nothing by design --
        see :meth:`raw_edits`, which is that side's own question.
        """
        name, *rest = relative.parts
        root = self.roots.get(name)
        if root is None or not rest:
            return None
        found = root.joinpath(*rest)
        return found if found.is_file() else None

    def materialize_source(self, path: Path) -> Path:
        """Copy one of the base trees' files into the overlay, to be edited by
        hand, and say where it landed.

        Either spelling. An **absolute** path in one of :attr:`roots` is what a
        caller browsing the disassembly has, and :meth:`overlaid` resolves the
        tree from it; a **relative** one is read as the overlay's own spelling
        -- ``SMW/Banks/Bank06.asm`` -- which is what :attr:`changed`,
        :meth:`shadowed` and :meth:`revert_source` speak and what a row already
        carries. The tree's name is what makes the relative form unambiguous:
        the same path can exist in the game folder and in the assets, so a bare
        ``Banks/Bank06.asm`` is refused rather than guessed at.

        A file the overlay already holds is handed back untouched:
        materializing is how hand editing *starts*, so doing it twice must not
        throw away the first edit.

        The copy keeps the base's mtime (:func:`shutil.copy2`), so a
        materialized file that has not been edited yet stays quiet in every
        stat-keyed reading of the overlay.
        """
        found = path if path.is_absolute() else self.shadowed(path)
        if found is None or not found.is_file():
            raise ProjectError(f"{path} is not a file this project can lay over")
        destination = self.overlaid(found)
        # `is_relative_to` is lexical, so a path climbing out of a tree with
        # `..` satisfies it and lands the copy outside the overlay. This writes
        # a file, so where it writes is checked rather than assumed.
        if not destination.resolve().is_relative_to(self.overlay.resolve()):
            raise ProjectError(f"{path} is not inside this project's overlay")
        if destination.is_file():
            return destination
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(found, destination)
        self._write_metadata({"modified": _now()})
        return destination

    def revert_source(self, relative: Path) -> Path | None:
        """Take one overlay entry back out, by its :attr:`changed` spelling.

        Deleting the file is the revert, exactly as it is for a level. The
        overlay spelling rather than a base path, because this has to be able
        to remove an entry that shadows nothing -- a stray is precisely what
        somebody most needs to delete, and it has no base file to name it by.

        A path that climbs out of the overlay is refused rather than followed:
        this deletes, and the caller's spelling is the only thing bounding what
        it deletes.
        """
        held = self.overlay / relative
        if not held.resolve().is_relative_to(self.overlay.resolve()):
            raise ProjectError(f"{relative} is not inside this project's overlay")
        if not held.is_file():
            return None
        held.unlink()
        self._write_metadata({"modified": _now()})
        return held

    def _sync_fragments(self, wanted: Mapping[Path, str | None]) -> list[Path]:
        """Bring each generated fragment to ``wanted``'s text -- ``None`` is
        the disassembly's stock copy, so the overlay's comes out -- and say
        which files moved."""
        moved: list[Path] = []
        for relative, text in wanted.items():
            path = self.overlaid(self.base / relative)
            if text is None:
                if path.is_file():
                    path.unlink()
                    moved.append(path)
                continue
            try:
                found = path.read_text(encoding="utf-8")
            except OSError:
                found = None
            if found != text:
                path.parent.mkdir(parents=True, exist_ok=True)
                _write_atomic(path, text)
                moved.append(path)
        return moved

    # -- plain fixed-size incbins ---------------------------------------------

    def _plain(self, relative: Path, size: int) -> bytes:
        """A fixed-size plain binary the build would read, exactly ``size``.

        Through :meth:`source`, so an edited project reopens as the edit --
        the same rule :meth:`level_streams` states for a level.
        """
        found = self.source(self.base / relative).read_bytes()
        if len(found) != size:
            raise ProjectError(f"{relative} is {len(found):#x} bytes, not {size:#x}")
        return found

    def _save_plain(self, relative: Path, data: bytes, size: int) -> Path:
        """Write one fixed-size plain binary into the overlay.

        The exact-size check **is** the room check: the file is a fixed-size
        ``incbin``, so a same-size copy cannot move a byte of the ROM map and
        an off-size one is refused before anything is written -- which is why
        this needs none of :meth:`save_raw`'s rollback. Metadata is the
        caller's, so a save of several parts stamps once.
        """
        if len(data) != size:
            raise ProjectError(f"{relative} is {size:#x} bytes, not {len(data):#x}")
        destination = self.overlaid(self.base / relative)
        destination.parent.mkdir(parents=True, exist_ok=True)
        _write_atomic(destination, data)
        return destination

    # -- the game's colours ---------------------------------------------------

    def _palette_files(self, *, stock: bool = False) -> dict[Path, bytes]:
        """Every file the palette table is assembled out of.

        The build reads the table from six files -- a ``.tpl`` per set where
        Lunar Magic exported one, ``palettes/smw.pal`` for the rest -- so this
        is where "the palettes" stops being one file. Through :meth:`source`
        unless ``stock``, which is what makes an edited project reopen as the
        edit; the disassembly's own copy is read either way, because its length
        is the room check every one of them has to pass.
        """
        out: dict[Path, bytes] = {}
        for relative in palettes.FILES:
            original = (self.base / relative).read_bytes()
            if stock:
                out[relative] = original
                continue
            found = self.source(self.base / relative).read_bytes()
            if len(found) != len(original):
                raise ProjectError(
                    f"{relative} is {len(found):#x} bytes, not {len(original):#x}"
                )
            out[relative] = found
        return out

    def palette(self) -> bytes:
        """The palette table the build would assemble -- this project's colours
        where it has saved any, and the disassembly's own everywhere else.

        Every palette in the game is in here; see
        :mod:`shiny_mushroom.palettes` for what the runs inside it are and why
        an edit to one is global.
        """
        return palettes.assemble(self._palette_files())

    def stock_palette(self) -> bytes:
        """The **disassembly's** palette table, whatever this project has saved.

        The base the held document's changes are measured from, so that putting
        a colour back means the game's own colour and not whatever was saved
        last. :meth:`palette` is the other question -- what the build would
        read -- and the two differ exactly where this project has edited.
        """
        return palettes.assemble(self._palette_files(stock=True))

    def save_palette(self, blob: bytes) -> list[Path]:
        """Write the game's colours into the overlay, and say which files moved.

        The table is cut out of several files, so a saved blob is **split back
        the way the table reads it**: a colour edited in the back area colours
        lands in ``Sky.tpl``, one in the ending palettes in ``smw.pal``, and a
        file no edit reached is not written at all. Everything a ``.tpl`` holds
        outside the ranges the table reads -- its header, the columns of a row
        the game never loads -- is copied through untouched, so the file stays
        one Lunar Magic opens.

        Each file is a fixed-size ``incbin``, so the size check
        :meth:`_save_plain` makes is the whole of the room check: a same-size
        file cannot move a byte of the ROM map, and there is no region to price
        and nothing to roll back.

        **Colours edited back to the game's own leave no file.** The overlay is
        the diff, so a file that matches the disassembly's is taken out of it
        rather than written as a copy -- the same rule :meth:`save_raw` keeps
        for a compressed resource, and what makes :attr:`palette_edited` mean
        what it says.
        """
        if len(blob) != palettes.BLOB_SIZE:
            raise ProjectError(
                f"the palette table is {palettes.BLOB_SIZE:#x} bytes, "
                f"not {len(blob):#x}"
            )
        stock = self._palette_files(stock=True)
        wanted = palettes.split(blob, stock)
        touched: list[Path] = []
        for relative, data in wanted.items():
            if moved := self._shadow_or_revert(relative, data, stock[relative]):
                touched.append(moved)
        if touched:
            self._write_metadata({"modified": _now()})
        return touched

    def revert_palette(self) -> list[Path]:
        """Put the game's colours back to the disassembly's own, and say what
        was removed. Deleting the files is the revert, exactly as it is for a
        level; a project that never saved any reverts to nothing.

        The custom level palettes go with them: the disassembly dresses no
        level in its own colours, so "the disassembly's own" takes every one
        of those files out too.
        """
        gone = [
            held
            for held in self._palette_overlays()
            + self._level_palette_files()
            + [
                self.overlaid(self.base / relative)
                for relative in (
                    level_palettes.POINTERS_FRAGMENT,
                    level_palettes.DATA_FRAGMENT,
                )
            ]
            if held.is_file()
        ]
        for held in gone:
            held.unlink()
        if gone:
            self._write_metadata({"modified": _now()})
        return gone

    def _palette_overlays(self) -> list[Path]:
        """Where this project's copy of each palette file would live."""
        return [self.overlaid(self.base / relative) for relative in palettes.FILES]

    @property
    def palette_edited(self) -> bool:
        """Whether this project has saved colours of its own -- the global
        files or any level's."""
        return any(
            held.is_file()
            for held in self._palette_overlays() + self._level_palette_files()
        )

    def _level_palette_dir(self) -> Path:
        """Where the custom level palettes live: overlay files that shadow
        nothing, like the added containers."""
        return self.overlaid(self.base / LEVEL_PALETTES_DIR)

    def _level_palette_files(self) -> list[Path]:
        """Every saved level palette, in level order."""
        folder = self._level_palette_dir()
        if not folder.is_dir():
            return []
        return sorted(
            path for path in folder.glob("*.pal") if LEVEL_PALETTE_NAME.match(path.name)
        )

    def level_palettes(self) -> dict[int, bytes]:
        """The palettes this project's levels wear, by level number.

        Derived from the overlay rather than recorded, on the overlay's own
        principle; a file of the wrong size is refused by name rather than
        read into a patch that would misplace every colour after it.
        """
        out: dict[int, bytes] = {}
        for path in self._level_palette_files():
            data = path.read_bytes()
            if len(data) != level_palettes.SIZE:
                raise ProjectError(
                    f"{path.name} is {len(data):#x} bytes, and a level palette "
                    f"is {level_palettes.SIZE:#x}"
                )
            out[int(path.stem, 16)] = data
        return out

    def save_level_palettes(self, held: Mapping[int, bytes]) -> list[Path]:
        """Make ``held`` the saved level palettes, and say which files moved.

        The whole answer at once -- a level absent from ``held`` loses its
        file -- because the document is saved whole: which levels wear one is
        as much the state as what each one holds.

        The ``.pal`` blobs and the two fragments the build assembles them
        through move together: the pointer rows and the incbins are derived
        from exactly the set being saved, so writing them here is what keeps
        a build from ever seeing the two disagree
        (``Config/LevelCustomPalettes.asm``). A save back to no palettes
        takes the overlay fragments out too, and the disassembly's stock
        copies -- zero rows, no blobs -- answer again.

        Refused past the level bank's room -- :meth:`level_bank_spare` with
        this many blobs at the bank's head. The bank alone holds
        :data:`shiny_mushroom.level_palettes.CAPACITY`; one the expanded
        level memory has packed level streams into holds fewer, and a
        palette that would push those streams out of the bank is refused
        here rather than at the build.
        """
        for level, blob in held.items():
            level_palettes.check_level(level)
            level_palettes.check(blob)
        if self.level_bank_spare(len(held)) < 0:
            raise ProjectError(
                f"{len(held)} levels wear a custom palette, and the level "
                f"bank holds {self.level_palette_capacity()} beside the "
                f"level streams packed into it"
            )
        folder = self._level_palette_dir()
        touched: list[Path] = []
        wanted = {level_palettes.pal_name(level): blob for level, blob in held.items()}
        for name, blob in sorted(wanted.items()):
            path = folder / name
            if path.is_file() and path.read_bytes() == blob:
                continue
            folder.mkdir(parents=True, exist_ok=True)
            _write_atomic(path, blob)
            touched.append(path)
        fragments: dict[Path, str | None] = {
            level_palettes.POINTERS_FRAGMENT: None,
            level_palettes.DATA_FRAGMENT: None,
        }
        if held:
            fragments[level_palettes.POINTERS_FRAGMENT] = (
                level_palettes.pointer_fragment(held)
            )
            fragments[level_palettes.DATA_FRAGMENT] = level_palettes.data_fragment(held)
        touched.extend(self._sync_fragments(fragments))
        # Stale blobs go last, once everything the new state needs is on
        # disk: a save cut short mid-way then leaves extra files nothing
        # references -- which the next save removes -- rather than fragments
        # naming incbins that are gone, which is a build that fails.
        for path in self._level_palette_files():
            if path.name not in wanted:
                path.unlink()
                touched.append(path)
        if touched:
            self._write_metadata({"modified": _now()})
        return touched

    # -- the per-level graphics -----------------------------------------------

    @_remembered
    def level_graphics(self) -> dict[int, bytes]:
        """The graphics rows this project's levels carry, by level number --
        the eight bytes the ``level-graphics`` feature reads for each
        (:mod:`shiny_mushroom.level_graphics`) -- for every level whose row
        names a file.

        Read off the containers as the build would read them
        (:meth:`level_file`, then :meth:`source`): the row is the Layer 1
        container's, so the level numbers sharing a container -- ``$015``,
        ``$016`` and ``$017`` -- share a row, exactly as they share the
        level. What the build's derived fragment names
        (:func:`smw_tools.level_graphics.fragment_from_containers`).

        There is no cheap way of saying "no level has one" -- the row is in
        each level's own container, so the answer is a read of every
        container, about 600 ms on the DrvFs a Windows checkout is under --
        and a patch gather asks on every redraw, so it is remembered
        (:func:`_remembered`). Treat what comes back as read-only: every
        caller after the first shares it.
        """
        return level_graphics.rows_for(self._level_containers())

    def level_graphics_record(self, level: int) -> bytes:
        """``level``'s graphics row as its container holds it, or empty for
        none -- what a document is read with, ahead of the cartridge's own
        row. One level's answer through the same reader as the whole
        project's (:func:`shiny_mushroom.level_graphics.rows_for`), so the
        two cannot disagree about what a row is."""
        where = self.level_file(level)
        if where is None:
            return b""
        return level_graphics.rows_for({level: self.source(where.layer1)}).get(
            level, b""
        )

    def _level_containers(self) -> dict[int, Path]:
        """Every level number and the container its Layer 1 comes out of, as
        the build would read it -- the resolution the graphics rows are read
        through."""
        return {
            level: self.source(where.layer1)
            for level, where in self.level_map().items()
        }

    # -- the Map16 tables -----------------------------------------------------

    def map16_tables(self) -> map16.Map16Tables:
        """Every Map16 table the build would include, held for editing --
        this project's copy of a file where it has saved one, the
        disassembly's otherwise, and the castle file this target's build
        includes. See :mod:`shiny_mushroom.map16`.
        """
        return map16.Map16Tables.load(
            self.base,
            self.overlay / self.base.name,
            castle=map16.castle_file(self.target.romid),
        )

    def save_map16(self, tables: map16.Map16Tables) -> list[Path]:
        """Write the held tables into the overlay, and say which files moved.

        Each table is a fixed-size plain ``incbin``, so :meth:`_save_plain`'s
        exact-size check is the whole room check, exactly as it is for a
        palette file. A file equal to the disassembly's leaves no copy -- it
        is taken out of the overlay instead, so the overlay stays the diff --
        and a file the overlay already holds as saved is left alone.
        """
        touched: list[Path] = []
        for name in map16.FILES:
            relative = map16.DIRECTORY / f"{name}.bin"
            held = self.overlaid(self.base / relative)
            stock = (self.base / relative).read_bytes()
            data = tables.file(name)
            if data == stock:
                if held.is_file():
                    held.unlink()
                    touched.append(held)
                continue
            if held.is_file() and held.read_bytes() == data:
                continue
            touched.append(self._save_plain(relative, data, len(stock)))
        tables.mark_saved()
        if touched:
            self._write_metadata({"modified": _now()})
        return touched

    def revert_map16(self) -> list[Path]:
        """Put every Map16 table back to the disassembly's, and say what was
        removed. Deleting the files is the revert."""
        gone = [held for held in self._map16_overlays() if held.is_file()]
        for held in gone:
            held.unlink()
        if gone:
            self._write_metadata({"modified": _now()})
        return gone

    def _map16_overlays(self) -> list[Path]:
        return [
            self.overlaid(self.base / map16.DIRECTORY / f"{name}.bin")
            for name in map16.FILES
        ]

    @property
    @_remembered
    def map16_edited(self) -> bool:
        """Whether this project has saved Map16 tables of its own -- a `stat`
        per file of the set, so remembered (:func:`_remembered`)."""
        return any(held.is_file() for held in self._map16_overlays())

    @property
    def patches_dir(self) -> Path:
        """Where this project keeps its asm patches -- beside the overlay,
        not in it. The overlay is the diff against the disassembly, copied
        verbatim into the build tree; a patch is project metadata the build
        *compiles* into the tree, the way the raw resources are.
        """
        return self.root / PATCHES_DIR

    @property
    def patch_state(self) -> tuple[tuple[str, ...], tuple[str, ...]]:
        """The patch manifest: ``(order, enabled)``, unvalidated and tolerant.

        ``order`` is the stable apply-and-display order; ``enabled`` the
        subset that is on, an unordered set held as a list. Tolerant the way
        every metadata reader here is -- a hand-edited file must not stop a
        project from opening -- and unvalidated deliberately:
        :func:`shiny_mushroom.patches.user_patches` is what reconciles the
        names against the files that actually exist.
        """
        held = self.metadata.get("patches", {})
        if not isinstance(held, dict):
            return ((), ())
        return _string_list(held.get("order")), _string_list(held.get("enabled"))

    def set_patch_state(self, order: Iterable[str], enabled: Iterable[str]) -> None:
        """Record the patch manifest."""
        self._write_metadata(
            {
                "patches": {"order": list(order), "enabled": list(enabled)},
                "modified": _now(),
            }
        )

    @property
    def feature_state(self) -> tuple[str, ...]:
        """The features this project has **asked for**, as ids into
        :data:`smw_tools.features.FEATURES`.

        Not :attr:`features`, which is what the cartridge on disk *has*: this
        is a switch someone threw, and it reaches the cartridge at the next
        build. The two part company for exactly as long as a build is owed,
        which is the same gap a toggled patch opens.

        Only a feature the disassembly carries behind a define can be here --
        one the base is built with, or one a patch writes in, arrives whole
        and has no switch (:attr:`smw_tools.features.Feature.switchable`).
        Tolerant and unvalidated like every metadata reader here; what an id
        *means* is checked by :mod:`shiny_mushroom.features`, which is what
        turns one on.
        """
        held = self.metadata.get("features", {})
        if not isinstance(held, dict):
            return ()
        return tuple(
            dict.fromkeys(
                MERGED_FEATURES.get(one, one)
                for one in _string_list(held.get("enabled"))
            )
        )

    def set_feature_state(self, ids: Iterable[str]) -> None:
        """Record which features this project asks its build for."""
        self._write_metadata(
            {
                "features": {"enabled": list(dict.fromkeys(ids))},
                "modified": _now(),
            }
        )

    @property
    def build_needed(self) -> tuple[str, ...]:
        """The parts whose edits outgrew the slots an in-place patch can
        fill -- names for a status line, empty when everything previews.

        A saved part always *builds* correctly -- asar re-places what grew,
        and the ROM map's placement guard refuses a collision loudly -- but a test
        run patches the open cartridge in place, so a part past its slot
        shows the cartridge's own bytes until the project is rebuilt and the
        built image reopened. Recomputed by whoever gathers the patches, and
        persisted so the reading survives the session.
        """
        return _string_list(self.metadata.get("needs_build"))

    def note_build_needed(self, parts: Iterable[str]) -> None:
        """Record which parts need a build to preview: the whole reading, so
        an empty one clears it."""
        kept = tuple(dict.fromkeys(str(part) for part in parts))
        if kept == self.build_needed:
            return
        self._write_metadata({"needs_build": list(kept), "modified": _now()})

    # -- editable asm regions -------------------------------------------------

    def asm_rows(self, region_id: str):
        """A region's rows as the build would read them: the overlay's fragment
        if this project saved one, the disassembly's otherwise.

        The model is whatever the region's codec speaks -- see
        :mod:`smw_tools.asm_regions`. A hand-edited overlay fragment that has
        left the emitter's grammar raises
        :class:`~smw_tools.asm_codec.AsmRegionError` naming the file and
        line, which the caller surfaces rather than guessing around.
        """
        region = self._applicable_region(region_id)
        return region.parse(self._region_text(region), self.cartridge_base)

    @_scanned
    def _region_text(self, region: asm_codec.AsmRegion) -> str:
        """``region``'s fragment as the build would assemble it: every file
        it spans, each the overlay's where this project saved one and the
        disassembly's otherwise, joined in ROM order. A region of one file is
        that file; one split an entry a file (the messages) reads as the
        index splices it, so a shadowed entry sits among unshadowed ones.

        **Read once inside a :func:`scanning_once` block and no longer**
        (:func:`_scanned`), because half of what it reads is the overlay and
        a hand edit lands there without this process writing anything. What
        the block buys is the repetition: pricing one fragment reads every
        other member of the run it shares, so a pass over all twenty-one
        regions asks for the same handful of fragments dozens of times, and
        on a checkout under a mounted Windows drive a read is milliseconds.
        Outside a block every caller reads the disk, which is the answer that
        cannot be stale.
        """
        return region.read(
            lambda path: self.source(self.base / path).read_text("utf-8")
        )

    def _region_overlays(self, region: asm_codec.AsmRegion) -> list[Path]:
        """Every overlay file ``region`` owns, held or not: its declared
        files, plus any the overlay holds of its shape -- a grown region's
        added entries, which no declaration lists."""
        declared = [self.overlaid(self.base / path) for path in region.files]
        if region.fixed_files:
            # Nothing else can be the region's, so the walk could only turn
            # up files already listed -- and it is a directory walk and a
            # stat a file, once per region, on the pass that asks all
            # twenty-one whether they are edited.
            return declared
        folder = self.overlaid(self.base / region.path.parent)
        found = [
            path
            for path in (sorted(folder.rglob("*")) if folder.is_dir() else ())
            if path.is_file()
            and region.owns(path.relative_to(self.overlaid(self.base)))
            and path not in declared
        ]
        return declared + found

    def _applicable_region(
        self, region_id: str, base: RomBase | None = None
    ) -> asm_codec.AsmRegion:
        """The region, or a refusal for a target whose build routes around
        its fragment -- an overlay written there would be silently ignored,
        the stock-build failure the overlay must never allow."""
        region = asm_regions.region_for(region_id, base or self.cartridge_base)
        if not region.applies_to(self.target_id):
            raise asm_codec.AsmRegionError(
                f"{region_id} does not apply to target {self.target_id}: "
                f"its build assembles a different payload"
            )
        return region

    def save_asm_regions(
        self,
        models: dict[str, object],
        runs: dict[str, asm_room.Run],
        base: RomBase | None = None,
    ) -> list[Path]:
        """Write asm regions into the overlay: every region given, or nothing.

        ``runs`` is per region the run of ROM the project's own build put its
        fragment in, and who else is in it --
        :func:`shiny_mushroom.build.asm_runs` reads that out of the build's
        symbol file. Every region is emitted (and so priced) before anything
        is written, which is what makes a refused save not a save without any
        rollback: :class:`~smw_tools.asm_codec.AsmRegionFull` can only be
        raised while the overlay is still untouched.

        A region whose rows equal the disassembly's is *reverted* rather than
        written -- the overlay is the diff, and an edit that puts the stock
        rows back is not a diff worth keeping. Only the regions that differ
        are emitted, so only those need a run.

        ``base`` is the cartridge the fragment is being written *for*,
        defaulting to :attr:`cartridge_base` -- which is what every save
        means. It is passed only while a feature is being switched: the
        project is then between two cartridges, and the overlay has to be
        re-fitted to the one it is going to rather than to the one its last
        build produced (:mod:`shiny_mushroom.features`).
        """
        return self._write_asm_regions(self._emit_asm_regions(models, runs, base))

    def _emit_asm_regions(
        self,
        models: dict[str, object],
        runs: dict[str, asm_room.Run],
        base: RomBase | None = None,
    ) -> list[tuple[asm_codec.AsmRegion, dict[Path, str] | None]]:
        """Price every region, and say what each one would be written as.

        ``None`` for a region whose rows are the disassembly's own: that is a
        revert rather than a write, and it needs no run.

        **Pure**: nothing has moved when this returns and nothing has moved
        when it raises, which is what lets a save that will not fit be refused
        whole. :meth:`save_world_map` calls this before it writes its own parts
        for exactly that reason, and hands what comes back to
        :meth:`_write_asm_regions` afterwards rather than emitting a second
        time. The hand-edit check belongs here for the same reason: the write
        runs last, after the raw and plain parts have landed, so a refusal
        there would leave those written.
        """
        for_cart = base if base is not None else self.cartridge_base
        emitted: list[tuple[asm_codec.AsmRegion, dict[Path, str] | None]] = []
        wrote: dict[str, int] = {}
        reverted: dict[str, int] = {}
        for region_id, model in models.items():
            region = self._applicable_region(region_id, for_cart)
            self._check_readable(region_id, region, for_cart)
            stock = self.asm_region_stock(region_id, for_cart)
            if model == stock:
                emitted.append((region, None))
                # Priced all the same: its overlay fragment is about to be
                # deleted, so what it takes of a run it shares is the
                # disassembly's rows and not the ones still on disk.
                reverted[region_id] = region.fits(model, None)
                continue
            if region_id not in runs:
                raise ProjectError(
                    f"saving {region_id} needs its run -- "
                    "see shiny_mushroom.build.asm_runs"
                )
            # Emitted unpriced, then priced by the run below: a fragment that
            # shares one is bounded by what the others leave, and that is not a
            # number this can ask of the fragment alone. Handed the stock rows
            # so a region of several files writes the ones that differ.
            emitted.append((region, region.emit_files(model, None, for_cart, stock)))
            wrote[region_id] = region.fits(model, None)
        self._price_runs(wrote, reverted, runs, for_cart)
        return emitted

    def _price_runs(
        self,
        wrote: dict[str, int],
        reverted: dict[str, int],
        runs: dict[str, asm_room.Run],
        base: RomBase,
    ) -> None:
        """Refuse a save whose fragments no longer fit the runs they share.

        Priced per **run** and not per fragment. Two that share one may each fit
        on its own and not together, which is the whole of what a shared run
        means -- and a fragment nothing is saving still occupies its rows, so
        the members left alone are counted at what the project holds for them.

        **What this save is giving back counts too.** A member of the same save
        whose rows went back to the disassembly's is a revert rather than a
        write, so it is not in ``wrote`` -- and reading it off disk would price
        it at the overlay fragment the write is about to delete. A save that
        shrinks one member to stock while growing another would be refused for
        room it is handing over in the same breath.
        """
        held = {**reverted, **wrote}
        for region_id in wrote:
            run = runs[region_id]
            used = dict(held)
            for member in run.members:
                if member in used:
                    continue
                other = self._applicable_region(member, base)
                used[member] = other.fits(
                    other.parse(self._region_text(other), base), None
                )
            spare = run.spare(used)
            if spare < 0:
                needed = sum(used.get(m, 0) for m in run.members)
                changed = ", ".join(sorted(set(wrote) & set(run.members)))
                # What the members may have, so the run's reservation comes off
                # it -- `spare` subtracts that too, and a room that did not
                # would report an overflow smaller than the reservation as a
                # negative number of bytes to take back out.
                raise asm_codec.AsmRegionFull(changed, needed, run.size - run.reserved)

    def _check_readable(
        self,
        region_id: str,
        region: asm_codec.AsmRegion,
        base: RomBase | None = None,
    ) -> None:
        """Refuse to write over a fragment the editor can no longer read.

        Only an overlay fragment can be hand-edited -- the base tree's own is
        the disassembly's and this project never writes there -- so a region
        with nothing in the overlay is always writable.
        """
        held = [path for path in self._region_overlays(region) if path.is_file()]
        if not held:
            return
        try:
            region.parse(self._region_text(region), base or self.cartridge_base)
        except asm_codec.AsmRegionError as error:
            raise HandEditedRegion(region_id, held[0], str(error)) from error

    def _write_asm_regions(
        self, emitted: list[tuple[asm_codec.AsmRegion, dict[Path, str] | None]]
    ) -> list[Path]:
        """Write what :meth:`_emit_asm_regions` priced, and say which files
        moved. Infallible by then: the pricing is where a save is refused.

        A region's files not among the emitted ones are the disassembly's --
        a revert whole, the entries of a split region that came back to
        stock, or the added entries of a grown one that shrank -- and any
        overlay copy of them goes, for the same reason a stock save is a
        delete: the overlay is the diff."""
        written: list[Path] = []
        touched = False
        for region, texts in emitted:
            kept = (
                set()
                if texts is None
                else {self.overlaid(self.base / path) for path in texts}
            )
            for destination in self._region_overlays(region):
                if destination not in kept and destination.is_file():
                    destination.unlink()
                    touched = True
            if texts is None:
                continue
            for path, text in texts.items():
                destination = self.overlaid(self.base / path)
                destination.parent.mkdir(parents=True, exist_ok=True)
                _write_atomic(destination, text)
                written.append(destination)
                touched = True
        if touched:
            self._write_metadata({"modified": _now()})
        return written

    def save_asm_region(
        self,
        region_id: str,
        model: object,
        run: asm_room.Run,
        base: RomBase | None = None,
    ) -> list[Path]:
        """One region of :meth:`save_asm_regions`."""
        return self.save_asm_regions({region_id: model}, {region_id: run}, base)

    def revert_asm_region(self, region_id: str) -> Path | None:
        """Take one region's edit back out of the overlay. Deleting the
        fragment is the revert, exactly as it is for a level."""
        region = asm_regions.declared_region(region_id)
        held = [path for path in self._region_overlays(region) if path.is_file()]
        if not held:
            return None
        for path in held:
            path.unlink()
        self._write_metadata({"modified": _now()})
        return held[0]

    def asm_region_edited(self, region_id: str) -> bool:
        """Whether this project has saved ``region_id``."""
        # The declared lookup: edited-ness is a fact about the overlay file,
        # and a feature's own region still names its fragment on a cartridge
        # without the feature -- where the answer is simply "no".
        region = asm_regions.declared_region(region_id)
        if not region.applies_to(self.target_id):
            return False
        return any(path.is_file() for path in self._region_overlays(region))

    def asm_region_stock(self, region_id: str, base: RomBase | None = None):
        """A region's rows as the disassembly ships them, the overlay ignored
        -- what a model is compared against to decide whether a save is an
        edit at all. ``None`` when the base tree does not carry the fragment:
        a minimal base has nothing to edit, and nothing to compare against --
        as does a region whose fragment this project's target never
        assembles.

        ``base`` is the cartridge to read them as, defaulting to this
        project's own -- see :meth:`save_asm_regions` for the one caller that
        passes another."""
        for_cart = base if base is not None else self.cartridge_base
        try:
            region = asm_regions.region_for(region_id, for_cart)
        except asm_codec.AsmRegionError:
            # A feature's own region on a cartridge without the feature --
            # nothing assembles the fragment, so there is nothing to edit.
            return None
        if not region.applies_to(self.target_id):
            return None
        try:
            text = asm_room.tree_text(region, self.base)
        except OSError:
            # The base tree does not carry the fragment -- a minimal base has
            # nothing to edit and nothing to compare against.
            return None
        return region.parse(text, for_cart)


def projects(root: Path | None = None) -> list[Project]:
    """Every project in the projects directory, by name.

    **Each carries the base, target and size it actually records**, read out of its
    own ``project.json`` rather than left at the default. A listing that showed
    every project as ``vanilla/U`` would be wrong about exactly the thing a
    listing is for, and a caller that opened one from here would build it
    against the wrong tree.

    Unlike :meth:`Project.open`, a base this build does not have is **not**
    refused here: a list is a description, and a project that cannot be opened
    is still one that exists and is worth saying so about. :attr:`buildable` is
    the question, and the refusal stays where opening happens.
    """
    folder = root or projects_root()
    if not folder.is_dir():
        return []
    return [
        Project(root=entry)._with_stored_ids()
        for entry in sorted(folder.iterdir())
        if (entry / PROJECT_FILE).is_file()
    ]


def unused_name(root: Path | None = None, base: str = DEFAULT_NAME) -> str:
    """A project name nothing is using yet: ``new-shiny``, then ``new-shiny-2``."""
    folder = root or projects_root()
    return numbered_unique(base, lambda name: (folder / name).exists())


#: How many numbered variants :func:`numbered_unique` tries. Far past what
#: anyone reaches by hand, and a bound rather than a policy: the alternative is
#: a loop with no end.
NUMBERED_LIMIT = 1000


def numbered_unique(base: str, taken: Callable[[str], bool]) -> str:
    """``base``, or the first free ``base-2``, ``base-3``, ... .

    The rule project names and patch ids share, because they are the same rule:
    a filename on every platform (:data:`NAME_PATTERN`), made unique against
    what is already there so adding never overwrites. ``base`` is trimmed to 60
    characters before a suffix goes on it, which is what keeps the answer inside
    the 64 the pattern allows.

    **Exhaustion raises**, naming the base -- a thousand names all taken is a
    real condition and deserves to be said. A caller with an exception of its
    own translates it; running off the end of a generator is not a report.
    """
    if not taken(base):
        return base
    for n in range(2, NUMBERED_LIMIT):
        candidate = f"{base[:60]}-{n}"
        if not taken(candidate):
            return candidate
    raise ProjectError(f"a thousand names beginning {base!r} are already taken")
