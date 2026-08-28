;####################################################################
;# Bank0C.asm -- overworld, title screen, credits.
;#
;# 88 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank0CMacros(StartBank, EndBank)
%BANK_START(<StartBank>)
DATATABLE_SMW_OverworldLayer2EventTilemap:	%DATATABLE_SMW_OverworldLayer2EventTilemap(NULLROM)				; $0C8000
INLINEDATATABLE_RT35_SMW_EmptySpace:	%INLINEDATATABLE_RT35_SMW_EmptySpace(NULLROM)					; $0C936A
ROUTINE_RT01_SMW_GameMode19_Cutscene:	%ROUTINE_RT01_SMW_GameMode19_Cutscene(NULLROM)					; $0C9380
ROUTINE_RT01_SMW_GameMode1B_EndingCinema:	%ROUTINE_RT01_SMW_GameMode1B_EndingCinema(NULLROM)				; $0C938D
ROUTINE_RT01_SMW_GameMode1D_LoadYoshisHouse:	%ROUTINE_RT01_SMW_GameMode1D_LoadYoshisHouse(NULLROM)				; $0C939A
ROUTINE_RT01_SMW_GameMode25_ShowEnemyRollcallScreen:	%ROUTINE_RT01_SMW_GameMode25_ShowEnemyRollcallScreen(NULLROM)			; $0C93A5
ROUTINE_RT01_SMW_GameMode21_DelayEnemyRollcall:	%ROUTINE_RT01_SMW_GameMode21_DelayEnemyRollcall(NULLROM)			; $0C93AD
ROUTINE_SMW_BufferCreditsBackgrounds:	%ROUTINE_SMW_BufferCreditsBackgrounds(NULLROM)					; $0C93C1
ROUTINE_SMW_UpdateCreditsBackground:	%ROUTINE_SMW_UpdateCreditsBackground(NULLROM)					; $0C9559
ROUTINE_RT02_SMW_GameMode1B_EndingCinema:	%ROUTINE_RT02_SMW_GameMode1B_EndingCinema(NULLROM)				; $0C95C7
ROUTINE_SMW_InitializeCreditsEggPositions:	%ROUTINE_SMW_InitializeCreditsEggPositions(NULLROM)				; $0CA043
ROUTINE_RT02_SMW_GameMode1D_LoadYoshisHouse:	%ROUTINE_RT02_SMW_GameMode1D_LoadYoshisHouse(NULLROM)				; $0CA08F
ROUTINE_SMW_DrawEndingThankYou:	%ROUTINE_SMW_DrawEndingThankYou(NULLROM)					; $0CA136
ROUTINE_RT03_SMW_GameMode1D_LoadYoshisHouse:	%ROUTINE_RT03_SMW_GameMode1D_LoadYoshisHouse(NULLROM)				; $0CA1D4
ROUTINE_SMW_WalkingIntoYoshisHouseDuringEnding:	%ROUTINE_SMW_WalkingIntoYoshisHouseDuringEnding(NULLROM)			; $0CA1ED
ROUTINE_SMW_ProcessCheeringYoshis:	%ROUTINE_SMW_ProcessCheeringYoshis(NULLROM)					; $0CA30D
ROUTINE_RT04_SMW_GameMode1D_LoadYoshisHouse:	%ROUTINE_RT04_SMW_GameMode1D_LoadYoshisHouse(NULLROM)				; $0CA3B4
ROUTINE_SMW_YoshisWatchInExcitementDuringEnding:	%ROUTINE_SMW_YoshisWatchInExcitementDuringEnding(NULLROM)			; $0CA439
ROUTINE_SMW_HatchYoshiEggsDuringEnding:	%ROUTINE_SMW_HatchYoshiEggsDuringEnding(NULLROM)				; $0CA524
ROUTINE_SMW_SlideInThankYouDuringEnding:	%ROUTINE_SMW_SlideInThankYouDuringEnding(NULLROM)				; $0CA65B
ROUTINE_SMW_EveryoneCheeringDuringEnding:	%ROUTINE_SMW_EveryoneCheeringDuringEnding(NULLROM)				; $0CA6B0
ROUTINE_SMW_UpdateCutsceneSpritePosition:	%ROUTINE_SMW_UpdateCutsceneSpritePosition(NULLROM)				; $0CA721
ROUTINE_SMW_HandlePlayerPoseAndAnimationTimersDuringEnding:	%ROUTINE_SMW_HandlePlayerPoseAndAnimationTimersDuringEnding(NULLROM)		; $0CA75A
ROUTINE_SMW_SpawnEndingYoshiSpriteAndDrawPlayer:	%ROUTINE_SMW_SpawnEndingYoshiSpriteAndDrawPlayer(NULLROM)			; $0CA778
ROUTINE_SMW_DrawCreditsPeachRedAndYellowYoshi:	%ROUTINE_SMW_DrawCreditsPeachRedAndYellowYoshi(NULLROM)			; $0CA7B9
ROUTINE_SMW_MakeCreditsEggsBounce:	%ROUTINE_SMW_MakeCreditsEggsBounce(NULLROM)					; $0CA8A3
ROUTINE_SMW_DrawEndingBabyYoshis:	%ROUTINE_SMW_DrawEndingBabyYoshis(NULLROM)					; $0CA8D1
ROUTINE_SMW_DrawLeaningEndingYoshis:	%ROUTINE_SMW_DrawLeaningEndingYoshis(NULLROM)					; $0CA93A
ROUTINE_SMW_DrawCameraFacingEndingYoshis:	%ROUTINE_SMW_DrawCameraFacingEndingYoshis(NULLROM)				; $0CAA0B
ROUTINE_SMW_DrawingTheEndMarioLuigiAndPeach:	%ROUTINE_SMW_DrawingTheEndMarioLuigiAndPeach(NULLROM)				; $0CAA53
ROUTINE_SMW_CreditsFadeOut:	%ROUTINE_SMW_CreditsFadeOut(NULLROM)						; $0CAB13
ROUTINE_SMW_GetLayer1And2PointersForEnemyRollcall:	%ROUTINE_SMW_GetLayer1And2PointersForEnemyRollcall(NULLROM)			; $0CAC29
ROUTINE_SMW_InitializeEnemyRollcallLayerPositions:	%ROUTINE_SMW_InitializeEnemyRollcallLayerPositions(NULLROM)			; $0CADB5
ROUTINE_RT02_SMW_GameMode25_ShowEnemyRollcallScreen:	%ROUTINE_RT02_SMW_GameMode25_ShowEnemyRollcallScreen(NULLROM)			; $0CAEAD
DATATABLE_SMW_TheEndScreenText:	%DATATABLE_SMW_TheEndScreenText(NULLROM)					; $0CB636
INLINEDATATABLE_RT36_SMW_EmptySpace:	%INLINEDATATABLE_RT36_SMW_EmptySpace(NULLROM)					; $0CB66F
DATATABLE_RT01_SMW_Backgrounds:	%DATATABLE_RT01_SMW_Backgrounds(NULLROM)					; $0CB800
DATATABLE_SMW_CastleDestructionText:	%DATATABLE_SMW_CastleDestructionText(NULLROM)					; $0CBE85
ROUTINE_SMW_DisplayCastleDestructionText:	%ROUTINE_SMW_DisplayCastleDestructionText(NULLROM)				; $0CC94E
ROUTINE_RT02_SMW_GameMode19_Cutscene:	%ROUTINE_RT02_SMW_GameMode19_Cutscene(NULLROM)					; $0CC97E
ROUTINE_SMW_DrawThankYouSpeechBubble:	%ROUTINE_SMW_DrawThankYouSpeechBubble(NULLROM)					; $0CCA83
ROUTINE_SMW_RaiseFlagUpFromRubble:	%ROUTINE_SMW_RaiseFlagUpFromRubble(NULLROM)					; $0CCACE
ROUTINE_SMW_DrawWhiteFlag:	%ROUTINE_SMW_DrawWhiteFlag(NULLROM)						; $0CCAFD
ROUTINE_RT00_SMW_HandleTNTFuse:	%ROUTINE_RT00_SMW_HandleTNTFuse(NULLROM)					; $0CCB1C
ROUTINE_SMW_DrawTNTFuseBox:	%ROUTINE_SMW_DrawTNTFuseBox(NULLROM)						; $0CCB5B
ROUTINE_RT01_SMW_DrawCastleDestructionCastleDoor:	%ROUTINE_RT01_SMW_DrawCastleDestructionCastleDoor(NULLROM)			; $0CCB7C
ROUTINE_RT01_SMW_HandleTNTFuse:	%ROUTINE_RT01_SMW_HandleTNTFuse(NULLROM)					; $0CCB80
ROUTINE_RT00_SMW_DrawCastleDestructionCastleDoor:	%ROUTINE_RT00_SMW_DrawCastleDestructionCastleDoor(NULLROM)			; $0CCBFA
ROUTINE_SMW_HandleTNTExplosion:	%ROUTINE_SMW_HandleTNTExplosion(NULLROM)					; $0CCC49
ROUTINE_RT00_SMW_HandleCastleCrumblingDown:	%ROUTINE_RT00_SMW_HandleCastleCrumblingDown(NULLROM)				; $0CCD23
ROUTINE_SMW_HandleCastleLiftoff:	%ROUTINE_SMW_HandleCastleLiftoff(NULLROM)					; $0CCDA1
ROUTINE_SMW_HandleFarawayCastleRocket:	%ROUTINE_SMW_HandleFarawayCastleRocket(NULLROM)				; $0CCED4
ROUTINE_SMW_HandleDudTNTExplosion:	%ROUTINE_SMW_HandleDudTNTExplosion(NULLROM)					; $0CCF72
ROUTINE_SMW_DelayTNTExplosionUntilPlayerComesBy:	%ROUTINE_SMW_DelayTNTExplosionUntilPlayerComesBy(NULLROM)			; $0CCFC5
ROUTINE_SMW_CheckIfPlayerCanEndCastleDestructionCutscene:	%ROUTINE_SMW_CheckIfPlayerCanEndCastleDestructionCutscene(NULLROM)		; $0CCFDE
ROUTINE_SMW_WaitForCastleDestructionTextToFinishInRoyCutscene:	%ROUTINE_SMW_WaitForCastleDestructionTextToFinishInRoyCutscene(NULLROM)	; $0CCFF7
ROUTINE_SMW_PlayerDropkicksAndStompsCastle:	%ROUTINE_SMW_PlayerDropkicksAndStompsCastle(NULLROM)				; $0CD003
ROUTINE_SMW_DrawCutsceneContactEffect:	%ROUTINE_SMW_DrawCutsceneContactEffect(NULLROM)				; $0CD061
ROUTINE_SMW_WaitBeforeMakingHammeredCastleCrumble:	%ROUTINE_SMW_WaitBeforeMakingHammeredCastleCrumble(NULLROM)			; $0CD0BC
ROUTINE_SMW_WaitForWendysCastleToBeFullyMopped:	%ROUTINE_SMW_WaitForWendysCastleToBeFullyMopped(NULLROM)			; $0CD0C9
ROUTINE_SMW_UprootCastleFromGround:	%ROUTINE_SMW_UprootCastleFromGround(NULLROM)					; $0CD0D2
ROUTINE_SMW_KickCastleAway:	%ROUTINE_SMW_KickCastleAway(NULLROM)						; $0CD108
ROUTINE_SMW_KickedCastleCreatesQuake:	%ROUTINE_SMW_KickedCastleCreatesQuake(NULLROM)					; $0CD16F
ROUTINE_SMW_WaitForPlayerVictoryPoseAfterCastleQuake:	%ROUTINE_SMW_WaitForPlayerVictoryPoseAfterCastleQuake(NULLROM)			; $0CD19C
ROUTINE_RT01_SMW_HandleCastleCrumblingDown:	%ROUTINE_RT01_SMW_HandleCastleCrumblingDown(NULLROM)				; $0CD1A7
ROUTINE_RT01_SMW_ProcessMop:	%ROUTINE_RT01_SMW_ProcessMop(NULLROM)						; $0CD1F0
ROUTINE_SMW_ShakeCutsceneCastle:	%ROUTINE_SMW_ShakeCutsceneCastle(NULLROM)					; $0CD283
ROUTINE_SMW_InitializeTNTExplosion:	%ROUTINE_SMW_InitializeTNTExplosion(NULLROM)					; $0CD295
ROUTINE_SMW_InitializeCastleCrumblingDown:	%ROUTINE_SMW_InitializeCastleCrumblingDown(NULLROM)				; $0CD2B2
ROUTINE_SMW_InitializeCastleLiftoff:	%ROUTINE_SMW_InitializeCastleLiftoff(NULLROM)					; $0CD2BD
ROUTINE_SMW_InitializeDudTNTExplosion:	%ROUTINE_SMW_InitializeDudTNTExplosion(NULLROM)				; $0CD2D0
ROUTINE_SMW_InitializeFarawayCastleRocket:	%ROUTINE_SMW_InitializeFarawayCastleRocket(NULLROM)				; $0CD2E6
ROUTINE_SMW_InitializeCastleDust:	%ROUTINE_SMW_InitializeCastleDust(NULLROM)					; $0CD31A
ROUTINE_SMW_CopyOfUpdateCutsceneSpritePosition:	%ROUTINE_SMW_CopyOfUpdateCutsceneSpritePosition(NULLROM)			; $0CD33A
ROUTINE_SMW_ClearCutsceneSpritesSubpixelPosition:	%ROUTINE_SMW_ClearCutsceneSpritesSubpixelPosition(NULLROM)			; $0CD373
ROUTINE_SMW_SpawnHammerDebris:	%ROUTINE_SMW_SpawnHammerDebris(NULLROM)					; $0CD386
ROUTINE_SMW_ProcessHammerDebris:	%ROUTINE_SMW_ProcessHammerDebris(NULLROM)					; $0CD3F4
ROUTINE_SMW_DrawQuestionMark:	%ROUTINE_SMW_DrawQuestionMark(NULLROM)						; $0CD464
ROUTINE_SMW_DrawPlayerCough:	%ROUTINE_SMW_DrawPlayerCough(NULLROM)						; $0CD4F4
ROUTINE_SMW_InitializeCastleDestructionTextTimers:	%ROUTINE_SMW_InitializeCastleDestructionTextTimers(NULLROM)			; $0CD5C6
ROUTINE_SMW_DrawWoodHammer:	%ROUTINE_SMW_DrawWoodHammer(NULLROM)						; $0CD5D9
ROUTINE_RT00_SMW_ProcessMop:	%ROUTINE_RT00_SMW_ProcessMop(NULLROM)						; $0CD6C4
ROUTINE_SMW_CarryEggAwayFromCastle:	%ROUTINE_SMW_CarryEggAwayFromCastle(NULLROM)					; $0CD7EB
INLINEDATATABLE_RT37_SMW_EmptySpace:	%INLINEDATATABLE_RT37_SMW_EmptySpace(NULLROM)					; $0CD86F
DATATABLE_RT02_SMW_Backgrounds:	%DATATABLE_RT02_SMW_Backgrounds(NULLROM)					; $0CD900
ROUTINE_RT04_SMW_LoadOverworldLayer1AndEvents:	%ROUTINE_RT04_SMW_LoadOverworldLayer1AndEvents(NULLROM)			; $0CF7DF
INLINEDATATABLE_RT38_SMW_EmptySpace:	%INLINEDATATABLE_RT38_SMW_EmptySpace(NULLROM)					; $0CFFDF
%BANK_END(<EndBank>)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UpdateCutsceneSpritePosition(Address)
namespace SMW_UpdateCutsceneSpritePosition
%InsertMacroAtXPosition(<Address>)

Y:
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_Sprites_CutsceneSpriteSubYPos,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteSubYPos,x
	PHP
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	LSR
	LSR
	LSR
	LSR
	CMP.b #$08
	LDY.b #$00
	BCC.b +
	ORA.b #$F0
	DEY
+:
	PLP
	ADC.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	TYA
	ADC.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi,x
	RTS

X:
	PHX
	TXA
	CLC
	ADC.b #!Define_SMW_MaxCutsceneSpriteSlot+$01
	TAX
	JSR.w Y
	PLX
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_CopyOfUpdateCutsceneSpritePosition(Address)
namespace SMW_CopyOfUpdateCutsceneSpritePosition
%InsertMacroAtXPosition(<Address>)

Y:
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_Sprites_CutsceneSpriteSubYPos,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteSubYPos,x
	PHP
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	LSR
	LSR
	LSR
	LSR
	CMP.b #$08
	LDY.b #$00
	BCC.b +
	ORA.b #$F0
	DEY
+:
	PLP
	ADC.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	TYA
	ADC.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi,x
	RTS

X:
	PHX
	TXA
	CLC
	ADC.b #!Define_SMW_MaxCutsceneSpriteSlot+$01
	TAX
	JSR.w Y
	PLX
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UpdateCreditsBackground(Address)
namespace SMW_UpdateCreditsBackground
%InsertMacroAtXPosition(<Address>)

; DMA settings to use during the routine at $0C9567. It contains two lists
; of values with the following format: - DMA control and destination bytes
; to be copied to $4310-$4311. Both lists use $01,$18 (upload to VRAM, two
; registers write once). - DMA source, to be copied to $4312-$4314. The
; first list uses $7F4000, the second uses $7F4400 (the two halves of the
; buffer). This value is actually summed with <current background
; number>*$800, since the buffer contains all the backgrounds in sequence. -
; Data size, to be copied to $4315-$4316. Both lists use $400 (1 KiB).
PARAMS_0C9559:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Misc_CreditsBackgroundBuffer
	dw $0400

PARAMS_0C9560:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Misc_CreditsBackgroundBuffer+$0400
	dw $0400

; The DMA routine for updating the backgrounds during the credits walking
; sequence.
Main:
	SEP.b #$30			; AXY->8
	PHB
	PHK
	PLB
	LDA.b #$80
	STA.w !REGISTER_VRAMAddressIncrementValue
	LDA.b #!VRAM_SMW_Layer2TilemapVRAMLocation+$C0
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer2TilemapVRAMLocation>>8
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDY.b #$06
CODE_0C957D:
	LDA.w PARAMS_0C9559,y
	STA.w DMA[$01].Parameters,y
	DEY
	BPL.b CODE_0C957D
	LDA.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	ASL
	ASL
	ASL
	ORA.w DMA[$01].SourceHi		; A Address (High Byte)
	STA.w DMA[$01].SourceHi		; A Address (High Byte)
	LDA.b #$02
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	LDA.b #$80
	STA.w !REGISTER_VRAMAddressIncrementValue
	LDA.b #!VRAM_SMW_Layer2TilemapVRAMLocation+$C0
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.b #(!VRAM_SMW_Layer2TilemapVRAMLocation>>8)+$04
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDY.b #$06
CODE_0C95A8:
	LDA.w PARAMS_0C9560,y
	STA.w DMA[$01].Parameters,y
	DEY
	BPL.b CODE_0C95A8
	LDA.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	ASL
	ASL
	ASL
	ORA.w DMA[$01].SourceHi		; A Address (High Byte)
	STA.w DMA[$01].SourceHi		; A Address (High Byte)
	LDA.b #$02
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	STZ.w !RAM_SMW_Flag_UpdateCreditsBackground
	PLB
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawEndingThankYou(Address)
namespace SMW_DrawEndingThankYou
%InsertMacroAtXPosition(<Address>)

; THANK YOU! text tiles (Yoshi's House).
Tiles:
	db $26,$28,$2A,$2C,$46,$48,$4A,$4C
	db $60,$62,$64,$66,$6A,$6C,$6E,$0A

Main:
	REP.b #$20			; A->16
	LDA.w #$003F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM04
	LDY.b #$00
	LDX.b #$50
Entry2:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0080
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	SEP.b #$20			; A->8
	JSR.w CODE_0CA183
	REP.b #$20			; A->16
	LDA.w #$0080
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM04
	SEC
	SBC.w #$0040
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w #$003F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	SEP.b #$20			; A->8
CODE_0CA183:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b CODE_0CA1AB
	LDA.w Tiles,y
	STA.w SMW_OAMBuffer[$40].Tile,x
	LDA.b #$35
	STA.w SMW_OAMBuffer[$40].Prop,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,x
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	STA.w SMW_OAMBuffer[$40].YDisp,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x
	PLX
	INX
	INX
	INX
	INX
CODE_0CA1AB:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	TYA
	AND.b #$07
	CMP.b #$03
	BNE.b CODE_0CA1CD
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM08
CODE_0CA1CD:
	INY
	TYA
	AND.b #$07
	BNE.b CODE_0CA183
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_GameMode21_DelayEnemyRollcall(Address)
namespace SMW_GameMode21_DelayEnemyRollcall
%InsertMacroAtXPosition(<Address>)

Bank03:
	PHB
	PHK
	PLB
	DEC.w !RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenLo
	BNE.b CODE_0C93BF
	LDA.b #!Define_SMW_GameMode23_LoadEnemyRollcallScreen
	STA.w !RAM_SMW_Misc_GameMode
	LDA.b #$FF
	STA.w !RAM_SMW_Counter_EnemyRollcallScreen
CODE_0C93BF:
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_GameMode19_Cutscene(Address)
namespace SMW_GameMode19_Cutscene
%InsertMacroAtXPosition(<Address>)

CastleDestructionBorder:
	incbin "images/other/black.bin"
namespace off
endmacro

macro ROUTINE_RT02_SMW_GameMode19_Cutscene(Address)
namespace SMW_GameMode19_Cutscene
%InsertMacroAtXPosition(<Address>)

CODE_0CC97E:
	PHB
	PHK
	PLB
	JSR.w SMW_DisplayCastleDestructionText_Main
	JSR.w SMW_DrawThankYouSpeechBubble_Main
	JSR.w ProcessCutscene_Main
	PLB
	RTL

ProcessCutscene_Main:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_0CC99A
	LDA.w !RAM_SMW_Timer_WaitBeforeAllowingEndOfCastleDestructionCutscene
	BEQ.b CODE_0CC99A
	DEC.w !RAM_SMW_Timer_WaitBeforeAllowingEndOfCastleDestructionCutscene
CODE_0CC99A:
	JSR.w SMW_CarryEggAwayFromCastle_Main
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	DEC
	JSL.l SMW_ExecutePtr_Absolute

Ptrs0CC9A5:
	dw IggyCutscene
	dw MortonCutscene
	dw LemmyCutscene
	dw LudwigCutscene
	dw RoyCutscene
	dw WendyCutscene
	dw LarryCutscene

IggyCutscene:
	JSR.w SMW_DrawTNTFuseBox_Main
	JSR.w SMW_RaiseFlagUpFromRubble_Main
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSL.l SMW_ExecutePtr_Absolute

Ptrs0CC9C0:
	dw SMW_HandleTNTFuse_Main
	dw SMW_InitializeTNTExplosion_Main
	dw SMW_HandleTNTExplosion_Main
	dw SMW_InitializeCastleCrumblingDown_Main
	dw SMW_HandleCastleCrumblingDown_Main
	dw SMW_CheckIfPlayerCanEndCastleDestructionCutscene_Main

MortonCutscene:
	JSR.w SMW_RaiseFlagUpFromRubble_Main
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSL.l SMW_ExecutePtr_Absolute

Ptrs0CC9D6:
	dw SMW_PlayerDropkicksAndStompsCastle_Main
	dw SMW_InitializeCastleCrumblingDown_Main
	dw SMW_HandleCastleCrumblingDown_Main
	dw SMW_DrawPlayerCough_MortonCutscene
	dw SMW_CheckIfPlayerCanEndCastleDestructionCutscene_Main

RoyCutscene:
	JSR.w SMW_DrawTNTFuseBox_Main
	JSR.w SMW_RaiseFlagUpFromRubble_Main
	JSR.w SMW_DrawPlayerCough_RoyCutscene
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSL.l SMW_ExecutePtr_Absolute

Ptrs0CC9F0:
	dw SMW_HandleTNTFuse_Main
	dw SMW_InitializeDudTNTExplosion_Main
	dw SMW_HandleDudTNTExplosion_Main
	dw SMW_DelayTNTExplosionUntilPlayerComesBy_Main
	dw SMW_InitializeTNTExplosion_Main
	dw SMW_HandleTNTExplosion_Main
	dw SMW_InitializeCastleCrumblingDown_Main
	dw SMW_HandleCastleCrumblingDown_Main
	dw SMW_WaitForCastleDestructionTextToFinishInRoyCutscene_Main
	dw SMW_CheckIfPlayerCanEndCastleDestructionCutscene_Main

LudwigCutscene:
	JSR.w SMW_DrawTNTFuseBox_Main
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BNE.b CODE_0CCA11
	LDY.b #$04
	STY.w !RAM_SMW_Sprites_QuestionMarkAnimationIndex
CODE_0CCA11:
	CMP.b #$07
	BNE.b CODE_0CCA18
	JSR.w SMW_HandleFarawayCastleRocket_DrawSprite
CODE_0CCA18:
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSL.l SMW_ExecutePtr_Absolute

Ptrs0CCA1F:
	dw SMW_HandleTNTFuse_Main
	dw SMW_InitializeTNTExplosion_Main
	dw SMW_HandleTNTExplosion_Main
	dw SMW_InitializeCastleLiftoff_Main
	dw SMW_HandleCastleLiftoff_Main
	dw SMW_InitializeFarawayCastleRocket_Main
	dw SMW_HandleFarawayCastleRocket_Main
	dw SMW_CheckIfPlayerCanEndCastleDestructionCutscene_Main

LemmyCutscene:
	JSR.w SMW_DrawWoodHammer_Main
	JSR.w SMW_RaiseFlagUpFromRubble_Main
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	CMP.b #$03
	BEQ.b CODE_0CCA3F
	JSR.w SMW_SpawnHammerDebris_Main
CODE_0CCA3F:
	JSR.w SMW_ProcessHammerDebris_Main
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSL.l SMW_ExecutePtr_Absolute

Ptrs0CCA49:
	dw SMW_WaitBeforeMakingHammeredCastleCrumble_Main
	dw SMW_InitializeCastleCrumblingDown_Main
	dw SMW_HandleCastleCrumblingDown_Main
	dw SMW_CheckIfPlayerCanEndCastleDestructionCutscene_Main

WendyCutscene:
	JSR.w SMW_ProcessMop_Main
	LDA.w !RAM_SMW_Flag_ShowWhiteFlag
	BEQ.b CODE_0CCA67
	LDX.b #$30
	LDA.b #$B0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$68
	STA.w !RAM_SMW_Sprites_WhiteFlagYPosLo
	JSR.w SMW_DrawWhiteFlag_Main
CODE_0CCA67:
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSL.l SMW_ExecutePtr_Absolute

Ptrs0CCA6E:
	dw SMW_WaitForWendysCastleToBeFullyMopped_Main
	dw SMW_CheckIfPlayerCanEndCastleDestructionCutscene_Main

LarryCutscene:
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSL.l SMW_ExecutePtr_Absolute

Ptrs0CCA79:
	dw SMW_UprootCastleFromGround_Main
	dw SMW_KickCastleAway_Main
	dw SMW_KickedCastleCreatesQuake_Main
	dw SMW_WaitForPlayerVictoryPoseAfterCastleQuake_Main
	dw SMW_CheckIfPlayerCanEndCastleDestructionCutscene_Main
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_CarryEggAwayFromCastle(Address)
namespace SMW_CarryEggAwayFromCastle
%InsertMacroAtXPosition(<Address>)

DATA_0CD7EB:
	db $F7,$F6

DATA_0CD7ED:
	db $63,$5F,$62,$5F,$62,$5E

YDisp:
	db $67,$66,$65,$65,$64,$64,$64,$64
	db $64,$64,$64,$64,$65,$65,$66,$67

Main:
	LDX.w !RAM_SMW_Flag_DisplayThankYouBubble
	BNE.b CODE_0CD83D
	LDA.w !RAM_SMW_Timer_DisplayPlayerPickUpPose
	BEQ.b CODE_0CD812
	LSR
	BEQ.b CODE_0CD849
	BRA.b CODE_0CD84F

CODE_0CD812:
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_0CD818
	LDY.b #$01
CODE_0CD818:
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w DATA_0CD7EB,y
	STA.w !RAM_SMW_Sprites_CarriedEggXPosLo
	TYA
	LSR
	LDA.w !RAM_SMW_Player_WalkingFrame
	ROL
	TAY
	LDA.w DATA_0CD7ED,y
	LDY.b !RAM_SMW_Player_XPosLo
	CPY.b #$40
	BCS.b CODE_0CD858
	LDY.b !RAM_SMW_Player_XSpeed
	BNE.b CODE_0CD858
	LDA.b #$10
	STA.w !RAM_SMW_Timer_DisplayPlayerPickUpPose
	STZ.w !RAM_SMW_Player_CarryingSomethingFlag2
CODE_0CD83D:
	LDA.b #$05
	CMP.b !RAM_SMW_Player_XPosLo
	BCC.b CODE_0CD84C
	STA.b !RAM_SMW_Player_XPosLo
	LDA.b !RAM_SMW_Player_XSpeed
	BMI.b CODE_0CD84C
CODE_0CD849:
	INC.w !RAM_SMW_Flag_DisplayThankYouBubble
CODE_0CD84C:
	INC.w !RAM_SMW_Sprites_CarriedEggBounceFrameCounter
CODE_0CD84F:
	LDA.w !RAM_SMW_Sprites_CarriedEggBounceFrameCounter
	AND.b #$0F
	TAY
	LDA.w YDisp,y
CODE_0CD858:
	STA.w SMW_OAMBuffer[$60].YDisp
	LDA.w !RAM_SMW_Sprites_CarriedEggXPosLo
	STA.w SMW_OAMBuffer[$60].XDisp
	STZ.w SMW_OAMBuffer[$60].Tile
	LDA.b #$21
	STA.w SMW_OAMBuffer[$60].Prop
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$60].Slot
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_DisplayCastleDestructionText(Address)
namespace SMW_DisplayCastleDestructionText
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Timer_DisplayCastleDestructionText
if ver_is_arcade(!Define_Global_ROMToAssemble)
	BNE.b TextNotFinished
	LDA.w !RAM_SMW_Overworld_EnterLevelFlag
	BNE.b BranchToReturn
	LDA.b #$80
	STA.w !RAM_SMW_Overworld_EnterLevelFlag

