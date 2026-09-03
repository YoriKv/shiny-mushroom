"""The level's sprite list: what is in it, where each one is, and marking them.

Positions and identities need no emulator. The sprite stream is three bytes per
record and the arithmetic that turns one into a position is small -- it is the
*appearance* that the cartridge only expresses as code, and that is not what
this module is for. Everything here is derived from
``ROUTINE_SMW_ParseLevelSpriteList`` and checked against the running cart: the
pointer this resolves from matches the one the game puts in ``$7E00CE``, and the
numbers it reads out are the ones that turn up in ``!RAM_SMW_NorSpr_SpriteID``.

Two things in that routine are not visible in the record layout and are the
reason this is a module rather than three lines at the call site:

- **A vertical level swaps a sprite's axes**, exactly as it swaps an object's.
  Byte 0's high nibble is the Y coordinate in a horizontal level and the X
  coordinate in a vertical one.
- **The two "extra bits" live inside the position's high byte.** The game masks
  byte 0 with ``$0D`` -- bit 0 is the coordinate's 9th bit, bits 2-3 are the
  extra bits, and they share the byte deliberately. Masking all three as
  position puts any sprite with extra bits set hundreds of pixels away -- which
  is also what the cartridge does to it: the loader leaves them in the Y high
  byte, ``SubOffscreen`` reads that as having fallen out of the level, and the
  sprite is deleted on the frame it spawns. The goal tape is the one sprite
  that takes them back out first, and reads them as which exit it activates.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass, replace
from enum import Enum
from typing import TYPE_CHECKING

from shiny_mushroom import glyphs
from shiny_mushroom.fields import (
    Field,
    Flags,
    Number,
    choices,
    pairs,
    position_rows,
    readout,
    record_rows,
    screen_row,
)
from shiny_mushroom.hexnum import hexnum, hexspot
from shiny_mushroom.level import (
    ANY_SHAPE,
    BLOCK,
    BYTES_PER_TILE,
    COLORS_PER_ROW,
    SCREEN_COLUMNS,
    TILE,
    Geometry,
    Raster,
    palette,
)
from shiny_mushroom.metadata import SPRITES
from shiny_mushroom.rom_patches import PlayerPosition
from shiny_mushroom.sprite_art import CUSTOM_ART_BASE

if TYPE_CHECKING:
    # An annotation only: this module reads the sprite stream and never
    # captures art, so naming the tile type must not put the ctypes
    # binding into every process that parses a level.
    from shiny_mushroom.sprite_art import SpriteTile

#: Bytes per record. The sprite stream has no variable-length records -- unlike
#: the object stream, where the screen exit takes a fourth byte.
RECORD_SIZE = 3

#: Ends the stream.
TERMINATOR = 0xFF

#: A sanity bound, not a format limit: the stream is walked until a terminator,
#: and a pointer that does not lead to one would otherwise walk the cartridge.
MAX_RECORDS = 512


class UnencodableSprite(ValueError):
    """A sprite whose byte 0 would be the :data:`TERMINATOR` the loader stops
    at, so the records behind it would never be read.

    One combination reaches it, and only in a vertical level: column ``$1F``
    fills the high nibble and bit 0, a screen of ``$10`` or more sets bit 1,
    and both extra bits set fill bits 2-3. Every one of those is data with
    nowhere else to go -- unlike an object's new-screen bit, which
    :func:`~shiny_mushroom.objects.encode_objects` can say a second way -- so
    the placement is refused rather than written, and
    :meth:`shiny_mushroom.edit.Level._rebuild` turns the refusal into the
    ``None`` every operation hands back: the level is left alone, and the
    editor says why rather than appearing to have ignored the gesture.
    """


#: Where each of the loader's ranges begins. Every one of these is a comparison
#: in ``ROUTINE_SMW_ParseLevelSpriteList``, in the order it makes them, and the
#: arithmetic beside each is the loader's own -- which is why a sprite number is
#: not one index but four.
FIRST_SHOOTER = 0xC9  # shooter table, IDs counting from 1
FIRST_GENERATOR = 0xCB  # generator table, IDs counting from 1
FIRST_STUNNED = 0xDA  # sprite = number - $DA + $04, spawned stunned
FIRST_SCROLL = 0xE7  # ID = number - $E7, into the layer 1 scroll table

#: The first Koopa, which is where the stunned range lands: the loader does
#: ``SBC #$DA / ADC #GreenKoopa``, so ``$DA`` is a stunned green Koopa.
GREEN_KOOPA = 0x04

#: The goal tape, and the one sprite on this cartridge that reads its extra
#: bits. Its ``Status01`` copies the whole Y high byte into ``$187B`` and
#: masks the coordinate back down to ``AND #$01``, so it survives bits that
#: delete any other sprite -- see :meth:`Sprite.fields`.
GOAL_TAPE = 0x7B

#: What the goal tape makes of those two bits: crossing the tape stores
#: ``bits + 1`` into ``$0DD5``, the exit the level activates.
GOAL_EXITS = (
    (0, "Normal exit"),
    (1, "Secret exit"),
    (2, "Yoshi's Island, no exit"),
    (3, "Exit 4"),
)

#: The numbers inside those ranges that the loader intercepts first, each one a
#: routine that loads several sprites at once rather than the one the record
#: names. ``$DE`` sits inside the stunned range and ``$E0``-``$E6`` between it
#: and the scroll commands, so neither is reachable by indexing a table; which
#: number reaches which is the chain of comparisons in
#: ``NorSpr0E1_LoadBooCeiling``. The names are bundled with the rest -- see
#: :mod:`shiny_mushroom.metadata`.
LOADERS = SPRITES.loaders

#: What a number the tables do not cover is called. ``$F6`` and up index past
#: the fifteen scroll routines; the cart never places one, and a hack that does
#: gets an honest answer rather than a name.
UNKNOWN = "Unknown"


class SpriteKind(Enum):
    """What a sprite number means, from the ranges the loader branches on.

    Only :attr:`SPRITE` puts a sprite where the record says. The rest are
    spawners and commands that an editor must not draw as if they were enemies
    -- but must still show, because they are in the level and they do something.
    """

    SPRITE = "sprite"
    SPAWNER = "spawner"  # shooters, generators, and the multi-sprite loaders
    COMMAND = "command"  # layer scroll commands

    @classmethod
    def of(cls, number: int) -> SpriteKind:
        if number < FIRST_SHOOTER:
            return cls.SPRITE
        if number < FIRST_STUNNED:  # $C9-$CA shooters, $CB-$D9 generators
            return cls.SPAWNER
        if number < FIRST_SCROLL:
            # $DA-$DF are drawn: the loader turns them into Koopas and spawns
            # them stunned. The loaders in among them are not -- each one puts
            # its own sprites somewhere else, or nowhere yet.
            return cls.SPAWNER if number in LOADERS else cls.SPRITE
        return cls.COMMAND


class SpriteCategory(Enum):
    """What sort of thing a sprite is: an enemy, a powerup, a platform.

    Beside :class:`SpriteKind` rather than instead of it, because the two answer
    different questions. A *kind* is what the loader does with the number, and
    it decides what this module does: whether the record has a position, what
    glyph stands in for it, whether it can have artwork at all. A *category* is
    what the sprite is **for**, and it decides nothing here -- it is what a
    person sorts the catalogue by when they are looking for something to put in
    a level, and what the properties panel says a record is.

    **This is the one thing about a sprite the cartridge does not decide.** The
    ranges, the names and the behaviour flags are all read out of the
    disassembly; nothing in the ROM says a Koopa is an enemy, and the tweaker
    bits do not imply it either -- a Thwomp and a Rex share most of theirs. So
    the normal sprites' categories are written down by hand in
    `smw_tools.sprite_categories`, which is the only judgement in the generated
    metadata and is checked against the dispatch table both ways so that a
    sprite cannot silently fall out of it. See :mod:`shiny_mushroom.metadata`.

    :attr:`SPAWNER` and :attr:`COMMAND` are the exception and are not judged:
    for a shooter, a generator, a loader or a scroll command there is nothing
    left to decide once the loader's range is known, so the metadata carries
    them by the range they fall in. Both
    are also available to an ordinary sprite that earns one -- an exploding
    block carries an enemy, and so does a bubble.
    """

    ENEMY = "enemy"
    BOSS = "boss"
    HAZARD = "hazard"
    POWERUP = "powerup"
    ITEM = "item"
    PLATFORM = "platform"
    TERRAIN = "terrain"
    TRIGGER = "trigger"
    NPC = "npc"
    EFFECT = "effect"
    SPAWNER = "spawner"
    COMMAND = "command"
    #: A dispatch table entry the disassembly found no use for. Read off the
    #: routine's own name rather than decided -- see `sprite_categories`.
    UNUSED = "unused"
    #: A number no table names. Not a sort of sprite: the same answer
    #: :data:`UNKNOWN` is for a name, said the same way.
    UNKNOWN = "unknown"

    @property
    def label(self) -> str:
        """The word for a panel. ``NPC`` is the one that is not a capitalised
        lower-case word, and spelling it "Npc" would look like a typo."""
        return "NPC" if self is SpriteCategory.NPC else self.value.capitalize()


def category_of(number: int) -> SpriteCategory:
    """What sort of thing this sprite number is.

    **A lookup, and deliberately nothing more.** The bundled table carries an
    answer for every sprite number a dispatch table names -- not the pieces of
    one -- because a category is a fact about a number rather than about a
    situation: it is the same in every level, in every session and on every
    cartridge, so there is nothing for a rule here to be a function *of*. The
    work of turning the loader's four ranges into one flat table was done once
    and is written down in the bundled metadata, which is also where the stunned
    Koopas are filed with the Koopas.

    The one sprite question that stays a runtime one is which sprites the level
    in front of you contains, and that belongs to the level rather than here.
    """
    return _category(SPRITES.categories.get(number))


def placements(number: int) -> int | None:
    """How many times the shipped levels place this sprite, or ``None`` where
    nobody has counted.

    Scanned out of every level container in the disassembly by
    `editor/tools/scan_sprite_usage.py` and bundled with the names -- so this is
    a measurement of the game, available without a cartridge open, and not the
    same thing as :meth:`~shiny_mushroom.index.LevelIndex.shipped_under`, which
    answers the narrower question of *which sprite tilesets* a loaded ROM places
    it under.

    **Zero does not mean unused.** Fifty named sprites are placed by no level
    and are in the game regardless, because something else puts them there: a
    Bullet Bill comes out of a shooter, Yoshi hatches out of an egg, and
    Magikoopa's magic is thrown rather than placed. What this counts is records
    in level data. Reading more than that into it is the mistake the count
    exists to make unnecessary.

    ``None`` rather than ``0`` for an unscanned file, because "no level places
    this" and "nobody has looked" are different answers and only the first is
    evidence.
    """
    if not SPRITES.usage:
        return None
    return SPRITES.usage.get(number, 0)


def _category(name: str | None) -> SpriteCategory:
    """One category as the file spells it. A word the enum does not carry is
    :attr:`SpriteCategory.UNKNOWN` rather than an error: the file is generated
    from a checked table, so the only way here is a bundled file newer than the
    code reading it, and refusing to name a sprite is better than refusing to
    open the level it is in."""
    try:
        return SpriteCategory(name)
    except ValueError:
        return SpriteCategory.UNKNOWN


#: What stands in for each kind when there is nothing to draw. Keyed on the kind
#: rather than on the number, because what makes a record undrawable is what it
#: *is*: a spawner and a command have nothing at their own block by design,
#: while an ordinary sprite with no capture is a gap in what was observed rather
#: than a fact about the game. The three look different for that reason.
GLYPHS = {
    SpriteKind.SPRITE: glyphs.MISSING,
    SpriteKind.SPAWNER: glyphs.SPAWNER,
    SpriteKind.COMMAND: glyphs.COMMAND,
}

#: Sprite number -> the number it becomes when something reveals it, for the
#: sprites the cartridge draws nothing for until then. ``$C7``, the invisible
#: mushroom, is the one the disassembly has been read end to end for: it draws
#: nothing and, on contact, writes ``$74`` over its own entry in the game's
#: sprite ID table -- so from that moment it *is* a mushroom, and a mushroom is
#: the only honest thing to show for it. See :mod:`shiny_mushroom.metadata`.
#:
#: Not every invisible sprite has one. ``$8E``, the warp hole, has no drawing
#: code at any point in its life; it gets a glyph, and inventing a revealed form
#: for it would be a picture of something that is never on screen.
REVEALS = SPRITES.reveals


def artwork(
    number: int, art: Mapping[int, tuple[SpriteTile, ...]]
) -> tuple[tuple[SpriteTile, ...], bool]:
    """The tiles to draw for a sprite number, and whether the game hides them.

    One place decides this, because two would eventually disagree: the outline,
    the hit test and the picture all have to be about the same tiles, and a
    revealed mushroom that is painted but not measured would be a sprite you
    could see and not click.
    """
    tiles = art.get(number, ())
    if tiles:
        return tiles, False
    revealed = REVEALS.get(number)
    if revealed is None:
        return (), False
    return art.get(revealed, ()), True


def name_of(number: int) -> str:
    """What the disassembly calls this sprite number.

    The four tables in :mod:`shiny_mushroom.metadata` are indexed the way their
    own dispatchers index them, so this is where a level's sprite number is
    turned into the right index -- the same arithmetic the loader does.
    """
    if number < FIRST_SHOOTER:
        return SPRITES.normal.get(number, UNKNOWN)
    # Both of these count from 1, as the game numbers them: `ShooterSpr01` is
    # the first shooter, and is stream number $C9.
    if number < FIRST_GENERATOR:
        return SPRITES.shooter.get(number - FIRST_SHOOTER + 1, UNKNOWN)
    if number < FIRST_STUNNED:
        return SPRITES.generator.get(number - FIRST_GENERATOR + 1, UNKNOWN)
    if number < FIRST_SCROLL:
        if number in LOADERS:
            return LOADERS[number]
        koopa = SPRITES.normal.get(number - FIRST_STUNNED + GREEN_KOOPA, UNKNOWN)
        return f"{koopa} (stunned)"
    return SPRITES.scroll.get(number, UNKNOWN)


@dataclass(frozen=True)
class Sprite:
    """One record, placed."""

    number: int
    #: Block coordinates in the level, the same units the Map16 tilemap uses.
    column: int
    row: int
    screen: int
    extra_bits: int

    #: Position in the level's sprite list, counting from zero. Also its depth:
    #: the records are drawn in order, so a higher index covers a lower one.
    index: int = 0

    #: Byte offset of the record within the stream, and the record itself. The
    #: offset is what identifies a sprite: two identical records in a level are
    #: two sprites, and neither position nor contents tells them apart. Not the
    #: index, which moves when a record before it is inserted or deleted.
    #:
    #: All three are defaulted because a sprite is also built by hand to ask a
    #: question about geometry -- what it covers, what is under a pixel -- and
    #: inventing a record to ask that would say nothing. :func:`parse_sprites`
    #: sets them.
    offset: int = 0
    data: bytes = b""

    #: A number that identifies this record for as long as the level is open --
    #: an object's :attr:`~shiny_mushroom.objects.LevelObject.uid`, from the same
    #: pool, so one number names one record whichever stream it came from. See
    #: that attribute for why a selection is held by it rather than by
    #: :attr:`offset`.
    uid: int = 0

    #: Whether this record was read off a cartridge whose extra bits can mean
    #: anything at all -- the custom sprites feature. Carried on the record
    #: rather than asked per call because everything derived from it -- the
    #: name, the artwork key, the properties row -- has to answer the same
    #: way for one record, and on a stock cartridge the bit is position that
    #: deletes the sprite, not a meaning.
    custom_capable: bool = False

    #: The extra bytes a custom record carries behind its three, as many as
    #: the sprite's metadata declares -- the loader's own stride, consumed
    #: by the spawn seam into the slot's tables. Empty for every vanilla
    #: record and for a custom sprite that declares none.
    extra_bytes: bytes = b""

    #: What the project calls this number where the custom bit hands the
    #: record to its own code -- stamped at the parse, like
    #: :attr:`custom_capable`, so every reparse names the record the way
    #: the first read did. Empty for a vanilla record, and for a custom
    #: sprite the project never named.
    custom_name: str = ""

    @property
    def kind(self) -> SpriteKind:
        return SpriteKind.of(self.number)

    @property
    def custom(self) -> bool:
        """Whether this record spawns the project's own sprite.

        The second extra bit, PIXI's convention, read only where the
        cartridge reads it: a normal-range number on a custom-sprites build.
        The goal tape is the one number that cannot carry it -- Lunar Magic
        spends both of its extra bits on secret exits -- and the spawn stub
        leaves its flag unset, so this says the same.
        """
        return (
            self.custom_capable
            and self.kind is SpriteKind.SPRITE
            and self.number != GOAL_TAPE
            and bool(self.extra_bits & 0b10)
        )

    @property
    def art_key(self) -> int:
        """Which capture draws this record: the number, or the custom space's
        copy of it -- a custom sprite's picture is its own code's, not the
        vanilla sprite's that shares its byte."""
        return self.number | CUSTOM_ART_BASE if self.custom else self.number

    @property
    def category(self) -> SpriteCategory:
        return category_of(self.number)

    @property
    def placements(self) -> int | None:
        """How many times the shipped levels place this sprite number. See
        :func:`placements` for what the answer is and is not evidence of."""
        return placements(self.number)

    @property
    def movable(self) -> bool:
        """Whether this record has a position an edit can change.

        A scroll command has none: the bits an ordinary sprite spends on the
        across axis and its extra bits are one field for a command -- the
        layer's scroll type -- so moving one would rewrite what it does. It
        still sits on a screen, and that screen is still where it acts, but the
        editor has nothing finer to offer than the record it already has.
        """
        return self.kind is not SpriteKind.COMMAND

    def placed_at(self, column: int, row: int, shape: Geometry) -> Sprite:
        """This sprite with its block moved to ``(column, row)``.

        The screen goes with it, for the reason an object's does: a record's
        screen is not an independent field but which screen the position falls
        on, and ``shape`` decides which axis is counted.
        """
        return replace(
            self, column=column, row=row, screen=shape.screen_of(column, row)
        )

    @property
    def name(self) -> str:
        """What this sprite is, in the disassembly's own vocabulary -- or the
        project's, for a record the custom bit hands to its own code."""
        if self.custom:
            return self.custom_name or f"Custom sprite {hexnum(self.number)}"
        return name_of(self.number)

    def describe(self) -> str:
        """One line for a status bar, and the heading over the properties.

        Which sprite number this is, what that number is called, and where it
        sits -- and nothing else, because everything else the record says is a
        row below it.
        """
        return f"{hexnum(self.number)} {self.name} - {hexspot(self.column, self.row)}"

    def properties(self, shape: Geometry | None = None) -> list[tuple[str, str]]:
        """Every field of the record, as label/value pairs.

        Derived from :meth:`fields`, for the reason an object's is: the readout
        and the editors describe one record and must not be able to disagree
        about it.
        """
        return pairs(self.fields(shape or ANY_SHAPE), self)

    def fields(self, shape: Geometry) -> list[Field]:
        """Every field of the record, as descriptors a panel can edit.

        The same rules an object's list follows -- identity is a choice from
        the disassembly's own names, the position is editable and the screen it
        implies is not, and a command gets its own field in place of a position
        it does not have.

        **The sprite number is a plain number as well as a choice.** There are
        two hundred of them and the useful ones are scattered across the range,
        so the list is how a sprite is found; but a number the tables do not
        name is still a legal record, and :class:`~shiny_mushroom.fields.Choices`
        keeps it selectable rather than snapping it onto a neighbour.

        **The extra bits are position on this cartridge and are not offered as
        their own row.** Only the goal tape reads them, and it gets a row named
        for what it reads them as.
        """
        rows: list[Field] = [
            Field(
                key="number",
                label="Sprite",
                kind=choices(_sprite_choices()),
                read=lambda spr: spr.number,
                write=lambda spr, value: replace(spr, number=value),
                hint="Which sprite this record spawns.",
            ),
            readout(
                "Category",
                lambda spr: spr.category.label,
                "What sort of thing this is.",
            ),
            screen_row(
                "Which screen the sprite's position falls on. Not a field of "
                "its own -- it follows the position."
            ),
        ]
        if self.movable:
            rows += position_rows(shape)
            # The extra bits are not offered beside the position, because on
            # this cartridge they *are* position: the loader masks byte 0 with
            # $0D and they land in the sprite's Y high byte, where SubOffscreen
            # reads them as having fallen out of the level and deletes the
            # record. Only the goal tape takes them back out again, so only
            # the goal tape gets a row -- under the name of what it does with
            # them. Shooters mask them off ($01) and a scroll command spends
            # them on its type, below.
            #
            # A custom-sprites cartridge is the exception the feature exists
            # to make: its spawn stub reads the second bit as *this number is
            # the project's own*, so the row appears exactly where the bit
            # means something -- and nowhere else, because on a stock
            # cartridge setting it deletes the sprite on the frame it spawns.
            if (
                self.custom_capable
                and self.kind is SpriteKind.SPRITE
                and self.number != GOAL_TAPE
            ):
                rows.append(
                    Field(
                        key="custom",
                        label="Custom",
                        kind=Flags(((0b10, "Custom sprite"),)),
                        read=lambda spr: spr.extra_bits,
                        write=lambda spr, value: replace(spr, extra_bits=value),
                        hint="Set, this record spawns the project's own "
                        "sprite of this number -- its code and properties "
                        "under Project > Source Files -- instead of the "
                        "game's.",
                    )
                )
            if self.number == GOAL_TAPE:
                rows.append(
                    Field(
                        key="exit",
                        label="Exit",
                        kind=choices(GOAL_EXITS),
                        read=lambda spr: spr.extra_bits,
                        write=lambda spr, value: replace(spr, extra_bits=value),
                        hint="Which exit crossing this tape activates. 2 "
                        "moves the player to the Yoshi's Island submap; "
                        "3 has no event on the shipped overworld.",
                    )
                )
        else:
            # A scroll command spends the bits a position and the extra bits
            # would use on one field, the layer's scroll type, so the position
            # rows are replaced by this one rather than shown beside it.
            rows.append(
                Field(
                    key="scroll-type",
                    label="Scroll type",
                    kind=Number(0x00, 0x3F, hexadecimal=True),
                    read=lambda spr: _scroll_type(spr, shape),
                    write=lambda spr, value: _write_scroll_type(spr, value, shape),
                    hint="Which scrolling behaviour this command sets for its layer.",
                )
            )
        rows += record_rows("Sprite")
        return rows


