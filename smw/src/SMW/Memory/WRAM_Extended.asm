;--- Extended WRAM - $7E2000+ and $7F0000+
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; GFX32 decompressed. Written while the Nintendo Presents logo is shown and
; never modified after that, but often read. Prior to GFX32 being loaded
; here, the original game also uses this as a buffer for decompressing GFX33
; before it is converted from 3bpp to 4bpp into $7E7D00. With LM's 4bpp
; conversion, this is no longer necessary.
!RAM_SMW_Graphics_DecompressedGFX32 #= $7E2000		; $7E2000-$7E7CFF
; GFX33 decompressed. Written while the Nintendo Presents logo is shown and
; never modified after that, but often read.
!RAM_SMW_Graphics_DecompressedGFX33 #= !RAM_SMW_Graphics_DecompressedGFX32+$5D00
; GFX file decompression buffer. Decompressed as 3bpp (3kb) for unexpanded
; GFX and as 4bpp for expanded. It may also use the RAM following this (up
; to $7ECCFF) for larger files, such as the LT3 or AN2 slots. The latter
; continues to remain here after level/overworld load, and is where
; ExAnimations will pull their data from.
!RAM_SMW_Graphics_GraphicDecompressionBuffer #= $7EAD00
; During level load, if using a background Layer 2 tilemap in a level, this
; is table is temporarily used to hold the low byte of each tile. Format:
; Background is split into two 16x27 rectangles, followed by 160 $25 bytes
; that are never actually read. The high bytes of each tile are at $7EBD00.
; This table also used as an extension of the GFX decompression buffer at
; $7EAD00. As with that address, during a level, it may be used to hold
; additional data for the level's AN2 GFX file. In the original game, some
; of the RAM in this table is also used on the overworld for a number of
; 40-byte tables relating to the switch palace's block animation: $7EB900 -
; Switch block X position, high byte $7EB928 - Switch block Y position, high
; byte $7EB950 - Switch block Z position, high byte $7EB978 - Switch block X
; position, low byte $7EB9A0 - Switch block Y position, low byte $7EB9C8 -
; Switch block Z position, low byte $7EB9F0 - Switch block X speed $7EBA18 -
; Switch block Y speed $7EBA40 - Switch block Z speed $7EBA68 - Accumulating
; fraction bits for fixed point switch block X speed $7EBA90 - Accumulating
; fraction bits for fixed point switch block Y speed $7EBAB8 - Accumulating
; fraction bits for fixed point switch block Z speed With Lunar Magic, these
; tables instead get moved over to $7FC500 ($418800 on SA-1).
!RAM_SMW_Blocks_Layer2TilesLo #= $7EB900
; Where the switch-block tables sit: over the Layer 2 tile buffer on every
; shipped cartridge, and where SA-1 Pack's overworld boost keeps them on the
; SA-1 base -- BW-RAM, at the address Lunar Magic also moves them to. The
; twelve tables keep their stride and order either way.
if defined("Define_SMW_SA1")
!Define_SMW_SwitchBlockTablesLocation #= $418800
endif
if defined("Define_SMW_SwitchBlockTablesLocation") == 0
!Define_SMW_SwitchBlockTablesLocation #= $7EB900
endif
	!RAM_SMW_Overworld_SwitchBlockXPosHi #= !Define_SMW_SwitchBlockTablesLocation
	!RAM_SMW_Overworld_SwitchBlockYPosHi #= !RAM_SMW_Overworld_SwitchBlockXPosHi+((!Define_SMW_MaxSwitchBlockSlot+$01)*$01)
	!RAM_SMW_Overworld_SwitchBlockZPosHi #= !RAM_SMW_Overworld_SwitchBlockXPosHi+((!Define_SMW_MaxSwitchBlockSlot+$01)*$02)
	!RAM_SMW_Overworld_SwitchBlockXPosLo #= !RAM_SMW_Overworld_SwitchBlockXPosHi+((!Define_SMW_MaxSwitchBlockSlot+$01)*$03)
	!RAM_SMW_Overworld_SwitchBlockYPosLo #= !RAM_SMW_Overworld_SwitchBlockXPosLo+((!Define_SMW_MaxSwitchBlockSlot+$01)*$01)
	!RAM_SMW_Overworld_SwitchBlockZPosLo #= !RAM_SMW_Overworld_SwitchBlockXPosLo+((!Define_SMW_MaxSwitchBlockSlot+$01)*$02)
	!RAM_SMW_Overworld_SwitchBlockXSpeed #= !RAM_SMW_Overworld_SwitchBlockXPosHi+((!Define_SMW_MaxSwitchBlockSlot+$01)*$06)
	!RAM_SMW_Overworld_SwitchBlockYSpeed #= !RAM_SMW_Overworld_SwitchBlockXSpeed+((!Define_SMW_MaxSwitchBlockSlot+$01)*$01)
	!RAM_SMW_Overworld_SwitchBlockZSpeed #= !RAM_SMW_Overworld_SwitchBlockXSpeed+((!Define_SMW_MaxSwitchBlockSlot+$01)*$02)
	!RAM_SMW_Overworld_SwitchBlockSubXPos #= !RAM_SMW_Overworld_SwitchBlockXPosHi+((!Define_SMW_MaxSwitchBlockSlot+$01)*$09)
	!RAM_SMW_Overworld_SwitchBlockSubYPos #= !RAM_SMW_Overworld_SwitchBlockSubXPos+((!Define_SMW_MaxSwitchBlockSlot+$01)*$01)
	!RAM_SMW_Overworld_SwitchBlockSubZPos #= !RAM_SMW_Overworld_SwitchBlockSubXPos+((!Define_SMW_MaxSwitchBlockSlot+$01)*$02)
; During level load, if using a background Layer 2 tilemap in a level, this
; table is temporarily used to hold the high byte of each tile. Same format
; as the low-byte table at $7EB900. This table also used as an extension of
; the GFX decompression buffer at $7EAD00. As with that address, during a
; level, it may be used to hold additional data for the level's AN2 GFX
; file.
!RAM_SMW_Blocks_Layer2TilesHi #= !RAM_SMW_Blocks_Layer2TilesLo+$0400
;Empty $7EC100-$7EC67F
; Tilemap of Mode 7 bosses (Ludwig, Roy, Morton and Bowser).
!RAM_SMW_Misc_Mode7BossTilemap #= $7EC680
;Empty $7EC6E0-$7EC7FF
; Map16 Low Byte Table. For the high bytes, see $7FC800. In horizontal
; levels, $1B0 tiles per screen, where each screen can be indexed using the
; format %-------y yyyyxxxx . Addresses $7EFE00-$7EFFFF (512 bytes) are
; unused. In vertical levels, $200 bytes per screen, with the format
; %--sssssx yyyyxxxx . All bytes are used. If Layer 2 or 3 is interactive in
; the level, it uses screens 10-1F (0E-1B in vertical levels). On Lunar
; Magic version 3+, refer to this document for the layout in other level
; dimensions. On the overworld: $7EC800-$7ECFFF (2048 bytes) is used as the
; Layer 1 tilemap for the overworld. To index this table, use $1F11, $1F1F,
; and $1F21 to find Mario (or $1F12, $1F23, and $1F25 for Luigi). X position
; / 16: %---- ---- ---X xxxx Y position / 16: %---- ---- ---Y yyyy Index to
; this table: %---- -SYX yyyy xxxx * If the player is on a submap, the S bit
; is set. $7ED000-$7ED7FF (2048 bytes) is used as a table that contains the
; translevel numbers for every Layer 1 tile, in the format of $13BF.
; $7ED800-$7EDFFF (2048 bytes) is used as a table that contains the path
; direction settings for every Layer 1 tile, in the format of $04D678.
; $7EE400-$7EEBFF (2048 bytes) is used for uploading the Layer 1 tile map to
; VRAM in 2KB chunks. One chunk is uploaded per frame for four frames during
; transitions between the main overworld and submaps. Data is refreshed
; after each DMA.
; Where the Map16 tables live: the low bytes here and the high bytes one
; bank up, with the overworld's per-tile translevel and direction tables
; inside the same 64 KB. $7EC800 on every shipped cartridge, and $7EC700 on
; SMAS+W; a base that keeps them elsewhere sets the define on the command
; line, and every reader follows because none names the address itself.
; SA-1 Pack keeps them in BW-RAM at $40C800, which is where the sa1 base
; puts them.
if defined("Define_SMW_Map16Location") == 0
if ver_is_smasw(!Define_Global_ROMToAssemble)
!Define_SMW_Map16Location #= $7EC700
else
!Define_SMW_Map16Location #= $7EC800
endif
endif
!RAM_SMW_Blocks_Map16TableLo #= !Define_SMW_Map16Location
	!RAM_SMW_Overworld_LevelNumberOfEachTileTBL #= !RAM_SMW_Blocks_Map16TableLo+$0800
	!RAM_SMW_Overworld_LevelDirectionFlags #= !RAM_SMW_Blocks_Map16TableLo+$1000

; Layer 2 overworld event tilemap. The space after $7F0D00 is unused in the
; original game, but is used by LM to hold the expanded tilemap area. Note
; that this only holds the YXPCCCTT properties, with the actual tile numbers
; being retrieved from $0C8000. If LM's title screen moves recording hijack
; is installed, this region is also used to store the title screen
; movements. Three bytes are written any time a new key is pressed or
; released, or if the same keys are held for 256 frames. Since the event
; tilemap isn't restored, however, this will causes glitches with event
; tiles if the hijack isn't uninstalled. $7F0B44-$7F1343 is also used as a
; buffer for dynamic sprite graphics, to be uploaded during V-blank.
!RAM_SMW_Overworld_Layer2EventTiles #= $7F0000
; The Layer 2 tilemap of the whole overworld (including submaps starting at
; $7F6000). The tilemap starts from the top left corner of the main
; overworld, with two bytes per 8x8 tile (tile number, YXPCCCTT). This table
; is also used for a RAM buffer for the credit cutscene backgrounds.
!RAM_SMW_Overworld_Layer2Tiles #= $7F4000
	!RAM_SMW_Misc_CreditsBackgroundBuffer #= !RAM_SMW_Overworld_Layer2Tiles
