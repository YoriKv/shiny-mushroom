"""Where a ROM base keeps everything this package reads, and the RAM it reads.

A declaration, not behaviour. :class:`Addresses` answers "where is this table in
*this* cartridge"; the module constants below name the work-RAM offsets, game
modes and cartridge tables that go with it, each beside the masks and sentinels
read out of it; :class:`RamView` is the machine's memories, read once and
indexed the way the disassembly's RAM map names them.

Every work-RAM constant here is a **vanilla** offset from ``$7E0000``, which
:attr:`Addresses.ram` turns into the memory it is actually in on a base whose
coprocessor moved it.

Outside :mod:`shiny_mushroom.emu` rather than in it, and that is deliberate: a
document reading a cartridge image needs to know where a table is without a
core anywhere near it, and importing anything under that package loads the
ctypes binding. Nothing here loads native code -- :class:`RamView` is handed a
core rather than making one, and the annotation saying so is under
``TYPE_CHECKING``.
"""

from __future__ import annotations

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

from shiny_mushroom.memtype import SPACES, MemoryType
from smw_tools import asm_regions
from smw_tools.bases import AddressMap, DrivenPaths, RomBase, TracedCode
from smw_tools.bases import base as rom_base
from smw_tools.features import applied
from smw_tools.ram_map import RamMap, cpu_address, window_address
from smw_tools.rom_sizes import size_for

if TYPE_CHECKING:
    from shiny_mushroom.emu.core import MesenCore


