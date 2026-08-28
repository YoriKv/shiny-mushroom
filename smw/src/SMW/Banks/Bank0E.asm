;####################################################################
;# Bank0E.asm -- sound engine and sample data.
;#
;# 3 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank0EMacros(StartBank, EndBank)
%BANK_START(<StartBank>)
ROUTINE_RT02_SMW_HandleSPCUploads:	%ROUTINE_RT02_SMW_HandleSPCUploads(NULLROM)					; $0E8000
INLINEDATATABLE_RT45_SMW_EmptySpace:	%INLINEDATATABLE_RT45_SMW_EmptySpace(NULLROM)					; $0EF0F0
%BANK_END(<EndBank>)
endmacro

macro ROUTINE_RT02_SMW_HandleSPCUploads(Address)
namespace SMW_HandleSPCUploads
%InsertMacroAtXPosition(<Address>)

SPC700Engine:
	incbin "SPC700/Engine.bin"
OverworldMusicBank:
	incbin "SPC700/overworld_music.bin"
LevelMusicBank:
	incbin "SPC700/level_music.bin"
namespace off
endmacro

macro INLINEDATATABLE_RT45_SMW_EmptySpace(Address)
%InsertMacroAtXPosition(<Address>)
;garbage
if !Define_Global_ROMToAssemble&(!ROM_SMW_J|!ROM_SMASW_U|!ROM_SMASW_E) != $00
	if ver_is_japanese(!Define_Global_ROMToAssemble)
		dw $0098
	else
		dw $0077
	endif
	db $00,$00,$00
	dw $FF01
	db $00,$00,$00,$00,$00,$00
else
	dw $00E0			;!
	fillbyte $00	:	fill 19
endif

; LM: Lunar Magic inserts a lot of custom routines here.
; $0EF100 - Bank bytes for the sprite list pointers
; $0EF300 - Routine for setting the bank byte of the sprite list pointer.
; $0EF30C - 24-bit pointer to the custom sprite list size table
; $0EF310 - Level Layer 2 flags. bbBB-LD-
;           D = What type of data the layer 2 is: object (0) or tilemap (1)
;           L = Flag to indicate usage of the high nibble
;           BB = When L is set: Map16 bank to use for the BG
;           bbBB = When L is clear, used as the high byte for all BG Map16 tiles (deprecated?)
;           -- = Unused
; $0EF510 - Routine for handling the layer 2 flags
; $0EF550 - Routine that sets !LMRAM_Misc_CurrentLevelMinusOneLo
; $0EF55D - 24-bit pointer to the overworld custom sprite data.
; $0EF560 - Routine that initializes a couple level RAM addresses.
; $0EF570 - Routine that loads custom level palettes.
; $0EF600 - 24-bit custom level palette pointers
; $0EFC00 - Routine that converts 4BPP graphics into 3BPP. Used by the loading letters and the mode 7 tilemaps (aside from the Iggy/Larry platform)
; $0EFC50 - Routine that backs up the contents of $7EB900 to $7E2000 (Called during the enemy rollcall)
; $0EFC80 - Routine that restores the contents of $7EB900 from $7E2000 (Called during the enemy rollcall)
; $0EFD00 - Routine for handling the Background map16 pages.
; $0EFD50 - 24-bit Background map16 pointers
!SMW_UBytes = $0F10 : !SMW_JBytes = $0F00 : !SMW_E1Bytes = $0F10 : !SMW_E2Bytes = $0F10 : !SMASW_UBytes = $0EE0 : !SMASW_EBytes = $0EE0 : !SMW_ARCADEBytes = $0F10
	
	%SMW_InsertOriginalFreespace(!ROMID, 45)
endmacro
