;####################################################################
;# Bank05.asm -- level data.
;#
;# 104 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank05Macros(StartBank, EndBank)
%BANK_START(<StartBank>)
ROUTINE_RT01_SMW_InitializeMap16Pointers:	%ROUTINE_RT01_SMW_InitializeMap16Pointers(NULLROM)				; $058000
ROUTINE_RT00_SMW_LoadSublevel:	%ROUTINE_RT00_SMW_LoadSublevel(NULLROM)					; $05801E
ROUTINE_SMW_InitializeLevelLayer1And2Tilemaps:	%ROUTINE_SMW_InitializeLevelLayer1And2Tilemaps(NULLROM)			; $05809E
ROUTINE_SMW_BufferBGTilemap:	%ROUTINE_SMW_BufferBGTilemap(NULLROM)						; $058126
ROUTINE_RT00_SMW_InitializeMap16Pointers:	%ROUTINE_RT00_SMW_InitializeMap16Pointers(NULLROM)				; $0581BB
ROUTINE_SMW_InitializeLevelData:	%ROUTINE_SMW_InitializeLevelData(NULLROM)					; $0582C8
ROUTINE_SMW_BeginLoadingLevelData:	%ROUTINE_SMW_BeginLoadingLevelData(NULLROM)					; $0583AC
ROUTINE_SMW_LoadLevelHeader:	%ROUTINE_SMW_LoadLevelHeader(NULLROM)						; $058417
ROUTINE_SMW_LoadLevelDataObject:	%ROUTINE_SMW_LoadLevelDataObject(NULLROM)					; $0585D8
ROUTINE_SMW_CheckIfLevelTilemapsNeedScrollUpdate:	%ROUTINE_SMW_CheckIfLevelTilemapsNeedScrollUpdate(NULLROM)			; $0586F1
ROUTINE_SMW_CalculateRowOrColumnOfTilemapToUpdate:	%ROUTINE_SMW_CalculateRowOrColumnOfTilemapToUpdate(NULLROM)			; $058776
ROUTINE_RT00_SMW_BufferScrollingTiles:	%ROUTINE_RT00_SMW_BufferScrollingTiles(NULLROM)				; $05881A
DATATABLE_RT04_SMW_BitTable:	%DATATABLE_RT04_SMW_BitTable(NULLROM)						; $0589BE
ROUTINE_RT01_SMW_BufferScrollingTiles:	%ROUTINE_RT01_SMW_BufferScrollingTiles(NULLROM)				; $0589CE
INLINEDATATABLE_RT19_SMW_EmptySpace:	%INLINEDATATABLE_RT19_SMW_EmptySpace(NULLROM)					; $058E19
ROUTINE_RT01_SMW_InitializeLevelLayer3:	%ROUTINE_RT01_SMW_InitializeLevelLayer3(NULLROM)				; $059000
DATATABLE_RT00_SMW_Backgrounds:	%DATATABLE_RT00_SMW_Backgrounds(NULLROM)					; $059087
INLINEDATATABLE_RT20_SMW_EmptySpace:	%INLINEDATATABLE_RT20_SMW_EmptySpace(NULLROM)					; $05A562
DATATABLE_SMW_DisplayMessage:	%DATATABLE_SMW_DisplayMessage(NULLROM)					; $05A580
ROUTINE_SMW_DisplayMessage:	%ROUTINE_SMW_DisplayMessage(NULLROM)						; $05B0FF
ROUTINE_SMW_GiveCoins:	%ROUTINE_SMW_GiveCoins(NULLROM)						; $05B329
DATATABLE_RT03_SMW_BitTable:	%DATATABLE_RT03_SMW_BitTable(NULLROM)						; $05B35B
ROUTINE_SMW_UnusedOverworldEventPassedCheck:	%ROUTINE_SMW_UnusedOverworldEventPassedCheck(NULLROM)				; $05B363
ROUTINE_RT01_SMW_GameMode04_PrepareTitleScreen:	%ROUTINE_RT01_SMW_GameMode04_PrepareTitleScreen(NULLROM)			; $05B375
DATATABLE_SMW_FileSelectText:	%DATATABLE_SMW_FileSelectText(NULLROM)						; $05B6FE
DATATABLE_SMW_XPlayerGameText:	%DATATABLE_SMW_XPlayerGameText(NULLROM)					; $05B872
DATATABLE_SMW_SaveMenuText:	%DATATABLE_SMW_SaveMenuText(NULLROM)						; $05B8C7
DATATABLE_SMW_ContinueEndText:	%DATATABLE_SMW_ContinueEndText(NULLROM)					; $05B91C
ROUTINE_SMW_LevelTileAnimations:	%ROUTINE_SMW_LevelTileAnimations(NULLROM)					; $05B93B
INLINEDATATABLE_RT21_SMW_EmptySpace:	%INLINEDATATABLE_RT21_SMW_EmptySpace(NULLROM)					; $05BBA6
ROUTINE_SMW_HandleScrollSpriteAndLayer3Scrolling:	%ROUTINE_SMW_HandleScrollSpriteAndLayer3Scrolling(NULLROM)			; $05BC00
ROUTINE_RT01_SMW_ProcessScrollSprites:	%ROUTINE_RT01_SMW_ProcessScrollSprites(NULLROM)				; $05BC49
ROUTINE_SMW_ScrollSecondInteractiveLayer:	%ROUTINE_SMW_ScrollSecondInteractiveLayer(NULLROM)				; $05BC4A
ROUTINE_RT00_SMW_ProcessScrollSprites:	%ROUTINE_RT00_SMW_ProcessScrollSprites(NULLROM)				; $05BC76
ROUTINE_SMW_InitializeScrollSprites:	%ROUTINE_SMW_InitializeScrollSprites(NULLROM)					; $05BCD6
ROUTINE_RT00_SMW_NorSpr0E7_SpecialAutoScroll:	%ROUTINE_RT00_SMW_NorSpr0E7_SpecialAutoScroll(NULLROM)				; $05BD36
ROUTINE_RT00_SMW_MostlyUnusedScrollSpriteRoutine:	%ROUTINE_RT00_SMW_MostlyUnusedScrollSpriteRoutine(NULLROM)			; $05BD7B
ROUTINE_RT00_SMW_NorSpr0EB_UnusedSprite:	%ROUTINE_RT00_SMW_NorSpr0EB_UnusedSprite(NULLROM)				; $05BDDD
ROUTINE_RT00_SMW_NorSpr0F1_UnusedSprite:	%ROUTINE_RT00_SMW_NorSpr0F1_UnusedSprite(NULLROM)				; $05BE3A
ROUTINE_RT05_SMW_GameMode12_PrepareLevel:	%ROUTINE_RT05_SMW_GameMode12_PrepareLevel(NULLROM)				; $05BE8A
ROUTINE_RT00_SMW_NorSpr0EF_Layer2ScrollSOrL:	%ROUTINE_RT00_SMW_NorSpr0EF_Layer2ScrollSOrL(NULLROM)				; $05BEA6
ROUTINE_RT00_SMW_NorSpr0EA_Layer2Scroll:	%ROUTINE_RT00_SMW_NorSpr0EA_Layer2Scroll(NULLROM)				; $05BF0A
ROUTINE_RT00_SMW_NorSpr0E9_Layer2Smash:	%ROUTINE_RT00_SMW_NorSpr0E9_Layer2Smash(NULLROM)				; $05BF6A
ROUTINE_SMW_NorSpr0ED_Layer2Falls:	%ROUTINE_SMW_NorSpr0ED_Layer2Falls(NULLROM)					; $05BF97
ROUTINE_SMW_NorSpr0EC_UnusedSprite:	%ROUTINE_SMW_NorSpr0EC_UnusedSprite(NULLROM)					; $05BFBA
ROUTINE_SMW_NorSpr0F2_Layer2OnOffControlled:	%ROUTINE_SMW_NorSpr0F2_Layer2OnOffControlled(NULLROM)				; $05BFF6
ROUTINE_SMW_NorSpr0F3_RegularAutoScroll:	%ROUTINE_SMW_NorSpr0F3_RegularAutoScroll(NULLROM)				; $05BFFD
ROUTINE_SMW_NorSpr0F4_FastBGScroll:	%ROUTINE_SMW_NorSpr0F4_FastBGScroll(NULLROM)					; $05C01A
ROUTINE_RT00_SMW_NorSpr0F5_Layer2ScrollWhenTouched:	%ROUTINE_RT00_SMW_NorSpr0F5_Layer2ScrollWhenTouched(NULLROM)			; $05C036
ROUTINE_RT00_SMW_Layer1SpecialScrolling01_VariableScroll:	%ROUTINE_RT00_SMW_Layer1SpecialScrolling01_VariableScroll(NULLROM)		; $05C04D
ROUTINE_SMW_Layer2SpecialScrolling01_VariableScroll:	%ROUTINE_SMW_Layer2SpecialScrolling01_VariableScroll(NULLROM)			; $05C198
ROUTINE_RT00_SMW_UnusedScrollSpriteRoutine:	%ROUTINE_RT00_SMW_UnusedScrollSpriteRoutine(NULLROM)				; $05C1AE
ROUTINE_RT00_SMW_Layer2SpecialScrolling04_Unused:	%ROUTINE_RT00_SMW_Layer2SpecialScrolling04_Unused(NULLROM)			; $05C283
ROUTINE_RT00_SMW_Layer2SpecialScrolling0A_Unused:	%ROUTINE_RT00_SMW_Layer2SpecialScrolling0A_Unused(NULLROM)			; $05C32E
ROUTINE_RT00_SMW_ScrollLayer3:	%ROUTINE_RT00_SMW_ScrollLayer3(NULLROM)					; $05C406
ROUTINE_SMW_UpdateLayerPositionWithScrollSprite:	%ROUTINE_SMW_UpdateLayerPositionWithScrollSprite(NULLROM)			; $05C4F9
ROUTINE_SMW_Layer2SpecialScrolling08_Layer2ScrollSOrL:	%ROUTINE_SMW_Layer2SpecialScrolling08_Layer2ScrollSOrL(NULLROM)		; $05C51F
ROUTINE_SMW_Layer2SpecialScrolling03_Layer2Scroll:	%ROUTINE_SMW_Layer2SpecialScrolling03_Layer2Scroll(NULLROM)			; $05C5BB
ROUTINE_SMW_Layer2SpecialScrolling06_Unused:	%ROUTINE_SMW_Layer2SpecialScrolling06_Unused(NULLROM)				; $05C659
ROUTINE_SMW_Layer1SpecialScrolling05_Unused:	%ROUTINE_SMW_Layer1SpecialScrolling05_Unused(NULLROM)				; $05C69E
ROUTINE_SMW_Layer2SpecialScrolling0B_Layer2OnOffControlled:	%ROUTINE_SMW_Layer2SpecialScrolling0B_Layer2OnOffControlled(NULLROM)		; $05C71B
ROUTINE_SMW_Layer1SpecialScrolling0C_RegularAutoScroll:	%ROUTINE_SMW_Layer1SpecialScrolling0C_RegularAutoScroll(NULLROM)		; $05C787
ROUTINE_SMW_Layer2SpecialScrolling0D_FastBGScroll:	%ROUTINE_SMW_Layer2SpecialScrolling0D_FastBGScroll(NULLROM)			; $05C7BC
ROUTINE_RT01_SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched:	%ROUTINE_RT01_SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched(NULLROM)	; $05C7F0
ROUTINE_RT01_SMW_NorSpr0F5_Layer2ScrollWhenTouched:	%ROUTINE_RT01_SMW_NorSpr0F5_Layer2ScrollWhenTouched(NULLROM)			; $05C808
ROUTINE_RT00_SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched:	%ROUTINE_RT00_SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched(NULLROM)	; $05C80E
ROUTINE_RT01_SMW_Layer2SpecialScrolling02_Layer2Smash:	%ROUTINE_RT01_SMW_Layer2SpecialScrolling02_Layer2Smash(NULLROM)		; $05C880
ROUTINE_RT01_SMW_NorSpr0E9_Layer2Smash:	%ROUTINE_RT01_SMW_NorSpr0E9_Layer2Smash(NULLROM)				; $05C94F
ROUTINE_RT00_SMW_Layer2SpecialScrolling02_Layer2Smash:	%ROUTINE_RT00_SMW_Layer2SpecialScrolling02_Layer2Smash(NULLROM)		; $05C955
ROUTINE_RT01_SMW_NorSpr0E7_SpecialAutoScroll:	%ROUTINE_RT01_SMW_NorSpr0E7_SpecialAutoScroll(NULLROM)				; $05C9D1
ROUTINE_RT01_SMW_MostlyUnusedScrollSpriteRoutine:	%ROUTINE_RT01_SMW_MostlyUnusedScrollSpriteRoutine(NULLROM)			; $05C9E5
ROUTINE_RT01_SMW_NorSpr0EB_UnusedSprite:	%ROUTINE_RT01_SMW_NorSpr0EB_UnusedSprite(NULLROM)				; $05CA08
ROUTINE_RT01_SMW_NorSpr0F1_UnusedSprite:	%ROUTINE_RT01_SMW_NorSpr0F1_UnusedSprite(NULLROM)				; $05CA16
ROUTINE_RT01_SMW_NorSpr0EF_Layer2ScrollSOrL:	%ROUTINE_RT01_SMW_NorSpr0EF_Layer2ScrollSOrL(NULLROM)				; $05CA3E
ROUTINE_RT01_SMW_NorSpr0EA_Layer2Scroll:	%ROUTINE_RT01_SMW_NorSpr0EA_Layer2Scroll(NULLROM)				; $05CA48
ROUTINE_RT02_SMW_NorSpr0E7_SpecialAutoScroll:	%ROUTINE_RT02_SMW_NorSpr0E7_SpecialAutoScroll(NULLROM)				; $05CA61
ROUTINE_RT01_SMW_Layer1SpecialScrolling01_VariableScroll:	%ROUTINE_RT01_SMW_Layer1SpecialScrolling01_VariableScroll(NULLROM)		; $05CA6F
ROUTINE_RT01_SMW_UnusedScrollSpriteRoutine:	%ROUTINE_RT01_SMW_UnusedScrollSpriteRoutine(NULLROM)				; $05CB7B
ROUTINE_RT01_SMW_Layer2SpecialScrolling04_Unused:	%ROUTINE_RT01_SMW_Layer2SpecialScrolling04_Unused(NULLROM)			; $05CB9B
ROUTINE_RT01_SMW_Layer2SpecialScrolling0A_Unused:	%ROUTINE_RT01_SMW_Layer2SpecialScrolling0A_Unused(NULLROM)			; $05CBA3
ROUTINE_RT01_SMW_ScrollLayer3:	%ROUTINE_RT01_SMW_ScrollLayer3(NULLROM)					; $05CBBB
DATATABLE_RT00_SMW_SharedScrollSpriteTables:	%DATATABLE_RT00_SMW_SharedScrollSpriteTables(NULLROM)				; $05CBC3
ROUTINE_RT02_SMW_Layer2SpecialScrolling04_Unused:	%ROUTINE_RT02_SMW_Layer2SpecialScrolling04_Unused(NULLROM)			; $05CBE3
ROUTINE_RT02_SMW_Layer2SpecialScrolling0A_Unused:	%ROUTINE_RT02_SMW_Layer2SpecialScrolling0A_Unused(NULLROM)			; $05CBE5
ROUTINE_RT02_SMW_ScrollLayer3:	%ROUTINE_RT02_SMW_ScrollLayer3(NULLROM)					; $05CBEB
DATATABLE_RT01_SMW_SharedScrollSpriteTables:	%DATATABLE_RT01_SMW_SharedScrollSpriteTables(NULLROM)				; $05CBED
ROUTINE_SMW_ProcessLevelEndRoutines:	%ROUTINE_SMW_ProcessLevelEndRoutines(NULLROM)					; $05CBFF
DATATABLE_SMW_CourseClearText:	%DATATABLE_SMW_CourseClearText(NULLROM)					; $05CC16
ROUTINE_SMW_ShowCourseClearText:	%ROUTINE_SMW_ShowCourseClearText(NULLROM)					; $05CC66
DATATABLE_SMW_GotBonusStarsText:	%DATATABLE_SMW_GotBonusStarsText(NULLROM)					; $05CD3F
ROUTINE_SMW_DisplayCourseClearTextBonusStars:	%ROUTINE_SMW_DisplayCourseClearTextBonusStars(NULLROM)				; $05CD62
ROUTINE_SMW_AdjustTimeBonusDisplay:	%ROUTINE_SMW_AdjustTimeBonusDisplay(NULLROM)					; $05CDE9
ROUTINE_SMW_CalculateTimeBonusDigits:	%ROUTINE_SMW_CalculateTimeBonusDigits(NULLROM)					; $05CE3A
DATATABLE_SMW_NoBonusStarsText:	%DATATABLE_SMW_NoBonusStarsText(NULLROM)					; $05CEA3
ROUTINE_SMW_GiveTimeBonusAndBonusStars:	%ROUTINE_SMW_GiveTimeBonusAndBonusStars(NULLROM)				; $05CEC2
INLINEDATATABLE_RT22_SMW_EmptySpace:	%INLINEDATATABLE_RT22_SMW_EmptySpace(NULLROM)					; $05CFEA
DATATABLE_RT05_SMW_Map16Data:	%DATATABLE_RT05_SMW_Map16Data(NULLROM)						; $05D000
ROUTINE_RT00_SMW_SpecifySublevelToLoad:	%ROUTINE_RT00_SMW_SpecifySublevelToLoad(NULLROM)				; $05D608
INLINEDATATABLE_RT23_SMW_EmptySpace:	%INLINEDATATABLE_RT23_SMW_EmptySpace(NULLROM)					; $05D668
ROUTINE_RT01_SMW_SpecifySublevelToLoad:	%ROUTINE_RT01_SMW_SpecifySublevelToLoad(NULLROM)				; $05D708
ROUTINE_SMW_LoadOverworldLifeCounter:	%ROUTINE_SMW_LoadOverworldLifeCounter(NULLROM)					; $05DBC9
ROUTINE_RT02_SMW_HexToDec:	%ROUTINE_RT02_SMW_HexToDec(NULLROM)						; $05DC3A
INLINEDATATABLE_RT24_SMW_EmptySpace:	%INLINEDATATABLE_RT24_SMW_EmptySpace(NULLROM)					; $05DC46
ROUTINE_RT02_SMW_SpecifySublevelToLoad:	%ROUTINE_RT02_SMW_SpecifySublevelToLoad(NULLROM)				; $05E000
%BANK_END(<EndBank>)
endmacro

macro ROUTINE_RT02_SMW_HexToDec(Address)
namespace SMW_HexToDec
%InsertMacroAtXPosition(<Address>)

Bank05:
	%INLINEROUTINE_SMW_HexToDec(X)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

;Credit: SubconsciousEye on Discord helped me out with the following routine.

macro ROUTINE_SMW_LevelTileAnimations(Address)
namespace SMW_LevelTileAnimations
%InsertMacroAtXPosition(<Address>)

; Destination VRAM addresses for animated tiles. There are 6 bytes, 3 16-bit
; addresses, for each of the 8 possible animation frames (index = (frame &
; 7) * 6), and their values get stored to $0D7C, $0D7E, and $0D80 during the
; animation handling routine. (The last 6 bytes are actually unused, since
; SMW never uses animation frame 7 for anything.)
DATA_05B93B:
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$0600,!VRAM_SMW_Layer1GFXVRAMLocation+$0640,!VRAM_SMW_Layer1GFXVRAMLocation+$0680		; Frame 0
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$0740,!VRAM_SMW_Layer1GFXVRAMLocation+$0EA0,!VRAM_SMW_Layer1GFXVRAMLocation+$0800		; Frame 1
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$0500,!VRAM_SMW_Layer1GFXVRAMLocation+$0540,!VRAM_SMW_Layer1GFXVRAMLocation+$0580		; Frame 2
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$05C0,!VRAM_SMW_Layer1GFXVRAMLocation+$0780,!VRAM_SMW_Layer1GFXVRAMLocation+$07C0		; Frame 3
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$0DA0,!VRAM_SMW_Layer1GFXVRAMLocation+$06C0,!VRAM_SMW_Layer1GFXVRAMLocation+$0700		; Frame 4
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$04C0,!VRAM_SMW_Layer1GFXVRAMLocation+$0440,!VRAM_SMW_Layer1GFXVRAMLocation+$0480		; Frame 5
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$0400,!VRAM_SMW_Layer1GFXVRAMLocation+$0000,!VRAM_SMW_Layer1GFXVRAMLocation+$0000		; Frame 6 (Last 2 entries unused)
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$0000,!VRAM_SMW_Layer1GFXVRAMLocation+$0000,!VRAM_SMW_Layer1GFXVRAMLocation+$0000		; Frame 7 (Unused)

; This table determines how a certain tile should vary its animation. 00 =
; always the same, 01 = change depending on $14AD, $14AE, or $14AF (P-switch
; timers and on/off switch), 02 = change depending on $1931 (FG/BG tileset
; number). It is indexed by the animation frame times 3, or (($14 & #$07) *
; 3), and each of the 8 possible animation frames uses one group of 3 bytes.
; Note that the last 6 bytes overlap with the table at $05B97D.
DATA_05B96B:
	db $00,$00,$00		; Frame 0
	db $00,$00,$00		; Frame 1
	db $01,$01,$01		; Frame 2
	db $01,$01,$01		; Frame 3
	db $01,$01,$02		; Frame 4
	db $02,$02,$02		; Frame 5
	;db $02,$00,$00		; Frame 6
	;db $00,$00,$00		; Frame 7

; Table that determines, for tile animations that can have one of two
; states, which address to use to determine the state (i.e. any animation
; for which its corresponding value in the table at $05B96B is 01). The
; address used is $14AD plus this value, so 00 = blue P-switch, 01 = gray
; P-switch, 02 = on/off switch. This table is only 15 bytes long rather than
; 24 because all of the 2-state animations are updated on animation frame 0,
; 1, 2, 3, or 4, never 5, 6, or 7. Note also that the last byte overlaps
; with the table at $05B98B.
DATA_05B97D:						; Note: The first 6 bytes of this table are also used by the above table
	db $02,$00,$00		; Frame 0
	db $00,$00,$00		; Frame 1
	db $00,$00,$00		; Frame 2
	db $01,$00,$02		; Frame 3
	db $02,$00		; Frame 4		; Note: SMW never uses frames 5-7 for anything
	;db $00

DATA_05B98B:						; Note: The first byte of this table is also used by the above table
	%SMW_AnimationTileset(0)	; Tileset 00 (Normal 1)
	%SMW_AnimationTileset(1)	; Tileset 01 (Castle 1)
	%SMW_AnimationTileset(2)	; Tileset 02 (Rope 1)
	%SMW_AnimationTileset(3)	; Tileset 03 (Underground 1)
	%SMW_AnimationTileset(4)	; Tileset 04 (Switch Palace 1)
	%SMW_AnimationTileset(4)	; Tileset 05 (Ghost House 1)
	%SMW_AnimationTileset(5)	; Tileset 06 (Rope 2)
	%SMW_AnimationTileset(4)	; Tileset 07 (Normal 2)
	%SMW_AnimationTileset(2)	; Tileset 08 (Rope 3)
	%SMW_AnimationTileset(4)	; Tileset 09 (Underground 2)
	%SMW_AnimationTileset(0)	; Tileset 0A (Switch Palace 2)
	%SMW_AnimationTileset(1)	; Tileset 0B (Castle 2)
	%SMW_AnimationTileset(0)	; Tileset 0C (Cloud/Forest)
	%SMW_AnimationTileset(4)	; Tileset 0D (Ghost House 2)
	;%SMW_AnimationTileset(0)	; Tileset 0E (Underground 3)

FrameData:						; Note: The first byte of this table is also used by the above table
.Global:
..Frame0:
	%SMW_LMStyleAnimationFrames(6C0, 6D0, 6E0, 6F0)	; ? Block
	%SMW_LMStyleAnimationFrames(6C4, 6D4, 6E4, 6F4)	; Note Block
	%SMW_LMStyleAnimationFrames(6C8, 6C8, 6C8, 6C8)	; Turn Block (Not Spinning)		; Optimization: Waste of an animation slot.
..Frame1:
	%SMW_LMStyleAnimationFrames(704, 714, 724, 734)	; Midpoint Gate
	%SMW_LMStyleAnimationFrames(6C8, 6D8, 6E8, 6F8)	; Turn Block (Spinning)
	%SMW_LMStyleAnimationFrames(B6C, B7C, BE0, BE4)	; Berry
..Frame2:
	%SMW_LMStyleAnimationFrames(779, 779, 779, 779)	; Blank (P-Switch Door)
	%SMW_LMStyleAnimationFrames(779, 779, 779, 779)	; Blank (P-Switch Coin)
	%SMW_LMStyleAnimationFrames(6B4, 6B4, 6B4, 6B4)	; Used Block
..Frame3:
	%SMW_LMStyleAnimationFrames(738, 73C, 738, 73C)	; Muncher
	%SMW_LMStyleAnimationFrames(779, 779, 779, 779)	; Blank (P-Switch ? Block)
	%SMW_LMStyleAnimationFrames(778, 778, 778, 778)	; ON/OFF Line guide (/)
..Frame4:
	%SMW_LMStyleAnimationFrames(6A0, 6A0, 6A0, 6A0)	; ON/OFF Block (ON)
	%SMW_LMStyleAnimationFrames(6CC, 6DC, 6EC, 6FC)	; Coin

.Local0:
..Frame4:
	%SMW_LMStyleAnimationFrames(700, 710, 720, 730)	; Water
..Frame5:
	%SMW_LMStyleAnimationFrames(68C, 69C, 6AC, 6BC)	; Castle Lava
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused
..Frame6:
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused

.Local1:
..Frame4:
	%SMW_LMStyleAnimationFrames(700, 710, 720, 730)	; Water
..Frame5:
	%SMW_LMStyleAnimationFrames(68C, 69C, 6AC, 6BC)	; Castle Lava
	%SMW_LMStyleAnimationFrames(600, 610, 620, 630)	; Upwards Conveyor belt, conveyor belt end
	%SMW_LMStyleAnimationFrames(630, 620, 610, 600)	; Downwards Conveyor belt, conveyor belt end
..Frame6:
	%SMW_LMStyleAnimationFrames(708, 718, 728, 718)	; Candle light effect

.Local2:
..Frame4:
	%SMW_LMStyleAnimationFrames(700, 710, 720, 730)	; Water
..Frame5:
	%SMW_LMStyleAnimationFrames(740, 750, 760, 770)	; Line-Guide End, flat conveyor rope, unused
	%SMW_LMStyleAnimationFrames(744, 754, 764, 774)	; Upwards sloped conveyor rope, conveyor belt end duplicate, unused
	%SMW_LMStyleAnimationFrames(774, 764, 754, 744)	; Downwards sloped conveyor rope, conveyor belt end duplicate, unused
..Frame6:
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused

.Local3:
..Frame4:
	%SMW_LMStyleAnimationFrames(70C, 71C, 72C, 71C)	; Background stars/crystals
..Frame5:
	%SMW_LMStyleAnimationFrames(604, 614, 624, 634)	; Upwards normal slope cavern lava
	%SMW_LMStyleAnimationFrames(608, 618, 628, 638)	; Steep slope cavern lava
	%SMW_LMStyleAnimationFrames(60C, 61C, 62C, 63C)	; Horizontal and vertical cavern lava
..Frame6:
	%SMW_LMStyleAnimationFrames(634, 624, 614, 604)	; Downwards normal slope cavern lava

.Local4:
..Frame4:
#LM120Hijack_AnimatedWaterInMoreTilesets:
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused (LM: Changes this to the data for animated water so that can be used in more tilesets (1.20+))
..Frame5:
	%SMW_LMStyleAnimationFrames(74C, 75C, 76C, 75C)	; Background lamp, unused star
	%SMW_LMStyleAnimationFrames(688, 698, 6A8, 6B8)	; Seaweed
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused
..Frame6:
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused

.Local5:
..Frame4:
	%SMW_LMStyleAnimationFrames(70C, 71C, 72C, 71C)	; Background stars/crystals (cave)
..Frame5:
	%SMW_LMStyleAnimationFrames(748, 758, 768, 758)	; Background stars (sky)
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused
..Frame6:
	%SMW_LMStyleAnimationFrames(6C0, 6C0, 6C0, 6C0)	; Unused

.AltStates:
	%SMW_LMStyleAnimationFrames(6A4, 6A4, 6A4, 6A4)	; P-Switch Door
	%SMW_LMStyleAnimationFrames(6CC, 6DC, 6EC, 6FC)	; Coin (P-Switch)
	%SMW_LMStyleAnimationFrames(6CC, 6DC, 6EC, 6FC)	; Coin (Used Block)
	%SMW_LMStyleAnimationFrames(6CC, 6DC, 6EC, 6FC)	; Coin (Muncher)
	%SMW_LMStyleAnimationFrames(6C0, 6D0, 6E0, 6F0)	; ? Block (P-Switch)
	%SMW_LMStyleAnimationFrames(77C, 77C, 77C, 77C)	; ON/OFF Line guide (\)
	%SMW_LMStyleAnimationFrames(6B0, 6B0, 6B0, 6B0)	; ON/OFF Block (Off)
	%SMW_LMStyleAnimationFrames(6B4, 6B4, 6B4, 6B4)	; Used Block (Coin)


Main:
;$05BB39
	; The routine that handles tile animation. It reads the animation data from
	; the table at $05B999 and, based on that and a few other factors (such as
	; tileset and blue P-switch status), sets the pointers to the tile data in
	; the table at RAM $7E0D76.
	PHB				; AXY->8
	PHK
	PLB
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.b #$07			;| Calculate the index of the first one of four 8x8 tiles in a 16x16 tile:
	STA.b !RAM_SMW_Misc_ScratchRAM00	;| GFX_TILE_IDX = (EffFrame & 0b111) + ((EffFrame & 0b111) << 1), which is equivalent to:
	ASL				;| GFX_TILE_IDX = (EffFrame & 0b111) * 3
	ADC.b !RAM_SMW_Misc_ScratchRAM00	;/
	TAY				;\ Y = GFX_TILE_IDX
	ASL				;|
	TAX				;/ X = GFX_TILE_IDX * 2; offset of the frame's 6-byte row in DATA_05B93B
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.w #$0018			;| TILE_DATA_INDEX_PART = (EffFrame & 0b00011000) >> 2
	LSR				;| Extract bits 3 and 4 from EffFrame, and move them to bits 1 and 2: 0b000AB000 -> 0b00000AB0
	LSR				;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.w DATA_05B93B,x		;\
	STA.w !RAM_SMW_Graphics_TileAnimationVRAMAddress3Lo	;|
	LDA.w DATA_05B93B+$02,x		;| Write the 3 VRAM addresses of animated tiles' GFX into Gfx33DestAddr{A,B,C},
	STA.w !RAM_SMW_Graphics_TileAnimationVRAMAddress2Lo	;| from one 6-byte row of DATA_05B93B, X being the row's offset.
	LDA.w DATA_05B93B+$04,x		;|
	STA.w !RAM_SMW_Graphics_TileAnimationVRAMAddress1Lo	;/
	LDX.b #$04			; Initialise LOOP_COUNTER = 4
Loop:
	PHY				;\ Start loop, backup X and Y.
	PHX				;/
	SEP.b #$20			; A->8
	TYA				; A = GFX_TILE_IDX
	LDX.w DATA_05B96B,y		; X holds the value that determines how the current tile should behave.
	BEQ.b GlobalAnimation		; X == 0: the tile does not change based on any of the following conditions.
	DEX				;\ X == 2: the tile changes depending on FG/BG tileset number.
	BNE.b TilesetSpecificAnimation	;/
	LDX.w DATA_05B97D,y		; X == 1: tile changes depending on the two P-Switch timers and ON/OFF switch state.
	LDY.w !RAM_SMW_Timer_BluePSwitch,x	;\ If a P-Switch timer or ON/OFF Switch state is 0, handle the tile's default look,
	BEQ.b State1Animation		;/ that is when it's unaffected by P-Switch timer or ON/OFF Switch.
	CLC				;\ A = GFX_TILE_IDX + 0x26
	ADC.b #$26			;/
	BRA.b State2Animation		; Handle the look of the tile.

TilesetSpecificAnimation:
	LDY.w !RAM_SMW_Misc_LevelTilesetSetting	; Load the current object tileset.
	CLC				;\ Determine which group of animated tiles to use for current FG/BG tileset,
	ADC.w DATA_05B98B,y		;/ as defined in the table at $05B98B.
State1Animation:
State2Animation:
GlobalAnimation:
	REP.b #$30			; AXY->16
	AND.w #$00FF			;\
	ASL				;|
	ASL				;| Calculate the index to AnimatedTileData:
	ASL				;| A = ((GFX_TILE_IDX & 0xFF) << 3) | TILE_DATA_INDEX_PART
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;|
	TAY				;/
	LDA.w FrameData,y		; Get VRAM address of the tile's current animation frame GFX.
	SEP.b #$10			; XY->8
	PLX				; X = LOOP_COUNTER
	STA.w !RAM_SMW_Graphics_TileAnimationSourceAddress1Lo,x	; Write that address to Gfx33SrcAddrA.
	PLY				;\ Increment GFX_TILE_IDX.
	INY				;/
	DEX				;\ Subtract 2 from LOOP_COUNTER.
	DEX				;/
	BPL.b Loop			; Go back to the beginning of the loop if the LOOP_COUNTER is not negative.
	SEP.b #$20			; A->8
	PLB
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_LoadSublevel(Address)					; Optimization: This routine, along with its subroutines, are poorly optimized.
namespace SMW_LoadSublevel
%InsertMacroAtXPosition(<Address>)

Main:
	PHP
	SEP.b #$20			; A->8
	REP.b #$10			; XY->16
	LDX.w #$0000							;\ Optimization: Why use 025 as the default background tile when it's 000?
InitializeLayer2BackgroundLoLoop:					;| Also, why not put the LDA.b #$25 outside the loop since A never changes?
	LDA.b #$25							;| Alternatively, what about using DMA here?
	STA.l !RAM_SMW_Blocks_Layer2TilesLo,x				;|
	STA.l !RAM_SMW_Blocks_Layer2TilesLo+$0200,x			;/
	INX
	CPX.w #$0200
	BNE.b InitializeLayer2BackgroundLoLoop
	STZ.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject
	LDA.b !RAM_SMW_Pointer_Layer2DataBank
#LM000Hijack_LoadCustomLayer2Properties:
	CMP.b #$FF			; |If the layer 2 data is a background,
	BNE.b Layer2Level		; / branch to $8074
#LM_JMLHere_OriginalBG:
	REP.b #$10							;\ Optimization: X/Y is already 16-bit!
	LDY.w #$0000							;/
	LDX.b !RAM_SMW_Pointer_Layer2DataLo
	CPX.w #SMW_Backgrounds_Layer2_Cave	; |If Layer 2 pointer >= $E8FF,
	BCC.b Page1Background		; |the background should use Map16 page x11 instead of x10
	LDY.w #$0001							; Optimization: INY?
Page1Background:
	LDX.w #$0000
	TYA
SetBackgroundPageNumberLoop:
	STA.l !RAM_SMW_Blocks_Layer2TilesHi,x	; |Set the background's Map16 page
	STA.l !RAM_SMW_Blocks_Layer2TilesHi+$0200,x	; |(i.e. setting all high tile bytes to Y)
	INX
	CPX.w #$0200
	BNE.b SetBackgroundPageNumberLoop
	LDA.b #SMW_Backgrounds_Layer2>>16	; \ Set highest Layer 2 address to x0C
	STA.b !RAM_SMW_Pointer_Layer2DataBank	; / (All backgrounds are stored in bank 0C)
#LM_JMLHere_Layer2BG:
	STZ.w !RAM_SMW_UnusedRAM_CopyOfLevelTilesetSetting		; Optimization: Junk
	STZ.w !RAM_SMW_Misc_LevelTilesetSetting
	LDX.w #!RAM_SMW_Blocks_Layer2TilesLo				;\ Optimization: These can be removed for the optimized version of this routine
	STX.b !RAM_SMW_Misc_ScratchRAM0D				;|
	REP.b #$20							;/
	JSR.w SMW_BufferBGTilemap_Main
Layer2Level:
#LM_JMLHere_Layer2Level:
	SEP.b #$20			; A->8
	LDX.w #$0000							;\ Optimization: An unrolled loop that is not only slower than just using DMA, but also wastes more space than setting up a DMA.
CODE_058079:								;| I have a feeling that whoever wrote this was still used to writing NES code or something.
	LDA.b #$00							;|
	JSR.w SMW_InitializeLevelData_Hi				;|
	DEX								;| Why decrement X (and increment it in both subroutines) when it could have just been done in this loop?
	LDA.b #$25							;|
	JSR.w SMW_InitializeLevelData_Lo				;|
	CPX.w #$0200							;|
	BNE.b CODE_058079						;/
	STZ.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject
if !SMW_LevelCode_LoadWanted == !TRUE
	; The same five bytes as the JSR and the SEP under it. The level's own
	; load code runs before the objects are placed, so what it writes into
	; the Map16 table is what they are placed over; the stub then makes the
	; displaced call and comes back through the RTL below. See
	; Config/LevelCode.asm.
	JML.l SMW_LevelCode_Load
LevelCodeLanding:
	RTL				;> The RTS return the stub pushes for the call it displaced
else
LevelCodeLanding:			;> Named either way, so the stub assembles; only reached above
	JSR.w SMW_BeginLoadingLevelData_Main	; Load the level
	SEP.b #$30			; AXY->8
endif
LevelCodeReturn:
	LDA.w !RAM_SMW_Misc_GameMode
	CMP.b #!Define_SMW_GameMode22_FadeOutToEnemyRollcall
	BPL.b CODE_05809C		; |If level mode is less than x22,
if defined("Define_SMW_SA1")
	JSL.l SpriteLoading_Sprite_Load_Reset
else
	JSL.l CODE_02A751		; |JSL to $02A751
endif
CODE_05809C:
	PLP
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

; Optimization: The below routine is pretty badly optimized. There are a bunch of REP and SEPs that literally do nothing.
; This is because they change the size of A to 16-bit, then Y is changed, then A is set back to be 8-bit.
; Also, the routine constantly stores and loads Y from $02 and $05 so it can index two indirects, yet one of those indirects can be indexed with X as the location it indexes never changes.
; Also, the last part of the routine unnecessarily loads and stores to $00 during each loop for no reason. The carry flag also doesn't need to be manually cleared either.

macro ROUTINE_SMW_BufferBGTilemap(Address)
namespace SMW_BufferBGTilemap
%InsertMacroAtXPosition(<Address>)

Main:
	PHP
	REP.b #$30			; AXY->16
	LDY.w #$0000
	STY.b !RAM_SMW_Misc_ScratchRAM03
	STY.b !RAM_SMW_Misc_ScratchRAM05
	SEP.b #$30			; AXY->8
	LDA.b #!RAM_SMW_Blocks_Layer2TilesLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0F
CODE_058136:
	SEP.b #$20			; A->8
	REP.b #$10			; XY->16
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM07
	INY
	REP.b #$20			; A->16
	STY.b !RAM_SMW_Misc_ScratchRAM03
	SEP.b #$20			; A->8
	AND.b #$80
	BEQ.b CODE_05816A
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	AND.b #$7F
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	INY
	REP.b #$20			; A->16
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b !RAM_SMW_Misc_ScratchRAM05
CODE_05815A:
	SEP.b #$20			; A->8
	STA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM07
	BPL.b CODE_05815A
	REP.b #$20			; A->16
	STY.b !RAM_SMW_Misc_ScratchRAM05
	JMP.w CODE_058188

CODE_05816A:
	REP.b #$20			; A->16
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	INY
	REP.b #$20			; A->16
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b !RAM_SMW_Misc_ScratchRAM05
	SEP.b #$20			; A->8
	STA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	REP.b #$20			; A->16
	INY
	STY.b !RAM_SMW_Misc_ScratchRAM05
	SEP.b #$20			; A->8
	DEC.b !RAM_SMW_Misc_ScratchRAM07
	BPL.b CODE_05816A
CODE_058188:
	REP.b #$20			; A->16
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	CMP.b #$FF
	BNE.b CODE_058136
	INY
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	CMP.b #$FF
	BNE.b CODE_058136
	REP.b #$20			; A->16
	LDA.w #SMW_Map16Data_Backgrounds
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w #$0000
CODE_0581A5:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Pointer_Map16Tiles,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INX
	INX
	CPX.w #$0400
	BNE.b CODE_0581A5
	PLP
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_InitializeLevelData(Address)			; Optimization: Unrolled loop that should be replaced with a DMA transfer.
namespace SMW_InitializeLevelData
%InsertMacroAtXPosition(<Address>)

; This routine is used within the level clear to set $7EC800-$7EFFFF to
; #$25.
Lo:
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$00),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$01),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$02),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$03),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$04),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$05),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$06),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$07),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$08),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$09),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0A),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0B),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0C),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0D),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0E),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0F),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$10),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$11),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$12),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$13),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$14),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$15),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$16),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$17),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$18),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$19),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$1A),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$1B),x
	INX
	RTS

