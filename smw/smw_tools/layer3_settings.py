"""Per-level Layer 3: how it scrolls, where it starts, which screen it is on.

The stock game gives a level no say in any of it -- the image its tileset
loads brings its behaviour with it, and two levels sharing a tileset share
that. Under the ``layer3-settings`` feature (``Config/Layer3Settings.asm``)
the cartridge holds four ``$200``-byte tables in the level bank, one fragment
per byte under ``levels/properties/`` (the editor's asm regions
:data:`REGION_IDS`), and places Layer 3 by them at the load and once a frame
after it.

This module carries the tables' shape and defaults, the bits each byte
spells, and where a Lunar Magic container keeps the same settings, so the
editor can read a container, write the tables and say what a setting does
without a build. The layout the config fixes is restated here and held
against the config's own literals by a test.

**The scroll settings are Layer 2's.** A setting is one of the thirty-two
:data:`~smw_tools.lunar_magic_levels.SCROLL_SETTINGS`, given the same
meanings on this axis as on that layer -- one vocabulary for both, and one
table of ratios and speeds behind them.

**A tide level is left alone.** The rising and falling tides are Layer 3
with interaction underneath, driven by their own frame code and their own
state; the cartridge reads these tables for every other level and ignores
them for those, whatever they say.

**What a container carries is Lunar Magic's, and part of it is a guess.**
Lunar Magic keeps its own Layer 3 settings in the high bytes of the sixteen
bypass words a level container's ExGFX slot holds
(:data:`smw_tools.level_graphics.BYPASS_WORDS`), and :func:`from_bypass`
reads them: the bit positions are the format's, and the flags and the
offsets mean what they say. The two *scroll settings* are the exception --
Lunar Magic's own memory map records that the order it encodes them in is
not the order it lists them in, and that order is not established here -- so
a value imported from a container names the ratio this cartridge gives it,
which may not be the ratio Lunar Magic gave the same number. Everything the
editor writes is read back the way it was written; only an import can
disagree.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from . import level_graphics
from .asm_defines import block
from .bases import RomBase
from .lunar_magic_levels import SCROLL_SETTINGS, ScrollSetting

#: The feature under which the tables exist, by id, and the asar define the
#: config guards.
FEATURE = "layer3-settings"
DEFINE = "Define_SMW_Layer3Settings"

#: The four bytes, in the order the block emits them.
SIZE = 4
HORIZONTAL, VERTICAL, OFFSET_X, OFFSET_Y = range(SIZE)

#: The editor's asm regions holding the tables, in byte order.
REGION_IDS: tuple[str, ...] = (
    "levels.layer3_horizontal",
    "levels.layer3_vertical",
    "levels.layer3_offset_x",
    "levels.layer3_offset_y",
)

#: The roles the feature declares each table under, in the same order, and
#: the fragment each is emitted from.
ROLES: tuple[str, ...] = (
    "layer3_horizontal",
    "layer3_vertical",
    "layer3_offset_x",
    "layer3_offset_y",
)
FRAGMENTS: tuple[Path, ...] = (
    Path("levels/properties/layer3-horizontal.asm"),
    Path("levels/properties/layer3-vertical.asm"),
    Path("levels/properties/layer3-offset-x.asm"),
    Path("levels/properties/layer3-offset-y.asm"),
)

#: The four labels the fragments carry, without the namespace the placement
#: wraps them in, and the first stub behind the tables -- where the block
#: stops being rows and starts being code.
LABELS: tuple[str, ...] = ("Horizontal", "Vertical", "OffsetX", "OffsetY")
NAMESPACE = "SMW_Layer3Settings"
STUBS_LABEL = f"{NAMESPACE}_Init"

#: How many levels each table holds a byte for, and what the tables come to.
LEVELS = 0x200
TABLE_BYTES = LEVELS
TABLES_BYTES = SIZE * TABLE_BYTES

#: The tables' offset from the level bank's base -- the packed head, past the
#: RATS tag and the level number stash -- and the block's whole size, the four
#: tables and the stubs, from ``Config/PackedRuns.asm`` where the placement
#: asserts it. One size on every cartridge.
TABLES_OFFSET = 0x8011
BLOCK_BYTES = block("Layer3Settings")
STUB_BYTES = BLOCK_BYTES - TABLES_BYTES

#: What every shipped row holds: a level that says nothing, and so a level
#: the cartridge places exactly as the stock one does.
DEFAULT = bytes(SIZE)

#: The horizontal byte's bits: ``E`` the level places Layer 3 itself, ``C``
#: Layer 3 drawn through the colour maths, ``hhhhh`` the scroll setting.
ENABLED = 0x80
COLOR_MATH = 0x40

#: The vertical byte's: ``S`` Layer 3 on the subscreen, ``vvvvv`` its scroll
#: setting.
SUBSCREEN = 0x80

#: The five bits either scroll setting is kept in.
SETTING_MASK = 0x1F

#: What the two offsets count in, and how far they reach: a signed byte of
#: 16x16 tiles either way.
TILE = 16
OFFSET_MIN = -0x80
OFFSET_MAX = 0x7F


@dataclass(frozen=True)
class Settings:
    """One level's four bytes, as the fields they spell."""

    enabled: bool = False
    color_math: bool = False
    subscreen: bool = False
    horizontal: int = 0x00
    vertical: int = 0x00
    offset_x: int = 0
    offset_y: int = 0

    @classmethod
    def read(cls, row: bytes) -> Settings:
        """The settings a level's four table bytes spell."""
        row = bytes(row).ljust(SIZE, b"\x00")
        return cls(
            enabled=bool(row[HORIZONTAL] & ENABLED),
            color_math=bool(row[HORIZONTAL] & COLOR_MATH),
            subscreen=bool(row[VERTICAL] & SUBSCREEN),
            horizontal=row[HORIZONTAL] & SETTING_MASK,
            vertical=row[VERTICAL] & SETTING_MASK,
            offset_x=_signed(row[OFFSET_X]),
            offset_y=_signed(row[OFFSET_Y]),
        )

    @property
    def row(self) -> bytes:
        """The four table bytes these settings are written as."""
        return bytes(
            (
                (ENABLED if self.enabled else 0)
                | (COLOR_MATH if self.color_math else 0)
                | (self.horizontal & SETTING_MASK),
                (SUBSCREEN if self.subscreen else 0) | (self.vertical & SETTING_MASK),
                self.offset_x & 0xFF,
                self.offset_y & 0xFF,
            )
        )

    def setting(self, axis: int) -> ScrollSetting:
        """The scroll setting on one axis, as :data:`HORIZONTAL` or
        :data:`VERTICAL` names it."""
        return SCROLL_SETTINGS[self.horizontal if axis == HORIZONTAL else self.vertical]

    def placed(self, axis: int, layer1: int) -> int:
        """Where Layer 3 sits on one axis for Layer 1 at ``layer1``, for a
        setting that does not scroll by itself.

        The cartridge's arithmetic: a setting that follows the camera places
        the layer at the camera scaled plus the offset, and one that does not
        places it at the offset outright. A self-scrolling setting has no
        answer here -- where it sits is however far it has got.
        """
        offset = (self.offset_x if axis == HORIZONTAL else self.offset_y) * TILE
        found = self.setting(axis)
        if found.self_scrolling or not found.scrolls:
            return offset
        return found.scaled(layer1) + offset


