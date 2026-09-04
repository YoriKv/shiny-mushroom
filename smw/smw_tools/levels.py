"""Which file in the source tree holds which level.

A level's bytes live in ``src/SMW/levels/<name>.mwl``, and nothing in the tree
states the level *number* those bytes belong to. The connection is made in three
hops, each of which is a real file the assembler reads:

1. ``levels/pointers/layer1.asm`` is 512 ``dl`` directives, one per level number
   in order, each naming a label -- ``dl SMW_LEVEL_L1_105``. There is a matching
   table for the sprite data.
2. That label is defined in bank ``$06`` or ``$07`` as the first argument of
   the macro that inserts the level, or in bank ``$0C`` on the line above
   it::

       %SMW_InsertLevelData(LEVEL_L1_105, 105, SMW_U, LAYER_1)

       Screen01:
           %SMW_InsertOriginalLevelData(EnemyRollcallScreen01_Forest, SMW_U, LAYER_1)

   The label is an argument in the level banks because the managed level
   banks (:func:`pack`) may move a stream to another run before its label
   is placed; the roll-call screens never move and keep the older form.

3. The macro's container argument is the container's name and the one after
   it a **target**, so the file is ``levels/105.mwl`` -- unless that target is
   the one being assembled, in which case it is ``levels/105_SMW_J.mwl``. See
   :func:`_container`.

**A level number alone does not name a file, and the ordering does not either.**
Both are worth stating, because both look like they should work:

- There are 245 containers for 512 level numbers, and the container's name is
  not the level's number -- 342 of the 512 resolve to a container named
  something else, 67 of the containers are not numbers at all
  (``Level096_LarryBattle``, ``EnemyRollcallScreen11_Reznor``).
- The banks do not insert them in level order. ``Bank07.asm`` makes 232
  insertions with 130 descending steps, because insertion order is a *ROM
  layout* decision -- ``SMW_LoadROMMap`` places each at a literal address -- and
  not a statement about level numbers.

What *is* ordinal is the pointer table, and that is hop 1: 512 entries in level
order, so the index into it is the level number. The label is only what carries
a table slot to a file on disk.

Read rather than tabulated, because a table here would be a second copy of
something the tree already states, and the tree is the one the assembler
believes. It is also how the two awkward cases stay honest, and both are common
enough to matter:

- **Levels share containers.** Levels ``$015``, ``$016`` and ``$017`` all point
  at ``SMW_LEVEL_L1_015``, so they are one level with three numbers -- not
  copies of it -- and an editor that did not know would offer to change one and
  silently change three.
- **A level's two streams can come out of different containers.** Forty-five of
  them do: level ``$097`` takes its Layer 1 from ``Level096_LarryBattle`` and its
  sprites from ``097``, which is how the cart gives one boss room several
  different sets of enemies. So a level is *two* files, which happen to be the
  same file most of the time.

The ``SMW_`` prefix on a pointer-table label is the namespace bank ``$06``
declares; the definitions themselves are written without it.

**Where those insertions land is the fourth hop**, and it is what bounds an
edit. Each bank macro is placed at a literal address by ``RomMap/``, and the
insertions inside it are concatenated from there -- so what a level's streams
have to fit inside is not the level's own size but the **sum of every stream in
the macro**, against the gap to whatever the map places next. See
:class:`LevelRegion`.

**Unless the level banks are managed**, which is the ``managed-level-memory``
feature (``Config/ManagedLevelMemory.asm``): then the seven level macros of
banks ``$06`` and ``$07`` emit their streams end to end into four runs --
:data:`PACKING_RUNS`, and the level bank behind them (:func:`runs_for`) -- a
stream that would run past the end of one moving to the next, and what bounds
an edit is the whole of them. :func:`pack` is that packer's arithmetic, run
over the same insertions in the same order, so a save can be priced exactly
where a build would refuse it.
"""

# Nine of the 437 insertions name a target other than ``SMW_U`` and so resolve to
# a different container for that one release. Ignoring the argument answers with
# U's bytes for all five, which is right four times out of five and silently
# wrong for the fifth -- so every entry point here takes the target it is being
# asked about.

from __future__ import annotations

import re
from collections.abc import Callable, Iterable, Sequence
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import TYPE_CHECKING

from . import rom_map
from .asm_defines import define
from .bases import DEFAULT_TARGET, VANILLA, BuildTarget, RomBase
from .packing import lay_out
from .paths import GAME_DIR

if TYPE_CHECKING:
    from .symbols import SymbolTable

#: The ``VerDif`` argument that names no variant. The macro tests against this
#: rather than against the release being built, so it is the framework's spelling
#: of "every release reads this container" and not a claim about ``U``.
BASE_VERDIF = "SMW_U"