@dataclass(frozen=True)
class Addresses:
    """Where one ROM base keeps everything this module reads out of a cartridge.

    **A cartridge address is a fact about a base, not about the game.** The five
    shipped releases share a base and so share every address here; a base that
    keeps the game and moves the code does not, and neither does one whose
    address map reaches the image differently -- SA-1 stops mirroring at bank
    ``$3F`` where LoROM carries on.

    So the loader is handed one of these rather than reading module constants,
    and it comes from the project's own base
    (:attr:`~shiny_mushroom.project.Project.base_id`). The values are resolved
    from :mod:`smw_tools.rom_tables` rather than written down here, which is
    what makes them checkable: ``smw/tests/test_rom_tables.py`` asserts every one
    is where its label actually is in a built symbol file.

    Each field is one line here and documented in full on the module constant of
    the same name below, beside the masks and sentinels that go with it -- an
    address and the bits read out of it are one fact and are not worth
    separating.
    """

    #: The cartridge these addresses are of: the ROM base with its features
    #: applied and its size folded in -- what :meth:`of` resolved every field
    #: below out of.
    #:
    #: Kept rather than unpacked and dropped, because a reader that has these
    #: addresses is reading *that* cartridge, and some of what it needs is
    #: not an address: how many runs the level packer has
    #: (:func:`smw_tools.levels.has_level_bank`, off
    #: :attr:`~smw_tools.bases.RomBase.built_at`), which capabilities it
    #: carries, what its RAM map is. Re-deriving it at the far end means
    #: re-deciding the base, the features *and* the size, which is three
    #: chances to answer differently from the addresses in hand.
    base: RomBase

    #: How this base's CPU addresses reach offsets in the headerless image.
    map: AddressMap

    #: Where this base keeps the game's work RAM. Every work-RAM constant in
    #: this module is a **vanilla** offset from ``$7E0000``; this is what turns
    #: one into the memory it is actually in -- see :mod:`smw_tools.ram_map`.
    ram: RamMap

    #: Which bits of a level's sprite-stream header byte this base's build sets
    #: for itself -- see
    #: :attr:`~smw_tools.bases.RomBase.sprite_header_build_owned`. Zero on a
    #: base whose build carries level data through untouched.
    sprite_header_build_owned: int

    #: Which paths that call the game's own routines work on this base -- see
    #: :class:`~smw_tools.bases.DrivenPaths`. Carried whole rather than unpacked
    #: into a field per path, so adding one is a change to that class alone.
    driven: DrivenPaths

    #: Where this base keeps the code its captures trace -- see
    #: :class:`~smw_tools.bases.TracedCode`. Carried whole for
    #: :attr:`driven`'s reason, and separate from the tables below because a
    #: bank range has no label to resolve through and no override to read: a
    #: project's build can move a table, but only a base can move the code.
    traced: TracedCode

    #: Every table by role, and how many entries each holds -- the same numbers
    #: the named fields below carry, reachable by name for a caller reading
    #: tables in bulk rather than naming one. The fields are built *from*
    #: :attr:`roles`, so the two cannot disagree, and the counts come from
    #: :mod:`smw_tools.asm_regions`: the stock format except where a feature
    #: grew a table. Between them they are what reads one whole.
    roles: Mapping[str, int]
    counts: Mapping[str, int]
    #: And how many entries past a table's count its scan reads, by role,
    #: where one does -- the stock destroyed-tiles scan's eight, which a build
    #: that binds the scan to the table's labels no longer reads
    #: (:attr:`smw_tools.asm_codec.AsmRegion.overread`). A capture reads the
    #: window the scan reads, over-read included, so the replay's port walks
    #: exactly what the console walks.
    overreads: Mapping[str, int]

    #: The three pointer tables a level number resolves through.
    layer1_pointers: int
    layer2_pointers: int
    sprite_pointers: int

    #: The secondary header, one byte per level in each of four tables.
    secondary_header_y: int
    secondary_header_x: int
    secondary_header_fg_position: int
    secondary_header_entrance: int

    #: The secondary entrances, one byte per entrance in each of four tables.
    secondary_entrance_destination: int
    secondary_entrance_camera_y: int
    secondary_entrance_x_and_screen: int
    secondary_entrance_action: int

    #: The fixed entrance positions the secondary header and the secondary
    #: entrances both index into.
    entrance_y_low: int
    entrance_y_high: int
    entrance_x_low: int
    entrance_x_high: int

    #: Where the camera and Layer 2 start, and how Layer 2 scrolls.
    layer1_initial_y: int
    layer2_initial_y: int
    l2_vert_scroll_settings: int

    #: Level geometry and the definitions a Layer 2 background is drawn from.
    vertical_table: int
    map16_bg_defs: int

    #: The four pipe Map16 tables, as the cartridge's own pointers to them.
    #: See :data:`PIPE_TILES`.
    pipe_map16_pointers: int

    #: The overworld's per-translevel tables: which event a level's clear
    #: fires, and the walk the player takes afterwards.
    overworld_level_events: int
    overworld_level_names: int
    overworld_level_directions: int

    #: The star/pipe warp tables and the path-exit tables -- where a warp
    #: trigger stands and where each transfer lands the player.
    overworld_warp_trigger_columns: int
    overworld_warp_trigger_rows: int
    overworld_warp_landings_x: int
    overworld_warp_landings_y: int
    overworld_exit_triggers: int
    overworld_exit_landings: int
    overworld_exit_landing_cells: int

    #: The (translevel, flags) pairs a new save file's tile settings start
    #: from -- the walkability the map opens with before anything is beaten.
    initial_level_flags: int

    #: The overworld's own Map16 definition table -- the one its display path
    #: names with a long pointer, in a different bank from the level tables.
    overworld_map16_defs: int

    #: The overworld's Layer 1 tilemap in the image -- what the game
    #: block-copies to RAM at load, and what a test run patches so an edited
    #: world map is the one the player walks out onto.
    overworld_layer1_tilemap: int

    #: The event system's tables: pass 2's entry/pointer pair, pass 1's
    #: Layer 1 substitutions, and the stamp sheets with their properties.
    overworld_event_tile_entries: int
    overworld_event_pointers: int
    overworld_event_layer1_locations: int
    overworld_event_layer1_from: int
    overworld_event_layer1_to: int
    overworld_event_tiles: int
    overworld_event_properties: int

    #: The two smaller replay passes' tables: destroyed tiles and the
    #: silent, offscreen event tiles.
    overworld_destroy_events: int
    overworld_destroy_locations: int
    overworld_destroy_before: int
    overworld_destroy_top: int
    overworld_destroy_bottom: int
    overworld_silent_tiles: int
    overworld_silent_layers: int
    overworld_silent_locations: int
    overworld_silent_tile_numbers: int

    #: The sprite slot table: 13 slots of (number, X, Y), read at title load.
    overworld_sprite_slots: int

    #: Which maps show each sprite number: one disable-bits byte per number.
    overworld_sprite_submap_disable: int

    #: Where a submap draws its copy of a ghost, relative to the main map:
    #: three signed words each, for the last three slots.
    overworld_sprite_boo_x_offsets: int
    overworld_sprite_boo_y_offsets: int

    #: Where the smoke draws on each map: one absolute word each per map,
    #: written over its slot's position every frame.
    overworld_sprite_smoke_x_positions: int
    overworld_sprite_smoke_y_positions: int

    #: The Layer 2 loader's JSL-able wrapper -- what the replay cross-check
    #: drives to make the game build and stamp the buffer itself.
    overworld_layer2_loader: int

    #: The overworld Layer 2 tilemap's two LC_RLE2 streams. Read out of the
    #: image and decoded by the capture, because the game only decompresses
    #: them when a save file is loaded.
    overworld_layer2_tiles: int
    overworld_layer2_properties: int

    #: The routines a rebuild and a sprite probe are driven through.
    begin_loading_level_data: int
    initialize_level_layer3: int
    process_sprites: int
    init_sprite_tables: int

    #: The player's drawing routine, as a half-open range.
    player_gfx_start: int
    player_gfx_end: int

    #: The one patch site rather than a table: the ``LDA #$07`` that supplies
    #: every level's sprite-data bank.
    sprite_bank_instruction: int

    #: The two branches in ``SpecifySublevelToLoad`` that decide which levels
    #: ``$7E0109`` can name -- see :func:`level_request_bytes`.
    level_override_branch: int
    level_adjust_branch: int

    #: Where the cartridge keeps every colour in the game: the global palette
    #: table as the ROM map placed it. What each of its 1009 colours *is* comes
    #: from the bundled catalog and is the same on every base, because it is an
    #: offset into the table; where the table sits is this, and it moves in
    #: every target -- see :mod:`shiny_mushroom.palettes`.
    global_palettes: int

    #: The two runs of colour the global table does not hold: eight fade steps
    #: apiece for a Magikoopa and the Big Boo Boss, in bank ``$03`` beside the
    #: sprites that use them. The editor edits them alongside the global
    #: table's colours, so each needs its own address for the same reason --
    #: and neither moves between targets.
    magikoopa_fade_palettes: int
    boo_fade_palettes: int

    #: The translevel-remap table, one word per translevel -- the
    #: ``translevel-remap`` feature's own, and ``None`` on every cartridge
    #: without it: the stock game computes its level numbers instead, so
    #: there is no table to patch. Optional where every field above is not,
    #: because those are the stock cartridge's facts and this one is a
    #: feature's.
    overworld_translevel_levels: int | None = None

    @classmethod
    def of(
        cls,
        base: RomBase,
        target_id: str | None = None,
        overrides: Mapping[str, int] | None = None,
        counts: Mapping[str, int] | None = None,
    ) -> Addresses:
        """Resolve every address above out of ``base``, for one target's build.

        :meth:`~smw_tools.bases.RomBase.at` raises for a role the base does not
        declare -- or a target it does not have -- rather than answering
        ``None``, so a base that is missing one fails here, at the moment it
        is chosen, instead of patching offset zero somewhere far away.
        ``target_id`` matters because version conditionals move tables: the
        ``J`` build lands most of bank 4 two bytes on, and a capture reading
        the ``U`` addresses off a ``J`` cartridge is two bytes wrong about
        every one of them. ``None`` reads as the default target, which is all
        a cartridge of unknown provenance can claim.

        ``overrides`` is one cartridge's own answer, by role -- the addresses
        the project's build resolved from its symbol file, which is the record
        of where *that* build put each table rather than where the base
        declares the stock one does. A role absent from it reads through the
        declaration; see :func:`shiny_mushroom.build.role_addresses`.

        ``counts`` is the same cartridge's answer for how many entries its
        growable tables hold -- measured off the same symbol file, since a
        table whose scan follows its rows declares its count nowhere; see
        :func:`shiny_mushroom.build.role_counts`. A role absent from it reads
        the registry's declared count, which is the stock cartridge's.
        """

        def at(role: str) -> int:
            if overrides is not None and role in overrides:
                return overrides[role]
            return base.at(role, target_id)

        # A role whose label the target's build does not assemble -- the
        # level-name offset tables on `J` -- has no address to carry; readers
        # of the version-forked roles ask with `.get` and take the absence.
        roles = {
            role: at(role)
            for role, table in base.tables.items()
            if (overrides is not None and role in overrides)
            or table.assembled_for(target_id)
        }
        return cls(
            base=base,
            map=base.address_map,
            ram=base.ram_map,
            sprite_header_build_owned=base.sprite_header_build_owned,
            driven=base.driven,
            traced=base.traced,
            roles=roles,
            counts={
                **{
                    role: count
                    for region in asm_regions.regions(base).values()
                    for role, count in region.entry_counts().items()
                },
                **dict(counts or {}),
            },
            overreads={
                role: region.overread
                for region in asm_regions.regions(base).values()
                if region.overread
                for role in region.scanned_sections
            },
            layer1_pointers=roles["layer1_pointers"],
            layer2_pointers=roles["layer2_pointers"],
            sprite_pointers=roles["sprite_pointers"],
            secondary_header_y=roles["secondary_header_scroll_and_entrance_y"],
            secondary_header_x=roles["secondary_header_layer3_and_entrance_x"],
            secondary_header_fg_position=roles["secondary_header_initial_camera_y"],
            secondary_header_entrance=roles[
                "secondary_header_intro_and_entrance_screen"
            ],
            secondary_entrance_destination=roles[
                "secondary_entrance_destination_level"
            ],
            secondary_entrance_camera_y=roles[
                "secondary_entrance_camera_and_entrance_y"
            ],
            secondary_entrance_x_and_screen=roles[
                "secondary_entrance_entrance_x_and_screen"
            ],
            secondary_entrance_action=roles["secondary_entrance_action"],
            entrance_y_low=roles["entrance_y_low"],
            entrance_y_high=roles["entrance_y_high"],
            entrance_x_low=roles["entrance_x_low"],
            entrance_x_high=roles["entrance_x_high"],
            layer1_initial_y=roles["layer1_initial_y"],
            layer2_initial_y=roles["layer2_initial_y"],
            l2_vert_scroll_settings=roles["layer2_vertical_scroll_settings"],
            vertical_table=roles["vertical_table"],
            map16_bg_defs=roles["map16_background_definitions"],
            pipe_map16_pointers=roles["pipe_map16_pointers"],
            overworld_level_events=roles["overworld_level_events"],
            overworld_level_names=roles["overworld_level_names"],
            overworld_level_directions=roles["overworld_level_directions"],
            overworld_translevel_levels=roles.get("overworld_translevel_levels"),
            overworld_warp_trigger_columns=roles["overworld_warp_trigger_columns"],
            overworld_warp_trigger_rows=roles["overworld_warp_trigger_rows"],
            overworld_warp_landings_x=roles["overworld_warp_landings_x"],
            overworld_warp_landings_y=roles["overworld_warp_landings_y"],
            overworld_exit_triggers=roles["overworld_exit_triggers"],
            overworld_exit_landings=roles["overworld_exit_landings"],
            overworld_exit_landing_cells=roles["overworld_exit_landing_cells"],
            initial_level_flags=roles["initial_level_flags"],
            overworld_map16_defs=roles["overworld_map16_definitions"],
            overworld_layer1_tilemap=roles["overworld_layer1_tilemap"],
            overworld_event_tile_entries=roles["overworld_event_tile_entries"],
            overworld_event_pointers=roles["overworld_event_pointers"],
            overworld_event_layer1_locations=roles["overworld_event_layer1_locations"],
            overworld_event_layer1_from=roles["overworld_event_layer1_from"],
            overworld_event_layer1_to=roles["overworld_event_layer1_to"],
            overworld_event_tiles=roles["overworld_event_tiles"],
            overworld_event_properties=roles["overworld_event_properties"],
            overworld_destroy_events=roles["overworld_destroy_events"],
            overworld_destroy_locations=roles["overworld_destroy_locations"],
            overworld_destroy_before=roles["overworld_destroy_before"],
            overworld_destroy_top=roles["overworld_destroy_top"],
            overworld_destroy_bottom=roles["overworld_destroy_bottom"],
            overworld_silent_tiles=roles["overworld_silent_tiles"],
            overworld_silent_layers=roles["overworld_silent_layers"],
            overworld_silent_locations=roles["overworld_silent_locations"],
            overworld_silent_tile_numbers=roles["overworld_silent_tile_numbers"],
            overworld_sprite_slots=roles["overworld_sprite_slots"],
            overworld_sprite_submap_disable=roles["overworld_sprite_submap_disable"],
            overworld_sprite_boo_x_offsets=roles["overworld_sprite_boo_x_offsets"],
            overworld_sprite_boo_y_offsets=roles["overworld_sprite_boo_y_offsets"],
            overworld_sprite_smoke_x_positions=roles[
                "overworld_sprite_smoke_x_positions"
            ],
            overworld_sprite_smoke_y_positions=roles[
                "overworld_sprite_smoke_y_positions"
            ],
            overworld_layer2_loader=roles["overworld_layer2_loader"],
            overworld_layer2_tiles=roles["overworld_layer2_tiles"],
            overworld_layer2_properties=roles["overworld_layer2_properties"],
            begin_loading_level_data=roles["begin_loading_level_data"],
            initialize_level_layer3=roles["initialize_level_layer3"],
            process_sprites=roles["process_sprites"],
            init_sprite_tables=roles["init_sprite_tables"],
            player_gfx_start=roles["player_gfx_start"],
            player_gfx_end=roles["player_gfx_end"],
            sprite_bank_instruction=roles["sprite_bank_instruction"],
            level_override_branch=roles["level_override_branch"],
            level_adjust_branch=roles["level_adjust_branch"],
            global_palettes=roles["global_palettes"],
            magikoopa_fade_palettes=roles["magikoopa_fade_palettes"],
            boo_fade_palettes=roles["boo_fade_palettes"],
        )

    @classmethod
    def for_base(
        cls,
        base_id: str | None = None,
        target_id: str | None = None,
        overrides: Mapping[str, int] | None = None,
        features: Iterable[str] = (),
        counts: Mapping[str, int] | None = None,
        rom_size: str | None = None,
    ) -> Addresses:
        """The addresses of the base with this id, or the default base's --
        for ``target_id``'s build, or the default target's, with ``overrides``
        read in preference to either, and ``counts`` over the registry's
        declared entry counts; see :meth:`of`.

        ``features`` are the capabilities the *cartridge* has beyond the stock
        game -- see :mod:`smw_tools.features`. They amend the base before
        anything is resolved, so a feature that moved a table, the traced code
        or the RAM map is answered for by every field at once. Empty is the
        stock base, which is what a cartridge opened by hand is read as; a
        project's own set comes from its build's record
        (:attr:`shiny_mushroom.project.Project.features`).

        ``rom_size`` is **how long that cartridge is**, as a
        :mod:`smw_tools.rom_sizes` id, and it travels with the features
        because it is the same kind of fact: a feature that uses an expansion
        bank where the cartridge has one is read at one address on a 1 MB
        cartridge and another on a 512 KB one
        (:attr:`smw_tools.features.Feature.bank_rom_size`). ``None`` is the
        base's stock size, which is what a build assembles when nobody has
        said. A caller holding the image can read the answer off it --
        :func:`smw_tools.rom_sizes.size_for` over its length -- and one
        holding a project takes its build's record
        (:attr:`shiny_mushroom.project.Project.rom_size_built`).
        """
        return cls.of(
            applied(rom_base(base_id), features, rom_size),
            target_id,
            overrides,
            counts,
        )

    @classmethod
    def for_rom(
        cls,
        rom: Path,
        base_id: str | None = None,
        target_id: str | None = None,
        overrides: Mapping[str, int] | None = None,
        features: Iterable[str] = (),
        counts: Mapping[str, int] | None = None,
    ) -> Addresses:
        """:meth:`for_base`, with the cartridge's size read off ``rom`` itself.

        For a caller that has the image rather than a record of it -- the
        emulator worker, which is handed a path and nothing that says how long
        it is. The file's length is the one answer that cannot be stale, and
        it is right for a ROM opened by hand as well as for a project's own
        build. A file that cannot be measured is read as the base's stock
        size, which is what saying nothing already means.
        """
        try:
            length = rom.stat().st_size
        except OSError:
            length = 0
        return cls.for_base(
            base_id,
            target_id,
            overrides,
            features,
            counts,
            size_for(length, rom_base(base_id).sizes),
        )

    def offset(self, address: int) -> int:
        """Translate a CPU address to an offset in the headerless image."""
        return self.map.offset(address)

    def address(self, offset: int) -> int:
        """Translate an offset in the headerless image back to a CPU address."""
        return self.map.address(offset)

    @property
    def bank_size(self) -> int:
        """How many bytes of the image one CPU bank reaches."""
        return self.map.bank_size

    @property
    def addressable(self) -> int:
        """How many bytes of the image this base's banks can spell an address
        for. An image may be longer -- SA-1's banks stop at 2 MB and its chip
        reaches the rest another way -- and bytes past this bound cannot be
        pointed at."""
        return self.map.addressable

    def at(self, offset: int) -> tuple[MemoryType, int]:
        """One work-RAM location, as the arguments a core read or write takes.

        ``core.read(*where.at(GAME_MODE))`` is the whole idiom, and it is the
        only way this module reaches RAM -- there is no path left that names
        ``SNES_WORK_RAM`` and an offset together, because on a base with a
        coprocessor that pair is a byte of the right number from the wrong
        memory.
        """
        found = self.ram.place(offset)
        return SPACES[found.space], found.offset

    def landing(self, offset: int) -> int:
        """One work-RAM location, as **16 bits of a CPU address** in any bank
        the low mirror or the BW-RAM window reaches.

        :meth:`at` answers where a *core* reads a byte; this answers what a
        65816 instruction would have to spell to reach it, which is a different
        question with a different answer on a base that moved the memory. The
        rebuild's call chain needs both: it writes its blocks through
        :meth:`at` and pushes their addresses as operands through this.

        Sixteen bits and no bank, because the caller's bank is what makes it
        reachable: banks ``$00``-``$3F`` mirror the low 8 KB of work RAM at
        ``$0000``-``$1FFF`` and window BW-RAM at ``$6000``-``$7FFF``, so a
        routine in any of them reaches either without touching the program
        bank.

        Raises for a location in neither -- I-RAM, or BW-RAM past the window's
        first 8 KB -- which is a byte no instruction can name this way rather
        than one this could answer for with a longer address.
        """
        found = self.ram.place(offset)
        windowed = window_address(found)
        if windowed is not None:
            return windowed
        reached = cpu_address(found) & 0xFFFF
        if reached >= LOW_RAM_MIRROR:
            raise ValueError(
                f"${offset:05X} is at {found.space.name} ${found.offset:05X} on "
                f"the {self.ram.id} map, which no bank reaches in 16 bits"
            )
        return reached

    def slot(self, table: int, slot: int) -> tuple[MemoryType, int]:
        """One sprite slot table entry, as a core read or write takes it.

        Separate from :meth:`at` because a base with More Sprites has 22 slots
        where vanilla has 12, so the last ten have no vanilla offset to name --
        see :meth:`smw_tools.ram_map.RamMap.slot`.
        """
        found = self.ram.slot(table, slot)
        return SPACES[found.space], found.offset

    @property
    def direct_page(self) -> int:
        """What ``D`` has to hold to drive one of this base's routines."""
        return self.ram.direct_page

    @property
    def sprite_slots(self) -> int:
        """How many sprite slots this base's engine has."""
        return self.ram.sprite_slots


