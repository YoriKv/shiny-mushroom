"""The secondary header: the four per-level bytes read before the level.

A second per-level header exists and is not next to the level data at all --
four parallel ``$200``-byte tables in bank ``$05``, one byte per level each,
read in game mode ``$11`` before the primary header is parsed
(``docs/smw/level-format.md``). Between them they place the player and the
camera and pick the Layer 3 background: the load path's last step before the
streams, which is why the editor models them here rather than in
:mod:`shiny_mushroom.header` -- the five primary bytes travel with the level's
container, these four travel with the *cartridge*, as the asm regions
``levels.secondary_header_1`` through ``_4``.

:class:`SecondaryHeader` is the record -- the four bytes for one level, table
order -- and :func:`fields` the descriptors the panel renders, exactly as
:mod:`shiny_mushroom.objects` declares its records' fields. What each bit
means is stated once, in the field table, off the disassembly's own reading
(``Banks/Bank05.asm``); the entrance X and Y are *indices* into fixed position
tables shared by every level, not coordinates, and the fields say so.

No Qt, no emulator: a record in, a record out.
"""

from __future__ import annotations

from dataclasses import dataclass, replace

from shiny_mushroom.fields import Choice, Choices, Field, Flags, Number, Switch

#: The four bytes, in table order.
SIZE = 4

#: The asm regions holding the tables, in the same order -- one fragment per
#: table, ``levels/properties/1.asm`` through ``4.asm``.
REGION_IDS = (
    "levels.secondary_header_1",
    "levels.secondary_header_2",
    "levels.secondary_header_3",
    "levels.secondary_header_4",
)

#: The rom_tables role behind each region, in the same order -- what a
#: preview patch and a capture address the tables by.
ROLES = (
    "secondary_header_scroll_and_entrance_y",
    "secondary_header_layer3_and_entrance_x",
    "secondary_header_initial_camera_y",
    "secondary_header_intro_and_entrance_screen",
)

#: How many levels each table holds a byte for.
LEVELS = 0x200

#: Byte 4's flag bit: the level skips the No Yoshi intro room.
NO_ENTRANCE_ROOM = 0x80

#: Byte 4's two layout bits, as the entrance-placement code reads them. Bit 5
#: is Layer 1 vertical and bit 6 Layer 2 vertical -- and neither decides how
#: the level *renders*: game mode ``$12`` overwrites the layout flags from the
#: level mode, so these steer only where the entrance lands.
LAYER1_VERTICAL = 0x20
LAYER2_VERTICAL = 0x40


@dataclass(frozen=True)
class SecondaryHeader:
    """One level's four secondary-header bytes, in table order.

    Frozen like every record: an edit is a new one, and
    :meth:`with_byte` is the one write everything narrows to.
    """

    data: bytes = bytes(SIZE)

    def __post_init__(self) -> None:
        if len(self.data) != SIZE:
            raise ValueError(
                f"a secondary header is {SIZE} bytes, not {len(self.data)}"
            )

    def with_byte(self, index: int, value: int) -> SecondaryHeader:
        held = bytearray(self.data)
        held[index] = value & 0xFF
        return replace(self, data=bytes(held))

    def _bits(self, index: int, shift: int, mask: int) -> int:
        return (self.data[index] >> shift) & mask

    def _with_bits(
        self, index: int, shift: int, mask: int, value: int
    ) -> SecondaryHeader:
        held = (self.data[index] & ~(mask << shift)) | ((value & mask) << shift)
        return self.with_byte(index, held)


def _bit_field(
    key: str,
    label: str,
    byte: int,
    shift: int,
    bits: int,
    hint: str,
    hexadecimal: bool = True,
    choices: Choices | None = None,
) -> Field:
    mask = (1 << bits) - 1
    return Field(
        key=key,
        label=label,
        kind=choices
        if choices is not None
        else Number(0, mask, hexadecimal=hexadecimal, digits=1 if mask < 0x10 else 2),
        read=lambda record: record._bits(byte, shift, mask),
        write=lambda record, value: record._with_bits(byte, shift, mask, value),
        hint=hint,
    )


#: The eight entrance actions, as ``SMW_InitializeLevelRAM`` dispatches the
#: three bits: 1 and 2 are the horizontal pipe exits with the facing the
#: game's table gives them, 3 and 4 the vertical ones with the pipe speeds
#: ``PipeYSpeed`` moves them at, 5 additionally sets the slippery flag and
#: 7 the water flag before acting as 4.
ENTRANCE_ACTIONS = Choices(
    (
        Choice(0, "None"),
        Choice(1, "Exit horizontal pipe, left"),
        Choice(2, "Exit horizontal pipe, right"),
        Choice(3, "Exit vertical pipe, up"),
        Choice(4, "Exit vertical pipe, down"),
        Choice(5, "None, slippery level"),
        Choice(6, "Shot out of a pipe"),
        Choice(7, "Exit vertical pipe, down; water level"),
    )
)