def _sprite_choices() -> list[tuple[int, str]]:
    """Every sprite number, with the name the disassembly gives it.

    The whole byte, not only the named part: unlike an object number, a sprite
    number is meaningful across the range -- the shooters, generators and
    loaders are all up there -- and :func:`name_of` already does the arithmetic
    that turns a number into whichever table names it.
    """
    return [(number, f"{hexnum(number)} {name_of(number)}") for number in range(0x100)]


def _scroll_type(sprite: Sprite, shape: Geometry) -> int:
    """A scroll command's type: the top six bits of its first byte.

    The loader keeps them for the layer's scrolling behaviour (``LSR / LSR``
    into ``!RAM_SMW_L1ScrollSpr_ScrollTypeIndex``), and they are the same six
    bits an ordinary sprite spends on its across axis and its extra bits.
    """
    across = sprite.column if shape.vertical else sprite.row
    return ((across & 0x0F) << 2) | (sprite.extra_bits & 0x03)


def _write_scroll_type(sprite: Sprite, value: int, shape: Geometry) -> Sprite:
    """The command with a new scroll type.

    Written through the *semantic* fields the six bits are made of, not over
    the record's bytes: :func:`_sprite_bytes` builds byte 0 from the across axis
    and the extra bits and never looks at :attr:`Sprite.data`, so a raw-byte
    edit would be discarded by the next rewrite without saying so.
    """
    across = sprite.column if shape.vertical else sprite.row
    across = (across & ~0x0F) | ((value >> 2) & 0x0F)
    if shape.vertical:
        moved = replace(sprite, column=across)
    else:
        moved = replace(sprite, row=across)
    return replace(moved, extra_bits=value & 0x03)


