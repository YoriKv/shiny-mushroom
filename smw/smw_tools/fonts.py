"""The character tables the game's text is assembled through.

A string in the disassembly is a ``db "..."`` under asar character
assignments, and those are what turn each character into the tile the
game draws: ``tables/fonts/standard.asm`` says ``'A' = $00``, so ``"A"``
assembles to ``$00``. Nothing in the assembled cartridge remembers the character, only
the tile, so reading text back off a ROM -- or off a fragment written in hex
-- means holding the same table the assembler held.

This module is that table, read from the file the assembler reads rather
than restated, so a glyph added to the font reaches the editor by editing
the one file asar would also have to be told about.

**A table is one direction at a time.** ``standard.asm`` maps ``\\`` to
``$9F``, which is not a glyph: it is a space with bit 7 set, the terminator
the level-name strings are written with. :meth:`FontTable.tile` answers for
every entry, since that is what asar does; :attr:`FontTable.glyphs` lists
only the characters that are a tile of their own -- values below ``$80`` --
which is what an editor offers as typeable.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from functools import cache
from pathlib import Path

#: One character assignment as the font files spell it: the character in
#: single quotes, spaces around the ``=``, the tile in hex.
_ASSIGNMENT = re.compile(r"'(?P<char>.)' = \$(?P<hex>[0-9A-Fa-f]+)")


class FontError(ValueError):
    """A table that cannot be read, or text the table has no tile for."""


@dataclass(frozen=True)
class FontTable:
    """One font file: asar's ``'<char>' = $<hex>`` per line, one tile a character."""

    #: What each character assembles to.
    tiles: dict[str, int] = field(default_factory=dict)

    @property
    def glyphs(self) -> dict[str, int]:
        """The characters that are a tile of their own -- the typeable ones.

        An entry at ``$80`` or above carries the bit-7 terminator the strings
        use, and is a spelling of "end here" rather than a character; a
        table's ``\\`` is that, and nothing offers it as a key.
        """
        return {char: tile for char, tile in self.tiles.items() if tile < 0x80}

    @property
    def chars(self) -> dict[int, str]:
        """Each glyph tile's character -- :attr:`glyphs` the other way."""
        return {tile: char for char, tile in self.glyphs.items()}

    def tile(self, char: str) -> int:
        """The tile ``char`` assembles to, or :class:`FontError`."""
        try:
            return self.tiles[char]
        except KeyError:
            raise FontError(f"the font has no tile for {char!r}") from None

    def char(self, tile: int) -> str | None:
        """The character drawn as ``tile``, or ``None`` for one no character
        assembles to -- the cursive tiles a level name spells by number."""
        return self.chars.get(tile)

    def encode(self, text: str) -> bytes:
        """``text`` as tiles, exactly as ``db "text"`` assembles under the
        table. Refuses a character the table has no glyph for."""
        glyphs = self.glyphs
        out = bytearray()
        for char in text:
            tile = glyphs.get(char)
            if tile is None:
                raise FontError(f"the font has no tile for {char!r}")
            out.append(tile)
        return bytes(out)

    @classmethod
    def parse(cls, text: str) -> FontTable:
        """A font file's text. Blank lines are nothing; anything else is one
        of asar's character assignments, ``'c' = $hex``, with the hex as many
        digits as the tile is wide -- the one form the files use, so anything
        else asar would also accept on such a line is refused here."""
        tiles: dict[str, int] = {}
        for number, raw in enumerate(text.split("\n"), start=1):
            line = raw.rstrip("\r")
            if not line.strip():
                continue
            found = _ASSIGNMENT.fullmatch(line)
            if found is None:
                raise FontError(f"line {number}: {line!r} is not 'c' = $hex")
            tiles[found["char"]] = int(found["hex"], 16)
        return cls(tiles)

    @classmethod
    def load(cls, path: Path) -> FontTable:
        """The table at ``path``, read once per path."""
        return _load(Path(path))


@cache
def _load(path: Path) -> FontTable:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as error:
        raise FontError(f"{path}: {error}") from error
    return FontTable.parse(text)


#: The font every international string assembles through, relative to the
#: base's game folder.
STANDARD = Path("tables/fonts/standard.asm")
