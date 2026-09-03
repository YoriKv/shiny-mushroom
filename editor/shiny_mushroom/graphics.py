"""The graphics files as an editor holds them: a catalogue, tiles as pictures,
PNG as a spelling of the raw form, and the numbers a save has to fit.

**The raw ``.bin`` in the overlay is the truth.** `Project.graphics` reads it
(overlay first, the shipped stream decompressed otherwise), `save_graphics`
writes it, and the build compresses it back
([`project-overlay.md`](../../docs/editor/project-overlay.md)). Everything
here is a view over that file: :func:`tiles` decodes it through
:mod:`smw_tools.graphics`, :func:`raster` draws the tiles under a palette the
caller chose, :func:`export_png` / :func:`import_png` spell the tiles as an
indexed picture and read one back, and :func:`price` says what a save would
cost against the run the file is assembled into.

The palette is never a fact about a file. A planar file is colour indices, and
which sixteen colours those index is decided by the level that loads it, so a
picture of one is drawn under a :class:`PaletteRow` the window picked -- a row
of the level on screen or a run of the global file -- and written into a PNG's
``PLTE`` as a display hint and nothing more.

Qt-free: a picture is a :class:`~shiny_mushroom.level.Raster`, and turning one
into a ``QImage`` is the ``ui`` side's job.
([`docs/editor/graphics-editing.md`](../../docs/editor/graphics-editing.md))
"""

from __future__ import annotations

import enum
import struct
import zlib
from collections.abc import Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

from shiny_mushroom import palettes
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level import Raster, snes_color
from shiny_mushroom.project import ProjectError
from smw_tools import graphics as codec
from smw_tools import packed
from smw_tools.graphics import TILE_PIXELS, TILE_SIDE, GraphicsError, TileFormat

if TYPE_CHECKING:
    from shiny_mushroom.project import Project

__all__ = [
    "Colour",
    "GraphicsError",
    "GraphicsFile",
    "KEYWORD",
    "Kind",
    "PaletteRow",
    "Png",
    "Price",
    "Room",
    "baseline_tiles",
    "changed_tiles",
    "default_row",
    "ensure_raw",
    "export_png",
    "file_format",
    "file_rows",
    "files",
    "import_pixels",
    "import_png",
    "palette_rows",
    "price",
    "raster",
    "read_png",
    "redmean",
    "rgba_line",
    "room",
    "rooms",
    "row_width",
    "scene_rows",
    "snes_value",
    "stamps",
    "tiles",
    "write_png",
]

#: One colour as the editor draws it: 8-bit red, green, blue.
Colour = tuple[int, int, int]

BLACK: Colour = (0, 0, 0)

#: Tiles across a sheet, in :func:`raster` and in a PNG: a VRAM slot's own
#: width, and what every tile editor lays a file out as.
COLUMNS = 16

#: CGRAM as the console holds it, and as a `.pal` sidecar carries it: 256
#: colours, two bytes each -- sixteen rows of sixteen, which is what a 4bpp
#: tile's palette bits pick between (:func:`scene_rows`, :func:`row_name`).
CGRAM_COLOURS = 256
CGRAM_SIZE = 2 * CGRAM_COLOURS
CGRAM_ROWS = 16


# -- the catalogue -----------------------------------------------------------


class Kind(enum.Enum):
    """What a file is loaded as, which is what decides the palette it is
    sensibly drawn under -- see :func:`default_row`."""

    #: Sprite tiles, `SP1`-`SP4` of some sprite set.
    SPRITES = "sprites"
    #: Layer 1/2 tiles, `FG1`-`FG3` and `BG1` of some FG/BG set.
    LAYERS = "layers"
    #: 2bpp Layer 3 tiles, uploaded unconverted.
    LAYER3 = "layer3"
    #: `GFX27`, the Mode 7 boss background.
    MODE7 = "mode7"
    #: `GFX32`, the player, already 4bpp.
    PLAYER = "player"
    #: `GFX33`, the animated tiles.
    ANIMATED = "animated"
    #: A file the project added, loaded by whichever slot names it.
    ADDED = "added"