#: The default base's addresses.
#:
#: **What a caller with no project uses, and nothing more.** A cartridge opened
#: by hand has no base to speak of, and the five shipped releases are one base
#: anyway; anything that *has* a project resolves through
#: :meth:`Addresses.for_base` instead, because that is the one thing a project
#: records which these cannot know.
#:
#: The resolver functions below take ``where`` by keyword with no default, so
#: even a caller that means this one -- a test, mostly -- says
#: ``where=DEFAULT_ADDRESSES`` at the call site. A missed base is then a
#: ``TypeError`` there rather than a silent read through the wrong tables.
DEFAULT_ADDRESSES = Addresses.for_base()

#: Every module constant below is this base's. They are named because the prose
#: that explains what each table *is* has to live somewhere, and beside the mask
#: read out of it is where it belongs -- see :class:`Addresses`.


# -- work RAM, as offsets into the 128 KB array ($7E0000 is 0) ---------------

#: ``$7E0100``. The game-mode state machine's current state.
GAME_MODE = 0x000100

#: ``$7E0109``. Named IntroLevelFlag, but SpecifySublevelToLoad checks it before
#: anything else and a non-zero value *is* the sublevel to load, bypassing the
#: overworld-tile lookup. The routine then applies ``CMP #$25 / SEC / SBC #$24``,
#: which is why the disassembly writes level IDs as ``($C7+$24)``.
INTRO_LEVEL_FLAG = 0x000109

