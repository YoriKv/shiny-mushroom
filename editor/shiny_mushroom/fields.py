"""What a record's fields *are*, so a panel can show and edit them generically.

A list of label/value strings is all a *readout* needs and nothing an editor can
use: a string does not say what range a value has, whether it is a choice from a
list, or how to put an edited value back into the record. This module is that
description, and the readout is derived from it rather than written beside it --
see :func:`pairs` -- so the two cannot disagree about one record.

A :class:`Field` is one row: what to call it, what kind of value it holds, how
to read it off a record and -- when it can be edited at all -- how to write it
back. :mod:`shiny_mushroom.objects` and :mod:`shiny_mushroom.sprites` each
declare their own list, so **adding a property is appending a descriptor** and
the panel does not change. Fields that are one thing said in parts share a row
by naming it -- see :attr:`Field.group` and :func:`grouped`.

Three things are deliberate.

**A write returns a new record, it does not mutate one.** Records are frozen
dataclasses and every edit in :mod:`shiny_mushroom.edit` is a rewrite, so a
field's job ends at "here is the record you would have if this value changed".
What to do with it -- put it in the level, push the old one onto the undo stack,
re-render -- belongs to whoever owns the document.

**The descriptors work in the record's own semantic fields**, never in raw
bytes. A field writes to ``column`` or ``settings``, and the encoders in
``objects.py`` and ``sprites.py`` keep sole ownership of how those reach the
stream -- the nibble swap in a vertical level, the screen cursor, the four-byte
screen exit. A descriptor that assembled bytes itself would be a second encoder
to keep in step with the first.

**Qt-free, like everything it describes.** A field list is a fact about the
format and is tested by reading it back, without a window. Turning one into a
spin box is :mod:`shiny_mushroom.ui.properties`'s job.
"""

from __future__ import annotations

from collections.abc import Callable, Iterable, Sequence
from dataclasses import dataclass
from typing import TYPE_CHECKING, Any

from shiny_mushroom.hexnum import hexbytes, hexnum

if TYPE_CHECKING:
    from shiny_mushroom.level import Geometry

#: What comes between two fields sharing a row, in the panel and in the text a
#: readout makes of them -- one string, so "Pos: $03, $04" reads the same in
#: both places.
SEPARATOR = ", "

#: The group a column and a row share. Both streams place a record the same way
#: and so name the row the same way, for the reason :func:`record_rows` is here
#: rather than written twice: one thing said in two modules drifts.
POSITION = "Pos"


@dataclass(frozen=True)
class Choice:
    """One option of a :class:`Choices` field: the value, and what to call it.

    ``detail`` is words *beside* the label rather than part of it -- shown in
    the popup and searched through, absent from the closed box. What that is
    for is a list whose entries are addressed by a short name but recognised by
    a long one: a level is picked as ``$009`` and remembered as Donut Plains 2,
    and a box wide enough for the second is a box nobody wants on a row of
    numbers.
    """

    value: int
    label: str
    detail: str = ""


@dataclass(frozen=True)
class Number:
    """A whole number, bounded, shown in hex or in decimal.

    The bounds are the *format's*, not a policy: an object's column is bounded
    by the level, a settings byte by the byte. A panel clamps to them rather
    than refusing, because a value typed past the end of a range is a reach for
    the end of the range.
    """

    minimum: int
    maximum: int
    #: Shown and typed in base 16, with a ``$`` in front. True for anything the
    #: format itself is written in -- object numbers, settings bytes, screens --
    #: and false for counts, which are read as counts.
    hexadecimal: bool = False
    #: How many hex digits to pad to. Two by default because that is how this
    #: format is written and read everywhere else -- a column is `$01`, not
    #: `$1` -- and deriving it from :attr:`maximum` instead would make the same
    #: field read differently in a small level than in a big one.
    digits: int = 2
    #: What a step of one means, for a widget that offers stepping. Sizes and
    #: positions step by one; nothing yet steps by more.
    step: int = 1


@dataclass(frozen=True)
class Choices:
    """A value picked from a named list.

    **A value not in the list stays selectable**, shown as its bare number. The
    editor's name tables come from the disassembly and are not complete -- an
    unnamed object number is `Unknown`, and a hack may use a number no table
    mentions -- so a picker that silently snapped an unlisted value onto the
    nearest listed one would corrupt the record it was opened to inspect.
    """

    options: tuple[Choice, ...]
    #: Whether the picker showing this is worth searching rather than
    #: scrolling. True for the lists that are hundreds of entries long and are
    #: reached for by name -- the levels -- and false for the rest, where a
    #: search field over a dozen names costs a keystroke to skip. A fact about
    #: the *list*, which is why it is here rather than at each place one is
    #: shown.
    searchable: bool = False

    def label_for(self, value: int) -> str | None:
        for choice in self.options:
            if choice.value == value:
                return choice.label
        return None


