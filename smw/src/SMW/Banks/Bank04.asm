;####################################################################
;# Bank04.asm -- level object rendering.
;#
;# 110 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank04Macros(StartBank, EndBank)
%BANK_START(<StartBank>)
ROUTINE_SMW_OverworldTileAnimations:	%ROUTINE_SMW_OverworldTileAnimations(NULLROM)					; $048000
ROUTINE_RT01_SMW_GameMode0E_ShowOverworld:	%ROUTINE_RT01_SMW_GameMode0E_ShowOverworld(NULLROM)				; $04819F
DATATABLE_SMW_HandleOverworldStarPipeWarp:	%DATATABLE_SMW_HandleOverworldStarPipeWarp(NULLROM)			; $048431
ROUTINE_SMW_HandleOverworldStarPipeWarp:	%ROUTINE_SMW_HandleOverworldStarPipeWarp(NULLROM)				; $048509
ROUTINE_SMW_HandleCurrentOverworldProcess:	%ROUTINE_SMW_HandleCurrentOverworldProcess(NULLROM)				; $048576
ROUTINE_SMW_DrawOverworldBorderPlayer:	%ROUTINE_SMW_DrawOverworldBorderPlayer(NULLROM)				; $0485A4
ROUTINE_SMW_DrawOverworldPlayer:	%ROUTINE_SMW_DrawOverworldPlayer(NULLROM)					; $04862E
ROUTINE_RT01_SMW_GameMode0C_LoadOverworld:	%ROUTINE_RT01_SMW_GameMode0C_LoadOverworld(NULLROM)				; $048D74
ROUTINE_SMW_OverworldProcess00_OverworldEntryInitialization:	%ROUTINE_SMW_OverworldProcess00_OverworldEntryInitialization(NULLROM)		; $048EF1
ROUTINE_SMW_OverworldProcess02_HandleLevelBeaten:	%ROUTINE_SMW_OverworldProcess02_HandleLevelBeaten(NULLROM)			; $048F7F
ROUTINE_SMW_UpdateSaveBuffer:	%ROUTINE_SMW_UpdateSaveBuffer(NULLROM)						; $049037
DATATABLE_RT00_SMW_SharedOverworldPathTables:	%DATATABLE_RT00_SMW_SharedOverworldPathTables(NULLROM)				; $049058
ROUTINE_SMW_OverworldProcess03_StandingStill:	%ROUTINE_SMW_OverworldProcess03_StandingStill(NULLROM)				; $049120
ROUTINE_RT01_SMW_OverworldProcess04_PlayerIsMoving:	%ROUTINE_RT01_SMW_OverworldProcess04_PlayerIsMoving(NULLROM)			; $049414
DATATABLE_RT01_SMW_BitTable:	%DATATABLE_RT01_SMW_BitTable(NULLROM)						; $04941E
ROUTINE_RT00_SMW_OverworldProcess04_PlayerIsMoving:	%ROUTINE_RT00_SMW_OverworldProcess04_PlayerIsMoving(NULLROM)			; $049426
ROUTINE_SMW_CalculateOverworldPlayerPosition:	%ROUTINE_SMW_CalculateOverworldPlayerPosition(NULLROM)				; $049885
ROUTINE_SMW_OverworldProcess0C_IntroMarch:	%ROUTINE_SMW_OverworldProcess0C_IntroMarch(NULLROM)				; $0498C6
ROUTINE_SMW_UnlockOverworldPathBasedOnExit:	%ROUTINE_SMW_UnlockOverworldPathBasedOnExit(NULLROM)				; $0498FB
DATATABLE_SMW_HandleOverworldPathExits:	%DATATABLE_SMW_HandleOverworldPathExits(NULLROM)				; $049964
ROUTINE_SMW_HandleOverworldPathExits:	%ROUTINE_SMW_HandleOverworldPathExits(NULLROM)					; $049A0C
DATATABLE_SMW_UpdateLevelName:	%DATATABLE_SMW_UpdateLevelName(NULLROM)					; $049AC5
ROUTINE_SMW_UpdateLevelName:	%ROUTINE_SMW_UpdateLevelName(NULLROM)						; $049D07
ROUTINE_SMW_OverworldProcess05_CheckForPlayerSwitch:	%ROUTINE_SMW_OverworldProcess05_CheckForPlayerSwitch(NULLROM)			; $049D9A
ROUTINE_SMW_OverworldProcess07_SwitchingPlayers:	%ROUTINE_SMW_OverworldProcess07_SwitchingPlayers(NULLROM)			; $049DD1
ROUTINE_SMW_OverworldProcess06_PlayerSwitchFadeOut:	%ROUTINE_SMW_OverworldProcess06_PlayerSwitchFadeOut(NULLROM)			; $049E22
ROUTINE_SMW_OverworldProcess09_FinishedSwitchingPlayers:	%ROUTINE_SMW_OverworldProcess09_FinishedSwitchingPlayers(NULLROM)		; $049E4C
ROUTINE_SMW_OverworldProcess0B_StarWarpAnimation:	%ROUTINE_SMW_OverworldProcess0B_StarWarpAnimation(NULLROM)			; $049E52
ROUTINE_RT01_SMW_HexToDec:	%ROUTINE_RT01_SMW_HexToDec(NULLROM)						; $049E9B
DATATABLE_RT01_SMW_SharedOverworldPathTables:	%DATATABLE_RT01_SMW_SharedOverworldPathTables(NULLROM)				; $049EA7
DATATABLE_SMW_LevelNames:	%DATATABLE_SMW_LevelNames(NULLROM)						; $04A0FC
INLINEDATATABLE_RT16_SMW_EmptySpace:	%INLINEDATATABLE_RT16_SMW_EmptySpace(NULLROM)					; $04A1B6
ROUTINE_RT02_SMW_GameMode0C_LoadOverworld:	%ROUTINE_RT02_SMW_GameMode0C_LoadOverworld(NULLROM)				; $04A400
ROUTINE_RT01_SMW_LoadOverworldLayer2AndEventsTilemaps:	%ROUTINE_RT01_SMW_LoadOverworldLayer2AndEventsTilemaps(NULLROM)		; $04A533
ROUTINE_RT01_SMW_LoadOverworldLayer1AndEvents:	%ROUTINE_RT01_SMW_LoadOverworldLayer1AndEvents(NULLROM)			; $04D678
ROUTINE_RT00_SMW_InitializeOverworldTilemaps:	%ROUTINE_RT00_SMW_InitializeOverworldTilemaps(NULLROM)				; $04D6E9
ROUTINE_RT02_SMW_LoadOverworldLayer1AndEvents:	%ROUTINE_RT02_SMW_LoadOverworldLayer1AndEvents(NULLROM)			; $04D770
DATATABLE_RT00_SMW_ChangingLayer1OverworldTiles:	%DATATABLE_RT00_SMW_ChangingLayer1OverworldTiles(NULLROM)			; $04D85D
ROUTINE_RT01_SMW_OverworldEventProcess01_DestroyTileAnimation:	%ROUTINE_RT01_SMW_OverworldEventProcess01_DestroyTileAnimation(NULLROM)	; $04D93D
DATATABLE_RT01_SMW_ChangingLayer1OverworldTiles:	%DATATABLE_RT01_SMW_ChangingLayer1OverworldTiles(NULLROM)			; $04DA1D
ROUTINE_RT03_SMW_LoadOverworldLayer1AndEvents:	%ROUTINE_RT03_SMW_LoadOverworldLayer1AndEvents(NULLROM)			; $04DA49
ROUTINE_RT00_SMW_LoadOverworldLayer2AndEventsTilemaps:	%ROUTINE_RT00_SMW_LoadOverworldLayer2AndEventsTilemaps(NULLROM)		; $04DAAD
ROUTINE_RT01_SMW_InitializeOverworldTilemaps:	%ROUTINE_RT01_SMW_InitializeOverworldTilemaps(NULLROM)				; $04DAB3
ROUTINE_SMW_BufferOverworldLayer2Tilemap:	%ROUTINE_SMW_BufferOverworldLayer2Tilemap(NULLROM)				; $04DABA
ROUTINE_SMW_OverworldProcess0A_SwitchBetweenSubmaps:	%ROUTINE_SMW_OverworldProcess0A_SwitchBetweenSubmaps(NULLROM)			; $04DAEF
ROUTINE_SMW_SubmapSwitchProcess00_InitializeWindowHDMA:	%ROUTINE_SMW_SubmapSwitchProcess00_InitializeWindowHDMA(NULLROM)		; $04DB08
ROUTINE_SMW_SubmapSwitchProcess05_UpdatePalette:	%ROUTINE_SMW_SubmapSwitchProcess05_UpdatePalette(NULLROM)			; $04DB9D
ROUTINE_SMW_SubmapSwitchProcess07_EndSubmapSwitch:	%ROUTINE_SMW_SubmapSwitchProcess07_EndSubmapSwitch(NULLROM)			; $04DBC8
ROUTINE_RT00_SMW_LoadOverworldLayer1AndEvents:	%ROUTINE_RT00_SMW_LoadOverworldLayer1AndEvents(NULLROM)			; $04DC02
ROUTINE_RT02_SMW_LoadOverworldLayer2AndEventsTilemaps:	%ROUTINE_RT02_SMW_LoadOverworldLayer2AndEventsTilemaps(NULLROM)		; $04DC6A
ROUTINE_SMW_SubmapSwitchProcess01_UpdateLayer1:	%ROUTINE_SMW_SubmapSwitchProcess01_UpdateLayer1(NULLROM)			; $04DCAE
ROUTINE_RT03_SMW_LoadOverworldLayer2AndEventsTilemaps:	%ROUTINE_RT03_SMW_LoadOverworldLayer2AndEventsTilemaps(NULLROM)		; $04DD40
DATATABLE_RT00_SMW_Layer2EventData:	%DATATABLE_RT00_SMW_Layer2EventData(NULLROM)				; $04DD8D
DATATABLE_RT01_SMW_Layer2EventData:	%DATATABLE_RT01_SMW_Layer2EventData(NULLROM)				; $04E359
DATATABLE_RT02_SMW_BitTable:	%DATATABLE_RT02_SMW_BitTable(NULLROM)						; $04E44B
ROUTINE_RT04_SMW_LoadOverworldLayer2AndEventsTilemaps:	%ROUTINE_RT04_SMW_LoadOverworldLayer2AndEventsTilemaps(NULLROM)		; $04E453
ROUTINE_SMW_BufferEventTileToLayer2Tilemap:	%ROUTINE_SMW_BufferEventTileToLayer2Tilemap(NULLROM)				; $04E496
ROUTINE_SMW_OverworldProcess01_ActivateEvents:	%ROUTINE_SMW_OverworldProcess01_ActivateEvents(NULLROM)			; $04E570
ROUTINE_RT02_SMW_OverworldEventProcess01_DestroyTileAnimation:	%ROUTINE_RT02_SMW_OverworldEventProcess01_DestroyTileAnimation(NULLROM)	; $04E587
ROUTINE_RT01_SMW_CheckIfDestroyTileEventIsActive:	%ROUTINE_RT01_SMW_CheckIfDestroyTileEventIsActive(NULLROM)			; $04E5A7
ROUTINE_SMW_OverworldEventProcess00_CheckIfEventShouldRun:	%ROUTINE_SMW_OverworldEventProcess00_CheckIfEventShouldRun(NULLROM)		; $04E5E6
ROUTINE_RT00_SMW_CheckIfDestroyTileEventIsActive:	%ROUTINE_RT00_SMW_CheckIfDestroyTileEventIsActive(NULLROM)			; $04E677
ROUTINE_SMW_OverworldEventProcess02_SetEventTileIndexes:	%ROUTINE_SMW_OverworldEventProcess02_SetEventTileIndexes(NULLROM)		; $04E6D3
ROUTINE_RT00_SMW_OverworldEventProcess03_GetLayer2Tile:	%ROUTINE_RT00_SMW_OverworldEventProcess03_GetLayer2Tile(NULLROM)		; $04E6F9
ROUTINE_SMW_BufferEventTileToStripeImageTable:	%ROUTINE_SMW_BufferEventTileToStripeImageTable(NULLROM)			; $04E76C
DATATABLE_SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent:	%DATATABLE_SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent(NULLROM)	; $04E8E4
ROUTINE_SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent:	%ROUTINE_SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent(NULLROM)	; $04E9EC
ROUTINE_RT01_SMW_OverworldEventProcess03_GetLayer2Tile:	%ROUTINE_RT01_SMW_OverworldEventProcess03_GetLayer2Tile(NULLROM)		; $04EA62
ROUTINE_RT00_SMW_OverworldEventProcess04_FadeInLayer2Tile:	%ROUTINE_RT00_SMW_OverworldEventProcess04_FadeInLayer2Tile(NULLROM)		; $04EAA4
ROUTINE_RT00_SMW_OverworldEventProcess01_DestroyTileAnimation:	%ROUTINE_RT00_SMW_OverworldEventProcess01_DestroyTileAnimation(NULLROM)	; $04EB56
ROUTINE_SMW_GetXAndYDispOfCurrentEventTileSprite:	%ROUTINE_SMW_GetXAndYDispOfCurrentEventTileSprite(NULLROM)			; $04EC67
ROUTINE_SMW_OverworldEventProcess05_GetLayer1Tile:	%ROUTINE_SMW_OverworldEventProcess05_GetLayer1Tile(NULLROM)			; $04EC78
ROUTINE_RT03_SMW_OverworldEventProcess01_DestroyTileAnimation:	%ROUTINE_RT03_SMW_OverworldEventProcess01_DestroyTileAnimation(NULLROM)	; $04ECD3
ROUTINE_RT01_SMW_OverworldEventProcess04_FadeInLayer2Tile:	%ROUTINE_RT01_SMW_OverworldEventProcess04_FadeInLayer2Tile(NULLROM)		; $04EE30
ROUTINE_RT04_SMW_OverworldEventProcess01_DestroyTileAnimation:	%ROUTINE_RT04_SMW_OverworldEventProcess01_DestroyTileAnimation(NULLROM)	; $04EE7A
INLINEDATATABLE_RT17_SMW_EmptySpace:	%INLINEDATATABLE_RT17_SMW_EmptySpace(NULLROM)					; $04EF3E
DATATABLE_SMW_QuitToTitleScreenText:	%DATATABLE_SMW_QuitToTitleScreenText(NULLROM)					; N/A
ROUTINE_SMW_DrawFlyingSwitchBlocks:	%ROUTINE_SMW_DrawFlyingSwitchBlocks(NULLROM)					; $04F280
ROUTINE_SMW_DisplayOverworldPrompt:	%ROUTINE_SMW_DisplayOverworldPrompt(NULLROM)					; $04F3E5
ROUTINE_RT00_SMW_OverworldPrompt07_DisplayingSavePrompt:	%ROUTINE_RT00_SMW_OverworldPrompt07_DisplayingSavePrompt(NULLROM)		; $04F3FA
ROUTINE_RT00_SMW_OverworldPrompt0B_ShowQuitToTitleScreenPrompt:	%ROUTINE_RT00_SMW_OverworldPrompt0B_ShowQuitToTitleScreenPrompt(NULLROM)	; N/A
ROUTINE_SMW_OverworldPrompt01_InitializeOverworldPrompt:	%ROUTINE_SMW_OverworldPrompt01_InitializeOverworldPrompt(NULLROM)		; $04F3FF
ROUTINE_SMW_OverworldPrompt02_ExpandPromptWindow:	%ROUTINE_SMW_OverworldPrompt02_ExpandPromptWindow(NULLROM)			; $04F411
DATATABLE_SMW_LifeExchangeText:	%DATATABLE_SMW_LifeExchangeText(NULLROM)					; $04F4B2
ROUTINE_RT00_SMW_OverworldPrompt03_OverworldLifeExchanger:	%ROUTINE_RT00_SMW_OverworldPrompt03_OverworldLifeExchanger(NULLROM)		; $04F503
ROUTINE_SMW_LoadOverworldSprites:	%ROUTINE_SMW_LoadOverworldSprites(NULLROM)					; $04F625
ROUTINE_SMW_OverworldLightningAndRandomCloudSpawning:	%ROUTINE_SMW_OverworldLightningAndRandomCloudSpawning(NULLROM)			; $04F6D0
ROUTINE_RT01_SMW_CheckIfXIsAllowedOnYSubmap:	%ROUTINE_RT01_SMW_CheckIfXIsAllowedOnYSubmap(NULLROM)				; $04F829
ROUTINE_RT01_SMW_SetOverworldSpriteFrameIndex:	%ROUTINE_RT01_SMW_SetOverworldSpriteFrameIndex(NULLROM)			; $04F833
DATATABLE_SMW_OverworldSpriteOAMIndexes:	%DATATABLE_SMW_OverworldSpriteOAMIndexes(NULLROM)				; $04F843
ROUTINE_SMW_ProcessOverworldSprites:	%ROUTINE_SMW_ProcessOverworldSprites(NULLROM)					; $04F853
ROUTINE_RT00_SMW_CheckIfXIsAllowedOnYSubmap:	%ROUTINE_RT00_SMW_CheckIfXIsAllowedOnYSubmap(NULLROM)				; $04F875
ROUTINE_RT00_SMW_OWSpr01_Lakitu:	%ROUTINE_RT00_SMW_OWSpr01_Lakitu(NULLROM)					; $04F8A6
ROUTINE_SMW_OWSpr02_BlueBird:	%ROUTINE_SMW_OWSpr02_BlueBird(NULLROM)						; $04F9A8
ROUTINE_SMW_OWSpr03_CheepCheep:	%ROUTINE_SMW_OWSpr03_CheepCheep(NULLROM)					; $04FA2E
ROUTINE_SMW_OWSpr04_PiranhaPlant:	%ROUTINE_SMW_OWSpr04_PiranhaPlant(NULLROM)					; $04FAF1
ROUTINE_SMW_OWSpr05_Cloud:	%ROUTINE_SMW_OWSpr05_Cloud(NULLROM)						; $04FB37
ROUTINE_SMW_OWSpr06_KoopaKid:	%ROUTINE_SMW_OWSpr06_KoopaKid(NULLROM)						; $04FB85
ROUTINE_SMW_OWSpr07_Smoke:	%ROUTINE_SMW_OWSpr07_Smoke(NULLROM)						; $04FC1E
ROUTINE_SMW_OWSpr08_BowserSign:	%ROUTINE_SMW_OWSpr08_BowserSign(NULLROM)					; $04FCE1
ROUTINE_SMW_OWSpr09_Bowser:	%ROUTINE_SMW_OWSpr09_Bowser(NULLROM)						; $04FD0A
ROUTINE_SMW_OWSpr0A_Boo:	%ROUTINE_SMW_OWSpr0A_Boo(NULLROM)						; $04FD70
ROUTINE_SMW_DrawOverworldSpriteShadow:	%ROUTINE_SMW_DrawOverworldSpriteShadow(NULLROM)				; $04FDE0
ROUTINE_SMW_AddZPositionToTempYPos:	%ROUTINE_SMW_AddZPositionToTempYPos(NULLROM)					; $04FE4E
ROUTINE_RT00_SMW_SetOverworldSpriteFrameIndex:	%ROUTINE_RT00_SMW_SetOverworldSpriteFrameIndex(NULLROM)			; $04FE5B
ROUTINE_SMW_GetOverworldSpriteOnScreenPosition:	%ROUTINE_SMW_GetOverworldSpriteOnScreenPosition(NULLROM)			; $04FE62
ROUTINE_SMW_UpdateOverworldSpritePosition:	%ROUTINE_SMW_UpdateOverworldSpritePosition(NULLROM)				; $04FE90
ROUTINE_SMW_CheckForPlayerToOverworldSpriteCollision:	%ROUTINE_SMW_CheckForPlayerToOverworldSpriteCollision(NULLROM)			; $04FED7
ROUTINE_RT01_SMW_OWSpr01_Lakitu:	%ROUTINE_RT01_SMW_OWSpr01_Lakitu(NULLROM)					; $04FF2E
INLINEDATATABLE_RT18_SMW_EmptySpace:	%INLINEDATATABLE_RT18_SMW_EmptySpace(NULLROM)					; $04FFB1
%BANK_END(<EndBank>)
endmacro

macro ROUTINE_RT01_SMW_HexToDec(Address)
namespace SMW_HexToDec
%InsertMacroAtXPosition(<Address>)

;Note: This one appears to be unused.
Bank04:
	%INLINEROUTINE_SMW_HexToDec(Y)
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UpdateOverworldSpritePosition(Address)
namespace SMW_UpdateOverworldSpritePosition
%InsertMacroAtXPosition(<Address>)

; Overworld sprite speed routine.
Main:
	TXA				;Transfer X to A
	CLC				;Clear Carry Flag
	ADC.b #((!Define_SMW_MaxOverworldSpriteSlot+$01)*$02)	;Add #$20 to A
	TAX				;Transfer A to X
	JSR.w Z				;>Handle Z position
	LDA.w !RAM_SMW_OWSpr_ZPosLo-((!Define_SMW_MaxOverworldSpriteSlot+$01)*$02),x	;Load OW Sprite XPos Low
	BPL.b CODE_04FEA0		;If it is => 80
	STZ.w !RAM_SMW_OWSpr_ZPosLo-((!Define_SMW_MaxOverworldSpriteSlot+$01)*$02),x	;Store 00 OW Sprite Xpos Low
CODE_04FEA0:
	TXA				;Transfer X to A
	SEC				;Set Carry Flag...
	SBC.b #!Define_SMW_MaxOverworldSpriteSlot+$01	;...for substraction
	TAX				;Transfer A to X
	JSR.w Y				;>Handle Y position
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite	;>Handle X position (index is back to being $00-$0F)

X:
Y:
Z:
	LDA.w !RAM_SMW_OWSpr_XSpeed,x	;Load OW Sprite X Speed
	ASL				;Multiply it by 2
	ASL				;4...
	ASL				;8...
	ASL				;16...
	CLC				;Clear Carry Flag
	ADC.w !RAM_SMW_OWSpr_SubXPos,x	;>These are fraction bits (fractions of 16; %XXXX0000) of position
	STA.w !RAM_SMW_OWSpr_SubXPos,x	;And store it in
	LDA.w !RAM_SMW_OWSpr_XSpeed,x	;Load OW Sprite X Speed
	PHP
	LSR				;Divide by 2
	LSR				;4
	LSR				;8
	LSR				;16
	LDY.b #$00			;Load $00 in Y
	PLP
	BPL.b +
	ORA.b #$F0
	DEY
+:
	ADC.w !RAM_SMW_OWSpr_XPosLo,x
	STA.w !RAM_SMW_OWSpr_XPosLo,x
	TYA
	ADC.w !RAM_SMW_OWSpr_XPosHi,x
	STA.w !RAM_SMW_OWSpr_XPosHi,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DisplayOverworldPrompt(Address)
namespace SMW_DisplayOverworldPrompt
%InsertMacroAtXPosition(<Address>)

Main:
	DEC
	JSL.l SMW_ExecutePtr_Absolute

Ptrs04F3EA:
	dw SMW_OverworldPrompt01_InitializeOverworldPrompt_Main
	dw SMW_OverworldPrompt02_ExpandPromptWindow_Main
	dw SMW_OverworldPrompt03_OverworldLifeExchanger_Main
	dw SMW_OverworldPrompt04_ShrinkPromptWindow_Main
	dw SMW_OverworldPrompt05_InitializeOverworldPrompt_Main
	dw SMW_OverworldPrompt06_ExpandPromptWindow_Main
	dw SMW_OverworldPrompt07_DisplayingSavePrompt_Main
	dw SMW_OverworldPrompt08_ShrinkPromptWindow_Main
if ver_is_smasw(!Define_Global_ROMToAssemble)
	dw SMW_OverworldPrompt09_InitializeOverworldPrompt_Main
	dw SMW_OverworldPrompt0A_ExpandPromptWindow_Main
	dw SMW_OverworldPrompt0B_ShowQuitToTitleScreenPrompt_Main
	dw SMW_OverworldPrompt0C_ShrinkPromptWindow_Main
endif
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldPrompt01_InitializeOverworldPrompt(Address)
namespace SMW_OverworldPrompt01_InitializeOverworldPrompt
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #!Define_SMW_Sound1DFC_MessageBox
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	INC.w !RAM_SMW_Pointer_DisplayOverworldPrompt
CODE_04F407:
	STZ.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings
	STZ.b !RAM_SMW_Mirror_BG3And4WindowMaskSettings
	STZ.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings
	STZ.w !RAM_SMW_Mirror_HDMAEnable
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_OverworldPrompt01_InitializeOverworldPrompt_Main, SMW_OverworldPrompt05_InitializeOverworldPrompt_Main)

if ver_is_smasw(!Define_Global_ROMToAssemble)
	%SetDuplicateOrNullPointer(SMW_OverworldPrompt01_InitializeOverworldPrompt_Main, SMW_OverworldPrompt09_InitializeOverworldPrompt_Main)
endif
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldPrompt02_ExpandPromptWindow(Address)
namespace SMW_OverworldPrompt02_ExpandPromptWindow
%InsertMacroAtXPosition(<Address>)

DATA_04F411:
	db $04,$FC

DATA_04F413:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	db $48,$00
else
	db $68,$00			;!
endif

Main:
	LDX.b #$00
	LDA.w !RAM_SMW_Player_MariosLives
	CMP.w !RAM_SMW_Player_LuigisLives
	BPL.b CODE_04F420
	INX
CODE_04F420:
	STX.w !RAM_SMW_Flag_WhoGetsLivesInExchangeMenu
	LDX.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
	LDA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	CMP.l DATA_04F413,x
	BNE.b CODE_04F44B
	INC.w !RAM_SMW_Pointer_DisplayOverworldPrompt
	LDA.w !RAM_SMW_Pointer_DisplayOverworldPrompt
	CMP.b #$07
	BNE.b CODE_04F43D
	LDY.b #!Define_SMW_StripeImage_SaveMenuText
	STY.b !RAM_SMW_Graphics_StripeImageToUpload
CODE_04F43D:
if ver_is_smasw(!Define_Global_ROMToAssemble)
	CMP.b #$0B
	BNE.b +
	PHX
	PHA
	LDX.b #SMW_QuitToTitleScreenText_EndEnd-SMW_QuitToTitleScreenText_Main+$01

-:
	LDA.w SMW_QuitToTitleScreenText_Main,x
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	DEX
	BPL.b -
	PLA
	PLX
+:
endif
	DEC
	AND.b #$03
	BNE.b Return04F44A
	STZ.w !RAM_SMW_Pointer_DisplayOverworldPrompt
	STZ.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
	BRA.b SMW_OverworldPrompt01_InitializeOverworldPrompt_CODE_04F407

Return04F44A:
	RTS

CODE_04F44B:
	CLC
	ADC.l DATA_04F411,x
	STA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
	CLC
	ADC.b #$80
	XBA
	REP.b #$10			; XY->16
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDX.w #$018E
else
	LDX.w #$016E
endif
	LDA.b #$FF
CODE_04F45E:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$50,x
	STZ.w !RAM_SMW_Misc_HDMAWindowEffectTable+$51,x
	DEX
	DEX
	BPL.b CODE_04F45E
	SEP.b #$10			; XY->8
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
	LDA.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange	;!
	LSR				;!
	ADC.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange	;!
	LSR				;!
	AND.b #$FE			;!
	TAX				;!
endif
	LDA.b #$80			;!
	SEC				;!
	SBC.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange	;!
	REP.b #$20			;! A->16
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDX.w !RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange
endif
	LDY.b #$48			;!
CODE_04F47F:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$C8,y
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$110,x
else
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$A8,y	;!
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$F0,x	;!
endif
	DEY				;!
	DEY				;!
	DEX				;!
	DEX				;!
	BPL.b CODE_04F47F		;!
	STZ.w !RAM_SMW_Palettes_BackgroundColorLo
	SEP.b #$20			; A->8
	LDA.b #$22
	STA.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings
	LDA.b #$20
	JMP.w SMW_SubmapSwitchProcess00_InitializeWindowHDMA_CODE_04DB95

ClearPromptWindowImage:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	%StripeImageHeader(.ClearLine1, $09, $0E, 0, $0015, 3)
elseif ver_is_smasw(!Define_Global_ROMToAssemble)
	%StripeImageHeader(.ClearLine1, $04, $0E, 0, $002D, 3)
else
	%StripeImageHeader(.ClearLine1, $04, $0E, 0, $0025, 3)
endif
	db $FC,$38
.ClearLine1End
if ver_is_japanese(!Define_Global_ROMToAssemble)
	%StripeImageHeader(.ClearLine2, $08, $10, 0, $001F, 3)
else
	%StripeImageHeader(.ClearLine2, $04, $10, 0, $002D, 3)
endif
.ClearLine2End
	db $FC,$38
	%StripeImageHeader(.ClearLine3, $0F, $11, 0, $0003, 3)
	db $FC,$38			;!
.ClearLine3End
	%StripeImageHeader(.ClearLine4, $08, $12, 0, $001D, 3)
	db $FC,$38
.ClearLine4End
	db $FF				;!

namespace off
	%SetDuplicateOrNullPointer(SMW_OverworldPrompt02_ExpandPromptWindow_Main, SMW_OverworldPrompt04_ShrinkPromptWindow_Main)
	%SetDuplicateOrNullPointer(SMW_OverworldPrompt02_ExpandPromptWindow_Main, SMW_OverworldPrompt06_ExpandPromptWindow_Main)
	%SetDuplicateOrNullPointer(SMW_OverworldPrompt02_ExpandPromptWindow_Main, SMW_OverworldPrompt08_ShrinkPromptWindow_Main)

if ver_is_smasw(!Define_Global_ROMToAssemble)
	%SetDuplicateOrNullPointer(SMW_OverworldPrompt02_ExpandPromptWindow_Main, SMW_OverworldPrompt0A_ExpandPromptWindow_Main)
	%SetDuplicateOrNullPointer(SMW_OverworldPrompt02_ExpandPromptWindow_Main, SMW_OverworldPrompt0C_ShrinkPromptWindow_Main)
endif
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_OverworldPrompt03_OverworldLifeExchanger(Address)
namespace SMW_OverworldPrompt03_OverworldLifeExchanger
%InsertMacroAtXPosition(<Address>)

DATA_04F503:
	db $7D,$38,$7E,$78

DATA_04F507:
	db $7E,$38,$7D,$78

DATA_04F50B:
	db $7D,$B8,$7E,$F8

DATA_04F50F:
	db $7E,$B8,$7D,$F8

Main:
	LDA.w !RAM_SMW_IO_ControllerPress1CopyP1
	ORA.w !RAM_SMW_IO_ControllerPress1CopyP2
	AND.b #!Joypad_Start>>8
	BEQ.b DontCloseExchange
	LDX.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Player_MariosLives,x
	STA.w !RAM_SMW_Player_CurrentLifeCount
	JSL.l SMW_CloseOverworldPrompt_Main
	RTS

; Main Lives Exchanger routine $04F56F is X location of Mario on lives
; exchange $04F570 is Y location of Mario on lives exchange $04F575 is X
; location of Luigi on lives exchange $04F576 is Y location of Luigi on
; lives exchange $04F57B is the tile to use for Mario on lives exchange
; $04F57C is Pal/flip/etc. of Mario on lives exchange $04F581 is the tile to
; use for Luigi on lives exchange $04F582 is Pal/flip/etc. of Luigi on lives
; exchange
DontCloseExchange:
	LDA.w !RAM_SMW_IO_ControllerPress1CopyP1
	AND.b #(!Joypad_Y>>8)|(!Joypad_B>>8)
	BNE.b CODE_04F53B
	LDA.w !RAM_SMW_IO_ControllerPress1CopyP2
	AND.b #(!Joypad_Y>>8)|(!Joypad_B>>8)
	BEQ.b CODE_04F56C
	EOR.b #(!Joypad_Y>>8)|(!Joypad_B>>8)
CODE_04F53B:
	LDX.b #$01
	ASL
	BCS.b CODE_04F541
	DEX
CODE_04F541:
	CPX.w !RAM_SMW_Flag_WhoGetsLivesInExchangeMenu
	BEQ.b CODE_04F54B
	LDA.b #$18
	STA.w !RAM_SMW_Timer_LifeExchangeBlinkingArrowFrames
CODE_04F54B:
	STX.w !RAM_SMW_Flag_WhoGetsLivesInExchangeMenu
	TXA
	EOR.b #$01
	TAY
	LDA.w !RAM_SMW_Player_MariosLives,x
	BEQ.b CODE_04F56C
	BMI.b CODE_04F56C
	LDA.w !RAM_SMW_Player_MariosLives,y
	CMP.b #$62
	BPL.b CODE_04F56C
	INC
	STA.w !RAM_SMW_Player_MariosLives,y
	DEC.w !RAM_SMW_Player_MariosLives,x
	LDA.b #!Define_SMW_Sound1DFC_StepOnLevelTile
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
CODE_04F56C:
	REP.b #$20			; A->16
	LDA.w #$7848
	STA.w SMW_OAMBuffer[$27].XDisp
	LDA.w #$7890
	STA.w SMW_OAMBuffer[$28].XDisp
	LDA.w #$340A
	STA.w SMW_OAMBuffer[$27].Tile
	LDA.w #$360A
	STA.w SMW_OAMBuffer[$28].Tile
	SEP.b #$20			; A->8
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$27].Slot
	STA.w SMW_OAMTileSizeBuffer[$28].Slot
if defined("Define_SMW_SA1")
	JML.l overworld_lives_exchange_fix
else
	JSL.l SMW_LoadOverworldLifeCounter_Main
endif
	LDY.b #SMW_LifeExchangeText_End-SMW_LifeExchangeText_Main
	TYA
	CLC
	ADC.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_04F5A1:
	LDA.w SMW_LifeExchangeText_Main,y
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	DEX
	DEY
	BPL.b CODE_04F5A1
	INX
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_Player_MariosLives
	BMI.b MarioGameOver
	LDA.w #$38FC
	STA.l SMW_StripeImageUploadTable[$22].LowByte,x
	STA.l SMW_StripeImageUploadTable[$23].LowByte,x
MarioGameOver:
	LDY.w !RAM_SMW_Player_LuigisLives
	BMI.b LuigiGameOver
	LDA.w #$38FC
	STA.l SMW_StripeImageUploadTable[$26].LowByte,x
	STA.l SMW_StripeImageUploadTable[$27].LowByte,x
LuigiGameOver:
	SEP.b #$20			; A->8
	INC.w !RAM_SMW_Timer_LifeExchangeBlinkingArrowFrames
	LDA.w !RAM_SMW_Timer_LifeExchangeBlinkingArrowFrames
	AND.b #$18
	BEQ.b CODE_04F600
	LDA.w !RAM_SMW_Flag_WhoGetsLivesInExchangeMenu
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w DATA_04F503,y
	STA.l SMW_StripeImageUploadTable[$1A].LowByte,x
	LDA.w DATA_04F507,y
	STA.l SMW_StripeImageUploadTable[$1B].LowByte,x
	LDA.w DATA_04F50B,y
	STA.l SMW_StripeImageUploadTable[$1E].LowByte,x
	LDA.w DATA_04F50F,y
	STA.l SMW_StripeImageUploadTable[$1F].LowByte,x
	SEP.b #$20			; A->8
CODE_04F600:
	LDA.w !RAM_SMW_Player_MariosLives
	JSR.w CODE_04F60E
	TXA
	CLC
	ADC.b #$0A
	TAX
	LDA.w !RAM_SMW_Player_LuigisLives
CODE_04F60E:
	INC
	PHX
	JSL.l CODE_00974C
	TXY
	BNE.b CODE_04F619
	LDX.b #$FC
CODE_04F619:
	TXY
	PLX
	STA.l SMW_StripeImageUploadTable[$12].LowByte,x
	TYA
	STA.l SMW_StripeImageUploadTable[$11].LowByte,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_OverworldPrompt07_DisplayingSavePrompt(Address)
namespace SMW_OverworldPrompt07_DisplayingSavePrompt
%InsertMacroAtXPosition(<Address>)

Main:
if defined("Define_SMW_SA1")
	JSL.l overworld_blinking_cursor
else
	JSL.l Bank00
endif
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_OverworldPrompt0B_ShowQuitToTitleScreenPrompt(Address)				; Note: This is a SMAS exclusive routine macro
namespace SMW_OverworldPrompt0B_ShowQuitToTitleScreenPrompt
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank30
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_HandleOverworldStarPipeWarp(Address)
%SMW_RelocatableTableSlot(<Address>, StarPipeWarps)
if !Define_SMW_RelocateOverworldTables == !FALSE
	%SMW_OverworldTable_StarPipeWarps()
endif
endmacro

; The table itself, so that the relocated build can emit it where it
; wants it: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedOverworldTables. Nothing here knows which.
macro SMW_OverworldTable_StarPipeWarps()
namespace SMW_HandleOverworldStarPipeWarp

incsrc "overworld/tables/star-pipe-warps.asm"
namespace off
endmacro

macro ROUTINE_SMW_HandleOverworldStarPipeWarp(Address)
namespace SMW_HandleOverworldStarPipeWarp
%SMW_RelocatedRoutineStart(<Address>, StarPipeWarps)

GetIndex:
;$048509
	if !Define_SMW_RelocateOverworldTables == !TRUE
	; The trigger tables have moved to bank $10 and the search indexes them
	; with Y, which no long-addressed read takes, so the data bank goes to
	; the slots for the length of it. That bank is below $40, so the work RAM
	; mirror at $0000-$1FFF is still under it and every RAM read below still
	; lands where it did.
	PHB
	PEA.w !Define_SMW_ReservedBankDBR		;> both bytes are the bank, so either PLB lands on it
	PLB
	PLB
	endif
	LDY.w !RAM_SMW_Player_CurrentCharacter			;\ LM: Hijacks here to allow for more star/pipe warp indexes (1.90+)
	LDA.w !RAM_SMW_Overworld_MarioMap,y			;/
	STA.b !RAM_SMW_Misc_ScratchRAM01	; Store it in $01
	STZ.b !RAM_SMW_Misc_ScratchRAM00	; Store x00 in $00
	REP.b #$20			; A->16
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo	; Set X to Current character*4
	LDY.b #TriggerRow-TriggerColumnAndMap-2	; The last entry, two bytes a word: the table's own length, so a grown table is searched whole -- up to 64 entries, past which the BPL below falls through
