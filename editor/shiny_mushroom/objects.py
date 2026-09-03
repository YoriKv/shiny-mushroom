"""The level's object stream: what is in it, where it lands, and outlining it.

An object is the level's *source*. The Map16 tilemap the emulator hands back is
what the game made of it -- a grid of finished tiles with no record of which
object put each one there -- so this is the only layer that can say "that ledge
is one object" rather than "those forty blocks happen to look alike". Reading
it needs no emulator: the stream is in the cartridge, three bytes per record.

Everything here follows ``SMW_LoadLevelDataObject`` and the dispatchers it calls
in bank ``$0D``. Four things in that routine are not visible in the record
layout and are why this is a module rather than a comprehension:

- **Records are 3 bytes, except one.** Extended object ``$00``, the screen exit,
  reads a fourth byte and advances the pointer itself. Walking the stream three
  at a time therefore desynchronises the moment a level has an exit in it, and
  every record after that reads as garbage.
- **The screen is a running cursor, not a field.** Byte 0's high bit means "one
  screen further on", and extended object ``$01`` sets the cursor outright. A
  record's screen is a consequence of every record before it.
- **A vertical level swaps the position nibbles**, as it does for sprites --
  and skips the swap for the two commands, whose low bits are not a position at
  all.
- **The settings byte means whatever the object's routine decides**, and there
  are 315 of those. What each one reads it as was measured against the running
  loader and is bundled with the app, so :meth:`LevelObject.fields` can offer a
  width, a height, a length or a variant by name. A *record*, having no tileset,
  still claims only what the format promises -- see :attr:`LevelObject.width`.

Three different questions about an object's shape are answered in three
different places, and keeping them apart is what stops any of them from
pretending to be another:

1. **What does the record say?** :attr:`LevelObject.width` and
   :attr:`LevelObject.height`, derived from the settings byte for the fourteen
   objects the format promises a size for and ``1 x 1`` otherwise. The fallback,
   for when nothing better is known.
2. **What does this object's byte mean?** The measured roles, by tileset and
   number, through :meth:`LevelObject.fields`. What the properties panel renders
   and what the resize keys step.
3. **What did the object actually draw?** Observed from the loader as a
   footprint and passed in to :func:`stack_at`, :func:`within` and the outlines.
   The only one of the three that knows about slopes.

What an object number *means* also depends on the level's tileset, which is why
naming one takes the tileset as an argument. The names come from the
disassembly's own dispatch tables and are bundled with the app -- see
:mod:`shiny_mushroom.metadata`.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass, replace
from enum import Enum

from shiny_mushroom import metadata
from shiny_mushroom.fields import (
    Action,
    Field,
    Number,
    Switch,
    choices,
    pairs,
    position_rows,
    readout,
    record_rows,
    screen_row,
)
from shiny_mushroom.hexnum import hexnum, hexspot
from shiny_mushroom.level import ANY_SHAPE, SCREEN_COLUMNS, Geometry
from shiny_mushroom.metadata import OBJECTS

#: Bytes per record, and the one exception. The screen exit's fourth byte is the
#: destination level's low byte.
RECORD_SIZE = 3
SCREEN_EXIT_SIZE = 4

#: Ends the stream, in place of a record's first byte.
TERMINATOR = 0xFF

#: A sanity bound, not a format limit: the stream is walked until a terminator,
#: and a pointer that does not lead to one would otherwise walk the cartridge.
MAX_RECORDS = 2048

#: Object number 0 is not an object -- the settings byte is a second opcode.
EXTENDED_OBJECT = 0x00

#: The extended objects that place no tiles at all. Both act on the loader
#: rather than on the level, and neither has a position: their low bits are a
#: screen number and a destination.
SCREEN_EXIT = 0x00
SCREEN_JUMP = 0x01

#: The key a screen exit's Open Level button arrives on -- an
#: :class:`~shiny_mushroom.fields.Action` the window dispatches on, since the
#: window owns the document the destination level would replace.
OPEN_DESTINATION = "open-destination"

#: The extended objects the game cannot dispatch, from
#: :attr:`~shiny_mushroom.metadata.ObjectMetadata.crashes` -- the settings bytes
#: whose entry in the cartridge's own pointer table is ``$000000``. The loader
#: long-jumps to it and the machine is gone, ending in the first bytes of bank
#: ``$00``, so nothing can draw a picture of one and a level holding one does
#: not load. In the shipped cartridge that is ``$02``-``$0F`` and nothing else:
#: every number above them draws, including the ones the table leaves nameless,
#: because ``$98``-``$FF`` are aliases of the door at ``$47``.
#:
#: Read from the metadata rather than written down here, so a base whose table
#: is repointed -- which is the first thing a hack does with these -- says so in
#: the one file that describes its objects.
CRASHING_EXTENDED = OBJECTS.crashes


def crashes_the_loader(number: int, settings: int) -> bool:
    """Whether loading a level holding this record takes the cartridge down.

    See :data:`CRASHING_EXTENDED`. Asked before anything is put in front of the
    game's own loader -- a preview probe cannot ask about one of these, because
    the answer is not a picture but a dead machine.
    """
    return number == EXTENDED_OBJECT and settings in CRASHING_EXTENDED


#: The objects whose settings byte is a size **without knowing the tileset**:
#: ``$01``-``$0E`` share one routine in every one of the five tables, which
#: repeats a single Map16 tile over a rectangle, so the format promises that
#: much and a record can say it on its own.
#:
#: It is not the set the *cart* sizes -- measured against the loader, 210 of the
#: 315 routines read the byte as the same ``HHHHWWWW`` rectangle. Those are
#: reached through :meth:`LevelObject.fields`, which is handed the tileset;
#: this range is what is left when there is no tileset to be handed, and so is
#: exactly the reach of :attr:`LevelObject.width`.
SIZED_OBJECTS = range(0x01, 0x0F)

#: The largest extent one nibble can carry, in blocks: it holds "blocks minus
#: one", so sixteen is the format's ceiling rather than a limit the editor
#: imposes. Object ``$21`` is the exception and reaches 256, because it reads
#: the whole byte -- which is why the bound is passed to
#: :func:`_extent_field` rather than assumed by it.
MAX_EXTENT = 16


class ObjectKind(Enum):
    """What a record does, from the branch the loader takes on it."""

    STANDARD = "standard"  # a tileset object: number $01-$3F
    EXTENDED = "extended"  # number $00, settings $02 and up: one fixed tile
    COMMAND = "command"  # number $00, settings $00-$01: exit and screen jump

    @classmethod
    def of(cls, number: int, settings: int) -> ObjectKind:
        if number != EXTENDED_OBJECT:
            return cls.STANDARD
        return cls.COMMAND if settings in (SCREEN_EXIT, SCREEN_JUMP) else cls.EXTENDED


@dataclass(frozen=True)
class LevelObject:
    """One record, placed and sized as far as the format allows."""

    number: int
    #: Byte 2, and the whole of what makes one object number two different
    #: shapes. The extended object's number when :attr:`number` is zero; for
    #: everything else, a size, a variant, a length or a pair of those, decided
    #: by the routine the tileset dispatches to and measured per object -- see
    #: :meth:`fields`.
    settings: int

    #: Block coordinates of the object's origin, in the same units the Map16
    #: tilemap and the sprite list use. For a command this is the corner of the
    #: screen it acts on, because a command has no position of its own.
    column: int
    row: int
    screen: int

    #: Position in the level's object list, counting from zero. Also its depth:
    #: the loader writes the records in order and each overwrites what the last
    #: one put there, so a higher index is drawn over a lower one.
    index: int

    #: Byte offset of the record within the stream, and the record itself. The
    #: offset is what identifies an object: two identical records in a level are
    #: two objects, and neither position nor contents tells them apart. Not the
    #: index, which moves when a record before it is inserted or deleted.
    offset: int
    data: bytes

    #: A number that identifies this record for as long as the level is open,
    #: handed out by :mod:`shiny_mushroom.edit` and meaningless without it.
    #:
    #: :attr:`offset` identifies a record in *a stream*, and that is what the
    #: search and the index match on -- but it moves the moment a record before
    #: it is inserted, deleted or resized, and every edit rewrites the stream. So
    #: a *selection* is held by this instead: it survives the rewrite, which the
    #: offset does not, and it survives an undo, which nothing derived from the
    #: bytes can.
    #:
    #: Zero for a record nobody has taken ownership of -- a bare
    #: :func:`parse_objects`, or one built by hand to ask a question.
    uid: int = 0

    @property
    def kind(self) -> ObjectKind:
        return ObjectKind.of(self.number, self.settings)

    @property
    def sized(self) -> bool:
        """Whether :attr:`width` and :attr:`height` were read or assumed."""
        return self.number in SIZED_OBJECTS

    @property
    def width(self) -> int:
        """Blocks across, as far as the *format* alone says.

        Derived rather than stored, because it is nothing else: the two extents
        *are* the settings byte's two nibbles. A copy held beside the byte would
        be a second place to keep in step and a way for a record to contradict
        its own bytes.

        **This is the format's claim, not the object's size.** Outside
        :data:`SIZED_OBJECTS` it is 1, which is a statement about what can be
        known from the record alone -- what the object *drew* is observed from
        the loader and reaches whoever needs it as a footprint, and this is the
        fallback for when nothing was observed. What the byte turns out to mean
        per object is measured; see :meth:`fields`.
        """
        return _footprint(self.number, self.settings)[0]

    @property
    def height(self) -> int:
        """Blocks down, as far as the format alone says. See :attr:`width`."""
        return _footprint(self.number, self.settings)[1]

    @property
    def movable(self) -> bool:
        """Whether this record has a position an edit can change.

        A command has none: the bits a position would sit in are the screen it
        acts on, so dragging one would silently retarget a screen exit rather
        than move anything.
        """
        return self.kind is not ObjectKind.COMMAND

    def placed_at(self, column: int, row: int, shape: Geometry) -> LevelObject:
        """This object with its origin moved to ``(column, row)``.

        The screen goes with it, because a record's screen is not a field the
        editor is free to set independently: it is which screen the position
        falls on, and the stream says so by counting up to it. ``shape`` decides
        which axis is counted, exactly as it does when the record is read.
        """
        return replace(
            self, column=column, row=row, screen=shape.screen_of(column, row)
        )

    def contains(self, column: int, row: int) -> bool:
        """Whether the block at ``(column, row)`` is inside the footprint."""
        return (
            self.column <= column < self.column + self.width
            and self.row <= row < self.row + self.height
        )

    def name(self, tileset: int) -> str:
        """What this object is, in the level's tileset.

        The same number is a different object in a different tileset -- there
        are five tables and fifteen tilesets -- so the tileset is not optional.
        """
        if self.number == EXTENDED_OBJECT:
            return OBJECTS.extended.get(self.settings, "Unknown")
        group = OBJECTS.tileset_groups.get(tileset & 0x0F)
        if group is None:
            # Tileset $F indexes past the dispatcher's fifteen entries. The cart
            # never sets it; a hack that does gets an honest answer.
            return "Unknown"
        return OBJECTS.standard[group].get(self.number, "Unknown")

    def describe(self, tileset: int) -> str:
        """One line for a status bar, and the heading over the properties.

        Three things and no more: which object number this is, what that number
        is called here, and where it sits. Everything else the record says is a
        row below, where it can be read rather than scanned past.
        """
        return f"{self._number_text} {self.name(tileset)} - {self._position_text}"

    def properties(
        self, tileset: int, shape: Geometry | None = None
    ) -> list[tuple[str, str]]:
        """Every field of the record, as label/value pairs.

        Derived from :meth:`fields` rather than written beside it, so the
        readout and the editors can never disagree about what a record says.
        ``shape`` only decides what is *writable*, which a readout does not
        care about, so it is optional here and required there.
        """
        return pairs(self.fields(tileset, shape or ANY_SHAPE), self)

    def fields(self, tileset: int, shape: Geometry) -> list[Field]:
        """Every field of the record, as descriptors a panel can edit.

        ``shape`` is needed because a position is not a field that stands on its
        own: moving a record moves which screen it is on, and only the level's
        geometry knows which axis that counts along. It is the same argument
        :meth:`placed_at` takes, and for the same reason.

        What is offered for editing is decided here and not in the panel:

        - **The object number is a choice, not a number to type.** The tileset
          decides what a number means, so the list is the tileset's, and picking
          "Coins" is the operation -- `$05` is the implementation of it.
        - **Position is editable, and the screen is not.** A record's screen is
          which screen its position falls on. Offering it as its own field would
          let the two disagree, and the stream cannot express that.
        - **The settings byte is offered as what it turns out to be**, which is
          measured per object rather than assumed -- a width and a height, a
          length beside a variant, or one field over the whole byte. See
          :meth:`_size_fields`.
        - **A nibble nobody measured is offered raw, and nothing else is.**
          It is reachable no other way, so it gets a box; every other bit of
          the byte already has a field, and a second box over one of those is a
          row that says nothing and can be typed into to contradict the ones
          above. The record's own bytes are on the last row either way, so the
          byte is never out of sight.
        - **A command's own fields replace the position**, which it does not
          have: a screen exit is a destination and a screen.
        """
        if self.kind is ObjectKind.COMMAND:
            return self._command_fields()
        rows: list[Field] = [
            self._number_field(tileset),
            readout("Kind", lambda obj: obj.kind.value.capitalize()),
            screen_row(
                "Which screen the object's position falls on. Not a field of "
                "its own -- the stream counts up to it."
            ),
            *position_rows(shape),
        ]
        # Not for an extended object, either the roles or the byte: there the
        # settings byte *is* the object's number and is already the picker
        # above. Two boxes over one byte is two ways to say the same thing, and
        # they disagree the moment one of them is typed into.
        if self.kind is not ObjectKind.EXTENDED:
            size = OBJECTS.size_of(tileset, self.number)
            rows += self._size_fields(size)
            if not size.accounted_for:
                rows += self._unmeasured_fields(size)
        rows += record_rows("Object")
        return rows

    def _size_fields(self, size: metadata.ObjectSize) -> list[Field]:
        """The settings byte broken into what it was measured to mean.

        The record cannot answer this and neither can the format: the byte
        means whatever this object's routine reads it as, and there are 315 of
        those. So it is measured against the running loader and bundled --
        :mod:`shiny_mushroom.metadata`, and `docs/smw/object-sizes.md` for the
        finding. 210 of the 315 turn out to be a plain width and height, which
        is fifteen times as many as the format alone promises.

        An unmeasured nibble gets no field rather than a guessed one, and is why
        the raw byte is still offered below these when there is one -- see
        :meth:`fields`. These rows are for saying what the byte *is*.

        **Each field's key is its role** -- ``width``, ``height``, ``length``.
        That is what lets the resize keys drive the same descriptors the panel
        renders without either of them knowing which nibble the role landed in,
        or whether it took the whole byte. The one exception is an object whose
        *both* nibbles were measured as the same role: a key names one field, so
        those two are ``low-length`` and ``high-length`` and share a row.

        ``size`` is passed in rather than looked up, because the caller has
        already asked what the byte means: whether the raw byte is offered
        under these is the same question.
        """
        if size.whole is not None:
            # One field over the whole byte -- object `$21`, whose width is the
            # byte plus one and reaches 256 blocks. Its two nibbles must not be
            # offered apart, or the high one reads as a second size sixteen
            # times the first.
            return [
                _extent_field(
                    role=size.whole,
                    read=lambda obj: obj.settings,
                    write=lambda obj, value: _write_settings(obj, value),
                    maximum=0x100,
                    runaway="byte" in size.runaway,
                    held=self.settings,
                    where="the whole settings byte, unmasked",
                )
            ]
        rows = []
        # A role measured in *both* nibbles -- the two diagonal ledges and the
        # rock wall, whose byte is two lengths. Each is a field of its own, and
        # they share one row under the role's name for the reason a column and
        # a row share "Pos": two rows called "Length" is one name over two
        # different numbers, and one key over two fields is a field the resize
        # keys cannot reach.
        shared = size.low == size.high and size.low in metadata.EXTENTS
        for side, role, read, write in (
            ("low", size.low, _low_nibble, _write_low),
            ("high", size.high, _high_nibble, _write_high),
        ):
            if role == metadata.UNKNOWN:
                continue
            if role == metadata.VARIANT:
                rows.append(
                    Field(
                        key=f"{side}-variant",
                        label="Variant",
                        kind=Number(0, 0x0F, hexadecimal=True, digits=1),
                        read=read,
                        write=write,
                        hint=f"Which form of this object is drawn, from the "
                        f"{side} nibble of the settings byte. Changes what is "
                        f"drawn, not how far it reaches.",
                    )
                )
                continue
            rows.append(
                _extent_field(
                    role=role,
                    read=read,
                    write=write,
                    maximum=MAX_EXTENT,
                    runaway=side in size.runaway,
                    held=read(self),
                    where=f"the {side} nibble of the settings byte",
                    side=side if shared else "",
                )
            )
        return rows

    def _number_field(self, tileset: int) -> Field:
        """The object's identity: which object it is, from the tileset's list.

        An extended object's identity is its settings byte and a standard
        object's is its number, so the two are different fields with the same
        job -- and changing one into the other is not an edit this offers, since
        every other field would mean something else afterwards.
        """
        if self.number == EXTENDED_OBJECT:
            return Field(
                key="extended",
                label="Object",
                kind=choices(_extended_choices()),
                read=lambda obj: obj.settings,
                write=lambda obj, value: replace(obj, settings=value),
                hint="Which extended object this is.",
            )
        return Field(
            key="number",
            label="Object",
            kind=choices(_standard_choices(tileset)),
            read=lambda obj: obj.number,
            write=lambda obj, value: replace(obj, number=value),
            hint="Which object this is; the list is this level's tileset.",
        )

    def _unmeasured_fields(self, size: metadata.ObjectSize) -> list[Field]:
        """A raw box over each nibble the measurement could not pin down.

        The fallback, and **it covers only what is unaccounted for**. What the
        object's routine reads in an unmeasured nibble is a real value -- a
        pipe's type, a variant nobody has named -- and no other row reaches it,
        so a box has to be offered. But a box over the *whole byte* would sit
        over the measured nibble as well, and two boxes over one nibble is a row
        that can be typed into to contradict the one above it: on the forest
        tree top, whose low nibble is a variant, a settings byte typed here
        would silently change which tree is drawn. So the row is the nibble,
        not the byte.

        Named by where it sits, because that is the only true thing there is to
        say about it: the row exists precisely because what the nibble does was
        never established. Where every bit of the byte has a role there are no
        rows at all, and the record's own bytes are the last row either way, so
        the byte is never out of sight.
        """
        return [
            Field(
                key=f"{side}-nibble",
                label=f"{side.capitalize()} nibble",
                kind=Number(0x0, 0xF, hexadecimal=True, digits=1),
                read=read,
                write=write,
                hint=f"The {side} nibble of the settings byte, raw. What this "
                f"object does with it was never measured -- the loader did not "
                f"finish -- so it is offered as the value rather than as what "
                f"it means.",
            )
            for side, role, read, write in (
                ("low", size.low, _low_nibble, _write_low),
                ("high", size.high, _high_nibble, _write_high),
            )
            if role == metadata.UNKNOWN
        ]

    def _command_fields(self) -> list[Field]:
        """A screen exit's or a screen jump's fields, which are not a position.

        The low bits an ordinary record spends on a position are the screen the
        command acts on, so that screen *is* editable here, unlike an object's
        -- it is a field of the record rather than a consequence of where the
        record sits.
        """
        jump = self.settings == SCREEN_JUMP
        rows: list[Field] = [
            # Read-only, unlike every other object's identity: a screen exit is
            # four bytes and a screen jump three, so turning one into the other
            # is not a field edit -- it would have to invent a destination or
            # throw one away. Deleting the record and placing the other is the
            # operation, and it is the one that says what it is doing.
            readout(
                "Object",
                lambda obj: OBJECTS.extended.get(obj.settings, "Unknown"),
                "Which command this is. The two are different lengths, so an "
                "edit cannot switch between them.",
            ),
            readout("Kind", lambda obj: obj.kind.value.capitalize()),
            Field(
                key="command-screen",
                label="Jumps to screen" if jump else "Exit from screen",
                kind=Number(0x00, 0x1F, hexadecimal=True),
                read=lambda obj: obj.data[0] & 0x1F,
                write=_write_command_screen,
                hint=(
                    "The screen the loader carries on from, so later records "
                    "are placed there."
                    if jump
                    else "The screen this exit is taken from. A command names its "
                    "screen outright rather than being placed on one."
                ),
            ),
        ]
        if self.settings == SCREEN_EXIT:
            rows += [
                Field(
                    key="destination",
                    label="Destination",
                    kind=Number(0x000, 0x1FF, hexadecimal=True, digits=3),
                    read=_read_destination,
                    write=_write_destination,
                    hint="The level this exit leads to.",
                ),
                Field(
                    key="secondary",
                    label="Secondary entrance",
                    kind=Switch(),
                    read=lambda obj: (obj.data[1] >> 1) & 0x01,
                    write=_write_secondary,
                    hint="Arrive through the destination's secondary entrance "
                    "instead of its main one.",
                ),
                Field(
                    key=OPEN_DESTINATION,
                    label="Open",
                    kind=Action("Open Level"),
                    hint="Leave this level and edit the one the exit leads to.",
                ),
            ]
        rows += record_rows("Object")
        return rows

    @property
    def _number_text(self) -> str:
        if self.number == EXTENDED_OBJECT:
            return f"ext {hexnum(self.settings)}"
        return hexnum(self.number)

    @property
    def _position_text(self) -> str:
        # A command has no position of its own -- the bits a position would sit
        # in are the screen it acts on -- so the screen is the whole answer.
        if self.kind is ObjectKind.COMMAND:
            return f"screen {hexnum(self.screen)}"
        return hexspot(self.column, self.row)


def _standard_choices(tileset: int) -> list[tuple[int, str]]:
    """Every standard object number this tileset has a name for.

    Numbers the tables do not name are left out rather than listed as
    "Unknown": a picker is for choosing, and sixty rows of the same word is not
    a choice. A record already holding such a number keeps it -- an unlisted
    value stays selectable, which is :class:`~shiny_mushroom.fields.Choices`'s
    own rule.
    """
    group = OBJECTS.tileset_groups.get(tileset & 0x0F)
    table = OBJECTS.standard.get(group or "", {})
    return [
        (number, f"{hexnum(number)} {name}") for number, name in sorted(table.items())
    ]


def _extended_choices() -> list[tuple[int, str]]:
    """Every extended object the disassembly names, by its settings byte."""
    return [
        (number, f"{hexnum(number)} {name}")
        for number, name in sorted(OBJECTS.extended.items())
    ]


#: What each measured role is called in the panel, and the clause naming what it
#: counts. Each is followed by which part of the byte it came from, so it reads
#: as one sentence: "How many blocks across, from the low nibble".
_ROLE_LABELS = {
    metadata.WIDTH: ("Width", "How many blocks across"),
    metadata.HEIGHT: ("Height", "How many blocks down"),
    metadata.LENGTH: (
        "Length",
        "How long, in this object's own steps rather than blocks",
    ),
}

#: The sentence a role needs beyond what it counts. ``length`` is the only one
#: that earns it: it is a size, it is not a block count, and a reader who assumes
#: it is will be wrong by a factor the object -- and usually its variant --
#: decides.
_ROLE_NOTES = {
    metadata.LENGTH: (
        "How far a step reaches depends on the object, and often on its variant."
    ),
}


def _low_nibble(obj: LevelObject) -> int:
    return obj.settings & 0x0F


def _high_nibble(obj: LevelObject) -> int:
    return obj.settings >> 4


def _write_low(obj: LevelObject, value: int) -> LevelObject:
    return _write_settings(obj, (obj.settings & 0xF0) | (value & 0x0F))


def _write_high(obj: LevelObject, value: int) -> LevelObject:
    return _write_settings(obj, ((value & 0x0F) << 4) | (obj.settings & 0x0F))


def _extent_field(
    role: str,
    read,
    write,
    maximum: int,
    runaway: bool,
    held: int,
    where: str,
    side: str = "",
) -> Field:
    """One of the settings byte's extents, counted from one.

    Keyed by its role, so a caller asks for "the width" without having to know
    which nibble that turned out to be -- or, for object `$21`, that it took
    the whole byte.

    ``side`` is set only for the handful of objects whose **two nibbles were
    measured as the same role**, and it is what keeps that from collapsing into
    one field: the pair is keyed ``low-length``/``high-length`` rather than both
    claiming ``length``, and shown on one row under the role's own name, each
    box saying which nibble it is. Empty for every other field, which is then
    keyed and labelled by its role alone.

    **The value shown is the stored one plus one**, because that is what the
    loops do: a nibble of 1 draws two blocks. Showing the raw nibble would make
    every size in the editor one less than the size on screen.

    A ``runaway`` extent cannot be *set* to its smallest value. Where the loop
    tests after decrementing, a stored zero means 256 passes rather than one, so
    the one-block size those objects appear to offer does not exist -- and
    letting it be picked would send the object across the level. The bound says
    so instead of a warning nobody reads.

    **A record already holding that zero is shown holding it**, which is what
    ``held`` decides: the bound is the record's own value when the record is
    already below it. A box floored at two over a byte that says zero would be
    the panel telling the user something the level does not hold, and the object
    it describes really is the runaway one. The floor comes back the moment the
    value leaves it, because the descriptor is rebuilt from the record every
    edit -- so this is a truthful readout of a value that is already there and
    never a way back down to it.
    """
    plain, explanation = _ROLE_LABELS[role]
    smallest = 1
    note = f"{maximum} is what the field can say."
    if runaway and held > 0:
        smallest = 2
        note = (
            "Its smallest value is two: a stored zero means 256 here, not one, "
            "and sends the object across the level."
        )
    elif runaway:
        note = (
            "This record holds the stored zero, which means 256 here, not one, "
            "and sends the object across the level. Stepping up leaves it, "
            "and nothing steps back down."
        )
    note = f"{_ROLE_NOTES[role]} {note}" if role in _ROLE_NOTES else note
    return Field(
        key=f"{side}-{role}" if side else role,
        label=f"{plain}, {side} nibble" if side else plain,
        group=plain if side else "",
        kind=Number(smallest, maximum),
        read=lambda obj: read(obj) + 1,
        write=lambda obj, value: write(obj, value - 1),
        hint=f"{explanation}, from {where}. {note}",
    )


def _write_settings(obj: LevelObject, value: int) -> LevelObject:
    """The record with a new settings byte.

    The footprint follows on its own, because :attr:`LevelObject.width` and
    :attr:`LevelObject.height` are read out of this byte rather than stored
    beside it. That is the whole reason they are properties: there is no second
    place to remember to update, and no way for a record to disagree with its
    own bytes.
    """
    return replace(obj, settings=value)


def _command_byte(obj: LevelObject, index: int, value: int) -> LevelObject:
    """The record with one of its raw bytes replaced.

    A command's fields live in its bytes and nowhere else -- :func:`encode_objects`
    writes a command out verbatim, because a screen exit's destination and its
    entrance flag are fields nothing above it understands. So an edit to one is
    an edit to the byte.
    """
    data = bytearray(obj.data)
    data[index] = value & 0xFF
    return replace(obj, data=bytes(data))


def _write_command_screen(obj: LevelObject, value: int) -> LevelObject:
    """The screen a command acts on, in the low five bits of its first byte.

    :attr:`screen` is set alongside it because for a command that attribute is
    read out of these same bits rather than counted up to, so the two are one
    fact and must move together.
    """
    first = (obj.data[0] & ~0x1F) | (value & 0x1F)
    return replace(_command_byte(obj, 0, first), screen=value & 0x1F)


def _read_destination(obj: LevelObject) -> int:
    """A screen exit's destination level: nine bits, split across two bytes."""
    return obj.data[3] | ((obj.data[1] & 0x01) << 8)


