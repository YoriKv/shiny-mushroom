"""The Lunar Magic level container, which is how the disassembly stores a level.

A level's bytes are not in the ``.asm`` tree as bytes. ``smw/src/SMW/levels/``
holds 245 ``.mwl`` files -- Lunar Magic's own level format -- and Bank ``$06``,
``$07`` and ``$0C`` reach into them with a macro that reads the container's
offset table and ``incbin``\\ s one region out of it::

    %SMW_InsertLevelData(LEVEL_L1_105, 105, SMW_U, LAYER_1)

So a saved edit is a rewritten ``.mwl``, not a patched ROM, and this module is
what rewrites one. Editing anything else about the file is out of scope on
purpose: the regions this does not understand are copied through untouched, so
a level round-trips byte for byte and Lunar Magic can still open the result.

**The layout, as every file in the tree has it.** Four magic bytes, two lengths,
an unused word, the tool's own signature string, and then at ``$40`` a table of
eight ``(offset, size)`` pairs. The regions follow the table contiguously in
table order, the last one ending at the end of the file -- all 245 of them,
without exception, which is what lets a rewrite simply re-lay them out rather
than having to preserve holes.

Each data region begins with eight bytes of its own that the macro skips
(:data:`REGION_HEADER`), so the payload is what comes after them. For Layer 1
that payload is the five-byte level header followed by the object stream; for
the sprite region it is the sprite header byte followed by the sprite records.
Both end in the ``$FF`` their loaders stop at.

The eight are ``flags(4) address(3) 00``: the address is the one the level's
pointer-table entry held in the ROM the tool extracted from, and for Layer 2
the flags say what kind of thing that was. :data:`LAYER2_BACKGROUND` set means
the level's Layer 2 was a **background** -- the payload is then the tilemap
Lunar Magic decoded, as 16-bit Map16 words rather than the ROM's LC_RLE1
bytes -- and clear means an object stream, shaped like Layer 1's. The address
is a fact about somebody else's ROM, so nothing here resolves it; the
tilemap is what says which background, by content
(:meth:`Container.layer2_tilemap`).

**What else is in there.** The eight slots are level information, Layer 1,
Layer 2, sprites, palette, secondary entrances, ExAnimation, and the ExGFX and
bypass words, in that order -- Lunar Magic's format, written up at
https://github.com/Ankouno/SMW-Data/blob/master/Misc/MWL%20File%20Format.md.
The disassembly inserts three of them, and the editor writes a fourth: the
ExGFX words are where a level's own graphics row lives
(:attr:`Container.graphics_row`, :meth:`Container.with_graphics_row`) --
Lunar Magic's record of which file each slot loads, which the ``level-graphics``
feature reads through a fragment the build derives from the containers
(:mod:`smw_tools.level_graphics`). The other four are the tool's record of
things the ROM keeps elsewhere: nothing in this build reads them, and they
matter to whoever opens the file next -- Lunar Magic, or a container imported
from another hack. They are carried through a save untouched, and read here
only far enough to say what a container holds: :data:`SLOT_NAMES`,
:meth:`Container.region_size`, :attr:`Container.custom_palette`,
:attr:`Container.secondary_entrances` and :attr:`Container.has_exanimation`.
"""

from __future__ import annotations

import struct
from dataclasses import dataclass

from shiny_mushroom.hexnum import hexnum
from smw_tools.level_graphics import (
    BYPASS_BYTES,
    INHERIT,
    ROW_BYTES,
    bypass_with_row,
    row_from_bypass,
)

#: What a level container starts with. Checked rather than assumed, because the
#: alternative to noticing is writing a rebuilt table over something else's file.
MAGIC = b"LMS\x02"

#: Where the region table starts, and how wide one entry is. The table's *length*
#: is not stored: it runs from here to wherever the first region begins, which is
#: eight entries in every file the disassembly carries.
TABLE_START = 0x40
ENTRY_SIZE = 8