def _signed(value: int) -> int:
    return value - 0x100 if value & 0x80 else value


def is_enabled(base: RomBase) -> bool:
    """Whether ``base`` carries the tables -- see :data:`FEATURE`."""
    return FEATURE in base.features


def rows(tables: bytes) -> tuple[Settings, ...]:
    """Every level's settings, from the four tables laid end to end."""
    return tuple(
        Settings.read(
            bytes(tables[table * TABLE_BYTES + level] for table in range(SIZE))
        )
        for level in range(LEVELS)
    )


# -- what a container carries ----------------------------------------------------

#: Which bypass word each field's bits sit in, and what they are worth there.
#: Lunar Magic spreads its Layer 3 settings across the *high* bytes of the
#: sixteen words a container's ExGFX slot holds, whose low bytes are the
#: graphics files themselves -- so a container that names no file still
#: carries these.
#:
#: Each field is in the **top nibble** of its word's high byte; the low
#: nibble is the file number's own high bits, which is why a word naming no
#: file (``$FFFF``) reads as ones everywhere and why nothing here is read
#: until the enable bit says to.
#:
#: The enable bit is ``LG4``'s ``B``, "advanced bypass settings"; the colour
#: maths and the subscreen are ``SP1``'s ``C`` and ``S``; the horizontal
#: setting is ``SP2``'s ``H`` over ``LG2``'s four bits and the vertical
#: ``SP2``'s ``V`` over ``LG1``'s; the X offset is ``SP1``'s two bits, and
#: the Y offset the eleven spread over ``SP2``, ``SP3``, ``LG3`` and ``LG4``
#: -- of which this cartridge keeps the eight a signed byte of tiles holds.
BYPASS_ENABLED = ("LG4", 0x10)
BYPASS_COLOR_MATH = ("SP1", 0x40)
BYPASS_SUBSCREEN = ("SP1", 0x80)
BYPASS_HORIZONTAL_HIGH = ("SP2", 0x80)
BYPASS_VERTICAL_HIGH = ("SP2", 0x40)
BYPASS_HORIZONTAL = ("LG2", 0xF0)
BYPASS_VERTICAL = ("LG1", 0xF0)
BYPASS_OFFSET_X = ("SP1", 0x30)

