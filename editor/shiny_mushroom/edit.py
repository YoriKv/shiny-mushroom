"""What a level *is* while it is being edited, and what an edit does to it.

:mod:`shiny_mushroom.objects` and :mod:`shiny_mushroom.sprites` read a stream
into records and write records back out as a stream. This is the layer between
them: a :class:`Level` holding both streams' records at once -- and the five
header bytes that say what kind of level they are in -- the operations that
change them, and the :class:`History` that lets those be taken back.

**Everything a level is, is in here.** The header is part of the document rather
than something held beside it, which is what makes a header edit an edit: one
undo step, restored by an undo along with the shape it implies, and written by
the same save. Held beside it, an undo would take back the records and leave the
header, and the two would disagree about what the level is.

No Qt, no emulator, no window. An edit is a function from a level to a level,
which is what lets the whole of this be tested by handing it records and reading
records back -- and what keeps the question of *what a gesture means* out of it
entirely. Which records a drag has hold of is the window's business; moving them
is this module's.

Three decisions are worth stating, because everything here follows from them.

**Every edit is a rewrite.** An operation does not patch a record in place: it
builds the list it wants, encodes that list to a stream, and re-reads the stream
back. So a level always holds the parse of the bytes it would write -- offsets,
record indices, the screen cursor and each record's own bytes are what the game
will actually see, not what the editor believes it asked for. It is not the
cheapest way to move one object a block sideways; it is the way that cannot
drift, and a level's streams are a few kilobytes.

**Identity is a uid, not an offset.** A rewrite moves offsets, and an undo
restores bytes that were never on disk, so neither survives as a name for "the
thing I have hold of". Every record is stamped with a number when the level is
read, keeps it across every edit, and gets it back on undo. One pool for both
streams, so a selection is a set of numbers rather than a set of pairs.

**Nothing is clamped silently into something else.** A move that would take a
record out of the level moves the whole group as far as it can and no further,
which is what makes dragging a selection against the edge feel like an edge
rather than like a fold; a resize is bounded by what the format's nibble can
say. What cannot be done at all -- moving a screen exit, resizing an object
whose settings byte is not a size -- is refused rather than approximated, and
the operation says so by leaving the level alone.
"""

from __future__ import annotations

from collections.abc import Collection, Iterable, Mapping, Sequence
from dataclasses import dataclass, field, replace

from shiny_mushroom.header import field_value
from shiny_mushroom.level import Geometry
from shiny_mushroom.objects import LevelObject, encode_objects, parse_objects
from shiny_mushroom.sprites import (
    Sprite,
    UnencodableSprite,
    encode_sprites,
    parse_sprites,
)
from smw_tools.level_graphics import ROW_BYTES as GRAPHICS_ROW_BYTES
from smw_tools.level_graphics import decode as decode_graphics
from smw_tools.level_graphics import effective as effective_graphics

#: A record of either stream. The two have no common base class and do not want
#: one -- an object and a sprite share a position and nothing else -- so this is
#: the name for "one of the things a selection can hold".
Record = LevelObject | Sprite

#: How deep the undo stack goes. Each entry is a level's two record lists, which
#: is tens of kilobytes for the largest level in the cartridge, so this is a
#: bound on a session's memory rather than on anyone's patience.
HISTORY_DEPTH = 200


def _checked_graphics(graphics: bytes) -> bytes:
    """``graphics`` as :attr:`Level.graphics` holds it: empty, or one row."""
    graphics = bytes(graphics)
    if graphics and len(graphics) != GRAPHICS_ROW_BYTES:
        raise ValueError(
            f"a level's graphics row is {GRAPHICS_ROW_BYTES} bytes or none, "
            f"not {len(graphics)}"
        )
    return graphics


