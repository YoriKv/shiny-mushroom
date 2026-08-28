"""The graphics files: which exist, what they decompress to, and the raw form.

52 files per asset set, `GFX00` through `GFX33`, stored in the cartridge and on
disk **still compressed** -- a plain `incbin` of `.lz1` or `.lz2` puts them back,
and nothing is decompressed during a build. That is what makes byte-exactness
possible at all, because LZ is not canonical and a re-encode is a different
stream ([`compression`](compression.py)).

This module is the **file model and the tile codecs**: which files exist, which
version reads which set, what each must decompress to, where a baseline lives,
and how the decompressed bytes of each become 8x8 tiles of colour indices and
back. Opening and closing one is [`packed`](packed.py)'s job, which registers
these alongside the RLE-compressed tables; where an editor *keeps* a raw form is
[`shiny_mushroom.project`](../../editor/shiny_mushroom/project.py)'s.

**No file records its own format.** Whether it is 3bpp, 2bpp, 4bpp or Mode 7
packed is decided by the slot path that loads it, so :func:`tile_format` is the
table of what each loader expects, read off `SMW/Banks/Bank00.asm`
([`docs/smw/graphics-loading.md`](../../docs/smw/graphics-loading.md)).

**Three sets, not five.** `U`, `E0` and `SS` share one; `J` and `E1` have their
own. The split is the LZ member rather than the pixels -- decompressed, 43 of
the 52 files are identical across all three sets.
"""

from __future__ import annotations

import enum
from collections.abc import Callable, Sequence
from pathlib import Path

from . import compression
from .bases import base as default_base
from .compression import Family
from .extract import GFX_SETS

#: `GFX00` through `GFX33`.
FILE_NUMBERS = range(0x34)

#: ROM version -> the asset set directory its graphics come from. Named beside
#: the extraction destinations, so the set a file is written to and the set it
#: is read from cannot become two different answers.
SETS: dict[str, str] = GFX_SETS

#: Asset set -> the family its files are stored in. Derived rather than
#: restated, so it cannot drift from `LZ1_VERSIONS`.
SET_FAMILIES: dict[str, Family] = {
    directory: compression.family_for(version) for version, directory in SETS.items()
}

#: Files whose decompressed size is not the usual `$C00`. See
#: [`docs/smw/graphics-loading.md`](../../docs/smw/graphics-loading.md).
#: The two files the game decompresses once, during the Nintendo Presents
#: logo, into WRAM rather than into a VRAM slot: the player's graphics, which
#: `MarioGFXDMA` sends a few tiles of into SP1 every frame, and the animated
#: tiles, which `ROUTINE_SMW_LevelTileAnimations` DMAs three four-tile blocks
#: of every frame. Neither is a shape a slot can load, and both are larger
#: than the decompression buffer, so a caller asking the decompressor for one
#: reads it out of the WRAM staging area instead
#: ([graphics-loading.md](../../docs/smw/graphics-loading.md)).
PLAYER_FILE = 0x32
ANIMATED_TILES_FILE = 0x33

_ODD_SIZES: dict[int, int] = {
    **dict.fromkeys((0x28, 0x29, 0x2A, 0x2B), 0x800),  # 2bpp, Layer 3
    0x2F: 0x400,  # 2bpp, credits letters
    0x30: 0x600,
    0x31: 0x600,
    PLAYER_FILE: 0x5D00,  # the player, 4bpp already
    ANIMATED_TILES_FILE: 0x2400,  # the animated tiles
}

#: The usual size: 128 tiles of SNES 3bpp planar.
DEFAULT_SIZE = 0xC00


class GraphicsError(ValueError):
    """A graphics file that is not what it claims to be."""


def name_for(number: int) -> str:
    """`GFX1E` for `0x1E`. The cartridge's own naming, uppercase hex.

    Every number a file can wear: the game's own `$00`-`$33` and the
    `$34`-`$FE` a project adds. This is the one place the spelling lives, so
    anything naming a file that may not be the game's asks here --
    :func:`file_name` is the same spelling for a caller that means one of the
    game's and wants the number checked.
    """
    return f"GFX{number:02X}"


def file_name(number: int) -> str:
    """`GFX1E` for `0x1E`, refusing a number the game does not ship."""
    check_number(number)
    return name_for(number)