#: The two pointer tables, relative to the game folder, and the banks the labels
#: they name are defined in. Layer 2 has a table of its own that is not read
#: here: most levels' Layer 2 is a background rather than a level, and its mixed
#: grammar -- ``dw label : db $FF`` for a background, ``dl label`` for level
#: data -- needs a parser of its own, which the editor's
#: ``shiny_mushroom.layer2_table`` is. The path is stated here beside its two
#: siblings so nothing else has to spell it.
LAYER1_TABLE = Path("levels/pointers/layer1.asm")
LAYER2_TABLE = Path("levels/pointers/layer2.asm")
SPRITE_TABLE = Path("levels/pointers/sprites.asm")
DEFINITION_BANKS = ("Bank06.asm", "Bank07.asm", "Bank0C.asm")

#: Where the containers themselves are, relative to the game folder. The same
#: path the insertion macro uses, because the macro resolves it from the game
#: folder too.
LEVELS_DIR = Path("levels")

#: The namespace bank $06 wraps its level labels in, which the pointer tables
#: spell out and the definitions do not.
NAMESPACE = "SMW_"

#: The three streams the insertion macro can pull out of a container, in the
#: framework's own spelling -- what it compares ``<Data>`` against to choose
#: which pair of offsets in the container's table to read.
LAYER_1 = "LAYER_1"
LAYER_2 = "LAYER_2"
SPRITES = "SPRITES"

_POINTER = re.compile(r"^\s*d[lw]\s+(\S+)")
#: Layer 2 definitions (``LEVEL_L2_``) are matched like the other two, but only
#: :func:`layer2_container` uses them: reaching one means starting from a label
#: rather than from a level number, because the Layer 2 *pointer* table is the
#: mixed-grammar one this module deliberately does not read.
_DEFINITION = re.compile(r"^(LEVEL_(?:L1|L2|SP)_\S+):")
#: The two insertion forms: the level banks' ``%SMW_InsertLevelData(label,
#: container, target, kind)``, and the older ``%SMW_InsertOriginalLevelData(
#: container, target, kind)`` under a label line, which bank ``$0C`` and the
#: added-level fragments keep. Both name the same three things.
_INSERTION = re.compile(
    r"^\s*%SMW_InsertOriginalLevelData\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*\)"
)
_LABELLED_INSERTION = re.compile(
    r"^\s*%SMW_InsertLevelData\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*\)"
)
_MACRO = re.compile(r"^macro\s+(\w+)\(")

#: Level numbers the pointer tables have an entry for.
LEVEL_COUNT = 0x200


@dataclass(frozen=True)
class LevelFile:
    """Where one level's two streams are, and who else reads them."""

    #: The container the level's Layer 1 region comes from -- its header and its
    #: object stream -- and the one its sprite list comes from. The same file for
    #: most levels, and this is the whole reason they are two fields.
    layer1: Path
    sprites: Path

    #: Every level number that reads either of those containers, this one
    #: included. Saving changes all of them, and there is no way to change one
    #: without the rest: they are not copies of a level, they are the same bytes
    #: reached by several numbers. Somewhere has to say so before a save, and
    #: nothing else in the tree can.
    shared_with: tuple[int, ...]

    @property
    def one_file(self) -> bool:
        """Whether both streams come out of the same container, which decides
        whether saving writes one file or two."""
        return self.layer1 == self.sprites

    @property
    def paths(self) -> tuple[Path, ...]:
        """The containers to write, without the duplicate."""
        return (self.layer1,) if self.one_file else (self.layer1, self.sprites)

    @property
    def shared(self) -> bool:
        return len(self.shared_with) > 1


@dataclass(frozen=True)
class Insertion:
    """One stream pulled out of one container, at one point in a region."""

    #: The container's name as the macro resolved it for this release -- so
    #: ``105`` or ``105_SMW_J``, and the file is that plus ``.mwl``.
    container: str
    #: :data:`LAYER_1`, :data:`LAYER_2` or :data:`SPRITES`.
    kind: str
    #: The label the stream is reached by, without the :data:`NAMESPACE`
    #: prefix -- ``LEVEL_L1_105``. Empty for an insertion nothing labels.
    label: str = ""


