"""The regions whose model is the game's text.

The message boxes and the level-name parts: font tiles rather than tuples of
numbers, a string ended by the high bit of its last tile, read and written
through the font table the fragment puts in force.
:class:`TerminatedStrings` is that shape; :class:`MessageTables` is the one
region that carries a message file, its two slot tables and the message text
together. Both are :class:`~smw_tools.asm_codec.AsmRegion`s, and
:mod:`smw_tools.asm_regions` is the registry that declares them.
"""

from __future__ import annotations

import re
from collections.abc import Callable
from dataclasses import dataclass, replace
from pathlib import Path
from typing import TYPE_CHECKING

from . import fonts
from .asm_codec import (
    AsmRegion,
    AsmRegionError,
    _comment_stripped,
    _joined,
    _rows,
    _values,
)

if TYPE_CHECKING:
    from .bases import RomBase


#: Where the game's text lives, under the base's game folder.
STRINGS_DIR = Path("strings")

#: The directives that put the standard font in force, as the shipped string
#: fragments spell them: relative to the fragment's own folder, which is
#: where asar resolves a `table` from.
FONT_HEADER = ("cleartable", 'table "../tables/fonts/standard.txt"')

#: The message boxes: how many, and the box each is drawn in -- eight rows
#: of eighteen tiles, off SMW_DisplayMessage's upload loop.
MESSAGE_LABELS = tuple(f"LevelMsg{n:02X}" for n in range(0x16))
MESSAGE_LINES = 8
MESSAGE_WIDTH = 18

#: The level-name parts, in the order the shipped fragment lays them out:
#: the first-part strings, the second, the third, then the one every part
#: table's "none" row points at. The label numbers are the word each part
#: is picked by (`overworld_level_names` rows), spelled as the fragment
#: spells them.
NAME_LABELS = (
    *(f"LevelStr_{n:02X}00" for n in range(0x01, 0x1F)),
    *(f"LevelStr_00{n:X}0" for n in range(0x1, 0xF)),
    *(f"LevelStr_000{n:X}" for n in range(0x1, 0xD)),
    "LevelStr_None",
)


#: A message line's spelling inside a ``db``: the characters safe to write
#: between quotes. Anything else is written as a tile number, because asar
#: reads a ``!name`` inside a string as a define to expand, and a message is
#: free to shout.
_QUOTABLE = frozenset(
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,-?'#()"
)

#: The one conditional a shipped string file carries: the arcade cartridge's
#: own wording of a message, under a version `if`. Read as the *other* builds
#: read it -- the region refuses the arcade target -- and never written.
_ARCADE_IF = "if !Define_Global_ROMToAssemble == !ROM_SMW_ARCADE"


def _split_args(payload: str) -> list[str]:
    """A ``db`` payload's comma-separated arguments, quotes respected."""
    out, held, quoted = [], [], False
    for char in payload:
        if char == '"':
            quoted = not quoted
        if char == "," and not quoted:
            out.append("".join(held).strip())
            held = []
            continue
        held.append(char)
    out.append("".join(held).strip())
    return out


def _string_arg(arg: str, font: fonts.FontTable, where: str) -> bytes:
    """One ``db`` argument as the bytes asar assembles it to: a quoted
    literal through the table, or ``$XX`` with an optional ``|$80``."""
    if arg.startswith('"'):
        if not arg.endswith('"') or len(arg) < 2:
            raise AsmRegionError(f"{where}: {arg!r} is not a closed string")
        try:
            return bytes(font.tile(char) for char in arg[1:-1])
        except fonts.FontError as error:
            raise AsmRegionError(f"{where}: {error}") from None
    value = 0
    for piece in arg.split("|"):
        piece = piece.strip()
        if not piece.startswith("$"):
            raise AsmRegionError(f"{where}: {arg!r} is not a string or a $-value")
        try:
            value |= int(piece[1:], 16)
        except ValueError:
            raise AsmRegionError(f"{where}: {arg!r} is not hexadecimal") from None
    if not 0 <= value < 0x100:
        raise AsmRegionError(f"{where}: {arg!r} is not a byte")
    return bytes([value])