def parse_sprites(
    stream: bytes,
    shape: Geometry,
    custom_sprites: bool = False,
    extra_counts: Mapping[int, int] = {},
    custom_names: Mapping[int, str] = {},
) -> list[Sprite]:
    """Read a sprite stream into placed sprites.

    ``stream`` is the one-byte header followed by three-byte records; a
    terminator or a short tail ends it. ``shape`` decides the axis swap, so the
    same stream reads differently in a vertical level -- which is not a quirk of
    this code but of the loader it follows. ``custom_sprites`` says whether the
    cartridge these records are for reads the second extra bit as the custom
    flag -- see :attr:`Sprite.custom` -- and ``extra_counts`` how many extra
    bytes each custom number's records carry behind their three, which is the
    loader's own stride: a stream read under the wrong counts misparses from
    the first custom record on, exactly as the cartridge would.
    ``custom_names`` is what the project calls each custom number, stamped
    onto the records the bit marks so everything derived from one -- the
    status bar, the properties heading, the create panel's key -- says the
    project's own word for it.
    """
    sprites = []
    cursor = 1  # past the header byte: memory setting and buoyancy, not a record
    while cursor + RECORD_SIZE <= len(stream) and len(sprites) < MAX_RECORDS:
        record = stream[cursor : cursor + RECORD_SIZE]
        first, second, number = record
        if first == TERMINATOR:
            break
        offset = cursor
        cursor += RECORD_SIZE
        extra = b""
        named = ""
        if (
            custom_sprites
            and first & 0x08
            and number < FIRST_SHOOTER
            and number != GOAL_TAPE
        ):
            held = extra_counts.get(number, 0)
            extra = stream[cursor : cursor + held]
            cursor += held
            named = custom_names.get(number, "")

        screen = (second & 0x0F) | ((first << 3) & 0x10)
        along = screen * SCREEN_COLUMNS + (second >> 4)
        # Bit 0 only. Bits 2-3 are the extra bits, riding in the same byte.
        across = (first >> 4) | ((first & 0x01) << 4)
        column, row = (across, along) if shape.vertical else (along, across)
        sprites.append(
            Sprite(
                number=number,
                column=column,
                row=row,
                screen=screen,
                extra_bits=(first >> 2) & 0x03,
                index=len(sprites),
                offset=offset,
                data=record,
                custom_capable=custom_sprites,
                extra_bytes=extra,
                custom_name=named,
            )
        )
    return sprites