; Unrolled loop which, executed once per each frame, writes to OAM to put
; all sprites outside the screen (this clears the OAM slots by setting their
; Y positions to #$F0). Note: Not executed during pause.
!RAM_SMW_Sprites_ResetSpriteOAMRt #= $7F8000
;Empty $7F8183-$7F837A
; Current length of the $7F837D stripe image, excluding the FF terminator.
; Used to allow two subroutines to write to $7F837D in the same frame.
!RAM_SMW_Misc_StripeImageUploadIndexLo #= $7F837B
!RAM_SMW_Misc_StripeImageUploadIndexHi #= !RAM_SMW_Misc_StripeImageUploadIndexLo+$01
; VRAM upload table, as a stripe image. Used to make changes to VRAM
; dynamically for updating on-screen tiles (e.g. when hitting a block). To
; use, get the current index from $7F837B, then start writing to this table
; from that position. End your stripe image with an $FF byte, then update
; $7F837B with an index to that. Not all of this table is used during normal
; gameplay, so $7F8600+ should generally be safe to use.
!RAM_SMW_Misc_StripeImageUploadTable #= $7F837D						; $7F837D-$7F977A
; Mario/Luigi Start, Game Over, Time Up etc. messages Graphics,
; decompressed.
!RAM_SMW_Graphics_DecompressedLoadingLetters #= $7F977B					; $7F977B-$7F9A7A
; Position table for the Wiggler's segments. Consists of four 0x80-byte
; tables assigned based on the Wiggler's sprite slot mod 4. A pointer to a
; Wiggler's assigned section is stored to $D5. The actual contents of these
; tables are two-byte pairs of 8-bit X and Y positions. Each frame, the
; Wiggler shifts all the bytes in its table right 2 bytes, and then writes
; its current position at the head, effectively acting as a log of the
; Wiggler's position over the last 64 frames. Its segments then pull their
; position from various indices within the table (specifically at 00, 1E,
; 3E, 5E, and 7E, or half those values when the Wiggler is angry).
; On the SA-1 base the pack's sprite boost keeps the Wiggler's segment table
; in BW-RAM, in the run the overworld's switch-block tables use -- the two
; are never live at once.
if defined("Define_SMW_SA1")
!Define_SMW_WigglerSegmentTableLocation #= $418800
endif
if defined("Define_SMW_WigglerSegmentTableLocation") == 0
!Define_SMW_WigglerSegmentTableLocation #= $7F9A7B
endif
!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable #= !Define_SMW_WigglerSegmentTableLocation
;Empty $7F9C7B-$7F9C7FF
; The custom sprites' per-slot tables (Config/CustomSprites.asm), at the
; addresses every sprite tool in the wild keeps them, so that a routine
; reading !extra_bits or !new_sprite_num through the dialect's defines
; (code/uberasm/defines.asm) reads the same bytes the feature writes. One
; byte per normal sprite slot each, except the pending pair, which is one
; spawn's worth of hand-off between the spawn seam and the initialize
; choke. On the SA-1 base they sit in BW-RAM, in the layout PIXI's own
; SA-1 support uses: 22-byte strides, with the new-code flag a single
; byte that tool no longer indexes.
if defined("Define_SMW_SA1")
!RAM_SMW_CustomSprites_ExtraBits #= $400040
!RAM_SMW_CustomSprites_NewCodeFlag #= $400056
!RAM_SMW_CustomSprites_ExtraProp1 #= $400057
!RAM_SMW_CustomSprites_ExtraProp2 #= $40006D
!RAM_SMW_CustomSprites_TrueSpriteID #= $400083
!RAM_SMW_CustomSprites_ExtraByte1 #= $400099
!RAM_SMW_CustomSprites_ExtraByte2 #= $4000AF
!RAM_SMW_CustomSprites_ExtraByte3 #= $4000C5
!RAM_SMW_CustomSprites_ExtraByte4 #= $4000DB
!RAM_SMW_CustomSprites_PendingExtraBits #= $4000F1
!RAM_SMW_CustomSprites_PendingSpriteID #= $4000F2
!RAM_SMW_CustomSprites_PendingExtraCount #= $4000F3
!RAM_SMW_CustomSprites_PendingExtra1 #= $4000F4
!RAM_SMW_CustomSprites_PendingExtra2 #= $4000F5
!RAM_SMW_CustomSprites_PendingExtra3 #= $4000F6
!RAM_SMW_CustomSprites_PendingExtra4 #= $4000F7
else
!RAM_SMW_CustomSprites_ExtraBits #= $7FAB10
!RAM_SMW_CustomSprites_NewCodeFlag #= $7FAB1C
!RAM_SMW_CustomSprites_ExtraProp1 #= $7FAB28
!RAM_SMW_CustomSprites_ExtraProp2 #= $7FAB34
!RAM_SMW_CustomSprites_ExtraByte1 #= $7FAB40
!RAM_SMW_CustomSprites_ExtraByte2 #= $7FAB4C
!RAM_SMW_CustomSprites_ExtraByte3 #= $7FAB58
!RAM_SMW_CustomSprites_ExtraByte4 #= $7FAB64
!RAM_SMW_CustomSprites_TrueSpriteID #= $7FAB9E
!RAM_SMW_CustomSprites_PendingExtraBits #= $7FABAA
!RAM_SMW_CustomSprites_PendingSpriteID #= $7FABAB
!RAM_SMW_CustomSprites_PendingExtraCount #= $7FABAC
!RAM_SMW_CustomSprites_PendingExtra1 #= $7FABAD
!RAM_SMW_CustomSprites_PendingExtra2 #= $7FABAE
!RAM_SMW_CustomSprites_PendingExtra3 #= $7FABAF
!RAM_SMW_CustomSprites_PendingExtra4 #= $7FABB0
endif
; Map16 high byte table. Same format as $7EC800. $7FFFF8-$7FFFFD are also
; used by Lunar Magic's title screen recording ASM.
!RAM_SMW_Blocks_Map16TableHi #= !RAM_SMW_Blocks_Map16TableLo+$010000

;VRAM Map
!VRAM_SMW_Layer1GFXVRAMLocation #= (!Define_SMW_Layer1GFXVRAMLocation*$1000)&$007FFF
!VRAM_SMW_Layer2GFXVRAMLocation #= !VRAM_SMW_Layer1GFXVRAMLocation
!VRAM_SMW_Layer4GFXVRAMLocation #= (!Define_SMW_Layer4GFXVRAMLocation*$1000)&$007FFF
!VRAM_SMW_Layer4TilemapVRAMLocation #= (!Define_SMW_Layer4TilemapVRAMLocation*$0400)&$00FFFF
!VRAM_SMW_Layer1TilemapVRAMLocation #= (!Define_SMW_Layer1TilemapVRAMLocation*$0400)&$00FFFF
!VRAM_SMW_Layer2TilemapVRAMLocation #= (!Define_SMW_Layer2TilemapVRAMLocation*$0400)&$00FFFF
!VRAM_SMW_Layer3GFXVRAMLocation #= (!Define_SMW_Layer3GFXVRAMLocation*$1000)&$007FFF
!VRAM_SMW_Layer3TilemapVRAMLocation #= (!Define_SMW_Layer3TilemapVRAMLocation*$0400)&$00FFFF
!VRAM_SMW_SpriteGFXLocationLo = ((!SpriteGFXLocationInVRAMLo_6000*$2000)&$00FFFF)
!VRAM_SMW_SpriteGFXLocationHi = ((!VRAM_SMW_SpriteGFXLocationLo+$1000+((!SpriteGFXLocationInVRAMHi_Add1000>>3)*$1000))&$00FFFF)
!VRAM_SMW_Layer1TilemapVRAMLocation_Mode7 #= (!Define_SMW_Layer1TilemapVRAMLocation_Mode7*$0400)&$00FFFF
!VRAM_SMW_Layer1GFXVRAMLocation_Mode7 #= (!Define_SMW_Layer1GFXVRAMLocation_Mode7*$1000)&$007FFF

;CGRAM
!CGRAM_SMW_DynamicPlayerPalette #= $86
!CGRAM_SMW_YoshiCoinFlash #= $64
!CGRAM_SMW_YellowLevelTile #= $6D
!CGRAM_SMW_RedLevelTile #= $7D

;OAM Map
!OAM_SMW_GenericMiscSprite #= $00
!OAM_SMW_GenericNormalSprite #= $40
!OAM_SMW_NintendoPresents #= $00
!OAM_SMW_ItemBoxItem_NormalLevel #= $38
!OAM_SMW_ItemBoxItem_BowserReznorMortonRoyRoom #= $00^(!OAM_SMW_ItemBoxItem_NormalLevel&$40)
!OAM_SMW_NorSpr0A0_ActivateBowserBattle_ItemBox #= $01
!OAM_SMW_NorSpr0A0_ActivateBowserBattle_CastleRoofDuringFight #= $6F
!OAM_SMW_NorSpr0A0_ActivateBowserBattle_CastleRoofDuringEnding #= $64

;SMAS+W Exclusive RAM/SRAM/VRAM/OAM

;Lunar Magic RAM										; Todo: Some of these might need more verification
!RAM_SMW_LM_Blocks_CurrentlyProcessedMap16TileLo #= !RAM_SMW_Misc_ScratchRAM03
!RAM_SMW_LM_Blocks_CurrentlyProcessedMap16TileHi #= !RAM_SMW_LM_Blocks_CurrentlyProcessedMap16TileLo+$01
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM45 #= !Define_SMW_DirectPageLocation+$45
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM46 #= !Define_SMW_DirectPageLocation+$46
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM47 #= !RAM_SMW_LM_CustomLevelDimensions_ScratchRAM46+$01
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM48 #= !Define_SMW_DirectPageLocation+$48
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM49 #= !Define_SMW_DirectPageLocation+$49
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM4A #= !Define_SMW_DirectPageLocation+$4A
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM4B #= !Define_SMW_DirectPageLocation+$4B
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM4C #= !Define_SMW_DirectPageLocation+$4C
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM4D #= !RAM_SMW_LM_CustomLevelDimensions_ScratchRAM4C+$01
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM4E #= !Define_SMW_DirectPageLocation+$4E
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM4F #= !RAM_SMW_LM_CustomLevelDimensions_ScratchRAM4E+$01
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM50 #= !Define_SMW_DirectPageLocation+$50
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM51 #= !RAM_SMW_LM_CustomLevelDimensions_ScratchRAM50+$01
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM52 #= !Define_SMW_DirectPageLocation+$52
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM53 #= !RAM_SMW_LM_CustomLevelDimensions_ScratchRAM52+$01
!RAM_SMW_LM_CustomLevelDimensions_ScratchRAM54 #= !Define_SMW_DirectPageLocation+$54
!RAM_SMW_LM_CustomLayer3Interaction_ScratchRAMD8 #= !Define_SMW_DirectPageLocation+$D8
!RAM_SMW_LM_CustomLayer3Interaction_ScratchRAMD9 #= !RAM_SMW_LM_CustomLayer3Interaction_ScratchRAMD8+$01
!RAM_SMW_LM_LCZ3_ScratchRAMD8 #= !Define_SMW_DirectPageLocation+$D8
!RAM_SMW_LM_LCZ3_ScratchRAMD9 #= !Define_SMW_DirectPageLocation+$D9
!RAM_SMW_LM_LCZ3_ScratchRAMDA #= !Define_SMW_DirectPageLocation+$DA
!RAM_SMW_LM_LCZ3_ScratchRAMDB #= !Define_SMW_DirectPageLocation+$DB
!RAM_SMW_LM_LCZ3_ScratchRAMDC #= !Define_SMW_DirectPageLocation+$DC
!RAM_SMW_LM_LCZ3_ScratchRAMDD #= !Define_SMW_DirectPageLocation+$DD
!RAM_SMW_LM_LCZ3_ScratchRAMDE #= !Define_SMW_DirectPageLocation+$DE
!RAM_SMW_LM_LCZ3_ScratchRAMDF #= !Define_SMW_DirectPageLocation+$DF
!RAM_SMW_LM_LCZ3_ScratchRAME0 #= !Define_SMW_DirectPageLocation+$E0
!RAM_SMW_LM_LCZ3_ScratchRAME1 #= !Define_SMW_DirectPageLocation+$E1
!RAM_SMW_LM_LCZ3_ScratchRAME2 #= !Define_SMW_DirectPageLocation+$E2
!RAM_SMW_LM_LCZ3_ScratchRAME3 #= !Define_SMW_DirectPageLocation+$E3
; Sprite X position, low byte.
!RAM_SMW_LM_LCZ3_ScratchRAME4 #= !Define_SMW_DirectPageLocation+$E4
!RAM_SMW_LM_LCZ3_ScratchRAME5 #= !Define_SMW_DirectPageLocation+$E5
!RAM_SMW_LM_LCZ3_ScratchRAME6 #= !Define_SMW_DirectPageLocation+$E6
!RAM_SMW_LM_LCZ3_ScratchRAME7 #= !Define_SMW_DirectPageLocation+$E7
!RAM_SMW_LM_LCZ3_ScratchRAME8 #= !Define_SMW_DirectPageLocation+$E8
!RAM_SMW_LM_LCZ3_ScratchRAME9 #= !Define_SMW_DirectPageLocation+$E9
!RAM_SMW_LM_Misc_OldGFXBypassUnusedRAM #= !Define_SMW_DirectPageLocation+$FA
!RAM_SMW_LM_Misc_OldGFXBypassAn2GFXList #= !Define_SMW_DirectPageLocation+$FB
!RAM_SMW_LM_Misc_OldGFXBypassFGBGGFXList #= !Define_SMW_DirectPageLocation+$FC
!RAM_SMW_LM_Misc_OldGFXBypassSpriteGFXList #= !Define_SMW_DirectPageLocation+$FD
!RAM_SMW_LM_Misc_CurrentLevelMinusOneLo #= !Define_SMW_DirectPageLocation+$FE
!RAM_SMW_LM_Misc_CurrentLevelMinusOneHi #= !RAM_SMW_LM_Misc_CurrentLevelMinusOneLo+$01
; 100 bytes used in LM 1.70+ for VRAM modification. In the clean ROM, it's
; empty (cleared on reset and titlescreen load).
!RAM_SMW_LM_Table_UnknownRAM7E0695 #= !Define_SMW_LowRAMLocation+$0695									; Note: 100 bytes
!RAM_SMW_LM_Misc_UnknownRAM7E0BF0 #= !Define_SMW_LowRAMLocation+$0BF0
!RAM_SMW_LM_Misc_UnknownRAM7E0BF1 #= !Define_SMW_LowRAMLocation+$0BF1
!RAM_SMW_LM_Misc_UnknownRAM7E0BF2 #= !Define_SMW_LowRAMLocation+$0BF2
!RAM_SMW_LM_Misc_UnknownRAM7E0BF3 #= !Define_SMW_LowRAMLocation+$0BF3
!RAM_SMW_LM_Misc_UnknownRAM7E0BF4 #= !Define_SMW_LowRAMLocation+$0BF4
!RAM_SMW_LM_Misc_UnknownRAM7E0BF5 #= !Define_SMW_LowRAMLocation+$0BF5
; Used for multiple purposes: During loading screen messages (MARIO START,
; TIME UP, GAME OVER, BONUS GAME), temporarily holds the decompressed GFX
; for tiles 4A-4F and 5A-5F of SP1 so that they can be restored afterwards.
; Lunar Magic disables this as it overwrites those anyway when it loads the
; level's GFX files. On the overworld, may contain decompressed animation
; data, continued from $0AF6. Lunar Magic 3.00+ uses this region to support
; the expanded horizontal level system; see details.
!RAM_SMW_LM_Misc_24BitL1LevelScreenPosLoPtrs #= !Define_SMW_LowRAMLocation+$0BF6
!RAM_SMW_LM_Misc_24BitL2LevelScreenPosLoPtrs #= !Define_SMW_LowRAMLocation+$0C26
!RAM_SMW_LM_Misc_24BitL1LevelScreenPosHiPtrs #= !Define_SMW_LowRAMLocation+$0C56
!RAM_SMW_LM_Misc_24BitL2LevelScreenPosHiPtrs #= !Define_SMW_LowRAMLocation+$0C86
!RAM_SMW_LM_Misc_8BitL1LevelScreenPosLoPtrs #= !Define_SMW_LowRAMLocation+$0CB6
!RAM_SMW_LM_Misc_8BitL2LevelScreenPosLoPtrs #= !Define_SMW_LowRAMLocation+$0CC6
!RAM_SMW_LM_Misc_8BitL1LevelScreenPosHiPtrs #= !Define_SMW_LowRAMLocation+$0CD6
!RAM_SMW_LM_Misc_8BitL2LevelScreenPosHiPtrs #= !Define_SMW_LowRAMLocation+$0CE6
!RAM_SMW_LM_Misc_UnknownRAM7E0CF6 #= !Define_SMW_LowRAMLocation+$0CF6
!RAM_SMW_LM_Misc_UnknownRAM7E0D36 #= !Define_SMW_LowRAMLocation+$0D36
!RAM_SMW_LM_Misc_LevelScreenSizeLo #= !Define_SMW_LowRAMLocation+$13D7
!RAM_SMW_LM_Misc_LevelScreenSizeHi #= !RAM_SMW_LM_Misc_LevelScreenSizeLo+$01
!RAM_SMW_LM_Misc_UnknownRAM7E13CD #= !Define_SMW_LowRAMLocation+$13CD
; Used by Lunar Magic to hold various settings, mainly related to Layer 3.
; Format: yyyyyosb - yyyyy: Initial Layer 3 Y position bits 0-4; bits 5-10
; can be found in bits 0-5 of $7FC01C. - o: Make sprites beyond level
; boundaries interact with air instead of water. - s: Enable Layer 3 scroll
; sync fix. - b: Enable advanced Layer 3 bypass settings. Empty in original
; game. Cleared on reset, titlescreen load, overworld load and cutscene
; load.
!RAM_SMW_LM_Misc_Layer3Settings #= !Define_SMW_LowRAMLocation+$145E
; When the advanced Layer 3 bypass is enabled, Lunar Magic uses this to hold
; the Layer 3 horizontal scroll setting, multiplied by 2. Notably, the
; actual order of these values is different from the order Lunar Magic lists
; them; see the details table for a full list. During level load, it also
; temporarily holds the vertical scroll setting as well, encoded using the
; format vvvvhhhh: - vvvv: Vertical scroll setting. The fifth bit can be
; found in bit 6 of $7FC01C. - hhhh: Horizontal scroll setting. The fifth
; bit can be found in bit 7 of $7FC01C. Empty in original game. Cleared on
; reset, titlescreen load, overworld load and cutscene load.
!RAM_SMW_LM_Misc_Layer3ScrollSettings #= !Define_SMW_LowRAMLocation+$145F
!RAM_SMW_LM_Misc_Layer3AutoScrollSubYPosLo #= !RAM_SMW_Flag_Layer3VerticalScrollDirection
!RAM_SMW_LM_Misc_Layer3AutoScrollSubYPosHi #= !RAM_SMW_LM_Misc_Layer3AutoScrollSubYPosLo+$01
!RAM_SMW_LM_Misc_Layer3InitialXOffsetLo #= !RAM_SMW_Misc_Layer3XDispLo
!RAM_SMW_LM_Misc_Layer3InitialXOffsetHi #= !RAM_SMW_LM_Misc_Layer3InitialXOffsetLo+$01
!RAM_SMW_LM_Misc_FixLayer3ScrollSyncXPosLo #= !RAM_SMW_Overworld_ProcessHardcodedPathFlagLo
!RAM_SMW_LM_Misc_FixLayer3ScrollSyncXPosHi #= !RAM_SMW_LM_Misc_FixLayer3ScrollSyncXPosLo+$01
!RAM_SMW_LM_Misc_FixLayer3ScrollSyncYPosLo #= !RAM_SMW_Overworld_HardcodedPathIndexLo
!RAM_SMW_LM_Misc_FixLayer3ScrollSyncYPosHi #= !RAM_SMW_LM_Misc_FixLayer3ScrollSyncYPosLo+$01
; Used by Lunar Magic v3.00+ (hijack at $00F70D) to hold the vertical
; scrolling range minus one tile (when "Allow viewing full bottom row of
; tiles" is unchecked). Effectively equivalent to $13D7 - #$10.
!RAM_SMW_LM_Misc_LevelScreenSizeMinus10Lo #= !Define_SMW_LowRAMLocation+$1936
!RAM_SMW_LM_Misc_LevelScreenSizeMinus10Hi #= !RAM_SMW_LM_Misc_LevelScreenSizeMinus10Lo+$01
!RAM_SMW_LM_Misc_AltDecompressionBuffer #= $7EB500
!RAM_SMW_LM_Misc_Layer3TilemapDecompressionBuffer #= $7EBD00
RAM_SMW_LM_Misc_TitleScreenMovementDataBuffer = $7F0000
!RAM_SMW_LM_Misc_UnknownDecompressionBuffer #= $7F2000
; Empty, untouched RAM. ~420 bytes used in LM 1.70+ for VRAM modification
; (see details).
!RAM_SMW_LM_VRAMPatch_L1HorizVRAMLocLo #= $7F8183
!RAM_SMW_LM_VRAMPatch_L1HorizVRAMLocHi #= !RAM_SMW_LM_VRAMPatch_L1HorizVRAMLocLo+$01
!RAM_SMW_LM_VRAMPatch_L2HorizVRAMLocLo #= $7F8185
!RAM_SMW_LM_VRAMPatch_L2HorizVRAMLocHi #= !RAM_SMW_LM_VRAMPatch_L2HorizVRAMLocLo+$01
!RAM_SMW_LM_VRAMPatch_L1VertVRAMLocLo #= $7F8187
!RAM_SMW_LM_VRAMPatch_L1VertVRAMLocHi #= !RAM_SMW_LM_VRAMPatch_L1VertVRAMLocLo+$01
!RAM_SMW_LM_VRAMPatch_L2VertVRAMLocLo #= $7F8189
!RAM_SMW_LM_VRAMPatch_L2VertVRAMLocHi #= !RAM_SMW_LM_VRAMPatch_L2VertVRAMLocLo+$01
!RAM_SMW_LM_VRAMPatch_L1VertTilesVRAMUploadAddr #= $7F820B
!RAM_SMW_LM_VRAMPatch_L2VertTilesVRAMUploadAddr #= $7F828B
!RAM_SMW_LM_VRAMPatch_UnknownRAM1 #= $7F8327
!RAM_SMW_LM_VRAMPatch_UnknownRAM2 #= !RAM_SMW_LM_VRAMPatch_UnknownRAM1+$01
; Used by Lunar Magic's VRAM patch.
!RAM_SMW_LM_Blocks_Layer2TilesLo #= $7FBC00									; Note: 1024 bytes. Used by the VRAM patch
; Used by Lunar Magic for various purposes. See details for a list.
!RAM_SMW_LM_Pointer_LocalExAnimationAddressLo #= $7FC000
!RAM_SMW_LM_Pointer_LocalExAnimationAddressHi #= !RAM_SMW_LM_Pointer_LocalExAnimationAddressLo+$01
!RAM_SMW_LM_Pointer_LocalExAnimationAddressBank #= !RAM_SMW_LM_Pointer_LocalExAnimationAddressLo+$02
!RAM_SMW_LM_Counter_LocalExAnimationFrames #= $7FC003
!RAM_SMW_LM_Misc_UnknownRAM7FC004 #= $7FC004
!RAM_SMW_LM_Pointer_SuperGFXBypassTBLLo #= $7FC006
!RAM_SMW_LM_Pointer_SuperGFXBypassTBLHi #= !RAM_SMW_LM_Pointer_SuperGFXBypassTBLLo+$01
!RAM_SMW_LM_Pointer_SuperGFXBypassTBLBank #= !RAM_SMW_LM_Pointer_SuperGFXBypassTBLLo+$02
!RAM_SMW_LM_Misc_UnknownRAM7FC009 #= $7FC009
!RAM_SMW_LM_Flag_ExAnimationSettings #= $7FC00A
!RAM_SMW_LM_Misc_Layer2Properties #= $7FC00B
!RAM_SMW_LM_Misc_TotalLocalExAnimationsLo #= $7FC00C								;\ Todo: I'm 99% sure that this is what these addresses are for.
!RAM_SMW_LM_Misc_TotalLocalExAnimationsHi #= !RAM_SMW_LM_Misc_TotalLocalExAnimationsLo+$01				;|
!RAM_SMW_LM_Misc_TotalGlobalExAnimationsLo #= $7FC00E								;|
!RAM_SMW_LM_Misc_TotalGlobalExAnimationsHi #= !RAM_SMW_LM_Misc_TotalGlobalExAnimationsLo+$01			;/
!RAM_SMW_LM_Pointer_LocalAltExGFXLocLo #= $7FC010
!RAM_SMW_LM_Pointer_LocalAltExGFXLocHi #= !RAM_SMW_LM_Pointer_LocalAltExGFXLocLo+$01
!RAM_SMW_LM_Pointer_LocalAltExGFXLocBank #= !RAM_SMW_LM_Pointer_LocalAltExGFXLocLo+$02
!RAM_SMW_LM_Pointer_GlobalAltExGFXLocLo #= $7FC013
!RAM_SMW_LM_Pointer_GlobalAltExGFXLocHi #= !RAM_SMW_LM_Pointer_GlobalAltExGFXLocLo+$01
!RAM_SMW_LM_Pointer_GlobalAltExGFXLocBank #= !RAM_SMW_LM_Pointer_GlobalAltExGFXLocLo+$02
!RAM_SMW_LM_Pointer_GlobalExAnimationAddressLo #= $7FC016
!RAM_SMW_LM_Pointer_GlobalExAnimationAddressHi #= !RAM_SMW_LM_Pointer_GlobalExAnimationAddressLo+$01
!RAM_SMW_LM_Pointer_GlobalExAnimationAddressBank #= !RAM_SMW_LM_Pointer_GlobalExAnimationAddressLo+$02
!RAM_SMW_LM_Misc_UnknownRAM7FC019 #= $7FC019
!RAM_SMW_LM_Misc_CustomLayer3Settings #= $7FC01A
!RAM_SMW_LM_Misc_UnknownRAM7FC01B #= $7FC01B
!RAM_SMW_LM_Misc_UnknownRAM7FC01C #= !RAM_SMW_LM_Misc_UnknownRAM7FC01B+$01
; Used by Lunar Magic v1.80+ as bitwise state flags for Conditional Direct
; Map16. To find the bit for a particular flag, use flag >> 3 to get the
; byte, and then 1 << (flag & 7) to get a bitmask for the bit (ordered low
; to high). Note that this address is not initialized automatically.
!RAM_SMW_LM_Misc_ConditionalMap16FlagsTable #= $7FC060								; Note: 16 bytes
; Used by Lunar Magic v1.70+ as frame numbers for each Manual ExAnimation.
; One byte per slot. Note that these addresses are uninitialized unless
; specified by the "Trigger Init" settings in Lunar Magic.
!RAM_SMW_LM_Misc_ExAnimationManualFrames #= $7FC070								; Note: 16 bytes
; Used by Lunar Magic as frame counters for each Level/Submap ExAnimation.
; One byte per slot.
!RAM_SMW_LM_Misc_ExAnimationLevelFrameCount #= $7FC080							; Note: 32 bytes
; Used by Lunar Magic as frame counters for each Global ExAnimation. One
; byte per slot.
!RAM_SMW_LM_Misc_ExAnimationGlobalFrameCount #= !RAM_SMW_LM_Misc_ExAnimationLevelFrameCount+$20			; Note: 32 bytes
; Lunar Magic's ExAnimation output table, used to temporarily store data for
; any ExAnimations updating on the current frame. There are 8 tables, each 7
; bytes long, with their data written by the routine at read3($00A2A5+1) .
; The data within these tables is then written as follows: Bytes 0-1: 16-bit
; header. The highest bit determines the animation type, with 0 being
; graphics and 1 being palettes. For graphics, the remaining 15 bits are the
; transfer size. For palettes, the low byte is doubled and used as the
; transfer size (with the low byte hence effectively being the number of
; colors). Bytes 2-3: 16-bit destination. For GFX animations, the high bit
; determines whether the animation uses a line (0) or rectangular (1) type,
; with the remaining 15 bits used as the base VRAM address. For color
; animations, the low byte holds the base CGRAM address while the high byte
; is unused. Bytes 4-6: 24-bit source. For GFX animations, this generally
; points to RAM, but may be ROM for ExGFX60-63. For "palette + working"
; animations, this points to the corresponding color to update in the table
; at $0903. For palette animations with only one color (i.e. header =
; #$8001), bytes 4/5 hold the raw 16-bit SNES RGB color while byte 6 is
; unused. For any other palette animation, all three bytes form a 24-bit
; pointer to the color data.
!RAM_SMW_LM_Misc_ExAnimationDMAParametersTable #= $7FC0C0
; Used by Lunar Magic v1.70+ as bitwise flags for One Shot ExAnimation
; triggers. To find the bit for a particular trigger, use trigger >> 3 to
; get the byte, and then 1 << (trigger & 7) to get a bitmask for the bit.
!RAM_SMW_LM_Misc_ExAnimationOneShotTriggers #= $7FC0F8							; Note: 4 bytes
; Used by Lunar Magic v1.70+ as bitwise flags for Custom ExAnimation
; triggers. To find the bit for a particular flag, use trigger >> 3 to get
; the byte, and then 1 << (trigger & 7) to get a bitmask for the bit. Note
; that these addresses are uninitialized unless specified by the "Trigger
; Init" settings in Lunar Magic.
!RAM_SMW_LM_Misc_ExAnimationCustomTriggers #= $7FC0FC
!RAM_SMW_LM_Blocks_Layer2TilesLo #= $7FC300									; Note: 1024 bytes. Used by the VRAM patch
!RAM_SMW_LM_Misc_UnknownRAM7FFFF8 #= $7FFFF8
!RAM_SMW_LM_Misc_UnknownRAM7FFFF9 #= $7FFFF9
!RAM_SMW_LM_Misc_UnknownRAM7FFFFA #= $7FFFFA
!RAM_SMW_LM_Misc_UnknownRAM7FFFFB #= $7FFFFB
!RAM_SMW_LM_Misc_UnknownRAM7FFFFC #= $7FFFFC
!RAM_SMW_LM_Misc_UnknownRAM7FFFFD #= $7FFFFD
!RAM_SMW_LM_Misc_UnknownRAM7FFFFE #= $7FFFFE

;SA-1 RAM (used by Lunar Magic)
!RAM_SMW_SA1_SNESCodePointerLo #= !Define_SMW_LowRAMLocation+$0183
!RAM_SMW_SA1_SNESCodePointerHi #= !RAM_SMW_SA1_SNESCodePointerLo+$01
!RAM_SMW_SA1_SNESCodePointerBank #= !RAM_SMW_SA1_SNESCodePointerLo+$02
!RAM_SMW_SA1_SNESDoneFlag #= !Define_SMW_LowRAMLocation+$018A

;RAM Tables

struct SMW_Stack !RAM_SMW_Misc_EndOfStack
	.Byte skip $01
endstruct align $01

struct SMW_OAMBuffer !RAM_SMW_IO_OAMBuffer
	.XDisp: skip $01
	.YDisp: skip $01
	.Tile: skip $01
	.Prop: skip $01
endstruct align $04

struct SMW_ParallaxScrollHDMA !RAM_SMW_Misc_HDMAWindowEffectTable
	.Scanline1: skip $01
	.PosLo1: skip $01
	.PosHi1: skip $01
	.Scanline2: skip $01
	.PosLo2: skip $01
	.PosHi2: skip $01
	.Scanline3: skip $01
	.PosLo3: skip $01
	.PosHi3: skip $01
	.End: skip $01
endstruct

struct SMW_UpperOAMBuffer !RAM_SMW_IO_OAMBuffer+$0200
	.Slot: skip $01
endstruct align $01

struct SMW_OAMTileSizeBuffer !RAM_SMW_Sprites_OAMTileSizeBuffer
	.Slot: skip $01
endstruct

struct SMW_StripeImageUploadTable !RAM_SMW_Misc_StripeImageUploadTable
	.LowByte: skip $01
	.HighByte: skip $01
endstruct align $02

struct SMW_DynamicSpritePointersTop !RAM_SMW_Graphics_DynamicSpritePointersTopLo
	.LowByte: skip $01
	.HighByte: skip $01
endstruct align $02

struct SMW_DynamicSpritePointersBottom !RAM_SMW_Graphics_DynamicSpritePointersBottomLo
	.LowByte: skip $01
	.HighByte: skip $01
endstruct align $02

struct SMW_PaletteMirror !RAM_SMW_Palettes_PaletteMirror
	.LowByte: skip $01
	.HighByte: skip $01
endstruct align $02

struct SMW_CopyOfPaletteMirror !RAM_SMW_Palettes_CopyOfPaletteMirror
	.LowByte: skip $01
	.HighByte: skip $01
endstruct align $02

struct SMW_GraphicDecompressionBuffer !RAM_SMW_Graphics_GraphicDecompressionBuffer
	.Tile: skip $18
endstruct align $18

struct SMW_ExAnimationDMAParameters !RAM_SMW_LM_Misc_ExAnimationDMAParametersTable
	.SizeLo: skip $01
	.SizeHi: skip $01
	.UploadAddressLo: skip $01
	.UploadAddressHi: skip $01
	.SourceLo: skip $01
	.SourceHi: skip $01
	.SourceBank: skip $01
endstruct align $07


;Sprite RAM
;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_GenericEnemies_BounceHeight #= !RAM_SMW_NorSpr_Table7E160E

!RAM_SMW_NorSprXXX_NakedKoopa_FlipOrKickShellTimer #= !RAM_SMW_NorSpr_Table7E00C2

!RAM_SMW_NorSpr003_YellowNakedKoopa_WaitBeforeFacingMario #= !RAM_SMW_NorSpr_Table7E1570

!RAM_SMW_NorSpr007_YellowKoopa_WaitBeforeFacingMario #= !RAM_SMW_NorSpr_Table7E1570

!RAM_SMW_NorSpr00C_YellowParaKoopa_WaitBeforeFacingMario #= !RAM_SMW_NorSpr_Table7E1570

!RAM_SMW_NorSpr00D_BobOmb_IsExploding #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr00D_BobOmb_WaitBeforeExplosion #= !RAM_SMW_NorSpr_DecrementingTable7E1540

!RAM_SMW_NorSpr00F_Goomba_StunTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr00E_Keyhole_HighestSlotWithKey #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr00E_Keyhole_ActivateKeyholeFlag #= !RAM_SMW_NorSpr_DecrementingTable7E154C
!RAM_SMW_NorSpr00E_Keyhole_XPosLo #= !RAM_SMW_Misc_ScratchRAM7E1436
!RAM_SMW_NorSpr00E_Keyhole_XPosHi #= !RAM_SMW_NorSpr00E_Keyhole_XPosLo+$01
!RAM_SMW_NorSpr00E_Keyhole_YPosLo #= !RAM_SMW_Misc_ScratchRAM7E1438
!RAM_SMW_NorSpr00E_Keyhole_YPosHi #= !RAM_SMW_NorSpr00E_Keyhole_YPosLo+$01

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr010_ParaGoomba_FacePlayerTimer #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr010_ParaGoomba_HopCounter #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr010_ParaGoomba_WaitBeforeHoppingAfterBigHop #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr012_UnusedSprite_UnknownRAM #= !RAM_SMW_NorSpr_Table7E1534

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_FixedMovementCheepCheep_MovementDirection #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_FixedMovementCheepCheep_MovementFlag #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_FixedMovementCheepCheep_TurnAroundTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr018_SurfaceJumpingCheepCheep_HopCounter #= !RAM_SMW_NorSpr_Table7E00C2

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr019_DisplayMessage_WaitBeforeDisplayMessage  #= !RAM_SMW_NorSpr_DecrementingTable7E1564

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr01B_Football_WaitBeforeBeingKicked #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr01C_BulletBill_FiringDirection #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr01C_BulletBill_AppearBehindLayer1Timer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr01D_HoppingFlame_WaitBeforeHopping #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr01E_Lakitu_FishingFlag #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr01E_Lakitu_ThrowingAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr01E_Lakitu_FishingLineXDisp #= !RAM_SMW_Misc_ScratchRAM7E185E
!RAM_SMW_NorSpr01E_Lakitu_FishingLineYDisp #= !RAM_SMW_Misc_ScratchRAM7E18B6

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr01F_MagiKoopa_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr01F_MagiKoopa_FadePaletteIndex #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr01F_MagiKoopa_DisableInteraction #= !RAM_SMW_NorSpr_Table7E15D0

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_NetKoopas_MovementDirectionFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_NetKoopas_TurnAroundToOtherSideTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_NetKoopas_MovementDirection #= !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr026_Thwomp_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr026_Thwomp_InitialYPosLo #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr026_Thwomp_FaceFrame #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr026_Thwomp_WaitBeforeRising #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr026_Thwomp_SidePlayerIsOn #= !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr027_Thwimp_HoppingDirection #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr027_Thwimp_WaitBeforeNextHop #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr029_KoopaKid_KoopaKidType #= !RAM_SMW_NorSprXXX_CurrentlyActiveBoss

!RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_AttackPointer #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr029_KoopaKid_MortonRoy_LeftWallXPos #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr029_KoopaKid_Ludwig_JumpRotationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection #= !RAM_SMW_NorSpr_Table7E157C
!RAM_SMW_NorSpr029_KoopaKid_MortonRoy_MovementDirection #= !RAM_SMW_NorSpr_Table7E1594
!RAM_SMW_NorSpr029_KoopaKid_MortonRoy_RightWallXPos #= !RAM_SMW_NorSpr_Table7E160E
!RAM_SMW_NorSpr029_KoopaKid_Ludwig_JumpingXSpeed #= !RAM_SMW_NorSpr_Table7E160E
!RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_HitCounter #= !RAM_SMW_NorSpr_Table7E1626
!RAM_SMW_NorSpr029_KoopaKid_Ludwig_WaitBeforeShootingFire #= !RAM_SMW_NorSpr_DecrementingTable7E163E
!RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_MoveWallsInwardTimer #= !RAM_SMW_NorSpr_Table7E164A
!RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_Mode7RoomToLoad #= !RAM_SMW_NorSpr_Table7E187B
!RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_DisableMarioContactTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1FE2

!RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfXPosLo #= !RAM_SMW_Misc_ScratchRAM7E14B8
!RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfYPosLo #= !RAM_SMW_Misc_ScratchRAM7E14BA
!RAM_SMW_NorSpr029_KoopaKid_IggyLarry_WaitBeforeNextBallThrow #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr029_KoopaKid_IggyLarry_HurtAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E154C
!RAM_SMW_NorSpr029_KoopaKid_IggyLarry_DisablePlayerInteractionTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr029_KoopaKid_IggyLarry_BallThrowAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1564
!RAM_SMW_NorSpr029_KoopaKid_IggyLarry_FellOffPlatformFlag #= !RAM_SMW_NorSpr_Table7E160E
!RAM_SMW_NorSpr029_KoopaKid_IggyLarry_SinkingInLavaTimer #= !RAM_SMW_NorSpr_DecrementingTable7E163E

!RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_CurrentState #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_AnimationPointer #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_HitCounter #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_DummyFlag #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_SpawnPositionIndex #= !RAM_SMW_NorSpr_Table7E160E

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_RegularPiranhaPlant_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_RegularPiranhaPlant_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_RegularPiranhaPlant_PlayerIsCloseFlag #= !RAM_SMW_NorSpr_Table7E1594

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr02B_SumoLightning_SpawnFireTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr02B_SumoLightning_NumberOfFlamesSpawned #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr02B_SumoLightning_DisableBlockCollisionTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1FE2

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr02C_YoshiEgg_ContentsOfEgg #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr02C_YoshiEgg_DontHatchYetFlag #= !RAM_SMW_NorSpr_Table7E187B

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr02D_BabyYoshi_SpritesEatenCounter #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr02D_BabyYoshi_SlotOfSpriteBeingEaten #= !RAM_SMW_NorSpr_Table7E160E
!RAM_SMW_NorSpr02D_BabyYoshi_SwallowAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E163E

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_WallFollowers_RotationDirection #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_WallFollowers_TurnOnCornerTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_WallFollowers_BlinkingAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558

!RAM_SMW_NorSprXXX_Urchins_AnimationFrameCounter #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSprXXX_Urchins_AnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E163E

!RAM_SMW_NorSpr02E_SpikeTop_DiagonalAnimationFrameTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1564

!RAM_SMW_NorSpr03A_FixedUrchin_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr03A_FixedUrchin_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

!RAM_SMW_NorSpr03B_WallDetectUrchin_CurrentState #= !RAM_SMW_NorSpr03A_FixedUrchin_CurrentState
!RAM_SMW_NorSpr03B_WallDetectUrchin_PhaseTimer #= !RAM_SMW_NorSpr03A_FixedUrchin_PhaseTimer

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr02F_PortableSpringboard_AnimationFrameTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr030_ThrowingDryBones_HasCollapsedFlag #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr030_ThrowingDryBones_CollapsedTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr030_ThrowingDryBones_ThrowBonesTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr030_ThrowingDryBones_UnusedFreezeTimer #= !RAM_SMW_NorSpr_DecrementingTable7E163E

!RAM_SMW_NorSpr031_BonyBeetle_WaitBeforeGoingIntoShell #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr031_BonyBeetle_HasCollapsedFlag #= !RAM_SMW_NorSpr030_ThrowingDryBones_HasCollapsedFlag
!RAM_SMW_NorSpr031_BonyBeetle_HideInShellTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr031_BonyBeetle_UnusedFreezeTimer #= !RAM_SMW_NorSpr030_ThrowingDryBones_UnusedFreezeTimer

!RAM_SMW_NorSpr032_LedgeDryBones_WalkedOffLedgeFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr032_LedgeDryBones_HasCollapsedFlag #= !RAM_SMW_NorSpr030_ThrowingDryBones_HasCollapsedFlag
!RAM_SMW_NorSpr032_LedgeDryBones_CollapsedTimer #= !RAM_SMW_NorSpr030_ThrowingDryBones_CollapsedTimer
!RAM_SMW_NorSpr032_LedgeDryBones_ThrowBonesTimer #= !RAM_SMW_NorSpr030_ThrowingDryBones_ThrowBonesTimer
!RAM_SMW_NorSpr032_LedgeDryBones_UnusedFreezeTimer #= !RAM_SMW_NorSpr030_ThrowingDryBones_UnusedFreezeTimer

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr033_Podoboo_FireballType #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr033_Podoboo_InitialYPosHi #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr033_Podoboo_InitialYPosLo #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr033_Podoboo_WaitBeforeNextJump #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr033_Podoboo_BowserFireDespawnTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr033_Podoboo_KeepYSpeedFailsafeTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1564
!RAM_SMW_NorSpr033_Podoboo_CopyOfWaitBeforeNextJump #= !RAM_SMW_NorSpr_Table7E15D0

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr034_LudwigFireball_WaitBeforeMoving #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr035_Yoshi_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr035_Yoshi_EndingYPosLo #= !RAM_SMW_NorSpr_YPosLo
!RAM_SMW_NorSpr035_Yoshi_EndingXPosLo #= !RAM_SMW_NorSpr_XPosLo
; Slot 0 by the spelling that also assembles on the SA-1 base; see the
; tables' own `_Slot0` defines.
!RAM_SMW_NorSpr035_Yoshi_EndingYPosLo_Slot0 = "!RAM_SMW_NorSpr_YPosLo_Slot0"
!RAM_SMW_NorSpr035_Yoshi_EndingXPosLo_Slot0 = "!RAM_SMW_NorSpr_XPosLo_Slot0"
!RAM_SMW_NorSpr035_Yoshi_EndingYPosHi #= !RAM_SMW_NorSpr_YPosHi
!RAM_SMW_NorSpr035_Yoshi_EndingXPosHi #= !RAM_SMW_NorSpr_XPosHi
!RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr035_Yoshi_SwallowAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1564
!RAM_SMW_NorSpr035_Yoshi_CurrentMouthState #= !RAM_SMW_NorSpr_Table7E1594
!RAM_SMW_NorSpr035_Yoshi_EndingOAMIndex #= !RAM_SMW_NorSpr_OAMIndex
!RAM_SMW_NorSpr035_Yoshi_YoshiColor #= !RAM_SMW_NorSpr_Table7E15F6
!RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten #= !RAM_SMW_NorSpr_Table7E160E
!RAM_SMW_NorSpr035_Yoshi_DisableSpriteInteraction #= !RAM_SMW_NorSpr_DecrementingTable7E163E
!RAM_SMW_NorSpr035_Yoshi_UnknownRAM #= !RAM_SMW_Misc_ScratchRAM7E185E
!RAM_SMW_NorSpr035_Yoshi_DisableWaterSplashTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1FE2

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_NonBossBoos_FollowingMarioFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_NonBossBoos_WaitBeforeNextFollowCheck #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_NonBossBoos_IdleAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSprXXX_NonBossBoos_IdleAnimationFrameCounter #= !RAM_SMW_NorSpr_Table7E1570

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_Eeries_VerticalMovementDirection #= !RAM_SMW_NorSpr_Table7E00C2

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr03D_RipVanFish_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr03D_RipVanFish_SwimmingTimer #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr03D_RipVanFish_ZSpawnTimer #= !RAM_SMW_NorSpr_Table7E1528

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr03E_PSwitch_Type #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr03E_PSwitch_DespawnTimer #= !RAM_SMW_NorSpr_DecrementingTable7E163E

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_ParachutingEnemy_SwingDirection #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_ParachutingEnemy_FallStraightDownFlag #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_ParachutingEnemy_WaitForParachuteToDescend #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_ParachutingEnemy_CurrentAngle #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteAnimationFrame #= !RAM_SMW_NorSpr_AnimationFrame
!RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteYPosOffset #= !RAM_SMW_Misc_ScratchRAM7E185E

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_Dolphins_HorizontalMovementDirection #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_Dolphins_NoTurnAroundFlag #= !RAM_SMW_NorSpr_Table7E151C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr044_TorpedoTed_ReleaseAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr045_DirectionalCoins_MovementDirection #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr045_DirectionalCoins_DirectionToTravelNext #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr045_DirectionalCoins_AppearBehindLayer1Timer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnOrJumpTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnAroundCounter #= !RAM_SMW_NorSpr_Table7E1570

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr048_DigginChuckRock_InGroundTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr049_ShiftingPipe_CurrentMovementPhase #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr049_ShiftingPipe_InitialClearTileOffset #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr049_ShiftingPipe_MovementPhaseTimer #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr049_ShiftingPipe_LeftMap16Tile #= !RAM_SMW_Misc_ScratchRAM7E185E
!RAM_SMW_NorSpr049_ShiftingPipe_RightMap16Tile #= !RAM_SMW_Misc_ScratchRAM7E18B6

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr04B_PipeLakitu_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr04B_PipeLakitu_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr04C_ExplodingBlock_Contents #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr04C_ExplodingBlock_MusicNoteSpawnTimer #= !RAM_SMW_NorSpr03D_RipVanFish_ZSpawnTimer
!RAM_SMW_NorSpr04C_ExplodingBlock_ShakingAnimationFrameCounter #= !RAM_SMW_NorSpr_Table7E1570

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_SmallMontyMole_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_SmallMontyMole_FollowMarioFlag #= !RAM_SMW_NorSpr01E_Lakitu_FishingFlag
!RAM_SMW_NorSprXXX_SmallMontyMole_WaitBeforeJumpingOutOfGround #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_SmallMontyMole_WaitBeforeNextHop #= !RAM_SMW_NorSpr_DecrementingTable7E1558

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_JumpingPiranhaPlant_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_JumpingPiranhaPlant_PropellerAnimationFrameCounter #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_JumpingPiranhaPlant_WaitBeforeJumping #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_JumpingPiranhaPlant_MouthAnimationFrameCounter #= !RAM_SMW_NorSpr_AnimationFrameCounter

!RAM_SMW_NorSpr050_FireSpittingJumpingPiranhaPlant_WaitBeforeFireSpit #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr051_Ninji_JumpCounter #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr051_Ninji_WaitBeforeNextJump #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr052_MovingLedgeHole_ChangeDirectionTimer #= !RAM_SMW_NorSpr_Table7E1570 

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr053_ThrowBlock_DespawnTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr054_ClimbingNetDoor_TurningAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr054_ClimbingNetDoor_WaitBeforeTurning #= !RAM_SMW_NorSpr_DecrementingTable7E154C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr055_HorizontalCheckerboardPlatform_PlatformType #= !RAM_SMW_NorSpr_Table7E1602

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr057_VerticalCheckerboardPlatform_PlatformType #= !RAM_SMW_NorSpr055_HorizontalCheckerboardPlatform_PlatformType

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_TurnBlockBridge_MovementState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_TurnBlockBridge_ExtendDistance #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_TurnBlockBridge_WaitBeforeExtending #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr05F_BrownChainedPlatform_PreviousXPos #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr05F_BrownChainedPlatform_XAngleSpeedLo #= !RAM_SMW_Misc_ScratchRAM7E14B4
!RAM_SMW_NorSpr05F_BrownChainedPlatform_XAngleSpeedHi #= !RAM_SMW_NorSpr05F_BrownChainedPlatform_XAngleSpeedLo+$01
!RAM_SMW_NorSpr05F_BrownChainedPlatform_YAngleSpeedLo #= !RAM_SMW_Misc_ScratchRAM7E14B6
!RAM_SMW_NorSpr05F_BrownChainedPlatform_YAngleSpeedHi #= !RAM_SMW_NorSpr05F_BrownChainedPlatform_YAngleSpeedLo+$01
!RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosLo #= !RAM_SMW_Misc_ScratchRAM7E14B8
!RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosHi #= !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosLo+$01
!RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosLo #= !RAM_SMW_Misc_ScratchRAM7E14BA
!RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosHi #= !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosLo+$01
!RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleSpeed #= !RAM_SMW_NorSpr_Table7E1504
!RAM_SMW_NorSpr05F_BrownChainedPlatform_SubAngle #= !RAM_SMW_NorSpr_Table7E1510
!RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr05F_BrownChainedPlatform_PlayerOnPlatformFlag #= !RAM_SMW_NorSpr_Table7E1602
!RAM_SMW_NorSpr05F_BrownChainedPlatform_PlayerIsTouchingPlatformFlag #= !RAM_SMW_NorSpr_Table7E160E

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr060_FlatPalaceSwitch_WaitBeforeEraseSwitchObject #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr061_SkullRaft_FirstPlatformFlag #= !RAM_SMW_NorSpr_Table7E00C2

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_LineGuidedSprites_LineGuideSpeedTableIndexLo #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_LineGuidedSprites_LineGuideSpeedTableIndexHi #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSprXXX_LineGuidedSprites_LeftLineGuideSpeedTableIndex #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_LineGuidedSprites_RightLineGuideSpeedTableIndex #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSprXXX_LineGuidedSprites_MovementDirection #= !RAM_SMW_NorSpr_Table7E157C
!RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentltTouchedLineGuideTile #= !RAM_SMW_NorSpr_Table7E160E
!RAM_SMW_NorSprXXX_LineGuidedSprites_IsNotMovingFlag #= !RAM_SMW_NorSpr_Table7E1626
!RAM_SMW_NorSprXXX_LineGuidedSprites_TouchingPlayerFlag #= !RAM_SMW_NorSpr_DecrementingTable7E163E
!RAM_SMW_NorSprXXX_LineGuidedSprites_FasterMovementFlag #= !RAM_SMW_NorSpr_Table7E187B

!RAM_SMW_NorSpr062_BrownLineGuidePlatform_PlatformType #= !RAM_SMW_NorSpr_Table7E1602

!RAM_SMW_NorSpr063_CheckerboardLineGuidePlatform_PlatformType #= !RAM_SMW_NorSpr062_BrownLineGuidePlatform_PlatformType

!RAM_SMW_NorSpr064_LineGuideRope_PlayerYPosOffset #= !RAM_SMW_Misc_ScratchRAM7E185E
!RAM_SMW_NorSpr064_LineGuideRope_PlayerXPosOffset #= !RAM_SMW_Misc_ScratchRAM7E18B6

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr06A_CoinGameCloud_ResetCloudCoinCounter #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr06A_CoinGameCloud_SpawnedCoinCounter #= !RAM_SMW_NorSpr_Table7E1570

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_WallSpringboard_MaximumAngle #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_WallSpringboard_CurrentState #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSprXXX_WallSpringboard_CanBounceHigherTimer #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSprXXX_WallSpringboard_WaitBeforeAutoBounce #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_WallSpringboard_ReboundDirectionCounter #= !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr06F_DinoTorch_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr06F_DinoTorch_FireLength #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr06F_DinoTorch_BreathFireTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr070_Pokey_Segments #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr070_Pokey_DisconnectedUpperSegments #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr070_Pokey_DeadSegmentFlag #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr070_Pokey_ReconnectBodyTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr070_Pokey_DisableSegmentLossTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr070_Pokey_TurnTowardsMarioTimer #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr070_Pokey_HorizontalMovementDirection #= !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr073_GroundSuperKoopa_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr073_GroundSuperKoopa_TakeOffTimer #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr073_GroundSuperKoopa_HasFeatherFlag #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr073_GroundSuperKoopa_AnimationFrame = !RAM_SMW_NorSpr071_RedCapeSuperKoopa_AnimationFrame

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr079_VineHead_AppearBehindLayer1Timer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr07A_Fireworks_DecelerateTimer #= !RAM_SMW_NorSpr_XSpeed
!RAM_SMW_NorSpr07A_Fireworks_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr07A_Fireworks_ExpandingSpeed #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr07A_Fireworks_CurrentType #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr07A_Fireworks_WaitBeforeWhistleSound #= !RAM_SMW_NorSpr_DecrementingTable7E1564
!RAM_SMW_NorSpr07A_Fireworks_ColorFlashIndex #= !RAM_SMW_NorSpr_DecrementingTable7E1564+$09
!RAM_SMW_NorSpr07A_Fireworks_ExplosionSize #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr07A_Fireworks_WaitBeforeBangSound #= !RAM_SMW_NorSpr_DecrementingTable7E15AC
!RAM_SMW_NorSpr07A_Fireworks_ParticleAnimationSet #= !RAM_SMW_NorSpr_Table7E1602

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr07B_GoalTape_HitboxXPosLo #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr07B_GoalTape_HitboxXPosHi #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr07B_GoalTape_HitboxYPosLo #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr07B_GoalTape_HitboxYPosHi #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr07B_GoalTape_ChangeDirectionTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr07B_GoalTape_DisplayStarsTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr07B_GoalTape_VerticalDirection #= !RAM_SMW_NorSpr_Table7E1588
!RAM_SMW_NorSpr07B_GoalTape_RelativeYPosTapeWasHitAt #= !RAM_SMW_NorSpr_Table7E1594
!RAM_SMW_NorSpr07B_GoalTape_GoalCrossedFlag #= !RAM_SMW_NorSpr_Table7E1602
!RAM_SMW_NorSpr07B_GoalTape_BrokeTapeFlag #= !RAM_SMW_NorSpr_Table7E160E
; The goal tape's sprite record extra bits, and which exit crossing the tape
; activates. Status01 copies the whole Y position high byte here and masks the
; coordinate back down to bit 0, which is why the extra bits do not put the tape
; below the level the way they do every other sprite. Crossing it stores the two
; bits shifted down, plus one, into !RAM_SMW_Misc_ExitLevelAction: #$00 = the
; normal exit; #$01 = the secret exit; #$02 = moves the player to Yoshi's Island
; and activates no exit at all; #$03 = the fourth exit, which no overworld level
; tile has an event for.
!RAM_SMW_NorSpr07B_GoalTape_GoalType = !RAM_SMW_NorSpr0A3_GreyChainedPlatform_ChainLength 		;\ LM: LM changes how this address is stored to to allow goal tapes to trigger more secret exits.
													;/ It's normally not dependent on normal sprite 0A3's code (3.00+)

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr07C_PrincessPeach_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr07C_PrincessPeach_LandedOnMarioFlag #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr07C_PrincessPeach_FireworksCounter #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr07C_PrincessPeach_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr07C_PrincessPeach_WaitBeforeDrawingNextLetter #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr07C_PrincessPeach_BlinkTimer #= !RAM_SMW_NorSpr_DecrementingTable7E154C
!RAM_SMW_NorSpr07C_PrincessPeach_MarioBlushTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr07C_PrincessPeach_WaitBeforeSpawningFireworks #= !RAM_SMW_NorSpr_DecrementingTable7E1564
!RAM_SMW_NorSpr07C_PrincessPeach_SpawnFireworksTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1FE2+$09

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_FlyingItems_ItemToDraw #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_FlyingItems_VerticalDirection #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_FlyingItems_AppearBehindLayer1Timer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_PowerUps_IsChangingItem #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_PowerUps_RisingOutOfSpriteBlockFlag #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSprXXX_PowerUps_RisingOutOfBlockTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSprXXX_PowerUps_NoBlockSideInteractionTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSprXXX_PowerUps_IsBerryFlag #= !RAM_SMW_NorSpr_Table7E160E

!RAM_SMW_NorSpr077_Feather_HorizontalMovementDirection  #= !RAM_SMW_NorSpr_Table7E1528

!RAM_SMW_NorSpr081_ChangingItem_SpriteChangeCounter #= !RAM_SMW_NorSpr_Table7E187B

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr082_BonusGame_AnimationFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr082_BonusGame_HitAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr082_BonusGame_FlashBlockLineTimer #= !RAM_SMW_NorSpr_DecrementingTable7E154C
!RAM_SMW_NorSpr082_BonusGame_MovementDirection #= !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr083_LeftFlyingBlock_HitFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr083_LeftFlyingBlock_ContentsOfBlock #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr083_LeftFlyingBlock_HorizontalDirection #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr083_LeftFlyingBlock_WaitBeforeTurningAround #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr083_LeftFlyingBlock_BounceAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr083_LeftFlyingBlock_VerticalDirection #= !RAM_SMW_NorSpr_Table7E1594
!RAM_SMW_NorSpr083_LeftFlyingBlock_BlockContentsRisingTimer #= !RAM_SMW_NorSpr_DecrementingTable7E163E

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr086_Wiggler_IndividualSegmentFacingDirectionFlags #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr086_Wiggler_IsAngryFlag #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr086_Wiggler_TurnTowardsMarioWhileAngryTimer #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr086_Wiggler_StunnedTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr086_Wiggler_FlipSegmentsWhenTurningTimer #= !RAM_SMW_NorSpr_Table7E1602

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr087_LakituCloud_PlayerInCloudFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr087_LakituCloud_PlayerHasControlledCloudFlag #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr087_LakituCloud_VerticalDirection #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr087_LakituCloud_EvaporateTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr087_LakituCloud_LakituSpriteSlot #= !RAM_SMW_NorSpr_Table7E160E
!RAM_SMW_NorSpr087_LakituCloud_TempXPosLo #= !RAM_SMW_Misc_ScratchRAM7E14B0
!RAM_SMW_NorSpr087_LakituCloud_TempYPosLo #= !RAM_SMW_Misc_ScratchRAM7E14B2
!RAM_SMW_NorSpr087_LakituCloud_PlayerInCloudOAMIndex #= !RAM_SMW_Misc_ScratchRAM7E18B6

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr089_Layer3Smasher_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr089_Layer3Smasher_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr08A_Bird_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr08A_Bird_PeckingTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr08A_Bird_ForcedTurnAroundTimer #= !RAM_SMW_NorSpr_DecrementingTable7E154C
!RAM_SMW_NorSpr08A_Bird_ActionCounter #= !RAM_SMW_NorSpr_Table7E1570

;---------------------------------------------------------------------------

!RAM_SMW_NorSPr08B_FireplaceSmoke_XSpeedFrameCount #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSPr08B_FireplaceSmoke_NoHorizontalMovementFlag #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSPr08B_FireplaceSmoke_XDispIndex #= !RAM_SMW_NorSpr_Table7E151C

;---------------------------------------------------------------------------

!RAM_SMW_NorSPr08C_SideExitAndFireplace_FrameIndex #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSPr08C_SideExitAndFireplace_UnusedRAM #= !RAM_SMW_NorSpr019_DisplayMessage_WaitBeforeDisplayMessage

;---------------------------------------------------------------------------

!RAM_SMW_NorSPr08F_ScalePlatform_RightPlatformXPosLo #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosHi #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosLo #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSPr08F_ScalePlatform_RightPlatformXPosHi #= !RAM_SMW_NorSpr_Table7E1602
!RAM_SMW_NorSPr08F_ScalePlatform_PlayerIsOnSpriteFlag #= !RAM_SMW_Misc_ScratchRAM7E185E

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr090_GreenGasBubble_VerticalDirection #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr090_GreenGasBubble_HorizontalMovementDirection #= !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

!RAM_SMW_NorSprXXX_Chucks_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSprXXX_Chucks_HitCounter #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSprXXX_Chucks_HurtFrameCounter #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame #= !RAM_SMW_NorSpr_Table7E1602

!RAM_SMW_NorSpr046_DigginChuck_DiggingAnimationFrameCounter #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr046_DigginChuck_DiggingTimer = !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer
!RAM_SMW_NorSpr046_DigginChuck_HeadTurnTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr046_DigginChuck_ShovelAnimationFrame #= !RAM_SMW_NorSpr_Table7E1570

!RAM_SMW_NorSpr091_CharginChuck_HeadTurnCounter #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr091_CharginChuck_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr091_CharginChuck_HeadAnimationFrameCounter #= !RAM_SMW_NorSpr_Table7E1594
!RAM_SMW_NorSpr091_CharginChuck_WaitBeforeChargingTimer #= !RAM_SMW_NorSpr_DecrementingTable7E15AC
!RAM_SMW_NorSpr091_CharginChuck_UnusedLineOfSightTimer #= !RAM_SMW_NorSpr_DecrementingTable7E163E
!RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag #= !RAM_SMW_NorSpr_Table7E187B

!RAM_SMW_NorSpr092_SplittinChuck_WaitBeforeSplittin #= !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer
!RAM_SMW_NorSpr092_SplittinChuck_SpawnChuckIndex #= !RAM_SMW_Misc_ScratchRAM7E185E

!RAM_SMW_NorSpr093_BouncinChuck_WaitBeforeSplittin #= !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer

!RAM_SMW_NorSpr095_ClappinChuck_WaitBeforeJumpsOrHops #= !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer
!RAM_SMW_NorSpr095_ClappinChuck_JumpingFlag #= !RAM_SMW_NorSpr_Table7E160E
!RAM_SMW_NorSpr095_ClappinChuck_WaitBeforeClapSound #= !RAM_SMW_NorSpr_DecrementingTable7E1FE2

!RAM_SMW_NorSpr098_PitchinChuck_JumpingFlag #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr098_PitchinChuck_PhaseTimer #= !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer
!RAM_SMW_NorSpr098_PitchinChuck_WaitBeforeThrowingNextBaseball #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr098_PitchinChuck_BaseballThrowSetIndex #= !RAM_SMW_NorSpr_Table7E187B

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr099_VolcanoLotus_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr099_VolcanoLotus_FlashingPaletteFlag #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr099_VolcanoLotus_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr09A_SumoBro_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr09A_SumoBro_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr09A_SumoBro_WaitBeforeNextStep #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr09A_SumoBro_StepsTaken #= !RAM_SMW_NorSpr_Table7E1570

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr09B_HammerBro_WaitBeforeThowingNextHammer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr09C_HammerBroPlatform_HitFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr09C_HammerBroPlatform_VerticalDirection #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr09C_HammerBroPlatform_HorizontalDirection #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr09C_HammerBroPlatform_BounceAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr09C_HammerBroPlatform_HammerBroOnPlatformSpriteSlot #= !RAM_SMW_NorSpr_Table7E1594

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr09D_BubbleWithSprite_Contents #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr09D_BubbleWithSprite_VerticalDirection #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr09D_BubbleWithSprite_TimerUntilPopping #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr09D_BubbleWithSprite_HorizontalDirection #= !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr09E_BallNChain_UnknownClusterSpriteRAM = !RAM_SMW_NorSpr0A3_GreyChainedPlatform_UnknownClusterSpriteRAM
!RAM_SMW_NorSpr09E_BallNChain_CurrentAngleHi = !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleHi
!RAM_SMW_NorSpr09E_BallNChain_PreviousXPos = !RAM_SMW_NorSpr0A3_GreyChainedPlatform_PreviousXPos
!RAM_SMW_NorSpr09E_BallNChain_CurrentAngleLo = !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleLo
!RAM_SMW_NorSpr09E_BallNChain_ChainLength = !RAM_SMW_NorSpr0A3_GreyChainedPlatform_ChainLength

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack #= !RAM_SMW_Misc_ScratchRAM7E14B0
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeMechaKoopaThrow #= !RAM_SMW_Misc_ScratchRAM7E14B1
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_ScalingDirection #= !RAM_SMW_Misc_ScratchRAM7E14B2
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_TearDropYDispIndex #= !RAM_SMW_Misc_ScratchRAM7E14B3
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_SongToPlayIndex #= !RAM_SMW_Misc_ScratchRAM7E14B4
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_HurtStateTimer #= !RAM_SMW_Misc_ScratchRAM7E14B5
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeBowlingBallDrop #= !RAM_SMW_Misc_ScratchRAM7E14B6
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_FireballInitialXPosLo #= !RAM_SMW_Misc_ScratchRAM7E14B7
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_Phase2AttackCounter #= !RAM_SMW_Misc_ScratchRAM7E14B8
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_HorizontalAccelerationDirection #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_VerticalAccelerationDirection #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_DuckingAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeTurningUpsideDown #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_DisableMarioContactTimer #= !RAM_SMW_NorSpr_DecrementingTable7E154C
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeAttackPhase1 #= !RAM_SMW_NorSpr_DecrementingTable7E154C
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeSpawningPeach #= !RAM_SMW_NorSpr_DecrementingTable7E154C
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_ClownCarBlinkAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_SmokePuffTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1564
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_FacingFirection #= !RAM_SMW_NorSpr_Table7E157C
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_HelpAnimationTimer #= !RAM_SMW_NorSpr_Table7E1594
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_PeachKissMusicIsPlaying #= !RAM_SMW_NorSpr_Table7E164A
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_HPForCurrentPhase #= !RAM_SMW_NorSpr_Table7E187B

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0A2_MechaKoopa_WaitBeforeTurningAround #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0A2_MechaKoopa_StunTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0A3_GreyChainedPlatform_UnknownClusterSpriteRAM #= !RAM_SMW_ClusterSpr_Table7E0F86
!RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleHi #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr0A3_GreyChainedPlatform_PreviousXPos #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleLo #= !RAM_SMW_NorSpr_Table7E1602
!RAM_SMW_NorSpr0A3_GreyChainedPlatform_PlayerOnPlatformFlag #= !RAM_SMW_NorSpr_Table7E160E
!RAM_SMW_NorSpr0A3_GreyChainedPlatform_ChainLength #= !RAM_SMW_NorSpr_Table7E187B

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0A7_IggyBall_HorizontalMovementDirection #= !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0A8_Blargg_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0A8_Blargg_InitialXPosHi #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr0A8_Blargg_InitialXPosLo #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr0A8_Blargg_InitialYPosHi #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr0A8_Blargg_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr0A8_Blargg_InitialYPosLo #= !RAM_SMW_NorSpr_Table7E1594
!RAM_SMW_NorSpr0A8_Blargg_AttackingAnimationFrame #= !RAM_SMW_NorSpr_AnimationFrame

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0A9_Reznor_SpriteGFXToLoad #= !RAM_SMW_NorSprXXX_CurrentlyActiveBoss
!RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr0A9_Reznor_FiringAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr0A9_Reznor_PlatformBounceTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1564
!RAM_SMW_NorSpr0A9_Reznor_WaitBeforeShootingFire #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr0A9_Reznor_WaitBeforeEndingLevel #= !RAM_SMW_NorSpr_DecrementingTable7E163E

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0AA_Fishbone_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0AA_Fishbone_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr0AA_Fishbone_BlinkAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0AB_Rex_StompCounter #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0AB_Rex_ShowSquishedStateTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr0AB_Rex_DisableCapeAndBounceSpriteContactTimer #= !RAM_SMW_NorSpr_Table7E15D0
!RAM_SMW_NorSpr0AB_Rex_WaitAfterFirstStomp #= !RAM_SMW_NorSpr_DecrementingTable7E1FE2

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_InitialMovementDirection #= !RAM_SMW_NorSpr01E_Lakitu_FishingFlag
!RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_WaitBeforeNextPhase #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0AE_FishinBoo_VerticalDirection #= !RAM_SMW_NorSpr_Table7E00C2

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0B1_CreateEatBlock_BlockType #= !RAM_SMW_NorSpr01E_Lakitu_FishingFlag
!RAM_SMW_NorSpr0B1_CreateEatBlock_CreatePathIndex #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr0B1_CreateEatBlock_TilesRemainingInCurrentDirection #= !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr0B1_CreateEatBlock_MovementDirection #= !RAM_SMW_NorSpr_Table7E157C
!RAM_SMW_NorSpr0B1_CreateEatBlock_CurrentMovementData #= !RAM_SMW_NorSpr_Table7E1602

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0B2_FallingSpike_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0B2_FallingSpike_ShakingTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0B7_CarrotTopLiftUpperRight_MovementTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0B9_MessageBox_HitFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0B9_MessageBox_BounceAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr0B9_MessageBox_UnusedBounceAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1564

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0BA_TimedPlatform_ActivatedFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0BA_TimedPlatform_ClockTimer #= !RAM_SMW_NorSpr_Table7E1570

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0BB_MovingCastleStone_MovementPhase #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0BB_MovingCastleStone_MovementTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0BC_BowserStatue_StatueType #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0BC_BowserStatue_WaitBeforeJumping #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0BD_SlidingNakedBlueKoopa_WaitBeforeFalling #= !RAM_SMW_NorSpr09A_SumoBro_PhaseTimer
!RAM_SMW_NorSpr0BD_SlidingNakedBlueKoopa_WaitBeforeTurningIntoKoopa #= !RAM_SMW_NorSpr_DecrementingTable7E1558

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0BE_Swooper_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0BE_Swooper_VerticalDirection #= !RAM_SMW_NorSpr_Table7E151C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0BF_MegaMole_FacingDirection #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr0BF_MegaMole_WaitBeforeFalling  #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr0BF_MegaMole_MovementDirection #= !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0C0_SinkingLavaPlatform_DespawnTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0C1_WingedPlatform_FlyDownInitiallyFlag #= !RAM_SMW_NorSpr01E_Lakitu_FishingFlag
!RAM_SMW_NorSpr0C1_WingedPlatform_VerticalMovementTimerHi #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr0C1_WingedPlatform_VerticalDirection #= !RAM_SMW_NorSpr_Table7E157C
!RAM_SMW_NorSpr0C1_WingedPlatform_VerticalMovementTimerLo #= !RAM_SMW_NorSpr_Table7E1602

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0C2_Blurp_VerticalDirection #= !RAM_SMW_NorSpr_Table7E00C2

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0C4_GreyFallingPlatform_WaitBeforeFall #= !RAM_SMW_NorSpr_DecrementingTable7E1540

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0C5_BigBooBoss_CurrentState #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0C5_BigBooBoss_HorizontalDirection #= !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr0C5_BigBooBoss_VerticalDirection #= !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_NorSpr0C5_BigBooBoss_HitCounter #= !RAM_SMW_NorSpr_Table7E1534
!RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
!RAM_SMW_NorSpr0C5_BigBooBoss_UnusedPeekingTimer #= !RAM_SMW_NorSprXXX_NonBossBoos_IdleAnimationTimer
!RAM_SMW_NorSpr0C5_BigBooBoss_FadeInFrameCounter #= !RAM_SMW_NorSpr_AnimationFrameCounter

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0C6_Spotlight_OnFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0C6_Spotlight_DeleteOtherSpotlightsFlag #= !RAM_SMW_NorSpr_Table7E1534

;---------------------------------------------------------------------------

!RAM_SMW_NorSpr0C8_LightSwitch_HitFlag #= !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_NorSpr0C8_LightSwitch_BounceAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1558
!RAM_SMW_NorSpr0C8_LightSwitch_UnusedBounceAnimationTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1564

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr01_SmokePuff_DespawnTimer #= !RAM_SMW_ExtSpr_DecrementingTable7E176F

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr03_FlameRemnant_AnimationFrameCounter #= !RAM_SMW_ExtSpr_Table7E1765
!RAM_SMW_ExtSpr03_FlameRemnant_DespawnTimer #= !RAM_SMW_ExtSpr_DecrementingTable7E176F

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr04_Hammer_AnimationFrameCounter #= !RAM_SMW_ExtSpr_Table7E1765

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr05_MarioFireball_CurrentLayerPriority #= !RAM_SMW_ExtSpr_Table7E1779

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr06_ThrownBone_UnknownRAM7E1765 #= !RAM_SMW_ExtSpr_Table7E1765

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr07_LavaSplash_AnimationFrameCounter #= !RAM_SMW_ExtSpr_DecrementingTable7E176F

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr08_LauncherArm_VerticalDirectionTimer #= !RAM_SMW_ExtSpr_DecrementingTable7E176F

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr0A_CloudCoin_DisableBlockCollisionFlag #= !RAM_SMW_ExtSpr_Table7E1765

!RAM_SMW_ExtSpr0E_WigglerFlower_DisableBlockCollisionFlag #= !RAM_SMW_ExtSpr0A_CloudCoin_DisableBlockCollisionFlag

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr0F_SmokeTrail_DespawnTimer #= !RAM_SMW_ExtSpr_DecrementingTable7E176F

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr10_SpinJumpStars_DespawnTimer #= !RAM_SMW_ExtSpr_DecrementingTable7E176F

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr11_YoshiFireball_CurrentLayerPriority #= !RAM_SMW_ExtSpr05_MarioFireball_CurrentLayerPriority

;---------------------------------------------------------------------------

!RAM_SMW_ExtSpr12_BreathBubble_AnimationFrameCounter #= !RAM_SMW_ExtSpr_Table7E1765

;---------------------------------------------------------------------------

!RAM_SMW_ClusterSpr01_1up_YSpeed #= !RAM_SMW_ClusterSpr_Table7E1E52
!RAM_SMW_ClusterSpr01_1up_XSpeed #= !RAM_SMW_ClusterSpr_Table7E1E66
!RAM_SMW_ClusterSpr01_1up_SubXPos #= !RAM_SMW_ClusterSpr_Table7E1E7A

;---------------------------------------------------------------------------

!RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F4A #= !RAM_SMW_ClusterSpr_Table7E0F4A
!RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F72 #= !RAM_SMW_ClusterSpr_Table7E0F72
!RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F86 #= !RAM_SMW_ClusterSpr_Table7E0F86
!RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F9A #= !RAM_SMW_ClusterSpr_Table7E0F9A
!RAM_SMW_ClusterSpr03_BooCeiling_UnknownRAM #= !RAM_SMW_ClusterSpr04_BooRing_RingIndex
!RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E52 #= !RAM_SMW_ClusterSpr_Table7E1E52
!RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E66 #= !RAM_SMW_ClusterSpr_Table7E1E66

!RAM_SMW_ClusterSpr08_DeathBatCeiling_UnknownTable7E0F4A #= !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F4A
!RAM_SMW_ClusterSpr08_DeathBatCeiling_UnknownTable7E0F72 #= !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F72
!RAM_SMW_ClusterSpr08_DeathBatCeiling_UnknownTable7E0F86 #= !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F86
!RAM_SMW_ClusterSpr08_DeathBatCeiling_UnknownTable7E0F9A #= !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F9A
!RAM_SMW_ClusterSpr08_DeathBatCeiling_UnknownTable7E1E52 #= !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E52
!RAM_SMW_ClusterSpr08_DeathBatCeiling_UnknownTable7E1E66 #= !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E66

;---------------------------------------------------------------------------

!RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F4A #= !RAM_SMW_ClusterSpr_Table7E0F4A
!RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F72 #= !RAM_SMW_ClusterSpr_Table7E0F72
!RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F86 #= !RAM_SMW_ClusterSpr_Table7E0F86
!RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E1E66 #= !RAM_SMW_ClusterSpr_Table7E1E66

;---------------------------------------------------------------------------

!RAM_SMW_ClusterSpr05_CandleFlame_UnknownTable7E0F4A #= !RAM_SMW_ClusterSpr_Table7E0F4A

;---------------------------------------------------------------------------

!RAM_SMW_ClusterSpr06_SumoBroFlame_DespawnTimer #= !RAM_SMW_ClusterSpr_Table7E0F4A

;---------------------------------------------------------------------------

!RAM_SMW_ClusterSpr07_ReappearingBoo_BooSet #= !RAM_SMW_ClusterSpr04_BooRing_RingIndex
!RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E52 #= !RAM_SMW_ClusterSpr_Table7E1E52
!RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E66 #= !RAM_SMW_ClusterSpr_Table7E1E66
!RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E7A #= !RAM_SMW_ClusterSpr_Table7E1E7A
!RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E8E #= !RAM_SMW_ClusterSpr_Table7E1E8E

;---------------------------------------------------------------------------

!RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0DF5 #= !RAM_SMW_OWSpr_Table7E0DF5
!RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E05 #= !RAM_SMW_OWSpr_Table7E0E05
!RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E15 #= !RAM_SMW_OWSpr_Table7E0E15

;---------------------------------------------------------------------------

!RAM_SMW_OWSpr03_CheepCheep_UnknownTable7E0DF5 #= !RAM_SMW_OWSpr_Table7E0DF5
!RAM_SMW_OWSpr03_CheepCheep_UnknownTable7E0E25 #= !RAM_SMW_OWSpr_Table7E0E25

;---------------------------------------------------------------------------

!RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0DF5 #= !RAM_SMW_OWSpr_Table7E0DF5
!RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0E05 #= !RAM_SMW_OWSpr_Table7E0E05
!RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0E25 #= !RAM_SMW_OWSpr_Table7E0E25

;---------------------------------------------------------------------------

!RAM_SMW_OWSpr09_Bowser_UnknownTable7E0DF5 #= !RAM_SMW_OWSpr_Table7E0DF5
!RAM_SMW_OWSpr09_Bowser_UnknownTable7E0E05 #= !RAM_SMW_OWSpr_Table7E0E05
!RAM_SMW_OWSpr09_Bowser_UnknownTable7E0E15 #= !RAM_SMW_OWSpr_Table7E0E15

;---------------------------------------------------------------------------

!RAM_SMW_OWSpr0A_Boo_UnknownTable7E0DF5 #= !RAM_SMW_OWSpr_Table7E0DF5
!RAM_SMW_OWSpr0A_Boo_UnknownTable7E0E25 #= !RAM_SMW_OWSpr_Table7E0E25

;---------------------------------------------------------------------------