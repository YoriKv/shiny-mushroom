"""What can be put into a level, and what putting one there produces.

:mod:`shiny_mushroom.objects` and :mod:`shiny_mushroom.sprites` answer "what is
this record?"; this module answers the question from the other end -- "what
records are there to make?" -- and hands back the record itself. It is the model
behind the create panel, and it is Qt-free for the reason the rest of the model
is: what may be placed and what a placement *is* are facts about the format, and
they should be testable by reading a list back.

**The vocabulary is the disassembly's.** A name comes from
:mod:`shiny_mushroom.metadata`, which is generated from the game's own dispatch
tables, and nothing here invents one.

**An entry's category is what the filter cuts along, and the two streams answer
it differently.** For an **object** it is the kind the loader branches on --
:class:`~shiny_mushroom.objects.ObjectKind`, `standard`/`extended`/`command` --
because that division is true by construction and there is no other. For a
**sprite** it is :class:`~shiny_mushroom.sprites.SpriteCategory`: `enemy`,
`powerup`, `platform`, and ten more. That one is a judgement, and the only one
in the metadata -- no table in the cartridge says a Koopa is an enemy. It is
kept in `smw_tools.sprite_categories`, generated into the bundled file with the
names, and checked against the dispatch table both ways so a sprite cannot fall
quietly out of every filter. `sprite`/`spawner`/`command` would be true by
construction and would sort two hundred sprites into one pile of a hundred and
ninety.

Three decisions are worth stating.

**An object list belongs to a tileset.** The same number is a different object
in a different tileset -- there are five tables and fifteen tilesets -- so
:func:`object_entries` takes one and there is no tileset-free list to be had.

**An unnamed number is left out rather than listed as "Unknown".** The same rule
:func:`shiny_mushroom.objects._standard_choices` already follows: a picker is
for choosing, and sixty rows of the same word is not a choice. Nothing is put
out of reach by it -- the properties panel will still hold any number a record
carries, and the panel's own pickers keep an unlisted value selectable.

**A new object's settings byte is not simply zero.** For the objects whose
extent is measured as a *runaway* -- the loop tests after decrementing, so a
stored zero means 256 passes rather than one -- zero is the one value nobody
ever means, and placing one would send the object across the whole level. See
:func:`default_settings`.
"""

from __future__ import annotations

from collections.abc import Collection, Mapping, Sequence
from dataclasses import dataclass, replace
from enum import Enum

from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.level import Geometry
from shiny_mushroom.metadata import OBJECTS
from shiny_mushroom.objects import (
    EXTENDED_OBJECT,
    SCREEN_EXIT,
    SCREEN_JUMP,
    LevelObject,
    ObjectKind,
    encode_objects,
    parse_objects,
    screen_exit_record,
)
from shiny_mushroom.sprite_art import CUSTOM_ART_BASE
from shiny_mushroom.sprites import (
    FIRST_SHOOTER,
    GOAL_TAPE,
    UNKNOWN,
    Sprite,
    SpriteKind,
    category_of,
    name_of,
)

#: The nibble a runaway extent must start at, and the smallest it can hold: a
#: stored zero is 256 there. It is the same floor
#: :func:`shiny_mushroom.objects._extent_field` puts on the field, said once
#: more at the point a record is created rather than edited.
SMALLEST_RUNAWAY = 1


class Stream(Enum):
    """Which of a level's two record streams an entry belongs to.

    The one thing a placement cannot change afterwards -- the two streams are
    written separately, so a record that changed sides would be dropped from one
    and never reach the other (see
    :meth:`shiny_mushroom.edit.Level.replaced`) -- which is why it is the first
    thing an entry says.
    """

    OBJECT = "object"
    SPRITE = "sprite"


