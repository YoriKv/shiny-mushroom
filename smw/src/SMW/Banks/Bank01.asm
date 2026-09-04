;####################################################################
;# Bank01.asm -- sprite main routines.
;#
;# 242 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank01Macros(StartBank, EndBank)
%BANK_START(<StartBank>)
ROUTINE_RT01_SMW_NorSprXXX_LineGuidedSprites_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_LineGuidedSprites_Status08(NULLROM)		; $018000
ROUTINE_SMW_CheckNormalSpriteLevelCollision:	%ROUTINE_SMW_CheckNormalSpriteLevelCollision(NULLROM)				; $018008
ROUTINE_RT00_SMW_UpdateNormalSpritePositionBank01:	%ROUTINE_RT00_SMW_UpdateNormalSpritePositionBank01(NULLROM)			; $01801A
ROUTINE_RT00_SMW_HandleNormalSpriteGravity:	%ROUTINE_RT00_SMW_HandleNormalSpriteGravity(NULLROM)				; $01802A
ROUTINE_RT00_SMW_CheckForNormalSpriteToNormalSpriteCollision:	%ROUTINE_RT00_SMW_CheckForNormalSpriteToNormalSpriteCollision(NULLROM)		; $018032
ROUTINE_SMW_CheckForPlayerAndNormalSpriteCollisions:	%ROUTINE_SMW_CheckForPlayerAndNormalSpriteCollisions(NULLROM)			; $01803A
ROUTINE_RT00_SMW_GenericGFXRtDraw4Tiles8x8Square:	%ROUTINE_RT00_SMW_GenericGFXRtDraw4Tiles8x8Square(NULLROM)			; $018042
ROUTINE_RT00_SMW_UnnecessaryInvertARt:	%ROUTINE_RT00_SMW_UnnecessaryInvertARt(NULLROM)				; $01804A
ROUTINE_SMW_SpawnNormalSpriteTurnAroundSmoke:	%ROUTINE_SMW_SpawnNormalSpriteTurnAroundSmoke(NULLROM)				; $01804E
ROUTINE_RT00_SMW_ProcessNormalSprites:	%ROUTINE_RT00_SMW_ProcessNormalSprites(NULLROM)				; $01808C
ROUTINE_RT00_SMW_CheckIfNormalSpriteOffScreen:	%ROUTINE_RT00_SMW_CheckIfNormalSpriteOffScreen(NULLROM)			; $0180CB
ROUTINE_RT01_SMW_ProcessNormalSprites:	%ROUTINE_RT01_SMW_ProcessNormalSprites(NULLROM)				; $0180D2
ROUTINE_SMW_NorSprStatus00_EmptySlot:	%ROUTINE_SMW_NorSprStatus00_EmptySlot(NULLROM)					; $018151
ROUTINE_SMW_NorSprStatus0C_GoalPowerUp:	%ROUTINE_SMW_NorSprStatus0C_GoalPowerUp(NULLROM)				; $018157
ROUTINE_RT00_SMW_NorSprStatus06_GoalCoins:	%ROUTINE_RT00_SMW_NorSprStatus06_GoalCoins(NULLROM)				; $01816D
ROUTINE_SMW_NorSprStatus01_Init:	%ROUTINE_SMW_NorSprStatus01_Init(NULLROM)					; $018172
ROUTINE_SMW_NorSpr0C0_SinkingLavaPlatform_Status01:	%ROUTINE_SMW_NorSpr0C0_SinkingLavaPlatform_Status01(NULLROM)			; $01830F
ROUTINE_SMW_NorSpr0BC_BowserStatue_Status01:	%ROUTINE_SMW_NorSpr0BC_BowserStatue_Status01(NULLROM)				; $018314
ROUTINE_SMW_NorSpr0BA_TimedPlatform_Status01:	%ROUTINE_SMW_NorSpr0BA_TimedPlatform_Status01(NULLROM)				; $018326
ROUTINE_SMW_NorSpr02C_YoshiEgg_Status01:	%ROUTINE_SMW_NorSpr02C_YoshiEgg_Status01(NULLROM)				; $018335
ROUTINE_SMW_NorSprXXX_ReflectingEnemy_Status01:	%ROUTINE_SMW_NorSprXXX_ReflectingEnemy_Status01(NULLROM)			; $01834C
ROUTINE_SMW_NorSpr0AC_DownFirstWoodenSpike_Status01:	%ROUTINE_SMW_NorSpr0AC_DownFirstWoodenSpike_Status01(NULLROM)			; $01835B
ROUTINE_SMW_NorSpr0AD_UpDownFirstWoodenSpike_Status01:	%ROUTINE_SMW_NorSpr0AD_UpDownFirstWoodenSpike_Status01(NULLROM)		; $01836B
ROUTINE_RT00_SMW_NorSpr0A0_ActivateBowserBattle_Status01:	%ROUTINE_RT00_SMW_NorSpr0A0_ActivateBowserBattle_Status01(NULLROM)		; $01836E
ROUTINE_SMW_NorSpr09A_SumoBro_Status01:	%ROUTINE_SMW_NorSpr09A_SumoBro_Status01(NULLROM)				; $018373
ROUTINE_SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status01:	%ROUTINE_SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status01(NULLROM)			; $01837D
ROUTINE_SMW_NorSpr049_ShiftingPipe_Status01:	%ROUTINE_SMW_NorSpr049_ShiftingPipe_Status01(NULLROM)				; $018381
ROUTINE_SMW_NorSpr09F_BanzaiBill_Status01:	%ROUTINE_SMW_NorSpr09F_BanzaiBill_Status01(NULLROM)				; $018387
ROUTINE_SMW_NorSpr09E_BallNChain_Status01:	%ROUTINE_SMW_NorSpr09E_BallNChain_Status01(NULLROM)				; $018396
ROUTINE_SMW_NorSpr04C_ExplodingBlock_Status01:	%ROUTINE_SMW_NorSpr04C_ExplodingBlock_Status01(NULLROM)			; $0183A0
ROUTINE_SMW_NorSpr08F_ScalePlatform_Status01:	%ROUTINE_SMW_NorSpr08F_ScalePlatform_Status01(NULLROM)				; $0183B3
ROUTINE_SMW_NorSpr019_DisplayMessage_Status01:	%ROUTINE_SMW_NorSpr019_DisplayMessage_Status01(NULLROM)			; $0183DA
ROUTINE_SMW_NorSpr035_Yoshi_Status01:	%ROUTINE_SMW_NorSpr035_Yoshi_Status01(NULLROM)					; $0183E0
ROUTINE_SMW_NorSprXXX_WallFollowers_Status01:	%ROUTINE_SMW_NorSprXXX_WallFollowers_Status01(NULLROM)				; $0183EF
ROUTINE_SMW_NorSpr02D_BabyYoshi_Status01:	%ROUTINE_SMW_NorSpr02D_BabyYoshi_Status01(NULLROM)				; $018435
ROUTINE_SMW_NorSpr081_ChangingItem_Status01:	%ROUTINE_SMW_NorSpr081_ChangingItem_Status01(NULLROM)				; $01843B
ROUTINE_SMW_NorSpr06C_RightWallSpringboard_Status01:	%ROUTINE_SMW_NorSpr06C_RightWallSpringboard_Status01(NULLROM)			; $01843E
ROUTINE_SMW_NorSpr03E_PSwitch_Status01:	%ROUTINE_SMW_NorSpr03E_PSwitch_Status01(NULLROM)				; $01844E
ROUTINE_SMW_NorSpr01E_Lakitu_Status01:	%ROUTINE_SMW_NorSpr01E_Lakitu_Status01(NULLROM)				; $018468
ROUTINE_SMW_NorSpr0B1_CreateEatBlock_Status01:	%ROUTINE_SMW_NorSpr0B1_CreateEatBlock_Status01(NULLROM)			; $0184D6
ROUTINE_SMW_NorSpr01C_BulletBill_Status01:	%ROUTINE_SMW_NorSpr01C_BulletBill_Status01(NULLROM)				; $0184DD
ROUTINE_SMW_NorSpr095_ClappinChuck_Status01:	%ROUTINE_SMW_NorSpr095_ClappinChuck_Status01(NULLROM)				; $0184E9
ROUTINE_SMW_NorSpr071_RedCapeSuperKoopa_Status01:	%ROUTINE_SMW_NorSpr071_RedCapeSuperKoopa_Status01(NULLROM)			; $018528
ROUTINE_SMW_NorSpr073_GroundSuperKoopa_Status01:	%ROUTINE_SMW_NorSpr073_GroundSuperKoopa_Status01(NULLROM)			; $01852E
ROUTINE_SMW_NorSpr070_Pokey_Status01:	%ROUTINE_SMW_NorSpr070_Pokey_Status01(NULLROM)					; $01854B
ROUTINE_SMW_NorSpr06F_DinoTorch_Status01:	%ROUTINE_SMW_NorSpr06F_DinoTorch_Status01(NULLROM)				; $018558
ROUTINE_SMW_NorSpr09D_BubbleWithSprite_Status01:	%ROUTINE_SMW_NorSpr09D_BubbleWithSprite_Status01(NULLROM)			; $018564
ROUTINE_SMW_NorSprXXX_GenericEnemies_Status01:	%ROUTINE_SMW_NorSprXXX_GenericEnemies_Status01(NULLROM)			; $01856E
ROUTINE_SMW_NorSpr0B3_BowserStatueFire_Status01:	%ROUTINE_SMW_NorSpr0B3_BowserStatueFire_Status01(NULLROM)			; $018584
ROUTINE_SMW_NorSpr074_Mushroom_Status01:	%ROUTINE_SMW_NorSpr074_Mushroom_Status01(NULLROM)				; $01858B
ROUTINE_SMW_NorSpr0AA_Fishbone_Status01:	%ROUTINE_SMW_NorSpr0AA_Fishbone_Status01(NULLROM)				; $01858E
ROUTINE_SMW_NorSprXXX_RegularPiranhaPlant_Status01:	%ROUTINE_SMW_NorSprXXX_RegularPiranhaPlant_Status01(NULLROM)			; $01859A
ROUTINE_SMW_NorSprStatus08_Normal:	%ROUTINE_SMW_NorSprStatus08_Normal(NULLROM)					; $0185C3
ROUTINE_RT00_SMW_NorSpr06F_DinoTorch_Status08:	%ROUTINE_RT00_SMW_NorSpr06F_DinoTorch_Status08(NULLROM)			; $01875E
ROUTINE_SMW_NorSpr04A_GoalSphere_Status08:	%ROUTINE_SMW_NorSpr04A_GoalSphere_Status08(NULLROM)				; $018763
ROUTINE_RT00_SMW_NorSpr0A9_Reznor_Status01:	%ROUTINE_RT00_SMW_NorSpr0A9_Reznor_Status01(NULLROM)				; $018789
ROUTINE_RT00_SMW_NorSpr0A0_ActivateBowserBattle_Status08:	%ROUTINE_RT00_SMW_NorSpr0A0_ActivateBowserBattle_Status08(NULLROM)		; $01878E
ROUTINE_RT00_SMW_NorSpr09F_BanzaiBill_Status08:	%ROUTINE_RT00_SMW_NorSpr09F_BanzaiBill_Status08(NULLROM)			; $018793
ROUTINE_RT00_SMW_NorSpr09D_BubbleWithSprite_Status08:	%ROUTINE_RT00_SMW_NorSpr09D_BubbleWithSprite_Status08(NULLROM)			; $018798
ROUTINE_RT00_SMW_NorSpr09B_HammerBro_Status08:	%ROUTINE_RT00_SMW_NorSpr09B_HammerBro_Status08(NULLROM)			; $01879D
ROUTINE_RT00_SMW_NorSpr09C_HammerBroPlatform_Status08:	%ROUTINE_RT00_SMW_NorSpr09C_HammerBroPlatform_Status08(NULLROM)		; $0187A2
ROUTINE_SMW_NorSpr09B_HammerBro_Status01:	%ROUTINE_SMW_NorSpr09B_HammerBro_Status01(NULLROM)				; $0187A7
ROUTINE_RT00_SMW_NorSpr099_VolcanoLotus_Status08:	%ROUTINE_RT00_SMW_NorSpr099_VolcanoLotus_Status08(NULLROM)			; $0187AC
ROUTINE_RT00_SMW_NorSpr09A_SumoBro_Status08:	%ROUTINE_RT00_SMW_NorSpr09A_SumoBro_Status08(NULLROM)				; $0187B1
ROUTINE_RT00_SMW_NorSpr02B_SumoLightning_Status08:	%ROUTINE_RT00_SMW_NorSpr02B_SumoLightning_Status08(NULLROM)			; $0187B6
ROUTINE_RT00_SMW_NorSprXXX_JumpingPiranhaPlant_Status08:	%ROUTINE_RT00_SMW_NorSprXXX_JumpingPiranhaPlant_Status08(NULLROM)		; $0187BB
ROUTINE_RT00_SMW_NorSpr090_GreenGasBubble_Status08:	%ROUTINE_RT00_SMW_NorSpr090_GreenGasBubble_Status08(NULLROM)			; $0187C0
ROUTINE_SMW_UnusedJSLTo_NorSpr09A_SumoBro_Status08_Bank02:	%ROUTINE_SMW_UnusedJSLTo_NorSpr09A_SumoBro_Status08_Bank02(NULLROM)		; $0187C5
ROUTINE_RT00_SMW_NorSpr045_DirectionalCoins_Status08:	%ROUTINE_RT00_SMW_NorSpr045_DirectionalCoins_Status08(NULLROM)			; $0187CA
ROUTINE_RT00_SMW_NorSpr04C_ExplodingBlock_Status08:	%ROUTINE_RT00_SMW_NorSpr04C_ExplodingBlock_Status08(NULLROM)			; $0187CF
ROUTINE_RT00_SMW_NorSpr08F_ScalePlatform_Status08:	%ROUTINE_RT00_SMW_NorSpr08F_ScalePlatform_Status08(NULLROM)			; $0187D4
ROUTINE_RT00_SMW_NorSpr061_SkullRaft_Status01:	%ROUTINE_RT00_SMW_NorSpr061_SkullRaft_Status01(NULLROM)			; $0187D9
ROUTINE_RT00_SMW_NorSpr061_SkullRaft_Status08:	%ROUTINE_RT00_SMW_NorSpr061_SkullRaft_Status08(NULLROM)			; $0187DE
ROUTINE_RT00_SMW_NorSpr08D_GhostHouseDoor_Status08:	%ROUTINE_RT00_SMW_NorSpr08D_GhostHouseDoor_Status08(NULLROM)			; $0187E3
ROUTINE_RT00_SMW_NorSpr08E_WarpHole_Status08:	%ROUTINE_RT00_SMW_NorSpr08E_WarpHole_Status08(NULLROM)				; $0187E8
ROUTINE_RT00_SMW_NorSpr070_Pokey_Status08:	%ROUTINE_RT00_SMW_NorSpr070_Pokey_Status08(NULLROM)				; $0187ED
ROUTINE_RT00_SMW_NorSprXXX_SuperKoopas_Status08:	%ROUTINE_RT00_SMW_NorSprXXX_SuperKoopas_Status08(NULLROM)			; $0187F2
ROUTINE_RT00_SMW_NorSpr04B_PipeLakitu_Status08:	%ROUTINE_RT00_SMW_NorSpr04B_PipeLakitu_Status08(NULLROM)			; $018801
ROUTINE_SMW_NorSpr046_DigginChuck_Status08:	%ROUTINE_SMW_NorSpr046_DigginChuck_Status08(NULLROM)				; $018806
ROUTINE_RT00_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status08:	%ROUTINE_RT00_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status08(NULLROM)	; $01880B
ROUTINE_RT00_SMW_NorSpr048_DigginChuckRock_Status08:	%ROUTINE_RT00_SMW_NorSpr048_DigginChuckRock_Status08(NULLROM)			; $018810
ROUTINE_RT00_SMW_NorSpr049_ShiftingPipe_Status08:	%ROUTINE_RT00_SMW_NorSpr049_ShiftingPipe_Status08(NULLROM)			; $018815
ROUTINE_RT00_SMW_NorSpr08A_Bird_Status08:	%ROUTINE_RT00_SMW_NorSpr08A_Bird_Status08(NULLROM)				; $01881A
ROUTINE_RT00_SMW_NorSpr08B_FireplaceSmoke_Status08:	%ROUTINE_RT00_SMW_NorSpr08B_FireplaceSmoke_Status08(NULLROM)			; $01881F
ROUTINE_RT00_SMW_NorSpr08C_SideExitAndFireplace_Status08:	%ROUTINE_RT00_SMW_NorSpr08C_SideExitAndFireplace_Status08(NULLROM)		; $018824
ROUTINE_RT00_SMW_NorSpr086_Wiggler_Status01:	%ROUTINE_RT00_SMW_NorSpr086_Wiggler_Status01(NULLROM)				; $018829
ROUTINE_RT00_SMW_NorSpr086_Wiggler_Status08:	%ROUTINE_RT00_SMW_NorSpr086_Wiggler_Status08(NULLROM)				; $01882E
ROUTINE_RT00_SMW_NorSpr06A_CoinGameCloud_Status08:	%ROUTINE_RT00_SMW_NorSpr06A_CoinGameCloud_Status08(NULLROM)			; $018833
ROUTINE_RT00_SMW_NorSpr044_TorpedoTed_Status08:	%ROUTINE_RT00_SMW_NorSpr044_TorpedoTed_Status08(NULLROM)			; $018838
ROUTINE_RT00_SMW_NorSpr089_Layer3Smasher_Status08:	%ROUTINE_RT00_SMW_NorSpr089_Layer3Smasher_Status08(NULLROM)			; $01883D
ROUTINE_RT00_SMW_NorSprXXX_WallSpringboard_Status08:	%ROUTINE_RT00_SMW_NorSprXXX_WallSpringboard_Status08(NULLROM)			; $018848
ROUTINE_RT00_SMW_NorSpr03D_RipVanFish_Status08:	%ROUTINE_RT00_SMW_NorSpr03D_RipVanFish_Status08(NULLROM)			; $018853
ROUTINE_RT00_SMW_NorSprXXX_WallFollowers_Status08:	%ROUTINE_RT00_SMW_NorSprXXX_WallFollowers_Status08(NULLROM)			; $01885E
ROUTINE_SMW_NorSpr091_CharginChuck_Status01:	%ROUTINE_SMW_NorSpr091_CharginChuck_Status01(NULLROM)				; $018869
ROUTINE_RT00_SMW_NorSpr091_CharginChuck_Status08:	%ROUTINE_RT00_SMW_NorSpr091_CharginChuck_Status08(NULLROM)			; $01886A
ROUTINE_RT00_SMW_NorSpr088_WingedCage_Status01:	%ROUTINE_RT00_SMW_NorSpr088_WingedCage_Status01(NULLROM)			; $01886F
ROUTINE_RT00_SMW_NorSpr088_WingedCage_Status08:	%ROUTINE_RT00_SMW_NorSpr088_WingedCage_Status08(NULLROM)			; $01887A
ROUTINE_RT00_SMW_NorSprXXX_Dolphins_Status08:	%ROUTINE_RT00_SMW_NorSprXXX_Dolphins_Status08(NULLROM)				; $018885
ROUTINE_SMW_NorSpr052_MovingLedgeHole_Status01:	%ROUTINE_SMW_NorSpr052_MovingLedgeHole_Status01(NULLROM)			; $018890
ROUTINE_RT00_SMW_NorSpr052_MovingLedgeHole_Status08:	%ROUTINE_RT00_SMW_NorSpr052_MovingLedgeHole_Status08(NULLROM)			; $018893
ROUTINE_RT00_SMW_NorSprXXX_GenericEnemies_Status08:	%ROUTINE_RT00_SMW_NorSprXXX_GenericEnemies_Status08(NULLROM)			; $018898
ROUTINE_SMW_NorSpr014_SpinyEgg_Status08:	%ROUTINE_SMW_NorSpr014_SpinyEgg_Status08(NULLROM)				; $018C18
ROUTINE_RT01_SMW_NorSprXXX_GenericEnemies_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_GenericEnemies_Status08(NULLROM)			; $018C4D
ROUTINE_RT00_SMW_NorSpr010_ParaGoomba_Status08:	%ROUTINE_RT00_SMW_NorSpr010_ParaGoomba_Status08(NULLROM)			; $018D2E
ROUTINE_SMW_SetXSpeedBasedOnNormalSpriteFacingDirection:	%ROUTINE_SMW_SetXSpeedBasedOnNormalSpriteFacingDirection(NULLROM)		; $018DBB
ROUTINE_RT01_SMW_NorSpr010_ParaGoomba_Status08:	%ROUTINE_RT01_SMW_NorSpr010_ParaGoomba_Status08(NULLROM)			; $018DC7
ROUTINE_SMW_SetNormalSpriteAnimationFrame:	%ROUTINE_SMW_SetNormalSpriteAnimationFrame(NULLROM)				; $018E5F
ROUTINE_SMW_NorSprXXX_RegularPiranhaPlant_Status08:	%ROUTINE_SMW_NorSprXXX_RegularPiranhaPlant_Status08(NULLROM)			; $018E6E
ROUTINE_SMW_CheckForAvailableExtendedSpriteSlot:	%ROUTINE_SMW_CheckForAvailableExtendedSpriteSlot(NULLROM)			; $018EEF
ROUTINE_SMW_NorSpr01D_HoppingFlame_Status08:	%ROUTINE_SMW_NorSpr01D_HoppingFlame_Status08(NULLROM)				; $018F0D
ROUTINE_RT00_SMW_NorSpr01E_Lakitu_Status08:	%ROUTINE_RT00_SMW_NorSpr01E_Lakitu_Status08(NULLROM)				; $018F97
ROUTINE_SMW_NorSpr01C_BulletBill_Status08:	%ROUTINE_SMW_NorSpr01C_BulletBill_Status08(NULLROM)				; $018FC7
ROUTINE_RT01_SMW_HandleNormalSpriteGravity:	%ROUTINE_RT01_SMW_HandleNormalSpriteGravity(NULLROM)				; $01902E
ROUTINE_SMW_ChangeNormalSpriteDirection:	%ROUTINE_SMW_ChangeNormalSpriteDirection(NULLROM)				; $019089
ROUTINE_RT00_SMW_GenericGFXRtDraw1Tile16x16:	%ROUTINE_RT00_SMW_GenericGFXRtDraw1Tile16x16(NULLROM)				; $0190B2
ROUTINE_RT00_SMW_HandleNormalSpriteLevelCollision:	%ROUTINE_RT00_SMW_HandleNormalSpriteLevelCollision(NULLROM)			; $0190BA
ROUTINE_SMW_NorSprStatus09_Stunned:	%ROUTINE_SMW_NorSprStatus09_Stunned(NULLROM)					; $01953C
ROUTINE_SMW_MakeStunnedSpriteBounceOrSlowDownOnGround:	%ROUTINE_SMW_MakeStunnedSpriteBounceOrSlowDownOnGround(NULLROM)		; $0197AF
ROUTINE_SMW_StunnedShellGFXRt:	%ROUTINE_SMW_StunnedShellGFXRt(NULLROM)					; $019806
ROUTINE_SMW_NorSprStatus0A_Kicked:	%ROUTINE_SMW_NorSprStatus0A_Kicked(NULLROM)					; $0198A7
ROUTINE_SMW_MakeNormalSpriteReboundOffWall:	%ROUTINE_SMW_MakeNormalSpriteReboundOffWall(NULLROM)				; $01999E
ROUTINE_SMW_BreakThrowBlock:	%ROUTINE_SMW_BreakThrowBlock(NULLROM)						; $0199DC
ROUTINE_RT00_SMW_SetNormalSpriteYSpeedBasedOnSlope:	%ROUTINE_RT00_SMW_SetNormalSpriteYSpeedBasedOnSlope(NULLROM)			; $019A04
ROUTINE_SMW_SetFacingDirectionBasedOnSpeed:	%ROUTINE_SMW_SetFacingDirectionBasedOnSpeed(NULLROM)				; $019A15
ROUTINE_SMW_KickedShellGFXRt:	%ROUTINE_SMW_KickedShellGFXRt(NULLROM)						; $019A22
ROUTINE_SMW_NorSprStatus04_SpinJumpKill:	%ROUTINE_SMW_NorSprStatus04_SpinJumpKill(NULLROM)				; $019A4E
ROUTINE_RT00_SMW_NorSprStatus02_Dead:	%ROUTINE_RT00_SMW_NorSprStatus02_Dead(NULLROM)					; $019A7B
ROUTINE_SMW_NorSprStatus03_Smushed:	%ROUTINE_SMW_NorSprStatus03_Smushed(NULLROM)					; $019AE4
ROUTINE_RT01_SMW_NorSprStatus02_Dead:	%ROUTINE_RT01_SMW_NorSprStatus02_Dead(NULLROM)					; $019B13
DATATABLE_SMW_GenericSpriteOAMData:	%DATATABLE_SMW_GenericSpriteOAMData(NULLROM)					; $019B83
ROUTINE_RT01_SMW_GenericGFXRtDraw4Tiles8x8Square:	%ROUTINE_RT01_SMW_GenericGFXRtDraw4Tiles8x8Square(NULLROM)			; $019CF3
ROUTINE_SMW_GenericGFXRtDraw2Tiles16x16sStacked:	%ROUTINE_SMW_GenericGFXRtDraw2Tiles16x16sStacked(NULLROM)			; $019D5F
ROUTINE_SMW_DrawWingTiles:	%ROUTINE_SMW_DrawWingTiles(NULLROM)						; $019E10
ROUTINE_RT01_SMW_GenericGFXRtDraw1Tile16x16:	%ROUTINE_RT01_SMW_GenericGFXRtDraw1Tile16x16(NULLROM)				; $019F09
ROUTINE_SMW_NorSprStatus0B_Carried:	%ROUTINE_SMW_NorSprStatus0B_Carried(NULLROM)					; $019F5B
ROUTINE_SMW_ProcessStunnedNormalSprite:	%ROUTINE_SMW_ProcessStunnedNormalSprite(NULLROM)				; $01A12F
ROUTINE_RT00_SMW_GetDrawInfo:	%ROUTINE_RT00_SMW_GetDrawInfo(NULLROM)						; $01A361
ROUTINE_SMW_GenericGFXRtMoveTileOffscreenVertically:	%ROUTINE_SMW_GenericGFXRtMoveTileOffscreenVertically(NULLROM)			; $01A3DF
ROUTINE_RT01_SMW_CheckForNormalSpriteToNormalSpriteCollision:	%ROUTINE_RT01_SMW_CheckForNormalSpriteToNormalSpriteCollision(NULLROM)		; $01A40B
DATATABLE_SMW_StompSoundTable:	%DATATABLE_SMW_StompSoundTable(NULLROM)					; $01A61E
ROUTINE_RT02_SMW_CheckForNormalSpriteToNormalSpriteCollision:	%ROUTINE_RT02_SMW_CheckForNormalSpriteToNormalSpriteCollision(NULLROM)		; $01A625
DATATABLE_SMW_GenericSpriteToSpawnTable:	%DATATABLE_SMW_GenericSpriteToSpawnTable(NULLROM)				; $01A7C9
ROUTINE_RT00_SMW_CheckForPlayerToNormalSpriteCollision:	%ROUTINE_RT00_SMW_CheckForPlayerToNormalSpriteCollision(NULLROM)		; $01A7DC
ROUTINE_SMW_BoostMarioSpeed:	%ROUTINE_SMW_BoostMarioSpeed(NULLROM)						; $01AA33
ROUTINE_RT01_SMW_CheckForPlayerToNormalSpriteCollision:	%ROUTINE_RT01_SMW_CheckForPlayerToNormalSpriteCollision(NULLROM)		; $01AA42
ROUTINE_SMW_SpawnContactEffectFromSide:	%ROUTINE_SMW_SpawnContactEffectFromSide(NULLROM)				; $01AB6A
ROUTINE_SMW_SpawnContactEffectFromAbove:	%ROUTINE_SMW_SpawnContactEffectFromAbove(NULLROM)				; $01AB99
ROUTINE_RT01_SMW_UpdateNormalSpritePositionBank01:	%ROUTINE_RT01_SMW_UpdateNormalSpritePositionBank01(NULLROM)			; $01ABCC
ROUTINE_RT00_SMW_SubOffscreen:	%ROUTINE_RT00_SMW_SubOffscreen(NULLROM)					; $01AC0D
ROUTINE_SMW_GetRand:	%ROUTINE_SMW_GetRand(NULLROM)							; $01ACF9
ROUTINE_RT00_SMW_CheckPlayerPositionRelativeToSprite:	%ROUTINE_RT00_SMW_CheckPlayerPositionRelativeToSprite(NULLROM)			; $01AD30
INLINEDATATABLE_RT05_SMW_EmptySpace:	%INLINEDATATABLE_RT05_SMW_EmptySpace(NULLROM)					; $01AD54
ROUTINE_SMW_NorSpr083_LeftFlyingBlock_Status01:	%ROUTINE_SMW_NorSpr083_LeftFlyingBlock_Status01(NULLROM)			; $01AD59
ROUTINE_SMW_NorSpr083_LeftFlyingBlock_Status08:	%ROUTINE_SMW_NorSpr083_LeftFlyingBlock_Status08(NULLROM)			; $01AD68
ROUTINE_SMW_NorSpr060_FlatPalaceSwitch_Status01:	%ROUTINE_SMW_NorSpr060_FlatPalaceSwitch_Status01(NULLROM)			; $01AE90
ROUTINE_RT00_SMW_NorSpr060_FlatPalaceSwitch_Status08:	%ROUTINE_RT00_SMW_NorSpr060_FlatPalaceSwitch_Status08(NULLROM)			; $01AE91
ROUTINE_SMW_NorSpr026_Thwomp_Status01:	%ROUTINE_SMW_NorSpr026_Thwomp_Status01(NULLROM)				; $01AE96
ROUTINE_SMW_NorSpr026_Thwomp_Status08:	%ROUTINE_SMW_NorSpr026_Thwomp_Status08(NULLROM)				; $01AEA3
ROUTINE_SMW_NorSpr027_Thwimp_Status08:	%ROUTINE_SMW_NorSpr027_Thwimp_Status08(NULLROM)				; $01AF9F
ROUTINE_SMW_NorSprXXX_FixedMovementCheepCheep_Status01:	%ROUTINE_SMW_NorSprXXX_FixedMovementCheepCheep_Status01(NULLROM)		; $01B00B
ROUTINE_SMW_NorSpr017_GeneratorCheepCheep_Status01:	%ROUTINE_SMW_NorSpr017_GeneratorCheepCheep_Status01(NULLROM)			; $01B012
ROUTINE_SMW_NorSprXXX_FixedMovementCheepCheep_Status08:	%ROUTINE_SMW_NorSprXXX_FixedMovementCheepCheep_Status08(NULLROM)		; $01B01D
ROUTINE_SMW_KickHelplessSprite:	%ROUTINE_SMW_KickHelplessSprite(NULLROM)					; $01B12A
ROUTINE_RT01_SMW_SpawnSparkles:	%ROUTINE_RT01_SMW_SpawnSparkles(NULLROM)					; $01B14E
ROUTINE_SMW_NorSpr017_GeneratorCheepCheep_Status08:	%ROUTINE_SMW_NorSpr017_GeneratorCheepCheep_Status08(NULLROM)			; $01B192
ROUTINE_SMW_NorSpr018_SurfaceJumpingCheepCheep_Status08:	%ROUTINE_SMW_NorSpr018_SurfaceJumpingCheepCheep_Status08(NULLROM)		; $01B1B1
ROUTINE_RT00_SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01:	%ROUTINE_RT00_SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01(NULLROM)		; $01B212
ROUTINE_SMW_NorSpr055_HorizontalCheckerboardPlatform_Status01:	%ROUTINE_SMW_NorSpr055_HorizontalCheckerboardPlatform_Status01(NULLROM)	; $01B25E
ROUTINE_RT01_SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01:	%ROUTINE_RT01_SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01(NULLROM)		; $01B262
ROUTINE_SMW_NorSpr055_HorizontalCheckerboardPlatform_Status08:	%ROUTINE_SMW_NorSpr055_HorizontalCheckerboardPlatform_Status08(NULLROM)	; $01B268
ROUTINE_SMW_NormalSpritePlatformGFXRt:	%ROUTINE_SMW_NormalSpritePlatformGFXRt(NULLROM)				; $01B2C3
ROUTINE_SMW_SolidSpriteBlock:	%ROUTINE_SMW_SolidSpriteBlock(NULLROM)						; $01B44F
ROUTINE_SMW_NorSprXXX_BuoyantPlatformsAndMine_Status08:	%ROUTINE_SMW_NorSprXXX_BuoyantPlatformsAndMine_Status08(NULLROM)		; $01B536
ROUTINE_RT00_SMW_NorSprXXX_TurnBlockBridge_Status08:	%ROUTINE_RT00_SMW_NorSprXXX_TurnBlockBridge_Status08(NULLROM)			; $01B69F
ROUTINE_SMW_FinishOAMWrite:	%ROUTINE_SMW_FinishOAMWrite(NULLROM)						; $01B7B3
ROUTINE_RT01_SMW_NorSprXXX_TurnBlockBridge_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_TurnBlockBridge_Status08(NULLROM)			; $01B851
ROUTINE_SMW_NorSprXXX_NetKoopas_Status01:	%ROUTINE_SMW_NorSprXXX_NetKoopas_Status01(NULLROM)				; $01B93C
ROUTINE_SMW_NorSprXXX_NetKoopas_Status08:	%ROUTINE_SMW_NorSprXXX_NetKoopas_Status08(NULLROM)				; $01B969
ROUTINE_SMW_NorSpr054_ClimbingNetDoor_Status01:	%ROUTINE_SMW_NorSpr054_ClimbingNetDoor_Status01(NULLROM)			; $01BA87
ROUTINE_RT00_SMW_NorSpr054_ClimbingNetDoor_Status08:	%ROUTINE_RT00_SMW_NorSpr054_ClimbingNetDoor_Status08(NULLROM)			; $01BA95
ROUTINE_SMW_NorSpr020_Magic_Status08:	%ROUTINE_SMW_NorSpr020_Magic_Status08(NULLROM)					; $01BC34
ROUTINE_SMW_NorSpr01F_Magikoopa_Status01:	%ROUTINE_SMW_NorSpr01F_Magikoopa_Status01(NULLROM)				; $01BDB8
ROUTINE_RT00_SMW_NorSpr01F_Magikoopa_Status08:	%ROUTINE_RT00_SMW_NorSpr01F_Magikoopa_Status08(NULLROM)			; $01BDD6
ROUTINE_RT00_SMW_AimTowardsPlayer:	%ROUTINE_RT00_SMW_AimTowardsPlayer(NULLROM)					; $01BF6A
ROUTINE_RT01_SMW_NorSpr01F_Magikoopa_Status08:	%ROUTINE_RT01_SMW_NorSpr01F_Magikoopa_Status08(NULLROM)			; $01BFE3
ROUTINE_SMW_NorSpr07B_GoalTape_Status01:	%ROUTINE_SMW_NorSpr07B_GoalTape_Status01(NULLROM)				; $01C062
ROUTINE_RT00_SMW_NorSpr07B_GoalTape_Status08:	%ROUTINE_RT00_SMW_NorSpr07B_GoalTape_Status08(NULLROM)				; $01C098
ROUTINE_SMW_NorSpr079_VineHead_Status08:	%ROUTINE_SMW_NorSpr079_VineHead_Status08(NULLROM)				; $01C183
ROUTINE_SMW_NorSprXXX_FlyingItems_Status08:	%ROUTINE_SMW_NorSprXXX_FlyingItems_Status08(NULLROM)				; $01C1EE
ROUTINE_RT00_SMW_NorSprXXX_PowerUps_Status08:	%ROUTINE_RT00_SMW_NorSprXXX_PowerUps_Status08(NULLROM)				; $01C313
ROUTINE_SMW_GivePlayerStarPower:	%ROUTINE_SMW_GivePlayerStarPower(NULLROM)					; $01C580
ROUTINE_RT01_SMW_NorSprXXX_PowerUps_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_PowerUps_Status08(NULLROM)				; $01C592
ROUTINE_SMW_PowerUpAndItemGFXRt:	%ROUTINE_SMW_PowerUpAndItemGFXRt(NULLROM)					; $01C609
ROUTINE_SMW_NorSpr077_Feather_Status08:	%ROUTINE_SMW_NorSpr077_Feather_Status08(NULLROM)				; $01C6E6
ROUTINE_SMW_NorSpr05F_BrownChainedPlatform_Status01:	%ROUTINE_SMW_NorSpr05F_BrownChainedPlatform_Status01(NULLROM)			; $01C74A
ROUTINE_RT00_SMW_NorSpr05F_BrownChainedPlatform_Status08:	%ROUTINE_RT00_SMW_NorSpr05F_BrownChainedPlatform_Status08(NULLROM)		; $01C773
ROUTINE_SMW_GetSineAndCosineOfTiltingPlatform:	%ROUTINE_SMW_GetSineAndCosineOfTiltingPlatform(NULLROM)			; $01CB20
ROUTINE_SMW_CalculateCircleCoordinatesForTiltingPlaform:	%ROUTINE_SMW_CalculateCircleCoordinatesForTiltingPlaform(NULLROM)		; $01CB53
ROUTINE_SMW_WasteTime:	%ROUTINE_SMW_WasteTime(NULLROM)						; $01CC94
ROUTINE_SMW_CheckForTiltingPlatformCollision:	%ROUTINE_SMW_CheckForTiltingPlatformCollision(NULLROM)				; $01CC9D
ROUTINE_RT01_SMW_UnnecessaryInvertARt:	%ROUTINE_RT01_SMW_UnnecessaryInvertARt(NULLROM)				; $01CCEC
ROUTINE_RT01_SMW_NorSpr05F_BrownChainedPlatform_Status08:	%ROUTINE_RT01_SMW_NorSpr05F_BrownChainedPlatform_Status08(NULLROM)		; $01CCF0
INLINEDATATABLE_RT06_SMW_EmptySpace:	%INLINEDATATABLE_RT06_SMW_EmptySpace(NULLROM)					; $01CD1E
ROUTINE_RT00_SMW_NorSpr029_KoopaKid_Status08_WendyLemmy:	%ROUTINE_RT00_SMW_NorSpr029_KoopaKid_Status08_WendyLemmy(NULLROM)		; $01CD2A
ROUTINE_RT00_SMW_NorSpr029_KoopaKid_Status01:	%ROUTINE_RT00_SMW_NorSpr029_KoopaKid_Status01(NULLROM)				; $01CD2F
ROUTINE_SMW_NorSpr029_KoopaKid_Status08_MortonRoyLudwig:	%ROUTINE_SMW_NorSpr029_KoopaKid_Status08_MortonRoyLudwig(NULLROM)		; $01CD99
ROUTINE_SMW_NorSpr034_LudwigFireball_Status08:	%ROUTINE_SMW_NorSpr034_LudwigFireball_Status08(NULLROM)			; $01D439
ROUTINE_SMW_NorSprXXX_ParachutingEnemy_Status08:	%ROUTINE_SMW_NorSprXXX_ParachutingEnemy_Status08(NULLROM)			; $01D4E7
ROUTINE_SMW_NorSprXXX_LineGuidedSprites_Status01:	%ROUTINE_SMW_NorSprXXX_LineGuidedSprites_Status01(NULLROM)			; $01D6C4
ROUTINE_RT00_SMW_NorSprXXX_LineGuidedSprites_Status08:	%ROUTINE_RT00_SMW_NorSprXXX_LineGuidedSprites_Status08(NULLROM)		; $01D717
ROUTINE_SMW_NorSpr0B4_NonLineGuideGrinder_Status08:	%ROUTINE_SMW_NorSpr0B4_NonLineGuideGrinder_Status08(NULLROM)			; $01DB5A
ROUTINE_RT02_SMW_NorSprXXX_LineGuidedSprites_Status08:	%ROUTINE_RT02_SMW_NorSprXXX_LineGuidedSprites_Status08(NULLROM)		; $01DBD4
ROUTINE_SMW_NorSpr082_BonusGame_Status01:	%ROUTINE_SMW_NorSpr082_BonusGame_Status01(NULLROM)				; $01DD90
ROUTINE_RT00_SMW_NorSpr082_BonusGame_Status08:	%ROUTINE_RT00_SMW_NorSpr082_BonusGame_Status08(NULLROM)			; $01DE11
ROUTINE_SMW_NorSpr033_Podoboo_Status01:	%ROUTINE_SMW_NorSpr033_Podoboo_Status01(NULLROM)				; $01E050
ROUTINE_RT00_SMW_NorSpr033_Podoboo_Status08:	%ROUTINE_RT00_SMW_NorSpr033_Podoboo_Status08(NULLROM)				; $01E07B
ROUTINE_SMW_NorSpr00E_Keyhole_Status01:	%ROUTINE_SMW_NorSpr00E_Keyhole_Status01(NULLROM)				; $01E1B8
ROUTINE_SMW_NorSpr00E_Keyhole_Status08:	%ROUTINE_SMW_NorSpr00E_Keyhole_Status08(NULLROM)				; $01E1C8
ROUTINE_RT01_SMW_NorSpr082_BonusGame_Status08:	%ROUTINE_RT01_SMW_NorSpr082_BonusGame_Status08(NULLROM)			; $01E26A
INLINEDATATABLE_RT07_SMW_EmptySpace:	%INLINEDATATABLE_RT07_SMW_EmptySpace(NULLROM)					; $01E2B0
ROUTINE_SMW_NorSprXXX_SmallMontyMole_Status08:	%ROUTINE_SMW_NorSprXXX_SmallMontyMole_Status08(NULLROM)			; $01E2C8
ROUTINE_RT00_SMW_NorSpr030_ThrowingDryBones_Status08:	%ROUTINE_RT00_SMW_NorSpr030_ThrowingDryBones_Status08(NULLROM)			; $01E41F
ROUTINE_SMW_NorSpr02F_PortableSpringboard_Status08:	%ROUTINE_SMW_NorSpr02F_PortableSpringboard_Status08(NULLROM)			; $01E611
ROUTINE_SMW_GenericSmushedSpriteGFXRt:	%ROUTINE_SMW_GenericSmushedSpriteGFXRt(NULLROM)				; $01E700
ROUTINE_SMW_NorSpr019_DisplayMessage_Status08:	%ROUTINE_SMW_NorSpr019_DisplayMessage_Status08(NULLROM)			; $01E75B
ROUTINE_SMW_NorSpr087_LakituCloud_Status08:	%ROUTINE_SMW_NorSpr087_LakituCloud_Status08(NULLROM)				; $01E76F
ROUTINE_SMW_MakeLakituThrowSpiny:	%ROUTINE_SMW_MakeLakituThrowSpiny(NULLROM)					; $01EA17
ROUTINE_RT02_SMW_PlayerGFXRt:	%ROUTINE_RT02_SMW_PlayerGFXRt(NULLROM)						; $01EA70
DATATABLE_SMW_GenericNormalSpriteAccelerationTable:	%DATATABLE_SMW_GenericNormalSpriteAccelerationTable(NULLROM)			; $01EBB4
ROUTINE_RT00_SMW_NorSpr035_Yoshi_Status08:	%ROUTINE_RT00_SMW_NorSpr035_Yoshi_Status08(NULLROM)				; $01EBB6
ROUTINE_SMW_PrepareToHatchNormalSpriteYoshiEgg:	%ROUTINE_SMW_PrepareToHatchNormalSpriteYoshiEgg(NULLROM)			; $01F74C
ROUTINE_SMW_NorSpr02C_YoshiEgg_Status08:	%ROUTINE_SMW_NorSpr02C_YoshiEgg_Status08(NULLROM)				; $01F75C
ROUTINE_SMW_NorSpr012_UnusedSprite_Status01:	%ROUTINE_SMW_NorSpr012_UnusedSprite_Status01(NULLROM)				; $01F873
ROUTINE_SMW_NorSprXXX_Eeries_Status01:	%ROUTINE_SMW_NorSprXXX_Eeries_Status01(NULLROM)				; $01F87C
ROUTINE_SMW_NorSprXXX_Eeries_Status08:	%ROUTINE_SMW_NorSprXXX_Eeries_Status08(NULLROM)				; $01F88E
ROUTINE_SMW_NorSprXXX_NonBossBoos_Status08:	%ROUTINE_SMW_NorSprXXX_NonBossBoos_Status08(NULLROM)				; $01F8CF
ROUTINE_RT00_SMW_NorSpr0A7_IggyBall_Status08:	%ROUTINE_RT00_SMW_NorSpr0A7_IggyBall_Status08(NULLROM)				; $01FA4C
ROUTINE_SMW_NorSpr029_KoopaKid_Status08:	%ROUTINE_SMW_NorSpr029_KoopaKid_Status08(NULLROM)				; $01FAD5
ROUTINE_SMW_NorSpr029_KoopaKid_Status08_IggyLarry:	%ROUTINE_SMW_NorSpr029_KoopaKid_Status08_IggyLarry(NULLROM)			; $01FAD5
ROUTINE_RT01_SMW_NorSpr0A7_IggyBall_Status08:	%ROUTINE_RT01_SMW_NorSpr0A7_IggyBall_Status08(NULLROM)				; $01FF98
INLINEDATATABLE_RT08_SMW_EmptySpace:	%INLINEDATATABLE_RT08_SMW_EmptySpace(NULLROM)					; $01FFBF
%BANK_END(<EndBank>)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprStatus01_Init(Address)					; Optimization: These pointers ought to be 24-bit in the optimized code.
namespace SMW_NorSprStatus01_Init
%InsertMacroAtXPosition(<Address>)

; This is sprite status #$01, which will call the current sprite's init
; routine.
Main:
	LDA.b #$08			; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
if !Define_SMW_CustomSprites == !TRUE
	; The same four bytes as the trampoline call, which neither returns
	; nor is returned to. The stub gives a custom slot its acts-like
	; number and its properties and runs its own init; everything else
	; reaches this same table by name. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Init
else
	JSL.l SMW_ExecutePtr_Absolute
endif

NormalSpriteInitPointers:
;$01817D
	; Pointers to sprite initialization routines. These are called based on the
	; sprite number ($9E,x). Valid values are 00-C8; sprites C9 and above are
	; considered different types of sprites and handled by other routines.
	dw SMW_NorSpr000_GreenNakedKoopa_Status01_Main				; 000 - Green Koopa, no shell
	dw SMW_NorSpr001_RedNakedKoopa_Status01_Main				; 001 - Red Koopa, no shell
	dw SMW_NorSpr002_BlueNakedKoopa_Status01_Main				; 002 - Blue Koopa, no shell
	dw SMW_NorSpr003_YellowNakedKoopa_Status01_Main				; 003 - Yellow Koopa, no shell
	dw SMW_NorSpr004_GreenKoopa_Status01_Main				; 004 - Green Koopa
	dw SMW_NorSpr005_RedKoopa_Status01_Main					; 005 - Red Koopa
	dw SMW_NorSpr006_BlueKoopa_Status01_Main				; 006 - Blue Koopa
	dw SMW_NorSpr007_YellowKoopa_Status01_Main				; 007 - Yellow Koopa
	dw SMW_NorSpr008_LeftFlyingGreenParaKoopa_Status01_Main			; 008 - Green Koopa, flying left
	dw SMW_NorSpr009_BouncingGreenParaKoopa_Status01_Main			; 009 - Green bouncing Koopa
	dw SMW_NorSpr00A_VerticalRedParaKoopa_Status01_Main			; 00A - Red vertical flying Koopa
	dw SMW_NorSpr00B_HorizontalRedParaKoopa_Status01_Main			; 00B - Red horizontal flying Koopa
	dw SMW_NorSpr00C_YellowParaKoopa_Status01_Main				; 00C - Yellow Koopa with wings
	dw SMW_NorSpr00D_BobOmb_Status01_Main					; 00D - Bob-omb
	dw SMW_NorSpr00E_Keyhole_Status01_Main					; 00E - Keyhole
	dw SMW_NorSpr00F_Goomba_Status01_Main					; 00F - Goomba
	dw SMW_NorSpr010_ParaGoomba_Status01_Main				; 010 - Bouncing Goomba with wings
	dw SMW_NorSpr011_BuzzyBeetle_Status01_Main				; 011 - Buzzy Beetle
	dw SMW_NorSpr012_Unused_Status01_Main					; 012 - Unused
	dw SMW_NorSpr013_Spiny_Status01_Main					; 013 - Spiny
	dw SMW_NorSpr014_SpinyEgg_Status01_Main					; 014 - Spiny falling
	dw SMW_NorSpr015_HorizontalCheepCheep_Status01_Main			; 015 - Fish, horizontal
	dw SMW_NorSpr016_VerticalCheepCheep_Status01_Main			; 016 - Fish, vertical
	dw SMW_NorSpr017_GeneratorCheepCheep_Status01_Main			; 017 - Fish, created from generator
	dw SMW_NorSpr018_SurfaceJumpingCheepCheep_Status01_Main			; 018 - Surface jumping fish
	dw SMW_NorSpr019_DisplayMessage_Status01_Main				; 019 - Display text from level Message Box #1
	dw SMW_NorSpr01A_ClassicPiranhaPlant_Status01_Main			; 01A - Classic Piranha Plant
	dw SMW_NorSpr01B_Football_Status01_Main					; 01B - Bouncing football in place
	dw SMW_NorSpr01C_BulletBill_Status01_Main				; 01C - Bullet Bill
	dw SMW_NorSpr01D_HoppingFlame_Status01_Main				; 01D - Hopping flame
	dw SMW_NorSpr01E_Lakitu_Status01_Main					; 01E - Lakitu
	dw SMW_NorSpr01F_MagiKoopa_Status01_Main				; 01F - Magikoopa
	dw SMW_NorSpr020_Magic_Status01_Main					; 020 - Magikoopa's magic
	dw SMW_NorSpr021_MovingCoin_Status01_Main				; 021 - Moving coin
	dw SMW_NorSpr022_GreenVerticalNetKoopa_Status01_Main			; 022 - Green vertical net Koopa
	dw SMW_NorSpr023_RedVerticalNetKoopa_Status01_Main			; 023 - Red vertical net Koopa
	dw SMW_NorSpr024_GreenHorizontalNetKoopa_Status01_Main			; 024 - Green horizontal net Koopa
	dw SMW_NorSpr025_RedHorizontalNetKoopa_Status01_Main			; 025 - Red horizontal net Koopa
	dw SMW_NorSpr026_Thwomp_Status01_Main					; 026 - Thwomp
	dw SMW_NorSpr027_Thwimp_Status01_Main					; 027 - Thwimp
	dw SMW_NorSpr028_BigBoo_Status01_Main					; 028 - Big Boo
	dw SMW_NorSpr029_KoopaKids_Status01_Main				; 029 - Koopa Kid
	dw SMW_NorSpr02A_UpsideDownPiranhaPlant_Status01_Main			; 02A - Upside down Piranha Plant
	dw SMW_NorSpr02B_SumoLightning_Status01_Main				; 02B - Sumo Brother's fire lightning
	dw SMW_NorSpr02C_YoshiEgg_Status01_Main					; 02C - Yoshi egg
	dw SMW_NorSpr02D_BabyYoshi_Status01_Main				; 02D - Baby green Yoshi
	dw SMW_NorSpr02E_SpikeTop_Status01_Main					; 02E - Spike Top
	dw SMW_NorSpr02F_PortableSpringboard_Status01_Main			; 02F - Portable spring board
	dw SMW_NorSpr030_ThrowingDryBones_Status01_Main				; 030 - Dry Bones, throws bones
	dw SMW_NorSpr031_BonyBeetle_Status01_Main				; 031 - Bony Beetle
	dw SMW_NorSpr032_LedgeDryBones_Status01_Main				; 032 - Dry Bones, stay on ledge
	dw SMW_NorSpr033_Podoboo_Status01_Main					; 033 - Fireball
	dw SMW_NorSpr034_LudwigFireball_Status01_Main				; 034 - Boss fireball
	dw SMW_NorSpr035_Yoshi_Status01_Main					; 035 - Green Yoshi
	dw SMW_NorSpr036_Unused_Status01_Main					; 036 - Unused
	dw SMW_NorSpr037_Boo_Status01_Main					; 037 - Boo
	dw SMW_NorSpr038_StraightEerie_Status01_Main				; 038 - Eerie
	dw SMW_NorSpr039_WavyEerie_Status01_Main				; 039 - Eerie, wave motion
	dw SMW_NorSpr03A_FixedUrchin_Status01_Main				; 03A - Urchin, fixed
	dw SMW_NorSpr03B_WallDetectUrchin_Status01_Main				; 03B - Urchin, wall detect
	dw SMW_NorSpr03C_WallFollowUrchin_Status01_Main				; 03C - Urchin, wall follow
	dw SMW_NorSpr03D_RipVanFish_Status01_Main				; 03D - Rip Van Fish
	dw SMW_NorSpr03E_PSwitch_Status01_Main					; 03E - POW
	dw SMW_NorSpr03F_ParachuteGoomba_Status01_Main				; 03F - Para-Goomba
	dw SMW_NorSpr040_ParachuteBobOmb_Status01_Main				; 040 - Para-Bomb
	dw SMW_NorSpr041_LongJumpDolphin_Status01_Main				; 041 - Dolphin, horizontal
	dw SMW_NorSpr042_ShortJumpDolphin_Status01_Main				; 042 - Dolphin2, horizontal
	dw SMW_NorSpr043_VerticalDolphin_Status01_Main				; 043 - Dolphin, vertical
	dw SMW_NorSpr044_TorpedoTed_Status01_Main				; 044 - Torpedo Ted
	dw SMW_NorSpr045_DirectionalCoins_Status01_Main				; 045 - Directional coins
	dw SMW_NorSpr046_DigginChuck_Status01_Main				; 046 - Diggin' Chuck
	dw SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status01_Main		; 047 - Swimming/Jumping fish
	dw SMW_NorSpr048_DigginChuckRock_Status01_Main				; 048 - Diggin' Chuck's rock
	dw SMW_NorSpr049_ShiftingPipe_Status01_Main				; 049 - Growing/shrinking pipe end
	dw SMW_NorSpr04A_GoalSphere_Status01_Main				; 04A - Goal Point Question Sphere
	dw SMW_NorSpr04B_PipeLakitu_Status01_Main				; 04B - Pipe dwelling Lakitu
	dw SMW_NorSpr04C_ExplodingBlock_Status01_Main				; 04C - Exploding Block
	dw SMW_NorSpr04D_GroundMontyMole_Status01_Main				; 04D - Ground dwelling Monty Mole
	dw SMW_NorSpr04E_LedgeMontyMole_Status01_Main				; 04E - Ledge dwelling Monty Mole
	dw SMW_NorSpr04F_JumpingPiranhaPlant_Status01_Main			; 04F - Jumping Piranha Plant
	dw SMW_NorSpr050_FireSpittingJumpingPiranhaPlant_Status01_Main		; 050 - Jumping Piranha Plant, spit fire
	dw SMW_NorSpr051_Ninji_Status01_Main					; 051 - Ninji
#LM253Hijack_MovingLedgeHoleInitFix:
	dw SMW_NorSpr052_MovingLedgeHole_Status01_Main				; 052 - Moving ledge hole in ghost house
	; Change from C2 85 to 35 84 to allow throw blocks to be placed directly in
	; Lunar Magic, with infinite timer until they disappear.
	dw SMW_NorSpr053_ThrowBlock_Status01_Main				; 053 - Throw block sprite
	dw SMW_NorSpr054_ClimbingNetDoor_Status01_Main				; 054 - Climbing net door
	dw SMW_NorSpr055_HorizontalCheckerboardPlatform_Status01_Main		; 055 - Checkerboard platform, horizontal
	dw SMW_NorSpr056_HorizontalRockPlatform_Status01_Main			; 056 - Flying rock platform, horizontal
	dw SMW_NorSpr057_VerticalCheckerboardPlatform_Status01_Main		; 057 - Checkerboard platform, vertical
	dw SMW_NorSpr058_VerticalRockPlatform_Status01_Main			; 058 - Flying rock platform, vertical
	dw SMW_NorSpr059_HorizontalAndVerticalTurnBlockBridge_Status01_Main	; 059 - Turn block bridge, horizontal and vertical
	dw SMW_NorSpr05A_HorizontalTurnBlockBridge_Status01_Main		; 05A - Turn block bridge, horizontal
	dw SMW_NorSpr05B_BrownBuoyantPlatform_Status01_Main			; 05B - Brown platform floating in water
	dw SMW_NorSpr05C_BuoyantCheckboardPlatform_Status01_Main		; 05C - Checkerboard platform that falls
	dw SMW_NorSpr05D_OrangeBuoyantPlatform_Status01_Main			; 05D - Orange platform floating in water
	dw SMW_NorSpr05E_FloatingOrangePlatform_Status01_Main			; 05E - Orange platform, goes on forever
	dw SMW_NorSpr05F_BrownChainedPlatform_Status01_Main			; 05F - Brown platform on a chain
	dw SMW_NorSpr060_FlatPalaceSwitch_Status01_Main				; 060 - Flat green switch palace switch
	dw SMW_NorSpr061_SkullRaft_Status01_Main				; 061 - Floating skulls
	dw SMW_NorSpr062_BrownLineGuidePlatform_Status01_Main			; 062 - Brown platform, line-guided
	dw SMW_NorSpr063_CheckerboardLineGuidePlatform_Status01_Main		; 063 - Checker/brown platform, line-guided
	dw SMW_NorSpr064_LineGuideRope_Status01_Main				; 064 - Rope mechanism, line-guided
	dw SMW_NorSpr065_Chainsaw_Status01_Main					; 065 - Chainsaw, line-guided
	dw SMW_NorSpr066_UpsideDownChainsaw_Status01_Main			; 066 - Upside down chainsaw, line-guided
	dw SMW_NorSpr067_LineGuideGrinder_Status01_Main				; 067 - Grinder, line-guided
	dw SMW_NorSpr068_LineGuideFuzzy_Status01_Main				; 068 - Fuzz ball, line-guided
	dw SMW_NorSpr069_Unused_Status01_Main					; 069 - Unused
	dw SMW_NorSpr06A_CoinGameCloud_Status01_Main				; 06A - Coin game cloud
	dw SMW_NorSpr06B_LeftWallSpringboard_Status01_Main			; 06B - Spring board, left wall
	dw SMW_NorSpr06C_RightWallSpringboard_Status01_Main			; 06C - Spring board, right wall
	dw SMW_NorSpr06D_InvisibleBlock_Status01_Main				; 06D - Invisible solid block
	dw SMW_NorSpr06E_DinoRhino_Status01_Main				; 06E - Dino Rhino
	dw SMW_NorSpr06F_DinoTorch_Status01_Main				; 06F - Dino Torch
	dw SMW_NorSpr070_Pokey_Status01_Main					; 070 - Pokey
	dw SMW_NorSpr071_RedCapeSuperKoopa_Status01_Main			; 071 - Super Koopa, red cape
	dw SMW_NorSpr072_YellowCapeSuperKoopa_Status01_Main			; 072 - Super Koopa, yellow cape
	dw SMW_NorSpr073_GroundSuperKoopa_Status01_Main				; 073 - Super Koopa, feather
	dw SMW_NorSpr074_Mushroom_Status01_Main					; 074 - Mushroom
	dw SMW_NorSpr075_FireFlower_Status01_Main				; 075 - Flower
	dw SMW_NorSpr076_Star_Status01_Main					; 076 - Star
	dw SMW_NorSpr077_Feather_Status01_Main					; 077 - Feather
	dw SMW_NorSpr078_1upMushroom_Status01_Main				; 078 - 1-Up
	dw SMW_NorSpr079_VineHead_Status01_Main					; 079 - Growing Vine
	dw SMW_NorSpr07A_Fireworks_Status01_Main				; 07A - Firework
	dw SMW_NorSpr07B_GoalTape_Status01_Main					; 07B - Goal Point
	dw SMW_NorSpr07C_PrincessPeach_Status01_Main				; 07C - Princess Peach
	dw SMW_NorSpr07D_PBalloon_Status01_Main					; 07D - Balloon
	dw SMW_NorSpr07E_FlyingRedCoin_Status01_Main				; 07E - Flying Red coin
	dw SMW_NorSpr07F_Flying1up_Status01_Main				; 07F - Flying yellow 1-Up
	dw SMW_NorSpr080_Key_Status01_Main					; 080 - Key
	dw SMW_NorSpr081_ChangingItem_Status01_Main				; 081 - Changing item from translucent block
	dw SMW_NorSpr082_BonusGame_Status01_Main				; 082 - Bonus game sprite
	dw SMW_NorSpr083_LeftFlyingBlock_Status01_Main				; 083 - Left flying question block
	dw SMW_NorSpr084_HorizontalFlyingBlock_Status01_Main			; 084 - Flying question block
	dw SMW_NorSpr085_Unused_Status01_Main					; 085 - Unused (Pretty sure)
	dw SMW_NorSpr086_Wiggler_Status01_Main					; 086 - Wiggler
	dw SMW_NorSpr087_LakituCloud_Status01_Main				; 087 - Lakitu's cloud
	dw SMW_NorSpr088_WingedCage_Status01_Main				; 088 - Unused (Winged cage sprite)
	dw SMW_NorSpr089_Layer3Smasher_Status01_Main				; 089 - Layer 3 smash
	dw SMW_NorSpr08A_Bird_Status01_Main					; 08A - Bird from Yoshi's house
	dw SMW_NorSpr08B_FireplaceSmoke_Status01_Main				; 08B - Puff of smoke from Yoshi's house
	dw SMW_NorSpr08C_SideExitAndFireplace_Status01_Main			; 08C - Fireplace smoke/exit from side screen
	dw SMW_NorSpr08D_GhostHouseDoor_Status01_Main				; 08D - Ghost house exit sign and door
	dw SMW_NorSpr08E_WarpHole_Status01_Main					; 08E - Invisible "Warp Hole" blocks
	dw SMW_NorSpr08F_ScalePlatform_Status01_Main				; 08F - Scale platforms
	dw SMW_NorSpr090_GreenGasBubble_Status01_Main				; 090 - Large green gas bubble
	dw SMW_NorSpr091_CharginChuck_Status01_Main				; 091 - Chargin' Chuck
	dw SMW_NorSpr092_SplittinChuck_Status01_Main				; 092 - Splittin' Chuck
	dw SMW_NorSpr093_BouncinChuck_Status01_Main				; 093 - Bouncin' Chuck
	dw SMW_NorSpr094_WhistlinChuck_Status01_Main				; 094 - Whistlin' Chuck
	dw SMW_NorSpr095_ClappinChuck_Status01_Main				; 095 - Clappin' Chuck
	dw SMW_NorSpr096_CharginChuckCopy_Status01_Main				; 096 - Unused (Chargin' Chuck clone)
	dw SMW_NorSpr097_PuntinChuck_Status01_Main				; 097 - Puntin' Chuck
	dw SMW_NorSpr098_PitchinChuck_Status01_Main				; 098 - Pitchin' Chuck
	dw SMW_NorSpr099_VolcanoLotus_Status01_Main				; 099 - Volcano Lotus
	dw SMW_NorSpr09A_SumoBro_Status01_Main					; 09A - Sumo Brother
	dw SMW_NorSpr09B_HammerBro_Status01_Main				; 09B - Hammer Brother
	dw SMW_NorSpr09C_HammerBroPlatform_Status01_Main			; 09C - Flying blocks for Hammer Brother
	dw SMW_NorSpr09D_BubbleWithSprite_Status01_Main				; 09D - Bubble with sprite
	dw SMW_NorSpr09E_BallNChain_Status01_Main				; 09E - Ball and Chain
	dw SMW_NorSpr09F_BanzaiBill_Status01_Main				; 09F - Banzai Bill
	dw SMW_NorSpr0A0_ActivateBowserBattle_Status01_Main			; 0A0 - Activates Bowser scene
	dw SMW_NorSpr0A1_BowserBowlingBall_Status01_Main			; 0A1 - Bowser's bowling ball
	dw SMW_NorSpr0A2_MechaKoopa_Status01_Main				; 0A2 - MechaKoopa
	dw SMW_NorSpr0A3_GreyChainedPlatform_Status01_Main			; 0A3 - Grey platform on chain
	dw SMW_NorSpr0A4_SpikeBall_Status01_Main				; 0A4 - Floating Spike ball
	dw SMW_NorSpr0A5_Sparky_Status01_Main					; 0A5 - Fuzzball/Sparky, ground-guided
	dw SMW_NorSpr0A6_Hothead_Status01_Main					; 0A6 - HotHead, ground-guided
	dw SMW_NorSpr0A7_IggyBall_Status01_Main					; 0A7 - Iggy's ball
	dw SMW_NorSpr0A8_Blargg_Status01_Main					; 0A8 - Blargg
	dw SMW_NorSpr0A9_Reznor_Status01_Main					; 0A9 - Reznor
	dw SMW_NorSpr0AA_Fishbone_Status01_Main					; 0AA - Fishbone
	dw SMW_NorSpr0AB_Rex_Status01_Main					; 0AB - Rex
	dw SMW_NorSpr0AC_DownFirstWoodenSpike_Status01_Main			; 0AC - Wooden Spike, moving down and up
	dw SMW_NorSpr0AD_UpDownFirstWoodenSpike_Status01_Main			; 0AD - Wooden Spike, moving up/down first
	dw SMW_NorSpr0AE_FishinBoo_Status01_Main				; 0AE - Fishin' Boo
	dw SMW_NorSpr0AF_BooBlock_Status01_Main					; 0AF - Boo Block
	dw SMW_NorSpr0B0_ReflectingBooBuddies_Status01_Main			; 0B0 - Reflecting stream of Boo Buddies
	dw SMW_NorSpr0B1_CreateEatBlock_Status01_Main				; 0B1 - Creating/Eating block
	dw SMW_NorSpr0B2_FallingSpike_Status01_Main				; 0B2 - Falling Spike
	dw SMW_NorSpr0B3_BowserStatueFire_Status01_Main				; 0B3 - Bowser statue fireball
	dw SMW_NorSpr0B4_NonLineGuideGrinder_Status01_Main			; 0B4 - Grinder, non-line-guided
	dw SMW_NorSpr0B5_SinkingFireball_Status01_Main				; 0B5 - Sinking fireball used in boss battles
	dw SMW_NorSpr0B6_ReflectingPodoboo_Status01_Main			; 0B6 - Reflecting fireball
	dw SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status01_Main			; 0B7 - Carrot Top lift, upper right
	dw SMW_NorSpr0B8_CarrotTopLiftUpperLeft_Status01_Main			; 0B8 - Carrot Top lift, upper left
	dw SMW_NorSpr0B9_MessageBox_Status01_Main				; 0B9 - Info Box
	dw SMW_NorSpr0BA_TimedPlatform_Status01_Main				; 0BA - Timed lift
	dw SMW_NorSpr0BB_MovingCastleStone_Status01_Main			; 0BB - Grey moving castle block
	dw SMW_NorSpr0BC_BowserStatue_Status01_Main				; 0BC - Bowser statue
	dw SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status01_Main			; 0BD - Sliding Koopa without a shell
	dw SMW_NorSpr0BE_Swooper_Status01_Main					; 0BE - Swooper bat
	dw SMW_NorSpr0BF_MegaMole_Status01_Main					; 0BF - Mega Mole
	dw SMW_NorSpr0C0_SinkingLavaPlatform_Status01_Main			; 0C0 - Grey platform on lava
	dw SMW_NorSpr0C1_WingedPlatform_Status01_Main				; 0C1 - Flying grey turnblocks
	dw SMW_NorSpr0C2_Blurp_Status01_Main					; 0C2 - Blurp fish
	dw SMW_NorSpr0C3_PorcuPuffer_Status01_Main				; 0C3 - Porcu-Puffer fish
	dw SMW_NorSpr0C4_GreyFallingPlatform_Status01_Main			; 0C4 - Grey platform that falls
	dw SMW_NorSpr0C5_BigBooBoss_Status01_Main				; 0C5 - Big Boo Boss
	dw SMW_NorSpr0C6_Spotlight_Status01_Main				; 0C6 - Dark room with spot light
	dw SMW_NorSpr0C7_InvisibleMushroom_Status01_Main			; 0C7 - Invisible mushroom
	dw SMW_NorSpr0C8_LightSwitch_Status01_Main				; 0C8 - Light switch block for dark room

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprStatus08_Normal(Address)					; Optimization: These pointers ought to be 24-bit in the optimized code.
namespace SMW_NorSprStatus08_Normal
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Sprites_PositionDisp	; CallSpriteMain
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
if !Define_SMW_CustomSprites == !TRUE
	; The same four bytes as the trampoline call. The stub runs a custom
	; slot's own main where its rows name one -- a rowless one falls back
	; to the acts-like number in $9E -- and reaches this same table by
	; name for everything else. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Main
else
	JSL.l SMW_ExecutePtr_Absolute
endif

NormalSpriteNormalPtrs:
;$0185CC
base $000000
; Pointers to sprite main routines. These are called based on the sprite
; number ($9E,x). Valid values are 00-C8; sprites C9 and above are
; considered different types of sprites and handled by other routines.
.NorSpr000_GreenNakedKoopa:				dw SMW_NorSpr000_GreenNakedKoopa_Status08_Main	; 00 - Green Koopa, no shell
.NorSpr001_RedNakedKoopa:				dw SMW_NorSpr001_RedNakedKoopa_Status08_Main	; 01 - Red Koopa, no shell
.NorSpr002_BlueNakedKoopa:				dw SMW_NorSpr002_BlueNakedKoopa_Status08_Main	; 02 - Blue Koopa, no shell
.NorSpr003_YellowNakedKoopa:				dw SMW_NorSpr003_YellowNakedKoopa_Status08_Main	; 03 - Yellow Koopa, no shell
.NorSpr004_GreenKoopa:					dw SMW_NorSpr004_GreenKoopa_Status08_Main	; 04 - Green Koopa
.NorSpr005_RedKoopa:					dw SMW_NorSpr005_RedKoopa_Status08_Main	; 05 - Red Koopa
.NorSpr006_BlueKoopa:					dw SMW_NorSpr006_BlueKoopa_Status08_Main	; 06 - Blue Koopa
.NorSpr007_YellowKoopa:					dw SMW_NorSpr007_YellowKoopa_Status08_Main	; 07 - Yellow Koopa
.NorSpr008_LeftFlyingGreenParaKoopa:			dw SMW_NorSpr008_LeftFlyingGreenParaKoopa_Status08_Main	; 08 - Green Koopa, flying left
.NorSpr009_BouncingGreenParaKoopa:			dw SMW_NorSpr009_BouncingGreenParaKoopa_Status08_Main	; 09 - Green bouncing Koopa
.NorSpr00A_VerticalRedParaKoopa:			dw SMW_NorSpr00A_VerticalRedParaKoopa_Status08_Main	; 0A - Red vertical flying Koopa
.NorSpr00B_HorizontalRedParaKoopa:			dw SMW_NorSpr00B_HorizontalRedParaKoopa_Status08_Main	; 0B - Red horizontal flying Koopa
.NorSpr00C_YellowParaKoopa:				dw SMW_NorSpr00C_YellowParaKoopa_Status08_Main	; 0C - Yellow Koopa with wings
.NorSpr00D_BobOmb:					dw SMW_NorSpr00D_BobOmb_Status08_Main	; 0D - Bob-omb
.NorSpr00E_Keyhole:					dw SMW_NorSpr00E_Keyhole_Status08_Main	; 0E - Keyhole
.NorSpr00F_Goomba:					dw SMW_NorSpr00F_Goomba_Status08_Main	; 0F - Goomba
.NorSpr010_ParaGoomba:					dw SMW_NorSpr010_ParaGoomba_Status08_Main	; 10 - Bouncing Goomba with wings
.NorSpr011_BuzzyBeetle:					dw SMW_NorSpr011_BuzzyBeetle_Status08_Main	; 11 - Buzzy Beetle
.NorSpr012_Unused:					dw SMW_NorSpr012_Unused_Status08_Main	; 12 - Unused
.NorSpr013_Spiny:					dw SMW_NorSpr013_Spiny_Status08_Main	; 13 - Spiny
.NorSpr014_SpinyEgg:					dw SMW_NorSpr014_SpinyEgg_Status08_Main	; 14 - Spiny falling
.NorSpr015_HorizontalCheepCheep:			dw SMW_NorSpr015_HorizontalCheepCheep_Status08_Main	; 15 - Fish, horizontal
.NorSpr016_VerticalCheepCheep:				dw SMW_NorSpr016_VerticalCheepCheep_Status08_Main	; 16 - Fish, vertical
.NorSpr017_GeneratorCheepCheep:				dw SMW_NorSpr017_GeneratorCheepCheep_Status08_Main	; 17 - Fish, created from generator
.NorSpr018_SurfaceJumpingCheepCheep:			dw SMW_NorSpr018_SurfaceJumpingCheepCheep_Status08_Main	; 18 - Surface jumping fish
.NorSpr019_DisplayMessage:				dw SMW_NorSpr019_DisplayMessage_Status08_Main	; 19 - Display text from level Message Box #1
.NorSpr01A_ClassicPiranhaPlant:				dw SMW_NorSpr01A_ClassicPiranhaPlant_Status08_Main	; 1A - Classic Piranha Plant
.NorSpr01B_Football:					dw SMW_NorSpr01B_Football_Status08_Main	; 1B - Bouncing football in place
.NorSpr01C_BulletBill:					dw SMW_NorSpr01C_BulletBill_Status08_Main	; 1C - Bullet Bill
.NorSpr01D_HoppingFlame:				dw SMW_NorSpr01D_HoppingFlame_Status08_Main	; 1D - Hopping flame
.NorSpr01E_Lakitu:					dw SMW_NorSpr01E_Lakitu_Status08_Main	; 1E - Lakitu
.NorSpr01F_MagiKoopa:					dw SMW_NorSpr01F_MagiKoopa_Status08_Main	; 1F - Magikoopa
.NorSpr020_Magic:					dw SMW_NorSpr020_Magic_Status08_Main	; 20 - Magikoopa's magic
.NorSpr021_MovingCoin:					dw SMW_NorSpr021_MovingCoin_Status08_Main	; 21 - Moving coin
.NorSpr022_GreenVerticalNetKoopa:			dw SMW_NorSpr022_GreenVerticalNetKoopa_Status08_Main	; 22 - Green vertical net Koopa
.NorSpr023_RedVerticalNetKoopa:				dw SMW_NorSpr023_RedVerticalNetKoopa_Status08_Main	; 23 - Red vertical net Koopa
.NorSpr024_GreenHorizontalNetKoopa:			dw SMW_NorSpr024_GreenHorizontalNetKoopa_Status08_Main	; 24 - Green horizontal net Koopa
.NorSpr025_RedHorizontalNetKoopa:			dw SMW_NorSpr025_RedHorizontalNetKoopa_Status08_Main	; 25 - Red horizontal net Koopa
.NorSpr026_Thwomp:					dw SMW_NorSpr026_Thwomp_Status08_Main	; 26 - Thwomp
.NorSpr027_Thwimp:					dw SMW_NorSpr027_Thwimp_Status08_Main	; 27 - Thwimp
.NorSpr028_BigBoo:					dw SMW_NorSpr028_BigBoo_Status08_Main	; 28 - Big Boo
.NorSpr029_KoopaKids:					dw SMW_NorSpr029_KoopaKids_Status08_Main	; 29 - Koopa Kid
.NorSpr02A_UpsideDownPiranhaPlant:			dw SMW_NorSpr02A_UpsideDownPiranhaPlant_Status08_Main	; 2A - Upside down Piranha Plant
.NorSpr02B_SumoLightning:				dw SMW_NorSpr02B_SumoLightning_Status08_Main	; 2B - Sumo Brother's fire lightning
.NorSpr02C_YoshiEgg:					dw SMW_NorSpr02C_YoshiEgg_Status08_Main	; 2C - Yoshi egg
.NorSpr02D_BabyYoshi:					dw SMW_NorSpr02D_BabyYoshi_Status08_Main	; 2D - Baby green Yoshi
.NorSpr02E_SpikeTop:					dw SMW_NorSpr02E_SpikeTop_Status08_Main	; 2E - Spike Top
.NorSpr02F_PortableSpringboard:				dw SMW_NorSpr02F_PortableSpringboard_Status08_Main	; 2F - Portable spring board
.NorSpr030_ThrowingDryBones:				dw SMW_NorSpr030_ThrowingDryBones_Status08_Main	; 30 - Dry Bones, throws bones
.NorSpr031_BonyBeetle:					dw SMW_NorSpr031_BonyBeetle_Status08_Main	; 31 - Bony Beetle
.NorSpr032_LedgeDryBones:				dw SMW_NorSpr032_LedgeDryBones_Status08_Main	; 32 - Dry Bones, stay on ledge
.NorSpr033_Podoboo:					dw SMW_NorSpr033_Podoboo_Status08_Main	; 33 - Fireball
.NorSpr034_LudwigFireball:				dw SMW_NorSpr034_LudwigFireball_Status08_Main	; 34 - Boss fireball
.NorSpr035_Yoshi:					dw SMW_NorSpr035_Yoshi_Status08_Main	; 35 - Green Yoshi
.NorSpr036_Unused:					dw SMW_NorSpr036_Unused_Status08_Main	; 36 - Unused
.NorSpr037_Boo:						dw SMW_NorSpr037_Boo_Status08_Main	; 37 - Boo
.NorSpr038_StraightEerie:				dw SMW_NorSpr038_StraightEerie_Status08_Main	; 38 - Eerie
.NorSpr039_WavyEerie:					dw SMW_NorSpr039_WavyEerie_Status08_Main	; 39 - Eerie, wave motion
.NorSpr03A_FixedUrchin:					dw SMW_NorSpr03A_FixedUrchin_Status08_Main	; 3A - Urchin, fixed
.NorSpr03B_WallDetectUrchin:				dw SMW_NorSpr03B_WallDetectUrchin_Status08_Main	; 3B - Urchin, wall detect
.NorSpr03C_WallFollowUrchin:				dw SMW_NorSpr03C_WallFollowUrchin_Status08_Main	; 3C - Urchin, wall follow
.NorSpr03D_RipVanFish:					dw SMW_NorSpr03D_RipVanFish_Status08_Main	; 3D - Rip Van Fish
.NorSpr03E_PSwitch:					dw SMW_NorSpr03E_PSwitch_Status08_Main	; 3E - POW
.NorSpr03F_ParachuteGoomba:				dw SMW_NorSpr03F_ParachuteGoomba_Status08_Main	; 3F - Para-Goomba
.NorSpr040_ParachuteBobOmb:				dw SMW_NorSpr040_ParachuteBobOmb_Status08_Main	; 40 - Para-Bomb
.NorSpr041_LongJumpDolphin:				dw SMW_NorSpr041_LongJumpDolphin_Status08_Main	; 41 - Dolphin, horizontal
.NorSpr042_ShortJumpDolphin:				dw SMW_NorSpr042_ShortJumpDolphin_Status08_Main	; 42 - Dolphin2, horizontal
.NorSpr043_VerticalDolphin:				dw SMW_NorSpr043_VerticalDolphin_Status08_Main	; 43 - Dolphin, vertical
.NorSpr044_TorpedoTed:					dw SMW_NorSpr044_TorpedoTed_Status08_Main	; 44 - Torpedo Ted
.NorSpr045_DirectionalCoins:				dw SMW_NorSpr045_DirectionalCoins_Status08_Main	; 45 - Directional coins
.NorSpr046_DigginChuck:					dw SMW_NorSpr046_DigginChuck_Status08_Main	; 46 - Diggin' Chuck
.NorSpr047_SwimmingAndJumpingCheepCheep:		dw SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status08_Main	; 47 - Swimming/Jumping fish
.NorSpr048_DigginChuckRock:				dw SMW_NorSpr048_DigginChuckRock_Status08_Main	; 48 - Diggin' Chuck's rock
.NorSpr049_ShiftingPipe:				dw SMW_NorSpr049_ShiftingPipe_Status08_Main	; 49 - Growing/shrinking pipe end
.NorSpr04A_GoalSphere:					dw SMW_NorSpr04A_GoalSphere_Status08_Main	; 4A - Goal Point Question Sphere
.NorSpr04B_PipeLakitu:					dw SMW_NorSpr04B_PipeLakitu_Status08_Main	; 4B - Pipe dwelling Lakitu
.NorSpr04C_ExplodingBlock:				dw SMW_NorSpr04C_ExplodingBlock_Status08_Main	; 4C - Exploding Block
.NorSpr04D_GroundMontyMole:				dw SMW_NorSpr04D_GroundMontyMole_Status08_Main	; 4D - Ground dwelling Monty Mole
.NorSpr04E_LedgeMontyMole:				dw SMW_NorSpr04E_LedgeMontyMole_Status08_Main	; 4E - Ledge dwelling Monty Mole
.NorSpr04F_JumpingPiranhaPlant:				dw SMW_NorSpr04F_JumpingPiranhaPlant_Status08_Main	; 4F - Jumping Piranha Plant
.NorSpr050_FireSpittingJumpingPiranhaPlant:		dw SMW_NorSpr050_FireSpittingJumpingPiranhaPlant_Status08_Main	; 50 - Jumping Piranha Plant, spit fire
.NorSpr051_Ninji:					dw SMW_NorSpr051_Ninji_Status08_Main	; 51 - Ninji
.NorSpr052_MovingLedgeHole:				dw SMW_NorSpr052_MovingLedgeHole_Status08_Main	; 52 - Moving ledge hole in ghost house
.NorSpr053_ThrowBlock:					dw SMW_NorSpr053_ThrowBlock_Status08_Main	; 53 - Throw block sprite
.NorSpr054_ClimbingNetDoor:				dw SMW_NorSpr054_ClimbingNetDoor_Status08_Main	; 54 - Climbing net door
.NorSpr055_HorizontalCheckerboardPlatform:		dw SMW_NorSpr055_HorizontalCheckerboardPlatform_Status08_Main	; 55 - Checkerboard platform, horizontal
.NorSpr056_HorizontalRockPlatform:			dw SMW_NorSpr056_HorizontalRockPlatform_Status08_Main	; 56 - Flying rock platform, horizontal
.NorSpr057_VerticalCheckerboardPlatform:		dw SMW_NorSpr057_VerticalCheckerboardPlatform_Status08_Main	; 57 - Checkerboard platform, vertical
.NorSpr058_VerticalRockPlatform:			dw SMW_NorSpr058_VerticalRockPlatform_Status08_Main	; 58 - Flying rock platform, vertical
.NorSpr059_HorizontalAndVerticalTurnBlockBridge:	dw SMW_NorSpr059_HorizontalAndVerticalTurnBlockBridge_Status08_Main	; 59 - Turn block bridge, horizontal and vertical
.NorSpr05A_HorizontalTurnBlockBridge:			dw SMW_NorSpr05A_HorizontalTurnBlockBridge_Status08_Main	; 5A - Turn block bridge, horizontal
.NorSpr05B_BrownBuoyantPlatform:			dw SMW_NorSpr05B_BrownBuoyantPlatform_Status08_Main	; 5B - Brown platform floating in water
.NorSpr05C_BuoyantCheckboardPlatform:			dw SMW_NorSpr05C_BuoyantCheckboardPlatform_Status08_Main	; 5C - Checkerboard platform that falls
.NorSpr05D_OrangeBuoyantPlatform:			dw SMW_NorSpr05D_OrangeBuoyantPlatform_Status08_Main	; 5D - Orange platform floating in water
.NorSpr05E_FloatingOrangePlatform:			dw SMW_NorSpr05E_FloatingOrangePlatform_Status08_Main	; 5E - Orange platform, goes on forever
.NorSpr05F_BrownChainedPlatform:			dw SMW_NorSpr05F_BrownChainedPlatform_Status08_Main	; 5F - Brown platform on a chain
.NorSpr060_FlatPalaceSwitch:				dw SMW_NorSpr060_FlatPalaceSwitch_Status08_Main	; 60 - Flat green switch palace switch
.NorSpr061_SkullRaft:					dw SMW_NorSpr061_SkullRaft_Status08_Main	; 61 - Floating skulls
.NorSpr062_BrownLineGuidePlatform:			dw SMW_NorSpr062_BrownLineGuidePlatform_Status08_Main	; 62 - Brown platform, line-guided
.NorSpr063_CheckerboardLineGuidePlatform:		dw SMW_NorSpr063_CheckerboardLineGuidePlatform_Status08_Main	; 63 - Checker/brown platform, line-guided
.NorSpr064_LineGuideRope:				dw SMW_NorSpr064_LineGuideRope_Status08_Main	; 64 - Rope mechanism, line-guided
.NorSpr065_Chainsaw:					dw SMW_NorSpr065_Chainsaw_Status08_Main	; 65 - Chainsaw, line-guided
.NorSpr066_UpsideDownChainsaw:				dw SMW_NorSpr066_UpsideDownChainsaw_Status08_Main	; 66 - Upside down chainsaw, line-guided
.NorSpr067_LineGuideGrinder:				dw SMW_NorSpr067_LineGuideGrinder_Status08_Main	; 67 - Grinder, line-guided
.NorSpr068_LineGuideFuzzy:				dw SMW_NorSpr068_LineGuideFuzzy_Status08_Main	; 68 - Fuzz ball, line-guided
.NorSpr069_Unused:					dw SMW_NorSpr069_Unused_Status08_Main	; 69 - Unused
.NorSpr06A_CoinGameCloud:				dw SMW_NorSpr06A_CoinGameCloud_Status08_Main	; 6A - Coin game cloud
.NorSpr06B_LeftWallSpringboard:				dw SMW_NorSpr06B_LeftWallSpringboard_Status08_Main	; 6B - Spring board, left wall
.NorSpr06C_RightWallSpringboard:			dw SMW_NorSpr06C_RightWallSpringboard_Status08_Main	; 6C - Spring board, right wall
.NorSpr06D_InvisibleBlock:				dw SMW_NorSpr06D_InvisibleBlock_Status08_Main	; 6D - Invisible solid block
.NorSpr06E_DinoRhino:					dw SMW_NorSpr06E_DinoRhino_Status08_Main	; 6E - Dino Rhino
.NorSpr06F_DinoTorch:					dw SMW_NorSpr06F_DinoTorch_Status08_Main	; 6F - Dino Torch
.NorSpr070_Pokey:					dw SMW_NorSpr070_Pokey_Status08_Main	; 70 - Pokey
.NorSpr071_RedCapeSuperKoopa:				dw SMW_NorSpr071_RedCapeSuperKoopa_Status08_Main	; 71 - Super Koopa, red cape
.NorSpr072_YellowCapeSuperKoopa:			dw SMW_NorSpr072_YellowCapeSuperKoopa_Status08_Main	; 72 - Super Koopa, yellow cape
.NorSpr073_GroundSuperKoopa:				dw SMW_NorSpr073_GroundSuperKoopa_Status08_Main	; 73 - Super Koopa, feather
.NorSpr074_Mushroom:					dw SMW_NorSpr074_Mushroom_Status08_Main	; 74 - Mushroom
.NorSpr075_FireFlower:					dw SMW_NorSpr075_FireFlower_Status08_Main	; 75 - Flower
.NorSpr076_Star:					dw SMW_NorSpr076_Star_Status08_Main	; 76 - Star
.NorSpr077_Feather:					dw SMW_NorSpr077_Feather_Status08_Main	; 77 - Feather
.NorSpr078_1upMushroom:					dw SMW_NorSpr078_1upMushroom_Status08_Main	; 78 - 1-Up
.NorSpr079_VineHead:					dw SMW_NorSpr079_VineHead_Status08_Main	; 79 - Growing Vine
.NorSpr07A_Fireworks:					dw SMW_NorSpr07A_Fireworks_Status08_Main	; 7A - Firework
.NorSpr07B_GoalTape:					dw SMW_NorSpr07B_GoalTape_Status08_Main	; 7B - Goal Point
.NorSpr07C_PrincessPeach:				dw SMW_NorSpr07C_PrincessPeach_Status08_Main	; 7C - Princess Peach
.NorSpr07D_PBalloon:					dw SMW_NorSpr07D_PBalloon_Status08_Main	; 7D - Balloon
.NorSpr07E_FlyingRedCoin:				dw SMW_NorSpr07E_FlyingRedCoin_Status08_Main	; 7E - Flying Red coin
.NorSpr07F_Flying1up:					dw SMW_NorSpr07F_Flying1up_Status08_Main	; 7F - Flying yellow 1-Up
.NorSpr080_Key:						dw SMW_NorSpr080_Key_Status08_Main	; 80 - Key
.NorSpr081_ChangingItem:				dw SMW_NorSpr081_ChangingItem_Status08_Main	; 81 - Changing item from translucent block
.NorSpr082_BonusGame:					dw SMW_NorSpr082_BonusGame_Status08_Main	; 82 - Bonus game sprite
.NorSpr083_LeftFlyingBlock:				dw SMW_NorSpr083_LeftFlyingBlock_Status08_Main	; 83 - Left flying question block
.NorSpr084_HorizontalFlyingBlock:			dw SMW_NorSpr084_HorizontalFlyingBlock_Status08_Main	; 84 - Flying question block
.NorSpr085_Unused:					dw SMW_NorSpr085_Unused_Status08_Main	; 85 - Unused (Pretty sure)
.NorSpr086_Wiggler:					dw SMW_NorSpr086_Wiggler_Status08_Main	; 86 - Wiggler
.NorSpr087_LakituCloud:					dw SMW_NorSpr087_LakituCloud_Status08_Main	; 87 - Lakitu's cloud
.NorSpr088_WingedCage:					dw SMW_NorSpr088_WingedCage_Status08_Main	; 88 - Unused (Winged cage sprite)
.NorSpr089_Layer3Smasher:				dw SMW_NorSpr089_Layer3Smasher_Status08_Main	; 89 - Layer 3 smash
.NorSpr08A_Bird:					dw SMW_NorSpr08A_Bird_Status08_Main	; 8A - Bird from Yoshi's house
.NorSpr08B_FireplaceSmoke:				dw SMW_NorSpr08B_FireplaceSmoke_Status08_Main	; 8B - Puff of smoke from Yoshi's house
.NorSpr08C_SideExitAndFireplace:			dw SMW_NorSpr08C_SideExitAndFireplace_Status08_Main	; 8C - Fireplace smoke/exit from side screen
.NorSpr08D_GhostHouseDoor:				dw SMW_NorSpr08D_GhostHouseDoor_Status08_Main	; 8D - Ghost house exit sign and door
.NorSpr08E_WarpHole:					dw SMW_NorSpr08E_WarpHole_Status08_Main	; 8E - Invisible "Warp Hole" blocks
.NorSpr08F_ScalePlatform:				dw SMW_NorSpr08F_ScalePlatform_Status08_Main	; 8F - Scale platforms
.NorSpr090_GreenGasBubble:				dw SMW_NorSpr090_GreenGasBubble_Status08_Main	; 90 - Large green gas bubble
.NorSpr091_CharginChuck:				dw SMW_NorSpr091_CharginChuck_Status08_Main	; 91 - Chargin' Chuck
.NorSpr092_SplittinChuck:				dw SMW_NorSpr092_SplittinChuck_Status08_Main	; 92 - Splittin' Chuck
.NorSpr093_BouncinChuck:				dw SMW_NorSpr093_BouncinChuck_Status08_Main	; 93 - Bouncin' Chuck
.NorSpr094_WhistlinChuck:				dw SMW_NorSpr094_WhistlinChuck_Status08_Main	; 94 - Whistlin' Chuck
.NorSpr095_ClappinChuck:				dw SMW_NorSpr095_ClappinChuck_Status08_Main	; 95 - Clapin' Chuck
.NorSpr096_CharginChuckCopy:				dw SMW_NorSpr096_CharginChuckCopy_Status08_Main	; 96 - Unused (Chargin' Chuck clone)
.NorSpr097_PuntinChuck:					dw SMW_NorSpr097_PuntinChuck_Status08_Main	; 97 - Puntin' Chuck
.NorSpr098_PitchinChuck:				dw SMW_NorSpr098_PitchinChuck_Status08_Main	; 98 - Pitchin' Chuck
.NorSpr099_VolcanoLotus:				dw SMW_NorSpr099_VolcanoLotus_Status08_Main	; 99 - Volcano Lotus
.NorSpr09A_SumoBro:					dw SMW_NorSpr09A_SumoBro_Status08_Main	; 9A - Sumo Brother
.NorSpr09B_HammerBro:					dw SMW_NorSpr09B_HammerBro_Status08_Main	; 9B - Hammer Brother
.NorSpr09C_HammerBroPlatform:				dw SMW_NorSpr09C_HammerBroPlatform_Status08_Main	; 9C - Flying blocks for Hammer Brother
.NorSpr09D_BubbleWithSprite:				dw SMW_NorSpr09D_BubbleWithSprite_Status08_Main	; 9D - Bubble with sprite
.NorSpr09E_BallNChain:					dw SMW_NorSpr09E_BallNChain_Status08_Main	; 9E - Ball and Chain
.NorSpr09F_BanzaiBill:					dw SMW_NorSpr09F_BanzaiBill_Status08_Main	; 9F - Banzai Bill
.NorSpr0A0_ActivateBowserBattle:			dw SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main	; A0 - Activates Bowser scene
.NorSpr0A1_BowserBowlingBall:				dw SMW_NorSpr0A1_BowserBowlingBall_Status08_Main	; A1 - Bowser's bowling ball
.NorSpr0A2_MechaKoopa:					dw SMW_NorSpr0A2_MechaKoopa_Status08_Main	; A2 - MechaKoopa
.NorSpr0A3_GreyChainedPlatform:				dw SMW_NorSpr0A3_GreyChainedPlatform_Status08_Main	; A3 - Grey platform on chain
.NorSpr0A4_SpikeBall:					dw SMW_NorSpr0A4_SpikeBall_Status08_Main	; A4 - Floating Spike ball
.NorSpr0A5_Sparky:					dw SMW_NorSpr0A5_Sparky_Status08_Main	; A5 - Fuzzball/Sparky, ground-guided
.NorSpr0A6_Hothead:					dw SMW_NorSpr0A6_Hothead_Status08_Main	; A6 - HotHead, ground-guided
.NorSpr0A7_IggyBall:					dw SMW_NorSpr0A7_IggyBall_Status08_Main	; A7 - Iggy's ball
.NorSpr0A8_Blargg:					dw SMW_NorSpr0A8_Blargg_Status08_Main	; A8 - Blargg
.NorSpr0A9_Reznor:					dw SMW_NorSpr0A9_Reznor_Status08_Main	; A9 - Reznor
.NorSpr0AA_Fishbone:					dw SMW_NorSpr0AA_Fishbone_Status08_Main	; AA - Fishbone
.NorSpr0AB_Rex:						dw SMW_NorSpr0AB_Rex_Status08_Main	; AB - Rex
.NorSpr0AC_DownFirstWoodenSpike:			dw SMW_NorSpr0AC_DownFirstWoodenSpike_Status08_Main	; AC - Wooden Spike, moving down and up
.NorSpr0AD_UpDownFirstWoodenSpike:			dw SMW_NorSpr0AD_UpDownFirstWoodenSpike_Status08_Main	; AD - Wooden Spike, moving up/down first
.NorSpr0AE_FishinBoo:					dw SMW_NorSpr0AE_FishinBoo_Status08_Main	; AE - Fishin' Boo
.NorSpr0AF_BooBlock:					dw SMW_NorSpr0AF_BooBlock_Status08_Main	; AF - Boo Block
.NorSpr0B0_ReflectingBooBuddies:			dw SMW_NorSpr0B0_ReflectingBooBuddies_Status08_Main	; B0 - Reflecting stream of Boo Buddies
.NorSpr0B1_CreateEatBlock:				dw SMW_NorSpr0B1_CreateEatBlock_Status08_Main	; B1 - Creating/Eating block
.NorSpr0B2_FallingSpike:				dw SMW_NorSpr0B2_FallingSpike_Status08_Main	; B2 - Falling Spike
.NorSpr0B3_BowserStatueFire:				dw SMW_NorSpr0B3_BowserStatueFire_Status08_Main	; B3 - Bowser statue fireball
.NorSpr0B4_NonLineGuideGrinder:				dw SMW_NorSpr0B4_NonLineGuideGrinder_Status08_Main	; B4 - Grinder, non-line-guided
.NorSpr0B5_SinkingFireball:				dw SMW_NorSpr0B5_SinkingFireball_Status08_Main	; B5 - Sinking fireball used in boss battles
.NorSpr0B6_ReflectingPodoboo:				dw SMW_NorSpr0B6_ReflectingPodoboo_Status08_Main	; B6 - Reflecting fireball
.NorSpr0B7_CarrotTopLiftUpperRight:			dw SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status08_Main	; B7 - Carrot Top lift, upper right
.NorSpr0B8_CarrotTopLiftUpperLeft:			dw SMW_NorSpr0B8_CarrotTopLiftUpperLeft_Status08_Main	; B8 - Carrot Top lift, upper left
.NorSpr0B9_MessageBox:					dw SMW_NorSpr0B9_MessageBox_Status08_Main	; B9 - Info Box
.NorSpr0BA_TimedPlatform:				dw SMW_NorSpr0BA_TimedPlatform_Status08_Main	; BA - Timed lift
.NorSpr0BB_MovingCastleStone:				dw SMW_NorSpr0BB_MovingCastleStone_Status08_Main	; BB - Grey moving castle block
.NorSpr0BC_BowserStatue:				dw SMW_NorSpr0BC_BowserStatue_Status08_Main	; BC - Bowser statue
.NorSpr0BD_SlidingNakedBlueKoopa:			dw SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status08_Main	; BD - Sliding Koopa without a shell
.NorSpr0BE_Swooper:					dw SMW_NorSpr0BE_Swooper_Status08_Main	; BE - Swooper bat
.NorSpr0BF_MegaMole:					dw SMW_NorSpr0BF_MegaMole_Status08_Main	; BF - Mega Mole
.NorSpr0C0_SinkingLavaPlatform:				dw SMW_NorSpr0C0_SinkingLavaPlatform_Status08_Main	; C0 - Grey platform on lava
.NorSpr0C1_WingedPlatform:				dw SMW_NorSpr0C1_WingedPlatform_Status08_Main	; C1 - Flying grey turnblocks
.NorSpr0C2_Blurp:					dw SMW_NorSpr0C2_Blurp_Status08_Main	; C2 - Blurp fish
.NorSpr0C3_PorcuPuffer:					dw SMW_NorSpr0C3_PorcuPuffer_Status08_Main	; C3 - Porcu-Puffer fish
.NorSpr0C4_GreyFallingPlatform:				dw SMW_NorSpr0C4_GreyFallingPlatform_Status08_Main	; C4 - Grey platform that falls
.NorSpr0C5_BigBooBoss:					dw SMW_NorSpr0C5_BigBooBoss_Status08_Main	; C5 - Big Boo Boss
.NorSpr0C6_Spotlight:					dw SMW_NorSpr0C6_Spotlight_Status08_Main	; C6 - Dark room with spot light
.NorSpr0C7_InvisibleMushroom:				dw SMW_NorSpr0C7_InvisibleMushroom_Status08_Main	; C7 - Invisible mushroom
.NorSpr0C8_LightSwitch:					dw SMW_NorSpr0C8_LightSwitch_Status08_Main	; C8 - Light switch block for dark room
base off
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GetRand(Address)
namespace SMW_GetRand
%InsertMacroAtXPosition(<Address>)

; Random number generation subroutine. Uses the current seed in $148B to
; generate a 16-bit random number output to $148D. The value of $148D is
; also returned directly in A.
Main:
	PHY
	LDY.b #$01
	JSL.l CODE_01AD07
	DEY
	JSL.l CODE_01AD07
	PLY
	RTL

CODE_01AD07:
	LDA.w !RAM_SMW_Misc_RNGRoutineScratchRAM148B
	ASL
	ASL
	SEC
	ADC.w !RAM_SMW_Misc_RNGRoutineScratchRAM148B
	STA.w !RAM_SMW_Misc_RNGRoutineScratchRAM148B
	ASL.w !RAM_SMW_Misc_RNGRoutineScratchRAM148C
	LDA.b #$20
	BIT.w !RAM_SMW_Misc_RNGRoutineScratchRAM148C
	BCC.b CODE_01AD21
	BEQ.b CODE_01AD26
	BNE.b CODE_01AD23
CODE_01AD21:
	BNE.b CODE_01AD26
CODE_01AD23:
	INC.w !RAM_SMW_Misc_RNGRoutineScratchRAM148C
CODE_01AD26:
	LDA.w !RAM_SMW_Misc_RNGRoutineScratchRAM148C
	EOR.w !RAM_SMW_Misc_RNGRoutineScratchRAM148B
	STA.w !RAM_SMW_Misc_RandomByte1,y
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_UpdateNormalSpritePositionBank01(Address)
namespace SMW_UpdateNormalSpritePositionBank01
%InsertMacroAtXPosition(<Address>)

; The subroutine that updates a sprite's Y position without gravity. JSRs
; into $01ABD8 which is the main handler of adjusting the sprite's position.
Main:
.Y:
	PHB				; This starts the updating of the
	PHK				; Ypos on a sprite
	PLB
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	PLB
	RTL

.X:
;$018022
	; The subroutine that updates a sprite's X position without gravity. JSRs
	; into $01ABCC, which adds the sprite's index number by 12 (which is the
	; number of existing sprite slots), then JSRs again into $01ABD8 so that it
	; will handle moving the X position of the sprite.
	PHB				; This starts the updating of the Xpos
	PHK				; on a sprite.
	PLB
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_UpdateNormalSpritePositionBank01(Address)
namespace SMW_UpdateNormalSpritePositionBank01
%InsertMacroAtXPosition(<Address>)

; Routine used to update a sprite's X and Y position ($E4/$14E0/$14F8 and
; $D8/$14D4/$14EC) by its speed ($AA and $B6). Specifically, this consists
; of two different callpoints at $01ABCC and $01ABD8 for updating the X and
; Y position respectively. JSL wrappers for this exist at $018022 (updates X
; position) and $01801A (updates Y position). Alternatively, you can call
; $01802A to update both the X and Y position while additionally applying
; gravity and processing object interaction. This also records the number of
; pixels moved in $1491. The original game uses this mainly to move Mario
; along with the sprite for platforms.
Sub:
.X:
if defined("Define_SMW_SA1")
	JSL.l SubSprXPosNoGrvty
	RTS
else
	TXA
	CLC				;\Index + 12 to handle X speed instead of Y
	ADC.b #!Define_SMW_MaxNormalSpriteSlot+$01	;/
	TAX
endif
	JSR.w .Y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

.Y:
;$01ABD9
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	; Load current sprite's Y speed
	BEQ.b ++			; If speed is 0, branch to $AC09
	ASL
	ASL				; |Multiply speed by 16
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_NorSpr_SubYPos,x	; |Increase (unknown sprite table) by that value
	STA.w !RAM_SMW_NorSpr_SubYPos,x
	PHP				;\Push processer flags (we are working with the carry flag, that is, when the subpixels value exceeds 1/16th (exceeds %11110000))
	PHP				;/
	LDY.b #$00			;>High byte handler of the sprite's XY pos, either add by $FF for negative or $00 for positive on that high byte
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	; Load current sprite's Y speed
	LSR
	LSR				; |Multiply speed by 16
	LSR
	LSR
	CMP.b #$08			;\If less than 8, the sprite is going at positive speed (rightwards or downwards)
	BCC.b +				;/
	ORA.b #$F0			;\Negative speed
	DEY				;/>Decrement high byte to make this negative
+:
	PLP				;>Retrieve the processer flag so we use the carry
	PHA				;>Preserve the displacement value
	ADC.b !RAM_SMW_NorSpr_YPosLo_x	; \ Add value to current sprite's Y position
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	TYA				;\Apply the modification to similar to above but high byte
	ADC.w !RAM_SMW_NorSpr_YPosHi,x	;|
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;/
	PLA				;\Retrieve the displacement value
	PLP				;|
	ADC.b #$00			;/
++:
	STA.w !RAM_SMW_Sprites_PositionDisp	;>This contains the amount of pixels moved (signed), so that things like platforms moving should move the player with it.
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_UnnecessaryInvertARt(Address)
namespace SMW_UnnecessaryInvertARt
%InsertMacroAtXPosition(<Address>)

Bank01:
	%INLINEROUTINE_SMW_UnnecessaryInvertARt()
namespace off
endmacro

macro ROUTINE_RT01_SMW_UnnecessaryInvertARt(Address)
namespace SMW_UnnecessaryInvertARt
%InsertMacroAtXPosition(<Address>)

CopyOfBank01:
	%INLINEROUTINE_SMW_UnnecessaryInvertARt()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GetDrawInfo(Address)
namespace SMW_GetDrawInfo
%InsertMacroAtXPosition(<Address>)

DATA_01A361:									;\ Optimization: Unnecessary tables if the below optimization is done.
	db $10,$20								;|
										;|
DATA_01A363:									;|
	db $01,$02								;/

Bank01:
	STZ.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	STZ.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BEQ.b CODE_01A379
	INC.w !RAM_SMW_NorSpr_XOffscreenFlag,x
CODE_01A379:
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	XBA
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
	BNE.b CODE_01A3CB
	LDY.b #$00								;\ Optimization: The only place bit 2 of !RAM_SMW_NorSpr_YOffscreenFlag is even specifically read is SMW_GenericGFXRtMoveTileOffscreenVertically.
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x					;| I believe that routine is a leftover before Nintendo wrote a more flexible routine for moving sprite tiles offscreen and they forgot to remove it.
	CMP.b #!Define_SMW_NorSprStatus09_Stunned				;| To fix, replace the two JSR.w SMW_GenericGFXRtMoveTileOffscreenVertically with some code to set up A/Y and JMP to SMW_FinishOAMWrite_Sub.
	BEQ.b CODE_01A3A6							;| This code then needs to be updated to remove the loop and change the ADC.w table,y to ADC.b #$YY, with YY being between #$0C and #$20.
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,x				;|
	AND.b #!Define_SMW_NorSpr_190FProp_2TileTallDeathFrame			;|
	BEQ.b CODE_01A3A6							;|
	INY									;|
CODE_01A3A6:									;|
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;|
	CLC									;|
	ADC.w DATA_01A361,y							;|
	PHP									;|
	CMP.b !RAM_SMW_Mirror_CurrentLayer1YPosLo				;|
	ROL.b !RAM_SMW_Misc_ScratchRAM00					;|
	PLP									;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x						;|
	ADC.b #$00								;|
	LSR.b !RAM_SMW_Misc_ScratchRAM00					;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi				;|
	BEQ.b CODE_01A3C6							;|
	LDA.w !RAM_SMW_NorSpr_YOffscreenFlag,x					;|
	ORA.w DATA_01A363,y							;|
	STA.w !RAM_SMW_NorSpr_YOffscreenFlag,x					;|
CODE_01A3C6:									;|
	DEY									;|
	BPL.b CODE_01A3A6							;/
	BRA.b CODE_01A3CD

CODE_01A3CB:
	PLA
	PLA
CODE_01A3CD:
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_ProcessNormalSprites(Address)
namespace SMW_ProcessNormalSprites
%InsertMacroAtXPosition(<Address>)

; Routine that runs all the normal and cluster sprites routines.
Main:
if defined("Define_SMW_SA1")
	JML.l SpriteMain
	NOP #2
else
	PHB				;Start of a routine, it seems.
	PHK
	PLB
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2
endif
	STA.w !RAM_SMW_Player_CarryingSomethingFlag1	; Reset carrying enemy flag
	STZ.w !RAM_SMW_Player_CarryingSomethingFlag2	;Stop mario from holding whatever he has
	STZ.w !RAM_SMW_Misc_PlayerOnSolidSprite	;Reset what platform mario is on
	STZ.w !RAM_SMW_Flag_PlayerInLakitusCloud	;Reset flag for mario is standing normally
	LDA.w !RAM_SMW_Sprites_YoshiSlotIndex	;\If yoshi exists (I think that's what this is)
	STA.w !RAM_SMW_Yoshi_StrayYoshiFlag	;/then make him loose!
	STZ.w !RAM_SMW_Sprites_YoshiSlotIndex	; ...and then destroy him. Cool.
	LDX.b #!Define_SMW_MaxNormalSpriteSlot
CODE_0180A9:
if defined("Define_SMW_SA1")
	; SA-1 Pack: Hack main sprite routine.
	JSL.l SPRITE_MAIN_HACK
	NOP
	NOP
else
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
	JSR.w GetNormalSpriteOAMIndexAndDecrementTimers	; This routine decrements all the sprite timers.
endif
	JSR.w HandleSprite		;Well, what do you think this is? :p
	DEX				;And continue doing that until
	BPL.b CODE_0180A9		;you've  handled every sprite.
	LDA.w !RAM_SMW_Flag_RunClusterSprites	;\
	BEQ.b CODE_0180BE		;/ if some address is 00, then  don't run this next routine
if defined("Define_SMW_SA1")
	; SA-1 Pack: A few cluster sprites "steal" slot 0 of the ordinary sprite
	; tables in order to call subroutines that are normally called by ordinary
	; sprites. For this reason, set our pointer to point to index 0 before
	; processing cluster sprites.
	JSL.l CLUSTER_SPRITE_SET
else
	JSL.l SMW_ProcessClusterSprites_Main	; some kind of sprite handling routine, not my area
endif
CODE_0180BE:
	LDA.w !RAM_SMW_Sprites_YoshiSlotIndex	; probably yoshi related
	BNE.b CODE_0180C9		; if it is not 00, then return
	STZ.w !RAM_SMW_Player_RidingYoshiFlag	;\Get rid of yoshi
	STZ.w !RAM_SMW_Player_RelativeYPositionDuringScreenShake	;/
CODE_0180C9:
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_ProcessNormalSprites(Address)
namespace SMW_ProcessNormalSprites
%InsertMacroAtXPosition(<Address>)

; Routine that gets the current sprite's OAM index and decrements all the
; sprite timers.
GetNormalSpriteOAMIndexAndDecrementTimers:
if defined("Define_SMW_SA1")
	BRA.b +
	NOP #13
+
	JSL.l pick_oam_slot
else
	PHX				; In all sprite routines, X = current sprite
	TXA
	LDX.w !RAM_SMW_Sprites_SpriteMemorySetting	; $1692 = Current Sprite memory settings
	CLC
	ADC.l DATA_07F0B4,x		; |Add $07:F0B4,$1692 to sprite index.  i.e. minimum one tile allotted to each sprite
	TAX				; |the bytes read go straight to the OAM indexes
	LDA.l NormalSpriteOAMIndexes,x
	PLX
	STA.w !RAM_SMW_NorSpr_OAMIndex,x	; Current sprite's OAM index
endif
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; If  (something related to current sprite) is 0
	BEQ.b Return018126		; do not decrement these counters
	LDA.b !RAM_SMW_Flag_SpritesLocked	; Lock sprites timer
	BNE.b Return018126		; if sprites locked, do not decrement counters
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x	; \ Decrement a bunch of sprite counter tables
	BEQ.b CODE_0180F6
	DEC.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x	; |Do not decrement any individual counter if it's already at zero
CODE_0180F6:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	BEQ.b CODE_0180FE
	DEC.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
CODE_0180FE:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	BEQ.b CODE_018106
	DEC.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
CODE_018106:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x
	BEQ.b CODE_01810E
	DEC.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x
CODE_01810E:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1FE2,x
	BEQ.b CODE_018116
	DEC.w !RAM_SMW_NorSpr_DecrementingTable7E1FE2,x
CODE_018116:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E15AC,x
	BEQ.b CODE_01811E
	DEC.w !RAM_SMW_NorSpr_DecrementingTable7E15AC,x
CODE_01811E:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	BEQ.b Return018126
	DEC.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
Return018126:
	RTS

HandleSprite:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; Call a routine based on the sprite's status
	BEQ.b SMW_NorSprStatus00_EmptySlot_Main	; Routine for status 0 hardcoded, maybe for performance
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_018133		; Routine for status 8 hardcoded, maybe for preformance
	JMP.w SMW_NorSprStatus08_Normal_Main

CODE_018133:
if !SMW_CustomSprites_StatusWanted == !TRUE
	; The same four bytes as the trampoline call, whenever the custom
	; sprites are on. The stub runs a custom slot's own routines --
	; its status rows, and its main at the statuses PIXI's contract
	; owes it -- and reaches this same table by name for everything
	; else, where $9E's acts-like number already chooses the
	; behaviour. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Status
else
	JSL.l SMW_ExecutePtr_Absolute
endif

SpriteStatusPtr:
base $000000
; Sprite status subroutine pointers. These are called based on the value of
; $14C8,x; valid values are 00-0C.
.NorSprStatus00_EmptySlot:	dw SMW_NorSprStatus00_EmptySlot_Main	; 0 - Non-existant (Bypassed above)
.NorSprStatus01_Init:		dw SMW_NorSprStatus01_Init_Main	; 1 - Initialization
.NorSprStatus02_Dead:		dw SMW_NorSprStatus02_Dead_Main	; 2 - Falling off screen (hit by star, shell, etc)
.NorSprStatus03_Smushed:	dw SMW_NorSprStatus03_Smushed_Main	; 3 - Smushed
.NorSprStatus04_SpinJumpKill:	dw SMW_NorSprStatus04_SpinJumpKill_Main	; 4 - Spin Jumped
.NorSprStatus05_SinkInLava:	dw SMW_NorSprStatus05_SinkInLava_Main	; 5
.NorSprStatus06_GoalCoins:	dw SMW_NorSprStatus06_GoalCoins_Main	; 6 - End of level turn to coin
.NorSprStatus07_InLimbo:	dw SMW_NorSprStatus07_InLimbo_Main	; 7 - Unused
.NorSprStatus08_Normal:		dw SMW_NorSprStatus08_Return			; Note: The actual code for status 08 is called a bit earlier in the code
.NorSprStatus09_Stunned:	dw SMW_NorSprStatus09_Stunned_Main	; 9 - Stationary (Carryable, flipped, stunned)
.NorSprStatus0A_Kicked:		dw SMW_NorSprStatus0A_Kicked_Main	; A - Kicked
.NorSprStatus0B_Carried:	dw SMW_NorSprStatus0B_Carried_Main	; B - Carried
.NorSprStatus0C_GoalPowerUp:	dw SMW_NorSprStatus0C_GoalPowerUp_Main	; C - Power up from carrying a sprite past the goal tape
base off
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprStatus00_EmptySlot(Address)
namespace SMW_NorSprStatus00_EmptySlot
%InsertMacroAtXPosition(<Address>)

; This is sprite status #$00, which is is called when a sprite is either
; dead or nonexistent. It also sets $161A,x to #$FF to prevent that sprite
; from being reloaded.
Main:
	LDA.b #$FF			; \ Permanently erase sprite:
	STA.w !RAM_SMW_NorSpr_LoadStatusTableIndex,x	; | By changing the sprite's index into the level tables
Return:
	RTS				; / the actual sprite won't get marked for reloading
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprStatus00_EmptySlot_Return, SMW_NorSprStatus07_InLimbo_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_FinishOAMWrite(Address)
; Optimization: This routine is not very well optimized.
; Is there any particular reason this routine barely used 16-bit A?

namespace SMW_FinishOAMWrite
%InsertMacroAtXPosition(<Address>)

; JSL wrapper for the finish OAM write routine at $01B7BB. This routine is
; used to set up the data in $0460 for a defined set of sprite tiles.
; Arguments: A: Number of tiles to update, minus 1. Y: Tile size. 00 = 8x8,
; 02 = 16x16, 80+ = manually set via $0460 (i.e. only calculate the X bit).
; $0300, $0301: Must already be set to the X/Y position for each tile.
; $15EA: OAM index of the first tile to write for. Generally, this does not
; need to be manually set. Calling this routine overwrites the entire
; scratch RAM range at $00-$0B.
Main:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

; Finish OAM write routine, used to set up the data in $0460 for a set of
; sprite tiles. See its JSL wrapper at $01B7B3 for more information.
Sub:
	STY.b !RAM_SMW_Misc_ScratchRAM0B	;>$0B = tile size
	STA.b !RAM_SMW_Misc_ScratchRAM08	;>$08 = Numb of OAM slot tiles (include 0)
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\$00 = sprite Y pos low byte
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	SEC				;\$06 = Y position on-screen
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM06	;/
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;\$01 = sprite Y pos high byte
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\$02 = sprite X pos low byte
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	SEC				;\$07 = sprite X pos on-screen
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM07	;/
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;\$03 = sprite X pos high byte
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
CODE_01B7DE:
	TYA				;\Transfer RAM_SprOAMIndex into A,
	LSR				;|divide by 4 (divide by 2 twice),
	LSR				;|transfer to X for OAM size ($0420)
	TAX				;/(4 byte -> 1 byte index conversion)
	LDA.b !RAM_SMW_Misc_ScratchRAM0B	;\Um, Okay? Since $0B would be either #$00 or #$02
	BPL.b CODE_01B7F0		;/this branch will always be taken.
	LDA.w SMW_OAMTileSizeBuffer[$40].Slot,x	;\Clear all bits except bit 1 (#%00000010)
	AND.b #$02			;|and store it to tile size
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x	;/
	BRA.b CODE_01B7F3		;>Skip below code

CODE_01B7F0:
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x	;>Set OAM tile size.
CODE_01B7F3:
	LDX.b #$00			;>X index = 0
	LDA.w SMW_OAMBuffer[!OAM_SMW_GenericNormalSprite&$40].XDisp,y	;>Move tile X pos
	SEC				;\Subtract by X pos by distance between left edge of scrn
	SBC.b !RAM_SMW_Misc_ScratchRAM07	;/and sprite
	BPL.b CODE_01B7FE		;>If positive (tile not past left edge of screen), don't wrap the tile (skip DEX)
	DEX				;>X = #$FF
CODE_01B7FE:
	CLC				;\Add by x position relative to level
	ADC.b !RAM_SMW_Misc_ScratchRAM02	;/
	STA.b !RAM_SMW_Misc_ScratchRAM04	;>$04 = tile x pos relative to screen?
	TXA				;>Transfer X (#$00 or #$FF) to A
	ADC.b !RAM_SMW_Misc_ScratchRAM03	;>Add by sprite X pos high byte
	STA.b !RAM_SMW_Misc_ScratchRAM05	;>$05 = X pos relative to screen high byte? (ScreenXpos + XPosOnScrn = XPosInLvl)
	JSR.w CODE_01B844		;>Offscreen X position check
	BCC.b CODE_01B819		;>If on-screen, skip conversion below
	TYA				;\4 byte -> 1 byte index conversion
	LSR				;|and transfer to X.
	LSR				;|
	TAX				;/
	LDA.w SMW_OAMTileSizeBuffer[$40].Slot,x	;\Set bit 0 of tile size (#%00000001)
	ORA.b #$01			;|
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x	;/
CODE_01B819:
	LDX.b #$00			;>X = #$00
	LDA.w SMW_OAMBuffer[$40].YDisp,y	;\Tile Y position subtract by Y pos on-screen
	SEC				;|(Tile Y pos on-screen, I think)
	SBC.b !RAM_SMW_Misc_ScratchRAM06	;/
	BPL.b CODE_01B824		;>If positive (not past the top edge of screen), skip
	DEX				;>X = #$FF
CODE_01B824:
	CLC				;\Add by sprite Y pos low byte
	ADC.b !RAM_SMW_Misc_ScratchRAM00	;/
	STA.b !RAM_SMW_Misc_ScratchRAM09	;>$09 = tile y pos relative to screen?
	TXA				;>Transfer X (#$00 or #$FF)to A
	ADC.b !RAM_SMW_Misc_ScratchRAM01	;\Add by Y pos high byte
	STA.b !RAM_SMW_Misc_ScratchRAM0A	;/
	JSR.w SMW_NorSpr05F_BrownChainedPlatform_Status08_CODE_01C9BF	;>Offscreen Y position check
	BCC.b CODE_01B838		;>If on-screen, skip "clearing" a tile
	LDA.b #$F0			;\If off-screen, hide tile (Y = #$F0, the bottom of screen) to
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/not show wrapped gfx. This position is used to detect if that slot is free.
CODE_01B838:
	INY				;\Next slot (remember that OAM table, each data is 4 bytes long:
	INY				;|xxxxxxxx yyyyyyyy tttttttt yxppccct)
	INY				;|
	INY				;/
	DEC.b !RAM_SMW_Misc_ScratchRAM08	;>Decrement number of OAM slots (loop counter) by 1
	BPL.b CODE_01B7DE		;>Loop until Y index is negative (DEC $xx doesn't effect A)
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

CODE_01B844:								; Note: This routine is also called elsewhere.
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.w #$0100
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BoostMarioSpeed(Address)					; Info: Routine that sets Mario's upwards speed when jumping on enemies.
namespace SMW_BoostMarioSpeed
%InsertMacroAtXPosition(<Address>)

; Boost player subroutine. Boosts the player up a bit or a lot depending on
; whether A/B are being pressed.
Main:
	LDA.b !RAM_SMW_Player_ClimbingFlag	; \ Return if climbing
	BNE.b Return01AA41
	LDA.b #$D0
	BIT.b !RAM_SMW_IO_ControllerHold1
	BPL.b CODE_01AA3F							; Note: !Joypad_A|(!Joypad_B>>8)
	LDA.b #$A8
CODE_01AA3F:
	STA.b !RAM_SMW_Player_YSpeed
Return01AA41:
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_GenericSpriteOAMData(Address)
namespace SMW_GenericSpriteOAMData
%InsertMacroAtXPosition(<Address>)

Tiles:
base $000000
; Standard Sprite Tile Table: Koopa tilemap
.Koopa:
	db $82,$A0		;\ Stand/Walk 1
	db $82,$A2		;| Walk 2
	db $84,$A4		;| Turn
	; Standard Sprite Tile Table: Koopa shell tilemap
	db $8C			;| Shell 1
	db $8A			;| Shell 2
	db $8E			;/ Shell 3

; Standard Sprite Tile Table: Shelless koopa tilemap (Fourth byte unused?)
.NakedKoopa:
	db $C8
	db $CA
	db $CA
	db $CE
	db $CC
	db $86
	db $4E

; Standard Sprite Tile Table: Blue shelless koopa tilemap (Fourth byte
; unused?)
.NakedBlueKoopa:
	db $E0
	db $E2
	db $E2
	db $CE
	db $E4
	db $E0
	db $E0

; Standard Sprite Tile Table: Para-goomba tilemap
.ParachuteGoomba:
	db $A3,$A3,$B3,$B3
	db $E9,$E8,$F9,$F8
	db $E8,$E9,$F8,$F9
	db $E2,$E6

; Standard Sprite Tile Table: Goomba tilemap
.Goomba:
	db $AA
	db $A8
	db $A8
	db $AA

; Standard Sprite Tile Table: Para-bomb tilemap
.ParachuteBomb:
	db $A2,$A2,$B2,$B2
	db $C3,$C2,$D3,$D2
	db $C2,$C3,$D2,$D3
	db $E2,$E6

; Standard Sprite Tile Table: Bob-omb tilemap
.BobOmb:
	db $CA
	db $CC
	db $CA

; Standard Sprite Tile Table: Piranha plant tilemap
.PiranhaPlant:
	db $AC,$CE
	db $AE,$CE
	db $83,$83,$C4,$C4
	db $83,$83,$C5,$C5

; Standard Sprite Tile Table: Football tilemap
.Football:
	db $8A

; Standard Sprite Tile Table: Bullet Bill tilemap (Horizontal, Vertical,
; Diagonal, Diagonal)
.BulletBill:
	db $A6
	db $A4
	db $A6
	db $A8

; Standard Sprite Tile Table: Spiny tilemap
.Spiny:
	db $80
	db $82
	db $80

; Standard Sprite Tile Table: Spiny egg tilemap
.SpinyEgg:
	db $84,$84,$84,$84
	db $94,$94,$94,$94

.DisplayMessage:					;\ Todo: Unused?
	db $A0,$B0,$A0,$D0				;/

; Standard Sprite Tile Table: Buzzy Beetle
.BuzzyBeetle:
	db $82
	db $80
	db $82
	db $00
	db $00
	db $00
	; Standard Sprite Tile Table: Buzzy Beetle Shell.
	db $86
	db $84
	db $88

; Spike Top tilemap
.SpikeTop:
	db $EC
	db $8C
	db $A8
	db $AA
	db $8E
	db $AC

; Hopping Flame tilemap
.HoppingFlame:
	db $AE
	db $8E

; Lakitu tilemap (3 frames, 2 bytes each)
.Lakitu:
	db $EC,$EE
	db $CE,$EE
	db $A8,$EE

.MovingLedgeHole:					;\ Todo: Unused?
	db $40,$40					;/

; Magikoopa Tilemap
.Magikoopa:
	db $A0,$C0
	db $A0,$C0
	db $A4,$C4
	db $A4,$C4
	db $A0,$C0
	db $A0,$C0

; Throw block sprite tilemap and turn block sprite with hidden enemies
; inside. (Both use the same byte)
.SpriteTurnBlock:
	db $40

; Climbing Koopa Tilemap
.NetKoopa:
	db $07,$27
	db $4C,$29
	db $4E,$2B
	db $82,$A0
	db $84,$A4

; Fish (Cheep Cheep) Tilemap (2 frames swimming, 2 frames flopping)
.CheepCheep:
	db $67,$69,$88,$CE

.Thwomp:						;\ Todo: Unused?
	db $8E,$AE					;/

; Thwimp Tilemap
.Thwimp:
	db $A2,$A2,$B2,$B2

; Yoshi Egg Tilemap (only manifests if the Yoshi egg is in the stunned
; status ($14C8 = #$09), i.e. found in a block or laid by Yoshi; otherwise,
; the tile loaded from this address is overwritten before drawing). Change
; alongside $01F760 - $01F763 and $01F794 to completely remap the Yoshi egg
; tiles.
.YoshiEgg:
	db $00

.BabyYoshi:						;\ Todo: Unused?
	db $40						;|
	db $44						;|
	db $42						;|
	db $2C						;/

.PSwitch:
	db $42

; Portable Springboard Tilemap
.PortableSpringboard:
	db $28,$28,$28,$28
	db $4C,$4C,$4C,$4C
	db $83,$83,$6F,$6F

.ThrowingDryBones:					;\ Todo: Unused?
	db $AC,$BC					;|
	db $AC,$A6					;/

; Bony Beetle tilemap
.BonyBeetle:
	db $8C
	db $AA
	db $86
	db $84

.LedgeDryBones:						;\ Todo: Unused?
	db $DC,$EC					;|
	db $DE,$EE					;/

; Vertical Fireball (Podoboo) tilemap.
.Podoboo:
	db $06,$06,$16,$16
	db $07,$07,$17,$17
	db $16,$16,$06,$06
	db $17,$17,$07,$07

.LudwigFire:						;\ Todo: Unused?
	db $84,$86					;/

.Yoshi:							;\ Todo: Unused?
	db $00,$00					;|
	db $00,$0E					;|
	db $2A,$24					;|
	db $02,$06					;|
	db $0A,$20					;|
	db $22,$28					;|
	db $26,$2E					;|
	db $40,$42					;|
	db $0C						;/

.Sprite036:
	db $04,$2B

; Eerie tilemap
.Eerie:
	db $6A
	db $ED

; Boo Ghost Tilemap
.Boo:
	db $88
	db $8C
	db $A8
	db $8E
	db $AA
	db $AE
	db $8C
	db $88
	db $A8

; Rip Van Fish Tilemap
.RipVanFish:
	db $AE
	db $AC
	db $8C
	db $8E

; Vertical Dolphin Tilemap
.VerticalDolphin:
	db $CE,$EE

; Diggin' Chuck's Rock Tilemap
.DigginChuckRock:
	db $C4
	db $C6

; Monty Mole Tilemap
.MontyMole:
	db $82
	db $84
	db $86

; Ledge-dwelling Mole's Dirt Tilemap (data shared with Goal Point Sphere's
; Tilemap)
.LedgeMontyDirtMole:
.GoalSphere:
	db $8C

; Ground-dwelling Monty Mole's Dirt (2 Air tiles, 2 Dirt Tiles, 2 Air tiles,
; 2 Dirt Tiles)
.GroundMontyDirtMole:
	db $CE,$CE,$88,$89
	db $CE,$CE,$89,$88

; Sumo Bros' Lightning Tilemap
.SumoLightning:
	db $F3,$CE,$F3,$CE

; Ninji Tilemap
.Ninji:
	db $A7
	db $A9
base off

; Table containing a sprite's location in the Standard Sprite Tile Table.
TilesOffset:
	db Tiles_NakedKoopa,Tiles_NakedKoopa,Tiles_NakedBlueKoopa,Tiles_NakedKoopa
	db Tiles_Koopa,Tiles_Koopa,Tiles_Koopa,Tiles_Koopa
	db Tiles_Koopa,Tiles_Koopa,Tiles_Koopa,Tiles_Koopa
	db Tiles_Koopa,Tiles_BobOmb,Tiles_Koopa,Tiles_Goomba
	db Tiles_Goomba,Tiles_BuzzyBeetle,Tiles_Koopa,Tiles_Spiny
	db Tiles_SpinyEgg,Tiles_CheepCheep,Tiles_CheepCheep,Tiles_CheepCheep
	db Tiles_CheepCheep,Tiles_DisplayMessage,Tiles_PiranhaPlant,Tiles_Football
	db Tiles_BulletBill,Tiles_HoppingFlame,Tiles_Lakitu,Tiles_Magikoopa
	db Tiles_Koopa,Tiles_Koopa,Tiles_NetKoopa,Tiles_NetKoopa
	db Tiles_NetKoopa,Tiles_NetKoopa,Tiles_Thwomp,Tiles_Thwimp
	db Tiles_Koopa,Tiles_Koopa,Tiles_PiranhaPlant,Tiles_SumoLightning
	db Tiles_YoshiEgg,Tiles_BabyYoshi,Tiles_SpikeTop,Tiles_PortableSpringboard
	db Tiles_ThrowingDryBones,Tiles_BonyBeetle,Tiles_LedgeDryBones,Tiles_Podoboo
	db Tiles_LudwigFire,Tiles_Yoshi,Tiles_Sprite036,Tiles_Boo
	db Tiles_Eerie,Tiles_Eerie,Tiles_VerticalDolphin,Tiles_VerticalDolphin
	db Tiles_VerticalDolphin,Tiles_RipVanFish,Tiles_PSwitch,Tiles_ParachuteGoomba
	db Tiles_ParachuteBomb,Tiles_VerticalDolphin,Tiles_VerticalDolphin,Tiles_VerticalDolphin
	db Tiles_Koopa,Tiles_DigginChuckRock,Tiles_Koopa,Tiles_CheepCheep
	db Tiles_DigginChuckRock,Tiles_Koopa,Tiles_GoalSphere,Tiles_MontyMole
	db Tiles_SpriteTurnBlock,Tiles_MontyMole,Tiles_MontyMole,Tiles_PiranhaPlant
	db Tiles_PiranhaPlant,Tiles_Ninji,Tiles_MovingLedgeHole,Tiles_SpriteTurnBlock

; X displacement for tiles in the first shared GFX routine ($019CF3).
XDisp:
	db $00,$08,$00,$08

; Y displacement for tiles in the first shared GFX routine ($019CF3).
YDisp:
	db $00,$00,$08,$08

; Properties for tiles in the first shared GFX routine ($019CF3). It's
; indexed by the value of $05 times 4.
Prop:
	db $00,$00,$00,$00
	db $00,$40,$00,$40
	db $00,$40,$80,$C0
	db $40,$40,$00,$00
	db $40,$00,$C0,$80
	db $40,$40,$40,$40
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_GenericGFXRtDraw4Tiles8x8Square(Address)
namespace SMW_GenericGFXRtDraw4Tiles8x8Square
%InsertMacroAtXPosition(<Address>)

; SMW's first shared subroutine for drawing sprites. This one draws four 8x8
; tiles in a 16x16 arrangement. Not very useful for custom sprites.
Main:
	PHB
	PHK
	PLB				; Well, guess! :p Start of the generic sprite
	JSR.w Sub			; graphics routine- what this exactly means I
	PLB				; am not sure. I'll find out though.
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_GenericGFXRtDraw4Tiles8x8Square(Address)
namespace SMW_GenericGFXRtDraw4Tiles8x8Square
%InsertMacroAtXPosition(<Address>)

; The first of the shared graphics subroutines. This one creates 4 8x8 tiles
; in a 16x16 block.
Sub:
	LDY.b #$00
Entry1:								; Note: This is only called by the portable springboard (?)
	STA.b !RAM_SMW_Misc_ScratchRAM05
	STY.b !RAM_SMW_Misc_ScratchRAM0F
	JSR.w SMW_GetDrawInfo_Bank01
	LDY.b !RAM_SMW_Misc_ScratchRAM0F			;\ Optimization: Why load $0F into Y then transfer it into A when Y is not used before being overwritten?
	TYA							;/
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	LDA.w !RAM_SMW_NorSpr_Table7E1602,x
	ASL
	ASL
	ADC.w SMW_GenericSpriteOAMData_TilesOffset,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM04
	PHX
Loop:
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w SMW_GenericSpriteOAMData_XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w SMW_GenericSpriteOAMData_YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	TAX
	LDA.w SMW_GenericSpriteOAMData_Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	TAX
	LDA.w SMW_GenericSpriteOAMData_Prop,x
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b Loop
	PLX
	LDA.b #$03
	LDY.b #$00
	JSR.w SMW_FinishOAMWrite_Sub
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_GenericGFXRtDraw2Tiles16x16sStacked(Address)
namespace SMW_GenericGFXRtDraw2Tiles16x16sStacked
%InsertMacroAtXPosition(<Address>)

; The second of the shared graphics subroutines. This one creates 2 16x16
; tiles in a 16x32 block, with the second one tile below the base position.
; It can also be called with a JSR to $019D67.
Main:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	BPL.b RightsideUp
	JSR.w UpsideDown
	RTS

RightsideUp:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TYA
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	CPY.b #!Define_SMW_SpriteID_NorSpr00F_Goomba
	BCS.b CODE_019D81
	ADC.b #$04
CODE_019D81:
	TAY
	PHY
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	LDA.w !RAM_SMW_NorSpr_Table7E1602,x
	ASL
	CLC
	ADC.w SMW_GenericSpriteOAMData_TilesOffset,y
	TAX
	PLY
	LDA.w SMW_GenericSpriteOAMData_Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_GenericSpriteOAMData_Tiles+$01,x
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$41].YDisp,y
CODE_019DA9:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	LSR
	LDA.b #$00
	ORA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	BCS.b CODE_019DBE
	ORA.b #$40
CODE_019DBE:
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	ORA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
	JSR.w SMW_GenericGFXRtMoveTileOffscreenVertically_Main
	RTS

UpsideDown:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TYA
	CLC
	ADC.b #$08
	TAY
	PHY
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	LDA.w !RAM_SMW_NorSpr_Table7E1602,x
	ASL
	CLC
	ADC.w SMW_GenericSpriteOAMData_TilesOffset,y
	TAX
	PLY
	LDA.w SMW_GenericSpriteOAMData_Tiles,x
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.w SMW_GenericSpriteOAMData_Tiles+$01,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$41].YDisp,y
	JMP.w CODE_019DA9
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_GenericGFXRtDraw1Tile16x16(Address)
namespace SMW_GenericGFXRtDraw1Tile16x16
%InsertMacroAtXPosition(<Address>)

; SMW's third shared subroutine for drawing sprites. This one draws a single
; 16x16 tile. It can be used by custom sprites, although you'll have to set
; the correct tile number in OAM afterwards (see the example code).
Main:
	PHB
	PHK
	PLB
	JSR.w Sub_Entry1
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_GenericGFXRtDraw1Tile16x16(Address)
namespace SMW_GenericGFXRtDraw1Tile16x16
%InsertMacroAtXPosition(<Address>)

Sub:
.Entry2:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	BRA.b CODE_019F0F

; The third of the shared graphics subroutines. This one creates a single
; 16x16 tile.
.Entry1:
	STZ.b !RAM_SMW_Misc_ScratchRAM04
CODE_019F0F:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x			;\ Optimization: !RAM_SMW_Misc_ScratchRAM02 isn't used in this routine.
	STA.b !RAM_SMW_Misc_ScratchRAM02			;/
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	LDA.w !RAM_SMW_NorSpr_Table7E1602,x
	CLC
	ADC.w SMW_GenericSpriteOAMData_TilesOffset,y
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	TAX
	LDA.w SMW_GenericSpriteOAMData_Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	LSR
	LDA.b #$00
	ORA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	BCS.b CODE_019F44
	EOR.b #$40
CODE_019F44:
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	ORA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	JSR.w SMW_GenericGFXRtMoveTileOffscreenVertically_Main
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_GenericGFXRtMoveTileOffscreenVertically(Address)
namespace SMW_GenericGFXRtMoveTileOffscreenVertically
%InsertMacroAtXPosition(<Address>)

; Optimization: Junk routine. See ROUTINE_SMW_GetDrawInfo for an explaination of how to disable this routine.
; This routine is like a poor man's version of FinishOAMWrite that is likely an old leftover routine.

; Routine called by the shared sprite GFX routines at $019D5F and $0190B2 to
; hide tiles that would be drawn offscreen vertically. It works for both 1
; and 2 tile high sprites by using the first two bits in $186C to determine
; which tile(s) should be hidden.
Main:
	LDA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BEQ.b Return01A40A
	PHX
	LSR
	BCC.b CODE_01A3F8
	PHA
	LDA.b #$01
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	TYA
	ASL
	ASL
	TAX
	LDA.b #$80
	STA.w SMW_OAMBuffer[$40].XDisp,x
	PLA
CODE_01A3F8:
	LSR
	BCC.b CODE_01A409
	LDA.b #$01
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
	TYA
	ASL
	ASL
	TAX
	LDA.b #$80
	STA.w SMW_OAMBuffer[$41].XDisp,x
CODE_01A409:
	PLX
Return01A40A:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_CheckPlayerPositionRelativeToSprite(Address)
namespace SMW_CheckPlayerPositionRelativeToSprite
%InsertMacroAtXPosition(<Address>)

Bank01:
.X:
%CheckPlayerPositionRelativeToSpriteSub(RAM_SMW_Player_CurrentXPos, RAM_SMW_NorSpr_XPos, !RAM_SMW_Misc_ScratchRAM0F, X_LOW_REMAP2)

.Y:
;$01AD42
%CheckPlayerPositionRelativeToSpriteSub(RAM_SMW_Player_CurrentYPos, RAM_SMW_NorSpr_YPos, !RAM_SMW_Misc_ScratchRAM0E, Y_LOW_REMAP8)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprStatus0C_GoalPowerUp(Address)
namespace SMW_NorSprStatus0C_GoalPowerUp
%InsertMacroAtXPosition(<Address>)

; Routine that handles sprites in the "powerup from being carried past the
; goal tape" state ($14C8,x = #$0C). It calls the sprite's main code, then
; despawns it if it went offscreen and applies movement (decelerating the Y
; speed).
Main:
	JSR.w SMW_NorSprStatus08_Normal_Main
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b Return
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
Return:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSprStatus06_GoalCoins(Address)
namespace SMW_NorSprStatus06_GoalCoins
%InsertMacroAtXPosition(<Address>)

; Routine that handles sprites in the "turned into coin by the goal tape"
; state ($14C8 = #$06). It just JSLs to $00FBAC.
Main:
	JSL.l Sub
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_CheckIfNormalSpriteOffScreen(Address)
namespace SMW_CheckIfNormalSpriteOffScreen
%InsertMacroAtXPosition(<Address>)

Bank01:
	%INLINEROUTINE_SMW_CheckIfNormalSpriteOffScreen()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckNormalSpriteLevelCollision(Address)
namespace SMW_CheckNormalSpriteLevelCollision
%InsertMacroAtXPosition(<Address>)

; Subroutine that checks if a sprite is touching a wall. If the accumulator
; is set, it's touching a wall.
Wall:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Set A to lower two bits of
	AND.b #$03			; / current sprite's Position Status
	RTS

Floor:
;$01800E
	; Subroutine that is accessed by sprites to check if a sprite is touching
	; the ground. If the accumulator is set, it's touching the ground.
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Set A to bit 2 of
	AND.b #$04			; / current sprite's Position Status
	RTS

Ceiling:
;$018014
	; Routine that checks if a sprite is touching a ceiling. If the accumulator
	; is set, it's touching a ceiling.
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Set A to bit 3 of
	AND.b #$08			; / current sprite's Position Status
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_SubOffscreen(Address)
namespace SMW_SubOffscreen
%InsertMacroAtXPosition(<Address>)

Bank01:
.SpriteOffScreen1:
	db $40,$B0

.SpriteOffScreen2:
	db $01,$FF

.SpriteOffScreen3:
	db $30,$C0,$A0,$C0,$A0,$F0,$60,$90

.SpriteOffScreen4:
	db $01,$FF,$01,$FF,$01,$FF,$01,$FF

.Entry4:
	LDA.b #$06			; \ Entry point of routine determines value of $03
	STA.b !RAM_SMW_Misc_ScratchRAM03
	BRA.b .CODE_01AC2D

.Entry3:
	LDA.b #$04
	BRA.b .CODE_01AC2D

.Entry2:
	LDA.b #$02
.CODE_01AC2D:
	STA.b !RAM_SMW_Misc_ScratchRAM03
	BRA.b .CODE_01AC33

.Entry1:
	STZ.b !RAM_SMW_Misc_ScratchRAM03
.CODE_01AC33:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01	; \ if sprite is not off screen, return
	BEQ.b .Return01ACA4
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
	BNE.b .Return01ACA4
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM01
	TAY
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w .SpriteOffScreen3,y
	ROL.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b !RAM_SMW_NorSpr_XPosLo_x
	PHP
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w .SpriteOffScreen4,y
	PLP
	SBC.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LSR.b !RAM_SMW_Misc_ScratchRAM01
	BCC.b .CODE_01AC7C
	EOR.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
.CODE_01AC7C:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b .Return01ACA4
.EraseSprite:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ If MagiKoopa...
	CMP.b #!Define_SMW_SpriteID_NorSpr01F_MagiKoopa
	BNE.b .CODE_01AC8E		; | Sprite to respawn = MagiKoopa
	STA.w !RAM_SMW_Sprites_SpriteToRespawn
	LDA.b #$FF			; | Set timer until respawn
	STA.w !RAM_SMW_Timer_RespawnSprite
.CODE_01AC8E:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ If sprite status < 8, permanently erase sprite
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b .OffScrKillSprite
	LDY.w !RAM_SMW_NorSpr_LoadStatusTableIndex,x	; \ Branch if should permanently erase sprite
	CPY.b #$FF
	BEQ.b .OffScrKillSprite
if defined("Define_SMW_SA1")
	JSL.l SpriteLoading_CODE_01AC9C
	NOP
else
	LDA.b #$00			; \ Allow sprite to be reloaded by level loading routine
	STA.w !RAM_SMW_Sprites_LoadStatus,y
endif
.OffScrKillSprite:
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x	; Erase sprite
.Return01ACA4:
	RTS

.VerticalLevel:
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ If "process offscreen" flag is set, return
	AND.b #!Define_SMW_NorSpr_167AProp_TrackWhenOffScreen
	BNE.b .Return01ACA4
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Return every other frame
	LSR
	BCS.b .Return01ACA4
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.b #$00			; | If the sprite has gone off the side of the level...
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b #$00
	CMP.b #$02
	BCS.b .EraseSprite		; /  ...erase the sprite
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM01
	TAY
	BEQ.b .CODE_01ACD2
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Return if Green Net Koopa
	CMP.b #!Define_SMW_SpriteID_NorSpr022_GreenVerticalNetKoopa
	BEQ.b .Return01ACA4
	CMP.b #!Define_SMW_SpriteID_NorSpr024_GreenHorizontalNetKoopa
	BEQ.b .Return01ACA4
.CODE_01ACD2:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.w .SpriteOffScreen1,y
	ROL.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b !RAM_SMW_NorSpr_YPosLo_x
	PHP
	LDA.w !RAM_SMW_Mirror_CurrentLayer1YPosHi
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w .SpriteOffScreen2,y
	PLP
	SBC.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	BEQ.b .CODE_01ACF3
	EOR.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
.CODE_01ACF3:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b .Return01ACA4
	BMI.b .EraseSprite
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckForAvailableExtendedSpriteSlot(Address)
namespace SMW_CheckForAvailableExtendedSpriteSlot
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_018EF1:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_018F07
	DEY
	BPL.b CODE_018EF1
	DEC.w !RAM_SMW_ExtSpr_SlotToOverwriteWhenSlotsFull
	BPL.b ADDR_018F03
	LDA.b #!Define_SMW_MaxExtendedSpriteSlot-$02
	STA.w !RAM_SMW_ExtSpr_SlotToOverwriteWhenSlotsFull
ADDR_018F03:
	LDY.w !RAM_SMW_ExtSpr_SlotToOverwriteWhenSlotsFull
Return018F06:
	RTS

CODE_018F07:
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x			;\ Optimization: Return or return??
	BNE.b Return018F06 					;|
	RTS							;/
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetXSpeedBasedOnNormalSpriteFacingDirection(Address)
namespace SMW_SetXSpeedBasedOnNormalSpriteFacingDirection
%InsertMacroAtXPosition(<Address>)

; Subroutine to set the X speed for the Winged Goomba, Hopping Flame, Moving
; Coin, Mushroom, 1UP, and Star sprites. $018DBC is specifically the
; leftwards speed (F8) while $018DC3 is the rightwards one (08).
Main:
	LDA.b #$F8
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	BNE.b CODE_018DC4
	LDA.b #$08
CODE_018DC4:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetNormalSpriteAnimationFrame(Address)
namespace SMW_SetNormalSpriteAnimationFrame
%InsertMacroAtXPosition(<Address>)

Main:
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x	; \ Change animation image every 8 cycles
	LSR
	LSR
	LSR
	AND.b #$01
	STA.w !RAM_SMW_NorSpr_Table7E1602,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_SetNormalSpriteYSpeedBasedOnSlope(Address)
namespace SMW_SetNormalSpriteYSpeedBasedOnSlope
%InsertMacroAtXPosition(<Address>)

Bank01:

	%INLINEROUTINE_SMW_SetNormalSpriteYSpeedBasedOnSlope()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PowerUpAndItemGFXRt(Address)
namespace SMW_PowerUpAndItemGFXRt
%InsertMacroAtXPosition(<Address>)

; Tilemap: Power-ups (Mushroom, Flower, Star, Feather, 1Up)
PowerUpTiles:
	db $24,$26,$48,$0E,$24,$00,$00,$00
	db $00,$E4,$E8,$24,$EC

; The palettes the star sprite flashes through. 00 is palette 8, 02 is
; palette 9, 04 palette A, etc. YXPPCCCT format.
StarPalValues:
	db $00,$04,$08,$04

Main:
	JSR.w SMW_GetDrawInfo_Bank01	; Draw sprite
	STZ.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_Flag_ReznorRoomOAMIndexTimer
	BNE.b CODE_01C636
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	CMP.b #$C1
	BEQ.b CODE_01C636
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_01C636
	LDA.b #$D8
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
CODE_01C636:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin	; sprite coin
	BNE.b PowerUpGFXRt
	JSL.l DrawCoinSprite_Main
	RTS

; The GFX routine of the moving coin (sprite 21) and various other coin
; sprites, such as the directional coins. - $01C641: 4 bytes, JSRs to the
; main routine and ends in RTL. - $01C645: Start of the main GFX routine. -
; $01C653: Tile used by the first frame. This is the 16x16 one. - $01C667:
; Changing this to [80 07] will cause all 4 frames to use 2 tiles, and
; changing it to [D0 00] or [EA EA] will cause all 4 frames to use only 1
; tile. - $01C66A: Changing this to 00 will cause all 4 frames to be 8x8. -
; $01C66D: Tiles used by the second, third, and fourth frames. These are all
; 8x8. - $01C699: Changing this to 02 will cause all 4 frames to be 16x16.
DrawCoinSprite:
.Main:
	JSR.w .Sub
	RTL

.Sub:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$E8
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	TXA
	CLC
	ADC.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$03
	BNE.b .CODE_01C670
	LDY.b #$02
	BRA.b .CODE_01C69A

.Tiles:
	db $EA,$FA,$EA

.CODE_01C670:
	PHX
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$04
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.l .Tiles-$01,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.w SMW_OAMBuffer[$40].Prop,y
	ORA.b #$80
	STA.w SMW_OAMBuffer[$41].Prop,y
	PLX
	LDY.b #$00
.CODE_01C69A:
	LDA.b #$01
	JSL.l SMW_FinishOAMWrite_Main
	RTS

; Graphics routine for the powerups (mushroom, fire flower, cape feather,
; and star). - $01C6A3: Changing this to [80] will disable the star
; flashing. - $01C6C2: Changing this to [30] will fix the powerups being
; covered by the background in levels with transparent layer 3. - $01C6C3:
; Changing this to [80] will make the graphics for powerups always face
; right (preventing things like the automatic flipping for fireflowers).
PowerUpGFXRt:
	CMP.b #!Define_SMW_SpriteID_NorSpr076_Star	; \ Setup flashing palette for star
	BNE.b NoFlashingPal
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	AND.b #$03
	PHY
	TAY
	LDA.w StarPalValues,y
	PLY
	STA.b !RAM_SMW_Misc_ScratchRAM0A	; / $0A contains palette info, will be applied later
NoFlashingPal:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; \ Set tile x position
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01	; \ Set tile y position
	DEC
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; \ Flip flower/cape if 157C,x is set
	LSR
	LDA.b #$00
	BCS.b CODE_01C6C7
	ORA.b #$40
CODE_01C6C7:
	ORA.b !RAM_SMW_Sprites_TilePriority	; \ Add in level priority information
	ORA.w !RAM_SMW_NorSpr_Table7E15F6,x	; | Add in palette/gfx page
	EOR.b !RAM_SMW_Misc_ScratchRAM0A	; | Adjust palette for star
	STA.w SMW_OAMBuffer[$40].Prop,y	; / Set property byte
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Set powerup tile
	SEC
	SBC.b #!Define_SMW_SpriteID_NorSpr074_Mushroom
	TAX				; | X = Sprite number - #$74
	LDA.w PowerUpTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = sprite index
	LDA.b #$00
	JSR.w SMW_NormalSpritePlatformGFXRt_CODE_01B37E
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_WasteTime(Address)
namespace SMW_WasteTime
%InsertMacroAtXPosition(<Address>)

Main:
	NOP #8				; \ Do nothing at all
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnContactEffectFromAbove(Address)
namespace SMW_SpawnContactEffectFromAbove
%InsertMacroAtXPosition(<Address>)

; Routine that displays the contact graphics at Mario's position, usually
; called by sprites when Mario jumps on them.
Main:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01
	BNE.b Return01ABCB
	PHY
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_01ABA1:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y
	BEQ.b CODE_01ABAA
	DEY
	BPL.b CODE_01ABA1
	INY
CODE_01ABAA:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr02_ContactEffect
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y
	LDA.b !RAM_SMW_Player_XPosLo
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	CMP.b #$01
	LDA.b #$14
	BCC.b CODE_01ABBF
	LDA.b #$1E
CODE_01ABBF:
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y
	LDA.b #$08
	STA.w !RAM_SMW_SmokeSpr_Timer,y
	PLY
Return01ABCB:
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SpawnContactEffectFromSide(Address)
namespace SMW_SpawnContactEffectFromSide
%InsertMacroAtXPosition(<Address>)

UNK_01AB6A:
	db $0C,$FC,$EC,$DC,$CC

; Routine that displays the white star effect at a sprite's position and
; plays the "kicked" sfx (used, for example, when kicking a Shell or killing
; an enemy with a Shell). JSL to $01AB72 to show the star but not play the
; sound effect.
Main:
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_PlayKickSfx
NoKickSound:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01
	BNE.b Return01AB98		; if sprite is offscreen, return
	PHY
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_01AB7A:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y
	BEQ.b CODE_01AB83
	DEY
	BPL.b CODE_01AB7A
	INY				; if no free slot found, overwrite slot 0 ($17C0)
CODE_01AB83:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr02_ContactEffect	;\ set smoke image
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y	;/
if defined("Define_SMW_SA1")
	; SA-1 Pack: When hitting a flying platform with a hammer bro on top, need
	; to hijack this so that the smash graphic appears in the right spot.
	JML.l FLYING_BLOCK_FIX
	db $77	; the tail of the STA.w below, which the hijack leaves unreached
else
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\ set smoke position
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y	; |
endif
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;|
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y	;/
	LDA.b #$08			;\ set time for smoke to be displayed
	STA.w !RAM_SMW_SmokeSpr_Timer,y	;/
	PLY
Return01AB98:
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_PlayerGFXRt(Address)
namespace SMW_PlayerGFXRt
%InsertMacroAtXPosition(<Address>)

CODE_01EA70:
	LDX.w !RAM_SMW_Yoshi_StrayYoshiFlag
	BEQ.b Return01EA8E
	STZ.w !RAM_SMW_Player_RelativeYPositionDuringScreenShake
	STZ.w !RAM_SMW_Yoshi_KeyInMouthFlag
	LDA.w !RAM_SMW_NorSpr_CurrentSlotID
	PHA
if defined("Define_SMW_SA1")
	; SA-1 Pack: Yoshi has some code that needs fixing.
	JSL.l YOSHI_SET
else
	DEX
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
endif
	PHB
	PHK
	PLB
	JSR.w CODE_01EA8F
	PLB
if defined("Define_SMW_SA1")
	JML.l YOSHI_RESTORE
else
	PLA
	STA.w !RAM_SMW_NorSpr_CurrentSlotID
endif
Return01EA8E:
	RTL

CODE_01EA8F:
	LDA.w !RAM_SMW_GrowingYoshiTimer
	ORA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	BEQ.b CODE_01EA9A
	JMP.w CODE_01EB48

CODE_01EA9A:
	STZ.w !RAM_SMW_Yoshi_DuckingFlag
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	CMP.b #$02
	BCC.b CODE_01EAA7
	LDA.b #$30
	BRA.b CODE_01EAB2

CODE_01EAA7:
	LDY.b #$00
	LDA.b !RAM_SMW_Player_XSpeed	; \ Branch if Mario X speed == 0
	BEQ.b CODE_01EADF
	BPL.b CODE_01EAB2		; \ If Mario X speed is positive,
	EOR.b #$FF			; | invert it
	INC
CODE_01EAB2:
	LSR				; \ Y = Upper 4 bits of X speed
	LSR
	LSR
	LSR
	TAY
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01EAD0
	DEC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x	; \ If time to change frame...
	BPL.b CODE_01EAD0
	LDA.w SMW_NorSpr035_Yoshi_Status08_DATA_01EDF5,y	; | Set time to display new frame (based on Mario's X speed)
	STA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	DEC.w !RAM_SMW_Yoshi_WalkingFrames	; | Set index to new frame, $18AD = ($18AD-1) % 3
	BPL.b CODE_01EAD0
	LDA.b #$02
	STA.w !RAM_SMW_Yoshi_WalkingFrames
CODE_01EAD0:
	LDY.w !RAM_SMW_Yoshi_WalkingFrames	; \ Y = frame to show
	LDA.w SMW_NorSpr035_Yoshi_Status08_YoshiWalkFrames,y
	TAY
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	CMP.b #$02
	BCS.b CODE_01EB2E
	BRA.b CODE_01EAE2

CODE_01EADF:
	STZ.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
CODE_01EAE2:
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_01EAF0
	LDY.b #$02
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_01EAF0
	LDY.b #$05
	BRA.b CODE_01EAF0

CODE_01EAF0:
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BEQ.b CODE_01EAF7
	LDY.b #$03
CODE_01EAF7:
	LDA.b !RAM_SMW_Player_InAirFlag
	BNE.b CODE_01EB21
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	BEQ.b CODE_01EB0C
	LDY.b #$07
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #!Joypad_DPadU>>8
	BEQ.b CODE_01EB0A
	LDY.b #$06
CODE_01EB0A:
	BRA.b CODE_01EB21

CODE_01EB0C:
	LDA.w !RAM_SMW_Timer_YoshiSquatting
	BEQ.b CODE_01EB16
	DEC.w !RAM_SMW_Timer_YoshiSquatting
	BRA.b CODE_01EB1C

; Change this to [EA EA A5 73] to fix an issue with Yoshi if you disable
; ducking.
CODE_01EB16:
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #!Joypad_DPadD>>8
	BEQ.b CODE_01EB21
CODE_01EB1C:
	LDY.b #$04
	INC.w !RAM_SMW_Yoshi_DuckingFlag
CODE_01EB21:
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	CMP.b #$01
	BEQ.b CODE_01EB2E
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	BNE.b CODE_01EB2E
	LDY.b #$04
CODE_01EB2E:
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01EB44
	LDA.w !RAM_SMW_Yoshi_InPipe
	CMP.b #$01
	BNE.b CODE_01EB44
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$08
	LSR
	LSR
	LSR
	ADC.b #$08
	TAY
CODE_01EB44:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
CODE_01EB48:
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	CMP.b #$01
	BNE.b CODE_01EB97
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w SMW_NorSpr035_Yoshi_Status08_YoshiPositionX,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Player_XPosHi
	ADC.w SMW_NorSpr035_Yoshi_Status08_DATA_01EDF3,y
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDY.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w SMW_NorSpr035_Yoshi_Status08_DATA_01EDE4,y
	STA.w !RAM_SMW_Player_RelativeYPositionDuringScreenShake
	LDA.b #$01
	LDY.w !RAM_SMW_NorSpr_AnimationFrame,x
	CPY.b #$03
	BNE.b BackOnYoshi
	INC
BackOnYoshi:
	STA.w !RAM_SMW_Player_RidingYoshiFlag
	LDA.b #$01
	STA.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	LDA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,x	; \ $13C7 = Yoshi palette
	STA.w !RAM_SMW_Yoshi_CurrentYoshiColor
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	STA.b !RAM_SMW_Player_FacingDirection
CODE_01EB97:
	LDA.b !RAM_SMW_Sprites_TilePriority
	PHA
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01EBAD
	LDA.w !RAM_SMW_Yoshi_InPipe
	BEQ.b CODE_01EBAD
	LDA.w !RAM_SMW_Flag_AboutToWarpInPipe
	BNE.b CODE_01EBB0
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_01EBAD:
	JSR.w SMW_NorSpr035_Yoshi_Status08_HandleOffYoshi
CODE_01EBB0:
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_SpawnSparkles(Address)
namespace SMW_SpawnSparkles
%InsertMacroAtXPosition(<Address>)

; Sprite based sparkle routine. Used by Magikoopa's magic and the goal
; sphere. The goal sphere calls $01:B152.
NormalSpriteEntry:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
GoalSphereEntry:
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return01B191
	JSL.l SMW_GetRand_Main
	AND.b #$0F
	CLC
	LDY.b #$00
	ADC.b #$FC
	BPL.b CODE_01B167
	DEY
CODE_01B167:
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TYA
	ADC.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	PLA
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b Return01B191
	LDA.w !RAM_SMW_Misc_RandomByte2
	AND.b #$0F
	CLC
	ADC.b #$FE
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	JSL.l SMW_SpawnSparkles_Main
Return01B191:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_KickHelplessSprite(Address)
namespace SMW_KickHelplessSprite
%InsertMacroAtXPosition(<Address>)

; This subroutine is what is used to kill stunned koopas and out of water
; fish. The following offsets may be of use: $01B12B - How long to show the
; player kicked a sprite pose. $01B130 - The sound effect to play (default
; #$03) $01B132 - The sound effect channel (default $1DF9) $01B13D - Y speed
; of the dying sprite (default #$E0) $01B145 - Forces the player to face the
; killed sprite, change to NOP #2 (EA EA) to disable
Main:
	LDA.b #$10
	STA.w !RAM_SMW_Timer_DisplayPlayerKickingPose
	LDA.b #!Define_SMW_Sound1DF9_KickShell
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w SMW_NorSprXXX_FixedMovementCheepCheep_Status08_KickedXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$E0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	STY.b !RAM_SMW_Player_FacingDirection
	LDA.b #$01
	JSL.l SMW_GivePoints_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprStatus0A_Kicked(Address)
namespace SMW_NorSprStatus0A_Kicked
%InsertMacroAtXPosition(<Address>)

; [$E0 $20] X speed (left, right) to give Disco Shells when bumping into a
; wall.
XSpeed:
	db $E0,$20

CODE_0198A9:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_0198B0
	JMP.w SMW_KickedShellGFXRt_Main

CODE_0198B0:
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	LDA.w !RAM_SMW_NorSpr_Table7E151C,x
	AND.b #$1F
	BNE.b CODE_0198BD
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
CODE_0198BD:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	CPY.b #$00
	BNE.b CODE_0198D0
	CMP.b #$20
	BPL.b CODE_0198D8
	INC.b !RAM_SMW_NorSpr_XSpeed,x
	INC.b !RAM_SMW_NorSpr_XSpeed,x
	BRA.b CODE_0198D8

CODE_0198D0:
	CMP.b #$E0
	BMI.b CODE_0198D8
	DEC.b !RAM_SMW_NorSpr_XSpeed,x
	DEC.b !RAM_SMW_NorSpr_XSpeed,x
CODE_0198D8:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b CODE_0198EA
	PHA
	JSR.w SMW_MakeNormalSpriteReboundOffWall_Main
	PLA
	AND.b #$03
	TAY
	LDA.w XSpeed-$01,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_0198EA:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_0198F6
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_0198F6:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling
	BEQ.b CODE_0198FD
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_0198FD:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_01990D
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	INC
	INC
	AND.b #$CF
	STA.w !RAM_SMW_NorSpr_Table7E15F6,x
CODE_01990D:
	JMP.w CODE_01998C

UNK_019910:
	db $F0,$EE,$EC

; Start of sprite being kicked routine.
Main:
	LDA.w !RAM_SMW_NorSpr_Table7E187B,x
	BEQ.b CODE_01991B
	JMP.w CODE_0198A9

CODE_01991B:
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x
	AND.b #!Define_SMW_NorSpr_167AProp_CantBeKickedLikeShell
	BEQ.b CODE_019928
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_CODE_01AA0B
	JMP.w SMW_ProcessStunnedNormalSprite_Main

CODE_019928:
	LDA.w !RAM_SMW_NorSpr_Table7E1528,x
	BNE.b CODE_019939
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CLC
	ADC.b #$20
	CMP.b #$40
	BCS.b CODE_019939
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_CODE_01AA0B
CODE_019939:
	STZ.w !RAM_SMW_NorSpr_Table7E1528,x
	LDA.b !RAM_SMW_Flag_SpritesLocked
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	BEQ.b CODE_019946
	JMP.w CODE_01998F

CODE_019946:
	JSR.w SMW_SetFacingDirectionBasedOnSpeed_Bank01
	LDA.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	PHA
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	PLA
	BEQ.b CODE_019969
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BNE.b CODE_019969
	CMP.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	BEQ.b CODE_019969
	EOR.b !RAM_SMW_NorSpr_XSpeed,x
	BMI.b CODE_019969
	LDA.b #$F8			; \ Set upward speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	BRA.b CODE_019975

CODE_019969:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_019984
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	LDA.b #$10			; \ Set downward speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_019975:
	LDA.w !RAM_SMW_Sprites_Map16TileBeingTouchedHorizontallyLo
	CMP.b #$B5
	BEQ.b CODE_019980
	CMP.b #$B4
	BNE.b CODE_019984
CODE_019980:
	LDA.b #$B8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_019984:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall	;>Check if touching side of block
	BEQ.b CODE_01998C		;>if not, skip over.
	JSR.w SMW_MakeNormalSpriteReboundOffWall_Main	;>Code that makes sprites react when colliding solid walls
CODE_01998C:
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
CODE_01998F:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if throw block sprite
	CMP.b #!Define_SMW_SpriteID_NorSpr053_ThrowBlock
	BEQ.b CODE_01999B
	JMP.w SMW_KickedShellGFXRt_Main

CODE_01999B:
	JMP.w SMW_ProcessStunnedNormalSprite_StunnedThrowBlock
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_KickedShellGFXRt(Address)
namespace SMW_KickedShellGFXRt
%InsertMacroAtXPosition(<Address>)

; Animation frame assignments for the shell
ShellAniTiles:
	db $06,$07,$08,$07

; Flip of each animation frame
Prop:
	db $00,$00,$00,$40

Main:
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$03
	TAY
	PHY
	LDA.w ShellAniTiles,y
	JSR.w SMW_StunnedShellGFXRt_CODE_01980F
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	PLY
	LDA.w Prop,y
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	EOR.w SMW_OAMBuffer[$42].Prop,y
	STA.w SMW_OAMBuffer[$42].Prop,y
	RTS

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprStatus0B_Carried(Address)
namespace SMW_NorSprStatus0B_Carried
%InsertMacroAtXPosition(<Address>)

; x-pos table of sprite being carried: walking, turn from left to right,
; turn from right to left (two bytes each, indexed by Mario's direction)
CarriedSpriteXOffsetLo:
	db $0B,$F5			; Normal
	db $04,$FC,$04			; Facing Screen (during standing turn)
	db $00				; Climbing/Turning Around/Enter Vertical Pipe

CarriedSpriteXOffsetHi:
	db $00,$FF			; Normal
	db $00,$FF,$00			; Facing Screen (during standing turn)
	db $00				; Climbing/Turning Around/Enter Vertical Pipe

PlacedSpriteInitialXPosLo:
	db $F3,$0D			; .db -13, 13

PlacedSpriteInitialXPosHi:
	db $FF,$00			; high byte of -13, 13

ShellXSpeed:
if ver_is_pal(!Define_Global_ROMToAssemble)
	db $C9,$37			; Normal
	db $C2,$3E			; Riding Yoshi (Unused?)
else
	; X-speed of the touched/kicked shell. Value 1: left-speed, when touched
	; (not kicking) Value 2: right-speed, when touched Value 3: left-speed,
	; when kicked Value 4: right-speed, when kicked. This will also affect the
	; shell of buzzy beetle! Setting the speed to 00 or FF will make the shells
	; not spinning, giving unlimited score. Original Values: D2 2E CC 34
	db $D2,$2E			; Normal
	db $CC,$34			; Riding Yoshi (Unused?)
endif

UNK_019F6F:
	db $00,$10			; unknown bytes

Main:
	JSR.w CODE_019F9B
	LDA.w !RAM_SMW_Player_TurningAroundFlag
	BNE.b CODE_019F83
	LDA.w !RAM_SMW_Yoshi_InPipe	; \ Branch if Yoshi going down pipe
	BNE.b CODE_019F83
	LDA.w !RAM_SMW_Timer_DisplayPlayerFaceScreenPose	; \ Branch if Mario facing camera
	BEQ.b CODE_019F86
CODE_019F83:
	STZ.w !RAM_SMW_NorSpr_OAMIndex,x
CODE_019F86:
	LDA.b !RAM_SMW_Sprites_TilePriority	; \ Save vhoopppN of current sprite
	PHA				; /
	LDA.w !RAM_SMW_Yoshi_InPipe	; \ Do nothing if we are in a pipe.
	BEQ.b CODE_019F92		;  |Otherwise, vhoopppN = 00010000
	LDA.b #$10			;  |  no flipping, priority oo = 1,
	STA.b !RAM_SMW_Sprites_TilePriority	; /   palette ppp = 0, N = 0
CODE_019F92:
	JSR.w SMW_ProcessStunnedNormalSprite_Main
	PLA				; \ Restore vhoopppN
	STA.b !RAM_SMW_Sprites_TilePriority	; /
	RTS

PlacedSpriteInitiaXSpeed:
	db $FC,$04			; .db -4, 4

; First half of the routine that handles sprites being carried, though it's
; actually only the part that handles the P-balloon. Any other sprite will
; branch to $019FE0 $019FA7 change to EA EA EA EA EA to the P-Balloon last
; forever. $019FB0 is the time at which the deflatting animation starts.
; (default 30) $019FC2 change 90 to 80 to make Mario keep the balloon effect
; even after taking hits or power-ups. (causes weird behaviour when dying)
CODE_019F9B:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if not Balloon
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon
	BNE.b NotCarryingBalloon
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ The next code runs every four frames.
	AND.b #$03			;  |If the frame counter is not a multiple of 4,
	BNE.b CODE_019FBE		; / then skip ahead.
	; Change to [EA EA EA EA EA] to give the P-Balloon an infinite timer
	DEC.w !RAM_SMW_Timer_PlayerHasPBalloon	; Decrement the timer of the P-balloon
	BEQ.b BalloonExpired		; Branch if the P-balloon expired
	LDA.w !RAM_SMW_Timer_PlayerHasPBalloon	; A = P-balloon's timer
	CMP.b #$30			; \ Skip ahead if timer >= 48
	BCS.b CODE_019FBE		; /
	LDY.b #$01			; \ Divide timer by 8, take remainder.
	AND.b #$04			;  |If 0 <= remainder <= 3, then Y = 1.
	BEQ.b CODE_019FBB		;  |If 4 <= remainder <= 7, then Y = 9.
	LDY.b #$09			; /
CODE_019FBB:
	STY.w !RAM_SMW_Timer_InflateFromPBalloon	; Write $13F3 = Y
CODE_019FBE:
	LDA.b !RAM_SMW_Player_CurrentState	; \ Branch if no Mario animation sequence in progress
	CMP.b #!Define_SMW_PlayerState01_PowerDown
	BCC.b BalloonActive
BalloonExpired:
	STZ.w !RAM_SMW_Timer_InflateFromPBalloon	; Write $13F3 = 0
	JMP.w SMW_SubOffscreen_Bank01_EraseSprite

BalloonActive:
	PHB				; Save previous data bank
	LDA.b #SMW_HandleHeldPBalloonAndInLakituCloudMovement_Main>>16
	PHA
	PLB
	JSL.l SMW_HandleHeldPBalloonAndInLakituCloudMovement_Main	; React to Control Pad, adjust speed
	PLB				; Restore previous data bank
	JSR.w CODE_01A0B1
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$F0
	STA.w SMW_OAMBuffer[$40].YDisp,y
	RTS

NotCarryingBalloon:
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.b !RAM_SMW_Player_CurrentState	; \ Branch if no Mario animation sequence in progress
	CMP.b #!Define_SMW_PlayerState01_PowerDown
	BCC.b CODE_019FF4
	LDA.w !RAM_SMW_Yoshi_InPipe	; \ Branch if in pipe
	BNE.b CODE_019FF4
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Stunned
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

CODE_019FF4:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Return if sprite status == Normal
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b Return01A014
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Jump if sprites locked
	BEQ.b CODE_01A002
	JMP.w CODE_01A0B1

CODE_01A002:
	JSR.w SMW_NorSprStatus09_Stunned_CODE_019624
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_Sub
	LDA.w !RAM_SMW_Yoshi_InPipe	; \ Do nothing if we are in a pipe.
	BNE.b CODE_01A011		;  |Otherwise, if not holding Y or X,
	BIT.b !RAM_SMW_IO_ControllerHold1	;  |  then branch to release the sprite.
	BVC.b ReleaseSprCarried		; / (BIT moves bit $40 to flag V.)
CODE_01A011:
	JSR.w CODE_01A0B1
Return01A014:
	RTS

ReleaseSprCarried:
	STZ.w !RAM_SMW_NorSpr_Table7E1626,x	; TODO - what is this?
	LDY.b #$00			; Y = 0
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if not Goomba
	CMP.b #!Define_SMW_SpriteID_NorSpr00F_Goomba
	BNE.b CODE_01A026
	LDA.b !RAM_SMW_Player_InAirFlag
	BNE.b CODE_01A026
	LDY.b #$EC
CODE_01A026:
	STY.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y speed = register Y
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b !RAM_SMW_IO_ControllerHold1	; \ If holding up from Control Pad,
	AND.b #!Joypad_DPadU>>8		;  |branch to toss up sprite
	BNE.b TossUpSprCarried		; /
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if sprite >= #$15
	CMP.b #!Define_SMW_SpriteID_NorSpr015_HorizontalCheepCheep
	BCS.b CODE_01A041
	LDA.b !RAM_SMW_IO_ControllerHold1	; \ For sprite number < $15,
	AND.b #!Joypad_DPadD>>8		;  |Kick sprite unless holding down
	BEQ.b KickSprCarried		;  |  from Control Pad
	BRA.b PlaceDownSprite		; /

CODE_01A041:
	LDA.b !RAM_SMW_IO_ControllerHold1	; \ For sprite number >= $15,
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)	;  |Kick sprite if holding left or right
	BNE.b KickSprCarried		; /   from Control Pad
PlaceDownSprite:
	LDY.b !RAM_SMW_Player_FacingDirection	; Y = 0 if Mario faces left, 1 if right
	LDA.b !RAM_SMW_Player_CurrentXPosLo	; \ Sprite X position =
	CLC				;  |  Mario X position plus or minus 13
	ADC.w PlacedSpriteInitialXPosLo,y	;  |
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;  |Subtract 13 if Mario faces left.
	LDA.b !RAM_SMW_Player_CurrentXPosHi	;  |Add 13 if Mario faces right.
	ADC.w PlacedSpriteInitialXPosHi,y	;  |
	STA.w !RAM_SMW_NorSpr_XPosHi,x	; /
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w PlacedSpriteInitiaXSpeed,y	; \ Sprite X speed =
	CLC				;  |  Mario X speed plus or minus 4
	ADC.b !RAM_SMW_Player_XSpeed	;  |Subtract 4 if Mario faces left.
	STA.b !RAM_SMW_NorSpr_XSpeed,x	; / Add 4 if Mario faces right.
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	BRA.b StartKickPose		; Branch to pose Mario

TossUpSprCarried:
	JSL.l SMW_SpawnContactEffectFromSide_Main
	LDA.b #$90			; \ Sprite Y speed = -112
	STA.b !RAM_SMW_NorSpr_YSpeed,x	; /
	LDA.b !RAM_SMW_Player_XSpeed	; \ Sprite X speed = 1/2 * Mario X speed
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;  |(The ASL moves the sign bit to the
	ASL				;  | carry flag, such that the ROR
	ROR.b !RAM_SMW_NorSpr_XSpeed,x	; /  performs signed division by 2.)
	BRA.b StartKickPose		; Branch to pose Mario

KickSprCarried:
	JSL.l SMW_SpawnContactEffectFromSide_Main
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x	; \ TODO - what is this?
	STA.b !RAM_SMW_NorSpr_Table7E00C2,x	; /
	LDA.b #!Define_SMW_NorSprStatus0A_Kicked	; \ Sprite status = Kicked
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDY.b !RAM_SMW_Player_FacingDirection	; \ Y = 0 if Mario faces left, no Yoshi
	LDA.w !RAM_SMW_Player_RidingYoshiFlag	;  |Y = 1 if Mario faces right, no Yoshi
	BEQ.b CODE_01A090		;  |Y = 2 if Mario and Yoshi face left
	INY				;  |Y = 3 if Mario and Yoshi face right
	INY				; /
CODE_01A090:
	LDA.w ShellXSpeed,y		; \ Sprite X speed = Value from table
	STA.b !RAM_SMW_NorSpr_XSpeed,x	; /   -46, 46, -52, 52 indexed by Y
	EOR.b !RAM_SMW_Player_XSpeed	; \ Skip ahead unless sign bits of Mario
	BMI.b StartKickPose		; /   and sprite X speeds are equal
	LDA.b !RAM_SMW_Player_XSpeed	; \ Carry flag = sign bit of Mario X
	STA.b !RAM_SMW_Misc_ScratchRAM00	;  |  speed
	ASL.b !RAM_SMW_Misc_ScratchRAM00	; /
	ROR				; \ Sprite X speed = Sprite X speed +
	CLC				;  |  1/2 * Mario X speed
	ADC.w ShellXSpeed,y		;  |
	STA.b !RAM_SMW_NorSpr_XSpeed,x	; /
StartKickPose:
	LDA.b #$10			; \ Disable collisions between Mario
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x	; / and this sprite for 16 frames.
	LDA.b #$0C			; \ Display pose of Mario kicking for
	STA.w !RAM_SMW_Timer_DisplayPlayerKickingPose	; / 12 frames.
	RTS

CODE_01A0B1:
	LDY.b #$00
	LDA.b !RAM_SMW_Player_FacingDirection	; \ Y = Mario's direction
	BNE.b CODE_01A0B8
	INY
CODE_01A0B8:
	LDA.w !RAM_SMW_Timer_DisplayPlayerFaceScreenPose
	BEQ.b CODE_01A0C4
	INY
	INY
	CMP.b #$05
	BCC.b CODE_01A0C4
	INY
CODE_01A0C4:
	LDA.w !RAM_SMW_Yoshi_InPipe
	BEQ.b CODE_01A0CD
	CMP.b #$02
	BEQ.b CODE_01A0D4
CODE_01A0CD:
	LDA.w !RAM_SMW_Player_TurningAroundFlag
	ORA.b !RAM_SMW_Player_ClimbingFlag
	BEQ.b CODE_01A0D6
CODE_01A0D4:
	LDY.b #$05
CODE_01A0D6:
	PHY
	LDY.b #$00
	LDA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	CMP.b #$03
	BEQ.b CODE_01A0E2
	LDY.b #!RAM_SMW_Player_CurrentXPosLo-!RAM_SMW_Player_XPosLo
CODE_01A0E2:
	LDA.w !RAM_SMW_Player_XPosLo,y	; \ $00 = Mario's X position
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Player_XPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_Player_YPosLo,y	; \ $02 = Mario's Y position
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Player_YPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PLY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w CarriedSpriteXOffsetLo,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	ADC.w CarriedSpriteXOffsetHi,y
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b #$0D
	LDY.b !RAM_SMW_Player_DuckingFlag	; \ Branch if ducking
	BNE.b CODE_01A111
	LDY.b !RAM_SMW_Player_CurrentPowerUp	; \ Branch if Mario isn't small
	BNE.b CODE_01A113
CODE_01A111:
	LDA.b #$0F
CODE_01A113:
	LDY.w !RAM_SMW_Timer_DisplayPlayerPickUpPose
	BEQ.b CODE_01A11A
	LDA.b #$0F
CODE_01A11A:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b #$01
	STA.w !RAM_SMW_Player_CarryingSomethingFlag2
	STA.w !RAM_SMW_Player_CarryingSomethingFlag1	; Set carrying enemy flag
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSprStatus02_Dead(Address)
namespace SMW_NorSprStatus02_Dead
%InsertMacroAtXPosition(<Address>)

Status05Entry:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	BEQ.b SMW_NorSprStatus04_SpinJumpKill_EraseSprite
	LDA.b #$04
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	ASL.w !RAM_SMW_NorSpr_PropertyBits190F,x				;\ Note: !Define_SMW_NorSpr_190FProp_DontGetStuckInWallsWhenCarried
	LSR.w !RAM_SMW_NorSpr_PropertyBits190F,x				;/
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b CODE_019A9D
	BPL.b CODE_019A94
	INC.b !RAM_SMW_NorSpr_XSpeed,x
	BRA.b CODE_019A9D

CODE_019A94:
	DEC.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b CODE_019A9D
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
CODE_019A9D:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
; Routine for sprites in state 02 (killed and falling offscreen). It's also
; shared by the routine for sprites killed in lava.
Main:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ If Wiggler, call main sprite routine
	CMP.b #!Define_SMW_SpriteID_NorSpr086_Wiggler
	BNE.b CODE_019AAB
	JMP.w SMW_NorSprStatus08_Normal_Main

CODE_019AAB:
	CMP.b #!Define_SMW_SpriteID_NorSpr01E_Lakitu	; \ If Lakitu, $18E0 = #$FF
	BNE.b CODE_019AB4
	LDY.b #$FF
	STY.w !RAM_SMW_Timer_DespawnLakituCloud
CODE_019AB4:
	CMP.b #!Define_SMW_SpriteID_NorSpr053_ThrowBlock	; \ If Throw Block sprite...
	BNE.b CODE_019ABC
	JSR.w SMW_BreakThrowBlock_Main	; | ...break block...
	RTS				; / ...and return

CODE_019ABC:
	CMP.b #!Define_SMW_SpriteID_NorSpr04C_ExplodingBlock	; \ If Exploding Block Enemy
	BNE.b CODE_019AC4
	JSL.l SMW_ShatterExplodingBlock_Main
CODE_019AC4:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1656,x	; \ If "disappears in puff of smoke" is set...
	AND.b #!Define_SMW_NorSpr_1656Prop_DisappearAsSmokeCloud
	BEQ.b CODE_019AD6
SetNorSprStatus04:
.Main:
	LDA.b #!Define_SMW_NorSprStatus04_SpinJumpKill	; | ...Sprite status = Spin Jump Killed...
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$1F			; | ...Set Time to show smoke cloud...
	STA.w !RAM_SMW_NorSpr_SpinJumpKillTimer,x
	RTS				; / ... and return

CODE_019AD6:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_019ADD
	JSR.w SMW_HandleNormalSpriteGravity_Sub
CODE_019ADD:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w HandleGenericSpriteDeath
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSprStatus02_Dead(Address)
namespace SMW_NorSprStatus02_Dead
%InsertMacroAtXPosition(<Address>)

; Routine called during two sprite death states ($14C8,x = #$02 or #$05). If
; the "Don't disable clipping when killed by star" tweaker bit is set (bit 0
; in $167A,x) the sprite's main code is jumped to. Otherwise, it just draws
; the death frame. This is what makes some sprites appear glitched when
; killed in unintended ways (for example, killing a grinder by sliding).
HandleGenericSpriteDeath:
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ If the main routine handles the death state...
	AND.b #!Define_SMW_NorSpr_167AProp_DontDisableClippingWhenStarKilled
	BEQ.b CODE_019B1D
	JMP.w SMW_NorSprStatus08_Normal_Main	; / ...jump to the main routine

CODE_019B1D:
	STZ.w !RAM_SMW_NorSpr_Table7E1602,x
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,x	; \ Branch if "Death frame 2 tiles high"
	AND.b #!Define_SMW_NorSpr_190FProp_2TileTallDeathFrame	; | is NOT set
	BEQ.b CODE_019B64
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x	; \ Branch if "Use shell as death frame"
	AND.b #!Define_SMW_NorSpr_1662Prop_UseShellAsDeathFrame	; | is set
	BNE.b CODE_019B5F
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if Lakitu
	CMP.b #!Define_SMW_SpriteID_NorSpr01E_Lakitu
	BEQ.b CODE_019B3D
	CMP.b #!Define_SMW_SpriteID_NorSpr04B_PipeLakitu	; \ If Pipe Lakitu,
	BNE.b CODE_019B44
	LDA.b #$01			; | set behind scenery flag
	STA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
CODE_019B3D:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	BRA.b CODE_019B4C

CODE_019B44:
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x	; \ Set to flip tiles vertically
	ORA.b #$80
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
CODE_019B4C:
	LDA.b !RAM_SMW_Sprites_TilePriority	; \ If sprite is behind scenery,
	PHA
	LDY.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
	BEQ.b CODE_019B56
	LDA.b #$10			; | temorarily set layer priority for gfx routine
CODE_019B56:
	STA.b !RAM_SMW_Sprites_TilePriority
	JSR.w SMW_GenericGFXRtDraw2Tiles16x16sStacked_Sub	; | Draw sprite
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	RTS

CODE_019B5F:
	LDA.b #$06
	STA.w !RAM_SMW_NorSpr_Table7E1602,x
CODE_019B64:
	LDA.b #$00
	CPY.b #$1C
	BEQ.b CODE_019B6C
	LDA.b #$80
CODE_019B6C:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Sprites_TilePriority	; \ If sprite is behind scenery,
	PHA
	LDY.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
	BEQ.b CODE_019B78
	LDA.b #$10			; | temorarily set layer priority for gfx routine
CODE_019B78:
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry2	; | Draw sprite
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprStatus02_Dead_Status05Entry, SMW_NorSprStatus05_SinkInLava_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprStatus04_SpinJumpKill(Address)
namespace SMW_NorSprStatus04_SpinJumpKill
%InsertMacroAtXPosition(<Address>)

SmokeTiles:
	db $64,$62,$60,$62

; This is the routine that handles sprites in the "killed by a spin jump
; state" ($14C8,x = #$04). It handles drawing the smoke on screen, then it
; erases the sprite permanently when $1540,x is #$00. $019A57: change to $60
; to stop the smoke from appearing (doesn't stop the spin jump stars from
; appearing).
Main:
	LDA.w !RAM_SMW_NorSpr_SpinJumpKillTimer,x	; \ Erase sprite if time up
	BEQ.b EraseSprite
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1	; Call generic gfx routine
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr_SpinJumpKillTimer,x	; \ Load tile based on timer
	LSR
	LSR
	LSR
	AND.b #$03
	PHX
	TAX
	LDA.w SmokeTiles,x
	PLX
	STA.w SMW_OAMBuffer[$40].Tile,y	; Overwrite tile
	STA.w SMW_OAMBuffer[$40].Prop,y	; \ Overwrite properties
	AND.b #$30
	STA.w SMW_OAMBuffer[$40].Prop,y
	RTS

EraseSprite:
	JSR.w SMW_SubOffscreen_Bank01_EraseSprite	; Permanently kill the sprite
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprStatus03_Smushed(Address)
namespace SMW_NorSprStatus03_Smushed
%InsertMacroAtXPosition(<Address>)

; Routine that handles sprites in the "smushed state" ($14C8,x = #$03). It
; draws graphics (with special cases for Dino-Torch and Rex) and handles
; speed and movement. Once $1540,x reaches 0, the sprite is erased
; permanently.
Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_019AFE
	LDA.w !RAM_SMW_NorSpr_SmushedSpriteDespawnTimer,x	; \ Free sprite slot when timer runs out
	BNE.b ShowSmushedGfx
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

ShowSmushedGfx:
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_019AFE
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
CODE_019AFE:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ If Dino Torch...
	CMP.b #!Define_SMW_SpriteID_NorSpr06F_DinoTorch
	BNE.b CODE_019B10
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1	; | ...call standard gfx routine...
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x
	LDA.b #$AC			; | ...and replace the tile with #$AC
	STA.w SMW_OAMBuffer[$40].Tile,y
	RTS				; / Return

CODE_019B10:
	JMP.w SMW_GenericSmushedSpriteGFXRt_Main	; Call smushed gfx routine
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenericSmushedSpriteGFXRt(Address)
namespace SMW_GenericSmushedSpriteGFXRt
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_GetDrawInfo_Bank01
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01
	BNE.b Return01E75A
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; \ Set X displacement for both tiles
	STA.w SMW_OAMBuffer[$40].XDisp,y	; | (Sprite position + #$00/#$08)
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01	; \ Set Y displacement for both tiles
	CLC				; | (Sprite position + #$08)
	ADC.b #$08
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	PHX
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	TAX
	LDA.b #$FE			; \ If P Switch, tile = #$FE
	CPX.b #!Define_SMW_SpriteID_NorSpr03E_PSwitch
	BEQ.b CODE_01E73A
	LDA.b #$EE			; \ If Sliding Koopa...
	CPX.b #!Define_SMW_SpriteID_NorSpr0BD_SlidingNakedBlueKoopa
	BEQ.b CODE_01E73A
	CPX.b #!Define_SMW_SpriteID_NorSpr004_GreenKoopa	; | ...or a shelless, tile = #$EE
	BCC.b CODE_01E73A
	LDA.b #$C7			; \ If sprite num >= #$0F, tile = #$C7 (is this used?)
	CPX.b #!Define_SMW_SpriteID_NorSpr00F_Goomba
	BCS.b CODE_01E73A
	LDA.b #$4D			; If #$04 <= sprite num < #$0F, tile = #$4D (Koopas)
CODE_01E73A:
	STA.w SMW_OAMBuffer[$40].Tile,y	; \ Same value for both tiles
	STA.w SMW_OAMBuffer[$41].Tile,y
	PLX
	LDA.b !RAM_SMW_Sprites_TilePriority	; \ Store the first tile's properties
	ORA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	ORA.b #$40			; \ Horizontally flip the second tile and store it
	STA.w SMW_OAMBuffer[$41].Prop,y
	TYA				; \ Y = index to size table
	LSR
	LSR
	TAY
	LDA.b #$00			; \ Two 8x8 tiles
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
Return01E75A:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_HandleNormalSpriteGravity(Address)
namespace SMW_HandleNormalSpriteGravity
%InsertMacroAtXPosition(<Address>)

; Routine used to update a sprite's X/Y position, apply gravity, and process
; object interaction. This is a JSL-wrapper for $019032, which also calls
; the position-update routine at $01ABCC.
Main:
	PHB				;Update XY position, including gravity and block interaction
	PHK				; the position of a sprite.
	PLB
	JSR.w Sub
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_HandleNormalSpriteGravity(Address)
namespace SMW_HandleNormalSpriteGravity
%InsertMacroAtXPosition(<Address>)

; Maximum falling Y speed used for sprites that make use of $01802A. The
; first value [$40] is in air, while the second [$10] is in water.
MaxYSpeed:
	db $40			; Air
	db $10			; Water

; Accelerations applied every frame (effectively as gravity) for sprites
; that make use of $01802A. The first value [$03] is in air, while the
; second [$01] is in water.
YAcceleration:
	db $03			; Air
	db $01			; Water

; Standard rused to update a sprite's X/Y position (internally calling
; $01ABCC), apply gravity, and process object interaction. A JSL wrapper for
; it can be found at $01802A. $019042, $019045 [$E8]: Maximum upwards Y
; speed of sprites in water. The acceleration rates this routine uses for
; gravity can be found at $019030, and the maximum downwards Y speeds at
; $01902E.
Sub:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y	; Check for no gravity
	LDY.b #$00			; init Y
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x	;\ (multi-use sprite address) if 00, don't make Ysp =E8
	BEQ.b CODE_019049		;/
	INY				; Y =01
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;\
	BPL.b CODE_019049		;/ if moving down
	CMP.b #$E8			;\
	BCS.b CODE_019049		;/ if moving slowly up, don't make Ysp = E8
	LDA.b #$E8			;\
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/ make Ysp E8
CODE_019049:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;\
	CLC				;| add 03 if sprite address is 00(case1), 01 if it's not (case2)
	ADC.w YAcceleration,y		;|
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/ to Ysp
	BMI.b CODE_01905D		; if that makes the sprite go up,
	CMP.w MaxYSpeed,y		;\ if speed is slower than 40 for case1, or 10 for case2,
	BCC.b CODE_01905D		;/
	LDA.w MaxYSpeed,y		;\
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/ make that the speed
CODE_01905D:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;\
	PHA				;/ Preserve Xsp
	LDY.w !RAM_SMW_NorSpr_InLiquidFlag,x	; this address again
	BEQ.b CODE_019076		; if 00, return after doing a few things  (handling "sprite falls through things" mainly)
	ASL				; Otherwise, "x2" it
	ROR.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	PHA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	ROR.b !RAM_SMW_Misc_ScratchRAM00
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_019076:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X	; Act like there is no gravity
	PLA
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w !RAM_SMW_NorSpr_NoLevelCollisionFlag,x
	BNE.b ADDR_019085		;| if sprite is suppposed to fall through things...
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub	;>Interact with blocks (like move sprite out of the wall)
	RTS

ADDR_019085:
	STZ.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;/ then don't let it be stopped by anything
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_AimTowardsPlayer(Address)
namespace SMW_AimTowardsPlayer
%InsertMacroAtXPosition(<Address>)

Bank01:
	%INLINEROUTINE_SMW_AimTowardsPlayer(Bank01)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_HandleNormalSpriteLevelCollision(Address)
namespace SMW_HandleNormalSpriteLevelCollision
%InsertMacroAtXPosition(<Address>)

; Positions of each of the 4 object collision points for each sprite hitbox,
; relative to the sprite's XY position ($E4/$14E0 and $D8/$14D4). Consists
; of two 61-byte tables for each of the X and Y positions: $0190BA-$0190F6:
; X positions $0190F7-$019133: Y positions Each byte indexed by %00ccccpp:
; cccc: Which hitbox to use; retrieved from the low nybble of $1656. pp:
; Which of the 4 collision points to use: 00 = Right 01 = Left 10 = Bottom
; 11 = Top
SpriteObjClippingX:
	db $0E,$02,$08,$08,$0E,$02,$07,$07
	db $07,$07,$07,$07,$0E,$02,$08,$08
	db $10,$00,$08,$08,$0D,$02,$08,$08
	db $07,$00,$04,$04,$1F,$01,$10,$10
	db $0F,$00,$08,$08,$10,$00,$08,$08
	db $0D,$02,$08,$08,$0E,$02,$08,$08
	db $0D,$02,$08,$08,$10,$00,$08,$08
	db $1F,$00,$10,$10,$08

SpriteObjClippingY:
	db $08,$08,$10,$02,$12,$12,$20,$02
	db $07,$07,$07,$07,$10,$10,$20,$0B
	db $12,$12,$20,$02,$18,$18,$20,$10
	db $04,$04,$08,$00,$10,$10,$1F,$01
	db $08,$08,$0F,$00,$08,$08,$10,$00
	db $48,$48,$50,$42,$04,$04,$08,$00
	db $00,$00,$00,$00,$08,$08,$10,$00
	db $08,$08,$10,$00,$04

DATA_019134:
	db $01,$02,$04,$08		;>Set bit for object status (sprite blocked status), stored in $0F

Main:
;$019138
	; JSL to process interaction between sprites and objects. Actually just a
	; wrapper for the JSR routine at $019140. When processing custom blocks:
	; $0A-$0D: Position (in pixels) of the collision point currently being
	; processed for sprite interaction, relative to the current layer being
	; processed: $0A-$0B (2 bytes): X position $0C-$0D (2 bytes): Y position
	; $0F (1 byte): Index of one of the 4 collision points currently in use.
	; Also used to eject sprite out of block horizontally: 00 = SpriteH: Right
	; (touches blocks from left) 01 = SpriteH: Left (touches blocks from right)
	; 02 = SpriteV: Down (touches blocks from above) 03 = SpriteV: Up (touches
	; blocks from below) Be careful modifying this in custom blocks, as $0F is
	; used still used after the block is processed at $019533. If $0F is
	; modified and not restored, sprite interaction issues can occur.
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	STZ.w !RAM_SMW_Sprites_DistanceToSnapDownToNearestTile
	STZ.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; Set sprite's position status to 0 (in air)
	STZ.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	STZ.w !RAM_SMW_Misc_ScratchRAM7E185E
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	STA.w !RAM_SMW_Sprites_SpriteEnterOrExitingWater
	STZ.w !RAM_SMW_NorSpr_InLiquidFlag,x
#LMBlockOffset_Unknown2:
	JSR.w CODE_019211		;>Sprite buoyancy routine
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	; Vertical level flag
	BPL.b CODE_0191BE		;>If collisison with layer 2 = false, skip
	INC.w !RAM_SMW_Misc_ScratchRAM7E185E	;>Updaate tile generate routine
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Sprite's X position += $26
	CLC				; | for call to below routine
	ADC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b !RAM_SMW_Misc_SecondLevelLayerXPosHi
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ Sprite's Y position += $28
	CLC				; | for call to below routine
	ADC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b !RAM_SMW_Misc_SecondLevelLayerYPosHi
	STA.w !RAM_SMW_NorSpr_YPosHi,x
#LMBlockOffset_Unknown5:
	JSR.w CODE_019211		;>sprite bouyancy
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Restore sprite's original position
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b !RAM_SMW_Misc_SecondLevelLayerXPosHi
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b !RAM_SMW_Misc_SecondLevelLayerYPosHi
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;\If touching layer 2 from above, branch
	BPL.b CODE_0191BE		;/
	AND.b #$03			;\If left or right bits set, branch
	BNE.b CODE_0191BE		;/
	LDY.b #$00			;>Y = #$00
	LDA.w !RAM_SMW_Misc_Layer2XDisp	; \ A = -$17BF
	EOR.b #$FF
	INC
	BPL.b CODE_0191B2		;>If results negative, branch
	DEY				;>Y = #$FF
CODE_0191B2:
	CLC				;\Add by sprite x position
	ADC.b !RAM_SMW_NorSpr_XPosLo_x	;/
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;>And set sprite's x pos
	TYA				;>A = #$FF
	ADC.w !RAM_SMW_NorSpr_XPosHi,x	;\And update hi byte position
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
CODE_0191BE:
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,x				;\ Note: !Define_SMW_NorSpr_190FProp_DontGetStuckInWallsWhenCarried
	BPL.b CODE_0191ED							;/
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_0191ED
	TAY				;>Object status in Y (left and right)
	LDA.w !RAM_SMW_NorSpr_OnYoshisTongue,x	;\Sprite eaten table
	BNE.b CODE_0191ED		;/
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\Add by a table minus 1 (1 byte before the actual table)
	CLC				;|
	ADC.w DATA_019284-$01,y		;/
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;\And set sprite x pos (push sprite out of wall)
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;|Note that this executes even if the player is currently carrying
	ADC.w DATA_019286-$01,y		;|the sprite.
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;\If sprite moving, branch
	BNE.b CODE_0191ED		;/
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;\Clear left and right bits (if still)
	AND.b #$FC			;|
	STA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;/
CODE_0191ED:
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x	;>Liquid table
	EOR.w !RAM_SMW_Sprites_SpriteEnterOrExitingWater	;>Flip bits by other sprite
	BEQ.b Return019210		;>If zero, done.
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	TAY
else
	ASL				;!
endif
	LDA.w !RAM_SMW_NorSpr_PropertyBits166E,x	;! \ TODO: Unknown Bit A...
	AND.b #!Define_SMW_NorSpr_166EProp_DisableSplashing	;! | ... may be related to cape
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E1FE2,x	;!
	BNE.b Return019210		;!
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_NorSpr_YPosLo,X
	SEC
	SBC.w !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$D2
	BCS.b Return019210
	TYA
	BMI.b CODE_01920C
else
	BCS.b CODE_01920C		;!
endif
	BIT.w !RAM_SMW_Misc_NMIToUseFlag	;>Bit test $0D9B (level modes)
	BMI.b CODE_01920C		;>If still negative, branch
	JSL.l SMW_SpawnWaterSplash_Main	;>Some splash code
	RTS

CODE_01920C:
	JSL.l SMW_SpawnLavaSplash_Main
Return019210:
	RTS

; Sprite buoyancy routine. Called from the object interaction routine and
; handles collision points.
CODE_019211:
	LDA.w !RAM_SMW_Sprites_SpriteBuoyancySettings	;\If sprite boyancy is completely off, branch
	BEQ.b CODE_01925B		;/
	LDA.b !RAM_SMW_Flag_UnderwaterLevel	;\Make sprite always water if level is water rather than by blocks
	BNE.b CODE_019258		;/
	LDY.b #$3C			;>Y = #$3C
	JSR.w CODE_01944D		;>Line guide stuff
	BEQ.b CODE_019233		;>If results zero, branch
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;\If block behavors is #$00 to #$6D (#$6E = 3-up moon)
	CMP.b #$6E			;|
	BCC.b CODE_01925B		;/Branch
	JSL.l SMW_CheckForWaterSlope_Main	;>Slope stuff
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;>Load map16 behavor
	BCC.b CODE_01925B		;>If carry set from slope branch
	BCS.b CODE_01923A		;>Inverse of above
CODE_019233:
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;\If tiles #$06 (vine) and further branch
	CMP.b #$06			;|
	BCS.b CODE_01925B		;/
CODE_01923A:
	TAY				;>Transfer map16 into index
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x	;\Determine what tile is water?
	ORA.b #$01			;|>Set bit 0
	CPY.b #$04			;/
	BNE.b CODE_019258		;>if not zero, branch
	PHA				;>Save liquid status.
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if Yoshi
	CMP.b #!Define_SMW_SpriteID_NorSpr035_Yoshi
	BEQ.b CODE_019252
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ Branch if "Process interaction every frame"
	AND.b #!Define_SMW_NorSpr_167AProp_InvincibleToMostThings	; | is set
	BNE.b CODE_019255
CODE_019252:
	JSR.w CODE_019330		;>Sink in lava
CODE_019255:
	PLA				;>restore map16 status
	ORA.b #$80			;>Set bit 7 of liquid status
CODE_019258:
	STA.w !RAM_SMW_NorSpr_InLiquidFlag,x	;>Some lava stuff
CODE_01925B:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,x				;\ Note: !Define_SMW_NorSpr_1686Prop_DisableObjectClipping
	BMI.b Return019210							;/
	LDA.w !RAM_SMW_Misc_ScratchRAM7E185E	;\If tile generation is 0, branch?
	BEQ.b CODE_01926F		;/
	BIT.w !RAM_SMW_Sprites_SpriteBuoyancySettings
	BVS.b Return0192C0		;If enabled, return?
	LDA.w !RAM_SMW_NorSpr_PropertyBits166E,x				;\ Note: !Define_SMW_NorSpr_166EProp_OnlyInteractWithLayer1
	BMI.b Return0192C0							;/
CODE_01926F:
#LMBlockOffset_Unknown1:
	JSR.w CODE_0192C9		;>Handle spriteV offset
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,x				;\ Note: !Define_SMW_NorSpr_190FProp_DontGetStuckInWallsWhenCarried
	BPL.b CODE_019288							;/
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	; \ Branch if sprite has X speed...
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E15AC,x	; | ...or sprite is turning
	BNE.b CODE_019288		;>Handle spriteH offset
	LDA.b !RAM_SMW_Counter_GlobalFrames	;>Load frame counter (immume to freeze)
	JSR.w CODE_01928E		;>With the frame counter above, make horizontal collision point alternate between left and right
	RTS

DATA_019284:
	db $FC,$04

DATA_019286:
	db $FF,$00

CODE_019288:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	;\If not moving horizontal, return
	BEQ.b Return0192C0		;/
	ASL				;>Left shift speed value (bit 7 into carry)
	ROL				;>Now bit 7 is in bit 0
CODE_01928E:
	AND.b #$01			;>Clear all but bit 0
	TAY				;>Transfer to Y (Y= 0 or 1)
#LMBlockOffset_Unknown4:
	JSR.w CODE_019441		;>Get map16 numbers (the $C800s)
	STA.w !RAM_SMW_Sprites_Map16TileBeingTouchedHorizontallyHi	;>High byte of map16 tile (if moving horizontal)
	BEQ.b CODE_0192BA		;>If zero branch
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;>Block behavor
	CMP.b #$11			;>If #$11 (fence part?)
	BCC.b CODE_0192BA		;>Then branch
	CMP.b #$6E			;>if >= #$6E (3-up moon)
	BCS.b CODE_0192BA		;>Then branch
	JSR.w CODE_019425		;>Block touch positon
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;>Map16 number
	STA.w !RAM_SMW_Blocks_CopyOfCurrentlyProcessedMap16TileLo2	;>Mirror of above
	LDA.w !RAM_SMW_Misc_ScratchRAM7E185E	;>Tile generation
	BEQ.b CODE_0192BA		;if zero, branch
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;\Touching layer 2 from side
	ORA.b #$40			;|
	STA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;/
CODE_0192BA:
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;>Low byte map16 tile (not act as)
	STA.w !RAM_SMW_Sprites_Map16TileBeingTouchedHorizontallyLo	;>Mirror of above
Return0192C0:
	RTS

DATA_0192C1:
	db $FE,$02,$FF,$00

; [$01 $FF] Speed (right, left) given by conveyors (tiles 10C/10D) to
; sprites standing on them.
DATA_0192C5:
	db $01,$FF

DATA_0192C7:
	db $00,$FF

CODE_0192C9:
	LDY.b #$02			;>Switch y index to #$02 (bottom collision point of sprite)
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;\If not moving vertically or going downwards, branch over
	BPL.b CODE_0192D0		;/from changing Y (move spriteV collision point to top of sprite)
	INY				;>Y = #$03 (top collision point of sprite)
CODE_0192D0:
#LMBlockOffset_Unknown3:
	JSR.w CODE_019441		;>Get map16 number
	STA.w !RAM_SMW_Sprites_Map16TileBeingTouchedVerticallyHi	;>Set high byte map16 tile
	PHP				;>Save processor flags
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;\some other tile number
	STA.w !RAM_SMW_Sprites_Map16TileBeingTouchedVerticallyLo	;/
	PLP				;>Get back processor flags
	BEQ.b Return01930F		;>If zero flag set, return
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;>Some map16 number in A
	CPY.b #$02			;\Some various tile number to react to.
	BEQ.b CODE_019310		;|
	CMP.b #$11			;|
	BCC.b Return01930F		;|
	CMP.b #$6E			;|
	BCC.b CODE_0192F9		;|
	CMP.w !RAM_SMW_Blocks_LowestNumberSolidMap16TileForSprites	;|
	BCC.b Return01930F		;|
	CMP.w !RAM_SMW_Blocks_HighestNumberSolidMap16TileForSprites	;|
	BCS.b Return01930F		;/
CODE_0192F9:
	JSR.w CODE_019425		;>Block touch position
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;\Copy some map16 numbers
	STA.w !RAM_SMW_Blocks_CopyOfCurrentlyProcessedMap16TileLo1	;/
	LDA.w !RAM_SMW_Misc_ScratchRAM7E185E	;\If tile generation is 0, return
	BEQ.b Return01930F		;/
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;\Touching layer 2 from below bit
	ORA.b #$20			;|
	STA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;/
Return01930F:
	RTS

CODE_019310:
	CMP.b #$59			;\Some various map16 numbers to react to.
	BCC.b CODE_01933B		;|
	CMP.b #$5C			;|
	BCS.b CODE_01933B		;/
	LDY.w !RAM_SMW_Misc_LevelTilesetSetting	;\Tileset settings (like how line guides), so sprites that
	CPY.b #$0E			;|react to tiles based on level (castle, ghost house, etc)
	BEQ.b CODE_019323		;|works correctly
	CPY.b #$03			;|
	BNE.b CODE_01933B		;/
CODE_019323:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if sprite == Yoshi
	CMP.b #!Define_SMW_SpriteID_NorSpr035_Yoshi
	BEQ.b CODE_019330
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ Branch if "Process interaction every frame"
	AND.b #!Define_SMW_NorSpr_167AProp_InvincibleToMostThings	; | is set
	BNE.b CODE_01933B
CODE_019330:
	LDA.b #!Define_SMW_NorSprStatus05_SinkInLava	; \ Sprite status = #$05 ???
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$40			;\timer sinking in lava
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x	;/
	RTS

CODE_01933B:
	CMP.b #$11			;\Another set of special tiles
	BCC.b CODE_0193B0		;|
	CMP.b #$6E			;|
	BCC.b CODE_0193B8		;|
	CMP.b #$D8			;|
	BCS.b CODE_019386		;/
	JSL.l SMW_CheckWhatSlopeSpriteIsOn_Main	;>Slope pointers?
	LDA.b [!RAM_SMW_Misc_ScratchRAM05],y	;\Load stuff from a table
	CMP.b #$10			;|
	BEQ.b Return0193AF		;|
	BCS.b CODE_019386		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$0C
	BCS.b CODE_01935D
	CMP.b [!RAM_SMW_Misc_ScratchRAM05],y
	BCC.b Return0193AF
CODE_01935D:
	LDA.b [!RAM_SMW_Misc_ScratchRAM05],y
	STA.w !RAM_SMW_Sprites_DistanceToSnapDownToNearestTile
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM08
	LDA.l SMW_SlopeDataTables_SlopeType,x
	PLX
	STA.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	CMP.b #$04
	BEQ.b CODE_019375
	CMP.b #$FC
	BNE.b CODE_019384
CODE_019375:
	EOR.b !RAM_SMW_NorSpr_XSpeed,x
	BPL.b CODE_019380
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b CODE_019380
	JSR.w SMW_ChangeNormalSpriteDirection_Main
CODE_019380:
	JSL.l CODE_03C1CA
CODE_019384:
	BRA.b CODE_0193B8

CODE_019386:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	AND.b #$0F
	CMP.b #$05
	BCS.b Return0193AF
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Return if sprite status == Killed
	CMP.b #!Define_SMW_NorSprStatus02_Dead
	BEQ.b Return0193AF
	CMP.b #!Define_SMW_NorSprStatus05_SinkInLava	; \ Return if sprite status == #$05
	BEQ.b Return0193AF
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	; \ Return if sprite status == Carried
	BEQ.b Return0193AF
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\Make sprite rise
	SEC				;|
	SBC.b #$01			;|
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;|
	SBC.b #$00			;|
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;/
	JSR.w CODE_0192C9
Return0193AF:
	RTS

CODE_0193B0:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;>Y position
	AND.b #$0F			;>Centered within 16x16
	CMP.b #$05			;\If 5 pixels or higher
	BCS.b Return019424		;/then return
CODE_0193B8:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,x	;\Branch if weird ground behavor applies
	AND.b #!Define_SMW_NorSpr_1686Prop_DisableGroundShifting	;|
	BNE.b CODE_019414		;/
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Return if sprite status == Killed
	CMP.b #!Define_SMW_NorSprStatus02_Dead
	BEQ.b Return019424
	CMP.b #!Define_SMW_NorSprStatus05_SinkInLava	; \ Return if sprite status == #$05
	BEQ.b Return019424
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	; \ Return if sprite status == Carried
	BEQ.b Return019424
	LDY.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;\Probably used by climbing koopa?
	CPY.b #$0C			;|
	BEQ.b CODE_0193D9		;|
	CPY.b #$0D			;|
	BNE.b CODE_019405		;/
CODE_0193D9:
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\Other than the 4th frames, branch
	AND.b #$03			;|
	BNE.b CODE_019405		;/
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BNE.b CODE_019405
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting	;\Tileset handling
	CMP.b #$02			;|>Rope
	BEQ.b ADDR_0193EF		;|
	CMP.b #$08			;|>Rope 3
	BNE.b CODE_019405		;/
; The code that makes sprites move if placed on conveyor belts.
ADDR_0193EF:
	TYA				;\Not sure why nintendo would use the tileset number (Y)
	SEC				;|as a value to add and store to sprite position.
	SBC.b #$0C			;|
	TAY				;|
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;|
	CLC				;|
	ADC.w DATA_0192C5,y		;|
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;|
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;|
	ADC.w DATA_0192C7,y		;|
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
CODE_019405:
	LDA.w !RAM_SMW_NorSpr_OnYoshisTongue,x	;\If sprite eaten, branch
	BNE.b CODE_019414		;/
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\How much to move down from nearest 16x16 tile
	AND.b #$F0			;|
	CLC				;|
	ADC.w !RAM_SMW_Sprites_DistanceToSnapDownToNearestTile	;|
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;/
CODE_019414:
	JSR.w CODE_019435		;>Activate blocked status
	LDA.w !RAM_SMW_Misc_ScratchRAM7E185E	;\If tile generation is clear, return
	BEQ.b Return019424		;/
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;\Touch layer 2 from above.
	ORA.b #$80			;|
	STA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;/
Return019424:
	RTS

CODE_019425:
	LDA.b !RAM_SMW_Misc_ScratchRAM0A	;\Block touching offsets transfer to mario's collision points.
	STA.b !RAM_SMW_Blocks_XPosLo	;|
	LDA.b !RAM_SMW_Misc_ScratchRAM0B	;|
	STA.b !RAM_SMW_Blocks_XPosHi	;|
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;|
	STA.b !RAM_SMW_Blocks_YPosLo	;|
	LDA.b !RAM_SMW_Misc_ScratchRAM0D	;|
	STA.b !RAM_SMW_Blocks_YPosHi	;/
CODE_019435:
	LDY.b !RAM_SMW_Misc_ScratchRAM0F	;>$0F = which of the "4" collision points?
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;\Set blocked status (sets one bit depending on $0F).
	ORA.w DATA_019134,y		;|
	STA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;/
	RTS

CODE_019441:
	STY.b !RAM_SMW_Misc_ScratchRAM0F	; Can be 00-03
	LDA.w !RAM_SMW_NorSpr_PropertyBits1656,x	; \ Y = $1656,x (Upper 4 bits) + $0F (Lower 2 bits)
	AND.b #!Define_SMW_NorSpr_1656Prop_ObjectClipping
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	TAY
CODE_01944D:
	LDA.w !RAM_SMW_Misc_ScratchRAM7E185E	;\Incremement tile generation by 1
	INC				;/
	AND.b !RAM_SMW_Misc_LevelLayoutFlags	;clear out some bits based on level type
	BEQ.b CODE_0194BF		;>If all zero branch to horizontal level
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\Set clipping points (Y pos) in $0C
	CLC				;|
	ADC.w SpriteObjClippingY,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM0C	;/
	AND.b #$F0			;>Align with 16x16 grid
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>block y pos in $00
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;\Get carry if Y pos exceeds #$FF
	ADC.b #$00			;/
	CMP.b !RAM_SMW_Misc_ScreensInLvl	;\Also use carry if exceeds last screen in level
	BCS.b CODE_0194B4		;/
	STA.b !RAM_SMW_Misc_ScratchRAM0D	;>And store highbyte to $0D (so $0C in 16-bit is the Y pos of collision point)
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\Set clipping points (x pos) in $0A
	CLC				;|
	ADC.w SpriteObjClippingX,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM0A	;/
	STA.b !RAM_SMW_Misc_ScratchRAM01	;>Store a copy of x position in $01
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;\High bytes
	ADC.b #$00			;/
	CMP.b #$02			;\If exceeds the right edge of the vertical level, treat as of there are no blocks there.
	BCS.b CODE_0194B4		;/
	STA.b !RAM_SMW_Misc_ScratchRAM0B	;>And store highbyte to $0B (so $0A in 16-bit is the x pos of collision point)
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;>X position
	LSR				;\Divide by 16 (so that each increment of a single 16x16 block equals 16 pixels of movement of sprite)
	LSR				;|(so this converts sprite position into block position)
	LSR				;|
	LSR				;/
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;>Set some bits by x position high byte
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>Store to $00
	LDX.b !RAM_SMW_Misc_ScratchRAM0D	;>high byte of X to be loaded in index (by the way, the high byte x pos is the screen number)
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L1,x	;>Low byte map16 pointers for vertical levels
	LDY.w !RAM_SMW_Misc_ScratchRAM7E185E	;>Load tile generate RAM into Y index
	BEQ.b CODE_01949A		;>If tile generate 0, branch
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L2,x	;>Replace to use another set of tables
CODE_01949A:
	CLC				;\Add by x position high byte
	ADC.b !RAM_SMW_Misc_ScratchRAM00	;/
	STA.b !RAM_SMW_Misc_ScratchRAM05	;>and store to $05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L1,x	;>High byte version of $00BA80
	LDY.w !RAM_SMW_Misc_ScratchRAM7E185E	;>Tile generation RAM
	BEQ.b CODE_0194AC		;>If zero, branch
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L2,x	;>Replace to use another set of tables
CODE_0194AC:
	ADC.b !RAM_SMW_Misc_ScratchRAM0B	;>Add by $0B (x position high byte)
	STA.b !RAM_SMW_Misc_ScratchRAM06	;>And store to $06
	JSR.w CODE_019523
	RTS

CODE_0194B4:
	LDY.b !RAM_SMW_Misc_ScratchRAM0F	;>???
	LDA.b #$00			;\Set behavor?
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;/
	STA.w !RAM_SMW_Sprites_DistanceToSnapDownToNearestTile	;>And set number of pixels ROUNDED DOWN to nearest 16x16 block
	RTS

CODE_0194BF:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\Set clipping points (Y pos) in $0C
	CLC				;|
	ADC.w SpriteObjClippingY,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM0C	;/
	AND.b #$F0			;>Align with 16x16 grid
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>block y pos in $00
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;\Store highbyte to $0D (so $0C in 16-bit is the Y pos of collision point)
	ADC.b #$00			;|
	STA.b !RAM_SMW_Misc_ScratchRAM0D	;/
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\The position past the bottom of the horizontal level (past the bottom subscreen boundary).
	CMP.w #$01B0			;/
	SEP.b #$20			; A->8
	BCS.b CODE_0194B4		;>If exceed (outside the level), treat as of there are no blocks exist there
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\Set clipping points (x pos) in $0A
	CLC				;|
	ADC.w SpriteObjClippingX,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM0A	;/
	STA.b !RAM_SMW_Misc_ScratchRAM01	;>Store a copy of x position in $01
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B			;\ Optimization: I don't think this line of code is necessary, as if the sprite is going off the left side of the level, it's position will be greater than $1F.
	BMI.b CODE_0194B4					;| This STA.b !RAM_SMW_Misc_ScratchRAM0B can also be moved to after this block of code
	CMP.b !RAM_SMW_Misc_ScreensInLvl			;|
	BCS.b CODE_0194B4					;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	LSR				;\Divide by 16 (so that each increment of a single 16x16 block equals 16 pixels of movement of sprite)
	LSR				;|(so this converts sprite position into block position)
	LSR				;|
	LSR				;/
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;>Set some bits by x position high byte
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>Store to $00
	LDX.b !RAM_SMW_Misc_ScratchRAM0B	;>Add by $0B (x position high byte)
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L1,x	;>Low byte map16 pointers
	LDY.w !RAM_SMW_Misc_ScratchRAM7E185E	;>Tile generation RAM
	BEQ.b CODE_01950D		;>If zero, branch
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L2,x	;>Replace with another set of tables
CODE_01950D:
	CLC				;\Table add by y pos (equivalent to adding index by #$10 on the $C800s index)
	ADC.b !RAM_SMW_Misc_ScratchRAM00	;|
	STA.b !RAM_SMW_Misc_ScratchRAM05	;/
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L1,x	;>Load pointer table
	LDY.w !RAM_SMW_Misc_ScratchRAM7E185E	;\If tile generation RAM zero, branch
	BEQ.b CODE_01951F		;/
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L2,x	;>Replace with another set of tables
CODE_01951F:
	ADC.b !RAM_SMW_Misc_ScratchRAM0D	;>Add by Y pos high byte
	STA.b !RAM_SMW_Misc_ScratchRAM06	;>And store to $06
CODE_019523:
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16	;\Set bank to $7E for loading $7EC800 (the low byte map16 RAM in level)
	STA.b !RAM_SMW_Misc_ScratchRAM07	;/
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]	;\Current block being checked
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;/
	INC.b !RAM_SMW_Misc_ScratchRAM07	;>Switch bank into $7F for loading $7FC800 (the high byte map16 RAM in level)
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]	;>Load the $C800s
#LM000Hijack_ProcessCustomNormalSpriteBlockCode:
if !Define_SMW_CustomTiles == !TRUE
	JSL.l SMW_CustomTiles_ActsLikeOf		;> A custom tile as the vanilla tile it acts like, then the stock routine (Config/CustomTiles.asm)
else
	JSL.l SMW_ModifyMap16IDForSpecialBlocks_Main
endif
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	CMP.b #$00
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprStatus09_Stunned(Address)
namespace SMW_NorSprStatus09_Stunned
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x				;\
	CMP.b #!Define_SMW_SpriteID_NorSpr02C_YoshiEgg			;| Todo: Is this !RAM_SMW_NorSpr_Table7E00C2 ever non-zero?
	BNE.b CODE_019554						;| If not, then this code is useless.
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x				;|
	BEQ.b CODE_01956A						;/
BulletBillEntry:
	LDA.b !RAM_SMW_Sprites_TilePriority	; \ Temporarily set $64 = #$10...
	PHA
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1	; | ...and call gfx routine
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	RTS

CODE_019554:
	CMP.b #!Define_SMW_SpriteID_NorSpr02F_PortableSpringboard	; \ If Spring Board...
	BEQ.b SetNormalStatus2		; | ...Unused Sprite 85...
	CMP.b #!Define_SMW_SpriteID_NorSpr085_Unused	; | ...or Balloon,
	BEQ.b SetNormalStatus2		; | Set Status = Normal...
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon	; |  ...and jump to $01A187
	BNE.b CODE_01956A
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; | Balloon Y Speed = 0
SetNormalStatus2:
	LDA.b #!Define_SMW_NorSprStatus08_Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	JMP.w SMW_ProcessStunnedNormalSprite_Main

CODE_01956A:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ If sprites locked,
	BEQ.b CODE_019571		; | jump to $0195F5
	JMP.w CODE_0195F5

CODE_019571:
	JSR.w CODE_019624
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_019598
	JSR.w SMW_MakeStunnedSpriteBounceOrSlowDownOnGround_Main
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr016_VerticalCheepCheep	; \ If Vertical or Horizontal Fish,
	BEQ.b ADDR_019589
	CMP.b #!Define_SMW_SpriteID_NorSpr015_HorizontalCheepCheep	; | jump to $019562
	BNE.b CODE_01958C
ADDR_019589:
	JMP.w SetNormalStatus2

CODE_01958C:
	CMP.b #!Define_SMW_SpriteID_NorSpr02C_YoshiEgg	; \ Branch if not Yoshi Egg
	BNE.b CODE_019598
	LDA.b #$F0			; \ Set upward speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_PrepareToHatchNormalSpriteYoshiEgg_Entry2
CODE_019598:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling
	BEQ.b CODE_0195DB
	LDA.b #$10			; \ Set downward speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BNE.b CODE_0195DB
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $9A = Sprite X position + #$08
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $9A = Sprite X position
	AND.b #$F0			; | (Rounded down to nearest #$10)
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$20
	ASL
	ASL
	ASL
	ROL
	AND.b #$01
	STA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	LDY.b #$00
	LDA.w !RAM_SMW_Blocks_CopyOfCurrentlyProcessedMap16TileLo1
	JSL.l SMW_CheckIfBlockWasHit_Main
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1FE2,x
CODE_0195DB:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b CODE_0195F2
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Call $0195E9 if sprite number < #$0D
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb	; | (Koopa Troopas)
	BCC.b CODE_0195E9
	JSR.w SMW_MakeNormalSpriteReboundOffWall_Main
CODE_0195E9:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	ASL
	PHP
	ROR.b !RAM_SMW_NorSpr_XSpeed,x
	PLP
	ROR.b !RAM_SMW_NorSpr_XSpeed,x
CODE_0195F2:
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
CODE_0195F5:
	JSR.w SMW_ProcessStunnedNormalSprite_Main
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	RTS

; Unused data.
UNK_0195FC:
	db $00,$00,$00,$00,$04,$05,$06,$07
	db $00,$00,$00,$00,$04,$05,$06,$07
	db $00,$00,$00,$00,$04,$05,$06,$07
	db $00,$00,$00,$00,$04,$05,$06,$07

; Sprites spawned by stomping Koopa Troopas (shelless Koopas)
SpriteKoopasSpawn:
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr001_RedNakedKoopa
	db !Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa
	db !Define_SMW_SpriteID_NorSpr003_YellowNakedKoopa

CODE_019624:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch away if sprite isn't a Bob-omb
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb
	BNE.b CODE_01965C
	; Code that handles the Bob-omb flashing and exploding. Change $019630 from
	; 1D to 1C to disable the flashing entirely.
	LDA.w !RAM_SMW_NorSpr00D_BobOmb_WaitBeforeExplosion,x	; \ Branch away if it's not time to explode
	CMP.b #$01
	BNE.b CODE_01964E
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Bomb sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr00D_BobOmb_IsExploding,x
	LDA.b #$40			; \ Set explosion timer
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Set normal status
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,x	; \ Set to interact with other sprites
	AND.b #!Define_SMW_NorSpr_1686Prop_DisableSpriteClipping^$FF
	STA.w !RAM_SMW_NorSpr_PropertyBits1686,x
	RTS

CODE_01964E:
	CMP.b #$40
	BCS.b Return01965B
	ASL
	AND.b #$0E
	EOR.w !RAM_SMW_NorSpr_Table7E15F6,x
	STA.w !RAM_SMW_NorSpr_Table7E15F6,x
Return01965B:
	RTS

CODE_01965C:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	STA.b !RAM_SMW_NorSpr_Table7E00C2,x
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	BEQ.b CODE_01969C
	CMP.b #$01
	BNE.b CODE_01969C
	LDY.w !RAM_SMW_NorSpr_Table7E1594,x
	LDA.w !RAM_SMW_NorSpr_OnYoshisTongue,y
	BNE.b CODE_01969C
	JSL.l SMW_InitializeNormalSpriteRAMTables_YXPPCCCTAndPropertyTables
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	ASL.w !RAM_SMW_NorSpr_Table7E15F6,x
	LSR.w !RAM_SMW_NorSpr_Table7E15F6,x
	LDY.w !RAM_SMW_NorSpr_Table7E160E,x
	LDA.b #!Define_SMW_NorSprStatus08_Normal
	CPY.b #$03
	BNE.b CODE_019698
	INC.w !RAM_SMW_NorSpr_Table7E187B,x
	LDA.w !RAM_SMW_NorSpr_PropertyBits166E,x	; \ Disable fireball/cape killing
	ORA.b #!Define_SMW_NorSpr_166EProp_ImmuneToFire|!Define_SMW_NorSpr_166EProp_ImmuneToCape
	STA.w !RAM_SMW_NorSpr_PropertyBits166E,x
	LDA.b #!Define_SMW_NorSprStatus0A_Kicked	; \ Sprite status = Kicked
CODE_019698:
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
Return01969B:
	RTS

CODE_01969C:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x	; \ Return if stun timer == 0
	BEQ.b Return01969B
	CMP.b #$03			; \ If stun timer == 3, un-stun the sprite
	BEQ.b UnstunSprite
	CMP.b #$01			; \ Every other frame, increment the stall timer
	BNE.b IncrmntStunTimer		; /  to emulates a slower timer
UnstunSprite:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if Buzzy Beetle
	CMP.b #!Define_SMW_SpriteID_NorSpr011_BuzzyBeetle
	BEQ.b SetNormalStatus
	CMP.b #!Define_SMW_SpriteID_NorSpr02E_SpikeTop	; \ Branch if Spike Top
	BEQ.b SetNormalStatus
	CMP.b #!Define_SMW_SpriteID_NorSpr02D_BabyYoshi	; \ Return if Baby Yoshi
	BEQ.b Return0196CA
	CMP.b #!Define_SMW_SpriteID_NorSpr0A2_MechaKoopa	; \ Branch if MechaKoopa
	BEQ.b SetNormalStatus
	CMP.b #!Define_SMW_SpriteID_NorSpr00F_Goomba	; \ Branch if Goomba
	BEQ.b SetNormalStatus
	CMP.b #!Define_SMW_SpriteID_NorSpr02C_YoshiEgg	; \ Branch if Yoshi Egg
	BEQ.b Return0196CA
	CMP.b #!Define_SMW_SpriteID_NorSpr053_ThrowBlock	; \ Branch if not Throw Block
	BNE.b GeneralResetSpr
	JSR.w SMW_NorSprStatus02_Dead_SetNorSprStatus04_Main	; Set throw block to vanish
Return0196CA:
	RTS

SetNormalStatus:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite Status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	ASL.w !RAM_SMW_NorSpr_Table7E15F6,x	; \ Clear vertical flip bit
	LSR.w !RAM_SMW_NorSpr_Table7E15F6,x
	RTS

IncrmntStunTimer:
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Increment timer every other frame
	AND.b #$01
	BNE.b Return0196E0
	INC.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
Return0196E0:
	RTS

GeneralResetSpr:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free sprite slot found
	BMI.b Return0196CA
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Store sprite number for shelless koopa
	TAX
	LDA.w SpriteKoopasSpawn,x
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	TYX				; \ Reset sprite tables
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Shelless Koopa position = Koopa position
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b #$00			; \ Direction = 0
	STA.w !RAM_SMW_NorSpr_Table7E157C,y
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,y
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	STA.w !RAM_SMW_NorSpr_InLiquidFlag,y
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	CMP.b #$01
	BEQ.b CODE_019747
	LDA.b #$D0			; \ Set upward speed
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	PHY				; \ Make Shelless Koopa face away from Mario
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA
	EOR.b #$01
	PLY
	STA.w !RAM_SMW_NorSpr_Table7E157C,y
	PHX				; \ Set Shelless X speed
	TAX
	LDA.w SMW_NorSprXXX_GenericEnemies_Status08_Spr0to13SpeedX,x
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	PLX
	RTS

CODE_019747:
	PHY
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w DATA_0197AD,y
	STY.b !RAM_SMW_Misc_ScratchRAM00
	PLY
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_Table7E157C,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,y
	STA.w !RAM_SMW_NorSpr_Table7E1528,y
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ If Yellow Koopa...
	CMP.b #!Define_SMW_SpriteID_NorSpr007_YellowKoopa
	BNE.b Return019775
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$03	; | ...find free sprite slot...
CODE_01976D:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b SpawnMovingCoin		; | ...and spawn moving coin
	DEY
	BPL.b CODE_01976D
Return019775:
	RTS

SpawnMovingCoin:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin	; \ Sprite = Moving Coin
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Copy X position to coin
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ Copy Y position to coin
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; | Clear all sprite tables, and load new values
	PLX
	LDA.b #$D0			; \ Set Y speed
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01	; \ Set direction
	STA.w !RAM_SMW_NorSpr_FacingDirection,y
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,y
	RTS

DATA_0197AD:
	db $C0,$40
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GivePlayerStarPower(Address)
namespace SMW_GivePlayerStarPower
%InsertMacroAtXPosition(<Address>)

; Star Subroutine. JSL to it to give Mario star power. $01C581 controls how
; long stars last, $01C586 controls the music that is played during star
; power.
Main:
	LDA.b #$FF			; \ Set star timer
	STA.w !RAM_SMW_Timer_StarPower
	LDA.b #!Define_SMW_LevelMusic_HaveStar	; change music
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	ASL.w !RAM_SMW_Misc_MusicRegisterBackup	; shift music value left 1 bit...
	SEC				; set carry flag...
	ROR.w !RAM_SMW_Misc_MusicRegisterBackup	; ...and rotate music byte right 1 bit, causing the music value to remain the same it was before except that bit 7 has now been set (?)
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnNormalSpriteTurnAroundSmoke(Address)
namespace SMW_SpawnNormalSpriteTurnAroundSmoke
%InsertMacroAtXPosition(<Address>)

; Routine to spawn dust sprite (smoke sprite number $03) at the sprite's
; position. Used for example by Sliding Koopas and Monty Moles.
Main:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if in air
	BEQ.b Return018072
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\
	AND.b #$03			;| Every three frames, if it isn't a slippery
	ORA.b !RAM_SMW_Flag_IceLevel	;| level..
	BNE.b Return018072		;/ return.
	LDA.b #$04			;\ this will be used later
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/ in the smoke image display.
	LDA.b #$0A			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ and again.
Entry2:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01	; Checking if the sprite is offscreen...
	BNE.b Return018072		; If it is, then return.
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot	;---Loop time!
CODE_01806A:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y	;Load the smoke image frame...
	BEQ.b CODE_018073		;if it's not showing, branch..
	DEY				; check the next smoke image frame...
	BPL.b CODE_01806A		; until it reaches 0, when it should...
Return018072:
	RTS

CODE_018073:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr03_TurnAroundSmoke	;\
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y	;/ make the not-showing smoke frame frame 3.
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\ Load the sprite's Xpos
	ADC.b !RAM_SMW_Misc_ScratchRAM00	;| add a little bit (orig. #$04, see above)
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y	;/ and make that the smoke image Xpos.
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\
	ADC.b !RAM_SMW_Misc_ScratchRAM01	;| and make the smoke ypos just a little bit
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y	;/ below the sprite.
	LDA.b #$13			;\ and then set the time for the smoke to display
	STA.w !RAM_SMW_SmokeSpr_Timer,y	;/ to 13 (frames? probably)
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_CheckForNormalSpriteToNormalSpriteCollision(Address)
namespace SMW_CheckForNormalSpriteToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

; JSL wrapper for the sprite subroutine at $01A40D, which when called will
; process standard interactions between the sprite and other sprites.
Main:
	PHB
	PHK				; Start of the sprite-on-sprite-contact
	PLB				; routine (Details not covered by my
	JSR.w Sub			; commentary
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckForNormalSpriteToNormalSpriteCollision(Address)
namespace SMW_CheckForNormalSpriteToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

DATA_01A40B:
	db $02,$0A			;>Offset positions based on tweaker

; The primary routine used to process most standard interactions between a
; sprite and other sprites; call this routine from within the sprite's MAIN
; routine to do so. A JSL to this routine can be found at $018032. When two
; sprites are interacting, only the sprite in the higher slot actually
; processes it to prevent the interaction from being handled twice.
; Interactions can be prevented entirely by setting either sprite's "don't
; interact with other sprites" tweaker bit ($1686) or $1564. Notably, not
; using one of these two methods and instead simply not calling the routine
; in the first place does not guarantee interaction will not be processed,
; as it can still occur if the handling is coming from a sprite in a higher
; slot. An example of this in the original game exists with shells and
; Thwomps, who are immune to thrown shells when they handle the interaction,
; but are killed when the shell does instead. Overwrites $00-$03 when
; called. When processing interaction for sprites in status 8 that have the
; "change direction when touched" tweaker bit set ($1686), $157C is assumed
; to be their horizontal direction and $15AC will be set for a timer
; intended to control a turning-around animation for the sprite.
Sub:
	TXA				;\If Sprite A is the "bottom-index" sprite, then there are no sprites below it, we are done
	BEQ.b SMW_GenericGFXRtMoveTileOffscreenVertically_Return01A40A	;/(if higher sprites did call $018032 then those will be handling interaction with this sprite.)
	TAY				;>Y = Sprite A index
	EOR.b !RAM_SMW_Counter_GlobalFrames	; \ Return every other frame
if defined("Define_SMW_SA1")
	; SA-1 Pack: sprite <-> sprite interaction routine now properly fixed.
	JML.l SPR_SPR_INTERACT_INIT
else
	LSR
	BCC.b SMW_GenericGFXRtMoveTileOffscreenVertically_Return01A40A
	DEX				;>X = Sprite_B (this is the index of all the slots below sprite_A)
endif
CODE_01A417:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Jump to $01A4B0 if
	CMP.b #!Define_SMW_NorSprStatus08_Normal	; | sprite status < 8
	BCS.b CODE_01A421
	JMP.w CODE_01A4B0

CODE_01A421:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,x	;\SWYE bits of tweaker $1686, which is some interaction with other sprites settings.
	ORA.w !RAM_SMW_NorSpr_PropertyBits1686,y	;|
	AND.b #!Define_SMW_NorSpr_1686Prop_DisableSpriteClipping	;/
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x	;\Don't interact if their intangibility timers are going
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,y	;/
	ORA.w !RAM_SMW_NorSpr_OnYoshisTongue,x	;>Don't interact if one of them is on yoshi's tongue
	ORA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x	;\They must be on the same layer (mainly used by net koopas to change direction)
	EOR.w !RAM_SMW_NorSpr_CurrentLayerPriority,y	;/
	BNE.b CODE_01A4B0		;>If any of the above conditions were false, next slot
	STX.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex	;>$1695 = sprite B's index (preserve it because we are going to use X for something else)
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\$00-$01: X position of X index (Sprite_B)
	STA.b !RAM_SMW_Misc_ScratchRAM00	;|$02-$03: X position of Y index (Sprite_A)
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;|
	STA.b !RAM_SMW_Misc_ScratchRAM01	;|
	LDA.w !RAM_SMW_NorSpr_XPosLo,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM02	;|
	LDA.w !RAM_SMW_NorSpr_XPosHi,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\Horizontal distance between the two
	SEC				;|
	SBC.b !RAM_SMW_Misc_ScratchRAM02	;/
	CLC
	ADC.w #$0010
	CMP.w #$0020
	SEP.b #$20			; A->8
	BCS.b CODE_01A4B0
	LDY.b #$00			;>Y = Tweaker clipping hitbox offset
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x	;\Adjust that Y-index based on tweaker setting
	AND.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping0F	;|
	BEQ.b CODE_01A46C		;|
	INY				;/
CODE_01A46C:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\$00-$01: Y position of X index of "hitbox"
	CLC				;|
	ADC.w DATA_01A40B,y		;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;|
	ADC.b #$00			;|
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDY.w !RAM_SMW_NorSpr_CurrentSlotID	; Y = Sprite index
	LDX.b #$00			;>X = Tweaker clipping hitbox offset
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,y	;\Adjust that X-index based on tweaker setting
	AND.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping0F	;|
	BEQ.b CODE_01A488		;|
	INX				;/
CODE_01A488:
	LDA.w !RAM_SMW_NorSpr_YPosLo,y
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l DATA_01A40B,x
else
	ADC.w DATA_01A40B,x
endif
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_YPosHi,y
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDX.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex	;>Restore sprite_B's index for X
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\Vertical distance between the two
	SEC				;|
	SBC.b !RAM_SMW_Misc_ScratchRAM02	;/
	CLC
	ADC.w #$000C
	CMP.w #$0018
	SEP.b #$20			; A->8
	BCS.b CODE_01A4B0
	JSR.w CODE_01A4BA		;>Handle what action to take when contact was detected
CODE_01A4B0:
if defined("Define_SMW_SA1")
	JML.l SPR_SPR_INTERACT_LOOP
	db $17,$A4	; the tail of the JMP.w below, which the hijack leaves unreached
else
	DEX				;\Next slot (loop) until the slot counter goes from 0 to -1
	BMI.b CODE_01A4B6		;|
	JMP.w CODE_01A417		;/
endif

CODE_01A4B6:
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

CODE_01A4BA:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	; \ Branch if sprite 2 status == Normal
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_01A4CE
	CMP.b #!Define_SMW_NorSprStatus09_Stunned	; \ Branch if sprite 2 status == Carryable
	BEQ.b CODE_01A4E2
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked	; \ Branch if sprite 2 status == Kicked
	BEQ.b CODE_01A506
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	; \ Branch if sprite 2 status == Carried
	BEQ.b CODE_01A51A
	RTS

CODE_01A4CE:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Branch if sprite status == Normal
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_01A53D
	CMP.b #!Define_SMW_NorSprStatus09_Stunned	; \ Branch if sprite status == Carryable
	BEQ.b CODE_01A540
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked	; \ Branch if sprite status == Kicked
	BEQ.b CODE_01A537
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	; \ Branch if sprite status == Carried
	BEQ.b CODE_01A534
	RTS

CODE_01A4E2:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,y	; \ Branch if on ground
	AND.b #$04
	BNE.b CODE_01A4F2
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ Branch if Goomba
	CMP.b #!Define_SMW_SpriteID_NorSpr00F_Goomba
	BEQ.b CODE_01A534
	BRA.b CODE_01A506

CODE_01A4F2:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Branch if sprite status == Normal
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_01A540
	CMP.b #!Define_SMW_NorSprStatus09_Stunned	; \ Branch if sprite status == Carryable
	BEQ.b CODE_01A555
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked	; \ Branch if sprite status == Kicked
	BEQ.b ADDR_01A53A
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	; \ Branch if sprite status == Carried
	BEQ.b CODE_01A534
	RTS

CODE_01A506:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Branch if sprite status == Normal
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_01A52E
	CMP.b #!Define_SMW_NorSprStatus09_Stunned	; \ Branch if sprite status == Carryable
	BEQ.b CODE_01A531
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked	; \ Branch if sprite status == Kicked
	BEQ.b CODE_01A534
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	; \ Branch if sprite status == Carried
	BEQ.b CODE_01A534
	RTS

CODE_01A51A:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Branch if sprite status == Normal
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_01A534
	CMP.b #!Define_SMW_NorSprStatus09_Stunned	; \ Branch if sprite status == Carryable
	BEQ.b CODE_01A534
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked	; \ Branch if sprite status == Kicked
	BEQ.b CODE_01A534
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	; \ Branch if sprite status == Carried
	BEQ.b CODE_01A534
	RTS

CODE_01A52E:
	JMP.w CODE_01A625

CODE_01A531:
	JMP.w CODE_01A642

CODE_01A534:
	JMP.w CODE_01A685

CODE_01A537:
	JMP.w CODE_01A5C4

ADDR_01A53A:
	JMP.w CODE_01A5C4

CODE_01A53D:
	JMP.w CODE_01A56D

CODE_01A540:
	JSR.w CODE_01A6D9
	PHX
	PHY
	TYA
	TXY
	TAX
	JSR.w CODE_01A6D9
	PLY
	PLX
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,y
	BNE.b Return01A5C3
CODE_01A555:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus09_Stunned
	BNE.b CODE_01A56D
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BNE.b CODE_01A56D
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if not Goomba
	CMP.b #!Define_SMW_SpriteID_NorSpr00F_Goomba
	BNE.b CODE_01A56A
	JMP.w CODE_01A685

CODE_01A56A:
	JMP.w CODE_01A5C4

CODE_01A56D:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\compare (using subtract; carry = borrow) the positions between sprite A and B
	SEC				;|
	SBC.w !RAM_SMW_NorSpr_XPosLo,y	;| ;$01A57E = first sprite, $01A5A1 = other sprite
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;|
	SBC.w !RAM_SMW_NorSpr_XPosHi,y	;|
	ROL				;|\use negative sign bit into $00
	AND.b #$01			;||
	STA.b !RAM_SMW_Misc_ScratchRAM00	;//
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,y	;\Sprite tweaker: don't change direction when touched
	AND.b #!Define_SMW_NorSpr_1686Prop_DontChangeDirectionWhenTouched	;|
	BNE.b CODE_01A5A1		;/
	LDY.w !RAM_SMW_NorSpr_CurrentSlotID	; Y = Sprite index
	LDA.w !RAM_SMW_NorSpr_Table7E157C,y	;\flip sprite direction
	PHA				;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;|
	STA.w !RAM_SMW_NorSpr_Table7E157C,y	;|
	PLA				;/
	CMP.w !RAM_SMW_NorSpr_Table7E157C,y
	BEQ.b CODE_01A5A1		;\if already flipped?
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E15AC,y	;|\don't set timer if already set.
	BNE.b CODE_01A5A1		;//
	LDA.b #$08			; \ Set turning timer
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E15AC,y
CODE_01A5A1:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,x	;\Sprite tweaker: don't change direction when touched
	AND.b #!Define_SMW_NorSpr_1686Prop_DontChangeDirectionWhenTouched	;|
	BNE.b Return01A5C3		;/
	LDA.w !RAM_SMW_NorSpr_Table7E157C,x	;\flip other sprite direction
	PHA				;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;|
	EOR.b #$01			;|
	STA.w !RAM_SMW_NorSpr_Table7E157C,x	;|
	PLA				;/
	CMP.w !RAM_SMW_NorSpr_Table7E157C,x	;\return if already flipped?
	BEQ.b Return01A5C3		;/
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E15AC,x	;\don't set timer if already set.
	BNE.b Return01A5C3		;/
	LDA.b #$08			; \ Set turning timer
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E15AC,x
Return01A5C3:
	RTS

CODE_01A5C4:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	SEC
	SBC.b #!Define_SMW_SpriteID_NorSpr083_LeftFlyingBlock
	CMP.b #$02
	BCS.b CODE_01A5DA
	JSR.w SMW_ChangeNormalSpriteDirection_Main
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_01A5D3:
if defined("Define_SMW_SA1")
	JML.l SPR_SPR_INTERACT_4
	db $B4	; the tail of the JSR.w below, which the hijack leaves unreached
else
	PHX
	TYX
	JSR.w SMW_SolidSpriteBlock_Entry2
endif
	PLX
	RTS

CODE_01A5DA:
if defined("Define_SMW_SA1")
	JML.l SPR_SPR_INTERACT_5
	db $95,$76	; the tail of the LDY.w below, which the hijack leaves unreached
else
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex	;>sprite checking
endif
	JSR.w CODE_01A77C
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	PHX
	TYX
	JSL.l SMW_SpawnContactEffectFromSide_NoKickSound	;>smoke handling?
	PLX
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	ASL
	LDA.b #$10
	BCC.b CODE_01A5F8
	LDA.b #$F0
CODE_01A5F8:
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	LDA.b #$D0
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	PHY
	INC.w !RAM_SMW_NorSpr_Table7E1626,x
	LDY.w !RAM_SMW_NorSpr_Table7E1626,x
	CPY.b #$08
	BCS.b CODE_01A611
	LDA.w SMW_StompSoundTable_Bank01-$01,y
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_01A611:
	TYA
	CMP.b #$08
	BCC.b CODE_01A618
	LDA.b #$08
CODE_01A618:
	PLY
	JSL.l SMW_GivePoints_Entry2
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_CheckForNormalSpriteToNormalSpriteCollision(Address)
namespace SMW_CheckForNormalSpriteToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

CODE_01A625:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	SEC
	SBC.b #!Define_SMW_SpriteID_NorSpr083_LeftFlyingBlock
	CMP.b #$02
	BCS.b CODE_01A63D
	PHX
	TYX
	JSR.w SMW_ChangeNormalSpriteDirection_Main
	PLX
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	JSR.w SMW_SolidSpriteBlock_Entry2
	RTS

CODE_01A63D:
	JSR.w CODE_01A77C
	BRA.b CODE_01A64A

CODE_01A642:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BNE.b CODE_01A64A
	JMP.w CODE_01A685

CODE_01A64A:
	PHX
	LDA.w !RAM_SMW_NorSpr_Table7E1626,y	;\increment Consecutive enemies counter
	INC				;|
	STA.w !RAM_SMW_NorSpr_Table7E1626,y	;/
	LDX.w !RAM_SMW_NorSpr_Table7E1626,y
	CPX.b #$08
	BCS.b CODE_01A65F
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l SMW_StompSoundTable_Bank01-$01,x
else
	LDA.w SMW_StompSoundTable_Bank01-$01,x
endif
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_01A65F:
	TXA
	CMP.b #$08
	BCC.b CODE_01A666
	LDA.b #$08
CODE_01A666:
	PLX				;\points for every enemy killed (200, 400, 800, 1000...)
	JSL.l SMW_GivePoints_Main	;/
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	JSL.l SMW_SpawnContactEffectFromSide_NoKickSound	;>smoke handling?
	LDA.w !RAM_SMW_NorSpr_XSpeed,y
	ASL
	LDA.b #$10
	BCC.b CODE_01A67E
	LDA.b #$F0
CODE_01A67E:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	RTS

CODE_01A685:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if Flying Question Block
	CMP.b #!Define_SMW_SpriteID_NorSpr083_LeftFlyingBlock
	BEQ.b ADDR_01A69A
	CMP.b #!Define_SMW_SpriteID_NorSpr084_HorizontalFlyingBlock
	BEQ.b ADDR_01A69A
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	BRA.b CODE_01A69D

ADDR_01A69A:
	JSR.w SMW_SolidSpriteBlock_Entry2
CODE_01A69D:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ Branch if Flying Question Block or Key
	CMP.b #!Define_SMW_SpriteID_NorSpr080_Key
	BEQ.b CODE_01A6BB
	CMP.b #!Define_SMW_SpriteID_NorSpr083_LeftFlyingBlock
	BEQ.b ADDR_01A6B8
	CMP.b #!Define_SMW_SpriteID_NorSpr084_HorizontalFlyingBlock
	BEQ.b ADDR_01A6B8
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #$D0
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	BRA.b CODE_01A6BB

ADDR_01A6B8:
	JSR.w CODE_01A5D3
CODE_01A6BB:
	JSL.l SMW_SpawnContactEffectFromSide_Main
	LDA.b #$04
	JSL.l SMW_GivePoints_Main
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	ASL
	LDA.b #$10
	BCS.b CODE_01A6CE
	LDA.b #$F0
CODE_01A6CE:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	RTS

; X speeds given to sprites when kicked by a blue shelless Koopa. First byte
; is kicking right, second is left.
DATA_01A6D7:
	db $30,$D0

CODE_01A6D9:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b Return01A72D
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,y	; \ Branch if not on ground
	AND.b #$04
	BEQ.b Return01A72D
	LDA.w !RAM_SMW_NorSpr_PropertyBits1656,x	; \ Return if doesn't kick/hop into shells
	AND.b #!Define_SMW_NorSpr_1656Prop_HopInOrKickShells
	BEQ.b Return01A72D
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,y
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	BNE.b Return01A72D
if defined("Define_SMW_SA1")
	; SA-1 Pack: In the sprite/sprite interaction this lookup can happen with
	; a different value of x, easiest to just hijack.
	JSL.l X_LOW_REMAP0
else
	STZ.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_NorSpr_XPosLo,x
endif
	SEC
	SBC.w !RAM_SMW_NorSpr_XPosLo,y
	BMI.b CODE_01A702
	INC.b !RAM_SMW_Misc_ScratchRAM02
CODE_01A702:
	CLC
	ADC.b #$08
	CMP.b #$10
	BCC.b Return01A72D
	LDA.w !RAM_SMW_NorSpr_Table7E157C,x
	CMP.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b Return01A72D
if defined("Define_SMW_SA1")
	JSL.l SPRITE_NUM_REMAP3
else
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if not Blue Shelless
	CMP.b #!Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa
endif
	BNE.b HopIntoShell
	; Set to 60 to stop Blue Koopas from kicking shells
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	LDA.b #$23
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x
	TYA
	STA.w !RAM_SMW_NorSpr_Table7E160E,x
	RTS

PlayKickSfx:
	LDA.b #!Define_SMW_Sound1DF9_KickShell	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
Return01A72D:
	RTS

HopIntoShell:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,y	; \ Return if timer is set
	BNE.b Return01A777
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ Return if sprite >= #$0F
	CMP.b #!Define_SMW_SpriteID_NorSpr00F_Goomba
	BCS.b Return01A777
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,y	; \ Return if not on ground
	AND.b #$04
	BEQ.b Return01A777
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,y	; \ Branch if $15F6,y positive...
	BPL.b CODE_01A75D
	AND.b #$7F			; \ ...otherwise make it positive
	STA.w !RAM_SMW_NorSpr_Table7E15F6,y
	LDA.b #$E0			; \ Set upward speed
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	LDA.b #$20			; \ $1564,y = #$20
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,y
CODE_01A755:
	LDA.b #$20			; \ C2,x and 1558,x = #$20
	STA.b !RAM_SMW_NorSpr_Table7E00C2,x	; | (These are for the shell sprite)
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	RTS

CODE_01A75D:
	LDA.b #$E0			; \ Set upward speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	CMP.b #$01
	LDA.b #$18
	BCC.b CODE_01A76C
	LDA.b #$2C
CODE_01A76C:
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	TXA
	STA.w !RAM_SMW_NorSpr_Table7E1594,y
	TYA
	STA.w !RAM_SMW_NorSpr_Table7E1594,x
Return01A777:
	RTS

DATA_01A778:
	db $10,$F0

DATA_01A77A:
	db $00,$FF

CODE_01A77C:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa
	BNE.b CODE_01A7C2
	LDA.w !RAM_SMW_NorSpr_Table7E187B,y
	BNE.b CODE_01A7C2
	LDA.w !RAM_SMW_NorSpr_Table7E157C,x
	CMP.w !RAM_SMW_NorSpr_Table7E157C,y
	; Set to 80 to stop Blue Koopas from stopping shells
	BEQ.b CODE_01A7C2
	STY.b !RAM_SMW_Misc_ScratchRAM01
	LDY.w !RAM_SMW_NorSpr_Table7E1534,x
	BNE.b CODE_01A7C0
	STZ.w !RAM_SMW_NorSpr_Table7E1528,x
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	TAY
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w DATA_01A778,y
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w DATA_01A77A,y
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	TYA
	STA.w !RAM_SMW_NorSpr_Table7E160E,x
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_Table7E1534,x
CODE_01A7C0:
	PLA
	PLA
CODE_01A7C2:
if defined("Define_SMW_SA1")
	JML.l SPR_SPR_INTERACT_3
	db $E9,$75	; the tail of the LDY.w below, which the hijack leaves unreached
else
	LDX.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	LDY.w !RAM_SMW_NorSpr_CurrentSlotID	; Y = Sprite index
endif
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_CheckForPlayerToNormalSpriteCollision(Address)
namespace SMW_CheckForPlayerToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

; Subroutine that handles interaction between Mario and the sprite slot
; currently in X. If the "Don't use default interaction with player" tweaker
; bit in $167A,x is not set, the routine checks for contact between Mario
; and the sprite and handles the default interaction by jumping to the
; routine at $01A83B. Otherwise, it just checks for contact and returns with
; carry set if there's contact, and clear if there's not contact (note that
; when the sprite uses default interaction, the return carry isn't
; meaningful). Note that the routine will return "No contact" and skip
; interaction every other frame if the "Process interaction with player
; every frame" tweaker bit in $167A,x is not set, or if the sprite is
; horizontally offscreen during a frame in which it should be interacted
; with.
Main:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ Branch if "Process interaction every frame" is set
	AND.b #!Define_SMW_NorSpr_167AProp_ProcessPlayerInteractionEveryFrame
	BNE.b ProcessInteract
	TXA				; \ Otherwise, return every other frame
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	; Change from [1D A0 15] to [EA EA EA] to fix a glitch where sprites lose
	; their interaction with the player while touching the edge of the screen.
	; An example of this happens when a Banzai Bill's leftmost pixel goes past
	; the left edge of the screen.
	ORA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BEQ.b ProcessInteract
ReturnNoContact:
	CLC
	RTS

ProcessInteract:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$50
	CMP.b #$A0
	BCS.b ReturnNoContact		; No contact, return
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_Y
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CLC
	ADC.b #$60
	CMP.b #$C0
	BCS.b ReturnNoContact		; No contact, return
CODE_01A80F:
	LDA.b !RAM_SMW_Player_CurrentState	; \ If animation sequence activated...
	CMP.b #!Define_SMW_PlayerState01_PowerDown
	BCS.b ReturnNoContact		; / ...no contact, return
	LDA.b #$00			; \ Branch if bit 6 of $0D9B set?
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVS.b CODE_01A822
	LDA.w !RAM_SMW_Player_CurrentLayerPriority	; \ If Mario and Sprite not on same side of scenery...
	EOR.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
CODE_01A822:
	BNE.b ReturnNoContact2		; / ...no contact, return
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b ReturnNoContact2		; No contact, return
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x		;\ Note: !Define_SMW_NorSpr_167AProp_UseNonDefaultPlayerInteraction
	BPL.b DefaultInteractR					;/
	SEC				; Contact, return
	RTS

DATA_01A839:
	db $F0,$10

; Default sprite interaction routine. The sprite interaction routine calls
; it if $167A,x is positive/ bit 7 is not set. - $01A852 controls number
; where the star chain should stop. To be used with $01A856 - $01A856
; controls, how many points/ one-ups are added if the max limit of a star
; chain is reached. To be used with $01A852 $01A8D0 handles the code when
; you jump on a spiky enemy. Change $01A8D3 to $AD (LDA $xxxx) to disable
; spin jumping on spiky enemies. On contrary, change $01A8D3 to $80,$01 (BRA
; $01) to disable jumping with Yoshi on spiky enemies. To disable both,
; change $01A8D0 to $80,$04 (BRA $04). $01A91C handles the code when you
; jump on a non-spiky enemy. Change $01A91F to $AD (LDA $xxxx) to make spin
; jumps count as normal jumps. On contrary, change $01A91F to $80,$01 (BRA
; $01) to make jumps with Yoshi on enemies count as regular jumps. To make
; both count as regular jumps, change $01A91C to $80,$04 (BRA $04). Change
; $01A930 to $00 to enable the boost gain with spin jump kill. $01A940 is
; the sound effect to play when you kill an enemy with a spin jump/ jump
; with Yoshi. $01AA42 is the routine for carryable sprites. Change $01AA61
; to $AD (LDA $xxxx) to enable carrying more than one sprite at time even
; though you already have one.
DefaultInteractR:
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario doesn't have star
	BEQ.b CODE_01A87E
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ Branch if "Process interaction every frame" is set
	AND.b #!Define_SMW_NorSpr_167AProp_InvincibleToMostThings
	BNE.b CODE_01A87E
CODE_01A847:
	JSL.l SMW_SpawnContactEffectFromSide_Main
	INC.w !RAM_SMW_Player_StarKillCount
	LDA.w !RAM_SMW_Player_StarKillCount
	CMP.b #$08
	BCC.b CODE_01A85A
	LDA.b #$08
	STA.w !RAM_SMW_Player_StarKillCount
CODE_01A85A:
	JSL.l SMW_GivePoints_Main
	LDY.w !RAM_SMW_Player_StarKillCount
	CPY.b #$08
	BCS.b CODE_01A86B
	LDA.w SMW_StompSoundTable_Bank01-$01,y
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_01A86B:
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w DATA_01A839,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
ReturnNoContact2:
	CLC
	RTS

CODE_01A87E:
	STZ.w !RAM_SMW_Player_StarKillCount
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	BNE.b CODE_01A895
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus09_Stunned
	BNE.b CODE_01A897
	JSR.w CODE_01AA42
CODE_01A895:
	CLC
	RTS

CODE_01A897:
	LDA.b #$14
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM01
	ROL.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b !RAM_SMW_Player_CurrentYPosLo
	PHP
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	SBC.b #$00
	PLP
	SBC.b !RAM_SMW_Player_CurrentYPosHi
	BMI.b CODE_01A8E6
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_01A8C0
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,x	; \ TODO: Branch if Unknown Bit 11 is set
	AND.b #!Define_SMW_NorSpr_190FProp_CanBeJumpedOnWithUpwardYSpeed
	BNE.b CODE_01A8C0
	LDA.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped
	BEQ.b CODE_01A8E6
CODE_01A8C0:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01A8C9
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_01A8E6
CODE_01A8C9:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1656,x	; \ Branch if can be jumped on
	AND.b #!Define_SMW_NorSpr_1656Prop_SafeToJumpOn
	BNE.b CODE_01A91C
	LDA.w !RAM_SMW_Player_SpinJumpFlag
	; Change from 0D to AD to prevent Mario from being able to jump on spikey
	; enemies with the spin jump
	ORA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01A8E6
CODE_01A8D8:
	LDA.b #!Define_SMW_Sound1DF9_Contact
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	JSL.l SMW_BoostMarioSpeed_Main
	JSL.l SMW_SpawnContactEffectFromAbove_Main
	RTS

CODE_01A8E6:
	LDA.w !RAM_SMW_Player_SlidingOnGround
	BEQ.b CODE_01A8F9
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,x	; \ Branch if "Takes 5 fireballs to kill"...
	AND.b #!Define_SMW_NorSpr_190FProp_ImmuneToSliding	; | ...is set
	BNE.b CODE_01A8F9
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_PlayKickSfx
	JSR.w CODE_01A847
	RTS

CODE_01A8F9:
	LDA.w !RAM_SMW_Timer_PlayerHurt	; \ Return if Mario is invincible
	BNE.b Return01A91B
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b Return01A91B
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,x
	AND.b #!Define_SMW_NorSpr_1686Prop_DontChangeDirectionWhenTouched
	BNE.b CODE_01A911
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA
	STA.w !RAM_SMW_NorSpr_Table7E157C,x
CODE_01A911:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr053_ThrowBlock
	BEQ.b Return01A91B
	JSL.l SMW_DamagePlayer_Hurt
Return01A91B:
	RTS

CODE_01A91C:
	LDA.w !RAM_SMW_Player_SpinJumpFlag
	ORA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01A947
CODE_01A924:
	JSL.l SMW_SpawnContactEffectFromAbove_Main
	LDA.b #$F8
	STA.b !RAM_SMW_Player_YSpeed
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01A935
	JSL.l SMW_BoostMarioSpeed_Main
CODE_01A935:
	JSR.w SMW_NorSprStatus02_Dead_SetNorSprStatus04_Main
	JSL.l SMW_SpawnSpinJumpStars_Main
	JSR.w CODE_01AB46
	LDA.b #!Define_SMW_Sound1DF9_SpinJumpKill
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	JMP.w CODE_01A9F2

CODE_01A947:
	JSR.w CODE_01A8D8
	LDA.w !RAM_SMW_NorSpr_Table7E187B,x
	BEQ.b CODE_01A95D
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.b #$18
	CPY.b #$00
	BEQ.b CODE_01A95A
	LDA.b #$E8
CODE_01A95A:
	STA.b !RAM_SMW_Player_XSpeed
	RTS

CODE_01A95D:
	JSR.w CODE_01AB46
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,x
	AND.b #!Define_SMW_NorSpr_1686Prop_SpawnsNewSprite
	BEQ.b CODE_01A9BE
	CPY.b #!Define_SMW_SpriteID_NorSpr072_YellowCapeSuperKoopa
	BCC.b CODE_01A979
	PHX
	PHY
	JSL.l SpawnFeatherFromSuperKoopa
	PLY
	PLX
	LDA.b #$02
	BRA.b CODE_01A99B

CODE_01A979:
	CPY.b #!Define_SMW_SpriteID_NorSpr06E_DinoRhino
	BNE.b CODE_01A98A
	LDA.b #$02
	STA.b !RAM_SMW_NorSpr06F_DinoTorch_CurrentState,x
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr06F_DinoTorch_BreathFireTimer,x
	LDA.b #!Define_SMW_SpriteID_NorSpr06F_DinoTorch	;DINO TORCH SPRITE NUM
	BRA.b CODE_01A99B

CODE_01A98A:
	CPY.b #!Define_SMW_SpriteID_NorSpr03F_ParachuteGoomba
	BCC.b CODE_01A998
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	LDA.w SMW_GenericSpriteToSpawnTable_Main-$2E,y	; Hey, this label might be wrong!
	BRA.b CODE_01A99B

CODE_01A998:
	LDA.w SMW_GenericSpriteToSpawnTable_Main,y
CODE_01A99B:
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	AND.b #$0E
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	JSL.l SMW_InitializeNormalSpriteRAMTables_YXPPCCCTAndPropertyTables
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	AND.b #$F1
	ORA.b !RAM_SMW_Misc_ScratchRAM0F
	STA.w !RAM_SMW_NorSpr_Table7E15F6,x
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa
	BNE.b Return01A9BD
	INC.w !RAM_SMW_NorSpr_Table7E151C,x
Return01A9BD:
	RTS

CODE_01A9BE:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x			;\ Glitch: This code is buggy. It makes glitch graphics appear when landing on some sprites with a cape.
	SEC							;|
	SBC.b #!Define_SMW_SpriteID_NorSpr004_GreenKoopa	;|
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb		;|
	BCS.b CODE_01A9CC					;|
	LDA.w !RAM_SMW_Player_CapeFlyingPhase			;|
	BNE.b CODE_01A9D3					;/
CODE_01A9CC:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1656,x	; \ Branch if doesn't die when jumped on
	AND.b #!Define_SMW_NorSpr_1656Prop_DiesWhenJumpedOn
	BEQ.b CODE_01A9E2
CODE_01A9D3:
	LDA.b #!Define_SMW_NorSprStatus03_Smushed	; \ Sprite status = Smushed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr_SmushedSpriteDespawnTimer,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; \ Sprite Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x
	RTS

CODE_01A9E2:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x	; \ Branch if Tweaker bit...
	AND.b #!Define_SMW_NorSpr_1662Prop_FallWhenKilled	; | ..."Falls straight down when killed"...
	BEQ.b CODE_01AA01		; / ...is NOT set.
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Falling off screen
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; \ Sprite Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01A9F2:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Return if NOT Lakitu
	CMP.b #!Define_SMW_SpriteID_NorSpr01E_Lakitu
	BNE.b Return01AA00
	LDY.w !RAM_SMW_Sprites_LakituCloudSlotIndex
	LDA.b #$1F
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,y
Return01AA00:
	RTS

CODE_01AA01:
	LDY.w !RAM_SMW_NorSpr_CurrentStatus,x
	STZ.w !RAM_SMW_NorSpr_Table7E1626,x
	CPY.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b SetStunnedTimer
CODE_01AA0B:
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x
	BNE.b SetStunnedTimer
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	BRA.b SetAsStunned

SetStunnedTimer:
	LDA.b #$02
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	CPY.b #!Define_SMW_SpriteID_NorSpr00F_Goomba	; | Set stunnned timer with:
	BEQ.b CODE_01AA28
	CPY.b #!Define_SMW_SpriteID_NorSpr011_BuzzyBeetle	; | #$FF for Goomba, Buzzy Beetle, Mechakoopa, or Bob-omb...
	BEQ.b CODE_01AA28		; | #$02 for others
	CPY.b #!Define_SMW_SpriteID_NorSpr0A2_MechaKoopa
	BEQ.b CODE_01AA28
	CPY.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb
	BNE.b CODE_01AA2A
CODE_01AA28:
	LDA.b #$FF
CODE_01AA2A:
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
SetAsStunned:
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Status = stunned
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckForPlayerToNormalSpriteCollision(Address)
namespace SMW_CheckForPlayerToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

CODE_01AA42:
	LDA.w !RAM_SMW_Player_SpinJumpFlag
	ORA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01AA58
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_01AA58
	LDA.w !RAM_SMW_NorSpr_PropertyBits1656,x	; \ Branch if can't be jumped on
	AND.b #!Define_SMW_NorSpr_1656Prop_SafeToJumpOn
	BEQ.b CODE_01AA58
	JMP.w CODE_01A924

CODE_01AA58:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_IO_ControllerHold1
else
	LDA.b !RAM_SMW_IO_ControllerHold1
endif
	AND.b #!Joypad_X|(!Joypad_Y>>8)
	; Change from BEQ [F0] to BRA [80] and Mario will not be able to carry
	; items by holding X or Y.
	BEQ.b CODE_01AA74
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag1	; \ Branch if carrying an enemy...
	ORA.w !RAM_SMW_Player_RidingYoshiFlag	; | ...or on Yoshi
	BNE.b CODE_01AA74
	LDA.b #!Define_SMW_NorSprStatus0B_Carried	; \ Sprite status = Being carried
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	INC.w !RAM_SMW_Player_CarryingSomethingFlag1	; Set carrying enemy flag
	LDA.b #$08
	STA.w !RAM_SMW_Timer_DisplayPlayerPickUpPose
	RTS

CODE_01AA74:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if Key
	CMP.b #!Define_SMW_SpriteID_NorSpr080_Key
	BEQ.b CODE_01AAB7
	CMP.b #!Define_SMW_SpriteID_NorSpr03E_PSwitch	; \ Branch if P Switch
	BEQ.b CODE_01AAB2
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb	; \ Branch if Bobomb
	BEQ.b CODE_01AA97
	CMP.b #!Define_SMW_SpriteID_NorSpr02D_BabyYoshi	; \ Branch if Baby Yoshi
	BEQ.b CODE_01AA97
	CMP.b #!Define_SMW_SpriteID_NorSpr0A2_MechaKoopa	; \ Branch if MechaKoopa
	BEQ.b CODE_01AA97
	CMP.b #!Define_SMW_SpriteID_NorSpr00F_Goomba	; \ Branch if not Goomba
	BNE.b CODE_01AA94
	LDA.b #$F0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	BRA.b CODE_01AA97

CODE_01AA94:
	JSR.w CODE_01AB46
CODE_01AA97:
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_PlayKickSfx
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	STA.b !RAM_SMW_NorSpr_Table7E00C2,x
	LDA.b #!Define_SMW_NorSprStatus0A_Kicked	; \ Sprite status = Kicked
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w SMW_NorSprStatus0B_Carried_ShellXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	RTS

CODE_01AAB2:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	BNE.b Return01AB2C
CODE_01AAB7:
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Player_CurrentYPosLo
	CLC
	ADC.b #$08
	CMP.b #$20
	BCC.b CODE_01AB31
	BPL.b CODE_01AACD
	LDA.b #$10
	STA.b !RAM_SMW_Player_YSpeed
	RTS

CODE_01AACD:
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return01AB2C
	STZ.b !RAM_SMW_Player_YSpeed
	STZ.b !RAM_SMW_Player_InAirFlag
	INC.w !RAM_SMW_Misc_PlayerOnSolidSprite
	LDA.b #$1F
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01AAE1
	LDA.b #$2F
CODE_01AAE1:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr03E_PSwitch
	BNE.b Return01AB2C
	ASL.w !RAM_SMW_NorSpr_PropertyBits167A,x				;\ Note: !Define_SMW_NorSpr_167AProp_UseNonDefaultPlayerInteraction
	LSR.w !RAM_SMW_NorSpr_PropertyBits167A,x				;/
	LDA.b #!Define_SMW_Sound1DF9_ONOFFSwitch
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	LDA.w !RAM_SMW_Misc_MusicRegisterBackup
	; Change to [80 00] to not have star music override P-Switch music. Instead
	; which ever is pressed/collected recently will have priority.
	BMI.b CODE_01AB0C
	LDA.b #!Define_SMW_LevelMusic_DirectCoins
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
CODE_01AB0C:
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	LSR.w !RAM_SMW_NorSpr_Table7E15F6,x
	ASL.w !RAM_SMW_NorSpr_Table7E15F6,x
	LDY.w !RAM_SMW_NorSpr_Table7E151C,x
	LDA.b #$B0
	STA.w !RAM_SMW_Timer_BluePSwitch,y
	LDA.b #$20			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
	CPY.b #$01
	BNE.b Return01AB2C
	; Change to EA EA EA EA to prevent on screen sprites from turning into
	; silver coins when the silver POW is active (USE WITH $02A9A1)
	JSL.l TurnSpritesIntoSilverCoins
Return01AB2C:
	RTS

DATA_01AB2D:
	dw $0001,$FFFF

; Code that pushes the player out of solid carryable sprites, such as keys
; and springboards. Increments/decrements $94 (player x position).
CODE_01AB31:
	STZ.b !RAM_SMW_Player_XSpeed
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w DATA_01AB2D,y
	STA.b !RAM_SMW_Player_XPosLo
	SEP.b #$20			; A->8
	RTS

CODE_01AB46:
	PHY
	LDA.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped
	CLC
	ADC.w !RAM_SMW_NorSpr_Table7E1626,x
	INC.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped
	TAY
	INY
	CPY.b #$08
	; Change to [80] to give enemies (inc. goomba) the SMAS stomp sound.
	BCS.b CODE_01AB5D
	LDA.w SMW_StompSoundTable_Bank01-$01,y
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_01AB5D:
	TYA
	CMP.b #$08
	BCC.b CODE_01AB64
	LDA.b #$08
CODE_01AB64:
	JSL.l SMW_GivePoints_Main
	PLY
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ChangeNormalSpriteDirection(Address)
namespace SMW_ChangeNormalSpriteDirection
%InsertMacroAtXPosition(<Address>)

CheckIfTouchingWall:
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; \ If touching an object in the direction
	INC				; | that the sprite is moving...
	AND.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$03
	BEQ.b Return019097
	JSR.w Main			; | ...flip direction
Return019097:
	RTS

Main:
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x	; \ Return if turning timer is set
	BNE.b Return0190B1
	LDA.b #$08			; \ Set turning timer
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
FlipXSpeedAndDirection:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	; \ Invert speed
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; \ Flip sprite direction
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
Return0190B1:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UnusedJSLTo_NorSpr09A_SumoBro_Status08_Bank02(Address)
namespace SMW_UnusedJSLTo_NorSpr09A_SumoBro_Status08_Bank02
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l SMW_NorSpr09A_SumoBro_Status08_Bank02	; Unused call to main Sumo Brother routine
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DrawWingTiles(Address)
namespace SMW_DrawWingTiles
%InsertMacroAtXPosition(<Address>)

XDispLo:
	db $FF,$F7,$09,$09

XDispHi:
	db $FF,$FF,$00,$00

YDisp:
	db $FC,$F4,$FC,$F4

; Sprite tilemap: Paratroopa Wings
Tiles:
	db $5D,$C6,$5D,$C6

; Palette/GFX page/Priority/Flip of Paratroopa Wing tiles
Prop:
	db $46,$46,$06,$06

; Size of Paratroopa Wing tiles
TileSize:
	db $00,$02,$00,$02

ParaKoopaEntry:
	LDY.b #$00			; \ If not on ground, $02 = animation frame (00 or 01)
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor	; | else, $02 = 0
	BNE.b CODE_019E35
	LDA.w !RAM_SMW_NorSpr_Table7E1602,x
	AND.b #$01
	TAY
CODE_019E35:
	STY.b !RAM_SMW_Misc_ScratchRAM02
CODE_019E37:
	LDA.w !RAM_SMW_NorSpr_YOffscreenFlag,x	; \ Return if offscreen vertically
	BNE.b Return019E94
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $00 = X position low
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	; \ $04 = X position high
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $01 = Y position low
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = index to OAM
	PHX
	LDA.w !RAM_SMW_NorSpr_Table7E157C,x	; \ X = index into tables
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; \ Store X position (relative to screen)
	CLC
	ADC.w XDispLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	ADC.w XDispHi,x
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLA				; \ Return if off screen horizontally
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b CODE_019E93
	LDA.b !RAM_SMW_Misc_ScratchRAM01	; \ Store Y position (relative to screen)
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x			; \ Store tile
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority	; \ Store tile properties
	ORA.w Prop,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.w TileSize,x		; \ Store tile size
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
CODE_019E93:
	PLX
Return019E94:
	RTS

; Subroutine that draws wings for 16x16 sprites. It uses $1570,x to decide
; if to draw open or closed wings (increasing it once per frame will result
; in the normal wings animation speed). If used in a custom sprite, the data
; bank needs to be set to $01 (see example code).
Main:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	SEC
	SBC.b #$02
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	PHA
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	LDA.w !RAM_SMW_NorSpr_Table7E157C,x
	PHA
	STZ.w !RAM_SMW_NorSpr_Table7E157C,x
	LDA.w !RAM_SMW_NorSpr_Table7E1570,x
	LSR
	LSR
	LSR
	AND.b #$01
	TAY
	JSR.w CODE_019E35
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	INC.w !RAM_SMW_NorSpr_Table7E157C,x
	JSR.w CODE_019E37
	PLA
	STA.w !RAM_SMW_NorSpr_Table7E157C,x
	PLA
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	PLA
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MakeNormalSpriteReboundOffWall(Address)
namespace SMW_MakeNormalSpriteReboundOffWall
%InsertMacroAtXPosition(<Address>)

; Block interaction of carryable and kicked sprite for horizontal
; interaction. This allows sprites to interact with bounce blocks. Note that
; for the stunned state ($14C8 = $09), this interaction is skipped for Koopa
; shells. $01999F [$01]: Which sound effect to play when a sprite touches a
; solid block. $0199B2 [$14]: The range of the left side to check whether a
; sprite is on-screen. $0199B4 [$1C]: The range of the right side to check
; whether a sprite is on-screen (must be added with the left range). $0199CE
; [$05]: How long to disable interaction with capes and bounce sprites.
; $0199D5 [$53]: Which sprite breaks at wall contact.
Main:
	LDA.b #!Define_SMW_Sound1DF9_HitHead	;>hit head SFX
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	JSR.w SMW_ChangeNormalSpriteDirection_FlipXSpeedAndDirection	;>Flip direction without timer.
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x	;\If offscreen, skip over
	BNE.b CODE_0199D2		;/
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\SpriteXPos - screenxpos = onscreen x positon
	SEC				;|(all low byte)
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;/
	CLC				;\Check if its position is past #$1C?
	ADC.b #$14			;|
	CMP.b #$1C			;/
	BCC.b CODE_0199D2		;>Skip following code
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;>Blocked status
	AND.b #$40			;>#%0X000000
	ASL				;>#%X0000000
	ASL				;>X in carry
	ROL				;>X wraps to bit 0: #%0000000X
	AND.b #$01			;>clear all but bit 0
	STA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo	;>Write to layer processor
	LDY.b #$00			;>Y = #$00
	LDA.w !RAM_SMW_Blocks_CopyOfCurrentlyProcessedMap16TileLo2	;>Map16 holder
	JSL.l SMW_CheckIfBlockWasHit_Main	;>Interaction with solid blocks
	LDA.b #$05			;\Disable contact with cape.
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1FE2,x	;/
CODE_0199D2:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ If Throw Block, break it
	CMP.b #!Define_SMW_SpriteID_NorSpr053_ThrowBlock
	BNE.b Return0199DB
	JSR.w SMW_BreakThrowBlock_Main
Return0199DB:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BreakThrowBlock(Address)
namespace SMW_BreakThrowBlock
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x	; Free up sprite slot
	LDY.b #$FF			; Is this for the shatter routine??
MontyMoleEntry:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01	; \ Return if off screen
	BNE.b Return019A03
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Store Y position in $9A-$9B
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ Store X position in $98-$99
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Blocks_YPosHi
	PHB				; \ Shatter the brick
	LDA.b #SMW_SpawnBrickPieces_Main>>16
	PHA
	PLB
	TYA
	JSL.l SMW_SpawnBrickPieces_Main
	PLB
Return019A03:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StunnedShellGFXRt(Address)
namespace SMW_StunnedShellGFXRt
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$06
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	BNE.b CODE_01980F
	LDA.b #$08
CODE_01980F:
	STA.w !RAM_SMW_NorSpr_Table7E1602,x
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	PHA
	BEQ.b CODE_01981B
	CLC
	ADC.b #$08
CODE_01981B:
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	PLA
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	LDA.w !RAM_SMW_Overworld_LevelTileSettings+!Define_SMW_LevelID_ChangeSP2GFX
	BMI.b Return0198A6
	LDA.w !RAM_SMW_NorSpr_Table7E1602,x
	CMP.b #$06
	BNE.b Return0198A6
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	BNE.b CODE_019842
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	BEQ.b Return0198A6
	CMP.b #$30
	BCS.b CODE_01984D
CODE_019842:
	LSR
	LDA.w SMW_OAMBuffer[$42].XDisp,y
	ADC.b #$00
	BCS.b CODE_01984D
	STA.w SMW_OAMBuffer[$42].XDisp,y
CODE_01984D:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch away if a Buzzy Beetle
	CMP.b #!Define_SMW_SpriteID_NorSpr011_BuzzyBeetle
	; Change to #$80 to prevent koopas eyes blinking while inside the shell.
	BEQ.b Return0198A6
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01
	BNE.b Return0198A6
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	ASL
	LDA.b #$08
	BCC.b CODE_019862
	LDA.b #$00
CODE_019862:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w SMW_OAMBuffer[$42].XDisp,y
	CLC
	ADC.b #$02
	STA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$04
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.w SMW_OAMBuffer[$42].YDisp,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	PHY
	LDY.b #$64
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$F8
	BNE.b CODE_01988A
	LDY.b #$4D
CODE_01988A:
	TYA
	PLY
	STA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
Return0198A6:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessStunnedNormalSprite(Address)
namespace SMW_ProcessStunnedNormalSprite
%InsertMacroAtXPosition(<Address>)

StunnedGoomba:
	LDA.b !RAM_SMW_Counter_LocalFrames	; \ A = frame counter / 4
	LSR				;  |  (RAM $14 stops counting frames
	LSR				; /    while sprites are frozen.)
	LDY.w !RAM_SMW_NorSpr00F_Goomba_StunTimer,x	; \ If timer < 48,
	CPY.b #$30			;  |  then A = frame counter / 8
	BCC.b .CODE_01A13B		;  |
	LSR				; /
.CODE_01A13B:
	AND.b #$01			; \ Sprite image = 0 or 1,
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x	; /   alternating after 4 or 8 frames
	CPY.b #$08			; \ If timer == 8, and Goomba is on the
	BNE.b .CODE_01A14D		;  |ground (not in midair), then set
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor	;  |vertical speed of Goomba to -40.
	BEQ.b .CODE_01A14D		;  |(Exactly 8 turns before waking, the
	LDA.b #$D8			;  | Goomba hops into the air!)
	STA.b !RAM_SMW_NorSpr_YSpeed,x	; /
.CODE_01A14D:
	LDA.b #$80
	JMP.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry2	; TODO, seems to affect OAM

StunnedMechaKoopa:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	; \ Push low byte of X-position
	PHA				; /   of layer 1 of level
	LDA.w !RAM_SMW_NorSpr0A2_MechaKoopa_StunTimer,x	; \ Skip ahead if timer >= 48
	CMP.b #$30			;  |
	BCS.b .CODE_01A162		; /
	AND.b #$01			; \ If timer is odd, then flip bit 1
	EOR.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;  |  of X-position of layer 1
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	; /
.CODE_01A162:
	JSL.l SMW_NorSpr0A2_MechaKoopa_Status08_GFXRt	; TODO
	PLA				; \ Pull orignal low byte of X-position
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	; /   of layer 1 of level
.CODE_01A169:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ If sprite status == Carried,
	CMP.b #!Define_SMW_NorSprStatus0B_Carried
	BNE.b .Return01A177
	LDA.b !RAM_SMW_Player_FacingDirection	; | Sprite direction = Opposite direction of Mario
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
.Return01A177:
	RTS

StunnedFish:
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	ORA.b #$80
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	RTS

Main:
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ Branch if sprite changes into a shell
	AND.b #!Define_SMW_NorSpr_167AProp_DontBecomeShellWhenStunned
	BEQ.b CODE_01A1D0
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; A = sprite number of this sprite
	CMP.b #!Define_SMW_SpriteID_NorSpr0A2_MechaKoopa	; \ Branch if A == $A2,
	BEQ.b StunnedMechaKoopa		; /   Mecha Koopa
	CMP.b #!Define_SMW_SpriteID_NorSpr015_HorizontalCheepCheep	; \ Branch if A == $15,
	BEQ.b StunnedFish		; /   horizontal Cheep-Cheep
	CMP.b #!Define_SMW_SpriteID_NorSpr016_VerticalCheepCheep	; \ Branch if A == $16,
	BEQ.b StunnedFish		; /   vertical Cheep-Cheep
	CMP.b #!Define_SMW_SpriteID_NorSpr00F_Goomba	; \ Branch if A == $0F,
	BEQ.b StunnedGoomba		; /   Goomba
	CMP.b #!Define_SMW_SpriteID_NorSpr053_ThrowBlock	; \ Branch if A == $53,
	BEQ.b StunnedThrowBlock		; /   grab block
	CMP.b #!Define_SMW_SpriteID_NorSpr02C_YoshiEgg	; \ Branch if A == $2C,
	BEQ.b StunnedYoshiEgg		; /   Yoshi egg
	CMP.b #!Define_SMW_SpriteID_NorSpr080_Key	; \ Branch if A == $80,
	BEQ.b StunnedKey		; /   key
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon	; \ Branch if A == $7D,
	BEQ.b Return01A1D3		; /   P-balloon
	CMP.b #!Define_SMW_SpriteID_NorSpr03E_PSwitch	; \ Branch if A == $3E,
	BEQ.b StunnedPSwitch		; /   P-switch
	CMP.b #!Define_SMW_SpriteID_NorSpr02F_PortableSpringboard	; \ Branch if A == $2F,
	BEQ.b StunnedSpringBoard	; /   portable springboard
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb	; \ Branch if A == $0D,
	BEQ.b StunnedBobOmb		; /   Bob-omb
	CMP.b #!Define_SMW_SpriteID_NorSpr02D_BabyYoshi	; \ Branch if A == $2D,
	BEQ.b StunnedBabyYoshi		; /   baby Yoshi
	CMP.b #!Define_SMW_SpriteID_NorSpr085_Unused
	BNE.b CODE_01A1D0
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1		;\ Note: Code for NorSpr085_Unused
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x			;|
	LDA.b #$47						;|
	STA.w SMW_OAMBuffer[$40].Tile,y				;|
	RTS							;/

CODE_01A1D0:
	JSR.w SMW_StunnedShellGFXRt_Main	; Handle all other sprites
Return01A1D3:
	RTS

StunnedThrowBlock:
	LDA.w !RAM_SMW_NorSpr053_ThrowBlock_DespawnTimer,x	; \ If timer < 64,
	CMP.b #$40			;  |  and if timer is odd,
	BCS.b .CODE_01A1DE		;  |  then skip the change of palette.
	LSR				;  |
	BCS.b StunnedYoshiEgg		; /
.CODE_01A1DE:
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	; Changing [1A 1A 29 0F] to [EA EA EA EA] will disable the throw block
	; sprites flashing.
	INC
	INC
	AND.b #$0F
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
StunnedYoshiEgg:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	RTS

StunnedBobOmb:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDA.b #$CA
	BRA.b CODE_01A222

StunnedKey:
	JSR.w StunnedMechaKoopa_CODE_01A169
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDA.b #$EC
	BRA.b CODE_01A222

StunnedPSwitch:
	LDY.w !RAM_SMW_NorSpr03E_PSwitch_DespawnTimer,x
	BEQ.b .CODE_01A218
	CPY.b #$01
	BNE.b .CODE_01A209
	JMP.w SMW_NorSprStatus02_Dead_SetNorSprStatus04_Main

.CODE_01A209:
	JSR.w SMW_GenericSmushedSpriteGFXRt_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$40].Prop,y
	AND.b #$FE
	STA.w SMW_OAMBuffer[$40].Prop,y
	RTS

.CODE_01A218:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDA.b #$42
CODE_01A222:
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	STA.w SMW_OAMBuffer[$40].Tile,y
	RTS

StunnedSpringBoard:
	JMP.w SMW_NorSpr02F_PortableSpringboard_Status08_CODE_01E6F0

StunnedBabyYoshi:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b .CODE_01A27B
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM09
	JSL.l SMW_CheckForBerryTileCollisionWithYoshiTongue_Main
	JSL.l SMW_CheckIfBabyYoshiCanEatNormalSprite_Main
	LDA.w !RAM_SMW_NorSpr02D_BabyYoshi_SwallowAnimationTimer,x
	BNE.b .CODE_01A27E
	DEC
	STA.w !RAM_SMW_NorSpr02D_BabyYoshi_SlotOfSpriteBeingEaten,x
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Branch if sprite status != Stunned
	CMP.b #!Define_SMW_NorSprStatus09_Stunned
	BNE.b .CODE_01A26D
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b .CODE_01A26D
	LDA.b #$F0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
.CODE_01A26D:
	LDY.b #$00
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$18
	BNE.b .CODE_01A277
	LDY.b #$03
.CODE_01A277:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
.CODE_01A27B:
	JMP.w .CODE_01A34F

.CODE_01A27E:
	STZ.w !RAM_SMW_NorSpr_OAMIndex,x
	CMP.b #$20
	BEQ.b .CODE_01A288
	JMP.w .CODE_01A30A

.CODE_01A288:
	LDY.w !RAM_SMW_NorSpr02D_BabyYoshi_SlotOfSpriteBeingEaten,x
	LDA.b #!Define_SMW_NorSprStatus00_EmptySlot	; \ Clear sprite status
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_Sound1DF9_YoshiGulp
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	; Change to [$80,$1E] to make Baby Yoshi instantly grow when eating
	; something, regardless if it's a powerup or not. Change to [$80,$5D] to
	; make Baby Yoshi never grow instantly when eating something, even if it's
	; a powerup. It will count as one sprite eaten instead. If changing this,
	; you also need to apply the hex edit at $03C03C for it to work properly.
	LDA.w !RAM_SMW_NorSpr02D_BabyYoshi_SlotOfSpriteBeingEaten,y
	BNE.b .CODE_01A2F4
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ Branch if not Changing power up
	CMP.b #!Define_SMW_SpriteID_NorSpr081_ChangingItem
	BNE.b .CODE_01A2AD
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w SMW_NorSprXXX_PowerUps_Status08_ChangingItemSprite,y
.CODE_01A2AD:
	CMP.b #!Define_SMW_SpriteID_NorSpr074_Mushroom
	BCC.b .CODE_01A2F4
	CMP.b #!Define_SMW_SpriteID_NorSpr078_1upMushroom
	BCS.b .CODE_01A2F4
.CODE_01A2B5:
	STZ.w !RAM_SMW_Yoshi_SwallowTimer
	STZ.w !RAM_SMW_Yoshi_YoshiHasWings	; No Yoshi wings
	LDA.b #!Define_SMW_SpriteID_NorSpr035_Yoshi	; \ Sprite = Yoshi
	STA.w !RAM_SMW_NorSpr_SpriteID,x
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_Sound1DFC_MountYoshi
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SBC.b #$10
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,x
	PHA				; \ Reset sprite tables
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

.CODE_01A2F4:
	INC.w !RAM_SMW_NorSpr02D_BabyYoshi_SpritesEatenCounter,x
	LDA.w !RAM_SMW_NorSpr02D_BabyYoshi_SpritesEatenCounter,x
	CMP.b #$05
	BNE.b .CODE_01A300
	BRA.b .CODE_01A2B5

; Change to $80,$02 to disable getting a coin when Baby Yoshi eats
; something.
.CODE_01A300:
	JSL.l SMW_GiveCoins_OneCoin
	LDA.b #$01
	JSL.l SMW_GivePoints_Main
.CODE_01A30A:
	LDA.w !RAM_SMW_NorSpr02D_BabyYoshi_SwallowAnimationTimer,x
	LSR
	LSR
	LSR
	TAY
	LDA.w .DATA_01A35A,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr02D_BabyYoshi_SwallowAnimationTimer,x
	CMP.b #$20
	BCC.b .CODE_01A34F
	SBC.b #$10
	LSR
	LSR
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	BEQ.b .CODE_01A32E
	EOR.b #$FF
	INC
	DEC.b !RAM_SMW_Misc_ScratchRAM01
.CODE_01A32E:
	LDY.w !RAM_SMW_NorSpr02D_BabyYoshi_SlotOfSpriteBeingEaten,x
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b #$02
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
.CODE_01A34F:
	JSR.w StunnedMechaKoopa_CODE_01A169
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	JSL.l SMW_SetBabyYoshiDynamicGraphicsPointer_Main
	RTS

.DATA_01A35A:
	db $00,$03,$02,$02,$01,$01,$01
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetFacingDirectionBasedOnSpeed(Address)
namespace SMW_SetFacingDirectionBasedOnSpeed
%InsertMacroAtXPosition(<Address>)

Bank01:
	LDA.b #$00			; \ Subroutine: Set direction from speed value
	LDY.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b Return019A21
	BPL.b CODE_019A1E
	INC
CODE_019A1E:
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
Return019A21:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_GenericSpriteToSpawnTable(Address)
namespace SMW_GenericSpriteToSpawnTable
%InsertMacroAtXPosition(<Address>)

Main:
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr001_RedNakedKoopa
	db !Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa
	db !Define_SMW_SpriteID_NorSpr003_YellowNakedKoopa
	db !Define_SMW_SpriteID_NorSpr004_GreenKoopa
	db !Define_SMW_SpriteID_NorSpr005_RedKoopa
	db !Define_SMW_SpriteID_NorSpr006_BlueKoopa
	db !Define_SMW_SpriteID_NorSpr007_YellowKoopa
	; Enemy spawned from stomping horizontal green winged koopas
	db !Define_SMW_SpriteID_NorSpr004_GreenKoopa
	; Enemy spawned from stomping bouncing green winged koopas
	db !Define_SMW_SpriteID_NorSpr004_GreenKoopa
	; Enemy spawned from stomping vertical red winged koopas
	db !Define_SMW_SpriteID_NorSpr005_RedKoopa
	; Enemy spawned from stomping horizontal red winged koopas
	db !Define_SMW_SpriteID_NorSpr005_RedKoopa
	; Enemy spawned from stomping yellow winged koopas
	db !Define_SMW_SpriteID_NorSpr007_YellowKoopa
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr00F_Goomba
	; Enemy spawned from stomping winged goombas
	db !Define_SMW_SpriteID_NorSpr00F_Goomba
	; Sprite spawned from Para-Goomba
	db !Define_SMW_SpriteID_NorSpr00F_Goomba
	; Sprite spawned from Para-Bomb
	db !Define_SMW_SpriteID_NorSpr00D_BobOmb
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_StompSoundTable(Address)
namespace SMW_StompSoundTable
%InsertMacroAtXPosition(<Address>)

Bank01:
	%INLINEDATATABLE_SMW_StompSoundTable()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MakeStunnedSpriteBounceOrSlowDownOnGround(Address)
namespace SMW_MakeStunnedSpriteBounceOrSlowDownOnGround
%InsertMacroAtXPosition(<Address>)

DATA_0197AF:
	db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
	db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
	db $E8,$E8,$E8

	db $00,$00,$00,$00,$FE,$FC,$F8,$EC
	db $EC,$EC,$E8,$E4,$E0,$DC,$D8,$D4
	db $D0,$CC,$C8

Main:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	PHP
	BPL.b CODE_0197DD
	JSR.w SMW_UnnecessaryInvertARt_Bank01
CODE_0197DD:
	LSR
	PLP
	BPL.b CODE_0197E4
	JSR.w SMW_UnnecessaryInvertARt_Bank01
CODE_0197E4:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	PHA
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	PLA
	LSR
	LSR
	TAY
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ If Goomba, Y += #$13
	CMP.b #!Define_SMW_SpriteID_NorSpr00F_Goomba
	BNE.b CODE_0197FB
	TYA
	CLC
	ADC.b #$13
	TAY
CODE_0197FB:
	LDA.w DATA_0197AF,y
	LDY.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	BMI.b Return019805
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return019805:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckForTiltingPlatformCollision(Address)
namespace SMW_CheckForTiltingPlatformCollision
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetHi
	ORA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetHi
	BNE.b NoCollision
	JSR.w CODE_01CCC7
	JSR.w SMW_GetSineAndCosineOfTiltingPlatform_Main
	JSR.w SMW_CalculateCircleCoordinatesForTiltingPlaform_Main
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileYPosLo
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileXPosLo
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	LDA.w !RAM_SMW_Misc_IggyLarryPlatformInteraction,y
	CMP.b #$15
	RTL

NoCollision:
	CLC
	RTL

; Mode 7 rotation preparation routine. First JSR to this, then to $01CB20
; and finally to $01CB53.
CODE_01CCC7:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_M7CenterXPosLo
	STA.w !RAM_SMW_Misc_RotatingObjectCenterXPosLo
	LDA.b !RAM_SMW_Mirror_M7CenterYPosLo
	STA.w !RAM_SMW_Misc_RotatingObjectCenterYPosLo
	LDA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetLo
	SEC
	SBC.w !RAM_SMW_Misc_RotatingObjectCenterXPosLo
	STA.w !RAM_SMW_Misc_RotatingObjectXRadiusLo
	LDA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetLo
	SEC
	SBC.w !RAM_SMW_Misc_RotatingObjectCenterYPosLo
	STA.w !RAM_SMW_Misc_RotatingObjectYRadiusLo
	SEP.b #$20			; A->8
	RTS

Return01CCEA:
	RTS ; Unused

Return01CCEB:
	RTS ; Unused
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_CalculateCircleCoordinatesForTiltingPlaform(Address)
namespace SMW_CalculateCircleCoordinatesForTiltingPlaform
%InsertMacroAtXPosition(<Address>)

; The game's global rotation routine. First you can JSR to either $01CACB
; for sprite rotation or to $01CCC7 for Mode 7 rotation (this step seems to
; be optional). Next you JSR to $01CB20 to prepare the rotation and finally
; you JSR to this.
Main:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformCosineLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Misc_RotatingObjectXRadiusLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	JSR.w CODE_01CC28
	LDA.w !RAM_SMW_Sprites_BrownRoatingPlatformAngleSign2
	LSR
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BCC.b CODE_01CB72
	EOR.w #$FFFF
	INC
CODE_01CB72:
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	BCC.b CODE_01CB7C
	EOR.w #$FFFF
	INC
CODE_01CB7C:
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformSineLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Misc_RotatingObjectYRadiusLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	JSR.w CODE_01CC28
	LDA.w !RAM_SMW_Sprites_BrownRoatingPlatformAngleSign1
	LSR
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BCC.b CODE_01CB9B
	EOR.w #$FFFF
	INC
CODE_01CB9B:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	BCC.b CODE_01CBA5
	EOR.w #$FFFF
	INC
CODE_01CBA5:
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	ADC.b !RAM_SMW_Misc_ScratchRAM0A
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	CLC
	ADC.w !RAM_SMW_Misc_RotatingObjectCenterXPosLo
	STA.w !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileXPosLo
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformCosineLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Misc_RotatingObjectYRadiusLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	JSR.w CODE_01CC28
	LDA.w !RAM_SMW_Sprites_BrownRoatingPlatformAngleSign2
	LSR
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BCC.b CODE_01CBDA
	EOR.w #$FFFF
	INC
CODE_01CBDA:
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	BCC.b CODE_01CBE4
	EOR.w #$FFFF
	INC
CODE_01CBE4:
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformSineLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Misc_RotatingObjectXRadiusLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20			; A->8
	JSR.w CODE_01CC28
	LDA.w !RAM_SMW_Sprites_BrownRoatingPlatformAngleSign1
	LSR
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BCC.b CODE_01CC03
	EOR.w #$FFFF
	INC
CODE_01CC03:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	BCC.b CODE_01CC0D
	EOR.w #$FFFF
	INC
CODE_01CC0D:
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	SBC.b !RAM_SMW_Misc_ScratchRAM0A
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w !RAM_SMW_Misc_RotatingObjectCenterYPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM05
	STA.w !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileYPosLo
	SEP.b #$20			; A->8
	RTS

CODE_01CC28:
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/01CC28.asm"
namespace SMW_CalculateCircleCoordinatesForTiltingPlaform
else
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !REGISTER_Multiplier	; Multplier B
	JSR.w SMW_WasteTime_Main
	LDA.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !REGISTER_Multiplier	; Multplier B
	JSR.w SMW_WasteTime_Main
	LDA.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM05
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !REGISTER_Multiplier	; Multplier B
	JSR.w SMW_WasteTime_Main
	LDA.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM05
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	ADC.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !REGISTER_Multiplier	; Multplier B
	JSR.w SMW_WasteTime_Main
	LDA.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM07
	RTS
endif
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_GetSineAndCosineOfTiltingPlatform(Address)
namespace SMW_GetSineAndCosineOfTiltingPlatform
%InsertMacroAtXPosition(<Address>)

; Routine for preparing the game's global rotation routine. First you can
; JSR to either $01CACB for sprite rotation or to $01CCC7 for Mode 7
; rotation (this step seems to be optional). Next you JSR to this to prepare
; the rotation and finally you JSR to $01CB53.
Main:
	LDA.b !RAM_SMW_Misc_M7RotationHi
	STA.w !RAM_SMW_Sprites_BrownRoatingPlatformAngleSign1
	PHX
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Misc_M7RotationLo
	ASL
	AND.w #$01FF
	TAX
	LDA.l SMW_CircleCoordinates_Main,x
	STA.w !RAM_SMW_Sprites_BrownRotatingPlatformSineLo
	LDA.b !RAM_SMW_Misc_M7RotationLo
	CLC
	ADC.w #$0080
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	AND.w #$01FF
	TAX
	LDA.l SMW_CircleCoordinates_Main,x
	STA.w !RAM_SMW_Sprites_BrownRotatingPlatformCosineLo
	SEP.b #$30			; AXY->8
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_Sprites_BrownRoatingPlatformAngleSign2
	PLX
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_GenericNormalSpriteAccelerationTable(Address)
namespace SMW_GenericNormalSpriteAccelerationTable
%InsertMacroAtXPosition(<Address>)

Main:
	db $01,$FF
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_GenericEnemies_Status01(Address)
namespace SMW_NorSprXXX_GenericEnemies_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	AND.b #$10			;|ypos dertermines how high
	STA.w !RAM_SMW_NorSprXXX_GenericEnemies_BounceHeight,x
StandardSpritesInit:
	JSL.l SMW_GetRand_Main
	STA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x	; make that it's frame
MakeSpriteFacePlayer:
.Main:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X	;\
	TYA				;| face mario
	STA.w !RAM_SMW_NorSpr_FacingDirection,x	;/
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_Main, SMW_NorSpr009_BouncingGreenParaKoopa_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr000_GreenNakedKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr001_RedNakedKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr002_BlueNakedKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr003_YellowNakedKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr004_GreenKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr005_RedKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr006_BlueKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr007_YellowKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr008_LeftFlyingGreenParaKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr00A_VerticalRedParaKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr00B_HorizontalRedParaKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr00C_YellowParaKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr00F_Goomba_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr010_ParaGoomba_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr011_BuzzyBeetle_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr013_Spiny_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr014_SpinyEgg_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_StandardSpritesInit, SMW_NorSpr01D_HoppingFlame_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_Return, SMW_NorSpr020_Magic_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_Return, SMW_NorSpr079_VineHead_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_Return, SMW_NorSpr07A_Fireworks_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr021_MovingCoin_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr030_ThrowingDryBones_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr031_BonyBeetle_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr032_LedgeDryBones_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr051_Ninji_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr090_GreenGasBubble_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr0AB_Rex_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr0B4_NonLineGuideGrinder_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr0BF_MegaMole_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr0C2_Blurp_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr0C3_PorcuPuffer_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer, SMW_NorSpr0C5_BigBooBoss_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSprXXX_GenericEnemies_Status08(Address)
namespace SMW_NorSprXXX_GenericEnemies_Status08
%InsertMacroAtXPosition(<Address>)

; Subroutine that makes Yellow Koopas jump over shells. $0188E5 is the Y
; speed they get when jumping ($C0).
JumpOverKickedObject:
	TXA				; \ Process every 4 frames
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b Return0188AB
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02	; \ Loop over sprites:
JumpLoopStart:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked	; | If sprite status = kicked, try to jump it
	BEQ.b HandleJumpOver
JumpLoopNext:
	DEY
	BPL.b JumpLoopStart
Return0188AB:
	RTS

HandleJumpOver:
	LDA.w !RAM_SMW_NorSpr_XPosLo,y	;\Y is the index to whatever shell is incoming. This is the "Jump over shell" thing the yellow koopa does.
	SEC				;|
	SBC.b #$1A			;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;|
	LDA.w !RAM_SMW_NorSpr_XPosHi,y	;|
	SBC.b #$00			;|
	STA.b !RAM_SMW_Misc_ScratchRAM08	;|
	LDA.b #$44			;|
	STA.b !RAM_SMW_Misc_ScratchRAM02	;|now the position of the shell can be easily accessed
	LDA.w !RAM_SMW_NorSpr_YPosLo,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM01	;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM09	;|
	LDA.b #$10			;|
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b JumpLoopNext		; If not close to shell, go back to main loop
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor	; \ If sprite not on ground, go back to main loop
	BEQ.b JumpLoopNext
	LDA.w !RAM_SMW_NorSpr_FacingDirection,y	; \ If sprite not facing shell, don't jump
	CMP.w !RAM_SMW_NorSpr_FacingDirection,x
	BEQ.b Return0188EB
	LDA.b #$C0			; \ Finally set jump speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x	; get rid of the jump timer
Return0188EB:
	RTS

; Standard X speeds for sprites 00-13. The first two bytes are used when the
; "move faster" bit at $0188F0 is clear for the sprite, while the second two
; are used when it's set.
Spr0to13SpeedX:
	db $08,$F8,$0C,$F4

; Various properties for sprites 00-13. Format: ak--jfls. a = animate twice
; as fast in air k = use 32x16 tilemap (also draws wings on sprites 08+) --
; = unknown/unused j = jump over thrown shells f = follow Mario l = stay on
; ledges s = move faster (use $0188EE for X speeds instead of $0188EC)
Spr0to13Prop:
	db $00,$02,$03,$0D,$40,$42,$43,$45
	db $50,$50,$50,$5C,$DD,$05,$00,$20
	db $20,$00,$00,$00

NakedKoopaEntry:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ If sprites aren't locked,
	BEQ.b CODE_018952		; / branch to $8952
CODE_018908:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x	;COME BACK HERE ON NOT STATIONARY BRANCH
	CMP.b #$80
	BCC.b CODE_01891F
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ If sprites are locked,
	BNE.b CODE_01891F		; / branch to $891F
CODE_018913:
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main	; Set the animation frame, obviously.
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	CLC				; |Increase sprite's image by x05
	ADC.b #$05
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
CODE_01891F:
	JSR.w CODE_018931
	JSR.w SMW_HandleNormalSpriteGravity_Sub	; Update sprite position (since we just set frames, etc?)
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor	; \ If sprite is on edge (on ground),
	BEQ.b CODE_01892E		; |Sprite Y Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01892E:
	JMP.w CODE_018B03

CODE_018931:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa	; |If sprite isn't Blue shelless Koopa,
	BNE.b CODE_01893C		; / branch to $893C
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub	; interact with mario
	BRA.b Return018951

CODE_01893C:
	ASL.w !RAM_SMW_NorSpr_PropertyBits167A,x			;\ Optimization: I don't see the point of this.
	SEC							;| All this does is clear, then set !Define_SMW_NorSpr_167AProp_UseNonDefaultPlayerInteraction
	ROR.w !RAM_SMW_NorSpr_PropertyBits167A,x			;/
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	BCC.b CODE_01894B
	JSR.w SMW_KickHelplessSprite_Main
CODE_01894B:
	ASL.w !RAM_SMW_NorSpr_PropertyBits167A,x			;\ Note: !Define_SMW_NorSpr_167AProp_UseNonDefaultPlayerInteraction
	LSR.w !RAM_SMW_NorSpr_PropertyBits167A,x			;/
Return018951:
	RTS

CODE_018952:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x	;CODE RUNA T START?
	BEQ.b CODE_0189B4		;SKIP IF $163E IS ZERO FOR SPRITE.  IS KICKING SHELL TIMER / GENREAL TIME
	CMP.b #$80			;\ if it's not about to kick (probably)
	BNE.b CODE_01896B		;/ don't worry about checking to see if it's the blue koopa
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main	; face mario
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa	; |If sprite is Blue shelless Koopa,
	BEQ.b CODE_018968		; |Set Y speed to xE0
	LDA.b #$E0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_018968:
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x	;ZERO KICKING SHELL TIMER
CODE_01896B:
	CMP.b #$01			;\ if kick timer is not 01
	BNE.b CODE_018908		;/ keep handling kicking and such
	LDY.w !RAM_SMW_NorSpr_Table7E160E,x	;IT KICKS THIS? !@#
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus09_Stunned	;IF NOT STATIONARY, BRANCH
	BNE.b CODE_018908
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;KOOPA BLUE KICK SHELL!
	SEC
	SBC.w !RAM_SMW_NorSpr_XPosLo,y
	CLC
	ADC.b #$12
	CMP.b #$24
	BCS.b CODE_018908
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_PlayKickSfx
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_CODE_01A755	; Kick shell routine, I think
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x	;\
	LDA.w SMW_CheckForNormalSpriteToNormalSpriteCollision_DATA_01A6D7,y	;|  kick sprite in the right direction
	LDY.w !RAM_SMW_NorSpr_Table7E160E,x	;|
	STA.w !RAM_SMW_NorSpr_XSpeed,y	;/
	LDA.b #!Define_SMW_NorSprStatus0A_Kicked	; \ Sprite status = Kicked
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,y	;\
	STA.w !RAM_SMW_NorSpr_Table7E00C2,y	;/ Special handling for shells?
	LDA.b #$08			;\
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,y	;/ don't let other sprites interact for a teeny bit
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,y	;\
	AND.b #!Define_SMW_NorSpr_167AProp_CantBeKickedLikeShell	;| if sprite can be kicked like a shell, don't
	BEQ.b CODE_0189B4		;/ set Y speeds on the sprite
	LDA.b #$E0			;\
	STA.w !RAM_SMW_NorSpr_YSpeed,y	;/ make the sprite go up
CODE_0189B4:
	LDA.w !RAM_SMW_NorSpr_Table7E1528,x
	BEQ.b CODE_018A15
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall	;\if it's not touching a wall, don't make Xspeed 0.
	BEQ.b CODE_0189C0		;/
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
CODE_0189C0:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor	;\
	BEQ.b CODE_0189E6		;/ if not on ground, skip this
	LDA.b !RAM_SMW_Flag_IceLevel
	CMP.b #$01
	LDA.b #$02
	BCC.b CODE_0189CE
	LSR
CODE_0189CE:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.b #$02
	BCC.b CODE_0189FD
	BPL.b CODE_0189DE
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
CODE_0189DE:
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_SpawnNormalSpriteTurnAroundSmoke_Main	; Handle kicked sprite?
CODE_0189E6:
	STZ.w !RAM_SMW_NorSpr_Table7E1570,x	; (No sprite being kicked?)
	JSR.w CODE_018B43
	LDA.b #$E6
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached	; \ Branch if Blue shelless
	CPY.b #!Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa
	BEQ.b CODE_0189F6
	LDA.b #$86
CODE_0189F6:
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	STA.w SMW_OAMBuffer[$40].Tile,y
	RTS

CODE_0189FD:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor	;KOOPA CODE
	BEQ.b CODE_018A0F		; If sprite is not on ground, don't even bother setting
	LDA.b #$FF			;\
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached	;|
	CPY.b #!Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa	;| if sprite is blue shelless,
	BNE.b CODE_018A0C		;/ set sprite timer to FF
	LDA.b #$A0
CODE_018A0C:
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
CODE_018A0F:
	STZ.w !RAM_SMW_NorSpr_Table7E1528,x	; STZ a sprite address (sprite state backup, it seems)
	JMP.w CODE_018913		; Setting frame animation stuff, and then moving on

CODE_018A15:
	LDA.w !RAM_SMW_NorSpr_Table7E1534,x	;\ don't handle kicking stuff if
	BEQ.b CODE_018A88		;/ the koopa doesn't have anything to kick
	LDY.w !RAM_SMW_NorSpr_Table7E160E,x	;\ If sprite that koopa is trying to
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	;|    kick has been kicked, then
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked	;|    handle what is going on with them
	BEQ.b CODE_018A29		;/
	STZ.w !RAM_SMW_NorSpr_Table7E1534,x	; Reset sprite kicked?
	BRA.b CODE_018A62		; Make frame normal and return

CODE_018A29:
	STA.w !RAM_SMW_NorSpr_Table7E1528,y	; if stunned, then set that as the sprite state backup
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall	;\
	BEQ.b CODE_018A38		;/ if not touching a side, do not stop the sprite
	LDA.b #$00			;\
	STA.w !RAM_SMW_NorSpr_XSpeed,y	;| stop sprite and object it is holding
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
CODE_018A38:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor	;\If not on ground,
	BEQ.b CODE_018A62		;/ don't
	LDA.b !RAM_SMW_Flag_IceLevel	;\
	CMP.b #$01			;|if a slippery level,
	LDA.b #$02			;| A = 02
	BCC.b CODE_018A46		;/
	LSR
CODE_018A46:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XSpeed,y	;\
	CMP.b #$02			;| if kicked sprite X speed >2,
	BCC.b CODE_018A69		;/ go to
	BPL.b CODE_018A57		; if it's going right but is faster than 2, go to
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
CODE_018A57:
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_SpawnNormalSpriteTurnAroundSmoke_Main	; Make effect for when koopa kicks it
CODE_018A62:
	STZ.w !RAM_SMW_NorSpr_Table7E1570,x	; Set frame to 0 (normal)
	JSR.w CODE_018B43
	RTS

CODE_018A69:
	LDA.b #$00			;\
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;| stop the kicked sprite and koopa
	STA.w !RAM_SMW_NorSpr_XSpeed,y	;/
	STZ.w !RAM_SMW_NorSpr_Table7E1534,x	; Reset sprite kicked flag?
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	PHX				; Preserve X for later
	TYX				; X = index to kicked sprite
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_CODE_01AA0B	;Handle being kicked (stun timer, etc)
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x	;\
	BEQ.b CODE_018A87		;|1540 is now 00 or FF
	LDA.b #$FF			;|
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x	;/
CODE_018A87:
	PLX				; X = index to koopa again
CODE_018A88:
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x	;\
	BEQ.b CODE_018A9B		;/ If koopa frame counter = 0
	DEC.b !RAM_SMW_NorSpr_Table7E00C2,x	; Decrement sprite ram address (every frame to make
	CMP.b #$08
	LDA.b #$04
	BCS.b CODE_018A96
	LDA.b #$00
CODE_018A96:
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	BRA.b CODE_018B00

CODE_018A9B:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x	;\
	CMP.b #$01			;| if timer = 01
	BNE.b Spr0to13Main		;/
	LDY.w !RAM_SMW_NorSpr_Table7E1594,x	;SHELL TO INTERACT WITH???
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	;\
	CMP.b #!Define_SMW_NorSprStatus08_Normal	;| If sprite is not running normal routines, being
	BCC.b Return018AD9		;/ return
	LDA.w !RAM_SMW_NorSpr_YSpeed,y	;\ if kicked sprite is going left, return
	BMI.b Return018AD9		;/
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ Return if Coin sprite
	CMP.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin
	BEQ.b Return018AD9
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA	;\
	PHX				;|
	TYX				;|
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingB	;|if sprite has no contact, return
	PLX				;|
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact	;|
	BCC.b Return018AD9		;/
	JSR.w SMW_SubOffscreen_Bank01_EraseSprite	;/ if has contact, get rid of sprite
	LDY.w !RAM_SMW_NorSpr_Table7E1594,x	;\
	LDA.b #$10			;| Set some timer for a kicked sprite
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,y	;/ (frozen? Disable interaction?)
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	STA.w !RAM_SMW_NorSpr_Table7E160E,y	;SPRITE NUMBER TO DEAL WITH ?
Return018AD9:
	RTS

ExplodeBomb:
	PHB				; \ Change Bob-omb into explosion
	LDA.b #SMW_BobOmbExplosion_Main>>16
	PHA
	PLB
	JSL.l SMW_BobOmbExplosion_Main
	PLB
	RTS

BobOmbEntry:
	LDA.w !RAM_SMW_NorSpr00D_BobOmb_IsExploding,x	; \ Branch if exploding
	BNE.b ExplodeBomb
	LDA.w !RAM_SMW_NorSpr00D_BobOmb_WaitBeforeExplosion,x	; \ Branch if not set to explode
	; Change from D0 to 80 to make bob-ombs not stun themselves then explode on
	; their own, like SMB3 and other games.
	BNE.b RegularKoopaEntry
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Stunned
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$40			; \ Time until explosion = #$40
	STA.w !RAM_SMW_NorSpr00D_BobOmb_WaitBeforeExplosion,x
	JMP.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1	; Draw sprite

RegularKoopaEntry:
SpinyEntry:
BuzzyBeetleEntry:
GoombaEntry:
YellowParaKoopaEntry:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ If sprites locked...
	BEQ.b Spr0to13Main
CODE_018B00:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub	; | ...interact with Mario
CODE_018B03:
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_Sub	; | ...interact with sprites
	JSR.w Spr0to13Gfx		; | ...draw sprite
	RTS				; / Return

Spr0to13Main:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor	; \ If sprite on ground...
	BEQ.b CODE_018B2E
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	LDA.w Spr0to13Prop,y		; | Set sprite X speed
	LSR
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	BCC.b CODE_018B1C
	INY				; | Increase index if sprite set to go fast
	INY
CODE_018B1C:
	LDA.w Spr0to13SpeedX,y
	EOR.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x	; | what does $15B8,x do?
	ASL
	LDA.w Spr0to13SpeedX,y
	BCC.b CODE_018B2C
	CLC
	ADC.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
CODE_018B2C:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_018B2E:
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x	; \ If touching an object in the direction
	TYA				; | that Mario is moving...
	INC
	AND.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$03
	BEQ.b CODE_018B3C
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; / ...Sprite X Speed = 0
CODE_018B3C:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling	; \ If touching ceiling...
	BEQ.b CODE_018B43
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; / ...Sprite Y Speed = 0
CODE_018B43:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_HandleNormalSpriteGravity_Sub	; Apply speed to position
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main	; Set the animation frame
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor	; \ Branch if not on ground
	BEQ.b SpriteInAir
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	STZ.w !RAM_SMW_NorSpr_Table7E151C,x
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	LDA.w Spr0to13Prop,y		; | If follow Mario is set...
	PHA
	AND.b #$04
	BEQ.b DontFollowMario
	LDA.w !RAM_SMW_NorSpr_Table7E1570,x	; | ...and time until turn == 0...
	AND.b #$7F
	BNE.b DontFollowMario
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	PHA
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main	; | ...face Mario
	PLA				; | If was facing the other direction...
	CMP.w !RAM_SMW_NorSpr_FacingDirection,x
	BEQ.b DontFollowMario
	LDA.b #$08			; | ...set turning timer
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
DontFollowMario:
	PLA				; \ If jump over shells is set call routine
	AND.b #$08
	BEQ.b CODE_018B82
	JSR.w JumpOverKickedObject
CODE_018B82:
	BRA.b CODE_018BB0

SpriteInAir:
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	LDA.w Spr0to13Prop,y		; \ If flutter wings is set...
	BPL.b CODE_018B90
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main	; | ...set frame...
	BRA.b CODE_018B93		; | ...and don't zero out $1570,x

CODE_018B90:
	STZ.w !RAM_SMW_NorSpr_Table7E1570,x
CODE_018B93:
	LDA.w Spr0to13Prop,y		; \ If stay on ledges is set...
	AND.b #$02
	BEQ.b CODE_018BB0
	LDA.w !RAM_SMW_NorSpr_Table7E151C,x	; | todo: what are all these?
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	ORA.w !RAM_SMW_NorSpr_Table7E1528,x
	ORA.w !RAM_SMW_NorSpr_Table7E1534,x
	BNE.b CODE_018BB0
	JSR.w SMW_ChangeNormalSpriteDirection_Main	; | ...change sprite direction
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_Table7E151C,x
CODE_018BB0:
	LDA.w !RAM_SMW_NorSpr_Table7E1528,x
	BEQ.b CODE_018BBA
	JSR.w CODE_018931
	BRA.b CODE_018BBD

CODE_018BBA:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub	; Interact with Mario
CODE_018BBD:
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_Sub	; Interact with other sprites
	JSR.w SMW_ChangeNormalSpriteDirection_CheckIfTouchingWall	; Change direction if touching an object
Spr0to13Gfx:
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; \ Store sprite direction
	PHA
	LDY.w !RAM_SMW_NorSpr_TurnAroundTimer,x	; \ If turning timer is set...
	BEQ.b CODE_018BDE
	LDA.b #$02			; | ...set turning image
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b #$00
	CPY.b #$05			; | If turning timer >= 5...
	BCC.b CODE_018BD8
	INC				; | ...flip sprite direction (temporarily)
CODE_018BD8:
	EOR.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_018BDE:
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached	; \ Branch if sprite is 2 tiles high
	LDA.w Spr0to13Prop,y
	AND.b #$40
	BNE.b CODE_018BEC
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1	; \ Draw 1 tile high sprite and return
	BRA.b DoneWithSprite

CODE_018BEC:
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x	; \ Nothing?
	LSR
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ Y position -= #$0F (temporarily)
	PHA
	SBC.b #$0F
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSR.w SMW_GenericGFXRtDraw2Tiles16x16sStacked_Sub	; Draw sprite
	PLA				; \ Restore Y position
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Add wings if sprite number > #$08
	CMP.b #!Define_SMW_SpriteID_NorSpr008_LeftFlyingGreenParaKoopa
	BCC.b DoneWithSprite
	JSR.w SMW_DrawWingTiles_ParaKoopaEntry
DoneWithSprite:
	PLA				; \ Restore sprite direction
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_NakedKoopaEntry, SMW_NorSpr000_GreenNakedKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_NakedKoopaEntry, SMW_NorSpr001_RedNakedKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_NakedKoopaEntry, SMW_NorSpr002_BlueNakedKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_NakedKoopaEntry, SMW_NorSpr003_YellowNakedKoopa_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_BobOmbEntry, SMW_NorSpr00D_BobOmb_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_RegularKoopaEntry, SMW_NorSpr004_GreenKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_RegularKoopaEntry, SMW_NorSpr005_RedKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_RegularKoopaEntry, SMW_NorSpr006_BlueKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_RegularKoopaEntry, SMW_NorSpr007_YellowKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_YellowParaKoopaEntry, SMW_NorSpr00C_YellowParaKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_GoombaEntry, SMW_NorSpr00F_Goomba_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_BuzzyBeetleEntry, SMW_NorSpr011_BuzzyBeetle_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_SpinyEntry, SMW_NorSpr013_Spiny_Status08_Main)
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_GenericEnemies_Status08(Address)
namespace SMW_NorSprXXX_GenericEnemies_Status08
%InsertMacroAtXPosition(<Address>)

GreenParaKoopaEntry:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_018CB7
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w Spr0to13SpeedX,y
	EOR.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	ASL
	LDA.w Spr0to13SpeedX,y
	BCC.b CODE_018C64
	CLC
	ADC.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
CODE_018C64:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	TYA
	INC
	AND.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ If touching object,
	AND.b #$03
	BEQ.b CODE_018C71
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; / Sprite X Speed = 0
CODE_018C71:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ If flying left Green Koopa...
	CMP.b #!Define_SMW_SpriteID_NorSpr008_LeftFlyingGreenParaKoopa
	BNE.b CODE_018C8C
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X	; | Update X position
	LDY.b #$FC
	LDA.w !RAM_SMW_NorSpr_Table7E1570,x	; | Y speed = #$FC or #$04,
	AND.b #$20			; | depending on 1570,x
	BEQ.b CODE_018C85
	LDY.b #$04
CODE_018C85:
	STY.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y	; / Update Y position
	BRA.b CODE_018C91

CODE_018C8C:
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_018C91:
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling
	BEQ.b CODE_018C9B
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_018C9B:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_018CAE
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	LDA.b #$D0
	LDY.w !RAM_SMW_NorSpr_Table7E160E,x
	BNE.b CODE_018CAC
	LDA.b #$B0
CODE_018CAC:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_018CAE:
	JSR.w SMW_ChangeNormalSpriteDirection_CheckIfTouchingWall
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSR.w SMW_SubOffscreen_Bank01_Entry1
CODE_018CB7:
	JMP.w Spr0to13Gfx

DATA_018CBA:
	db $FF,$01

DATA_018CBC:
	db $F0,$10

HorizontalRedParaKoopaEntry:
	JSR.w SMW_SubOffscreen_Bank01_Entry2
	BRA.b CODE_018CC6

VerticalRedParaKoopaEntry:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
CODE_018CC6:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_018D2A
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	PHA
	JSR.w SMW_SetFacingDirectionBasedOnSpeed_Bank01
	PLA
	CMP.w !RAM_SMW_NorSpr_FacingDirection,x
	BEQ.b CODE_018CDC
	; Time it takes for a Red Vertical Parakoopa to turn around after reaching
	; it's maximum/mimimum Y speed. (08)
	LDA.b #$08			; \ Set turning timer
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
CODE_018CDC:
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr00A_VerticalRedParaKoopa
	BNE.b CODE_018CEA
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	BRA.b CODE_018CFD

CODE_018CEA:
	LDY.b #$FC
	LDA.w !RAM_SMW_NorSpr_Table7E1570,x
	AND.b #$20
	BEQ.b CODE_018CF5
	LDY.b #$04
CODE_018CF5:
	STY.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
CODE_018CFD:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	BNE.b CODE_018D27
	INC.b !RAM_SMW_NorSpr_Table7E00C2,x
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x
	AND.b #$03
	BNE.b CODE_018D27
	LDA.w !RAM_SMW_NorSpr_Table7E151C,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CLC
	ADC.w DATA_018CBA,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w DATA_018CBC,y
	BNE.b CODE_018D27
	INC.w !RAM_SMW_NorSpr_Table7E151C,x
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
CODE_018D27:
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
CODE_018D2A:
	JSR.w CODE_018CB7
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_GreenParaKoopaEntry, SMW_NorSpr008_LeftFlyingGreenParaKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_GreenParaKoopaEntry, SMW_NorSpr009_BouncingGreenParaKoopa_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_HorizontalRedParaKoopaEntry, SMW_NorSpr00B_HorizontalRedParaKoopa_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_GenericEnemies_Status08_VerticalRedParaKoopaEntry, SMW_NorSpr00A_VerticalRedParaKoopa_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr00E_Keyhole_Status01(Address)
namespace SMW_NorSpr00E_Keyhole_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr00E_Keyhole_Status08(Address)
namespace SMW_NorSpr00E_Keyhole_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot
CODE_01E1CA:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b CODE_01E1D8
	; Sprite that can unlock keyholes in its stunned status (Default is 80:
	; Key)
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr080_Key
	BEQ.b CODE_01E1DB
CODE_01E1D8:
	DEY
	BPL.b CODE_01E1CA
CODE_01E1DB:
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01E1E5
	LDA.w !RAM_SMW_Yoshi_KeyInMouthFlag
	BNE.b CODE_01E1ED
CODE_01E1E5:
	TYA
	STA.w !RAM_SMW_NorSpr00E_Keyhole_HighestSlotWithKey,x
	BMI.b CODE_01E23A
	BRA.b CODE_01E1F3

CODE_01E1ED:
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	BRA.b CODE_01E201

CODE_01E1F3:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus0B_Carried
	BNE.b CODE_01E23A
	PHX
	TYX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingB
	PLX
CODE_01E201:
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b CODE_01E23A
	LDA.w !RAM_SMW_NorSpr00E_Keyhole_ActivateKeyholeFlag,x
	BNE.b CODE_01E23A
	LDA.b #$30
	STA.w !RAM_SMW_Timer_EndLevelViaKeyhole
	LDA.b #!Define_SMW_LevelMusic_IntoKeyhole2
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	INC.w !RAM_SMW_Player_FreezePlayerFlag
	INC.b !RAM_SMW_Flag_SpritesLocked
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr00E_Keyhole_XPosHi
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr00E_Keyhole_XPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr00E_Keyhole_YPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr00E_Keyhole_YPosLo
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr00E_Keyhole_ActivateKeyholeFlag,x
CODE_01E23A:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.b #$EB
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$FB
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b #$30
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	LDY.b #$00
	LDA.b #$01
	JSR.w SMW_FinishOAMWrite_Sub
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr010_ParaGoomba_Status08(Address)
namespace SMW_NorSpr010_ParaGoomba_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_018D39
	JSR.w CODE_018DAC
	RTS

CODE_018D39:
	JSR.w SMW_SetXSpeedBasedOnNormalSpriteFacingDirection_Main
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_NorSpr010_ParaGoomba_FacePlayerTimer,x
	LSR
	LSR
	LSR
	AND.b #$01
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w CODE_018DAC
	INC.b !RAM_SMW_NorSpr010_ParaGoomba_FacePlayerTimer,x
	LDA.w !RAM_SMW_NorSpr010_ParaGoomba_HopCounter,x
	BNE.b CODE_018D5F
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BPL.b CODE_018D5F
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
CODE_018D5F:
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling
	BEQ.b CODE_018D69
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_018D69:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_018DA5
	LDA.b !RAM_SMW_NorSpr010_ParaGoomba_FacePlayerTimer,x
	AND.b #$3F
	BNE.b CODE_018D77
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
CODE_018D77:
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	LDA.w !RAM_SMW_NorSpr010_ParaGoomba_HopCounter,x
	BNE.b CODE_018D82
	STZ.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
CODE_018D82:
	LDA.w !RAM_SMW_NorSpr010_ParaGoomba_WaitBeforeHoppingAfterBigHop,x
	BNE.b CODE_018DA5
	INC.w !RAM_SMW_NorSpr010_ParaGoomba_HopCounter,x
	LDY.b #$F0
	LDA.w !RAM_SMW_NorSpr010_ParaGoomba_HopCounter,x
	CMP.b #$04
	BNE.b CODE_018DA3
	STZ.w !RAM_SMW_NorSpr010_ParaGoomba_HopCounter,x
	JSL.l SMW_GetRand_Main
	AND.b #$3F
	ORA.b #$50
	STA.w !RAM_SMW_NorSpr010_ParaGoomba_WaitBeforeHoppingAfterBigHop,x
	LDY.b #$D0
CODE_018DA3:
	STY.b !RAM_SMW_NorSpr_YSpeed,x
CODE_018DA5:
	JSR.w SMW_ChangeNormalSpriteDirection_CheckIfTouchingWall
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
	RTS

CODE_018DAC:
	JSR.w GoombaWingGFXRt
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	JMP.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr010_ParaGoomba_Status08(Address)
namespace SMW_NorSpr010_ParaGoomba_Status08
%InsertMacroAtXPosition(<Address>)

; Goomba Wing alignment, X position. First 8 bytes are for the alignment
; when the goomba's hopping left, the other 8 when he's hopping into the
; right direction.
WingXDisp:
	db $F7,$0B
	db $F6,$0D
	db $FD,$0C
	db $FC,$0D
	db $0B,$F5
	db $0A,$F3
	db $0B,$FC
	db $0C,$FB

WingYDisp:
	db $F7,$F7
	db $F8,$F8
	db $01,$01
	db $02,$02

; Palette/GFX page/Priority/Flip of Goomba Wing Tiles
WingProp:
	db $46,$06

; Sprite tilemap: Goomba Wings
WingTiles:
	db $C6,$C6
	db $5D,$5D

; Size of Goomba Wing tiles
WingTileSize:
	db $02,$02
	db $00,$00

GoombaWingGFXRt:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LSR
	LSR
	AND.b #$02
	CLC
	ADC.w !RAM_SMW_NorSpr_AnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM05
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	PHX
	LDX.b #$01
CODE_018E07:
	STX.b !RAM_SMW_Misc_ScratchRAM03
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	PHA
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	BNE.b CODE_018E15
	CLC
	ADC.b #$08
CODE_018E15:
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w WingXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w WingYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w WingTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w WingTileSize,x
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	LSR
	LDA.w WingProp,x
	BCS.b CODE_018E49
	EOR.b #$40
CODE_018E49:
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	CLC
	ADC.b #$08
	TAY
	DEX
	BPL.b CODE_018E07
	PLX
	LDY.b #$FF
	LDA.b #$02
	JSR.w SMW_FinishOAMWrite_Sub
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr012_UnusedSprite_Status01(Address)
namespace SMW_NorSpr012_Unused_Status01
%InsertMacroAtXPosition(<Address>)

UNK_01F873:
	db $08,$F8

Main:
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	STA.w !RAM_SMW_NorSpr012_UnusedSprite_UnknownRAM,x
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr012_Unused_Status01_Return, SMW_NorSpr012_Unused_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr014_SpinyEgg_Status08(Address)
namespace SMW_NorSpr014_SpinyEgg_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_018C44
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_018C44
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_018C3E
	LDA.b #!Define_SMW_SpriteID_NorSpr013_Spiny	; \ Sprite = Spiny
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Reset sprite tables
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	JSR.w SMW_MakeStunnedSpriteBounceOrSlowDownOnGround_Main
CODE_018C3E:
	JSR.w SMW_ChangeNormalSpriteDirection_CheckIfTouchingWall
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
CODE_018C44:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.b #$02
	JSR.w SMW_GenericGFXRtDraw4Tiles8x8Square_Sub
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_FixedMovementCheepCheep_Status01(Address)
namespace SMW_NorSprXXX_FixedMovementCheepCheep_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	INC.w !RAM_SMW_NorSprXXX_FixedMovementCheepCheep_MovementFlag,x
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_FixedMovementCheepCheep_Status01_Main, SMW_NorSpr016_VerticalCheepCheep_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_FixedMovementCheepCheep_Status01_Return, SMW_NorSpr015_HorizontalCheepCheep_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSprXXX_FixedMovementCheepCheep_Status08(Address)
namespace SMW_NorSprXXX_FixedMovementCheepCheep_Status08
%InsertMacroAtXPosition(<Address>)

SwimmingXSpeed:
	db $08,$F8

SwimmingYSpeed:
	db $00,$00,$08,$F8

KickedXSpeed:
	db $F0,$10

FloppingYSpeed:
	db $E0,$E8,$D0,$D8

FloppingXSpeed:
	db $08,$F8,$10,$F0,$04,$FC,$14,$EC

DATA_01B031:
	db $03,$0C

; Both fixed-movement Cheep Cheeps, $15 horizontal and $16 vertical; which one
; it is comes from !RAM_SMW_NorSprXXX_FixedMovementCheepCheep_MovementFlag, set
; by the Status01 routine.
;
; The branch is on !RAM_SMW_NorSpr_InLiquidFlag. In liquid it swims along its
; axis at the speeds in SwimmingXSpeed and SwimmingYSpeed; out of liquid it
; flops -- gravity, a random speed out of FloppingXSpeed and FloppingYSpeed, and
; a random vertical flip. A freshly spawned slot has the flag clear, and nothing
; sets it until SMW_HandleNormalSpriteGravity_Sub has run
; SMW_HandleNormalSpriteLevelCollision_Sub's buoyancy check once. So a fish
; placed in water flops for its first frame and swims from its second.
;
; Which of the two it is doing decides the tile page as well as the tile. The
; tail at CODE_01B10A puts bit 1 of !RAM_SMW_NorSpr_AnimationFrame, inverted,
; into bit 0 of !RAM_SMW_NorSpr_YXPPCCCT -- the tile number's ninth bit -- and
; the flopping branch has added $02 to that frame. So the swimming frames are
; drawn from tiles $100-$1FF and the flopping ones from $000-$0FF, out of
; different sprite graphics pages. The tail forces the bit back to 1 before
; returning.
Main:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_01B03E
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_01B041
CODE_01B03E:
	JMP.w CODE_01B10A

CODE_01B041:
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BNE.b CODE_01B0A7
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b CODE_01B054
	JSR.w SMW_ChangeNormalSpriteDirection_Main
CODE_01B054:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01B09C
	LDA.w !RAM_SMW_Sprites_SpriteBuoyancySettings
	BEQ.b CODE_01B062
	JSL.l SMW_SpawnWaterSplash_VerticalCheepCheepEntry
CODE_01B062:
	JSL.l SMW_GetRand_Main
	ADC.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	TAY
	LDA.w FloppingXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSL.l SMW_GetRand_Main
	LDA.w !RAM_SMW_Misc_RandomByte2
	AND.b #$03
	TAY
	LDA.w FloppingYSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.w !RAM_SMW_Misc_RandomByte1
	AND.b #$40
	BNE.b CODE_01B08E
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	EOR.b #$80
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
CODE_01B08E:
	JSL.l SMW_GetRand_Main
	LDA.w !RAM_SMW_Misc_RandomByte1
	AND.b #$80
	BNE.b CODE_01B09C
	JSR.w SMW_SetFacingDirectionBasedOnSpeed_Bank01
CODE_01B09C:
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	CLC
	ADC.b #$02
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	BRA.b CODE_01B0EA

CODE_01B0A7:
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	JSR.w SMW_SetFacingDirectionBasedOnSpeed_Bank01
	ASL.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LSR.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	LDY.w !RAM_SMW_NorSprXXX_FixedMovementCheepCheep_MovementFlag,x
	AND.w DATA_01B031,y
	BNE.b CODE_01B0C3
	LDA.w !RAM_SMW_NorSprXXX_FixedMovementCheepCheep_TurnAroundTimer,x
	BNE.b CODE_01B0CA
CODE_01B0C3:
	LDA.b #$80
	STA.w !RAM_SMW_NorSprXXX_FixedMovementCheepCheep_TurnAroundTimer,x
	INC.b !RAM_SMW_NorSprXXX_FixedMovementCheepCheep_MovementDirection,x
CODE_01B0CA:
	LDA.b !RAM_SMW_NorSprXXX_FixedMovementCheepCheep_MovementDirection,x
	AND.b #$01
	TAY
	LDA.w !RAM_SMW_NorSprXXX_FixedMovementCheepCheep_MovementFlag,x
	BEQ.b CODE_01B0D6
	INY
	INY
CODE_01B0D6:
	LDA.w SwimmingXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w SwimmingYSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	AND.b #$0C
	BNE.b CODE_01B0EA
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
CODE_01B0EA:
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_Sub
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	BCC.b CODE_01B10A
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BEQ.b CODE_01B107
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario has star
	BNE.b CODE_01B107
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b CODE_01B10A
	JSL.l SMW_DamagePlayer_Hurt
	BRA.b CODE_01B10A

CODE_01B107:
	JSR.w SMW_KickHelplessSprite_Main
CODE_01B10A:
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LSR
	EOR.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	AND.b #$FE
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	; Replace 9D F6 15 with EA EA EA to make the fish (Cheep Cheep) tilemap use
	; a single GFX page
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LSR.w !RAM_SMW_NorSpr_YXPPCCCT,x
	SEC
	ROL.w !RAM_SMW_NorSpr_YXPPCCCT,x
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_FixedMovementCheepCheep_Status08_Main, SMW_NorSpr015_HorizontalCheepCheep_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_FixedMovementCheepCheep_Status08_Main, SMW_NorSpr016_VerticalCheepCheep_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr017_GeneratorCheepCheep_Status01(Address)
namespace SMW_NorSpr017_GeneratorCheepCheep_Status01
%InsertMacroAtXPosition(<Address>)

InitXSpeed:
	db $10,$F0

Main:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w InitXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr017_GeneratorCheepCheep_Status01_Main, SMW_NorSpr018_SurfaceJumpingCheepCheep_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr017_GeneratorCheepCheep_Status08(Address)
namespace SMW_NorSpr017_GeneratorCheepCheep_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_NorSpr018_SurfaceJumpingCheepCheep_Status08_CODE_01B209
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01B1B0
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$20
	BPL.b CODE_01B1AE
	CLC
	ADC.b #$01
CODE_01B1AE:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return01B1B0:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr018_SurfaceJumpingCheepCheep_Status08(Address)
namespace SMW_NorSpr018_SurfaceJumpingCheepCheep_Status08
%InsertMacroAtXPosition(<Address>)

YSpeed:
	db $D0,$D0,$B0

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01B209
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	STA.w !RAM_SMW_NorSpr_Table7E151C,x
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BEQ.b CODE_01B1EA
	LDA.b !RAM_SMW_NorSpr018_SurfaceJumpingCheepCheep_HopCounter,x
	CMP.b #$03
	BEQ.b CODE_01B1DE
	INC.b !RAM_SMW_NorSpr018_SurfaceJumpingCheepCheep_HopCounter,x
	TAY
	LDA.w YSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	STZ.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BRA.b CODE_01B206

CODE_01B1DE:
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_01B1E8
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01B1E8:
	BRA.b CODE_01B206

CODE_01B1EA:
	INC.w !RAM_SMW_NorSpr_Table7E1570,x
	INC.w !RAM_SMW_NorSpr_Table7E1570,x
	CMP.w !RAM_SMW_NorSpr_Table7E151C,x
	BEQ.b CODE_01B206
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	LDA.b !RAM_SMW_NorSpr018_SurfaceJumpingCheepCheep_HopCounter,x
	CMP.b #$03
	BNE.b CODE_01B206
	STZ.b !RAM_SMW_NorSpr018_SurfaceJumpingCheepCheep_HopCounter,x
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01B206:
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
CODE_01B209:
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
	JSR.w SMW_SetFacingDirectionBasedOnSpeed_Bank01
	JMP.w SMW_NorSprXXX_FixedMovementCheepCheep_Status08_CODE_01B10A
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr019_DisplayMessage_Status01(Address)
namespace SMW_NorSpr019_DisplayMessage_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$28			; \ Set current sprite's "disable contact with other sprites" timer to x28
	STA.w !RAM_SMW_NorSpr019_DisplayMessage_WaitBeforeDisplayMessage,x
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr019_DisplayMessage_Status01_Main, SMW_NorSpr08C_SideExitAndFireplace_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr019_DisplayMessage_Status08(Address)
namespace SMW_NorSpr019_DisplayMessage_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_NorSpr019_DisplayMessage_WaitBeforeDisplayMessage,x
	CMP.b #$01
	BNE.b Return
	STA.w !RAM_SMW_Overworld_MarioMap				;\ LM: Shift+F8 will NOP these lines out so that this sprite no longer affects your overworld position.
	STA.w !RAM_SMW_Overworld_SaveBuffer+$6F				;/ Note: !Define_SMW_Overworld_YoshisIsland
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	INC.w !RAM_SMW_Misc_DisplayMessage
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr019_DisplayMessage_Status08_Main, SMW_NorSpr03E_PSwitch_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

;Glitch: Beating Funky will cause only the standard horizontal bullet bills to change into pidgets.

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr01C_BulletBill_Status01(Address)
namespace SMW_NorSpr01C_BulletBill_Status01
%InsertMacroAtXPosition(<Address>)

Main:								; Glitch: Placing this sprite directly causes it to not play its usual sound.
								; Optimization: Setting this routine to handle playing the bullet bill sound will remove the need to make it play in the bullet spawners.
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X	;\
	TYA				;|take which direction mario is for future use
	STA.b !RAM_SMW_NorSpr01C_BulletBill_FiringDirection,x	;/
	LDA.b #$10			;\
	STA.w !RAM_SMW_NorSpr01C_BulletBill_AppearBehindLayer1Timer,x	;/ set something to do with it's frames
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr01C_BulletBill_Status08(Address)
namespace SMW_NorSpr01C_BulletBill_Status08
%InsertMacroAtXPosition(<Address>)

; Bullet Bill properties, YXPPCCCT. - First byte: Right flying bullet bill -
; Second byte: Left flying bullet bill - Third byte: Vertically upwards
; flying bullet bill - Fourth byte: Vertically downwards flying bullet bill
; - Fifth byte: Diagonally flying bullet bill, lower left - Sixth byte:
; Diagonally flying bullet bill, upper left - Seventh byte: Diagonally
; flying bullet bill, upper right - Eighth byte: Diagonally flying bullet
; bill, lower right
Prop:
	db $42		; Left
	db $02		; Right
	db $03		; Up
	db $83		; Down
	db $03		; Up-Right
	db $43		; Down-Right
	db $03		; Down-Left
	db $43		; Up-Left

; Which GFX frame to use (00 = regular bill, 01 = vertical bill, 02 =
; diagonal bill) for the Bullet Bills. Same order as x91C7.
AnimationFrame:
	db $00		; Left
	db $00		; Right
	db $01		; Up
	db $01		; Down
	db $02		; Up-Right
	db $03		; Down-Right
	db $03		; Down-Left
	db $02		; Up-Left

; X speed of Bullet Bills. Same order as $018FC7.
XSpeed:
	db $20		; Left
	db $E0		; Right
	db $00		; Up
	db $00		; Down
	db $18		; Up-Right
	db $18		; Down-Right
	db $E8		; Down-Left
	db $E8		; Up-Left

; Y speed of Bullet Bills. Same order as $018FC7.
YSpeed:
	db $00		; Left
	db $00		; Right
	db $E0		; Up
	db $20		; Down
	db $E8		; Up-Right
	db $18		; Down-Right
	db $18		; Down-Left
	db $E8		; Up-Left

Main:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_019014
	LDY.b !RAM_SMW_NorSpr01C_BulletBill_FiringDirection,x
	LDA.w Prop,y			; \ Store gfx properties into palette byte
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LDA.w AnimationFrame,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w XSpeed,y			; \ Set X speed
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w YSpeed,y			; \ Set Y speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X	; \ Update position
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub			; Note: Bullet Bills only use this to generate water splashes. They otherwise don't interact with terrain.
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub	; Interact with Mario and sprites
CODE_019014:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$F0
	BCC.b CODE_019023
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
CODE_019023:
	LDA.w !RAM_SMW_NorSpr01C_BulletBill_AppearBehindLayer1Timer,x
	BEQ.b CODE_01902B
	JMP.w SMW_NorSprStatus09_Stunned_BulletBillEntry

CODE_01902B:
	JMP.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr01D_HoppingFlame_Status08(Address)
namespace SMW_NorSpr01D_HoppingFlame_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_018F49
	INC.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_SetXSpeedBasedOnNormalSpriteFacingDirection_Main
	ASL.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_018F43
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	LDA.w !RAM_SMW_NorSpr01D_HoppingFlame_WaitBeforeHopping,x
	BEQ.b CODE_018F38
	DEC
	BNE.b CODE_018F43
	JSR.w CODE_018F50
	BRA.b CODE_018F43

CODE_018F38:
	JSL.l SMW_GetRand_Main
	AND.b #$1F
	ORA.b #$20
	STA.w !RAM_SMW_NorSpr01D_HoppingFlame_WaitBeforeHopping,x
CODE_018F43:
	JSR.w SMW_ChangeNormalSpriteDirection_CheckIfTouchingWall
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
CODE_018F49:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	RTS

CODE_018F50:
	JSL.l SMW_GetRand_Main
	AND.b #$0F
	ORA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.w !RAM_SMW_Misc_RandomByte1
	AND.b #$03
	BNE.b CODE_018F64
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
CODE_018F64:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01
	BNE.b Return018F96
	JSR.w SMW_CheckForAvailableExtendedSpriteSlot_Main
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDA.b #!Define_SMW_SpriteID_ExtSpr03_FlameRemnant	; \ Extended sprite = Hopping flame's flame
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b #$FF
	STA.w !RAM_SMW_ExtSpr03_FlameRemnant_DespawnTimer,y
Return018F96:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr01E_Lakitu_Status01(Address)
namespace SMW_NorSpr01E_Lakitu_Status01
%InsertMacroAtXPosition(<Address>)

ADDR_018468:
	JMP.w SMW_SubOffscreen_Bank01_EraseSprite

Main:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_01846D:
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID
	BEQ.b CODE_018484
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	;\
	CMP.b #!Define_SMW_NorSprStatus08_Normal	;| if it's runnning normally
	BNE.b CODE_018484		;/  restart the loop
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	;\
	CMP.b #!Define_SMW_SpriteID_NorSpr087_LakituCloud	;| if lakitu's cloud is around already
	BEQ.b ADDR_018468		;/   erase the sprite
	CMP.b #!Define_SMW_SpriteID_NorSpr01E_Lakitu	;/ erase it if there is another lakitu, too
	BEQ.b ADDR_018468
CODE_018484:
	DEY				;\restart the loop!
	BPL.b CODE_01846D		;/if it's not done, restart
	STZ.w !RAM_SMW_Timer_RespawnSprite	;\
	STZ.w !RAM_SMW_Timer_DisappearingSprite	;|
	STZ.w !RAM_SMW_GenSpr_SpriteID	;/ And don't let it come back!
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\
	STA.w !RAM_SMW_Sprites_YPosOfRespawningSpriteLo	;| working with the sprite's xpos and mario(?)
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;|
	STA.w !RAM_SMW_Sprites_YPosOfRespawningSpriteHi	;/
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	;\
	BMI.b SetLakituType		;/ if you can't find a free slot, then go monty mole
	STY.w !RAM_SMW_Sprites_LakituCloudSlotIndex
	LDA.b #!Define_SMW_SpriteID_NorSpr087_LakituCloud	; \ Sprite = Lakitu Cloud
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\
	STA.w !RAM_SMW_NorSpr_XPosLo,y	;|
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;|
	STA.w !RAM_SMW_NorSpr_XPosHi,y	;|
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;|make the cloud in the same place as lakitu
	STA.w !RAM_SMW_NorSpr_YPosLo,y	;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;|
	STA.w !RAM_SMW_NorSpr_YPosHi,y	;/
	PHX
	TYX
	; Change to EA EA EA EA to make lakitu cloud never get spawned
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
	STZ.w !RAM_SMW_Timer_DespawnLakituCloud
SetLakituType:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\
	AND.b #$10			;|it's Ydir depends on what it's xpos is
	STA.w !RAM_SMW_NorSpr01E_Lakitu_FishingFlag,x	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr01E_Lakitu_Status01_SetLakituType, SMW_NorSpr04D_GroundMontyMole_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr01E_Lakitu_Status01_SetLakituType, SMW_NorSpr04E_LedgeMontyMole_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr01E_Lakitu_Status01_SetLakituType, SMW_NorSpr0C1_WingedPlatform_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr01E_Lakitu_Status08(Address)
namespace SMW_NorSpr01E_Lakitu_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr01E_Lakitu_ThrowingAnimationTimer,x
	BEQ.b CODE_018FA0
	LDY.b #$02
CODE_018FA0:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_GenericGFXRtDraw2Tiles16x16sStacked_Sub
	LDA.w !RAM_SMW_NorSpr01E_Lakitu_ThrowingAnimationTimer,x
	BEQ.b CODE_018FB8
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$41].YDisp,y
	SEC
	SBC.b #$03
	STA.w SMW_OAMBuffer[$41].YDisp,y
CODE_018FB8:
	LDA.w !RAM_SMW_NorSpr01E_Lakitu_FishingFlag,x
	BEQ.b CheckForPlayerAndNormalSpriteCollisions_Sub
	JSL.l LakituFishingLineGFXRt
CheckForPlayerAndNormalSpriteCollisions:
.Sub
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_Sub
	JMP.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_CheckForPlayerAndNormalSpriteCollisions(Address)
namespace SMW_CheckForPlayerAndNormalSpriteCollisions
%InsertMacroAtXPosition(<Address>)

; Sprite routine used to process interaction with both Mario and other
; sprites (by way of calling $01A7E4 and $01A40D respectively).
Main:
	PHB
	PHK				; Start of the sprite/mario contact
	PLB				; routine (also not entirely covered..I know
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub	; what I am doing next lot
	PLB
	RTL

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr01F_Magikoopa_Status01(Address)
namespace SMW_NorSpr01F_MagiKoopa_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_01BDBA:
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID
	BEQ.b CODE_01BDCF
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_01BDCF
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr01F_MagiKoopa
	BNE.b CODE_01BDCF
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

CODE_01BDCF:
	DEY
	BPL.b CODE_01BDBA
	STZ.w !RAM_SMW_Timer_DisappearingSprite
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr01F_Magikoopa_Status08(Address)
namespace SMW_NorSpr01F_MagiKoopa_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr01F_MagiKoopa_DisableInteraction,x
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BEQ.b CODE_01BDE2
	STZ.b !RAM_SMW_NorSpr01F_MagiKoopa_CurrentState,x
CODE_01BDE2:
	LDA.b !RAM_SMW_NorSpr01F_MagiKoopa_CurrentState,x
	AND.b #$03
	JSL.l SMW_ExecutePtr_Absolute

MagiKoopaPtrs:
	dw State00_FindOpenSpace
	dw State01_FadeIn
	dw State02_Shoot
	dw State03_FadeOut

State00_FindOpenSpace:
	LDA.w !RAM_SMW_Timer_DisappearingSprite
	BEQ.b CODE_01BDFB
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

CODE_01BDFB:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01BE5E
	LDY.b #$24
	STY.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
	LDA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer,x
	BNE.b Return01BE5E
	JSL.l SMW_GetRand_Main
	CMP.b #$D1
	BCS.b Return01BE5E
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSL.l SMW_GetRand_Main
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$20
	CMP.b #$40
	BCC.b Return01BE5E
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.b #$01
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b Return01BE5E
	LDA.w !RAM_SMW_Sprites_Map16TileBeingTouchedHorizontallyHi
	BNE.b Return01BE5E
	INC.b !RAM_SMW_NorSpr01F_MagiKoopa_CurrentState,x
	STZ.w !RAM_SMW_NorSpr01F_MagiKoopa_FadePaletteIndex,x
	JSR.w CODE_01BE82
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
Return01BE5E:
	RTS

State01_FadeIn:
	JSR.w CODE_01C004
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_GenericGFXRtDraw2Tiles16x16sStacked_Sub
	RTS

DATA_01BE69:
	db $04,$02,$00

WandXDisp:
	db $10,$F8

State02_Shoot:
	STZ.w !RAM_SMW_NorSpr01F_MagiKoopa_DisableInteraction,x
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer,x
	BNE.b CODE_01BE86
	INC.b !RAM_SMW_NorSpr01F_MagiKoopa_CurrentState,x
CODE_01BE82:
	LDY.b #$34
	STY.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
CODE_01BE86:
	CMP.b #$40
	BNE.b CODE_01BE96
	PHA
	LDA.b !RAM_SMW_Flag_SpritesLocked
	ORA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BNE.b CODE_01BE95
	JSR.w CODE_01BF1D		;JUMP TO GENERATE MAGIC
CODE_01BE95:
	PLA
CODE_01BE96:
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	TAY
	PHY
	LDA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer,x
	LSR
	LSR
	LSR
	AND.b #$01
	ORA.w DATA_01BE69,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_GenericGFXRtDraw2Tiles16x16sStacked_Sub
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	SEC
	SBC.b #$02
	CMP.b #$02
	BCC.b CODE_01BEC6
	LSR
	BCC.b CODE_01BEC6
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAX
	INC.w SMW_OAMBuffer[$40].YDisp,x
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
CODE_01BEC6:
	PLY
	CPY.b #$01
	BNE.b CODE_01BECE
	JSR.w SMW_SpawnSparkles_NormalSpriteEntry
CODE_01BECE:
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	CMP.b #$04
	BCC.b Return01BF15
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w WandXDisp,y
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	STA.w SMW_OAMBuffer[$42].XDisp,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$42].YDisp,y
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	LSR
	LDA.b #$00
	BCS.b CODE_01BEFC
	ORA.b #$40
CODE_01BEFC:
	ORA.b !RAM_SMW_Sprites_TilePriority
	ORA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	STA.w SMW_OAMBuffer[$42].Prop,y
	LDA.b #$99
	STA.w SMW_OAMBuffer[$42].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	ORA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	STA.w SMW_OAMTileSizeBuffer[$42].Slot,y
Return01BF15:
	RTS

State03_FadeOut:
	JSR.w CODE_01BFE3
	JSR.w SMW_GenericGFXRtDraw2Tiles16x16sStacked_Sub
	RTS

CODE_01BF1D:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_01BF1F:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_01BF28
	DEY
	BPL.b CODE_01BF1F
	RTS

CODE_01BF28:
	LDA.b #!Define_SMW_Sound1DF9_MagicShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr020_Magic	;GENERATES MAGIC HERE!   !@#
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$0A
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b #$20
	JSR.w SMW_AimTowardsPlayer_Bank01
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;PULLS SPEED FROM RAM HERE?
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr01F_Magikoopa_Status08(Address)
namespace SMW_NorSpr01F_MagiKoopa_Status08
%InsertMacroAtXPosition(<Address>)

CODE_01BFE3:
	LDA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer,x
	BNE.b Return01C000
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer,x
	DEC.w !RAM_SMW_NorSpr01F_MagiKoopa_FadePaletteIndex,x
	LDA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadePaletteIndex,x
	CMP.b #$00
	BNE.b CODE_01C001
	INC.b !RAM_SMW_NorSpr01F_MagiKoopa_CurrentState,x
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer,x
	PLA
	PLA
Return01C000:
	RTS

CODE_01C001:
	JMP.w CODE_01C028

CODE_01C004:
	LDA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer,x
	BNE.b CODE_01C05E
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer,x
	INC.w !RAM_SMW_NorSpr01F_MagiKoopa_FadePaletteIndex,x
	LDA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadePaletteIndex,x
	CMP.b #$09
	BNE.b CODE_01C01C
	LDY.b #$24
	STY.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
CODE_01C01C:
	CMP.b #$09
	BNE.b CODE_01C028
	INC.b !RAM_SMW_NorSpr01F_MagiKoopa_CurrentState,x
	LDA.b #$70
	STA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadeTimer,x
	RTS

CODE_01C028:
	LDA.w !RAM_SMW_NorSpr01F_MagiKoopa_FadePaletteIndex,x
	DEC
	ASL
	ASL
	ASL
	ASL
	TAX
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
CODE_01C036:
	LDA.l MagiKoopaFadePalettes,x
	STA.w !RAM_SMW_Palettes_DynamicPaletteColors,y
	INY
	INX
	INC.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$10
	BNE.b CODE_01C036
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
CODE_01C05E:
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr020_Magic_Status08(Address)
namespace SMW_NorSpr020_Magic_Status08
%InsertMacroAtXPosition(<Address>)

; The OAM Properties of the Magikoopa's magic.
Palettes:
	db $05,$07,$09,$0B

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_01BC3F
	JMP.w CODE_01BCBD

CODE_01BC3F:
	JSR.w SMW_SpawnSparkles_NormalSpriteEntry
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	PHA
	LDA.b #$FF
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	PLA
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling
	BEQ.b CODE_01BCBD
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BNE.b CODE_01BCBD
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	; Change to EA EA EA EA EA EA EA EA and every Map16 block will change into
	; sprites when touched by Magikoopa's Magic. (Not just turn blocks)
	LDA.w !RAM_SMW_Sprites_Map16TileBeingTouchedVerticallyLo
	SEC
	SBC.b #$11
	CMP.b #$1D
	BCS.b CODE_01BCB9
	JSL.l SMW_GetRand_Main
	ADC.w !RAM_SMW_Misc_RandomByte2
	ADC.b !RAM_SMW_Player_XSpeed
	ADC.b !RAM_SMW_Counter_GlobalFrames
	LDY.b #!Define_SMW_SpriteID_NorSpr078_1upMushroom
	CMP.b #$35
	BEQ.b StoreSpriteNum
	LDY.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin
	CMP.b #$08
	BCC.b StoreSpriteNum
	LDY.b #!Define_SMW_SpriteID_NorSpr027_Thwimp
	CMP.b #$F7
	BCS.b StoreSpriteNum
	LDY.b #!Define_SMW_SpriteID_NorSpr007_YellowKoopa
StoreSpriteNum:
if defined("Define_SMW_SA1")
	JSL.l SPRITE_NUM_REMAP2
else
	STY.b !RAM_SMW_NorSpr_SpriteID,x
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
endif
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b !RAM_SMW_Blocks_XPosHi	; \ Sprite X position = block X position
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Blocks_XPosLo
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Blocks_YPosHi
	STA.w !RAM_SMW_NorSpr_YPosHi,x	; \ Sprite Y position = block Y position
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$02			; \ Block to generate = #$02
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
CODE_01BCB9:
	JSR.w CODE_01BD98
	RTS

CODE_01BCBD:
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w Palettes,y
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JSR.w GFXRt
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$E0
	BCC.b Return01BCDF
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
Return01BCDF:
	RTS

; Magikoopa's Magic Sine Rotation Table.
Disp:
	db $00,$01,$02,$05,$08,$0B,$0E,$0F
	db $10,$0F,$0E,$0B,$08,$05,$02,$01

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM03
	CLC
	ADC.b #$0C
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l Disp,x
else
	ADC.w Disp,x
endif
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l Disp,x
else
	ADC.w Disp,x
endif
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.b #$05
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l Disp,x
else
	ADC.w Disp,x
endif
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CLC
	ADC.b #$05
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l Disp,x
else
	ADC.w Disp,x
endif
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.b #$05
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l Disp,x
else
	ADC.w Disp,x
endif
	STA.w SMW_OAMBuffer[$42].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CLC
	ADC.b #$05
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l Disp,x
else
	ADC.w Disp,x
endif
	STA.w SMW_OAMBuffer[$42].XDisp,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	STA.w SMW_OAMBuffer[$42].Prop,y
	LDA.b #$88
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$89
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b #$98
	STA.w SMW_OAMBuffer[$42].Tile,y
	LDY.b #$00			; \ 3 8x8 tiles
	LDA.b #$02
	JMP.w SMW_FinishOAMWrite_Sub

CODE_01BD98:
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_01BD9A:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y
	BEQ.b CODE_01BDA3
	DEY
	BPL.b CODE_01BD9A
	RTS

CODE_01BDA3:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr01_PuffOfSmoke
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y
	LDA.b #$1B
	STA.w !RAM_SMW_SmokeSpr_Timer,y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_NetKoopas_Status01(Address)
namespace SMW_NorSprXXX_NetKoopas_Status01
%InsertMacroAtXPosition(<Address>)

; Green horizontal net Koopa's speed (right, left). Red horizontal net
; Koopas move twice this speed.
InitXSpeed:
	db $08,$F8

HorizontalNetKoopaEntry:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w InitXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	BRA.b CODE_01B950

VerticalNetKoopaEntry:
	INC.b !RAM_SMW_NorSprXXX_NetKoopas_MovementDirectionFlag,x
	INC.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$F8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01B950:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	LDY.b #$00
	AND.b #$10
	BNE.b CODE_01B959
	INY
CODE_01B959:
	TYA
	STA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	AND.b #$02
	BNE.b Return01B968
	ASL.b !RAM_SMW_NorSpr_XSpeed,x
	ASL.b !RAM_SMW_NorSpr_YSpeed,x
Return01B968:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NetKoopas_Status01_HorizontalNetKoopaEntry, SMW_NorSpr024_GreenHorizontalNetKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NetKoopas_Status01_HorizontalNetKoopaEntry, SMW_NorSpr025_RedHorizontalNetKoopa_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NetKoopas_Status01_VerticalNetKoopaEntry, SMW_NorSpr022_GreenVerticalNetKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NetKoopas_Status01_VerticalNetKoopaEntry, SMW_NorSpr023_RedVerticalNetKoopa_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSprXXX_NetKoopas_Status08(Address)
namespace SMW_NorSprXXX_NetKoopas_Status08
%InsertMacroAtXPosition(<Address>)

DATA_01B969:
	db $02,$02,$03,$04,$03,$02,$02,$02
	db $01,$02

DATA_01B973:
	db $01,$01,$00,$00,$00,$01,$01,$01
	db $01,$01

DATA_01B97D:
	db $03,$0C

Main:
	LDA.w !RAM_SMW_NorSprXXX_NetKoopas_TurnAroundToOtherSideTimer,x
	BEQ.b CODE_01B9FB
	CMP.b #$30
	BCC.b CODE_01B9A0
	CMP.b #$40
	BCC.b CODE_01B9A3
	BNE.b CODE_01B9A0
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_01B9A0
	LDA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
	JSR.w SMW_ChangeNormalSpriteDirection_Main
	JSR.w CODE_01BA7F
CODE_01B9A0:
	JMP.w CODE_01BA37

CODE_01B9A3:
if defined("Define_SMW_SA1")
	JML.l Y_LOW_REMAP4
	NOP
	NOP
else
	LDY.b !RAM_SMW_NorSpr_YPosLo,x
	PHY
	LDY.w !RAM_SMW_NorSpr_YPosHi,x
endif
	PHY
	LDY.b #$00
	CMP.b #$38
	BCC.b CODE_01B9B1
	INY
CODE_01B9B1:
	LDA.b !RAM_SMW_NorSprXXX_NetKoopas_MovementDirectionFlag,x
	BEQ.b CODE_01B9CC
	INY
	INY
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b #$0C
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
	BEQ.b CODE_01B9CC
	INY
CODE_01B9CC:
	LDA.w !RAM_SMW_Overworld_LevelTileSettings+!Define_SMW_LevelID_ChangeSP2GFX
	BPL.b CODE_01B9D6
	INY
	INY
	INY
	INY
	INY
CODE_01B9D6:
	LDA.w DATA_01B969,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w DATA_01B973,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	PHA
	AND.b #$FE
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JSR.w SMW_GenericGFXRtDraw2Tiles16x16sStacked_Sub
	PLA
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	RTS

CODE_01B9FB:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01BA53
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDY.b !RAM_SMW_NorSprXXX_NetKoopas_MovementDirectionFlag,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.w DATA_01B97D,y
	BEQ.b CODE_01BA14
CODE_01BA0C:
	JSR.w SMW_ChangeNormalSpriteDirection_Main
	JSR.w CODE_01BA7F
	BRA.b CODE_01BA37

CODE_01BA14:
	LDA.w !RAM_SMW_Sprites_Map16TileBeingTouchedVerticallyLo
	LDY.b !RAM_SMW_NorSpr_YSpeed,x
	BEQ.b CODE_01BA27
	BPL.b CODE_01BA1F
	BMI.b CODE_01BA2A
CODE_01BA1F:
	CMP.b #$07
	BCC.b CODE_01BA0C
	CMP.b #$1D
	BCS.b CODE_01BA0C
CODE_01BA27:
	LDA.w !RAM_SMW_Sprites_Map16TileBeingTouchedHorizontallyLo
CODE_01BA2A:
	CMP.b #$07
	BCC.b CODE_01BA32
	CMP.b #$1D
	BCC.b CODE_01BA37
CODE_01BA32:
	LDA.b #$50
	STA.w !RAM_SMW_NorSprXXX_NetKoopas_TurnAroundToOtherSideTimer,x
CODE_01BA37:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01BA53
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	JSR.w SMW_SetFacingDirectionBasedOnSpeed_Bank01
	LDA.b !RAM_SMW_NorSprXXX_NetKoopas_MovementDirectionFlag,x
	BNE.b CODE_01BA4A
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	BRA.b CODE_01BA4D

CODE_01BA4A:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
CODE_01BA4D:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	JSR.w SMW_SubOffscreen_Bank01_Entry1
CODE_01BA53:
	LDA.w !RAM_SMW_NorSprXXX_NetKoopas_MovementDirection,x
	PHA
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	AND.b #$08
	LSR
	LSR
	LSR
	STA.w !RAM_SMW_NorSprXXX_NetKoopas_MovementDirection,x
	LDA.b !RAM_SMW_Sprites_TilePriority
	PHA
	LDA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
	BEQ.b CODE_01BA74
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_01BA74:
	JSR.w SMW_GenericGFXRtDraw2Tiles16x16sStacked_Sub
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	PLA
	STA.w !RAM_SMW_NorSprXXX_NetKoopas_MovementDirection,x
	RTS

CODE_01BA7F:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NetKoopas_Status08_Main, SMW_NorSpr022_GreenVerticalNetKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NetKoopas_Status08_Main, SMW_NorSpr023_RedVerticalNetKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NetKoopas_Status08_Main, SMW_NorSpr024_GreenHorizontalNetKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NetKoopas_Status08_Main, SMW_NorSpr025_RedHorizontalNetKoopa_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr026_Thwomp_Status01(Address)
namespace SMW_NorSpr026_Thwomp_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x					;\ Glitch: If a thwomp falls far enough, it won't be able to go back up to its original height.
	STA.w !RAM_SMW_NorSpr026_Thwomp_InitialYPosLo,x			;/
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_NorSpr_XPosLo_x
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr026_Thwomp_Status01_Return, SMW_NorSpr027_Thwimp_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr026_Thwomp_Status08(Address)
namespace SMW_NorSpr026_Thwomp_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w GFXRt
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b SMW_NorSpr026_Thwomp_Status01_Return
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b SMW_NorSpr026_Thwomp_Status01_Return
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	LDA.b !RAM_SMW_NorSpr026_Thwomp_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

ThwompPtrs:
	dw Waiting
	dw Falling
	dw Rising

Waiting:
	LDA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b CODE_01AEEE
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BNE.b Return01AEF9
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA									;\ Optimization: This is not used.
	STA.w !RAM_SMW_NorSpr026_Thwomp_SidePlayerIsOn,x			;/	
	STZ.w !RAM_SMW_NorSpr026_Thwomp_FaceFrame,x
	LDA.b !RAM_SMW_Misc_ScratchRAM0F					;\ Glitch: The thwomp will act like you're close to it if you're one screen away horizontally
	CLC									;| This should be 16-bit and CheckPlayerPositionRelativeToSprite_Bank01_X needs to check Mario's 16-bit position instead of 8-bit.
	ADC.b #$40								;|
	CMP.b #$80								;|
	BCS.b CODE_01AEE5							;/
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr026_Thwomp_FaceFrame,x
CODE_01AEE5:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$24
	CMP.b #$50
	BCS.b Return01AEF9
CODE_01AEEE:
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr026_Thwomp_FaceFrame,x
	INC.b !RAM_SMW_NorSpr026_Thwomp_CurrentState,x
	LDA.b #$00
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return01AEF9:
	RTS

Falling:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$3E
	BCS.b CODE_01AF07
	ADC.b #$04
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01AF07:
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b Return01AF23
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	LDA.b #$18			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr026_Thwomp_WaitBeforeRising,x
	INC.b !RAM_SMW_NorSpr026_Thwomp_CurrentState,x
Return01AF23:
	RTS

Rising:
	LDA.w !RAM_SMW_NorSpr026_Thwomp_WaitBeforeRising,x
	BNE.b Return01AF3F
	STZ.w !RAM_SMW_NorSpr026_Thwomp_FaceFrame,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.w !RAM_SMW_NorSpr026_Thwomp_InitialYPosLo,x
	BNE.b CODE_01AF38
	LDA.b #$00
	STA.b !RAM_SMW_NorSpr026_Thwomp_CurrentState,x
	RTS

CODE_01AF38:
	LDA.b #$F0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
Return01AF3F:
	RTS

XDisp:
	db $FC,$04,$FC,$04,$00

YDisp:
	db $00,$00,$10,$10,$08

; Thwomp Tilemap
Tiles:
	db $8E,$8E,$AE,$AE,$C8

; YXPPCCCT - Thwomp Properties Byte 01 - Top left Byte 02 - Bottom left Byte
; 03 - Top right Byte 04 - Bottom Right Byte 05 - Angry Thwomp Face
Prop:
	db $03,$43,$03,$43,$03

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.w !RAM_SMW_NorSpr026_Thwomp_FaceFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX
	LDX.b #$03
	CMP.b #$00
	BEQ.b CODE_01AF64
	INX
CODE_01AF64:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Prop,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.w Tiles,x
	CPX.b #$04
	BNE.b CODE_01AF8F
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	CPX.b #$02
	BNE.b CODE_01AF8E
	LDA.b #$CA
CODE_01AF8E:
	PLX
CODE_01AF8F:
	STA.w SMW_OAMBuffer[$40].Tile,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_01AF64
	PLX
	LDA.b #$04
	JMP.w SMW_NormalSpritePlatformGFXRt_CODE_01B37E
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr027_Thwimp_Status08(Address)
namespace SMW_NorSpr027_Thwimp_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_01B006
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01B006
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_01AFC3
	CMP.b #$40
	BCS.b CODE_01AFC8
	ADC.b #$05
CODE_01AFC3:
	CLC
	ADC.b #$03
	BRA.b CODE_01AFCA

CODE_01AFC8:
	LDA.b #$40
CODE_01AFCA:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling	; \ If touching ceiling,
	BEQ.b CODE_01AFD5
	LDA.b #$10			; | Y speed = #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01AFD5:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01B006
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; \ Sprite Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.w !RAM_SMW_NorSpr027_Thwimp_WaitBeforeNextHop,x
	BEQ.b CODE_01AFFC
	DEC
	BNE.b CODE_01B006
	LDA.b #$A0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	INC.b !RAM_SMW_NorSpr027_Thwimp_HoppingDirection,x
	LDA.b !RAM_SMW_NorSpr027_Thwimp_HoppingDirection,x
	LSR
	LDA.b #$10
	BCC.b CODE_01AFF8
	LDA.b #$F0
CODE_01AFF8:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	BRA.b CODE_01B006

CODE_01AFFC:
	LDA.b #!Define_SMW_Sound1DF9_HitHead
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr027_Thwimp_WaitBeforeNextHop,x
CODE_01B006:
	LDA.b #$01
	JMP.w SMW_GenericGFXRtDraw4Tiles8x8Square_Sub
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr029_KoopaKid_Status01(Address)
namespace SMW_NorSpr029_KoopaKids_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	CMP.b #$05
	BCC.b CODE_01CD4E
	LDA.b #$78
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b #$40
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr029_KoopaKid_WendyLemmy_PhaseTimer,x
	RTS

CODE_01CD4E:
	LDY.b #$90
if defined("Define_SMW_SA1")
	JSL.l Y_LOW_REMAP5
else
	STY.b !RAM_SMW_NorSpr_YPosLo,x
	CMP.b #$03
endif
	BCC.b CODE_01CD5E
	JSL.l SetPlatformKoopaKidsInitialPosition
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	RTS

CODE_01CD5E:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	LDA.b #$20
	STA.b !RAM_SMW_Misc_M7AngleLo
	STA.b !RAM_SMW_Misc_M7AngleHi
	JSL.l SMW_InitializeMode7TilemapsAndPalettes_Main
	LDY.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	LDA.w DATA_01CD92,y
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_Mode7RoomToLoad,x
	CMP.b #$01
	BEQ.b CODE_01CD87
	CMP.b #$00
	BNE.b CODE_01CD81
	LDA.b #$70
	STA.b !RAM_SMW_NorSpr_XPosLo_x
CODE_01CD81:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	RTS

CODE_01CD87:
	LDA.b #$26
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_LeftWallXPos,x
	LDA.b #$D8
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_RightWallXPos,x
	RTS

DATA_01CD92:
	db $01,$01,$00

UNK_01CD95:
	db $02,$02,$03,$03
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr029_KoopaKid_Status08(Address)
namespace SMW_NorSpr029_KoopaKids_Status08
%InsertMacroAtXPosition(<Address>)

UNK_01FAB4:
	db $FF,$01,$00,$80,$60,$A0,$40,$D0
	db $D8,$C0,$C8,$0C,$F4

Main:
	LDA.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	JSL.l SMW_ExecutePtr_Absolute	; 00 - Morton

KoopaKidPtrs:
	dw SMW_NorSpr029_KoopaKid_Status08_MortonRoyLudwig_Main	; Morton 
	dw SMW_NorSpr029_KoopaKid_Status08_MortonRoyLudwig_Main	; Roy
	dw SMW_NorSpr029_KoopaKid_Status08_MortonRoyLudwig_Main	; Ludwig
	dw SMW_NorSpr029_KoopaKid_Status08_IggyLarry_Main	; Iggy
	dw SMW_NorSpr029_KoopaKid_Status08_IggyLarry_Main	; Larry
	dw SMW_NorSpr029_KoopaKid_Status08_WendyLemmy_Main	; Lemmy
	dw SMW_NorSpr029_KoopaKid_Status08_WendyLemmy_Main	; Wendy
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr029_KoopaKid_Status08_WendyLemmy(Address)		; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's horizontally offscreen
									; Glitch: This sprite does not call FinishOAMWrite, which means its tiles can wrap around the screen
namespace SMW_NorSpr029_KoopaKid_Status08_WendyLemmy
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank03
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr029_KoopaKid_Status08_IggyLarry(Address)
namespace SMW_NorSpr029_KoopaKid_Status08_IggyLarry
%InsertMacroAtXPosition(<Address>)

HurtXSpeed:
	db $00,$FC,$F8,$F8,$F8,$F8,$F8,$F8
	db $F8,$F8,$F8,$F4,$F0,$F0,$EC,$EC

WalkingAnimationFrames:
	db $00,$01,$02,$00,$01,$02,$00,$01
	db $02,$00,$01,$02,$00,$01,$02,$01

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	ORA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_HurtAnimationTimer,x
	BNE.b CODE_01FB1A
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_M7RotationLo
	ASL
	ROL
	AND.b #$01
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_01FB1A
	INC.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_WaitBeforeNextBallThrow,x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_WaitBeforeNextBallThrow,x
	AND.b #$7F
	BNE.b CODE_01FB1A
	LDA.b #$7F			; \ Set time to go in shell
	STA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_BallThrowAnimationTimer,x
CODE_01FB1A:
	STZ.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_SinkingInLavaTimer,x
	BEQ.b CODE_01FB36
	DEC
	BNE.b Return01FB35
	INC.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	LDA.b #$FF
	STA.w !RAM_SMW_Timer_EndLevel
	LDA.b #!Define_SMW_LevelMusic_PassedBoss
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
Return01FB35:
	RTS

CODE_01FB36:
	JSL.l SMW_InitializeNormalSpriteRAMTables_PropertyTables
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_01FB41
	JMP.w CODE_01FC08

CODE_01FB41:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_FellOffPlatformFlag,x
	BEQ.b CODE_01FB7B
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$40
	BPL.b CODE_01FB56
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	INC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01FB56:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$58
	BCC.b CODE_01FB6E
	CMP.b #$80
	BCS.b CODE_01FB6E
	LDA.b #!Define_SMW_Sound1DFC_LemmyWendyLandInLava	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$50
	STA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_SinkingInLavaTimer,x
	JSL.l SMW_DespawnNonBossSprites_Main	; Kill all sprites
CODE_01FB6E:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfXPosLo
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfYPosLo
	JMP.w CODE_01FC0E

CODE_01FB7B:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$1F
	ORA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_BallThrowAnimationTimer,x
	BNE.b CODE_01FB99
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	PHA
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	PLA
	CMP.w !RAM_SMW_NorSpr_FacingDirection,x
	BEQ.b CODE_01FB99
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
CODE_01FB99:
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	LDA.b !RAM_SMW_Misc_M7RotationLo
	BPL.b CODE_01FBA4
	CLC
	ADC.b #$08
CODE_01FBA4:
	LSR
	LSR
	LSR
	LSR
	TAY
	STY.b !RAM_SMW_Misc_ScratchRAM00
	EOR.b #$FF
	INC
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_HurtAnimationTimer,x
	BNE.b CODE_01FBD9
	LDA.b !RAM_SMW_Misc_M7RotationHi
	BNE.b CODE_01FBC9
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.b #$78
	BCC.b CODE_01FBC5
	LDA.b #$FF
	BRA.b CODE_01FBEE

CODE_01FBC5:
	LDA.b #$01
	BRA.b CODE_01FBEE

CODE_01FBC9:
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.b #$78
	BCS.b CODE_01FBD5
	LDA.b #$01
	BRA.b CODE_01FBEE

CODE_01FBD5:
	LDA.b #$FF
	BRA.b CODE_01FBEE

CODE_01FBD9:
	LDA.b !RAM_SMW_Misc_M7RotationHi
	BNE.b CODE_01FBE7
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w HurtXSpeed+$08,y
	EOR.b #$FF
	INC
	BRA.b CODE_01FBEC

CODE_01FBE7:
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w HurtXSpeed+$08,y
CODE_01FBEC:
	ASL
	ASL
CODE_01FBEE:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b CODE_01FBFA
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
CODE_01FBFA:
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LSR
	LSR
	AND.b #$0F
	TAY
	LDA.w WalkingAnimationFrames,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
CODE_01FC08:
	JSR.w CODE_01FD50
	JSR.w CODE_01FC62
CODE_01FC0E:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_HurtAnimationTimer,x
	BNE.b CODE_01FC4E
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	PHA
	LDY.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BEQ.b CODE_01FC2A
	CPY.b #$08
	BCC.b CODE_01FC25
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_01FC25:
	LDA.b #$06
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
CODE_01FC2A:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_BallThrowAnimationTimer,x
	BEQ.b CODE_01FC46
	PHA
	LSR
	LSR
	LSR
	TAY
	LDA.w ThrowingAnimationFrames,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	PLA
	CMP.b #$28
	BNE.b CODE_01FC46
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01FC46
	JSR.w ThrowBall			; Throw ball
CODE_01FC46:
	JSR.w GFXRt
	PLA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	RTS

CODE_01FC4E:
	CMP.b #$10
	BCC.b CODE_01FC5A
CODE_01FC52:
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JMP.w GFXRt

CODE_01FC5A:
	CMP.b #$08
	BCC.b CODE_01FC52
	JSR.w InShellGFXRt
Return01FC61:
	RTS

CODE_01FC62:
	LDA.b !RAM_SMW_Player_CurrentState
	CMP.b #!Define_SMW_PlayerState01_PowerDown
	BCS.b Return01FC61
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_FellOffPlatformFlag,x
	BNE.b Return01FC61
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.b #$20
	BCC.b CODE_01FC77
	CMP.b #$D8
	BCC.b CODE_01FC84
CODE_01FC77:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfXPosLo
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfYPosLo
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	INC.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_FellOffPlatformFlag,x
CODE_01FC84:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfXPosLo
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfYPosLo
	CLC
	ADC.b #$60
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$0C
	STA.b !RAM_SMW_Misc_ScratchRAM03
	STZ.b !RAM_SMW_Misc_ScratchRAM08
	STZ.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b !RAM_SMW_Player_OnScreenPosXLo
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b #$0C
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b #$0E
	STA.b !RAM_SMW_Misc_ScratchRAM07
	STZ.b !RAM_SMW_Misc_ScratchRAM0A
	STZ.b !RAM_SMW_Misc_ScratchRAM0B
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b CODE_01FD0A
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_DisablePlayerInteractionTimer,x
	BNE.b Return01FD09
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_DisablePlayerInteractionTimer,x
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_01FD05
	LDA.b #!Define_SMW_Sound1DFC_StunEnemy	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	JSL.l SMW_BoostMarioSpeed_Main
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfXPosLo
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfYPosLo
	SEC
	SBC.b #$10
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	STZ.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	JSL.l SMW_SpawnContactEffectFromAbove_Main
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_HurtAnimationTimer,x
	BNE.b Return01FD09
	LDA.b #$18
	STA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_HurtAnimationTimer,x
	RTS

CODE_01FD05:
	JSL.l SMW_DamagePlayer_Hurt
Return01FD09:
	RTS

CODE_01FD0A:
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot+$01			; Glitch: Another instance of an extended sprite slot check loop starting at 0A 
CODE_01FD0C:
	STY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_ExtSpr05_MarioFireball
	BNE.b CODE_01FD4A
	LDA.w !RAM_SMW_ExtSpr_XPosLo,y
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STZ.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_ExtSpr_YPosLo,y
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM05
	STZ.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM07
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b CODE_01FD4A
	LDA.b #!Define_SMW_SpriteID_ExtSpr01_SmokePuff	; \ Extended sprite = Smoke puff
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b #$0F
	STA.w !RAM_SMW_ExtSpr01_SmokePuff_DespawnTimer,y
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_HurtAnimationTimer,x
CODE_01FD4A:
	DEY
	CPY.b #!Define_SMW_MaxExtendedSpriteSlot-$02
	BNE.b CODE_01FD0C
	RTS

CODE_01FD50:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$2F
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetHi
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_M7RotationLo
	EOR.w #$01FF
	INC
	AND.w #$01FF
	STA.b !RAM_SMW_Misc_M7RotationLo
	SEP.b #$20			; A->8
	PHX
	JSL.l SMW_CheckForTiltingPlatformCollision_Main
	PLX
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_M7RotationLo
	EOR.w #$01FF
	INC
	AND.w #$01FF
	STA.b !RAM_SMW_Misc_M7RotationLo
	SEP.b #$20			; A->8
	RTS

ThrowingAnimationFrames:
	db $04,$0B,$0B,$0B,$0B,$0A,$0A,$09
	db $09,$08,$08,$07,$04,$05,$05,$05

BallXDisp:
	db $08,$F8

ThrowBall:
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$06	; \ Find an open sprite index
CODE_01FDA9:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b GenerateBall
	DEY
	BPL.b CODE_01FDA9
	RTS

GenerateBall:
	LDA.b #!Define_SMW_Sound1DF9_YoshiSpit	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr0A7_IggyBall	; \ Sprite to throw = Ball
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	PHX				; \ Before: X must have index of sprite being generated
	TYX				; | Routine clears *all* old sprite values...
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; | ...and loads in new values for the 6 main sprite tables
	PLX
	PHX				; Push Iggy's sprite index
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; \ Ball's direction = Iggy'direction
	STA.w !RAM_SMW_NorSpr0A7_IggyBall_HorizontalMovementDirection,y
	TAX				; X = Ball's direction
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfXPosLo	; \ Set Ball X position
	SEC
	SBC.b #$08
	ADC.w BallXDisp,x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfYPosLo	; \ Set Ball Y position
	SEC
	SBC.b #$18
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.b #$00
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PLX				; X = Iggy's sprite index
	RTS

XDisp:
	db $F7,$FF,$00,$F8
	db $F7,$FF,$00,$F8
	db $F8,$00,$00,$F8
	db $FB,$03,$00,$F8
	db $F8,$00,$00,$F8
	db $FA,$02,$00,$F8
	db $00,$00,$F8,$00
	db $00,$F8,$00,$F8
	db $00,$00,$00,$00
	db $FB,$F8,$00,$F8
	db $F4,$F8,$00,$F8
	db $00,$F8,$00,$F8

	db $09,$09,$00,$10
	db $09,$09,$00,$10
	db $08,$08,$00,$10
	db $05,$05,$00,$10
	db $08,$08,$00,$10
	db $06,$06,$00,$10
	db $00,$08,$08,$08
	db $00,$10,$00,$10
	db $00,$08,$00,$08
	db $05,$10,$00,$10
	db $0C,$10,$00,$10
	db $00,$10,$00,$10

YDisp:
	db $FA,$F2,$00,$09
	db $F9,$F1,$00,$08
	db $F8,$F0,$00,$08
	db $FE,$F6,$00,$08
	db $FC,$F4,$00,$08
	db $FF,$F7,$00,$08
	db $00,$F0,$F8,$F0
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $FC,$00,$00,$00
	db $F9,$00,$00,$00
	db $00,$08,$00,$08

; Sprite tilemap: Larry/Iggy
Tiles:
	db $00,$0C,$02,$0A
	db $00,$0C,$22,$0A
	db $00,$0C,$20,$0A
	db $00,$0C,$20,$0A
	db $00,$0C,$20,$0A
	db $00,$0C,$20,$0A
	db $24,$1C,$04,$1C
	db $0E,$0D,$0E,$0D
	db $0E,$1D,$0E,$1D
	db $4A,$0D,$0E,$0D
	db $4A,$0D,$0E,$0D
	db $20,$0A,$20,$0A

IggyTiles:
	db $06,$02,$08

TileSize:
	db $02,$00,$02,$00

; Iggy Koopa's Palette/GFX page/Priority/Flip
Prop:
	db $37,$3B

GFXRt:
	LDY.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	LDA.w Prop-$03,y
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	STY.b !RAM_SMW_Misc_ScratchRAM05
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	LSR
	ROR
	LSR
	AND.b #$40
	EOR.b #$40
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PHX
	LDX.b #$03
CODE_01FEDE:
	PHX
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	BEQ.b CODE_01FEEE
	TXA
	CLC
	ADC.b #$30
	TAX
CODE_01FEEE:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfXPosLo
	SEC
	SBC.b #$08
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLX
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfYPosLo
	CLC
	ADC.b #$60
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM05
	CPX.b #$03
	BNE.b CODE_01FF22
	CMP.b #$05					;\ Note: If the current sprite is Iggy, then this will set the head graphic to Iggy's.
	BCS.b CODE_01FF22				;| However, it won't change his hair to how you see it in the ending
	LSR						;| To fix that, you'd have to rearrange some of the tiles in GFX 25 so that the Larry's hair tiles are 02 and 03, remove this LSR and use the free byte for IggyTiles.
	TAX						;|
	LDA.w IggyTiles,x				;|
	STA.w SMW_OAMBuffer[$40].Tile,y			;/
CODE_01FF22:
	LDA.w SMW_OAMBuffer[$40].Tile,y
	CMP.b #$4A
	LDA.b !RAM_SMW_Misc_ScratchRAM0D
	BCC.b CODE_01FF2D
	LDA.b #$35			;  Iggy ball palette
CODE_01FF2D:
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
	AND.b #$03
	TAX
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
	PLX
	DEX
	BPL.b CODE_01FEDE
	PLX
	LDY.b #$FF
	LDA.b #$03
	JSR.w SMW_FinishOAMWrite_Sub
	RTS

; Sprite tilemap: Larry/Iggy shell
InShellTiles:
	db $2C,$2E,$2C,$2E

InShellProp:
	db $00,$00,$40,$00

InShellGFXRt:
	PHX
	LDY.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	LDA.w Prop-$03,y
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDY.b #$70
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfXPosLo
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_IggyLarry_CopyOfYPosLo
	CLC
	ADC.b #$60
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	AND.b #$03
	TAX
	LDA.w InShellTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$30
	ORA.w InShellProp,x
	ORA.b !RAM_SMW_Misc_ScratchRAM0D
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLX
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr029_KoopaKid_Status08_MortonRoyLudwig(Address)
namespace SMW_NorSpr029_KoopaKid_Status08_MortonRoyLudwig
%InsertMacroAtXPosition(<Address>)

DATA_01CD99:
	db (SMW_InitializeMode7TilemapsAndPalettes_TilemapData_Morton-SMW_InitializeMode7TilemapsAndPalettes_TilemapData)/$10
	db (SMW_InitializeMode7TilemapsAndPalettes_TilemapData_Roy-SMW_InitializeMode7TilemapsAndPalettes_TilemapData)/$10
	db (SMW_InitializeMode7TilemapsAndPalettes_TilemapData_Ludwig-SMW_InitializeMode7TilemapsAndPalettes_TilemapData)/$10

DATA_01CD9C:
	db $00
	db $01
	db $02
	db $03
	db $04
	db $05
	db $06
	db $07
	db $08

DATA_01CDA5:
	db $00,$80

GetDrawInfo:
	JSR.w SMW_GetDrawInfo_Bank01
	RTS

Main:
	STZ.w !RAM_SMW_Player_FreezePlayerFlag
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	CMP.b #$1B
	BCS.b CODE_01CDD5
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	CMP.b #$08
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	LDA.w DATA_01CDA5,y
	BCS.b CODE_01CDC4
	EOR.b #$80
CODE_01CDC4:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	LDA.w DATA_01CD99,y
	LDY.w !RAM_SMW_NorSpr_AnimationFrame,x
	CLC
	ADC.w DATA_01CD9C,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
CODE_01CDD5:
	STA.w !RAM_SMW_Misc_Mode7TilemapIndex
	JSL.l SMW_UpdateMode7SpriteAnimations_Main
	JSR.w GetDrawInfo
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01CE3D
	JSR.w CODE_01D2A8
	JSR.w CODE_01D3B1
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_Mode7RoomToLoad,x
	CMP.b #$01
	BEQ.b CODE_01CE0B
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_Ludwig_WaitBeforeShootingFire,x
	BNE.b CODE_01CE0B
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	PHA
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	PLA
	CMP.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	BEQ.b CODE_01CE0B
	LDA.b #$10			; \ Set turning timer
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
CODE_01CE0B:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

StatePtrs:
	dw CODE_01CE1E
	dw CODE_01CE3E
	dw State02_Normal
	dw State03_Hurt
	dw State04_Dying
	dw State05_ActivateLevelEnd

CODE_01CE1E:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_Mode7RoomToLoad,x
	CMP.b #$01
	BNE.b CODE_01CE34
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	INC.w !RAM_SMW_Sprites_MortonAndRoyLeftPillarStatus
	STZ.w !RAM_SMW_Sprites_MortonAndRoyLeftPillarYPosition
	INC.b !RAM_SMW_Flag_SpritesLocked
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
	RTS

CODE_01CE34:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b #$7E
	BCC.b Return01CE3D
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
Return01CE3D:
	RTS

; Change [64 7B] to [EA EA] in order to prevent Mario from slowing down when
; Ludwig appears.
CODE_01CE3E:
	STZ.b !RAM_SMW_Player_XSpeed
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$40
	BPL.b CODE_01CE4C
	CLC
	ADC.b #$03
CODE_01CE4C:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w CODE_01D0C0
	BCC.b Return01CE3D
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
	LDA.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	CMP.b #$02
	BCC.b Return01CE3D
	JMP.w CODE_01CEA8

State02_Normal:
	LDA.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	JSL.l SMW_ExecutePtr_Absolute

AttackRoutinePtrs:
	dw ProcessMortonsAttacks
	dw ProcessRoysAttacks
	dw ProcessLudwigsAttacks

ProcessLudwigsAttacks:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_AttackPointer,x
	JSL.l SMW_ExecutePtr_Absolute

Ptrs01CE72:
	dw LudwigAttack00_ShootFire
	dw LudwigAttack01_InShell
	dw LudwigAttack02_Jump

LudwigAttack00_ShootFire:
	STZ.b !RAM_SMW_Misc_M7RotationLo
	STZ.b !RAM_SMW_Misc_M7RotationHi
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	BEQ.b CODE_01CEA5
	LDY.b #$03
	AND.b #$30
	BNE.b CODE_01CE88
	INY
CODE_01CE88:
	TYA
	LDY.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BEQ.b CODE_01CE90
	LDA.b #$05
CODE_01CE90:
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	AND.b #$3F
	CMP.b #$2E
	BNE.b Return01CEA4
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr029_KoopaKid_Ludwig_WaitBeforeShootingFire,x
	JSR.w CODE_01D059
Return01CEA4:
	RTS

CODE_01CEA5:
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_AttackPointer,x
CODE_01CEA8:
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	RTS

; Ludwig's shell speed
LudwigMaxXSpeed:
	db $30,$D0

DATA_01CEB0:
	db $1B,$1C,$1D,$1B

; Ludwig's horizontal jump distance
DATA_01CEB4:
	db $14,$EC

LudwigAttack01_InShell:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	BNE.b CODE_01CEDC
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA
	CMP.w !RAM_SMW_NorSpr_XPosHi,x
	BNE.b CODE_01CEDC
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_AttackPointer,x
	LDA.w DATA_01CEB4,y
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_RightWallXPos,x
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	LDA.b #$60
	STA.w !RAM_SMW_NorSpr029_KoopaKid_Ludwig_JumpRotationTimer,x
	LDA.b #$D8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	RTS

CODE_01CEDC:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w LudwigMaxXSpeed,y
	BEQ.b CODE_01CEEC
	CLC
	ADC.w SMW_NorSprXXX_ParachutingEnemy_Status08_DATA_01D4E7,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01CEEC:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w DATA_01CEB0,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

LudwigAttack02_Jump:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	BEQ.b CODE_01CF1C
	DEC
	BNE.b CODE_01CF0F
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_Ludwig_JumpingXSpeed,x
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #!Define_SMW_Sound1DFC_Springboard	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_01CF0F:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b Return01CF1B
	BPL.b CODE_01CF19
	INC.b !RAM_SMW_NorSpr_XSpeed,x
	INC.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01CF19:
	DEC.b !RAM_SMW_NorSpr_XSpeed,x
Return01CF1B:
	RTS

CODE_01CF1C:
	JSR.w CODE_01D0C0
	BCC.b CODE_01CF2F
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_01CF2F
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; \ Sprite Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x
	STZ.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_AttackPointer,x
	JMP.w CODE_01CEA8

CODE_01CF2F:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCS.b CODE_01CF44
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_01CF42
	CMP.b #$70
	BCS.b CODE_01CF44
CODE_01CF42:
	INC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01CF44:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_Ludwig_JumpRotationTimer,x
	BNE.b CODE_01CF4F
	LDA.b !RAM_SMW_Misc_M7RotationLo
	ORA.b !RAM_SMW_Misc_M7RotationHi
	BEQ.b CODE_01CF67
CODE_01CF4F:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	ASL
	LDA.b #$04
	LDY.b #$00
	BCC.b CODE_01CF5B
	; Ludwig jump left type modifier
	LDA.b #$FC
	DEY
CODE_01CF5B:
	CLC
	ADC.b !RAM_SMW_Misc_M7RotationLo
	STA.b !RAM_SMW_Misc_M7RotationLo
	TYA
	ADC.b !RAM_SMW_Misc_M7RotationHi
	AND.b #$01
	STA.b !RAM_SMW_Misc_M7RotationHi
CODE_01CF67:
	LDA.b #$06
	LDY.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_01CF79
	CPY.b #$08
	BCC.b CODE_01CF79
	LDA.b #$05
	CPY.b #$10
	BCC.b CODE_01CF79
	LDA.b #$02
CODE_01CF79:
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

State03_Hurt:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w CODE_01D0C0
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	BEQ.b CODE_01CFB7
	CMP.b #$40
	BCC.b CODE_01CF9E
	BEQ.b CODE_01CFC6
	LDY.b #$06
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$04
	BEQ.b CODE_01CF99
	INY
CODE_01CF99:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

CODE_01CF9E:
	LDY.w !RAM_SMW_UnusedRAM_7E18A6			; Optimization: This is not used
	LDA.b !RAM_SMW_Misc_M7AngleLo
	CMP.b #$20
	BEQ.b CODE_01CFA9
	INC.b !RAM_SMW_Misc_M7AngleLo
CODE_01CFA9:
	LDA.b !RAM_SMW_Misc_M7AngleHi
	CMP.b #$20
	BEQ.b CODE_01CFB1
	DEC.b !RAM_SMW_Misc_M7AngleHi
CODE_01CFB1:
	LDA.b #$07
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

CODE_01CFB7:
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
	LDA.b !RAM_SMW_NorSpr029_KoopaKid_KoopaKidType,x
	BEQ.b Return01CFC5
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_MoveWallsInwardTimer,x
Return01CFC5:
	RTS

CODE_01CFC6:
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_HitCounter,x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_HitCounter,x
	CMP.b #$03
	BCC.b Return01CFDF
CODE_01CFD0:
	LDA.b #!Define_SMW_Sound1DF9_KoopalingDead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
	LDA.b #$13
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
Return01CFDF:
	RTS

State04_Dying:
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	BEQ.b CODE_01CFFC
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b #$01
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	BCS.b CODE_01CFF1
	DEC.w !RAM_SMW_NorSpr_YPosHi,x
CODE_01CFF1:
	DEC.b !RAM_SMW_Misc_M7AngleHi
	TYA
	AND.b #$03
	BEQ.b CODE_01CFFA
	DEC.b !RAM_SMW_Misc_M7AngleLo
CODE_01CFFA:
	BRA.b CODE_01D00F

CODE_01CFFC:
	LDA.b !RAM_SMW_Misc_M7RotationLo
	CLC
	ADC.b #$06
	STA.b !RAM_SMW_Misc_M7RotationLo
	LDA.b !RAM_SMW_Misc_M7RotationHi
	ADC.b #$00
	AND.b #$01
	STA.b !RAM_SMW_Misc_M7RotationHi
	INC.b !RAM_SMW_Misc_M7AngleLo
	INC.b !RAM_SMW_Misc_M7AngleHi
CODE_01D00F:
	LDA.b !RAM_SMW_Misc_M7AngleHi
if ver_is_pal(!Define_Global_ROMToAssemble)
	CMP.b #$80
else
	CMP.b #$A0
endif
	BCC.b Return01D042
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BNE.b CODE_01D032
	LDA.b #!Define_SMW_SpriteID_SmokeSpr01_PuffOfSmoke
	STA.w !RAM_SMW_SmokeSpr_SpriteID
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SBC.b #$08
	STA.w !RAM_SMW_SmokeSpr_XPosLo
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	ADC.b #$08
	STA.w !RAM_SMW_SmokeSpr_YPosLo
	LDA.b #$1B
	STA.w !RAM_SMW_SmokeSpr_Timer
CODE_01D032:
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	JSL.l SMW_UpdateMode7SpriteAnimations_Main
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
Return01D042:
	RTS

State05_ActivateLevelEnd:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	BNE.b Return01D056
	INC.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	DEC.w !RAM_SMW_Timer_EndLevel
	LDA.b #!Define_SMW_LevelMusic_PassedBoss
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
Return01D056:
	RTS

DATA_01D057:
	db $FF,$F1

CODE_01D059:
	LDA.b #!Define_SMW_Sound1DFC_FireSpit	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$07
CODE_01D060:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_01D069
	DEY
	BPL.b CODE_01D060
	RTS

CODE_01D069:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr034_LudwigFireball
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$03
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	PHX
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_01D057,x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	ADC.b #$FF
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	PLX
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
	PHX
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	STA.w !RAM_SMW_NorSpr_FacingDirection,y
	TAX
	LDA.w DATA_01D0BE,x
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,y
	PLX
	RTS

; X Speed of Ludwig's Fireball (Right)
DATA_01D0BE:
	db $20,$E0

CODE_01D0C0:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_01D0DC
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	BNE.b CODE_01D0DC
	LDA.b !RAM_SMW_Misc_M7AngleHi
	LSR
	TAY
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.w DATA_01D0DE-$08,y
	BCC.b CODE_01D0DC
	LDA.w DATA_01D0DE-$08,y
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	RTS

CODE_01D0DC:
	CLC
	RTS

DATA_01D0DE:
	db $80,$83,$85,$88,$8A,$8B,$8D,$8F
	db $90,$91,$91,$92,$92,$93,$93,$94
	db $94,$95,$95,$96,$96,$97,$97,$98
	db $98,$98,$99,$99,$9A,$9A,$9B,$9B
	db $9C,$9C,$9C,$9C,$9D,$9D,$9D,$9D
	db $9E,$9E,$9E,$9E,$9E,$9F,$9F,$9F
	db $9F,$9F,$9F,$9F,$9F,$9F,$9F,$9F

ProcessMortonsAttacks:
ProcessRoysAttacks:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_AttackPointer,x
	JSL.l SMW_ExecutePtr_Absolute

MortonRoyAttackPtrs:
	dw MortonRoyAttack00_Walk
	dw MortonRoyAttack01_Drop

Return01D121:
	RTS ; Unused

; Morton and Roy's speed for first hit, left.
DATA_01D122:
	db $F0,$00,$10,$00,$F0,$00,$10,$00
	; Morton and Roy's speed for third hit, left.
	db $E8,$00,$18,$00

DATA_01D12E:
	db $00,$F0,$00,$10,$00,$F0,$00,$10
	db $00,$E8,$00,$18,$26,$26,$D8,$D8

DATA_01D13E:
	db $90,$30,$30,$90

DATA_01D142:
	db $00,$01,$02,$01

MortonRoyAttack00_Walk:
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_HitCounter,x
	CPY.b #$02
	BCS.b CODE_01D151
	LSR
CODE_01D151:
	AND.b #$03
	TAY
	LDA.w DATA_01D142,y
	LDY.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BEQ.b CODE_01D15E
	LDA.b #$05
CODE_01D15E:
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_MoveWallsInwardTimer,x
	BEQ.b CODE_01D17C
if defined("Define_SMW_SA1")
	; SA-1 Pack: Hijacked because there are no indirect addressing modes for
	; LDY.
	JSL.l X_LOW_REMAP1
else
	LDY.b !RAM_SMW_NorSpr_XPosLo,x
	CPY.b #$50
endif
	BCC.b CODE_01D17C
	CPY.b #$80
	BCS.b CODE_01D17C
	DEC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_MoveWallsInwardTimer,x
	LSR
	BCS.b CODE_01D17C
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_LeftWallXPos,x
	DEC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_RightWallXPos,x
CODE_01D17C:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_LeftWallXPos,x
	STA.b !RAM_SMW_Misc_ScratchRAM05
	STA.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_RightWallXPos,x
	STA.b !RAM_SMW_Misc_ScratchRAM07
	STA.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM09
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_M7RotationLo
	ASL
	BEQ.b CODE_01D19A
	JMP.w CODE_01D224

CODE_01D19A:
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_MovementDirection,x
	TYA
	LSR
	BCS.b CODE_01D1B5
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CPY.b #$00
	BNE.b CODE_01D1AE
	CMP.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_LeftWallXPos,x
	BCC.b CODE_01D215
	BRA.b CODE_01D1D8

CODE_01D1AE:
	CMP.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_RightWallXPos,x
	BCS.b CODE_01D215
	BRA.b CODE_01D1D8

CODE_01D1B5:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	BNE.b CODE_01D1BE
	INY
	INY
	INY
	INY
CODE_01D1BE:
	LDA.w !RAM_SMW_Misc_ScratchRAM05,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_MovementDirection,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CPY.b #$03
	BEQ.b ADDR_01D1D3
	CMP.w DATA_01D13E,y
	BCC.b CODE_01D215
	BRA.b CODE_01D1D8

ADDR_01D1D3:
	CMP.w DATA_01D13E,y
	BCS.b CODE_01D215
CODE_01D1D8:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_HitCounter,x
	CMP.b #$02
	BCC.b CODE_01D1E1
	LDA.b #$02
CODE_01D1E1:
	ASL
	ASL
	ADC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_MovementDirection,x
	TAY
	LDA.w DATA_01D122,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w DATA_01D12E,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_MovementDirection,x
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	BNE.b CODE_01D201
	EOR.b #$02
CODE_01D201:
	CMP.b #$02
	BNE.b Return01D214
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$10
	CMP.b #$20
	BCS.b Return01D214
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_AttackPointer,x
Return01D214:
	RTS

CODE_01D215:
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_MovementDirection,x
	CLC
	ADC.w DATA_01D23D,y
	AND.b #$03
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_MovementDirection,x
CODE_01D224:
	LDY.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	LDA.b !RAM_SMW_Misc_M7RotationLo
	CLC
	ADC.w DATA_01D239,y
	STA.b !RAM_SMW_Misc_M7RotationLo
	LDA.b !RAM_SMW_Misc_M7RotationHi
	ADC.w DATA_01D23B,y
	AND.b #$01
	STA.b !RAM_SMW_Misc_M7RotationHi
	RTS

; How fast Morton and Roy rotate when they're crawling on a wall or ceiling.
; By default FC and 04. The closer to 00, the slower it gets. Do not exceed
; above a difference of 80 (that is, don't make the first value 01-7F, and
; don't make the second value 81-FF). Using 00 isn't recommended either.
DATA_01D239:
	db $FC,$04

DATA_01D23B:
	db $FF,$00

DATA_01D23D:
	db $FF,$01

MortonRoyAttack01_Drop:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	BEQ.b CODE_01D25E
	CMP.b #$01
	BNE.b Return01D2A7
	STZ.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_AttackPointer,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_RotationDirection,x
	ASL
	EOR.b #$02
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_MovementDirection,x
	LDA.b #$0A			; \ Set turning timer
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	RTS

CODE_01D25E:
	LDA.b #$06
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$70
	BCS.b CODE_01D271
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01D271:
	LDA.b !RAM_SMW_Misc_M7RotationLo
	ORA.b !RAM_SMW_Misc_M7RotationHi
	BEQ.b CODE_01D286
	LDA.b !RAM_SMW_Misc_M7RotationLo
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_M7RotationLo
	LDA.b !RAM_SMW_Misc_M7RotationHi
	ADC.b #$00
	AND.b #$01
	STA.b !RAM_SMW_Misc_M7RotationHi
CODE_01D286:
	JSR.w CODE_01D0C0
	BCC.b Return01D2A7
	LDA.b #$20			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
	LDA.b !RAM_SMW_Player_InAirFlag
	BNE.b CODE_01D299
	LDA.b #$28			; \ Lock Mario in place
	STA.w !RAM_SMW_Timer_StunPlayer
CODE_01D299:
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$28
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	STZ.b !RAM_SMW_Misc_M7RotationLo
	STZ.b !RAM_SMW_Misc_M7RotationHi
Return01D2A7:
	RTS

CODE_01D2A8:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
	CMP.b #$03
	BCS.b Return01D318
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_Mode7RoomToLoad,x			;\ Note: This RAM address is either 00 or 01, so this will never branch.
	CMP.b #$03									;| Although, given some unused data in the init routine, perhaps this was a leftover for Wendy/Lemmy?
	BNE.b CODE_01D2BD								;/
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_AttackPointer,x			;\ Note: Morton/Roy/Ludwig don't have an attack state 03.
	CMP.b #$03									;| Change this to CMP.b #$02 to fix the oddity where you can jump on Ludwig's head while he is jumping and cause him to not enter his shell after his hurt animation ends.
	BCS.b Return01D318								;/
CODE_01D2BD:
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSR.w CODE_01D40B
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return01D318
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_DisableMarioContactTimer,x
	BNE.b Return01D318
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_DisableMarioContactTimer,x
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_01D319
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	CMP.b #$10
	BCS.b CODE_01D2E3
	CMP.b #$06
	BCS.b ADDR_01D31E
CODE_01D2E3:
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b #$08
	CMP.b !RAM_SMW_NorSpr_YPosLo_x
	BCS.b ADDR_01D31E
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoy_MovementDirection,x
	LSR
	BCS.b CODE_01D334
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return01D31D
	JSR.w CODE_01D351
	LDA.b #$D0
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b #!Define_SMW_Sound1DF9_Contact	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	CMP.b #$1B
	BCC.b CODE_01D379
ADDR_01D309:
	LDY.b #$20
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b #$08
	CMP.b !RAM_SMW_Player_XPosLo
	BMI.b ADDR_01D316
	LDY.b #$E0
ADDR_01D316:
	STY.b !RAM_SMW_Player_XSpeed
Return01D318:
	RTS

CODE_01D319:
	JSL.l SMW_DamagePlayer_Hurt
Return01D31D:
	RTS

ADDR_01D31E:
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b ADDR_01D32C
	LDA.b #$10
	STA.b !RAM_SMW_Player_YSpeed
	RTS

ADDR_01D32C:
	JSR.w ADDR_01D309
	LDA.b #$D0
	STA.b !RAM_SMW_Player_YSpeed
	RTS

CODE_01D334:
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_01D342
	LDA.b #$20
	STA.b !RAM_SMW_Player_YSpeed
	RTS

CODE_01D342:
	LDY.b #$20
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	BPL.b CODE_01D34A
	LDY.b #$E0
CODE_01D34A:
	STY.b !RAM_SMW_Player_XSpeed
	LDA.b #$B0
	STA.b !RAM_SMW_Player_YSpeed
	RTS

CODE_01D351:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	JSL.l SMW_SpawnContactEffectFromAbove_Main
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	RTS

CODE_01D379:
	LDA.b #$18
	STA.b !RAM_SMW_Misc_M7AngleLo
	PHX
	LDA.b !RAM_SMW_Misc_M7AngleHi
	LSR
	TAX
	LDA.b #$28
	STA.b !RAM_SMW_Misc_M7AngleHi
	LSR
	TAY
	LDA.w DATA_01D0DE-$08,y
	SEC
	SBC.w DATA_01D0DE-$08,x
	PLX
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; \ Sprite Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_PhaseTimer,x
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
	LDA.b #!Define_SMW_Sound1DFC_StunEnemy	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	RTS

CODE_01D3B1:
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_CurrentState,x
	CMP.b #$03
	BCS.b Return01D40A
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot+$01			; Glitch: $0A? Don't the extended sprite slots go from $00-$09?
CODE_01D3BA:
	STY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_ExtSpr05_MarioFireball
	BNE.b CODE_01D405
	LDA.w !RAM_SMW_ExtSpr_XPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ExtSpr_XPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w !RAM_SMW_ExtSpr_YPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_ExtSpr_YPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PHY
	JSR.w CODE_01D40B
	PLY
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b CODE_01D405
	LDA.b #!Define_SMW_SpriteID_ExtSpr01_SmokePuff	; \ Extended sprite = Smoke puff
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b #$0F
	STA.w !RAM_SMW_ExtSpr01_SmokePuff_DespawnTimer,y
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	; Counts fireball hits to Morton/Roy/Ludwig. Change to [80 06] to make
	; Morton/Roy/Ludwig immune to fireballs. Alternately, change to [FE 10 15
	; BD 10 15] to decouple their fireball HP from their stomp HP, so that they
	; don't die after 2+ fireballs and a single jump.
	INC.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_HitCounter,x
	LDA.w !RAM_SMW_NorSpr029_KoopaKid_MortonRoyLudwig_HitCounter,x
	CMP.b #$0C
	BCC.b CODE_01D405
	JSR.w CODE_01CFD0
CODE_01D405:
	DEY
	CPY.b #!Define_SMW_MaxExtendedSpriteSlot-$02
	BNE.b CODE_01D3BA
Return01D40A:
	RTS

CODE_01D40B:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	CMP.b #$69
	LDA.b #$08
	BCC.b CODE_01D42C
	ADC.b #$0A
CODE_01D42C:
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_RegularPiranhaPlant_Status01(Address)
namespace SMW_NorSprXXX_RegularPiranhaPlant_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	ASL.w !RAM_SMW_NorSpr_YXPPCCCT,x
	SEC
	ROR.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC				;|this sets up the sprite inside the pipe
	SBC.b #$10
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
ShiftSpriteDown:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Center sprite between two tiles
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_NorSpr_XPosLo_x
if defined("Define_SMW_SA1")
	JSL.l Y_LOW_REMAP3
else
	DEC.b !RAM_SMW_NorSpr_YPosLo,x				; LM: Sprite 52's (Moving ledge hole in ghost house) init routine is moved to here to fix a bug when placing it at the top of a subscreen (2.53+)
	LDA.b !RAM_SMW_NorSpr_YPosLo,x	;\
endif
	CMP.b #$FF			;| if that means fixing the Yhipos, so be it
	BNE.b Return			;|
	DEC.w !RAM_SMW_NorSpr_YPosHi,x	;/
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Main, SMW_NorSpr02A_UpsideDownPiranhaPlant_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_ShiftSpriteDown, SMW_NorSpr01A_ClassicPiranhaPlant_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_ShiftSpriteDown, SMW_NorSpr04B_PipeLakitu_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_ShiftSpriteDown, SMW_NorSpr04F_JumpingPiranhaPlant_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_ShiftSpriteDown, SMW_NorSpr050_FireSpittingJumpingPiranhaPlant_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSprStatus08_Return)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr01B_Football_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr02B_SumoLightning_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr02F_PortableSpringboard_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr034_LudwigFireball_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr036_Unused_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr03F_ParachuteGoomba_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr040_ParachuteBobOmb_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr045_DirectionalCoins_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr053_ThrowBlock_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr06A_CoinGameCloud_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr06D_InvisibleBlock_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr07C_PrincessPeach_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr07D_PBalloon_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr07E_FlyingRedCoin_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr07F_Flying1up_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr085_Unused_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr087_LakituCloud_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr08A_Bird_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr08B_FireplaceSmoke_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr08D_GhostHouseDoor_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr08E_WarpHole_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr09C_HammerBroPlatform_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0A1_BowserBowlingBall_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0A2_MechaKoopa_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0A7_IggyBall_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0A8_Blargg_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0AE_FishinBoo_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0AF_BooBlock_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0B2_FallingSpike_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0B5_SinkingFireball_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0B8_CarrotTopLiftUpperLeft_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0B9_MessageBox_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0BB_MovingCastleStone_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0BE_Swooper_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0C4_GreyFallingPlatform_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0C7_InvisibleMushroom_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr0C8_LightSwitch_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr02D_BabyYoshi_Status08_Main)			; Note: The Baby Yoshi's "Main" state is status 09 (Stunned), so the main routine will never execute.
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status01_Return, SMW_NorSpr053_ThrowBlock_Status08_Main) 			; Note: The Throw Block's "Main" state is status 09 (Stunned), so the main routine will never execute.
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSprXXX_RegularPiranhaPlant_Status08(Address)
namespace SMW_NorSprXXX_RegularPiranhaPlant_Status08
%InsertMacroAtXPosition(<Address>)

; Speed of piranha plant (in pipe, going up, staying up, going down).
YSpeed:
	db $00,$F0,$00,$10

PhaseTimers:
	db $20,$30,$20,$30

Main:
	LDA.w !RAM_SMW_NorSprXXX_RegularPiranhaPlant_PlayerIsCloseFlag,x	; \ Don't draw the sprite if in pipe and Mario naerby
	BNE.b CODE_018E9A
	LDA.b !RAM_SMW_Sprites_TilePriority	; \ Set sprite to go behind objects
	PHA				; | for the graphics routine
	LDA.w !RAM_SMW_NorSpr_OnYoshisTongue,x
	BNE.b CODE_018E87
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_018E87:
	JSR.w SMW_GenericGFXRtDraw2Tiles16x16sStacked_Sub	; Draw the sprite
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; \ Modify the palette and page of the stem
	LDA.w SMW_OAMBuffer[$42].Prop,y
	AND.b #$F1
	ORA.b #$0B
	STA.w SMW_OAMBuffer[$42].Prop,y
	PLA				; \ Restore value of $64
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_018E9A:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return018EC7
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	LDA.w !RAM_SMW_NorSprXXX_RegularPiranhaPlant_PlayerIsCloseFlag,x	; \ Don't don't process interactions if in pipe and Mario nearby
	BNE.b CODE_018EAC
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
CODE_018EAC:
	LDA.b !RAM_SMW_NorSprXXX_RegularPiranhaPlant_CurrentState,x	; \ Y = Piranha state
	AND.b #$03
	TAY
	LDA.w !RAM_SMW_NorSprXXX_RegularPiranhaPlant_PhaseTimer,x	; \ Change state if it's time
	BEQ.b ChangePiranhaState
	LDA.w YSpeed,y			; Load Y speed
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached	; \ Invert speed if upside-down piranha
	CPY.b #!Define_SMW_SpriteID_NorSpr02A_UpsideDownPiranhaPlant
	BNE.b CODE_018EC2
	EOR.b #$FF
	INC
CODE_018EC2:
	STA.b !RAM_SMW_NorSpr_YSpeed,x	; Store Y Speed
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y	; Update position based on speed
Return018EC7:
	RTS

ChangePiranhaState:
	LDA.b !RAM_SMW_NorSprXXX_RegularPiranhaPlant_CurrentState,x	; \ $00 = Sprite state (00 - 03)
	AND.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM00
	; Replace D0 with 80 to make the classic and upsidedown piranha plants keep
	; coming out of the pipe even if Mario is near or on top of the sprite.
	BNE.b CODE_018EE1		; \ If the piranha is in the pipe (State 0)...
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X	; | ...check if Mario is nearby...
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$1B
	CMP.b #$37
	LDA.b #$01
	STA.w !RAM_SMW_NorSprXXX_RegularPiranhaPlant_PlayerIsCloseFlag,x	; | ...and set $1594,x if so
	BCC.b Return018EEE
CODE_018EE1:
	STZ.w !RAM_SMW_NorSprXXX_RegularPiranhaPlant_PlayerIsCloseFlag,x
	LDY.b !RAM_SMW_Misc_ScratchRAM00	; \ Set time in state
	LDA.w PhaseTimers,y
	STA.w !RAM_SMW_NorSprXXX_RegularPiranhaPlant_PhaseTimer,x
	INC.b !RAM_SMW_NorSprXXX_RegularPiranhaPlant_CurrentState,x	; Go to next state
Return018EEE:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status08_Main, SMW_NorSpr01A_ClassicPiranhaPlant_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_RegularPiranhaPlant_Status08_Main, SMW_NorSpr02A_UpsideDownPiranhaPlant_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr02B_SumoLightning_Status08(Address)
namespace SMW_NorSpr02B_SumoLightning_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr02C_YoshiEgg_Status01(Address)
namespace SMW_NorSpr02C_YoshiEgg_Status01
%InsertMacroAtXPosition(<Address>)

; Colours of Yoshi Eggs (Red, Blue, Yellow, Blue)
EggPalette:
	db $09,$07,$05,$07

Main:
;$018339
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\
	LSR				;| Color of the yoshi egg depends on the
	LSR				;| X position of it
	LSR				;|
	LSR				;|
	AND.b #$03			;|
	TAY				;|
	LDA.w EggPalette,y		;|
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x	;/
	INC.w !RAM_SMW_NorSpr02C_YoshiEgg_DontHatchYetFlag,x	;Also, the egg can't be stomped
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr02C_YoshiEgg_Status08(Address)
namespace SMW_NorSpr02C_YoshiEgg_Status08
%InsertMacroAtXPosition(<Address>)

; GFX page of the tiles used in the Yoshi egg hatching animation ($01F760).
DATA_01F75C:
	db $00,$01,$01,$01

; Tile numbers for each frame in the Yoshi egg hatching animation. Read from
; right to left as (intact, breaking, breaking, puff of smoke). Change
; alongside $019C17 and $01F794 to completely remap the Yoshi egg tiles.
YoshiEggTiles:
	db $62,$02,$02,$00

Main:
	LDA.w !RAM_SMW_NorSpr02C_YoshiEgg_DontHatchYetFlag,x
	BEQ.b CODE_01F799
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01
	BNE.b CODE_01F78D
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$20
	CMP.b #$40
	BCS.b CODE_01F78D
	STZ.w !RAM_SMW_NorSpr02C_YoshiEgg_DontHatchYetFlag,x
	JSL.l SMW_PrepareToHatchNormalSpriteYoshiEgg_Main
	LDA.b #$2D
	LDY.w !RAM_SMW_Yoshi_StrayYoshiFlag
	BEQ.b CODE_01F78A
	LDA.b #$78
CODE_01F78A:
	STA.w !RAM_SMW_NorSpr02C_YoshiEgg_ContentsOfEgg,x
CODE_01F78D:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$00
	STA.w SMW_OAMBuffer[$40].Tile,y
	RTS

CODE_01F799:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	BEQ.b CODE_01F7C2
	LSR
	LSR
	LSR
	TAY
	LDA.w YoshiEggTiles,y
	PHA
	LDA.w DATA_01F75C,y
	PHA
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w SMW_OAMBuffer[$40].Prop,y
	AND.b #$FE
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
	STA.w SMW_OAMBuffer[$40].Tile,y
	RTS

CODE_01F7C2:
	JSR.w CODE_01F7C8
	JMP.w CODE_01F83D

CODE_01F7C8:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01
	BNE.b Return01F82C
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PHX
	LDY.b #$03
	LDX.b #!Define_SMW_MaxMinorExtendedSpriteSlot
CODE_01F7DF:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,x
	BEQ.b CODE_01F7F4
CODE_01F7E4:
	DEX
	BPL.b CODE_01F7DF
	DEC.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
	BPL.b CODE_01F7F1
	LDA.b #!Define_SMW_MaxMinorExtendedSpriteSlot
	STA.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
CODE_01F7F1:
	LDX.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
CODE_01F7F4:
	LDA.b #!Define_SMW_SpriteID_MExtSpr03_EggShell
	STA.w !RAM_SMW_MExtSpr_SpriteID,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w EggShellInitialXPosLo,y
	STA.w !RAM_SMW_MExtSpr_XPosLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.w EggShellInitialYPosLo,y
	STA.w !RAM_SMW_MExtSpr_YPosLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_MExtSpr_YPosHi,x
	LDA.w EggShellInitialYSpeed,y
	STA.w !RAM_SMW_MExtSpr_YSpeed,x
	LDA.w EggShellInitialXSpeed,y
	STA.w !RAM_SMW_MExtSpr_XSpeed,x
	TYA
	ASL
	ASL
	ASL
	ASL
	ASL
	ASL
	ORA.b #$28
	STA.w !RAM_SMW_MExtSpr_Timer,x
	DEY
	BPL.b CODE_01F7E4
	PLX
Return01F82C:
	RTS

EggShellInitialYPosLo:
	db $00,$00,$08,$08

EggShellInitialXPosLo:
	db $00,$08,$00,$08

EggShellInitialYSpeed:
	db $E8,$E8,$F4,$F4

EggShellInitialXSpeed:
	db $FA,$06,$FD,$03

CODE_01F83D:
	LDA.w !RAM_SMW_NorSpr02C_YoshiEgg_ContentsOfEgg,x
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr035_Yoshi
	BEQ.b CODE_01F86C
	CMP.b #!Define_SMW_SpriteID_NorSpr02D_BabyYoshi
	BNE.b CODE_01F867
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	AND.b #$0E
	PHA
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	AND.b #$F1
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	RTS

CODE_01F867:
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	RTS

CODE_01F86C:
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	JMP.w SMW_ProcessStunnedNormalSprite_StunnedBabyYoshi_CODE_01A2B5
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_PrepareToHatchNormalSpriteYoshiEgg(Address)
namespace SMW_PrepareToHatchNormalSpriteYoshiEgg
%InsertMacroAtXPosition(<Address>)

; Small routine used when Yoshi Egg hatches. Sets $14C8,x to $08, $1540,x to
; $20, and plays the 'egg hatching' sound effect.
Entry2:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
Main:
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	LDA.b #!Define_SMW_Sound1DFC_EggHatch	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr02D_BabyYoshi_Status01(Address)
namespace SMW_NorSpr02D_BabyYoshi_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr02D_BabyYoshi_Status01_Main, SMW_NorSpr080_Key_Status01_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_WallFollowers_Status01(Address)
namespace SMW_NorSprXXX_WallFollowers_Status01
%InsertMacroAtXPosition(<Address>)

DATA_0183EF:
	db $08,$00,$08			; uh, okay.... one byte, great.

SpikeTopEntry:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X	;\
	TYA				;|
	EOR.b #$01			;|Take the opposite of whichever way mario
	ASL				;|is and do set the speeds for going up/down walls
	ASL				;|using that data (Urchin init routine used)
	ASL				;|
	ASL				;|
	JSR.w CODE_01841D		;/
	STZ.w !RAM_SMW_NorSpr_InLiquidFlag,x	; don't make any little sprites follow it
	BRA.b CODE_01840E

WallFollowUrchinEntry:
if defined("Define_SMW_SA1")
	JML.l Y_LOW_REMAP1
else
	INC.b !RAM_SMW_NorSpr_YPosLo,x
	BNE.b InitFuzzBallSpark		;| handle if it is on a Ypos boundary
endif
	INC.w !RAM_SMW_NorSpr_YPosHi,x
InitFuzzBallSpark:
SparkyEntry:
HotheadEntry:
	JSR.w CODE_01841B
CODE_01840E:
	LDA.w !RAM_SMW_NorSprXXX_WallFollowers_RotationDirection,x	;\
	EOR.b #$10			;| invert the Y direction, or something like that
	STA.w !RAM_SMW_NorSprXXX_WallFollowers_RotationDirection,x	;/
	LSR				;\
	LSR				;|scale it down and then store it to a misc. sprite table
	STA.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x	;/
	RTS

FixedUrchinEntry:
WallDetectUrchinEntry:
CODE_01841B:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
CODE_01841D:
	LDY.b #$00
	AND.b #$10
	STA.w !RAM_SMW_NorSprXXX_WallFollowers_RotationDirection,x
	BNE.b CODE_018427
	INY
CODE_018427:
	LDA.w DATA_0183EF,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w DATA_0183EF+$01,y		;\ again, set the yspeed to either 00 or 08.
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
RipVanFishEntry:
	INC.w !RAM_SMW_NorSpr_InLiquidFlag,x	; increment the sprite follower (bubbles?)
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status01_SpikeTopEntry, SMW_NorSpr02E_SpikeTop_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status01_FixedUrchinEntry, SMW_NorSpr03A_FixedUrchin_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status01_WallDetectUrchinEntry, SMW_NorSpr03B_WallDetectUrchin_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status01_WallFollowUrchinEntry, SMW_NorSpr03C_WallFollowUrchin_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status01_RipVanFishEntry, SMW_NorSpr03D_RipVanFish_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status01_SparkyEntry, SMW_NorSpr0A5_Sparky_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status01_HotheadEntry, SMW_NorSpr0A6_Hothead_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSprXXX_WallFollowers_Status08(Address)
namespace SMW_NorSprXXX_WallFollowers_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	PHB
	LDA.b #Bank02>>16		;and again..
	PHA
	PLB
	JSL.l Bank02
	PLB
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status08_Main, SMW_NorSpr02E_SpikeTop_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status08_Main, SMW_NorSpr03A_FixedUrchin_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status08_Main, SMW_NorSpr03B_WallDetectUrchin_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status08_Main, SMW_NorSpr03C_WallFollowUrchin_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status08_Main, SMW_NorSpr0A5_Sparky_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallFollowers_Status08_Main, SMW_NorSpr0A6_Hothead_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr02F_PortableSpringboard_Status08(Address)
namespace SMW_NorSpr02F_PortableSpringboard_Status08
%InsertMacroAtXPosition(<Address>)

AnimationFrames:
	db $00,$01,$02,$02,$02,$01,$01,$00
	db $00

PlayerYDisp:
	db $1E,$1B,$18,$18,$18,$1A,$1C,$1D
	db $1E

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_01E62A
	JMP.w CODE_01E6F0

CODE_01E62A:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01E638
	JSR.w SMW_MakeStunnedSpriteBounceOrSlowDownOnGround_Main
CODE_01E638:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b CODE_01E649
	JSR.w SMW_ChangeNormalSpriteDirection_Main
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	ASL
	PHP
	ROR.b !RAM_SMW_NorSpr_XSpeed,x
	PLP
	ROR.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01E649:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling
	BEQ.b CODE_01E650
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_01E650:
	LDA.w !RAM_SMW_NorSpr02F_PortableSpringboard_AnimationFrameTimer,x
	BEQ.b CODE_01E6B0
	LSR
	TAY
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	CMP.b #$01
	LDA.w PlayerYDisp,y
	BCC.b CODE_01E664
	CLC
	ADC.b #$12
CODE_01E664:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w AnimationFrames,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	STZ.b !RAM_SMW_Player_InAirFlag
	STZ.b !RAM_SMW_Player_XSpeed
	LDA.b #$02
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	LDA.w !RAM_SMW_NorSpr02F_PortableSpringboard_AnimationFrameTimer,x
	CMP.b #$07
	BCS.b CODE_01E6AE
	STZ.w !RAM_SMW_Misc_PlayerOnSolidSprite
	LDY.b #$B0
	LDA.b !RAM_SMW_IO_ControllerHold2
	; [10] Change to 80 to disable spin jumping from springboards
	BPL.b CODE_01E69A
	LDA.b #$01
	STA.w !RAM_SMW_Player_SpinJumpFlag
	BRA.b CODE_01E69E

CODE_01E69A:
	LDA.b !RAM_SMW_IO_ControllerHold1
	BPL.b CODE_01E6A7
CODE_01E69E:
	LDA.b #$0B
	STA.b !RAM_SMW_Player_InAirFlag
	LDY.b #$80
	STY.w !RAM_SMW_Camera_BounceOffSpringFlag
CODE_01E6A7:
	STY.b !RAM_SMW_Player_YSpeed
	LDA.b #!Define_SMW_Sound1DFC_Springboard	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_01E6AE:
	BRA.b CODE_01E6F0

CODE_01E6B0:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_ProcessInteract
	BCC.b CODE_01E6F0
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b #$04
	CMP.b #$1C
	BCC.b CODE_01E6CE
	BPL.b CODE_01E6E7
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_01E6F0
	STZ.b !RAM_SMW_Player_YSpeed
	BRA.b CODE_01E6F0

CODE_01E6CE:
	BIT.b !RAM_SMW_IO_ControllerHold1
	BVC.b CODE_01E6E2
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag1	; \ Branch if carrying an enemy...
	ORA.w !RAM_SMW_Player_RidingYoshiFlag	; | ...or if on Yoshi
	BNE.b CODE_01E6E2
	LDA.b #!Define_SMW_NorSprStatus0B_Carried	; \ Sprite status = carried
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
CODE_01E6E2:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_CODE_01AB31
	BRA.b CODE_01E6F0

CODE_01E6E7:
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_01E6F0
	LDA.b #$11
	STA.w !RAM_SMW_NorSpr02F_PortableSpringboard_AnimationFrameTimer,x
CODE_01E6F0:
	LDY.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w YDispOffset,y
	TAY
	LDA.b #$02
	JSR.w SMW_GenericGFXRtDraw4Tiles8x8Square_Entry1
	RTS

YDispOffset:
	db $00,$02,$00
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr030_ThrowingDryBones_Status08(Address)
namespace SMW_NorSpr030_ThrowingDryBones_Status08
%InsertMacroAtXPosition(<Address>)

XSpeed:
	db $08,$F8

UNK_01E421:
	db $02,$03,$04,$04,$04,$04,$04,$04
	db $04,$04

Main:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_01E43E
	ASL.w !RAM_SMW_NorSpr_YXPPCCCT,x
	SEC
	ROR.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JMP.w CODE_01E5BF

DATA_01E43C:
	db $08,$F8

CODE_01E43E:
	LDA.w !RAM_SMW_NorSpr030_ThrowingDryBones_HasCollapsedFlag,x
	BEQ.b CODE_01E4C0
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDY.w !RAM_SMW_NorSpr030_ThrowingDryBones_CollapsedTimer,x
	BNE.b CODE_01E453
	STZ.w !RAM_SMW_NorSpr030_ThrowingDryBones_HasCollapsedFlag,x
	PHY
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	PLY
CODE_01E453:
	LDA.b #$48
	CPY.b #$10
	BCC.b CODE_01E45F
	CPY.b #$F0
	BCS.b CODE_01E45F
	LDA.b #$2E
CODE_01E45F:
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	STA.w SMW_OAMBuffer[$40].Tile,y
	TYA
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	PHX
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	TAX
	LDA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.w DATA_01E43C,x
	PLX
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	LDA.w SMW_OAMBuffer[$40].Tile,y
	DEC
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.w !RAM_SMW_NorSpr030_ThrowingDryBones_CollapsedTimer,x
	BEQ.b CODE_01E4AC
	CMP.b #$40
	BCS.b CODE_01E4AC
	LSR
	LSR
	PHP
	LDA.w SMW_OAMBuffer[$40].XDisp,y
	ADC.b #$00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLP
	LDA.w SMW_OAMBuffer[$41].XDisp,y
	ADC.b #$00
	STA.w SMW_OAMBuffer[$41].XDisp,y
CODE_01E4AC:
	LDY.b #$02
	LDA.b #$01
	JSR.w SMW_FinishOAMWrite_Sub
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b Return01E4BF
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; \ Sprite Speed = 0
	STZ.b !RAM_SMW_NorSpr_XSpeed,x
Return01E4BF:
	RTS

CODE_01E4C0:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	ORA.w !RAM_SMW_NorSpr030_ThrowingDryBones_UnusedFreezeTimer,x
	BEQ.b CODE_01E4CA
	JMP.w CODE_01E5B6

CODE_01E4CA:
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w XSpeed,y
	EOR.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	ASL
	LDA.w XSpeed,y
	BCC.b CODE_01E4DD
	CLC
	ADC.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
CODE_01E4DD:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w !RAM_SMW_NorSpr030_ThrowingDryBones_ThrowBonesTimer,x
	BNE.b CODE_01E4ED
	TYA
	INC
	AND.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_01E4EF
CODE_01E4ED:
	STZ.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01E4EF:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling
	BEQ.b CODE_01E4F6
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_01E4F6:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr031_BonyBeetle
	BNE.b CODE_01E51E
	LDA.w !RAM_SMW_NorSpr031_BonyBeetle_HideInShellTimer,x
	BEQ.b CODE_01E542
	LDY.b #$00
	CMP.b #$70
	BCS.b CODE_01E518
	INY
	INY
	CMP.b #$08
	BCC.b CODE_01E518
	CMP.b #$68
	BCS.b CODE_01E518
	INY
CODE_01E518:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	BRA.b CODE_01E563

CODE_01E51E:
	CMP.b #!Define_SMW_SpriteID_NorSpr030_ThrowingDryBones
	BEQ.b CODE_01E52D
	; Part of the code that makes sprite 32, the Dry Bones that stays on
	; ledges, throw bones when the overworld level is 10D. You can change
	; $01E522 to [80 1E] to make sprite 32 never throw bones, change $01E526 to
	; [80 05] to make it throw bones in all overworld levels, or change $01E52A
	; to a different number to make it check a different overworld level. The
	; default value is 31, and it follows the format of RAM address $13BF. If
	; you change this behavior, you must also change the code at $01E59C.
	CMP.b #!Define_SMW_SpriteID_NorSpr032_LedgeDryBones
	BNE.b CODE_01E542
	LDA.w !RAM_SMW_Overworld_LevelNumberLo
	CMP.b #!Define_SMW_LevelID_NorSpr032_LedgeDryBones_ThrowsBones
	BNE.b CODE_01E542
CODE_01E52D:
	LDA.w !RAM_SMW_NorSpr030_ThrowingDryBones_ThrowBonesTimer,x
	BEQ.b CODE_01E542
	CMP.b #$01
	BNE.b CODE_01E53A
	JSL.l SpawnDryBonesBone
CODE_01E53A:
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JMP.w CODE_01E5B6

CODE_01E542:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01E563
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr032_LedgeDryBones
	BNE.b CODE_01E557
	STZ.b !RAM_SMW_NorSpr032_LedgeDryBones_WalkedOffLedgeFlag,x
	BRA.b CODE_01E561

CODE_01E557:
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	AND.b #$7F
	BNE.b CODE_01E561
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
CODE_01E561:
	BRA.b CODE_01E57B

CODE_01E563:
	STZ.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr032_LedgeDryBones
	BNE.b CODE_01E57B
	LDA.b !RAM_SMW_NorSpr032_LedgeDryBones_WalkedOffLedgeFlag,x
	BNE.b CODE_01E57B
	INC.b !RAM_SMW_NorSpr032_LedgeDryBones_WalkedOffLedgeFlag,x
	JSR.w SMW_ChangeNormalSpriteDirection_Main
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
CODE_01E57B:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr031_BonyBeetle
	BNE.b CODE_01E598
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b CODE_01E589
	INC.w !RAM_SMW_NorSpr031_BonyBeetle_WaitBeforeGoingIntoShell,x
CODE_01E589:
	LDA.w !RAM_SMW_NorSpr031_BonyBeetle_WaitBeforeGoingIntoShell,x
	BNE.b CODE_01E5B6
	INC.w !RAM_SMW_NorSpr031_BonyBeetle_WaitBeforeGoingIntoShell,x
	LDA.b #$A0
	STA.w !RAM_SMW_NorSpr031_BonyBeetle_HideInShellTimer,x
	BRA.b CODE_01E5B6

CODE_01E598:
	CMP.b #!Define_SMW_SpriteID_NorSpr030_ThrowingDryBones
	BEQ.b CODE_01E5A7
	; Part of the code that makes sprite 32, the Dry Bones that stays on
	; ledges, set its timer for throwing bones when the overworld level is 10D.
	; You can change $01E59C to [80 18] to make sprite 32 never throw bones,
	; change $01E5A0 to [80 05] to make it throw bones in all overworld levels,
	; or change $01E5A4 to a different number to make it check a different
	; overworld level. The default value is 31, and it follows the format of
	; RAM address $13BF. If you change this behavior, you must also change the
	; code at $01E522.
	CMP.b #!Define_SMW_SpriteID_NorSpr032_LedgeDryBones
	BNE.b CODE_01E5B6
	LDA.w !RAM_SMW_Overworld_LevelNumberLo
	CMP.b #!Define_SMW_LevelID_NorSpr032_LedgeDryBones_ThrowsBones
	BNE.b CODE_01E5B6
CODE_01E5A7:
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	CLC
	ADC.b #$40
	AND.b #$7F
	BNE.b CODE_01E5B6
	LDA.b #$3F
	STA.w !RAM_SMW_NorSpr030_ThrowingDryBones_ThrowBonesTimer,x
CODE_01E5B6:
	JSR.w CODE_01E5C4
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_Sub
	JSR.w SMW_ChangeNormalSpriteDirection_CheckIfTouchingWall
CODE_01E5BF:
	JSL.l DryBonesAndBonyBeetleGFXRt
	RTS

CODE_01E5C4:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	BCC.b Return01E610
	LDA.b !RAM_SMW_Player_CurrentYPosLo
	CLC
	ADC.b #$14
	CMP.b !RAM_SMW_NorSpr_YPosLo_x
	BPL.b CODE_01E604
	LDA.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped
	BNE.b CODE_01E5DB
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_01E604
CODE_01E5DB:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr031_BonyBeetle
	BNE.b CODE_01E5EB
	LDA.w !RAM_SMW_NorSpr031_BonyBeetle_HideInShellTimer,x
	SEC
	SBC.b #$08
	CMP.b #$60
	BCC.b CODE_01E604
CODE_01E5EB:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_CODE_01AB46
	JSL.l SMW_SpawnContactEffectFromAbove_Main
	LDA.b #!Define_SMW_Sound1DF9_DryBonesCollapse	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	JSL.l SMW_BoostMarioSpeed_Main
	INC.w !RAM_SMW_NorSpr030_ThrowingDryBones_HasCollapsedFlag,x
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr030_ThrowingDryBones_CollapsedTimer,x
	RTS

CODE_01E604:
	JSL.l SMW_DamagePlayer_Hurt
	LDA.w !RAM_SMW_Timer_PlayerHurt	; \ Return if Mario is invincible
	BNE.b Return01E610
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
Return01E610:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr030_ThrowingDryBones_Status08_Main, SMW_NorSpr031_BonyBeetle_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr030_ThrowingDryBones_Status08_Main, SMW_NorSpr032_LedgeDryBones_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSpr030_ThrowingDryBones_Status08_XSpeed, SMW_NorSpr036_Unused_Status08_Main)		; Crash: Loading this sprite will cause the universe to implode.
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr033_Podoboo_Status01(Address)
namespace SMW_NorSpr033_Podoboo_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr033_Podoboo_InitialYPosLo,x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr033_Podoboo_InitialYPosHi,x
CODE_01E05B:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	; | Podoboo Data
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x				;\ Crash: If sprite buoyancy is not set, then this will always branch, resulting in the game freezing.
	BEQ.b CODE_01E05B						;/
	JSR.w SMW_NorSpr033_Podoboo_Status08_CODE_01E0E2
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr033_Podoboo_WaitBeforeNextJump,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr033_Podoboo_Status08(Address)
namespace SMW_NorSpr033_Podoboo_Status08
%InsertMacroAtXPosition(<Address>)

DATA_01E07B:
	db $F0,$DC,$D0,$C8,$C0,$B8,$B2,$AC
	db $A6,$A0,$9A,$96,$92,$8C,$88,$84
	db $80,$04,$08,$0C,$10,$14

DATA_01E091:
	db $70,$20

Main:
	STZ.w !RAM_SMW_NorSpr033_Podoboo_CopyOfWaitBeforeNextJump,x
	LDA.w !RAM_SMW_NorSpr033_Podoboo_WaitBeforeNextJump,x
	BEQ.b CODE_01E0A7
	STA.w !RAM_SMW_NorSpr033_Podoboo_CopyOfWaitBeforeNextJump,x
	DEC
	BNE.b Return01E0A6
	LDA.b #!Define_SMW_Sound1DFC_Podoboo	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
Return01E0A6:
	RTS

CODE_01E0A7:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_01E0AE
	JMP.w CODE_01E12D

CODE_01E0AE:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	AND.b #$7F
	LDY.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_01E0C8
	INC.w !RAM_SMW_NorSpr_AnimationFrame,x
	INC.w !RAM_SMW_NorSpr_AnimationFrame,x
	ORA.b #$80
CODE_01E0C8:
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BEQ.b CODE_01E106
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_01E106
	JSL.l SMW_GetRand_Main
	AND.b #$3F
	; Change to [A9 XX 9D 40 15 80 04 EA EA EA EA] to make the Podoboo's timer
	; consistent, with XX being the amount of time for it to reappear.
	ADC.b #$60
	STA.w !RAM_SMW_NorSpr033_Podoboo_WaitBeforeNextJump,x
CODE_01E0E2:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.w !RAM_SMW_NorSpr033_Podoboo_InitialYPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.w !RAM_SMW_NorSpr033_Podoboo_InitialYPosHi,x
	LSR
	ROR.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	LSR
	LSR
	LSR
	TAY
	LDA.w DATA_01E07B,y
	BMI.b CODE_01E103
	STA.w !RAM_SMW_NorSpr033_Podoboo_KeepYSpeedFailsafeTimer,x
	LDA.b #$80
CODE_01E103:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	RTS

CODE_01E106:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$07
	ORA.b !RAM_SMW_NorSpr033_Podoboo_FireballType,x
	BNE.b CODE_01E115
	; Change to EA EA EA EA to prevent Podoboo from having lava trail.
	JSL.l SpawnPodobooFire
CODE_01E115:
	LDA.w !RAM_SMW_NorSpr033_Podoboo_KeepYSpeedFailsafeTimer,x
	BNE.b CODE_01E12A
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_01E125
	LDY.b !RAM_SMW_NorSpr033_Podoboo_FireballType,x
	CMP.w DATA_01E091,y
	BCS.b CODE_01E12A
CODE_01E125:
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01E12A:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
CODE_01E12D:
	LDA.b !RAM_SMW_NorSpr033_Podoboo_FireballType,x
	BEQ.b CODE_01E198
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_01E164
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_01E151
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.w !RAM_SMW_NorSpr033_Podoboo_BowserFireDespawnTimer,x
	BEQ.b CODE_01E14A
	CMP.b #$01
	BNE.b CODE_01E14F
	JMP.w SMW_NorSprStatus02_Dead_SetNorSprStatus04_Main

CODE_01E14A:
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr033_Podoboo_BowserFireDespawnTimer,x
CODE_01E14F:
	BRA.b CODE_01E164

CODE_01E151:
	TXA
	ASL
	ASL
	CLC
	ADC.b !RAM_SMW_Counter_GlobalFrames
	LDY.b #$F0
	AND.b #$04
	BEQ.b CODE_01E15F
	LDY.b #$10
CODE_01E15F:
	STY.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
CODE_01E164:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$F0
	BCC.b CODE_01E16D
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
CODE_01E16D:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	PHX
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$0C
	LSR
	ADC.w !RAM_SMW_NorSpr_CurrentSlotID
	LSR
	AND.b #$03
	TAX
	LDA.w BowserFlameTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w BowserFlameProp,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	RTS

; Sprite tilemap: Bowser Flame
BowserFlameTiles:
	db $2A,$2C,$2A,$2C

BowserFlameProp:
	db $05,$05,$45,$45

CODE_01E198:
	LDA.b #$01
	JSR.w SMW_GenericGFXRtDraw4Tiles8x8Square_Sub
	REP.b #$20			; A->16
	LDA.w #$0008
	ASL
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w #!RAM_SMW_Graphics_DecompressedGFX33+!Define_SMW_Graphics_StartOfDynamicSpriteTiles
	STA.w SMW_DynamicSpritePointersTop[$03].LowByte
	CLC
	ADC.w #$0200
	STA.w SMW_DynamicSpritePointersBottom[$03].LowByte
	SEP.b #$20			; A->8
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr033_Podoboo_Status08_Main, SMW_NorSpr0B5_SinkingFireball_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

; Glitch: This sprite does not move if placed directly into a level
; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's horizontally offscreen (when placed in level)
; Note: This sprite uses its own set of hardcoded OAM indexes separate from the ones Normal sprites usually use.

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr034_LudwigFireball_Status08(Address)
namespace SMW_NorSpr034_LudwigFireball_Status08
%InsertMacroAtXPosition(<Address>)

OAMIndexes:
	db $A8,$B0,$B8,$C0,$C8

UnusedRoutine_01D43E:
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Unreachable
	RTS				; / Erase sprite

XDisp:
	db $00,$F0
	db $00,$10

; Sprite tilemap: Ludwig Fireball
Tiles:
	db $4A,$4C
	db $6A,$6C

Prop:
	db $45,$45
	db $05,$05

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	ORA.w !RAM_SMW_Player_FreezePlayerFlag
	BNE.b CODE_01D487
	LDA.w !RAM_SMW_NorSpr034_LudwigFireball_WaitBeforeMoving,x
	CMP.b #$10
	BCS.b CODE_01D487
	TAY
	BNE.b CODE_01D468
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
CODE_01D468:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$20
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.w #$0230
	SEP.b #$20			; A->8
	BCC.b CODE_01D487
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
CODE_01D487:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM02
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l OAMIndexes,x
else
	LDA.w OAMIndexes,x
endif
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	PHX
	LDA.w !RAM_SMW_NorSpr034_LudwigFireball_WaitBeforeMoving,x
	LDX.b #$01
	CMP.b #$08
	BCC.b CODE_01D4A8
	DEX
CODE_01D4A8:
	PHX
	PHX
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	ROR
	AND.b #$80
	ORA.w Prop,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	INC
	INC
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_01D4A8
	PLX
	LDY.b #$02
	LDA.b #$01
	JMP.w SMW_FinishOAMWrite_Sub
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr035_Yoshi_Status01(Address)
namespace SMW_NorSpr035_Yoshi_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	DEC.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x	; Yoshi table...
	INC.w !RAM_SMW_NorSpr_FacingDirection,x	; add 1 to the sprite direction, not much to say
	LDA.w !RAM_SMW_Yoshi_CarryOverLevelsFlag	;\
	BEQ.b Return			;| if mario already has yoshi, don't make yoshi appear
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x	;/
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr035_Yoshi_Status01_Return, SMW_NorSpr04A_GoalSphere_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr035_Yoshi_Status01_Return, SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr035_Yoshi_Status01_Return, SMW_NorSpr048_DigginChuckRock_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr035_Yoshi_Status01_Return, SMW_NorSpr099_VolcanoLotus_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr035_Yoshi_Status08(Address)
namespace SMW_NorSpr035_Yoshi_Status08
%InsertMacroAtXPosition(<Address>)

UNK_01EBB6:
	db $01,$00,$FF,$00,$20,$E0,$0A,$0E

; Speed Yoshi has when mario get's hit while riding him. (Format = Left,
; Right) Left Value must be a value over 80, Right Value must be a value
; under 7F
PanicXSpeed:
	db $E8,$18

DismountXSpeed:
	db $10,$F0

; Growing animation sequence
GrowingAniSequence:
	db $0C,$0B,$0C,$0B,$0A,$0B,$0A,$0B

Main:
	STZ.w !RAM_SMW_Player_FreezePlayerFlag
	LDA.w !RAM_SMW_Yoshi_YoshiHasWings	; \ $1410 = winged Yoshi flag
	STA.w !RAM_SMW_Flag_DisplayYoshisWings
	STZ.w !RAM_SMW_Yoshi_YoshiHasWings	; Clear real winged Yoshi flag
	STZ.w !RAM_SMW_Yoshi_StompGroundFlag	; Clear stomp Yoshi flag
	STZ.w !RAM_SMW_UnusedRAM_7E191B						; Optimization: Unused
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Branch if normal Yoshi status
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_01EBE9
	STZ.w !RAM_SMW_Yoshi_CarryOverLevelsFlag	; Mario won't have Yoshi when returning to OW
	JMP.w HandleOffYoshi

CODE_01EBE9:
	TXA
	INC
	STA.w !RAM_SMW_Sprites_YoshiSlotIndex
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b CODE_01EC04
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	BNE.b CODE_01EC04
	LDA.w !RAM_SMW_InYoshiWingsBonusArea
	BNE.b Return01EC03
	STZ.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
Return01EC03:
	RTS

; The routine that makes Yoshi hatch. $01EC2C - Change to "A9 00 EA EA" (LDA
; #$00 : NOP : NOP) to make Yoshi's "Thank you for saving me" appear on any
; map. $01EC2F - Change "3A" (DEC A) to "EA" (NOP) to make Yoshi's "Thank
; you for saving me" message appear on the main map, as opposed to the
; Yoshi's Island submap. $01EC36 - Change from "D0" (BNE) to "80" (BRA) to
; disable the Yoshi rescue message. $01EC3C is Yoshi's thank you message.
; See ram $1426 for possible values.
CODE_01EC04:
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01EC0E
	LDA.w !RAM_SMW_Yoshi_InPipe
	BNE.b CODE_01EC61
CODE_01EC0E:
	LDA.w !RAM_SMW_Yoshi_EggLayTimer
	BNE.b CODE_01EC61
	LDA.w !RAM_SMW_GrowingYoshiTimer
	BEQ.b CODE_01EC4C
	DEC.w !RAM_SMW_GrowingYoshiTimer
	STA.b !RAM_SMW_Flag_SpritesLocked
	STA.w !RAM_SMW_Player_FreezePlayerFlag
	CMP.b #$01
	BNE.b CODE_01EC40
	STZ.b !RAM_SMW_Flag_SpritesLocked
	STZ.w !RAM_SMW_Player_FreezePlayerFlag
	LDY.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	DEC
	ORA.w !RAM_SMW_Flag_YoshiSaved
	ORA.w !RAM_SMW_Misc_IntroLevelFlag
	BNE.b CODE_01EC40
	INC.w !RAM_SMW_Flag_YoshiSaved
	LDA.b #$03
	STA.w !RAM_SMW_Misc_DisplayMessage
CODE_01EC40:
	DEC
	LSR
	LSR
	LSR
	TAY
	LDA.w GrowingAniSequence,y	; \ Set image to appropriate frame
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

CODE_01EC4C:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_01EC61
CODE_01EC50:
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b Return01EC5A
	LDY.b #$06
	STY.w !RAM_SMW_Player_RelativeYPositionDuringScreenShake
Return01EC5A:
	RTS

YoshiEggInitialXSpeed:
	db $F0,$10

YoshiEggInitialXOffsetLo:
	db $FA,$06

YoshiEggInitialXOffsetHi:
	db $FF,$00

CODE_01EC61:
	LDA.b !RAM_SMW_Player_InAirFlag
	BNE.b CODE_01EC6A
	LDA.w !RAM_SMW_Yoshi_EggLayTimer
	BNE.b CODE_01EC6D
CODE_01EC6A:
	JMP.w CODE_01ECE1

CODE_01EC6D:
	DEC.w !RAM_SMW_Yoshi_EggLayTimer
	CMP.b #$01
	BNE.b CODE_01EC78
	STZ.b !RAM_SMW_Flag_SpritesLocked
	BRA.b CODE_01EC6A

CODE_01EC78:
	INC.w !RAM_SMW_Player_FreezePlayerFlag
	JSR.w CODE_01EC50
	STY.b !RAM_SMW_Flag_SpritesLocked
	CMP.b #$02
	BNE.b Return01EC8A
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BPL.b CODE_01EC8B
Return01EC8A:
	RTS

CODE_01EC8B:
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr02C_YoshiEgg
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	PHY
	PHY
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	STY.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w YoshiEggInitialXOffsetLo,y
	PLY
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.w YoshiEggInitialXOffsetHi,y
	PLY
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.w YoshiEggInitialXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$F0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.w !RAM_SMW_Yoshi_LaidEggContents
	STA.w !RAM_SMW_NorSpr02C_YoshiEgg_ContentsOfEgg,x
	PLX
	RTS

CODE_01ECE1:
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	CMP.b #$01
	BNE.b CODE_01ECEA
	JMP.w CODE_01ED70

CODE_01ECEA:
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01ED01
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	CMP.b #$02
	BCS.b CODE_01ED01
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	LDA.b #$F0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01ED01:
	JSR.w SMW_SetFacingDirectionBasedOnSpeed_Bank01
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b CODE_01ED0C
	JSR.w SMW_ChangeNormalSpriteDirection_FlipXSpeedAndDirection
CODE_01ED0C:
	LDA.b #$04
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b #$13
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM07
	STA.b !RAM_SMW_Misc_ScratchRAM06
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b CODE_01ED70
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_01ED70
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag1	; \ Branch if carrying an enemy...
	ORA.w !RAM_SMW_Player_RidingYoshiFlag	; | ...or if on Yoshi
	BNE.b CODE_01ED70
	LDA.b !RAM_SMW_Player_YSpeed	; \ Branch if upward speed
	BMI.b CODE_01ED70
	LDY.b #$01
	JSR.w CODE_01EDCE
	; Change from [64 7B] to [EA EA] (NOP #2) to preserve Mario's horizontal
	; speed when mounting Yoshi.
	STZ.b !RAM_SMW_Player_XSpeed	; \ Mario's speed = 0
	; Change from [64 7D] to [EA EA] (NOP #2) to preserve Mario's vertical
	; speed when mounting Yoshi.
	STZ.b !RAM_SMW_Player_YSpeed
	LDA.b #$0C
	STA.w !RAM_SMW_Timer_YoshiSquatting
	LDA.b #$01
	STA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	LDA.b #!Define_SMW_Sound1DFA_TurnOnYoshiDrum	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
	LDA.b #!Define_SMW_Sound1DFC_MountYoshi	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	JSL.l SpawnUnusedYoshiSmoke
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr035_Yoshi_DisableSpriteInteraction,x
	; Change to [80 01 EA] to fix the glitch where you can hop off Yoshi to
	; increase consecutive enemies stomped.
	INC.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped			; Note: This is an odd thing to put here, considering that the player normally only mounts Yoshi while he is on the ground.
CODE_01ED70:
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	CMP.b #$01
	BNE.b Return01EDCB
	JSR.w CODE_01F622
	LDA.b !RAM_SMW_IO_ControllerHold1					;\ Glitch: Holding left+right will cause Yoshi to constantly turn around.
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)				;|
	BEQ.b CODE_01ED95							;|
	DEC									;|
	CMP.w !RAM_SMW_NorSpr_FacingDirection,x					;|
	BEQ.b CODE_01ED95							;/
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	ORA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	ORA.w !RAM_SMW_Yoshi_DuckingFlag
	BNE.b CODE_01ED95
	LDA.b #$10			; \ Set turning timer
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
CODE_01ED95:
	LDA.w !RAM_SMW_Timer_InflateFromPBalloon
	BNE.b CODE_01ED9E
	BIT.b !RAM_SMW_IO_ControllerPress2
	; [10] Change to [80] to disable jumping of Yoshi.
	BPL.b Return01EDCB
; The routine that makes player leave Yoshi (by pressing A while on him).
CODE_01ED9E:
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr035_Yoshi_DisableWaterSplashTimer,x
	STZ.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	LDA.b #!Define_SMW_Sound1DFA_TurnOffYoshiDrum	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
	STZ.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	LDA.b !RAM_SMW_Player_XSpeed
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$A0
	LDY.b !RAM_SMW_Player_InAirFlag
	BNE.b CODE_01EDC1
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w DismountXSpeed,y
	STA.b !RAM_SMW_Player_XSpeed
	LDA.b #$C0							; Glitch: Setting !RAM_SMW_Player_InAirFlag to #$0B here would fix the zip bug while in the Iggy/Larry boss fight
CODE_01EDC1:
	STA.b !RAM_SMW_Player_YSpeed
	STZ.w !RAM_SMW_Player_RidingYoshiFlag
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	JSR.w CODE_01EDCC
Return01EDCB:
	RTS

CODE_01EDCC:
	LDY.b #$00
CODE_01EDCE:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.w DATA_01EDE2,y
	STA.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_Player_CurrentYPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	STA.b !RAM_SMW_Player_CurrentYPosHi
	RTS

DATA_01EDE2:
	db $04,$10

; Y-position of Mario on Yoshi (1 byte for each frame; 10 bytes)
DATA_01EDE4:							;\ Note: Not used by Yoshi directly
	db $06,$05,$05,$05,$0A,$05,$05,$0A			;|
	db $0A,$0B						;|
								;|
; Riding Yoshi walking animation frames
YoshiWalkFrames:						;|
	db $02,$01,$00						;|
								;|
; Base X-position of Yoshi (1st byte facing right; 2nd facing left)
YoshiPositionX:							;|
	db $02,$FE						;|
								;|
DATA_01EDF3:							;|
	db $00,$FF						;|
								;|
DATA_01EDF5:							;|
	db $03,$02,$01,$00					;/

; Yoshi's head tiles (points to table at 9E47-9E57)
YoshiHeadTiles:
	db $00,$01,$02,$03,$02,$10,$04,$05
	db $00,$00,$FF,$FF,$00

; Yoshi's body tiles (points to table at 9E47-9E57)
YoshiBodyTiles:
	db $06,$07,$08,$09,$0A,$0B,$06,$0C
	db $0A,$0D,$0E,$0F,$0C

; X-position of Yoshi's head (facing right)
YoshiHeadXDisp:
	db $0A,$09,$0A,$06,$0A,$0A,$0A,$10
	db $0A,$0A,$00,$00,$0A,$F6,$F7,$F6
	db $FA,$F6,$F6,$F6,$F0,$F6,$F6,$00
	db $00,$F6

DATA_01EE2D:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
	db $00,$FF

; Base Y-position of Yoshi
YoshiPositionY:
	db $00,$01,$01,$00,$04,$00,$00,$04
	db $03,$03,$00,$00,$04

; Y-position of Yoshi's head
YoshiHeadYDisp:
	db $00,$00,$01,$00,$00,$00,$00,$08
	db $00,$00,$00,$00,$05

HandleOffYoshi:
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	PHA
	LDY.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	CPY.b #$08
	BNE.b CODE_01EE7D
	LDA.w !RAM_SMW_Yoshi_InPipe
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_01EE7D
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Player_FacingDirection
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_01EE7D:
	LDA.w !RAM_SMW_Yoshi_InPipe
	BMI.b CODE_01EE8A
	CMP.b #$02
	BNE.b CODE_01EE8A
	INC
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
CODE_01EE8A:
	JSR.w CODE_01EF18
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w SMW_OAMBuffer[$40].Tile,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$06
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$40].Tile,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b #$08
	STA.w SMW_OAMBuffer[$40].Tile,y
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w #!RAM_SMW_Graphics_DecompressedGFX33+!Define_SMW_Graphics_StartOfDynamicSpriteTiles
	STA.w SMW_DynamicSpritePointersTop[$03].LowByte
	CLC
	ADC.w #$0200
	STA.w SMW_DynamicSpritePointersBottom[$03].LowByte
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	ASL
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w #!RAM_SMW_Graphics_DecompressedGFX33+!Define_SMW_Graphics_StartOfDynamicSpriteTiles
	STA.w SMW_DynamicSpritePointersTop[$04].LowByte
	CLC
	ADC.w #$0200
	STA.w SMW_DynamicSpritePointersBottom[$04].LowByte
	SEP.b #$20			; A->8
	PLA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w CODE_01F0A2
	LDA.w !RAM_SMW_Flag_DisplayYoshisWings	; \ Return if Yoshi doesn't have wings
	CMP.b #$02
	BCC.b Return01EF17
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01EF13
	LDA.b !RAM_SMW_Player_InAirFlag
	BNE.b CODE_01EF00
	LDA.b !RAM_SMW_Player_XSpeed
	BPL.b CODE_01EEF6
	EOR.b #$FF
	INC
CODE_01EEF6:
	CMP.b #$28
	LDA.b #$01
	BCS.b CODE_01EF13
	LDA.b #$00
	BRA.b CODE_01EF13

CODE_01EF00:
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	; [A4 7D 30 02] Controls the rate at which Blue/Winged Yoshi's wings
	; flutter and the rate at which the flying SFX plays, depending on Mario's
	; Y speed direction. Change $01EF04 to [80 02] (BRA $02) to make the
	; flutter animation/SFX always slow. Change $01EF06 to [80] (BRA) to make
	; the flutter animation/SFX always fast. Change $01EF06 to [10] (BPL) to
	; invert the Y speed direction condition (Slow if rising, fast if falling).
	LDY.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_01EF0A
	LSR
	LSR
CODE_01EF0A:
	AND.b #$01
	BNE.b CODE_01EF13
	LDY.b #!Define_SMW_Sound1DFC_YoshiTongue	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh3
CODE_01EF13:
	JSL.l DrawYoshisWings
Return01EF17:
	RTS

CODE_01EF18:
	LDY.w !RAM_SMW_NorSpr_AnimationFrame,x
	STY.w !RAM_SMW_NorSpr035_Yoshi_UnknownRAM
	LDA.w YoshiHeadTiles,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	CLC
	ADC.w YoshiPositionY,y
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	TYA
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	BEQ.b CODE_01EF41
	CLC
	ADC.b #$0D
CODE_01EF41:
	TAY
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	CLC
	ADC.w YoshiHeadXDisp,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	ADC.w DATA_01EE2D,y
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	PHA
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	ORA.w !RAM_SMW_Yoshi_InPipe
	BEQ.b CODE_01EF66
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
CODE_01EF66:
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	PHX
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDX.w !RAM_SMW_NorSpr035_Yoshi_UnknownRAM
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l YoshiHeadYDisp,x
else
	ADC.w YoshiHeadYDisp,x
endif
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PLX
	PLA
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	PLA
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDY.w !RAM_SMW_NorSpr035_Yoshi_UnknownRAM
	LDA.w YoshiBodyTiles,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	BCC.b CODE_01EFA3
	INC.w !RAM_SMW_NorSpr_YPosHi,x
CODE_01EFA3:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	BPL.b CODE_01EFB8
	LDA.b #$F0
	STA.w SMW_OAMBuffer[$40].YDisp,y
CODE_01EFB8:
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	BNE.b CODE_01EFC6
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$30
	BNE.b CODE_01EFDB
	LDA.b #$2A
	BRA.b CODE_01EFFA

CODE_01EFC6:
	CMP.b #$02
	BNE.b CODE_01EFDB
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	ORA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	BNE.b CODE_01EFDB
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$10
	BEQ.b CODE_01EFFD
	BRA.b CODE_01EFF8

Return01EFDA:
	RTS

CODE_01EFDB:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState,x
	CMP.b #$03
	BEQ.b CODE_01EFEE
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	BEQ.b CODE_01EFF3
	LDA.w SMW_OAMBuffer[$40].Tile,y
	CMP.b #$24
	BEQ.b CODE_01EFF3
CODE_01EFEE:
	LDA.b #$2A
	STA.w SMW_OAMBuffer[$40].Tile,y
CODE_01EFF3:
	LDA.w !RAM_SMW_Timer_YoshiTongueInit
	BEQ.b CODE_01EFFD
CODE_01EFF8:
	LDA.b #$0C
CODE_01EFFA:
	STA.w SMW_OAMBuffer[$40].Tile,y
CODE_01EFFD:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_SwallowAnimationTimer,x
	LDY.w !RAM_SMW_Yoshi_SwallowTimer
	BEQ.b CODE_01F00F
	CPY.b #$26
	BCS.b CODE_01F038
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$18
	BNE.b CODE_01F038
CODE_01F00F:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_SwallowAnimationTimer,x
	CMP.b #$00
	BEQ.b Return01EFDA
	LDY.b #$00
	CMP.b #$0F
	BCC.b CODE_01F03A
	CMP.b #$1C
	BCC.b CODE_01F038
	BNE.b CODE_01F02F
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	PHA
	JSL.l ChangeBerryIntoBushTile
	JSR.w HandleYoshiSwallowingSomething
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_01F02F:
	INC.w !RAM_SMW_Player_FreezePlayerFlag
	LDA.b #$00
	LDY.b #$2A
	BRA.b CODE_01F03A

CODE_01F038:
	LDY.b #$04
CODE_01F03A:
	PHA
	TYA
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLA
	CMP.b #$0F
	BCS.b Return01F0A0
	CMP.b #$05
	BCC.b Return01F0A0
	SBC.b #$05
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	BEQ.b CODE_01F054
	CLC
	ADC.b #$0A
CODE_01F054:
	LDY.w !RAM_SMW_NorSpr_AnimationFrame,x
	CPY.b #$0A
	BNE.b CODE_01F05E
	CLC
	ADC.b #$14
CODE_01F05E:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01
	BNE.b Return01F0A0
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.l YoshiThroatXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.l YoshiThroatYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp
	LDA.b #$3F
	STA.w SMW_OAMBuffer[$40].Tile
	PLX
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$40].Prop,y
	ORA.b #$01
	STA.w SMW_OAMBuffer[$40].Prop
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot
Return01F0A0:
	RTS

Return01F0A1:
	RTS

CODE_01F0A2:
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	CMP.b #$01
	BNE.b CODE_01F0AC
	JSL.l CheckForBerryTileCollisionWithAdultYoshiMouth
CODE_01F0AC:
	LDA.w !RAM_SMW_Flag_DisplayYoshisWings	; \ Branch if $1410 == #$01
	CMP.b #$01			; | This never happens
	BEQ.b Return01F0A1		; / (fireball on Yoshi ability)
	LDA.w !RAM_SMW_Timer_YoshiTongueIsOut
	CMP.b #$10
	BNE.b CODE_01F0C4
	; Change from [AD AE 18] to [EA A5 9D] to fix the glitch where Yoshi will
	; stick his tongue out twice if the screen is frozen (such as during a
	; power up animation) while $7E14A3 is #$10.
	LDA.w !RAM_SMW_Timer_YoshiTongueInit			; Glitch: Change this LDA.w !RAM_SMW_Timer_YoshiTongueInit to LDA.b !RAM_SMW_Flag_SpritesLocked : NOP to fix the double tongue glitch
	BNE.b CODE_01F0C4
	LDA.b #$06
	STA.w !RAM_SMW_Timer_YoshiTongueInit
CODE_01F0C4:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState,x
	JSL.l SMW_ExecutePtr_Absolute

Ptrs01F0CB:
	dw MouthState00_Normal
	dw MouthState01_ExtendTongue
	dw MouthState02_RetractTongue
	dw MouthState03_Spitting

; Subroutine that is called while swallowing a sprite or a berry with Yoshi
; to give the player a coin and handle berry effects. - $01F0D4: ($06) SFX
; to play when swallowing something. - $01F0D6: ($1DF9) Swallow SFX port. -
; $01F0D8: change to $80,$02 to disable the coin given by swallowing
; sprites. - $01F0EF: ($0A) Number of red berries Yoshi needs to lay an egg.
; - $01F0F6: ($74) Sprite number to spawn when eating enough red berries. -
; $01F0FE: ($29) SFX to play when swallowing a green berry. - $01F100:
; ($1DFC) Green berry SFX port. - $01F107: ($02) Amount of tens to add to
; the timer when eating a green berry ($01 = add 10 seconds, $02 = add 20
; seconds, etc.); can glitch the timer if set to values higher than $0A. -
; $01F11D: ($02) Number of pink berries Yoshi needs to eat to lay an egg. -
; $01F124: ($6A) Sprite number to spawn when eating enough pink berries.
HandleYoshiSwallowingSomething:
	LDA.b #!Define_SMW_Sound1DF9_YoshiGulp	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	JSL.l SMW_GiveCoins_OneCoin
	LDA.w !RAM_SMW_Yoshi_BerryBeingEaten
	BEQ.b Return01F12D
	STZ.w !RAM_SMW_Yoshi_BerryBeingEaten
	CMP.b #$01
	BNE.b CODE_01F0F9
	INC.w !RAM_SMW_Counter_EatenRedBerries
	LDA.w !RAM_SMW_Counter_EatenRedBerries
	CMP.b #$0A
	BNE.b Return01F12D
	STZ.w !RAM_SMW_Counter_EatenRedBerries
	LDA.b #$74
	BRA.b CODE_01F125

CODE_01F0F9:
	CMP.b #$03
	BNE.b CODE_01F116
	LDA.b #!Define_SMW_Sound1DFC_Correct	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.w !RAM_SMW_Counter_TimerTens
	CLC
	ADC.b #$02
	CMP.b #$0A
	BCC.b CODE_01F111
	SBC.b #$0A
	INC.w !RAM_SMW_Counter_TimerHundreds
CODE_01F111:
	STA.w !RAM_SMW_Counter_TimerTens
	BRA.b Return01F12D

CODE_01F116:
	INC.w !RAM_SMW_Counter_EatenPinkBerries
	LDA.w !RAM_SMW_Counter_EatenPinkBerries
	CMP.b #$02
	BNE.b Return01F12D
	STZ.w !RAM_SMW_Counter_EatenPinkBerries
	LDA.b #$6A
CODE_01F125:
	STA.w !RAM_SMW_Yoshi_LaidEggContents
	LDY.b #$20
	STY.w !RAM_SMW_Yoshi_EggLayTimer
Return01F12D:
	RTS

MouthState03_Spitting:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	BNE.b Return01F136
	STZ.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState,x
Return01F136:
	RTS

; Which powers the different Yoshi color+shell color combinations gives.
; It's a 4x4 table, where the order is green, red, yellow, blue, the Koopa
; colors are on the horizontal axis and the Yoshi colors are on the vertical
; axis. Setting a #$01 bit enables ground pounding, #$02 enables flight,
; #$03 enables both. The other bits aren't used.
YoshiShellAbility:
	db $00,$00,$01,$02,$00,$00,$01,$02
	db $01,$01,$01,$03,$02,$02

YoshiAbilityIndex:
	db $03,$02,$02,$03,$01,$00

MouthState00_Normal:
	LDA.w !RAM_SMW_InYoshiWingsBonusArea
	BEQ.b CODE_01F155
	LDA.b #$02			; \ Set Yoshi wing ability
	STA.w !RAM_SMW_Yoshi_YoshiHasWings
CODE_01F155:
	LDA.w !RAM_SMW_Yoshi_SwallowTimer
	BEQ.b CODE_01F1A2
	LDY.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr080_Key
	BNE.b CODE_01F167
	INC.w !RAM_SMW_Yoshi_KeyInMouthFlag
CODE_01F167:
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb
	BCS.b CODE_01F1A2
	PHY
	LDA.w !RAM_SMW_NorSpr_Table7E187B,y
	CMP.b #$01
	LDA.b #$03
	BCS.b CODE_01F195
	LDA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,x	; \ Set yoshi stomp/wing ability,
	LSR				; | based on palette of sprite and Yoshi
	AND.b #$07
	TAY
	LDA.w YoshiAbilityIndex,y
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM00
	PLY
	PHY
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,y
	LSR
	AND.b #$07
	TAY
	LDA.w YoshiAbilityIndex,y
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	LDA.w YoshiShellAbility,y
CODE_01F195:
	PHA				; \ Set yoshi wing ability
	AND.b #$02			; | ($141E = #$02)
	STA.w !RAM_SMW_Yoshi_YoshiHasWings
	PLA				; \ If Yoshi gets stomp ability,
	AND.b #$01			; | $18E7 = #$01
	STA.w !RAM_SMW_Yoshi_StompGroundFlag
	PLY
CODE_01F1A2:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$03
	BNE.b CODE_01F1C6
	LDA.w !RAM_SMW_Yoshi_SwallowTimer
	; Change from F0 to 80 to make Yoshi never swallow sprites held in his
	; mouth (shells, keys, P-switches, etc).
	BEQ.b CODE_01F1C6
	DEC.w !RAM_SMW_Yoshi_SwallowTimer
	BNE.b CODE_01F1C6
	LDY.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	LDA.b #!Define_SMW_NorSprStatus00_EmptySlot
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	DEC
	STA.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	LDA.b #$1B
	STA.w !RAM_SMW_NorSpr035_Yoshi_SwallowAnimationTimer,x
	JMP.w HandleYoshiSwallowingSomething

CODE_01F1C6:
	LDA.w !RAM_SMW_Timer_YoshiTongueInit
	BEQ.b CODE_01F1DF
	DEC.w !RAM_SMW_Timer_YoshiTongueInit
	BNE.b Return01F1DE
	INC.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState,x
	STZ.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	STZ.w !RAM_SMW_NorSpr035_Yoshi_SwallowAnimationTimer,x
Return01F1DE:
	RTS

CODE_01F1DF:
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	CMP.b #$01
	BNE.b Return01F1DE
	BIT.b !RAM_SMW_IO_ControllerPress1
	BVC.b Return01F1DE
	LDA.w !RAM_SMW_Yoshi_SwallowTimer
	BNE.b CODE_01F1F1
	JMP.w CODE_01F309

CODE_01F1F1:
	STZ.w !RAM_SMW_Yoshi_SwallowTimer
	LDY.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	PHY
	PHY
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w DATA_01F305,y
	PLY
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.w DATA_01F307,y
	PLY
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_Table7E00C2,y
	STA.w !RAM_SMW_NorSpr_OnYoshisTongue,y
	STA.w !RAM_SMW_NorSpr_Table7E1626,y
	LDA.w !RAM_SMW_Yoshi_DuckingFlag
	CMP.b #$01
	LDA.b #!Define_SMW_NorSprStatus0A_Kicked
	BCC.b CODE_01F234
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
CODE_01F234:
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	PHX
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.w !RAM_SMW_NorSpr_FacingDirection,y
	TAX
	BCC.b CODE_01F243
	INX
	INX
CODE_01F243:
	LDA.w SpatOutSpriteXSpeed,x
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	PLX
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState,x
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb
	BCS.b CODE_01F2DF
	LDA.w !RAM_SMW_NorSpr_Table7E187B,y
	BNE.b CODE_01F27C
	; Code that makes Yoshi spit out flames when he has the red shell in his
	; mouth $01F270 - Which shell colour can give Yoshi fire breath.
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,y
	AND.b #$0E
	CMP.b #$08
	BEQ.b CODE_01F27C
	; Code that makes Red Yoshi spit out flames no matter what shell colour is
	; in his mouth $01F279 - Which coloured Yoshi always gets fire breath
	LDA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,x
	AND.b #$0E
	CMP.b #$08
	BNE.b CODE_01F2DF
; Code that makes Yoshi spawn Yoshi Fireballs, by calling the subroutine at
; $01F295 three times. Change $01F28B to $80,$01 to make Yoshi breathe just
; the top and bottom fireball. Change $01F282 to $00 and $01F288 to $80,$04
; to make Yoshi breathe just the middle fireball.
CODE_01F27C:
	PHX
if defined("Define_SMW_SA1")
	; SA-1 Pack: yoshi spit fire.
	JML.l YOSHI_SPIT
else
	TYX
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
endif
	LDA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM00
	JSR.w CODE_01F295
	JSR.w CODE_01F295
	JSR.w CODE_01F295
	PLX
	LDA.b #!Define_SMW_Sound1DFC_FireSpit	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	RTS

; Subroutine to spawn a Yoshi Fireball, which uses the value in $7E:0000 to
; determine what speed values to use. After it returns, the value in
; $7E:0000 will be decremented by 1. - $01F299 (1 byte): extended sprite
; number to spawn. By default it's $11 (Yoshi Fireball). - $01F2D9 (3
; bytes): X speed to give the fireball. By default it's $28,$24,$24 (middle,
; up, down fireball respectively). - $01F2DC (3 bytes): Y speed to give the
; fireball. By default it's $00,$F8,$08 (middle, up, down fireball
; respectively).
CODE_01F295:
	JSR.w SMW_CheckForAvailableExtendedSpriteSlot_Main
	LDA.b #!Define_SMW_SpriteID_ExtSpr11_YoshiFireball	; \ Extended sprite = Yoshi fireball
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDA.b #$00
	STA.w !RAM_SMW_ExtSpr11_YoshiFireball_CurrentLayerPriority,y
	PHX
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	LSR
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w YoshiFireballInitialXSpeed,x
	BCC.b CODE_01F2C7
	EOR.b #$FF
	INC
CODE_01F2C7:
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
	LDA.w YoshiFireballInitialYSpeed,x
	STA.w !RAM_SMW_ExtSpr_YSpeed,y
	LDA.b #$A0
	STA.w !RAM_SMW_ExtSpr_DecrementingTable7E176F,y
	PLX
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	RTS

YoshiFireballInitialXSpeed:
	db $28,$24,$24

YoshiFireballInitialYSpeed:
	db $00,$F8,$08

CODE_01F2DF:
	LDA.b #!Define_SMW_Sound1DF9_YoshiSpit	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,y	; \ Return if sprite doesn't spawn a new one
	AND.b #!Define_SMW_NorSpr_1686Prop_SpawnsNewSprite
	BEQ.b Return01F2FE
	PHX				; \ Load sprite to spawn and store it
	LDX.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.l SMW_GenericSpriteToSpawnTable_Main,x
	PLX
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	PHX				; \ Load Tweaker bytes
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_YXPPCCCTAndPropertyTables
	PLX
Return01F2FE:
	RTS

UNK_01F2FF:
	db $20,$E0

; X speeds to give sprites when spit out by Yoshi, depending on Yoshi's
; direction and if Yoshi is ducking or not. The values are, in order: -
; ($30) Speed when spitting to the right while not ducking. - ($D0) Speed
; when spitting to the left while not ducking. - ($10) Speed when spitting
; to the right while ducking. - ($F0) Speed when spitting to the left while
; ducking.
SpatOutSpriteXSpeed:
	db $30,$D0,$10,$F0

DATA_01F305:
	db $10,$F0

DATA_01F307:
	db $00,$FF

CODE_01F309:
	LDA.b #$12
	STA.w !RAM_SMW_Timer_YoshiTongueIsOut
	LDA.b #!Define_SMW_Sound1DFC_YoshiTongue	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	RTS

MouthState01_ExtendTongue:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	CLC
	ADC.b #$03
	STA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	CMP.b #$20
	BCS.b CODE_01F328
CODE_01F321:
	JSR.w CODE_01F3FE
	JSR.w CODE_01F4B2
	RTS

CODE_01F328:
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	INC.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState,x
	BRA.b CODE_01F321

MouthState02_RetractTongue:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	BNE.b CODE_01F321
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	SEC
	SBC.b #$04
	BMI.b CODE_01F344
	STA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	BRA.b CODE_01F321

CODE_01F344:
	STZ.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	STZ.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState,x
	LDY.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	BMI.b CODE_01F370
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,y
	AND.b #!Define_SMW_NorSpr_1686Prop_StayInYoshisMouth
	BEQ.b CODE_01F373
	LDA.b #!Define_SMW_NorSprStatus07_InLimbo	; \ Sprite status = Unused (todo: look here)
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #$FF
	STA.w !RAM_SMW_Yoshi_SwallowTimer
	; The routine triggered when Yoshi eats a sprite. Starts by loading the
	; sprite number and comparing it to a Koopa.
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ Branch if not a Koopa
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb	; | (sprite number >= #$0D)
	BCS.b CODE_01F370
	PHX
	TAX
	LDA.w SMW_GenericSpriteToSpawnTable_Main,x
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	PLX
CODE_01F370:
	JMP.w CODE_01F3FA

CODE_01F373:
	LDA.b #!Define_SMW_NorSprStatus00_EmptySlot
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #$1B
	STA.w !RAM_SMW_NorSpr035_Yoshi_SwallowAnimationTimer,x
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr09D_BubbleWithSprite
	BNE.b CODE_01F39F
	LDA.w !RAM_SMW_NorSpr09D_BubbleWithSprite_Contents,y
	CMP.b #$03
	BNE.b CODE_01F39F
	LDA.b #!Define_SMW_SpriteID_NorSpr074_Mushroom	; \ Sprite = Mushroom
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,y	; \ Set "Gives powerup when eaten" bit
	ORA.b #!Define_SMW_NorSpr_167AProp_GivePowerupWhenEaten
	STA.w !RAM_SMW_NorSpr_PropertyBits167A,y
CODE_01F39F:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ Branch if not Changing Item
	CMP.b #!Define_SMW_SpriteID_NorSpr081_ChangingItem
	BNE.b CODE_01F3BA
	LDA.w !RAM_SMW_NorSpr081_ChangingItem_SpriteChangeCounter,y
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w SMW_NorSprXXX_PowerUps_Status08_ChangingItemSprite,y
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_SpriteID,y
CODE_01F3BA:
	PHA
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,y				; Note: !Define_SMW_NorSpr_167AProp_InvincibleToMostThings
	ASL
	ASL
	PLA
	BCC.b CODE_01F3DB
if defined("Define_SMW_SA1")
	; SA-1 Pack: Yoshi eating a sprite.
	JML.l YOSHI_EAT_SET
else
	PHX
	TYX
	STZ.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
endif
	JSR.w SMW_NorSprXXX_PowerUps_Status08_CODE_01C4BF
if defined("Define_SMW_SA1")
	JML.l YOSHI_EAT_RESTORE
else
	PLX
	LDY.w !RAM_SMW_Yoshi_DuckingFlag
endif
	LDA.w DATA_01F3D9,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JMP.w CODE_01F321

DATA_01F3D9:
	db $00,$04

CODE_01F3DB:
	CMP.b #!Define_SMW_SpriteID_NorSpr07E_FlyingRedCoin
	BNE.b CODE_01F3F7
	LDA.w !RAM_SMW_NorSpr_Table7E00C2,y
	BEQ.b CODE_01F3F7
	CMP.b #$02
	BNE.b ADDR_01F3F1
	LDA.b #!Define_SMW_PlayerState08_WarpToYoshiWingsBonus
	STA.b !RAM_SMW_Player_CurrentState
	LDA.b #!Define_SMW_Sound1DFC_HitVineBlock	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
ADDR_01F3F1:
	JSR.w CODE_01F6CD
	JMP.w CODE_01F321

CODE_01F3F7:
	JSR.w HandleYoshiSwallowingSomething
CODE_01F3FA:
	JMP.w CODE_01F321

Return01F3FD:
	RTS

CODE_01F3FE:
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x	; \ Branch if sprite off screen...
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	ORA.w !RAM_SMW_Yoshi_InPipe	; | ...or going down pipe
	BNE.b Return01F3FD
	LDY.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w DATA_01F61A,y
	STA.w !RAM_SMW_NorSpr035_Yoshi_UnknownRAM
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	BNE.b CODE_01F424
	TYA
	CLC
	ADC.b #$08
	TAY
CODE_01F424:
	LDA.w DATA_01F60A,y
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0D
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	BNE.b CODE_01F43C
	BCS.b Return01F3FD
	BRA.b CODE_01F43E

CODE_01F43C:
	BCC.b Return01F3FD
CODE_01F43E:
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/01F43E.asm"
namespace SMW_NorSpr035_Yoshi_Status08
else
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	STA.w !REGISTER_DividendHi	; Dividend (High-Byte)
	STZ.w !REGISTER_DividendLo	; Dividend (Low Byte)
	LDA.b #$04
	STA.w !REGISTER_Divisor		; Divisor B
	NOP #8
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LSR
	LDA.w !REGISTER_QuotientHi	; Quotient of Divide Result (High Byte)
endif
	BCC.b CODE_01F462
	EOR.b #$FF
	INC
CODE_01F462:
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDY.b #$0C
CODE_01F46A:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].XDisp,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM05
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	BPL.b CODE_01F47C
	BCC.b Return01F4B1
	BRA.b CODE_01F47E

CODE_01F47C:
	BCS.b Return01F4B1
CODE_01F47E:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	CMP.b #$01
	LDA.b #$76
	BCS.b CODE_01F48D
	LDA.b #$66
CODE_01F48D:
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	LSR
	LDA.b #$09
	BCS.b CODE_01F499
	ORA.b #$40
CODE_01F499:
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
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
	DEC.b !RAM_SMW_Misc_ScratchRAM06
	BPL.b CODE_01F46A
Return01F4B1:
	RTS

CODE_01F4B2:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	BMI.b CODE_01F524
	LDY.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM0D
	BMI.b CODE_01F4C3
	CLC
	ADC.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	BRA.b CODE_01F4CC

CODE_01F4C3:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	EOR.b #$FF
	INC
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0D
CODE_01F4CC:
	SEC
	SBC.b #$04
	BPL.b CODE_01F4D2
	DEY
CODE_01F4D2:
	PHY
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	LDY.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	PLY
	TYA
	ADC.w !RAM_SMW_NorSpr_XPosHi,x
	LDY.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b #$FC
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,y
	AND.b #!Define_SMW_NorSpr_1662Prop_UseShellAsDeathFrame
	BNE.b CODE_01F4FD
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,y	; \ Branch if "Death frame 2 tiles high"
	AND.b #!Define_SMW_NorSpr_190FProp_2TileTallDeathFrame	; | is NOT set
	BEQ.b CODE_01F4FD
	LDA.b #$F8
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_01F4FD:
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w !RAM_SMW_NorSpr035_Yoshi_UnknownRAM
	BPL.b CODE_01F509
	DEC.b !RAM_SMW_Misc_ScratchRAM01
CODE_01F509:
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	INC
	STA.w !RAM_SMW_NorSpr_OnYoshisTongue,y
	RTS

; Subroutine that checks for contact between Yoshi's tongue and any other
; sprite or berry. - $01F55F: ($08) Clipping width of the tip of Yoshi's
; tongue. - $01F563: ($04) Clipping height of the tip of Yoshi's tongue.
; Change $01F524 from $5A to $60 to prevent Yoshi from eating anything
; (although he will still be able to eat berries by walking on them).
CODE_01F524:
	PHY
	LDY.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM0D
	BMI.b CODE_01F531
	CLC
	ADC.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	BRA.b CODE_01F53A

CODE_01F531:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	EOR.b #$FF
	INC
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0D
CODE_01F53A:
	CLC
	ADC.b #$00
	BPL.b CODE_01F540
	DEY
CODE_01F540:
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	TYA
	ADC.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	PLY
	LDA.w !RAM_SMW_NorSpr035_Yoshi_UnknownRAM
	CLC
	ADC.b #$02
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b #!Define_SMW_MaxNormalSpriteSlot	; Loop over spites:
CODE_01F568:
	STY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID
	BEQ.b CODE_01F586
	LDA.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	BPL.b CODE_01F586
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	; \ Skip sprite if sprite status < 8
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b CODE_01F586
	LDA.w !RAM_SMW_NorSpr_CurrentLayerPriority,y	; \ Skip sprite if behind scenery
	BNE.b CODE_01F586
	PHY
	JSR.w TryEatSprite
	PLY
CODE_01F586:
	DEY
	BPL.b CODE_01F568
	JSL.l SMW_CheckForBerryTileCollisionWithYoshiTongue_Main
	RTS

TryEatSprite:
	PHX
	TYX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	PLX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return01F609
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,y			;\ Note: !Define_SMW_NorSpr_1686Prop_Inedible
	LSR								;|
	BCC.b EatSprite							;/
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; | Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	RTS				; / Return

EatSprite:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ Branch if sprite being eaten not Pokey
	CMP.b #!Define_SMW_SpriteID_NorSpr070_Pokey
	BNE.b CODE_01F5FB
	STY.w !RAM_SMW_NorSpr035_Yoshi_UnknownRAM	; $185E = Index of sprite being eaten
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.w !RAM_SMW_NorSpr_YPosLo,y
	CLC
	ADC.b #$00
	PHX
	TYX				; X = Index of sprite being eaten
	JSL.l SMW_NorSpr070_Pokey_Status08_RemovePokeySegment
	PLX
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return01F609
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr070_Pokey	; \ Sprite = Pokey
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX				; X = Index of new sprite
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Reset sprite tables
	LDX.w !RAM_SMW_NorSpr035_Yoshi_UnknownRAM	; X = Index of sprite being eaten
	LDA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	AND.b !RAM_SMW_Misc_ScratchRAM0D
	STA.w !RAM_SMW_NorSpr_Table7E00C2,y	; y = index of new sptr here??
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_Table7E1534,y
	PLX
CODE_01F5FB:
	TYA				; \ $160E,x = Index of sprite being eaten
	STA.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState,x
	LDA.b #$0A
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
Return01F609:
	RTS

DATA_01F60A:
	db $F5,$F5,$F5,$F5,$F5,$F5,$F5,$F0
	db $13,$13,$13,$13,$13,$13,$13,$18

DATA_01F61A:
	db $08,$08,$08,$08,$08,$08,$08,$13

CODE_01F622:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_DisableSpriteInteraction,x
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return01F667
	LDY.b #!Define_SMW_MaxNormalSpriteSlot
CODE_01F62B:
	STY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	TYA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_01F661
	TYA
	CMP.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	BEQ.b CODE_01F661
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID
	BEQ.b CODE_01F661
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b CODE_01F661
	LDA.w !RAM_SMW_NorSpr_SpriteID,y ; fix, overwrite accumulator nintendo?
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #$09
	BEQ.b CODE_01F661
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,y
	AND.b #!Define_SMW_NorSpr_167AProp_InvincibleToMostThings
	ORA.w !RAM_SMW_NorSpr_OnYoshisTongue,y
	ORA.w !RAM_SMW_NorSpr_CurrentLayerPriority,y
	BNE.b CODE_01F661
	JSR.w CODE_01F668
CODE_01F661:
	LDY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	DEY
	BPL.b CODE_01F62B
Return01F667:
	RTS

CODE_01F668:
	PHX
	TYX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingB
	PLX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return01F667
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr09D_BubbleWithSprite
	BEQ.b Return01F667
	CMP.b #!Define_SMW_SpriteID_NorSpr015_HorizontalCheepCheep
	BEQ.b CODE_01F69E
	CMP.b #!Define_SMW_SpriteID_NorSpr016_VerticalCheepCheep
	BEQ.b CODE_01F69E
	CMP.b #!Define_SMW_SpriteID_NorSpr004_GreenKoopa
	BCS.b CODE_01F6A3
	CMP.b #!Define_SMW_SpriteID_NorSpr002_BlueNakedKoopa
	BEQ.b CODE_01F6A3
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,y
	BPL.b CODE_01F6A3
CODE_01F695:
	PHY
	PHX
	TYX
	JSR.w SMW_KickHelplessSprite_Main
	PLX
	PLY
	RTS

CODE_01F69E:
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,y
	BEQ.b CODE_01F695
CODE_01F6A3:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr0BF_MegaMole
	BNE.b CODE_01F6B4
	LDA.b !RAM_SMW_Player_YPosLo
	SEC
	SBC.w !RAM_SMW_NorSpr_YPosLo,y
	CMP.b #$E8
	BMI.b Return01F6DC
CODE_01F6B4:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr07E_FlyingRedCoin
	BNE.b CODE_01F6DD
	LDA.w !RAM_SMW_NorSprXXX_FlyingItems_ItemToDraw,y
	BEQ.b Return01F6DC
	CMP.b #$02
	BNE.b CODE_01F6CD
	LDA.b #!Define_SMW_PlayerState08_WarpToYoshiWingsBonus
	STA.b !RAM_SMW_Player_CurrentState
	LDA.b #!Define_SMW_Sound1DFC_HitVineBlock	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_01F6CD:
	LDA.b #$40							;\ Optimization: Unused
	STA.w !RAM_SMW_UnusedRAM_7E14AA					;/
	LDA.b #$02			; \ Set Yoshi wing ability
	STA.w !RAM_SMW_Yoshi_YoshiHasWings
	LDA.b #!Define_SMW_NorSprStatus00_EmptySlot
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
Return01F6DC:
	RTS

CODE_01F6DD:
	CMP.b #!Define_SMW_SpriteID_NorSpr04E_LedgeMontyMole
	BEQ.b CODE_01F6E5
	CMP.b #!Define_SMW_SpriteID_NorSpr04D_GroundMontyMole
	BNE.b CODE_01F6EC
CODE_01F6E5:
	LDA.w !RAM_SMW_NorSprXXX_SmallMontyMole_CurrentState,y
	CMP.b #$02
	BCC.b Return01F6DC
CODE_01F6EC:
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	CLC
	ADC.b #$0D
	CMP.b !RAM_SMW_Misc_ScratchRAM01
	BMI.b Return01F74B
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked
	BNE.b CODE_01F70E
	PHX
	TYX
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	PLX
	ASL
	ROL
	AND.b #$01
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b Return01F74B
CODE_01F70E:
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario has star
	BNE.b Return01F74B
	; Subroutine that will damage Yoshi (register X should contain Yoshi's
	; sprite slot number), knocking Mario off Yoshi, making Yoshi run, and
	; triggering invincibility frames for Mario. In case you want it to check
	; for star power first, call from $01F70E instead.
	LDA.b #$10							; Glitch: Setting !RAM_SMW_Player_InAirFlag to #$24 here would fix the zip bug while in the Iggy/Larry boss fight
	STA.w !RAM_SMW_NorSpr035_Yoshi_DisableSpriteInteraction,x
	LDA.b #!Define_SMW_Sound1DFA_TurnOffYoshiDrum	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
	LDA.b #!Define_SMW_Sound1DFC_LoseYoshi	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$02
	STA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	STZ.w !RAM_SMW_Player_RidingYoshiFlag
	LDA.b #$C0
	STA.b !RAM_SMW_Player_YSpeed
	STZ.b !RAM_SMW_Player_XSpeed
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w PanicXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	STZ.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState,x
	STZ.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength,x
	STZ.w !RAM_SMW_Timer_YoshiTongueInit
	STZ.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	LDA.b #$30			; \ Mario invincible timer = #$30
	STA.w !RAM_SMW_Timer_PlayerHurt
	JSR.w CODE_01EDCC
Return01F74B:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_NonBossBoos_Status08(Address)
namespace SMW_NorSprXXX_NonBossBoos_Status08
%InsertMacroAtXPosition(<Address>)

; Maximum speed that Boo, Boo Block and Big Boo can accelerate to (first
; byte is right & down, second left & up).
MaxSpeed:
	db $08,$F8

DATA_01F8D1:
	db $01,$02,$02,$01

BigBooEntry:
	JSR.w SMW_SubOffscreen_Bank01_Entry2
	LDA.b #$20
	BRA.b CODE_01F8E1

BooEntry:
BooBlockEntry:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.b #$10
CODE_01F8E1:
	STA.w !RAM_SMW_Misc_ScratchRAM7E18B6
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_01F8EF
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_01F8F2
CODE_01F8EF:
	JMP.w CODE_01F9CE

CODE_01F8F2:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w !RAM_SMW_NorSprXXX_NonBossBoos_WaitBeforeNextFollowCheck,x
	BNE.b CODE_01F914
	LDA.b #$20
	STA.w !RAM_SMW_NorSprXXX_NonBossBoos_WaitBeforeNextFollowCheck,x
	LDA.b !RAM_SMW_NorSprXXX_NonBossBoos_FollowingMarioFlag,x
	BEQ.b CODE_01F90C
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$0A
	CMP.b #$14
	BCC.b CODE_01F92F
CODE_01F90C:
	STZ.b !RAM_SMW_NorSprXXX_NonBossBoos_FollowingMarioFlag,x
	CPY.b !RAM_SMW_Player_FacingDirection
	; Change from D0 to 80 to disable Boo from stopping when Mario looks at it.
	BNE.b CODE_01F914
	INC.b !RAM_SMW_NorSprXXX_NonBossBoos_FollowingMarioFlag,x
CODE_01F914:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$0A
	CMP.b #$14
	BCC.b CODE_01F92F
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BNE.b CODE_01F971
	TYA
	CMP.w !RAM_SMW_NorSpr_FacingDirection,x
	BEQ.b CODE_01F92F
	LDA.b #$1F			; \ Set turning timer
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BRA.b CODE_01F971

CODE_01F92F:
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b !RAM_SMW_NorSprXXX_NonBossBoos_FollowingMarioFlag,x
	BEQ.b CODE_01F989
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	CPY.b #!Define_SMW_SpriteID_NorSpr028_BigBoo
	BEQ.b CODE_01F948
	LDA.b #$00
	CPY.b #!Define_SMW_SpriteID_NorSpr0AF_BooBlock
	BEQ.b CODE_01F948
	INC
CODE_01F948:
	AND.b !RAM_SMW_Counter_GlobalFrames
	BNE.b CODE_01F96F
	INC.w !RAM_SMW_NorSprXXX_NonBossBoos_IdleAnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSprXXX_NonBossBoos_IdleAnimationFrameCounter,x
	BNE.b CODE_01F959
	LDA.b #$20
	STA.w !RAM_SMW_NorSprXXX_NonBossBoos_IdleAnimationTimer,x
CODE_01F959:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b CODE_01F962
	BPL.b CODE_01F961
	INC
	INC
CODE_01F961:
	DEC
CODE_01F962:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BEQ.b CODE_01F96D
	BPL.b CODE_01F96C
	INC
	INC
CODE_01F96C:
	DEC
CODE_01F96D:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01F96F:
	BRA.b CODE_01F9C8

CODE_01F971:
	CMP.b #$10
	BNE.b CODE_01F97F
	PHA
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	PLA
CODE_01F97F:
	LSR
	LSR
	LSR
	TAY
	LDA.w DATA_01F8D1,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
CODE_01F989:
	STZ.w !RAM_SMW_NorSprXXX_NonBossBoos_IdleAnimationFrameCounter,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	BNE.b CODE_01F9C8
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxSpeed,y
	BEQ.b CODE_01F9A2
	CLC
	ADC.w SMW_GenericNormalSpriteAccelerationTable_Main,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01F9A2:
	LDA.b !RAM_SMW_Player_CurrentYPosLo
	PHA
	; [38 ED B6 18 85 D3 A5 D4 48 E9] Change to [18 69 10 EA 85 D3 A5 D4 48 69]
	; to make the Boo/Boo Block track Mario accurately.
	SEC
	SBC.w !RAM_SMW_Misc_ScratchRAM7E18B6
	STA.b !RAM_SMW_Player_CurrentYPosLo
	LDA.b !RAM_SMW_Player_CurrentYPosHi
	PHA
	SBC.b #$00
	STA.b !RAM_SMW_Player_CurrentYPosHi
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_Y
	PLA
	STA.b !RAM_SMW_Player_CurrentYPosHi
	PLA
	STA.b !RAM_SMW_Player_CurrentYPosLo
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w MaxSpeed,y
	BEQ.b CODE_01F9C8
	CLC
	ADC.w SMW_GenericNormalSpriteAccelerationTable_Main,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01F9C8:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
CODE_01F9CE:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0AF_BooBlock
	BNE.b CODE_01FA3D
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BPL.b CODE_01F9DB
	EOR.b #$FF
	INC
CODE_01F9DB:
	LDY.b #$00
	CMP.b #$08
	BCS.b CODE_01FA09
	PHA
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	PHA
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x
	PHA
	ORA.b #!Define_SMW_NorSpr_167AProp_UseNonDefaultPlayerInteraction
	STA.w !RAM_SMW_NorSpr_PropertyBits167A,x
	LDA.b #$0C
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	JSR.w SMW_SolidSpriteBlock_Sub
	PLA
	STA.w !RAM_SMW_NorSpr_PropertyBits167A,x
	PLA
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	PLA
	LDY.b #$01
	CMP.b #$04
	BCS.b CODE_01FA15
	INY
	BRA.b CODE_01FA15

CODE_01FA09:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_01FA15
	PHY
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	PLY
CODE_01FA15:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	PHX
	TAX
	LDA.w BooBlockTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_OAMBuffer[$40].Prop,y
	AND.b #$F1
	; Change to 09 xx EA to make all three frames of the Boo Block use the same
	; palette, xx being the palette bits. Note that changing this to 02 won't
	; make any *noticeable* difference if you use the default palettes...the
	; correct setting for palette F, used for the non-block frame, makes it use
	; the EXACT same colors that are used in palette 9, for some reason.
	ORA.w BooBlockProp,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	RTS

; Boo Block Tilemap
BooBlockTiles:
	db $8C,$C8,$CA

; Boo Block Palettes
BooBlockProp:
	db $0E,$02,$02

CODE_01FA3D:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_01FA47
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
CODE_01FA47:
	JSL.l SMW_NormalSpriteBooGFXRt_Main
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NonBossBoos_Status08_BigBooEntry, SMW_NorSpr028_BigBoo_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NonBossBoos_Status08_BooEntry, SMW_NorSpr037_Boo_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_NonBossBoos_Status08_BooBlockEntry, SMW_NorSpr0AF_BooBlock_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_Eeries_Status01(Address)
namespace SMW_NorSprXXX_Eeries_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
SetInitialFrameCounter:
	JSL.l SMW_GetRand_Main
	STA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	RTS

; Horizontal speed of Eeries
XSpeed:
	db $10,$F0
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_Eeries_Status01_Main, SMW_NorSpr038_StraightEerie_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_Eeries_Status01_Main, SMW_NorSpr039_WavyEerie_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_Eeries_Status01_SetInitialFrameCounter, SMW_NorSpr028_BigBoo_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_Eeries_Status01_SetInitialFrameCounter, SMW_NorSpr037_Boo_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSprXXX_Eeries_Status08(Address)
namespace SMW_NorSprXXX_Eeries_Status08
%InsertMacroAtXPosition(<Address>)

; Vertical speed of Eerie (sprite 39)
YSpeed:
	db $18,$E8

Main:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_01F8C9
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01F8C9
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr039_WavyEerie
	BNE.b CODE_01F8C0
	LDA.b !RAM_SMW_NorSprXXX_Eeries_VerticalMovementDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w SMW_GenericNormalSpriteAccelerationTable_Main,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w YSpeed,y
	BNE.b CODE_01F8B8
	INC.b !RAM_SMW_NorSprXXX_Eeries_VerticalMovementDirection,x
CODE_01F8B8:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	JSR.w SMW_SubOffscreen_Bank01_Entry4
	BRA.b CODE_01F8C3

CODE_01F8C0:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
CODE_01F8C3:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
CODE_01F8C9:
	JSR.w SMW_SetFacingDirectionBasedOnSpeed_Bank01
	JMP.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_Eeries_Status08_Main, SMW_NorSpr038_StraightEerie_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_Eeries_Status08_Main, SMW_NorSpr039_WavyEerie_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr03D_RipVanFish_Status08(Address)
namespace SMW_NorSpr03D_RipVanFish_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	PHB
	LDA.b #Bank02>>16		;again...
	PHA
	PLB
	JSL.l Bank02
	PLB
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Note: The P-switch's "Main" state is status 09 (Stunned), so the main routine will never execute. Which is fine, because this is the code for sprite 19 (Display Message).

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr03E_PSwitch_Status01(Address)
namespace SMW_NorSpr03E_PSwitch_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $151C,x = Blue/Silver,
	LSR				; | depending on initial X position
	LSR
	LSR
	LSR
	AND.b #$01
	STA.w !RAM_SMW_NorSpr03E_PSwitch_Type,x
	TAY				; \ Store appropriate palette to RAM
	LDA.w PSwitchPal,y
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

; Colours of P-Switches (Blue, Silver)
PSwitchPal:
	db $06,$02
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_ParachutingEnemy_Status08(Address)
namespace SMW_NorSprXXX_ParachutingEnemy_Status08
%InsertMacroAtXPosition(<Address>)

DATA_01D4E7:
	db $01,$FF

DATA_01D4E9:
	db $0F,$00

DATA_01D4EB:
	db $00,$02,$04,$06,$08,$0A,$0C,$0E
	db $0E,$0C,$0A,$08,$06,$04,$02,$00

Main:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_01D505
	JMP.w CODE_01D671

CODE_01D505:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01D558
	LDA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_WaitForParachuteToDescend,x
	BNE.b CODE_01D558
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b CODE_01D51A
if defined("Define_SMW_SA1")
	JML.l Y_LOW_REMAP6
else
	INC.b !RAM_SMW_NorSpr_YPosLo,x
	BNE.b CODE_01D51A
endif
	INC.w !RAM_SMW_NorSpr_YPosHi,x
CODE_01D51A:
	LDA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_FallStraightDownFlag,x
	BNE.b CODE_01D558
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b CODE_01D53A
	LDA.b !RAM_SMW_NorSprXXX_ParachutingEnemy_SwingDirection,x
	AND.b #$01
	TAY
	LDA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_CurrentAngle,x
	CLC
	ADC.w DATA_01D4E7,y
	STA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_CurrentAngle,x
	CMP.w DATA_01D4E9,y
	BNE.b CODE_01D53A
	INC.b !RAM_SMW_NorSprXXX_ParachutingEnemy_SwingDirection,x
CODE_01D53A:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	PHA
	LDY.w !RAM_SMW_NorSprXXX_ParachutingEnemy_CurrentAngle,x
	LDA.b !RAM_SMW_NorSprXXX_ParachutingEnemy_SwingDirection,x
	LSR
	LDA.w DATA_01D4EB,y
	BCC.b CODE_01D54B
	EOR.b #$FF
	INC
CODE_01D54B:
	CLC
	ADC.b !RAM_SMW_NorSpr_XSpeed,x
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	PLA
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	BRA.b CODE_01D558

CODE_01D558:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JMP.w CODE_01D5B3

DATA_01D55E:
	db $0D,$0D,$0D,$0D,$0C,$0C,$0C,$0C
	db $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D

DATA_01D56E:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $01,$01,$01,$01,$01,$01,$01,$01

DATA_01D57E:
	db $F8,$F8,$FA,$FA,$FC,$FC,$FE,$FE
	db $02,$02,$04,$04,$06,$06,$08,$08

DATA_01D58E:
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $00,$00,$00,$00,$00,$00,$00,$00

DATA_01D59E:
	db $0E,$0E,$0F,$0F,$10,$10,$10,$10
	db $10,$10,$10,$10,$0F,$0F,$0E,$0E

DATA_01D5AE:
	db !Define_SMW_SpriteID_NorSpr00F_Goomba
	db !Define_SMW_SpriteID_NorSpr00D_BobOmb

DATA_01D5B0:
	db $01,$05,$00

CODE_01D5B3:
	STZ.w !RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteYPosOffset
	LDY.b #$F0
	LDA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_WaitForParachuteToDescend,x
	BEQ.b CODE_01D5C7
	LSR
	EOR.b #$0F
	STA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteYPosOffset
	CLC
	ADC.b #$F0
	TAY
CODE_01D5C7:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	ADC.b #$FF
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	PHA
	AND.b #$F1
	ORA.b #$06
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LDY.w !RAM_SMW_NorSprXXX_ParachutingEnemy_CurrentAngle,x
	LDA.w DATA_01D55E,y
	STA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteAnimationFrame,x
	LDA.w DATA_01D56E,y
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	PLA
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	LDY.w !RAM_SMW_NorSprXXX_ParachutingEnemy_CurrentAngle,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	CLC
	ADC.w DATA_01D57E,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	ADC.w DATA_01D58E,y
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w DATA_01D59E,y
	SEC
	SBC.w !RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteYPosOffset
	BPL.b CODE_01D627
	DEC.b !RAM_SMW_Misc_ScratchRAM00
CODE_01D627:
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteAnimationFrame,x
	SEC
	SBC.b #$0C
	CMP.b #$01
	BNE.b CODE_01D642
	CLC
	ADC.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_01D642:
	STA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteAnimationFrame,x
	LDA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_WaitForParachuteToDescend,x
	BEQ.b CODE_01D64D
	STZ.w !RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteAnimationFrame,x
CODE_01D64D:
	LDY.w !RAM_SMW_NorSprXXX_ParachutingEnemy_ParachuteAnimationFrame,x
	LDA.w DATA_01D5B0,y
	JSR.w SMW_GenericGFXRtDraw4Tiles8x8Square_Sub
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
	LDA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_WaitForParachuteToDescend,x
	BEQ.b CODE_01D693
	DEC
	BNE.b CODE_01D681
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	PLA
	PLA
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$80
	STA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_WaitForParachuteToDescend,x
CODE_01D671:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	SEC
	SBC.b #!Define_SMW_SpriteID_NorSpr03F_ParachuteGoomba
	TAY
	LDA.w DATA_01D5AE,y
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_YXPPCCCTAndPropertyTables
	RTS

CODE_01D681:
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01D68C
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
CODE_01D68C:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	BRA.b CODE_01D6B5

CODE_01D693:
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b CODE_01D6B5
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b CODE_01D6AB
	LDA.b #$01
	STA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_FallStraightDownFlag,x
	LDA.b #$07
	STA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_CurrentAngle,x
CODE_01D6AB:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01D6B5
	LDA.b #$20
	STA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_WaitForParachuteToDescend,x
CODE_01D6B5:
	PLA
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_ParachutingEnemy_Status08_Return, SMW_NorSpr069_Unused_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_ParachutingEnemy_Status08_Return, SMW_NorSpr069_Unused_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_ParachutingEnemy_Status08_Main, SMW_NorSpr03F_ParachuteGoomba_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_ParachutingEnemy_Status08_Main, SMW_NorSpr040_ParachuteBobOmb_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSprXXX_Dolphins_Status08(Address)
namespace SMW_NorSprXXX_Dolphins_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	PHB
	LDA.b #Bank02>>16
	PHA
	PLB
	JSL.l Bank02
	PLB
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_Dolphins_Status08_Main, SMW_NorSpr041_LongJumpDolphin_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_Dolphins_Status08_Main, SMW_NorSpr042_ShortJumpDolphin_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_Dolphins_Status08_Main, SMW_NorSpr043_VerticalDolphin_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr044_TorpedoTed_Status08(Address)
namespace SMW_NorSpr044_TorpedoTed_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr045_DirectionalCoins_Status08(Address)
namespace SMW_NorSpr045_DirectionalCoins_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr046_DigginChuck_Status08(Address)
namespace SMW_NorSpr046_DigginChuck_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l SMW_NorSpr091_CharginChuck_Status08_Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status08(Address)
namespace SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr048_DigginChuckRock_Status08(Address)
namespace SMW_NorSpr048_DigginChuckRock_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr049_ShiftingPipe_Status01(Address)
namespace SMW_NorSpr049_ShiftingPipe_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr049_ShiftingPipe_InitialClearTileOffset,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr049_ShiftingPipe_Status08(Address)
namespace SMW_NorSpr049_ShiftingPipe_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's horizontally offscreen

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr04A_GoalSphere_Status08(Address)
namespace SMW_NorSpr04A_GoalSphere_Status08
%InsertMacroAtXPosition(<Address>)

; Goal point sphere/boss killed code. - $018778: if you change this to [20
; 23 CD] and change $01CD23 to [9E C8 14 CE C6 13 60], it will prevent the
; player from walking after touching a goal sphere in a horizontal level. -
; $018784: it controls which music is played when it's collected.
Main:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1	; another standard graphics routine, it seems
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\
	AND.b #$1F			;|work with some routine, unkown
	ORA.b !RAM_SMW_Flag_SpritesLocked	;|
	JSR.w SMW_SpawnSparkles_GoalSphereEntry	;/
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub	; Interact with mario
	BCC.b Return			; if mario isn't there, then return
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x	;Destroy sprite, but first...
#Debug_TriggerCutsceneOnGoal:
	LDA.b #$FF
	STA.w !RAM_SMW_Timer_EndLevel
	STA.w !RAM_SMW_Misc_MusicRegisterBackup
	LDA.b #!Define_SMW_LevelMusic_PassedBoss
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
Return:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr04B_PipeLakitu_Status08(Address)
namespace SMW_NorSpr04B_PipeLakitu_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr04C_ExplodingBlock_Status01(Address)
namespace SMW_NorSpr04C_ExplodingBlock_Status01
%InsertMacroAtXPosition(<Address>)

; Sprites inside exploding turn block (Fish, Goomba, Shelless Green Koopa,
; Green Koopa)
ExplodingBlkSpr:
	db !Define_SMW_SpriteID_NorSpr015_HorizontalCheepCheep
	db !Define_SMW_SpriteID_NorSpr00F_Goomba
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr004_GreenKoopa

Main:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\
	LSR				;|
	LSR				;|sprite in exploding block
	LSR				;|depends on Xpos
	LSR				;|
	AND.b #$03			;|
	TAY				;|
	LDA.w ExplodingBlkSpr,y		;/
	STA.b !RAM_SMW_NorSpr04C_ExplodingBlock_Contents,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr04C_ExplodingBlock_Status08(Address)
namespace SMW_NorSpr04C_ExplodingBlock_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_SmallMontyMole_Status08(Address)
namespace SMW_NorSprXXX_SmallMontyMole_Status08
%InsertMacroAtXPosition(<Address>)

UNK_01E2C8:
	db $13,$14,$15,$16,$17,$18,$19 ; Possibly stomp sounds?

Main:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.b !RAM_SMW_NorSprXXX_SmallMontyMole_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

GroundMontyMolePtrs:
	dw State00_Invisible
	dw State01_AboutToEmerge
	dw State02_PopOutOfGround
	dw State03_Walking

State00_Invisible:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$60
	CMP.b #$C0
	BCS.b CODE_01E305
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BNE.b CODE_01E305
	INC.b !RAM_SMW_NorSprXXX_SmallMontyMole_CurrentState,x
	LDY.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	TAY
	LDA.b #$68
	CPY.b #!Define_SMW_Submap_SlowerEmergingMontyMoles
	BEQ.b CODE_01E302
	LDA.b #$20
CODE_01E302:
	STA.w !RAM_SMW_NorSprXXX_SmallMontyMole_WaitBeforeJumpingOutOfGround,x
CODE_01E305:
	JSR.w SMW_GetDrawInfo_Bank01
	RTS

State01_AboutToEmerge:
	LDA.w !RAM_SMW_NorSprXXX_SmallMontyMole_WaitBeforeJumpingOutOfGround,x
	ORA.w !RAM_SMW_NorSpr_OnYoshisTongue,x
	BNE.b CODE_01E343
	INC.b !RAM_SMW_NorSprXXX_SmallMontyMole_CurrentState,x
	LDA.b #$B0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank01
	BNE.b CODE_01E320
	TAY
	JSR.w SMW_BreakThrowBlock_MontyMoleEntry
CODE_01E320:
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr04E_LedgeMontyMole
	BNE.b CODE_01E343
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $9A = Sprite X position
	STA.b !RAM_SMW_Blocks_XPosLo	; | for block creation
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $98 = Sprite Y position
	STA.b !RAM_SMW_Blocks_YPosLo	; | for block creation
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.b #$08			; \ Block to generate = Mole hole
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
CODE_01E343:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr04D_GroundMontyMole
	BNE.b CODE_01E363
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	LSR
	AND.b #$01
	TAY
	LDA.w DATA_01E35F,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w DATA_01E361,y
	JSR.w SMW_GenericGFXRtDraw4Tiles8x8Square_Sub
	RTS

DATA_01E35F:
	db $01,$02

DATA_01E361:
	db $00,$05

CODE_01E363:
	LDA.b !RAM_SMW_Counter_LocalFrames
	ASL
	ASL
	AND.b #$C0
	ORA.b #$31
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	AND.b #$3F
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	RTS

State02_PopOutOfGround:
	JSR.w CODE_01E3EF
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b Return01E38E
	INC.b !RAM_SMW_NorSprXXX_SmallMontyMole_CurrentState,x
Return01E38E:
	RTS

; [$10 $F0 $18 $E8] Monty mole X speed. The first two bytes control the
; speed for the hopping mole while next two control the maximum speed for
; the chasing one.
NoFollowXSpeed:
	db $10,$F0

FollowMaxXSpeed:
	db $18,$E8

State03_Walking:
	JSR.w CODE_01E3EF
	LDA.w !RAM_SMW_NorSprXXX_SmallMontyMole_FollowMarioFlag,x
	BNE.b CODE_01E3C7
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSL.l SMW_GetRand_Main
	AND.b #$01
	BNE.b Return01E3C6
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w FollowMaxXSpeed,y
	BEQ.b Return01E3C6
	CLC
	ADC.w SMW_GenericNormalSpriteAccelerationTable_Main,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	TYA
	LSR
	ROR
	EOR.b !RAM_SMW_NorSpr_XSpeed,x
	BPL.b Return01E3C6
	JSR.w SMW_SpawnNormalSpriteTurnAroundSmoke_Main
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
Return01E3C6:
	RTS

CODE_01E3C7:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01E3E9
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	JSR.w SMW_SetNormalSpriteAnimationFrame_Main
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w NoFollowXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w !RAM_SMW_NorSprXXX_SmallMontyMole_WaitBeforeNextHop,x
	BNE.b Return01E3E8
	LDA.b #$50
	STA.w !RAM_SMW_NorSprXXX_SmallMontyMole_WaitBeforeNextHop,x
	LDA.b #$D8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return01E3E8:
	RTS

CODE_01E3E9:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

CODE_01E3EF:
	LDA.b !RAM_SMW_Sprites_TilePriority
	PHA
	LDA.w !RAM_SMW_NorSprXXX_SmallMontyMole_WaitBeforeJumpingOutOfGround,x
	BEQ.b CODE_01E3FB
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_01E3FB:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01E41C
	JSR.w SMW_NorSpr01E_Lakitu_Status08_CheckForPlayerAndNormalSpriteCollisions_Sub
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01E413
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
CODE_01E413:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b Return01E41B
	JSR.w SMW_ChangeNormalSpriteDirection_Main
Return01E41B:
	RTS

CODE_01E41C:
	PLA
	PLA
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_SmallMontyMole_Status08_Main, SMW_NorSpr04D_GroundMontyMole_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_SmallMontyMole_Status08_Main, SMW_NorSpr04E_LedgeMontyMole_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSprXXX_JumpingPiranhaPlant_Status08(Address)
namespace SMW_NorSprXXX_JumpingPiranhaPlant_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_JumpingPiranhaPlant_Status08_Main, SMW_NorSpr04F_JumpingPiranhaPlant_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_JumpingPiranhaPlant_Status08_Main, SMW_NorSpr050_FireSpittingJumpingPiranhaPlant_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr052_MovingLedgeHole_Status01(Address)
namespace SMW_NorSpr052_MovingLedgeHole_Status01
%InsertMacroAtXPosition(<Address>)

; Initialization routine for sprite 52 (moving ledge hole in ghost house)
; that simply decrements the low byte of its Y position. Lunar Magic v2.53+
; renders this routine unused by changing the initialization routine to
; $0185B7 instead. This is done in order to fix the glitch where placing the
; hole at the top of a subscreen causes its position to wrap around to the
; bottom of the subscreen.
Main:								;\ Glitch: Placing this sprite at the top of a subscreen will cause it to spawn at the bottom.
if defined("Define_SMW_SA1")
	LDA.b #$00
	NOP
else
	DEC.b !RAM_SMW_NorSpr_YPosLo,x				;| LM: ROMs edited with 2.53+ cause this routine to become unused due to FuSoYa adding a fix for this bug.
	RTS							;/
endif
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr052_MovingLedgeHole_Status08(Address)
namespace SMW_NorSpr052_MovingLedgeHole_Status08
%InsertMacroAtXPosition(<Address>)

Main:
if defined("Define_SMW_SA1")
	JSL.l Y_LOW_REMAP2
else
	JSL.l Bank02
endif
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr054_ClimbingNetDoor_Status01(Address)
namespace SMW_NorSpr054_ClimbingNetDoor_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	ADC.b #$07
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr054_ClimbingNetDoor_Status08(Address)
namespace SMW_NorSpr054_ClimbingNetDoor_Status08
%InsertMacroAtXPosition(<Address>)

UNK_01BA95:
	db $30,$54

XDisp:
	db $00,$01,$02,$04,$06,$09,$0C,$0D
	db $14,$0D,$0C,$09,$06,$04,$02,$01

AnimationFrame:
	db $00,$00,$00,$00,$00,$01,$01,$01
	db $02,$01,$01,$01,$00,$00,$00,$00

; Gate Sprite Tilemap
Tiles:
	db $00,$10,$00,$00,$10,$00,$01,$11,$01
	db $05,$15,$05,$05,$15,$05,$00,$00,$00
	db $03,$13,$03

Return01BACC:
	RTS

Main:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.w !RAM_SMW_NorSpr054_ClimbingNetDoor_WaitBeforeTurning,x
	CMP.b #$01
	BNE.b CODE_01BAF5
	LDA.b #!Define_SMW_Sound1DF9_HurtWhileFlying	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #$19
	JSL.l UpdateClimbingNetDoorTiles
	LDA.b #$1F
	STA.w !RAM_SMW_NorSpr054_ClimbingNetDoor_TurningAnimationTimer,x
	STA.w !RAM_SMW_Timer_OnSwingingClimbingNetDoor
	LDA.b !RAM_SMW_Player_XPosLo
	SEC
	SBC.b #$10
	SEC
	SBC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_Sprites_PlayerXSpeedOnSwingingNetDoor
CODE_01BAF5:
	LDA.w !RAM_SMW_NorSpr054_ClimbingNetDoor_TurningAnimationTimer,x
	ORA.w !RAM_SMW_NorSpr054_ClimbingNetDoor_WaitBeforeTurning,x
	BNE.b CODE_01BB16
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSR.w CODE_01BC1D
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b CODE_01BB16
	LDA.w !RAM_SMW_Timer_DisplayPlayerNetPunchPose
	CMP.b #$01
	BNE.b CODE_01BB16
	LDA.b #$06
	STA.w !RAM_SMW_NorSpr054_ClimbingNetDoor_WaitBeforeTurning,x
CODE_01BB16:
	LDA.w !RAM_SMW_NorSpr054_ClimbingNetDoor_TurningAnimationTimer,x
	BEQ.b Return01BACC
	CMP.b #$01
	BNE.b CODE_01BB27
	PHA
	LDA.b #$1A
	JSL.l UpdateClimbingNetDoorTiles
	PLA
CODE_01BB27:
	CMP.b #$10
	BNE.b CODE_01BB33
	LDA.w !RAM_SMW_Player_CurrentLayerPriority
	EOR.b #$01
	STA.w !RAM_SMW_Player_CurrentLayerPriority
CODE_01BB33:
if defined("Define_SMW_SA1")
	; SA-1 Pack: Don't want climbing net door setting it's own OAM index.
	JSL.l net_door_fix
	NOP
else
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
endif
	STA.b !RAM_SMW_Misc_ScratchRAM03
	TAY
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr054_ClimbingNetDoor_TurningAnimationTimer,x
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l AnimationFrame,x
else
	LDA.w AnimationFrame,x
endif
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l XDisp,x
else
	ADC.w XDisp,x
endif
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$41].XDisp,y
	STA.w SMW_OAMBuffer[$42].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	CMP.b #$02
	BEQ.b CODE_01BB8E
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$20
	SEC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	SBC.l XDisp,x
else
	SBC.w XDisp,x
endif
	STA.w SMW_OAMBuffer[$43].XDisp,y
	STA.w SMW_OAMBuffer[$44].XDisp,y
	STA.w SMW_OAMBuffer[$45].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	BNE.b CODE_01BB8E
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$46].XDisp,y
	STA.w SMW_OAMBuffer[$47].XDisp,y
	STA.w SMW_OAMBuffer[$48].XDisp,y
CODE_01BB8E:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$43].YDisp,y
	STA.w SMW_OAMBuffer[$46].YDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$41].YDisp,y
	STA.w SMW_OAMBuffer[$44].YDisp,y
	STA.w SMW_OAMBuffer[$47].YDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$42].YDisp,y
	STA.w SMW_OAMBuffer[$45].YDisp,y
	STA.w SMW_OAMBuffer[$48].YDisp,y
	LDA.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM06
	TAX
CODE_01BBBD:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
	INY
	INY
	INY
	INY
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM07
	BPL.b CODE_01BBBD
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDX.b #$08
CODE_01BBD0:
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$09
	CPX.b #$06
	BCS.b CODE_01BBDA
	ORA.b #$40
CODE_01BBDA:
	CPX.b #$00
	BEQ.b CODE_01BBE6
	CPX.b #$03
	BEQ.b CODE_01BBE6
	CPX.b #$06
	BNE.b CODE_01BBE8
CODE_01BBE6:
	ORA.b #$80
CODE_01BBE8:
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_01BBD0
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	PHA
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b #$08
	JSR.w SMW_NormalSpritePlatformGFXRt_CODE_01B37E
if defined("Define_SMW_SA1")
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
else
	LDY.b #$0C
endif
	PLA
	BEQ.b Return01BC1C
	CMP.b #$02
	BNE.b CODE_01BC11
	LDA.b #$03
	STA.w SMW_OAMTileSizeBuffer[$43].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$44].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$45].Slot,y
CODE_01BC11:
	LDA.b #$03
	STA.w SMW_OAMTileSizeBuffer[$46].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$47].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$48].Slot,y
Return01BC1C:
	RTS

CODE_01BC1D:
	LDA.b !RAM_SMW_Player_XPosLo	; \ $00 = Mario X Low
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Player_YPosLo	; \ $01 = Mario Y Low
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$10			; \ $02 = $03 = #$10
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Player_XPosHi	; \ $08 = Mario X High
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Player_YPosHi	; \ $09 = Mario Y High
	STA.b !RAM_SMW_Misc_ScratchRAM09
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr055_HorizontalCheckerboardPlatform_Status01(Address)
namespace SMW_NorSpr055_HorizontalCheckerboardPlatform_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	INC.w !RAM_SMW_NorSpr055_HorizontalCheckerboardPlatform_PlatformType,x
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr055_HorizontalCheckerboardPlatform_Status01_Main, SMW_NorSpr057_VerticalCheckerboardPlatform_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr055_HorizontalCheckerboardPlatform_Status08(Address)
namespace SMW_NorSpr055_HorizontalCheckerboardPlatform_Status08
%InsertMacroAtXPosition(<Address>)

DATA_01B268:
	db $FF,$01

DATA_01B26A:
	db $F0,$10

Main:
	JSR.w SMW_NormalSpritePlatformGFXRt_Main
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01B2C2
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	BNE.b CODE_01B2A5
	INC.b !RAM_SMW_NorSpr_Table7E00C2,x
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x
	AND.b #$03
	BNE.b CODE_01B2A5
	LDA.w !RAM_SMW_NorSpr_Table7E151C,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w DATA_01B268,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w DATA_01B26A,y
	BNE.b CODE_01B2A5
	INC.w !RAM_SMW_NorSpr_Table7E151C,x
	LDA.b #$18
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	CPY.b #!Define_SMW_SpriteID_NorSpr055_HorizontalCheckerboardPlatform
	BNE.b CODE_01B2A2
	LDA.b #$08
CODE_01B2A2:
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
CODE_01B2A5:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr057_VerticalCheckerboardPlatform
	BCS.b CODE_01B2B0
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	BRA.b CODE_01B2B6

CODE_01B2B0:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	STZ.w !RAM_SMW_Sprites_PositionDisp
CODE_01B2B6:
	LDA.w !RAM_SMW_Sprites_PositionDisp
	STA.w !RAM_SMW_NorSpr_Table7E1528,x
	JSR.w SMW_SolidSpriteBlock_Sub
	JSR.w SMW_SubOffscreen_Bank01_Entry2
Return01B2C2:
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr055_HorizontalCheckerboardPlatform_Status08_Main, SMW_NorSpr056_HorizontalRockPlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr055_HorizontalCheckerboardPlatform_Status08_Main, SMW_NorSpr057_VerticalCheckerboardPlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr055_HorizontalCheckerboardPlatform_Status08_Main, SMW_NorSpr058_VerticalRockPlatform_Status08_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NormalSpritePlatformGFXRt(Address)
namespace SMW_NormalSpritePlatformGFXRt
%InsertMacroAtXPosition(<Address>)

; For sprites 55-58 and 5B-5E, partly determines which tilemap to use. 00 ->
; wooden or checkerboard platform, 01 -> flying rock or grassy platform. The
; table offset is the sprite number minus 55, and the fifth and sixth bytes
; and the last four bytes are not used.
DATA_01B2C3:
	db $00,$01,$00,$01,$00,$00,$00,$00
	db $01,$01,$00,$00,$00,$00

Main:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	SEC
	SBC.b #!Define_SMW_SpriteID_NorSpr055_HorizontalCheckerboardPlatform
	TAY
	LDA.w DATA_01B2C3,y
	BEQ.b DrawFlatPlatform
	JMP.w DrawRockPlatform

DrawFlatPlatform:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.w !RAM_SMW_NorSpr055_HorizontalCheckerboardPlatform_PlatformType,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	STA.w SMW_OAMBuffer[$42].YDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM01
	BEQ.b CODE_01B2FF
	STA.w SMW_OAMBuffer[$43].YDisp,y
	STA.w SMW_OAMBuffer[$44].YDisp,y
CODE_01B2FF:
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$41].XDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$42].XDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM01
	BEQ.b CODE_01B326
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$43].XDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$44].XDisp,y
CODE_01B326:
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	; Change to 80 to let sprite 63 use the wooden platform tilemap only.
	; However, the size will be still different, depending on the x-pos.
	BEQ.b CODE_01B344
	LDA.b #$EA
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$EB
	STA.w SMW_OAMBuffer[$41].Tile,y
	STA.w SMW_OAMBuffer[$42].Tile,y
	STA.w SMW_OAMBuffer[$43].Tile,y
	LDA.b #$EC
	STA.w SMW_OAMBuffer[$44].Tile,y
	BRA.b CODE_01B359

CODE_01B344:
	LDA.b #$60
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$61
	STA.w SMW_OAMBuffer[$41].Tile,y
	STA.w SMW_OAMBuffer[$42].Tile,y
	STA.w SMW_OAMBuffer[$43].Tile,y
	LDA.b #$62
	STA.w SMW_OAMBuffer[$44].Tile,y
CODE_01B359:
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	STA.w SMW_OAMBuffer[$42].Prop,y
	STA.w SMW_OAMBuffer[$43].Prop,y
	STA.w SMW_OAMBuffer[$44].Prop,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b CODE_01B376
	LDA.b #$62
	STA.w SMW_OAMBuffer[$42].Tile,y
CODE_01B376:
	LDA.b #$04
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b CODE_01B37E
	LDA.b #$02
CODE_01B37E:
	LDY.b #$02
	JMP.w SMW_FinishOAMWrite_Sub

; Grassy Orange Platform Tilemap (sprites 5D and 5E)
DiagPlatTiles:
	db $CB,$E4,$CC,$E5,$CC,$E5,$CC,$E4
	db $CB

; Flying Rock Platform Tilemap (Sprites 56 and 58)
UNK_FlyRockPlatTiles:
	db $85,$88,$86,$89,$86,$89,$86,$88
	db $85

DrawRockPlatform:
	JSR.w SMW_GetDrawInfo_Bank01
	PHY
	LDY.b #$00
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr05E_FloatingOrangePlatform
	BNE.b CODE_01B3A2
	INY
CODE_01B3A2:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	PLY
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$42].YDisp,y
	STA.w SMW_OAMBuffer[$44].YDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	BEQ.b CODE_01B3BD
	STA.w SMW_OAMBuffer[$46].YDisp,y
	STA.w SMW_OAMBuffer[$48].YDisp,y
CODE_01B3BD:
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$41].YDisp,y
	STA.w SMW_OAMBuffer[$43].YDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	BEQ.b CODE_01B3D0
	STA.w SMW_OAMBuffer[$45].YDisp,y
	STA.w SMW_OAMBuffer[$47].YDisp,y
CODE_01B3D0:
	LDA.b #$08
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_01B3D8
	LDA.b #$04
CODE_01B3D8:
	STA.b !RAM_SMW_Misc_ScratchRAM01
	DEC
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr05B_BrownBuoyantPlatform
	LDA.b #$00
	BCS.b CODE_01B3EF
	LDA.b #$09
CODE_01B3EF:
	PHA
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	PLX
CODE_01B3F6:
	STA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$08
	PHA
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DiagPlatTiles,x
else
	LDA.w DiagPlatTiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM01
	CPX.b !RAM_SMW_Misc_ScratchRAM02
	PLX
	BCS.b CODE_01B411
	ORA.b #$40
CODE_01B411:
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
	INY
	INY
	INY
	INY
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM01
	BPL.b CODE_01B3F6
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_01B444
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr05B_BrownBuoyantPlatform
	BCS.b CODE_01B43A
	LDA.b #$85
	STA.w SMW_OAMBuffer[$44].Tile,y
	LDA.b #$88
	STA.w SMW_OAMBuffer[$43].Tile,y
	BRA.b CODE_01B444

CODE_01B43A:
	LDA.b #$CB
	STA.w SMW_OAMBuffer[$44].Tile,y
	LDA.b #$E4
	STA.w SMW_OAMBuffer[$43].Tile,y
CODE_01B444:
	LDA.b #$08
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_01B44C
	LDA.b #$04
CODE_01B44C:
	JMP.w CODE_01B37E
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSprXXX_TurnBlockBridge_Status08(Address)
namespace SMW_NorSprXXX_TurnBlockBridge_Status08
%InsertMacroAtXPosition(<Address>)

; Length of Turn Block Bridge (sprites 59 and 5A)
BlkBridgeLength:
	db $20,$00

; X speed of Turn Block Bridge (sprites 59 and 5A)
TurnBlkBridgeSpeed:
	db $01,$FF

; Time of Turn Block Bridge (sprites 59 and 5A)
BlkBridgeTiming:
	db $40,$40

HorizontalAndVerticalTurnBlockBridgeEntry:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w GFXRt
	JSR.w CODE_01B852
	JSR.w CODE_01B6B2
	RTS

CODE_01B6B2:
	LDA.b !RAM_SMW_NorSprXXX_TurnBlockBridge_MovementState,x
	AND.b #$01
	TAY
	LDA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_ExtendDistance,x
	CMP.w BlkBridgeLength,y
	BEQ.b CODE_01B6D1
	LDA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_WaitBeforeExtending,x
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return01B6D0
	LDA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_ExtendDistance,x
	CLC
	ADC.w TurnBlkBridgeSpeed,y
	STA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_ExtendDistance,x
Return01B6D0:
	RTS

CODE_01B6D1:
	LDA.w BlkBridgeTiming,y
	STA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_WaitBeforeExtending,x
	INC.b !RAM_SMW_NorSprXXX_TurnBlockBridge_MovementState,x
	RTS

HorizontalTurnBlockBridgeEntry:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w GFXRt
	JSR.w CODE_01B852
	JSR.w CODE_01B6E7
	RTS

CODE_01B6E7:
	LDY.b !RAM_SMW_NorSprXXX_TurnBlockBridge_MovementState,x
	LDA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_ExtendDistance,x
	CMP.w BlkBridgeLength,y
	BEQ.b CODE_01B703
	LDA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_WaitBeforeExtending,x
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return01B702
	LDA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_ExtendDistance,x
	CLC
	ADC.w TurnBlkBridgeSpeed,y
	STA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_ExtendDistance,x
Return01B702:
	RTS

CODE_01B703:
	LDA.w BlkBridgeTiming,y
	STA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_WaitBeforeExtending,x
	LDA.b !RAM_SMW_NorSprXXX_TurnBlockBridge_MovementState,x
	EOR.b #$01
	STA.b !RAM_SMW_NorSprXXX_TurnBlockBridge_MovementState,x
	RTS

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank01
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	STZ.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_NorSprXXX_TurnBlockBridge_MovementState,x
	AND.b #$02
	TAY
	LDA.w !RAM_SMW_NorSprXXX_TurnBlockBridge_ExtendDistance,x
	STA.w !RAM_SMW_Misc_ScratchRAM00,y
	LSR
	STA.w !RAM_SMW_Misc_ScratchRAM01,y
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$44].YDisp,y
	PHA
	PHA
	PHA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$42].YDisp,y
	PLA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM03
	STA.w SMW_OAMBuffer[$43].YDisp,y
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$44].XDisp,y
	PHA
	PHA
	PHA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$42].XDisp,y
	PLA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$43].XDisp,y
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_NorSprXXX_TurnBlockBridge_MovementState,x
	LSR
	LSR
	LDA.b #$40
	STA.w SMW_OAMBuffer[$41].Tile,y
	STA.w SMW_OAMBuffer[$43].Tile,y
	STA.w SMW_OAMBuffer[$44].Tile,y
	STA.w SMW_OAMBuffer[$42].Tile,y
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	; Change to [09 xx 99 07 03 99 0B 03 99 0F 03 99 13 03] to change the
	; palette used by the turn block bridge. ("xx" is the new palette value; 00
	; is the original.) This also prevents the last tile from being X-flipped.
	STA.w SMW_OAMBuffer[$43].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	STA.w SMW_OAMBuffer[$42].Prop,y
	STA.w SMW_OAMBuffer[$44].Prop,y
	ORA.b #$60							; Note: I wonder why Nintendo made the first tile have a different priority and X flip?
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	PHA
	LDA.b #$04
	JSR.w SMW_NormalSpritePlatformGFXRt_CODE_01B37E
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_TurnBlockBridge_Status08_HorizontalAndVerticalTurnBlockBridgeEntry, SMW_NorSpr059_HorizontalAndVerticalTurnBlockBridge_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_TurnBlockBridge_Status08_HorizontalTurnBlockBridgeEntry, SMW_NorSpr05A_HorizontalTurnBlockBridge_Status08_Main)
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_TurnBlockBridge_Status08(Address)
namespace SMW_NorSprXXX_TurnBlockBridge_Status08
%InsertMacroAtXPosition(<Address>)

Return01B851:
	RTS ; Unused

CODE_01B852:
	LDA.w !RAM_SMW_NorSpr_Table7E15C4,x
	BNE.b Return01B8B1
	LDA.b !RAM_SMW_Player_CurrentState
	CMP.b #!Define_SMW_PlayerState01_PowerDown
	BCS.b Return01B8B1
	JSR.w CODE_01B8FF
	BCC.b Return01B8B1
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0D
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	CLC
	ADC.b #$18
	CMP.b !RAM_SMW_Misc_ScratchRAM09
	BCS.b ADDR_01B8B2
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return01B8B1
	STZ.b !RAM_SMW_Player_YSpeed
	LDA.b #$01
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	LDA.b !RAM_SMW_Misc_ScratchRAM0D
	CLC
	ADC.b #$1F
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01B88F
	CLC
	ADC.b #$10
CODE_01B88F:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	LDY.b #$00
	LDA.w !RAM_SMW_Sprites_PositionDisp
	BPL.b CODE_01B8A7
	DEY
CODE_01B8A7:
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	TYA
	ADC.b !RAM_SMW_Player_XPosHi
	STA.b !RAM_SMW_Player_XPosHi
Return01B8B1:
	RTS

ADDR_01B8B2:
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0D
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$FF
	LDY.b !RAM_SMW_Player_DuckingFlag
	BNE.b ADDR_01B8C3
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b ADDR_01B8C5
ADDR_01B8C3:
	LDA.b #$08
ADDR_01B8C5:
	CLC
	ADC.b !RAM_SMW_Player_OnScreenPosYLo
	CMP.b !RAM_SMW_Misc_ScratchRAM02
	BCC.b ADDR_01B8D5
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b Return01B8D4
	LDA.b #$10
	STA.b !RAM_SMW_Player_YSpeed
Return01B8D4:
	RTS

ADDR_01B8D5:
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b #$00
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b !RAM_SMW_Player_OnScreenPosXLo
	BCC.b ADDR_01B8EF
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM00
	DEY
ADDR_01B8EF:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Player_XPosLo
	TYA
	ADC.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Player_XPosHi
	STZ.b !RAM_SMW_Player_XSpeed
	RTS

CODE_01B8FF:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	ASL
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM07
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01(Address)
namespace SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01
%InsertMacroAtXPosition(<Address>)

; Table of X speeds for the floating spike ball (sprite A4). In order: Slow
; right, slow left, fast right, fast left.
InitialXSpeed:
	db $08,$F8,$10,$F0

SpikeBallEntry:
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	LDY.w !RAM_SMW_NorSpr_Table7E157C,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	AND.b #$10
	BEQ.b CODE_01B224
	INY
	INY
CODE_01B224:
	LDA.w InitialXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	BRA.b InitFloatingPlat

BuoyantCheckboardPlatformEntry:
	INC.w !RAM_SMW_NorSpr_Table7E1602,x
; The code that checks the sprite buoyancy to determine whether sprites 5C
; and 5E should float on water or be suspended in the air. You can change
; this to 80 03 xx xx xx (xx can by any byte) to make them always stay in
; air or to 80 06 xx xx xx to make them always float.
FloatingOrangePlatformEntry:
	LDA.w !RAM_SMW_Sprites_SpriteBuoyancySettings
	BNE.b InitFloatingPlat
	INC.b !RAM_SMW_NorSpr_Table7E00C2,x
	RTS

InitFloatingPlat:
BrownBuoyantPlatformEntry:
OrangeBuoyantPlatformEntry:
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr_Table7E151C,x
CODE_01B23B:
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BNE.b Return
	DEC.w !RAM_SMW_NorSpr_Table7E151C,x
	BMI.b CODE_01B262
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	CMP.b #$02
	BCS.b Return						;\ Optimization: Save 2 bytes by changing this to BCC.b CODE_01B23B and removing the BRA.b.
	BRA.b CODE_01B23B					;/

Return:
HorizontalRockPlatformEntry:
VerticalRockPlatformEntry:
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01_HorizontalRockPlatformEntry, SMW_NorSpr056_HorizontalRockPlatform_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01_VerticalRockPlatformEntry, SMW_NorSpr058_VerticalRockPlatform_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01_BrownBuoyantPlatformEntry, SMW_NorSpr05B_BrownBuoyantPlatform_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01_BuoyantCheckboardPlatformEntry, SMW_NorSpr05C_BuoyantCheckboardPlatform_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01_OrangeBuoyantPlatformEntry, SMW_NorSpr05D_OrangeBuoyantPlatform_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01_FloatingOrangePlatformEntry, SMW_NorSpr05E_FloatingOrangePlatform_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01_SpikeBallEntry, SMW_NorSpr0A4_SpikeBall_Status01_Main)
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01(Address)
namespace SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01
%InsertMacroAtXPosition(<Address>)

CODE_01B262:
	LDA.b #!Define_SMW_NorSprStatus01_Init	; \ Sprite status = Initialization
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
HorizontalAndVerticalTurnBlockBridgeEntry:
HorizontalTurnBlockBridgeEntry:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01_HorizontalAndVerticalTurnBlockBridgeEntry, SMW_NorSpr059_HorizontalAndVerticalTurnBlockBridge_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status01_HorizontalTurnBlockBridgeEntry, SMW_NorSpr05A_HorizontalTurnBlockBridge_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSprXXX_BuoyantPlatformsAndMine_Status08(Address)
namespace SMW_NorSprXXX_BuoyantPlatformsAndMine_Status08
%InsertMacroAtXPosition(<Address>)

FloatingOrangePlatformEntry:
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x
	BEQ.b CODE_01B563
	JSR.w SMW_NormalSpritePlatformGFXRt_Main
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01B558
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	LDA.w !RAM_SMW_Sprites_PositionDisp
	STA.w !RAM_SMW_NorSpr_Table7E1528,x
	JSR.w SMW_SolidSpriteBlock_Sub
	BCC.b Return01B558
	LDA.b #$01
	STA.w !RAM_SMW_Flag_ActiveFastBackgroundScrollGenerator
	LDA.b #$08
	STA.b !RAM_SMW_NorSpr_XSpeed,x
Return01B558:
	RTS

SpikeBallEntry:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_01B563
	JMP.w SpikeBallGFXRt

CODE_01B563:
BrownBuoyantPlatformEntry:
BuoyantCheckboardPlatformEntry:
OrangeBuoyantPlatformEntry:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_01B56A
	JMP.w CODE_01B64E

CODE_01B56A:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$0C
	BNE.b CODE_01B574
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
CODE_01B574:
	STZ.w !RAM_SMW_Sprites_PositionDisp
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0A4_SpikeBall
	BNE.b CODE_01B580
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
CODE_01B580:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$40
	BPL.b CODE_01B588
	INC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01B588:
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BEQ.b CODE_01B5A6
	LDY.b #$F8
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr05D_OrangeBuoyantPlatform
	BCC.b CODE_01B597
	LDY.b #$FC
CODE_01B597:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BPL.b CODE_01B5A1
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b CODE_01B5A6
CODE_01B5A1:
	SEC
	SBC.b #$02
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01B5A6:
	LDA.b !RAM_SMW_Player_YSpeed
	PHA
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0A4_SpikeBall
	BNE.b CODE_01B5B5
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	CLC
	BRA.b CODE_01B5B8

CODE_01B5B5:
	JSR.w SMW_SolidSpriteBlock_Sub
CODE_01B5B8:
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.w !RAM_SMW_Misc_ScratchRAM7E185E
	BCC.b CODE_01B5E7
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr05D_OrangeBuoyantPlatform
	BCC.b CODE_01B5DA
	LDY.b #$03
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_01B5CD
	DEY
CODE_01B5CD:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_01B5DA
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01B5DA:
	INC.w !RAM_SMW_Misc_ScratchRAM7E185E
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$20
	BCC.b CODE_01B5E7
	LSR
	LSR
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01B5E7:
	LDA.w !RAM_SMW_Misc_ScratchRAM7E185E
	CMP.w !RAM_SMW_NorSpr_Table7E151C,x
	STA.w !RAM_SMW_NorSpr_Table7E151C,x
	BEQ.b CODE_01B610
	LDA.w !RAM_SMW_Misc_ScratchRAM7E185E
	BNE.b CODE_01B610
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_01B610
	LDY.b #$08
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_01B603
	LDY.b #$06
CODE_01B603:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$20
	BPL.b CODE_01B610
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01B610:
	LDA.b #$01
	AND.b !RAM_SMW_Counter_GlobalFrames
	BNE.b CODE_01B64E
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BEQ.b CODE_01B624
	BPL.b CODE_01B61F
	CLC
	ADC.b #$02
CODE_01B61F:
	SEC
	SBC.b #$01
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01B624:
	LDY.w !RAM_SMW_Misc_ScratchRAM7E185E
	BEQ.b CODE_01B631
	LDY.b #$05
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_01B631
	LDY.b #$02
CODE_01B631:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
CODE_01B64E:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0A4_SpikeBall
	BEQ.b SpikeBallGFXRt
	JMP.w SMW_NormalSpritePlatformGFXRt_Main

; X displacement for each tile of the floating spike ball (sprite A4). In
; order: Top left, top right, bottom left, bottom right.
SpikeBallXDisp:
	db $F8,$08,$F8,$08

; Y displacement for each tile of the floating spike ball (sprite A4). In
; order: Top left, top right, bottom left, bottom right.
SpikeBallYDisp:
	db $F8,$F8,$08,$08

; Tile properties for each tile of the floating spike ball (sprite A4). In
; order: Top left, top right, bottom left, bottom right.
SpikeBallProp:
	db $31,$71,$A1,$F1

; The GFX routine for the floating spike ball (sprite A4). $01B686 controls
; the first tile number used, and the second is always one 16x16 tile to the
; right of that.
SpikeBallGFXRt:
	JSR.w SMW_GetDrawInfo_Bank01
	PHX
	LDX.b #$03
CODE_01B66C:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w SpikeBallXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w SpikeBallYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$04
	LSR
	ADC.b #$AA
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SpikeBallProp,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_01B66C
	PLX
	LDY.b #$02
	LDA.b #$03
	JMP.w SMW_FinishOAMWrite_Sub
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status08_BrownBuoyantPlatformEntry, SMW_NorSpr05B_BrownBuoyantPlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status08_BuoyantCheckboardPlatformEntry, SMW_NorSpr05C_BuoyantCheckboardPlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status08_OrangeBuoyantPlatformEntry, SMW_NorSpr05D_OrangeBuoyantPlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status08_FloatingOrangePlatformEntry, SMW_NorSpr05E_FloatingOrangePlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_BuoyantPlatformsAndMine_Status08_SpikeBallEntry, SMW_NorSpr0A4_SpikeBall_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr05F_BrownChainedPlatform_Status01(Address)
namespace SMW_NorSpr05F_BrownChainedPlatform_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo,x
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$78
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$68
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr05F_BrownChainedPlatform_Status08(Address)
namespace SMW_NorSpr05F_BrownChainedPlatform_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_SubOffscreen_Bank01_Entry3
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01C795
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	ORA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_PlayerOnPlatformFlag,x
	BNE.b CODE_01C795
	LDA.b #$01
	LDY.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleSpeed,x
	BEQ.b CODE_01C795
	BMI.b CODE_01C78E
	LDA.b #$FF
CODE_01C78E:
	CLC
	ADC.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleSpeed,x
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleSpeed,x
CODE_01C795:
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo,x
	PHA
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi,x
	PHA
	LDA.b #$00
	SEC
	SBC.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo,x
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo,x
	LDA.b #$02
	SBC.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi,x
	AND.b #$01
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi,x
	JSR.w CODE_01CACB
	JSR.w SMW_GetSineAndCosineOfTiltingPlatform_Main
	JSR.w SMW_CalculateCircleCoordinatesForTiltingPlaform_Main
	PLA
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi,x
	PLA
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo,x
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosLo
	PHA
	SEC
	SBC.b !RAM_SMW_NorSpr05F_BrownChainedPlatform_PreviousXPos,x
	STA.w !RAM_SMW_Sprites_PositionDisp
	PLA
	STA.b !RAM_SMW_NorSpr05F_BrownChainedPlatform_PreviousXPos,x
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b #$A2
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$31
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosLo
	SEC
	SBC.w !RAM_SMW_Misc_RotatingObjectCenterYPosLo
	BPL.b CODE_01C802
	EOR.b #$FF
	INC
	INY
CODE_01C802:
	STY.b !RAM_SMW_Misc_ScratchRAM00
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/01C804.asm"
namespace SMW_NorSpr05F_BrownChainedPlatform_Status08
else
	STA.w !REGISTER_DividendHi	; Dividend (High-Byte)
	STZ.w !REGISTER_DividendLo	; Dividend (Low Byte)
	LDA.b #$05
	STA.w !REGISTER_Divisor		; Divisor B
	JSR.w SMW_WasteTime_Main
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w !REGISTER_QuotientHi	; Quotient of Divide Result (High Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosLo
	SEC
	SBC.w !RAM_SMW_Misc_RotatingObjectCenterXPosLo
	BPL.b CODE_01C82F
	EOR.b #$FF
	INC
	INY
CODE_01C82F:
	STY.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !REGISTER_DividendHi	; Dividend (High-Byte)
	STZ.w !REGISTER_DividendLo	; Dividend (Low Byte)
	LDA.b #$05
	STA.w !REGISTER_Divisor		; Divisor B
	JSR.w SMW_WasteTime_Main
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w !REGISTER_QuotientHi	; Quotient of Divide Result (High Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM05
	STA.b !RAM_SMW_Misc_ScratchRAM09
endif
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	INY
	INY
	INY
	INY
	LDA.w !RAM_SMW_Misc_RotatingObjectCenterYPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w !RAM_SMW_Misc_RotatingObjectCenterXPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b #$A2
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$31
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDX.b #$03
CODE_01C87C:
	INY
	INY
	INY
	INY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_01C88E
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM07
	STA.w SMW_OAMBuffer[$40].YDisp,y
	BRA.b CODE_01C896

CODE_01C88E:
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM07
	STA.w SMW_OAMBuffer[$40].YDisp,y
CODE_01C896:
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b CODE_01C8B1
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM09
	STA.w SMW_OAMBuffer[$40].XDisp,y
	BRA.b CODE_01C8B9

CODE_01C8B1:
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM09
	STA.w SMW_OAMBuffer[$40].XDisp,y
CODE_01C8B9:
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	ADC.b !RAM_SMW_Misc_ScratchRAM05
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b #$A2
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$31
	STA.w SMW_OAMBuffer[$40].Prop,y
	DEX
	BPL.b CODE_01C87C
	LDX.b #$03
CODE_01C8D5:
	STX.b !RAM_SMW_Misc_ScratchRAM02
	INY
	INY
	INY
	INY
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	SEC
	SBC.b #$10
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w PlatformXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w PlatformTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$31
	STA.w SMW_OAMBuffer[$40].Prop,y
	DEX
	BPL.b CODE_01C8D5
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b #$09
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w !RAM_SMW_Misc_RotatingObjectCenterYPosLo
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Misc_RotatingObjectCenterYPosHi
	SBC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_Misc_RotatingObjectCenterXPosLo
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Misc_RotatingObjectCenterXPosHi
	SBC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$41].YDisp,y
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w SMW_OAMBuffer[$41].XDisp,y
	STA.b !RAM_SMW_Misc_ScratchRAM07
CODE_01C934:
	TYA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x
	LDX.b #$00
	LDA.w SMW_OAMBuffer[$40].XDisp,y
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM07
	BPL.b CODE_01C948
	DEX
CODE_01C948:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM04
	TXA
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM05
	JSR.w SMW_FinishOAMWrite_CODE_01B844
	BCC.b CODE_01C960
	TYA
	LSR
	LSR
	TAX
	LDA.b #$03
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x
CODE_01C960:
	LDX.b #$00
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM06
	BPL.b CODE_01C96B
	DEX
CODE_01C96B:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM09
	TXA
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	JSR.w CODE_01C9BF
	BCC.b CODE_01C97F
	LDA.b #$F0
	STA.w SMW_OAMBuffer[$40].YDisp,y
CODE_01C97F:
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.b #$09
	BNE.b CODE_01C999
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosLo
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosLo
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosHi
CODE_01C999:
	INY
	INY
	INY
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM08
	BPL.b CODE_01C934
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$F0
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01C9B6
	JSR.w UpdateRotatingPlatformAngle
	JMP.w CODE_01C9EC

Return01C9B6:
	RTS

PlatformXDisp:
	db $E0,$F0,$00,$10

; Tilemap: Brown Swinging Platform (Sprite 5F)
PlatformTiles:
	db $60,$61,$61,$62

CODE_01C9BF:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	PHA
	CLC
	ADC.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM09
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.w #$0100
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM09
	SEP.b #$20			; A->8
Return01C9D5:
	RTS

DATA_01C9D6:
	db $01,$FF

DATA_01C9D8:
	db $40,$C0

CODE_01C9DA:
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_PlayerIsTouchingPlatformFlag,x
	BEQ.b Return01C9EB
	STZ.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_PlayerIsTouchingPlatformFlag,x
CODE_01C9E2:
	PHX
	JSL.l SMW_PlayerGFXRt_Main
	PLX
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
Return01C9EB:
	RTS

CODE_01C9EC:
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosHi
	XBA
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosLo
	REP.b #$20			; A->16
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w #$0010
	CMP.w #$0120
	SEP.b #$20			; A->8
	ROL
	AND.b #$01
	ORA.b !RAM_SMW_Flag_SpritesLocked
	STA.w !RAM_SMW_NorSpr_Table7E15C4,x
	BNE.b Return01C9D5
	JSR.w CODE_01CA9C
	STZ.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_PlayerOnPlatformFlag,x
	BCC.b CODE_01C9DA
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_PlayerIsTouchingPlatformFlag,x
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM03
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	CLC
	ADC.b #$18
	CMP.b !RAM_SMW_Misc_ScratchRAM0E
	BCS.b Return01CA9B
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_01C9E2
	STZ.b !RAM_SMW_Player_YSpeed
	LDA.b #$03
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_PlayerOnPlatformFlag,x
	LDA.b #$28
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01CA45
	LDA.b #$38
CODE_01CA45:
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0F
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosHi
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b !RAM_SMW_Player_BlockedFlags
	AND.b #$03
	BNE.b CODE_01CA6E
	LDY.b #$00
	LDA.w !RAM_SMW_Sprites_PositionDisp
	BPL.b CODE_01CA64
	DEY
CODE_01CA64:
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	TYA
	ADC.b !RAM_SMW_Player_XPosHi
	STA.b !RAM_SMW_Player_XPosHi
CODE_01CA6E:
	JSR.w CODE_01C9E2
	LDA.b !RAM_SMW_IO_ControllerPress1
	BMI.b CODE_01CA79
	LDA.b #$FF
	STA.b !RAM_SMW_Player_HidePlayerTileFlags
CODE_01CA79:
if ver_is_pal(!Define_Global_ROMToAssemble) == 0
	LDA.b !RAM_SMW_Counter_GlobalFrames	;!
	LSR				;!
	BCC.b Return01CA9B		;!
endif
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo,x	;!
	CLC				;!
	ADC.b #$80			;!
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi,x	;!
	ADC.b #$00			;!
	AND.b #$01			;!
	TAY				;!
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleSpeed,x
	BEQ.b +
	EOR.w DATA_01C9D8,y
	BPL.b +
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b Return01CA9B
+:
endif
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleSpeed,x
	CMP.w DATA_01C9D8,y
	BEQ.b Return01CA9B
	CLC
	ADC.w DATA_01C9D6,y
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleSpeed,x
Return01CA9B:
	RTS

CODE_01CA9C:
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosLo
	SEC
	SBC.b #$18
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileXPosHi
	SBC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b #$40
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosLo
	SEC
	SBC.b #$0C
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_ChainTileYPosHi
	SBC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.b #$13
	STA.b !RAM_SMW_Misc_ScratchRAM07
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	RTS

; Sprite rotation preparation routine. First JSR to this, then to $01CB20
; and finally to $01CB53.
CODE_01CACB:
	LDA.b #$50
	STA.w !RAM_SMW_Misc_RotatingObjectXRadiusLo
	STZ.w !RAM_SMW_Misc_RotatingObjectYRadiusLo
	STZ.w !RAM_SMW_Misc_RotatingObjectXRadiusHi
	STZ.w !RAM_SMW_Misc_RotatingObjectYRadiusHi
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_XAngleSpeedLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_XAngleSpeedHi
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_XAngleSpeedLo
	SEC
	SBC.w !RAM_SMW_Misc_RotatingObjectXRadiusLo
	STA.w !RAM_SMW_Misc_RotatingObjectCenterXPosLo
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_XAngleSpeedHi
	SBC.w !RAM_SMW_Misc_RotatingObjectXRadiusHi
	STA.w !RAM_SMW_Misc_RotatingObjectCenterXPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_YAngleSpeedLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_YAngleSpeedHi
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_YAngleSpeedLo
	SEC
	SBC.w !RAM_SMW_Misc_RotatingObjectYRadiusLo
	STA.w !RAM_SMW_Misc_RotatingObjectCenterYPosLo
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_YAngleSpeedHi
	SBC.w !RAM_SMW_Misc_RotatingObjectYRadiusHi
	STA.w !RAM_SMW_Misc_RotatingObjectCenterYPosHi
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo,x
	STA.b !RAM_SMW_Misc_M7RotationLo
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi,x
	STA.b !RAM_SMW_Misc_M7RotationHi
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr05F_BrownChainedPlatform_Status08(Address)
namespace SMW_NorSpr05F_BrownChainedPlatform_Status08
%InsertMacroAtXPosition(<Address>)

UpdateRotatingPlatformAngle:
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleSpeed,x
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_SubAngle,x
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_SubAngle,x
	PHP
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleSpeed,x
	LSR
	LSR
	LSR
	LSR
	CMP.b #$08
	BCC.b CODE_01CD0F
	ORA.b #$F0
	DEY
CODE_01CD0F:
	PLP
	ADC.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo,x
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleLo,x
	TYA
	ADC.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi,x
	STA.w !RAM_SMW_NorSpr05F_BrownChainedPlatform_AngleHi,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr060_FlatPalaceSwitch_Status01(Address)
namespace SMW_NorSpr060_FlatPalaceSwitch_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr060_FlatPalaceSwitch_Status08(Address)
namespace SMW_NorSpr060_FlatPalaceSwitch_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr061_SkullRaft_Status01(Address)
namespace SMW_NorSpr061_SkullRaft_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr061_SkullRaft_Status08(Address)
namespace SMW_NorSpr061_SkullRaft_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_LineGuidedSprites_Status01(Address)
namespace SMW_NorSprXXX_LineGuidedSprites_Status01
%InsertMacroAtXPosition(<Address>)

LineGuideRopeEntry:
	CPX.b #$06
	BCC.b CODE_01D6E0
	LDA.w !RAM_SMW_Sprites_SpriteMemorySetting
	BEQ.b CODE_01D6E0
	INC.w !RAM_SMW_NorSpr_PropertyBits1662,x
	BRA.b CODE_01D6E0

; The code that determines whether sprite 63 should be brown or checkered.
; Change to "A9 xx EA EA EA EA" to make the platform always brown or always
; checkered (if brown, xx = 00, if checkered, xx = 01). - $01D6D5: change to
; 00 to make sprite 63 use the small wooden platform no matter which
; x-position. (to use with $01D6D7) - $01D6D7: change to 00 to make sprite
; 63 use the small wooden platform no matter which x-position. (to use with
; $01D6D5)
CheckerboardLineGuidePlatformEntry:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	AND.b #$10
	EOR.b #$10
	STA.w !RAM_SMW_NorSpr062_BrownLineGuidePlatform_PlatformType,x
	BEQ.b CODE_01D6E0
	INC.w !RAM_SMW_NorSpr_PropertyBits1662,x
CODE_01D6E0:
	INC.w !RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide,x
	JSR.w SMW_NorSprXXX_LineGuidedSprites_Status08_LineFuzzyPlats
	JSR.w SMW_NorSprXXX_LineGuidedSprites_Status08_LineFuzzyPlats
	INC.w !RAM_SMW_NorSprXXX_LineGuidedSprites_IsNotMovingFlag,x
Return01D6EC:
	RTS

; Change to EA EA EA to make all line-guided sprites move at the same speed
; instead of the chainsaws, Grinder, and Fuzzy going twice as fast.
ChainsawEntry:
UpsideDownChainsawEntry:
LineGuideGrinderEntry:
LineGuideFuzzyEntry:
	INC.w !RAM_SMW_NorSprXXX_LineGuidedSprites_FasterMovementFlag,x
	; Change to B5 E4 29 10 4A 4A 4A 4A 9D 7C 15 80 14 EA EA EA EA EA EA EA EA
	; EA EA to fix certain line-guided sprites: instead of moving left on odd
	; starting X positions and not showing up at all on even ones (actually,
	; they are just shifted offscreen), they will instead move right on even
	; starting X positions. x$01D6FA - X position (low byte) of sprites 65, 66,
	; 67 and 68. Change it to 0F to fix its x position when it goes to the
	; right. (USE WITH $01D701) $01D701 - X position (high byte) of sprites 65,
	; 66, 67 and 68. Change it to 00 to fix its x position when it goes to the
	; right. (USE WITH $01D6FA)
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	AND.b #$10
	BNE.b CODE_01D707
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b #$40
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b #$01
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	BRA.b BrownLineGuidePlatformEntry

CODE_01D707:
	INC.w !RAM_SMW_NorSprXXX_LineGuidedSprites_MovementDirection,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$0F
	STA.b !RAM_SMW_NorSpr_XPosLo_x
BrownLineGuidePlatformEntry:
	LDA.b #$02
	STA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide,x
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status01_LineGuideRopeEntry, SMW_NorSpr064_LineGuideRope_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status01_CheckerboardLineGuidePlatformEntry, SMW_NorSpr063_CheckerboardLineGuidePlatform_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status01_ChainsawEntry, SMW_NorSpr065_Chainsaw_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status01_UpsideDownChainsawEntry, SMW_NorSpr066_UpsideDownChainsaw_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status01_LineGuideGrinderEntry, SMW_NorSpr067_LineGuideGrinder_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status01_LineGuideFuzzyEntry, SMW_NorSpr068_LineGuideFuzzy_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status01_BrownLineGuidePlatformEntry, SMW_NorSpr062_BrownLineGuidePlatform_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSprXXX_LineGuidedSprites_Status08(Address)
namespace SMW_NorSprXXX_LineGuidedSprites_Status08
%InsertMacroAtXPosition(<Address>)

DATA_01D717:
	db $F8,$00

LineGuideRopeEntry:
ChainsawEntry:
UpsideDownChainsawEntry:
	TXA
	ASL
	ASL
	EOR.b !RAM_SMW_Counter_LocalFrames
	STA.b !RAM_SMW_Misc_ScratchRAM02
	AND.b #$07
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b LineGuideGrinderEntry
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	LSR
	LSR
	LSR
	AND.b #$01
	TAY
	LDA.w DATA_01D717,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$F2
	STA.b !RAM_SMW_Misc_ScratchRAM01
	JSR.w SMW_SpawnNormalSpriteTurnAroundSmoke_Entry2
LineGuideGrinderEntry:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	ORA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_IsNotMovingFlag,x
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b LineFuzzyPlats
	LDA.b #!Define_SMW_Sound1DFA_Grinder	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
LineFuzzyPlats:
BrownLineGuidePlatformEntry:
CheckerboardLineGuidePlatformEntry:
LineGuideFuzzyEntry:
	JMP.w CODE_01D9A7

CODE_01D74D:
	JSR.w SMW_SubOffscreen_Bank01_Entry2
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide,x
	BNE.b CODE_01D75C
	LDA.b !RAM_SMW_Flag_SpritesLocked
	ORA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_IsNotMovingFlag,x
	BNE.b SMW_NorSprXXX_LineGuidedSprites_Status01_Return01D6EC
CODE_01D75C:
	LDA.b !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

Ptrs01D762:
	dw State00_AtEndOfTile
	dw State01_OnLineGuide
	dw State02_Falling

State01_OnLineGuide:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01D791
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_MovementDirection,x
	BNE.b CODE_01D792
	LDY.w !RAM_SMW_NorSprXXX_LineGuidedSprites_LeftLineGuideSpeedTableIndex,x
	JSR.w CODE_01D7B0
	INC.w !RAM_SMW_NorSprXXX_LineGuidedSprites_LeftLineGuideSpeedTableIndex,x
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_FasterMovementFlag,x
	; Change from F0 to D0 to switch the speeds of the line-guided sprites.
	; (Normally, the chainsaws, Grinder, and Fuzzy move fast, while the
	; platforms and rope move slow.) Use with $01D7A1.
	BEQ.b CODE_01D787
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b CODE_01D787
	INC.w !RAM_SMW_NorSprXXX_LineGuidedSprites_LeftLineGuideSpeedTableIndex,x
CODE_01D787:
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_LeftLineGuideSpeedTableIndex,x
	CMP.w !RAM_SMW_NorSprXXX_LineGuidedSprites_RightLineGuideSpeedTableIndex,x
	BCC.b Return01D791
	STZ.b !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentState,x
Return01D791:
	RTS

CODE_01D792:
	LDY.w !RAM_SMW_NorSprXXX_LineGuidedSprites_RightLineGuideSpeedTableIndex,x
	DEY
	JSR.w CODE_01D7B0
	DEC.w !RAM_SMW_NorSprXXX_LineGuidedSprites_RightLineGuideSpeedTableIndex,x
	BEQ.b CODE_01D7AD
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_FasterMovementFlag,x
	; Change from F0 to D0 to switch the speeds of the line-guided sprites.
	; (Normally, the chainsaws, Grinder, and Fuzzy move fast, while the
	; platforms and rope move slow.) Use with $01D77D.
	BEQ.b Return01D7AF
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b Return01D7AF
	DEC.w !RAM_SMW_NorSprXXX_LineGuidedSprites_RightLineGuideSpeedTableIndex,x
	BNE.b Return01D7AF
CODE_01D7AD:
	STZ.b !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentState,x
Return01D7AF:
	RTS

CODE_01D7B0:
	PHB				; Sprites calling this routine must be modified
	LDA.b #SMW_LineGuideSpeedTable_Main>>16	; to set $151C,x and $1528,x to a location in
	PHA				; LineTable instead of $07/F9DB+something
	PLB
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_LineGuideSpeedTableIndexLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_LineGuideSpeedTableIndexHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b (!RAM_SMW_Misc_ScratchRAM04),y
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b (!RAM_SMW_Misc_ScratchRAM04),y
	PLB
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	AND.b #$F0
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM07
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	AND.b #$F0
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	RTS

DATA_01D7E1:
	db $FC,$04,$FC,$04

DATA_01D7E5:
	db $FF,$00,$FF,$00

DATA_01D7E9:
	db $FC,$FC,$04,$04

DATA_01D7ED:
	db $FF,$FF,$00,$00

CODE_01D7F1:
	JMP.w CODE_01D89F

State00_AtEndOfTile:
	LDY.b #$03
CODE_01D7F6:
	STY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w DATA_01D7E1,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.w DATA_01D7E5,y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.w DATA_01D7E9,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.w DATA_01D7ED,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide,x
	BNE.b CODE_01D83A
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	AND.b #$F0
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	BNE.b CODE_01D83A
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	AND.b #$F0
	CMP.b !RAM_SMW_Misc_ScratchRAM05
	BEQ.b CODE_01D861
CODE_01D83A:
	JSR.w CODE_01D94D		;WIERD ROUTINE INVOLVING POSITIONS.  ALL VARIABLES SET ABOVE...
	BNE.b CODE_01D7F1
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;"# OF CUSTOM BLOCK???"
	CMP.b #$94
	BEQ.b CODE_01D851
	CMP.b #$95
	BNE.b CODE_01D856
	LDA.w !RAM_SMW_Flag_OnOffSwitch
	BEQ.b CODE_01D861
	BNE.b CODE_01D856
CODE_01D851:
	LDA.w !RAM_SMW_Flag_OnOffSwitch
	BNE.b CODE_01D861
CODE_01D856:
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	CMP.b #$76
	BCC.b CODE_01D861
	CMP.b #$9A
	BCC.b CODE_01D895
CODE_01D861:
	LDY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	DEY
	BPL.b CODE_01D7F6
	LDA.b !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentState,x
	CMP.b #$02			; ?? #00 - platforms stop at end rather than fall off
	BEQ.b Return01D894
	LDA.b #$02
	STA.b !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentState,x
	LDY.w !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentltTouchedLineGuideTile,x
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_MovementDirection,x
	BEQ.b CODE_01D87E
	TYA
	CLC
	ADC.b #$20
	TAY
CODE_01D87E:
	LDA.w DATA_01DD11,y
	BPL.b CODE_01D884
	ASL
CODE_01D884:
	PHY
	ASL
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;SPEED SETTINGS!
	PLY
	LDA.w DATA_01DD51,y
	ASL
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$10
	STA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide,x
Return01D894:
	RTS

CODE_01D895:
	PHA
	SEC
	SBC.b #$76
	TAY
	PLA
	CMP.b #$96
	BCC.b CODE_01D8A4
CODE_01D89F:
	LDY.w !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentltTouchedLineGuideTile,x
	BRA.b CODE_01D8C8

CODE_01D8A4:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_NorSpr_XPosHi,x
CODE_01D8C8:
	PHB
	LDA.b #SMW_LineGuideSpeedTable_Main>>16
	PHA
	PLB
	LDA.w SMW_LineGuideSpeedTable_PtrsLo,y
	STA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_LineGuideSpeedTableIndexLo,x
	LDA.w SMW_LineGuideSpeedTable_PtrsHi,y
	STA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_LineGuideSpeedTableIndexHi,x
	PLB
	LDA.w DATA_01DCD1,y
	STA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_RightLineGuideSpeedTableIndex,x
	STZ.w !RAM_SMW_NorSprXXX_LineGuidedSprites_LeftLineGuideSpeedTableIndex,x
	TYA
	STA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentltTouchedLineGuideTile,x
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide,x
	BNE.b CODE_01D933
	STZ.w !RAM_SMW_NorSprXXX_LineGuidedSprites_MovementDirection,x
	LDA.w DATA_01DCF1,y
	BEQ.b CODE_01D8FF
	TAY
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CPY.b #$01
	BNE.b CODE_01D8FD
	EOR.b #$0F
CODE_01D8FD:
	BRA.b CODE_01D901

CODE_01D8FF:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
CODE_01D901:
	AND.b #$0F
	CMP.b #$0A
	BCC.b CODE_01D910
	LDA.b !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentState,x
	CMP.b #$02
	BEQ.b CODE_01D910
	INC.w !RAM_SMW_NorSprXXX_LineGuidedSprites_MovementDirection,x
CODE_01D910:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	JSR.w State01_OnLineGuide
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	SEC
	SBC.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$08
	CMP.b #$10
	BCS.b CODE_01D938
	LDA.b !RAM_SMW_Misc_ScratchRAM0D
	SEC
	SBC.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$08
	CMP.b #$10
	BCS.b CODE_01D938
CODE_01D933:
	LDA.b #$01
	STA.b !RAM_SMW_NorSprXXX_LineGuidedSprites_CurrentState,x
	RTS

CODE_01D938:
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	JMP.w CODE_01D861

CODE_01D94D:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	LSR
	LSR
	LSR
	LSR
	PHA
	ORA.b !RAM_SMW_Misc_ScratchRAM06
	PHA
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.b #$01
	BEQ.b CODE_01D977
	PLA
	LDX.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L1,x
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L1,x
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM06
	BRA.b CODE_01D989

CODE_01D977:
	PLA
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	CLC
	ADC.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L1,x
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L1,x
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Misc_ScratchRAM06
CODE_01D989:
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	INC.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	PLY
	STY.b !RAM_SMW_Misc_ScratchRAM05
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	AND.b #$07
	TAY
	PLA
	AND.w DATA_018000,y
	RTS

CODE_01D9A7:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	;LINE GUIDE PLATFORM FUZZY
	CMP.b #!Define_SMW_SpriteID_NorSpr064_LineGuideRope	;DETERMINE SPRITE ITS DEALING WITH
	BEQ.b CODE_01D9D3
	CMP.b #!Define_SMW_SpriteID_NorSpr065_Chainsaw
	BCC.b CODE_01D9D0		;PLATFORM!
	CMP.b #!Define_SMW_SpriteID_NorSpr068_LineGuideFuzzy
	BNE.b CODE_01D9BA
	JSR.w CODE_01DBD4
	BRA.b CODE_01D9C1

CODE_01D9BA:
	CMP.b #!Define_SMW_SpriteID_NorSpr067_LineGuideGrinder
	BNE.b CODE_01D9C6
	JSR.w CODE_01DC0B
CODE_01D9C1:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	BRA.b CODE_01D9CD

CODE_01D9C6:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	JSL.l ChainsawGFXRt
CODE_01D9CD:
	JMP.w CODE_01D74D

CODE_01D9D0:
	JMP.w CODE_01DAA2

CODE_01D9D3:
	JSR.w CODE_01DC54
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	JSR.w CODE_01D74D
	PLA
	SEC
	SBC.b !RAM_SMW_NorSpr_YPosLo_x
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_NorSpr064_LineGuideRope_PlayerYPosOffset
	PLA
	SEC
	SBC.b !RAM_SMW_NorSpr_XPosLo_x
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_NorSpr064_LineGuideRope_PlayerXPosOffset
	LDA.b !RAM_SMW_Player_BlockedFlags
	AND.b #$03
	BNE.b Return01DA09
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_CODE_01A80F
	BCS.b CODE_01DA0A
CODE_01D9FE:
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_TouchingPlayerFlag,x
	BEQ.b Return01DA09
	STZ.w !RAM_SMW_NorSprXXX_LineGuidedSprites_TouchingPlayerFlag,x
	STZ.w !RAM_SMW_Flag_PlayerClimbOnAir
Return01DA09:
	RTS

CODE_01DA0A:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	BEQ.b CODE_01DA37
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag1	; \ Branch if carrying an enemy...
	ORA.w !RAM_SMW_Player_RidingYoshiFlag	; | ...or if on Yoshi
	BNE.b CODE_01D9FE
	LDA.b #$03
	STA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_TouchingPlayerFlag,x
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	BNE.b Return01DA8F
	LDA.w !RAM_SMW_Flag_PlayerClimbOnAir
	BNE.b CODE_01DA2F
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #!Joypad_DPadU>>8
	BEQ.b Return01DA8F
	STA.w !RAM_SMW_Flag_PlayerClimbOnAir
CODE_01DA2F:
	BIT.b !RAM_SMW_IO_ControllerPress1
	BPL.b CODE_01DA3F
	LDA.b #$B0
	STA.b !RAM_SMW_Player_YSpeed
CODE_01DA37:
	STZ.w !RAM_SMW_Flag_PlayerClimbOnAir
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
CODE_01DA3F:
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr064_LineGuideRope_PlayerYPosOffset
	BPL.b CODE_01DA47
	DEY
CODE_01DA47:
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_Player_YPosLo
	TYA
	ADC.b !RAM_SMW_Player_YPosHi
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_YPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	CMP.w #$0000
	BPL.b CODE_01DA68
	INC.b !RAM_SMW_Player_YPosLo
CODE_01DA68:
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_NorSpr064_LineGuideRope_PlayerXPosOffset
	JSR.w CODE_01DA90
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b #$08
	CMP.b !RAM_SMW_Player_XPosLo
	BEQ.b CODE_01DA84
	BPL.b CODE_01DA7F
	LDA.b #$FF
	BRA.b CODE_01DA81

CODE_01DA7F:
	LDA.b #$01
CODE_01DA81:
	JSR.w CODE_01DA90
CODE_01DA84:
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_IsNotMovingFlag,x
	BEQ.b Return01DA8F
	STZ.w !RAM_SMW_NorSprXXX_LineGuidedSprites_IsNotMovingFlag,x
	STZ.w !RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide,x
Return01DA8F:
	RTS

CODE_01DA90:
	LDY.b #$00
	CMP.b #$00
	BPL.b CODE_01DA97
	DEY
CODE_01DA97:
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	TYA
	ADC.b !RAM_SMW_Player_XPosHi
	STA.b !RAM_SMW_Player_XPosHi
	RTS

CODE_01DAA2:
	LDY.b #$18			;LINE GUIDED PLATFORM CODE
	LDA.w !RAM_SMW_NorSpr062_BrownLineGuidePlatform_PlatformType,x
	BEQ.b CODE_01DAAB
	LDY.b #$28			;CONDITIONAL DEPENDING ON PLATFORM TYPE?
CODE_01DAAB:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSR.w SMW_NormalSpritePlatformGFXRt_DrawFlatPlatform	;DRAW GFX  .  RELIES ON NEW POSITIONS MADE UP THERE.
	PLA				;RESTORE POSITIONS
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	JSR.w CODE_01D74D		;LINE GUIDE HANDLER???
	PLA
	SEC
	SBC.b !RAM_SMW_NorSpr_XPosLo_x
	LDY.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	PHY
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	LDY.b #$18
	LDA.w !RAM_SMW_NorSpr062_BrownLineGuidePlatform_PlatformType,x
	BEQ.b CODE_01DAFD
	LDY.b #$28
CODE_01DAFD:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSR.w SMW_SolidSpriteBlock_Sub	;CUSTOM INTERACTION HANDLER
	BCC.b CODE_01DB31
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_IsNotMovingFlag,x
	BEQ.b CODE_01DB31
	STZ.w !RAM_SMW_NorSprXXX_LineGuidedSprites_IsNotMovingFlag,x
	STZ.w !RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide,x
CODE_01DB31:
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	PLA
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	RTS

State02_Falling:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01DB59
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	LDA.w !RAM_SMW_NorSprXXX_LineGuidedSprites_WaitBeforeLatchingOntoLineGuide,x
	BNE.b Return01DB59
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$20
	BMI.b Return01DB59
	JSR.w State00_AtEndOfTile
Return01DB59:
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status08_LineGuideRopeEntry, SMW_NorSpr064_LineGuideRope_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status08_ChainsawEntry, SMW_NorSpr065_Chainsaw_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status08_UpsideDownChainsawEntry, SMW_NorSpr066_UpsideDownChainsaw_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status08_LineGuideGrinderEntry, SMW_NorSpr067_LineGuideGrinder_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status08_BrownLineGuidePlatformEntry, SMW_NorSpr062_BrownLineGuidePlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status08_CheckerboardLineGuidePlatformEntry, SMW_NorSpr063_CheckerboardLineGuidePlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_LineGuidedSprites_Status08_LineGuideFuzzyEntry, SMW_NorSpr068_LineGuideFuzzy_Status08_Main)
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_LineGuidedSprites_Status08(Address)
namespace SMW_NorSprXXX_LineGuidedSprites_Status08
%InsertMacroAtXPosition(<Address>)

DATA_018000:
	db $80,$40,$20,$10,$08,$04,$02,$01	; this belonged to previous code, I belive
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSprXXX_LineGuidedSprites_Status08(Address)
namespace SMW_NorSprXXX_LineGuidedSprites_Status08
%InsertMacroAtXPosition(<Address>)

CODE_01DBD4:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$40].XDisp,y
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$01
	TAX
	LDA.b #$C8
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w DATA_01DC09,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b #$00
CODE_01DC03:
	PLX
CODE_01DC04:
	LDY.b #$02
	JMP.w SMW_FinishOAMWrite_Sub

DATA_01DC09:
	db $05,$45

CODE_01DC0B:
	JSR.w SMW_GetDrawInfo_Bank01
	PHX
	LDX.b #$03
CODE_01DC11:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_01DC3B,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w DATA_01DC3F,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$02
	ORA.b #$6C
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w DATA_01DC43,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_01DC11
	BRA.b SMW_NorSpr0B4_NonLineGuideGrinder_Status08_CODE_01DBD0

DATA_01DC3B:
	db $F0,$00,$F0,$00

DATA_01DC3F:
	db $F0,$F0,$00,$00

DATA_01DC43:
	db $33,$73,$B3,$F3

; Line-guided Rope's Motor Tilemap
RopeMotorTiles:
	db $C0,$C2,$E0,$C2

LineGuideRopeTiles:
	db $C0,$CE,$CE,$CE,$CE,$CE,$CE,$CE
	db $CE

; Line-guided rope graphics routine. Note that the visual length of the rope
; depends on whether the rope is in slot 6 as well as of the current sprite
; memory settings (sprite memory zero will always draw short ropes).
CODE_01DC54:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM01
	TXA
	ASL
	ASL
	EOR.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	AND.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$05
	CPX.b #$06
	BCC.b CODE_01DC7E
	LDY.w !RAM_SMW_Sprites_SpriteMemorySetting
	BEQ.b CODE_01DC7E
	LDA.b #$09
CODE_01DC7E:
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDX.b #$00
CODE_01DC85:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM01
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l LineGuideRopeTiles,x
else
	LDA.w LineGuideRopeTiles,x
endif
	CPX.b #$00
	BNE.b CODE_01DCA2
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM02
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l RopeMotorTiles,x
else
	LDA.w RopeMotorTiles,x
endif
	PLX
CODE_01DCA2:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$37
	CPX.b #$01
	BCC.b CODE_01DCAD
	LDA.b #$31
CODE_01DCAD:
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	INX
	CPX.b !RAM_SMW_Misc_ScratchRAM03
	BNE.b CODE_01DC85
	LDA.b #$DE
	STA.w SMW_OAMBuffer[$3F].Tile,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b #$04
	CPX.b #$06
	BCC.b CODE_01DCCE
	LDY.w !RAM_SMW_Sprites_SpriteMemorySetting
	BEQ.b CODE_01DCCE
	LDA.b #$08
CODE_01DCCE:
	JMP.w CODE_01DC04

DATA_01DCD1:
	db $15,$15,$15,$15,$0C,$10,$10,$10
	db $10,$0C,$0C,$10,$10,$10,$10,$0C
	db $15,$15,$10,$10,$10,$10,$10,$10
	db $10,$10,$10,$10,$10,$10,$15,$15

DATA_01DCF1:
	db $00,$00,$00,$00,$00,$00,$01,$02
	db $00,$00,$00,$00,$02,$01,$00,$00
	db $00,$00,$01,$02,$01,$02,$00,$00
	db $00,$00,$02,$02,$00,$00,$00,$00

DATA_01DD11:
	db $00,$10,$00,$F0,$F4,$FC,$F0,$10
	db $04,$0C,$0C,$00,$10,$F0,$FC,$F4
	db $F0,$10,$F0,$10,$F0,$10,$F8,$F8
	db $08,$08,$10,$10,$00,$00,$F0,$10
	db $10,$00,$F0,$F0,$0C,$04,$10,$F0
	db $00,$F4,$F4,$FC,$F0,$10,$00,$0C
	db $10,$F0,$10,$00,$10,$F0,$08,$08
	db $F8,$F8,$F0,$F0,$00,$00,$10,$F0

DATA_01DD51:
	db $10,$00,$10,$00,$0C,$10,$04,$00
	db $10,$0C,$0C,$10,$04,$00,$10,$0C
	db $10,$10,$08,$08,$08,$08,$10,$10
	db $10,$10,$00,$00,$10,$10,$10,$10
	db $00,$F0,$00,$F0,$F4,$F0,$00,$FC
	db $F0,$F4,$F4,$F0,$00,$FC,$F0,$F4
	db $F0,$F0,$F8,$F8,$F8,$F8,$F0,$F0
	db $F0,$F0,$00,$00,$F0,$F0,$F0
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr06A_CoinGameCloud_Status08(Address)
namespace SMW_NorSpr06A_CoinGameCloud_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSprXXX_WallSpringboard_Status08(Address)
namespace SMW_NorSprXXX_WallSpringboard_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	PHB
	LDA.b #Sub>>16			; see above.
	PHA
	PLB
	JSL.l Sub
	PLB
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallSpringboard_Status08_Main, SMW_NorSpr06B_LeftWallSpringboard_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_WallSpringboard_Status08_Main, SMW_NorSpr06C_RightWallSpringboard_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr06C_RightWallSpringboard_Status01(Address)
namespace SMW_NorSpr06C_RightWallSpringboard_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\this is a springboard, peabouncer i don't even
	SEC				;|
	SBC.b #$08			;| set the Xpos down 8 than where it was placed
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;/ (probably to offset for when it bends)
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;\
	SBC.b #$00			;| change the Yhipos if that's the case
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SolidSpriteBlock(Address)
namespace SMW_SolidSpriteBlock
%InsertMacroAtXPosition(<Address>)

; Invisible solid block subroutine. JSL to it in a sprite to make it solid
; (or act as a platform depending on bit 0 of $190F). Inputs: - $1528,x:
; number of pixels Mario has moved horizontally in the current frame, used
; to move Mario with the sprite when he's standing on top of it. Note: not
; cleared post-routine. Outputs: - Carry: set if Mario is on top of the
; sprite, clear if not. - $C2,x: if the sprite is set to be solid from all
; sides, it's set to #$01 if it was #$00 before. It can be used as a flag
; for the sprite being hit from below by Mario. - $1558,x: if the sprite is
; set to be solid from all sides, it's set to #$10 if $C2,x was #$00 before.
; It can be used as a timer for a bouncing animation when the sprite is hit
; from below. - $1564,x: if the sprite is set to be solid from all sides,
; it's set to #$0F when hit from below (only for sprites >= $83). This is
; used to disable interaction with sprites for a short amount of time. -
; $1471: set to #$01 if Mario is standing on top of the sprite. Misc. data:
; - $01B477: [$10] Y speed given to Mario when sitting on top of a solid
; block/platform. - $01B4C0: Change to [$A0 $00] to make Super/Fire/Cape
; Mario have a 16x16 interaction field (like Small Mario) or change to [$A0
; $01] to have a 16x32 interaction field (like Big Mario) (in conjunction
; with addresses $00EB79 and $03B67C). - $01B4D9: [$10] Y speed given to
; Mario when hitting a solid sprite from below. - $01B4F3: [$01] SFX that
; comes up when Mario hits a solid sprite from below. - $01B4F5: [$1DF9]
; Bank used for the SFX when Mario hits a solid sprite from below.
Main:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_ProcessInteract
	BCC.b NoContact1
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	CLC
	ADC.b #$18
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b HandleMarioBelow
	LDA.b !RAM_SMW_Player_YSpeed	;\If mario is going upward, don't
	BMI.b NoContact1		;/snap his Y pos onto platform sprite
	LDA.b !RAM_SMW_Player_BlockedFlags
	AND.b #$08
	BNE.b NoContact1
	LDA.b #$10
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b #$01
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	LDA.b #$1F
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b NotRidingYoshi1
	LDA.b #$2F
NotRidingYoshi1:
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b !RAM_SMW_Player_BlockedFlags
	AND.b #$03
	BNE.b Contact
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	BPL.b MoveMarioRight
	DEY
MoveMarioRight:
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	TYA
	ADC.b !RAM_SMW_Player_XPosHi
	STA.b !RAM_SMW_Player_XPosHi
Contact:
	SEC
	RTS

NoContact1:
	CLC
	RTS

HandleMarioBelow:
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,x		;\ Note: !Define_SMW_NorSpr_190FProp_CanPassThroughPlaformFromBelow
	LSR						;|
	BCS.b NoContact1				;/
	LDA.b #$00
	LDY.b !RAM_SMW_Player_DuckingFlag
	BNE.b IsDucking
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b IsNotSmall
IsDucking:
	LDA.b #$08
IsNotSmall:
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b NotRidingYoshi2
	ADC.b #$08
NotRidingYoshi2:
	CLC
	ADC.b !RAM_SMW_Player_OnScreenPosYLo
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b HandleMarioSide
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b NoContact2
	LDA.b #$10
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr083_LeftFlyingBlock
	BCC.b IsNotSprite83Plus
Entry2:
	LDA.b #$0F
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x
	BNE.b CODE_01B4F2
	INC.b !RAM_SMW_NorSpr_Table7E00C2,x
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
CODE_01B4F2:
IsNotSprite83Plus:
	LDA.b #!Define_SMW_Sound1DF9_HitHead
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
NoContact2:
	CLC
	RTS

DATA_01B4F9:
	db $0E,$F1
	db $10,$E0
	db $1F,$F1

DATA_01B4FF:
	db $00,$FF
	db $00,$FF
	db $00,$FF

HandleMarioSide:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0A9_Reznor
	BEQ.b IsReznor
	CMP.b #!Define_SMW_SpriteID_NorSpr09C_HammerBroPlatform
	BEQ.b IsHammerBroPlatform
	CMP.b #!Define_SMW_SpriteID_NorSpr0BB_MovingCastleStone
	BEQ.b IsMovingCastleStone
	CMP.b #!Define_SMW_SpriteID_NorSpr060_FlatPalaceSwitch
	BEQ.b IsFlatPalaceSwitch
	CMP.b #!Define_SMW_SpriteID_NorSpr049_ShiftingPipe
	BNE.b IsNotShiftingPipe
IsHammerBroPlatform:
IsMovingCastleStone:
IsFlatPalaceSwitch:
	INY
	INY
IsReznor:
	INY
	INY
IsNotShiftingPipe:
	LDA.w DATA_01B4F9,y
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Player_XPosLo
	LDA.w DATA_01B4FF,y
	ADC.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Player_XPosHi
	STZ.b !RAM_SMW_Player_XSpeed
	CLC
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr06F_DinoTorch_Status01(Address)
namespace SMW_NorSpr06F_DinoTorch_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr06F_DinoTorch_FireLength,x
CODE_01855D:
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr06F_DinoTorch_BreathFireTimer,x
	BRA.b SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr06F_DinoTorch_Status01_CODE_01855D, SMW_NorSpr00D_BobOmb_Status01_Main)

	%SetDuplicateOrNullPointer(SMW_NorSpr06F_DinoTorch_Status01_Main, SMW_NorSpr06E_DinoRhino_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr06F_DinoTorch_Status08(Address)
namespace SMW_NorSpr06F_DinoTorch_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank03			; solid block/dino routine (What the...)
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr06F_DinoTorch_Status08_Main, SMW_NorSpr06D_InvisibleBlock_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr06F_DinoTorch_Status08_Main, SMW_NorSpr06E_DinoRhino_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr070_Pokey_Status01(Address)
namespace SMW_NorSpr070_Pokey_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$1F			; \ If on Yoshi, $C2,x = #$1F
	LDY.w !RAM_SMW_Player_RidingYoshiFlag	; | (5 segments, 1 bit each)
	BNE.b IsRidingYoshi
	LDA.b #$07			; | If not on Yoshi, $C2,x = #$07
IsRidingYoshi:
	STA.b !RAM_SMW_NorSpr070_Pokey_Segments,x	; /   (3 segments, 1 bit each)
	BRA.b SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr070_Pokey_Status08(Address)
namespace SMW_NorSpr070_Pokey_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr071_RedCapeSuperKoopa_Status01(Address)
namespace SMW_NorSpr071_RedCapeSuperKoopa_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$28			;\
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;| face mario, and set the Yspeed to going down
	BRA.b SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main	;/
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr071_RedCapeSuperKoopa_Status01_Main, SMW_NorSpr072_YellowCapeSuperKoopa_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSprXXX_SuperKoopas_Status08(Address)
namespace SMW_NorSprXXX_SuperKoopas_Status08
%InsertMacroAtXPosition(<Address>)

RedCapeSuperKoopaEntry:
	JSL.l Bank02
	RTS

YellowCapeSuperKoopaEntry:
	JSL.l Bank02
	RTS

GroundSuperKoopaEntry:
	JSL.l Bank02
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_SuperKoopas_Status08_RedCapeSuperKoopaEntry, SMW_NorSpr071_RedCapeSuperKoopa_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_SuperKoopas_Status08_YellowCapeSuperKoopaEntry, SMW_NorSpr072_YellowCapeSuperKoopa_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_SuperKoopas_Status08_GroundSuperKoopaEntry, SMW_NorSpr073_GroundSuperKoopa_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr073_GroundSuperKoopa_Status01(Address)
namespace SMW_NorSpr073_GroundSuperKoopa_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\
	AND.b #$10			;|xpos does something with a sprite table
	BEQ.b CODE_018547		;/
	LDA.b #!Define_SMW_NorSpr_1656Prop_SafeToJumpOn	; \ Can be jumped on
	STA.w !RAM_SMW_NorSpr_PropertyBits1656,x
	LDA.b #!Define_SMW_NorSpr_1662Prop_FallWhenKilled|!Define_SMW_NorSpr_1662Prop_SpriteClipping00	;\
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x	;|various tweaker bytes.
	LDA.b #!Define_SMW_NorSpr_1686Prop_DontChangeDirectionWhenTouched	;|
	STA.w !RAM_SMW_NorSpr_PropertyBits1686,x	;/
	RTS

CODE_018547:
	INC.w !RAM_SMW_NorSpr073_GroundSuperKoopa_HasFeatherFlag,x	; unkown sprite table
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr074_Mushroom_Status01(Address)
namespace SMW_NorSpr074_Mushroom_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	INC.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x	; context in sprite
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr074_Mushroom_Status01_Main, SMW_NorSpr075_FireFlower_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr074_Mushroom_Status01_Main, SMW_NorSpr076_Star_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr074_Mushroom_Status01_Main, SMW_NorSpr077_Feather_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr074_Mushroom_Status01_Main, SMW_NorSpr078_1upMushroom_Status01_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr077_Feather_Status08(Address)
namespace SMW_NorSpr077_Feather_Status08
%InsertMacroAtXPosition(<Address>)

XAccelerarion:
	db $02,$FE

MaxXSpeed:
	db $20,$E0

YSpeed:
	db $0A,$F6,$08

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01C744
	LDA.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x	;\
	BEQ.b CODE_01C701		;/ if delected, do not worry about checking if floating
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	;\ if not floating, do not delete sprite
	BNE.b CODE_01C6FF		;/
	STZ.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x	; delete sprite
CODE_01C6FF:
	BRA.b CODE_01C741

CODE_01C701:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;\ if...uh...
	CMP.b #!Define_SMW_NorSprStatus0C_GoalPowerUp	;/
	BEQ.b CODE_01C744
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	BEQ.b CODE_01C715
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	JMP.w CODE_01C741

CODE_01C715:
	LDA.w !RAM_SMW_NorSpr077_Feather_HorizontalMovementDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CLC
	ADC.w XAccelerarion,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxXSpeed,y
	BNE.b CODE_01C72B
	INC.w !RAM_SMW_NorSpr077_Feather_HorizontalMovementDirection,x
CODE_01C72B:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BPL.b CODE_01C730
	INY
CODE_01C730:
	LDA.w YSpeed,y
	CLC
	ADC.b #$06
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
CODE_01C741:
	JSR.w SMW_SetFacingDirectionBasedOnSpeed_Bank01
CODE_01C744:
	JSR.w SMW_NorSprXXX_PowerUps_Status08_CODE_01C4AC
	JMP.w SMW_PowerUpAndItemGFXRt_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr079_VineHead_Status08(Address)
namespace SMW_NorSpr079_VineHead_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Sprites_TilePriority
	PHA
	LDA.w !RAM_SMW_NorSpr079_VineHead_AppearBehindLayer1Timer,x
	CMP.b #$20
	BCC.b CODE_01C191
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_01C191:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	LSR
	LDA.b #$AC
	BCC.b CODE_01C1A3
	LDA.b #$AE
CODE_01C1A3:
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01C1ED
	LDA.b #$F0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.w !RAM_SMW_NorSpr079_VineHead_AppearBehindLayer1Timer,x
	CMP.b #$20
	BCS.b CODE_01C1CB
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	BNE.b CODE_01C1C8
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	BPL.b CODE_01C1CB
CODE_01C1C8:
	JMP.w SMW_SubOffscreen_Bank01_EraseSprite

CODE_01C1CB:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	AND.b #$0F
	CMP.b #$00
	BNE.b Return01C1ED
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $9A = Sprite X position
	STA.b !RAM_SMW_Blocks_XPosLo	; | for block creation
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $98 = Sprite Y position
	STA.b !RAM_SMW_Blocks_YPosLo	; | for block creation
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.b #$03			; \ Block to generate = Vine
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main	; Generate the tile
Return01C1ED:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr07B_GoalTape_Status01(Address)
namespace SMW_NorSpr07B_GoalTape_Status01
%InsertMacroAtXPosition(<Address>)

ADDR_01C062:						;\ Note: Unused code
	JSR.w Main					;|
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;|
	SEC						;|
	SBC.b #$4C					;|
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x			;|
	SBC.b #$00					;|
	STA.w !RAM_SMW_NorSpr_YPosHi,x			;|
	RTS						;/

Main:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_NorSpr07B_GoalTape_HitboxXPosLo,x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr07B_GoalTape_HitboxXPosHi,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr07B_GoalTape_HitboxYPosLo,x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	; \ Save extra bits into $187B,x
#LM300Hijack_SecretExit2And3GoalTape1:
	STA.w !RAM_SMW_NorSpr07B_GoalTape_GoalType,x		;\ LM: NOPed out code (3.00+)
	AND.b #$01						;| LM changes how !RAM_SMW_NorSpr07B_GoalTape_GoalType is stored to to allow goal tapes to trigger secret exit 2 and 3.
	STA.w !RAM_SMW_NorSpr_YPosHi,x				;/
	STA.w !RAM_SMW_NorSpr07B_GoalTape_HitboxYPosHi,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr07B_GoalTape_Status08(Address)
namespace SMW_NorSpr07B_GoalTape_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01C0A4
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_GoalCrossedFlag,x
	BEQ.b CODE_01C0A7
Return01C0A4:
	RTS

YSpeed:
	db $10,$F0

CODE_01C0A7:
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_ChangeDirectionTimer,x
	BNE.b CODE_01C0B4
	LDA.b #$7C
	STA.w !RAM_SMW_NorSpr07B_GoalTape_ChangeDirectionTimer,x
	INC.w !RAM_SMW_NorSpr07B_GoalTape_VerticalDirection,x
CODE_01C0B4:
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_VerticalDirection,x
	AND.b #$01
	TAY
	LDA.w YSpeed,y
	; [95] Change to A5 to stop the goal point bar from moving.
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.b !RAM_SMW_NorSpr07B_GoalTape_HitboxXPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_HitboxXPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	CMP.w #$0010
	SEP.b #$20			; A->8
	BCS.b Return01C12C
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_HitboxYPosLo,x
	CMP.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_HitboxYPosHi,x
#LM300Hijack_SecretExit2And3GoalTape2:
	AND.b #$01						; LM: Changed to AND.b #$FF so goal tapes can trigger more secret exits (3.00+)
	SBC.b !RAM_SMW_Player_YPosHi
	BCC.b Return01C12C
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_GoalType,x	; \ $141C = #01 if Goal Tape triggers secret exit
	LSR
	LSR
	STA.w !RAM_SMW_Flag_SecretGoalSprite
	LDA.b #!Define_SMW_LevelMusic_PassedLevel
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	LDA.b #$FF
	STA.w !RAM_SMW_Misc_MusicRegisterBackup
#Debug_TriggerCutsceneOnGoal:
	LDA.b #$FF
	STA.w !RAM_SMW_Timer_EndLevel
	STZ.w !RAM_SMW_Timer_StarPower	; Zero out star timer
	INC.w !RAM_SMW_NorSpr07B_GoalTape_GoalCrossedFlag,x
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	BCC.b CODE_01C125
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	INC.w !RAM_SMW_NorSpr07B_GoalTape_BrokeTapeFlag,x
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_HitboxYPosLo,x
	SEC
	SBC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr07B_GoalTape_RelativeYPosTapeWasHitAt,x
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr07B_GoalTape_DisplayStarsTimer,x
	JSL.l GiveBonusStars
	BRA.b CODE_01C128

CODE_01C125:
	STZ.w !RAM_SMW_NorSpr_PropertyBits1686,x
CODE_01C128:
	JSL.l TriggerGoalTape
Return01C12C:
	RTS

GFXRt:
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_BrokeTapeFlag,x
	BNE.b CODE_01C175
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$41].XDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$42].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	STA.w SMW_OAMBuffer[$42].YDisp,y
	LDA.b #$D4
	STA.w SMW_OAMBuffer[$40].Tile,y
	INC
	STA.w SMW_OAMBuffer[$41].Tile,y
	STA.w SMW_OAMBuffer[$42].Tile,y
	LDA.b #$32
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	STA.w SMW_OAMBuffer[$42].Prop,y
	LDY.b #$00
	LDA.b #$02
	JMP.w SMW_FinishOAMWrite_Sub

CODE_01C175:
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_DisplayStarsTimer,x
	BEQ.b CODE_01C17F
	; Change 22 CA F1 07 to EA EA EA EA to disable the digits made up of star
	; tiles at the goal tape (which resemble the amount of bonus stars
	; gathered)
	JSL.l BonusStarNumbersGFXRt
	RTS

CODE_01C17F:
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_FlyingItems_Status08(Address)
namespace SMW_NorSprXXX_FlyingItems_Status08
%InsertMacroAtXPosition(<Address>)

YAcceleration:
	db $FF,$01

MaxYSpeed:
	db $F0,$10

Main:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus0C_GoalPowerUp
	BEQ.b CODE_01C255
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01C255
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon
	BNE.b CODE_01C21D
	LDA.w !RAM_SMW_NorSprXXX_FlyingItems_AppearBehindLayer1Timer,x
	BEQ.b CODE_01C21D
	LDA.b !RAM_SMW_Sprites_TilePriority
	PHA
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
	JSR.w SMW_PowerUpAndItemGFXRt_Main
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.b #$F8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	RTS

CODE_01C21D:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_01C239
	LDA.w !RAM_SMW_NorSprXXX_FlyingItems_VerticalDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w YAcceleration,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w MaxYSpeed,y
	BNE.b CODE_01C239
	INC.w !RAM_SMW_NorSprXXX_FlyingItems_VerticalDirection,x
CODE_01C239:
	LDA.b #$0C
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	PHA
	CLC
	SEC
	SBC.b #$02
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	PLA
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
CODE_01C255:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon
	BNE.b CODE_01C262
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	BRA.b CODE_01C27F

CODE_01C262:
	LDA.b !RAM_SMW_NorSprXXX_FlyingItems_ItemToDraw,x
	CMP.b #$02
	BNE.b CODE_01C27C
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_01C271
	JSR.w SMW_SpawnSparkles_NormalSpriteEntry
CODE_01C271:
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	AND.b #$0E
	EOR.w !RAM_SMW_NorSpr_YXPPCCCT,x
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
CODE_01C27C:
	JSR.w SMW_DrawWingTiles_Main
CODE_01C27F:
	LDA.b !RAM_SMW_NorSprXXX_FlyingItems_ItemToDraw,x
	BEQ.b CODE_01C287
	JSR.w SMW_GetDrawInfo_Bank01
	RTS

CODE_01C287:
	JSR.w SMW_PowerUpAndItemGFXRt_Main
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	BCC.b Return01C2D2
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr07E_FlyingRedCoin
	BNE.b CODE_01C2A6
	JSR.w SMW_NorSprXXX_PowerUps_Status08_CODE_01C4F0
	LDA.b #$05
	JSL.l SMW_GiveCoins_MultipleCoins
	LDA.b #$03
	JSL.l SMW_GivePoints_Main
	BRA.b ADDR_01C30F

CODE_01C2A6:
	CMP.b #!Define_SMW_SpriteID_NorSpr07F_Flying1up
	BNE.b CODE_01C2AF
	JSR.w SMW_NorSprXXX_PowerUps_Status08_GiveMario1Up
	BRA.b ADDR_01C30F

CODE_01C2AF:
	CMP.b #!Define_SMW_SpriteID_NorSpr080_Key
	BNE.b CODE_01C2CE
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return01C2D2
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$D0
	STA.b !RAM_SMW_Player_YSpeed
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	STZ.w !RAM_SMW_NorSprXXX_FlyingItems_AppearBehindLayer1Timer,x
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ Use default interation with Mario
	AND.b #!Define_SMW_NorSpr_167AProp_UseNonDefaultPlayerInteraction^$FF
	STA.w !RAM_SMW_NorSpr_PropertyBits167A,x
	RTS

CODE_01C2CE:
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon
	BEQ.b CODE_01C2D3
Return01C2D2:
	RTS

CODE_01C2D3:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot
CODE_01C2D5:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus0B_Carried
	BNE.b CODE_01C2E8
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon
	BEQ.b CODE_01C2E8
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
CODE_01C2E8:
	DEY
	BPL.b CODE_01C2D5
	LDA.b #!Define_SMW_NorSprStatus00_EmptySlot
	LDY.w !RAM_SMW_Timer_InflateFromPBalloon
	BNE.b CODE_01C2F4
	LDA.b #!Define_SMW_NorSprStatus0B_Carried	; \ Sprite status = Being carried
CODE_01C2F4:
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b !RAM_SMW_Player_YSpeed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_Player_XSpeed
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$09
	STA.w !RAM_SMW_Timer_InflateFromPBalloon
	LDA.b #$FF
	STA.w !RAM_SMW_Timer_PlayerHasPBalloon
	LDA.b #!Define_SMW_Sound1DF9_PBalloon	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	RTS

ADDR_01C30F:
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_FlyingItems_Status08_Main, SMW_NorSpr07D_PBalloon_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_FlyingItems_Status08_Main, SMW_NorSpr07E_FlyingRedCoin_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_FlyingItems_Status08_Main, SMW_NorSpr07F_Flying1up_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_FlyingItems_Status08_Main, SMW_NorSpr080_Key_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr081_ChangingItem_Status01(Address)
namespace SMW_NorSpr081_ChangingItem_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	INC.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x	; set a misc. sprite data table up one (for random?)
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr081_ChangingItem_Status01_Return, SMW_NorSpr041_LongJumpDolphin_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr081_ChangingItem_Status01_Return, SMW_NorSpr042_ShortJumpDolphin_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr081_ChangingItem_Status01_Return, SMW_NorSpr043_VerticalDolphin_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr081_ChangingItem_Status01_Return, SMW_NorSpr044_TorpedoTed_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr081_ChangingItem_Status01_Return, SMW_NorSpr06B_LeftWallSpringboard_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr081_ChangingItem_Status01_Return, SMW_NorSpr089_Layer3Smasher_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSprXXX_PowerUps_Status08(Address)
namespace SMW_NorSprXXX_PowerUps_Status08
%InsertMacroAtXPosition(<Address>)

; Sprites used by the changing item (Mushroom, Flower, Feather, Star)
ChangingItemSprite:
	db !Define_SMW_SpriteID_NorSpr074_Mushroom 
	db !Define_SMW_SpriteID_NorSpr075_FireFlower
	db !Define_SMW_SpriteID_NorSpr077_Feather
	db !Define_SMW_SpriteID_NorSpr076_Star

ChangingItemEntry:
	LDA.b #$01
	STA.w !RAM_SMW_NorSprXXX_PowerUps_IsChangingItem,x
	LDA.w !RAM_SMW_NorSpr_OnYoshisTongue,x
	BNE.b CODE_01C324
if ver_is_pal(!Define_Global_ROMToAssemble)
	INC.w !RAM_SMW_NorSpr081_ChangingItem_SpriteChangeCounter,x
endif
	INC.w !RAM_SMW_NorSpr081_ChangingItem_SpriteChangeCounter,x
CODE_01C324:
	LDA.w !RAM_SMW_NorSpr081_ChangingItem_SpriteChangeCounter,x	; \ Determine which power-up to act like
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w ChangingItemSprite,y
	STA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Change into the appropriate power up
	JSL.l SMW_InitializeNormalSpriteRAMTables_YXPPCCCTAndPropertyTables
	JSR.w CODE_01C353		; Run the power up code
	LDA.b #!Define_SMW_SpriteID_NorSpr081_ChangingItem	; \ Change it back to the turning item
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_YXPPCCCTAndPropertyTables
	RTS

; Eaten berry palettes (unused, red, pink, green)
EatenBerryGfxProp:
	db $02,$02,$04,$06

FireFlowerEntry:
	LDA.b !RAM_SMW_Counter_LocalFrames	; \ Flip flower every 8 frames
	AND.b #$08
	LSR
	LSR
	LSR				; | ($157C,x = 0 or 1)
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_01C353:
MovingCoinEntry:
MushroomEntry:
StarEntry:
OneUpMushroomEntry:
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_IsBerryFlag,x
	BEQ.b CODE_01C371
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$80			; \ Set berry tile to OAM
	STA.w SMW_OAMBuffer[$40].Tile,y
	PHX				; \ Set gfx properties of berry
	LDX.w !RAM_SMW_Yoshi_BerryBeingEaten	; | X = type of berry being eaten
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l EatenBerryGfxProp,x
else
	LDA.w EatenBerryGfxProp,x
endif
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX				; X = sprite index
	RTS

CODE_01C371:
	LDA.b !RAM_SMW_Sprites_TilePriority
	PHA
	JSR.w CODE_01C4AC
	LDA.w !RAM_SMW_NorSpr_Table7E1534,x
	BEQ.b CODE_01C38F
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01C387
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
CODE_01C387:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$0C
	BNE.b CODE_01C3AB
	PLA
	RTS

CODE_01C38F:
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_RisingOutOfBlockTimer,x
	BEQ.b CODE_01C3AE
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_RisingOutOfSpriteBlockFlag,x
	BNE.b CODE_01C3A0
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_01C3A0:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01C3AB
	LDA.b #$FC
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
CODE_01C3AB:
	JMP.w CODE_01C48D

CODE_01C3AE:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01C3AB
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus0C_GoalPowerUp
	BEQ.b CODE_01C3AB
	LDA.b !RAM_SMW_NorSpr_SpriteID_x					;\ Optimization: Unnecessary.
	CMP.b #!Define_SMW_SpriteID_NorSpr076_Star				;|
	BNE.b CODE_01C3BF						;|
CODE_01C3BF:								;/
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	JSR.w SMW_SetXSpeedBasedOnNormalSpriteFacingDirection_Main
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr075_FireFlower	; flower
	BNE.b CODE_01C3D2
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_IsChangingItem,x
	BNE.b CODE_01C3D2
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
CODE_01C3D2:
	CMP.b #!Define_SMW_SpriteID_NorSpr076_Star	; star
	BEQ.b CODE_01C3E1
	CMP.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin	; sprite coin
	BEQ.b CODE_01C3E1
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_IsChangingItem,x
	BNE.b CODE_01C3E1
	ASL.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01C3E1:
	LDA.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x
	BEQ.b CODE_01C3F3
	BMI.b CODE_01C3F1
	JSR.w SMW_HandleNormalSpriteLevelCollision_Sub
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	BNE.b CODE_01C3F1
	STZ.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x
CODE_01C3F1:
	BRA.b CODE_01C437

CODE_01C3F3:
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	CMP.b #$C1
	BEQ.b CODE_01C42C
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_01C42C
	STZ.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	BNE.b ADDR_01C41E
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$A0
	BCC.b ADDR_01C41E
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	ORA.b #$04
	STA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	JSR.w SMW_SetXSpeedBasedOnNormalSpriteFacingDirection_Main
ADDR_01C41E:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	BRA.b CODE_01C42F

; Set to EA EA EA to disable moving coin and star movement
CODE_01C42C:
	JSR.w SMW_HandleNormalSpriteGravity_Sub
CODE_01C42F:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BEQ.b CODE_01C437
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01C437:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_CheckNormalSpriteLevelCollision_Ceiling
	BEQ.b CODE_01C443
	LDA.b #$00
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01C443:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BNE.b CODE_01C44A
	BRA.b CODE_01C47E

CODE_01C44A:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin	; sprite coin
	BNE.b CODE_01C46C
	JSR.w SMW_SetXSpeedBasedOnNormalSpriteFacingDirection_Main
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	INC
	PHA
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	PLA
	LSR
	JSR.w SMW_UnnecessaryInvertARt_CopyOfBank01
	CMP.b #$FC
	BCS.b CODE_01C46A
	LDY.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	BMI.b CODE_01C46A
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01C46A:
	BRA.b CODE_01C47E

CODE_01C46C:
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank01
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_IsChangingItem,x
	BNE.b CODE_01C47A
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr076_Star	; star
	BNE.b CODE_01C47E
CODE_01C47A:
	LDA.b #$C8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01C47E:
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_NoBlockSideInteractionTimer,x
	ORA.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x
	BNE.b CODE_01C48D
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b CODE_01C48D
	JSR.w SMW_ChangeNormalSpriteDirection_Main
CODE_01C48D:
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_RisingOutOfBlockTimer,x
	CMP.b #$36
	BCS.b CODE_01C4A8
	LDA.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x
	BEQ.b CODE_01C49C
	CMP.b #$FF
	BNE.b CODE_01C4A1
CODE_01C49C:
	LDA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x
	BEQ.b CODE_01C4A5
CODE_01C4A1:
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_01C4A5:
	JSR.w SMW_PowerUpAndItemGFXRt_Main
CODE_01C4A8:
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
Return01C4AB:
	RTS

CODE_01C4AC:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_CODE_01A80F
	BCC.b Return01C4AB
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_IsChangingItem,x
	BEQ.b CODE_01C4BA
	LDA.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x
	BNE.b Return01C4FA
CODE_01C4BA:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	BNE.b Return01C4FA
CODE_01C4BF:
	LDA.w !RAM_SMW_NorSprXXX_PowerUps_RisingOutOfBlockTimer,x
	CMP.b #$18
	BCS.b Return01C4FA
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin
	BNE.b TouchedPowerUp
	JSL.l SMW_GiveCoins_OneCoin
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	AND.b #$0E
	CMP.b #$02
	BEQ.b CODE_01C4E0
	LDA.b #$01
	BRA.b CODE_01C4EC

CODE_01C4E0:
	LDA.w !RAM_SMW_Counter_CurrentSilverCoins
	INC.w !RAM_SMW_Counter_CurrentSilverCoins
	CMP.b #$0A
	BCC.b CODE_01C4EC
	LDA.b #$0A
CODE_01C4EC:
	JSL.l SMW_GivePoints_Main
CODE_01C4F0:
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_01C4F2:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y
	BEQ.b CODE_01C4FB
	DEY
	BPL.b CODE_01C4F2
Return01C4FA:
	RTS

CODE_01C4FB:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr05_Glitter
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y
	LDA.b #$10
	STA.w !RAM_SMW_SmokeSpr_Timer,y
	RTS

; Table of items to put in the item box when a powerup is touched. Indexed
; by Mario's status ($19), plus 4 times the type of powerup touched.
; Powerups are ordered as follows: $01C510 to $01C513 - Mushroom $01C514 to
; $01C517 - Flower $01C518 to $01C51B - Star $01C51C to $01C51F - Cape
; $01C520 to $01C523 - 1-up For a list of possible values, see $0DC2. Note:
; A value of 0x00 (empty) means that the item in the item box doesn't
; change.
ItemBoxSprite:
	db $00,$01,$01,$01
	db $00,$01,$04,$02
	db $00,$00,$00,$00
	db $00,$01,$04,$02
	db $00,$00,$00,$00

; Action to take when Mario touches a powerup. Indexed by Mario's status
; ($19), plus 4 times the type of powerup touched. Powerups are ordered as
; follows: $01C524 to $01C527 - Mushroom $01C528 to $01C52B - Flower $01C52C
; to $01C52F - Star $01C530 to $01C533 - Cape $01C534 to $01C537 - 1up
; Possible values are: 00: Give a mushroom 01: Do nothing 02: Give a star
; 03: Give a cape 04: Give a flower 05: Give a 1up
GivePowerPtrIndex:
	db $00,$01,$01,$01
	db $04,$04,$04,$01
	db $02,$02,$02,$02
	db $03,$03,$01,$03
	db $05,$05,$05,$05

; Handles what happens when the player touches a powerup. This routine will
; manage the item box as well. $01C549 [0B] is the sound effect to play when
; touching a powerup. Set $01C543 to $80 to prevent the items from being put
; in the item box (though it still can be filled by other means).
TouchedPowerUp:
	SEC				; \ Index created from...
	SBC.b #!Define_SMW_SpriteID_NorSpr074_Mushroom	; | ... powerup touched (upper 2 bits)
	ASL
	ASL
	ORA.b !RAM_SMW_Player_CurrentPowerUp	; | ... Mario's status (lower 3 bits)
	TAY
	LDA.w ItemBoxSprite,y		; \ Put appropriate item in item box
	BEQ.b NoItem
	STA.w !RAM_SMW_Player_CurrentItemBox
	LDA.b #!Define_SMW_Sound1DFC_PutItemInReserve
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
NoItem:
	LDA.w GivePowerPtrIndex,y	; \ Call routine to change Mario's status
	JSL.l SMW_ExecutePtr_Absolute

; powerup routines (indexed by values from $01C524 - $01C537)
HandlePowerUpPtrs:
	dw GiveMarioMushroom		; 0 - Big
	dw CODE_01C56F			; 1 - No change
	dw GiveMarioStar		; 2 - Star
	dw GiveMarioCape		; 3 - Cape
	dw GiveMarioFire		; 4 - Fire
	dw GiveMario1Up			; 5 - 1Up 13

Return01C560:
	RTS ; Unused

; Routine for when Mario touches a Mushroom. It sets the animation value and
; timer, then jumps to $01C56F. $01C566: [$2F] replace with [$00] to
; completely skip the Mushroom powerup animation.
GiveMarioMushroom:
	LDA.b #!Define_SMW_PlayerState02_Grow	; \ Set growing action
	STA.b !RAM_SMW_Player_CurrentState
	LDA.b #$2F
if ver_is_japanese(!Define_Global_ROMToAssemble)
	STA.w !RAM_SMW_Player_AnimationTimer
else
	STA.w !RAM_SMW_Player_AnimationTimer,y			; Note: That ,y seems very questionable to me...
endif
	STA.b !RAM_SMW_Flag_SpritesLocked	; / Set lock sprites timer
	JMP.w CODE_01C56F 					; Optimization: Jump to next instruction...

CODE_01C56F:
	LDA.b #$04			; 04=1000 points in points routine, so load A with 04
	LDY.w !RAM_SMW_NorSpr_Table7E1534,x	; Load Y with a value from an unknown sprite table, $1534,x
	BNE.b CODE_01C57A		; if that value is not 00, skip points routine
	JSL.l SMW_GivePoints_Main	; otherwise, jump to points routine
CODE_01C57A:
	LDA.b #!Define_SMW_Sound1DF9_GetPowerup	; \ play sound effect:
	STA.w !RAM_SMW_IO_SoundCh1	; / "get mushroom" sound effect
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_PowerUps_Status08(Address)
namespace SMW_NorSprXXX_PowerUps_Status08
%InsertMacroAtXPosition(<Address>)

GiveMarioStar:
	JSL.l SMW_GivePlayerStarPower_Main	; jump to actual star code (inefficiently; a byte could be saved here by using JSR instead, since we're already in bank 01)
	BRA.b CODE_01C56F		; jump to same points routine used by the mushroom

GiveMarioCape:
	LDA.b #$02			; set Mario's powerup to 02,
	STA.b !RAM_SMW_Player_CurrentPowerUp	; giving him a cape
	LDA.b #!Define_SMW_Sound1DF9_GetCape	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #$04			; use same points routine that all powerups use:
	JSL.l SMW_GivePoints_Main	; 04: 1000 points
	JSL.l CODE_01C5AE		; JSL to next part of cape code (again, JSR would have worked)
	INC.b !RAM_SMW_Flag_SpritesLocked	; increment sprite lock timer
	RTS

CODE_01C5AE:
	LDA.b !RAM_SMW_Player_OnScreenPosYHi		;\ Glitch: This will cause the game to freeze if you collect a feather while above the screen in an autoscroll level.
	ORA.b !RAM_SMW_Player_OnScreenPosXHi		;| To fix, move these instructions to be after the STA.w !RAM_SMW_Player_AnimationTimer
	BNE.b Return01C5EB				;/
	LDA.b #!Define_SMW_PlayerState03_GotCape
	STA.b !RAM_SMW_Player_CurrentState	; display "get cape" animation ($71=03)
	LDA.b #$18			; set Mario hurt frame counter
	STA.w !RAM_SMW_Player_AnimationTimer	; to 18
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_01C5BF:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y	; load fourth slot of smoke image table
	BEQ.b CODE_01C5D4		; if that slot is unused, skip check with $1863
	DEY				; decrement Y, and if Y is still positive...
	BPL.b CODE_01C5BF		; check next slot of smoke image table
	DEC.w !RAM_SMW_SmokeSpr_SlotToOverwriteWhenSlotsFull	; if all four slots of table full, decrement $1863 (indexing to replace old slots.)
	BPL.b CODE_01C5D1		; if $1863>=0, skip next part (storing to $1863)
	LDA.b #!Define_SMW_MaxSmokeSpriteSlot	; if $1863 is negative,
	STA.w !RAM_SMW_SmokeSpr_SlotToOverwriteWhenSlotsFull	; change it to 03
CODE_01C5D1:
	LDY.w !RAM_SMW_SmokeSpr_SlotToOverwriteWhenSlotsFull	; load $1863...
CODE_01C5D4:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr01_PuffOfSmoke|$80	; set type of smoke image: $81 (?)
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y
	LDA.b #$1B			; set time to show smoke image: $18
	STA.w !RAM_SMW_SmokeSpr_Timer,y
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b #$08			; Y position of smoke image:
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y	; 8 pixels below Mario
	LDA.b !RAM_SMW_Player_XPosLo	; X position of smoke image
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y	; matches Mario's X position
Return01C5EB:
	RTL

; Routine for when Mario touches a Fire Flower. It sets the animation value
; and timer, then jumps to $01C56F. $01C5EC: [$A9 $20] Replace with [$80
; $09] to completely skip the Fire Flower powerup animation.
GiveMarioFire:
	LDA.b #$20			;\ make mario's palette flash
	STA.w !RAM_SMW_Timer_PlayerPaletteCycle	;/
	STA.b !RAM_SMW_Flag_SpritesLocked	;/ and lock the sprites for that same amount of time
	LDA.b #!Define_SMW_PlayerState04_GotFlower	;\ set the "get powerup" animation
	STA.b !RAM_SMW_Player_CurrentState	;/
	LDA.b #$03			;\
	STA.b !RAM_SMW_Player_CurrentPowerUp	;/ make mario firey
	JMP.w CODE_01C56F

GiveMario1Up:
	LDA.b #$08			;\
	CLC				;|points to give is calculated
	ADC.w !RAM_SMW_NorSpr_Table7E1594,x	;/
	JSL.l SMW_GivePoints_Main
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_PowerUps_Status08_ChangingItemEntry, SMW_NorSpr081_ChangingItem_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_PowerUps_Status08_FireFlowerEntry, SMW_NorSpr075_FireFlower_Status08_Main)

	%SetDuplicateOrNullPointer(SMW_NorSprXXX_PowerUps_Status08_MovingCoinEntry, SMW_NorSpr021_MovingCoin_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_PowerUps_Status08_MushroomEntry, SMW_NorSpr074_Mushroom_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_PowerUps_Status08_StarEntry, SMW_NorSpr076_Star_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_PowerUps_Status08_OneUpMushroomEntry, SMW_NorSpr078_1upMushroom_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr082_BonusGame_Status01(Address)
namespace SMW_NorSpr082_BonusGame_Status01
%InsertMacroAtXPosition(<Address>)

DATA_01DD90:
	db $F0,$50,$78,$A0,$A0,$A0,$78,$50
	db $50

DATA_01DD99:
	db $78,$F0,$F0,$F0,$18,$40,$40,$40
	db $18

DATA_01DDA2:
	db $18,$03,$00,$00,$01,$01,$02,$02
	db $03,$FF

Main:
	LDA.w !RAM_SMW_Flag_DisableBonusGameSprite
	BEQ.b CODE_01DDB5
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

CODE_01DDB5:
	LDX.b #!Define_SMW_StockMaxNormalSpriteSlot-$02
CODE_01DDB7:
if defined("Define_SMW_SA1")
	; SA-1 Pack: Bonus game needs fixing.
	JSL.l BONUS_GAME_SET
	NOP
else
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
endif
	LDA.b #!Define_SMW_SpriteID_NorSpr082_BonusGame
	STA.w !RAM_SMW_NorSpr_SpriteID,x
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_01DD90,x
else
	LDA.w DATA_01DD90,x
endif
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_01DD99,x
else
	LDA.w DATA_01DD99,x
endif
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	ASL
	LDA.b #$00
	BCS.b CODE_01DDD6
	INC
CODE_01DDD6:
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_01DDA2,x
else
	LDA.w DATA_01DDA2,x
endif
	STA.w !RAM_SMW_NorSpr082_BonusGame_MovementDirection,x
	TXA
	CLC
	ADC.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	STA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	DEX
	BNE.b CODE_01DDB7
	STZ.w !RAM_SMW_Sprites_BonusGameIsOverFlag
	STZ.w !RAM_SMW_Counter_NumberOfBonusGame1upsToSpawn
	JSL.l SMW_GetRand_Main
	EOR.b !RAM_SMW_Counter_GlobalFrames
	ADC.b !RAM_SMW_Counter_LocalFrames
	AND.b #$07
	TAY
	LDA.w SMW_NorSpr082_BonusGame_Status08_DATA_01DE21,y
	STA.w !RAM_SMW_NorSpr_AnimationFrameCounter+$09
	LDA.b #$01
	STA.b !RAM_SMW_NorSpr082_BonusGame_AnimationFlag+$09
	INC.w !RAM_SMW_Flag_DisableBonusGameSprite
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr082_BonusGame_Status08(Address)
namespace SMW_NorSpr082_BonusGame_Status08
%InsertMacroAtXPosition(<Address>)

DATA_01DE11:
	db $10,$00,$F0,$00

DATA_01DE15:
	db $00,$10,$00,$F0

DATA_01DE19:
	db $A0,$A0,$50,$50

DATA_01DE1D:
	db $F0,$40,$40,$F0

DATA_01DE21:
	db $01,$01,$01,$04,$04,$04,$07,$07
	db $07

Main:
	STZ.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	CPX.b #$01
	BNE.b CODE_01DE34
	JSR.w Spawn1ups
CODE_01DE34:
	JSR.w CODE_01DF19
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Return if sprites locked
	BNE.b Return01DE40
	LDA.w !RAM_SMW_Sprites_BonusGameIsOverFlag
	BEQ.b CODE_01DE41
Return01DE40:
	RTS

CODE_01DE41:
	LDA.b !RAM_SMW_NorSpr082_BonusGame_AnimationFlag,x
	BNE.b CODE_01DE8C
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$03
	BNE.b CODE_01DE58
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	CMP.b #$09
	BNE.b CODE_01DE58
	STZ.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
CODE_01DE58:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	BCC.b CODE_01DE8C
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_01DE8C
	LDA.b #$F4
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_01DE69
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$FC
else
	LDA.b #$00
endif
CODE_01DE69:
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b !RAM_SMW_Player_OnScreenPosYLo
	BCS.b CODE_01DE8C
	LDA.b #$10
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b #!Define_SMW_Sound1DF9_ONOFFSwitch	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	INC.b !RAM_SMW_NorSpr082_BonusGame_AnimationFlag,x
	LDY.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.w DATA_01DE21,y
	STA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr082_BonusGame_HitAnimationTimer,x
CODE_01DE8C:
	LDY.w !RAM_SMW_NorSpr082_BonusGame_MovementDirection,x
	BMI.b Return01DEAF
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.w DATA_01DE19,y
	BNE.b CODE_01DE9F
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.w DATA_01DE1D,y
	BEQ.b CODE_01DEB0
CODE_01DE9F:
	LDA.w DATA_01DE11,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w DATA_01DE15,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
Return01DEAF:
	RTS

CODE_01DEB0:
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$02
CODE_01DEB2:
	LDA.w !RAM_SMW_NorSpr082_BonusGame_AnimationFlag,y
	BEQ.b CODE_01DED7
	LDA.w !RAM_SMW_NorSpr_YPosLo,y
	CLC
	ADC.b #$04
	AND.b #$F8
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosLo,y
	CLC
	ADC.b #$04
	AND.b #$F8
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	DEY
	BNE.b CODE_01DEB2
	INC.w !RAM_SMW_Sprites_BonusGameIsOverFlag
	JSR.w CODE_01DFD9
	RTS

CODE_01DED7:
	LDA.w !RAM_SMW_NorSpr082_BonusGame_MovementDirection,x
	INC
	AND.b #$03
	TAY
	STA.w !RAM_SMW_NorSpr082_BonusGame_MovementDirection,x
	BRA.b CODE_01DE9F

; Sprite tilemap: Bonus Roulette
DATA_01DEE3:
	db $58,$59,$83,$83,$48,$49,$58,$59
	db $83,$83,$48,$49,$34,$35,$83,$83
	db $24,$25,$34,$35,$83,$83,$24,$25
	db $36,$37,$83,$83,$26,$27,$36,$37
	db $83,$83,$26,$27

; Palette info for the items in the bonus game sprite (0x82). The first
; three bytes are the palette for the Star. The next three are for the
; Mushroom, and the last three are for the Fire Flower. They're all
; expressed as even numbers where 00 = Lunar Magic palette 8, 02 = LM
; palette 9, and so on.
DATA_01DF07:
	db $04,$04,$04,$08,$08,$08,$0A,$0A
	db $0A

DATA_01DF10:
	db $00,$03,$05,$07,$08,$08,$07,$05
	db $03

CODE_01DF19:
	LDA.w !RAM_SMW_NorSpr082_BonusGame_HitAnimationTimer,x
	LSR
	TAY
	LDA.w DATA_01DF10,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$44].XDisp,y
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$42].XDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$41].XDisp,y
	STA.w SMW_OAMBuffer[$43].XDisp,y
	LDA.w !RAM_SMW_NorSpr082_BonusGame_FlashBlockLineTimer,x
	CLC
	BEQ.b CODE_01DF4E
	LSR
	LSR
	LSR
	LSR
	BRA.b CODE_01DF4D

ADDR_01DF49: ; Unreachable
	CLC				; \ Unreachable instructions
	ADC.w !RAM_SMW_NorSpr_CurrentSlotID

CODE_01DF4D:
	LSR
CODE_01DF4E:
	PHP
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$44].YDisp,y
	PLP
	BCS.b CODE_01DF6C
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$42].YDisp,y
	STA.w SMW_OAMBuffer[$43].YDisp,y
CODE_01DF6C:
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	PHX
	PHA
	ASL
	ASL
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_01DEE3,x
else
	LDA.w DATA_01DEE3,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_01DEE3+$01,x
else
	LDA.w DATA_01DEE3+$01,x
endif
	STA.w SMW_OAMBuffer[$41].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_01DEE3+$02,x
else
	LDA.w DATA_01DEE3+$02,x
endif
	STA.w SMW_OAMBuffer[$42].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_01DEE3+$03,x
else
	LDA.w DATA_01DEE3+$03,x
endif
	STA.w SMW_OAMBuffer[$43].Tile,y
	LDA.b #$E4
	STA.w SMW_OAMBuffer[$44].Tile,y
	PLX
	LDA.b !RAM_SMW_Sprites_TilePriority
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ORA.l DATA_01DF07,x
else
	ORA.w DATA_01DF07,x
endif
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	STA.w SMW_OAMBuffer[$42].Prop,y
	STA.w SMW_OAMBuffer[$43].Prop,y
	ORA.b #$01
	STA.w SMW_OAMBuffer[$44].Prop,y
	PLX
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$42].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$43].Slot,y
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$44].Slot,y
	RTS

DATA_01DFC1:
	db $00,$01,$02,$02,$03,$04,$04,$05
	db $06,$06,$07,$00,$00,$08,$04,$02
	db $08,$06,$03,$08,$07,$01,$08,$05

CODE_01DFD9:
	LDA.b #$07
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_01DFDD:
	LDX.b #$02
CODE_01DFDF:
	STX.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	TAY
	LDA.w DATA_01DFC1,y
	TAY
	LDA.w SMW_NorSpr082_BonusGame_Status01_DATA_01DD99+$01,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w SMW_NorSpr082_BonusGame_Status01_DATA_01DD90+$01,y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot-$02
CODE_01DFFA:
	LDA.w !RAM_SMW_NorSpr_YPosLo,y
	CMP.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b CODE_01E008
	LDA.w !RAM_SMW_NorSpr_XPosLo,y
	CMP.b !RAM_SMW_Misc_ScratchRAM03
	BEQ.b CODE_01E00D
CODE_01E008:
	DEY
	CPY.b #!Define_SMW_StockMaxNormalSpriteSlot-$0A
	BNE.b CODE_01DFFA
CODE_01E00D:
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,y
	STA.b !RAM_SMW_Misc_ScratchRAM04,x
	STY.b !RAM_SMW_Misc_ScratchRAM07,x
	DEX
	BPL.b CODE_01DFDF
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CMP.b !RAM_SMW_Misc_ScratchRAM05
	BNE.b CODE_01E035
	CMP.b !RAM_SMW_Misc_ScratchRAM06
	BNE.b CODE_01E035
	INC.w !RAM_SMW_Counter_NumberOfBonusGame1upsToSpawn
	LDA.b #$70
	LDY.b !RAM_SMW_Misc_ScratchRAM07
	STA.w !RAM_SMW_NorSpr082_BonusGame_FlashBlockLineTimer,y
	LDY.b !RAM_SMW_Misc_ScratchRAM08
	STA.w !RAM_SMW_NorSpr082_BonusGame_FlashBlockLineTimer,y
	LDY.b !RAM_SMW_Misc_ScratchRAM09
	STA.w !RAM_SMW_NorSpr082_BonusGame_FlashBlockLineTimer,y
CODE_01E035:
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_01DFDD
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDY.b #!Define_SMW_Sound1DFC_Correct
	LDA.w !RAM_SMW_Counter_NumberOfBonusGame1upsToSpawn
	STA.w !RAM_SMW_Counter_RemainingBonusGame1ups
	BNE.b CODE_01E04C
	LDA.b #$58
	STA.w !RAM_SMW_Timer_BonusGameEnd
	INY
CODE_01E04C:
	STY.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr082_BonusGame_Status08(Address)
namespace SMW_NorSpr082_BonusGame_Status08
%InsertMacroAtXPosition(<Address>)

Spawn1ups:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$3F
	BNE.b CODE_01E27B
	LDA.w !RAM_SMW_Counter_NumberOfBonusGame1upsToSpawn
	BEQ.b CODE_01E27B
	DEC.w !RAM_SMW_Counter_NumberOfBonusGame1upsToSpawn
	JSR.w CODE_01E281
CODE_01E27B:
	LDA.b #$01
	STA.w !RAM_SMW_Flag_RunClusterSprites
	RTS

CODE_01E281:
	LDY.b #!Define_SMW_MaxClusterSpriteSlot-$0C
CODE_01E283:
	LDA.w !RAM_SMW_ClusterSpr_SpriteID,y
	BEQ.b CODE_01E28C
	DEY
	BPL.b CODE_01E283
	RTS

CODE_01E28C:
	LDA.b #!Define_SMW_SpriteID_ClusterSpr01_1up
	STA.w !RAM_SMW_ClusterSpr_SpriteID,y
	LDA.b #$00
	STA.w !RAM_SMW_ClusterSpr_YPosLo,y
	LDA.b #$01
	STA.w !RAM_SMW_ClusterSpr_YPosHi,y
	LDA.b #$18
	STA.w !RAM_SMW_ClusterSpr_XPosLo,y
	LDA.b #$00
	STA.w !RAM_SMW_ClusterSpr_XPosHi,y
	LDA.b #$01
	STA.w !RAM_SMW_ClusterSpr01_1up_XSpeed,y
	LDA.b #$10
	STA.w !RAM_SMW_ClusterSpr01_1up_YSpeed,y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr083_LeftFlyingBlock_Status01(Address)
namespace SMW_NorSpr083_LeftFlyingBlock_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	LSR
	LSR
	LSR
	LSR
	AND.b #$03
	STA.w !RAM_SMW_NorSpr083_LeftFlyingBlock_ContentsOfBlock,x
	INC.w !RAM_SMW_NorSpr_FacingDirection,x
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr083_LeftFlyingBlock_Status01_Main, SMW_NorSpr084_HorizontalFlyingBlock_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr083_LeftFlyingBlock_Status01_Main, SMW_NorSpr085_Unused_Status08_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr083_LeftFlyingBlock_Status08(Address)
namespace SMW_NorSpr083_LeftFlyingBlock_Status08
%InsertMacroAtXPosition(<Address>)

Acceleration:
	db $FF,$01

MaxYSpeed:
	db $F4,$0C

MaxXSpeed:
	db $F0,$10

Main:
	LDA.w !RAM_SMW_NorSpr083_LeftFlyingBlock_BlockContentsRisingTimer,x
	BEQ.b CODE_01AD80
	STZ.w !RAM_SMW_NorSpr_OAMIndex,x
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b CODE_01AD80
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
CODE_01AD80:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	DEC
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STZ.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	LDA.b !RAM_SMW_NorSpr083_LeftFlyingBlock_HitFlag,x
	BNE.b CODE_01ADF8
	JSR.w SMW_DrawWingTiles_Main
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_01ADF8
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_01ADB7
	LDA.w !RAM_SMW_NorSpr083_LeftFlyingBlock_VerticalDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w Acceleration,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w MaxYSpeed,y
	BNE.b CODE_01ADB7
	INC.w !RAM_SMW_NorSpr083_LeftFlyingBlock_VerticalDirection,x
CODE_01ADB7:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr083_LeftFlyingBlock
	BEQ.b CODE_01ADE8
	LDA.w !RAM_SMW_NorSpr083_LeftFlyingBlock_WaitBeforeTurningAround,x
	BNE.b CODE_01ADE6
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_01ADE6
	LDA.w !RAM_SMW_NorSpr083_LeftFlyingBlock_HorizontalDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CLC
	ADC.w Acceleration,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxXSpeed,y
	BNE.b CODE_01ADE6
	INC.w !RAM_SMW_NorSpr083_LeftFlyingBlock_HorizontalDirection,x
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr083_LeftFlyingBlock_WaitBeforeTurningAround,x
CODE_01ADE6:
	BRA.b CODE_01ADEC

CODE_01ADE8:
	LDA.b #$F4
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01ADEC:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	LDA.w !RAM_SMW_Sprites_PositionDisp
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
CODE_01ADF8:
	JSR.w SMW_CheckForNormalSpriteToNormalSpriteCollision_Sub
	JSR.w SMW_SolidSpriteBlock_Sub
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.w !RAM_SMW_NorSpr083_LeftFlyingBlock_BounceAnimationTimer,x
	CMP.b #$08
	BNE.b CODE_01AE5E
	LDY.b !RAM_SMW_NorSpr083_LeftFlyingBlock_HitFlag,x
	CPY.b #$02
	BEQ.b CODE_01AE5E
	PHA
	INC.b !RAM_SMW_NorSpr083_LeftFlyingBlock_HitFlag,x
	LDA.b #$50
	STA.w !RAM_SMW_NorSpr083_LeftFlyingBlock_BlockContentsRisingTimer,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.b #$FF			; \ Set to permanently erase sprite
	STA.w !RAM_SMW_NorSpr_LoadStatusTableIndex,x
	LDY.w !RAM_SMW_NorSpr083_LeftFlyingBlock_ContentsOfBlock,x
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_01AE38
	INY
	INY
	INY
	INY
CODE_01AE38:
	LDA.w DATA_01AE88,y
	STA.b !RAM_SMW_Misc_ScratchRAM05
	PHB
	LDA.b #SMW_SpawnBounceSprite_CODE_02887D>>16
	PHA
	PLB
	PHX
	JSL.l SMW_SpawnBounceSprite_CODE_02887D
	PLX
	LDY.w !RAM_SMW_Sprites_PowerUpFromBlockSpriteSlot
	LDA.b #$01
	STA.w !RAM_SMW_NorSprXXX_PowerUps_RisingOutOfSpriteBlockFlag,y
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr075_FireFlower
	BNE.b CODE_01AE5C
	LDA.b #$FF
	STA.w !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,y
CODE_01AE5C:
	PLB
	PLA
CODE_01AE5E:
	LSR
	TAY
	LDA.w DATA_01AE7F,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_NorSpr083_LeftFlyingBlock_HitFlag,x
	CMP.b #$01
	LDA.b #$2A
	BCC.b CODE_01AE7B
	LDA.b #$2E
CODE_01AE7B:
	STA.w SMW_OAMBuffer[$40].Tile,y
	RTS

DATA_01AE7F:
	db $00,$03,$05,$07,$08,$08,$07,$05
	db $03

; Sprites for the flying ? blocks to spawn, as indexes to the table starting
; at $0288A3. First four are used if Mario has a powerup, second four if he
; doesn't.
DATA_01AE88:
	db $06,$02,$04,$05,$06,$01,$01,$05
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr083_LeftFlyingBlock_Status08_Main, SMW_NorSpr084_HorizontalFlyingBlock_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr086_Wiggler_Status01(Address)
namespace SMW_NorSpr086_Wiggler_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr086_Wiggler_Status08(Address)
namespace SMW_NorSpr086_Wiggler_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr087_LakituCloud_Status08(Address)
namespace SMW_NorSpr087_LakituCloud_Status08
%InsertMacroAtXPosition(<Address>)

XDisp:
	db $FC,$04,$FE,$02,$FB,$05,$FD,$03
	db $FA,$06,$FC,$04,$FB,$05,$FD,$03

YDisp:
	db $00,$FF,$03,$04,$FF,$FE,$04,$03
	db $FE,$FF,$03,$03,$FF,$00,$03,$03
	db $F8,$FC,$00,$04

CloudYPosOffset:
	db $0E,$0F,$10,$11,$12,$11,$10,$0F
	db $1A,$1B,$1C,$1D,$1E,$1D,$1C,$1B

UNK_01E7A3:
	db $1A

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BEQ.b NoCloudGfx
CODE_01E7A8:
	JMP.w GFXRt

NoCloudGfx:
	LDY.w !RAM_SMW_Timer_DespawnLakituCloud
	BEQ.b CODE_01E7C5
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$03
	BNE.b CODE_01E7C5
	LDA.w !RAM_SMW_Timer_DespawnLakituCloud
	BEQ.b CODE_01E7C5
	DEC.w !RAM_SMW_Timer_DespawnLakituCloud
	BNE.b CODE_01E7C5
	LDA.b #$1F
	STA.w !RAM_SMW_NorSpr087_LakituCloud_EvaporateTimer,x
CODE_01E7C5:
	LDA.w !RAM_SMW_NorSpr087_LakituCloud_EvaporateTimer,x
	BEQ.b CODE_01E7DB
	DEC
	BNE.b CODE_01E7A8
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$FF			; \ Set time until respawn
	STA.w !RAM_SMW_Timer_RespawnSprite
	LDA.b #!Define_SMW_SpriteID_NorSpr01E_Lakitu	; | Sprite to respawn = Lakitu
	STA.w !RAM_SMW_Sprites_SpriteToRespawn
	RTS

CODE_01E7DB:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_01E7DD:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_01E7F2
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr01E_Lakitu
	BNE.b CODE_01E7F2
	TYA
	STA.w !RAM_SMW_NorSpr087_LakituCloud_LakituSpriteSlot,x
	JMP.w CODE_01E898

CODE_01E7F2:
	DEY
	BPL.b CODE_01E7DD
	LDA.b !RAM_SMW_NorSpr087_LakituCloud_PlayerInCloudFlag,x
	BNE.b CODE_01E840
	LDA.w !RAM_SMW_NorSpr087_LakituCloud_PlayerHasControlledCloudFlag,x
	BEQ.b CODE_01E804
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
CODE_01E804:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	BNE.b CODE_01E83D
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_ProcessInteract
	BCC.b CODE_01E83D
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_01E83D
	INC.b !RAM_SMW_NorSpr087_LakituCloud_PlayerInCloudFlag,x
	LDA.b #$11
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01E81D
	LDA.b #$22
CODE_01E81D:
	CLC
	ADC.b !RAM_SMW_Player_CurrentYPosLo
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Player_CurrentYPosHi
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b !RAM_SMW_Player_CurrentXPosLo
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Player_CurrentXPosHi
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	STA.w !RAM_SMW_NorSpr087_LakituCloud_PlayerHasControlledCloudFlag,x
	LDA.b !RAM_SMW_Player_XSpeed
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01E83D:
	JMP.w GFXRt

CODE_01E840:
	JSR.w GFXRt
	PHB
	LDA.b #SMW_HandleHeldPBalloonAndInLakituCloudMovement_Main>>16
	PHA
	PLB
	JSL.l SMW_HandleHeldPBalloonAndInLakituCloudMovement_Main
	PLB
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.b #$03
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	AND.b #$07
	TAY
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_01E866
	TYA
	CLC
	ADC.b #$08
	TAY
CODE_01E866:
	LDA.b !RAM_SMW_Player_CurrentXPosLo
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Player_CurrentXPosHi
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Player_CurrentYPosLo
	CLC
	ADC.w CloudYPosOffset,y
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Player_CurrentYPosHi
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	STZ.b !RAM_SMW_Player_InAirFlag
	INC.w !RAM_SMW_Misc_PlayerOnSolidSprite
	INC.w !RAM_SMW_Flag_PlayerInLakitusCloud
	LDA.b !RAM_SMW_IO_ControllerPress1
	AND.b #!Joypad_B>>8
	BEQ.b Return01E897
	LDA.b #$C0
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	STZ.b !RAM_SMW_NorSpr087_LakituCloud_PlayerInCloudFlag,x
Return01E897:
	RTS

CODE_01E898:
	PHY
	JSR.w CODE_01E98D
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	AND.b #$07
	TAY
	LDA.w CloudYPosOffset,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	PLY
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
GFXRt:
	JSR.w SMW_GetDrawInfo_Bank01
	LDA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b Return01E897
	LDA.b #$F8
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.b #$FC
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.b #$00
	LDY.b !RAM_SMW_NorSpr087_LakituCloud_PlayerInCloudFlag,x
	BNE.b CODE_01E8E2
	LDA.b #$30
CODE_01E8E2:
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	STA.w !RAM_SMW_NorSpr087_LakituCloud_PlayerInCloudOAMIndex
	ORA.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr087_LakituCloud_TempXPosLo
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr087_LakituCloud_TempYPosLo
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$0C
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM03
CODE_01E901:
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDY.b !RAM_SMW_Misc_ScratchRAM0C,x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l XDisp,x
else
	LDA.w XDisp,x
endif
	CLC
	ADC.w !RAM_SMW_NorSpr087_LakituCloud_TempXPosLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l YDisp,x
else
	LDA.w YDisp,x
endif
	CLC
	ADC.w !RAM_SMW_NorSpr087_LakituCloud_TempYPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b #$60
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w !RAM_SMW_NorSpr087_LakituCloud_EvaporateTimer,x
	BEQ.b CODE_01E935
	LSR
	LSR
	LSR
	TAX
	LDA.w EvaporatingCloudTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
CODE_01E935:
	LDA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM03
	BPL.b CODE_01E901
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b #$F8
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	LDY.b #$02
	LDA.b #$01
	JSR.w SMW_FinishOAMWrite_Sub
	LDA.w !RAM_SMW_NorSpr087_LakituCloud_PlayerInCloudOAMIndex
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	LDY.b #$02
	LDA.b #$01
	JSR.w SMW_FinishOAMWrite_Sub
	; Change to 60 (RTS) to remove the face on Lakitu's cloud
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BNE.b Return01E984
	LDA.w !RAM_SMW_NorSpr087_LakituCloud_TempXPosLo
	CLC
	ADC.b #$04
	STA.w SMW_OAMBuffer[$02].XDisp
	LDA.w !RAM_SMW_NorSpr087_LakituCloud_TempYPosLo
	CLC
	ADC.b #$07
	STA.w SMW_OAMBuffer[$02].YDisp
	LDA.b #$4D
	STA.w SMW_OAMBuffer[$02].Tile
	LDA.b #$39
	STA.w SMW_OAMBuffer[$02].Prop
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$02].Slot
Return01E984:
	RTS

; Cloud Tilemap
EvaporatingCloudTiles:
	db $66,$64,$62,$60

MaxLakituXSpeed:
	db $20,$E0

MaxLakituYSpeed:
	db $10,$F0

CODE_01E98D:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01E984
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	TYA
	LDY.w !RAM_SMW_NorSpr087_LakituCloud_LakituSpriteSlot,x
	STA.w !RAM_SMW_NorSpr_FacingDirection,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Timer_DisappearingSprite
	BEQ.b CODE_01E9BD
	PHY
	PHX
	LDA.w !RAM_SMW_NorSpr087_LakituCloud_LakituSpriteSlot,x
	TAX
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	PLX
	CMP.b #!Define_SMW_NorSprStatus00_EmptySlot
	BNE.b CODE_01E9B8
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
CODE_01E9B8:
	PLY
	TYA
	EOR.b #$01
	TAY
CODE_01E9BD:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_01E9E6
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxLakituXSpeed,y
	BEQ.b CODE_01E9D0
	CLC
	ADC.w SMW_GenericNormalSpriteAccelerationTable_Main,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01E9D0:
	LDA.w !RAM_SMW_NorSpr087_LakituCloud_VerticalDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w SMW_GenericNormalSpriteAccelerationTable_Main,y
	; Change to 74 to disable Lakitu vertical movement
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w MaxLakituYSpeed,y
	BNE.b CODE_01E9E6
	INC.w !RAM_SMW_NorSpr087_LakituCloud_VerticalDirection,x
CODE_01E9E6:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	PHA
	LDY.w !RAM_SMW_Timer_DisappearingSprite
	BNE.b CODE_01E9F9
	LDA.w !RAM_SMW_Misc_Layer1XDisp
	ASL
	ASL
	ASL
	CLC
	ADC.b !RAM_SMW_NorSpr_XSpeed,x
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_01E9F9:
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	PLA
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDY.w !RAM_SMW_NorSpr087_LakituCloud_LakituSpriteSlot,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$7F
	ORA.w !RAM_SMW_NorSpr01E_Lakitu_FishingFlag,y
	BNE.b Return01EA16
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr01E_Lakitu_ThrowingAnimationTimer,y
	JSR.w SMW_MakeLakituThrowSpiny_Sub
Return01EA16:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_MakeLakituThrowSpiny(Address)
namespace SMW_MakeLakituThrowSpiny
%InsertMacroAtXPosition(<Address>)

InitialXSpeed:
	db $10,$F0

; Wrapper for the subroutine at $01EA21 (changes the data bank and JSRs to
; it).
Main:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

; A subroutine for spawning a Spiny egg. This is used by both the normal and
; pipe-dwelling Lakitus, and it can be called via the wrapper at $01EA19.
; $01EA32 is the sprite Lakitu throws. $01EA36 is the sprite Lakitu throws
; when a silver P-switch is active. $01EA69 is the palette of the sprite
; Lakitu throws when a silver P-Switch is active.
Sub:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return01EA6F
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.w !RAM_SMW_Timer_SilverPSwitch
	CMP.b #$01
	LDA.b #!Define_SMW_SpriteID_NorSpr014_SpinyEgg
	BCC.b CODE_01EA37
	LDA.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin
CODE_01EA37:
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b #$D8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X
	LDA.w InitialXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
if defined("Define_SMW_SA1")
	; SA-1 Pack: Spiney throwing an object. I'd rather just hijack to use the
	; new address than doing a set and restore.
	JSL.l SPRITE_NUM_REMAP4
else
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin
endif
	BNE.b CODE_01EA6D
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr_Table7E15F6,x
CODE_01EA6D:
	TXY
	PLX
Return01EA6F:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr088_WingedCage_Status01(Address)
namespace SMW_NorSpr088_WingedCage_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	PHB						;\ Optimization: Useless init routine.
	LDA.b #Bank02>>16				;|
	PHA						;|
	PLB						;|
	JSL.l Bank02					;|
	PLB						;/
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr088_WingedCage_Status08(Address)
namespace SMW_NorSpr088_WingedCage_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	PHB
	LDA.b #Bank02>>16
	PHA
	PLB
	JSL.l Bank02			; the infamous winged cage!
	PLB
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr089_Layer3Smasher_Status08(Address)
namespace SMW_NorSpr089_Layer3Smasher_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	PHB
	LDA.b #Bank02>>16
	PHA
	PLB
	JSL.l Bank02
	PLB
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's horizontally offscreen
; Glitch: This sprite does not call FinishOAMWrite, which means its tiles can wrap around the screen
; Note: This sprite does not call GetDrawInfo

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr08A_Bird_Status08(Address)
namespace SMW_NorSpr08A_Bird_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Glitch: This sprite does not use the sprite lock flag ($7E009D) so it will not pause along with other sprites
; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's horizontally offscreen
; Note: This sprite could have easily been a smoke/minor extended sprite. Why is it a normal sprite?

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr08B_FireplaceSmoke_Status08(Address)
namespace SMW_NorSpr08B_FireplaceSmoke_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's offscreen
; Glitch: This sprite does not use the sprite lock flag ($7E009D) so it will not pause along with other sprites

macro ROUTINE_RT00_SMW_NorSpr08C_SideExitAndFireplace_Status08(Address)
namespace SMW_NorSpr08C_SideExitAndFireplace_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Note: This sprite does not call GetDrawInfo
; Glitch: This sprite does not call FinishOAMWrite, which means its tiles can wrap around the screen
; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's offscreen

macro ROUTINE_RT00_SMW_NorSpr08D_GhostHouseDoor_Status08(Address)
namespace SMW_NorSpr08D_GhostHouseDoor_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Glitch: This sprite does not call SubOffscreen, so it will never be erased if it's offscreen

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr08E_WarpHole_Status08(Address)
namespace SMW_NorSpr08E_WarpHole_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr08F_ScalePlatform_Status01(Address)
namespace SMW_NorSpr08F_ScalePlatform_Status01
%InsertMacroAtXPosition(<Address>)

ScalePlatWidth:
	db $80,$40

Main:
;$0183B5
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\
	STA.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosLo,x	;/ save init Ypos for later?
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;\
	STA.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosHi,x	;/ save init yhipos for later?
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\
	AND.b #$10			;|
	LSR				;|
	LSR				;|
	LSR				;|Find out where the other
	LSR				;|mushroom platform is going to be,
	TAY				;|based on Xpos
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;|
	CLC				;|
	ADC.w ScalePlatWidth,y		;|And store in a extra info table
	STA.b !RAM_SMW_NorSPr08F_ScalePlatform_RightPlatformXPosLo,x	;/ (C2 is not the sprite state.)
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;\
	ADC.b #$00			;|And set the sprite image according to the
	STA.w !RAM_SMW_NorSPr08F_ScalePlatform_RightPlatformXPosHi,x	;/hi xpos byte
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr08F_ScalePlatform_Status08(Address)
namespace SMW_NorSpr08F_ScalePlatform_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr090_GreenGasBubble_Status08(Address)
namespace SMW_NorSpr090_GreenGasBubble_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr091_CharginChuck_Status01(Address)
namespace SMW_NorSpr091_CharginChuck_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr091_CharginChuck_Status01_Main, SMW_NorSpr096_CharginChuckCopy_Status01_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr091_CharginChuck_Status08(Address)
namespace SMW_NorSpr091_CharginChuck_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr091_CharginChuck_Status08_Main, SMW_NorSpr092_SplittinChuck_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr091_CharginChuck_Status08_Main, SMW_NorSpr093_BouncinChuck_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr091_CharginChuck_Status08_Main, SMW_NorSpr094_WhistlinChuck_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr091_CharginChuck_Status08_Main, SMW_NorSpr095_ClappinChuck_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr091_CharginChuck_Status08_Main, SMW_NorSpr096_CharginChuckCopy_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr091_CharginChuck_Status08_Main, SMW_NorSpr097_PuntinChuck_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr091_CharginChuck_Status08_Main, SMW_NorSpr098_PitchinChuck_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr095_ClappinChuck_Status01(Address)
namespace SMW_NorSpr095_ClappinChuck_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$08			;\do the standard chuck thing, with
	BRA.b CODE_01851A		;/ it's own special code

PitchinChuckEntry:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\
	AND.b #$30			;|
	LSR				;|
	LSR				;|
	LSR				;|Make it's Xpos do something
	LSR				;|
	STA.w !RAM_SMW_NorSpr098_PitchinChuck_BaseballThrowSetIndex,x	;/
	LDA.b #$0A			;\ run the standard chuck thing, with
	BRA.b CODE_01851A		;/ it's own special code

PuntinChuckEntry:
	LDA.b #$09			;\ run the standard chuck thing, with
	BRA.b CODE_01851A		;/ it's own special code

WhistlinChuckEntry:
	LDA.b #$0B			;\ run the standard chuck thing, with
	BRA.b CODE_01851A		;/ it's own special code

SplittinChuckEntry:
BouncinChuckEntry:
	LDA.b #$05			;\ run the standard chuck thing with
	BRA.b CODE_01851A		;/ it's own special code

DigginChuckEntry:
	LDA.b #$30			;\
	STA.w !RAM_SMW_NorSpr046_DigginChuck_DiggingTimer,x	;/ set the chuck-related thing to 30
	LDA.b !RAM_SMW_NorSpr_XPosLo_x						;\ Optimization: This code is useless due to the JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main
	AND.b #$10								;| Glitch: Alternatively, digging chucks aren't supposed to spawn facing towards the player
	LSR									;|
	LSR									;|
	LSR									;|
	LSR									;|
	STA.w !RAM_SMW_NorSpr_FacingDirection,x					;/
	LDA.b #$04
CODE_01851A:
	STA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x	;sprite state is used as a "chuck type" for chucks, since they share a ton of code
	; [20 7C 85] Change to [BC 7C 15] to make the Diggin' Chuck's starting
	; direction depend on its X position instead of it always starting out
	; facing the player.
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main	; face mario
	LDA.w DATA_018526,y		;\
	STA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x	;/ Ydir is either 00 or 04...
	RTS

DATA_018526:
	db $00,$04
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr095_ClappinChuck_Status01_DigginChuckEntry, SMW_NorSpr046_DigginChuck_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr095_ClappinChuck_Status01_SplittinChuckEntry, SMW_NorSpr092_SplittinChuck_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr095_ClappinChuck_Status01_BouncinChuckEntry, SMW_NorSpr093_BouncinChuck_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr095_ClappinChuck_Status01_WhistlinChuckEntry, SMW_NorSpr094_WhistlinChuck_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr095_ClappinChuck_Status01_PuntinChuckEntry, SMW_NorSpr097_PuntinChuck_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr095_ClappinChuck_Status01_PitchinChuckEntry, SMW_NorSpr098_PitchinChuck_Status01_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr099_VolcanoLotus_Status08(Address)
namespace SMW_NorSpr099_VolcanoLotus_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr09A_SumoBro_Status01(Address)
namespace SMW_NorSpr09A_SumoBro_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$03
	STA.b !RAM_SMW_NorSpr09A_SumoBro_CurrentState,x
	LDA.b #$70
CODE_018379:
	STA.w !RAM_SMW_NorSpr09A_SumoBro_PhaseTimer,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr09A_SumoBro_Status08(Address)
namespace SMW_NorSpr09A_SumoBro_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Note: This sprite won't display its graphics unless it's either dying or Normal sprite 09C exists.

;---------------------------------------------------------------------------

macro ROUTINE_SMW_NorSpr09B_HammerBro_Status01(Address)
namespace SMW_NorSpr09B_HammerBro_Status01
%InsertMacroAtXPosition(<Address>)

Main:								;\ Optimization: Useless init routine.
	JSL.l SMW_NorSpr09B_HammerBro_Status08_Bank02_Return	;|
	RTS							;/
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr09B_HammerBro_Status08(Address)
namespace SMW_NorSpr09B_HammerBro_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr09C_HammerBroPlatform_Status08(Address)
namespace SMW_NorSpr09C_HammerBroPlatform_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr09D_BubbleWithSprite_Status01(Address)
namespace SMW_NorSpr09D_BubbleWithSprite_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_NorSpr04C_ExplodingBlock_Status01_Main	; work a abit like the exploding block
	STY.b !RAM_SMW_NorSpr09D_BubbleWithSprite_Contents,x	; ^ just finishing up with that ^
	DEC.w !RAM_SMW_NorSpr09D_BubbleWithSprite_TimerUntilPopping,x	; some sprite table...
	BRA.b SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main	; face mario
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr09D_BubbleWithSprite_Status08(Address)
namespace SMW_NorSpr09D_BubbleWithSprite_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr09E_BallNChain_Status01(Address)
namespace SMW_NorSpr09E_BallNChain_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$38
	BRA.b CODE_01839C

GreyChainedPlatformEntry:
	LDA.b #$30
CODE_01839C:								; LM: Sprite 7B (Goal Tape) uses this code when being loaded. (3.00+)
	STA.w !RAM_SMW_NorSpr09E_BallNChain_ChainLength,x
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr09E_BallNChain_Status01_GreyChainedPlatformEntry, SMW_NorSpr0A3_GreyChainedPlatform_Status01_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr09F_BanzaiBill_Status01(Address)
namespace SMW_NorSpr09F_BanzaiBill_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank01_X	;\ If mario is to the right of
	TYA				;| the banzai bill....
	BNE.b FireLeft			;|
	JMP.w SMW_SubOffscreen_Bank01_EraseSprite	;/ erase it
								; Optimization: If the bullet bill's init routine was moved here, it would allow it to play its usual sound when placed into a level directly and save a byte at the same time.
FireLeft:
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr09F_BanzaiBill_Status08(Address)
namespace SMW_NorSpr09F_BanzaiBill_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank02
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0A0_ActivateBowserBattle_Status01(Address)
namespace SMW_NorSpr0A0_ActivateBowserBattle_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank03
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_NorSpr0A0_ActivateBowserBattle_Status08(Address)
namespace SMW_NorSpr0A0_ActivateBowserBattle_Status08
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank03
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr01B_Football_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr051_Ninji_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr07A_Fireworks_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr07C_PrincessPeach_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0A1_BowserBowlingBall_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0A2_MechaKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0A8_Blargg_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0A9_Reznor_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0AA_Fishbone_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0AB_Rex_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0AC_DownFirstWoodenSpike_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0AD_UpDownFirstWoodenSpike_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0AE_FishinBoo_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0B0_ReflectingBooBuddies_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0B1_CreateEatBlock_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0B2_FallingSpike_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0B3_BowserStatueFire_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0B6_ReflectingPodoboo_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0B7_CarrotTopLiftUpperRight_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0B8_CarrotTopLiftUpperLeft_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0B9_MessageBox_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0BA_TimedPlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0BB_MovingCastleStone_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0BC_BowserStatue_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0BE_Swooper_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0BF_MegaMole_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0C0_SinkingLavaPlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0C1_WingedPlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0C2_Blurp_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0C3_PorcuPuffer_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0C4_GreyFallingPlatform_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0C5_BigBooBoss_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0C6_Spotlight_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0C7_InvisibleMushroom_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr0A0_ActivateBowserBattle_Status08_Main, SMW_NorSpr0C8_LightSwitch_Status08_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0A7_IggyBall_Status08(Address)
namespace SMW_NorSpr0A7_IggyBall_Status08
%InsertMacroAtXPosition(<Address>)

XFlip:
	db $40,$00

; Iggy/Larry ball tilemap
Tiles:
	db $4A,$4C,$4A,$4C

Prop:
	db $35,$35,$F5,$F5

XSpeed:
	db $10,$F0

Main:
	JSR.w SMW_GenericGFXRtDraw1Tile16x16_Sub_Entry1
	LDY.w !RAM_SMW_NorSpr0A7_IggyBall_HorizontalMovementDirection,x
	LDA.w XFlip,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$03
	PHX
	TAX
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	EOR.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01FAB3
	LDY.w !RAM_SMW_NorSpr0A7_IggyBall_HorizontalMovementDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_X
	JSR.w SMW_UpdateNormalSpritePositionBank01_Sub_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$40
	BPL.b CODE_01FA9A
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01FA9A:
	JSR.w CheckForTiltingPlatformCollision
	BCC.b CODE_01FAA3
	LDA.b #$F0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_01FAA3:
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$44
	BCC.b Return01FAB3
	CMP.b #$50
	BCS.b Return01FAB3
	JSR.w SMW_NorSprStatus02_Dead_SetNorSprStatus04_Main
Return01FAB3:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0A7_IggyBall_Status08(Address)
namespace SMW_NorSpr0A7_IggyBall_Status08
%InsertMacroAtXPosition(<Address>)

CheckForTiltingPlatformCollision:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $14B4,$14B5 = Sprite X position + #$08
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $14B6,$14B7 = Sprite Y position + #$0F
	CLC
	ADC.b #$0F
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetHi
	PHX
	JSL.l SMW_CheckForTiltingPlatformCollision_Main
	PLX
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0A9_Reznor_Status01(Address)
namespace SMW_NorSpr0A9_Reznor_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank03			;----------I'm not going to comment this. it is simply the JSL to the main sprite routines.
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0AA_Fishbone_Status01(Address)
namespace SMW_NorSpr0AA_Fishbone_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l SMW_GetRand_Main		;\get a random number...
	AND.b #$1F			;|
	STA.w !RAM_SMW_NorSpr0AA_Fishbone_PhaseTimer,x	;/  calculate frames using it
	JMP.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main	; and, as always, face mario.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0AC_DownFirstWoodenSpike_Status01(Address)
namespace SMW_NorSpr0AC_DownFirstWoodenSpike_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\
	SEC				;| Take the wood spike's original position and
	SBC.b #$40			;| drop it down a bit
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;/
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;\
	SBC.b #$00			;| If that means changing the XhiPos, then
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;/ be it
	; Change to EA to make both wooden spikes move up or down depending on X&1
	; instead of sprite AC always moving down first.
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0AD_UpDownFirstWoodenSpike_Status01(Address)
namespace SMW_NorSpr0AD_UpDownFirstWoodenSpike_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	JMP.w SMW_NorSpr01E_Lakitu_Status01_SetLakituType	;  jump to the monty mole init. Who knew they had the same init routine?
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_ReflectingEnemy_Status01(Address)
namespace SMW_NorSprXXX_ReflectingEnemy_Status01
%InsertMacroAtXPosition(<Address>)

; Initial leftward and rightward X speeds of diagonally moving sprites, i.e.
; stream of boo buddies and reflecting fireball (F0).
InitYSpeed:
	db $10,$F0

Main:
;$01834E
	JSR.w SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main	; Check to see which direction mario is, Y = which
	LDA.w InitYSpeed,y		;\
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/ Set the X speed accordingly
	LDA.b #$F0			;\ set to slowly go up
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_ReflectingEnemy_Status01_Main, SMW_NorSpr0B0_ReflectingBooBuddies_Status01_Main)
	%SetDuplicateOrNullPointer(SMW_NorSprXXX_ReflectingEnemy_Status01_Main, SMW_NorSpr0B6_ReflectingPodoboo_Status01_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0B1_CreateEatBlock_Status01(Address)
namespace SMW_NorSpr0B1_CreateEatBlock_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$FF			;\
	STA.w !RAM_SMW_Flag_ActiveCreateEatBlock	;|run the monty mole routines
	BRA.b SMW_NorSpr01E_Lakitu_Status01_SetLakituType	;/
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0B3_BowserStatueFire_Status01(Address)
namespace SMW_NorSpr0B3_BowserStatueFire_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #!Define_SMW_Sound1DFC_FireSpit
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	BRA.b SMW_NorSprXXX_GenericEnemies_Status01_MakeSpriteFacePlayer_Main	; face mario
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0B4_NonLineGuideGrinder_Status08(Address)
namespace SMW_NorSpr0B4_NonLineGuideGrinder_Status08
%InsertMacroAtXPosition(<Address>)

XSpeed:
	db $18,$E8

Main:
	JSR.w GFXRt
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b Return01DB95
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return01DB95
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_01DB75
	LDA.b #!Define_SMW_Sound1DFA_Grinder	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
CODE_01DB75:
	JSR.w SMW_SubOffscreen_Bank01_Entry1
	JSR.w SMW_CheckForPlayerToNormalSpriteCollision_Sub
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_HandleNormalSpriteGravity_Sub
	JSR.w SMW_CheckNormalSpriteLevelCollision_Floor
	BEQ.b CODE_01DB8D
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_01DB8D:
	JSR.w SMW_CheckNormalSpriteLevelCollision_Wall
	BEQ.b Return01DB95
	JSR.w SMW_ChangeNormalSpriteDirection_Main
Return01DB95:
	RTS

; X displacement for the Grinder tiles (the one that doesn't follow line
; guides).
XDisp:
	db $F8,$08,$F8,$08

; [00 00 10 10] Y offset for the Grinder tiles (the one that doesn't follow
; line guides).
YDisp:
	db $00,$00,$10,$10

; [03 43 83 C3] OAM properties for the Grinder tiles (the one that doesn't
; follow line guides).
Prop:
	db $03,$43,$83,$C3

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank01
	PHX
	LDX.b #$03
CODE_01DBA8:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$02
	ORA.b #$6C
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_01DBA8
CODE_01DBD0:
	LDA.b #$03
	BRA.b SMW_NorSprXXX_LineGuidedSprites_Status08_CODE_01DC03
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0BA_TimedPlatform_Status01(Address)
namespace SMW_NorSpr0BA_TimedPlatform_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #$3F
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;\
	AND.b #$10			;| if on every 11 frames, make 1570 = 3F
	BNE.b ShortTimer		;/
	LDY.b #$FF
ShortTimer:
	TYA
	STA.w !RAM_SMW_NorSpr0BA_TimedPlatform_ClockTimer,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0BC_BowserStatue_Status01(Address)
namespace SMW_NorSpr0BC_BowserStatue_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	INC.w !RAM_SMW_NorSpr_FacingDirection,x	; The context on these sprites is unreal.
	JSR.w SMW_NorSpr04C_ExplodingBlock_Status01_Main	; I don't even know what Y is loaded with! :\
	STY.b !RAM_SMW_NorSpr0BC_BowserStatue_StatueType,x
	CPY.b #$02
	BNE.b Return018325
	LDA.b #$01			;\ set the sprite palette
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x	;/
Return018325:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status01(Address)
namespace SMW_NorSpr0BD_SlidingNakedBlueKoopa_Status01
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$04			;\ 04 to 1570
	BRA.b SMW_NorSpr09A_SumoBro_Status01_CODE_018379	;/
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0C0_SinkingLavaPlatform_Status01(Address)
namespace SMW_NorSpr0C0_SinkingLavaPlatform_Status01
%InsertMacroAtXPosition(<Address>)

Main:
if defined("Define_SMW_SA1")
	JSL.l Y_LOW_REMAP0
else
	INC.b !RAM_SMW_NorSpr_YPosLo,x	;\  Now all the INIT routines! Great...?
	INC.b !RAM_SMW_NorSpr_YPosLo,x	;/   < This will make the sprite float down
endif
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr0C0_SinkingLavaPlatform_Status01_Return, SMW_NorSpr0C6_Spotlight_Status01_Main)
endmacro

macro INLINEDATATABLE_RT05_SMW_EmptySpace(Address)
!SMW_UBytes = $05 : !SMW_JBytes = $02 : !SMW_E1Bytes = $05 : !SMW_E2Bytes = $00 : !SMASW_UBytes = $05 : !SMASW_EBytes = $00 : !SMW_ARCADEBytes = $05
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 05)
endmacro

macro INLINEDATATABLE_RT06_SMW_EmptySpace(Address)
!SMW_UBytes = $0C : !SMW_JBytes = $00 : !SMW_E1Bytes = $06 : !SMW_E2Bytes = $06 : !SMASW_UBytes = $0C : !SMASW_EBytes = $06 : !SMW_ARCADEBytes = $0C
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 06)
endmacro

macro INLINEDATATABLE_RT07_SMW_EmptySpace(Address)
!SMW_UBytes = $18 : !SMW_JBytes = $0D : !SMW_E1Bytes = $11 : !SMW_E2Bytes = $0A : !SMASW_UBytes = $18 : !SMASW_EBytes = $0A : !SMW_ARCADEBytes = $18
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 07)
endmacro

macro INLINEDATATABLE_RT08_SMW_EmptySpace(Address)
!SMW_UBytes = $41 : !SMW_JBytes = $3E : !SMW_E1Bytes = $41 : !SMW_E2Bytes = $41 : !SMASW_UBytes = $41 : !SMASW_EBytes = $41 : !SMW_ARCADEBytes = $41

	%SMW_FitOriginalFreespace(<Address>, !ROMID, 08)
endmacro
