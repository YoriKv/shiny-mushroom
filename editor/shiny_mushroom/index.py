"""Where every object and sprite in a cartridge is, by id.

Answers "which levels have a spring board in them, and where" without loading a
single one of them. The whole cartridge is walked once when a ROM is opened and
the result is a lookup: an id, and the places it occurs, in level order.

**No emulator, and that is what makes it affordable.** Asking the game to load a
level costs ~150 ms, so indexing 512 of them that way would be well over a
minute of the user waiting. But neither stream needs the game: both are in the
cartridge, and :func:`~shiny_mushroom.objects.parse_objects` and
:func:`~shiny_mushroom.sprites.parse_sprites` already read them from bytes.
Everything else a level's shape depends on -- the screen count, the level mode,
whether Layer 2 is a background -- is a byte of the ROM too. Measured on the U
cart the sweep is ~65 ms for all 512 levels, 22,749 objects and 3,290 sprites.

What this cannot say is what a *standard* object is called, because that depends
on the level's tileset and an index spans every tileset at once. Extended
objects and sprites are named, since neither is tileset-dependent.

The same sweep answers a second question, and gets it for nothing: **which
sprite tilesets the cartridge places each sprite number under**
(:meth:`LevelIndex.shipped_under`). Every level's header is already being read
for the level's shape, and the sprite tileset is one nibble of it. It is the
evidence behind whether a sprite's graphics will be loaded where you are putting
it -- see :func:`~shiny_mushroom.catalog.art_verdict` for why that is evidence
and not a rule.

**Levels sharing a stream are indexed once.** The stock cart points 277 of its
512 level slots at one unused stream, and a search that reported all 277 would
put 276 copies of the same record between the user and the next real one. Two
levels are the same entry here exactly when the cartridge's own pointer tables
send them to the same bytes -- so a hack whose levels are all distinct loses
nothing, and the collapse can never merge two levels that differ.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from enum import Enum

from shiny_mushroom.addresses import Addresses
from shiny_mushroom.header import HEADER_SIZE
from shiny_mushroom.hexnum import hexnum, hexspot
from shiny_mushroom.level import Geometry, level_shape
from shiny_mushroom.metadata import OBJECTS
from shiny_mushroom.objects import EXTENDED_OBJECT, LevelObject, parse_objects
from shiny_mushroom.rom_patches import (
    layer1_base,
    layer2_is_background,
    object_stream,
    sprite_base,
    sprite_stream,
    vertical_level,
)
from shiny_mushroom.sprites import Sprite, name_of, parse_sprites

#: Every level number the cartridge has a pointer table entry for.
LEVEL_COUNT = 0x200


class SearchKind(Enum):
    """What a search is over.

    Three, because an id means three different things depending on which stream
    it is read from and which half of an object record it sits in. ``$0E`` is a
    tileset object, an extended object and a sprite all at once, and none of the
    three is in the same place as the others.
    """

    STANDARD = "standard object"
    EXTENDED = "extended object"
    SPRITE = "sprite"

    @property
    def label(self) -> str:
        """What to put in front of a user."""
        return self.value.capitalize()

    def name_of(self, number: int) -> str:
        """What ``number`` is called, where that can be said at all.

        A standard object's name is a property of the **level's tileset**, and
        an index spans every tileset in the cartridge -- so there is no one
        answer and this gives none, rather than picking a tileset and being
        wrong for the other fourteen. The other two are tileset-independent.
        """
        if self is SearchKind.SPRITE:
            return name_of(number)
        if self is SearchKind.EXTENDED:
            return OBJECTS.extended.get(number, "")
        return ""

    @property
    def limit(self) -> int:
        """One past the largest id this kind can hold.

        An object number is six bits; an extended object number and a sprite
        number are both a whole byte.
        """
        return 0x40 if self is SearchKind.STANDARD else 0x100


@dataclass(frozen=True)
class Occurrence:
    """One record, and enough about it to go and look at it.

    :attr:`offset` is what identifies it once the level is open -- the same byte
    offset :class:`~shiny_mushroom.objects.LevelObject` and
    :class:`~shiny_mushroom.sprites.Sprite` are told apart by, and the reason a
    jump can select the record it found rather than the first one that looks
    like it. The position is carried as well because it is what a search result
    *reads* as, and because scrolling to it must not wait for the level.
    """

    kind: SearchKind
    number: int
    level: int
    column: int
    row: int
    screen: int
    offset: int

    def describe(self) -> str:
        """One line for a readout: which level, and where in it."""
        return f"{hexnum(self.level, 3)} at {hexspot(self.column, self.row)}"


class LevelIndex:
    """Every occurrence in a cartridge, by kind and id.

    Built by :func:`build_index`; empty by default, which is what a window
    holding no ROM has and what keeps every caller from having to test for one.
    """

    def __init__(
        self,
        occurrences: Mapping[SearchKind, Mapping[int, tuple[Occurrence, ...]]]
        | None = None,
        levels: Iterable[int] = (),
        sprite_tilesets: Mapping[int, frozenset[int]] | None = None,
    ) -> None:
        found = occurrences or {}
        self._by_id = {kind: dict(found.get(kind, {})) for kind in SearchKind}
        #: The levels actually walked -- one per distinct pair of streams, so
        #: shorter than the cartridge's level count wherever slots are shared.
        self.levels = tuple(levels)
        #: Sprite number -> the **sprite tilesets** the cartridge itself places
        #: it under. See :meth:`shipped_under`.
        self._sprite_tilesets = dict(sprite_tilesets or {})

    def find(self, kind: SearchKind, number: int) -> tuple[Occurrence, ...]:
        """Every occurrence of ``number``, in level order then stream order.

        Empty for an id that occurs nowhere, which is an ordinary answer: most
        of the 256 sprite numbers are not in the stock cart.
        """
        return self._by_id[kind].get(number, ())

    def count(self, kind: SearchKind, number: int) -> int:
        return len(self.find(kind, number))

    def ids(self, kind: SearchKind) -> tuple[int, ...]:
        """Which ids of this kind occur anywhere, ascending."""
        return tuple(sorted(self._by_id[kind]))

    def total(self, kind: SearchKind) -> int:
        """How many records of this kind the cartridge holds."""
        return sum(len(found) for found in self._by_id[kind].values())

    def shipped_under(self, number: int) -> frozenset[int]:
        """Which **sprite tilesets** this cartridge places sprite ``number``
        under.

        The evidence behind "will this sprite's graphics be loaded here", and it
        is evidence rather than a rule: SMW has no table saying which GFX files
        a sprite needs. What it draws is decided by its own drawing code and by
        which of ``SpriteGFXList``'s four files the level's **sprite tileset**
        (header byte 2, bits 0-3) put in SP1-SP4 -- and that field is chosen
        independently of the level tileset, so a sprite genuinely can be placed
        somewhere its artwork is not loaded.

        What the shipped cartridge does is the best answer available without
        running the game for every sprite in every tileset. An **empty** set is
        therefore not "this sprite is broken everywhere": it means the cart
        never places this number at all, and nothing is known either way. The
        two have to stay distinguishable -- see
        :func:`~shiny_mushroom.catalog.art_verdict`.
        """
        return self._sprite_tilesets.get(number, frozenset())

    def __bool__(self) -> bool:
        return any(self._by_id[kind] for kind in SearchKind)


def build_index(rom: bytes, *, where: Addresses) -> LevelIndex:
    """Walk every level in ``rom`` and index what is in it.

    ``rom`` is the **headerless** image, like every other offset in
    :mod:`shiny_mushroom.emu.smw`, and ``where`` is the ROM base it was
    assembled from -- the pointer tables this walk follows are the base's, not
    the game's, so a project built on another one is indexed through its own.

    Total by construction: a file that is not a Super Mario World cartridge is
    an ordinary thing to open -- the window draws any file as a byte map -- and
    an index of one is empty rather than an exception. A level whose pointers do
    not resolve is skipped for the same reason: one broken entry in a hack must
    not cost the other 511.
    """
    by_id: dict[SearchKind, dict[int, list[Occurrence]]] = {
        kind: {} for kind in SearchKind
    }
    # Sprite number -> the sprite tilesets it is shipped under. Collected on the
    # same sweep because it is the same walk: every level's header is already
    # being read for its shape, and the field is one nibble of it.
    tilesets: dict[int, set[int]] = {}
    walked: list[int] = []
    for level in _representatives(rom, where):
        found = _read_level(rom, level, where)
        if found is None:
            continue
        walked.append(level)
        sprite_tileset = _sprite_tileset(rom, level, where)
        for kind, number, column, row, screen, offset in found:
            by_id[kind].setdefault(number, []).append(
                Occurrence(kind, number, level, column, row, screen, offset)
            )
            if kind is SearchKind.SPRITE and sprite_tileset is not None:
                tilesets.setdefault(number, set()).add(sprite_tileset)
    return LevelIndex(
        {
            kind: {number: tuple(found) for number, found in ids.items()}
            for kind, ids in by_id.items()
        },
        walked,
        {number: frozenset(under) for number, under in tilesets.items()},
    )


def _sprite_tileset(rom: bytes, level: int, where: Addresses) -> int | None:
    """A level's sprite tileset: header byte 2, bits 3-0.

    Its own field, and **not** the tileset that decides what an object number
    means -- that is byte 4. The two are chosen independently, which is the
    whole reason a sprite's graphics are a question worth asking and an object's
    are not. ``None`` for a level whose header cannot be read, which the caller
    treats as "this level is no evidence" rather than as a tileset.
    """
    try:
        base = layer1_base(rom, level, where=where)
    except (ValueError, IndexError):
        return None
    header = rom[base : base + HEADER_SIZE]
    if len(header) < HEADER_SIZE:
        return None
    return header[2] & 0x0F


def _representatives(rom: bytes, where: Addresses) -> list[int]:
    """The levels worth walking: one per distinct pair of streams.

    One ascending pass, and the lowest level to claim a pair of streams keeps
    it. Every level in the cartridge can be opened -- the emulated loader holds
    the branch that reads ``$00`` as "no override" open for the numbers the
    request cannot otherwise name -- so the lowest is as good an answer as any
    other and is the one a search result should name.

    A level whose **Layer 1** pointer does not resolve gets no key and is dropped
    here; it would fail in :func:`_read_level` anyway, and this keeps the failure
    in one place. A level whose *sprite* pointer does not resolve is kept, keyed
    on ``None`` in that half -- see :func:`_sprite_key`.
    """
    claimed: dict[tuple[int, int | None], int] = {}
    for level in range(LEVEL_COUNT):
        try:
            key = (layer1_base(rom, level, where=where), _sprite_key(rom, level, where))
        except (ValueError, IndexError):
            continue
        # The first level to claim a pair of streams keeps it: they are the
        # same bytes reached by several numbers, and one occurrence is what a
        # search result should be.
        claimed.setdefault(key, level)
    return sorted(claimed.values())


def _sprite_key(rom: bytes, level: int, where: Addresses) -> int | None:
    """Where a level's sprite stream is, for telling two levels apart.

    ``None`` when it cannot be resolved, which on a cartridge whose sprite data
    bank has been hijacked is *every* level -- see
    :func:`~shiny_mushroom.rom_patches.sprite_data_bank`. Levels are then told apart
    by their Layer 1 pointer alone, which is a coarser answer than usual and a
    far better one than dropping the whole cartridge: its objects are perfectly
    readable and are most of what is in it.
    """
    try:
        return sprite_base(rom, level, where=where)
    except (ValueError, IndexError):
        return None


def _read_level(
    rom: bytes, level: int, where: Addresses
) -> list[tuple[SearchKind, int, int, int, int, int]] | None:
    """Everything in one level, as the tuples :func:`build_index` places.

    ``None`` when the level's own data cannot be read at all, which for a real
    cartridge never happens and for an arbitrary file is the usual answer.

    **The two streams fail independently.** They are resolved through different
    tables and, in the sprite stream's case, through an instruction a hack may
    have replaced -- so a cartridge can perfectly well have readable objects and
    unreachable sprites. Losing the objects too would throw away most of the
    cartridge over the half that broke.
    """
    try:
        shape = shape_of(rom, level, where=where)
        base = layer1_base(rom, level, where=where)
        objects = parse_objects(object_stream(rom, base + HEADER_SIZE), shape)
    except (ValueError, IndexError):
        return None
    found = [_object_entry(obj) for obj in objects]
    found += [
        (SearchKind.SPRITE, s.number, s.column, s.row, s.screen, s.offset)
        for s in _read_sprites(rom, level, shape, where)
    ]
    return found


def _read_sprites(
    rom: bytes, level: int, shape: Geometry, where: Addresses
) -> list[Sprite]:
    """One level's sprite records, or none where they cannot be reached."""
    try:
        return parse_sprites(
            sprite_stream(rom, sprite_base(rom, level, where=where)), shape
        )
    except (ValueError, IndexError):
        return []