def _terminated(entry: bytes) -> list[bytes]:
    """``entry`` cut after every bit-7 byte, the tail (if any) kept last."""
    out, start = [], 0
    for at, byte in enumerate(entry):
        if byte & 0x80:
            out.append(entry[start : at + 1])
            start = at + 1
    if start < len(entry):
        out.append(entry[start:])
    return out


@dataclass(frozen=True)
class TerminatedStrings(AsmRegion):
    """Labelled strings whose last tile carries bit 7, under a font table.

    The form the game's text takes: tiles from ``tables/fonts/standard.txt``,
    the end of a string said by the high bit of its last tile rather than by
    a byte of its own, so a one-tile string is one byte and nothing is ever
    empty. Two shapes wear it -- the level-name parts, one string a label,
    and the message boxes, :attr:`lines` strings a label read as the rows of
    a box -- and both are fixed lists of labels: the pointer tables name
    them, and a label neither added nor dropped is the format.

    The model is one ``bytes`` per label, in :attr:`labels` order, the bit-7
    marks inside: text as the cartridge holds it, so a tile no character
    spells -- the cursive ones a level name is drawn with -- is carried
    rather than lost. Turning it into characters is the reader's business,
    through the same :class:`~smw_tools.fonts.FontTable` this assembles by.

    What the rows cost is what they hold, and the run is the disassembly's
    own bytes: the pointers into a fragment are offsets the assembler
    computes, so a string may grow while another shrinks, and the whole has
    to stay within what the shipped strings occupied.
    """

    #: The labels, in ROM order -- one entry each.
    labels: tuple[str, ...] = ()
    #: Terminated strings an entry holds: one, or the rows of a message box.
    lines: int = 1
    #: Most tiles a string may hold, or ``None`` where nothing bounds it.
    line_width: int | None = None
    #: Lines written ahead of the first label -- the ``cleartable`` and
    #: ``table`` that put the font in force for a fragment assembled where
    #: no other has. Parsed past, never into the model.
    header: tuple[str, ...] = ()
    #: One file per entry, in :attr:`labels` order, for a fragment split
    #: one entry a file; empty where :attr:`path` holds them all.
    entry_files: tuple[Path, ...] = ()
    #: The table the strings assemble through, under the base's game folder.
    font: Path = fonts.STANDARD

    def __post_init__(self) -> None:
        self._check_sections()
        if len(set(self.labels)) != len(self.labels) or not self.labels:
            raise AsmRegionError(f"{self.id}: the labels must be distinct")
        if self.entry_files and len(self.entry_files) != len(self.labels):
            raise AsmRegionError(f"{self.id}: one file an entry, or none")
        if self.lines < 1:
            raise AsmRegionError(f"{self.id}: an entry holds at least one string")

    def _check_sections(self) -> None:
        if len(self.sections) != 1:
            raise AsmRegionError(f"{self.id}: one blob, so one section")

    @property
    def files(self) -> tuple[Path, ...]:
        return self.entry_files or (self.path,)

    @property
    def strides(self) -> tuple[int, ...]:
        return (1,)

    def _font(self, base: RomBase) -> fonts.FontTable:
        try:
            return fonts.FontTable.load(base.game_dir / self.font)
        except fonts.FontError as error:
            raise AsmRegionError(f"{self.id}: {error}") from error

    # -- the codec -------------------------------------------------------------

    def decode(self, images: dict[str, bytes]) -> tuple[bytes, ...]:
        """The entries off the run: each is :attr:`lines` terminated strings,
        read back to back. What follows the last entry is the run's slack --
        or the next placement, where the shipped strings fill it -- and is
        not the model's."""
        image = images[self.sections[0]]
        out, at = [], 0
        for label in self.labels:
            start = at
            for _ in range(self.lines):
                while at < len(image) and not image[at] & 0x80:
                    at += 1
                if at >= len(image):
                    raise AsmRegionError(f"{self.id}: {label} runs off the image")
                at += 1
            out.append(bytes(image[start:at]))
        model = tuple(out)
        self._check(model)
        return model

    def _check(self, model: tuple[bytes, ...]) -> None:
        if len(model) != len(self.labels):
            raise AsmRegionError(
                f"{self.id} holds {len(self.labels)} entries, got {len(model)}"
            )
        for label, entry in zip(self.labels, model, strict=True):
            strings = _terminated(entry)
            if not strings or not strings[-1][-1] & 0x80:
                raise AsmRegionError(f"{self.id}: {label} does not end terminated")
            if len(strings) != self.lines:
                raise AsmRegionError(
                    f"{self.id}: {label} holds {self.lines} "
                    f"string{'s' if self.lines != 1 else ''}, got {len(strings)}"
                )
            if self.line_width is not None:
                for number, string in enumerate(strings, start=1):
                    if len(string) > self.line_width:
                        raise AsmRegionError(
                            f"{self.id}: {label} line {number} holds "
                            f"{len(string)} tiles, and a line holds "
                            f"{self.line_width} at most"
                        )

    def used(self, model: tuple[bytes, ...]) -> dict[str, int]:
        self._check(model)
        return {self.sections[0]: sum(len(entry) for entry in model)}

    def encode(
        self, model: tuple[bytes, ...], room: int | None = None
    ) -> dict[str, bytes]:
        self.fits(model, room)
        return {self.sections[0]: b"".join(model)}

    def _rows(self, entry: bytes, font: fonts.FontTable) -> list[str]:
        """An entry as ``db`` rows, one a string: the body between quotes
        where it can be, the last tile as ``$XX|$80`` where it always is."""
        chars = font.chars
        rows = []
        for string in _terminated(entry):
            args: list[str] = []
            quoted: list[str] = []
            for tile in string[:-1]:
                char = chars.get(tile)
                if char is not None and char in _QUOTABLE:
                    quoted.append(char)
                    continue
                if quoted:
                    args.append('"' + "".join(quoted) + '"')
                    quoted = []
                args.append(f"${tile:02X}")
            if quoted:
                args.append('"' + "".join(quoted) + '"')
            last = string[-1]
            args.append(f"${last & 0x7F:02X}|$80")
            rows.append("\tdb " + ",".join(args))
        return rows

    def _entry_text(self, label: str, entry: bytes, font: fonts.FontTable) -> str:
        return "\n".join([label + ":", *self._rows(entry, font)]) + "\n"

    def emit(self, model: tuple[bytes, ...], room: int | None, base: RomBase) -> str:
        """The whole fragment as one text -- the header, then every entry --
        which for a region split one entry a file is what its index would
        hold spelled inline, and assembles to the same bytes."""
        self.fits(model, room)
        font = self._font(base)
        parts = [f"; {self.id} -- written by the editor; each label is one entry.\n"]
        if self.header:
            parts.append("\n".join(self.header) + "\n")
        parts += [
            "\n" + self._entry_text(label, entry, font)
            for label, entry in zip(self.labels, model, strict=True)
        ]
        return "".join(parts)

    def emit_files(
        self,
        model: tuple[bytes, ...],
        room: int | None,
        base: RomBase,
        stock: tuple[bytes, ...] | None = None,
    ) -> dict[Path, str]:
        if not self.entry_files:
            return {self.path: self.emit(model, room, base)}
        self.fits(model, room)
        font = self._font(base)
        out: dict[Path, str] = {}
        for at, (label, entry) in enumerate(zip(self.labels, model, strict=True)):
            if stock is not None and at < len(stock) and stock[at] == entry:
                continue
            out[self.entry_files[at]] = self._entry_text(label, entry, font)
        return out

    def parse(self, text: str, base: RomBase) -> tuple[bytes, ...]:
        """Fragment text back to the model.

        The grammar the shipped files are in as well as the emitted ones:
        ``Label:`` alone or with its ``db`` on the same line, ``db`` rows of
        quoted strings and ``$XX``/``$XX|$80`` values, the table directives,
        and the arcade build's version conditional read as every other build
        reads it. Every declared label exactly once, none other.
        """
        font = self._font(base)
        name = self.id
        found: dict[str, bytearray] = {}
        current: str | None = None
        skipping = False
        for number, raw in enumerate(text.split("\n"), start=1):
            line = _comment_stripped(raw)
            where = f"{name}:{number}"
            if not line:
                continue
            if line == _ARCADE_IF:
                skipping = True
                continue
            if line == "else":
                if not skipping:
                    raise AsmRegionError(f"{where}: else outside a conditional")
                skipping = False
                continue
            if line == "endif":
                # Closing the conditional ends the skip whether or not it had
                # an `else`, so a branch with no other half cannot swallow
                # every entry after it.
                skipping = False
                continue
            if skipping:
                continue
            if line == "cleartable" or line.startswith("table "):
                continue
            if line.startswith("if ") or line.startswith("incsrc "):
                raise AsmRegionError(f"{where}: {line!r} is off-grammar")
            label, sep, rest = line.partition(":")
            if sep and " " not in label and "\t" not in label and '"' not in label:
                if label not in self.labels:
                    raise AsmRegionError(f"{where}: unexpected label {label}")
                if label in found:
                    raise AsmRegionError(f"{where}: {label} appears twice")
                found[label] = bytearray()
                current = label
                line = rest.strip()
                if not line:
                    continue
            if current is None:
                raise AsmRegionError(f"{where}: data before any label")
            if not line.startswith("db ") and not line.startswith("db\t"):
                raise AsmRegionError(f"{where}: {line!r} is off-grammar")
            for arg in _split_args(line[3:]):
                found[current] += _string_arg(arg, font, where)
        missing = [label for label in self.labels if label not in found]
        if missing:
            raise AsmRegionError(f"{name}: no entry for {', '.join(missing)}")
        model = tuple(bytes(found[label]) for label in self.labels)
        self._check(model)
        return model


