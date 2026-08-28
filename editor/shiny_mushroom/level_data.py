"""The level numbers and the level labels as rows, beside the containers.

Level data reaches the ROM in three hops (:mod:`smw_tools.levels`): a **level
number** is an entry in each pointer table naming a **label**, the label is
defined above one **container**'s stream in the level banks, and the container
is the ``.mwl`` file the bytes come out of. :mod:`shiny_mushroom.level_files`
builds the third hop as rows; this module builds the first two, so the Level
Data window can show each hop as a tab and a reader can follow a number to its
file or a file back to its numbers.

Everything is read off the same tables and definitions the loader resolves
through -- a project's own pointer tables where it has remapped one, and
:func:`smw_tools.levels.stream_definitions` for what each label reaches -- so
a row can never say something a build would not do. No Qt.
"""

from __future__ import annotations

from collections.abc import Collection, Mapping, Sequence
from dataclasses import dataclass
from pathlib import Path

from shiny_mushroom.layer2_table import Layer2Entry, Layer2Table
from shiny_mushroom.level_files import LevelFileRow
from shiny_mushroom.level_pointers import StreamTarget, added_insertions
from shiny_mushroom.memory_map import LevelBudgets
from smw_tools.bases import BuildTarget
from smw_tools.levels import (
    LAYER_1,
    LAYER_2,
    NAMESPACE,
    SPRITES,
    level_regions,
    stream_definitions,
    undecorated,
)

#: How the three stream kinds read in a column.
KIND_NAMES = {LAYER_1: "Layer 1", LAYER_2: "Layer 2", SPRITES: "Sprites"}


@dataclass(frozen=True)
class LevelNumberRow:
    """One of the 512 level numbers: what its three entries name, and what
    each of them makes the number read."""

    level: int

    #: The Layer 1 and sprite entries as the tables spell them, and the
    #: container each resolves to -- ``None`` for an entry naming a label no
    #: bank defines, which is what a hand-hacked table leaves behind.
    layer1_label: str
    layer1_file: str | None
    sprites_label: str
    sprites_file: str | None

    #: The Layer 2 entry, or ``None`` on a tree whose table stops short of
    #: this number, and the container behind it -- ``None`` for a background,
    #: which has no container, and for an unresolved label.
    layer2: Layer2Entry | None
    layer2_file: str | None

    #: Every *other* level number reading either of this one's two files:
    #: what a save under this number changes besides itself.
    shares_with: tuple[int, ...]

    #: Whether the project's tables point this number somewhere the
    #: checkout's do not.
    remapped: bool = False

    @property
    def placed(self) -> bool:
        """Whether both entries resolve, which is what a load needs."""
        return self.layer1_file is not None and self.sprites_file is not None

    @property
    def split(self) -> bool:
        """Whether the two streams come out of different containers."""
        return self.placed and self.layer1_file != self.sprites_file


@dataclass(frozen=True)
class LevelLabelRow:
    """One label a pointer entry may name: which container's which stream it
    reaches, where the build puts it, and who names it."""

    #: The label as the pointer tables spell it -- the banks' own with the
    #: ``SMW_`` namespace, an added file's bare.
    label: str

    #: :data:`~smw_tools.levels.LAYER_1`, :data:`~smw_tools.levels.LAYER_2`
    #: or :data:`~smw_tools.levels.SPRITES`.
    kind: str

    #: The container the stream is pulled out of.
    container: str

    #: The bank macro the stream is emitted inside -- what the ROM map places
    #: -- or empty for a label nothing places: an added file's, packed by the
    #: managed banks' close, or one on a tree with no map.
    region: str

    #: Every level number whose entry in any of the three tables names it.
    used_by: tuple[int, ...]

    #: Whether the label is one the project's added-files fragment defines.
    added: bool = False

    #: Whether the label inserts the empty level: the project deleted it.
    deleted: bool = False

    @property
    def key(self) -> str:
        """The label as the definitions and the project's record spell it."""
        return undecorated(self.label)

    @property
    def kind_name(self) -> str:
        return KIND_NAMES.get(self.kind, self.kind)