#: Bytes at the front of a data region that belong to the container rather than
#: to the level -- what the insertion macro adds ``$08`` to skip. Copied through
#: unchanged: a rewrite that dropped them would shift every payload eight bytes.
#: :data:`INFO` and :data:`EXGFX` are fields to their first byte and have no such
#: header, so :meth:`Container.payload` is for the data regions only.
REGION_HEADER = 8

#: Which table entry holds what, in the order Lunar Magic writes the eight. The
#: three the editor writes are Layer 1 -- the level header and its object
#: stream -- the sprite list, and the ExGFX words the level's graphics row is
#: kept in; Layer 2 is written for the levels whose pointer names one. The
#: other four are carried through without being changed, and read only to say
#: they are there.
INFO = 0
LAYER1 = 1
LAYER2 = 2
SPRITES = 3
PALETTE = 4
ENTRANCES = 5
EXANIMATION = 6
EXGFX = 7

#: What to call each slot in a view of what a container holds.
SLOT_NAMES = {
    INFO: "Level information",
    LAYER1: "Layer 1",
    LAYER2: "Layer 2",
    SPRITES: "Sprites",
    PALETTE: "Palette",
    ENTRANCES: "Secondary entrances",
    EXANIMATION: "ExAnimation",
    EXGFX: "ExGFX and bypasses",
}

#: The slots the disassembly never inserts and the editor never writes --
#: Lunar Magic's own record, which only a tool reading the file acts on.
CARRIED = (INFO, PALETTE, ENTRANCES, EXANIMATION)

#: A row keeping every slot the tileset's -- what a container with no row reads.
INHERIT_ROW = bytes([INHERIT]) * ROW_BYTES

#: The :data:`EXGFX` slot as every shipped container has it, and as a blank
#: one starts: no file in any of the row's nine words, the tool's no-file
#: number in ``AN2``, ``LT3``, ``BG2``, ``BG3`` and ``SP1``, and the stock
#: Layer 3 files ``GFX28``-``GFX2B`` in the last four.
STOCK_EXGFX = bytes.fromhex(
    "7f007f007f007f00ffffffffffffffffffffffffffff7f002b002a0029002800"
)

#: Bytes per secondary entrance in the :data:`ENTRANCES` region, after the
#: region's own eight.
ENTRANCE_SIZE = 8

#: The Layer 2 region's flag for a background: bit 2 of the little-endian
#: word its eight bytes open with. Clear, the region holds an object stream.
LAYER2_BACKGROUND = 0x04

#: How a background tilemap is laid out in the region -- two halves of sixteen
#: columns, each padded to thirty-two rows of 16-bit words -- and how the game
#: keeps it: the same two halves, twenty-seven rows deep, one byte per tile
#: (``SMW_BufferBGTilemap_Main`` decodes into exactly that). Folding one into
#: the other takes the first twenty-seven rows of each half and the low byte
#: of each word; the high byte is Lunar Magic's Map16 page, which the ROM
#: never stores.
TILEMAP_COLUMNS = 16
TILEMAP_ROWS = 27
TILEMAP_PADDED_ROWS = 32
TILEMAP_HALVES = 2


class MwlError(ValueError):
    """A container that could not be read, or could not be rebuilt."""