; This routine is used within the level clear to set $7FC800-$7FFFFF to
; #$00.
Hi:
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$00),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$01),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$02),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$03),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$04),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$05),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$06),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$07),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$08),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$09),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$0A),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$0B),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$0C),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$0D),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$0E),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$0F),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$10),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$11),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$12),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$13),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$14),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$15),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$16),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$17),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$18),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$19),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$1A),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($0200*$1B),x
	INX
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_BeginLoadingLevelData(Address)
namespace SMW_BeginLoadingLevelData
%InsertMacroAtXPosition(<Address>)

Main:
	PHP
#LM160Hijack_InitializeLevelExAnimations:
	SEP.b #$30			; AXY->8
	STZ.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo	; Layer number (0=Layer 1, 1=Layer 2)
	JSR.w SMW_LoadLevelHeader_Main	; Loads level header
	JSR.w SMW_InitializeMap16Pointers_Main
Loop:
#LM000Hijack_GetSuperGFXBypassTableLocation:
	LDA.w !RAM_SMW_Misc_LevelModeSetting	; Get current level mode
	CMP.b #$09
	BEQ.b IsBossLevel
	CMP.b #$0B			; |If the current level is a boss level,
	BEQ.b IsBossLevel		; |don't load anything else.
	CMP.b #$10
	BEQ.b IsBossLevel
	LDY.b #$00						;\ Optimization: LDA.b [$65]?
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y			;/ There is no need to load Y here.
	CMP.b #$FF			; |If level isn't empty, load the level.
	BEQ.b BlankLevelData
	JSR.w SMW_LoadLevelDataObject_Main
BlankLevelData:
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Misc_LevelModeSetting			;\ Optimization: Would an indexed table of values be out of the question?
	BEQ.b NotLayer2Level					;|
	CMP.b #$0A						;|
	BEQ.b NotLayer2Level					;|
	CMP.b #$0C						;|
	BEQ.b NotLayer2Level					;|
	CMP.b #$0D						;|
	BEQ.b NotLayer2Level					;|
	CMP.b #$0E						;|
	BEQ.b NotLayer2Level					;|
	CMP.b #$11						;|
	BEQ.b NotLayer2Level					;|
	CMP.b #$1E						;|
	BEQ.b NotLayer2Level					;/
	INC.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo	; \Increase layer number and load into A
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	CMP.b #$02			; \If it is x02, end. (Layer 1 and 2 are done)
	BEQ.b LoadLevelDone
	LDA.b !RAM_SMW_Pointer_Layer2DataLo
	CLC
	ADC.b #$05
	STA.b !RAM_SMW_Pointer_Layer1DataLo	; |Move address stored in $68-$6A to $65-$67.
	LDA.b !RAM_SMW_Pointer_Layer2DataHi	; |(Move Layer 2 address to "Level to load" address)
	ADC.b #$00			; |It also increases the address by 5 (to ignore Layer 2's header)
	STA.b !RAM_SMW_Pointer_Layer1DataHi
	LDA.b !RAM_SMW_Pointer_Layer2DataBank
	STA.b !RAM_SMW_Pointer_Layer1DataBank
	STZ.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	JMP.w Loop

NotLayer2Level:
IsBossLevel:
LoadLevelDone:
	STZ.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	PLP
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_LoadLevelHeader(Address)					; Optimization: This whole routine could easily be inserted where the JSR.w to it is.
namespace SMW_LoadLevelHeader
%InsertMacroAtXPosition(<Address>)

; Level mode attribute tables, corresponding to the list of properties seen
; in LM below the level mode dropdown. Consists of six 32-byte tables, with
; each level mode receiving a single byte in each: $058417: Screen Mode.
; Stored to $5B. $058437: TM&TMW. Stored to $0D9D. $058457: TD&TSW. Stored
; to $0D9E. $058477: CGADSUB. Stored to $40. $058497: Fight Mode. Stored to
; $0D9B. $0584B7: Sprite Layer. Stored to $64. Change at the two bytes at
; $058455 from [$01 $02] to [$05 $06] to fix an issue in level modes 1E and
; 1F that causes the Layer 3 status bar to be overlaid by the transparent
; layer.
VerticalTable:		; LM: These are the "Screen Mode" values. They also affect "Layout", but not "Layer 2 Interact" for some reason.
	db $00		; 00 Horizontal level
	db $00		; 01 Horizontal layer 2 level (no layer 2 interaction)
	db $80		; 02 Horizontal layer 2 level (layer 2 interaction)
	db $01		; 03 Do not use this level mode!
	db $81		; 04 Do not use this level mode!
	db $02		; 05 Do not use this level mode!
	db $82		; 06 Do not use this level mode!
	db $03		; 07 Vertical layer 2 level (no layer 2 interaction)
	db $83		; 08 Vertical layer 2 level (layer 2 interaction)
	db $00		; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	db $01		; 0A Vertical level
	db $00		; 0B Horizontal boss level (Larry, Iggy)
	db $00		; 0C Horizontal dark BG level
	db $01		; 0D Vertical dark BG level
	db $00		; 0E Horizontal level
	db $00		; 0F Horizontal layer 2 level (no layer 2 interaction)
	db $00		; 10 Horizontal boss level (Bowser)
	db $00		; 11 Horizontal dark BG level
	db $00		; 12 Cannot use this level mode!
	db $00		; 13 Cannot use this level mode!
	db $00		; 14 Cannot use this level mode!
	db $00		; 15 Cannot use this level mode!
	db $00		; 16 Cannot use this level mode!
	db $00		; 17 Cannot use this level mode!
	db $00		; 18 Cannot use this level mode!
	db $00		; 19 Cannot use this level mode!
	db $00		; 1A Cannot use this level mode!
	db $00		; 1B Cannot use this level mode!
	db $00		; 1C Cannot use this level mode!
	db $00		; 1D Cannot use this level mode!
	db $00		; 1E Horizontal translucent level
	db $80		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

LevMainScrnTbl:		; LM: These are the "TM & TMW" values
	db $15		; 00 Horizontal level
	db $15		; 01 Horizontal layer 2 level (no layer 2 interaction)
	db $17		; 02 Horizontal layer 2 level (layer 2 interaction)
	db $15		; 03 Do not use this level mode!
	db $15		; 04 Do not use this level mode!
	db $15		; 05 Do not use this level mode!
	db $17		; 06 Do not use this level mode!
	db $15		; 07 Vertical layer 2 level (no layer 2 interaction)
	db $17		; 08 Vertical layer 2 level (layer 2 interaction)
	db $15		; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	db $15		; 0A Vertical level
	db $15		; 0B Horizontal boss level (Larry, Iggy)
	db $15		; 0C Horizontal dark BG level
	db $15		; 0D Vertical dark BG level
	db $04		; 0E Horizontal level
	db $04		; 0F Horizontal layer 2 level (no layer 2 interaction)
	db $15		; 10 Horizontal boss level (Bowser)
	db $17		; 11 Horizontal dark BG level
	db $15		; 12 Cannot use this level mode!
	db $15		; 13 Cannot use this level mode!
	db $15		; 14 Cannot use this level mode!
	db $15		; 15 Cannot use this level mode!
	db $15		; 16 Cannot use this level mode!
	db $15		; 17 Cannot use this level mode!
	db $15		; 18 Cannot use this level mode!
	db $15		; 19 Cannot use this level mode!
	db $15		; 1A Cannot use this level mode!
	db $15		; 1B Cannot use this level mode!
	db $15		; 1C Cannot use this level mode!
	db $15		; 1D Cannot use this level mode!
	db $01		; 1E Horizontal translucent level
	db $02		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

LevSubScrnTbl:		; LM: These are the "TS & TSW" values
	db $02		; 00 Horizontal level
	db $02		; 01 Horizontal layer 2 level (no layer 2 interaction)
	db $00		; 02 Horizontal layer 2 level (layer 2 interaction)
	db $02		; 03 Do not use this level mode!
	db $02		; 04 Do not use this level mode!
	db $02		; 05 Do not use this level mode!
	db $00		; 06 Do not use this level mode!
	db $02		; 07 Vertical layer 2 level (no layer 2 interaction)
	db $00		; 08 Vertical layer 2 level (layer 2 interaction)
	db $00		; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	db $02		; 0A Vertical level
	db $00		; 0B Horizontal boss level (Larry, Iggy)
	db $02		; 0C Horizontal dark BG level
	db $02		; 0D Vertical dark BG level
	db $13		; 0E Horizontal level
	db $13		; 0F Horizontal layer 2 level (no layer 2 interaction)
	db $00		; 10 Horizontal boss level (Bowser)
	db $00		; 11 Horizontal dark BG level
	db $02		; 12 Cannot use this level mode!
	db $02		; 13 Cannot use this level mode!
	db $02		; 14 Cannot use this level mode!
	db $02		; 15 Cannot use this level mode!
	db $02		; 16 Cannot use this level mode!
	db $02		; 17 Cannot use this level mode!
	db $02		; 18 Cannot use this level mode!
	db $02		; 19 Cannot use this level mode!
	db $02		; 1A Cannot use this level mode!
	db $02		; 1B Cannot use this level mode!
	db $02		; 1C Cannot use this level mode!
	db $02		; 1D Cannot use this level mode!
	db $16		; 1E Horizontal translucent level
	db $15		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

LevCGADSUBtable:	; LM: These are the "CGADSUB" values
	db $24		; 00 Horizontal level
	db $24		; 01 Horizontal layer 2 level (no layer 2 interaction)
	db $24		; 02 Horizontal layer 2 level (layer 2 interaction)
	db $24		; 03 Do not use this level mode!
	db $24		; 04 Do not use this level mode!
	db $24		; 05 Do not use this level mode!
	db $20		; 06 Do not use this level mode!
	db $24		; 07 Vertical layer 2 level (no layer 2 interaction)
	db $24		; 08 Vertical layer 2 level (layer 2 interaction)
	db $20		; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	db $24		; 0A Vertical level
	db $20		; 0B Horizontal boss level (Larry, Iggy)
	db $70		; 0C Horizontal dark BG level
	db $70		; 0D Vertical dark BG level
	db $24		; 0E Horizontal level
	db $24		; 0F Horizontal layer 2 level (no layer 2 interaction)
	db $20		; 10 Horizontal boss level (Bowser)
	db $FF		; 11 Horizontal dark BG level
	db $24		; 12 Cannot use this level mode!
	db $24		; 13 Cannot use this level mode!
	db $24		; 14 Cannot use this level mode!
	db $24		; 15 Cannot use this level mode!
	db $24		; 16 Cannot use this level mode!
	db $24		; 17 Cannot use this level mode!
	db $24		; 18 Cannot use this level mode!
	db $24		; 19 Cannot use this level mode!
	db $24		; 1A Cannot use this level mode!
	db $24		; 1B Cannot use this level mode!
	db $24		; 1C Cannot use this level mode!
	db $24		; 1D Cannot use this level mode!
	db $21		; 1E Horizontal translucent level
	db $22		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

SpecialLevTable:	; LM: These are the "Fight Mode" values
	db $00		; 00 Horizontal level
	db $00		; 01 Horizontal layer 2 level (no layer 2 interaction)
	db $00		; 02 Horizontal layer 2 level (layer 2 interaction)
	db $00		; 03 Do not use this level mode!
	db $00		; 04 Do not use this level mode!
	db $00		; 05 Do not use this level mode!
	db $00		; 06 Do not use this level mode!
	db $00		; 07 Vertical layer 2 level (no layer 2 interaction)
	db $00		; 08 Vertical layer 2 level (layer 2 interaction)
	db $C0		; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	db $00		; 0A Vertical level
	db $80		; 0B Horizontal boss level (Larry, Iggy)
	db $00		; 0C Horizontal dark BG level
	db $00		; 0D Vertical dark BG level
	db $00		; 0E Horizontal level
	db $00		; 0F Horizontal layer 2 level (no layer 2 interaction)
	db $C1		; 10 Horizontal boss level (Bowser)
	db $00		; 11 Horizontal dark BG level
	db $00		; 12 Cannot use this level mode!
	db $00		; 13 Cannot use this level mode!
	db $00		; 14 Cannot use this level mode!
	db $00		; 15 Cannot use this level mode!
	db $00		; 16 Cannot use this level mode!
	db $00		; 17 Cannot use this level mode!
	db $00		; 18 Cannot use this level mode!
	db $00		; 19 Cannot use this level mode!
	db $00		; 1A Cannot use this level mode!
	db $00		; 1B Cannot use this level mode!
	db $00		; 1C Cannot use this level mode!
	db $00		; 1D Cannot use this level mode!
	db $00		; 1E Horizontal translucent level
	db $00		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

LevXYPPCCCTtbl:		; LM: These are the "Sprite Layer" values.
			; Glitch: The $30s cause sprites to appear in front of tiles with priority in those level modes, which is undesireable in some cases.
	db $20		; 00 Horizontal level
	db $20		; 01 Horizontal layer 2 level (no layer 2 interaction)
	db $20		; 02 Horizontal layer 2 level (layer 2 interaction)
	db $30		; 03 Do not use this level mode!
	db $30		; 04 Do not use this level mode!
	db $30		; 05 Do not use this level mode!
	db $30		; 06 Do not use this level mode!
	db $30		; 07 Vertical layer 2 level (no layer 2 interaction)
	db $30		; 08 Vertical layer 2 level (layer 2 interaction)
	db $30		; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	db $30		; 0A Vertical level
	db $30		; 0B Horizontal boss level (Larry, Iggy)
	db $30		; 0C Horizontal dark BG level
	db $30		; 0D Vertical dark BG level
	db $20		; 0E Horizontal level
	db $20		; 0F Horizontal layer 2 level (no layer 2 interaction)
	db $30		; 10 Horizontal boss level (Bowser)
	db $30		; 11 Horizontal dark BG level
	db $30		; 12 Cannot use this level mode!
	db $30		; 13 Cannot use this level mode!
	db $30		; 14 Cannot use this level mode!
	db $30		; 15 Cannot use this level mode!
	db $30		; 16 Cannot use this level mode!
	db $30		; 17 Cannot use this level mode!
	db $30		; 18 Cannot use this level mode!
	db $30		; 19 Cannot use this level mode!
	db $30		; 1A Cannot use this level mode!
	db $30		; 1B Cannot use this level mode!
	db $30		; 1C Cannot use this level mode!
	db $30		; 1D Cannot use this level mode!
	db $30		; 1E Horizontal translucent level
	db $30		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

; Hundreds digits for the four time limits that can be specified in the
; level header. Default is $00, $02, $03, $04 for time limits of 0, 200,
; 300, and 400. Tens and ones digits are set to 0 at $05858A.
TimerTable:
	db $00,$02,$03,$04

; The eight tracks a level header's music setting can name, one row per
; setting.
	incsrc "levels/music.asm"

Main:
;$0584E3
	LDY.b #$00
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	; Get first byte
	TAX
	AND.b #$1F			; |Get amount of screens
	INC
	STA.b !RAM_SMW_Misc_ScreensInLvl
	TXA
	LSR
	LSR
	LSR				; |Get BG color setting
	LSR
	LSR
	STA.w !RAM_SMW_Misc_BGPaletteSetting
	INY				; \Get second byte
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	AND.b #$1F			; \Get level mode
	STA.w !RAM_SMW_Misc_LevelModeSetting
	TAX
	LDA.l LevXYPPCCCTtbl,x		; \Get XYPPCCCT settings from table
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.l LevMainScrnTbl,x		; \Get main screen setting from table
	STA.w !RAM_SMW_Mirror_MainScreenLayers
	LDA.l LevSubScrnTbl,x		; \Get subscreen setting from table
	STA.w !RAM_SMW_Mirror_SubScreenLayers
	LDA.l LevCGADSUBtable,x		; \Get CGADSUB settings from table
	STA.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
	LDA.l SpecialLevTable,x		; \Get special level setting from table
	STA.w !RAM_SMW_Misc_NMIToUseFlag
	LDA.l VerticalTable,x		; \Get vertical level setting from table
	STA.b !RAM_SMW_Misc_LevelLayoutFlags
	LSR
	LDA.b !RAM_SMW_Misc_ScreensInLvl
	LDX.b #$01			; |If level mode is even:
	BCC.b LevelModeEven		; |Store screen amount in $5E and x01 in $5F
	TAX				; |Otherwise:
	LDA.b #$01			; |Store x01 in $5E and screen amount in $5F
LevelModeEven:
	STA.b !RAM_SMW_Camera_LastScreenHoriz
	STX.b !RAM_SMW_Camera_LastScreenVert
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	; Reload second byte
	LSR
	LSR
	LSR				; |Get BG color settings
	LSR
	LSR
	STA.w !RAM_SMW_Misc_BackgroundColorSetting
	INY				; \Get third byte
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM00	; "Push" third byte
	TAX				; "Push" third byte
	AND.b #$0F			; \Load sprite set
	STA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting
	TXA				; "Pull" third byte
	LSR
	LSR
	LSR
	LSR
	AND.b #$07
	TAX				; |Get music
	LDA.l LevelMusicTable,x
	LDX.w !RAM_SMW_Misc_MusicRegisterBackup	; | \
	BPL.b CODE_05855C		; |  |
	ORA.b #$80			; |  |Related to not restarting music if the new track
CODE_05855C:
	CMP.w !RAM_SMW_Misc_MusicRegisterBackup	; |  |is the same as the old one?
	BNE.b CODE_058563		; |  |
	ORA.b #$40			; | /
CODE_058563:
	STA.w !RAM_SMW_Misc_MusicRegisterBackup
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; "Pull" third byte
	AND.b #!BGModeAndTileSizeSetting_Mode01Layer3Priority<<4
	LSR
	LSR
	LSR				; |Get Layer 3 priority
	LSR
	ORA.b #!BGModeAndTileSizeSetting_Mode01Enable
	STA.b !RAM_SMW_Mirror_BGModeAndTileSizeSetting
	INY				; \Get fourth bit
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM00	; "Push" fourth bit
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	TAX				; |Get time
	LDA.w !RAM_SMW_Counter_SublevelsEntered
	BNE.b CODE_058590
	LDA.l TimerTable,x
	STA.w !RAM_SMW_Counter_TimerHundreds
	STZ.w !RAM_SMW_Counter_TimerTens
	STZ.w !RAM_SMW_Counter_TimerOnes
CODE_058590:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; "Pull" fourth bit
	AND.b #$07			; \Get FG color settings
	STA.w !RAM_SMW_Misc_FGPaletteSetting
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; "Pull" fourth bit (again)
	AND.b #$38
	LSR
	LSR				; |Get sprite palette
	LSR
	STA.w !RAM_SMW_Misc_SpritePaletteSetting
	INY				; \Get fifth byte
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	AND.b #$0F
	STA.w !RAM_SMW_Misc_LevelTilesetSetting	; |Get tileset
	STA.w !RAM_SMW_UnusedRAM_CopyOfLevelTilesetSetting		; Optimization: Junk
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	; Reload fifth byte
	AND.b #$C0
	ASL
	ROL				; |Get item memory settings
	ROL
	STA.w !RAM_SMW_Misc_ItemMemorySetting
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	; Reload fifth byte
	AND.b #$30
	LSR				; |Get horizontal/vertical scroll
	LSR
	LSR
	LSR
	CMP.b #$03			; | \
	BNE.b HeaderVHscroll		; |  |If scroll mode is x03, disable both
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting	; |  |vertical and horizontal scroll
	LDA.b #$00			; | /
HeaderVHscroll:
	STA.w !RAM_SMW_Flag_Layer1VerticalScrollLevelSetting
	LDA.b !RAM_SMW_Pointer_Layer1DataLo				;\ Optimization: 16-bit A would be useful here.
	CLC								;|
	ADC.b #$05							;|
	STA.b !RAM_SMW_Pointer_Layer1DataLo				;|
	LDA.b !RAM_SMW_Pointer_Layer1DataHi				;|
	ADC.b #$00							;|
	STA.b !RAM_SMW_Pointer_Layer1DataHi				;/
	RTS				; We're done!
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_LoadLevelDataObject(Address)
namespace SMW_LoadLevelDataObject
%InsertMacroAtXPosition(<Address>)

CODE_0585D8:
	LDA.b !RAM_SMW_Blocks_ObjectNumber
	BNE.b CODE_0585E2
	LDA.b !RAM_SMW_Blocks_SizeOrType
	CMP.b #$02
	BCC.b Return0585FE
CODE_0585E2:
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$F0
	ORA.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	AND.b #$F0
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
Return0585FE:
	RTS

Main:
if defined("Define_SMW_SA1")
	JSL.l CallSA1
	RTS
	db $65	; the tail of the LDA.b below, which the hijack leaves unreached
else
	SEP.b #$30			; AXY->8
	LDY.b #$00
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
endif
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	; |Read three bytes of level data
	STA.b !RAM_SMW_Misc_ScratchRAM0B	; |Store them in $0A, $0B and $59
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	STA.b !RAM_SMW_Blocks_SizeOrType
	INY
	TYA
	CLC
	ADC.b !RAM_SMW_Pointer_Layer1DataLo
	STA.b !RAM_SMW_Pointer_Layer1DataLo	; |Increase address by 3 (as 3 bytes were read)
	LDA.b !RAM_SMW_Pointer_Layer1DataHi
	ADC.b #$00
	STA.b !RAM_SMW_Pointer_Layer1DataHi
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Blocks_ObjectNumber	; |Get block number, store in $5A
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$60
	LSR
	ORA.b !RAM_SMW_Blocks_ObjectNumber
	STA.b !RAM_SMW_Blocks_ObjectNumber
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	; A = vertical level setting
	LDY.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	BEQ.b CODE_058637		; |If $1933=x00, divide A by 2
	LSR
CODE_058637:
	AND.b #$01
	BEQ.b CODE_05863E		; |If lowest bit of A is set, jump to sub
	JSR.w CODE_0585D8						; Optimization: This routine is only called here and is small enough to fit here.
CODE_05863E:
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$0F
	ASL
	ASL
	ASL				; |Set upper half of $57 to Y pos
	ASL				; |and lower half of $57 to X pos
	STA.b !RAM_SMW_Blocks_SubScrPos
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	AND.b #$0F
	ORA.b !RAM_SMW_Blocks_SubScrPos
	STA.b !RAM_SMW_Blocks_SubScrPos
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	AND.w #$00FF			; |Load $1993*2 into X
	ASL
	TAX
	LDA.l SMW_LevelDataLayoutTables_LoTablePtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_HiTablePtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	AND.w #$001F			; |Set Y to Level Mode*2
	ASL
	TAY
	SEP.b #$20			; A->8
	LDA.b #SMW_LevelDataLayoutTables_LoTablePtrs>>16
	STA.b !RAM_SMW_Misc_ScratchRAM05
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b [!RAM_SMW_Misc_ScratchRAM03],y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b [!RAM_SMW_Misc_ScratchRAM06],y
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM03],y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b [!RAM_SMW_Misc_ScratchRAM06],y
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b #SMW_LevelDataLayoutTables_Main>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$80
	ASL				; |If New Page flag is set, increase $1928 by 1
	ADC.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject	; |(A = $1928)
	STA.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject
	STA.w !RAM_SMW_Blocks_ScreenToPlaceNextObject	; Store A in $1BA1
	ASL
	CLC				; |Multiply A by 2 and add $1928 to it
	ADC.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject	; |Set Y to A
	TAY
#LM300Hijack_CustomLevelDimensions09:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataBank
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataBank
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$10			; |If high coordinate is set...
	BEQ.b LoadNoHiCoord		; |(Lower half of horizontal level)
	INC.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |(Right half of vertical level)
	INC.b !RAM_SMW_Pointer_HiMap16BlockDataHi	; |...increase $6C and $6F
LoadNoHiCoord:
	LDA.b !RAM_SMW_Blocks_ObjectNumber
	BNE.b LevLoadJsrNrm		; |If block number is x00 (extended object),
	JSR.w LevLoadExtObj						; Optimization: Why not JSL.l to SMW_ProcessExtendedObjects_Main directly?
	JMP.w LevLoadContinue						; Optimization: BRA.b?

LevLoadJsrNrm:
	JSR.w LevLoadNrmObj						; Optimization: Why not JSL.l to SMW_ProcessStandardAndTilesetSpecificObjects_Main directly?
LevLoadContinue:
	SEP.b #$20			; A->8
	REP.b #$10			; XY->16
	LDY.w #$0000							;\ Optimization: Again with the unnecessary Y load to index the first entry in an indirect.
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y				;/
	CMP.b #$FF			; |If the next byte is xFF, return (loading is done).
if defined("Define_SMW_SA1")
	BEQ.b Return0586E9
else
	BEQ.b LevelDataEnd		; |Otherwise, repeat this routine.
endif
if defined("Define_SMW_SA1")
	JML.l KeepLoading
else
	JMP.w Main

LevelDataEnd:
	RTS								; Optimization: This could have pointed to one of the below RTSs, but given that those bits of code are useless anyway, it's no big deal.
endif

LevLoadExtObj:
	SEP.b #$30							;\ Optimization: A/X/Y are already 8-bit!
	JSL.l SMW_ProcessExtendedObjects_Main				;|
Return0586E9:
	RTS								;/

LevLoadNrmObj:
	SEP.b #$30							;\ Optimization: A/X/Y are already 8-bit!
	JSL.l SMW_ProcessStandardAndTilesetSpecificObjects_Main		;|
	RTS								;/
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_InitializeMap16Pointers(Address)
namespace SMW_InitializeMap16Pointers
%InsertMacroAtXPosition(<Address>)

; Map16 shared/tileset-specific mask, one bit per tile from high to low, for
; tiles $000-$1FF. When the game sets up the tile pointers, a set bit takes
; the next definition from the shared table (SMW_Map16Data_Global) and a
; clear bit takes it from the tileset's own table (the TilesetMap16Ptrs
; entry); each cursor advances by 8, one definition, only when it is used.
DATA_0581BB:
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$E0,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $FE,$00,$7F,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$E0,$00,$00,$03,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

Main:
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting
	ASL				; |Store tileset*2 in X
	TAX
	LDA.b #DATA_0581BB>>16		; \Store x05 in $0F
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b #DATA_00E55E>>16		; \Store x00 in $84
	STA.b !RAM_SMW_Pointer_SlopeSteepnessBank
	LDA.b #$C4			; \Store xC4 in $1430
	STA.w !RAM_SMW_Blocks_LowestNumberSolidMap16TileForSprites
	LDA.b #$CA			; \Store xCA in $1431
	STA.w !RAM_SMW_Blocks_HighestNumberSolidMap16TileForSprites
	REP.b #$20			; A->16
	LDA.w #DATA_00E55E		; \Store xE55E in $82-$83
	STA.b !RAM_SMW_Pointer_SlopeSteepnessLo
	LDA.l TilesetMap16Ptrs,x	; \Store address to MAP16 data in $00-$01
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #SMW_Map16Data_Global	; \Store x8000 in $02-$03
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w #DATA_0581BB		; \Store x81BB in $0D-$0E
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	STZ.b !RAM_SMW_Misc_ScratchRAM04
	STZ.b !RAM_SMW_Misc_ScratchRAM09	; |Store x00 in $04, $09 and $0B
	STZ.b !RAM_SMW_Misc_ScratchRAM0B
	REP.b #$10			; XY->16
	LDY.w #$0000			; \Set X and Y to x0000
	TYX