def _write_destination(obj: LevelObject, value: int) -> LevelObject:
    edited = _command_byte(obj, 3, value & 0xFF)
    second = (edited.data[1] & ~0x01) | ((value >> 8) & 0x01)
    return _command_byte(edited, 1, second)


def _write_secondary(obj: LevelObject, value: int) -> LevelObject:
    second = (obj.data[1] & ~0x02) | ((value & 0x01) << 1)
    return _command_byte(obj, 1, second)


def parse_objects(stream: bytes, shape: Geometry) -> list[LevelObject]:
    """Read an object stream into placed objects.

    ``stream`` starts at the first record -- the five header bytes are the
    level's, not the stream's, and are parsed elsewhere. ``shape`` decides the
    axis swap and how a screen number turns into blocks, so the same bytes read
    differently in a vertical level.
    """
    objects: list[LevelObject] = []
    cursor = 0
    screen = 0  # the loader zeroes it before the first record
    while cursor + RECORD_SIZE <= len(stream) and len(objects) < MAX_RECORDS:
        first, second, settings = stream[cursor : cursor + RECORD_SIZE]
        if first == TERMINATOR:
            break

        number = ((first & 0x60) >> 1) | (second >> 4)
        size = (
            SCREEN_EXIT_SIZE
            if number == EXTENDED_OBJECT and settings == SCREEN_EXIT
            else RECORD_SIZE
        )
        record = stream[cursor : cursor + size]
        if len(record) < size:
            # A stream that ends inside its last record. Reading the missing
            # byte as zero would invent a destination level.
            break

        # The new-screen bit is applied before the record is placed, so an
        # object carrying it belongs to the screen it opens rather than to the
        # one before.
        screen += first >> 7
        command = number == EXTENDED_OBJECT and settings in (SCREEN_EXIT, SCREEN_JUMP)
        # A command names its own screen in the same low bits a normal object
        # would use for a position, and it applies to that screen whatever the
        # cursor is.
        placed_on = (first & 0x1F) if command else screen

        # Across the screen and along the level, whichever axes those are. Both
        # fields sit in the same bits either way: what a vertical level changes
        # is which axis each one names, which is what the loader's nibble swap
        # accomplishes.
        along = placed_on * SCREEN_COLUMNS + (0 if command else second & 0x0F)
        # Bit 4 adds $100 to the write pointer: sixteen rows down a horizontal
        # screen, the right half of a vertical one -- the same sixteen entries
        # either way.
        far_half = SCREEN_COLUMNS if first & 0x10 else 0
        across = 0 if command else (first & 0x0F) + far_half
        column, row = (across, along) if shape.vertical else (along, across)

        objects.append(
            LevelObject(
                number=number,
                settings=settings,
                column=column,
                row=row,
                screen=placed_on,
                index=len(objects),
                offset=cursor,
                data=record,
            )
        )
        if number == EXTENDED_OBJECT and settings == SCREEN_JUMP:
            # The cursor moves outright, and every later record is placed from
            # there. This is what lets level data skip empty screens.
            screen = first & 0x1F
        cursor += size
    return objects