@dataclass(frozen=True)
class Container:
    """One ``.mwl`` file, as the parts a rewrite has to put back.

    ``prefix`` is everything before the region table -- magic, lengths and the
    signature string -- and ``regions`` is one entry per table slot, each the
    whole region including its eight-byte header. Between them they are the
    entire file, so :meth:`write` can rebuild it without consulting the original
    again.
    """

    prefix: bytes
    regions: tuple[bytes, ...]

    # -- reading ------------------------------------------------------------

    @classmethod
    def read(cls, data: bytes) -> Container:
        """Split a container into its regions.

        The table's length is derived from where the first region starts, which
        is the only thing in the file that says how many entries there are.
        """
        if len(data) < TABLE_START + ENTRY_SIZE or data[:4] != MAGIC:
            raise MwlError("not a Lunar Magic level container")
        first, _ = struct.unpack_from("<II", data, TABLE_START)
        if first < TABLE_START + ENTRY_SIZE or first > len(data):
            raise MwlError(f"region table cannot end at {hexnum(first, 0)}")
        count, remainder = divmod(first - TABLE_START, ENTRY_SIZE)
        if remainder:
            raise MwlError("region table is not a whole number of entries")
        regions = []
        for index in range(count):
            offset, size = struct.unpack_from(
                "<II", data, TABLE_START + index * ENTRY_SIZE
            )
            if offset + size > len(data):
                raise MwlError(f"region {index} runs past the end of the file")
            regions.append(data[offset : offset + size])
        return cls(prefix=data[:TABLE_START], regions=tuple(regions))

    def payload(self, region: int) -> bytes:
        """One region's contents, past the eight bytes the macro skips.

        This is what the assembler pulls into the ROM, and so what the editor
        reads a level out of: for :data:`LAYER1`, the five header bytes and the
        object stream; for :data:`SPRITES`, the sprite stream entire.

        A container whose table stops short of the slot is a file this cannot
        read rather than an index error: the table's length is derived from
        where the first region starts, so a truncated one is short by however
        many entries it lost.
        """
        if not 0 <= region < len(self.regions):
            raise MwlError(f"there is no region {region} in this container")
        return self.regions[region][REGION_HEADER:]

    @property
    def recorded_level(self) -> int | None:
        """The level number the tool stamped the container with, or ``None``.

        The :data:`INFO` region opens with a little-endian word saying which
        level Lunar Magic extracted, ahead of the secondary header and midway
        bytes it records beside it. It is a *record*, not a binding -- the
        disassembly connects containers to levels through the pointer tables,
        and for the Chocolate Island 2 sub-files the two genuinely disagree --
        which is exactly why it is worth being able to read.
        """
        info = self._region(INFO)
        if len(info) < 2:
            return None
        return info[0] | (info[1] << 8)

    @property
    def custom_palette(self) -> bool:
        """Whether the level says it uses the palette the container carries.

        Bit 0 of the Layer 1 region's first byte, and clear in all 245 shipped
        files: vanilla has no custom palettes, so their palette regions are a
        copy of what the ROM would have loaded anyway. An imported container
        with the bit set is one whose colours came with it.
        """
        layer1 = self._region(LAYER1)
        return bool(layer1) and bool(layer1[0] & 1)

    @property
    def secondary_entrances(self) -> int:
        """How many secondary entrances the container records.

        :data:`ENTRANCE_SIZE` bytes each after the region's own eight. The
        disassembly keeps its secondary entrances in the ROM's tables rather
        than in the containers, so these are Lunar Magic's copy, and only a
        tool inserting the file acts on them.
        """
        entrances = self._region(ENTRANCES)
        return max(0, len(entrances) - REGION_HEADER) // ENTRANCE_SIZE

    @property
    def layer2_is_background(self) -> bool:
        """Whether the level's Layer 2, where the tool extracted it from, was a
        background tilemap rather than an object stream --
        :data:`LAYER2_BACKGROUND` in the region's own header."""
        layer2 = self._region(LAYER2)
        return len(layer2) >= 4 and bool(layer2[0] & LAYER2_BACKGROUND)

    def layer2_tilemap(self) -> bytes | None:
        """The background tilemap the Layer 2 region holds, as the game keeps
        one: both halves, :data:`TILEMAP_ROWS` deep, one byte per tile -- what
        an LC_RLE1 blob under ``levels/backgrounds/`` decodes to, so the two
        compare byte for byte. ``None`` for a region that is not a background,
        or one too short to hold the layout.
        """
        if not self.layer2_is_background:
            return None
        words = self.payload(LAYER2)
        half = TILEMAP_COLUMNS * TILEMAP_PADDED_ROWS * 2
        if len(words) < half * TILEMAP_HALVES:
            return None
        kept = TILEMAP_COLUMNS * TILEMAP_ROWS * 2
        return b"".join(
            words[start : start + kept : 2]
            for start in range(0, half * TILEMAP_HALVES, half)
        )

    @property
    def has_exanimation(self) -> bool:
        """Whether the container carries ExAnimation data. Empty in every
        shipped file -- the region is written, with nothing after its header."""
        return len(self._region(EXANIMATION)) > REGION_HEADER

    @property
    def graphics_row(self) -> bytes:
        """The level's own graphics row, nine bytes in slot order -- FG1, FG2,
        BG1, FG3, SP1, SP2, SP3, SP4, then ``AN2`` -- out of the :data:`EXGFX`
        words, ``$FF`` where the slot keeps its tileset's file and, for the
        animated tiles, the game's own ``GFX33``.

        Lunar Magic's sixteen words, read by
        :func:`smw_tools.level_graphics.row_from_bypass`: ``$FFFF`` and the
        tool's no-file number are the tileset's, a number
        below ``$100`` is the file, and one above -- an ExGFX file with no
        counterpart here -- is the tileset's too. Every shipped container
        reads :data:`INHERIT_ROW`; :attr:`has_graphics_row` is whether this
        one does not.
        """
        region = self._region(EXGFX)
        if len(region) != BYPASS_BYTES:
            return INHERIT_ROW
        return row_from_bypass(region)

    @property
    def has_graphics_row(self) -> bool:
        """Whether any slot of :attr:`graphics_row` names a file."""
        return self.graphics_row != INHERIT_ROW

    def region_size(self, slot: int) -> int | None:
        """How many bytes the container gives one slot, its own leading bytes
        included, or ``None`` for a slot this file does not have.

        Whole regions rather than payloads, because what a slot puts in front
        of its contents differs by slot and this has to be answerable for all
        eight -- including the ones nothing here can read.
        """
        if not 0 <= slot < len(self.regions):
            return None
        return len(self.regions[slot])

    def _region(self, slot: int) -> bytes:
        """One region, or empty for a container that does not go that far."""
        return self.regions[slot] if slot < len(self.regions) else b""

    # -- writing ------------------------------------------------------------

    def replacing(self, region: int, payload: bytes) -> Container:
        """This container with one region's payload swapped out.

        The region's own eight bytes are kept, and so is every other region --
        including the ones nothing here understands. That is what makes a saved
        level a *level* edit rather than a rewritten file: everything the editor
        has no opinion about comes through unchanged.
        """
        if not 0 <= region < len(self.regions):
            raise MwlError(f"there is no region {region} in this container")
        kept = self.regions[region][:REGION_HEADER]
        regions = list(self.regions)
        regions[region] = kept + bytes(payload)
        return Container(prefix=self.prefix, regions=tuple(regions))

    def recording(self, level: int) -> Container:
        """This container stamped with ``level`` as its recorded number.

        The one word :attr:`recorded_level` reads, rewritten in place; every
        other byte of the info region -- the secondary header and midway
        bytes Lunar Magic keeps beside it -- and every other region come
        through unchanged. Still a record rather than a binding: the pointer
        tables decide who reads the file, and this only makes the file agree
        with them.
        """
        info = self._region(INFO)
        if len(info) < 2:
            raise MwlError("this container has no info region to record a level in")
        if not 0 <= level <= 0xFFFF:
            raise MwlError(f"{level:#x} is not a level number a container can record")
        regions = list(self.regions)
        regions[INFO] = level.to_bytes(2, "little") + info[2:]
        return Container(prefix=self.prefix, regions=tuple(regions))

    def with_graphics_row(self, row: bytes) -> Container:
        """This container holding ``row`` as its graphics row.

        The nine words the row maps to are rewritten
        (:func:`smw_tools.level_graphics.bypass_with_row`) and the other seven
        -- the tool's own files, real numbers on every shipped container --
        are left exactly as they are; so is a word that already reads as the
        byte it is given, which is what makes a container rewritten with the
        row it already holds byte-identical. A row of all ``$FF`` is how a
        row is taken away: there is no file to delete, only words to put
        back to ``$FFFF``.

        A container whose slot is not the tool's thirty-two bytes -- one made
        by hand, with nothing past the slot's entry -- reads as no row, and
        stays as it is for the inherit row; the first row that names a file
        gives it :data:`STOCK_EXGFX` with the row written in.
        """
        if EXGFX >= len(self.regions):
            raise MwlError("this container has no ExGFX slot to hold a graphics row")
        row = bytes(row)
        region = self.regions[EXGFX]
        if len(region) != BYPASS_BYTES:
            if row == INHERIT_ROW:
                return self
            region = STOCK_EXGFX
        regions = list(self.regions)
        regions[EXGFX] = bypass_with_row(region, row)
        return Container(prefix=self.prefix, regions=tuple(regions))

    def write(self) -> bytes:
        """Rebuild the file: the table re-derived, the regions laid out after it.

        Contiguously and in table order, which is how every container in the
        tree is already arranged -- so a container read and written back with
        nothing replaced is byte-identical, and one with a longer region simply
        pushes what follows it along.
        """
        table = bytearray()
        body = bytearray()
        start = TABLE_START + len(self.regions) * ENTRY_SIZE
        for region in self.regions:
            table += struct.pack("<II", start + len(body), len(region))
            body += region
        return bytes(self.prefix + table + body)