@dataclass(frozen=True)
class LevelRegion:
    """A run of ROM that holds nothing but level streams, and what is in it.

    One bank macro, placed at a literal address by ``RomMap/``. The insertions
    are emitted in the order they are written, contiguously, so **the region is
    the unit that has a size limit and a level is not**: one stream growing is
    paid for by another in the same region shrinking, and a level may grow
    freely while the group still fits.

    There is nothing to spare. Every one of these is packed to the byte against
    whatever the map places next -- the seven pure ones exactly, and the one that
    is a routine with level data after it exactly once its code is accounted for
    -- so the stock total *is* the budget, which is why nothing here needs the
    addresses to do the arithmetic. They are carried for the one thing the sum
    cannot say: which run of ROM was overrun, and where to find it.
    """

    #: The bank macro's name, which is what ``RomMap/`` places and so what names
    #: the region in an error.
    name: str
    #: Where the map puts it, and where the next placed entry begins. ``end`` is
    #: ``None`` for a macro nothing follows in the file.
    start: int
    end: int | None
    #: Every stream the macro emits, in order. A container inserted twice pays
    #: twice, which is why this is a sequence and not a set.
    insertions: tuple[Insertion, ...]

    @property
    def span(self) -> int | None:
        """How much ROM the map gives it, or ``None`` when nothing follows."""
        return None if self.end is None else self.end - self.start

    @property
    def containers(self) -> frozenset[str]:
        """Every container this region reads, without the duplicates."""
        return frozenset(insertion.container for insertion in self.insertions)


def level_regions(
    root: Path | None = None, target: BuildTarget | None = None
) -> tuple[LevelRegion, ...]:
    """Every region of level data the tree places, in ROM order.

    Only the macros the target's own ROM map places: a bank can define one that
    a given release never inserts, and a region nothing places bounds nothing.
    """
    return _regions(root or GAME_DIR, _romid(target))


def regions_holding(
    container: str, root: Path | None = None, target: BuildTarget | None = None
) -> tuple[LevelRegion, ...]:
    """Every region that reads ``container``, named without its suffix.

    Usually one and sometimes two: a container's Layer 1 and its sprites are
    inserted separately, and the map is free to put them in different banks --
    which for most of the cart it does.
    """
    return tuple(
        region
        for region in level_regions(root, target)
        if container in region.containers
    )


def level_file(
    level: int, root: Path | None = None, target: BuildTarget | None = None
) -> LevelFile | None:
    """Where ``level``'s data is, or ``None`` if the tree does not place it.

    ``root`` is the game folder, so a merged build tree or a test fixture can be
    asked the same question as the checkout.

    ``target`` is which release is being asked about, because twelve level
    numbers resolve to a different container for ``J`` or the arcade build than
    they do for the other releases. It defaults to the one the editor works in.
    """
    return _index(root or GAME_DIR, _romid(target)).get(level)


def layer2_container(
    label: str, root: Path | None = None, target: BuildTarget | None = None
) -> Path | None:
    """The container holding the Layer 2 stream ``label`` names, or ``None``.

    Hops 2 and 3 only, starting from the label rather than from a level number,
    because hop 1 for Layer 2 is the mixed-grammar pointer table this module
    does not read -- ``shiny_mushroom.layer2_table`` is what parses that and so
    what has the label to hand. ``label`` may carry the :data:`NAMESPACE`
    prefix the pointer table spells it with or not.

    ``None`` for a label no bank defines, which is what a hacked tree pointing
    at something of its own gives: there is no file to write such a stream
    into, and saying so is the whole point of asking.
    """
    found = _definitions(root or GAME_DIR, _romid(target)).get(undecorated(label))
    if found is None:
        return None
    return (root or GAME_DIR) / LEVELS_DIR / f"{found}.mwl"


def containers(
    root: Path | None = None, target: BuildTarget | None = None
) -> dict[int, LevelFile]:
    """Every level number the tree places, and where its data is."""
    return dict(_index(root or GAME_DIR, _romid(target)))


def containers_for(root: Path, romid: str) -> dict[int, LevelFile]:
    """:func:`containers` for a release named by its ROMID rather than by a
    target -- what a build tree knows its release as."""
    return dict(_index(root, romid))


def definitions(
    root: Path | None = None, target: BuildTarget | None = None
) -> dict[str, str]:
    """Label -> container name, for every level label the banks define.

    Hop 2 and 3 on their own, public for the one caller that starts from a
    label rather than from a level number: an editor rewriting a pointer
    *table* has labels in hand and needs to know what each would make a level
    read. Keys are spelled as the definitions are -- without the
    :data:`NAMESPACE` prefix the pointer tables add.
    """
    return dict(_definitions(root or GAME_DIR, _romid(target)))


def place(
    layer1: Sequence[str],
    sprites: Sequence[str],
    definitions: dict[str, str],
    root: Path,
) -> dict[int, LevelFile]:
    """Hop 1 resolved against hops 2 and 3: pointer-table labels, in level
    order, turned into where each level's data is.

    The whole of :func:`containers` once the three files are read -- and the
    reason it is public is that the *tables* are not always the checkout's own:
    an editor laying a project over the tree reads its edited copies, and the
    resolution had better be this same function or the two would drift.
    Labels may carry the :data:`NAMESPACE` prefix the tables spell them with.
    """
    placed: dict[int, tuple[str, str]] = {}
    for level in range(min(LEVEL_COUNT, len(layer1), len(sprites))):
        one = definitions.get(undecorated(layer1[level]))
        other = definitions.get(undecorated(sprites[level]))
        if one is not None and other is not None:
            placed[level] = (one, other)

    # Which levels read each container, so a level can be told every number its
    # own save would move. Both streams count: editing the sprite list of a boss
    # room reaches every room that shares that sprite container, even though
    # their layouts are separate files.
    readers: dict[str, set[int]] = {}
    for level, names in placed.items():
        for name in names:
            readers.setdefault(name, set()).add(level)

    return {
        level: LevelFile(
            layer1=root / LEVELS_DIR / f"{one}.mwl",
            sprites=root / LEVELS_DIR / f"{other}.mwl",
            shared_with=tuple(sorted(readers[one] | readers[other])),
        )
        for level, (one, other) in placed.items()
    }


