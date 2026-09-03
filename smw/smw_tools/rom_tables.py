"""Where a base keeps the tables and routines an editor has to reach.

Reading a level out of a cartridge means knowing where the pointer tables are,
where the secondary header is, and which routines the loader can be driven
through. Those are **facts about a ROM base**, not about the editor -- a base
that keeps the game and moves the code answers every one of them differently --
so they are declared here rather than written as literals wherever they are used.

Each entry carries both halves of the answer:

``label``
    The name the assembler resolves. This is the durable half: a table can move
    to a different address in a restructured base and keep its name, and the
    build's own symbol file is what turns the name back into an address.
``address``
    Where it landed in *this* base's **default target**. Held rather than
    resolved so that nothing needs a symbol file to run -- a symbol file is a
    build artifact, and the emulator worker must not depend on one having been
    produced.
``per_target``
    Where the other targets put it, for the tables that move. Version
    conditionals shift bytes -- the ``J`` build lands most of bank 4 two bytes
    on, the PAL pair moves bank 5's front -- so an address is a fact about a
    *target*, and a reader that knows its cartridge's target resolves through
    :meth:`RomTable.address_for`.

**The literals are cross-checked, not trusted.** ``test_rom_tables.py`` loads
each target's symbol file and asserts every address here -- default and
per-target alike -- is where its label actually is. That is what keeps a
hand-held literal honest: a table that moves, or a label that is renamed,
fails there rather than by rendering a level wrong.

Only ROM addresses belong here. Work RAM is named by the RAM map -- entries like
``!RAM_SMW_Blocks_Layer2TilesLo``, which are ``!Name #= $address`` defines and so
appear in no symbol file -- and a mask, a sentinel or a sprite number is not an
address at all.
"""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass, field
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .symbols import SymbolTable


class RomTableError(Exception):
    """A declared label that one build's symbol file does not know."""


@dataclass(frozen=True)
class RomTable:
    """One table or routine entry point, by name and by address."""

    #: What it is, in the vocabulary of the game rather than of a release.
    role: str

    #: The label the assembler resolves, as it appears in a symbol file.
    label: str

    #: Its 24-bit SNES address in the declaring base's default target.
    address: int

    #: The targets whose build places the label elsewhere, by target id.
    #: Absent means "same as :attr:`address`", which is most tables.
    per_target: Mapping[str, int] = field(default_factory=dict)

    #: The targets whose build does not assemble the label at all -- a version
    #: conditional routes around the branch that defines it, so there is no
    #: address to declare and asking for one is a mistake to refuse rather
    #: than answer. The level-name offset tables are the case: the Japanese
    #: build assembles its own kana tables in their place.
    absent_targets: tuple[str, ...] = ()

    def assembled_for(self, target_id: str | None) -> bool:
        """Whether ``target_id``'s build assembles this label. ``None`` is
        the default target, which assembles everything declared here."""
        return target_id not in self.absent_targets

    def address_for(self, target_id: str | None) -> int:
        """The address in ``target_id``'s build; the default with ``None``."""
        if target_id is None:
            return self.address
        if target_id in self.absent_targets:
            raise RomTableError(
                f"{self.role}: {self.label} is not assembled on target {target_id}"
            )
        return self.per_target.get(target_id, self.address)


def _tables(*rows: tuple) -> dict[str, RomTable]:
    return {row[0]: RomTable(*row) for row in rows}