#: What identifies a catalogue entry: ``(stream, number, settings)``. Named
#: because it is the join between four things that otherwise share nothing -- an
#: entry, a record in a level (:func:`key_of`), the pictures the window renders,
#: and the "already in this level" and graphics filters the create panel runs --
#: and a bare three-tuple in each of their signatures says none of that.
#:
#: An alias rather than a class: it is a dictionary key in every one of those
#: places, and what makes it usable as one is being a plain tuple of plain
#: values. See :attr:`Entry.key` for why the third element is usually zero.
type CatalogKey = tuple[Stream, int, int]


@dataclass(frozen=True)
class Entry:
    """One thing the catalogue offers, and what placing it produces.

    :attr:`settings` carries two different jobs, exactly as the format does. For
    an **extended object** the settings byte *is* the object's number, so it is
    this entry's identity; for a **standard object** it is the byte a new record
    starts with, which is a default and not part of what the entry is. That is
    why :attr:`key` masks it in one case and not the other, and it is why the
    byte is here at all rather than being invented at the point of placement:
    what a fresh record should hold is a fact about the object, and it is
    measured -- see :func:`default_settings`.
    """

    stream: Stream
    number: int
    settings: int
    name: str
    #: What the panel's filter cuts along: ``standard``/``extended``/``command``
    #: for an object, and a :class:`~shiny_mushroom.sprites.SpriteCategory` for
    #: a sprite. A plain string because the two enums do not share a base and
    #: nothing here needs them to -- it is a word to group and search by.
    category: str

    #: Whether placing this entry sets the custom bit: a row for the
    #: project's own sprite of this number rather than the game's. The two
    #: share a byte and nothing else -- different code, different picture,
    #: different name -- so they are two entries with two keys.
    custom: bool = False

    #: The extra bytes a fresh custom record carries: as many zeros as the
    #: built cartridge's count table declares for the number, so the stream
    #: an edit re-encodes parses back record for record. Empty for every
    #: vanilla entry, whose records carry none.
    extra_bytes: bytes = b""

    #: A record to copy the properties of -- what the eyedropper picked up,
    #: or that record as the keys since shaped it. A placement then carries
    #: its settings byte, its extra bits, a screen exit's destination: the
    #: thing under the pointer *as it is*, not the catalogue's fresh one of
    #: its kind. Never part of :attr:`key`: the entry is still the row it
    #: was, only what placing it produces has moved.
    template: LevelObject | Sprite | None = None

    @property
    def key(self) -> CatalogKey:
        """What identifies this entry, and what a record in a level is matched
        against.

        The settings byte is part of it only where it is part of the identity --
        an extended object's number lives there. A standard object's is a
        default, so two records of the same object at different sizes are the
        same entry, which is what "the level already uses this" has to mean.
        """
        if self.stream is Stream.OBJECT and self.number == EXTENDED_OBJECT:
            return (self.stream, EXTENDED_OBJECT, self.settings)
        if self.stream is Stream.SPRITE and self.custom:
            # The custom space's copy of the number, as the captures key it
            # (:data:`~shiny_mushroom.sprite_art.CUSTOM_ART_BASE`): the
            # project's $1A and the game's $1A are different things to
            # place, and :func:`key_of` says the same of their records.
            return (self.stream, self.number | CUSTOM_ART_BASE, 0)
        return (self.stream, self.number, 0)

    @property
    def reshaped(self) -> bool:
        """Whether the template places something the row's own fresh record
        would not draw the same -- an object whose settings byte has moved,
        so its size or its variant is not the catalogue's. A sprite's
        picture is its number's whatever its bits, so it is never this."""
        template = self.template
        return (
            isinstance(template, LevelObject)
            and template.settings != self.settings
            and template.kind is not ObjectKind.COMMAND
        )

    @property
    def id_text(self) -> str:
        """The entry's number, written the way the rest of the app writes one.

        An extended object is spelled ``ext $12`` rather than ``$00``, because
        ``$00`` is what every one of them would read as: the number is zero and
        the settings byte is the identity. A project sprite is spelled
        ``custom $1A`` for the same reason at the other end: the byte is the
        vanilla sprite's too, and a list holding both rows as ``$1A`` would
        leave only the name to say which is the game's.
        """
        if self.stream is Stream.OBJECT and self.number == EXTENDED_OBJECT:
            return f"ext {hexnum(self.settings)}"
        if self.stream is Stream.SPRITE and self.custom:
            return f"custom {hexnum(self.number)}"
        return hexnum(self.number)

    @property
    def label(self) -> str:
        """One line for a row in a list: the id, then what it is called."""
        return f"{self.id_text}  {self.name}"

    def matches(self, query: str) -> bool:
        """Whether ``query`` finds this entry.

        Over the name, the id and the category at once, because those are the
        three things somebody knows about what they are looking for and there is
        no reason to make them say which they are typing. Case-insensitive, and
        the ``$`` every id in this application is written with is ignored rather
        than required -- typing ``c7`` and typing ``$c7`` are the same search.
        """
        query = query.strip().lower().removeprefix("$")
        if not query:
            return True
        return (
            query in self.name.lower()
            or query in self.id_text.lower().replace("$", "")
            or query in self.category
        )

    def at(self, column: int, row: int, shape: Geometry) -> LevelObject | Sprite:
        """The record this entry becomes, placed at block ``(column, row)``.

        Everything a stream computes rather than stores is left at zero -- the
        index, the offset, and a non-command's own bytes. That is not
        carelessness: :meth:`shiny_mushroom.edit.Level.added` encodes the list it
        builds and re-reads it, so what a record ends up holding for those is the
        parse of the bytes that would be written, and anything set here would
        only be a guess waiting to be overwritten.

        **A screen exit is the exception, and it has to be.** A command's bytes
        are written out verbatim by
        :func:`~shiny_mushroom.objects.encode_objects`, because its destination
        and its entrance flag are fields nothing above understands -- so a new
        one has to arrive with four bytes that mean something. It gets the screen
        the click landed on and destination ``$000``, which is a level the
        cartridge has: an exit that leads somewhere definite is a thing to edit
        in the properties panel, and one built out of nothing is a thing to
        debug.
        """
        screen = shape.screen_of(column, row)
        template = self.template
        if template is not None:
            return self._like(template, column, row, screen, shape)
        if self.stream is Stream.SPRITE:
            # A custom entry arrives as its record will be read back: the
            # bit set, the name on it, and the declared count's worth of
            # zero extra bytes -- the loader's stride, without which the
            # re-encoded stream would misparse every record behind it.
            return Sprite(
                number=self.number,
                column=column,
                row=row,
                screen=screen,
                extra_bits=0b10 if self.custom else 0,
                custom_capable=self.custom,
                extra_bytes=self.extra_bytes,
                custom_name=self.name if self.custom else "",
            )
        if self.number == EXTENDED_OBJECT and self.settings == SCREEN_EXIT:
            return screen_exit_record(screen, shape)
        return LevelObject(
            number=self.number,
            settings=self.settings,
            column=column,
            row=row,
            screen=screen,
            index=0,
            offset=0,
            data=b"",
        )

    @staticmethod
    def _like(
        template: LevelObject | Sprite,
        column: int,
        row: int,
        screen: int,
        shape: Geometry,
    ) -> LevelObject | Sprite:
        """A copy of ``template`` placed at ``(column, row)``: its properties
        kept, everything a stream computes reset as :meth:`at` resets it.

        A screen exit keeps its destination and its entrance flag and takes
        the screen it lands on, which is the whole of what one is.
        """
        if isinstance(template, LevelObject) and template.kind is ObjectKind.COMMAND:
            fresh = screen_exit_record(screen, shape)
            if template.settings != SCREEN_EXIT or len(template.data) != 4:
                return fresh
            data = bytes(
                (fresh.data[0], template.data[1], SCREEN_EXIT, template.data[3])
            )
            return replace(fresh, data=data)
        return replace(
            template,
            column=column,
            row=row,
            screen=screen,
            index=0,
            offset=0,
            data=b"",
            uid=0,
        )

    def preview(
        self, column: int, row: int, shape: Geometry
    ) -> tuple[int, int, int, int]:
        """The blocks a placement here would claim: ``(left, top, columns,
        rows)``.

        **What the record claims, not what the object will draw.** What an object
        puts on screen is the game's own work and is not known until the loader
        has been asked -- which is the same bargain
        :class:`~shiny_mushroom.ui.overlays.Stretching` makes for a resize. So
        this is the record's own extent: the settings byte's rectangle where the
        format promises one, and one block where it does not. A preview that drew
        a shape nobody has measured would be a picture of a guess.

        A **screen exit** claims the whole screen it is dropped on, because that
        is what it acts on: it has no position, and previewing it as a block
        would put a mark on a place that means nothing.
        """
        if self.stream is Stream.OBJECT and self.number == EXTENDED_OBJECT:
            if self.settings == SCREEN_EXIT:
                columns, rows = shape.screen
                return (column - column % columns, row - row % rows, columns, rows)
        record = self.at(column, row, shape)
        if isinstance(record, Sprite):
            return (column, row, 1, 1)
        return (column, row, record.width, record.height)