CODE_04851A:
	LDA.w TriggerColumnAndMap,y
	EOR.b !RAM_SMW_Misc_ScratchRAM00
	CMP.w #$0200
	BCS.b CODE_048531
	CMP.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	BNE.b CODE_048531
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	CMP.w TriggerRow,y
	BEQ.b CODE_048535
CODE_048531:
	DEY
	DEY
	BPL.b CODE_04851A
CODE_048535:
	STY.w !RAM_SMW_Overworld_StarPipeIndex	; Store Y in "Warp destination"
	SEP.b #$20			; A->8
	if !Define_SMW_RelocateOverworldTables == !TRUE
	PLB
	endif
	RTS

SetPlayerDestination:
;$04853B
	PHB
	if !Define_SMW_RelocateOverworldTables == !TRUE
	PEA.w !Define_SMW_ReservedBankDBR		;> the landing tables are in the reserved bank
	PLB
	PLB
	else
	PHK
	PLB
	endif
	REP.b #$20			; A->16
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDY.w !RAM_SMW_Overworld_StarPipeIndex
	LDA.w LandingXAndMap,y
	PHA
	AND.w #$01FF
	STA.w !RAM_SMW_Overworld_MarioXPosLo,x
	LSR
	LSR
	LSR
	LSR
	STA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	LDA.w LandingY,y
	STA.w !RAM_SMW_Overworld_MarioYPosLo,x
	LSR
	LSR
	LSR
	LSR
	STA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	PLA
	LSR
	XBA								;\ LM: Hijacks here to allow for more star/pipe warp indexes (1.90+)
	AND.w #$000F							;/
	STA.w !RAM_SMW_Overworld_CurrentlyLoadedSubmapLo
	if !Define_SMW_RelocateOverworldTables == !TRUE
	PHK						;\ SetLayerPositions reads a table that did not move,
	PLB						;/ so it wants this bank and not the slots'.
	endif
	REP.b #$10			; XY->16
	JSR.w SMW_HandleOverworldPathExits_SetLayerPositions
	SEP.b #$30			; AXY->8
	PLB
	RTL
if !Define_SMW_RelocateOverworldTables == !TRUE
if defined("Define_SMW_SA1")
	; SA-1 Pack's overworld boost hands work back to the SNES CPU through a
	; pushed return address of $048575 -- where the RTL above sat before this
	; routine moved into its tables' vacated run. The moved copy ends short
	; of that address, so the byte the boost's literals expect is pinned
	; where it was: an RTL nothing here falls into, reached only through the
	; pack's seams. The literal is a USA address, which is the one release
	; the pack applies to.
	assert pc() <= ($048575), "The moved copy runs past the pinned RTL at $048575!"
	org $048575
	RTL
endif
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_HandleOverworldPathExits(Address)
%SMW_RelocatableTableSlot(<Address>, PathExits)
if !Define_SMW_RelocateOverworldTables == !FALSE
	%SMW_OverworldTable_PathExits()
endif
endmacro

; The table itself, so that the relocated build can emit it where it
; wants it: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedOverworldTables. Nothing here knows which.
macro SMW_OverworldTable_PathExits()
namespace SMW_HandleOverworldPathExits

incsrc "overworld/tables/path-exits.asm"
namespace off
endmacro

macro ROUTINE_SMW_HandleOverworldPathExits(Address)
namespace SMW_HandleOverworldPathExits
%SMW_RelocatedRoutineStart(<Address>, PathExits)

DATA_049A0C:
	dw $FFEF,$FFD8		; Yoshi's Island
	dw $FFEF,$0080		; Vanilla Dome
	dw $FFEF,$0128		; Forest of Illusion
	dw $00F0,$FFD8		; Valley of Bowser
	dw $00F0,$0080		; Special World
	dw $00F0,$0128		; Star World

Main:
;$049A24
	if !Define_SMW_RelocateOverworldTables == !TRUE
	; The three exit tables have moved to bank $10 and the search indexes
	; them with Y, so the data bank goes to the slots for the length of it --
	; see SMW_HandleOverworldStarPipeWarp_GetIndex, which does the same for
	; the same reason. SetLayerPositions below is a separate entry point and
	; reads a table that did not move, so it is left alone.
	PHB
	PEA.w !Define_SMW_ReservedBankDBR		;> both bytes are the bank, so either PLB lands on it
	PLB
	PLB
	endif
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	AND.w #$00FF
	STA.w !RAM_SMW_Overworld_CurrentlyLoadedSubmapLo
	LDA.w #((LandingPositions-TriggerPositions)/5)*2-2	;\ LM: Hijacks here to allow for more path exit indexes (2.40+)
	STA.b !RAM_SMW_Misc_ScratchRAM02			;/ The last entry's landing-cell pair: the table's own length, like the trigger cursor below
	LDY.b #LandingPositions-TriggerPositions-5		; The last entry, five bytes a row: the table's own length, so a grown table is searched whole -- up to 26 entries, past which the BPL below falls through
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
Loop:
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x			;\ Glitch: This code will malfunction if the player is not aligned to the layer 1 paths correctly.
	CMP.w TriggerPositions,y					;| This can be fixed by using AND.w #$FFF0 before each of these CMPs and changing the ones digit of the 16-bit values in TriggerPositions and LandingPositions to 0.
	BNE.b CODE_049A85					;| Todo: Other things might be necessary to fix this bug.
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x			;|
	CMP.w TriggerPositions+$02,y					;|
	BNE.b CODE_049A85					;/
	LDA.w TriggerPositions+$04,y
	AND.w #$00FF
	CMP.w !RAM_SMW_Overworld_CurrentlyLoadedSubmapLo
	BNE.b CODE_049A85
	LDA.w LandingPositions,y
	STA.w !RAM_SMW_Overworld_MarioYPosLo,x
	LDA.w LandingPositions+$02,y
	STA.w !RAM_SMW_Overworld_MarioXPosLo,x
	LDA.w LandingPositions+$04,y
	AND.w #$00FF
	STA.w !RAM_SMW_Overworld_CurrentlyLoadedSubmapLo
	LDY.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w LandingCells,y
	AND.w #$00FF
	STA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	LDA.w LandingCells+$01,y
	AND.w #$00FF
	STA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	BRA.b CODE_049A90

CODE_049A85:
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	DEY
	DEY
	DEY
	DEY
	DEY
	BPL.b Loop
CODE_049A90:
	SEP.b #$20			; A->8
	if !Define_SMW_RelocateOverworldTables == !TRUE
	PLB
	endif
	RTS

SetLayerPositions:
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	AND.w #$00FF
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	AND.w #$FF00
	ORA.w !RAM_SMW_Overworld_CurrentlyLoadedSubmapLo
	STA.w !RAM_SMW_Overworld_MarioMap,x
	AND.w #$00FF
	BNE.b CODE_049AB0
	JMP.w SMW_OverworldProcess04_PlayerIsMoving_CODE_04983F

CODE_049AB0:
	DEC
	ASL
	ASL
	TAY
	LDA.w DATA_049A0C,y
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	LDA.w DATA_049A0C+$02,y
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_OverworldSpriteOAMIndexes(Address)
namespace SMW_OverworldSpriteOAMIndexes
%InsertMacroAtXPosition(<Address>)

; Where each overworld sprite slot writes its tiles, as a byte offset from OAM
; object $10 -- the base every overworld draw indexes from, with the objects
; below it going to the players and the border box. One entry per slot, and
; the value is fixed: nothing rotates it and nothing reassigns it per frame.
;
; A sprite's tiles walk *down* from its index. Each tile written through
; SMW_OWSpr04_PiranhaPlant_GenericOverworldSpriteGFXRt ends with four DEYs, so
; a slot's room is the gap to the next lower index in use -- $9C has 21
; objects under it and $DC has one. The one-object slots therefore hold only
; a one-tile sprite, which is what the shipped table puts in them.
;
; Slots $00-$04 all read $F4, and the shipped table leaves slots $03 and $04
; empty because of it: the three clouds above them never take an index from
; here (they share the cursor at
; !RAM_SMW_Sprites_StartingOAMIndexForOverworldSprites), but two drawing
; sprites in $03 and $04 would write over each other.
Main:
	db $F4,$F4,$F4,$F4,$F4,$9C,$3C,$48
	db $C8,$CC,$A0,$A4,$D8,$DC,$E0,$E4
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GetOverworldSpriteOnScreenPosition(Address)
namespace SMW_GetOverworldSpriteOnScreenPosition
%InsertMacroAtXPosition(<Address>)

Main:
	TXA
	CLC
	ADC.b #!Define_SMW_MaxOverworldSpriteSlot+$01
	TAX
	LDY.b #$02
	JSR.w Y
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	SEC
	SBC.w !RAM_SMW_OWSpr_ZPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	BCS.b CODE_04FE7B
	DEC.b !RAM_SMW_Misc_ScratchRAM03
CODE_04FE7B:
	LDY.b #$00
Y:
	LDA.w !RAM_SMW_OWSpr_XPosHi,x
	XBA
	LDA.w !RAM_SMW_OWSpr_XPosLo,x
	REP.b #$20			; A->16
	SEC
	SBC.w !RAM_SMW_Mirror_CurrentLayer1XPosLo,y
	STA.w !RAM_SMW_Misc_ScratchRAM00,y
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_AddZPositionToTempYPos(Address)
namespace SMW_AddZPositionToTempYPos
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.w !RAM_SMW_OWSpr_ZPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	BCC.b Return04FE5A
	INC.b !RAM_SMW_Misc_ScratchRAM03
Return04FE5A:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_SetOverworldSpriteFrameIndex(Address)
namespace SMW_SetOverworldSpriteFrameIndex
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	CLC
	ADC.w DATA_04F833,x
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_SetOverworldSpriteFrameIndex(Address)
namespace SMW_SetOverworldSpriteFrameIndex
%InsertMacroAtXPosition(<Address>)

DATA_04F833:
	db $00,$52,$31,$19,$45,$2A,$03,$8B
	db $94,$3C,$78,$0D,$36,$5E,$87,$1F
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckForPlayerToOverworldSpriteCollision(Address)
namespace SMW_CheckForPlayerToOverworldSpriteCollision
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SubOverworldHorizAndVertPos
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	CMP.w #$0008
	BCS.b ADDR_04FEE6
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.w #$0008
ADDR_04FEE6:
	SEP.b #$20			; A->8
	TXA
	BCS.b Return04FEEE
	STA.w !RAM_SMW_Overworld_EnterLevelFlag
Return04FEEE:
	RTS

SubOverworldHorizAndVertPos:
	LDA.w !RAM_SMW_OWSpr_XPosHi,x
	XBA
	LDA.w !RAM_SMW_OWSpr_XPosLo,x
	REP.b #$20			; A->16
	CLC
	ADC.w #$0008
	LDY.w !RAM_SMW_Player_CurrentCharacterX4Lo
	SEC
	SBC.w !RAM_SMW_Overworld_MarioXPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b ADDR_04FF0B
	EOR.w #$FFFF
	INC
ADDR_04FF0B:
	STA.b !RAM_SMW_Misc_ScratchRAM06
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_OWSpr_YPosHi,x
	XBA
	LDA.w !RAM_SMW_OWSpr_YPosLo,x
	REP.b #$20			; A->16
	CLC
	ADC.w #$0008
	LDY.w !RAM_SMW_Player_CurrentCharacterX4Lo
	SEC
	SBC.w !RAM_SMW_Overworld_MarioYPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	BPL.b ADDR_04FF2B
	EOR.w #$FFFF
	INC
ADDR_04FF2B:
	STA.b !RAM_SMW_Misc_ScratchRAM08
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawOverworldSpriteShadow(Address)
namespace SMW_DrawOverworldSpriteShadow
%InsertMacroAtXPosition(<Address>)

LeftTileXDisp:
	db $00,$00,$00,$00,$01,$02,$02,$02
	db $00,$00,$01,$01,$02,$02,$03,$03

RightTileXDisp:
	db $08,$08,$08,$08,$07,$06,$05,$05
	db $00,$00,$0E,$0E,$0C,$0C,$0A,$0A

Main:
	ROR.b !RAM_SMW_Misc_ScratchRAM04
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main
	JSR.w SMW_AddZPositionToTempYPos_Main
	LDA.w !RAM_SMW_OWSpr_ZPosLo,x
	LSR
	LSR
	LSR
	LSR
	LDY.b #$29
	BIT.b !RAM_SMW_Misc_ScratchRAM04				;\ Note: Lakitu and the blue bird are the only sprites that call this routine and both clear the carry flag before doing so.
	BPL.b ADDR_04FE1A						;| That means that the code below will never execute because $04 will always be positive.
	LDY.b #$2E							;| Tile #$2E is part of Yoshi's face, so the shadow will glitch if this were to execute anyway.
	CLC								;| Perhaps #$2E was originally a different shadow tile?
	ADC.b #$08							;/
ADDR_04FE1A:
	STY.b !RAM_SMW_Misc_ScratchRAM05
	TAY
	STY.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w LeftTileXDisp,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b ADDR_04FE2B
	INC.b !RAM_SMW_Misc_ScratchRAM01
ADDR_04FE2B:
	LDA.b #$32
	LDY.w SMW_OverworldSpriteOAMIndexes_Main,x
	JSR.w ADDR_04FE45
	PHY
	LDY.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w RightTileXDisp,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b ADDR_04FE42
	INC.b !RAM_SMW_Misc_ScratchRAM01
ADDR_04FE42:
	LDA.b #$72
	PLY
ADDR_04FE45:
	XBA
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	ASL
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	JMP.w SMW_OWSpr04_PiranhaPlant_GenericOverworldSpriteGFXRt_Entry2
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_CheckIfXIsAllowedOnYSubmap(Address)
namespace SMW_CheckIfXIsAllowedOnYSubmap
%InsertMacroAtXPosition(<Address>)

ANDTable:
	db $80,$40,$20,$10,$08,$04,$02

Sprites:
	LDY.w !RAM_SMW_OWSpr_SpriteID,x
	LDA.w DisableSpriteOnXSubmapFlags-$01,y
Lightning:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_Pointer_CurrentOverworldProcess
	CPY.b #$0A
	BNE.b CODE_04F892
	LDY.w !RAM_SMW_Overworld_SubmapSwitchProcess
	CPY.b #$01
	BNE.b CODE_04F8A3
CODE_04F892:
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	TAY
	LDA.w ANDTable,y
	AND.b !RAM_SMW_Misc_ScratchRAM00
	BEQ.b Return04F8A5
CODE_04F8A3:
	LDA.b #$01
Return04F8A5:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckIfXIsAllowedOnYSubmap(Address)
namespace SMW_CheckIfXIsAllowedOnYSubmap
%InsertMacroAtXPosition(<Address>)

incsrc "overworld/tables/sprite-submaps.asm"
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_LoadOverworldSprites(Address)
namespace SMW_LoadOverworldSprites
%InsertMacroAtXPosition(<Address>)

; Overworld sprite data - controls 13 of the 16 slots of the overworld
; sprite tables (the first 3 of the 16 are reserved for clouds). One
; overworld sprite has 5 bytes: Byte 1 - sprite number Byte 2 - X-Pos, low
; Byte 3 - X-Pos, high Byte 4 - Y-Pos, low Byte 5 - Y-Pos, high Data is only
; read once, on titlescreen load. (Which also explains the bug that occurs
; with the titlescreen showing an unnecessary cloud tile.)
;
; Positions are signed 16-bit map pixels in the one shared 512x512 space
; (Bowser ships at Y = -$0004); which submap shows a sprite follows its
; *number* through DisableSpriteOnXSubmapFlags above, and the last three
; slots feed the SubmapBoo*PosOffset tables below. The sprite numbers are
; the !Define_SMW_SpriteID_OWSpr* enum:
;   $00 none        $01 Lakitu     $02 Blue Bird  $03 Cheep Cheep
;   $04 Piranha Plant  $05 Cloud   $06 Koopa Kid  $07 Smoke
;   $08 Bowser Sign    $09 Bowser  $0A Boo
; Sprite $00's per-frame handler is a null pointer to a bare RTS
; (SMW_ProcessOverworldSprites' table), so an empty slot's position is dead
; data: the shipped table's leftover positions do nothing.
;
; Three numbers ignore the position loaded here as well, overwriting it from
; tables of their own, so editing a slot that holds one moves nothing:
; $03 Cheep Cheep and $06 Koopa Kid place themselves off the trigger tile the
; player stands on, and $07 Smoke rewrites its position every frame from the
; per-map pair in SMW_OWSpr07_Smoke -- ($0038,$018A) on the main map and
; ($0068,$006A) on Yoshi's Island, the only two maps its flags allow.
SpriteSlotData:
	incbin "overworld/sprites/slots.bin"
.End:

; X positions of the overworld ghost sprites, relative to their
; corresponding main map ghosts. Two bytes each. The small size of this
; table is why you can't have ghosts in any slot other than the last three.
SubmapBooXPosOffset:
	dw $0030,$0100,$FF10

; Y positions of the overworld ghost sprites, relative to their
; corresponding main map ghosts. Two bytes each. The small size of this
; table is why you can't have ghosts in any slot other than the last three.
SubmapBooYPosOffset:
	dw $0020,$FF70,$0010

UNK_04F672:
	db $01,$40,$80

Main:
;$04F675
	PHB
	PHK
	PLB
	LDX.b #!Define_SMW_MaxOverworldSpriteSlot-$03
	LDY.b #(!Define_SMW_MaxOverworldSpriteSlot)*((SpriteSlotData_End-SpriteSlotData)/$0D)
CODE_04F67C:
	LDA.w SpriteSlotData-(!Define_SMW_MaxOverworldSpriteSlot),y
	STA.w !RAM_SMW_OWSpr_SpriteID+$03,x
	CMP.b #!Define_SMW_SpriteID_OWSpr01_Lakitu
	BEQ.b ADDR_04F68A
	CMP.b #!Define_SMW_SpriteID_OWSpr02_BlueBird
	BNE.b CODE_04F68F
ADDR_04F68A:
	LDA.b #$40
	STA.w !RAM_SMW_OWSpr_ZPosLo+$03,x
CODE_04F68F:
	LDA.w SpriteSlotData-(!Define_SMW_MaxOverworldSpriteSlot-$01),y
	STA.w !RAM_SMW_OWSpr_XPosLo+$03,x
	LDA.w SpriteSlotData-(!Define_SMW_MaxOverworldSpriteSlot-$02),y
	STA.w !RAM_SMW_OWSpr_XPosHi+$03,x
	LDA.w SpriteSlotData-(!Define_SMW_MaxOverworldSpriteSlot-$03),y
	STA.w !RAM_SMW_OWSpr_YPosLo+$03,x
	LDA.w SpriteSlotData-(!Define_SMW_MaxOverworldSpriteSlot-$04),y
	STA.w !RAM_SMW_OWSpr_YPosHi+$03,x
	TYA
	SEC
	SBC.b #(SpriteSlotData_End-SpriteSlotData)/$0D
	TAY
	DEX
	BPL.b CODE_04F67C
	LDX.b #!Define_SMW_MaxOverworldSpriteSlot-$02
CODE_04F6B1:
	STZ.w !RAM_SMW_OWSpr0A_Boo_UnknownTable7E0E25,x
	LDA.w SMW_OWSpr09_Bowser_DATA_04FD22				;\ Optimization: STZ.w !RAM_SMW_OWSpr_ZSpeed,x?
	DEC								;| $04FD22 contains a $01, for reference.
	STA.w !RAM_SMW_OWSpr_ZSpeed,x					;/
	LDA.w SubmapBooXPosOffset-$01,x
CODE_04F6BE:
	PHA
	STX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
	JSR.w SMW_ProcessOverworldSprites_Main
	PLA
	DEC
	BNE.b CODE_04F6BE
	INX
	CPX.b #!Define_SMW_MaxOverworldSpriteSlot+$01
	BCC.b CODE_04F6B1
	PLB
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CalculateOverworldPlayerPosition(Address)
namespace SMW_CalculateOverworldPlayerPosition
%InsertMacroAtXPosition(<Address>)

; Calculator for the players overworld tile position. Before calling this
; function $00 must contain the 16 bit X position of the player, $02 must
; contain the 16 bit Y position of the player, and X must be 0 or 1 (luigi,
; mario). Additionally, A must be 16 bit.
Main:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; Get overworld X pos/16 (X)
	AND.w #$000F
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$0010
	ASL				; |Set tile pos to ((X&0xF)+((X&0x10)<<4))
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM02	; Get overworld Y pos/16 (Y)
	ASL
	ASL
	ASL				; |Increase tile pos by ((Y<<4)&0xFF)
	ASL
	AND.w #$00FF
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	AND.w #$0010
	BEQ.b CODE_0498B5		; |If (Y&0x10) isn't 0,
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; |increase tile pos by x200
	CLC
	ADC.w #$0200
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_0498B5:
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	AND.w #$00FF
	BEQ.b Return0498C5					; Note: !Define_SMW_Overworld_MainMap
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; |Increase tile pos by x400
	CLC
	ADC.w #$0400
	STA.b !RAM_SMW_Misc_ScratchRAM04
Return0498C5:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleCurrentOverworldProcess(Address)
namespace SMW_HandleCurrentOverworldProcess
%InsertMacroAtXPosition(<Address>)

Main:
if defined("Define_SMW_SA1")
	JSL.l overworld_events
	RTS
	NOP #2
else
	LDA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	JSL.l SMW_ExecutePtr_Long
endif

; Pointers that are indexed by $7E13D9. Each one points to a different
; process running on the overworld.
PtrsLong04857D:
	dl SMW_OverworldProcess00_OverworldEntryInitialization_Main
	dl SMW_OverworldProcess01_ActivateEvents_Main
	dl SMW_OverworldProcess02_HandleLevelBeaten_Main
	dl SMW_OverworldProcess03_StandingStill_Main
	dl SMW_OverworldProcess04_PlayerIsMoving_Main
	dl SMW_OverworldProcess05_CheckForPlayerSwitch_Main
	dl SMW_OverworldProcess06_PlayerSwitchFadeOut_Main
	dl SMW_OverworldProcess07_SwitchingPlayers_Main
	dl SMW_OverworldProcess08_PlayerSwitchFadeIn_Main
	dl SMW_OverworldProcess09_FinishedSwitchingPlayers_Main
	dl SMW_OverworldProcess0A_SwitchBetweenSubmaps_Main
	dl SMW_OverworldProcess0B_StarWarpAnimation_Main
	dl SMW_OverworldProcess0C_IntroMarch_Main
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldProcess00_OverworldEntryInitialization(Address)
namespace SMW_OverworldProcess00_OverworldEntryInitialization
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$08
	STA.w !RAM_SMW_Timer_KeepGameModeActive
	LDA.w !RAM_SMW_Overworld_MarioMap
	CMP.b #!Define_SMW_Overworld_YoshisIsland
	BNE.b CODE_048F13
	LDA.w !RAM_SMW_Overworld_MarioXPosLo
	CMP.b #$68
	BNE.b CODE_048F13
	LDA.w !RAM_SMW_Overworld_MarioYPosLo
	CMP.b #$8E
	BNE.b CODE_048F13
	LDA.b #$0C
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	BRL.w CODE_048F7A

CODE_048F13:
	REP.b #$20			; A->16
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TXA
	LSR
	LSR
	TAX
	JSR.w SMW_CalculateOverworldPlayerPosition_Main
	REP.b #$10			; XY->16
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Flag_GotMidpoint					;\ Glitch: Dying in the bonus game results in setting the midpoint flag
	BEQ.b CODE_048F56						;| These checks need to be swapped and all instances of !RAM_SMW_Flag_ActivateOverworldEvent need to be removed
	LDA.w !RAM_SMW_Misc_ExitLevelAction				;|
	BEQ.b CODE_048F56						;|
	BPL.b CODE_048F5F						;/
	REP.b #$20			; A->16
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x
	AND.w #$00FF
	TAX
	LDA.w !RAM_SMW_Overworld_LevelTileSettings,x
	ORA.w #$0040
	STA.w !RAM_SMW_Overworld_LevelTileSettings,x
CODE_048F56:
	SEP.b #$20			; A->8
	LDA.b #$05
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	BRA.b CODE_048F7A

CODE_048F5F:
	REP.b #$20			; A->16
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x
	AND.w #$00FF
	TAX
	LDA.w !RAM_SMW_Overworld_LevelTileSettings,x
	ORA.w #$0080
	AND.w #$FFBF
	STA.w !RAM_SMW_Overworld_LevelTileSettings,x
	INC.w !RAM_SMW_Pointer_CurrentOverworldProcess
CODE_048F7A:
	REP.b #$30			; AXY->16
	JMP.w SMW_OverworldProcess04_PlayerIsMoving_CODE_049831
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldProcess02_HandleLevelBeaten(Address)
namespace SMW_OverworldProcess02_HandleLevelBeaten
%InsertMacroAtXPosition(<Address>)

DATA_048F7F:
	%INLINEDATATABLE_SMW_SavePromptLevels()

Main:
	JSR.w SMW_UnlockOverworldPathBasedOnExit_Main
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	LDX.b #$07			;!
CODE_048F8C:
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo	;!
	CMP.w DATA_048F7F,x		;!
	BNE.b CODE_049000		;!
	%INLINEROUTINE_SMW_PreparePlayerSwap()
endif
	LDA.w !RAM_SMW_Misc_ExitLevelAction
	CMP.b #$E0
	BNE.b CODE_048FFB
	DEC.w !RAM_SMW_Timer_KeepGameModeActive
	BMI.b ADDR_048FE9
	RTS

ADDR_048FE9:
	INC.w !RAM_SMW_Flag_ShowSavePrompt
	JSR.w SMW_UpdateSaveBuffer_Main
	LDA.b #$02
	STA.w !RAM_SMW_Timer_KeepGameModeActive
	LDA.b #$04
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	BRA.b CODE_049003

CODE_048FFB:
	INC.w !RAM_SMW_Flag_ShowSavePrompt
	BRA.b CODE_049003

CODE_049000:
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	DEX				;!
	BPL.b CODE_048F8C		;!
endif

CODE_049003:
	REP.b #$20			; A->16
	STZ.b !RAM_SMW_Misc_ScratchRAM06
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TXA
	LSR
	LSR
	TAX
	JSR.w SMW_CalculateOverworldPlayerPosition_Main
	REP.b #$10			; XY->16
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.l !RAM_SMW_Blocks_Map16TableLo,x
	AND.w #$00FF
	STA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	SEP.b #$30			; AXY->8
	INC.w !RAM_SMW_Pointer_CurrentOverworldProcess
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UnlockOverworldPathBasedOnExit(Address)
namespace SMW_UnlockOverworldPathBasedOnExit
%InsertMacroAtXPosition(<Address>)

UNK_0498FB:
	dw $0008,$0004,$0002,$0001		; Note: This table is identical to SMW_BitTable_Bank04, which is used by this routine.

Main:
	LDX.w !RAM_SMW_Misc_ExitLevelAction
	BEQ.b SMW_CalculateOverworldPlayerPosition_Return0498C5
	BMI.b SMW_CalculateOverworldPlayerPosition_Return0498C5
	DEX
	LDA.w SMW_SharedOverworldPathTables_DATA_049060,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	STZ.b !RAM_SMW_Misc_ScratchRAM09
	REP.b #$20			; A->16
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	TXA
	LSR
	LSR
	TAX
	JSR.w SMW_CalculateOverworldPlayerPosition_Main
	REP.b #$10			; XY->16
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.l !RAM_SMW_Overworld_LevelDirectionFlags,x
	AND.w #$00FF
	LDX.b !RAM_SMW_Misc_ScratchRAM08
	BEQ.b CODE_049949
CODE_049945:
	LSR
	DEX
	BPL.b CODE_049945
CODE_049949:
	AND.w #$0003
	ASL
	TAY
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x
	AND.w #$00FF
	TAX
	LDA.w SMW_BitTable_Bank04,y
	ORA.w !RAM_SMW_Overworld_LevelTileSettings,x
	STA.w !RAM_SMW_Overworld_LevelTileSettings,x
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldProcess03_StandingStill(Address)
namespace SMW_OverworldProcess03_StandingStill
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Flag_SwitchPlayers
	LDY.w !RAM_SMW_Overworld_EnterLevelFlag
	BMI.b OWPU_NotOnPipe
	LDA.w !RAM_SMW_Misc_ExitLevelAction
	BMI.b CODE_049132
	BEQ.b CODE_049132
	BRL.w CODE_0491E9

CODE_049132:
	LDA.b !RAM_SMW_IO_ControllerPress1
	AND.b #!Joypad_Select>>8
; DEBUG: Change to F0 to make player warp to Star Road if Select is pressed
; on top of Yoshi's House (tile 0x56).
#Debug_StarRoadWarp:
	BRA.b OW_Player_Update		; Change to BEQ to enable below debug code
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo	; \ Unreachable
	BEQ.b CODE_049165		; | Debug: Warp to star road from Yoshi's house
	CMP.b #$56
	BEQ.b CODE_049165
OW_Player_Update:
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
	LDA.b !RAM_SMW_IO_ControllerHold2	;! \
	AND.b #!Joypad_L|!Joypad_R	;! |If L and R aren't pressed,
	CMP.b #!Joypad_L|!Joypad_R	;! |branch to OWPU_NoLR
	BNE.b OWPU_NoLR			;! /
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo	;! \
	CMP.b #$81			;! |If Mario is standing on Destroyed Castle,
	BEQ.b OWPU_EnterLevel		;! / branch to OWPU_EnterLevel
OWPU_NoLR:
endif
	LDA.b !RAM_SMW_IO_ControllerPress1
	ORA.b !RAM_SMW_IO_ControllerPress2	; |If A, B, X or Y are pressed,
	AND.b #!Joypad_X|(!Joypad_Y>>8)|!Joypad_A|(!Joypad_B>>8)	; |branch to OWPU_ABXY
	BNE.b OWPU_ABXY			; |Otherwise,
	BRL.w CODE_0491E9		; / branch to $91E9

OWPU_ABXY:
	STZ.w !RAM_SMW_Flag_ChangeSubmapMusicOnPlayerSwitch
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	CMP.b #$5F			; |If not standing on a star tile,
	BNE.b OWPU_NotOnStar		; / branch to OWPU_NotOnStar
CODE_049165:
	JSR.w SMW_HandleOverworldStarPipeWarp_GetIndex
	BNE.b OWPU_IsOnPipeRTS
	STZ.w !RAM_SMW_Overworld_StarLaunchSpeed	; Set "Fly away" speed to 0
	STZ.w !RAM_SMW_Timer_WaitBeforeStarLaunch	; Set "Stay on ground" timer to 0 (31 = Fly away)
	LDA.b #!Define_SMW_Sound1DF9_GetCape	; \ Star Road sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #$0B			; \ Activate star warp
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	JMP.w SMW_OverworldProcess0B_StarWarpAnimation_Main

OWPU_NotOnStar:
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	CMP.b #$82			; |If standing on Pipe#1 (unused),
	BEQ.b OWPU_IsOnPipe		; / branch to OWPU_IsOnPipe
	CMP.b #$5B			; \ If not standing on Pipe#2,
	BNE.b OWPU_NotOnPipe		; / branch to OWPU_NotOnPipe
OWPU_IsOnPipe:
	JSR.w SMW_HandleOverworldStarPipeWarp_GetIndex
	BNE.b OWPU_IsOnPipeRTS
TriggerOverworldWarp:
	INC.w !RAM_SMW_Overworld_WarpingOnPipeOrStarFlag
	STZ.w !RAM_SMW_Misc_ExitLevelAction	; Set auto-walk to 0
	LDA.b #!Define_SMW_GameMode0B_FadeOutToOverworld	; \ Fade to overworld
	STA.w !RAM_SMW_Misc_GameMode
OWPU_IsOnPipeRTS:
	RTS

OWPU_NotOnPipe:
	CMP.b #$81
	BEQ.b CODE_0491E9		; |If standing on a tile >= (?) Destroyed Castle,
	BCS.b CODE_0491E9		; / branch to $91E9
OWPU_EnterLevel:
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR				; |If current player is Luigi,
	AND.b #$02			; |change Luigi's animation in the following lines
	TAX
	LDY.b #$10
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,x
	AND.b #$08			; |If Mario isn't swimming, use "raise hand" animation
	BEQ.b CODE_0491B1		; |Otherwise, use "raise hand, swimming" animation
	LDY.b #$12
CODE_0491B1:
	TYA
	STA.w !RAM_SMW_Overworld_MarioAnimationLo,x
	LDX.w !RAM_SMW_Player_CurrentCharacter	; Get current character
	; Loads Mario/Luigi's powerups, coins, Yoshies, and lives
	LDA.w !RAM_SMW_Player_MariosCoins,x	; \ Get character's coins
	STA.w !RAM_SMW_Player_CurrentCoinCount
	LDA.w !RAM_SMW_Player_MariosLives,x	; \ Get character's lives
	STA.w !RAM_SMW_Player_CurrentLifeCount
	LDA.w !RAM_SMW_Player_MariosPowerUp,x	; \ Get character's powerup
	STA.b !RAM_SMW_Player_CurrentPowerUp
	LDA.w !RAM_SMW_Player_MariosYoshi,x
	STA.w !RAM_SMW_Yoshi_CarryOverLevelsFlag	; |Get character's Yoshi color
	STA.w !RAM_SMW_Yoshi_CurrentYoshiColor
	STA.w !RAM_SMW_Player_RidingYoshiFlag
	LDA.w !RAM_SMW_Player_MariosItemBox,x	; \ Get character's reserved item
	STA.w !RAM_SMW_Player_CurrentItemBox
	LDA.b #$02			; \ Related to fade speed
	STA.w !RAM_SMW_Timer_KeepGameModeActive
	LDA.b #!Define_SMW_LevelMusic_MusicFade	; \ Music fade out
	STA.w !RAM_SMW_IO_MusicCh1
	INC.w !RAM_SMW_Misc_GameMode	; Fade to level
	RTS

CODE_0491E9:
	REP.b #$20			; A->16
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo	; Get current character * 4
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x	; Get character's X coordinate
	LSR
	LSR				; |Divide X coordinate by 16
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00	; \ Store in $00 and $1F1F,x
	STA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x	; Get character's Y coordinate
	LSR
	LSR				; |Divide Y coordinate by 16
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM02	; \ Store in $02 and $1F21,x
	STA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	TXA
	LSR				; |Divide (current character * 4) by 4
	LSR
	TAX
	JSR.w SMW_CalculateOverworldPlayerPosition_Main	; Calculate current tile pos
	SEP.b #$20			; A->8
	LDX.w !RAM_SMW_Misc_ExitLevelAction	; \ If auto-walk=0,
	BEQ.b OWPU_NotAutoWalk		; / branch to OWPU_NotAutoWalk
	DEX
	LDA.w SMW_SharedOverworldPathTables_DATA_049060,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	STZ.b !RAM_SMW_Misc_ScratchRAM09
	REP.b #$30			; AXY->16
	LDX.b !RAM_SMW_Misc_ScratchRAM04	; X = tile pos
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x	; \ Get level number of current tile pos
	AND.w #$00FF
	LDY.w #$000A
CODE_04922A:
	CMP.w SMW_SharedOverworldPathTables_NoAutoMoveLevels,y
	BNE.b CODE_04923B
	LDA.w #$0005
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	JSR.w SMW_UpdateSaveBuffer_Main
	BRL.w CODE_049411

CODE_04923B:
	DEY
	DEY
	BPL.b CODE_04922A
	LDA.l !RAM_SMW_Overworld_LevelDirectionFlags,x
	AND.w #$00FF
	LDX.b !RAM_SMW_Misc_ScratchRAM08
	BEQ.b CODE_04924E
CODE_04924A:
	LSR
	DEX
	BPL.b CODE_04924A
CODE_04924E:
	AND.w #$0003
	ASL
	TAX
	LDA.w SMW_SharedOverworldPathTables_DATA_049064,x
	TAY
	JMP.w CODE_0492BC

OWPU_NotAutoWalk:
	SEP.b #$30			; AXY->8
	STZ.w !RAM_SMW_Misc_ExitLevelAction	; Set auto-walk to 0
	LDA.b !RAM_SMW_IO_ControllerPress1
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)|(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)	; |If no dir button is pressed (one frame),
	BEQ.b CODE_04926E		; / branch to $926E
	LDX.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	CPX.b #$82			; |If standing on Pipe#2,
	BEQ.b CODE_0492AD		; |branch to $92AD
	BRA.b CODE_04928C		; / Otherwise, branch to $928C

CODE_04926E:
	DEC.w !RAM_SMW_Overworld_MakeStandingPlayerFaceDownTimerLo	; \ Decrease "Face walking dir" timer
	BPL.b CODE_049287		; / If >= 0, branch to $9287
	STZ.w !RAM_SMW_Overworld_MakeStandingPlayerFaceDownTimerLo	; Set "Face walking dir" timer to 0
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR				; |Set X to current character * 2
	AND.b #$02
	TAX
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,x
	AND.b #$08			; |Set current character's animation to "facing down"
	ORA.b #$02			; |or "facing down in water", depending on if character
	STA.w !RAM_SMW_Overworld_MarioAnimationLo,x	; / is in water or not.
CODE_049287:
	REP.b #$30			; AXY->16
	JMP.w SMW_OverworldProcess04_PlayerIsMoving_CODE_049831

CODE_04928C:
	REP.b #$30			; AXY->16
	AND.w #$00FF			;  Clears out the high byte of A, since we just switched to 16-bit mode.
; If you replace this with "4C AF 92" (JMP $92AF), it will enable to walk in
; unrevealed paths on the overworld. (But it will not work correctly with
; star road warps)
#Debug_WalkOnUnrevealedOWPaths:
	NOP #3
	PHA				;\
	STZ.b !RAM_SMW_Misc_ScratchRAM06	; |
	LDX.b !RAM_SMW_Misc_ScratchRAM04	; | This has the 16-bit offset to the current tile.
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x	; | Retrieve the level number for the current tile.
	AND.w #$00FF			; |
	TAX				; |
	PLA				;/
	AND.w !RAM_SMW_Overworld_LevelTileSettings,x
	AND.w #$000F
	BNE.b CODE_0492AD
	JMP.w CODE_049411