BranchToReturn:
	BRA.b Return0CC97D

TextNotFinished:
	LDA.b !RAM_SMW_IO_ControllerHold1	
	ORA.b !RAM_SMW_IO_ControllerHold2
	BEQ.b CODE_0CC953
	LDA.w !RAM_SMW_Timer_DisplayCastleDestructionText
	AND.b #$E0
	BNE.b PauseText
	LDA.b #$01
	STA.w !RAM_SMW_Timer_DisplayCastleDestructionText
	BRA.b CODE_0CC953

PauseText:
	INC
	STA.w !RAM_SMW_Timer_DisplayCastleDestructionText
else
	BEQ.b Return0CC97D		;!
endif
CODE_0CC953:
	DEC.w !RAM_SMW_Timer_DisplayCastleDestructionText
	LDA.w !RAM_SMW_Timer_DisplayCastleDestructionText
	AND.b #$1F
	BNE.b Return0CC97D
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	DEC
	ASL
	ASL
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
	ASL				;!
endif
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Timer_DisplayCastleDestructionText
if ver_is_japanese(!Define_Global_ROMToAssemble)
	AND.b #$60
else
	AND.b #$E0
endif
	LSR
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #!Define_SMW_StripeImage_CastleDestructionText
	STA.b !RAM_SMW_Graphics_StripeImageToUpload
Return0CC97D:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_DrawThankYouSpeechBubble(Address)
namespace SMW_DrawThankYouSpeechBubble
%InsertMacroAtXPosition(<Address>)

; Positions and tilemap for the castle destruction scene's "Thank you!" text
; bubble. Almost in the standard OAM format (xxxxxxxx yyyyyyyy tttttttt
; YXPPCCCT), except the YXPPCCCT is actually formatted as "YX-SCCCT", where
; the S bit is the size (8x8 or 16s16); the PP bits are always set to 10.
TileData:
	db $20,$48,$A6,$18
	db $30,$48,$A8,$18
	db $28,$58,$8D,$08

Main:
	LDA.w !RAM_SMW_Flag_DisplayThankYouBubble
	BEQ.b Return0CCACD
	LDY.b #$00
	TYX
CODE_0CCA97:
	LDA.w TileData,y
	STA.w SMW_OAMBuffer[$78].XDisp,x
	LDA.w TileData+$01,y
	STA.w SMW_OAMBuffer[$78].YDisp,x
	LDA.w TileData+$02,y
	STA.w SMW_OAMBuffer[$78].Tile,x
	LDA.w TileData+$03,y
	AND.b #$CF
	ORA.b #$20
	STA.w SMW_OAMBuffer[$78].Prop,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA.w TileData+$03,y
	AND.b #$10
	LSR
	LSR
	LSR
	STA.w SMW_OAMTileSizeBuffer[$78].Slot,x
	PLX
	INX
	INX
	INX
	INX
	TXY
	CPY.b #$0C
	BNE.b CODE_0CCA97
Return0CCACD:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawTNTFuseBox(Address)
namespace SMW_DrawTNTFuseBox
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #$E0
	LDA.w !RAM_SMW_Flag_TNTPlungerWasPressed
	BEQ.b CODE_0CCB64
	LDY.b #$E2
CODE_0CCB64:
	STY.w SMW_OAMBuffer[$00].Tile
	LDA.b #$39
	STA.w SMW_OAMBuffer[$00].Prop
	LDA.b #$50
	STA.w SMW_OAMBuffer[$00].XDisp
	LDA.b #$67
	STA.w SMW_OAMBuffer[$00].YDisp
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_DrawWhiteFlag(Address)
namespace SMW_DrawWhiteFlag
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$60].XDisp,x
	LDA.w !RAM_SMW_Sprites_WhiteFlagYPosLo
	STA.w SMW_OAMBuffer[$60].YDisp,x
	LDA.b #$E6
	STA.w SMW_OAMBuffer[$60].Tile,x
	LDA.b #$21
	STA.w SMW_OAMBuffer[$60].Prop,x
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$60].Slot,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_RaiseFlagUpFromRubble(Address)
namespace SMW_RaiseFlagUpFromRubble
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BNE.b CODE_0CCADD
	STZ.w !RAM_SMW_Flag_ShowWhiteFlag
	LDA.b #$98
	STA.w !RAM_SMW_Sprites_WhiteFlagYPosLo
	BRA.b Return0CCAFC

CODE_0CCADD:
	LDA.w !RAM_SMW_Flag_ShowWhiteFlag
	BEQ.b Return0CCAFC
	LDA.w !RAM_SMW_Sprites_WhiteFlagYPosLo
	CMP.b #$5C
	BCC.b CODE_0CCAF3
	LDX.b #$01
	LDA.b #$F0
	STA.w !RAM_SMW_Sprites_WhiteFlagYSpeed-$01,x			;\ Note: Yeah, the programmer used the X version of this routine to change the Y position of the white flag. Don't ask why.
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_X			;/
CODE_0CCAF3:
	LDX.b #$30
	LDA.b #$AB
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BRL.w SMW_DrawWhiteFlag_Main

Return0CCAFC:
	RTS

namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_DrawPlayerCough(Address)
namespace SMW_DrawPlayerCough
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $89,$99,$A9,$B9

RoyCutscene:
	LDA.w !RAM_SMW_Misc_ShowPlayerCough
	BNE.b CODE_0CD502
	STZ.w !RAM_SMW_Sprites_RoyCutscenePlayerCoughYPosLo
	BRA.b Return0CD556

CODE_0CD502:
	LDX.b #$02
	LDA.b #$FD
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	EOR.b #$FF
	INC
	CMP.b #$0D
	BCC.b CODE_0CD51B
	STZ.w !RAM_SMW_Misc_ShowPlayerCough
	BRA.b Return0CD556

CODE_0CD51B:
	LDX.b #$00
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_0CD523
	LDX.b #$08
CODE_0CD523:
	STX.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b #$34
	LDA.b #$04
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.w !RAM_SMW_Sprites_RoyCutscenePlayerCoughYPosLo
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LDA.w !RAM_SMW_Sprites_RoyCutscenePlayerCoughYPosLo
	EOR.b #$FF
	INC
	LSR
	LSR
	TAY
	LDA.w Tiles,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.b #$33
	STA.w SMW_OAMBuffer[$00].Prop,x
	TXA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$00].Slot,x
Return0CD556:
	RTS

MortonCutscene:
	LDA.w !RAM_SMW_Misc_ShowPlayerCough
	BNE.b CODE_0CD564
	STZ.w !RAM_SMW_Sprites_MortonCutscenePlayerCoughYPosLo
	STZ.w !RAM_SMW_Sprites_MortonCutscenePlayerCoughXPosLo
	BRA.b Return0CD5C5

CODE_0CD564:
	LDX.b #$03
	LDA.b #$06
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXSpeed,x
	LDA.b #$01
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_X
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo,x
	CMP.b #$0D
	BCC.b CODE_0CD585
	STZ.w !RAM_SMW_Misc_ShowPlayerCough
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BRA.b Return0CD5C5

CODE_0CD585:
	LDX.b #$0F
	LDY.b #$0C
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_0CD58F
	LDX.b #$13
CODE_0CD58F:
	STX.b !RAM_SMW_Misc_ScratchRAM00
	STY.b !RAM_SMW_Misc_ScratchRAM01
	LDX.b #$34
	LDA.w !RAM_SMW_Sprites_MortonCutscenePlayerCoughXPosLo
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.w !RAM_SMW_Sprites_MortonCutscenePlayerCoughYPosLo
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LDA.w !RAM_SMW_Sprites_MortonCutscenePlayerCoughXPosLo
	LSR
	LSR
	TAY
	LDA.w Tiles,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.b #$33
	STA.w SMW_OAMBuffer[$00].Prop,x
	TXA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$00].Slot,x
Return0CD5C5:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_DrawWoodHammer(Address)
namespace SMW_DrawWoodHammer
%InsertMacroAtXPosition(<Address>)

HammerSwingPlayerPoses:
	db $35,$36,$36,$36,$37,$37,$37,$37
	db $37,$37,$37,$36,$36,$35,$35,$35

Tiles:
	db $8B,$8B,$8B,$AA,$8A,$CE,$CE,$8A
	db $8A,$AA,$AA,$8A,$AA,$8A,$CE,$8A
	db $AA,$8A,$8A

Prop:
	db $61,$61,$61,$61,$61,$61,$61,$21
	db $21,$21,$21,$A1,$21,$21,$61,$61
	db $61,$E1,$E1

XDisp:
	db $FA,$FA,$F9,$FB,$F9,$FA,$F0,$F0
	db $F4,$F4,$FD,$FF,$FD,$FF,$0A,$0D
	db $0A,$0D,$0E,$10,$0E,$10,$0D,$0E
	db $0E,$10,$0A,$0D,$FD,$FF,$F4,$F4
	db $F0,$F0,$F3,$F0,$F3,$F0

YDisp:
	db $06,$03,$07,$00,$07,$01,$0D,$08
	db $02,$FB,$FF,$F6,$FF,$F6,$03,$FD
	db $03,$FD,$0A,$06,$0A,$06,$12,$0F
	db $0A,$06,$03,$FD,$FF,$F6,$02,$FB
	db $0D,$08,$15,$10,$15,$10

Main:
	LDA.w !RAM_SMW_Flag_DisplayThankYouBubble
	LSR
	BEQ.b Return0CD6C3
	LDA.w !RAM_SMW_Sprites_SwingHammerTimer
	BNE.b CODE_0CD66B
	LDX.w !RAM_SMW_Player_WalkingFrame
	BRA.b CODE_0CD680

CODE_0CD66B:
	DEC.w !RAM_SMW_Sprites_SwingHammerTimer
	CMP.b #$F0
	BCC.b CODE_0CD674
	LDA.b #$0F
CODE_0CD674:
	AND.b #$0F
	CLC
	ADC.b #$03
	TAX
	LDA.w HammerSwingPlayerPoses-$03,x
	STA.w !RAM_SMW_Player_CurrentPose
CODE_0CD680:
	LDY.b #$00
	LDA.w Tiles,x
	LSR
	BCC.b CODE_0CD68A
	LDY.b #$30
CODE_0CD68A:
	ASL
	STA.w SMW_OAMBuffer[$3F].Tile,y
	LDA.b !RAM_SMW_Player_FacingDirection
	LSR
	ROR
	LSR
	EOR.w Prop,x
	STA.w SMW_OAMBuffer[$3F].Prop,y
	TXA
	ASL
	TAX
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_0CD6A1
	INX
CODE_0CD6A1:
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$3F].YDisp,y
	LDA.w XDisp,x
	LDX.b !RAM_SMW_Player_FacingDirection
	BNE.b CODE_0CD6B4
	EOR.b #$FF
	INC
CODE_0CD6B4:
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.w SMW_OAMBuffer[$3F].XDisp,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$3F].Slot,y
Return0CD6C3:
	RTS

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnHammerDebris(Address)
namespace SMW_SpawnHammerDebris
%InsertMacroAtXPosition(<Address>)

YSpeed:
	db $C8,$C0,$C4,$C8,$C0,$B4,$C8,$B8
	db $C6,$B7,$C4,$B0,$C8,$C0,$C8,$C4

XSpeed:
	db $18,$F8,$0A,$20,$E8,$1A,$EA,$08
	db $F0,$18,$E0,$2A,$F8,$20,$FA,$18

Main:
	LDA.w !RAM_SMW_Sprites_SwingHammerTimer
	DEC
	CMP.b #$E7
	BCS.b Return0CD3F3
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b Return0CD3F3
	LDX.b #!Define_SMW_MaxCutsceneSpriteSlot
CODE_0CD3B6:
	LDA.w !RAM_SMW_CutsceneSpr_HammerDebris_CurrentStatus,x
	BNE.b CODE_0CD3EE
	LDA.b #$01
	STA.w !RAM_SMW_CutsceneSpr_HammerDebris_CurrentStatus,x
	LDA.b #$04
	STA.w !RAM_SMW_CutsceneSpr_HammerDebris_YAcceleration,x
	LDA.w YSpeed,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	LDA.w XSpeed,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXSpeed,x
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.b #$18
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo,x
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b #$20
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$02
	BNE.b Return0CD3F3
	LDA.b #!Define_SMW_Sound1DFC_BreakBlock
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	BRA.b Return0CD3F3

CODE_0CD3EE:
	DEX
	CPX.b #!Define_SMW_MaxCutsceneSpriteSlot-$0B
	BNE.b CODE_0CD3B6
Return0CD3F3:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_DrawQuestionMark(Address)
namespace SMW_DrawQuestionMark
%InsertMacroAtXPosition(<Address>)

YDisp:
	db $F8,$80,$80,$80
	db $FA,$80,$80,$80
	db $FA,$FC,$80,$80
	db $FA,$FC,$04,$80
	db $F8,$80,$80,$80
	db $F9,$80,$80,$80
	db $FA,$80,$80,$80
	db $FA,$80,$80,$80

XDisp:
	db $08,$80,$80,$80
	db $09,$80,$80,$80
	db $09,$FF,$80,$80
	db $09,$FF,$F6,$80
	db $04,$80,$80,$80
	db $00,$80,$80,$80
	db $FF,$80,$80,$80
	db $00,$80,$80,$80

Main:
	PHB
	PHK
	PLB
	LDX.b #$00
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_0CD4AF
	LDX.b #$08
CODE_0CD4AF:
	STX.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$40
	LDA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_QuestionMarkAnimationIndex
	ASL
	ASL
	TAY
CODE_0CD4BD:
	LDA.w XDisp,y
	CMP.b #$80
	BEQ.b CODE_0CD4ED
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.w YDisp,y
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LDA.b #$B6
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.b #$31
	STA.w SMW_OAMBuffer[$00].Prop,x
	PHX
	TXA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$00].Slot,x
	PLX
	INX
	INX
	INX
	INX
CODE_0CD4ED:
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_0CD4BD
	PLB
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_GameMode1B_EndingCinema(Address)
namespace SMW_GameMode1B_EndingCinema
%InsertMacroAtXPosition(<Address>)

Bank0C:
	PHB				; Wrapper
	PHK
	PLB
	SEP.b #$30			; AXY->8
	JSR.w Sub
	JSR.w SMW_CreditsFadeOut_Sub
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_GameMode1B_EndingCinema(Address)
namespace SMW_GameMode1B_EndingCinema
%InsertMacroAtXPosition(<Address>)

Tilemaps:											;\ LM: This becomes freespace in ROMs with custom credits images.
if ver_is_japanese(!Define_Global_ROMToAssemble)						;|
	%InsertVersionExclusiveFile(incbin, ../SMW/images/ending/Credits_, SMW_J.bin, )		;|
else												;|
	%InsertVersionExclusiveFile(incbin, ../SMW/images/ending/Credits_, SMW_U.bin, )		;/
endif

