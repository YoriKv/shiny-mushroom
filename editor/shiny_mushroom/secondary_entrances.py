"""The secondary entrances: the cartridge's table of arrivals, one row each.

A level's own entrance is the secondary header, four ``$200``-byte tables
indexed by the level number (:mod:`shiny_mushroom.secondary_header`). The
**secondary entrances** are four more tables in the same shape, at
``$05F800``-``$05FE00``, indexed by the *secondary entrance number* instead:
a screen exit carrying the secondary flag hands the loader one of these
numbers and the loader reads the arrival out of them in place of the
destination's own header (``docs/smw/level-format.md``).

So an entrance belongs to no level. It is the cartridge's, like the Map16
tables and unlike anything the level document carries -- which is why the
window over it is a project window, and why the whole table travels here as
one :class:`Entrances` document rather than as a row on a level.

Two things about the number the game reads with, and both show in a row:

- **The high bit is the overworld map**, not part of the exit's record. The
  loader indexes with the exit's byte over a high byte holding 0 on the main
  map and 1 on a submap, and then loads the level the same 16-bit pair names
  -- so entrance ``$1xx`` is reachable only from a submap level, and the
  level it loads is in ``$100``-``$1FF`` too. :func:`entrance_rows` offers
  each row the half of the level list its own number can reach.
- **The upper five bits of byte 4 are read by nothing here.** Lunar Magic
  keeps a level's high bit and its slippery and water flags there; this
  cartridge masks them off. No field offers them and every write leaves them
  as they were, so a table carrying them keeps them.

Qt-free, like every model module: a document in, a document out, and the
fields are descriptors the table editor renders.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass, replace
from functools import cache

from shiny_mushroom.fields import Action, Choice, Choices, Field, Number
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.secondary_header import (
    BG_POSITIONS,
    ENTRANCE_ACTIONS,
    FG_POSITIONS,
)
from smw_tools.levels import LEVEL_COUNT

#: The four bytes one entrance is written as, in table order.
SIZE = 4

#: How many entrances the tables hold -- the format's own count, as the
#: secondary header holds one row per level.
COUNT = 0x200

#: The half of the numbers a submap level reaches: an entrance at or above
#: this is indexed with the submap's high byte, and so is the level it names.
SUBMAP = 0x100

#: The asm regions holding the tables, in the same order -- one fragment per
#: table, ``levels/properties/5.asm`` through ``8.asm``.
REGION_IDS = (
    "levels.secondary_entrance_1",
    "levels.secondary_entrance_2",
    "levels.secondary_entrance_3",
    "levels.secondary_entrance_4",
)

#: The rom_tables role behind each region, in the same order -- what a
#: preview patch addresses the tables by.
ROLES = (
    "secondary_entrance_destination_level",
    "secondary_entrance_camera_and_entrance_y",
    "secondary_entrance_entrance_x_and_screen",
    "secondary_entrance_action",
)

#: The field keys. The one action is dispatched by the window; the rest are
#: ordinary writes.
DESTINATION = "entrance-destination"
ENTRANCE_SCREEN = "entrance-screen"
ENTRANCE_X = "entrance-x"
ENTRANCE_Y = "entrance-y"
ENTRANCE_ACTION = "entrance-action"
FG_INITIAL = "entrance-fg-initial"
BG_INITIAL = "entrance-bg-initial"
FOLLOW = "entrance-follow"

#: Where the three numbers that decide where the player lands sit, as the byte
#: they are in, the shift and the count of bits. Named because they are read
#: twice -- as the window's columns, and as :class:`SecondaryEntrance`'s own
#: properties, which is what a caller asking where an entrance leads reads.
SCREEN_BITS = (2, 0, 5)
X_BITS = (2, 5, 3)
Y_BITS = (1, 0, 4)


class EntrancesError(ValueError):
    """A table that is not the shape the format has."""


@dataclass(frozen=True)
class Entrances:
    """The four tables, whole: one tuple of :data:`COUNT` bytes each.

    Frozen like every document here, and edited by rewrite --
    :meth:`with_entry` is the one write, so a window holding these gets undo
    from :class:`~shiny_mushroom.edit.History` with nothing to add.
    """

    tables: tuple[tuple[int, ...], ...]

    def __post_init__(self) -> None:
        if len(self.tables) != SIZE:
            raise EntrancesError(
                f"the secondary entrances are {SIZE} tables, not {len(self.tables)}"
            )
        for role, values in zip(ROLES, self.tables, strict=True):
            if len(values) != COUNT:
                raise EntrancesError(
                    f"{role} holds {COUNT} entrances, not {len(values)}"
                )
            if any(not 0 <= value <= 0xFF for value in values):
                raise EntrancesError(f"{role} holds a value that is not a byte")

    @classmethod
    def read(cls, rows: dict[str, tuple[int, ...]]) -> Entrances:
        """The document from a region's rows per region id -- what
        :meth:`~shiny_mushroom.project.Project.asm_rows` hands back."""
        return cls(tuple(tuple(rows[region_id]) for region_id in REGION_IDS))

    def entry(self, number: int) -> bytes:
        """Entrance ``number``'s four bytes, in table order."""
        return bytes(values[number] for values in self.tables)

    def with_entry(self, number: int, data: bytes) -> Entrances:
        """These tables with entrance ``number`` written as ``data``.

        ``self`` where nothing changes, which is what
        :class:`~shiny_mushroom.edit.History` reads as "no step to push".
        """
        if len(data) != SIZE:
            raise EntrancesError(f"an entrance is {SIZE} bytes, not {len(data)}")
        if self.entry(number) == data:
            return self
        tables = []
        for values, value in zip(self.tables, data, strict=True):
            held = list(values)
            held[number] = value
            tables.append(tuple(held))
        return replace(self, tables=tuple(tables))

    def models(self) -> dict[str, object]:
        """The tables as region models, by region id -- what a save writes
        (:meth:`~shiny_mushroom.project.Project.save_asm_regions`)."""
        return {
            region_id: (values,)
            for region_id, values in zip(REGION_IDS, self.tables, strict=True)
        }