@dataclass(frozen=True)
class Flags:
    """Named bits of one value, each offered as its own switch.

    ``bits`` is the mask and the name of every bit shown, in the order they
    are shown. A bit no entry names is not the field's to touch -- see
    :attr:`mask` -- so a byte with an unused low bit keeps whatever it held.

    What a set bit *means* is the field's business and not this one's: the
    overworld's table says which maps a sprite is **disabled** on, and the
    panel offers the maps it appears on by inverting the byte in the field's
    read and write. This only ever renders "set is on", which is why it can
    be read without knowing which table is behind it.
    """

    bits: tuple[tuple[int, str], ...]

    @property
    def mask(self) -> int:
        """Every bit this field offers -- the whole of what an edit changes."""
        held = 0
        for mask, _ in self.bits:
            held |= mask
        return held

    def text_for(self, value: int) -> str:
        """The set bits' names, as the row reads. A dash for none, because an
        empty row reads as a missing one."""
        return SEPARATOR.join(name for mask, name in self.bits if value & mask) or "-"


@dataclass(frozen=True)
class Readout:
    """A row that is shown and never edited.

    Not everything a record says is a value with a range. The bytes themselves,
    the record's index in its stream, which branch of the loader it takes --
    those are read, and an editable-looking box around them would be a lie about
    what the editor can do.
    """


@dataclass(frozen=True)
class Action:
    """A button: pressing it asks the record's owner to *start* something --
    a pick on the canvas, say -- rather than writing a value.

    The panel emits the field's key with a value of one, exactly the shape a
    committed edit arrives in, and what happens next belongs to whoever owns
    the document. No ``read`` and no ``write``: an action has no value, so
    :meth:`Field.applied` treats it as read-only and the owner dispatches on
    the key instead.
    """

    caption: str


#: What a field holds. The union is the seam a new widget arrives through: a
#: flag, a bit field, a level picker.
Kind = Number | Choices | Flags | Readout | Action


@dataclass(frozen=True)
class Field:
    """One row of the properties panel.

    ``read`` and ``write`` work in whole numbers because every field in this
    format is one -- a position, an id, a size, a flag -- and a panel that only
    has to render integers and choices is a panel with no per-type branches in
    it. A :class:`Readout` field has neither and carries ``show`` instead.
    """

    #: Stable identity for the row, used to keep a widget across a refresh
    #: rather than rebuilding the panel under the user's cursor.
    key: str
    label: str
    kind: Kind

    #: Read the value off a record. ``None`` only for a :class:`Readout`.
    read: Callable[[Any], int] | None = None

    #: The record this one would be with the field set. ``None`` makes the row
    #: read-only, which is the honest rendering for a value that is derived
    #: rather than stored -- a record's screen follows its position, so it is
    #: shown and not offered.
    write: Callable[[Any, int], Any] | None = None

    #: How to render the value as text. Defaulted from :attr:`kind`, and given
    #: explicitly where the useful rendering is not the number -- which is
    #: every :func:`readout`, whose value is a name or a run of bytes.
    show: Callable[[Any], str] | None = None

    #: One line explaining the field, for a tooltip. Worth writing for anything
    #: whose name does not carry it: "Settings" says nothing, and what the byte
    #: means is the single most confusing thing about this format.
    #:
    #: **What the field is, and any rule an edit runs into -- nothing else.**
    #: A hint is read while reaching for the control, so it carries what the
    #: user needs to work it and leaves out which table it indexes, how many
    #: bits it is and why the game does it that way. Those belong in
    #: ``docs/smw/`` or beside the label in the disassembly.
    #: :func:`~shiny_mushroom.ui.tips.wrap_tip` breaks a long one into lines,
    #: but needing more than two of them means it has not been cut down far
    #: enough.
    hint: str = ""

    #: What to call the row this field shares with its neighbours, for the
    #: fields that are one thing said in parts -- a column and a row are a
    #: position, and two rows for it is two rows saying half of one. Consecutive
    #: fields carrying the same group are shown together under it, in place of
    #: their own labels; the empty string is a row of the field's own. See
    #: :func:`grouped`.
    group: str = ""

    @property
    def editable(self) -> bool:
        return self.write is not None

    def value(self, record: Any) -> int:
        """The field's current value. Zero for a :class:`Readout`, which has
        none -- callers reach for :meth:`text` there."""
        return 0 if self.read is None else self.read(record)

    def text(self, record: Any) -> str:
        """The field as it reads on screen."""
        if self.show is not None:
            return self.show(record)
        if isinstance(self.kind, Action):
            return self.kind.caption
        value = self.value(record)
        if isinstance(self.kind, Choices):
            return self.kind.label_for(value) or hexnum(value)
        if isinstance(self.kind, Flags):
            return self.kind.text_for(value)
        if isinstance(self.kind, Number) and self.kind.hexadecimal:
            return hexnum(value, self.kind.digits)
        return str(value)

    def clamped(self, value: int) -> int:
        """``value`` brought inside the field's range."""
        if isinstance(self.kind, Number):
            return max(self.kind.minimum, min(self.kind.maximum, value))
        return value

    def applied(self, record: Any, value: int) -> Any:
        """``record`` with this field set to ``value``, clamped.

        Returns the record unchanged when the field cannot be written or the
        value is already what it is -- which is what lets a caller tell a real
        edit from a commit of an untouched box, and so keep the latter out of
        the undo stack.
        """
        if self.write is None:
            return record
        value = self.clamped(value)
        if self.read is not None and self.read(record) == value:
            return record
        return self.write(record, value)