def check_number(number: int) -> None:
    if number not in FILE_NUMBERS:
        raise GraphicsError(
            f"no graphics file {number:#04x}; a set holds "
            f"{name_for(FILE_NUMBERS[0])}-{name_for(FILE_NUMBERS[-1])}"
        )


def set_for(version: str) -> str:
    """The asset set directory a ROM version's graphics come from."""
    try:
        return SETS[version]
    except KeyError:
        raise GraphicsError(
            f"unknown version {version!r}; expected one of {sorted(SETS)}"
        ) from None


def family_for_set(directory: str) -> Family:
    try:
        return SET_FAMILIES[directory]
    except KeyError:
        sets = sorted(SET_FAMILIES)
        raise GraphicsError(
            f"unknown graphics set {directory!r}; expected one of {sets}"
        ) from None


def decompressed_size(number: int) -> int:
    """What ``number`` must decompress to.

    Worth checking rather than trusting: a raw form of the wrong length is
    accepted by the compressor, assembles cleanly, and shows up only as
    corrupted VRAM several steps later.
    """
    check_number(number)
    return _ODD_SIZES.get(number, DEFAULT_SIZE)


def baseline_relative(directory: str, number: int) -> Path:
    """A shipped file's path within an assets root: ``GFX/SMW_U/GFX00.lz2``.

    The suffix names the family, which is why the same file number is
    `GFX00.lz2` under `SMW_U` and `GFX00.lz1` under `SMW_J`.
    """
    family = family_for_set(directory)
    return Path("GFX") / directory / f"{file_name(number)}.{family.name.lower()}"


def baseline_path(directory: str, number: int, assets: Path | None = None) -> Path:
    """Where the shipped compressed file for ``number`` lives on disk."""
    root = default_base().assets_root if assets is None else assets
    return root / baseline_relative(directory, number)


# -- the tile formats ---------------------------------------------------------


class TileFormat(enum.Enum):
    """How one 8x8 tile's colour indices are laid out in a decompressed file.

    The three planar layouts are the SNES's own: each row of eight pixels is
    one byte per bitplane, bit 7 the leftmost pixel, planes 0 and 1 interleaved
    row by row over the first sixteen bytes, and what follows depends on the
    depth. The fourth is the one file the PPU never reads as planar.
    """

    #: 16 bytes a tile, `(bp0, bp1)` per row. `GFX28`-`GFX2B` and `GFX2F`, the
    #: Layer 3 files, uploaded unconverted.
    PLANAR_2BPP = ("planar", 2)

    #: 24 bytes a tile, the 2bpp sixteen then one `bp2` byte per row. What
    #: `UploadGFXFile` expands to 4bpp on the way into VRAM, so the ordinary
    #: file: `GFX00`-`GFX26`, `GFX2C`-`GFX2E`, `GFX30`, `GFX31`, `GFX33`.
    PLANAR_3BPP = ("planar", 3)

    #: 32 bytes a tile, `(bp0, bp1)` rows then `(bp2, bp3)` rows -- VRAM's own
    #: layout, which is why `GFX32`, the player, needs no conversion.
    PLANAR_4BPP = ("planar", 4)

    #: 24 bytes a tile, 3 bits a pixel packed linearly and most significant
    #: bit first: 8 pixels to 3 bytes, so one row is 3 bytes and 64 pixels are
    #: 24. `GFX27` only. `ConvertGFX27IntoNormallFormat` (`Bank00.asm`) pulls
    #: three bits at a time off the front of each byte with `ROL` and writes
    #: each value as one Mode 7 character byte, so the pixels follow the
    #: stream in order, row-major.
    MODE7_3BPP = ("mode7", 3)

    @property
    def bpp(self) -> int:
        """Bits per pixel."""
        return self.value[1]

    @property
    def tile_bytes(self) -> int:
        """Bytes one tile takes: 64 pixels at ``bpp`` bits, in every layout."""
        return 8 * self.bpp

    @property
    def colours(self) -> int:
        """How many indices a pixel can hold, `2 ** bpp`, index 0 being the
        transparent one."""
        return 1 << self.bpp

    @property
    def planar(self) -> bool:
        return self.value[0] == "planar"


#: Pixels a tile is on a side, and in a tile.
TILE_SIDE = 8
TILE_PIXELS = TILE_SIDE * TILE_SIDE

