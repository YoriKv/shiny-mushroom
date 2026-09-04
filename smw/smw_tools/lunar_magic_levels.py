"""Lunar Magic level compatibility: the four bytes Lunar Magic adds to a
level's secondary header, and the Layer 2 scroll settings they carry.

Under the ``lunar-magic-levels`` feature (``Config/LunarMagicLevels.asm``)
the cartridge holds the four ``$200``-byte tables Lunar Magic keeps beyond
the stock secondary header -- one fragment per byte under
``levels/properties/``, the editor's asm regions
:data:`REGION_IDS` -- and gives their Layer 2 scroll settings Lunar Magic's
meaning: a level whose scroll byte has :data:`SEPARATE_SCROLL` set takes the
header's nibble whole as its horizontal setting and the byte's low five
bits as its vertical one, and either setting is one of the thirty-two
:data:`SCROLL_SETTINGS` rather than the stock game's four.

This module carries the tables' shape and defaults, where a level container
keeps the four bytes, the settings' names and the scaling the cartridge
applies, so the editor can read a container, write the tables and say what
a setting does without a build. The layout the config fixes is restated
here and held against the config's own literals by a test.

**The bytes live in the cartridge's tables, and a container carries a
copy.** A Lunar Magic ``.mwl`` of format 3 keeps them in its
level-information slot beside the stock four (:func:`container_settings`),
which is what an imported container is read for; the tables are what the
build assembles, exactly as the stock secondary header's are.
"""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
from pathlib import Path

from .asm_defines import block
from .bases import RomBase

#: The feature under which the tables exist, by id -- the same string
#: :data:`smw_tools.features.LUNAR_MAGIC_LEVELS` declares, spelled here so
#: this module's imports stay its own.
FEATURE = "lunar-magic-levels"

#: The asar define the config guards.
DEFINE = "Define_SMW_LunarMagicLevels"

#: The four bytes, in the order Lunar Magic keeps its tables: the entrance
#: flags, the scroll byte, the entrance's high Y bits, the background.
SIZE = 4
ENTRANCE, SCROLL, ENTRANCE_Y, BACKGROUND = range(SIZE)

#: The editor's asm regions holding the tables, in byte order -- one
#: fragment per table under ``levels/properties/``.
REGION_IDS: tuple[str, ...] = (
    "levels.lunar_magic_entrance",
    "levels.lunar_magic_scroll",
    "levels.lunar_magic_entrance_y",
    "levels.lunar_magic_background",
)

#: The roles the feature declares each table under, in the same order, and
#: the fragment each is emitted from.
ROLES: tuple[str, ...] = (
    "lunar_magic_entrance",
    "lunar_magic_scroll",
    "lunar_magic_entrance_y",
    "lunar_magic_background",
)
FRAGMENTS: tuple[Path, ...] = (
    Path("levels/properties/lunar-magic-entrance.asm"),
    Path("levels/properties/lunar-magic-scroll.asm"),
    Path("levels/properties/lunar-magic-entrance-y.asm"),
    Path("levels/properties/lunar-magic-background.asm"),
)

#: The four labels the fragments carry, without the ``SMW_LunarMagicLevels``
#: namespace the placement wraps them in.
LABELS: tuple[str, ...] = ("Entrance", "Scroll", "EntranceY", "Background")
NAMESPACE = "SMW_LunarMagicLevels"

#: The first stub behind the tables, which is where the block stops being
#: rows and starts being code -- the label the memory map cuts the block
#: at. The config's placement lays it directly after the fourth table.
STUBS_LABEL = f"{NAMESPACE}_ScrollSettings"

#: How many levels each table holds a byte for, and the tables' size.
LEVELS = 0x200
TABLE_BYTES = LEVELS
TABLES_BYTES = SIZE * TABLE_BYTES

#: What Lunar Magic writes for a level it has not touched -- and what every
#: row of the shipped fragments holds: no entrance flags, the scroll byte's
#: auto-set-screens flag alone, no high Y bits, and the stock background's
#: twenty-seven rows less one.
DEFAULT = bytes((0x00, 0x20, 0x00, 0x1A))

#: The scroll byte's bits: ``S``, the level scrolls Layer 2 by the two
#: settings of its own; ``C``, the tool's auto-set-screens flag, which the
#: game never reads; and the five bits of the vertical setting.
SEPARATE_SCROLL = 0x80
AUTO_SCREENS = 0x20
VERTICAL_SCROLL_MASK = 0x1F

#: The entrance byte's bits: ``I`` slippery, ``W`` water, ``P`` the main
#: entrance placed at a tile by the second method, ``XX`` that tile column's
#: high two bits over the header's three. The low three bits, ``t`` and
#: ``TT``, are the sprite spawn settings the cartridge does not read yet.
SLIPPERY = 0x80
WATER = 0x40
SECOND_METHOD = 0x20
HIGH_X_MASK = 0x18
HIGH_X_SHIFT = 3
SPAWN_MASK = 0x07