@dataclass(frozen=True)
class SecondaryEntrance:
    """One entrance of the tables, as the columns describe it.

    Holds the whole document for :class:`~shiny_mushroom.level_exits.ScreenExit`'s
    reason: an edit is a rewrite of the tables, so a field's write hands back
    another of these over the tables that result, and the window commits
    :attr:`document`.
    """

    document: Entrances
    number: int
    #: The levels this row's destination picker offers -- the half its own
    #: number can reach, as :func:`entrance_rows` splits them.
    levels: tuple[Choice, ...] = ()

    @property
    def data(self) -> bytes:
        """This entrance's four bytes, in table order."""
        return self.document.entry(self.number)

    @property
    def in_use(self) -> bool:
        """Whether anything is written in this entrance.

        **Anything, not a destination.** An entrance's destination is a byte,
        and zero is a level the cartridge has -- eleven of the shipped rows
        hold a zero there over a real screen, position and action -- so a row
        is blank only when all four of its bytes are. That leaves one case
        this cannot tell apart, and no reader could: an entrance that loads
        level ``$000`` at the first position with no action is written
        exactly as an unused one.
        """
        return any(self.data)

    @property
    def submap(self) -> bool:
        """Whether this entrance is one a submap level reaches -- which is
        also which half of the level list it can name."""
        return self.number >= SUBMAP

    @property
    def destination(self) -> int:
        """The level this entrance loads: the table's byte under the high bit
        the entrance number itself carries."""
        return (self.number & SUBMAP) | self.data[0]

    @property
    def screen(self) -> int:
        """The screen the player arrives on.

        The coarse half of one axis, and which axis is the destination
        level's business rather than this row's: it is the X high byte in a
        horizontal level and the Y high byte in a vertical one. See
        :func:`~shiny_mushroom.rom_patches.entrance_position`, which is where
        the three numbers below become a place.
        """
        return self._number(SCREEN_BITS)

    @property
    def x_index(self) -> int:
        """Which of the eight shared X positions the player arrives at."""
        return self._number(X_BITS)

    @property
    def y_index(self) -> int:
        """Which of the sixteen shared Y positions the player arrives at."""
        return self._number(Y_BITS)

    def _number(self, layout: tuple[int, int, int]) -> int:
        index, shift, bits = layout
        return self._bits(index, shift, (1 << bits) - 1)

    def _bits(self, index: int, shift: int, mask: int) -> int:
        return (self.data[index] >> shift) & mask

    def _with_bits(
        self, index: int, shift: int, mask: int, value: int
    ) -> SecondaryEntrance:
        data = bytearray(self.data)
        data[index] = (data[index] & ~(mask << shift)) | ((value & mask) << shift)
        return replace(
            self, document=self.document.with_entry(self.number, bytes(data))
        )


@cache
def numbered_levels(submap: bool) -> tuple[Choice, ...]:
    """One half of the levels as bare numbers -- the fallback where no
    cartridge tree has named them, and what a test offers.

    Built once per half: it is the same 256 rows every time, and
    :func:`~shiny_mushroom.ui.properties.field_widget` keys its shared list
    model on the tuple.
    """
    return tuple(
        Choice(level, hexnum(level, 3))
        for level in range(LEVEL_COUNT)
        if (level >= SUBMAP) is submap
    )


def used_entrances(document: Entrances) -> list[int]:
    """The entrances of ``document`` that carry anything, in number order --
    :attr:`SecondaryEntrance.in_use` over the whole table."""
    return [
        number
        for number in range(COUNT)
        if any(table[number] for table in document.tables)
    ]


