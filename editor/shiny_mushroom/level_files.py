"""Every level container in the tree, as rows a viewer can show.

The disassembly stores levels as 245 ``.mwl`` containers for 512 level numbers,
so **the container is the unit of level data and the level number is only a
route to one** -- three numbers can read the same container, and a level's two
streams can come out of two different files. A list of levels therefore shows
the same bytes many times over and never says so; this module builds the list
the other way round, one row per container, saying what is in it, what it costs
in ROM, and which level numbers reach it.

Everything here is read through the same functions the loader and the save path
use -- :mod:`smw_tools.levels` for the three-hop resolution and
:mod:`shiny_mushroom.mwl` for the container itself -- so the rows cannot drift
from what a build would do. ``source`` is
:meth:`~shiny_mushroom.project.Project.source`, which is what makes an edited
project's sizes the edit's rather than the checkout's.

The other direction is here too, and for the same reason: the container is the
more useful of a level's two names, so :func:`container_names` and
:func:`level_choices` build the rows every picker in the editor offers a level
as -- ``$009   Level009_DonutPlains2_Main`` -- and :func:`numbered_levels` the
bare numbers a picker falls back to with no tree read yet.
"""

from __future__ import annotations

from collections import Counter
from collections.abc import Callable, Iterable, Mapping
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from functools import cache
from pathlib import Path

from shiny_mushroom import mwl
from shiny_mushroom.fields import Choice
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level_pointers import added_insertions
from smw_tools.bases import BuildTarget
from smw_tools.levels import (
    EMPTY_STREAM_SIZES,
    LEVEL_COUNT,
    LEVELS_DIR,
    Insertion,
    LevelFile,
    containers,
    level_regions,
    stream_definitions,
)

#: Containers opened at once when a listing reads all 245 of them.
#:
#: The reads are independent and the work is not the bytes: 245 containers are
#: 683 KiB and parse in under a millisecond, while *opening* them one at a time
#: over a Windows drive mounted into WSL costs the best part of a second --
#: reading only the first 256 bytes of each costs the same, because the price
#: is the open. Threads are the fit: every one of them is blocked in a syscall
#: rather than holding the GIL. Four is where the curve has already flattened
#: to within a few tens of milliseconds of its floor, and it is a number a
#: laptop can spare.
READ_WORKERS = 4

#: The insertion kinds a container can be read for, in the framework's own
#: spelling, and which of the container's regions each pulls.
_KINDS = {"LAYER_1": mwl.LAYER1, "LAYER_2": mwl.LAYER2, "SPRITES": mwl.SPRITES}


@dataclass(frozen=True)
class ContainerUse:
    """One level number that reads a container, and for which of its streams.

    Both flags as a rule -- most levels are one file -- and one of them for the
    forty-five levels whose Layer 1 and sprites come out of different files.
    """

    level: int
    layer1: bool
    sprites: bool

    @property
    def partial(self) -> bool:
        return not (self.layer1 and self.sprites)


@dataclass(frozen=True)
class ContainerNames:
    """The containers one level number reads, named as the files are.

    The other direction from :class:`ContainerUse`: a level asking which files
    it comes out of rather than a file listing who reads it. Two fields for
    the forty-five levels whose Layer 1 and sprites come out of different
    containers -- for every other level they are the same name twice.
    """

    layer1: str
    sprites: str

    @property
    def split(self) -> bool:
        """Whether the two streams come out of different containers."""
        return self.layer1 != self.sprites


@dataclass(frozen=True)
class CarriedRegion:
    """One slot the build never inserts, and how many bytes it takes up.

    Lunar Magic writes all eight slots whether or not the disassembly reads
    them, so every container carries a palette, an entrance list and the rest
    (:data:`~shiny_mushroom.mwl.CARRIED`). Saying so is worth a line: the bytes
    are real, a save keeps them, and a container imported from somewhere else
    is where they stop being the cart's own.
    """

    slot: int
    name: str

    #: The bytes the container gives the slot, its own leading bytes included.
    size: int