def default_settings(tileset: int, number: int) -> int:
    """The settings byte a newly placed standard object starts with.

    Zero for almost everything, which is one block by one: a nibble holds
    "blocks minus one", so a fresh object is as small as it can be and is grown
    from there -- by the resize keys, by a dragged edge, or in the properties
    panel.

    **Except where zero is the value nobody means.** For the objects whose
    extent was measured as a runaway, the loader's loop tests after decrementing,
    so a stored zero is 256 passes rather than one and the object runs across the
    whole level. The properties panel refuses to *set* that value
    (:func:`shiny_mushroom.objects._extent_field` puts the field's floor at two
    blocks); this is the same rule at the other end, so a placement cannot create
    what an edit cannot produce.

    An unmeasured object gets zero, which is the honest answer: nothing is known
    about what its byte means, and the smallest number is the least eventful
    thing to hand it.
    """
    size = OBJECTS.size_of(tileset, number)
    if size.whole is not None:
        return SMALLEST_RUNAWAY if "byte" in size.runaway else 0
    low = SMALLEST_RUNAWAY if "low" in size.runaway else 0
    high = SMALLEST_RUNAWAY if "high" in size.runaway else 0
    return (high << 4) | low


def drawn_as_placed(record: LevelObject, tileset: int) -> bool:
    """Whether ``record`` holds the settings byte its entry would be placed with.

    The question a picture of the catalogue has to pass. A preview says "this is
    what putting one down gets you", so it may only be drawn from an object that
    was put down that way -- and a level's own records are not: the same entry
    keys a two-block row of coins and a single coin
    (:attr:`Entry.key` masks the byte for a standard object, because two records
    of one object at different sizes are one entry), so taking whichever the
    level happened to hold would show a size the placement does not make. The
    catalogue probe, which places each entry exactly as a click would, answers
    for the rest.

    Always true for an **extended object**, where the settings byte is the
    object's number rather than a size, so an entry and its records cannot
    disagree about it.
    """
    if record.number == EXTENDED_OBJECT:
        return True
    return record.settings == default_settings(tileset, record.number)