@dataclass(frozen=True)
class Level:
    """A level's header and its two record streams, and the operations that
    change them.

    Immutable, and every operation returns a new one -- which is what makes
    :class:`History` a list of these rather than a log of reversible actions.
    An operation with nothing to do returns ``self`` unchanged, and that
    identity is load-bearing: it is how a caller tells a real edit from a
    gesture that hit a wall, and so how a no-op stays out of the undo stack.

    **A refusal is the third answer, and it is ``None``.** An edit the streams
    cannot hold -- see :meth:`_rebuild` -- did have something to do and could
    not do it, which is not the same as a drag against the edge and must not
    look the same to the caller: a gesture answered with silence is one the
    person made, watched do nothing, and has no reason to make again. Every
    operation that rewrites the streams answers ``None`` there, and the level
    is left exactly as it was either way.
    """

    #: The level's shape, which decides which axis a screen counts along. Held
    #: because every encode and every move needs it and none of them should have
    #: to be handed it separately.
    #:
    #: A property of :attr:`header` and not an independent one, but not derivable
    #: from it here: whether a level runs *down* is a byte of the cartridge's
    #: ``VerticalTable`` indexed by the mode in header byte 1, and this module
    #: has no cartridge. So it is carried, and :meth:`with_header` is the one
    #: operation that changes the two together -- which is also why it takes the
    #: shape as an argument rather than working it out.
    shape: Geometry

    objects: tuple[LevelObject, ...] = ()
    sprites: tuple[Sprite, ...] = ()

    #: The level's own five header bytes: what kind of level this is, before
    #: anything is in it. **Part of the document**, so a header edit is an edit
    #: like any other -- one undo step, saved by the same save, and the shape it
    #: implies restored along with it. See :meth:`with_header`.
    #:
    #: Not parsed here beyond the two fields the *records* depend on
    #: (:attr:`fg_bg_tileset`, :attr:`sprite_tileset`). What each byte means is
    #: :mod:`shiny_mushroom.header`'s field table, which is what the dialog that
    #: edits one is built from; restating any of it here would be a second
    #: source of truth for a format neither of them owns.
    #:
    #: Empty for a level built by hand to ask a question about records, which is
    #: every :class:`Level` in a test that is not about the header.
    header: bytes = b""

    #: The sprite stream's first byte: the sprite memory setting and the
    #: buoyancy flag. Not a record, not read by anything here, and carried so
    #: the stream can be rewritten without losing it.
    sprite_header: int = 0

    #: The level's Layer 2 *background*: the repeating two-screen pattern as
    #: its tilemap's low bytes, in the buffer's own order -- two 16x27 screens
    #: side by side. Low bytes alone because that is all the stored stream can
    #: say: which Map16 page the whole pattern reads from is decided by where
    #: the stream sits in ROM, not by anything in it.
    #:
    #: Part of the document for the same reason the header is: held beside it,
    #: an undo would take back the records and leave the background. What makes
    #: it unusual is that the pattern is **shared** -- the cartridge points many
    #: levels at one stream -- so editing it here edits what every one of those
    #: levels shows, and saving says so.
    #:
    #: Empty when the level's Layer 2 is an object stream -- then
    #: :attr:`layer2_objects` is what it holds -- and for a level built by hand
    #: to ask a question about records.
    layer2: bytes = b""

    #: The level's Layer 2 as **records**, for the twenty-six level numbers
    #: whose Layer 2 pointer names an object stream rather than a background.
    #: The same kind of stream Layer 1 is, drawn by a second pass of the same
    #: loader loop into the other half of the Map16 buffer -- which is why
    #: these are :class:`~shiny_mushroom.objects.LevelObject` records and every
    #: operation here works them exactly as it works Layer 1's.
    #:
    #: Part of the document for the reason the header and the background are:
    #: one undo stack, one save, and no way for the two halves of a level to
    #: disagree about what it is. The ids come out of the same pool, so a
    #: selection is still a set of numbers and :meth:`record` still answers
    #: without being told which stream to look in.
    #:
    #: Like the background, **the stream is shared**: eight level numbers read
    #: the one Layer 2 that level $0C4's container holds, so editing it here
    #: edits what every one of them shows.
    layer2_objects: tuple[LevelObject, ...] = ()

    #: The five bytes in front of :attr:`layer2_objects` in the cartridge: the
    #: Layer 2 region's own copy of a level header. The loader steps over them
    #: without reading one -- a Layer 2 level's shape, tileset and everything
    #: else come from Layer 1's header -- so nothing here reads them either.
    #: Carried so the region can be written back byte for byte, and non-empty
    #: is what says this level *has* a Layer 2 object stream at all.
    layer2_header: bytes = b""

    #: The level's four secondary-header bytes -- the per-level entries of the
    #: bank ``$05`` tables that place the player and the camera and pick the
    #: Layer 3 background, in table order (:mod:`shiny_mushroom.secondary_header`).
    #: Part of the document for the reason the header is: one undo stack, one
    #: save. What makes these unusual is that they live in the *cartridge's*
    #: tables rather than in the level's container, so a save writes them
    #: through the ``levels.secondary_header_*`` asm regions instead.
    #:
    #: Empty for a level built by hand to ask a question about records, which
    #: no operation here minds -- nothing reads a bit of it.
    secondary: bytes = b""

    #: The level's own graphics: the eight-byte row the ``level-graphics``
    #: feature keeps per level number -- which file each of FG1, FG2, BG1,
    #: FG3, SP1-SP4 loads, ``$FF`` where the slot keeps the file the header's
    #: tileset would load (:mod:`smw_tools.level_graphics`). Part of the
    #: document for the reason the secondary header is: one undo stack, one
    #: save. Like it, held in the *cartridge's* table rather than in the
    #: level's container, so a save writes it as a file of the level's own
    #: beside a regenerated fragment.
    #:
    #: Empty for a level with no row -- every slot the tileset's -- and for a
    #: level built by hand to ask a question about records. An all-``$FF``
    #: row and no row are the same level, and :meth:`with_graphics` keeps
    #: them apart only as bytes.
    graphics: bytes = b""

    #: Whether the cartridge these records are for reads the second extra bit
    #: as the custom-sprite flag -- see :attr:`shiny_mushroom.sprites.Sprite.custom`.
    #: A property of the document because every reparse has to answer the
    #: same way the first read did: an edit rebuilds the records from the
    #: re-encoded stream, and a rebuild that forgot the flag would strip
    #: every custom sprite's name and picture on the first move.
    custom_sprites: bool = False

    #: How many extra bytes each custom number's records carry -- the
    #: loader's stride, from the built cartridge's own count table, and a
    #: property of the document for the reason the flag is: a reparse under
    #: different counts is a different reading of the same bytes.
    extra_counts: Mapping[int, int] = field(default_factory=dict)

    #: What the project calls each custom number -- carried beside the
    #: counts for the same reason: an edit rebuilds the records from the
    #: re-encoded stream, and a rebuild that forgot the names would strip
    #: them from every custom sprite on the first move.
    custom_names: Mapping[int, str] = field(default_factory=dict)

    #: The next unused identity, handed out by :meth:`added` to a record that
    #: was not in the level when it was read. It lives here rather than in the
    #: window because it is a property of *this level's* pool of ids, and
    #: because a caller that has to remember to advance a counter is a caller
    #: that eventually does not.
    #:
    #: Out of the comparison, deliberately: two levels holding the same records
    #: are the same level whether or not the same number of things have been
    #: placed and undone along the way.
    next_uid: int = field(default=1, compare=False)

    # -- reading one in -----------------------------------------------------

    @classmethod
    def read(
        cls,
        objects: bytes,
        sprites: bytes,
        shape: Geometry,
        header: bytes = b"",
        layer2: bytes = b"",
        layer2_objects: bytes = b"",
        layer2_header: bytes = b"",
        secondary: bytes = b"",
        graphics: bytes = b"",
        custom_sprites: bool = False,
        extra_counts: Mapping[int, int] = {},
        custom_names: Mapping[int, str] = {},
    ) -> Level:
        """Read both of a level's streams, stamping every record with an id.

        ``objects`` starts at the first record -- the five header bytes are the
        level's, not the stream's, and come in separately as ``header`` -- and
        ``sprites`` starts at its header byte, which is exactly what
        :func:`~shiny_mushroom.rom_patches.object_stream` and
        :func:`~shiny_mushroom.rom_patches.sprite_stream` hand back.

        ``header`` is optional because a level built to ask a question about
        records does not have one and should not have to invent five bytes to
        be read; what it costs is that :attr:`fg_bg_tileset` then answers zero.

        ``layer2_objects`` is the level's Layer 2 where that is a stream rather
        than a background, starting at *its* first record for the same reason
        -- the five bytes in front of it are ``layer2_header`` -- and empty for
        every other level. It is read under the same ``shape``: a Layer 2 level
        is the same geometry drawn into the other half of the buffer.

        ``graphics`` is the level's own eight-byte graphics row where the
        project or the cartridge holds one -- see :attr:`graphics` -- and
        empty otherwise; a length other than 0 or 8 is refused.
        """
        parsed_objects = parse_objects(objects, shape)
        parsed_sprites = parse_sprites(
            sprites, shape, custom_sprites, extra_counts, custom_names
        )
        uid = 1
        stamped_objects = []
        for obj in parsed_objects:
            stamped_objects.append(replace(obj, uid=uid))
            uid += 1
        stamped_sprites = []
        for sprite in parsed_sprites:
            stamped_sprites.append(replace(sprite, uid=uid))
            uid += 1
        # One pool for all three streams, so a selection is a set of numbers
        # and nothing has to say which stream a number came out of.
        stamped_layer2 = []
        for obj in parse_objects(layer2_objects, shape):
            stamped_layer2.append(replace(obj, uid=uid))
            uid += 1
        return cls(
            shape=shape,
            objects=tuple(stamped_objects),
            sprites=tuple(stamped_sprites),
            header=bytes(header),
            sprite_header=sprites[0] if sprites else 0,
            layer2=bytes(layer2),
            layer2_objects=tuple(stamped_layer2),
            layer2_header=bytes(layer2_header),
            secondary=bytes(secondary),
            graphics=_checked_graphics(graphics),
            custom_sprites=custom_sprites,
            extra_counts=dict(extra_counts),
            custom_names=dict(custom_names),
            next_uid=uid,
        )

    # -- what is in it ------------------------------------------------------

    @property
    def fg_bg_tileset(self) -> int:
        """Header byte 4 bits 3-0: which of the five object tables this level's
        object *numbers* are read against.

        One of the two header fields read here at all, and it is here because it
        is the one the **records** depend on: the same number is a different
        object in a different tileset, so nothing can say what an object *is*
        without it. Zero for a level carrying no header, which is the same
        answer a level in tileset zero gives -- a name, and not a wrong one.
        """
        return field_value(self.header, "fg_bg_tileset")

    @property
    def sprite_tileset(self) -> int:
        """Header byte 2 bits 3-0: which four graphics files land in SP1-SP4.

        The other one, and chosen independently of :attr:`fg_bg_tileset`. It
        says nothing about what a sprite record *is* -- a sprite number means
        one thing across a cartridge -- only about whether its artwork will be
        loaded where it sits, which is the create panel's warning to give.
        """
        return field_value(self.header, "sprite_tileset")

    @property
    def layer2_records(self) -> bool:
        """Whether this level's Layer 2 is an object stream of its own.

        The five carried header bytes are what says so, because a Layer 2 level
        that draws nothing is still a Layer 2 level; a level built by hand out
        of records alone answers from whether it was given any.
        """
        return bool(self.layer2_header or self.layer2_objects)

    @property
    def _streams(self) -> tuple[Sequence[Record], ...]:
        """The three record lists, in the order a readout walks them."""
        return (self.objects, self.sprites, self.layer2_objects)

    def record(self, uid: int) -> Record | None:
        """The record ``uid`` names, from whichever stream holds it."""
        for records in self._streams:
            for found in records:
                if found.uid == uid:
                    return found
        return None

    def records(self, uids: Collection[int]) -> list[Record]:
        """The records ``uids`` names, objects first and each stream in its own
        order -- which is the order an edit has to apply them in, and the order
        a readout should list them in."""
        return [
            found for records in self._streams for found in records if found.uid in uids
        ]

    def movable(self, uids: Collection[int]) -> frozenset[int]:
        """Which of ``uids`` name a record with a position to change.

        The commands do not -- a screen exit's position bits are the screen it
        acts on, a scroll command's are the scroll type -- so a drag over a
        selection that includes one moves everything else and leaves it be,
        rather than refusing the whole gesture or quietly rewriting it.
        """
        return frozenset(found.uid for found in self.records(uids) if found.movable)

    def streams(self) -> tuple[bytes, bytes]:
        """This level as the two streams a cartridge holds, terminators and all.

        The object stream first, then the sprite stream. What to *do* with them
        -- where they go in a cartridge image, and what has to move if they no
        longer fit -- is :mod:`shiny_mushroom.emu.smw`'s business.

        Layer 2's stream is not among them, because it is not one of the two:
        it has a pointer table of its own, a container region of its own and a
        set of levels sharing it that is not this level's. :meth:`layer2_stream`
        is where it comes out, so nothing can write it by accident.
        """
        return (
            encode_objects(self.objects, self.shape)[0],
            encode_sprites(self.sprites, self.shape, self.sprite_header),
        )

    def layer2_stream(self) -> bytes:
        """This level's Layer 2 records as the stream a cartridge holds.

        The records alone, without :attr:`layer2_header` -- what goes in front
        of them is the caller's to put back, exactly as Layer 1's five bytes
        are. Empty for a level whose Layer 2 is a background or nothing.
        """
        if not self.layer2_records:
            return b""
        return encode_objects(self.layer2_objects, self.shape)[0]

    # -- changing it --------------------------------------------------------

    def step(self, uids: Collection[int], columns: int, rows: int) -> tuple[int, int]:
        """How far a move of ``uids`` by ``(columns, rows)`` would actually go.

        The answer :meth:`moved` acts on, without building the level it would
        produce -- which is what a drag needs while it is still in the hand.
        Asking every frame for the level a gesture *would* make means rewriting
        both streams sixty times a second to draw an outline somewhere else, and
        the outline is the only part of it anyone sees until the button comes up.

        ``(0, 0)`` means the move would do nothing: nothing movable is held, or
        the group is already against the edge it is being pushed into.
        """
        moving = self.movable(uids)
        if not moving or (columns == 0 and rows == 0):
            return 0, 0
        return self._trim(self.records(moving), columns, rows)

    def moved(self, uids: Collection[int], columns: int, rows: int) -> Level | None:
        """Translate every movable record in ``uids`` by ``(columns, rows)``
        blocks.

        **The group moves or it does not.** The step is trimmed until every
        record in it is still inside the level, rather than each record being
        clamped where it lands: clamping individually collapses a selection
        against an edge -- the leading records stop, the trailing ones keep
        coming, and the shape that was dragged is not the shape that arrives.
        Trimming the step keeps the group rigid, so pushing a selection into a
        wall stops it instead of squashing it.
        """
        columns, rows = self.step(uids, columns, rows)
        if columns == 0 and rows == 0:
            return self
        moving = self.movable(uids)
        return self._rebuild(
            [self._translate(obj, moving, columns, rows) for obj in self.objects],
            [self._translate(spr, moving, columns, rows) for spr in self.sprites],
            [
                self._translate(obj, moving, columns, rows)
                for obj in self.layer2_objects
            ],
        )

    def added(self, *records: Record, layer2: bool = False) -> Level | None:
        """This level with ``records`` put into their own streams, on top.

        The one operation that brings something into a level rather than
        rearranging what is already there, so it is the one that hands out
        identities: whatever a caller passed in :attr:`~Record.uid` is
        overwritten with :attr:`next_uid` and the ones after it, in the order
        they were given, and the level that comes back has moved the counter
        past them. A caller that needs to select what it just placed reads
        :attr:`next_uid` **before** the call -- that is the number the first
        record will have, and the rest run on from it.

        **Several at once rather than one call each**, because a paste is a
        group and every call is a rewrite of both streams: adding six records
        one at a time would encode and re-parse the level six times to produce
        the level one call already produces. It is also the only way the group
        gets *consecutive* ids, which is what lets the caller name what it just
        pasted as a range rather than by collecting return values.

        **On top, because order is depth.** The loader writes objects in stream
        order and each overwrites what the last one put there, so an appended
        object is the one you can see; anywhere else in the stream and half of
        what is placed would arrive buried, and the reorder keys are how it is
        sent back. A sprite lands on top **of its own screen** instead: the
        rebuild keeps the sprite list in the game's screen order -- see
        :meth:`_sprite_order`, and the loader's early-out that demands it --
        and the sort being stable is what makes the newcomer the last of its
        screen rather than the last of the list.

        Where they land is the records' own business, and this checks none of it:
        a position outside the level, a settings byte that means nothing, a
        screen exit on a screen that already has one. Those are decisions with
        answers elsewhere -- the caller places from a click on the picture, and
        the format's own rules are the field descriptors' -- and a guard here
        could only be a second, quieter copy of them.

        ``layer2`` sends the objects to :attr:`layer2_objects` instead of to
        Layer 1's stream, which is the one thing about a record that its own
        bytes cannot say: an object is an object, and which layer it is being
        placed on is a fact about the gesture. Sprites ignore it -- a level has
        one sprite list, whichever layer is being edited.

        Adding nothing hands back the level it was given, like every other
        operation with nothing to do, so a paste with an empty clipboard is not
        an undo step.
        """
        if not records:
            return self
        uid = self.next_uid
        objects = list(self.objects)
        sprites = list(self.sprites)
        layer2_objects = list(self.layer2_objects)
        for record in records:
            stamped = replace(record, uid=uid)
            uid += 1
            if not isinstance(stamped, LevelObject):
                sprites.append(stamped)
            elif layer2:
                layer2_objects.append(stamped)
            else:
                objects.append(stamped)
        return replace(self, next_uid=uid)._rebuild(objects, sprites, layer2_objects)

    def landing(self, records: Sequence[Record], column: int, row: int) -> list[Record]:
        """``records`` moved as a group so their origin sits at ``(column,
        row)``, trimmed to stay inside this level.

        Where a copy would go, worked out without building the level it would
        produce -- the same relationship :meth:`step` has to :meth:`moved`, and
        for the same reason: what lands has to be known before it is committed.

        Three rules, each already stated somewhere else and none of them new
        here:

        - **The origin is the movable records' top-left**, from
          :func:`group_origin`. A command's position bits are not a position, so
          letting a screen exit into the box would anchor the group on a number
          that means a screen.
        - **Only the movable records move.** A screen exit pasted with a group
          lands on the screen it names, exactly as it stays put while the rest of
          a selection is dragged around it.
        - **The group moves or it does not**, trimmed by :meth:`_trim` so every
          origin is still inside the level rather than each record being clamped
          where it fell. A copy pasted against the right edge arrives whole and
          a block short, rather than folded up against the wall.

        ``records`` need not be in this level, and normally are not: they are the
        clipboard's, and may have been copied out of a different one. Their ids
        come from wherever they came from and are overwritten by :meth:`added`.
        """
        origin = group_origin(records)
        if origin is None:
            # Nothing here has a position, so there is nothing to anchor and
            # nothing an anchor could mean. A screen exit on its own pastes onto
            # the screen it names.
            return list(records)
        moving = [found for found in records if found.movable]
        dc, dr = self._trim(moving, column - origin[0], row - origin[1])
        return [
            found.placed_at(found.column + dc, found.row + dr, self.shape)
            if found.movable
            else found
            for found in records
        ]

    def with_header(self, header: bytes, shape: Geometry) -> Level | None:
        """This level with different header bytes, and the shape they give it.

        The header is part of the document, so changing it is an ordinary edit:
        one undo step, restored by an undo along with everything it implies, and
        written by the same save. Nothing else here would be true if it were
        held beside the document instead -- an undo would take back the records
        and leave the header, and the two would disagree about what the level
        is.

        **The shape comes in with it**, rather than being worked out. The screen
        count is a header field, but whether a level runs *down* is a byte of
        the cartridge's ``VerticalTable`` indexed by header byte 1's mode, and
        this module has no cartridge -- so the caller, which does, answers that
        question once and hands both halves over together. They must not be able
        to arrive separately: a level holding a header saying one shape and a
        :attr:`shape` saying another would encode its records into a stream the
        loader reads differently.

        **A change of shape rewrites the records**, and that is the whole reason
        this is not just a field assignment. A record's screen, its bytes and
        the jumps that place it are all facts about the stream under *a
        geometry*; re-encoding at the block coordinates the records already have
        is what keeps an object where it was on screen while the bytes under it
        become what the loader now needs. Reading the old bytes back under the
        new geometry would do the opposite -- keep the bytes and move everything.
        """
        header = bytes(header)
        if header == self.header and shape == self.shape:
            return self
        changed = replace(self, header=header, shape=shape)
        if shape == self.shape:
            return changed
        return changed._rebuild(self.objects, self.sprites, self.layer2_objects)

    def with_secondary(self, secondary: bytes) -> Level:
        """This level with different secondary-header bytes.

        An ordinary edit for the reason a header edit is -- the four bytes are
        part of the document -- and simpler than one: nothing about the streams
        depends on them, so no rebuild. Where the level's *entrance* lands is
        the loader's business, re-read from the patched preview.
        """
        secondary = bytes(secondary)
        if secondary == self.secondary:
            return self
        return replace(self, secondary=secondary)

    def with_graphics(self, graphics: bytes) -> Level:
        """This level with a different graphics row.

        An ordinary edit exactly as a secondary-header edit is: the row is
        part of the document and nothing about the streams depends on it, so
        no rebuild. Empty is a level with no row of its own. What the level
        will *load* is :meth:`effective_graphics`'s answer, which needs the
        cartridge's two tileset lists this module has not got.
        """
        graphics = _checked_graphics(graphics)
        if graphics == self.graphics:
            return self
        return replace(self, graphics=graphics)

    def effective_graphics(
        self, *, sprite_row: bytes, fgbg_row: bytes
    ) -> tuple[int, ...]:
        """The eight files this level loads, in slot order FG1, FG2, BG1,
        FG3, SP1, SP2, SP3, SP4: the two tileset rows -- ``fgbg_row`` the
        four bytes of ``FGAndBGGFXList`` the header's FG/BG tileset
        indexes, ``sprite_row`` the four of ``SpriteGFXList`` its sprite
        tileset indexes -- with :attr:`graphics` laid over them, which is
        exactly what the feature's stubs do
        (:func:`smw_tools.level_graphics.effective`). The caller reads the
        rows out of the cartridge, since this module has none.

        Both rows are keyword-only: they are four bytes each and neither
        spelling of a swap is wrong enough to raise, so a transposed call
        would answer with eight plausible files that are not this level's.
        """
        record = decode_graphics(self.graphics) if self.graphics else None
        return effective_graphics(record, fgbg_row=fgbg_row, sprite_row=sprite_row)

    def layer2_placed(self, entries: Mapping[int, int]) -> Level:
        """This level with background entries changed: index in the two-screen
        pattern to the tile's low byte.

        The background's counterpart to placing an object, and simpler than
        any record edit because the tilemap *is* the stored form -- there is
        no stream to rewrite and no identity to keep. A paint stroke commits
        one call covering every cell it touched, which is what makes the
        stroke one undo step.

        Returns ``self`` when the level has no editable background, when every
        entry is out of the pattern's range, or when nothing would change --
        the identity every operation keeps, so a click on the tile already
        there is not an undo step.
        """
        if not self.layer2:
            return self
        edited = bytearray(self.layer2)
        for index, tile in entries.items():
            if 0 <= index < len(edited):
                edited[index] = tile & 0xFF
        if bytes(edited) == self.layer2:
            return self
        return replace(self, layer2=bytes(edited))

    def replaced(self, uid: int, record: Record) -> Level | None:
        """This level with the record ``uid`` names swapped for ``record``.

        The general edit, and what everything that changes a record's *fields*
        commits through -- the properties panel and the resize keys alike. A
        field descriptor knows how to turn a record into the record it would be
        with one field changed, and this is where that lands.

        A move is its own operation, because it means something this does not:
        a group moves or it does not, trimmed against the edge of the level so a
        selection stays rigid. This one means nothing beyond "hold this
        instead", so its guard rails are the *field's*.

        **Resizing is not an operation here**, and it is worth saying why the
        reason changed. It used to be that a :class:`Level` held no tileset --
        which nibble of a settings byte is a width is a property of the object
        *and* the tileset it is read under -- so an operation on this side could
        only ever have sized the fourteen objects the format promises a size
        for. That barrier is gone: the header came into the document with the
        records, and :attr:`fg_bg_tileset` is right here.

        What keeps it out is now the weaker of the two reasons and is still
        enough. A resize is a *gesture* that steps a field descriptor, exactly
        as the properties panel does, and both of those are the window's --
        ``MainWindow.resize_selection`` and ``_commit_field`` are the same three
        lines around a different source of the number. Moving one of them here
        without the other would split a pair; moving both would put the
        descriptors' vocabulary in a module whose subject is streams. Neither is
        an improvement anybody has needed, and this is the note that says the
        old reason no longer applies.

        What this does check is that the record stays in its own stream: an
        object cannot be replaced by a sprite, because the two streams are
        written separately and a record that changed sides would be dropped
        from one and never reach the other.

        Returns ``self`` when nothing matches or the record is already the one
        held, which keeps a committed-but-unchanged field out of the undo stack.
        """
        found = self.record(uid)
        if found is None or type(found) is not type(record):
            return self
        if found == record:
            return self
        record = replace(record, uid=uid)
        if not isinstance(record, LevelObject):
            return self._rebuild(
                self.objects,
                [record if spr.uid == uid else spr for spr in self.sprites],
                self.layer2_objects,
            )
        # Which of the two object streams holds it is a fact about the level,
        # not about the record: the record itself cannot say which layer it is
        # on, so the swap is made in whichever list the id is already in.
        if any(obj.uid == uid for obj in self.layer2_objects):
            return self._rebuild(
                self.objects,
                self.sprites,
                [record if obj.uid == uid else obj for obj in self.layer2_objects],
            )
        return self._rebuild(
            [record if obj.uid == uid else obj for obj in self.objects],
            self.sprites,
            self.layer2_objects,
        )

    def without(self, uids: Collection[int]) -> Level | None:
        """This level with every record in ``uids`` removed.

        Commands included, unlike a move: a screen exit has no position to drag
        but it is a record in the level like any other, and deleting one is how
        an exit is taken out.
        """
        gone = frozenset(uids)
        objects = [obj for obj in self.objects if obj.uid not in gone]
        sprites = [spr for spr in self.sprites if spr.uid not in gone]
        layer2 = [obj for obj in self.layer2_objects if obj.uid not in gone]
        if (
            len(objects) == len(self.objects)
            and len(sprites) == len(self.sprites)
            and len(layer2) == len(self.layer2_objects)
        ):
            return self
        return self._rebuild(objects, sprites, layer2)

    def reordered(self, uids: Collection[int], delta: int) -> Level | None:
        """Shift every record in ``uids`` one place along its own stream.

        Order *is* depth. The loader writes objects in stream order and each
        overwrites what the last one put there, and the sprite list is drawn the
        same way, so ``+1`` brings a record forward and ``-1`` sends it back.

        Each selected record steps past its nearest **unselected** neighbour,
        which is what keeps a multi-selection's own internal order while it
        moves through the rest of the level. A record already at its end of the
        stream, or blocked by another selected one, stays where it is -- so a
        group pressed against the top of the pile settles there rather than
        scrambling itself.

        A sprite steps within its own screen only: the stream keeps the game's
        screen order -- see :meth:`_sprite_order` -- so a step that would carry
        one past a record on another screen changes nothing, exactly like a
        step off the end of the stream. Depth across screens is not a degree of
        freedom the format has.
        """
        chosen = frozenset(uids)
        if not chosen or delta == 0:
            return self
        objects = _shift(self.objects, chosen, delta)
        sprites = self._sprite_order(_shift(self.sprites, chosen, delta))
        layer2 = _shift(self.layer2_objects, chosen, delta)
        if (
            objects == list(self.objects)
            and sprites == list(self.sprites)
            and layer2 == list(self.layer2_objects)
        ):
            return self
        return self._rebuild(objects, sprites, layer2)

    # -- the rewrite --------------------------------------------------------

    def _rebuild(
        self,
        objects: Sequence[LevelObject],
        sprites: Sequence[Sprite],
        layer2_objects: Sequence[LevelObject],
    ) -> Level | None:
        """Encode these records and read them straight back, keeping their ids.

        The heart of the module, and the reason an edit here cannot drift from
        what the cartridge will hold: what comes out is the *parse of the bytes
        that would be written*, so a record's own bytes, its offset, its index
        in the list and the screen it landed on are all facts about the stream
        rather than about what the editor meant.

        It also absorbs the one thing an encoder can add that no caller asked
        for, and this is the subtle half. Moving an object two screens along can
        leave a gap the new-screen bit cannot count across, and
        :func:`~shiny_mushroom.objects.encode_objects` fills it with a screen
        jump. Those records come back with no id and are **dropped again here**:
        a level holds the records someone put in it, and the jumps that place
        them are re-derived every time the stream is written.

        Keeping them would be the obvious thing and is wrong twice over. They
        would accumulate -- drag an object across a boundary and back and the
        stream is three bytes longer than it started, once per round trip -- and
        the only way to stop that is to drop jumps that turn out to be redundant,
        which cannot be done without also dropping the redundant ones the
        cartridge itself ships (level ``$0DE`` has one). A level read and written
        back unchanged has to be byte-identical, and this is what keeps it so.

        ``layer2_objects`` goes through the identical mill, because a Layer 2
        level is the same kind of stream under the same geometry. It has no
        default, deliberately: every operation must say what it did to all
        three lists, and an omitted one would quietly empty a level's Layer 2
        rather than fail.

        ``None`` for the one arrangement the streams cannot hold: a sprite whose
        byte 0 would be the terminator -- see
        :class:`~shiny_mushroom.sprites.UnencodableSprite`. Every operation
        hands that ``None`` straight back, so the edit is refused, the level is
        left alone, and the caller can say so -- which is the whole difference
        between this and an operation that had nothing to do.
        """
        stream, uids = encode_objects(objects, self.shape)
        rebuilt_objects = [
            replace(obj, uid=uid)
            for obj, uid in zip(parse_objects(stream, self.shape), uids, strict=True)
            if uid != 0
        ]
        # Sprites need no such reconciliation -- every record is three bytes
        # and none of them moves a cursor, so the list that goes in is the list
        # that comes back, record for record -- but they do need the game's
        # order; see :meth:`_sprite_order`.
        sprites = self._sprite_order(sprites)
        try:
            stream = encode_sprites(sprites, self.shape, self.sprite_header)
        except UnencodableSprite:
            return None
        rebuilt_sprites = [
            replace(parsed, uid=sprite.uid)
            for parsed, sprite in zip(
                parse_sprites(
                    stream,
                    self.shape,
                    self.custom_sprites,
                    self.extra_counts,
                    self.custom_names,
                ),
                sprites,
                strict=True,
            )
        ]
        layer2_stream, layer2_uids = encode_objects(layer2_objects, self.shape)
        rebuilt_layer2 = [
            replace(obj, uid=uid)
            for obj, uid in zip(
                parse_objects(layer2_stream, self.shape), layer2_uids, strict=True
            )
            if uid != 0
        ]
        return replace(
            self,
            objects=tuple(rebuilt_objects),
            sprites=tuple(rebuilt_sprites),
            layer2_objects=tuple(rebuilt_layer2),
        )

    def _sprite_order(self, sprites: Sequence[Sprite]) -> list[Sprite]:
        """``sprites`` in the order the cartridge must hold them: by screen.

        Not a preference. The game's sprite loader
        (``SMW_ParseLevelSpriteList``) scans the list front to back each frame
        and **returns at the first record past the camera's screen**, so a
        record sitting behind a higher screen's is never reached -- it simply
        never spawns, however correct its own bytes are. Every shipped level's
        list is already in this order, which is what keeps the sort byte-exact
        on a stream nobody edited.

        Stable, so within one screen the order stays depth -- what
        :meth:`added` and :meth:`reordered` mean by "on top". The key is
        derived from the position, exactly as the encoder derives the screen
        bits it writes, rather than read from :attr:`~Sprite.screen`, which a
        move has not updated yet.
        """
        return sorted(
            sprites, key=lambda found: self.shape.screen_of(found.column, found.row)
        )

    def _translate(self, found: Record, moving: Collection[int], dc: int, dr: int):
        """One record moved, or the same record when it is not in the group."""
        if found.uid not in moving:
            return found
        return found.placed_at(found.column + dc, found.row + dr, self.shape)

    def _trim(
        self, placed: Sequence[Record], columns: int, rows: int
    ) -> tuple[int, int]:
        """The largest part of a step that keeps every moving record's **origin**
        inside the level.

        Each axis on its own, so a drag into a corner still slides along the
        wall it is against instead of stopping dead.

        The origin and not the footprint, which matters for a wide object near
        the right edge: the cartridge's own levels contain objects that reach
        past their last screen, and bounding the footprint would make those
        immovable in the direction they already overhang. What the level format
        can express is where a record *starts*, so that is what is held inside
        it.

        Takes the records rather than their ids, because the group being fitted
        is not always one this level holds: :meth:`landing` asks it about the
        clipboard's.
        """
        if not placed:
            return 0, 0
        left = min(found.column for found in placed)
        right = max(found.column for found in placed)
        top = min(found.row for found in placed)
        bottom = max(found.row for found in placed)
        columns = max(-left, min(self.shape.columns - 1 - right, columns))
        rows = max(-top, min(self.shape.rows - 1 - bottom, rows))
        return columns, rows