#: The vanilla base's tables.
#:
#: Every address here was read out of a build and is cross-checked against one.
#: The labels are the disassembly's own, flattened as asar emits them --
#: ``<namespace>_<label>``, which is the spelling a symbol file and an emulator
#: trace both use.
VANILLA_TABLES: dict[str, RomTable] = _tables(
    # -- the three pointer tables a level number resolves through -------------
    (
        "layer1_pointers",
        "SMW_SpecifySublevelToLoad_Layer1DataPtrs",
        0x05E000,
    ),
    (
        "layer2_pointers",
        "SMW_SpecifySublevelToLoad_Layer2DataPtrs",
        0x05E600,
    ),
    (
        "sprite_pointers",
        "SMW_SpecifySublevelToLoad_SpriteDataPtrs",
        0x05EC00,
    ),
    # -- the secondary header, one byte per level each ------------------------
    (
        "secondary_header_scroll_and_entrance_y",
        "SMW_SpecifySublevelToLoad_SecondaryHeader1",
        0x05F000,
    ),
    (
        "secondary_header_layer3_and_entrance_x",
        "SMW_SpecifySublevelToLoad_SecondaryHeader2",
        0x05F200,
    ),
    (
        "secondary_header_initial_camera_y",
        "SMW_SpecifySublevelToLoad_SecondaryHeader3",
        0x05F400,
    ),
    (
        "secondary_header_intro_and_entrance_screen",
        "SMW_SpecifySublevelToLoad_SecondaryHeader4",
        0x05F600,
    ),
    # -- the secondary entrances, one byte per entrance each ------------------
    (
        "secondary_entrance_destination_level",
        "SMW_SpecifySublevelToLoad_SecondaryEntrance1",
        0x05F800,
    ),
    (
        "secondary_entrance_camera_and_entrance_y",
        "SMW_SpecifySublevelToLoad_SecondaryEntrance2",
        0x05FA00,
    ),
    (
        "secondary_entrance_entrance_x_and_screen",
        "SMW_SpecifySublevelToLoad_SecondaryEntrance3",
        0x05FC00,
    ),
    (
        "secondary_entrance_action",
        "SMW_SpecifySublevelToLoad_SecondaryEntrance4",
        0x05FE00,
    ),
    # -- the fixed positions the secondary header indexes into ----------------
    ("entrance_y_low", "SMW_SpecifySublevelToLoad_EntranceYPosLo", 0x05D730),
    ("entrance_y_high", "SMW_SpecifySublevelToLoad_EntranceYPosHi", 0x05D740),
    ("entrance_x_low", "SMW_SpecifySublevelToLoad_EntranceXPosLo", 0x05D750),
    ("entrance_x_high", "SMW_SpecifySublevelToLoad_EntranceXPosHi", 0x05D758),
    (
        "layer1_initial_y",
        "SMW_SpecifySublevelToLoad_Layer1InitialYPositions",
        0x05D708,
    ),
    (
        "layer2_initial_y",
        "SMW_SpecifySublevelToLoad_Layer2InitialYPositions",
        0x05D70C,
    ),
    (
        "layer2_vertical_scroll_settings",
        "SMW_SpecifySublevelToLoad_L2VertScrollSettings",
        0x05D710,
    ),
    # -- level geometry and tile definitions ----------------------------------
    (
        "vertical_table",
        "SMW_LoadLevelHeader_VerticalTable",
        0x058417,
        {"E1": 0x05843C},
    ),
    ("map16_background_definitions", "SMW_Map16Data_Backgrounds", 0x0D9100),
    # The four Map16 definition tables the pipe tiles are swapped between.
    # `$133`-`$13A` are not a property of the level: the routine that turns a
    # column of Map16 blocks into tilemap words re-points those eight tiles
    # before every column it buffers, off the column's own number, so a pipe's
    # colour is a function of where in the level it stands -- see
    # `shiny_mushroom.level.pipe_table`. The four `dw` entries are bare bank
    # `$0D` offsets, in the order the column picks them: variable, green,
    # yellow, purple. Bank $05 code, so the PAL rev 1 build moves it.
    (
        "pipe_map16_pointers",
        "SMW_CalculateRowOrColumnOfTilemapToUpdate_PipeMap16Ptrs",
        0x058776,
        {"E1": 0x05879B},
    ),
    # -- the graphics files a tileset loads --------------------------------
    #
    # The two 26 x 4 lists ``ROUTINE_SMW_UploadGraphicsFiles`` reads a level's
    # eight files out of: a row of four file numbers per tileset, the header's
    # sprite tileset indexing one and its FG/BG tileset the other. Bank $00
    # code, so every version conditional ahead of them moves both together.
    (
        "sprite_gfx_list",
        "SMW_UploadGraphicsFiles_SpriteGFXList",
        0x00A8C3,
        {"J": 0x00A861, "SS": 0x00A8AC, "E0": 0x00A8C8, "E1": 0x00A8CA},
    ),
    (
        "fgbg_gfx_list",
        "SMW_UploadGraphicsFiles_FGAndBGGFXList",
        0x00A92B,
        {"J": 0x00A8C9, "SS": 0x00A914, "E0": 0x00A930, "E1": 0x00A932},
    ),
    # -- overworld tables, indexed by translevel ------------------------------
    (
        "overworld_level_events",
        "SMW_SpecifySublevelToLoad_LevelEventNumbers",
        0x05D608,
    ),
    (
        "initial_level_flags",
        "SMW_InitializeSaveData_InitialLevelFlags",
        0x009EE0,
        {"J": 0x009E7E, "SS": 0x009D99, "E0": 0x009EE5, "E1": 0x009EE7},
    ),
    (
        "overworld_level_directions",
        "SMW_LoadOverworldLayer1AndEvents_PostClearWalkDirections",
        0x04D678,
    ),
    (
        "overworld_level_names",
        "SMW_LevelNames_Main",
        0x04A0FC,
        {"J": 0x04A040, "SS": 0x04A0DB},
    ),
    # -- what a level-name word is assembled from -----------------------------
    #
    # The strings blob and the three offset tables the international builds'
    # name routine reads: a word's three part indices resolve through the
    # offset tables into the blob. The Japanese build keeps its own blob in
    # the same role but its own kana tables in place of the three -- so those
    # are declared absent there rather than given an address that would read
    # someone else's bytes.
    (
        "overworld_level_name_strings",
        "SMW_UpdateLevelName_LevelNameStrings",
        0x049AC5,
        {"J": 0x049A84, "SS": 0x049AA4},
    ),
    (
        "overworld_level_name_part1",
        "SMW_UpdateLevelName_Part1Offsets",
        0x049C91,
        {"SS": 0x049C70},
        ("J",),
    ),
    (
        "overworld_level_name_part2",
        "SMW_UpdateLevelName_Part2Offsets",
        0x049CCF,
        {"SS": 0x049CAE},
        ("J",),
    ),
    (
        "overworld_level_name_part3",
        "SMW_UpdateLevelName_Part3Offsets",
        0x049CED,
        {"SS": 0x049CCC},
        ("J",),
    ),
    # -- the message boxes ----------------------------------------------------
    #
    # Which level each slot is for, the offset of each slot's text, and the
    # text itself -- three tables SMW_DisplayMessage reads in that order. The
    # Japanese build assembles all three, shorter tables ahead of them moving
    # each eight bytes down; the region that edits the text refuses that
    # target on the format of the text, not on the address.
    (
        "level_message_levels",
        "SMW_DisplayMessage_MessageLevels",
        0x05A590,
        {"J": 0x05A588},
    ),
    (
        "level_message_pointers",
        "SMW_DisplayMessage_MessagePointers",
        0x05A5A7,
        {"J": 0x05A59F},
    ),
    (
        "level_message_text",
        "SMW_DisplayMessage_MessageText",
        0x05A5D9,
        {"J": 0x05A5D1},
    ),
    # -- the overworld's star/pipe warps and path exits -----------------------
    #
    # Both transfers are keyed on the player's position, not on the tile. The
    # warp tables are 27 parallel entries: trigger grid column with the submap
    # in the high byte, trigger grid row, landing pixel X with the submap in
    # bits 9-12, landing pixel Y. The exit tables are 14 entries: trigger and
    # landing as (pixel Y, pixel X, submap) records, plus the landing's
    # (grid row, grid column) pair. Editable through `asm_regions`.
    (
        "overworld_warp_trigger_columns",
        "SMW_HandleOverworldStarPipeWarp_TriggerColumnAndMap",
        0x048431,
        {"SS": 0x048422},
    ),
    (
        "overworld_warp_trigger_rows",
        "SMW_HandleOverworldStarPipeWarp_TriggerRow",
        0x048467,
        {"SS": 0x048458},
    ),
    (
        "overworld_warp_landings_x",
        "SMW_HandleOverworldStarPipeWarp_LandingXAndMap",
        0x04849D,
        {"SS": 0x04848E},
    ),
    (
        "overworld_warp_landings_y",
        "SMW_HandleOverworldStarPipeWarp_LandingY",
        0x0484D3,
        {"SS": 0x0484C4},
    ),
    (
        "overworld_exit_triggers",
        "SMW_HandleOverworldPathExits_TriggerPositions",
        0x049964,
        {"J": 0x049923, "SS": 0x049943},
    ),
    (
        "overworld_exit_landings",
        "SMW_HandleOverworldPathExits_LandingPositions",
        0x0499AA,
        {"J": 0x049969, "SS": 0x049989},
    ),
    (
        "overworld_exit_landing_cells",
        "SMW_HandleOverworldPathExits_LandingCells",
        0x0499F0,
        {"J": 0x0499AF, "SS": 0x0499CF},
    ),
    # -- the overworld's Map16 definitions, indexed by tile number ------------
    #
    # The game's own display path names this table directly with a long
    # pointer rather than going through the Map16 pointer table, which is why
    # a capture reads it here rather than following pointers whose bank the
    # level pipeline would guess wrong.
    (
        "overworld_map16_definitions",
        "SMW_Map16Data_OverworldLayer1",
        0x05D000,
    ),
    # -- the overworld's Layer 1 tilemap, block-copied to RAM at load ---------
    #
    # The `$800` bytes the editor's world map edits. Named so a test run can
    # patch the edited map over the image, the same way an edited level
    # reaches a play cart.
    (
        "overworld_layer1_tilemap",
        "SMW_LoadOverworldLayer1AndEvents_Layer1Tilemap",
        0x0CF7DF,
    ),
    # -- the overworld's event system: what each event changes ----------------
    #
    # Pass 1 substitutes single Layer 1 tiles; pass 2 stamps 6x6 or 2x2
    # blocks of 8x8 tiles into the Layer 2 buffer. The editor reads these to
    # replay events for display, and edits them through `asm_regions`, whose
    # fragments keep every one of these labels at the address declared here.
    (
        "overworld_event_tile_entries",
        "SMW_Layer2EventData_TileEntries",
        0x04DD8D,
        {"J": 0x04DD8F},
    ),
    (
        "overworld_event_pointers",
        "SMW_Layer2EventData_Ptrs",
        0x04E359,
        {"J": 0x04E35B},
    ),
    (
        "overworld_event_layer1_locations",
        "SMW_ChangingLayer1OverworldTiles_Layer1TileLocation",
        0x04D85D,
    ),
    (
        "overworld_event_layer1_from",
        "SMW_ChangingLayer1OverworldTiles_TilesThatChange",
        0x04DA1D,
    ),
    (
        "overworld_event_layer1_to",
        "SMW_ChangingLayer1OverworldTiles_TilesToBecome",
        0x04DA33,
    ),
    # -- the two smaller replay passes: destroyed and silent tiles ------------
    #
    # A destroy event crushes a castle/fortress/switch tile at load; silent
    # tiles are the ones flagged events place offscreen with no animation.
    # Both replay at every overworld load, so the editor's replay ports both.
    (
        "overworld_destroy_events",
        "SMW_CheckIfDestroyTileEventIsActive_EventNums",
        0x04E5D6,
        {"J": 0x04E5D8},
    ),
    (
        "overworld_destroy_locations",
        "SMW_CheckIfDestroyTileEventIsActive_DestructionTileLocations",
        0x04E5B6,
        {"J": 0x04E5B8},
    ),
    (
        "overworld_destroy_before",
        "SMW_CheckIfDestroyTileEventIsActive_TilesBeforeDestruction",
        0x04E5A7,
        {"J": 0x04E5A9},
    ),
    (
        "overworld_destroy_top",
        "SMW_CheckIfDestroyTileEventIsActive_TopTilesAfterDestruction",
        0x04E5AC,
        {"J": 0x04E5AE},
    ),
    (
        "overworld_destroy_bottom",
        "SMW_CheckIfDestroyTileEventIsActive_BottomTilesAfterDestruction",
        0x04E5B1,
        {"J": 0x04E5B3},
    ),
    # The block's first table doubles as the whole block's address: the
    # capture reads all $108 bytes from here, and the asm region names it
    # as its first section.
    (
        "overworld_silent_tiles",
        "SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent_"
        "SilentEventTiles_EventNum",
        0x04E8E4,
        {"J": 0x04E8E6},
    ),
    (
        "overworld_silent_layers",
        "SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent_"
        "SilentEventTiles_TileLayer",
        0x04E910,
        {"J": 0x04E912},
    ),
    (
        "overworld_silent_locations",
        "SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent_"
        "SilentEventTiles_TilemapLocation",
        0x04E93C,
        {"J": 0x04E93E},
    ),
    (
        "overworld_silent_tile_numbers",
        "SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent_"
        "SilentEventTiles_TileNum",
        0x04E994,
        {"J": 0x04E996},
    ),
    # -- the overworld's sprite slot table -------------------------------------
    #
    # 13 slots of (number, X, Y), signed map pixels, read once at title load.
    # The editor edits it as a plain fixed-size table, like the Layer 1
    # tilemap.
    (
        "overworld_sprite_slots",
        "SMW_LoadOverworldSprites_SpriteSlotData",
        0x04F625,
        {"J": 0x04F61D},
    ),
    # -- which maps show each overworld sprite number --------------------------
    #
    # One byte per sprite number, a set bit disabling it on that map. A fact
    # about the number rather than the slot, which is why the capture reads
    # it once and the markers follow it.
    (
        "overworld_sprite_submap_disable",
        "SMW_CheckIfXIsAllowedOnYSubmap_DisableSpriteOnXSubmapFlags",
        0x04F829,
        {"J": 0x04F821},
    ),
    # -- where a submap draws its copy of a ghost ------------------------------
    #
    # Three signed words each, applied to the main-map position of a Boo in
    # one of the last three slots. Their being three entries long is why a
    # ghost works in no other slot. Two tables rather than one because the
    # game keeps them apart, and a base is free to move one without the
    # other.
    (
        "overworld_sprite_boo_x_offsets",
        "SMW_LoadOverworldSprites_SubmapBooXPosOffset",
        0x04F666,
        {"J": 0x04F65E},
    ),
    (
        "overworld_sprite_boo_y_offsets",
        "SMW_LoadOverworldSprites_SubmapBooYPosOffset",
        0x04F66C,
        {"J": 0x04F664},
    ),
    # -- where the smoke draws on each map -------------------------------------
    #
    # One word per map, indexed by the map the player is on, and vanilla's are
    # two entries long: the main map and Yoshi's Island. The smoke's own
    # routine writes them into its position every frame, so a Smoke slot's
    # position in the slot table above never reaches the screen -- these are
    # what a marker has to follow. Two tables, as the ghost's are.
    (
        "overworld_sprite_smoke_x_positions",
        "SMW_OWSpr07_Smoke_MapXPos",
        0x04FC1E,
        {"J": 0x04FC16},
    ),
    (
        "overworld_sprite_smoke_y_positions",
        "SMW_OWSpr07_Smoke_MapYPos",
        0x04FC22,
        {"J": 0x04FC1A},
    ),
    # -- the Layer 2 loader's JSL-able wrapper ---------------------------------
    #
    # Decompresses both streams and replays pass 2. The game runs it at file
    # select; the editor's replay cross-check drives it directly, which its
    # own comment invites.
    (
        "overworld_layer2_loader",
        "SMW_LoadOverworldLayer2AndEventsTilemaps_Main",
        0x04DAAD,
    ),
    # -- the event stamp sheets and their properties --------------------------
    #
    # The 6x6 sheet, with the 2x2 sheet at a fixed offset after it; the
    # properties stream pairs one byte with every sheet byte.
    (
        "overworld_event_tiles",
        "SMW_OverworldLayer2EventTilemap_Tiles",
        0x0C8000,
    ),
    (
        "overworld_event_properties",
        "SMW_OverworldLayer2EventTilemap_Prop",
        0x0C8D00,
    ),
    # -- the overworld's Layer 2 tilemap, as two LC_RLE2 streams --------------
    #
    # Decompressed into $7F4000 only when a save file is loaded, not on every
    # overworld load -- so a capture that never selects a file reads them out
    # of the image and decodes them itself.
    (
        "overworld_layer2_tiles",
        "SMW_LoadOverworldLayer2AndEventsTilemaps_OverworldLayer2Tilemap_Tiles",
        0x04A533,
    ),
    (
        "overworld_layer2_properties",
        "SMW_LoadOverworldLayer2AndEventsTilemaps_OverworldLayer2Tilemap_Prop",
        0x04C02B,
    ),
    # -- routines the loader is driven through --------------------------------
    (
        "begin_loading_level_data",
        "SMW_BeginLoadingLevelData_Main",
        0x0583AC,
        {"E1": 0x0583D1},
    ),
    (
        "initialize_level_layer3",
        "SMW_InitializeLevelLayer3_Main",
        0x009FB8,
        {"J": 0x009F56, "SS": 0x009FF6, "E0": 0x009FBD, "E1": 0x009FBF},
    ),
    ("process_sprites", "SMW_ProcessNormalSprites_Main", 0x01808C),
    (
        "init_sprite_tables",
        "SMW_InitializeNormalSpriteRAMTables_Main",
        0x07F7D2,
    ),
    # -- the player's drawing routine, as a range -----------------------------
    #
    # The end is *exclusive* and is the address of whatever the ROM map placed
    # next, which is why it carries that label rather than one of its own. A
    # range needs both ends and only the start is a thing in its own right.
    (
        "player_gfx_start",
        "SMW_PlayerGFXRt_Main",
        0x00E2BD,
        {"J": 0x00E25D, "E0": 0x00E2AD, "E1": 0x00E2AD},
    ),
    (
        "player_gfx_end",
        "SMW_SlopeDataTables_Player_SlopeType",
        0x00E4B9,
        {"J": 0x00E459, "E0": 0x00E4A9, "E1": 0x00E4A9},
    ),
    # -- the object loop's per-record continue point ---------------------------
    #
    # The loop reaches it once per record with that record's drawing already
    # finished, which is what makes it a boundary the footprint trace can
    # watch -- see `shiny_mushroom.emu.footprints`.
    (
        "object_loop_continue",
        "SMW_LoadLevelDataObject_LevLoadContinue",
        0x0586D2,
        {"E1": 0x0586F7},
    ),
    # -- patch sites, rather than tables --------------------------------------
    #
    # An `LDA #$07` whose operand the editor rewrites to relocate a sprite
    # stream. It is a label because Lunar Magic hijacks it, which is the only
    # reason a hand-placed instruction has a name at all.
    (
        "sprite_bank_instruction",
        "SMW_SpecifySublevelToLoad_LM100Hijack_RemoveHardcodedSpriteListBank",
        0x05D8F5,
    ),
    # The two branches that decide which levels `$7E0109` can ask for. The
    # first reads `$00` as "no override" and the second subtracts `$24` from
    # anything above `$24`, so between them the low bytes `$00` and `$DC`
    # through `$FF` name no level -- a fifth of the cartridge, `$0DC` through
    # `$0FF` and `$1DC` through `$1FF` included. Turned into a `BRA` for the
    # length of one load, the byte written to `$0109` means itself and every
    # level number can be asked for.
    (
        "level_override_branch",
        "SMW_SpecifySublevelToLoad_OverrideTest",
        0x05D845,
    ),
    (
        "level_adjust_branch",
        "SMW_SpecifySublevelToLoad_AdjustmentTest",
        0x05D8A4,
    ),
    # -- every colour in the game ---------------------------------------------
    #
    # The global palette table as the ROM map placed it: 2018 bytes of colour,
    # cut into named runs by a table that is nothing but `incbin` ranges. The
    # editor reads the whole blob out of a cartridge here and writes it back
    # the same way -- see `shiny_mushroom.palettes`, whose catalog says what
    # each run inside it is.
    #
    # It moves in every target, which is the reason it is declared rather than
    # written down at the reading end: the front of bank `$00` is where the
    # version conditionals bite hardest.
    (
        "global_palettes",
        "SMW_GlobalPalettes_Main",
        0x00B0A0,
        {"J": 0x00B040, "SS": 0x00B0B0, "E0": 0x00B0B3, "E1": 0x00B0B3},
    ),
    # Two more runs of colour that the global table does not hold: the eight
    # steps a Magikoopa fades through, and the eight the Big Boo Boss does.
    # Both are 128 bytes, both are `incbin` out of a `.tpl` of their own, and
    # both sit in bank `$03` where no version conditional reaches -- which is
    # why neither carries a per-target address and the global table does.
    (
        "magikoopa_fade_palettes",
        "SMW_NorSpr01F_MagiKoopa_Status08_MagiKoopaFadePalettes",
        0x03B902,
    ),
    (
        "boo_fade_palettes",
        "SMW_BooFadePalettes_Main",
        0x03B982,
    ),
    # -- the graphics files ---------------------------------------------------
    #
    # The three parallel tables `SMW_GraphicsDecompressionRoutines_Main` reads
    # with the file number in Y: fifty `db` entries each, `GFX00`-`GFX31`, the
    # low, high and bank byte of each file's compressed stream. What a preview
    # of an edited file repoints when its re-encoding has outgrown the slot the
    # cartridge gave it -- see `shiny_mushroom.rom_patches.graphics_patch`. They
    # sit in the front of bank `$00`, so every target places them differently.
    (
        "graphics_pointers_low",
        "SMW_GraphicsDecompressionRoutines_GraphicsPtrLo",
        0x00B992,
        {"J": 0x00B933, "SS": 0x00B9A2, "E0": 0x00B9A5, "E1": 0x00B9A6},
    ),
    (
        "graphics_pointers_high",
        "SMW_GraphicsDecompressionRoutines_GraphicsPtrHi",
        0x00B9C4,
        {"J": 0x00B965, "SS": 0x00B9D4, "E0": 0x00B9D7, "E1": 0x00B9D8},
    ),
    (
        "graphics_pointers_bank",
        "SMW_GraphicsDecompressionRoutines_GraphicsPtrBank",
        0x00B9F6,
        {"J": 0x00B997, "SS": 0x00BA06, "E0": 0x00BA09, "E1": 0x00BA0A},
    ),
    # The two files the tables leave out, reached by literal from
    # `DecompressGFX32And33` once at boot: the player's 4bpp tiles and the
    # animated tiles. The same place on every target -- the start of bank
    # `$08` and a fixed spot in it -- and, with no table naming them, an edit
    # to either is previewed in place or not at all.
    ("graphics_file_32", "SMW_GFX32", 0x088000),
    ("graphics_file_33", "SMW_GFX33", 0x08BFC0),
)