def encode_objects(
    objects: Iterable[LevelObject], shape: Geometry
) -> tuple[bytes, tuple[int, ...]]:
    """Write placed objects back out as an object stream, terminator and all.

    The exact inverse of :func:`parse_objects` for a stream nobody has edited:
    ``encode_objects(parse_objects(s, shape), shape)[0] == s``. That round trip
    is the whole test of this function, and it is worth stating as one -- an
    encoder that is merely *plausible* produces a level that loads and is subtly
    not the one on the canvas.

    **The screen cursor is reconstructed rather than carried.** A record does not
    say which screen it is on; byte 0's high bit says "one further than the last
    one", and the level's shape says which axis that counts along. So this walks
    the list keeping the same cursor the loader keeps, and asks each object only
    where it *is*:

    - on the cursor's screen, or the next one along, the bit says it;
    - anywhere else -- which is what moving an object across two screen
      boundaries, or deleting the object that opened a screen, produces -- a
      **screen jump** is emitted ahead of it to put the cursor there.

    The next screen along takes the jump too when the bit would make byte 0
    read ``$FF``, which is the byte the loader stops the stream at: a standard
    object ``$30``-``$3F`` in a vertical level's last column fills every other
    bit of it. The jump says the same thing absolutely, so the record that
    follows it carries the bit clear and the level is the one that was asked
    for -- three bytes longer, and readable.

    That last case is why this returns more than bytes. A synthesised jump is a
    record the caller never had, so the second element is the :attr:`uid` of the
    object each emitted record came from, in order, with ``0`` for a jump this
    invented. Re-parsing the stream and zipping those on is what keeps a
    selection pointing at the same objects across an edit.

    Commands keep their own bytes. A screen exit's destination and its secondary
    entrance flag are fields nothing above understands, and a command names its
    screen outright rather than counting to it, so re-deriving either would be
    inventing data.
    """
    stream = bytearray()
    uids: list[int] = []
    cursor = 0
    for obj in objects:
        if obj.kind is ObjectKind.COMMAND:
            stream += obj.data
            uids.append(obj.uid)
            cursor += obj.data[0] >> 7
            if obj.settings == SCREEN_JUMP:
                cursor = obj.data[0] & 0x1F
            continue
        screen = shape.screen_of(obj.column, obj.row)
        new_screen = (
            screen == cursor + 1 and _first_byte(obj, shape, True) != TERMINATOR
        )
        if new_screen:
            cursor += 1
        elif screen != cursor:
            stream += screen_jump(screen)
            uids.append(0)
            cursor = screen
        stream += _record_bytes(obj, shape, new_screen)
        uids.append(obj.uid)
    stream.append(TERMINATOR)
    return bytes(stream), tuple(uids)


