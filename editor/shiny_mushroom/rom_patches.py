"""Reading a cartridge image, and the writes that change what it holds.

Byte arithmetic over a ROM and nothing else: every function here takes an image
and an :class:`~shiny_mushroom.addresses.Addresses` and hands back either
what the image says or a ``{offset: bytes}`` patch that would make it say
something else. Nothing here runs the game, holds a core or reads a savestate,
which is what lets the editor's document layer build a patch without an
emulator anywhere near it.

A patch is a mapping from **headerless** image offset to the bytes to write
there. Applying one is the caller's business --
:mod:`shiny_mushroom.cart_patches` assembles them for a document,
:meth:`~shiny_mushroom.emu.smw.CartSession.preview` hands one to a running core
-- and the same mapping means the same thing to both.

**A table is believed only when the role says where it is and the image is
running the code that reads it**; :func:`_hooked` is what asks the second half,
and every relocated-table feature here goes through it.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass
from typing import TYPE_CHECKING

from shiny_mushroom.addresses import (
    CAMERA_LOWEST_Y,
    CAMERA_SETTLED_Y,
    DEFAULT_ADDRESSES,
    ENTRANCE_SCREEN,
    ENTRANCE_X_INDEX,
    ENTRANCE_Y_INDEX,
    FG_POSITION_INDEX,
    FG_POSITION_SHIFT,
    INITIAL_Y_POSITIONS,
    L2_OFFSET_SHIFT,
    L2_POSITION_INDEX,
    L2_SCROLL_SETTINGS,
    LAYER2_IS_BACKGROUND,
    LEVEL_MODE_COUNT,
    LEVEL_SLOTS,
    MAP16_DEF_SIZE,
    MAP16_TILE_COUNT,
    MAX_OBJECT_RECORDS,
    MAX_SPRITE_RECORDS,
    SPRITE_BANK_LENGTH,
    SPRITE_BANK_OPCODE,
    SPRITE_BANK_STORE,
    SPRITE_RECORD_SIZE,
    Addresses,
    _read_long,
    _read_word,
)
from shiny_mushroom.header import HEADER_SIZE
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.layer3 import ROLES as LAYER3_ROLES
from shiny_mushroom.layer3 import SIZE as LAYER3_SIZE
from shiny_mushroom.lunar_magic import ROLES as LUNAR_MAGIC_ROLES
from shiny_mushroom.lunar_magic import SIZE as LUNAR_MAGIC_SIZE
from shiny_mushroom.secondary_entrances import COUNT as SECONDARY_ENTRANCE_COUNT
from shiny_mushroom.secondary_header import SIZE as SECONDARY_HEADER_SIZE
from smw_tools import custom_tiles, graphics, graphics_memory, level_graphics

if TYPE_CHECKING:
    from smw_tools.compression import Family


def _long(address: int) -> tuple[int, int, int]:
    """A 24-bit address as the three bytes a ``JSL``/``JML`` operand needs."""
    return (address & 0xFF, (address >> 8) & 0xFF, (address >> 16) & 0xFF)


#: The opcode every one of the framework's hooks is: ``JSL``, which is what a
#: same-size hook has to be to stand in for the stock code it replaces.
HOOK_OPCODE = 0x22


def _hooked(
    rom: bytes, site: int, *, target: int | None = None, where: Addresses
) -> bool:
    """Whether ``rom`` actually has the hook at ``site`` -- the ``JSL``
    opcode, and where given, the stub address it calls.

    **The rule every feature that moves a table keeps**: a table is believed
    only when the role says where it is *and* the image is running the code
    that reads it. The role comes from the project's build -- its symbol
    file for where, its build record for which features
    (:attr:`shiny_mushroom.project.Project.features`) -- so a switch moved
    since the last build already declares nothing. What is left is the image
    disagreeing with that record: a cartridge rebuilt elsewhere or put back
    by hand, and a build whose symbol file has gone, where the declared
    literals answer for a layout nobody assembled. The stock code is then
    the truth, and patching a table the game does not read would write over
    whatever the level bank holds instead.

    ``False`` for a site outside the image, so an address that does not
    reach this cartridge is the same answer as a cartridge without the hook.
    """
    try:
        at = where.offset(site)
    except ValueError:
        return False
    hook = bytes((HOOK_OPCODE,) if target is None else (HOOK_OPCODE, *_long(target)))
    return rom[at : at + len(hook)] == hook


#: How far above the player's feet :data:`PLAYER_Y` sits, in pixels.
#:
#: **It is not his top-left corner and it is not where he stands**, which is the
#: trap: it is a fixed point 32 pixels above the soles of his shoes, and the
#: game keeps it there whatever his powerup is and whether or not he is
#: crouching -- a big Mario and a small one standing on the same floor hold the
#: same value. ``!RAM_SMW_Player_YPosLo`` in the memory map says so, and a load
#: of level ``$004`` measures it: ``$0096`` reads ``352`` the instant the loader
#: finishes and still reads ``352`` two seconds later, with the floor he is
#: standing on at ``384``.
#:
#: So it is a coordinate that has to be converted at both edges. Anything about
#: where the player *stands* -- a block someone clicked, a floor -- is 32 pixels
#: below one of these, and the entrance tables :func:`entrance_patch` writes
#: hold this value rather than that one, because the loader copies them straight
#: into ``$0096``.
#:
#: Riding Yoshi moves the point another 16 pixels up, which does not arise here:
#: nothing the editor reads or writes happens with a Yoshi under him.
PLAYER_FEET_OFFSET = 32


@dataclass(frozen=True)
class PlayerPosition:
    """Where the player is, in level pixels and in the game's own terms.

    The pair ``$7E0094``/``$7E0096`` holds, which is **not** the floor he stands
    on: ``y`` is :data:`PLAYER_FEET_OFFSET` above his feet. This class exists
    because that distinction is invisible in a ``tuple[int, int]`` and wrong in
    a way nothing catches -- a floor passed where a position was meant draws the
    marker two blocks into the air, and written to the cartridge it starts a
    test run two blocks inside the ground.

    So the two spellings are named. :meth:`standing_on` is the only way in from
    a floor, :attr:`feet` the only way back out, and everything in between --
    the snapshot's spawn, a middle-click override,
    :func:`entrance_patch`, :func:`~shiny_mushroom.sprites.player_plane` --
    passes one of these around and cannot mean the other by accident.
    """

    x: int
    y: int

    @classmethod
    def standing_on(cls, x: int, floor: int) -> PlayerPosition:
        """Where a player whose feet are at ``floor`` is positioned."""
        return cls(x, floor - PLAYER_FEET_OFFSET)

    @property
    def feet(self) -> int:
        """The floor line he stands on."""
        return self.y + PLAYER_FEET_OFFSET


def lorom_offset(snes_address: int) -> int:
    """Translate a CPU address to an offset in the headerless image, in the
    **default base**.

    How an address reaches the image is a cartridge-level decision a
    restructured base can answer differently, so this is
    :meth:`Addresses.offset` for the one base a caller with no project has. The
    name is kept because it says what it does for the base the editor has by
    default.
    """
    return DEFAULT_ADDRESSES.offset(snes_address)


#: One bank's slice of the image, in the default base. A stream read through a
#: 16-bit pointer cannot reach past the end of one.
BANK_SIZE = DEFAULT_ADDRESSES.bank_size

#: The shortest run of ``$FF`` :func:`free_space` will hand out, whatever the
#: caller asked for. A short run of ``$FF`` turns up inside ordinary data all the
#: time; a long one is the build's freespace fill, and telling them apart is the
#: only thing this number does.
FREE_RUN_MINIMUM = 64


def snes_address(offset: int) -> int:
    """Translate an offset in the headerless image back to a CPU address, in the
    **default base**.

    The inverse of :func:`lorom_offset`, and needed as soon as anything *writes*
    a pointer rather than following one: a relocated stream has to be named to
    the game in the game's own coordinates.
    """
    return DEFAULT_ADDRESSES.address(offset)


#: How long a copier header is. Exactly this, always: the header a floppy
#: copier wrote is a fixed block, not a length field.
COPIER_HEADER_SIZE = 512


def has_copier_header(image: bytes) -> bool:
    """Whether ``image`` carries a copier header.

    Asked of its **length** and nothing else: nothing reads what is in the
    block, here or in an emulator. The rule is
    :func:`smw_tools.rom_image.strip_copier_header`'s -- a cartridge is a whole
    number of KiB, so a file 512 bytes over a KiB boundary carries one -- and
    that is where the reason it is *not* the narrower "512 bytes over a 32 KB
    bank" is written down: the narrower test misses the header on any image
    whose payload is not a whole number of banks.

    An image that is nothing but the header is not one, because there would be
    no cartridge left underneath it.
    """
    return (
        len(image) > COPIER_HEADER_SIZE and (len(image) & 0x3FF) == COPIER_HEADER_SIZE
    )


def headerless(image: bytes) -> bytes:
    """A cartridge image with any copier header taken off the front.

    Every offset in this module is into the **headerless** image, which is what
    the emulator's ``SNES_PRG_ROM`` holds -- Mesen strips the header as it loads.
    A ``.smc`` dump read straight off disk still has it, and 512 bytes of skew
    turns a patch into an edit of whatever happens to be there.
    """
    return image[COPIER_HEADER_SIZE:] if has_copier_header(image) else image


def headered(image: bytes) -> bytes:
    """``image`` with a copier header on the front, adding one if it has none.

    The inverse of :func:`headerless`, for the one direction that is not the
    editor's own: something outside it wants the older spelling of the same
    cartridge. An image that already has one is handed back as it is, because
    that is what was asked for.

    **The 512 bytes added are zero.** What detects a header is the length --
    :func:`has_copier_header` and every emulator ask that and only that -- and
    the fields the block once held describe a floppy copier's idea of the dump,
    which no cartridge is.
    """
    return image if has_copier_header(image) else bytes(COPIER_HEADER_SIZE) + image


def layer1_base(rom: bytes, level: int, *, where: Addresses) -> int:
    """Where ``level``'s Layer 1 data starts, as an offset into the image.

    Resolved the way the game resolves it -- through the cartridge's own pointer
    table -- rather than from a cached copy in RAM, so a patched table is
    followed like any other edit. The running pointer at ``$7E0065`` is no use
    for this: the loader advances it as it reads, so by the time a load is over
    it points past the data.

    The handful of levels the cart resolves dynamically rather than through the
    table -- Chocolate Island 2 picks a sub-level from the player's progress --
    resolve here to the entry the table holds, which is not necessarily the one
    a given load used.
    """
    entry = where.offset(where.layer1_pointers + level * 3)
    return where.offset(_read_long(rom, entry))


def layer2_is_background(rom: bytes, level: int, *, where: Addresses) -> bool:
    """Whether ``level``'s Layer 2 is a background rather than an object stream.

    One byte of the cartridge decides it -- the bank of the Layer 2 pointer,
    ``$FF`` for a background -- and it has to be read here rather than out of
    the loaded machine, because ``LoadSublevel`` replaces that bank with the
    background data's own as soon as it has tested it. After a load there is
    nothing in RAM still saying which kind the level had.
    """
    entry = where.offset(where.layer2_pointers + level * 3)
    return rom[entry + 2] == LAYER2_IS_BACKGROUND


def layer2_level_base(rom: bytes, level: int, *, where: Addresses) -> int | None:
    """Where ``level``'s Layer 2 *level data* starts, as an offset into the
    image -- or ``None`` when its Layer 2 is a background instead.

    The five header bytes first, exactly as :func:`layer1_base` answers for
    Layer 1: the pointer addresses them and the loader steps over them with an
    ``ADC #$05`` before it reads a record. The address is what every level
    sharing this Layer 2 resolves to, which is what makes it the stream's
    identity -- eight level numbers reach the one that level ``$0C4``'s
    container holds.
    """
    entry = where.offset(where.layer2_pointers + level * 3)
    if len(rom) < entry + 3 or rom[entry + 2] == LAYER2_IS_BACKGROUND:
        return None
    return where.offset(_read_long(rom, entry))


#: The one FG/BG tileset whose Layer 2 *level* is drawn a palette row higher
#: than its Map16 definitions say -- see
#: :meth:`LevelSnapshot.layer2_definition`. Tileset ``$03`` is Underground 1,
#: and the cave levels built on it are where the rule shows.
LAYER2_PALETTE_TILESET = 0x03

#: What that costs a tilemap word's high byte: bit 12, the top bit of the
#: three palette bits, so the palette row goes up by four.
LAYER2_PALETTE_BIT = 0x10


#: The bank a Layer 2 background pointer's 16 bits are read in. The pointer
#: table's bank byte is spent saying "background" (``$FF``), so the real bank
#: is hardcoded in the loader -- ``LDA #SMW_Backgrounds_Layer2>>16`` -- and has
#: to be hardcoded here to match it.
LAYER2_BG_BANK = 0x0C


def layer2_background_base(rom: bytes, level: int, *, where: Addresses) -> int | None:
    """Where ``level``'s Layer 2 background stream starts, as an offset into
    the image -- or ``None`` when its Layer 2 is an object stream.

    The address every level sharing the background resolves to the same way,
    which is what makes it the background's identity: the stream has no name
    of its own in the cartridge, only a position.
    """
    entry = where.offset(where.layer2_pointers + level * 3)
    if len(rom) < entry + 3 or rom[entry + 2] != LAYER2_IS_BACKGROUND:
        return None
    return where.offset((LAYER2_BG_BANK << 16) | _read_word(rom, entry))


def layer2_background_patch(
    rom: bytes, level: int, tilemap: bytes, *, where: Addresses
) -> dict[int, bytes] | None:
    """``level``'s Layer 2 background as ``tilemap``, re-encoded in place.

    ``tilemap`` is the pattern's low bytes, exactly as
    :attr:`LevelSnapshot.layer2_low` carries them and the document holds them.
    The stream is LC_RLE1 in ROM and its start is an address other levels'
    pointers share, so it can only be rewritten **in place**: an encoding that
    has outgrown the shipped stream's bytes would overwrite its neighbour.
    That case returns ``None`` -- the edit stands, a build re-places the
    streams, and the caller says the preview could not carry it. ``{}`` means
    there is nothing to patch: the image already decodes to ``tilemap``, or it
    is a stub too short to hold a stream at all.
    """
    from smw_tools.rle import CorruptStream, Variant, decompress, repack

    base = layer2_background_base(rom, level, where=where)
    if base is None:
        return {}
    window = rom[base : base + 2 * len(tilemap)]
    if len(window) < len(tilemap) // 4:
        return {}  # a byte-map stub, not a cartridge
    try:
        # Unsized: the shipped streams decode to $360 *or* $361 bytes -- the
        # odd byte is junk past the pattern -- so the terminator is the truth.
        decoded, consumed = decompress(window, Variant.RLE1)
    except CorruptStream:
        return None
    if decoded[: len(tilemap)] == tilemap:
        return {}
    encoded = repack(window[:consumed], tilemap, Variant.RLE1, size=None, smallest=True)
    if len(encoded) > consumed:
        return None
    return {base: encoded}


def levels_sharing_layer2(rom: bytes, level: int, *, where: Addresses) -> int:
    """How many *other* levels point at the same Layer 2 data as ``level``.

    What a background edit's save message needs: the stream is shared, and
    "this also changes N levels" is a fact of the pointer table alone.
    """
    entry = where.offset(where.layer2_pointers + level * 3)
    mine = rom[entry : entry + 3]
    count = 0
    for other in range(LEVEL_SLOTS):
        if other == level:
            continue
        at = where.offset(where.layer2_pointers + other * 3)
        if rom[at : at + 3] == mine:
            count += 1
    return count


def layer2_entry_patch(
    rom: bytes, level: int, address: int, *, background: bool, where: Addresses
) -> dict[int, bytes]:
    """Point ``level``'s Layer 2 entry at ``address``.

    Three bytes of the pointer table, which is all a Layer 2 repoint is to the
    cartridge -- kind and address travel together, since the bank byte is what
    says "background". ``address`` is the data's 24-bit SNES address, which for
    the editor comes from the project build's own symbol file: the file that
    says what the assembler resolved for the very image being patched.

    A background entry spends its bank byte on the ``$FF`` marker and the
    loader hardcodes the real bank, so an address outside
    :data:`LAYER2_BG_BANK` cannot be written as one -- that case patches
    nothing, as does an entry that already matches and a stub too short to
    hold the table.
    """
    if background:
        if address >> 16 != LAYER2_BG_BANK:
            return {}
        entry = bytes([address & 0xFF, (address >> 8) & 0xFF, LAYER2_IS_BACKGROUND])
    else:
        entry = (address & 0xFFFFFF).to_bytes(3, "little")
    at = where.offset(where.layer2_pointers + level * 3)
    if len(rom) < at + 3 or bytes(rom[at : at + 3]) == entry:
        return {}
    return {at: entry}


def sprite_data_bank(rom: bytes, *, where: Addresses) -> int | None:
    """Which bank this cartridge keeps sprite data in, or ``None`` if it cannot
    be told.

    Read from the instruction that supplies it rather than assumed to be
    ``$07``, because that instruction is exactly what a hack patches to move
    sprite data somewhere bigger -- see :data:`SPRITE_BANK_INSTRUCTION`. The
    pointer table itself is only two bytes an entry and cannot say.

    **The instruction is checked before its operand is believed**, and that is
    the whole reason this returns an option rather than a number. A patch that
    merely retunes the bank leaves ``LDA #imm / STA $D0`` in place and the new
    bank is simply there to read. A patch that *hijacks* the site -- which is
    what Lunar Magic does when it relocates sprite data wholesale -- writes a
    ``JSL`` over it, and the byte after that opcode is half a target address
    rather than a bank. Reading it anyway would resolve every sprite pointer in
    the cartridge into nonsense and report it with a straight face.

    ``None`` therefore means "this cannot be answered from the bytes", which for
    a hijacked cart is the truth: where the data went is decided by code that
    only running it will reveal. A level that has actually been loaded is not
    subject to any of this -- see :data:`SPRITE_LIST_POINTER`.
    """
    at = where.offset(where.sprite_bank_instruction)
    instruction = rom[at : at + SPRITE_BANK_LENGTH]
    if len(instruction) < SPRITE_BANK_LENGTH:
        return None
    opcode, bank, *store = instruction
    if opcode != SPRITE_BANK_OPCODE or tuple(store) != SPRITE_BANK_STORE:
        return None
    return bank


def sprite_base(rom: bytes, level: int, *, where: Addresses) -> int:
    """Where ``level``'s sprite stream starts, as an offset into the image.

    The table's counterpart to :func:`layer1_base`, and the way to reach a
    sprite stream for a level **nothing has loaded** -- which is what indexing
    the whole cartridge needs. A level that is on screen has a better source in
    :data:`SPRITE_LIST_POINTER`, because the game resolved that one itself.

    The stored word is an address with its bank left out, exactly as
    ``SMW_SpecifySublevelToLoad_CODE_05D8B7`` reads it, and the bank comes from
    :func:`sprite_data_bank` -- so a cartridge whose sprite data has been moved
    out of bank ``$07`` resolves to where it actually is.

    Raises ``ValueError`` when the bank cannot be determined, rather than
    falling back to ``$07`` and pointing every level at whatever now lives
    there.
    """
    bank = sprite_list_bank(rom, level, where=where)
    if bank is None:
        raise ValueError(
            "this cartridge's sprite data bank cannot be read: the "
            f"instruction at {hexnum(where.sprite_bank_instruction, 6)} that "
            "supplies it is not the game's own"
        )
    entry = where.offset(where.sprite_pointers + level * 2)
    return where.offset((bank << 16) | _read_word(rom, entry))


#: The role the managed level banks declare their per-level table under
#: (:data:`smw_tools.features.MANAGED_LEVEL_MEMORY`); the ``JSL`` they hook
#: over the bank instruction is :data:`HOOK_OPCODE`, like every other.
SPRITE_BANK_TABLE_ROLE = "level_sprite_banks"


def sprite_list_bank(rom: bytes, level: int, *, where: Addresses) -> int | None:
    """Which bank ``level``'s sprite list is in, or ``None`` if it cannot be
    told.

    :func:`sprite_data_bank`'s one bank for every level, unless the
    cartridge keeps a bank *per* level: the managed level banks
    (``Config/ManagedLevelMemory.asm``) hook the bank instruction with a
    ``JSL`` to a stub that reads one byte a level off a table at the level
    bank's tail, and a base with that feature declares the table under
    :data:`SPRITE_BANK_TABLE_ROLE`. Both halves have to be there before the
    table is believed -- the role, and the hook actually in the image
    (:func:`_hooked`) -- and the stock instruction is the truth otherwise.
    """
    table = where.roles.get(SPRITE_BANK_TABLE_ROLE)
    if table is not None and _hooked(rom, where.sprite_bank_instruction, where=where):
        entry = where.offset(table) + level
        if entry < len(rom):
            return rom[entry]
    return sprite_data_bank(rom, where=where)


#: The per-level graphics (``Config/LevelGraphics.asm``,
#: :data:`smw_tools.features.LEVEL_GRAPHICS`): the role the rows are
#: declared under -- one eight-byte row per level number at the level
#: bank's head, with the ``$200`` animated files behind them -- and how the
#: hook that reads them is found. The two
#: tileset lists ``ROUTINE_SMW_UploadGraphicsFiles`` reads a level's files
#: out of are roles of their own, 26 rows of four file numbers each; the
#: two hook sites are the nine-byte loops that copy a tileset's row out of
#: each list, and both sit a fixed distance past the FG/BG list, since the
#: code between is the same code on every target. Under the feature the
#: sprite loop is a ``JSL`` to the sprite stub, which is the first byte
#: past both tables (:data:`smw_tools.level_graphics.BLOCK_BYTES` less its
#: stubs), and five
#: NOPs -- the hook :func:`level_graphics_rows` looks for, the way
#: :func:`managed_graphics` looks for the decompressor's.
LEVEL_GRAPHICS_ROWS_ROLE = level_graphics.ROLE
SPRITE_GFX_LIST_ROLE = "sprite_gfx_list"
FGBG_GFX_LIST_ROLE = "fgbg_gfx_list"
GFX_LIST_ROWS = 26
GFX_LIST_ROW_BYTES = 4
#: The sprite loop's site and the FG/BG loop's, past the FG/BG list:
#: ``$00A9E7`` and ``$00AA28`` past ``$00A92B`` on ``U``.
LEVEL_GRAPHICS_SPRITE_HOOK = 0xBC
LEVEL_GRAPHICS_LAYER_HOOK = 0xFD

#: Where each of a level's eight graphics slots lands in VRAM, in the row's
#: own order -- FG1, FG2, BG1, FG3, then SP1-SP4.
#:
#: ``DATA_00A9D6`` and ``DATA_00A9D2`` (``SMW/Banks/Bank00.asm``) hold the high
#: byte of each destination's VRAM *word* address -- ``$18,$10,$08,$00`` and
#: ``$78,$70,$68,$60`` -- read with the loop index counting down from 3, which
#: is what puts a list's entry 0 in the first slot. Doubled here, because this
#: module indexes VRAM by byte.
SLOT_VRAM = (0x0000, 0x1000, 0x2000, 0x3000, 0xC000, 0xD000, 0xE000, 0xF000)


def vram_with_graphics(vram: bytes, swaps: Iterable[tuple[int, bytes, bytes]]) -> bytes:
    """``vram`` with slots swapped from one file to another: ``swaps`` is
    ``(slot, held, wanted)``, each file in its VRAM form
    (:func:`smw_tools.graphics.vram_bytes`).

    **Written tile by tile, and only where the capture still holds the file
    being replaced.** A slot's run of VRAM is not the file alone by the time a
    capture is taken: the animated tiles are uploaded over a window of FG1 and
    FG2 every frame, and the player over the front of SP1 -- about half of FG1
    on a stock cartridge. A byte that no longer agrees with the outgoing file
    belongs to whatever wrote it last, and swapping the file is no reason to
    take that away, so it is left exactly as captured. Which needs no table of
    where those windows are, and stays right on a cartridge that moved them.
    """
    out = bytearray(vram)
    tile = graphics.TileFormat.PLANAR_4BPP.tile_bytes
    for slot, held, wanted in swaps:
        at = SLOT_VRAM[slot]
        for start in range(0, graphics.SLOT_BYTES, tile):
            here = at + start
            if out[here : here + tile] == held[start : start + tile]:
                out[here : here + tile] = wanted[start : start + tile]
    return bytes(out)


def gfx_list_rows(
    rom: bytes, *, where: Addresses
) -> tuple[tuple[bytes, ...], tuple[bytes, ...]] | None:
    """The two tileset lists as the image holds them -- ``SpriteGFXList``'s
    26 rows, then ``FGAndBGGFXList``'s -- each row the four file numbers a
    tileset loads in slot order; ``None`` on a base that declares neither.
    Read off the cartridge rather than the disassembly, since the image is
    the thing a preview patches."""
    sprites = where.roles.get(SPRITE_GFX_LIST_ROLE)
    layers = where.roles.get(FGBG_GFX_LIST_ROLE)
    if sprites is None or layers is None:
        return None
    size = GFX_LIST_ROWS * GFX_LIST_ROW_BYTES

    def rows(address: int) -> tuple[bytes, ...]:
        at = where.offset(address)
        if at + size > len(rom):
            raise ValueError(f"the image ends inside the list at {hexnum(address, 6)}")
        return tuple(
            bytes(rom[at + row * GFX_LIST_ROW_BYTES :][:GFX_LIST_ROW_BYTES])
            for row in range(GFX_LIST_ROWS)
        )

    return rows(sprites), rows(layers)


def tileset_gfx_rows(
    rom: bytes, sprite_tileset: int, fg_bg_tileset: int, *, where: Addresses
) -> tuple[bytes, bytes]:
    """The four files ``sprite_tileset``'s row of ``SpriteGFXList`` names and
    the four ``fg_bg_tileset``'s row of ``FGAndBGGFXList`` does -- what a
    level with those header fields loads on a stock cartridge, and what
    :func:`smw_tools.level_graphics.effective` lays a row over. A tileset
    past the lists' 26 rows is refused: the header's nibbles can name one
    the game reads garbage for, and a caller wants to know."""
    lists = gfx_list_rows(rom, where=where)
    if lists is None:
        raise ValueError("this base declares no tileset graphics lists")
    sprites, layers = lists
    if not (0 <= sprite_tileset < GFX_LIST_ROWS and 0 <= fg_bg_tileset < GFX_LIST_ROWS):
        raise ValueError(
            f"tileset {sprite_tileset:#x}/{fg_bg_tileset:#x} is past the lists' "
            f"{GFX_LIST_ROWS} rows"
        )
    return sprites[sprite_tileset], layers[fg_bg_tileset]


def level_graphics_hook_sites(where: Addresses) -> tuple[int, int] | None:
    """Where the two tileset loops are, as CPU addresses -- the sprite list's
    then the FG/BG list's -- or the JSLs the feature puts over them;
    ``None`` on a base that declares no FG/BG list."""
    layers = where.roles.get(FGBG_GFX_LIST_ROLE)
    if layers is None:
        return None
    return layers + LEVEL_GRAPHICS_SPRITE_HOOK, layers + LEVEL_GRAPHICS_LAYER_HOOK


def level_graphics_rows(rom: bytes, *, where: Addresses) -> int | None:
    """Where the per-level graphics rows begin, as an offset into the image,
    when the image is one the game reads them from -- or ``None``.

    Both halves have to be there before the rows are believed, the rule
    :func:`_hooked` states: the role, which a base with the feature
    declares, **and** the hook in the image -- the ``JSL`` to the sprite
    stub, the first byte past the rows and the animated files behind them,
    at the sprite loop's site. The stock loops load the tilesets' files
    otherwise.
    """
    rows = where.roles.get(LEVEL_GRAPHICS_ROWS_ROLE)
    sites = level_graphics_hook_sites(where)
    if rows is None or sites is None:
        return None
    stub = rows + level_graphics.ROWS_BYTES + level_graphics.ANIMATED_BYTES
    if not _hooked(rom, sites[0], target=stub, where=where):
        return None
    try:
        head = where.offset(rows)
    except ValueError:
        return None
    if head + level_graphics.ROWS_BYTES + level_graphics.ANIMATED_BYTES > len(rom):
        return None
    return head


def level_graphics_row(rom: bytes, level: int, *, where: Addresses) -> bytes:
    """``level``'s nine-byte graphics row as the image holds it -- empty
    where the image has no rows, and empty for a row that is all ``$FF``,
    since that is a level with no row of its own. The baseline a preview
    patch is measured against, and the fallback source for a session with
    no project to ask.

    **Read out of the two tables the cartridge keeps**: the eight slots out
    of the level's row, and the animated tiles out of the level's byte of
    the table behind them (:func:`_level_graphics_at`)."""
    head = level_graphics_rows(rom, where=where)
    if head is None:
        return b""
    slots, animated = _level_graphics_at(head, level)
    row = bytes(rom[slots : slots + level_graphics.TABLE_ROW_BYTES]) + bytes(
        rom[animated : animated + 1]
    )
    return b"" if row == INHERIT_ROW else row


def _level_graphics_at(head: int, level: int) -> tuple[int, int]:
    """Where ``level``'s eight slot bytes are and where its animated file
    byte is, as offsets into an image whose rows begin at ``head``."""
    level_graphics_check_level(level)
    return (
        head + level * level_graphics.TABLE_ROW_BYTES,
        head + level_graphics.ROWS_BYTES + level,
    )


def level_graphics_patch(
    rom: bytes, level: int, record: bytes, *, where: Addresses
) -> dict[int, bytes]:
    """The cartridge edit that gives ``level`` this graphics row -- empty
    ``record`` being no row, which is a row of ``$FF``. Always safe to patch
    in place, exactly as a secondary header is: the table holds one row per
    level and nothing after it can move. ``{}`` where the image already
    holds the row, or where it has no rows at all -- the caller decides
    what to say about that (:func:`level_graphics_rows`)."""
    return level_graphics_table_patch(rom, {level: record}, where=where)


def level_graphics_table_patch(
    rom: bytes, rows: Mapping[int, bytes], *, where: Addresses
) -> dict[int, bytes]:
    """:func:`level_graphics_patch` for a set of levels at once: the rows
    ``rows`` names, over the image's own, and nothing for a level it leaves
    out.

    The whole answer in one pass -- where the rows are is looked up once
    rather than per level -- for the caller that patches the **whole table**
    (:func:`~shiny_mushroom.cart_patches.saved_level_graphics_patch`): the
    project's rows, and ``$FF`` for every level it no longer holds, which is
    512 rows on every level redraw.

    A row lands in two places, since the cartridge keeps it in two tables,
    and each is patched only where it differs.
    """
    head = level_graphics_rows(rom, where=where)
    if head is None:
        return {}
    patches: dict[int, bytes] = {}
    for level, record in rows.items():
        row = INHERIT_ROW if not record else bytes(record)
        if len(row) != level_graphics.ROW_BYTES:
            raise ValueError(
                f"a level's graphics row is {level_graphics.ROW_BYTES} bytes, "
                f"not {len(row)}"
            )
        slots_at, animated_at = _level_graphics_at(head, level)
        slots = row[: level_graphics.TABLE_ROW_BYTES]
        animated = row[level_graphics.TABLE_ROW_BYTES :]
        if rom[slots_at : slots_at + len(slots)] != slots:
            patches[slots_at] = slots
        if rom[animated_at : animated_at + 1] != animated:
            patches[animated_at] = animated
    return patches


#: A row that keeps every slot's file the tileset's: no row at all.
INHERIT_ROW = bytes([level_graphics.INHERIT]) * level_graphics.ROW_BYTES


def level_graphics_check_level(level: int) -> None:
    if not 0 <= level < level_graphics.LEVELS:
        raise ValueError(f"level {level:#05x} has no graphics row")


def vertical_level(rom: bytes, level_mode: int, *, where: Addresses) -> bool:
    """Whether a level in this level mode runs down rather than across.

    The level's header does not say. Header byte 1 holds a **level mode**, and
    the mode is an index into ``VerticalTable`` in the cartridge -- so the answer
    is a byte of the ROM, and a hack that retunes a mode changes it. See
    :data:`VERTICAL_TABLE`.
    """
    entry = where.offset(where.vertical_table) + (level_mode % LEVEL_MODE_COUNT)
    return bool(rom[entry] & 0x01)


#: Bytes per object record, and the exceptions: extended object ``$00``, the
#: screen exit, reads a fourth byte, and Lunar Magic's direct-tile objects
#: and its reserved one read up to :data:`smw_tools.custom_tiles.CONDITIONAL_SIZE`
#: (:func:`smw_tools.custom_tiles.record_size`). Walking three at a time
#: desynchronises on the first level that has an exit in it, which is most of
#: them, and on the first custom tile placed -- which is why one walk answers
#: for both :func:`object_stream` and :mod:`shiny_mushroom.emu.footprints`.
OBJECT_RECORD_SIZE = 3
OBJECT_SCREEN_EXIT_SIZE = 4
OBJECT_TERMINATOR = 0xFF


def record_offsets(stream: bytes) -> list[int]:
    """Where each record starts, and where the terminator is.

    The same walk the loop makes, which is why the screen exit's fourth byte
    matters: getting the stride wrong shifts every boundary after it.

    The last entry is the terminator rather than a record. It is kept because it
    closes the final record's window -- there has to be a boundary after the
    last object as well as before it.
    """
    offsets: list[int] = []
    at = 0
    while at + OBJECT_RECORD_SIZE <= len(stream):
        first, second, settings = stream[at : at + OBJECT_RECORD_SIZE]
        if first == OBJECT_TERMINATOR:
            break
        offsets.append(at)
        number = ((first & 0x60) >> 1) | (second >> 4)
        if number == 0:
            size = OBJECT_SCREEN_EXIT_SIZE if settings == 0x00 else OBJECT_RECORD_SIZE
        else:
            # A direct-tile object's length is in its number, and a 27's in
            # its fourth byte too -- the stride
            # :func:`shiny_mushroom.objects.parse_objects` takes, which this
            # has to match or the two disagree about where every record after
            # it begins.
            fourth = stream[at + 3] if at + 3 < len(stream) else None
            size = custom_tiles.record_size(number, settings, fourth)
        at += size
    offsets.append(at)
    return offsets


def object_stream(rom: bytes, base: int) -> bytes:
    """Copy an object stream out of the cartridge, first record to terminator.

    Walked rather than sliced at a fixed length because only the walk finds the
    end, and only a walk that knows about the screen exit's fourth byte stays
    aligned while doing it -- three at a time desynchronises on the first level
    that has an exit in it, and every record after that reads as garbage.

    It is :func:`record_offsets`' walk, which
    :mod:`shiny_mushroom.emu.footprints` buckets writes by as well, so a
    stream copied here and the footprints attributed there cannot disagree
    about where a record begins.
    The window it is given is :data:`MAX_OBJECT_RECORDS` of the longest record
    wide, which bounds a stream whose terminator is missing rather than
    limiting the format.
    """
    window = rom[base : base + MAX_OBJECT_RECORDS * custom_tiles.CONDITIONAL_SIZE]
    return window[: record_offsets(window)[-1] + 1]


def _layer2_level_stream(
    rom: bytes, level: int, *, where: Addresses
) -> tuple[bytes, bytes] | None:
    """``level``'s Layer 2 as ``(its five header bytes, its object stream)``,
    or ``None`` when its Layer 2 is a background instead.

    A stub image too short to hold either answers ``None`` as well: a byte-map
    view is not a cartridge, and reading a stream out of one would produce
    records rather than say so.
    """
    base = layer2_level_base(rom, level, where=where)
    if base is None or len(rom) < base + HEADER_SIZE + 1:
        return None
    return rom[base : base + HEADER_SIZE], object_stream(rom, base + HEADER_SIZE)


def sprite_stream(rom: bytes, base: int, counts: Mapping[int, int] = {}) -> bytes:
    """Copy a sprite stream out of the cartridge, header byte to terminator.

    ``base`` is where the stream starts -- from :func:`sprite_base` for a level
    read off the cartridge, or from the pointer the game resolved for one that
    has been loaded. The walk is the same either way, and having one of it is
    the point: where a stream *ends* is a fact about the format, not about which
    of the two pointers led to it.

    ``counts`` is the custom sprites' extra-byte stride, from
    :func:`extra_byte_counts` -- the walk has to step over a custom record's
    extra bytes exactly as the loader does, or a byte of somebody's data
    reads as a terminator, or worse, as the next record's first byte.
    """
    end = base + 1  # past the header byte: memory setting and buoyancy
    limit = end + MAX_SPRITE_RECORDS * SPRITE_RECORD_SIZE
    while end < len(rom) and end < limit and rom[end] != 0xFF:
        first = rom[end]
        number = rom[min(end + 2, len(rom) - 1)]
        end += SPRITE_RECORD_SIZE
        if counts and first & 0x08 and number < 0xC9 and number != 0x7B:
            end += counts.get(number, 0)
    return rom[base : end + 1]


def extra_byte_counts(rom: bytes, *, where: Addresses) -> dict[int, int]:
    """The custom sprites' extra-byte counts, off the cartridge's own table.

    The built cartridge is the authority on its own stride -- the count
    table sits at a declared address in the sprite bank
    (``custom_sprite_extra_byte_count``) -- so every walker over this image's
    streams reads the same figures the loader does. Empty on a build without
    the feature, which is also the answer that leaves every walk exactly as
    it was.
    """
    address = where.roles.get("custom_sprite_extra_byte_count")
    if address is None:
        return {}
    offset = where.offset(address)
    table = rom[offset : offset + 0x100]
    if len(table) < 0x100:
        return {}
    return {number: table[number] for number in range(0x100) if table[number]}


def background_definitions(rom: bytes, *, where: Addresses) -> bytes:
    """The Map16 definitions every Layer 2 background is drawn from.

    A fixed table rather than a resolved one, and the only definitions in the
    editor that are not the loader's own work -- see :data:`MAP16_BG_DEFS` for
    why the loader's copy of them is gone by capture time.
    """
    base = where.offset(where.map16_bg_defs)
    return rom[base : base + MAP16_TILE_COUNT * MAP16_DEF_SIZE]


def header_patch(
    rom: bytes,
    level: int,
    header: bytes,
    *,
    where: Addresses,
) -> dict[int, bytes]:
    """The cartridge edit that gives ``level`` this header.

    The seam an in-memory edit crosses to reach a running cart: the editor holds
    a level's header as five bytes, and this says where in the image they go.
    Nothing is written here -- the result is a patch map for
    :meth:`SmwLevelLoader.load` or
    :meth:`~shiny_mushroom.emu.play.PlaySession.enter`, both of which apply it to
    the core's copy and to nothing on disk.

    A header is the one part of a level that is always safe to patch in place:
    it is exactly five bytes and it is the first five, so nothing after it
    moves. An object or sprite stream is not -- it is variable length, and a
    longer one would run into whatever the cart put next.
    """
    if len(header) != HEADER_SIZE:
        raise ValueError(f"a level header is {HEADER_SIZE} bytes, not {len(header)}")
    return {layer1_base(rom, level, where=where): bytes(header)}


def secondary_header_tables(where: Addresses) -> tuple[int, int, int, int]:
    """The four secondary-header tables' addresses, in table order -- the
    order :mod:`shiny_mushroom.secondary_header` keeps its four bytes in."""
    return (
        where.secondary_header_y,
        where.secondary_header_x,
        where.secondary_header_fg_position,
        where.secondary_header_entrance,
    )


def lunar_magic_tables(where: Addresses) -> tuple[int, int, int, int] | None:
    """The four Lunar Magic tables' addresses, in table order -- the order
    :mod:`shiny_mushroom.lunar_magic` keeps its four bytes in -- or ``None``
    on a cartridge whose base does not carry them: the roles are the
    ``lunar-magic-levels`` feature's own, declared only where it is on."""
    found = tuple(where.roles.get(role) for role in LUNAR_MAGIC_ROLES)
    if any(one is None for one in found):
        return None
    return found  # type: ignore[return-value]


