;####################################################################
;# Bank03.asm -- player physics and animation.
;#
;# 82 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank03Macros(StartBank, EndBank)
%BANK_START(<StartBank>)
ROUTINE_RT02_SMW_NorSpr0AB_Rex_Status08:	%ROUTINE_RT02_SMW_NorSpr0AB_Rex_Status08(NULLROM)				; $038000
ROUTINE_RT01_SMW_NorSpr01B_Football_Status08:	%ROUTINE_RT01_SMW_NorSpr01B_Football_Status08(NULLROM)				; $038007
ROUTINE_RT01_SMW_NorSpr0C5_BigBooBoss_Status08:	%ROUTINE_RT01_SMW_NorSpr0C5_BigBooBoss_Status08(NULLROM)			; $038087
ROUTINE_SMW_FadingBooPaletteAnimation:	%ROUTINE_SMW_FadingBooPaletteAnimation(NULLROM)				; $038239
ROUTINE_SMW_NormalSpriteBooGFXRt:	%ROUTINE_SMW_NormalSpriteBooGFXRt(NULLROM)					; $038280
ROUTINE_RT01_SMW_NorSpr0C4_GreyFallingPlatform_Status08:	%ROUTINE_RT01_SMW_NorSpr0C4_GreyFallingPlatform_Status08(NULLROM)		; $038454
ROUTINE_RT01_SMW_NorSpr0C2_Blurp_Status08:	%ROUTINE_RT01_SMW_NorSpr0C2_Blurp_Status08(NULLROM)				; $0384C4
ROUTINE_RT01_SMW_NorSpr0C3_PorcuPuffer_Status08:	%ROUTINE_RT01_SMW_NorSpr0C3_PorcuPuffer_Status08(NULLROM)			; $03852B
ROUTINE_RT01_SMW_NorSpr0C1_WingedPlatform_Status08:	%ROUTINE_RT01_SMW_NorSpr0C1_WingedPlatform_Status08(NULLROM)			; $0385F4
ROUTINE_RT01_SMW_NorSpr0C0_SinkingLavaPlatform_Status08:	%ROUTINE_RT01_SMW_NorSpr0C0_SinkingLavaPlatform_Status08(NULLROM)		; $0386FF
ROUTINE_RT01_SMW_NorSpr0BF_MegaMole_Status08:	%ROUTINE_RT01_SMW_NorSpr0BF_MegaMole_Status08(NULLROM)				; $03876E
ROUTINE_RT01_SMW_NorSpr0BE_Swooper_Status08:	%ROUTINE_RT01_SMW_NorSpr0BE_Swooper_Status08(NULLROM)				; $0388A0
ROUTINE_RT01_SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status08:	%ROUTINE_RT01_SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status08(NULLROM)		; $038954
ROUTINE_RT01_SMW_NorSpr0BC_BowserStatue_Status08:	%ROUTINE_RT01_SMW_NorSpr0BC_BowserStatue_Status08(NULLROM)			; $038A3C
ROUTINE_RT01_SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status08:	%ROUTINE_RT01_SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status08(NULLROM)		; $038BAA
ROUTINE_RT01_SMW_NorSpr0B9_MessageBox_Status08:	%ROUTINE_RT01_SMW_NorSpr0B9_MessageBox_Status08(NULLROM)			; $038D66
ROUTINE_RT01_SMW_NorSpr0BA_TimedPlatform_Status08:	%ROUTINE_RT01_SMW_NorSpr0BA_TimedPlatform_Status08(NULLROM)			; $038DBB
ROUTINE_RT01_SMW_NorSpr0BB_MovingCastleStone_Status08:	%ROUTINE_RT01_SMW_NorSpr0BB_MovingCastleStone_Status08(NULLROM)		; $038E71
ROUTINE_RT01_SMW_NorSpr0B3_BowserStatueFire_Status08:	%ROUTINE_RT01_SMW_NorSpr0B3_BowserStatueFire_Status08(NULLROM)			; $038EEA
ROUTINE_RT01_SMW_NorSprXXX_ReflectingEnemy_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_ReflectingEnemy_Status08(NULLROM)			; $038F6D
ROUTINE_RT01_SMW_NorSpr0AE_FishinBoo_Status08:	%ROUTINE_RT01_SMW_NorSpr0AE_FishinBoo_Status08(NULLROM)			; $03905D
ROUTINE_RT01_SMW_NorSpr0B2_FallingSpike_Status08:	%ROUTINE_RT01_SMW_NorSpr0B2_FallingSpike_Status08(NULLROM)			; $039214
ROUTINE_RT01_SMW_NorSpr0B1_CreateEatBlock_Status08:	%ROUTINE_RT01_SMW_NorSpr0B1_CreateEatBlock_Status08(NULLROM)			; $03926F
ROUTINE_RT01_SMW_NorSpr0AC_DownFirstWoodenSpike_Status08:	%ROUTINE_RT01_SMW_NorSpr0AC_DownFirstWoodenSpike_Status08(NULLROM)		; $039423
ROUTINE_RT01_SMW_NorSpr0AB_Rex_Status08:	%ROUTINE_RT01_SMW_NorSpr0AB_Rex_Status08(NULLROM)				; $039513
ROUTINE_RT01_SMW_NorSpr0AA_Fishbone_Status08:	%ROUTINE_RT01_SMW_NorSpr0AA_Fishbone_Status08(NULLROM)				; $0396F6
ROUTINE_RT02_SMW_AimTowardsPlayer:	%ROUTINE_RT02_SMW_AimTowardsPlayer(NULLROM)					; $0397F9
ROUTINE_RT01_SMW_NorSpr0A9_Reznor_Status01:	%ROUTINE_RT01_SMW_NorSpr0A9_Reznor_Status01(NULLROM)				; $039872
ROUTINE_RT01_SMW_NorSpr0A9_Reznor_Status08:	%ROUTINE_RT01_SMW_NorSpr0A9_Reznor_Status08(NULLROM)				; $039886
ROUTINE_RT01_SMW_NorSpr06F_DinoTorch_Status08:	%ROUTINE_RT01_SMW_NorSpr06F_DinoTorch_Status08(NULLROM)			; $039C34
ROUTINE_RT01_SMW_NorSpr0A8_Blargg_Status08:	%ROUTINE_RT01_SMW_NorSpr0A8_Blargg_Status08(NULLROM)				; $039F38
ROUTINE_RT01_SMW_NorSpr0A0_ActivateBowserBattle_Status01:	%ROUTINE_RT01_SMW_NorSpr0A0_ActivateBowserBattle_Status01(NULLROM)		; $03A0F1
ROUTINE_RT01_SMW_NorSpr0A0_ActivateBowserBattle_Status08:	%ROUTINE_RT01_SMW_NorSpr0A0_ActivateBowserBattle_Status08(NULLROM)		; $03A118
ROUTINE_SMW_DespawnNonBossSprites:	%ROUTINE_SMW_DespawnNonBossSprites(NULLROM)					; $03A6C8
ROUTINE_RT02_SMW_NorSpr0A0_ActivateBowserBattle_Status08:	%ROUTINE_RT02_SMW_NorSpr0A0_ActivateBowserBattle_Status08(NULLROM)		; $03A6F0
ROUTINE_RT05_SMW_NorSpr07C_PrincessPeach_Status08:	%ROUTINE_RT05_SMW_NorSpr07C_PrincessPeach_Status08(NULLROM)			; $03A92E
ROUTINE_RT03_SMW_NorSpr0A0_ActivateBowserBattle_Status08:	%ROUTINE_RT03_SMW_NorSpr0A0_ActivateBowserBattle_Status08(NULLROM)		; $03AB15
ROUTINE_RT01_SMW_NorSpr07C_PrincessPeach_Status08:	%ROUTINE_RT01_SMW_NorSpr07C_PrincessPeach_Status08(NULLROM)			; $03AC93
ROUTINE_RT04_SMW_NorSpr0A0_ActivateBowserBattle_Status08:	%ROUTINE_RT04_SMW_NorSpr0A0_ActivateBowserBattle_Status08(NULLROM)		; $03AF34
ROUTINE_RT01_SMW_NorSpr0A1_BowserBowlingBall_Status08:	%ROUTINE_RT01_SMW_NorSpr0A1_BowserBowlingBall_Status08(NULLROM)		; $03B161
ROUTINE_RT01_SMW_NorSpr0A2_MechaKoopa_Status08:	%ROUTINE_RT01_SMW_NorSpr0A2_MechaKoopa_Status08(NULLROM)			; $03B2A7
ROUTINE_RT05_SMW_NorSpr0A0_ActivateBowserBattle_Status08:	%ROUTINE_RT05_SMW_NorSpr0A0_ActivateBowserBattle_Status08(NULLROM)		; $03B43C
ROUTINE_SMW_StandardSpriteToSpriteCollisionChecks:	%ROUTINE_SMW_StandardSpriteToSpriteCollisionChecks(NULLROM)			; $03B56C
ROUTINE_RT02_SMW_GetDrawInfo:	%ROUTINE_RT02_SMW_GetDrawInfo(NULLROM)						; $03B75C
ROUTINE_RT02_SMW_NorSpr0A1_BowserBowlingBall_Status08:	%ROUTINE_RT02_SMW_NorSpr0A1_BowserBowlingBall_Status08(NULLROM)		; $03B7D2
ROUTINE_RT03_SMW_CheckPlayerPositionRelativeToSprite:	%ROUTINE_RT03_SMW_CheckPlayerPositionRelativeToSprite(NULLROM)			; $03B817
ROUTINE_RT03_SMW_SubOffscreen:	%ROUTINE_RT03_SMW_SubOffscreen(NULLROM)					; $03B83B
ROUTINE_RT03_SMW_CheckIfNormalSpriteOffScreen:	%ROUTINE_RT03_SMW_CheckIfNormalSpriteOffScreen(NULLROM)			; $03B8FB
ROUTINE_RT02_SMW_NorSpr01F_Magikoopa_Status08:	%ROUTINE_RT02_SMW_NorSpr01F_Magikoopa_Status08(NULLROM)			; $03B902
DATATABLE_SMW_BooFadePalettes:	%DATATABLE_SMW_BooFadePalettes(NULLROM)					; $03B982
INLINEDATATABLE_RT12_SMW_EmptySpace:	%INLINEDATATABLE_RT12_SMW_EmptySpace(NULLROM)					; $03BA02
ROUTINE_RT01_SMW_NorSpr054_ClimbingNetDoor_Status08:	%ROUTINE_RT01_SMW_NorSpr054_ClimbingNetDoor_Status08(NULLROM)			; $03C000
ROUTINE_RT01_SMW_CheckIfBabyYoshiCanEatNormalSprite:	%ROUTINE_RT01_SMW_CheckIfBabyYoshiCanEatNormalSprite(NULLROM)			; $03C023
ROUTINE_RT07_SMW_GameMode14_InLevel:	%ROUTINE_RT07_SMW_GameMode14_InLevel(NULLROM)					; $03C0B2
ROUTINE_RT04_SMW_NorSpr035_Yoshi_Status08:	%ROUTINE_RT04_SMW_NorSpr035_Yoshi_Status08(NULLROM)				; $03C176
ROUTINE_RT01_SMW_HandleNormalSpriteLevelCollision:	%ROUTINE_RT01_SMW_HandleNormalSpriteLevelCollision(NULLROM)			; $03C1C6
ROUTINE_RT01_SMW_NorSpr0C8_LightSwitch_Status08:	%ROUTINE_RT01_SMW_NorSpr0C8_LightSwitch_Status08(NULLROM)			; $03C1EC
ROUTINE_RT03_SMW_NorSprXXX_LineGuidedSprites_Status08:	%ROUTINE_RT03_SMW_NorSprXXX_LineGuidedSprites_Status08(NULLROM)		; $03C25B
ROUTINE_SMW_TriggerHidden1up:	%ROUTINE_SMW_TriggerHidden1up(NULLROM)						; $03C2D9
ROUTINE_RT01_SMW_NorSpr0C7_InvisibleMushroom_Status08:	%ROUTINE_RT01_SMW_NorSpr0C7_InvisibleMushroom_Status08(NULLROM)		; $03C30F
ROUTINE_RT01_SMW_NorSpr051_Ninji_Status08:	%ROUTINE_RT01_SMW_NorSpr051_Ninji_Status08(NULLROM)				; $03C348
ROUTINE_RT01_SMW_NorSpr030_ThrowingDryBones_Status08:	%ROUTINE_RT01_SMW_NorSpr030_ThrowingDryBones_Status08(NULLROM)			; $03C390
ROUTINE_RT01_SMW_NorSpr0C6_Spotlight_Status08:	%ROUTINE_RT01_SMW_NorSpr0C6_Spotlight_Status08(NULLROM)			; $03C48F
ROUTINE_RT03_SMW_NorSpr07A_Fireworks_Status08:	%ROUTINE_RT03_SMW_NorSpr07A_Fireworks_Status08(NULLROM)			; $03C626
ROUTINE_RT02_SMW_NorSpr07C_PrincessPeach_Status08:	%ROUTINE_RT02_SMW_NorSpr07C_PrincessPeach_Status08(NULLROM)			; $03C776
ROUTINE_RT02_SMW_NorSpr07A_Fireworks_Status08:	%ROUTINE_RT02_SMW_NorSpr07A_Fireworks_Status08(NULLROM)			; $03C77A
ROUTINE_RT03_SMW_NorSpr07C_PrincessPeach_Status08:	%ROUTINE_RT03_SMW_NorSpr07C_PrincessPeach_Status08(NULLROM)			; $03C78A
ROUTINE_RT01_SMW_NorSpr07A_Fireworks_Status08:	%ROUTINE_RT01_SMW_NorSpr07A_Fireworks_Status08(NULLROM)			; $03C816
ROUTINE_SMW_SpawnFootball:	%ROUTINE_SMW_SpawnFootball(NULLROM)						; $03CBAD
ROUTINE_RT01_SMW_NorSpr029_KoopaKid_Status08_WendyLemmy:	%ROUTINE_RT01_SMW_NorSpr029_KoopaKid_Status08_WendyLemmy(NULLROM)		; $03CC09
ROUTINE_RT04_SMW_NorSpr07C_PrincessPeach_Status08:	%ROUTINE_RT04_SMW_NorSpr07C_PrincessPeach_Status08(NULLROM)			; $03D524
INLINEDATATABLE_RT13_SMW_EmptySpace:	%INLINEDATATABLE_RT13_SMW_EmptySpace(NULLROM)					; $03D6AC
ROUTINE_RT02_SMW_NorSpr0A9_Reznor_Status08:	%ROUTINE_RT02_SMW_NorSpr0A9_Reznor_Status08(NULLROM)				; $03D700
ROUTINE_RT04_SMW_GameMode12_PrepareLevel:	%ROUTINE_RT04_SMW_GameMode12_PrepareLevel(NULLROM)				; $03D7EC
ROUTINE_SMW_InitializeMode7TilemapsAndPalettes:	%ROUTINE_SMW_InitializeMode7TilemapsAndPalettes(NULLROM)			; $03D9DE
ROUTINE_SMW_UpdateMode7SpriteAnimations:	%ROUTINE_SMW_UpdateMode7SpriteAnimations(NULLROM)				; $03DEBB
ROUTINE_RT06_SMW_NorSpr0A0_ActivateBowserBattle_Status08:	%ROUTINE_RT06_SMW_NorSpr0A0_ActivateBowserBattle_Status08(NULLROM)		; $03DFC4
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
ROUTINE_RT02_SMW_UploadPlayerGFX:	%ROUTINE_RT02_SMW_UploadPlayerGFX(NULLROM)					; N/A
endif
INLINEDATATABLE_RT14_SMW_EmptySpace:	%INLINEDATATABLE_RT14_SMW_EmptySpace(NULLROM)					; $03E05C
ROUTINE_RT01_SMW_HandleSPCUploads:	%ROUTINE_RT01_SMW_HandleSPCUploads(NULLROM)					; $03E400
INLINEDATATABLE_RT15_SMW_EmptySpace:	%INLINEDATATABLE_RT15_SMW_EmptySpace(NULLROM)					; $03FDE0
%BANK_END(<EndBank>)
endmacro

macro ROUTINE_RT01_SMW_HandleSPCUploads(Address)
namespace SMW_HandleSPCUploads
%InsertMacroAtXPosition(<Address>)

; Credit music SPC data.
CreditsMusicBank:
	incbin "SPC700/credits_music.bin"
namespace off
endmacro

macro ROUTINE_RT02_SMW_GetDrawInfo(Address)
namespace SMW_GetDrawInfo
%InsertMacroAtXPosition(<Address>)

DATA_03B75C:									;\ Optimization: Same deal as the Bank 01 GetDrawInfo.
	db $0C,$1C								;|
										;|
DATA_03B75E:									;|
	db $01,$02								;/

Bank03:
	STZ.w !RAM_SMW_NorSpr_YOffscreenFlag,x	; Reset sprite offscreen flag, vertical
	STZ.w !RAM_SMW_NorSpr_XOffscreenFlag,x	; Reset sprite offscreen flag, horizontal
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	; | Set horizontal offscreen if necessary
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BEQ.b CODE_03B774
	INC.w !RAM_SMW_NorSpr_XOffscreenFlag,x
CODE_03B774:
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	XBA				; | Mark sprite invalid if far enough off screen
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	REP.b #$20			; A->16
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w #$0040
	CMP.w #$0180
	SEP.b #$20			; A->8
	ROL
	AND.b #$01
	STA.w !RAM_SMW_NorSpr_Table7E15C4,x
	BNE.b CODE_03B7CF
	LDY.b #$00								;\ Optimization: Same deal as the Bank 01 GetDrawInfo.
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x				;| Glitch: Same deal as the Bank 02 GetDrawInfo.
	AND.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping20			;|
	BEQ.b CODE_03B79A							;|
	INY									;|
CODE_03B79A:									;|
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;|
	CLC									;|
	ADC.w DATA_03B75C,y							;|
	PHP									;|
	CMP.b !RAM_SMW_Mirror_CurrentLayer1YPosLo				;|
	ROL.b !RAM_SMW_Misc_ScratchRAM00					;|
	PLP									;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x						;|
	ADC.b #$00								;|
	LSR.b !RAM_SMW_Misc_ScratchRAM00					;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi				;|
	BEQ.b CODE_03B7BA							;|
	LDA.w !RAM_SMW_NorSpr_YOffscreenFlag,x					;|
	ORA.w DATA_03B75E,y							;|
	STA.w !RAM_SMW_NorSpr_YOffscreenFlag,x					;|
CODE_03B7BA:									;|
	DEY									;|
	BPL.b CODE_03B79A							;/
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; get offset to sprite OAM
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00	; / $00 = sprite x position relative to screen boarder
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01	; / $01 = sprite y position relative to screen boarder
	RTS

CODE_03B7CF:
	PLA				; \ Return from *main gfx routine* subroutine...
	PLA				; |    ...(not just this subroutine)
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardSpriteToSpriteCollisionChecks(Address)
namespace SMW_StandardSpriteToSpriteCollisionChecks
%InsertMacroAtXPosition(<Address>)

; X displacement of sprite clippings.
SprClippingDispX:
	db $02,$02,$10,$14,$00,$00,$01,$08
	db $F8,$FE,$03,$06,$01,$00,$06,$02
	db $00,$E8,$FC,$FC,$04,$00,$FC,$02
	db $02,$02,$02,$02,$00,$02,$E0,$F0
	db $FC,$FC,$00,$F8,$F4,$F2,$00,$FC
	db $F2,$F0,$02,$00,$F8,$04,$02,$02
	db $08,$00,$00,$00,$FC,$03,$08,$00
	db $08,$04,$F8,$00

; Width of sprite clippings.
SprClippingWidth:
	db $0C,$0C,$10,$08,$30,$50,$0E,$28
	db $20,$14,$01,$03,$0D,$0F,$14,$24
	db $0F,$40,$08,$08,$18,$0F,$18,$0C
	db $0C,$0C,$0C,$0C,$0A,$1C,$30,$30
	db $08,$08,$10,$20,$38,$3C,$20,$18
	db $1C,$20,$0C,$10,$10,$08,$1C,$1C
	db $10,$30,$30,$40,$08,$12,$34,$0F
	db $20,$08,$20,$10

; Y displacement of sprite clippings.
SprClippingDispY:
	db $03,$03,$FE,$08,$FE,$FE,$02,$08
	db $FE,$08,$07,$06,$FE,$FC,$06,$FE
	db $FE,$E8,$10,$10,$02,$FE,$F4,$08
	db $13,$23,$33,$43,$0A,$FD,$F8,$FC
	db $E8,$10,$00,$E8,$20,$04,$58,$FC
	db $E8,$FC,$F8,$02,$F8,$04,$FE,$FE
	db $F2,$FE,$FE,$FE,$FC,$00,$08,$F8
	db $10,$03,$10,$00

; Height of sprite clippings.
SprClippingHeight:
	db $0A,$15,$12,$08,$0E,$0E,$18,$30
	db $10,$1E,$02,$03,$16,$10,$14,$12
	db $20,$40,$34,$74,$0C,$0E,$18,$45
	db $3A,$2A,$1A,$0A,$30,$1B,$20,$12
	db $18,$18,$10,$20,$38,$14,$08,$18
	db $28,$1B,$13,$4C,$10,$04,$22,$20
	db $1C,$12,$12,$12,$08,$20,$2E,$14
	db $28,$0A,$10,$0D

MarioClipDispY:
	db $06,$14,$10,$18

MarioClippingHeight:
	db $1A,$0C,$20,$18

; Get player clipping B subroutine. Gets and stores information in scratch
; RAM about the position and size of the player's sprite interaction hitbox;
; see details for a list. Generally for use in conjunction with $03B69F and
; $03B72B to check if a sprite is touching Mario. Notable tweaks: $03B673:
; The width of Mario hitbox with sprites in pixels (default: 0C). $03B67C:
; Change to [A9 00] to make Mario always have a 16x16 interaction field
; (like Small Mario), or to [A9 01] to always have a 16x32 interaction field
; (like Big Mario). Recommended to combine with the similar tweaks at
; $00EB79 and $01B4C0.
GetMarioClipping:
	PHX
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | $00 = (Mario X position + #$02) Low byte
	LDA.b !RAM_SMW_Player_XPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM08	; / $08 = (Mario X position + #$02) High byte
	LDA.b #$0C			; \ $06 = Clipping width X (#$0C)
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$00			; \ If mario small or ducking, X = #$01
	LDA.b !RAM_SMW_Player_DuckingFlag	; | else, X = #$00
	BNE.b .IsDucking
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b .NotSmall
.IsDucking:
	INX
.NotSmall:
	LDA.w !RAM_SMW_Player_RidingYoshiFlag	; \ If on Yoshi, X += #$02
	BEQ.b .NotRidingYoshi
	INX
	INX
.NotRidingYoshi:
	LDA.l MarioClippingHeight,x	; \ $03 = Clipping height
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.l MarioClipDispY,x
	STA.b !RAM_SMW_Misc_ScratchRAM01	; | $01 = (Mario Y position + displacement) Low byte
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM09	; / $09 = (Mario Y position + displacement) High byte
	PLX
	RTL

; Get sprite clipping A subroutine. Gets and stores information in scratch
; RAM about the position and size of the sprite interaction hitbox for the
; sprite slot in X; see details for a list. Generally for use in conjunction
; with $03B72B and either $03B664 or $03B6E5 to check if the sprite is
; interacting with either Mario or another sprite.
GetSpriteClippingA:
	PHY
	PHX
	TXY				; Y = Sprite index
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x	; \ X = Clipping table index
	AND.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping
	TAX
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.l SprClippingDispX,x	; | Load low byte of X displacement
	BPL.b .CODE_03B6B2
	DEC.b !RAM_SMW_Misc_ScratchRAM0F	; | $0F = High byte of X displacement
.CODE_03B6B2:
	CLC
	ADC.w !RAM_SMW_NorSpr_XPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM04	; | $04 = (Sprite X position + displacement) Low byte
	LDA.w !RAM_SMW_NorSpr_XPosHi,y
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	STA.b !RAM_SMW_Misc_ScratchRAM0A	; / $0A = (Sprite X position + displacement) High byte
	LDA.l SprClippingWidth,x	; \ $06 = Clipping width
	STA.b !RAM_SMW_Misc_ScratchRAM06
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.l SprClippingDispY,x	; | Load low byte of Y displacement
	BPL.b .CODE_03B6CF
	DEC.b !RAM_SMW_Misc_ScratchRAM0F	; | $0F = High byte of Y displacement
.CODE_03B6CF:
	CLC
	ADC.w !RAM_SMW_NorSpr_YPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM05	; | $05 = (Sprite Y position + displacement) Low byte
	LDA.w !RAM_SMW_NorSpr_YPosHi,y
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	STA.b !RAM_SMW_Misc_ScratchRAM0B	; / $0B = (Sprite Y position + displacement) High byte
	LDA.l SprClippingHeight,x	; \ $07 = Clipping height
	STA.b !RAM_SMW_Misc_ScratchRAM07
	PLX				; X = Sprite index
	PLY
	RTL

; Get sprite clipping B subroutine. Gets and stores information in scratch
; RAM about the position and size of the sprite interaction hitbox for the
; sprite slot in X; see details for a list. Generally for use in conjunction
; with $03B69F and $03B72B to check if two sprites are touching.
GetSpriteClippingB:
	PHY
	PHX
	TXY				; Y = Sprite index
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x	; \ X = Clipping table index
	AND.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping
	TAX
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.l SprClippingDispX,x	; | Load low byte of X displacement
	BPL.b .CODE_03B6F8
	DEC.b !RAM_SMW_Misc_ScratchRAM0F	; | $0F = High byte of X displacement
.CODE_03B6F8:
	CLC
	ADC.w !RAM_SMW_NorSpr_XPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | $00 = (Sprite X position + displacement) Low byte
	LDA.w !RAM_SMW_NorSpr_XPosHi,y
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	STA.b !RAM_SMW_Misc_ScratchRAM08	; / $08 = (Sprite X position + displacement) High byte
	LDA.l SprClippingWidth,x	; \ $02 = Clipping width
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.l SprClippingDispY,x	; | Load low byte of Y displacement
	BPL.b .CODE_03B715
	DEC.b !RAM_SMW_Misc_ScratchRAM0F	; | $0F = High byte of Y displacement
.CODE_03B715:
	CLC
	ADC.w !RAM_SMW_NorSpr_YPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM01	; | $01 = (Sprite Y position + displacement) Low byte
	LDA.w !RAM_SMW_NorSpr_YPosHi,y
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	STA.b !RAM_SMW_Misc_ScratchRAM09	; / $09 = (Sprite Y position + displacement) High byte
	LDA.l SprClippingHeight,x	; \ $03 = Clipping height
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PLX				; X = Sprite index
	PLY
	RTL

; "Check for contact" collision subroutine. Checks whether two hitboxes
; (defined in $00-$0B; see details) are touching, with the result returned
; in the carry flag (set = in contact). Generally for use in conjunction
; with $03B69F and either $03B664 or $03B6E5 to check if a sprite is
; interacting with either Mario or another sprite, although you can also
; manually provide values for etiher of the two hitboxes. Note that, in
; addition to scratch RAM $00-$0B being used as input to this routine, $0C
; and $0F also get overwritten during its run.
CheckForContact:
	PHX				;>Preserve sprite slot
	LDX.b #$01			;>Start index loop (First is Y, then X).
.CODE_03B72E:
	LDA.b !RAM_SMW_Misc_ScratchRAM00,x	;\(1) low byte distance between hitboxes [B - A]
	SEC				;|
	SBC.b !RAM_SMW_Misc_ScratchRAM04,x	;|
	PHA				;/
	LDA.b !RAM_SMW_Misc_ScratchRAM08,x	;\high byte distance difference
	SBC.b !RAM_SMW_Misc_ScratchRAM0A,x	;|
	STA.b !RAM_SMW_Misc_ScratchRAM0C	;/
	PLA				;\Add low byte by #$80 to "round" the value to the next #$0100 value to
	CLC				;|find out if hitbox is too far away (possibly if the hitbox width/height were to extend
	ADC.b #$80			;/so far out that it only checks the top/left of the box properly?)
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\add by #$00 or #$01 on the high byte to see if the two hitboxes are >= #$0100 away
	ADC.b #$00			;/
	BNE.b .CODE_03B75A		;>If too far, no contact.
	LDA.b !RAM_SMW_Misc_ScratchRAM04,x	;\(2) Find distance between boxes while within range [A - B]
	SEC				;|
	SBC.b !RAM_SMW_Misc_ScratchRAM00,x	;|
	CLC				;|\Either find the gap between two boxes (if subtraction negative), or get total
	ADC.b !RAM_SMW_Misc_ScratchRAM06,x	;|/value of both width/heights and the space between boxes
	STA.b !RAM_SMW_Misc_ScratchRAM0F	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM02,x	;\(3)Add size (width/height) of the two hitboxes (the furthest distance they can be when touching, edge to edge)
	CLC				;|
	ADC.b !RAM_SMW_Misc_ScratchRAM06,x	;/
	CMP.b !RAM_SMW_Misc_ScratchRAM0F	;>Compare with difference in width/height
	BCC.b .CODE_03B75A		;>If max distance is smaller than the distance of the boxes, exit loop w/ carry clear.
	DEX				;>Next index (move from Y pos to X pos)
	BPL.b .CODE_03B72E		;>Loop if index is 0 or positive.
.CODE_03B75A:
	PLX				;>Restore sprite slot
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_UploadPlayerGFX(Address)					; Note: This is a SMAS (USA) exclusive routine macro
namespace SMW_UploadPlayerGFX
%InsertMacroAtXPosition(<Address>)

Luigi:
	CLC
	ADC.w #LuigiGFX-$2000
	STA.w DMA[$02].SourceLo
	LDY.b #LuigiGFX>>16
	STY.w DMA[$02].SourceBank
	STX.w !REGISTER_DMAEnable
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo
	STA.w !REGISTER_VRAMAddressLo
	LDY.b #$00
	CLC
CODE_33E076:
	LDA.w SMW_DynamicSpritePointersTop[$00].LowByte,y
	ADC.w #LuigiGFX-$2000
	STA.w DMA[$02].SourceLo
	LDA.w #$0040
	STA.w DMA[$02].SizeLo
	STX.w !REGISTER_DMAEnable
	INY
	INY
	CPY.b #$04
	BNE.b CODE_33E076
	LDY.b #!RAM_SMW_Graphics_DecompressedGFX33>>16
	STY.w DMA[$02].SourceBank
	LDY.b #$04
CODE_33E095:
	LDA.w SMW_DynamicSpritePointersTop[$00].LowByte,y
	STA.w DMA[$02].SourceLo
	LDA.w #$0040
	STA.w DMA[$02].SizeLo
	STX.w !REGISTER_DMAEnable
	INY
	INY
	CPY.w !RAM_SMW_Player_NumberOfTilesToUpdate
	BCC.b CODE_33E095
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$0100
	STA.w !REGISTER_VRAMAddressLo
	LDY.b #LuigiGFX>>16
	STY.w DMA[$02].SourceBank
	LDY.b #$00
	CLC
CODE_33E0B9:
	LDA.w SMW_DynamicSpritePointersBottom[$00].LowByte,y
	ADC.w #LuigiGFX-$2000
	STA.w DMA[$02].SourceLo
	LDA.w #$0040
	STA.w DMA[$02].SizeLo
	STX.w !REGISTER_DMAEnable
	INY
	INY
	CPY.b #$04
	BNE.b CODE_33E0B9
	LDY.b #!RAM_SMW_Graphics_DecompressedGFX33>>16
	STY.w DMA[$02].SourceBank
	LDY.b #$04
CODE_33E0D8:
	LDA.w SMW_DynamicSpritePointersBottom[$00].LowByte,y
	STA.w DMA[$02].SourceLo
	LDA.w #$0040
	STA.w DMA[$02].SizeLo
	STX.w !REGISTER_DMAEnable
	INY
	INY
	CPY.w !RAM_SMW_Player_NumberOfTilesToUpdate
	BCC.b CODE_33E0D8
	SEP.b #$20
	RTL
namespace off
endmacro

macro ROUTINE_RT07_SMW_GameMode14_InLevel(Address)
namespace SMW_GameMode14_InLevel
%InsertMacroAtXPosition(<Address>)

; The tile numbers to use for the animated lava sprite tiles in Iggy/Larry's
; room. Default values are $68, $6A, $6C and $6E.
DATA_03C0B2:
	db $68,$6A,$6C,$6E

; The animation offsets for the animated lava sprite tiles in Iggy/Larry's
; room (e.g. if you set all of them to the same value, they would all
; display the same tile at once). Strangely, some of them are #$04, despite
; nothing using that bit.
DATA_03C0B6:
	db $00,$03,$01,$02,$04,$02,$00,$01
	db $00,$04,$00,$02,$00,$03,$04,$01

CODE_03C0C6:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_03C0CD
	JSR.w CODE_03C11E
; The subroutine that displays the animated lava sprite tiles in
; Iggy/Larry's room (as well as calling his platform tilting routine, not
; included). It makes use of 4 bytes at $03C0B2 and 16 bytes at $03C0B6,
; respectively for determining the tile numbers to use and their animation
; offset. If you want to disable it for some reason, you can just put an RTL
; there.
CODE_03C0CD:
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b #$13
	LDY.b #$B0
CODE_03C0D3:
	STX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$C4
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$09
	STA.w SMW_OAMBuffer[$40].Prop,y
	PHX
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	CLC
	ADC.l DATA_03C0B6,x
	AND.b #$03
	TAX
	LDA.l DATA_03C0B2,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	TYA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03C0D3
	RTL

; Speed of rotation of Iggy/Larry's platform
IggyPlatSpeed:
	db $FF,$01,$FF,$01

DATA_03C116:
	db $FF,$00,$FF,$00

; How far to Iggy/Larry's rotate platforms
IggyPlatBounds:
	db $E7,$18,$D7,$28

; The subroutine that takes care of tilting Iggy/Larry's Mode 7 platform. It
; makes use of 4 bytes at $03C112, 4 bytes at $03C11A and 1 byte at $03C164,
; respectively for determining the tilting speeds, maximum angles and time
; to elapse between each tilt. It also uses RAM adresses $1905, $1906 and
; $1907, respectively for the total number of tilts made, the timer between
; each tilt and the phase counter (See these for more details). If you want
; to disable it for some reason, you can just put an RTS there.
CODE_03C11E:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ If sprites locked...
	ORA.w !RAM_SMW_Timer_EndLevel	; | ...or battle is over (set to FF when over)...
	BNE.b Return03C175		; / ...return
	LDA.w !RAM_SMW_Timer_WaitBeforeNextTiltingPlatformPhase	; \ If platform at a maximum tilt, (stationary timer > 0)
	BEQ.b CODE_03C12D
	DEC.w !RAM_SMW_Timer_WaitBeforeNextTiltingPlatformPhase	; / decrement stationary timer
CODE_03C12D:
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Return every other time through...
	AND.b #$01
	ORA.w !RAM_SMW_Timer_WaitBeforeNextTiltingPlatformPhase	; | ...return if stationary
	BNE.b Return03C175
	LDA.w !RAM_SMW_Counter_DirectionToTiltPlatform	; $1907 holds the total number of tilts made
	AND.b #$01			; \ X=1 if platform tilted up to the right (/)...
	TAX				; / ...else X=0
	LDA.w !RAM_SMW_Counter_TiltingPlatformPhase	; $1907 holds the current phase: 0/ 1\ 2/ 3\ 4// 5\\
	CMP.b #$04			; \ If this is phase 4 or 5...
	BCC.b CODE_03C145		; | ...cause a steep tilt by setting X=X+2
	INX
	INX
CODE_03C145:
	LDA.b !RAM_SMW_Misc_M7RotationLo	; $36 is tilt of platform: //D8 /E8 -0- 18\ 28\\
	CLC				; \ Get new tilt of platform by adding value
	ADC.l IggyPlatSpeed,x
	STA.b !RAM_SMW_Misc_M7RotationLo
	PHA
	LDA.b !RAM_SMW_Misc_M7RotationHi	; $37 is boolean tilt of platform: 0\ /1
	ADC.l DATA_03C116,x		; \ if tilted up to left,  $37=0
	AND.b #$01			; | if tilted up to right, $37=1
	STA.b !RAM_SMW_Misc_M7RotationHi
	PLA
	CMP.l IggyPlatBounds,x		; \ Return if platform not at a maximum tilt
	BNE.b Return03C175
	INC.w !RAM_SMW_Counter_DirectionToTiltPlatform	; Increment total number of tilts made
	LDA.b #$40			; \ Set timer to stay stationary
	STA.w !RAM_SMW_Timer_WaitBeforeNextTiltingPlatformPhase
	INC.w !RAM_SMW_Counter_TiltingPlatformPhase	; Increment phase
	LDA.w !RAM_SMW_Counter_TiltingPlatformPhase	; \ If phase > 5, phase = 0
	CMP.b #$06
	BNE.b Return03C175
	STZ.w !RAM_SMW_Counter_TiltingPlatformPhase
Return03C175:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DespawnNonBossSprites(Address)
namespace SMW_DespawnNonBossSprites
%InsertMacroAtXPosition(<Address>)

; Routine which kills most active sprites and turn them into a smoke. Only
; the last two sprite slots as well as sprites with a certain ID are not
; affected. $03A6E3 is the sprite state to give to the affected sprites.
; $03A6E8 is the timer for how long the is smoke is active.
Main:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_03A6CA:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_03A6EC
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr0A9_Reznor
	BEQ.b CODE_03A6EC
	CMP.b #!Define_SMW_SpriteID_NorSpr029_KoopaKids
	BEQ.b CODE_03A6EC
	CMP.b #!Define_SMW_SpriteID_NorSpr0A0_ActivateBowserBattle
	BEQ.b CODE_03A6EC
	CMP.b #!Define_SMW_SpriteID_NorSpr0C5_BigBooBoss
	BEQ.b CODE_03A6EC
	LDA.b #!Define_SMW_NorSprStatus04_SpinJumpKill	; \ Sprite status = Killed by spin jump
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #$1F			; \ Time to show cloud of smoke = #$1F
	STA.w !RAM_SMW_NorSpr_SpinJumpKillTimer,y
CODE_03A6EC:
	DEY
	BPL.b CODE_03A6CA
	RTL
namespace off
endmacro

macro ROUTINE_RT03_SMW_CheckPlayerPositionRelativeToSprite(Address)
namespace SMW_CheckPlayerPositionRelativeToSprite
%InsertMacroAtXPosition(<Address>)

Bank03:
.X:
%CheckPlayerPositionRelativeToSpriteSub(RAM_SMW_Player_XPos, RAM_SMW_NorSpr_XPos, !RAM_SMW_Misc_ScratchRAM0F, none)

.Y:
;$03B829
%CheckPlayerPositionRelativeToSpriteSub(RAM_SMW_Player_YPos, RAM_SMW_NorSpr_YPos, !RAM_SMW_Misc_ScratchRAM0F, none)
namespace off
endmacro

macro ROUTINE_RT03_SMW_CheckIfNormalSpriteOffScreen(Address)
namespace SMW_CheckIfNormalSpriteOffScreen
%InsertMacroAtXPosition(<Address>)

Bank03:
	%INLINEROUTINE_SMW_CheckIfNormalSpriteOffScreen()
namespace off
endmacro

macro ROUTINE_RT03_SMW_SubOffscreen(Address)
namespace SMW_SubOffscreen
%InsertMacroAtXPosition(<Address>)

Bank03:
.DATA_03B83B:
	db $40,$B0

.DATA_03B83D:
	db $01,$FF

.DATA_03B83F:
	db $30,$C0,$A0,$80,$A0,$40,$60,$B0

.DATA_03B847:
	db $01,$FF,$01,$FF,$01,$00,$01,$FF

.Entry4:
	LDA.b #$06			; \ Entry point of routine determines value of $03
	BRA.b .CODE_03B859

.Entry3:					;\ Note: Unused
	LDA.b #$04				;|
	BRA.b .CODE_03B859			;/

.Entry2:					;\ Note: Unused
	LDA.b #$02				;/
.CODE_03B859:
	STA.b !RAM_SMW_Misc_ScratchRAM03
	BRA.b .CODE_03B85F

.Entry1:
	STZ.b !RAM_SMW_Misc_ScratchRAM03
.CODE_03B85F:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank03	; \ if sprite is not off screen, return
	BEQ.b .Return03B8C2
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	; \  vertical level
	AND.b #$01
	BNE.b .VerticalLevel
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$50			; | if the sprite has gone off the bottom of the level...
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	; | (if adding 0x50 to the sprite y position would make the high byte >= 2)
	ADC.b #$00
	CMP.b #$02
	BPL.b .EraseSprite		; /    ...erase the sprite
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ if "process offscreen" flag is set, return
	AND.b #!Define_SMW_NorSpr_167AProp_TrackWhenOffScreen
	BNE.b .Return03B8C2
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM01
	TAY
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w .DATA_03B83F,y
	ROL.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b !RAM_SMW_NorSpr_XPosLo_x
	PHP
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w .DATA_03B847,y
	PLP
	SBC.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LSR.b !RAM_SMW_Misc_ScratchRAM01
	BCC.b .CODE_03B8A8
	EOR.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
.CODE_03B8A8:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b .Return03B8C2
.EraseSprite:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ If sprite status < 8, permanently erase sprite
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b .OffScrKillSpr
	LDY.w !RAM_SMW_NorSpr_LoadStatusTableIndex,x	; \ Branch if should permanently erase sprite
	CPY.b #$FF
	BEQ.b .OffScrKillSpr
if defined("Define_SMW_SA1")
	JSL.l SpriteLoading_CODE_01AC9C
	NOP
else
	LDA.b #$00			; \ Allow sprite to be reloaded by level loading routine
	STA.w !RAM_SMW_Sprites_LoadStatus,y
endif
.OffScrKillSpr:
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
.Return03B8C2:
	RTS

.VerticalLevel:
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ If "process offscreen" flag is set, return
	AND.b #!Define_SMW_NorSpr_167AProp_TrackWhenOffScreen
	BNE.b .Return03B8C2
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Return every other frame
	LSR
	BCS.b .Return03B8C2
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM01
	TAY
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.w .DATA_03B83B,y
	ROL.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b !RAM_SMW_NorSpr_YPosLo_x
	PHP
	LDA.w !RAM_SMW_Mirror_CurrentLayer1YPosHi
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w .DATA_03B83D,y
	PLP
	SBC.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	BEQ.b .CODE_03B8F5
	EOR.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
.CODE_03B8F5:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b .Return03B8C2
	BMI.b .EraseSprite
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeMode7TilemapsAndPalettes(Address)
namespace SMW_InitializeMode7TilemapsAndPalettes
%InsertMacroAtXPosition(<Address>)

TilemapData:
.Morton:
..Pose00:
..Pose01:
..Pose02:
..Pose03:
..Pose04:
..Pose05:
..Pose06:
..Pose07:
..Pose08:
	; Morton, Roy and Ludwig tilemap
	incbin "tilemaps/mode7/morton.bin"
.Roy:
..Pose00:
..Pose01:
..Pose02:
..Pose03:
..Pose04:
..Pose05:
..Pose06:
..Pose07:
..Pose08:
	incbin "tilemaps/mode7/roy.bin"
.Ludwig:
..Pose00:
..Pose01:
..Pose02:
..Pose03:
..Pose04:
..Pose05:
..Pose06:
..Pose07:
..Pose08:
	incbin "tilemaps/mode7/ludwig.bin"
.Bowser:
..Pose00_Neutral:
..Pose01_Blink:
..Pose02_BlinkAndCloseMouth:
..Pose03_Emerging1:
..Pose04_Emerging2:
..Pose05_Emerging3:
..Pose06_Hurt1:
..Pose07_InsideCar:
..Pose08_Hurt2:
..Pose09_Hurt3:
	; Bowser tilemap
	incbin "tilemaps/mode7/bowser.bin"

; Low byte for the pointers to the SNES addresses for Morton, Roy, and
; Ludwig's palettes. The last two bytes are unused.
PalPtrLo:
	db SMW_GlobalPalettes_InitBossFightMorton	; Morton
	db SMW_GlobalPalettes_InitBossFighRoy		; Roy
	db SMW_GlobalPalettes_InitBossFightLudwig	; Ludwig
	db SMW_GlobalPalettes_InitBossFightBowser	; Bowser
	db SMW_GlobalPalettes_InitBossFightReznor	; Reznor

; High byte for the pointers to the SNES addresses for Morton, Roy, and
; Ludwig's palettes. The last two bytes are unused.
PalPtrHi:
	db SMW_GlobalPalettes_InitBossFightMorton>>8	; Morton
	db SMW_GlobalPalettes_InitBossFighRoy>>8	; Roy
	db SMW_GlobalPalettes_InitBossFightLudwig>>8	; Ludwig
	db SMW_GlobalPalettes_InitBossFightBowser>>8	; Bowser
	db SMW_GlobalPalettes_InitBossFightReznor>>8	; Reznor

; The graphics ID for some Mode 7 bosses, indexed by $7E13FC. A value of $00
; means to upload no planar graphics for the boss battle.
GFXFile:
	db $0B		; Morton
	db $0B		; Roy
	db $0B		; Ludwig
	db $21		; Bowser
	db $00		; Reznor

Main:
if defined("Define_SMW_SA1")
	JML.l MoreMode7
else
	PHX
	PHB
	PHK
	PLB
endif
	LDY.b !RAM_SMW_NorSprXXX_CurrentlyActiveBoss,x
	STY.w !RAM_SMW_Misc_CurrentlyActiveBoss
	CPY.b #$04
	BNE.b CODE_03DD97
	JSR.w BufferReznorWallTilemap
	LDA.b #$48
	STA.b !RAM_SMW_Mirror_M7CenterYPosLo
	LDA.b #$14
	STA.b !RAM_SMW_Misc_M7AngleLo
	STA.b !RAM_SMW_Misc_M7AngleHi
CODE_03DD97:
	LDA.b #$FF
	STA.b !RAM_SMW_Misc_ScreensInLvl
	INC
	STA.b !RAM_SMW_Camera_LastScreenHoriz
	LDY.w !RAM_SMW_Misc_CurrentlyActiveBoss
	LDX.w GFXFile,y
	LDA.w PalPtrLo,y		; \ $00 = Pointer in bank 0 (from above tables)
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w PalPtrHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
if ver_is_smasw(!Define_Global_ROMToAssemble)
	LDA.b #SMW_GlobalPalettes_Main>>16				; Note: #!BANK_30
	STA.b !RAM_SMW_Misc_ScratchRAM02
else
	STZ.b !RAM_SMW_Misc_ScratchRAM02 				; Note: #!BANK_00
endif
	LDY.b #$0B			; \ Read 0B bytes and put them in $0707
CODE_03DDB2:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.w SMW_PaletteMirror[$02].LowByte,y
	DEY
	BPL.b CODE_03DDB2
	LDA.b #$80
	STA.w !REGISTER_VRAMAddressIncrementValue
	STZ.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	STZ.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	TXY
	BEQ.b CODE_03DDD7
#LM000Hijack_DecompressAndConverGFXTo3BPP2:
	JSL.l SMW_GraphicsDecompressionRoutines_Main			; LM: Changes this JSL.l to point to $0EFC00
	LDA.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM03
CODE_03DDD0:
	JSR.w BufferTilemap
	DEC.b !RAM_SMW_Misc_ScratchRAM03
	BNE.b CODE_03DDD0
CODE_03DDD7:
	LDX.b #$5F
CODE_03DDD9:
	LDA.b #$FF
	STA.l !RAM_SMW_Misc_Mode7BossTilemap,x
	DEX
	BPL.b CODE_03DDD9
	PLB
if defined("Define_SMW_SA1")
	NOP
else
	PLX
endif
	RTL

; SMW 3bpp to Mode 7 8bpp converter. Used to decode the graphics of Morton,
; Roy, Ludwig and Bowser. This routine takes a regular 3bpp tile and
; converts it into a linear 8bpp tile usable by Mode 7, buffering it to
; $1BA3. In doing so, the tile gets stored both in normal and in reverse
; order which results in the tile getting flipped.
BufferTilemap:
	LDX.b #$00
	TXY
	LDA.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM05
CODE_03DDEC:
	JSR.w CODE_03DE39
	PHY
	TYA
	LSR
	CLC
	ADC.b #$0F
	TAY
	JSR.w CODE_03DE3C
	LDY.b #$08
CODE_03DDFB:
	LDA.w !RAM_SMW_Graphics_Mode7TileBuffer,x
	ASL
	ROL
	ROL
	ROL
	AND.b #$07
	STA.w !RAM_SMW_Graphics_Mode7TileBuffer,x
	STA.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	INX
	DEY
	BNE.b CODE_03DDFB
	PLY
	DEC.b !RAM_SMW_Misc_ScratchRAM05
	BNE.b CODE_03DDEC
	LDA.b #$07
CODE_03DE15:
	TAX
	LDY.b #$08
	STY.b !RAM_SMW_Misc_ScratchRAM05
CODE_03DE1A:
	LDY.w !RAM_SMW_Graphics_Mode7TileBuffer,x
	STY.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	DEX
	DEC.b !RAM_SMW_Misc_ScratchRAM05
	BNE.b CODE_03DE1A
	CLC
	ADC.b #$08
	CMP.b #$40
	BCC.b CODE_03DE15
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC							;\ Todo: I wonder if changing this to #$0020 would allow the mode 7 bosses to be 4BPP?
	ADC.w #$0018						;/ More changes may be needed to make that work though.
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	RTS

CODE_03DE39:
	JSR.w CODE_03DE3C
CODE_03DE3C:
	PHX
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	PHY
	LDY.b #$08
CODE_03DE42:
	ASL
	ROR.w !RAM_SMW_Graphics_Mode7TileBuffer,x
	INX
	DEY
	BNE.b CODE_03DE42
	PLY
	INY
	PLX
	RTS

DATA_03DE4E:
	incbin "tilemaps/mode7/ReznorWall.bin"

BufferReznorWallTilemap:
	STZ.w !REGISTER_VRAMAddressIncrementValue
	REP.b #$20			; A->16
	LDA.w #!VRAM_SMW_Layer1GFXVRAMLocation+$0A1C
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b #$00
CODE_03DE9A:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0080
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	SEP.b #$20			; A->8
	LDY.b #$08
CODE_03DEAB:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.w DATA_03DE4E,x
else
	LDA.l DATA_03DE4E,x
endif
	STA.w !REGISTER_WriteToVRAMPortLo	; Data for VRAM Write (Low Byte)
	INX
	DEY
	BNE.b CODE_03DEAB
	CPX.b #$40
	BCC.b CODE_03DE9A
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_TriggerHidden1up(Address)
namespace SMW_TriggerHidden1up
%InsertMacroAtXPosition(<Address>)

Main:
	PHX				; \ Find free sprite slot (#$0B-#$00)
	LDX.b #!Define_SMW_MaxNormalSpriteSlot
CODE_03C2DC:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	BEQ.b Generate1Up
	DEX
	BPL.b CODE_03C2DC
	PLX
	RTL

Generate1Up:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
if defined("Define_SMW_SA1")
	; SA-1 Pack: Invisible 1up stuff.
	JSL.l INVIS_1UP_SET
else
	LDA.b #!Define_SMW_SpriteID_NorSpr078_1upMushroom	; \ Sprite = 1Up
	STA.b !RAM_SMW_NorSpr_SpriteID_x
endif
	LDA.b !RAM_SMW_Player_XPosLo	; \ Sprite X position = Mario X position
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Player_XPosHi
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Player_YPosLo	; \ Sprite Y position = Matio Y position
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Player_YPosHi
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Load sprite tables
	LDA.b #$10			; \ Disable interaction timer = #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	JSR.w SMW_NorSpr0C7_InvisibleMushroom_Status08_PopupMushroom_Main
	PLX
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_AimTowardsPlayer(Address)
namespace SMW_AimTowardsPlayer
%InsertMacroAtXPosition(<Address>)

Bank03:
	%INLINEROUTINE_SMW_AimTowardsPlayer(Bank03)
namespace off
endmacro

macro ROUTINE_RT01_SMW_HandleNormalSpriteLevelCollision(Address)
namespace SMW_HandleNormalSpriteLevelCollision
%InsertMacroAtXPosition(<Address>)

DATA_03C1C6:
	db $02,$FE

DATA_03C1C8:
	db $00,$FF

CODE_03C1CA:
	PHB
	PHK
	PLB
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	BPL.b CODE_03C1D5
	INY
CODE_03C1D5:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w DATA_03C1C6,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.w DATA_03C1C8,y
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b #$18
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT04_SMW_GameMode12_PrepareLevel(Address)
namespace SMW_GameMode12_PrepareLevel
%InsertMacroAtXPosition(<Address>)

IggyPlatformTiles:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$15,$16,$17,$18,$17,$18,$17,$18,$17,$18,$19,$1A,$00,$00
	db $00,$00,$01,$02,$03,$04,$03,$04,$03,$04,$03,$04,$05,$12,$00,$00
	db $00,$00,$00,$07,$04,$03,$04,$03,$04,$03,$04,$03,$08,$00,$00,$00
	db $00,$00,$00,$09,$0A,$04,$03,$04,$03,$04,$03,$0B,$0C,$00,$00,$00
	db $00,$00,$00,$00,$0D,$0E,$04,$03,$04,$03,$0F,$10,$00,$00,$00,$00
	db $00,$00,$00,$00,$11,$02,$03,$04,$03,$04,$05,$12,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$07,$04,$03,$04,$03,$08,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$09,$0A,$04,$03,$0B,$0C,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$13,$03,$04,$14,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$13,$14,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

DATA_03D8EC:
	incbin "tilemaps/mode7/TiltingPlatform.bin"

UploadTiltingPlatformTilemap:
	REP.b #$10			; XY->16
	STZ.w !REGISTER_VRAMAddressIncrementValue
	STZ.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	STZ.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.w #$4000
	LDA.b #$FF
CODE_03D968:
	STA.w !REGISTER_WriteToVRAMPortLo	; Data for VRAM Write (Low Byte)
	DEX
	BNE.b CODE_03D968
	SEP.b #$10			; XY->8
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVS.b Return03D990
	PHB
	PHK
	PLB
	LDA.b #IggyPlatformTiles
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b #IggyPlatformTiles>>8
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b #IggyPlatformTiles>>16
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM01
	JSR.w CODE_03D991
	PLB
Return03D990:
	RTL

CODE_03D991:
	STZ.w !REGISTER_VRAMAddressIncrementValue
	LDY.b #$00
CODE_03D996:
	STY.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$00
CODE_03D99A:
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDY.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_03D9AC:
	LDA.b [!RAM_SMW_Misc_ScratchRAM05],y
	STA.w !RAM_SMW_Misc_IggyLarryPlatformInteraction,y
	ASL
	ASL
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.w DATA_03D8EC,x
else
	LDA.l DATA_03D8EC,x
endif
	STA.w !REGISTER_WriteToVRAMPortLo	; Data for VRAM Write (Low Byte)
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.w DATA_03D8EC+$02,x
else
	LDA.l DATA_03D8EC+$02,x
endif
	STA.w !REGISTER_WriteToVRAMPortLo	; Data for VRAM Write (Low Byte)
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BNE.b CODE_03D9AC
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b CODE_03D9D4
	INC.b !RAM_SMW_Misc_ScratchRAM01
CODE_03D9D4:
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	EOR.b #$01
	BNE.b CODE_03D99A
	TYA
	BNE.b CODE_03D996
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UpdateMode7SpriteAnimations(Address)
namespace SMW_UpdateMode7SpriteAnimations
%InsertMacroAtXPosition(<Address>)

DATA_03DEBB:
	dw $0100,$0110

DATA_03DEBF:
	db $6E,$70,$FF,$50,$FE,$FE,$FF,$57

DATA_03DEC7:
	db $72,$74,$52,$54,$3C,$3E,$55,$53

DATA_03DECF:
	db $76,$56,$56,$FF,$FF,$FF,$51,$FF

DATA_03DED7:
	db $20,$03,$30,$03,$40,$03,$50,$03

Main:
if defined("Define_SMW_SA1")
	JML.l Mode7Stuff
	NOP #2
else
	PHB
	PHK
	PLB
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
endif
	XBA
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	LDY.b #$00
	JSR.w CODE_03DFAE
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	XBA
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	LDY.b #$02
	JSR.w CODE_03DFAE
	PHX
	REP.b #$30			; AXY->16
	STZ.b !RAM_SMW_Misc_ScratchRAM06
	LDY.w #$0003
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	LSR
	BCC.b CODE_03DF44
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_PropellerAnimationFrameCounter
	AND.w #$0003
	ASL
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.w DATA_03DEBF,x
else
	LDA.l DATA_03DEBF,x
endif
	STA.l !RAM_SMW_Misc_Mode7BossTilemap+$01
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.w DATA_03DEC7,x
else
	LDA.l DATA_03DEC7,x
endif
	STA.l !RAM_SMW_Misc_Mode7BossTilemap+$03
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.w DATA_03DECF,x
else
	LDA.l DATA_03DECF,x
endif
	STA.l !RAM_SMW_Misc_Mode7BossTilemap+$05
	LDA.w #$0008
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDX.w #$0380
	LDA.w !RAM_SMW_Misc_Mode7TilemapIndex
	AND.w #$007F
	CMP.w #$002C
	BCC.b CODE_03DF3C
	LDX.w #$0388
CODE_03DF3C:
	TXA
	LDX.w #$000A
	LDY.w #$0007
	SEC
CODE_03DF44:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	BCS.b CODE_03DF55
CODE_03DF48:
	LDA.w !RAM_SMW_Misc_Mode7TilemapIndex
	AND.w #$007F
	ASL
	ASL
	ASL
	ASL
	LDX.w #$0003
CODE_03DF55:
	STX.b !RAM_SMW_Misc_ScratchRAM02
	PHA
	LDY.w !RAM_SMW_UnusedRAM_7E1BA1			;\ Optimization: Unused?
	BPL.b CODE_03DF60				;|
	CLC						;|
	ADC.b !RAM_SMW_Misc_ScratchRAM00		;/
CODE_03DF60:
	TAY
	SEP.b #$20			; A->8
	LDX.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_03DF69:
	LDA.w SMW_InitializeMode7TilemapsAndPalettes_TilemapData,y
	INY
	BIT.w !RAM_SMW_Misc_Mode7TilemapIndex
	BPL.b CODE_03DF76
	EOR.b #$01
	DEY
	DEY
CODE_03DF76:
	STA.l !RAM_SMW_Misc_Mode7BossTilemap,x
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_03DF69
	STX.b !RAM_SMW_Misc_ScratchRAM06
	REP.b #$20			; A->16
	PLA
	SEC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	CPX.w #$0004
	BEQ.b CODE_03DF48
	CPX.w #$0008
	BNE.b CODE_03DF96
	LDA.w #$0360
CODE_03DF96:
	CPX.w #$000A
	BNE.b CODE_03DFA6
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ClownCarFaceAnimationFrame
	AND.w #$0003
	ASL
	TAY
	LDA.w DATA_03DED7,y
CODE_03DFA6:
	DEX
	BPL.b CODE_03DF55
	SEP.b #$30			; AXY->8
	PLX
	PLB
	RTL

CODE_03DFAE:
	PHX
	TYX
	REP.b #$20			; A->16
	EOR.w #$FFFF
	INC
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.w DATA_03DEBB,x
else
	ADC.l DATA_03DEBB,x
endif
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x
	STA.b !RAM_SMW_Mirror_M7XPosLo,x
	SEP.b #$20			; A->8
	PLX
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr01B_Football_Status08(Address)
namespace SMW_NorSpr01B_Football_Status08
%InsertMacroAtXPosition(<Address>)

DATA_038007:								;\ Glitch: This table needs to be 2 bytes larger. Otherwise, the football will read a value from the below table and from the above Rex stomp sound table when landing on very steep slopes.
	db $F0,$F8,$FC,$00,$04,$08,$10					;/

DATA_03800E:
	db $A0,$D0,$C0,$D0

Bank03:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038086		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	LDA.w !RAM_SMW_NorSpr01B_Football_WaitBeforeBeingKicked,x	;\ if sprite not spinjumped,
	BEQ.b CODE_03802D		;/ branch
	DEC				;\ if sprite not about to disappear after getting spinjumped (?),
	BNE.b CODE_038031		;/ branch
	JSL.l SMW_SpawnContactEffectFromSide_Main	; show smoke
CODE_03802D:
	JSL.l SMW_HandleNormalSpriteGravity_Main
CODE_038031:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_03803F
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;\ horizontal contact -> reverse horizontal speed
	EOR.b #$FF			; |
	INC				; | and increase new speed by one
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
CODE_03803F:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;\ if sprite not touching ceiling, branch
	AND.b #$08			; |
	BEQ.b CODE_038048		;/
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_038048:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b Return038086
	LDA.w !RAM_SMW_NorSpr01B_Football_WaitBeforeBeingKicked,x	;\ if sprite spinjumped (?),
	BNE.b Return038086		;/ return
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x	;\ flip sprite graphics
	EOR.b #$40			; |
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x	;/
	JSL.l SMW_GetRand_Main		;\ use random number generator to
	AND.b #$03			; | determine new y speed
	TAY				; |
	LDA.w DATA_03800E,y		; |
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	LDY.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	INY
	INY
	INY
	LDA.w DATA_038007,y
	CLC
	ADC.b !RAM_SMW_NorSpr_XSpeed,x
	BPL.b CODE_03807E		; if sprite going to the left, branch
	CMP.b #$E0			;\ if sprite x speed slower than #$E0,
	BCS.b CODE_038084		; |
	LDA.b #$E0			; | load #$E0,
	BRA.b CODE_038084		;/

CODE_03807E:
	CMP.b #$20			;\ if sprite x speed slower than #$20,
	BCC.b CODE_038084		; |
	LDA.b #$20			;/ load #$20,
CODE_038084:
	STA.b !RAM_SMW_NorSpr_XSpeed,x	; and set new sprite x speed (to prevent sprite from going slower than #$20 or #$E0)
Return038086:
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr01F_Magikoopa_Status08(Address)
namespace SMW_NorSpr01F_MagiKoopa_Status08
%InsertMacroAtXPosition(<Address>)

; Magikoopa palettes (8 palettes; 8 colours each, including transparent
; colour)
MagiKoopaFadePalettes:
.Fade07:						;\ Note: For some reason, the lightest blue color is inverted from what it should be in each palette row.
	incbin "palettes/MagiKoopa.tpl":$6..$16		;|
.Fade06:						;|
	incbin "palettes/MagiKoopa.tpl":$26..$36		;|
.Fade05:						;|
	incbin "palettes/MagiKoopa.tpl":$46..$56		;|
.Fade04:						;|
	incbin "palettes/MagiKoopa.tpl":$66..$76		;|
.Fade03:						;|
	incbin "palettes/MagiKoopa.tpl":$86..$96		;|
.Fade02:						;|
	incbin "palettes/MagiKoopa.tpl":$A6..$B6		;|
.Fade01:						;|
	incbin "palettes/MagiKoopa.tpl":$C6..$D6		;|
.Normal:						;|
	incbin "palettes/MagiKoopa.tpl":$E6..$F6		;/
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr029_KoopaKid_Status08_WendyLemmy(Address)
namespace SMW_NorSpr029_KoopaKid_Status08_WendyLemmy
%InsertMacroAtXPosition(<Address>)

Bank03:
	PHB				; Wrapper
	PHK
	PLB
	STZ.w !RAM_SMW_NorSpr_PropertyBits1662,x
	JSR.w Sub
	PLB
	RTL

; Subroutine for the Lemmy Koopa and Wendy O. Koopa boss fights. Jumps to a
; graphics subroutine, then if the sprite is dead or the lock sprites flag
; is set, returns. Otherwise, loads the current fight phase from table
; $151C, then executes the pointer subroutine.
Sub:
	JSR.w GFXRt
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b Return03CC37
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return03CC37
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

; Pointers to the various phase routines of the Lemmy Koopa and Wendy O.
; Koopa boss fights. [8A CC] Phase 0: In pipe [21 CD] Phase 1: Rising [C7
; CD] Phase 2: Out of pipe [EF CD] Phase 3: Descending [0E CE] Phase 4: Hit
; [5A CE] Phase 5: Falling [89 CE] Phase 6: Sinking in lava
WendyLemmyPtrs:
	dw State00_InPipe
	dw State01_Rising
	dw State02_OutOfPipe
	dw State03_Descending
	dw State04_Hurt
	dw State05_Falling
	dw State06_SinkingInLava

Return03CC37:
	RTS

; Possible X positions for Lemmy/Wendy and their decoys.
SpawningXPos:
	db $18,$38,$58,$78,$98,$B8,$D8,$78

; Possible Y positions for Lemmy and his decoys.
LemmySpawningYPos:
	db $40,$50,$50,$40,$30,$40,$50,$40

; Number of frames Wendy and Lemmy take to emerge from their pipes, indexed
; by the animation they are performing.
DATA_03CC48:
	db $50,$4A,$50,$4A,$4A,$40,$4A,$48
	; Number of frames that Wendy/Lemmy's dummies take to rise out of their
	; pipes.
	db $4A

DATA_03CC51:
	db $02,$04,$06,$08,$0B,$0C,$0E,$10
	db $13

; Indexes to $03CC38 / $03CC40 to choose from for each RNG value (00-0F).
; The first set of 16 bytes is used for Wendy/Lemmy, the second set is the
; corresponding value for the first dummy, and the third set is the
; corresponding value for the second dummy.
SpawningPositionIndexes:
.Real:
	db $00,$01,$02,$03,$04,$05,$06,$00,$01,$02,$03,$04,$05,$06,$00,$01
.Dummy1:
	db $02,$03,$04,$05,$06,$00,$01,$02,$03,$04,$05,$06,$00,$01,$02,$03
.Dummy2:
	db $04,$05,$06,$00,$01,$02,$03,$04,$05,$06,$00,$01,$02,$03,$04,$05

; Subroutine that runs for Lemmy Koopa and Wendy O. Koopa's "in pipe" phase.
; This routine handles several of the Lemmy/Wendy fight behaviours: - Calls
; the RNG routine to determine at what X positions (pipes) Lemmy/Wendy and
; their dummies appear out of. - Sets their Y positions depending on the
; pipe they appear from. Always #$50 if the boss is Wendy, otherwise, loads
; Y positions from a table corresponding to the heights of Lemmy's pipes. -
; Jumps to the routines that initialize the sprite tables. - Calls the RNG
; routine to determine Lemmy/Wendy's emerged animation pointer, and
; animation frame when coming out of a pipe. - Sets the phase timer for
; Lemmy/Wendy's next phase. Timer value depends on their current animation.
; - Increments the current phase table.
State00_InPipe:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	BNE.b Return03CCDF
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_DummyFlag,x
	BNE.b CODE_03CC9D
	JSL.l SMW_GetRand_Main
	AND.b #$0F
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_SpawnPositionIndex,x
CODE_03CC9D:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_SpawnPositionIndex,x
	ORA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_DummyFlag,x
	TAY
	LDA.w SpawningPositionIndexes,y
	TAY
	LDA.w SpawningXPos,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	CMP.b #$06
	LDA.w LemmySpawningYPos,y
	BCC.b CODE_03CCB8
	LDA.b #$50
CODE_03CCB8:
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$08
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_DummyFlag,x
	BNE.b CODE_03CCCC
	JSR.w CODE_03CCE2
	JSL.l SMW_GetRand_Main
	LSR
	LSR
	AND.b #$07
CODE_03CCCC:
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_AnimationPointer,x
	TAY
	LDA.w DATA_03CC48,y
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	INC.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_CurrentState,x
	LDA.w DATA_03CC51,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
Return03CCDF:
	RTS

DummyIDs:
	db $10,$20

CODE_03CCE2:
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$0A
	JSR.w CODE_03CCE8
	DEY
CODE_03CCE8:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr029_KoopaKids
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
	LDA.w DummyIDs,y
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_DummyFlag,y
	LDA.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	STA.w !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,y
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_SpawnPositionIndex,x
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_SpawnPositionIndex,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	RTS

; Subroutine that runs for Lemmy Koopa and Wendy O. Koopa's "rising" phase.
; Updates Lemmy/Wendy's Y speed and position when rising out of pipes. When
; the phase timer for this phase reaches 0, the routine sets the phase timer
; for the next phase, and increments the current phase table.
State01_Rising:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	BNE.b CODE_03CD2E
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	INC.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_CurrentState,x
CODE_03CD2E:
	LDA.b #$F8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	RTS

; Animation frame data for Lemmy Koopa and Wendy O. Koopa when out of a
; pipe. Indexed by a combination of the emerged animation pointer and the
; current phase timer.
LemmyAndWendyAnimationFrames:
.LookAtCamera:
	db $02,$02,$02,$02,$03,$03,$03,$03
	db $03,$03,$03,$03,$02,$02,$02,$02
.WavingHands1:
	db $04,$04,$04,$04,$05,$05,$04,$05
	db $05,$04,$05,$05,$04,$04,$04,$04
.OpenMouth:
	db $06,$06,$06,$06,$07,$07,$07,$07
	db $07,$07,$07,$07,$06,$06,$06,$06
..LookSideToSide:
	db $08,$08,$08,$08,$08,$09,$09,$08
	db $08,$09,$09,$08,$08,$08,$08,$08
.WeirdFace1:
	db $0B,$0B,$0B,$0B,$0B,$0A,$0B,$0A
	db $0B,$0A,$0B,$0A,$0B,$0B,$0B,$0B
.Legs:
	db $0C,$0C,$0C,$0C,$0D,$0C,$0D,$0C
	db $0D,$0C,$0D,$0C,$0D,$0D,$0D,$0D
.WeirdFace2:
	db $0E,$0E,$0E,$0E,$0E,$0F,$0E,$0F
	db $0E,$0F,$0E,$0F,$0E,$0E,$0E,$0E
.WavingHands2:
	db $10,$10,$10,$10,$11,$12,$11,$10
	db $11,$12,$11,$10,$11,$11,$11,$11
.Dummy:
	db $13,$13,$13,$13,$13,$13,$13,$13
	db $13,$13,$13,$13,$13,$13,$13,$13

; Subroutine that runs for Lemmy Koopa and Wendy O. Koopa's "out of pipe"
; phase. Jumps to a subroutine that checks if Mario has jumped on
; Lemmy/Wendy/dummy. If he hasn't, the routine checks if the current phase
; timer is 0. If it is, the the routine sets the phase timer for the next
; phase and increments the current phase table. If the phase timer is not 0,
; the routine jumps to a subroutine that handles Lemmy/Wendy's animations.
State02_OutOfPipe:
	JSR.w CheckForMarioStomp
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	BNE.b CODE_03CDDA
CODE_03CDCF:
	LDA.b #$24
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_CurrentState,x
	RTS

; Subroutine that handles Lemmy Koopa and Wendy O. Koopa's animations when
; out of a pipe. The accumulator contains the current phase timer when the
; routine is called, and is right-shifted twice then stored to $00. The
; emerged animation pointer is loaded, left-shifted four times, ORA'd with
; $00, and moved to the Y register to serve as an index for which animation
; frame to use.
CODE_03CDDA:
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_AnimationPointer,x
	ASL
	ASL
	ASL
	ASL
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	LDA.w LemmyAndWendyAnimationFrames,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

; Subroutine that runs for Lemmy Koopa and Wendy O. Koopa's "descending"
; phase. Updates Lemmy/Wendy's Y speed and position when the phase timer
; isn't 0. When the timer reaches 0, this routine clears the dummy sprite
; slots, sets the phase timer and resets the Lemmy/Wendy phase to 0 (in
; pipe).
State03_Descending:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	BNE.b CODE_03CE05
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_DummyFlag,x
	BEQ.b CODE_03CDFD
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

CODE_03CDFD:
	STZ.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_CurrentState,x
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
CODE_03CE05:
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	RTS

; Subroutine for Lemmy Koopa and Wendy O. Koopa's "hit" phase. If the phase
; timer is 0, this routine will increment the "hit counter" table, check if
; it's at 3, and if so, will zero Lemmy/Wendy's Y speed, play the falling
; SFX and increment the current phase table to "falling". If the "hit
; counter" table is not at 3, the routine will jump to code that sets the
; phase timer and sets the current phase to "descending". If the phase timer
; is not 0, this routine will check whether the sprite hit was Lemmy/Wendy
; or a dummy, play the appropriate SFX for hitting them, and set the
; appropriate animation frames.
State04_Hurt:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	; Change to F0 to make Lemmy/Wendy and enemies immediately go back into the
	; pipe when they have been hit. (will not play the correct! sound effect.)
	BNE.b CODE_03CE2A
	INC.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_HitCounter,x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_HitCounter,x
	CMP.b #$03
	BNE.b CODE_03CDCF
	LDA.b #$05
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_CurrentState,x
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.b #!Define_SMW_Sound1DF9_LemmyWendyFall
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	RTS

CODE_03CE2A:
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_DummyFlag,x
	BNE.b CODE_03CE42
CODE_03CE2F:
	CMP.b #$24
	BNE.b CODE_03CE38
	LDY.b #!Define_SMW_Sound1DFC_Correct
	STY.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
CODE_03CE38:
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$01
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

CODE_03CE42:
	CMP.b #$10
	BNE.b CODE_03CE4B
	LDY.b #!Define_SMW_Sound1DFC_Wrong
	STY.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
CODE_03CE4B:
	LSR
	LSR
	LSR
	TAY
	LDA.w DummyHurtFrames,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

; Animation frames for the Lemmy/Wendy dummies when hit by Mario. Indexed by
; the phase timer.
DummyHurtFrames:
	db $16,$16,$15,$14

; Subroutine for Lemmy Koopa and Wendy O. Koopa's "falling" phase. Updates
; Lemmy/Wendy's Y speed and position - Accelerates their falling speed until
; it reaches approximately #$40. When their Y low position reaches #$85, the
; routine spawns lava extended sprites, plays the "falling in lava" SFX,
; sets the phase timer, and sets the current phase to "sinking in lava". The
; routine then branches to part of the "hit" phase subroutine that sets
; Lemmy/Wendy's animation frames.
State05_Falling:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$40
	BPL.b CODE_03CE69
	CLC
	ADC.b #$03
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_03CE69:
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	BEQ.b CODE_03CE87
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$85
	BCC.b CODE_03CE87
	LDA.b #$06
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_CurrentState,x
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	LDA.b #!Define_SMW_Sound1DFC_LemmyWendyLandInLava
	; Change to [80 05] to disable the lava splash and sound effect when
	; Lemmy/Wendy fall into lava.
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	JSL.l SMW_SpawnLavaSplash_Main
CODE_03CE87:
	BRA.b CODE_03CE2F

; Subroutine that runs when Lemmy Koopa or Wendy O. Koopa are sinking in
; lava. Ends the level (boss fight) when their phase timer is 0, otherwise,
; updates their Y speed and position.
State06_SinkingInLava:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	BNE.b CODE_03CE9E
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	INC.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	LDA.b #$FF
	STA.w !RAM_SMW_Timer_EndLevel
	LDA.b #!Define_SMW_LevelMusic_PassedBoss
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
CODE_03CE9E:
	LDA.b #$04
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	RTS

; Contact routine for the Lemmy Koopa and Wendy O. Koopa boss fights. Runs
; the Mario-Sprite interaction routine, and if contact is made with Lemmy,
; Wendy or one of the dummies, will hurt Mario if his Y speed is negative or
; less than #$10. For other speeds, the routine calls the subroutines to
; give Mario points and boost him up, and plays the contact SFX (also the
; enemy hurt SFX if the sprite hit was Lemmy/Wendy). Also sets the phase
; timer, and increments the current phase of the fight to "hit". If the hit
; counter is at 2, this routine is also responsible for killing most sprites
; on screen (via JSL $03A6C8).
CheckForMarioStomp:
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	BCC.b Return03CEF1
	LDA.b !RAM_SMW_Player_YSpeed
	CMP.b #$10
	BMI.b CODE_03CEED
	JSL.l SMW_SpawnContactEffectFromAbove_Main
	LDA.b #$02
	JSL.l SMW_GivePoints_Main
	JSL.l SMW_BoostMarioSpeed_Main
	LDA.b #!Define_SMW_Sound1DF9_Contact
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_DummyFlag,x
	BNE.b CODE_03CEDB
	LDA.b #!Define_SMW_Sound1DFC_StunEnemy
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	; [BD 34 15] Change to [80 09] (BRA $09) to make sprites on screen never
	; die when stomping Lemmy Koopa or Wendy O. Koopa, regardless of their hit
	; points.
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_HitCounter,x
	CMP.b #$02
	BNE.b CODE_03CEDB
	JSL.l SMW_DespawnNonBossSprites_Main
CODE_03CEDB:
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_CurrentState,x
	LDA.b #$50
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_DummyFlag,x
	BEQ.b CODE_03CEE9
	LDA.b #$1F
CODE_03CEE9:
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	RTS

CODE_03CEED:
	JSL.l SMW_DamagePlayer_Hurt
Return03CEF1:
	RTS

; X offsets for the graphics of Lemmy Koopa and his decoys, indexed by their
; animation frame ($1602) times 6. Not all six bytes for each frame are
; actually used, though; the number of tiles per frame is instead determined
; by the table at $03D456.
LemmyXDisp:
	db $F8,$08,$F8,$08,$00,$00
	db $F8,$08,$F8,$08,$00,$00
	db $F8,$00,$00,$00,$00,$00
	db $FB,$00,$FB,$03,$00,$00
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$00,$00,$00,$00,$00
	db $F8,$00,$08,$00,$00,$00
	db $F8,$08,$00,$06,$00,$00
	db $F8,$08,$00,$02,$00,$00
	db $F8,$08,$00,$04,$00,$08
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00

; X offsets for the graphics of Wendy O. Koopa and her decoys, indexed by
; their animation frame ($1602) times 6. Not all six bytes for each frame
; are actually used, though; the number of tiles per frame is instead
; determined by the table at $03D46D. Change both $03CFAF and $03CFB5 to
; [$08] to fix a tilemap issue with Wendy's bow, in conjunction with the
; changes listed under $03D1A4.
WendyXDisp:
	db $F8,$08,$F8,$08,$00,$00
	db $F8,$08,$F8,$08,$00,$00
	db $F8,$00,$08,$00,$00,$00
	db $FB,$00,$FB,$03,$00,$00
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$00,$08,$00,$00,$00
	db $F8,$00,$08,$00,$00,$00
	db $F8,$08,$00,$06,$00,$08
	db $F8,$08,$00,$02,$00,$08
	db $F8,$08,$00,$04,$00,$08
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$08,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00
	db $F8,$08,$00,$00,$00,$00

; Y offsets for the graphics of Lemmy Koopa and his decoys, indexed by their
; animation frame ($1602) times 6. Not all six bytes for each frame are
; actually used, though; the number of tiles per frame is instead determined
; by the table at $03D456.
LemmyYDisp:
	db $04,$04,$14,$14,$00,$00
	db $04,$04,$14,$14,$00,$00
	db $00,$08,$F8,$00,$00,$00
	db $00,$08,$F8,$F8,$00,$00
	db $05,$05,$00,$F8,$F8,$00
	db $05,$05,$00,$00,$00,$00
	db $00,$08,$F8,$00,$00,$00
	db $00,$08,$00,$00,$00,$00
	db $05,$05,$00,$F8,$00,$00
	db $05,$05,$00,$F8,$00,$00
	db $05,$05,$00,$0F,$F8,$F8
	db $05,$05,$00,$F8,$F8,$00
	db $00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00
	db $05,$05,$00,$F8,$F8,$00
	db $05,$05,$00,$F8,$F8,$00
	db $04,$04,$02,$00,$00,$00
	db $04,$04,$01,$00,$00,$00
	db $04,$04,$00,$00,$00,$00
	db $05,$05,$00,$F8,$F8,$00
	db $05,$05,$00,$00,$00,$00
	db $05,$05,$03,$00,$00,$00
	db $05,$05,$04,$00,$00,$00

; Y offsets for the graphics of Wendy O. Koopa and her decoys, indexed by
; their animation frame ($1602) times 6. Not all six bytes for each frame
; are actually used, though; the number of tiles per frame is instead
; determined by the table at $03D46D.
WendyYDisp:
	db $04,$04,$14,$14,$00,$00
	db $04,$04,$14,$14,$00,$00
	db $00,$08,$00,$00,$00,$00
	db $00,$08,$F8,$F8,$00,$00
	db $05,$05,$00,$F8,$F8,$00
	db $05,$05,$00,$00,$00,$00
	db $00,$08,$00,$00,$00,$00
	db $00,$08,$08,$00,$00,$00
	db $05,$05,$00,$F8,$F8,$00
	db $05,$05,$00,$F8,$F8,$00
	db $05,$05,$00,$0F,$F8,$F8
	db $05,$05,$00,$F8,$F8,$00
	db $00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00
	db $05,$05,$00,$F8,$F8,$00
	db $05,$05,$00,$F8,$F8,$00
	db $04,$04,$02,$00,$00,$00
	db $04,$04,$01,$00,$00,$00
	db $04,$04,$00,$00,$00,$00
	db $05,$05,$00,$F8,$F8,$00
	db $05,$05,$00,$00,$00,$00
	db $05,$05,$03,$00,$00,$00
	db $05,$05,$04,$00,$00,$00

; Tile numbers for the graphics of Lemmy Koopa and his decoys, indexed by
; their animation frame ($1602) times 6. Not all six bytes for each frame
; are actually used, though; the number of tiles per frame is instead
; determined by the table at $03D456.
LemmyTiles:
	db $20,$20,$26,$26,$08,$00
	db $2E,$2E,$24,$24,$08,$00
	db $00,$28,$02,$00,$00,$00
	db $04,$28,$12,$12,$00,$00
	db $22,$22,$04,$12,$12,$00
	db $20,$20,$08,$00,$00,$00
	db $00,$28,$02,$00,$00,$00
	db $0A,$28,$13,$00,$00,$00
	db $20,$20,$0C,$02,$00,$00
	db $20,$20,$0C,$02,$00,$00
	db $22,$22,$06,$03,$12,$12
	db $20,$20,$06,$12,$12,$00
	db $2A,$2A,$00,$00,$00,$00
	db $2C,$2C,$00,$00,$00,$00
	db $20,$20,$06,$12,$12,$00
	db $20,$20,$06,$12,$12,$00
	db $22,$22,$08,$00,$00,$00
	db $20,$20,$08,$00,$00,$00
	db $2E,$2E,$08,$00,$00,$00
	db $4E,$4E,$60,$43,$43,$00
	db $4E,$4E,$64,$00,$00,$00
	db $62,$62,$64,$00,$00,$00
	db $62,$62,$64,$00,$00,$00

; Tile numbers for the graphics of Wendy O. Koopa and her decoys, indexed by
; their animation frame ($1602) times 6. Not all six bytes for each frame
; are actually used, though; the number of tiles per frame is instead
; determined by the table at $03D46D. Change both $03D1D7 to [1F 1E] and
; $03D1DD to [1E 1F] to fix a tilemap issue with Wendy's bow, in conjunction
; with the changes listed under $03CF7C.
WendyTiles:
	db $20,$20,$26,$26,$48,$00
	db $2E,$2E,$24,$24,$48,$00
	db $40,$28,$42,$00,$00,$00
	db $44,$28,$52,$52,$00,$00
	db $22,$22,$44,$52,$52,$00
	db $20,$20,$48,$00,$00,$00
	db $40,$28,$42,$00,$00,$00
	db $4A,$28,$53,$00,$00,$00
	db $20,$20,$4C,$1E,$1F,$00
	db $20,$20,$4C,$1F,$1E,$00
	db $22,$22,$44,$03,$52,$52
	db $20,$20,$44,$52,$52,$00
	db $2A,$2A,$00,$00,$00,$00
	db $2C,$2C,$00,$00,$00,$00
	db $20,$20,$46,$52,$52,$00
	db $20,$20,$46,$52,$52,$00
	db $22,$22,$48,$00,$00,$00
	db $20,$20,$48,$00,$00,$00
	db $2E,$2E,$48,$00,$00,$00
	db $4E,$4E,$66,$68,$68,$00
	db $4E,$4E,$6A,$00,$00,$00
	db $62,$62,$6A,$00,$00,$00
	db $62,$62,$6A,$00,$00,$00

; YXPPCCCT settings for the graphics of Lemmy Koopa and his decoys, indexed
; by their animation frame ($1602) times 6. Not all six bytes for each frame
; are actually used, though; the number of tiles per frame is instead
; determined by the table at $03D456.
LemmyProp:
	db $05,$45,$05,$45,$05,$00
	db $05,$45,$05,$45,$05,$00
	db $05,$05,$05,$00,$00,$00
	db $05,$05,$05,$45,$00,$00
	db $05,$45,$05,$05,$45,$00
	db $05,$45,$05,$00,$00,$00
	db $05,$05,$05,$00,$00,$00
	db $05,$05,$05,$00,$00,$00
	db $05,$45,$05,$05,$00,$00
	db $05,$45,$45,$45,$00,$00
	db $05,$45,$05,$05,$05,$45
	db $05,$45,$45,$05,$45,$00
	db $05,$45,$00,$00,$00,$00
	db $05,$45,$00,$00,$00,$00
	db $05,$45,$45,$05,$45,$00
	db $05,$45,$05,$05,$45,$00
	db $05,$45,$05,$00,$00,$00
	db $05,$45,$05,$00,$00,$00
	db $05,$45,$05,$00,$00,$00
	db $07,$47,$07,$07,$47,$00
	db $07,$47,$07,$00,$00,$00
	db $07,$47,$07,$00,$00,$00
	db $07,$47,$07,$00,$00,$00

; YXPPCCCT settings for the graphics of Wendy O. Koopa and her decoys,
; indexed by their animation frame ($1602) times 6. Not all six bytes for
; each frame are actually used, though; the number of tiles per frame is
; instead determined by the table at $03D46D.
WendyProp:
	db $09,$49,$09,$49,$09,$00
	db $09,$49,$09,$49,$09,$00
	db $09,$09,$09,$00,$00,$00
	db $09,$09,$09,$49,$00,$00
	db $09,$49,$09,$09,$49,$00
	db $09,$49,$09,$00,$00,$00
	db $09,$09,$09,$00,$00,$00
	db $09,$09,$09,$00,$00,$00
	db $09,$49,$09,$09,$09,$00
	db $09,$49,$49,$49,$49,$00
	db $09,$49,$09,$09,$09,$49
	db $09,$49,$49,$09,$49,$00
	db $09,$49,$00,$00,$00,$00
	db $09,$49,$00,$00,$00,$00
	db $09,$49,$49,$09,$49,$00
	db $09,$49,$09,$09,$49,$00
	db $09,$49,$09,$00,$00,$00
	db $09,$49,$09,$00,$00,$00
	db $09,$49,$09,$00,$00,$00
	db $05,$45,$05,$05,$45,$00
	db $05,$45,$05,$00,$00,$00
	db $05,$45,$05,$00,$00,$00
	db $05,$45,$05,$00,$00,$00

; Tile sizes (00 = 8x8, 02 = 16x16, 04 = unused) for the graphics of Lemmy
; Koopa and his decoys, indexed by their animation frame ($1602) times 6.
; Not all six bytes for each frame are actually used, though; the number of
; tiles per frame is instead determined by the table at $03D456.
LemmyTileSize:
	db $02,$02,$02,$02,$02,$04
	db $02,$02,$02,$02,$02,$04
	db $02,$02,$00,$04,$04,$04
	db $02,$02,$00,$00,$04,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$00,$04,$04,$04
	db $02,$02,$00,$04,$04,$04
	db $02,$02,$02,$00,$04,$04
	db $02,$02,$02,$00,$04,$04
	db $02,$02,$02,$00,$00,$00
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$04,$04,$04,$04
	db $02,$02,$04,$04,$04,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$04,$04,$04

; Tile sizes (00 = 8x8, 02 = 16x16) for the graphics of Wendy O. Koopa and
; her decoys, indexed by their animation frame ($1602) times 6. Not all six
; bytes for each frame are actually used, though; the number of tiles per
; frame is instead determined by the table at $03D46D.
WendyTileSize:
	db $02,$02,$02,$02,$02,$04
	db $02,$02,$02,$02,$02,$04
	db $02,$02,$00,$04,$04,$04
	db $02,$02,$00,$00,$04,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$00,$04,$04,$04
	db $02,$02,$00,$04,$04,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$00,$00,$00
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$04,$04,$04,$04
	db $02,$02,$04,$04,$04,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$00,$00,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$04,$04,$04
	db $02,$02,$02,$04,$04,$04

; Number of tiles (-1) used in each of the animation frames for Lemmy Koopa
; and his dummies, indexed by $1602.
NumberOfTilesToDrawForLemmy:
	db $04,$04,$02,$03,$04,$02,$02,$02
	db $03,$03,$05,$04,$01,$01,$04,$04
	db $02,$02,$02,$04,$02,$02,$02

; Number of tiles (-1) used in each of the animation frames for Wendy O.
; Koopa and her dummies, indexed by $1602.
NumberOfTilesToDrawForWendy:
	db $04,$04,$02,$03,$04,$02,$02,$02
	db $04,$04,$05,$04,$01,$01,$04,$04
	db $02,$02,$02,$04,$02,$02,$02

; Graphics routine for Lemmy Koopa, Wendy O. Koopa, and their dummies (who
; share the routine of their corresponding boss). $03D49A-$03D4DB is
; specifically used by Lemmy, while $03D4DF-$03D522 is used by Wendy.
GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	ASL
	ASL
	ADC.w !RAM_SMW_NorSpr_AnimationFrame,x
	ADC.w !RAM_SMW_NorSpr_AnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	CMP.b #$06
	BEQ.b WendyGFXRt
	PHX
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l NumberOfTilesToDrawForLemmy,x
else
	LDA.w NumberOfTilesToDrawForLemmy,x
endif
	TAX
CODE_03D4A3:
	PHX
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w LemmyXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w LemmyYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w LemmyTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w LemmyProp,x
	ORA.b #$10
	STA.w SMW_OAMBuffer[$40].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w LemmyTileSize,x
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	INY
	INY
	INY
	INY
	PLX
	DEX
	BPL.b CODE_03D4A3
CODE_03D4DD:
	PLX
	RTS

WendyGFXRt:
	PHX
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l NumberOfTilesToDrawForWendy,x
else
	LDA.w NumberOfTilesToDrawForWendy,x
endif
	TAX
CODE_03D4E8:
	PHX
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w WendyXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w WendyYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w WendyTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w WendyProp,x
	ORA.b #$10
	STA.w SMW_OAMBuffer[$40].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w WendyTileSize,x
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	INY
	INY
	INY
	INY
	PLX
	DEX
	BPL.b CODE_03D4E8
	BRA.b CODE_03D4DD
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckIfBabyYoshiCanEatNormalSprite(Address)
namespace SMW_CheckIfBabyYoshiCanEatNormalSprite
%InsertMacroAtXPosition(<Address>)

BabyYoshiCanEatSprite:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

ChangingItemSpriteType:
	db !Define_SMW_SpriteID_NorSpr074_Mushroom
	db !Define_SMW_SpriteID_NorSpr075_FireFlower
	db !Define_SMW_SpriteID_NorSpr077_Feather
	db !Define_SMW_SpriteID_NorSpr076_Star

Sub:
	LDY.w !RAM_SMW_NorSpr02D_BabyYoshi_SlotOfSpriteBeingEaten,x
	LDA.b #!Define_SMW_NorSprStatus00_EmptySlot
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_Sound1DF9_YoshiGulp	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	; Change to [$80,$1E] to make Baby Yoshi instantly grow when eating
	; something, regardless if it's a powerup or not. Change to [$80,$5D] to
	; make Baby Yoshi never grow instantly when eating something, even if it's
	; a powerup. It will count as one sprite eaten instead. If changing this,
	; you also need to apply the hex edit at $01A295 for it to work properly.
	LDA.w !RAM_SMW_NorSpr02D_BabyYoshi_SlotOfSpriteBeingEaten,y
	BNE.b CODE_03C09B
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr081_ChangingItem
	BNE.b CODE_03C054
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w ChangingItemSpriteType,y
CODE_03C054:
	CMP.b #!Define_SMW_SpriteID_NorSpr074_Mushroom
	BCC.b CODE_03C09B
	CMP.b #!Define_SMW_SpriteID_NorSpr078_1upMushroom
	BCS.b CODE_03C09B
ADDR_03C05C:
	STZ.w !RAM_SMW_Yoshi_SwallowTimer
	STZ.w !RAM_SMW_Yoshi_YoshiHasWings	; No Yoshi wing ability
	LDA.b #!Define_SMW_SpriteID_NorSpr035_Yoshi
	STA.w !RAM_SMW_NorSpr_SpriteID,x
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_Sound1DFC_MountYoshi	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SBC.b #$10
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,x
	PHA
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLA
	AND.b #$FE
	STA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,x
	LDA.b #$0C
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	DEC.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	LDA.b #$40
	STA.w !RAM_SMW_GrowingYoshiTimer
	RTS

CODE_03C09B:
	INC.w !RAM_SMW_NorSpr02D_BabyYoshi_SpritesEatenCounter,x
	LDA.w !RAM_SMW_NorSpr02D_BabyYoshi_SpritesEatenCounter,x
	CMP.b #$05
	BNE.b CODE_03C0A7
	BRA.b ADDR_03C05C

CODE_03C0A7:
	JSL.l SMW_GiveCoins_OneCoin
	LDA.b #$01
	JSL.l SMW_GivePoints_Main
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr030_ThrowingDryBones_Status08(Address)
namespace SMW_NorSpr030_ThrowingDryBones_Status08
%InsertMacroAtXPosition(<Address>)

DryBonesAndBonyBeetleGFXRt:
	PHB
	PHK
	PLB
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	PHA
	LDY.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BEQ.b CODE_03C3A5
	CPY.b #$05
	BCC.b CODE_03C3A5
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_03C3A5:
	JSR.w CODE_03C3DA
	PLA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	PLB
	RTL

CODE_03C3AE:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	RTS

; Dry Bones x-displacement table (Bone, Head, Body)
DryBonesTileXDisp:
	db $00,$08,$00,$00,$F8,$00,$00,$04
	db $00,$00,$FC,$00

; Dry Bones palette/gfx page (Facing right) (Bone, Head, Body)
DryBonesGfxProp:
	db $43,$43,$43,$03,$03,$03

; Dry Bones y-displacement table (Bone, Head, Body)
DryBonesTileYDisp:
	db $F4,$F0,$00,$F4,$F1,$00,$F4,$F0
	db $00

; Dry Bones tile table
DryBonesTiles:
	db $00,$64,$66,$00,$64,$68,$82,$64
	db $E6

DATA_03C3D7:
	db $00,$00,$FF

CODE_03C3DA:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr031_BonyBeetle
	BEQ.b CODE_03C3AE
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	ASL
	ADC.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	PHA
	ASL
	ADC.w !RAM_SMW_NorSpr_AnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PLX
	LDA.w DATA_03C3D7,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDX.b #$02
CODE_03C404:
	PHX
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	BEQ.b CODE_03C414
	TXA
	CLC
	ADC.b #$06
	TAX
CODE_03C414:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DryBonesTileXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLX
	LDA.w DryBonesGfxProp,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
	PHA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w DryBonesTileYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w DryBonesTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	INY
	INY
	INY
	INY
	DEX
	CPX.b !RAM_SMW_Misc_ScratchRAM04
	BNE.b CODE_03C404
	PLX
	LDY.b #$02
	TYA
	JSL.l SMW_FinishOAMWrite_Main
	RTS

; Dry Bones's bone-throwing subroutine. It can be JSL'd to. $03C462 - [06]
; Extended sprite number to throw. $03C46A - [10] Y offset of the bone
; relative to the Dry Bones's position. $03C486 - [18] X speed of the bone
; when the Dry Bones is facing right. $03C48A - [E8] X speed of the bone
; when the Dry Bones is facing left.
SpawnDryBonesBone:
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b Return03C460
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_03C458:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_03C461
	DEY
	BPL.b CODE_03C458
Return03C460:
	RTL				; / Return if no free slots

CODE_03C461:
	LDA.b #!Define_SMW_SpriteID_ExtSpr06_ThrownBone	; \ Extended sprite = Bone
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b #$10
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	LSR
	LDA.b #$18
	BCC.b CODE_03C48B
	LDA.b #$E8
CODE_03C48B:
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
	RTL
namespace off
endmacro

macro ROUTINE_RT04_SMW_NorSpr035_Yoshi_Status08(Address)
namespace SMW_NorSpr035_Yoshi_Status08
%InsertMacroAtXPosition(<Address>)

YoshiThroatXDisp:
	db $0C,$0C,$0C,$0C,$0C,$0C,$0D,$0D
	db $0D,$0D,$FC,$FC,$FC,$FC,$FC,$FC
	db $FB,$FB,$FB,$FB,$0C,$0C,$0C,$0C
	db $0C,$0C,$0D,$0D,$0D,$0D,$FC,$FC
	db $FC,$FC,$FC,$FC,$FB,$FB,$FB,$FB

YoshiThroatYDisp:
	db $0E,$0E,$0E,$0D,$0D,$0D,$0C,$0C
	db $0B,$0B,$0E,$0E,$0E,$0D,$0D,$0D
	db $0C,$0C,$0B,$0B,$12,$12,$12,$11
	db $11,$11,$10,$10,$0F,$0F,$12,$12
	db $12,$11,$11,$11,$10,$10,$0F,$0F
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NormalSpriteBooGFXRt(Address)
namespace SMW_NormalSpriteBooGFXRt
%InsertMacroAtXPosition(<Address>)

; X position of big boo's eyes in the normal frame
BigBooXDisp:
	db $08,$08,$20,$00,$00,$00,$00,$10
	db $10,$10,$10,$20,$20,$20,$20,$30
	db $30,$30,$30,$FD,$0C,$0C,$27,$00
	db $00,$00,$00,$10,$10,$10,$10,$1F
	db $20,$20,$1F,$2E,$2E,$2C,$2C,$FB
	; X position of big boo's eyes in turning frame 2
	db $12,$12,$30,$00,$00,$00,$00,$10
	db $10,$10,$10,$1F,$20,$20,$1F,$2E
	db $2E,$2E,$2E,$F8,$11,$FF,$08,$08
	; X position of the 16 body tiles of Big boo in the hiding frame
	db $00,$00,$00,$00,$10,$10,$10,$10
	db $20,$20,$20,$20,$30,$30,$30,$30

; Y position of Big boo's eyes in normal, turning 1 and turning 2 frames
BigBooYDisp:
	db $12,$22,$18,$00,$10,$20,$30,$00
	db $10,$20,$30,$00,$10,$20,$30,$00
	db $10,$20,$30,$18,$16,$16,$12,$22
	; Y position of the 16 tiles of big boo's body in hiding frame
	db $00,$10,$20,$30,$00,$10,$20,$30
	db $00,$10,$20,$30,$00,$10,$20,$30

; Sprite Tilemap: Big Boo
BigBooTiles:
	db $C0,$E0,$E8,$80,$A0,$A0,$80,$82
	db $A2,$A2,$82,$84,$A4,$C4,$E4,$86
	db $A6,$C6,$E6,$E8,$C0,$E0,$E8,$80
	db $A0,$A0,$80,$82,$A2,$A2,$82,$84
	db $A4,$C4,$E4,$86,$A6,$C6,$E6,$E8
	db $C0,$E0,$E8,$80,$A0,$A0,$80,$82
	db $A2,$A2,$82,$84,$A4,$A4,$84,$86
	db $A6,$A6,$86,$E8,$E8,$E8,$C2,$E2
	db $80,$A0,$A0,$80,$82,$A2,$A2,$82
	db $84,$A4,$C4,$E4,$86,$A6,$C6,$E6

; The flip of each tile in the tilemap of Big Boo (00 is no flip, 40 is
; horizontal flip, 80 is vertical flip, C0 is horizontal + vertical flip)
BigBooProp:
	db $00,$00,$40,$00,$00,$80,$80,$00
	db $00,$80,$80,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$40,$00
	db $00,$80,$80,$00,$00,$80,$80,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$40,$00,$00,$80,$80,$00
	db $00,$80,$80,$00,$00,$80,$80,$00
	db $00,$80,$80,$00,$00,$40,$00,$00
	db $00,$00,$80,$80,$00,$00,$80,$80
	db $00,$00,$00,$00,$00,$00,$00,$00

Main:
;$038398
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	;\ if sprite isn't #37 (Boo),
	CMP.b #!Define_SMW_SpriteID_NorSpr037_Boo	; |
	BNE.b CODE_0383C2		;/ branch
	LDA.b #$00
	LDY.b !RAM_SMW_NorSprXXX_NonBossBoos_FollowingMarioFlag,x	;\ if sprite state == #$00 (non-existant),
	BEQ.b CODE_0383BA		;/ branch
	LDA.b #$06
	LDY.w !RAM_SMW_NorSprXXX_NonBossBoos_IdleAnimationTimer,x	;\ if ? == #$00,
	BEQ.b CODE_0383BA		;/ branch
	TYA
	AND.b #$04
	LSR
	LSR
	ADC.b #$02
CODE_0383BA:
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x	; set graphics frame to use
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	RTS

CODE_0383C2:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x	;\ $06 = graphics frame to use
	STA.b !RAM_SMW_Misc_ScratchRAM06	;/
	ASL				;\ $02 = graphics frame multiplied by total number of tiles to draw (0x14)
	ASL				; |
	STA.b !RAM_SMW_Misc_ScratchRAM03	; |
	ASL				; |
	ASL				; |
	ADC.b !RAM_SMW_Misc_ScratchRAM03	; |
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	;\ $04 = direction
	STA.b !RAM_SMW_Misc_ScratchRAM04	;/
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x	;\ $05 = tile properties
	STA.b !RAM_SMW_Misc_ScratchRAM05	;/
	LDX.b #$00			; set up loop
CODE_0383E0:
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; load tile pointer
	LDA.w BigBooTiles,x		;\ store tilemap
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM04	;\ useless code?
	LSR				;/
	LDA.w BigBooProp,x		;\ use tile properties to determine flip
	ORA.b !RAM_SMW_Misc_ScratchRAM05	; |
	BCS.b CODE_0383F5		;/
	EOR.b #$40			; flip tile
CODE_0383F5:
	ORA.b !RAM_SMW_Sprites_TilePriority	; add in level properties
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.w BigBooXDisp,x		; x offset of tile
	BCS.b CODE_038405		;\ if carry flag set from earlier, branch
	EOR.b #$FF			; | else, invert offset
	INC				; |
	CLC				; |
	ADC.b #$28			;/ and move tile to match up with hitbox
CODE_038405:
	CLC				;\
	ADC.b !RAM_SMW_Misc_ScratchRAM00	;/ add sprite x position
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLX				;\ get original loop counter back into X register,
	PHX				;/ while still keeping it preserved in the stack
	LDA.b !RAM_SMW_Misc_ScratchRAM06	;\ if graphics frame to use = hiding,
	CMP.b #$03			; |
	BCC.b CODE_038418		;/ branch
	TXA				;\ else, increase tile index by 0x14
	CLC				; |
	ADC.b #$14			; |
	TAX				;/
CODE_038418:
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\ store tile y position
	CLC				; |
	ADC.w BigBooYDisp,x		; |
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	PLX
	INY				;\ as we wrote a 16x16 tile to OAM, we need to increase the sprite tilemap pointer by 4
	INY				; |
	INY				; |
	INY				;/
	INC.b !RAM_SMW_Misc_ScratchRAM02	; increase tile pointer
	INX				; increase loop counter
	CPX.b #$14			;\ if still tiles left to draw,
	BNE.b CODE_0383E0		;/ go back to start of loop
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	CMP.b #$03
	BNE.b CODE_03844B
	LDA.w !RAM_SMW_NorSprXXX_NonBossBoos_IdleAnimationTimer,x	;\ this will always branch, as $1558,x never is set in the sprite
	BEQ.b CODE_03844B		;/
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
	ADC.b #$05
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
CODE_03844B:
	LDA.b #$13			; 0x14 tiles written
	LDY.b #$02			; the tiles were 16x16
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr051_Ninji_Status08(Address)
namespace SMW_NorSpr051_Ninji_Status08
%InsertMacroAtXPosition(<Address>)

; Ninji's vertical speed when jumping
YSpeed:
	db $D0,$C0,$B0,$D0

Bank03:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main	; Draw sprite uing the routine for sprites <= 53
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Return if sprites locked
	BNE.b Return03C38F
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X	; \ Always face mario
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	JSR.w SMW_SubOffscreen_Bank03_Entry1	; Only process while onscreen
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main	; Interact with mario
	JSL.l SMW_HandleNormalSpriteGravity_Main	; Update position based on speed values
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x				;\ Glitch: Set AND.b #$04 to AND.b #$0C to fix the bug where Ninjis will get stuck inside ceilings.
	AND.b #$04								;|
	BEQ.b CODE_03C385							;/
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.w !RAM_SMW_NorSpr051_Ninji_WaitBeforeNextJump,x
	BNE.b CODE_03C385
	LDA.b #$60
	STA.w !RAM_SMW_NorSpr051_Ninji_WaitBeforeNextJump,x
	INC.b !RAM_SMW_NorSpr051_Ninji_JumpCounter,x
	LDA.b !RAM_SMW_NorSpr051_Ninji_JumpCounter,x
	AND.b #$03
	TAY
	LDA.w YSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_03C385:
	LDA.b #$00
	LDY.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_03C38C
	INC
CODE_03C38C:
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
Return03C38F:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr054_ClimbingNetDoor_Status08(Address)
namespace SMW_NorSpr054_ClimbingNetDoor_Status08
%InsertMacroAtXPosition(<Address>)

; This generates a Map16 tile at the position of the sprite currently being
; processed plus 8 pixels left and 8 pixels down. It can be accessed with a
; JSL, and A should be set to the value of $9C you wish to use.
UpdateClimbingNetDoorTiles:
	STA.b !RAM_SMW_Blocks_Map16ToGenerate	; $9C = tile to generate
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $9A = Sprite X position + #$08
	SEC				; | for block creation
	SBC.b #$08
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $98 = Sprite Y position + #$08
	CLC				; | for block creation
	ADC.b #$08
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Blocks_YPosHi
	JSL.l SMW_GenerateTile_Main	; Generate the tile
	RTL
namespace off
endmacro

macro ROUTINE_RT03_SMW_NorSprXXX_LineGuidedSprites_Status08(Address)
namespace SMW_NorSprXXX_LineGuidedSprites_Status08
%InsertMacroAtXPosition(<Address>)

; Chainsaw's Motor Tilemap
MotorTiles:
	db $E0,$C2,$C0,$C2

YDisp:
	db $F2,$0E

Prop:
	db $33,$B3

ChainsawGFXRt:
.Main:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w .Sub
	PLB
	RTL

.Sub:
	JSR.w SMW_GetDrawInfo_Bank03
	PHX
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	SEC
	SBC.b #!Define_SMW_SpriteID_NorSpr065_Chainsaw
	TAX
	LDA.w YDisp,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w Prop,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	PLX
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$41].XDisp,y
	STA.w SMW_OAMBuffer[$42].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$41].YDisp,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	STA.w SMW_OAMBuffer[$42].YDisp,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$03
	PHX
	TAX
	LDA.w MotorTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDA.b #$AE
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b #$8E
	STA.w SMW_OAMBuffer[$42].Tile,y
	LDA.b #$37
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w SMW_OAMBuffer[$41].Prop,y
	STA.w SMW_OAMBuffer[$42].Prop,y
	LDY.b #$02
	TYA
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr06F_DinoTorch_Status08(Address)
namespace SMW_NorSpr06F_DinoTorch_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x				;\ Optimization: You know, SolidSpriteBlock_Main is in bank 01. Sprite 6D's main pointer could have been set to directly point there.
	CMP.b #!Define_SMW_SpriteID_NorSpr06D_InvisibleBlock		;| That would have rendered this bit of code unnecessary.
	BNE.b NotInvisibleBlock						;|
	JSL.l SMW_SolidSpriteBlock_Main					;|
	RTL								;/

NotInvisibleBlock:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return039CA3
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b Return039CA3
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	JSL.l SMW_HandleNormalSpriteGravity_Main
	LDA.b !RAM_SMW_NorSpr06F_DinoTorch_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

DinoTorchPtrs:
	dw CODE_039CA8
	dw CODE_039D41
	dw CODE_039D41
	dw CODE_039C74

DATA_039C6E:
	db $00,$FE,$02

DATA_039C71:
	db $00,$FF,$00

CODE_039C74:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_039C89
	STZ.b !RAM_SMW_NorSpr06F_DinoTorch_CurrentState,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_039C89
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_039C89:
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$03
	TAY
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w DATA_039C6E,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.w DATA_039C71,y
	STA.w !RAM_SMW_NorSpr_XPosHi,x
Return039CA3:
	RTS

; Dino Rhino X-Speed.
XSpeed:
	db $08,$F8,$10,$F0

CODE_039CA8:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_039C89
	LDA.w !RAM_SMW_NorSpr06F_DinoTorch_BreathFireTimer,x
	BNE.b CODE_039CC8
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr06E_DinoRhino
	BEQ.b CODE_039CC8
	LDA.b #$FF			; \ Set fire breathing timer
	STA.w !RAM_SMW_NorSpr06F_DinoTorch_BreathFireTimer,x
	JSL.l SMW_GetRand_Main
	AND.b #$01
	INC
	STA.b !RAM_SMW_NorSpr06F_DinoTorch_CurrentState,x
CODE_039CC8:
	TXA
	ASL
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Counter_LocalFrames
	AND.b #$3F
	BNE.b CODE_039CDA
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X	; \ If not facing mario, change directions
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_039CDA:
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x	; \ Set x speed for rhino based on direction and sprite number
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr06E_DinoRhino
	BEQ.b CODE_039CE9
	INY
	INY
CODE_039CE9:
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w DinoSetGfxFrame
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b Return039D00
	LDA.b #$C0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$03
	STA.b !RAM_SMW_NorSpr06F_DinoTorch_CurrentState,x
Return039D00:
	RTS

DinoFlameTable:
	db $41,$42,$42,$32,$22,$12,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$12
	db $22,$32,$42,$42,$42,$42,$41,$41
	db $41,$43,$43,$33,$23,$13,$03,$03
	db $03,$03,$03,$03,$03,$03,$03,$03
	db $03,$03,$03,$03,$03,$03,$03,$13
	db $23,$33,$43,$43,$43,$43,$41,$41

CODE_039D41:
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	LDA.w !RAM_SMW_NorSpr06F_DinoTorch_BreathFireTimer,x
	BNE.b DinoFlameTimerSet
	STZ.b !RAM_SMW_NorSpr06F_DinoTorch_CurrentState,x
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr06F_DinoTorch_BreathFireTimer,x
	LDA.b #$00
DinoFlameTimerSet:
	CMP.b #$C0
	BNE.b CODE_039D5A
	LDY.b #!Define_SMW_Sound1DFC_FireSpit	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh3
CODE_039D5A:
	LSR
	LSR
	LSR
	LDY.b !RAM_SMW_NorSpr06F_DinoTorch_CurrentState,x
	CPY.b #$02
	; Change to 80 to make Dino-Torches only breathe fire horizontally
	BNE.b CODE_039D66
	CLC
	ADC.b #$20
CODE_039D66:
	TAY
	LDA.w DinoFlameTable,y
	PHA
	AND.b #$0F
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	PLA
	LSR
	LSR
	LSR
	LSR
	STA.w !RAM_SMW_NorSpr06F_DinoTorch_FireLength,x
	BNE.b Return039D9D
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr06E_DinoRhino
	BEQ.b Return039D9D
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b Return039D9D
	JSR.w DinoFlameClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return039D9D
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario has star
	; Change to 80 and Dino-Torch's flame will have no effect on Mario.
	BNE.b Return039D9D
	JSL.l SMW_DamagePlayer_Hurt
Return039D9D:
	RTS

; Dino Torch's Flame Clipping tables. - $039D9E: Clipping X offset (low
; byte). - $039DA2: Clipping X offset (high byte). - $039DA6: Clipping
; Width. - $039DAA: Clipping Y offset (low byte). - $039DAE: Clipping Y
; offset (high byte). - $039DB2: Clipping Height. Each table has 4 bytes,
; and it uses the following format: - 1st byte: Horizontal Flame Facing Left
; - 2nd byte: Vertical Flame Facing Left - 3rd byte: Horizontal Flame Facing
; Right - 4th byte: Vertical Flame Facing Right
DinoFlame1:
	db $DC,$02,$10,$02

DinoFlame2:
	db $FF,$00,$00,$00

DinoFlame3:
	db $24,$0C,$24,$0C

DinoFlame4:
	db $02,$DC,$02,$DC

DinoFlame5:
	db $00,$FF,$00,$FF

DinoFlame6:
	db $0C,$24,$0C,$24

DinoFlameClipping:
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	SEC
	SBC.b #$02
	TAY
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	BNE.b CODE_039DC4
	INY
	INY
CODE_039DC4:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w DinoFlame1,y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.w DinoFlame2,y
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w DinoFlame3,y
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.w DinoFlame4,y
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.w DinoFlame5,y
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.w DinoFlame6,y
	STA.b !RAM_SMW_Misc_ScratchRAM07
	RTS

DinoSetGfxFrame:
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	AND.b #$08
	LSR
	LSR
	LSR
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

; Dino-Torch flame tile horiz. displacement table (horizontal flame)
DinoTorchXDisp:
	db $D8,$E0,$EC,$F8,$00,$FF,$FF,$FF
	db $FF,$00

; Dino-Torch flame tile vert. displacement table (horizontal flame)
DinoTorchYDisp:
	db $00,$00,$00,$00,$00,$D8,$E0,$EC
	db $F8,$00

; Dino-Torch flame tile table (2 animation frames, each 4 bytes w/an unused
; byte)
DinoFlameTiles:
	db $80,$82,$84,$86,$00,$88,$8A,$8C
	db $8E,$00

; Dino-Torch YXPPCCCT bytes.
DinoTorchProp:
	db $09,$05,$05,$05,$0F

; Dino-Torch tile table (4 animation frames, each 1 byte)
DinoTorchTiles:
	db $EA,$AA,$C4,$C6

; Dino-Rhino tile horizontal displacement table
DinoRhinoXDisp:
	db $F8,$08,$F8,$08,$08,$F8,$08,$F8

; Dino-Rhino tiles' palette/gfx page/priority/flip left
DinoRhinoProp:
	db $2F,$2F,$2F,$2F,$6F,$6F,$6F,$6F

; Dino-Rhino tile vertical displacement table
DinoRhinoYDisp:
	db $F0,$F0,$00,$00

; Dino-Rhino tile table (4 animation frames, each 4 bytes)
DinoRhinoTiles:
	db $C0,$C2,$E4,$E6,$C0,$C2,$E0,$E2
	db $C8,$CA,$E8,$E2,$CC,$CE,$EC,$EE

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr06F_DinoTorch
	BEQ.b CODE_039EA9
	PHX
	LDX.b #$03
CODE_039E5F:
	STX.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b #$01
	BCS.b CODE_039E6C
	TXA
	CLC
	ADC.b #$04
	TAX
CODE_039E6C:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DinoRhinoProp,x
else
	LDA.w DinoRhinoProp,x
endif
	STA.w SMW_OAMBuffer[$40].Prop,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DinoRhinoXDisp,x
else
	LDA.w DinoRhinoXDisp,x
endif
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CMP.b #$01
	LDX.b !RAM_SMW_Misc_ScratchRAM0F
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DinoRhinoYDisp,x
else
	LDA.w DinoRhinoYDisp,x
endif
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DinoRhinoTiles,x
else
	LDA.w DinoRhinoTiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
	INY
	INY
	INY
	INY
	LDX.b !RAM_SMW_Misc_ScratchRAM0F
	DEX
	BPL.b CODE_039E5F
	PLX
	LDA.b #$03
	LDY.b #$02
	JSL.l SMW_FinishOAMWrite_Main
	RTS

CODE_039EA9:
	LDA.w !RAM_SMW_NorSpr06F_DinoTorch_FireLength,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	PHX
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$02
	ASL
	ASL
	ASL
	ASL
	ASL
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	CPX.b #$03
	BEQ.b CODE_039EC4
	ASL
CODE_039EC4:
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDX.b #$04
CODE_039EC8:
	STX.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CMP.b #$03
	BNE.b CODE_039ED5
	TXA
	CLC
	ADC.b #$05
	TAX
CODE_039ED5:
	PHX
	LDA.w DinoTorchXDisp,x
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b CODE_039EE0
	EOR.b #$FF
	INC
CODE_039EE0:
	PLX
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w DinoTorchYDisp,x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	CMP.b #$04
	BNE.b CODE_039EFD
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w DinoTorchTiles,x
	BRA.b CODE_039F00

CODE_039EFD:
	LDA.w DinoFlameTiles,x
CODE_039F00:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$00
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b CODE_039F0B
	ORA.b #$40
CODE_039F0B:
	LDX.b !RAM_SMW_Misc_ScratchRAM06
	CPX.b #$04
	BEQ.b CODE_039F13
	EOR.b !RAM_SMW_Misc_ScratchRAM05
CODE_039F13:
	ORA.w DinoTorchProp,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	CPX.b !RAM_SMW_Misc_ScratchRAM03
	BPL.b CODE_039EC8
	PLX
	LDY.w !RAM_SMW_NorSpr06F_DinoTorch_FireLength,x
	LDA.w DinoTilesWritten,y
	LDY.b #$02
	JSL.l SMW_FinishOAMWrite_Main
	RTS

DinoTilesWritten:
	db $04,$03,$02,$01,$00

Return039F37:
	RTS ; unused
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr07A_Fireworks_Status08(Address)
namespace SMW_NorSpr07A_Fireworks_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	LDA.b !RAM_SMW_NorSpr07A_Fireworks_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

FireworkPtrs:
	dw InitialFire
	dw ShootUp
	dw Explode
	dw FadeAway

YSpeed:
	db $E4,$E6,$E4,$E2

InitialFire:
	LDY.w !RAM_SMW_NorSpr07A_Fireworks_CurrentType,x
	LDA.w YSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #!Define_SMW_Sound1DFC_YoshiStompsEnemy	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr07A_Fireworks_WaitBeforeWhistleSound,x
	INC.b !RAM_SMW_NorSpr07A_Fireworks_CurrentState,x
	RTS

DATA_03C83D:
	db $14,$0C,$10,$15

DATA_03C841:
	db $08,$10,$0C,$05

ShootUp:
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_WaitBeforeWhistleSound,x
	CMP.b #$01
	BNE.b CODE_03C85B
	LDY.w !RAM_SMW_NorSpr07A_Fireworks_CurrentType,x
	LDA.w FireworkSounds_WhistleCh1,y	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.w FireworkSounds_WhistleCh3,y	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_03C85B:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	INC.b !RAM_SMW_NorSpr07A_Fireworks_DecelerateTimer,x
	LDA.b !RAM_SMW_NorSpr07A_Fireworks_DecelerateTimer,x
	AND.b #$03
	BNE.b CODE_03C869
	INC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_03C869:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$FC
	BNE.b CODE_03C885
	INC.b !RAM_SMW_NorSpr07A_Fireworks_CurrentState,x
	LDY.w !RAM_SMW_NorSpr07A_Fireworks_CurrentType,x
	LDA.w DATA_03C83D,y
	STA.w !RAM_SMW_NorSpr07A_Fireworks_ExpandingSpeed,x
	LDA.w DATA_03C841,y
	STA.w !RAM_SMW_NorSpr07A_Fireworks_WaitBeforeBangSound,x
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr07A_Fireworks_ColorFlashIndex
CODE_03C885:
	JSR.w CODE_03C96D
	RTS

DATA_03C889:
	db $FF,$80,$C0,$FF

Explode:
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_WaitBeforeBangSound,x
	DEC
	BNE.b CODE_03C8A2
	LDY.w !RAM_SMW_NorSpr07A_Fireworks_CurrentType,x
	LDA.w FireworkSounds_BangCh1,y	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.w FireworkSounds_BangCh3,y	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_03C8A2:
	JSR.w CODE_03C8B1
	LDA.b !RAM_SMW_NorSpr07A_Fireworks_CurrentState,x
	CMP.b #$02
	BNE.b CODE_03C8AE
	JSR.w CODE_03C8B1
CODE_03C8AE:
	JMP.w CODE_03C9E9

CODE_03C8B1:
	LDY.w !RAM_SMW_NorSpr07A_Fireworks_CurrentType,x
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_ExplosionSize,x
	CLC
	ADC.w !RAM_SMW_NorSpr07A_Fireworks_ExpandingSpeed,x
	STA.w !RAM_SMW_NorSpr07A_Fireworks_ExplosionSize,x
	BCS.b ADDR_03C8DB
	CMP.w DATA_03C889,y
	BCS.b CODE_03C8E0
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_ExpandingSpeed,x
	CMP.b #$02
	BCC.b CODE_03C8D4
	SEC
	SBC.b #$01
	STA.w !RAM_SMW_NorSpr07A_Fireworks_ExpandingSpeed,x
	BCS.b CODE_03C8E4
CODE_03C8D4:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr07A_Fireworks_ExpandingSpeed,x
	BRA.b CODE_03C8E4

ADDR_03C8DB:
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr07A_Fireworks_ExplosionSize,x
CODE_03C8E0:
	INC.b !RAM_SMW_NorSpr07A_Fireworks_CurrentState,x
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_03C8E4:
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_ExpandingSpeed,x
	AND.b #$FF
	TAY
	LDA.w DATA_03C8F1,y
	STA.w !RAM_SMW_NorSpr07A_Fireworks_ParticleAnimationSet,x
	RTS

DATA_03C8F1:
	db $06,$05,$04,$03,$03,$03,$03,$02
	db $02,$02,$02,$02,$02,$02,$01,$01
	db $01,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $03,$03,$03,$03,$03,$03,$03,$03
	db $03,$03,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02

FadeAway:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	BNE.b CODE_03C949
	INC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_03C949:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	LDA.b #$07
	LDY.b !RAM_SMW_NorSpr_YSpeed,x
	CPY.b #$08
	BNE.b CODE_03C958
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
CODE_03C958:
	CPY.b #$03
	BCC.b CODE_03C962
	INC
	CPY.b #$05
	BCC.b CODE_03C962
	INC
CODE_03C962:
	STA.w !RAM_SMW_NorSpr07A_Fireworks_ParticleAnimationSet,x
	JSR.w CODE_03C9E9
	RTS

DATA_03C969:
	db $EC,$8E,$EC,$EC

CODE_03C96D:
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b Return03C9B8
	JSR.w SMW_GetDrawInfo_Bank03
	LDY.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_CurrentType,x
	TAX
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	LSR
	AND.b #$02
	LSR
	ADC.w DATA_03C969,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDA.b !RAM_SMW_Counter_GlobalFrames
	ASL
	AND.b #$0E
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Counter_GlobalFrames
	ASL
	ASL
	ASL
	ASL
	AND.b #$40
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	ORA.b #$31
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
Return03C9B8:
	RTS

; Fireworks Tilemap
DATA_03C9B9:
	db $36,$35,$C7,$34,$34,$34,$34,$24
	db $03,$03,$36,$35,$C7,$34,$34,$24
	db $24,$24,$24,$03,$36,$35,$C7,$34
	db $34,$34,$24,$24,$03,$24,$36,$35
	db $C7,$34,$24,$24,$24,$24,$24,$03

DATA_03C9E1:
	db $00,$01,$01,$00,$00,$FF,$FF,$00

CODE_03C9E9:
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_ExplosionSize,x
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_ParticleAnimationSet,x
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_CurrentType,x
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	PHX
	LDX.b #$3F
	LDY.b #$00
CODE_03CA0D:
	STX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	CMP.b #$03
	LDA.w DATA_03C626,x
	BCC.b CODE_03CA1B
	LDA.w DATA_03C6CE,x
CODE_03CA1B:
	SEC
	SBC.b #$40
	STA.b !RAM_SMW_Misc_ScratchRAM00
	PHY
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	CMP.b #$03
	LDA.w DATA_03C67A,x
	BCC.b CODE_03CA2D
	LDA.w DATA_03C722,x
CODE_03CA2D:
	SEC
	SBC.b #$50
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_03CA39
	EOR.b #$FF
	INC
CODE_03CA39:
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/03CA39.asm"
namespace SMW_NorSpr07A_Fireworks_Status08
else
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_03CA4F
	EOR.b #$FF
	INC
CODE_03CA4F:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BPL.b CODE_03CA58
	EOR.b #$FF
	INC
CODE_03CA58:
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
endif
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	BPL.b CODE_03CA6E
	EOR.b #$FF
	INC
CODE_03CA6E:
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	CMP.b #$06
	BCC.b CODE_03CA82
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	LSR
	LSR
	AND.b #$07
	TAY
CODE_03CA82:
	LDA.w DATA_03C9E1,y
	PLY
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM08
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM09
	STA.w SMW_OAMBuffer[$00].YDisp,y
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	AND.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	ADC.b !RAM_SMW_Misc_ScratchRAM07
	TAX
	LDA.w DATA_03C9B9,x
	STA.w SMW_OAMBuffer[$00].Tile,y
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	LSR
	NOP #2
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM0A
	CPX.b #$03
	BEQ.b CODE_03CABD
	EOR.b !RAM_SMW_Misc_ScratchRAM04
CODE_03CABD:
	AND.b #$0E
	ORA.b #$31
	STA.w SMW_OAMBuffer[$00].Prop,y
	PLX
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	BMI.b CODE_03CADA
	JMP.w CODE_03CA0D

CODE_03CADA:
	LDX.b #$53
CODE_03CADC:
	STX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	CMP.b #$03
	LDA.w DATA_03C626,x
	BCC.b CODE_03CAEA
	LDA.w DATA_03C6CE,x
CODE_03CAEA:
	SEC
	SBC.b #$40
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	CMP.b #$03
	LDA.w DATA_03C67A,x
	BCC.b CODE_03CAFB
	LDA.w DATA_03C722,x
CODE_03CAFB:
	SEC
	SBC.b #$50
	STA.b !RAM_SMW_Misc_ScratchRAM01
	PHY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_03CB08
	EOR.b #$FF
	INC
CODE_03CB08:
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/03CB08.asm"
namespace SMW_NorSpr07A_Fireworks_Status08
else
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_03CB1E
	EOR.b #$FF
	INC
CODE_03CB1E:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BPL.b CODE_03CB27
	EOR.b #$FF
	INC
CODE_03CB27:
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
endif
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	BPL.b CODE_03CB3D
	EOR.b #$FF
	INC
CODE_03CB3D:
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	CMP.b #$06
	BCC.b CODE_03CB51
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	LSR
	LSR
	AND.b #$07
	TAY
CODE_03CB51:
	LDA.w DATA_03C9E1,y
	PLY
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM08
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM09
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	AND.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	ADC.b !RAM_SMW_Misc_ScratchRAM07
	TAX
	LDA.w DATA_03C9B9,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	LSR
	NOP #2
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM0A
	CPX.b #$03
	BEQ.b CODE_03CB8C
	EOR.b !RAM_SMW_Misc_ScratchRAM04
CODE_03CB8C:
	AND.b #$0E
	ORA.b #$31
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	CPX.b #$3F
	BEQ.b CODE_03CBAB
	JMP.w CODE_03CADC

CODE_03CBAB:
	PLX
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr07A_Fireworks_Status08(Address)
namespace SMW_NorSpr07A_Fireworks_Status08
%InsertMacroAtXPosition(<Address>)

FireworkSounds:
.WhistleCh1:
	db !Define_SMW_Sound1DF9_FireworksWhistle,$00,!Define_SMW_Sound1DF9_FireworksWhistle,!Define_SMW_Sound1DF9_LouderFireworksWhistle

.WhistleCh3:
	db $00,!Define_SMW_Sound1DFC_FireworksWhistle,$00,$00

.BangCh1:
	db !Define_SMW_Sound1DF9_FireworksBang,$00,!Define_SMW_Sound1DF9_FireworksBang,!Define_SMW_Sound1DF9_LouderFireworksBang

.BangCh3:
	db $00,!Define_SMW_Sound1DFC_FireworksBang,$00,$00
namespace off
endmacro

macro ROUTINE_RT03_SMW_NorSpr07A_Fireworks_Status08(Address)
namespace SMW_NorSpr07A_Fireworks_Status08
%InsertMacroAtXPosition(<Address>)

DATA_03C626:
	db $14,$28,$38,$20,$30,$4C,$40,$34
	db $2C,$1C,$08,$0C,$04,$0C,$1C,$24
	db $2C,$38,$40,$48,$50,$5C,$5C,$6C
	db $4C,$58,$24,$78,$64,$70,$78,$7C
	db $70,$68,$58,$4C,$40,$34,$24,$04
	db $18,$2C,$0C,$0C,$14,$18,$1C,$24
	db $2C,$28,$24,$30,$30,$34,$38,$3C
	db $44,$54,$48,$5C,$68,$40,$4C,$40
	db $3C,$40,$50,$54,$60,$54,$4C,$5C
	db $5C,$68,$74,$6C,$7C,$78,$68,$80
	db $18,$48,$2C,$1C

DATA_03C67A:
	db $1C,$0C,$08,$1C,$14,$08,$14,$24
	db $28,$2C,$30,$3C,$44,$4C,$44,$34
	db $40,$34,$24,$1C,$10,$0C,$18,$18
	db $2C,$28,$68,$28,$34,$34,$38,$40
	db $44,$44,$38,$3C,$44,$48,$4C,$5C
	db $5C,$54,$64,$74,$74,$88,$80,$94
	db $8C,$78,$6C,$64,$70,$7C,$8C,$98
	db $90,$98,$84,$84,$88,$78,$78,$6C
	db $5C,$50,$50,$48,$50,$5C,$64,$64
	db $74,$78,$74,$64,$60,$58,$54,$50
	db $50,$58,$30,$34

DATA_03C6CE:
	db $20,$30,$39,$47,$50,$60,$70,$7C
	db $7B,$80,$7D,$78,$6E,$60,$4F,$47
	db $41,$38,$30,$2A,$20,$10,$04,$00
	db $00,$08,$10,$20,$1A,$10,$0A,$06
	db $0F,$17,$16,$1C,$1F,$21,$10,$18
	db $20,$2C,$2E,$3B,$30,$30,$2D,$2A
	db $34,$36,$3A,$3F,$45,$4D,$5F,$54
	db $4E,$67,$70,$67,$70,$5C,$4E,$40
	db $48,$56,$57,$5F,$68,$72,$77,$6F
	db $66,$60,$67,$5C,$57,$4B,$4D,$54
	db $48,$43,$3D,$3C

DATA_03C722:
	db $18,$1E,$25,$22,$1A,$17,$20,$30
	db $41,$4F,$61,$70,$7F,$8C,$94,$92
	db $A0,$86,$93,$88,$88,$78,$66,$50
	db $40,$30,$22,$20,$2C,$30,$40,$4F
	db $59,$51,$3F,$39,$4C,$5F,$6A,$6F
	db $77,$7E,$6C,$60,$58,$48,$3D,$2F
	db $28,$38,$44,$30,$36,$27,$21,$2F
	db $39,$2A,$2F,$39,$40,$3F,$49,$50
	db $60,$59,$4C,$51,$48,$4F,$56,$67
	db $5B,$68,$75,$7D,$87,$8A,$7A,$6B
	db $70,$82,$73,$92
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr07C_PrincessPeach_Status08(Address)
namespace SMW_NorSpr07C_PrincessPeach_Status08
%InsertMacroAtXPosition(<Address>)

; Y-coords of blushing Mario face tiles (Super, small)
BlushYDisp:
	db $01,$11

; Blushing Mario Faces (Super, Small)
BlushTiles:
	db $6E,$88

Bank03:
;$03AC97
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$7F
	BNE.b CODE_03ACB8
	JSL.l SMW_GetRand_Main
	AND.b #$07
	BNE.b CODE_03ACB8
	LDA.b #$0C
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_BlinkTimer,x
CODE_03ACB8:
	LDY.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_BlinkTimer,x
	BEQ.b CODE_03ACC1
	INY
CODE_03ACC1:
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	BNE.b CODE_03ACCB
	TYA
	CLC
	ADC.b #$08
	TAY
CODE_03ACCB:
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b #$D0
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	JSR.w SMW_NorSpr07C_PrincessPeach_Status08_GFXRt_DrawPeach
	LDY.b #$02
	LDA.b #$03
	JSL.l SMW_FinishOAMWrite_Main
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_MarioBlushTimer,x
	BEQ.b CODE_03AD18
	PHX
	LDX.b #$00
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_03ACEB
	INX
CODE_03ACEB:
	LDY.b #$4C
	LDA.b !RAM_SMW_Player_OnScreenPosXLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	CLC
	ADC.w BlushYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
if ver_is_smasw(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_Player_CurrentCharacter
	BEQ.b CODE_03AD09
	LDA.w SMW_OAMBuffer[$40].YDisp,Y
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	SEC
	SBC.b #$02
else
	DEC
	DEC
endif
	STA.w SMW_OAMBuffer[$40].YDisp,Y
CODE_03AD09:
endif
	LDA.w BlushTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDA.b !RAM_SMW_Player_FacingDirection
	CMP.b #$01
	LDA.b #$31
	BCC.b CODE_03AD0C
	ORA.b #$40
CODE_03AD0C:
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
CODE_03AD18:
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	STZ.b !RAM_SMW_Player_XSpeed
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b !RAM_SMW_NorSpr07C_PrincessPeach_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

PrincessPeachPtrs:
	dw FloatingDown
	dw WaitAfterFall
	dw WalkTowardsBro
	dw StandByBro
	dw KissBro
	dw DisplayMessage
	dw FadeText
	dw Fireworks

FloatingDown:
	LDA.b #$06
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$08
	BCS.b CODE_03AD4B
	CLC
	ADC.b #$01
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_03AD4B:
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	BMI.b CODE_03AD63
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	CMP.b #$B0
else
	CMP.b #$A0
endif
	BCC.b CODE_03AD63
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDA.b #$B0
else
	LDA.b #$A0
endif
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.b #$A0
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_PhaseTimer,x
	INC.b !RAM_SMW_NorSpr07C_PrincessPeach_CurrentState,x
CODE_03AD63:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	BNE.b Return03AD73
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot
CODE_03AD6B:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y
	BEQ.b CODE_03AD74
	DEY
	BPL.b CODE_03AD6B
Return03AD73:
	RTS

CODE_03AD74:
	LDA.b #!Define_SMW_SpriteID_MExtSpr05_SmallStar
	STA.w !RAM_SMW_MExtSpr_SpriteID,y
	JSL.l SMW_GetRand_Main
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$1F
	CLC
	ADC.b #$F8
	BPL.b CODE_03AD88
	DEC.b !RAM_SMW_Misc_ScratchRAM00
CODE_03AD88:
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_MExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_MExtSpr_XPosHi,y
	LDA.w !RAM_SMW_Misc_RandomByte2
	AND.b #$1F
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_MExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_MExtSpr_YPosHi,y
	LDA.b #$00
	STA.w !RAM_SMW_MExtSpr_YSpeed,y
	LDA.b #$17
	STA.w !RAM_SMW_MExtSpr_Timer,y
	RTS

WaitAfterFall:
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_PhaseTimer,x
	BNE.b CODE_03ADC2
	INC.b !RAM_SMW_NorSpr07C_PrincessPeach_CurrentState,x
	JSR.w CODE_03ADCC
	BCC.b CODE_03ADC2
	INC.w !RAM_SMW_NorSpr07C_PrincessPeach_LandedOnMarioFlag,x
CODE_03ADC2:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Player_FacingDirection
	RTS

CODE_03ADCC:
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	RTS

XSpeed:
	db $08,$F8,$F8,$08

WalkTowardsBro:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$08
	BNE.b CODE_03ADE8
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
CODE_03ADE8:
	JSR.w CODE_03ADCC
	PHP
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	PLP
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_LandedOnMarioFlag,x
	BNE.b ADDR_03ADF9
	BCS.b CODE_03AE14
	BRA.b CODE_03ADFF

ADDR_03ADF9:
	BCC.b CODE_03AE14
	TYA
	EOR.b #$01
	TAY
CODE_03ADFF:
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_Player_XSpeed
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Player_FacingDirection
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	RTS

CODE_03AE14:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Player_FacingDirection
	INC.b !RAM_SMW_NorSpr07C_PrincessPeach_CurrentState,x
	LDA.b #$60
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_PhaseTimer,x
	RTS

StandByBro:
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_PhaseTimer,x
	BNE.b Return03AE31
	INC.b !RAM_SMW_NorSpr07C_PrincessPeach_CurrentState,x
	LDA.b #$A0
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_PhaseTimer,x
Return03AE31:
	RTS

KissBro:
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_PhaseTimer,x
	BNE.b CODE_03AE3F
	INC.b !RAM_SMW_NorSpr07C_PrincessPeach_CurrentState,x
	STZ.w !RAM_SMW_UnusedRAM_7E188A				; Optimization: This is unused
	STZ.w !RAM_SMW_Player_RelativeYPositionDuringScreenShake
CODE_03AE3F:
	CMP.b #$50
	BCC.b Return03AE5A
	PHA
	BNE.b CODE_03AE4B
	LDA.b #$14
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_BlinkTimer,x
CODE_03AE4B:
	LDA.b #$0A
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	PLA
	CMP.b #$68
	BNE.b Return03AE5A
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_MarioBlushTimer,x
Return03AE5A:
	RTS

DATA_03AE5B:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	db $08,$08,$00,$10,$08,$08,$00,$08
	db $08,$08,$08,$08,$08,$00,$08,$08
	db $08,$08,$10,$08,$08,$08,$00,$08
	db $03,$38,$04,$10,$04,$10,$0C,$08
	db $08,$08,$08,$08,$08,$04,$0C,$04
	db $10,$00,$08,$08,$08,$08,$08,$08
	db $08,$08,$08,$00,$08,$08,$08,$03
	db $08,$08,$00,$10,$08,$08,$08,$00
	db $08,$08,$00,$08,$08,$08,$08,$40
	db $10,$10,$10,$C0
elseif ver_is_pal(!Define_Global_ROMToAssemble)
	db $05,$05,$05,$05,$05,$05,$10,$05
	db $05,$05,$05,$05,$05,$05,$05,$05
	db $08,$05,$05,$05,$05,$05,$14,$08
	db $05,$05,$05,$05,$14,$05,$05,$08
	db $05,$05,$05,$05,$05,$05,$05,$05
	db $14,$05,$05,$05,$05,$05,$14,$05
	db $03,$14,$05,$05,$05,$05,$05,$05
	db $05,$05,$05,$05,$05,$05,$08,$05
	db $05,$05,$05,$05,$05,$05,$05,$05
	db $05,$05,$08,$05,$05,$05,$05,$05
	db $05,$05,$05,$50
else
	db $08,$08,$08,$08,$08,$08,$18,$08	;!
	db $08,$08,$08,$08,$08,$08,$08,$08	;!
	db $08,$08,$08,$08,$08,$08,$20,$08	;!
	db $08,$08,$08,$08,$20,$08,$08,$10	;!
	db $08,$08,$08,$08,$08,$08,$08,$08	;!
	db $20,$08,$08,$08,$08,$08,$20,$08	;!
	db $04,$20,$08,$08,$08,$08,$08,$08	;!
	db $08,$08,$08,$08,$08,$08,$10,$08	;!
	db $08,$08,$08,$08,$08,$08,$08,$08	;!
	db $08,$08,$10,$08,$08,$08,$08,$08	;!
	db $08,$08,$08,$40		;!
endif

DisplayMessage:
	JSR.w DisplayPeachRescueMessage
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_WaitBeforeDrawingNextLetter,x
	BNE.b Return
	LDY.w !RAM_SMW_NorSpr07C_PrincessPeach_CurrentLetterLo
	CPY.b #(MessageData_End-MessageData)/4
	BEQ.b DoneDisplayingMessage
	INC.w !RAM_SMW_NorSpr07C_PrincessPeach_CurrentLetterLo
	LDA.w DATA_03AE5B,y
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_WaitBeforeDrawingNextLetter,x
Return:
	RTS

DoneDisplayingMessage:
	INC.b !RAM_SMW_NorSpr07C_PrincessPeach_CurrentState,x
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_PhaseTimer,x
	RTS

CODE_03AED0:
	INC.b !RAM_SMW_NorSpr07C_PrincessPeach_CurrentState,x
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_SpawnFireworksTimer
	RTS

UNK_03AED8: ; unused?
	db $00,$00,$94,$18,$18,$9C,$9C,$FF
	db $00,$00,$52,$63,$63,$73,$73,$7F

FadeText:
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_PhaseTimer,x
	BEQ.b CODE_03AED0
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	ASL
	ASL
	ASL
	ASL
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	ASL
	ASL
	ASL
	ASL
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	PHX
	TAX
	LDY.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
	LDA.b #$02
	STA.w !RAM_SMW_Palettes_DynamicPaletteBytesToUpload,y
	LDA.b #$F1
	STA.w !RAM_SMW_Palettes_DynamicPaletteCGRAMAddress,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors+$01,y
	LDA.b #$00
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors+$02,y
	TYA
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
	PLX
	JSR.w DisplayPeachRescueMessage
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr07C_PrincessPeach_Status08(Address)
namespace SMW_NorSpr07C_PrincessPeach_Status08
%InsertMacroAtXPosition(<Address>)

InitialXLo:
	db $60,$B0,$40,$80
namespace off
endmacro

macro ROUTINE_RT03_SMW_NorSpr07C_PrincessPeach_Status08(Address)
namespace SMW_NorSpr07C_PrincessPeach_Status08
%InsertMacroAtXPosition(<Address>)

DATA_03C78A:
	db $00,$AA,$FF,$AA

DATA_03C78E:
	db $00,$7E,$27,$7E

DATA_03C792:
	db $C0,$C0,$FF,$C0

Fireworks:
;$03C796
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_WaitBeforeSpawningFireworks,x
	BEQ.b CODE_03C7A7
	DEC
	BNE.b Return03C7A6
	INC.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	LDA.b #$FF
	STA.w !RAM_SMW_Timer_EndLevel
Return03C7A6:
	RTS

CODE_03C7A7:
	LDA.w !RAM_SMW_NorSpr07A_Fireworks_ColorFlashIndex
	AND.b #$03
	TAY
	LDA.w DATA_03C78A,y
	STA.w !RAM_SMW_Palettes_BackgroundColorLo
	LDA.w DATA_03C78E,y
	STA.w !RAM_SMW_Palettes_BackgroundColorHi
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_SpawnFireworksTimer
	BNE.b Return03C80F
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_FireworksCounter,x
	CMP.b #$04
	BEQ.b CODE_03C810
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$0A
CODE_03C7C7:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_03C7D0
	DEY
	BPL.b CODE_03C7C7
	RTS

CODE_03C7D0:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr07A_Fireworks
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b #$A8
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
	PHX
	LDA.w !RAM_SMW_NorSpr07C_PrincessPeach_FireworksCounter,x
	AND.b #$03
	STA.w !RAM_SMW_NorSpr07A_Fireworks_CurrentType,y
	TAX
	LDA.w DATA_03C792,x
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_SpawnFireworksTimer
	LDA.w InitialXLo,x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	PLX
	INC.w !RAM_SMW_NorSpr07C_PrincessPeach_FireworksCounter,x
Return03C80F:
	RTS

CODE_03C810:
	LDA.b #$70
	STA.w !RAM_SMW_NorSpr07C_PrincessPeach_WaitBeforeSpawningFireworks,x
	RTS
namespace off
endmacro

macro ROUTINE_RT04_SMW_NorSpr07C_PrincessPeach_Status08(Address)
namespace SMW_NorSpr07C_PrincessPeach_Status08
%InsertMacroAtXPosition(<Address>)

; Optimization: Besides changing the BG mode after Bowser disappears and using stipe image text (Which would have been a less hacky way of implementing this), all the property bytes could have been set separately from the tile number.

MessageData:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	incbin "strings/PeachRescueMessage_SMW_J.bin"
else
					;\ Info: This text is 84 characters long in the original SMW. Due to using sprites, the max would be 128, but that's if no other sprites are on screen.
; OAM data for the "Mario's adventure is over..." message. Excluding
; whitespace, each character is defined by four bytes of standard OAM data
; (X position, Y position, tile, YXPPCCCT), and characters will appear one
; by one in the order listed.
.Line1:					;|
	db $18,$20,$A1,$0E		;| M
	db $20,$20,$88,$0E		;| a
	db $28,$20,$AB,$0E		;| r
	db $30,$20,$99,$0E		;| i
	db $38,$20,$A8,$0E		;| o
	db $40,$20,$BF,$0E		;| '
	db $48,$20,$AC,$0E		;| s
					;|  
	db $58,$20,$88,$0E		;| a
	db $60,$20,$8B,$0E		;| d
	db $68,$20,$AF,$0E		;| v
	db $70,$20,$8C,$0E		;| e
	db $78,$20,$9E,$0E		;| n
	db $80,$20,$AD,$0E		;| t
	db $88,$20,$AE,$0E		;| u
	db $90,$20,$AB,$0E		;| r
	db $98,$20,$8C,$0E		;| e
					;|  
	db $A8,$20,$99,$0E		;| i
	db $B0,$20,$AC,$0E		;| s
					;|  
	db $C0,$20,$A8,$0E		;| o
	db $C8,$20,$AF,$0E		;| v
	db $D0,$20,$8C,$0E		;| e
	db $D8,$20,$AB,$0E		;| r
	db $E0,$20,$BD,$0E		;| .
.Line2:					;|  
	db $18,$30,$A1,$0E		;| M
	db $20,$30,$88,$0E		;| a
	db $28,$30,$AB,$0E		;| r
	db $30,$30,$99,$0E		;| i
	db $38,$30,$A8,$0E		;| o
	db $40,$30,$BE,$0E		;| ,
	db $48,$30,$AD,$0E		;| t
	db $50,$30,$98,$0E		;| h
	db $58,$30,$8C,$0E		;| e
					;|  
	db $68,$30,$A0,$0E		;| P
	db $70,$30,$AB,$0E		;| r
	db $78,$30,$99,$0E		;| i
	db $80,$30,$9E,$0E		;| n
	db $88,$30,$8A,$0E		;| c
	db $90,$30,$8C,$0E		;| e
	db $98,$30,$AC,$0E		;| s
	db $A0,$30,$AC,$0E		;| s
	db $A8,$30,$BE,$0E		;| ,
	db $B0,$30,$B0,$0E		;| Y
	db $B8,$30,$A8,$0E		;| o
	db $C0,$30,$AC,$0E		;| s
	db $C8,$30,$98,$0E		;| h
	db $D0,$30,$99,$0E		;| i
	db $D8,$30,$BE,$0E		;| ,
.Line3:					;|  
	db $18,$40,$88,$0E		;| a
	db $20,$40,$9E,$0E		;| n
	db $28,$40,$8B,$0E		;| d
					;|  
	db $38,$40,$98,$0E		;| h
	db $40,$40,$99,$0E		;| i
	db $48,$40,$AC,$0E		;| s
					;|  
	db $58,$40,$8D,$0E		;| f
	db $60,$40,$AB,$0E		;| r
	db $68,$40,$99,$0E		;| i
	db $70,$40,$8C,$0E		;| e
	db $78,$40,$9E,$0E		;| n
	db $80,$40,$8B,$0E		;| d
	db $88,$40,$AC,$0E		;| s
					;|  
	db $98,$40,$88,$0E		;| a
	db $A0,$40,$AB,$0E		;| r
	db $A8,$40,$8C,$0E		;| e
					;|  
	db $B8,$40,$8E,$0E		;| g
	db $C0,$40,$A8,$0E		;| o
	db $C8,$40,$99,$0E		;| i
	db $D0,$40,$9E,$0E		;| n
	db $D8,$40,$8E,$0E		;| g
.Line4:					;|  
	db $18,$50,$AD,$0E		;| t
	db $20,$50,$A8,$0E		;| o
					;|  
	db $30,$50,$AD,$0E		;| t
	db $38,$50,$88,$0E		;| a
	db $40,$50,$9B,$0E		;| k
	db $48,$50,$8C,$0E		;| e
					;|  
	db $58,$50,$88,$0E		;| a
					;| 
	db $68,$50,$AF,$0E		;| v
	db $70,$50,$88,$0E		;| a
	db $78,$50,$8A,$0E		;| c
	db $80,$50,$88,$0E		;| a
	db $88,$50,$AD,$0E		;| t
	db $90,$50,$99,$0E		;| i
	db $98,$50,$A8,$0E		;| o
	db $A0,$50,$9E,$0E		;| n
	db $A8,$50,$BD,$0E		;/ .
endif
.End:

DisplayPeachRescueMessage:
;$03D674
	PHX
	REP.b #$30			; AXY->16
	LDX.w !RAM_SMW_NorSpr07C_PrincessPeach_CurrentLetterLo
	BEQ.b NoLettersToDraw
	DEX
	LDY.w #$0000
Loop:
	PHX
	TXA
	ASL
	ASL
	TAX
	LDA.w MessageData,x
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w MessageData+$02,x
	STA.w SMW_OAMBuffer[$00].Tile,y
	PHY
	TYA
	LSR
	LSR
	TAY
	SEP.b #$20			; A->8
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	REP.b #$20			; A->16
	PLY
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL.b Loop
NoLettersToDraw:
	SEP.b #$30			; AXY->8
	PLX
	RTS
namespace off
endmacro

macro ROUTINE_RT05_SMW_NorSpr07C_PrincessPeach_Status08(Address)
namespace SMW_NorSpr07C_PrincessPeach_Status08
%InsertMacroAtXPosition(<Address>)

PeachXDisp:
	db $00,$08,$00,$08,$00,$08,$00,$08
	db $00,$08,$00,$08,$00,$08,$00,$08
	db $00,$08,$00,$08,$00,$08,$00,$08
	db $00,$08,$00,$08,$00,$08,$00,$08
	db $00,$08,$00,$08,$00,$08,$00,$08
	db $00,$08,$00,$08,$00,$08,$00,$08
	db $08,$00,$08,$00,$08,$00,$08,$00
	db $08,$00,$08,$00,$08,$00,$08,$00
	db $08,$00,$08,$00,$08,$00,$08,$00
	db $08,$00,$08,$00,$08,$00,$08,$00

PeachYDisp:
	db $00,$00,$08,$08,$00,$00,$08,$08
	db $00,$00,$08,$08,$00,$00,$08,$08
	db $00,$00,$10,$10,$00,$00,$10,$10
	db $00,$00,$10,$10,$00,$00,$10,$10
	db $00,$00,$10,$10,$00,$00,$10,$10
	db $00,$00,$10,$10,$00,$00,$10,$10
	db $00,$00,$10,$10,$00,$00,$10,$10
	db $00,$00,$10,$10,$00,$00,$10,$10
	db $00,$00,$10,$10,$00,$00,$10,$10
	db $00,$00,$10,$10,$00,$00,$10,$10

; Sprite tilemap: Princess Toadstool(Bowser Battle)
PeachTiles:
	db $05,$06,$15,$16,$9D,$9E,$4E,$AE
	db $06,$05,$16,$15,$9E,$9D,$AE,$4E
	db $8A,$8B,$AA,$68,$83,$84,$AA,$68
	db $8A,$8B,$80,$81,$83,$84,$80,$81
	db $85,$86,$A5,$A6,$83,$84,$A5,$A6
	db $82,$83,$A2,$A3,$82,$83,$A2,$A3
	db $8A,$8B,$AA,$68,$83,$84,$AA,$68
	db $8A,$8B,$80,$81,$83,$84,$80,$81
	db $85,$86,$A5,$A6,$83,$84,$A5,$A6
	db $82,$83,$A2,$A3,$82,$83,$A2,$A3

PeachProp:
	db $01,$01,$01,$01,$01,$01,$01,$01
	db $41,$41,$41,$41,$41,$41,$41,$41
	db $01,$01,$01,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$01,$01,$01,$01
	db $00,$00,$00,$00,$01,$01,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $41,$41,$41,$41,$41,$41,$41,$41
	db $41,$41,$41,$41,$41,$41,$41,$41
	db $40,$40,$40,$40,$41,$41,$40,$40
	db $40,$40,$40,$40,$40,$40,$40,$40

GFXRt_DrawHELP:
;$03AA6E
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$04
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$20
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	CPY.b #$08
	BCC.b CODE_03AAC6
	CPY.b #$10
	BCS.b CODE_03AAC6
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$04
	STA.w SMW_OAMBuffer[$28].XDisp
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$29].XDisp
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b #$18
	STA.w SMW_OAMBuffer[$28].YDisp
	STA.w SMW_OAMBuffer[$29].YDisp
	LDA.b #$20
	STA.w SMW_OAMBuffer[$28].Tile
	LDA.b #$22
	STA.w SMW_OAMBuffer[$29].Tile
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	AND.b #$06
	INC
	INC
	INC
	STA.w SMW_OAMBuffer[$28].Prop
	STA.w SMW_OAMBuffer[$29].Prop
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$28].Slot
	STA.w SMW_OAMTileSizeBuffer[$29].Slot
CODE_03AAC6:
	LDY.b #$70
GFXRt_DrawPeach:
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM04
	PHX
	LDX.b #$03
CODE_03AAD1:
	PHX
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w PeachXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w PeachYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w PeachTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w PeachProp,x
	PHX
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	CPX.b #$09
	BEQ.b CODE_03AAFC
	ORA.b #$30
CODE_03AAFC:
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	INY
	INY
	INY
	INY
	PLX
	DEX
	BPL.b CODE_03AAD1
	PLX
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SpawnFootball(Address)
namespace SMW_SpawnFootball
%InsertMacroAtXPosition(<Address>)

; X-position of sprite spawned by Puntin' Chuck (facing right/left)
InitialXPosLo:
	db $14,$EC

; X-speed of sprite spawned by Puntin' Chuck, high byte (facing right/left)
InitialXPosHi:
	db $00,$FF

; X-speed of sprite spawned by Puntin' Chuck, low byte (facing right/left)
InitialXSpeed:
	db $18,$E8

Main:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return03CC08
	LDA.b #!Define_SMW_SpriteID_NorSpr01B_Football	; \ Sprite = Football
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	PHX
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.l InitialXPosLo,x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ADC.l InitialXPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.l InitialXSpeed,x
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	LDA.b #$E0
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr01B_Football_WaitBeforeBeingKicked,y
	PLX
Return03CC08:
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0A0_ActivateBowserBattle_Status01(Address)
namespace SMW_NorSpr0A0_ActivateBowserBattle_Status01
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	STZ.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	LDA.b #$80
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HPForCurrentPhase,x
	LDA.b #$03
	STA.b !RAM_SMW_NorSprXXX_CurrentlyActiveBoss,x
	JSL.l SMW_InitializeMode7TilemapsAndPalettes_Main
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0A0_ActivateBowserBattle_Status08(Address)
namespace SMW_NorSpr0A0_ActivateBowserBattle_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	PHB
	PHK
	PLB
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0C8_LightSwitch
	BNE.b NotLightSwitch
	JSR.w SMW_NorSpr0C8_LightSwitch_Status08_Bank03
	PLB
	RTL

NotLightSwitch:
	CMP.b #!Define_SMW_SpriteID_NorSpr0C7_InvisibleMushroom
	BNE.b NotInvisibleMushroom
	JSR.w SMW_NorSpr0C7_InvisibleMushroom_Status08_Bank03
	PLB
	RTL

NotInvisibleMushroom:
	CMP.b #!Define_SMW_SpriteID_NorSpr051_Ninji
	BNE.b NotNinji
	JSR.w SMW_NorSpr051_Ninji_Status08_Bank03
	PLB
	RTL

NotNinji:
	CMP.b #!Define_SMW_SpriteID_NorSpr01B_Football
	BNE.b NotFootball
	JSR.w SMW_NorSpr01B_Football_Status08_Bank03
	PLB
	RTL

NotFootball:
	CMP.b #!Define_SMW_SpriteID_NorSpr0C6_Spotlight
	BNE.b NotSpotlight
	JSR.w SMW_NorSpr0C6_Spotlight_Status08_Bank03
	PLB
	RTL

NotSpotlight:
	CMP.b #!Define_SMW_SpriteID_NorSpr07A_Fireworks
	BNE.b NotFireworks
	JSR.w SMW_NorSpr07A_Fireworks_Status08_Bank03
	PLB
	RTL

NotFireworks:
	CMP.b #!Define_SMW_SpriteID_NorSpr07C_PrincessPeach
	BNE.b NotPrincessPeach
	JSR.w SMW_NorSpr07C_PrincessPeach_Status08_Bank03
	PLB
	RTL

NotPrincessPeach:
	CMP.b #!Define_SMW_SpriteID_NorSpr0C5_BigBooBoss
	BNE.b NotBigBooBoss
	JSR.w SMW_NorSpr0C5_BigBooBoss_Status08_Bank03
	PLB
	RTL

NotBigBooBoss:
	CMP.b #!Define_SMW_SpriteID_NorSpr0C4_GreyFallingPlatform
	BNE.b NotGreyFallingPlatform
	JSR.w SMW_NorSpr0C4_GreyFallingPlatform_Status08_Bank03
	PLB
	RTL

NotGreyFallingPlatform:
	CMP.b #!Define_SMW_SpriteID_NorSpr0C2_Blurp
	BNE.b NotBlurp
	JSR.w SMW_NorSpr0C2_Blurp_Status08_Bank03
	PLB
	RTL

NotBlurp:
	CMP.b #!Define_SMW_SpriteID_NorSpr0C3_PorcuPuffer
	BNE.b NotPorcuPuffer
	JSR.w SMW_NorSpr0C3_PorcuPuffer_Status08_Bank03
	PLB
	RTL

NotPorcuPuffer:
	CMP.b #!Define_SMW_SpriteID_NorSpr0C1_WingedPlatform
	BNE.b NotWingedPlatform
	JSR.w SMW_NorSpr0C1_WingedPlatform_Status08_Bank03
	PLB
	RTL

NotWingedPlatform:
	CMP.b #!Define_SMW_SpriteID_NorSpr0C0_SinkingLavaPlatform
	BNE.b NotSinkingLavaPlatform
	JSR.w SMW_NorSpr0C0_SinkingLavaPlatform_Status08_Bank03
	PLB
	RTL

NotSinkingLavaPlatform:
	CMP.b #!Define_SMW_SpriteID_NorSpr0BF_MegaMole
	BNE.b NotMegaMole
	JSR.w SMW_NorSpr0BF_MegaMole_Status08_Bank03
	PLB
	RTL

NotMegaMole:
	CMP.b #!Define_SMW_SpriteID_NorSpr0BE_Swooper
	BNE.b NotSwooper
	JSR.w SMW_NorSpr0BE_Swooper_Status08_Bank03
	PLB
	RTL

NotSwooper:
	CMP.b #!Define_SMW_SpriteID_NorSpr0BD_SlidingNakedBlueKoopa
	BNE.b NotSlidingNakedBlueKoopa
	JSR.w SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status08_Bank03
	PLB
	RTL

NotSlidingNakedBlueKoopa:
	CMP.b #!Define_SMW_SpriteID_NorSpr0BC_BowserStatue
	BNE.b NotBowserStatue
	JSR.w SMW_NorSpr0BC_BowserStatue_Status08_Bank03
	PLB
	RTL

NotBowserStatue:
	CMP.b #!Define_SMW_SpriteID_NorSpr0B8_CarrotTopLiftUpperLeft
	BEQ.b IsCarrotTopLift
	CMP.b #!Define_SMW_SpriteID_NorSpr0B7_CarrotTopLiftUpperRight
	BNE.b NotCarrotTopLift
IsCarrotTopLift:
	JSR.w SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status08_Bank03
	PLB
	RTL

NotCarrotTopLift:
	CMP.b #!Define_SMW_SpriteID_NorSpr0B9_MessageBox
	BNE.b NotMessageBox
	JSR.w SMW_NorSpr0B9_MessageBox_Status08_Bank03
	PLB
	RTL

NotMessageBox:
	CMP.b #!Define_SMW_SpriteID_NorSpr0BA_TimedPlatform
	BNE.b NotTimedPlatform
	JSR.w SMW_NorSpr0BA_TimedPlatform_Status08_Bank03
	PLB
	RTL

NotTimedPlatform:
	CMP.b #!Define_SMW_SpriteID_NorSpr0BB_MovingCastleStone
	BNE.b NotMovingCastleStone
	JSR.w SMW_NorSpr0BB_MovingCastleStone_Status08_Bank03
	PLB
	RTL

NotMovingCastleStone:
	CMP.b #!Define_SMW_SpriteID_NorSpr0B3_BowserStatueFire
	BNE.b NotBowserStatueFire
	JSR.w SMW_NorSpr0B3_BowserStatueFire_Status08_Bank03
	PLB
	RTL

NotBowserStatueFire:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0B2_FallingSpike
	BNE.b NotFallingSpike
	JSR.w SMW_NorSpr0B2_FallingSpike_Status08_Bank03
	PLB
	RTL

NotFallingSpike:
	CMP.b #!Define_SMW_SpriteID_NorSpr0AE_FishinBoo
	BNE.b NotFishinBoo
	JSR.w SMW_NorSpr0AE_FishinBoo_Status08_Bank03
	PLB
	RTL

NotFishinBoo:
	CMP.b #!Define_SMW_SpriteID_NorSpr0B6_ReflectingPodoboo
	BNE.b NotReflectingPodoboo
	JSR.w SMW_NorSprXXX_ReflectingEnemy_Status08_ReflectingPodobooEntry
	PLB
	RTL

NotReflectingPodoboo:
	CMP.b #!Define_SMW_SpriteID_NorSpr0B0_ReflectingBooBuddies
	BNE.b NotReflectingBooBuddies
	JSR.w SMW_NorSprXXX_ReflectingEnemy_Status08_ReflectingBooBuddiesEntry
	PLB
	RTL

NotReflectingBooBuddies:
	CMP.b #!Define_SMW_SpriteID_NorSpr0B1_CreateEatBlock
	BNE.b NotCreateEatBlock
	JSR.w SMW_NorSpr0B1_CreateEatBlock_Status08_Bank03
	PLB
	RTL

NotCreateEatBlock:
	CMP.b #!Define_SMW_SpriteID_NorSpr0AC_DownFirstWoodenSpike
	BEQ.b IsWoodenSpike
	CMP.b #!Define_SMW_SpriteID_NorSpr0AD_UpDownFirstWoodenSpike
	BNE.b NotWoodenSpike
IsWoodenSpike:
	JSR.w SMW_NorSpr0AC_DownFirstWoodenSpike_Status08_Bank03
	PLB
	RTL

NotWoodenSpike:
	CMP.b #!Define_SMW_SpriteID_NorSpr0AB_Rex
	BNE.b NotRex
	JSR.w SMW_NorSpr0AB_Rex_Status08_Bank03
	PLB
	RTL

NotRex:
	CMP.b #!Define_SMW_SpriteID_NorSpr0AA_Fishbone
	BNE.b NotFishbone
	JSR.w SMW_NorSpr0AA_Fishbone_Status08_Bank03
	PLB
	RTL

NotFishbone:
	CMP.b #!Define_SMW_SpriteID_NorSpr0A9_Reznor
	BNE.b NotReznor
	JSR.w SMW_NorSpr0A9_Reznor_Status08_Bank03
	PLB
	RTL

NotReznor:
	CMP.b #!Define_SMW_SpriteID_NorSpr0A8_Blargg
	BNE.b NotBlargg
	JSR.w SMW_NorSpr0A8_Blargg_Status08_Bank03
	PLB
	RTL

NotBlargg:
	CMP.b #!Define_SMW_SpriteID_NorSpr0A1_BowserBowlingBall
	BNE.b NotBowserBowlingBall
	JSR.w SMW_NorSpr0A1_BowserBowlingBall_Status08_Bank03
	PLB
	RTL

NotBowserBowlingBall:
	CMP.b #!Define_SMW_SpriteID_NorSpr0A2_MechaKoopa	;\
	BNE.b IsActivateBowserBattle	;| Mechakoopa
	JSR.w SMW_NorSpr0A2_MechaKoopa_Status08_Bank03	;| INIT Routline
	PLB				;/
	RTL

IsActivateBowserBattle:
	JSL.l UpdatePaletteAndLightningAnimation
	JSR.w Sub
	JSR.w GFXRt
	PLB
	RTL

DATA_03A265:
	db $04,$03,$02,$01,$00,$01,$02,$03
	db $04,$05,$06,$07,$07,$07,$07,$07
	db $07,$07,$07,$07

Sub:
	LDA.b !RAM_SMW_Misc_M7AngleLo
	LSR
	LSR
	LSR
	TAY
	LDA.w DATA_03A265,y
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_PaletteIndex
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame,x
	CLC
	ADC.b #(SMW_InitializeMode7TilemapsAndPalettes_TilemapData_Bowser-SMW_InitializeMode7TilemapsAndPalettes_TilemapData)/$10
	ORA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_FacingFirection,x
	STA.w !RAM_SMW_Misc_Mode7TilemapIndex
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	AND.b #$03
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_PropellerAnimationFrameCounter
	LDA.b #$90
	STA.b !RAM_SMW_Mirror_M7CenterXPosLo
	LDA.b #$C8
	STA.b !RAM_SMW_Mirror_M7CenterYPosLo
	JSL.l SMW_UpdateMode7SpriteAnimations_Main
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HurtStateTimer
	BEQ.b CODE_03A2AD
	JSR.w CODE_03AF59
CODE_03A2AD:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_SmokePuffTimer,x
	BEQ.b CODE_03A2B5
	JSR.w SmokeGFXRt
CODE_03A2B5:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HelpAnimationTimer,x
	BEQ.b CODE_03A2CE
	DEC
	LSR
	LSR
	PHA
	LSR
	TAY
	LDA.w DATA_03A8BE,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PLA
	AND.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM03
	JSR.w SMW_NorSpr07C_PrincessPeach_Status08_GFXRt_DrawHELP		;\ Optimization: Seems like the routine that draws Peach may have been an RTL routine at some point.
	NOP								;/
CODE_03A2CE:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return03A340
	STZ.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HelpAnimationTimer,x
	LDA.b #$30
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.b !RAM_SMW_Misc_M7AngleLo
	CMP.b #$20
	BCS.b CODE_03A2E1
	STZ.b !RAM_SMW_Sprites_TilePriority
CODE_03A2E1:
	JSR.w CODE_03A661
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
	BEQ.b CODE_03A2F2
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_03A2F2
	DEC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
CODE_03A2F2:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$7F
	BNE.b CODE_03A305
	JSL.l SMW_GetRand_Main
	AND.b #$01
	BNE.b CODE_03A305
	LDA.b #$0C
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ClownCarBlinkAnimationTimer,x
CODE_03A305:
	JSR.w CODE_03B078
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	CMP.b #$09
	BEQ.b CODE_03A31A
	STZ.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ClownCarFaceAnimationFrame
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ClownCarBlinkAnimationTimer,x
	BEQ.b CODE_03A31A
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ClownCarFaceAnimationFrame
CODE_03A31A:
	JSR.w CODE_03A5AD
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	LDA.w !RAM_SMW_NorSpr_Table7E151C,x
	JSL.l SMW_ExecutePtr_Absolute

ActivateBowserBattlePtrs:
	dw State00_InitialDescent
	dw State01_SwoopOut
	dw State02_SwoopIn
	dw State03_DropFireballs
	dw State04_RiseUpToDie
	dw State05_ClownCarMalfunction
	dw State06_DropPeachAndFlyOff
	dw State07_Phase1
	dw State08_Phase2
	dw State09_Phase3

Return03A340:
	RTS

SmokeXDisp:
	db $D5,$DD,$23,$2B,$D5,$DD,$23,$2B
	db $D5,$DD,$23,$2B,$D5,$DD,$23,$2B
	db $D6,$DE,$22,$2A,$D6,$DE,$22,$2A
	db $D7,$DF,$21,$29,$D7,$DF,$21,$29
	db $D8,$E0,$20,$28,$D8,$E0,$20,$28
	db $DA,$E2,$1E,$26,$DA,$E2,$1E,$26
	db $DC,$E4,$1C,$24,$DC,$E4,$1C,$24
	db $E0,$E8,$18,$20,$E0,$E8,$18,$20
	db $E8,$F0,$10,$18,$E8,$F0,$10,$18

SmokeYDisp:
	db $DD,$D5,$D5,$DD,$23,$2B,$2B,$23
	db $DD,$D5,$D5,$DD,$23,$2B,$2B,$23
	db $DE,$D6,$D6,$DE,$22,$2A,$2A,$22
	db $DF,$D7,$D7,$DF,$21,$29,$29,$21
	db $E0,$D8,$D8,$E0,$20,$28,$28,$20
	db $E2,$DA,$DA,$E2,$1E,$26,$26,$1E
	db $E4,$DC,$DC,$E4,$1C,$24,$24,$1C
	db $E8,$E0,$E0,$E8,$18,$20,$20,$18
	db $F0,$E8,$E8,$F0,$10,$18,$18,$10

SmokeProp:
	db $80,$40,$00,$C0,$00,$C0,$80,$40

; Tilemap: Clouds from Bowser's Clown Car
SmokeTiles:
	db $E3,$ED,$ED,$EB,$EB,$E9,$E9,$E7
	db $E7

SmokeGFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_SmokePuffTimer,x
	DEC
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM03
	ASL
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$70
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	PHX
	LDX.b #$07
CODE_03A3FA:
	PHX
	TXA
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w SmokeXDisp,x
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w SmokeYDisp,x
	CLC
	ADC.b #$30
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w SmokeTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDA.w SmokeProp,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03A3FA
	PLX
	LDY.b #$02
	LDA.b #$07
	JSL.l SMW_FinishOAMWrite_Main
	RTS

DuckingAnimationFrames:
	db $00,$00,$00,$00,$02,$04,$06,$08
	db $0A,$0E

State00_InitialDescent:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeAttackPhase1,x
	BNE.b CODE_03A482
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_DuckingAnimationTimer,x
	BNE.b CODE_03A465
	LDA.b #$0E
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame,x
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$05
else
	LDA.b #$04
endif
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$10
	BNE.b Return03A464
	LDA.b #$A4
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_DuckingAnimationTimer,x
Return03A464:
	RTS

CODE_03A465:
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	CMP.b #$01
	BEQ.b CODE_03A47C
	CMP.b #$40
	BCS.b Return03A47B
	LSR
	LSR
	LSR
	TAY
	LDA.w DuckingAnimationFrames,y
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame,x
Return03A47B:
	RTS

CODE_03A47C:
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$15
else
	LDA.b #$24
endif
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeAttackPhase1,x
	RTS

CODE_03A482:
	DEC
	BNE.b Return03A48F
	LDA.b #$07
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	LDA.b #$78
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
Return03A48F:
	RTS

DATA_03A490:
	db $FF,$01

; X speed of Bowser's swoop in first part.
DATA_03A492:
	db $C8,$38

DATA_03A494:
	db $01,$FF

; Y speed of Bowser's swoop in first part.
DATA_03A496:
	db $1C,$E4

DATA_03A498:
	db $00,$02,$04,$02

State07_Phase1:
	JSR.w CODE_03A4D2
	JSR.w CODE_03A4FD
	JSR.w CODE_03A4ED
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HorizontalAccelerationDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CLC
	ADC.w DATA_03A490,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w DATA_03A492,y
	BNE.b CODE_03A4BB
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HorizontalAccelerationDirection,x
CODE_03A4BB:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_VerticalAccelerationDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w DATA_03A494,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w DATA_03A496,y
	BNE.b Return03A4D1
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_VerticalAccelerationDirection,x
Return03A4D1:
	RTS

CODE_03A4D2:
	LDY.b #$00
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$E0
	BNE.b CODE_03A4E6
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$18
	LSR
	LSR
	LSR
	TAY
	LDA.w DATA_03A498,y
	TAY
CODE_03A4E6:
	TYA
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame,x
	RTS

DATA_03A4EB:
	db $80,$00

CODE_03A4ED:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$1F
	BNE.b Return03A4FC
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	LDA.w DATA_03A4EB,y
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_FacingFirection,x
Return03A4FC:
	RTS

CODE_03A4FD:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
	BNE.b Return03A52C
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	CMP.b #$08
	BNE.b CODE_03A51A
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_Phase2AttackCounter
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_Phase2AttackCounter
	CMP.b #$03
	BEQ.b CODE_03A51A
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeBowlingBallDrop
	BRA.b Return03A52C

CODE_03A51A:
	STZ.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_Phase2AttackCounter
	LDA.w !RAM_SMW_NorSpr_CurrentStatus
	BEQ.b CODE_03A527
	LDA.w !RAM_SMW_NorSpr_CurrentStatus+$01
	BNE.b Return03A52C
CODE_03A527:
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeMechaKoopaThrow
Return03A52C:
	RTS

DATA_03A52D:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$02,$04,$06,$08,$0A,$0E,$0E
	db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	db $0E,$0E,$0A,$08,$06,$04,$02,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00

DATA_03A56D:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$10,$20,$30,$40,$50,$60
	db $80,$A0,$C0,$E0,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$C0,$80,$60
	db $40,$30,$20,$10,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00

CODE_03A5AD:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeMechaKoopaThrow
	BEQ.b CODE_03A5D8
	DEC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeMechaKoopaThrow
	BNE.b CODE_03A5BD
	LDA.b #$54
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
	RTS

CODE_03A5BD:
	LSR
	LSR
	TAY
	LDA.w DATA_03A52D,y
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeMechaKoopaThrow
	CMP.b #$80
	BNE.b CODE_03A5D5
	JSR.w CODE_03B019
	LDA.b #!Define_SMW_Sound1DFC_Springboard	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_03A5D5:
	PLA
	PLA
	RTS

CODE_03A5D8:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeBowlingBallDrop
	BEQ.b Return03A60D
	DEC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeBowlingBallDrop
	BEQ.b CODE_03A60E
	LSR
	LSR
	TAY
	LDA.w DATA_03A52D,y
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame,x
	LDA.w DATA_03A56D,y
	STA.b !RAM_SMW_Misc_M7RotationLo
	STZ.b !RAM_SMW_Misc_M7RotationHi
	CMP.b #$FF
	BNE.b CODE_03A5FC
	STZ.b !RAM_SMW_Misc_M7RotationLo
	INC.b !RAM_SMW_Misc_M7RotationHi
	STZ.b !RAM_SMW_Sprites_TilePriority
CODE_03A5FC:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeBowlingBallDrop
	CMP.b #$80
	BNE.b CODE_03A60B
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	JSR.w CODE_03A61D
CODE_03A60B:
	PLA
	PLA
Return03A60D:
	RTS

CODE_03A60E:
	LDA.b #$60
	LDY.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_Phase2AttackCounter
	CPY.b #$02
	BEQ.b CODE_03A619
	LDA.b #$20
CODE_03A619:
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
	RTS

CODE_03A61D:
	LDA.b #!Define_SMW_NorSprStatus08_Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus+$08
	LDA.b #!Define_SMW_SpriteID_NorSpr0A1_BowserBowlingBall
if defined("Define_SMW_SA1")
	; SA-1 Pack: Bowser's bowling balls are hard-coded to use sprite slot 8,
	; just hijack their generation for simplicity.
	JML.l BOWSER_BOWLING_BALL
else
	STA.b !RAM_SMW_NorSpr_SpriteID+$08
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
endif
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_NorSpr_XPosLo_AsShipped+$08	; dead under SA-1 Pack, which replaces this code
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi+$08
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$40
	STA.b !RAM_SMW_NorSpr_YPosLo_AsShipped+$08	; dead under SA-1 Pack, which replaces this code
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi+$08
	PHX
	LDX.b #$08
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
	RTS

DATA_03A64D:
	db $00,$00,$00,$00,$FC,$F8,$F4,$F0
	db $F4,$F8,$FC,$00,$04,$08,$0C,$10
	db $0C,$08,$04,$00

CODE_03A661:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HurtStateTimer
	BEQ.b Return03A6BF
	STZ.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeMechaKoopaThrow
	STZ.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeBowlingBallDrop
	DEC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HurtStateTimer
	BNE.b CODE_03A691
	LDA.b #$50
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
	DEC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HPForCurrentPhase,x
	BNE.b CODE_03A691
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	CMP.b #$09
	BEQ.b CODE_03A6C0
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HPForCurrentPhase,x
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_DuckingAnimationTimer,x

CODE_03A691:
	PLY
	PLY
	PHA
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HurtStateTimer
	LSR
	LSR
	TAY
	LDA.w DATA_03A64D,y
	STA.b !RAM_SMW_Misc_M7RotationLo
	STZ.b !RAM_SMW_Misc_M7RotationHi
	BPL.b CODE_03A6A5
	INC.b !RAM_SMW_Misc_M7RotationHi
CODE_03A6A5:
	PLA
	LDY.b #$0C
	CMP.b #$40
	BCS.b CODE_03A6B6
CODE_03A6AC:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LDY.b #$10
	AND.b #$04
	BEQ.b CODE_03A6B6
	LDY.b #$12
CODE_03A6B6:
	TYA
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame,x
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ClownCarFaceAnimationFrame
Return03A6BF:
	RTS

CODE_03A6C0:
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr0A0_ActivateBowserBattle_Status08(Address)
namespace SMW_NorSpr0A0_ActivateBowserBattle_Status08
%InsertMacroAtXPosition(<Address>)

DATA_03A6F0:
	db $0E,$0E,$0A,$08,$06,$04,$02,$00

State01_SwoopOut:
;$03A6F8
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_DuckingAnimationTimer,x
	BEQ.b CODE_03A731
	CMP.b #$01
	BNE.b CODE_03A706
	LDY.b #!Define_SMW_LevelMusic_BowserZoomOut
	STY.w !RAM_SMW_IO_MusicCh1	; / Change music
CODE_03A706:
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA.w DATA_03A6F0,y
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	STZ.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HorizontalAccelerationDirection,x
	STZ.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_VerticalAccelerationDirection,x
	STZ.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ScalingDirection
	RTS

; Bowser's X acceleration as he swoops out before the fireball phase. First
; is while shrinking, second is while growing. Default is $01,$FF.
DATA_03A71F:
	db $01,$FF

DATA_03A721:
	db $10,$80

DATA_03A723:
	db $07,$03

; Bowser's Y acceleration as he swoops out before the fireball phase. First
; is while shrinking, second is while growing. Default is $FF,$01.
DATA_03A725:
	db $FF,$01

DATA_03A727:
	db $F0,$08

; Bowser's shrink/grow speed (change in $38 and $39) as he swoops out before
; the fireball phase. First is while shrinking, second is while growing.
; Default is $01,$FF.
DATA_03A729:
	db $01,$FF

DATA_03A72B:
	db $03,$03

DATA_03A72D:
	db $60,$02

DATA_03A72F:
	db $01,$01

CODE_03A731:
	LDY.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HorizontalAccelerationDirection,x
	CPY.b #$02
	BCS.b CODE_03A74F
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w DATA_03A723,y
	BNE.b CODE_03A74F
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CLC
	ADC.w DATA_03A71F,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w DATA_03A721,y
	BNE.b CODE_03A74F
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HorizontalAccelerationDirection,x
CODE_03A74F:
	LDY.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_VerticalAccelerationDirection,x
	CPY.b #$02
	BCS.b CODE_03A76D
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w DATA_03A72B,y
	BNE.b CODE_03A76D
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w DATA_03A725,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w DATA_03A727,y
	BNE.b CODE_03A76D
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_VerticalAccelerationDirection,x
CODE_03A76D:
	LDY.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ScalingDirection
	CPY.b #$02
	BEQ.b CODE_03A794
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w DATA_03A72F,y
	BNE.b CODE_03A78D
	LDA.b !RAM_SMW_Misc_M7AngleLo
	CLC
	ADC.w DATA_03A729,y
	STA.b !RAM_SMW_Misc_M7AngleLo
	STA.b !RAM_SMW_Misc_M7AngleHi
	CMP.w DATA_03A72D,y
	BNE.b CODE_03A78D
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ScalingDirection
CODE_03A78D:
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	CMP.b #$FE
	BNE.b Return03A7AC
CODE_03A794:
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
	JSL.l SMW_GetRand_Main
	AND.b #$F0
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_FireballInitialXPosLo
	LDA.b #!Define_SMW_LevelMusic_BowserInterlude
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
Return03A7AC:
	RTS

State03_DropFireballs:
	LDA.b #$60
	STA.b !RAM_SMW_Misc_M7AngleLo
	STA.b !RAM_SMW_Misc_M7AngleHi
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b #$60
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
	BNE.b CODE_03A7DF
	LDA.b #!Define_SMW_LevelMusic_BowserZoomIn
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	LDA.b #$18
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b #$08
	STA.b !RAM_SMW_Misc_M7AngleLo
	STA.b !RAM_SMW_Misc_M7AngleHi
	LDA.b #$64
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	RTS

CODE_03A7DF:
	CMP.b #$60
	BCS.b Return03A840
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$1F
	BNE.b Return03A840
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$04
CODE_03A7EB:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_03A7F6
	DEY
	CPY.b #!Define_SMW_StockMaxNormalSpriteSlot-$0A
	BNE.b CODE_03A7EB
	RTS

CODE_03A7F6:
	LDA.b #!Define_SMW_Sound1DFC_FireSpit					;\ Glitch: This is overwritten by the podoboo pan sounds a bit later in this routine.
	STA.w !RAM_SMW_IO_SoundCh3						;/
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr033_Podoboo
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_FireballInitialXPosLo
	PHA
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	CLC
	ADC.b #$20
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_FireballInitialXPosLo
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	; [F6 C2] By default, sets the sprite state for Bowser's Podoboo Rain to
	; 01. Change to EA EA to change the sprite state back to 00 - useful if you
	; want Bowser to spawn different falling sprites in between his regular
	; attack rounds.
	INC.b !RAM_SMW_NorSpr033_Podoboo_FireballType,x
	ASL.w !RAM_SMW_NorSpr_PropertyBits1686,x				;\ Note: !Define_SMW_NorSpr_1686Prop_DisableObjectClipping
	LSR.w !RAM_SMW_NorSpr_PropertyBits1686,x				;/
	LDA.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping39
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	PLX
	PLA
	LSR
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA.w RainingFireSounds,y
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
Return03A840:
	RTS

; Bowser Battle other flame sounds
RainingFireSounds:
	db !Define_SMW_Sound1DFC_PodobooPan1,!Define_SMW_Sound1DFC_PodobooPan2,!Define_SMW_Sound1DFC_PodobooPan3,!Define_SMW_Sound1DFC_PodobooPan4
	db !Define_SMW_Sound1DFC_PodobooPan5,!Define_SMW_Sound1DFC_PodobooPan6,!Define_SMW_Sound1DFC_PodobooPan7,!Define_SMW_Sound1DFC_PodobooPan8

; Music for the other Bowser Battle attack phases
BowserSoundMusic:
	db !Define_SMW_LevelMusic_FightBowser3,!Define_SMW_LevelMusic_FightBowser4

State02_SwoopIn:
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_DuckingAnimationTimer,x
	BNE.b CODE_03A86E
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b CODE_03A858
	DEC.b !RAM_SMW_NorSpr_XSpeed,x
CODE_03A858:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b Return03A86D
	INC.b !RAM_SMW_Misc_M7AngleLo
	INC.b !RAM_SMW_Misc_M7AngleHi
	LDA.b !RAM_SMW_Misc_M7AngleLo
	CMP.b #$20
	BNE.b Return03A86D
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_DuckingAnimationTimer,x
Return03A86D:
	RTS

CODE_03A86E:
	CMP.b #$A0
	BNE.b CODE_03A877
	PHA
	JSR.w CODE_03A8D6
	PLA
CODE_03A877:
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	CMP.b #$01
	BEQ.b CODE_03A89D
	CMP.b #$40
	BCS.b CODE_03A8AE
	CMP.b #$3F
	BNE.b CODE_03A892
	PHA
	LDY.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_SongToPlayIndex
	LDA.w BowserSoundMusic-$07,y
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	PLA
CODE_03A892:
	LSR
	LSR
	LSR
	TAY
	LDA.w DuckingAnimationFrames,y
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_BowserAnimationFrame,x
	RTS

CODE_03A89D:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_SongToPlayIndex
	INC
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeNextAttack
	RTS

CODE_03A8AE:
	CMP.b #$E8
	BNE.b CODE_03A8B7
	LDY.b #!Define_SMW_Sound1DF9_PeachPoppingOutOfClownCar	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh1
CODE_03A8B7:
	SEC
	SBC.b #$3F
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HelpAnimationTimer,x
	RTS

DATA_03A8BE:
	db $00,$00,$00,$08,$10,$14,$14,$16
	db $16,$18,$18,$17,$16,$16,$17,$18
	db $18,$17,$14,$10,$0C,$08,$04,$00

CODE_03A8D6:
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$04
CODE_03A8D8:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_03A8E3
	DEY
	CPY.b #!Define_SMW_StockMaxNormalSpriteSlot-$0A
	BNE.b CODE_03A8D8
	RTS

CODE_03A8E3:
	LDA.b #!Define_SMW_Sound1DF9_MagicShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr074_Mushroom
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$18
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b #$C0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	STZ.w !RAM_SMW_NorSpr_FacingDirection,x
	LDY.b #$0C
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	BPL.b CODE_03A92A
	LDY.b #$F4
	INC.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_03A92A:
	STY.b !RAM_SMW_NorSpr_XSpeed,x
	PLX
	RTS
namespace off
endmacro

macro ROUTINE_RT03_SMW_NorSpr0A0_ActivateBowserBattle_Status08(Address)
namespace SMW_NorSpr0A0_ActivateBowserBattle_Status08
%InsertMacroAtXPosition(<Address>)

; Bowser's X acceleration (right/left) during phase 2.
DATA_03AB15:
	db $01,$FF

; Bowser's maximum X speed (right/left) during phase 2.
DATA_03AB17:
	db $20,$E0

; Bowser's Y acceleration (down/up) during phase 2.
DATA_03AB19:
	db $02,$FE

; Bowser's maximum Y speed (down/up) during phase 2.
DATA_03AB1B:
	db $20,$E0,$01,$FF,$10,$F0

State08_Phase2:
	JSR.w CODE_03A4FD
	JSR.w CODE_03A4D2
	JSR.w CODE_03A4ED
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$00
	BNE.b CODE_03AB4B
	LDY.b #$00
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.b !RAM_SMW_Player_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b !RAM_SMW_Player_XPosHi
	BMI.b CODE_03AB3E
	INY
CODE_03AB3E:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w DATA_03AB17,y
	BEQ.b CODE_03AB4B
	CLC
	ADC.w DATA_03AB15,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_03AB4B:
	LDY.b #$00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$10
	BMI.b CODE_03AB54
	INY
CODE_03AB54:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w DATA_03AB1B,y
	BEQ.b Return03AB61
	CLC
	ADC.w DATA_03AB19,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return03AB61:
	RTS

; X speed of bounce in Bowser's third part.
DATA_03AB62:
	db $10,$F0

State09_Phase3:
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_ClownCarFaceAnimationFrame
	JSR.w CODE_03A4FD
	JSR.w CODE_03A4D2
	JSR.w CODE_03A4ED
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.b #$03
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	CMP.b #$74
else
	CMP.b #$64
endif
	BCC.b Return03AB9E
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	BMI.b Return03AB9E
	LDA.b #$64
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$A0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	LDA.w DATA_03AB62,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$20			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
Return03AB9E:
	RTS

State04_RiseUpToDie:
	JSR.w CODE_03A6AC
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	BMI.b CODE_03ABAF
	BNE.b CODE_03ABB9
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$10
	BCS.b CODE_03ABB9
CODE_03ABAF:
	LDA.b #$05
	STA.w !RAM_SMW_NorSpr_Table7E151C,x
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$50
else
	LDA.b #$60
endif
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
CODE_03ABB9:
	LDA.b #$F8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	RTS

State05_ClownCarMalfunction:
	JSR.w CODE_03A6AC
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	BNE.b CODE_03ABEB
	LDA.b !RAM_SMW_Misc_M7RotationLo
	CLC
	ADC.b #$0A
	STA.b !RAM_SMW_Misc_M7RotationLo
	LDA.b !RAM_SMW_Misc_M7RotationHi
	ADC.b #$00
	STA.b !RAM_SMW_Misc_M7RotationHi
	BEQ.b Return03ABEA
	STZ.b !RAM_SMW_Misc_M7RotationLo
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$50
else
	LDA.b #$60
endif
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	LDA.b #$06
	STA.w !RAM_SMW_NorSpr_Table7E151C,x
Return03ABEA:
	RTS

CODE_03ABEB:
if ver_is_pal(!Define_Global_ROMToAssemble)
	CMP.b #$30
else
	CMP.b #$40
endif
	BCC.b Return03AC02
if ver_is_pal(!Define_Global_ROMToAssemble)
	CMP.b #$4A
else
	CMP.b #$5E
endif
	BNE.b CODE_03ABF8
	LDY.b #!Define_SMW_LevelMusic_BowserDied
	STY.w !RAM_SMW_IO_MusicCh1	; / Change music
CODE_03ABF8:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_SmokePuffTimer,x
	BNE.b Return03AC02
	LDA.b #$12
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_SmokePuffTimer,x
Return03AC02:
	RTS

State06_DropPeachAndFlyOff:
	JSR.w CODE_03A6AC
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	CMP.b #$01
	BNE.b CODE_03AC22
	LDA.b #!Define_SMW_PlayerState0B_RescuedPeach
	STA.b !RAM_SMW_Player_CurrentState
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_EndOfBattleFlag
	STZ.w !RAM_SMW_Palettes_BackgroundColorLo
	STZ.w !RAM_SMW_Palettes_BackgroundColorHi
	LDA.b #$03
	STA.w !RAM_SMW_Player_CurrentLayerPriority
	JSR.w CODE_03AC63
CODE_03AC22:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	BNE.b Return03AC4C
	LDA.b #$FA
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$FC
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_Misc_M7RotationLo
	CLC
	ADC.b #$05
	STA.b !RAM_SMW_Misc_M7RotationLo
	LDA.b !RAM_SMW_Misc_M7RotationHi
	ADC.b #$00
	STA.b !RAM_SMW_Misc_M7RotationHi
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b Return03AC4C
	LDA.b !RAM_SMW_Misc_M7AngleLo
	CMP.b #$80
	BCS.b CODE_03AC4D
	INC.b !RAM_SMW_Misc_M7AngleLo
	INC.b !RAM_SMW_Misc_M7AngleHi
Return03AC4C:
	RTS

CODE_03AC4D:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_PeachKissMusicIsPlaying,x
	BNE.b CODE_03AC5A
	LDA.b #!Define_SMW_LevelMusic_PrincessKiss
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_PeachKissMusicIsPlaying,x
CODE_03AC5A:
	LDA.b #$FE
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	RTS

; Routine that spawns Princess Peach from Bowser's clown car. $03AC69 is the
; sprite ID Bowser spawns. Note that it will always use the 8th sprite slot.
; $03AC7F is the starting Y-coordinate of this sprite.
CODE_03AC63:
	LDA.b #!Define_SMW_NorSprStatus08_Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus+$08
	LDA.b #!Define_SMW_SpriteID_NorSpr07C_PrincessPeach
if defined("Define_SMW_SA1")
	; SA-1 Pack: Princess peach is also hard-coded for slot 8, do the same
	; thing.
	JML.l PRINCESS_PEACH
else
	STA.b !RAM_SMW_NorSpr_SpriteID+$08
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
endif
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_NorSpr_XPosLo_AsShipped+$08	; dead under SA-1 Pack, which replaces this code
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi+$08
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$47
	STA.b !RAM_SMW_NorSpr_YPosLo_AsShipped+$08	; dead under SA-1 Pack, which replaces this code
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi+$08
	PHX
	LDX.b #$08
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
	RTS
namespace off
endmacro

macro ROUTINE_RT04_SMW_NorSpr0A0_ActivateBowserBattle_Status08(Address)
namespace SMW_NorSpr0A0_ActivateBowserBattle_Status08
%InsertMacroAtXPosition(<Address>)

DATA_03AF34:
	db $F4,$FF,$0C,$19,$24,$19,$0C,$FF

DATA_03AF3C:
	db $FC,$F6,$F4,$F6,$FC,$02,$04,$02

DATA_03AF44:
	db $05,$05,$05,$05,$45,$45,$45,$45

DATA_03AF4C:
	db $34,$34,$34,$35,$35,$36,$36,$37
	db $38,$3A,$3E,$46,$54

CODE_03AF59:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_FacingFirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$07
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$EC
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	PHX
	LDX.b #$03
CODE_03AF72:
	PHX
	TXA
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	AND.b #$07
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_03AF34,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w DATA_03AF3C,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$59
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w DATA_03AF44,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03AF72
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_TearDropYDispIndex
	INC.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_TearDropYDispIndex
	LSR
	LSR
	LSR
	CMP.b #$0D
	BCS.b CODE_03AFD7
	TAX
	LDY.b #$FC
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	ASL
	ROL
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$15
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.l DATA_03AF4C,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$49
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$07
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
CODE_03AFD7:
	PLX
	LDY.b #$00
	LDA.b #$04
	JSL.l SMW_FinishOAMWrite_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	PHX
	LDX.b #$04
CODE_03AFE6:
	LDA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$00].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03AFE6
	PLX
	RTS

DATA_03B013:
	db $00,$10

DATA_03B015:
	db $00,$00

DATA_03B017:
	db $F8,$08

CODE_03B019:
	STZ.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w CODE_03B020
	INC.b !RAM_SMW_Misc_ScratchRAM02
CODE_03B020:
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$0A
CODE_03B022:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_03B02B
	DEY
	BPL.b CODE_03B022
	RTS

CODE_03B02B:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr0A2_MechaKoopa
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$10
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_03B013,x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	ADC.w DATA_03B015,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDY.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w DATA_03B017,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$C0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	PLX
	RTS

DATA_03B074:
	db $40,$C0

DATA_03B076:
	db $10,$F0

CODE_03B078:
	LDA.b !RAM_SMW_Misc_M7AngleLo
	CMP.b #$20
	BNE.b Return03B0DB
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	CMP.b #$07
	BCC.b Return03B0F2
	LDA.b !RAM_SMW_Misc_M7RotationLo
	ORA.b !RAM_SMW_Misc_M7RotationHi
	BNE.b Return03B0F2
	JSR.w CODE_03B0DC
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeAttackPhase1,x
	BNE.b Return03B0DB
	LDA.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping24
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	BCC.b CODE_03B0BD
	JSR.w CODE_03B0D6
	STZ.b !RAM_SMW_Player_YSpeed
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeMechaKoopaThrow
	ORA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_WaitBeforeBowlingBallDrop
	BEQ.b CODE_03B0B3
	LDA.w DATA_03B076,y
	BRA.b CODE_03B0B6

CODE_03B0B3:
	LDA.w DATA_03B074,y
CODE_03B0B6:
	STA.b !RAM_SMW_Player_XSpeed
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
CODE_03B0BD:
	INC.w !RAM_SMW_NorSpr_PropertyBits1662,x
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	BCC.b CODE_03B0C9
	JSR.w CODE_03B0D2
CODE_03B0C9:
	INC.w !RAM_SMW_NorSpr_PropertyBits1662,x
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	BCC.b Return03B0DB
CODE_03B0D2:
	JSL.l SMW_DamagePlayer_Hurt
CODE_03B0D6:
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_DisableMarioContactTimer,x
Return03B0DB:
	RTS

CODE_03B0DC:
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$0A
CODE_03B0DE:
	PHY
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus09_Stunned
	BNE.b CODE_03B0EE
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,y
	BNE.b CODE_03B0EE
	JSR.w CODE_03B0F3
CODE_03B0EE:
	PLY
	DEY
	BPL.b CODE_03B0DE
Return03B0F2:
	RTS

CODE_03B0F3:
	PHX
	TYX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingB
	PLX
	LDA.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping24
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCS.b CODE_03B142
	INC.w !RAM_SMW_NorSpr_PropertyBits1662,x
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return03B160
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HurtStateTimer
	BNE.b Return03B160
	LDA.b #$4C
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HurtStateTimer
	STZ.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_TearDropYDispIndex
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	STA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_SongToPlayIndex
	LDA.b #!Define_SMW_Sound1DFC_StunEnemy	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_CurrentState,x
	CMP.b #$09
	BNE.b CODE_03B142
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_HPForCurrentPhase,x
	CMP.b #$01
	BNE.b CODE_03B142
	PHY
	JSL.l SMW_DespawnNonBossSprites_Main
	PLY
CODE_03B142:
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	PHX
	LDX.b #$10
	LDA.w !RAM_SMW_NorSpr_YSpeed,y
	BMI.b CODE_03B151
	LDX.b #$D0
CODE_03B151:
	TXA
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	TYX
	JSL.l SMW_SpawnContactEffectFromSide_Main
	PLX
Return03B160:
	RTS
namespace off
endmacro

macro ROUTINE_RT05_SMW_NorSpr0A0_ActivateBowserBattle_Status08(Address)
namespace SMW_NorSpr0A0_ActivateBowserBattle_Status08
%InsertMacroAtXPosition(<Address>)

GFXRt:
	JSR.w DrawItemBox
	JSR.w DrawCastleRoof
	RTS

; Bowser Battle Item Box Frame: X position of each corner of the frame (in
; the order upper-left, upper-right, lower-left, lower-right)
ItemBoxXPos:
	db ((!RAM_SMW_Misc_StatusBar_ItemBox-!RAM_SMW_Misc_StatusBarTilemap)*$08)+$10
	db ((!RAM_SMW_Misc_StatusBar_ItemBox-!RAM_SMW_Misc_StatusBarTilemap)*$08)+$20
	db ((!RAM_SMW_Misc_StatusBar_ItemBox-!RAM_SMW_Misc_StatusBarTilemap)*$08)+$10
	db ((!RAM_SMW_Misc_StatusBar_ItemBox-!RAM_SMW_Misc_StatusBarTilemap)*$08)+$20

; Bowser Battle Item Box Frame: Y position of each corner of the frame (same
; order as above)
ItemBoxYPos:
	db $07,$07,$17,$17

; Bowser Battle Item Box Frame: Attributes for each corner of the frame
; (same order as above)
ItemBoxProp:
	db $37,$77,$B7,$F7

DrawItemBox:
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_EndOfBattleFlag
	BEQ.b CODE_03B457
	STZ.w !RAM_SMW_Player_CurrentItemBox
CODE_03B457:
	LDA.w !RAM_SMW_Player_CurrentItemBox
	BEQ.b Return03B48B
	PHX
	LDX.b #$03
	LDY.b #!OAM_SMW_NorSpr0A0_ActivateBowserBattle_ItemBox*$04
CODE_03B461:
	LDA.w ItemBoxXPos,x
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w ItemBoxYPos,x
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b #$43
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.w ItemBoxProp,x
	STA.w SMW_OAMBuffer[$00].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03B461
	PLX
Return03B48B:
	RTS

; X-coordinates of 1st and 3rd rows of Bowser's castle roof
RoofXPos:
	db $00,$30,$60,$90,$C0,$F0,$00,$30
	db $40,$50,$60,$90,$A0,$B0,$C0,$F0

RoofYPos:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	db $C0,$C0,$C0,$C0,$C0,$C0,$E0,$E0
	db $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
else
	; Y-coordinates of 1st and 3rd rows of castle roof
	db $B0,$B0,$B0,$B0,$B0,$B0,$D0,$D0	;!
	db $D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0	;!
endif

DrawCastleRoof:
	PHX
	LDY.b #!OAM_SMW_NorSpr0A0_ActivateBowserBattle_CastleRoofDuringFight*$04
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_EndOfBattleFlag
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	CMP.b #$01
	LDX.b #$10
	BCC.b CODE_03B4BF
	LDY.b #!OAM_SMW_NorSpr0A0_ActivateBowserBattle_CastleRoofDuringEnding*$04
	DEX
CODE_03B4BF:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDA.b #$D0
else
	LDA.b #$C0
endif
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$08
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$0D
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03B4BF
	LDX.b #$0F
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	BNE.b CODE_03B532
	LDY.b #$14
CODE_03B4FA:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l RoofXPos,x
else
	LDA.w RoofXPos,x
endif
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$00].XDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l RoofYPos,x
else
	LDA.w RoofYPos,x
endif
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b #$08
	CPX.b #$06
	BCS.b CODE_03B514
	LDA.b #$03
CODE_03B514:
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b #$0D
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03B4FA
	BRA.b CODE_03B56A

CODE_03B532:
	LDY.b #$50
CODE_03B534:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l RoofXPos,x
else
	LDA.w RoofXPos,x
endif
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l RoofYPos,x
else
	LDA.w RoofYPos,x
endif
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$08
	CPX.b #$06
	BCS.b CODE_03B54E
	LDA.b #$03
CODE_03B54E:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$0D
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03B534
CODE_03B56A:
	PLX
	RTS
namespace off
endmacro

macro ROUTINE_RT06_SMW_NorSpr0A0_ActivateBowserBattle_Status08(Address)
namespace SMW_NorSpr0A0_ActivateBowserBattle_Status08
%InsertMacroAtXPosition(<Address>)

BowserPaletteTableIndex:
	db SMW_GlobalPalettes_Bowser_Normal-SMW_GlobalPalettes_Bowser, SMW_GlobalPalettes_Bowser_Fade01-SMW_GlobalPalettes_Bowser
	db SMW_GlobalPalettes_Bowser_Fade02-SMW_GlobalPalettes_Bowser, SMW_GlobalPalettes_Bowser_Fade03-SMW_GlobalPalettes_Bowser
	db SMW_GlobalPalettes_Bowser_Fade04-SMW_GlobalPalettes_Bowser, SMW_GlobalPalettes_Bowser_Fade05-SMW_GlobalPalettes_Bowser
	db SMW_GlobalPalettes_Bowser_Fade06-SMW_GlobalPalettes_Bowser, SMW_GlobalPalettes_Bowser_Fade07-SMW_GlobalPalettes_Bowser

UpdatePaletteAndLightningAnimation:
;$03DFCC
	PHX
	LDX.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
	LDA.b #$10
	STA.w !RAM_SMW_Palettes_DynamicPaletteBytesToUpload,x
	STZ.w !RAM_SMW_Palettes_DynamicPaletteCGRAMAddress,x
	STZ.w !RAM_SMW_Palettes_DynamicPaletteColors,x
	STZ.w !RAM_SMW_Palettes_DynamicPaletteColors+$01,x
	TXY
	LDX.w !RAM_SMW_Palettes_LightningFlashColorIndex
	BNE.b CODE_03E01B
	LDA.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_EndOfBattleFlag
	BEQ.b CODE_03DFF0
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Palettes_BackgroundColorLo
	BRA.b CODE_03E031

CODE_03DFF0:
	LDA.b !RAM_SMW_Counter_LocalFrames	; Accum (8 bit) herr
	LSR
	BCC.b CODE_03E036
	DEC.w !RAM_SMW_Timer_WaitBeforeNextLightningFlash
	BNE.b CODE_03E036
	TAX
	LDA.l SMW_OverworldLightningAndRandomCloudSpawning_DATA_04F700+$08,x
	AND.b #$07
	TAX
	LDA.l SMW_OverworldLightningAndRandomCloudSpawning_DATA_04F6F8,x
	STA.w !RAM_SMW_Timer_WaitBeforeNextLightningFlash
	LDA.l SMW_OverworldLightningAndRandomCloudSpawning_DATA_04F700,x
	STA.w !RAM_SMW_Palettes_LightningFlashColorIndex
	TAX
	LDA.b #$08
	STA.w !RAM_SMW_Timer_LightningFrameDuration
	; Lightning sound FX for Bowser battle. Change to EA EA EA EA EA to disable
	; noise.
	LDA.b #!Define_SMW_Sound1DFC_Thunder
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
CODE_03E01B:
	DEC.w !RAM_SMW_Timer_LightningFrameDuration
	BPL.b CODE_03E028
	DEC.w !RAM_SMW_Palettes_LightningFlashColorIndex
	LDA.b #$04
	STA.w !RAM_SMW_Timer_LightningFrameDuration
CODE_03E028:
	TXA
	ASL
	TAX
	REP.b #$20			; A->16
	; Code for loading BG flashes during Bowser battle. Change to EA EA EA EA
	; EA EA EA to disable.
	LDA.l SMW_GlobalPalettes_BowserLightningFlash,x
CODE_03E031:
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors,y
	SEP.b #$20			; A->8
CODE_03E036:
	LDX.w !RAM_SMW_NorSpr0A0_ActivateBowserBattle_PaletteIndex
	LDA.l BowserPaletteTableIndex,x
	TAX
	LDA.b #$0E
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_03E042:
	LDA.l SMW_GlobalPalettes_Bowser,x
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors+$02,y
	INX
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_03E042
	TYX
	STZ.w !RAM_SMW_Palettes_DynamicPaletteColors+$02,x
	INX
	INX
	INX
	INX
	STX.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
	PLX
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0A1_BowserBowlingBall_Status08(Address)
namespace SMW_NorSpr0A1_BowserBowlingBall_Status08
%InsertMacroAtXPosition(<Address>)

; Bowling ball's X speed. (Default: Right: $10, Left: $F0)
XSpeed:
	db $10,$F0

Bank03:
;$03B163
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return03B1D4
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$40
	BPL.b CODE_03B186
	CLC
	ADC.b #$03
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	BRA.b CODE_03B18A

CODE_03B186:
	LDA.b #$40
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_03B18A:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_03B1C5
	LDA.w !RAM_SMW_NorSpr_YPosHi,x					;\ Note: This sprite is hardcoded to "land" at a specific Y position regardless of whether there is ground there or not.
	BMI.b CODE_03B1C5						;|
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;|
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)	;|
	CMP.b #$C0							;|
else									;|
	CMP.b #$B0							;|
endif									;|
	BCC.b CODE_03B1C5						;|
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)	;|
	LDA.b #$C0							;|
else									;|
	LDA.b #$B0							;|
endif									;|
	STA.b !RAM_SMW_NorSpr_YPosLo_x					;/
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$3E
	BCC.b CODE_03B1AD
	LDY.b #!Define_SMW_Sound1DFC_YoshiStompsEnemy	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh3
	LDY.b #$20			; \ Set ground shake timer
	STY.w !RAM_SMW_Timer_ShakeLayer1
CODE_03B1AD:
	CMP.b #$08
	BCC.b CODE_03B1B6
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
CODE_03B1B6:
	JSR.w MakeBallBounce
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BNE.b CODE_03B1C5
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_03B1C5:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b Return03B1D4
	BMI.b CODE_03B1D1
	DEC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	DEC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
CODE_03B1D1:
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
Return03B1D4:
	RTS

XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00
	db $10,$00,$00,$F8

YDisp:
	db $E2,$E2,$E2,$F2,$F2,$F2,$02,$02
	db $02,$02,$02,$EA

; Sprite tilemap: Bowser's Steel Ball
Tiles:
	db $45,$47,$45,$65,$66,$65,$45,$47
	db $45,$39,$38,$63

Prop:
	db $0D,$0D,$4D,$0D,$0D,$4D,$8D,$8D
	db $CD,$0D,$0D,$0D

TileSize:
	db $02,$02,$02,$02,$02,$02,$02,$02
	db $02,$00,$00,$02

XDisp2:
	db $04,$0D,$10,$0D,$04,$FB,$F8,$FB

YDisp2:
	db $00,$FD,$F4,$EB,$E8,$EB,$F4,$FD

GFXRt:
	LDA.b #$70
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	JSR.w SMW_GetDrawInfo_Bank03
	PHX
	LDX.b #$0B
CODE_03B22C:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w TileSize,x
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03B22C
	PLX
	PHX
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LSR
	LSR
	LSR
	AND.b #$07
	PHA
	TAX
	LDA.w SMW_OAMBuffer[$41].XDisp,y
	CLC
	ADC.w XDisp2,x
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.w SMW_OAMBuffer[$41].YDisp,y
	CLC
	ADC.w YDisp2,x
	STA.w SMW_OAMBuffer[$41].YDisp,y
	PLA
	CLC
	ADC.b #$02
	AND.b #$07
	TAX
	LDA.w SMW_OAMBuffer[$42].XDisp,y
	CLC
	ADC.w XDisp2,x
	STA.w SMW_OAMBuffer[$42].XDisp,y
	LDA.w SMW_OAMBuffer[$42].YDisp,y
	CLC
	ADC.w YDisp2,x
	STA.w SMW_OAMBuffer[$42].YDisp,y
	PLX
	LDA.b #$0B
	LDY.b #$FF
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr0A1_BowserBowlingBall_Status08(Address)
namespace SMW_NorSpr0A1_BowserBowlingBall_Status08
%InsertMacroAtXPosition(<Address>)

BounceYSpeed:
	db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
	db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
	db $E8,$E8,$E8

	db $00,$00,$00,$00,$FE,$FC,$F8,$EC
	db $EC,$EC,$E8,$E4,$E0,$DC,$D8,$D4
	db $D0,$CC,$C8

MakeBallBounce:
;$03B7F8
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	PHA
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	PLA
	LSR
	LSR
	TAY
	LDA.b !RAM_SMW_NorSpr_SpriteID_x				;\ Optimization: Sprite 0A1 is the only sprite that calls this routine.
	CMP.b #!Define_SMW_SpriteID_NorSpr0A1_BowserBowlingBall		;| Perhaps Nintendo planned on having other sprites call this?
	BNE.b CODE_03B80C						;/
	TYA
	CLC
	ADC.b #$13
	TAY
CODE_03B80C:
	LDA.w BounceYSpeed,y
	LDY.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	BMI.b Return03B816
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return03B816:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0A2_MechaKoopa_Status08(Address)
namespace SMW_NorSpr0A2_MechaKoopa_Status08
%InsertMacroAtXPosition(<Address>)

XSpeed:
	db $08,$F8

Bank03:
	JSL.l GFXRt
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b Return03B306
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return03B306
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSL.l SMW_HandleNormalSpriteGravity_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_03B2E3
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_NorSpr0A2_MechaKoopa_WaitBeforeTurningAround,x
	INC.b !RAM_SMW_NorSpr0A2_MechaKoopa_WaitBeforeTurningAround,x
	AND.b #$3F
	BNE.b CODE_03B2E3
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_03B2E3:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_03B2F9
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_03B2F9:
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	AND.b #$0C
	LSR
	LSR
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
Return03B306:
	RTS

GFXRt:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w MechakoopaGFXRt
	PLB
	RTL

; Mechakoopa tile horizontal displacement table left
MechakoopaXDisp:
	db $F8,$08,$F8,$00,$08,$00,$10,$00

; Mechakoopa tile vertical displacement table (6 animation frames, each 4
; bytes)
MechakoopaYDisp:
	db $F8,$F8,$08,$00,$F9,$F9,$09,$00
	db $F8,$F8,$08,$00,$F9,$F9,$09,$00
	db $FD,$00,$05,$00,$00,$00,$08,$00

; Mechakoopa tile table (6 animation frames, each 4 bytes)
MechakoopaTiles:
	db $40,$42,$60,$51,$40,$42,$60,$0A
	db $40,$42,$60,$0C,$40,$42,$60,$0E
	db $00,$02,$10,$01,$00,$02,$10,$01

; Mechakoopa tiles' priority/flip left
MechakoopaProp:
	db $00,$00,$00,$00,$40,$40,$40,$40

; Mechakoopa tile sizes (00= 8x8, 02= 16x16)
MechakoopaTileSize:
	db $02,$00,$00,$02

; Mechakoopa Palette/gfx page used when coming to, #1
MechakoopaPalette:
	db $0B,$05

MechakoopaGFXRt:
	LDA.b #$0B
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LDA.w !RAM_SMW_NorSpr0A2_MechaKoopa_StunTimer,x
	BEQ.b CODE_03B37F
	LDY.b #$05
	CMP.b #$05
	BCC.b CODE_03B369
	CMP.b #$FA
	BCC.b CODE_03B36B
CODE_03B369:
	LDY.b #$04
CODE_03B36B:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr0A2_MechaKoopa_StunTimer,x
	CMP.b #$30
	BCS.b CODE_03B37F
	AND.b #$01
	TAY
	LDA.w MechakoopaPalette,y
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
CODE_03B37F:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	TYA
	CLC
	ADC.b #$0C
	TAY
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	ASL
	ASL
	EOR.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX
	LDX.b #$03
CODE_03B39F:
	PHX
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w MechakoopaTileSize,x
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	PLA
	PHA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w MechakoopaXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w MechakoopaProp,x
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
	PHA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.w MechakoopaTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w MechakoopaYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PLX
	DEY
	DEY
	DEY
	DEY
	DEX
	BPL.b CODE_03B39F
	PLX
	LDY.b #$FF
	LDA.b #$03
	JSL.l SMW_FinishOAMWrite_Main
	JSR.w KeyGFXRt
	RTS

; Mechakoopa Wind-up key horizontal displacement right
KeyXDisp:
	db $F9,$0F

; Mechakoopa Wind-up key palette/gfx page right
KeyProp:
	db $4D,$0D

; Mechakoopa Wind-up key tile table (4 animation frames, each 1 byte)
KeyTiles:
	db $70,$71,$72,$71

KeyGFXRt:
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$10
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	JSR.w SMW_GetDrawInfo_Bank03
	PHX
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LSR
	LSR
	AND.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w KeyXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b #$00
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w KeyProp,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w KeyTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDY.b #$00
	LDA.b #$00
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0A8_Blargg_Status08(Address)
namespace SMW_NorSpr0A8_Blargg_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return039F56
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	LDA.b !RAM_SMW_NorSpr0A8_Blargg_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

BlarggPtrs:
	dw HidingInLava
	dw EyesEmerging
	dw LookAround
	dw RetractEyes
	dw Attack

Return039F56:
	RTS

HidingInLava:
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr0A8_Blargg_PhaseTimer,x
	BNE.b Return039F8A
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$70
	CMP.b #$E0
	BCS.b Return039F8A
	LDA.b #$E3
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr0A8_Blargg_InitialXPosHi,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr0A8_Blargg_InitialXPosLo,x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr0A8_Blargg_InitialYPosHi,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr0A8_Blargg_InitialYPosLo,x
	JSR.w CODE_039FC0
	INC.b !RAM_SMW_NorSpr0A8_Blargg_CurrentState,x
Return039F8A:
	RTS

EyesEmerging:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$10
	BMI.b CODE_039F9B
	LDA.b #$50
	STA.w !RAM_SMW_NorSpr0A8_Blargg_PhaseTimer,x
	INC.b !RAM_SMW_NorSpr0A8_Blargg_CurrentState,x
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	RTS

CODE_039F9B:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	RTS

LookAround:
	LDA.w !RAM_SMW_NorSpr0A8_Blargg_PhaseTimer,x
	BNE.b CODE_039FB1
	INC.b !RAM_SMW_NorSpr0A8_Blargg_CurrentState,x
	LDA.b #$0A
	STA.w !RAM_SMW_NorSpr0A8_Blargg_PhaseTimer,x
	RTS

CODE_039FB1:
	CMP.b #$20
	BCC.b CODE_039FC0
	AND.b #$1F
	BNE.b Return039FC7
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	BRA.b CODE_039FC4

CODE_039FC0:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	TYA
CODE_039FC4:
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
Return039FC7:
	RTS

RetractEyes:
	LDA.w !RAM_SMW_NorSpr0A8_Blargg_PhaseTimer,x
	BEQ.b CODE_039FD6
	LDA.b #$20
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	RTS

CODE_039FD6:
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr0A8_Blargg_PhaseTimer,x
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$E2
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w CODE_03A045
	INC.b !RAM_SMW_NorSpr0A8_Blargg_CurrentState,x
	RTS

XSpeed:
	db $10,$F0

Attack:
	STZ.w !RAM_SMW_NorSpr0A8_Blargg_AttackingAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr0A8_Blargg_PhaseTimer,x
	BEQ.b CODE_03A002
	DEC
	BNE.b CODE_03A038
	LDA.b #!Define_SMW_Sound1DF9_BlarggRoar	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	JSR.w CODE_03A045
CODE_03A002:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$00
	BNE.b CODE_03A012
	INC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_03A012:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$20
	BMI.b CODE_03A038
	JSR.w CODE_03A045
	STZ.b !RAM_SMW_NorSpr0A8_Blargg_CurrentState,x
	LDA.w !RAM_SMW_NorSpr0A8_Blargg_InitialXPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.w !RAM_SMW_NorSpr0A8_Blargg_InitialXPosLo,x
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr0A8_Blargg_InitialYPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_NorSpr0A8_Blargg_InitialYPosLo,x
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr0A8_Blargg_PhaseTimer,x
CODE_03A038:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.b #$06
	CMP.b #$0C
	BCS.b Return03A044
	INC.w !RAM_SMW_NorSpr0A8_Blargg_AttackingAnimationFrame,x
Return03A044:
	RTS

CODE_03A045:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	SEC
	SBC.b #$0C
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSL.l SMW_SpawnLavaSplash_Main
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	RTS

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.b !RAM_SMW_NorSpr0A8_Blargg_CurrentState,x
	BEQ.b CODE_03A038
	CMP.b #$04
	BEQ.b CODE_03A09D
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$A0
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_OAMBuffer[$40].Prop,y
	AND.b #$CF
	STA.w SMW_OAMBuffer[$40].Prop,y
	RTS

XDisp:
	db $F8,$08,$F8,$08,$18,$08,$F8,$08
	db $F8,$E8

YDisp:
	db $F8,$F8,$08,$08,$08

; Blargg Tilemap
Tiles:
	db $A2,$A4,$C2,$C4,$A6,$A2,$A4,$E6
	db $C8,$A6

; Blargg palette/gfx page, right
Prop:
	db $45,$05

CODE_03A09D:
	LDA.w !RAM_SMW_NorSpr0A8_Blargg_AttackingAnimationFrame,x
	ASL
	ASL
	ADC.w !RAM_SMW_NorSpr0A8_Blargg_AttackingAnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX
	LDX.b #$04
CODE_03A0AF:
	PHX
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b CODE_03A0C3
	TXA
	CLC
	ADC.b #$05
	TAX
CODE_03A0C3:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w Prop,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_03A0AF
	PLX
	LDY.b #$02
	LDA.b #$04
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0A9_Reznor_Status01(Address)
namespace SMW_NorSpr0A9_Reznor_Status01
%InsertMacroAtXPosition(<Address>)

Bank03:
	CPX.b #!Define_SMW_StockMaxNormalSpriteSlot-$04
	BNE.b NotAlphaReznor
	LDA.b #$04
	STA.b !RAM_SMW_NorSpr0A9_Reznor_SpriteGFXToLoad,x
	JSL.l SMW_InitializeMode7TilemapsAndPalettes_Main
NotAlphaReznor:
	JSL.l SMW_GetRand_Main
	STA.w !RAM_SMW_NorSpr0A9_Reznor_WaitBeforeShootingFire,x
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0A9_Reznor_Status08(Address)
namespace SMW_NorSpr0A9_Reznor_Status08
%InsertMacroAtXPosition(<Address>)

; reznor starting position low byte (4 byte table)
ReznorStartPosLo:
	db $00,$80,$00,$80

; reznor starting position high byte (4 byte table)
ReznorStartPosHi:
	db $00,$00,$01,$01

ReboundSpeedX:
	db $20,$E0

Bank03:
if defined("Define_SMW_SA1")
	; SA-1 Pack: I'm pretty sure that $140F was meant to be used a flag
	; indicating that Reznor is on screen but SMW has a bug where it
	; increments every frame in which Reznor is present instead of just once,
	; which means it can wrap around to zero for one frame. This can cause
	; tiles to disappear among other problems for this patch so it is best to
	; fix the bug and set $140F to a fixed value so that it's always non-zero
	; during a Reznor fight.
	STA.w !RAM_SMW_Flag_ReznorRoomOAMIndexTimer
else
	INC.w !RAM_SMW_Flag_ReznorRoomOAMIndexTimer
endif
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b ReznorNotLocked
	JMP.w DrawReznor

ReznorNotLocked:
	CPX.b #!Define_SMW_StockMaxNormalSpriteSlot-$04
	BNE.b CODE_039910
	PHX
	; [22 0C D7 03] Change to [EA EA EA EA] to stop the bridge in the Reznor
	; battle from breaking.
	JSL.l BreakReznorBridge		; Break bridge when necessary
	LDA.b #$80			; \ Set radius for Reznor sign rotation
	STA.b !RAM_SMW_Mirror_M7CenterXPosLo
	STZ.b !RAM_SMW_Mirror_M7CenterXPosHi
if defined("Define_SMW_SA1")
	; SA-1 Pack: It seems reznor's sign is hard-coded to be in sprite slot 0.
	JSL.l REZNOR_SET
else
	LDX.b #$00
	LDA.b #$C0			; \ X position of Reznor sign
endif
	STA.b !RAM_SMW_NorSpr_XPosLo_Slot0
	STZ.w !RAM_SMW_NorSpr_XPosHi
	LDA.b #$B2			; \ Y position of Reznor sign
	STA.b !RAM_SMW_NorSpr_YPosLo_Slot0
	STZ.w !RAM_SMW_NorSpr_YPosHi
	LDA.b #$2C
	STA.w !RAM_SMW_Misc_Mode7TilemapIndex
	JSL.l SMW_UpdateMode7SpriteAnimations_Main	; Applies position changes to Reznor sign
	PLX				; Pull, X = sprite index
if defined("Define_SMW_SA1")
	JSL.l REZNOR_RESTORE
else
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_M7RotationLo	; \ Rotate 1 frame around the circle (clockwise)
endif
	; Change to [38 E9] to change rotation direction of the Reznor platform.
	CLC				; | $37,36 = 0 to 1FF, denotes circle position
	ADC.w #$0001
	AND.w #$01FF
	STA.b !RAM_SMW_Misc_M7RotationLo
	SEP.b #$20			; A->8
	CPX.b #!Define_SMW_StockMaxNormalSpriteSlot-$04
	BNE.b CODE_039910
	LDA.w !RAM_SMW_NorSpr0A9_Reznor_WaitBeforeEndingLevel,x	; \ Branch if timer to trigger level isn't set
	BEQ.b ReznorNoLevelEnd
	DEC
	BNE.b CODE_039910
	DEC.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene	; Prevent mario from walking at level end
	LDA.b #$FF			; \ Set time before return to overworld
	STA.w !RAM_SMW_Timer_EndLevel
	LDA.b #!Define_SMW_LevelMusic_PassedBoss
	STA.w !RAM_SMW_IO_MusicCh1	; / Play sound effect
	RTS

ReznorNoLevelEnd:
	LDA.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag+(!Define_SMW_StockMaxNormalSpriteSlot-$04)
	CLC
	ADC.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag+(!Define_SMW_StockMaxNormalSpriteSlot-$05)
	ADC.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag+(!Define_SMW_StockMaxNormalSpriteSlot-$06)
	ADC.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag+(!Define_SMW_StockMaxNormalSpriteSlot-$07)
	CMP.b #$04
	BNE.b CODE_039910
	LDA.b #$90			; | Set time to trigger level if all Reznors are dead
	STA.w !RAM_SMW_NorSpr0A9_Reznor_WaitBeforeEndingLevel,x
	JSL.l SMW_DespawnNonBossSprites_Main
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Zero out extended sprite table
	LDA.b #$00
CODE_03990A:
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	DEY
	BPL.b CODE_03990A
CODE_039910:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_03991A
	JMP.w DrawReznor

CODE_03991A:
	TXA				; \ Load Y with Reznor number (0-3)
	AND.b #$03
	TAY
	LDA.b !RAM_SMW_Misc_M7RotationLo
	CLC
	ADC.w ReznorStartPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | $01,00 = 0-1FF, position Reznors on the circle
	LDA.b !RAM_SMW_Misc_M7RotationHi
	ADC.w ReznorStartPosHi,y
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$30			; \ AXY->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; | Make Reznors turn clockwise rather than counter clockwise
	EOR.w #$01FF			; | ($01,00 = -1 * $01,00)
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0080
	AND.w #$01FF
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$00FF
	ASL
	TAX
	LDA.l SMW_CircleCoordinates_Main,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	AND.w #$00FF
	ASL
	TAX
	LDA.l SMW_CircleCoordinates_Main,x
	STA.b !RAM_SMW_Misc_ScratchRAM06
	SEP.b #$30			; AXY->8
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/03995E.asm"
namespace SMW_NorSpr0A9_Reznor_Status08
else
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b #$38
	LDY.b !RAM_SMW_Misc_ScratchRAM05
	BNE.b CODE_039978
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	ASL.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	ADC.b #$00
CODE_039978:
	LSR.b !RAM_SMW_Misc_ScratchRAM01
	BCC.b CODE_03997F
	EOR.b #$FF
	INC
CODE_03997F:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b #$38
	LDY.b !RAM_SMW_Misc_ScratchRAM07
	BNE.b CODE_03999B
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	ASL.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	ADC.b #$00
CODE_03999B:
	LSR.b !RAM_SMW_Misc_ScratchRAM03
	BCC.b CODE_0399A2
	EOR.b #$FF
	INC
CODE_0399A2:
	STA.b !RAM_SMW_Misc_ScratchRAM06
endif
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = sprite index
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_0399B2
	DEC.b !RAM_SMW_Misc_ScratchRAM00
CODE_0399B2:
	CLC
	ADC.b !RAM_SMW_Mirror_M7CenterXPosLo
	PHP
	CLC
	ADC.b #$40
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Mirror_M7CenterXPosHi
	ADC.b #$00
	PLP
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	SEC
	SBC.b !RAM_SMW_NorSpr_XPosLo_x
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	BPL.b CODE_0399D7
	DEC.b !RAM_SMW_Misc_ScratchRAM01
CODE_0399D7:
	CLC
	ADC.b !RAM_SMW_Mirror_M7CenterYPosLo
	PHP
	ADC.b #$20
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Mirror_M7CenterYPosHi
	ADC.b #$00
	PLP
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag,x	; \ If a Reznor is dead, make it's platform standable
	BEQ.b ReznorAlive
	; Change from 22 to AF to make the Reznor platforms non-standable
	; (fall-through) after Mario hits a Reznor from below.
	JSL.l SMW_SolidSpriteBlock_Main
	JMP.w DrawReznor

ReznorAlive:
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Don't try to spit fire if turning
	AND.b #$00
	ORA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BNE.b NoSetRznrFireTime
	INC.w !RAM_SMW_NorSpr0A9_Reznor_WaitBeforeShootingFire,x
	LDA.w !RAM_SMW_NorSpr0A9_Reznor_WaitBeforeShootingFire,x
	; Change to [D0 0A A9 xx 9D] to alter the rate at which Reznor shoots
	; fireballs. (xx is the speed: $00 is the original value, and $DF seems to
	; be the fastest value that will work correctly.)
	CMP.b #$00
	BNE.b NoSetRznrFireTime
	STZ.w !RAM_SMW_NorSpr0A9_Reznor_WaitBeforeShootingFire,x
	LDA.b #$40			; \ Set time to show firing graphic = 0A
	STA.w !RAM_SMW_NorSpr0A9_Reznor_FiringAnimationTimer,x
NoSetRznrFireTime:
	TXA
	ASL
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Counter_LocalFrames
	AND.b #$3F
	ORA.w !RAM_SMW_NorSpr0A9_Reznor_FiringAnimationTimer,x	; Firing
	ORA.w !RAM_SMW_NorSpr_TurnAroundTimer,x	; Turning
	BNE.b NoSetRenrTurnTime
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; \ if direction has changed since last frame...
	PHA
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	PLA
	CMP.w !RAM_SMW_NorSpr_FacingDirection,x
	BEQ.b NoSetRenrTurnTime
	LDA.b #$0A			; | ...set time to show turning graphic = 0A
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
NoSetRenrTurnTime:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x	; \ If disable interaction timer > 0, just draw Reznor
	BNE.b DrawReznor
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main	; \ Interact with mario
	BCC.b DrawReznor		; / If no contact, just draw Reznor
	LDA.b #$08			; \ Disable interaction timer = 08
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x	; / (eg. after hitting Reznor, or getting bounced by platform)
	LDA.b !RAM_SMW_Player_YPosLo	; \ Compare y positions to see if mario hit Reznor
	SEC
	SBC.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$ED
	BMI.b HitReznor
	CMP.b #$F2			; \ See if mario hit side of the platform
	BMI.b HitPlatSide
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b HitPlatSide
	LDA.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping29	; ??Something about boosting mario on platform??
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	LDA.b #$0F			; \ Time to bounce platform = 0F
	STA.w !RAM_SMW_NorSpr0A9_Reznor_PlatformBounceTimer,x
	LDA.b #$10			; \ Set mario's y speed to rebound down off platform
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b #!Define_SMW_Sound1DF9_HitHead
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	BRA.b DrawReznor

HitPlatSide:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X	; \ Set mario to bounce back
	LDA.w ReboundSpeedX,y		; | (hit side of platform?)
	STA.b !RAM_SMW_Player_XSpeed
	BRA.b DrawReznor

HitReznor:
	JSL.l SMW_DamagePlayer_Hurt	; Hurt Mario
DrawReznor:
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x	; Set normal image
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	PHA
	LDY.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BEQ.b ReznorNoTurning
	CPY.b #$05
	BCC.b ReznorTurning
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
ReznorTurning:
	LDA.b #$02			; \ Set turning image
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
ReznorNoTurning:
	LDA.w !RAM_SMW_NorSpr0A9_Reznor_FiringAnimationTimer,x	; \ Shoot fire if "time to show firing image" == 20
	BEQ.b ReznorNoFiring
	CMP.b #$20			; | (shows image for 20 frames after the fireball is shot)
	BNE.b ReznorFiring
	JSR.w ReznorFireRt
ReznorFiring:
	LDA.b #$01			; \ Set firing image
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
ReznorNoFiring:
	JSR.w GFXRt			; Draw Reznor
	PLA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ If sprites locked, or mario already killed the Reznor on the platform, return
	ORA.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag,x
	BNE.b Return039AF7
	LDA.w !RAM_SMW_NorSpr0A9_Reznor_PlatformBounceTimer,x	; \ If time to bounce platform != 0C, return
	CMP.b #$0C			; | (causes delay between start of boucing platform and killing Reznor)
	BNE.b Return039AF7
	LDA.b #!Define_SMW_Sound1DF9_KickShell
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	STZ.w !RAM_SMW_NorSpr0A9_Reznor_FiringAnimationTimer,x	; Prevent from throwing fire after death
	INC.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag,x	; Record a hit on Reznor
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Load Y with a free sprite index for dead Reznor
	BMI.b Return039AF7		; / Return if no free index
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Set status to being killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr0A9_Reznor	; \ Sprite to use for dead Reznor
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Transfer x position to dead Reznor
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ Transfer y position to dead Reznor
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX				; | Before: X must have index of sprite being generated
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; /  Routine clears all old sprite values and loads in new values for the 6 main sprite tables
	LDA.b #$C0			; \ Set y speed for Reznor's bounce off the platform
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	PLX				; pull, X = sprite index
Return039AF7:
	RTS

ReznorFireRt:
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ find a free extended sprite slot, return if all full
CODE_039AFA:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b FoundRznrFireSlot
	DEY
	BPL.b CODE_039AFA
	RTS				; / Return if no free slots

FoundRznrFireSlot:
	LDA.b #!Define_SMW_Sound1DF9_MagicShoot
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	LDA.b #!Define_SMW_SpriteID_ExtSpr02_ReznorFireball	; \ Extended sprite = Reznor fireball
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	SEC
	SBC.b #$08
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	SEC
	SBC.b #$14
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b #$10
	JSR.w SMW_AimTowardsPlayer_Bank03
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_ExtSpr_YSpeed,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
	RTS

XDisp:
	db $00,$F0,$00,$F0,$F0,$00,$F0,$00

YDisp:
	db $E0,$E0,$F0,$F0

; Reznor tilemap (4 bytes regular reznor, 4 bytes shooting fireball, 4 bytes
; turning)
Tiles:
	db $40,$42,$60,$62,$44,$46,$64,$66
	db $28,$28,$48,$48

; Reznor palette map (4 bytes regular reznor, 4 bytes shooting fireball, 4
; bytes turning)
Prop:
	db $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F
	db $7F,$3F,$7F,$3F

GFXRt:
	LDA.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag,x	; \ if the reznor is dead, only draw the platform
	BNE.b DrawReznorPlats
	JSR.w SMW_GetDrawInfo_Bank03	; after: Y = index to sprite tile map, $00 = sprite x, $01 = sprite y
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x	; \ $03 = index to frame start (frame to show * 4 tiles per frame)
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; \ $02 = direction index
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX
	LDX.b #$03
RznrGfxLoopStart:
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CMP.b #$08
	BCS.b CODE_039B99
	TXA
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	TAX
CODE_039B99:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX
	TXA
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.w Tiles,x			; \ set tile
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x			; \ set palette/properties
	CPX.b #$08			; | if turning, don't flip
	BCS.b NoReznorGfxFlip
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; | if direction = 0, don't flip
	BNE.b NoReznorGfxFlip
	EOR.b #$40
NoReznorGfxFlip:
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX				; \ pull, X = current tile of the frame we're drawing
	INY				; | Increase index to sprite tile map ($300)...
	INY				; |    ...we wrote 4 bytes...
	INY				; |    ...so increment 4 times
	INY
	DEX				; | Go to next tile of frame and loop
	BPL.b RznrGfxLoopStart
	PLX
	LDY.b #$02			; | Y = 02 (All 16x16 tiles)
	LDA.b #$03			; | A = number of tiles drawn - 1
	JSL.l SMW_FinishOAMWrite_Main	; / Don't draw if offscreen
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus02_Dead
	BEQ.b Return039BE2
DrawReznorPlats:
	JSR.w PlatformGFXRt
Return039BE2:
	RTS

PlatformYDisp:
	db $00,$03,$04,$05,$05,$04,$03,$00

PlatformGFXRt:
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$10
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr0A9_Reznor_PlatformBounceTimer,x
	LSR
	PHY
	TAY
	LDA.w PlatformYDisp,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PLY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$41].XDisp,y
	SEC
	SBC.b #$10
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.b #$4E			; \ Tile of reznor platform...
	STA.w SMW_OAMBuffer[$40].Tile,y	; | ...store left side
	STA.w SMW_OAMBuffer[$41].Tile,y	; /  ...store right side
	LDA.b #$33			; \ Palette of reznor platform...
	STA.w SMW_OAMBuffer[$40].Prop,y
	ORA.b #$40			; | ...flip right side
	STA.w SMW_OAMBuffer[$41].Prop,y
	LDY.b #$02
	LDA.b #$01			; | A = number of tiles drawn - 1
	JSL.l SMW_FinishOAMWrite_Main	; / Don't draw if offscreen
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr0A9_Reznor_Status08(Address)
namespace SMW_NorSpr0A9_Reznor_Status08
%InsertMacroAtXPosition(<Address>)

DATA_03D700:
	db $B0,$A0,$90,$80,$70,$60,$50,$40
	db $30,$20,$10,$00

BreakReznorBridge:
	PHX
	LDA.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag+(!Define_SMW_StockMaxNormalSpriteSlot-$07)	; \ Return if less than 2 reznors killed
	CLC
	ADC.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag+(!Define_SMW_StockMaxNormalSpriteSlot-$06)
	ADC.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag+(!Define_SMW_StockMaxNormalSpriteSlot-$05)
	ADC.w !RAM_SMW_NorSpr0A9_Reznor_IsDeadFlag+(!Define_SMW_StockMaxNormalSpriteSlot-$04)
	CMP.b #$02
	BCC.b CODE_03D757
	LDX.w !RAM_SMW_Counter_NumberOfBrokenReznorBridgeTiles
	CPX.b #$0C
	BCS.b CODE_03D757
	LDA.l DATA_03D700,x
	STA.b !RAM_SMW_Blocks_XPosLo
	STZ.b !RAM_SMW_Blocks_XPosHi
	LDA.b #$B0
	STA.b !RAM_SMW_Blocks_YPosLo
	STZ.b !RAM_SMW_Blocks_YPosHi
	LDA.w !RAM_SMW_Timer_ReznorBridgeBreaking
	BEQ.b CODE_03D74A
	CMP.b #$3C
	BNE.b CODE_03D757
	JSR.w CODE_03D77F
	JSR.w CODE_03D759
	JSR.w CODE_03D77F
	INC.w !RAM_SMW_Counter_NumberOfBrokenReznorBridgeTiles
	BRA.b CODE_03D757

CODE_03D74A:
	JSR.w CODE_03D766
	LDA.b #$40
	STA.w !RAM_SMW_Timer_ReznorBridgeBreaking
	LDA.b #!Define_SMW_Sound1DFC_BreakBlock
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
CODE_03D757:
	PLX
	RTL

CODE_03D759:
	REP.b #$20			; A->16
	LDA.w #$0170
	SEC
	SBC.b !RAM_SMW_Blocks_XPosLo
	STA.b !RAM_SMW_Blocks_XPosLo
	SEP.b #$20			; A->8
	RTS

CODE_03D766:
	JSR.w CODE_03D76C
	JSR.w CODE_03D759
CODE_03D76C:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Blocks_XPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.w #$0100
	SEP.b #$20			; A->8
	BCS.b Return03D77E
	JSL.l SMW_SpawnSmokePuff_Main
Return03D77E:
	RTS

CODE_03D77F:
	LDA.b !RAM_SMW_Blocks_XPosLo
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LSR
	ORA.b !RAM_SMW_Blocks_YPosLo
	REP.b #$20			; A->16
	AND.w #$00FF
	LDX.b !RAM_SMW_Blocks_XPosHi
	BEQ.b CODE_03D798
	CLC
	ADC.w #$01B0
	LDX.b #$04
CODE_03D798:
	STX.b !RAM_SMW_Misc_ScratchRAM00
	REP.b #$10			; XY->16
	TAX
	SEP.b #$20			; A->8
	LDA.b #$25
	STA.l !RAM_SMW_Blocks_Map16TableLo,x
	LDA.b #$00
	STA.l !RAM_SMW_Blocks_Map16TableHi,x
if defined("Define_SMW_SA1")
	JML.l ReznorFix
	RTS
	db $7F	; the tail of the LDA.l below, which the hijack leaves unreached
else
	REP.b #$20			; A->16
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
endif
	TAX
	LDA.w #$C05A
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	ORA.w #$2000
	STA.l SMW_StripeImageUploadTable[$03].LowByte,x
	LDA.w #$0240
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	STA.l SMW_StripeImageUploadTable[$04].LowByte,x
	LDA.w #$38FC
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	STA.l SMW_StripeImageUploadTable[$05].LowByte,x
	LDA.w #$00FF
	STA.l SMW_StripeImageUploadTable[$06].LowByte,x
	TXA
	CLC
	ADC.w #$000C
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0AA_Fishbone_Status08(Address)
namespace SMW_NorSpr0AA_Fishbone_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return03972A
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	TXA
	ASL
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$7F
	BNE.b CODE_039720
	JSL.l SMW_GetRand_Main
	AND.b #$01
	BNE.b CODE_039720
	LDA.b #$0C
	STA.w !RAM_SMW_NorSpr0AA_Fishbone_BlinkAnimationTimer,x
CODE_039720:
	LDA.b !RAM_SMW_NorSpr0AA_Fishbone_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

FishbonePtrs:
	dw Boosting
	dw SlowingDown

Return03972A:
	RTS

MaxXSpeed:
	db $10,$F0

XAcceleration:
	db $01,$FF

Boosting:
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	NOP										;Optimization: It seems that Nintendo may have originally had the fishbone animate slower.
	LSR
	AND.b #$01
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr0AA_Fishbone_PhaseTimer,x
	BEQ.b CODE_039756
	AND.b #$01
	BNE.b Return039755
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxXSpeed,y
	BEQ.b Return039755
	CLC
	ADC.w XAcceleration,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
Return039755:
	RTS

CODE_039756:
	INC.b !RAM_SMW_NorSpr0AA_Fishbone_CurrentState,x
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr0AA_Fishbone_PhaseTimer,x
	RTS

SlowingDown:
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr0AA_Fishbone_PhaseTimer,x
	BEQ.b CODE_039776
	AND.b #$03
	BNE.b Return039775
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b Return039775
	BPL.b CODE_039773
	INC.b !RAM_SMW_NorSpr_XSpeed,x
	RTS

CODE_039773:
	DEC.b !RAM_SMW_NorSpr_XSpeed,x
Return039775:
	RTS

CODE_039776:
	STZ.b !RAM_SMW_NorSpr0AA_Fishbone_CurrentState,x
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr0AA_Fishbone_PhaseTimer,x
	RTS

XDisp:
	db $F8,$F8,$10,$10

YDisp:
	db $00,$08

; Fishbone tail properties, YXPPCCCT. First two bytes are for the tail when
; the fishbone is heading into the right direction, the other two when
; heading into the left direction.
Prop:
	db $4D,$CD,$0D,$8D

; Tiles used by Fishbone's Tail
TailTiles:
	db $A3,$A3,$B3,$B3

GFXRt:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr0AA_Fishbone_BlinkAnimationTimer,x
	CMP.b #$01
	LDA.b #$A6
	BCC.b CODE_03979E
	LDA.b #$A8
CODE_03979E:
	STA.w SMW_OAMBuffer[$40].Tile,y
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	PHX
	LDX.b #$01
CODE_0397BD:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX
	TXA
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w Prop,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
	PHA
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.w TailTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_0397BD
	PLX
	LDY.b #$00
	LDA.b #$02
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0AB_Rex_Status08(Address)
namespace SMW_NorSpr0AB_Rex_Status08
%InsertMacroAtXPosition(<Address>)

; Normal rex walking speed
XSpeed:
	db $08,$F8,$10,$F0

Bank03:
;$039517
	JSR.w GFXRt			; Draw Rex gfx
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ If Rex status != 8...
	CMP.b #!Define_SMW_NorSprStatus08_Normal	; |   ... not (killed with spin jump [4] or star [2])
	BNE.b Return			; /    ... return
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ If sprites locked...
	BNE.b Return			; /    ... return
	LDA.w !RAM_SMW_NorSpr0AB_Rex_ShowSquishedStateTimer,x	; \ If Rex not defeated (timer to show remains > 0)...
	BEQ.b RexAlive			; /    ... goto RexAlive
	STA.w !RAM_SMW_NorSpr0AB_Rex_DisableCapeAndBounceSpriteContactTimer,x
	DEC				; |   If Rex remains don't disappear next frame...
	BNE.b Return			; /    ... return
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x	; This is the last frame to show remains, so set Rex status = 0
Return:
	RTS

RexAlive:
	JSR.w SMW_SubOffscreen_Bank03_Entry1	; Only process Rex while on screen
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x	; Increment number of frames Rex has been on sc
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x	; \ Calculate which frame to show:
	LSR
	LSR
	LDY.b !RAM_SMW_NorSpr0AB_Rex_StompCounter,x	; | Number of hits determines if smushed
	BEQ.b CODE_03954A
	AND.b #$01			; | Update every 8 cycles if smushed
	CLC
	ADC.b #$03			; | Show smushed frame
	BRA.b CODE_03954D

CODE_03954A:
	LSR
	AND.b #$01			; | Update every 16 cycles if normal
CODE_03954D:
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x	; / Write frame to show
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \  If sprite is not on ground...
	AND.b #$04			; |    ...(4 = on ground) ...
	BEQ.b RexInAir			; /     ...goto IN_AIR
	LDA.b #$10			; \  Y speed = 10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x	; Load, y = Rex direction, as index for speed
	LDA.b !RAM_SMW_NorSpr0AB_Rex_StompCounter,x	; \ If hits on Rex == 0...
	BEQ.b RexNoAdjustSpeed		; /    ...goto DONT_ADJUST_SPEED
	INY				; \ Increment y twice...
	INY				; /    ...in order to get speed for smushed Rex
RexNoAdjustSpeed:
	LDA.w XSpeed,y			; \ Load x speed from ROM...
	STA.b !RAM_SMW_NorSpr_XSpeed,x	; /    ...and store it
RexInAir:
	LDA.w !RAM_SMW_NorSpr0AB_Rex_WaitAfterFirstStomp,x	; \ If time to show half-smushed Rex > 0...
	BNE.b RexHalfSmushed		; /    ...goto HALF_SMUSHED
	JSL.l SMW_HandleNormalSpriteGravity_Main	; Update position based on speed values
RexHalfSmushed:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ If Rex is touching the side of an object...
	AND.b #$03
	BEQ.b CODE_039581
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01			; |    ... change Rex direction
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_039581:
	JSL.l SMW_CheckForNormalSpriteToNormalSpriteCollision_Main	; Interact with other sprites
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main	; Check for mario/Rex contact
	BCC.b NoRexContact		; (carry set = mario/Rex contact)
	LDA.w !RAM_SMW_Timer_StarPower	; \ If mario star timer > 0 ...
	BNE.b RexStarKill		; /    ... goto HAS_STAR
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x	; \ If Rex invincibility timer > 0 ...
	BNE.b NoRexContact		; /    ... goto NO_CONTACT
	LDA.b #$08			; \ Rex invincibility timer = $08
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.b !RAM_SMW_Player_YSpeed	; \  If mario's y speed < 10 ...
	CMP.b #$10			; |   ... Rex will hurt mario
	BMI.b RexWins
	JSR.w RexPoints			; Give mario points
	JSL.l SMW_BoostMarioSpeed_Main	; Set mario speed
	JSL.l SMW_SpawnContactEffectFromAbove_Main	; Display contact graphic
	LDA.w !RAM_SMW_Player_SpinJumpFlag	; \  If mario is spin jumping...
	ORA.w !RAM_SMW_Player_RidingYoshiFlag	; |    ... or on yoshi ...
	BNE.b RexSpinKill		; /     ... goto SPIN_KILL
	INC.b !RAM_SMW_NorSpr0AB_Rex_StompCounter,x	; Increment Rex hit counter
	LDA.b !RAM_SMW_NorSpr0AB_Rex_StompCounter,x	; \  If Rex hit counter == 2
	CMP.b #$02
	BNE.b SmushRex
	LDA.b #$20			; |    ... time to show defeated Rex = $20
	STA.w !RAM_SMW_NorSpr0AB_Rex_ShowSquishedStateTimer,x
	RTS

SmushRex:
	LDA.b #$0C			; \ Time to show semi-squashed Rex = $0C
	STA.w !RAM_SMW_NorSpr0AB_Rex_WaitAfterFirstStomp,x
	STZ.w !RAM_SMW_NorSpr_PropertyBits1662,x	; Change clipping area for squashed Rex
	RTS

RexWins:
	LDA.w !RAM_SMW_Timer_PlayerHurt	; \ If mario is invincible...
	ORA.w !RAM_SMW_Player_RidingYoshiFlag	; |  ... or mario on yoshi...
	BNE.b NoRexContact		; /   ... return
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X	; \  Set new Rex direction
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	JSL.l SMW_DamagePlayer_Hurt	; Hurt mario
NoRexContact:
	RTS

RexSpinKill:
	LDA.b #!Define_SMW_NorSprStatus04_SpinJumpKill	; \ Rex status = 4 (being killed by spin jump)
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$1F			; \ Set spin jump animation timer
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	JSL.l SMW_SpawnSpinJumpStars_Main	; Show star animation
	LDA.b #!Define_SMW_Sound1DF9_SpinJumpKill
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	RTS

RexStarKill:
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Rex status = 2 (being killed by star)
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$D0			; \ Set y speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X	; Get new Rex direction
	LDA.w RexKilledSpeed,y		; \ Set x speed based on Rex direction
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	INC.w !RAM_SMW_Player_StarKillCount	; Increment number consecutive enemies killed
	LDA.w !RAM_SMW_Player_StarKillCount
	CMP.b #$08			; | If consecutive enemies stomped >= 8, reset to 8
	BCC.b ADDR_039612
	LDA.b #$08
	STA.w !RAM_SMW_Player_StarKillCount
ADDR_039612:
	JSL.l SMW_GivePoints_Main	; Give mario points
	LDY.w !RAM_SMW_Player_StarKillCount
	CPY.b #$08			; | If consecutive enemies stomped < 8 ...
	BCS.b Return039623
	LDA.w StompSounds-$01,y		; |    ... play sound effect
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
Return039623:
	RTS

Return039624:
	RTS ; unused

RexKilledSpeed:
	db $F0,$10

Return039627:
	RTS ; unused

RexPoints:
	PHY
	LDA.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped
	CLC
	ADC.w !RAM_SMW_NorSpr_Table7E1626,x
	INC.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped	; Increase consecutive enemies stomped
	TAY
	INY
	CPY.b #$08			; \ If consecutive enemies stomped >= 8 ...
	BCS.b CODE_03963F		; /    ... don't play sound
	LDA.w StompSounds-$01,y
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_03963F:
	TYA
	CMP.b #$08			; | If consecutive enemies stomped >= 8, reset to 8
	BCC.b CODE_039646
	LDA.b #$08
CODE_039646:
	JSL.l SMW_GivePoints_Main	; Give mario points
	PLY
	RTS

; Rex tile horizontal displacement table left (0C entries)
XDisp:
	db $FC,$00,$FC,$00,$FE,$00,$00,$00
	db $00,$00,$00,$08,$04,$00,$04,$00
	db $02,$00,$00,$00,$00,$00,$08,$00

; Rex tile vertical displacement table (0C entries)
YDisp:
	db $F1,$00,$F0,$00,$F8,$00,$00,$00
	db $00,$00,$08,$08

; Sprite tilemap: Rex
Tiles:
	db $8A,$AA,$8A,$AC,$8A,$AA,$8C,$8C
	db $A8,$A8,$A2,$B2

; YXPPCCCT properties for sprite AB, Rex.
Prop:
	db $47,$07

GFXRt:
	LDA.w !RAM_SMW_NorSpr0AB_Rex_ShowSquishedStateTimer,x	; \ If time to show Rex remains > 0...
	BEQ.b Alive
	LDA.b #$05			; |    ...set Rex frame = 5 (fully squashed)
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
Alive:
	LDA.w !RAM_SMW_NorSpr0AB_Rex_WaitAfterFirstStomp,x	; \ If time to show half smushed Rex > 0...
	BEQ.b NotHalfSmushed
	LDA.b #$02			; |    ...set Rex frame = 2 (half smushed)
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
NotHalfSmushed:
	JSR.w SMW_GetDrawInfo_Bank03	; Y = index to sprite tile map, $00 = sprite x, $01 = sprite y
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	ASL				; | $03 = index to frame start (frame to show * 2 tile per frame)
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; \ $02 = sprite direction
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX				; Push sprite index
	LDX.b #$01			; Loop counter = (number of tiles per frame) - 1
Loop:
	PHX				; Push current tile number
	TXA				; \ X = index to horizontal displacement
	ORA.b !RAM_SMW_Misc_ScratchRAM03	; / get index of tile (index to first tile of frame + current tile number)
	PHA				; Push index of current tile
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; \ If facing right...
	BNE.b FaceLeft
	CLC
	ADC.b #$0C			; /    ...use row 2 of horizontal tile displacement table
FaceLeft:
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; | Tile x position = sprite x location ($00) + tile displacement
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLX				; \ Pull, X = index to vertical displacement and tilemap
	LDA.b !RAM_SMW_Misc_ScratchRAM01	; | Tile y position = sprite y location ($01) + tile displacement
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x			; \ Store tile
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w Prop,x			; | Get tile properties using sprite direction
	ORA.b !RAM_SMW_Sprites_TilePriority	; | Level properties
	STA.w SMW_OAMBuffer[$40].Prop,y	; / Store tile properties
	TYA				; \ Get index to sprite property map ($460)...
	LSR				; |    ...we use the sprite OAM index...
	LSR				; |    ...and divide by 4 because a 16x16 tile is 4 8x8 tiles
	LDX.b !RAM_SMW_Misc_ScratchRAM03	; | If index of frame start is > 0A
	CPX.b #$0A
	TAX
	LDA.b #$00			; |     ...show only an 8x8 tile
	BCS.b Set8x8Tile
	LDA.b #$02			; | Else show a full 16 x 16 tile
Set8x8Tile:
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x
	PLX				; \ Pull, X = current tile of the frame we're drawing
	INY				; | Increase index to sprite tile map ($300)...
	INY				; |    ...we wrote 4 times...
	INY				; |    ...so increment 4 times
	INY
	DEX				; | Go to next tile of frame and loop
	BPL.b Loop
	PLX				; Pull, X = sprite index
	LDY.b #$FF			; \ FF because we already wrote size to $0460
	LDA.b #$01			; | A = number of tiles drawn - 1
	JSL.l SMW_FinishOAMWrite_Main	; / Don't draw if offscreen
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr0AB_Rex_Status08(Address)
namespace SMW_NorSpr0AB_Rex_Status08
%InsertMacroAtXPosition(<Address>)

StompSounds:
	%INLINEDATATABLE_SMW_StompSoundTable()
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0AC_DownFirstWoodenSpike_Status08(Address)
namespace SMW_NorSpr0AC_DownFirstWoodenSpike_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return039440
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSR.w CODE_039488
	LDA.b !RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_CurrentState,x
	AND.b #$03
	JSL.l SMW_ExecutePtr_Absolute

DownFirstWoodenSpikePtrs:
	dw Retracting
	dw WaitingToExtend
	dw Extending
	dw WaitingToRetract

Return039440:
	RTS

Extending:
	LDA.w !RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_WaitBeforeNextPhase,x
	BEQ.b CODE_03944A
	LDA.b #$20
	BRA.b CODE_039475

CODE_03944A:
	LDA.b #$30
	BRA.b SetTimerNextState

WaitingToExtend:
	LDA.w !RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_WaitBeforeNextPhase,x
	BNE.b Return039457
	LDA.b #$18
	BRA.b SetTimerNextState

Return039457:
	RTS

Retracting:
	LDA.w !RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_WaitBeforeNextPhase,x
	BEQ.b CODE_039463
	LDA.b #$F0
	JSR.w CODE_039475
	RTS

CODE_039463:
	LDA.b #$30
SetTimerNextState:
	STA.w !RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_WaitBeforeNextPhase,x
	INC.b !RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_CurrentState,x	; Goto next state
	RTS

WaitingToRetract:
	LDA.w !RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_WaitBeforeNextPhase,x	; \ If stall timer us up,
	BNE.b Return039474		; | reset it to #$2F...
	LDA.b #$2F
	BRA.b SetTimerNextState		; | ...and goto next state

Return039474:
	RTS

CODE_039475:
	LDY.w !RAM_SMW_NorSpr0AC_DownFirstWoodenSpike_InitialMovementDirection,x
	BEQ.b CODE_03947D
	EOR.b #$FF
	INC
CODE_03947D:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	RTS

DATA_039484:
	db $01,$FF

DATA_039486:
	db $00,$FF

CODE_039488:
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	BCC.b Return0394B0
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$04
	CMP.b #$08
	BCS.b CODE_03949F
	JSL.l SMW_DamagePlayer_Hurt
	RTS

CODE_03949F:
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w DATA_039484,y
	STA.b !RAM_SMW_Player_XPosLo
	LDA.b !RAM_SMW_Player_XPosHi
	ADC.w DATA_039486,y
	STA.b !RAM_SMW_Player_XPosHi
	STZ.b !RAM_SMW_Player_XSpeed
Return0394B0:
	RTS

YDisp:
	db $00,$10,$20,$30,$40
	db $40,$30,$20,$10,$00

; Sprite tilemap: Wooden Castle Spike
Tiles:
	db $6A,$6A,$6A,$6A,$4A
	db $6A,$6A,$6A,$6A,$4A

; Properties (palette, gfx page etc.) of the wooden spike. The first 5 bytes
; for sprite AC the next 5 bytes for sprite AD. YXPPCCCT format.
Prop:
	db $81,$81,$81,$81,$81
	db $01,$01,$01,$01,$01

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	STZ.b !RAM_SMW_Misc_ScratchRAM02	; \ Set $02 based on sprite number
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0AD_UpDownFirstWoodenSpike
	BNE.b CODE_0394DE
	LDA.b #$05
	STA.b !RAM_SMW_Misc_ScratchRAM02
CODE_0394DE:
	PHX
	LDX.b #$04			; Draw 4 tiles:
Loop:
	PHX
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; \ Set X
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01	; \ Set Y
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x			; \ Set tile
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x			; \ Set gfs properties
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY				; \ We wrote 4 times, so increase index by 4
	INY
	INY
	INY
	PLX
	DEX
	BPL.b Loop
	PLX
	LDY.b #$02			; \ Wrote 5 16x16 tiles...
	LDA.b #$04
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr0AC_DownFirstWoodenSpike_Status08_Bank03, SMW_NorSpr0AD_UpDownFirstWoodenSpike_Status08_Bank03)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0AE_FishinBoo_Status08(Address)
namespace SMW_NorSpr0AE_FishinBoo_Status08
%InsertMacroAtXPosition(<Address>)

XAcceleration:
	db $01,$FF

MaxXSpeed:
	db $20,$E0

YAcceleration:
	db $01,$FF

MaxYSpeed:
	db $10,$F0

Bank03:
;$039065
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return0390EA
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BEQ.b CODE_039086
	INC.w !RAM_SMW_NorSpr_AnimationFrame,x
	CMP.b #$10
	BNE.b CODE_039086
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_039086:
	TXA
	ASL
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$3F
	ORA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BNE.b CODE_039099
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
CODE_039099:
	LDA.w !RAM_SMW_Timer_DisappearingSprite
	BEQ.b CODE_0390A2
	TYA
	EOR.b #$01
	TAY
CODE_0390A2:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	; \ If not at max X speed, accelerate
	CMP.w MaxXSpeed,y
	BEQ.b CODE_0390AF
	CLC
	ADC.w XAcceleration,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_0390AF:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_0390C9
	LDA.b !RAM_SMW_NorSpr0AE_FishinBoo_VerticalDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w YAcceleration,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w MaxYSpeed,y
	BNE.b CODE_0390C9
	INC.b !RAM_SMW_NorSpr0AE_FishinBoo_VerticalDirection,x
CODE_0390C9:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	PHA
	LDY.w !RAM_SMW_Timer_DisappearingSprite
	BNE.b CODE_0390DC
	LDA.w !RAM_SMW_Misc_Layer1XDisp
	ASL
	ASL
	ASL
	CLC
	ADC.b !RAM_SMW_NorSpr_XSpeed,x
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_0390DC:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	PLA
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	JSR.w CODE_0390F3
Return0390EA:
	RTS

DATA_0390EB:
	db $1A,$14,$EE,$F8

DATA_0390EF:
	db $00,$00,$FF,$FF

CODE_0390F3:
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	ASL
	ADC.w !RAM_SMW_NorSpr_AnimationFrame,x
	TAY
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w DATA_0390EB,y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.w DATA_0390EF,y
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$47
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return03912D
	JSL.l SMW_DamagePlayer_Hurt
Return03912D:
	RTS

XDisp:
	db $FB,$05,$00,$F2,$FD,$03,$EA,$EA
	db $EA,$EA

	db $FB,$05,$00,$FA,$FD,$03,$F2,$F2
	db $F2,$F2

	db $FB,$05,$00,$0E,$03,$FD,$16,$16
	db $16,$16
	
	db $FB,$05,$00,$06,$03,$FD,$0E,$0E
	db $0E,$0E

YDisp:
	db $0B,$0B,$00,$03,$0F,$0F,$13,$23
	db $33,$43

; Fishin' Boo Tilemap (cloud, face, rod, cloud, line)
Tiles1:
	db $60,$60,$64,$8A,$60,$60,$AC,$AC
	db $AC,$CE

Prop:
	db $04,$04,$0D,$09,$04,$04,$0D,$0D
	db $0D,$07

; Fishin' Boo's Flame Tilemap
Tiles2:
	db $CC,$CE,$CC,$CE

DATA_039178:
	db $00,$00,$40,$40

DATA_03917C:
	db $00,$40,$C0,$80

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX
	PHY
	LDX.b #$09
CODE_039191:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STZ.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w Tiles1,x
	CPX.b #$09
	BNE.b CODE_0391B4
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	PHX
	AND.b #$03
	TAX
	LDA.w DATA_039178,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w Tiles2,x
	PLX
CODE_0391B4:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b #$01
	LDA.w Prop,x
	EOR.b !RAM_SMW_Misc_ScratchRAM03
	ORA.b !RAM_SMW_Sprites_TilePriority
	BCS.b CODE_0391C6
	EOR.b #$40
CODE_0391C6:
	STA.w SMW_OAMBuffer[$40].Prop,y
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BEQ.b CODE_0391D3
	TXA
	CLC
	ADC.b #$0A
	TAX
CODE_0391D3:
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b CODE_0391DC
	TXA
	CLC
	ADC.b #$14
	TAX
CODE_0391DC:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_039191
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	AND.b #$03
	TAX
	PLY
	LDA.w DATA_03917C,x
	EOR.w SMW_OAMBuffer[$44].Prop,y
	STA.w SMW_OAMBuffer[$44].Prop,y
	STA.w SMW_OAMBuffer[$49].Prop,y
	EOR.b #$C0
	STA.w SMW_OAMBuffer[$45].Prop,y
	STA.w SMW_OAMBuffer[$48].Prop,y
	PLX
	LDY.b #$02
	LDA.b #$09
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSprXXX_ReflectingEnemy_Status08(Address)
namespace SMW_NorSprXXX_ReflectingEnemy_Status08
%InsertMacroAtXPosition(<Address>)

; Reflecting Stream of Boo Buddies tilemap (leader only)
BooStreamTiles:
	db $88,$8C,$8E,$A8,$AA,$AE,$88,$8C

ReflectingPodobooEntry:
	JSR.w ReflectingPodobooGFXRt
	BRA.b CODE_038FA4

ReflectingBooBuddiesEntry:
	LDA.b #$00
	LDY.b !RAM_SMW_NorSpr_XSpeed,x
	BPL.b CODE_038F81
	INC
CODE_038F81:
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_Counter_LocalFrames	;\ use frame counter to determine tile to use
	LSR				; |
	LSR				; |
	LSR				; |
	LSR				; |
	AND.b #$01			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	TXA				; |
	AND.b #$03			; |
	ASL				; |
	ORA.b !RAM_SMW_Misc_ScratchRAM00	; |
	PHX				; | preserve sprite index
	TAX				; |
	LDA.w BooStreamTiles,x		;|
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	PLX				; retrieve sprite index
CODE_038FA4:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;\ if sprite status not normal,
	CMP.b #!Define_SMW_NorSprStatus08_Normal	; |
	BNE.b Return038FF1		;/ return
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038FF1		;/ return
	TXA				;\ if sprite index or
	EOR.b !RAM_SMW_Counter_LocalFrames	; | frame counter mod 8 =/= 0
	AND.b #$07			; |
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x	; | or sprite is offscreen vertically,
	BNE.b CODE_038FC2		;/ branch
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	;\ if sprite number isn't B0 (boo stream),
	CMP.b #!Define_SMW_SpriteID_NorSpr0B0_ReflectingBooBuddies	; |
	BNE.b CODE_038FC2		;/ branch
	JSR.w SpawnTrailingBoo
CODE_038FC2:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main	; interact with objects
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_038FDC
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_038FDC:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;\ if touching object from top or bottom,
	AND.b #$0C			; |
	BEQ.b CODE_038FEA		; |
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	; | invert y speed
	EOR.b #$FF			; |
	INC				; |
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
CODE_038FEA:
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	JSR.w SMW_SubOffscreen_Bank03_Entry1
Return038FF1:
	RTS

ReflectingPodobooGFXRt:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDA.b !RAM_SMW_Counter_LocalFrames	;\ if frame counter < 0x40,
	LSR				; |
	LSR				; |
	LDA.b #$04			; |
	BCC.b +				;/ branch
	ASL
+:
	LDY.b !RAM_SMW_NorSpr_XSpeed,x	;\ if sprite moving to the left,
	BPL.b +				; |
	EOR.b #$40			;/ flip tile horizontally
+:
	LDY.b !RAM_SMW_NorSpr_YSpeed,x	;\ if sprite moving upwards,
	BMI.b +				; |
	EOR.b #$80			;/ flip tile vertically
+:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$AC			;\ set tile number
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	LDA.w SMW_OAMBuffer[$40].Prop,y	;\ set tile properties
	AND.b #$31			; | layer priority, sprite tile page 2
	ORA.b !RAM_SMW_Misc_ScratchRAM00	; | add in flip and palette from earlier
	STA.w SMW_OAMBuffer[$40].Prop,y	;/
	RTS

SpawnTrailingBoo:
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot	; setup loop
CODE_039022:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y	;\ check if current slot in extended sprite list is empty
	BEQ.b CODE_039037		; | if so, continue
	DEY				; | else, decrease loop counter
	BPL.b CODE_039022		;/ and go to start of loop
	DEC.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
	BPL.b ADDR_039034
	LDA.b #!Define_SMW_MaxMinorExtendedSpriteSlot
	STA.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
ADDR_039034:
	LDY.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
CODE_039037:
	LDA.b #!Define_SMW_SpriteID_MExtSpr0A_BooStream	;\ set extended sprite number: 0A (boo stream tile)
	STA.w !RAM_SMW_MExtSpr_SpriteID,y	;/
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\ set x position for extended sprite
	STA.w !RAM_SMW_MExtSpr_XPosLo,y	; |
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	; |
	STA.w !RAM_SMW_MExtSpr_XPosHi,y	;/
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\ set y position for extended sprite
	STA.w !RAM_SMW_MExtSpr_YPosLo,y	; |
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	; |
	STA.w !RAM_SMW_MExtSpr_YPosHi,y	;/
	LDA.b #$30			;\ set extended sprite timer
	STA.w !RAM_SMW_MExtSpr_Timer,y	;/
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;\ set extended sprite x speed
	STA.w !RAM_SMW_MExtSpr_XSpeed,y	;/
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0B1_CreateEatBlock_Status08(Address)
namespace SMW_NorSpr0B1_CreateEatBlock_Status08
%InsertMacroAtXPosition(<Address>)

; X speed of the Creating/Eating block
XSpeed:
	db $10,$F0,$00,$00,$00

; Y speed of the Creating/Eating block
YSpeed:
	db $00,$00,$10,$F0,$00

DATA_039279:
	db $00,$00,$01,$00,$02,$00,$00,$00
	db $03,$00,$00

Bank03:
;$039284
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	DEC
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$2E
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_OAMBuffer[$40].Prop,y
	AND.b #$3F
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDY.b #$02
	LDA.b #$00
	JSL.l SMW_FinishOAMWrite_Main
	LDY.b #$04
	LDA.w !RAM_SMW_Flag_ActiveCreateEatBlock
	CMP.b #$FF
	BEQ.b CODE_0392C0
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_0392BD
	LDA.b #!Define_SMW_Sound1DFA_Grinder	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
CODE_0392BD:
	LDY.w !RAM_SMW_NorSpr0B1_CreateEatBlock_MovementDirection,x
CODE_0392C0:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return03932B
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w YSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	STZ.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	JSL.l SMW_SolidSpriteBlock_Main
	LDA.w !RAM_SMW_Flag_ActiveCreateEatBlock
	CMP.b #$FF
	BEQ.b Return03932B
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	ORA.b !RAM_SMW_NorSpr_XPosLo_x
	AND.b #$0F
	BNE.b Return03932B
	LDA.w !RAM_SMW_NorSpr0B1_CreateEatBlock_BlockType,x
	BNE.b CODE_03932C
	DEC.w !RAM_SMW_NorSpr0B1_CreateEatBlock_TilesRemainingInCurrentDirection,x
	BMI.b CODE_0392F8
	BNE.b CODE_03931F
CODE_0392F8:
	LDY.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	CMP.b #!Define_SMW_Overworld_MainMap+$01
	LDY.w !RAM_SMW_NorSpr0B1_CreateEatBlock_CreatePathIndex,x
	INC.w !RAM_SMW_NorSpr0B1_CreateEatBlock_CreatePathIndex,x
	LDA.w SubmapMovementData,y
	BCS.b CODE_03930E
	LDA.w MainMapMovementData,y
CODE_03930E:
	STA.w !RAM_SMW_NorSpr0B1_CreateEatBlock_CurrentMovementData,x
	PHA
	LSR
	LSR
	LSR
	LSR
	STA.w !RAM_SMW_NorSpr0B1_CreateEatBlock_TilesRemainingInCurrentDirection,x
	PLA
	AND.b #$03
	STA.w !RAM_SMW_NorSpr0B1_CreateEatBlock_MovementDirection,x
CODE_03931F:
	LDA.b #$0D
	JSR.w GenTileFromSpr1
	LDA.w !RAM_SMW_NorSpr0B1_CreateEatBlock_CurrentMovementData,x
	CMP.b #$FF
	BEQ.b CODE_039387
Return03932B:
	RTS

CODE_03932C:
	LDA.b #$02
	JSR.w GenTileFromSpr1
	LDA.b #$01
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	PHA
	LDA.b #$FF
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	SEC
	SBC.b #$01
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	SEC
	SBC.b #$01
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	PLA
	ORA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	BEQ.b CODE_039387
	TAY
	LDA.w DATA_039279,y
	STA.w !RAM_SMW_NorSpr0B1_CreateEatBlock_MovementDirection,x
	RTS

CODE_039387:
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

; This generates a Map16 tile at the position of the sprite currently being
; processed. It is identical to the routine at $02B9A4, except that this one
; ends with RTS.
GenTileFromSpr1:
	STA.b !RAM_SMW_Blocks_Map16ToGenerate	; $9C = tile to generate
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $9A = Sprite X position
	STA.b !RAM_SMW_Blocks_XPosLo	; | for block creation
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $98 = Sprite Y position
	STA.b !RAM_SMW_Blocks_YPosLo	; | for block creation
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Blocks_YPosHi
	JSL.l SMW_GenerateTile_Main	; Generate the tile
	RTS

SubmapMovementData:
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)

	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)

	%SMW_CreateEatBlockPath(RIGHT, $0020) : %SMW_CreateEatBlockPath(DOWN, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(DOWN, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(DOWN, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(DOWN, $0001)

	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(DOWN, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(DOWN, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(DOWN, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $000D) : %SMW_CreateEatBlockPath(UP, $000C)

	%SMW_CreateEatBlockPath(LEFT, $0011) : %SMW_CreateEatBlockPath(DOWN, $0002)
	%SMW_CreateEatBlockPath(LEFT, $0023) : %SMW_CreateEatBlockPath(UP, $0004)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)

	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0033) : %SMW_CreateEatBlockPath(DOWN, $0003)
	%SMW_CreateEatBlockPath(RIGHT, $0006) : %SMW_CreateEatBlockPath(DOWN, $0003)
	%SMW_CreateEatBlockPath(LEFT, $0007) : %SMW_CreateEatBlockPath(DOWN, $0003)

	%SMW_CreateEatBlockPath(RIGHT, $0006) : %SMW_CreateEatBlockPath(DOWN, $0003)
	%SMW_CreateEatBlockPath(LEFT, $0006) : %SMW_CreateEatBlockPath(DOWN, $0003)
	%SMW_CreateEatBlockPath(RIGHT, $0007) : %SMW_CreateEatBlockPath(UP, $0003)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0003)

	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0003)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0003)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0003)
	%SMW_CreateEatBlockPath(RIGHT, $0010) : %SMW_CreateEatBlockPath(DOWN, $0014)

	%SMW_CreateEatBlockPath(END, $0000)

MainMapMovementData:
	%SMW_CreateEatBlockPath(RIGHT, $0008) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)

	%SMW_CreateEatBlockPath(RIGHT, $0006) : %SMW_CreateEatBlockPath(UP, $0002)
	%SMW_CreateEatBlockPath(RIGHT, $0002) : %SMW_CreateEatBlockPath(UP, $0002)
	%SMW_CreateEatBlockPath(RIGHT, $000B) : %SMW_CreateEatBlockPath(DOWN, $0002)
	%SMW_CreateEatBlockPath(LEFT, $000A) : %SMW_CreateEatBlockPath(DOWN, $0002)

	%SMW_CreateEatBlockPath(RIGHT, $000A) : %SMW_CreateEatBlockPath(DOWN, $0002)
	%SMW_CreateEatBlockPath(LEFT, $000A) : %SMW_CreateEatBlockPath(DOWN, $0002)
	%SMW_CreateEatBlockPath(RIGHT, $000C) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)

	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)

	%SMW_CreateEatBlockPath(RIGHT, $0001) : %SMW_CreateEatBlockPath(UP, $0001)
	%SMW_CreateEatBlockPath(RIGHT, $002D) : %SMW_CreateEatBlockPath(DOWN, $0005)
	%SMW_CreateEatBlockPath(RIGHT, $0005) : %SMW_CreateEatBlockPath(UP, $0003)
	%SMW_CreateEatBlockPath(RIGHT, $0005) : %SMW_CreateEatBlockPath(DOWN, $0003)

	%SMW_CreateEatBlockPath(RIGHT, $0005) : %SMW_CreateEatBlockPath(UP, $0003)
	%SMW_CreateEatBlockPath(RIGHT, $0005) : %SMW_CreateEatBlockPath(DOWN, $0002)
	%SMW_CreateEatBlockPath(RIGHT, $0005) : %SMW_CreateEatBlockPath(UP, $0003)
	%SMW_CreateEatBlockPath(RIGHT, $0014) : %SMW_CreateEatBlockPath(DOWN, $0008)

	%SMW_CreateEatBlockPath(END, $0000)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0B2_FallingSpike_Status08(Address)
namespace SMW_NorSpr0B2_FallingSpike_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$E0
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	DEC
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w !RAM_SMW_NorSpr0B2_FallingSpike_ShakingTimer,x
	BEQ.b CODE_039237
	LSR
	LSR
	AND.b #$01
	CLC
	ADC.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$40].XDisp,y
CODE_039237:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_03926C
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_HandleNormalSpriteGravity_Main
	LDA.b !RAM_SMW_NorSpr0B2_FallingSpike_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

FallingSpikePtrs:
	dw Waiting
	dw ShakeOrFall

Waiting:
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F					;\ Glitch: The spike will act like you're close to it if you're one screen away horizontally
	CLC									;| This should be 16-bit and CheckPlayerPositionRelativeToSprite_Bank03_X needs to check Mario's 16-bit position instead of 8-bit.
	ADC.b #$40								;|
	CMP.b #$80								;|
	BCS.b Return039261							;/
	INC.b !RAM_SMW_NorSpr0B2_FallingSpike_CurrentState,x
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$20
else
	LDA.b #$40
endif
	STA.w !RAM_SMW_NorSpr0B2_FallingSpike_ShakingTimer,x
Return039261:
	RTS

ShakeOrFall:
	LDA.w !RAM_SMW_NorSpr0B2_FallingSpike_ShakingTimer,x
	BNE.b CODE_03926C
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main			; Glitch: This sprite will not hurt Mario unless it's falling even though it looks like a spike
	RTS

CODE_03926C:
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0B3_BowserStatueFire_Status08(Address)
namespace SMW_NorSpr0B3_BowserStatueFire_Status08
%InsertMacroAtXPosition(<Address>)

; X speeds for the Bowser Statue fireball. Ordered right, left.
XSpeed:
	db $10,$F0

Bank03:
;$038EEC
	JSR.w GFXRt			; graphics routine
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038F06		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x	;\ use sprite direction to determine x speed
	LDA.w XSpeed,y			; |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
Return038F06:
	RTS

XDisp:
	db $08,$00,$00,$08

; Sprite tilemap: Bowser Statue Fireball
Tiles:
	db $32,$50,$33,$34,$32,$50,$33,$34

; The YXPPCCCT properties of the Bowser Statue Fireball.
Prop:
	db $09,$09,$09,$09,$89,$89,$89,$89

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	;\ $02 == sprite direction * 2
	ASL				; |
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b !RAM_SMW_Counter_LocalFrames	;\ $03 == (frame counter/2 mod 4) * 2
	LSR				; |
	AND.b #$03			; |
	ASL				; |
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
	PHX				; preserve sprite index
	LDX.b #$01			; setup loop
CODE_038F2F:
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\ set tile y position
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	PHX
	TXA
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\ set tile x position
	CLC				; |
	ADC.w XDisp,x			; |
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	PLA
	PHA
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.w Tiles,x			;\ set tile number
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	LDA.w Prop,x
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b CODE_038F56
	EOR.b #$40
CODE_038F56:
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	INY				;\ how odd... those were 8x8 tiles drawn...
	INY				; |
	INY				; |
	INY				;/
	DEX				; decrease loop counter
	BPL.b CODE_038F2F		; if still tiles left to draw, go to start of loop
	PLX				; retrieve sprite index
	LDY.b #$00			; the tiles written were 8x8
	LDA.b #$01			; we wrote two tiles
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status08(Address)
namespace SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status08
%InsertMacroAtXPosition(<Address>)

DATA_038BAA:
	db $20,$20,$20,$20,$20,$20,$20,$20
	db $20,$20,$20,$20,$20,$20,$20,$20
	db $20,$1F,$1E,$1D,$1C,$1B,$1A,$19
	db $18,$17,$16,$15,$14,$13,$12,$11
	db $10,$0F,$0E,$0D,$0C,$0B,$0A,$09
	db $08,$07,$06,$05,$04,$03,$02,$01
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $01,$02,$03,$04,$05,$06,$07,$08
	db $09,$0A,$0B,$0C,$0D,$0E,$0F,$10
	db $11,$12,$13,$14,$15,$16,$17,$18
	db $19,$1A,$1B,$1C,$1D,$1E,$1F,$20
	db $20,$20,$20,$20,$20,$20,$20,$20
	db $20,$20,$20,$20,$20,$20,$20,$20

DATA_038C2A:
	db $00,$F8,$00,$08

Return038C2E:
	RTS

Bank03:
	JSR.w GFXRt			; I can't seem to make sense of the details of the routine below... Anyone else is free to try.
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return038C2E
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	LDA.w !RAM_SMW_NorSpr0B7_CarrotTopLiftUpperRight_MovementTimer,x
	BNE.b CODE_038C45
	INC.b !RAM_SMW_NorSpr_Table7E00C2,x
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr0B7_CarrotTopLiftUpperRight_MovementTimer,x
CODE_038C45:
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x
	AND.b #$03
	TAY
	LDA.w DATA_038C2A,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	CPY.b #!Define_SMW_SpriteID_NorSpr0B8_CarrotTopLiftUpperLeft
	BEQ.b CODE_038C5A
	EOR.b #$FF
	INC
CODE_038C5A:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr_Table7E151C,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	JSR.w CODE_038CE4
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return038CE3
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return038CE3
	LDA.b !RAM_SMW_Player_XPosLo
	SEC
	SBC.w !RAM_SMW_NorSpr_Table7E151C,x
	CLC
	ADC.b #$1C
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	CPY.b #!Define_SMW_SpriteID_NorSpr0B8_CarrotTopLiftUpperLeft
	BNE.b CODE_038C8C
	CLC
	ADC.b #$38
CODE_038C8C:
	TAY
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	CMP.b #$01
	LDA.b #$20
	BCC.b CODE_038C98
	LDA.b #$30
CODE_038C98:
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.w DATA_038BAA,y
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b Return038CE3
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	CMP.b #$01
	LDA.b #$1D
	BCC.b CODE_038CB2
	LDA.b #$2D
CODE_038CB2:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.w DATA_038BAA,y
	PHP
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	PLP
	ADC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	STZ.b !RAM_SMW_Player_YSpeed
	LDA.b #$01
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	LDY.b #$00
	LDA.w !RAM_SMW_Sprites_PositionDisp
	BPL.b CODE_038CD9
	DEY
CODE_038CD9:
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	TYA
	ADC.b !RAM_SMW_Player_XPosHi
	STA.b !RAM_SMW_Player_XPosHi
Return038CE3:
	RTS

CODE_038CE4:
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Player_XPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b #$20
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_038D00
	LDA.b #$30
CODE_038D00:
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM09
	RTS

; Relative X position of the diagonal platform tiles (Carrot Top Lift).
; First half is used for sprite B7, second half is used for sprite B8.
XDisp:
	db $10,$00,$10,$00,$10,$00

; Relative Y position of the diagonal platform tiles (Carrot Top Lift).
; First half is used for sprite B7, second half is used for sprite B8.
YDisp:
	db $00,$10,$10,$00,$10,$10

; Sprite tilemap: Diagonal Platform (Carrot Top Lift). First half is used
; for sprite B7, second half is used for sprite B8.
Tiles:
	db $E4,$E0,$E2,$E4,$E0,$E2

; YXPPCCCT properties for the diagonal platform (Carrot Top Lift). First
; half is used for sprite B7, second half is used for sprite B8.
Prop:
	db $0B,$0B,$0B,$4B,$4B,$4B

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	PHX
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0B8_CarrotTopLiftUpperLeft
	LDX.b #$02
	STX.b !RAM_SMW_Misc_ScratchRAM02
	BCC.b CODE_038D34
	LDX.b #$05
CODE_038D34:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	BPL.b CODE_038D34
	PLX
	LDY.b #$02
	TYA
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status08_Bank03, SMW_NorSpr0B8_CarrotTopLiftUpperLeft_Status08_Bank03)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0B9_MessageBox_Status08(Address)
namespace SMW_NorSpr0B9_MessageBox_Status08
%InsertMacroAtXPosition(<Address>)

DATA_038D66:
	db $00,$04,$07,$08,$08,$07,$04,$00
	db $00

Bank03:
;$038D6F
	JSL.l SMW_SolidSpriteBlock_Main	; make Mario able to stand on top of sprite
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	LDA.w !RAM_SMW_NorSpr0B9_MessageBox_BounceAnimationTimer,x	;\ if not time to display message (timer set to 10 if Mario hits sprite from below),
	CMP.b #$01			; |
	BNE.b DontDisplayMessageYet	;/ branch
	LDA.b #!Define_SMW_Sound1DFC_MessageBox	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	STZ.w !RAM_SMW_NorSpr0B9_MessageBox_BounceAnimationTimer,x	; clear message timer
	STZ.b !RAM_SMW_NorSpr0B9_MessageBox_HitFlag,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\ use sprite x position to determine which message to display
	LSR				; |
	LSR				; |
	LSR				; |
	LSR				; |
	AND.b #$01			; |
	INC				; |
	STA.w !RAM_SMW_Misc_DisplayMessage	;/
DontDisplayMessageYet:
	LDA.w !RAM_SMW_NorSpr0B9_MessageBox_BounceAnimationTimer,x	;\ Temporarily change layer 1 y position depending on message timer,
	LSR				; | to create the block bounce effect
	TAY				; |
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	; |
	PHA				; |
	CLC				; |
	ADC.w DATA_038D66,y		; |
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	; |
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	; |
	PHA				; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;/
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$C0
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLA				;\ reset layer 1 y position to its earlier value
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	; |
	PLA				; |
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;/
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0BA_TimedPlatform_Status08(Address)
namespace SMW_NorSpr0BA_TimedPlatform_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSR.w GFXRt			; graphics routine
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038DEF		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	LDA.b !RAM_SMW_Counter_GlobalFrames				;\ Optimization: This will never branch.
	AND.b #$00							;|
	BNE.b CODE_038DD7						;/
	LDA.b !RAM_SMW_NorSpr0BA_TimedPlatform_ActivatedFlag,x	;\ if sprite movement hasn't been triggered,
	BEQ.b CODE_038DD7		;/ branch
	LDA.w !RAM_SMW_NorSpr0BA_TimedPlatform_ClockTimer,x	;\ if timer not at zero,
	BEQ.b CODE_038DD7		; |
	DEC.w !RAM_SMW_NorSpr0BA_TimedPlatform_ClockTimer,x	;/ decrease it
CODE_038DD7:
	LDA.w !RAM_SMW_NorSpr0BA_TimedPlatform_ClockTimer,x	;\ if timer at zero,
	BEQ.b CODE_038DF0		;/ branch
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X	; no gravity
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	JSL.l SMW_SolidSpriteBlock_Main	;\ if Mario not standing on sprite,
	BCC.b Return038DEF		;/ return
	LDA.b #$10			;\ set sprite state and trigger movement
	STA.b !RAM_SMW_NorSpr_XSpeed,x	; |
	STA.b !RAM_SMW_NorSpr0BA_TimedPlatform_ActivatedFlag,x	;/
Return038DEF:
	RTS

CODE_038DF0:
	JSL.l SMW_HandleNormalSpriteGravity_Main	; gravity makes the sprite fall
	LDA.w !RAM_SMW_Sprites_PositionDisp	; unknown RAM address
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x	; $1528 is never used in the sprite anyway
	JSL.l SMW_SolidSpriteBlock_Main	; make Mario able to stand on sprite
	RTS

XDisp:
	db $00,$10,$0C

YDisp:
	db $00,$00,$04

; Sprite tilemap: Timed Platform
PlatformTiles:
	db $C4,$C4,$00

; [0B 4B 0B] Properties (Palette, gfx page, etc..) of the Timed Lift.
Prop:
	db $0B,$4B,$0B

TileSize:
	db $02,$02,$00

; Tiles used by numbers in Timed Platform (1,2,3,4)
NumberTiles:
	db $B6,$B5,$B4,$B3

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr0BA_TimedPlatform_ClockTimer,x	;\ use sprite timer to calculate which number tile to use
	PHX				; |
	PHA				; |
	LSR				; |
	LSR				; |
	LSR				; |
	LSR				; |
	LSR				; |
	LSR				; |
	TAX				; |
	LDA.w NumberTiles,x		; |
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDX.b #$02			; setup loop
	PLA				;\ if sprite timer less than 08,
	CMP.b #$08			; |
	BCS.b CODE_038E2E		; | don't branch,
	DEX				;/ which means that the OAM index gets decreased and the number tile never gets written
CODE_038E2E:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\ set x position of tile
	CLC				; |
	ADC.w XDisp,x			; |
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\ set y position of tile
	CLC				; |
	ADC.w YDisp,x			; |
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	LDA.w PlatformTiles,x
	CPX.b #$02
	BNE.b CODE_038E49
	LDA.b !RAM_SMW_Misc_ScratchRAM02
CODE_038E49:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x			;\ set tile properties
	ORA.b !RAM_SMW_Sprites_TilePriority	; |
	STA.w SMW_OAMBuffer[$40].Prop,y	;/
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w TileSize,x		;\ set tile size
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y	;/
	PLY
	INY				;\ as we wrote a 16x16 tile to OAM, we need to increase the sprite tilemap pointer by 4
	INY				; |
	INY				; |
	INY				;/
	DEX				; decrease loop counter
	BPL.b CODE_038E2E		; if still tiles left to draw, go to start of loop
	PLX				; retrieve sprite index
	LDY.b #$FF			; the tiles written were of various sizes
	LDA.b #$02			; we wrote three tiles
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's offscreen

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0BB_MovingCastleStone_Status08(Address)
namespace SMW_NorSpr0BB_MovingCastleStone_Status08
%InsertMacroAtXPosition(<Address>)

; Horizontal speed of the Grey Moving Castle Block.
XSpeed:
	db $00,$F0,$00,$10

; Time in position of the Grey Moving Castle Block.
MovementTiming:
	db $40,$50,$40,$50

Bank03:
;$038E79
	JSR.w GFXRt			; graphics routine
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038EA7		;/ return
	LDA.w !RAM_SMW_NorSpr0BB_MovingCastleStone_MovementTimer,x	;\ if not time to change sprite state,
	BNE.b CODE_038E92		;/ branch
	INC.b !RAM_SMW_NorSpr0BB_MovingCastleStone_MovementPhase,x
	LDA.b !RAM_SMW_NorSpr0BB_MovingCastleStone_MovementPhase,x	;\ use sprite state to determine time until next state change
	AND.b #$03			; |
	TAY				; |
	LDA.w MovementTiming,y		; |
	STA.w !RAM_SMW_NorSpr0BB_MovingCastleStone_MovementTimer,x	;/
CODE_038E92:
	LDA.b !RAM_SMW_NorSpr0BB_MovingCastleStone_MovementPhase,x	;\ use sprite state to determine x speed
	AND.b #$03			; |
	TAY				; |
	LDA.w XSpeed,y			; |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x	; $1528,x == sprite y speed = 0 (why?)
	JSL.l SMW_SolidSpriteBlock_Main	; make Mario able to stand on top of sprite
Return038EA7:
	RTS

XDisp:
	db $00,$10,$00,$10

YDisp:
	db $00,$00,$10,$10

; Sprite tilemap: Moving Grey Castle Brick
Tiles:
	db $CC,$CE,$EC,$EE

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	PHX				; preserve sprite index
	LDX.b #$03			; setup loop
CODE_038EBA:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\ set tile x position
	CLC				; |
	ADC.w XDisp,x			; |
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\ set tile y position
	CLC				; |
	ADC.w YDisp,x			; |
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	LDA.w Tiles,x			;\ set tile number
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	LDA.b #$03			;\ set sprite properties (hardcoded to use palette 9 and the second graphics page)
	ORA.b !RAM_SMW_Sprites_TilePriority	; |
	STA.w SMW_OAMBuffer[$40].Prop,y	;/
	INY				;\ as we wrote a 16x16 tile to OAM, we need to increase the sprite tilemap pointer by 4
	INY				; |
	INY				; |
	INY				;/
	DEX				; decrease loop counter
	BPL.b CODE_038EBA		; if still tiles left to draw, go to start of loop
	PLX				; retrieve sprite index
	LDY.b #$02			; the tiles written were 16x16
	LDA.b #$03			; we wrote four tiles
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0BC_BowserStatue_Status08(Address)
namespace SMW_NorSpr0BC_BowserStatue_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSR.w GFXRt			; graphics routine
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038A68		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	LDA.b !RAM_SMW_NorSpr0BC_BowserStatue_StatueType,x	;\ use sprite state to determine where to jump
	JSL.l SMW_ExecutePtr_Absolute	;/ using a routine I don't know anything about

BowserStatuePtrs:
	dw DoNothing			; just kind of sitting there
	dw ShootFire			; breathing fire
	dw Jump				; jumping around
	dw ShootFire			; same as the second one

ShootFire:
	JSR.w CODE_038ACB		; firebreathing routine
DoNothing:
	JSL.l SMW_SolidSpriteBlock_Main					; Glitch: If this sprite is hit below, 7E00C2 will be set to 1. Meaning, this sprite sort of has an "on" button on it's bottom that will cause an inactive statue to start spitting fire.
	JSL.l SMW_HandleNormalSpriteGravity_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x			;\ Glitch: Set AND.b #$04 to AND.b #$0C to fix the bug where jumping Bowser statues will get stuck inside ceilings.
	AND.b #$04							;|
	BEQ.b Return038A68						;/
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
Return038A68:
	RTS

Jump:
	ASL.w !RAM_SMW_NorSpr_PropertyBits167A,x			;\ Note: !Define_SMW_NorSpr_167AProp_UseNonDefaultPlayerInteraction
	LSR.w !RAM_SMW_NorSpr_PropertyBits167A,x			;/
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x	; reset sprite graphics frame
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;\ if sprite speed less than 0x10,
	CMP.b #$10			; |
	BPL.b CODE_038A7F		;/ branch
	INC.w !RAM_SMW_NorSpr_AnimationFrame,x	; use jumping graphics frame
CODE_038A7F:
	JSL.l SMW_HandleNormalSpriteGravity_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_038A99
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;\ else, invert sprite x speed
	EOR.b #$FF			; |
	INC				; |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	;\ and swap sprite direction
	EOR.b #$01			; |
	STA.w !RAM_SMW_NorSpr_FacingDirection,x	;/
CODE_038A99:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b Return038AC6
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	LDA.w !RAM_SMW_NorSpr0BC_BowserStatue_WaitBeforeJumping,x	;\ if sprite just jumped,
	BEQ.b CODE_038AC1		;/ branch
	DEC				;\ if not time to jump,
	BNE.b Return038AC6		;/ branch
	LDA.b #$C0			;\ set initial jumping y speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X	;\ set direction and x speed to make sprite jump towards Mario
	TYA				; |
	STA.w !RAM_SMW_NorSpr_FacingDirection,x	; |
	LDA.w XSpeed,y			; |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	RTS

XSpeed:
	db $10,$F0

CODE_038AC1:
	LDA.b #$30			;\ set time until next jump
	STA.w !RAM_SMW_NorSpr0BC_BowserStatue_WaitBeforeJumping,x	;/
Return038AC6:
	RTS

FireSpawnXDispXLo:
	db $10,$F0

FireSpawnXDispXHi:
	db $00,$FF

CODE_038ACB:
	TXA
	ASL
	ASL
	ADC.b !RAM_SMW_Counter_GlobalFrames	;\ if not time to spawn sprite,
	AND.b #$7F			;/ return
	BNE.b Return038B24
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return038B24
	LDA.b #!Define_SMW_Sound1DFC_FireSpit	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr0B3_BowserStatueFire	; \ Sprite = Bowser Statue Fireball
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\ set sprite x position
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	; |
	PHX				; |
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; |
	TAX				; |
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; |
	CLC				; |
	ADC.w FireSpawnXDispXLo,x	; |
	STA.w !RAM_SMW_NorSpr_XPosLo,y	;|
	LDA.b !RAM_SMW_Misc_ScratchRAM01	; |
	ADC.w FireSpawnXDispXHi,x	; |
	STA.w !RAM_SMW_NorSpr_XPosHi,y	;/
	TYX				; \ Reset sprite tables
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\ set sprite y position
	SEC				; |
	SBC.b #$02			; |
	STA.w !RAM_SMW_NorSpr_YPosLo,y	;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	; |
	SBC.b #$00			; |
	STA.w !RAM_SMW_NorSpr_YPosHi,y	;/
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	;\ set sprite direction
	STA.w !RAM_SMW_NorSpr_FacingDirection,y	;/
Return038B24:
	RTS

XDisp:
	db $08,$F8,$00,$00,$08,$00

YDisp:
	db $10,$F8,$00

; Sprite tilemap: Bowser Statue(Both)
Tiles:
	db $56,$30,$41,$56,$30,$35

TileSize:
	db $00,$02,$02

; Bowser Statue Properties. This will get or'd with the sprite's palette,
; which means it has the most effect on the jumping Bowser statue.
Prop:
	db $00,$00,$00,$40,$40,$40

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x	;\ $04 = graphics frame
	STA.b !RAM_SMW_Misc_ScratchRAM04	;/
	EOR.b #$01
	DEC
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x	;\ $05 = tile properties
	STA.b !RAM_SMW_Misc_ScratchRAM05	;/
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	;\ $02 = sprite direction
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	PHX
	LDX.b #$02			; setup loop
CODE_038B57:
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\ use direction to determine x position table pointers to use
	BNE.b CODE_038B5F		; |
	INX				; |
	INX				; |
	INX				;/
CODE_038B5F:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\ set x position of tile
	CLC				; |
	ADC.w XDisp,x			; |
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	LDA.w Prop,x			;\ palette depends on type of Bowser statue
	ORA.b !RAM_SMW_Misc_ScratchRAM05	; | add in tile properties
	ORA.b !RAM_SMW_Sprites_TilePriority	; | add in level properties
	STA.w SMW_OAMBuffer[$40].Prop,y	;/
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\ set y position of tile
	CLC				; |
	ADC.w YDisp,x			; |
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM04	;\ use graphics frame to determine tile table pointers to use
	BEQ.b CODE_038B84		; |
	INX				; |
	INX				; |
	INX				;/
CODE_038B84:
	LDA.w Tiles,x			;\ set tile number
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	PLX
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w TileSize,x		;\ set size of tile
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y	; /
	PLY
	INY				;\ as we wrote a 16x16 tile to OAM, we need to increase the sprite tilemap pointer by 4
	INY				; |
	INY				; |
	INY				;/
	DEX				; decrease loop counter
	CPX.b !RAM_SMW_Misc_ScratchRAM03	;\ if still tiles left to draw,
	BNE.b CODE_038B57		;/ go to start of loop
	PLX
	LDY.b #$FF			; the tiles written were of various sizes
	LDA.b #$02			; we wrote three tiles
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status08(Address)
namespace SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status08
%InsertMacroAtXPosition(<Address>)

MaxXSpeed:
	db $20,$E0

XAcceleration:
	db $02,$FE

Bank03:
;$038958
	LDA.b #$00
	LDY.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b CODE_038964
	BPL.b CODE_038961
	INC
CODE_038961:
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_038964:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr0BD_SlidingNakedBlueKoopa_WaitBeforeTurningIntoKoopa,x	;\ if not time to become normal blue shelless Koopa,
	CMP.b #$01			; |
	BNE.b CODE_038983		;/ branch
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	;\ preserve sprite direction
	PHA				;/
	LDA.b #!Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa	;\ sprite number = shelless blue Koopa
	STA.b !RAM_SMW_NorSpr_SpriteID_x	;/
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; INIT shelless blue Koopa
	PLA				;\ get sprite direction back
	STA.w !RAM_SMW_NorSpr_FacingDirection,x	;/
	SEC				; set carry flag, for graphics tile determining purposes
CODE_038983:
	LDA.b #$86			; if carry flag not set (sprite is still sliding blue Koopa), use tile 0x86
	BCC.b CODE_038989
	LDA.b #$E0			; if carry flag set (sprite is shelless blue Koopa), use tile 0xE0
CODE_038989:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;\ if sprite status not normal,
	CMP.b #!Define_SMW_NorSprStatus08_Normal	; |
	BNE.b Return0389FE		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked...
	ORA.w !RAM_SMW_NorSpr0BD_SlidingNakedBlueKoopa_WaitBeforeFalling,x	; | ...or INIT timer not finished counting down...
	ORA.w !RAM_SMW_NorSpr0BD_SlidingNakedBlueKoopa_WaitBeforeTurningIntoKoopa,x	; | ...or sprite about to become shelless blue Koopa,
	BNE.b Return0389FE		;/ return
	JSL.l SMW_HandleNormalSpriteGravity_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b Return0389FE
	JSR.w CODE_0389FF		; display smoke image
	LDY.b #$00
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b CODE_0389CC		; if sprite x speed == 0, branch
	BPL.b CODE_0389BD		; if sprite moving right, branch
	EOR.b #$FF
	INC
CODE_0389BD:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x	;\ if sprite not on slope (?),
	BEQ.b CODE_0389CC		;/ branch
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	EOR.b !RAM_SMW_NorSpr_XSpeed,x	;\
	BPL.b CODE_0389CC		;/ branch
	LDY.b #$D0
CODE_0389CC:
	STY.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\ if frame number odd,
	AND.b #$01			; |
	BNE.b Return0389FE		;/ return
	LDA.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x	;\ if sprite on slope (?)
	BNE.b CODE_0389EC		;/ branch
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;\ if sprite x speed =/= 0,
	BNE.b CODE_0389E3		;/ return
	LDA.b #$20			;\ set timer for turning into blue shelless Koopa
	STA.w !RAM_SMW_NorSpr0BD_SlidingNakedBlueKoopa_WaitBeforeTurningIntoKoopa,x	;/
	RTS

CODE_0389E3:
	BPL.b CODE_0389E9
	INC.b !RAM_SMW_NorSpr_XSpeed,x
	INC.b !RAM_SMW_NorSpr_XSpeed,x
CODE_0389E9:
	DEC.b !RAM_SMW_NorSpr_XSpeed,x
	RTS

CODE_0389EC:
	ASL				;\ if max x speed in the current direction achieved, don't accelerate sprite
	ROL				; |
	AND.b #$01			; |
	TAY				; |
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	; |
	CMP.w MaxXSpeed,y		; |
	BEQ.b Return0389FE		;/
	CLC				;\ if not, accelerate sprite in the current direction
	ADC.w XAcceleration,y		; |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
Return0389FE:
	RTS

CODE_0389FF:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;\ if sprite x speed == 0,
	BEQ.b Return038A20		;/ return
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\ three out of four frames,
	AND.b #$03			; |
	BNE.b Return038A20		;/ return
	LDA.b #$04			;\ set smoke x and y offsets
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	LDA.b #$0A			; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank03	;\ if sprite is offscreen,
	BNE.b Return038A20		;/ return
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot	; setup loop
CODE_038A18:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y	;\ check for free smoke image slot
	BEQ.b CODE_038A21		; |
	DEY				; |
	BPL.b CODE_038A18		;/
Return038A20:
	RTS

CODE_038A21:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr03_TurnAroundSmoke	;\ display smoke image
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y	;/
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\ set smoke x position
	CLC				; |
	ADC.b !RAM_SMW_Misc_ScratchRAM00	; |
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y	;/
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\ set smoke y position
	CLC				; |
	ADC.b !RAM_SMW_Misc_ScratchRAM01	; |
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y	;/
	LDA.b #$13			;\ set time for smoke to display
	STA.w !RAM_SMW_SmokeSpr_Timer,y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0BE_Swooper_Status08(Address)
namespace SMW_NorSpr0BE_Swooper_Status08
%InsertMacroAtXPosition(<Address>)

; Swooper Bat Tilemap
Tiles:
	db $AE,$C0,$E8

Bank03:
;$0388A3
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	PHX
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	TAX
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;\ if sprite status normal,
	CMP.b #!Define_SMW_NorSprStatus08_Normal	; |
	BEQ.b CODE_0388C0		;/ go to main code
	JMP.w SMW_NorSpr0C2_Blurp_Status08_FlipSpriteUpsideDown	; else, turn sprite upside down

CODE_0388C0:
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return0388DF		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	LDA.b !RAM_SMW_NorSpr0BE_Swooper_CurrentState,x	;\ use sprite state to determine which code to go to
	JSL.l SMW_ExecutePtr_Absolute	;/ ...somehow

SwooperPtrs:
	dw Waiting
	dw Swooping			; swooping down
	dw FlyStraight			; flying horizontally

Return0388DF:
	RTS

MaxXSpeed:
	db $10,$F0

XAcceleration:
	db $01,$FF

Waiting:
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x	;\ if sprite offscreen horizontally,
	BNE.b Return038904		;/ return
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F	;\ if Mario more than 0x50 pixels (5 16x16 tiles) from sprite,
	CLC				; |
	ADC.b #$50			; |
	CMP.b #$A0			; |
	BCS.b Return038904		;/ return
	INC.b !RAM_SMW_NorSpr0BE_Swooper_CurrentState,x	; sprite state = swooping down
	TYA				;\ make sprite face Mario
	STA.w !RAM_SMW_NorSpr_FacingDirection,x	;/
	LDA.b #$20			;\ set initial y speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	LDA.b #!Define_SMW_Sound1DFC_Swooper	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
Return038904:
	RTS

Swooping:
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\ three out of four frames,
	AND.b #$03			; |
	BNE.b CODE_038915		;/ branch
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;\ if sprite y speed == 0,
	BEQ.b CODE_038915		;/ branch
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
	BNE.b CODE_038915		; if new sprite y speed =/= 0, branch
	INC.b !RAM_SMW_NorSpr0BE_Swooper_CurrentState,x	; else, sprite state = flying horizontally
CODE_038915:
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\ three out of four frames,
	AND.b #$03			; |
	BNE.b CODE_03892B		;/ branch
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x	;\ set sprite x speed according to direction
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	CMP.w MaxXSpeed,y		;\ if max x speed achieved,
	BEQ.b CODE_03892B		;/ skip accelerating sprite
	CLC				;\ else,
	ADC.w XAcceleration,y		; |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/ accelerate sprite
CODE_03892B:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$04
	LSR
	LSR
	INC
	; Change to EA EA EA to disable Mega Mole animation
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

FlyStraight:
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\ if number of current frame is odd,
	AND.b #$01			; |
	BNE.b CODE_038952		;/ branch
	LDA.w !RAM_SMW_NorSpr0BE_Swooper_VerticalDirection,x	;\ use sprite vertical direction to determine vertical acceleration
	AND.b #$01			; |
	TAY				; |
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	; |
	CLC				; |
	ADC.w SMW_NorSpr0C2_Blurp_Status08_YAcceleration,y	; |
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	CMP.w SMW_NorSpr0C2_Blurp_Status08_MaxYSpeed,y	;\ if max y speed in current direction not achieved,
	BNE.b CODE_038952		;/ branch
	INC.w !RAM_SMW_NorSpr0BE_Swooper_VerticalDirection,x	; else, swap sprite vertical direction
CODE_038952:
	BRA.b CODE_038915		; reuse normal movement routine from the previous sprite state
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0BF_MegaMole_Status08(Address)
namespace SMW_NorSpr0BF_MegaMole_Status08
%InsertMacroAtXPosition(<Address>)

; Mega Mole X speed (right)
MegaMoleSpeed:
	db $10,$F0

Bank03:
;$038770
	JSR.w GFXRt			; Graphics routine
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal	; | If status != 8, return
	BNE.b SMW_NorSpr0C0_SinkingLavaPlatform_Status08_Return038733
	JSR.w SMW_SubOffscreen_Bank03_Entry4	; Handle off screen situation
	LDY.w !RAM_SMW_NorSpr0BF_MegaMole_MovementDirection,x	; \ Set x speed based on direction
	LDA.w MegaMoleSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ If sprites locked, return
	BNE.b SMW_NorSpr0C0_SinkingLavaPlatform_Status08_Return038733
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$04
	PHA
	JSL.l SMW_HandleNormalSpriteGravity_Main	; Update position based on speed values
	JSL.l SMW_CheckForNormalSpriteToNormalSpriteCollision_Main	; Interact with other sprites
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b InAir
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	PLA
	BRA.b OnGround

InAir:
	PLA
	BEQ.b WasInAir
	LDA.b #$0A
	STA.w !RAM_SMW_NorSpr0BF_MegaMole_WaitBeforeFalling,x
WasInAir:
	LDA.w !RAM_SMW_NorSpr0BF_MegaMole_WaitBeforeFalling,x
	BEQ.b OnGround
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
OnGround:
	LDY.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; | If Mega Mole is in contact with an object...
	AND.b #$03
	BEQ.b CODE_0387CD
	CPY.b #$00			; |    ... and timer hasn't been set (time until flip == 0)...
	BNE.b CODE_0387C5
	LDA.b #$10			; |    ... set time until flip
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
CODE_0387C5:
	LDA.w !RAM_SMW_NorSpr0BF_MegaMole_MovementDirection,x	; \ Flip the temp direction status
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr0BF_MegaMole_MovementDirection,x
CODE_0387CD:
	CPY.b #$00			; \ If time until flip == 0...
	BNE.b CODE_0387D7
	LDA.w !RAM_SMW_NorSpr0BF_MegaMole_MovementDirection,x	; |    ...update the direction status used by the gfx routine
	STA.w !RAM_SMW_NorSpr0BF_MegaMole_FacingDirection,x
CODE_0387D7:
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main	; Check for mario/Mega Mole contact
	BCC.b Return03882A		; (Carry set = contact)
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_Y
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CMP.b #$D8
	BPL.b Contact
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return03882A
	LDA.b #$01			; \ Set "on sprite" flag
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	LDA.b #$06			; \ Set riding Mega Mole
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	STZ.b !RAM_SMW_Player_YSpeed	; Y speed = 0
	LDA.b #$D6
	LDY.w !RAM_SMW_Player_RidingYoshiFlag	; | Mario's y position += C6 or D6 depending if on yoshi
	BEQ.b NoYoshi
	LDA.b #$C6
NoYoshi:
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$FF
	STA.b !RAM_SMW_Player_YPosHi
	LDY.b #$00
	LDA.w !RAM_SMW_Sprites_PositionDisp	; | $1491 == 01 or FF, depending on direction
	BPL.b CODE_038813		; | Set mario's new x position
	DEY
CODE_038813:
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	TYA
	ADC.b !RAM_SMW_Player_XPosHi
	STA.b !RAM_SMW_Player_XPosHi
	RTS

Contact:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x	; \ If riding Mega Mole...
	ORA.w !RAM_SMW_NorSpr_OnYoshisTongue,x	; |   ...or Mega Mole being eaten...
	BNE.b Return03882A		; /   ...return
	; [22 B7 F5 00] Change to [EA EA EA EA] to make Mega Mole not hurt Mario.
	JSL.l SMW_DamagePlayer_Hurt	; Hurt mario
Return03882A:
	RTS

TileDispX:
	db $00,$10,$00,$10,$10,$00,$10,$00

TileDispY:
	db $F0,$F0,$00,$00

; Sprite tilemap: Mega Mole
Tiles:
	db $C6,$C8,$E6,$E8,$CA,$CC,$EA,$EC

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.w !RAM_SMW_NorSpr0BF_MegaMole_FacingDirection,x	; \ $02 = direction
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Counter_LocalFrames
	; Animation speed of Mega Mole. Change a 4A to EA to speed it up, and a EA
	; to 4A to slow it down.
	LSR
	LSR
	NOP
	CLC
	ADC.w !RAM_SMW_NorSpr_CurrentSlotID
	AND.b #$01
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM03	; | $03 = index to frame start (0 or 4)
	PHX
	LDX.b #$03			; Run loop 4 times, cuz 4 tiles per frame
Loop:
	PHX				; Push, current tile
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b FaceLeft			; | If facing right, index to frame end += 4
	INX
	INX
	INX
	INX
FaceLeft:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; \ Tile x position = sprite x location ($00) + tile displacement
	CLC
	ADC.w TileDispX,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLX				; \ Pull, X = index to frame end
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC				; | Tile y position = sprite y location ($01) + tile displacement
	ADC.w TileDispY,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX				; \ Set current tile
	TXA				; | X = index of frame start + current tile
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$01			; Tile properties xyppccct, format
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; \ If direction == 0...
	BNE.b NoFlip
	ORA.b #$40			; /    ...flip tile
NoFlip:
	ORA.b !RAM_SMW_Sprites_TilePriority	; Add in tile priority of level
	STA.w SMW_OAMBuffer[$40].Prop,y	; Store tile properties
	PLX				; \ Pull, current tile
	INY				; | Increase index to sprite tile map ($300)...
	INY				; |    ...we wrote 4 bytes
	INY				; |    ...so increment 4 times
	INY
	DEX				; | Go to next tile of frame and loop
	BPL.b Loop
	PLX				; Pull, X = sprite index
	LDY.b #$02			; \ Will write 02 to $0460 (all 16x16 tiles)
	LDA.b #$03			; | A = number of tiles drawn - 1
	JSL.l SMW_FinishOAMWrite_Main	; / Don't draw if offscreen
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0C0_SinkingLavaPlatform_Status08(Address)
namespace SMW_NorSpr0C0_SinkingLavaPlatform_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSR.w GFXRt			; graphics routine
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038733		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	LDA.w !RAM_SMW_NorSpr0C0_SinkingLavaPlatform_DespawnTimer,x	;\ if sprite hasn't started to sink or hasn't sunk completely,
	DEC				; |
	BNE.b CODE_03871B		;/ branch
	LDY.w !RAM_SMW_NorSpr_LoadStatusTableIndex,x
if defined("Define_SMW_SA1")
	JSL.l SpriteLoading_CODE_01AC9C
	NOP
else
	LDA.b #$00			; | Allow sprite to be reloaded by level loading routine
	STA.w !RAM_SMW_Sprites_LoadStatus,y
endif
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

CODE_03871B:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	JSL.l SMW_SolidSpriteBlock_Main	; make Mario able to stand on top of sprite
	BCC.b Return038733		; if Mario not standing on sprite, return
	LDA.w !RAM_SMW_NorSpr0C0_SinkingLavaPlatform_DespawnTimer,x	;\ if sprite has already started to sink,
	BNE.b Return038733		;/ return
	LDA.b #$06
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$40			;\ set sinking timer
	STA.w !RAM_SMW_NorSpr0C0_SinkingLavaPlatform_DespawnTimer,x	;/
Return038733:
	RTS

; Sprite tilemap: Sinking Lava Platform
LavaPlatTiles:
	db $85,$86,$85

DATA_038737:
	db $43,$03,$03

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	PHX
	LDX.b #$02			; setup loop counter
CODE_038740:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\ set x position of tile
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	CLC				;\ and setup x position for next tile
	ADC.b #$10			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\ set y position for tile
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	LDA.w LavaPlatTiles,x		;\ set tile number
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	LDA.w DATA_038737,x		;\ set tile properties
	ORA.b !RAM_SMW_Sprites_TilePriority	; | add level properties
	STA.w SMW_OAMBuffer[$40].Prop,y	;/
	INY				;\ as we wrote a 16x16 tile to OAM, we must increase the sprite tilemap pointer by 4
	INY				; |
	INY				; |
	INY				;/
	DEX				;\ if tiles still left to draw,
	BPL.b CODE_038740		;/ go to start of loop
	PLX
	LDY.b #$02			; the tiles written were 16x16
	LDA.b #$02			; we wrote three tiles
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0C1_WingedPlatform_Status08(Address)
namespace SMW_NorSpr0C1_WingedPlatform_Status08
%InsertMacroAtXPosition(<Address>)

; [08 F8] Y speeds of the Flying grey turnblocks (Sprite C1). First entry is
; downwards speed, second entry is upwards speed. Setting the upwards speed
; faster than $D8 ($28 as absolute value) is prone to causing Mario to clip
; through the turnblocks when jumping. Keep in mind that if the turnblocks
; are set to go up first, these speeds are inverted.
FlyingBlockSpeedY:
	db $08,$F8

Bank03:
;$0385F6
	JSR.w GFXRt			; graphics routine
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038675		;/ return
	LDA.w !RAM_SMW_Flag_ActiveFastBackgroundScrollGenerator	;\ if BG scroll not activated yet (triggered by Mario standing on sprite),
	BEQ.b CODE_038629		;/ branch
	LDA.w !RAM_SMW_NorSpr0C1_WingedPlatform_VerticalMovementTimerHi,x	;\ every second frame (?),
	INC.w !RAM_SMW_NorSpr0C1_WingedPlatform_VerticalMovementTimerHi,x	; |
	AND.b #$01			; |
	BNE.b CODE_03861E		;/ branch
	DEC.w !RAM_SMW_NorSpr0C1_WingedPlatform_VerticalMovementTimerLo,x	; decrease direction switch timer
	LDA.w !RAM_SMW_NorSpr0C1_WingedPlatform_VerticalMovementTimerLo,x	;\ if not time to switch y direction,
	CMP.b #$FF			; |
	BNE.b CODE_03861E		;/ branch
	LDA.b #$FF			;\ if it is, do some kind of useless stuff...
	STA.w !RAM_SMW_NorSpr0C1_WingedPlatform_VerticalMovementTimerLo,x	; |
	INC.w !RAM_SMW_NorSpr0C1_WingedPlatform_VerticalDirection,x	;/ and swap sprite direction
CODE_03861E:
	LDA.w !RAM_SMW_NorSpr0C1_WingedPlatform_VerticalDirection,x
	AND.b #$01
	TAY
	LDA.w FlyingBlockSpeedY,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_038629:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	PHA				; preserve current y speed
	LDY.w !RAM_SMW_NorSpr0C1_WingedPlatform_FlyDownInitiallyFlag,x	;\ if sprite set to go down first,
	BNE.b CODE_038636		;/ branch
	EOR.b #$FF			;\ else, invert y speed
	INC				; |
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
CODE_038636:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	PLA				;\ revert to old y speed for calculation purposes
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	LDA.w !RAM_SMW_Flag_ActiveFastBackgroundScrollGenerator	; load background scroll status (activated: 08, inactivated: 00)
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x	; kind of useless, as this address is never loaded by this sprite
	JSL.l SMW_SolidSpriteBlock_Main	; make Mario able to stand on top of sprite
	BCC.b Return038675		; if Mario not standing on sprite, return
	LDA.w !RAM_SMW_Flag_ActiveFastBackgroundScrollGenerator	;\ if background scroll already triggered,
	BNE.b Return038675		;/ return
	LDA.b #$08			;\ else, set background scroll flag
	STA.w !RAM_SMW_Flag_ActiveFastBackgroundScrollGenerator	;/
	LDA.b #$7F			;\ set direction change timer
	STA.w !RAM_SMW_NorSpr0C1_WingedPlatform_VerticalMovementTimerLo,x	;/
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02	; setup loop
CODE_038660:
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID
	BEQ.b CODE_03866C
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr0C1_WingedPlatform
	BEQ.b CODE_038670
CODE_03866C:
	DEY
	BPL.b CODE_038660
	; Change C8 to 60 to fix a bug where sprite C1 (Flying Grey Turnblocks)
	; corrupts $1602 if sprite slot 0 is occupied and only one sprite C1 is
	; present.
	INY								; Glitch: This should be an RTS! This will corrupt $7E1602!
CODE_038670:
	LDA.b #$7F
	STA.w !RAM_SMW_NorSpr0C1_WingedPlatform_VerticalMovementTimerLo,y
Return038675:
	RTS

XDisp:
	db $00,$10,$20,$F2,$2E,$00,$10,$20
	db $FA,$2E

YDisp:
	db $00,$00,$00,$F6,$F6,$00,$00,$00
	db $FE,$FE

; Sprite tilemap: Forest Secret Area Platform
Tiles:
	db $40,$40,$40,$C6,$C6,$40,$40,$40
	db $5D,$5D

Prop:
	db $32,$32,$32,$72,$32,$32,$32,$32
	db $72,$32

TileSize:
	db $02,$02,$02,$02,$02,$02,$02,$02
	db $00,$00

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x				; Optimization: GetDrawInfo already sets Y!
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	AND.b #$04
	BEQ.b CODE_0386B6
	INC
CODE_0386B6:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX
	LDX.b #$04
CODE_0386BB:
	STX.b !RAM_SMW_Misc_ScratchRAM06
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\ set horizontal tile position
	CLC				; |
	ADC.w XDisp,x			; |
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\ set vertical tile position
	CLC				; |
	ADC.w YDisp,x			; |
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	LDA.w Tiles,x			;\ set tile number
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	LDA.w Prop,x			;\ set tile properties
	STA.w SMW_OAMBuffer[$40].Prop,y	;/
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w TileSize,x		;\ set tile size
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y	;/
	PLY
	INY				;\ as we wrote a 16x16 tile to OAM, we must increase the sprite tilemap pointer by 4
	INY				; |
	INY				; |
	INY				;/
	LDX.b !RAM_SMW_Misc_ScratchRAM06	;\ if still tiles left to draw,
	DEX				; |
	BPL.b CODE_0386BB		;/ go to start of loop
	PLX
	LDY.b #$FF			; the tiles drawn were of varying sizes (?)
	LDA.b #$04			; we wrote five tiles
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0C2_Blurp_Status08(Address)
namespace SMW_NorSpr0C2_Blurp_Status08
%InsertMacroAtXPosition(<Address>)

MaxYSpeed:
	db $04,$FC

XSpeed:
	db $08,$F8

YAcceleration:
	db $01,$FF

Bank03:
;$0384CA
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_Counter_LocalFrames	;\ use frame counter and sprite index to determine tile to use
	LSR				; |
	LSR				; |
	LSR				; |
	CLC				; |
	ADC.w !RAM_SMW_NorSpr_CurrentSlotID	; |
	LSR				;/
	LDA.b #$A2			; either tile 0xA2...
	BCC.b CODE_0384E2
	LDA.b #$EC			; ...or tile 0xEC is used
CODE_0384E2:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;\ if sprite status is normal,
	CMP.b #!Define_SMW_NorSprStatus08_Normal	; |
	BEQ.b CODE_0384F5		;/ branch
FlipSpriteUpsideDown:
	LDA.w SMW_OAMBuffer[$40].Prop,y	;\ else, sprite is dead, so it is flipped upside down
	ORA.b #$80			;
	STA.w SMW_OAMBuffer[$40].Prop,y	;/
	RTS

CODE_0384F5:
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return03852A		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	LDA.b !RAM_SMW_Counter_LocalFrames	;\ only update every fourth frame
	AND.b #$03			; |
	BNE.b CODE_038516		;/
	LDA.b !RAM_SMW_NorSpr0C2_Blurp_VerticalDirection,x	;\ use sprite state to determine direction of y acceleration
	AND.b #$01			; |
	TAY				; |
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	; |
	CLC				; |
	ADC.w YAcceleration,y		; |
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	CMP.w MaxYSpeed,y		;\ if max y speed in current direction has been achieved,
	BNE.b CODE_038516		; |
	INC.b !RAM_SMW_NorSpr0C2_Blurp_VerticalDirection,x	;/ switch sprite state
CODE_038516:
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x	;\ apply x speed
	LDA.w XSpeed,y			; |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
Return03852A:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0C3_PorcuPuffer_Status08(Address)
namespace SMW_NorSpr0C3_PorcuPuffer_Status08
%InsertMacroAtXPosition(<Address>)

PorcuPuffAccel:
	db $01,$FF

; Horizontal speed of the Porcu-Puffer fish
PorcuPuffMaxSpeed:
	db $10,$F0

Bank03:
;$03852F
	JSR.w GFXRt			; graphics routine
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038586		;/ return
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;\ if sprite status not normal,
	CMP.b #!Define_SMW_NorSprStatus08_Normal	; |
	BNE.b Return038586		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X	;\ make sprite face Mario
	TYA				; |
	STA.w !RAM_SMW_NorSpr_FacingDirection,x	;/
	LDA.b !RAM_SMW_Counter_LocalFrames	;\ only update every fourth frame
	AND.b #$03			; |
	BNE.b CODE_03855E		;/
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	; \ Branch if at max speed
	CMP.w PorcuPuffMaxSpeed,y
	BEQ.b CODE_03855E
	CLC				; \ Otherwise, accelerate
	ADC.w PorcuPuffAccel,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_03855E:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;\ preserve x speed in stack
	PHA				;/
	LDA.w !RAM_SMW_Misc_Layer1XDisp	;\ use unknown address to change x speed...
	ASL				; |
	ASL				; |
	ASL				; |
	CLC				; |
	ADC.b !RAM_SMW_NorSpr_XSpeed,x	; |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X	; apply x speed
	PLA				;\ and then restore it to its original value
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main	; sprite bouyancy + in water check (I assume)
	LDY.b #$04			; this corresponds to a negative y speed
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x	;\ if sprite not in water, or sprite bouyancy not enabled,
	BEQ.b CODE_038580		;/ branch
	LDY.b #$FC			; this corresponds to a positive y speed
; Change 94 to 60 to make the Porcu-Puffer fish go in a straight line and
; also float on air.
CODE_038580:
	STY.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
Return038586:
	RTS

PocruPufferDispX:
	db $F8,$08,$F8,$08,$08,$F8,$08,$F8

PocruPufferDispY:
	db $F8,$F8,$08,$08

; Sprite tilemap: Porcu-Puffer
PocruPufferTiles:
	db $86,$C0,$A6,$C2,$86,$C0,$A6,$8A

PocruPufferGfxProp:
	db $0D,$0D,$0D,$0D,$4D,$4D,$4D,$4D

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	LDA.b !RAM_SMW_Counter_LocalFrames	;\ $03 = first tile offset
	AND.b #$04			; |
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	;\ $02 = sprite direction
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	PHX
	LDX.b #$03			; setup loop
CODE_0385B4:
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\ store y position of tile
	CLC				; |
	ADC.w PocruPufferDispY,x	; |
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	PHX				; preserve loop counter
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\ if sprite facing left,
	BNE.b CODE_0385C6		; |
	TXA				; |
	ORA.b #$04			; | add 4 to loop counter to get correct X offsets
	TAX				;/
CODE_0385C6:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\ store x position of tile
	CLC				; |
	ADC.w PocruPufferDispX,x	; |
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	LDA.w PocruPufferGfxProp,x	; load sprite properties
	ORA.b !RAM_SMW_Sprites_TilePriority	; add in level properties
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA				;\ get original loop counter back,
	PHA				;/ while still keeping it preserved in the stack
	ORA.b !RAM_SMW_Misc_ScratchRAM03	; add in first tile offset
	TAX
	LDA.w PocruPufferTiles,x	;\ store tile number
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	PLX
	INY				;\ as we wrote a 16x16 tile to OAM, we must increase the sprite tilemap pointer by 4
	INY				; |
	INY				; |
	INY				;/
	DEX
	BPL.b CODE_0385B4		; if tiles left to draw, go to start of loop
	PLX
	LDY.b #$02			; the tiles written were 16x16
	LDA.b #$03			; we wrote four tiles
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0C4_GreyFallingPlatform_Status08(Address)
namespace SMW_NorSpr0C4_GreyFallingPlatform_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSR.w GFXRt			; graphics routine
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return038489		;/ return
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;\ if platform hasn't been stepped on (Y speed == 0),
	BEQ.b CODE_038476		;/ branch
	LDA.w !RAM_SMW_NorSpr0C4_GreyFallingPlatform_WaitBeforeFall,x	;\ if timer isn't zero,
	BNE.b CODE_038472		;/ skip accelerating code
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;\ if sprite max speed has been reached,
	CMP.b #$40			; |
	BPL.b CODE_038472		;/ skip accelerating code
	CLC				;\ accelerate sprite downwards
	ADC.b #$02			; |
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
CODE_038472:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
CODE_038476:
	JSL.l SMW_SolidSpriteBlock_Main	; make Mario able to stand on top of sprite
	BCC.b Return038489		; if Mario not standing on sprite, return
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;\ if sprite already moving,
	BNE.b Return038489		;/ return
	LDA.b #$03			;\ else, set initial speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	LDA.b #$18			;\ set time before accelerating starts
	STA.w !RAM_SMW_NorSpr0C4_GreyFallingPlatform_WaitBeforeFall,x	;/
Return038489:
	RTS

XDisp:
	db $00,$10,$20,$30

; Sprite tilemap: Falling Grey Platform
Tiles:
	db $60,$61,$61,$62

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank03
	PHX
	LDX.b #$03			; setup graphics loop
CODE_038498:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\ store x position of tile
	CLC				; |
	ADC.w XDisp,x			; |
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\ store y position of tile
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	LDA.w Tiles,x			;\ store tile number
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	LDA.b #$03			; palette 9, second sprite GFX page
	ORA.b !RAM_SMW_Sprites_TilePriority	; add in level properties settings
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX				; decrease loop counter
	BPL.b CODE_038498		; if tiles left to draw, go to start of loop
	PLX
	LDY.b #$02			; the tiles written were 16x16
	LDA.b #$03			; 0x4 tiles written
	JSL.l SMW_FinishOAMWrite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0C5_BigBooBoss_Status08(Address)
namespace SMW_NorSpr0C5_BigBooBoss_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSL.l SMW_NormalSpriteBooGFXRt_Main
	JSL.l SMW_FadingBooPaletteAnimation_Main
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;\ if sprite status not zero (inexistant),
	BNE.b CODE_0380A2		;/ branch to main code
	INC.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene	; else, prevent Mario from walking at level end and enable cutscene
	LDA.b #$FF			;\ end level
	STA.w !RAM_SMW_Timer_EndLevel	;/
	LDA.b #!Define_SMW_LevelMusic_PassedBoss
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	RTS

CODE_0380A2:
	CMP.b #!Define_SMW_NorSprStatus08_Normal	;\ if sprite state not normal,
	BNE.b Return0380D4		;/ return
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites locked,
	BNE.b Return0380D4		;/ return
	LDA.b !RAM_SMW_NorSpr0C5_BigBooBoss_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute	; somehow, this ends up calling the table below

BigBooBossPtrs:
	dw StoppedBeforeFadeIn		; sprite state 0: calculate graphics to use
	dw FadingIn			; sprite state 1: turning visible
	dw FloatingAroundWhileVisible	; sprite state 2: normal movement
	dw Hurt				; sprite state 3: hit by sprite
	dw FadingOut			; sprite state 4: turning invisible
	dw FloatingAroundWhileInvisible	; sprite state 5:
	dw Dying			; sprite state 6: defeated

StoppedBeforeFadeIn:
	LDA.b #$03			;\ graphics frame to use = hiding
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x	;/
	INC.w !RAM_SMW_NorSpr0C5_BigBooBoss_FadeInFrameCounter,x
	LDA.w !RAM_SMW_NorSpr0C5_BigBooBoss_FadeInFrameCounter,x
	CMP.b #$90
	BNE.b Return0380D4
	LDA.b #$08			;\set time until next sprite state
	STA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x	;/
	INC.b !RAM_SMW_NorSpr0C5_BigBooBoss_CurrentState,x	; sprite state = turn visible
Return0380D4:
	RTS

FadingIn:
	LDA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x	;\ if the timer isn't set,
	BNE.b Return0380F9		;/ return
	LDA.b #$08			;\ set time until next sprite state
	STA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x	;/
	INC.w !RAM_SMW_Sprites_BigBooBossPaletteIndex	; increase Boo palette index
	LDA.w !RAM_SMW_Sprites_BigBooBossPaletteIndex
	CMP.b #$02
	BNE.b CODE_0380EE
	LDY.b #!Define_SMW_Sound1DF9_MagicShoot	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh1
CODE_0380EE:
	CMP.b #$07
	BNE.b Return0380F9
	INC.b !RAM_SMW_NorSpr0C5_BigBooBoss_CurrentState,x	; sprite state = normal
	LDA.b #$40			;\ set time until next sprite state
	STA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x	;/
Return0380F9:
	RTS

XAcceleration:
	db $FF,$01

MaxXSpeed:
	db $F0,$10

MaxYSpeed:
	db $0C,$F4

YAcceleration:
	db $01,$FF

DATA_038102:
	db $01,$02,$02,$01

FloatingAroundWhileInvisible:
	LDA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x	;\ if timer isn't set,
	BNE.b CODE_038112		;/ branch
	STZ.b !RAM_SMW_NorSpr0C5_BigBooBoss_CurrentState,x	; sprite state = graphics calculation
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr0C5_BigBooBoss_FadeInFrameCounter,x
CODE_038112:
	LDA.b #$03			;\ graphics frame to use = hiding
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x	;/
	BRA.b CODE_03811F

FloatingAroundWhileVisible:
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x	; graphics frame to use = normal
	JSR.w CODE_0381E4
CODE_03811F:
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x	; if Boo already turning,
	BNE.b CODE_038132
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank03_X	;\ if Boo facing Mario,
	TYA				; |
	CMP.w !RAM_SMW_NorSpr_FacingDirection,x	; |
	BEQ.b CODE_03814A		;/ branch
	LDA.b #$1F			;\ set time for Boo to show turning frame
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x	;/
CODE_038132:
	CMP.b #$10			;\ if time left to turn =/= 10,
	BNE.b CODE_038140		;/ branch
	PHA
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	;\ switch sprite direction
	EOR.b #$01			; |
	STA.w !RAM_SMW_NorSpr_FacingDirection,x	;/
	PLA				; get turning timer back into accumulator
CODE_038140:
	LSR
	LSR
	LSR
	TAY
	LDA.w DATA_038102,y		;\ use turning timer to determine graphics frame to use
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x	;/
CODE_03814A:
	LDA.b !RAM_SMW_Counter_LocalFrames	;\ only execute following code every 8th frame
	AND.b #$07			; |
	BNE.b CODE_038166		;/
	LDA.w !RAM_SMW_NorSpr0C5_BigBooBoss_HorizontalDirection,x	;\ use ? to determine x acceleration
	AND.b #$01			; |
	TAY				; |
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	; |
	CLC				; |
	ADC.w XAcceleration,y		; |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	CMP.w MaxXSpeed,y		;\ if max x speed not reached, branch
	BNE.b CODE_038166		;/
	INC.w !RAM_SMW_NorSpr0C5_BigBooBoss_HorizontalDirection,x	; increase ?
CODE_038166:
	LDA.b !RAM_SMW_Counter_LocalFrames	;\ only execute following code every 8th frame
	AND.b #$07			; |
	BNE.b CODE_038182		;/
	LDA.w !RAM_SMW_NorSpr0C5_BigBooBoss_VerticalDirection,x	;\ use ? to determine y acceleration
	AND.b #$01			; |
	TAY				; |
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	; |
	CLC				; |
	ADC.w YAcceleration,y		; |
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	CMP.w MaxYSpeed,y		;\ if max y speed not reached, branch
	BNE.b CODE_038182		;/
	INC.w !RAM_SMW_NorSpr0C5_BigBooBoss_VerticalDirection,x	; increase ?
CODE_038182:
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_X
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	RTS

Hurt:
	LDA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x	;\ if timer =/= 0,
	BNE.b CODE_0381AE		;/ branch
	INC.b !RAM_SMW_NorSpr0C5_BigBooBoss_CurrentState,x	; sprite state = turning invisible
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x
	JSL.l SMW_InitializeNormalSpriteRAMTables_YXPPCCCTAndPropertyTables
	INC.w !RAM_SMW_NorSpr0C5_BigBooBoss_HitCounter,x	; increase hitpoints counter
	LDA.w !RAM_SMW_NorSpr0C5_BigBooBoss_HitCounter,x	;\ if hits taken =/= 3,
	CMP.b #$03			; |
	BNE.b Return0381AD		;/ branch
	LDA.b #$06			;\ sprite state = defeated
	STA.b !RAM_SMW_NorSpr0C5_BigBooBoss_CurrentState,x	;/
	JSL.l SMW_DespawnNonBossSprites_Main
Return0381AD:
	RTS

CODE_0381AE:
	AND.b #$0E			;\ make sprite flash
	EOR.w !RAM_SMW_NorSpr_YXPPCCCT,x	; |
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x	;/
	LDA.b #$03			;\ graphics frame to use = hiding
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x	;/
	RTS

FadingOut:
	LDA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x	;\ if timer =/= 0,
	BNE.b Return0381D2		;/ return
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x
	DEC.w !RAM_SMW_Sprites_BigBooBossPaletteIndex	;\ decrease Boo palette index
	BNE.b Return0381D2		;/ if palette index =/= 0, return
	INC.b !RAM_SMW_NorSpr0C5_BigBooBoss_CurrentState,x	; sprite state = turning invisible
	LDA.b #$C0			;\ set time until next sprite state
	STA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x	;/
Return0381D2:
	RTS

Dying:
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	LDA.b #$D0			;\ set sprite y speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	LDA.b #!Define_SMW_Sound1DF9_LemmyWendyFall	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	RTS

CODE_0381E4:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot	; set up loop
CODE_0381E6:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus09_Stunned
	BEQ.b CODE_0381F5
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked
	BEQ.b CODE_0381F5
CODE_0381F1:
	DEY
	BPL.b CODE_0381E6
	RTS				; else, return

; Big Boo's "Hit with sprite" subroutine. JSR every frame to it to have your
; boss have functionality with thrown items. $038234 is the sound made by
; Big Boo Boss when it is hit.
CODE_0381F5:
	PHX				; preserve Big Boo Boss sprite number
	TYX				; get number of sprite being checked into X register
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingB	;\ if sprites not touching each other,
	PLX				; |
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA	; |
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact	; |
	BCC.b CODE_0381F1		;/ go back to loop
	LDA.b #$03			;\ sprite state = hit by sprite
	STA.b !RAM_SMW_NorSpr0C5_BigBooBoss_CurrentState,x	;/
	LDA.b #$40			;\ set timer
	STA.w !RAM_SMW_NorSpr0C5_BigBooBoss_PhaseTimer,x	;/
	PHX
	TYX
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x	; destroy sprite that hit Boo
if defined("Define_SMW_SA1")
	; SA-1 Pack: Big boo boss needs to access sprite tables for objects that
	; are colliding with it, the tables are indexed by x only in one place so
	; don't bother updating the pointers, instead simply hijack and replace
	; with our own version.
	JML.l BIG_BOO_BOSS_FIX
else
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\ setup exploding block effect
	STA.b !RAM_SMW_Blocks_XPosLo	; |
endif
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	; |
	STA.b !RAM_SMW_Blocks_XPosHi	; |
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;|
	STA.b !RAM_SMW_Blocks_YPosLo	; |
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	; |
	STA.b !RAM_SMW_Blocks_YPosHi	; |
	PHB				; |
	LDA.b #SMW_SpawnBrickPieces_Main>>16	; |
	PHA				; |
	PLB				; |
	LDA.b #$FF			; |
	JSL.l SMW_SpawnBrickPieces_Main	; |
	PLB				; |
	PLX				;/
	LDA.b #!Define_SMW_Sound1DFC_StunEnemy	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_FadingBooPaletteAnimation(Address)
namespace SMW_FadingBooPaletteAnimation
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #$24
	STY.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
	LDA.w !RAM_SMW_Sprites_BigBooBossPaletteIndex
	CMP.b #$08
	DEC
	BCS.b CODE_03824A
	LDY.b #$34
	STY.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
	INC
CODE_03824A:
	ASL
	ASL
	ASL
	ASL
	TAX
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
CODE_038254:
	LDA.l SMW_BooFadePalettes_Main,x
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors,y
	INY
	INX
	INC.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$10
	BNE.b CODE_038254
	LDX.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
	LDA.b #$10
	STA.w !RAM_SMW_Palettes_DynamicPaletteBytesToUpload,x
	LDA.b #$F0
	STA.w !RAM_SMW_Palettes_DynamicPaletteCGRAMAddress,x
	STZ.w !RAM_SMW_Palettes_DynamicPaletteColors+$10,x
	TXA
	CLC
	ADC.b #$12
	STA.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_BooFadePalettes(Address)
namespace SMW_BooFadePalettes
%InsertMacroAtXPosition(<Address>)

; Big Boo Boss palettes (in same layout as Magikoopa palettes)
Main:
Fade07:
	incbin "palettes/FadingBoo.tpl":$6..$16
Fade06:
	incbin "palettes/FadingBoo.tpl":$26..$36
Fade05:
	incbin "palettes/FadingBoo.tpl":$46..$56
Fade04:
	incbin "palettes/FadingBoo.tpl":$66..$76
Fade03:
	incbin "palettes/FadingBoo.tpl":$86..$96
Fade02:
	incbin "palettes/FadingBoo.tpl":$A6..$B6
Fade01:
	incbin "palettes/FadingBoo.tpl":$C6..$D6
Normal:
	incbin "palettes/FadingBoo.tpl":$E6..$F6
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0C6_Spotlight_Status08(Address)
namespace SMW_NorSpr0C6_Spotlight_Status08
%InsertMacroAtXPosition(<Address>)

DATA_03C48F:
	db $01,$FF

DATA_03C491:
	db $FF,$90

; Sprite tilemap: Disco Ball
Tiles:
	db $80,$82,$84,$86,$88,$8C,$C0,$C2
	db $C2

; Spotlight / Disco Ball properties, YXPPCCCT.
Prop:
	db $31,$33,$35,$37,$31,$33,$35,$37
	db $39

GFXRt:
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$78
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b #$28
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_OnFlag,x
	LDX.b #$08
	AND.b #$01
	BEQ.b CODE_03C4C1
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	AND.b #$07
	TAX
CODE_03C4C1:
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLX
	RTS

DATA_03C4D8:
	db $10,$8C

DATA_03C4DA:
	db $42,$31

Bank03:
;$03C4DC
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_DeleteOtherSpotlightsFlag,x
	BNE.b CODE_03C500
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_03C4E3:
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID
	BEQ.b CODE_03C4FA
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_03C4FA
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr0C6_Spotlight
	BNE.b CODE_03C4FA
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
Return03C4F9:
	RTS

CODE_03C4FA:
	DEY
	BPL.b CODE_03C4E3
	INC.w !RAM_SMW_NorSpr0C6_Spotlight_DeleteOtherSpotlightsFlag,x
CODE_03C500:
	JSR.w GFXRt
	LDA.b #$FF
	STA.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
	LDA.b #$20
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings
	LDA.b #$20
	STA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings
	LDA.b #($01<<!Define_SMW_WindowHDMAChannel)
	STA.w !RAM_SMW_Mirror_HDMAEnable
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_OnFlag,x
	AND.b #$01
	TAY
	LDA.w DATA_03C4D8,y
	STA.w !RAM_SMW_Palettes_BackgroundColorLo
	LDA.w DATA_03C4DA,y
	STA.w !RAM_SMW_Palettes_BackgroundColorHi
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return03C4F9
	LDA.w !RAM_SMW_Flag_SkipSpotlightWindowInitialization
	BNE.b CODE_03C54D
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosBottom
	LDA.b #$90
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom
	LDA.b #$78
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosTop
	LDA.b #$87
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosTop 
	LDA.b #$01							;\ Optimization: Could be removed to make $1486 free RAM
	STA.w !RAM_SMW_UnusedRAM_7E1486					;/
	STZ.w !RAM_SMW_NorSpr0C6_Spotlight_Direction
	INC.w !RAM_SMW_Flag_SkipSpotlightWindowInitialization
CODE_03C54D:
	LDY.w !RAM_SMW_NorSpr0C6_Spotlight_Direction
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosBottom
	CLC
	ADC.w DATA_03C48F,y
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosBottom
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom
	CLC
	ADC.w DATA_03C48F,y
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom
	CMP.w DATA_03C491,y
	BNE.b CODE_03C572
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_Direction
	INC
	AND.b #$01
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_Direction
CODE_03C572:
	LDA.b !RAM_SMW_Counter_GlobalFrames
if defined("Define_SMW_SA1")
	AND.b #$00			; every frame, not one in four
else
	AND.b #$03
endif
	BNE.b Return03C4F9
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosTop
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
	SEC
	SBC.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosBottom
	BCS.b CODE_03C58A
	INY
	EOR.b #$FF
	INC
CODE_03C58A:
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_WidthOfLeftSideOfWindow
	STY.w !RAM_SMW_NorSpr0C6_Spotlight_BottomLeftWindowPosRelativeToTop
	STZ.w !RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosTop 
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
	SEC
	SBC.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom
	BCS.b CODE_03C5A5
	INY
	EOR.b #$FF
	INC
CODE_03C5A5:
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_WidthOfRightSideOfWindow
	STY.w !RAM_SMW_NorSpr0C6_Spotlight_BottomRightWindowPosRelativeToTop
	STZ.w !RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_OnFlag,x
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	PHX
	REP.b #$10			; XY->16
	LDX.w #$0000
CODE_03C5B8:
	CPX.w #$005F
	BCC.b CODE_03C607
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow
	CLC
	ADC.w !RAM_SMW_NorSpr0C6_Spotlight_WidthOfLeftSideOfWindow
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow
	BCS.b CODE_03C5CD
	CMP.b #$CF
	BCC.b CODE_03C5E0
CODE_03C5CD:
	SBC.b #$CF
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow
	INC.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_BottomLeftWindowPosRelativeToTop
	BNE.b CODE_03C5E0
	DEC.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
	DEC.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
CODE_03C5E0:
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow
	CLC
	ADC.w !RAM_SMW_NorSpr0C6_Spotlight_WidthOfRightSideOfWindow
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow
	BCS.b CODE_03C5F0
	CMP.b #$CF
	BCC.b CODE_03C603
CODE_03C5F0:
	SBC.b #$CF
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow
	INC.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_BottomRightWindowPosRelativeToTop
	BNE.b CODE_03C603
	DEC.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
	DEC.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
CODE_03C603:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	BNE.b CODE_03C60F
CODE_03C607:
	LDA.b #$01
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable,x
	DEC
	BRA.b CODE_03C618

CODE_03C60F:
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable,x
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
CODE_03C618:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$01,x
	INX
	INX
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	CPX.w #$01E0
else
	CPX.w #$01C0
endif
	BNE.b CODE_03C5B8
	SEP.b #$10			; XY->8
	PLX
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's offscreen unless it's touched.

;---------------------------------------------------------------------------

macro ROUTINE_RT01_SMW_NorSpr0C7_InvisibleMushroom_Status08(Address)
namespace SMW_NorSpr0C7_InvisibleMushroom_Status08
%InsertMacroAtXPosition(<Address>)

Bank03:
	JSR.w SMW_GetDrawInfo_Bank03
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main	; \ Return if no interaction
	BCC.b PopupMushroom_Return
	LDA.b #!Define_SMW_SpriteID_NorSpr074_Mushroom	; \ Replace, Sprite = Mushroom
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Reset sprite tables
	LDA.b #$20			; \ Disable interaction timer = #$20
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ Sprite Y position = Mario Y position - $000F
	SEC
	SBC.b #$0F
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
PopupMushroom:
.Main:
;$03C334
	LDA.b #$00			; \ Sprite direction = dirction of Mario's X speed
	LDY.b !RAM_SMW_Player_XSpeed
	BPL.b .CODE_03C33B
	INC
.CODE_03C33B:
	STA.w !RAM_SMW_NorSpr_Table7E157C,x
	LDA.b #$C0			; \ Set upward speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #!Define_SMW_Sound1DFC_HitItemBlock	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
.Return:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT01_SMW_NorSpr0C8_LightSwitch_Status08(Address)
namespace SMW_NorSpr0C8_LightSwitch_Status08
%InsertMacroAtXPosition(<Address>)

DATA_03C1EC:
	db $00,$04,$07,$08,$08,$07,$04,$00
	db $00

Bank03:
;$03C1F5
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_03C22B
	JSL.l SMW_SolidSpriteBlock_Main
	JSR.w SMW_SubOffscreen_Bank03_Entry1
	LDA.w !RAM_SMW_NorSpr0C8_LightSwitch_BounceAnimationTimer,x
	CMP.b #$05
	BNE.b CODE_03C22B
	STZ.b !RAM_SMW_NorSpr0C8_LightSwitch_HitFlag,x
	LDY.b #!Define_SMW_Sound1DF9_ONOFFSwitch	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh1
	PHA
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_03C211:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_03C227
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr0C6_Spotlight
	BNE.b CODE_03C227
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_OnFlag,y
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_OnFlag,y
CODE_03C227:
	DEY
	BPL.b CODE_03C211
	PLA
CODE_03C22B:
	LDA.w !RAM_SMW_NorSpr0C8_LightSwitch_BounceAnimationTimer,x
	LSR
	TAY
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	PHA
	CLC
	ADC.w DATA_03C1EC,y
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	PHA
	ADC.b #$00
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$2A
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_OAMBuffer[$40].Prop,y
	AND.b #$BF
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	RTS
namespace off
endmacro

macro INLINEDATATABLE_RT12_SMW_EmptySpace(Address)

; LM: Lunar Magic inserts some custom code here:
; $03BA10 - Routine that allows you to make any level bring up the save prompt.
; $03BA50 - Routine that lets you prevent level re-entry if the level is beaten.
; $03BB00 - Routine that sets !RAM_SMW_ExitTBLProp and !RAM_SMW_Use2ndExitFlag to 00 when warping to the bonus game or Yoshi wings rooms.
; $03BB20 - Routine for displaying custom level names.
; $03BB90 - Routine for displaying custom messages
; $03BCA0 - Routine for the Sprite 19 fix
; $03BCC0 - Alt ExGFX pointers, used for ExAnimation
; $03BCDC - JML that points to a routine that calculates which screen you're on in a level with custom dimensions
; $03BCE0 - Routine for handling Secondary Entrance tables $05FE00 and the two new ones added in 3.00. 
; $03BE80 - Pre 2.53+ overworld expansion hijack - 16-bit level message pointer offsets
;           Post 2.53+ overworld expansion hijack - Initial level flags table
!SMW_UBytes = $05FE : !SMW_JBytes = $05FE : !SMW_E1Bytes = $05FE : !SMW_E2Bytes = $05FE : !SMASW_UBytes = $05F0 : !SMASW_EBytes = $05F1 : !SMW_ARCADEBytes = $05FE
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 12)
endmacro

macro INLINEDATATABLE_RT13_SMW_EmptySpace(Address)
!SMW_UBytes = $54 : !SMW_JBytes = $72 : !SMW_E1Bytes = $54 : !SMW_E2Bytes = $54 : !SMASW_UBytes = $54 : !SMASW_EBytes = $54 : !SMW_ARCADEBytes = $54
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 13)
endmacro

macro INLINEDATATABLE_RT14_SMW_EmptySpace(Address)
!SMW_UBytes = $03A4 : !SMW_JBytes = $03AB : !SMW_E1Bytes = $03A4 : !SMW_E2Bytes = $03A4 : !SMASW_UBytes = $030F : !SMASW_EBytes = $03A2 : !SMW_ARCADEBytes = $03A4
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 14)
endmacro

macro INLINEDATATABLE_RT15_SMW_EmptySpace(Address)
%InsertMacroAtXPosition(<Address>)
if ver_is_smasw(!Define_Global_ROMToAssemble) == 0
;garbage
dw $00E8
fillbyte $00	:	fill 16
endif

; LM: Some stuff Lunar Magic inserts here:
; $03FDFF = If $00, display the effects of these settings in the editor
; $03FE00 = Level Exanimation flags. PTLG----
;	     P = disable original game's palette animations
;	     T = disable original game's tile animations
;	     L = disable LM's level animations
;	     G = disable LM's global animations
;           ---- = Unused
!SMW_UBytes = $0220 : !SMW_JBytes = $0220 : !SMW_E1Bytes = $0220 : !SMW_E2Bytes = $0220 : !SMASW_UBytes = $0232 : !SMASW_EBytes = $0232 : !SMW_ARCADEBytes = $0220
	
	%SMW_InsertOriginalFreespace(!ROMID, 15)
endmacro
