"""What the disassembly calls things, read once from the bundled metadata.

The cartridge holds no names. An object number is three bits and a nibble, a
sprite number is a byte, and what either one *is* was decided by whichever
routine the game dispatches to -- so the only place the vocabulary exists is the
disassembly's own labels, `SMW_StandardObj05_Coins_Main` and `.NorSpr02B_Chuck`.

That is the rule for what belongs here: **everything the binary does not carry**.
The names, and the two tables that are read out of the assembly's control flow
rather than out of a table -- which tileset shares which object list, which
sprite numbers the loader intercepts before the arithmetic reaches them.
Anything a level's own bytes say is parsed from those bytes and is not metadata.

**All three files are written by hand and are the source of truth.** Each was
seeded once out of the disassembly -- the object and sprite dispatch tables, and
the global palette table's `incbin` ranges -- and is edited directly from then
on. Nothing regenerates them, so a name that reads better than the routine it
came from stays that way, and a correction sticks.

The disassembly still owns the *structure*, and that is checked rather than
assumed: `editor/tests/test_level_metadata.py` asserts the object and sprite
catalogs name exactly the numbers the dispatch tables dispatch, by the numbers
and not by the names, so a sprite gained, lost or renumbered fails with a line
number rather than by drawing the wrong thing.

`resources/palette-metadata.json` carries more than the ranges it was seeded
from, because most of what is worth saying about a run of colours was in the
table's comments rather than in its `incbin` lines. `Flashing` and `YoshiBerry`
were each cut into pieces the table commented but did not name, and asking for
them here is what got them labelled in `Bank00.asm` -- a label emits no bytes,
so naming a run the editor already had a name for was free. Every key is
therefore a symbol today, which is why `labelled` is written only when it is
false and today never is. `editor/tests/test_palette_metadata.py` keeps the rest
honest: the runs have to tile the file, every range the table cuts has to be a
boundary here, and the two sets of names have to agree.

**Nothing writes these files at all.** Two tools still *measure* what two of
their blocks describe -- `editor/tools/measure_object_sizes.py` for `sizes`,
over a sweep of the running loader, and `scan_sprite_usage.py` for `usage`, over
every level container -- and each prints its result **against** what the file
already says, as the lines to change. Applying them is a decision, which is the
whole point: a measurement is a reading, a reading can be wrong, and the
correction someone made here is the likelier of the two to be right.

**One thing in here is typed, and it is the one thing the disassembly does not
answer**: what sort of sprite each number is -- an enemy, a powerup, a platform.
No table in the cartridge says it and no combination of tweaker bits implies it.
It is written down in `smw_tools.sprite_categories`, which is generated into the
same file and refuses to write one that has fallen out of step with the names.

Keys are the two-digit hex the disassembly numbers them by, since JSON has no
integer keys; this module turns them back into the integers everything else
holds, so a caller never sees a string. The palettes are the one file keyed by
**symbol** instead, because a run of colours has no number -- what addresses it
is the label the table gives it and the loader reaches for.
"""

from __future__ import annotations

import json
from dataclasses import dataclass

from shiny_mushroom import resources

#: The bundled files, by the names `smw_tools` writes them under.
OBJECT_FILE = "object-metadata.json"
SPRITE_FILE = "sprite-metadata.json"
PALETTE_FILE = "palette-metadata.json"


#: What a nibble of the settings byte turns out to be, from
#: `editor/tools/measure_object_sizes.py`. The whole vocabulary.
WIDTH = "width"
HEIGHT = "height"
#: An extent in the object's *own* units rather than in blocks -- a slope's
#: length is counted in slope steps, and how far a step reaches depends on which
#: slope. Still a size, and still the thing a user would want to change; just
#: not a block count, so nothing may turn it into one.
LENGTH = "length"
#: Changes what is drawn rather than how far it reaches.
VARIANT = "variant"
#: The loader never finished, so nothing is claimed.
UNKNOWN = "unknown"

#: The roles that are an extent of some kind, and so worth offering as a size.
EXTENTS = frozenset({WIDTH, HEIGHT, LENGTH})