#: ``$7E141A``. Non-zero sends SpecifySublevelToLoad down the screen-exit path,
#: where it ignores the override above. Must be cleared for every request.
SUBLEVELS_ENTERED = 0x00141A

#: ``$7E0101``. The graphics upload cache: which file each of the eight VRAM
#: slots holds -- the four sprite slots, then the four layer slots at
#: ``$7E0105``. ``SMW_UploadGraphicsFiles`` compares a slot's wanted file
#: against its entry and skips the upload when they agree, which is what makes
#: a warm load cheap and what would hide a patched file behind the unpatched
#: one a savestate already expanded into VRAM. :data:`NO_GRAPHICS_FILE` is a
#: "holds nothing" no layout reads as a file: the stock game's own sentinel is
#: ``$80``, which the Mode 7 boss path writes so every slot uploads again next
#: time, but under the managed graphics ``$80`` is a file number and the
#: sentinel moves to ``$FF`` -- which no stock level asks for either, so a
#: patched load writes that on both layouts.
LOADED_GRAPHICS_FILES = 0x000101
GRAPHICS_SLOTS = 8
NO_GRAPHICS_FILE = 0xFF

#: ``$05F600``, the fourth secondary-header table: one byte per level, bit 7 of
#: which disables the level's **entrance room**.
#:
#: SpecifySublevelToLoad replaces the level's own Layer 1 pointer with one of six
#: built-in doorway rooms -- ghost house, castle, the three no-Yoshi entrances --
#: whenever the level's tileset is one of ``$05 $01 $02 $06 $08``, no sublevel
#: has been entered, and this bit is clear. All three hold for a request made the
#: way this module makes one, so a quarter of the cart's levels would load a
#: small doorway instead of themselves: the tilemap is the entrance's, the
#: tileset is the entrance's, and patching the level's object stream changes
#: nothing because it was never read.
#:
#: Setting the flag in work RAM does not help -- the same routine writes it from
#: this table a few instructions earlier -- so the bit is set in the cartridge
#: image for the duration of the load, and taken back out with the rest of the
#: preview afterwards. It decides which room the *player* walks into first, and
#: an editor wants the level.
SECONDARY_HEADER_ENTRANCE = DEFAULT_ADDRESSES.secondary_header_entrance
NO_ENTRANCE_ROOM = 0x80

#: The rest of that same byte: the level's **primary entrance screen**, and the
#: coarse half of where the player starts.
ENTRANCE_SCREEN = 0x1F

#: The other two secondary-header tables the entrance is spread across. The low
#: nybble of ``$05F000``'s entry indexes sixteen Y positions, and the low three
#: bits of ``$05F200``'s indexes eight X positions.
SECONDARY_HEADER_Y = DEFAULT_ADDRESSES.secondary_header_y
SECONDARY_HEADER_X = DEFAULT_ADDRESSES.secondary_header_x
ENTRANCE_Y_INDEX = 0x0F
ENTRANCE_X_INDEX = 0x07

#: The position tables themselves, in bank ``$05``: sixteen Y positions as a low
#: and a high byte, then eight X positions the same way.
ENTRANCE_Y_LOW = DEFAULT_ADDRESSES.entrance_y_low
ENTRANCE_Y_HIGH = DEFAULT_ADDRESSES.entrance_y_high
ENTRANCE_X_LOW = DEFAULT_ADDRESSES.entrance_x_low
ENTRANCE_X_HIGH = DEFAULT_ADDRESSES.entrance_x_high

#: The fourth secondary-header table: where the **camera** starts. Bits 2-3 of
#: this level's entry index :data:`LAYER1_INITIAL_Y` and bits 0-1 index
#: :data:`LAYER2_INITIAL_Y`, and the two have to be moved together -- see
#: :func:`camera_patch`.
SECONDARY_HEADER_FG_POSITION = DEFAULT_ADDRESSES.secondary_header_fg_position
FG_POSITION_INDEX = 0x0C
FG_POSITION_SHIFT = 2
L2_POSITION_INDEX = 0x03

