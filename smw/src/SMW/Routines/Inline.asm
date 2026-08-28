;####################################################################
;# Inline.asm -- helpers invoked from inside other macro bodies rather
;# than from a bank manifest, so they belong to no single bank.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro INLINEDATATABLE_SMW_TallNumberTiles()		; 1st byte = Top half. 2nd byte = Bottom half
	db $B7,$C3		; 0
	db $B8,$B9		; 1
	db $BA,$BB		; 2
	db $BA,$BF		; 3
	db $BC,$BD		; 4
	db $BE,$BF		; 5
	db $C0,$C3		; 6
	db $C1,$B9		; 7
	db $C2,$C4		; 8
	db $B7,$C5		; 9
endmacro

;---------------------------------------------------------------------------

macro INLINEROUTINE_SMW_HexToDec(Index)
	LD<Index>.b #$00
-:
	CMP.b #$0A
	BCC.b +
	SBC.b #$0A
	IN<Index>
	BRA.b -

+
	RTS
endmacro

;---------------------------------------------------------------------------

macro INLINEROUTINE_SMW_UnnecessaryInvertARt()
	EOR.b #$FF
	INC
	RTS
endmacro

macro ROUTINE_RT01_SMW_UploadPlayerGFX(Address)					; Note: This is a SMAS exclusive routine macro
namespace SMW_UploadPlayerGFX
%InsertMacroAtXPosition(<Address>)

LuigiGFX:
	incbin "GFX/Luigi.bin"
	incbin "GFX/BlankLuigiTiles.bin"
namespace off
endmacro

macro ROUTINE_SMW_ARCADE_InitializeSaveData(Address)			; Note: This macro is used exclusively by the arcade version.
namespace SMW_InitializeSaveData
%InsertMacroAtXPosition(<Address>)

InitialLevelFlags:
base $000000
.Zone1Start:
	db $28,$83,$4D,$81,$52,$81,$53,$81
	db $5B,$88,$5C,$82,$57,$84,$30,$81
.Zone1End:
	db $29,$89,$2A,$8A,$27,$85,$26,$8C
	db $25,$89,$15,$04
.Zone2End:
	db $15,$86,$09,$8E,$04,$83,$05,$83
	db $06,$8A,$07,$8A,$3E,$04
.Zone3End:
	db $3E,$85,$3C,$8D,$2B,$85,$2E,$8C
	db $3D,$8C,$40,$8C,$0F,$02
.Zone4End:
	db $0F,$83,$10,$86,$0E,$85,$42,$08
.Zone5End:
	db $42,$89,$44,$8D,$47,$85,$20,$85
	db $22,$08
.Zone6End:
	db $22,$8A,$21,$85,$24,$8A,$23,$83
	db $1B,$85,$1D,$8A,$1C,$89
	db $1A,$8C,$18,$02
.Zone7End:
base off

InitialLevelFlagsStartAndEndIndex:
	db InitialLevelFlags_Zone1Start,InitialLevelFlags_Zone1End,InitialLevelFlags_Zone2End,InitialLevelFlags_Zone3End
	db InitialLevelFlags_Zone4End,InitialLevelFlags_Zone5End,InitialLevelFlags_Zone6End,InitialLevelFlags_Zone7End

InitialOWPlayerPos:
base $000000
.Zone1Start:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $01,$01
	dw $0002,$0002
	dw $0068,$0078
	dw $0068,$0078
	dw $0006,$0007
	dw $0006,$0007
	db $00,$00,$00,$00
.Zone1End:
	db $7E,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $00,$00
	dw $0002,$0002
	dw $0058,$0118
	dw $0058,$0118
	dw $0005,$0011
	dw $0005,$0011
	db $00,$01,$00,$00
.Zone2End:
	db $7F,$6F,$00,$00,$00,$80,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $02,$02
	dw $0002,$0002
	dw $0058,$0128
	dw $0058,$0128
	dw $0005,$0012
	dw $0005,$0012
	db $01,$01,$00,$00
.Zone3End:
	db $7F,$6F,$05,$F8,$00,$C0,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $00,$00
	dw $0002,$0002
	dw $0148,$0058
	dw $0148,$0058
	dw $0014,$0005
	dw $0014,$0005
	db $01,$01,$00,$01
