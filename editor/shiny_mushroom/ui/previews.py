"""What the create panel is offering, and the round trips that fill it in.

The panel (:mod:`shiny_mushroom.ui.create`) lists what a level could hold and
shows a small picture of each row. Neither the list nor the pictures are cheap
facts: an object list belongs to a *tileset*, an object's shape is what the
game's own loader was traced drawing, and a sprite's artwork is a capture of its
drawing code. So this is a small state machine rather than a lookup -- it
remembers what has already been asked for, batches what has not, and adds
whatever comes back to what is already on offer.

**Three sources, arriving at three different times**, which is the whole reason
the pictures accumulate rather than being recomputed: the level's own records at
load, the object catalogue a round trip later, and one sprite at a time as the
pointer rests on rows.

It reaches the emulator through two signals of its own, connected to the loader
alongside the window's -- see ``MainWindow.load_level``. It reads the window
through one callable, :class:`Held`, asked afresh every time rather than
captured: a probe outlives several edits, and the level it should be describing
is the one on the canvas now.
"""

from __future__ import annotations

import logging
from collections.abc import Callable, Mapping
from dataclasses import dataclass
from typing import NamedTuple

from PySide6.QtCore import QObject, Signal
from PySide6.QtGui import QImage

from shiny_mushroom.addresses import Addresses
from shiny_mushroom.catalog import (
    CatalogKey,
    Entry,
    Stream,
    art_verdict_under,
    drawn_as_placed,
    key_of,
    object_entries,
    probe_stream,
    sprite_entries,
    tilesets_loading,
)
from shiny_mushroom.edit import Level
from shiny_mushroom.index import LevelIndex
from shiny_mushroom.level import geometry, level_shape
from shiny_mushroom.level_snapshot import LevelSnapshot
from shiny_mushroom.objects import crashes_the_loader, parse_objects
from shiny_mushroom.preview import Thumbnail, previews_from, sprite_preview
from shiny_mushroom.rom_patches import gfx_list_rows, level_patch
from shiny_mushroom.sprite_art import SpriteTile
from shiny_mushroom.ui.create import CreateDock
from shiny_mushroom.ui.render import pixels_to_image
from smw_tools.level_graphics import LAYER_SLOTS

_log = logging.getLogger(__name__)

# How long the scratch level a catalogue probe loads is made, in screens. The
# most the format can express, because the grid needs room: a one-screen level
# has six cells and the catalogue has hundreds of objects. Only the screen count
# is changed -- the tileset nibble is untouched, so the graphics and the Map16
# definitions the previews are drawn from are still the real level's.
PROBE_SCREENS = 0x20

# How many objects one probe load may carry, and it is a **measured ceiling
# rather than a tuning choice**. The game's loader gets a fixed budget to reach
# a loaded level, and a level stuffed with objects runs past it: measured on
# level $105, batches of 16, 32, 48 and 64 objects all came back in about 200 ms
# with every object drawing, and 96 never finished loading at all.
#
# **One batch in flight, and the next asked for only when it lands.** The loader
# answers in order, so a queue of them would put seconds between an edit and its
# picture. Chained, the most an edit ever waits behind is one batch.
PROBE_BATCH = 48


class Thumb(NamedTuple):
    """A catalogue entry's picture, and where it sits against its own block.

    The offset comes along because the two are only useful together. The create
    panel's popup needs the picture alone, but the placement ghost has to put it
    where the record will be -- and a sprite's artwork does not start at the
    block its record names.

    Named rather than a bare triple because it is carried three ways -- rendered
    at a load, brought back by a catalogue probe, and by a sprite probe one row
    at a time -- and ``tuple`` in each of those signatures said nothing about
    which of the three numbers was which.
    """

    image: QImage
    dx: int
    dy: int


@dataclass(frozen=True)
class Held:
    """The level on the canvas, as the catalogue needs to see it.

    A read-only view of the window rather than a copy of it: everything here is
    already held somewhere in ``MainWindow``, and gathering it into one value is
    what lets this module take "the level as it now stands" as a single argument
    instead of six.

    ``rom`` is ``None`` when the image in hand is not a cartridge the base's
    offsets mean anything in -- a byte map, or a stub -- which is exactly when a
    probe cannot build the patches it would need. See ``MainWindow._addressable``
    for the test, which stays with the window because it is a fact about the
    file rather than about the catalogue.
    """

    level: int
    doc: Level
    snapshot: LevelSnapshot
    index: LevelIndex
    drawn: Mapping[int, frozenset[tuple[int, int]]]
    rom: bytes | None
    addresses: Addresses