def _romid(target: BuildTarget | None) -> str:
    """The framework's name for the release being asked about.

    Reduced to the ROMID here rather than held as a target, because that string
    is the whole of what the insertion macro compares against -- and it keeps
    :func:`_index`'s cache key hashable and small.
    """
    return (target or VANILLA.target(DEFAULT_TARGET)).romid


@lru_cache(maxsize=8)
def _index(root: Path, romid: str) -> dict[int, LevelFile]:
    """Walk the three hops for all 512 levels. Cached: it reads five files and
    is asked once per level load."""
    return place(
        _pointers(root / LAYER1_TABLE),
        _pointers(root / SPRITE_TABLE),
        _definitions(root, romid),
        root,
    )


@lru_cache(maxsize=8)
def _regions(root: Path, romid: str) -> tuple[LevelRegion, ...]:
    """Match the macros that insert level data against where the map puts them.

    Cached alongside :func:`_index`: it reads the same banks plus one ROM map,
    and a save asks it once per container written.
    """
    inserted = _insertions(root, romid)
    placed = _placements(root, romid)
    return tuple(
        LevelRegion(
            name=name,
            start=start,
            end=placed[index + 1][1] if index + 1 < len(placed) else None,
            insertions=inserted[name],
        )
        for index, (name, start) in enumerate(placed)
        if name in inserted
    )


def _placements(root: Path, romid: str) -> list[tuple[str, int]]:
    """Every macro the ROM map places, as ``(name, address)`` in file order.

    Through :mod:`smw_tools.rom_map`, which owns the map's grammar, and reduced
    back to a pair here because what bounds a region is the *address* the next
    line orgs to -- the number the error a full region raises has to name.
    """
    return [(one.macro, one.start) for one in rom_map.placements_for(root, romid)]


def _insertions(root: Path, romid: str) -> dict[str, tuple[Insertion, ...]]:
    """Macro name -> the level streams its body emits, in order.

    Only the macros that emit any, so a region is a macro with level data in it
    rather than every macro the banks define.
    """
    found: dict[str, list[Insertion]] = {}
    for bank in DEFINITION_BANKS:
        path = root / "Banks" / bank
        if not path.is_file():
            continue
        macro = None
        label = ""
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            start = _MACRO.match(line)
            if start is not None:
                macro = start.group(1)
            elif line.startswith("endmacro"):
                macro = None
            elif macro is None:
                continue
            elif labelled := _LABELLED_INSERTION.match(line):
                found.setdefault(macro, []).append(
                    Insertion(
                        container=_container(
                            labelled.group(2), labelled.group(3), romid
                        ),
                        kind=labelled.group(4),
                        label=labelled.group(1),
                    )
                )
            elif insert := _INSERTION.match(line):
                found.setdefault(macro, []).append(
                    Insertion(
                        container=_container(insert.group(1), insert.group(2), romid),
                        kind=insert.group(3),
                        label=label,
                    )
                )
            # The older form's label is the line above its insertion, and a
            # label line that is not followed by one names nothing here.
            label = line[:-1] if re.fullmatch(r"\w+:", line) else ""
    return {name: tuple(entries) for name, entries in found.items()}


def _pointers(path: Path) -> list[str]:
    """A pointer table's labels, in level order."""
    if not path.is_file():
        return []
    return [
        match.group(1)
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines()
        if (match := _POINTER.match(line))
    ]


def _definitions(root: Path, romid: str) -> dict[str, str]:
    """Label -> container name, from the banks the levels are inserted in."""
    return {
        label: one.container for label, one in _stream_definitions(root, romid).items()
    }


def stream_definitions(
    root: Path | None = None, target: BuildTarget | None = None
) -> dict[str, Insertion]:
    """Label -> the insertion it names, for every level label the banks define.

    :func:`definitions` with the stream's *kind* kept: what a label reaches is
    which region of the container the macro pulls, and a remap offering a
    label for a level's Layer 1 has to know it is a Layer 1 stream -- the
    unused levels' ``UnusedLevelData_*`` labels say nothing in their spelling.
    Read off the bank files alone, so a tree whose map places nothing still
    answers.
    """
    return dict(_stream_definitions(root or GAME_DIR, _romid(target)))


