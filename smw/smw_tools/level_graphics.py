"""Per-level graphics: the rows a level names its eight files in.

Under the ``level-graphics`` feature (``Config/LevelGraphics.asm``) a level
may name the graphics file each of its eight VRAM slots loads -- FG1, FG2,
BG1, FG3, SP1, SP2, SP3, SP4 -- over what its header's two tilesets would
load out of the stock lists. The cartridge holds one row per level number
at the level bank's fixed head, eight bytes each, ``$FF`` where the slot
keeps the tileset's file; the uploader's two hooks lay the loading level's
row over the four files each list gave.

This module carries the row's shape, where a level's container keeps it,
the fragment a build derives from the containers and the arithmetic the
loader applies, so the editor can write the table and say what a level
will load without a build. The layout the config fixes -- the rows'
offset, the block's size -- is restated here and held against the config's
own literals by a test.

**The row lives in the level's container.** A Lunar Magic ``.mwl`` keeps
the level's own files in its eighth slot, "ExGFX and bypasses"
(:data:`BYPASS_WORDS`), and that is where the editor saves a row: the
container the level's Layer 1 stream comes out of, so a level sharing a
container shares the row, as it shares everything else in the file. The
fragment the build reads the rows through is derived from the containers
at build time (:func:`fragment_from_containers`); the checkout's copy
names no level, and the containers it ships hold no row, so the two agree.
"""

from __future__ import annotations

import re
from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from pathlib import Path

from . import graphics
from .asm_defines import block
from .bases import RomBase

#: The feature under which the rows exist, by id -- the same string
#: :data:`smw_tools.features.LEVEL_GRAPHICS` declares, spelled here so this
#: module's imports stay its own.
FEATURE = "level-graphics"

#: The asar define the config guards.
DEFINE = "Define_SMW_LevelGraphics"

#: The slots, in row order: the four layer slots the FG/BG list fills, then
#: the four sprite slots the sprite list fills, and then the animated tiles
#: -- which are not a VRAM slot at all (:data:`UPLOAD_SLOTS` is how many of
#: these are), but a file expanded into WRAM once per level that asks for
#: one, so a row carries it beside the eight and a container keeps it in the
#: same place: the word Lunar Magic calls ``AN2``.
SLOTS: tuple[str, ...] = (
    "FG1", "FG2", "BG1", "FG3", "SP1", "SP2", "SP3", "SP4", "AN2",
)  # fmt: skip
LAYER_SLOTS = 4
SPRITE_SLOTS = 4

#: How many of the slots are files the uploader puts in VRAM -- the eight the
#: two tileset lists answer for, which is what a row is laid over
#: (:func:`effective`). The animated tiles are the row's ninth and last.
UPLOAD_SLOTS = LAYER_SLOTS + SPRITE_SLOTS

#: What a row is, and what the cartridge keeps it in. A row is nine files --
#: :data:`SLOTS` -- and ``$FF`` is never one of them: in a slot it keeps the
#: tileset's file, and in the animated tiles it keeps the game's own
#: ``GFX33``. The cartridge holds them as **two tables**, one per level
#: number: the eight slots in ``$200`` rows of :data:`TABLE_ROW_BYTES` at the
#: block's head, and the animated file in ``$200`` bytes behind them. The
#: split is the stub's arithmetic -- a row of eight is a shift where a row of
#: nine is a multiply, and the animated byte is read by the level number
#: itself.
ROW_BYTES = 9
TABLE_ROW_BYTES = UPLOAD_SLOTS
LEVELS = 0x200
INHERIT = 0xFF
ROWS_BYTES = LEVELS * TABLE_ROW_BYTES
ANIMATED_BYTES = LEVELS

#: A row that keeps every slot the tileset's -- what no row at all means, and
#: what a container with nothing to say reads as.
INHERIT_ROW = bytes([INHERIT] * ROW_BYTES)


def is_inherit(row: bytes) -> bool:
    """Whether ``row`` names no file at all.

    The two spellings of a level with no row of its own -- no bytes, or
    :data:`INHERIT` in every slot -- are one answer: every slot keeps its
    tileset's file. This is the bytes' form of
    :attr:`LevelGraphics.is_empty`, which asks it of a decoded record.
    """
    return not row or bytes(row) == INHERIT_ROW


#: The rows' offset from the level bank's base -- the packed head, which is
#: the run's start past the RATS tag and the level number stash the bank lays
#: down in front of every occupant -- and the animated files' behind them.
#: Exactly as ``Config/LevelBank.asm`` and ``Config/LevelGraphics.asm`` state
#: them, which a test holds the files to.
ROWS_OFFSET = 0x8011
ANIMATED_OFFSET = ROWS_OFFSET + ROWS_BYTES