CODE_0492AD:
	REP.b #$30			; AXY->16
	AND.w #$00FF
CODE_0492B2:
	LDY.w #$0006
CODE_0492B5:
	LSR
	BCS.b CODE_0492BC
	DEY
	DEY
	BPL.b CODE_0492B5
CODE_0492BC:
	TYA
	STA.w !RAM_SMW_Overworld_PlayerDirection	; Store the direction for later.
	LDX.w #$0000			;\  Put 0 into X if we're moving vertically
	CPY.w #$0004			; | Otherwise, put 2 into X
	BCS.b CODE_0492CB		; |
	LDX.w #$0002			;/
CODE_0492CB:
	LDA.b !RAM_SMW_Misc_ScratchRAM04	;\  Preserve our current tile offset, as
	STA.b !RAM_SMW_Misc_ScratchRAM08	;/  we are about to overwrite it.
	LDA.b !RAM_SMW_Misc_ScratchRAM00,x
	CLC
	ADC.w SMW_SharedOverworldPathTables_DATA_049058,y
	STA.b !RAM_SMW_Misc_ScratchRAM00,x
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAX
	JSR.w SMW_CalculateOverworldPlayerPosition_Main
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	BMI.b CODE_049301
	CMP.w #$0800
	BCS.b CODE_049301
	LDA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$00),x
	AND.w #$00FF
	BEQ.b CODE_049301
	CMP.w #$0056
	BCC.b CODE_0492FE
	CMP.w #$0087
	BCC.b CODE_0492FE
	BRA.b CODE_049301

CODE_0492FE:
	BRL.w CODE_049384

CODE_049301:
	STZ.w !RAM_SMW_Overworld_ProcessHardcodedPathFlagLo
	STZ.w !RAM_SMW_Overworld_HardcodedPathIndexLo
	LDX.b !RAM_SMW_Misc_ScratchRAM08	;\  Retrieve the tile offset for our current tile (we stored it earlier)
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x	; | and get the level number for that tile.
	AND.w #$00FF			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/  Store it in $00 for later.
	LDX.w #$0009			;   Initialize the loop. Looping over 10 elements.
CODE_049315:
	LDA.w SMW_SharedOverworldPathTables_HardCodedOWPaths_LevelNums,x	;\  LOOP START
	AND.w #$00FF			; | Load the level number we want to test.
	CMP.w #$00FF			; | If that level is 0xFF, we need to do special logic.
	BNE.b CODE_049349		;/  Otherwise, do the normal stuff.
	PHX
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x
	CMP.w SMW_SharedOverworldPathTables_DATA_049082			; Optimization: Why not just put the $0178 here? Maybe this was originally a loop?
	BNE.b CODE_049346
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x
	CMP.w SMW_SharedOverworldPathTables_DATA_049084			; Optimization: Same as above, except the bytes are $0128.
	BNE.b CODE_049346
	LDA.w !RAM_SMW_Player_CurrentCharacter
	AND.w #$00FF
	TAX
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	AND.w #$00FF
	BNE.b CODE_049346						; Note: !Define_SMW_Overworld_MainMap
	PLX
	BRA.b CODE_04934D

CODE_049346:
	PLX
	BRA.b CODE_049374

CODE_049349:
	CMP.b !RAM_SMW_Misc_ScratchRAM00	;\  Register A has the level number from the hardcoded list. We compare this to
	BNE.b CODE_049374		;/  the current level number we stored earlier. If it matches, we break the loop.
CODE_04934D:
	STX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w SMW_SharedOverworldPathTables_HardCodedOWPaths_Layer1AndMovementTableIndex,x	;\  Register X has the index into the list of hardcoded path levels.
	AND.w #$00FF			; | We use it to index a list of offsets for those levels. The offset
	TAX				; | tells us where that level's tile information is.
	DEC				; |
	STA.w !RAM_SMW_Overworld_HardcodedPathIndexLo	;/  Store the offset for use in code that walks the list of tiles.
	STY.b !RAM_SMW_Misc_ScratchRAM02	;\  Reminder: Y is the movement direction.
	LDA.w SMW_SharedOverworldPathTables_HardCodedOWPaths_MovementDirection,x	; | This is a list of the directions for each of the path tiles along the hardcoded path.
	AND.w #$00FF			; |
	CMP.b !RAM_SMW_Misc_ScratchRAM02	; |
	BNE.b CODE_04937A		;/  Exit if the tile doesn't use the same direction as we're trying to use. This breaks the loop entirely.
	LDA.w #$0001			;\  We are now committed to a hard-coded path.
	STA.w !RAM_SMW_Overworld_ProcessHardcodedPathFlagLo	;/  Store that fact now.
	LDA.w SMW_SharedOverworldPathTables_HardCodedOWPaths_Layer1Tiles,x	;\  Fetch the next tile.
	AND.w #$00FF			; |
	BRA.b CODE_049384		;/  Break out of the loop

CODE_049374:
	DEX				;\  Do the actual looping. X is the counter.
	BMI.b CODE_04937A		; |
	BRL.w CODE_049315		;/

CODE_04937A:
	SEP.b #$20			; A->8
	STZ.w !RAM_SMW_Misc_ExitLevelAction
	REP.b #$20			; A->16
	JMP.w CODE_049411

CODE_049384:
	STA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo	;\  Register A has the destination tile number.
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	STZ.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDX.w #$0017			; Initialize the loop.
CODE_04938E:
	LDA.w SMW_SharedOverworldPathTables_DATA_04A03C,x
	AND.w #$00FF
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_0493B5
	LDA.w SMW_SharedOverworldPathTables_DATA_04A0E4,x	;\  We are computing a "bitfield". If the bit 0x2 is set, then the value we set into $00 should be
	CLC				; | taken as the Y offset instead of the X offset. The bit 0x4 comes from $0DD6, which selects
	ADC.w !RAM_SMW_Player_CurrentCharacterX4Lo	; | Mario vs. Luigi. The X vs. Y is a property of the tile.
	PHA				;/
	TXA
	ASL
	ASL
	TAX
	LDA.w SMW_SharedOverworldPathTables_DATA_04A084,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w SMW_SharedOverworldPathTables_DATA_04A084+$02,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PLA
	AND.w #$00FF
	TAX
	BRA.b CODE_0493DA

CODE_0493B5:
	DEX				;\ Decrement counter and loop.
	BPL.b CODE_04938E		;/
	LDX.w #$0008
	TYA
	AND.w #$0002
	BNE.b CODE_0493C7
	TXA
	EOR.w #$FFFF
	INC
	TAX
CODE_0493C7:
	STX.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w #$0000
	CPY.w #$0004
	BCS.b CODE_0493D4
	LDX.w #$0002
CODE_0493D4:
	TXA
	CLC
	ADC.w !RAM_SMW_Player_CurrentCharacterX4Lo
	TAX
CODE_0493DA:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\  Apply the offsets to the current sprites position,
	CLC				; | and set those as the desiered position.
	ADC.w !RAM_SMW_Overworld_MarioXPosLo,x	; |
	STA.w !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo,x	; |
	TXA				; |
	EOR.w #$0002			; |
	TAX				; |
	LDA.b !RAM_SMW_Misc_ScratchRAM02	; |
	CLC				; |
	ADC.w !RAM_SMW_Overworld_MarioXPosLo,x	; |
	STA.w !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo,x	;/
	TXA				;\  Set the character's facing in the direction that the user pressed (still in Y).
	LSR				; |
	AND.w #$0002			; |
	TAX				; |
	TYA				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,x	; |
	AND.w #$0008			; |
	ORA.b !RAM_SMW_Misc_ScratchRAM00	; |
	STA.w !RAM_SMW_Overworld_MarioAnimationLo,x	;/
	LDA.w #$000F
	STA.w !RAM_SMW_Overworld_MakeStandingPlayerFaceDownTimerLo
	INC.w !RAM_SMW_Pointer_CurrentOverworldProcess
	STZ.w !RAM_SMW_Overworld_PlayerIsSteppingOnLevelTileFlagLo
CODE_049411:
	JMP.w SMW_OverworldProcess04_PlayerIsMoving_CODE_049831
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_OverworldProcess04_PlayerIsMoving(Address)
namespace SMW_OverworldProcess04_PlayerIsMoving
%InsertMacroAtXPosition(<Address>)

; List of layer 1 overworld tiles that allow mario to walk from one map to
; another ("exit level tiles" in lunar magic)
DATA_049426:
	db $44,$43,$45,$46,$47,$48,$25,$40
	db $42,$4D

DATA_049430:
	db $0C,$00,$0E,$00,$10,$06,$12,$00
	db $18,$04,$1A,$02,$20,$06,$42,$06
	db $4E,$04,$50,$02,$58,$06,$5A,$00
	db $70,$06,$90,$00,$A0,$06

DATA_04944E:
	db $01,$01,$00,$01,$01,$00,$00,$00
	db $01,$00,$00,$01,$00,$01,$00

Main:
	LDA.w !RAM_SMW_Flag_SwitchPlayers
	BEQ.b CODE_049468
	LDA.b #$08
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	RTS

CODE_049468:
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	CLC
	ADC.w #$0002
	TAY
	LDX.w #$0002
CODE_049475:
	LDA.w !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo,y
	SEC
	SBC.w !RAM_SMW_Overworld_MarioXPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00,x
	BPL.b CODE_049484
	EOR.w #$FFFF
	INC
CODE_049484:
	STA.b !RAM_SMW_Misc_ScratchRAM04,x
	DEY
	DEY
	DEX
	DEX
	BPL.b CODE_049475
	LDY.w #$FFFF
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	BCC.b CODE_0494A4
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDY.w #$0001
CODE_0494A4:
	STY.b !RAM_SMW_Misc_ScratchRAM08
	SEP.b #$20			; A->8
	LDX.w !RAM_SMW_Overworld_PlayerOnClimbingTileLo
	LDA.w OWPlayerPathSpeedOffset,x
	ASL
	ASL
	ASL
	ASL
if defined("Define_SMW_SA1")
	JML.l overworld_mulfixv2
	NOP #38
else
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	BEQ.b CODE_0494DA
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	REP.b #$20			; A->16
	LDA.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	STA.w !REGISTER_DividendLo	; Dividend (Low Byte)
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	STA.w !REGISTER_Divisor		; Divisor B
	NOP #6
	REP.b #$20			; A->16
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
CODE_0494DA:
	REP.b #$20			; A->16
endif
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDX.w !RAM_SMW_Overworld_PlayerOnClimbingTileLo
	LDA.w OWPlayerPathSpeedOffset,x
	AND.w #$00FF
	ASL
	ASL
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDX.w #$0002
CODE_0494F0:
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	BMI.b CODE_0494F8
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	BRA.b CODE_0494FA

CODE_0494F8:
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_0494FA:
	BIT.b !RAM_SMW_Misc_ScratchRAM00,x
	BPL.b CODE_049502
	EOR.w #$FFFF
	INC
CODE_049502:
	STA.w !RAM_SMW_Player_OverworldXSpeedLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	EOR.w #$FFFF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM08
	DEX
	DEX
	BPL.b CODE_0494F0
	LDX.w #$0000
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	BMI.b CODE_04951B
	LDX.w #$0002
CODE_04951B:
	LDA.b !RAM_SMW_Misc_ScratchRAM00,x
	BEQ.b CODE_049522
	JMP.w CODE_049801

CODE_049522:
	LDA.w !RAM_SMW_Overworld_PlayerIsSteppingOnLevelTileFlagLo
	BEQ.b CODE_04955C
	STZ.w !RAM_SMW_Overworld_ProcessHardcodedPathFlagLo
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TXA
	LSR
	LSR
	TAX
	JSR.w SMW_CalculateOverworldPlayerPosition_Main
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x
	AND.w #$00FF
#LM000Hijack_CustomLevelNames2:
	ASL								;\ LM: NOPs out and inserts a JSL.l to $03BB20 to enable having custom level names.
	TAX								;|
	LDA.w SMW_LevelNames_Main,x					;|
	STA.b !RAM_SMW_Misc_ScratchRAM00				;|
	JSR.w SMW_UpdateLevelName_Main					;/
	INC.w !RAM_SMW_Pointer_CurrentOverworldProcess
	JSR.w SMW_UpdateSaveBuffer_Main
	JMP.w CODE_049831

CODE_04955C:
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	STA.w !RAM_SMW_CopyOfTilePlayerIsStandingdOnLo
	LDA.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDY.w !RAM_SMW_Overworld_PlayerDirection
	TYA
	AND.w #$00FF
	EOR.w #$0002
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	BRA.b CODE_049582

ADDR_049575:
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	SEC
	SBC.w #$0002
	STA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.b !RAM_SMW_Misc_ScratchRAM0A
	BEQ.b ADDR_049575
	TAY
CODE_049582:
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.w #$0000
	CPY.w #$0004
	BCS.b CODE_04959A
	LDX.w #$0002
CODE_04959A:
	LDA.b !RAM_SMW_Misc_ScratchRAM00,x
	CLC
	ADC.w SMW_SharedOverworldPathTables_DATA_049058,y
	STA.b !RAM_SMW_Misc_ScratchRAM00,x
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAX
	JSR.w SMW_CalculateOverworldPlayerPosition_Main
	LDA.w !RAM_SMW_Overworld_ProcessHardcodedPathFlagLo
	BEQ.b CODE_0495CE
	STY.b !RAM_SMW_Misc_ScratchRAM06
	LDX.w !RAM_SMW_Overworld_HardcodedPathIndexLo
	INX
	LDA.w SMW_SharedOverworldPathTables_HardCodedOWPaths_MovementDirection,x
	AND.w #$00FF
	CMP.b !RAM_SMW_Misc_ScratchRAM06
	BNE.b ADDR_049575
	STX.w !RAM_SMW_Overworld_HardcodedPathIndexLo
	LDA.w SMW_SharedOverworldPathTables_HardCodedOWPaths_Layer1Tiles,x
	AND.w #$00FF
	CMP.w #$0058
	BNE.b CODE_0495DE
CODE_0495CE:
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	BMI.b ADDR_049575
	CMP.w #$0800
	BCS.b ADDR_049575
	LDA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$00),x	; \ Load OW tile number
	AND.w #$00FF
CODE_0495DE:
	STA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo	; Set "Current OW tile"
	BEQ.b ADDR_049575
	CMP.w #$0087
	BCS.b ADDR_049575
	PHA
	PHY
	TAX
	DEX
	LDY.w #$0000
	LDA.w SMW_SharedOverworldPathTables_DATA_049FEB,x
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	AND.w #$00FF
	CMP.w #$0014
	BNE.b CODE_0495FF
	LDY.w #$0001
CODE_0495FF:
	STY.w !RAM_SMW_Overworld_PlayerOnClimbingTileLo
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	PLY
	PLA
	PHA
	SEP.b #$30			; AXY->8
	LDX.b #$09
CODE_049616:
	CMP.w DATA_049426,x
	BNE.b CODE_049645
	PHY
	JSR.w SMW_HandleOverworldPathExits_Main
	PLY
	LDA.b #$01
	STA.w !RAM_SMW_Flag_ChangeSubmapMusicOnPlayerSwitch
	JSR.w SMW_OverworldPrompt01_InitializeOverworldPrompt_CODE_04F407
	STZ.w !RAM_SMW_Overworld_HDMATransitionEffectFlag
	REP.b #$20			; A->16
	STZ.w !RAM_SMW_Palettes_BackgroundColorLo
	LDA.w #$7000
	STA.w !RAM_SMW_Overworld_HDMATransitionEffectXPosLo
	LDA.w #$5400
	STA.w !RAM_SMW_Overworld_HDMATransitionEffectYPosLo
	SEP.b #$20			; A->8
	LDA.b #$0A
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	BRA.b CODE_049648

CODE_049645:
	DEX
	BPL.b CODE_049616
CODE_049648:
	REP.b #$30			; AXY->16
	PLA
	PHA
	CMP.w #$0056
	BCS.b CODE_049654
	JMP.w CODE_04971D

CODE_049654:
	CMP.w #$0080
	BEQ.b CODE_049663
	CMP.w #$006A
	; Change to 80 (BRA) to make Mario stand on OW tiles 6A through 6D, instead
	; of swimming through them.
	BCC.b CODE_049676
	CMP.w #$006E
	BCS.b CODE_049676
CODE_049663:
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	AND.w #$0002
	TAX
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,x
	ORA.w #$0008
	STA.w !RAM_SMW_Overworld_MarioAnimationLo,x
	BRA.b CODE_049687

CODE_049676:
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	AND.w #$0002
	TAX
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,x
	AND.w #$00F7
	STA.w !RAM_SMW_Overworld_MarioAnimationLo,x
CODE_049687:
	LDA.w #$0001
	STA.w !RAM_SMW_Overworld_PlayerIsSteppingOnLevelTileFlagLo
	; Code that handles what overworld tiles don't play a SFX when stepped on.
	; The tile numbers are used in 16-bit. $04968D - Change [AD C1] to [80 10]
	; to make overworld star/pipe tiles play the "beep" sound when stepped on.
	; $0496A0 - Sound effect that plays when Mario steps on a level tile.
	; Change to 00 to disable.
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	CMP.w #$005F
	BEQ.b CODE_0496A5
	CMP.w #$005B
	BEQ.b CODE_0496A5
	CMP.w #$0082
	BEQ.b CODE_0496A5
	; Replace [A9 23 00 8D FC 1D] with [EA EA EA EA EA EA] to disable the
	; "beep" when Mario moves onto a level tile.
	LDA.w #!Define_SMW_Sound1DFC_StepOnLevelTile
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
CODE_0496A5:
	NOP #3										; Optimization: Junk
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	AND.w #$00FF
	CMP.w #$0082
	BEQ.b CODE_0496D2
	PHY
	TYA
	AND.w #$00FF
	EOR.w #$0002
	TAY
	STZ.b !RAM_SMW_Misc_ScratchRAM06
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x
	AND.w #$00FF
	TAX
	LDA.w SMW_BitTable_Bank04,y
	ORA.w !RAM_SMW_Overworld_LevelTileSettings,x
	STA.w !RAM_SMW_Overworld_LevelTileSettings,x
	PLY
CODE_0496D2:
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	AND.w #$0002
	TAX
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,x
	AND.w #$000C
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_CopyOfTilePlayerIsStandingdOnLo
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w #$0017
CODE_0496F2:
	LDA.w SMW_SharedOverworldPathTables_DATA_04A03C,x
	AND.w #$00FF
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_049704
	TXA
	ASL
	TAX
	LDA.w SMW_SharedOverworldPathTables_DATA_04A054,x
	BRA.b CODE_049718

CODE_049704:
	DEX
	BPL.b CODE_0496F2
	LDA.w #$0000					;\ Optimization: What's wrong with using LDA.w #$0800?
	ORA.w #$0800					;/
	CPY.w #$0004
	BCC.b CODE_049718
	LDA.w #$0000					;\ Optimization: With the above optimization, this could then be an XBA.
	ORA.w #$0008					;/
CODE_049718:
	LDX.w #$0000
	BRA.b CODE_049728

CODE_04971D:
	DEC
	ASL
	TAX
	LDA.w SMW_SharedOverworldPathTables_DATA_049F49,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w SMW_SharedOverworldPathTables_DATA_049EA7,x
CODE_049728:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	TXA
	SEP.b #$20			; A->8
	LDX.w #$001C
CODE_049730:
	CMP.w DATA_049430,x
	BEQ.b CODE_04973B
	DEX
	DEX
	BPL.b CODE_049730
	BRA.b CODE_04974A

CODE_04973B:
	TYA
	CMP.w DATA_049430+$01,x
	BEQ.b CODE_04974A
	TXA
	LSR
	TAX
	LDA.w DATA_04944E,x
	TAX
	BRA.b CODE_049755

CODE_04974A:
	LDX.w #$0000
	TYA
	AND.b #$02
	BEQ.b CODE_049755
	LDX.w #$0001					; Optimization: INX?
CODE_049755:
	LDA.b !RAM_SMW_Misc_ScratchRAM04,x
	BEQ.b CODE_049767
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM01
CODE_049767:
	REP.b #$20			; A->16
	PLA
	LDX.w #$0000
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	AND.w #$0007
	BNE.b CODE_049777
	LDX.w #$0001					; Optimization: INX?
CODE_049777:
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM00,x
	AND.w #$00FF
	CMP.w #$0080
	BCS.b CODE_049790
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CLC
	ADC.w #$0002
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_049790:
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	AND.w #$0002
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !RAM_SMW_Overworld_MarioAnimationLo,x
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$00FF
	CMP.w #$0080
	BCC.b CODE_0497AD
	ORA.w #$FF00
CODE_0497AD:
	CLC
	ADC.w !RAM_SMW_Overworld_MarioXPosLo,x
	AND.w #$FFFC
	STA.w !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	AND.w #$00FF
	CMP.w #$0080
	BCC.b CODE_0497C4
	ORA.w #$FF00
CODE_0497C4:
	CLC
	ADC.w !RAM_SMW_Overworld_MarioYPosLo,x
	AND.w #$FFFC
	STA.w !RAM_SMW_Player_OverworldYPosMarioIsGoingToLo,x
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo,x
	AND.b #$0F
	BNE.b CODE_0497E3
	LDY.w #$0004
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BMI.b CODE_0497E1
	LDY.w #$0006
CODE_0497E1:
	BRA.b CODE_0497F4

CODE_0497E3:
	LDA.w !RAM_SMW_Player_OverworldYPosMarioIsGoingToLo,x
	AND.b #$0F
	BNE.b CODE_0497F4
	LDY.w #$0000
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BMI.b CODE_0497F4
	LDY.w #$0002
CODE_0497F4:
	STY.w !RAM_SMW_Overworld_PlayerDirection
	LDA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	CMP.b #$0A
	BEQ.b CODE_049831
	JMP.w SMW_OverworldProcess04_PlayerIsMoving_Main

CODE_049801:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	CLC
	ADC.w #$0002
	TAX
	LDY.w #$0002
CODE_04980E:
	LDA.w !RAM_SMW_Player_OverworldSubXPosLo,y
	AND.w #$00FF
	CLC
	ADC.w !RAM_SMW_Player_OverworldXSpeedLo,y
	STA.w !RAM_SMW_Player_OverworldSubXPosLo,y
	AND.w #$FF00
	BPL.b CODE_049823
	ORA.w #$00FF
CODE_049823:
	XBA
	CLC
	ADC.w !RAM_SMW_Overworld_MarioXPosLo,x
	STA.w !RAM_SMW_Overworld_MarioXPosLo,x
	DEX
	DEX
	DEY
	DEY
	BPL.b CODE_04980E
; Handles moving the camera when Mario moves on the overworld. Checks
; against the scroll bounds of the overworld at $049416. Does not move the
; camera when the Valley of Bowser earthquake ($7E1BA0) is happening, or
; when the player is on a submap.
CODE_049831:
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	CMP.b #$0A
	BEQ.b CODE_049882
	LDA.w !RAM_SMW_Overworld_ActiveEarthquakeEvent
	BNE.b CODE_049882
CODE_04983F:
	REP.b #$30			; AXY->16
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TXA
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	AND.w #$00FF
	BNE.b CODE_049882						; Note: !Define_SMW_Overworld_MainMap
	LDX.w #$0002
	TXY
CODE_04985E:
	LDA.b !RAM_SMW_Misc_ScratchRAM00,x
	SEC
	SBC.w #$0080
	BPL.b CODE_049870
	CMP.w MaxOverworlCameraPosition_LeftAndTop,y
	BCS.b CODE_049878
	LDA.w MaxOverworlCameraPosition_LeftAndTop,y
	BRA.b CODE_049878

CODE_049870:
	CMP.w MaxOverworlCameraPosition_RightAndBottom,y
	BCC.b CODE_049878
	LDA.w MaxOverworlCameraPosition_RightAndBottom,y
CODE_049878:
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo,x
	DEY
	DEY
	DEX
	DEX
	BPL.b CODE_04985E
CODE_049882:
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_OverworldProcess04_PlayerIsMoving(Address)
namespace SMW_OverworldProcess04_PlayerIsMoving
%InsertMacroAtXPosition(<Address>)

; Speed of Mario on the OW (Higher = faster). First byte is normal ground,
; second is stairs.
OWPlayerPathSpeedOffset:
	db $0D,$08

; Max range for overworld scrolling when walking. 16-bit. Order: left, top,
; right, bottom. Due to a discrepancy between these values and the values in
; $048221, free scrolling can scroll the overworld 1 pixel lower than
; walking down can.
MaxOverworlCameraPosition:
.LeftAndTop:
	dw $FFEF,$FFD7

.RightAndBottom:
	dw $0111,$0131
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldProcess05_CheckForPlayerSwitch(Address)
namespace SMW_OverworldProcess05_CheckForPlayerSwitch
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Flag_TwoPlayerGame
	BEQ.b CODE_049DAF
	LDA.w !RAM_SMW_Player_CurrentCharacter
	EOR.b #$01
	TAX
	LDA.w !RAM_SMW_Player_MariosLives,x
	BMI.b CODE_049DAF
	LDA.w !RAM_SMW_Misc_ExitLevelAction
	BNE.b CODE_049DBC
CODE_049DAF:
	LDA.b #$03
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	STZ.w !RAM_SMW_Misc_ExitLevelAction
	REP.b #$30			; AXY->16
	JMP.w SMW_OverworldProcess04_PlayerIsMoving_CODE_049831

CODE_049DBC:
	DEC.w !RAM_SMW_Timer_KeepGameModeActive
	BPL.b CODE_049DCC
	LDA.b #$02
	STA.w !RAM_SMW_Timer_KeepGameModeActive
	STZ.w !RAM_SMW_Misc_ExitLevelAction
	INC.w !RAM_SMW_Pointer_CurrentOverworldProcess
CODE_049DCC:
	REP.b #$30			; AXY->16
	JMP.w SMW_OverworldProcess04_PlayerIsMoving_CODE_049831
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldProcess06_PlayerSwitchFadeOut(Address)
namespace SMW_OverworldProcess06_PlayerSwitchFadeOut
%InsertMacroAtXPosition(<Address>)

Main:
	DEC.w !RAM_SMW_Timer_KeepGameModeActive
	BPL.b Return049E4B
	LDA.b #$02
	STA.w !RAM_SMW_Timer_KeepGameModeActive
	LDX.w !RAM_SMW_Misc_MosaicDirection
	LDA.w !RAM_SMW_Mirror_ScreenDisplayRegister
	CLC
	ADC.l SMW_GameModeXX_FadeInOrOut_DATA_009F2F,x
	STA.w !RAM_SMW_Mirror_ScreenDisplayRegister
	CMP.l SMW_GameModeXX_FadeInOrOut_DATA_009F33,x
	BNE.b Return049E4B
	INC.w !RAM_SMW_Pointer_CurrentOverworldProcess
	LDA.w !RAM_SMW_Misc_MosaicDirection
	EOR.b #$01
	STA.w !RAM_SMW_Misc_MosaicDirection
Return049E4B:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_OverworldProcess06_PlayerSwitchFadeOut_Main, SMW_OverworldProcess08_PlayerSwitchFadeIn_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldProcess07_SwitchingPlayers(Address)
namespace SMW_OverworldProcess07_SwitchingPlayers
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Player_CurrentCharacter
	EOR.b #$01
	STA.w !RAM_SMW_Player_CurrentCharacter
	TAX
	LDA.w !RAM_SMW_Player_MariosCoins,x
	STA.w !RAM_SMW_Player_CurrentCoinCount
	LDA.w !RAM_SMW_Player_MariosLives,x
	STA.w !RAM_SMW_Player_CurrentLifeCount
	LDA.w !RAM_SMW_Player_MariosPowerUp,x
	STA.b !RAM_SMW_Player_CurrentPowerUp
	LDA.w !RAM_SMW_Player_MariosYoshi,x
	STA.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	STA.w !RAM_SMW_Yoshi_CurrentYoshiColor
	STA.w !RAM_SMW_Player_RidingYoshiFlag
	LDA.w !RAM_SMW_Player_MariosItemBox,x
	STA.w !RAM_SMW_Player_CurrentItemBox
	JSL.l SMW_LoadOverworldLifeCounter_Main
	REP.b #$20			; A->16
	JSR.w SMW_GameMode0C_LoadOverworld_CODE_048E55
	SEP.b #$20			; A->8
	LDX.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	STA.w !RAM_SMW_Overworld_CurrentlyLoadedSubmapLo
	STZ.w !RAM_SMW_Overworld_CurrentlyLoadedSubmapHi
	LDA.b #$02
	STA.w !RAM_SMW_Timer_KeepGameModeActive
	LDA.b #$0A
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	INC.w !RAM_SMW_Flag_SwitchPlayers
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldProcess09_FinishedSwitchingPlayers(Address)
namespace SMW_OverworldProcess09_FinishedSwitchingPlayers
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$03
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldProcess0B_StarWarpAnimation(Address)
namespace SMW_OverworldProcess0B_StarWarpAnimation
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Overworld_StarLaunchSpeed
	BNE.b CODE_049E63
	INC.w !RAM_SMW_Timer_WaitBeforeStarLaunch
	LDA.w !RAM_SMW_Timer_WaitBeforeStarLaunch
	CMP.b #$31
	BNE.b CODE_049E93
	BRA.b CODE_049E69

CODE_049E63:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	BNE.b CODE_049E78
CODE_049E69:
	INC.w !RAM_SMW_Overworld_StarLaunchSpeed
	LDA.w !RAM_SMW_Overworld_StarLaunchSpeed
	CMP.b #$05
	BNE.b CODE_049E78
	LDA.b #$04
	STA.w !RAM_SMW_Overworld_StarLaunchSpeed
CODE_049E78:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Overworld_StarLaunchSpeed
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Overworld_MarioYPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	BMI.b CODE_049E96						;\ Optimization: Save two bytes by removing one of the SEP.b #$20s and putting the remaining one before this line.
CODE_049E93:								;|
	SEP.b #$20							;|
	RTS								;|
									;|
CODE_049E96:								;|
	SEP.b #$20							;/
	JMP.w SMW_OverworldProcess03_StandingStill_TriggerOverworldWarp
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldProcess0C_IntroMarch(Address)				; LM: This routine is unused in hacked ROMs if Mario is moved on the overworld.
namespace SMW_OverworldProcess0C_IntroMarch
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Overworld_MarioAnimationLo
	LDA.b #$80
	CLC
	ADC.w !RAM_SMW_Player_OverworldSubYPosLo
	STA.w !RAM_SMW_Player_OverworldSubYPosLo
	PHP
	LDA.b #$0F
	CMP.b #$08
	LDY.b #$00
	BCC.b CODE_0498DE
	ORA.b #$F0
	DEY
CODE_0498DE:
	PLP
	ADC.w !RAM_SMW_Overworld_MarioYPosLo
	STA.w !RAM_SMW_Overworld_MarioYPosLo
	TYA
	ADC.w !RAM_SMW_Overworld_MarioYPosHi
	STA.w !RAM_SMW_Overworld_MarioYPosHi
	LDA.w !RAM_SMW_Overworld_MarioYPosLo
	CMP.b #$78
	BNE.b Return0498FA
	STZ.w !RAM_SMW_Pointer_CurrentOverworldProcess
	JSL.l SMW_SaveGame_Main
Return0498FA:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OverworldProcess01_ActivateEvents(Address)
namespace SMW_OverworldProcess01_ActivateEvents
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Pointer_OverworldEventProcess
	JSL.l SMW_ExecutePtr_Absolute

; Pointer to locations in the routine that runs events.
Ptrs04E577:
	dw SMW_OverworldEventProcess00_CheckIfEventShouldRun_Main
	dw SMW_OverworldEventProcess01_DestroyTileAnimation_Main
	dw SMW_OverworldEventProcess02_SetEventTileIndexes_Main
	dw SMW_OverworldEventProcess03_GetLayer2Tile_Main
	dw SMW_OverworldEventProcess04_FadeInLayer2Tile_Main
	dw SMW_OverworldEventProcess05_GetLayer1Tile_Main
	dw SMW_OverworldEventProcess06_FadeInLayer1Tile_Main
	dw SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent_Main
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldEventProcess00_CheckIfEventShouldRun(Address)
namespace SMW_OverworldEventProcess00_CheckIfEventShouldRun
%InsertMacroAtXPosition(<Address>)

DATA_04E5E6:
	%INLINEDATATABLE_SMW_SavePromptLevels()

; Subroutine that runs events at level end.
Main:
	LDA.w !RAM_SMW_Misc_ExitLevelAction	; Accum (8 bit)  ;\ If player got the secret exit
	CMP.b #$02			;| increment OW event to activate by one
	BNE.b CODE_04E5F8
	INC.w !RAM_SMW_Overworld_CurrentEventNumber
CODE_04E5F8:
	LDA.w !RAM_SMW_Overworld_CheckIfEventPassedFlag			;\ Optimization: Junk. There is no reason to prevent the check for whether X event has been triggered, as if it's already been triggered, it won't trigger again.
	BEQ.b CODE_04E61A						;/
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	CMP.b #$FF
	BEQ.b CODE_04E61A
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	AND.b #$07
	TAX
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	LSR
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_Overworld_EventFlags,y
	AND.l SMW_BitTable_DATA_04E44B,x
	BEQ.b CODE_04E640
CODE_04E61A:
	LDX.b #$07
CODE_04E61C:
	LDA.w DATA_04E5E6,x
	CMP.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	BNE.b CODE_04E632
	INC.w !RAM_SMW_Pointer_CurrentOverworldProcess	;| else increment "Cause Mario event" address
	LDA.b #$E0
	STA.w !RAM_SMW_Misc_ExitLevelAction
	LDA.b #$0F			;\ keep game mode active
	STA.w !RAM_SMW_Timer_KeepGameModeActive	;/
	RTS

CODE_04E632:
	DEX
	BPL.b CODE_04E61C
	LDA.b #$05			;\ Make mario do nothing on the overworld
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess	;/
	LDA.b #$80
	STA.w !RAM_SMW_Misc_ExitLevelAction
	RTS

CODE_04E640:
	INC.w !RAM_SMW_Pointer_OverworldEventProcess
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	JSR.w SMW_CheckIfDestroyTileEventIsActive_Main
	TYA
	ASL
	ASL
	ASL
	ASL
	STA.w !RAM_SMW_Overworld_OnScreenXPosOfCurrentEventTile
	TYA
	AND.b #$F0
	STA.w !RAM_SMW_Overworld_OnScreenYPosOfCurrentEventTile
	LDA.b #$28
	STA.w !RAM_SMW_Timer_FadeInLevelTile
	LDA.w !RAM_SMW_Overworld_LevelNumberLo	;\ level that triggers overworld Earthquake sequence when beaten
	CMP.b #!Define_SMW_LevelID_EarthquakeEvent	;| Sunken Ghost Ship
	BNE.b CODE_04E668		;| if not level 18, don't trigger Earthquake
	LDA.b #$FF			;|
	STA.w !RAM_SMW_Overworld_ActiveEarthquakeEvent	;/
CODE_04E668:
	LDA.w !RAM_SMW_Pointer_OverworldEventProcess
	CMP.b #$02
	BEQ.b CODE_04E674
	LDA.b #!Define_SMW_Sound1DFC_CastleCollapse
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
CODE_04E674:
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_OverworldEventProcess01_DestroyTileAnimation(Address)
namespace SMW_OverworldEventProcess01_DestroyTileAnimation
%InsertMacroAtXPosition(<Address>)

DATA_04EB56:
	db $F5,$11,$F2,$15,$F5,$11,$F3,$14
	db $F5,$11,$F3,$14,$F6,$10,$F4,$13
	db $F7,$0F,$F5,$12,$F8,$0E,$F7,$11
	db $FA,$0D,$F9,$10,$FC,$0C,$FB,$0D
	db $FF,$0A,$FE,$0B,$01,$07,$01,$07
	db $00,$08,$00,$08

DATA_04EB82:
	db $F8,$F8,$11,$12,$F8,$F8,$10,$11
	db $F8,$F8,$10,$11,$F9,$F9,$0F,$10
	db $FA,$FA,$0E,$0F,$FB,$FB,$0C,$0D
	db $FC,$FC,$0B,$0B,$FE,$FE,$0A,$0A
	db $00,$00,$08,$08,$01,$01,$07,$07
	db $00,$00,$08,$08

DATA_04EBAE:
	db $F6,$B6,$76,$36,$F6,$B6,$76,$36
	db $36,$76,$B6,$F6,$36,$76,$B6,$F6
	db $36,$36,$36,$36,$36,$36,$36,$36
	db $36,$36,$36,$36,$36,$36,$36,$36
	db $36,$36,$36,$36,$36,$36,$36,$36
	db $30,$70,$B0,$F0

DATA_04EBDA:
	db $22,$23,$32,$33,$32,$23,$22

DATA_04EBE1:
	db $73,$73,$72,$72,$5F,$5F,$28,$28
	db $28,$28

Main:
	DEC.w !RAM_SMW_Timer_FadeInLevelTile
	BPL.b CODE_04EBF4
	INC.w !RAM_SMW_Pointer_OverworldEventProcess
	RTS

CODE_04EBF4:
	LDA.w !RAM_SMW_Timer_FadeInLevelTile
	LDY.w !RAM_SMW_Pointer_OverworldEventProcess
	CPY.b #$01
	BEQ.b CODE_04EC17
	CMP.b #$10
	BNE.b CODE_04EC07
	PHA
	JSR.w CODE_04ED83
	PLA
CODE_04EC07:
	LSR
	LSR
	TAX
	LDA.w DATA_04EBDA,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_GetXAndYDispOfCurrentEventTileSprite_Main
	LDX.b #$28
	JMP.w CODE_04EC2E

CODE_04EC17:
	CMP.b #$18
	BNE.b CODE_04EC20
	PHA
	JSR.w CODE_04EEAA
	PLA