@dataclass(frozen=True)
class ObjectSize:
    """What one object does with its settings byte.

    Either two nibbles with a role each, or -- for object `$21`, the wide ground
    ledge -- one field over the whole byte, which is how a byte read without
    masking looks from outside.

    **No step is carried, deliberately.** For an object whose other nibble picks
    a shape, how far a step of the extent reaches depends on which shape: object
    `$12`'s length grows the footprint by one, two or four columns depending on
    the slope, and some slopes do not grow by a fixed amount at all. A stored
    step would be right for one variant and wrong for the rest -- and nothing
    needs one, because the footprint comes back from the loader after the edit.
    """

    low: str = UNKNOWN
    high: str = UNKNOWN
    #: Set when the whole byte is one field, in which case :attr:`low` and
    #: :attr:`high` are both that role and the two must not be offered apart.
    whole: str | None = None
    #: Which of ``low``/``high``/``byte`` sends the object across the whole
    #: level when it is zero. A size field's one value nobody ever means.
    runaway: frozenset[str] = frozenset()

    @property
    def sized(self) -> bool:
        """Whether this object's byte is a plain width and height in blocks."""
        return self.whole is None and self.low == WIDTH and self.high == HEIGHT

    @property
    def accounted_for(self) -> bool:
        """Whether every bit of the byte has a role.

        The question a panel asks before offering the raw byte as well: when
        both nibbles are named -- or one field took the whole byte -- there is
        nothing in it the fields above do not already say, and the raw box is
        the same value written a second way. One unmeasured nibble is enough to
        make it the only way to reach what is in there.
        """
        return self.whole is not None or UNKNOWN not in (self.low, self.high)


@dataclass(frozen=True)
class ObjectMetadata:
    """What the object dispatch tables in bank `$0D` say, and what the loader
    was measured doing with each object's settings byte."""

    #: Tileset number -> the object table it uses. Fifteen tilesets, five tables.
    tileset_groups: dict[int, str]
    #: Settings byte -> name, for objects whose number is zero.
    extended: dict[int, str]
    #: The settings bytes among those whose dispatch entry is ``$000000``. The
    #: loader long-jumps to it, so a level holding one of these does not load --
    #: the machine ends up in the first bytes of bank ``$00`` -- and nothing can
    #: draw a picture of one. Read out of the bank rather than judged here, and
    #: `editor/tests/test_level_metadata.py` checks it still is what the bank
    #: says. Empty when the bundled file predates the reading, which reads as
    #: "no object is known to crash" and costs a failed probe batch, not a wrong
    #: picture.
    crashes: frozenset[int]
    #: Group name -> {object number -> name}.
    standard: dict[str, dict[int, str]]
    #: Group name -> {object number -> what its settings byte is}. Empty when
    #: the bundled file predates the measurement, which every reader has to
    #: cope with by falling back to the raw byte.
    sizes: dict[str, dict[int, ObjectSize]]

    def size_of(self, tileset: int, number: int) -> ObjectSize:
        """What object ``number`` does with its settings byte in ``tileset``.

        An unmeasured object gets an all-``unknown`` answer rather than a
        guess, which is what makes the raw settings byte the honest fallback.
        """
        group = self.tileset_groups.get(tileset & 0x0F)
        return self.sizes.get(group or "", {}).get(number, ObjectSize())