#: The block's whole size: the two tables, then the read stubs. From
#: ``Config/PackedRuns.asm``, where every packed run's blocks are declared
#: and the placement asserts them (:mod:`smw_tools.asm_defines`), so this
#: module reads the figure the build checks rather than composing a second
#: one. One size on every cartridge -- the level number stash the rows are
#: indexed by is the bank's, in front of every occupant.
BLOCK_BYTES = block("LevelGraphics")

#: What the block holds beyond its two tables: the read stubs with their
#: shared tail and the animated tiles' stub. A difference rather than a
#: figure, since the block is the declaration and the tables are fixed.
STUB_BYTES = BLOCK_BYTES - ROWS_BYTES - ANIMATED_BYTES

#: The role the rows are declared under, and the fragment the build derives
#: from the containers, relative to the game folder.
ROLE = "level_graphics_rows"
FRAGMENT = Path("graphics/levels/level-graphics.asm")

#: Lunar Magic's record of a level's files: a container's eighth slot, sixteen
#: little-endian words with no region header of their own, in this order. The
#: low twelve bits of a word are the file number and the high nibble the
#: tool's bypass flags; :data:`BYPASS_NONE` is a slot with no file named.
#: Eight of the sixteen are the slots a row has, and the other eight -- the
#: animation, Layer 3 and status-bar files -- are the tool's and are left
#: exactly as found.
BYPASS_WORDS: tuple[str, ...] = (
    "AN2", "LT3", "BG3", "BG2", "FG3", "BG1", "FG2", "FG1",
    "SP4", "SP3", "SP2", "SP1", "LG4", "LG3", "LG2", "LG1",
)  # fmt: skip
BYPASS_BYTES = 2 * len(BYPASS_WORDS)
BYPASS_NONE = 0xFFFF
BYPASS_FILE_MASK = 0x0FFF

#: The file number Lunar Magic writes for a slot holding no file -- the four
#: Layer 3 words on every shipped container, and SP1 on all of them, since
#: every stock sprite tileset loads ``GFX00`` there. Never a file a level may
#: name: reading it is the tileset's, and writing it is refused.
BYPASS_NO_FILE = 0x7F

#: Where the slot's entry sits in a container's table -- its eight bytes, the
#: offset long then the size long, the eighth entry of eight.
BYPASS_SLOT = 7
_BYPASS_ENTRY = 0x40 + BYPASS_SLOT * 8

#: Which word of the sixteen each slot of a row is.
_ROW_WORDS = tuple(BYPASS_WORDS.index(slot) for slot in SLOTS)

_LINE = re.compile(
    r"^\s*%SMW_LevelGraphics\(\s*\$([0-9A-Fa-f]{1,3})\s*,"
    + r"\s*\$([0-9A-Fa-f]{1,2})\s*," * (ROW_BYTES - 1)
    + r"\s*\$([0-9A-Fa-f]{1,2})\s*\)\s*(?:;.*)?$"
)


class LevelGraphicsError(ValueError):
    """A row or a fragment the feature cannot express."""


@dataclass(frozen=True)
class LevelGraphics:
    """One level's row: the file each slot loads, or ``None`` to keep the
    file the level's tileset would load there -- and, for :attr:`an2`, to
    keep the game's own animated tiles."""

    fg1: int | None = None
    fg2: int | None = None
    bg1: int | None = None
    fg3: int | None = None
    sp1: int | None = None
    sp2: int | None = None
    sp3: int | None = None
    sp4: int | None = None
    an2: int | None = None

    @classmethod
    def from_files(cls, files: Iterable[int | None]) -> LevelGraphics:
        """A row out of nine files in slot order."""
        held = tuple(files)
        if len(held) != ROW_BYTES:
            raise LevelGraphicsError(
                f"a level's row is {ROW_BYTES} files, not {len(held)}"
            )
        return cls(*held)

    @property
    def files(self) -> tuple[int | None, ...]:
        """The nine, in slot order."""
        return (
            self.fg1,
            self.fg2,
            self.bg1,
            self.fg3,
            self.sp1,
            self.sp2,
            self.sp3,
            self.sp4,
            self.an2,
        )

    @property
    def slot_files(self) -> tuple[int | None, ...]:
        """The eight the uploader puts in VRAM, without the animated tiles."""
        return self.files[:UPLOAD_SLOTS]

    @property
    def is_empty(self) -> bool:
        """Whether every slot keeps its tileset's file."""
        return all(one is None for one in self.files)

    def __post_init__(self) -> None:
        for slot, one in zip(SLOTS, self.files, strict=True):
            if one is None:
                continue
            if not 0 <= one < INHERIT:
                raise LevelGraphicsError(
                    f"{slot} names file {one:#04x}; a file is $00-$FE, "
                    f"and ${INHERIT:02X} keeps the tileset's"
                )