RowPointers:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	dw $00C1,$0026,$00DF,$00FD,$0026,$0026,$0026,$011B			;\ LM: Changes all of these to dw $40*X, with X being the row number, when saving a custom credits image
	dw $0026,$0137,$0153,$0026,$0026,$0026,$016F,$0026			;| Note that Lunar Magic makes no attempt to optimize the size of your credits.
	dw $018F,$01AD,$0026,$0026,$0026,$01CB,$0026,$01ED			;| Your custom credits will always take up 12.6 KB (SMW's take up about 1.82 KB) as a result.
	dw $020F,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0231,$0026,$0269,$0287,$0026,$0026,$0026			;|
	dw $02A5,$0026,$02C7,$02E5,$0026,$0026,$0026,$0303			;|
	dw $0026,$032F,$0357,$0026,$037F,$03A5,$0026,$03CB			;|
	dw $0026,$03E7,$0409,$0026,$0026,$0026,$042B,$0026			;|
	dw $0447,$0469,$0026,$048B,$049F,$0026,$04B3,$04D3			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $04F3,$0026,$050D,$052B,$0026,$0026,$0026,$0549			;|
	dw $0026,$0567,$057D,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0593,$0026,$05B7,$05D3,$0026			;|
	dw $05EF,$060D,$0026,$062B,$0647,$0026,$0663,$0681			;|
	dw $0026,$069F,$06B5,$0026,$06CB,$06E7,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$006B,$0026			;|
	dw $007D,$009F,$0026,$0026,$0026,$0000,$0026,$0027			;|
	dw $0049,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026								;|
else										;|
	dw $00C1,$0026,$00DD,$00FB,$0026,$0026,$0026,$0119			;|
	dw $0026,$0133,$014F,$0026,$0026,$0026,$016B,$0026			;|
	dw $0187,$01A5,$0026,$0026,$0026,$01C3,$0026,$01E5			;|
	dw $0207,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0229,$0026,$0261,$027F,$0026,$0026,$0026,$029D			;|
	dw $0026,$02C1,$02DF,$0026,$0026,$0026,$02FD,$0026			;|
	dw $0329,$0351,$0026,$0379,$039F,$0026,$0026,$03C5			;|
	dw $0026,$03E3,$0405,$0026,$0026,$0026,$0427,$0026			;|
	dw $0447,$0469,$0026,$048B,$049F,$0026,$04B3,$04D3			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$04F3			;|
	dw $0026,$0529,$0547,$0026,$0026,$0026,$0565,$0026			;|
	dw $0583,$0599,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$05AF,$0026,$05D5,$05F1,$0026,$060D,$062B			;|
	dw $0026,$0649,$0665,$0026,$0681,$069F,$0026,$06BD			;|
	dw $06D3,$0026,$06E9,$0705,$0026,$0721,$0739,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$006B,$0026			;|
	dw $007D,$009F,$0026,$0026,$0026,$0000,$0026,$0027			;|
	dw $0049,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0026			;|
	dw $0026,$0026								;/
endif

DATA_0C9EAC:
	db $40,$3E,$FC,$00,$FF

; The subroutine that uploads the credits tilemap.
BufferNextRowOfCredits:
	REP.b #$30			; AXY->16
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	LDY.w #$0000
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_CreditsStripeImageHeaderHi
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	LDA.b !RAM_SMW_Misc_CreditsStripeImageHeaderLo
	STA.l SMW_StripeImageUploadTable[$00].HighByte,x
	INX
	INX
CODE_0C9ECB:
	LDA.w DATA_0C9EAC,y
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INY
	CPY.w #$0005
	BNE.b CODE_0C9ECB
	REP.b #$20			; A->16
	DEX
	TXA
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	LDA.b !RAM_SMW_Misc_CreditsStripeImageIndex
	AND.w #$00FF
	ASL
	TAY
	LDA.w RowPointers,y
	TAY							;\ LM: Optimizes and modifies this routine to support having a custom credits image.
	SEP.b #$20						;| The custom credits data can be found by using read3($0C9F17)
	INC.b !RAM_SMW_Misc_CreditsStripeImageIndex		;|
	LDA.w Tilemaps,y					;|
	CMP.b #$FF						;|
	BEQ.b CODE_0C9F43					;|
	LDA.w Tilemaps,y					;|
	STA.b !RAM_SMW_Misc_ScratchRAM02			;|
	LDA.w Tilemaps+$01,y					;|
	STA.b !RAM_SMW_Misc_ScratchRAM00			;|
	STZ.b !RAM_SMW_Misc_ScratchRAM01			;|
	INY							;|
	INY							;|
	LDA.b !RAM_SMW_Misc_CreditsStripeImageHeaderHi		;|
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x		;|
	LDA.b !RAM_SMW_Misc_CreditsStripeImageHeaderLo		;|
	CLC							;|
	ADC.b !RAM_SMW_Misc_ScratchRAM02			;|
	STA.l SMW_StripeImageUploadTable[$00].HighByte,x		;|
	INX							;|
	INX							;|
	LDA.b !RAM_SMW_Misc_ScratchRAM01			;|
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x		;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00			;|
	STA.l SMW_StripeImageUploadTable[$00].HighByte,x		;|
	INX							;|
	INX							;|
	REP.b #$20						;|
CODE_0C9F26:							;|
	LDA.w Tilemaps,y					;|
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x		;|
	INX							;|
	INX							;|
	INY							;|
	INY							;|
	DEC.b !RAM_SMW_Misc_ScratchRAM00			;|
	DEC.b !RAM_SMW_Misc_ScratchRAM00			;|
	BPL.b CODE_0C9F26					;|
	LDA.w #$00FF						;|
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x		;|
	TXA							;|
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo		;|
CODE_0C9F43:							;|
	REP.b #$20						;|
	SEP.b #$10						;|
	LDA.b !RAM_SMW_Misc_CreditsStripeImageHeaderLo		;|
	CLC							;|
	ADC.w #$0020						;|
	STA.b !RAM_SMW_Misc_CreditsStripeImageHeaderLo		;|
	AND.w #$03FF						;|
	BNE.b Return0C9F5B					;|
	LDA.b !RAM_SMW_Misc_CreditsStripeImageHeaderLo		;|
	EOR.w #$0C00						;|
	STA.b !RAM_SMW_Misc_CreditsStripeImageHeaderLo		;|
Return0C9F5B:							;|
	RTS							;/

BackgroundChangeHeight:
	dw $00C0,$0180,$0240,$0300
	dw $03C0,$0480,$0559

Sub:
	REP.b #$20			; A->16
	LDX.b #$00
	LDA.w #$FF80
	STA.w !RAM_SMW_Misc_CreditsTempLayer2XSpeedLo,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00,x
	JSR.w CODE_0C9FCB
	LDA.b !RAM_SMW_Misc_ScratchRAM00,x
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo,x
	LDA.b !RAM_SMW_Mirror_Layer3YPosLo
	CMP.w #$0559
	BCS.b CODE_0C9FAC
	LDX.b #$02
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.w #$004E
else
	LDA.w #$0040
endif
	STA.w !RAM_SMW_Misc_CreditsTempLayer3YSpeedLo-$02,x
	LDA.b !RAM_SMW_Mirror_Layer3YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	JSR.w CODE_0C9FCB
	LDA.b !RAM_SMW_Misc_ScratchRAM00,x
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	BEQ.b CODE_0C9FAC
	STA.b !RAM_SMW_Mirror_Layer3YPosLo
	LDA.b !RAM_SMW_Mirror_Layer3YPosLo
	AND.w #$0007
	CMP.w #$0001
	BNE.b CODE_0C9FAC
	JSR.w BufferNextRowOfCredits
CODE_0C9FAC:
	LDX.b #$0C
CODE_0C9FAE:
	LDA.b !RAM_SMW_Mirror_Layer3YPosLo
if ver_is_japanese(!Define_Global_ROMToAssemble)
	CMP.l BackgroundChangeHeight,x
else
	CMP.w BackgroundChangeHeight,x
endif
	BEQ.b CODE_0C9FBB
	DEX
	DEX
	BPL.b CODE_0C9FAE
	BRA.b CODE_0C9FC6

CODE_0C9FBB:
	LDA.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
	AND.w #$00FF
	BNE.b CODE_0C9FC6
	INC.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
CODE_0C9FC6:
	SEP.b #$20			; A->8
	BRL.w CODE_0C9FEA

CODE_0C9FCB:
	LDA.w !RAM_SMW_Misc_CreditsTempLayer2XPosLo,x
	AND.w #$00FF
	CLC
	ADC.w !RAM_SMW_Misc_CreditsTempLayer2XSpeedLo,x
	STA.w !RAM_SMW_Misc_CreditsTempLayer2XPosLo,x
	AND.w #$FF00
	BPL.b CODE_0C9FE0
	ORA.w #$00FF
CODE_0C9FE0:
	XBA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00,x
	STA.b !RAM_SMW_Misc_ScratchRAM00,x
	RTS

; Princess's Y position on Yoshi during the staff roll, relative to absolute
; value #$85. Each byte represents a Y position.
PeachOnYoshiOffset:
	db $00,$FF,$00

CODE_0C9FEA:
	REP.b #$20			; A->16
	LDA.w #$0038
	STA.b !RAM_SMW_Player_XPosLo
	LDA.w #$008F
	STA.b !RAM_SMW_Player_YPosLo
	SEP.b #$20			; A->8
	; Mario's powerup status during the staff roll in the credits. Change to A9
	; 00 for Small Mario, A9 01 for Big Mario, A9 02 for Cape Mario, A9 03 for
	; Fiery Mario, A5 19 to keep the same powerup after Bowser's Battle.
	LDA.b #$01
	STA.b !RAM_SMW_Player_CurrentPowerUp
	LDA.b #$08
	STA.w !RAM_SMW_Player_XSpeed
	JSR.w SMW_HandlePlayerPoseAndAnimationTimersDuringEnding_Main
	LDA.b #$52
	STA.b !RAM_SMW_NorSpr035_Yoshi_EndingXPosLo
	STZ.w !RAM_SMW_NorSpr035_Yoshi_EndingXPosHi
	LDA.b #$8F
	STA.b !RAM_SMW_NorSpr035_Yoshi_EndingYPosLo
	STZ.w !RAM_SMW_NorSpr035_Yoshi_EndingYPosHi
	LDA.b #$A0
	STA.w !RAM_SMW_NorSpr035_Yoshi_EndingOAMIndex
	JSR.w SMW_SpawnEndingYoshiSpriteAndDrawPlayer_Main
	LDX.w !RAM_SMW_NorSpr_AnimationFrame
	LDA.b #$51
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w PeachOnYoshiOffset,x
	CLC
	ADC.b #$85
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TXA
	ASL
	ASL
	TAY
	LDX.b #$00
	JSR.w SMW_DrawCreditsPeachRedAndYellowYoshi_Peach
	LDA.b #$A0
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	JSR.w SMW_MakeCreditsEggsBounce_Main
	LDA.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_DrawEndingBabyYoshis_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandlePlayerPoseAndAnimationTimersDuringEnding(Address)
namespace SMW_HandlePlayerPoseAndAnimationTimersDuringEnding
%InsertMacroAtXPosition(<Address>)

Main:
	PHB
	LDA.b #SMW_SetPlayerPose_Main>>16
	PHA
	PLB
	JSL.l SMW_SetPlayerPose_Main
	PLB
CODE_0CA764:
	STZ.w !RAM_SMW_Player_CurrentLayerPriority
	LDA.w !RAM_SMW_Player_AnimationTimer
	BEQ.b CODE_0CA76F
	DEC.w !RAM_SMW_Player_AnimationTimer
CODE_0CA76F:
	LDA.w !RAM_SMW_Timer_CapeFlapAnimation
	BEQ.b Return0CA777
	DEC.w !RAM_SMW_Timer_CapeFlapAnimation
Return0CA777:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BufferCreditsBackgrounds(Address)
namespace SMW_BufferCreditsBackgrounds
%InsertMacroAtXPosition(<Address>)

; Table indexed by $1928*2, which is used to indicate the cutscene number in
; the beginning of the credits (as in, castle = #$00, chocolate island BG =
; #$01, etc.). Points to BG image to use. All images are in bank $0C.
Layer2Pointers:
	dw SMW_Backgrounds_Layer2_Castle,SMW_Backgrounds_Layer2_Rocks,SMW_Backgrounds_Layer2_Forest,SMW_Backgrounds_Layer2_Clouds
	dw SMW_Backgrounds_Layer2_Mountains,SMW_Backgrounds_Layer2_Rocks2,SMW_Backgrounds_Layer2_SmallHills

; Table indexed by $1928*2. Is used to clear certain bits of the loaded BG
; tile out, specifically, but not necessarily, the properties byte
; (YXPCCCTT) of the BG tile. Some BG images in the credits require bit 8 to
; be clear ($FEFF).
TilePageModifier:
	dw $FFFF,$FEFF,$FEFF,$FEFF
	dw $FFFF,$FEFF,$FEFF

; Routine that uploads all the credit backgrounds into the $7F4000, then
; uploads the first one into VRAM. It works by looping through all 7
; backgrounds (pointed by the table at $0C93C1). For each one, the BG data
; is first copied to $7EB900 and $7EBD00, then this address is then copied
; to $7F4000+<BG number>*$800. After this loop, the first BG from $7F4000 is
; uploaded to VRAM and the staff roll song is played. $0C9447: [$09] song
; number used during the credits staff roll.
Main:
	REP.b #$30			; AXY->16
	STZ.w !RAM_SMW_Pointer_CreditsBackgroundIndex
CODE_0C93E2:
	LDA.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	AND.w #$00FF
	ASL
	TAX
	LDA.l Layer2Pointers,x
	STA.b !RAM_SMW_Pointer_Layer2DataLo
	LDA.l TilePageModifier,x
	STA.b !RAM_SMW_Misc_ScratchRAM7E0065
	SEP.b #$20			; A->8
	LDY.w #$0000
	LDX.b !RAM_SMW_Pointer_Layer2DataLo
	CPX.w #SMW_Backgrounds_Layer2_Cave
	BCC.b CODE_0C9405
	LDY.w #$0001
CODE_0C9405:
	LDX.w #$0000
	TYA
CODE_0C9409:
	STA.l !RAM_SMW_Blocks_Layer2TilesHi,x
	STA.l !RAM_SMW_Blocks_Layer2TilesHi+$0200,x
	INX
	CPX.w #$0200
	BNE.b CODE_0C9409
	LDA.b #SMW_Backgrounds_Layer2>>16
	STA.b !RAM_SMW_Pointer_Layer2DataBank
	LDX.w #!RAM_SMW_Blocks_Layer2TilesLo
	STX.b !RAM_SMW_Misc_ScratchRAM0D
	REP.b #$20			; A->16
	JSR.w CODE_0C944C
	JSR.w CODE_0C94C0
	INC.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	LDA.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	CMP.w #$0007
	BNE.b CODE_0C93E2
	LDA.w #$5840
	STA.b !RAM_SMW_Misc_CreditsStripeImageHeaderLo
	SEP.b #$30			; AXY->8
	STZ.b !RAM_SMW_Misc_CreditsStripeImageIndex
	STZ.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	JSL.l SMW_UpdateCreditsBackground_Main
	JSR.w SMW_InitializeCreditsEggPositions_Main
	LDA.b #!Define_SMW_CreditsMusic_StaffRoll
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	RTL

; Routine called during the credits initialization, specifically by the
; routine at $0C93DD. It uploads the background image data pointed by $68 to
; the address pointed by $0D. In practice, this is called to upload one of
; the staff roll backgrounds to $7EB900.
CODE_0C944C:
	REP.b #$30			; AXY->16
	LDY.w #$0000
	STY.b !RAM_SMW_Misc_ScratchRAM03
	STY.b !RAM_SMW_Misc_ScratchRAM05
	SEP.b #$20			; A->8
	LDA.b #!RAM_SMW_Blocks_Layer2TilesLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0F
CODE_0C945B:
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM07
	INY
	STY.b !RAM_SMW_Misc_ScratchRAM03
	AND.b #$80
	BEQ.b CODE_0C9480
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	AND.b #$7F
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	INY
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b !RAM_SMW_Misc_ScratchRAM05
CODE_0C9475:
	STA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM07
	BPL.b CODE_0C9475
	STY.b !RAM_SMW_Misc_ScratchRAM05
	BRA.b CODE_0C9492

CODE_0C9480:
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	INY
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b !RAM_SMW_Misc_ScratchRAM05
	STA.b [!RAM_SMW_Misc_ScratchRAM0D],y
	INY
	STY.b !RAM_SMW_Misc_ScratchRAM05
	DEC.b !RAM_SMW_Misc_ScratchRAM07
	BPL.b CODE_0C9480
CODE_0C9492:
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	CMP.b #$FF
	BNE.b CODE_0C945B
	INY
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	CMP.b #$FF
	BNE.b CODE_0C945B
	REP.b #$20			; A->16
	LDA.w #SMW_Map16Data_Backgrounds
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w #$0000
CODE_0C94AB:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Pointer_Map16Tiles,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INX
	INX
	CPX.w #$0400
	BNE.b CODE_0C94AB
	RTS

; Routine called during credits initialization, specifically by the routine
; at $0C93DD. It copies the background data at $7EB900 and $7EBD00
; (transforming it from map16 data to raw tilemap data) into one portion of
; the $7F4000 buffer.
CODE_0C94C0:
	SEP.b #$20			; A->8
	REP.b #$10			; XY->16
	LDX.w #!RAM_SMW_Blocks_Layer2TilesLo
	STX.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	LDA.b #!RAM_SMW_Blocks_Layer2TilesLo>>16
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataBank
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataBank
	LDX.w #!RAM_SMW_Blocks_Layer2TilesHi
	STX.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	LDA.b #SMW_Map16Data_Backgrounds>>16
	STA.b !RAM_SMW_Pointer_Layer2DataBank
	LDY.w #$00F0
	STY.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	XBA
	AND.b #$00
	TAX
	STX.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w #$007F
	STX.b !RAM_SMW_Misc_ScratchRAM08
CODE_0C94EB:
	SEP.b #$20			; A->8
	LDY.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	ASL
	TAX
	LDA.w !RAM_SMW_Pointer_Map16Tiles,x
	STA.b !RAM_SMW_Pointer_Layer2DataLo
	LDY.w #$0000
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	ASL
	PHA
	AND.w #$003F
	STA.b !RAM_SMW_Misc_ScratchRAM06
	PLA
	AND.w #$FFC0
	ASL
	ORA.b !RAM_SMW_Misc_ScratchRAM06
	TAX
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	AND.b !RAM_SMW_Misc_ScratchRAM7E0065
	STA.l !RAM_SMW_Misc_CreditsBackgroundBuffer,x
	INY
	INY
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	AND.b !RAM_SMW_Misc_ScratchRAM7E0065
	STA.l !RAM_SMW_Misc_CreditsBackgroundBuffer+$40,x
	INY
	INY
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	AND.b !RAM_SMW_Misc_ScratchRAM7E0065
	STA.l !RAM_SMW_Misc_CreditsBackgroundBuffer+$02,x
	INY
	INY
	LDA.b [!RAM_SMW_Pointer_Layer2DataLo],y
	AND.b !RAM_SMW_Misc_ScratchRAM7E0065
	STA.l !RAM_SMW_Misc_CreditsBackgroundBuffer+$42,x
	INC.b !RAM_SMW_Misc_ScratchRAM00
	INC.b !RAM_SMW_Misc_ScratchRAM04
	DEC.b !RAM_SMW_Misc_ScratchRAM08
	BPL.b CODE_0C94EB
	LDA.w #$007F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CMP.w #$0170
	BNE.b Return0C9558
	LDA.w #$02A0
	STA.b !RAM_SMW_Misc_ScratchRAM04
	BRA.b CODE_0C94EB

Return0C9558:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_InitializeCreditsEggPositions(Address)
namespace SMW_InitializeCreditsEggPositions
%InsertMacroAtXPosition(<Address>)

InitialXPos:
	db $63,$73,$83,$93,$A3,$B3,$C3

InitialYPos:
	db $A0,$9C,$A0,$9C,$A0,$9C,$A0

Main:
	PHB
	PHK
	PLB
	LDX.b #!Define_SMW_MaxCutsceneSpriteSlot
CODE_0CA056:
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubYPos,x
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubXPos,x
	DEX
	BPL.b CODE_0CA056
	LDX.b #!Define_SMW_MaxCutsceneSpriteSlot-$01
	LDY.b #$06
CODE_0CA063:
	LDA.w InitialYPos,y
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi,x
	LDA.w InitialXPos,y
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo,x
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi,x
	LDA.w SMW_GameMode1D_LoadYoshisHouse_EggYSpeed,y
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	LDA.b #$01
	STA.w !RAM_SMW_CutsceneSprites_CreditsEgg_YAcceleration,x
	DEY
	DEX
	CPX.b #!Define_SMW_MaxCutsceneSpriteSlot-$08
	BNE.b CODE_0CA063
	STZ.b !RAM_SMW_Player_FacingDirection
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDA.b #$FE
else
	LDA.b #$E2
endif
	STA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	PLB
	RTS
namespace off
endmacro

macro DATATABLE_RT01_SMW_Backgrounds(Address)
namespace SMW_Backgrounds
%InsertMacroAtXPosition(<Address>)

; World 4 Castle Destruction Scene Layer 2 Tilemap
CastleDestruction:
.CookieMountain:
	incbin "images/cutscenes/cookiemountain.bin"
; Castle Destruction Scene Layer 1 Tilemap (Castle)
.Castle:
	incbin "images/cutscenes/castle.bin"
; World 3/7 Castle Destruction Scene Layer 2 Tilemap
.Cave:
	incbin "images/cutscenes/cave.bin"
; World 6 Castle Destruction Scene Layer 2 Tilemap
.ChocolateIsland:
	incbin "images/cutscenes/chocolateisland.bin"
; World 1/2/5 Castle Destruction Scene Layer 2 Tilemap
.Overworld:
	incbin "images/cutscenes/overworld.bin"
namespace off
endmacro

macro DATATABLE_RT02_SMW_Backgrounds(Address)
namespace SMW_Backgrounds
%InsertMacroAtXPosition(<Address>)

; Tilemap of the oblong hill background (the one that appears in, e.g.,
; level 105), in LC_RLE1 format.
Layer2:
.Mountains:
	incbin "levels/backgrounds/mountains.bin"
; Tilemap of the underwater background (the one that appears in, e.g., level
; A), in LC_RLE1 format.
.Water:
	incbin "levels/backgrounds/water.bin"
; Tilemap of the cloud/mountain background (the one that appears in level
; 125), in LC_RLE1 format.
.CloudyHills:
	incbin "levels/backgrounds/cloudyhills.bin"
; Tilemap of the cloud background (the one that appears in, e.g., level 1),
; in LC_RLE1 format.
.Clouds:
	incbin "levels/backgrounds/clouds.bin"
; Tilemap of the shallow hills background (the one that appears in, e.g.,
; level 15), in LC_RLE1 format.
.SmallHills:
	incbin "levels/backgrounds/smallhills.bin"
; Tilemap of the "odd land formations with clouds" background (the one that
; appears in, e.g., level 102), in LC_RLE1 format.
.Rocks2:
	incbin "levels/backgrounds/rocks2.bin"
; Tilemap of the castle background with pillars (the one that appears in,
; e.g., level 1F), in LC_RLE1 format.
.Castle2:
	incbin "levels/backgrounds/castle2.bin"
; Tilemap of the large mountain background (the one that appears in, e.g.,
; level 12B), in LC_RLE1 format.
.LargeHills:
	incbin "levels/backgrounds/largehills.bin"
; Tilemap of the switch palace background (the one that appears in, e.g.,
; level 14), in LC_RLE1 format.
.Bonus:
	incbin "levels/backgrounds/bonus.bin"
; Tilemap of the starry night background (the one that appears in, e.g.,
; level 119), in LC_RLE1 format.
.Stars:
	incbin "levels/backgrounds/stars.bin"
; Tilemap of the "pointy land formations" background (the one that appears
; in, e.g., level 23), in LC_RLE1 format.
.Rocks:
	incbin "levels/backgrounds/rocks.bin"
; Tilemap of the blank background (the one that appears in level F7), in
; LC_RLE1 format.
.Black:
	incbin "levels/backgrounds/black.bin"
; Tilemap of the underground background (the one that appears in, e.g.,
; level 11A), in LC_RLE1 format.
.Cave:
	incbin "levels/backgrounds/cave.bin"
; Tilemap of the forest background (the one that appears in, e.g., level
; 106), in LC_RLE1 format.
.Forest:
	incbin "levels/backgrounds/forest.bin"
; Tilemap of the ghost house background (the one that appears in, e.g.,
; level 4), in LC_RLE1 format.
.GhostHouse:
	incbin "levels/backgrounds/ghosthouse.bin"
; Tilemap of the sunken ship background (the one that appears in level F8),
; in LC_RLE1 format.
.SunkenGhostShip:
	incbin "levels/backgrounds/sunkenghostship.bin"
; Tilemap of the castle background with windows (the one that appears in,
; e.g., level 7), in LC_RLE1 format.
.Castle:
	incbin "levels/backgrounds/castle.bin"
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MakeCreditsEggsBounce(Address)
namespace SMW_MakeCreditsEggsBounce
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #!Define_SMW_MaxCutsceneSpriteSlot-$01
CODE_0CA8A5:
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	CLC
	ADC.w !RAM_SMW_CutsceneSprites_CreditsEgg_YAcceleration,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	JSR.w SMW_UpdateCutsceneSpritePosition_Y
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	CMP.b !RAM_SMW_Misc_ScratchRAM0E
	BCC.b CODE_0CA8CB
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubYPos,x
	LDA.b #$F6
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	LDA.b #$01
	STA.w !RAM_SMW_CutsceneSprites_CreditsEgg_YAcceleration,x
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
CODE_0CA8CB:
	DEX
	CPX.b #!Define_SMW_MaxCutsceneSpriteSlot-$08
	BNE.b CODE_0CA8A5
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawEndingBabyYoshis(Address)
namespace SMW_DrawEndingBabyYoshis
%InsertMacroAtXPosition(<Address>)

UNK_0CA8D1:
	db $00,$10,$20,$30,$40,$50,$60 			; Note: Unused, probably did something similar to what EndingYoshiHouseState02_DATA_0CA52B is used for.

; Palettes of Baby Yoshis (Ending)
BabyYoshiProp:
	db $68,$26,$24,$6A,$28,$64,$26

Main:
	LDA.w !RAM_SMW_Sprites_WhichEndingEggsHatched
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDY.b #!Define_SMW_MaxCutsceneSpriteSlot-$01
CODE_0CA8E6:
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi,y
	BNE.b CODE_0CA934
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LSR.b !RAM_SMW_Misc_ScratchRAM0E
	BCS.b CODE_0CA911
	LDA.b #$86
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.b #$21
	STA.w SMW_OAMBuffer[$00].Prop,x
	BRA.b CODE_0CA923

CODE_0CA911:
	PHY
	TYA
	SEC
	SBC.b #$07
	TAY
	LDA.b #$EA
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.w BabyYoshiProp,y
	STA.w SMW_OAMBuffer[$00].Prop,x
	PLY
CODE_0CA923:
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	INC.b !RAM_SMW_Misc_ScratchRAM02
	INC.b !RAM_SMW_Misc_ScratchRAM02
	INC.b !RAM_SMW_Misc_ScratchRAM02
	INC.b !RAM_SMW_Misc_ScratchRAM02
CODE_0CA934:
	DEY
	CPY.b #!Define_SMW_MaxCutsceneSpriteSlot-$08
	BNE.b CODE_0CA8E6
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnEndingYoshiSpriteAndDrawPlayer(Address)
namespace SMW_SpawnEndingYoshiSpriteAndDrawPlayer
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #$00
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
	LDA.b #!Define_SMW_SpriteID_NorSpr035_Yoshi
	STA.b !RAM_SMW_NorSpr_SpriteID
	LDA.w !RAM_SMW_NorSpr_AnimationFrame
	PHA
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLA
	STA.w !RAM_SMW_NorSpr_AnimationFrame
	LDA.b #$02
	STA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection
	LDA.w !RAM_SMW_ScrollSpr_LayerIndex
	CLC
	ADC.b #$38
	STA.w !RAM_SMW_ScrollSpr_LayerIndex
	BCC.b CODE_0CA7AF
	LDA.w !RAM_SMW_NorSpr_AnimationFrame
	INC
	STA.w !RAM_SMW_NorSpr_AnimationFrame
	CMP.b #$03
	BCC.b CODE_0CA7AF
	STZ.w !RAM_SMW_NorSpr_AnimationFrame
CODE_0CA7AF:
	LDA.b #$01
	STA.w !RAM_SMW_Yoshi_StrayYoshiFlag
CODE_0CA7B4:
	JSL.l SMW_PlayerGFXRt_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CreditsFadeOut(Address)
namespace SMW_CreditsFadeOut
%InsertMacroAtXPosition(<Address>)

Main:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

DATA_0CAB1B:
	db $FE,$02

DATA_0CAB1D:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	db $00,$FE
else
	db $00,$E0			;!
endif

Sub:
	LDX.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
	LDA.b #$33
	STA.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings
	LDY.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	BNE.b CODE_0CAB2F
	CPX.b #$00
	BEQ.b CODE_0CAB3B
CODE_0CAB2F:
	CPY.b #$06
	BCC.b CODE_0CAB39
	BNE.b CODE_0CAB3B
	CPX.b #$00
	BNE.b CODE_0CAB3B
CODE_0CAB39:
	LDA.b #$30
CODE_0CAB3B:
	STA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings
	LDA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	CMP.w DATA_0CAB1D,x
	BNE.b CODE_0CAB64
	CPX.b #$00
	BEQ.b CODE_0CAB6B
	LDX.b #$00
	STX.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
	CPY.b #$06
	BCC.b CODE_0CAB57
	INC.w !RAM_SMW_Misc_GameMode
	BRA.b CODE_0CAB6B

CODE_0CAB57:
	PHA
	PHX
	INC.w !RAM_SMW_Flag_UpdateCreditsBackground
	INC.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	JSR.w CODE_0CABB2
	PLX
	PLA
CODE_0CAB64:
	CLC
	ADC.w DATA_0CAB1B,x
	STA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
CODE_0CAB6B:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	REP.b #$30
	LDA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	AND.w #$00FF
	STA.w !RAM_SMW_Misc_ScratchRAM0110
	LDX.w #$0000
	LDY.w #$00FE
	LDA.w #$00FF

-:
	CPX.w !RAM_SMW_Misc_ScratchRAM0110
	BCC.b +
	BEQ.b +
	LDA.w #$FF00

+:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$DE,y
	CPX.w #$001E
	BMI.b +
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable-$1E,x

+:
	INX
	INX
	DEY
	DEY
	BNE.b -
	SEP.b #$30
else
	REP.b #$20			;! A->16
	LDX.b #$00			;!
	LDY.b #$E0			;!
	LDA.w #$00FF			;!
CODE_0CAB74:
	CPX.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange	;!
	BCC.b CODE_0CAB7C		;!
	LDA.w #$FF00			;!
CODE_0CAB7C:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable,x	;!
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$DE,y	;!
	INX				;!
	INX				;!
	DEY				;!
	DEY				;!
	BNE.b CODE_0CAB74		;!
	SEP.b #$20			;! A->8
endif
	LDA.b #$13
	STA.w !REGISTER_MainScreenWindowMask	; Window Mask Designation for Main Screen
	STA.w !REGISTER_SubScreenWindowMask	; Window Mask Designation for Sub Screen
	LDA.b #$22
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings
	LDA.b #$80
	STA.w !RAM_SMW_Mirror_HDMAEnable
	RTS

BGPaletteIndex:
	db SMW_GlobalPalettes_Background_Setting00-SMW_GlobalPalettes_Background
	db SMW_GlobalPalettes_Background_Setting01-SMW_GlobalPalettes_Background
	db SMW_GlobalPalettes_Background_Setting02-SMW_GlobalPalettes_Background
	db SMW_GlobalPalettes_Background_Setting03-SMW_GlobalPalettes_Background
	db SMW_GlobalPalettes_Background_Setting04-SMW_GlobalPalettes_Background
	db SMW_GlobalPalettes_Background_Setting05-SMW_GlobalPalettes_Background
	db SMW_GlobalPalettes_Background_Setting06-SMW_GlobalPalettes_Background
	db SMW_GlobalPalettes_Background_Setting07-SMW_GlobalPalettes_Background

; Points to BG colour to use at the cutscenes in the beginning of the
; credits. First value not used?
SkyColorSetting:
	db $06,$00,$00,$02,$05,$06,$00

BGPaletteSetting:
	db $03,$03,$07,$00,$01,$02,$00

CODE_0CABB2:
	SEP.b #$30			; AXY->8
	LDA.b #$0C
	STA.w !RAM_SMW_Palettes_DynamicPaletteBytesToUpload
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors+$0C
	LDA.b #$02
	STA.w !RAM_SMW_Palettes_DynamicPaletteCGRAMAddress
	LDA.b #$12
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors+$0D
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	AND.w #$00FF
	TAY
	LDA.w SkyColorSetting,y
	AND.w #$000F
	ASL
	TAX
	LDA.l SMW_GlobalPalettes_Sky,x
	STA.w !RAM_SMW_Palettes_BackgroundColorLo
	LDA.w #SMW_GlobalPalettes_Background
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w BGPaletteSetting,y
	AND.w #$000F
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l BGPaletteIndex,x
else
	LDA.w BGPaletteIndex,x
endif
	AND.w #$00FF
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
if ver_is_smasw(!Define_Global_ROMToAssemble)
	LDA.w #SMW_GlobalPalettes_Main>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
else
	STZ.b !RAM_SMW_Misc_ScratchRAM02 		; Note: #!BANK_00
endif
	LDA.w #$0000
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
CODE_0CAC01:
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDY.w #$0005
CODE_0CAC06:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors,x
	INC.b !RAM_SMW_Misc_ScratchRAM00
	INC.b !RAM_SMW_Misc_ScratchRAM00
	INX
	INX
	DEY
	BPL.b CODE_0CAC06
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CLC
	ADC.w #$000E
	STA.b !RAM_SMW_Misc_ScratchRAM04
	DEC.b !RAM_SMW_Misc_ScratchRAM08
	BPL.b CODE_0CAC01
	LDA.w #$0000
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors,x
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_DrawingTheEndMarioLuigiAndPeach(Address)
namespace SMW_DrawingTheEndMarioLuigiAndPeach
%InsertMacroAtXPosition(<Address>)

; Mario, Luigi and Peach ending image tilemap
TileData:
	db $53,$6A,$80,$3C		;\ Mario
	db $63,$6A,$82,$3C		;|
	db $53,$7A,$A0,$3C		;|
	db $63,$7A,$A2,$3C		;|
	db $53,$8A,$84,$3C		;|
	db $63,$8A,$86,$3C		;|
	db $53,$9A,$A4,$3C		;|
	db $63,$9A,$A6,$3C		;|
	db $53,$AA,$88,$3C		;|
	db $63,$AA,$8A,$3C		;/
	db $8D,$5A,$A8,$3A		;\ Luigi
	db $9D,$5A,$AA,$3A		;|
	db $8D,$6A,$8C,$3A		;|
	db $9D,$6A,$8E,$3A		;|
	db $8D,$7A,$AC,$3A		;|
	db $9D,$7A,$AE,$3A		;|
	db $8D,$8A,$63,$3A		;|
	db $9D,$8A,$65,$3A		;|
	db $8D,$9A,$48,$3A		;|
	db $9D,$9A,$68,$3A		;|
	db $8D,$AA,$6B,$3A		;|
	db $9D,$AA,$6D,$3A		;/
	db $78,$58,$4D,$3E		;\ Peach
	db $70,$68,$E0,$3F		;|
	db $80,$68,$C4,$3F		;|
	db $70,$78,$4A,$3F		;|
	db $80,$78,$4C,$3F		;|
	db $70,$88,$6A,$3F		;|
	db $80,$88,$6C,$3F		;|
	db $68,$98,$AB,$3F		;|
	db $78,$98,$C8,$3F		;|
	db $88,$98,$E6,$3F		;|
	db $68,$A8,$E8,$3F		;|
	db $78,$A8,$EA,$3F		;|
	db $88,$A8,$EC,$3F		;/

Main:
	PHB
	PHK
	PLB
	LDX.b #$00
	TXY
CODE_0CAAE5:
	LDA.w TileData,y
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.w TileData+$01,y
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LDA.w TileData+$02,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.w TileData+$03,y
	STA.w SMW_OAMBuffer[$00].Prop,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	PLX
	INX
	INX
	INX
	INX
	TXY
	CPY.b #$8C
	BNE.b CODE_0CAAE5
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_GameMode1D_LoadYoshisHouse(Address)
namespace SMW_GameMode1D_LoadYoshisHouse
%InsertMacroAtXPosition(<Address>)

Bank0C:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w DrawEndingYoshisHouseDecorations
	JSR.w CODE_0CA1D4
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_GameMode1D_LoadYoshisHouse(Address)
namespace SMW_GameMode1D_LoadYoshisHouse
%InsertMacroAtXPosition(<Address>)

; Yoshi's House decoration tiles (Ending)
Tiles:
	db $FF,$02,$04,$06,$08,$06,$08,$06,$08,$06,$08,$04,$02,$FF
	db $20,$22,$24,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$24,$22,$20
	db $40,$42,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$42,$40

; Yoshi's House decoration palettes (Ending)
Prop:
	db $FF,$37,$37,$35,$35,$37,$37,$39,$39,$3B,$3B,$77,$77,$FF
	db $37,$37,$37,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$77,$77,$77
	db $37,$37,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$77,$77

DrawEndingYoshisHouseDecorations:
	LDA.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$2F
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDX.b #$90
	LDY.b #$00
CODE_0CA0F1:
	LDA.w Tiles,y
	CMP.b #$FF
	BEQ.b CODE_0CA11A
	STA.w SMW_OAMBuffer[$40].Tile,x
	LDA.w Prop,y
	STA.w SMW_OAMBuffer[$40].Prop,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x
	PLX
	INX
	INX
	INX
	INX
CODE_0CA11A:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$F0
	BNE.b CODE_0CA130
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM01
CODE_0CA130:
	INY
	CPY.b #$2A
	BNE.b CODE_0CA0F1
	RTS
namespace off
endmacro

macro ROUTINE_RT03_SMW_GameMode1D_LoadYoshisHouse(Address)
namespace SMW_GameMode1D_LoadYoshisHouse
%InsertMacroAtXPosition(<Address>)

CODE_0CA1D4:
	JSR.w SMW_CreditsFadeOut_Sub
	LDA.w !RAM_SMW_Pointer_CurrentYoshiHouseSceneProcess
	JSL.l SMW_ExecutePtr_Long

PtrsLong0CA1DE:
	dl SMW_WalkingIntoYoshisHouseDuringEnding_Main
	dl SMW_YoshisWatchInExcitementDuringEnding_Main
	dl SMW_HatchYoshiEggsDuringEnding_Main
	dl SMW_SlideInThankYouDuringEnding_Main
	dl SMW_EveryoneCheeringDuringEnding_Main
namespace off
endmacro

macro ROUTINE_RT04_SMW_GameMode1D_LoadYoshisHouse(Address)
namespace SMW_GameMode1D_LoadYoshisHouse
%InsertMacroAtXPosition(<Address>)

EggInitialXPos:
	db $40,$50,$60,$70,$80,$90,$A0

EggInitialYPos:
	db $AF,$AB,$AF,$AB,$AF,$AB,$AF

EggYSpeed:
	db $F6,$00,$F6,$00,$F6,$00,$F6

InitializeYoshisHouseSceneRAM:
	PHB
	PHK
	PLB
	LDA.b #$01
	STA.w !RAM_SMW_Sprites_DrawEndingYoshis
	STZ.b !RAM_SMW_Player_FacingDirection
	STZ.w !RAM_SMW_Pointer_CurrentYoshiHouseSceneProcess
	LDA.b #$00
	STA.w !RAM_SMW_Sprites_EndingPlayerXPosLo
	LDA.b #$01
	STA.w !RAM_SMW_Sprites_EndingPlayerXPosHi
	STZ.w !RAM_SMW_Sprites_EndingPlayerSubXPos
	STZ.w !RAM_SMW_Sprites_EndingYoshisSubXPos
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubXPos+$07
	LDA.b #$06
	STA.w !RAM_SMW_Sprites_EndingPeachWalkBobbingTimer
	STZ.w !RAM_SMW_Sprites_EndingPeachWalkBobbingFlag
	STZ.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	LDA.b #$06
	STA.w !RAM_SMW_Sprites_WaitBeforeNextEndingYoshiDuckFrame
	LDA.b #$F0
	STA.w !RAM_SMW_Sprites_EndingYoshisYSpeed
	LDA.b #$9F
	STA.w !RAM_SMW_Sprites_EndingYoshisYPosLo
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDA.b #$FE
else
	LDA.b #$E2
endif
	STA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	STA.w !RAM_SMW_Pointer_CreditsBackgroundIndex
	LDA.b #!Define_SMW_CreditsMusic_TheYoshisAreHome
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	LDX.b #!Define_SMW_MaxCutsceneSpriteSlot-$01
	LDY.b #$06
CODE_0CA414:
	LDA.w EggInitialYPos,y
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi,x
	LDA.w EggInitialXPos,y
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo,x
	LDA.w EggYSpeed,y
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	LDA.b #$01
	STA.w !RAM_SMW_CutsceneSprites_CreditsEgg_YAcceleration,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi,x
	DEY
	DEX
	CPX.b #!Define_SMW_MaxCutsceneSpriteSlot-$08
	BNE.b CODE_0CA414
	PLB
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_WalkingIntoYoshisHouseDuringEnding(Address)
namespace SMW_WalkingIntoYoshisHouseDuringEnding
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_ProcessCheeringYoshis_Main
	LDA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	BEQ.b CODE_0CA1F6
	RTS

CODE_0CA1F6:
	LDA.b #$60
	STA.b !RAM_SMW_Player_YPosLo
	LDA.b #$01
	STA.b !RAM_SMW_Player_YPosHi
	LDX.b #$00
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosLo,x
	CMP.b #$70
	BNE.b CODE_0CA24F
	STZ.w !RAM_SMW_Yoshi_StrayYoshiFlag
	LDA.b #$0F			; \ Mario's image = Going Down Pipe
	STA.w !RAM_SMW_Player_CurrentPose
	JSR.w SMW_HandlePlayerPoseAndAnimationTimersDuringEnding_CODE_0CA764
	JSR.w SMW_SpawnEndingYoshiSpriteAndDrawPlayer_CODE_0CA7B4
	LDA.w !RAM_SMW_Pointer_CurrentYoshiHouseSceneProcess
	BNE.b CODE_0CA22D
	LDA.b !RAM_SMW_NorSpr035_Yoshi_EndingXPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$9F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDY.b #$00
	LDX.b #$B4
	LDA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	JSR.w SMW_DrawCameraFacingEndingYoshis_GreenYoshi
CODE_0CA22D:
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$9F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$03							;\ Optimization: LDY.b #$0C?
	ASL								;|
	ASL								;|
	TAY								;/
	LDX.b #$A4
	JSR.w SMW_DrawCreditsPeachRedAndYellowYoshi_Peach
	BRL.w CODE_0CA2C3

CODE_0CA24F:
	LDA.b #$F8
	STA.w !RAM_SMW_Sprites_EndingPlayerXSpeed,x
	JSR.w SMW_UpdateCutsceneSpritePosition_X
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosLo,x
	STA.b !RAM_SMW_Player_XPosLo
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosHi,x
	STA.b !RAM_SMW_Player_XPosHi
	LDA.b #$01
	STA.b !RAM_SMW_Player_CurrentPowerUp
	LDA.b #$08
	STA.w !RAM_SMW_Player_XSpeed
	JSR.w SMW_HandlePlayerPoseAndAnimationTimersDuringEnding_Main
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosLo
	CLC
	ADC.b #$30
	STA.b !RAM_SMW_NorSpr035_Yoshi_EndingXPosLo
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosHi
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr035_Yoshi_EndingXPosHi
	LDA.b #$60
	STA.b !RAM_SMW_NorSpr035_Yoshi_EndingYPosLo
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr035_Yoshi_EndingYPosHi
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr_OAMIndex
	JSR.w SMW_SpawnEndingYoshiSpriteAndDrawPlayer_Main
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$9F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	DEC.w !RAM_SMW_Sprites_EndingPeachWalkBobbingTimer
	BPL.b CODE_0CA2B5
	LDA.b #$06
	STA.w !RAM_SMW_Sprites_EndingPeachWalkBobbingTimer
	LDA.w !RAM_SMW_Sprites_EndingPeachWalkBobbingFlag
	EOR.b #$01
	STA.w !RAM_SMW_Sprites_EndingPeachWalkBobbingFlag
CODE_0CA2B5:
	LDA.w !RAM_SMW_Sprites_EndingPeachWalkBobbingFlag
	CLC
	ADC.b #$03
	ASL
	ASL
	TAY
	LDX.b #$A4
	JSR.w SMW_DrawCreditsPeachRedAndYellowYoshi_Peach
CODE_0CA2C3:
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$07
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi+$07
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.w #$0030
	BNE.b CODE_0CA2E0
	LDA.w !RAM_SMW_Pointer_CurrentYoshiHouseSceneProcess
	BNE.b CODE_0CA2FC
	INC.w !RAM_SMW_Pointer_CurrentYoshiHouseSceneProcess
	BRA.b CODE_0CA2FC

CODE_0CA2E0:
	SEP.b #$20			; A->8
	LDX.b #!Define_SMW_MaxCutsceneSpriteSlot-$01
CODE_0CA2E4:
	CPX.b #!Define_SMW_MaxCutsceneSpriteSlot-$03
	BCC.b CODE_0CA2EF
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$0B
	CMP.b #$98
	BEQ.b CODE_0CA2F7
CODE_0CA2EF:
	LDA.b #$F8
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXSpeed,x
	JSR.w SMW_UpdateCutsceneSpritePosition_X
CODE_0CA2F7:
	DEX
	CPX.b #!Define_SMW_MaxCutsceneSpriteSlot-$08
	BNE.b CODE_0CA2E4
CODE_0CA2FC:
	SEP.b #$20			; A->8
	LDA.b #$AF
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	JSR.w SMW_MakeCreditsEggsBounce_Main
	LDA.b #$88
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_DrawEndingBabyYoshis_Main
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_ProcessCheeringYoshis(Address)
namespace SMW_ProcessCheeringYoshis
%InsertMacroAtXPosition(<Address>)

DATA_0CA30D:
	db $00,$01,$02,$01

DATA_0CA311:
	db $00,$01,$01,$01

Main:
	LDX.b #$01
	LDA.w !RAM_SMW_Sprites_EndingYoshisYSpeed-$01,x
	CLC
	ADC.b #$01
	STA.w !RAM_SMW_Sprites_EndingYoshisYSpeed-$01,x
	JSR.w SMW_UpdateCutsceneSpritePosition_Y
	LDA.w !RAM_SMW_Sprites_EndingYoshisYPosLo-$01,x
	CMP.b #$9F
	BCC.b CODE_0CA334
	LDA.b #$F0
	STA.w !RAM_SMW_Sprites_EndingYoshisYSpeed-$01,x
	LDA.b #$9F
	STA.w !RAM_SMW_Sprites_EndingYoshisYPosLo-$01,x
CODE_0CA334:
	LDY.b #$00
	LDA.w !RAM_SMW_Sprites_EndingYoshisYSpeed
	BPL.b CODE_0CA349
	CMP.b #$F4
	BCC.b CODE_0CA355
	LDY.b #$01
	CMP.b #$F8
	BCC.b CODE_0CA355
	LDY.b #$02
	BRA.b CODE_0CA349 						; Optimization: BRA to the next instruction...

CODE_0CA349:
	CMP.b #$0C
	BCS.b CODE_0CA355
	LDY.b #$01
	CMP.b #$08
	BCS.b CODE_0CA355
	LDY.b #$02
CODE_0CA355:
	STY.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	LDA.w !RAM_SMW_Sprites_DrawEndingYoshis
	BEQ.b Return0CA3B3
	CMP.b #$01
	BNE.b Return0CA3B3
	LDA.b #$18
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_Sprites_EndingYoshisYPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDY.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	LDA.w DATA_0CA30D,y
	CLC
	ADC.b #$07
	ASL
	ASL
	TAY
	LDX.b #$D0
	JSR.w SMW_DrawCreditsPeachRedAndYellowYoshi_RedYoshi
	LDA.b #$D4
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_Sprites_EndingYoshisYPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDY.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	LDA.w DATA_0CA30D,y
	CLC
	ADC.b #$0A
	ASL
	ASL
	TAY
	LDX.b #$F0
	JSR.w SMW_DrawCreditsPeachRedAndYellowYoshi_YellowYoshi
	LDY.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	LDA.w SMW_ProcessCheeringYoshis_DATA_0CA311,y
	ASL
	TAY
	LDA.b #$50
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_EndingYoshisYPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$F0
	LDA.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	JSR.w SMW_DrawCameraFacingEndingYoshis_BlueYoshi
Return0CA3B3:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_YoshisWatchInExcitementDuringEnding(Address)
namespace SMW_YoshisWatchInExcitementDuringEnding
%InsertMacroAtXPosition(<Address>)

DATA_0CA439:
	db $00,$02,$02

Main:
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	CMP.b #$08
	BCS.b CODE_0CA45C
	JSR.w SMW_ProcessCheeringYoshis_Main
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	BNE.b CODE_0CA457
	LDA.w !RAM_SMW_Sprites_EndingYoshisYPosLo
	CMP.b #$9F
	BNE.b CODE_0CA457
	LDA.b #$08
	STA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
CODE_0CA457:
	LDY.b #$00
	BRL.w CODE_0CA510

CODE_0CA45C:
	DEC.w !RAM_SMW_Sprites_WaitBeforeNextEndingYoshiDuckFrame
	BPL.b CODE_0CA478
	LDA.b #$06
	STA.w !RAM_SMW_Sprites_WaitBeforeNextEndingYoshiDuckFrame
	INC.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	CMP.b #$0B
	BNE.b CODE_0CA478
	LDA.b #$0A
	STA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	INC.w !RAM_SMW_Pointer_CurrentYoshiHouseSceneProcess
CODE_0CA478:
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	AND.b #$03
	BNE.b CODE_0CA4B6
	LDA.b #$18
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$9F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	AND.b #$03
	CLC
	ADC.b #$07
	ASL
	ASL
	TAY
	LDX.b #$D0
	JSR.w SMW_DrawCreditsPeachRedAndYellowYoshi_RedYoshi
	LDA.b #$D4
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$9F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	AND.b #$03
	CLC
	ADC.b #$0A
	ASL
	ASL
	TAY
	LDX.b #$F0
	JSR.w SMW_DrawCreditsPeachRedAndYellowYoshi_YellowYoshi
	BRL.w CODE_0CA4E9

CODE_0CA4B6:
	LDA.b #$18
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$A7
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	AND.b #$03
	DEC
	ASL
	ASL
	TAY
	LDX.b #$C0
	JSR.w SMW_DrawLeaningEndingYoshis_Main
	LDA.b #$CC
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$A7
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	AND.b #$03
	DEC
	CLC
	ADC.b #$02
	ASL
	ASL
	TAY
	LDX.b #$D8
	JSR.w SMW_DrawLeaningEndingYoshis_Main
CODE_0CA4E9:
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	AND.b #$03
	TAY
	LDA.w DATA_0CA439,y
	ASL
	TAY
	LDA.b #$50
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$9F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$F0
	LDA.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	JSR.w SMW_DrawCameraFacingEndingYoshis_BlueYoshi
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	AND.b #$03
	TAY
	LDA.w DATA_0CA439,y
	ASL
	TAY
CODE_0CA510:
	LDA.b !RAM_SMW_NorSpr035_Yoshi_EndingXPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$9F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$B4
	LDA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	JSR.w SMW_DrawCameraFacingEndingYoshis_GreenYoshi
	BRL.w SMW_WalkingIntoYoshisHouseDuringEnding_CODE_0CA1F6
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_HatchYoshiEggsDuringEnding(Address)
namespace SMW_HatchYoshiEggsDuringEnding
%InsertMacroAtXPosition(<Address>)

DATA_0CA524:
	db $20,$01,$10,$40,$08,$02,$04

DATA_0CA52B:
	db $10,$60,$20,$00,$30,$50,$40

Main:
	LDA.w !RAM_SMW_Flag_EndingEggIsHatching
	BEQ.b CODE_0CA53A
	BRL.w CODE_0CA5CB

CODE_0CA53A:
	LDA.b #$98
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed+$03
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed+$04
	LDA.b #$D4
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed+$05
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed+$06
	LDY.w !RAM_SMW_Counter_NumberOfEndingEggsHatched
	LDA.w DATA_0CA52B,y
	LSR
	LSR
	LSR
	LSR
	TAX
	INC
	STA.w !RAM_SMW_Flag_EndingEggIsHatching
	LDA.b #$C0
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed+$07,x
	LDA.b #$04
	STA.w !RAM_SMW_Sprites_CutsceneSpriteTable7E0AF6+$07,x	;0\A560;
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$07,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$03
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$04
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$05
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$06
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi+$03
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi+$04
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi+$05
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi+$06
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$07,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$03
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$05
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$04
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$06
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi+$03
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi+$04
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi+$05
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi+$06
	LDA.w DATA_0CA524,y
	TSB.w !RAM_SMW_Sprites_WhichEndingEggsHatched
	INC.w !RAM_SMW_Counter_NumberOfEndingEggsHatched
	LDA.w !RAM_SMW_Counter_NumberOfEndingEggsHatched
	CMP.b #$08
	BEQ.b CODE_0CA5B6
	LDA.b #!Define_SMW_Sound1DFC_EggHatch
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	BRA.b CODE_0CA5CB

CODE_0CA5B6:
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi+$02
	LDA.b #$80
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$02
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteXSpeed+$02
	LDA.b #!Define_SMW_CreditsMusic_CastList
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	INC.w !RAM_SMW_Pointer_CurrentYoshiHouseSceneProcess
	BRA.b CODE_0CA5CE

CODE_0CA5CB:
	JSR.w CODE_0CA5DE
CODE_0CA5CE:
	JSR.w SMW_YoshisWatchInExcitementDuringEnding_CODE_0CA4B6
	RTS

DATA_0CA5D2:
	db $C8,$C8,$D8,$D8

DATA_0CA5D6:
	db $26,$66,$26,$66

DATA_0CA5DA:
	db $E8,$18,$F4,$0C

CODE_0CA5DE:
	LDA.w !RAM_SMW_Flag_EndingEggIsHatching
	BEQ.b Return0CA65A
	LDX.b #$06
CODE_0CA5E5:
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	CLC
	ADC.b #$06
	CMP.b #$70
	BEQ.b CODE_0CA5F2
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
CODE_0CA5F2:
	TXA
	SEC
	SBC.b #$03
	TAY
	LDA.w DATA_0CA5DA,y
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXSpeed,x
	JSR.w SMW_UpdateCutsceneSpritePosition_Y
	JSR.w SMW_UpdateCutsceneSpritePosition_X
	DEX
	CPX.b #$02
	BNE.b CODE_0CA5E5
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$03
	AND.b #$F0
	CMP.b #$F0
	BNE.b CODE_0CA614
	STZ.w !RAM_SMW_Flag_EndingEggIsHatching
CODE_0CA614:
	LDX.b #$00
	LDY.b #$06
CODE_0CA618:
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosHi,y
	BNE.b CODE_0CA655
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosHi,y
	BNE.b CODE_0CA655
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,y
	CMP.b #$F0
	BCS.b CODE_0CA655
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo,y
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,y
	STA.w SMW_OAMBuffer[$00].YDisp,x
	PHY
	TYA
	SEC
	SBC.b #$03
	TAY
	LDA.w DATA_0CA5D2,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.w DATA_0CA5D6,y
	STA.w SMW_OAMBuffer[$00].Prop,x
	PLY
	PHX
	TXA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$00].Slot,x
	PLX
	INX
	INX
	INX
	INX
CODE_0CA655:
	DEY
	CPY.b #$02
	BNE.b CODE_0CA618
Return0CA65A:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SlideInThankYouDuringEnding(Address)
namespace SMW_SlideInThankYouDuringEnding
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #$02
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXSpeed,x
	SEC
	SBC.b #$04
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXSpeed,x
	JSR.w SMW_UpdateCutsceneSpritePosition_X
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo,x
	CMP.b #$F8
	BCC.b CODE_0CA67A
	INC.w !RAM_SMW_Pointer_CurrentYoshiHouseSceneProcess
	LDA.b #$F0
	STA.w !RAM_SMW_Timer_WaitBeforeFadingOutYoshisHouseScene
	LDA.b #$00
CODE_0CA67A:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	STZ.b !RAM_SMW_Misc_ScratchRAM03
	STZ.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b #$3F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDY.b #$00
	LDX.b #$50
	JSR.w SMW_DrawEndingThankYou_Entry2
	DEC.w !RAM_SMW_Sprites_WaitBeforeNextEndingYoshiDuckFrame
	BPL.b CODE_0CA6AC
	LDA.b #$06
	STA.w !RAM_SMW_Sprites_WaitBeforeNextEndingYoshiDuckFrame
	DEC.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	LDA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	CMP.b #$07
	BNE.b CODE_0CA6AC
	LDA.b #$08
	STA.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
CODE_0CA6AC:
	JSR.w SMW_YoshisWatchInExcitementDuringEnding_CODE_0CA478
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_EveryoneCheeringDuringEnding(Address)
namespace SMW_EveryoneCheeringDuringEnding
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_DrawEndingThankYou_Main
	JSR.w SMW_ProcessCheeringYoshis_Main
	JSR.w SMW_WalkingIntoYoshisHouseDuringEnding_CODE_0CA2FC
	LDA.b #$60
	STA.b !RAM_SMW_Player_YPosLo
	LDA.b #$01
	STA.b !RAM_SMW_Player_YPosHi
	STZ.w !RAM_SMW_Yoshi_StrayYoshiFlag
	LDA.b #$26			; \ Mario's image = Peace Sign
	STA.w !RAM_SMW_Player_CurrentPose
	JSR.w SMW_HandlePlayerPoseAndAnimationTimersDuringEnding_CODE_0CA764
	JSR.w SMW_SpawnEndingYoshiSpriteAndDrawPlayer_CODE_0CA7B4
	LDY.w !RAM_SMW_Sprites_CheeringYoshiAnimationFrame
	LDA.w SMW_ProcessCheeringYoshis_DATA_0CA311,y
	ASL
	TAY
	LDA.b !RAM_SMW_NorSpr035_Yoshi_EndingXPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_EndingYoshisYPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$B4
	LDA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	JSR.w SMW_DrawCameraFacingEndingYoshis_GreenYoshi
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_EndingPlayerXPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$9F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$08
	LSR
	LSR
	LSR
	CLC
	ADC.b #$05
	ASL
	ASL
	TAY
	LDX.b #$A4
	JSR.w SMW_DrawCreditsPeachRedAndYellowYoshi_Peach
	DEC.w !RAM_SMW_Timer_WaitBeforeFadingOutYoshisHouseScene
	LDA.w !RAM_SMW_Timer_WaitBeforeFadingOutYoshisHouseScene
	BNE.b Return0CA720
	INC.w !RAM_SMW_Misc_GameMode
	LDA.b #$40
	STA.w !RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenLo
Return0CA720:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_InitializeEnemyRollcallLayerPositions(Address)
namespace SMW_InitializeEnemyRollcallLayerPositions
%InsertMacroAtXPosition(<Address>)

DATA_0CADB5:
	db $28,$28,$44,$28,$38,$20,$28,$20
	db $08,$28,$7C,$68,$28

InitialLayer2YPos:
	dw $0000,$0088,$00E0,$00C0
	dw $00E8,$0000,$00A0,$0050
	dw $00B0,$00E0,$0018,$00E0
	dw $0000

if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
SpecialWorldEnemyNamePtrs:
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused1	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Pumpkin	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Pidget	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused2	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_MaskKoopa	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused3	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused4	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused5	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused6	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused7	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused8	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused9	;!
	dw SMW_CreditsEnemyNames_SpecialWorld_Unused10	;!
endif

Main:
	PHB
	PHK
	PLB
	LDA.w !RAM_SMW_Counter_EnemyRollcallScreen
	TAY
	ASL
	TAX
	CLC
	ADC.w !RAM_SMW_Counter_EnemyRollcallScreen
	CLC
	ADC.b #!Define_SMW_StripeImage_CreditsEnemyNames
	STA.b !RAM_SMW_Graphics_StripeImageToUpload
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
	PHY				;!
	PHX				;!
	JSL.l SMW_LoadStripeImage_Main	;!
	LDA.w !RAM_SMW_Overworld_LevelTileSettings+!Define_SMW_LevelID_ChangeSP2GFX	;!
	BPL.b CODE_0CAE48		;!
	LDA.w !RAM_SMW_Counter_EnemyRollcallScreen	;!
	ASL				;!
	TAY				;!
	LDA.w SpecialWorldEnemyNamePtrs,y	;!
	STA.w !RAM_SMW_Misc_ScratchRAM00	;!
	LDA.w SpecialWorldEnemyNamePtrs+$01,y	;!
	STA.w !RAM_SMW_Misc_ScratchRAM01	;!
	LDA.b #SMW_CreditsEnemyNames_Main>>16	;!
	STA.w !RAM_SMW_Misc_ScratchRAM02	;!
	LDY.b #$00			;!
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo	;!
	TAX				;!
CODE_0CAE30:
	REP.b #$20			;! A->16
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	;!
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x	;!
	INY				;!
	INY				;!
	INX				;!
	INX				;!
	CMP.w #$FFFF			;!
	BNE.b CODE_0CAE30		;!
	TXA				;!
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo	;!
	SEP.b #$20			;! A->8
CODE_0CAE48:
	PLX				;!
	PLY				;!
endif
	LDA.w DATA_0CADB5,y
	STA.w SMW_ParallaxScrollHDMA[$00].Scanline2
	STA.w SMW_ParallaxScrollHDMA[$01].Scanline2
	STA.w SMW_ParallaxScrollHDMA[$02].Scanline2
	LDA.b #$88
	SEC
	SBC.w DATA_0CADB5,y
	STA.w SMW_ParallaxScrollHDMA[$00].Scanline3
	STA.w SMW_ParallaxScrollHDMA[$01].Scanline3
	STA.w SMW_ParallaxScrollHDMA[$02].Scanline3
	REP.b #$20			; A->16
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l InitialLayer2YPos,x
else
	LDA.w InitialLayer2YPos,x
endif
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	LDA.w !RAM_SMW_Counter_EnemyRollcallScreen
	AND.w #$00FF
	CMP.w #$000C
	BNE.b CODE_0CAE88
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STZ.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	STZ.b !RAM_SMW_Mirror_Layer3XPosLo
	STZ.w !RAM_SMW_Misc_Layer1XPosLo
	STZ.w !RAM_SMW_Misc_Layer2XPosLo
	STZ.w !RAM_SMW_Misc_Layer3XDispLo
	BRA.b CODE_0CAEA3

CODE_0CAE88:
	LDA.w #$FF00
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	LDA.w #$0100
	STA.w !RAM_SMW_Misc_Layer1XPosLo
	STA.w !RAM_SMW_Misc_Layer3XDispLo
	LDA.w #$FF80
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	LDA.w #$0080
	STA.w !RAM_SMW_Misc_Layer2XPosLo
CODE_0CAEA3:
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.w #$00A0
else
	LDA.w #$00FF
endif
	STA.w !RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenLo
	SEP.b #$20			; A->8
	PLB
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_GetLayer1And2PointersForEnemyRollcall(Address)
namespace SMW_GetLayer1And2PointersForEnemyRollcall
%InsertMacroAtXPosition(<Address>)

Screen01:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen01_Forest, SMW_U, LAYER_1)
Screen02:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen02_Sky, SMW_U, LAYER_1)
Screen03:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen03_Plains1, SMW_U, LAYER_1)
Screen04:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen04_Mountain, SMW_U, LAYER_1)
Screen05:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen05_Plains2, SMW_U, LAYER_1)
Screen06:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen06_Cave, SMW_U, LAYER_1)
Screen07:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen07_Underwater, SMW_U, LAYER_1)
Screen08:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen08_GhostHouse, SMW_U, LAYER_1)
Screen09:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen09_Castle1, SMW_U, LAYER_1)
Screen10:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen10_Castle2, SMW_U, LAYER_1)
Screen11:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen11_Reznor, SMW_U, LAYER_1)
Screen12:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen12_MechaKoopas, SMW_U, LAYER_1)
Screen13:
	%SMW_InsertOriginalLevelData(EnemyRollcallScreen13_BowserAndKoopalings, SMW_U, LAYER_1)