def lunar_magic_bytes(rom: bytes, level: int, *, where: Addresses) -> bytes:
    """``level``'s four Lunar Magic bytes, read off the image -- empty where
    the image's base keeps no such tables. The fallback source for a
    session with no project to ask, and the baseline a preview patch is
    measured against."""
    tables = lunar_magic_tables(where)
    if tables is None:
        return b""
    return bytes(rom[where.offset(table + level)] for table in tables)


def lunar_magic_patch(
    rom: bytes, level: int, settings: bytes, *, where: Addresses
) -> dict[int, bytes]:
    """The cartridge edit that gives ``level`` these four bytes: one byte
    per table, always safe in place, and nothing at all on a cartridge
    without the tables -- the document's bytes then describe a build this
    image is not."""
    if len(settings) != LUNAR_MAGIC_SIZE:
        raise ValueError(
            f"the Lunar Magic settings are {LUNAR_MAGIC_SIZE} bytes, "
            f"not {len(settings)}"
        )
    tables = lunar_magic_tables(where)
    if tables is None:
        return {}
    patches = {}
    for table, value in zip(tables, settings, strict=True):
        offset = where.offset(table + level)
        if rom[offset] != value:
            patches[offset] = bytes([value])
    return patches


def layer3_tables(where: Addresses) -> tuple[int, int, int, int] | None:
    """The four Layer 3 tables' addresses, in table order, or ``None`` on a
    cartridge whose base does not carry them -- the ``layer3-settings``
    feature's own roles, declared only where it is on."""
    found = tuple(where.roles.get(role) for role in LAYER3_ROLES)
    if any(one is None for one in found):
        return None
    return found  # type: ignore[return-value]