def _object_entry(obj: LevelObject) -> tuple[SearchKind, int, int, int, int, int]:
    """Which kind an object record is searchable as, and under which id.

    Object number ``$00`` is not an object: its settings byte is a second
    opcode, so the id that matters for one of those is the settings byte and the
    kind is :attr:`SearchKind.EXTENDED`. That covers the screen exit and the
    screen jump as well -- they are extended objects ``$00`` and ``$01``, and
    being able to find every exit in a cartridge is worth more than excluding
    them for placing no tiles.
    """
    if obj.number == EXTENDED_OBJECT:
        kind, number = SearchKind.EXTENDED, obj.settings
    else:
        kind, number = SearchKind.STANDARD, obj.number
    return kind, number, obj.column, obj.row, obj.screen, obj.offset


def shape_of(rom: bytes, level: int, *, where: Addresses) -> Geometry:
    """A level's shape, read entirely off the cartridge.

    The one part that is not simply a header field is ``vertical``: header byte
    1 holds a level *mode*, and whether that mode is vertical is a byte of
    ``VerticalTable`` -- see :func:`~shiny_mushroom.rom_patches.vertical_level`. It
    matters here as much as anywhere, because a vertical level swaps the
    position nibbles of every object and sprite record in it.
    """
    base = layer1_base(rom, level, where=where)
    header = rom[base : base + HEADER_SIZE]
    if len(header) < HEADER_SIZE:
        raise ValueError(f"level {hexnum(level, 3)} has no header in this image")
    return level_shape(
        screen_count=(header[0] & 0x1F) + 1,
        vertical=vertical_level(rom, header[1] & 0x1F, where=where),
        layer2_background=layer2_is_background(rom, level, where=where),
    )