#: The message slot tables' shape, off SMW_DisplayMessage: how many slots
#: name a level, and how many name a message (the level slots, the
#: riding-Yoshi slot and the Yoshi-thanks slot).
SLOT_LEVELS = 0x17
SLOT_POINTERS = 0x19
#: The two pointers past the level slots: the riding-Yoshi one and the
#: Yoshi-thanks one, picked by state rather than by level.
STATE_SLOTS = 2
#: The most level slots the relocated search reaches: its index is 8-bit,
#: and the upload doubles the slot for the pointer table.
SLOT_CAPACITY = 0x7E

#: A message's label, and the file it lives in: ``LevelMsgNN``.
MESSAGE_LABEL = re.compile(r"^LevelMsg([0-9A-F]{2})$")


def message_label(index: int) -> str:
    return f"LevelMsg{index:02X}"


@dataclass(frozen=True)
class Messages:
    """The message tables as one model: which level each slot is for, which
    message each slot shows, and the messages themselves.

    One model rather than three because the pointers *name* messages, as
    labels, and the number a pointer holds on the cartridge is an offset the
    assembler computed from the text before it -- a fact about the text, not
    about the slot. Held together, a message reworded moves every pointer
    past it and nothing has to notice.
    """

    #: One byte per level slot: the translevel, bit 7 for its second message.
    levels: tuple[int, ...]
    #: One message index per slot.
    pointers: tuple[int, ...]
    #: The messages, by index -- :class:`TerminatedStrings`' own model.
    text: tuple[bytes, ...]


