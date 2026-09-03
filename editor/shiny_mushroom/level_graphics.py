"""Per-level graphics: the row a level names its files in, as the editor
keeps it.

A stock level loads the files its two header tilesets name -- sixteen fixed
sets of four per list, every one of them a stock file. Under the
``level-graphics`` feature (``Config/LevelGraphics.asm``,
[../../docs/smw/level-graphics.md](../../docs/smw/level-graphics.md)) a
level may carry a **row of its own**: nine bytes, which file each of FG1,
FG2, BG1, FG3, SP1-SP4 loads, ``$FF`` where the slot keeps the tileset's,
and then which file its animated tiles come out of, ``$FF`` for the game's
own ``GFX33``.
The row's shape, its fragment grammar and the arithmetic the stubs apply are
:mod:`smw_tools.level_graphics`'s; this module is what the editor adds:

- **The document's form.** :attr:`shiny_mushroom.edit.Level.graphics` holds
  the row as bytes -- empty for a level with none -- and :func:`check` is
  what that has to look like. A row of all ``$FF`` and no row are the same
  level, and :func:`is_inherit` says so, so a save writes the tileset's for
  either.
- **The storage.** The level's own container: the row is the ExGFX words of
  the ``.mwl`` its Layer 1 comes out of
  (:attr:`shiny_mushroom.mwl.Container.graphics_row`), written in the same
  rewrite as the streams, so a level sharing a container shares the row.
  The fragment the build reads the rows through is derived from the
  containers by the project build
  (:func:`smw_tools.level_graphics.fragment_from_containers`), and nothing
  else holds a copy.
- **What the dialog offers.** :func:`choices` is the file catalogue a slot
  may name -- the set's files and the ones the project added -- and
  :func:`list_rows` / :func:`tileset_rows` the tileset lists read off the
  cartridge, which is what the header's defaults are greyed in from.

Qt-free, like everything outside :mod:`shiny_mushroom.ui`.
"""

from __future__ import annotations

from collections.abc import Mapping
from pathlib import Path
from typing import TYPE_CHECKING

from shiny_mushroom.header import field_value
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.rom_patches import SLOT_VRAM, gfx_list_rows, tileset_gfx_rows
from smw_tools import graphics as codec
from smw_tools.graphics import SLOT_BYTES, TileFormat
from smw_tools.level_graphics import (
    BYPASS_NO_FILE,
    INHERIT,
    INHERIT_ROW,
    LAYER_SLOTS,
    LEVELS,
    ROW_BYTES,
    UPLOAD_SLOTS,
    LevelGraphics,
    LevelGraphicsError,
    encode,
    rows_from_containers,
)

if TYPE_CHECKING:
    from shiny_mushroom.addresses import Addresses
    from shiny_mushroom.level import Raster
    from shiny_mushroom.project import Project


def check_level(level: int) -> int:
    """``level`` if the table has a row for it, or raise."""
    if not 0 <= level < LEVELS:
        raise LevelGraphicsError(
            f"level {hexnum(level, 3)} is not one of the game's {LEVELS}"
        )
    return level


def check(record: bytes) -> bytes:
    """``record`` if it is the size a row is and names nothing a container
    cannot hold, or raise. ``GFX7F`` is the one number refused: it is what
    Lunar Magic writes for a slot with no file
    (:data:`smw_tools.level_graphics.BYPASS_NO_FILE`), so a row naming it
    would read back as the tileset's."""
    record = bytes(record)
    if len(record) != ROW_BYTES:
        raise LevelGraphicsError(
            f"a level's graphics row is {ROW_BYTES} bytes, not {len(record)}"
        )
    if BYPASS_NO_FILE in record:
        raise LevelGraphicsError(
            f"GFX{BYPASS_NO_FILE:02X} is the number Lunar Magic keeps for a slot "
            "with no file, and a level cannot name it"
        )
    return record


def animated_file(record: bytes) -> int | None:
    """Which file ``record`` names for its animated tiles, or ``None`` for
    the game's own ``GFX33`` -- which an empty record and :data:`INHERIT`
    both mean.

    The row's ninth byte, asked for on its own because it is the one slot
    the canvas cannot swap: the animated tiles reach VRAM three four-tile
    blocks at a time out of a WRAM buffer no capture holds, so a level whose
    animated file has moved is one the emulator has to be asked about again
    (:meth:`shiny_mushroom.ui.main_window.MainWindow._sync_graphics`).
    """
    if not record:
        return None
    held = bytes(record)[UPLOAD_SLOTS]
    return None if held == INHERIT else held


def is_inherit(record: bytes) -> bool:
    """Whether ``record`` names nothing -- empty, or ``$FF`` in every slot --
    which is a level with no row: its container's words all say the
    tileset's."""
    return not record or bytes(record) == INHERIT_ROW