def sprite_tilesets_of(where: Held) -> frozenset[int]:
    """The stock sprite tilesets whose evidence the level's sprites are judged
    by: the header's own, until the level carries a graphics row -- then
    whichever tilesets load exactly the four files the row leaves in SP1-SP4
    (:func:`~shiny_mushroom.catalog.tilesets_loading`), which may be none.
    The header's own again where the image cannot say what the row lays
    over: a stand-in cartridge, or a base without the lists."""
    own = frozenset({where.doc.sprite_tileset})
    if not where.doc.graphics or where.rom is None:
        return own
    try:
        lists = gfx_list_rows(where.rom, where=where.addresses)
    except ValueError:
        return own
    if lists is None:
        return own
    sprites, layers = lists
    if where.doc.sprite_tileset >= len(sprites) or where.doc.fg_bg_tileset >= len(
        layers
    ):
        return own
    files = where.doc.effective_graphics(
        sprite_row=sprites[where.doc.sprite_tileset],
        fgbg_row=layers[where.doc.fg_bg_tileset],
    )
    return tilesets_loading(files[LAYER_SLOTS:], sprites)


def as_image(found: Thumbnail) -> Thumb:
    """One rendered thumbnail, as something the canvas and the panel can use."""
    return Thumb(
        pixels_to_image(found.raster.pixels, found.width, found.height),
        found.dx,
        found.dy,
    )


def as_images(made: Mapping[CatalogKey, Thumbnail]) -> dict[CatalogKey, Thumb]:
    """A whole map of them, keyed as the catalogue keys them."""
    return {key: as_image(found) for key, found in made.items()}


def _sprite_thumbs(
    where: Held, art: Mapping[int, tuple[SpriteTile, ...]]
) -> dict[CatalogKey, Thumb]:
    """A picture of every sprite number one capture answered for.

    The one way a sprite row gets a picture, whether the capture came with the
    level or a hover asked for it: the two arrived at different times and drew
    from different things, and only one of them was passing the whole mapping.

    Drawn against **the level's own** VRAM, CGRAM and backdrop rather than the
    probe's, because that is what the sprite will stand in front of once placed
    -- and because the capture was taken under this level's header, which is
    what makes it the right artwork at all.

    Every number answers. A sprite with no artwork previews as the glyph the
    canvas draws for it, which is the same picture and not a second opinion
    about it.
    """
    return {
        (Stream.SPRITE, number, 0): as_image(
            sprite_preview(
                number,
                art,
                where.snapshot.vram,
                where.snapshot.cgram,
                where.snapshot.back_area_color,
            )
        )
        for number in art
    }