; Ending sequence level data (Pointer table)
Layer1Ptrs:
	dw Screen01,Screen02,Screen03,Screen04
	dw Screen05,Screen06,Screen07,Screen08
	dw Screen09,Screen10,Screen11,Screen12
	dw Screen13

Layer2Ptrs:
	dw SMW_Backgrounds_Layer2_Forest,SMW_Backgrounds_Layer2_Clouds,SMW_Backgrounds_Layer2_Rocks2,SMW_Backgrounds_Layer2_Mountains
	dw SMW_Backgrounds_Layer2_SmallHills,SMW_Backgrounds_Layer2_Cave,SMW_Backgrounds_Layer2_Water,SMW_Backgrounds_Layer2_GhostHouse
	dw SMW_Backgrounds_Layer2_Castle,SMW_Backgrounds_Layer2_Castle2,SMW_Backgrounds_Layer2_Castle,SMW_Backgrounds_Layer2_Castle2
	dw Screen13

Main:
;$0CAD8C
	PHB
	PHK
	PLB
	INC.w !RAM_SMW_Counter_EnemyRollcallScreen
	LDX.b #$FF
	LDA.w !RAM_SMW_Counter_EnemyRollcallScreen
	CMP.b #$0C
	BNE.b NotBowserScreen
	LDX.b #SMW_Backgrounds_Layer2>>16
NotBowserScreen:
	ASL
	TAY
	LDA.b #Layer1Ptrs>>16
	STA.b !RAM_SMW_Pointer_Layer1DataBank
	STX.b !RAM_SMW_Pointer_Layer2DataBank
	REP.b #$20			; A->16
	LDA.w Layer1Ptrs,y
	STA.b !RAM_SMW_Pointer_Layer1DataLo
	LDA.w Layer2Ptrs,y
	STA.b !RAM_SMW_Pointer_Layer2DataLo
	SEP.b #$20			; A->8
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_GameMode25_ShowEnemyRollcallScreen(Address)
namespace SMW_GameMode25_ShowEnemyRollcallScreen
%InsertMacroAtXPosition(<Address>)

Bank0C:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_GameMode25_ShowEnemyRollcallScreen(Address)
namespace SMW_GameMode25_ShowEnemyRollcallScreen
%InsertMacroAtXPosition(<Address>)

Sub:
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Counter_EnemyRollcallScreen
	CMP.b #$0C
	BNE.b CODE_0CAEBC
	DEC.w !RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenLo
	JMP.w CODE_0CAEF8

CODE_0CAEBC:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.w !RAM_SMW_Misc_Layer1XPosLo
	BNE.b CODE_0CAED0
	LDA.w !RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenLo
	BEQ.b CODE_0CAED0
	DEC.w !RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenLo
	JMP.w CODE_0CAF0C

CODE_0CAED0:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w #$0002
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	LDA.w !RAM_SMW_Misc_Layer1XPosLo
	SEC
	SBC.w #$0002
	STA.w !RAM_SMW_Misc_Layer1XPosLo
	STA.w !RAM_SMW_Misc_Layer3XDispLo
	INC.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	DEC.w !RAM_SMW_Misc_Layer2XPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	AND.w !RAM_SMW_Misc_Layer1XPosLo
	AND.w #$00FF
	SEP.b #$20			; A->8
	BNE.b CODE_0CAF0C
CODE_0CAEF8:
	LDA.w !RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenLo
	BNE.b CODE_0CAF0C
	INC.w !RAM_SMW_Misc_GameMode
	LDA.w !RAM_SMW_Counter_EnemyRollcallScreen
	CMP.b #$0C
	BEQ.b CODE_0CAF0C
	LDA.b #!Define_SMW_GameMode22_FadeOutToEnemyRollcall
	STA.w !RAM_SMW_Misc_GameMode
CODE_0CAF0C:
	SEP.b #$20			; A->8
	JMP.w DrawEnemyRollcallSprites

TileData:				;\ Note: The following sprite tile data is mostly in the same format as what gets stored to the OAM buffer.
					;/ However the YXPPCCCT byte works a bit differently. The right P controls the tile size and the left P affects which Layer 1 X Position RAM to use for the X Disp.