#: ``Layer1InitialYPositions``: the four camera Y positions a level can start
#: at, ``$00``, ``$60``, ``$C0``, ``$00``. The loader stores one into
#: ``$7E001C`` as a byte,
#: over a high byte it has already cleared, so in a horizontal level this is the
#: whole camera position.
LAYER1_INITIAL_Y = DEFAULT_ADDRESSES.layer1_initial_y

#: Entries in each of the two initial-Y tables -- ``$00 $60 $C0 $00`` and
#: ``$60 $90 $C0 $00`` -- which is what two bits of a secondary header can index.
INITIAL_Y_POSITIONS = 4

#: ``Layer2InitialYPositions``: Layer 2's four initial Y positions,
#: ``$60 $90 $C0 $00``.
#:
#: Only ever an *input*. ``CODE_00F7BC`` recomputes Layer 2's position from
#: scratch every frame as ``(layer1Y >> shift) + $7E1417``, so the value stored
#: here survives one frame; what it decides is ``$1417``, which is computed from
#: it once during the load and then never again.
LAYER2_INITIAL_Y = DEFAULT_ADDRESSES.layer2_initial_y

#: ``L2VertScrollSettings``: which vertical scroll behaviour Layer 2 has,
#: indexed by the **high** nybble of ``$05F000``'s entry -- the ``%ssss`` of its
#: ``%ssssyyyy``, the same byte whose low nybble indexes the entrance. Sixteen
#: entries, of which the stock cart uses the first eight and holds ``$00`` in
#: the rest; Lunar Magic hijacks that upper half for scroll settings of its own.
L2_VERT_SCROLL_SETTINGS = DEFAULT_ADDRESSES.l2_vert_scroll_settings
L2_SCROLL_SETTINGS = 16

#: How far ``CODE_00A796`` shifts Layer 1's initial Y right before subtracting
#: it from Layer 2's, per that setting. Setting ``0`` is absent because the
#: routine returns without writing ``$1417`` at all, which is the same thing as
#: having no offset to preserve.
#:
#: **These are the load-time routine's shifts and not the frame code's.** The
#: two disagree -- for setting 3 ``CODE_00A796`` shifts three places and
#: ``CODE_00F7AA`` shifts five -- and since what is being preserved here is the
#: value ``CODE_00A796`` computes, this table has to match that one. Copying the
#: frame code's shifts instead reintroduces the drift on exactly the levels
#: where it is smallest and hardest to see.
#:
#: **The largest key is a ceiling, not a limit** -- see
#: :func:`layer2_scroll_shift`.
L2_OFFSET_SHIFT = {1: 0, 2: 1, 3: 3}

#: Where on the screen the game considers itself caught up with the player when
#: it is scrolling up: ``DATA_00F69F``'s first entry, and the line
#: ``SMW_HandleStandardLevelCameraScroll`` walks the camera towards at three
#: pixels a frame. Framing a start here is asking for what the game would
#: eventually settle on rather than inventing a composition.
CAMERA_SETTLED_Y = 0x64

#: The lowest a horizontal level's camera goes -- ``LDA.w #$00C0`` at
#: ``CODE_00F70D``, passed in as the limit for that level's whole scroll.
#:
#: **It is also a switch.** ``SMW_InitializeLevelRAM`` runs
#: ``LDA $1C : CMP #$C0 : BEQ + : INC Flag_EnableVerticalScroll``, so a level
#: whose camera starts anywhere *other* than the bottom has vertical scrolling
#: unlocked for it. That is the whole mechanism behind a level with something
#: above the screen: the camera is pinned at ``$C0`` until either the player
#: flies, swims or climbs, or the level simply did not start there.
CAMERA_LOWEST_Y = 0xC0

#: ``$7E1F11``. Which overworld map the player is on. The routine turns this
#: into the high bit of the 9-bit level number, so it selects $000-$0FF or
#: $100-$1FF.
MARIO_MAP = 0x001F11

#: ``$7EC800`` / ``$7FC800``. The Map16 tilemap: one 16x16 tile number per
#: entry, split low byte and high byte across the two banks. This is the level.
MAP16_LOW = 0x00C800
MAP16_HIGH = 0x01C800
MAP16_SIZE = 0x3800

#: Entries the core's write log holds before flagging overflow. A game-mode
#: load writes the low table once as its buffer fill (0x3800) and the object
#: loop adds a few thousand more, so the ceiling is a comfortable 3x the worst
#: measured -- and an overflow is a fallback to the counters, not an error.
WRITE_LOG_CAPACITY = 0x10000

#: ``$7E0094`` and ``$7E0096``, ``!RAM_SMW_Player_XPosLo`` and ``_YPosLo``, both
#: 16-bit with the ``Hi`` byte above them. The player's position in the level.
#:
#: **Read rather than derived, because the level's own entrance cannot be read
#: any other way that stays right.** A main entrance is two small indices --
#: ``$05F200``'s low three bits choose one of eight X positions and
#: ``$05F000``'s low nybble one of sixteen Y positions, out of tables in bank
#: ``$05`` -- and a vertical level overrides the Y from its own header instead.
#: The loader has already done all of that by the time a capture runs, so these
#: two words are the game's own answer to where the player starts.
PLAYER_X = 0x000094
PLAYER_Y = 0x000096


#: ``$7E0013`` and ``$7E0014``, the global and effective frame counters. Sprite
#: graphics routines index their animation off these, and the disassembly says
#: the effective one is what they usually prefer.
#:
#: Pinned before every probe so a sprite is captured in the same pose whatever
#: frame the load happened to stop on -- the technique smw-editor calls faking
#: the frame counters. Measured, ``$14`` is already the same at every capture
#: and ``$13`` is not, so this only has to move one of them; both are written
#: because which one a given sprite reads is the sprite's business.
FRAME_COUNTER_GLOBAL = 0x000013
FRAME_COUNTER_LOCAL = 0x000014

#: What they are pinned to. Any fixed value gives a reproducible pose; this one
#: is zero because a reader asking "which frame is this sprite drawn on" should
#: get the first.
FRAME_COUNTER_POSE = 0x00


#: ``$7E001A``, 16-bit, with the Y twin immediately after it -- so four
#: consecutive bytes set both.
CAMERA_X = 0x00001A
CAMERA_Y = 0x00001C


# -- rebuilding a level without running the game mode ------------------------
#
# The routines a level load is made of, so an edit can re-run the ones it
# reaches instead of driving the game from mode $11 to $14. Every one of these
# ends in **RTS**, not RTL -- see `SmwLevelLoader._call_chain`.

#: What ``SMW_InitializeLevelData`` fills the Map16 buffer's low half with; the
#: high half is zeroed. Not merely "blank": a merging object routine reads the
#: cell it is about to write and ``SMW_StandardObj13_GroundEdgesAndVine`` tests
#: for this value by name, so the wrong fill changes what objects draw.
EMPTY_MAP16_TILE = 0x25

#: ``SMW_BeginLoadingLevelData``: the header, the Map16 pointer table, and both
#: layers' object loops. The whole of what an object edit changes.
BEGIN_LOADING_LEVEL_DATA = DEFAULT_ADDRESSES.begin_loading_level_data

#: ``SMW_InitializeLevelLayer3``. Not optional even with no Layer 3:
#: GenerateInteractiveTideWater inside it zeroes part of every Layer 2 screen.
INITIALIZE_LEVEL_LAYER3 = DEFAULT_ADDRESSES.initialize_level_layer3