#: The entrance Y byte's bits: ``O`` Layer 2 placed from Layer 1 rather than
#: from its own height, ``F`` the sign of a relative entrance's camera
#: offset, ``YYYYYY`` the tile row's high six bits over the header's four.
BACKGROUND_RELATIVE = 0x80
OFFSET_HIGH = 0x40
HIGH_Y_MASK = 0x3F

#: The background byte's bits: ``R`` the camera placed from the player,
#: ``L`` the player facing left, ``ooooo`` the background's rows less one --
#: or, with ``O`` set, its offset from the camera in rows: ``$00``-``$0F``
#: that many down, ``$11``-``$1F`` counting back from ``$20``, and ``$10``
#: the layer at the level's top outright, the wiki's "absolute 0" --
#: measured so against Lunar Magic 3.63.
RELATIVE = 0x80
FACE_LEFT = 0x40
BACKGROUND_ROWS_MASK = 0x1F
BACKGROUND_TOP = 0x10

#: The tables' offset from the level bank's base -- the packed head, past
#: the RATS tag and the level number stash -- and the block's whole size,
#: the four tables and the stubs, from ``Config/PackedRuns.asm`` where the
#: placement asserts it. One size on every cartridge.
TABLES_OFFSET = 0x8011
BLOCK_BYTES = block("LunarMagicLevels")
STUB_BYTES = BLOCK_BYTES - TABLES_BYTES

# -- the settings ----------------------------------------------------------------


@dataclass(frozen=True)
class ScrollSetting:
    """One of the thirty-two Layer 2 scroll settings, as the cartridge
    applies it.

    ``shift`` is how many places Layer 1's position is shifted right to
    place Layer 2 -- zero for constant -- for a setting that scales; ``fast``
    is the one ratio that is not a shift, six fifths; ``speed`` is a
    self-scrolling setting's speed in 256ths of a pixel a frame, signed,
    rightwards or downwards positive. A setting with none of the three
    leaves the layer where the load put it.
    """

    value: int
    name: str
    shift: int | None = None
    fast: bool = False
    speed: int | None = None

    @property
    def scrolls(self) -> bool:
        """Whether the layer moves at all under this setting."""
        return self.shift is not None or self.fast or self.speed is not None

    @property
    def self_scrolling(self) -> bool:
        """Whether the layer moves on its own rather than with the camera."""
        return self.speed is not None

    def scaled(self, position: int) -> int:
        """Layer 2's position for Layer 1 at ``position``, for a setting
        that scales -- the shift, or the position plus a fifth of it; the
        position itself for one that does not."""
        if self.shift is not None:
            return position >> self.shift
        if self.fast:
            return position + position // 5
        return position


#: The six self-scrolling speeds, in 256ths of a pixel a frame: the slowest
#: is the fog and goldfish's, ``$100`` the tides', the fastest the fast
#: background scroll sprite's.
SELF_SCROLL_SPEEDS: tuple[int, ...] = (0x40, 0x80, 0x100, 0x200, 0x300, 0x400)
FIRST_SELF_SCROLL = 0x10


def _settings() -> tuple[ScrollSetting, ...]:
    scaled = (
        ScrollSetting(0x00, "None"),
        ScrollSetting(0x01, "Constant (1:1)", shift=0),
        ScrollSetting(0x02, "Medium (1:2)", shift=1),
        ScrollSetting(0x03, "Slow (1:32)", shift=5),
        ScrollSetting(0x04, "Medium 2 (1:4)", shift=2),
        ScrollSetting(0x05, "Medium 3 (1:8)", shift=3),
        ScrollSetting(0x06, "Medium 4 (1:16)", shift=4),
        ScrollSetting(0x07, "Slow 2 (1:64)", shift=6),
        ScrollSetting(0x08, "Fast (6:5)", fast=True),
    )
    unused = tuple(
        ScrollSetting(value, f"None (${value:02X})")
        for value in range(0x09, FIRST_SELF_SCROLL)
    )
    ahead = tuple(
        ScrollSetting(
            FIRST_SELF_SCROLL + index,
            f"Auto-scroll forward, {speed / 256:g} px/frame",
            speed=speed,
        )
        for index, speed in enumerate(SELF_SCROLL_SPEEDS)
    )
    back = tuple(
        ScrollSetting(
            FIRST_SELF_SCROLL + len(SELF_SCROLL_SPEEDS) + index,
            f"Auto-scroll back, {speed / 256:g} px/frame",
            speed=-speed,
        )
        for index, speed in enumerate(SELF_SCROLL_SPEEDS)
    )
    idle = tuple(
        ScrollSetting(value, f"Auto-scroll, no speed (${value:02X})", speed=0)
        for value in range(FIRST_SELF_SCROLL + 2 * len(SELF_SCROLL_SPEEDS), 0x20)
    )
    return (*scaled, *unused, *ahead, *back, *idle)


#: The thirty-two settings, indexed by value. The first four are the stock
#: game's four -- the pair tables in ``SMW_SpecifySublevelToLoad`` hold
#: those values -- and the rest are Lunar Magic's.
SCROLL_SETTINGS: tuple[ScrollSetting, ...] = _settings()

#: How many settings there are, which is what a five-bit field holds.
SETTINGS = len(SCROLL_SETTINGS)