CODE_058237:
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Misc_ScratchRAM0C
CODE_05823D:
	ASL.b !RAM_SMW_Misc_ScratchRAM0C
	BCC.b CODE_058253
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_Pointer_Map16Tiles,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JMP.w CODE_058262

CODE_058253:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Pointer_Map16Tiles,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_058262:
	SEP.b #$20			; A->8
	INX
	INX
	INC.b !RAM_SMW_Misc_ScratchRAM09
	INC.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	CMP.b #$08
	BNE.b CODE_05823D
	STZ.b !RAM_SMW_Misc_ScratchRAM0B
	INY
	CPY.w #$0040
	BNE.b CODE_058237
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting
	BEQ.b CODE_058281
	CMP.b #$07
	BNE.b CODE_0582C5
CODE_058281:
	LDA.b #$FF
	STA.w !RAM_SMW_Blocks_LowestNumberSolidMap16TileForSprites
	STA.w !RAM_SMW_Blocks_HighestNumberSolidMap16TileForSprites
	REP.b #$30			; AXY->16
	LDA.w #DATA_00E5C8
	STA.b !RAM_SMW_Pointer_SlopeSteepnessLo
	LDA.w #$01C4
	ASL
	TAY
	LDA.w #SMW_Map16Data_SlopedPipeTiles
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w #$0003
CODE_05829D:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Pointer_Map16Tiles,y
	CLC
	ADC.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INY
	INY
	DEX
	BPL.b CODE_05829D
	LDA.w #$01EC
	ASL
	TAY
	LDX.w #$0003
CODE_0582B5:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Pointer_Map16Tiles,y
	CLC
	ADC.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INY
	INY
	DEX
	BPL.b CODE_0582B5
CODE_0582C5:
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_InitializeMap16Pointers(Address)
namespace SMW_InitializeMap16Pointers
%InsertMacroAtXPosition(<Address>)

TilesetMap16Ptrs:
	dw SMW_Map16Data_Grassland	; Tileset 0 (Normal 1)
	dw SMW_Map16Data_Castle		; Tileset 1 (Castle 1)
	dw SMW_Map16Data_Rope		; Tileset 2 (Rope 1)
	dw SMW_Map16Data_Underground	; Tileset 3 (Underground 1)
	dw SMW_Map16Data_GhostHouse	; Tileset 4 (Switch Palace 1)
	dw SMW_Map16Data_GhostHouse	; Tileset 5 (Ghost House 1)
	dw SMW_Map16Data_Rope		; Tileset 6 (Rope 2)
	dw SMW_Map16Data_Grassland	; Tileset 7 (Normal 2)
	dw SMW_Map16Data_Rope		; Tileset 8 (Rope 3)
	dw SMW_Map16Data_Underground	; Tileset 9 (Underground 2)
	dw SMW_Map16Data_Underground	; Tileset A (Switch Palace 2)
	dw SMW_Map16Data_Underground	; Tileset B (Castle 2)
	dw SMW_Map16Data_Grassland	; Tileset C (Cloud/Forest)
	dw SMW_Map16Data_GhostHouse	; Tileset D (Ghost House 2)
	dw SMW_Map16Data_Underground	; Tileset E (Underground 3)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_SpecifySublevelToLoad(Address)				; Optimzation: This routine is not very well optimized
namespace SMW_SpecifySublevelToLoad
%InsertMacroAtXPosition(<Address>)

incsrc "overworld/tables/level-events.asm"
namespace off
endmacro

macro ROUTINE_RT01_SMW_SpecifySublevelToLoad(Address)
namespace SMW_SpecifySublevelToLoad
%InsertMacroAtXPosition(<Address>)

; The four camera Y positions Layer 1 (FG) can start a level at. Indexed by
; bits 2-3 of SecondaryHeader3 for a main entrance, and by bits 4-5 of
; SecondaryEntrance2 for a secondary one.
Layer1InitialYPositions:
	db $00,$60,$C0,$00		;>Layer 1 inital Y position

; The same four for Layer 2 (BG), indexed by bits 0-1 of SecondaryHeader3 or
; bits 6-7 of SecondaryEntrance2.
Layer2InitialYPositions:
	db $60,$90,$C0,$00		;>Layer 2 inital Y position

; Vertical scroll settings for layer 2 background. The values in this table
; are for RAM $7E:1414. The index to this table is the %ssss from the
; %ssssyyyy in SecondaryHeader1.
L2VertScrollSettings:			; Info: Layer 2 vertical scroll setting...
	db $03				; Slow
	db $01				; Constant
	db $01				; Constant
	db $00				; None
	db $00				; None
	db $02				; Variable
	db $02				; Variable
	db $01				; Constant
#LM300Hijack_CustomL2VerticalScroll:	; LM: (3.00+)
if !Define_SMW_LunarMagicLevels == !TRUE
	db $04				; Medium 2, 1:4 (Config/LunarMagicLevels.asm)
	db $05				; Medium 3, 1:8
	db $06				; Medium 4, 1:16
	db $07				; Slow 2, 1:64
else
	db $00				; None/Variable 2
	db $00				; None/Variable 3
	db $00				; None/Variable 4
	db $00				; None/Slow 2
endif
	db $00				; None
	db $00				; None
	db $00				; None
	db $00				; None

; Horizontal scroll settings for layer 2 background. The values in this
; table are for RAM $7E:1413. The index to this table is the %ssss from the
; %ssssyyyy in SecondaryHeader1. The maximum %ssss in SMW is %0111, thus
; indexes %1000 through %1111 are unused and are available if you want to
; invent more scroll settings for layer 2.
L2HorzScrollSettings:
	db $02				; Variable
	db $02				; Variable
	db $01				; Constant
	db $00				; None
	db $01				; Constant
	db $02				; Variable
	db $01				; Constant
	db $00				; None
#LM300Hijack_CustomL2HorizontalScroll:	; LM: (3.00+)
if !Define_SMW_LunarMagicLevels == !TRUE
	db $02				; Variable, the four pairs' horizontal half (Config/LunarMagicLevels.asm)
	db $02				; Variable
	db $02				; Variable
	db $02				; Variable
else
	db $00				; None/Variable
	db $00				; None/Variable
	db $00				; None/Variable
	db $00				; None/Variable
endif
	db $00				; None
	db $00				; None
	db $00				; None
	db $00				; None

; The low byte of the sixteen Y positions the player can enter a level at.
; Indexed by the low nibble of SecondaryHeader1 for a main entrance, and of
; SecondaryEntrance2 for a secondary one. EntranceYPosHi holds the high byte.
EntranceYPosLo:
	db $00,$30,$60,$80,$A0,$B0,$C0,$E0
	db $10,$30,$50,$60,$70,$90,$00,$00

; The high byte of those sixteen Y positions. In a vertical level it is
; overwritten by the entrance screen before it is used, so only a horizontal
; level ever enters at the height this table gives.
EntranceYPosHi:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $01,$01,$01,$01,$01,$01,$01,$01

; The low byte of the eight X positions the player can enter a level at --
; roughly one per screen. Indexed by bits 0-2 of SecondaryHeader2 for a main
; entrance, and by bits 5-7 of SecondaryEntrance3 for a secondary one.
EntranceXPosLo:
	db $10,$80,$00,$E0,$10,$70,$00,$E0

; The high byte of those eight X positions. In a horizontal level it is
; overwritten by the entrance screen before it is used, so only a vertical
; level ever enters at the screen this table gives.
EntranceXPosHi:
	db $00,$00,$00,$00,$01,$01,$01,$01

; The tileset that each no-Yoshi intro intro is used with. Same order as
; $05D766 (0x2D966). The last one seems to be unused.
LevelEntranceTileset:
	db $05,$01,$02,$06,$08,$01

; List of 6 pointers to the "Get off Yoshi" level intros. In order: Ghost
; House, Castle Entrance 1, No Yoshi Sign 1, No Yoshi Sign 2, No Yoshi Sign
; 3, Castle Entrance 2.
LevelEntranceLayer1:
	dl SMW_LEVEL_L1_GhostHouseEntrance
	dl SMW_LEVEL_L1_CastleEntrance
	dl SMW_LEVEL_L1_NoYoshiEntrance1
	dl SMW_LEVEL_L1_NoYoshiEntrance2
	dl SMW_LEVEL_L1_NoYoshiEntrance3
	dl SMW_LEVEL_L1_CastleEntrance2

; List of pointers to the Layer 2's for the "Get off Yoshi" intro levels.
; Same order as for 2D966
LevelEntranceLayer2:
	dl SMW_LEVEL_L1_BlankEntrance
	dw SMW_Backgrounds_Layer2_Mountains	:	db $FF
	dw SMW_Backgrounds_Layer2_Mountains	:	db $FF
	dw SMW_Backgrounds_Layer2_Stars		:	db $FF
	dw SMW_Backgrounds_Layer2_Rocks2	:	db $FF
	dw SMW_Backgrounds_Layer2_Black		:	db $FF

LevelEntranceLayer3:
	db $03,$00,$00,$00,$00,$00

LevelEntranceYPos:
	db $70,$70,$60,$70,$70,$70

Main:
;$05D796
	; The main level data loading routine. $05DAE5 is which level has the
	; variable exits that changes depending on coins, timer, and yoshi coins.
	; To disable the variable properties of this level, change $05DAE6 to 80.
	; $05DA19 is the start of the code for checking whether or not the level
	; should use a No-Yoshi intro. Change to [4C D7 DA] to disable all No-Yoshi
	; intros, including those for ghost houses and castles.
	PHB
	PHK
	PLB
	SEP.b #$30			; AXY->8
	STZ.w !RAM_SMW_Flag_OverrideNoYoshiIntroForMidwayEntrance
	LDA.w !RAM_SMW_InYoshiWingsBonusArea
	BNE.b CODE_05D7A8
	LDY.w !RAM_SMW_Flag_ActiveBonusGame
	BEQ.b CODE_05D7AB
CODE_05D7A8:
	JSR.w CODE_05DBAC
CODE_05D7AB:
	LDA.w !RAM_SMW_Counter_SublevelsEntered
	BNE.b CODE_05D7B3
	JMP.w CODE_05D83E

CODE_05D7B3:
	LDX.b !RAM_SMW_Player_XPosHi
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.b #$01
#LM300Hijack_CustomLevelDimensions01:
	BEQ.b CODE_05D7BD
	LDX.b !RAM_SMW_Player_YPosHi
CODE_05D7BD:
	LDA.w !RAM_SMW_Misc_SubscreenExitEntranceNumberLo,x
	STA.w !RAM_SMW_UnusedRAM_7E17BB					; Optimization: This is unused
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	BEQ.b CODE_05D7D2						; Note: !Define_SMW_Overworld_MainMap
	LDA.b #$01
CODE_05D7D2:
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.w !RAM_SMW_Flag_UseSecondaryEntrance			;\ Note: Levels in SMW can only use either main entrances or secondary entrances for screen exits.
	BEQ.b CODE_05D83B						;/ LM Allows you to mix and match.
	REP.b #$30			; AXY->16
	LDA.w #$0000
	SEP.b #$20			; A->8
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
#LM250Hijack_Expand05F800:
	LDA.w SecondaryEntrance1,y
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	STA.w !RAM_SMW_UnusedRAM_7E17BB					; Optimization: This is unused
#LM250Hijack_Expand05FA00:
	LDA.w SecondaryEntrance2,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$0F
	TAX
	LDA.l EntranceYPosLo,x
	STA.b !RAM_SMW_Player_YPosLo
	LDA.l EntranceYPosHi,x
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$30
	LSR
	LSR
	LSR
	LSR
	TAX
	LDA.l Layer1InitialYPositions,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	TAX
	LDA.l Layer2InitialYPositions,x
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
#LM250Hijack_Expand05FC00:
	LDA.w SecondaryEntrance3,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LSR
	LSR
	LSR
	LSR
	LSR
	TAX
	LDA.l EntranceXPosLo,x
	STA.b !RAM_SMW_Player_XPosLo
	LDA.l EntranceXPosHi,x
	STA.b !RAM_SMW_Player_XPosHi
	LDA.w SecondaryEntrance4,y
#LM250Hijack_ExpandAndModify05FE00:
	AND.b #$07
	STA.w !RAM_SMW_Misc_LevelHeaderEntranceSettings
CODE_05D83B:
	JMP.w CODE_05D8B7

CODE_05D83E:
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	LDY.b #$00
	LDA.w !RAM_SMW_Misc_IntroLevelFlag
; The override test, named because it is the whole of what makes $00 special:
; a non-zero value here *is* the level to load, so $00 is the one value that
; asks for no level at all and reads the overworld tile instead. A branch
; taken unconditionally here makes $x00 a level number like any other.
OverrideTest:
	BNE.b CODE_05D8A2
	REP.b #$30			; AXY->16
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	; Set "X position of screen boundary" to 0
	STZ.b !RAM_SMW_Mirror_CurrentLayer2XPosLo	; Set "Layer 2 X position" to 0
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	AND.w #$000F
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	AND.w #$000F
	ASL
	ASL
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	AND.w #$0010
	ASL
	ASL
	ASL
	ASL
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	AND.w #$0010
	ASL
	ASL
	ASL
	ASL
	ASL
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	TAX
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	AND.w #$00FF
	LSR				; |Set Y to current player
	LSR
	TAY
	LDA.w !RAM_SMW_Overworld_MarioMap,y	; \ Get current player's submap
	AND.w #$000F
	BEQ.b CODE_05D899
	TXA
	CLC				; |If on submap, increase X by x400
	ADC.w #$0400
	TAX
CODE_05D899:
	SEP.b #$20			; A->8
if !Define_SMW_TranslevelRemap == !TRUE
	; The tile path reads its level number off the remap table instead of
	; computing it. The lookup lives beside the table in the relocated bank:
	; this run of bank $05 is packed to the byte, so there is no room to
	; grow, and it may not shrink either -- the ROM map places every
	; routine at a literal address, so the JML pads back to the exact size
	; of the two instructions it stands in for and nothing after it moves
	; on any base. The three padded bytes are dead: nothing jumps into
	; them. On the sa1 base the pack's map16 remap is off, and the vendored
	; remap/map16.asm stands its rewrite of this read down under the same
	; define besides -- the lookup reads the table where the pack keeps it;
	; see Config/TranslevelRemap.asm and the vendored remap/map16.asm. X is
	; still the tile's Map16 index, so the lookup makes the same read and
	; the same store these two made before taking the level number off its
	; table and rejoining at CODE_05D8B7. The code from CODE_05D8A2 to
	; CODE_05D8B5 then serves only the intro-override path, which enters at
	; CODE_05D8A2 with a value that is not a scan translevel and keeps the
	; arithmetic.
	JML.l SMW_TranslevelRemap_TileLevelLookup
	NOP
	NOP
	NOP
else
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x
	STA.w !RAM_SMW_Overworld_LevelNumberLo	; Store overworld level number
endif
CODE_05D8A2:
	CMP.b #$25
; The adjustment test. A level from $25 up is asked for by a value $24 higher
; than itself, so the low bytes $DC through $FF cannot be asked for at all --
; they would need a value past $FF. A branch taken unconditionally here skips
; the subtraction, and every low byte then means itself.
AdjustmentTest:
	BCC.b CODE_05D8A9
	SEC				; |If A>= x25,
	SBC.b #$24			; |subtract x24
CODE_05D8A9:
	STA.w !RAM_SMW_UnusedRAM_7E17BB				; Optimization: This is unused
	STA.b !RAM_SMW_Misc_ScratchRAM0E	; Store A as lower level number byte
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	BEQ.b CODE_05D8B5					; Note: !Define_SMW_Overworld_MainMap
	LDA.b #$01			; |0 if on overworld
CODE_05D8B5:
	STA.b !RAM_SMW_Misc_ScratchRAM0F
CODE_05D8B7:
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ASL
	CLC									; Optimization: X could have been set here and transfered here to save a few bytes later in this routine
	ADC.b !RAM_SMW_Misc_ScratchRAM0E	; |(Each L1/2 pointer table entry is 3 bytes long)
	TAY
	SEP.b #$20			; A->8
	LDA.w Layer1DataPtrs,y							;\ Optimization: There is no reason not to use 16-bit A here.
	STA.b !RAM_SMW_Pointer_Layer1DataLo					;|
	LDA.w Layer1DataPtrs+$01,y						;|
	STA.b !RAM_SMW_Pointer_Layer1DataHi					;|
	LDA.w Layer1DataPtrs+$02,y						;|
	STA.b !RAM_SMW_Pointer_Layer1DataBank					;|
	LDA.w Layer2DataPtrs,y							;|
	STA.b !RAM_SMW_Pointer_Layer2DataLo					;|
	LDA.w Layer2DataPtrs+$01,y						;|
	STA.b !RAM_SMW_Pointer_Layer2DataHi					;|
	LDA.w Layer2DataPtrs+$02,y						;|
	STA.b !RAM_SMW_Pointer_Layer2DataBank					;|
	REP.b #$20								;|\ Optimization: If X were stored to earlier, then changing A's size wouldn't be necessary
#LM000Hijack_StoreSublevelNumber:						;|| From there, the following two tables could be made to use X instead of Y.
if !SMW_LevelNumberStashWanted == !TRUE
	; The same four bytes as the three instructions below. The stub makes
	; the same read, stores the level number word to
	; !RAM_SMW_LevelNumberStash_LoadedLevel -- the value is whole here and
	; nowhere after the load without help -- and returns with A doubled
	; into Y exactly as these left it. One stash for the custom level
	; palettes and the level graphics both: see Config/LevelNumberStash.asm.
	JSL.l SMW_LevelNumberStash_Store
else
	LDA.b !RAM_SMW_Misc_ScratchRAM0E					;||
	ASL									;||
	TAY									;||
endif
	LDA.w #$0000								;||
	SEP.b #$20								;||
	LDA.w SpriteDataPtrs,y							;||
	STA.b !RAM_SMW_Pointer_SpriteListDataLo					;||
	LDA.w SpriteDataPtrs+$01,y						;|/
	STA.b !RAM_SMW_Pointer_SpriteListDataHi					;|
#LM100Hijack_RemoveHardcodedSpriteListBank:					;|
if !Define_SMW_ManagedLevelMemory == !TRUE
	; The same four bytes as the two instructions below. The stub reads
	; the bank from a table of one byte per level, indexed off the Y this
	; path has just used for the dw rows, so a sprite list may sit in any
	; bank the packer put it in. Same size, so nothing here moves -- SA-1
	; Pack patches this routine's operands by literal address. See
	; Config/ManagedLevelMemory.asm.
	JSL.l SMW_ManagedLevelMemory_SpriteBank					;|
else
	LDA.b #SMW_SpriteDataBank>>16						;| The one bank every sprite list is in on a stock
	STA.b !RAM_SMW_Pointer_SpriteListDataBank				;/ cartridge
endif
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo]	; \ Get first byte of sprite data (header)
	AND.b #$3F			; |Get level's sprite memory
	STA.w !RAM_SMW_Sprites_SpriteMemorySetting	; / Store in $1692
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo]	; \ Get first byte of sprite data (header) again
	AND.b #$C0			; |Get level's sprite buoyancy settings
	STA.w !RAM_SMW_Sprites_SpriteBuoyancySettings	; / Store in $190E
	REP.b #$10								;\ Optimization: A is already 8-bit and X/Y 16-bit!
	SEP.b #$20								;/
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w SecondaryHeader1,y
	LSR
	LSR
	LSR
	LSR
	TAX
	LDA.l L2HorzScrollSettings,x
	STA.w !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting
	LDA.l L2VertScrollSettings,x
	STA.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	LDA.b #$01
	STA.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	LDA.w SecondaryHeader2,y
	AND.b #$C0
	CLC
	ASL
	ROL
	ROL
	STA.w !RAM_SMW_Misc_LevelLayer3Settings
	STZ.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	STZ.b !RAM_SMW_Mirror_CurrentLayer2YPosHi
	LDA.w SecondaryHeader4,y
	AND.b #$80
	STA.w !RAM_SMW_Flag_DisableNoYoshiIntro
	LDA.w SecondaryHeader4,y
	AND.b #$60
	LSR
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_LevelLayoutFlags
	LDA.w !RAM_SMW_Flag_UseSecondaryEntrance
	BNE.b CODE_05D9A1
	LDA.w SecondaryHeader1,y
	AND.b #$0F
	TAX
	LDA.l EntranceYPosLo,x
	STA.b !RAM_SMW_Player_YPosLo
	LDA.l EntranceYPosHi,x
	STA.b !RAM_SMW_Player_YPosHi
	LDA.w SecondaryHeader2,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	AND.b #$07
	TAX
	LDA.l EntranceXPosLo,x
	STA.b !RAM_SMW_Player_XPosLo
	LDA.l EntranceXPosHi,x
	STA.b !RAM_SMW_Player_XPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	AND.b #$38
	LSR
	LSR
#LM000Hijack_ExpandedLevelHeader:
	LSR
	STA.w !RAM_SMW_Misc_LevelHeaderEntranceSettings
	LDA.w SecondaryHeader3,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	AND.b #$03
	TAX
	LDA.l Layer2InitialYPositions,x
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	AND.b #$0C
	LSR
	LSR
	TAX
	LDA.l Layer1InitialYPositions,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.w SecondaryHeader4,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
CODE_05D9A1:
#LM300Hijack_CustomLevelDimensions02:
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.b #$01
	BEQ.b CODE_05D9B8
	LDY.w #$0000
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	AND.b #$1F
	STA.b !RAM_SMW_Player_YPosHi
	INC
	STA.b !RAM_SMW_Camera_LastScreenVert
	LDA.b #$01
	STA.w !RAM_SMW_Flag_Layer1VerticalScrollLevelSetting
CODE_05D9B8:
	LDA.w !RAM_SMW_Counter_SublevelsEntered
	BNE.b CODE_05D9EC
	LDA.b !RAM_SMW_Misc_ScratchRAM02			;\ SecondaryHeader3's high nibble: the midway entrance screen
	LSR							;|
	LSR							;|
	LSR							;|
	LSR							;|
	STA.w !RAM_SMW_Misc_MidwayEntranceScreen		;/
	STZ.w !RAM_SMW_Flag_GotMidpoint
	LDY.w !RAM_SMW_Overworld_LevelNumberLo			;\ Optimization: If that SEP.b #$10 was done a bit earlier, then $7E13C0 would be free RAM. 
	LDA.w LevelEventNumbers,y				;|
	STA.w !RAM_SMW_Overworld_CurrentEventNumber		;|
	SEP.b #$10						;/
	LDX.w !RAM_SMW_Overworld_LevelNumberLo
	LDA.w !RAM_SMW_Overworld_LevelTileSettings,x
	AND.b #$40							;\ The midway point has been passed, so enter by
	BEQ.b CODE_05D9EC						;/ the midway entrance rather than the main one
	STA.w !RAM_SMW_Flag_OverrideNoYoshiIntroForMidwayEntrance
	LDA.b !RAM_SMW_Misc_ScratchRAM02				;\ SecondaryHeader3's high nibble takes the place of
	LSR								;| the main entrance screen. Everything else about
	LSR								;| the entrance stays the main one's, so the midway
	LSR								;| entrance is the same position on another screen.
	LSR								;| It always lands on X, where a vertical level wants
	STA.b !RAM_SMW_Player_XPosHi					;/ Y -- no level with a midway entrance is vertical.
	JMP.w CODE_05DA17

CODE_05D9EC:
	REP.b #$10			; XY->16
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	AND.b #$1F
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.b #$01
	BNE.b CODE_05DA01
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Player_XPosHi
	JMP.w CODE_05DA17

CODE_05DA01:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Player_YPosHi
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	SEP.b #$10			; XY->8
	LDY.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	CPY.b #$03
	BEQ.b CODE_05DA12
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosHi
CODE_05DA12:
	LDA.b #$01
	STA.w !RAM_SMW_Flag_Layer1VerticalScrollLevelSetting
CODE_05DA17:
if !Define_SMW_LunarMagicLevels == !TRUE
	JSL.l SMW_LunarMagicLevels_ScrollSettings	;\ A level with settings of its own writes them over
	NOP						;/ the pair (Config/LunarMagicLevels.asm)
else
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Overworld_LevelNumberLo				;\ Optimization: Junk code.
endif
	CMP.b #$52							;| All this does is force the special world levels to have no-yoshi intros, except all of them disable the intros anyway in the header settings. 
	BCC.b CODE_05DA24						;|
	LDX.b #$03							;|
	BRA.b CODE_05DA38						;/

CODE_05DA24:
	LDX.b #$04
	LDY.b #$04
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	AND.b #$0F
CODE_05DA2C:
	CMP.l LevelEntranceTileset,x
	BEQ.b CODE_05DA38
	DEX
	BPL.b CODE_05DA2C
CODE_05DA35:
	JMP.w CODE_05DAD7

CODE_05DA38:
	LDA.w !RAM_SMW_Counter_SublevelsEntered
	BNE.b CODE_05DA35
	LDA.w !RAM_SMW_Flag_ShowPlayerStart
	BNE.b CODE_05DA35
	LDA.w !RAM_SMW_Flag_DisableNoYoshiIntro
	BNE.b CODE_05DA35
	LDA.w !RAM_SMW_Overworld_LevelNumberLo
	CMP.b #$31
	BEQ.b CODE_05DA5E
	CMP.b #$32
	BEQ.b CODE_05DA5E
	CMP.b #$34
	BEQ.b CODE_05DA5E
	CMP.b #$35
	BEQ.b CODE_05DA5E
	CMP.b #$40
	BNE.b CODE_05DA60
CODE_05DA5E:
	LDX.b #$05
CODE_05DA60:
	LDA.w !RAM_SMW_Flag_OverrideNoYoshiIntroForMidwayEntrance
	BNE.b CODE_05DAD0
	LDA.l LevelEntranceYPos,x
	STA.b !RAM_SMW_Player_YPosLo
	LDA.b #$01
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b #$30
	STA.b !RAM_SMW_Player_XPosLo
	STZ.b !RAM_SMW_Player_XPosHi
	LDA.b #$C0
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	STZ.w !RAM_SMW_Misc_LevelHeaderEntranceSettings
	LDA.b #SMW_LEVEL_SP_0BD
	STA.b !RAM_SMW_Pointer_SpriteListDataLo
	LDA.b #SMW_LEVEL_SP_0BD>>8
	STA.b !RAM_SMW_Pointer_SpriteListDataHi
	LDA.b #SMW_LEVEL_SP_0BD>>16
	STA.b !RAM_SMW_Pointer_SpriteListDataBank
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo]						;\ LM: Hijacks here for something related to the custom level dimensions
	AND.b #$3F										;/
	STA.w !RAM_SMW_Sprites_SpriteMemorySetting
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo]
	AND.b #$C0
	STA.w !RAM_SMW_Sprites_SpriteBuoyancySettings
	STZ.w !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting
	STZ.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	STZ.b !RAM_SMW_Misc_LevelLayoutFlags
	LDA.l LevelEntranceLayer3,x
	STA.w !RAM_SMW_Misc_LevelLayer3Settings
	STX.b !RAM_SMW_Misc_ScratchRAM00
	TXA
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	LDA.w LevelEntranceLayer1,y
	STA.b !RAM_SMW_Pointer_Layer1DataLo
	LDA.w LevelEntranceLayer1+$01,y
	STA.b !RAM_SMW_Pointer_Layer1DataHi
	LDA.w LevelEntranceLayer1+$02,y
	STA.b !RAM_SMW_Pointer_Layer1DataBank
	LDA.w LevelEntranceLayer2,y
	STA.b !RAM_SMW_Pointer_Layer2DataLo
	LDA.w LevelEntranceLayer2+$01,y
	STA.b !RAM_SMW_Pointer_Layer2DataHi
	LDA.w LevelEntranceLayer2+$02,y
	STA.b !RAM_SMW_Pointer_Layer2DataBank
CODE_05DAD0:
	LDA.l LevelEntranceTileset,x
	STA.w !RAM_SMW_Misc_LevelTilesetSetting
CODE_05DAD7:
	LDA.w !RAM_SMW_Counter_SublevelsEntered
	BEQ.b CODE_05DAEB
	LDA.w !RAM_SMW_Flag_ActiveBonusGame
	BNE.b CODE_05DAEB
	LDA.w !RAM_SMW_Overworld_LevelNumberLo
	CMP.b #!Define_SMW_LevelID_ChocolateIsland2
#LM000Hijack_DisableChocolateIsland2Gimmick:
	BNE.b CODE_05DAEB					; LM: Changes BNE.b to BRA.b if Chocolate Island 2's gimmick is disabled.
	JSR.w HandleChocolateIsland2Gimmick
CODE_05DAEB:
	PLB
	SEP.b #$30			; AXY->8
	RTL

; The routine that loads level data for the sublevels of the level with the
; variable screen exits (i.e. level 24, or Chocolate Island 2, in the
; original SMW).
HandleChocolateIsland2Gimmick:
	SEP.b #$30			; AXY->8
	LDY.b #$04
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y		;\ Note: It seems that Chocolate Island 2 uses the item memory bits to determine what section of the level you're on.
	AND.b #$C0					;| Crash: Which means that if you uses item memory 3, the game will crash.
	CLC						;|
	ROL						;|
	ROL						;|
	ROL						;|
	JSL.l SMW_ExecutePtr_Long			;/

PtrsLong05DAFF:
	dl YoshiCoinCheck
	dl CoinsCollectedCheck
	dl TimeRemainingCheck

; Pointers to the layer 1 data that should be loaded for Chocolate Island 2.
Layer1Ptrs:
	dw SMW_LEVEL_L1_0CD
	dw SMW_LEVEL_L1_024_5
	dw SMW_LEVEL_L1_024_5
	dw SMW_LEVEL_L1_0CF
	dw SMW_LEVEL_L1_024_1
	dw SMW_LEVEL_L1_024_2
	dw SMW_LEVEL_L1_0CE
	dw SMW_LEVEL_L1_024_3
	dw SMW_LEVEL_L1_024_4

; Pointers to the sprite data that should be loaded for Chocolate Island 2.
SpritePtrs:
	dw SMW_LEVEL_SP_0CD
	dw SMW_LEVEL_SP_024_5
	dw SMW_LEVEL_SP_024_5
	dw SMW_LEVEL_SP_0CF
	dw SMW_LEVEL_SP_024_1
	dw SMW_LEVEL_SP_024_2
	dw SMW_LEVEL_SP_0CE
	dw SMW_LEVEL_SP_024_3
	dw SMW_LEVEL_SP_024_4

; Pointers to the layer 2 data that should be loaded for Chocolate Island 2
; (all identical).
Layer2Ptrs:
	dw SMW_Backgrounds_Layer2_Rocks2
	dw SMW_Backgrounds_Layer2_Rocks2
	dw SMW_Backgrounds_Layer2_Rocks2
	dw SMW_Backgrounds_Layer2_Rocks2
	dw SMW_Backgrounds_Layer2_Rocks2
	dw SMW_Backgrounds_Layer2_Rocks2
	dw SMW_Backgrounds_Layer2_Rocks2
	dw SMW_Backgrounds_Layer2_Rocks2
	dw SMW_Backgrounds_Layer2_Rocks2

YoshiCoinCheck:
	LDX.b #$00
	LDA.w !RAM_SMW_Counter_YoshiCoinsToDisplay
	CMP.b #$04
	BEQ.b CODE_05DB49
	LDX.b #$02
CODE_05DB49:
	REP.b #$20			; A->16
if !Define_SMW_ManagedLevelMemory == !TRUE
	; The same six bytes as the two instructions below. Layer1Ptrs is dw,
	; so the bank byte stays whatever the main path resolved for level
	; $024 -- right while every sub-level shares $024's bank, which the
	; stock banks guarantee and the managed level banks do not. The stub
	; repeats the read and supplies each sub-level's own bank from a table
	; beside the packed run, and pads back to the exact size because SA-1
	; Pack patches this routine's operands by literal address. The two
	; padded bytes are dead: nothing jumps into them. See
	; Config/ManagedLevelMemory.asm.
	JSL.l SMW_ManagedLevelMemory_ChocolateIsland2Layer1
	NOP
	NOP
else
	LDA.l Layer1Ptrs,x
	STA.b !RAM_SMW_Pointer_Layer1DataLo
endif
	LDA.l SpritePtrs,x
	STA.b !RAM_SMW_Pointer_SpriteListDataLo
	LDA.l Layer2Ptrs,x
	STA.b !RAM_SMW_Pointer_Layer2DataLo
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo]
	AND.b #$7F
	STA.w !RAM_SMW_Sprites_SpriteMemorySetting
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo]
	AND.b #$80
	STA.w !RAM_SMW_Sprites_SpriteBuoyancySettings
	RTS

CoinsCollectedCheck:
	LDX.b #$0A
	LDA.w !RAM_SMW_Counter_GreenStarBlock
	CMP.b #$16
	BPL.b CODE_05DB7F
	LDX.b #$08
	CMP.b #$0A
	BPL.b CODE_05DB7F
	LDX.b #$06
CODE_05DB7F:
	JMP.w CODE_05DB49

TimeRemainingCheck:
	LDX.b #$0C
	LDA.w !RAM_SMW_Counter_TimerHundreds
	CMP.b #$02
	BMI.b CODE_05DBA6
	LDA.w !RAM_SMW_Counter_TimerTens
	CMP.b #$03
	BMI.b CODE_05DBA6
	BNE.b CODE_05DB9B
	LDA.w !RAM_SMW_Counter_TimerOnes
	CMP.b #$05
	BMI.b CODE_05DBA6
CODE_05DB9B:
	LDX.b #$0E
	LDA.w !RAM_SMW_Counter_TimerTens
	CMP.b #$05
	BMI.b CODE_05DBA6
	LDX.b #$10
CODE_05DBA6:
	JMP.w CODE_05DB49