; Sprite data for the enemy credits roll. This contains the OAM data in the
; same format i.e. X position, Y position, tile number and tile properties
; aside from the priority bits. In the latter, bit 4 instead sets the tile
; size (bit clear = 8x8 tile, bit set = 16x16 tile) and bit 5 the scrolling
; of the screen (i.e. is the tile rooted to the top half or the bottom
; half). The data of a scene ends when the X position is set to be $FF. The
; scenes are indexed at the table $0CB5A2.
.EndEnemySprites5:
	db $29,$3C,$C2,$5F		;\ Top half of Dino Rhino
	db $39,$3C,$C0,$5F		;/
	db $5B,$34,$88,$59		;\ Top half of Dino Torch flame
	db $5B,$40,$8A,$55		;/
	db $29,$4C,$E2,$5F		;\ Bottom half of Dino Rhino
	db $39,$4C,$E0,$5F		;/
	db $5B,$4C,$8C,$55		;\ Bottom half of Dino Torch flame
	db $5B,$58,$8E,$55		;/
	db $5C,$60,$C6,$1F		; Dino Torch
	db $60,$A0,$82,$34		;\ Yellow Koopa
	db $60,$B0,$A2,$34		;/
	db $A0,$B0,$A4,$38		; Red Koopa body
	db $80,$A0,$82,$36		; Blue Koopa head
	db $C0,$A0,$82,$78		; Green Koopa head (Note: Uses the wrong palette, but you can't see that since the head only uses the colors shared by palettes A-D)
	db $80,$B0,$A0,$36		; Blue Koopa body
	db $C0,$B0,$A2,$7A		; Green Koopa body
	db $A0,$A0,$84,$38		; Red Koopa body
	db $FF

.EndEnemySprites6:
	db $92,$A3,$A2,$35		;\ Top half of Blargg
	db $A2,$A3,$A4,$35		;/
	db $80,$A9,$D7,$25		;\ Lava Splash
	db $86,$AC,$D6,$25		;|
	db $B5,$AF,$C7,$25		;|
	db $BD,$B2,$C6,$25		;/
	db $92,$B3,$E6,$35		;\ Bottom half of Blragg
	db $A2,$B3,$C8,$35		;|
	db $B2,$B3,$A6,$35		;/
	db $63,$B4,$E0,$33		;\ Skull raft
	db $73,$B4,$E0,$33		;|
	db $83,$B4,$E0,$33		;|
	db $93,$B4,$E0,$33		;/
	db $17,$2F,$8C,$19		; Spike Top
	db $37,$37,$8E,$19		; Diagonal Spike Top
	db $3F,$47,$AA,$19		; Sideways Spike Top
	db $1F,$5F,$EC,$99		; Upside down Spike Top
	db $38,$8F,$80,$3D		; Left Buzzy Beetle
	db $50,$8F,$82,$7D		; Right Buzzy Beetle	
	db $90,$3C,$AE,$1B		; Left ceiling Swooper Bat
	db $A6,$45,$AE,$1B		; Right ceiling Swooper Bat
	db $78,$54,$C0,$1B		; Swooping Swooper Bat
	db $FF

.EndEnemySprites9:			; Note: The undead enemies use palette E (setting 01) when they normally use palette 9.
	db $43,$1E,$82,$5D		; Dry Bones Bone
	db $30,$22,$64,$5D		; Dry Bones head
	db $72,$23,$0A,$15		; Sparky
	db $27,$30,$66,$5D		; Dry Bones body
	db $AD,$40,$AA,$1D		; Bony Beetle
	db $84,$6A,$8E,$33		;\ Thwomp
	db $8C,$6A,$8E,$73		;|
	db $84,$7A,$AE,$33		;|
	db $8C,$7A,$AE,$73		;/
	db $BC,$92,$A2,$23		;\ Thwimp
	db $C4,$92,$A2,$63		;|
	db $BC,$9A,$B2,$23		;|
	db $C4,$9A,$B2,$63		;/
	db $48,$93,$0C,$35		;\ Hothead
	db $58,$93,$0E,$35		;|
	db $50,$9A,$09,$25		;|
	db $48,$A3,$0E,$F5		;|
	db $58,$A3,$0C,$F5		;/
	db $FF

.EndEnemySprites12:
	db $6B,$67,$41,$5B		;\ Top half of middle Mechakoopa
	db $73,$67,$40,$5B		;/
	db $A6,$67,$40,$1B		;\ Top half of right Mechakoopa
	db $AE,$67,$41,$1B		;/
	db $57,$6E,$72,$0B		; Stunned Mechakoopa key
	db $66,$6E,$71,$4B		; Middle Mechakoopa key
	db $BB,$6E,$70,$0B		; Right Mechakoopa key
	db $42,$6F,$00,$1B		;\ Stunned Mechakoopa
	db $4A,$6F,$01,$1B		;/
	db $6B,$6F,$51,$5B		; Middle Mechakoopa legs
	db $AE,$6F,$0A,$1B		; Right Mechakoopa legs
	db $7B,$77,$60,$4B		; Middle Mechakoopa jaw
	db $A6,$77,$60,$0B		; Right Mechakoopa jaw
	db $FF

.EndEnemySprites2:
	db $20,$37,$6D,$57		; Hammer
	db $38,$37,$5A,$07		;\ Hammer Bro
	db $40,$37,$4A,$07		;|
	db $30,$3F,$46,$17		;|
	db $40,$3F,$48,$17		;/
	db $20,$47,$C6,$56		;\ Hammer Bro Platform
	db $50,$47,$C6,$16		;|
	db $30,$4F,$2E,$12		;| Note: Tile 2E is the brown used block, not the turn block that this sprite normally uses
	db $40,$4F,$2E,$12		;/
	db $90,$9C,$B6,$29		;\ Volcano Lotus Fire
	db $99,$9C,$B6,$29		;|
	db $86,$A0,$B6,$29		;|
	db $A3,$A0,$B6,$29		;/
	db $CB,$A4,$06,$77		;\ Chargin' Chuck head and shoulder (Note: Chargin Chucks use palette D, not B with the exception of tile 1C for some reason)
	db $C0,$A7,$1D,$67		;|
	db $C8,$A7,$1C,$67		;/
	db $88,$AF,$CE,$3B		;\ Volcano Lotus
	db $90,$AF,$E2,$29		;|
	db $98,$AF,$E3,$29		;|
	db $98,$AF,$CE,$7B		;/
	db $C0,$AF,$21,$77		;\ Chargin' Chuck body
	db $C8,$AF,$20,$77		;/
	db $38,$8F,$AE,$38		;\ Jumpin' Piranha Plant
	db $38,$9F,$C5,$2A		;|
	db $40,$9F,$C5,$6A		;/
	db $8C,$1F,$E0,$1B		;\ Top left Super Koopa
	db $94,$22,$E4,$09		;|
	db $9C,$22,$E5,$09		;|
	db $9C,$27,$F2,$0B		;/
	db $B4,$27,$E0,$1B		;\ Top right Super Koopa
	db $BC,$2A,$F4,$05		;|
	db $C4,$2A,$F5,$05		;|
	db $C4,$2F,$F2,$09		;/
	db $94,$3F,$E0,$1B		;\ Bottom left Super Koopa
	db $9C,$42,$E4,$09		;|
	db $A4,$42,$E5,$09		;|
	db $A4,$47,$F2,$0B		;/
	db $B4,$4F,$E2,$18		;\ Grounded Super Koopa (Note: The koopa uses palette C when it normally uses B)
	db $BC,$4F,$C9,$05		;|
	db $BC,$57,$D9,$05		;|
	db $C4,$57,$C0,$05		;/
	db $FF

.EndEnemySprites3:
	db $2C,$27,$EE,$15		;\ Sumo Bro
	db $28,$2F,$C5,$15		;|
	db $30,$2F,$C6,$15		;/
	db $20,$3F,$2E,$10		;\ Used blocks (Note: Unnecessary because there are turn blocks underneath)
	db $30,$3F,$2E,$10		;|
	db $40,$3F,$2E,$10		;/
	db $30,$4F,$CC,$15		;\ Sumo Bro Flames
	db $20,$5F,$CC,$15		;|
	db $30,$5F,$EC,$15		;|
	db $40,$5F,$CC,$15		;/
	db $89,$3F,$8A,$15		; Pokey head
	db $BA,$43,$86,$11		; Monty Mole popping out of ground
	db $CB,$47,$3D,$00		;\ Upper Brick Pieces
	db $AE,$48,$3D,$00		;/
	db $8A,$4F,$E8,$15		;\ Upper Pokey body
	db $8A,$4F,$E8,$15		;/
	db $D6,$4F,$84,$51		; Walking Monty Mole
	db $B7,$54,$3D,$00		;\ Lower Brick Pieces
	db $C8,$55,$3D,$00		;/
	db $89,$5F,$E8,$15		;\ Lower Pokey body (Note: What is with all the duplicate Pokey body tiles?)
	db $89,$5F,$E8,$15		;|
	db $8A,$6F,$E8,$15		;/
	db $74,$AF,$62,$30		; Smoke puff
	db $84,$AF,$A6,$72		; Bullet Bill
	db $FF

.EndEnemySprites4:
	db $80,$8F,$80,$33		;\ Banzai Bill
	db $90,$8F,$82,$33		;|
	db $A0,$8F,$84,$33		;|
	db $B0,$8F,$86,$33		;|
	db $80,$9F,$A0,$33		;|
	db $90,$9F,$88,$33		;|
	db $A0,$9F,$CE,$33		;|
	db $B0,$9F,$EE,$33		;|
	db $80,$AF,$C0,$33		;|
	db $90,$AF,$C2,$33		;|
	db $A0,$AF,$CE,$33		;|
	db $B0,$AF,$EE,$33		;|
	db $80,$BF,$8E,$33		;|
	db $90,$BF,$AE,$33		;|
	db $A0,$BF,$84,$B3		;|
	db $B0,$BF,$86,$B3		;/
	db $6C,$2F,$8A,$57		;\ Rex
	db $67,$3F,$AA,$57		;/
	db $A4,$4F,$66,$00		;\ Trailing Smoke
	db $A0,$53,$64,$00		;/
	db $8C,$57,$A8,$17		; Smushed Rex
	db $9C,$57,$62,$00		; Trailing Smoke
	db $30,$8F,$CC,$71		;\ Mega Mole
	db $40,$8F,$CA,$71		;|
	db $30,$9F,$EC,$71		;|
	db $40,$9F,$EA,$71		;/
	db $FF

.EndEnemySprites7:
	db $30,$27,$EC,$1B		; Top Blurp Fish
	db $28,$37,$EC,$1B		; Middle Blurp Fish
	db $50,$40,$C0,$5D		;\ Top half of Porcu-Puffer
	db $60,$40,$86,$5D		;/
	db $30,$47,$EC,$1B		; Bottom Blurp Fish
	db $50,$50,$C2,$5D		;\ Bottom Half of Porcu-Puffer
	db $60,$50,$A6,$5D		;/
	db $98,$2F,$C8,$17		;\ Urchin
	db $A8,$2F,$C8,$57		;|
	db $A0,$37,$CA,$17		;|
	db $98,$3F,$C8,$97		;|
	db $A8,$3F,$C8,$D7		;/
	db $44,$8F,$AC,$37		; Top right Rip Van Fish
	db $22,$94,$F1,$2B		;\ Top 3 Zs
	db $20,$9C,$F0,$2B		;|
	db $25,$A4,$E1,$2B		;/
	db $4C,$A7,$AE,$77		; Bottom right Rip Van Fish
	db $24,$AB,$E0,$2B		; Lowest Z
	db $24,$AF,$8C,$37		; Sleeping Rip Van Fish
	db $B2,$A7,$A0,$77		;\ Top Torpedo Ted (Note: Both Torpedo teds use palette B when they normally uses palette 9).
	db $C2,$A7,$80,$77		;/
	db $BA,$9E,$84,$77		; Right Launcher Arm
	db $88,$AF,$A4,$77		; Left Launcher Arm
	db $88,$BF,$66,$76		; Left Smoke Puff
	db $90,$BF,$64,$76		; Middle Smoke Puff
	db $98,$BF,$62,$76		; Right Smoke Puff
	db $A8,$BF,$82,$77		;\ Bottom Torpedo Ted
	db $B8,$BF,$80,$77		;/
	db $FF

.EndEnemySprites1:
	db $28,$26,$E6,$57		;\ Parachute Bob-omb
	db $20,$36,$C2,$51		;/
	db $48,$36,$E6,$17		;\ Parachute Goomba (Note: The goomba uses palette D when it normally uses A)
	db $51,$45,$E8,$1B		;/
	db $A8,$4A,$60,$14		;\ Lakitu
	db $B0,$4A,$60,$14		;|
	db $AC,$3E,$A8,$1B		;|
	db $AA,$4E,$60,$14		;|
	db $AE,$4E,$60,$14		;|
	db $AF,$51,$4D,$09		;/
	db $9F,$33,$84,$07		;\ Spiny Egg (Note: Uses palette B when it normally uses A)
	db $A7,$33,$84,$47		;|
	db $9F,$3B,$84,$87		;|
	db $A7,$3B,$84,$C7		;/
	db $B7,$2B,$60,$54		;\ Fishin' Lakitu
	db $BF,$2B,$60,$54		;|
	db $BB,$1F,$EC,$5B		;|
	db $C9,$21,$AA,$55		;|
	db $B9,$2F,$60,$54		;|
	db $BD,$2F,$60,$54		;|
	db $C0,$32,$4D,$49		;|
	db $D9,$21,$89,$49		;|
	db $D9,$29,$89,$49		;|
	db $D9,$31,$89,$49		;|
	db $D9,$39,$89,$49		;|
	db $D9,$41,$89,$49		;|
	db $D9,$49,$89,$49		;|
	db $D9,$51,$89,$49		;|
	db $D9,$59,$89,$49		;|
	db $D1,$61,$24,$5A		;/
	db $48,$8F,$82,$79		; Spiny
	db $7F,$AE,$CC,$35		; Bob-omb
	db $B8,$AF,$C6,$35		;\ Wiggler
	db $B0,$AF,$C4,$35		;|
	db $A8,$AE,$C8,$35		;|
	db $A0,$AF,$C6,$35		;|
	db $98,$AF,$8C,$35		;|
	db $9E,$A7,$98,$2B		;/
	db $FF

.EndEnemySprites8:
	db $41,$56,$8C,$1F		; Bottom Boo Buddy
	db $46,$46,$AE,$1F		; Middle Left Boo Buddy
	db $50,$36,$88,$1F		; Middle Right Boo Buddy
	db $5C,$29,$A8,$1F		; Top Boo Buddy
	db $AB,$50,$60,$54		;\ Fishin' Boo
	db $B5,$50,$60,$54		;|
	db $B0,$45,$64,$5D		;|
	db $BE,$48,$8A,$59		;|
	db $AD,$54,$60,$54		;|
	db $B3,$54,$60,$54		;|
	db $C6,$58,$AC,$5D		;|
	db $C6,$68,$AC,$5D		;|
	db $C6,$7C,$AC,$7D		;|
	db $C6,$8A,$CE,$77		;/
	db $B2,$90,$6A,$3D		; Right Eerie
	db $A0,$8A,$ED,$3D		; Middle Eerie
	db $8E,$8F,$6A,$3D		; Left Eerie
	db $22,$95,$86,$7D		;\ Big Boo
	db $32,$95,$84,$7D		;|
	db $42,$95,$82,$7D		;|
	db $52,$95,$80,$7D		;|
	db $22,$A5,$A6,$7D		;|
	db $32,$A5,$A4,$7D		;|
	db $42,$A5,$A2,$7D		;|
	db $59,$A5,$E8,$7D		;|
	db $52,$A5,$A0,$7D		;|
	db $22,$B5,$C6,$7D		;|
	db $32,$B5,$C4,$7D		;|
	db $42,$B5,$A2,$7D		;|
	db $52,$B5,$A0,$FD		;|
	db $22,$C5,$E6,$7D		;|
	db $32,$C5,$E4,$7D		;|
	db $42,$C5,$82,$FD		;|
	db $52,$C5,$80,$FD		;|
	db $30,$A6,$E8,$3D		;|
	db $4B,$A3,$C0,$7D		;|
	db $4B,$B3,$E0,$7D		;/
	db $FF

.EndEnemySprites10:
	db $5C,$47,$EA,$13		;\ Ball N' Chain
	db $6C,$47,$EA,$53		;|
	db $5C,$57,$EA,$93		;|
	db $6C,$57,$EA,$D3		;|
	db $54,$3F,$E8,$13		;|
	db $49,$34,$E8,$13		;|
	db $3E,$29,$E8,$13		;/
	db $7B,$2E,$6C,$13		;\ Grinder
	db $8B,$2E,$6C,$53		;|
	db $7B,$3E,$6C,$93		;|
	db $8B,$3E,$6C,$D3		;/
	db $70,$A7,$A8,$3D		;\ Top Fishbone
	db $80,$A7,$A3,$2D		;|
	db $80,$AF,$A3,$AD		;/
	db $A8,$AC,$A6,$3D		;\ Right Fishbone
	db $B8,$AC,$A3,$2D		;|
	db $B8,$B4,$A3,$AD		;/
	db $50,$AF,$A6,$3D		;\ Left Fishbone
	db $60,$AF,$A3,$2D		;|
	db $60,$B7,$A3,$AD		;/
	db $86,$AF,$A6,$3D		;\ Middle Right Fishbone
	db $96,$AF,$B3,$2D		;|
	db $96,$B7,$B3,$AD		;/
	db $78,$BF,$A6,$3D		;\ Bottom Fishbone
	db $88,$BF,$B3,$2D		;|
	db $88,$C7,$B3,$AD		;/
	db $FF

.EndEnemySprites11:			; Note: The Reznor platforms use palette 8 when they normally use palette 9
	db $70,$1E,$44,$1F		;\ Top half of top Reznor
	db $80,$1E,$46,$1F		;/
	db $60,$2E,$26,$D5		; Top Reznor Fireball
	db $70,$2E,$64,$1F		;\ Bottom half of top Reznor
	db $80,$2E,$66,$1F		;/
	db $70,$3E,$4E,$11		;\ Top Reznor platform
	db $80,$3E,$4E,$51		;/
	db $48,$3F,$40,$1F		;\ Top half of left Reznor
	db $58,$3F,$42,$1F		;/
	db $98,$3F,$42,$5F		;\ Top half of right Reznor
	db $A8,$3F,$40,$5F		;/
	db $48,$4F,$60,$1F		;\ Bottom half of left Reznor
	db $58,$4F,$62,$1F		;/
	db $98,$4F,$62,$5F		;\ Bottom half of right Reznor
	db $A8,$4F,$60,$5F		;/
	db $48,$5F,$4E,$11		;\ Left Reznor platform
	db $58,$5F,$4E,$51		;/
	db $98,$5F,$4E,$11		;\ Right Reznor platform
	db $A8,$5F,$4E,$51		;/
	db $70,$66,$46,$5F		;\ Bottom Reznor
	db $80,$66,$44,$5F		;|
	db $70,$76,$66,$5F		;|
	db $80,$76,$64,$5F		;/
	db $70,$86,$4E,$11		;\ Bottom Reznor platform
	db $80,$86,$4E,$51		;/
	db $A0,$8E,$26,$15		; Bottom Reznor Fireball
	db $FF

.EndEnemySprites13:
	db $6C,$1A,$48,$10		;\ Bowser
	db $7C,$1A,$4A,$10		;|
	db $8C,$22,$1C,$00		;|
	db $6C,$2A,$68,$10		;|
	db $7C,$2A,$6A,$10		;|
	db $8C,$2A,$2C,$10		;|
	db $64,$3A,$08,$00		;|
	db $6C,$3A,$09,$00		;|
	db $74,$3A,$0A,$00		;|
	db $7C,$3A,$0B,$00		;|
	db $84,$3A,$0C,$00		;|
	db $8C,$3A,$0D,$00		;|
	db $94,$3A,$0E,$00		;|
	db $9C,$3A,$0F,$00		;|
	db $64,$42,$40,$10		;|
	db $74,$42,$41,$40		;|
	db $7C,$42,$45,$00		;|
	db $84,$42,$41,$00		;|
	db $8C,$42,$41,$40		;|
	db $94,$42,$46,$10		;|
	db $74,$4A,$51,$40		;|
	db $7C,$4A,$62,$00		;|
	db $84,$4A,$51,$00		;|
	db $8C,$4A,$51,$40		;|
	db $64,$52,$60,$10		;|
	db $74,$52,$62,$00		;|
	db $7C,$52,$62,$00		;|
	db $84,$52,$62,$00		;|
	db $8C,$52,$65,$00		;|
	db $94,$52,$66,$10		;|
	db $74,$5A,$72,$00		;|
	db $7C,$5A,$73,$00		;|
	db $84,$5A,$74,$00		;|
	db $8C,$5A,$75,$00		;|
	db $64,$62,$20,$00		;|
	db $6C,$62,$21,$00		;|
	db $74,$62,$22,$10		;|
	db $84,$62,$24,$10		;|
	db $94,$62,$26,$00		;|
	db $9C,$62,$27,$00		;|
	db $6C,$6A,$31,$00		;|
	db $94,$6A,$36,$00		;|
	db $6C,$72,$37,$00		;|
	db $74,$72,$38,$00		;|
	db $7C,$72,$39,$00		;|
	db $84,$72,$3A,$00		;|
	db $8C,$72,$3B,$00		;|
	db $94,$72,$2B,$00		;/
	db $31,$2C,$83,$4C		;\ Morton (Note: Uses the blue colors from palette E (sprite palette setting 04) when he normally uses palette D's colors
	db $39,$2C,$DA,$4C		;|
	db $41,$2C,$D9,$4C		;|
	db $31,$34,$86,$4C		;|
	db $39,$34,$EA,$4C		;|
	db $41,$34,$E9,$4C		;|
	db $31,$3C,$8D,$4C		;|
	db $39,$3C,$8C,$4C		;|
	db $41,$3C,$87,$4C		;/
	db $B2,$2C,$B2,$0E		;\ Roy (Note: Uses the grey colors from palette F (sprite palette setting 04) when he normally uses palette B's colors)
	db $BA,$2C,$B3,$0E		;|
	db $C2,$2C,$91,$0E		;|
	db $B2,$34,$92,$0E		;|
	db $BA,$34,$93,$0E		;|
	db $C2,$34,$94,$0E		;|
	db $BA,$3C,$95,$0E		;|
	db $C2,$3C,$96,$0E		;/
	db $1A,$6C,$A8,$15		;\ Lemmy
	db $12,$7C,$EC,$1B		;|
	db $22,$7C,$EE,$1B		;|
	db $15,$5C,$92,$05		;|
	db $1D,$5C,$92,$45		;|
	db $15,$64,$84,$15		;/
	db $CD,$6C,$A0,$19		;\ Wendy
	db $DD,$6C,$A0,$59		;|
	db $CD,$7C,$EC,$1B		;|
	db $DD,$7C,$EE,$1B		;|
	db $D5,$5F,$9F,$49		;|
	db $DD,$5F,$9E,$49		;|
	db $D5,$67,$CC,$59		;/
	db $34,$AA,$24,$57		;\ Iggy
	db $3C,$9A,$1B,$47		;|
	db $3C,$A2,$08,$57		;/
	db $70,$A9,$CC,$02		;\ Ludwig (Note: Uses the purple colors from palette F (sprite palette setting 01/07) when he normally uses palette A's colors 
	db $78,$A9,$CD,$02		;|
	db $80,$A9,$CD,$42		;|
	db $88,$A9,$CC,$42		;|
	db $70,$B1,$99,$02		;|
	db $78,$B1,$9A,$02		;|
	db $80,$B1,$9A,$42		;|
	db $88,$B1,$99,$42		;|
	db $70,$B9,$9B,$02		;|
	db $78,$B9,$9C,$02		;|
	db $80,$B9,$9C,$42		;|
	db $88,$B9,$9B,$42		;|
	db $70,$C1,$9D,$02		;|
	db $78,$C1,$9E,$02		;|
	db $80,$C1,$9E,$42		;|
	db $88,$C1,$9D,$42		;/
	db $BD,$9E,$0C,$0B		;\ Larry
	db $B4,$A6,$00,$1B		;|
	db $BD,$AB,$02,$1B		;|
	db $B5,$B4,$0A,$0B		;/
	db $FF

; The credits scene indices, indexed by $1DE9. The table contains all the
; indices to the sprite tilemap $0CAF11 for the enemy credits roll.
EnemyRollcallSpriteDataPtrs:
	dw TileData_EndEnemySprites1-TileData,TileData_EndEnemySprites2-TileData,TileData_EndEnemySprites3-TileData,TileData_EndEnemySprites4-TileData
	dw TileData_EndEnemySprites5-TileData,TileData_EndEnemySprites6-TileData,TileData_EndEnemySprites7-TileData,TileData_EndEnemySprites8-TileData
	dw TileData_EndEnemySprites9-TileData,TileData_EndEnemySprites10-TileData,TileData_EndEnemySprites11-TileData,TileData_EndEnemySprites12-TileData
	dw TileData_EndEnemySprites13-TileData

; Draws the sprites for the enemy credits roll using the table at $0CAF11,
; indexed by $0CB5A2.
DrawEnemyRollcallSprites:
	LDA.b #$00
	XBA
	LDY.b #$20
	LDA.w !RAM_SMW_Counter_EnemyRollcallScreen
	CMP.b #$05
	BNE.b CODE_0CB5CA
	LDY.b #$30
CODE_0CB5CA:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	REP.b #$10			; XY->16
	TAY
	LDX.w EnemyRollcallSpriteDataPtrs,y
	LDY.w #$007F
	STY.b !RAM_SMW_Misc_ScratchRAM01
	LDY.w #$01FC
CODE_0CB5DB:
	PHY
	LDY.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.w TileData+$03,x
	AND.b #$20
	BEQ.b CODE_0CB5E8
	LDY.w !RAM_SMW_Misc_Layer1XPosLo
CODE_0CB5E8:
	STY.b !RAM_SMW_Misc_ScratchRAM03
	PLY
	LDA.w TileData,x
	CMP.b #$FF
	BEQ.b CODE_0CB633
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM03
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.b #$00
	SBC.b !RAM_SMW_Misc_ScratchRAM04
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w TileData+$03,x
	AND.b #$10
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	PHY
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	PLY
	LDA.w TileData+$01,x
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w TileData+$02,x
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.w TileData+$03,x
	AND.b #$CF
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].Prop,y
	DEY
	DEY
	DEY
	DEY
	INX
	INX
	INX
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM01
	BRA.b CODE_0CB5DB

CODE_0CB633:
	SEP.b #$10			; XY->8
	RTS
namespace off
endmacro

macro ROUTINE_RT04_SMW_LoadOverworldLayer1AndEvents(Address)
namespace SMW_LoadOverworldLayer1AndEvents
%InsertMacroAtXPosition(<Address>)

; Layer 1 Map16 data of the overworld, uncompressed. The data is directly
; copied from there to $7EC800. Note that the original game only has low
; bytes for each of these tiles; the high bytes are all set to 00. Lunar
; Magic adds an additional table for the high bytes at
; (read1($04D827)<<16)|read2($04D822) , compressed with LC_LZ2.
Layer1Tilemap:
	incbin "overworld/layer1/levels.bin"
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawLeaningEndingYoshis(Address)
namespace SMW_DrawLeaningEndingYoshis
%InsertMacroAtXPosition(<Address>)

; Red Yoshi Watching Tiles (Ending)
DATA_0CA93A:
	db $BB,$B9,$DC,$DB,$DA,$D9
	db $8B,$89,$AC,$AB,$AA,$A9
	; Yellow Yoshi Watching Tiles (Ending)
	db $B9,$BB,$D9,$DA,$DB,$DC
	db $89,$8B,$A9,$AA,$AB,$AC

; Red Yoshi Watching Palettes (Ending)
DATA_0CA952:
	db $78,$78,$78,$78,$78,$78
	db $78,$78,$78,$78,$78,$78
	; Yellow Yoshi Watching Palettes (Ending)
	db $34,$34,$34,$34,$34,$34
	db $34,$34,$34,$34,$34,$34

; Red Yoshi Watching Tile X-coords (Ending)
DATA_0CA96A:
	db $00,$10,$00,$08,$10,$18
	db $00,$10,$00,$08,$10,$18
	; Yellow Yoshi Watching Tile X-coords (Ending)
	db $00,$10,$00,$08,$10,$18
	db $00,$10,$00,$08,$10,$18

; Red Yoshi Watching Tile Y-coords (Ending)
DATA_0CA982:
	db $00,$00,$10,$10,$10,$10
	db $00,$00,$10,$10,$10,$10
	; Yellow Yoshi Watching Tile Y-coords (Ending)
	db $00,$00,$10,$10,$10,$10
	db $00,$00,$10,$10,$10,$10

DATA_0CA99A:
	db $00,$06,$0C,$12

Main:
	TYA
	LSR
	LSR
	TAY
	LDA.w DATA_0CA99A,y
	TAY
	LDA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_0CA9AA:
	LDA.w DATA_0CA96A,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.w DATA_0CA96A+$01,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$01].XDisp,x
	LDA.w DATA_0CA982,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LDA.w DATA_0CA982+$01,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$01].YDisp,x
	LDA.w DATA_0CA93A,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.w DATA_0CA93A+$01,y
	STA.w SMW_OAMBuffer[$01].Tile,x
	LDA.w DATA_0CA952,y
	STA.w SMW_OAMBuffer[$00].Prop,x
	LDA.w DATA_0CA952+$01,y
	STA.w SMW_OAMBuffer[$01].Prop,x
	PHY
	PHX
	TXA
	LSR
	LSR
	TAX
	LDY.b #$02
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	AND.b #$02
	BNE.b CODE_0CA9F6
	LDY.b #$00
CODE_0CA9F6:
	TYA
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	STA.w SMW_OAMTileSizeBuffer[$01].Slot,x
	PLX
	PLY
	TXA
	CLC
	ADC.b #$08
	TAX
	INY
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_0CA9AA
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawCameraFacingEndingYoshis(Address)
namespace SMW_DrawCameraFacingEndingYoshis
%InsertMacroAtXPosition(<Address>)

; Blue/Green Yoshi Tiles (Ending)
Tiles:
	db $C4,$E4	; Stand
	db $E6,$E8	; Cheer
	db $CE,$EE	; Lean in

; Blue Yoshi Palettes (Ending)
Prop:
	db $36,$36
	; Green Yoshi Palettes (Ending)
	db $3A,$3A

BlueYoshi:
GreenYoshi:
	PHY
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ASL
	TAY
	LDA.w Prop,y
	STA.w SMW_OAMBuffer[$00].Prop,x
	LDA.w Prop+$01,y
	STA.w SMW_OAMBuffer[$01].Prop,x
	PLY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].XDisp,x
	STA.w SMW_OAMBuffer[$01].XDisp,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$00].YDisp,x
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$01].YDisp,x
	LDA.w Tiles,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.w Tiles+$01,y
	STA.w SMW_OAMBuffer[$01].Tile,x
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	STA.w SMW_OAMTileSizeBuffer[$01].Slot,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawCreditsPeachRedAndYellowYoshi(Address)
namespace SMW_DrawCreditsPeachRedAndYellowYoshi
%InsertMacroAtXPosition(<Address>)

DATA_0CA7B9:
	db $63,$64,$68,$69		;\ Peach Riding Yoshi
	db $63,$64,$68,$69		;|
	db $4B,$4C,$6B,$6C		;/
	db $8A,$8B,$AA,$68		;\ Peach Walking
	db $8D,$8E,$AD,$AE		;/
	db $8A,$00,$AA,$44		;\ Peach Waving
	db $8A,$0E,$AA,$2E		;/
	; Red Yoshi Cheering Tiles (Ending)
	db $81,$80,$A1,$A0		;\ Red Yoshi Cheering
	db $84,$83,$A4,$A3		;|
	db $87,$86,$A7,$A6		;/
	; Yellow Yoshi Cheering Tiles (Ending)
	db $80,$81,$A0,$A1		;\ Yellow Yoshi Cheering
	db $83,$84,$A3,$A4		;|
	db $86,$87,$A6,$A7		;/

DATA_0CA7ED:
	db $21,$21,$21,$21		;\ Peach Riding Yoshi
	db $21,$21,$21,$21		;|
	db $21,$21,$21,$21		;/
	db $21,$21,$21,$21		;\ Peach Walking
	db $20,$20,$20,$20		;/
	db $21,$21,$21,$21		;\ Peach Waving
	db $21,$21,$21,$21		;/
	; Red Yoshi Cheering Palettes (Ending)
	db $78,$78,$78,$78		;\ Red Yoshi Cheering
	db $78,$78,$78,$78		;|
	db $78,$78,$78,$78		;/
	; Yellow Yoshi Cheering Palettes (ending)
	db $34,$34,$34,$34		;\ Yellow Yoshi Cheering
	db $34,$34,$34,$34		;|
	db $34,$34,$34,$34		;/

Peach:
RedYoshi:
YellowYoshi:
	REP.b #$30			; AXY->16
	TXA
	AND.w #$00FF
	TAX
	TYA
	AND.w #$00FF
	CMP.w #$0028
	BCC.b CODE_0CA836
	TXA
	ORA.w #$0100
	TAX
CODE_0CA836:
	SEP.b #$20			; A->8
	LDA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_0CA83C:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b CODE_0CA8A0
	LDA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$01].XDisp,x
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$00].XDisp,x
	BCC.b CODE_0CA855
	LDA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM0A
CODE_0CA855:
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$00].YDisp,x
	STA.w SMW_OAMBuffer[$01].YDisp,x
	LDA.w DATA_0CA7B9,y
	STA.w SMW_OAMBuffer[$01].Tile,x
	LDA.w DATA_0CA7B9+$01,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.w DATA_0CA7ED,y
	STA.w SMW_OAMBuffer[$01].Prop,x
	LDA.w DATA_0CA7ED+$01,y
	STA.w SMW_OAMBuffer[$00].Prop,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX
	REP.b #$20			; A->16
	TXA
	LSR
	LSR
	TAX
	SEP.b #$20			; A->8
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$01].Slot,x
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	PLX
	REP.b #$20			; A->16
	TXA
	CLC
	ADC.w #$0008
	TAX
	SEP.b #$20			; A->8
	INY
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_0CA83C
CODE_0CA8A0:
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_HandleTNTFuse(Address)
namespace SMW_HandleTNTFuse
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Flag_TNTPlungerWasPressed
	BNE.b CODE_0CCB30
	LDA.b #$60
	STA.w !RAM_SMW_Sprites_TNTFuseAndLineXPos
	LDA.b #$01
	STA.w !RAM_SMW_Sprites_TNTFuseAnimationTimer
	STZ.w !RAM_SMW_Sprites_TNTFuseAnimationIndex
	BRA.b CODE_0CCB55

CODE_0CCB30:
	LDX.b #$00
	LDY.b #$30
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	DEC
	BNE.b CODE_0CCB3C
	LDY.b #$18
CODE_0CCB3C:
	TYA
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXSpeed,x
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_X
	DEC.w !RAM_SMW_Sprites_TNTFuseAnimationTimer
	BPL.b CODE_0CCB55
	LDA.b #$01
	STA.w !RAM_SMW_Sprites_TNTFuseAnimationTimer
	LDA.w !RAM_SMW_Sprites_TNTFuseAnimationIndex
	EOR.b #$01
	STA.w !RAM_SMW_Sprites_TNTFuseAnimationIndex