@lru_cache(maxsize=8)
def _stream_definitions(root: Path, romid: str) -> dict[str, Insertion]:
    """Label -> insertion, from the banks the levels are inserted in.

    The label is the insertion's first argument in the level banks, and the
    line above the call in bank ``$0C``, which is why this is a one-line
    match plus a two-line window rather than a parser.
    """
    found: dict[str, Insertion] = {}
    for bank in DEFINITION_BANKS:
        path = root / "Banks" / bank
        if not path.is_file():
            continue
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        for index, line in enumerate(lines):
            # Every labelled insertion, the unused levels' `UnusedLevelData_*`
            # included: a label is what a pointer entry may name, and which
            # stream it reaches is the insertion's kind to say.
            labelled = _LABELLED_INSERTION.match(line)
            if labelled is not None:
                found[labelled.group(1)] = Insertion(
                    container=_container(labelled.group(2), labelled.group(3), romid),
                    kind=labelled.group(4),
                    label=labelled.group(1),
                )
                continue
            label = _DEFINITION.match(line)
            if label is None or index + 1 >= len(lines):
                continue
            inserted = _INSERTION.match(lines[index + 1])
            if inserted is not None:
                found[label.group(1)] = Insertion(
                    container=_container(inserted.group(1), inserted.group(2), romid),
                    kind=inserted.group(3),
                    label=label.group(1),
                )
    return found


#: Where the Layer 2 backgrounds are defined, and what their blobs are under.
BACKGROUNDS_BANK = "Bank0C.asm"
BACKGROUNDS_DIR = Path("levels/backgrounds")

_NAMESPACE = re.compile(r"^\s*namespace\s+(\w+)")
_PARENT_LABEL = re.compile(r"^(\w+):")
_SUB_LABEL = re.compile(r"^\.(\w+):")
_INCBIN = re.compile(r"^\s*incbin\s+\"(levels/backgrounds/[^\"]+)\"")


def background_definitions(root: Path | None = None) -> dict[str, Path]:
    """Label -> blob, for every Layer 2 background bank ``$0C`` defines.

    The seventeen LC_RLE1 tilemaps the Layer 2 pointer table's ``dw label :
    db $FF`` entries name. Each is a sublabel under ``Layer2:`` inside
    ``namespace SMW_Backgrounds``, followed by the ``incbin`` of its blob, so
    the label the table spells -- ``SMW_Backgrounds_Layer2_Clouds`` -- is the
    three joined, and the path is the ``incbin``'s. Read off the bank alone,
    like :func:`stream_definitions`, so a tree whose map places nothing still
    answers.
    """
    return dict(_background_definitions(root or GAME_DIR))


@lru_cache(maxsize=8)
def _background_definitions(root: Path) -> dict[str, Path]:
    path = root / "Banks" / BACKGROUNDS_BANK
    if not path.is_file():
        return {}
    found: dict[str, Path] = {}
    namespace = ""
    parent = ""
    pending: str | None = None
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if named := _NAMESPACE.match(line):
            namespace = "" if named.group(1) == "off" else named.group(1)
            parent, pending = "", None
        elif labelled := _PARENT_LABEL.match(line):
            parent, pending = labelled.group(1), None
        elif sub := _SUB_LABEL.match(line):
            parts = (namespace, parent, sub.group(1))
            pending = "_".join(part for part in parts if part)
        elif (blob := _INCBIN.match(line)) and pending is not None:
            found[pending] = root / blob.group(1)
            pending = None
    return found


def _container(name: str, verdif: str, romid: str) -> str:
    """Which container an insertion reads, for the release being assembled.

    The macro's own rule, and it is a three-way rather than a two-way::

        if !ROM_<VerDif> != !ROM_SMW_U
            if !Define_Global_ROMToAssemble&(!ROM_<VerDif>) != $00
                !TEMP = <LevelName>_<VerDif>
            else
                !TEMP = <LevelName>
        else
            !TEMP = <LevelName>

    ``!Define_Global_ROMToAssemble`` is set to a single bit (``!ROM_<ROMID>``),
    so the mask test is an equality however much it looks like a membership one.
    A ``VerDif`` of ``SMW_U`` names no variant at all -- it is the macro's way of
    spelling "every release reads this file" -- which is why the outer test is
    against ``SMW_U`` rather than against the release being built.
    """
    if verdif == BASE_VERDIF or verdif != romid:
        return name
    return f"{name}_{verdif}"


def undecorated(label: str) -> str:
    """A pointer table's label as the definitions spell it."""
    return label[len(NAMESPACE) :] if label.startswith(NAMESPACE) else label


# -- the managed level banks ---------------------------------------------------