; Level number for bonus game after gaining 100 bonus stars from a goal
; tape.
BonusLevelSublevelsLo:
	db $00,$C8,$00

; The routine that handles setting the level to warp to when Yoshi gets the
; wings. (Level xC8.)
CODE_05DBAC:
	LDY.b #$00
	LDA.w !RAM_SMW_InYoshiWingsBonusArea
	BEQ.b CODE_05DBB5
	; Change to 60 (RTS) to make it so Yoshi wings use the normal screen exit
	; instead of forcing a warp to level C8/1C8. This allows you to use
	; pipes/doors in Yoshi wings levels. However, bonus games still remain
	; incompatible. (Make sure to add a screen exit on every screen a player
	; could possibly collect Yoshi wings if you use this.)
	LDY.b #$01
CODE_05DBB5:
	LDX.b !RAM_SMW_Player_XPosHi
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.b #$01
	BEQ.b CODE_05DBBF
	LDX.b !RAM_SMW_Player_YPosHi
CODE_05DBBF:
	LDA.w BonusLevelSublevelsLo,y
#LM000Hijack_RecodedScreenExits:
	STA.w !RAM_SMW_Misc_SubscreenExitEntranceNumberLo,x
	INC.w !RAM_SMW_Counter_SublevelsEntered
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_SpecifySublevelToLoad(Address)
namespace SMW_SpecifySublevelToLoad
%InsertMacroAtXPosition(<Address>)

Layer1DataPtrs:
	incsrc "levels/pointers/layer1.asm"
Layer2DataPtrs:
	incsrc "levels/pointers/layer2.asm"
SpriteDataPtrs:
	incsrc "levels/pointers/sprites.asm"

; The secondary header: four parallel $200-byte tables, one byte per level
; each, indexed by the level number. It is a second per-level header that does
; not sit next to the level data at all, and it is read here in game mode $11,
; before the primary header is parsed in mode $12.

; Secondary header byte 1: %ssssyyyy
;   ssss  Layer 2 scroll setting, indexing L2HorzScrollSettings and
;         L2VertScrollSettings.
;   yyyy  main entrance Y position, indexing EntranceYPosLo/EntranceYPosHi.
	incsrc "levels/properties/1.asm"

; Secondary header byte 2: %ttaaaxxx
;   tt    Layer 3 setting, rotated into !RAM_SMW_Misc_LevelLayer3Settings.
;   aaa   !RAM_SMW_Misc_LevelHeaderEntranceSettings.
;   xxx   main entrance X position, indexing EntranceXPosLo/EntranceXPosHi.
	incsrc "levels/properties/2.asm"

; Secondary header byte 3: %....ffbb
;   ff    Layer 1 initial camera Y, indexing Layer1InitialYPositions.
;   bb    Layer 2 initial camera Y, indexing Layer2InitialYPositions.
; The high nibble is not read anywhere in this ROM.
	incsrc "levels/properties/3.asm"

; Secondary header byte 4: %iLLeeeee
;   i     !RAM_SMW_Flag_DisableNoYoshiIntro.
;   LL    the two !RAM_SMW_Misc_LevelLayoutFlags bits: bit 5 is Layer 1
;         vertical and bit 6 is Layer 2 vertical. This is not what decides
;         whether the level renders vertically -- the level mode does.
;   eeeee main entrance screen. Which axis it lands on depends on the level:
;         it is the X high byte in a horizontal level and the Y high byte in
;         a vertical one.
	incsrc "levels/properties/4.asm"

; The secondary entrances: four more $200-byte tables in the same shape, but
; indexed by the **secondary entrance number** rather than by the level. They
; are read in place of the four above when !RAM_SMW_Flag_UseSecondaryEntrance
; is set, and a level in this ROM uses one form or the other and never both.

; Secondary entrance byte 1: the destination level number's low byte, which
; becomes the level this routine goes on to load.
	incsrc "levels/properties/5.asm"

; Secondary entrance byte 2: %bbffyyyy
;   bb    Layer 2 initial camera Y, indexing Layer2InitialYPositions.
;   ff    Layer 1 initial camera Y, indexing Layer1InitialYPositions.
;   yyyy  entrance Y position, indexing EntranceYPosLo/EntranceYPosHi.
	incsrc "levels/properties/6.asm"

; Secondary entrance byte 3: %xxxeeeee
;   xxx   entrance X position, indexing EntranceXPosLo/EntranceXPosHi.
;   eeeee entrance screen, as in SecondaryHeader4.
	incsrc "levels/properties/7.asm"

; Secondary entrance byte 4: %.....aaa
;   aaa   !RAM_SMW_Misc_LevelHeaderEntranceSettings, as SecondaryHeader2's
;         middle three bits are for a main entrance.
	incsrc "levels/properties/8.asm"
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_LoadOverworldLifeCounter(Address)
namespace SMW_LoadOverworldLifeCounter
%InsertMacroAtXPosition(<Address>)

; Position of lives counter on the overworld.
DATA_05DBC9:
	db $50,$88,$00,$03
	db $FE,$38
	db $FE,$38
	db $FF

UNK_05DBD2:					;\ Note: This seems to be the big world 1-8 numbers shown in beta screenshots
	dw $3CB8,$3CB9				;|
	dw $3CBA,$3CBB				;|
	dw $3CBA,$BCBA				;|
	dw $3CBC,$3CBD				;|
	dw $3CBE,$3CBF				;|
	dw $3CC0,$BCB7				;|
	dw $3CC1,$3CB9				;|
	dw $3CC2,$BCC2				;/

; Routine that draws the life counter on the overworld border. You can JSL
; to it to update the counter if changing the player's lives while on the
; overworld.
Main:
	PHB
	PHK
	PLB
	LDX.b #$08
CODE_05DBF7:
	LDA.w DATA_05DBC9,x
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	DEX
	BPL.b CODE_05DBF7
	LDX.b #$00
	LDA.w !RAM_SMW_Player_CurrentCharacter
	BEQ.b CODE_05DC0A
	LDX.b #$01
CODE_05DC0A:
	LDA.w !RAM_SMW_Player_MariosLives,x
	INC
	JSR.w SMW_HexToDec_Bank05
	CPX.b #$00
	BEQ.b CODE_05DC23
	CLC
	ADC.b #$22
	STA.l SMW_StripeImageUploadTable[$03].LowByte
	LDA.b #$39
	STA.l SMW_StripeImageUploadTable[$03].HighByte
	TXA
CODE_05DC23:
	CLC
	ADC.b #$22
	STA.l SMW_StripeImageUploadTable[$02].LowByte
	LDA.b #$39
	STA.l SMW_StripeImageUploadTable[$02].HighByte
	LDA.b #$08
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	SEP.b #$20			; A->8
	PLB
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessLevelEndRoutines(Address)
namespace SMW_ProcessLevelEndRoutines
%InsertMacroAtXPosition(<Address>)

; Jumps to Level End Scorecard Subroutine
Main:
if defined("Define_SMW_SA1")
	JML.l level_mode_score_stuff
	db $07,$CC	; the tail of the JSR.w below, which the hijack leaves unreached
else
	PHB
	PHK				; Wrapper
	PLB
	JSR.w Sub
endif
	PLB
	RTL

Sub:
	LDA.w !RAM_SMW_Pointer_CurrentLevelEndProcess
	JSL.l SMW_ExecutePtr_Absolute

Ptrs05CC0E:
	dw SMW_ShowCourseClearText_Main
	dw SMW_DisplayCourseClearTextBonusStars_Main
	dw SMW_GiveTimeBonusAndBonusStars_Main
	dw SMW_GiveTimeBonusAndBonusStars_Return
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_ShowCourseClearText(Address)
namespace SMW_ShowCourseClearText
%InsertMacroAtXPosition(<Address>)

; Change to 80 1C to prevent the player from getting a free 1UP at the goal
; if the tens digit of your bonus star counter and the tens and ones digits
; of your time are all the same
Main:
	LDY.b #$00
	LDX.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Player_MarioBonusStars,x
CODE_05CC6E:
	CMP.b #$0A
	BCC.b CODE_05CC77
	SBC.b #$0A
	INY
	BRA.b CODE_05CC6E

CODE_05CC77:
	CPY.w !RAM_SMW_Counter_TimerTens
	BNE.b CODE_05CC84
	CPY.w !RAM_SMW_Counter_TimerOnes
	BNE.b CODE_05CC84
	INC.w !RAM_SMW_Misc_1upHandler
CODE_05CC84:
	LDA.b #$01
	STA.w !RAM_SMW_Flag_DisableLayer3Scroll
	LDA.b #!BGModeAndTileSizeSetting_Mode01Layer3Priority
	TSB.b !RAM_SMW_Mirror_BGModeAndTileSizeSetting
	REP.b #$30			; AXY->16
	STZ.b !RAM_SMW_Mirror_Layer3XPosLo
	STZ.b !RAM_SMW_Mirror_Layer3YPosLo
	LDY.w #$004A
	TYA
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_05CC9D:
	LDA.w SMW_CourseClearText_Main,y
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	DEX
	DEX
	DEY
	DEY
	BPL.b CODE_05CC9D
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Player_CurrentCharacter
	BEQ.b CODE_05CCC8
	LDY.w #$0000
CODE_05CCB9:
	LDA.w SMW_CourseClearText_Luigi,y
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	INX
	INX
	INY
	CPY.w #SMW_CourseClearText_LuigiEnd-SMW_CourseClearText_Luigi
	BNE.b CODE_05CCB9
CODE_05CCC8:
	LDY.w #$0002
	LDA.b #$04
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_05CCD3:
	LDA.w !RAM_SMW_Counter_TimerHundreds,y
	STA.l SMW_StripeImageUploadTable[$19].LowByte,x
	DEY
	DEX
	DEX
	BPL.b CODE_05CCD3
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_05CCE4:
	LDA.l SMW_StripeImageUploadTable[$19].LowByte,x
	AND.b #$0F
	BNE.b CODE_05CCF9
	LDA.b #$FC
	STA.l SMW_StripeImageUploadTable[$19].LowByte,x
	INX
	INX
	CPX.w #$0004
	BNE.b CODE_05CCE4
CODE_05CCF9:
	SEP.b #$10			; XY->8
	JSR.w SMW_CalculateTimeBonusDigits_Main
	REP.b #$20			; A->16
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_Counter_LevelEndScoreTallyLo
	LDX.b #$42
	LDY.b #$00
	JSR.w SMW_AdjustTimeBonusDisplay_Main
	LDX.b #$00
CODE_05CD10:
	LDA.l SMW_StripeImageUploadTable[$20].LowByte,x
	AND.w #$000F
	BNE.b CODE_05CD26
	LDA.w #$38FC
	STA.l SMW_StripeImageUploadTable[$20].LowByte,x
	INX
	INX
	CPX.b #$08
	BNE.b CODE_05CD10
CODE_05CD26:
	SEP.b #$20			; A->8
	INC.w !RAM_SMW_Pointer_CurrentLevelEndProcess
	LDA.b #$28
	STA.w !RAM_SMW_Timer_DisplayBonusStars
	LDA.b #$4A
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	INC
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_AdjustTimeBonusDisplay(Address)
namespace SMW_AdjustTimeBonusDisplay
%InsertMacroAtXPosition(<Address>)

DATA_05CDE9:
	dw $0000,$2710
	dw $0000,$03E8
	dw $0000,$0064
	dw $0000,$000A
	dw $0000,$0001

Main:
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo,x
	AND.w #$FF00
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo,x
CODE_05CE08:
	PHX
	TYX
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	SEC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	SBC.l DATA_05CDE9+$02,x
else
	SBC.w DATA_05CDE9+$02,x
endif
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM00
if ver_is_japanese(!Define_Global_ROMToAssemble)
	SBC.l DATA_05CDE9,x
else
	SBC.w DATA_05CDE9,x
endif
	STA.b !RAM_SMW_Misc_ScratchRAM04
	PLX
	BCC.b CODE_05CE2F
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo,x
	INC
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo,x
	BRA.b CODE_05CE08

CODE_05CE2F:
	INX
	INX
	INY
	INY
	INY
	INY
	CPY.b #$14
	BNE.b Main
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_CalculateTimeBonusDigits(Address)
namespace SMW_CalculateTimeBonusDigits
%InsertMacroAtXPosition(<Address>)

DATA_05CE3A:
	dw $0000,$0064,$00C8,$012C

DATA_05CE42:
	db $00,$0A,$14,$1E,$28,$32,$3C,$46
	db $50,$5A

Main:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Counter_TimerHundreds
	ASL
	TAX
	LDA.w DATA_05CE3A,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Counter_TimerTens
	TAX
	LDA.w DATA_05CE42,x
	AND.w #$00FF
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Counter_TimerOnes
	AND.w #$00FF
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b #$32
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	LDA.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b #$32
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	LDA.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM03
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_DisplayCourseClearTextBonusStars(Address)
namespace SMW_DisplayCourseClearTextBonusStars
%InsertMacroAtXPosition(<Address>)

DATA_05CD62:
	%INLINEDATATABLE_SMW_TallNumberTiles()

Main:
	LDA.w !RAM_SMW_Counter_BonusStarsEarned
	; Changing this byte to [80] will disable the bonus counter in the 'Course
	; Clear' screen.
	BEQ.b CODE_05CDD5
	DEC.w !RAM_SMW_Timer_DisplayBonusStars
	BPL.b Return05CDE8
	LDY.b #$22
	TYA
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_05CD89:
	LDA.w SMW_GotBonusStarsText_Main,y
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	DEX
	DEY
	BPL.b CODE_05CD89
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	LDA.w !RAM_SMW_Counter_BonusStarsEarned
	AND.b #$0F
	ASL
	TAY
	LDA.w DATA_05CD62+$01,y
	STA.l SMW_StripeImageUploadTable[$0C].LowByte,x
	LDA.w DATA_05CD62,y
	STA.l SMW_StripeImageUploadTable[$10].LowByte,x
	LDA.w !RAM_SMW_Counter_BonusStarsEarned
	AND.b #$F0
	LSR
	LSR
	LSR
	LSR
	BEQ.b CODE_05CDC9
	ASL
	TAY
	LDA.w DATA_05CD62+$01,y
	STA.l SMW_StripeImageUploadTable[$0B].LowByte,x
	LDA.w DATA_05CD62,y
	STA.l SMW_StripeImageUploadTable[$0F].LowByte,x
CODE_05CDC9:
	LDA.b #$22
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	INC
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
CODE_05CDD5:
	DEC.w !RAM_SMW_Timer_WaitBeforeScoreTally
	; Changing this byte to [80] will disable the drumroll sound effect, and
	; the Timer and score tallying at the 'Course Clear' screen.
	BPL.b Return05CDE8
	LDA.w !RAM_SMW_Counter_BonusStarsEarned
	STA.w !RAM_SMW_Timer_DisplayBonusStars
	INC.w !RAM_SMW_Pointer_CurrentLevelEndProcess
	LDA.b #!Define_SMW_Sound1DFC_DrumrollStart
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
Return05CDE8:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_GiveTimeBonusAndBonusStars(Address)
namespace SMW_GiveTimeBonusAndBonusStars
%InsertMacroAtXPosition(<Address>)

DATA_05CEC2:
	db $0A,$00,$64,$00

DATA_05CEC6:
	db $01,$00,$0A,$00

Main:
	PHB
	PHK
	PLB
	REP.b #$20			; A->16
	LDX.b #$00
	LDA.w !RAM_SMW_Player_CurrentCharacter
	AND.w #$00FF
	BEQ.b CODE_05CEDB
	LDX.b #$03
CODE_05CEDB:
	LDY.b #$02
	LDA.w !RAM_SMW_Counter_LevelEndScoreTallyLo
	BEQ.b CODE_05CF05
	CMP.w #$0063
	BCS.b CODE_05CEE9
	LDY.b #$00
CODE_05CEE9:
	SEC
	SBC.w DATA_05CEC2,y
	STA.w !RAM_SMW_Counter_LevelEndScoreTallyLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w DATA_05CEC6,y
	CLC
	ADC.w !RAM_SMW_Player_MarioScoreLo,x
	STA.w !RAM_SMW_Player_MarioScoreLo,x
	LDA.w !RAM_SMW_Player_MarioScoreHi,x
	ADC.w #$0000
	STA.w !RAM_SMW_Player_MarioScoreHi,x
CODE_05CF05:
	LDX.w !RAM_SMW_Counter_BonusStarsEarned
	BEQ.b CODE_05CF36
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_05CF34
	LDX.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Player_MarioBonusStars,x
	CLC
	ADC.b #$01
	; Change to EA EA EA and the player will receive no bonus stars at the end
	; of the level.
	STA.w !RAM_SMW_Player_MarioBonusStars,x
	LDA.w !RAM_SMW_Counter_BonusStarsEarned
	DEC
	STA.w !RAM_SMW_Counter_BonusStarsEarned
	AND.b #$0F
	CMP.b #$0F
	BNE.b CODE_05CF34
	LDA.w !RAM_SMW_Counter_BonusStarsEarned
	SEC
	SBC.b #$06
	STA.w !RAM_SMW_Counter_BonusStarsEarned
CODE_05CF34:
	REP.b #$20			; A->16
CODE_05CF36:
	LDA.w !RAM_SMW_Counter_LevelEndScoreTallyLo
	BNE.b CODE_05CF4D
	LDX.w !RAM_SMW_Counter_BonusStarsEarned
	BNE.b CODE_05CF4D
	LDX.b #$30
	STX.w !RAM_SMW_Timer_WaitBeforeScoreTally
	INC.w !RAM_SMW_Pointer_CurrentLevelEndProcess
	LDX.b #!Define_SMW_Sound1DFC_DrumrollEnd
	STX.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
CODE_05CF4D:
	LDY.b #$1E
	TYA
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM0A
CODE_05CF59:
	LDA.w SMW_NoBonusStarsText_Main,y
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	DEX
	DEX
	DEY
	DEY
	BPL.b CODE_05CF59
	LDA.w !RAM_SMW_Counter_LevelEndScoreTallyLo
	BEQ.b CODE_05CFA0
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	CLC
	ADC.w #$0006
	TAX
	LDY.b #$00
	JSR.w SMW_AdjustTimeBonusDisplay_Main
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	CLC
	ADC.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_05CF8A:
	LDA.l SMW_StripeImageUploadTable[$02].LowByte,x
	AND.w #$000F
	BNE.b CODE_05CFA0
	LDA.w #$38FC
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	INX
	INX
	CPX.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_05CF8A
CODE_05CFA0:
	SEP.b #$20			; A->8
	REP.b #$10			; XY->16
	LDA.w !RAM_SMW_Timer_DisplayBonusStars
	BEQ.b CODE_05CFDC
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	LDA.w !RAM_SMW_Counter_BonusStarsEarned
	AND.b #$0F
	ASL
	TAY
	LDA.w SMW_DisplayCourseClearTextBonusStars_DATA_05CD62,y
	STA.l SMW_StripeImageUploadTable[$0A].LowByte,x
	LDA.w SMW_DisplayCourseClearTextBonusStars_DATA_05CD62+$01,y
	STA.l SMW_StripeImageUploadTable[$0E].LowByte,x
	LDA.w !RAM_SMW_Counter_BonusStarsEarned
	AND.b #$F0
	LSR
	LSR
	LSR
	BEQ.b CODE_05CFDC
	TAY
	LDA.w SMW_DisplayCourseClearTextBonusStars_DATA_05CD62,y
	STA.l SMW_StripeImageUploadTable[$09].LowByte,x
	LDA.w SMW_DisplayCourseClearTextBonusStars_DATA_05CD62+$01,y
	STA.l SMW_StripeImageUploadTable[$0D].LowByte,x
CODE_05CFDC:
	REP.b #$20			; A->16
	SEP.b #$10			; XY->8
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	SEP.b #$30			; AXY->8
	PLB
Return:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_DisplayMessage(Address)
%SMW_RelocatableStringSlot(<Address>, MessageTables)
if !Define_SMW_RelocateStringTables == !FALSE
	%SMW_DisplayMessage_Tables()
endif
endmacro

; The tables themselves, so that the relocated build can emit them where it
; wants them -- see %SMW_UpdateLevelName_Tables in Banks/Bank04.asm.
macro SMW_DisplayMessage_Tables()
namespace SMW_DisplayMessage

; The VRAM word each line of the box is uploaded to -- the first half of a
; stripe image header, the second half being the same for every line.
LineVRAM:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	dw $6751,$2751,$E750,$A750
else
	dw $A751,$8751,$6751,$4751	;!
	dw $2751,$0751,$E750,$C750	;!
endif

; Which level each message slot is for, and which message it shows -- two
; tables the fragment describes, one per release.
if ver_is_japanese(!Define_Global_ROMToAssemble)
	%InsertVersionExclusiveFile(incsrc, ../SMW/strings/MessageSlots_, SMW_J.asm, )
else
	%InsertVersionExclusiveFile(incsrc, ../SMW/strings/MessageSlots_, SMW_U.asm, )
endif

; The 22 messages, back to back, each one file under strings/messages/. On
; the international builds a message is eight lines of up to 18 tiles from
; tables/fonts/standard.txt: the last tile of a line carries bit 7, and
; DisplayText fills the rest of an 18-tile row with spaces ($1F) once it has
; seen one, so a line shorter than 18 tiles costs only what it holds and a
; message is never fewer than eight bytes. A line of 18 tiles has its
; eighteenth carry the bit. The Japanese build reads a kana and, where one
; precedes it, its sound mark for every cell, so its files are raw bytes.
;
; The pointers above are offsets into this run rather than addresses (the
; base $0000 below), and RemoveTextBox bounds it: the messages may be
; reworded within the bytes the shipped ones occupy, and not past them.
MessageText:
	base $0000
if ver_is_japanese(!Define_Global_ROMToAssemble)
	%InsertVersionExclusiveFile(incsrc, ../SMW/strings/LevelMessageText_, SMW_J.asm, )
else
	%InsertVersionExclusiveFile(incsrc, ../SMW/strings/LevelMessageText_, SMW_U.asm, )
endif
	base off
namespace off
endmacro

;#############################################################################################################

macro ROUTINE_SMW_DisplayMessage(Address)
namespace SMW_DisplayMessage
%InsertMacroAtXPosition(<Address>)

RemoveTextBox:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	%InsertVersionExclusiveFile(incbin, ../SMW/images/menus/NoText_, SMW_J.bin, )
else
	%InsertVersionExclusiveFile(incbin, ../SMW/images/menus/NoText_, SMW_U.bin, )
endif

; Time when to show text after expanding/shrinking the Message Box window.
; 1st byte determines when to show the message. 2nd byte determines how fast
; to hide the message. Edited values can't be higher than the default hex
; values.
DATA_05B106:
	db $4C,$50

; Expanding/Shrinking size of Message Box window. Second digit of both bytes
; can't be other numbers than 0.
DATA_05B108:
	db $50,$00

; Expanding/Shrinking speed of Message Box window.
DATA_05B10A:
	db $04,$FC

Main:
;$05B10C
	; The subroutine that displays the message from a message box. It handles
	; the windowing HDMA, the stripe image upload, and things such as
	; teleporting to the overworld after the intro screen. $05B129: [9C 9F 0D]
	; Change to [EA EA EA] to prevent HDMA from getting disabled AFTER a
	; message box has been displayed. Use with $05B296. $05B15C: [8E] The Y
	; position on which to start the march to Yoshi's House after the intro
	; screen. To be used with $048F08. $05B15D: [8D 19 1F] ASM code that stores
	; the player's starting Y position to its RAM address, $1F19. Lunar Magic
	; changes this to [EA EA EA] if you move the Mario OW sprite around, thus
	; disabling the intro march (and its effects, such as storing '0' to the
	; amount of levels cleared). If you want to undo this effect, change it
	; back to [8D 19 1F]. $05B160: Side exit subroutine. It can be JSL'd to.
	; $05B189: [D0 CF] Change to [EA EA] to prevent the message that pops up in
	; the intro screen from exiting the level. (It will act exactly the same as
	; a message in any other level.) $05B21D: [39] Tile properties of the Layer
	; 3 tiles in message box messages in YXPCCCTT format. (Note: Lunar Magic
	; ASM hacks render this address unused.) $05B296: [8D] Change to [0C] to
	; prevent HDMA from getting disabled WHILE a message box is being
	; displayed. Use with $05B129.
	PHB
	PHK
	PLB
	LDX.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
	LDA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	CMP.w DATA_05B108,x
	BNE.b CODE_05B191
	TXA
	BEQ.b ExpandingMessage
	STZ.w !RAM_SMW_Misc_DisplayMessage
	STZ.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
	STZ.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings
	STZ.b !RAM_SMW_Mirror_BG3And4WindowMaskSettings
	STZ.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings
	STZ.w !RAM_SMW_Mirror_HDMAEnable				; Glitch: This STZ should be TRB and an LDA.b #$80 should be added before this line, or else displaying a message will disable other HDMA channels.
	LDA.b #$02
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings
	BRA.b CODE_05B18E						; Optimization: PLB : RTL would do the same thing in fewer cycles.

ExpandingMessage:
	LDA.w !RAM_SMW_Misc_IntroLevelFlag
	ORA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1
	BEQ.b CODE_05B16E
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_05B18E
	DEC.w !RAM_SMW_Timer_DisplaySpecialMessage
	BNE.b CODE_05B18E
	PLB
elseif ver_is_arcade(!Define_Global_ROMToAssemble)
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_05B16E
	DEC.w !RAM_SMW_Timer_DisplaySpecialMessage
	BNE.b CODE_05B16E
else
	LDA.w !RAM_SMW_Timer_DisplaySpecialMessage	;!!
	BEQ.b CODE_05B16E		;!!
	LDA.b !RAM_SMW_Counter_GlobalFrames	;!!
	AND.b #$03			;!!
	BNE.b CODE_05B18E		;!!
	DEC.w !RAM_SMW_Timer_DisplaySpecialMessage	;!!
	BNE.b CODE_05B18E		;!!
endif
	LDA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1	;!!
if ver_is_japanese(!Define_Global_ROMToAssemble)
	BEQ.b SetInitialYPosForIntroMarch
elseif ver_is_arcade(!Define_Global_ROMToAssemble)
	BEQ.b SetInitialYPosForIntroMarch
CODE_05B14F:
	PLB
else
	BEQ.b CODE_05B16E		;!!
CODE_05B14F:
	PLB				;!
endif
	INC.w !RAM_SMW_Overworld_CheckIfEventPassedFlag		;\ Optimization: Junk
	LDA.b #$01						;|
	STA.w !RAM_SMW_Flag_ActivateOverworldEvent		;/
	BRA.b ExitToOverworldForSwitchBlockEvent	;!

SetInitialYPosForIntroMarch:
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
	PLB				;!
endif
	LDA.b #$8E
	STA.w !RAM_SMW_Overworld_MarioYPosLo			;\ LM: Moving Mario on the overworld will cause LM to NOP this line to disable the goal walk.
								;| This has the side effect of the game not autosaving after the goal walk though!
								;| All FuSoYa has to do to fix this is put a JSL.l to the save routine one byte earlier, but he seemed reluctant to do that.
								;/ Alternatively, he could add a way to modify the goal walk, and I even provided the ASM to do so, but he wasn't interested.
ExitToOverworldNoEvent:
	STZ.w !RAM_SMW_Misc_IntroLevelFlag
	LDA.b #$00
ExitToOverworldForSwitchBlockEvent:
	STA.w !RAM_SMW_Misc_ExitLevelAction
	LDA.b #!Define_SMW_GameMode0B_FadeOutToOverworld
	STA.w !RAM_SMW_Misc_GameMode
	RTL

CODE_05B16E:
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #(!Joypad_Start>>8)|(!Joypad_Select>>8)|!Joypad_X|(!Joypad_Y>>8)|!Joypad_A|(!Joypad_B>>8)
	BEQ.b CODE_05B18E
	EOR.b !RAM_SMW_IO_ControllerPress1
	AND.b #(!Joypad_Start>>8)|(!Joypad_Select>>8)|(!Joypad_Y>>8)|(!Joypad_B>>8)
	BEQ.b CODE_05B186
	LDA.b !RAM_SMW_IO_ControllerHold2
	AND.b #!Joypad_X|!Joypad_A
	BEQ.b CODE_05B18E
	EOR.b !RAM_SMW_IO_ControllerPress2
	AND.b #!Joypad_X|!Joypad_A
	BNE.b CODE_05B18E