@dataclass(frozen=True)
class LevelData:
    """Everything the Level Data window shows at once: the three tabs' rows,
    and what the editable cells may be pointed at."""

    numbers: list[LevelNumberRow]
    labels: list[LevelLabelRow]
    files: list[LevelFileRow]
    layer1_targets: tuple[StreamTarget, ...] = ()
    sprite_targets: tuple[StreamTarget, ...] = ()
    layer2_choices: tuple[Layer2Entry, ...] = ()

    #: The runs of ROM the streams are written into, and how full each is --
    #: the window's foot, under all three tabs, because which run a stream
    #: lands in is the third hop and how much room is left is what every
    #: refused save is about. ``None`` where there is no project to price.
    budgets: LevelBudgets | None = None


def level_number_rows(
    layer1: Sequence[str],
    sprites: Sequence[str],
    definitions: Mapping[str, str],
    layer2: Layer2Table | None = None,
    repointed: Collection[int] = (),
) -> list[LevelNumberRow]:
    """One row per level number the two tables have an entry for.

    ``layer1`` and ``sprites`` are the tables' labels in level order, as the
    tables spell them; ``definitions`` is label -> container for everything a
    label may name (:meth:`~shiny_mushroom.project.Project._level_definitions`
    on a project, :func:`smw_tools.levels.definitions` on the checkout), keyed
    without the namespace. ``layer2`` is the Layer 2 table where there is one
    to read, and ``repointed`` the numbers the project has moved.
    """
    count = min(len(layer1), len(sprites))
    resolved = [
        (
            definitions.get(undecorated(layer1[level])),
            definitions.get(undecorated(sprites[level])),
        )
        for level in range(count)
    ]
    readers: dict[str, set[int]] = {}
    for level, (one, other) in enumerate(resolved):
        for name in (one, other):
            if name is not None:
                readers.setdefault(name, set()).add(level)

    moved = set(repointed)
    rows = []
    for level in range(count):
        one, other = resolved[level]
        entry = None
        layer2_file = None
        if layer2 is not None and level < len(layer2.entries):
            entry = layer2.entry(level)
            if not entry.background:
                layer2_file = definitions.get(undecorated(entry.label))
        sharing: set[int] = set()
        for name in (one, other):
            if name is not None:
                sharing |= readers[name]
        sharing.discard(level)
        rows.append(
            LevelNumberRow(
                level=level,
                layer1_label=layer1[level],
                layer1_file=one,
                sprites_label=sprites[level],
                sprites_file=other,
                layer2=entry,
                layer2_file=layer2_file,
                shares_with=tuple(sorted(sharing)),
                remapped=level in moved,
            )
        )
    return rows


def level_label_rows(
    base: Path,
    target: BuildTarget | None = None,
    layer1: Sequence[str] = (),
    sprites: Sequence[str] = (),
    layer2: Layer2Table | None = None,
    added: tuple[str, ...] = (),
    deleted: tuple[str, ...] = (),
) -> list[LevelLabelRow]:
    """One row per label the level banks define, plus one per stream of each
    container the project adds, in label order.

    ``base`` and ``target`` are the game folder and the release, as
    :func:`smw_tools.levels.stream_definitions` takes them. The three tables'
    labels say who names each label; ``added`` is the project's added files
    and ``deleted`` its deleted labels
    (:meth:`~shiny_mushroom.project.Project.deleted_level_labels`), and the
    two decide the flags.
    """
    users: dict[str, set[int]] = {}
    for table in (layer1, sprites):
        for level, label in enumerate(table):
            users.setdefault(undecorated(label), set()).add(level)
    if layer2 is not None:
        for level, entry in enumerate(layer2.entries):
            users.setdefault(undecorated(entry.label), set()).add(level)

    placed: dict[str, str] = {}
    for region in level_regions(base, target):
        for insertion in region.insertions:
            if insertion.label:
                placed.setdefault(insertion.label, region.name)

    gone = set(deleted)
    rows = []
    for label, insertion in stream_definitions(base, target).items():
        rows.append(
            LevelLabelRow(
                label=NAMESPACE + label,
                kind=insertion.kind,
                container=insertion.container,
                region=placed.get(label, ""),
                used_by=tuple(sorted(users.get(label, ()))),
                deleted=label in gone,
            )
        )
    for insertion in added_insertions(added):
        rows.append(
            LevelLabelRow(
                label=insertion.label,
                kind=insertion.kind,
                container=insertion.container,
                region="",
                used_by=tuple(sorted(users.get(insertion.label, ()))),
                added=True,
            )
        )
    rows.sort(key=lambda row: row.label.lower())
    return rows