def exit_choices(
    document: Entrances, levels: tuple[Choice, ...] = ()
) -> tuple[Choice, ...]:
    """The entrances in use, as **a screen exit** can name one.

    Valued by the byte the record holds rather than by the entrance number,
    because that byte is all the record has: the loader indexes the tables
    with it over a high byte holding ``$00`` on the main map and ``$01`` on a
    submap, so ``$BF`` reaches ``$0BF`` from one and ``$1BF`` from the other
    and the exit has no say in which. A byte that reaches two entrances in
    use is therefore one row naming both -- ``$0BF/$1BF`` -- and the detail
    says where each of them lands.

    In byte order, which is the order of the values rather than of the
    numbers: the two halves interleave, and a picker whose values did not
    ascend would be a list nobody could scan.

    ``levels`` is the whole cartridge's level list
    (:func:`~shiny_mushroom.level_files.level_choices`), for naming those
    landings; without it they are bare numbers.
    """
    names = {choice.value: choice for choice in levels}
    reached: dict[int, list[SecondaryEntrance]] = {}
    for number in used_entrances(document):
        reached.setdefault(number & 0xFF, []).append(
            SecondaryEntrance(document, number)
        )
    return tuple(
        Choice(
            byte,
            "/".join(hexnum(one.number, 3) for one in found),
            ", ".join(_lands_in(one, names) for one in found),
        )
        for byte, found in sorted(reached.items())
    )


def _lands_in(record: SecondaryEntrance, names: Mapping[int, Choice]) -> str:
    """The level one entrance loads, for a picker's detail -- named by its
    container where the cartridge's tree names it."""
    label = hexnum(record.destination, 3)
    found = names.get(record.destination)
    return label if found is None or not found.detail else f"{label} {found.detail}"


def entrance_rows(
    document: Entrances,
    levels: tuple[Choice, ...] = (),
    numbers: Iterable[int] | None = None,
) -> list[SecondaryEntrance]:
    """``document``'s entrances as records, in number order.

    ``numbers`` narrows the answer to those entrances -- what a filtered
    table shows -- and ``None`` is every one of them.

    ``levels`` is the whole cartridge's level list
    (:func:`~shiny_mushroom.level_files.level_choices`); each row is handed
    the half its number can reach. Split once here rather than per row: the
    picker's list model is keyed on the tuple, so two tuples across the whole
    table is two models and 512 would be 512.
    """
    halves = {
        submap: tuple(choice for choice in levels if (choice.value >= SUBMAP) is submap)
        or numbered_levels(submap)
        for submap in (False, True)
    }
    return [
        SecondaryEntrance(document, number, halves[number >= SUBMAP])
        for number in (range(COUNT) if numbers is None else numbers)
    ]


def _bit_field(
    key: str,
    label: str,
    byte: int,
    shift: int,
    bits: int,
    hint: str,
    choices: Choices | None = None,
) -> Field:
    mask = (1 << bits) - 1
    return Field(
        key=key,
        label=label,
        kind=choices if choices is not None else Number(0, mask, hexadecimal=True),
        read=lambda record: record._bits(byte, shift, mask),
        write=lambda record, value: record._with_bits(byte, shift, mask, value),
        hint=hint,
    )


def _destination_field(record: SecondaryEntrance) -> Field:
    """Where this entrance lands, as the level picker the exits window and the
    level bar both offer -- half of it, since the other half is a level this
    entrance's number cannot name."""
    half = "$100-$1FF" if record.submap else "$000-$0FF"
    return Field(
        key=DESTINATION,
        label="Destination",
        kind=Choices(record.levels or numbered_levels(record.submap), searchable=True),
        read=lambda record: record.destination,
        write=lambda record, value: replace(
            record,
            document=record.document.with_entry(
                record.number,
                bytes((value & 0xFF, *record.data[1:])),
            ),
        ),
        hint=f"The level this entrance loads. An entrance in this half of "
        f"the table reaches {half}.",
    )


def entrance_columns(record: SecondaryEntrance) -> list[Field]:
    """One entrance as the window's columns: where it lands, where in the
    level the player arrives, how, and where the camera starts."""
    return [
        _destination_field(record),
        _bit_field(
            ENTRANCE_SCREEN,
            "Screen",
            *SCREEN_BITS,
            "The screen the player arrives on.",
        ),
        _bit_field(
            ENTRANCE_X,
            "X",
            *X_BITS,
            "The arrival's column: one of eight shared positions, roughly one "
            "per screen.",
        ),
        _bit_field(
            ENTRANCE_Y,
            "Y",
            *Y_BITS,
            "The arrival's height: one of sixteen shared positions.",
        ),
        _bit_field(
            ENTRANCE_ACTION,
            "Action",
            3,
            0,
            3,
            "How the player arrives -- walking, sliding, out of a pipe.",
            choices=ENTRANCE_ACTIONS,
        ),
        _bit_field(
            FG_INITIAL,
            "FG initial Y",
            1,
            4,
            2,
            "The camera's starting height. Not starting at $C0 unlocks "
            "vertical scrolling by itself.",
            choices=FG_POSITIONS,
        ),
        _bit_field(
            BG_INITIAL,
            "BG initial Y",
            1,
            6,
            2,
            "Layer 2's starting height.",
            choices=BG_POSITIONS,
        ),
        Field(
            key=FOLLOW,
            # Not "Destination", which is the picker beside it: two columns
            # under one header is a table that has to be read twice.
            label="Go to",
            kind=Action("Open level"),
            hint="Open the level this entrance loads.",
        ),
    ]