@dataclass(frozen=True)
class SpriteMetadata:
    """What the four sprite dispatch tables say, each by the index its own
    dispatcher uses -- which is not the level's sprite number for three of them.
    :func:`shiny_mushroom.sprites.name_of` does that arithmetic."""

    #: Sprite number -> name, for `$00`-`$C8`.
    normal: dict[int, str]
    #: Shooter ID -> name, counting from 1 as the game numbers them.
    shooter: dict[int, str]
    #: Generator ID -> name, likewise.
    generator: dict[int, str]
    #: Sprite number -> name, for the layer scroll commands.
    scroll: dict[int, str]
    #: Sprite number -> name, for the numbers that load several sprites at once
    #: rather than the one the record names.
    loaders: dict[int, str]

    #: Sprite number -> what sort of thing it is, for **every** number a
    #: dispatch table names. Flat, so that
    #: :func:`shiny_mushroom.sprites.category_of` is a lookup and no part of a
    #: category is worked out while the app runs: it is the same answer in every
    #: level and every session, so there is nothing for a rule to be a function
    #: of. Flat over every number rather than only the curated ones, so the
    #: ranges the loader branches on are written out here too --
    #: `editor/tests/test_sprite_category_table.py` checks they still say what
    #: those ranges imply.
    #:
    #: **The one judgement in this file.** Everything else here is read back out
    #: of the disassembly; no table in the cartridge says a Koopa is an enemy.
    #: `smw_tools.sprite_categories` is where the judgement is written down --
    #: the normal sprites, which are the ones with anything to decide -- and
    #: what checks it against the dispatch table, both ways, so a sprite cannot
    #: quietly fall out of it.
    categories: dict[int, str]

    #: Sprite number -> how many times the shipped levels place one, counted
    #: over every level container in the tree by
    #: `editor/tools/scan_sprite_usage.py`. A number that is absent is placed
    #: nowhere; an *empty* table is one nobody has scanned, which is why
    #: :func:`shiny_mushroom.sprites.placements` says so rather than answering
    #: zero for everything.
    #:
    #: **Not the same question as whether a sprite is used.** Fifty named
    #: sprites are placed by no level and appear in the game all the same,
    #: because something else spawns them -- Yoshi hatches out of an egg, a
    #: Bullet Bill comes out of a shooter. This counts records in level data,
    #: which is a fact; what it is evidence *for* is up to the reader.
    usage: dict[int, int]

    #: Sprite number -> the number it becomes when something reveals it, for the
    #: sprites that draw nothing until then. Not a name: a hidden sprite has no
    #: second appearance of its own, it overwrites its own entry in the game's
    #: sprite ID table and from then on *is* the other sprite -- so the honest
    #: thing to show for it is that sprite.
    reveals: dict[int, int]


@dataclass(frozen=True)
class PaletteRun:
    """One named run of colours inside the palette file, as the global palette
    table cuts it."""

    #: The name in the table's namespace: `SMW_GlobalPalettes_YoshiBerry`. A
    #: symbol where :attr:`labelled`, and the name the label would carry where
    #: the table only comments the run.
    symbol: str

    #: Byte offsets into the blob. `end` is one past the last byte.
    start: int
    end: int

    #: The run as a panel should offer it, spelled at generation time.
    title: str

    #: Whether nothing subdivides it. The leaves tile the file exactly once;
    #: the rest are the parents they sit under, which the loader still reads by
    #: name -- `Sky` is eight back area colours and `Sky_Setting00` is one.
    leaf: bool

    #: Whether `Bank00.asm` labels this run, and so whether a build's symbol
    #: file carries :attr:`symbol`. Every run is labelled today, so the file
    #: writes this only where it is false -- which is the answer to wanting a
    #: run the table does not name: label it there, which moves no bytes.
    labelled: bool = True

    #: What the table says about the run that its extent and its title do not,
    #: or the empty string. Only what is *not* already modelled: where a run
    #: lands in CGRAM is `shiny_mushroom.palette_map`'s answer and is not
    #: repeated here.
    note: str = ""


@dataclass(frozen=True)
class PaletteTable:
    """One run of colour the editor offers, as the cartridge keeps it.

    Three of them, and they are separate runs of the ROM rather than one: the
    global palette table at the front of bank `$00`, and the eight fade steps
    apiece that a Magikoopa and the Big Boo Boss are drawn through, which live
    in bank `$03` beside the sprites that use them. The editor's document is
    all three laid end to end, so a colour has one offset wherever it lives and
    every table's colours are edited the same way.
    """

    #: What it is in :mod:`smw_tools.rom_tables`, which is what says where a
    #: given target put it.
    role: str

    #: The label on its first byte, as a symbol file spells it.
    label: str

    #: The namespace its runs carry, stripped off a run's name for display.
    prefix: str

    #: Where the source writes it -- a file under the game folder, and the
    #: macro inside it. Nothing at run time reads either; they are what the
    #: catalog is checked against.
    file: str
    macro: str

    #: Where it sits in the document, and how big it is.
    at: int
    size: int

    @property
    def end(self) -> int:
        return self.at + self.size