def _shift(records: Sequence[Record], chosen: Collection[int], delta: int) -> list:
    """``records`` with each chosen one stepped past its nearest unchosen
    neighbour.

    Walked from the end forwards and from the front backwards, which is the
    whole of what makes a group keep its own order: taken in the direction of
    travel, the first record to move is the one nearest the destination, so the
    one behind it finds the place it just left rather than the place it was.
    """
    shifted = list(records)
    steps = range(len(shifted) - 1, -1, -1) if delta > 0 else range(len(shifted))
    for index in steps:
        if shifted[index].uid not in chosen:
            continue
        neighbour = index + (1 if delta > 0 else -1)
        if not 0 <= neighbour < len(shifted):
            continue
        if shifted[neighbour].uid in chosen:
            continue
        shifted[index], shifted[neighbour] = shifted[neighbour], shifted[index]
    return shifted


class History[T]:
    """Snapshot undo over an immutable document, a :class:`Level` here.

    A stack of whole documents rather than a log of reversible actions, which is
    the right trade here for a reason that is about the *format* and not about
    convenience: an edit rewrites both streams, so what an "inverse action"
    would have to restore is the stream, and a stream is exactly what a snapshot
    already is. It also means a new kind of edit is undoable the day it is
    written, with nothing to remember to add.

    A level is a few kilobytes of records, so :data:`HISTORY_DEPTH` of them is
    small enough not to be worth being clever about.

    Nothing here calls a method of what it holds -- only identity is used -- so
    any immutable document whose operations return ``self`` for a no-op gets
    the same undo the day it exists. The world map is one.

    **A step may carry a mark beside its document**, opaque here: whatever the
    caller needs putting back when that document comes back. What a selection
    was is the reason it exists -- an undo that restores the tiles and leaves
    the ants where the edit left them has only half taken the edit back -- and
    it is *not* part of the document, because a selection is not something a
    save writes. Every push says what to restore with what it pushes: a commit
    for the document it leaves behind, an undo or a redo for the one it is
    stepping off. A step pushed without one restores nothing, which is how an
    edit whose selection needs no help stays as it was.
    """

    def __init__(self, level: T) -> None:
        self._level = level
        #: What was loaded. Kept so the window can tell an edited level from an
        #: untouched one without walking the stack.
        self._base = level
        self._past: list[tuple[T, object]] = []
        self._future: list[tuple[T, object]] = []
        self._mark: object = None

    @property
    def level(self) -> T:
        """The document as it now stands."""
        return self._level

    @property
    def mark(self) -> object:
        """What the last :meth:`undo` or :meth:`redo` restored beside the
        document, or ``None`` for a step that carried no mark."""
        return self._mark

    @property
    def base(self) -> T:
        """The level as it was last loaded or saved -- what :attr:`edited` is
        measured against.

        Offered as well as the boolean because "has anything changed" is not
        always the question. Turning an edit into a cartridge patch needs to
        know *which part* changed: a header that has moved is five bytes at a
        known offset, and a stream that has moved may have to be relocated.
        """
        return self._base

    @property
    def edited(self) -> bool:
        """Whether anything has changed since the level was read."""
        return self._level is not self._base

    @property
    def can_undo(self) -> bool:
        return bool(self._past)

    @property
    def can_redo(self) -> bool:
        return bool(self._future)

    def commit(self, level: T, mark: object = None) -> bool:
        """Make ``level`` the present, reporting whether anything changed.

        A level that is the one already held is **not** committed, and that is
        what keeps the stack honest: an operation returns ``self`` when it had
        nothing to do -- a drag that hit the edge of the level, a resize of
        something that has no size -- and an undo entry for each of those would
        mean pressing undo several times to take back one edit.

        ``mark`` is what an undo of this step puts back beside the level it
        goes back to -- the selection the edit was made from.

        Anything new discards the redo branch, which is what every editor does
        and what anyone who has just typed over a redo expects.
        """
        if level is self._level:
            return False
        self._past.append((self._level, mark))
        del self._past[:-HISTORY_DEPTH]
        self._future.clear()
        self._level = level
        return True

    def note(self, mark: object) -> None:
        """A step that moves the document not at all and carries only a mark.

        What a floating selection dragged somewhere else is: nothing is written
        while the pixels are in the air, and yet the drag is an interaction an
        undo has to take back, and a redo has to put the pixels up again. The
        step's document is the one already held, so :attr:`edited` does not
        move; only the mark does. Discards the redo branch, as any new step
        does, since what came after was made from somewhere else.
        """
        self._past.append((self._level, mark))
        del self._past[:-HISTORY_DEPTH]
        self._future.clear()

    def saved(self) -> None:
        """Take the level as it stands to be the saved one.

        What :attr:`edited` is measured against moves; **the stack does not**.
        Saving is not an edit and not a barrier: undo has to keep working across
        one, because "save, then realise, then undo" is an ordinary sequence and
        an editor that answered it by having forgotten everything would be worse
        than one that never saved at all.

        Which also means :attr:`edited` can go back to true by *undoing* past the
        save, and that is correct: the level no longer matches what is on disk.
        """
        self._base = self._level

    def rebase(self, base: T) -> None:
        """Take ``base`` to be the saved document -- :meth:`saved` for a save
        that wrote only part of what stands, moving only that part's measure.

        The caller builds ``base`` from the old one with the written part
        replaced, so :attr:`edited` keeps answering for the part still owed.
        The stack is left alone, exactly as :meth:`saved` leaves it.
        """
        self._base = base

    def replace(self, level: T, mark: object = None) -> bool:
        """Swap the present for ``level`` without a step of its own.

        What a gesture still refining its **last** commit uses -- a floating
        paste dragged somewhere else -- so however far the refinement travels,
        one undo takes the whole journey back. The caller owns the claim that
        the present *is* its commit; this only keeps the stack honest about
        the two ways a refinement can degenerate:

        - Replacing with what is already held is nothing, exactly as
          :meth:`commit` treats it.
        - Replacing with what the last commit was **made from** collapses the
          step instead of keeping it: the edit has gone back to changing
          nothing, and an undo entry for nothing is the failure ``commit``
          refuses.

        The redo branch is left alone. A refinement can only follow its own
        commit, and that commit already cleared it.

        ``mark`` **overwrites** the step's own, because the refinement is where
        the step now stands: a paste dragged three blocks on comes back into
        hand where it last was, not where it first landed. A collapsed step
        takes its mark with it, having no document left to restore beside.
        """
        if level is self._level:
            return False
        if self._past and self._past[-1][0] is level:
            self._level, _ = self._past.pop()
        elif self._past:
            self._level = level
            self._past[-1] = (self._past[-1][0], mark)
        else:
            self._level = level
        return True

    def ahead(self, back: bool) -> object:
        """The mark the next :meth:`undo` (``back``) or :meth:`redo` would
        restore, without walking.

        What a caller that must act *around* a walk reads first: a step whose
        mark says it needs more than the document put back -- a Layer 2
        repoint, whose pointer lives in the project rather than in the
        document -- has to be recognised before the stack moves, or a failure
        to do that outside work would leave the stack already walked.
        """
        stack = self._past if back else self._future
        return stack[-1][1] if stack else None

    def undo(self, mark: object = None) -> bool:
        """Step back one edit, reporting whether there was one.

        ``mark`` is what a redo back to here restores -- the selection as it
        stands now, which the step being stepped off never got to say.
        """
        if not self._past:
            return False
        self._future.append((self._level, mark))
        self._level, self._mark = self._past.pop()
        return True

    def redo(self, mark: object = None) -> bool:
        """Step forward again, reporting whether there was anywhere to go.

        ``mark`` is what an undo back to here restores, as it is for
        :meth:`undo`.
        """
        if not self._future:
            return False
        self._past.append((self._level, mark))
        self._level, self._mark = self._future.pop()
        return True


