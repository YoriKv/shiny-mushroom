"""The game's colours: three tables, and every palette in the game inside them.

``DATATABLE_SMW_GlobalPalettes`` (``Banks/Bank00.asm``) is 2018 bytes of
ROM-form colour -- 15-bit ``0BBBBBGG GGGRRRRR``, two bytes each, 1009 of them --
and is nothing but ``incbin`` byte-ranges, in order, under a name apiece. Two
more tables sit in bank ``$03`` beside the sprites that read them: the eight
steps a Magikoopa fades through and the eight the Big Boo Boss does, 128 bytes
apiece, which no level ever loads and which nothing else in the editor would
otherwise reach.

**The document is all three laid end to end**, and everything here addresses
it by byte offset: the catalog below, the loader model in
:mod:`shiny_mushroom.palette_map`, and a capture off a running cartridge all
measure from the document's first byte. :data:`TABLES` is what says which table
an offset falls in -- and so which run of a cartridge it lives in, because the
three are three separate runs and a patch is one per table.

What the tables are cut *out of* is a second question, and the answer is eight
files. Every ROM map sets
``!Define_SMW_Global_UseIndividualPaletteFiles = !TRUE``, so the global table
reads a Lunar Magic ``.tpl`` per set where one was exported -- ``Sky.tpl``,
``Background.tpl``, ``Mode7.tpl``, ``Bowser.tpl``, ``IggyLarryPlatform.tpl`` --
and ``palettes/smw.pal`` for the 1584 bytes no ``.tpl`` covers; the fade tables
read ``MagiKoopa.tpl`` and ``FadingBoo.tpl``. :data:`SOURCES` is that map,
:func:`assemble` reads the document out of the files and :func:`split` writes
an edit back to whichever one it belongs to.

Three things follow, and they are the whole reason a palette edit is cheap here.

- **They are fixed-size plain files in the source tree**, so the project
  overlay carries them with no help from the build:
  :meth:`~shiny_mushroom.project.Project.save_palette` writes them through
  :meth:`~shiny_mushroom.project.Project._save_plain`, the size check is the
  room check, and reverting is deleting them.
- **A colour goes back to the file the table read it from**, and a file no edit
  reached is not written at all. What a ``.tpl`` holds outside the ranges the
  table reads is copied through untouched, so it stays a file Lunar Magic
  opens.
- **An edit is global.** The game has no per-level palette. Two levels that
  select background set 3 read the same twelve colours, so recolouring one
  recolours both -- which is a fact about the cartridge and has to be said out
  loud wherever the editing happens.

**The catalog is bundled, and it is the source of truth.** Every run inside the
blob is named -- ``..._Sky_Setting00``, ``..._Background_Setting03``,
``..._Bowser_Fade04``, ``..._YoshiBerry_Green`` -- in
``resources/palette-metadata.json``, keyed by symbol and edited by hand
(:mod:`shiny_mushroom.metadata`), which carries what the table's comments say
about a run as well as where its bytes are.

Deriving it at run time from the build's symbol file instead -- subtracting the
table's address off every ``SMW_GlobalPalettes_*`` symbol -- named the same runs
and cost a walk of three thousand symbols per redraw, but needed a **build**: a
project that had never been built named no runs at all.

**Where the tables sit in a cartridge is not here.** Offsets into the document
are the
same in every target and on every base, because they are offsets into files the
source tree holds, assembled in an order the source fixes. Where the ROM map
*placed* the table is a fact about the target -- ``$00B0A0`` on ``U``,
``$00B040`` on ``J`` -- and is the ``global_palettes`` role in
:mod:`smw_tools.rom_tables`, like every other table the editor reaches:
declared per target, cross-checked against each target's own
build, overridden by a project's build where there is one, and reachable as
:attr:`shiny_mushroom.addresses.Addresses.global_palettes` without one.

Those names say what a run of colours **is**. They are not how the loader
*indexes* it, and the two decompositions genuinely differ: sprite set 3 runs
from the middle of ``Sprites`` through ``InitBossFightReznor`` into
``InitBossFightBowser``, because Reznor's palette and sprite set 3's colours are
the same bytes. Which colours a header field selects is
:mod:`shiny_mushroom.palette_map`'s question, answered from the loader's own
index tables. Both are true, both address the same blob by byte offset, and an
edit made through either shows up in the other.

Qt-free, like everything outside :mod:`shiny_mushroom.ui`, and free of the
emulator too: this module knows a file of colours and nothing about what is on
screen.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from pathlib import Path

from shiny_mushroom import metadata

#: The runs of colour the document is, laid end to end: the global palette
#: table, then the eight fade steps a Magikoopa is drawn through, then the Big
#: Boo Boss's eight. Separate runs of the cartridge -- bank ``$00`` and bank
#: ``$03`` -- so a patch is one per table, and each names the
#: :mod:`smw_tools.rom_tables` role that says where a target put it.
TABLES = metadata.PALETTES.tables

#: What the tables are assembled out of, in emission order: a file, a range of
#: it and where those bytes land in the document. The catalog's account of the
#: ``incbin`` lines, so it is what says which file an edited colour belongs to.
SOURCES = metadata.PALETTES.sources

#: Every file those runs name, first use first and relative to the game folder
#: -- the paths the overlay mirrors and the ones ``Bank00.asm`` spells.
FILES = tuple(Path(name) for name in metadata.PALETTES.files())

#: The largest of them, and the one that holds every set Lunar Magic did not
#: export on its own. Named because the disassembly's own tooling speaks of it,
#: not because the table reads it alone -- it does not.
BLOB = Path("palettes/smw.pal")

#: Its size, which is fixed: the table is a run of ``incbin`` ranges placed by
#: the ROM map, so a table of any other length moves bytes. Counted off those
#: ranges rather than typed, so the number cannot part company with the table
#: it describes.
BLOB_SIZE = metadata.PALETTES.blob_size

#: One colour, in bytes. The blob is little-endian 15-bit BGR throughout.
COLOR_SIZE = 2

#: How many colours that is.
COLOR_COUNT = BLOB_SIZE // COLOR_SIZE

#: The mask a stored colour is worth keeping. Bit 15 is unused by the PPU and
#: reads back as zero from CGRAM, so an edit that set it would compare unequal
#: to a capture that never can.
COLOR_MASK = 0x7FFF

#: The namespace every name inside the table carries, and the table's own entry
#: label -- the symbol every offset in the catalog is measured from, and the one
#: :mod:`smw_tools.rom_tables` declares an address for.
LABEL_PREFIX = "SMW_GlobalPalettes_"
TABLE_LABEL = metadata.PALETTES.table
ENTRY_NAME = TABLE_LABEL.removeprefix(LABEL_PREFIX)

#: An edit held but not yet written: blob byte offset to 15-bit colour. Sparse
#: over the file rather than a copy of it, so "put this one colour back" is a
#: deletion rather than a diff against a remembered baseline, and an edit made
#: against one base still says something on another.
type Edits = Mapping[int, int]


class PaletteError(ValueError):
    """A palette blob, or a symbol file, this module cannot read."""


# -- the file ----------------------------------------------------------------


def check(blob: bytes) -> bytes:
    """``blob`` if it is the size the ROM map expects, or raise.

    The size is the only thing about the palette table that can be wrong in a
    way that matters to the build: every byte value is a colour.
    """
    if len(blob) != BLOB_SIZE:
        raise PaletteError(
            f"the palette table is {BLOB_SIZE:#x} bytes, not {len(blob):#x}"
        )
    return blob


def assemble(files: Mapping[Path, bytes]) -> bytes:
    """The table, out of the files the build reads it from.

    What the assembler does with the ``incbin`` lines, in Python: every run
    copied out of its file in emission order. The result is the blob the whole
    editor addresses by byte offset -- the catalog, the loader model and a
    capture off a running cartridge all measure from its first byte.
    """
    out = bytearray()
    for source in SOURCES:
        found = files.get(Path(source.file))
        if found is None:
            raise PaletteError(f"{source.file} is missing")
        if len(found) < source.end:
            raise PaletteError(
                f"{source.file} is {len(found):#x} bytes, so it has no "
                f"{source.start:X}-{source.end:X} to read"
            )
        out += found[source.start : source.end]
    return check(bytes(out))


def split(blob: bytes, files: Mapping[Path, bytes]) -> dict[Path, bytes]:
    """``files`` with ``blob``'s colours written back where they came from.

    The inverse of :func:`assemble`, and the reason a colour edited in the
    editor reaches the build: the table is cut out of several files now, so an
    edit lands in whichever one the table took that byte from.

    **Only the bytes the table reads are touched.** A ``.tpl`` is a Lunar Magic
    palette file -- a header, sixteen rows of sixteen colours -- and the table
    reads a few colours out of each row, so everything the ranges do not cover
    is copied through exactly as it was. That is what keeps the file something
    Lunar Magic still opens.
    """
    check(blob)
    out = {path: bytearray(data) for path, data in files.items()}
    for source in SOURCES:
        held = out.get(Path(source.file))
        if held is None:
            raise PaletteError(f"{source.file} is missing")
        if len(held) < source.end:
            raise PaletteError(
                f"{source.file} is {len(held):#x} bytes, so it has no "
                f"{source.start:X}-{source.end:X} to write"
            )
        held[source.start : source.end] = blob[source.at : source.at + source.size]
    return {path: bytes(data) for path, data in out.items()}


def unpack(buffer: bytes, at: int, default: int = -1) -> int:
    """The 15-bit colour ``buffer`` holds at byte ``at``, or ``default`` when
    it does not run that far.

    Every store of colour the editor reads is this shape -- the palette file, a
    captured CGRAM, the mirror a snapshot carries -- so the little-endian pair
    and the mask that drops bit 15 are written once, here.
    """
    if at < 0 or at + COLOR_SIZE > len(buffer):
        return default
    return (buffer[at] | (buffer[at + 1] << 8)) & COLOR_MASK


def pack(out: bytearray, at: int, value: int) -> None:
    """Write ``value`` into ``out`` at byte ``at``, masked as CGRAM reads back.

    Bit 15 is unused by the PPU and reads back as zero, so an edit that set it
    would compare unequal to a capture that never can -- the reason
    :data:`COLOR_MASK` exists. The inverse of :func:`unpack`.
    """
    out[at] = value & 0xFF
    out[at + 1] = (value >> 8) & (COLOR_MASK >> 8)


def color(blob: bytes, offset: int) -> int:
    """The 15-bit colour at byte ``offset``.

    :func:`unpack` for a palette file, where running off the end is a caller's
    mistake rather than a short capture: every offset in the file is a colour.
    """
    found = unpack(blob, offset)
    if found < 0:
        raise PaletteError(f"offset {offset:#x} is outside the palette file")
    return found


def colors(blob: bytes, offset: int, count: int) -> tuple[int, ...]:
    """``count`` colours running from byte ``offset``."""
    return tuple(color(blob, offset + n * COLOR_SIZE) for n in range(count))


def applied(blob: bytes, edits: Edits) -> bytes:
    """``blob`` with every edit written into it -- the form that is saved, and
    the form the cartridge is patched with.

    Every offset is checked, so a draft carrying an offset from a tree whose
    table has since shrunk is refused here rather than silently writing past
    the end of a file the build will happily assemble.
    """
    if not edits:
        return bytes(blob)
    out = bytearray(blob)
    for offset, value in edits.items():
        if offset < 0 or offset + COLOR_SIZE > len(out) or offset % COLOR_SIZE:
            raise PaletteError(f"offset {offset:#x} is not a colour in this file")
        pack(out, offset, value)
    return bytes(out)


def differences(blob: bytes, other: bytes) -> dict[int, int]:
    """Which colours ``other`` holds that ``blob`` does not, as edits.

    The inverse of :func:`applied`, and what turns a project's saved file back
    into a draft when one is opened.
    """
    check(blob)
    check(other)
    return {
        offset: color(other, offset)
        for offset in range(0, BLOB_SIZE, COLOR_SIZE)
        if color(blob, offset) != color(other, offset)
    }


# -- the document ------------------------------------------------------------


@dataclass(frozen=True)
class Palette:
    """The game's colours as the editor holds them: the disassembly's own file,
    plus the colours that have been changed.

    Held as the changes rather than as a copy of the file, so putting one
    colour back is a deletion rather than a diff against a remembered baseline,
    and a project that has been edited back to stock contributes the
    disassembly's bytes rather than this module's.

    Immutable, and **an operation with nothing to do returns the palette it was
    given** -- the same object, testable with ``is``. That identity is what
    keeps a no-op out of the undo stack, exactly as it does for a level
    (:class:`shiny_mushroom.edit.Level`).
    """

    #: Byte offset to 15-bit colour, sorted and masked, so two palettes holding
    #: the same colours compare equal whatever order they were built in.
    edits: tuple[tuple[int, int], ...] = ()

    @classmethod
    def of(cls, edits: Edits) -> Palette:
        """A palette holding exactly ``edits``, normalised and checked."""
        for offset in edits:
            if offset < 0 or offset + COLOR_SIZE > BLOB_SIZE or offset % COLOR_SIZE:
                raise PaletteError(f"offset {offset:#x} is not a colour in this file")
        return cls(
            tuple((offset, edits[offset] & COLOR_MASK) for offset in sorted(edits))
        )

    @classmethod
    def between(cls, base: bytes, other: bytes) -> Palette:
        """The palette that turns ``base`` into ``other`` -- what opening a
        project's saved file comes back as."""
        return cls.of(differences(base, other))

    @property
    def changed(self) -> dict[int, int]:
        """The edits as a mapping, for the lookups a swatch grid makes."""
        return dict(self.edits)

    @property
    def edited(self) -> bool:
        """Whether anything has been changed at all."""
        return bool(self.edits)

    def color(self, base: bytes, offset: int) -> int:
        """The colour at ``offset`` as this palette has it: the edit if there
        is one, the file's own otherwise."""
        held = self.changed
        return held[offset] if offset in held else color(base, offset)

    def image(self, base: bytes) -> bytes:
        """The whole file as this palette has it -- what is saved, and what a
        cartridge is patched with."""
        return applied(check(base), self.changed)

    def with_color(self, offset: int, value: int) -> Palette:
        """One colour changed."""
        return self.with_colors((offset,), value)

    def with_colors(self, offsets: Iterable[int], value: int) -> Palette:
        """Several colours set to one value, as one step.

        What a swatch shared by more than one offset commits: the berries are
        two rows of CGRAM apart and one run of the file, and a strip that
        offers them together has to move them together.
        """
        held = self.changed
        wanted = value & COLOR_MASK
        changing = {offset: wanted for offset in offsets}
        if all(held.get(offset) == wanted for offset in changing):
            return self
        return Palette.of(held | changing)

    def without(self, offsets: Iterable[int]) -> Palette:
        """Colours put back to the file's own."""
        held = self.changed
        dropped = {offset for offset in offsets if offset in held}
        if not dropped:
            return self
        return Palette.of(
            {offset: value for offset, value in held.items() if offset not in dropped}
        )

    def cleared(self) -> Palette:
        """Every colour put back."""
        return EMPTY if self.edited else self


