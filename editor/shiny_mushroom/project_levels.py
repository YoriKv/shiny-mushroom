"""The levels a project holds: its containers, its pointer tables, and the
room they have to fit.

One of :class:`~shiny_mushroom.project.Project`'s subjects, in a module of
its own -- what a level's streams are read out of and written back into,
where the three pointer tables send each level number, the containers a
project adds and deletes, and the arithmetic that says whether a save fits
the runs of ROM the build assembles it into. Its two refusals
(:class:`LevelRegionFull`, :class:`LevelBanksFull`), its one unloadable pair
(:class:`Layer2Gap`) and the empty streams a deletion leaves behind are here
beside the methods that raise and write them.

**A mixin rather than a view**, for the reason
:mod:`shiny_mushroom.project_graphics` gives: every caller still asks the
project, and ``self`` is that project.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

from shiny_mushroom import level_graphics, level_palettes, mwl
from shiny_mushroom.header import HEADER_SIZE, field_value, needs_layer2_data
from shiny_mushroom.hexnum import hexnum
from shiny_mushroom.layer2_table import Layer2Entry, Layer2Table
from shiny_mushroom.layer2_table import choices as layer2_table_choices
from shiny_mushroom.level_pointers import (
    ADDED_LAYER1_PREFIX,
    ADDED_NAME,
    ADDED_SPRITE_PREFIX,
    BANKS_FRAGMENT,
    DELETIONS_FRAGMENT,
    STREAMS_FRAGMENT,
    PointerTable,
    StreamTarget,
    added_insertions,
    added_labels,
    deleted_fragment,
    sprite_banks_fragment,
    streams_fragment,
)
from shiny_mushroom.mwl import MwlError, layer2_payload, read_level, write_level
from shiny_mushroom.project_files import (
    RAW_NAME,
    ProjectError,
    _capture,
    _now,
    _restore,
    _string_list,
    _write_atomic,
)
from shiny_mushroom.secondary_header import REGION_IDS as SECONDARY_REGIONS
from shiny_mushroom.secondary_header import SIZE as SECONDARY_SIZE
from smw_tools import asm_codec, asm_room, packed
from smw_tools.bases import base as rom_base
from smw_tools.features import LEVEL_CUSTOM_PALETTES, applied
from smw_tools.levels import (
    EMPTY_STREAM_SIZES,
    LAYER1_TABLE,
    LAYER2_TABLE,
    LAYER_1,
    LAYER_2,
    LEVEL_COUNT,
    LEVELS_DIR,
    NAMESPACE,
    SPRITE_TABLE,
    SPRITES,
    LevelFile,
    LevelRegion,
    LevelRun,
    Packing,
    background_definitions,
    containers,
    definitions,
    is_managed,
    layer2_container,
    level_bank_run,
    managed_regions,
    pack,
    place,
    regions_holding,
    runs_for,
    stock_stream_sizes,
    stream_definitions,
    stream_size,
    undecorated,
)
from smw_tools.rle import CorruptStream, Variant, decompress
from smw_tools.rom_sizes import ROM_SIZES

if TYPE_CHECKING:
    from collections.abc import Iterable, Sequence

    from smw_tools.bases import RomBase


class LevelRegionFull(ProjectError):
    """A level's streams no longer fit the run of ROM they are assembled into.

    The level counterpart of :class:`smw_tools.packed.RegionFull`, and a
    :class:`ProjectError` because the window's save path already reports one of
    those -- an overflowing edit is a refused save, not a broken project.
    """

    def __init__(self, region: LevelRegion, over: int) -> None:
        self.region = region
        #: How many bytes have to come back out before the region fits.
        self.over = over
        where = (
            ""
            if region.span is None
            else f" ({hexnum(region.start, 6)}, {region.span:,} bytes)"
        )
        super().__init__(
            f"{region.name}{where} is full: this save needs {over:,} bytes "
            f"more than it has. Take {over:,} bytes out of one of the "
            f"{len(region.insertions)} streams in it."
        )


class LevelBanksFull(ProjectError):
    """The level streams no longer fit the managed level banks end to end.

    :class:`LevelRegionFull`'s counterpart for a cartridge whose level banks
    are packed (:func:`smw_tools.levels.pack`): there is one budget -- the
    two banks, and the level bank behind them where the level memory is
    expanded -- and what will not fit is whatever the packer had to leave
    out.
    """

    def __init__(self, packing: Packing) -> None:
        self.packing = packing
        #: How many bytes have to come back out before everything fits.
        self.over = packing.over
        first, _size = packing.unplaced[0]
        super().__init__(
            f"the level banks are full: this save needs {self.over:,} bytes "
            f"more than the level runs hold end to end, and the first "
            f"stream left out is {first.label or first.container}. Take "
            f"{self.over:,} bytes out of a level."
        )


@dataclass(frozen=True)
class Layer2Gap:
    """A remap the game could not load: a Layer 2 level under a number whose
    Layer 2 entry is a background image.

    Twenty-six of the tree's containers carry a header whose level mode makes
    the loader walk Layer 2 as an object stream, and most level numbers have
    nothing there for it to walk. The two tables are edited from different
    places -- Layer 1 and sprites from the remap dialog, Layer 2 from the
    header dialog -- so neither edit can see the other going wrong, and the
    combination is a hang rather than a mistake you can look at.

    Carried as facts with the sentences over them, so the two refusals and
    the dialogs that should have prevented them cannot word it differently.
    """

    #: The level number, and the container its Layer 1 comes from.
    level: int
    container: str

    #: The container header's level mode, which is what asks for a stream.
    mode: int

    #: What the level's Layer 2 entry names instead --
    #: :attr:`~shiny_mushroom.layer2_table.Layer2Entry.name`, so ``Clouds``.
    background: str

    @property
    def reason(self) -> str:
        """What is wrong with the pair, without saying which half to move.

        The pair can be arrived at from either side -- a Layer 1 remap, or a
        Layer 2 repoint -- and the way out is whichever half the edit in hand
        is not, so the remedy is the caller's sentence and this is the part
        they share.
        """
        return (
            f"Level {hexnum(self.level, 3)} would read {self.container}.mwl, "
            f"whose header names level mode {hexnum(self.mode)} -- a Layer 2 "
            f"level -- with the {self.background} background as its Layer 2. "
            f"The game would read that background as objects and never finish "
            f"loading."
        )

    @property
    def refusing_a_remap(self) -> str:
        """What a Layer 1 remap is told: the Layer 2 entry is the half that
        can move, because the container's header is not that edit's to
        change."""
        return (
            f"{self.reason} Point {hexnum(self.level, 3)}'s Layer 2 at a "
            f"Layer 2 stream first."
        )

    @property
    def refusing_a_repoint(self) -> str:
        """What a Layer 2 repoint is told: this edit *is* the Layer 2 half, so
        what can move is the level's own header or its Layer 1 entry."""
        return (
            f"{self.reason} Give {self.container}.mwl a level mode that reads "
            f"Layer 2 as a background, or point {hexnum(self.level, 3)}'s "
            f"Layer 1 at a level that does not need a stream."
        )


#: Which region of a container each of the framework's stream names is. The two
#: modules number them the same way, but nothing makes them: one is the
#: assembler's spelling and the other is the container's table order.
_SLOTS = {LAYER_1: mwl.LAYER1, LAYER_2: mwl.LAYER2, SPRITES: mwl.SPRITES}

#: The empty level, as the build inserts it for a deleted stream and as
#: :func:`shiny_mushroom.mwl.blank_container` starts a new one: a zeroed
#: header and the terminator, and a zero sprite header and the terminator.
#: Their lengths are :data:`smw_tools.levels.EMPTY_STREAM_SIZES`.
EMPTY_LAYER1 = bytes(5) + b"\xff"
EMPTY_SPRITES = b"\x00\xff"


def _payload_size(container: Path, slot: int) -> int:
    """How many bytes one region of ``container`` contributes to the ROM.

    What the insertion macro ``incbin``\\ s, which is the region past the eight
    bytes belonging to the container itself -- so this is the number the region
    it lands in has to find room for.
    """
    return len(mwl.Container.read(container.read_bytes()).payload(slot))