.Zone4End:
	db $7F,$6F,$05,$F8,$0D,$C0,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $03,$03
	dw $0002,$0002
	dw $0088,$0178
	dw $0088,$0178
	dw $0008,$0017
	dw $0008,$0017
	db $01,$01,$00,$01
.Zone5End:
	db $7F,$6F,$05,$F8,$0D,$ED,$01,$00
	db $00,$00,$00,$00,$40,$00,$00
	db $00,$00
	dw $0002,$0002
	dw $0188,$0168
	dw $0188,$0168
	dw $0018,$0016
	dw $0018,$0016
	db $01,$01,$01,$01
.Zone6End:
	db $7F,$6F,$05,$F8,$0D,$ED,$01,$00
	db $02,$7C,$00,$00,$70,$00,$00
	db $00,$00
	dw $0002,$0002
	dw $00E8,$0178
	dw $00E8,$0178
	dw $000E,$0017
	dw $000E,$0017
	db $01,$01,$01,$01
.Zone7End:
base off

InitialOWPlayerPosIndex:
	dw InitialOWPlayerPos_Zone1End-$01,InitialOWPlayerPos_Zone2End-$01,InitialOWPlayerPos_Zone3End-$01,InitialOWPlayerPos_Zone4End-$01
	dw InitialOWPlayerPos_Zone5End-$01,InitialOWPlayerPos_Zone6End-$01,InitialOWPlayerPos_Zone7End-$01

Main:
	LDX.b #!Define_SMW_Misc_SaveFileSize-$02
CODE_009F08:
	STZ.w !RAM_SMW_Overworld_SaveBuffer-$01,x
	DEX
	BNE.b CODE_009F08
	LDX.w !RAM_SMW_Misc_ZoneSelectionCursorPos
	LDA.w InitialLevelFlagsStartAndEndIndex+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w InitialLevelFlagsStartAndEndIndex
	TAX

CODE_009F10:
	LDY.w InitialLevelFlags,x
	LDA.w InitialLevelFlags+$01,x
	STA.w !RAM_SMW_Overworld_SaveBuffer,y
	INX
	INX
	CPX.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_009F10
	REP.b #$30
	LDA.w !RAM_SMW_Misc_ZoneSelectionCursorPos
	ASL
	TAX
	LDY.w InitialOWPlayerPosIndex,x
	LDX.w #$0028
CODE_009F1F:
	LDA.w InitialOWPlayerPos,y
	STA.w !RAM_SMW_Overworld_SaveBuffer+$60,x
	DEY
	DEX
	BPL.b CODE_009F1F
	SEP.b #$30
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro INLINEROUTINE_SMW_EraseExtendedSprite()
	STZ.w !RAM_SMW_ExtSpr_SpriteID,x
	RTS
endmacro

;---------------------------------------------------------------------------

macro INLINEROUTINE_SMW_EraseSmokeSprite()
	STZ.w !RAM_SMW_SmokeSpr_SpriteID,x
	RTS
endmacro

;---------------------------------------------------------------------------

macro INLINEROUTINE_SMW_EraseMinorExtendedSprite()
	STZ.w !RAM_SMW_MExtSpr_SpriteID,x
	RTS
endmacro

;#############################################################################################################
;#############################################################################################################

macro INLINEDATATABLE_SMW_LavaSplashTileNumbers()
	db $D7,$C7,$D6,$C6
endmacro

;---------------------------------------------------------------------------

macro INLINEROUTINE_SMW_PreparePlayerSwap()
	; Set up saving routine. This copies a number of RAM addresses to the table
	; at $1F49. You probably want to copy this to your patch (it contains lots
	; of weirdness you don't want, so don't use the JSL to RTS trick).
	LDX.b #$2C			;!