#: Files whose format is not the usual 3bpp planar. Everything else is.
_ODD_FORMATS: dict[int, TileFormat] = {
    0x27: TileFormat.MODE7_3BPP,
    **dict.fromkeys((0x28, 0x29, 0x2A, 0x2B, 0x2F), TileFormat.PLANAR_2BPP),
    0x32: TileFormat.PLANAR_4BPP,
}


def tile_format(number: int) -> TileFormat:
    """The layout the loader that reads ``number`` expects."""
    check_number(number)
    return _ODD_FORMATS.get(number, TileFormat.PLANAR_3BPP)


def tile_count(number: int) -> int:
    """How many tiles ``number`` holds: its size over its format's tile size,
    which divides exactly for every file there is."""
    size, per_tile = decompressed_size(number), tile_format(number).tile_bytes
    count, rest = divmod(size, per_tile)
    if rest:
        raise GraphicsError(
            f"{file_name(number)}: {size:#x} bytes is not whole tiles of {per_tile}"
        )
    return count


def decode(number: int, raw: bytes) -> list[bytes]:
    """The tiles of a decompressed file: one 64-byte entry per tile, row-major
    colour indices. Refuses a ``raw`` that is not the file's length."""
    expected = decompressed_size(number)
    if len(raw) != expected:
        raise GraphicsError(
            f"{file_name(number)} holds {expected:#x} bytes, got {len(raw):#x}"
        )
    return decode_tiles(tile_format(number), raw)


def encode(number: int, tiles: Sequence[bytes]) -> bytes:
    """The decompressed file those tiles make -- :func:`decode`'s inverse.
    Refuses the wrong number of tiles, a tile that is not 64 pixels, and an
    index the format cannot hold."""
    expected = tile_count(number)
    if len(tiles) != expected:
        raise GraphicsError(
            f"{file_name(number)} holds {expected} tiles, got {len(tiles)}"
        )
    return encode_tiles(tile_format(number), tiles)


def decode_tiles(fmt: TileFormat, raw: bytes) -> list[bytes]:
    """Every tile in ``raw``, which must be whole tiles of ``fmt``."""
    per_tile = fmt.tile_bytes
    if len(raw) % per_tile:
        raise GraphicsError(
            f"{len(raw):#x} bytes is not whole {fmt.name} tiles of {per_tile}"
        )
    rows = _PLANAR_ROWS[fmt.bpp] if fmt.planar else _mode7_rows
    return [rows(raw[at : at + per_tile]) for at in range(0, len(raw), per_tile)]


def encode_tiles(fmt: TileFormat, tiles: Sequence[bytes]) -> bytes:
    """``tiles`` packed as ``fmt``: the exact inverse of :func:`decode_tiles`."""
    limit = fmt.colours
    pack = _PLANAR_PACK[fmt.bpp] if fmt.planar else _mode7_pack
    out = bytearray()
    for index, tile in enumerate(tiles):
        if len(tile) != TILE_PIXELS:
            raise GraphicsError(
                f"tile {index} has {len(tile)} pixels, not {TILE_PIXELS}"
            )
        if max(tile) >= limit:
            raise GraphicsError(
                f"tile {index} uses colour {max(tile)}; {fmt.name} holds "
                f"{limit} (0-{limit - 1})"
            )
        out += pack(tile)
    return bytes(out)


# -- the planar codec ---------------------------------------------------------
#
# A row is one byte per plane, so decoding is a lookup per plane byte -- the
# eight pixels that byte contributes, with only bit `p` set -- OR'd together as
# 64-bit integers. Encoding gathers bit `p` of each of the eight pixel bytes
# back into one byte: mask the plane's bit out of every byte, then one multiply
# lines those eight bits up in the top byte of the product. Both are a handful
# of integer operations a row, which is what keeps a whole asset set's worth of
# tiles well inside a second.

#: `_SPREAD[p][b]` is the eight pixel bytes plane byte ``b`` contributes at
#: plane ``p``, as one big-endian 64-bit integer -- pixel 0 in the top byte.
_SPREAD: list[list[int]] = [
    [
        int.from_bytes(
            bytes(((b >> (7 - x)) & 1) << p for x in range(TILE_SIDE)), "big"
        )
        for b in range(256)
    ]
    for p in range(4)
]

#: Bit 0 of each of the eight pixel bytes.
_LOW_BITS = 0x0101010101010101
#: Multiplying the masked bits by this puts pixel `x`'s bit at bit `63 - x` of
#: the product -- bit 0 of the top byte times `2**56`, of the next byte times
#: `2**49`, and so on, none of the partial products overlapping.
_GATHER = 0x0102040810204080

