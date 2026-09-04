"""A level's own Layer 3: how it scrolls, where it starts, which screen it is on.

Under the ``layer3-settings`` feature the cartridge keeps four ``$200``-byte
tables in the level bank (:mod:`smw_tools.layer3_settings`), as the asm
regions ``levels.layer3_horizontal`` through ``levels.layer3_offset_y`` --
the same shape as the stock secondary header's four and the Lunar Magic
tables', and modelled the same way: a frozen four-byte record and a field
per part of it.

The stock game has nothing to edit here. Which Layer 3 image a level loads
is its tileset's and its secondary header's between them, and how the image
behaves comes with the image; these bytes are the level's own answer, read
at the load and once a frame after it.

No Qt, no emulator: a record in, a record out.
"""

from __future__ import annotations

from dataclasses import dataclass, replace

from shiny_mushroom.fields import Choice, Choices, Field, Number, Switch
from smw_tools.layer3_settings import (
    COLOR_MATH,
    DEFAULT,
    ENABLED,
    HORIZONTAL,
    OFFSET_MAX,
    OFFSET_MIN,
    OFFSET_X,
    OFFSET_Y,
    REGION_IDS,
    ROLES,
    SETTING_MASK,
    SIZE,
    SUBSCREEN,
    VERTICAL,
    Settings,
)
from smw_tools.lunar_magic_levels import SCROLL_SETTINGS

__all__ = [
    "DEFAULT",
    "HORIZONTAL",
    "OFFSET_X",
    "OFFSET_Y",
    "REGION_IDS",
    "ROLES",
    "SIZE",
    "VERTICAL",
    "Layer3Settings",
    "fields",
]

#: The thirty-two settings either axis can take, named as Lunar Magic names
#: them -- one vocabulary for Layer 2's scroll and this one, because the
#: cartridge gives them one meaning.
SCROLLS = Choices(tuple(Choice(one.value, one.name) for one in SCROLL_SETTINGS))


@dataclass(frozen=True)
class Layer3Settings:
    """One level's four bytes, in table order: the horizontal byte, the
    vertical byte, and the two offsets.

    Frozen like every record: an edit is a new one, and :meth:`with_byte` is
    the one write everything narrows to.
    """

    data: bytes = DEFAULT

    def __post_init__(self) -> None:
        if len(self.data) != SIZE:
            raise ValueError(f"the settings are {SIZE} bytes, not {len(self.data)}")

    @property
    def is_default(self) -> bool:
        """Whether this level says nothing, and so is placed as the stock
        cartridge places it."""
        return self.data == DEFAULT

    @property
    def settings(self) -> Settings:
        """The fields the four bytes spell, as the tooling reads them."""
        return Settings.read(self.data)

    def with_byte(self, index: int, value: int) -> Layer3Settings:
        held = bytearray(self.data)
        held[index] = value & 0xFF
        return replace(self, data=bytes(held))


def _flag(key: str, label: str, byte: int, mask: int, hint: str) -> Field:
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


def _scroll(key: str, label: str, byte: int, hint: str) -> Field:
    return Field(
        key=key,
        label=label,
        kind=SCROLLS,
        read=lambda record: record.data[byte] & SETTING_MASK,
        write=lambda record, value: record.with_byte(
            byte, (record.data[byte] & ~SETTING_MASK) | (value & SETTING_MASK)
        ),
        hint=hint,
    )


def _offset(key: str, label: str, byte: int, hint: str) -> Field:
    return Field(
        key=key,
        label=label,
        kind=Number(OFFSET_MIN, OFFSET_MAX),
        read=lambda record: _signed(record.data[byte]),
        write=lambda record, value: record.with_byte(byte, value),
        hint=hint,
    )


def _signed(value: int) -> int:
    return value - 0x100 if value & 0x80 else value


def fields() -> tuple[Field, ...]:
    """The rows the header window shows for the settings: whether the level
    places Layer 3 at all, then how each axis moves and where it starts, then
    how it is drawn."""
    return (
        _flag(
            "layer3-enabled",
            "Place Layer 3 here",
            HORIZONTAL,
            ENABLED,
            "Scroll Layer 3 by this level's own settings instead of however "
            "the image its tileset loads behaves. A level whose Layer 3 is a "
            "tide keeps the tide whatever this says.",
        ),
        _scroll(
            "layer3-horizontal",
            "Horizontal scroll",
            HORIZONTAL,
            "How far Layer 3 moves across for each pixel Layer 1 does, or "
            "the speed it moves at by itself.",
        ),
        _scroll(
            "layer3-vertical",
            "Vertical scroll",
            VERTICAL,
            "The same down the screen. The two axes are set apart, as Layer 2's are.",
        ),
        _offset(
            "layer3-offset-x",
            "X offset",
            OFFSET_X,
            "Where Layer 3 starts across, in 16x16 tiles: added to Layer 1's "
            "position for a setting that follows the camera, and the "
            "position outright for one that does not.",
        ),
        _offset(
            "layer3-offset-y",
            "Y offset",
            OFFSET_Y,
            "The same down the screen. Negative counts up and left.",
        ),
        _flag(
            "layer3-color-math",
            "Colour maths",
            HORIZONTAL,
            COLOR_MATH,
            "Draw Layer 3 through the colour maths, so it blends with the "
            "layers behind it where the level's mode has any.",
        ),
        _flag(
            "layer3-subscreen",
            "On the subscreen",
            VERTICAL,
            SUBSCREEN,
            "Draw Layer 3 on the subscreen rather than the main one, which "
            "puts it behind Layer 2 -- and the status bar with it.",
        ),
    )