def setting(value: int) -> ScrollSetting:
    """The setting numbered ``value``, refusing one past the five bits."""
    if not 0 <= value < SETTINGS:
        raise ValueError(f"a scroll setting is 0-{SETTINGS - 1}, not {value}")
    return SCROLL_SETTINGS[value]


def scroll_settings(scroll: int, header1: int) -> tuple[int, int]:
    """The horizontal and vertical setting a level runs with: from its
    scroll byte and its first secondary-header byte, both as the tables
    hold them. With :data:`SEPARATE_SCROLL` set the header's high nibble is
    the horizontal setting whole and the byte's low five bits the vertical;
    clear, that nibble picks a pair out of the cartridge's two pair tables,
    which is the stock game's reading and :func:`paired_settings`'s."""
    nibble = (header1 >> 4) & 0x0F
    if scroll & SEPARATE_SCROLL:
        return nibble, scroll & VERTICAL_SCROLL_MASK
    return paired_settings(nibble)


#: The pair tables as the feature's build holds them: the stock eight pairs,
#: then the four Lunar Magic added -- each a variable horizontal with a
#: vertical medium 2, medium 3, medium 4 and slow 2 -- and four that do not
#: scroll. Horizontal first, indexed by the header's nibble.
PAIRS: tuple[tuple[int, int], ...] = (
    (2, 3), (2, 1), (1, 1), (0, 0), (1, 0), (2, 2), (1, 2), (0, 1),
    (2, 4), (2, 5), (2, 6), (2, 7), (0, 0), (0, 0), (0, 0), (0, 0),
)  # fmt: skip


def paired_settings(nibble: int) -> tuple[int, int]:
    """The horizontal and vertical setting the header's scroll nibble picks
    out of the pair tables, on a cartridge with the feature."""
    return PAIRS[nibble & 0x0F]


# -- the bytes in a container ----------------------------------------------------

#: Where a container of format 3 keeps the four bytes in its
#: level-information slot: the entrance byte after the level number and the
#: stock four, then -- past eight bytes the tool keeps for itself -- the
#: entrance's high Y bits, the background, the tool's horizontal level mode,
#: and the scroll byte. In byte order, as offsets into the slot.
INFO_SLOT = 0
INFO_OFFSETS: tuple[int, ...] = (0x06, 0x11, 0x0E, 0x0F)
INFO_BYTES = 0x40

#: The container format that carries the bytes: the fourth byte of the file.
#: Format 2 -- every container the disassembly ships, written by Lunar Magic
#: 2.53 -- keeps zeros there, which read as no settings at all.
INFO_FORMAT = 3
_TABLE_START = 0x40
_ENTRY_SIZE = 8


def container_settings(container: Path | bytes) -> bytes | None:
    """The four bytes a ``.mwl`` carries for its level, or ``None`` for a
    container that carries none: one of a format before 3, one whose
    level-information slot is not the tool's sixty-four bytes, or one whose
    four bytes are all zero -- which no format-3 file writes, the untouched
    level being :data:`DEFAULT`."""
    data = container.read_bytes() if isinstance(container, Path) else bytes(container)
    if len(data) < _TABLE_START + _ENTRY_SIZE or data[:2] != b"LM":
        return None
    offset = int.from_bytes(data[_TABLE_START : _TABLE_START + 4], "little")
    size = int.from_bytes(data[_TABLE_START + 4 : _TABLE_START + 8], "little")
    if offset + size > len(data):
        return None
    return slot_settings(data[3], data[offset : offset + size])


def slot_settings(format: int, info: bytes) -> bytes | None:
    """The four bytes a container's level-information slot carries, given
    the file's format byte and the slot whole -- what
    :func:`container_settings` reads once it has found the slot, for a
    caller that already holds the pieces. ``None`` on the same terms."""
    if format < INFO_FORMAT or len(info) != INFO_BYTES:
        return None
    found = bytes(info[at] for at in INFO_OFFSETS)
    return None if found == bytes(SIZE) else found


def with_container_settings(info: bytes, settings: bytes) -> bytes:
    """``info`` -- a container's sixty-four-byte level-information slot --
    with the four bytes written where a format-3 file keeps them; every
    other byte as it was."""
    if len(info) != INFO_BYTES:
        raise ValueError(
            f"a level-information slot is {INFO_BYTES} bytes, not {len(info)}"
        )
    if len(settings) != SIZE:
        raise ValueError(f"the settings are {SIZE} bytes, not {len(settings)}")
    out = bytearray(info)
    for at, value in zip(INFO_OFFSETS, settings, strict=True):
        out[at] = value
    return bytes(out)


def check(settings: Sequence[int]) -> bytes:
    """``settings`` as the tables hold them, refusing the wrong length."""
    held = bytes(settings)
    if len(held) != SIZE:
        raise ValueError(f"the settings are {SIZE} bytes, not {len(held)}")
    return held


def is_enabled(base: RomBase) -> bool:
    """Whether ``base`` carries the tables -- see :data:`FEATURE`."""
    return FEATURE in base.features