#: What each file is for, read off `SpriteGFXList` and `FGAndBGGFXList`
#: (`SMW/Banks/Bank00.asm`) -- which slot of which set names it -- and off
#: [`graphics-loading.md`](../../docs/smw/graphics-loading.md) for the files
#: no set row names. A phrase per file, not a claim about every user of it.
PURPOSES: dict[int, tuple[Kind, str]] = {
    0x00: (Kind.SPRITES, "sprites shared by every set (SP1)"),
    0x01: (Kind.SPRITES, "sprites shared by every set (SP2)"),
    0x02: (Kind.SPRITES, "Forest sprites (SP4)"),
    0x03: (Kind.SPRITES, "Castle sprites (SP4)"),
    0x04: (Kind.SPRITES, "Underground sprites (SP4)"),
    0x05: (Kind.SPRITES, "Mushroom sprites (SP4)"),
    0x06: (Kind.SPRITES, "Water sprites (SP4); Ghost House SP3"),
    0x07: (Kind.LAYERS, "Ghost House Layer 1/2 tiles (FG3)"),
    0x08: (Kind.LAYERS, "Switch Palace Layer 1/2 tiles (FG3); overworld BG1"),
    0x09: (Kind.SPRITES, "Pokey sprites (SP4)"),
    0x0A: (Kind.SPRITES, "Wendy/Lemmy sprites (SP3)"),
    0x0B: (Kind.SPRITES, "Bowser credits sprites (SP2)"),
    0x0C: (Kind.LAYERS, "Underground / Ghost House background tiles (BG1)"),
    0x0D: (Kind.LAYERS, "Underground 2 / Ghost House 2 background tiles (BG1)"),
    0x0E: (Kind.SPRITES, "Mecha-Koopa / Ninji sprites (SP4)"),
    0x0F: (Kind.SPRITES, "Yoshi's House sprites (SP4); overworld SP2"),
    0x10: (Kind.SPRITES, "overworld sprites (SP1)"),
    0x11: (Kind.SPRITES, "Ghost House sprites (SP4)"),
    0x12: (Kind.SPRITES, "Castle sprites (SP3)"),
    0x13: (Kind.SPRITES, "sprites shared by most sets (SP3)"),
    0x14: (Kind.LAYERS, "Layer 1/2 tiles, FG1 of every set"),
    0x15: (Kind.LAYERS, "Normal Layer 1/2 tiles (FG3)"),
    0x16: (Kind.LAYERS, "Rope Layer 1/2 tiles (FG3)"),
    0x17: (Kind.LAYERS, "Layer 1/2 tiles, FG2 of every set"),
    0x18: (Kind.LAYERS, "Castle Layer 1/2 tiles (FG3)"),
    0x19: (Kind.LAYERS, "Normal / Cloud / Forest background tiles (BG1)"),
    0x1A: (Kind.LAYERS, "Underground Layer 1/2 tiles (FG3)"),
    0x1B: (Kind.LAYERS, "Castle / Rope / Switch Palace background tiles (BG1)"),
    0x1C: (Kind.LAYERS, "overworld tiles (FG1)"),
    0x1D: (Kind.LAYERS, "overworld tiles (FG2)"),
    0x1E: (Kind.LAYERS, "overworld tiles (FG3)"),
    0x1F: (Kind.LAYERS, "Cloud / Forest Layer 1/2 tiles (FG3)"),
    0x20: (Kind.SPRITES, "Banzai Bill sprites (SP4)"),
    0x21: (Kind.SPRITES, "Bowser credits sprites (SP1)"),
    0x22: (Kind.SPRITES, "boss room sprites (SP4)"),
    0x23: (Kind.SPRITES, "Dino-Rhino sprites (SP4)"),
    0x24: (Kind.SPRITES, "Mecha-Koopa / boss room sprites (SP3)"),
    0x25: (Kind.SPRITES, "Reznor / Iggy / Larry room sprites (SP3)"),
    0x26: (Kind.SPRITES, "Yoshi's House credits sprites (SP2)"),
    0x27: (Kind.MODE7, "Mode 7 boss background"),
    0x28: (Kind.LAYER3, "Layer 3 tiles (2bpp)"),
    0x29: (Kind.LAYER3, "Layer 3 tiles (2bpp)"),
    0x2A: (Kind.LAYER3, "Layer 3 tiles (2bpp)"),
    0x2B: (Kind.LAYER3, "Layer 3 tiles (2bpp)"),
    0x2C: (Kind.LAYERS, "castle destruction cutscene tiles (FG3)"),
    0x2D: (Kind.SPRITES, "castle destruction sprites (SP4)"),
    0x2E: (Kind.SPRITES, "Yoshi's House credits sprites (SP3)"),
    0x2F: (Kind.LAYER3, "credits letters (2bpp)"),
    0x30: (Kind.SPRITES, "The End screen sprites (SP2)"),
    0x31: (Kind.SPRITES, "64 sprite tiles no set row names"),
    0x32: (Kind.PLAYER, "the player (4bpp)"),
    0x33: (Kind.ANIMATED, "animated tiles"),
}


@dataclass(frozen=True)
class GraphicsFile:
    """One file of the project's asset set, as a catalogue row."""

    number: int
    #: `GFX1E`.
    name: str
    format: TileFormat
    #: How many tiles it holds.
    tiles: int
    #: What it decompresses to, in bytes.
    raw_size: int
    kind: Kind
    #: What it is for, in a phrase -- for a file the project adds, the name
    #: somebody gave it, since what it is for is theirs to know.
    purpose: str
    #: What the overlay's raw form is called: `GFX1E.bin` for a stock file,
    #: and for an added one whatever it has been renamed to.
    file_name: str
    #: Whether the overlay holds a raw form of it.
    edited: bool
    #: What the shipped stream takes in the cartridge, in bytes -- zero when
    #: the assets are not extracted, in which case the build reads nothing.
    baseline: int
    #: What the build will write for it: the baseline's size for a file that
    #: is unedited or edited back to its pixels, the re-encoding's otherwise.
    encoded: int

    @property
    def grown(self) -> int:
        """Bytes the file takes beyond what it shipped as; negative when the
        edit packs smaller."""
        return self.encoded - self.baseline


@dataclass(frozen=True)
class Room:
    """What a run of graphics holds and may hold, in bytes: the sum of what
    the build will write for every file in it, against the run's budget.

    The stock region on a stock cartridge; on one whose graphics are managed
    (:attr:`~shiny_mushroom.project.Project.graphics_managed`), one per run
    the packer fills -- :func:`rooms` -- or the whole packing at once.
    """

    region: str
    used: int
    budget: int
    #: The run in the person's words, `banks $08-$0B` or `bank $12`; empty
    #: for the stock region, which is the only one.
    name: str = ""

    @property
    def free(self) -> int:
        return self.budget - self.used