CODE_0CCB55:
	JSR.w SMW_DrawCastleDestructionCastleDoor_Main
	BRL.w TNTFuseAndLineGFXRt
namespace off
endmacro

macro ROUTINE_RT01_SMW_HandleTNTFuse(Address)
namespace SMW_HandleTNTFuse
%InsertMacroAtXPosition(<Address>)

TNTFuseAndLineGFXRt:
	LDX.b #$60
	LDA.w !RAM_SMW_Flag_TNTPlungerWasPressed
	BEQ.b CODE_0CCB8A
	LDX.w !RAM_SMW_Sprites_TNTFuseAndLineXPos
CODE_0CCB8A:
	STX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$67
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDX.b #$14
CODE_0CCB92:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$B0
	BCS.b CODE_0CCBB5
	STA.w SMW_OAMBuffer[$60].XDisp,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$60].YDisp,x
	LDA.b #$E4
	STA.w SMW_OAMBuffer[$60].Tile,x
	LDA.b #$3F
	STA.w SMW_OAMBuffer[$60].Prop,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$60].Slot,x
	PLX
CODE_0CCBB5:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INX
	INX
	INX
	INX
	CPX.b #$28
	BNE.b CODE_0CCB92
	LDA.w !RAM_SMW_Flag_TNTPlungerWasPressed
	BEQ.b Return0CCBF9
	LDA.w !RAM_SMW_Sprites_TNTFuseAndLineXPos
	SEC
	SBC.b #$08
	CMP.b #$B0
	BCC.b CODE_0CCBD8
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BRA.b Return0CCBF9

CODE_0CCBD8:
	STA.w SMW_OAMBuffer[$60].XDisp,x
	LDA.b #$6F
	STA.w SMW_OAMBuffer[$60].YDisp,x
	LDY.b #$85
	LDA.w !RAM_SMW_Sprites_TNTFuseAnimationIndex
	BEQ.b CODE_0CCBE9
	LDY.b #$95
CODE_0CCBE9:
	TYA
	STA.w SMW_OAMBuffer[$60].Tile,x
	LDA.b #$35
	STA.w SMW_OAMBuffer[$60].Prop,x
	TXA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$60].Slot,x
Return0CCBF9:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeTNTExplosion(Address)
namespace SMW_InitializeTNTExplosion
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #!Define_SMW_Sound1DFC_Explosion
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b #$FF
	STA.w !RAM_SMW_Sprites_TNTExplosionAnimationIndex
	LDA.b #$30
	STA.w !RAM_SMW_Sprites_TNTExplosionTimer
	LDA.b #$01
	STA.w !RAM_SMW_Sprites_TNTExplosionAnimationTimer
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSR.w SMW_DrawCastleDestructionCastleDoor_Main
	BRL.w SMW_HandleTNTExplosion_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleTNTExplosion(Address)
namespace SMW_HandleTNTExplosion
%InsertMacroAtXPosition(<Address>)

DATA_0CCC49:
	db $03,$01,$03,$01

DATA_0CCC4D:
	dw $7393,$7FFF

Main:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$02
	TAX
	REP.b #$20			; A->16
	LDA.w DATA_0CCC4D,x
	STA.w !RAM_SMW_Palettes_BackgroundColorLo
	SEP.b #$20			; A->8
	DEC.w !RAM_SMW_Sprites_TNTExplosionTimer
	BPL.b CODE_0CCC82
	JSR.w SMW_ClearCutsceneSpritesSubpixelPosition_Main
	LDX.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	LDA.l SMW_GameMode19_Cutscene_SkyColorSetting-$01,x
	ASL
	TAX
	REP.b #$20			; A->16
	LDA.l SMW_GlobalPalettes_Sky,x
	STA.w !RAM_SMW_Palettes_BackgroundColorLo
	SEP.b #$20			; A->8
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BRL.w CODE_0CCC9A

CODE_0CCC82:
	DEC.w !RAM_SMW_Sprites_TNTExplosionAnimationTimer
	BPL.b CODE_0CCC97
	LDA.w !RAM_SMW_Sprites_TNTExplosionAnimationIndex
	INC
	AND.b #$03
	STA.w !RAM_SMW_Sprites_TNTExplosionAnimationIndex
	TAX
	LDA.w DATA_0CCC49,x
	STA.w !RAM_SMW_Sprites_TNTExplosionAnimationTimer
CODE_0CCC97:
	JSR.w TNTExplosionGFXRt
CODE_0CCC9A:
	LDX.b #$1C
	BRL.w SMW_DrawCastleDestructionCastleDoor_Entry2

DATA_0CCC9F:
	db $A0,$A4,$00,$C0,$C4,$00
	db $A0,$A2,$A4,$C0,$C2,$C4
	db $00,$00,$00,$00,$00,$00

DATA_0CCCB1:
	db $00,$06,$0C,$06,$0C

TNTExplosionGFXRt:
	LDA.w !RAM_SMW_Sprites_TNTExplosionAnimationIndex
	INC
	TAX
	LDA.w DATA_0CCCB1,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDY.b #$A0
	CPX.b #$00
	BNE.b CODE_0CCCC8
	LDY.b #$A8
CODE_0CCCC8:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	STY.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b #$57
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$00
CODE_0CCCD2:
	LDY.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w DATA_0CCC9F,y
	BEQ.b CODE_0CCD02
	STA.w SMW_OAMBuffer[$01].Tile,x
	LDY.b #$35
	LDA.w !RAM_SMW_Sprites_TNTExplosionAnimationIndex
	BMI.b CODE_0CCCE9
	AND.b #$02
	BEQ.b CODE_0CCCE9
	LDY.b #$39
CODE_0CCCE9:
	TYA
	STA.w SMW_OAMBuffer[$01].Prop,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$01].XDisp,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$01].YDisp,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$01].Slot,x
	PLX
CODE_0CCD02:
	INC.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INX
	INX
	INX
	INX
	CPX.b #$0C
	BNE.b CODE_0CCD1E
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM02
CODE_0CCD1E:
	CPX.b #$18
	BNE.b CODE_0CCCD2
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeCastleCrumblingDown(Address)
namespace SMW_InitializeCastleCrumblingDown
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #!Define_SMW_Sound1DF9_ValleyOfBowserAppears
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	JSR.w SMW_InitializeCastleDust_Main
	BRL.w SMW_HandleCastleCrumblingDown_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_HandleCastleCrumblingDown(Address)
namespace SMW_HandleCastleCrumblingDown
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #$00
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$C0
	BNE.b CODE_0CCD31
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BRA.b CODE_0CCD75

CODE_0CCD31:
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYPosHi,x
	LDA.b #$F0
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYSpeed,x
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
	JSR.w SMW_ShakeCutsceneCastle_Main
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosHi,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$FD
	BNE.b CODE_0CCD59
	LDA.b #$01
	STA.w !RAM_SMW_Flag_ShowWhiteFlag
CODE_0CCD59:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$E8
	BNE.b CODE_0CCD62
	JSR.w SMW_InitializeCastleDestructionTextTimers_DontIncrementCutsceneProcess
CODE_0CCD62:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$C0
	BNE.b CODE_0CCD75
	LDA.b #!Define_SMW_Sound1DF9_EndValleyOfBowserAppears
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	JSR.w DrawCastleRubble
	LDA.b #$08
	STA.w !RAM_SMW_Sprites_CastleDustYSpeed
CODE_0CCD75:
	LDX.b #$01
	LDA.w !RAM_SMW_Sprites_CastleDustYSpeed-$01,x
	BPL.b CODE_0CCD85
	LDA.w !RAM_SMW_Sprites_CastleDustYPos-$01,x
	CMP.b #$68
	BCS.b CODE_0CCD91
	BRA.b CODE_0CCD94

CODE_0CCD85:
	LDA.w !RAM_SMW_Sprites_CastleDustYPos-$01,x
	CMP.b #$78
	BNE.b CODE_0CCD91
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BRA.b CODE_0CCD9E

CODE_0CCD91:
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
CODE_0CCD94:
	LDX.b #$00
	LDA.b #$04
	STA.w !RAM_SMW_Sprites_CutsceneSpriteXSpeed,x
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_X
CODE_0CCD9E:
	BRL.w SMW_HandleCastleLiftoff_CODE_0CCE2A
namespace off
endmacro

macro ROUTINE_RT01_SMW_HandleCastleCrumblingDown(Address)
namespace SMW_HandleCastleCrumblingDown
%InsertMacroAtXPosition(<Address>)

RubbleTiles:
	%StripeImageHeader(.Top, $13, $05, 0, $0000, 1)
	db $C0,$01,$C1,$01,$C2,$01,$C3,$01
	db $C4,$01,$C5,$01,$C1,$41,$C0,$41
.TopEnd:
	%StripeImageHeader(.Bottom, $13, $06, 0, $0000, 1)
	db $D0,$01,$D1,$01,$D2,$01,$D3,$01
	db $D4,$01,$D5,$01,$D1,$41,$D0,$41
.BottomEnd:
	db $FF

DrawCastleRubble:
	LDY.b #$28
	TYA
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
-:
	LDA.w RubbleTiles,y
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	DEX
	DEY
	BPL.b -
	LDA.b #$28
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_DrawCastleDestructionCastleDoor(Address)
namespace SMW_DrawCastleDestructionCastleDoor
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #$04
Entry2:
	LDA.b #$A8
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$5F
	STA.b !RAM_SMW_Misc_ScratchRAM01
Entry3:
	LDY.b #$00
CODE_0CCC08:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$60].XDisp,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$60].YDisp,x
	LDA.w Tiles,y
	STA.w SMW_OAMBuffer[$60].Tile,x
	LDA.b #$2D
	STA.w SMW_OAMBuffer[$60].Prop,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$60].Slot,x
	PLX
	INY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	TYA
	AND.b #$01
	BNE.b CODE_0CCC40
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM01
CODE_0CCC40:
	INX
	INX
	INX
	INX
	CPY.b #$04
	BNE.b CODE_0CCC08
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_DrawCastleDestructionCastleDoor(Address)
namespace SMW_DrawCastleDestructionCastleDoor
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $86,$87,$96,$97
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeDudTNTExplosion(Address)
namespace SMW_InitializeDudTNTExplosion
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$03
	STA.w !RAM_SMW_Sprites_DudTNTSmokeAnimationTimer
	STZ.w !RAM_SMW_Sprites_DudTNTSmokeAnimationIndex
	LDA.b #!Define_SMW_Sound1DFC_Clap
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSR.w SMW_DrawCastleDestructionCastleDoor_Main
	BRL.w SMW_HandleDudTNTExplosion_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleDudTNTExplosion(Address)
namespace SMW_HandleDudTNTExplosion
%InsertMacroAtXPosition(<Address>)

Main:
	DEC.w !RAM_SMW_Sprites_DudTNTSmokeAnimationTimer
	BPL.b CODE_0CCF8B
	LDA.b #$03
	STA.w !RAM_SMW_Sprites_DudTNTSmokeAnimationTimer
	INC.w !RAM_SMW_Sprites_DudTNTSmokeAnimationIndex
	LDA.w !RAM_SMW_Sprites_DudTNTSmokeAnimationIndex
	CMP.b #$04
	BNE.b CODE_0CCF8B
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BRA.b CODE_0CCF90

CODE_0CCF8B:
	LDX.b #$04
	JSR.w DrawDudTNTExplosion
CODE_0CCF90:
	LDX.b #$08
	LDA.b #$A8								;\ Optimization: Replace with BRL.w DrawCastleDestructionCastleDoor_Entry2
	STA.b !RAM_SMW_Misc_ScratchRAM00					;|
	STA.b !RAM_SMW_Misc_ScratchRAM02					;|
	LDA.b #$5F								;|
	STA.b !RAM_SMW_Misc_ScratchRAM01					;|
	BRL.w SMW_DrawCastleDestructionCastleDoor_Entry3			;/

TilesAndProp:
	db $60,$62,$64,$66

DrawDudTNTExplosion:
	LDY.w !RAM_SMW_Sprites_DudTNTSmokeAnimationIndex
	LDA.w TilesAndProp,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDY.b #$21								;\ Glitch: This LDY.b #$21 does nothing, so this sprite's tile property uses the tile number loaded.
	STA.w SMW_OAMBuffer[$00].Prop,x						;| To fix this, change it to LDA.b #$20.
										;/ Funnily enough, this bug is not visible in game normally, since the smoke tile doesn't use any palette specific colors.
	LDA.b #$AC
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.b #$63
	STA.w SMW_OAMBuffer[$00].YDisp,x
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessHammerDebris(Address)
namespace SMW_ProcessHammerDebris
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #!Define_SMW_MaxCutsceneSpriteSlot
CODE_0CD3F6:
	LDA.w !RAM_SMW_CutsceneSpr_HammerDebris_CurrentStatus,x
	BEQ.b CODE_0CD41B
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
	BMI.b CODE_0CD404
	CMP.b #$40
	BCS.b CODE_0CD40B
CODE_0CD404:
	CLC
	ADC.w !RAM_SMW_CutsceneSpr_HammerDebris_YAcceleration,x
	STA.w !RAM_SMW_Sprites_CutsceneSpriteYSpeed,x
CODE_0CD40B:
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_X
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,x
	CMP.b #$80
	BCC.b CODE_0CD41B
	STZ.w !RAM_SMW_CutsceneSpr_HammerDebris_CurrentStatus,x
CODE_0CD41B:
	DEX
	CPX.b #!Define_SMW_MaxCutsceneSpriteSlot-$0B
	BNE.b CODE_0CD3F6
	BRL.w DrawSprite

DATA_0CD423:
	db $3C,$3D

DrawSprite:
	LDY.b #!Define_SMW_MaxCutsceneSpriteSlot
	LDX.b #$14
CODE_0CD429:
	LDA.w !RAM_SMW_CutsceneSpr_HammerDebris_CurrentStatus,y
	BEQ.b CODE_0CD45A
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteXPosLo,y
	CMP.b #$50
	BCC.b CODE_0CD45A
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.w !RAM_SMW_Sprites_CutsceneSpriteYPosLo,y
	STA.w SMW_OAMBuffer[$00].YDisp,x
	PHY
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$02
	LSR
	TAY
	LDA.w DATA_0CD423,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	PLY
	LDA.b #$22
	STA.w SMW_OAMBuffer[$00].Prop,x
	PHX
	TXA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$00].Slot,x
	PLX
CODE_0CD45A:
	INX
	INX
	INX
	INX
	DEY
	CPY.b #!Define_SMW_MaxCutsceneSpriteSlot-$0B
	BNE.b CODE_0CD429
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeCastleLiftoff(Address)
namespace SMW_InitializeCastleLiftoff
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #!Define_SMW_Sound1DFC_FireSpit
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b #$77
	STA.w !RAM_SMW_Sprites_CastleRocketFlameYPos
	STZ.w !RAM_SMW_Sprites_CastleLiftoffYSpeed
	JSR.w SMW_InitializeCastleDust_Main
	BRL.w SMW_HandleCastleLiftoff_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleCastleLiftoff(Address)
namespace SMW_HandleCastleLiftoff
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_0CCDB9
	LDA.w !RAM_SMW_Sprites_CastleLiftoffYSpeed
	CLC
	ADC.b #$02
	STA.w !RAM_SMW_Sprites_CastleLiftoffYSpeed
	CMP.b #$80
	BCC.b CODE_0CCDB9
	LDA.b #$7F
	STA.w !RAM_SMW_Sprites_CastleLiftoffYSpeed
CODE_0CCDB9:
	LDX.b #$00
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYPosHi,x
	LDA.w !RAM_SMW_Sprites_CastleLiftoffYSpeed
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYSpeed,x
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	BEQ.b CODE_0CCDD7
	CMP.b #$20
	BCS.b CODE_0CCDDA
CODE_0CCDD7:
	JSR.w SMW_ShakeCutsceneCastle_Main
CODE_0CCDDA:
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosHi,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	BEQ.b CODE_0CCDEF
	CMP.b #$20
	BCC.b CODE_0CCDEF
	LDA.b #$08
	STA.w !RAM_SMW_Sprites_CastleDustYSpeed
CODE_0CCDEF:
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	BEQ.b CODE_0CCE02
	CMP.b #$A8
	BCC.b CODE_0CCE02
	LDA.b #$7F
	STA.w !RAM_SMW_Sprites_WaitBeforeCastleRocketAppearsInSky
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BRA.b CODE_0CCE1E

CODE_0CCE02:
	SEP.b #$20			; A->8
	LDX.b #$01
	LDA.w !RAM_SMW_Sprites_CastleDustYSpeed-$01,x
	BPL.b CODE_0CCE14
	LDA.w !RAM_SMW_Sprites_CastleDustYPos-$01,x
	CMP.b #$68
	BCS.b CODE_0CCE1B
	BRA.b CODE_0CCE1E

CODE_0CCE14:
	LDA.w !RAM_SMW_Sprites_CastleDustYPos-$01,x
	CMP.b #$78
	BCS.b CODE_0CCE1E
CODE_0CCE1B:
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
CODE_0CCE1E:
	LDA.b #$77
	SEC
	SBC.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo
	STA.w !RAM_SMW_Sprites_CastleRocketFlameYPos
	JSR.w DrawCastleRocketFlame
CODE_0CCE2A:
	JSR.w DrawCastleDust
	LDX.b #$14
	LDA.b #$A8
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$5F
	SEC
	SBC.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	BRL.w SMW_DrawCastleDestructionCastleDoor_Entry3

CastleDustTiles:
	db $80,$81,$82,$83,$83,$82,$81,$80

DrawCastleDust:
	DEC.w !RAM_SMW_Sprites_CastleDustAnimationTimer
	BPL.b CODE_0CCE5A
	LDA.b #$05
	STA.w !RAM_SMW_Sprites_CastleDustAnimationTimer
	LDA.w !RAM_SMW_Sprites_CastleDustFacingDirection
	EOR.b #$01
	STA.w !RAM_SMW_Sprites_CastleDustFacingDirection
CODE_0CCE5A:
	LDA.b #$98
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b #$21
	LDA.w !RAM_SMW_Sprites_CastleDustFacingDirection
	BEQ.b CODE_0CCE67
	LDY.b #$61
CODE_0CCE67:
	STY.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_Sprites_CastleDustFacingDirection
	ASL
	ASL
	TAY
	LDX.b #$00
CODE_0CCE71:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$01].XDisp,x
	LDA.w !RAM_SMW_Sprites_CastleDustYPos
	STA.w SMW_OAMBuffer[$01].YDisp,x
	LDA.w CastleDustTiles,y
	STA.w SMW_OAMBuffer[$01].Tile,x
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w SMW_OAMBuffer[$01].Prop,x
	PHX
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$01].Slot,x
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INY
	INX
	INX
	INX
	INX
	CPX.b #$10
	BNE.b CODE_0CCE71
	RTS

RocketFlameTiles:
	db $C6,$C8,$C6,$C8

RocketFlameProp:
	db $25,$25,$65,$65

DrawCastleRocketFlame:
	LDX.b #$30
	LDA.b #$B0
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.w !RAM_SMW_Sprites_CastleRocketFlameYPos
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$06
	LSR
	TAY
	LDA.w RocketFlameTiles,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.w RocketFlameProp,y
	STA.w SMW_OAMBuffer[$00].Prop,x
	TXA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeFarawayCastleRocket(Address)
namespace SMW_InitializeFarawayCastleRocket
%InsertMacroAtXPosition(<Address>)

Main:
	DEC.w !RAM_SMW_Sprites_WaitBeforeCastleRocketAppearsInSky
	BMI.b CODE_0CD2EC
	RTS

CODE_0CD2EC:
	JSR.w SMW_ClearCutsceneSpritesSubpixelPosition_Main
	LDA.b #$0F
	STA.w !RAM_SMW_Sprites_FarawayCastleRocketYPosLo
	STZ.w !RAM_SMW_Sprites_FarawayCastleRocketYPosHi
	LDA.b #$90
	STA.w !RAM_SMW_Sprites_FarawayCastleRocketXPosLo
	STZ.w !RAM_SMW_Sprites_FarawayCastleRocketXPosHi
	LDA.b #$08
	STA.w !RAM_SMW_Sprites_FarawayCastleRocketYSpeed
	LDA.b #$FF
	STA.w !RAM_SMW_Sprites_FarawayCastleRocketXSpeed
	LDA.b #$02
	STA.w !RAM_SMW_Sprites_DestroyedCastleRocketAnimationTimer
	STZ.w !RAM_SMW_Sprites_FarawayCastleRocketAnimationIndex
	STZ.w !RAM_SMW_Sprites_DestroyedCastleRocketSmokeIndex
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BRL.w SMW_HandleFarawayCastleRocket_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleFarawayCastleRocket(Address)
namespace SMW_HandleFarawayCastleRocket
%InsertMacroAtXPosition(<Address>)

DATA_0CCED4:
	db $02,$FF,$02,$03,$04,$05,$06

DATA_0CCEDB:
	db $03,$01,$07,$07,$07,$07,$07

Main:
	LDA.w !RAM_SMW_Sprites_FarawayCastleRocketAnimationIndex
	CMP.b #$02
	BCS.b CODE_0CCF0F
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BEQ.b CODE_0CCEF7
	LDA.w !RAM_SMW_Sprites_FarawayCastleRocketAnimationIndex
	EOR.b #$01
	STA.w !RAM_SMW_Sprites_FarawayCastleRocketAnimationIndex
CODE_0CCEF7:
	LDX.b #$02
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_X
	LDA.w !RAM_SMW_Sprites_FarawayCastleRocketYPosLo
	CMP.b #$5C
	BCC.b CODE_0CCF0D
	LDA.b #$02
	STA.w !RAM_SMW_Sprites_FarawayCastleRocketAnimationIndex
	BRA.b CODE_0CCF0F

CODE_0CCF0D:
	BRA.b CODE_0CCF38

CODE_0CCF0F:
	DEC.w !RAM_SMW_Sprites_DestroyedCastleRocketAnimationTimer
	BPL.b CODE_0CCF38
	LDA.w !RAM_SMW_Sprites_DestroyedCastleRocketSmokeIndex
	INC
	STA.w !RAM_SMW_Sprites_DestroyedCastleRocketSmokeIndex
	TAX
	LDA.w DATA_0CCED4,x
	STA.w !RAM_SMW_Sprites_FarawayCastleRocketAnimationIndex
	LDA.w DATA_0CCEDB,x
	STA.w !RAM_SMW_Sprites_DestroyedCastleRocketAnimationTimer
	CPX.b #$01
	BNE.b CODE_0CCF31
	LDA.b #!Define_SMW_Sound1DF9_SpinJumpKill
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_0CCF31:
	CPX.b #$06
	BNE.b CODE_0CCF38
	JSR.w SMW_InitializeCastleDestructionTextTimers_Main
CODE_0CCF38:
	BRL.w DrawSprite

Tiles:
	db $B7,$B8
	db $89,$99,$A9,$B9,$E8

Prop:
	db $25,$25
	db $23,$23,$23,$23,$23

DrawSprite:
	LDY.w !RAM_SMW_Sprites_FarawayCastleRocketAnimationIndex
	CPY.b #$FF
	BEQ.b Return0CCF71
	LDX.b #$04
	LDA.w !RAM_SMW_Sprites_FarawayCastleRocketXPosLo
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.w !RAM_SMW_Sprites_FarawayCastleRocketYPosLo
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LDA.w Tiles,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.w Prop,y
	STA.w SMW_OAMBuffer[$00].Prop,x
	TXA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$00].Slot,x
Return0CCF71:
	RTS

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeCastleDestructionTextTimers(Address)
namespace SMW_InitializeCastleDestructionTextTimers
%InsertMacroAtXPosition(<Address>)

Main:
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
DontIncrementCutsceneProcess:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.b #$80
else
	LDA.b #$FF
endif
	STA.w !RAM_SMW_Timer_DisplayCastleDestructionText
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$A8
elseif ver_is_arcade(!Define_Global_ROMToAssemble)
	LDA.b #$01
else
	LDA.b #$D0
endif
	STA.w !RAM_SMW_Timer_WaitBeforeAllowingEndOfCastleDestructionCutscene
	LDA.b #!Define_SMW_LevelMusic_Welcome
	STA.w !RAM_SMW_IO_MusicCh1
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckIfPlayerCanEndCastleDestructionCutscene(Address)
namespace SMW_CheckIfPlayerCanEndCastleDestructionCutscene
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Timer_DisplayCastleDestructionText
	ORA.w !RAM_SMW_Timer_WaitBeforeAllowingEndOfCastleDestructionCutscene
	BNE.b Return0CCFF6
if ver_is_arcade(!Define_Global_ROMToAssemble)
	DEC.w !RAM_SMW_Overworld_EnterLevelFlag
	BEQ.b CODE_0CCFED
endif
	LDA.b !RAM_SMW_IO_ControllerPress1	;!
	ORA.b !RAM_SMW_IO_ControllerPress2	;!
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	AND.b #!Joypad_X|(!Joypad_Y>>8)|!Joypad_A|(!Joypad_B>>8)	;!
endif
	BEQ.b Return0CCFF6
CODE_0CCFED:
	STZ.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	LDA.b #!Define_SMW_GameMode0B_FadeOutToOverworld
	STA.w !RAM_SMW_Misc_GameMode
Return0CCFF6:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_WaitForCastleDestructionTextToFinishInRoyCutscene(Address)
namespace SMW_WaitForCastleDestructionTextToFinishInRoyCutscene
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Timer_DisplayCastleDestructionText
	BEQ.b Return0CD002
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	BRL.w SMW_CheckIfPlayerCanEndCastleDestructionCutscene_Main

Return0CD002:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ClearCutsceneSpritesSubpixelPosition(Address)
namespace SMW_ClearCutsceneSpritesSubpixelPosition
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubYPos
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubXPos
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubYPos+$01
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubXPos+$01
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubXPos+$02				;\ Glitch: Seems like Nintendo accidentally forgot to clear the Y subpixels.
	STZ.w !RAM_SMW_Sprites_CutsceneSpriteSubXPos+$02				;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ShakeCutsceneCastle(Address)
namespace SMW_ShakeCutsceneCastle
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w #$0001
	BEQ.b CODE_0CD290
	INC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	BRA.b CODE_0CD292

CODE_0CD290:
	DEC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
CODE_0CD292:
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeCastleDust(Address)
namespace SMW_InitializeCastleDust
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$77
	STA.w !RAM_SMW_Sprites_CastleDustYPos
	LDA.b #$5F
	STA.w !RAM_SMW_Sprites_SmallCastleDoorXPosLo
	LDA.b #$F8
	STA.w !RAM_SMW_Sprites_CastleDustYSpeed
	STZ.w !RAM_SMW_Sprites_CastleDustFacingDirection
	LDA.b #$05
	STA.w !RAM_SMW_Sprites_CastleDustAnimationTimer
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	JSR.w SMW_ClearCutsceneSpritesSubpixelPosition_Main
	BRL.w SMW_DrawCastleDestructionCastleDoor_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PlayerDropkicksAndStompsCastle(Address)
namespace SMW_PlayerDropkicksAndStompsCastle
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Flag_DropkickCounter
	CMP.b #$01
	BEQ.b PrepareToStomp
	CMP.b #$02
	BEQ.b Dropkick
	CMP.b #$03
	BEQ.b Stomping
	LDA.b #$10
	STA.w !RAM_SMW_Sprites_DropkickContactAnimationTimer
	BRA.b CODE_0CD046

Dropkick:
	LDA.w !RAM_SMW_Sprites_DropkickContactAnimationTimer
	AND.b #$F8
	BEQ.b CODE_0CD023
	JSR.w SMW_DrawCutsceneContactEffect_Main
CODE_0CD023:
	JSR.w SMW_ShakeCutsceneCastle_Main
	DEC.w !RAM_SMW_Sprites_DropkickContactAnimationTimer
	BPL.b CODE_0CD046
	STZ.w !RAM_SMW_Flag_DropkickCounter
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BRA.b CODE_0CD046

PrepareToStomp:
	LDA.b #$3F
	STA.w !RAM_SMW_Sprites_WaitBeforeCastleCrumblesFromStompTimer
	LDA.b #$03
	STA.w !RAM_SMW_Flag_DropkickCounter
Stomping:
	DEC.w !RAM_SMW_Sprites_WaitBeforeCastleCrumblesFromStompTimer
	BPL.b CODE_0CD046
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
CODE_0CD046:
	LDX.b #$A8
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	BEQ.b CODE_0CD054
	BPL.b CODE_0CD052
	LDX.b #$A9
	BRA.b CODE_0CD054

CODE_0CD052:
	LDX.b #$A7
CODE_0CD054:
	STX.b !RAM_SMW_Misc_ScratchRAM00
	STX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$5F
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDX.b #$08
	BRL.w SMW_DrawCastleDestructionCastleDoor_Entry3
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawCutsceneContactEffect(Address)
namespace SMW_DrawCutsceneContactEffect
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $7C,$7D,$7D,$7C

Prop:
	db $30,$30,$F0,$F0

Main:
	LDY.b #$00
	LDX.b #$04
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM01
CODE_0CD07D:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].XDisp,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LDA.w Tiles,y
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.w Prop,y
	STA.w SMW_OAMBuffer[$00].Prop,x
	PHX
	TXA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$00].Slot,x
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INY
	CPY.b #$02
	BNE.b CODE_0CD0B3
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM01
CODE_0CD0B3:
	INX
	INX
	INX
	INX
	CPY.b #$04
	BNE.b CODE_0CD07D
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UprootCastleFromGround(Address)
namespace SMW_UprootCastleFromGround
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Flag_PickedUpCastle
	CMP.b #$01
	BNE.b Return0CD107
	LDX.b #$00
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYPosHi,x
	LDA.b #$08
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYSpeed,x
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	BEQ.b CODE_0CD100
	CMP.b #$09
	BCC.b CODE_0CD100
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	LDA.b #$28
	STA.w !RAM_SMW_Sprites_KickedCastleYSpeed
	BRA.b Return0CD107