def screen_jump(screen: int) -> bytes:
    """A screen-jump command that puts the loader's cursor on ``screen``.

    Extended object ``$01``: the screen in the low five bits of byte 0, byte 1
    zero so the object number reads as ``$00``, and the new-screen bit clear
    because the jump is absolute and does not want to be counted from as well.
    """
    return bytes((screen & 0x1F, 0x00, SCREEN_JUMP))


def _record_bytes(obj: LevelObject, shape: Geometry, new_screen: bool) -> bytes:
    """One standard or extended object as its three bytes.

    Every field lands back in the bits :func:`parse_objects` reads it out of:
    the object number split across both bytes, the across axis in byte 0's low
    five bits -- the fifth being the ``+$100`` half-screen step -- and the along
    axis's position within its screen in byte 1's low nibble.
    """
    along = obj.row if shape.vertical else obj.column
    second = ((obj.number & 0x0F) << 4) | (along % SCREEN_COLUMNS)
    return bytes((_first_byte(obj, shape, new_screen), second, obj.settings))


def _first_byte(obj: LevelObject, shape: Geometry, new_screen: bool) -> int:
    """Byte 0 of a standard or extended object: the new-screen bit, the object
    number's high two bits, and the across axis's low five.

    Its own function because :func:`encode_objects` has to ask what the byte
    would be before it commits to the new-screen bit -- the one combination
    that reads as :data:`TERMINATOR` is refused there.
    """
    across = obj.column if shape.vertical else obj.row
    return (0x80 if new_screen else 0x00) | ((obj.number & 0x30) << 1) | (across & 0x1F)