def encode_sprites(sprites: Iterable[Sprite], shape: Geometry, header: int) -> bytes:
    """Write placed sprites back out as a sprite stream, header and terminator.

    The exact inverse of :func:`parse_sprites` for a stream nobody has edited:
    ``encode_sprites(parse_sprites(s, shape), shape, s[0]) == s``. Simpler than
    the object stream's encoder in the one way that matters -- every record is
    three bytes and none of them is a command that moves a cursor -- so the list
    that goes in is the list that comes out, record for record, and a caller can
    zip its own identities back on by position.

    ``header`` is the byte the stream opens with: the sprite memory setting and
    the buoyancy flag, neither of which is a record and neither of which this
    module reads. Passed through so a stream can be rewritten without the caller
    having to know what is in it.

    Raises :class:`UnencodableSprite` for the one placement the format cannot
    hold -- see the exception.
    """
    stream = bytearray((header,))
    for sprite in sprites:
        stream += _sprite_bytes(sprite, shape)
        # The record's own extra bytes, behind its three -- the loader's
        # stride for a custom number that declares any. What the record
        # holds is what goes back out; keeping them to the declared count is
        # the document's business, at the moment the count is a question.
        stream += sprite.extra_bytes
    stream.append(TERMINATOR)
    return bytes(stream)