# -- reading the rows out of the containers ----------------------------------


def rows_for(files: Mapping[int, Path]) -> dict[int, bytes]:
    """The row each level carries, by level number, for the levels whose row
    names a file -- ``files`` being each level's Layer 1 container.

    **The editor's one reading of the containers**: whole-project and
    one-level alike (:meth:`shiny_mushroom.project.Project.level_graphics`
    and :meth:`~shiny_mushroom.project.Project.level_graphics_record` are
    both this), so the inherit rule and the sharing -- one container, one
    row, however many level numbers point at it -- are decided in one
    place. What the build's derived fragment names, read the same way
    (:func:`smw_tools.level_graphics.rows_from_containers`).

    Reading every container costs about 600 ms on the DrvFs a Windows
    checkout is under, so the whole-project call is remembered per project
    write rather than taken once per level redraw -- by
    :meth:`shiny_mushroom.project.Project.level_graphics`, not here.
    """
    return {level: encode(held) for level, held in rows_from_containers(files).items()}


def record(files: Mapping[str, int | None] | LevelGraphics) -> bytes:
    """A row's bytes out of a :class:`~smw_tools.level_graphics.LevelGraphics`
    -- or a mapping of slot name to file, ``None`` keeping the tileset's."""
    if isinstance(files, LevelGraphics):
        held = files
    else:
        held = LevelGraphics(**{slot.lower(): file for slot, file in files.items()})
    return encode(held)


# -- what the cartridge says -------------------------------------------------


def list_rows(
    rom: bytes, where: Addresses
) -> tuple[tuple[bytes, ...], tuple[bytes, ...]] | None:
    """The two tileset lists as the image holds them -- ``SpriteGFXList``'s
    26 rows, then ``FGAndBGGFXList``'s -- or ``None`` on a base that
    declares neither (:func:`shiny_mushroom.rom_patches.gfx_list_rows`)."""
    return gfx_list_rows(rom, where=where)


def tileset_rows(
    rom: bytes, where: Addresses, sprite_tileset: int, fg_bg_tileset: int
) -> tuple[bytes, bytes]:
    """The four files ``sprite_tileset`` loads and the four ``fg_bg_tileset``
    does, as the header's two fields would have the stock game load them:
    what :meth:`~shiny_mushroom.edit.Level.effective_graphics` lays the row
    over (:func:`shiny_mushroom.rom_patches.tileset_gfx_rows`)."""
    return tileset_gfx_rows(rom, sprite_tileset, fg_bg_tileset, where=where)


# -- what the slots hold -----------------------------------------------------

#: The palette row a slot's tiles are drawn under in a preview: the
#: header-selected foreground palette for the four layer slots, the first
#: sprite palette for the four sprite ones -- the guess
#: :func:`shiny_mushroom.graphics.default_row` makes, made per *slot* rather
#: than per file, so that an added file in a sprite slot is drawn in sprite
#: colours. A tile's palette is its tilemap entry's, never the file's, so
#: there is no right answer here; there is only a useful one.
LAYER_ROW = 2
SPRITE_ROW = 8