#: Byte 2's top two bits, named as the level loader stores them to the
#: Layer 3 settings byte.
_LAYER3_SETTINGS = Choices(
    (
        Choice(0, "None"),
        Choice(1, "Tide, low and high"),
        Choice(2, "Tide, low only"),
        Choice(3, "Tileset-specific image"),
    )
)

#: The eight scroll pairs the nibble picks out of ``L2HorzScrollSettings``
#: and ``L2VertScrollSettings``, horizontal first. The nibble has sixteen
#: values and the upper eight scroll not at all in this ROM -- Lunar Magic
#: 3.00+ hijack slots -- so they stay selectable as bare numbers.
_LAYER2_SCROLLS = Choices(
    (
        Choice(0, "H variable, V slow"),
        Choice(1, "H variable, V constant"),
        Choice(2, "H constant, V constant"),
        Choice(3, "H none, V none"),
        Choice(4, "H constant, V none"),
        Choice(5, "H variable, V variable"),
        Choice(6, "H constant, V variable"),
        Choice(7, "H none, V constant"),
    )
)

#: The four camera starting heights of ``Layer1InitialYPositions``. Only
#: $C0 leaves vertical scrolling locked, which is why the third entry is
#: the common one and the fourth a duplicate of the first.
FG_POSITIONS = Choices(
    (
        Choice(0, "$00 (top)"),
        Choice(1, "$60 (middle)"),
        Choice(2, "$C0 (bottom)"),
        Choice(3, "$00 (top, duplicate)"),
    )
)

#: The four Layer 2 starting heights of ``Layer2InitialYPositions``.
BG_POSITIONS = Choices(
    (
        Choice(0, "$60"),
        Choice(1, "$90"),
        Choice(2, "$C0"),
        Choice(3, "$00"),
    )
)


def fields() -> tuple[Field, ...]:
    """The secondary header's rows, in the order the panel shows them:
    what shapes the entrance first, then where it lands, then the layers.

    Every bit of all four bytes is covered, the midway-entrance screen
    included: it is read only on the way into a level entered from the
    overworld, but a byte written back has to carry it either way.
    """
    return (
        Field(
            key="no-entrance-room",
            label="Skip intro room",
            kind=Switch(),
            read=lambda record: 1 if record.data[3] & NO_ENTRANCE_ROOM else 0,
            write=lambda record, value: record.with_byte(
                3,
                (record.data[3] & ~NO_ENTRANCE_ROOM)
                | (NO_ENTRANCE_ROOM if value else 0),
            ),
            hint="Skip the No Yoshi intro room this level would enter through.",
        ),
        Field(
            key="vertical-entrance",
            label="Vertical entrance",
            kind=Flags(((LAYER1_VERTICAL, "Layer 1"), (LAYER2_VERTICAL, "Layer 2"))),
            read=lambda record: record.data[3],
            write=lambda record, value: record.with_byte(
                3,
                (record.data[3] & ~(LAYER1_VERTICAL | LAYER2_VERTICAL))
                | (value & (LAYER1_VERTICAL | LAYER2_VERTICAL)),
            ),
            hint="Place the entrance as if the named layers were vertical.",
        ),
        _bit_field(
            "entrance-screen",
            "Entrance screen",
            3,
            0,
            5,
            "The screen the main entrance lands on.",
        ),
        _bit_field(
            "entrance-x",
            "Entrance X",
            1,
            0,
            3,
            "The main entrance's column: one of eight shared positions, "
            "roughly one per screen.",
        ),
        _bit_field(
            "entrance-y",
            "Entrance Y",
            0,
            0,
            4,
            "The main entrance's height: one of sixteen shared positions.",
        ),
        _bit_field(
            "entrance-action",
            "Entrance action",
            1,
            3,
            3,
            "How the player enters -- walking, sliding, shot from a pipe.",
            choices=ENTRANCE_ACTIONS,
        ),
        _bit_field(
            "midway-screen",
            "Midway screen",
            2,
            4,
            4,
            "The screen the level is entered on once its midway point has "
            "been passed. Zero, and the midway point records nothing.",
        ),
        _bit_field(
            "layer2-scroll",
            "Layer 2 scroll",
            0,
            4,
            4,
            "The level's Layer 2 scroll pair.",
            choices=_LAYER2_SCROLLS,
        ),
        _bit_field(
            "layer3",
            "Layer 3",
            1,
            6,
            2,
            "The tide or tileset-specific Layer 3 background setting.",
            choices=_LAYER3_SETTINGS,
        ),
        _bit_field(
            "fg-initial",
            "FG initial Y",
            2,
            2,
            2,
            "The camera's starting height. Not starting at $C0 unlocks "
            "vertical scrolling by itself.",
            choices=FG_POSITIONS,
        ),
        _bit_field(
            "bg-initial",
            "BG initial Y",
            2,
            0,
            2,
            "Layer 2's starting height. Its offset from Layer 1 is fixed at "
            "load, so moving one without the other skews the background.",
            choices=BG_POSITIONS,
        ),
    )
