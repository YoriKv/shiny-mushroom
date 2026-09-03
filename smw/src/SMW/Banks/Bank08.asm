;####################################################################
;# Bank08.asm -- compressed graphics (spans banks $08-$0B).
;#
;# 3 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank08Macros(StartBank, EndBank)
%BANK_START(<StartBank>)
DATATABLE_SMW_CompressedGraphics:	%DATATABLE_SMW_CompressedGraphics(NULLROM)					; $088000 (GFX32)
										; $08BFC0 (GFX33)
										; $08D9F9 (GFX00)
										; $08E231 (GFX01)
										; $08ECBB (GFX02)
										; $08F552 (GFX03)
										; $08FF7D (GFX04)
										; $098963 (GFX05)
										; $09936C (GFX06)
										; $099D10 (GFX07)
										; $09A657 (GFX08)
										; $09AFA1 (GFX09)
										; $09BA15 (GFX0A)
										; $09C39C (GFX0B)
										; $09CD63 (GFX0C)
										; $09D5D2 (GFX0D)
										; $09DDCB (GFX0E)
										; $09E6E5 (GFX0F)
										; $09EF1E (GFX10)
										; $09F7AF (GFX11)
										; $09FFBD (GFX12)
										; $0A8910 (GFX13)
										; $0A9348 (GFX14)
										; $0A9AE8 (GFX15)
										; $0AA374 (GFX16)
										; $0AA9B4 (GFX17)
										; $0AB2AD (GFX18)
										; $0ABBE4 (GFX19)
										; $0AC380 (GFX1A)
										; $0ACC66 (GFX1B)
										; $0AD47E (GFX1C)
										; $0ADC88 (GFX1D)
										; $0AE67F (GFX1E)
										; $0AEE43 (GFX1F)
										; $0AF6A1 (GFX20)
										; $0AFF65 (GFX21)
										; $0B88CD (GFX22)
										; $0B91CA (GFX23)
										; $0B9AE5 (GFX24)
										; $0BA3B5 (GFX25)
										; $0BAE21 (GFX26)
										; $0BB744 (GFX27)
										; $0BC06C (GFX28)
										; $0BC6A3 (GFX29)
										; $0BCB7B (GFX2A)
										; $0BD0F0 (GFX2B)
										; $0BD7B9 (GFX2C)
										; $0BE006 (GFX2D)
										; $0BE936 (GFX2E)
										; $0BF185 (GFX2F)
										; $0BF3BB (GFX30)
										; $0BF800 (GFX31)
INLINEDATATABLE_RT34_SMW_EmptySpace:	%INLINEDATATABLE_RT34_SMW_EmptySpace(NULLROM)					; $0BFD0D
%BANK_END(<EndBank>)
endmacro

;---------------------------------------------------------------------------

;Credit: Cut Man gave me a decompressed version of GFX27, since the tool that usually does that doesn't work for me.

;The graphics run straight through the bank boundaries, so the crossing check is
;off for the length of the table and restored after it. It is restored with
;`full` and not `on` -- they mean the same thing, but `on` is deprecated, and in
;asar 1.91 it is also a silent no-op: it warns and never clears the flag, so
;every bank after this one would keep wrapping its position and the end guard
;of each would fail. See docs/smw/building.md.
; Under !Define_SMW_ManagedGraphicsMemory the placement is the first run of
; a packing instead, emitted from the tail of the ROM map: at this line the
; macro emits nothing, and invoked again from there each file is fitted
; before its label is placed, one that would run past bank $0B is placed
; in the graphics bank, and the fill behind the files emits nothing --
; Config/ManagedGraphicsMemory.asm.
macro DATATABLE_SMW_CompressedGraphics(Address)
check bankcross off
%InsertMacroAtXPosition(<Address>)
%SMW_ManagedGraphicsSlot()

	%SMW_INCGFX(GFX32)	:	%SMW_INCGFX(GFX33)	:	%SMW_INCGFX(GFX00)	:	%SMW_INCGFX(GFX01)
	%SMW_INCGFX(GFX02)	:	%SMW_INCGFX(GFX03)	:	%SMW_INCGFX(GFX04)	:	%SMW_INCGFX(GFX05)
	%SMW_INCGFX(GFX06)	:	%SMW_INCGFX(GFX07)	:	%SMW_INCGFX(GFX08)	:	%SMW_INCGFX(GFX09)
	%SMW_INCGFX(GFX0A)	:	%SMW_INCGFX(GFX0B)	:	%SMW_INCGFX(GFX0C)	:	%SMW_INCGFX(GFX0D)
	%SMW_INCGFX(GFX0E)	:	%SMW_INCGFX(GFX0F)	:	%SMW_INCGFX(GFX10)	:	%SMW_INCGFX(GFX11)
	%SMW_INCGFX(GFX12)	:	%SMW_INCGFX(GFX13)	:	%SMW_INCGFX(GFX14)	:	%SMW_INCGFX(GFX15)
	%SMW_INCGFX(GFX16)	:	%SMW_INCGFX(GFX17)	:	%SMW_INCGFX(GFX18)	:	%SMW_INCGFX(GFX19)
	%SMW_INCGFX(GFX1A)	:	%SMW_INCGFX(GFX1B)	:	%SMW_INCGFX(GFX1C)	:	%SMW_INCGFX(GFX1D)
	%SMW_INCGFX(GFX1E)	:	%SMW_INCGFX(GFX1F)	:	%SMW_INCGFX(GFX20)	:	%SMW_INCGFX(GFX21)
	%SMW_INCGFX(GFX22)	:	%SMW_INCGFX(GFX23)	:	%SMW_INCGFX(GFX24)	:	%SMW_INCGFX(GFX25)
	%SMW_INCGFX(GFX26)	:	%SMW_INCGFX(GFX27)	:	%SMW_INCGFX(GFX28)	:	%SMW_INCGFX(GFX29)
	%SMW_INCGFX(GFX2A)	:	%SMW_INCGFX(GFX2B)	:	%SMW_INCGFX(GFX2C)	:	%SMW_INCGFX(GFX2D)
	%SMW_INCGFX(GFX2E)	:	%SMW_INCGFX(GFX2F)	:	%SMW_INCGFX(GFX30)	:	%SMW_INCGFX(GFX31)
check bankcross full
endmacro

macro INLINEDATATABLE_RT34_SMW_EmptySpace(Address)
!SMW_UBytes = $02F3 : !SMW_JBytes = $017E : !SMW_E1Bytes = $02F3 : !SMW_E2Bytes = $0265 : !SMASW_UBytes = $02F3 : !SMASW_EBytes = $0265 : !SMW_ARCADEBytes = $02F3
	
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	; Inside the managed run: the graphics files own these bytes.
else
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 34)
endif
endmacro