def resolved(tables: Mapping[str, RomTable], symbols: SymbolTable) -> dict[str, int]:
    """Every role's address in one particular build, read from its symbol file.

    The declared literals describe the stock build; the symbol file describes
    the build actually in hand, and a project whose patches move a table is
    described only by the latter. Resolving through the label is what the label
    is *for* -- it is the durable half of an entry -- and a label the file does
    not know means the symbols are not this base's, which is worth a refusal
    rather than a partial answer read through the wrong tables.

    The exception is a label declared absent on *some* target
    (:attr:`RomTable.absent_targets`): the symbol file does not say which
    target it describes, so a missing version-forked label is read as that
    fork rather than as the wrong base, and its role is left out of the
    answer for the caller to fall back on the declarations.
    """
    missing = sorted(
        table.label
        for table in tables.values()
        if table.label not in symbols.by_name and not table.absent_targets
    )
    if missing:
        raise RomTableError(
            f"{len(missing)} declared label(s) are not in the symbol file, "
            f"starting with {missing[0]} -- these symbols do not describe "
            f"this base's build"
        )
    return {
        role: symbols.by_name[table.label].addr
        for role, table in tables.items()
        if table.label in symbols.by_name
    }


def drifted(
    tables: Mapping[str, RomTable],
    symbols: SymbolTable,
    target_id: str | None = None,
) -> dict[str, tuple[int, int]]:
    """The roles a build placed away from their declaration, as
    ``{role: (declared, built)}``.

    Empty means the build put every table where the unedited cartridge has it.
    A non-empty answer is **not** a defect on its own: a project that grew a
    table moved the ones after it, and every read goes through :func:`resolved`
    rather than through the literal. What this is for is holding a *declaration*
    honest -- the pinned targets in ``test_rom_tables``, and a feature's claim
    about the cartridge it makes -- where drift means the declaration is stale
    rather than the build wrong.
    """
    addresses = resolved(tables, symbols)
    return {
        role: (table.address_for(target_id), addresses[role])
        for role, table in tables.items()
        if role in addresses
        and table.assembled_for(target_id)
        and addresses[role] != table.address_for(target_id)
    }