CODE_04EC20:
	AND.b #$FC
	TAX
	LSR
	LSR
	TAY
	LDA.w DATA_04EBE1,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_GetXAndYDispOfCurrentEventTileSprite_Main
CODE_04EC2E:
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b #$00
CODE_04EC34:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_04EB56,x
	STA.w SMW_OAMBuffer[$20].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w DATA_04EB82,x
	STA.w SMW_OAMBuffer[$20].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$20].Tile,y
	LDA.w DATA_04EBAE,x
	STA.w SMW_OAMBuffer[$20].Prop,y
	INY
	INY
	INY
	INY
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM03
	BPL.b CODE_04EC34
	STZ.w SMW_OAMTileSizeBuffer[$20].Slot
	STZ.w SMW_OAMTileSizeBuffer[$21].Slot
	STZ.w SMW_OAMTileSizeBuffer[$22].Slot
	STZ.w SMW_OAMTileSizeBuffer[$23].Slot
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_OverworldEventProcess01_DestroyTileAnimation_Main, SMW_OverworldEventProcess06_FadeInLayer1Tile_Main)
endmacro

macro ROUTINE_RT01_SMW_OverworldEventProcess01_DestroyTileAnimation(Address)
namespace SMW_OverworldEventProcess01_DestroyTileAnimation
%InsertMacroAtXPosition(<Address>)

; Table of 16-bit VRAM addresses for the primary Layer 1 tile that each
; event reveals. Lunar Magic may move this table to a dynamic location that
; can be found at read3($04EDB8).
DATA_04D93D:
	db $00,$00,$00,$00,$00,$00,$21,$92
	db $21,$16,$20,$92,$20,$12,$23,$46
	db $23,$8A,$22,$8A,$23,$42,$22,$0A
	db $22,$92,$23,$16,$22,$DA,$22,$5A
	db $22,$8A,$28,$0E,$00,$00,$28,$8E
	db $24,$04,$28,$10,$23,$86,$23,$10
	db $28,$94,$23,$98,$28,$18,$28,$58
	db $29,$14,$00,$00,$23,$80,$20,$DC
	db $24,$C0,$24,$C8,$24,$CC,$24,$D4
	db $00,$00,$25,$4E,$26,$08,$24,$D4
	db $00,$00,$00,$00,$2A,$94,$29,$CC
	db $2B,$10,$2A,$98,$29,$CC,$00,$00
	db $00,$00,$2A,$88,$2A,$94,$2B,$08
	db $00,$00,$2C,$08,$00,$00,$00,$00
	db $25,$D2,$25,$CE,$25,$52,$25,$C8
	db $00,$00,$25,$48,$00,$00,$24,$C8
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$2E,$C6,$00,$00
	db $00,$00,$00,$00,$2B,$5E,$2B,$58
	db $00,$00,$29,$DC,$00,$00,$00,$00
	db $00,$00,$23,$80,$23,$80,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$24,$C8,$24,$C8
	db $00,$00,$00,$00,$2E,$0E,$00,$00
	db $27,$C0,$2D,$90,$2D,$8A,$2E,$CA
	db $00,$00,$2C,$CC,$2C,$D2,$2C,$D8
	db $2C,$58,$2C,$52,$2C,$4C,$2C,$46
	db $2C,$42,$00,$00,$00,$00,$00,$00
namespace off
endmacro

macro ROUTINE_RT02_SMW_OverworldEventProcess01_DestroyTileAnimation(Address)
namespace SMW_OverworldEventProcess01_DestroyTileAnimation
%InsertMacroAtXPosition(<Address>)

; VRAM addresses (16-bit) to write each of the destroyed
; castle/fortress/switch palace tiles to. Likely not used when LM is done
; with the ROM.
DATA_04E587:
	dw $5220,$DA22,$5828,$C024
	dw $9424,$4223,$9428,$982A
	dw $0E25,$5225,$C425,$DE2A
	dw $982A,$4428,$502C,$0C2C
namespace off
endmacro

macro ROUTINE_RT03_SMW_OverworldEventProcess01_DestroyTileAnimation(Address)
namespace SMW_OverworldEventProcess01_DestroyTileAnimation
%InsertMacroAtXPosition(<Address>)

DATA_04ECD3:						; Note: These entires correspond to the values in SMW_ChangingLayer1OverworldTiles_TilesToBecome
	dw $9986,$1986,$D986,$5986			; Small yellow level tile
	dw $9996,$1996,$D996,$5996			; Big yellow level tile
	dw $9D86,$1D86,$DD86,$5D86			; Small red level tile
	dw $9D96,$1D96,$DD96,$5D96			; Big red level tile
	dw $9986,$1986,$D986,$5986			; Small yellow level tile
	dw $9996,$1996,$D996,$5996			; Big yellow level tile
	dw $9D86,$1D86,$DD86,$5D86			; Small red level tile
	dw $9D96,$1D96,$DD96,$5D96			; Big red level tile
	dw $1588,$1598,$1589,$1599			; Fortress
	dw $11A4,$11B4,$11A5,$11B5			; 4 sign
	dw $1122,$1190,$1122,$1191			; Half a 1 sign
	dw $11C2,$11D2,$11C3,$11D3			; Open door
	dw $11A6,$11B6,$11A7,$11B7			; Bridge
	dw $1982,$1992,$1983,$1993			; Yellow cave tile
	dw $19C8,$19F8,$19C9,$19F9			; Star Road
	dw $1C80,$1C90,$1C81,$5C90			; Switch Palace 1
	dw $1480,$1490,$1481,$5490			; Switch Palace 2
	dw $11A2,$11B2,$11A3,$11B3			; Ghost House
	dw $1D82,$1D92,$1D83,$1D93			; Red cave tile
	dw $9986,$1986,$D986,$5986			; Small yellow level tile
	dw $9986,$1986,$D986,$5986			; Small yellow level tile
	dw $11A8,$11B8,$11A9,$11B9			; 5 sign

CODE_04ED83:
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	REP.b #$30			; AXY->16
	LDA.w #!RAM_SMW_Blocks_Map16TableLo
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	AND.w #$00FF
	ASL
	TAX
	LDA.l SMW_ChangingLayer1OverworldTiles_Layer1TileLocation,x
	TAY
	LDX.w #SMW_ChangingLayer1OverworldTiles_TilesToBecome-SMW_ChangingLayer1OverworldTiles_TilesThatChange-1	; The last pair: the table's own length, so a grown table is scanned whole
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
CODE_04EDA2:
	CMP.l SMW_ChangingLayer1OverworldTiles_TilesThatChange,x
	BEQ.b CODE_04EDAB
	DEX
	BNE.b CODE_04EDA2
CODE_04EDAB:
	REP.b #$30			; AXY->16
	STX.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	AND.w #$00FF
	ASL
	TAX
	LDA.l DATA_04D93D,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l SMW_ChangingLayer1OverworldTiles_Layer1TileLocation,x
	TAX
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM0E
	SEP.b #$20			; A->8
	LDA.l SMW_ChangingLayer1OverworldTiles_TilesToBecome,x
	PLX
	STA.l !RAM_SMW_Blocks_Map16TableLo,x
	LDA.b #DATA_04ECD3>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	REP.b #$20			; A->16
	LDA.w #DATA_04ECD3
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ASL
	ASL
	ASL
	TAY
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_04EDE6:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	CLC
	ADC.w #$2000
	STA.l SMW_StripeImageUploadTable[$04].LowByte,x
	LDA.w #$0300
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	STA.l SMW_StripeImageUploadTable[$05].LowByte,x
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.l SMW_StripeImageUploadTable[$06].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.l SMW_StripeImageUploadTable[$03].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.l SMW_StripeImageUploadTable[$07].LowByte,x
	LDA.w #$00FF
	STA.l SMW_StripeImageUploadTable[$08].LowByte,x
	TXA
	CLC
	ADC.w #$0010
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

macro ROUTINE_RT04_SMW_OverworldEventProcess01_DestroyTileAnimation(Address)
namespace SMW_OverworldEventProcess01_DestroyTileAnimation
%InsertMacroAtXPosition(<Address>)

DATA_04EE7A:
	dw $0122,$1C82,$0122,$1C83
	dw $0122,$1482,$0122,$1483
	dw $01EA,$01EA,$C1EA,$C1EA
	dw $01EA,$01EA,$C1EA,$C1EA
	dw $0122,$0122,$0122,$0122
	dw $158A,$159A,$158B,$159B

CODE_04EEAA:
	SEP.b #$30			; AXY->8
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b #DATA_04EE7A>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	REP.b #$30			; AXY->16
	LDA.w #!RAM_SMW_Blocks_Map16TableLo
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.w #DATA_04EE7A
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_Overworld_DestroyTileEventVRAMIndex
	AND.w #$00FF
	ASL
	TAX
	LDA.l DATA_04E587,x				; LM: Makes this pointer point to the expanded area so one can safely modify all 24 entries of it (2.21+)
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	LDA.w !RAM_SMW_Overworld_DestroyTileEventTileIndex
	AND.w #$00FF
	CMP.w #$0003
	BMI.b CODE_04EF27
	ASL
	ASL
	ASL
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	CLC
	ADC.w #$2000
	STA.l SMW_StripeImageUploadTable[$04].LowByte,x
	XBA
	CLC
	ADC.w #$0020
	XBA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0300
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	STA.l SMW_StripeImageUploadTable[$05].LowByte,x
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.l SMW_StripeImageUploadTable[$06].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.l SMW_StripeImageUploadTable[$03].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	STA.l SMW_StripeImageUploadTable[$07].LowByte,x
	TXA
	CLC
	ADC.w #$0010
	TAX
CODE_04EF27:
	LDA.w !RAM_SMW_Overworld_DestroyTileEventTileIndex
	AND.w #$00FF
	CMP.w #$0002
	BPL.b CODE_04EF38
	ASL
	ASL
	ASL
	TAY
	BRA.b CODE_04EF3B

CODE_04EF38:
	LDY.w #$0028
CODE_04EF3B:
	JMP.w CODE_04EDE6
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldEventProcess02_SetEventTileIndexes(Address)
namespace SMW_OverworldEventProcess02_SetEventTileIndexes
%InsertMacroAtXPosition(<Address>)

Main:
	INC.w !RAM_SMW_Pointer_OverworldEventProcess
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	ASL
	TAX
	REP.b #$20			; A->16
	LDA.l SMW_Layer2EventData_Ptrs,x
	STA.w !RAM_SMW_Overworld_StartingEventTileLo
	LDA.l SMW_Layer2EventData_Ptrs+$02,x
	STA.w !RAM_SMW_Overworld_FinalEventTileLo
	CMP.w !RAM_SMW_Overworld_StartingEventTileLo
	SEP.b #$20			; A->8
	BNE.b Return04E6F8
	INC.w !RAM_SMW_Pointer_OverworldEventProcess
	INC.w !RAM_SMW_Pointer_OverworldEventProcess
Return04E6F8:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_OverworldEventProcess03_GetLayer2Tile(Address)
namespace SMW_OverworldEventProcess03_GetLayer2Tile
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w CODE_04EA62
	LDA.b #!RAM_SMW_Overworld_Layer2Tiles>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Overworld_StartingEventTileLo
	ASL
	ASL
	TAX
	LDA.l SMW_Layer2EventData_TileEntries,x
	STA.w !RAM_SMW_Overworld_EventTileSizeAddressLo
	LDA.l SMW_Layer2EventData_TileEntries+$02,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$1FFF
	LSR
	CLC
	ADC.w #$3000
	XBA
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	LSR
	LSR
	LSR
	SEP.b #$20			; A->8
	AND.b #$F8
	STA.w !RAM_SMW_Overworld_OnScreenYPosOfCurrentEventTile
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$3E
	ASL
	ASL
	STA.w !RAM_SMW_Overworld_OnScreenXPosOfCurrentEventTile
	REP.b #$20			; A->16
	LDA.w #!RAM_SMW_Overworld_Layer2Tiles
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.w #$EFFF
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_Overworld_EventTileSizeAddressLo
	CMP.w #SMW_OverworldLayer2EventTilemap_Tiles_TwoByTwo-SMW_OverworldLayer2EventTilemap_Tiles
	BCC.b CODE_04E74F
	JSR.w SMW_BufferEventTileToStripeImageTable_Buffer2x2Tile
	JMP.w CODE_04E752

CODE_04E74F:
	JSR.w SMW_BufferEventTileToStripeImageTable_Buffer6x6Tile
CODE_04E752:
	LDA.w #$00FF
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	TXA
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	JSR.w SMW_BufferEventTileToLayer2Tilemap_Main
	SEP.b #$30			; AXY->8
	LDA.b #!Define_SMW_Sound1DFC_OverworldTileReveal
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	INC.w !RAM_SMW_Pointer_OverworldEventProcess
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_OverworldEventProcess03_GetLayer2Tile(Address)
namespace SMW_OverworldEventProcess03_GetLayer2Tile
%InsertMacroAtXPosition(<Address>)

CODE_04EA62:
	STZ.w !RAM_SMW_Timer_LevelEndFade
	STZ.w !RAM_SMW_Palettes_LevelEndColorFadeDirection
	LDX.b #$6F
CODE_04EA6A:
	LDA.w SMW_PaletteMirror[$00].LowByte,x
	STA.w SMW_CopyOfPaletteMirror[$01].LowByte,x
	STZ.w SMW_CopyOfPaletteMirror[$3A].LowByte,x
	DEX
	BPL.b CODE_04EA6A
	LDX.b #$6F
CODE_04EA78:
	LDY.b #$10
CODE_04EA7A:
	LDA.w SMW_PaletteMirror[$40].LowByte,x
	STA.w SMW_CopyOfPaletteMirror[$01].LowByte,x
	DEX
	DEY
	BNE.b CODE_04EA7A
	TXA
	SEC
	SBC.b #$10
	TAX
	BPL.b CODE_04EA78
CODE_04EA8B:
	REP.b #$20			; A->16
	LDA.w #$0070
	STA.w SMW_CopyOfPaletteMirror[$00].LowByte
	LDA.w #$C070
	STA.w SMW_CopyOfPaletteMirror[$39].LowByte
	SEP.b #$20			; A->8
	STZ.w SMW_CopyOfPaletteMirror[$72].LowByte
	LDA.b #$03
	STA.w !RAM_SMW_Palettes_PaletteUploadTableIndex
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_OverworldEventProcess04_FadeInLayer2Tile(Address)
namespace SMW_OverworldEventProcess04_FadeInLayer2Tile
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Timer_LevelEndFade	;\ if counter less than 40
	CMP.b #$40			;| don't lay down this event tile yet
	BCC.b CODE_04EAC9		;/
	INC.w !RAM_SMW_Pointer_OverworldEventProcess
	JSR.w CODE_04EE30		;|Draw the layer 2 tile
	JSR.w SMW_BufferEventTileToLayer2Tilemap_Main
	REP.b #$20			; A->16
	INC.w !RAM_SMW_Overworld_StartingEventTileLo	;| increment to next event tile
	LDA.w !RAM_SMW_Overworld_StartingEventTileLo
	CMP.w !RAM_SMW_Overworld_FinalEventTileLo
	SEP.b #$20			; A->8
	BCS.b Return04EAC8
	LDA.b #$03
	STA.w !RAM_SMW_Pointer_OverworldEventProcess
Return04EAC8:
	RTS

CODE_04EAC9:
	JSR.w SMW_GetXAndYDispOfCurrentEventTileSprite_Main
	REP.b #$30			; AXY->16
	LDY.w #$008C
	LDX.w #$0006
	LDA.w !RAM_SMW_Overworld_EventTileSizeAddressLo
	CMP.w #SMW_OverworldLayer2EventTilemap_Tiles_TwoByTwo-SMW_OverworldLayer2EventTilemap_Tiles
	BCC.b CODE_04EAE2
	LDY.w #$000C
	LDX.w #$0002
CODE_04EAE2:
	STX.b !RAM_SMW_Misc_ScratchRAM05
	TAX
	SEP.b #$20			; A->8
CODE_04EAE7:
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_ScratchRAM00
CODE_04EAED:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$54].YDisp,y
	LDA.l SMW_OverworldLayer2EventTilemap_Tiles,x
	STA.w SMW_OAMBuffer[$54].Tile,y
	LDA.l !RAM_SMW_Overworld_Layer2EventTiles,x
	AND.b #$C0
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.l !RAM_SMW_Overworld_Layer2EventTiles,x
	AND.b #$1C
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	ORA.b #$11
	STA.w SMW_OAMBuffer[$54].Prop,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$54].XDisp,y
	CLC
	ADC.b #$08
	INX
	DEY
	DEY
	DEY
	DEY
	DEC.b !RAM_SMW_Misc_ScratchRAM03
	BNE.b CODE_04EAED
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM01
	CPY.w #$FFFC
	BNE.b CODE_04EAE7
	SEP.b #$10			; XY->8
	LDX.b #$23
CODE_04EB32:
	STZ.w SMW_OAMTileSizeBuffer[$54].Slot,x
	DEX
	BPL.b CODE_04EB32
	LDY.b #$08
	LDX.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	CMP.b #!Define_SMW_Overworld_ForestOfIlluision
	; Change from D0 to 80 to make the Forest of Illusion submap reveal its
	; event tiles at the same speed as the other submaps
	BNE.b CODE_04EB46
	LDY.b #$01
CODE_04EB46:
	STY.b !RAM_SMW_Misc_ScratchRAM8A
CODE_04EB48:
	LDA.w !RAM_SMW_Timer_LevelEndFade
	JSL.l CODE_00B006
	DEC.b !RAM_SMW_Misc_ScratchRAM8A
	BNE.b CODE_04EB48
	JMP.w SMW_OverworldEventProcess03_GetLayer2Tile_CODE_04EA8B
namespace off
endmacro

macro ROUTINE_RT01_SMW_OverworldEventProcess04_FadeInLayer2Tile(Address)
namespace SMW_OverworldEventProcess04_FadeInLayer2Tile
%InsertMacroAtXPosition(<Address>)

CODE_04EE30:
	SEP.b #$20			; A->8
	LDA.b #!RAM_SMW_Overworld_Layer2Tiles>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Overworld_StartingEventTileLo
	ASL
	ASL
	TAX
	LDA.l SMW_Layer2EventData_TileEntries+$02,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$1FFF
	LSR
	CLC
	ADC.w #$3000
	XBA
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w #!RAM_SMW_Overworld_Layer2Tiles
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.w #$FFFF
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.l SMW_Layer2EventData_TileEntries,x
	CMP.w #SMW_OverworldLayer2EventTilemap_Tiles_TwoByTwo-SMW_OverworldLayer2EventTilemap_Tiles
	BCC.b CODE_04EE68
	JSR.w SMW_BufferEventTileToStripeImageTable_Buffer2x2Tile
	JMP.w CODE_04EE6B

CODE_04EE68:
	JSR.w SMW_BufferEventTileToStripeImageTable_Buffer6x6Tile
CODE_04EE6B:
	LDA.w #$00FF
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	TXA
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldEventProcess05_GetLayer1Tile(Address)
namespace SMW_OverworldEventProcess05_GetLayer1Tile
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	REP.b #$30			; AXY->16
	LDA.w #!RAM_SMW_Blocks_Map16TableLo
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	AND.w #$00FF
	ASL
	TAX
	LDA.l SMW_ChangingLayer1OverworldTiles_Layer1TileLocation,x
	TAY
	LDX.w #SMW_ChangingLayer1OverworldTiles_TilesToBecome-SMW_ChangingLayer1OverworldTiles_TilesThatChange-1	; The last pair: the table's own length, so a grown table is scanned whole
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Misc_ScratchRAM0D],y
CODE_04EC97:
	CMP.l SMW_ChangingLayer1OverworldTiles_TilesThatChange,x
	BEQ.b CODE_04ECA8
	DEX
	BPL.b CODE_04EC97
	SEP.b #$10			; XY->8
	LDA.b #$07
	STA.w !RAM_SMW_Pointer_OverworldEventProcess
	RTS

CODE_04ECA8:
	SEP.b #$30			; AXY->8
	LDA.b #!Define_SMW_Sound1DFC_Coin
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	INC.w !RAM_SMW_Pointer_OverworldEventProcess
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	AND.b #$FF									; Optimization: Unnecessary AND.b #$FF
	ASL
	TAX
	LDA.l SMW_ChangingLayer1OverworldTiles_Layer1TileLocation,x
	ASL
	ASL
	ASL
	ASL
	STA.w !RAM_SMW_Overworld_OnScreenXPosOfCurrentEventTile
	LDA.l SMW_ChangingLayer1OverworldTiles_Layer1TileLocation,x
	AND.b #$F0
	STA.w !RAM_SMW_Overworld_OnScreenYPosOfCurrentEventTile
	LDA.b #$1C
	STA.w !RAM_SMW_Timer_FadeInLevelTile
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent(Address)
%SMW_RelocatableTableSlot(<Address>, SilentTiles)
if !Define_SMW_RelocateOverworldTables == !FALSE
	%SMW_OverworldTable_SilentTiles()
endif
endmacro

; The table itself, so that the relocated build can emit it where it
; wants it: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedOverworldTables. Nothing here knows which.
macro SMW_OverworldTable_SilentTiles()
namespace SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent

incsrc "overworld/tables/silent-tiles.asm"
namespace off
endmacro

macro ROUTINE_SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent(Address)
namespace SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	STA.b !RAM_SMW_Misc_ScratchRAM0F
Entry2:
	LDX.b #SilentEventTiles_TileLayer-SilentEventTiles_EventNum-1		;\ LM: These lines of code become useless if the below hijack is applied. You can safely NOP them out.
										;| The last slot: the table's own length, so a grown table is scanned whole -- up to $80 slots, past which the BPL below falls through
CODE_04E9F3:									;| All that matters is that A contains the current event number.
	CMP.l SilentEventTiles_EventNum,x					;/
#LM160Hijack_MoreSilentEventTiles:
	BEQ.b CODE_04EA25							;\ LM: NOPs out and inserts a JSL.l to the expanded area to allow SMW to have more silent events (1.60+)
CODE_04E9F9:									;|
	DEX									;|
	BPL.b CODE_04E9F3							;/
	LDA.w !RAM_SMW_Pointer_OverworldEventProcess
	BEQ.b Return04EA24
	STZ.w !RAM_SMW_Pointer_OverworldEventProcess
	INC.w !RAM_SMW_Pointer_CurrentOverworldProcess
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	AND.b #$07
	TAX
	LDA.w !RAM_SMW_Overworld_CurrentEventNumber
	LSR
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_Overworld_EventFlags,y
	ORA.l SMW_BitTable_DATA_04E44B,x
	STA.w !RAM_SMW_Overworld_EventFlags,y
	INC.w !RAM_SMW_Counter_EventsTriggered
	STZ.w !RAM_SMW_Overworld_CheckIfEventPassedFlag				; Optimization: Junk
Return04EA24:
	RTS

CODE_04EA25:									;\ LM: This routine becomes inaccessible in ROM with edited overworlds (1.60+) 
	PHX									;|
	LDA.l SilentEventTiles_TileLayer,x					;|
	STA.b !RAM_SMW_Misc_ScratchRAM02					;|
	TXA									;|
	ASL									;|
	TAX									;|
	REP.b #$20								;|
	LDA.l SilentEventTiles_TileNum,x					;|
	STA.b !RAM_SMW_Misc_ScratchRAM00					;|
	LDA.l SilentEventTiles_TilemapLocation,x				;|
	STA.b !RAM_SMW_Misc_ScratchRAM04					;|
	LDA.b !RAM_SMW_Misc_ScratchRAM02					;|
	AND.w #$0001								;|
	BEQ.b CODE_04EA4E							;|
	REP.b #$10								;|
	LDY.b !RAM_SMW_Misc_ScratchRAM00					;|
	JSR.w SMW_BufferEventTileToLayer2Tilemap_Entry2				;|
	JMP.w CODE_04EA5A							;|
										;|
CODE_04EA4E:									;|
	SEP.b #$20								;|
	REP.b #$10								;|
	LDX.b !RAM_SMW_Misc_ScratchRAM04					;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00					;|
	STA.l !RAM_SMW_Blocks_Map16TableLo,x					;|
CODE_04EA5A:									;|
	SEP.b #$30								;|
	PLX									;|
	LDA.b !RAM_SMW_Misc_ScratchRAM0F					;|
	JMP.w CODE_04E9F9							;/
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OverworldProcess0A_SwitchBetweenSubmaps(Address)
namespace SMW_OverworldProcess0A_SwitchBetweenSubmaps
%InsertMacroAtXPosition(<Address>)

Main:
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Overworld_SubmapSwitchProcess
	JSL.l SMW_ExecutePtr_Absolute

Ptrs04DAF8:
	dw SMW_SubmapSwitchProcess00_InitializeWindowHDMA_Main
	dw SMW_SubmapSwitchProcess01_UpdateLayer1_Main
	dw SMW_SubmapSwitchProcess02_UpdateLayer1_Main
	dw SMW_SubmapSwitchProcess03_UpdateLayer1_Main
	dw SMW_SubmapSwitchProcess04_UpdateLayer1_Main
	dw SMW_SubmapSwitchProcess05_UpdatePalette_Main
	dw SMW_SubmapSwitchProcess06_EndWindowHDMA_Main
	dw SMW_SubmapSwitchProcess07_EndSubmapSwitch_Main
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SubmapSwitchProcess00_InitializeWindowHDMA(Address)
namespace SMW_SubmapSwitchProcess00_InitializeWindowHDMA
%InsertMacroAtXPosition(<Address>)

DATA_04DB08:
	dw $F900,$0700

DATA_04DB0C:
	dw $0000,$7000

DATA_04DB10:
	dw $FAC0,$0540

DATA_04DB14:
	dw $0000,$5400

Main:
	REP.b #$20			; A->16
	LDX.w !RAM_SMW_Overworld_HDMATransitionEffectFlag
	LDA.w !RAM_SMW_Overworld_HDMATransitionEffectXPosLo
	CLC
	ADC.w DATA_04DB08,x
	STA.w !RAM_SMW_Overworld_HDMATransitionEffectXPosLo
	SEC
	SBC.w DATA_04DB0C,x
	EOR.w DATA_04DB08,x
	BPL.b CODE_04DB43
	LDA.w !RAM_SMW_Overworld_HDMATransitionEffectYPosLo
	CLC
	ADC.w DATA_04DB10,x
	STA.w !RAM_SMW_Overworld_HDMATransitionEffectYPosLo
	SEC
	SBC.w DATA_04DB14,x
	EOR.w DATA_04DB10,x
	BMI.b CODE_04DB5F
CODE_04DB43:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_04DB0C,x
else
	LDA.w DATA_04DB0C,x
endif
	STA.w !RAM_SMW_Overworld_HDMATransitionEffectXPosLo
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_04DB14,x
else
	LDA.w DATA_04DB14,x
endif
	STA.w !RAM_SMW_Overworld_HDMATransitionEffectYPosLo
	INC.w !RAM_SMW_Overworld_SubmapSwitchProcess
	TXA
	EOR.w #$0002
	TAX
	STX.w !RAM_SMW_Overworld_HDMATransitionEffectFlag
	BEQ.b CODE_04DB5F
	JSR.w SMW_HandleOverworldPathExits_SetLayerPositions
CODE_04DB5F:
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Overworld_HDMATransitionEffectYPosHi
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_HDMATransitionEffectXPosHi
	CLC
	ADC.b #$80
	XBA
	LDA.b #$80
	SEC
	SBC.w !RAM_SMW_Overworld_HDMATransitionEffectXPosHi
	REP.b #$20			; A->16
	LDX.b #$00
	LDY.b #$A8
CODE_04DB7A:
	CPX.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b CODE_04DB81
	LDA.w #$00FF
CODE_04DB81:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$4E,y
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$F8,x
	INX
	INX
	DEY
	DEY
	BNE.b CODE_04DB7A
	SEP.b #$20			; A->8
	LDA.b #$33
	STA.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings
	LDA.b #$33
CODE_04DB95:
	STA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings
	LDA.b #($01<<!Define_SMW_WindowHDMAChannel)
	STA.w !RAM_SMW_Mirror_HDMAEnable
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_SubmapSwitchProcess00_InitializeWindowHDMA_Main, SMW_SubmapSwitchProcess06_EndWindowHDMA_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SubmapSwitchProcess01_UpdateLayer1(Address)
namespace SMW_SubmapSwitchProcess01_UpdateLayer1
%InsertMacroAtXPosition(<Address>)

UNK_04DCAE:
	db $80,$40,$20,$10,$08,$04,$02,$01

Main:
	PHP
	REP.b #$10			; XY->16
	SEP.b #$20			; A->8
	LDX.w #SMW_Map16Data_OverworldLayer1
	STX.b !RAM_SMW_Pointer_Layer1DataLo
	LDA.b #SMW_Map16Data_OverworldLayer1>>16
	STA.b !RAM_SMW_Pointer_Layer1DataBank
	LDX.w #$0000
	STX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_SubmapSwitchProcess
	DEC
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	AND.w #$00FF
	TAX
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	BEQ.b CODE_04DCE8						; Note: !Define_SMW_Overworld_MainMap
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM01
CODE_04DCE8:
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l !RAM_SMW_Blocks_Map16TableLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	REP.b #$20			; A->16
	LDA.l !RAM_SMW_Blocks_Map16TableHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_ScratchRAM02
#LM000Hijack_Unknown04DCFA:
	ASL
	ASL
	ASL
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$00FF
	ASL
	ASL
	PHA
	AND.w #$003F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PLA
	ASL
	AND.w #$0F80
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0E),x
	INY
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0E)+$40,x
	INY
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0E)+$02,x
	INY
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	STA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$0E)+$42,x
	SEP.b #$20			; A->8
	INC.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$FF
	BNE.b CODE_04DCE8
	INC.w !RAM_SMW_Overworld_SubmapSwitchProcess
	PLP
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_SubmapSwitchProcess01_UpdateLayer1_Main, SMW_SubmapSwitchProcess02_UpdateLayer1_Main)
	%SetDuplicateOrNullPointer(SMW_SubmapSwitchProcess01_UpdateLayer1_Main, SMW_SubmapSwitchProcess03_UpdateLayer1_Main)
	%SetDuplicateOrNullPointer(SMW_SubmapSwitchProcess01_UpdateLayer1_Main, SMW_SubmapSwitchProcess04_UpdateLayer1_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SubmapSwitchProcess05_UpdatePalette(Address)
namespace SMW_SubmapSwitchProcess05_UpdatePalette
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	TAX
	LDA.l SMW_LoadOverworldLayer1AndEvents_DATA_04DC02,x
	STA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad
	JSL.l SMW_BufferPalettesRoutines_Overworld_Main
	LDA.b #$FE
	STA.w SMW_PaletteMirror[$00].LowByte
	LDA.b #$01
	STA.w SMW_PaletteMirror[$00].HighByte
	STZ.w SMW_PaletteMirror[$80].LowByte
	LDA.b #$06
	STA.w !RAM_SMW_Palettes_PaletteUploadTableIndex
	INC.w !RAM_SMW_Overworld_SubmapSwitchProcess
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SubmapSwitchProcess07_EndSubmapSwitch(Address)
namespace SMW_SubmapSwitchProcess07_EndSubmapSwitch
%InsertMacroAtXPosition(<Address>)

; Music tracks used by the different submaps, indexed by submap ID ($1F11).
DATA_04DBC8:
	db !Define_SMW_OverworldMusic_Overworld
	db !Define_SMW_OverworldMusic_YoshisIsland
	db !Define_SMW_OverworldMusic_VanillaDome
	db !Define_SMW_OverworldMusic_ForestOfIllusion
	db !Define_SMW_OverworldMusic_BowsersValley
	db !Define_SMW_OverworldMusic_SpecialWorld
	db !Define_SMW_OverworldMusic_StarRoad

Main:
	STZ.w !RAM_SMW_Overworld_SubmapSwitchProcess
	LDA.b #$04
	STA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_Flag_TwoPlayerGame
	BEQ.b CODE_04DBF3
	LDA.w !RAM_SMW_Flag_ChangeSubmapMusicOnPlayerSwitch
	BNE.b CODE_04DBF3
	TYA
	EOR.b #$01
	TAX
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	CMP.w !RAM_SMW_Overworld_MarioMap,x
	BEQ.b Return04DC01
CODE_04DBF3:
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	TAX
	LDA.l DATA_04DBC8,x
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	STZ.w !RAM_SMW_Flag_ChangeSubmapMusicOnPlayerSwitch
Return04DC01:
	RTS
namespace off
endmacro

macro DATATABLE_RT01_SMW_BitTable(Address)
namespace SMW_BitTable
%InsertMacroAtXPosition(<Address>)

Bank04:
	dw $0008,$0004,$0002,$0001
namespace off
endmacro

macro DATATABLE_RT02_SMW_BitTable(Address)
namespace SMW_BitTable
%InsertMacroAtXPosition(<Address>)

DATA_04E44B:
	db $80,$40,$20,$10,$08,$04,$02,$01
namespace off
endmacro

macro ROUTINE_RT01_SMW_GameMode0E_ShowOverworld(Address)
namespace SMW_GameMode0E_ShowOverworld
%InsertMacroAtXPosition(<Address>)

OverworldScrollArrowsImage:
	incbin "images/overworld/scrollarrows.bin"

RemoveOverworldScrollArrowsImage:
	incbin "images/overworld/noscrollarrows.bin"

; Offsets for overworld free scrolling when start is pressed. 16 bit. Order:
; null, right, left, both (unused, same as right), null, bottom, top, both
; (unused, same as bottom)
DATA_048211:
	dw $0000,$0002,$FFFE,$0002
	dw $0000,$0002,$FFFE,$0002

; Max range for overworld scrolling when start is pressed. 16bit. Indexed by
; controller bits. Order: null, right, left, both (unused, same as right),
; null, bottom, top, both (unused, same as bottom) Due to a discrepancy
; between these values and the values in $049416, free scrolling can scroll
; the overworld 1 pixel lower than walking down can.
DATA_048221:
	dw $0000,$0111,$FFEF,$0111
	dw $0000,$0132,$FFD7,$0132

DATA_048231:
	db $0F,$0F,$07,$07,$07,$03,$03,$03
	db $01,$01,$03,$03,$03,$07,$07,$07

Bank04:
	PHB
	PHK
	PLB
	LDX.b #$01			; \ If player 1 pushes select...
CODE_048246:
	LDA.w !RAM_SMW_IO_ControllerPress1CopyP1,x
	AND.b #!Joypad_Select>>8	; | ...disabled by BRA
#Debug_CycleYoshiColors
	; Change from 80 to F0, and pushing select on the OW will cycle through
	; Yoshi colours.
	BRA.b CODE_048261		; / Change to BEQ to enable debug code below
	LDA.w !RAM_SMW_Player_MariosYoshi,x	; \ Unreachable
	INC				; | Debug: Change Yoshi color
	INC
	CMP.b #$04
	BCS.b ADDR_048258
	LDA.b #$04
ADDR_048258:
	CMP.b #$0B
	BCC.b ADDR_04825E
	LDA.b #$00
ADDR_04825E:
	STA.w !RAM_SMW_Player_MariosYoshi,x
CODE_048261:
	DEX
	BPL.b CODE_048246
	JSR.w SMW_DrawOverworldBorderPlayer_Entry2
if defined("Define_SMW_SA1")
	JSL.l overworld_animations
	NOP #2
else
	JSR.w SMW_OverworldTileAnimations_Main
	LDA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1	; \ If "! blocks flying away color" is 0,
endif
	BEQ.b CODE_048275		; / don't play the animation
	JSR.w SMW_DrawFlyingSwitchBlocks_Main
	JMP.w CODE_04840D

CODE_048275:
	LDA.w !RAM_SMW_Flag_ShowContinueAndEnd	; \ If not showing Continue/End message,
	BEQ.b CODE_048281		; / branch to $8281
if defined("Define_SMW_SA1")
	JSL.l overworld_continue_fix
else
	JSL.l SMW_DisplayingContinueEnd_Main
endif
	JMP.w CODE_048410

CODE_048281:
	LDA.w !RAM_SMW_Pointer_DisplayOverworldPrompt
	BEQ.b CODE_048295
	CMP.b #$05
	BCS.b CODE_04828F
	LDY.w !RAM_SMW_Flag_TwoPlayerGame
	; Change to 80 06 to disable "Lives Exchanger" function.
	BEQ.b CODE_048295
CODE_04828F:
	JSR.w SMW_DisplayOverworldPrompt_Main
	JMP.w CODE_048413

CODE_048295:
	LDA.w !RAM_SMW_Flag_MainMapFreeScrolling
	LSR
	BNE.b CODE_04829E
	JMP.w CODE_048356

CODE_04829E:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Overworld_ScrollCameraYPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	BPL.b CODE_0482AE
	EOR.w #$FFFF
	INC
CODE_0482AE:
	LSR
	SEP.b #$20			; A->8
	STA.b !RAM_SMW_Misc_ScratchRAM05
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Overworld_ScrollCameraXPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_0482C3
	EOR.w #$FFFF
	INC
CODE_0482C3:
	LSR
	SEP.b #$20			; A->8
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDX.b #$01
	CMP.b !RAM_SMW_Misc_ScratchRAM05
	BCS.b CODE_0482D1
	DEX
	LDA.b !RAM_SMW_Misc_ScratchRAM05
CODE_0482D1:
	CMP.b #$02
	BCS.b CODE_0482ED
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Overworld_ScrollCameraXPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	LDA.w !RAM_SMW_Overworld_ScrollCameraYPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	SEP.b #$20			; A->8
	STZ.w !RAM_SMW_Flag_MainMapFreeScrolling
	JMP.w CODE_0483BD

CODE_0482ED:
if defined("Define_SMW_SA1")
	JML.l overworld_mulfix2v2
	NOP #22
else
	STZ.w !REGISTER_DividendLo	; Dividend (Low Byte)
	LDY.b !RAM_SMW_Misc_ScratchRAM04,x
	STY.w !REGISTER_DividendHi	; Dividend (High-Byte)
	STA.w !REGISTER_Divisor		; Divisor B
	NOP #6
	REP.b #$20			; A->16
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
	LSR
	LSR
	SEP.b #$20			; A->8
endif
	LDY.b !RAM_SMW_Misc_ScratchRAM01,x
	BPL.b CODE_04830E
	EOR.b #$FF
	INC
CODE_04830E:
	STA.b !RAM_SMW_Misc_ScratchRAM01,x
	TXA
	EOR.b #$01
	TAX
	LDA.b #$40
	LDY.b !RAM_SMW_Misc_ScratchRAM01,x
	BPL.b CODE_04831C
	LDA.b #$C0
CODE_04831C:
	STA.b !RAM_SMW_Misc_ScratchRAM01,x
	LDY.b #$01
CODE_048320:
	TYA
	ASL
	TAX
	LDA.w !RAM_SMW_Misc_ScratchRAM01,y
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_Overworld_Layer1SubXPos,y
	STA.w !RAM_SMW_Overworld_Layer1SubXPos,y
	LDA.w !RAM_SMW_Misc_ScratchRAM01,y
	PHY
	PHP
	LSR
	LSR
	LSR
	LSR
	LDY.b #$00
	PLP
	BPL.b CODE_048342
	ORA.b #$F0
	DEY
CODE_048342:
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo,x
	TYA
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi,x
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosHi,x
	PLY
	DEY
	BPL.b CODE_048320
	JMP.w CODE_04840D

CODE_048356:
	LDA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	CMP.b #$03
	BEQ.b CODE_048366
	CMP.b #$04
	BNE.b CODE_04839A
	LDA.w !RAM_SMW_Flag_SwitchPlayers
	BNE.b CODE_04839A
CODE_048366:
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	LDA.w !RAM_SMW_IO_ControllerPress2CopyP1	;!
	ORA.w !RAM_SMW_IO_ControllerPress2CopyP2	;!
	AND.b #!Joypad_L|!Joypad_R	;!
	BEQ.b CODE_048375		;!
	LDA.b #$01			;!
	STA.w !RAM_SMW_Pointer_DisplayOverworldPrompt	;!
endif

CODE_048375:
if ver_is_smasw(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_IO_ControllerPress1
	AND.b #!Joypad_Select>>8
	BEQ.b +
	LDA.b #$09
	STA.w !RAM_SMW_Pointer_DisplayOverworldPrompt
+:
endif
	LDX.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	BNE.b CODE_04839A						; Note: !Define_SMW_Overworld_MainMap
	LDA.b !RAM_SMW_IO_ControllerPress1
	AND.b #!Joypad_Start>>8
	BEQ.b CODE_04839A
	INC.w !RAM_SMW_Flag_MainMapFreeScrolling	; Look around overworld
	LDA.w !RAM_SMW_Flag_MainMapFreeScrolling	;\
	LSR				;| If not looking around overworld
	BNE.b CODE_04839A		;/
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w !RAM_SMW_Overworld_ScrollCameraXPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w !RAM_SMW_Overworld_ScrollCameraYPosLo
	SEP.b #$20			; A->8
CODE_04839A:
	LDA.w !RAM_SMW_Flag_MainMapFreeScrolling
	BEQ.b CODE_0483C3
	LDX.b #$00
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)
	ASL
	JSR.w UpdateMainMapFreeScrollingPosition
	LDX.b #$02
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)
	ORA.b #$10
	LSR
	JSR.w UpdateMainMapFreeScrollingPosition
	LDY.b #!Define_SMW_StripeImage_ShowScrollArrows
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$18
	BNE.b CODE_0483BF