def layer3_bytes(rom: bytes, level: int, *, where: Addresses) -> bytes:
    """``level``'s four Layer 3 bytes, read off the image -- empty where the
    image's base keeps no such tables."""
    tables = layer3_tables(where)
    if tables is None:
        return b""
    return bytes(rom[where.offset(table + level)] for table in tables)


def layer3_patch(
    rom: bytes, level: int, settings: bytes, *, where: Addresses
) -> dict[int, bytes]:
    """The cartridge edit that gives ``level`` these four bytes: one byte per
    table, always safe in place, and nothing at all on a cartridge without
    the tables."""
    if len(settings) != LAYER3_SIZE:
        raise ValueError(
            f"the Layer 3 settings are {LAYER3_SIZE} bytes, not {len(settings)}"
        )
    tables = layer3_tables(where)
    if tables is None:
        return {}
    patches = {}
    for table, value in zip(tables, settings, strict=True):
        offset = where.offset(table + level)
        if rom[offset] != value:
            patches[offset] = bytes([value])
    return patches


def secondary_entrance_tables(where: Addresses) -> tuple[int, int, int, int]:
    """The four secondary-entrance tables' addresses, in table order -- the
    order :mod:`shiny_mushroom.secondary_entrances` keeps its four bytes
    in."""
    return (
        where.secondary_entrance_destination,
        where.secondary_entrance_camera_y,
        where.secondary_entrance_x_and_screen,
        where.secondary_entrance_action,
    )