def file_format(project: Project, number: int) -> TileFormat:
    """The layout file ``number`` is in: the loader's for a stock file, the
    project's record for an added one -- and a :class:`GraphicsError` for a
    number that is neither."""
    if number in codec.FILE_NUMBERS:
        return codec.tile_format(number)
    try:
        return project.added_graphics()[number]
    except KeyError:
        raise GraphicsError(
            f"GFX{number:02X} is neither a file the set ships nor one this project adds"
        ) from None


def files(project: Project) -> list[GraphicsFile]:
    """The 52 files of the project's own asset set, in number order, then
    every file the project adds.

    An edited file is priced through the encoder, the way the build writes it;
    an untouched one costs a `stat`. An added file has no shipped stream: its
    baseline is zero, every one of its tiles is an edit, and its encoding is
    from scratch.
    """
    edited = set(project.raw_edits())
    known = project.packed_resources()
    out = []
    for number in codec.FILE_NUMBERS:
        key = project.graphics_key(number)
        resource = known[key]
        shipped = resource.baseline_path(project.base, project.assets_base)
        try:
            baseline = shipped.stat().st_size
        except OSError:
            baseline = 0
        held = key in edited
        encoded = baseline
        if held and baseline:
            encoded = len(
                resource.encode(project.graphics(number), shipped.read_bytes())
            )
        kind, purpose = PURPOSES[number]
        out.append(
            GraphicsFile(
                number=number,
                name=codec.file_name(number),
                format=codec.tile_format(number),
                tiles=codec.tile_count(number),
                raw_size=codec.decompressed_size(number),
                kind=kind,
                purpose=purpose,
                file_name=key.name,
                edited=held,
                baseline=baseline,
                encoded=encoded,
            )
        )
    slots = project.added_graphics_slots()
    for number, fmt in project.added_graphics().items():
        resource = known[project.graphics_key(number)]
        raw = project.graphics(number)
        file_name = slots.get(number, f"GFX{number:02X}.bin")
        out.append(
            GraphicsFile(
                number=number,
                name=f"GFX{number:02X}",
                format=fmt,
                tiles=len(raw) // fmt.tile_bytes,
                raw_size=len(raw),
                kind=Kind.ADDED,
                purpose=Path(file_name).stem,
                file_name=file_name,
                edited=True,
                baseline=0,
                encoded=len(resource.encode(raw, None)),
            )
        )
    return out


def room(project: Project) -> Room:
    """How full the graphics are, priced exactly as a save is: the stock
    run's usage against its budget
    (:meth:`~shiny_mushroom.project.Project.region_usage`), or, where the
    graphics are managed, every file against every run the packer fills
    (:meth:`~shiny_mushroom.project.Project.graphics_packing`) -- a summary
    a footer can show; :func:`rooms` is the run-by-run reading."""
    region = packed.graphics_region(project.graphics_set)
    if not project.graphics_managed:
        used, budget = project.region_usage(region)
        return Room(region, used, budget)
    packing = project.graphics_packing()
    banks = f"{packing.banks} graphics bank{'s' if packing.banks != 1 else ''}"
    return Room(region, packing.total, packing.room, f"the stock banks and {banks}")


def rooms(project: Project) -> list[Room]:
    """Every run the graphics are packed into, as :class:`Room` rows: the
    one stock region on a stock cartridge; on a managed one, the stock four
    banks and then each graphics bank, each at what the packing put there.
    A packing that fits nowhere has every run at what it holds up to the
    file that found no room."""
    region = packed.graphics_region(project.graphics_set)
    if not project.graphics_managed:
        return [room(project)]
    packing = project.graphics_packing()
    out = []
    for run, used in zip(packing.runs, packing.used, strict=True):
        last = (run.end - 1) >> 16
        name = (
            f"bank {hexnum(run.bank)}"
            if last == run.bank
            else f"banks {hexnum(run.bank)}-{hexnum(last)}"
        )
        out.append(Room(region, used, run.size, name))
    return out


# -- tiles as pictures --------------------------------------------------------


def tiles(project: Project, number: int) -> list[bytes]:
    """The file's tiles as the project holds them -- the overlay's raw form
    where there is one -- each 64 colour indices, row-major."""
    return codec.decode_tiles(file_format(project, number), project.graphics(number))


def baseline_tiles(project: Project, number: int) -> list[bytes]:
    """The shipped file's tiles, whatever the overlay holds. An added file
    ships nothing, so its baseline is every tile blank."""
    resource = project.resource_for(project.graphics_key(number))
    if resource.added:
        return [bytes(TILE_PIXELS)] * (
            (resource.raw_size or 0) // file_format(project, number).tile_bytes
        )
    return codec.decode(
        number, packed.read_raw(resource, project.base, project.assets_base)
    )


def changed_tiles(project: Project, number: int) -> set[int]:
    """Which tile indices differ between the overlay's raw form and the shipped
    file. Empty for a file the overlay does not hold; every tile of an added
    file, which has nothing shipped to agree with."""
    if project.graphics_key(number) not in project.raw_edits():
        return set()
    held = tiles(project, number)
    if number not in codec.FILE_NUMBERS:
        return set(range(len(held)))
    shipped = baseline_tiles(project, number)
    return {
        index for index, (a, b) in enumerate(zip(held, shipped, strict=True)) if a != b
    }