def object_entries(tileset: int) -> list[Entry]:
    """Everything that can be added to the object stream of a level in
    ``tileset``.

    The tileset's own standard objects first, in number order, then the extended
    objects -- which are the same list in every tileset, because the extended
    dispatcher is not indexed by one.

    **The screen jump is not offered.** It is the one record in the format that
    exists to place other records: the encoder emits jumps as it needs them and
    :meth:`shiny_mushroom.edit.Level._rebuild` drops the ones it invented, so a
    hand-placed one is not a thing in the level but a thing in the *stream*, and
    putting one in by hand means moving every record after it to a screen nobody
    chose. The screen exit is offered, because it is the opposite: a decision
    about where a pipe leads, which nothing else can express.
    """
    group = OBJECTS.tileset_groups.get(tileset & 0x0F)
    standard = OBJECTS.standard.get(group or "", {})
    entries = [
        Entry(
            stream=Stream.OBJECT,
            number=number,
            settings=default_settings(tileset, number),
            name=name,
            category=ObjectKind.STANDARD.value,
        )
        for number, name in sorted(standard.items())
    ]
    entries += [
        Entry(
            stream=Stream.OBJECT,
            number=EXTENDED_OBJECT,
            settings=settings,
            name=name,
            category=ObjectKind.of(EXTENDED_OBJECT, settings).value,
        )
        for settings, name in sorted(OBJECTS.extended.items())
        if settings != SCREEN_JUMP
    ]
    return entries