def group_origin(records: Iterable[Record]) -> tuple[int, int] | None:
    """The top-left block a group of records starts at, or ``None`` for a group
    with no position at all.

    **The movable ones only**, which is what makes this different from the
    corner of :func:`bounding_blocks`. A command's low bits are the screen it
    acts on rather than a place, so a screen exit let into the box would anchor
    a paste on a number that is not a coordinate -- and it would do it silently,
    because that number looks exactly like one.

    The origin rather than the whole box, because it is what a group is carried
    *by*: :meth:`Level.landing` moves everything by the difference between this
    and where the group is being put, which is how a copy keeps its own shape.
    """
    placed = [found for found in records if found.movable]
    if not placed:
        return None
    return (
        min(found.column for found in placed),
        min(found.row for found in placed),
    )


def bounding_blocks(records: Iterable[Record]) -> tuple[int, int, int, int] | None:
    """The block rectangle a set of records covers, or ``None`` for none of them.

    ``(left, top, right, bottom)``, all inclusive. An object covers its
    footprint and a sprite its block -- the record's own extent rather than the
    artwork's, because this answers questions about *level coordinates*: where a
    group would land, and whether that is still inside the level.
    """
    left = top = right = bottom = None
    for found in records:
        width = found.width if isinstance(found, LevelObject) else 1
        height = found.height if isinstance(found, LevelObject) else 1
        left = found.column if left is None else min(left, found.column)
        top = found.row if top is None else min(top, found.row)
        far = found.column + width - 1
        low = found.row + height - 1
        right = far if right is None else max(right, far)
        bottom = low if bottom is None else max(bottom, low)
    if left is None:
        return None
    return left, top, right, bottom