def _footprint(number: int, settings: int) -> tuple[int, int]:
    """Blocks covered, where the format says. One block where it does not."""
    if number in SIZED_OBJECTS:
        return (settings & 0x0F) + 1, (settings >> 4) + 1
    return 1, 1


def is_screen_exit(record: LevelObject) -> bool:
    """Whether this record is a screen exit rather than an object."""
    return record.number == EXTENDED_OBJECT and record.settings == SCREEN_EXIT


def screen_exits(objects: Iterable[LevelObject]) -> dict[int, int]:
    """Where each screen's exit leads, by screen number.

    One per screen: the exit writes into a table indexed by the screen, so a
    second exit on the same screen overwrites the first rather than adding to
    it, and the last record is the one that takes effect.
    """
    return {
        obj.screen: obj.data[3] | ((obj.data[1] & 0x01) << 8)
        for obj in objects
        if is_screen_exit(obj)
    }


def screen_exit_on(objects: Iterable[LevelObject], screen: int) -> LevelObject | None:
    """The record that decides where ``screen`` leads, or ``None`` for a screen
    with no exit on it.

    The **last** of them, on :func:`screen_exits`' rule: the loader writes each
    one into the same entry of the destination table, so a screen carrying two
    is a screen whose second record is the only one anybody can observe. That
    is also the one an edit has to land on, which is why this answers with the
    record rather than with the count.
    """
    found = None
    for obj in objects:
        if is_screen_exit(obj) and obj.screen == screen:
            found = obj
    return found