@dataclass(frozen=True)
class PaletteSource:
    """One `incbin` the assembled table makes: bytes taken out of one palette
    file, landing at :attr:`at` in the table.

    The table is nothing but these, in order, so they tile the table exactly --
    which is what lets an edit made against the table be written back to
    whichever file the byte actually came from.
    """

    #: The file, relative to the game folder: `palettes/Sky.tpl`.
    file: str

    #: The byte range taken out of it. `end` is one past the last byte, and
    #: these are offsets into *that file*, header and all.
    start: int
    end: int

    #: Where those bytes land in the table, which is the offset every run in
    #: :class:`PaletteRun` is measured in. Derived: the runs are emitted in
    #: order, so it is what came before.
    at: int

    @property
    def size(self) -> int:
        return self.end - self.start


@dataclass(frozen=True)
class PaletteMetadata:
    """Every run of the global palette table, by symbol, in file order."""

    #: Symbol -> run. Insertion-ordered as the table writes them, which is the
    #: order a panel offers them in.
    runs: dict[str, PaletteRun]

    #: What the tables are assembled out of, in emission order. Every ROM map
    #: sets `!Define_SMW_Global_UseIndividualPaletteFiles = !TRUE`, so this is
    #: several files -- a `.tpl` per set where Lunar Magic exported one, and
    #: `palettes/smw.pal` for the rest.
    sources: tuple[PaletteSource, ...]

    #: The tables the document is, in the order it lays them out.
    tables: tuple[PaletteTable, ...]

    #: The size the table cuts out of the blob, which is the blob's own: a
    #: palette file of any other length moves bytes.
    blob_size: int

    #: The symbol on the global table's first byte -- what the editor resolves
    #: against the build to find where **this target** put it.
    table: str

    def table_at(self, offset: int) -> PaletteTable:
        """Which table byte `offset` of the document falls in."""
        for table in self.tables:
            if table.at <= offset < table.end:
                return table
        raise MetadataError(f"{offset:#x} is past the end of the palette document")

    def leaves(self) -> tuple[PaletteRun, ...]:
        """The runs nothing subdivides, in file order -- the ones that tile it."""
        return tuple(run for run in self.runs.values() if run.leaf)

    def files(self) -> tuple[str, ...]:
        """Every file the table is assembled out of, first use first."""
        return tuple(dict.fromkeys(source.file for source in self.sources))


def _numbered(table: dict[str, str]) -> dict[int, str]:
    """A hex-keyed table as a number-keyed one."""
    return {int(key, 16): name for key, name in table.items()}


def _document(name: str) -> dict:
    return json.loads(resources.read_text(name))


def _size(entry: dict) -> ObjectSize:
    """One object's size entry, as the file writes it.

    ``byte`` and the ``low``/``high`` pair are alternatives, not both: a whole
    byte is one field and its two halves must never be offered apart, or the
    high nibble reads as a second size sixteen times the first.
    """
    runaway = frozenset(entry.get("runaway", ()))
    whole = entry.get("byte")
    if whole is not None:
        return ObjectSize(low=whole, high=whole, whole=whole, runaway=runaway)
    return ObjectSize(
        low=entry.get("low", UNKNOWN),
        high=entry.get("high", UNKNOWN),
        runaway=runaway,
    )


def load_objects() -> ObjectMetadata:
    """Read `object-metadata.json`."""
    document = _document(OBJECT_FILE)
    return ObjectMetadata(
        tileset_groups=_numbered(document["tileset_groups"]),
        extended=_numbered(document["extended"]),
        crashes=frozenset(
            int(number, 16) for number in document.get("extended_crashes", ())
        ),
        standard={
            group: _numbered(table) for group, table in document["standard"].items()
        },
        sizes={
            group: {int(number, 16): _size(entry) for number, entry in table.items()}
            for group, table in document.get("sizes", {}).items()
        },
    )


def load_sprites() -> SpriteMetadata:
    """Read `sprite-metadata.json`."""
    document = _document(SPRITE_FILE)
    return SpriteMetadata(
        normal=_numbered(document["normal"]),
        shooter=_numbered(document["shooter"]),
        generator=_numbered(document["generator"]),
        scroll=_numbered(document["scroll"]),
        loaders=_numbered(document["loaders"]),
        categories=_numbered(document["categories"]),
        # Empty where the scan has not run, which every reader has to cope with
        # -- the same bargain the object sizes make.
        usage={
            int(number, 16): count
            for number, count in document.get("usage", {}).items()
        },
        reveals={
            int(number, 16): int(becomes, 16)
            for number, becomes in document["reveals"].items()
        },
    )


