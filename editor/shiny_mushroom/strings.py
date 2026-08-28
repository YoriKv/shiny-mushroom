"""The game's text as words: what the Strings window edits, and what it costs.

Two regions carry it, both :class:`~smw_tools.asm_strings.TerminatedStrings`
over the standard font -- the 22 message boxes, and the parts the overworld
assembles a level's name from. Their model is tiles, because that is what the
cartridge holds and a tile no character spells has to survive a save; what a
person edits is text. This module is the seam between the two:

- :class:`Font` turns tiles into characters and back through the same table
  the assembler uses, with ``[XX]`` for a tile the font has no character for
  -- the cursive glyphs a shipped name is drawn with -- so every string is
  writable as text and reads back to the same bytes.
- :class:`StringsDocument` is the whole of what the window holds, as text: a
  value, compared whole to the last-saved one to know whether anything is
  unsaved, exactly as the colours are.
- :func:`price` is what a document would occupy in each region's run, asked
  before a save so the window can say "over by 12 bytes" instead of letting
  the project refuse.
- :func:`slots_of` says which level shows each message, off the slot tables
  the document holds, so a row can say *Yoshi's Island 2, message 1* rather
  than *LevelMsg05*.

No Qt, no emulator: text in, tiles out.
"""

from __future__ import annotations

import re
from collections.abc import Callable, Iterable
from dataclasses import dataclass, replace
from pathlib import Path

from smw_tools import asm_strings, fonts
from smw_tools.asm_strings import MESSAGE_LINES, MESSAGE_WIDTH, Messages

MESSAGES = "strings.level_messages"
NAMES = "strings.level_names"

#: A tile spelled by number, for one the font gives no character.
_TOKEN = re.compile(r"\[([0-9A-Fa-f]{2})\]")

#: How many of the first message slots are switch palaces -- off
#: ``SMW_DisplayMessage`` (``strings/MessageSlots_SMW_U.asm``). Past the level
#: slots, however many there are, come the riding-Yoshi variant of the last
#: one and the Yoshi-thanks message, which the routine picks by state rather
#: than by level.
SWITCH_PALACE_SLOTS = 4

#: The switch palace each of the first four slots draws, by the colour code
#: the message routine stores (``!RAM_SMW_Misc_ColorOfPalaceSwitchPressed1``).
SWITCH_COLOURS = ("Yellow", "Blue", "Red", "Green")


class TextError(ValueError):
    """Text the font cannot spell, or a line the box cannot show."""


@dataclass(frozen=True)
class Font:
    """The standard font as an editor reads and writes it."""

    table: fonts.FontTable

    @classmethod
    def load(cls, game_dir: Path) -> Font:
        return cls(fonts.FontTable.load(game_dir / fonts.STANDARD))

    def text(self, tiles: bytes) -> str:
        """``tiles`` as characters, bit 7 ignored, ``[XX]`` where the font
        has none."""
        chars = self.table.chars
        return "".join(
            chars.get(tile & 0x7F) or f"[{tile & 0x7F:02X}]" for tile in tiles
        )

    def tiles(self, text: str) -> bytes:
        """``text`` as tiles, or :class:`TextError` naming the first
        character the font cannot spell."""
        glyphs = self.table.glyphs
        out = bytearray()
        at = 0
        for match in _TOKEN.finditer(text):
            out += self._plain(text[at : match.start()], glyphs)
            out.append(int(match.group(1), 16))
            at = match.end()
        out += self._plain(text[at:], glyphs)
        return bytes(out)

    def _plain(self, text: str, glyphs: dict[str, int]) -> bytes:
        try:
            return bytes(glyphs[char] for char in text)
        except KeyError:
            bad = next(char for char in text if char not in glyphs)
            raise TextError(f"the font cannot spell {bad!r}") from None

    def unspellable(self, text: str) -> str:
        """Every character of ``text`` the font cannot spell, once each, in
        order -- the empty string for text it can. Tokens are spelling."""
        glyphs = self.table.glyphs
        plain = _TOKEN.sub("", text)
        seen: list[str] = []
        for char in plain:
            if char not in glyphs and char not in seen:
                seen.append(char)
        return "".join(seen)

    def width(self, text: str) -> int:
        """How many tiles ``text`` is -- a token is one."""
        return len(_TOKEN.sub("x", text))


def _lines(entry: bytes) -> tuple[bytes, ...]:
    """A region entry cut into its terminated strings, bits off."""
    out, held = [], bytearray()
    for tile in entry:
        held.append(tile & 0x7F)
        if tile & 0x80:
            out.append(bytes(held))
            held = bytearray()
    return tuple(out)


