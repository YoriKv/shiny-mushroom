;####################################################################
;# Bank06.asm -- level data.
;#
;# 9 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank06Macros(StartBank, EndBank)
%BANK_START(<StartBank>)
DATATABLE_RT00_SMW_LevelData:	%DATATABLE_RT00_SMW_LevelData(NULLROM)						; $068000
INLINEDATATABLE_RT25_SMW_EmptySpace:	%INLINEDATATABLE_RT25_SMW_EmptySpace(NULLROM)					; $06A5B9
DATATABLE_RT01_SMW_LevelData:	%DATATABLE_RT01_SMW_LevelData(NULLROM)						; $06A600
INLINEDATATABLE_RT26_SMW_EmptySpace:	%INLINEDATATABLE_RT26_SMW_EmptySpace(NULLROM)					; $06C964
DATATABLE_RT02_SMW_LevelData:	%DATATABLE_RT02_SMW_LevelData(NULLROM)						; $06D000
INLINEDATATABLE_RT27_SMW_EmptySpace:	%INLINEDATATABLE_RT27_SMW_EmptySpace(NULLROM)				; $06F539
if ver_is_smasw_europe(!Define_Global_ROMToAssemble)
ROUTINE_RT03_SMW_UploadPlayerGFX:	%ROUTINE_RT03_SMW_UploadPlayerGFX(NULLROM)					; N/A
INLINEDATATABLE_RT28_SMW_EmptySpace:	%INLINEDATATABLE_RT28_SMW_EmptySpace(NULLROM)					; N/A
endif
%BANK_END(<EndBank>)
endmacro

macro ROUTINE_RT03_SMW_UploadPlayerGFX(Address)				; Note: This is a SMAS (PAL) exclusive routine macro
namespace SMW_UploadPlayerGFX
%InsertMacroAtXPosition(<Address>)

MarioAndLuigi:
	REP.b #$20
	LDA.w !RAM_SMW_Player_CurrentCharacter
	AND.w #$00FF
	BEQ.b CODE_36F613
	LDA.w #LuigiGFX&$8000
	LDX.b #LuigiGFX>>16
	STX.b !RAM_SMW_Misc_ScratchRAM02
	BRA.b CODE_36F617

CODE_36F613:
	LDX.b #!RAM_SMW_Graphics_DecompressedGFX32>>16
	STX.b !RAM_SMW_Misc_ScratchRAM02

CODE_36F617:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b #$04
	LDY.w !RAM_SMW_Player_NumberOfTilesToUpdate
	BEQ.b CODE_36F63F
	LDY.b #!CGRAM_SMW_DynamicPlayerPalette
	STY.w !REGISTER_CGRAMAddress
	LDA.w #((!REGISTER_WriteToCGRAMPort&$0000FF)<<8)+$00
	STA.w DMA[$02].Parameters
	LDA.w !RAM_SMW_Pointer_PlayerPaletteLo
	STA.w DMA[$02].SourceLo
	LDY.b #$30
	STY.w DMA[$02].SourceBank
	LDA.w #$0014
	STA.w DMA[$02].SizeLo
	STX.w !REGISTER_DMAEnable

CODE_36F63F:
	LDY.b #$80
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w #((!REGISTER_WriteToVRAMPortLo&$0000FF)<<8)+$01
	STA.w DMA[$02].Parameters
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$07F0
	STA.w !REGISTER_VRAMAddressLo
	LDA.w !RAM_SMW_Graphics_DynamicSpriteTile7FLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w DMA[$02].SourceLo
	LDY.b !RAM_SMW_Misc_ScratchRAM02
	STY.w DMA[$02].SourceBank
	LDA.w #$0020
	STA.w DMA[$02].SizeLo
	STX.w !REGISTER_DMAEnable
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo
	STA.w !REGISTER_VRAMAddressLo
	LDY.b #$00

CODE_36F66F:
	LDA.w SMW_DynamicSpritePointersTop[$00].LowByte,y
	LDX.w !RAM_SMW_Player_CurrentCharacter
	BEQ.b CODE_36F681
	CPY.b #$04
	BCS.b CODE_36F681
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b #LuigiGFX>>16
	BRA.b CODE_36F683

CODE_36F681:
	LDX.b #!RAM_SMW_Graphics_DecompressedGFX32>>16

CODE_36F683:
	STX.w DMA[$02].SourceBank
	STA.w DMA[$02].SourceLo
	LDA.w #$0040
	STA.w DMA[$02].SizeLo
	LDX.b #$04
	STX.w !REGISTER_DMAEnable
	INY
	INY
	CPY.w !RAM_SMW_Player_NumberOfTilesToUpdate
	BCC.b CODE_36F66F
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$0100
	STA.w !REGISTER_VRAMAddressLo
	LDY.b #$00