#: The category every project sprite files under: the one judgement the
#: metadata cannot make, because the sprite is not in it. One word for all
#: of them keeps the project's rows one filter click away.
CUSTOM_CATEGORY = "custom"


def sprite_entries(
    custom_names: Mapping[int, str] = {},
    extra_counts: Mapping[int, int] = {},
) -> list[Entry]:
    """Everything that can be added to the sprite stream.

    The game's list is the same for every level, unlike the objects: a sprite
    number means one thing across the cartridge, and what a level's header
    decides is whether the graphics for it are loaded -- which is a question
    about how it will *look*, not about what the record is. The editor cannot
    answer that one yet, and offering a list that quietly left sprites out
    would be claiming it could.

    Behind it come the **project's own sprites** -- ``custom_names`` as
    :func:`shiny_mushroom.project_sprites.custom_names` reads it off the
    sprite folders -- each placed with the custom bit set and, from
    ``extra_counts``, the built cartridge's stride of zero extra bytes. The
    goal tape's number is left out however the project spells it: both of
    that record's extra bits are Lunar Magic's secret-exit choice, so the
    bit cannot mark it and a row offering to would place the vanilla tape.
    """
    entries = [
        Entry(
            stream=Stream.SPRITE,
            number=number,
            settings=0,
            name=name_of(number),
            category=category_of(number).value,
        )
        for number in range(0x100)
        if name_of(number) != UNKNOWN
    ]
    entries += [
        Entry(
            stream=Stream.SPRITE,
            number=number,
            settings=0,
            name=name,
            category=CUSTOM_CATEGORY,
            custom=True,
            extra_bytes=bytes(extra_counts.get(number, 0)),
        )
        for number, name in sorted(custom_names.items())
        # A record byte from the shooter range up is a command to the
        # loader -- a generator, a shooter, a scroll -- before any custom
        # bit is read, so a custom normal sprite numbered there could
        # never be placed as itself.
        if number != GOAL_TAPE and number < FIRST_SHOOTER
    ]
    return entries


class Art(Enum):
    """Whether an entry's graphics will be loaded where it is being placed.

    Four answers, and the middle two must not be collapsed into one: "the cart
    never does this" and "the cart never does this *anywhere*" are different
    statements, and only the first is a reason to think something is wrong.
    """

    #: Nothing to say. Every object, and every sprite that draws nothing of its
    #: own -- a spawner or a scroll command. See :func:`art_verdict`.
    SETTLED = "settled"
    #: The cartridge itself places this sprite under this sprite tileset.
    SHIPPED = "shipped"
    #: The cartridge places it, but never under this sprite tileset. The one
    #: answer that is a warning.
    ELSEWHERE = "elsewhere"
    #: The cartridge never places it at all, so nothing is known either way.
    UNKNOWN = "unknown"