def _entry(lines: Iterable[bytes]) -> bytes:
    """Strings back into one entry, each terminated on its last tile; an
    empty string is a lone space, since nothing is ever empty."""
    out = bytearray()
    for line in lines:
        tiles = bytearray(line or b"\x1f")
        tiles[-1] |= 0x80
        out += tiles
    return bytes(out)


def _held(line: str) -> str:
    """A line as the document keeps it: never empty, because the cartridge
    cannot hold an empty string and a lone space is what one becomes."""
    return line or " "


@dataclass(frozen=True)
class StringsDocument:
    """Everything the window edits, as text.

    ``messages`` is one tuple of
    :data:`~smw_tools.asm_strings.MESSAGE_LINES` lines per message in
    ``LevelMsg`` order; ``names`` one string per level-name part in the
    fragment's order. A line is never empty -- see :func:`_held` -- so two
    documents that would save the same bytes compare equal.
    """

    messages: tuple[tuple[str, ...], ...] = ()
    names: tuple[str, ...] = ()
    #: The slot tables, as the region holds them: one byte per level slot
    #: (the translevel, bit 7 for its second message) and one message index
    #: per slot. Empty with no messages.
    levels: tuple[int, ...] = ()
    pointers: tuple[int, ...] = ()

    @classmethod
    def read(
        cls,
        font: Font,
        messages: Messages | None,
        names: tuple[bytes, ...] | None,
    ) -> StringsDocument:
        """The regions' models as text. Either may be absent -- a target
        whose build has no such fragment -- and then that half is empty."""
        return cls(
            messages=tuple(
                tuple(_held(font.text(line)) for line in _lines(entry))
                for entry in (messages.text if messages else ())
            ),
            names=tuple(_held(font.text(entry)) for entry in (names or ())),
            levels=messages.levels if messages else (),
            pointers=messages.pointers if messages else (),
        )

    def with_slot_level(
        self, slot: int, translevel: int, second: bool
    ) -> StringsDocument:
        """Slot ``slot`` for ``translevel``'s first or second message."""
        levels = list(self.levels)
        levels[slot] = (translevel & 0x7F) | (0x80 if second else 0)
        return replace(self, levels=tuple(levels))

    def with_slot_message(self, slot: int, message: int) -> StringsDocument:
        """Slot ``slot`` showing message ``message``."""
        pointers = list(self.pointers)
        pointers[slot] = message
        return replace(self, pointers=tuple(pointers))

    # -- growing and shrinking, on a cartridge whose search follows the rows --

    @property
    def level_slots(self) -> int:
        """How many slots name a level -- the two state-picked ones follow."""
        return len(self.levels)

    def with_slot_added(self) -> StringsDocument:
        """One more level slot, for translevel 0's first message, showing
        message 0 -- ahead of the two state-picked pointers, which stay
        last."""
        at = self.level_slots
        pointers = (*self.pointers[:at], 0, *self.pointers[at:])
        return replace(self, levels=(*self.levels, 0), pointers=pointers)

    def without_last_slot(self) -> StringsDocument:
        """The last level slot taken away; the state-picked pointers stay.
        Refuses to take the last one: the search lands on slot 0."""
        at = self.level_slots
        if at <= 1:
            raise TextError("the slot tables keep at least one level slot")
        pointers = (*self.pointers[: at - 1], *self.pointers[at:])
        return replace(self, levels=self.levels[:-1], pointers=pointers)

    def with_message_added(self) -> StringsDocument:
        """One more message, empty, at the end -- no slot shows it yet."""
        rows = len(self.messages[0]) if self.messages else MESSAGE_LINES
        return replace(self, messages=(*self.messages, (" ",) * rows))

    def slots_showing(self, message: int) -> tuple[int, ...]:
        """The slots that show message ``message``, by number."""
        return tuple(
            slot for slot, index in enumerate(self.pointers) if index == message
        )

    def without_message(self, message: int) -> StringsDocument:
        """Message ``message`` taken away, every later one renumbered. Refuses
        a message a slot still shows, and the last message there is."""
        if len(self.messages) <= 1:
            raise TextError("the messages keep at least one message")
        showing = self.slots_showing(message)
        if showing:
            listed = ", ".join(f"{slot:02X}" for slot in showing)
            raise TextError(f"message {message:02X} is shown by slot {listed}")
        messages = (*self.messages[:message], *self.messages[message + 1 :])
        pointers = tuple(
            index - 1 if index > message else index for index in self.pointers
        )
        return replace(self, messages=messages, pointers=pointers)

    def with_message_line(self, message: int, line: int, text: str) -> StringsDocument:
        rows = list(self.messages[message])
        rows[line] = _held(text)
        messages = list(self.messages)
        messages[message] = tuple(rows)
        return replace(self, messages=tuple(messages))

    def with_name(self, index: int, text: str) -> StringsDocument:
        names = list(self.names)
        names[index] = _held(text)
        return replace(self, names=tuple(names))

    def message_tiles(self, font: Font) -> Messages:
        """The messages as the region's model, or :class:`TextError`."""
        out = []
        for number, lines in enumerate(self.messages):
            tiles = []
            for row, line in enumerate(lines, start=1):
                held = _tiles(font, line, f"message {number:02X}, line {row}")
                if len(held) > MESSAGE_WIDTH:
                    raise TextError(
                        f"message {number:02X}, line {row}: {len(held)} tiles, "
                        f"and a line holds {MESSAGE_WIDTH} at most"
                    )
                tiles.append(held)
            out.append(_entry(tiles))
        return Messages(levels=self.levels, pointers=self.pointers, text=tuple(out))

    def name_tiles(self, font: Font) -> tuple[bytes, ...]:
        """The names as the region's model, or :class:`TextError`."""
        return tuple(
            _entry([_tiles(font, name, f"name part {asm_strings.NAME_LABELS[i]}")])
            for i, name in enumerate(self.names)
        )

    def models(self, font: Font) -> dict[str, object]:
        """Both regions' models by id, for the halves the document holds."""
        out: dict[str, object] = {}
        if self.messages:
            out[MESSAGES] = self.message_tiles(font)
        if self.names:
            out[NAMES] = self.name_tiles(font)
        return out