@dataclass(frozen=True)
class LevelFileRow:
    """One ``.mwl`` container: what it holds, what it costs, who reads it."""

    #: The container's name -- its filename without the extension.
    name: str

    #: The level number Lunar Magic stamped the file with
    #: (:attr:`~shiny_mushroom.mwl.Container.recorded_level`), or ``None`` for
    #: a container too strange to say. A record rather than a binding: the
    #: pointer tables are what connect containers to levels, and the two can
    #: disagree.
    recorded_level: int | None

    #: How many bytes each stream puts into the ROM, or ``None`` for a stream
    #: no bank inserts -- the container still holds one, but the build never
    #: reads it, so it has no size *in ROM* to report.
    layer1_size: int | None
    sprite_size: int | None
    layer2_size: int | None

    #: Every byte the build pulls out of this container, duplicates included:
    #: a container inserted twice pays twice.
    rom_size: int

    #: The level-data regions the streams land in, by macro name.
    regions: tuple[str, ...]

    #: Every level number that reads the container, in order.
    used_by: tuple[ContainerUse, ...]

    #: The slots the build never inserts, with their sizes -- empty for a
    #: container that could not be read.
    carries: tuple[CarriedRegion, ...]

    #: Whether the Layer 1 flag claims the palette the container carries.
    custom_palette: bool

    #: How many secondary entrances Lunar Magic recorded in the file.
    secondary_entrances: int

    #: Whether the container carries ExAnimation data.
    exanimation: bool

    #: Whether the container is one the *project* added rather than the
    #: checkout's -- an overlay file that shadows nothing, whose streams the
    #: managed level banks pack after the game's own.
    added: bool = False

    #: Every label the level banks define over one of this container's
    #: streams, spelled as the definitions are, and the ones among them the
    #: project has deleted -- each of which inserts the empty level instead
    #: of its stream, and :attr:`rom_size` says what that costs.
    labels: tuple[str, ...] = ()
    deleted_labels: tuple[str, ...] = ()

    #: Whether the overlay holds a copy of this checkout container -- a saved
    #: edit, which is what a revert takes back out.
    edited: bool = False

    @property
    def deleted(self) -> bool:
        """Whether every label over the container is deleted: none of its
        bytes reach the ROM. Hidden by default in the viewer, and what makes
        a row restorable as a whole."""
        return bool(self.labels) and len(self.deleted_labels) == len(self.labels)

    @property
    def partly_deleted(self) -> bool:
        """Whether some but not all of its labels are deleted -- a Layer 2
        gone while the layout stays, say. Listed like any other row, priced
        for what is left."""
        return 0 < len(self.deleted_labels) < len(self.labels)

    @property
    def extras(self) -> tuple[str, ...]:
        """The carried data that a reader of the file would act on, phrased.

        Not everything in :attr:`carries`: every container is written with a
        palette region and a set of ExGFX words, so listing those on every row
        would say nothing. What is left is what differs -- a palette the level
        actually claims, entrances it records, ExAnimation it brought with it
        -- and in the shipped tree that is a secondary entrance or two on a
        handful of files, and nothing else at all.
        """
        notes = []
        if self.custom_palette:
            notes.append("custom palette")
        if self.secondary_entrances:
            count = self.secondary_entrances
            notes.append(f"{count} secondary entrance" + ("s" if count > 1 else ""))
        if self.exanimation:
            notes.append("ExAnimation")
        return tuple(notes)

    @property
    def agrees(self) -> bool:
        """Whether the recorded level number is one of the levels that read the
        file. False is a real fact about the cart worth surfacing, not an
        error: five shipped files disagree. A container no pointer table reads
        -- Chocolate Island 2's sub-levels resolve dynamically -- has nothing
        to disagree with."""
        return (
            self.recorded_level is None
            or not self.used_by
            or any(use.level == self.recorded_level for use in self.used_by)
        )