#: Where each plane's byte for row ``y`` sits in a tile, per depth.
_PLANE_AT: dict[int, tuple[tuple[int, ...], ...]] = {
    2: tuple((2 * y, 2 * y + 1) for y in range(TILE_SIDE)),
    3: tuple((2 * y, 2 * y + 1, 16 + y) for y in range(TILE_SIDE)),
    4: tuple((2 * y, 2 * y + 1, 16 + 2 * y, 17 + 2 * y) for y in range(TILE_SIDE)),
}


def _planar_rows(bpp: int) -> Callable[[bytes], bytes]:
    """The decoder for one depth."""
    offsets = _PLANE_AT[bpp]
    spread = _SPREAD[:bpp]

    def rows(tile: bytes) -> bytes:
        out = bytearray()
        for at in offsets:
            row = 0
            for p, offset in enumerate(at):
                row |= spread[p][tile[offset]]
            out += row.to_bytes(8, "big")
        return bytes(out)

    return rows


def _planar_pack(bpp: int) -> Callable[[bytes], bytes]:
    """The encoder for one depth."""
    offsets = _PLANE_AT[bpp]
    size = 8 * bpp

    def pack(tile: bytes) -> bytes:
        out = bytearray(size)
        for y, at in enumerate(offsets):
            row = int.from_bytes(tile[y * 8 : y * 8 + 8], "big")
            for p, offset in enumerate(at):
                out[offset] = (((row >> p) & _LOW_BITS) * _GATHER >> 56) & 0xFF
        return bytes(out)

    return pack


_PLANAR_ROWS = {bpp: _planar_rows(bpp) for bpp in _PLANE_AT}
_PLANAR_PACK = {bpp: _planar_pack(bpp) for bpp in _PLANE_AT}


# -- what the uploader puts in VRAM -------------------------------------------
#
# `UploadGFXFile` (`SMW/Banks/Bank00.asm`) writes a file straight to the VRAM
# port, expanding 3bpp to 4bpp as it goes: bitplanes 0 and 1 pass through, and
# bitplane 3 is `(bp0 | bp1 | bp2) & mask` -- so with the mask clear the file
# occupies colours 1-7 of its palette, and with it set every non-transparent
# pixel gains bit 3 and the tile moves into colours 9-15. A file already 4bpp
# is copied whole.
#
# Which is what makes a file's VRAM form worth having here: it is the form the
# editor can compare a capture against and write over one, so which file a slot
# loads can be previewed without asking the game to load the level again.

#: How much VRAM one graphics slot holds: 128 tiles of 4bpp, which is what
#: both the 3bpp expansion and the 4bpp straight copy produce.
SLOT_BYTES = 0x1000
SLOT_TILES = 128

#: The one file the full mask is unconditional for, and the pair that takes it
#: over four tiles. `UploadGFXFile` decides from the file number in `Y`: `$1E`
#: always, `$08` when the tileset is `$11` or over, and for `$01` and `$17` a
#: window rather than the whole file.
_ALWAYS_MASKED = 0x1E
_MASKED_OVER_TILESET = (0x08, 0x11)
_WINDOW_MASKED = (0x01, 0x17)

#: The four tiles the windowed mask covers. The uploader's counter runs `$7F`
#: down to `$00` and tests `>= $7E` and `$6E`-`$6F`, so tile *n* is counter
#: `$7F - n` and the windows are the first two tiles of the first and of the
#: seventeenth row of the sheet.
_MASKED_TILES = frozenset({0x00, 0x01, 0x10, 0x11})


def masked_tiles(number: int, tileset: int = 0) -> frozenset[int] | None:
    """Which of a file's tiles the uploader moves into colours 9-15 -- every
    tile (``None``), four of them, or none (an empty set).

    ``tileset`` is the value `UploadGFXFile` compares against `$11`, which
    only file `$08` is judged by.
    """
    if number == _ALWAYS_MASKED:
        return None
    one, over = _MASKED_OVER_TILESET
    if number == one and tileset >= over:
        return None
    return _MASKED_TILES if number in _WINDOW_MASKED else frozenset()


#: What a slot's file decompresses to, by format. **The length is the format**
#: -- which is the rule the cartridge itself keeps for a file the project
#: added, and true of every stock file that goes into a slot.
_SLOT_SIZES = {
    SLOT_BYTES * 3 // 4: TileFormat.PLANAR_3BPP,
    SLOT_BYTES: TileFormat.PLANAR_4BPP,
}