def _sprite_bytes(sprite: Sprite, shape: Geometry) -> bytes:
    """One sprite as its three bytes.

    Every field lands back in the bits :func:`parse_sprites` reads it out of,
    which for byte 0 means three different ones interleaved: the across axis
    split between its high nibble and bit 0, the extra bits in bits 2-3, and the
    screen's fifth bit in bit 1. They share the byte deliberately, and writing
    the position over all of it is the mistake this function exists to not make.
    """
    along, across = (
        (sprite.row, sprite.column) if shape.vertical else (sprite.column, sprite.row)
    )
    screen, within = divmod(along, SCREEN_COLUMNS)
    first = (
        ((across & 0x0F) << 4)
        | ((across >> 4) & 0x01)
        | (((screen >> 4) & 0x01) << 1)
        | ((sprite.extra_bits & 0x03) << 2)
    )
    if first == TERMINATOR:
        raise UnencodableSprite(
            f"a sprite at {hexspot(sprite.column, sprite.row)} with extra "
            f"bits {sprite.extra_bits} would end the stream where it stands"
        )
    second = ((within & 0x0F) << 4) | (screen & 0x0F)
    return bytes((first, second, sprite.number))


@dataclass(frozen=True)
class Bounds:
    """A rectangle in image pixels, top-left inclusive."""

    left: int
    top: int
    width: int
    height: int

    def contains(self, x: int, y: int) -> bool:
        return (
            self.left <= x < self.left + self.width
            and self.top <= y < self.top + self.height
        )

    def at(self, x: int, y: int) -> Bounds:
        """The same box with its corner taken as relative to ``(x, y)``."""
        return Bounds(x + self.left, y + self.top, self.width, self.height)