def screen_exit_record(screen: int, shape: Geometry) -> LevelObject:
    """A new screen exit on ``screen``, leading to level ``$000``.

    The **whole record**, bytes included, unlike everything else a placement
    builds: :func:`encode_objects` writes a command out verbatim, because its
    destination and its entrance flag are fields nothing above it understands,
    so a new one has to arrive with four bytes that mean something. Destination
    ``$000`` is a level the cartridge has -- an exit that leads somewhere
    definite is a thing to edit, and one built out of nothing is a thing to
    debug.

    A command has no position of its own: the low bits an ordinary record
    spends on one are the screen it acts on, and its block coordinates are that
    screen's corner. Derived the way :func:`parse_objects` derives them, so the
    record built here is the one that comes back from the rewrite.
    """
    along = screen * SCREEN_COLUMNS
    corner = (0, along) if shape.vertical else (along, 0)
    return LevelObject(
        number=EXTENDED_OBJECT,
        settings=SCREEN_EXIT,
        column=corner[0],
        row=corner[1],
        screen=screen,
        index=0,
        offset=0,
        data=bytes((screen & 0x1F, 0x00, SCREEN_EXIT, 0x00)),
    )


def stack_at(
    objects: list[LevelObject],
    column: int,
    row: int,
    drawn: Mapping[int, frozenset[tuple[int, int]]] | None = None,
) -> list[LevelObject]:
    """Every object covering a block, front to back.

    Later records win. The loader writes them in order and each overwrites what
    the last one put there, so the object a block *shows* is the last one that
    reached it -- which is what a click on that block should select, and the
    rest are the ones it was drawn over. A block a dozen objects reached is
    ordinary here: the ground under a ledge under a pipe is three of them, and
    only the topmost is visible.

    ``drawn`` maps an object's :attr:`~LevelObject.uid` to the blocks it
    actually drew, from
    :attr:`~shiny_mushroom.level_snapshot.LevelSnapshot.footprints`. Given an entry, a
    click lands on any block that object reached; without one, only on the
    rectangle the record admits to -- which for everything outside the
    ``$01``-``$0E`` family is a single block, so a slope could otherwise only be
    selected by its first tile.

    Keyed by uid rather than by stream offset, because an offset is a property
    of the *bytes*: every edit rewrites the stream, so a delete three records
    back shifts every offset after it and would pair a record with somebody
    else's tiles. A uid is what survives a rewrite, which is what it is for.

    The **absence** of an entry and an **empty** entry are different answers:
    nothing was observed, so fall back to the rectangle, versus the object
    placed no tiles at all -- a screen exit or a screen jump -- which must not
    be selectable anywhere.
    """
    footprints = drawn or {}
    stack = []
    for obj in reversed(objects):
        blocks = footprints.get(obj.uid) if obj.uid else None
        if blocks is None:
            hit = obj.contains(column, row)
        else:
            hit = (column, row) in blocks
        if hit:
            stack.append(obj)
    return stack