CODE_0483BD:
	LDY.b #!Define_SMW_StripeImage_RemoveScrollArrows
CODE_0483BF:
	STY.b !RAM_SMW_Graphics_StripeImageToUpload
	BRA.b CODE_04840D

CODE_0483C3:
	LDX.w !RAM_SMW_Overworld_ActiveEarthquakeEvent
	BEQ.b CODE_04840A
	CPX.b #$FE
	BNE.b CODE_0483D6
	LDA.b #!Define_SMW_Sound1DF9_ValleyOfBowserAppears
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	LDA.b #!Define_SMW_OverworldMusic_BowsersValleyRevealed
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
CODE_0483D6:
	TXA
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w DATA_048231,y
	BNE.b CODE_0483F3
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	EOR.b #$01
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	EOR.b #$01
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
CODE_0483F3:
	CPX.b #$80
	BCS.b CODE_0483FE
	LDA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	CMP.b #$02
	BNE.b CODE_04840A
CODE_0483FE:
	DEC.w !RAM_SMW_Overworld_ActiveEarthquakeEvent
	BNE.b CODE_04840D
	LDA.b #!Define_SMW_Sound1DF9_EndValleyOfBowserAppears
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	BRA.b CODE_04840D

CODE_04840A:
	JSR.w SMW_HandleCurrentOverworldProcess_Main
CODE_04840D:
	JSR.w SMW_OverworldLightningAndRandomCloudSpawning_Main
CODE_048410:
	JSR.w SMW_DrawOverworldPlayer_Main
CODE_048413:
	PLB
Return048414:							; LM: For some routines that JML.l to a JSR.w SMW_routine in bank 04, the address of this label minus 1 is stored onto the stack.
	RTL

; Handles looking around the overworld when in the free look mode (pressing
; pause). Takes values in A and X that correspond to directions. Indexes
; $048211 and $048221 using the given values.
UpdateMainMapFreeScrollingPosition:
	TAY				; A=$2,X=$0 for right; A=$4,X=$0 for left; A=$A,X=$2 for down; A=$C,X=$2 for up
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x
	CLC
	ADC.w DATA_048211,y
	PHA
	SEC
	SBC.w DATA_048221,y
	EOR.w DATA_048211,y
	ASL
	PLA
	BCC.b CODE_04842E
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo,x
CODE_04842E:
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_OverworldLightningAndRandomCloudSpawning(Address)
namespace SMW_OverworldLightningAndRandomCloudSpawning
%InsertMacroAtXPosition(<Address>)

DATA_04F6D0:
	db $70,$7F,$78,$7F,$70,$7F,$78,$7F

DATA_04F6D8:
	db $F0,$FF,$20,$00,$C0,$00,$F0,$FF
	db $F0,$FF,$80,$00,$F0,$FF,$00,$00

DATA_04F6E8:
	db $70,$00,$60,$01,$58,$01,$B0,$00
	db $60,$01,$60,$01,$70,$00,$60,$01

DATA_04F6F8:
	db $20,$58,$43,$CF,$18,$34,$A2,$5E

DATA_04F700:
	db $07,$05,$06,$07,$04,$06,$07,$05

Main:
	LDA.b #$F7
	JSR.w SMW_CheckIfXIsAllowedOnYSubmap_Lightning
	BNE.b CODE_04F76E
	LDY.w !RAM_SMW_Palettes_LightningFlashColorIndex
	BNE.b CODE_04F73B
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b CODE_04F76E
	DEC.w !RAM_SMW_Timer_WaitBeforeNextLightningFlash
	BNE.b CODE_04F76E
	TAY
	LDA.w DATA_04F700+$08,y
	AND.b #$07
	TAX
	LDA.w DATA_04F6F8,x
	STA.w !RAM_SMW_Timer_WaitBeforeNextLightningFlash
	LDY.w DATA_04F700,x
	STY.w !RAM_SMW_Palettes_LightningFlashColorIndex
	LDA.b #$08
	STA.w !RAM_SMW_Timer_LightningFrameDuration
	LDA.b #!Define_SMW_Sound1DFC_Thunder
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
CODE_04F73B:
	DEC.w !RAM_SMW_Timer_LightningFrameDuration
	BPL.b CODE_04F748
	DEC.w !RAM_SMW_Palettes_LightningFlashColorIndex
	LDA.b #$04
	STA.w !RAM_SMW_Timer_LightningFrameDuration
CODE_04F748:
	TYA
	ASL
	TAY
	; Subroutine which is used for the flashing effect in Valley of Bowser.
	; $04F754 - Color which is animated by this routine. Can be changed to 00
	; to have an all round lightning effect (everything flashes).
	LDX.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
	LDA.b #$02
	STA.w !RAM_SMW_Palettes_DynamicPaletteBytesToUpload,x
	LDA.b #$47
	STA.w !RAM_SMW_Palettes_DynamicPaletteCGRAMAddress,x
	LDA.w SMW_PaletteMirror[$28].LowByte,y
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors,x
	LDA.w SMW_PaletteMirror[$28].HighByte,y
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors+$01,x
	STZ.w !RAM_SMW_Palettes_DynamicPaletteColors+$02,x
	TXA
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
CODE_04F76E:
	LDX.b #!Define_SMW_MaxOverworldSpriteSlot-$0D
CODE_04F770:
	LDA.w !RAM_SMW_OWSpr_SpriteID,x
	BNE.b CODE_04F7AB
	LDA.b #!Define_SMW_SpriteID_OWSpr05_Cloud
	STA.w !RAM_SMW_OWSpr_SpriteID,x
	JSR.w SMW_SetOverworldSpriteFrameIndex_Main
	AND.b #$07
	TAY
	LDA.w DATA_04F6D0,y
	STA.w !RAM_SMW_OWSpr_ZPosLo,x
	TYA
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w DATA_04F6D8,y
	SEP.b #$20			; A->8
	STA.w !RAM_SMW_OWSpr_XPosLo,x
	XBA
	STA.w !RAM_SMW_OWSpr_XPosHi,x
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.w DATA_04F6E8,y
	SEP.b #$20			; A->8
	STA.w !RAM_SMW_OWSpr_YPosLo,x
	XBA
	STA.w !RAM_SMW_OWSpr_YPosHi,x
CODE_04F7AB:
	DEX
	BPL.b CODE_04F770
	LDX.b #$04
CODE_04F7B0:
	TXA
	STA.w !RAM_SMW_Sprites_OverworldCloudSyncTable,x
	DEX
	BPL.b CODE_04F7B0
	LDX.b #!Define_SMW_MaxOverworldSpriteSlot-$0B
CODE_04F7B9:
	STX.b !RAM_SMW_Misc_ScratchRAM00
CODE_04F7BB:
	STX.b !RAM_SMW_Misc_ScratchRAM01
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_Sprites_OverworldCloudSyncTable,x
	LDA.w !RAM_SMW_OWSpr_YPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_OWSpr_YPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDX.b !RAM_SMW_Misc_ScratchRAM01
	LDY.w !RAM_SMW_Sprites_OverworldCloudSyncTable-$01,x
	LDA.w !RAM_SMW_OWSpr_YPosHi,y
	XBA
	LDA.w !RAM_SMW_OWSpr_YPosLo,y
	REP.b #$20			; A->16
	CMP.b !RAM_SMW_Misc_ScratchRAM02
	SEP.b #$20			; A->8
	BPL.b CODE_04F7ED
	PHY
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_OverworldCloudSyncTable,y
	STA.w !RAM_SMW_Sprites_OverworldCloudSyncTable-$01,x
	PLA
	STA.w !RAM_SMW_Sprites_OverworldCloudSyncTable,y
CODE_04F7ED:
	DEX
	BNE.b CODE_04F7BB
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	DEX
	BNE.b CODE_04F7B9
	LDA.b #$30
	STA.w !RAM_SMW_Sprites_StartingOAMIndexForOverworldSprites
	STZ.w !RAM_SMW_Overworld_EnterLevelFlag
	LDX.b #!Define_SMW_MaxOverworldSpriteSlot
	LDY.b #$2D
CODE_04F801:
	CPX.b #!Define_SMW_MaxOverworldSpriteSlot-$02
	BCS.b CODE_04F80D
	LDA.w !RAM_SMW_OWSpr_Table7E0E25,x
	BEQ.b CODE_04F80D
	DEC.w !RAM_SMW_OWSpr_Table7E0E25,x
CODE_04F80D:
	CPX.b #!Define_SMW_MaxOverworldSpriteSlot-$0A
	BCC.b CODE_04F819
	STX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
	JSR.w SMW_ProcessOverworldSprites_Main
	BRA.b CODE_04F825

CODE_04F819:
	PHX
	LDA.w !RAM_SMW_Sprites_OverworldCloudSyncTable,x
	TAX
	STX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
	JSR.w SMW_ProcessOverworldSprites_Main
	PLX
CODE_04F825:
	DEX
	BPL.b CODE_04F801
Return04F828:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_OverworldLightningAndRandomCloudSpawning_Return04F828, SMW_OWSpr00_Unused_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_ProcessOverworldSprites(Address)
namespace SMW_ProcessOverworldSprites
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_CheckIfXIsAllowedOnYSubmap_Sprites
	BNE.b SMW_OverworldLightningAndRandomCloudSpawning_Return04F828
	LDA.w !RAM_SMW_OWSpr_SpriteID,x
	JSL.l SMW_ExecutePtr_Absolute

OverworldSpritePtrs:
base $000000
; Overworld sprite pointer table.
.OWSpr00_Unused:		dw SMW_OWSpr00_Unused_Main
.OWSpr01_Lakitu:		dw SMW_OWSpr01_Lakitu_Main
.OWSpr02_BlueBird:		dw SMW_OWSpr02_BlueBird_Main
.OWSpr03_CheepCheep:		dw SMW_OWSpr03_CheepCheep_Main
.OWSpr04_PiranhaPlant:		dw SMW_OWSpr04_PiranhaPlant_Main
.OWSpr05_Cloud:			dw SMW_OWSpr05_Cloud_Main
.OWSpr06_KoopaKid:		dw SMW_OWSpr06_KoopaKid_Main
.OWSpr07_Smoke:			dw SMW_OWSpr07_Smoke_Main
.OWSpr08_BowserSign:		dw SMW_OWSpr08_BowserSign_Main
.OWSpr09_Bowser:		dw SMW_OWSpr09_Bowser_Main
.OWSpr0A_Boo:			dw SMW_OWSpr0A_Boo_Main
base off
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawOverworldBorderPlayer(Address)
namespace SMW_DrawOverworldBorderPlayer
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_DrawOverworldPlayer_Main
Entry2:
	REP.b #$20			; A->16
	LDA.w #$001E			; \ Mario X postion = #$001E
	CLC				; | (On overworld boarder)
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	LDA.w #$0006			; \ Mario Y postion = #$0006
	CLC				; | (On overworld boarder)
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Player_YPosLo
	SEP.b #$20			; A->8
	LDA.b #$08
	STA.w !RAM_SMW_Player_XSpeed
	PHB
	LDA.b #SMW_SetPlayerPose_Main>>16
	PHA
	PLB
	JSL.l SMW_SetPlayerPose_Main
	PLB
	LDA.b #$03
	STA.w !RAM_SMW_Player_CurrentLayerPriority
	; Change from 22 BD E2 00 to EA EA EA EA to remove Mario from the Overworld
	; border
	JSL.l SMW_PlayerGFXRt_Main
	LDA.b #$06
	STA.w !RAM_SMW_Player_NumberOfTilesToUpdate
	LDA.w !RAM_SMW_Player_AnimationTimer
	BEQ.b CODE_0485E0
	DEC.w !RAM_SMW_Player_AnimationTimer
CODE_0485E0:
	LDA.w !RAM_SMW_Timer_CapeFlapAnimation
	BEQ.b CODE_0485E8
	DEC.w !RAM_SMW_Timer_CapeFlapAnimation
; Change this byte to [60] (RTS) to get rid of the 32x32 box that surrounds
; the Mario image.
CODE_0485E8:
	LDA.b #$18
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$07
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.b #$00
	TYX
CODE_0485F3:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].XDisp,x
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$00].YDisp,x
	LDA.b #$7E
	STA.w SMW_OAMBuffer[$00].Tile,x
	LDA.b #$36
	STA.w SMW_OAMBuffer[$00].Prop,x
	PHX
	TYX
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	PLX
	INY
	TYA
	AND.b #$03
	BNE.b CODE_048625
	LDA.b #$18
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM01
CODE_048625:
	INX
	INX
	INX
	INX
	CPY.b #$10
	BNE.b CODE_0485F3
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawOverworldPlayer(Address)
namespace SMW_DrawOverworldPlayer
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$30			; AXY->16
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo	; X = player x 4
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x	; A = player X-pos on OW
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	; A = X-pos on screen
	CMP.w #$0100
	BCS.b CODE_04864D		; \ if < #$0100
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | $00 = X-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM08	; | $08 = X-pos on screen
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x	; | A = player Y-pos on OW
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	; | A = Y-pos on screen
	CMP.w #$0100
	BCC.b CODE_048650
CODE_04864D:
	LDA.w #$00F0
CODE_048650:
	STA.b !RAM_SMW_Misc_ScratchRAM02	; | $02 = Y-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM0A	; / $0A = Y-pos on screen
	TXA				; A = player x 4
	EOR.w #$0004			; A = other player x 4
	TAX				; X = other player x 4
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x
	SEC				; | (same as above, but for luigi)
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.w #$0100
	BCS.b CODE_048673
	STA.b !RAM_SMW_Misc_ScratchRAM04	; | $04 = X-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM0C	; | $0C = X-pos on screen
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.w #$0100
	BCC.b CODE_048676
CODE_048673:
	LDA.w #$00F0
CODE_048676:
	STA.b !RAM_SMW_Misc_ScratchRAM06	; | $06 = Y-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM0E	; / $0E = Y-pos on screen
	SEP.b #$30			; AXY->8
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$08			; subtract 8 from 1P X-pos
	STA.b !RAM_SMW_Misc_ScratchRAM00	; $00 = 1P X-pos on screen
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	SEC
	SBC.b #$09			; subtract 9 from 1P Y-pos
	STA.b !RAM_SMW_Misc_ScratchRAM01	; $01 = 1P Y-pos on screen
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	SEC
	SBC.b #$08			; subtract 8 from 2P X-pos
	STA.b !RAM_SMW_Misc_ScratchRAM02	; $02 = 2P X-pos on screen
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	SEC
	SBC.b #$09			; subtract 9 from 2P Y-pos
	STA.b !RAM_SMW_Misc_ScratchRAM03	; $03 = 2P Y-pos on screen
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM8C	; $8C = #$03
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM06	; $06 = 1P X-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM8A	; $8A = 1P X-pos on screen
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Misc_ScratchRAM07	; $07 = 1P Y-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM8B	; $8B = 1P Y-pos on screen
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo	; A = player x 4
	LSR				; A = player x 2
	TAY				; Y = player x 2
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,y	; A = player OW animation type
	CMP.b #$12
	BEQ.b CODE_0486C5		; skip if enter level in water animation
	CMP.b #$07
	BCC.b CODE_0486BC		; don't skip if moving on land
	CMP.b #$0F
	BCC.b CODE_0486C5		; skip if moving in water
CODE_0486BC:
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	SEC
	SBC.b #$05			; subtract 5 from Y-pos if on land
	STA.b !RAM_SMW_Misc_ScratchRAM8B	; $8B = 1P Y-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM07	; $07 = 1P Y-pos on screen
CODE_0486C5:
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo			;\ Note: This forces Luigi's palette to be from a row next to Mario's
	XBA								;| In this case, it will be palette row 0B, since !RAM_SMW_Misc_ScratchRAM05's value is added to the tile property byte.
	LSR								;|
	STA.b !RAM_SMW_Misc_ScratchRAM04				;/
	LDX.w #$0000			; X = #$0000
	JSR.w DrawHalo			; draw halo if out of lives
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo	; A = player x 4
	LSR				; A = player x 2
	TAY				; Y = player x 2
	LDX.w #$0000			; X = #$0000
	JSR.w DrawCurrentPlayer
	SEP.b #$30			; AXY->8
	STZ.w SMW_OAMTileSizeBuffer[$27].Slot
	STZ.w SMW_OAMTileSizeBuffer[$28].Slot	; | make OAM tiles 8x8
	STZ.w SMW_OAMTileSizeBuffer[$29].Slot
	STZ.w SMW_OAMTileSizeBuffer[$2A].Slot
	STZ.w SMW_OAMTileSizeBuffer[$2B].Slot
	STZ.w SMW_OAMTileSizeBuffer[$2C].Slot
	STZ.w SMW_OAMTileSizeBuffer[$2D].Slot
	STZ.w SMW_OAMTileSizeBuffer[$2E].Slot
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM8C	; $8C = #$03
	LDA.w !RAM_SMW_Overworld_MarioMap	; A = 1P submap
	LDY.w !RAM_SMW_Pointer_CurrentOverworldProcess	; Y = overworld process
	CPY.b #$0A
	BNE.b CODE_048709
	EOR.b #$01			; ??
CODE_048709:
	CMP.w !RAM_SMW_Overworld_LuigiMap
	BNE.b CODE_048786		; skip everything if 1P and 2P are on different submaps
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06	; $06 = 2P X-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM8A	; $8A = 2P X-pos on screen
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM07	; $07 = 2P Y-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM8B	; $8B = 2P Y-pos on screen
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo	; A = player x 4
	LSR				; A = player x 2
	EOR.b #$02			; A = other player x 2
	TAY				; Y = other player x 2
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,y	; A = other player OW animation type
	CMP.b #$12
	BEQ.b CODE_048739		; skip if enter level in water animation
	CMP.b #$07
	BCC.b CODE_048730		; don't skip if moving on land
	CMP.b #$0F
	BCC.b CODE_048739		; skip if moving in water
CODE_048730:
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	SEC
	SBC.b #$05			; subtract 5 from Y-pos if on land
	STA.b !RAM_SMW_Misc_ScratchRAM8B	; $8B = 2P Y-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM07	; $07 = 2P Y-pos on screen
CODE_048739:
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Flag_TwoPlayerGame
	AND.w #$00FF
	BEQ.b CODE_048786		; skip everything if we are in a 1P-game (why check that so late?)
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	CMP.w #$00F0
	BCS.b CODE_048786		; skip if 2P is offscreen in the X direction
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CMP.w #$00F0
	BCS.b CODE_048786		; skip if 2P is offscreen in the Y direction
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; A = player x #$200
	EOR.w #$0200			; A = other player x #$200
	STA.b !RAM_SMW_Misc_ScratchRAM04	; $04 = other player x #$200
	LDX.w #$0020			; X = #$0020
	JSR.w DrawHalo			; draw halo if out of lives
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo	; A = player x 4
	LSR				; A = player x 2
	EOR.w #$0002			; A = other player x 2
	TAY				; Y = other player x 2
	LDX.w #$0020			; X = #$0020
	; Change to EA EA EA to keep the inactive player from appearing on the map
	JSR.w DrawCurrentPlayer
	SEP.b #$30			; AXY->8
	STZ.w SMW_OAMTileSizeBuffer[$2F].Slot
	STZ.w SMW_OAMTileSizeBuffer[$30].Slot	; | make OAM tiles 8x8
	STZ.w SMW_OAMTileSizeBuffer[$31].Slot
	STZ.w SMW_OAMTileSizeBuffer[$32].Slot
	STZ.w SMW_OAMTileSizeBuffer[$33].Slot
	STZ.w SMW_OAMTileSizeBuffer[$34].Slot
	STZ.w SMW_OAMTileSizeBuffer[$35].Slot
	STZ.w SMW_OAMTileSizeBuffer[$36].Slot
CODE_048786:
	SEP.b #$30			; AXY->8
	RTS

DrawHalo:
	LDA.b !RAM_SMW_Misc_ScratchRAM8A	; A = Y-pos on screen | X-pos on screen
	PHA
	PHX				; X = player x #$20
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; A = player x #$200
	XBA				; A = player x 2
	LSR				; A = player
	TAX				; X = player
	LDA.w !RAM_SMW_Player_MariosLives-$01,x	; A = player lives | junk
	PLX				; X = player x #$20
	AND.w #$FF00			; A = player lives | #$00
	BPL.b CODE_0487C7		; skip if player lives positive
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM8A
	STA.w SMW_OAMBuffer[$2D].XDisp,x	; OAM X-pos of 1st halo tile
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$2E].XDisp,x	; OAM X-pos of 2nd halo tile
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	CLC
	ADC.b #$F9
	STA.w SMW_OAMBuffer[$2D].YDisp,x	; OAM Y-pos of 1st halo tile
	STA.w SMW_OAMBuffer[$2E].YDisp,x	; OAM Y-pos of 2nd halo tile
	LDA.b #$7C
	STA.w SMW_OAMBuffer[$2D].Tile,x	; OAM tile number of 1st halo tile
	STA.w SMW_OAMBuffer[$2E].Tile,x	; OAM tile number of 2nd halo tile
	LDA.b #$20
	STA.w SMW_OAMBuffer[$2D].Prop,x	; OAM yxppccct of 1st halo tile
	LDA.b #$60
	STA.w SMW_OAMBuffer[$2E].Prop,x	; OAM yxppccct of 2nd halo tile
	REP.b #$20			; A->16
CODE_0487C7:
	PLA				; A = Y-pos on screen | X-pos on screen
	STA.b !RAM_SMW_Misc_ScratchRAM8A	; $8A = X-pos on screen, $8B = Y-pos on screen
	RTS

PlayerTilesAndProp:
;$0487CB						; Info: Frames...
	; Overworld sprite tilemap (Mario/Luigi) (2 bytes per 8x8 tile)
	db $0E,$24,$0F,$24,$1E,$24,$1F,$24		; Walk up (Frame 1)
	db $20,$24,$21,$24,$30,$24,$31,$24		; Walk up (Frame 2)
	db $0E,$24,$0F,$24,$1E,$24,$1F,$24		; Walk up (Frame 3)
	db $20,$24,$21,$24,$31,$64,$30,$64		; Walk up (Frame 4)
	db $0A,$24,$0B,$24,$1A,$24,$1B,$24		; Walk down/stand (Frame 1)
	db $0C,$24,$0D,$24,$1C,$24,$1D,$24		; Walk down/stand (Frame 2)
	db $0A,$24,$0B,$24,$1A,$24,$1B,$24		; Walk down/stand (Frame 3)
	db $0C,$24,$0D,$24,$1D,$64,$1C,$64		; Walk down/stand (Frame 4)
	db $08,$24,$09,$24,$18,$24,$19,$24		; Walk left (Frame 1)
	db $06,$24,$07,$24,$16,$24,$17,$24		; Walk left (Frame 2)
	db $08,$24,$09,$24,$18,$24,$19,$24		; Walk left (Frame 3)
	db $06,$24,$07,$24,$16,$24,$17,$24		; Walk left (Frame 4)
	db $09,$64,$08,$64,$19,$64,$18,$64		; Walk right (Frame 1)
	db $07,$64,$06,$64,$17,$64,$16,$64		; Walk right (Frame 2)
	db $09,$64,$08,$64,$19,$64,$18,$64		; Walk right (Frame 3)
	db $07,$64,$06,$64,$17,$64,$16,$64		; Walk right (Frame 4)
	db $0E,$24,$0F,$24,$38,$24,$38,$64		; Swim up (Frame 1)
	db $20,$24,$21,$24,$39,$24,$39,$64		; Swim up (Frame 2)
	db $0E,$24,$0F,$24,$38,$24,$38,$64		; Swim up (Frame 3)
	db $20,$24,$21,$24,$39,$24,$39,$64		; Swim up (Frame 4)
	db $0A,$24,$0B,$24,$38,$24,$38,$64		; Swim down/wade (Frame 1)
	db $0C,$24,$0D,$24,$39,$24,$39,$64		; Swim down/wade (Frame 2)
	db $0A,$24,$0B,$24,$38,$24,$38,$64		; Swim down/wade (Frame 3)
	db $0C,$24,$0D,$24,$39,$24,$39,$64		; Swim down/wade (Frame 4)
	db $08,$24,$09,$24,$38,$24,$38,$64		; Swim left (Frame 1)
	db $06,$24,$07,$24,$39,$24,$39,$64		; Swim left (Frame 2)
	db $08,$24,$09,$24,$38,$24,$38,$64		; Swim left (Frame 3)
	db $06,$24,$07,$24,$39,$24,$39,$64		; Swim left (Frame 4)
	db $09,$64,$08,$64,$38,$24,$38,$64		; Swim right (Frame 1)
	db $07,$64,$06,$64,$39,$24,$39,$64		; Swim right (Frame 2)
	db $09,$64,$08,$64,$38,$24,$38,$64		; Swim right (Frame 3)
	db $07,$64,$06,$64,$39,$24,$39,$64		; Swim right (Frame 4)
	db $24,$24,$25,$24,$34,$24,$35,$24		; Enter level on land (Frame 1)
	db $24,$24,$25,$24,$34,$24,$35,$24		; Enter level on land (Frame 2)
	db $24,$24,$25,$24,$34,$24,$35,$24		; Enter level on land (Frame 3)
	db $24,$24,$25,$24,$34,$24,$35,$24		; Enter level on land (Frame 4)
	db $24,$24,$25,$24,$38,$24,$38,$64		; Enter level in water (Frame 1)
	db $24,$24,$25,$24,$38,$24,$38,$64		; Enter level in water (Frame 2)
	db $24,$24,$25,$24,$38,$24,$38,$64		; Enter level in water (Frame 3)
	db $24,$24,$25,$24,$38,$24,$38,$64		; Enter level in water (Frame 4)
	db $46,$24,$47,$24,$56,$24,$57,$24		; Climbing (Unused? Frame 1)
	db $47,$64,$46,$64,$57,$64,$56,$64		; Climbing (Unused? Frame 2)
	db $46,$24,$47,$24,$56,$24,$57,$24		; Climbing (Unused? Frame 3)
	db $47,$64,$46,$64,$57,$64,$56,$64		; Climbing (Unused? Frame 4)
	db $46,$24,$47,$24,$56,$24,$57,$24		; Climbing (Frame 1)
	db $47,$64,$46,$64,$57,$64,$56,$64		; Climbing (Frame 2)
	db $46,$24,$47,$24,$56,$24,$57,$24		; Climbing (Frame 3)
	db $47,$64,$46,$64,$57,$64,$56,$64		; Climbing (Frame 4)

StarWarpAnimationOffset:
;$04894B
	db $20,$60,$00,$40

DrawCurrentPlayer:
	SEP.b #$30			; AXY->8
	PHY				; Y = player x 2
	TYA				; A = player x 2
	LSR				; A = player
	TAY				; Y = player
	LDA.w !RAM_SMW_Player_MariosYoshi,y	; A = player's yoshi color
	BEQ.b DrawPlayerWithoutYoshi	; branch if no yoshi
	STA.b !RAM_SMW_Misc_ScratchRAM0E	; $0E = player's yoshi color
	STZ.b !RAM_SMW_Misc_ScratchRAM0F	; $0F = #$00
	PLY				; Y = player x 2
	JMP.w DrawPlayerWithYoshi	; jump

DrawPlayerWithoutYoshi:
	PLY				; Y = player x 2
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,y	; A = player OW animation type
	ASL
	ASL
	ASL
	ASL				; A = player OW animation type x #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00	; $00 = player OW animation type x #$10
	LDA.b !RAM_SMW_Counter_GlobalFrames	; A = frame counter
	AND.w #$0018			; A = 5 LSB of frame counter
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00	; A = 0000 000a aaaf ffff (a = animation type, f = 5 LSB of frame counter)
	TAY				; Y = that index ^
	PHX				; X = player x #$20
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; A = player x #$200
	XBA				; A = player x 2
	LSR				; A = player
	TAX				; X = player
	LDA.w !RAM_SMW_Player_MariosLives-$01,x	; A = player's lives | junk
	PLX				; X = player x #$20
	AND.w #$FF00			; A = player's lives | #$00
	BPL.b CODE_04898B		; branch if player's lives positive
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; A = player OW animation type x #$10
	TAY				; Y = player OW animation type x #$10
	BRA.b CODE_0489A7		; branch (basically, if player is out of lives, their sprite is static)

CODE_04898B:
	CPX.w #$0000
	BNE.b CODE_0489A7		; skip if 2P
	LDA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	CMP.w #$000B
	BNE.b CODE_0489A7		; skip if not on star warp
	LDA.b !RAM_SMW_Counter_GlobalFrames	; A = frame counter
	AND.w #$000C			; A = 0000 ff00 (f = frame counter bits)
	LSR
	LSR				; A = 2 LSB of frame counter / 4
	TAY				; Y = 2 LSB of frame counter / 4
	LDA.w StarWarpAnimationOffset,y	; A = index to use when using a star warp (overrides that complicated thing)
	AND.w #$00FF
	TAY				; Y = index into tilemap table
CODE_0489A7:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM8A	; A = Y-pos on screen | X-pos on screen
	STA.w SMW_OAMBuffer[$27].XDisp,x	; OAM y-pos and x-pos for tile
	LDA.w PlayerTilesAndProp,y	; get tile | yxppccct
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04	; add player x #$200 (increment palette of tile by 1)
	STA.w SMW_OAMBuffer[$27].Tile,x	; OAM tile and yxppccct for tile
	SEP.b #$20			; A->8
	INX
	INX
	INX
	INX				; increment X to next OAM tile
	INY
	INY				; increment index to tilemap table
	LDA.b !RAM_SMW_Misc_ScratchRAM8A
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM8A	; | update X and Y position of tile
	DEC.b !RAM_SMW_Misc_ScratchRAM8C	; | (zig zag pattern)
	LDA.b !RAM_SMW_Misc_ScratchRAM8C
	AND.b #$01
	BEQ.b CODE_0489D9
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM8A
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM8B
CODE_0489D9:
	LDA.b !RAM_SMW_Misc_ScratchRAM8C
	BPL.b CODE_0489A7		; loop if we have tiles left
	RTS

PlayerRidingYoshiTilesAndProp:
;$0489DE						; Info: Frames...
	; Overworld sprite tilemap (More M/L, Yoshi) Change $04:8A36 to [42 22 43
	; 22 52 22 53 22] to fix a bug where Yoshi is partially red sometimes, no
	; matter which color he really has.
	db $66,$24,$67,$24,$76,$24,$77,$24		;\ Walk up (Frame 1)
	db $2F,$62,$2E,$62,$3F,$62,$3E,$62		;/
	db $66,$24,$67,$24,$76,$24,$77,$24		;\ Walk up (Frame 2)
	db $2E,$22,$2F,$22,$3E,$22,$3F,$22		;/
	db $2F,$62,$2E,$62,$3F,$62,$3E,$62		;\ Walk down/stand (Frame 1)
	db $0A,$24,$0B,$24,$1A,$24,$1B,$24		;/
	db $2E,$22,$2F,$22,$3E,$22,$3F,$22		;\ Walk down/stand (Frame 2)
	db $0A,$24,$0B,$24,$1A,$24,$1B,$24		;/
	db $64,$24,$65,$24,$74,$24,$75,$24		;\ Walk left (Frame 1)
	db $40,$22,$41,$22,$50,$22,$51,$22		;/
	db $64,$24,$65,$24,$74,$24,$75,$24		;\ Walk left (Frame 2)
	db $42,$22,$43,$24,$52,$24,$53,$24		;/
	db $65,$64,$64,$64,$75,$64,$74,$64		;\ Walk right (Frame 1)
	db $41,$62,$40,$62,$51,$62,$50,$62		;/
	db $65,$64,$64,$64,$75,$64,$74,$64		;\ Walk right (Frame 2)
	db $43,$62,$42,$62,$53,$62,$52,$62		;/
	db $38,$24,$38,$64,$66,$24,$67,$24		;\ Swim up (Frame 1)
	db $76,$24,$77,$24,$FF,$FF,$FF,$FF		;/
	db $39,$24,$39,$64,$66,$24,$67,$24		;\ Swim up (Frame 2)
	db $76,$24,$77,$24,$FF,$FF,$FF,$FF		;/
	db $38,$24,$38,$64,$2F,$62,$2E,$62		;\ Swim down/wade (Frame 1)
	db $0A,$24,$0B,$24,$1A,$24,$1B,$24		;/
	db $39,$24,$39,$24,$2E,$22,$2F,$22		;\ Swim down/wade (Frame 2)
	db $0A,$24,$0B,$24,$1A,$24,$1B,$24		;/
	db $38,$24,$38,$64,$64,$24,$65,$24		;\ Swim left (Frame 1)
	db $74,$24,$75,$24,$40,$22,$41,$22		;/
	db $39,$24,$39,$64,$64,$24,$65,$24		;\ Swim left (Frame 2)
	db $74,$24,$75,$24,$42,$22,$42,$22		;/
	db $38,$24,$38,$64,$65,$64,$64,$64		;\ Swim right (Frame 1)
	db $75,$64,$74,$64,$41,$62,$40,$62		;/
	db $39,$24,$39,$64,$65,$64,$64,$64		;\ Swim right (Frame 2)
	db $75,$64,$74,$64,$43,$62,$42,$62		;/
	db $2F,$62,$2E,$62,$3F,$62,$3E,$62		;\ Enter level on land (Frame 1)
	db $24,$24,$25,$24,$34,$24,$35,$24		;/
	db $2E,$22,$2F,$22,$3E,$22,$3F,$22		;\ Enter level on land (Frame 2)
	db $24,$24,$25,$24,$34,$24,$35,$24		;/
	db $38,$24,$38,$64,$2F,$62,$2E,$62		;\ Enter level in water (Frame 1)
	db $24,$24,$25,$24,$34,$24,$35,$24		;/
	db $39,$24,$39,$64,$2E,$22,$2F,$22		;\ Enter level in water (Frame 2)
	db $24,$24,$25,$24,$34,$24,$35,$24		;/
	db $66,$24,$67,$24,$76,$24,$77,$24		;\ Climbing (Unused? Frame 1)
	db $2F,$62,$2E,$62,$3F,$62,$3E,$62		;/
	db $66,$24,$67,$24,$76,$24,$77,$24		;\ Climbing (Unused? Frame 2)
	db $2E,$22,$2F,$22,$3E,$22,$3F,$22		;/
	db $66,$24,$67,$24,$76,$24,$77,$24		;\ Climbing (Frame 1)
	db $2F,$62,$2E,$62,$3F,$62,$3E,$62		;/
	db $66,$24,$67,$24,$76,$24,$77,$24		;\ Climbing (Frame 2)
	db $2E,$22,$2F,$22,$3E,$22,$3F,$22		;/