-:
	LDA.w !RAM_SMW_Overworld_EventFlags,x	;!
	STA.w !RAM_SMW_Overworld_SaveBuffer+$60,x	;!
	DEX				;!
	BPL.b -				;!
	REP.b #$30			;! AXY->16
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo	;!
	TXA				;!
	EOR.w #$0004			;!
	TAY				;!
	LDA.w !RAM_SMW_Overworld_SaveBuffer+$75,x	;!
	STA.w !RAM_SMW_Overworld_SaveBuffer+$75,y	;!
	LDA.w !RAM_SMW_Overworld_SaveBuffer+$77,x	;!
	STA.w !RAM_SMW_Overworld_SaveBuffer+$77,y	;!
	LDA.w !RAM_SMW_Overworld_SaveBuffer+$7D,x	;!
	STA.w !RAM_SMW_Overworld_SaveBuffer+$7D,y	;!
	LDA.w !RAM_SMW_Overworld_SaveBuffer+$7F,x	;!
	STA.w !RAM_SMW_Overworld_SaveBuffer+$7F,y	;!
	TXA				;!
	LSR				;!
	TAX				;!
	EOR.w #$0002			;!
	TAY				;!
	LDA.w !RAM_SMW_Overworld_SaveBuffer+$71,x	;!
	STA.w !RAM_SMW_Overworld_SaveBuffer+$71,y	;!
	TXA				;!
	SEP.b #$30			;! AXY->8
	LSR				;!
	TAX				;!
	EOR.b #$01			;!
	TAY				;!
	LDA.w !RAM_SMW_Overworld_SaveBuffer+$6F,x	;!
	STA.w !RAM_SMW_Overworld_SaveBuffer+$6F,y	;!
endmacro

;---------------------------------------------------------------------------

macro INLINEDATATABLE_SMW_SavePromptLevels()
	db $58,$59,$5D,$63,$77,$79,$7E,$80
endmacro

;---------------------------------------------------------------------------

macro CheckPlayerPositionRelativeToSpriteSub(PlayerPos, SpritePos, ScratchRAM)
	LDY.b #$00
	LDA.b !<PlayerPos>Lo
	SEC
	SBC.b !<SpritePos>Lo,x
	STA.b <ScratchRAM>
	LDA.b !<PlayerPos>Hi
	SBC.w !<SpritePos>Hi,x
	BPL.b +
	INY
+:
	RTS
endmacro

;---------------------------------------------------------------------------

macro INLINEROUTINE_SMW_CheckIfNormalSpriteOffScreen()
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	RTS
endmacro

;---------------------------------------------------------------------------

macro INLINEROUTINE_SMW_SetNormalSpriteYSpeedBasedOnSlope()
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	BMI.b +
	LDA.b #$00
	LDY.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	BEQ.b ++
+:
	LDA.b #$18
++:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	RTS
endmacro

;---------------------------------------------------------------------------

macro INLINEROUTINE_SMW_AimTowardsPlayer(Bank)
	STA.b !RAM_SMW_Misc_ScratchRAM01
	PHX
	PHY
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_<Bank>_Y
	STY.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	BPL.b +
	EOR.b #$FF
	CLC
	ADC.b #$01
+:
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_<Bank>_X
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	BPL.b +
	EOR.b #$FF
	CLC
	ADC.b #$01
+:
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDY.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM0D
	CMP.b !RAM_SMW_Misc_ScratchRAM0C
	BCS.b +
	INY
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM0C
+:
	LDA.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM01
-:
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0C
	CMP.b !RAM_SMW_Misc_ScratchRAM0D
	BCC.b +
	SBC.b !RAM_SMW_Misc_ScratchRAM0D
	INC.b !RAM_SMW_Misc_ScratchRAM00
+:
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	DEX
	BNE.b -
	TYA
	BEQ.b +
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Misc_ScratchRAM00
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM01
+:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_Misc_ScratchRAM02
	BEQ.b +
	EOR.b #$FF
	CLC
	ADC.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM00
+:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	BEQ.b +
	EOR.b #$FF
	CLC
	ADC.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM01
+:
	PLY
	PLX
	RTS
endmacro

;---------------------------------------------------------------------------

macro INLINEDATATABLE_SMW_StompSoundTable()
	db !Define_SMW_Sound1DF9_Stomp1,!Define_SMW_Sound1DF9_Stomp2,!Define_SMW_Sound1DF9_Stomp3,!Define_SMW_Sound1DF9_Stomp4
	db !Define_SMW_Sound1DF9_Stomp5,!Define_SMW_Sound1DF9_Stomp6,!Define_SMW_Sound1DF9_Stomp7
endmacro

;#############################################################################################################
;#############################################################################################################