#: Where the rebuild's own code goes: bank ``$7E``, inside the graphics
#: decompression buffer, past the stubs ``MesenCore`` itself uses.
REBUILD_STUB = 0x7E2100

#: The low 8 KB every bank ``$00``-``$3F`` mirrors, which is the half of what
#: :meth:`Addresses.landing` can answer for that is not the BW-RAM window.
LOW_RAM_MIRROR = 0x2000

#: Where an ``RTS`` routine lands, as **work-RAM offsets** resolved per base by
#: :meth:`Addresses.landing`, like every other byte of RAM this module names.
#:
#: A landing has to be reachable in the returning routine's **own** bank, since
#: an ``RTS`` keeps the program bank -- and the loader is in ``$05``. Banks
#: ``$00``-``$3F`` mirror the low 8 KB of work RAM and window BW-RAM's first
#: 8 KB, so a location in either is reachable from bank ``$05`` and bank ``$00``
#: at once, whichever memory the base actually keeps it in.
#:
#: **They are two entries the game's own RAM map calls unused, and that is what
#: makes them safe rather than an argument about the protocol around them.** The
#: block is written where the base keeps the entry, so a base that relocated it
#: relocated the landing: ``sa1`` has the first at BW-RAM ``$166E`` and the
#: second where it assembles, and both are still the bytes nothing reads.
#: Sizes are the reason each is where it is -- ``A`` takes nine bytes and ``B``
#: six.
#:
#: - ``$0017B3`` is ``!RAM_SMW_ShooterSpr_UnusedLevelListIndex``, 8 bytes.
#: - ``$001FD6`` is ``!RAM_SMW_NorSpr_UnusedTable7E1FD6``, 12 bytes.
#:
#: **Not the low ``$1FFA``**, which is what these were before: six bytes there
#: cover the lightning flash colour index, its two timers and the credits
#: background flag, which two routines read and write -- and on ``sa1`` the
#: whole of ``$7E:1F00``-``$1FFF`` is the S-CPU stack, SA-1 Pack initialising
#: ``SP`` to ``$1FFF``. Nothing broke, because a rebuild restores a savestate
#: before writing and clears
#: :attr:`~shiny_mushroom.emu.smw.SmwLevelLoader._game_runnable` after, so no
#: frame of the game ran over what they left; the picture was right and the
#: reason was luck. **Not ``$7E1F00`` either** -- that is the overworld's tile
#: settings, which is real save data.
REBUILD_LANDING_A = 0x001FD6
REBUILD_LANDING_B = 0x0017B3

#: Console cycles a rebuild may spend. The default ten frames is not enough: a
#: Layer 2 level draws both layers' objects and measures ~495k.
REBUILD_BUDGET = 60 * 47_000

#: What ``$4200`` holds while a level is running -- NMI on, auto-joypad on. The
#: loader runs with NMI off and mode ``$11`` opens by clearing it, so a rebuild
#: masks it and puts this back.
NMI_IN_LEVEL = 0x81

#: ``$7E0065``/``$7E0068``, ``!RAM_SMW_Pointer_Layer1DataLo`` and Layer 2's.
#: The object loop walks the first to the end of the stream, so it has to be
#: put back from the cartridge before a second run; the second's bank byte is
#: the "Layer 2 is a background" marker, which a load overwrites.
LAYER1_DATA_POINTER = 0x000065
LAYER2_DATA_POINTER = 0x000068

#: ``$7E1928``, ``!RAM_SMW_Blocks_ScreenToPlaceCurrentObject``. The object
#: loop's screen cursor. ``LoadSublevel`` clears it; the routine below it does
#: not, so a rebuild has to.
SCREEN_TO_PLACE_CURRENT = 0x001928

#: ``$7E13D5``, ``!RAM_SMW_Flag_DisableLayer3Scroll``. Incremented rather than
#: stored by InitializeLevelLayer3's no-Layer-3 path, so repeated rebuilds
#: count it up and wrap.
DISABLE_LAYER3_SCROLL = 0x0013D5


#: ``$7E0FBE``, ``!RAM_SMW_Pointer_Map16Tiles``. 512 16-bit pointers into bank
#: ``$0D``, one per Map16 tile number, built by InitializeMap16Pointers during
#: the load. Which of the six definition tables a tile comes from is decided by
#: a bitmask and by the level's tileset, so resolving it any other way means
#: reimplementing that choice; reading the table the game just built does not.
MAP16_POINTERS = 0x000FBE
MAP16_TILE_COUNT = 512

#: ``$7E005B``, ``!RAM_SMW_Misc_LevelLayoutFlags``. Written by LoadLevelHeader
#: from the level mode. Bit 0 is "Layer 1 is vertical", which is the difference
#: between a 27-row horizontal level and a 32-column vertical one.
LEVEL_LAYOUT_FLAGS = 0x00005B
LAYOUT_LAYER1_VERTICAL = 0x01

#: Where Layer 2's half of the Map16 tilemap starts, by layout: screen ``$10``
#: across, screen ``$0E`` down. Only meaningful when the level's Layer 2 is a
#: *level* rather than a background -- otherwise the region holds whatever the
#: last load left there, plus a tide's collision if the level has one.
LAYER2_REGION_HORIZONTAL = 0x1B00
LAYER2_REGION_VERTICAL = 0x1C00

#: ``$7EB900`` / ``$7EBD00``, ``!RAM_SMW_Blocks_Layer2TilesLo`` / ``...Hi``.
#: Where a Layer 2 *background* is decompressed to: two 16x27 screens of Map16
#: numbers, which then repeat across and down the level. The ``$A0`` bytes past
#: the two screens are filled and never read.
LAYER2_BG_LOW = 0x00B900
LAYER2_BG_HIGH = 0x00BD00
LAYER2_BG_SIZE = 2 * 0x1B0

#: ``$05E600``, three bytes per level, immediately after the Layer 1 table --
#: 512 entries of three bytes each. **A bank byte of ``$FF`` means the level's
#: Layer 2 is a background** rather than an object stream, which is the one
#: thing that decides how Layer 2 has to be read. Resolved from the cartridge
#: like the Layer 1 pointer, so a hack that repoints it is followed.
LAYER2_POINTERS = DEFAULT_ADDRESSES.layer2_pointers
LAYER2_IS_BACKGROUND = 0xFF

#: Level numbers the cartridge's per-level tables have an entry for. Every one
#: of them is indexed by the level number and none of them is bounded by
#: anything else, so this is the stride's companion wherever one is walked.
LEVEL_SLOTS = 0x200

#: ``$0D9100``, ``SMW_Map16Data_Backgrounds``. The Map16 definitions a Layer 2
#: background's tile numbers index -- 512 tiles of eight bytes, shared by every
#: background and every tileset.
#:
#: Read from the cartridge at this fixed address rather than from
#: :data:`MAP16_POINTERS`, and the difference is not a shortcut. The background
#: loader *does* fill all 512 pointer entries with these, but
#: BeginLoadingLevelData rebuilds the table from the tileset immediately
#: afterwards, so by the time a capture happens the pointers are the
#: foreground's -- for a background level as much as for any other. The address
#: is the same in all five ROM maps.
MAP16_BG_DEFS = DEFAULT_ADDRESSES.map16_bg_defs