@dataclass(frozen=True)
class MessageTables(TerminatedStrings):
    """The message boxes with their slot tables: three sections, one run.

    :attr:`sections` is the levels, the pointers and the text, in ROM order;
    the first two are one file (:attr:`slots_file`) and the text one file a
    message. The model is :class:`Messages`. Everything about the text is
    :class:`TerminatedStrings`', and the two tables in front are what this
    adds: fixed counts, bytes and message indices.
    """

    #: The fragment holding the two slot tables.
    slots_file: Path = Path()
    #: The tables' labels, in the fragment.
    levels_label: str = "MessageLevels"
    pointers_label: str = "MessagePointers"

    def _check_sections(self) -> None:
        if len(self.sections) != 3 or not self.entry_files:
            raise AsmRegionError(f"{self.id}: three sections, one file a message")

    @property
    def files(self) -> tuple[Path, ...]:
        """The shipped set: the slots, then a file a message. :attr:`path`
        -- the index -- joins them when the count may change, since it is
        what names the files then."""
        return (self.slots_file, *self.entry_files)

    def for_base(self, base: RomBase | None = None) -> AsmRegion:
        """On a cartridge whose search follows the tables' labels
        (:attr:`~smw_tools.bases.RomBase.label_bound_scans`) the slots and
        the messages may be added to and taken from; the stock search reads
        ``$17`` slots and the shipped pointers name 22 messages."""
        region = super().for_base(base)
        if base is not None and self.id in base.label_bound_scans:
            region = replace(region, growable=True, capacity=SLOT_CAPACITY)
        return region

    def entry_counts(self) -> dict[str, int]:
        levels, pointers, text = self._roles
        return {levels: SLOT_LEVELS, pointers: SLOT_POINTERS, text: len(self.labels)}

    def _with_counts(self, counts: dict[str, int]) -> MessageTables:
        raise AsmRegionError(f"{self.id}: the slot tables' counts are the scan's")

    def scanned_count(self, model: Messages) -> int:  # type: ignore[override]
        return len(model.levels)

    def owns(self, path: Path) -> bool:
        return (
            path in (self.slots_file, self.path)
            or path.parent == self.entry_files[0].parent
            and path.suffix == ".asm"
            and MESSAGE_LABEL.match(path.stem) is not None
        )

    @property
    def fixed_files(self) -> bool:
        """False: the index is this region's without being one of
        :attr:`files`, and a cartridge whose search follows the tables may
        hold messages the disassembly never shipped."""
        return False

    def read(self, read_text: Callable[[Path], str]) -> str:
        """The slots, then the messages the index names, in its order --
        the index rather than :attr:`entry_files`, because a grown set has
        more of them and the index is what the build splices in."""
        parts = [read_text(self.slots_file)]
        folder = self.path.parent
        for line in read_text(self.path).split("\n"):
            line = _comment_stripped(line)
            if line.startswith("incsrc "):
                parts.append(read_text(folder / line[7:].strip().strip('"')))
        return _joined(parts)

    def _index_text(self, count: int) -> str:
        """The index for ``count`` messages, in the shipped file's shape."""
        folder = self.entry_files[0].parent.relative_to(self.path.parent)
        lines = [
            *self.header,
            "",
            ";--- One file per message. The cleartable/table directives above set the",
            ";--- text encoding these strings assemble against and must stay in force.",
            "",
            *(
                f'incsrc "{(folder / f"{message_label(index)}.asm").as_posix()}"'
                for index in range(count)
            ),
        ]
        return "\n".join(lines) + "\n"

    def _entry_file(self, index: int) -> Path:
        if index < len(self.entry_files):
            return self.entry_files[index]
        return self.entry_files[0].parent / f"{message_label(index)}.asm"

    @property
    def strides(self) -> tuple[int, ...]:
        return (1, 2, 1)

    @property
    def _roles(self) -> tuple[str, str, str]:
        levels, pointers, text = self.sections
        return levels, pointers, text

    # -- the codec -------------------------------------------------------------

    def _text_region(self, count: int | None = None) -> TerminatedStrings:
        """This region as its text alone, for the half the parent codes --
        at ``count`` messages, the shipped count otherwise."""
        levels, pointers, text = self._roles
        count = len(self.labels) if count is None else count
        return TerminatedStrings(
            id=self.id,
            path=self.path,
            namespace=self.namespace,
            owner=self.owner,
            sections=(text,),
            labels=tuple(message_label(index) for index in range(count)),
            lines=self.lines,
            line_width=self.line_width,
            header=self.header,
            entry_files=tuple(self._entry_file(index) for index in range(count)),
            font=self.font,
            excluded_targets=self.excluded_targets,
            feature=self.feature,
        )

    def _starts(self, text: tuple[bytes, ...]) -> dict[int, int]:
        """Each message's offset into the run, by index -- what a pointer
        holds once the assembler has laid the text out."""
        out, at = {}, 0
        for index, entry in enumerate(text):
            out[at] = index
            at += len(entry)
        return out

    def decode(self, images: dict[str, bytes]) -> Messages:
        """The three tables off their images. On a grown cartridge the
        counts come off the images themselves: the level slots are the
        bytes between the two tables, the pointers two bytes a slot plus
        the two state-picked ones, and the messages as many as the pointers
        reach -- since nothing else says where the text ends."""
        levels_role, pointers_role, text_role = self._roles
        levels_image = images[levels_role]
        if not self.grows:
            count = SLOT_LEVELS
        else:
            count = len(levels_image)
            if count > SLOT_CAPACITY:
                raise AsmRegionError(
                    f"{self.id}: {count} level slots is more than the search reaches"
                )
        image = images[pointers_role][: (count + STATE_SLOTS) * 2]
        messages = len(self.labels)
        if self.grows:
            # As many messages as the pointers reach, and every one walked.
            # An entry is at least one byte, so the walk always advances.
            text_image = images[text_role]
            furthest = max(
                (
                    int.from_bytes(image[at : at + 2], "little")
                    for at in range(0, len(image), 2)
                ),
                default=-1,
            )
            messages, at = 0, 0
            while at <= furthest:
                for _ in range(self.lines):
                    while at < len(text_image) and not text_image[at] & 0x80:
                        at += 1
                    at += 1
                messages += 1
        text = self._text_region(messages).decode({text_role: images[text_role]})
        starts = self._starts(text)
        pointers = []
        for at in range(0, len(image), 2):
            offset = int.from_bytes(image[at : at + 2], "little")
            if offset not in starts:
                raise AsmRegionError(
                    f"{self.id}: slot {at // 2} points at {offset:#06x}, which "
                    "is inside a message rather than at one"
                )
            pointers.append(starts[offset])
        model = Messages(
            levels=tuple(levels_image[:count]),
            pointers=tuple(pointers),
            text=text,
        )
        self._check(model)
        return model

    def _check(self, model: Messages) -> None:  # type: ignore[override]
        if not isinstance(model, Messages):
            raise AsmRegionError(f"{self.id}: the model is the three tables")
        held = len(model.levels)
        if self.grows:
            if not 1 <= held <= SLOT_CAPACITY:
                raise AsmRegionError(
                    f"{self.id} holds 1 to {SLOT_CAPACITY} level slots, got {held}"
                )
            if not model.text:
                raise AsmRegionError(f"{self.id}: at least one message")
        else:
            if held != SLOT_LEVELS:
                raise AsmRegionError(
                    f"{self.id}: {SLOT_LEVELS} level slots, got {held}"
                )
            if len(model.text) != len(self.labels):
                raise AsmRegionError(
                    f"{self.id} holds {len(self.labels)} entries, got {len(model.text)}"
                )
        if any(not 0 <= value < 0x100 for value in model.levels):
            raise AsmRegionError(f"{self.id}: a level slot is not a byte")
        if len(model.pointers) != held + STATE_SLOTS:
            raise AsmRegionError(
                f"{self.id}: {held + STATE_SLOTS} message slots, got "
                f"{len(model.pointers)}"
            )
        if any(not 0 <= index < len(model.text) for index in model.pointers):
            raise AsmRegionError(f"{self.id}: a slot names a message that is not one")
        self._text_region(len(model.text))._check(model.text)

    def used(self, model: Messages) -> dict[str, int]:  # type: ignore[override]
        self._check(model)
        levels, pointers, text = self._roles
        return {
            levels: len(model.levels),
            pointers: len(model.pointers) * 2,
            text: sum(len(entry) for entry in model.text),
        }

    def encode(  # type: ignore[override]
        self, model: Messages, room: int | None = None
    ) -> dict[str, bytes]:
        self.fits(model, room)
        levels, pointers, text = self._roles
        offsets = {index: at for at, index in self._starts(model.text).items()}
        return {
            levels: bytes(model.levels),
            pointers: b"".join(
                offsets[index].to_bytes(2, "little") for index in model.pointers
            ),
            text: b"".join(model.text),
        }

    def _slots_text(self, model: Messages) -> str:
        lines = [self.levels_label + ":"]
        lines += _rows(list(model.levels), "db", 8, 1)
        lines += ["", self.pointers_label + ":"]
        names = [message_label(index) for index in model.pointers]
        lines += [
            "\tdw " + ",".join(names[at : at + 4]) for at in range(0, len(names), 4)
        ]
        return "\n".join(lines) + "\n"

    def emit(  # type: ignore[override]
        self, model: Messages, room: int | None, base: RomBase
    ) -> str:
        """The whole region as one text, in ROM order: the slot tables, then
        the messages -- what the two fragments would be spelled inline."""
        self.fits(model, room)
        whole = self._text_region(len(model.text)).emit(model.text, None, base)
        first, _, entries = whole.partition("\n\n")
        return (
            first.replace(
                "each label is one entry", "each label is one table or message"
            )
            + "\n\n"
            + self._slots_text(model)
            + "\n"
            + entries
        )

    def emit_files(  # type: ignore[override]
        self,
        model: Messages,
        room: int | None,
        base: RomBase,
        stock: Messages | None = None,
    ) -> dict[Path, str]:
        self.fits(model, room)
        out: dict[Path, str] = {}
        if stock is None or (model.levels, model.pointers) != (
            stock.levels,
            stock.pointers,
        ):
            out[self.slots_file] = (
                f"; {self.id} -- written by the editor; the slot tables.\n\n"
                + self._slots_text(model)
            )
        stock_text = None if stock is None else stock.text
        count = len(model.text)
        if count != len(self.labels) and (stock is None or count != len(stock.text)):
            # The index names the files: a count the shipped one does not
            # have needs one that does.
            out[self.path] = self._index_text(count)
        out.update(
            self._text_region(count).emit_files(model.text, None, base, stock_text)
        )
        return out

    def parse(self, text: str, base: RomBase) -> Messages:  # type: ignore[override]
        """The slot tables' lines are read here, and every other line is the
        text's -- the two fragments are one region however they are joined."""
        levels: list[int] = []
        pointers: list[int] = []
        rest: list[str] = []
        current: str | None = None
        seen: set[str] = set()
        for number, raw in enumerate(text.split("\n"), start=1):
            line = _comment_stripped(raw)
            where = f"{self.id}:{number}"
            label = line[:-1] if line.endswith(":") else None
            if label in (self.levels_label, self.pointers_label):
                if label in seen:
                    raise AsmRegionError(f"{where}: {label} appears twice")
                seen.add(label)
                current = label
                continue
            if label is not None or line.startswith(("if ", "else", "endif")):
                current = None
            if current is None:
                rest.append(raw)
                continue
            if not line:
                continue
            if current == self.levels_label:
                if not line.startswith("db "):
                    raise AsmRegionError(f"{where}: {line!r} is off-grammar")
                levels += _values(line[3:], self.id, number)
            else:
                if not line.startswith("dw "):
                    raise AsmRegionError(f"{where}: {line!r} is off-grammar")
                for name in line[3:].split(","):
                    name = name.strip()
                    found = MESSAGE_LABEL.match(name)
                    if found is None:
                        raise AsmRegionError(
                            f"{where}: {name!r} is not a message's label"
                        )
                    pointers.append(int(found.group(1), 16))
        missing = [
            label
            for label in (self.levels_label, self.pointers_label)
            if label not in seen
        ]
        if missing:
            raise AsmRegionError(f"{self.id}: no {', '.join(missing)} table")
        # The messages are whichever LevelMsg labels the text carries, and
        # they have to be the first so many, in order: a hole would leave a
        # pointer naming a message the index does not splice in.
        seen_labels = [
            found.group(0)[:-1]
            for line in rest
            if (found := re.match(r"^(LevelMsg[0-9A-F]{2}):", _comment_stripped(line)))
        ]
        expected = [message_label(index) for index in range(len(seen_labels))]
        if seen_labels != expected:
            raise AsmRegionError(
                f"{self.id}: the messages are {', '.join(expected) or 'none'} "
                f"in order, got {', '.join(seen_labels) or 'none'}"
            )
        model = Messages(
            levels=tuple(levels),
            pointers=tuple(pointers),
            text=self._text_region(len(seen_labels)).parse("\n".join(rest), base),
        )
        self._check(model)
        return model