CODE_05B186:
if ver_is_japanese(!Define_Global_ROMToAssemble)
elseif ver_is_arcade(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1
	BNE.b CODE_05B14F
	LDA.w !RAM_SMW_Misc_IntroLevelFlag
	BNE.b SetInitialYPosForIntroMarch
else
	LDA.w !RAM_SMW_Misc_IntroLevelFlag	;!
	BNE.b SetInitialYPosForIntroMarch	;!
endif
	INC.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
CODE_05B18E:
	JMP.w CODE_05B299						; Optimization: PLB : RTL would do the same thing in 1 fewer byte.

CODE_05B191:
	CMP.w DATA_05B106,x
	BNE.b CODE_05B1A0
	TXA
	BEQ.b DisplayText
	JSR.w RemoveSwitchBlocks
	LDA.b #!Define_SMW_StripeImage_RemoveTextBox
	STA.b !RAM_SMW_Graphics_StripeImageToUpload
CODE_05B1A0:
	JMP.w CODE_05B250

DisplayText:
if !Define_SMW_RelocateStringTables == !TRUE
	; The slot tables have moved to the relocated strings bank: the search
	; runs there, over however many slots the tables hold, and hands the
	; slot back in X with the Yoshi-thanks case already picked -- seven
	; bytes, as the code it stands in for. Config/StringTableRelocation.asm.
	JSL.l SMW_RelocatedStrings_FindSlot
	BRA.b CODE_05B1C5
	NOP
CODE_05B1A5:
else
	LDX.b #$16							;\ LM: Inserts a JSL.l to a custom message text routine at $03BB90, as well as a JMP.w that skips the below code up to CODE_05B250
CODE_05B1A5:								;| This hijack mainly allows you to have 2 messages per overworld level and not be limited to only being able to edit the messages SMW originally used.
	LDY.b #$01							;|
	LDA.w MessageLevels,x						;|
endif
	BPL.b CODE_05B1AF						;|
	INY								;|
	AND.b #$7F							;|
CODE_05B1AF:								;|
	CPY.w !RAM_SMW_Misc_DisplayMessage				;|
	BNE.b CODE_05B1B9						;|
	CMP.w !RAM_SMW_Overworld_LevelNumberLo				;|
	BEQ.b CODE_05B1BC						;|
CODE_05B1B9:								;|
	DEX								;|
	BNE.b CODE_05B1A5						;|
CODE_05B1BC:								;|
	LDY.w !RAM_SMW_Misc_DisplayMessage				;|
	CPY.b #$03							;|
	BNE.b CODE_05B1C5						;|
	LDX.b #$18							;|
CODE_05B1C5:								;|
	CPX.b #$04							;|
	BCS.b CODE_05B1D1						;|
	INX								;|
	STX.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1			;|
	DEX								;|
	JSR.w DrawSwitchBlocks						;|
CODE_05B1D1:								;|
if !Define_SMW_RelocateStringTables == !TRUE
	; The pointers and the text have moved with the slots: the riding-Yoshi
	; pick, keyed on the last level slot wherever the grown table ends, and
	; the upload run from the relocated bank, coming back to the window's
	; own code -- ten bytes, as the code they stand in for. Everything from
	; CODE_05B1DB on is dead then, and stays in place unchanged.
	JSL.l SMW_RelocatedStrings_Upload
	JMP.w CODE_05B250
	NOP
	NOP
	NOP
else
	CPX.b #$16							;|
	BNE.b CODE_05B1DB						;|
	LDA.w !RAM_SMW_Player_RidingYoshiFlag				;|
	BEQ.b CODE_05B1DB						;|
	INX								;|
endif
CODE_05B1DB:								;|
	TXA								;|
	ASL								;|
	TAX								;|
	REP.b #$20							;|
	LDA.w MessagePointers,x						;|
	STA.b !RAM_SMW_Misc_ScratchRAM00				;|
	REP.b #$10							;|
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo			;|
	TAX								;|
if ver_is_japanese(!Define_Global_ROMToAssemble)			;|
	LDY.w #$0006							;|
CODE_05B1EF:								;|
	LDA.w LineVRAM,y						;|
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x			;|
	XBA								;|
	CLC								;|
	ADC.w #$0020							;|
	XBA								;|
	STA.l SMW_StripeImageUploadTable[$14].LowByte,x			;|
	LDA.w #$2300							;|
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x			;|
	STA.l SMW_StripeImageUploadTable[$15].LowByte,x			;|
else									;|
	LDY.w #$000E							;|
CODE_05B1EF:								;|
	LDA.w LineVRAM,y						;|
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x			;|
	LDA.w #$2300							;|
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x			;|
endif									;|
	PHY								;|
	SEP.b #$20							;|
	LDA.b #$12							;|
	STA.b !RAM_SMW_Misc_ScratchRAM02				;|
if ver_is_japanese(!Define_Global_ROMToAssemble)			;|
	LDY.b !RAM_SMW_Misc_ScratchRAM00				;|
CODE_05ADB2:								;|
	LDA.w MessageText,y						;|
	CMP.b #$59							;|
	BEQ.b CODE_05ADC0						;|
	CMP.b #$5B							;|
	BEQ.b CODE_05ADC0						;|
	DEY								;|
	LDA.b #$5D							;|
									;|
CODE_05ADC0:								;|
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x			;|
	INY								;|
	LDA.w MessageText,y						;|
	STA.l SMW_StripeImageUploadTable[$16].LowByte,x			;|
	LDA.b #$39							;|
	STA.l SMW_StripeImageUploadTable[$02].HighByte,x		;|
	STA.l SMW_StripeImageUploadTable[$16].HighByte,x		;|
	INX								;|
	INX								;|
	INY								;|
	DEC.b !RAM_SMW_Misc_ScratchRAM02				;|
	BNE.b CODE_05ADB2						;|
	STY.b !RAM_SMW_Misc_ScratchRAM00				;|
	REP.b #$20							;|
	TXA								;|
	CLC								;|
	ADC.w #$002C							;|
	TAX								;|
else									;|
	STZ.b !RAM_SMW_Misc_ScratchRAM03				;|
	LDY.b !RAM_SMW_Misc_ScratchRAM00				;|
CODE_05B208:								;|
	LDA.b #$1F							;|
	BIT.w !RAM_SMW_Misc_ScratchRAM03				;|
	BMI.b CODE_05B218						;|
	LDA.w MessageText,y						;|
	STA.w !RAM_SMW_Misc_ScratchRAM03				;|
	AND.b #$7F							;|
	INY								;|
CODE_05B218:								;|
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x			;|
	LDA.b #$39							;|
	STA.l SMW_StripeImageUploadTable[$02].HighByte,x		;|
	INX								;|
	INX								;|
	DEC.b !RAM_SMW_Misc_ScratchRAM02				;|
	BNE.b CODE_05B208						;|
	STY.b !RAM_SMW_Misc_ScratchRAM00				;|
	REP.b #$20							;|
	INX								;|
	INX								;|
	INX								;|
	INX								;|
endif									;|
	PLY								;|
	DEY								;|
	DEY								;|
	BPL.b CODE_05B1EF						;|
	LDA.w #$00FF							;|
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x			;|
	TXA								;|
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo			;|
	SEP.b #$30							;|
	LDA.b #$01							;|
	STA.w !RAM_SMW_Flag_DisableLayer3Scroll				;|
	STZ.b !RAM_SMW_Mirror_Layer3XPosLo				;|
	STZ.b !RAM_SMW_Mirror_Layer3XPosHi				;|
	STZ.b !RAM_SMW_Mirror_Layer3YPosLo				;|
	STZ.b !RAM_SMW_Mirror_Layer3YPosHi				;/
CODE_05B250:
	LDX.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
	LDA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	CLC
	ADC.w DATA_05B10A,x
	STA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	CLC
	ADC.b #$80
	XBA
	LDA.b #$80
	SEC
	SBC.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	REP.b #$20			; A->16
	LDX.b #$00
	LDY.b #$50
CODE_05B26D:
	CPX.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	BCC.b CODE_05B275
	LDA.w #$00FF
CODE_05B275:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$4C,y
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$9C,x
	INX
	INX
	DEY
	DEY
	BNE.b CODE_05B26D
	SEP.b #$20			; A->8
	LDA.b #$22
	STA.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings
	LDY.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1
	BEQ.b CODE_05B28E
	LDA.b #$20
CODE_05B28E:
	STA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings
	LDA.b #$22
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings
	LDA.b #($01<<!Define_SMW_WindowHDMAChannel)
	STA.w !RAM_SMW_Mirror_HDMAEnable				; Glitch: This STA should be TSB, or else displaying a message will disable other HDMA channels.
CODE_05B299:
	PLB
	RTL

; This is the 8x8 tilemap data for the sprites used on the switch palace
; messages (dotted and '!' block). The first byte in each is the tile, the
; second byte is the YXPPCCCT data.
SwitchBlockTileAndProperties:
.Yellow:
	db $AD,$35,$AD,$75,$AD,$B5,$AD,$F5
	db $A7,$35,$A7,$75,$B7,$35,$B7,$75

.Blue:
	db $BD,$37,$BD,$77,$BD,$B7,$BD,$F7
	db $A7,$37,$A7,$77,$B7,$37,$B7,$77

.Red:
	db $AD,$39,$AD,$79,$AD,$B9,$AD,$F9
	db $A7,$39,$A7,$79,$B7,$39,$B7,$79

.Green:
	db $BD,$3B,$BD,$7B,$BD,$BB,$BD,$FB
	db $A7,$3B,$A7,$7B,$B7,$3B,$B7,$7B

SwitchBlockXAndYDisp:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	db $38,$4B,$40,$4B,$38,$53,$40,$53
	db $60,$4B,$68,$4B,$60,$53,$68,$53
elseif ver_is_arcade(!Define_Global_ROMToAssemble)
	db $50,$57,$58,$57,$50,$5F,$58,$5F
	db $92,$57,$9A,$57,$92,$5F,$9A,$5F
else
	; Position of the blocks in the switch palace activation message. -- "50 4F
	; 58 4F 50 57 58 57 92 4F 9A 4F 92 57 9A 57" in the U version. -- "38 4B 40
	; 4B 38 53 40 53 60 4B 68 4B 60 53 68 53" in the J version.
	db $50,$4F,$58,$4F,$50,$57,$58,$57	;!
	db $92,$4F,$9A,$4F,$92,$57,$9A,$57	;!
endif

DrawSwitchBlocks:
;$05B2EB
	PHX
	TXA
	ASL
	ASL
	ASL
	ASL
	TAX
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	REP.b #$20			; A->16
	LDY.b #$1C
.Loop:
	LDA.w SwitchBlockTileAndProperties,x
	STA.w SMW_OAMBuffer[$00].Tile,y
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w SwitchBlockXAndYDisp,x
	STA.w SMW_OAMBuffer[$00].XDisp,y
	PLX
	INX
	INX
	INC.b !RAM_SMW_Misc_ScratchRAM00
	INC.b !RAM_SMW_Misc_ScratchRAM00
	DEY
	DEY
	DEY
	DEY
	BPL.b .Loop
	STZ.w SMW_UpperOAMBuffer[$00].Slot
	SEP.b #$20			; A->8
	PLX
	RTS

RemoveSwitchBlocks:
	LDY.b #$1C
	LDA.b #$F0
.Loop:
	STA.w SMW_OAMBuffer[$00].YDisp,y
	DEY
	DEY
	DEY
	DEY
	BPL.b .Loop
	RTS
namespace off
endmacro

macro DATATABLE_RT05_SMW_Map16Data(Address)
namespace SMW_Map16Data
%InsertMacroAtXPosition(<Address>)

; Tile data for all Layer 1 overworld tiles, #$00-#$BF (but BF doesn't show
; up in LM no matter what you set it to). 8 bytes per 16x16 tile = 2 bytes
; per 8x8 tile. (TTTTTTTT YXPCCCTT.) Order in which the pairs of bytes go
; inside a 16x16 tile: upper-left, bottom-left, upper-right, bottom-right.
OverworldLayer1:
	incbin "overworld/layer1/tiles.bin"
namespace off
endmacro

macro DATATABLE_RT03_SMW_BitTable(Address)
namespace SMW_BitTable
%InsertMacroAtXPosition(<Address>)

Bank05:
	db $80,$40,$20,$10,$08,$04,$02,$01
namespace off
endmacro

macro DATATABLE_RT04_SMW_BitTable(Address)
namespace SMW_BitTable
%InsertMacroAtXPosition(<Address>)

Unused_Bank05:
	dw $0080,$0040,$0020,$0010
	dw $0008,$0004,$0002,$0001
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_RT00_SMW_Backgrounds(Address)
namespace SMW_Backgrounds
%InsertMacroAtXPosition(<Address>)

; Layer 3 cage tiles placement, stripe image format.
Layer3:
.Cage:
	incbin "images/levels/layer3/cage.bin"
; Layer 3 crusher tiles placement, stripe image format.
.Smasher:
	incbin "images/levels/layer3/smasher.bin"
; Layer 3 tide tiles placement, stripe image format.
.Tide:
	incbin "images/levels/layer3/water.bin"
; Layer 3 ghost house fog tiles placement, stripe image format.
.Fog:
	incbin "images/levels/layer3/fog.bin"
; Layer 3 goldfish tiles placement, stripe image format.
.Fish:
	incbin "images/levels/layer3/fish.bin"
; Layer 3 castle windows tiles placement, stripe image format.
.Windows:
	incbin "images/levels/layer3/windows.bin"
; Layer 3 underground rocks tiles placement, stripe image format.
.Cave:
	incbin "images/levels/layer3/cave.bin"
namespace off
endmacro

macro ROUTINE_RT01_SMW_InitializeLevelLayer3(Address)
namespace SMW_InitializeLevelLayer3
%InsertMacroAtXPosition(<Address>)

; 24-bit layer 3 pointer. 3 pointer addresses per FG/BG tileset (tilesets
; 0-E). First pointer for low and high tides, second pointer for low tide
; only, third pointer for tileset specific layer 3 (although technically,
; all layer 3 settings here can be tileset specific).
Layer3ImagePtrs:
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 0 (Normal 1)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cage		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 1 (Castle 1)
	dl SMW_Backgrounds_Layer3_Smasher	;|
	dl SMW_Backgrounds_Layer3_Windows	;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 2 (Rope 1)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cage		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 3 (Underground 1)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cave		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 4 (Switch Palace 1)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cage		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 5 (Ghost House 1)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Fog		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 6 (Rope 2)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cage		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 7 (Normal 2)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cage		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 8 (Rope 3)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cage		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset 9 (Underground 2)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Fish		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset A (Switch Palace 2)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cage		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset B (Castle 2)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cage		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset C (Cloud/Forest)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cage		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset D (Ghost House 2)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Fog		;/
	dl SMW_Backgrounds_Layer3_Tide		;\ Tileset E (Underground 3)
	dl SMW_Backgrounds_Layer3_Tide		;|
	dl SMW_Backgrounds_Layer3_Cave		;/
namespace off
endmacro

macro ROUTINE_RT01_SMW_GameMode04_PrepareTitleScreen(Address)
namespace SMW_GameMode04_PrepareTitleScreen
%InsertMacroAtXPosition(<Address>)

TitlescreenLayer3:
if !Define_Global_ROMToAssemble&(!ROM_SMW_J|!ROM_SMW_E2|!ROM_SMASW_U|!ROM_SMASW_E) != $00
	%InsertVersionExclusiveFile(incbin, ../SMW/images/other/Titlescreen_, !ROMID.bin, )
else
	%InsertVersionExclusiveFile(incbin, ../SMW/images/other/Titlescreen_, SMW_U.bin, )
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_BufferScrollingTiles(Address)
namespace SMW_BufferScrollingTiles
%InsertMacroAtXPosition(<Address>)

Layer1_Main:
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	JSL.l SMW_ExecutePtr_Long

.PtrsLong058823:
	dl Layer1_HorizontalLevel		; 00 Horizontal level
	dl Layer1_HorizontalLevel		; 01 Horizontal layer 2 level (no layer 2 interaction)
	dl Layer1_HorizontalLevel		; 02 Horizontal layer 2 level (layer 2 interaction)
	dl Layer1_VerticalLevel			; 03 Do not use this level mode!
	dl Layer1_VerticalLevel			; 04 Do not use this level mode!
	dl Layer1_HorizontalLevel		; 05 Do not use this level mode!
	dl Layer1_HorizontalLevel		; 06 Do not use this level mode!
	dl Layer1_VerticalLevel			; 07 Vertical layer 2 level (no layer 2 interaction)/Overworld
	dl Layer1_VerticalLevel			; 08 Vertical layer 2 level (layer 2 interaction)
	dl Layer1_NoScroll			; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	dl Layer1_VerticalLevel			; 0A Vertical level
	dl Layer1_NoScroll			; 0B Horizontal boss level (Larry, Iggy)
	dl Layer1_HorizontalLevel		; 0C Horizontal dark BG level
	dl Layer1_VerticalLevel			; 0D Vertical dark BG level
	dl Layer1_HorizontalLevel		; 0E Horizontal level
	dl Layer1_HorizontalLevel		; 0F Horizontal layer 2 level (no layer 2 interaction)
	dl Layer1_NoScroll			; 10 Horizontal boss level (Bowser)
	dl Layer1_HorizontalLevel		; 11 Horizontal dark BG level
	dl Layer1_NoScroll			; 12 Cannot use this level mode!
	dl Layer1_NoScroll			; 13 Cannot use this level mode!
	dl Layer1_NoScroll			; 14 Cannot use this level mode!
	dl Layer1_NoScroll			; 15 Cannot use this level mode!
	dl Layer1_NoScroll			; 16 Cannot use this level mode!
	dl Layer1_NoScroll			; 17 Cannot use this level mode!
	dl Layer1_NoScroll			; 18 Cannot use this level mode!
	dl Layer1_NoScroll			; 19 Cannot use this level mode!
	dl Layer1_NoScroll			; 1A Cannot use this level mode!
	dl Layer1_NoScroll			; 1B Cannot use this level mode!
	dl Layer1_NoScroll			; 1C Cannot use this level mode!
	dl Layer1_NoScroll			; 1D Cannot use this level mode!
	dl Layer1_HorizontalLevel		; 1E Horizontal translucent level
	dl Layer1_HorizontalLevel		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

Layer2_Main:
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	JSL.l SMW_ExecutePtr_Long

.PtrsLong05888C:
	dl Layer2_NoScroll			; 00 Horizontal level
	dl Layer2_HorizontalLevel		; 01 Horizontal layer 2 level (no layer 2 interaction)
	dl Layer2_HorizontalLevel		; 02 Horizontal layer 2 level (layer 2 interaction)
	dl Layer2_HorizontalLevel		; 03 Do not use this level mode!
	dl Layer2_HorizontalLevel		; 04 Do not use this level mode!
	dl Layer2_VerticalLevel			; 05 Do not use this level mode!
	dl Layer2_VerticalLevel			; 06 Do not use this level mode!
	dl Layer2_VerticalLevel			; 07 Vertical layer 2 level (no layer 2 interaction)/Overworld
	dl Layer2_VerticalLevel			; 08 Vertical layer 2 level (layer 2 interaction)
	dl Layer2_NoScroll			; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	dl Layer2_NoScroll			; 0A Vertical level
	dl Layer2_NoScroll			; 0B Horizontal boss level (Larry, Iggy)
	dl Layer2_NoScroll			; 0C Horizontal dark BG level
	dl Layer2_NoScroll			; 0D Vertical dark BG level
	dl Layer2_NoScroll			; 0E Horizontal level
	dl Layer2_HorizontalLevel		; 0F Horizontal layer 2 level (no layer 2 interaction)
	dl Layer2_NoScroll			; 10 Horizontal boss level (Bowser)
	dl Layer2_NoScroll			; 11 Horizontal dark BG level
	dl Layer2_NoScroll			; 12 Cannot use this level mode!
	dl Layer2_NoScroll			; 13 Cannot use this level mode!
	dl Layer2_NoScroll			; 14 Cannot use this level mode!
	dl Layer2_NoScroll			; 15 Cannot use this level mode!
	dl Layer2_NoScroll			; 16 Cannot use this level mode!
	dl Layer2_NoScroll			; 17 Cannot use this level mode!
	dl Layer2_NoScroll			; 18 Cannot use this level mode!
	dl Layer2_NoScroll			; 19 Cannot use this level mode!
	dl Layer2_NoScroll			; 1A Cannot use this level mode!
	dl Layer2_NoScroll			; 1B Cannot use this level mode!
	dl Layer2_NoScroll			; 1C Cannot use this level mode!
	dl Layer2_NoScroll			; 1D Cannot use this level mode!
	dl Layer2_NoScroll			; 1E Horizontal translucent level
	dl Layer2_HorizontalLevel		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

Layer1_Init:
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	JSL.l SMW_ExecutePtr_Long

.PtrsLong0588F5:
	dl Layer1_HorizontalLevel		; 00 Horizontal level
	dl Layer1_HorizontalLevel		; 01 Horizontal layer 2 level (no layer 2 interaction)
	dl Layer1_HorizontalLevel		; 02 Horizontal layer 2 level (layer 2 interaction)
	dl Layer1_VerticalLevel			; 03 Do not use this level mode!
	dl Layer1_VerticalLevel			; 04 Do not use this level mode!
	dl Layer1_HorizontalLevel		; 05 Do not use this level mode!
	dl Layer1_HorizontalLevel		; 06 Do not use this level mode!
	dl Layer1_VerticalLevel			; 07 Vertical layer 2 level (no layer 2 interaction)/Overworld
	dl Layer1_VerticalLevel			; 08 Vertical layer 2 level (layer 2 interaction)
	dl Layer1_NoScroll			; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	dl Layer1_VerticalLevel			; 0A Vertical level
	dl Layer1_NoScroll			; 0B Horizontal boss level (Larry, Iggy)
	dl Layer1_HorizontalLevel		; 0C Horizontal dark BG level
	dl Layer1_VerticalLevel			; 0D Vertical dark BG level
	dl Layer1_HorizontalLevel		; 0E Horizontal level
	dl Layer1_HorizontalLevel		; 0F Horizontal layer 2 level (no layer 2 interaction)
	dl Layer1_NoScroll			; 10 Horizontal boss level (Bowser)
	dl Layer1_HorizontalLevel		; 11 Horizontal dark BG level
	dl Layer1_NoScroll			; 12 Cannot use this level mode!
	dl Layer1_NoScroll			; 13 Cannot use this level mode!
	dl Layer1_NoScroll			; 14 Cannot use this level mode!
	dl Layer1_NoScroll			; 15 Cannot use this level mode!
	dl Layer1_NoScroll			; 16 Cannot use this level mode!
	dl Layer1_NoScroll			; 17 Cannot use this level mode!
	dl Layer1_NoScroll			; 18 Cannot use this level mode!
	dl Layer1_NoScroll			; 19 Cannot use this level mode!
	dl Layer1_NoScroll			; 1A Cannot use this level mode!
	dl Layer1_NoScroll			; 1B Cannot use this level mode!
	dl Layer1_NoScroll			; 1C Cannot use this level mode!
	dl Layer1_NoScroll			; 1D Cannot use this level mode!
	dl Layer1_HorizontalLevel		; 1E Horizontal translucent level
	dl Layer1_HorizontalLevel		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

Layer2_Init:
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	JSL.l SMW_ExecutePtr_Long

.PtrsLong05895E:
	dl Layer2_Background			; 00 Horizontal level
	dl Layer2_HorizontalLevel		; 01 Horizontal layer 2 level (no layer 2 interaction)
	dl Layer2_HorizontalLevel		; 02 Horizontal layer 2 level (layer 2 interaction)
	dl Layer2_HorizontalLevel		; 03 Do not use this level mode!
	dl Layer2_HorizontalLevel		; 04 Do not use this level mode!
	dl Layer2_VerticalLevel			; 05 Do not use this level mode!
	dl Layer2_VerticalLevel			; 06 Do not use this level mode!
	dl Layer2_VerticalLevel			; 07 Vertical layer 2 level (no layer 2 interaction)/Overworld
	dl Layer2_VerticalLevel			; 08 Vertical layer 2 level (layer 2 interaction)
	dl Layer2_NoScroll			; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	dl Layer2_Background			; 0A Vertical level
	dl Layer2_NoScroll			; 0B Horizontal boss level (Larry, Iggy)
	dl Layer2_Background			; 0C Horizontal dark BG level
	dl Layer2_Background			; 0D Vertical dark BG level
	dl Layer2_Background			; 0E Horizontal level
	dl Layer2_HorizontalLevel		; 0F Horizontal layer 2 level (no layer 2 interaction)
	dl Layer2_NoScroll			; 10 Horizontal boss level (Bowser)
	dl Layer2_Background			; 11 Horizontal dark BG level
	dl Layer2_NoScroll			; 12 Cannot use this level mode!
	dl Layer2_NoScroll			; 13 Cannot use this level mode!
	dl Layer2_NoScroll			; 14 Cannot use this level mode!
	dl Layer2_NoScroll			; 15 Cannot use this level mode!
	dl Layer2_NoScroll			; 16 Cannot use this level mode!
	dl Layer2_NoScroll			; 17 Cannot use this level mode!
	dl Layer2_NoScroll			; 18 Cannot use this level mode!
	dl Layer2_NoScroll			; 19 Cannot use this level mode!
	dl Layer2_NoScroll			; 1A Cannot use this level mode!
	dl Layer2_NoScroll			; 1B Cannot use this level mode!
	dl Layer2_NoScroll			; 1C Cannot use this level mode!
	dl Layer2_NoScroll			; 1D Cannot use this level mode!
	dl Layer2_Background			; 1E Horizontal translucent level
	dl Layer2_HorizontalLevel		; 1F Horizontal layer 2 translucent level (layer 2 interaction)
namespace off
endmacro

macro ROUTINE_RT01_SMW_BufferScrollingTiles(Address)
namespace SMW_BufferScrollingTiles
%InsertMacroAtXPosition(<Address>)

Layer1:
.HorizontalLevel:
	PHP
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	AND.w #$00FF
	ASL
	TAX
	SEP.b #$20			; A->8
	LDA.l SMW_LevelDataLayoutTables_Layer1LoPtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.l SMW_LevelDataLayoutTables_Layer1LoPtrs+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.l SMW_LevelDataLayoutTables_Layer1HiPtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.l SMW_LevelDataLayoutTables_Layer1HiPtrs+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b #SMW_LevelDataLayoutTables_Layer1LoPtrs>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	TAX
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	AND.b #$0F
	ASL
	STA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	LDY.w #$0020
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	AND.b #$10
	BEQ.b .CODE_058A10
	LDY.w #$0024
.CODE_058A10:
	TYA
	STA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	AND.w #$01F0
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	SEP.b #$20			; A->8
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataBank
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataBank
	SEP.b #$10			; XY->8
	LDY.b #SMW_Map16Data_Main>>16
	LDA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad
	CMP.b #$10
	BMI.b .CODE_058A47
	LDY.b #SMW_Map16Data_OverworldLayer1>>16
.CODE_058A47:
	STY.b !RAM_SMW_Misc_ScratchRAM0C
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	AND.w #$000F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDX.w #$0000
.CODE_058A55:
	LDY.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	TAY
if !Define_SMW_CustomTiles == !TRUE
	JSL.l SMW_CustomTiles_Definition		;> The definition of a tile on any page (Config/CustomTiles.asm)
	NOP
else
	LDA.w !RAM_SMW_Pointer_Map16Tiles,y
	STA.b !RAM_SMW_Misc_ScratchRAM0A
endif
	LDY.w #$0000
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer1TilesToUploadBuffer,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer1TilesToUploadBuffer+$02,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer1TilesToUploadBuffer+$80,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer1TilesToUploadBuffer+$82,x
	INX
	INX
	INX
	INX
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	CLC
	ADC.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.w #$01B0
	BCC.b .CODE_058A55
	PLP
.NoScroll:
	RTL

.VerticalLevel:
	PHP
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	AND.w #$00FF
	ASL
	TAX
	SEP.b #$20			; A->8
	LDA.l SMW_LevelDataLayoutTables_Layer1LoPtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.l SMW_LevelDataLayoutTables_Layer1LoPtrs+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.l SMW_LevelDataLayoutTables_Layer1HiPtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.l SMW_LevelDataLayoutTables_Layer1HiPtrs+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b #SMW_LevelDataLayoutTables_Layer1LoPtrs>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	TAX
	LDY.w #$0020
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	AND.b #$10
	BEQ.b .CODE_058AD5
	LDY.w #$0028
.CODE_058AD5:
	TYA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	LSR
	LSR
	AND.b #$03
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	AND.b #$03
	ASL
	ASL
	ASL
	ASL
	ASL
	ASL
	STA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	AND.w #$01F0
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	SEP.b #$20			; A->8
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataBank
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataBank
	SEP.b #$10			; XY->8
	LDY.b #SMW_Map16Data_Main>>16
	LDA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad
	CMP.b #$10
	BMI.b .CODE_058B23
	LDY.b #SMW_Map16Data_OverworldLayer1>>16
.CODE_058B23:
	STY.b !RAM_SMW_Misc_ScratchRAM0C
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	AND.w #$000F
	ASL
	ASL
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDX.w #$0000
.CODE_058B35:
	LDY.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	TAY
if !Define_SMW_CustomTiles == !TRUE
	JSL.l SMW_CustomTiles_Definition		;> The definition of a tile on any page (Config/CustomTiles.asm)
	NOP
else
	LDA.w !RAM_SMW_Pointer_Map16Tiles,y
	STA.b !RAM_SMW_Misc_ScratchRAM0A
endif
	LDY.w #$0000
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer1TilesToUploadBuffer,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer1TilesToUploadBuffer+$80,x
	INX
	INX
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer1TilesToUploadBuffer,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer1TilesToUploadBuffer+$80,x
	INX
	INX
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	TAY
	CLC
	ADC.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
	AND.w #$000F
	BNE.b .CODE_058B84
	TYA
	AND.w #$FFF0
	CLC
	ADC.w #$0100
	STA.b !RAM_SMW_Misc_ScratchRAM08
.CODE_058B84:
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	AND.w #$010F
	BNE.b .CODE_058B35
	PLP
	RTL

Layer2:
.HorizontalLevel:
	PHP
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	AND.w #$00FF
	ASL
	TAX
	SEP.b #$20			; A->8
	LDY.w #$0000
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting
	CMP.b #$03
	BNE.b .CODE_058BA7
	LDY.w #$1000
.CODE_058BA7:
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_Layer2LoPtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.l SMW_LevelDataLayoutTables_Layer2LoPtrs+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.l SMW_LevelDataLayoutTables_Layer2HiPtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.l SMW_LevelDataLayoutTables_Layer2HiPtrs+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b #SMW_LevelDataLayoutTables_Layer2LoPtrs>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_Camera_Layer2ScrollingDirection
	TAX
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo,x
	AND.b #$0F
	ASL
	STA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	LDY.w #$0030
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo,x
	AND.b #$10
	BEQ.b .CODE_058BDE
	LDY.w #$0034
.CODE_058BDE:
	TYA
	STA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo,x
	AND.w #$01F0
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	SEP.b #$20			; A->8
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataBank
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataBank
	SEP.b #$10			; XY->8
	LDY.b #SMW_Map16Data_Main>>16
	LDA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad
	CMP.b #$10
	BMI.b .CODE_058C15
	LDY.b #SMW_Map16Data_OverworldLayer1>>16
.CODE_058C15:
	STY.b !RAM_SMW_Misc_ScratchRAM0C
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo,x
	AND.w #$000F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDX.w #$0000
.CODE_058C23:
	LDY.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	TAY
if !Define_SMW_CustomTiles == !TRUE
	JSL.l SMW_CustomTiles_Definition		;> The definition of a tile on any page (Config/CustomTiles.asm)
	NOP
else
	LDA.w !RAM_SMW_Pointer_Map16Tiles,y
	STA.b !RAM_SMW_Misc_ScratchRAM0A
endif
	LDY.w #$0000
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$02,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$80,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$82,x
	INX
	INX
	INX
	INX
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	CLC
	ADC.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.w #$01B0
	BCC.b .CODE_058C23
	PLP
.NoScroll:
	RTL

.VerticalLevel:
	PHP
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	AND.w #$00FF
	ASL
	TAX
	SEP.b #$20			; A->8
	LDY.w #$0000
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting
	CMP.b #$03
	BNE.b .CODE_058C8B
	LDY.w #$1000
.CODE_058C8B:
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_Layer2LoPtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.l SMW_LevelDataLayoutTables_Layer2LoPtrs+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.l SMW_LevelDataLayoutTables_Layer2HiPtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.l SMW_LevelDataLayoutTables_Layer2HiPtrs+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b #SMW_LevelDataLayoutTables_Layer2LoPtrs>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_Camera_Layer2ScrollingDirection
	TAX
	LDY.w #$0030
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo,x
	AND.b #$10
	BEQ.b .CODE_058CBA
	LDY.w #$0038
.CODE_058CBA:
	TYA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo,x
	LSR
	LSR
	AND.b #$03
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo,x
	AND.b #$03
	ASL
	ASL
	ASL
	ASL
	ASL
	ASL
	STA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo,x
	AND.w #$01F0
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	SEP.b #$20			; A->8
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataBank
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataBank
	SEP.b #$10			; XY->8
	LDY.b #SMW_Map16Data_Main>>16
	LDA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad
	CMP.b #$10
	BMI.b .CODE_058D08
	LDY.b #SMW_Map16Data_OverworldLayer1>>16
.CODE_058D08:
	STY.b !RAM_SMW_Misc_ScratchRAM0C
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo,x
	AND.w #$000F
	ASL
	ASL
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDX.w #$0000
.CODE_058D1A:
	LDY.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	TAY
if !Define_SMW_CustomTiles == !TRUE
	JSL.l SMW_CustomTiles_Definition		;> The definition of a tile on any page (Config/CustomTiles.asm)
	NOP
else
	LDA.w !RAM_SMW_Pointer_Map16Tiles,y
	STA.b !RAM_SMW_Misc_ScratchRAM0A
endif
	LDY.w #$0000
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$80,x
	INX
	INX
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$80,x
	INX
	INX
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	TAY
	CLC
	ADC.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
	AND.w #$000F
	BNE.b .CODE_058D71
	TYA
	AND.w #$FFF0
	CLC
	ADC.w #$0100
	STA.b !RAM_SMW_Misc_ScratchRAM08
.CODE_058D71:
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	AND.w #$010F
	BNE.b .CODE_058D1A
	PLP
	RTL

.Background:
	PHP
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject
	AND.b #$0F
	ASL
	STA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	LDY.b #$30
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject
	AND.b #$10
	BEQ.b .CODE_058D91
	LDY.b #$34
.CODE_058D91:
	TYA
	STA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	REP.b #$20			; A->16
	LDA.w #!RAM_SMW_Blocks_Layer2TilesLo
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	LDA.w #!RAM_SMW_Blocks_Layer2TilesHi
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	LDA.w #SMW_Map16Data_Backgrounds
#LM000Hijack_CustomBGMap16:
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject
	AND.w #$00F0
	BEQ.b .CODE_058DBE
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	CLC
	ADC.w #$01B0
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	LDA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	CLC
	ADC.w #$01B0
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
.CODE_058DBE:
	SEP.b #$20			; A->8
	LDA.b #!RAM_SMW_Blocks_Layer2TilesLo>>16
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataBank
	LDA.b #!RAM_SMW_Blocks_Layer2TilesHi>>16
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataBank
	LDY.b #SMW_Map16Data_Backgrounds>>16
	STY.b !RAM_SMW_Misc_ScratchRAM0C
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject
	AND.w #$000F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDX.w #$0000
.CODE_058DD9:
	LDY.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	ASL
	ASL
	TAY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$02,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$80,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.w !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$82,x
	INX
	INX
	INX
	INX
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	CLC
	ADC.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.w #$01B0
	BCC.b .CODE_058DD9
	PLP
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeLevelLayer1And2Tilemaps(Address)
namespace SMW_InitializeLevelLayer1And2Tilemaps
%InsertMacroAtXPosition(<Address>)

if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
DATA_35809E:
	%StripeImageHeader(.Layer1, $00, $00, 0, $1FFF, 1)
	db $FA,$18
.Layer1End
	%StripeImageHeader(.Layer2, $00, $00, 0, $1FFF, 2)
	db $FA,$18
.Layer2End
	db $FF
endif

Main:
	PHP				;!
	SEP.b #$20			;! A->8
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDX.b #$0C
-:
	LDA.l DATA_35809E,x
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	DEX
	BPL.b -
	STZ.b !RAM_SMW_Graphics_StripeImageToUpload
	JSL.l SMW_LoadStripeImage_Main
	LDA.b #$80
	STA.w !REGISTER_Mode7TilemapSettings
endif
	STZ.w !RAM_SMW_Unknown_7E1928	; Zero a byte in the middle of the RAM table for the level header
	REP.b #$30			; AXY->16
	LDA.w #$FFFF
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo	; $4D to $50 = #$FF
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateRightDownLo
	JSR.w SMW_CalculateRowOrColumnOfTilemapToUpdate_Main	; -> here
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo
	STA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo
	LDA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo
	STA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateRightDownLo
	LDA.w #$0202
	STA.b !RAM_SMW_Camera_Layer1ScrollingDirection
CODE_0580BD:
	REP.b #$30			; AXY->16
	JSL.l SMW_BufferScrollingTiles_Layer1_Init
	JSL.l SMW_BufferScrollingTiles_Layer2_Init
	JSL.l SMW_UploadLevelLayer1And2Tilemaps_Main
	REP.b #$30			; AXY->16
	INC.b !RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo
	INC.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateRightDownLo
	SEP.b #$30			; AXY->8
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo
	; Handles pipe colours in horizontal levels. Change to: EA - Pipes change
	; colour every half-screen. EAEA - Every 1/4 screen (every 2 pipes). EAEAEA
	; - Every pipe. EAEA0A - Every half pipe (every pipe is 2-toned). EAA9xx -
	; All pipes are same colour (xx=00, 01, 02 or 04). Must be combined with
	; $05:87A4. Warning: Does not have any effect on ROMs LM 1.7 has been used
	; on.
	LSR
	LSR
	LSR
	REP.b #$30			; AXY->16
	AND.w #$0006
	TAX
	LDA.w #$0133
	ASL
	TAY
	LDA.w #$0007
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l SMW_CalculateRowOrColumnOfTilemapToUpdate_PipeMap16Ptrs,x
CODE_0580EC:
	STA.w !RAM_SMW_Pointer_Map16Tiles,y
	INY
	INY
	CLC
	ADC.w #$0008
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_0580EC
	SEP.b #$20			; A->8
	INC.w !RAM_SMW_Unknown_7E1928
	LDA.w !RAM_SMW_Unknown_7E1928
	CMP.b #$20
	BNE.b CODE_0580BD
	LDA.w !RAM_SMW_Mirror_MainScreenLayers
	STA.w !REGISTER_MainScreenLayers	; Background and Object Enable
	STA.w !REGISTER_MainScreenWindowMask	; Window Mask Designation for Main Screen
	LDA.w !RAM_SMW_Mirror_SubScreenLayers
	STA.w !REGISTER_SubScreenLayers	; Sub Screen Designation
	STA.w !REGISTER_SubScreenWindowMask	; Window Mask Designation for Sub Screen
	REP.b #$20			; A->16
	LDA.w #$FFFF
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateRightDownLo
	STA.b !RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpLo
	STA.b !RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateRightDownLo
	PLP
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckIfLevelTilemapsNeedScrollUpdate(Address)
namespace SMW_CheckIfLevelTilemapsNeedScrollUpdate
%InsertMacroAtXPosition(<Address>)