PlayerAndYoshiXDisp:
;$048B5E
	db $00,$08,$00,$08,$00,$08,$00,$08		;\ Walk up
	db $00,$08,$00,$08,$00,$08,$00,$08		;/
	db $00,$08,$00,$08,$00,$08,$00,$08		;\ Walk down/stand
	db $00,$08,$00,$08,$00,$08,$00,$08		;/
	db $07,$0F,$07,$0F,$00,$08,$00,$08		;\ Walk left
	db $07,$0F,$07,$0F,$00,$08,$00,$08		;/
	db $F9,$01,$F9,$01,$00,$08,$00,$08		;\ Walk right
	db $F9,$01,$F9,$01,$00,$08,$00,$08		;/
	db $00,$08,$00,$08,$00,$08,$00,$08		;\ Swim up
	db $00,$08,$00,$08,$00,$08,$00,$08		;/
	db $00,$08,$00,$08,$00,$08,$00,$08		;\ Swim down/wade
	db $00,$08,$00,$08,$00,$08,$00,$08		;/
	db $00,$08,$07,$0F,$07,$0F,$00,$08		;\ Swim left
	db $00,$08,$07,$0F,$07,$0F,$00,$08		;/
	db $00,$08,$F9,$01,$F9,$01,$00,$08		;\ Swim right
	db $00,$08,$F9,$01,$F9,$01,$00,$08		;/
	db $00,$08,$00,$08,$00,$08,$00,$08		;\ Enter level on land
	db $00,$08,$00,$08,$00,$08,$00,$08		;/
	db $00,$08,$00,$08,$00,$08,$00,$08		;\ Enter level in water
	db $00,$08,$00,$08,$00,$08,$00,$08		;/
	db $00,$08,$00,$08,$00,$08,$00,$08		;\ Climbing (Unused?)
	db $00,$08,$00,$08,$00,$08,$00,$08		;/
	db $00,$08,$00,$08,$00,$08,$00,$08		;\ Climbing
	db $00,$08,$00,$08,$00,$08,$00,$08		;/

PlayerAndYoshiYDisp:
;$048C1E
	db $FB,$FB,$03,$03,$00,$00,$08,$08		;\ Walk up
	db $FA,$FA,$02,$02,$00,$00,$08,$08		;/
	db $00,$00,$08,$08,$F8,$F8,$00,$00		;\ Walk down/stand
	db $00,$00,$08,$08,$F9,$F9,$01,$01		;/
	db $FC,$FC,$04,$04,$00,$00,$08,$08		;\ Walk left
	db $FB,$FB,$03,$03,$00,$00,$08,$08		;/
	db $FC,$FC,$04,$04,$00,$00,$08,$08		;\ Walk right
	db $FB,$FB,$03,$03,$00,$00,$08,$08		;/
	db $08,$08,$FB,$FB,$03,$03,$00,$00		;\ Swim up
	db $08,$08,$FA,$FA,$02,$02,$00,$00		;/
	db $08,$08,$00,$00,$F8,$F8,$00,$00		;\ Swim down/wade
	db $08,$08,$00,$00,$F9,$F9,$01,$01		;/
	db $08,$08,$FC,$FC,$04,$04,$00,$00		;\ Swim left
	db $08,$08,$FB,$FB,$03,$03,$00,$00		;/
	db $08,$08,$FC,$FC,$04,$04,$00,$00		;\ Swim right
	db $08,$08,$FB,$FB,$03,$03,$00,$00		;/
	db $00,$00,$08,$08,$F8,$F8,$00,$00		;\ Enter level on land
	db $00,$00,$08,$08,$F8,$F8,$00,$00		;/
	db $08,$08,$00,$00,$F8,$F8,$00,$00		;\ Enter level in water
	db $08,$08,$00,$00,$F8,$F8,$00,$00		;/
	db $FB,$FB,$03,$03,$00,$00,$08,$08		;\ Climbing (Unused?)
	db $FA,$FA,$02,$02,$00,$00,$08,$08		;/
	db $FB,$FB,$03,$03,$00,$00,$08,$08		;\ Climbing
	db $FA,$FA,$02,$02,$00,$00,$08,$08		;/

YoshiPalette:
;$048CDE
	; Table of palette values used by each Yoshi color on the overworld. The
	; table is formatted as follows: each color uses 2 bytes, in the order
	; yellow, blue, red, green, and each 2 byte value is in big endian, meaning
	; that the actual value is stored in the second byte. In practice, this
	; means that the addresses you should edit are the following: - $048CDF:
	; yellow palette. - $048CE1: blue palette. - $048CE3: red palette. -
	; $048CE5: green palette. The values follow the YXPPCCCT properties format:
	; to find this, subtract 8 from the palette row, and then multiply it by 2.
	db $00,$00,$00,$02,$00,$04,$00,$06

DrawPlayerWithYoshi:
;$048CE6
	LDA.b #$07
	STA.b !RAM_SMW_Misc_ScratchRAM8C	; $8C = #$07
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo,y
	ASL
	ASL
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w #$0008
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAY				; Y = 0000 000a aaaf ffff (a = animation type, f = 5 LSB of frame counter)
	CPX.w #$0000
	BNE.b CODE_048D1B		; skip if not 1P
	LDA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	CMP.w #$000B
	BNE.b CODE_048D1B		; skip if not star warp
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w #$000C
	LSR
	LSR
	TAY				; Y = 2 LSB of frame counter / 4
	LDA.w StarWarpAnimationOffset,y
	AND.w #$00FF
	TAY				; Y = index into tilemap table
CODE_048D1B:
	REP.b #$20			; A->16
	PHY				; Y = index into tilemap table
	TYA				; A = index into tilemap table
	LSR				; / 2
	TAY				; Y = index into tilemap table / 2
	SEP.b #$20			; A->8
	LDA.w PlayerAndYoshiXDisp,y	; X offset table for riding yoshi sprites
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM8A
	STA.w SMW_OAMBuffer[$27].XDisp,x	; OAM X-position
	LDA.w PlayerAndYoshiYDisp,y	; Y offset table for riding yoshi sprites
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM8B
	STA.w SMW_OAMBuffer[$27].YDisp,x	; OAM Y-position
	PLY
	REP.b #$20			; A->16
	LDA.w PlayerRidingYoshiTilesAndProp,y
	CMP.w #$FFFF
	BEQ.b CODE_048D67
	PHA
	AND.w #$0F00
	CMP.w #$0200
	BNE.b CODE_048D5E
	STY.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	SEC
	SBC.w #$0004
	TAY
	PLA
	AND.w #$F0FF
	ORA.w YoshiPalette,y
	PHA
	LDY.b !RAM_SMW_Misc_ScratchRAM08
	BRA.b CODE_048D63

CODE_048D5E:
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	PHA
CODE_048D63:
	PLA
	STA.w SMW_OAMBuffer[$27].Tile,x
CODE_048D67:
	SEP.b #$20			; A->8
	INX
	INX
	INX
	INX
	INY
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM8C
	BPL.b CODE_048D1B
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BufferOverworldLayer2Tilemap(Address)
namespace SMW_BufferOverworldLayer2Tilemap
%InsertMacroAtXPosition(<Address>)

; Subroutine that decompresses LC_RLE2 data.
Main:
	SEP.b #$20			; A->8
	REP.b #$10			; XY->16
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	AND.b #$80					;\ Optimization: Use BMI instead of BNE to make this AND.b #$80 unnecessary.
	BNE.b CODE_04DAD6				;/
CODE_04DAC6:
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.l !RAM_SMW_Overworld_Layer2Tiles,x
	INX
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM03
	BPL.b CODE_04DAC6
	JMP.w CODE_04DAE9

CODE_04DAD6:
	LDA.b !RAM_SMW_Misc_ScratchRAM03		; Optimization: Remove this after doing the above optimization.
	AND.b #$7F
	STA.b !RAM_SMW_Misc_ScratchRAM03
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
CODE_04DADF:
	STA.l !RAM_SMW_Overworld_Layer2Tiles,x
	INX
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM03
	BPL.b CODE_04DADF
CODE_04DAE9:
	INY
	CPX.b !RAM_SMW_Misc_ScratchRAM0E
	BCC.b Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_CheckIfDestroyTileEventIsActive(Address)
namespace SMW_CheckIfDestroyTileEventIsActive
%InsertMacroAtXPosition(<Address>)

Main:
	SEP.b #$30			; AXY->8
	if !Define_SMW_RelocateOverworldTables == !TRUE
	LDX.b #(EventNums-DestructionTileLocations)/2-1	; The last entry: the table's own length, so a grown table is scanned whole and nothing past it is read -- up to $80 entries, past which the BPL below falls through
	else
	LDX.b #$17					; Glitch: There are not that many entries in .EventNums! The scan reads the eight bytes after the table as event numbers -- %INLINEDATATABLE_SMW_SavePromptLevels, placed next -- which is why the table cannot move on a stock build.
	endif
CODE_04E67B:
	CMP.l EventNums,x				; LM: Makes this pointer point to the expanded area so one can safely modify all 24 entries of it (2.21+)
	BEQ.b CODE_04E68A
	DEX
	BPL.b CODE_04E67B
CODE_04E684:
	LDA.b #$02
	STA.w !RAM_SMW_Pointer_OverworldEventProcess
	RTS

CODE_04E68A:
	STX.w !RAM_SMW_Overworld_DestroyTileEventVRAMIndex
	TXA
	ASL
	TAX
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	REP.b #$30			; AXY->16
	LDA.w #!RAM_SMW_Blocks_Map16TableLo
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.l DestructionTileLocations,x				; LM: Makes this pointer point to the expanded area so one can safely modify all 24 entries of it (2.21+)
	TAY
	SEP.b #$20			; A->8
	LDX.w #$0004
	LDA.b [!RAM_SMW_Misc_ScratchRAM0A],y
CODE_04E6A7:
	CMP.l TilesBeforeDestruction,x
	BEQ.b CODE_04E6B3
	DEX
	BPL.b CODE_04E6A7
	JMP.w CODE_04E684

CODE_04E6B3:
	TXA
	STA.w !RAM_SMW_Overworld_DestroyTileEventTileIndex
	CPX.w #$0003
	BMI.b CODE_04E6CA
	LDA.l TopTilesAfterDestruction,x
	STA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	REP.b #$20			; A->16
	TYA
	CLC
	ADC.w #$0010
	TAY
CODE_04E6CA:
	SEP.b #$20			; A->8
	LDA.l BottomTilesAfterDestruction,x
	STA.b [!RAM_SMW_Misc_ScratchRAM0A],y
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckIfDestroyTileEventIsActive(Address)
; Relocatable only together with the scan bound above: on a stock build the
; scan in SMW_CheckIfDestroyTileEventIsActive_Main runs 24 entries over this
; 16-entry table, so it reads the eight bytes that follow -- which are
; %INLINEDATATABLE_SMW_SavePromptLevels, emitted at the front of
; SMW_OverworldEventProcess00_CheckIfEventShouldRun, and four of them are valid
; event numbers the scan acts on -- and moving the table away from that one
; would change what the game reads. The relocated build binds the scan to the
; table's own labels instead, so the table reads whole and nothing past it,
; and then it moves with the rest.
%SMW_RelocatableTableSlot(<Address>, DestroyedTiles)
if !Define_SMW_RelocateOverworldTables == !FALSE
	%SMW_OverworldTable_DestroyedTiles()
endif
endmacro

; The table itself, so that the relocated build can emit it where it
; wants it: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedOverworldTables. Nothing here knows which.
macro SMW_OverworldTable_DestroyedTiles()
namespace SMW_CheckIfDestroyTileEventIsActive

incsrc "overworld/tables/destroyed-tiles.asm"

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawFlyingSwitchBlocks(Address)
namespace SMW_DrawFlyingSwitchBlocks
%InsertMacroAtXPosition(<Address>)

XSpeed:
	db $00,$D8,$28,$D0,$30,$D8,$28,$00

YSpeed:
	db $D0,$D8,$D8,$00,$00,$28,$28,$30

Main:
	LDY.w !RAM_SMW_Overworld_SwitchBlockEventEjectionCounter
	CPY.b #$0C
	BCC.b CODE_04F29B
	STZ.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1
	RTS

CODE_04F29B:
	LDA.w !RAM_SMW_Overworld_SwitchBlockEventWaitBeforeNextEjection
	BNE.b CODE_04F314
	CPY.b #$08
	BCS.b CODE_04F30C
	LDA.b #!Define_SMW_Sound1DFC_OverworldSwitchBlockEjection
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b #$07
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w !RAM_SMW_Overworld_SwitchBlockEventBlocksThrownCounter
CODE_04F2B0:
	LDY.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,y
	STA.l !RAM_SMW_Overworld_SwitchBlockXPosLo,x
	LDA.w !RAM_SMW_Overworld_MarioXPosHi,y
	STA.l !RAM_SMW_Overworld_SwitchBlockXPosHi,x
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,y
	STA.l !RAM_SMW_Overworld_SwitchBlockYPosLo,x
	LDA.w !RAM_SMW_Overworld_MarioYPosHi,y
	STA.l !RAM_SMW_Overworld_SwitchBlockYPosHi,x
	LDA.b #$00
	STA.l !RAM_SMW_Overworld_SwitchBlockZPosLo,x
	STA.l !RAM_SMW_Overworld_SwitchBlockZPosHi,x
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w XSpeed,y
	STA.l !RAM_SMW_Overworld_SwitchBlockXSpeed,x
	LDA.w YSpeed,y
	STA.l !RAM_SMW_Overworld_SwitchBlockYSpeed,x
	LDA.b #$D0
	STA.l !RAM_SMW_Overworld_SwitchBlockZSpeed,x
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_04F2B0
	CPX.b #!Define_SMW_MaxSwitchBlockSlot+$01
	BCC.b CODE_04F309
	LDA.w !RAM_SMW_Overworld_SwitchBlockEventOAMOffset
	CLC
	ADC.b #$20
	CMP.b #$A0
	BCC.b CODE_04F304
	LDA.b #$00
CODE_04F304:
	STA.w !RAM_SMW_Overworld_SwitchBlockEventOAMOffset
	LDX.b #$00
CODE_04F309:
	STX.w !RAM_SMW_Overworld_SwitchBlockEventBlocksThrownCounter
CODE_04F30C:
	LDA.b #$10
	STA.w !RAM_SMW_Overworld_SwitchBlockEventWaitBeforeNextEjection
	INC.w !RAM_SMW_Overworld_SwitchBlockEventEjectionCounter
CODE_04F314:
	DEC.w !RAM_SMW_Overworld_SwitchBlockEventWaitBeforeNextEjection
	LDA.w !RAM_SMW_Overworld_SwitchBlockEventOAMOffset
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDX.b #$00
CODE_04F31E:
	PHX
	LDY.b #$00
	JSR.w CODE_04F39C
	JSR.w CODE_04F397
	JSR.w CODE_04F397
	PLX
	LDA.l !RAM_SMW_Overworld_SwitchBlockZSpeed,x
	CLC
	ADC.b #$01
	BMI.b CODE_04F33A
	CMP.b #$40
	BCC.b CODE_04F33A
	LDA.b #$40
CODE_04F33A:
	STA.l !RAM_SMW_Overworld_SwitchBlockZSpeed,x
	LDA.l !RAM_SMW_Overworld_SwitchBlockZPosHi,x
	XBA
	LDA.l !RAM_SMW_Overworld_SwitchBlockZPosLo,x
	REP.b #$20			; A->16
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM02
	SEP.b #$20			; A->8
	XBA
	ORA.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b CODE_04F378
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	XBA
	STA.w SMW_OAMBuffer[$50].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$50].XDisp,y
	LDA.b #$E6
	STA.w SMW_OAMBuffer[$50].Tile,y
	LDA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1
	DEC
	ASL
	ORA.b #$30
	STA.w SMW_OAMBuffer[$50].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$50].Slot,y
CODE_04F378:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$04
	CMP.b #$A0
	BCC.b CODE_04F383
	LDA.b #$00
CODE_04F383:
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	INX
	CPX.w !RAM_SMW_Overworld_SwitchBlockEventBlocksThrownCounter
	BCC.b CODE_04F31E
	LDA.w !RAM_SMW_Overworld_SwitchBlockEventEjectionCounter
	CMP.b #$05
	BCC.b Return04F396
	CPX.b #!Define_SMW_MaxSwitchBlockSlot+$01
	BCC.b CODE_04F31E
Return04F396:
	RTS

CODE_04F397:
	TXA
	CLC
	ADC.b #!Define_SMW_MaxSwitchBlockSlot+$01
	TAX
CODE_04F39C:
	PHY
	LDA.l !RAM_SMW_Overworld_SwitchBlockXSpeed,x
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.l !RAM_SMW_Overworld_SwitchBlockSubXPos,x
	STA.l !RAM_SMW_Overworld_SwitchBlockSubXPos,x
	LDA.l !RAM_SMW_Overworld_SwitchBlockXSpeed,x
	PHP
	LSR
	LSR
	LSR
	LSR
	LDY.b #$00
	PLP
	BPL.b CODE_04F3BF
	ORA.b #$F0
	DEY
CODE_04F3BF:
	ADC.l !RAM_SMW_Overworld_SwitchBlockXPosLo,x
	STA.l !RAM_SMW_Overworld_SwitchBlockXPosLo,x
	XBA
	TYA
	ADC.l !RAM_SMW_Overworld_SwitchBlockXPosHi,x
	STA.l !RAM_SMW_Overworld_SwitchBlockXPosHi,x
	XBA
	PLY
	REP.b #$20			; A->16
	SEC
	SBC.w !RAM_SMW_Mirror_CurrentLayer1XPosLo,y
	SEC
	SBC.w #$0008
	STA.w !RAM_SMW_Misc_ScratchRAM00,y
	SEP.b #$20			; A->8
	INY
	INY
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_GameMode0C_LoadOverworld(Address)
namespace SMW_GameMode0C_LoadOverworld
%InsertMacroAtXPosition(<Address>)

DATA_048D74:
	dw $000B,$0013,$001A,$001B
	dw $001F,$0020,$0031,$0032
	dw $0034,$0035,$0040

DATA_048D8A:
	db !Define_SMW_OverworldMusic_Overworld
	db !Define_SMW_OverworldMusic_YoshisIsland
	db !Define_SMW_OverworldMusic_VanillaDome
	db !Define_SMW_OverworldMusic_ForestOfIllusion
	db !Define_SMW_OverworldMusic_BowsersValley
	db !Define_SMW_OverworldMusic_SpecialWorld
	db !Define_SMW_OverworldMusic_StarRoad

CODE_048D91:
	PHB
	PHK
	PLB
	STZ.w !RAM_SMW_Flag_ChangeSubmapMusicOnPlayerSwitch
	LDA.b #$0F
	STA.w !RAM_SMW_Overworld_MakeStandingPlayerFaceDownTimerLo
	LDX.b #$02
	LDA.w !RAM_SMW_Overworld_MarioAnimationLo
	CMP.b #$12
	BEQ.b CODE_048DA9
	AND.b #$08
	BEQ.b CODE_048DAB
CODE_048DA9:
	LDX.b #$0A
CODE_048DAB:
	STX.w !RAM_SMW_Overworld_MarioAnimationLo
	LDX.b #$02
	LDA.w !RAM_SMW_Overworld_LuigiAnimationLo
	CMP.b #$12
	BEQ.b CODE_048DBB
	AND.b #$08
	BEQ.b CODE_048DBD
CODE_048DBB:
	LDX.b #$0A
CODE_048DBD:
	STX.w !RAM_SMW_Overworld_LuigiAnimationLo
	SEP.b #$10			; XY->8
	JSR.w CODE_048E55
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Misc_ExitLevelAction-$01			;\ Glitch: This causes Yoshi to act weird and prevent goal walks if a boss is beaten in level 018 (Sunken Ghost Ship)
	AND.w #$FF00						;|
	BEQ.b CODE_048DDF					;|
	BMI.b CODE_048DDF					;|
	LDA.w !RAM_SMW_Overworld_LevelNumberLo			;|
	AND.w #$00FF						;|
	CMP.w #$0018						;|
	; Change to 80 to fix a rather odd bug caused by playing a level
	; immediately after beating a boss in Sunken Ghost Ship's original level
	; (level 018), in which Yoshi will display extremely strangely and goal
	; tapes/spheres will stop Mario rather than making him walk.
	BNE.b CODE_048DDF					;|
	BRL.w CODE_048E34					;/

CODE_048DDF:
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	AND.w #$00FF
	BEQ.b CODE_048E38
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	AND.w #$FF00
	STA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
	SEP.b #$10						;\ Note: Is this code necessary? It seems to be used to calculate the index for !RAM_SMW_Overworld_LevelTileSettings based on where the current player is standing.
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo		;| But, wouldn't it make sense to just do "LDX.w !RAM_SMW_Overworld_LevelNumberLo"
	LDA.w !RAM_SMW_Overworld_MarioXPosLo,x			;| If that's the case, then this is easily an "Optimization:"
	LSR							;|
	LSR							;|
	LSR							;|
	LSR							;|
	STA.b !RAM_SMW_Misc_ScratchRAM00			;|
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,x			;|
	LSR							;|
	LSR							;|
	LSR							;|
	LSR							;|
	STA.b !RAM_SMW_Misc_ScratchRAM02			;|
	TXA							;|
	LSR							;|
	LSR							;|
	TAX							;|
	JSR.w SMW_CalculateOverworldPlayerPosition_Main		;|
	REP.b #$10						;|
	LDX.b !RAM_SMW_Misc_ScratchRAM04			;|
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x	;|
	AND.w #$00FF						;|
	TAX							;/
	LDA.w !RAM_SMW_Overworld_LevelTileSettings,x	;!
	AND.w #$0080			;!
	BNE.b CODE_048E38		;!
endif
	LDY.w #$0014						;\ Optimization: This loop could be shrunken down to only reference 4 entries instead of 11.
CODE_048E25:							;| This loop checks which levels that end in cutscenes are allowed to keep playing music after being beaten.
	LDA.w !RAM_SMW_Overworld_LevelNumberLo			;| Only 4 of those entries really make sense (Wendy's Castle, Roy's Castle, Larry's Castle, and Lemmy's Castle).
	AND.w #$00FF						;| The rest either don't play a cutscene after being beaten or don't even return to the overworld (aka. Trigger credits).
	CMP.w DATA_048D74,y					;|
	; Change to 80 to fix the glitch that occurs when Mario defeats one of the
	; Koopalings and the music on the Overworld "disappears". Also applies for
	; Custom Music.
	BEQ.b CODE_048E38					;|
	DEY							;|
	DEY							;|
	BPL.b CODE_048E25					;/
CODE_048E34:
	SEP.b #$30			; AXY->8
	BRA.b CODE_048E47

CODE_048E38:
	SEP.b #$30			; AXY->8
	LDX.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	TAX
	LDA.w DATA_048D8A,x
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
CODE_048E47:
	PLB
	RTL

#LM220Hijack_SetKoopaTeleportHere1:
KoopaKidTeleportXPos:							;\ LM: Set Koopa Teleport Here... (2.20+)
	dw $0128,$0000,$0188						;|
									;|
#LM220Hijack_SetKoopaTeleportHere2:					;|
KoopaKidTeleportYPos:							;|
	dw $01C8,$0000,$01D8						;/

CODE_048E55:
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Player_CurrentCharacter
	AND.w #$00FF
	ASL
	ASL
	STA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDX.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedXPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_MarioGridAlignedYPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TXA
	LSR
	LSR
	TAX
	JSR.w SMW_CalculateOverworldPlayerPosition_Main
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x
	AND.w #$00FF
#LM000Hijack_CustomLevelNames1:
	ASL								;\ LM: NOPs out and inserts a JSL.l to $03BB20 to enable having custom level names.
	TAX								;|
	LDA.w SMW_LevelNames_Main,x					;|
	STA.b !RAM_SMW_Misc_ScratchRAM00				;|
	JSR.w SMW_UpdateLevelName_Main					;/
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	BMI.b CODE_048E9E
	CPX.w #$0800
	BCS.b CODE_048E9E
	LDA.l !RAM_SMW_Blocks_Map16TableLo+($0200*$00),x
	AND.w #$00FF
	STA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
CODE_048E9E:
	SEP.b #$30			; AXY->8
	LDX.w !RAM_SMW_Overworld_EnterLevelFlag
	BEQ.b CODE_048EE1
	BPL.b ADDR_048ED9
	TXA
	AND.b #$7F
	TAX
	STZ.w !RAM_SMW_OWSpr_Table7E0DF5,x
	LDA.w !RAM_SMW_OWSpr06_KoopaKid_TileIndex
	LDX.w !RAM_SMW_Misc_ExitLevelAction
	BPL.b ADDR_048ECD
	ASL
	TAX
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w KoopaKidTeleportXPos,x
	STA.w !RAM_SMW_Overworld_MarioXPosLo,y
	LDA.w KoopaKidTeleportYPos,x
	STA.w !RAM_SMW_Overworld_MarioYPosLo,y
	SEP.b #$20			; A->8
	BRA.b CODE_048EE1

ADDR_048ECD:
	TAX
	LDA.w SMW_OWSpr06_KoopaKid_DATA_04FB85,x
	ORA.w !RAM_SMW_OWSpr06_KoopaKid_ActivateFlag
	STA.w !RAM_SMW_OWSpr06_KoopaKid_ActivateFlag
	BRA.b CODE_048EE1

ADDR_048ED9:
	LDA.w !RAM_SMW_Misc_ExitLevelAction
	BMI.b CODE_048EE1
	STZ.w !RAM_SMW_OWSpr_SpriteID,x
CODE_048EE1:
	REP.b #$30			; AXY->16
	JSR.w SMW_OverworldProcess04_PlayerIsMoving_CODE_049831
	SEP.b #$30			; AXY->8
	JSR.w SMW_DrawOverworldBorderPlayer_Main
	; If you change this to EA EA EA, the background water tiles on the
	; overworld will not show up.
	JSR.w SMW_OverworldTileAnimations_ShiftWaterTiles
	JMP.w SMW_OverworldTileAnimations_Main
namespace off
endmacro

macro ROUTINE_RT02_SMW_GameMode0C_LoadOverworld(Address)
namespace SMW_GameMode0C_LoadOverworld
%InsertMacroAtXPosition(<Address>)

; Layer 3 Border Tile Data: The 95s, 96s, and 97s are the tiles used for the
; Mushrooms, Stars, and Fire Flowers (respectively). The overworld border's
; "filler" tiles (tile FE by default) are determined by bytes at: $04A404
; (top rows overworld border); $04A40A (first column, left-hand side);
; $04A410 (second column, left-hand side); $04A416 (top right corner by map
; shadow); $04A41C (right-hand side column); $04A422 (bottom rows). $04A530
; is the x beside Mario and the Lives in the overword border. Change from 8F
; to FE to remove it.
; The stripes cover the screen's top five tile rows, bottom two, and two
; columns down each side, leaving a 224x168 window open at screen pixel
; (16, 40) -- tile columns 2-29 of rows 5-25 -- with the thin frame line
; drawn on the window's outermost tiles. The submap camera positions in
; SMW_GameMode0C_LoadOverworld sit 168 pixels apart, so the submaps' open
; windows tile the shared submap page exactly.
OverworldBorderLayer3:
	incbin "images/overworld/border.bin"	; Whew, big table
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_InitializeOverworldTilemaps(Address)
namespace SMW_InitializeOverworldTilemaps
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$30			; AXY->16
	STZ.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.w #$FFFF
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateRightDownLo
	LDA.w #$0202
	STA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	AND.w #$00FF
	TAX
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	AND.w #$000F
	BEQ.b CODE_04D714						; Note: !Define_SMW_Overworld_MainMap
	LDA.w #$0020
	STA.b !RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo
	LDA.w #$0200
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
CODE_04D714:
	JSL.l SMW_BufferScrollingTiles_Layer1_Main
	JSL.l SMW_UploadLevelLayer1And2Tilemaps_Main
	REP.b #$30			; AXY->16
	INC.b !RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.w #$0010
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	AND.w #$01FF
	BNE.b CODE_04D714
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STZ.b !RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo
	STZ.w !RAM_SMW_Misc_LevelModeSetting
	STZ.b !RAM_SMW_Misc_LevelLayoutFlags
	LDA.w #$FFFF
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo
	STA.b !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateRightDownLo
	SEP.b #$30			; AXY->8
	LDA.b #$80
	STA.w !REGISTER_VRAMAddressIncrementValue
	STZ.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer2TilemapVRAMLocation>>8
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_04D750:
	LDA.l PARAMS_04DAB3,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_04D750
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	BEQ.b CODE_04D76A						; Note: !Define_SMW_Overworld_MainMap
	LDA.b #(!RAM_SMW_Overworld_Layer2Tiles+$2000)>>8
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SourceHi		; A Address (High Byte)
CODE_04D76A:
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_InitializeOverworldTilemaps(Address)
namespace SMW_InitializeOverworldTilemaps
%InsertMacroAtXPosition(<Address>)

PARAMS_04DAB3:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Overworld_Layer2Tiles
	dw $2000
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OverworldTileAnimations(Address)
namespace SMW_OverworldTileAnimations
%InsertMacroAtXPosition(<Address>)

WaterTileNumbers:
	dw SMW_GraphicDecompressionBuffer[$50].Tile, SMW_GraphicDecompressionBuffer[$51].Tile,SMW_GraphicDecompressionBuffer[$52].Tile

TileNumbers:
	dw SMW_GraphicDecompressionBuffer[$40].Tile, SMW_GraphicDecompressionBuffer[$41].Tile,SMW_GraphicDecompressionBuffer[$42].Tile, SMW_GraphicDecompressionBuffer[$43].Tile
	dw SMW_GraphicDecompressionBuffer[$44].Tile, SMW_GraphicDecompressionBuffer[$45].Tile,SMW_GraphicDecompressionBuffer[$46].Tile, SMW_GraphicDecompressionBuffer[$47].Tile
	dw SMW_GraphicDecompressionBuffer[$48].Tile, SMW_GraphicDecompressionBuffer[$49].Tile,SMW_GraphicDecompressionBuffer[$4A].Tile, SMW_GraphicDecompressionBuffer[$4B].Tile
	dw SMW_GraphicDecompressionBuffer[$4C].Tile, SMW_GraphicDecompressionBuffer[$4D].Tile,SMW_GraphicDecompressionBuffer[$4E].Tile, SMW_GraphicDecompressionBuffer[$4F].Tile
	dw SMW_GraphicDecompressionBuffer[$50].Tile, SMW_GraphicDecompressionBuffer[$51].Tile,SMW_GraphicDecompressionBuffer[$52].Tile, SMW_GraphicDecompressionBuffer[$53].Tile
	dw SMW_GraphicDecompressionBuffer[$54].Tile, SMW_GraphicDecompressionBuffer[$55].Tile,SMW_GraphicDecompressionBuffer[$56].Tile, SMW_GraphicDecompressionBuffer[$57].Tile
	dw SMW_GraphicDecompressionBuffer[$58].Tile, SMW_GraphicDecompressionBuffer[$59].Tile,SMW_GraphicDecompressionBuffer[$5A].Tile, SMW_GraphicDecompressionBuffer[$5B].Tile
	dw SMW_GraphicDecompressionBuffer[$5C].Tile, SMW_GraphicDecompressionBuffer[$5D].Tile,SMW_GraphicDecompressionBuffer[$5E].Tile, SMW_GraphicDecompressionBuffer[$5F].Tile
	dw SMW_GraphicDecompressionBuffer[$60].Tile, SMW_GraphicDecompressionBuffer[$61].Tile,SMW_GraphicDecompressionBuffer[$62].Tile, SMW_GraphicDecompressionBuffer[$63].Tile
	dw SMW_GraphicDecompressionBuffer[$64].Tile, SMW_GraphicDecompressionBuffer[$65].Tile,SMW_GraphicDecompressionBuffer[$66].Tile, SMW_GraphicDecompressionBuffer[$67].Tile
	dw SMW_GraphicDecompressionBuffer[$68].Tile, SMW_GraphicDecompressionBuffer[$69].Tile,SMW_GraphicDecompressionBuffer[$6A].Tile, SMW_GraphicDecompressionBuffer[$6B].Tile
	dw SMW_GraphicDecompressionBuffer[$6C].Tile, SMW_GraphicDecompressionBuffer[$6D].Tile,SMW_GraphicDecompressionBuffer[$6E].Tile, SMW_GraphicDecompressionBuffer[$6F].Tile
	dw SMW_GraphicDecompressionBuffer[$70].Tile, SMW_GraphicDecompressionBuffer[$71].Tile,SMW_GraphicDecompressionBuffer[$72].Tile, SMW_GraphicDecompressionBuffer[$73].Tile
	dw SMW_GraphicDecompressionBuffer[$74].Tile, SMW_GraphicDecompressionBuffer[$75].Tile,SMW_GraphicDecompressionBuffer[$76].Tile, SMW_GraphicDecompressionBuffer[$77].Tile
	dw SMW_GraphicDecompressionBuffer[$78].Tile, SMW_GraphicDecompressionBuffer[$79].Tile,SMW_GraphicDecompressionBuffer[$7A].Tile, SMW_GraphicDecompressionBuffer[$7B].Tile
	dw SMW_GraphicDecompressionBuffer[$7C].Tile, SMW_GraphicDecompressionBuffer[$7D].Tile,SMW_GraphicDecompressionBuffer[$7E].Tile, SMW_GraphicDecompressionBuffer[$7F].Tile

; Seems to handle drawing the default water tiles on the overworld.
ShiftWaterTiles:
	REP.b #$30			; AXY->16
	STZ.b !RAM_SMW_Misc_ScratchRAM03
	STZ.b !RAM_SMW_Misc_ScratchRAM05
-:
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w WaterTileNumbers,x					; Optimization: The 6 bytes in this table are repeated inside DATA_048006.
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$10							;\ Optimization: Move this load/store to be outside this loop and remove the REP/SEPs.
	LDY.b #!RAM_SMW_Graphics_GraphicDecompressionBuffer>>16		;|
	STY.b !RAM_SMW_Misc_ScratchRAM02				;|
	REP.b #$10							;/
	LDX.b !RAM_SMW_Misc_ScratchRAM05
	JSR.w CODE_0480B9
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	CLC
	ADC.w #$0020
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	INC
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM03
	AND.w #$00FF
	CMP.w #$0006
	BNE.b -
	SEP.b #$30			; AXY->8
	RTS

CODE_0480B9:
	LDY.w #$0000
	LDA.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM07
	STA.b !RAM_SMW_Misc_ScratchRAM09
CODE_0480C3:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.w !RAM_SMW_Graphics_DecompressedOverworldGFX,x
	INY
	INY
	INX
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM07
	BNE.b CODE_0480C3
CODE_0480D0:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	AND.w #$00FF
	STA.w !RAM_SMW_Graphics_DecompressedOverworldGFX,x
	INY
	INX
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM09
	BNE.b CODE_0480D0
	RTS

Main:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07			; |If lower 3 bits of frame counter isn't 0,
	BNE.b CODE_048101		; / don't update the water animation
	LDX.b #$1F
CODE_0480E8:
	LDA.w !RAM_SMW_Graphics_DecompressedOverworldGFX,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	TXA
	AND.b #$08
	BNE.b CODE_0480F9
	ASL.b !RAM_SMW_Misc_ScratchRAM00
	ROL.w !RAM_SMW_Graphics_DecompressedOverworldGFX,x
	BRA.b CODE_0480FE

CODE_0480F9:
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	ROR.w !RAM_SMW_Graphics_DecompressedOverworldGFX,x
CODE_0480FE:
	DEX
	BPL.b CODE_0480E8
CODE_048101:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07			; |If lower 3 bits of frame counter isn't 0,
	BNE.b CODE_04810C		; / don't update the waterfall animation
	LDX.b #$20
	JSR.w CODE_048172
CODE_04810C:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07			; |If lower 3 bits of frame counter isn't 0,
	BNE.b CODE_048123		; / branch to $8123
	LDX.b #$1F
CODE_048114:
	LDA.w !RAM_SMW_Graphics_DecompressedOverworldGFX+$40,x
	ASL
	ROL.w !RAM_SMW_Graphics_DecompressedOverworldGFX+$40,x
	DEX
	BPL.b CODE_048114
	LDX.b #$40
	JSR.w CODE_048172
CODE_048123:
	REP.b #$30			; AXY->16
	LDA.w #$0060
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	STZ.b !RAM_SMW_Misc_ScratchRAM0B
CODE_04812C:
	LDX.w #$0038
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	CMP.w #$0020
	BCS.b CODE_048139
	LDX.w #$0070
CODE_048139:
	TXA
	AND.b !RAM_SMW_Counter_GlobalFrames
	LSR
	LSR
	CPX.w #$0038
	BEQ.b CODE_048144
	LSR
CODE_048144:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0B
	TAX
	LDA.w TileNumbers,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$10			; XY->8
	LDY.b #!RAM_SMW_Graphics_GraphicDecompressionBuffer>>16
	STY.b !RAM_SMW_Misc_ScratchRAM02
	REP.b #$10			; XY->16
	LDX.b !RAM_SMW_Misc_ScratchRAM0D
	JSR.w CODE_0480B9
	LDA.b !RAM_SMW_Misc_ScratchRAM0D
	CLC
	ADC.w #$0020
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	CLC
	ADC.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	CMP.w #$0080
	BNE.b CODE_04812C
	SEP.b #$30			; AXY->8
	RTS

CODE_048172:
	REP.b #$20			; A->16
	LDY.b #$00
CODE_048176:
	PHX
	TXA
	CLC
	ADC.w #$000E
	TAX
	LDA.w !RAM_SMW_Graphics_DecompressedOverworldGFX,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	PLX
CODE_048183:
	LDA.w !RAM_SMW_Graphics_DecompressedOverworldGFX,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Graphics_DecompressedOverworldGFX,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INX
	INX
	INY
	CPY.b #$08
	BEQ.b CODE_048176
	CPY.b #$10
	BNE.b CODE_048183
	SEP.b #$20			; A->8
	RTS

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UpdateSaveBuffer(Address)
namespace SMW_UpdateSaveBuffer
%InsertMacroAtXPosition(<Address>)

Main:
	PHX
	PHY
	PHP
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Flag_ShowSavePrompt
	BEQ.b CODE_049054
