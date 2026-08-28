;####################################################################
;# Bank0F.asm -- end-of-ROM freespace.
;#
;# 3 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank0FMacros(StartBank, EndBank)
%BANK_START(<StartBank>)
ROUTINE_RT03_SMW_HandleSPCUploads:	%ROUTINE_RT03_SMW_HandleSPCUploads(NULLROM)					; $0F8000
INLINEDATATABLE_RT46_SMW_EmptySpace:	%INLINEDATATABLE_RT46_SMW_EmptySpace(NULLROM)					; $0FEF90
%BANK_END(<EndBank>)
endmacro

macro ROUTINE_RT03_SMW_HandleSPCUploads(Address)
namespace SMW_HandleSPCUploads
%InsertMacroAtXPosition(<Address>)

; Instrument data.
SPC700Samples:
	incbin "SPC700/samples.bin"
namespace off
endmacro

macro INLINEDATATABLE_RT46_SMW_EmptySpace(Address)
%InsertMacroAtXPosition(<Address>)

if ver_is_smasw(!Define_Global_ROMToAssemble) == 0
;garbage
dw $0018
fillbyte $00	:	fill 18
endif

; LM: Lunar Magic inserts a lot of custom routines here.
; $0FEFA0 - Table used to maintain the ROM checksum
; $0FF0A0 - Ascii text stating the latest LM version used on the ROM and a link to FuSoYa's website
; $0FF160 - Routine used to load FG/BG/Sprite graphics with the Old GFX Bypass (if SuperGFXBypass is not enabled).
; $0FF200 - Old GFX Bypass list data
; $0FF600 - 24-bit pointers to ExGFX 080-0FF
; $0FF780 - Routine that loads the AN2 GFX file with the old GFX Bypass (if SuperGFXBypass is not enabled). Also calls the routines for handling loading the layer 3 GFX/Tilemap
; $0FF7D0 - Unknown routine (Perhaps FuSoYa intended layer 2 BGs to be loaded with ExGFX at some point?)
; $0FF7F0 - Routine for loading the level SuperGFXBypass table.
; $0FF840 - Routine that checks if SuperGFXBypass is enabled and if so, load a GFX/ExGFX file
; $0FF8A0 - Routine that reads from the Old GFX Bypass list table
; $0FF8B8 - Routine that sets the GFX decompression location when using Old GFX Bypass
; $0FF8CB - Routine that sets the GFX decompression location when using SuperGFXBypass
; $0FF900 - Routine for specifying what graphics file to decompress
; $0FF9C0 - Routine that loads the layer 3 GFX files in cutscenes
; $0FF9E0 - Routine that loads the layer 3 GFX files
; $0FFAB0 - Routine for loading the overworld SuperGFXBypass table.
; $0FFAF0 - Routine that forces the overworld to reload when both players are on different submaps (2.30+)
; $0FFB20 - Routine that reloads aspects of the overworld when touching a path exit.
; $0FFD80 - Routine that loads a custom layer 3 tilemap and settings
; $0FFFE7 - Saved ROM settings
;	; Byte 1-4 = Unknown
;	; Byte 5 = Compression Setting
;	; Byte 6 = Unknown
;	; Byte 7-8 = Use FastROM addressing?
;	; Byte 9 = FastROM patch setting?
;	; Bytes 10-25 = Unknown
!SMW_UBytes = $1070 : !SMW_JBytes = $1070 : !SMW_E1Bytes = $1070 : !SMW_E2Bytes = $1070 : !SMASW_UBytes = $1084 : !SMASW_EBytes = $1084 : !SMW_ARCADEBytes = $1070
	
	%SMW_InsertOriginalFreespace(!ROMID, 46)
endmacro