CODE_0CD100:
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosHi,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
Return0CD107:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_KickCastleAway(Address)
namespace SMW_KickCastleAway
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Flag_KickedCastle
	CMP.b #$02
	BNE.b Return0CD16E
	DEC.w !RAM_SMW_Sprites_KickedCastleYSpeed
	LDA.w !RAM_SMW_Sprites_KickedCastleYSpeed
	BMI.b CODE_0CD11E
	CMP.b #$24
	BCC.b CODE_0CD11E
	JSR.w SMW_DrawCutsceneContactEffect_Main
CODE_0CD11E:
	LDA.w !RAM_SMW_Sprites_KickedCastleYSpeed
	CMP.b #$C8
	BNE.b CODE_0CD133
	LDA.b #$40
	STA.w !RAM_SMW_Sprites_KickedCastleQuakeTimer
	LDA.b #!Define_SMW_Sound1DFC_Explosion
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
	RTS

CODE_0CD133:
	LDX.b #$00
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYPosHi,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w !RAM_SMW_Sprites_SmallCastleDoorXPosLo,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	STA.w !RAM_SMW_Sprites_SmallCastleDoorXPosHi,x
	LDA.w !RAM_SMW_Sprites_KickedCastleYSpeed
	STA.w !RAM_SMW_Sprites_SmallCastleDoorYSpeed,x
	LDA.b #$E8
	STA.w !RAM_SMW_Sprites_SmallCastleDoorXSpeed,x
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_Y
	JSR.w SMW_CopyOfUpdateCutsceneSpritePosition_X
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosLo,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorYPosHi,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorXPosLo,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.w !RAM_SMW_Sprites_SmallCastleDoorXPosHi,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
Return0CD16E:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_KickedCastleCreatesQuake(Address)
namespace SMW_KickedCastleCreatesQuake
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$02
	BEQ.b CODE_0CD183					;\ Optimization: Use a table to add #$0001/#$FFFF to !RAM_SMW_Mirror_CurrentLayer2YPosLo using the !RAM_SMW_Counter_GlobalFrames as the index
	REP.b #$20						;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo		;|
	SEC							;|
	SBC.w #$0001						;|
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo		;|
	SEP.b #$20						;|
	BRA.b CODE_0CD18F					;|
								;|
CODE_0CD183:							;|
	REP.b #$20						;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo		;|
	CLC							;|
	ADC.w #$0001						;|
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo		;|
	SEP.b #$20						;/
CODE_0CD18F:
	DEC.w !RAM_SMW_Sprites_KickedCastleQuakeTimer
	BPL.b Return0CD19B
	STZ.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	STZ.b !RAM_SMW_Mirror_CurrentLayer2YPosHi
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
Return0CD19B:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_WaitForPlayerVictoryPoseAfterCastleQuake(Address)
namespace SMW_WaitForPlayerVictoryPoseAfterCastleQuake
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Flag_ShowVictoryPoseInLarryCutscene
	CMP.b #$03
	BNE.b Return0CD1A6
	JSR.w SMW_InitializeCastleDestructionTextTimers_Main
Return0CD1A6:
	RTS

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_WaitForWendysCastleToBeFullyMopped(Address)
namespace SMW_WaitForWendysCastleToBeFullyMopped
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Flag_FullyMoppedCastle
	BEQ.b Return0CD0D1
	JSR.w SMW_InitializeCastleDestructionTextTimers_Main
Return0CD0D1:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_WaitBeforeMakingHammeredCastleCrumble(Address)
namespace SMW_WaitBeforeMakingHammeredCastleCrumble
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Flag_HammeredCastleShouldCrumble
	CMP.b #$01
	BNE.b CODE_0CD0C6
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
CODE_0CD0C6:
	BRL.w SMW_HandleDudTNTExplosion_CODE_0CCF90				; Optimization: Replace with BRL.w DrawCastleDestructionCastleDoor_Entry2
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DelayTNTExplosionUntilPlayerComesBy(Address)
namespace SMW_DelayTNTExplosionUntilPlayerComesBy
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Sprites_QuestionMarkAnimationIndex
	CMP.b #$03
	BEQ.b CODE_0CCFD3
	LDA.b #$08
	STA.w !RAM_SMW_Sprites_DelayedTNTExplosionTimer
	BRA.b CODE_0CCFDB

CODE_0CCFD3:
	DEC.w !RAM_SMW_Sprites_DelayedTNTExplosionTimer
	BPL.b CODE_0CCFDB
	INC.w !RAM_SMW_Pointer_CurrentCutsceneProcess
CODE_0CCFDB:
	BRL.w SMW_HandleDudTNTExplosion_CODE_0CCF90				; Optimization: Replace with BRL.w DrawCastleDestructionCastleDoor_Entry2
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_ProcessMop(Address)
namespace SMW_ProcessMop
%InsertMacroAtXPosition(<Address>)

DATA_0CD6C4:
	db $E7,$E6,$E6,$EA,$E6,$E7

DATA_0CD6CA:
	db $F6,$F1,$F3,$F3,$F3,$F4

DATA_0CD6D0:
	db $1B,$0E,$00

DATA_0CD6D3:
	db $15,$08,$00

Tiles:
	db $8E,$8E,$8C

DATA_0CD6D9:
	db $FC,$04,$FC,$04,$FC,$04,$FC

DATA_0CD6E0:
	db $34,$68,$34,$68,$34

DATA_0CD6E5:
	db $68,$34,$B0,$00,$C0,$00,$C0

Main:
	LDA.w !RAM_SMW_Flag_DisplayThankYouBubble
	LSR
	BEQ.b Return0CD751
	LDY.b #$04
	LDA.b #$02
CODE_0CD6F6:
	STA.w SMW_OAMTileSizeBuffer[$50].Slot,y
	DEY
	BPL.b CODE_0CD6F6
	LDA.w !RAM_SMW_Sprites_MopYPosLo
	BNE.b CODE_0CD752
	LDA.w !RAM_SMW_Player_WalkingFrame
	ASL
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_0CD70A
	INC
CODE_0CD70A:
	TAY
	LDA.w DATA_0CD6C4,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w DATA_0CD6CA,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Player_FacingDirection
	LSR
	ROR
	LSR
	EOR.b #$61
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$02
CODE_0CD720:
	TXA
	ASL
	ASL
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_0CD6D0,x
	BIT.b !RAM_SMW_Misc_ScratchRAM02
	BVC.b CODE_0CD731
	EOR.b #$FF
	INC
CODE_0CD731:
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.w SMW_OAMBuffer[$50].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w DATA_0CD6D3,x
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.w SMW_OAMBuffer[$50].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$50].Tile,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$50].Prop,y
	DEX
	BPL.b CODE_0CD720
Return0CD751:
	RTS

CODE_0CD752:
	AND.b #$07
	BNE.b CODE_0CD759
	JSR.w EraseColumn
CODE_0CD759:
	LDY.b #$25
	LDA.w !RAM_SMW_Sprites_MopYPosLo
	CMP.b #$4C
	BCC.b CODE_0CD764
	LDY.b #$38			; \ Mario's image = Ducking, back to camera
CODE_0CD764:
	STY.w !RAM_SMW_Player_CurrentPose
	LDY.b #$00
	DEC
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$AC
CODE_0CD76E:
	STA.w SMW_OAMBuffer[$50].Tile,y
	LDA.b #$21
	STA.w SMW_OAMBuffer[$50].Prop,y
	LDA.b !RAM_SMW_Player_XPosLo
	STA.w SMW_OAMBuffer[$50].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$50].YDisp,y
	CLC
	ADC.b #$10
	CMP.b #$68
	BCC.b CODE_0CD789
	LDA.b #$68
CODE_0CD789:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INY
	INY
	INY
	INY
	LDA.b #$AE
	CPY.b #$14
	BCC.b CODE_0CD76E
	LDX.w !RAM_SMW_Sprites_MoppingMovementDirection
	LDA.w !RAM_SMW_Sprites_MopYPosLo
	CMP.w DATA_0CD6E0,x
	BNE.b CODE_0CD7DE
	LDA.w !RAM_SMW_Sprites_MopTimer
	BEQ.b CODE_0CD7A9
	DEC.w !RAM_SMW_Sprites_MopTimer
	RTS

CODE_0CD7A9:
	TXA
	BEQ.b CODE_0CD7C9
	LSR
	BCS.b CODE_0CD7C9
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$04
	BEQ.b CODE_0CD7BA
	LDA.b #$39			; \ Mario's image = Standing, back to camera
	STA.w !RAM_SMW_Player_CurrentPose
CODE_0CD7BA:
	LDA.b !RAM_SMW_Player_XPosLo
	CMP.w DATA_0CD6E5,x
	BEQ.b CODE_0CD7C9
	INC
	STA.b !RAM_SMW_Player_XPosLo
	AND.b #$0F
	BEQ.b CODE_0CD7E5
	RTS

CODE_0CD7C9:
	INC.w !RAM_SMW_Sprites_MoppingMovementDirection
	CPX.b #$06
	BCC.b CODE_0CD7D4
	STZ.w !RAM_SMW_Sprites_MopYPosLo
	RTS

CODE_0CD7D4:
	TXA
	LSR
	BCS.b Return0CD7DD
	LDA.b #!Define_SMW_Sound1DF9_HurtWhileFlying
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
Return0CD7DD:
	RTS

CODE_0CD7DE:
	CLC
	ADC.w DATA_0CD6D9,x
	STA.w !RAM_SMW_Sprites_MopYPosLo
CODE_0CD7E5:
	LDA.b #$10
	STA.w !RAM_SMW_Sprites_MopTimer
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_ProcessMop(Address)
namespace SMW_ProcessMop
%InsertMacroAtXPosition(<Address>)

DATA_0CD1F0:
	db $20,$F4,$40,$02
	db $F8,$00
	db $21,$14,$40,$02
	db $F8,$00
	db $FF

DATA_0CD1FD:
	db $20,$F4,$21,$14
	db $21,$34,$21,$54
	db $21,$74,$21,$94
	db $21,$B4,$21,$D4
	db $20,$F6,$21,$16
	db $21,$36,$21,$56
	db $21,$76,$21,$96
	db $21,$B6,$21,$D6
	db $20,$F8,$21,$18
	db $21,$38,$21,$58
	db $21,$78,$21,$98
	db $21,$B8,$21,$D8

EraseColumn:
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.b #$0C
	TYA
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_0CD23C:
	LDA.w DATA_0CD1F0,y
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	DEX
	DEY
	BPL.b CODE_0CD23C
	LDA.b #$0C
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	LDA.b !RAM_SMW_Player_XPosLo
	SEC
	SBC.b #$A0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_MopYPosLo
	SEC
	SBC.b #$38
	LSR
	LSR
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	LDX.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.w DATA_0CD1FD,y
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	LDA.w DATA_0CD1FD+$02,y
	STA.l SMW_StripeImageUploadTable[$03].LowByte,x
	SEP.b #$20			; A->8
	CPY.b #$1C
	BNE.b Return0CD282
	LDA.b #$01
	STA.w !RAM_SMW_Flag_ShowWhiteFlag
Return0CD282:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_OverworldLayer2EventTilemap(Address)
namespace SMW_OverworldLayer2EventTilemap
%InsertMacroAtXPosition(<Address>)

Tiles:
.SixBySix
	; Uncompressed tile numbers for the layer 2 event tiles. The first 0x900
	; bytes are for the 6x6 blocks of 8x8 tiles, the last 0x400 bytes are for
	; 2x2 blocks of 8x8 tiles. Lunar Magic may move this table to a new
	; location that can be found at read3($04EAF5). The number of 6x6 tiles may
	; also be adjusted, with the number of bytes for them found at
	; read2($04E4C0).
	incbin "overworld/layer2/events/6x6Tiles.bin"
.TwoByTwo
	incbin "overworld/layer2/events/2x2Tiles.bin"
; YXPCCCTT data for the Layer 2 event tiles, compressed via LC_RLE1. Lunar
; Magic may move this table to a new location that can be found at
; (read1($04DD4A)<<16)|read2($04DD45).
Prop:
	incbin "overworld/layer2/events/properties.bin"
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_CastleDestructionText(Address)
namespace SMW_CastleDestructionText
%InsertMacroAtXPosition(<Address>)

cleartable

Main:
if ver_is_japanese(!Define_Global_ROMToAssemble)
Iggy:
.Line1:
db $52,$50,$00,$01
db $59,$39
db $52,$5A,$00,$01
db $5B,$39
db $52,$64,$00,$2F
db $47,$39,$5A,$39,$4A,$39,$4B,$39,$5A,$39,$11,$39,$02,$39,$14,$39,$5D,$39,$50,$39,$09,$39,$5C,$39,$10,$39,$5D,$39,$08,$39,$01,$39,$09,$39,$84,$39,$14,$39,$6C,$39,$5F,$39,$65,$39,$61,$39,$77,$39
.Line1End:
	db $FF
.Line2:
db $52,$92,$00,$01
db $5B,$39
db $52,$97,$00,$01
db $59,$39
db $52,$9B,$00,$01
db $59,$39
db $52,$A4,$00,$2F
db $0D,$39,$50,$39,$09,$39,$0D,$39,$5D,$39,$67,$39,$60,$39,$6A,$39,$0D,$39,$0E,$39,$15,$39,$5D,$39,$5F,$39,$65,$39,$61,$39,$14,$39,$19,$39,$54,$39,$02,$39,$10,$39,$5D,$39,$0D,$39,$19,$39,$07,$39
.Line2End:
	db $FF
.Line3:
db $52,$D0,$00,$01
db $59,$39
db $52,$D3,$00,$01
db $59,$39
db $52,$E4,$00,$2D
db $12,$39,$08,$39,$57,$39,$0D,$39,$5D,$39,$52,$39,$04,$39,$19,$39,$77,$39,$0D,$39,$0A,$39,$06,$39,$0D,$39,$09,$39,$5D,$39,$64,$39,$5A,$39,$46,$39,$41,$39,$18,$39,$01,$39,$1E,$39,$18,$39
.Line3End:
	db $FF
.Line4:
db $53,$05,$00,$01
db $59,$39
db $53,$06,$00,$01
db $59,$39
db $53,$09,$00,$01
db $59,$39
db $53,$24,$00,$17
db $0D,$39,$16,$39,$0D,$39,$0F,$39,$14,$39,$10,$39,$00,$39,$55,$39,$19,$39,$09,$39,$0D,$39,$78,$39
.Line4End:
	db $FF

Morton:
.Line1:
db $52,$4C,$00,$01
db $59,$39
db $52,$53,$00,$01
db $5B,$39
db $52,$64,$00,$2F
db $67,$39,$60,$39,$6A,$39,$0D,$39,$0E,$39,$15,$39,$5D,$39,$12,$39,$15,$39,$21,$39,$1C,$39,$14,$39,$6C,$39,$5F,$39,$65,$39,$61,$39,$1D,$39,$5D,$39,$1E,$39,$7C,$39,$0F,$39,$06,$39,$10,$39,$5D,$39
.Line1End:
	db $FF
.Line2:
db $52,$84,$00,$01
db $59,$39
db $52,$96,$00,$01
db $59,$39
db $52,$99,$00,$01
db $59,$39
db $52,$A4,$00,$2F
db $64,$39,$5A,$39,$46,$39,$41,$39,$18,$39,$01,$39,$1E,$39,$04,$39,$20,$39,$5D,$39,$0E,$39,$04,$39,$14,$39,$0B,$39,$04,$39,$01,$39,$14,$39,$5D,$39,$61,$39,$40,$39,$63,$39,$64,$39,$5A,$39,$43,$39
.Line2End:
	db $FF
.Line3:
db $52,$C9,$00,$01
db $59,$39
db $52,$D2,$00,$01
db $59,$39
db $52,$D7,$00,$01
db $59,$39
db $52,$E4,$00,$2F
db $18,$39,$11,$39,$0A,$39,$0A,$39,$21,$39,$10,$39,$01,$39,$05,$39,$3F,$39,$07,$39,$14,$39,$08,$39,$51,$39,$5D,$39,$11,$39,$21,$39,$52,$39,$A7,$39,$46,$39,$04,$39,$19,$39,$0E,$39,$04,$39,$19,$39
.Line3End:
	db $FF
.Line4:
db $53,$0B,$00,$01
db $5B,$39
db $53,$24,$00,$2F
db $03,$39,$10,$39,$01,$39,$56,$39,$04,$39,$3D,$39,$5D,$39,$79,$39,$5A,$39,$7B,$39,$16,$39,$1C,$39,$14,$39,$02,$39,$21,$39,$1C,$39,$01,$39,$1E,$39,$5D,$39,$01,$39,$04,$39,$12,$39,$3F,$39,$3D,$39
.Line4End:
	db $FF

Lemmy:
.Line1:
db $52,$4D,$00,$01
db $59,$39
db $52,$54,$00,$01
db $5B,$39
db $52,$64,$00,$2F
db $67,$39,$60,$39,$6A,$39,$0D,$39,$0E,$39,$15,$39,$5D,$39,$08,$39,$21,$39,$15,$39,$21,$39,$1C,$39,$14,$39,$6C,$39,$5F,$39,$65,$39,$61,$39,$1D,$39,$5D,$39,$1E,$39,$7C,$39,$0F,$39,$06,$39,$10,$39
.Line1End:
	db $FF
.Line2:
db $52,$A4,$00,$2F
db $54,$39,$7C,$39,$11,$39,$5D,$39,$16,$39,$11,$39,$01,$39,$51,$39,$78,$39,$5D,$39,$09,$39,$04,$39,$09,$39,$6C,$39,$5A,$39,$4A,$39,$15,$39,$5D,$39,$06,$39,$58,$39,$09,$39,$05,$39,$52,$39,$56,$39
.Line2End:
	db $FF
.Line3:
db $52,$C9,$00,$01
db $59,$39
db $52,$E4,$00,$2F
db $1D,$39,$09,$39,$1D,$39,$5D,$39,$1A,$39,$11,$39,$55,$39,$1E,$39,$00,$39,$04,$39,$14,$39,$4A,$39,$48,$39,$65,$39,$7B,$39,$77,$39,$5D,$39,$11,$39,$7C,$39,$10,$39,$01,$39,$52,$39,$01,$39,$11,$39
.Line3End:
	db $FF
.Line4:
db $53,$08,$00,$01
db $59,$39
db $53,$0C,$00,$01
db $59,$39
db $53,$12,$00,$01
db $59,$39
db $53,$24,$00,$27
db $09,$39,$0D,$39,$20,$39,$5D,$39,$11,$39,$21,$39,$52,$39,$0D,$39,$16,$39,$12,$39,$5D,$39,$52,$39,$56,$39,$14,$39,$10,$39,$00,$39,$5C,$39,$02,$39,$04,$39,$3F,$39
.Line4End:
	db $FF

Ludwig:
.Line1:
db $52,$46,$00,$01
db $59,$39
db $52,$4D,$00,$01
db $5B,$39
db $52,$64,$00,$2F
db $1F,$39,$21,$39,$15,$39,$21,$39,$1C,$39,$14,$39,$6C,$39,$5F,$39,$65,$39,$61,$39,$1D,$39,$5D,$39,$52,$39,$21,$39,$11,$39,$04,$39,$5F,$39,$60,$39,$62,$39,$5A,$39,$5D,$39,$67,$39,$60,$39,$6A,$39
.Line1End:
	db $FF
.Line2:
db $52,$A4,$00,$2F
db $0D,$39,$0E,$39,$15,$39,$5D,$39,$07,$39,$57,$39,$04,$39,$20,$39,$5D,$39,$19,$39,$1F,$39,$01,$39,$14,$39,$1D,$39,$55,$39,$12,$39,$15,$39,$01,$39,$7C,$39,$10,$39,$01,$39,$05,$39,$3F,$39,$3D,$39
.Line2End:
	db $FF
.Line3:
db $52,$C5,$00,$01
db $59,$39
db $52,$CD,$00,$01
db $59,$39
db $52,$D1,$00,$01
db $59,$39
db $52,$D2,$00,$01
db $59,$39
db $52,$E4,$00,$2F
db $52,$39,$0C,$39,$77,$39,$11,$39,$04,$39,$52,$39,$01,$39,$11,$39,$5D,$39,$10,$39,$56,$39,$07,$39,$11,$39,$04,$39,$10,$39,$51,$39,$52,$39,$01,$39,$11,$39,$01,$39,$02,$39,$5D,$39,$17,$39,$09,$39
.Line3End:
	db $FF
.Line4:
db $53,$04,$00,$01
db $59,$39
db $53,$15,$00,$01
db $59,$39
db $53,$16,$00,$01
db $59,$39
db $53,$24,$00,$2F
db $51,$39,$14,$39,$1D,$39,$55,$39,$3F,$39,$15,$39,$0D,$39,$09,$39,$10,$39,$1D,$39,$55,$39,$77,$39,$53,$39,$06,$39,$56,$39,$07,$39,$11,$39,$04,$39,$10,$39,$51,$39,$56,$39,$14,$39,$04,$39,$3D,$39
.Line4End:
	db $FF

Roy:
.Line1:
db $52,$4B,$00,$01
db $59,$39
db $52,$4C,$00,$01
db $59,$39
db $52,$53,$00,$01
db $5B,$39
db $52,$64,$00,$2F
db $67,$39,$60,$39,$6A,$39,$0D,$39,$0E,$39,$15,$39,$5D,$39,$07,$39,$15,$39,$21,$39,$1C,$39,$14,$39,$6C,$39,$5F,$39,$65,$39,$61,$39,$77,$39,$1E,$39,$7C,$39,$0F,$39,$06,$39,$5D,$39,$1E,$39,$7C,$39
.Line1End:
	db $FF
.Line2:
db $52,$8E,$00,$01
db $59,$39
db $52,$8F,$00,$01
db $59,$39
db $52,$94,$00,$01
db $59,$39
db $52,$95,$00,$01
db $59,$39
db $52,$A4,$00,$2F
db $11,$39,$5D,$39,$1D,$39,$55,$39,$77,$39,$53,$39,$06,$39,$56,$39,$07,$39,$11,$39,$04,$39,$10,$39,$51,$39,$0D,$39,$78,$39,$5D,$39,$0D,$39,$04,$39,$5D,$39,$07,$39,$14,$39,$08,$39,$51,$39,$14,$39
.Line2End:
	db $FF
.Line3:
db $52,$CE,$00,$01
db $59,$39
db $52,$D5,$00,$01
db $59,$39
db $52,$D7,$00,$01
db $59,$39
db $52,$D9,$00,$01
db $59,$39
db $52,$E4,$00,$2F
db $7B,$39,$44,$39,$6C,$39,$4E,$39,$5A,$39,$11,$39,$02,$39,$15,$39,$5D,$39,$52,$39,$0C,$39,$14,$39,$6C,$39,$5A,$39,$4A,$39,$11,$39,$5D,$39,$64,$39,$63,$39,$6C,$39,$4C,$39,$10,$39,$01,$39,$7C,$39
.Line3End:
	db $FF
.Line4:
db $53,$04,$00,$01
db $5B,$39
db $53,$09,$00,$01
db $59,$39
db $53,$13,$00,$01
db $59,$39
db $53,$17,$00,$01
db $59,$39
db $53,$24,$00,$2F
db $15,$39,$01,$39,$78,$39,$5D,$39,$0F,$39,$51,$39,$52,$39,$56,$39,$0D,$39,$0D,$39,$04,$39,$01,$39,$14,$39,$5D,$39,$15,$39,$09,$39,$19,$39,$55,$39,$15,$39,$09,$39,$19,$39,$55,$39,$5A,$39,$3F,$39
.Line4End:
	db $FF

Wendy:
.Line1:
db $52,$47,$00,$01
db $59,$39
db $52,$4E,$00,$01
db $5B,$39
db $52,$64,$00,$2B
db $5D,$39,$5C,$39,$05,$39,$15,$39,$21,$39,$1C,$39,$14,$39,$6C,$39,$5F,$39,$65,$39,$61,$39,$77,$39,$0D,$39,$50,$39,$09,$39,$0D,$39,$67,$39,$60,$39,$6A,$39,$0D,$39,$0E,$39,$3F,$39
.Line1End:
	db $FF
.Line2:
db $52,$8D,$00,$01
db $59,$39
db $52,$96,$00,$01
db $5B,$39
db $52,$A4,$00,$2D
db $5D,$39,$07,$39,$14,$39,$08,$39,$51,$39,$14,$39,$5D,$39,$0E,$39,$21,$39,$54,$39,$0F,$39,$0B,$39,$21,$39,$12,$39,$15,$39,$5D,$39,$5F,$39,$65,$39,$61,$39,$14,$39,$0D,$39,$12,$39,$14,$39
.Line2End:
	db $FF
.Line3:
db $52,$C7,$00,$01
db $59,$39
db $52,$D2,$00,$01
db $59,$39
db $52,$D3,$00,$01
db $59,$39
db $52,$E4,$00,$2B
db $5D,$39,$01,$39,$55,$39,$05,$39,$0E,$39,$77,$39,$16,$39,$20,$39,$05,$39,$0D,$39,$1C,$39,$14,$39,$5D,$39,$D0,$39,$4D,$39,$04,$39,$00,$39,$56,$39,$20,$39,$09,$39,$01,$39,$78,$39
.Line3End:
	db $FF
.Line4:
db $53,$07,$00,$01
db $59,$39
db $53,$0E,$00,$01
db $59,$39
db $53,$10,$00,$01
db $59,$39
db $53,$15,$00,$01
db $59,$39
db $53,$24,$00,$25
db $5D,$39,$01,$39,$0C,$39,$06,$39,$5D,$39,$67,$39,$60,$39,$6A,$39,$3F,$39,$5D,$39,$04,$39,$21,$39,$15,$39,$57,$39,$5D,$39,$FF,$39,$48,$39,$6B,$39,$3F,$39
.Line4End:
	db $FF

Larry:
.Line1:
db $52,$4A,$00,$01
db $59,$39
db $52,$4F,$00,$01
db $5B,$39
db $52,$64,$00,$2D
db $0F,$39,$01,$39,$12,$39,$5D,$39,$08,$39,$01,$39,$07,$39,$14,$39,$6C,$39,$5F,$39,$65,$39,$61,$39,$77,$39,$0D,$39,$50,$39,$09,$39,$0D,$39,$3F,$39,$5D,$39,$14,$39,$07,$39,$0A,$39,$15,$39
.Line1End:
	db $FF
.Line2:
db $52,$84,$00,$01
db $5B,$39
db $52,$89,$00,$01
db $59,$39
db $52,$95,$00,$01
db $5B,$39
db $52,$96,$00,$01
db $59,$39
db $52,$A4,$00,$2D
db $79,$39,$5A,$39,$7B,$39,$16,$39,$1C,$39,$04,$39,$5D,$39,$11,$39,$20,$39,$58,$39,$57,$39,$10,$39,$01,$39,$56,$39,$5D,$39,$5F,$39,$65,$39,$61,$39,$09,$39,$84,$39,$02,$39,$14,$39,$1A,$39
.Line2End:
	db $FF
.Line3:
db $52,$C4,$00,$01
db $59,$39
db $52,$C5,$00,$01
db $59,$39
db $52,$C7,$00,$01
db $5B,$39
db $52,$D0,$00,$01
db $59,$39
db $52,$E4,$00,$2D
db $17,$39,$09,$39,$12,$39,$79,$39,$5A,$39,$7B,$39,$16,$39,$1C,$39,$77,$39,$0D,$39,$0A,$39,$06,$39,$0D,$39,$09,$39,$5D,$39,$07,$39,$14,$39,$51,$39,$84,$39,$02,$39,$55,$39,$EF,$39,$02,$39
.Line3End:
	db $FF
.Line4:
db $53,$06,$00,$01
db $59,$39
db $53,$0F,$00,$01
db $59,$39
db $53,$13,$00,$01
db $59,$39
db $53,$14,$00,$01
db $59,$39
db $53,$24,$00,$2B
db $63,$39,$4C,$39,$64,$39,$12,$39,$18,$39,$01,$39,$58,$39,$77,$39,$11,$39,$55,$39,$1D,$39,$11,$39,$0A,$39,$07,$39,$11,$39,$04,$39,$10,$39,$51,$39,$56,$39,$14,$39,$04,$39,$3D,$39
.Line4End:
	db $FF
else
			;                        |                        |                        |                        |                        |                        |                        |                        ;
;%InsertCastleDestructionText("Mario  has  defeated the demented  Iggy Koopa  in castle  #1  and  rescued Yoshi's  friend  who  is still trapped in an egg. Together,    they    now travel to Donut Land.")
			;                        |                        |                        |                        |                        |                        |                        |                        ;
;%InsertCastleDestructionText("Morton   Koopa   Jr.  of castle  #2 is now just a memory. The next area is the  underground Vanilla Dome.   What traps await Mario in this new world? What   will   become  of  Princess Toadstool?")
			;                        |                        |                        |                        |                        |                        |                        |                        ;
;%InsertCastleDestructionText("Mario has triumphed over Lemmy  Koopa  of  castle #3.  Mario's  quest   is starting  to  get   much more difficult.     Have you  found  the Red  and Green Switches yet?")
			;                        |                        |                        |                        |                        |                        |                        |                        ;
;%InsertCastleDestructionText("Ludwig von  Koopa's days of    composing    Koopa symphonies in castle  #4 are over.  The Forest of Illusion   lies   ahead. Mario must use his brain to solve  the puzzle  of this perplexing forest.")
			;                        |                        |                        |                        |                        |                        |                        |                        ;
;%InsertCastleDestructionText("Mario   found   his  way through  the  Forest  of Illusion and  has put an end  to   Roy  Koopa  of castle  #5.   Onward  to the    dangerous    (but tasty) Chocolate Island!")
			;                        |                        |                        |                        |                        |                        |                        |                        ;
;%InsertCastleDestructionText("Wendy O. Koopa in castle #6  has  sung  her  last song.  Mario  must  meet the  challenge  that  is now before him.    There is a  sunken  ship  that appears to be  a gateway to the Valley of Bowser.")
			;                        |                        |                        |                        |                        |                        |                        |                        ;