CODE_36F6A3:
	LDA.w SMW_DynamicSpritePointersBottom[$00].LowByte,y
	LDX.w !RAM_SMW_Player_CurrentCharacter
	BEQ.b CODE_36F6B5
	CPY.b #$04
	BCS.b CODE_36F6B5
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b #LuigiGFX>>16
	BRA.b CODE_36F6B7

CODE_36F6B5:
	LDX.b #!RAM_SMW_Graphics_DecompressedGFX32>>16

CODE_36F6B7:
	STX.w DMA[$02].SourceBank
	STA.w DMA[$02].SourceLo
	LDA.w #$0040
	STA.w DMA[$02].SizeLo
	LDX.b #$04
	STX.w !REGISTER_DMAEnable
	INY
	INY
	CPY.w !RAM_SMW_Player_NumberOfTilesToUpdate
	BCC.b CODE_36F6A3
	SEP.b #$20
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_RT00_SMW_LevelData(Address)
namespace SMW
%SMW_ManagedLevelSlot(<Address>)

; LM: These MWLs are a bit different from what you'd normally extract from a clean SMW ROM. This is because Lunar Magic will actually modify the original level data during the extraction process to comply with certain ASM hacks it makes:
; - Extended Object 00 (Screen Exit) - Changes one of the bytes to store the exit properties.
; - Extended Object 01 (Screen Jump) - Removes

	%SMW_InsertLevelData(LEVEL_L1_Test, Level025_TestLevel, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_RideAmongTheCloudsL1, UnusedLevel_RideAmongTheClouds, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_MushroomScalesL1, UnusedLevel_MushroomScales, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_BossTestL1, UnusedLevel_BossTest, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_09B, Level09B_BowserBattle, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_095, Level095_ReznorBattle, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_096, Level096_LarryBattle, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_LavaCaveL2, UnusedLevel_LavaCave, SMW_U, LAYER_2)
	%SMW_InsertLevelData(UnusedLevelData_LavaCaveL1, UnusedLevel_LavaCave, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_FollowTestL1, UnusedLevel_FollowTest, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_OldWendysCastleL1, UnusedLevel_OldWendysCastle, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_OldWendysCastleL2, UnusedLevel_OldWendysCastle, SMW_U, LAYER_2)
	%SMW_InsertLevelData(UnusedLevelData_GhostGroundL1, UnusedLevel_GhostHouseGround, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_093, Level093_LemmyBattle, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_094, Level094_WendyBattle, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0C7, Level0C7_TitleScreen, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0C5, Level0C5_IntroLevel, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_0C4, Level0C4_UnusedGhostHouseExit, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_0EB, Level0EB_DonutGhostHouse_NormalExit, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0CC, Level0CC_RoyBattle, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0FF, Level0FF_DonutPlains2_NormalExit, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_000, Level000_BonusGame, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_GhostHouseExitL1, UnusedLevel_GhostHouseExit1, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1EB, 1EB, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_014, 014, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_11B, 11B, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_121, 121, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_008, 008, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0CA, 0CA, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1D8, 1D8, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1D7, 1D7, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0C9, 0C9, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_003, 003, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_105, 105, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1CB, 1CB, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_106, 106, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1CA, 1CA, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_103, 103, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1FD, 1FD, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_102, 102, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1FF, 1FF, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1BE, Level1BE_YoshisIsland4_SideArea, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_101, 101, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1FC, 1FC, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_015, 015, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0FD, 0FD, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0E3, 0E3, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_009, Level009_DonutPlains2_Main, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_009, Level009_DonutPlains2_Main, SMW_J, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0E9, 0E9, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_004, 004, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0FA, 0FA, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0DE, 0DE, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0FE, 0FE, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0C4, Level0C4_UnusedGhostHouseExit, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_005, 005, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0F4, 0F4, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_006, 006, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0D2, 0D2, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0C3, 0C3, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_007, 007, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0E8, 0E8, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_0E7, 0E7, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_0E7, 0E7, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0E6, 0E6, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_00A, 00A, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0C2, 0C2, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_013, Level013_DonutSecretHouse_Main, SMW_J, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0ED, Level0ED_DonutSecretHouse_SecondRoom, SMW_J, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0F1, 0F1, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0E4, 0E4, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_10B, 10B, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1C6, 1C6, SMW_U, LAYER_1)
namespace off
endmacro

macro DATATABLE_RT01_SMW_LevelData(Address)
namespace SMW
%SMW_ManagedLevelSlot(<Address>)

	%SMW_InsertLevelData(LEVEL_L1_11A, Level11A_VanillaDome1_Main, SMW_J, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1EF, 1EF, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_1EF, 1EF, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_118, 118, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1C3, 1C3, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_107, 107, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1EA, 1EA, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_10A, 10A, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1C2, 1C2, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1F7, 1F7, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_119, 119, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1F5, 1F5, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_11C, Level11C_LemmysCastle_Main, SMW_J, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1F4, 1F4, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1F3, 1F3, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_1F3, 1F3, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_1F2, 1F2, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_109, 109, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1F1, 1F1, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1F0, 1F0, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_001, 001, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0D8, 0D8, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_002, 002, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0CB, 0CB, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_00B, 00B, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0E0, 0E0, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_00F, 00F, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0BF, 0BF, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_010, 010, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0C1, 0C1, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_00E, 00E, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_00E, 00E, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_0DC, 0DC, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_0DC, 0DC, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_0DB, 0DB, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0DA, 0DA, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_011, 011, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0C6, 0C6, SMW_U, LAYER_1)