def bounds(sprite: Sprite, art: Mapping[int, tuple[SpriteTile, ...]]) -> Bounds:
    """What the sprite covers on screen: the box its captured tiles fill.

    A sprite is not the block it is recorded on -- a Banzai Bill is five blocks
    wide and a Koopa stands a block taller than its record says. The box the
    game's own drawing code fills is the honest answer to both "what am I
    pointing at" and "where does this reach", and it is the same box either
    question is asked of, so the outline and the hit test cannot disagree.

    The record's block is the origin and :func:`_extent` is the reach from it,
    fallback included -- a sprite with no captured art is its own block, which
    is the floor the marker has always been: the record is in the level and it
    does something, whether or not anything is drawn for it.
    """
    tiles, _ = artwork(sprite.art_key, art)
    return _extent(tiles).at(sprite.column * BLOCK, sprite.row * BLOCK)


def _extent(tiles: Sequence[SpriteTile]) -> Bounds:
    """The box a capture's tiles fill, measured from the sprite's own origin.

    Offsets are signed, so ``left`` and ``top`` are negative for anything
    reaching above or to the left of the record's block. No tiles at all -- a
    spawner, a command, or a sprite the probe could not make draw -- is one
    block at the origin: the floor a marker and a glyph are drawn in, so the
    outline, the hit test and the picture agree about a stood-in sprite.
    """
    if not tiles:
        return Bounds(0, 0, BLOCK, BLOCK)
    left = min(tile.x for tile in tiles)
    top = min(tile.y for tile in tiles)
    right = max(tile.x + _tile_side(tile) for tile in tiles)
    bottom = max(tile.y + _tile_side(tile) for tile in tiles)
    return Bounds(left, top, right - left, bottom - top)


def _tile_side(tile: SpriteTile) -> int:
    """How far one OAM object reaches from its own corner. A large object is the
    four quadrants of a block, whichever way it is flipped."""
    return BLOCK if tile.large else TILE


def stack_at(
    sprites: list[Sprite],
    x: int,
    y: int,
    art: Mapping[int, tuple[SpriteTile, ...]],
) -> list[Sprite]:
    """Every sprite covering an image pixel, front to back.

    Reversed, because later records draw on top: the first of the list is what
    the pixel *shows*, and the rest are what is hidden behind it. Sprites
    overlap freely -- a Koopa on a moving platform, a shell inside a block --
    and the whole stack is what lets a repeated click reach past the front one
    instead of forcing the layer off to get at what is under it.
    """
    return [
        sprite for sprite in reversed(sprites) if bounds(sprite, art).contains(x, y)
    ]


def within(
    sprites: Iterable[Sprite],
    left: int,
    top: int,
    right: int,
    bottom: int,
    art: Mapping[int, tuple[SpriteTile, ...]],
) -> list[Sprite]:
    """Every sprite whose artwork reaches into a **pixel** rectangle, in record
    order.

    Pixels rather than blocks, because that is what a sprite's box is measured
    in -- and touching is enough, for the reason it is enough for an object: a
    Banzai Bill is five blocks wide, and a box over its nose has caught the
    Banzai Bill.
    """
    caught = []
    for sprite in sprites:
        box = bounds(sprite, art)
        if (
            box.left <= right
            and box.left + box.width > left
            and box.top <= bottom
            and box.top + box.height > top
        ):
            caught.append(sprite)
    return caught


def at(
    sprites: list[Sprite],
    x: int,
    y: int,
    art: Mapping[int, tuple[SpriteTile, ...]],
) -> Sprite | None:
    """The sprite covering an image pixel, if any. Later records win, as they
    draw on top."""
    stack = stack_at(sprites, x, y, art)
    return stack[0] if stack else None


# -- drawing what they look like ---------------------------------------------

#: OBJ tiles start at VRAM word ``$6000``, set once at reset -- so byte
#: ``$C000``, and a sprite tile number indexes 32 bytes at a time from there.
#: The four OBJ slots SP1-SP4 are consecutive from it, which is why one base
#: plus the tile number covers all of them.
OBJ_VRAM_BASE = 0xC000

#: A 16x16 object is four tiles: ``n`` and ``n+1`` side by side, ``n+16`` and
#: ``n+17`` beneath them -- the next row of a 16-wide grid, not the next two
#: numbers.
LARGE_QUADRANTS = ((0, 0, 0), (TILE, 0, 1), (0, TILE, 16), (TILE, TILE, 17))