if ver_is_arcade(!Define_Global_ROMToAssemble)
	%INLINEROUTINE_SMW_PreparePlayerSwap()
endif
	LDX.b #$5F			;!
CODE_049043:
	LDA.w !RAM_SMW_Overworld_LevelTileSettings,x	;!
	STA.w !RAM_SMW_Overworld_SaveBuffer,x	;!
	DEX				;!
	BPL.b CODE_049043		;!
	STZ.w !RAM_SMW_Flag_ShowSavePrompt	;!
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	LDA.b #$05			;!
	STA.w !RAM_SMW_Pointer_DisplayOverworldPrompt	;!
endif
CODE_049054:
	PLP
	PLY
	PLX
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_UpdateLevelName(Address)
%SMW_RelocatableStringSlot(<Address>, LevelNameTables)
if !Define_SMW_RelocateStringTables == !FALSE
	%SMW_UpdateLevelName_Tables()
endif
endmacro

; The tables themselves, so that the relocated build can emit them where it
; wants them: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedStrings. Nothing here knows which.
macro SMW_UpdateLevelName_Tables()
namespace SMW_UpdateLevelName

; The strings a level's name is assembled from, and the three offset
; tables the name word picks them through -- placed ahead of the routine
; that reads them so they can vacate the bank under the string-table
; relocation. The Japanese build keeps its kana blob inside the routine's
; own placement, so this emits nothing there.
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
LevelNameStrings:
	base $0000
	incsrc "strings/LevelNameStrings.asm"
	base off

Part1Offsets:
	dw LevelStr_None,LevelStr_0100,LevelStr_0200,LevelStr_0300	;!
	dw LevelStr_0400,LevelStr_0500,LevelStr_0600,LevelStr_0700	;!
	dw LevelStr_0800,LevelStr_0900,LevelStr_0A00,LevelStr_0B00	;!
	dw LevelStr_0C00,LevelStr_0D00,LevelStr_0E00,LevelStr_0F00	;!
	dw LevelStr_1000,LevelStr_1100,LevelStr_1200,LevelStr_1300	;!
	dw LevelStr_1400,LevelStr_1500,LevelStr_1600,LevelStr_1700	;!
	dw LevelStr_1800,LevelStr_1900,LevelStr_1A00,LevelStr_1B00	;!
	dw LevelStr_1C00,LevelStr_1D00,LevelStr_1E00	;!

Part2Offsets:
	dw LevelStr_None,LevelStr_0010,LevelStr_0020,LevelStr_0030	;!
	dw LevelStr_0040,LevelStr_0050,LevelStr_0060,LevelStr_0070	;!
	dw LevelStr_0080,LevelStr_0090,LevelStr_00A0,LevelStr_00B0	;!
	dw LevelStr_00C0,LevelStr_00D0,LevelStr_00E0	;!

Part3Offsets:
	dw LevelStr_None,LevelStr_0001,LevelStr_0002,LevelStr_0003	;!
	dw LevelStr_0004,LevelStr_0005,LevelStr_0006,LevelStr_0007	;!
	dw LevelStr_0008,LevelStr_0009,LevelStr_000A,LevelStr_000B	;!
	dw LevelStr_000C		;!
endif
namespace off
endmacro

macro ROUTINE_SMW_UpdateLevelName(Address)
namespace SMW_UpdateLevelName
%InsertMacroAtXPosition(<Address>)

;LM: This routine becomes freespace in ROMs with edited overworlds, so you can have unique level names for each level.
;In the original SMW, levels names are made up of up to 3 (US) or 4 (JP) strings strung together.
;This is not ideal for the average SMW hacker, so LM adds a routine at $03BB20 that allows each level name to be unique.

if ver_is_japanese(!Define_Global_ROMToAssemble)
LevelNameStrings:
	base $0000
	incbin "strings/LevelNameStrings_SMW_J.bin"
	base off

DATA_049B9F:
	dw $011A,$0000,$0007,$000F
	dw $0017,$001F,$0029,$0033
	dw $003A,$0040,$0047,$004E
	dw $0058,$0064,$0070,$0077
	dw $007E,$0088,$0091

DATA_049BC5:
	dw $011A,$0097,$009D,$00A3
	dw $00AA,$00B2,$00B5,$00BC
	dw $00BF,$00C3,$00C7,$00CC
	dw $00D9,$00E4

DATA_049BE1:
	dw $011A,$00EF,$00F3,$00F7
	dw $00FB,$00FF,$0103,$0107
	dw $010E,$0114,$0116

DATA_049BF7:
	dw $0119,$011A

Main:
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	CLC
	ADC.w #$0020
	STA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.w #$0024
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	LDA.w #$1F00
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	STA.l SMW_StripeImageUploadTable[$13].LowByte,x
	LDA.w #$8C50
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	LDA.w #$6C50
	STA.l SMW_StripeImageUploadTable[$12].LowByte,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	AND.w #$001F
	ASL
	TAY
	LDA.w DATA_049B9F,y
	TAY
	SEP.b #$20
	LDA.w LevelNameStrings,y
	BMI.b CODE_049C51
	JSR.w CODE_049CAB
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	ASL
	ROL
	ROL
	REP.b #$20
	AND.w #$0003
	ASL
	TAY
	LDA.w DATA_049BF7,y
	TAY
	SEP.b #$20
	JSR.w CODE_049CAB

CODE_049C51:
	REP.b #$20
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$00F0
	LSR
	LSR
	LSR
	TAY
	LDA.w DATA_049BC5,y
	TAY
	SEP.b #$20
	LDA.w LevelNameStrings,y
	CMP.b #$DD
	BEQ.b CODE_049C84
	JSR.w CODE_049CAB
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	AND.b #$20
	ASL
	ASL
	ASL
	ROL
	REP.b #$20
	AND.w #$0001
	ASL
	TAY
	LDA.w DATA_049BF7,y
	TAY
	SEP.b #$20
	JSR.w CODE_049CAB

CODE_049C84:
	REP.b #$20
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$000F
	ASL
	TAY
	LDA.w DATA_049BE1,y
	TAY
	SEP.b #$20
	JSR.w CODE_049CAB

CODE_049C96:
	CPX.b !RAM_SMW_Misc_ScratchRAM02
	BCS.b CODE_049CA2
	LDY.w #$011A
	JSR.w CODE_049CAB
	BRA.b CODE_049C96

CODE_049CA2:
	LDA.b #$FF
	STA.l SMW_StripeImageUploadTable[$14].LowByte,x
	REP.b #$20
	RTS

CODE_049CAB:
	LDA.w LevelNameStrings,y
	PHP
	CPX.b !RAM_SMW_Misc_ScratchRAM02
	BCS.b CODE_049CD9
	AND.b #$7F
	CMP.b #$59
	BEQ.b CODE_049CBD
	CMP.b #$5B
	BNE.b CODE_049CC3

CODE_049CBD:
	STA.l SMW_StripeImageUploadTable[$13].LowByte,x
	BRA.b CODE_049CD9

CODE_049CC3:
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	LDA.b #$5D
	STA.l SMW_StripeImageUploadTable[$14].LowByte,x
	LDA.b #$39
	STA.l SMW_StripeImageUploadTable[$02].HighByte,x
	STA.l SMW_StripeImageUploadTable[$14].HighByte,x
	INX
	INX

CODE_049CD9:
	INY
	PLP
	BPL.b CODE_049CAB
	RTS

else
Main:
if !Define_SMW_RelocateStringTables == !TRUE
	; The strings and their offset tables have moved to the relocated
	; strings bank: the whole box is drawn from there -- five bytes, as the
	; code it stands in for. Config/StringTableRelocation.asm.
	JSL.l SMW_RelocatedStrings_LevelName
	RTS
else
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo	;!
	TAX				;!
endif
	CLC				;!
	ADC.w #$0026			;!
	STA.b !RAM_SMW_Misc_ScratchRAM02	;!
	CLC				;!
	ADC.w #$0004			;!
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo	;!
	LDA.w #$2500			;!
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x	;!
	LDA.w #$8B50			;!
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x	;!
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;!
	AND.w #$007F			;!
	ASL				;!
	TAY				;!
	LDA.w Part1Offsets,y		;!
	TAY				;!
	SEP.b #$20			;! A->8
	LDA.w LevelNameStrings,y	;!
	BMI.b CODE_049D3D		;!
	JSR.w CODE_049D7F		;!
CODE_049D3D:
	REP.b #$20			;! A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;!
	AND.w #$00F0			;!
	LSR				;!
	LSR				;!
	LSR				;!
	TAY				;!
	LDA.w Part2Offsets,y		;!
	TAY				;!
	SEP.b #$20			;! A->8
	LDA.w LevelNameStrings,y	;!
	CMP.b #$9F			;!
	BEQ.b CODE_049D58		;!
	JSR.w CODE_049D7F		;!
CODE_049D58:
	REP.b #$20			;! A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;!
	AND.w #$000F			;!
	ASL				;!
	TAY				;!
	LDA.w Part3Offsets,y		;!
	TAY				;!
	SEP.b #$20			;! A->8
	JSR.w CODE_049D7F		;!
CODE_049D6A:
	CPX.b !RAM_SMW_Misc_ScratchRAM02	;!
	BCS.b CODE_049D76		;!
	LDY.w #LevelStr_None		;! The lone terminated space, wherever the strings put it
	JSR.w CODE_049D7F		;!
	BRA.b CODE_049D6A		;!

CODE_049D76:
	LDA.b #$FF			;!
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x	;!
	REP.b #$20			;! A->16
	RTS				;!

CODE_049D7F:
	LDA.w LevelNameStrings,y	;!
	PHP				;!
	CPX.b !RAM_SMW_Misc_ScratchRAM02	;!
	BCS.b CODE_049D95		;!
	AND.b #$7F			;!
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x	;!
	LDA.b #$39			;!
	STA.l SMW_StripeImageUploadTable[$02].HighByte,x	;!
	INX				;!
	INX				;!
CODE_049D95:
	INY				;!
	PLP				;!
	BPL.b CODE_049D7F		;!
	RTS				;!
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_LoadOverworldLayer1AndEvents(Address)
namespace SMW_LoadOverworldLayer1AndEvents
%InsertMacroAtXPosition(<Address>)

DATA_04DC02:
	db $11,$12,$13,$14,$15,$16,$17

Main:
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo	;\
	LSR				;|
	LSR				;| get current player
	TAX				;/
	LDA.w !RAM_SMW_Overworld_MarioMap,x	;\ current submap to player = X
	TAX				;/
	LDA.l DATA_04DC02,x		;\
	STA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad	;/ make it mario start tileset (why do you need the submap to figure that one out?)
	LDA.b #$11			;\
	STA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting	;/ set correct sprite GFX
	LDA.b #$07
	STA.w !RAM_SMW_Misc_LevelModeSetting
	LDA.b #$03
	STA.b !RAM_SMW_Misc_LevelLayoutFlags
	REP.b #$10			; XY->16
	LDX.w #$0000
	TXA
CODE_04DC30:
	JSR.w InitializedOverworldLayer1Tilemap
	CPX.w #$01B0
	BNE.b CODE_04DC30
	REP.b #$30			; AXY->16
	LDA.w #SMW_Map16Data_OverworldLayer1
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w #$0000
CODE_04DC42:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Pointer_Map16Tiles,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INX
	INX
	CPX.w #$0400
	BNE.b CODE_04DC42
	PHB
	LDA.w #$07FF
	LDX.w #Layer1Tilemap
	LDY.w #!RAM_SMW_Blocks_Map16TableLo
	MVN !RAM_SMW_Blocks_Map16TableLo>>16,Layer1Tilemap>>16
	PLB
	JSR.w CODE_04D7F2
	SEP.b #$30			; AXY->8
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_LoadOverworldLayer1AndEvents(Address)
%SMW_RelocatableTableSlot(<Address>, WalkDirections)
if !Define_SMW_RelocateOverworldTables == !FALSE
	%SMW_OverworldTable_WalkDirections()
endif
endmacro

; The table itself, so that the relocated build can emit it where it
; wants it: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedOverworldTables. Nothing here knows which.
macro SMW_OverworldTable_WalkDirections()
namespace SMW_LoadOverworldLayer1AndEvents

incsrc "overworld/tables/walk-directions.asm"
namespace off
endmacro

macro ROUTINE_RT02_SMW_LoadOverworldLayer1AndEvents(Address)
namespace SMW_LoadOverworldLayer1AndEvents
%InsertMacroAtXPosition(<Address>)

InitializedOverworldLayer1Tilemap:
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$00),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$01),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$02),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$03),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$04),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$05),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$06),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$07),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$08),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$09),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$0A),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$0B),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$0C),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$0D),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$0E),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$0F),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$10),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$11),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$12),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$13),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$14),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$15),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$16),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$17),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$18),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$19),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$1A),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$1B),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$1C),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$1D),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$1E),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$1F),x
	INX
	RTS

CODE_04D7F2:
	REP.b #$30			; AXY->16
	LDA.w #$0000
	SEP.b #$20			; A->8
#LM000Hijack_PlaceOverworldLevelAnywhere:
	LDA.b #!RAM_SMW_Overworld_LevelNumberOfEachTileTBL	;\ LM: Rewrites and skips over this code.
	STA.b !RAM_SMW_Misc_ScratchRAM0D			;| This is to allow you to place levels anywhere you want on the overworld.
	LDA.b #!RAM_SMW_Overworld_LevelNumberOfEachTileTBL>>8	;| In the original SMW, the overworld is divided up into chunks of 16x16 tiles ordered internally from left to right, top to bottom.
	STA.b !RAM_SMW_Misc_ScratchRAM0E			;| Within these blocks, the level numbers are arranged going from left to right, top to bottom.
	LDA.b #!RAM_SMW_Overworld_LevelNumberOfEachTileTBL>>16	;| To give an example, the top left section of the main map contains levels 001-00A. The top right section contains 00B-012. The bottom section left contains 013-01D. And the bottom right section contains 01E-024.
	STA.b !RAM_SMW_Misc_ScratchRAM0F			;|
	LDA.b #!RAM_SMW_Overworld_LevelDirectionFlags		;|
	STA.b !RAM_SMW_Misc_ScratchRAM0A			;|
	LDA.b #!RAM_SMW_Overworld_LevelDirectionFlags>>8	;|
	STA.b !RAM_SMW_Misc_ScratchRAM0B			;|
	LDA.b #!RAM_SMW_Overworld_LevelDirectionFlags>>16	;|
	STA.b !RAM_SMW_Misc_ScratchRAM0C			;|
	LDA.b #!RAM_SMW_Blocks_Map16TableLo			;|
	STA.b !RAM_SMW_Misc_ScratchRAM04			;|
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>8			;|
	STA.b !RAM_SMW_Misc_ScratchRAM05			;|
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16			;|
	STA.b !RAM_SMW_Misc_ScratchRAM06			;|
	LDY.w #$0001						;|
	STY.b !RAM_SMW_Misc_ScratchRAM00			;|
	LDY.w #$07FF						;|
	LDA.b #$00						;|
CODE_04D827:							;|
	STA.b [!RAM_SMW_Misc_ScratchRAM0A],y			;|
	STA.b [!RAM_SMW_Misc_ScratchRAM0D],y			;|
	DEY							;|
	BPL.b CODE_04D827					;|
	LDY.w #$0000						;|
	TYX							;|
CODE_04D832:							;|
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y			;|
	CMP.b #$56						;|
	BCC.b CODE_04D849					;|
	CMP.b #$81						;|
	BCS.b CODE_04D849					;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00			;|
	STA.b [!RAM_SMW_Misc_ScratchRAM0D],y			;|
	TAX							;|
	LDA.l PostClearWalkDirections,x				;|
	STA.b [!RAM_SMW_Misc_ScratchRAM0A],y			;|
	INC.b !RAM_SMW_Misc_ScratchRAM00			;|
CODE_04D849:							;|
	INY							;|
	CPY.w #$0800						;|
	BNE.b CODE_04D832					;/
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
CODE_04D851:
	JSR.w CODE_04DA49
	INC.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CMP.b #$6F
	BNE.b CODE_04D851
	RTS
namespace off
endmacro

macro ROUTINE_RT03_SMW_LoadOverworldLayer1AndEvents(Address)
namespace SMW_LoadOverworldLayer1AndEvents
%InsertMacroAtXPosition(<Address>)

CODE_04DA49:
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	AND.w #$00F8
	LSR
	LSR
	LSR
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	AND.w #$0007
	TAX
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Overworld_EventFlags,y
	AND.l SMW_BitTable_DATA_04E44B,x
	BEQ.b Return04DAAC
	REP.b #$20			; A->16
	LDA.w #!RAM_SMW_Blocks_Map16TableLo
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	AND.w #$00FF
	ASL
	TAX
	LDA.l SMW_ChangingLayer1OverworldTiles_Layer1TileLocation,x
	TAY
	LDX.w #SMW_ChangingLayer1OverworldTiles_TilesToBecome-SMW_ChangingLayer1OverworldTiles_TilesThatChange-1	; The last pair: the table's own length, so a grown table is scanned whole
	SEP.b #$20			; A->8
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
CODE_04DA83:
	CMP.l SMW_ChangingLayer1OverworldTiles_TilesThatChange,x
	BEQ.b CODE_04DA8F
	DEX
	BPL.b CODE_04DA83
	JMP.w CODE_04DA9D

CODE_04DA8F:
	LDA.l SMW_ChangingLayer1OverworldTiles_TilesToBecome,x
	STA.b [!RAM_SMW_Misc_ScratchRAM04],y
	CPX.w #$0015
	BNE.b CODE_04DA9D
	INY
	STA.b [!RAM_SMW_Misc_ScratchRAM04],y
CODE_04DA9D:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	JSR.w SMW_CheckIfDestroyTileEventIsActive_Main
	SEP.b #$10			; XY->8
	STZ.w !RAM_SMW_Pointer_OverworldEventProcess
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	JSR.w SMW_OverworldEventProcess07_SilentEventsAndEndOfEvent_Entry2
Return04DAAC:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_RT00_SMW_SharedOverworldPathTables(Address)
namespace SMW_SharedOverworldPathTables
%InsertMacroAtXPosition(<Address>)

DATA_049058:
	dw $FFFF,$0001,$FFFF,$0001

; How may times the bits are shifted to the right to get the direction the
; player walks after beating a level for the layer 1 overworld tile the
; player stands on - 1 except for a zero in which the value isn't shifted.
; Indexed by $7E0DD5 in the order normal exit, secret exit 1, secret exit 2
; and secret exit 3.
DATA_049060:
	db $05,$03,$01,$00

; The direction the player moves after beating a level. Indexed from $7ED800
; after shifting and stored to $7E0DD3.
DATA_049064:
	dw $0000,$0002,$0004,$0006

NoAutoMoveLevels:
;$04906C
	; Table of the no-auto-move levels on the overworld. Each of the values are
	; translevel numbers in 16-bit.
	dw $0028,$0008,$0014,$0036
	dw $003F,$0045

HardCodedOWPaths_LevelNums:
;$049078
	; The list of levels that have hard-coded paths. Each byte represents a
	; level. The value 0xFF means to check for a particular overworld position
	; instead of a level (for the pipe that Chocolate Island 2 leads to).
	; Setting any of these levels to an invalid level (e.g. 0xFE) will disable
	; that hardcoded path.
	db $09,$15			; DONUT PLAINS 2 <--> DONUT PLAINS 1
	db $23,$1B			; CHOCOLATE ISLAND 3 <--> CHOCOLATE FORTRESS
	db $43,$44			; FOREST OF ILLUSION 4 <--> FOREST OF ILLUSION 2
	db $24,$FF			; CHOCOLATE ISLAND 2 <--> Pipe
	db $30,$31			; STAR ROAD (10C) <--> FRONT DOOR

; The 16-bit X and Y position in the overworld that will be used for the
; hardcoded path from the pipe to Chocolate Island 2.
DATA_049082:
	dw $0178

DATA_049084:
	dw $0128

HardCodedOWPaths_Layer1Tiles:
;$049086
; This is a list of all of the hardcoded paths, in the same order as the
; levels defined at $049078. The paths are defined as a list of all the
; Layer 1 tiles that Mario would encounter along the path if the path were
; not hardcoded. Each path ends in a level tile of some kind, which should
; match a visible level tile in the world.
.Path00:
	db $10,$10,$1E,$19,$16,$66
	db $16,$19,$1E,$10,$10,$66
.Path01:
	db $04,$04,$04,$58
	db $04,$04,$04,$66
.Path02:
	db $04,$04,$04,$04,$04,$6A
	db $04,$04,$04,$04,$04,$66
.Path03:
	db $1E,$19,$06,$09,$0F,$20,$1A,$21
	db $1A,$14,$19,$18,$1F,$17,$82
	db $17,$1F,$18,$19,$14,$1A,$21,$1A
	db $20,$0F,$09,$06,$19,$1E,$66
.Path04:
	db $04,$04,$58
	db $04,$04,$5F

HardCodedOWPaths_MovementDirection:
;$0490CA
; Hardcoded path information. For each tile in the list at $049086, there is
; a corresponding byte in this list. These values determine the direction
; Mario should face while walking along that path. $00 = Up, $02 = Down, $04
; = Left, $06 = Right
.Path00:
	db $02,$02,$02,$02,$06,$06
	db $04,$04,$00,$00,$00,$00
.Path01:
	db $04,$04,$04,$04
	db $06,$06,$06,$06
.Path02:
	db $06,$06,$06,$06,$06,$06
	db $04,$04,$04,$04,$04,$04
.Path03:
	db $02,$02,$06,$06,$00,$00,$00,$04
	db $00,$04,$04,$00,$04,$00,$04
	db $06,$02,$06,$02,$06,$06,$02,$06
	db $02,$02,$02,$04,$04,$00,$00
.Path04:
	db $06,$06,$06
	db $04,$04,$04

HardCodedOWPaths_Layer1AndMovementTableIndex:
;$04910E
	; Hardcoded path data. A list of offsets into the fields at $04:9086 and
	; $04:90CA. This list corresponds to the list at $04:9078; this offset
	; tells where the tile data for that level's hardcoded path begins.
	db $00,$06
	db $0C,$10
	db $14,$1A
	db $20,$2F
	db $3E,$41

UNK_049118:
	dw $0008,$0004,$0002,$0001
namespace off
endmacro

macro DATATABLE_RT01_SMW_SharedOverworldPathTables(Address)
namespace SMW_SharedOverworldPathTables
%InsertMacroAtXPosition(<Address>)

; Two bytes per tile, starts at tile $01 and goes to $51. First byte is X
; distance mario moves across tile Second byte is Y distance mario moves
; across tile The distance is based on walking right for a horizontal path
; and walking down for a vertical path (see entry for $04:9F49)
DATA_049EA7:
	db $10,$F8,$10,$00,$10,$FC,$10,$00
	db $10,$FC,$10,$00,$08,$FC,$0C,$F4
	db $FC,$04,$04,$FC,$F8,$10,$00,$10
	db $FC,$08,$FC,$08,$FC,$10,$00,$10
	db $F8,$04,$FC,$10,$00,$10,$10,$08
	db $10,$04,$10,$04,$08,$04,$0C,$0C
	db $04,$04,$04,$04,$08,$10,$FC,$F8
	db $FC,$F8,$04,$10,$F8,$FC,$04,$10
	db $F4,$F4,$0C,$F4,$10,$00,$00,$10
	db $00,$10,$10,$00,$10,$00,$FC,$08
	db $FC,$08,$00,$10,$10,$FC,$10,$FC
	db $FC,$04,$04,$FC,$F8,$10,$00,$10
	db $FC,$10,$10,$04,$10,$00,$04,$10
	db $04,$04,$FC,$F8,$04,$04,$10,$08
	db $0C,$F4,$00,$10,$FC,$10,$10,$00
	db $04,$10,$10,$F8,$00,$10,$00,$10
	db $FC,$10,$10,$00,$00,$10,$00,$10
	db $00,$10,$00,$10,$00,$10,$00,$10
	db $04,$FC,$04,$04,$04,$04,$00,$10
	db $00,$10,$10,$00,$10,$00,$FC,$10
	db $FC,$04

; Two bytes per tile, starts at tile $01 and goes to $51 If the two bytes
; are $01,$00 then the tile is a horizontal path If they are $00,$01 then a
; vertical path. No other values were used in game It seems odd to use two
; bytes to do this, so it might be worth experimenting with other values
DATA_049F49:
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$00,$01,$00,$01
	db $00,$01,$00,$01,$01,$00,$01,$00
	db $00,$01,$01,$00,$01,$00,$01,$00
	db $00,$01,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$00,$01
	db $00,$01,$01,$00,$00,$01,$01,$00
	db $00,$01,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$00,$01
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $00,$01,$00,$01,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$00,$01,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $00,$01,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $00,$01

; One byte per tile, starts at tile $01 and goes to $51 Mario pose while
; walking 0 - Mario Vertical 4 - Mario Horizontal 8 - Mario Swimming
; Vertical C - Mario Swimming Horizontal 10 - Entering Level 14 - Climbing
; 18-FF - Unused Only multiples of 4 seem to be used, using a value
; inbetween just seems to result in oddly animated versions of the normal
; values
DATA_049FEB:
	db $04,$04,$04,$04,$04,$04,$04,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $04,$00,$00,$04,$04,$04,$04,$00
	db $00,$00,$00,$00,$00,$00,$04,$00
	db $00,$00,$04,$00,$00,$04,$04,$08
	db $08,$08,$0C,$0C,$08,$08,$08,$08
	db $08,$0C,$0C,$08,$08,$08,$08,$0C
	db $08,$08,$08,$0C,$08,$0C,$14,$14
	db $14,$04,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$04,$04,$08
	db $00

DATA_04A03C:
	db $07,$09,$0A,$0D,$0E,$11,$17,$19
	db $1A,$1C,$1D,$1F,$28,$29,$2D,$2E
	db $35,$36,$37,$49,$4A,$4B,$4D,$51

DATA_04A054:
	db $08,$FC,$FC,$08,$FC,$08,$FC,$08
	db $FC,$08,$04,$00,$08,$04,$04,$08
	db $04,$08,$04,$00,$04,$08,$04,$00
	db $FC,$08,$00,$00,$FC,$08,$FC,$08
	db $04,$00,$04,$00,$00,$00,$08,$FC
	db $08,$04,$08,$04,$FC,$08,$08,$FC

DATA_04A084:
	dw $0004,$FFF8
	dw $0008,$FFFC
	dw $FFF8,$0004
	dw $FFF8,$0004
	dw $0008,$FFFC
	dw $0004,$0004
	dw $0004,$0008
	dw $0008,$0004
	dw $FFF8,$FFFC
	dw $0000,$0000
	dw $0008,$0004
	dw $0004,$0004
	dw $FFF8,$0004
	dw $0004,$0004
	dw $0008,$FFFC
	dw $FFF8,$0004
	dw $0004,$0004
	dw $0000,$0000
	dw $0004,$0004
	dw $0004,$FFF8
	dw $0004,$0008
	dw $FFFC,$FFF8
	dw $FFF8,$0004
	dw $FFFC,$0008

DATA_04A0E4:
	db $02,$02,$02,$02,$02,$00,$02,$02
	db $02,$00,$02,$00,$02,$00,$02,$02
	db $00,$00,$00,$02,$02,$02,$02,$02
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_LevelNames(Address)
namespace SMW_LevelNames
%InsertMacroAtXPosition(<Address>)

; The word format is the reading routine's, and the two are forked together:
; the Japanese release decodes these words with a fourth lookup and its own
; string bank, so its payload is a sibling file rather than a branch of the
; editable fragment -- the editor's level-names region covers the
; international targets and leaves J's table alone.
if !Define_Global_ROMToAssemble == !ROM_SMW_J
Main:
	incsrc "overworld/levelnames-j.asm"
else
incsrc "overworld/tables/level-names.asm"
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_LoadOverworldLayer2AndEventsTilemaps(Address)
namespace SMW_LoadOverworldLayer2AndEventsTilemaps
%InsertMacroAtXPosition(<Address>)

; Routine that decompresses and uploads the overworld's layer 2 tilemap to
; the buffer at $7F4000. It's just a wrapper that JSRs to $04DC6A and
; preserves the processor flags (PHP : JSR : PLP). You can JSL to this
; routine to reload the overworld's layer 2. This can be useful if modifying
; $7F4000 (for example, if you want to load the overworld after the staff
; roll cutscene has played out).
Main:
	PHP
	JSR.w Sub
	PLP
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_LoadOverworldLayer2AndEventsTilemaps(Address)
namespace SMW_LoadOverworldLayer2AndEventsTilemaps
%InsertMacroAtXPosition(<Address>)

; The base Layer 2 tilemap (tile numbers) for the overworld, compressed via
; LC_RLE2. Combines with the YXPCCCTT table at $04C02B. Lunar Magic may move
; this table dynamically to (read1($04DC79)<<16)|read2($04DC72).
OverworldLayer2Tilemap:
.Tiles:
	incbin "overworld/layer2/tiles.bin"

; The base Layer 2 tilemap (YXPCCCTT) for the overworld, compressed via
; LC_RLE2. Combines with the tile number table at $04A533. Lunar Magic may
; move this table dynamically to (read1($04DC79)<<16)|read2($04DC8D).
.Prop:
	incbin "overworld/layer2/properties.bin"
namespace off
endmacro

macro ROUTINE_RT02_SMW_LoadOverworldLayer2AndEventsTilemaps(Address)
namespace SMW_LoadOverworldLayer2AndEventsTilemaps
%InsertMacroAtXPosition(<Address>)

; Routine that decompresses and uploads the overworld's layer 2 tilemap to
; $7F4000 (including all the event data). Additionally, it loads all the
; currently activated events into the tilemap. If you need this, call the
; JSL wrapper at $04DAAD.
Sub:
	SEP.b #$30			; AXY->8
	JSR.w CODE_04DD40
	REP.b #$20			; A->16
	LDA.w #OverworldLayer2Tilemap_Tiles
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$30			; AXY->8
	LDA.b #OverworldLayer2Tilemap_Tiles>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
	REP.b #$10			; XY->16
	LDY.w #$4000
	STY.b !RAM_SMW_Misc_ScratchRAM0E
	LDY.w #$0000
	TYX
	JSR.w SMW_BufferOverworldLayer2Tilemap_Main
	REP.b #$20			; A->16
	LDA.w #OverworldLayer2Tilemap_Prop
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	LDX.w #$0001
	LDY.w #$0000
	JSR.w SMW_BufferOverworldLayer2Tilemap_Main
	SEP.b #$30			; AXY->8
	LDA.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0F
-:
	JSR.w CODE_04E453
	INC.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CMP.b #$6F
	BNE.b -
	RTS
namespace off
endmacro

macro ROUTINE_RT03_SMW_LoadOverworldLayer2AndEventsTilemaps(Address)
namespace SMW_LoadOverworldLayer2AndEventsTilemaps
%InsertMacroAtXPosition(<Address>)

CODE_04DD40:
	REP.b #$10			; XY->16
	SEP.b #$20			; A->8
	LDY.w #SMW_OverworldLayer2EventTilemap_Prop
	STY.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #SMW_OverworldLayer2EventTilemap_Prop>>16
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDX.w #$0000
	TXY
	JSR.w CODE_04DD57
	SEP.b #$30			; AXY->8
	RTS

; Subroutine that decompresses LC_RLE1 data.
CODE_04DD57:
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Misc_ScratchRAM02],y
	INY
	STA.b !RAM_SMW_Misc_ScratchRAM05
	AND.b #$80
	BNE.b CODE_04DD71
CODE_04DD62:
	LDA.b [!RAM_SMW_Misc_ScratchRAM02],y
	STA.l !RAM_SMW_Overworld_Layer2EventTiles,x
	INY
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM05
	BPL.b CODE_04DD62
	JMP.w CODE_04DD83

CODE_04DD71:
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	AND.b #$7F
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b [!RAM_SMW_Misc_ScratchRAM02],y
CODE_04DD79:
	STA.l !RAM_SMW_Overworld_Layer2EventTiles,x
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM05
	BPL.b CODE_04DD79
	INY
CODE_04DD83:
	REP.b #$20			; A->16
	LDA.b [!RAM_SMW_Misc_ScratchRAM02],y
	CMP.w #$FFFF
	BNE.b CODE_04DD57
	RTS
namespace off
endmacro

macro ROUTINE_RT04_SMW_LoadOverworldLayer2AndEventsTilemaps(Address)
namespace SMW_LoadOverworldLayer2AndEventsTilemaps
%InsertMacroAtXPosition(<Address>)

; Routine that loads the overworld layer 2 events on game load and OW load
; after cutscenes (possibly at every OW load).
CODE_04E453:
	SEP.b #$30			; AXY->8
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	AND.b #$07
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	LSR
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_Overworld_EventFlags,y
	AND.l SMW_BitTable_DATA_04E44B,x
	BNE.b CODE_04E46A
	RTS

CODE_04E46A:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	ASL
	TAX
	REP.b #$20			; A->16
	LDA.l SMW_Layer2EventData_Ptrs,x
	STA.w !RAM_SMW_Overworld_StartingEventTileLo
	LDA.l SMW_Layer2EventData_Ptrs+$02,x
	STA.w !RAM_SMW_Overworld_FinalEventTileLo
	CMP.w !RAM_SMW_Overworld_StartingEventTileLo
	BEQ.b CODE_04E493
CODE_04E483:
	JSR.w SMW_BufferEventTileToLayer2Tilemap_Main
	REP.b #$20			; A->16
	INC.w !RAM_SMW_Overworld_StartingEventTileLo
	LDA.w !RAM_SMW_Overworld_StartingEventTileLo
	CMP.w !RAM_SMW_Overworld_FinalEventTileLo
	BNE.b CODE_04E483
CODE_04E493:
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GetXAndYDispOfCurrentEventTileSprite(Address)
namespace SMW_GetXAndYDispOfCurrentEventTileSprite
%InsertMacroAtXPosition(<Address>)

; Subroutine used to get the relative (screen) position of the path fade
; sprite. Returns the X position in $00 and Y position in $01.
Main:
	LDA.w !RAM_SMW_Overworld_OnScreenXPosOfCurrentEventTile
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Overworld_OnScreenYPosOfCurrentEventTile
	CLC
	SBC.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BufferEventTileToLayer2Tilemap(Address)
namespace SMW_BufferEventTileToLayer2Tilemap
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Overworld_StartingEventTileLo
	ASL
	ASL
	TAX
	LDA.l SMW_Layer2EventData_TileEntries,x
	TAY
	LDA.l SMW_Layer2EventData_TileEntries+$02,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
Entry2:
	SEP.b #$20			; A->8
	LDA.b #!RAM_SMW_Overworld_Layer2EventTiles>>16
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b #SMW_OverworldLayer2EventTilemap_Tiles>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	REP.b #$20			; A->16
	LDA.w #!RAM_SMW_Overworld_Layer2EventTiles
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #SMW_OverworldLayer2EventTilemap_Tiles
	STA.b !RAM_SMW_Misc_ScratchRAM09
	CPY.w #SMW_OverworldLayer2EventTilemap_Tiles_TwoByTwo-SMW_OverworldLayer2EventTilemap_Tiles
	BCC.b CODE_04E4CA
	JSR.w Buffer2x2Tile
	JMP.w CODE_04E4CD

CODE_04E4CA:
	JSR.w Buffer6x6Tile
CODE_04E4CD:
	SEP.b #$30			; AXY->8
	RTS

Buffer2x2Tile:
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_04E4D5:
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM0C
CODE_04E4DC:
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Misc_ScratchRAM09],y
	STA.l !RAM_SMW_Overworld_Layer2Tiles,x
	INX
	LDA.b [!RAM_SMW_Misc_ScratchRAM06],y
	STA.l !RAM_SMW_Overworld_Layer2Tiles,x
	INY
	INX
	REP.b #$20			; A->16
	TXA
	AND.w #$003F
	BNE.b CODE_04E4FF
	DEX
	TXA
	AND.w #$FFC0
	CLC
	ADC.w #$0800
	TAX
CODE_04E4FF:
	DEC.b !RAM_SMW_Misc_ScratchRAM0C
	BPL.b CODE_04E4DC
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	TAX
	CLC
	ADC.w #$0040
	STA.b !RAM_SMW_Misc_ScratchRAM04
	AND.w #$07C0
	BNE.b CODE_04E51B
	TXA
	AND.w #$F83F
	CLC
	ADC.w #$1000
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_04E51B:
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_04E4D5
	RTS

Buffer6x6Tile:
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_04E525:
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM0C
CODE_04E52C:
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Misc_ScratchRAM09],y
	STA.l !RAM_SMW_Overworld_Layer2Tiles,x
	INX
	LDA.b [!RAM_SMW_Misc_ScratchRAM06],y
	STA.l !RAM_SMW_Overworld_Layer2Tiles,x
	INY
	INX
	REP.b #$20			; A->16
	TXA
	AND.w #$003F
	BNE.b CODE_04E54F
	DEX
	TXA
	AND.w #$FFC0
	CLC
	ADC.w #$0800
	TAX
CODE_04E54F:
	DEC.b !RAM_SMW_Misc_ScratchRAM0C
	BPL.b CODE_04E52C
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	TAX
	CLC
	ADC.w #$0040
	STA.b !RAM_SMW_Misc_ScratchRAM04
	AND.w #$07C0
	BNE.b CODE_04E56B
	TXA
	AND.w #$F83F
	CLC
	ADC.w #$1000
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_04E56B:
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_04E525
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BufferEventTileToStripeImageTable(Address)
namespace SMW_BufferEventTileToStripeImageTable
%InsertMacroAtXPosition(<Address>)

Buffer2x2Tile:
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_04E776:
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
	LDY.w #$0300
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	AND.w #$001F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w #$0020
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.w #$0001
	BNE.b CODE_04E79B
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	ASL
	DEC
	XBA
	TAY