#: Each slot's VRAM address as the console and ``Memory/VRAM.asm`` write it,
#: in *words* -- :data:`shiny_mushroom.rom_patches.SLOT_VRAM` counts the bytes
#: this module reads a capture by.
SLOT_WORDS: tuple[int, ...] = tuple(at // 2 for at in SLOT_VRAM)

#: What the console keeps in the VRAM the eight slots leave between them, as
#: ``(word address, what is there)``. The slots are words ``$0000``-``$1FFF``
#: and ``$6000``-``$7FFF``; the tilemaps and the 2bpp Layer 3 tiles fill the
#: gap, which is why a panel that shows the slots alone steps from ``$1800``
#: to ``$6000``. Named rather than drawn: none of it is a slot's 128 4bpp
#: tiles, and a tilemap is not a picture at all. The map is the
#: ``!Define_SMW_Layer*VRAMLocation`` values in ``SMW/Misc_Defines_SMW.asm``,
#: turned into word addresses by ``SMW/Memory/WRAM_Extended.asm``
#: (``docs/smw/graphics-loading.md``).
OTHER_VRAM: tuple[tuple[int, str], ...] = (
    (0x2000, "Layer 1 tilemap, 64×64"),
    (0x3000, "Layer 2 tilemap, 64×64"),
    (0x4000, "Layer 3 tiles, 2bpp (GFX28-GFX2B)"),
    (0x5000, "Layer 3 tilemap, 64×64"),
    (0x5800, "Mode 7 bosses' Layer 1 tilemap"),
)


#: Where the game DMAs a block of animated tiles, as VRAM *word* addresses:
#: ``DATA_05B93B`` (``SMW/Banks/Bank05.asm``), three destinations per animation
#: slot over the eight ``ROUTINE_SMW_LevelTileAnimations`` selects with
#: ``EffFrame & $07``. The table's entries are offsets from
#: ``!VRAM_SMW_Layer1GFXVRAMLocation``, which is word ``$0000``, so they are
#: read here as they are written there; ``$0000`` is the entry
#: ``ROUTINE_SMW_UploadLevelAnimations`` skips, and the last two rows are the
#: game's own unused ones.
ANIMATION_VRAM: tuple[tuple[int, int, int], ...] = (
    (0x0600, 0x0640, 0x0680),
    (0x0740, 0x0EA0, 0x0800),
    (0x0500, 0x0540, 0x0580),
    (0x05C0, 0x0780, 0x07C0),
    (0x0DA0, 0x06C0, 0x0700),
    (0x04C0, 0x0440, 0x0480),
    (0x0400, 0x0000, 0x0000),
    (0x0000, 0x0000, 0x0000),
)

#: How much one of those DMAs writes: ``$80`` bytes, which is four 4bpp tiles.
ANIMATION_BLOCK = 0x80

#: The one destination ``ROUTINE_SMW_UploadLevelAnimations`` does not write
#: whole: it tests the third of a row's three destinations against ``$0800``
#: and sends that one as two ``$40``-byte halves, the second to ``$0900``, so
#: its four tiles are two here and two a page further on. Only frame 1's third
#: entry is ``$0800``, which is why the value alone names it.
ANIMATION_SPLIT: dict[int, tuple[int, int]] = {0x0800: (0x0800, 0x0900)}


def _animated_tiles() -> tuple[frozenset[int], ...]:
    """:data:`ANIMATED_TILES`, worked out once from the table above."""
    tile = TileFormat.PLANAR_4BPP.tile_bytes
    found: list[set[int]] = [set() for _ in SLOT_VRAM]
    for row in ANIMATION_VRAM:
        for where in row:
            if not where:
                continue  # the entry the uploader skips
            halves = ANIMATION_SPLIT.get(where)
            size = ANIMATION_BLOCK if halves is None else ANIMATION_BLOCK // 2
            for at in halves or (where,):
                start = at * 2  # the table counts words, a slot's run bytes
                slot = next(
                    (
                        index
                        for index, base in enumerate(SLOT_VRAM)
                        if base <= start < base + SLOT_BYTES
                    ),
                    None,
                )
                if slot is None:  # a hack's destination outside the eight
                    continue
                first = (start - SLOT_VRAM[slot]) // tile
                found[slot].update(range(first, first + size // tile))
    return tuple(frozenset(one) for one in found)


#: Which of a slot's 128 tiles the animated tiles own, by slot -- what no file
#: a slot names can put on screen.
#:
#: ``ROUTINE_SMW_LevelTileAnimations`` runs every frame and DMAs three blocks
#: out of ``GFX33`` over the layer slots, so within eight frames of any capture
#: these tiles hold the animation rather than the slot's file: **all 64 tiles
#: of FG1's lower half**, ``$40``-``$7F``, and twelve of FG2. Pointing a slot at
#: another file cannot move them, and neither can repainting that file --
#: :func:`shiny_mushroom.rom_patches.vram_with_graphics` leaves them because the
#: capture no longer agrees with the file being replaced, and a real cartridge
#: overwrites them again on the next frame either way. A window onto VRAM says
#: so rather than letting a reader think the edit failed.
#:
#: The player's own window of SP1 is not here: ``MarioGFXDMA`` writes tiles
#: ``$00``-``$09`` and ``$7F`` of it, which is the same rule and a different
#: table (``docs/smw/graphics-loading.md``).
ANIMATED_TILES: tuple[frozenset[int], ...] = _animated_tiles()


def slot_sheets(
    vram: bytes, cgram: bytes, row: int | None = None
) -> tuple[Raster, ...]:
    """What VRAM holds for each of the eight slots, in the row's own order:
    its 128 tiles as a sixteen-column sheet, under ``row`` of ``cgram`` --
    or, ``None``, under :data:`LAYER_ROW` for the layer slots and
    :data:`SPRITE_ROW` for the sprite ones.

    **Read out of the capture, not out of the files.** This is the VRAM the
    canvas draws the level from, so it is what the level *has*: the
    uploader's 3bpp expansion and its colour mask already applied, the
    animated tiles and the player where the game put them, and a slot the
    editor has pointed somewhere else already swapped
    (:func:`shiny_mushroom.rom_patches.vram_with_graphics`). A capture shorter
    than a slot -- a synthetic one -- is read as zeroes past its end.
    """
    from shiny_mushroom.graphics import raster, scene_rows

    rows = scene_rows(cgram, TileFormat.PLANAR_4BPP)
    sheets = []
    for slot, at in enumerate(SLOT_VRAM):
        held = vram[at : at + SLOT_BYTES].ljust(SLOT_BYTES, b"\x00")
        tiles = codec.decode_tiles(TileFormat.PLANAR_4BPP, held)
        under = row if row is not None else default_row(slot)
        sheets.append(raster(tiles, rows[under].colours))
    return tuple(sheets)


def default_row(slot: int) -> int:
    """Which CGRAM row a slot is drawn under when nobody has picked one.
    The animated tiles are Layer 1/2 tiles like the layer slots' files, and
    are drawn under the same row."""
    return SPRITE_ROW if LAYER_SLOTS <= slot < UPLOAD_SLOTS else LAYER_ROW


# -- what a slot may name ----------------------------------------------------


def choices(project: Project | None) -> list[tuple[int, str, str]]:
    """Every file a slot may name, as ``(number, name, purpose)``: the set's
    own in number order, then every file the project added. What the dialog
    lists; a stock file's purpose is the catalogue's phrase
    (:data:`shiny_mushroom.graphics.PURPOSES`), an added file's says so.
    ``None`` -- no project -- is the stock files alone.

    **The ten files no slot can take are left out**
    (:func:`smw_tools.graphics.fits_a_slot`): the 2bpp Layer 3 files and
    `GFX27` are uploaded another way entirely, the player and the animated
    tiles decompress past what the slot path reads through, and the two
    credits files are half a slot. No tileset a level can select names one of
    them, so nothing a level already loads goes missing -- and an added file
    is a slot's shape by construction.

    Nothing here is priced -- :func:`shiny_mushroom.graphics.files` encodes
    every edited file to say what it costs, and a list of names does not
    need that.
    """
    from shiny_mushroom.graphics import PURPOSES

    out = [
        (number, codec.file_name(number), PURPOSES[number][1])
        for number in codec.FILE_NUMBERS
        if codec.fits_a_slot(number)
    ]
    out.extend(_added_choices(project, slot_shaped=True))
    return out


def animated_choices(project: Project | None) -> list[tuple[int, str, str]]:
    """Every file the animated tiles slot may name, as ``(number, name,
    purpose)`` -- :func:`choices` for the row's ninth byte.

    A different catalogue, because it is a different question. The animated
    tiles are not a VRAM slot: the file is decompressed and expanded into
    WRAM on the way into a level, in the shape the expansion reads, which is
    384 tiles of 3bpp. So the only files here are the ones the project added
    of that shape -- and none of them is offered to the eight, which would
    decompress them past what a slot's path reads through.

    **`GFX33` is not among them.** Naming it and naming nothing are the same
    file, and the row already spells that as :data:`INHERIT`; offering the
    number as well would let a level ask, in the one spelling a cartridge
    without the managed graphics cannot assemble, for exactly what it gets
    for free."""
    return _added_choices(project, slot_shaped=False)


def _added_choices(
    project: Project | None, *, slot_shaped: bool
) -> list[tuple[int, str, str]]:
    """The project's own files of one shape, as :func:`choices` lists them:
    the ones a VRAM slot can load, or the ones only the animated tiles can.

    ``GFX7F`` is a number a container cannot name (:func:`check` says why),
    so a file added under it is not offered whatever its shape.
    """
    if project is None:
        return []
    from smw_tools.packed import shape_for_size

    out = []
    for number, size in sorted(project.added_graphics_sizes().items()):
        shape = shape_for_size(size)
        if number == BYPASS_NO_FILE or shape is None:
            continue
        if shape.fits_a_slot is not slot_shaped:
            continue
        out.append((number, f"GFX{number:02X}", "added file"))
    return out


#: The level modes the game prepares as a Mode 7 boss scene -- ``$09``,
#: ``$0B`` and ``$10``, the three ``SMW_BeginLoadingLevelData_Loop`` loads
#: no objects for. Their uploader sets the FG/BG tileset to ``$FE``/``$FF``
#: and takes the Mode 7 path before the layer hook, and their sprite rows
#: (``$12``, ``$13``, ``$18``) are past the sixteen a row may overlay, so a
#: level in one of them loads what it always did whatever its row says.
MODE7_BOSS_MODES = frozenset({0x09, 0x0B, 0x10})


def takes_a_row(header: bytes) -> bool:
    """Whether a level with this header would ever have its row read: false
    for the Mode 7 boss modes (:data:`MODE7_BOSS_MODES`), where the dialog
    says so rather than offering files the game will not load."""
    return field_value(header, "level_mode") not in MODE7_BOSS_MODES