@dataclass(frozen=True)
class SpritePlane:
    """Every pixel a level's sprites paint, decoded once and kept.

    A **run** is one horizontal stretch of opaque pixels, as the byte offset it
    starts at in a raster of this size and the colours to write there. Laying
    the sprites over a picture is then a few thousand slice assignments rather
    than a 4bpp decode of every tile: measured on level ``$105``, 14 ms of
    compositing becomes well under one.

    That is what makes a repaint affordable. Every repaint lays the whole plane
    down again -- a block that moved can sit under a sprite, so patching around
    them would leave holes -- but a sprite's artwork is a *capture* of one frame
    of its drawing code and does not move between repaints, so decoding it again
    each time would cost more than the level itself.

    The size is carried so a plane cannot be laid over a picture it was not
    measured for: the offsets are absolute, and a level that changed shape
    underneath them would paint its sprites into the wrong rows.

    :attr:`markers` is a **second pass, laid down after the first**, and holds
    what the *editor* draws rather than what the game does: the glyphs, and the
    hidden sprites revealed at half strength. Both are annotations. A spawner's
    glyph is not in the level's picture at any point, and a hidden mushroom is
    the picture of something the game is deliberately not showing -- so letting
    a Koopa recorded after either one bury it hides the very thing the mark
    exists to point at. They go on top, and among themselves they keep record
    order.

    Both passes are **pure writes**, which is what keeps laying a plane down a
    few thousand slice assignments and makes it idempotent: the same plane over
    the same picture twice leaves what it left once. Half strength is therefore
    a **stipple**, decided at decode time rather than blended at paint time:
    every other pixel of it is simply left out, and what is underneath shows
    between them. Zoomed out that averages to the 50% it stands for; at 1:1 it
    reads as a ghost.
    """

    width: int
    height: int

    #: What the cartridge draws, in record order.
    runs: tuple[tuple[int, bytes], ...]

    #: What the editor draws over it: glyphs and hidden sprites.
    markers: tuple[tuple[int, bytes], ...] = ()


def plane(
    width: int,
    height: int,
    sprites: list[Sprite],
    art: Mapping[int, tuple[SpriteTile, ...]],
    vram: bytes,
    cgram: bytes,
) -> SpritePlane:
    """Decode what every sprite in ``sprites`` paints, in drawing order.

    Transparent pixels are *left out* rather than filled: a sprite stands in
    front of the level, so colour 0 has to show the tiles behind it. That is the
    one way this differs from drawing a background tile, and doing it the
    background way would box every sprite in its own rectangle of backdrop.

    Three things can be drawn for a record, in this order of preference:

    - **its own artwork**, wherever the probe captured any. In record order,
      with the rest of the level's sprites, because that is the game's picture
      and its depth is the game's business;
    - **its revealed form**, stippled, where the game draws nothing until
      something reveals it -- see :func:`artwork`;
    - **a glyph**, where there is nothing honest to draw at all -- see
      :mod:`shiny_mushroom.glyphs`.

    The last two are the editor's marks rather than the level's picture, so they
    go into :attr:`SpritePlane.markers` and are laid over all of it. Both point
    at something that would otherwise be invisible, and a mark another sprite is
    allowed to bury does not do that job.
    """
    runs: list[tuple[int, bytes]] = []
    markers: list[tuple[int, bytes]] = []
    colors = palette(cgram)
    for sprite in sprites:
        origin_x = sprite.column * BLOCK
        origin_y = sprite.row * BLOCK
        tiles, hidden = artwork(sprite.art_key, art)
        if not tiles:
            glyphs.draw(
                markers,
                width,
                height,
                origin_x,
                origin_y,
                GLYPHS[sprite.kind],
                f"{sprite.number:02X}",
            )
            continue
        into = markers if hidden else runs
        for tile in _back_to_front(tiles):
            _tile_runs(
                into,
                width,
                height,
                tile,
                origin_x + tile.x,
                origin_y + tile.y,
                vram,
                colors,
                stipple=hidden,
            )
    return SpritePlane(width, height, tuple(runs), tuple(markers))


def player_plane(
    width: int,
    height: int,
    tiles: Iterable[SpriteTile],
    at: PlayerPosition,
    vram: bytes,
    cgram: bytes,
) -> SpritePlane:
    """What the player paints, positioned at ``at``.

    The same decode as :func:`plane`, for one figure at an arbitrary pixel
    rather than for a list of sprites at their records' positions -- which is
    what a start marker is.

    A :class:`~shiny_mushroom.rom_patches.PlayerPosition` and not a floor: the tiles
    are laid down at the offsets they were captured at, measured against that
    same position, which is what the game's drawing routine did with them. So
    the figure lands where the game would put it without this having to know how
    tall he is -- and a big or crouching Mario would come out right unchanged.

    **Its VRAM and CGRAM are the capture's, not the level's.** The player's
    tiles are DMA'd per frame and a level's VRAM is read before that happens, so
    passing a snapshot's memories here draws whatever else is at those tile
    numbers -- see :class:`~shiny_mushroom.sprite_art.PlayerArt`.
    """
    tiles = tuple(tiles)
    if not tiles:
        return SpritePlane(width, height, ())
    colors = palette(cgram)
    runs: list[tuple[int, bytes]] = []
    for tile in _back_to_front(tiles):
        _tile_runs(
            runs, width, height, tile, at.x + tile.x, at.y + tile.y, vram, colors
        )
    return SpritePlane(width, height, tuple(runs))


def player_bounds(tiles: Iterable[SpriteTile], at: PlayerPosition) -> Bounds:
    """The box :func:`player_plane` would paint into, for the same arguments."""
    return _extent(tuple(tiles)).at(at.x, at.y)


def paint(raster: Raster, sprite_plane: SpritePlane) -> Raster:
    """``raster`` with a plane's pixels laid over it, in the order it holds
    them -- so a sprite recorded later covers one recorded earlier."""
    pixels = bytearray(raster.pixels)
    paint_into(pixels, raster.width, raster.height, sprite_plane)
    return Raster(raster.width, raster.height, bytes(pixels))