Main:
	PHP
	REP.b #$30			; AXY->16
	JSR.w SMW_CalculateRowOrColumnOfTilemapToUpdate_Main
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.b #$01
	BNE.b CODE_058713
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	AND.w #$00FF
	TAX
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	AND.w #$FFF0
	CMP.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo,x
	BEQ.b CODE_058737
	JMP.w CODE_058724

CODE_058713:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	AND.w #$00FF
	TAX
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	AND.w #$FFF0
	CMP.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo,x
	BEQ.b CODE_058737
CODE_058724:
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo,x
	TXA
	EOR.w #$0002
	TAX
	LDA.w #$FFFF
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo,x
	JSL.l SMW_BufferScrollingTiles_Layer1_Main
	JMP.w CODE_058774

CODE_058737:
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.b #$02
	BNE.b CODE_058753
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Camera_Layer2ScrollingDirection
	AND.w #$00FF
	TAX
	LDA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	AND.w #$FFF0
	CMP.b !RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpLo,x
	BEQ.b CODE_058774
	JMP.w CODE_058764

CODE_058753:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Camera_Layer2ScrollingDirection
	AND.w #$00FF
	TAX
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	AND.w #$FFF0
	CMP.b !RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpLo,x
	BEQ.b CODE_058774
CODE_058764:
	STA.b !RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpLo,x
	TXA
	EOR.w #$0002
	TAX
	LDA.w #$FFFF
	STA.b !RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpLo,x
	JSL.l SMW_BufferScrollingTiles_Layer2_Main
CODE_058774:
	PLP
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CalculateRowOrColumnOfTilemapToUpdate(Address)
namespace SMW_CalculateRowOrColumnOfTilemapToUpdate
%InsertMacroAtXPosition(<Address>)

PipeMap16Ptrs:
	dw SMW_Map16Data_VariableColorPipes
	dw SMW_Map16Data_GreenPipes
	dw SMW_Map16Data_YellowPipes
	dw SMW_Map16Data_PurplePipes

Main:
	PHP
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.b #$01
	BNE.b VerticalLevel_Layer1
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	; Load "Xpos of Screen Boundary"
	LSR
	LSR				; |Multiply by 16
	LSR
	LSR
	TAY
	SEC
	SBC.w #$0008			; /Subtract 8
	STA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo	; Store to $45 (Seems to be Scratch RAM)
	TYA				; Get back the multiplied XPos
	CLC
	ADC.w #$0017			; Add $17
	STA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo	; Store to $47 (Seems to be Scratch RAM)
	SEP.b #$30							;\ LM: Skips past this chunk of code.
	LDA.b !RAM_SMW_Camera_Layer1ScrollingDirection			;| Todo: Probably has something to do with the VRAM patch, but I'm not sure.
	TAX								;|
	LDA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x		;|
	; Same as $05:80D5. Both must be changed to the same values.
	LSR								;|
	LSR								;|
	LSR								;|
	REP.b #$30							;|
	AND.w #$0006							;|
	TAX								;|
	LDA.w #$0133							;| Note: Start of the pipe map16 tiles.
	ASL								;|
	TAY								;|
	LDA.w #$0007							;|
	STA.b !RAM_SMW_Misc_ScratchRAM00				;|
	LDA.l PipeMap16Ptrs,x						;|
CODE_0587BB:								;|
	STA.w !RAM_SMW_Pointer_Map16Tiles,y				;|
	INY								;|
	INY								;|
	CLC								;|
	ADC.w #$0008							;|
	DEC.b !RAM_SMW_Misc_ScratchRAM00				;|
	BPL.b CODE_0587BB						;/
	JMP.w CODE_0587E1

VerticalLevel_Layer1:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LSR
	LSR
	LSR
	LSR
	TAY
	SEC
	SBC.w #$0008
	STA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo
	TYA
	CLC
	ADC.w #$0017
	STA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo
CODE_0587E1:
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	; Load the vertical level flag
	AND.b #$02			; \if bit 1 is set, process based on that
	BNE.b VerticalLevel_Layer2
	REP.b #$20			; A->16, Not a vertical level
	LDA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo	; \Y = L2XPos * 16
	LSR
	LSR
	LSR
	LSR
	TAY
	SEC
	SBC.w #$0008
	STA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo
	TYA
	CLC
	ADC.w #$0017
	STA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateRightDownLo
	JMP.w CODE_058818

VerticalLevel_Layer2:
	REP.b #$20			; \ A->16, A = Y = !4*16 (?)
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	LSR
	LSR
	LSR
	LSR
	TAY
	SEC
	SBC.w #$0008			; |Subtract x08 and store in $49
	STA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo
	TYA
	CLC				; |"Undo", add x17 and store in $4B
	ADC.w #$0017
	STA.b !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateRightDownLo
CODE_058818:
	PLP
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeScrollSprites(Address)
namespace SMW_InitializeScrollSprites
%InsertMacroAtXPosition(<Address>)

Main:
	PHB
	PHK
	PLB
	STZ.w !RAM_SMW_ScrollSpr_LayerIndex
	JSR.w CODE_05BCE9
	LDA.b #$04
	STA.w !RAM_SMW_ScrollSpr_LayerIndex
	JSR.w CODE_05BD0E
	PLB
	RTL

CODE_05BCE9:
	LDA.w !RAM_SMW_L1ScrollSpr_SpriteID
	JSL.l SMW_ExecutePtr_Absolute

; Pointers to the scroll sprite init routines for Layer 1 scrolling.
Ptrs05BCF0:
	dw SMW_NorSpr0E7_SpecialAutoScroll_Main	; 00 - Auto-Scroll, Unused?
	dw SMW_NorSpr0E8_SpecialAutoScroll_Main	; 01 - Auto-Scroll
	dw SMW_NorSpr0E9_Layer2Smash_Main	; 02 - Layer 2 Smash
	dw SMW_NorSpr0EA_Layer2Scroll_Main	; 03 - Layer 2 Scroll
	dw SMW_NorSpr0EB_UnusedSprite_Main	; 04 - Unused
	dw SMW_NorSpr0EC_UnusedSprite_Main	; 05 - Unused
	dw SMW_NorSpr0ED_Layer2Falls_Main	; 06 - Layer 2 Falls
	dw SMW_NorSpr0EE_UnusedSprite_Main	; 07 - Unused
	dw SMW_NorSpr0EF_Layer2ScrollSOrL_Main	; 08 - Layer 2 Scroll
	dw SMW_NorSpr0F0_UnusedSprite_Main	; 09 - Unused
	dw SMW_NorSpr0F1_UnusedSprite_Main	; 0A - Unused
	dw SMW_NorSpr0F2_Layer2OnOffControlled_Main	; 0B - Layer 2 On/Off Switch controlled
	dw SMW_NorSpr0F3_RegularAutoScroll_Main	; 0C - Auto-Scroll level
	dw SMW_NorSpr0F4_FastBGScroll_Main	; 0D - Fast BG scroll
	dw SMW_NorSpr0F5_Layer2ScrollWhenTouched_Main	; 0E - Layer 2 sink/rise

CODE_05BD0E:
	LDA.w !RAM_SMW_L2ScrollSpr_SpriteID
	BEQ.b Return05BD35
	JSL.l SMW_ExecutePtr_Absolute

; Pointers to the scroll sprite init routines for Layer 2 scrolling.
Ptrs05BD17:
	dw SMW_NorSpr0E7_SpecialAutoScroll_Layer2
	dw SMW_NorSpr0E7_SpecialAutoScroll_Layer2
	dw SMW_ProcessScrollSprites_Return
	dw SMW_NorSpr0EA_Layer2Scroll_CODE_05BF20
	dw SMW_NorSpr0EB_UnusedSprite_ADDR_05BDF0
	dw SMW_ProcessScrollSprites_Return
	dw SMW_ProcessScrollSprites_Return
	dw Return05BD35
	dw SMW_NorSpr0EF_Layer2ScrollSOrL_CODE_05BEC6
	dw SMW_NorSpr0F4_FastBGScroll_CODE_05C022
	dw SMW_NorSpr0F1_UnusedSprite_ADDR_05BE4D
	dw SMW_ProcessScrollSprites_Return
	dw SMW_ProcessScrollSprites_Return
	dw SMW_ProcessScrollSprites_Return
	dw SMW_ProcessScrollSprites_Return

Return05BD35:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_InitializeScrollSprites_Return05BD35, SMW_NorSpr0EE_UnusedSprite_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_HandleScrollSpriteAndLayer3Scrolling(Address)
namespace SMW_HandleScrollSpriteAndLayer3Scrolling
%InsertMacroAtXPosition(<Address>)

Main:
	PHB
	PHK
	PLB
	JSR.w SMW_ProcessScrollSprites_Layer1
	JSR.w SMW_ProcessScrollSprites_Layer2
	JSR.w SMW_ScrollSecondInteractiveLayer_Sub
	LDA.w !RAM_SMW_Misc_Layer1XPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w !RAM_SMW_Misc_Layer1XDisp
	STA.w !RAM_SMW_Misc_Layer1XDisp
	LDA.w !RAM_SMW_Misc_Layer1YPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.w !RAM_SMW_Misc_Layer1YDisp
	STA.w !RAM_SMW_Misc_Layer1YDisp
	LDA.w !RAM_SMW_Misc_Layer2XPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	LDY.w !RAM_SMW_L2ScrollSpr_SpriteID
	DEY
	BNE.b CODE_05BC33
	TYA
CODE_05BC33:
	STA.w !RAM_SMW_Misc_Layer2XDisp
	LDA.w !RAM_SMW_Misc_Layer2YPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	STA.w !RAM_SMW_Misc_Layer2YDisp
	LDA.w !RAM_SMW_Flag_DisableLayer3Scroll
	BNE.b CODE_05BC47
	JSR.w SMW_ScrollLayer3_Main
CODE_05BC47:
	PLB
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_ScrollLayer3(Address)
namespace SMW_ScrollLayer3
%InsertMacroAtXPosition(<Address>)

TideYAcceleration:
	db $FF,$01

TideMaxYSpeed:
	db $FC,$04

TideMaxYPos:
	db $30,$A0

Main:
if !Define_SMW_Layer3Settings == !TRUE
	JML.l SMW_Layer3Settings_Scroll	;\ A level that places Layer 3 itself does
	NOP				;/ so here (Config/Layer3Settings.asm)
else
	LDA.w !RAM_SMW_Flag_Layer3TideLevel
	BEQ.b CODE_05C414
endif
	JMP.w Layer3Tide

CODE_05C414:
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_Misc_LevelTilesetSetting
	CPY.b #$01
	BEQ.b CODE_05C421
	CPY.b #$03
	BNE.b CODE_05C428
CODE_05C421:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LSR
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	BRA.b CODE_05C491

CODE_05C428:
	LDY.w !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_05C48D
	LDA.w !RAM_SMW_Flag_Layer3VerticalScrollDirection
	AND.w #$00FF
	TAY
	LDA.w DATA_05CBEB
	AND.w #$00FF
	ASL
	ASL
	ASL
	ASL
	CPY.b #$01
	BEQ.b CODE_05C446
	EOR.w #$FFFF
	INC
CODE_05C446:
	LDY.b #$00
	CMP.w !RAM_SMW_Misc_Layer3XSpeedLo
	BEQ.b CODE_05C45B
	BPL.b CODE_05C451
	LDY.b #$02
CODE_05C451:
	LDA.w !RAM_SMW_Misc_Layer3XSpeedLo
	CLC
	ADC.w DATA_05CBBB,y
	STA.w !RAM_SMW_Misc_Layer3XSpeedLo
CODE_05C45B:
	LDA.w !RAM_SMW_Misc_Layer3TideSubYPosLo
	AND.w #$00FF
	CLC
	ADC.w !RAM_SMW_Misc_Layer3XSpeedLo
	STA.w !RAM_SMW_Misc_Layer3TideSubYPosLo
	AND.w #$FF00
	BPL.b CODE_05C470
	ORA.w #$00FF
CODE_05C470:
	XBA
	CLC
	ADC.b !RAM_SMW_Mirror_Layer3XPosLo
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	LDA.w !RAM_SMW_Misc_Layer1XDisp
	AND.w #$00FF
	CMP.w #$0080
	BCC.b CODE_05C484
	ORA.w #$FF00
CODE_05C484:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Mirror_Layer3XPosLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
CODE_05C48D:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Mirror_Layer3YPosLo
CODE_05C491:
	SEP.b #$20			; A->8
	RTS

Layer3Tide:
	DEC
	BNE.b CODE_05C4EC
	LDA.w !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_05C4EC
	LDY.w !RAM_SMW_Flag_Layer3VerticalScrollDirection
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$03
	BNE.b CODE_05C4C0
	LDA.w !RAM_SMW_Misc_Layer3YSpeedLo
	BNE.b CODE_05C4AF
	DEC.w !RAM_SMW_Timer_WaitBeforeLayer3TideMovesVertically
	BNE.b CODE_05C4EC
CODE_05C4AF:
	CMP.w TideMaxYSpeed,y
	BEQ.b CODE_05C4BB
	CLC
	ADC.w TideYAcceleration,y
	STA.w !RAM_SMW_Misc_Layer3YSpeedLo
CODE_05C4BB:
	LDA.b #$4B
	STA.w !RAM_SMW_Timer_WaitBeforeLayer3TideMovesVertically
CODE_05C4C0:
	LDA.b !RAM_SMW_Mirror_Layer3YPosLo
	CMP.w TideMaxYPos,y
	BNE.b CODE_05C4CD
	TYA
	EOR.b #$01
	STA.w !RAM_SMW_Flag_Layer3VerticalScrollDirection
CODE_05C4CD:
	LDA.w !RAM_SMW_Misc_Layer3YSpeedLo
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_Misc_Layer3TideSubYPosLo
	STA.w !RAM_SMW_Misc_Layer3TideSubYPosLo
	LDA.w !RAM_SMW_Misc_Layer3YSpeedLo
	PHP
	LSR
	LSR
	LSR
	LSR
	PLP
	BPL.b CODE_05C4E8
	ORA.b #$F0
CODE_05C4E8:
	ADC.b !RAM_SMW_Mirror_Layer3YPosLo				;\ Glitch: Because this position changing routine never touches the high byte of the layer 3 Y position, this causes tides to be vertically fixed on screen.
	STA.b !RAM_SMW_Mirror_Layer3YPosLo				;/
CODE_05C4EC:
	LDA.b !RAM_SMW_Mirror_Layer3XPosLo
	SEC
	ADC.w !RAM_SMW_Misc_Layer1XDisp
	; Change from [85 22 A9 01 85 23] to [38 69 02 85 22 EA] in order to make
	; the Layer 3 tides scroll to the right instead of the left. (Nothing is
	; stored to the high byte of Layer 3 X position, however, so if you
	; adjusted the tide to be asymmetrical, this may not give the wanted
	; result.) Only applies to the graphical part of the Layer 3 tide.
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	LDA.b #$01
	STA.b !RAM_SMW_Mirror_Layer3XPosHi
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_ScrollLayer3(Address)
namespace SMW_ScrollLayer3
%InsertMacroAtXPosition(<Address>)

DATA_05CBBB:
	dw $0004,$FFFC

UNK_05CBBF:
	dw $0004,$FFFC
namespace off
endmacro

macro ROUTINE_RT02_SMW_ScrollLayer3(Address)
namespace SMW_ScrollLayer3
%InsertMacroAtXPosition(<Address>)

DATA_05CBEB:
	db $04,$04
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_ScrollSecondInteractiveLayer(Address)
namespace SMW_ScrollSecondInteractiveLayer
%InsertMacroAtXPosition(<Address>)

Sub:
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_Flag_Layer3TideLevel
	BNE.b CODE_05BC5F
	LDA.w !RAM_SMW_Misc_Layer2XPosLo
	SEC
	SBC.w !RAM_SMW_Misc_Layer1XPosLo
	STA.b !RAM_SMW_Misc_SecondLevelLayerXPosLo
	LDA.w !RAM_SMW_Misc_Layer2YPosLo
	BRA.b CODE_05BC69

CODE_05BC5F:
	LDA.b !RAM_SMW_Mirror_Layer3XPosLo
	SEC
	SBC.w !RAM_SMW_Misc_Layer1XPosLo
	STA.b !RAM_SMW_Misc_SecondLevelLayerXPosLo					; Glitch: This line causes the layer 3 tide interaction to be messed up for sprites.
	LDA.b !RAM_SMW_Mirror_Layer3YPosLo
CODE_05BC69:
	SEC
	SBC.w !RAM_SMW_Misc_Layer1YPosLo
	STA.b !RAM_SMW_Misc_SecondLevelLayerYPosLo
	SEP.b #$20			; A->8
	RTS

Main:
	JSR.w Sub
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_ProcessScrollSprites(Address)
namespace SMW_ProcessScrollSprites
%InsertMacroAtXPosition(<Address>)

Layer1:
	STZ.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.w !RAM_SMW_Flag_SpritesLocked
	BNE.b Return
	LDA.w !RAM_SMW_L1ScrollSpr_SpriteID
	BEQ.b Return
	JSL.l SMW_ExecutePtr_Absolute

; Pointers to the scroll sprite main routines for Layer 1 scrolling.
Ptrs05BC87:
	dw SMW_Layer1SpecialScrolling00_VariableScroll_Main	; 00 - Auto-Scroll, Unused?
	dw SMW_Layer1SpecialScrolling01_VariableScroll_Main	; 01 - Auto-Scroll
	dw SMW_Layer1SpecialScrolling02_DoNothing_Main	; 02 - Layer 2 Smash
	dw SMW_Layer1SpecialScrolling03_DoNothing_Main	; 03 - Layer 2 Scroll
	dw SMW_Layer1SpecialScrolling04_Unused_Main	; 04 - Unused
	dw SMW_Layer1SpecialScrolling05_Unused_Main	; 05 - Unused
	dw SMW_Layer1SpecialScrolling06_DoNothing_Main	; 06 - Layer 2 Falls
	dw SMW_Layer1SpecialScrolling07_DoNothing_Main	; 07 - Unused
	dw SMW_Layer1SpecialScrolling08_Layer2ScrollSOrL_Main	; 08 - Layer 2 Scroll
	dw SMW_Layer1SpecialScrolling09_DoNothing_Main	; 09 - Unused
	dw SMW_Layer1SpecialScrolling0A_Unused_Main	; 0A - Unused
	dw SMW_Layer1SpecialScrolling0B_Layer2OnOffControlled_Main	; 0B - Layer 2 On/Off Switch controlled
	dw SMW_Layer1SpecialScrolling0C_RegularAutoScroll_Main	; 0C - Auto-Scroll level
	dw SMW_Layer1SpecialScrolling0D_DoNothing_Main	; 0D - Fast BG scroll
	dw SMW_Layer1SpecialScrolling0E_DoNothing_Main	; 0E - Layer 2 sink/rise

Layer2:
if !Define_SMW_LunarMagicLevels == !TRUE
	JML.l SMW_LunarMagicLevels_AutoScroll	;\ A self-scrolling Layer 2 setting steps here when the
	NOP					;/ layer is interactive (Config/LunarMagicLevels.asm)
else
	LDA.b #$04
	STA.w !RAM_SMW_ScrollSpr_LayerIndex
endif
.Continue:
	LDA.w !RAM_SMW_L2ScrollSpr_SpriteID
	BEQ.b Return
	LDY.w !RAM_SMW_Flag_SpritesLocked
	BNE.b Return
	JSL.l SMW_ExecutePtr_Absolute

; Pointers to the scroll sprite main routines for Layer 2 scrolling.
Ptrs05BCB8:
	dw SMW_Layer2SpecialScrolling00_VariableScroll_Main
	dw SMW_Layer2SpecialScrolling01_VariableScroll_Main
	dw SMW_Layer2SpecialScrolling02_Layer2Smash_Main
	dw SMW_Layer2SpecialScrolling03_Layer2Scroll_Main
	dw SMW_Layer2SpecialScrolling04_Unused_Main
	dw SMW_Layer2SpecialScrolling05_DoNothing_Main
	dw SMW_Layer2SpecialScrolling06_Unused_Main
	dw SMW_Layer2SpecialScrolling07_DoNothing_Main
	dw SMW_Layer2SpecialScrolling08_Layer2ScrollSOrL_Main
	dw SMW_Layer2SpecialScrolling0D_FastBGScroll_NonFlagged
	dw SMW_Layer2SpecialScrolling0A_Unused_Main
	dw SMW_Layer2SpecialScrolling0B_Layer2OnOffControlled_Main
	dw SMW_Layer2SpecialScrolling0C_RegularAutoScroll_Main
	dw SMW_Layer2SpecialScrolling0D_FastBGScroll_Flagged
	dw SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched_Main
namespace off
endmacro

macro ROUTINE_RT01_SMW_ProcessScrollSprites(Address)
namespace SMW_ProcessScrollSprites
%InsertMacroAtXPosition(<Address>)

Return:
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_ProcessScrollSprites_Return, SMW_NorSpr0F0_UnusedSprite_Main)
	%SetDuplicateOrNullPointer(SMW_ProcessScrollSprites_Return, SMW_Layer1SpecialScrolling02_DoNothing_Main)
	%SetDuplicateOrNullPointer(SMW_ProcessScrollSprites_Return, SMW_Layer1SpecialScrolling03_DoNothing_Main)
	%SetDuplicateOrNullPointer(SMW_ProcessScrollSprites_Return, SMW_Layer1SpecialScrolling06_DoNothing_Main)
	%SetDuplicateOrNullPointer(SMW_ProcessScrollSprites_Return, SMW_Layer1SpecialScrolling09_DoNothing_Main)
	%SetDuplicateOrNullPointer(SMW_ProcessScrollSprites_Return, SMW_Layer1SpecialScrolling0D_DoNothing_Main)
	%SetDuplicateOrNullPointer(SMW_ProcessScrollSprites_Return, SMW_Layer1SpecialScrolling0E_DoNothing_Main)
	%SetDuplicateOrNullPointer(SMW_ProcessScrollSprites_Return, SMW_Layer2SpecialScrolling05_DoNothing_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_Layer1SpecialScrolling01_VariableScroll(Address)
namespace SMW_Layer1SpecialScrolling01_VariableScroll
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_Timer,x
	BNE.b CODE_05C05F
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	STZ.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	RTS

CODE_05C05F:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	TAY
	LDA.w DATA_05CA6F-$01,y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w DATA_05CABF-$01,y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	TAX
	LDA.w !RAM_SMW_Misc_Layer1XPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Misc_Layer1YPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$02
	LDA.w DATA_05CA6F,y
	AND.w #$00FF
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	BNE.b CODE_05C098
	STZ.b !RAM_SMW_Misc_ScratchRAM04
	STX.b !RAM_SMW_Misc_ScratchRAM08
	BRA.b CODE_05C0AD

CODE_05C098:
	ASL
	ASL
	ASL
	ASL
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_05C0A9
	LDX.b #$00
	EOR.w #$FFFF
	INC
CODE_05C0A9:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STX.b !RAM_SMW_Misc_ScratchRAM08
CODE_05C0AD:
	LDX.b #$00
	LDA.w DATA_05CABF,y
	AND.w #$00FF
	CMP.b !RAM_SMW_Misc_ScratchRAM06
	BNE.b CODE_05C0BD
	STZ.b !RAM_SMW_Misc_ScratchRAM06
	BRA.b CODE_05C0D0

CODE_05C0BD:
	ASL
	ASL
	ASL
	ASL
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM02
	BPL.b CODE_05C0CE
	LDX.b #$02
	EOR.w #$FFFF
	INC
CODE_05C0CE:
	STA.b !RAM_SMW_Misc_ScratchRAM06
CODE_05C0D0:
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	LSR
	BCS.b CODE_05C0D7
	LDX.b !RAM_SMW_Misc_ScratchRAM08
CODE_05C0D7:
	STX.b !RAM_SMW_Camera_Layer1ScrollingDirection
	LDA.w #$FFFF
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	BCC.b CODE_05C0F5
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
CODE_05C0F5:
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	STA.w !REGISTER_DividendLo	; Dividend (Low Byte)
	SEP.b #$20			; A->8
	LDA.w DATA_05CB0F,y
	STA.w !REGISTER_Divisor		; Divisor B
	NOP #6
	REP.b #$20			; A->16
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
	BNE.b CODE_05C123
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	INC.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	SEP.b #$20			; A->8
	DEC.w !RAM_SMW_L1ScrollSpr_Timer,x
	JMP.w Main

CODE_05C123:
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	ASL
	ASL
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDY.b #$10
	LDA.w #$0000
	STA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_05C134:
	ASL.b !RAM_SMW_Misc_ScratchRAM0C
	ROL
	CMP.b !RAM_SMW_Misc_ScratchRAM0A
	BCC.b CODE_05C13D
	SBC.b !RAM_SMW_Misc_ScratchRAM0A
CODE_05C13D:
	ROL.b !RAM_SMW_Misc_ScratchRAM0E
	DEY
	BNE.b CODE_05C134
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	TAY
	LDA.w DATA_05CB0F,y
	AND.w #$00FF
	ASL
	ASL
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDX.b #$02
CODE_05C15D:
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	BMI.b CODE_05C165
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	BRA.b CODE_05C167

CODE_05C165:
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_05C167:
	BIT.b !RAM_SMW_Misc_ScratchRAM00,x
	BPL.b CODE_05C16F
	EOR.w #$FFFF
	INC
CODE_05C16F:
	PHX
	PHA
	TXA
	CLC
	ADC.w !RAM_SMW_ScrollSpr_LayerIndex
	TAX
	PLA
	LDY.b #$00
	CMP.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	BEQ.b CODE_05C18D
	BPL.b CODE_05C183
	LDY.b #$02
CODE_05C183:
	LDA.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	CLC
	ADC.w DATA_05CB5F,y
	STA.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
CODE_05C18D:
	JSR.w SMW_UpdateLayerPositionWithScrollSprite_Main
	PLX
	DEX
	DEX
	BPL.b CODE_05C15D
	SEP.b #$20			; A->8
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_Layer1SpecialScrolling01_VariableScroll_Main, SMW_Layer1SpecialScrolling00_VariableScroll_Main)
	%SetDuplicateOrNullPointer(SMW_Layer1SpecialScrolling01_VariableScroll_Main, SMW_Layer2SpecialScrolling00_VariableScroll_Main)
endmacro

macro ROUTINE_RT01_SMW_Layer1SpecialScrolling01_VariableScroll(Address)
namespace SMW_Layer1SpecialScrolling01_VariableScroll
%InsertMacroAtXPosition(<Address>)

DATA_05CA6F:
	db $00,$09,$14,$1C,$24,$28,$33,$3C
	db $43,$4B,$54,$60,$67,$74,$77,$7B
	db $83,$8A,$8D,$90,$99,$A0,$B0,$00
	db $09,$14,$2C,$3C,$B0,$00,$09,$11
	db $1D,$2C,$32,$41,$48,$63,$6B,$70
	db $00,$27,$37,$70,$00,$07,$12,$27
	db $32,$48,$5B,$70,$00,$20,$28,$3A
	db $40,$5F,$66,$6B,$6B,$80,$80,$89
	db $92,$96,$9A,$9E,$A0,$B0,$00,$10
	db $1A,$20,$2B,$30,$3B,$40,$4B,$50

DATA_05CABF:
	db $0C,$0C,$06,$0B,$08,$0C,$03,$02
	db $09,$03,$09,$02,$06,$06,$07,$05
	db $08,$05,$0A,$04,$08,$04,$04,$0C
	db $0C,$07,$07,$05,$05,$0C,$0C,$08
	db $0C,$0C,$07,$07,$0A,$0A,$0C,$0C
	db $00,$00,$0A,$0A,$00,$00,$09,$09
	db $03,$03,$0C,$0C,$0C,$0C,$08,$08
	db $05,$05,$02,$02,$09,$09,$01,$01
	db $01,$02,$03,$07,$08,$08,$0C,$0C
	db $02,$02,$0A,$0A,$02,$02,$0A,$0A

DATA_05CB0F:
	db $07,$07,$07,$07,$07,$07,$07,$07
	db $07,$07,$07,$07,$07,$07,$07,$07
	db $07,$07,$07,$07,$07,$07,$07,$07
	db $07,$07,$07,$07,$07,$07,$07,$07
	db $07,$07,$07,$07,$07,$07,$07,$07
	db $07,$07,$07,$07,$07,$07,$07,$07
	db $07,$07,$07,$07,$08,$08,$08,$08
	db $08,$08,$10,$08,$40,$08,$04,$08
	db $10,$08,$08,$10,$10,$08,$08,$08
	db $08,$08,$08,$08,$08,$08,$08,$08

DATA_05CB5F:
	dw $0001,$FFFF,$0001,$FFFF
	dw $0001,$FFFF,$0001,$FFFF
	dw $0001,$FFFF,$0001,$FFFF
	dw $0001,$FFFF
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_Layer1SpecialScrolling05_Unused(Address)
namespace SMW_Layer1SpecialScrolling05_Unused
%InsertMacroAtXPosition(<Address>)

; A community disassembly log renders this routine wrongly. This reading is
; the correct one: every instruction below was traced against the cartridge's
; bytes, and the routine ends at its RTS with no byte left over.
;
; Worth stating because the error propagates. Tools built from that log
; inherit it -- one relocates the operand of the direct-page LDA below, which
; needs no relocation, and misses the absolute stores that do. Nothing comes
; of it here, since nothing calls this routine, but a reader comparing against
; such a tool should trust the bytes rather than the tool.
;
; This is where a work-RAM-relocating build of this tree differs from that
; tool's output, and deliberately: the absolute accesses below move with the
; rest of work RAM and the direct-page one does not. Four bytes across the two
; routines, and this reading is the reason they differ.
Main:
	LDA.b #$02
	STA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	STZ.b !RAM_SMW_Camera_Layer2ScrollingDirection
	REP.b #$20			; A->16
	LDX.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	BNE.b ADDR_05C6CD
	LDA.w !RAM_SMW_L1ScrollSpr_XSpeedLo
	CMP.w #$0080
	BEQ.b ADDR_05C6B4
	INC
ADDR_05C6B4:
	STA.w !RAM_SMW_L1ScrollSpr_XSpeedLo
	LDY.b !RAM_SMW_Camera_LastScreenHoriz
	DEY
	CPY.w !RAM_SMW_Misc_Layer1XPosHi
	BNE.b ADDR_05C6EC
	INC.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	STZ.w !RAM_SMW_L1ScrollSpr_XSpeedLo
	LDA.w #$FCF0
	STA.w !RAM_SMW_UnusedRAM_UnknownScrollFunctionFlagLo
	BRA.b ADDR_05C6EC

ADDR_05C6CD:
	LDY.b #$16			; \ Unreachable
	STY.w !REGISTER_MainScreenLayers	; Background and Object Enable
	LDA.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	CMP.w #$FF80
	BEQ.b ADDR_05C6DB
	DEC
ADDR_05C6DB:
	STA.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	STA.w !RAM_SMW_L1ScrollSpr_YSpeedLo
	LDA.w !RAM_SMW_Misc_Layer2YPosLo
	BNE.b ADDR_05C6EC
	STZ.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	STZ.w !RAM_SMW_L1ScrollSpr_YSpeedLo
ADDR_05C6EC:
	LDX.b #$06
ADDR_05C6EE:
	JSR.w SMW_UpdateLayerPositionWithScrollSprite_Main
	DEX
	DEX
	BPL.b ADDR_05C6EE
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Misc_Layer1XPosHi
	SEC
	SBC.b !RAM_SMW_Camera_LastScreenHoriz
	INC
	INC
	XBA
	LDA.w !RAM_SMW_Misc_Layer1XPosLo
	REP.b #$20			; A->16
	LDY.b #$82
	CMP.w #$0000
	BPL.b ADDR_05C711
	LDA.w #$0000
	LDY.b #$02
ADDR_05C711:
	STA.w !RAM_SMW_Misc_Layer2XPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	STY.b !RAM_SMW_Misc_LevelLayoutFlags
	JMP.w SMW_Layer2SpecialScrolling04_Unused_CODE_05C32B						; Optimization: Change to SEP.b #$20 : RTS since that's what this JMP.w leads to.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_Layer2SpecialScrolling01_VariableScroll(Address)
namespace SMW_Layer2SpecialScrolling01_VariableScroll
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_Layer1SpecialScrolling01_VariableScroll_Main
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Misc_Layer2XPosLo
	STA.w !RAM_SMW_Misc_Layer1XPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	CLC
	ADC.w !RAM_SMW_ShakingLayer1DispYLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_Layer2SpecialScrolling03_Layer2Scroll(Address)
namespace SMW_Layer2SpecialScrolling03_Layer2Scroll
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$30			; AXY->16
	LDY.w !RAM_SMW_ScrollSpr_LayerIndex
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,y
	TAX
	LDA.w !RAM_SMW_Misc_Layer1YPosLo,y
	CMP.w !RAM_SMW_L1ScrollSpr_SubXPosLo,y
	BCC.b CODE_05C5D4
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STX.b !RAM_SMW_Misc_ScratchRAM02
	BRA.b CODE_05C5D8

CODE_05C5D4:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STX.b !RAM_SMW_Misc_ScratchRAM04
CODE_05C5D8:
	SEP.b #$10			; XY->8
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	BCC.b CODE_05C621
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	BEQ.b CODE_05C5EB
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
CODE_05C5EB:
	TYA
	ASL
	TAY
	LDA.w SMW_SharedScrollSpriteTables_DATA_05CBF5+$01,y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	EOR.w #$0001
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	AND.w #$00FF
	BNE.b CODE_05C615
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	EOR.w #$FFFF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_05C615:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	STA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
CODE_05C621:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	TAX
	LDA.w SMW_SharedScrollSpriteTables_DATA_05CBF1,x
	AND.w #$00FF
	CPX.b #$01
	BEQ.b CODE_05C63C
	EOR.w #$FFFF
	INC
CODE_05C63C:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDY.b #$00
	CMP.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	BEQ.b CODE_05C654
	BPL.b CODE_05C64A
	LDY.b #$02
CODE_05C64A:
	LDA.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	CLC
	ADC.w SMW_SharedScrollSpriteTables_DATA_05CBC3,y
	STA.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