CODE_04E79B:
	TYA
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDY.b !RAM_SMW_Misc_ScratchRAM00
CODE_04E7A9:
	LDA.b [!RAM_SMW_Misc_ScratchRAM0C],y
	AND.b !RAM_SMW_Misc_ScratchRAM0A
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
	INY
	INY
	TYA
	AND.w #$003F
	BNE.b CODE_04E7E5
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BEQ.b CODE_04E7E5
	DEY
	TYA
	AND.w #$FFC0
	CLC
	ADC.w #$0800
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	XBA
	AND.w #$3BE0
	CLC
	ADC.w #$0400
	XBA
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	ASL
	DEC
	XBA
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
CODE_04E7E5:
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_04E7A9
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	XBA
	CLC
	ADC.w #$0020
	XBA
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	CLC
	ADC.w #$0040
	STA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$07C0
	BNE.b CODE_04E81C
	TYA
	AND.w #$F83F
	CLC
	ADC.w #$1000
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	XBA
	SEC
	SBC.w #$0020
	AND.w #$341F
	CLC
	ADC.w #$0800
	XBA
	STA.b !RAM_SMW_Misc_ScratchRAM02
CODE_04E81C:
	DEC.b !RAM_SMW_Misc_ScratchRAM06
	BMI.b Return04E823
	JMP.w CODE_04E776

Return04E823:
	RTS

Buffer6x6Tile:
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
CODE_04E82E:
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
	LDY.w #$0B00
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	AND.w #$001F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w #$0020
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.w #$0006
	BCS.b CODE_04E85B
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	ASL
	DEC
	XBA
	TAY
	LDA.w #$0006
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM08
CODE_04E85B:
	TYA
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDY.b !RAM_SMW_Misc_ScratchRAM00
CODE_04E869:
	LDA.b [!RAM_SMW_Misc_ScratchRAM0C],y
	AND.b !RAM_SMW_Misc_ScratchRAM0A
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
	INY
	INY
	TYA
	AND.w #$003F
	BNE.b CODE_04E8A5
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BEQ.b CODE_04E8A5
	DEY
	TYA
	AND.w #$FFC0
	CLC
	ADC.w #$0800
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	XBA
	AND.w #$3BE0
	CLC
	ADC.w #$0400
	XBA
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	ASL
	DEC
	XBA
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	INX
CODE_04E8A5:
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_04E869
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	XBA
	CLC
	ADC.w #$0020
	XBA
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	CLC
	ADC.w #$0040
	STA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$07C0
	BNE.b CODE_04E8DC
	TYA
	AND.w #$F83F
	CLC
	ADC.w #$1000
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	XBA
	SEC
	SBC.w #$0020
	AND.w #$341F
	CLC
	ADC.w #$0800
	XBA
	STA.b !RAM_SMW_Misc_ScratchRAM02
CODE_04E8DC:
	DEC.b !RAM_SMW_Misc_ScratchRAM06
	BMI.b Return04E8E3
	JMP.w CODE_04E82E

Return04E8E3:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_RT00_SMW_Layer2EventData(Address)
%SMW_RelocatableTableSlot(<Address>, Layer2EventEntries)
if !Define_SMW_RelocateOverworldTables == !FALSE
	%SMW_OverworldTable_Layer2EventEntries()
endif
endmacro

; The table itself, so that the relocated build can emit it where it
; wants it: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedOverworldTables. Nothing here knows which.
macro SMW_OverworldTable_Layer2EventEntries()
namespace SMW_Layer2EventData

incsrc "overworld/tables/layer2-events.asm"
namespace off
endmacro

macro DATATABLE_RT01_SMW_Layer2EventData(Address)
%SMW_RelocatableTableSlot(<Address>, Layer2EventPtrs)
if !Define_SMW_RelocateOverworldTables == !FALSE
	%SMW_OverworldTable_Layer2EventPtrs()
endif
endmacro

; The table itself, so that the relocated build can emit it where it
; wants it: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedOverworldTables. Nothing here knows which.
macro SMW_OverworldTable_Layer2EventPtrs()
namespace SMW_Layer2EventData

incsrc "overworld/layer2-event-pointers.asm"
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_RT00_SMW_ChangingLayer1OverworldTiles(Address)
%SMW_RelocatableTableSlot(<Address>, Layer1EventLocations)
if !Define_SMW_RelocateOverworldTables == !FALSE
	%SMW_OverworldTable_Layer1EventLocations()
endif
endmacro

; The table itself, so that the relocated build can emit it where it
; wants it: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedOverworldTables. Nothing here knows which.
macro SMW_OverworldTable_Layer1EventLocations()
namespace SMW_ChangingLayer1OverworldTiles

incsrc "overworld/tables/layer1-event-locations.asm"
namespace off
endmacro

macro DATATABLE_RT01_SMW_ChangingLayer1OverworldTiles(Address)
%SMW_RelocatableTableSlot(<Address>, Layer1EventSwaps)
if !Define_SMW_RelocateOverworldTables == !FALSE
	%SMW_OverworldTable_Layer1EventSwaps()
endif
endmacro

; The table itself, so that the relocated build can emit it where it
; wants it: in place at the slot above, or into the reserved run out of
; %SMW_PlaceRelocatedOverworldTables. Nothing here knows which.
macro SMW_OverworldTable_Layer1EventSwaps()
namespace SMW_ChangingLayer1OverworldTiles

incsrc "overworld/tables/layer1-event-swaps.asm"
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_LifeExchangeText(Address)
namespace SMW_LifeExchangeText
%InsertMacroAtXPosition(<Address>)

cleartable
Main:
	%StripeImageHeader(Mario, $09, $12, 0, $0000, 3)
	;dw "MARIO"
; MARIO text in the Lives Exchanger box. Odd bytes are tile numbers. Even
; bytes are YXPCCCTT properties.
db $16,$28,$0A,$28,$1B,$28,$12,$28,$18,$28
MarioEnd:
	%StripeImageHeader(Luigi, $12, $12, 0, $0000, 3)
	;dw "LUIGI"
; LUIGI text in the Lives Exchanger box. Odd bytes are tile numbers. Even
; bytes are YXPCCCTT properties.
db $15,$28,$1E,$28,$12,$28,$10,$28,$12,$28
LuigiEnd:
	%StripeImageHeader(MarioLives, $0B, $10, 0, $0000, 3)
	dw $2826	; Small x
	;dw "00"
db $00,$28,$00,$28
MarioLivesEnd:
	%StripeImageHeader(LuigiLives, $14, $10, 0, $0000, 3)
	dw $2826	; Small x
	;dw "00"
db $00,$28,$00,$28
LuigiLivesEnd:
	%StripeImageHeader(ArrowTopHalf, $0F, $10, 0, $0000, 3)
	db $FC,$38,$FC,$38
ArrowTopHalfEnd:
	%StripeImageHeader(ArrowBottomHalf, $0F, $11, 0, $0000, 3)
	db $FC,$38,$FC,$38
ArrowBottomHalfEnd:
	%StripeImageHeader(MarioHalo, $09, $0E, 0, $0000, 3)
	; Tiles for Mario's halo in the Life Exchange box. Even bytes are tile
	; numbers and odd bytes are their YXPCCCTT properties.
	dw $2985,$6985
MarioHaloEnd:
	%StripeImageHeader(LuigiHalo, $12, $0E, 0, $0000, 3)
	; Tiles for Luigi's halo in the Life Exchange box. Even bytes are tile
	; numbers and odd bytes are their YXPCCCTT properties.
	dw $2985,$6985
LuigiHaloEnd:
End:
	db $FF
cleartable
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_QuitToTitleScreenText(Address)			; Note: This is a SMAS exclusive routine macro
namespace SMW_QuitToTitleScreenText
%InsertMacroAtXPosition(<Address>)

cleartable

Main:
	%StripeImageHeader(Continue, $06, $0E, 0, $0000, 3)
	;dw "CONTINUE WITHOUT SAVE"
	db $2D,$39,$7A,$38,$79,$38,$2F,$39,$82,$38,$79,$38,$7B,$38,$73,$39,$FC,$38,$81,$38,$82,$38,$2F,$39,$84,$38,$7A,$38,$7B,$38,$2F,$39,$FC,$38,$31,$39,$71,$39,$80,$38,$73,$39
ContinueEnd:
	%StripeImageHeader(End, $06, $10, 0, $0000, 3)
	;dw "END WITHOUT SAVE"
	db $73,$39,$79,$38,$7C,$38,$FC,$38,$81,$38,$82,$38,$2F,$39,$84,$38,$7A,$38,$7B,$38,$2F,$39,$FC,$38,$31,$39,$71,$39,$80,$38,$73,$39
EndEnd:
	db $FF
cleartable
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_OWSpr01_Lakitu(Address)
namespace SMW_OWSpr01_Lakitu
%InsertMacroAtXPosition(<Address>)

DATA_04F8A6:
	db $01,$01,$03,$01,$01,$01,$01,$02

DATA_04F8AE:
	db $0C,$0C,$12,$12,$12,$12,$0C,$0C

DATA_04F8B6:
	db $10,$00,$08,$00,$20,$00,$20,$00

DATA_04F8BE:
	db $10,$00,$30,$00,$08,$00,$10,$00

Acceleration:
	db $01,$FF

XYSpeedCap:
	db $10,$F0

ZSpeedCap:
	db $10,$F0

Main:
;$04F8CC
	JSR.w SMW_UpdateOverworldSpritePosition_Main
	CLC
	JSR.w SMW_DrawOverworldSpriteShadow_Main
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM04
	SEP.b #$20			; A->8
	JSR.w SMW_SetOverworldSpriteFrameIndex_Main
	LDX.b #$06
	AND.b #$10
	BEQ.b ADDR_04F8E8
	INX
ADDR_04F8E8:
	STX.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_04F8A6,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b ADDR_04F8F6
	INC.b !RAM_SMW_Misc_ScratchRAM01
ADDR_04F8F6:
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CLC
	ADC.w DATA_04F8AE,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b #$32
	XBA
	LDA.b #$28
	JSR.w SMW_OWSpr05_Cloud_CODE_04FB7B
	LDX.b !RAM_SMW_Misc_ScratchRAM06
	DEX
	DEX
	BPL.b ADDR_04F8E8
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main
	LDA.b #$32
	XBA
	LDA.b #$26
	JSR.w SMW_OWSpr05_Cloud_CODE_04FB7A
	LDA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E15,x
	BEQ.b ADDR_04F928
	JMP.w CalculateOverworldLakitusSpeed

ADDR_04F928:
	LDA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E05,x
	AND.b #$01
	TAY
	LDA.w !RAM_SMW_OWSpr_ZSpeed,x
	CLC
	ADC.w Acceleration,y
	STA.w !RAM_SMW_OWSpr_ZSpeed,x
	CMP.w ZSpeedCap,y
	BNE.b ADDR_04F945
	LDA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E05,x
	EOR.b #$01
	STA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E05,x
ADDR_04F945:
	JSR.w SMW_CheckForPlayerToOverworldSpriteCollision_SubOverworldHorizAndVertPos
	LDY.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0DF5,x
	LDA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0DF5+$0F,x
	ASL
	EOR.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b ADDR_04F95D
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	CMP.w DATA_04F8B6,y
	LDA.w #$0040
	BCS.b ADDR_04F96D
ADDR_04F95D:
	LDA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0DF5+$0F,x
	EOR.b !RAM_SMW_Misc_ScratchRAM02
	ASL
	BCC.b ADDR_04F96D
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.w DATA_04F8BE,y
	LDA.w #$0080
ADDR_04F96D:
	SEP.b #$20			; A->8
	BCC.b ADDR_04F97F
	EOR.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E05,x
	STA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E05,x
	JSR.w SMW_SetOverworldSpriteFrameIndex_Main
	AND.b #$06
	STA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0DF5,x
ADDR_04F97F:
	TXA
	CLC
	ADC.b #!Define_SMW_MaxOverworldSpriteSlot+$01
	TAX
	LDA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0DF5,x
	ASL
	JSR.w ADDR_04F993
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
	LDA.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E05,x
	ASL
	ASL
ADDR_04F993:
	LDY.b #$00
	BCS.b ADDR_04F998
	INY
ADDR_04F998:
	LDA.w !RAM_SMW_OWSpr_XSpeed,x
	CLC
	ADC.w Acceleration,y
	CMP.w XYSpeedCap,y
	BEQ.b Return04F9A7
	STA.w !RAM_SMW_OWSpr_XSpeed,x
Return04F9A7:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_OWSpr01_Lakitu(Address)
namespace SMW_OWSpr01_Lakitu
%InsertMacroAtXPosition(<Address>)

CalculateOverworldLakitusSpeed:
	JSR.w SMW_CheckForPlayerToOverworldSpriteCollision_SubOverworldHorizAndVertPos
	LSR.b !RAM_SMW_Misc_ScratchRAM06
	LSR.b !RAM_SMW_Misc_ScratchRAM08
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_OWSpr_ZPosLo,x
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	STZ.b !RAM_SMW_Misc_ScratchRAM05
	LDY.b #$04
	CMP.b !RAM_SMW_Misc_ScratchRAM08
	BCS.b ADDR_04FF49
	LDY.b #$02
	LDA.b !RAM_SMW_Misc_ScratchRAM08
ADDR_04FF49:
	CMP.b !RAM_SMW_Misc_ScratchRAM06
	BCS.b ADDR_04FF51
	LDY.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM06
ADDR_04FF51:
	CMP.b #$01
	BCS.b ADDR_04FF67
	STZ.w !RAM_SMW_OWSpr01_Lakitu_UnknownTable7E0E15,x
	STZ.w !RAM_SMW_OWSpr_XSpeed,x
	STZ.w !RAM_SMW_OWSpr_YSpeed,x
	STZ.w !RAM_SMW_OWSpr_ZSpeed,x
	LDA.b #$40
	STA.w !RAM_SMW_OWSpr_ZPosLo,x
	RTS

ADDR_04FF67:
	STY.b !RAM_SMW_Misc_ScratchRAM0C
	LDX.b #$04
ADDR_04FF6B:
	CPX.b !RAM_SMW_Misc_ScratchRAM0C
	BNE.b ADDR_04FF73
	LDA.b #$20
	BRA.b ADDR_04FF91

ADDR_04FF73:
	STZ.w !REGISTER_DividendLo	; Dividend (Low Byte)
	LDA.b !RAM_SMW_Misc_ScratchRAM06,x
	STA.w !REGISTER_DividendHi	; Dividend (High-Byte)
	LDA.w !RAM_SMW_Misc_ScratchRAM06,y
	STA.w !REGISTER_Divisor		; Divisor B
	NOP #6
	REP.b #$20			; A->16
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
	LSR
	LSR
	LSR
	SEP.b #$20			; A->8
ADDR_04FF91:
	BIT.b !RAM_SMW_Misc_ScratchRAM01,x
	BMI.b ADDR_04FF98
	EOR.b #$FF
	INC
ADDR_04FF98:
	STA.b !RAM_SMW_Misc_ScratchRAM00,x
	DEX
	DEX
	BPL.b ADDR_04FF6B
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_OWSpr_XSpeed,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_OWSpr_YSpeed,x
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !RAM_SMW_OWSpr_ZSpeed,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OWSpr02_BlueBird(Address)
namespace SMW_OWSpr02_BlueBird
%InsertMacroAtXPosition(<Address>)

DATA_04F9A8:
	db $4E,$4F,$5E,$4F

DATA_04F9AC:
	db $08,$07,$04,$07

DATA_04F9B0:
	db $00,$01,$04,$01

DATA_04F9B4:
	db $01,$07,$09,$07

Main:
;$04F9B8
	CLC
	JSR.w SMW_DrawOverworldSpriteShadow_Main
	JSR.w SMW_CheckForPlayerToOverworldSpriteCollision_SubOverworldHorizAndVertPos
	SEP.b #$20			; A->8
	LDY.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BMI.b ADDR_04F9C8
	INY
ADDR_04F9C8:
	LDA.w !RAM_SMW_OWSpr_XSpeed,x
	CLC
	ADC.w SMW_OWSpr01_Lakitu_Acceleration,y
	CMP.w SMW_OWSpr01_Lakitu_XYSpeedCap,y
	BEQ.b ADDR_04F9D7
	STA.w !RAM_SMW_OWSpr_XSpeed,x
ADDR_04F9D7:
	LDY.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LDA.w !RAM_SMW_Overworld_MarioYPosLo,y
	STA.w !RAM_SMW_OWSpr_YPosLo,x
	LDA.w !RAM_SMW_Overworld_MarioYPosHi,y
	STA.w !RAM_SMW_OWSpr_YPosHi,x
	JSR.w SMW_UpdateOverworldSpritePosition_Main
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main
	LDA.b #$36
	LDY.w !RAM_SMW_OWSpr_XSpeed,x
	BMI.b ADDR_04F9F5
	ORA.b #$40
ADDR_04F9F5:
	PHA
	XBA
	LDA.b #$4C
	JSR.w SMW_OWSpr05_Cloud_CODE_04FB7A
	PLA
	XBA
	JSR.w SMW_SetOverworldSpriteFrameIndex_Main
	LSR
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w DATA_04F9AC,y
	BIT.w !RAM_SMW_OWSpr_XSpeed,x
	BMI.b ADDR_04FA12
	LDA.w DATA_04F9B0,y
ADDR_04FA12:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b ADDR_04FA1B
	INC.b !RAM_SMW_Misc_ScratchRAM01
ADDR_04FA1B:
	LDA.w DATA_04F9B4,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM02
	BCC.b ADDR_04FA27
	INC.b !RAM_SMW_Misc_ScratchRAM03
ADDR_04FA27:
	LDA.w DATA_04F9A8,y
	CLC
	JMP.w SMW_OWSpr05_Cloud_CODE_04FB7B
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OWSpr03_CheepCheep(Address)
namespace SMW_OWSpr03_CheepCheep
%InsertMacroAtXPosition(<Address>)

; Where a Cheep Cheep starts, per trigger tile: one byte each, indexed by
; the tile the player stands on less $4E. Written into the sprite's position
; the frame it is triggered, so a Cheep Cheep slot's own position in
; SpriteSlotData is dead data -- the shipped one holds (0, 0).
InitialXLo:
	db $70,$50,$B0

InitialXHi:
	db $00,$01,$00

InitialYLo:
	db $CF,$8F,$7F

InitialYHi:
	db $00,$00,$01

DATA_04FA3A:
	db $73,$72,$63,$62

Main:
;$04FA3E
	LDA.w !RAM_SMW_OWSpr03_CheepCheep_UnknownTable7E0DF5,x
	BNE.b CODE_04FA83
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	SEC
	SBC.b #$4E
	CMP.b #$03
	BCS.b Return04FA82
	TAY
	LDA.w InitialXLo,y
	STA.w !RAM_SMW_OWSpr_XPosLo,x
	LDA.w InitialXHi,y
	STA.w !RAM_SMW_OWSpr_XPosHi,x
	LDA.w InitialYLo,y
	STA.w !RAM_SMW_OWSpr_YPosLo,x
	LDA.w InitialYHi,y
	STA.w !RAM_SMW_OWSpr_YPosHi,x
	JSR.w SMW_SetOverworldSpriteFrameIndex_Main
	LSR
	ROR
	LSR
	AND.b #$40
	ORA.b #$12
	STA.w !RAM_SMW_OWSpr03_CheepCheep_UnknownTable7E0DF5,x
	LDA.b #$24
	STA.w !RAM_SMW_OWSpr_ZSpeed,x
	LDA.b #!Define_SMW_Sound1DF9_Swim
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_04FA7D:
	LDA.b #$0F
	STA.w !RAM_SMW_OWSpr03_CheepCheep_UnknownTable7E0E25,x
Return04FA82:
	RTS

CODE_04FA83:
	DEC.w !RAM_SMW_OWSpr_ZSpeed,x
	LDA.w !RAM_SMW_OWSpr_ZSpeed,x
	CMP.b #$E4
	BNE.b CODE_04FA90
	JSR.w CODE_04FA7D
CODE_04FA90:
	JSR.w SMW_UpdateOverworldSpritePosition_Main
	LDA.w !RAM_SMW_OWSpr_ZPosLo,x
	ORA.w !RAM_SMW_OWSpr03_CheepCheep_UnknownTable7E0E25,x
	BNE.b CODE_04FA9E
	STZ.w !RAM_SMW_OWSpr03_CheepCheep_UnknownTable7E0DF5,x
CODE_04FA9E:
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main
	LDA.w !RAM_SMW_OWSpr03_CheepCheep_UnknownTable7E0DF5,x
	LDY.b #$08
	BIT.w !RAM_SMW_OWSpr_ZSpeed,x
	BPL.b CODE_04FAAF
	EOR.b #$C0
	LDY.b #$10
CODE_04FAAF:
	XBA
	TYA
	LDY.b #$4A
	AND.b !RAM_SMW_Counter_GlobalFrames
	BEQ.b CODE_04FAB9
	LDY.b #$48
CODE_04FAB9:
	TYA
	JSR.w SMW_OWSpr04_PiranhaPlant_GenericOverworldSpriteGFXRt_Main
	JSR.w SMW_AddZPositionToTempYPos_Main
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM02
	BCS.b CODE_04FAC9
	DEC.b !RAM_SMW_Misc_ScratchRAM03
CODE_04FAC9:
	LDA.b #$36
	XBA
	LDA.w !RAM_SMW_OWSpr03_CheepCheep_UnknownTable7E0E25,x
	BEQ.b Return04FA82
	LSR
	LSR
	PHY
	TAY
	LDA.w DATA_04FA3A,y
	PLY
	PHA
	JSR.w SMW_OWSpr03_CheepCheep_GenericOverworldSpriteGFXRt_Draw8x8
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	LDA.b #$76
	XBA
	PLA
GenericOverworldSpriteGFXRt_Draw8x8:
	CLC
	JMP.w SMW_OWSpr04_PiranhaPlant_GenericOverworldSpriteGFXRt_Entry2
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OWSpr04_PiranhaPlant(Address)
namespace SMW_OWSpr04_PiranhaPlant
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_CheckForPlayerToOverworldSpriteCollision_Main			; Note: This sprite doesn't do anything special when it touches Mario or Luigi.
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main	; NOP this and the sprite doesn't appear
	JSR.w SMW_SetOverworldSpriteFrameIndex_Main	; NOP this and the sprite stops animating.
	LDY.b #$2A			;Tile for pirahna plant, #1
	AND.b #$08
	BEQ.b CODE_04FB02
	LDY.b #$2C			; Tile for pirahna plant, #2, stored in $0242
CODE_04FB02:
	LDA.b #$32			; YXPPCCCT - 00110010
	XBA
	TYA
GenericOverworldSpriteGFXRt:
.Main:
;$04FB06
	SEC
	LDY.w SMW_OverworldSpriteOAMIndexes_Main,x
.Entry2:
	STA.w SMW_OAMBuffer[$10].Tile,y	;Tilemap
	XBA
	STA.w SMW_OAMBuffer[$10].Prop,y	;Property
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b .Return04FB36
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$10].XDisp,y	;X Position
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	BNE.b .Return04FB36
	PHP
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$10].YDisp,y	;Y Position
	TYA
	LSR
	LSR
	PLP
	PHY
	TAY
	ROL
	ASL
	AND.b #$03
	STA.w SMW_OAMTileSizeBuffer[$10].Slot,y
	PLY
	DEY
	DEY
	DEY
	DEY
.Return04FB36:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OWSpr05_Cloud(Address)
namespace SMW_OWSpr05_Cloud
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$02			;\Overworld Sprite X Speed
	STA.w !RAM_SMW_OWSpr_XSpeed,x	;/
	LDA.b #$FF			;\Overworld Sprite Y Speed
	STA.w !RAM_SMW_OWSpr_YSpeed,x	;/
	JSR.w SMW_UpdateOverworldSpritePosition_Main	;Move the overworld cloud
	; Change from 20 62 FE to EA EA EA to make the overworld clouds not show up
	; (even if you use sprite slots for them).
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0020
	CMP.w #$0140
	BCS.b CODE_04FB5D
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.w #$0080
	CMP.w #$01A0
CODE_04FB5D:
	SEP.b #$20			; A->8
	BCC.b CODE_04FB64
	STZ.w !RAM_SMW_OWSpr_SpriteID,x
CODE_04FB64:
	LDA.b #$32
	JSR.w CODE_04FB77
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	LDA.b #$72
CODE_04FB77:
	XBA
	LDA.b #$44
CODE_04FB7A:
	SEC
CODE_04FB7B:
	LDY.w !RAM_SMW_Sprites_StartingOAMIndexForOverworldSprites
	JSR.w SMW_OWSpr04_PiranhaPlant_GenericOverworldSpriteGFXRt_Entry2
	STY.w !RAM_SMW_Sprites_StartingOAMIndexForOverworldSprites
Return04FB84:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OWSpr06_KoopaKid(Address)
namespace SMW_OWSpr06_KoopaKid
%InsertMacroAtXPosition(<Address>)

DATA_04FB85:
	db $80,$40,$20

InitialXLo:
	db $30,$10,$C0

InitialXHi:
	db $01,$01,$01

InitialYLo:
	db $7F,$7F,$8F

InitialYHi:
	db $01,$00

DATA_04FB93:
	db $01,$08

DATA_04FB95:
	db $02,$0F,$00

Main:
;$04FB98
	LDA.w !RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0DF5,x
	BNE.b ADDR_04FBD8
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	SEC
	SBC.b #!Define_SMW_OWSpr06_KoopaKid_LowestTriggerTile			; LM: "Koopa Kid Tile Numbers" in "Edit Sprites List"
	CMP.b #$03
	BCS.b SMW_OWSpr05_Cloud_Return04FB84
	TAY
	STA.w !RAM_SMW_OWSpr06_KoopaKid_TileIndex
	LDA.w !RAM_SMW_OWSpr06_KoopaKid_ActivateFlag
	AND.w DATA_04FB85,y
	BNE.b SMW_OWSpr05_Cloud_Return04FB84
	LDA.w InitialXLo,y
	STA.w !RAM_SMW_OWSpr_XPosLo,x
	LDA.w InitialXHi,y
	STA.w !RAM_SMW_OWSpr_XPosHi,x
	LDA.w InitialYLo,y
	STA.w !RAM_SMW_OWSpr_YPosLo,x
	LDA.w InitialYHi,y
	STA.w !RAM_SMW_OWSpr_YPosHi,x
	LDA.b #$02
	STA.w !RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0DF5,x
	LDA.b #$F0
	STA.w !RAM_SMW_OWSpr_XSpeed,x
	STZ.w !RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0E25,x
ADDR_04FBD8:
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main
	LDA.w !RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0E25,x
	BNE.b ADDR_04FC00
	INC.w !RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0E05,x
	JSR.w SMW_UpdateOverworldSpritePosition_X
	LDY.w !RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0DF5,x
	LDA.w !RAM_SMW_OWSpr_XPosLo,x
	AND.b #$0F
	CMP.w DATA_04FB95,y
	BNE.b ADDR_04FC00
	DEC.w !RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0DF5,x
	LDA.b #$04
	STA.w !RAM_SMW_OWSpr_XSpeed,x
	LDA.b #$60
	STA.w !RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0E25,x
ADDR_04FC00:
	LDA.w DATA_04FB93,y
	LDY.b #$22
	AND.w !RAM_SMW_OWSpr06_KoopaKid_UnknownTable7E0E05,x
	BNE.b ADDR_04FC0C
	LDY.b #$62
ADDR_04FC0C:
	TYA
	XBA
	LDA.b #$6A
	JSR.w SMW_OWSpr04_PiranhaPlant_GenericOverworldSpriteGFXRt_Main
	JSR.w SMW_CheckForPlayerToOverworldSpriteCollision_Main
	BCS.b Return04FC1D
	ORA.b #$80
	STA.w !RAM_SMW_Overworld_EnterLevelFlag
Return04FC1D:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OWSpr07_Smoke(Address)
namespace SMW_OWSpr07_Smoke
%InsertMacroAtXPosition(<Address>)

; Where the smoke draws, per map: one word each, indexed by the map the
; player is on. Two entries -- the main map and Yoshi's Island -- which is
; the same pair DisableSpriteOnXSubmapFlags allows sprite $07 on, and why a
; third map would read the animation table below as a position.
;
; The routine writes both into the sprite's position every frame, before it
; draws, so a Smoke slot's own position in SpriteSlotData is dead data: it
; is overwritten before anything reads it. The shipped slot happens to hold
; the main map pair, which is what makes the two look connected.
MapXPos:
	dw $0038,$0068

MapYPos:
	dw $018A,$006A

DATA_04FC26:
	db $01,$02,$03,$04,$03,$02,$01,$00
	db $01,$02,$03,$04,$03,$02,$01,$00

DATA_04FC36:
	db $FF,$FF,$FE,$FD,$FD,$FC,$FB,$FB
	db $FA,$F9,$F9,$F8,$F7,$F7,$F6,$F5

Main:
;$04FC46
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	ASL
	TAY
	LDA.w MapXPos,y
	STA.w !RAM_SMW_OWSpr_XPosLo,x
	LDA.w MapXPos+$01,y
	STA.w !RAM_SMW_OWSpr_XPosHi,x
	LDA.w MapYPos,y
	STA.w !RAM_SMW_OWSpr_YPosLo,x
	LDA.w MapYPos+$01,y
	STA.w !RAM_SMW_OWSpr_YPosHi,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$0F
	BNE.b CODE_04FC7C
	LDA.w !RAM_SMW_OWSpr_Table7E0DF5,x
	INC
	CMP.b #$0C
	BCC.b CODE_04FC79
	LDA.b #$00
CODE_04FC79:
	STA.w !RAM_SMW_OWSpr_Table7E0DF5,x
CODE_04FC7C:
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Counter_GlobalFrames
	STA.b !RAM_SMW_Misc_ScratchRAM06
	STZ.b !RAM_SMW_Misc_ScratchRAM07
	LDY.w SMW_OverworldSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_OWSpr_Table7E0DF5,x
	TAX
CODE_04FC8D:
	PHY
	PHX
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	CLC
	ADC.w DATA_04FC36,x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM02
	BCS.b CODE_04FCA5
	DEC.b !RAM_SMW_Misc_ScratchRAM03
CODE_04FCA5:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_04FC26,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b CODE_04FCB1
	INC.b !RAM_SMW_Misc_ScratchRAM01
CODE_04FCB1:
	TXA
	CLC
	ADC.b #$0C
	CMP.b #$10
	AND.b #$0F
	TAX
	BCC.b CODE_04FCC2
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	SBC.b #$0C
	STA.b !RAM_SMW_Misc_ScratchRAM07
CODE_04FCC2:
	LDA.b #$30
	XBA
	LDY.b #$28
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	CLC
	ADC.b #$0A
	STA.b !RAM_SMW_Misc_ScratchRAM06
	AND.b #$20
	BEQ.b CODE_04FCD4
	LDY.b #$5F
CODE_04FCD4:
	TYA
	PLY
	JSR.w SMW_OWSpr03_CheepCheep_GenericOverworldSpriteGFXRt_Draw8x8
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BNE.b CODE_04FC8D
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OWSpr08_BowserSign(Address)
namespace SMW_OWSpr08_BowserSign
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main
	LDA.b #$04			;\How many tiles to show up for Bowser's sign
	STA.b !RAM_SMW_Misc_ScratchRAM04	;/
	LDA.b #$6F
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDY.w SMW_OverworldSpriteOAMIndexes_Main,x
CODE_04FCEF:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	AND.b #$06
	ORA.b #$30
	XBA
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	JSR.w SMW_OWSpr03_CheepCheep_GenericOverworldSpriteGFXRt_Draw8x8	;Jump to CLC, then the OAM part of the Pirahna Plant code.
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	DEC.b !RAM_SMW_Misc_ScratchRAM05
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BNE.b CODE_04FCEF
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OWSpr09_Bowser(Address)
namespace SMW_OWSpr09_Bowser
%InsertMacroAtXPosition(<Address>)

; Turn timer table for the OW Boo sprite. The table is formatted as follows:
; 3 pair of speeds, each one used for the X, Y and Z direction respectively.
; In each pair, the first value is used when having positive speed and the
; second when turning around to negative speed. The timer is checked by
; doing AND between the value in this table and the table at $0E25 (which
; increases every frame), and updating the direction when the result is not
; 0.
DATA_04FD0A:
	db $07,$07,$03,$03,$5F,$5F

; Acceleration table for the overworld Bowser and Boo sprites. The table is
; formatted as follows: 5 pairs of values, each pair having a right and left
; acceleration value, where the first 2 are OW Bowser's X and Y acceleration
; respectively, and the others are OW Boo's X,Y and Z acceleration
; respectively.
DATA_04FD10:
	db $01,$FF,$01,$FF,$01,$FF,$01,$FF
	db $01,$FF

; Maximum speed table for the overworld Bowser and Boo sprites. The table is
; formatted as follows: 5 pairs of values, each pair having a right and left
; speed value, where the first 2 are OW Bowser's X and Y speed respectively,
; and the others are OW Boo's X,Y and Z speed respectively. The last pair of
; values ($01,$FF) is also used to initialize the Z speed of the OW Boos,
; but for some reason they only read the first value.
DATA_04FD1A:
	db $18,$E8,$0A,$F6,$08,$F8,$03,$FD

DATA_04FD22:									; Note: This label is not referenced in the Overworld Bowser code, but rather from a bit of code that shouldn't be referencing this.
	db $01,$FF

Main:
;$04FD24
	JSR.w SMW_UpdateOverworldSpritePosition_Main
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main				;\ Optimization: Why is this called twice?
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main				;/
	LDA.b #$00
	LDY.w !RAM_SMW_OWSpr_XSpeed,x
	BMI.b CODE_04FD36
	LDA.b #$40
CODE_04FD36:
	XBA
	LDA.b #$68
	JSR.w SMW_OWSpr04_PiranhaPlant_GenericOverworldSpriteGFXRt_Main
	INC.w !RAM_SMW_OWSpr09_Bowser_UnknownTable7E0E15,x
	LDA.w !RAM_SMW_OWSpr09_Bowser_UnknownTable7E0E15,x
	LSR
	BCS.b Return04FD6F
	LDA.w !RAM_SMW_OWSpr09_Bowser_UnknownTable7E0E05,x
	ORA.b #$02
	TAY
	TXA
	ADC.b #!Define_SMW_MaxOverworldSpriteSlot+$01
	TAX
	JSR.w CODE_04FD55
	LDY.w !RAM_SMW_OWSpr09_Bowser_UnknownTable7E0DF5,x
CODE_04FD55:
	LDA.w !RAM_SMW_OWSpr_XSpeed,x
	CLC
	ADC.w DATA_04FD10,y
	STA.w !RAM_SMW_OWSpr_XSpeed,x
	CMP.w DATA_04FD1A,y
	BNE.b CODE_04FD68
	TYA
	EOR.b #$01
	TAY
CODE_04FD68:
	TYA
	STA.w !RAM_SMW_OWSpr09_Bowser_UnknownTable7E0DF5,x
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite
Return04FD6F:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_OWSpr0A_Boo(Address)
namespace SMW_OWSpr0A_Boo
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_UpdateOverworldSpritePosition_Main
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main				;\ Optimization: Why is this called twice?
	JSR.w SMW_GetOverworldSpriteOnScreenPosition_Main				;/
	LDY.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	BEQ.b CODE_04FDA5							; Note: !Define_SMW_Overworld_MainMap
	CPX.b #$0F
	BNE.b CODE_04FD8E
	LDA.w !RAM_SMW_Overworld_EventFlags+$05
	AND.b #$12
	BNE.b CODE_04FD8E
	STX.b !RAM_SMW_Misc_ScratchRAM03
CODE_04FD8E:
	TXA
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w SMW_LoadOverworldSprites_SubmapBooXPosOffset-$1A,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.w SMW_LoadOverworldSprites_SubmapBooYPosOffset-$1A,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	SEP.b #$20			; A->8
CODE_04FDA5:
	LDA.b #$34
	LDY.w !RAM_SMW_OWSpr_XSpeed,x
	BMI.b CODE_04FDAE
	LDA.b #$44
CODE_04FDAE:
	XBA
	LDA.b #$60
	JSR.w SMW_OWSpr04_PiranhaPlant_GenericOverworldSpriteGFXRt_Main
	LDA.w !RAM_SMW_OWSpr0A_Boo_UnknownTable7E0E25,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INC.w !RAM_SMW_OWSpr0A_Boo_UnknownTable7E0E25,x
	TXA
	CLC
	ADC.b #((!Define_SMW_MaxOverworldSpriteSlot+$01)*$02)
	TAX
	LDA.b #$08
	JSR.w CODE_04FDD2
	TXA
	CLC
	ADC.b #!Define_SMW_MaxOverworldSpriteSlot+$01
	TAX
	LDA.b #$06
	JSR.w CODE_04FDD2
	LDA.b #$04
CODE_04FDD2:
	ORA.w !RAM_SMW_OWSpr0A_Boo_UnknownTable7E0DF5,x
	TAY
	LDA.w SMW_OWSpr09_Bowser_DATA_04FD0A-$04,y
	AND.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b SMW_OWSpr09_Bowser_CODE_04FD68
	JMP.w SMW_OWSpr09_Bowser_CODE_04FD55
namespace off
endmacro

macro INLINEDATATABLE_RT16_SMW_EmptySpace(Address)
!SMW_UBytes = $024A : !SMW_JBytes = $0306 : !SMW_E1Bytes = $024A : !SMW_E2Bytes = $024A : !SMASW_UBytes = $023E : !SMASW_EBytes = $023E : !SMW_ARCADEBytes = $026B
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 16)
endmacro

macro INLINEDATATABLE_RT17_SMW_EmptySpace(Address)
!SMW_UBytes = $0342 : !SMW_JBytes = $0340 : !SMW_E1Bytes = $0342 : !SMW_E2Bytes = $0342 : !SMASW_UBytes = $02C2 : !SMASW_EBytes = $02C2 : !SMW_ARCADEBytes = $0342
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 17)
endmacro

macro INLINEDATATABLE_RT18_SMW_EmptySpace(Address)
!SMW_UBytes = $4F : !SMW_JBytes = $57 : !SMW_E1Bytes = $4F : !SMW_E2Bytes = $4F : !SMASW_UBytes = $5B : !SMASW_EBytes = $5B : !SMW_ARCADEBytes = $4F
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 18)
endmacro