def encode(record: LevelGraphics) -> bytes:
    """The row's nine bytes: the eight the rows table holds, then the one the
    animated files table holds."""
    return bytes(INHERIT if one is None else one for one in record.files)


def decode(row: bytes) -> LevelGraphics:
    """A row read back off a cartridge."""
    if len(row) != ROW_BYTES:
        raise LevelGraphicsError(f"a row is {ROW_BYTES} bytes, not {len(row)}")
    return LevelGraphics.from_files(None if one == INHERIT else one for one in row)


def _check_level(level: int) -> None:
    if not 0 <= level < LEVELS:
        raise LevelGraphicsError(f"level {level:#05x} is past ${LEVELS - 1:03X}")


def line(level: int, record: LevelGraphics) -> str:
    """One fragment line, without its newline: the level, then the nine bytes
    in slot order -- the layer four, the sprite four and the animated tiles
    apart."""
    _check_level(level)
    held = encode(record)
    layers = ",".join(f"${one:02X}" for one in held[:LAYER_SLOTS])
    sprites = ",".join(f"${one:02X}" for one in held[LAYER_SLOTS:UPLOAD_SLOTS])
    animated = f"${held[UPLOAD_SLOTS]:02X}"
    return f"%SMW_LevelGraphics(${level:03X}, {layers}, {sprites}, {animated})"


def fragment(rows: Mapping[int, LevelGraphics]) -> str:
    """The fragment's whole text for ``rows``: one line per level named,
    levels ascending, each line newline-terminated; nothing for none."""
    return "".join(f"{line(level, rows[level])}\n" for level in sorted(rows))


def parse(text: str) -> dict[int, LevelGraphics]:
    """The rows a fragment names, by level, refusing a line that is not
    the grammar, a level past the table or one named twice."""
    out: dict[int, LevelGraphics] = {}
    for number, raw in enumerate(text.splitlines(), start=1):
        if not raw.strip() or raw.lstrip().startswith(";"):
            continue
        match = _LINE.match(raw)
        if match is None:
            raise LevelGraphicsError(
                f"{FRAGMENT.as_posix()}:{number}: not a %SMW_LevelGraphics line: "
                f"{raw.strip()!r}"
            )
        level = int(match.group(1), 16)
        _check_level(level)
        if level in out:
            raise LevelGraphicsError(
                f"{FRAGMENT.as_posix()}:{number}: level ${level:03X} is named twice"
            )
        out[level] = decode(bytes(int(one, 16) for one in match.groups()[1:]))
    return out


# -- the row in a container ------------------------------------------------------


def bypass_file(word: int) -> int | None:
    """The file one of the sixteen words names, or ``None`` for the tileset's:
    :data:`BYPASS_NONE`, the tool's no-file number, and a number past
    ``$FF`` -- a Lunar Magic ExGFX file with no counterpart here -- all read
    as the tileset's. The flags nibble is ignored on the way in."""
    file = word & BYPASS_FILE_MASK
    if word == BYPASS_NONE or file == BYPASS_NO_FILE or file > 0xFE:
        return None
    return file


def bypass_word(file: int | None, held: int) -> int:
    """The word to write for ``file`` over ``held``, the word the container
    holds there now. A word that already reads as ``file`` is kept exactly --
    the tool's flags, and its no-file spelling, survive a rewrite -- so a
    container rewritten with the row it holds is byte-identical; otherwise
    the tileset's is :data:`BYPASS_NONE` and a file is its number, flags
    clear."""
    if file == BYPASS_NO_FILE:
        raise LevelGraphicsError(
            f"{graphics.name_for(BYPASS_NO_FILE)} is the number Lunar Magic "
            "keeps for a slot with no file, and a level cannot name it"
        )
    if bypass_file(held) == file:
        return held
    return BYPASS_NONE if file is None else file


def row_from_bypass(data: bytes) -> bytes:
    """A row's eight bytes out of the slot's :data:`BYPASS_BYTES`, in slot
    order -- :data:`INHERIT` where the word names nothing a row can hold."""
    if len(data) != BYPASS_BYTES:
        raise LevelGraphicsError(
            f"a container's ExGFX slot is {BYPASS_BYTES} bytes, not {len(data)}"
        )
    words = [
        int.from_bytes(data[at : at + 2], "little") for at in range(0, len(data), 2)
    ]
    return bytes(
        INHERIT if (file := bypass_file(words[index])) is None else file
        for index in _ROW_WORDS
    )


