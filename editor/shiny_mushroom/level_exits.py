"""A level's screen exits, keyed by the screen rather than by the record.

The object stream carries screen exits as records, and
:mod:`shiny_mushroom.objects` reads them that way: four bytes on a screen,
somewhere in a list of ledges and pipes. That is what the *cartridge* holds and
it is not how anybody works: an exit is a decision about a screen -- "walking
off screen 3 lands you in level $105" -- and the question a level designer asks
is about the screen, not about the record's place in a stream.

So this module turns the stream around. A :class:`ScreenExit` is one screen of
one level, and what it holds is whatever exit that screen has, or none. The
window (`Level > Level Exits`) lists the screens that have one; the properties
panel describes whichever screen was clicked, with or without. Both are the
same record and the same descriptors.

**One screen, one exit.** The loader writes each record into
``!RAM_SMW_Misc_SubscreenExitEntranceNumberLo[screen]``, so a screen carrying
two exits is a screen whose first record nothing can observe -- see
:func:`~shiny_mushroom.objects.screen_exit_on`. Nothing here creates that state:
adding refuses a screen that already has one, and moving refuses the same. A
level that already carries two -- a hand-edited one, or the object panel's own
"Exit from screen" field, which edits the *record* and is not bound by this --
reads back through the last of them, which is the one the game obeys.

Qt-free, like every model module: the fields are descriptors and the edits
return a new document, so the whole of this is tested by reading a list back.
"""

from __future__ import annotations

from dataclasses import dataclass, replace
from typing import TYPE_CHECKING

from shiny_mushroom.fields import (
    Action,
    Choice,
    Choices,
    Field,
    Number,
    choices,
    readout,
)
from shiny_mushroom.hexnum import hexbytes, hexnum
from shiny_mushroom.level_files import numbered_levels
from shiny_mushroom.objects import (
    LevelObject,
    is_screen_exit,
    screen_exit_on,
    screen_exit_record,
    screen_exits,
)
from shiny_mushroom.secondary_entrances import (
    SUBMAP,
    Entrances,
    SecondaryEntrance,
    exit_choices,
)

if TYPE_CHECKING:
    from collections.abc import Callable

    from shiny_mushroom.edit import Level

#: The highest screen a record can name: the exit's screen lives in the low
#: five bits of its first byte, whatever the level's own length is.
LAST_SCREEN = 0x1F

#: The field keys. Dispatched by whoever owns the document -- the two actions
#: carry no value, and the three editable columns are ordinary writes.
EXIT_SCREEN = "exit-screen"
EXIT_DESTINATION = "exit-destination"
EXIT_SECONDARY = "exit-secondary"
EXIT_ADD = "exit-add"
EXIT_REMOVE = "exit-remove"
EXIT_FOLLOW = "exit-follow"

#: Why an add or a move was turned away. One screen holds one exit, so the
#: answer is always the same and is said in one place.
OCCUPIED = "That screen already has an exit; remove it first."