namespace off
endmacro

macro DATATABLE_RT02_SMW_LevelData(Address)
namespace SMW
%SMW_ManagedLevelSlot(<Address>)

	%SMW_InsertLevelData(LEVEL_L1_00C, 00C, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0F3, 0F3, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_00D, 00D, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0DD, 0DD, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_11E, 11E, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_120, 120, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_123, 123, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1F8, 1F8, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1BC, 1BC, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_020, 020, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_11D, 11D, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_11D, 11D, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_1FA, 1FA, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1E6, 1E6, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_11F, 11F, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1DF, 1DF, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1C1, 1C1, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_122, 122, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_01F, 01F, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0D6, 0D6, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_022, 022, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0F5, 0F5, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0BE, 0BE, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_021, 021, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0FC, 0FC, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_024, 024, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0CF, 0CF, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_024_1, Level0CF_ChocolateIsland2_Rexes, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_024_2, Level0CF_ChocolateIsland2_Slopes, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0CE, 0CE, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_024_3, Level0CE_ChocolateIsland2_Dinos, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_024_4, Level0CE_ChocolateIsland2_SecretExit, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0CD, 0CD, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_024_5, Level0CD_ChocolateIsland2_NormalExit, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_023, Level023_ChocolateIsland3_Main, SMW_J, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0D7, 0D7, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_01B, 01B, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0EF, 0EF, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_117, 117, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1ED, 1ED, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1EC, 1EC, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_1EC, 1EC, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_1EE, 1EE, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1C0, 1C0, SMW_U, LAYER_1)
namespace off
endmacro

macro INLINEDATATABLE_RT25_SMW_EmptySpace(Address)
!SMW_UBytes = $47 : !SMW_JBytes = $4A : !SMW_E1Bytes = $47 : !SMW_E2Bytes = $47 : !SMASW_UBytes = $47 : !SMASW_EBytes = $47 : !SMW_ARCADEBytes = $47
	
if !Define_SMW_ManagedLevelMemory == !TRUE
	; Inside a managed run: the level streams own these bytes.
else
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 25)
endif
endmacro

macro INLINEDATATABLE_RT26_SMW_EmptySpace(Address)
!SMW_UBytes = $069C : !SMW_JBytes = $069F : !SMW_E1Bytes = $069C : !SMW_E2Bytes = $069C : !SMASW_UBytes = $069C : !SMASW_EBytes = $069C : !SMW_ARCADEBytes = $069C
	
if !Define_SMW_ManagedLevelMemory == !TRUE
	; Inside a managed run: the level streams own these bytes.
else
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 26)
endif
endmacro

macro INLINEDATATABLE_RT27_SMW_EmptySpace(Address)

; LM: Lunar Magic inserts some custom code here:
; $06F540 - Routine that gets the FG map16 page number of a tile
; $06F5D0 - Routine that allows custom map16 to work for tiles modified through "SMW_GenerateTile"
; $06F5E4 - Routine that allows custom map16 to work in submap switching.
; $06F600 - Routine for getting the acts like setting for a map16 tile
; $06F660 - Routine for running custom block code for Mario's offsets
; $06F700 - Routine for running custom block code for sprite offsets
; $06F760 - Routine for running custom block code for the cape offset
; $06F7A0 - Routine for running custom block code for the fireball offset
; $06FC00 - Extra Secondary Level Header data 1
; $06FE00 - Extra Secondary Level Header data 2
!SMW_UBytes = $0AC7 : !SMW_JBytes = $0ACD : !SMW_E1Bytes = $0AC7 : !SMW_E2Bytes = $0AC7 : !SMASW_UBytes = $0AC7 : !SMASW_EBytes = $C7 : !SMW_ARCADEBytes = $0AC7
	
if !Define_SMW_ManagedLevelMemory == !TRUE
	; Inside a managed run: the level streams own these bytes.
else
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 27)
endif
endmacro

macro INLINEDATATABLE_RT28_SMW_EmptySpace(Address)				; Note: This is a SMAS (PAL) exclusive routine macro
%InsertMacroAtXPosition(<Address>)
!SMW_UBytes = $00 : !SMW_JBytes = $00 : !SMW_E1Bytes = $00 : !SMW_E2Bytes = $00 : !SMASW_UBytes = $00 : !SMASW_EBytes = $092E : !SMW_ARCADEBytes = $00

	%SMW_InsertOriginalFreespace(!ROMID, 28)
endmacro