#: A palette with nothing changed -- the document a project with no saved
#: colours opens as, and what `cleared` returns.
EMPTY = Palette()


# -- what the runs are called ------------------------------------------------


@dataclass(frozen=True)
class Region:
    """One named run of colours inside the blob.

    Read out of the bundled catalog rather than worked out here -- extents,
    title and all. Nothing corrects a label: where a run reads wrongly under the
    name the disassembly gives it, that is a defect in the disassembly and is
    fixed there, and the title here is what a panel says instead.
    """

    #: The name in the table's namespace: ``SMW_GlobalPalettes_YoshiBerry``.
    label: str

    #: Byte offsets into the blob. ``end`` is one past the last byte, and runs
    #: to the next name -- or to the end of the file for the last one.
    start: int
    end: int

    #: The run as a panel offers it: ``Background, setting 3``.
    title: str

    #: What the catalog says about it beyond that, or the empty string -- what
    #: the ``?``-block animation does with the flashing colours, why a colour
    #: edited in the cleared area sets may not survive Lunar Magic.
    note: str = ""

    @property
    def name(self) -> str:
        """The label without its namespace: ``Background_Setting03``, and
        ``MagiKoopaFadePalettes_Fade03`` out of the Magikoopa's own."""
        for table in TABLES:
            if self.label.startswith(table.prefix):
                return self.label.removeprefix(table.prefix)
        return self.label

    @property
    def count(self) -> int:
        """How many colours it holds."""
        return (self.end - self.start) // COLOR_SIZE

    def offsets(self) -> tuple[int, ...]:
        """Every colour's byte offset, in order."""
        return tuple(range(self.start, self.end, COLOR_SIZE))