CODE_05C654:
	INX
	INX
	JMP.w SMW_Layer2SpecialScrolling04_Unused_CODE_05C328
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_Layer2SpecialScrolling04_Unused(Address)
namespace SMW_Layer2SpecialScrolling04_Unused
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,y
	SEC
	SBC.w !RAM_SMW_Misc_Layer1YPosLo,y
	BPL.b ADDR_05C295
	EOR.w #$FFFF
	INC
ADDR_05C295:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	AND.w #$00FF
	TAY
	LSR
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !REGISTER_DividendLo	; Dividend (Low Byte)
	SEP.b #$20			; A->8
	LDA.w DATA_05CBE3,x
	STA.w !REGISTER_Divisor		; Divisor B
	NOP #6
	REP.b #$20			; A->16
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
	BNE.b ADDR_05C2E5
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	TAY
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.w #$0200
	CPY.b #$01
	BNE.b ADDR_05C2DE
	EOR.w #$FFFF
	INC
ADDR_05C2DE:
	CLC
	ADC.w !RAM_SMW_Misc_Layer1YPosLo,x
	STA.w !RAM_SMW_Misc_Layer1YPosLo,x
ADDR_05C2E5:
	LDX.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	BEQ.b ADDR_05C2F3
	LDX.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
ADDR_05C2F3:
	LDA.w DATA_05CBE3,x
	AND.w #$00FF
	ASL
	ASL
	ASL
	ASL
	CPY.b #$01
	BEQ.b ADDR_05C305
	EOR.w #$FFFF
	INC
ADDR_05C305:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDY.b #$00
	CMP.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	BEQ.b ADDR_05C31D
	BPL.b ADDR_05C313
	LDY.b #$02
ADDR_05C313:
	LDA.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	CLC
	ADC.w DATA_05CB9B,y
	STA.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
ADDR_05C31D:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	CLC
	ADC.w #$0002
	TAX
CODE_05C328:
	JSR.w SMW_UpdateLayerPositionWithScrollSprite_Main
CODE_05C32B:
	SEP.b #$20			; A->8
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_Layer2SpecialScrolling04_Unused_Main, SMW_Layer1SpecialScrolling04_Unused_Main)
endmacro

macro ROUTINE_RT01_SMW_Layer2SpecialScrolling04_Unused(Address)
namespace SMW_Layer2SpecialScrolling04_Unused
%InsertMacroAtXPosition(<Address>)

DATA_05CB9B:
	dw $0001,$FFFF,$0001,$FFFF
namespace off
endmacro

macro ROUTINE_RT02_SMW_Layer2SpecialScrolling04_Unused(Address)
namespace SMW_Layer2SpecialScrolling04_Unused
%InsertMacroAtXPosition(<Address>)

DATA_05CBE3:
	db $18,$18
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_Layer2SpecialScrolling06_Unused(Address)
namespace SMW_Layer2SpecialScrolling06_Unused
%InsertMacroAtXPosition(<Address>)

; The same disassembly-log error as SMW_Layer1SpecialScrolling05_Unused above,
; read the same way: against the cartridge's bytes, ending at the RTS with no
; byte left over. The absolute accesses below move with the rest of work RAM
; and the direct-page one does not, which is two of the four bytes a
; work-RAM-relocating build of this tree differs by. That routine's comment
; carries the full account.
Main:
	LDA.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
	BEQ.b ADDR_05C674
	DEC.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
	CMP.b #$20
	BCS.b Return05C673
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$01
	BNE.b Return05C673
	LDA.w !RAM_SMW_Misc_Layer1YPosLo
	EOR.b #$01
	STA.w !RAM_SMW_Misc_Layer1YPosLo
Return05C673:
	RTS

ADDR_05C674:
	STZ.b !RAM_SMW_Camera_Layer2ScrollingDirection
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	CMP.w #$FFC0
	BEQ.b ADDR_05C684
	DEC
	STA.w !RAM_SMW_L2ScrollSpr_YSpeedLo
ADDR_05C684:
	LDA.w !RAM_SMW_Misc_Layer2YPosLo
	CMP.w #$0031
	BPL.b ADDR_05C68F
	STZ.w !RAM_SMW_L2ScrollSpr_YSpeedLo
ADDR_05C68F:
	BNE.b ADDR_05C696
	LDY.b #$20
	STY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
ADDR_05C696:
	LDX.b #$06
	JSR.w SMW_UpdateLayerPositionWithScrollSprite_Main
	JMP.w SMW_Layer2SpecialScrolling04_Unused_CODE_05C32B			; Optimization: Change to SEP.b #$20 : RTS since that's what this JMP.w leads to.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_Layer2SpecialScrolling08_Layer2ScrollSOrL(Address)
namespace SMW_Layer2SpecialScrolling08_Layer2ScrollSOrL
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$30			; AXY->16
	LDY.w !RAM_SMW_ScrollSpr_LayerIndex
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_L1ScrollSpr_SubYPosLo,y
	TAX
	LDA.w !RAM_SMW_Misc_Layer1XPosLo,y
	CMP.w !RAM_SMW_L1ScrollSpr_SubYPosLo,y
	BCC.b CODE_05C538
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STX.b !RAM_SMW_Misc_ScratchRAM02
	BRA.b CODE_05C53C

CODE_05C538:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STX.b !RAM_SMW_Misc_ScratchRAM04
CODE_05C53C:
	SEP.b #$10			; XY->8
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	BCC.b CODE_05C585
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	BEQ.b CODE_05C54F
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
CODE_05C54F:
	TYA
	ASL
	TAY
	LDA.w SMW_SharedScrollSpriteTables_DATA_05CBED+$01,y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	EOR.w #$0001
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	AND.w #$00FF
	BNE.b CODE_05C579
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	EOR.w #$FFFF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_05C579:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w !RAM_SMW_L1ScrollSpr_SubYPosLo,x
	STA.w !RAM_SMW_L1ScrollSpr_SubYPosLo,x
CODE_05C585:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	TAX
	LDA.w SMW_SharedScrollSpriteTables_DATA_05CBF1,x
	AND.w #$00FF
	CPX.b #$01
	BEQ.b CODE_05C5A0
	EOR.w #$FFFF
	INC
CODE_05C5A0:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDY.b #$00
	CMP.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	BEQ.b CODE_05C5B8
	BPL.b CODE_05C5AE
	LDY.b #$02
CODE_05C5AE:
	LDA.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	CLC
	ADC.w SMW_SharedScrollSpriteTables_DATA_05CBC3,y
	STA.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
CODE_05C5B8:
	JMP.w SMW_Layer2SpecialScrolling04_Unused_CODE_05C328
namespace off
	%SetDuplicateOrNullPointer(SMW_Layer2SpecialScrolling08_Layer2ScrollSOrL_Main, SMW_Layer1SpecialScrolling08_Layer2ScrollSOrL_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_Layer2SpecialScrolling0A_Unused(Address)
namespace SMW_Layer2SpecialScrolling0A_Unused
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.w !RAM_SMW_L1ScrollSpr_SubYPosLo,y
	SEC
	SBC.w !RAM_SMW_Misc_Layer1XPosLo,y
	BPL.b ADDR_05C340
	EOR.w #$FFFF
	INC
ADDR_05C340:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	AND.w #$00FF
	TAY
	LSR
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !REGISTER_DividendLo	; Dividend (Low Byte)
	SEP.b #$20			; A->8
	LDA.w DATA_05CBE5,x
	STA.w !REGISTER_Divisor		; Divisor B
	NOP #6
	REP.b #$20			; A->16
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
	BNE.b ADDR_05C39F
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	TAY
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.w #$0600
	CPY.b #$01
	BNE.b ADDR_05C389
	EOR.w #$FFFF
	INC
ADDR_05C389:
	CLC
	ADC.w !RAM_SMW_Misc_Layer1XPosLo,x
	STA.w !RAM_SMW_Misc_Layer1XPosLo,x
	LDA.w #$FFF8
	STA.w !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo,x
	LDA.w #$0017
	STA.w !RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo,x
	STZ.w !RAM_SMW_Player_XPosHi
ADDR_05C39F:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	AND.w #$00FF
	PHA
	SEP.b #$20			; A->8
	LDX.b #$02
	LDY.b #$00
	CMP.b #$01
	BEQ.b ADDR_05C3BD
	LDX.b #$00
	LDY.b #$01
ADDR_05C3BD:
	TXA
	STA.w !RAM_SMW_Camera_Layer1ScrollingDirection,y
	REP.b #$20			; A->16
	PLA
	TAY
	LDX.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	BEQ.b ADDR_05C3D3
	LDX.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
ADDR_05C3D3:
	LDA.w DATA_05CBE5,x
	AND.w #$00FF
	ASL
	ASL
	ASL
	ASL
	CPY.b #$01
	BEQ.b ADDR_05C3E5
	EOR.w #$FFFF
	INC
ADDR_05C3E5:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDY.b #$00
	CMP.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	BEQ.b ADDR_05C3FD
	BPL.b ADDR_05C3F3
	LDY.b #$02
ADDR_05C3F3:
	LDA.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	CLC
	ADC.w DATA_05CBA3,y
	STA.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
ADDR_05C3FD:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	JSR.w SMW_UpdateLayerPositionWithScrollSprite_Main
	SEP.b #$20			; A->8
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_Layer2SpecialScrolling0A_Unused_Main, SMW_Layer1SpecialScrolling0A_Unused_Main)
endmacro

macro ROUTINE_RT01_SMW_Layer2SpecialScrolling0A_Unused(Address)
namespace SMW_Layer2SpecialScrolling0A_Unused
%InsertMacroAtXPosition(<Address>)

DATA_05CBA3:
	dw $0004,$FFFC,$0004,$FFFC
	dw $0004,$FFFC,$0004,$FFFC
	dw $0001,$FFFF,$0001,$FFFF
namespace off
endmacro

macro ROUTINE_RT02_SMW_Layer2SpecialScrolling0A_Unused(Address)
namespace SMW_Layer2SpecialScrolling0A_Unused
%InsertMacroAtXPosition(<Address>)

DATA_05CBE5:
	db $18,$18,$08,$20,$06,$06
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_Layer2SpecialScrolling0B_Layer2OnOffControlled(Address)
namespace SMW_Layer2SpecialScrolling0B_Layer2OnOffControlled
%InsertMacroAtXPosition(<Address>)

; Layer 2 on/off switch lower limit. The lower this number, the further down
; the screen layer 2 will go before stopping.
DATA_05C71B:
	db $20,$00,$C1,$00

DATA_05C71F:
	db $C0,$FF,$40,$00

DATA_05C723:
	db $FF,$FF,$01,$00

Main:
	LDX.w !RAM_SMW_Flag_OnOffSwitch
	BEQ.b CODE_05C72E
	LDX.b #$02
CODE_05C72E:
	CPX.w !RAM_SMW_L2ScrollSpr_CurrentState
	BEQ.b CODE_05C74A
	DEC.w !RAM_SMW_L2ScrollSpr_Timer
	BPL.b CODE_05C73B
	STX.w !RAM_SMW_L2ScrollSpr_CurrentState
CODE_05C73B:
	LDA.w !RAM_SMW_Misc_Layer2YPosLo
	EOR.b #$01
	STA.w !RAM_SMW_Misc_Layer2YPosLo
	STZ.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	STZ.w !RAM_SMW_L2ScrollSpr_YSpeedHi
	RTS

CODE_05C74A:
	LDA.b #$10
	STA.w !RAM_SMW_L2ScrollSpr_Timer
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Misc_Layer2YPosLo
	CMP.w DATA_05C71B,x
	BNE.b CODE_05C770
	CPX.b #$00
	BNE.b CODE_05C769
	LDA.w #!Define_SMW_Sound1DFC_BulletShoot		;\ Glitch: This executes every frame when layer 2 is at its lowest position. This causes layer 1 to be shifted slightly and cause some sounds to be overwritten.
	STA.w !RAM_SMW_IO_SoundCh3				;|
	LDA.w #$0020						;|
	STA.w !RAM_SMW_Timer_ShakeLayer1			;/
CODE_05C769:
	LDX.b #$00
	STX.w !RAM_SMW_Flag_OnOffSwitch
	BRA.b CODE_05C784

CODE_05C770:
	LDA.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	CMP.w DATA_05C71F,x
	BEQ.b CODE_05C77F
	CLC
	ADC.w DATA_05C723,x
	STA.w !RAM_SMW_L2ScrollSpr_YSpeedLo
CODE_05C77F:
	LDX.b #$06
	JSR.w SMW_UpdateLayerPositionWithScrollSprite_Main
CODE_05C784:
	JMP.w SMW_Layer2SpecialScrolling04_Unused_CODE_05C32B	; Optimization: Change to SEP.b #$20 : RTS since that's what this JMP.w leads to.