def raster(
    tiles: Sequence[bytes], palette: Sequence[Colour], columns: int = COLUMNS
) -> Raster:
    """The sheet: ``tiles`` laid ``columns`` to a row under ``palette``.

    Index ``n`` is drawn as ``palette[n]`` -- colour 0 included, so a caller
    that wants transparency hatched draws it over the result. A palette
    shorter than the indices used is padded with black, so a 4-colour row
    under a 2bpp file and a 16-colour one under anything else both work. The
    tail of a partial last row is black.
    """
    if columns < 1:
        raise GraphicsError(f"a sheet needs at least one column, not {columns}")
    colours = [bytes(colour) for colour in palette]
    colours += [bytes(BLACK)] * max(0, 256 - len(colours))
    blank = bytes(BLACK) * TILE_SIDE
    rows = -(-len(tiles) // columns)
    lines = []
    for tile_row in range(rows):
        first = tile_row * columns
        strip = tiles[first : first + columns]
        for y in range(TILE_SIDE):
            at = y * TILE_SIDE
            line = b"".join(
                b"".join(colours[index] for index in tile[at : at + TILE_SIDE])
                for tile in strip
            )
            lines.append(line + blank * (columns - len(strip)))
    return Raster(columns * TILE_SIDE, rows * TILE_SIDE, b"".join(lines))


# -- palette sources ----------------------------------------------------------


@dataclass(frozen=True)
class PaletteRow:
    """A named run of colours a sheet can be drawn under: sixteen for the
    planar 3bpp, 4bpp and Mode 7 files, four for a 2bpp one."""

    name: str
    colours: tuple[Colour, ...]


def row_width(fmt: TileFormat) -> int:
    """How many colours a row for ``fmt`` holds.

    A 2bpp tile indexes four colours and the PPU reads Layer 3's palettes as
    eight groups of four out of CGRAM's first two rows, so a row for one is
    four wide. Everything else is drawn under a full CGRAM row: a 3bpp file
    uses indices 0-7 of it as stored and 8-15 where the loader's mask moves it
    ([`graphics-loading.md`](../../docs/smw/graphics-loading.md)), which is
    why the row is not cut to eight.
    """
    return 4 if fmt.bpp == 2 else 16


def scene_rows(cgram: bytes, fmt: TileFormat) -> list[PaletteRow]:
    """The rows of one CGRAM capture -- the level on screen's own colours.

    Sixteen rows of sixteen for the planar files, named by row number and
    which half of CGRAM they are (`Row $2, background`; `Row $8, sprites`);
    the eight four-colour Layer 3 palettes for a 2bpp file.
    """
    if len(cgram) != CGRAM_SIZE:
        raise GraphicsError(f"CGRAM is {CGRAM_SIZE} bytes, got {len(cgram)}")
    colours = [
        tuple(snes_color(cgram[2 * n] | (cgram[2 * n + 1] << 8)))
        for n in range(CGRAM_COLOURS)
    ]
    width = row_width(fmt)
    if width == 4:
        return [
            PaletteRow(f"Layer 3 palette {n}", tuple(colours[4 * n : 4 * n + 4]))
            for n in range(8)
        ]
    return [
        PaletteRow(row_name(n), tuple(colours[16 * n : 16 * n + 16]))
        for n in range(CGRAM_ROWS)
    ]


def row_name(row: int) -> str:
    """What :func:`scene_rows` calls one of CGRAM's sixteen rows -- spelled
    here so a picker of them can be filled without a capture to name them
    from."""
    return f"Row {hexnum(row, 0)}, {'background' if row < 8 else 'sprites'}"


def file_rows(blob: bytes, fmt: TileFormat) -> list[PaletteRow]:
    """The global palette file's runs, as :mod:`shiny_mushroom.palettes`
    names them -- what the Sets tab offers -- cut into rows of
    :func:`row_width` and padded with black where a run does not fill one.

    A run longer than a row is several, numbered: `Sprites (1)`,
    `Sprites (2)`. A display palette and only that: which of a run's colours
    land at which index in a level is the loader's business.
    """
    palettes.check(blob)
    width = row_width(fmt)
    out = []
    for region in palettes.catalog():
        colours = [
            tuple(snes_color(value))
            for value in palettes.colors(blob, region.start, region.count)
        ]
        chunks = [colours[at : at + width] for at in range(0, len(colours), width)]
        for n, chunk in enumerate(chunks):
            name = region.title if len(chunks) == 1 else f"{region.title} ({n + 1})"
            out.append(PaletteRow(name, tuple(chunk) + (BLACK,) * (width - len(chunk))))
    return out


def palette_rows(
    project: Project, fmt: TileFormat, cgram: bytes | None = None
) -> list[PaletteRow]:
    """Every row a viewer can draw ``fmt`` under: the scene's, when the caller
    has a CGRAM capture, then the project's palette file's."""
    rows = scene_rows(cgram, fmt) if cgram is not None else []
    return rows + file_rows(project.palette(), fmt)


def default_row(number: int) -> int:
    """Which of :func:`scene_rows` to open a file under.

    A guess at where its tiles are usually drawn, and nothing turns on it:
    sprite files and the player under row 8, the first sprite palette; Layer
    1/2 files and the animated tiles under row 2, the header-selected
    foreground palette; a 2bpp file under Layer 3 palette 2, the first the
    `Layer3` run writes; the Mode 7 background under row 0, since Mode 7
    indexes CGRAM directly. An added file, which any slot may load, under
    row 2.
    """
    kind, _purpose = PURPOSES.get(number, (Kind.ADDED, ""))
    if kind in (Kind.SPRITES, Kind.PLAYER):
        return 8
    if kind is Kind.MODE7:
        return 0
    return 2


# -- PNG ------------------------------------------------------------------------
#
# Standard library only: the format is a signature, a run of length-tagged CRC'd
# chunks, and one zlib stream of filtered scanlines, which is a hundred lines of
# struct and zlib and not a dependency.

_SIGNATURE = b"\x89PNG\r\n\x1a\n"
#: The keyword under which an export records what it is.
KEYWORD = b"shiny-mushroom"

#: Colour type -> samples per pixel.
_CHANNELS = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}
_INDEXED = 3