class LevelFiles:
    """A project's levels: the containers, the pointer tables that send each
    number at one, and what a save of one has to fit.

    Mixed into :class:`~shiny_mushroom.project.Project`, whose overlay,
    metadata and asm-region group every method here goes through -- ``self``
    is that project.
    """

    # -- levels -------------------------------------------------------------

    def level_streams(self, level: int) -> tuple[bytes, bytes] | None:
        """Level ``level`` as ``(header + objects, sprites)``, or ``None`` if the
        tree does not place it.

        Read through :meth:`source`, so an edited level reads back as the edit
        rather than as the disassembly's original -- which is what makes closing
        and reopening a level show the work.
        """
        where = self.level_file(level)
        if where is None:
            return None
        deleted = set(self.deleted_level_labels())
        layer1_label, sprite_label = self.level_labels(level)
        layer1, sprites = EMPTY_LAYER1, EMPTY_SPRITES
        # A deleted label's stream is the empty level the build inserts under
        # it -- what the number loads as, not what the file holds.
        if layer1_label not in deleted:
            layer1, _ = read_level(self.source(where.layer1).read_bytes())
        if sprite_label not in deleted:
            _, sprites = read_level(self.source(where.sprites).read_bytes())
        return layer1, sprites

    def level_labels(self, level: int) -> tuple[str, str]:
        """The labels ``level``'s Layer 1 and sprite entries name, spelled as
        the definitions are -- the keys of :meth:`deleted_level_labels`."""
        return (
            undecorated(self._pointer_table(LAYER1_TABLE).label(level)),
            undecorated(self._pointer_table(SPRITE_TABLE).label(level)),
        )

    def layer2_file(self, level: int) -> Path | None:
        """The container holding ``level``'s Layer 2 object stream, or ``None``.

        ``None`` for the great majority of levels, whose Layer 2 is a
        background and has no container region behind it -- and for a tree
        pointing at a Layer 2 label no bank defines, which is a stream that
        cannot be written anywhere.

        Not part of :class:`~smw_tools.levels.LevelFile`, deliberately: Layer 2
        is reached through a pointer table of its own, is often a *third*
        container -- eight levels read the Layer 2 in level ``$0C4``'s while
        taking their own Layer 1 from elsewhere -- and is shared by a set of
        levels that is not the one sharing Layer 1.
        """
        entry = self.layer2_table().entry(level)
        if entry.background:
            return None
        return layer2_container(entry.label, self.base, self.target)

    def layer2_stream(self, level: int) -> tuple[bytes, bytes] | None:
        """``level``'s Layer 2 as ``(its five header bytes, its object stream)``,
        or ``None`` when it has none -- a background, or a stream the tree does
        not place.

        Read through :meth:`source` like :meth:`level_streams`, so an edited
        Layer 2 reads back as the edit.
        """
        where = self.layer2_file(level)
        if where is None:
            return None
        entry = self.layer2_table().entry(level)
        if undecorated(entry.label) in self.deleted_level_labels():
            # The label inserts the empty level: a zeroed header and the
            # terminator, exactly as a deleted Layer 1 loads.
            return EMPTY_LAYER1[:HEADER_SIZE], EMPTY_LAYER1[HEADER_SIZE:]
        payload = layer2_payload(self.source(where).read_bytes())
        return payload[:HEADER_SIZE], payload[HEADER_SIZE:]

    def levels_sharing_layer2(self, level: int) -> tuple[int, ...]:
        """The other level numbers a save of ``level``'s Layer 2 would move.

        The Layer 2 pointer table's own answer, which is not
        :meth:`also_changes`': eight numbers read the Layer 2 that level
        ``$0C4``'s container holds, and only one of them shares its Layer 1.
        """
        table = self.layer2_table()
        entry = table.entry(level)
        if entry.background:
            return ()
        return tuple(other for other in table.levels_pointing(entry) if other != level)

    def background_key(self, rom: bytes, offset: int) -> Path | None:
        """Which Layer 2 background file the stream at ``offset`` of ``rom``
        is, as its raw-overlay key -- or ``None`` when no file matches.

        A background has no name in the cartridge, only a position -- see
        :func:`~shiny_mushroom.rom_patches.layer2_background_base` -- so the file
        is identified by its bytes: the image's stream is compared against
        each background as the build would write it, the overlay's re-encoding
        where this project has edited one and the shipped file otherwise. The
        17 shipped files are all distinct, so a match is an answer; ``None``
        means the cartridge's backgrounds are not this project's -- a hack
        that re-arranged bank ``$0C`` -- and an edit there has nowhere to be
        filed.
        """
        for key, resource in self._base_resources().items():
            if resource.region != packed.BACKGROUNDS:
                continue
            baseline = resource.baseline_path(self.base, self.assets_base).read_bytes()
            candidates = [baseline]
            if (self.overlay / RAW_NAME / key).is_file():
                candidates.append(resource.encode(self.raw(key), baseline))
            for candidate in candidates:
                if candidate and rom[offset : offset + len(candidate)] == candidate:
                    return key
        return None

    def save_level(
        self,
        level: int,
        layer1: bytes,
        sprites: bytes,
        background: tuple[Path, bytes] | None = None,
        layer2: tuple[bytes, bytes] | None = None,
        secondary: bytes | None = None,
        asm_runs: dict[str, asm_room.Run] | None = None,
        graphics: bytes | None = None,
    ) -> list[Path]:
        """Write level ``level`` into the overlay, and say which files moved.

        ``layer1`` is the five header bytes and the object stream, because that
        is one region of the container and the header is not separable from it.

        **Usually one file and sometimes two.** A level's two streams can come
        out of different containers -- forty-five of them do, which is how the
        cart gives one boss room several sets of enemies -- and each is rewritten
        where it actually lives. Every other region of both containers is copied
        through untouched, so what is saved is a level edit and not a rewritten
        file.

        Each container is rewritten from **the version the build would read**, so
        saving twice edits the first save rather than the stock level.

        **The room it has is checked before the save stands.** A level's streams
        are concatenated with every other level in their region and the run is
        packed to the byte (:meth:`level_room`), so an edit that grows past the
        end does not fail here -- it fails half a minute later inside asar, with
        a message about an address rather than about the level that was edited.
        Refusing it now, with the number of bytes, is the difference between an
        edit that will not fit and a project that will not build.

        ``background`` is the level's Layer 2 background where that was edited
        too -- its raw-overlay key (:meth:`background_key`) and the pattern's
        raw bytes -- saved through :meth:`save_raw` as one decision with the
        streams: a background the region refuses rolls the containers back, so
        a partial save is never left standing.

        ``layer2`` is the other kind of Layer 2 -- the object stream, for the
        levels whose pointer names one -- as its five header bytes and its
        records, and it can make the save a **third** file: the stream lives in
        whichever container :meth:`layer2_file` names, which for eight levels
        is one they take nothing else from. Rolled back with the rest, priced
        with the rest, and shared with a set of levels that is not Layer 1's --
        :meth:`levels_sharing_layer2` is what says which.

        ``secondary`` is the level's four secondary-header bytes, saved
        through the ``levels.secondary_header_*`` asm regions rather than
        into the container -- the tables live in bank ``$05``, not next to
        the level data. Passed whenever the document carries them, exactly
        as ``layer2`` is: a byte-identical row is not an edit, and a table
        put back to the disassembly's own reverts its fragment. A change
        needs ``asm_runs`` (:func:`shiny_mushroom.build.asm_runs`) to price
        against, like any region save; the fragments are emitted -- and so
        priced and refused -- before anything else is written, so a refusal
        here leaves the overlay untouched.

        ``graphics`` is the level's own graphics row -- the eight bytes the
        ``level-graphics`` feature reads for the level
        (:mod:`shiny_mushroom.level_graphics`) -- written into the Layer 1
        container's ExGFX words in the same rewrite as the streams
        (:meth:`~shiny_mushroom.mwl.Container.with_graphics_row`). A row
        that names nothing -- empty, or ``$FF`` in every slot -- writes the
        tileset's into every word, and ``None`` leaves the words alone. The
        row is the *container's*, so a level sharing its container with
        others shares the row with them, as :meth:`also_changes` says.
        """
        if graphics is not None:
            graphics = (
                level_graphics.INHERIT_ROW
                if level_graphics.is_inherit(graphics)
                else level_graphics.check(graphics)
            )
        emitted: list[tuple[asm_codec.AsmRegion, dict[Path, str] | None]] = []
        if secondary is not None:
            emitted = self._emit_secondary(level, secondary, asm_runs or {})
        where = self.level_file(level)
        if where is None:
            raise ProjectError(
                f"the disassembly does not place level {hexnum(level, 3)}"
            )
        gone = sorted(set(self.level_labels(level)) & set(self.deleted_level_labels()))
        if gone:
            raise ProjectError(
                f"level {hexnum(level, 3)} reads {', '.join(gone)}, which this "
                f"project has deleted -- restore the label in Level Data first"
            )
        layer2_path = None if layer2 is None else self.layer2_file(level)
        if layer2 is not None and layer2_path is None:
            raise ProjectError(
                f"the disassembly does not place level {hexnum(level, 3)}'s Layer 2"
            )
        # Its own container as a rule, and the same one over again for a level
        # like $009 whose Layer 2 sits beside its Layer 1 -- so the paths are
        # merged before anything is written. Writing the file twice would
        # rebuild the second copy from the stock container and lose the first.
        paths = list(where.paths)
        if layer2_path is not None and layer2_path not in paths:
            paths.append(layer2_path)
        written = []
        # Captured before the first write, so a refused save puts back exactly
        # what was there -- the same rule `_save_raws` keeps for a full region.
        held = _capture(self.overlaid(path) for path in paths)
        for path in paths:
            container = self.source(path).read_bytes()
            held_layer1, held_sprites = read_level(container)
            rebuilt = write_level(
                container,
                layer1 if path == where.layer1 else held_layer1,
                sprites if path == where.sprites else held_sprites,
                None if path != layer2_path else layer2[0] + layer2[1],
                graphics if path == where.layer1 else None,
            )
            destination = self.overlaid(path)
            destination.parent.mkdir(parents=True, exist_ok=True)
            _write_atomic(destination, rebuilt)
            written.append(destination)

        # Asked of the written overlay rather than of the streams in hand, so
        # what is measured is what the build will read -- and so that a level
        # sharing a region with one edited earlier is priced against that edit
        # and not against the cartridge. On managed level banks the budget is
        # the two banks and the packer is the judge; a save into the
        # roll-call routine's region is still its own run either way.
        for region in self.level_regions_for(level):
            if self.level_memory_managed and region in managed_regions(
                self.base, self.target
            ):
                continue
            room = self.level_room(region)
            if room < 0:
                _restore(held)
                raise LevelRegionFull(region, -room)
        if self.level_memory_managed:
            packing = self.level_packing()
            if not packing.fits:
                _restore(held)
                raise LevelBanksFull(packing)

        if background is not None:
            key, raw = background
            try:
                written.append(self.save_raw(key, raw))
            except (packed.PackedError, OSError):
                # `save_raw` has already restored its own file; the containers
                # written above go back too, or half the level would be saved.
                _restore(held)
                raise

        # Priced at the top, so by here the write cannot refuse -- the same
        # order `save_world_map` keeps for its own fragments.
        written.extend(self._write_asm_regions(emitted))
        self._write_metadata({"modified": _now()})
        return written

    def secondary_header(self, level: int) -> bytes:
        """``level``'s four secondary-header bytes, as the build would read
        them: one from each ``levels.secondary_header_*`` region, the
        overlay's rows where this project has saved them."""
        return bytes(
            self.asm_rows(region_id)[0][level] for region_id in SECONDARY_REGIONS
        )

    def _emit_secondary(
        self,
        level: int,
        secondary: bytes,
        runs: dict[str, asm_room.Run],
    ) -> list[tuple[asm_codec.AsmRegion, dict[Path, str] | None]]:
        """Price ``level``'s secondary-header bytes as region fragments.

        Only the tables whose row actually changes are emitted -- the other
        overlays stay exactly as they are -- and a table whose rows come back
        to the disassembly's own is a revert, decided by
        :meth:`_emit_asm_regions` as for any region. Pure, like the pricing
        it delegates to.
        """
        if len(secondary) != SECONDARY_SIZE:
            raise ProjectError(
                f"a secondary header is {SECONDARY_SIZE} bytes, not {len(secondary)}"
            )
        models: dict[str, object] = {}
        for region_id, value in zip(SECONDARY_REGIONS, secondary, strict=True):
            rows = list(self.asm_rows(region_id)[0])
            if rows[level] == value:
                continue
            rows[level] = value
            models[region_id] = (tuple(rows),)
        if not models:
            return []
        return self._emit_asm_regions(
            models, {found: runs[found] for found in models if found in runs}
        )

    def level_room(self, region: LevelRegion) -> int:
        """How many bytes ``region`` still has spare: negative when it overflows.

        **Measured as a delta, not as a total.** The budget is what the region
        holds today -- ``RomMap/`` places every macro at a literal address and
        the gaps between them are taken up by explicit freespace, so each run is
        packed to the byte against the next thing along and the stock total *is*
        the limit. What is left is therefore the sum of what the overlay has
        added, negated, and the only files that have to be read are the ones
        this project has edited.

        That is what makes this cheap enough to ask on every save: the largest
        region concatenates 189 streams, and asking it what it holds would mean
        opening 189 containers to find out something the checkout could have
        been asked once. An untouched stream contributes nothing to a
        difference.

        Which containers are edited is **one directory read**, not a `stat` per
        insertion. The difference is the same one
        :meth:`region_usage` measures for the packed regions and does not have
        the option of avoiding: 189 `stat` calls on a project whose checkout is
        on a mounted drive is most of a second, and this is on the path of every
        save.
        """
        edited = self._edited_containers()
        deleted = set(self.deleted_level_labels())
        grown = 0
        for insertion in region.insertions:
            stock = self.base / LEVELS_DIR / f"{insertion.container}.mwl"
            slot = _SLOTS[insertion.kind]
            if insertion.label in deleted:
                # The empty level stands in for the stream, on a stock build
                # as on a managed one.
                grown += EMPTY_STREAM_SIZES[insertion.kind] - _payload_size(stock, slot)
            elif insertion.container in edited:
                grown += _payload_size(
                    edited[insertion.container], slot
                ) - _payload_size(stock, slot)
        return -grown

    @property
    def level_memory_managed(self) -> bool:
        """Whether this project's **next build** packs its level banks --
        the ``managed-level-memory`` feature, switched on here or built into
        the base.

        The next build rather than the cartridge on disk, because a save is
        priced against the build it will be assembled by: a project that has
        just thrown the switch is already writing levels the packer will
        place, and one that has just cleared it is writing levels the stock
        runs have to hold.
        """
        return is_managed(self.next_base)

    @property
    def next_base(self) -> RomBase:
        """The cartridge this project's **next build** makes: the base with
        every feature :attr:`feature_state` asks for applied, at the size the
        project builds. What a save is priced against, for the reason
        :attr:`level_memory_managed` gives -- and the size is part of it,
        because the packing overflows into an expansion bank only where the
        cartridge has one (:func:`smw_tools.levels.has_level_bank`)."""
        return applied(rom_base(self.base_id), self.feature_state, self.rom_size_id)

    def levels_refuse_size(self, rom_size_id: str) -> str:
        """Why this project's saved levels could not be built into a cartridge
        of ``rom_size_id``, or ``""`` where they could.

        The one resize that takes room away. Growable levels overflow into an
        expansion bank where the cartridge has one
        (:func:`smw_tools.levels.has_level_bank`), so shrinking past it hands
        the packer fewer runs than the streams need -- which the build would
        refuse with a `warnpc`, too late to do anything about. Priced here
        against the cartridge being *asked for*, exactly as a feature switch
        is priced against the cartridge it would make.

        Nothing to say on a project whose level banks are stock: the seven
        macros are placed at literal addresses and hold what they held at
        every size.
        """
        if rom_size_id == self.rom_size_id or not self.level_memory_managed:
            return ""
        base = applied(rom_base(self.base_id), self.feature_state, rom_size_id)
        try:
            packing = self.level_packing(base)
        except (ProjectError, OSError, ValueError):
            return ""
        if packing.fits:
            return ""
        return (
            f"The saved levels need {packing.over:,} bytes more than a "
            f"{ROM_SIZES[rom_size_id].label} cartridge holds: growable levels "
            f"overflow into an expansion bank this one has not got. Take that "
            f"much back out of the levels first."
        )

    def level_palette_bytes(self, count: int | None = None) -> int:
        """How many bytes of the level bank the custom level palettes take
        on this project's next build: their fixed head and a blob per
        dressed level -- ``count`` of them, or the saved ones. What the
        packer's fourth run opens behind
        (:func:`smw_tools.levels.level_bank_run`).

        Zero only where there is nothing to keep room for: the feature off
        **and** no level dressed. A dressed level is charged for either way,
        since its blob is in the overlay whichever build reads it."""
        if count is None:
            count = len(self.level_palettes())
        base = self.next_base
        if not count and LEVEL_CUSTOM_PALETTES.id not in base.features:
            return 0
        return level_palettes.bytes_for(count)

    def level_runs(
        self, base: RomBase | None = None, palettes: int | None = None
    ) -> tuple[LevelRun, ...]:
        """The runs the packer fills on ``base`` -- the next build's, unless a
        feature switch is pricing another -- with the palettes' bytes in
        front of the level bank's: :func:`smw_tools.levels.runs_for`."""
        if base is None:
            base = self.next_base
        return runs_for(base, self.level_palette_bytes(palettes))

    def level_packing(
        self, base: RomBase | None = None, palettes: int | None = None
    ) -> Packing:
        """Where the managed level banks put every stream this project's
        build inserts -- :func:`smw_tools.levels.pack` over the project's
        own sizes.

        The checkout's sizes are read once and cached; only the containers
        the overlay holds are read again, which keeps this as cheap on the
        path of a save as :meth:`level_room` is. The packing is the whole of
        what a save has to know: :attr:`~smw_tools.levels.Packing.fits`, and
        what to take out when it does not.

        ``base`` is the cartridge to pack for, the next build's unless a
        feature switch is pricing the one it is going to; ``palettes`` is
        how many levels wear a custom palette, the saved number unless a
        palette save is pricing the one it is about to make. Both decide
        the runs (:meth:`level_runs`).
        """
        if base is None:
            base = self.next_base
        stock = stock_stream_sizes(self.base, self.target.romid)
        edited = self._edited_containers()
        deleted = set(self.deleted_level_labels())

        def size_of(insertion) -> int:  # noqa: ANN001 - an Insertion
            if insertion.label in deleted:
                return EMPTY_STREAM_SIZES[insertion.kind]
            path = edited.get(insertion.container)
            if path is not None:
                return stream_size(path, insertion.kind)
            return stock[(insertion.container, insertion.kind)]

        # The added files' streams last, as the close packs them: a region of
        # their own on the packer's terms, after the banks'.
        regions = list(managed_regions(self.base, self.target))
        added = added_insertions(self.added_level_files())
        if added:
            regions.append(
                LevelRegion(name="added", start=0, end=None, insertions=added)
            )
        return pack(
            regions,
            size_of,
            runs=self.level_runs(base, palettes),
        )

    def level_bank_spare(self, palettes: int | None = None) -> int:
        """How many bytes the level bank has left behind its two occupants
        on this project's next build, with ``palettes`` levels dressed --
        the saved number unless a palette save is asking about the one it
        is about to make. Negative by what the packed streams no longer
        fit, which a palette that took their room is answerable for.

        The bank's room is one number for both occupants: the palettes take
        the head, the streams the managed level banks pack take what
        follows, and what is spare is what either may still grow into.
        """
        base = self.next_base
        run = level_bank_run(base, self.level_palette_bytes(palettes))
        if not is_managed(base):
            return run.size
        packing = self.level_packing(base, palettes)
        if not packing.fits:
            return -packing.over
        return run.size - packing.used[-1]

    def level_palette_capacity(self) -> int:
        """How many levels may wear a custom palette on this project's next
        build: :func:`shiny_mushroom.level_palettes.capacity` over what the
        level bank has once the packed level streams have taken theirs --
        :data:`shiny_mushroom.level_palettes.CAPACITY` with the bank to
        themselves, fewer where the streams, the managed level banks' tail
        or the per-level graphics' block ahead share it."""
        base = self.next_base
        room = level_bank_run(base).size
        if is_managed(base):
            held = len(self.level_palettes())
            packing = self.level_packing(base, held)
            if not packing.fits:
                return held
            room -= packing.used[-1]
        return level_palettes.capacity(room)

    def _edited_containers(self) -> dict[str, Path]:
        """Container name -> the overlay's copy, for every level this has saved."""
        folder = self.overlaid(self.base / LEVELS_DIR)
        if not folder.is_dir():
            return {}
        return {path.stem: path for path in folder.glob("*.mwl")}

    def level_regions_for(self, level: int) -> tuple[LevelRegion, ...]:
        """Every region a save of ``level`` writes into.

        Two as a rule and one when the level's streams share a container that is
        inserted whole -- the Layer 1 stream and the sprite list are separate
        insertions, and the ROM map is free to put them in different banks.
        """
        where = self.level_file(level)
        if where is None:
            return ()
        found: dict[str, LevelRegion] = {}
        paths = [*where.paths, self.layer2_file(level)]
        for path in paths:
            if path is None:
                continue
            for region in regions_holding(path.stem, self.base, self.target):
                found[region.name] = region
        return tuple(found.values())

    def revert_level(self, level: int) -> list[Path]:
        """Take level ``level`` back out of the overlay, and say which files moved.

        Deleting the file *is* the revert: what the build reads is then the
        disassembly's own again, with nothing else to keep in step. A level that
        was never saved reverts to nothing, which is not an error.

        Safe for the levels sharing a container through the pointer tables,
        because those are one level under several numbers -- see
        :attr:`~smw_tools.levels.LevelFile.shared_with`.

        **Layer 2 is the one kind of sharing that is not that.** Nine level
        numbers read their Layer 2 out of a container another level owns
        outright: level ``$0EB``'s Layer 2 is in level ``$0C4``'s file, and the
        two are different levels. So a revert of the owner keeps that region --
        the file stays, with only the owner's own two regions put back -- and a
        revert of the borrower does not touch it at all. Which is the same rule
        the background follows: Revert Level takes back what is the level's
        own, and a shared Layer 2 is taken back where it was edited.

        The level's graphics row lives in its container, so it goes with it.
        """
        where = self.level_file(level)
        if where is None:
            return []
        removed = []
        for path in where.paths:
            overlaid = self.overlaid(path)
            if not overlaid.is_file():
                continue
            if not path.is_file():
                # A container this project *added*: there is no checkout copy
                # to come back to, so a revert has nothing to say about it --
                # the file is the level, and taking it out is
                # :meth:`delete_level_file`'s, deliberately.
                continue
            borrowed = self._layer2_borrowed(path, where.shared_with)
            if not borrowed:
                overlaid.unlink()
                removed.append(overlaid)
                continue
            stock = path.read_bytes()
            kept = write_level(
                stock, *read_level(stock), layer2_payload(overlaid.read_bytes())
            )
            if kept == stock:
                overlaid.unlink()
            else:
                _write_atomic(overlaid, kept)
            removed.append(overlaid)
        if removed:
            self._write_metadata({"modified": _now()})
        return removed

    def _layer2_borrowed(self, path: Path, by: Sequence[int]) -> bool:
        """Whether a level outside ``by`` reads its Layer 2 out of ``path``.

        What makes a container more than one level's: the Layer 2 pointer table
        can send a level to a file it takes nothing else from, and ``by`` is
        the set of numbers that are already the same level under several names.
        """
        table = self.layer2_table()
        held = frozenset(by)
        seen: dict[str, Path | None] = {}
        for other, entry in enumerate(table.entries):
            if entry.background or other in held:
                continue
            if entry.label not in seen:
                seen[entry.label] = layer2_container(
                    entry.label, self.base, self.target
                )
            if seen[entry.label] == path:
                return True
        return False

    def edited(self, level: int) -> bool:
        """Whether this project has saved anything for ``level``."""
        where = self.level_file(level)
        return where is not None and any(
            self.overlaid(path).is_file() for path in where.paths
        )

    # -- the Layer 2 pointer table --------------------------------------------

    def layer2_table(self) -> Layer2Table:
        """The Layer 2 pointer table as the build would read it.

        Through :meth:`source`, so a repointed level reads back as the repoint
        -- the same rule :meth:`level_streams` states for the streams.
        """
        return Layer2Table.read(
            self.source(self.base / LAYER2_TABLE).read_text(encoding="utf-8")
        )

    def layer2_choices(self) -> tuple[Layer2Entry, ...]:
        """Everything a level's Layer 2 can be pointed at.

        The union of what the project's table and the stock table name, because
        an entry this project has repointed every reader away from still has to
        be offered -- or the edit could never be taken back -- and every Layer
        2 stream the level banks insert under a label, whether or not a number
        reads it: the unused levels' own Layer 2 streams are reachable only
        this way, and pointing a number at one is what makes them a level
        again. A stream whose label the project has deleted is not offered:
        it loads as the empty level.
        """
        deleted = set(self.deleted_level_labels())
        inserted = (
            Layer2Entry(NAMESPACE + label, background=False)
            for label, one in stream_definitions(self.base, self.target).items()
            if one.kind == LAYER_2 and label not in deleted
        )
        return layer2_table_choices(
            self.layer2_table(), self._stock_layer2(), extra=inserted
        )

    def layer2_for_container(self, container: str) -> Layer2Entry | None:
        """The Layer 2 entry ``container`` says its level had, or ``None``.

        A Layer 1 stream is half a level: its header's mode says whether
        Layer 2 is walked as objects or drawn as a background, and the third
        pointer table says which. A container carries the tool's copy of that
        Layer 2 (:mod:`shiny_mushroom.mwl`), and this finds what in the tree
        holds the same bytes -- by content, never by the address the region
        records, which is a fact about the ROM the file was extracted from. A
        background is matched against the seventeen blobs bank ``$0C``
        defines; an object stream against every Layer 2 stream the banks
        insert, the container's own first, then one a table already names.

        ``None`` for a container the tree does not hold, one whose Layer 2
        matches nothing here -- a file imported from a hack with a background
        of its own -- or one whose label the project has deleted. What a
        remap should point the number's Layer 2 at, and what it says it
        cannot when this answers ``None``.
        """
        path = self.source(self.base / LEVELS_DIR / f"{container}.mwl")
        if not path.is_file():
            return None
        try:
            held = mwl.Container.read(path.read_bytes())
        except (MwlError, OSError):
            return None
        if held.layer2_is_background:
            tilemap = held.layer2_tilemap()
            if tilemap is None:
                return None
            for label, blob in sorted(background_definitions(self.base).items()):
                try:
                    decoded, _ = decompress(blob.read_bytes(), Variant.RLE1)
                except (OSError, CorruptStream):
                    continue
                if decoded[: len(tilemap)] == tilemap:
                    return Layer2Entry(label, background=True)
            return None
        try:
            wanted = held.payload(mwl.LAYER2)
        except MwlError:
            return None
        named = {entry.label for entry in self.layer2_choices()}
        deleted = set(self.deleted_level_labels())
        found: list[tuple[bool, bool, str]] = []
        for label, one in stream_definitions(self.base, self.target).items():
            if one.kind != LAYER_2 or label in deleted:
                continue
            other = self.source(self.base / LEVELS_DIR / f"{one.container}.mwl")
            try:
                if mwl.layer2_payload(other.read_bytes()) != wanted:
                    continue
            except (MwlError, OSError):
                continue
            spelled = NAMESPACE + label
            found.append((one.container != container, spelled not in named, spelled))
        if not found:
            return None
        return Layer2Entry(min(found)[2], background=False)

    def save_layer2_pointer(
        self, level: int, entry: Layer2Entry, header: bytes | None = None
    ) -> Path | None:
        """Point ``level``'s Layer 2 at ``entry``, and say which file moved.

        A three-byte edit inside a fixed-size table, so unlike a stream save
        there is nothing to price: no region can overflow, and no other level's
        entry moves. A table repointed back to stock is *reverted* rather than
        written -- the overlay's copy comes out, exactly as
        :meth:`revert_level` removes a container -- which is why this can
        return ``None``: nothing needed to move.

        A background is refused where the level's Layer 1 reads a level mode
        that walks Layer 2 as objects: the other side of what
        :meth:`save_level_pointers` refuses, and the same hang
        (:meth:`layer2_gap`). ``header`` is the level's header as the editor
        holds it, for the dialog that changes the level mode and the pointer
        in one accept -- a mode edited out of the way there has not reached
        the container yet, and weighing the container's copy would refuse an
        edit that is already the fix.
        """
        if gap := self.layer2_gap(level, entry=entry, header=header):
            raise ProjectError(gap.refusing_a_repoint)
        return self._write_layer2_pointer(level, entry)

    def _write_layer2_pointer(self, level: int, entry: Layer2Entry) -> Path | None:
        """The table edit behind :meth:`save_layer2_pointer`, without its
        refusal -- for the remap that has already weighed the pair it is
        about to write."""
        stock_text = (self.base / LAYER2_TABLE).read_text(encoding="utf-8")
        repointed = self.layer2_table().repointed(
            level, entry, donors=Layer2Table.read(stock_text)
        )
        text = repointed.text()
        moved = self._shadow_or_revert(LAYER2_TABLE, text, stock_text)
        if moved is not None:
            self._write_metadata({"modified": _now()})
        return None if text == stock_text else moved

    def layer2_repoint(self, level: int) -> Layer2Entry | None:
        """What this project repointed ``level``'s Layer 2 to, if it has.

        ``None`` while the level's entry is stock. The entry names a *label*;
        turning it into the three pointer bytes a cartridge preview needs is
        the build symbol file's job -- the one file that says what the
        assembler resolved for the very image being patched.
        """
        held = self.layer2_table()
        stock = self._stock_layer2()
        if level >= len(held.entries) or level >= len(stock.entries):
            return None
        entry = held.entry(level)
        return None if entry == stock.entry(level) else entry

    def layer2_pointer_donors(self, entry: Layer2Entry) -> tuple[int, ...]:
        """The level numbers whose three pointer bytes in the cartridge are
        ``entry``'s own: every level pointing at it in **both** the stock table
        and this project's.

        Both tables, because each rules out one way the cartridge's entry
        could mean something else. The stock table is what the reference cart
        was assembled from, so on a cartridge this project has not built the
        stock entry *is* the bytes; and a level this project has repointed may
        have been built that way, so its entry in a built image answers for
        the repoint rather than for the label. A level in both is one whose
        entry no table ever asked to move -- which is what lets a preview read
        the label's address off the image itself when there is no symbol file
        to ask (:func:`~shiny_mushroom.cart_patches.layer2_pointer_patch`).
        """
        held = self.layer2_table()
        stock = self._stock_layer2()
        readable = min(len(held.entries), len(stock.entries))
        return tuple(
            level
            for level in range(readable)
            if held.entries[level] == entry and stock.entries[level] == entry
        )

    def _stock_layer2(self) -> Layer2Table:
        return Layer2Table.read((self.base / LAYER2_TABLE).read_text(encoding="utf-8"))

    # -- the Layer 1 and sprite pointer tables --------------------------------

    def level_map(self) -> dict[int, LevelFile]:
        """Every level number and where its data is, through this project's
        pointer tables.

        :func:`smw_tools.levels.containers` while the tables are the
        checkout's own -- the cached fast path every unremapped project is on
        -- and the same resolution over the overlay's copies once a level has
        been remapped, so everything that asks (a load, a save, the viewer)
        sees the remap at once. Resolution is
        :func:`smw_tools.levels.place` either way; only where the tables are
        read from differs.
        """
        if not any(
            self.overlaid(self.base / table).is_file()
            for table in (LAYER1_TABLE, SPRITE_TABLE)
        ):
            return containers(self.base, self.target)
        return place(
            self._pointer_table(LAYER1_TABLE).labels,
            self._pointer_table(SPRITE_TABLE).labels,
            self.level_definitions(),
            self.base,
        )

    def level_file(self, level: int) -> LevelFile | None:
        """Where ``level``'s data is under this project, or ``None`` if
        nothing places it.

        The project's answer to :func:`smw_tools.levels.level_file`, and the
        one every path in this class asks: a level that has been remapped
        loads, saves, prices and reverts as the container its *table* names,
        not the checkout's.
        """
        return self.level_map().get(level)

    def level_pointer_labels(self) -> tuple[tuple[str, ...], tuple[str, ...]]:
        """The Layer 1 and sprite tables' labels in level order, as the build
        would read them -- the overlay's copy where a remap has written one,
        spelled as the tables spell them."""
        return (
            self._pointer_table(LAYER1_TABLE).labels,
            self._pointer_table(SPRITE_TABLE).labels,
        )

    def _pointer_table(self, relative: Path) -> PointerTable:
        """One of the two tables as the build would read it -- the overlay's
        copy where a remap has written one."""
        return PointerTable.read(
            self.source(self.base / relative).read_text(encoding="utf-8")
        )

    def level_definitions(self) -> dict[str, str]:
        """Label -> container, for everything a pointer entry may name: the
        banks' own definitions, and the labels the added-files fragment defines for
        the containers this project adds."""
        return definitions(self.base, self.target) | added_labels(
            self.added_level_files()
        )

    def level_targets(
        self, level: int
    ) -> tuple[StreamTarget | None, StreamTarget | None]:
        """What ``level``'s two entries point at -- Layer 1, then sprites --
        with ``None`` for an entry naming a label the banks do not define,
        which is what a hand-hacked table leaves behind."""
        known = self.level_definitions()
        found = []
        for relative in (LAYER1_TABLE, SPRITE_TABLE):
            label = self._pointer_table(relative).label(level)
            container = known.get(undecorated(label))
            found.append(None if container is None else StreamTarget(label, container))
        return (found[0], found[1])

    def layer1_targets(self) -> tuple[StreamTarget, ...]:
        """Everything a level's Layer 1 entry can be pointed at, by container
        name -- every Layer 1 stream the level banks insert under a label,
        whether or not any level currently reads it (the thirty-odd containers
        reached by address rather than by number, the unused levels among
        them, are targets too, and pointing a number at one is half of what a
        remap is for), and every container this project adds. A container the
        project has deleted is not offered: its label loads the empty level."""
        return self._stream_targets(LAYER_1, "LEVEL_L1_", ADDED_LAYER1_PREFIX)

    def sprite_targets(self) -> tuple[StreamTarget, ...]:
        """Everything a level's sprite entry can be pointed at, on
        :meth:`layer1_targets`' terms."""
        return self._stream_targets(SPRITES, "LEVEL_SP_", ADDED_SPRITE_PREFIX)

    def _stream_targets(
        self, kind: str, prefix: str, added_prefix: str
    ) -> tuple[StreamTarget, ...]:
        """The banks' labels spelled with the namespace the tables add, and
        the added containers' spelled bare -- the generated fragment assembles
        outside it. By the insertion's *kind* first, which is what a label
        reaches -- the unused levels' ``UnusedLevelData_*`` labels are Layer 1
        and sprite streams like any other -- and by the label's spelling for
        the one exception, ``LEVEL_L1_BlankEntrance``: a Layer 2 region the
        game itself loads as a Layer 1 entrance room.
        """
        deleted = set(self.deleted_level_labels())
        found = [
            StreamTarget(label=NAMESPACE + one.label, container=one.container)
            for one in stream_definitions(self.base, self.target).values()
            if one.label not in deleted
            and (one.kind == kind or one.label.startswith(prefix))
        ]
        found += [
            StreamTarget(label=added_prefix + name, container=name)
            for name in self.added_level_files()
        ]
        seen: dict[str, StreamTarget] = {}
        for target in found:
            seen.setdefault(target.label, target)
        return tuple(sorted(seen.values(), key=lambda target: target.container.lower()))

    def save_level_pointers(
        self,
        level: int,
        layer1: StreamTarget | None = None,
        sprites: StreamTarget | None = None,
        layer2: Layer2Entry | None = None,
    ) -> list[Path]:
        """Point ``level``'s streams at other containers, and say which files
        moved.

        Label edits inside fixed-size tables, so as with a Layer 2 repoint
        there is nothing to price and no other level's entry moves. ``None``
        leaves that stream pointing where it points. Each target must be a
        label the banks define -- anything else would assemble nothing -- and
        a table put back to the checkout's own is *reverted* rather than
        written, exactly as :meth:`save_layer2_pointer` reverts its table.

        ``layer2`` is the third table's half of the same move: a Layer 1
        remap changes which level the number *is*, and the level's Layer 2 --
        the background behind it, or the stream a Layer 2 mode walks -- is
        part of that, recorded in the container it came from
        (:meth:`layer2_for_container`). Written in the same call so the pair
        is weighed as it will stand: a Layer 1 target whose header asks for a
        Layer 2 stream is refused where the level's Layer 2 *would be* a
        background image, because that pair does not build wrong, it hangs
        the cartridge on the load (:meth:`layer2_gap`).
        """
        known = self.level_definitions()
        for target in (layer1, sprites):
            if target is None:
                continue
            resolved = known.get(undecorated(target.label))
            if resolved is None:
                raise ProjectError(
                    f"nothing defines {target.label}, so pointing level "
                    f"{hexnum(level, 3)} at it would not build"
                )
            if resolved != target.container:
                raise ProjectError(
                    f"{target.label} reads {resolved}.mwl, not "
                    f"{target.container}.mwl -- the choice list is stale"
                )
        if layer1 is not None and (
            gap := self.layer2_gap(level, layer1.container, entry=layer2)
        ):
            raise ProjectError(gap.refusing_a_remap)
        written = []
        if layer2 is not None and (moved := self._write_layer2_pointer(level, layer2)):
            written.append(moved)
        for target, relative in ((layer1, LAYER1_TABLE), (sprites, SPRITE_TABLE)):
            if target is None:
                continue
            stock_text = (self.base / relative).read_text(encoding="utf-8")
            repointed = self._pointer_table(relative).repointed(level, target.label)
            if moved := self._shadow_or_revert(relative, repointed.text(), stock_text):
                written.append(moved)
        if sprites is not None:
            # The sprite-bank fragment names the same labels, row for row.
            written.extend(self.sync_level_fragments())
        if written:
            self._write_metadata({"modified": _now()})
        return written

    def layer2_gap(
        self,
        level: int,
        container: str | None = None,
        entry: Layer2Entry | None = None,
        header: bytes | None = None,
    ) -> Layer2Gap | None:
        """Whether ``level`` would leave the game reading a background image
        as an object stream, and why.

        The pair takes two halves that are edited from different places and
        neither can see the other: the Layer 1 stream's header decides whether
        Layer 2 is walked at all, and the Layer 2 entry decides what is there
        to walk. Each half defaults to what the project holds, and a caller
        overrides the one it is about to write -- ``container`` for a remap,
        ``entry`` for a Layer 2 repoint, ``header`` for a level whose header
        has been edited but not saved into its container yet.

        ``None`` for everything else, which is every edit but this shape of
        one. A container the tree does not hold answers ``None`` too: the
        label check in :meth:`save_level_pointers` is what has an opinion on
        that.
        """
        if entry is None:
            entry = self.layer2_table().entry(level)
        if not entry.background:
            return None
        found = self._layer1_stream(level, container, header)
        if found is None:
            return None
        name, layer1 = found
        if not needs_layer2_data(layer1):
            return None
        return Layer2Gap(
            level=level,
            container=name,
            mode=field_value(layer1, "level_mode"),
            background=entry.name,
        )

    def _layer1_stream(
        self, level: int, container: str | None, header: bytes | None
    ) -> tuple[str, bytes] | None:
        """The Layer 1 bytes :meth:`layer2_gap` should weigh, and the name to
        call them by -- ``None`` when there are none to weigh.

        A named container is read straight out of the tree; without one the
        level's own stream is read through :meth:`level_streams`, so a deleted
        label answers as the empty level the build puts under it rather than
        as the file's bytes. ``header`` stands in for the first five either
        way, which is what lets an unsaved header edit be weighed as the edit
        rather than as what the container still holds.
        """
        if container is None:
            where = self.level_file(level)
            if where is None:
                return None
            if header is not None:
                # The container is wanted for its name alone, so its bytes are
                # not read: this runs on every keystroke in the header dialog.
                return where.layer1.stem, bytes(header)
            streams = self.level_streams(level)
            if streams is None:
                return None
            name, layer1 = where.layer1.stem, streams[0]
        else:
            path = self.source(self.base / LEVELS_DIR / f"{container}.mwl")
            if not path.is_file():
                return None
            name, (layer1, _) = container, read_level(path.read_bytes())
        return name, layer1 if header is None else bytes(header)

    def repointed_levels(self) -> tuple[int, ...]:
        """Every level number whose Layer 1 or sprite entry this project has
        remapped, in order -- what a build has to land before a cartridge
        shows them. Empty on the fast path: no overlay copy, no remap."""
        found: set[int] = set()
        for relative in (LAYER1_TABLE, SPRITE_TABLE):
            if not self.overlaid(self.base / relative).is_file():
                continue
            held = self._pointer_table(relative)
            stock = PointerTable.read(
                (self.base / relative).read_text(encoding="utf-8")
            )
            readable = min(len(held.labels), len(stock.labels))
            found.update(
                one for one in range(readable) if held.labels[one] != stock.labels[one]
            )
        return tuple(sorted(found))

    # -- the containers this project adds -------------------------------------

    def added_level_files(self) -> tuple[str, ...]:
        """The containers this project adds, in name order: the overlay's
        ``.mwl`` files that shadow nothing.

        Derived rather than recorded, on the overlay's own principle -- what
        is in it is what has been changed, and a file that stands in for no
        checkout file is a file the project brought. Deleting it *is* the
        delete, with no manifest to keep in step.
        """
        folder = self.overlaid(self.base / LEVELS_DIR)
        if not folder.is_dir():
            return ()
        return tuple(
            sorted(
                path.stem
                for path in folder.glob("*.mwl")
                if not (self.base / LEVELS_DIR / path.name).is_file()
            )
        )

    def add_level_file(self, name: str, data: bytes) -> Path:
        """Bring a new container into the project, and say where it landed.

        ``data`` is the whole ``.mwl`` -- a blank one
        (:func:`shiny_mushroom.mwl.blank_container`), a copy of another
        container, or a file from another hack -- validated as far as the
        insertion macro will read it: a container whose Layer 1 or sprite
        region cannot be read is refused here rather than by asar.

        The file alone changes nothing in a build: its streams enter the ROM
        through the managed level banks' added-files fragment
        (:meth:`sync_level_fragments`), packed after the game's own streams,
        and a level number reaches them through a remap. So the add needs
        the ``managed-level-memory`` feature, and is refused up front on a
        project without it -- a stock build has nowhere to put the streams
        and would fail on the labels the pointer tables name.
        """
        if not ADDED_NAME.match(name):
            raise ProjectError(
                f"{name!r} is not a usable file name: letters, digits and '_', "
                f"starting with a letter or digit"
            )
        if not self.level_memory_managed:
            raise ProjectError(
                "a new level file is packed into the managed level banks; turn "
                "on Growable levels under Project > Features first"
            )
        taken = {path.stem.lower() for path in (self.base / LEVELS_DIR).glob("*.mwl")}
        folder = self.overlaid(self.base / LEVELS_DIR)
        if folder.is_dir():
            taken |= {path.stem.lower() for path in folder.glob("*.mwl")}
        # Case-insensitively, because the overlay may live on a filesystem
        # that folds case -- two containers a build could tell apart would be
        # one file on Windows.
        if name.lower() in taken:
            raise ProjectError(f"there is already a container called {name}.mwl")
        try:
            read_level(data)
        except MwlError as error:
            raise ProjectError(
                f"{name}.mwl would not be a level file: {error}"
            ) from error
        destination = folder / f"{name}.mwl"
        destination.parent.mkdir(parents=True, exist_ok=True)
        _write_atomic(destination, data)
        self.sync_level_fragments()
        self._write_metadata({"modified": _now()})
        return destination

    def rename_level_file(self, name: str, new_name: str) -> Path:
        """Call an added container something else, and say where it is now.

        Only a file this project added: the game's own are named by the bank
        that inserts them, and renaming one would be an edit to the
        disassembly. The name is half of the file's two labels, so every
        pointer entry naming them is rewritten to the new spelling and the
        added-files fragment regenerated -- a level reading the file goes on
        reading it under the new name.
        """
        if name not in self.added_level_files():
            raise ProjectError(
                f"{name}.mwl is not a file this project added; the game's own "
                f"files are named by the disassembly"
            )
        if not ADDED_NAME.match(new_name):
            raise ProjectError(
                f"{new_name!r} is not a usable file name: letters, digits and "
                f"'_', starting with a letter or digit"
            )
        folder = self.overlaid(self.base / LEVELS_DIR)
        held = folder / f"{name}.mwl"
        if new_name == name:
            return held
        taken = {path.stem.lower() for path in (self.base / LEVELS_DIR).glob("*.mwl")}
        taken |= {path.stem.lower() for path in folder.glob("*.mwl")}
        taken.discard(name.lower())
        if new_name.lower() in taken:
            raise ProjectError(f"there is already a container called {new_name}.mwl")
        destination = folder / f"{new_name}.mwl"
        held.rename(destination)
        for relative, prefix in (
            (LAYER1_TABLE, ADDED_LAYER1_PREFIX),
            (SPRITE_TABLE, ADDED_SPRITE_PREFIX),
        ):
            table = self._pointer_table(relative)
            reading = table.levels_pointing(prefix + name)
            if not reading:
                continue
            for level in reading:
                table = table.repointed(level, prefix + new_name)
            _write_atomic(self.overlaid(self.base / relative), table.text())
        self.sync_level_fragments()
        self._write_metadata({"modified": _now()})
        return destination

    def record_level_in_file(self, name: str, level: int) -> Path:
        """Stamp ``level`` as the number a container records, and say which
        file moved.

        The word Lunar Magic wrote into the file's info region
        (:attr:`~shiny_mushroom.mwl.Container.recorded_level`) -- a record
        the pointer tables never consult, kept here so a file can be made to
        agree with them. An edit to the file, so it lands in the overlay like
        a saved level: a checkout container gains a copy, and a copy stamped
        back to the checkout's own bytes comes out again.
        """
        if not 0 <= level < LEVEL_COUNT:
            raise ProjectError(f"{level:#x} is not a level number")
        stock = self.base / LEVELS_DIR / f"{name}.mwl"
        held = self.overlaid(stock)
        source = held if held.is_file() else stock
        if not source.is_file():
            raise ProjectError(f"there is no level file called {name}.mwl")
        try:
            stamped = mwl.Container.read(source.read_bytes()).recording(level).write()
        except MwlError as error:
            raise ProjectError(f"{name}.mwl could not be restamped: {error}") from error
        if stock.is_file() and stamped == stock.read_bytes():
            if held.is_file():
                held.unlink()
                self._write_metadata({"modified": _now()})
            return stock
        held.parent.mkdir(parents=True, exist_ok=True)
        _write_atomic(held, stamped)
        self._write_metadata({"modified": _now()})
        return held

    def deleted_level_labels(self) -> tuple[str, ...]:
        """The level labels this project has deleted, in label order,
        spelled as the definitions are -- recorded in ``project.json`` under
        ``levels.deleted_labels``, since a deletion is the one edit the
        overlay cannot express as a file of its own.

        A deleted label inserts the empty level instead of its stream
        (``levels/deleted-levels.asm``), so every level number naming it
        loads empty there and the bytes the stream took are room for the
        rest. The label is the unit because the build's is: a file is read
        through one label per stream, and its Layer 2 can go while its
        layout stays. The file itself is untouched -- the checkout's, and
        any overlay copy -- which is what makes :meth:`restore_level_labels`
        a restore. A project written before labels were the record listed
        *files* under ``levels.deleted``; those read as every label of each,
        and the next write records the labels.
        """
        held = self.metadata.get("levels", {})
        if not isinstance(held, dict):
            return ()
        labels = set(_string_list(held.get("deleted_labels")))
        files = set(_string_list(held.get("deleted")))
        if files:
            for label, one in stream_definitions(self.base, self.target).items():
                if one.container in files:
                    labels.add(label)
        return tuple(sorted(labels))

    def deleted_level_files(self) -> tuple[str, ...]:
        """The checkout's containers every label of which this project has
        deleted, in name order: the files whose bytes no longer reach the
        ROM at all. Derived from :meth:`deleted_level_labels`; a file with
        only some of its labels deleted is not listed here."""
        deleted = set(self.deleted_level_labels())
        return tuple(
            sorted(
                name
                for name, labels in self._container_labels().items()
                if labels and set(labels) <= deleted
            )
        )

    def _container_labels(self) -> dict[str, tuple[str, ...]]:
        """Container -> every label the banks define over one of its
        streams, in label order."""
        found: dict[str, list[str]] = {}
        for label, one in stream_definitions(self.base, self.target).items():
            found.setdefault(one.container, []).append(label)
        return {name: tuple(sorted(labels)) for name, labels in found.items()}

    def _write_deleted_labels(self, labels: set[str]) -> None:
        # The whole ``levels`` key, so a legacy ``deleted`` file list is
        # replaced by the labels it was read as.
        self._write_metadata(
            {"levels": {"deleted_labels": sorted(labels)}, "modified": _now()}
        )
        self.sync_level_fragments()

    def delete_level_labels(self, labels: Iterable[str]) -> tuple[str, ...]:
        """Take the named labels' streams out of the build, and say which
        labels moved.

        Each must be one the level banks define, spelled either way the
        tables do -- a define for anything else would empty nothing -- and
        not one of a file this project added, whose streams leave with the
        file. A label already deleted is left as it is.
        """
        wanted = {undecorated(label) for label in labels}
        known = stream_definitions(self.base, self.target)
        added = added_labels(self.added_level_files())
        for label in sorted(wanted):
            if label in added:
                raise ProjectError(
                    f"{label} is a label of a file this project added; delete "
                    f"the file instead"
                )
            if label not in known:
                raise ProjectError(f"no level bank defines {label}")
        held = set(self.deleted_level_labels())
        moved = tuple(sorted(wanted - held))
        if moved:
            self._write_deleted_labels(held | wanted)
        return moved

    def restore_level_labels(self, labels: Iterable[str]) -> tuple[str, ...]:
        """Put the named deleted labels' streams back into the build, and
        say which labels moved."""
        wanted = {undecorated(label) for label in labels}
        held = set(self.deleted_level_labels())
        unknown = sorted(wanted - held)
        if unknown:
            raise ProjectError(
                f"{', '.join(unknown)} is not a label this project has deleted"
            )
        self._write_deleted_labels(held - wanted)
        return tuple(sorted(wanted))

    def delete_level_file(self, name: str) -> Path:
        """Take a container's streams out of the build, and say which file
        moved.

        Two kinds of file, two kinds of delete. One the project **added** has
        no other copy, so the file goes -- refused while a level number still
        reads it, since its entries would then name labels nothing defines.
        One the **checkout** ships stays on disk and every label over it is
        *recorded* as deleted (:meth:`delete_level_labels`): the labels stay,
        loading the empty level, so the numbers reading it need no remap and
        the room it took is free for the streams after it.
        """
        if name in self.added_level_files():
            reading = sorted(
                {
                    level
                    for relative, label in (
                        (LAYER1_TABLE, ADDED_LAYER1_PREFIX + name),
                        (SPRITE_TABLE, ADDED_SPRITE_PREFIX + name),
                    )
                    for level in self._pointer_table(relative).levels_pointing(label)
                }
            )
            if reading:
                listed = ", ".join(hexnum(level, 3) for level in reading)
                raise ProjectError(
                    f"{name}.mwl is still read by {listed} -- remap them first"
                )
            held = self.overlaid(self.base / LEVELS_DIR / f"{name}.mwl")
            held.unlink()
            self.sync_level_fragments()
            self._write_metadata({"modified": _now()})
            return held
        shipped = self.base / LEVELS_DIR / f"{name}.mwl"
        if not shipped.is_file():
            raise ProjectError(f"there is no level file called {name}.mwl")
        labels = self._container_labels().get(name, ())
        if not labels:
            raise ProjectError(
                f"no level bank inserts {name}.mwl under a label, so there is "
                f"nothing to delete"
            )
        self.delete_level_labels(labels)
        return shipped

    def restore_level_file(self, name: str) -> Path:
        """Put a checkout container's deleted labels back into the build --
        every one of them, whether the whole file was deleted or a stream."""
        labels = set(self._container_labels().get(name, ())) & set(
            self.deleted_level_labels()
        )
        if not labels:
            raise ProjectError(f"{name}.mwl is not a file this project has deleted")
        self.restore_level_labels(labels)
        return self.base / LEVELS_DIR / f"{name}.mwl"

    def revert_level_file(self, name: str) -> Path | None:
        """Put a checkout container back to the disassembly's own bytes:
        the overlay's copy comes out, and ``None`` says there was none.

        The container's whole of :meth:`revert_level`, by file rather than by
        number -- every region the overlay's copy carried, a borrowed Layer 2
        included, because the file is the unit here. An added file has no
        checkout copy to come back to and is refused: taking it out is the
        delete's.
        """
        if name in self.added_level_files():
            raise ProjectError(
                f"{name}.mwl was added by this project; there is nothing to "
                f"revert it to -- delete it instead"
            )
        if not (self.base / LEVELS_DIR / f"{name}.mwl").is_file():
            raise ProjectError(f"there is no level file called {name}.mwl")
        held = self.overlaid(self.base / LEVELS_DIR / f"{name}.mwl")
        if not held.is_file():
            return None
        held.unlink()
        self._write_metadata({"modified": _now()})
        return held

    def sync_level_fragments(self) -> list[Path]:
        """Bring the level-file fragments in step with the project, and say
        which files moved.

        The two fragments the managed level banks read
        (``Config/ManagedLevelMemory.asm``): the added files' insertions,
        packed after the banks' own streams, and the deleted streams'
        defines. Both are derived state -- the added containers, and the
        deletions ``project.json`` records -- so every flow that changes
        either calls this, and a project that adds and deletes nothing
        carries no overlay copy: the disassembly's stock fragments answer
        "nothing added, nothing deleted".

        And the third, read by the managed level banks' sprite-bank stub
        (``Config/ManagedLevelMemory.asm``): the bank of every level's
        sprite list, derived from the sprite pointer table. It has an overlay
        copy exactly when the table has one -- a remap is what changes a
        row -- so every flow that writes the table calls this too, and the
        disassembly's stock fragment mirrors its stock table.

        No metadata stamp of its own: the callers are already saves, and
        each stamps once for everything it moved.
        """
        names = self.added_level_files()
        deleted = self.deleted_level_labels()
        wanted: dict[Path, str | None] = {
            STREAMS_FRAGMENT: None,
            DELETIONS_FRAGMENT: None,
            BANKS_FRAGMENT: None,
        }
        if names:
            wanted[STREAMS_FRAGMENT] = streams_fragment(names)
        if deleted:
            wanted[DELETIONS_FRAGMENT] = deleted_fragment(deleted)
        if self.overlaid(self.base / SPRITE_TABLE).is_file():
            wanted[BANKS_FRAGMENT] = sprite_banks_fragment(
                self._pointer_table(SPRITE_TABLE).labels
            )
        return self._sync_fragments(wanted)

    def also_changes(self, level: int) -> tuple[int, ...]:
        """The other level numbers a save of ``level`` would move.

        Empty for most levels and not for the shared ones -- ``$015``, ``$016``
        and ``$017`` are one level with three numbers -- and that has to be said
        before the save rather than discovered afterwards.
        """
        where: LevelFile | None = self.level_file(level)
        if where is None:
            return ()
        return tuple(other for other in where.shared_with if other != level)