def secondary_entrance_rows(
    rom: bytes, *, where: Addresses
) -> tuple[tuple[int, ...], ...]:
    """The four secondary-entrance tables, whole, read off the image.

    The fallback source for a session with no project to ask, as
    :func:`secondary_header_bytes` is for a level's own arrival -- and read
    whole rather than a row at a time because an entrance belongs to no
    level: what asks for these is a picker over every entrance in use and a
    lookup of where one lands, neither of which knows a number in advance.
    """
    return tuple(
        tuple(rom[where.offset(table) :][:SECONDARY_ENTRANCE_COUNT])
        for table in secondary_entrance_tables(where)
    )


def secondary_header_bytes(rom: bytes, level: int, *, where: Addresses) -> bytes:
    """``level``'s four secondary-header bytes, read off the image.

    One byte from each table, in table order -- the fallback source for a
    session with no project to ask, and the baseline a preview patch is
    measured against.
    """
    return bytes(
        rom[where.offset(table + level)] for table in secondary_header_tables(where)
    )


def secondary_header_patch(
    rom: bytes,
    level: int,
    secondary: bytes,
    *,
    where: Addresses,
) -> dict[int, bytes]:
    """The cartridge edit that gives ``level`` these secondary-header bytes.

    Like a header, always safe to patch in place: each table holds exactly one
    byte per level, so nothing after it can move. The four tables are in
    :func:`sublevel_setup_tables`' window, so a patch here forces the full
    game-mode load a changed entrance needs rather than the fast rebuild.
    """
    if len(secondary) != SECONDARY_HEADER_SIZE:
        raise ValueError(
            f"a secondary header is {SECONDARY_HEADER_SIZE} bytes, not {len(secondary)}"
        )
    patches = {}
    for table, value in zip(secondary_header_tables(where), secondary, strict=True):
        offset = where.offset(table + level)
        if rom[offset] != value:
            patches[offset] = bytes([value])
    return patches