#: The feature under which the level banks are packed, by id -- the same
#: string :data:`smw_tools.features.MANAGED_LEVEL_MEMORY` declares, spelled
#: here so this module's imports stay its own.
MANAGED_FEATURE = "managed-level-memory"


@dataclass(frozen=True)
class LevelRun:
    """One run of ROM the managed level banks pack streams into."""

    #: Its 24-bit SNES address, and one past its last byte.
    start: int
    end: int

    @property
    def size(self) -> int:
        return self.end - self.start

    @property
    def bank(self) -> int:
        return self.start >> 16

    def holds(self, address: int) -> bool:
        """Whether ``address`` falls inside this run."""
        return self.start <= address < self.end


#: The three runs in the stock banks, in the order the packer fills them:
#: bank ``$06`` whole, bank ``$07`` up to the sprite routines the map places
#: at ``$07F000``, and that bank's tail behind its last routine. Literal,
#: exactly as ``Config/ManagedLevelMemory.asm`` states them; a test holds the
#: two against each other and against every ROM map. The level bank is the
#: fourth and is the cartridge's rather than a literal -- :func:`runs_for`.
#:
#: **As the ROM map places them**, which is the last of them whole. What the
#: packing fills of it stops at the sprite-bank tail below the end of bank
#: ``$07`` -- :data:`PACKING_RUNS`, and every caller pricing a save wants
#: that one.
MANAGED_RUNS = (
    LevelRun(0x068000, 0x070000),
    LevelRun(0x078000, 0x07F000),
    LevelRun(0x07FC90, 0x080000),
)

#: How many banks past a base's reservation bank the level bank is -- the
#: :attr:`~smw_tools.features.Feature.bank_offset` both its occupants declare,
#: restated here so this module can name the bank without importing them; a
#: test holds the two equal.
LEVEL_BANK_OFFSET = 1

#: The level bank's layout, as offsets from its base, exactly as
#: ``Config/LevelBank.asm`` states them -- a test holds the file to these.
#: The run starts past the RATS tag and the end label is the bank's last
#: byte, and nothing is held back from it: what packs there has the whole
#: run.
LEVEL_BANK_RUN = 0x8008
LEVEL_BANK_END = 0xFFFF

#: The managed level banks' **tail**: the sprite-bank stub and the table
#: after it -- one byte per level -- at the top of bank ``$07``, exactly as
#: ``Config/ManagedLevelMemory.asm`` places them. The last of
#: :data:`MANAGED_RUNS` ends where the stub starts, which is what
#: :data:`PACKING_RUNS` says.
#:
#: In one of the game's own banks and not in the level bank, because the
#: sprite-memory rewrite and the editor both name the table by address, and
#: the level bank moves with the base's reservation where bank ``$07`` is
#: the same everywhere.
#: The stub's own size is read from the file that emits it and asserts it
#: (:mod:`smw_tools.asm_defines`): where the last run ends follows from it.
TAIL_STUB_BYTES = define("Define_SMW_ManagedLevelStubBytes")
TAIL_BYTES = LEVEL_COUNT + TAIL_STUB_BYTES
SPRITE_BANKS_AT = MANAGED_RUNS[-1].end - LEVEL_COUNT

#: The runs the packing actually fills in the game's own banks:
#: :data:`MANAGED_RUNS` with the tail taken off the last of them. The level
#: bank is the fourth run behind these -- :func:`runs_for`.
PACKING_RUNS = (
    *MANAGED_RUNS[:-1],
    LevelRun(MANAGED_RUNS[-1].start, MANAGED_RUNS[-1].end - TAIL_BYTES),
)

#: The fragment that table incsrc's: one ``db <label>>>$10`` per level in
#: level order, naming the label the sprite pointer table names in the same
#: row. Regenerated by the editor whenever it rewrites the sprite table
#: (:func:`sprite_bank_rows`); the shipped copy mirrors the shipped table.
#: It is what frees a sprite list to land in any bank: the stock loader
#: completes every ``dw`` sprite pointer with bank ``$07``, and the feature's
#: hook reads this table instead.
SPRITE_BANKS_FRAGMENT = Path("levels/pointers/sprite-banks.asm")

#: What the first run's head holds before any stream: the Chocolate Island 2
#: hook and its nine-row bank table. Measured off a feature build's symbol
#: file, ``SMW_ManagedLevelMemory_Streams - SMW_ManagedLevelMemory_Start``.
MANAGED_HEAD_BYTES = 0x23

#: What a deleted stream costs instead of its bytes: the empty level
#: ``%SMW_InsertLevelData`` inserts under its label -- a zeroed header and the
#: ``$FF`` terminator for a layer, a zero header byte and the terminator for a
#: sprite list.
EMPTY_STREAM_SIZES = {LAYER_1: 6, LAYER_2: 6, SPRITES: 2}