@dataclass(frozen=True)
class ScreenExit:
    """One screen of a level, and whatever exit it carries.

    Holds the whole document rather than the exit record, because a screen
    with no exit has no record to hold and is exactly the case the panel has to
    describe. An edit rewrites the document and hands back another of these --
    :class:`~shiny_mushroom.overworld_fields.WarpEntry`'s contract on the other
    kind of transfer.
    """

    document: Level
    screen: int
    #: The levels the destination picker offers, as
    #: :func:`~shiny_mushroom.level_files.level_choices` builds them -- number
    #: and the container the level comes out of. Carried on the record because
    #: it is what the *cartridge* holds rather than what the level does, and
    #: nothing below has one to ask; empty falls back to bare numbers, which is
    #: every level said as well as it can be said without a tree to name it.
    levels: tuple[Choice, ...] = ()
    #: The cartridge's arrival tables, which is where an exit marked
    #: secondary leads. Carried for :attr:`levels`' reason and one more: they
    #: are the *cartridge's* rather than any level's, so a level document
    #: could not hold them even in principle. The whole document rather than
    #: a picker's rows, because two questions are asked of it -- which
    #: entrances to offer, and which level the one this exit names loads.
    #: ``None`` where none have been read.
    entrances: Entrances | None = None

    @property
    def record(self) -> LevelObject | None:
        """The exit on this screen, or ``None`` for a screen without one."""
        return screen_exit_on(self.document.objects, self.screen)

    @property
    def destination(self) -> int:
        """Where this screen leads. Nine bits, split across the record's second
        and fourth bytes; zero where there is no exit to ask."""
        found = self.record
        return 0 if found is None else found.data[3] | ((found.data[1] & 0x01) << 8)

    @property
    def secondary(self) -> int:
        """Whether the destination is entered through its secondary entrance."""
        found = self.record
        return 0 if found is None else (found.data[1] >> 1) & 0x01

    @property
    def entrance(self) -> int:
        """Which secondary entrance this exit arrives through: the record's
        fourth byte on its own.

        Eight bits where :attr:`destination` is nine, and the difference is
        not an oversight of the format. The loader builds its index from this
        byte over a high byte holding ``$00`` on the main map and ``$01`` on a
        submap, so which of ``$0BF`` and ``$1BF`` an exit reaches is decided by
        where the player is standing and the record has no say in it.
        """
        found = self.record
        return 0 if found is None else found.data[3]

    @property
    def arrivals(self) -> tuple[SecondaryEntrance, ...]:
        """The rows of the arrival tables this exit reaches, in map order.

        Empty for an ordinary exit, which arrives through the destination's
        own entrance and names no row at all; otherwise one row per half of
        the tables that has an entrance written in, main map first, exactly
        as :attr:`landings` -- of which this is the whole answer and that the
        level out of each row.
        """
        if self.record is None or not self.secondary or self.entrances is None:
            return ()
        return tuple(
            found
            for found in (
                SecondaryEntrance(self.entrances, half | self.entrance)
                for half in (0, SUBMAP)
            )
            if found.in_use
        )

    @property
    def landings(self) -> tuple[int, ...]:
        """The levels this exit leads to, in map order.

        One for an ordinary exit: the level its nine bits name. For an exit
        marked secondary it is what the *arrival tables* say, and there can be
        two of them: the loader indexes those tables with the record's byte
        over a high byte holding ``$00`` on the main map and ``$01`` on a
        submap, so the same exit lands wherever ``$0BF`` leads from one map
        and wherever ``$1BF`` leads from the other. Only the halves with an
        entrance written in are listed, main map first, and where both are
        the two answers always differ -- a destination carries the high bit
        of the entrance number that named it, so they are at least ``$100``
        apart.

        Empty where there is nothing to say: a screen with no exit, a
        secondary exit with no tables read, and a secondary exit whose byte
        names a blank row in both halves -- an exit pointed at an entrance
        nobody filled in leads wherever that blank row would, which is not a
        place anybody chose.
        """
        if self.record is None:
            return ()
        if not self.secondary:
            return (self.destination,)
        return tuple(found.destination for found in self.arrivals)


def exit_rows(
    document: Level,
    levels: tuple[Choice, ...] = (),
    entrances: Entrances | None = None,
) -> list[ScreenExit]:
    """Every screen of ``document`` that has an exit, in screen order.

    ``levels`` and ``entrances`` are the two lists a row's destination picker
    is filled from, one per side of the secondary flag -- see
    :attr:`ScreenExit.levels` and :attr:`ScreenExit.entrances`.

    Screen order rather than stream order: the window is a picture of where a
    level leads, and the stream's order is an artefact of how the records were
    typed in. A screen numbered past the level's own end still gets a row --
    the record names its screen outright, so an exit can be parked on one the
    level does not reach, and a row is the only place that would ever show.
    """
    return [
        ScreenExit(document, screen, levels, entrances)
        for screen in sorted(screen_exits(document.objects))
    ]


def free_screen(document: Level) -> int | None:
    """The lowest screen of ``document`` with no exit on it, or ``None`` when
    every screen has one.

    What the window's Add button aims at. The level's own screens first, and
    then nothing: an exit added onto a screen the level does not reach is a row
    nobody can click on the canvas.
    """
    taken = screen_exits(document.objects)
    for screen in range(document.shape.screens):
        if screen not in taken:
            return screen
    return None


# -- the edits ---------------------------------------------------------------
#
# Three operations over the document, each returning the level that results or
# ``None`` for one that was refused -- which is what every other edit in
# `shiny_mushroom.edit` already answers with, so the window's `_commit` says
# the refusal without any of this having to know about a status bar.


def with_exit(document: Level, screen: int) -> Level | None:
    """``document`` with a new exit on ``screen``, leading to level ``$000``.

    Refused where the screen already has one: two records on a screen is a
    state the loader cannot express, and adding one silently would put a
    record in the level that nothing in the level can show.
    """
    if screen_exit_on(document.objects, screen) is not None:
        return None
    return document.added(screen_exit_record(screen, document.shape))


def without_exit(document: Level, screen: int) -> Level | None:
    """``document`` with ``screen``'s exit taken out.

    Every exit on the screen, not only the one the game obeys: what the
    gesture says is "this screen leads nowhere", and leaving a shadowed record
    behind would make that untrue the moment anything moved the last one.
    """
    doomed = {
        record.uid
        for record in document.objects
        if is_screen_exit(record) and record.screen == screen
    }
    return document.without(doomed) if doomed else None