def free_space(
    rom: bytes,
    size: int,
    *,
    bank: int | None = None,
    taken: Iterable[range] = (),
    where: Addresses,
) -> int | None:
    """Somewhere in the image to park ``size`` bytes, or ``None`` if nowhere.

    Free space in this cartridge is a run of ``$FF``: the build fills its unused
    regions with them (see ``smw/src/SMW/Misc/``), and no level stream can
    contain one, because ``$FF`` in a record's first byte is the terminator that
    ends the walk. So a long run of them is either free or is data no reader
    could distinguish from free -- which is why the run has to be at least
    :data:`FREE_RUN_MINIMUM` long even when far less is being asked for. A short
    run of ``$FF`` is quite ordinary inside real data; a long one is not.

    **Never across a bank boundary.** The loader reads a stream through a 16-bit
    pointer and a separate bank register, so a stream that ran off the end of its
    bank would carry on reading at the *start* of the same one. Each of the
    image's ``$8000``-byte slices is therefore searched on its own.

    ``bank`` restricts the search to one of those slices, which is what sprite
    data needs: its pointer table holds no bank at all and the loader supplies
    one (:func:`sprite_data_bank`), so a sprite stream has nowhere else to go.
    ``taken`` excludes ranges already handed out, so two relocations in one patch
    cannot be given the same address.
    """
    bank_size = where.bank_size
    # Only banks the base can spell a pointer into: an image can outrun its
    # map's addresses (SA-1's stop at 2 MB), and a run past that bound is one
    # no pointer table entry could ever name.
    reachable = min(len(rom), where.addressable)
    banks = (bank,) if bank is not None else range(reachable // bank_size)
    claimed = list(taken)
    wanted = max(size, FREE_RUN_MINIMUM)
    for slice_index in banks:
        start = slice_index * bank_size
        run = None
        for offset in range(start, min(start + bank_size, len(rom))):
            if rom[offset] != 0xFF or any(offset in used for used in claimed):
                run = None
                continue
            if run is None:
                run = offset
            if offset - run + 1 >= wanted:
                return run
    return None


def level_patch(
    rom: bytes,
    level: int,
    header: bytes,
    objects: bytes,
    sprites: bytes,
    *,
    layer2: tuple[bytes, bytes] | None = None,
    taken: Iterable[range] = (),
    where: Addresses,
) -> dict[int, bytes]:
    """The cartridge edit that makes ``level`` the level the editor is holding.

    **This is the seam a level edit crosses.** The editor never writes a file;
    an edited level reaches a running cartridge as a patch over the emulator's
    own copy of the image, which costs a level load rather than an assembler
    pass. :func:`header_patch` does the same job for the five header bytes
    alone, and this supersedes it whenever the streams are in play, because a
    relocated level takes its header with it.

    Each stream is written back **in place if it still fits**, and it usually
    does: moving, resizing and reordering records leave the length alone, and
    deleting shortens it. A stream that is shorter than the one it replaces
    simply leaves the old tail behind -- the terminator it ends with is what
    stops the walk, so what follows is unreachable rather than wrong.

    A stream that has **grown** cannot go back where it came from: the cart packs
    one level's data against the next, so a longer one would overwrite its
    neighbour. It is relocated instead -- written whole into :func:`free_space`
    and pointed at through the table the game itself resolves. The object stream
    moves with its header, because the header is the five bytes in front of it.

    ``layer2`` is the level's Layer 2 where that is an object stream rather
    than a background -- its own five header bytes and its records -- patched
    by the same two rules through the Layer 2 pointer table. See
    :func:`layer2_level_patch`, which is where that arm lives and where what a
    relocation there costs is written down. ``taken`` is whatever runs of free
    space a caller has already handed out in the same patch -- a relocated
    graphics file, say -- so nothing here is placed over them.

    Raises :class:`ValueError` when a grown stream has nowhere to go, which is a
    real answer and not an internal error: the cartridge is full, and the caller
    has to say so rather than load a level that is silently not the one on the
    canvas.
    """
    patches: dict[int, bytes] = {}
    claimed: list[range] = list(taken)

    base = layer1_base(rom, level, where=where)
    header = bytes(header)
    if len(header) != HEADER_SIZE:
        raise ValueError(f"a level header is {HEADER_SIZE} bytes, not {len(header)}")
    if len(objects) <= len(object_stream(rom, base + HEADER_SIZE)):
        patches[base] = header + bytes(objects)
    else:
        block = header + bytes(objects)
        room = free_space(rom, len(block), taken=claimed, where=where)
        if room is None:
            raise ValueError(
                f"level {hexnum(level, 3)} has {len(objects)} bytes of objects and the "
                f"cartridge has no free run that long to move them to"
            )
        claimed.append(range(room, room + len(block)))
        patches[room] = block
        address = where.address(room)
        patches[where.offset(where.layer1_pointers + level * 3)] = bytes(
            (address & 0xFF, (address >> 8) & 0xFF, (address >> 16) & 0xFF)
        )

    sprite_start = sprite_base(rom, level, where=where)
    if len(sprites) <= len(
        sprite_stream(rom, sprite_start, extra_byte_counts(rom, where=where))
    ):
        patches[sprite_start] = bytes(sprites)
    else:
        bank = sprite_list_bank(rom, level, where=where)
        if bank is None:
            raise ValueError(
                "this cartridge does not say which bank its sprite data is in, "
                "so a longer sprite list has nowhere to go"
            )
        # The slice of the image that bank maps to; bit 7 is a mirror, exactly as
        # in :meth:`Addresses.offset`.
        room = free_space(
            rom, len(sprites), bank=bank & 0x7F, taken=claimed, where=where
        )
        if room is None:
            raise ValueError(
                f"level {hexnum(level, 3)} has {len(sprites)} bytes of sprites "
                f"and bank "
                f"{hexnum(bank)} has no free run that long to move them to"
            )
        patches[room] = bytes(sprites)
        address = where.address(room)
        patches[where.offset(where.sprite_pointers + level * 2)] = bytes(
            (address & 0xFF, (address >> 8) & 0xFF)
        )

    if layer2 is not None:
        patches |= layer2_level_patch(rom, level, *layer2, taken=claimed, where=where)
    return patches


def layer2_level_patch(
    rom: bytes,
    level: int,
    header: bytes,
    objects: bytes,
    *,
    taken: Sequence[range] = (),
    where: Addresses,
) -> dict[int, bytes]:
    """The cartridge edit that makes ``level``'s Layer 2 the object stream in
    hand -- its own five header bytes and its records.

    Layer 1's two rules, over Layer 2's pointer table: written back in place
    while it still fits, and relocated into :func:`free_space` with the table
    repointed when it has grown. ``taken`` is whatever runs a caller has
    already claimed of that free space, so two relocations in one patch cannot
    be handed the same bytes.

    **A relocation unshares the stream.** Eight level numbers read the one
    level ``$0C4``'s container holds, and repointing this level's entry alone
    leaves the other seven reading the address they always did -- which is what
    a *preview* wants, and is not something a save may do quietly.

    ``{}`` when the image already holds exactly these bytes, and for a level
    whose Layer 2 is a background: there is no stream there to write, and a
    caller asking is one that has nothing to say about this level's Layer 2.
    """
    start = layer2_level_base(rom, level, where=where)
    if start is None or len(rom) < start + HEADER_SIZE + 1:
        return {}
    if len(header) != HEADER_SIZE:
        raise ValueError(f"a level header is {HEADER_SIZE} bytes, not {len(header)}")
    held = object_stream(rom, start + HEADER_SIZE)
    block = bytes(header) + bytes(objects)
    if block == rom[start : start + HEADER_SIZE] + held:
        return {}
    if len(objects) <= len(held):
        return {start: block}
    room = free_space(rom, len(block), taken=taken, where=where)
    if room is None:
        raise ValueError(
            f"level {hexnum(level, 3)} has {len(objects)} bytes of Layer 2 objects and "
            f"the cartridge has no free run that long to move them to"
        )
    return {room: block} | layer2_entry_patch(
        rom, level, where.address(room), background=False, where=where
    )


#: The graphics files the pointer tables hold, `GFX00`-`GFX31`, which is also
#: how long each table is.
TABLED_GRAPHICS = range(0x32)

#: The two graphics files the pointer tables leave out, by the role each one's
#: address is declared under -- reached by literal from
#: `DecompressGFX32And33` once at boot, so an edit to either has no table entry
#: to repoint and is previewed in place or not at all. Under the managed
#: layout the pointer table has a row for each, which is where they are
#: *read* from -- `GFX33` follows `GFX32` in the packing and moves when it
#: grows -- but the boot-time load still reaches them by literal, so neither
#: is ever relocated.
UNTABLED_GRAPHICS = {0x32: "graphics_file_32", 0x33: "graphics_file_33"}

#: The three parallel pointer tables `GFX00`-`GFX31` resolve through, by role,
#: in the order a 24-bit address is spelled: low, high, bank.
GRAPHICS_POINTER_TABLES = (
    "graphics_pointers_low",
    "graphics_pointers_high",
    "graphics_pointers_bank",
)

#: The managed graphics head (``Config/ManagedGraphicsMemory.asm``,
#: :data:`smw_tools.features.MANAGED_GRAPHICS_MEMORY`): the roles its two
#: tables are declared under -- a ``dl`` row per file number and a format
#: byte per file number, ``$100`` of each -- and how the hook that reads
#: them is found. The stock decompressor's three table reads are fifteen
#: bytes that follow its four-byte prologue (``PHB : PHY : PHK : PLB``),
#: which follows the bank table; under the feature they are a ``JSL`` to
#: the pointer stub, itself at a fixed offset from the format table
#: (:data:`smw_tools.graphics_memory.STUBS_OFFSET`). The site is derived
#: from the bank table's role rather than declared, the way the level-bank
#: hook is found from the bank instruction (:func:`sprite_list_bank`): the
#: distance is the same on every target, since the code between is the
#: same code.
GRAPHICS_POINTERS_ROLE = "graphics_pointers"
GRAPHICS_FORMATS_ROLE = "graphics_formats"
GRAPHICS_HOOK_PROLOGUE = 4
GRAPHICS_ROW_BYTES = 3

#: The added files' file numbers, and the two raw lengths a file may have
#: under the managed layout by format -- what the format byte says, and
#: what the raw file's length implies.
ADDED_GRAPHICS = range(graphics_memory.FIRST_ADDED, graphics_memory.LAST_ADDED + 1)
GRAPHICS_FORMAT_SIZES = graphics_memory.DECOMPRESSED_SIZES
FORMAT_4BPP = graphics_memory.FORMAT_4BPP


def graphics_hook_site(where: Addresses) -> int | None:
    """Where the decompressor reads a file's pointer, as a CPU address: the
    three stock table reads, or the ``JSL`` that replaces them. ``None`` on a
    base that declares no pointer tables."""
    bank_table = where.roles.get(GRAPHICS_POINTER_TABLES[-1])
    if bank_table is None:
        return None
    return bank_table + len(TABLED_GRAPHICS) + GRAPHICS_HOOK_PROLOGUE


@dataclass(frozen=True)
class ManagedGraphics:
    """The managed head as the image holds it: where the pointer table and
    the format table begin, as offsets into the image. Only ever made by
    :func:`managed_graphics`, which is what checks the hook is in."""

    pointers: int
    formats: int

    def row_offset(self, number: int) -> int:
        """Where file ``number``'s three-byte row is."""
        return self.pointers + GRAPHICS_ROW_BYTES * number

    def format_offset(self, number: int) -> int:
        """Where file ``number``'s format byte is."""
        return self.formats + number

    def row(self, rom: bytes, number: int) -> int:
        """File ``number``'s 24-bit address; ``0`` is "no such file"."""
        at = self.row_offset(number)
        return rom[at] | (rom[at + 1] << 8) | (rom[at + 2] << 16)

    def format(self, rom: bytes, number: int) -> int:
        return rom[self.format_offset(number)]

    def reaches(self, offset: int, length: int) -> bool:
        """Whether a patch of ``length`` bytes at ``offset`` lands on either
        table -- from the pointer table's first byte to the format table's
        last, which is where the stubs begin."""
        end = self.formats + graphics_memory.FILE_ROWS
        return offset < end and offset + length > self.pointers


def managed_graphics(rom: bytes, *, where: Addresses) -> ManagedGraphics | None:
    """The managed head, when the image is one the game reads it from.

    Both halves have to be there before the tables are believed, the rule
    :func:`_hooked` states: the roles, which a base with the feature
    declares, **and** the hook in the image -- the ``JSL`` to the pointer
    stub at the site the stock reads occupy. The stock tables are the truth
    otherwise.
    """
    pointers = where.roles.get(GRAPHICS_POINTERS_ROLE)
    formats = where.roles.get(GRAPHICS_FORMATS_ROLE)
    site = graphics_hook_site(where)
    if pointers is None or formats is None or site is None:
        return None
    stub = formats + graphics_memory.FILE_ROWS
    if not _hooked(rom, site, target=stub, where=where):
        return None
    try:
        head = ManagedGraphics(where.offset(pointers), where.offset(formats))
    except ValueError:
        return None
    if head.formats + graphics_memory.FILE_ROWS > len(rom):
        return None
    return head


def graphics_pointer(rom: bytes, number: int, *, where: Addresses) -> int | None:
    """Where the image keeps graphics file ``number``'s compressed stream, as
    an offset into it -- or ``None`` when the image cannot say.

    Read off the cartridge's **own** pointer tables rather than the symbol file
    or the assets, because the image is the thing being patched: a build that
    already re-placed the file has the table saying so, and a stock cartridge
    has it saying where the file shipped. `GFX32` and `GFX33` are not in the
    stock tables and come from the base's declaration instead.

    Under the managed layout (:func:`managed_graphics`) every number up to
    ``$FE`` is a row of the 256-row table, `GFX32` and `GFX33` included, and
    a row of ``$000000`` is a file the cartridge does not hold -- an added
    number the last build had not seen, or one never added.

    ``None`` is an image too short to hold the tables, a base that declares
    none, or an entry that spells an address the base's map cannot reach --
    all of them "not a cartridge this can follow", and none of them a reason
    to raise.
    """
    try:
        head = managed_graphics(rom, where=where)
        if head is not None:
            if not 0 <= number < graphics_memory.SENTINEL:
                return None
            address = head.row(rom, number)
            return None if address == 0 else where.offset(address)
        role = UNTABLED_GRAPHICS.get(number)
        if role is not None:
            found = where.roles.get(role)
            return None if found is None else where.offset(found)
        entries = []
        for table in GRAPHICS_POINTER_TABLES:
            found = where.roles.get(table)
            if found is None:
                return None
            at = where.offset(found + number)
            if at >= len(rom):
                return None
            entries.append(rom[at])
        low, high, bank = entries
        return where.offset(low | (high << 8) | (bank << 16))
    except ValueError:
        return None


@dataclass(frozen=True)
class GraphicsPlacement:
    """What :func:`graphics_patch` decided for one file.

    ``patches`` is the edit, empty when there is nothing to do; ``reason``
    is why the edit could not be carried, in words that follow the file's
    name -- "has outgrown the run of ROM the cartridge gives it" -- and
    ``None`` when it was, or when nothing needed doing. Never both.
    """

    patches: dict[int, bytes]
    reason: str | None = None

    @classmethod
    def refused(cls, reason: str) -> GraphicsPlacement:
        return cls({}, reason)


#: The reason a grown file with nowhere to go is refused with.
OUTGROWN = "has outgrown the run of ROM the cartridge gives it"


def _graphics_name(number: int) -> str:
    return f"GFX{number:02X}"


def graphics_patch(
    rom: bytes,
    number: int,
    raw: bytes,
    family: Family,
    *,
    taken: Iterable[range] = (),
    where: Addresses,
) -> GraphicsPlacement:
    """The cartridge edit that makes graphics file ``number`` decompress to
    ``raw``.

    The level relocator's two rules, over the graphics pointer tables. The
    stream in the image is decoded to find its slot -- its start is what the
    table says and its length is what the decoder consumes -- and the new
    encoding is written **in place** when it is no longer than that: the
    decoder stops at the stream's own terminator, so a shorter stream leaves
    an unreachable tail behind and nothing else. One that has **grown** cannot
    go back where it came from, since the files are packed to the byte against
    each other, and is relocated instead: written whole into
    :func:`free_space` -- inside one bank, because the decoder's pointer is a
    bank register and a 16-bit address -- and the file's pointer repointed at
    it: the three stock table bytes, or under the managed layout
    (:func:`managed_graphics`) the file's three-byte row. ``taken`` is
    whatever free runs the same patch has already claimed.

    `GFX32` and `GFX33` are reached by literal at boot, so they are patched
    in place or not at all under either layout.

    Under the managed layout an **added** file -- ``$34``-``$FE`` -- whose
    row is ``$000000`` has no slot at all: it was added since the last build.
    It is encoded from scratch, placed whole into free space and its row
    written. Its format byte is made to say what the raw file's length
    implies, ``$C00`` being 3bpp and ``$1000`` 4bpp, so a 4bpp file added
    since the last build is uploaded straight rather than through the 3bpp
    expansion; a length that is neither is refused. A stock file's raw has
    to be the length the game decompresses it to.

    ``family`` is the LZ member the image's streams are in, which is a fact
    about the target's asset set (:func:`smw_tools.graphics.family_for_set`).

    Empty patches when there is nothing to do: the image already decodes to
    ``raw``, or it is a stub too short to hold the tables or the stream. A
    ``reason`` when the edit cannot be carried -- a grown stream with no free
    run to move to, a grown `GFX32`, a slot that does not decode, a raw of
    the wrong length, an added number on a cartridge with no row for it --
    so the caller can say the cartridge's own is showing until a build.
    """
    from smw_tools.compression import CorruptStream, compress, decompress, repack

    head = managed_graphics(rom, where=where)
    extra: dict[int, bytes] = {}
    if number in graphics.FILE_NUMBERS:
        expected = graphics.decompressed_size(number)
        if len(raw) != expected:
            return GraphicsPlacement.refused(
                f"is {hexnum(len(raw), 4)} bytes where the game decompresses "
                f"it to {hexnum(expected, 4)}"
            )
    elif head is not None and number in ADDED_GRAPHICS:
        by_size = {size: f for f, size in GRAPHICS_FORMAT_SIZES.items()}
        fmt = by_size.get(len(raw))
        if fmt is None:
            sizes = ", ".join(
                f"{hexnum(size, 4)} ({'4bpp' if f == FORMAT_4BPP else '3bpp'})"
                for f, size in GRAPHICS_FORMAT_SIZES.items()
            )
            return GraphicsPlacement.refused(
                f"is {hexnum(len(raw), 4)} bytes, and an added file is {sizes}"
            )
        if head.format(rom, number) != fmt:
            extra[head.format_offset(number)] = bytes([fmt])
    else:
        return GraphicsPlacement.refused(
            "has no row in this cartridge's pointer tables until a build with "
            "the managed graphics on"
        )

    if head is not None:
        address = head.row(rom, number)
        try:
            at = None if address == 0 else where.offset(address)
        except ValueError:
            return GraphicsPlacement.refused(
                f"points at {hexnum(address, 6)}, which this cartridge does not reach"
            )
        if at is None:
            encoded = compress(raw, family, smallest=True)
            room = free_space(rom, len(encoded), taken=taken, where=where)
            if room is None:
                return GraphicsPlacement.refused(
                    "was added since the last build and has no free run of ROM "
                    "to be placed in"
                )
            row = bytes(_long(where.address(room)))
            placed = {room: encoded, head.row_offset(number): row}
            return GraphicsPlacement(placed | extra)
    else:
        at = graphics_pointer(rom, number, where=where)
        if at is None or at >= len(rom):
            return GraphicsPlacement({})
    # Wide enough for any encoding of a file this long -- a stream is its raw
    # form plus a header byte per run at worst -- and stopped by the
    # terminator well before that.
    window = rom[at : at + 2 * len(raw) + 64]
    if len(window) < len(raw) // 4:
        return GraphicsPlacement({})  # a byte-map stub, not a cartridge
    try:
        decoded, consumed = decompress(window, family)
    except CorruptStream:
        return GraphicsPlacement.refused("does not decode from the cartridge")
    if decoded == raw:
        return GraphicsPlacement(extra)
    encoded = repack(window[:consumed], raw, family, smallest=True)
    if len(encoded) <= consumed:
        return GraphicsPlacement({at: encoded} | extra)
    if number in UNTABLED_GRAPHICS:
        return GraphicsPlacement.refused(OUTGROWN)
    room = free_space(rom, len(encoded), taken=taken, where=where)
    if room is None:
        return GraphicsPlacement.refused(OUTGROWN)
    address = where.address(room)
    patches = {room: encoded}
    if head is not None:
        patches[head.row_offset(number)] = bytes(_long(address))
    else:
        for table, byte in zip(GRAPHICS_POINTER_TABLES, _long(address), strict=True):
            patches[where.offset(where.roles[table] + number)] = bytes([byte])
    return GraphicsPlacement(patches | extra)


def patch_key(patches: Mapping[int, bytes] | None) -> tuple[tuple[int, bytes], ...]:
    """``patches`` as something a cache can be keyed on: the same edit spelled
    from any mapping, in any order, gives the same key, and no set at all is
    the empty one."""
    return tuple(
        sorted((offset, bytes(data)) for offset, data in (patches or {}).items())
    )


def patched_image(rom: bytes, patches: Mapping[int, bytes] | None) -> bytes:
    """``rom`` with ``patches`` laid over it.

    For a reader that has to answer a question about the image a load is
    *asking for* before the core has been given the edit;
    :meth:`~shiny_mushroom.emu.smw.CartSession.previewed_image` is that reader
    and says why one exists.

    The whole image rather than the window the caller wants, because a pointer
    followed through it may land anywhere -- half a megabyte copied, which is
    ~0.1 ms against the load it is deciding about.
    """
    if not patches:
        return rom
    image = bytearray(rom)
    for offset, data in patches.items():
        image[offset : offset + len(data)] = data
    return bytes(image)


def patches_reach_graphics(
    patches: Mapping[int, bytes] | None, rom: bytes, *, where: Addresses
) -> bool:
    """Whether any of ``patches`` is a graphics file or its pointer.

    What the rebuild shortcut has to refuse: it runs the loader over a warm
    state that already holds the level's graphics expanded into VRAM, and
    never decompresses one, so a patched file would go unseen. A patch here
    is recognised by where it lands -- in one of the three pointer tables,
    which a relocation rewrites, or at the start of a file's own stream, which
    an in-place rewrite overwrites -- and the starts are read off the image
    the way the game reads them, so a build that moved a file is followed.
    Under the managed layout the tables are the head's two, and the starts
    are every row the pointer table names.
    """
    if not patches:
        return False
    head = managed_graphics(rom, where=where)
    numbers = (
        range(graphics_memory.SENTINEL)
        if head is not None
        else (*TABLED_GRAPHICS, *UNTABLED_GRAPHICS)
    )
    starts = {
        found
        for number in numbers
        if (found := graphics_pointer(rom, number, where=where)) is not None
    }
    # The stock tables stay in the image under the managed layout, unread.
    tables = [
        where.offset(found)
        for table in (() if head is not None else GRAPHICS_POINTER_TABLES)
        if (found := where.roles.get(table)) is not None
    ]
    return any(
        offset in starts
        or (head is not None and head.reaches(offset, len(data)))
        or any(
            offset < base + len(TABLED_GRAPHICS) and offset + len(data) > base
            for base in tables
        )
        for offset, data in patches.items()
    )


def patches_reach_level_graphics(
    patches: Mapping[int, bytes] | None, rom: bytes, *, where: Addresses
) -> bool:
    """Whether any of ``patches`` lands in the per-level graphics tables.

    The other thing the rebuild shortcut has to refuse, and for the same
    reason :func:`patches_reach_graphics` gives: the shortcut runs the loader
    over a warm state and never runs ``SMW_UploadGraphicsFiles``, which is
    where both halves of a row are read -- the overlay that lays the eight
    slots over the tileset lists, and the stub that expands the level's own
    animated tiles into WRAM. A patched row would go unseen either way.

    The window is the two tables together (:func:`level_graphics_rows`), so a
    patch to a level's slots and one to its animated file are the same
    answer. ``False`` on an image with no rows, where there is nothing to
    patch and nothing to miss.
    """
    if not patches:
        return False
    head = level_graphics_rows(rom, where=where)
    if head is None:
        return False
    end = head + level_graphics.ROWS_BYTES + level_graphics.ANIMATED_BYTES
    return any(
        offset < end and offset + len(data) > head for offset, data in patches.items()
    )


def entrance_patch(
    rom: bytes,
    level: int,
    start: PlayerPosition,
    vertical: bool = False,
    *,
    where: Addresses,
) -> dict[int, bytes]:
    """The cartridge edit that makes ``level`` start at ``start``.

    A :class:`PlayerPosition` rather than two numbers because the loader copies
    these table entries into ``$0094``/``$0096`` untouched -- so what goes in
    here is what the game will hold, :data:`PLAYER_FEET_OFFSET` above the floor
    the player ends up standing on. Written a floor instead, he loads two blocks
    inside the ground; measured on level ``$004``, he falls through it.

    **Why a patch and not a write to the player's position.** SMW has no
    in-level teleport: a pipe, a door and a screen exit are all sublevel
    reloads. Writing the player somewhere mid-level moves *him* and nothing
    else, and the level is streamed into VRAM a column at a time as the camera
    scrolls -- so the screen keeps showing the columns the scroll code had
    already put there. Rebuilding it by hand does not work either: the routine
    that does it during a load, ``SMW_InitializeLevelLayer1And2Tilemaps``, ends
    in a VRAM DMA, and that only lands while the screen is off. Measured, a
    call to it mid-level runs its 494 instructions and changes nothing.

    So the start is moved the way the cartridge moves it: the loader reads the
    entrance and builds the level around it, which gets the camera, the tilemap
    and the level's sprites right for free because none of it is being
    second-guessed.

    Four bytes for the position, and the awkward one is the third:

    - the Y position, low and high, in the sixteen-entry table this level's
      secondary header indexes;
    - the X position's **low** byte, in the eight-entry table it indexes;
    - the X position's **high** byte, which is not in a position table at all.
      For a horizontal level the loader overwrites it with the level's primary
      entrance *screen*, out of the low five bits of ``$05F600`` -- so that is
      where the coarse half of an X lives. A **vertical** level takes the same
      five bits as its Y high byte instead, and its X comes wholly from the
      position tables.

    Bit 7 of that byte is the no-entrance-room flag
    (:meth:`CartSession.skip_entrance_room`), and is preserved.

    Then up to two more for the **camera** and the background that has to move
    with it, without which the other four are not enough -- see
    :func:`camera_patch`.

    The position tables are shared by every level that indexes the same entry,
    which is safe here for the reason any preview is: one level is loaded per
    test run, and the edit exists only in the emulator's copy.
    """
    x, y = start.x, start.y
    screen_at = where.offset(where.secondary_header_entrance + level)
    y_index = rom[where.offset(where.secondary_header_y + level)] & ENTRANCE_Y_INDEX
    x_index = rom[where.offset(where.secondary_header_x + level)] & ENTRANCE_X_INDEX
    screen = (y if vertical else x) >> 8
    keep = rom[screen_at] & ~ENTRANCE_SCREEN & 0xFF
    patch = {screen_at: bytes([keep | (screen & ENTRANCE_SCREEN)])}
    if vertical:
        patch[where.offset(where.entrance_y_low + y_index)] = bytes([y & 0xFF])
        patch[where.offset(where.entrance_x_low + x_index)] = bytes([x & 0xFF])
        patch[where.offset(where.entrance_x_high + x_index)] = bytes([(x >> 8) & 0xFF])
    else:
        patch[where.offset(where.entrance_y_low + y_index)] = bytes([y & 0xFF])
        patch[where.offset(where.entrance_y_high + y_index)] = bytes([(y >> 8) & 0xFF])
        patch[where.offset(where.entrance_x_low + x_index)] = bytes([x & 0xFF])
    return patch | camera_patch(rom, level, start, vertical, where=where)


def entrance_position(
    rom: bytes,
    screen: int,
    x_index: int,
    y_index: int,
    vertical: bool = False,
    *,
    where: Addresses,
) -> PlayerPosition:
    """Where an entrance's three numbers put the player, in level pixels.

    The read :func:`entrance_patch` is the write of: a screen, an index into
    the eight X positions and an index into the sixteen Y ones is the whole of
    what an entrance says about where it lands, whether it is a level's own
    entrance -- the low bits of its three secondary-header bytes -- or a row
    of the secondary entrances, where the same three numbers are spread across
    bytes 2 and 3.

    The awkward byte is the same one, from the other side: the screen is the
    **coarse half of one axis**, and which axis is the level's business rather
    than the entrance's. In a horizontal level it is the X high byte and the
    Y comes whole out of the position tables; in a vertical one it is the Y
    high byte and the X comes whole out of them. The table entry the screen
    overwrites is read by nothing either way, which is why each of the two
    high-byte tables is half zeroes and half ones and neither is wrong.
    """
    across = x_index & ENTRANCE_X_INDEX
    down = y_index & ENTRANCE_Y_INDEX
    x = rom[where.offset(where.entrance_x_low + across)]
    y = rom[where.offset(where.entrance_y_low + down)]
    coarse = (screen & ENTRANCE_SCREEN) << 8
    if vertical:
        x |= rom[where.offset(where.entrance_x_high + across)] << 8
        y |= coarse
    else:
        x |= coarse
        y |= rom[where.offset(where.entrance_y_high + down)] << 8
    return PlayerPosition(x, y)


def camera_start(start: PlayerPosition) -> int:
    """The byte to put in :data:`LAYER1_INITIAL_Y` to frame a start at ``start``.

    :data:`CAMERA_SETTLED_Y` above the player, which is the line the game's own
    scroll code walks the camera towards, clamped to the range that code works
    in -- ``$00`` to :data:`CAMERA_LOWEST_Y`.

    Horizontal levels only, which is all :func:`camera_patch` uses it for. In a
    vertical level the byte is merely the low half of a camera whose high byte
    is the entrance screen, and clamping it in isolation would mean something
    else entirely.
    """
    return max(0, min(CAMERA_LOWEST_Y, start.y - CAMERA_SETTLED_Y))


def layer2_scroll_shift(rom: bytes, level: int, *, where: Addresses) -> int | None:
    """How far ``CODE_00A796`` shifts Layer 1's initial Y for this level, or
    None where Layer 2 does not scroll vertically and there is no offset at all.

    The setting is indexed by the high nybble of the same ``$05F000`` byte whose
    low nybble picks the entrance Y -- see :data:`L2_VERT_SCROLL_SETTINGS`.

    **A setting above the table's largest is that largest, not "no offset".**
    ``CODE_00A796`` branches on a decrementing counter rather than on the value,
    and its second ``DEY : BEQ`` falls through for every ``Y >= 3``, so 3 and
    everything above it take the same three shifts:

    .. code-block:: asm

        CODE_00A7A7:
            LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
            LSR
            DEY
            BEQ.b CODE_00A7AF       ; only setting 2 leaves here
            LSR
            LSR                     ; 3 and up all land on three shifts

    The stock cart cannot reach it -- ``L2VertScrollSettings`` holds only
    ``$00``-``$03`` -- but Lunar Magic hijacks the table's upper half, so a hack
    can. Reading such a value as "no vertical scroll" would skip the Layer 2
    compensation in :func:`camera_patch` and ship a background off by the whole
    camera move, silently, which is the one outcome that patch exists to
    prevent.
    """
    index = rom[where.offset(where.secondary_header_y + level)] >> 4
    setting = rom[where.offset(where.l2_vert_scroll_settings) + index]
    return L2_OFFSET_SHIFT.get(min(setting, max(L2_OFFSET_SHIFT)))


def camera_patch(
    rom: bytes,
    level: int,
    start: PlayerPosition,
    vertical: bool = False,
    *,
    where: Addresses,
) -> dict[int, bytes]:
    """The two further bytes that put the camera where a start can be seen,
    without taking the background with it.

    **Moving the player without this leaves him off the screen.** The camera's
    starting position is not derived from his: ``SMW_SpecifySublevelToLoad``
    reads it out of :data:`LAYER1_INITIAL_Y`, four coarse heights indexed by
    bits 2-3 of the level's ``$05F400`` entry, and every stock level starts at
    ``$C0`` -- the bottom. A start put two screens up loads with the camera
    still down there and the player above the top edge. Measured on level
    ``$001``, a start at ``y = 80`` loads 112 pixels off the top of the screen.

    And the camera does not come and find him. Vertical scrolling is gated three
    ways, and the *level* usually loses: with ``$1412`` set to the common "not
    unless flying, swimming or climbing", ``CODE_00F869`` pins the camera to
    ``$C0`` outright. Even unpinned it converges at three pixels a frame and
    only once he is standing on something.

    So this patches what the loader reads, exactly as the entrance is patched,
    and the gate opens on its own: ``SMW_InitializeLevelRAM`` runs
    ``LDA $1C : CMP #$C0 : BEQ + : INC Flag_EnableVerticalScroll``, so a level
    whose camera does not start at the bottom has vertical scrolling unlocked
    for it. Setting the camera *is* the mechanism -- there is no flag to force
    and nothing about the level to misrepresent.

    **Layer 2 has to move with it, or it is left behind.** ``CODE_00A796``
    computes ``$7E1417`` -- Layer 2's base offset from Layer 1 -- once during the
    load, as ``layer2_initial - (layer1_initial >> shift)``, and the frame code
    adds it to every position it derives thereafter. Change Layer 1's initial Y
    alone and that offset comes out wrong by the difference, for the whole run:
    the error only *shows* once the camera returns to the level's usual height,
    which is why it reads as the background jumping after a fall. Measured on
    ``$004``, 192 pixels.

    The fix is to assume the answer rather than derive one. Where Layer 2 belongs
    relative to Layer 1 is a property of the level and not of where the player
    came in, so this keeps ``$1417`` at the value the level's *own* entrance
    would have produced, by moving Layer 2's initial Y in step. Layer 3 needs
    nothing: ``SMW_InitializeLevelLayer3`` reads Layer 1's X and never its Y.

    Two cases decline the whole thing and leave the level's own camera:

    - **A vertical level.** ``CODE_05DA12`` gives every one of them
      ``$1412 = 1``, free vertical scroll, which skips the gate entirely -- so
      the camera finds the player by itself and there is nothing here worth
      breaking to speed up. Its Layer 2 offset could rarely be preserved anyway:
      the entrance screen is the high byte of *both* layers' initial Y, so
      moving the start moves both, and measured across the stock cart's vertical
      levels the compensating byte is in range for well under a third of the
      heights a start could be placed at.
    - **A compensation that will not fit in the table's byte.** No stock level
      reaches this -- all 489 horizontal levels whose Layer 2 scrolls vertically
      are expressible across the whole camera range -- but a hack's tables are
      its own, and a shifted background is worse than a camera that stayed put.

    **A start at the level's own height writes the bytes that are already
    there.** :func:`camera_start` clamps to :data:`CAMERA_LOWEST_Y`, and an
    ordinary ground-level start is far enough down to clamp -- so the Layer 2
    compensation comes out as its own current value too, and a run that did not
    need any of this is byte-for-byte the run it was before.
    """
    if vertical:
        return {}
    fg = rom[where.offset(where.secondary_header_fg_position + level)]
    index = (fg & FG_POSITION_INDEX) >> FG_POSITION_SHIFT
    camera = camera_start(start)
    patch = {where.offset(where.layer1_initial_y + index): bytes([camera])}

    shift = layer2_scroll_shift(rom, level, where=where)
    if shift is None:
        return patch
    layer2_index = fg & L2_POSITION_INDEX
    was = rom[where.offset(where.layer1_initial_y) + index]
    layer2 = rom[where.offset(where.layer2_initial_y) + layer2_index]
    keep = layer2 - (was >> shift) + (camera >> shift)
    if not 0 <= keep <= 0xFF:
        return {}
    patch[where.offset(where.layer2_initial_y + layer2_index)] = bytes([keep])
    return patch


def level_request_bytes(level: int) -> tuple[int, int]:
    """The ``$7E0109`` and ``$7E1F11`` values that request ``level``.

    ``SpecifySublevelToLoad`` reads ``$0109`` as the level to load, but through
    two tests that between them leave a fifth of the cartridge unnameable: a
    ``$00`` there means "no override, read the overworld tile", and anything
    from ``$25`` up is stored ``$24`` higher than the level it asks for, which
    puts the low bytes ``$DC`` through ``$FF`` past a byte.

    So the value depends on whether the branch that enforces the test is still
    the game's. For every other level this returns the adjusted value the stock
    routine expects; for the low bytes it cannot express it returns the level's
    own, which is what the routine reads **once
    :meth:`CartSession.direct_level_numbers` has turned that branch into a
    ``BRA``**. The two belong together, and neither is useful alone -- writing
    an unadjusted ``$C5`` to an unpatched cartridge would load level ``$0A1``
    without complaining.
    """
    if not 0 <= level <= 0x1FF:
        raise ValueError(f"level {hexnum(level, 3)} is outside $000-$1FF")
    low, high = level & 0xFF, (level >> 8) & 1
    if needs_direct_request(level):
        return low, high
    return (low if low < 0x25 else low + 0x24), high


def needs_direct_request(level: int) -> bool:
    """Whether asking for ``level`` means patching a branch first.

    True for the low bytes the stock routine's two tests cannot produce --
    ``$00``, and ``$DC`` through ``$FF``. That is ``$000``, ``$100``, and
    everything from ``$0DC`` to ``$0FF`` and ``$1DC`` to ``$1FF``: real levels
    holding real data, unreachable only because of how the request is spelled.
    """
    low = level & 0xFF
    return low == 0x00 or low > 0xDB


#: What each of the two branches is in the game's own code -- ``BNE`` for the
#: override test, ``BCC`` for the adjustment -- and what replaces it. Checked
#: before anything is written: a cartridge whose branch is not the game's is
#: one this cannot reason about, and patching it blind would run a hack's own
#: code with a condition removed.
BRANCH_NOT_EQUAL = 0xD0
BRANCH_CARRY_CLEAR = 0x90
BRANCH_ALWAYS = 0x80

#: Every level the emulated loader can be asked for, in order.
#:
#: All of them: the levels the request cannot spell are reached by patching the
#: branch that says so -- :func:`needs_direct_request` -- for the length of the
#: load. A cartridge whose branch is not the game's refuses those levels when
#: one is asked for, which is a fact about that image rather than about the set.
REQUESTABLE_LEVELS = tuple(range(0x200))


def overworld_patches(
    rom: bytes,
    *,
    tiles: bytes | None = None,
    layer2: bytes | None = None,
    stamps: bytes | None = None,
    stamp_props: bytes | None = None,
    sprites: bytes | None = None,
    asm_sections: dict[str, bytes] | None = None,
    where: Addresses,
) -> tuple[dict[int, bytes], list[str]]:
    """The cartridge edits that make a test run show the world map in hand.

    The third kind of edit at :meth:`test_patches`' seam. ``tiles`` is the
    Layer 1 tilemap, ``stamps`` the two event sheets -- the 2x2 sheet sits
    directly after the 6x6 in ROM as it does in the document -- and
    ``sprites`` the slot table; all three patch in place always, being
    fixed-size tables. ``layer2``'s two
    compressed streams and ``stamp_props``' one patch in place **only if the
    re-encoding fits its own slot**: each stream's start is a label the
    game's code names, so a stream cannot grow past the room the shipped one
    occupies without a build re-placing it. A part that does not fit lands in
    the returned ``skipped`` list -- by the name a status line can show --
    rather than half-applying; a build still saves it, because the region's
    budget pools when asar lays the streams out afresh.

    ``asm_sections`` is the fourth kind: an edited asm region's per-section
    images, keyed by rom_tables role, encoded and padded by
    :mod:`smw_tools.asm_regions` so they patch in place like any fixed table.

    Every part is skipped silently when it already equals the image's -- the
    no-patch answer for an unedited map -- or when the image is too short to
    hold it, which is a byte-map stub rather than a cartridge.
    """
    from smw_tools.rle import CorruptStream, Variant, decompress, repack

    patches: dict[int, bytes] = {}
    skipped: list[str] = []

    def table(address: int, data: bytes) -> None:
        offset = where.offset(address)
        if len(rom) >= offset + len(data) and rom[offset : offset + len(data)] != data:
            patches[offset] = data

    if tiles is not None:
        table(where.overworld_layer1_tilemap, tiles)
    if stamps is not None:
        table(where.overworld_event_tiles, stamps)
    if sprites is not None:
        table(where.overworld_sprite_slots, sprites)
    # Edited asm regions arrive as per-section images keyed by rom_tables
    # role -- already padded by their codec, so every label after them is
    # still where `where` says it is. That invariant is what lets a plain
    # in-place table patch preview an asm edit at all.
    for role, image in (asm_sections or {}).items():
        table(getattr(where, role), image)

    def stream(address: int, raw: bytes, variant: Variant, name: str) -> None:
        base = where.offset(address)
        if len(rom) < base + len(raw) // 4:
            return  # a stub, not a cartridge; nothing to preview against
        window = rom[base : base + 2 * len(raw)]
        try:
            decoded, consumed = decompress(window, variant, size=len(raw))
        except CorruptStream:
            skipped.append(name)
            return
        if decoded == raw:
            return
        encoded = repack(window[:consumed], raw, variant, size=len(raw), smallest=True)
        if len(encoded) <= consumed:
            # No padding: bytes of the old stream left past the new one are
            # unreachable either way -- LC_RLE2's decoder stops at the raw
            # size, and LC_RLE1's at the terminator the re-encoding carries.
            patches[base] = encoded
        else:
            skipped.append(name)

    if layer2 is not None:
        stream(
            where.overworld_layer2_tiles,
            bytes(layer2[0::2]),
            Variant.RLE2,
            "Layer 2 tiles",
        )
        stream(
            where.overworld_layer2_properties,
            bytes(layer2[1::2]),
            Variant.RLE2,
            "Layer 2 attributes",
        )
    if stamp_props is not None:
        stream(
            where.overworld_event_properties,
            stamp_props,
            Variant.RLE1,
            "event stamp attributes",
        )

    return patches, skipped


def sublevel_setup_tables(where: Addresses) -> tuple[tuple[int, int], ...]:
    """Every region ``SMW_SpecifySublevelToLoad`` reads, as (offset, length).

    **That routine runs at the top of game mode ``$11``, not inside the
    loader**, so :meth:`SmwLevelLoader._rebuild` -- which calls the loader over
    a warm state -- never runs it. Ten of the forty-four addresses it
    establishes are read afterwards and written by nothing the rebuild calls:
    both layer pointers and the sprite list pointer, which
    :meth:`~SmwLevelLoader._prime_loader` and :meth:`~SmwLevelLoader._run_loader`
    put back by hand from the patched image; and the player's start, the
    camera's, and the Layer 3 setting, which come from the tables below.

    Those six are correct on a rebuild for one reason only: it starts from a
    warm state of the *same level*, and the tables are indexed by the level
    number, so the warm state's values are this level's. That holds exactly
    while no patch moves the tables -- which is what
    :func:`patches_reach_sublevel_setup` is asked, and why an entrance edit has
    to take the full game-mode path.
    """
    return (
        # The four secondary-header tables, one byte per level. Bits of these
        # index everything below.
        (where.offset(where.secondary_header_y), LEVEL_SLOTS),
        (where.offset(where.secondary_header_x), LEVEL_SLOTS),
        (where.offset(where.secondary_header_fg_position), LEVEL_SLOTS),
        (where.offset(where.secondary_header_entrance), LEVEL_SLOTS),
        # Where the player starts: sixteen Y positions and eight X, each a low
        # and a high byte.
        (where.offset(where.entrance_y_low), ENTRANCE_Y_INDEX + 1),
        (where.offset(where.entrance_y_high), ENTRANCE_Y_INDEX + 1),
        (where.offset(where.entrance_x_low), ENTRANCE_X_INDEX + 1),
        (where.offset(where.entrance_x_high), ENTRANCE_X_INDEX + 1),
        # Where the camera starts, both layers of it.
        (where.offset(where.layer1_initial_y), INITIAL_Y_POSITIONS),
        (where.offset(where.layer2_initial_y), INITIAL_Y_POSITIONS),
        (where.offset(where.l2_vert_scroll_settings), L2_SCROLL_SETTINGS),
    )


def patches_reach_sublevel_setup(
    patches: Mapping[int, bytes] | None, where: Addresses
) -> bool:
    """Whether any of ``patches`` moves what :func:`sublevel_setup_tables` names.

    True means the rebuild shortcut would show the *previous* load's answer for
    the player's start, the camera and Layer 3, because the routine that reads
    these tables is not one it runs. The full game-mode load is the only path
    that follows such an edit.
    """
    return any(
        offset < base + size and offset + len(data) > base
        for offset, data in (patches or {}).items()
        for base, size in sublevel_setup_tables(where)
    )


def patches_reach_title_load(
    patches: Mapping[int, bytes] | None, where: Addresses
) -> bool:
    """Whether any of ``patches`` lands in the overworld sprite slot table.

    The slot table is the one patched thing read at title load rather than by
    the mode a request stages, so it is the one edit a cold run must boot
    through the title preparation to show
    (:meth:`CartSession.restore_boot`) -- and that boot costs enough wall
    clock that a run whose patches stay out of the table should not pay it.
    """
    from shiny_mushroom.overworld import SPRITE_TABLE_SIZE

    base = where.offset(where.overworld_sprite_slots)
    end = base + SPRITE_TABLE_SIZE
    return any(
        offset < end and offset + len(data) > base
        for offset, data in (patches or {}).items()
    )


#: How many (translevel, flags) pairs ``InitializeSaveData`` applies to a new
#: file's tile settings.
INITIAL_LEVEL_FLAG_PAIRS = 8


def initial_level_flags(rom: bytes, *, where: Addresses) -> tuple[tuple[int, int], ...]:
    """The (translevel, flags) pairs a new save file's tile settings start
    from -- the walkability the map opens with before anything is beaten.

    Read off the image rather than held as constants so a base that edits the
    table keeps its own opening. (Lunar Magic abandons this table for one of
    its own; a cart it has touched starts a test run from vanilla's opening
    instead.) Empty for an image too short to hold the table -- a stub, not a
    cartridge.
    """
    start = where.offset(where.initial_level_flags)
    end = start + INITIAL_LEVEL_FLAG_PAIRS * 2
    if len(rom) < end:
        return ()
    return tuple((rom[offset], rom[offset + 1]) for offset in range(start, end, 2))