#: ``$7E1BE3``, ``!RAM_SMW_Misc_LevelLayer3Settings``. ``$00`` no Layer 3,
#: ``$01`` high and low tide, ``$02`` low tide only, ``$03`` a tileset-specific
#: image. What is actually drawn is in VRAM either way; this says whether the
#: level asked for anything.
LAYER3_SETTING = 0x001BE3

#: ``$7E0022`` / ``$7E0024``, the mirrors of the PPU's BG3 scroll registers.
#: Where the loader left Layer 3 -- which is the alignment of its pattern
#: against the top of the level, and the only alignment there is: a tide moves
#: while the level plays.
LAYER3_X = 0x000022
LAYER3_Y = 0x000024

#: ``$7E00CE``, ``!RAM_SMW_Pointer_SpriteListDataLo``. The cart's own resolved
#: pointer to the level's sprite stream. Read from here rather than recomputed
#: from ``Ptrs05EC00`` for the same reason the header is: a hack that repoints
#: it is then followed like any other edit. (The two agree on the stock cart --
#: level ``$105`` resolves to ``$07C4CA`` both ways.)
SPRITE_LIST_POINTER = 0x0000CE

#: Bytes per sprite record, after a one-byte stream header.
SPRITE_RECORD_SIZE = 3

#: Pixels per Map16 block and blocks across a screen, for turning a record's
#: position into the pixel one the machine works in. Restated here rather than
#: imported from :mod:`shiny_mushroom.level`, which imports this module.
BLOCK_PIXELS = 16
SCREEN_BLOCKS = 16

#: A bound on the walk, not a format limit. A pointer that leads to no
#: terminator would otherwise read to the end of the cartridge.
MAX_SPRITE_RECORDS = 512

#: ``$7E0701``, ``!RAM_SMW_Palettes_BackgroundColorLo``. The PPU *fixed* colour,
#: 15-bit. What shows through a transparent pixel is this, not CGRAM colour 0 --
#: which LoadPalette forces to black and nothing ever displays.
BACK_AREA_COLOR = 0x000701

# -- game modes -------------------------------------------------------------

MODE_LOAD_SUBLEVEL = 0x11
MODE_PREPARE_LEVEL = 0x12
MODE_FADE_IN = 0x13
MODE_IN_LEVEL = 0x14

#: The Nintendo Presents display -- seconds long, so a boot poll cannot miss it.
MODE_SHOW_NINTENDO = 0x01

#: The fade out of Nintendo Presents, on the way to the title screen.
MODE_FADE_TO_TITLE = 0x02

#: The title preparation pass. The one reader of the overworld sprite slot
#: table in the whole game, which is why the pre-title anchor sits before it:
#: restored past this mode, a patched slot table is dead bytes.
MODE_PREPARE_TITLE = 0x04

#: Modes the title screen sits in once the boot sequence is over.
TITLE_MODES = frozenset({0x06, 0x07})

#: The four bytes every fade in the game is driven by.
#:
#: There is one fade routine, ``GameModeXX_FadeInOrOut``, and fifteen game modes
#: are it: every *other* frame it steps the brightness mirror ``$0DAE`` by one
#: and hands over to the next game mode when it lands, which is fifteen steps --
#: **thirty frames** -- across the brightness range. ``$0DB1`` is the
#: every-other-frame timer, and ``$0DAF`` is which way it is going.
#:
#: Winding those to their last step is what turns a thirty-frame wait into a
#: one-frame one, and the game's own routine still makes the handover: nothing
#: writes the mode, so what changes is when the fade ends, not what ends it.
#: See :meth:`SmwLevelLoader._wind_fade_forward`.
SCREEN_BRIGHTNESS_MIRROR = 0x000DAE
MOSAIC_DIRECTION = 0x000DAF
MOSAIC_MIRROR = 0x000DB0
KEEP_MODE_TIMER = 0x000DB1

#: Which way a fade is going, as ``$0DAF`` holds it, and what each direction is
#: one step short of. A fade *in* adds ``$01`` to the brightness and stops at
#: ``$0F``; a fade *out* subtracts one and stops at ``$00``. The mosaic steps the
#: other way in ``$10``s, so the pair meet at both ends -- ``$00`` for a level
#: that is up and ``$F0`` for one being left.
FADE_IN = 0x00
FADE_OUT = 0x01
BRIGHTNESS_LAST_STEP = {FADE_IN: 0x0E, FADE_OUT: 0x01}
MOSAIC_LAST_STEP = {FADE_IN: 0x10, FADE_OUT: 0xE0}

#: The two fades on the way into a level, and the one on the way onto the
#: overworld -- the three the editor waits behind. ``$0F`` is only reached by a
#: run that came from the map, which a test run does not; it is named because
#: the mosaic it leaves is what ``$13`` unwinds.
MODE_FADE_OUT_TO_LEVEL = 0x0F
MODE_FADE_IN_TO_OVERWORLD = 0x0D

#: The game modes that *are* the fade routine, off the pointer aliases at the
#: end of it. Two of them enter at ``MosaicFade``, which steps the mosaic mirror
#: alongside the brightness; the rest enter at ``Main``, which steps the
#: brightness alone -- and so must have their mosaic left where it is, since
#: both paths write ``$2106`` from that mirror every step.
MOSAIC_FADE_MODES = frozenset({MODE_FADE_OUT_TO_LEVEL, MODE_FADE_IN})
PLAIN_FADE_MODES = frozenset(
    {
        MODE_FADE_TO_TITLE,
        0x05,  # fade in to the title screen
        0x0B,  # fade out to the overworld
        MODE_FADE_IN_TO_OVERWORLD,
        0x15,  # and the nine the editor never reaches: the death message,
        0x18,  # the castle cutscene, the credits, Yoshi's house, the enemy
        0x1A,  # rollcall and the ending. Listed because what makes this set
        0x1C,  # right is that it is the routine's own list, not a shortlist
        0x1E,  # of the ones something happens to wait on today.
        0x20,
        0x22,
        0x24,
        0x26,
    }
)
FADE_MODES = MOSAIC_FADE_MODES | PLAIN_FADE_MODES

#: Whole frames :meth:`CartSession.reanchor_title` steps before saving the
#: moved anchor: enough for whatever the old anchor caught mid-air -- a
#: handler's tail, a transition already decided -- to finish, and few enough
#: to stay near the title's arrival. Deliberately small: anchoring a second
#: *later* was tried and made things worse -- by then the title music is
#: playing, every NMI runs an SPC exchange, and the probes that hijack the
#: machine between frames wedge in that handshake far more often than they
#: do at the quiet moment the title first appears.
TITLE_REANCHOR_FRAMES = 4

# -- cartridge --------------------------------------------------------------

#: ``$05E000``, three bytes per level, indexed by the 9-bit level number.
LAYER1_POINTERS = DEFAULT_ADDRESSES.layer1_pointers

#: ``$05EC00``, ``SMW_SpecifySublevelToLoad_SpriteDataPtrs``. **Two** bytes per
#: level, not three: the bank is not in the table at all, because sprite data is
#: always in bank ``$07`` and the loader supplies it.
#:
#: This is the same pointer :data:`SPRITE_LIST_POINTER` holds after a load, and
#: the two are read for different jobs rather than one being a shortcut. A
#: snapshot follows the *loaded* pointer, so a cart that repoints it while
#: running is obeyed; reading a level nothing has loaded has only the table.
SPRITE_POINTERS = DEFAULT_ADDRESSES.sprite_pointers