def moved_exit(document: Level, screen: int, to: int) -> Level | None:
    """``document`` with ``screen``'s exit moved onto screen ``to``.

    Refused where there is nothing to move or where the target already has an
    exit -- :func:`with_exit`'s rule from the other end.
    """
    found = screen_exit_on(document.objects, screen)
    if found is None or to == screen:
        return None
    if screen_exit_on(document.objects, to) is not None:
        return None
    first = (found.data[0] & ~0x1F) | (to & 0x1F)
    return document.replaced(
        found.uid,
        replace(found, screen=to, data=bytes((first, *found.data[1:]))),
    )


def _write_screen(record: ScreenExit, value: int) -> ScreenExit:
    moved = moved_exit(record.document, record.screen, value)
    if moved is None:
        return record
    return replace(record, document=moved, screen=value)


def _rewritten(record: ScreenExit, edit: Callable[[bytes], bytes]) -> ScreenExit:
    """``record`` over a document whose exit holds ``edit``'s bytes instead.

    The one write the three field writers below share: each says what the four
    bytes become and this puts them back. A screen with no exit and a document
    that refused the replacement both hand back the record unchanged, which
    :meth:`~shiny_mushroom.fields.Field.applied` reads as "no edit".
    """
    found = record.record
    if found is None:
        return record
    edited = record.document.replaced(found.uid, replace(found, data=edit(found.data)))
    return record if edited is None else replace(record, document=edited)


def _write_destination(record: ScreenExit, value: int) -> ScreenExit:
    """The exit leading to level ``value`` -- nine bits, so the fourth byte and
    the second byte's low bit."""
    return _rewritten(
        record,
        lambda data: bytes(
            (
                data[0],
                (data[1] & ~0x01) | ((value >> 8) & 0x01),
                data[2],
                value & 0xFF,
            )
        ),
    )


def _write_entrance(record: ScreenExit, value: int) -> ScreenExit:
    """The exit arriving through entrance byte ``value``.

    The fourth byte alone. That byte is the one the two readings share -- the
    entrance the loader indexes with, and the low byte of the level a
    destination names -- so it cannot be written for one without moving the
    other; what is left untouched is the second byte's low bit, which is the
    destination's high bit and nothing an entrance number can reach. An exit
    switched back off secondary therefore names the level this byte now
    spells, in the half it was already in.
    """
    return _rewritten(record, lambda data: bytes((*data[:3], value & 0xFF)))


def _write_secondary(record: ScreenExit, value: int) -> ScreenExit:
    """The flag alone: the second byte's bit 1, leaving the destination bytes
    exactly as they were on both sides of the switch."""
    return _rewritten(
        record,
        lambda data: bytes(
            (data[0], (data[1] & ~0x02) | ((value & 0x01) << 1), *data[2:])
        ),
    )


# -- what a screen says ------------------------------------------------------


def _screen_field() -> Field:
    return Field(
        key=EXIT_SCREEN,
        label="Screen",
        kind=Number(0x00, LAST_SCREEN, hexadecimal=True),
        read=lambda record: record.screen,
        write=_write_screen,
        hint="Which screen the exit is taken from. One exit per screen.",
    )


def _destination_field(record: ScreenExit) -> Field:
    """Where this exit leads: **the level picker**, or the entrance picker for
    an exit marked secondary.

    Two lists under one key and one label, because the question is the same
    one -- where does walking off this screen land -- and only the *table* it
    is answered out of changes. An exit carrying the secondary flag names a
    row of the cartridge's arrival tables rather than a level at all, so the
    level list beside it would be a name for a number that does not mean that:
    ``$105`` against a byte the loader reads as entrance ``$005``. The flag's
    own row sits directly below, and switching it rebuilds this control --
    :func:`~shiny_mushroom.ui.properties.control_changed` is what makes a
    picker follow its options.

    The level half is the same list, and the same way of finding a row in it,
    that the toolbar's Level box offers: a level is remembered as a place
    rather than as a number, so a destination typed as ``$0CB`` is a
    destination nobody can check. The picker shows the number, says the
    container beside it in the popup, and is searched by both.
    """
    if record.secondary:
        return _entrance_field(record)
    return Field(
        key=EXIT_DESTINATION,
        label="Destination",
        kind=Choices(record.levels or numbered_levels(), searchable=True),
        read=lambda record: record.destination,
        write=_write_destination,
        hint="The level this exit leads to.",
    )


