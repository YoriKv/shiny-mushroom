"""Lunar Magic's four extra secondary-header bytes: the record, and the
Layer 2 scroll fields it carries.

Under the ``lunar-magic-levels`` feature the cartridge keeps the four
``$200``-byte tables Lunar Magic adds beyond the stock secondary header
(:mod:`smw_tools.lunar_magic_levels`), as the asm regions
``levels.lunar_magic_entrance`` through ``levels.lunar_magic_background``
-- the same shape as the stock four, and modelled the same way: a frozen
four-byte record and a field per bit-run the cartridge reads: the scroll
byte, and the main entrance's flags, its second-method position and its
relative camera. The sprite spawn bits and one unread bit of each of two
bytes ride along in the record, written back as found.

The horizontal setting is not here: with the separate flag set it is the
header's own scroll nibble, whole, which :mod:`shiny_mushroom.secondary_header`
already edits as the stock pair. That field's choices say so.

No Qt, no emulator: a record in, a record out.
"""

from __future__ import annotations

from dataclasses import dataclass, replace

from shiny_mushroom.fields import Choice, Choices, Field, Number, Switch
from smw_tools.lunar_magic_levels import (
    AUTO_SCREENS,
    BACKGROUND,
    BACKGROUND_RELATIVE,
    BACKGROUND_ROWS_MASK,
    DEFAULT,
    ENTRANCE,
    ENTRANCE_Y,
    FACE_LEFT,
    HIGH_X_MASK,
    HIGH_X_SHIFT,
    HIGH_Y_MASK,
    OFFSET_HIGH,
    REGION_IDS,
    RELATIVE,
    ROLES,
    SCROLL,
    SCROLL_SETTINGS,
    SECOND_METHOD,
    SEPARATE_SCROLL,
    SIZE,
    SLIPPERY,
    VERTICAL_SCROLL_MASK,
    WATER,
)

__all__ = [
    "BACKGROUND",
    "DEFAULT",
    "ENTRANCE",
    "ENTRANCE_Y",
    "REGION_IDS",
    "ROLES",
    "SCROLL",
    "SIZE",
    "LunarMagicSettings",
    "fields",
]

#: The thirty-two vertical settings, named as Lunar Magic names them.
VERTICAL_SCROLLS = Choices(
    tuple(Choice(one.value, one.name) for one in SCROLL_SETTINGS)
)


@dataclass(frozen=True)
class LunarMagicSettings:
    """One level's four bytes, in table order: the entrance flags, the
    scroll byte, the entrance's high Y bits, the background.

    Frozen like every record: an edit is a new one, and :meth:`with_byte`
    is the one write everything narrows to.
    """

    data: bytes = DEFAULT

    def __post_init__(self) -> None:
        if len(self.data) != SIZE:
            raise ValueError(f"the settings are {SIZE} bytes, not {len(self.data)}")

    @property
    def is_default(self) -> bool:
        """Whether this is a level Lunar Magic has not touched."""
        return self.data == DEFAULT

    def with_byte(self, index: int, value: int) -> LunarMagicSettings:
        held = bytearray(self.data)
        held[index] = value & 0xFF
        return replace(self, data=bytes(held))

    def _bits(self, index: int, shift: int, mask: int) -> int:
        return (self.data[index] >> shift) & mask

    def _with_bits(
        self, index: int, shift: int, mask: int, value: int
    ) -> LunarMagicSettings:
        held = (self.data[index] & ~(mask << shift)) | ((value & mask) << shift)
        return self.with_byte(index, held)


def _flag(key: str, label: str, mask: int, hint: str, byte: int = SCROLL) -> Field:
    return Field(
        key=key,
        label=label,
        kind=Switch(),
        read=lambda record: 1 if record.data[byte] & mask else 0,
        write=lambda record, value: record.with_byte(
            byte, (record.data[byte] & ~mask) | (mask if value else 0)
        ),
        hint=hint,
    )