#: The two fragments the editor regenerates for the packed level banks,
#: relative to the game folder: the added files' insertions, packed after the
#: banks' own by the feature's close, and the deleted streams' defines, read
#: at the start of every pass.
ADDED_FRAGMENT = Path("levels/added/added-levels.asm")
DELETED_FRAGMENT = Path("levels/deleted-levels.asm")

#: Where each stream's bounds are kept in a container's own table: the offset
#: word and the size word, per kind, exactly as the insertion macro reads them.
_STREAM_FIELDS = {LAYER_1: (0x48, 0x4C), LAYER_2: (0x50, 0x54), SPRITES: (0x58, 0x5C)}

#: The bytes a container's region carries in front of the stream itself, which
#: the macro steps over and the size word counts.
_REGION_HEADER = 8


def is_managed(base: RomBase) -> bool:
    """Whether ``base``'s level banks are packed -- see :func:`pack`."""
    return MANAGED_FEATURE in base.features


def level_bank(base: RomBase) -> int:
    """The bank ``base`` keeps the level bank in: one past its reservation
    bank, ``$11`` on a plain build and ``$12`` on ``sa1``."""
    return base.reservation_bank + LEVEL_BANK_OFFSET


#: The two labels ``%SMW_PlaceLevelBank`` drops around the project's own code
#: in the level bank -- the tool's dialect and library, the levels', the game
#: modes' and the global routines -- so a build's symbol file says how long
#: that code assembled to: the second is where the packer's fourth run opens.
LEVEL_BANK_CODE_LABELS = ("SMW_LevelBank_Code", "SMW_LevelBank_Streams")


def code_bytes(symbols: SymbolTable) -> int | None:
    """How many bytes of the level bank the project's own code took on the
    build ``symbols`` describes, or ``None`` where that build placed no
    level bank at all.

    Read off the two labels the bank's sequence drops around the code
    (:data:`LEVEL_BANK_CODE_LABELS`), because the code's length is whatever
    the project's files assembled to and nothing but a build knows it. Zero
    on a build whose level bank holds no code.
    """
    found = [symbols.by_name.get(label) for label in LEVEL_BANK_CODE_LABELS]
    if any(one is None for one in found):
        return None
    return found[1].addr - found[0].addr


def level_bank_run(base: RomBase, ahead: int = 0) -> LevelRun:
    """What the level bank has behind its first ``ahead`` bytes on ``base``.

    From the run's head to whatever ends it -- the bank's end label, or the
    managed level banks' fixed tail where ``base`` packs its levels -- less
    the level number stash the bank lays at that head for whichever of its
    readers it has, less what the level graphics, the per-level code and the
    Lunar Magic tables take at the front where ``base`` carries them
    (their block is one fixed size, :data:`level_graphics.BLOCK_BYTES`), and
    less ``ahead`` bytes behind that: what the custom level palettes put
    there -- their pointer table, their stubs and every blob a dressed level
    wears -- and what the project's own code assembled to behind them
    (:func:`code_bytes`). A caller pricing a project passes the project's
    own figure for both, and ``0`` is a cartridge with neither. The packer
    opens its fourth run here (:func:`runs_for`), and a palette save prices
    itself against the same run with the streams in it.
    """
    from . import level_graphics
    from .asm_defines import block
    from .features import (
        LEVEL_CUSTOM_PALETTES,
        LEVEL_GRAPHICS,
        LUNAR_MAGIC_LEVELS,
        UBERASM_SUPPORT,
    )

    held = set(base.features)
    readers = {
        LEVEL_GRAPHICS.id,
        UBERASM_SUPPORT.id,
        LUNAR_MAGIC_LEVELS.id,
        LEVEL_CUSTOM_PALETTES.id,
    }
    base_address = level_bank(base) << 16
    end = base_address | LEVEL_BANK_END
    start = base_address | LEVEL_BANK_RUN
    if readers & held:
        start += block("LevelNumberStash")
    if level_graphics.is_enabled(base):
        start += level_graphics.BLOCK_BYTES
    if UBERASM_SUPPORT.id in held:
        start += UBERASM_SUPPORT.block_bytes
    if LUNAR_MAGIC_LEVELS.id in held:
        start += LUNAR_MAGIC_LEVELS.block_bytes
    return LevelRun(start=start + ahead, end=end)


def runs_for(base: RomBase, ahead: int = 0) -> tuple[LevelRun, ...]:
    """The runs ``base``'s packer fills, in order: the three stock ones
    (:data:`PACKING_RUNS`), and the level bank behind them --
    :func:`level_bank_run`, with ``ahead`` bytes of palettes in front."""
    return (*PACKING_RUNS, level_bank_run(base, ahead))