def _entrance_field(record: ScreenExit) -> Field:
    """Where a secondary exit leads: **the entrance picker**, over the rows of
    the arrival tables something is written in.

    The entrances in use rather than all 512 of them, which is the same
    question the Secondary Entrances window's own filter asks and the same
    answer: the tables carry no flag saying which rows a hack uses, so a row
    whose four bytes are all zero is the nearest thing to "not an entrance"
    that can be read back. Falls back to a number box over the bare byte where
    there is nothing to offer -- no tables read, or none of their rows written
    in -- which is the number the record holds, said as well as it can be said
    without the cartridge's own to name it.
    """
    offered = (
        ()
        if record.entrances is None
        else exit_choices(record.entrances, record.levels)
    )
    return Field(
        key=EXIT_DESTINATION,
        label="Destination",
        kind=(
            Choices(offered, searchable=True)
            if offered
            else Number(0x00, 0xFF, hexadecimal=True)
        ),
        read=lambda record: record.entrance,
        write=_write_entrance,
        hint="The secondary entrance this exit arrives through; it sets both "
        "the level loaded and where the player lands.",
    )


def _secondary_field() -> Field:
    return Field(
        key=EXIT_SECONDARY,
        label="Secondary entrance",
        kind=choices(((0, "No"), (1, "Yes"))),
        read=lambda record: record.secondary,
        write=_write_secondary,
        hint="Arrive through the destination's secondary entrance instead of "
        "its main one.",
    )


def _follow_field() -> Field:
    return Field(
        key=EXIT_FOLLOW,
        # Not "Destination", which is the number beside it: two columns under
        # one header is a table that has to be read twice.
        label="Go to",
        kind=Action("Open level"),
        hint="Open the level this exit leads to. One marked Secondary "
        "entrance opens the level its entrance loads.",
    )


def _remove_field() -> Field:
    return Field(
        key=EXIT_REMOVE,
        label="Exit",
        kind=Action("Remove exit"),
        hint="Take this screen's exit out of the level.",
    )


def exit_columns(record: ScreenExit) -> list[Field]:
    """One exit as the **window's** columns: which screen it leaves from, where
    it lands, how it arrives, and the two ways out of the row."""
    return [
        _screen_field(),
        _destination_field(record),
        _secondary_field(),
        _follow_field(),
        _remove_field(),
    ]


def screen_fields(record: ScreenExit) -> list[Field]:
    """One screen as the **properties panel's** rows.

    Two sets rather than one with dead rows in it, because a screen with no
    exit has no destination to grey out: what it has is a decision nobody has
    taken yet, and one button is the whole of what to say about it. The panel
    rebuilds whenever the keys change, so adding an exit swaps one set for the
    other without anything having to ask.
    """
    if record.record is None:
        # One row, because there is one thing to say. That the screen leads
        # nowhere is the *heading*'s job -- said twice it would be two rows
        # under the same label, and the second of them would be a button.
        return [
            Field(
                key=EXIT_ADD,
                label="Exit",
                kind=Action("Add exit"),
                hint="Put an exit on this screen, leading to level $000.",
            )
        ]
    return [
        _destination_field(record),
        _secondary_field(),
        _follow_field(),
        readout(
            "Record",
            _record_bytes,
            "The exit's four bytes as the stream holds them.",
        ),
        _remove_field(),
    ]


def _record_bytes(record: ScreenExit) -> str:
    """The exit's own bytes, or a dash where the screen has lost it -- which a
    readout can be asked for between an edit landing and the rows being
    rebuilt."""
    found = record.record
    return "--" if found is None else hexbytes(found.data)


def screen_heading(record: ScreenExit) -> str:
    """What the panel calls the selected screen.

    A screen with no exit says so here, because the rows below cannot: what it
    has is one button, and "no exit" is the thing that button is *for* rather
    than a value to lay out beside it.
    """
    name = f"Screen {hexnum(record.screen)}"
    return name if record.record is not None else f"{name} -- no exit"


def screen_note(record: ScreenExit) -> str:
    """What the canvas writes in this screen's label -- ``> $105``.

    Short deliberately: it shares a corner with the screen's own number and is
    read at a glance across a whole level, so it carries where the exit leads
    and nothing else. Which is the *level*, on both sides of the secondary
    flag: an exit marked secondary is resolved through the arrival tables
    (:attr:`ScreenExit.landings`), because the number in its record is a row
    of those tables and reading it as a level is reading it as the wrong
    thing. A byte both halves of the tables have an entrance for lands in two
    places and says both -- ``> $01C/$117`` -- since which of them the exit
    reaches is the overworld map the player is on rather than anything the
    record holds. The main map's is first, which is also the one the panel's
    Go to takes for a level in that half.

    An exit whose entrance cannot be resolved says which entrance it is
    asking for instead, marked ``e`` so it does not read as a level:
    ``> e$C0``. That is a cartridge with no tables read, or an exit pointed
    at a row nobody has filled in.
    """
    landings = record.landings
    if not landings:
        return f"> e{hexnum(record.entrance)}"
    return "> " + "/".join(hexnum(level, 3) for level in landings)