def container_names(
    base: Path,
    target: BuildTarget | None = None,
    placed: dict[int, LevelFile] | None = None,
) -> dict[int, ContainerNames]:
    """Which containers each level number reads, by level number.

    What a level picker needs to say which file it is about to open: the
    container is the unit of level data, so its name is the more useful of the
    two names a level has, and the tree names most of them for the place they
    are rather than for a number.

    ``placed`` is the resolution to read -- a project's
    :meth:`~shiny_mushroom.project.Project.level_map`, whose remapped levels
    would otherwise be named for the checkout's containers -- and defaults to
    the checkout's own.
    """
    if placed is None:
        placed = containers(base, target)
    return {
        level: ContainerNames(where.layer1.stem, where.sprites.stem)
        for level, where in placed.items()
    }


def level_choices(names: Mapping[int, ContainerNames]) -> tuple[Choice, ...]:
    """Every level as a picker's option: its number, and the container it comes
    out of beside it.

    The rows the level bar's own picker is filled from
    (:mod:`shiny_mushroom.ui.level_bar`), as a Qt-free list -- so anything else
    that asks the user for a level offers the same list, found the same way.
    Typing "donut" reaches ``$009`` through ``Level009_DonutPlains2_Main``,
    wherever the question is asked.

    A container still named for its number is left as no detail at all: the
    tree names most of its files for the place they are, and the ones that do
    not would put ``$001   001`` in the list -- a column of the row repeating
    itself.
    """
    return tuple(
        Choice(level, hexnum(level, 3), _container_detail(names.get(level), level))
        for level in range(LEVEL_COUNT)
    )


@cache
def numbered_levels() -> tuple[Choice, ...]:
    """Every level as a bare number, for a picker with nothing to name them by.

    What a picker offers before a cartridge's tree has been read -- and in a
    test, which has no tree at all. Built once: it is the same 512 rows every
    time, and :func:`~shiny_mushroom.ui.properties.field_widget` keys its
    shared list model on the tuple.
    """
    return tuple(Choice(level, hexnum(level, 3)) for level in range(LEVEL_COUNT))


def _container_detail(names: ContainerNames | None, level: int) -> str:
    if names is None or names.layer1 == f"{level:03X}":
        return ""
    return names.layer1


def level_file_rows(
    base: Path,
    target: BuildTarget | None = None,
    source: Callable[[Path], Path] | None = None,
    placed: dict[int, LevelFile] | None = None,
    added: tuple[str, ...] = (),
    deleted: tuple[str, ...] = (),
    edited: tuple[str, ...] = (),
) -> list[LevelFileRow]:
    """One row per container the tree reads, in name order.

    ``base`` is the game folder and ``target`` the release being asked about,
    exactly as :func:`smw_tools.levels.level_file` takes them. ``source`` maps
    a base-tree path to the file the build would read -- a project's overlay
    lens -- and defaults to the path itself. ``placed`` is the level-number
    resolution on :func:`container_names`' terms: a project's remapped tables
    move numbers between rows, and the rows have to say so. ``added`` is the
    containers the project itself brings
    (:meth:`~shiny_mushroom.project.Project.added_level_files`), which the
    bank macros never insert: each gets a row counting its two streams once,
    which is what the added-files fragment inserts. ``deleted`` is the labels
    the project has deleted
    (:meth:`~shiny_mushroom.project.Project.deleted_level_labels`), each of
    whose insertions costs the empty level, and ``edited`` the containers the
    overlay holds a copy of.
    """
    through = source if source is not None else lambda path: path
    if placed is None:
        placed = containers(base, target)

    used: dict[str, dict[int, list[bool]]] = {}
    for level, where in placed.items():
        for path, slot in ((where.layer1, 0), (where.sprites, 1)):
            flags = used.setdefault(path.stem, {}).setdefault(level, [False, False])
            flags[slot] = True

    inserted: dict[str, list[Insertion]] = {}
    regions: dict[str, set[str]] = {}
    for region in level_regions(base, target):
        for insertion in region.insertions:
            inserted.setdefault(insertion.container, []).append(insertion)
            regions.setdefault(insertion.container, set()).add(region.name)
    for insertion in added_insertions(added):
        inserted.setdefault(insertion.container, []).append(insertion)

    labels: dict[str, list[str]] = {}
    for label, definition in stream_definitions(base, target).items():
        labels.setdefault(definition.container, []).append(label)
    gone = set(deleted)

    names = sorted(used.keys() | inserted.keys())
    paths = {name: through(base / LEVELS_DIR / f"{name}.mwl") for name in names}
    read = _read_containers(paths.values())

    rows = []
    for name in names:
        held = tuple(sorted(labels.get(name, ())))
        rows.append(
            _row(
                name,
                read[paths[name]],
                tuple(inserted.get(name, ())),
                tuple(sorted(regions.get(name, ()))),
                used.get(name, {}),
                gone,
                labels=held,
                deleted_labels=tuple(label for label in held if label in gone),
                added=name in added,
                edited=name in edited,
            )
        )
    return rows


