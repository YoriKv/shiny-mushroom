"""Per-level custom palettes: one 514-byte blob a level wears whole.

The game has no per-level palette -- every level assembles its colours out of
the global table by header setting, which is why an edit in
:mod:`shiny_mushroom.palettes` is global. This module is the other answer: a
level that carries a **blob of its own** -- its back area colour and all 256
CGRAM entries, copied over the mirror after the stock buffering has run -- so
recolouring it touches no other level.

**The blob is the level-load result, not the palette file.** Two bytes of back
area colour, then the 512-byte palette mirror exactly as the console holds it
(``$7E0701-$7E0902``, one contiguous run), which is what lets the game apply
one with a single copy and lets the editor seed one from the scene already on
screen. There is no arithmetic between the blob and CGRAM: colour ``n`` of the
screen is word ``n`` of the blob, two bytes in.

How a blob reaches a cartridge is the ``level-custom-palettes`` feature's job
-- compiled asm behind a define, ``Config/LevelCustomPalettes.asm`` in the
disassembly -- fed by two fragments this module renders and the project
writes into the overlay beside the ``.pal`` blobs (``palettes/levels/``).
What this module holds is the format, the document and those fragments:

- :class:`LevelPalettes` -- which levels carry one, immutable, with the same
  no-op-returns-self identity every other document here keeps, so
  :class:`~shiny_mushroom.edit.History` can recognise a step that did nothing.
- :class:`PaletteDocument` -- the palette panel's whole document: the global
  file's edits (:class:`~shiny_mushroom.palettes.Palette`) beside the level
  palettes, in **one** undo stack, because the panel is one surface.
- The **virtual offset space**. The panel's plumbing speaks byte offsets into
  the global palette file -- every signal, every swatch, every edit dict. A
  level palette's bytes join that space above :data:`VIRTUAL_BASE`, far past
  the file's end, so a swatch, a pick and a recolour need no second channel:
  :func:`offset_of` places a byte, :func:`holder` answers whose it is.

Qt-free, like everything outside :mod:`shiny_mushroom.ui`.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass, replace
from pathlib import Path

from shiny_mushroom import palette_map, palettes
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.palettes import Palette, PaletteError, pack, unpack
from smw_tools.features import LEVEL_CUSTOM_PALETTES
from smw_tools.levels import LEVEL_BANK_END, LEVEL_BANK_RUN

#: How many levels the game has -- the pointer table's height, and the bound
#: every level number here is checked against.
LEVELS = 0x200

#: One blob: the back area colour, then the 512-byte palette mirror.
BACKDROP_AT = 0
COLORS_AT = 2
SIZE = COLORS_AT + palette_map.CGRAM_COLORS * palettes.COLOR_SIZE

#: The labels the feature's asm speaks: the pointer table at the reserved
#: run's fixed head, and one data label per dressed level, spelled the way
#: the symbol file flattens the fragments' namespace.
POINTERS_LABEL = "SMW_LevelCustomPalettes_Pointers"
DATA_LABEL_PREFIX = "SMW_LevelCustomPalettes_Data_"

#: The two fragments the editor writes into the overlay, shadowing the
#: disassembly's stock copies (all-zero rows, no blobs), and the folder the
#: ``.pal`` blobs sit in beside them.
POINTERS_FRAGMENT = Path("palettes/levels/level-palettes.asm")
DATA_FRAGMENT = Path("palettes/levels/level-palette-data.asm")

#: What the feature puts at its head in the level bank before any blob: the
#: pointer table -- three bytes a level -- and the stubs. The head is the
#: feature's declared block
#: (:attr:`smw_tools.features.Feature.block_bytes`), so the size is stated
#: once, where the run that holds it is; the stubs are whatever the block is
#: not the table. One size on every cartridge: the level number stash the
#: copy reads sits at the bank's own head, in front of every occupant.
#: :func:`bytes_for` is the whole of what the palettes occupy; the bank's
#: other occupant, the level streams the managed level banks pack, opens
#: behind that.
TABLE_BYTES = 3 * LEVELS
HEAD_BYTES = LEVEL_CUSTOM_PALETTES.block_bytes
STUB_BYTES = HEAD_BYTES - TABLE_BYTES

#: How many levels can wear one with the level bank to themselves: the run
#: less the head, floored to whole blobs. The ceiling of the format rather
#: than of any cartridge -- a cartridge sharing the bank with packed level
#: streams, or with the per-level graphics ahead, holds fewer, which
#: :meth:`~shiny_mushroom.project.Project.level_palette_capacity` prices
#: through :func:`capacity`.
CAPACITY = (LEVEL_BANK_END - LEVEL_BANK_RUN - HEAD_BYTES) // SIZE


def head_bytes() -> int:
    """The fixed head: the pointer table and the stubs, which is the
    feature's declared block."""
    return LEVEL_CUSTOM_PALETTES.block_bytes