def paint_into(
    pixels: bytearray, width: int, height: int, sprite_plane: SpritePlane
) -> None:
    """The same, into a buffer that is already there.

    For anything drawing repeatedly: a picture of a whole level is megabytes,
    and :func:`paint` copies it twice -- once to work on and once to hand back.
    A repaint that only rewrites the blocks an edit moved would spend all of its
    time in those copies rather than in the drawing.

    The game's picture first, then the editor's marks over it -- see
    :class:`SpritePlane`. Every run of both is a slice assignment, hidden
    sprites included, so laying the same plane down twice leaves the picture
    laying it down once did. `ui.picture.Picture` depends on that: it re-lays
    the whole plane on every repaint, over a buffer where only the blocks an
    edit moved have been redrawn.
    """
    if (sprite_plane.width, sprite_plane.height) != (width, height):
        raise ValueError(
            f"a {sprite_plane.width}x{sprite_plane.height} sprite plane cannot be "
            f"laid over a {width}x{height} picture"
        )
    for offset, run in (*sprite_plane.runs, *sprite_plane.markers):
        pixels[offset : offset + len(run)] = run


def drawn(
    raster: Raster,
    sprites: list[Sprite],
    art: Mapping[int, tuple[SpriteTile, ...]],
    vram: bytes,
    cgram: bytes,
) -> Raster:
    """``raster`` with each sprite's captured artwork composited onto it.

    Decode and lay down in one call, for a picture drawn once. Anything drawing
    the same sprites repeatedly should keep the :func:`plane` and :func:`paint`
    it instead.
    """
    return paint(raster, plane(raster.width, raster.height, sprites, art, vram, cgram))


def _back_to_front(
    tiles: tuple[SpriteTile, ...],
) -> tuple[SpriteTile, ...]:
    """One sprite's captured tiles in the order they have to be painted.

    A capture holds them in ascending OAM object index, which is the order the
    game's own drawing code wrote them -- and on the SNES **a lower OAM index
    draws in front**. Painting is the other way round, last write wins, so a
    sprite laid down in capture order is assembled inside out: whatever it
    considers hindmost ends up on top.

    That is not a subtle wrongness. Big Boo's face is the first three objects
    its routine writes and its body the seventeen after them, so painting
    forwards loses the face entirely; a Wiggler's head is object 1 and its
    segments 2-5, so it is buried by its own tail.

    Only within one sprite. Which of two *different* sprites is in front is
    decided by the level's record order -- see :func:`plane` -- because a
    capture drives each one through the same slot and so cannot compare them.
    """
    return tuple(reversed(tiles))


def _tile_runs(
    runs: list[tuple[int, bytes]],
    width: int,
    height: int,
    tile: SpriteTile,
    left: int,
    top: int,
    vram: bytes,
    colors: Sequence[bytes],
    stipple: bool = False,
) -> None:
    quadrants = LARGE_QUADRANTS if tile.large else ((0, 0, 0),)
    row_base = tile.palette * COLORS_PER_ROW
    for dx, dy, step in quadrants:
        # A flip mirrors the arrangement of the four quadrants as well as the
        # pixels inside each one; doing only the second leaves a 16x16 sprite
        # facing the right way but assembled inside out.
        x = (TILE - dx) if (tile.large and tile.x_flip) else dx
        y = (TILE - dy) if (tile.large and tile.y_flip) else dy
        _quadrant_runs(
            runs,
            width,
            height,
            (tile.tile + step) & 0x1FF,
            left + x,
            top + y,
            vram,
            colors,
            row_base,
            tile.x_flip,
            tile.y_flip,
            stipple,
        )


def _quadrant_runs(
    runs: list[tuple[int, bytes]],
    width: int,
    height: int,
    number: int,
    left: int,
    top: int,
    vram: bytes,
    colors: Sequence[bytes],
    row_base: int,
    x_flip: bool,
    y_flip: bool,
    stipple: bool = False,
) -> None:
    """One 8x8 tile's opaque pixels, as runs. A row that is opaque throughout is
    one run; a gap of colour 0 ends the run and starts another.

    ``stipple`` drops every other pixel, on a checkerboard measured in the
    picture's own coordinates so that the pattern stays aligned across the tiles
    of one sprite instead of restarting four times inside a 16x16. It is how a
    hidden sprite is drawn at half strength -- see :class:`SpritePlane`.
    """
    base = OBJ_VRAM_BASE + number * BYTES_PER_TILE
    planes = vram[base : base + BYTES_PER_TILE]
    if len(planes) < BYTES_PER_TILE:
        return
    stride = width * 3
    for row in range(TILE):
        source = TILE - 1 - row if y_flip else row
        plane0, plane1 = planes[source * 2], planes[source * 2 + 1]
        plane2, plane3 = planes[16 + source * 2], planes[16 + source * 2 + 1]
        y = top + row
        if not 0 <= y < height:
            continue
        run: list[bytes] = []
        start = 0
        for column in range(TILE):
            bit = column if x_flip else TILE - 1 - column
            index = (
                ((plane0 >> bit) & 1)
                | (((plane1 >> bit) & 1) << 1)
                | (((plane2 >> bit) & 1) << 2)
                | (((plane3 >> bit) & 1) << 3)
            )
            x = left + column
            # Transparent lets the level show through, off the edge is not in
            # the picture at all, and a stippled pixel is deliberately one of
            # the gaps. Each ends the run being gathered.
            if not index or not 0 <= x < width or (stipple and (x + y) & 1):
                if run:
                    runs.append((start, b"".join(run)))
                    run = []
                continue
            if not run:
                start = y * stride + x * 3
            run.append(colors[row_base + index])
        if run:
            runs.append((start, b"".join(run)))
