"""What a level-name word says, and the parts it can say instead.

The overworld's name box is assembled, not stored: each translevel's row of
the level-names table (``WorldMap.level_names``) is a 16-bit word naming three
*parts*, and each part is an offset-table entry pointing into one strings blob
(``docs/smw/overworld.md``, "The level-name box"). The word's fields, off the
international builds' routine (``SMW_UpdateLevelName`` in ``Banks/Bank04.asm``):

- **part 1** -- the word's high byte ``& $7F``, indexing the 31-entry first
  table. Skipped when the string it names *starts* with a bit-7 byte, which
  is how ``LevelStr_None`` says nothing.
- **part 2** -- the low nibble pair ``(lo & $F0) >> 4``, indexing the
  15-entry second table. Skipped when the string's first byte is exactly
  ``$9F`` -- a lone terminal space.
- **part 3** -- ``lo & $0F``, indexing the 13-entry third table, emitted
  unconditionally; its "none" entry is that same lone terminal space.

A part's characters are tile numbers with bit 7 marking the last one (the
last character is kept, masked), and every part vanilla writes ends in a
space tile -- which is where the gaps between words come from. The box is 19
characters, padded with spaces.

The tables live in the cartridge, so they are *read* from the session's ROM
image through the ``overworld_level_name_*`` roles -- absent on the Japanese
build, whose name routine speaks its own kana format; there this module
answers ``None`` and nothing offers an edit, matching the
``overworld.level_names`` region's own target exclusion.

No Qt, no emulator: bytes in, text out.
"""

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from shiny_mushroom.addresses import Addresses

#: How many entries each offset table holds on the international builds --
#: the shipped tables' sizes, which the word format itself does not bound
#: (part 1's index has seven bits for 31 rows). An index past the end is the
#: game reading whatever follows; the decoder says so instead.
PART_COUNTS = (31, 15, 13)

#: The name box's width in characters; shorter names are padded with spaces.
BOX_WIDTH = 19

#: The character tiles, off ``tables/fonts/standard.asm`` -- the asar character
#: assignments the strings are assembled through, restated here so a session with no
#: disassembly tree in reach can still read a name off its cartridge.
_FONT = {
    **{0x00 + i: chr(ord("A") + i) for i in range(26)},
    0x1A: "!",
    0x1B: ".",
    0x1C: "-",
    0x1D: ",",
    0x1E: "?",
    0x1F: " ",
    **{0x40 + i: chr(ord("a") + i) for i in range(26)},
    0x5A: "#",
    0x5B: "(",
    0x5C: ")",
    0x5D: "'",
    **{0x64 + i: str(i + 1) for i in range(7)},
    0x6B: "0",
}

#: The cursive display tiles the shipped strings use where the plain font
#: has no glyph: the six spelling ``ILLUSI`` inside "OF ... ON" (each string
#: says so in its own comment) and the five spelling ``YELLOW``. The five
#: carry six letters -- "YELLOW SWITCH PALACE" only fits the 19-character box
#: at five tiles -- so one of them is the double letter.
_GLYPHS = {
    0x32: " I",
    0x33: "L",
    0x34: "L",
    0x35: "U",
    0x36: "S",
    0x37: "I",
    0x38: "Y",
    0x39: "E",
    0x3A: "LL",
    0x3B: "O",
    0x3C: "W",
}


@dataclass(frozen=True)
class NameTables:
    """The strings blob and the three offset tables, as one cartridge holds
    them -- everything a word needs to become text."""

    strings: bytes
    parts: tuple[tuple[int, ...], tuple[int, ...], tuple[int, ...]]


def read_name_tables(rom: bytes, where: Addresses) -> NameTables | None:
    """The name tables off ``rom``, or ``None`` where the build has none.

    The strings blob runs from its label to the first offset table -- the
    ROM map packs them back to back -- and the offset tables hold their
    shipped counts. ``None`` is the Japanese build's answer: its roles are
    declared absent, and its words are not this module's format.
    """
    strings_at = where.roles.get("overworld_level_name_strings")
    tables_at = tuple(
        where.roles.get(f"overworld_level_name_part{n}") for n in (1, 2, 3)
    )
    if strings_at is None or any(at is None for at in tables_at):
        return None
    strings_offset = where.offset(strings_at)
    strings = bytes(rom[strings_offset : where.offset(tables_at[0])])
    parts = []
    for at, count in zip(tables_at, PART_COUNTS, strict=True):
        offset = where.offset(at)
        parts.append(
            tuple(
                int.from_bytes(rom[offset + i * 2 : offset + i * 2 + 2], "little")
                for i in range(count)
            )
        )
    return NameTables(strings=strings, parts=(parts[0], parts[1], parts[2]))


def indices(word: int) -> tuple[int, int, int]:
    """A name word's three part indices, in part order."""
    return ((word >> 8) & 0x7F, (word >> 4) & 0x0F, word & 0x0F)


def word_for(part1: int, part2: int, part3: int) -> int:
    """The word saying these three parts. The high byte's spare bit is
    dropped -- the routine masks it and vanilla's words keep it clear."""
    return ((part1 & 0x7F) << 8) | ((part2 & 0x0F) << 4) | (part3 & 0x0F)


@lru_cache(maxsize=8)
def _part_texts(tables: NameTables, which: int) -> tuple[str, ...]:
    return tuple(_emitted(tables.strings, offset) for offset in tables.parts[which])


def part_text(tables: NameTables, which: int, index: int) -> str:
    """Part ``which``'s entry ``index`` as the box would draw it -- the
    empty string for a part the routine skips, and a marker where the
    entry is not there to read, which the game would read as garbage.
    An entry can be missing two ways: an index past its part's table, or
    an offset past the strings the parts index into, which is what a
    cartridge too short to hold the relocated tables reads as."""
    if not 0 <= index < len(tables.parts[which]):
        return f"(past the table: {index:#x})"
    offset = tables.parts[which][index]
    if not 0 <= offset < len(tables.strings):
        return f"(past the strings: {offset:#x})"
    text = _part_texts(tables, which)[index]
    if which == 0 and tables.strings[offset] & 0x80:
        # Part 1 is skipped outright when its string starts terminated.
        return ""
    if which == 1 and tables.strings[offset] == 0x9F:
        # Part 2 is skipped when its string is a lone terminal space.
        return ""
    return text


def decode(word: int, tables: NameTables) -> str:
    """``word`` as the 19-character box draws it, trailing padding trimmed."""
    part1, part2, part3 = indices(word)
    text = "".join(
        part_text(tables, which, index)
        for which, index in enumerate((part1, part2, part3))
    )
    return text[:BOX_WIDTH].rstrip()


def part_options(tables: NameTables, which: int) -> tuple[tuple[int, str], ...]:
    """Every entry of part ``which`` as ``(index, label)`` pairs for a
    picker, the skipped entries offered as ``(none)``."""
    return tuple(
        (index, part_text(tables, which, index).rstrip() or "(none)")
        for index in range(len(tables.parts[which]))
    )


def _emitted(strings: bytes, offset: int) -> str:
    """The string at ``offset``, drawn: characters until the bit-7 byte,
    that last one kept masked -- exactly the routine's emit loop."""
    out = []
    at = offset
    while at < len(strings):
        byte = strings[at]
        tile = byte & 0x7F
        out.append(_GLYPHS.get(tile) or _FONT.get(tile) or f"[{tile:02X}]")
        if byte & 0x80:
            break
        at += 1
    return "".join(out)