def bypass_with_row(data: bytes, row: bytes) -> bytes:
    """The slot's :data:`BYPASS_BYTES` with ``row`` written into its eight
    words, the other eight exactly as they were (:func:`bypass_word`)."""
    if len(data) != BYPASS_BYTES:
        raise LevelGraphicsError(
            f"a container's ExGFX slot is {BYPASS_BYTES} bytes, not {len(data)}"
        )
    files = decode(row).files
    out = bytearray(data)
    for file, index in zip(files, _ROW_WORDS, strict=True):
        at = index * 2
        held = int.from_bytes(out[at : at + 2], "little")
        out[at : at + 2] = bypass_word(file, held).to_bytes(2, "little")
    return bytes(out)


def container_row(container: Path) -> bytes:
    """The row a ``.mwl`` holds, read the way the insertion macro reads a
    stream -- the slot's entry in the container's table, then the slot --
    and all :data:`INHERIT` for a container with no such slot."""
    with container.open("rb") as handle:
        handle.seek(_BYPASS_ENTRY)
        entry = handle.read(8)
        if len(entry) != 8:
            return INHERIT_ROW
        offset = int.from_bytes(entry[:4], "little")
        size = int.from_bytes(entry[4:], "little")
        if size != BYPASS_BYTES:
            return INHERIT_ROW
        handle.seek(offset)
        data = handle.read(size)
    if len(data) != BYPASS_BYTES:
        return INHERIT_ROW
    return row_from_bypass(data)


def rows_from_containers(files: Mapping[int, Path]) -> dict[int, LevelGraphics]:
    """The rows the containers hold, by level: ``files`` is each level's
    Layer 1 container, and a level whose row keeps every slot is left out.
    Each file is read once however many levels share it."""
    held: dict[Path, bytes] = {}
    out: dict[int, LevelGraphics] = {}
    for level, path in sorted(files.items()):
        _check_level(level)
        if path not in held:
            held[path] = container_row(path)
        record = decode(held[path])
        if not record.is_empty:
            out[level] = record
    return out


_DERIVED = (
    "; Derived by the build from the level containers -- the row each\n"
    "; level's .mwl keeps in its ExGFX slot. Not kept anywhere: it is written\n"
    "; into the merged tree on every build, and editing it changes nothing.\n"
)


def fragment_from_containers(
    game_dir: Path, romid: str, files: Mapping[int, Path] | None = None
) -> str | None:
    """The fragment's whole text for the rows the containers under
    ``game_dir`` hold, or ``None`` when no level has one -- which is the
    checkout, whose shipped copy names no level.

    Every level number is resolved to its Layer 1 container through
    :mod:`.levels`, for ``romid``'s release; ``files`` is that resolution
    given rather than read, for a caller whose pointer tables or containers
    are not all in the tree -- the editor's build, which places the levels a
    project adds.
    """
    if files is None:
        from .levels import containers_for

        files = {
            level: where.layer1
            for level, where in containers_for(game_dir, romid).items()
        }
    rows = rows_from_containers(files)
    if not rows:
        return None
    return _DERIVED + fragment(rows)


def effective(
    record: LevelGraphics | None, *, fgbg_row: bytes, sprite_row: bytes
) -> tuple[int, ...]:
    """The eight files a level loads, in slot order: the tileset's rows --
    ``fgbg_row`` the four bytes of ``FGAndBGGFXList`` its FG/BG tileset
    indexes, ``sprite_row`` the four of ``SpriteGFXList`` its sprite
    tileset indexes -- with ``record``'s named slots laid over them, which
    is exactly what the two stubs do. ``None`` is a level with no row.

    **The two rows are named rather than ordered.** They are both four bytes
    of the same type, so a call that swapped them would answer eight files
    that look like an answer and are not; a keyword is what makes the swap a
    ``TypeError`` instead."""
    if len(fgbg_row) != LAYER_SLOTS or len(sprite_row) != SPRITE_SLOTS:
        raise LevelGraphicsError("a tileset's row is four bytes for each list")
    stock = (*fgbg_row, *sprite_row)
    if record is None:
        return stock
    return tuple(
        one if own is None else own
        for own, one in zip(record.slot_files, stock, strict=True)
    )


def is_enabled(base: RomBase) -> bool:
    """Whether ``base`` carries the rows -- see :data:`FEATURE`."""
    return FEATURE in base.features


def rows_address(base: RomBase) -> int:
    """Where the rows are on ``base``: the level bank's head, one past the
    base's reservation bank."""
    from .levels import level_bank

    return (level_bank(base) << 16) | ROWS_OFFSET