#: The Y offset's eleven bits, each field with the place it takes: the
#: format spells them ``YYyyyyYYYYy``, high to low, across four words.
BYPASS_OFFSET_Y: tuple[tuple[str, int, int], ...] = (
    ("SP2", 0x30, 9),
    ("SP3", 0xF0, 5),
    ("LG3", 0xF0, 1),
    ("LG4", 0x80, 0),
)


def _high(words: bytes, slot: str) -> int:
    """The high byte of one bypass word."""
    at = level_graphics.BYPASS_WORDS.index(slot) * 2 + 1
    return words[at] if at < len(words) else 0x00


def _field(words: bytes, field: tuple[str, int]) -> int:
    slot, mask = field
    value = _high(words, slot) & mask
    while mask and not mask & 1:
        mask >>= 1
        value >>= 1
    return value


def from_bypass(words: bytes) -> Settings:
    """The settings a container's bypass words carry.

    Read for an imported container, whose Layer 3 settings are otherwise
    lost. The two scroll settings are the caveat this module's docstring
    states: their bits are the format's and their *values* are read as this
    cartridge numbers them.
    """
    if len(words) != level_graphics.BYPASS_BYTES:
        return Settings()
    if not _field(words, BYPASS_ENABLED):
        # The settings sit in the *top nibble* of each high byte, whose low
        # nibble is the file number's own high bits -- so a slot naming no
        # file reads as all ones, and every field but the enable bit is
        # meaningless until that one is set. Which is also what a level with
        # the advanced bypass off means.
        return Settings()
    offset_y = 0
    for slot, mask, shift in BYPASS_OFFSET_Y:
        offset_y |= _field(words, (slot, mask)) << shift
    return Settings(
        enabled=bool(_field(words, BYPASS_ENABLED)),
        color_math=bool(_field(words, BYPASS_COLOR_MATH)),
        subscreen=bool(_field(words, BYPASS_SUBSCREEN)),
        horizontal=_field(words, BYPASS_HORIZONTAL)
        | _field(words, BYPASS_HORIZONTAL_HIGH) << 4,
        vertical=_field(words, BYPASS_VERTICAL)
        | _field(words, BYPASS_VERTICAL_HIGH) << 4,
        offset_x=_field(words, BYPASS_OFFSET_X),
        offset_y=_clamp(_signed_eleven(offset_y)),
    )


def _signed_eleven(value: int) -> int:
    """Lunar Magic's Y offset is eleven bits, signed."""
    value &= 0x7FF
    return value - 0x800 if value & 0x400 else value


def _clamp(value: int) -> int:
    """As far as a signed byte of tiles reaches, which is what the tables
    hold: an offset past it is kept at the end of the range rather than
    wrapping into its own opposite."""
    return max(OFFSET_MIN, min(OFFSET_MAX, value))