def bytes_for(count: int) -> int:
    """How many bytes of the level bank ``count`` dressed levels take: the
    fixed head, and a blob each."""
    return head_bytes() + count * SIZE


def capacity(room: int) -> int:
    """How many levels can wear one in ``room`` bytes of the level bank:
    whole blobs after the head, and none at all where the head itself does
    not fit."""
    return max(0, (room - head_bytes()) // SIZE)


#: Where the virtual offsets start. The real document -- the global palette
#: file and the two fade tables -- is a couple of thousand bytes, so anything
#: at or past this is a level palette's byte and nothing else's.
VIRTUAL_BASE = 0x10000

#: CGRAM entries a level palette holds but does not decide, kept unmapped in
#: :func:`provenance` so the panel hatches them rather than offering an edit
#: the screen would not keep:
#: colour 0 of every row is zeroed at upload so the backdrop shows through;
#: colour ``$64`` is rewritten every frame from the flashing run; and the
#: player's ten are re-uploaded every frame from the global file.
UNDECIDED = frozenset(
    {row * palette_map.ROW for row in range(palette_map.ROWS)}
    | {0x64}
    | set(
        range(
            palette_map.PLAYER_FIRST,
            palette_map.PLAYER_FIRST + palette_map.PLAYER_COUNT,
        )
    )
)


def check(blob: bytes) -> bytes:
    """``blob`` if it is the size a level palette is, or raise."""
    if len(blob) != SIZE:
        raise PaletteError(f"a level palette is {SIZE:#x} bytes, not {len(blob):#x}")
    return blob


def check_level(level: int) -> int:
    """``level`` if the game has it, or raise."""
    if not 0 <= level < LEVELS:
        raise PaletteError(
            f"level {hexnum(level, 3)} is not one of the game's {LEVELS}"
        )
    return level


def from_scene(cgram: bytes, back_area_color: int) -> bytes:
    """A level palette holding exactly what is on screen.

    What ticking the box starts from: the console's own CGRAM for the level --
    a capture, recoloured or not -- and the backdrop beside it. A capture
    shorter than CGRAM pads with black, the same reading a swatch grid gives
    it.
    """
    out = bytearray(SIZE)
    pack(out, BACKDROP_AT, max(back_area_color, 0))
    for index in range(palette_map.CGRAM_COLORS):
        pack(out, byte_of(index), max(unpack(cgram, index * palettes.COLOR_SIZE, 0), 0))
    return bytes(out)


#: The sizes an outside palette file can be, and what each one is. Lunar
#: Magic's own order is the 256 colours **then** the back area colour --
#: every shipped container's palette region and that tool's ``.pal`` export
#: are this shape -- where the blob keeps the backdrop in front; a bare
#: 512-byte CGRAM dump and the disassembly's ``.tpl`` (a four-byte header
#: over the same 512) carry no backdrop at all, and a 768-byte file is 256
#: colours of 8-bit RGB, which is how a tile editor writes one.
LM_SIZE = palette_map.CGRAM_COLORS * palettes.COLOR_SIZE + palettes.COLOR_SIZE
CGRAM_SIZE = palette_map.CGRAM_COLORS * palettes.COLOR_SIZE
TPL_MAGIC = b"TPL\x02"
RGB_SIZE = palette_map.CGRAM_COLORS * 3


def read_pal(data: bytes, backdrop: int = 0) -> bytes:
    """A blob from a palette file somebody exported, recognised by its size.

    ``backdrop`` is the back area colour to keep where the file carries none
    -- the scene's own, so importing a bare palette recolours the tiles and
    leaves the sky as it was. What cannot be read is refused by name,
    with the shapes that can.
    """
    data = bytes(data)
    if len(data) == LM_SIZE:
        return check(data[CGRAM_SIZE:] + data[:CGRAM_SIZE])
    if len(data) == CGRAM_SIZE:
        return check(_backdrop_word(backdrop) + data)
    if len(data) == len(TPL_MAGIC) + CGRAM_SIZE and data.startswith(TPL_MAGIC):
        return check(_backdrop_word(backdrop) + data[len(TPL_MAGIC) :])
    if len(data) == RGB_SIZE:
        out = bytearray()
        for at in range(0, RGB_SIZE, 3):
            r, g, b = (component >> 3 for component in data[at : at + 3])
            out += (r | (g << 5) | (b << 10)).to_bytes(2, "little")
        return check(_backdrop_word(backdrop) + bytes(out))
    raise PaletteError(
        f"{len(data):,} bytes is not a palette file this can read: one is "
        f"Lunar Magic's {LM_SIZE} (the colours then the back area colour), a "
        f"{CGRAM_SIZE}-byte CGRAM dump, a .tpl, or {RGB_SIZE} bytes of RGB"
    )


def from_container(payload: bytes) -> bytes:
    """A blob from the palette region a level container carries -- Lunar
    Magic's order, which :func:`read_pal` reads."""
    if len(payload) != LM_SIZE:
        raise PaletteError(
            f"the container's palette region holds {len(payload):,} bytes, "
            f"not the {LM_SIZE} a level palette is"
        )
    return read_pal(payload)


def _backdrop_word(color: int) -> bytes:
    return (color & palettes.COLOR_MASK).to_bytes(2, "little")


def byte_of(index: int) -> int:
    """Where CGRAM colour ``index`` sits inside a blob."""
    return COLORS_AT + index * palettes.COLOR_SIZE


def offset_of(level: int, byte: int) -> int:
    """Byte ``byte`` of ``level``'s palette, as a virtual document offset."""
    return VIRTUAL_BASE + check_level(level) * SIZE + byte


def holder(offset: int) -> tuple[int, int] | None:
    """Which level's palette a virtual offset belongs to, and which byte of
    it -- or ``None`` for an offset in the real document."""
    if offset < VIRTUAL_BASE:
        return None
    level, byte = divmod(offset - VIRTUAL_BASE, SIZE)
    if level >= LEVELS:
        raise PaletteError(f"offset {offset:#x} is past the last level's palette")
    return level, byte


def provenance(level: int) -> list[int]:
    """Where each of the screen's 256 colours lives in ``level``'s blob.

    The custom-palette counterpart of
    :func:`shiny_mushroom.palette_map.level_provenance`, and trivially total
    where that one is modelled and checked: the blob *is* the mirror, so
    colour ``n`` is word ``n``, except the entries the game decides after the
    copy (:data:`UNDECIDED`), which come back
    :data:`~shiny_mushroom.palette_map.UNMAPPED` exactly as they do there.
    """
    return [
        palette_map.UNMAPPED if index in UNDECIDED else offset_of(level, byte_of(index))
        for index in range(palette_map.CGRAM_COLORS)
    ]


def backdrop_offset(level: int) -> int:
    """The back area colour's virtual offset -- a real, editable byte of the
    blob, where the stock path reads a header setting."""
    return offset_of(level, BACKDROP_AT)


def scene_diffs(
    level: int, blob: bytes, cgram: bytes, back_area_color: int
) -> dict[int, int]:
    """What ``blob`` changes about the scene on screen, keyed by virtual offset.

    The recolour path's food: the capture the canvas was drawn from against
    the palette the document says the level wears, exactly the shape
    :func:`shiny_mushroom.palette_map.recolored` eats. Measured against the
    **capture** whatever it was booted with -- a capture that already wears
    the blob (a run the patch reached) diffs to nothing, and one booted before
    any build diffs everywhere the custom palette departs from stock.
    """
    check(blob)
    shown = from_scene(cgram, back_area_color)
    return {
        offset_of(level, at): unpack(blob, at, 0)
        for at in range(0, SIZE, palettes.COLOR_SIZE)
        if unpack(blob, at, 0) != unpack(shown, at, 0)
    }


@dataclass(frozen=True)
class LevelPalettes:
    """Which levels wear a palette of their own, and what each one holds.

    Immutable, and an operation with nothing to do returns the object it was
    called on -- the identity :class:`~shiny_mushroom.edit.History` recognises
    a no-op by, same as :class:`~shiny_mushroom.palettes.Palette`.
    """

    #: ``(level, blob)`` pairs, sorted by level, so two documents holding the
    #: same palettes compare equal whatever order they were built in.
    held: tuple[tuple[int, bytes], ...] = ()

    @classmethod
    def of(cls, palettes_by_level: Mapping[int, bytes]) -> LevelPalettes:
        """A document holding exactly these, checked and normalised."""
        return cls(
            tuple(
                (check_level(level), check(palettes_by_level[level]))
                for level in sorted(palettes_by_level)
            )
        )

    @property
    def as_mapping(self) -> dict[int, bytes]:
        """The palettes as a mapping -- what a save writes."""
        return dict(self.held)

    @property
    def levels(self) -> tuple[int, ...]:
        """Every level that wears one, in order."""
        return tuple(level for level, _ in self.held)

    def get(self, level: int) -> bytes | None:
        """``level``'s palette, or ``None`` while it wears the game's own."""
        for held, blob in self.held:
            if held == level:
                return blob
        return None

    def with_palette(self, level: int, blob: bytes) -> LevelPalettes:
        """``level`` wearing ``blob`` -- the tick, and any whole-blob change."""
        if self.get(level) == check(blob):
            return self
        return LevelPalettes.of(self.as_mapping | {check_level(level): blob})

    def without(self, level: int) -> LevelPalettes:
        """``level`` back on the game's own colours -- the untick."""
        held = self.as_mapping
        if level not in held:
            return self
        del held[level]
        return LevelPalettes.of(held)

    def with_color(self, level: int, byte: int, value: int) -> LevelPalettes:
        """One colour of one level's palette changed."""
        blob = self.get(level)
        if blob is None:
            raise PaletteError(f"level {hexnum(level, 3)} has no palette of its own")
        if not 0 <= byte <= SIZE - palettes.COLOR_SIZE or byte % palettes.COLOR_SIZE:
            raise PaletteError(f"byte {byte:#x} is not a colour of a level palette")
        if unpack(blob, byte) == (value & palettes.COLOR_MASK):
            return self
        out = bytearray(blob)
        pack(out, byte, value)
        return self.with_palette(level, bytes(out))

    def color(self, level: int, byte: int) -> int:
        """The colour at ``byte`` of ``level``'s palette."""
        blob = self.get(level)
        if blob is None:
            raise PaletteError(f"level {hexnum(level, 3)} has no palette of its own")
        found = unpack(blob, byte)
        if found < 0:
            raise PaletteError(f"byte {byte:#x} is outside a level palette")
        return found


#: A document with no level dressed differently -- what a fresh project holds.
NONE = LevelPalettes()


# -- the fragments the build assembles ----------------------------------------


def data_label(level: int) -> str:
    """The label a level's blob is emitted under, as the symbol file spells
    it."""
    return f"{DATA_LABEL_PREFIX}{check_level(level):03X}"


def pal_name(level: int) -> str:
    """What a level's blob file is called beside the fragments."""
    return f"{check_level(level):03X}.pal"


_GENERATED = (
    "; Generated by Shiny Mushroom -- the levels this project dresses in\n"
    "; palettes of their own. Do not edit: this file is rewritten whenever a\n"
    "; level's custom palette is saved or removed, and hand edits do not\n"
    "; survive. Only assembled under !Define_SMW_LevelCustomPalettes -- see\n"
    "; Config/LevelCustomPalettes.asm, and the disassembly's stock copy for\n"
    "; what the fragment is.\n"
)


def pointer_fragment(levels: Iterable[int]) -> str:
    """The pointer-table fragment: one ``dl`` row per level, a data label for
    a dressed one and zero for the rest."""
    dressed = {check_level(level) for level in levels}
    rows = [
        f"\tdl {f'Data_{level:03X}' if level in dressed else '$000000'}"
        f"\t; {level:03X}\n"
        for level in range(LEVELS)
    ]
    return _GENERATED + "Pointers:\n" + "".join(rows)


def data_fragment(levels: Iterable[int]) -> str:
    """The blobs fragment: one label and ``incbin`` per dressed level, the
    ``.pal`` files sitting beside it in the same folder."""
    parts = [_GENERATED]
    for level in sorted({check_level(level) for level in levels}):
        parts.append(f'Data_{level:03X}:\n\tincbin "{pal_name(level)}"\n')
    return "".join(parts)


@dataclass(frozen=True)
class PaletteDocument:
    """Everything the palette panel edits, as one undo stack sees it.

    The global file's changes and the level palettes are two stores with two
    savers, but the panel is **one surface** -- one selection, one Ctrl+Z --
    so they undo as one document. Construction preserves the no-op identity:
    a part that did not move keeps the document that held it.
    """

    shared: Palette = Palette()
    levels: LevelPalettes = NONE

    def with_shared(self, held: Palette) -> PaletteDocument:
        return self if held is self.shared else replace(self, shared=held)

    def with_levels(self, held: LevelPalettes) -> PaletteDocument:
        return self if held is self.levels else replace(self, levels=held)