namespace off
	%SetDuplicateOrNullPointer(SMW_Layer2SpecialScrolling0B_Layer2OnOffControlled_Main, SMW_Layer1SpecialScrolling0B_Layer2OnOffControlled_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_Layer2SpecialScrolling0D_FastBGScroll(Address)
namespace SMW_Layer2SpecialScrolling0D_FastBGScroll
%InsertMacroAtXPosition(<Address>)

; Change to A9 08 EA and the background will start scrolling fast with
; generator F4 without having to touch platform C1
Flagged:
	LDA.w !RAM_SMW_Flag_ActiveFastBackgroundScrollGenerator
	BEQ.b CODE_05C7ED
NonFlagged:
	LDA.b #$02
	STA.b !RAM_SMW_Camera_Layer2ScrollingDirection
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_L2ScrollSpr_XSpeedLo
	CMP.w #$0400
	BEQ.b CODE_05C7D0
	INC
CODE_05C7D0:
	STA.w !RAM_SMW_L2ScrollSpr_XSpeedLo
	LDX.b #$04
	JSR.w SMW_UpdateLayerPositionWithScrollSprite_Main
	LDA.w !RAM_SMW_Misc_Layer1XDisp
	AND.w #$00FF
	CMP.w #$0080
	BCC.b CODE_05C7E6
	ORA.w #$FF00
CODE_05C7E6:
	CLC
	ADC.w !RAM_SMW_Misc_Layer2XPosLo
	STA.w !RAM_SMW_Misc_Layer2XPosLo
CODE_05C7ED:
	JMP.w SMW_Layer2SpecialScrolling04_Unused_CODE_05C32B				; Optimization: Change to SEP.b #$20 : RTS since that's what this JMP.w leads to.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched(Address)
namespace SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched
%InsertMacroAtXPosition(<Address>)

DATA_05C80E:
	dw $00C0

DATA_05C810:
	dw $0000,$00B0

DATA_05C814:
	dw $FF80,$00C0

DATA_05C818:
if ver_is_pal(!Define_Global_ROMToAssemble)
	dw $FFFE,$0002
else
	dw $FFFF,$0001			;!
endif

Main:
	REP.b #$20			; A->16
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_L2ScrollSpr_Timer
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b #$00
	LDX.w !RAM_SMW_L1ScrollSpr_Timer
	CPX.b #$08
	BCC.b CODE_05C830
	LDY.b #$02
CODE_05C830:
	LDA.w !RAM_SMW_Misc_Layer2XPosLo
	CMP.w DATA_05C7F0,x
	BCC.b CODE_05C84C
	CMP.w DATA_05C7FC,x
	BCS.b CODE_05C84C
	STZ.w !RAM_SMW_L1ScrollSpr_CurrentState
	LDA.w DATA_05C80E,y
	STA.w !RAM_SMW_Misc_Layer2YPosLo
	STZ.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	STZ.w !RAM_SMW_L2ScrollSpr_SubYPosLo
CODE_05C84C:
	INX
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_05C830
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState
	ORA.w !RAM_SMW_Sprites_Layer2IsTouchedFlag
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState
	BEQ.b CODE_05C87D
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Misc_Layer2YPosLo
	CMP.w DATA_05C810,y
	BEQ.b CODE_05C87D
	LDA.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	CMP.w DATA_05C814,y
	BEQ.b CODE_05C875
	CLC
	ADC.w DATA_05C818,y
CODE_05C875:
	STA.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	LDX.b #$06
	JSR.w SMW_UpdateLayerPositionWithScrollSprite_Main
CODE_05C87D:
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched(Address)
namespace SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched
%InsertMacroAtXPosition(<Address>)

DATA_05C7F0:
	dw $0000,$02F0,$08B0,$0000
	dw $0000,$0370

DATA_05C7FC:
	dw $00D0,$0350,$0A30,$0008
	dw $0040,$0380
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_Layer1SpecialScrolling0C_RegularAutoScroll(Address)
namespace SMW_Layer1SpecialScrolling0C_RegularAutoScroll
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$02
	STA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	STA.b !RAM_SMW_Camera_Layer2ScrollingDirection
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	LSR
	LSR
	TAX
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex,x
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	CMP.w SMW_NorSpr0F3_RegularAutoScroll_MaxXSpeed,y
	BEQ.b CODE_05C7A4
	INC
CODE_05C7A4:
	STA.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	LDA.b !RAM_SMW_Camera_LastScreenHoriz
	DEC
	XBA
	AND.w #$FF00
	CMP.w !RAM_SMW_Misc_Layer1XPosLo,x
	BNE.b CODE_05C7B6							;\ Glitch: If this autoscroll happens to be moving fast enough, it will cause the camera to go beyond the right edge of the level.
										;/ To fix, change this BNE.b to BCS.b and change STZ.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x to STA.w !RAM_SMW_Misc_Layer1XPosLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
CODE_05C7B6:
	JSR.w SMW_UpdateLayerPositionWithScrollSprite_Main
	JMP.w SMW_Layer2SpecialScrolling04_Unused_CODE_05C32B			; Optimization: Change to SEP.b #$20 : RTS since that's what this JMP.w leads to.

namespace off
	%SetDuplicateOrNullPointer(SMW_Layer1SpecialScrolling0C_RegularAutoScroll_Main, SMW_Layer2SpecialScrolling0C_RegularAutoScroll_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_Layer2SpecialScrolling02_Layer2Smash(Address)
namespace SMW_Layer2SpecialScrolling02_Layer2Smash
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
CODE_05C95B:
	REP.b #$20			; A->16
CODE_05C95D:
	LDA.w !RAM_SMW_Misc_Layer2XPosLo
	CMP.w DATA_05C880,x
	BCC.b CODE_05C97B
	CMP.w DATA_05C8A4,x
	BCS.b CODE_05C97B
	TXA
	LSR
	AND.w #$00FE
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState
	LDA.w #$00C1
	STA.w !RAM_SMW_Misc_Layer2YPosLo
	STZ.w !RAM_SMW_L1ScrollSpr_Timer
CODE_05C97B:
	INX
	INX
	DEY
	BNE.b CODE_05C95D
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_L1ScrollSpr_Timer
	BEQ.b CODE_05C98B
	DEC.w !RAM_SMW_L1ScrollSpr_Timer
	RTS

CODE_05C98B:
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState
	CLC
	ADC.w !RAM_SMW_L2ScrollSpr_CurrentState
	TAY
	LSR
	TAX
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Misc_Layer2YPosLo
	SEC
	SBC.w DATA_05C8C8,y
	EOR.w DATA_05C8FE,y
	BPL.b CODE_05C9A9
	LDA.w DATA_05C8FE,y
	JMP.w SMW_Layer2SpecialScrolling0E_Layer2ScrollWhenTouched_CODE_05C875

CODE_05C9A9:
	LDA.w DATA_05C8C8,y
	STA.w !RAM_SMW_Misc_Layer2YPosLo
	SEP.b #$20			; A->8
	LDA.w DATA_05C934,x
	STA.w !RAM_SMW_L1ScrollSpr_Timer
	LDA.w !RAM_SMW_L2ScrollSpr_CurrentState
	CLC
	ADC.b #$12
	CMP.b #$36
	BCC.b CODE_05C9CD
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b #$20			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
	LDA.b #$00
CODE_05C9CD:
	STA.w !RAM_SMW_L2ScrollSpr_CurrentState
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_Layer2SpecialScrolling02_Layer2Smash(Address)
namespace SMW_Layer2SpecialScrolling02_Layer2Smash
%InsertMacroAtXPosition(<Address>)

DATA_05C880:
	dw $0000,$01C0,$0300,$0800,$0838,$0A00
	dw $0000,$0380,$0450,$0890,$0960,$0E80
	dw $4000,$4000,$4000,$4000,$4000,$0000

DATA_05C8A4:
	dw $0008,$0300,$0410,$0838,$0870,$0B00
	dw $0008,$0450,$04A0,$0960,$0A40,$0FFF
	dw $5000,$5000,$5000,$5000,$5000,$0080

DATA_05C8C8:
	dw $00C0,$00B0,$0070,$00C0,$00C0,$00C0
	dw $0000,$0000,$00C0,$00B0,$00A0,$0070
	dw $00B0,$00B0,$00B0,$0000,$0000,$00B0
	dw $0020,$0020,$0020,$0010,$0010,$0010
	dw $0000,$0000,$0010

DATA_05C8FE:
	dw $0100,$0100,$0800,$0100
	dw $0100,$0800,$0000,$0000
	dw $0180,$FF00,$FF00,$0000
	dw $FF00,$FF00,$FF00,$FF00
	dw $FF00,$FF00,$F800,$F800
	dw $F800,$F800,$F800,$F800
	dw $0000,$0000,$FE40

DATA_05C934:
if ver_is_pal(!Define_Global_ROMToAssemble)
	db $66,$33,$01,$66,$00,$00,$66,$00
	db $33,$00,$00,$19,$33,$00,$19,$00
	db $00,$19,$66,$66,$19,$66,$66,$19
	db $00,$00,$80
else
	db $80,$40,$01,$80,$00,$00,$80,$00	;!
	db $40,$00,$00,$20,$40,$00,$20,$00	;!
	db $00,$20,$80,$80,$20,$80,$80,$20	;!
	db $00,$00,$A0			;!
endif
namespace off
endmacro

macro ROUTINE_RT05_SMW_GameMode12_PrepareLevel(Address)
namespace SMW_GameMode12_PrepareLevel
%InsertMacroAtXPosition(<Address>)

InitializeLayer3RAM:
	PHB									;\ Optimization: Unnecessary bank wrapper
	PHK									;|
	PLB									;/
	REP.b #$20			; A->16
	LDA.w SMW_NorSpr0F1_UnusedSprite_DATA_05CA26				;\ Note: Why not just load #$0001?
	STA.w !RAM_SMW_Flag_Layer3VerticalScrollDirection			;/ Also, this affects unused RAM $7E1461
	STZ.w !RAM_SMW_Misc_Layer3XSpeedLo
	STZ.w !RAM_SMW_Misc_Layer3YSpeedLo
	STZ.w !RAM_SMW_Misc_Layer3TideSubYPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Mirror_Layer3YPosLo
	SEP.b #$20			; A->8
	PLB									; Optimization: Unnecessary PLB.
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GiveCoins(Address)
namespace SMW_GiveCoins
%InsertMacroAtXPosition(<Address>)

; Give coins subroutine. If you JSL to it, it will give the player the
; number of coins equal to the value in A.
MultipleCoins:
	PHA
	LDA.b #!Define_SMW_Sound1DFC_Coin
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	PLA
.NoCoinSound:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w !RAM_SMW_Counter_CoinHandler
	STA.w !RAM_SMW_Counter_CoinHandler
	LDA.w !RAM_SMW_Counter_GreenStarBlock
	BEQ.b Return05B35A
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_05B345
	LDA.b #$00
CODE_05B345:
	STA.w !RAM_SMW_Counter_GreenStarBlock
	BRA.b Return05B35A

; Subroutine that gives the player a single coin. It handles the green star
; block as well. $05B34E is the sound this generates.
OneCoin:
Main:
	INC.w !RAM_SMW_Counter_CoinHandler
	LDA.b #!Define_SMW_Sound1DFC_Coin
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.w !RAM_SMW_Counter_GreenStarBlock
	BEQ.b Return05B35A
	DEC.w !RAM_SMW_Counter_GreenStarBlock
Return05B35A:
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UnusedOverworldEventPassedCheck(Address)
namespace SMW_UnusedOverworldEventPassedCheck
%InsertMacroAtXPosition(<Address>)

Main:
	TYA				; \ Unreachable
	AND.b #$07
	PHA
	TYA
	LSR
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_Overworld_EventFlags,x
	PLX
	AND.l SMW_BitTable_Bank05,x
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_FileSelectText(Address)
namespace SMW_FileSelectText
%InsertMacroAtXPosition(<Address>)

cleartable

Main:
EraseFile:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	%StripeImageHeader(.ClearLine1, $08, $11, 0, $001D, 3)
	db $FC,$38
.ClearLine1End:
	%StripeImageHeader(.ClearLine2, $08, $13, 0, $001D, 3)
	db $FC,$38
.ClearLine2End:

SelectFile:
	%InsertVersionExclusiveFile(incbin, ../SMW/strings/FileSelectText_, SMW_J.bin, )
SelectFileEnd:
	db $FF

elseif ver_is_arcade(!Define_Global_ROMToAssemble)
	%StripeImageHeader(.ClearLine1, $05, $10, 0, $002F, 3)
	db $FC,$38
.ClearLine1End:
	%StripeImageHeader(.ClearLine2, $08, $11, 0, $001D, 3)
	db $FC,$38
.ClearLine2End:
	%StripeImageHeader(.ClearLine3, $05, $12, 0, $002F, 3)
	db $FC,$38
.ClearLine3End:
	%StripeImageHeader(.ClearLine4, $08, $13, 0, $001D, 3)
	db $FC,$38
.ClearLine4End:
	%StripeImageHeader(.ClearLine5, $05, $14, 0, $002F, 3)
	db $FC,$38
.ClearLine5End:
	%StripeImageHeader(.ClearLine6, $05, $16, 0, $001D, 3)
	db $FC,$38
.ClearLine6End:
	%StripeImageHeader(.MarioA, $0D, $10, 0, $0000, 3)
	;dw "MARIO A ...EMPTY"
	db $76,$31,$71,$31,$74,$31,$82,$30,$83,$30,$FC,$38,$71,$31,$FC,$38,$24,$38,$24,$38,$24,$38,$73,$31,$76,$31,$6F,$31,$2F,$31,$72,$31
.MarioAEnd:
	%StripeImageHeader(.MarioB, $0D, $12, 0, $0000, 3)
	;dw "MARIO B ...EMPTY"
	db $76,$31,$71,$31,$74,$31,$82,$30,$83,$30,$FC,$38,$2C,$31,$FC,$38,$24,$38,$24,$38,$24,$38,$73,$31,$76,$31,$6F,$31,$2F,$31,$72,$31
.MarioBEnd:
	%StripeImageHeader(.MarioC, $0D, $14, 0, $0000, 3)
	;dw "MARIO C ...EMPTY"
	db $76,$31,$71,$31,$74,$31,$82,$30,$83,$30,$FC,$38,$2D,$31,$FC,$38,$24,$38,$24,$38,$24,$38,$73,$31,$76,$31,$6F,$31,$2F,$31,$72,$31
.MarioCEnd:
	%StripeImageHeader(.EraseA, $07, $10, 0, $0000, 3)		;\ Note: Why not pair these up with the above 3 lines of text?
	;dw "ERASE "							;|
	db $73,$31,$74,$31,$71,$31,$31,$31,$73,$31,$FC,$38		;|
.EraseAEnd:								;|
	%StripeImageHeader(.EraseB, $07, $12, 0, $0000, 3)		;|
	;dw "ERASE "							;|
	db $73,$31,$74,$31,$71,$31,$31,$31,$73,$31,$FC,$38		;|
.EraseBEnd:								;|
	%StripeImageHeader(.EraseC, $07, $14, 0, $0000, 3)		;|
	;dw "ERASE "							;|
	db $73,$31,$74,$31,$71,$31,$31,$31,$73,$31,$FC,$38		;|
.EraseCEnd:								;/
	%StripeImageHeader(.End, $07, $16, 0, $0000, 3)
	;dw "END"
	db $73,$31,$79,$30,$7C,$30
.EndEnd:
	db $FF

SelectFile:
	%StripeImageHeader(.ClearLine1, $05, $10, 0, $002F, 3)
	db $FC,$38
.ClearLine1End:
	%StripeImageHeader(.ClearLine2, $08, $11, 0, $001D, 3)
	db $FC,$38
.ClearLine2End:
	%StripeImageHeader(.ClearLine3, $05, $12, 0, $002F, 3)
	db $FC,$38
.ClearLine3End:
	%StripeImageHeader(.ClearLine4, $08, $13, 0, $001D, 3)
	db $FC,$38
.ClearLine4End:
	%StripeImageHeader(.ClearLine5, $05, $14, 0, $002F, 3)
	db $FC,$38
.ClearLine5End:
	%StripeImageHeader(.ClearLine6, $05, $16, 0, $001D, 3)
	db $FC,$38
.ClearLine6End:
	%StripeImageHeader(.Row1, $08, $10, 0, $0000, 3)
	;dw "ZONE 1    ZONE 5"
	db $21,$31,$3E,$31,$30,$31,$73,$31,$FC,$38,$6D,$31,$FC,$38,$FC,$38,$FC,$38,$FC,$38,$21,$31,$3E,$31,$30,$31,$73,$31,$FC,$38,$51,$30
.Row1End:
	%StripeImageHeader(.Row2, $08, $12, 0, $0000, 3)
	;dw "ZONE 2    ZONE 6"
	db $21,$31,$3E,$31,$30,$31,$73,$31,$FC,$38,$6E,$31,$FC,$38,$FC,$38,$FC,$38,$FC,$38,$21,$31,$3E,$31,$30,$31,$73,$31,$FC,$38,$52,$30
.Row2End:
	%StripeImageHeader(.Row3, $08, $14, 0, $0000, 3)
	;dw "ZONE 3    ZONE 7"
	db $21,$31,$3E,$31,$30,$31,$73,$31,$FC,$38,$4E,$30,$FC,$38,$FC,$38,$FC,$38,$FC,$38,$21,$31,$3E,$31,$30,$31,$73,$31,$FC,$38,$53,$30
.Row3End:
	%StripeImageHeader(.Row4, $08, $16, 0, $0000, 3)
	;dw "ZONE 4"
	db $21,$31,$3E,$31,$30,$31,$73,$31,$FC,$38,$50,$30
.Row4End:
	db $FF

else
	%StripeImageHeader(.ClearLine1, $05, $0F, 0, $002F, 3)
	db $FC,$38
.ClearLine1End:
	%StripeImageHeader(.ClearLine2, $08, $10, 0, $001D, 3)
	db $FC,$38
.ClearLine2End:
	%StripeImageHeader(.ClearLine3, $05, $11, 0, $002F, 3)
	db $FC,$38			;!
.ClearLine3End:
	%StripeImageHeader(.ClearLine4, $08, $12, 0, $001D, 3)
	db $FC,$38
.ClearLine4End:
	%StripeImageHeader(.ClearLine5, $05, $13, 0, $002F, 3)
	db $FC,$38
.ClearLine5End:
	%StripeImageHeader(.ClearLine6, $05, $15, 0, $001D, 3)
	db $FC,$38
.ClearLine6End:
	%StripeImageHeader(.MarioA, $0D, $0F, 0, $0000, 3)
	;dw "MARIO A ...EMPTY"
	db $76,$31,$71,$31,$74,$31,$82,$30,$83,$30,$FC,$38,$71,$31,$FC,$38,$24,$38,$24,$38,$24,$38,$73,$31,$76,$31,$6F,$31,$2F,$31,$72,$31	;!
.MarioAEnd:
	%StripeImageHeader(.MarioB, $0D, $11, 0, $0000, 3)
	;dw "MARIO B ...EMPTY"
	db $76,$31,$71,$31,$74,$31,$82,$30,$83,$30,$FC,$38,$2C,$31,$FC,$38,$24,$38,$24,$38,$24,$38,$73,$31,$76,$31,$6F,$31,$2F,$31,$72,$31
.MarioBEnd:
	%StripeImageHeader(.MarioC, $0D, $13, 0, $0000, 3)
	;dw "MARIO C ...EMPTY"
	db $76,$31,$71,$31,$74,$31,$82,$30,$83,$30,$FC,$38,$2D,$31,$FC,$38,$24,$38,$24,$38,$24,$38,$73,$31,$76,$31,$6F,$31,$2F,$31,$72,$31	;!
.MarioCEnd:
	%StripeImageHeader(.EraseA, $07, $0F, 0, $0000, 3)		;\ Note: Why not pair these up with the above 3 lines of text?
	;dw "ERASE "							;|
	db $73,$31,$74,$31,$71,$31,$31,$31,$73,$31,$FC,$38		;|
.EraseAEnd:								;|
	%StripeImageHeader(.EraseB, $07, $11, 0, $0000, 3)		;|
	;dw "ERASE "							;|
	db $73,$31,$74,$31,$71,$31,$31,$31,$73,$31,$FC,$38		;|
.EraseBEnd:								;|
	%StripeImageHeader(.EraseC, $07, $13, 0, $0000, 3)		;|
	;dw "ERASE "							;|
	db $73,$31,$74,$31,$71,$31,$31,$31,$73,$31,$FC,$38		;|
.EraseCEnd:								;/
	%StripeImageHeader(.End, $07, $15, 0, $0000, 3)
	;dw "END"
	db $73,$31,$79,$30,$7C,$30
.EndEnd:
	db $FF

SelectFile:
	%StripeImageHeader(.ClearLine1, $05, $0F, 0, $002F, 3)
	db $FC,$38
.ClearLine1End:
	%StripeImageHeader(.ClearLine2, $08, $10, 0, $001D, 3)
	db $FC,$38
.ClearLine2End:
	%StripeImageHeader(.ClearLine3, $05, $11, 0, $002F, 3)
	db $FC,$38
.ClearLine3End:
	%StripeImageHeader(.ClearLine4, $08, $12, 0, $001D, 3)
	db $FC,$38
.ClearLine4End:
	%StripeImageHeader(.ClearLine5, $05, $13, 0, $002F, 3)
	db $FC,$38
.ClearLine5End:
	%StripeImageHeader(.ClearLine6, $05, $15, 0, $001D, 3)
	db $FC,$38
.ClearLine6End:
	%StripeImageHeader(.MarioA, $0A, $0F, 0, $0000, 3)
	;dw "MARIO A ...EMPTY"
	db $76,$31,$71,$31,$74,$31,$82,$30,$83,$30,$FC,$38,$71,$31,$FC,$38,$24,$38,$24,$38,$24,$38,$73,$31,$76,$31,$6F,$31,$2F,$31,$72,$31
.MarioAEnd:
	%StripeImageHeader(.MarioB, $0A, $11, 0, $0000, 3)
	;dw "MARIO B ...EMPTY"
	db $76,$31,$71,$31,$74,$31,$82,$30,$83,$30,$FC,$38,$2C,$31,$FC,$38,$24,$38,$24,$38,$24,$38,$73,$31,$76,$31,$6F,$31,$2F,$31,$72,$31
.MarioBEnd:
	%StripeImageHeader(.MarioC, $0A, $13, 0, $0000, 3)
	;dw "MARIO C ...EMPTY"
	db $76,$31,$71,$31,$74,$31,$82,$30,$83,$30,$FC,$38,$2D,$31,$FC,$38,$24,$38,$24,$38,$24,$38,$73,$31,$76,$31,$6F,$31,$2F,$31,$72,$31
.MarioCEnd:
	%StripeImageHeader(.EraseData, $0A, $15, 0, $0000, 3)
	;dw "ERASE DATA"
	db $73,$31,$74,$31,$71,$31,$31,$31,$73,$31,$FC,$38,$7C,$30,$71,$31,$2F,$31,$71,$31
.EraseDataEnd:
	db $FF
endif
cleartable
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_XPlayerGameText(Address)
namespace SMW_XPlayerGameText
%InsertMacroAtXPosition(<Address>)

cleartable

Main:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	%InsertVersionExclusiveFile(incbin, ../SMW/strings/XPlayerGame_, SMW_J.bin, )
elseif ver_is_arcade(!Define_Global_ROMToAssemble)
	%StripeImageHeader(ClearLine1, $05, $10, 0, $0030, 3)
	db $FC,$38
ClearLine1End:
	%StripeImageHeader(ClearLine2, $05, $12, 0, $0030, 3)
	db $FC,$38
ClearLine2End:
	%StripeImageHeader(ClearLine3, $05, $14, 0, $0030, 3)
	db $FC,$38
ClearLine3End:
	%StripeImageHeader(ClearLine4, $05, $16, 0, $001D, 3)
	db $FC,$38
ClearLine4End:
	%StripeImageHeader(OnePlayer, $0A, $10, 0, $0000, 3)
	;dw "1 PLAYER GAME"
	db $6D,$31,$FC,$38,$6F,$31,$70,$31,$71,$31,$72,$31,$73,$31,$74,$31,$FC,$38,$75,$31,$71,$31,$76,$31,$73,$31
OnePlayerEnd:
	%StripeImageHeader(TwoPlayer, $0A, $12, 0, $0000, 3)
	;dw "2 PLAYER GAME"
	db $6E,$31,$FC,$38,$6F,$31,$70,$31,$71,$31,$72,$31,$73,$31,$74,$31,$FC,$38,$75,$31,$71,$31,$76,$31,$73,$31
TwoPlayerEnd:
	db $FF
else
	%StripeImageHeader(ClearLine1, $05, $0F, 0, $0030, 3)
	db $FC,$38
ClearLine1End:
	%StripeImageHeader(ClearLine2, $05, $11, 0, $0030, 3)
	db $FC,$38
ClearLine2End:
	%StripeImageHeader(ClearLine3, $05, $13, 0, $0030, 3)
	db $FC,$38			;!
ClearLine3End:
	%StripeImageHeader(ClearLine4, $05, $15, 0, $001D, 3)
	db $FC,$38
ClearLine4End:
	%StripeImageHeader(OnePlayer, $0A, $10, 0, $0000, 3)
	;dw "1 PLAYER GAME"
	db $6D,$31,$FC,$38,$6F,$31,$70,$31,$71,$31,$72,$31,$73,$31,$74,$31,$FC,$38,$75,$31,$71,$31,$76,$31,$73,$31
OnePlayerEnd:
	%StripeImageHeader(TwoPlayer, $0A, $12, 0, $0000, 3)
	;dw "2 PLAYER GAME"
	db $6E,$31,$FC,$38,$6F,$31,$70,$31,$71,$31,$72,$31,$73,$31,$74,$31,$FC,$38,$75,$31,$71,$31,$76,$31,$73,$31
TwoPlayerEnd:
	db $FF
endif
cleartable
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_SaveMenuText(Address)
namespace SMW_SaveMenuText
%InsertMacroAtXPosition(<Address>)

cleartable
Main:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	%InsertVersionExclusiveFile(incbin, ../SMW/strings/SaveMenuText_, SMW_J.bin, )
else
	%StripeImageHeader(ContinueAndSave, $06, $0E, 0, $0000, 3)
	;dw "CONTINUE AND SAVE"
	db $2D,$39,$7A,$38,$79,$38,$2F,$39,$82,$38,$79,$38,$7B,$38,$73,$39,$FC,$38,$71,$39,$79,$38,$7C,$38,$FC,$38,$31,$39,$71,$39,$80,$38,$73,$39
ContinueAndSaveEnd:
	%StripeImageHeader(ContinueWithoutSave, $06, $10, 0, $0000, 3)
	;dw "CONTINUE WITHOUT SAVE"
	db $2D,$39,$7A,$38,$79,$38,$2F,$39,$82,$38,$79,$38,$7B,$38,$73,$39,$FC,$38,$81,$38,$82,$38,$2F,$39,$84,$38,$7A,$38,$7B,$38,$2F,$39,$FC,$38,$31,$39,$71,$39,$80,$38,$73,$39
ContinueWithoutSaveEnd:
	db $FF
endif
cleartable
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_ContinueEndText(Address)
namespace SMW_ContinueEndText
%InsertMacroAtXPosition(<Address>)

cleartable

Main:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	%InsertVersionExclusiveFile(incbin, ../SMW/strings/ContinueEndText_, SMW_J.bin, )
else
	%StripeImageHeader(Continue, $0D, $0E, 0, $0000, 3)
	;dw "CONTINUE"
	db $2D,$39,$7A,$38,$79,$38,$2F,$39,$82,$38,$79,$38,$7B,$38,$73,$39
ContinueEnd:
	%StripeImageHeader(End, $0D, $10, 0, $0000, 3)
	;dw "END"
	db $73,$39,$79,$38,$7C,$38	;!
EndEnd:
	db $FF
endif
cleartable
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_CourseClearText(Address)
namespace SMW_CourseClearText
%InsertMacroAtXPosition(<Address>)

cleartable

Main:
	%StripeImageHeader(Mario, $0D, $08, 0, $0000, 3)
	db $30,$28,$31,$28,$32,$28,$33,$28,$34,$28
MarioEnd:
	%StripeImageHeader(CourseClear, $09, $0A, 0, $0000, 3)
	db $0C,$38,$18,$38,$1E,$38,$1B,$38,$1C,$38,$0E,$38,$FC,$38,$0C,$38,$15,$38,$0E,$38,$0A,$38,$1B,$38,$28,$38
CourseClearEnd:
	%StripeImageHeader(TimeBonus, $09, $0D, 0, $0000, 3)
	db $76,$38,$FC,$38,$FC,$38,$FC,$38,$26,$38,$05,$38,$00,$38,$77,$38,$FC,$38,$FC,$38,$FC,$38,$FC,$38,$FC,$38
TimeBonusEnd:
	db $FF
Luigi:
;$05CC61
	; 'LUIGI' letters used in the end-of-level scorecard (uses the same
	; attributes as the MARIO letters)
	db $40,$41,$42,$43,$44				; Note: Due to how Luigi's name is coded to appear, these tiles must have the same properties and position as the Mario tiles.
LuigiEnd:
cleartable
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_GotBonusStarsText(Address)
namespace SMW_GotBonusStarsText
%InsertMacroAtXPosition(<Address>)

cleartable

Main:
	%StripeImageHeader(Bonus, $0A, $10, 0, $0000, 3)
db $0B,$38,$18,$38,$17,$38,$1E,$38,$1C,$38,$28,$38,$FC,$38,$64,$28,$26,$38,$FC,$38,$FC,$38
BonusEnd:
	%StripeImageHeader(TopHalf, $13, $0F, 0, $0000, 3)
db $FC,$38,$FC,$38
TopHalfEnd:
	db $FF
cleartable
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_NoBonusStarsText(Address)
namespace SMW_NoBonusStarsText
%InsertMacroAtXPosition(<Address>)

cleartable

Main:
	%StripeImageHeader(Stars, $11, $0D, 0, $0000, 3)
db $FC,$38,$FC,$38,$FC,$38,$FC,$38,$00,$38
StarsEnd:
	%StripeImageHeader(TopHalf, $13, $0F, 0, $0000, 3)
db $FC,$38,$FC,$38
TopHalfEnd:
	%StripeImageHeader(BottomHalf, $13, $10, 0, $0000, 3)
db $FC,$38,$FC,$38
BottomHalfEnd:
	db $FF
cleartable
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_UnusedScrollSpriteRoutine(Address)
namespace SMW_UnusedScrollSpriteRoutine
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex	; \ Unreachable
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_Timer,x
	BMI.b ADDR_05C1D4
	DEC.w !RAM_SMW_L1ScrollSpr_Timer,x
	LDA.w !RAM_SMW_L1ScrollSpr_Timer,x
	CMP.b #$20
	BCC.b ADDR_05C1D1
	REP.b #$20			; A->16
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.w !RAM_SMW_Misc_Layer1YPosLo,x
	EOR.w #$0001
	STA.w !RAM_SMW_Misc_Layer1YPosLo,x
ADDR_05C1D1:
	JMP.w SMW_Layer2SpecialScrolling04_Unused_CODE_05C32B				; Optimization: Change to SEP.b #$20 : RTS since that's what this JMP.w leads to.

ADDR_05C1D4:
	REP.b #$30			; AXY->16
	LDY.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,y
	TAX
	LDA.w !RAM_SMW_Misc_Layer1YPosLo,y
	CMP.w !RAM_SMW_L1ScrollSpr_SubXPosLo,y
	BCC.b ADDR_05C1EB
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STX.b !RAM_SMW_Misc_ScratchRAM02
	BRA.b ADDR_05C1EF

ADDR_05C1EB:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STX.b !RAM_SMW_Misc_ScratchRAM04
ADDR_05C1EF:
	SEP.b #$10			; XY->8
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	BCC.b ADDR_05C24D
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.b #$FF
	LSR
	LSR
	TAX
	LDA.b #$30
	STA.w !RAM_SMW_L1ScrollSpr_Timer,x
	REP.b #$20			; A->16
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	STZ.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_SubYPosLo,x
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	BEQ.b ADDR_05C21F
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
ADDR_05C21F:
	LDA.w SMW_SharedScrollSpriteTables_UNK_05CBC7,y
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	TXA
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	EOR.w #$0001
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	AND.w #$00FF
	BNE.b ADDR_05C241
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	EOR.w #$FFFF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM00
ADDR_05C241:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	STA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
ADDR_05C24D:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_L1ScrollSpr_CurrentState,y
	TAX
	LDA.w SMW_SharedScrollSpriteTables_UNK_05CBC7+$01,x
	AND.w #$00FF
	CPX.b #$01
	BEQ.b ADDR_05C268
	EOR.w #$FFFF
	INC
ADDR_05C268:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDY.b #$00
	CMP.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	BEQ.b ADDR_05C280
	BPL.b ADDR_05C276
	LDY.b #$02
ADDR_05C276:
	LDA.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	CLC
	ADC.w DATA_05CB7B,y
	STA.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
ADDR_05C280:
	JMP.w SMW_Layer2SpecialScrolling04_Unused_ADDR_05C31D
namespace off
endmacro

macro ROUTINE_RT01_SMW_UnusedScrollSpriteRoutine(Address)
namespace SMW_UnusedScrollSpriteRoutine
%InsertMacroAtXPosition(<Address>)

DATA_05CB7B:
	dw $0001,$FFFF,$0001,$FFFF
	dw $0001,$FFFF,$0001,$FFFF
	dw $0001,$FFFF,$0001,$FFFF
	dw $0001,$FFFF,$0004,$FFFC
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UpdateLayerPositionWithScrollSprite(Address)
namespace SMW_UpdateLayerPositionWithScrollSprite
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	AND.w #$00FF
	CLC
	ADC.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	STA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	AND.w #$FF00
	BPL.b +
	ORA.w #$00FF
+:
	XBA
	CLC
	ADC.w !RAM_SMW_Misc_Layer1XPosLo,x
	STA.w !RAM_SMW_Misc_Layer1XPosLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	EOR.w #$FFFF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM08
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_MostlyUnusedScrollSpriteRoutine(Address)
namespace SMW_MostlyUnusedScrollSpriteRoutine
%InsertMacroAtXPosition(<Address>)

Main: ; unreachable
	LDA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex	; \ Unreachable
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w UNK_05C9E5,y
	STA.w !RAM_SMW_L1ScrollSpr_SpriteID
	LDA.w UNK_05C9E7,y
	STA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	BEQ.b ADDR_05BD9E
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
ADDR_05BD9E:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w UNK_05C9E9,y
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	LDA.w SMW_SharedScrollSpriteTables_UNK_05CBC7,y
	AND.w #$00FF
	BEQ.b ADDR_05BDB9
	EOR.w #$FFFF
	INC
ADDR_05BDB9:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	CLC
	ADC.w !RAM_SMW_Misc_Layer1YPosLo,x
	AND.w #$00FF
	STA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_SubYPosLo,x
CODE_05BDC9:
	STZ.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
CODE_05BDCF:
	SEP.b #$20			; A->8
	TXA
	LSR
	LSR
	AND.b #$FF
	TAX
	LDA.b #$FF
	STA.w !RAM_SMW_L1ScrollSpr_Timer,x
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_MostlyUnusedScrollSpriteRoutine(Address)
namespace SMW_MostlyUnusedScrollSpriteRoutine
%InsertMacroAtXPosition(<Address>)

UNK_05C9E5:
	db $00,$01

UNK_05C9E7:
	db $00,$00

UNK_05C9E9:
	db $00,$00,$02,$02,$02,$00,$02,$05
	db $02,$02,$05,$00,$00,$02,$01,$00
	db $03,$02,$03,$04,$03,$01,$00,$01
	db $00,$00,$03,$00,$00,$00,$00
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_RT00_SMW_SharedScrollSpriteTables(Address)
namespace SMW_SharedScrollSpriteTables
%InsertMacroAtXPosition(<Address>)

DATA_05CBC3:
	dw $0001,$FFFF

UNK_05CBC7:
	db $30,$70,$80,$10,$28,$30,$30,$30
	db $30,$14,$02,$30,$30,$30,$30,$70
	db $80,$70,$80,$70,$80,$70,$80,$70
	db $80,$70,$80,$18
namespace off
endmacro

macro DATATABLE_RT01_SMW_SharedScrollSpriteTables(Address)
namespace SMW_SharedScrollSpriteTables
%InsertMacroAtXPosition(<Address>)

DATA_05CBED:
	db $60,$42,$D0,$B2

DATA_05CBF1:
	db $80,$80,$80,$80

DATA_05CBF5:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	db $90,$72,$60,$42,$22,$02,$40,$22
	db $20,$10
else
	; Determines the distance for Layer 2 to scroll when using each variant of
	; the Layer 2 Scroll sprite (sprite EA), outside of the
	; acceleration/deceleration period. In order: Range 12, Range 08, Range 05,
	; Range 06, Range 05 (alternate); each type corresponds to a pair of bytes
	; here. The first byte of each pair is for the first movement, and the
	; second is for every time it moves after that. The data is roughly how
	; much time will be spent scrolling at full speed, not the actual distance,
	; so the scroll speed and acceleration affect this.
	db $90,$72,$60,$42,$20,$10,$40,$22	;!
	db $20,$10
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0E7_SpecialAutoScroll(Address)
namespace SMW_NorSpr0E7_SpecialAutoScroll
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	LDA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w L1AndL2ScrollID,y
	STA.w !RAM_SMW_L1ScrollSpr_SpriteID
	LDA.w L1AndL2ScrollTypeIndex,y
	STA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
Layer2:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	REP.b #$20			; A->16
	STZ.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_SubYPosLo,x
	SEP.b #$20			; A->8
	TXA
	LSR
	LSR
	TAX
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	BEQ.b CODE_05BD6E
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
CODE_05BD6E:
	LDA.w DATA_05CA61,y
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	LDA.w DATA_05CA68,y
	STA.w !RAM_SMW_L1ScrollSpr_Timer,x
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr0E7_SpecialAutoScroll_Main, SMW_NorSpr0E8_SpecialAutoScroll_Main)
endmacro

macro ROUTINE_RT01_SMW_NorSpr0E7_SpecialAutoScroll(Address)
namespace SMW_NorSpr0E7_SpecialAutoScroll
%InsertMacroAtXPosition(<Address>)

L1AndL2ScrollID:
	db $01,$01		; Y = 00 Auto-Scroll 1 (set layer2+FG scroll to none)
	db $01,$00		; Y = 00 Auto-Scroll 2 (set FG scroll to none)
	db $01,$01		; Y = 00 Auto-Scroll 3 (set layer2+FG scroll to none)
	db $01,$00		; Y = 00 Auto-Scroll 4 (set FG scroll to none)
	db $01,$09		; Y = 10 Auto-Scroll 1 (set layer2+FG scroll to none)

L1AndL2ScrollTypeIndex:
	db $01,$00		; Y = 00 Auto-Scroll 1 (set layer2+FG scroll to none)
	db $02,$00		; Y = 00 Auto-Scroll 2 (set FG scroll to none)
	db $04,$03		; Y = 00 Auto-Scroll 3 (set layer2+FG scroll to none)
	db $05,$00		; Y = 00 Auto-Scroll 4 (set FG scroll to none)
	db $06,$00		; Y = 10 Auto-Scroll 1 (set layer2+FG scroll to none)
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr0E7_SpecialAutoScroll(Address)
namespace SMW_NorSpr0E7_SpecialAutoScroll
%InsertMacroAtXPosition(<Address>)

DATA_05CA61:
	db $01,$18,$1E,$29,$2D,$35,$47

DATA_05CA68:
	db $16,$05,$0A,$03,$07,$11,$09
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0E9_Layer2Smash(Address)
namespace SMW_NorSpr0E9_Layer2Smash
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w DATA_05C94F,y						;\ Glitch: Placing this sprite at any height besides #$0000 results in glitched Layer 2 Smash behavior.
	STA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex			;|
	LDA.w DATA_05C952,y						;|
	STA.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex			;/
	REP.b #$20			; A->16
	LDA.w #$0200
	JSR.w SMW_NorSpr0EC_UnusedSprite_CODE_05BFD2
	LDA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	CLC
	ADC.b #$0A
	TAX
	LDY.b #$01
	JSR.w SMW_Layer2SpecialScrolling02_Layer2Smash_CODE_05C95B
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Misc_Layer2YPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	JMP.w SMW_Layer2SpecialScrolling04_Unused_CODE_05C32B		; Optimization: Change to SEP.b #$20 : RTS since that's what this JMP.w leads to.
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0E9_Layer2Smash(Address)
namespace SMW_NorSpr0E9_Layer2Smash
%InsertMacroAtXPosition(<Address>)

DATA_05C94F:
	db $00			; Y = 00 Layer 2 Smash 1
	db $0C			; Y = 00 Layer 2 Smash 2
	db $18			; Y = 00 Layer 2 Smash 3

DATA_05C952:
	db $05			; Y = 00 Layer 2 Smash 1
	db $05			; Y = 00 Layer 2 Smash 2
	db $05			; Y = 00 Layer 2 Smash 3
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0EA_Layer2Scroll(Address)
namespace SMW_NorSpr0EA_Layer2Scroll
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	LDA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w DATA_05CA48,y
	STA.w !RAM_SMW_L1ScrollSpr_SpriteID
	LDA.w DATA_05CA52,y
	STA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
CODE_05BF20:
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	BEQ.b CODE_05BF30
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
CODE_05BF30:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w DirectionToStartMoving,y
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	TAX
	TYA
	ASL
	TAY
	LDA.w SMW_SharedScrollSpriteTables_DATA_05CBF5,y
	AND.w #$00FF
	CPX.b #$01
	BEQ.b CODE_05BF51
	EOR.w #$FFFF
	INC
CODE_05BF51:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	CLC
	ADC.w !RAM_SMW_Misc_Layer1YPosLo,x
	AND.w #$00FF
	STA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_SubYPosLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	JMP.w SMW_MostlyUnusedScrollSpriteRoutine_CODE_05BDCF
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0EA_Layer2Scroll(Address)
namespace SMW_NorSpr0EA_Layer2Scroll
%InsertMacroAtXPosition(<Address>)

DATA_05CA48:
	db $00,$03		; Y = 00 Layer 2 Scroll 1 (set BG init pos=0 if Y=0)
	db $00,$03		; Y = 00 Layer 2 Scroll 2
	db $00,$03		; Y = 00 Layer 2 Scroll 3 
	db $00,$03		; Y = 00 Layer 2 Scroll 4
	db $00,$03		; Y = 10 Layer 2 Scroll 1 (set BG init pos=0 if Y=0)

DATA_05CA52:
	db $00,$00		; Y = 00 Layer 2 Scroll 1 (set BG init pos=0 if Y=0)
	db $00,$01		; Y = 00 Layer 2 Scroll 2
	db $00,$02		; Y = 00 Layer 2 Scroll 3
	db $00,$03		; Y = 00 Layer 2 Scroll 4
	db $00,$04		; Y = 10 Layer 2 Scroll 1 (set BG init pos=0 if Y=0)

; What direction Layer 2 will start out moving when each variant of the
; Layer 2 Scroll sprite (sprite EA) is used. In order: Range 12, Range 08,
; Range 05, Range 06, Range 05 (alternate). 00 -> down, 01 -> up.
DirectionToStartMoving:
	db $01,$00,$00,$00,$00
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0EB_UnusedSprite(Address)
namespace SMW_NorSpr0EB_UnusedSprite
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w DATA_05CA08,y
	STA.w !RAM_SMW_L1ScrollSpr_SpriteID
	LDA.w DATA_05CA0C,y
	STA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
ADDR_05BDF0:
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	BEQ.b ADDR_05BE00
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
ADDR_05BE00:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w DATA_05CA10,y
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	PHA
	TYA
	ASL
	TAY
	LDA.w DATA_05CA12,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	PLA
	TAY
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CPY.b #$01
	BEQ.b ADDR_05BE27
	EOR.w #$FFFF
	INC
ADDR_05BE27:
	CLC
	ADC.w !RAM_SMW_Misc_Layer1YPosLo,x
	STA.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_SubYPosLo,x
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0EB_UnusedSprite(Address)
namespace SMW_NorSpr0EB_UnusedSprite
%InsertMacroAtXPosition(<Address>)

DATA_05CA08:
	db $00,$04,$00,$04

DATA_05CA0C:
	db $00,$00,$00,$01

DATA_05CA10:
	db $00,$01

DATA_05CA12:
	db $40,$01,$E0,$00
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0EC_UnusedSprite(Address)
namespace SMW_NorSpr0EC_UnusedSprite
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	REP.b #$20			; A->16
	STZ.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	STZ.w !RAM_SMW_Misc_Layer2XPosLo
	LDA.w #$03C0
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	STA.w !RAM_SMW_Misc_Layer2YPosLo
	STZ.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w #$0005
CODE_05BFD2:
	STZ.w !RAM_SMW_L1ScrollSpr_Timer
CODE_05BFD5:
	STZ.w !RAM_SMW_L1ScrollSpr_CurrentState
	STA.w !RAM_SMW_L1ScrollSpr_SpriteID
	STZ.w !RAM_SMW_L1ScrollSpr_XSpeedLo
	STZ.w !RAM_SMW_L1ScrollSpr_YSpeedLo
	STZ.w !RAM_SMW_L1ScrollSpr_SubXPosLo
	STZ.w !RAM_SMW_L1ScrollSpr_SubYPosLo
	STZ.w !RAM_SMW_L2ScrollSpr_XSpeedLo
	STZ.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	STZ.w !RAM_SMW_L2ScrollSpr_SubXPosLo
	STZ.w !RAM_SMW_L2ScrollSpr_SubYPosLo
	SEP.b #$20			; A->8
Return05BFF5:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr0EC_UnusedSprite_Return05BFF5, SMW_Layer1SpecialScrolling07_DoNothing_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0EC_UnusedSprite_Return05BFF5, SMW_Layer2SpecialScrolling07_DoNothing_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0ED_Layer2Falls(Address)
namespace SMW_NorSpr0ED_Layer2Falls
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	REP.b #$20			; A->16
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STZ.w !RAM_SMW_Misc_Layer1XPosLo
	STZ.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	STZ.w !RAM_SMW_Misc_Layer2XPosLo
	LDA.w #$0600
	STA.w !RAM_SMW_L1ScrollSpr_SpriteID
	STZ.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	STZ.w !RAM_SMW_L2ScrollSpr_SubYPosLo
	SEP.b #$20			; A->8
	LDA.b #$60
	STA.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0EF_Layer2ScrollSOrL(Address)
namespace SMW_NorSpr0EF_Layer2ScrollSOrL
%InsertMacroAtXPosition(<Address>)

; [9C 11 14] Change this to EA EA EA to make Layer 2 Sideways Scroll not
; disable horizontal scroll.
Main:
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	LDA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w DATA_05CA3E,y
	STA.w !RAM_SMW_L1ScrollSpr_SpriteID
	LDA.w DATA_05CA42,y
	STA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STZ.w !RAM_SMW_Misc_Layer1XPosLo
	STZ.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	STZ.w !RAM_SMW_Misc_Layer2XPosLo
CODE_05BEC6:
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	BEQ.b CODE_05BED6
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
CODE_05BED6:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w DATA_05CA46,y
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	TAX
	TYA
	ASL
	TAY
	LDA.w SMW_SharedScrollSpriteTables_DATA_05CBED,y
	AND.w #$00FF
	CPX.b #$01
	BEQ.b CODE_05BEF7
	EOR.w #$FFFF
	INC
CODE_05BEF7:
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	CLC
	ADC.w !RAM_SMW_Misc_Layer1XPosLo,x
	AND.w #$00FF
	STA.w !RAM_SMW_L1ScrollSpr_SubYPosLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	JMP.w SMW_MostlyUnusedScrollSpriteRoutine_CODE_05BDC9
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0EF_Layer2ScrollSOrL(Address)
namespace SMW_NorSpr0EF_Layer2ScrollSOrL
%InsertMacroAtXPosition(<Address>)

DATA_05CA3E:
	db $00,$08,$00,$08

DATA_05CA42:
	db $00,$00,$00,$01

DATA_05CA46:
	db $01,$01
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0F1_UnusedSprite(Address)
namespace SMW_NorSpr0F1_UnusedSprite
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w DATA_05CA16,y
	STA.w !RAM_SMW_L1ScrollSpr_SpriteID
	LDA.w DATA_05CA1E,y
	STA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
ADDR_05BE4D:
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	BEQ.b ADDR_05BE5D
	LDY.w !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
ADDR_05BE5D:
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w DATA_05CA26,y
	STA.w !RAM_SMW_L1ScrollSpr_CurrentState,x
	TAY
	LDX.w !RAM_SMW_ScrollSpr_LayerIndex
	LDA.w #$0F17
	CPY.b #$01
	BEQ.b ADDR_05BE7B
	EOR.w #$FFFF
	INC
ADDR_05BE7B:
	STA.w !RAM_SMW_L1ScrollSpr_SubYPosLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_XSpeedLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_YSpeedLo,x
	STZ.w !RAM_SMW_L1ScrollSpr_SubXPosLo,x
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0F1_UnusedSprite(Address)
namespace SMW_NorSpr0F1_UnusedSprite
%InsertMacroAtXPosition(<Address>)

DATA_05CA16:
	db $05,$00
	db $00,$05
	db $05,$02
	db $02,$05

DATA_05CA1E:
	db $00,$00
	db $00,$01
	db $02,$03
	db $04,$03

DATA_05CA26:
	db $01,$00,$01,$01,$00,$06,$00,$06
	db $00,$00,$00,$01,$00,$01,$08,$00
	db $00,$08,$00,$00,$00,$01,$01,$00
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0F2_Layer2OnOffControlled(Address)
namespace SMW_NorSpr0F2_Layer2OnOffControlled
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$20			; A->16
	LDA.w #$0B00
	BRA.b SMW_NorSpr0EC_UnusedSprite_CODE_05BFD2
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0F3_RegularAutoScroll(Address)
namespace SMW_NorSpr0F3_RegularAutoScroll
%InsertMacroAtXPosition(<Address>)

DATA_05BFFD:
	db $00,$00
	db $02,$00

MaxXSpeed:
	dw $0080
	dw $0100

Main:
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	LDA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w DATA_05BFFD,y
	STA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w #$000C
	BRA.b SMW_NorSpr0EC_UnusedSprite_CODE_05BFD2
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0F4_FastBGScroll(Address)
namespace SMW_NorSpr0F4_FastBGScroll
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$20			; A->16
	LDA.w #$0D00
	JSR.w SMW_NorSpr0EC_UnusedSprite_CODE_05BFD2
CODE_05C022:
	STZ.w !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting
	REP.b #$20			; A->16
	STZ.w !RAM_SMW_L2ScrollSpr_XSpeedLo
	STZ.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	STZ.w !RAM_SMW_L2ScrollSpr_SubXPosLo
	STZ.w !RAM_SMW_L2ScrollSpr_SubYPosLo
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0F5_Layer2ScrollWhenTouched(Address)
namespace SMW_NorSpr0F5_Layer2ScrollWhenTouched
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	LDA.w DATA_05C808,y
	STA.w !RAM_SMW_L1ScrollSpr_Timer
	LDA.w DATA_05C80B,y
	STA.w !RAM_SMW_L2ScrollSpr_Timer
	REP.b #$20			; A->16
	LDA.w #$0E00
	JMP.w SMW_NorSpr0EC_UnusedSprite_CODE_05BFD5
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0F5_Layer2ScrollWhenTouched(Address)
namespace SMW_NorSpr0F5_Layer2ScrollWhenTouched
%InsertMacroAtXPosition(<Address>)

DATA_05C808:
	db $00,$06,$08

DATA_05C80B:
	db $03,$01,$02
namespace off
endmacro

macro INLINEDATATABLE_RT19_SMW_EmptySpace(Address)
!SMW_UBytes = $01E7 : !SMW_JBytes = $01E7 : !SMW_E1Bytes = $01E7 : !SMW_E2Bytes = $01C2 : !SMASW_UBytes = $01E7 : !SMASW_EBytes = $01C2 : !SMW_ARCADEBytes = $01E7
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 19)
endmacro

macro INLINEDATATABLE_RT20_SMW_EmptySpace(Address)
!SMW_UBytes = $1E : !SMW_JBytes = $1E : !SMW_E1Bytes = $1E : !SMW_E2Bytes = $1E : !SMASW_UBytes = $1E : !SMASW_EBytes = $1E : !SMW_ARCADEBytes = $1E
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 20)
endmacro

macro INLINEDATATABLE_RT21_SMW_EmptySpace(Address)
!SMW_UBytes = $5A : !SMW_JBytes = $048A : !SMW_E1Bytes = $5A : !SMW_E2Bytes = $4A : !SMASW_UBytes = $50 : !SMASW_EBytes = $40 : !SMW_ARCADEBytes = $84
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 21)
endmacro

macro INLINEDATATABLE_RT22_SMW_EmptySpace(Address)
!SMW_UBytes = $16 : !SMW_JBytes = $0114 : !SMW_E1Bytes = $16 : !SMW_E2Bytes = $16 : !SMASW_UBytes = $16 : !SMASW_EBytes = $16 : !SMW_ARCADEBytes = $16
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 22)
endmacro

macro INLINEDATATABLE_RT23_SMW_EmptySpace(Address)
!SMW_UBytes = $A0 : !SMW_JBytes = $A0 : !SMW_E1Bytes = $A0 : !SMW_E2Bytes = $A0 : !SMASW_UBytes = $A0 : !SMASW_EBytes = $A0 : !SMW_ARCADEBytes = $A0
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 23)
endmacro

macro INLINEDATATABLE_RT24_SMW_EmptySpace(Address)

; LM: Lunar Magic inserts some custom routines here:
; $05DC50 - Routine that checks whether a screen exit is a SMW one or a LM modified one.
; $05DC80 - Routine that reads from SecondaryEntrance4 or its expanded version
; $05DC85 - Routine that reads from a custom level data table
; $05DC8A - Routine that reads from another custom level data table
; $05DCB0 - Routine that allows a level to trigger secret exit 2 and 3?
; $05DCD0 - Routine that removes the restriction for whether a main map or submap level can access a level from the first/second half of the level table respectively.
; $05DD00 - Routine that sets !RAM_SMW_Flag_UnderwaterLevel and !RAM_SMW_Flag_IceLevel based on !RAM_SMW_Misc_LevelHeaderEntranceSettings
; $05DD30 - Routine that indexes $05DE00, $06FC00, $06FE00, and sets the player position from a main entrance using method 2
; $05DD80 - Routine for initializing the overworld level flags
; $05DDA0 - Pre 2.53+ overworld expansion hijack - Initial level flags table
;           Post 2.53+ overworld expansion hijack - Empty
; $05DE00 - Secondary Entrance table. LWPYX---
;           L = Slippery flag
;           W = Water Flag
;           P = Flag to use X/Y position method 2
;           Y = Bit 5 of the Y position, for method 2
;           X = Bit 4 of the X position, for method 2
;           (X/Y are switched in vertical levels)
!SMW_UBytes = $03BA : !SMW_JBytes = $03BA : !SMW_E1Bytes = $03BA : !SMW_E2Bytes = $03BA : !SMASW_UBytes = $03BA : !SMASW_EBytes = $03BA : !SMW_ARCADEBytes = $03BA
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 24)
endmacro