def read_level(data: bytes) -> tuple[bytes, bytes]:
    """A container's Layer 1 and sprite payloads: ``(header + objects, sprites)``.

    The pair the editor works in, and the same pair
    :func:`~shiny_mushroom.rom_patches.object_stream` and
    :func:`~shiny_mushroom.rom_patches.sprite_stream` cut out of a cartridge -- so a
    level read from the source tree and one read from a ROM are the same bytes,
    and :class:`~shiny_mushroom.edit.Level` cannot tell which it was handed.
    """
    container = Container.read(data)
    return container.payload(LAYER1), container.payload(SPRITES)


def layer2_payload(data: bytes) -> bytes:
    """A container's Layer 2 payload: five header bytes then the object stream.

    The same shape as :data:`LAYER1`'s, because for the twenty-six level
    numbers whose Layer 2 is a level rather than a background it *is* a level's
    object stream -- and the loader steps over the five in front of it exactly
    as it does Layer 1's.
    """
    return Container.read(data).payload(LAYER2)


def write_level(
    data: bytes,
    layer1: bytes,
    sprites: bytes,
    layer2: bytes | None = None,
    graphics: bytes | None = None,
) -> bytes:
    """``data`` with its Layer 1 and sprite payloads replaced.

    ``layer1`` is the five header bytes followed by the object stream, because
    that is one region in the container and the header is not separable from it.

    ``layer2`` is the same shape for the Layer 2 region, and ``None`` -- the
    usual case -- leaves that region exactly as it was. A container is often
    reached for one of its three regions and not the others: a level whose
    Layer 2 is a background has one here that no bank inserts, and a level
    reading somebody else's Layer 2 writes that container for its Layer 2
    alone.

    ``graphics`` is the level's own graphics row for the ExGFX words
    (:meth:`Container.with_graphics_row`), and ``None`` leaves them alone.
    """
    container = (
        Container.read(data).replacing(LAYER1, layer1).replacing(SPRITES, sprites)
    )
    if layer2 is not None:
        container = container.replacing(LAYER2, layer2)
    if graphics is not None:
        container = container.with_graphics_row(graphics)
    return container.write()


def blank_container(level: int | None = None) -> bytes:
    """A minimal container holding an empty level -- what a brand-new file
    starts from.

    Eight regions in Lunar Magic's own order: the info region carries
    ``level`` as the recorded number (a record, not a binding -- the pointer
    tables are what connect a container to a level), the Layer 1 region a
    zeroed five-byte header and an object stream that is only its ``$FF``
    terminator, the sprite region an empty list, the ExGFX words
    :data:`STOCK_EXGFX` -- no row, but a slot a row can be written into --
    and the rest nothing past their own header bytes: no palette claimed,
    nothing carried.
    """
    info = (
        bytes(REGION_HEADER)
        if level is None
        else level.to_bytes(2, "little") + bytes(REGION_HEADER - 2)
    )
    empty = Container(
        prefix=MAGIC + bytes(TABLE_START - len(MAGIC)),
        regions=(info, *(bytes(REGION_HEADER) for _ in range(6)), STOCK_EXGFX),
    ).write()
    return write_level(empty, bytes(5) + b"\xff", b"\x00\xff")