def _tiles(font: Font, text: str, where: str) -> bytes:
    try:
        return font.tiles(text)
    except TextError as error:
        raise TextError(f"{where}: {error}") from None


# -- pricing -------------------------------------------------------------------


def message_cost(font: Font, lines: Iterable[str]) -> int:
    """The bytes one message occupies: each line's tiles, a lone space for
    an empty one."""
    return sum(max(1, font.width(line)) for line in lines)


def price(font: Font, document: StringsDocument) -> dict[str, int]:
    """What each region's rows would occupy, by region id -- the number a
    run is compared against. Counted in tiles rather than through the codec,
    so a document the font cannot spell yet still has a size to show."""
    out: dict[str, int] = {}
    if document.messages:
        out[MESSAGES] = (
            len(document.levels)
            + 2 * len(document.pointers)
            + sum(message_cost(font, lines) for lines in document.messages)
        )
    if document.names:
        out[NAMES] = sum(max(1, font.width(name)) for name in document.names)
    return out


# -- which level shows which message -------------------------------------------


@dataclass(frozen=True)
class Slot:
    """One row of the game's message table: who shows this message."""

    #: The slot's index, ``0`` to ``$18``.
    number: int
    #: The translevel the slot is for, or ``None`` for the Yoshi-thanks slot.
    translevel: int | None
    #: Whether the slot is the level's second message.
    second: bool
    #: What is special about it -- a switch palace, riding Yoshi, Yoshi's
    #: thanks -- or ``""`` for an ordinary level message.
    note: str = ""

    def describe(self, name_of: Callable[[int], str | None]) -> str:
        """The slot for a person: the level's name where the world map has
        one, its translevel number otherwise, and which of its messages."""
        if self.translevel is None:
            return self.note
        name = name_of(self.translevel) or f"translevel {self.translevel:02X}"
        which = "message 2" if self.second else "message 1"
        held = self.note or which
        return f"{name} -- {held}"


def slots_of(document: StringsDocument) -> tuple[Slot, ...]:
    """Every slot as the document's tables say it: which level, which of
    its messages, and what is special about it.

    The first four slots are the switch palaces -- slot 0 being where a
    level in no slot lands too -- and the last two are the riding-Yoshi
    variant of the last level slot and the Yoshi-thanks message, which the
    routine picks by state rather than by level.
    """
    out = []
    for number, byte in enumerate(document.levels):
        note = ""
        if number < SWITCH_PALACE_SLOTS:
            note = f"{SWITCH_COLOURS[number]} Switch Palace"
        out.append(Slot(number, byte & 0x7F, bool(byte & 0x80), note))
    if document.levels:
        last = document.levels[-1]
        riding = document.level_slots
        out.append(Slot(riding, last & 0x7F, bool(last & 0x80), "riding Yoshi"))
        out.append(Slot(riding + 1, None, False, "Yoshi's thanks"))
    return tuple(out)


def message_slots(document: StringsDocument) -> dict[int, tuple[Slot, ...]]:
    """Which slots show each message, by message index. A message no slot
    names is absent."""
    out: dict[int, list[Slot]] = {}
    for slot in slots_of(document):
        if slot.number < len(document.pointers):
            out.setdefault(document.pointers[slot.number], []).append(slot)
    return {index: tuple(held) for index, held in out.items()}