def _region(run: metadata.PaletteRun) -> Region:
    return Region(symbol_label(run.symbol), run.start, run.end, run.title, run.note)


def symbol_label(symbol: str) -> str:
    """``symbol`` as the assembler spells it, whether it was given with the
    namespace on it or without.

    A bare name is the global table's -- ``Sprites``, ``YoshiBerry`` -- which
    is what the loader's transcription asks for and the only table whose runs
    are worth naming without one. The fade tables carry namespaces of their
    own, so anything already spelled as a symbol is left alone.
    """
    if any(symbol.startswith(table.prefix) for table in TABLES):
        return symbol
    return LABEL_PREFIX + symbol


def run(symbol: str) -> Region:
    """One run by name, with or without its namespace.

    What the loader's own transcription resolves through
    (:mod:`shiny_mushroom.palette_map`): it reaches for ``Sprites`` and
    ``YoshiBerry`` by label, exactly as the game's code does.
    """
    found = metadata.PALETTES.runs.get(symbol_label(symbol))
    if found is None:
        raise PaletteError(f"{symbol_label(symbol)} is not a run of the palette table")
    return _region(found)


def catalog() -> tuple[Region, ...]:
    """Every run inside the blob, in the order the file holds them.

    The **leaves** only, which tile the file exactly once: ``Sky_Setting00``
    rather than ``Sky``, both of which start on the table's first byte, and the
    three berry colours rather than ``YoshiBerry``. That is what a panel walks
    and what :func:`region_at` answers from -- a parent kept alongside its
    children would offer every one of its colours twice. The parents are still
    reachable by name through :func:`run`, which is how the loader's own
    transcription reaches them.
    """
    return CATALOG


def table_at(offset: int) -> metadata.PaletteTable:
    """Which table byte ``offset`` falls in -- which is what says where in a
    cartridge it lives, and so which patch carries it."""
    return metadata.PALETTES.table_at(offset)


def table(role: str) -> metadata.PaletteTable:
    """One table by its ``rom_tables`` role."""
    for found in TABLES:
        if found.role == role:
            return found
    raise PaletteError(f"{role} is not one of the palette tables")


def region_at(regions: Iterable[Region], offset: int) -> Region | None:
    """Which run byte ``offset`` falls in, or ``None`` past the end."""
    for region in regions:
        if region.start <= offset < region.end:
            return region
    return None


#: Read at import and kept, like the metadata it is built from: bundled data
#: cannot change while the app runs, and a colour being dragged rebuilds the
#: panel eight times a second.
CATALOG: tuple[Region, ...] = tuple(
    _region(found) for found in metadata.PALETTES.leaves()
)