def readout(label: str, show: Callable[[Any], str], hint: str = "") -> Field:
    """A shown-not-edited row, which is most of what a record says."""
    return Field(
        key=label.lower().replace(" ", "-"),
        label=label,
        kind=Readout(),
        show=show,
        hint=hint,
    )


def record_rows(what: str) -> list[Field]:
    """The two rows every record ends with, whichever stream it came from.

    Both streams' records carry an index and their own bytes, and both want
    them said the same way -- so they are said once here rather than twice in
    the two modules that declare fields.

    Last in the list because they are what a reader falls back to rather than
    what they came for, and both because between them they answer "is this the
    record I think it is" without anything having to be trusted. ``what`` names
    the stream, since "index" alone does not say index of what.
    """
    return [
        readout(
            f"{what} index",
            lambda record: str(record.index),
            "Position in the stream, which is also depth: later records are "
            "drawn over earlier ones.",
        ),
        readout(
            "Bytes",
            lambda record: hexbytes(record.data),
            "The record as the cartridge holds it.",
        ),
    ]


def screen_row(hint: str) -> Field:
    """The screen a record falls on: shown, and never offered as a field.

    Both streams derive it rather than storing it as a value of its own, and
    offering it beside the position would let the two disagree about a record
    the format cannot express that way. *How* each derives it differs -- the
    object stream counts a cursor up to it, a sprite's own bytes carry it --
    so the hint saying why is the caller's and the row is not.
    """
    return readout("Screen", lambda record: hexnum(record.screen), hint)


def position_rows(shape: Geometry) -> list[Field]:
    """The column and row, as blocks in the level, on one row as a position.

    The same pair for both streams: a record is placed the same way in each and
    bounded by the same thing -- the level's own shape -- so it is declared here
    rather than twice, for the reason :func:`record_rows` is.

    Written through the record's ``placed_at`` rather than by setting the
    attribute, so its screen follows its position -- which is the invariant both
    streams are built on and the one thing a hand-set position would break.
    """
    return [
        Field(
            key="column",
            label="Column",
            group=POSITION,
            kind=Number(0, max(0, shape.columns - 1), hexadecimal=True),
            read=lambda record: record.column,
            write=lambda record, value: record.placed_at(value, record.row, shape),
            hint="Blocks from the left of the level.",
        ),
        Field(
            key="row",
            label="Row",
            group=POSITION,
            kind=Number(0, max(0, shape.rows - 1), hexadecimal=True),
            read=lambda record: record.row,
            write=lambda record, value: record.placed_at(record.column, value, shape),
            hint="Blocks from the top of the level.",
        ),
    ]


def grouped(fields: Iterable[Field]) -> list[list[Field]]:
    """A field list as the rows it is shown in.

    Consecutive fields carrying the same :attr:`Field.group` are one row, and
    everything else is a row of its own. Said here rather than in the panel
    because *which fields are one thing* is a fact about the record -- and
    because a readout derived from the same list has to draw the same rows, or
    the two descriptions of one record disagree about how many it has.
    """
    rows: list[list[Field]] = []
    for found in fields:
        if found.group and rows and rows[-1][-1].group == found.group:
            rows[-1].append(found)
        else:
            rows.append([found])
    return rows


def label_of(row: Sequence[Field]) -> str:
    """What a row is called: the group's name, or the single field's own."""
    return row[0].group or row[0].label


def pairs(fields: Iterable[Field], record: Any) -> list[tuple[str, str]]:
    """A field list rendered as the label/value pairs a readout wants.

    The old shape of the panel, kept because a status line, a test and a
    multi-record summary all want the text and none of them wants a widget.
    Deriving it from the fields rather than beside them is what stops the two
    from drifting -- grouped rows included, so a position reads as one pair
    here exactly as it is one row on screen.
    """
    return [
        (label_of(row), SEPARATOR.join(found.text(record) for found in row))
        for row in grouped(fields)
    ]


def choices(names: Sequence[tuple[int, str]]) -> Choices:
    """A :class:`Choices` from ``(value, label)`` pairs, in the given order."""
    return Choices(tuple(Choice(value, label) for value, label in names))