def _bits(key: str, label: str, byte: int, shift: int, mask: int, hint: str) -> Field:
    return Field(
        key=key,
        label=label,
        kind=Number(0, mask, hexadecimal=True, digits=1 if mask < 0x10 else 2),
        read=lambda record: record._bits(byte, shift, mask),
        write=lambda record, value: record._with_bits(byte, shift, mask, value),
        hint=hint,
    )


def fields() -> tuple[Field, ...]:
    """The rows the load path shows for the settings: the main entrance's
    flags and placement first, the camera, then the scroll byte's three
    parts."""
    return (
        _flag(
            "slippery",
            "Slippery",
            SLIPPERY,
            "The whole level is slippery, whatever the entrance action.",
            ENTRANCE,
        ),
        _flag(
            "water",
            "Water",
            WATER,
            "The whole level is under water, whatever the entrance action.",
            ENTRANCE,
        ),
        _flag(
            "face-left",
            "Face left",
            FACE_LEFT,
            "The player starts facing left, and is shot leftwards out of a "
            "pipe entrance.",
            BACKGROUND,
        ),
        _flag(
            "second-method",
            "Place at a tile",
            SECOND_METHOD,
            "Put the main entrance at a tile column and row rather than at "
            "one of the shared positions: the Entrance X and Y rows above "
            "are then the low bits, and the two rows below the high ones.",
            ENTRANCE,
        ),
        _bits(
            "tile-x-high",
            "Tile column, high bits",
            ENTRANCE,
            HIGH_X_SHIFT,
            HIGH_X_MASK >> HIGH_X_SHIFT,
            "Bits 3-4 of the tile column, over Entrance X's three; the "
            "screen is added as ever.",
        ),
        _bits(
            "tile-y-high",
            "Tile row, high bits",
            ENTRANCE_Y,
            0,
            HIGH_Y_MASK,
            "Bits 4-9 of the tile row, over Entrance Y's four.",
        ),
        _flag(
            "relative-camera",
            "Camera from the player",
            RELATIVE,
            "Start the camera at the player's row plus the offset below "
            "rather than at FG initial Y, and place Layer 2 from its height "
            "or from Layer 1.",
            BACKGROUND,
        ),
        _flag(
            "offset-up",
            "Camera offset upward",
            OFFSET_HIGH,
            "The camera offset counts rows upward: BG initial Y and FG "
            "initial Y together are then sixteen less the offset.",
            ENTRANCE_Y,
        ),
        _flag(
            "background-from-layer1",
            "Layer 2 from Layer 1",
            BACKGROUND_RELATIVE,
            "Place Layer 2 a signed number of rows from the camera rather "
            "than so that its bottom meets the level's: the rows below are "
            "then the offset: $00-$0F rows down, $11-$1F counting back "
            "from $20, and $10 the background at the level's top.",
            ENTRANCE_Y,
        ),
        _bits(
            "background-rows",
            "Background rows",
            BACKGROUND,
            0,
            BACKGROUND_ROWS_MASK,
            "The background's height in rows less one ($1A for the stock "
            "27), or its offset from Layer 1 when Layer 2 is placed from it.",
        ),
        _flag(
            "separate-scroll",
            "Separate Layer 2 scroll",
            SEPARATE_SCROLL,
            "Scroll Layer 2 by two settings of this level's own rather than "
            "the header's pair: the header's Layer 2 scroll value is then the "
            "horizontal setting, whole, and the row below the vertical one.",
        ),
        Field(
            key="vertical-scroll",
            label="Layer 2 vertical scroll",
            kind=VERTICAL_SCROLLS,
            read=lambda record: record._bits(SCROLL, 0, VERTICAL_SCROLL_MASK),
            write=lambda record, value: record._with_bits(
                SCROLL, 0, VERTICAL_SCROLL_MASK, value
            ),
            hint="How Layer 2 follows the camera vertically, when the scroll "
            "is separate: a ratio to Layer 1, or a speed of its own.",
        ),
        _flag(
            "auto-screens",
            "Auto-set screens (Lunar Magic)",
            AUTO_SCREENS,
            "Lunar Magic's own record that it sets the level's screen count "
            "on save. The game never reads it; kept so a container round-trips.",
        ),
    )