def export_png(
    tiles: Sequence[bytes],
    fmt: TileFormat,
    palette: Sequence[Colour],
    columns: int = COLUMNS,
    name: str = "",
) -> bytes:
    """``tiles`` as an indexed PNG: colour type 3, 8 bits a pixel, not
    interlaced, ``columns`` tiles to a row, the pixel value the colour index.

    ``PLTE`` is ``palette`` -- the row the picture was drawn under -- padded
    with black to the format's colour count when shorter, so the picture *is*
    the palette the user saw. Colour 0 is an ordinary entry rather than a
    ``tRNS`` transparency: an editor that flattens the picture then keeps
    colour 0's own RGB, which is what lets :func:`import_png` recognise it.

    A ``tEXt`` chunk under ``shiny-mushroom`` records ``name``, the format and
    the tile count, so an import can refuse a picture of the wrong kind.
    """
    if columns < 1:
        raise GraphicsError(f"a sheet needs at least one column, not {columns}")
    entries = [tuple(colour) for colour in palette][:256]
    entries += [BLACK] * max(0, fmt.colours - len(entries))
    limit = fmt.colours
    rows = -(-len(tiles) // columns)
    width, height = columns * TILE_SIDE, rows * TILE_SIDE
    scanlines = []
    for tile_row in range(rows):
        strip = list(tiles[tile_row * columns : (tile_row + 1) * columns])
        for index, tile in enumerate(strip, tile_row * columns):
            if len(tile) != TILE_PIXELS:
                raise GraphicsError(
                    f"tile {index} has {len(tile)} pixels, not {TILE_PIXELS}"
                )
            if max(tile) >= limit:
                raise GraphicsError(
                    f"tile {index} uses colour {max(tile)}; {fmt.name} holds "
                    f"{fmt.colours} (0-{fmt.colours - 1})"
                )
        strip += [bytes(TILE_PIXELS)] * (columns - len(strip))
        for y in range(TILE_SIDE):
            at = y * TILE_SIDE
            scanlines.append(b"".join(tile[at : at + TILE_SIDE] for tile in strip))
    text = f"name={name};format={fmt.name};tiles={len(tiles)}".encode("latin-1")
    plte = b"".join(bytes(colour) for colour in entries)
    return write_png(
        width,
        height,
        _INDEXED,
        8,
        scanlines,
        [(b"PLTE", plte), (b"tEXt", KEYWORD + b"\0" + text)],
    )


def write_png(
    width: int,
    height: int,
    colour_type: int,
    bit_depth: int,
    scanlines: Sequence[bytes],
    extra: Sequence[tuple[bytes, bytes]] = (),
) -> bytes:
    """A PNG out of unfiltered scanlines (filter 0 on every row), ``extra``
    chunks between the header and the image data."""
    ihdr = struct.pack(">IIBBBBB", width, height, bit_depth, colour_type, 0, 0, 0)
    image = zlib.compress(b"".join(b"\0" + line for line in scanlines), 9)
    chunks = [(b"IHDR", ihdr), *extra, (b"IDAT", image), (b"IEND", b"")]
    return _SIGNATURE + b"".join(_chunk(kind, data) for kind, data in chunks)


def _chunk(kind: bytes, data: bytes) -> bytes:
    crc = zlib.crc32(kind + data) & 0xFFFFFFFF
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", crc)


@dataclass(frozen=True)
class Png:
    """A decoded PNG: one byte per sample, unfiltered and unpacked."""

    width: int
    height: int
    colour_type: int
    #: Rows of samples, ``channels`` bytes a pixel.
    rows: list[bytes]
    #: The ``shiny-mushroom`` text, or the empty string.
    text: str
    #: The ``PLTE`` chunk as read, three bytes a colour -- empty for a
    #: picture without one.
    palette: bytes = b""

    @property
    def channels(self) -> int:
        return _CHANNELS[self.colour_type]


def read_png(data: bytes) -> Png:
    """Colour types 0, 2, 3, 4 and 6; bit depths 1-8 for the indexed and
    greyscale kinds and 8 for the rest; no interlace. Every CRC is checked, so
    a truncated or edited file is refused rather than read as a picture."""
    if not data.startswith(_SIGNATURE):
        raise GraphicsError("not a PNG file")
    at = len(_SIGNATURE)
    header = None
    image = bytearray()
    text = ""
    plte = b""
    while at < len(data):
        if at + 8 > len(data):
            raise GraphicsError("PNG is truncated")
        (length,) = struct.unpack(">I", data[at : at + 4])
        kind = data[at + 4 : at + 8]
        body = data[at + 8 : at + 8 + length]
        crc = data[at + 8 + length : at + 12 + length]
        if len(body) != length or len(crc) != 4:
            raise GraphicsError("PNG is truncated")
        if struct.unpack(">I", crc)[0] != (zlib.crc32(kind + body) & 0xFFFFFFFF):
            raise GraphicsError(f"PNG chunk {kind.decode('latin-1')} fails its CRC")
        at += 12 + length
        if kind == b"IHDR":
            header = struct.unpack(">IIBBBBB", body)
        elif kind == b"IDAT":
            image += body
        elif kind == b"PLTE":
            plte = bytes(body)
        elif kind == b"tEXt" and body.startswith(KEYWORD + b"\0"):
            text = body[len(KEYWORD) + 1 :].decode("latin-1")
        elif kind == b"IEND":
            break
    if header is None:
        raise GraphicsError("PNG has no header")
    width, height, depth, colour_type, compression, filter_method, interlace = header
    if colour_type not in _CHANNELS:
        raise GraphicsError(f"PNG colour type {colour_type} is not one this reads")
    if compression or filter_method:
        raise GraphicsError(
            "PNG uses a compression or filter method this does not read"
        )
    if interlace:
        raise GraphicsError("PNG is interlaced; save it without interlacing")
    if depth not in (1, 2, 4, 8) or (depth != 8 and colour_type not in (0, _INDEXED)):
        raise GraphicsError(f"PNG bit depth {depth} is not one this reads")
    channels = _CHANNELS[colour_type]
    bits = channels * depth
    stride = (width * bits + 7) // 8
    step = max(1, bits // 8)
    try:
        raw = zlib.decompress(bytes(image))
    except zlib.error as error:
        raise GraphicsError(f"PNG image data is corrupt: {error}") from None
    if len(raw) != (stride + 1) * height:
        raise GraphicsError("PNG image data is not the size its header says")
    # A sub-byte greyscale sample is a fraction of full white, so it is scaled
    # to the byte `_rgba` reads it as; an indexed one is an index and is not.
    grey_scale = 255 // ((1 << depth) - 1) if colour_type == 0 and depth < 8 else 1
    rows: list[bytes] = []
    previous = bytes(stride)
    for y in range(height):
        start = y * (stride + 1)
        line = _unfilter(
            raw[start], raw[start + 1 : start + 1 + stride], previous, step
        )
        previous = line
        if depth < 8:
            unpacked = _unpack(line, depth, width)
            line = (
                bytes(sample * grey_scale for sample in unpacked)
                if grey_scale != 1
                else unpacked
            )
        rows.append(line)
    return Png(width, height, colour_type, rows, text, plte)


def _unfilter(kind: int, line: bytes, previous: bytes, step: int) -> bytes:
    """One scanline with its filter undone."""
    if kind == 0:
        return line
    out = bytearray(line)
    if kind == 1:
        for i in range(step, len(out)):
            out[i] = (out[i] + out[i - step]) & 0xFF
    elif kind == 2:
        for i in range(len(out)):
            out[i] = (out[i] + previous[i]) & 0xFF
    elif kind == 3:
        for i in range(len(out)):
            left = out[i - step] if i >= step else 0
            out[i] = (out[i] + ((left + previous[i]) >> 1)) & 0xFF
    elif kind == 4:
        for i in range(len(out)):
            a = out[i - step] if i >= step else 0
            b = previous[i]
            c = previous[i - step] if i >= step else 0
            p = a + b - c
            pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
            predicted = a if pa <= pb and pa <= pc else b if pb <= pc else c
            out[i] = (out[i] + predicted) & 0xFF
    else:
        raise GraphicsError(f"PNG scanline filter {kind} does not exist")
    return bytes(out)


def _unpack(line: bytes, depth: int, width: int) -> bytes:
    """One sample a byte out of a scanline packed ``depth`` bits a sample."""
    per_byte = 8 // depth
    mask = (1 << depth) - 1
    out = bytearray()
    for byte in line:
        for n in range(per_byte):
            out.append((byte >> (8 - depth * (n + 1))) & mask)
    return bytes(out[:width])


def import_png(
    png: bytes,
    fmt: TileFormat,
    baseline_tiles: Sequence[bytes],
    palette: Sequence[Colour],
) -> list[bytes]:
    """The tiles a PNG spells, read back against what the file holds now.

    An indexed picture (colour type 3) is read straight: the pixel value is
    the colour index, refused where it is past what ``fmt`` can hold. A
    picture some editor flattened to greyscale, RGB or RGBA is read
    **base-aware**: a pixel whose colour is still what ``palette`` gave the
    baseline tile's index at that position keeps that index -- so two indices
    sharing a colour, and a colour the palette holds twice, survive the round
    trip -- and any other pixel takes the nearest of the format's colours by
    redmean distance. A fully transparent pixel is index 0.

    The picture must be whole tiles, ``len(baseline_tiles)`` of them, in the
    sheet's own column count or any other that leaves less than a row spare.
    A picture that records a different format or tile count in its
    ``shiny-mushroom`` text is refused as the wrong kind of file, whatever its
    size; one that records a different *name* is not, since a file may be
    imported into another of its kind on purpose.
    """
    picture = read_png(png)
    count = len(baseline_tiles)
    _check_kind(picture.text, fmt, count)
    columns = _sheet_columns(picture.width, picture.height, count)
    if picture.colour_type == _INDEXED:
        out = [bytearray(TILE_PIXELS) for _ in range(count)]
        for y, line in enumerate(picture.rows):
            _place_row(out, y, columns, line, fmt)
        return [bytes(tile) for tile in out]
    rows = [rgba_line(line, picture.channels, picture.width) for line in picture.rows]
    return _match_rows(
        rows, picture.width, columns, baseline_tiles, _entries(fmt, palette)
    )


def import_pixels(
    pixels: bytes,
    width: int,
    height: int,
    fmt: TileFormat,
    baseline_tiles: Sequence[bytes],
    palette: Sequence[Colour],
) -> list[bytes]:
    """The tiles a picture of plain pixels spells -- ``pixels`` is RGBA, four
    bytes each, ``width`` * ``height`` of them, rows top to bottom.

    What a picture that never was a file spells: the clipboard's, which
    carries a bitmap and no palette at all. There being no indices to read,
    every pixel is matched the way :func:`import_png` matches a flattened
    one -- against ``palette`` and the baseline tile under it -- and the same
    whole-tiles-and-the-file's-count rule decides the size.
    """
    if len(pixels) != width * height * 4:
        raise GraphicsError(
            f"the picture is {width}x{height} and {len(pixels):,} bytes, not "
            f"the {width * height * 4:,} four bytes a pixel makes"
        )
    columns = _sheet_columns(width, height, len(baseline_tiles), "the picture")
    rows = [bytes(pixels[y * width * 4 : (y + 1) * width * 4]) for y in range(height)]
    return _match_rows(rows, width, columns, baseline_tiles, _entries(fmt, palette))


def _sheet_columns(width: int, height: int, count: int, what: str = "PNG") -> int:
    """How many tiles a picture of ``width`` x ``height`` lays across, refusing
    one that is not ``count`` whole tiles: any column count will do, so long as
    it leaves less than a row spare."""
    if width % TILE_SIDE or height % TILE_SIDE:
        raise GraphicsError(
            f"{what} is {width}x{height}, not whole tiles of {TILE_SIDE}"
        )
    columns, rows = width // TILE_SIDE, height // TILE_SIDE
    grid = columns * rows
    if grid < count or grid - count >= columns:
        wanted_rows = -(-count // COLUMNS)
        raise GraphicsError(
            f"{what} is {width}x{height}, which is {grid} tiles; "
            f"this file holds {count}, {COLUMNS * TILE_SIDE}x{wanted_rows * TILE_SIDE}"
        )
    return columns


def _entries(fmt: TileFormat, palette: Sequence[Colour]) -> list[Colour]:
    """``palette`` cut and padded to the colours ``fmt`` holds."""
    entries = [tuple(colour) for colour in palette][: fmt.colours]
    return entries + [BLACK] * (fmt.colours - len(entries))


def rgba_line(line: bytes, channels: int, width: int) -> bytes:
    """One decoded scanline as RGBA, whatever its colour type gave: grey is
    read into all three channels, a picture without alpha is opaque."""
    if channels == 4:
        return line
    out = bytearray(width * 4)
    for x in range(width):
        sample = line[x * channels : (x + 1) * channels]
        colour = (sample[0],) * 3 if channels <= 2 else sample[:3]
        out[x * 4 : x * 4 + 3] = bytes(colour)
        out[x * 4 + 3] = sample[-1] if channels == 2 else 255
    return bytes(out)


def _match_rows(
    rows: Sequence[bytes],
    width: int,
    columns: int,
    baseline_tiles: Sequence[bytes],
    entries: Sequence[Colour],
) -> list[bytes]:
    """RGBA scanlines into the tiles they cross, each pixel base-aware
    (:func:`_match`)."""
    count = len(baseline_tiles)
    out = [bytearray(TILE_PIXELS) for _ in range(count)]
    nearest: dict[Colour, int] = {}
    for y, line in enumerate(rows):
        tile_row = y // TILE_SIDE
        within = (y % TILE_SIDE) * TILE_SIDE
        for x in range(width):
            index = tile_row * columns + x // TILE_SIDE
            if index >= count:
                break
            at = within + x % TILE_SIDE
            out[index][at] = _match(
                (line[x * 4], line[x * 4 + 1], line[x * 4 + 2]),
                line[x * 4 + 3],
                baseline_tiles[index][at],
                entries,
                nearest,
            )
    return [bytes(tile) for tile in out]


def _check_kind(text: str, fmt: TileFormat, count: int) -> None:
    if not text:
        return
    recorded = dict(part.split("=", 1) for part in text.split(";") if "=" in part)
    wrong = []
    if recorded.get("format", fmt.name) != fmt.name:
        wrong.append(f"format {recorded['format']}, not {fmt.name}")
    if recorded.get("tiles", str(count)) != str(count):
        wrong.append(f"{recorded['tiles']} tiles, not {count}")
    if wrong:
        origin = recorded.get("name") or "a file"
        raise GraphicsError(f"PNG was exported from {origin}: {'; '.join(wrong)}")


def _place_row(
    out: list[bytearray], y: int, columns: int, line: bytes, fmt: TileFormat
) -> None:
    """One indexed scanline into the tiles it crosses."""
    tile_row = y // TILE_SIDE
    within = (y % TILE_SIDE) * TILE_SIDE
    for column in range(columns):
        index = tile_row * columns + column
        if index >= len(out):
            return
        pixels = line[column * TILE_SIDE : (column + 1) * TILE_SIDE]
        if max(pixels) >= fmt.colours:
            raise GraphicsError(
                f"PNG uses colour {max(pixels)} in tile {index}; {fmt.name} holds "
                f"{fmt.colours} (0-{fmt.colours - 1})"
            )
        out[index][within : within + TILE_SIDE] = pixels


def _match(
    colour: Colour,
    alpha: int,
    base_index: int,
    entries: Sequence[Colour],
    nearest: dict[Colour, int],
) -> int:
    if alpha == 0:
        return 0
    if entries[base_index] == colour:
        return base_index
    found = nearest.get(colour)
    if found is None:
        found = min(range(len(entries)), key=lambda n: redmean(colour, entries[n]))
        nearest[colour] = found
    return found


def redmean(a: Colour, b: Colour) -> int:
    """Squared distance weighted the way the eye is, in integers."""
    mean = (a[0] + b[0]) // 2
    dr, dg, db = a[0] - b[0], a[1] - b[1], a[2] - b[2]
    return ((512 + mean) * dr * dr >> 8) + 4 * dg * dg + ((767 - mean) * db * db >> 8)


# -- the raw files themselves --------------------------------------------------


def snes_value(colour: Colour) -> int:
    """One RGB colour as the 15-bit word CGRAM holds, ``0BBBBBGG GGGRRRRR``:
    :func:`~shiny_mushroom.level.snes_color`'s inverse for a colour that came
    from one."""
    r, g, b = (channel >> 3 for channel in colour)
    return r | (g << 5) | (b << 10)


def raw_path(project: Project, number: int) -> Path:
    """Where the overlay keeps, or would keep, the file's raw ``.bin``."""
    return project.raw_path(project.graphics_key(number))


def ensure_raw(project: Project, number: int) -> Path:
    """The overlay's raw ``.bin`` for the file, materialised if it was not
    there: the shipped stream decompressed and saved, which costs nothing --
    an unedited raw form re-encodes to the cartridge's own bytes. What a
    window hands to whatever opens the folder."""
    path = raw_path(project, number)
    if not path.is_file():
        project.save_graphics(number, project.graphics(number))
    return path


def stamps(project: Project) -> dict[Path, tuple[int, int]]:
    """``(size, mtime_ns)`` of every raw graphics file the overlay holds, by
    its absolute path -- what an external save moves, and a `stat` apiece to
    ask, so a window can notice one on focus."""
    found: dict[Path, tuple[int, int]] = {}
    for key in project.raw_edits():
        if key.parts[0] != packed.ASSETS_ROOT:
            continue
        path = project.raw_path(key)
        try:
            stat = path.stat()
        except OSError:
            continue
        found[path] = (stat.st_size, stat.st_mtime_ns)
    return found


# -- pricing --------------------------------------------------------------------


@dataclass(frozen=True)
class Price:
    """What saving a set of tiles would cost, in the numbers
    :meth:`~shiny_mushroom.project.Project.save_graphics` decides by.

    On a stock cartridge the run's sum against its budget; where the
    graphics are managed, every file against every run of the packing --
    and a save the project's banks cannot hold but one more can is not
    refused, it :attr:`raises_banks`, as the save will.
    """

    #: What the build would write for the file, in bytes.
    encoded: int
    #: What the shipped stream takes; zero for an added file.
    baseline: int
    #: What the graphics would hold after the save, all files counted.
    used: int
    #: What they may hold: the run's budget, or every run of the packing at
    #: the bank count the save would leave.
    budget: int
    #: Whether the tiles differ from the shipped file's; a save of unchanged
    #: tiles keeps the cartridge's own bytes.
    changed: bool
    #: Bytes with nowhere to go; zero when the save fits.
    over: int = 0
    #: Whether the save takes a graphics bank the project has not got.
    raises_banks: bool = False

    @property
    def fits(self) -> bool:
        return self.over == 0


def price(project: Project, number: int, tiles: Sequence[bytes]) -> Price:
    """Price a save of ``tiles`` as the file, without writing anything.

    The same numbers :meth:`~shiny_mushroom.project.Project._save_resources`
    refuses on: on a stock cartridge the run's usage as it stands, less what
    this file contributes to it today, plus what these tiles encode to; on a
    managed one the packing with this file at its new size. A window asks
    this before writing so the refusal comes with the figures rather than
    after the fact.
    """
    key = project.graphics_key(number)
    resource = project.resource_for(key)
    fmt = file_format(project, number)
    raw = codec.encode_tiles(fmt, tiles)
    resource.check(raw)
    shipped_path = resource.baseline_path(project.base, project.assets_base)
    if resource.added:
        shipped = None
    else:
        try:
            shipped = shipped_path.read_bytes()
        except OSError:
            raise GraphicsError(
                f"{codec.file_name(number)} has no shipped file at "
                f"{shipped_path}; the assets are not extracted"
            ) from None
    encoded = resource.encode(raw, shipped)
    changed = encoded != shipped
    if project.graphics_managed:
        return _packed_price(project, number, encoded, shipped, changed)
    assert shipped is not None
    used, budget = project.region_usage(resource.region)
    held = project.raw_path(key)
    current = len(shipped)
    if held.is_file():
        current = len(resource.encode(project.graphics(number), shipped))
    after = used - current + len(encoded)
    return Price(
        encoded=len(encoded),
        baseline=len(shipped),
        used=after,
        budget=budget,
        changed=changed,
        over=max(0, after - budget),
    )


def _packed_price(
    project: Project,
    number: int,
    encoded: bytes,
    shipped: bytes | None,
    changed: bool,
) -> Price:
    """The managed reading: the packing with ``number`` at ``encoded``'s
    size, at the project's bank count and then at one more, the way the
    save decides (:meth:`~shiny_mushroom.project.Project._graphics_banks_needed`)."""
    banks = project.graphics_banks
    packing = project.graphics_packing(banks, {number: len(encoded)})
    raises = False
    if not packing.fits and not packing.split_player:
        try:
            more = project.graphics_packing(banks + 1, {number: len(encoded)})
        except ProjectError:
            more = None
        if more is not None and more.fits:
            packing, raises = more, True
    return Price(
        encoded=len(encoded),
        baseline=0 if shipped is None else len(shipped),
        used=packing.total,
        budget=packing.room,
        changed=changed,
        over=packing.over if not packing.split_player else max(packing.over, 1),
        raises_banks=raises,
    )