#: What each verdict is called in the panel, and the sentence explaining it.
#: ``SETTLED`` has neither: a badge on every row is furniture, not information.
ART_LABELS: dict[Art, tuple[str, str]] = {
    Art.ELSEWHERE: (
        "gfx?",
        "The cartridge never places this sprite under this sprite tileset, so "
        "its artwork is probably not in SP1-SP4 here: it will be placed, and "
        "may draw as the wrong thing. Evidence from the shipped game, not a "
        "rule.",
    ),
    Art.UNKNOWN: (
        "unused",
        "The cartridge never places this sprite at all, so there is no "
        "evidence either way about its graphics here.",
    ),
}


def art_verdict(entry: Entry, sprite_tileset: int, shipped: Collection[int]) -> Art:
    """Whether ``entry``'s artwork is likely to be loaded under
    ``sprite_tileset``.

    ``shipped`` is what :meth:`~shiny_mushroom.index.LevelIndex.shipped_under`
    answers for this sprite: the sprite tilesets the cartridge itself places it
    under.

    **Objects are always settled, and that is a fact about SMW rather than a
    gap here.** One header nibble picks the object dispatch table, the
    tileset-specific Map16 definitions *and* the FG/BG graphics row -- and the
    first two group the fifteen tilesets identically, five tables apiece. So an
    object offered for this level's tileset draws blocks defined for this
    level's tileset out of graphics loaded for it. There is no independent axis
    to get wrong, and a badge saying so on every row would be furniture.

    A **sprite** is the opposite case, and the only real one: the sprite tileset
    is its own header field (byte 2, bits 3-0), chosen independently of the
    level tileset, and it selects the four files that land in SP1-SP4. A sprite
    whose artwork is not among them is placed perfectly well and draws as
    whatever those tiles happen to hold.

    **Evidence, not a rule.** The cartridge carries no table of which graphics a
    sprite needs -- what it draws is decided by its own drawing code. What the
    shipped game *does* is the best answer available without running every
    sprite under every tileset, so a sprite the cart never places anywhere is
    :attr:`Art.UNKNOWN` and not a warning. Guessing there would put a red mark
    on 80 of the 246 sprites the disassembly names.

    A sprite that draws nothing of its own -- a shooter, a generator, a scroll
    command -- is settled too. It has no artwork for a tileset to be missing.
    """
    return art_verdict_under(entry, (sprite_tileset,), shipped)


def art_verdict_under(
    entry: Entry, tilesets: Collection[int], shipped: Collection[int]
) -> Art:
    """:func:`art_verdict` for a level whose SP1-SP4 hold what ``tilesets``
    load -- every stock sprite tileset whose four files are the level's
    four, :func:`tilesets_loading`'s answer.

    The one case the plain verdict cannot say: a level with a graphics row
    of its own (:mod:`shiny_mushroom.level_graphics`) loads files no header
    field names, and the evidence is keyed by tileset. Where its four sprite
    files are exactly some stock tileset's, that tileset's evidence is the
    level's; where they are no stock tileset's -- an added file, or a mix
    the lists never make -- there is no evidence either way, which is
    :attr:`Art.UNKNOWN` and not a warning.
    """
    if entry.stream is not Stream.SPRITE:
        return Art.SETTLED
    if entry.custom:
        # A project sprite's artwork is its own drawing code's, captured by
        # the probe like any other -- and the shipped evidence is about the
        # vanilla number that shares its byte, so it says nothing here.
        return Art.SETTLED
    if SpriteKind.of(entry.number) is not SpriteKind.SPRITE:
        return Art.SETTLED
    if not shipped or not tilesets:
        return Art.UNKNOWN
    return Art.SHIPPED if any(one in shipped for one in tilesets) else Art.ELSEWHERE


def tilesets_loading(
    sprite_files: Sequence[int], sprite_rows: Sequence[bytes]
) -> frozenset[int]:
    """Which rows of ``SpriteGFXList`` -- ``sprite_rows``, as
    :func:`~shiny_mushroom.rom_patches.gfx_list_rows` reads them -- load exactly
    ``sprite_files`` in SP1-SP4: the stock tilesets whose evidence a level
    loading those four files may borrow. Empty when none does."""
    wanted = bytes(sprite_files)
    return frozenset(
        tileset for tileset, row in enumerate(sprite_rows) if bytes(row) == wanted
    )