def _read_containers(paths: Iterable[Path]) -> dict[Path, mwl.Container | None]:
    """Every container at ``paths``, read :data:`READ_WORKERS` at a time.

    ``None`` for one that could not be read or parsed -- a container the tree
    names but a broken checkout does not hold. Caught per path rather than for
    the batch, so one bad file costs its own row's sizes and not the listing.

    The rows themselves are still built in name order off this map: the
    concurrency is in the waiting, and nothing a reader sees depends on which
    read finished first.
    """

    def one(path: Path) -> mwl.Container | None:
        try:
            return mwl.Container.read(path.read_bytes())
        except (OSError, mwl.MwlError):
            return None

    held = list(dict.fromkeys(paths))
    with ThreadPoolExecutor(READ_WORKERS) as pool:
        return dict(zip(held, pool.map(one, held), strict=True))


def _row(
    name: str,
    container: mwl.Container | None,
    inserted: tuple[Insertion, ...],
    regions: tuple[str, ...],
    users: dict[int, list[bool]],
    gone: set[str],
    labels: tuple[str, ...] = (),
    deleted_labels: tuple[str, ...] = (),
    added: bool = False,
    edited: bool = False,
) -> LevelFileRow:
    """One row. ``container`` is ``None`` for a file the tree names but cannot
    be read -- a row with no sizes says more than a viewer that refuses to
    open -- which is what :func:`_read_containers` puts there."""
    kinds = Counter(insertion.kind for insertion in inserted)

    def size(kind: str) -> int | None:
        if container is None or not kinds[kind]:
            return None
        slot = _KINDS[kind]
        return len(container.payload(slot)) if slot < len(container.regions) else None

    sizes = {kind: size(kind) for kind in _KINDS}
    carried = () if container is None else _carried(container)
    # A deleted label's insertion costs the empty level, whatever the file
    # holds: that is what the build inserts under it.
    rom_size = sum(
        EMPTY_STREAM_SIZES[one.kind] if one.label in gone else (sizes[one.kind] or 0)
        for one in inserted
    )
    return LevelFileRow(
        name=name,
        recorded_level=None if container is None else container.recorded_level,
        layer1_size=sizes["LAYER_1"],
        sprite_size=sizes["SPRITES"],
        layer2_size=sizes["LAYER_2"],
        rom_size=rom_size,
        regions=regions,
        used_by=tuple(
            ContainerUse(level=level, layer1=flags[0], sprites=flags[1])
            for level, flags in sorted(users.items())
        ),
        carries=carried,
        custom_palette=container is not None and container.custom_palette,
        secondary_entrances=0 if container is None else container.secondary_entrances,
        exanimation=container is not None and container.has_exanimation,
        added=added,
        labels=labels,
        deleted_labels=deleted_labels,
        edited=edited,
    )


def _carried(container: mwl.Container) -> tuple[CarriedRegion, ...]:
    """The slots the build never inserts, skipping any the file stops short of."""
    carried = []
    for slot in mwl.CARRIED:
        size = container.region_size(slot)
        if size is not None:
            carried.append(
                CarriedRegion(slot=slot, name=mwl.SLOT_NAMES[slot], size=size)
            )
    return tuple(carried)