class Previews(QObject):
    """The create panel's contents, and what it takes to keep them true."""

    #: Asks for a scratch level holding a batch of the tileset's objects, so one
    #: load says what all of them draw. Once per tileset, and **after** the level
    #: is on screen -- see :meth:`probe`.
    catalog_requested = Signal(int, object)

    #: Asks for artwork for sprite numbers this level does not hold. A few at a
    #: time, driven by the pointer resting on a row.
    sprite_art_requested = Signal(object, int, object)

    def __init__(
        self,
        panel: CreateDock,
        held: Callable[[], Held | None],
        parent: QObject | None = None,
    ) -> None:
        super().__init__(parent)
        self._panel = panel
        self._held = held
        #: Every picture on offer, by catalogue key. Held here rather than only
        #: in the panel because it is filled from three places at different
        #: times and each of those adds to it.
        self.thumbs: dict[CatalogKey, Thumb] = {}
        #: Which tileset the object list on offer was built for. The same number
        #: is a different object in a different one, and this is what stops the
        #: list being rebuilt -- and the panel scrolled back to the top -- on
        #: every edit's refresh.
        self.tileset: int | None = None
        #: Which tilesets the object catalogue has already been probed for. The
        #: probe costs a level load, so its answer outlives a switch between two
        #: levels that share one -- and is forgotten with the pictures it
        #: produced when the tileset changes, see :meth:`offer`.
        self.asked: set[int | None] = set()
        #: Which sprite tileset those answers were about. A sprite thumb keys
        #: without it -- see `catalog.CatalogKey` -- so the pictures and the
        #: asked-about numbers go together when it changes, see :meth:`offer`.
        self.sprite_tileset: int | None = None
        #: Which sprite numbers have been asked about, whether or not the answer
        #: was anything. A probe is ~30 ms, and a number that drew nothing must
        #: not be re-asked every time the pointer passes over its row.
        self.asked_sprites: set[int] = set()
        #: What the batch in flight laid out where, and what is still queued
        #: behind it.
        self.layout: dict[int, CatalogKey] = {}
        self.queue: list[Entry] = []
        #: Which tileset the batch in flight was laid out for. A load takes long
        #: enough for the level under it to change, and an answer about another
        #: tileset's objects is an answer about different objects.
        self.probing: int | None = None
        #: What the pictures on offer were last drawn from -- see
        #: :meth:`redraw`, which is a no-op while it has not moved.
        self._drawn_from: object | None = None
        # The pointer has rested on a row with no picture yet. Only the sprites
        # can be answered on demand -- an object's shape needs the whole
        # catalogue probe, which has already been asked for by then.
        panel.wants_preview.connect(self._want_sprite)

    def thumb(self, key: CatalogKey) -> Thumb | None:
        """The picture on offer for ``key``, if one has been rendered."""
        return self.thumbs.get(key)

    def forget(self) -> None:
        """Drop everything: the pictures, and every record of having asked.

        What closing a cartridge means. They are *this* cartridge's graphics and
        this cartridge's object tables, and the next one's are not these -- so a
        picture kept across the change would be a picture of the wrong thing,
        and a tileset remembered as probed would keep the right one from ever
        being asked for.
        """
        self.thumbs = {}
        self.asked.clear()
        self.asked_sprites.clear()
        self.layout = {}
        self.probing = None
        self.queue = []
        self._drawn_from = None
        self.offer()

    # -- what the panel shows -----------------------------------------------

    def offer(self) -> None:
        """Put the level's own catalogue in the panel.

        **The object list is rebuilt only when the tileset changes.** It is the
        tileset's list -- the same number is a different object in a different
        one -- but every edit asks for a picture and every picture comes back
        through here, and rebuilding the panel's list per edit would scroll it
        back to the top under a hand that is placing a row of blocks.

        What *is* re-sent every time is which entries the level already holds,
        because placing the first Chuck in a level is exactly what makes that
        answer change. The panel drops it when nothing depends on it.
        """
        where = self._held()
        if where is None:
            self.tileset = None
            self.sprite_tileset = None
            self._panel.set_catalog({})
            # And the pictures, which are of a level that is no longer open. An
            # empty catalogue leaves no row to hover, but the panel is handed
            # the next cartridge's catalogue before its previews arrive -- so
            # stale ones here are reachable, and they are pictures of the wrong
            # graphics.
            self.redraw()
            return
        tileset = where.doc.fg_bg_tileset
        if tileset != self.tileset:
            self.tileset = tileset
            # The object pictures go with the old list. A catalogue key carries
            # no tileset -- see `catalog.CatalogKey` -- so the same number keyed
            # the same way is a different object here, and a picture kept across
            # the change would be a picture of that other one. Every tileset's
            # probe is forgotten with them, so the one being left behind is
            # asked again if it comes back.
            self.thumbs = {
                key: thumb
                for key, thumb in self.thumbs.items()
                if key[0] is not Stream.OBJECT
            }
            self.asked.clear()
            self._panel.set_catalog(
                {
                    Stream.OBJECT: object_entries(tileset),
                    Stream.SPRITE: sprite_entries(),
                }
            )
        sprite_tileset = where.doc.sprite_tileset
        if sprite_tileset != self.sprite_tileset:
            self.sprite_tileset = sprite_tileset
            # The sprite pictures are that tileset's for the same reason, keyed
            # the same keyless way -- and the numbers remembered as asked were
            # asked about the other tileset's artwork, so hovering them again
            # must be a fresh question.
            self.thumbs = {
                key: thumb
                for key, thumb in self.thumbs.items()
                if key[0] is not Stream.SPRITE
            }
            self.asked_sprites.clear()
        self._panel.set_used(
            {key_of(record) for record in (*where.doc.objects, *where.doc.sprites)}
        )
        # And whether each one's graphics are loaded where it would be placed.
        # Keyed on the level's **sprite** tileset, which is a different header
        # field from the one that chose the objects above -- or, for a level
        # with a graphics row of its own, on whichever stock tilesets load
        # the four files the row leaves in SP1-SP4 -- see
        # `catalog.art_verdict_under`. The evidence is the cartridge index,
        # which was built when the ROM was opened and costs nothing to
        # consult.
        tilesets = sprite_tilesets_of(where)
        self._panel.set_art(
            {
                entry.key: art_verdict_under(
                    entry, tilesets, where.index.shipped_under(entry.number)
                )
                for entry in self._panel.catalog(Stream.SPRITE)
            }
        )
        self.redraw()

    def redraw(self) -> None:
        """Render a picture of every catalogue entry the level can answer for.

        **Built at the load rather than at the hover**, because the memories a
        preview is drawn from are the ones that just arrived and drawing a few
        dozen small rasters out of them is arithmetic -- the
        :class:`~shiny_mushroom.level.Blocks` caches are shared across the whole
        catalogue, so a tile decoded for one entry is not decoded again for the
        next. Doing it per hover would repeat that work for as long as the
        pointer moved.

        **What can be answered for is what the level already contains**, and
        that is a real bound rather than an oversight. A sprite's artwork is a
        capture of its own drawing code and only the numbers *in this level*
        were captured; an object's shape is what the loader was traced drawing
        and only the objects in this level were traced. Everything else in the
        catalogue needs the emulator asked again, which is a round trip and does
        not belong on the path a level load is already waiting on -- see
        `docs/editor/creating.md`.

        So an entry the level does not use has no picture yet, and the panel
        shows no popup for it rather than an empty frame.

        **And an entry the level uses at another size has no picture from it.**
        A preview is what a placement produces -- it is what the panel's popup
        shows and what the canvas's ghost paints under the pointer -- so it may
        only be drawn from a record placed the way a click would place one:
        :func:`~shiny_mushroom.catalog.drawn_as_placed`. The level's coins are as
        likely to be a row of six as the single block a fresh one is, and the
        two are one entry. The probe places each entry exactly as a click does
        and answers for those.

        **Nothing is drawn again while nothing it was drawn from has moved.**
        This is on the path of every commit and every edit's refresh, twice per
        edit, and rendering a level's worth of thumbnails is ~11 ms -- so what
        the pictures are a function of is compared first, and an ordinary object
        edit gets no further. That is the memories they were decoded out of, the
        tileset that says which object each entry is, and each entry's footprint
        **measured from its own block**: an object dragged across the level
        draws the same shape at a new anchor, which is the same picture and the
        one case a raw comparison of the footprints would redraw for.
        """
        where = self._held()
        if where is None:
            self.thumbs = {}
            self._drawn_from = None
            self._panel.set_previews({})
            return
        # Objects, from what the loader was observed drawing -- and only from
        # the ones a click would have produced. Keyed straight to the
        # catalogue's own key, so two records of the same object share one
        # picture and the first one that drew anything is the one kept.
        footprints: dict[
            CatalogKey,
            tuple[tuple[int, int], frozenset[tuple[int, int]]],
        ] = {}
        for obj in where.doc.objects:
            blocks = where.drawn.get(obj.uid)
            if not blocks or not drawn_as_placed(obj, where.doc.fg_bg_tileset):
                continue
            if key_of(obj) not in footprints:
                footprints[key_of(obj)] = ((obj.column, obj.row), blocks)
        drawn_from = (
            where.snapshot.vram,
            where.snapshot.cgram,
            where.snapshot.back_area_color,
            where.snapshot.map16_defs,
            where.snapshot.pipe_definitions,
            where.snapshot.vertical,
            where.snapshot.sprite_art,
            where.doc.fg_bg_tileset,
            {
                key: frozenset(
                    (column - anchor[0], row - anchor[1]) for column, row in blocks
                )
                for key, (anchor, blocks) in footprints.items()
            },
        )
        if drawn_from == self._drawn_from:
            return
        self._drawn_from = drawn_from
        made = as_images(previews_from(where.snapshot, footprints))
        # Sprites, from the artwork captured for this level's own numbers. Every
        # one of them answers -- a sprite with no artwork previews as the glyph
        # the canvas draws for it, which is the same picture and not a second
        # opinion about it.
        made |= _sprite_thumbs(where, where.snapshot.sprite_art)
        # Anything a probe already brought back for this level survives, so a
        # refresh after an edit does not throw away the catalogue's pictures and
        # ask for them all again -- but what has just been rendered wins, because
        # it was drawn from the memories the level is showing now.
        self.thumbs = self.thumbs | made
        self._panel.set_previews(
            {key: found.image for key, found in self.thumbs.items()}
        )

    def _add(self, made: Mapping[CatalogKey, Thumb]) -> None:
        """Put newly rendered pictures beside the ones already on offer.

        Added rather than replacing, because they arrive from three places at
        different times -- the level's own records at load, the object catalogue
        a round trip later, and a sprite whenever the pointer rests on one.
        """
        if not made:
            return
        self.thumbs.update(made)
        self._panel.set_previews(
            {key: found.image for key, found in self.thumbs.items()},
            keep_showing=True,
        )

    # -- probing the object catalogue ---------------------------------------

    def probe(self) -> None:
        """Start finding out what every object in this tileset draws.

        What an object draws is the game's own work and costs a level load to
        learn; laying a batch of them out on a grid in one scratch level makes
        that one load answer for all of them at once -- measured at ~200 ms for
        a batch of 48, against about a minute if each were asked for alone.

        **After the level is on screen, never before it.** Nobody is waiting on a
        thumbnail. Once per tileset, too, because the answer is the tileset's:
        switching between two levels that share one costs nothing.

        See :data:`PROBE_BATCH` for why this is batched at all and why the
        batches are chained rather than queued.
        """
        where = self._held()
        if where is None or where.rom is None:
            return
        if self.tileset in self.asked:
            return
        entries = self._panel.catalog(Stream.OBJECT)
        if not entries:
            return
        self.asked.add(self.tileset)
        # **Everything but the fourteen the game cannot dispatch.** Extended
        # objects $02-$0F are null pointers in the cartridge's own table, so a
        # probe carrying one does not come back with a picture -- it takes the
        # machine to bank zero, and the batch costs three failed load attempts
        # and yields nothing. They are excluded by name rather than by kind
        # because they are the only members: with them out, all 304 entries of a
        # tileset draw, in seven batches and about a second and a half, on every
        # tileset tried. See `objects.CRASHING_EXTENDED` and
        # `docs/editor/creating.md`.
        self.queue = [
            entry
            for entry in entries
            if not crashes_the_loader(entry.number, entry.settings)
        ]
        self.send_batch()

    def send_batch(self) -> None:
        """Ask for the next batch of objects, if there are any left.

        The stream replaces the level's own through the same
        :func:`~shiny_mushroom.rom_patches.level_patch` seam an edit uses, and the
        header's screen count goes up with it -- a one-screen level has six
        cells and a batch needs forty-eight. Nothing on disk is touched, and the
        canvas never sees the result: it comes back on a signal of its own.
        """
        where = self._held()
        if where is None or where.rom is None:
            return
        batch, self.queue = self.queue[:PROBE_BATCH], self.queue[PROBE_BATCH:]
        if not batch:
            self.layout = {}
            self.probing = None
            return
        self.probing = self.tileset
        # The widest shape the format can express, so the grid has room. The
        # tileset nibble is untouched, so the graphics and the Map16 definitions
        # are still this level's -- which is what makes the previews right.
        header = bytes([(where.doc.header[0] & 0xE0) | (PROBE_SCREENS - 1)])
        header += where.doc.header[1:]
        shape = level_shape(
            screen_count=PROBE_SCREENS,
            vertical=where.doc.shape.vertical,
            layer2_background=where.snapshot.layer2_background,
        )
        stream, self.layout = probe_stream(batch, shape)
        if not self.layout:
            # Nothing in this batch has a position -- all commands. Skip it
            # rather than spending a load learning that they draw nothing.
            self.send_batch()
            return
        try:
            patches = level_patch(
                where.rom,
                where.level,
                header,
                stream,
                where.doc.streams()[1],
                where=where.addresses,
            )
        except (ValueError, IndexError) as error:
            # A cartridge with nowhere to put a stream this long, or one whose
            # tables this cannot follow. The previews are an aid; the level is
            # open and working either way.
            _log.debug("no object catalogue previews: %s", error)
            self.queue = []
            self.layout = {}
            return
        self.catalog_requested.emit(where.level, patches)

    def probed(self, snapshot: LevelSnapshot | None) -> None:
        """A batch came back: turn its footprints into pictures, then ask for
        the next.

        Pairs the loader's footprints against a **fresh parse of the stream that
        was sent**, not against the document -- the document is the real level's
        and has nothing to do with the scratch one. The offsets the encoder's
        own jumps land on are absent from the layout, which is what tells an
        invented record from an asked-for one.

        ``None`` is a batch that failed. The next one is still asked for: a
        cycle budget blown by one awkward object says nothing about the rest of
        the catalogue, and stopping there would lose every picture after it.

        So is a batch that was laid out for a **tileset no longer in front of
        us**: the level changed under a load that was already out, and the same
        number is a different object here. Its pictures are dropped and the
        queue -- which is this tileset's by then -- carries on.
        """
        layout, self.layout = self.layout, {}
        stale = self.probing != self.tileset
        if snapshot is not None and layout and self._held() is not None and not stale:
            self._add(_from_probe(snapshot, layout))
        self.send_batch()

    # -- probing one sprite at a time ---------------------------------------

    def _want_sprite(self, entry: Entry) -> None:
        """The pointer has rested on a sprite row with no picture yet.

        **One number at a time and never twice.** Each is a savestate restore
        and three traced calls -- ~30 ms -- so the catalogue is not probed
        ahead of time and a row already asked about is not asked again, whether
        or not the answer was anything. The panel's own rest delay is what keeps
        a sweep down the list from queueing two hundred of these.

        Remembering a number as asked is safe because a level being held means
        there is a loader to ask: the window drops the level and the loader
        together, so there is no state in which the request goes out to nobody
        and the number is never probed again.
        """
        where = self._held()
        if where is None:
            return
        if entry.stream is not Stream.SPRITE or entry.number in self.asked_sprites:
            return
        self.asked_sprites.add(entry.number)
        self.sprite_art_requested.emit([entry.number], where.level, where.doc.header)

    def sprite_art(self, art: Mapping[int, tuple[SpriteTile, ...]]) -> None:
        """Artwork for hovered sprites came back: draw it and put it in the
        panel.

        A number that came back with nothing is remembered as having been asked
        for, so the pointer passing over it again does not queue the same probe.

        **The whole batch draws every picture in it**, rather than each number
        being drawn from its own entry alone. A capture answers for more numbers
        than were asked for -- a hidden sprite drags in the form it turns into --
        and an invisible mushroom drawn from an entry holding only itself has
        nothing to stipple. See
        :func:`~shiny_mushroom.emu.sprite_probe.with_revealed_forms`.
        """
        where = self._held()
        if where is None:
            return
        self.asked_sprites |= set(art)
        self._add(_sprite_thumbs(where, art))


def _from_probe(
    snapshot: LevelSnapshot, layout: dict[int, CatalogKey]
) -> dict[CatalogKey, Thumb]:
    """Every picture one probe load produced, keyed as the catalogue keys it."""
    shape = geometry(snapshot)
    footprints: dict[
        CatalogKey,
        tuple[tuple[int, int], frozenset[tuple[int, int]]],
    ] = {}
    for parsed, cells in zip(
        parse_objects(snapshot.objects, shape), snapshot.footprints, strict=False
    ):
        key = layout.get(parsed.offset)
        if key is None:
            continue
        blocks = frozenset(
            block
            for block in (shape.block_at(cell) for cell in cells)
            if block is not None
        )
        if blocks:
            footprints[key] = ((parsed.column, parsed.row), blocks)
    return as_images(previews_from(snapshot, footprints))