def slot_format(number: int, raw: bytes) -> TileFormat:
    """The layout ``raw`` is in as a slot's file, or :class:`GraphicsError`
    for a file that never goes into one.

    By length, not by number: an added file's format is its raw form's length
    and nothing else says it (:func:`smw_tools.packed.format_for_size`), and
    every stock file that fills a slot is the length its own format implies.
    What is refused is everything uploaded some other way -- the 2bpp Layer 3
    files, `GFX27`, which the PPU reads as Mode 7 character data, and `GFX32`,
    the player, which has a place of its own and is not 128 tiles.
    """
    odd = _ODD_FORMATS.get(number)
    if odd is not None and odd is not TileFormat.PLANAR_4BPP:
        raise GraphicsError(
            f"{file_name(number)} is {odd.name} and does not go into a "
            f"graphics slot as tiles"
        )
    fmt = _SLOT_SIZES.get(len(raw))
    if fmt is None:
        raise GraphicsError(
            f"{name_for(number)}: {len(raw):#x} bytes is not a graphics "
            f"slot's file, which is {SLOT_BYTES * 3 // 4:#x} or {SLOT_BYTES:#x}"
        )
    return fmt


def fits_a_slot(number: int) -> bool:
    """Whether a level's graphics slot may name ``number``.

    :func:`slot_format`'s two refusals asked of a *number* rather than of
    bytes in hand, which is what a picker of files needs before any of them is
    read: the file has to be a layout the uploader writes into a slot as tiles
    -- not the 2bpp Layer 3 files, not `GFX27`'s Mode 7 characters -- and it
    has to decompress to exactly a slot's worth, which `GFX32` (the player,
    with an upload of its own) and `GFX33` (the animated tiles, DMA'd per
    frame) do not. The short credits files go with them: half a slot leaves
    the other half whatever the last level put there, and no tileset a level
    can select names one.
    """
    odd = _ODD_FORMATS.get(number)
    if odd is not None and odd is not TileFormat.PLANAR_4BPP:
        return False
    return _SLOT_SIZES.get(decompressed_size(number)) is tile_format(number)


def vram_bytes(number: int, raw: bytes, tileset: int = 0) -> bytes:
    """``raw`` as `UploadGFXFile` writes it into a slot's :data:`SLOT_BYTES`.

    A 4bpp file goes as it is; a 3bpp one is expanded, with bit 3 set on the
    non-transparent pixels of whichever tiles :func:`masked_tiles` names.
    :func:`slot_format` is what ``raw`` has to be, and what a file that never
    reaches a slot is refused by.
    """
    tiles = decode_tiles(slot_format(number, raw), raw)
    masked = masked_tiles(number, tileset)
    if masked is None or masked:
        wanted = range(SLOT_TILES) if masked is None else masked
        tiles = [
            bytes((pixel | 0x08) if pixel else 0 for pixel in tile)
            if index in wanted
            else tile
            for index, tile in enumerate(tiles)
        ]
    return encode_tiles(TileFormat.PLANAR_4BPP, tiles)


# -- the Mode 7 codec ---------------------------------------------------------
#
# A row is 24 bits, pixel 0 in the top three. Half a row is twelve bits, which
# is small enough to table both ways.

#: Twelve bits -> the four pixels they pack, most significant first.
_MODE7_SPREAD: list[bytes] = [
    bytes((v >> shift) & 7 for shift in (9, 6, 3, 0)) for v in range(1 << 12)
]
_MODE7_GATHER: dict[bytes, int] = {pixels: v for v, pixels in enumerate(_MODE7_SPREAD)}


def _mode7_rows(tile: bytes) -> bytes:
    out = bytearray()
    for at in range(0, 24, 3):
        row = int.from_bytes(tile[at : at + 3], "big")
        out += _MODE7_SPREAD[row >> 12]
        out += _MODE7_SPREAD[row & 0xFFF]
    return bytes(out)


def _mode7_pack(tile: bytes) -> bytes:
    out = bytearray()
    for at in range(0, TILE_PIXELS, 8):
        row = (_MODE7_GATHER[bytes(tile[at : at + 4])] << 12) | _MODE7_GATHER[
            bytes(tile[at + 4 : at + 8])
        ]
        out += row.to_bytes(3, "big")
    return bytes(out)