;%InsertCastleDestructionText("Mario has defeated Larry Koopa in castle #7.  All that is left is Bowser's Castle  where   Princess Toadstool is being held. Can Mario rescue her and restore     peace     to Dinosaur Land?")
			;                        |                        |                        |                        |                        |                        |                        |                        ;

Iggy:
	%StripeImageHeader(.Line1, $04, $13, 0, $0000, 3)
	;dw "Mario  has  defeated the"
db $0C,$39,$40,$39,$51,$39,$48,$39,$4E,$39,$1F,$39,$1F,$39,$47,$39,$40,$39,$52,$39,$1F,$39,$1F,$39,$43,$39,$44,$39,$45,$39,$44,$39,$40,$39,$53,$39,$44,$39,$43,$39,$1F,$39,$53,$39,$47,$39,$44,$39
.Line1End:
	db $FF
	%StripeImageHeader(.Line2, $04, $14, 0, $0000, 3)
	;dw "demented  Iggy Koopa  in" 
db $43,$39,$44,$39,$4C,$39,$44,$39,$4D,$39,$53,$39,$44,$39,$43,$39,$1F,$39,$1F,$39,$08,$39,$46,$39,$46,$39,$58,$39,$1F,$39,$0A,$39,$4E,$39,$4E,$39,$4F,$39,$40,$39,$1F,$39,$1F,$39,$48,$39,$4D,$39
.Line2End:
	db $FF
	%StripeImageHeader(.Line3, $04, $15, 0, $0000, 3)
	;dw "castle  #1  and  rescued"
db $42,$39,$40,$39,$52,$39,$53,$39,$4B,$39,$44,$39,$1F,$39,$1F,$39,$5A,$39,$64,$39,$1F,$39,$1F,$39,$40,$39,$4D,$39,$43,$39,$1F,$39,$1F,$39,$51,$39,$44,$39,$52,$39,$42,$39,$54,$39,$44,$39,$43,$39
.Line3End:
	db $FF
	%StripeImageHeader(.Line4, $04, $16, 0, $0000, 3)
	;dw "Yoshi's  friend  who  is"
db $18,$39,$4E,$39,$52,$39,$47,$39,$48,$39,$5D,$39,$52,$39,$1F,$39,$1F,$39,$45,$39,$51,$39,$48,$39,$44,$39,$4D,$39,$43,$39,$1F,$39,$1F,$39,$56,$39,$47,$39,$4E,$39,$1F,$39,$1F,$39,$48,$39,$52,$39
.Line4End:
	db $FF
	%StripeImageHeader(.Line5, $04, $17, 0, $0000, 3)
	;dw "still trapped in an egg."
db $52,$39,$53,$39,$48,$39,$4B,$39,$4B,$39,$1F,$39,$53,$39,$51,$39,$40,$39,$4F,$39,$4F,$39,$44,$39,$43,$39,$1F,$39,$48,$39,$4D,$39,$1F,$39,$40,$39,$4D,$39,$1F,$39,$44,$39,$46,$39,$46,$39,$1B,$39
.Line5End:
	db $FF
	%StripeImageHeader(.Line6, $04, $18, 0, $0000, 3)
	;dw "Together,    they    now"
db $13,$39,$4E,$39,$46,$39,$44,$39,$53,$39,$47,$39,$44,$39,$51,$39,$1D,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$53,$39,$47,$39,$44,$39,$58,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$4D,$39,$4E,$39,$56,$39
.Line6End:
	db $FF
	%StripeImageHeader(.Line7, $04, $19, 0, $0000, 3)
	;dw "travel to Donut Land."
db $53,$39,$51,$39,$40,$39,$55,$39,$44,$39,$4B,$39,$1F,$39,$53,$39,$4E,$39,$1F,$39,$03,$39,$4E,$39,$4D,$39,$54,$39,$53,$39,$1F,$39,$0B,$39,$40,$39,$4D,$39,$43,$39,$1B,$39
.Line7End:
BlankLine:
	db $FF				;!

Morton:
	%StripeImageHeader(.Line1, $04, $13, 0, $0000, 3)
	;dw "Morton   Koopa   Jr.  of"
db $0C,$39,$4E,$39,$51,$39,$53,$39,$4E,$39,$4D,$39,$1F,$39,$1F,$39,$1F,$39,$0A,$39,$4E,$39,$4E,$39,$4F,$39,$40,$39,$1F,$39,$1F,$39,$1F,$39,$09,$39,$51,$39,$1B,$39,$1F,$39,$1F,$39,$4E,$39,$45,$39
.Line1End:
	db $FF
	%StripeImageHeader(.Line2, $04, $14, 0, $0000, 3)
	;dw "castle  #2 is now just a" 
db $42,$39,$40,$39,$52,$39,$53,$39,$4B,$39,$44,$39,$1F,$39,$1F,$39,$5A,$39,$65,$39,$1F,$39,$48,$39,$52,$39,$1F,$39,$4D,$39,$4E,$39,$56,$39,$1F,$39,$49,$39,$54,$39,$52,$39,$53,$39,$1F,$39,$40,$39
.Line2End:
	db $FF
	%StripeImageHeader(.Line3, $04, $15, 0, $0000, 3)
	;dw "memory. The next area is"
db $4C,$39,$44,$39,$4C,$39,$4E,$39,$51,$39,$58,$39,$1B,$39,$1F,$39,$13,$39,$47,$39,$44,$39,$1F,$39,$4D,$39,$44,$39,$57,$39,$53,$39,$1F,$39,$40,$39,$51,$39,$44,$39,$40,$39,$1F,$39,$48,$39,$52,$39
.Line3End:
	db $FF
	%StripeImageHeader(.Line4, $04, $16, 0, $0000, 3)
	;dw "the  underground Vanilla"
db $53,$39,$47,$39,$44,$39,$1F,$39,$1F,$39,$54,$39,$4D,$39,$43,$39,$44,$39,$51,$39,$46,$39,$51,$39,$4E,$39,$54,$39,$4D,$39,$43,$39,$1F,$39,$15,$39,$40,$39,$4D,$39,$48,$39,$4B,$39,$4B,$39,$40,$39
.Line4End:
	db $FF
	%StripeImageHeader(.Line5, $04, $17, 0, $0000, 3)
	;dw "Dome.   What traps await"
db $03,$39,$4E,$39,$4C,$39,$44,$39,$1B,$39,$1F,$39,$1F,$39,$1F,$39,$16,$39,$47,$39,$40,$39,$53,$39,$1F,$39,$53,$39,$51,$39,$40,$39,$4F,$39,$52,$39,$1F,$39,$40,$39,$56,$39,$40,$39,$48,$39,$53,$39
.Line5End:
	db $FF
	%StripeImageHeader(.Line6, $04, $18, 0, $0000, 3)
	;dw "Mario in this new world?"
db $0C,$39,$40,$39,$51,$39,$48,$39,$4E,$39,$1F,$39,$48,$39,$4D,$39,$1F,$39,$53,$39,$47,$39,$48,$39,$52,$39,$1F,$39,$4D,$39,$44,$39,$56,$39,$1F,$39,$56,$39,$4E,$39,$51,$39,$4B,$39,$43,$39,$1E,$39
.Line6End:
	db $FF
	%StripeImageHeader(.Line7, $04, $19, 0, $0000, 3)
	;dw "What   will   become  of"
db $16,$39,$47,$39,$40,$39,$53,$39,$1F,$39,$1F,$39,$1F,$39,$56,$39,$48,$39,$4B,$39,$4B,$39,$1F,$39,$1F,$39,$1F,$39,$41,$39,$44,$39,$42,$39,$4E,$39,$4C,$39,$44,$39,$1F,$39,$1F,$39,$4E,$39,$45,$39
.Line7End:
	db $FF
	%StripeImageHeader(.Line8, $04, $1A, 0, $0000, 3)
	;dw "Princess Toadstool?"
db $0F,$39,$51,$39,$48,$39,$4D,$39,$42,$39,$44,$39,$52,$39,$52,$39,$1F,$39,$13,$39,$4E,$39,$40,$39,$43,$39,$52,$39,$53,$39,$4E,$39,$4E,$39,$4B,$39,$1E,$39
.Line8End:
	db $FF

Lemmy:
	%StripeImageHeader(.Line1, $04, $13, 0, $0000, 3)
	;dw "Mario has triumphed over"
db $0C,$39,$40,$39,$51,$39,$48,$39,$4E,$39,$1F,$39,$47,$39,$40,$39,$52,$39,$1F,$39,$53,$39,$51,$39,$48,$39,$54,$39,$4C,$39,$4F,$39,$47,$39,$44,$39,$43,$39,$1F,$39,$4E,$39,$55,$39,$44,$39,$51,$39
.Line1End:
	db $FF
	%StripeImageHeader(.Line2, $04, $14, 0, $0000, 3)
	;dw "Lemmy  Koopa  of  castle" 
db $0B,$39,$44,$39,$4C,$39,$4C,$39,$58,$39,$1F,$39,$1F,$39,$0A,$39,$4E,$39,$4E,$39,$4F,$39,$40,$39,$1F,$39,$1F,$39,$4E,$39,$45,$39,$1F,$39,$1F,$39,$42,$39,$40,$39,$52,$39,$53,$39,$4B,$39,$44,$39
.Line2End:
	db $FF
	%StripeImageHeader(.Line3, $04, $15, 0, $0000, 3)
	;dw "#3.  Mario's  quest   is"
db $5A,$39,$66,$39,$1B,$39,$1F,$39,$1F,$39,$0C,$39,$40,$39,$51,$39,$48,$39,$4E,$39,$5D,$39,$52,$39,$1F,$39,$1F,$39,$50,$39,$54,$39,$44,$39,$52,$39,$53,$39,$1F,$39,$1F,$39,$1F,$39,$48,$39,$52,$39
.Line3End:
	db $FF
	%StripeImageHeader(.Line4, $04, $16, 0, $0000, 3)
	;dw "starting  to  get   much"
db $52,$39,$53,$39,$40,$39,$51,$39,$53,$39,$48,$39,$4D,$39,$46,$39,$1F,$39,$1F,$39,$53,$39,$4E,$39,$1F,$39,$1F,$39,$46,$39,$44,$39,$53,$39,$1F,$39,$1F,$39,$1F,$39,$4C,$39,$54,$39,$42,$39,$47,$39
.Line4End:
	db $FF
	%StripeImageHeader(.Line5, $04, $17, 0, $0000, 3)
	;dw "more difficult.     Have"
db $4C,$39,$4E,$39,$51,$39,$44,$39,$1F,$39,$43,$39,$48,$39,$45,$39,$45,$39,$48,$39,$42,$39,$54,$39,$4B,$39,$53,$39,$1B,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$07,$39,$40,$39,$55,$39,$44,$39
.Line5End:
	db $FF
	%StripeImageHeader(.Line6, $04, $18, 0, $0000, 3)
	;dw "you  found  the Red  and"
db $58,$39,$4E,$39,$54,$39,$1F,$39,$1F,$39,$45,$39,$4E,$39,$54,$39,$4D,$39,$43,$39,$1F,$39,$1F,$39,$53,$39,$47,$39,$44,$39,$1F,$39,$11,$39,$44,$39,$43,$39,$1F,$39,$1F,$39,$40,$39,$4D,$39,$43,$39
.Line6End:
	db $FF
	%StripeImageHeader(.Line7, $04, $19, 0, $0000, 3)
	;dw "Green Switches yet?"
db $06,$39,$51,$39,$44,$39,$44,$39,$4D,$39,$1F,$39,$12,$39,$56,$39,$48,$39,$53,$39,$42,$39,$47,$39,$44,$39,$52,$39,$1F,$39,$58,$39,$44,$39,$53,$39,$1E,$39
.Line7End:
	db $FF

Ludwig:
	%StripeImageHeader(.Line1, $04, $13, 0, $0000, 3)
	;dw "Ludwig von  Koopa's days"
db $0B,$39,$54,$39,$43,$39,$56,$39,$48,$39,$46,$39,$1F,$39,$55,$39,$4E,$39,$4D,$39,$1F,$39,$1F,$39,$0A,$39,$4E,$39,$4E,$39,$4F,$39,$40,$39,$5D,$39,$52,$39,$1F,$39,$43,$39,$40,$39,$58,$39,$52,$39
.Line1End:
	db $FF
	%StripeImageHeader(.Line2, $04, $14, 0, $0000, 3)
	;dw "of    composing    Koopa" 
db $4E,$39,$45,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$42,$39,$4E,$39,$4C,$39,$4F,$39,$4E,$39,$52,$39,$48,$39,$4D,$39,$46,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$0A,$39,$4E,$39,$4E,$39,$4F,$39,$40,$39
.Line2End:
	db $FF
	%StripeImageHeader(.Line3, $04, $15, 0, $0000, 3)
	;dw "symphonies in castle  #4"
db $52,$39,$58,$39,$4C,$39,$4F,$39,$47,$39,$4E,$39,$4D,$39,$48,$39,$44,$39,$52,$39,$1F,$39,$48,$39,$4D,$39,$1F,$39,$42,$39,$40,$39,$52,$39,$53,$39,$4B,$39,$44,$39,$1F,$39,$1F,$39,$5A,$39,$67,$39
.Line3End:
	db $FF
	%StripeImageHeader(.Line4, $04, $16, 0, $0000, 3)
	;dw "are over.  The Forest of"
db $40,$39,$51,$39,$44,$39,$1F,$39,$4E,$39,$55,$39,$44,$39,$51,$39,$1B,$39,$1F,$39,$1F,$39,$13,$39,$47,$39,$44,$39,$1F,$39,$05,$39,$4E,$39,$51,$39,$44,$39,$52,$39,$53,$39,$1F,$39,$4E,$39,$45,$39
.Line4End:
	db $FF
	%StripeImageHeader(.Line5, $04, $17, 0, $0000, 3)
	;dw "Illusion   lies   ahead."
db $08,$39,$4B,$39,$4B,$39,$54,$39,$52,$39,$48,$39,$4E,$39,$4D,$39,$1F,$39,$1F,$39,$1F,$39,$4B,$39,$48,$39,$44,$39,$52,$39,$1F,$39,$1F,$39,$1F,$39,$40,$39,$47,$39,$44,$39,$40,$39,$43,$39,$1B,$39
.Line5End:
	db $FF
	%StripeImageHeader(.Line6, $04, $18, 0, $0000, 3)
	;dw "Mario must use his brain"
db $0C,$39,$40,$39,$51,$39,$48,$39,$4E,$39,$1F,$39,$4C,$39,$54,$39,$52,$39,$53,$39,$1F,$39,$54,$39,$52,$39,$44,$39,$1F,$39,$47,$39,$48,$39,$52,$39,$1F,$39,$41,$39,$51,$39,$40,$39,$48,$39,$4D,$39
.Line6End:
	db $FF
	%StripeImageHeader(.Line7, $04, $19, 0, $0000, 3)
	;dw "to solve  the puzzle  of"
db $53,$39,$4E,$39,$1F,$39,$52,$39,$4E,$39,$4B,$39,$55,$39,$44,$39,$1F,$39,$1F,$39,$53,$39,$47,$39,$44,$39,$1F,$39,$4F,$39,$54,$39,$59,$39,$59,$39,$4B,$39,$44,$39,$1F,$39,$1F,$39,$4E,$39,$45,$39
.Line7End:
	db $FF
	%StripeImageHeader(.Line8, $04, $1A, 0, $0000, 3)
	;dw "this perplexing forest."
db $53,$39,$47,$39,$48,$39,$52,$39,$1F,$39,$4F,$39,$44,$39,$51,$39,$4F,$39,$4B,$39,$44,$39,$57,$39,$48,$39,$4D,$39,$46,$39,$1F,$39,$45,$39,$4E,$39,$51,$39,$44,$39,$52,$39,$53,$39,$1B,$39
.Line8End:
	db $FF

Roy:
	%StripeImageHeader(.Line1, $04, $13, 0, $0000, 3)
	;dw "Mario   found   his  way"
db $0C,$39,$40,$39,$51,$39,$48,$39,$4E,$39,$1F,$39,$1F,$39,$1F,$39,$45,$39,$4E,$39,$54,$39,$4D,$39,$43,$39,$1F,$39,$1F,$39,$1F,$39,$47,$39,$48,$39,$52,$39,$1F,$39,$1F,$39,$56,$39,$40,$39,$58,$39
.Line1End:
	db $FF
	%StripeImageHeader(.Line2, $04, $14, 0, $0000, 3)
	;dw "through  the  Forest  of" 
db $53,$39,$47,$39,$51,$39,$4E,$39,$54,$39,$46,$39,$47,$39,$1F,$39,$1F,$39,$53,$39,$47,$39,$44,$39,$1F,$39,$1F,$39,$05,$39,$4E,$39,$51,$39,$44,$39,$52,$39,$53,$39,$1F,$39,$1F,$39,$4E,$39,$45,$39
.Line2End:
	db $FF
	%StripeImageHeader(.Line3, $04, $15, 0, $0000, 3)
	;dw "Illusion and  has put an"
db $08,$39,$4B,$39,$4B,$39,$54,$39,$52,$39,$48,$39,$4E,$39,$4D,$39,$1F,$39,$40,$39,$4D,$39,$43,$39,$1F,$39,$1F,$39,$47,$39,$40,$39,$52,$39,$1F,$39,$4F,$39,$54,$39,$53,$39,$1F,$39,$40,$39,$4D,$39
.Line3End:
	db $FF
	%StripeImageHeader(.Line4, $04, $16, 0, $0000, 3)
	;dw "end  to   Roy  Koopa  of"
db $44,$39,$4D,$39,$43,$39,$1F,$39,$1F,$39,$53,$39,$4E,$39,$1F,$39,$1F,$39,$1F,$39,$11,$39,$4E,$39,$58,$39,$1F,$39,$1F,$39,$0A,$39,$4E,$39,$4E,$39,$4F,$39,$40,$39,$1F,$39,$1F,$39,$4E,$39,$45,$39
.Line4End:
	db $FF
	%StripeImageHeader(.Line5, $04, $17, 0, $0000, 3)
	;dw "castle  #5.   Onward  to"
db $42,$39,$40,$39,$52,$39,$53,$39,$4B,$39,$44,$39,$1F,$39,$1F,$39,$5A,$39,$68,$39,$1B,$39,$1F,$39,$1F,$39,$1F,$39,$0E,$39,$4D,$39,$56,$39,$40,$39,$51,$39,$43,$39,$1F,$39,$1F,$39,$53,$39,$4E,$39
.Line5End:
	db $FF
	%StripeImageHeader(.Line6, $04, $18, 0, $0000, 3)
	;dw "the    dangerous    (but"
db $53,$39,$47,$39,$44,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$43,$39,$40,$39,$4D,$39,$46,$39,$44,$39,$51,$39,$4E,$39,$54,$39,$52,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$5B,$39,$41,$39,$54,$39,$53,$39
.Line6End:
	db $FF
	%StripeImageHeader(.Line7, $04, $19, 0, $0000, 3)
	;dw "tasty) Chocolate Island!"
db $53,$39,$40,$39,$52,$39,$53,$39,$58,$39,$5C,$39,$1F,$39,$02,$39,$47,$39,$4E,$39,$42,$39,$4E,$39,$4B,$39,$40,$39,$53,$39,$44,$39,$1F,$39,$08,$39,$52,$39,$4B,$39,$40,$39,$4D,$39,$43,$39,$1A,$39
.Line7End:
	db $FF

Wendy:
	%StripeImageHeader(.Line1, $04, $13, 0, $0000, 3)
	;dw "Wendy O. Koopa in castle"
db $16,$39,$44,$39,$4D,$39,$43,$39,$58,$39,$1F,$39,$0E,$39,$1B,$39,$1F,$39,$0A,$39,$4E,$39,$4E,$39,$4F,$39,$40,$39,$1F,$39,$48,$39,$4D,$39,$1F,$39,$42,$39,$40,$39,$52,$39,$53,$39,$4B,$39,$44,$39
.Line1End:
	db $FF
	%StripeImageHeader(.Line2, $04, $14, 0, $0000, 3)
	;dw "#6  has  sung  her  last" 
db $5A,$39,$69,$39,$1F,$39,$1F,$39,$47,$39,$40,$39,$52,$39,$1F,$39,$1F,$39,$52,$39,$54,$39,$4D,$39,$46,$39,$1F,$39,$1F,$39,$47,$39,$44,$39,$51,$39,$1F,$39,$1F,$39,$4B,$39,$40,$39,$52,$39,$53,$39
.Line2End:
	db $FF
	%StripeImageHeader(.Line3, $04, $15, 0, $0000, 3)
	;dw "song.  Mario  must  meet"
db $52,$39,$4E,$39,$4D,$39,$46,$39,$1B,$39,$1F,$39,$1F,$39,$0C,$39,$40,$39,$51,$39,$48,$39,$4E,$39,$1F,$39,$1F,$39,$4C,$39,$54,$39,$52,$39,$53,$39,$1F,$39,$1F,$39,$4C,$39,$44,$39,$44,$39,$53,$39
.Line3End:
	db $FF
	%StripeImageHeader(.Line4, $04, $16, 0, $0000, 3)
	;dw "the  challenge  that  is"
db $53,$39,$47,$39,$44,$39,$1F,$39,$1F,$39,$42,$39,$47,$39,$40,$39,$4B,$39,$4B,$39,$44,$39,$4D,$39,$46,$39,$44,$39,$1F,$39,$1F,$39,$53,$39,$47,$39,$40,$39,$53,$39,$1F,$39,$1F,$39,$48,$39,$52,$39
.Line4End:
	db $FF
	%StripeImageHeader(.Line5, $04, $17, 0, $0000, 3)
	;dw "now before him.    There"
db $4D,$39,$4E,$39,$56,$39,$1F,$39,$41,$39,$44,$39,$45,$39,$4E,$39,$51,$39,$44,$39,$1F,$39,$47,$39,$48,$39,$4C,$39,$1B,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$13,$39,$47,$39,$44,$39,$51,$39,$44,$39
.Line5End:
	db $FF
	%StripeImageHeader(.Line6, $04, $18, 0, $0000, 3)
	;dw "is a  sunken  ship  that"
db $48,$39,$52,$39,$1F,$39,$40,$39,$1F,$39,$1F,$39,$52,$39,$54,$39,$4D,$39,$4A,$39,$44,$39,$4D,$39,$1F,$39,$1F,$39,$52,$39,$47,$39,$48,$39,$4F,$39,$1F,$39,$1F,$39,$53,$39,$47,$39,$40,$39,$53,$39
.Line6End:
	db $FF
	%StripeImageHeader(.Line7, $04, $19, 0, $0000, 3)
	;dw "appears to be  a gateway"
db $40,$39,$4F,$39,$4F,$39,$44,$39,$40,$39,$51,$39,$52,$39,$1F,$39,$53,$39,$4E,$39,$1F,$39,$41,$39,$44,$39,$1F,$39,$1F,$39,$40,$39,$1F,$39,$46,$39,$40,$39,$53,$39,$44,$39,$56,$39,$40,$39,$58,$39
.Line7End:
	db $FF
	%StripeImageHeader(.Line8, $04, $1A, 0, $0000, 3)
	;dw "to the Valley of Bowser."
db $53,$39,$4E,$39,$1F,$39,$53,$39,$47,$39,$44,$39,$1F,$39,$15,$39,$40,$39,$4B,$39,$4B,$39,$44,$39,$58,$39,$1F,$39,$4E,$39,$45,$39,$1F,$39,$01,$39,$4E,$39,$56,$39,$52,$39,$44,$39,$51,$39,$1B,$39
.Line8End:
	db $FF

Larry:
	%StripeImageHeader(.Line1, $04, $13, 0, $0000, 3)
	;dw "Mario has defeated Larry"
db $0C,$39,$40,$39,$51,$39,$48,$39,$4E,$39,$1F,$39,$47,$39,$40,$39,$52,$39,$1F,$39,$43,$39,$44,$39,$45,$39,$44,$39,$40,$39,$53,$39,$44,$39,$43,$39,$1F,$39,$0B,$39,$40,$39,$51,$39,$51,$39,$58,$39
.Line1End:
	db $FF
	%StripeImageHeader(.Line2, $04, $14, 0, $0000, 3)
	;dw "Koopa in castle #7.  All"
db $0A,$39,$4E,$39,$4E,$39,$4F,$39,$40,$39,$1F,$39,$48,$39,$4D,$39,$1F,$39,$42,$39,$40,$39,$52,$39,$53,$39,$4B,$39,$44,$39,$1F,$39,$5A,$39,$6A,$39,$1B,$39,$1F,$39,$1F,$39,$00,$39,$4B,$39,$4B,$39
.Line2End:
	db $FF
	%StripeImageHeader(.Line3, $04, $15, 0, $0000, 3)
	;dw "that is left is Bowser's"
db $53,$39,$47,$39,$40,$39,$53,$39,$1F,$39,$48,$39,$52,$39,$1F,$39,$4B,$39,$44,$39,$45,$39,$53,$39,$1F,$39,$48,$39,$52,$39,$1F,$39,$01,$39,$4E,$39,$56,$39,$52,$39,$44,$39,$51,$39,$5D,$39,$52,$39
.Line3End:
	db $FF
	%StripeImageHeader(.Line4, $04, $16, 0, $0000, 3)
	;dw "Castle  where   Princess"
db $02,$39,$40,$39,$52,$39,$53,$39,$4B,$39,$44,$39,$1F,$39,$1F,$39,$56,$39,$47,$39,$44,$39,$51,$39,$44,$39,$1F,$39,$1F,$39,$1F,$39,$0F,$39,$51,$39,$48,$39,$4D,$39,$42,$39,$44,$39,$52,$39,$52,$39
.Line4End:
	db $FF
	%StripeImageHeader(.Line5, $04, $17, 0, $0000, 3)
	;dw "Toadstool is being held."
db $13,$39,$4E,$39,$40,$39,$43,$39,$52,$39,$53,$39,$4E,$39,$4E,$39,$4B,$39,$1F,$39,$48,$39,$52,$39,$1F,$39,$41,$39,$44,$39,$48,$39,$4D,$39,$46,$39,$1F,$39,$47,$39,$44,$39,$4B,$39,$43,$39,$1B,$39
.Line5End:
	db $FF
	%StripeImageHeader(.Line6, $04, $18, 0, $0000, 3)
	;dw "Can Mario rescue her and"
db $02,$39,$40,$39,$4D,$39,$1F,$39,$0C,$39,$40,$39,$51,$39,$48,$39,$4E,$39,$1F,$39,$51,$39,$44,$39,$52,$39,$42,$39,$54,$39,$44,$39,$1F,$39,$47,$39,$44,$39,$51,$39,$1F,$39,$40,$39,$4D,$39,$43,$39
.Line6End:
	db $FF
	%StripeImageHeader(.Line7, $04, $19, 0, $0000, 3)
	;dw "restore     peace     to"
db $51,$39,$44,$39,$52,$39,$53,$39,$4E,$39,$51,$39,$44,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$4F,$39,$44,$39,$40,$39,$42,$39,$44,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$1F,$39,$53,$39,$4E,$39
.Line7End:
	db $FF
	%StripeImageHeader(.Line8, $04, $1A, 0, $0000, 3)
	;dw "Dinosaur Land?"
db $03,$39,$48,$39,$4D,$39,$4E,$39,$52,$39,$40,$39,$54,$39,$51,$39,$1F,$39,$0B,$39,$40,$39,$4D,$39,$43,$39,$1E,$39
.Line8End:
	db $FF				;!
endif
cleartable
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_TheEndScreenText(Address)
namespace SMW_TheEndScreenText
%InsertMacroAtXPosition(<Address>)

cleartable
Main:
	%StripeImageHeader(TopHalf, $0A, $07, 0, $0000, 3)
	;dw "T H E  E N D"
; The End text data, (with Mario, Peach and Luigi.)
db $E3,$20,$FC,$20,$C7,$20,$FC,$20,$C4,$20,$FC,$20,$FC,$20,$C4,$20,$FC,$20,$CD,$20,$FC,$20,$C3,$20
TopHalfEnd:
	%StripeImageHeader(BottomHalf, $0A, $08, 0, $0000, 3)
	;dw "T H E  E N D"
db $F3,$20,$FC,$20,$D7,$20,$FC,$20,$D4,$20,$FC,$20,$FC,$20,$D4,$20,$FC,$20,$DD,$20,$FC,$20,$D3,$20
BottomHalfEnd:
	db $FF
cleartable
namespace off
endmacro

macro INLINEDATATABLE_RT35_SMW_EmptySpace(Address)
!SMW_UBytes = $16 : !SMW_JBytes = $16 : !SMW_E1Bytes = $16 : !SMW_E2Bytes = $16 : !SMASW_UBytes = $16 : !SMASW_EBytes = $16 : !SMW_ARCADEBytes = $16
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 35)
endmacro

macro INLINEDATATABLE_RT36_SMW_EmptySpace(Address)
!SMW_UBytes = $0191 : !SMW_JBytes = $0638 : !SMW_E1Bytes = $0191 : !SMW_E2Bytes = $017F : !SMASW_UBytes = $018E : !SMASW_EBytes = $017C : !SMW_ARCADEBytes = $0191
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 36)
endmacro

macro INLINEDATATABLE_RT37_SMW_EmptySpace(Address)
!SMW_UBytes = $91 : !SMW_JBytes = $13 : !SMW_E1Bytes = $91 : !SMW_E2Bytes = $91 : !SMASW_UBytes = $91 : !SMASW_EBytes = $91 : !SMW_ARCADEBytes = $6A
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 37)
endmacro

macro INLINEDATATABLE_RT38_SMW_EmptySpace(Address)
!SMW_UBytes = $21 : !SMW_JBytes = $21 : !SMW_E1Bytes = $21 : !SMW_E2Bytes = $21 : !SMASW_UBytes = $21 : !SMASW_EBytes = $21 : !SMW_ARCADEBytes = $21
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 38)
endmacro