def within(
    objects: Iterable[LevelObject],
    left: int,
    top: int,
    right: int,
    bottom: int,
    drawn: Mapping[int, frozenset[tuple[int, int]]] | None = None,
) -> list[LevelObject]:
    """Every object that reaches into a block rectangle, in record order.

    What a selection box catches. **Touching is enough** -- an object is caught
    if any block it drew is inside, not only if all of them are -- which is the
    rule a box drawn over part of a long ledge has to follow: the ledge is one
    object, and half of it cannot be selected.

    ``drawn`` is the same uid-keyed map :func:`stack_at` takes, and carries the
    same distinction: no entry falls back to the record's rectangle, while an
    empty entry means the object placed no tiles and is caught by nothing.
    """
    footprints = drawn or {}
    caught = []
    for obj in objects:
        blocks = footprints.get(obj.uid) if obj.uid else None
        if blocks is None:
            hit = (
                obj.column <= right
                and obj.column + obj.width > left
                and obj.row <= bottom
                and obj.row + obj.height > top
            )
        else:
            hit = any(
                left <= column <= right and top <= row <= bottom
                for column, row in blocks
            )
        if hit:
            caught.append(obj)
    return caught


def carried_footprints(
    drawn: Mapping[int, frozenset[tuple[int, int]]],
    before: Iterable[LevelObject],
    after: Iterable[LevelObject],
) -> dict[int, frozenset[tuple[int, int]]]:
    """The observed footprints, carried across an edit.

    A footprint is what the *loader* saw an object draw, and the loader only
    runs again when the picture is redrawn, ~60 ms after the edit, because the
    picture is the game's own work. Between the two, the
    outlines are all the user has, so the footprints have to follow the records
    they belong to rather than describing where those records were.

    Three cases, and each is a different answer rather than a degree of the
    same one:

    - **Moved.** A move is a pure translation, so the blocks translate with it.
      That is exact and not an approximation: an object writes the same tilemap
      offsets wherever it is put -- what changes is which *tile* lands there,
      when a neighbour reads the map it is drawing into.
    - **Changed shape.** A different settings byte or a different object number
      is a different drawing, and nothing here knows what it looks like. The
      entry is dropped, so the outline falls back to the record's own rectangle
      until the loader has run -- small, and in the right place.
    - **Gone.** Deleted records take their footprints with them.

    An object the edit did not touch keeps what was observed of it, which is
    the overwhelming majority of a level on any one edit.
    """
    was = {obj.uid: obj for obj in before if obj.uid}
    carried: dict[int, frozenset[tuple[int, int]]] = {}
    for obj in after:
        if not obj.uid:
            continue
        blocks = drawn.get(obj.uid)
        previous = was.get(obj.uid)
        if blocks is None or previous is None:
            continue
        if (obj.number, obj.settings) != (previous.number, previous.settings):
            continue
        columns = obj.column - previous.column
        rows = obj.row - previous.row
        if (columns, rows) == (0, 0):
            carried[obj.uid] = blocks
        else:
            carried[obj.uid] = frozenset(
                (column + columns, row + rows) for column, row in blocks
            )
    return carried


def at(
    objects: list[LevelObject],
    column: int,
    row: int,
    drawn: Mapping[int, frozenset[tuple[int, int]]] | None = None,
) -> LevelObject | None:
    """The object a block shows: the last record that reached it, if any."""
    stack = stack_at(objects, column, row, drawn)
    return stack[0] if stack else None