def sprite_bank_rows(sprite_labels: Iterable[str]) -> list[str]:
    """The sprite-bank table's rows for ``sprite_labels``, the sprite pointer
    table's labels in level order: one line per level, each the bank of the
    label its pointer-table row names, spelled as the table spells it -- so
    a level remapped in one is remapped in the other, and a build with the
    two fragments disagreeing cannot be written."""
    return [
        f"db {label}>>$10\t; {level:03X}\n" for level, label in enumerate(sprite_labels)
    ]


def stream_size(container: Path, kind: str) -> int:
    """How many bytes ``container``'s ``kind`` stream puts in the ROM.

    Read the way ``%SMW_InsertOriginalLevelData`` reads it -- the size word
    of the region's entry in the container's table, less the region's own
    eight bytes -- so the number is the assembler's own and not a parse of
    the stream.
    """
    _offset, size_at = _STREAM_FIELDS[kind]
    with container.open("rb") as handle:
        handle.seek(size_at)
        word = handle.read(2)
    if len(word) != 2:
        raise ValueError(f"{container} is too short to hold a level stream table")
    return int.from_bytes(word, "little") - _REGION_HEADER


def managed_regions(
    root: Path | None = None, target: BuildTarget | None = None
) -> tuple[LevelRegion, ...]:
    """The level regions the managed banks pack, in the order they are packed.

    The ones the map places inside a run -- the seven level macros -- and not
    the roll-call routine in bank ``$0C``, which the feature leaves alone.
    """
    return tuple(
        region
        for region in level_regions(root, target)
        if any(run.holds(region.start) for run in MANAGED_RUNS)
    )


@dataclass(frozen=True)
class Placed:
    """One stream, where the packer put it."""

    insertion: Insertion
    #: Its 24-bit SNES address.
    address: int
    size: int

    @property
    def end(self) -> int:
        return self.address + self.size


@dataclass(frozen=True)
class Packing:
    """What :func:`pack` made of the streams it was given."""

    #: Every stream that found a run, in the order they were packed.
    placed: tuple[Placed, ...]
    #: The streams that found none, with their sizes, in order. Empty is the
    #: build that assembles.
    unplaced: tuple[tuple[Insertion, int], ...]
    #: How many bytes of each run the packing used, by run index -- the head
    #: and every stream placed there, up to where the packing left the run.
    used: tuple[int, ...]

    @property
    def fits(self) -> bool:
        return not self.unplaced

    @property
    def over(self) -> int:
        """How many bytes found no run: what has to come out before it fits."""
        return sum(size for _insertion, size in self.unplaced)

    def address_of(self, label: str) -> int | None:
        """Where the stream labelled ``label`` landed, or ``None``."""
        wanted = undecorated(label)
        for one in self.placed:
            if one.insertion.label == wanted:
                return one.address
        return None


def pack(
    regions: Iterable[LevelRegion],
    size_of: Callable[[Insertion], int],
    runs: Sequence[LevelRun] = PACKING_RUNS,
    head: int = MANAGED_HEAD_BYTES,
) -> Packing:
    """Lay ``regions``' streams into ``runs`` the way the managed banks do.

    The packer's own arithmetic (``%SMW_ManagedLevelFit``), so what this
    answers is what the build will do: streams go in region order and
    insertion order, back to back from ``head`` bytes into the first run; a
    stream that would run past the end of the run being filled moves the
    packing to the next run; the packing never goes back. A stream left over
    when the runs are spent is unplaced, and so is everything after it. A
    sprite list is a stream like any other: the loader reads each list's
    bank off the table at the level bank's tail, so none has a bank to keep.

    ``runs`` is the cartridge's -- :func:`runs_for`, the stock runs and
    the level bank behind whatever the palettes put there; the default is
    the stock runs alone, for a caller asking what the two banks hold.

    ``size_of`` answers each insertion's stream size -- :func:`stream_size`
    over whichever copy of the container the caller means, since a project
    prices its own edited copies and the checkout's for the rest.
    """
    laid = lay_out(
        (insertion for region in regions for insertion in region.insertions),
        size_of,
        runs,
        head,
    )
    return Packing(
        placed=tuple(
            Placed(insertion=slot.item, address=slot.address, size=slot.size)
            for slot in laid.placed
        ),
        unplaced=laid.leftover,
        used=laid.used(runs),
    )


@lru_cache(maxsize=8)
def stock_stream_sizes(root: Path, romid: str) -> dict[tuple[str, str], int]:
    """``(container, kind)`` -> stream size for every insertion the level
    banks make, read off the checkout's own containers. Cached: a save
    prices the whole packing, and only the edited containers change."""
    sizes: dict[tuple[str, str], int] = {}
    for region in _regions(root, romid):
        for insertion in region.insertions:
            key = (insertion.container, insertion.kind)
            if key not in sizes:
                sizes[key] = stream_size(
                    root / LEVELS_DIR / f"{insertion.container}.mwl", insertion.kind
                )
    return sizes