#: ``$05D8F5``, the instruction in ``SpecifySublevelToLoad`` that supplies the
#: **bank** of every level's sprite data -- which the pointer table above does
#: not carry:
#:
#: ```
#: LDA.b #SMW_SpriteDataBank>>16    ; A9 07
#: STA.b !RAM_SMW_Pointer_SpriteListDataBank   ; 85 D0
#: ```
#:
#: So the bank is a **byte of the ROM**, and reading it there rather than
#: assuming ``$07`` is what follows a hack that moved sprite data out of bank
#: ``$07``. The disassembly labels this site
#: ``LM100Hijack_RemoveHardcodedSpriteListBank``: it is where Lunar Magic patches
#: to lift that limit, so it is the one place worth reading.
#:
#: The address is the same in all five ROM maps -- ``SpecifySublevelToLoad`` is
#: placed at ``$05D708`` in every one of them -- and the four bytes below were
#: read back from all five shipped cart dumps to confirm it.
SPRITE_BANK_INSTRUCTION = DEFAULT_ADDRESSES.sprite_bank_instruction

#: What that site looks like when it is still the game's own code: ``LDA``
#: immediate, the bank, then ``STA`` direct page ``$D0``
#: (``!RAM_SMW_Pointer_SpriteListDataBank``). Checked before the operand is
#: believed, because the operand is only a bank while the instruction around it
#: is still this one -- see :func:`sprite_data_bank`.
SPRITE_BANK_OPCODE = 0xA9
SPRITE_BANK_STORE = (0x85, 0xD0)
SPRITE_BANK_LENGTH = 4

#: ``$058417``, ``VerticalTable``: one screen-mode byte per level mode, which is
#: what game mode ``$12`` writes into ``!RAM_SMW_Misc_LevelLayoutFlags``. Bit 0
#: is "Layer 1 is vertical" -- the same bit :data:`LAYOUT_LAYER1_VERTICAL` names
#: in the loaded machine's copy.
#:
#: Read from the cartridge rather than hardcoded so a hack that retunes a level
#: mode is followed. The header's own bits do not answer this: the level mode is
#: an index, and this is the table it indexes.
VERTICAL_TABLE = DEFAULT_ADDRESSES.vertical_table

#: Entries in it: the level mode is header byte 1's low five bits.
LEVEL_MODE_COUNT = 0x20

#: A bound on the walk, not a format limit -- the same guard the sprite stream
#: gets, for the same reason.
MAX_OBJECT_RECORDS = 2048

#: Bank ``$0D`` holds every Map16 definition table. MAP16_POINTERS' entries are
#: bare 16-bit offsets, so this is the bank they are relative to.
MAP16_BANK = 0x0D0000

#: Eight bytes per Map16 tile: four 16-bit SNES tilemap entries, in the order
#: upper-left, lower-left, upper-right, lower-right.
MAP16_DEF_SIZE = 8

#: The eight Map16 tiles a pipe is built out of, and the one place where the
#: definitions a level is drawn from are **not** the ones the loader resolved.
#:
#: ``SMW_CalculateRowOrColumnOfTilemapToUpdate`` re-points these eight entries
#: of :data:`MAP16_POINTERS` before every column of Map16 blocks it turns into
#: tilemap words, choosing between four tables off the number of the column
#: being buffered -- ``LDA column : LSR #3 : AND #$0006`` into
#: ``PipeMap16Ptrs``. So a pipe's colour is a function of *where in the level
#: it stands*, one table per screen, cycling every four screens; and a capture
#: of the pointer table holds whichever colour the last column buffered before
#: it happened to ask for. Which is why the four tables are carried whole in
#: :attr:`LevelSnapshot.pipe_definitions` and the choice is made again when the
#: level is drawn -- see :func:`shiny_mushroom.level.pipe_table`.
#:
#: Vertical levels keep the loader's answer: the branch that sets the pointers
#: is on the horizontal arm of that routine and the vertical one jumps past it.
PIPE_TILES = range(0x133, 0x13B)

#: How many tables ``PipeMap16Ptrs`` holds, in the order the column picks them:
#: the level's own "variable" colour, green, yellow, purple.
PIPE_TABLES = 4


def _read_word(image, at: int) -> int:
    """The 16-bit little-endian value at ``at``, low byte first.

    ``image`` is anything indexable by byte -- the cartridge image, or a
    :class:`RamView` over the machine's memories.
    """
    return image[at] | (image[at + 1] << 8)


def _read_long(image, at: int) -> int:
    """The 24-bit little-endian value at ``at``, low byte first.

    How the cartridge spells a long address wherever it keeps one: a
    pointer-table entry, and the direct-page copy the loader makes of it.
    """
    return _read_word(image, at) | (image[at + 2] << 16)


class RamView:
    """The game's RAM, read once and indexed by **vanilla** work-RAM offset.

    A capture wants a dozen slices out of the game's state, and the cheap way to
    get them is one bulk copy rather than a round trip per byte. On the vanilla
    base that is a single ``read_all`` of work RAM and the slices are plain
    indexing, which is what this replaced and what it still costs there.

    On a base with a coprocessor the same dozen slices come from two or three
    memories, and *which* is a property of the offset. So the memories are read
    once each, lazily -- a base whose Layer 2 buffers are the only thing left in
    work RAM does not pay for 128 KB of it unless something asks -- and every
    caller goes on naming bytes the way the disassembly's RAM map does.

    Read-only and a snapshot: it is the machine as it was when first asked, and
    nothing here writes back. A caller that needs the current value of something
    it has already read is looking at a different moment and should say so.
    """

    def __init__(self, core: MesenCore, where: Addresses) -> None:
        self._core = core
        self._where = where
        self._held: dict[MemoryType, bytes] = {}

    def _memory(self, memory: MemoryType) -> bytes:
        held = self._held.get(memory)
        if held is None:
            held = self._held[memory] = self._core.read_all(memory)
        return held

    def __getitem__(self, offset: int) -> int:
        memory, at = self._where.at(offset)
        return self._memory(memory)[at]

    def slice(self, offset: int, size: int) -> bytes:
        """``size`` bytes from ``offset``, refusing a run split across memories.

        :meth:`~smw_tools.ram_map.RamMap.region` is what refuses: a slice that
        began in one memory and ended in another would come back the right
        length with the wrong bytes in it, which is precisely the failure a RAM
        map exists to prevent.
        """
        found = self._where.ram.region(offset, size)
        memory = SPACES[found.space]
        return self._memory(memory)[found.offset : found.offset + size]

    def slots(self, table: int) -> bytes:
        """Every slot of the sprite table based at vanilla ``table``.

        Not :meth:`slice`, because a sprite table is the one thing that
        **grows** rather than merely moving. Under More Sprites it has 22
        entries and the tables sit adjacent, so only the first twelve have a
        vanilla offset and a run named by ``table`` would end inside the next
        table -- which is exactly what :meth:`slice` refuses, and refusing it
        is right. Asked slot by slot through
        :meth:`~shiny_mushroom.addresses.Addresses.slot` instead, which is the
        only spelling the last ten have.

        Still one read per memory, because the memories are held: the whole
        table comes out of the same snapshot however many slots the base has.
        """
        return bytes(
            self._memory(memory)[at]
            for memory, at in (
                self._where.slot(table, slot)
                for slot in range(self._where.sprite_slots)
            )
        )

    def word(self, offset: int) -> int:
        """The 16-bit little-endian value at ``offset``."""
        return int.from_bytes(self.slice(offset, 2), "little")