class MetadataError(ValueError):
    """A bundled metadata file this module cannot read, or reads as
    inconsistent."""


def load_palettes() -> PaletteMetadata:
    """Read `palette-metadata.json`, checking what a hand edit can break.

    The other two files are generated, so a malformed one is a bug in a
    generator and would be caught where it is written. This one is typed, and
    the mistakes typing it makes are the ones that do not look like mistakes:
    a run that stops one colour short, a start that repeats the line above, a
    range nudged by a byte. Each would show the wrong name over the wrong
    colours rather than fail, so the shape is checked here and the file refused
    where it does not hold.
    """
    document = _document(PALETTE_FILE)
    try:
        size = int(document["blob_size"], 16)
        runs = {
            symbol: PaletteRun(
                symbol=symbol,
                start=int(entry["start"], 16),
                end=int(entry["end"], 16),
                title=entry["title"],
                leaf=entry["leaf"],
                labelled=entry.get("labelled", True),
                note=entry.get("note", ""),
            )
            for symbol, entry in document["regions"].items()
        }
        tables, at = [], 0
        for entry in document["tables"]:
            held = int(entry["size"], 16)
            tables.append(
                PaletteTable(
                    role=entry["role"],
                    label=entry["label"],
                    prefix=entry["prefix"],
                    file=entry["file"],
                    macro=entry["macro"],
                    at=at,
                    size=held,
                )
            )
            at += held
        sources, at = [], 0
        for entry in document["sources"]:
            start, end = int(entry["start"], 16), int(entry["end"], 16)
            sources.append(
                PaletteSource(file=entry["file"], start=start, end=end, at=at)
            )
            at += end - start
    except (KeyError, TypeError, ValueError) as error:
        raise MetadataError(f"{PALETTE_FILE} is not a palette catalog: {error}") from (
            error
        )
    found = PaletteMetadata(
        runs=runs,
        sources=tuple(sources),
        tables=tuple(tables),
        blob_size=size,
        table=tables[0].label if tables else "",
    )
    _check_palettes(found)
    return found


def _check_palettes(found: PaletteMetadata) -> None:
    """That the catalog says one thing about every byte of the palette table.

    Three shapes, and the editor is entitled to all of them. The **leaves
    partition the table**, so every colour is offered once and "which run is
    this byte in" always has an answer; a **parent stops where its last child
    does**, so reading a run by name and reading its children give the same
    bytes; and the **sources tile it too**, so every byte of an edit has one
    file to be written back to and no byte is written twice.
    """
    covered = sum(table.size for table in found.tables)
    if covered != found.blob_size:
        raise MetadataError(
            f"the tables cover {covered:#x} of the document's "
            f"{found.blob_size:#x} bytes"
        )
    covered = sum(source.size for source in found.sources)
    if covered != found.blob_size:
        raise MetadataError(
            f"the sources cover {covered:#x} of the table's {found.blob_size:#x} bytes"
        )
    for source in found.sources:
        if source.end <= source.start:
            raise MetadataError(
                f"{source.file}:{source.start:X}-{source.end:X} is not a range"
            )
    at = 0
    for run in found.leaves():
        if run.start != at:
            raise MetadataError(
                f"{run.symbol} starts at {run.start:#x}, not {at:#x} -- the runs "
                f"leave a gap or overlap"
            )
        if run.end <= run.start or (run.end - run.start) % 2:
            raise MetadataError(
                f"{run.symbol} is {run.end - run.start:#x} bytes, which is not a "
                f"whole number of colours"
            )
        at = run.end
    if at != found.blob_size:
        raise MetadataError(
            f"the runs cover {at:#x} of the palette file's {found.blob_size:#x} bytes"
        )
    for run in found.runs.values():
        if run.leaf:
            continue
        under = [
            other
            for other in found.runs.values()
            if other is not run and run.start <= other.start < run.end
        ]
        if not under or max(other.end for other in under) != run.end:
            raise MetadataError(
                f"{run.symbol} is not a leaf but its children do not fill it"
            )


#: Read at import and kept. Bundled data cannot change while the app runs, and
#: naming a thing happens once per selection, per hover and per outline drawn.
OBJECTS = load_objects()
SPRITES = load_sprites()
PALETTES = load_palettes()