#: How much room each object gets to itself in a probe level, in blocks.
#: Generous next to what a smallest-settings object draws -- almost all of them
#: are a block or two -- and small enough that a level has far more cells than
#: the catalogue has objects. An object that draws past its cell has its extra
#: blocks counted against whichever object wrote them last, so the footprint
#: comes back short or empty and the preview is simply absent: a spill shows up
#: as no picture rather than as a wrong one.
PROBE_CELL = 8


def probe_stream(
    entries: Sequence[Entry], shape: Geometry
) -> tuple[bytes, dict[int, Entry]]:
    """One object stream drawing the whole catalogue, and what each record is.

    The trick that makes object previews affordable. Asking the emulator what
    one object draws costs a level load; asking it what sixty-three draw costs
    the same load if they are all in the same level. So each entry is placed on
    a cell of its own on a grid, the stream is loaded once with the object trace
    on, and the footprints come back one per record.

    Returns the stream and a map from each record's **byte offset** to the entry
    it came from -- the entry itself, since a reshaped one is keyed apart from
    its row (see :attr:`Entry.reshaped`); the offset because that is what a
    parse of the stream pairs
    the loader's footprints by, exactly as
    :meth:`~shiny_mushroom.ui.main_window.MainWindow._read_level` pairs a real
    level's. Records the encoder invented (the screen jumps that carry the
    cursor between cells) are absent from the map, which is what tells them
    apart from the ones somebody asked for.

    Entries past the last cell the level has room for are **left out**. A level
    of thirty-two screens has hundreds of cells and the catalogue has dozens, so
    this only bites on a level shaped too small to hold the probe -- and a
    missing preview is the honest result of not having asked.
    """
    across = max(1, shape.columns // PROBE_CELL)
    down = max(1, shape.rows // PROBE_CELL)
    # Commands are left out rather than given a cell. A screen exit draws
    # nothing, so probing it would spend a cell to learn that -- and it acts on
    # the screen it is written on, which is a thing to do to a scratch level
    # nobody asked for.
    wanted = [
        entry
        for entry in entries
        if entry.stream is Stream.OBJECT
        and ObjectKind.of(entry.number, entry.settings) is not ObjectKind.COMMAND
    ]
    placed: list[LevelObject] = []
    for cell, entry in enumerate(wanted[: across * down]):
        record = entry.at(
            (cell % across) * PROBE_CELL, (cell // across) * PROBE_CELL, shape
        )
        assert isinstance(record, LevelObject)
        # Stamped so the encoder can say which emitted record came from which
        # entry -- it reports a uid per record and zero for a jump it invented.
        placed.append(replace(record, uid=len(placed) + 1))

    stream, uids = encode_objects(placed, shape)
    by_offset: dict[int, Entry] = {}
    for parsed, uid in zip(parse_objects(stream, shape), uids, strict=True):
        if uid:
            by_offset[parsed.offset] = wanted[uid - 1]
    return stream, by_offset


def key_of(record: LevelObject | Sprite) -> CatalogKey:
    """Which entry a record in a level came from.

    The inverse of :attr:`Entry.key`, and the whole of what "this level already
    uses it" is asked with. Answered for every record, including ones no entry
    offers -- a screen jump, an object number the tables do not name -- because
    the answer is then simply a key nothing matches, which is what a filter
    should do with it.
    """
    if isinstance(record, Sprite):
        # The art key, not the byte: a custom record came from the custom
        # entry, and matching it to the vanilla row would say a level that
        # places the project's $1A already uses the game's.
        return (Stream.SPRITE, record.art_key, 0)
    if record.number == EXTENDED_OBJECT:
        return (Stream.OBJECT, EXTENDED_OBJECT, record.settings)
    return (Stream.OBJECT, record.number, 0)
