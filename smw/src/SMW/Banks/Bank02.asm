;####################################################################
;# Bank02.asm -- sprite routines and level loading.
;#
;# 196 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank02Macros(StartBank, EndBank)
%BANK_START(<StartBank>)
ROUTINE_SMW_DropReservedItem:	%ROUTINE_SMW_DropReservedItem(NULLROM)						; $028000
ROUTINE_SMW_BobOmbExplosion:	%ROUTINE_SMW_BobOmbExplosion(NULLROM)						; $028072
ROUTINE_RT05_SMW_GameMode14_InLevel:	%ROUTINE_RT05_SMW_GameMode14_InLevel(NULLROM)					; $028178
ROUTINE_RT01_SMW_CheckPlayerPositionRelativeToSprite:	%ROUTINE_RT01_SMW_CheckPlayerPositionRelativeToSprite(NULLROM)			; $02848D
ROUTINE_RT01_SMW_CheckIfNormalSpriteOffScreen:	%ROUTINE_RT01_SMW_CheckIfNormalSpriteOffScreen(NULLROM)			; $02849F
ROUTINE_SMW_SpawnWaterSplash:	%ROUTINE_SMW_SpawnWaterSplash(NULLROM)						; $0284A6
ROUTINE_SMW_SpawnLavaSplash:	%ROUTINE_SMW_SpawnLavaSplash(NULLROM)						; $028510
ROUTINE_RT00_SMW_SpawnSparkles:	%ROUTINE_RT00_SMW_SpawnSparkles(NULLROM)					; $02858F
ROUTINE_RT01_SMW_NorSpr033_Podoboo_Status08:	%ROUTINE_RT01_SMW_NorSpr033_Podoboo_Status08(NULLROM)				; $0285DF
ROUTINE_SMW_GrabThrowBlockBlock:	%ROUTINE_SMW_GrabThrowBlockBlock(NULLROM)					; $02862F
ROUTINE_RT00_SMW_SpawnBrickPieces:	%ROUTINE_RT00_SMW_SpawnBrickPieces(NULLROM)					; $028663
ROUTINE_SMW_YoshiStompRoutine:	%ROUTINE_SMW_YoshiStompRoutine(NULLROM)					; $0286BF
ROUTINE_SMW_InitializeBlockPunchAttack:	%ROUTINE_SMW_InitializeBlockPunchAttack(NULLROM)				; $0286ED
ROUTINE_RT01_SMW_SpawnBounceSprite:	%ROUTINE_RT01_SMW_SpawnBounceSprite(NULLROM)					; $02873A
ROUTINE_RT01_SMW_SpawnBrickPieces:	%ROUTINE_RT01_SMW_SpawnBrickPieces(NULLROM)					; $028742
ROUTINE_RT00_SMW_SpawnBounceSprite:	%ROUTINE_RT00_SMW_SpawnBounceSprite(NULLROM)					; $028752
ROUTINE_SMW_SpawnSmokePuff:	%ROUTINE_SMW_SpawnSmokePuff(NULLROM)						; $028A44
ROUTINE_RT02_SMW_SpawnBounceSprite:	%ROUTINE_RT02_SMW_SpawnBounceSprite(NULLROM)					; $028A66
ROUTINE_RT06_SMW_GameMode14_InLevel:	%ROUTINE_RT06_SMW_GameMode14_InLevel(NULLROM)					; $028AA9
ROUTINE_RT00_SMW_ProcessMinorExtendedSprites:	%ROUTINE_RT00_SMW_ProcessMinorExtendedSprites(NULLROM)				; $028B67
DATATABLE_SMW_MinorExtendedSpriteOAMIndexes:	%DATATABLE_SMW_MinorExtendedSpriteOAMIndexes(NULLROM)				; $028B78
ROUTINE_RT01_SMW_MExtSpr01_BrickPiece:	%ROUTINE_RT01_SMW_MExtSpr01_BrickPiece(NULLROM)				; $028B84
ROUTINE_RT01_SMW_ProcessMinorExtendedSprites:	%ROUTINE_RT01_SMW_ProcessMinorExtendedSprites(NULLROM)				; $028B94
ROUTINE_RT01_SMW_NorSpr035_Yoshi_Status08:	%ROUTINE_RT01_SMW_NorSpr035_Yoshi_Status08(NULLROM)				; $028BB0
ROUTINE_SMW_MExtSpr0B_UnusedYoshiSmoke:	%ROUTINE_SMW_MExtSpr0B_UnusedYoshiSmoke(NULLROM)				; $028C0F
ROUTINE_SMW_MExtSpr0A_BooStream:	%ROUTINE_SMW_MExtSpr0A_BooStream(NULLROM)					; $028CB8
ROUTINE_SMW_MExtSpr07_WaterSplash:	%ROUTINE_SMW_MExtSpr07_WaterSplash(NULLROM)					; $028D42
ROUTINE_SMW_MExtSpr06_RipVanFishZ:	%ROUTINE_SMW_MExtSpr06_RipVanFishZ(NULLROM)					; $028DD7
ROUTINE_SMW_MExtSpr03_EggShell:	%ROUTINE_SMW_MExtSpr03_EggShell(NULLROM)					; $028E7A
ROUTINE_SMW_MExtSpr02_SmallStar:	%ROUTINE_SMW_MExtSpr02_SmallStar(NULLROM)					; $028ECC
ROUTINE_SMW_MExtSpr04_PodobooFire:	%ROUTINE_SMW_MExtSpr04_PodobooFire(NULLROM)					; $028F2B
ROUTINE_RT00_SMW_MExtSpr01_BrickPiece:	%ROUTINE_RT00_SMW_MExtSpr01_BrickPiece(NULLROM)				; $028F8B
ROUTINE_RT00_SMW_ProcessBounceAndSmokeSprites:	%ROUTINE_RT00_SMW_ProcessBounceAndSmokeSprites(NULLROM)			; $02902D
ROUTINE_SMW_BounceSpr07_SpinningTurnBlock:	%ROUTINE_SMW_BounceSpr07_SpinningTurnBlock(NULLROM)				; $029072
ROUTINE_SMW_BounceSpr01_TurnBlock:	%ROUTINE_SMW_BounceSpr01_TurnBlock(NULLROM)					; $0290CE
ROUTINE_SMW_SpawnMap16TileFromBounceSprite:	%ROUTINE_SMW_SpawnMap16TileFromBounceSprite(NULLROM)				; $02919D
ROUTINE_SMW_BounceSpriteGFXRt:	%ROUTINE_SMW_BounceSpriteGFXRt(NULLROM)					; $0291ED
ROUTINE_SMW_GetBounceSpriteLevelCollisionMap16ID:	%ROUTINE_SMW_GetBounceSpriteLevelCollisionMap16ID(NULLROM)			; $029265
ROUTINE_RT00_SMW_CheckForPlayerAttackToNormalSpriteCollision:	%ROUTINE_RT00_SMW_CheckForPlayerAttackToNormalSpriteCollision(NULLROM)		; $029392
ROUTINE_RT06_SMW_RunPlayerBlockCode:	%ROUTINE_RT06_SMW_RunPlayerBlockCode(NULLROM)					; $0294C1
ROUTINE_SMW_HandleCapeInteraction:	%ROUTINE_SMW_HandleCapeInteraction(NULLROM)					; $0294F5
ROUTINE_SMW_HandleCapeLevelCollision:	%ROUTINE_SMW_HandleCapeLevelCollision(NULLROM)					; $02950B
ROUTINE_SMW_HandleCapeToExtendedSpriteCollision:	%ROUTINE_SMW_HandleCapeToExtendedSpriteCollision(NULLROM)			; $029631
ROUTINE_RT01_SMW_CheckForPlayerAttackToNormalSpriteCollision:	%ROUTINE_RT01_SMW_CheckForPlayerAttackToNormalSpriteCollision(NULLROM)		; $029657
DATATABLE_SMW_SmokeSpriteOAMIndexes:	%DATATABLE_SMW_SmokeSpriteOAMIndexes(NULLROM)					; $0296B8
ROUTINE_RT01_SMW_ProcessBounceAndSmokeSprites:	%ROUTINE_RT01_SMW_ProcessBounceAndSmokeSprites(NULLROM)			; $0296C0
ROUTINE_SMW_SmokeSpr01_PuffOfSmoke:	%ROUTINE_SMW_SmokeSpr01_PuffOfSmoke(NULLROM)					; $0296D8
ROUTINE_SMW_SmokeSpr02_ContactEffect:	%ROUTINE_SMW_SmokeSpr02_ContactEffect(NULLROM)					; $029797
ROUTINE_SMW_SmokeSpr05_Glitter:	%ROUTINE_SMW_SmokeSpr05_Glitter(NULLROM)					; $0298C2
ROUTINE_SMW_SmokeSpr03_TurnAroundSmoke:	%ROUTINE_SMW_SmokeSpr03_TurnAroundSmoke(NULLROM)				; $029922
ROUTINE_RT00_SMW_ProcessSpinningCoinSprites:	%ROUTINE_RT00_SMW_ProcessSpinningCoinSprites(NULLROM)				; $0299D2
ROUTINE_SMW_ProcessExtendedSprites:	%ROUTINE_SMW_ProcessExtendedSprites(NULLROM)					; $029B0A
ROUTINE_SMW_ExtSpr0C_VolcanoLotusFire:	%ROUTINE_SMW_ExtSpr0C_VolcanoLotusFire(NULLROM)				; $029B51
ROUTINE_SMW_SpawnYoshiStompSmoke:	%ROUTINE_SMW_SpawnYoshiStompSmoke(NULLROM)					; $029BDE
ROUTINE_SMW_ExtSpr0F_SmokeTrail:	%ROUTINE_SMW_ExtSpr0F_SmokeTrail(NULLROM)					; $029C33
ROUTINE_SMW_ExtSpr10_SpinJumpStars:	%ROUTINE_SMW_ExtSpr10_SpinJumpStars(NULLROM)					; $029C83
ROUTINE_SMW_ExtSpr0A_CloudCoin:	%ROUTINE_SMW_ExtSpr0A_CloudCoin(NULLROM)					; $029CB5
ROUTINE_SMW_ExtSpr09_Unused:	%ROUTINE_SMW_ExtSpr09_Unused(NULLROM)						; $029D5E
ROUTINE_SMW_ExtSpr08_LauncherArm:	%ROUTINE_SMW_ExtSpr08_LauncherArm(NULLROM)					; $029E36
ROUTINE_SMW_ExtSpr07_LavaSplash:	%ROUTINE_SMW_ExtSpr07_LavaSplash(NULLROM)					; $029E82
ROUTINE_SMW_ExtSpr12_BreathBubble:	%ROUTINE_SMW_ExtSpr12_BreathBubble(NULLROM)					; $029EEA
ROUTINE_SMW_ExtSpr11_YoshiFireball:	%ROUTINE_SMW_ExtSpr11_YoshiFireball(NULLROM)					; $029F61
ROUTINE_SMW_ExtSpr05_MarioFireball:	%ROUTINE_SMW_ExtSpr05_MarioFireball(NULLROM)					; $029F99
ROUTINE_RT00_SMW_CheckForPlayerFireballToNormalSpriteCollision:	%ROUTINE_RT00_SMW_CheckForPlayerFireballToNormalSpriteCollision(NULLROM)	; $02A0AC
DATATABLE_SMW_ExtendedSpriteOAMIndexes:	%DATATABLE_SMW_ExtendedSpriteOAMIndexes(NULLROM)				; $02A153
ROUTINE_RT01_SMW_GenericExtendedSpriteGFXRt:	%ROUTINE_RT01_SMW_GenericExtendedSpriteGFXRt(NULLROM)				; $02A15B
ROUTINE_SMW_ExtSpr02_ReznorFireball:	%ROUTINE_SMW_ExtSpr02_ReznorFireball(NULLROM)					; $02A163
ROUTINE_RT00_SMW_GenericExtendedSpriteGFXRt:	%ROUTINE_RT00_SMW_GenericExtendedSpriteGFXRt(NULLROM)				; $02A1A4
ROUTINE_SMW_ExtSpr03_FlameRemnant:	%ROUTINE_SMW_ExtSpr03_FlameRemnant(NULLROM)					; $02A217
ROUTINE_SMW_ExtSpr06_ThrownBone:	%ROUTINE_SMW_ExtSpr06_ThrownBone(NULLROM)					; $02A254
ROUTINE_SMW_ExtSpr04_Hammer:	%ROUTINE_SMW_ExtSpr04_Hammer(NULLROM)						; $02A2DF
ROUTINE_SMW_ExtSpr01_SmokePuff:	%ROUTINE_SMW_ExtSpr01_SmokePuff(NULLROM)					; $02A344
ROUTINE_SMW_CheckForMarioToExtendedSpriteCollision:	%ROUTINE_SMW_CheckForMarioToExtendedSpriteCollision(NULLROM)			; $02A3F6
ROUTINE_SMW_GetExtendedSpriteClipping:	%ROUTINE_SMW_GetExtendedSpriteClipping(NULLROM)				; $02A4E9
ROUTINE_RT01_SMW_CheckForPlayerFireballToNormalSpriteCollision:	%ROUTINE_RT01_SMW_CheckForPlayerFireballToNormalSpriteCollision(NULLROM)	; $02A547
ROUTINE_SMW_HandleExtendedSpriteLevelCollision:	%ROUTINE_SMW_HandleExtendedSpriteLevelCollision(NULLROM)			; $02A56E
ROUTINE_RT01_SMW_LoadSublevel:	%ROUTINE_RT01_SMW_LoadSublevel(NULLROM)					; $02A751
ROUTINE_SMW_ParseLevelSpriteList:	%ROUTINE_SMW_ParseLevelSpriteList(NULLROM)					; $02A773
ROUTINE_SMW_FindFreeNormalSpriteSlot:	%ROUTINE_SMW_FindFreeNormalSpriteSlot(NULLROM)					; $02A9DE
ROUTINE_RT01_SMW_NorSpr0E5_LoadReappearingBoo:	%ROUTINE_RT01_SMW_NorSpr0E5_LoadReappearingBoo(NULLROM)			; $02AA0B
ROUTINE_SMW_NorSpr0E5_LoadDeathBatCeiling:	%ROUTINE_SMW_NorSpr0E5_LoadDeathBatCeiling(NULLROM)				; $02AA33
ROUTINE_SMW_NorSpr0E6_LoadCandleFlames:	%ROUTINE_SMW_NorSpr0E6_LoadCandleFlames(NULLROM)				; $02AA68
ROUTINE_RT00_SMW_NorSpr0E5_LoadReappearingBoo:	%ROUTINE_RT00_SMW_NorSpr0E5_LoadReappearingBoo(NULLROM)			; $02AA8D
ROUTINE_SMW_NorSpr0E1_LoadBooCeiling:	%ROUTINE_SMW_NorSpr0E1_LoadBooCeiling(NULLROM)					; $02AABD
ROUTINE_SMW_NorSprXXX_LoadBooRing:	%ROUTINE_SMW_NorSprXXX_LoadBooRing(NULLROM)					; $02AB11
ROUTINE_SMW_NorSprXXX_LoadShooter:	%ROUTINE_SMW_NorSprXXX_LoadShooter(NULLROM)					; $02AB78
ROUTINE_SMW_InitializeAllSpritesOnLevelLoad:	%ROUTINE_SMW_InitializeAllSpritesOnLevelLoad(NULLROM)				; $02ABF2
ROUTINE_SMW_LoadSpritesOnLevelLoad:	%ROUTINE_SMW_LoadSpritesOnLevelLoad(NULLROM)					; $02AC5C
ROUTINE_SMW_GivePoints:	%ROUTINE_SMW_GivePoints(NULLROM)						; $02ACE1
ROUTINE_SMW_CheckForAvailableScoreSpriteSlot:	%ROUTINE_SMW_CheckForAvailableScoreSpriteSlot(NULLROM)				; $02AD34
ROUTINE_SMW_ProcessScoreSprites:	%ROUTINE_SMW_ProcessScoreSprites(NULLROM)					; $02AD4C
ROUTINE_SMW_NorSpr0E0_Load3Platforms:	%ROUTINE_SMW_NorSpr0E0_Load3Platforms(NULLROM)					; $02AF2D
ROUTINE_SMW_NorSpr0DE_Load5Eeries:	%ROUTINE_SMW_NorSpr0DE_Load5Eeries(NULLROM)					; $02AF87
ROUTINE_SMW_ProcessGeneratorSprite:	%ROUTINE_SMW_ProcessGeneratorSprite(NULLROM)					; $02AFFE
ROUTINE_SMW_GenSpr08_TurnOffRespawningSprite:	%ROUTINE_SMW_GenSpr08_TurnOffRespawningSprite(NULLROM)				; $02B02B
ROUTINE_SMW_GenSpr0F_TurnOffGenerator:	%ROUTINE_SMW_GenSpr0F_TurnOffGenerator(NULLROM)				; $02B032
ROUTINE_SMW_GenSpr0E_GenerateFire:	%ROUTINE_SMW_GenSpr0E_GenerateFire(NULLROM)					; $02B036
ROUTINE_SMW_GenSpr0B_GenerateBullet:	%ROUTINE_SMW_GenSpr0B_GenerateBullet(NULLROM)					; $02B07C
ROUTINE_SMW_GenSpr0C_GenerateSurroundingBullets:	%ROUTINE_SMW_GenSpr0C_GenerateSurroundingBullets(NULLROM)			; $02B0C9
ROUTINE_SMW_GenSpr07_GenerateFish:	%ROUTINE_SMW_GenSpr07_GenerateFish(NULLROM)					; $02B153
ROUTINE_SMW_GenSpr09_GenerateSuperKoopa:	%ROUTINE_SMW_GenSpr09_GenerateSuperKoopa(NULLROM)				; $02B1B8
ROUTINE_SMW_GenSpr0A_GenerateBubbles:	%ROUTINE_SMW_GenSpr0A_GenerateBubbles(NULLROM)					; $02B207
ROUTINE_SMW_GenSprXX_GenerateDolphins:	%ROUTINE_SMW_GenSprXX_GenerateDolphins(NULLROM)				; $02B25E
ROUTINE_SMW_GenSpr01_GenerateEerie:	%ROUTINE_SMW_GenSpr01_GenerateEerie(NULLROM)					; $02B2D0
ROUTINE_SMW_GenSprXX_GenerateParachuteEnemies:	%ROUTINE_SMW_GenSprXX_GenerateParachuteEnemies(NULLROM)			; $02B31F
ROUTINE_SMW_ProcessShooterSprites:	%ROUTINE_SMW_ProcessShooterSprites(NULLROM)					; $02B387
ROUTINE_SMW_ShooterSpr02_TorpedoShooter:	%ROUTINE_SMW_ShooterSpr02_TorpedoShooter(NULLROM)				; $02B3B6
ROUTINE_SMW_ShooterSpr01_BulletBillShooter:	%ROUTINE_SMW_ShooterSpr01_BulletBillShooter(NULLROM)				; $02B466
ROUTINE_SMW_UpdateBounceSpritePosition:	%ROUTINE_SMW_UpdateBounceSpritePosition(NULLROM)				; $02B51A
ROUTINE_SMW_UpdateExtendedSpritePosition:	%ROUTINE_SMW_UpdateExtendedSpritePosition(NULLROM)				; $02B554
ROUTINE_RT01_SMW_ProcessSpinningCoinSprites:	%ROUTINE_RT01_SMW_ProcessSpinningCoinSprites(NULLROM)				; $02B58E
ROUTINE_SMW_UpdateMinorExtendedSpritePosition:	%ROUTINE_SMW_UpdateMinorExtendedSpritePosition(NULLROM)			; $02B5BC
INLINEDATATABLE_RT09_SMW_EmptySpace:	%INLINEDATATABLE_RT09_SMW_EmptySpace(NULLROM)					; $02B5EC
ROUTINE_RT01_SMW_NorSpr070_Pokey_Status08:	%ROUTINE_RT01_SMW_NorSpr070_Pokey_Status08(NULLROM)				; $02B630
ROUTINE_RT01_SMW_NorSpr044_TorpedoTed_Status08:	%ROUTINE_RT01_SMW_NorSpr044_TorpedoTed_Status08(NULLROM)			; $02B882
ROUTINE_SMW_UnusedGenTileFromSpr:	%ROUTINE_SMW_UnusedGenTileFromSpr(NULLROM)					; $02B9A4
ROUTINE_RT02_SMW_CheckForPlayerToNormalSpriteCollision:	%ROUTINE_RT02_SMW_CheckForPlayerToNormalSpriteCollision(NULLROM)		; $02B9BD
ROUTINE_SMW_CheckForBerryTileCollisionWithYoshiTongue:	%ROUTINE_SMW_CheckForBerryTileCollisionWithYoshiTongue(NULLROM)		; $02B9FA
ROUTINE_RT02_SMW_NorSpr035_Yoshi_Status08:	%ROUTINE_RT02_SMW_NorSpr035_Yoshi_Status08(NULLROM)				; $02BB0B
ROUTINE_RT01_SMW_NorSprXXX_Dolphins_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_Dolphins_Status08(NULLROM)				; $02BB88
ROUTINE_RT01_SMW_NorSprXXX_WallFollowers_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_WallFollowers_Status08(NULLROM)			; $02BC8F
ROUTINE_RT01_SMW_NorSpr03D_RipVanFish_Status08:	%ROUTINE_RT01_SMW_NorSpr03D_RipVanFish_Status08(NULLROM)			; $02BFC8
ROUTINE_SMW_SpawnMusicNoteOrZ:	%ROUTINE_SMW_SpawnMusicNoteOrZ(NULLROM)					; $02C0CF
ROUTINE_RT02_SMW_NorSpr03D_RipVanFish_Status08:	%ROUTINE_RT02_SMW_NorSpr03D_RipVanFish_Status08(NULLROM)			; $02C126
ROUTINE_RT01_SMW_NorSpr091_CharginChuck_Status08:	%ROUTINE_RT01_SMW_NorSpr091_CharginChuck_Status08(NULLROM)			; $02C132
ROUTINE_RT01_SMW_NorSpr088_WingedCage_Status01:	%ROUTINE_RT01_SMW_NorSpr088_WingedCage_Status01(NULLROM)			; $02CBFD
ROUTINE_RT01_SMW_NorSpr088_WingedCage_Status08:	%ROUTINE_RT01_SMW_NorSpr088_WingedCage_Status08(NULLROM)			; $02CBFE
ROUTINE_RT01_SMW_NorSpr060_FlatPalaceSwitch_Status08:	%ROUTINE_RT01_SMW_NorSpr060_FlatPalaceSwitch_Status08(NULLROM)			; $02CD2D
ROUTINE_RT01_SMW_NorSprXXX_WallSpringboard_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_WallSpringboard_Status08(NULLROM)			; $02CDC5
ROUTINE_RT01_SMW_SubOffscreen:	%ROUTINE_RT01_SMW_SubOffscreen(NULLROM)					; $02D003
ROUTINE_RT02_SMW_CheckIfNormalSpriteOffScreen:	%ROUTINE_RT02_SMW_CheckIfNormalSpriteOffScreen(NULLROM)			; $02D0C9
ROUTINE_RT03_SMW_NorSpr035_Yoshi_Status08:	%ROUTINE_RT03_SMW_NorSpr035_Yoshi_Status08(NULLROM)				; $02D0D0
ROUTINE_SMW_HandleHeldPBalloonAndInLakituCloudMovement:	%ROUTINE_SMW_HandleHeldPBalloonAndInLakituCloudMovement(NULLROM)		; $02D210
ROUTINE_SMW_UpdateNormalSpritePositionBank02:	%ROUTINE_SMW_UpdateNormalSpritePositionBank02(NULLROM)				; $02D288
ROUTINE_SMW_UnusedPrepareToAimAtPlayerRoutine:	%ROUTINE_SMW_UnusedPrepareToAimAtPlayerRoutine(NULLROM)			; $02D2C7
ROUTINE_RT01_SMW_AimTowardsPlayer:	%ROUTINE_RT01_SMW_AimTowardsPlayer(NULLROM)					; $02D2FB
ROUTINE_RT01_SMW_GetDrawInfo:	%ROUTINE_RT01_SMW_GetDrawInfo(NULLROM)						; $02D374
ROUTINE_RT01_SMW_NorSpr089_Layer3Smasher_Status08:	%ROUTINE_RT01_SMW_NorSpr089_Layer3Smasher_Status08(NULLROM)			; $02D3EA
ROUTINE_RT02_SMW_CheckPlayerPositionRelativeToSprite:	%ROUTINE_RT02_SMW_CheckPlayerPositionRelativeToSprite(NULLROM)			; $02D4F2
INLINEDATATABLE_RT10_SMW_EmptySpace:	%INLINEDATATABLE_RT10_SMW_EmptySpace(NULLROM)					; $02D51E
ROUTINE_RT02_SMW_NorSpr086_Wiggler_Status08:	%ROUTINE_RT02_SMW_NorSpr086_Wiggler_Status08(NULLROM)				; $02D580
ROUTINE_RT01_SMW_NorSpr09F_BanzaiBill_Status08:	%ROUTINE_RT01_SMW_NorSpr09F_BanzaiBill_Status08(NULLROM)			; $02D587
ROUTINE_RT02_SMW_NorSpr0A3_GreyChainedPlatform_Status08:	%ROUTINE_RT02_SMW_NorSpr0A3_GreyChainedPlatform_Status08(NULLROM)		; $02D62A
ROUTINE_RT01_SMW_NorSpr09D_BubbleWithSprite_Status08:	%ROUTINE_RT01_SMW_NorSpr09D_BubbleWithSprite_Status08(NULLROM)			; $02D8A1
ROUTINE_RT01_SMW_NorSpr09B_HammerBro_Status08:	%ROUTINE_RT01_SMW_NorSpr09B_HammerBro_Status08(NULLROM)			; $02DA52
ROUTINE_RT01_SMW_NorSpr09C_HammerBroPlatform_Status08:	%ROUTINE_RT01_SMW_NorSpr09C_HammerBroPlatform_Status08(NULLROM)		; $02DB4C
ROUTINE_RT01_SMW_NorSpr09A_SumoBro_Status08:	%ROUTINE_RT01_SMW_NorSpr09A_SumoBro_Status08(NULLROM)				; $02DCAF
ROUTINE_RT01_SMW_NorSpr02B_SumoLightning_Status08:	%ROUTINE_RT01_SMW_NorSpr02B_SumoLightning_Status08(NULLROM)			; $02DEA8
ROUTINE_RT01_SMW_NorSpr099_VolcanoLotus_Status08:	%ROUTINE_RT01_SMW_NorSpr099_VolcanoLotus_Status08(NULLROM)			; $02DF8B
ROUTINE_RT01_SMW_NorSprXXX_JumpingPiranhaPlant_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_JumpingPiranhaPlant_Status08(NULLROM)		; $02E0C5
ROUTINE_RT01_SMW_NorSpr045_DirectionalCoins_Status08:	%ROUTINE_RT01_SMW_NorSpr045_DirectionalCoins_Status08(NULLROM)			; $02E1F9
ROUTINE_RT01_SMW_NorSpr090_GreenGasBubble_Status08:	%ROUTINE_RT01_SMW_NorSpr090_GreenGasBubble_Status08(NULLROM)			; $02E303
ROUTINE_RT01_SMW_NorSpr04C_ExplodingBlock_Status08:	%ROUTINE_RT01_SMW_NorSpr04C_ExplodingBlock_Status08(NULLROM)			; $02E417
ROUTINE_SMW_ShatterExplodingBlock:	%ROUTINE_SMW_ShatterExplodingBlock(NULLROM)					; $02E463
ROUTINE_RT01_SMW_NorSpr08F_ScalePlatform_Status08:	%ROUTINE_RT01_SMW_NorSpr08F_ScalePlatform_Status08(NULLROM)			; $02E495
ROUTINE_RT01_SMW_NorSpr052_MovingLedgeHole_Status08:	%ROUTINE_RT01_SMW_NorSpr052_MovingLedgeHole_Status08(NULLROM)			; $02E5B4
ROUTINE_RT01_SMW_NorSpr01E_Lakitu_Status08:	%ROUTINE_RT01_SMW_NorSpr01E_Lakitu_Status08(NULLROM)				; $02E672
ROUTINE_RT01_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status08:	%ROUTINE_RT01_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status08(NULLROM)	; $02E71F
ROUTINE_RT01_SMW_NorSpr048_DigginChuckRock_Status08:	%ROUTINE_RT01_SMW_NorSpr048_DigginChuckRock_Status08(NULLROM)			; $02E7B5
ROUTINE_RT01_SMW_NorSpr049_ShiftingPipe_Status08:	%ROUTINE_RT01_SMW_NorSpr049_ShiftingPipe_Status08(NULLROM)			; $02E82D
ROUTINE_RT01_SMW_NorSpr04B_PipeLakitu_Status08:	%ROUTINE_RT01_SMW_NorSpr04B_PipeLakitu_Status08(NULLROM)			; $02E935
ROUTINE_SMW_SetBabyYoshiDynamicGraphicsPointer:	%ROUTINE_SMW_SetBabyYoshiDynamicGraphicsPointer(NULLROM)			; $02EA25
ROUTINE_RT00_SMW_CheckIfBabyYoshiCanEatNormalSprite:	%ROUTINE_RT00_SMW_CheckIfBabyYoshiCanEatNormalSprite(NULLROM)			; $02EA4E
ROUTINE_RT01_SMW_NorSpr08E_WarpHole_Status08:	%ROUTINE_RT01_SMW_NorSpr08E_WarpHole_Status08(NULLROM)				; $02EAD2
ROUTINE_RT03_SMW_CheckForPlayerToNormalSpriteCollision:	%ROUTINE_RT03_SMW_CheckForPlayerToNormalSpriteCollision(NULLROM)		; $02EAF2
ROUTINE_RT01_SMW_NorSprXXX_SuperKoopas_Status08:	%ROUTINE_RT01_SMW_NorSprXXX_SuperKoopas_Status08(NULLROM)			; $02EB27
ROUTINE_RT01_SMW_NorSpr061_SkullRaft_Status01:	%ROUTINE_RT01_SMW_NorSpr061_SkullRaft_Status01(NULLROM)			; $02ED7F
ROUTINE_RT01_SMW_NorSpr061_SkullRaft_Status08:	%ROUTINE_RT01_SMW_NorSpr061_SkullRaft_Status08(NULLROM)			; $02EDD0
ROUTINE_RT01_SMW_NorSpr06A_CoinGameCloud_Status08:	%ROUTINE_RT01_SMW_NorSpr06A_CoinGameCloud_Status08(NULLROM)			; $02EEA9
ROUTINE_RT01_SMW_NorSpr086_Wiggler_Status01:	%ROUTINE_RT01_SMW_NorSpr086_Wiggler_Status01(NULLROM)				; $02EFEA
ROUTINE_RT01_SMW_NorSpr086_Wiggler_Status08:	%ROUTINE_RT01_SMW_NorSpr086_Wiggler_Status08(NULLROM)				; $02F029
ROUTINE_RT01_SMW_NorSpr08A_Bird_Status08:	%ROUTINE_RT01_SMW_NorSpr08A_Bird_Status08(NULLROM)				; $02F30F
ROUTINE_RT01_SMW_NorSpr08B_FireplaceSmoke_Status08:	%ROUTINE_RT01_SMW_NorSpr08B_FireplaceSmoke_Status08(NULLROM)			; $02F42C
ROUTINE_RT01_SMW_NorSpr08C_SideExitAndFireplace_Status08:	%ROUTINE_RT01_SMW_NorSpr08C_SideExitAndFireplace_Status08(NULLROM)		; $02F4CD
ROUTINE_RT00_SMW_DrawGhostHouseEntranceDoor:	%ROUTINE_RT00_SMW_DrawGhostHouseEntranceDoor(NULLROM)				; $02F57C
ROUTINE_RT00_SMW_DrawBigCastleGate:	%ROUTINE_RT00_SMW_DrawBigCastleGate(NULLROM)					; $02F584
ROUTINE_RT00_SMW_DrawNoYoshiSign:	%ROUTINE_RT00_SMW_DrawNoYoshiSign(NULLROM)					; $02F58C
ROUTINE_RT01_SMW_NorSpr08D_GhostHouseDoor_Status08:	%ROUTINE_RT01_SMW_NorSpr08D_GhostHouseDoor_Status08(NULLROM)			; $02F594
ROUTINE_RT01_SMW_DrawNoYoshiSign:	%ROUTINE_RT01_SMW_DrawNoYoshiSign(NULLROM)					; $02F619
ROUTINE_RT01_SMW_DrawBigCastleGate:	%ROUTINE_RT01_SMW_DrawBigCastleGate(NULLROM)					; $02F66E
ROUTINE_RT01_SMW_DrawGhostHouseEntranceDoor:	%ROUTINE_RT01_SMW_DrawGhostHouseEntranceDoor(NULLROM)				; $02F6F1
ROUTINE_SMW_ProcessClusterSprites:	%ROUTINE_SMW_ProcessClusterSprites(NULLROM)					; $02F808
ROUTINE_SMW_ClusterSpr07_ReappearingBoo:	%ROUTINE_SMW_ClusterSpr07_ReappearingBoo(NULLROM)				; $02F837
ROUTINE_SMW_ClusterSpr06_SumoBroFlame:	%ROUTINE_SMW_ClusterSpr06_SumoBroFlame(NULLROM)				; $02F8FC
ROUTINE_SMW_ClusterSpr05_CandleFlame:	%ROUTINE_SMW_ClusterSpr05_CandleFlame(NULLROM)					; $02FA02
ROUTINE_SMW_ClusterSpr04_BooRing:	%ROUTINE_SMW_ClusterSpr04_BooRing(NULLROM)					; $02FA84
ROUTINE_SMW_ClusterSpr03_BooCeiling:	%ROUTINE_SMW_ClusterSpr03_BooCeiling(NULLROM)					; $02FBBB
ROUTINE_RT00_SMW_ClusterSpr01_1up:	%ROUTINE_RT00_SMW_ClusterSpr01_1up(NULLROM)					; $02FDBC
ROUTINE_SMW_CheckForPlayerToEnemyClusterSpriteCollision:	%ROUTINE_SMW_CheckForPlayerToEnemyClusterSpriteCollision(NULLROM)		; $02FE71
ROUTINE_RT02_SMW_SubOffscreen:	%ROUTINE_RT02_SMW_SubOffscreen(NULLROM)					; $02FEC5
DATATABLE_SMW_ClusterSpriteOAMIndexes:	%DATATABLE_SMW_ClusterSpriteOAMIndexes(NULLROM)				; $02FF50
ROUTINE_RT01_SMW_ClusterSpr01_1up:	%ROUTINE_RT01_SMW_ClusterSpr01_1up(NULLROM)					; $02FF64
ROUTINE_SMW_UpdateClusterSpritePosition:	%ROUTINE_SMW_UpdateClusterSpritePosition(NULLROM)				; $02FF98
ROUTINE_RT01_SMW_SetNormalSpriteYSpeedBasedOnSlope:	%ROUTINE_RT01_SMW_SetNormalSpriteYSpeedBasedOnSlope(NULLROM)			; $02FFD1
INLINEDATATABLE_RT11_SMW_EmptySpace:	%INLINEDATATABLE_RT11_SMW_EmptySpace(NULLROM)					; $02FFE2
%BANK_END(<EndBank>)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DropReservedItem(Address)
namespace SMW_DropReservedItem
%InsertMacroAtXPosition(<Address>)

UNK_028000:
	db $80,$40,$20,$10,$08,$04,$02,$01

; Drop Item From Box Subroutine. JSL to it to make the current item fall
; from the box. Used when SELECT is pressed or if the player takes damage
; without dying. Change $028008 from DA (PHX) to 6B (RTL) to disable the
; item box drop routine. $028013 is Item dropping from itembox sound effect,
; written to $7E1DFC. Default value is [0C]. $028042 is Sprite status
; ($14C8) to drop items from the item box as (default is #$08 - normal
; routine). $028052 is the fixed X position of dropped item from item box
; (default is #$78). $028060 is the fixed Y position of dropped item from
; item box (default is #$20).
Main:
	PHX				; Preserve the value of X
	LDA.w !RAM_SMW_Player_CurrentItemBox	; \ If item box is empty, then skip
	BEQ.b DropRiEnd			; / ahead to end of routine.
	STZ.w !RAM_SMW_Player_CurrentItemBox	; Item box = empty
	PHA				; Push A = reserved item
	LDA.b #!Define_SMW_Sound1DFC_DropItemInReserve1	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDX.b #!Define_SMW_MaxNormalSpriteSlot	; X = 11
DropRiFindSlot:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Branch if sprite slot X is empty
	BEQ.b DropRiHaveSlot		; /
	DEX				; X = X - 1
	BPL.b DropRiFindSlot		; Loop back unless X < 0
	DEC.w !RAM_SMW_NorSpr_SlotToOverwriteWhenSlotsFull	; \ Swap the value of $7E1861
	BPL.b ADDR_02802B		;  |$00 becomes $01
	LDA.b #!Define_SMW_StockMaxNormalSpriteSlot-$0A	;  |$01 becomes $00
	STA.w !RAM_SMW_NorSpr_SlotToOverwriteWhenSlotsFull	; /
ADDR_02802B:
	LDA.w !RAM_SMW_NorSpr_SlotToOverwriteWhenSlotsFull	; \ X = RAM $7E1861 + 10
	CLC				;  |Select sprite 10 or sprite 11
	ADC.b #!Define_SMW_MaxNormalSpriteSlot-$01	;  |
	TAX				; /
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ If this sprite was a P-balloon
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon	;  |(number $7D) and Mario carries the
	BNE.b DropRiHaveSlot		;  |balloon (action $0B),
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;  |
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	;  |then RAM $7E13F3 = zero.
	BNE.b DropRiHaveSlot		;  |($7E13F3 might control the pose of
	STZ.w !RAM_SMW_Timer_InflateFromPBalloon	; /  Mario while using the balloon?)
DropRiHaveSlot:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	PLA				; Restore A = reserved item
	CLC				; \ Sprite number = reserved item + $73
if defined("Define_SMW_SA1")
	; SA-1 Pack: Dropping an item from an item box needs fixing.
	JSL.l DROP_ITEM_SET
else
	ADC.b #!Define_SMW_SpriteID_NorSpr074_Mushroom-$01	;  |
	STA.b !RAM_SMW_NorSpr_SpriteID,x	; /
endif
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Set up the new sprite
	LDA.b #$78			; \  Set the X-position of the falling
	CLC				;  | item to 120 pixels from the left
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;  | edge of the screen.
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;  | X_pos of sprite =
	ADC.b #$00			;  |
	STA.w !RAM_SMW_NorSpr_XPosHi,x	; /
	LDA.b #$20			; \  Set the Y-position of the falling
	CLC				;  | sprite to 32 pixels from the top
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;  | edge of the screen.
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;  | Y_pos of sprite =
if defined("Define_SMW_SA1")
	JSL.l DROP_ITEM_RESTORE
	NOP
else
	ADC.b #$00			;  |
	STA.w !RAM_SMW_NorSpr_YPosHi,x	; /
endif
	INC.w !RAM_SMW_NorSpr_Table7E1534,x	; Tell sprite to blink and fall
DropRiEnd:
	PLX				; Restore the value of X
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UpdateNormalSpritePositionBank02(Address)
namespace SMW_UpdateNormalSpritePositionBank02
%InsertMacroAtXPosition(<Address>)

X:
if defined("Define_SMW_SA1")
	JSL.l SubSprXPosNoGrvty
	RTS
else
	TXA				; \ Adjust index so we use X values rather than Y
	CLC
	ADC.b #!Define_SMW_MaxNormalSpriteSlot+$01
	TAX
endif
	JSR.w Y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = sprite index
	RTS

Y:
;$02D294
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	; \ $14EC or $14F8 += 16 * speed
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_NorSpr_SubYPos,x
	STA.w !RAM_SMW_NorSpr_SubYPos,x
	PHP
	PHP
	LDY.b #$00
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	; \ Amount to move sprite = speed / 16
	LSR
	LSR
	LSR
	LSR
	CMP.b #$08			; \ If speed was negative...
	BCC.b +
	ORA.b #$F0			; | ...set high bits
	DEY
+:
	PLP
	PHA				; \ Add to position
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	TYA
	ADC.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	PLP
	ADC.b #$00
	STA.w !RAM_SMW_Sprites_PositionDisp	; $1491 = amount sprite was moved
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UpdateExtendedSpritePosition(Address)
namespace SMW_UpdateExtendedSpritePosition
%InsertMacroAtXPosition(<Address>)

; The subroutine that updates an extended sprite's X position (without
; gravity).
X:
	TXA
	CLC
	ADC.b #!Define_SMW_MaxExtendedSpriteSlot+$01
	TAX
	JSR.w Y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

Y:
;$02B560
	; The subroutine that updates an extended sprite's Y position (without
	; gravity).
	LDA.w !RAM_SMW_ExtSpr_YSpeed,x
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_ExtSpr_SubYPos,x
	STA.w !RAM_SMW_ExtSpr_SubYPos,x
	PHP
	LDY.b #$00
	LDA.w !RAM_SMW_ExtSpr_YSpeed,x
	LSR
	LSR
	LSR
	LSR
	CMP.b #$08
	BCC.b +
	ORA.b #$F0
	DEY
+:
	PLP
	ADC.w !RAM_SMW_ExtSpr_YPosLo,x
	STA.w !RAM_SMW_ExtSpr_YPosLo,x
	TYA
	ADC.w !RAM_SMW_ExtSpr_YPosHi,x
	STA.w !RAM_SMW_ExtSpr_YPosHi,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UpdateBounceSpritePosition(Address)
namespace SMW_UpdateBounceSpritePosition
%InsertMacroAtXPosition(<Address>)

; Updates a bounce sprite's Y position without gravity (actually just
; changes the sprite index and JSRs to $02B526).
X:
	TXA
	CLC
	ADC.b #!Define_SMW_MaxBounceSpriteSlot+$01
	TAX
	JSR.w Y
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	RTS

Y:
;$02B526
	; Updates a bounce sprite's X position without gravity.
	LDA.w !RAM_SMW_BounceSpr_YSpeed,x
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_BounceSpr_SubYPos,x
	STA.w !RAM_SMW_BounceSpr_SubYPos,x
	PHP
	LDA.w !RAM_SMW_BounceSpr_YSpeed,x
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
	ADC.w !RAM_SMW_BounceSpr_YPosLo,x
	STA.w !RAM_SMW_BounceSpr_YPosLo,x
	TYA
	ADC.w !RAM_SMW_BounceSpr_YPosHi,x
	STA.w !RAM_SMW_BounceSpr_YPosHi,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UpdateMinorExtendedSpritePosition(Address)
namespace SMW_UpdateMinorExtendedSpritePosition
%InsertMacroAtXPosition(<Address>)

; The X speed subroutine for minor extended sprites. Actually just adds 12
; to the sprite index and JSRs to the Y speed subroutine, just like the
; equivalent subroutine for normal sprites.
X:
	TXA
	CLC
	ADC.b #!Define_SMW_MaxMinorExtendedSpriteSlot+$01
	TAX
	JSR.w Y
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite	;>And restore it
	RTS

Y:
;$02B5C8
	; The Y speed subroutine for minor extended sprites.
	LDA.w !RAM_SMW_MExtSpr_YSpeed,x
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_MExtSpr_SubYPos,x
	STA.w !RAM_SMW_MExtSpr_SubYPos,x
	PHP
	LDA.w !RAM_SMW_MExtSpr_YSpeed,x
	LSR
	LSR
	LSR
	LSR
	CMP.b #$08
	BCC.b +
	ORA.b #$F0
+:
	PLP
	ADC.w !RAM_SMW_MExtSpr_YPosLo,x
	STA.w !RAM_SMW_MExtSpr_YPosLo,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UpdateClusterSpritePosition(Address)
namespace SMW_UpdateClusterSpritePosition
%InsertMacroAtXPosition(<Address>)

; Update cluster sprite X position without gravity subroutine.
X:
	PHX
	TXA
	CLC
	ADC.b #!Define_SMW_MaxClusterSpriteSlot+$01
	TAX
	JSR.w Y
	PLX
	RTS

Y:
;$02FFA3
	; Update cluster sprite Y position without gravity subroutine.
	LDA.w !RAM_SMW_ClusterSpr_Table7E1E52,x
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_ClusterSpr_Table7E1E7A,x
	STA.w !RAM_SMW_ClusterSpr_Table7E1E7A,x
	PHP
	LDA.w !RAM_SMW_ClusterSpr_Table7E1E52,x
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
	ADC.w !RAM_SMW_ClusterSpr_YPosLo,x
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	TYA
	ADC.w !RAM_SMW_ClusterSpr_YPosHi,x
	STA.w !RAM_SMW_ClusterSpr_YPosHi,x
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_GetDrawInfo(Address)
namespace SMW_GetDrawInfo
%InsertMacroAtXPosition(<Address>)

DATA_02D374:									;\ Optimization: Same deal as the Bank 01 GetDrawInfo.
	db $0C,$1C								;|
										;|
DATA_02D376:									;|
	db $01,$02								;/

Bank02:
	STZ.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	STZ.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BEQ.b CODE_02D38C
	INC.w !RAM_SMW_NorSpr_XOffscreenFlag,x
CODE_02D38C:
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
	BNE.b CODE_02D3E7
	LDY.b #$00								;\ Optimization: Same deal as the Bank 01 GetDrawInfo.
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x				;| Glitch: This !RAM_SMW_NorSpr_PropertyBits1662 should have been !RAM_SMW_NorSpr_PropertyBits190F
	AND.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping20			;| This will cause some bank 02 sprites to think they're offscreen vertically when they're not.
	BEQ.b CODE_02D3B2							;|
	INY									;|
CODE_02D3B2:									;|
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;|
	CLC									;|
	ADC.w DATA_02D374,y							;|
	PHP									;|
	CMP.b !RAM_SMW_Mirror_CurrentLayer1YPosLo				;|
	ROL.b !RAM_SMW_Misc_ScratchRAM00					;|
	PLP									;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x						;|
	ADC.b #$00								;|
	LSR.b !RAM_SMW_Misc_ScratchRAM00					;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi				;|
	BEQ.b CODE_02D3D2							;|
	LDA.w !RAM_SMW_NorSpr_YOffscreenFlag,x					;|
	ORA.w DATA_02D376,y							;|
	STA.w !RAM_SMW_NorSpr_YOffscreenFlag,x					;|
CODE_02D3D2:									;|
	DEY									;|
	BPL.b CODE_02D3B2							;/
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

CODE_02D3E7:
	PLA
	PLA
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_ProcessClusterSprites(Address)
namespace SMW_ProcessClusterSprites
%InsertMacroAtXPosition(<Address>)

Main:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDX.b #!Define_SMW_MaxClusterSpriteSlot
CODE_02F812:
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
	LDA.w !RAM_SMW_ClusterSpr_SpriteID,x
	BEQ.b CODE_02F81D
	JSR.w CODE_02F821
CODE_02F81D:
	DEX
	BPL.b CODE_02F812

Return02F820:
	RTS

CODE_02F821:
if !SMW_CustomSprites_ClusterWanted == !TRUE
	; The same four bytes as the trampoline call, only where the rows
	; name a custom cluster sprite. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Cluster
else
	JSL.l SMW_ExecutePtr_Absolute
endif

ClusterSpritePtrs:
base $000000
; 16-bit pointers to cluster sprite MAIN routines.
.ClusterSpr00_Unused:		dw SMW_ClusterSpr00_Unused_Main
.ClusterSpr01_1up:		dw SMW_ClusterSpr01_1up_Main
.ClusterSpr02_Unused:		dw SMW_ClusterSpr02_Unused_Main			; Crash: Loading cluster sprite 02 will make the CPU jump to !RAM_SMW_Misc_ScratchRAM00 and do unpredictable things.
.ClusterSpr03_BooCeiling:	dw SMW_ClusterSpr03_BooCeiling_Main
.ClusterSpr04_BooRing:		dw SMW_ClusterSpr04_BooRing_Main
.ClusterSpr05_CandleFlame:	dw SMW_ClusterSpr05_CandleFlame_Main
.ClusterSpr06_SumoBroFlame:	dw SMW_ClusterSpr06_SumoBroFlame_Main
.ClusterSpr07_ReappearingBoo:	dw SMW_ClusterSpr07_ReappearingBoo_Main
.ClusterSpr08_DeathBatCeiling:	dw SMW_ClusterSpr08_DeathBatCeiling_Main
base off
namespace off
	%SetDuplicateOrNullPointer(SMW_ProcessClusterSprites_Return02F820, SMW_ClusterSpr00_Unused_Main)

	%SetDuplicateOrNullPointer($020000, SMW_ClusterSpr02_Unused_Main)
endmacro

macro ROUTINE_RT05_SMW_GameMode14_InLevel(Address)
namespace SMW_GameMode14_InLevel
%InsertMacroAtXPosition(<Address>)

DATA_028178:
	db $F8,$38,$78,$B8,$00,$10,$20,$D0
	db $E0,$10,$40,$80,$C0,$10,$10,$20
	db $B0,$20,$50,$60,$C0,$F0,$80,$B0
	db $20,$60,$A0,$E0,$70,$F0,$70,$B0
	db $F0,$10,$20,$50,$60,$90,$A0,$D0
	db $E0,$10,$20,$50,$60,$90,$A0,$D0
	db $E0,$10,$20,$50,$60,$90,$A0,$D0
	db $E0,$50,$60,$C0,$D0,$30,$40,$70
	db $80,$B0,$C0,$30,$40,$70,$80,$B0
	db $C0,$40,$50,$80,$90,$C8,$D8,$30
	db $40,$A0,$B0,$58,$68,$B0,$C0

DATA_0281CF:
	db $70,$70,$70,$70,$20,$20,$20,$20
	db $20,$30,$30,$30,$30,$70,$80,$80
	db $80,$90,$90,$90,$A0,$50,$60,$60
	db $70,$70,$70,$70,$60,$60,$70,$70
	db $70,$40,$40,$40,$40,$40,$40,$40
	db $40,$50,$50,$50,$50,$50,$50,$50
	db $50,$60,$60,$60,$60,$60,$60,$60
	db $60,$30,$30,$30,$30,$48,$48,$48
	db $48,$48,$48,$58,$58,$58,$58,$58
	db $58,$70,$70,$78,$78,$70,$70,$80
	db $80,$88,$88,$A0,$A0,$A0,$A0

; Ludwig BG Tiles
DATA_028226:
	db $E8,$E8,$E8,$E8,$E4,$E4,$E4,$E4
	db $E4,$E4,$E4,$E4,$E4,$E4,$E4,$E4
	db $E4,$E4,$E4,$E4,$E4,$E4,$E4,$E4
	db $E4,$E4,$E4,$E4,$EE,$EE,$EE,$EE
	db $EE,$C0,$C2,$C0,$C2,$C0,$C2,$C0
	db $C2,$E0,$E2,$E0,$E2,$E0,$E2,$E0
	db $E2,$C4,$A4,$C4,$A4,$C4,$A4,$C4
	db $A4,$CC,$CE,$CC,$CE,$C8,$CA,$C8
	db $CA,$C8,$CA,$CA,$C8,$CA,$C8,$CA
	db $C8,$CC,$CE,$CC,$CE,$CC,$CE,$CC
	db $CE,$CC,$CE,$CC,$CE,$CC,$CE

CODE_02827D:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w !RAM_SMW_Misc_MortonRoyLudwigBackgroundXOffset
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	LSR
	ROR.w !RAM_SMW_Misc_MortonRoyLudwigBackgroundXOffset
	PHA
	LDA.w !RAM_SMW_Misc_MortonRoyLudwigBackgroundXOffset
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM06
	PLA
	LSR
	ROR.w !RAM_SMW_Misc_MortonRoyLudwigBackgroundXOffset
	LDA.w !RAM_SMW_Misc_MortonRoyLudwigBackgroundXOffset
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_Misc_MortonRoyLudwigBackgroundXOffset
	REP.b #$10			; XY->16
	LDY.w #$0164
	LDA.b #$66
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b #$F0
CODE_0282AF:
	STA.w SMW_OAMBuffer[$03].YDisp,y
	INY
	INY
	INY
	INY
	CPY.w #$018C
	BCC.b CODE_0282AF
	LDX.w #$0000
	STX.b !RAM_SMW_Misc_ScratchRAM0C
	LDX.w #$0038
	LDY.w #$00E0
	LDA.w !RAM_SMW_Sprites_BackgroundToUseInKoopaKidBattle
	CMP.b #$01
	BNE.b CODE_0282D8
	LDX.w #$0039
	STX.b !RAM_SMW_Misc_ScratchRAM0C
	LDX.w #$001D
	LDY.w #$00FC
CODE_0282D8:
	STX.b !RAM_SMW_Misc_ScratchRAM00
	REP.b #$20			; A->16
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0C
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	CLC
	LDX.b !RAM_SMW_Misc_ScratchRAM0A
	ADC.l DATA_028178,x
	STA.w SMW_OAMBuffer[$03].XDisp,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_ShakingLayer1DispYLo
	STA.b !RAM_SMW_Misc_ScratchRAM07
	ASL
	ROR.b !RAM_SMW_Misc_ScratchRAM07
	LDA.l DATA_0281CF,x
	DEC
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM07
	STA.w SMW_OAMBuffer[$03].YDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM0A
if defined("Define_SMW_SA1")
	NOP
	LDA.b #$0D
	STA.w SMW_OAMBuffer[$03].Prop,y
	LDA.l DATA_028226,x
	CMP.b #$E8
	STA.w SMW_OAMBuffer[$03].Tile,y
	REP.b #$20			; A->16
	BEQ.b candles
else
	LDA.w !RAM_SMW_Flag_UpdateBackgroundSpritesInKoopaKidRooms
	BNE.b CODE_028318
	LDA.l DATA_028226,x
	STA.w SMW_OAMBuffer[$03].Tile,y
	LDA.b #$0D
	STA.w SMW_OAMBuffer[$03].Prop,y
CODE_028318:
	REP.b #$20			; A->16
endif
	PHY
	TYA
	LSR
	LSR
	TAY
	SEP.b #$20			; A->8
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$03].Slot,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b #$F0
	BCC.b CODE_028367
	LDA.w !RAM_SMW_Sprites_BackgroundToUseInKoopaKidBattle
	CMP.b #$01
	BEQ.b CODE_028367
	PLY
	PHY
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w SMW_OAMBuffer[$03].XDisp,y
	STA.w SMW_OAMBuffer[$03].XDisp,x
	LDA.w SMW_OAMBuffer[$03].YDisp,y
	STA.w SMW_OAMBuffer[$03].YDisp,x
	LDA.w SMW_OAMBuffer[$03].Tile,y
	STA.w SMW_OAMBuffer[$03].Tile,x
	LDA.w SMW_OAMBuffer[$03].Prop,y
	STA.w SMW_OAMBuffer[$03].Prop,x
	REP.b #$20			; A->16
	TXA
	LSR
	LSR
	TAY
	SEP.b #$20			; A->8
	LDA.b #$03
	STA.w SMW_OAMTileSizeBuffer[$03].Slot,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM03
	BCC.b CODE_028367
	INC.b !RAM_SMW_Misc_ScratchRAM04
CODE_028367:
	PLY
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	DEY
	DEY
	DEY
	DEY
	DEX
	BMI.b CODE_028374
	JMP.w CODE_0282D8

CODE_028374:
	SEP.b #$10			; XY->8
if defined("Define_SMW_SA1")
	BRA.b +
	NOP #3
+
else
	LDA.b #$01
	STA.w !RAM_SMW_Flag_UpdateBackgroundSpritesInKoopaKidRooms
endif
	LDA.w !RAM_SMW_Sprites_BackgroundToUseInKoopaKidBattle			;\ Glitch: This causes the flames in the Ludwig battle to turn grey very briefly.
	CMP.b #$01								;| Probably best to remove it.
if defined("Define_SMW_SA1")
	BNE.b candles_refresh
else
	BNE.b CODE_028398							;|
endif
	LDA.b #$CD								;|
	STA.w SMW_OAMBuffer[$2F].Prop						;|
	STA.w SMW_OAMBuffer[$30].Prop						;|
	STA.w SMW_OAMBuffer[$31].Prop						;|
	STA.w SMW_OAMBuffer[$32].Prop						;|
	STA.w SMW_OAMBuffer[$33].Prop						;|
	STA.w SMW_OAMBuffer[$34].Prop						;|
	BRA.b CODE_0283C4							;/

CODE_028398:
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/028398.asm"
namespace SMW_GameMode14_InLevel
else
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$03
	BNE.b CODE_0283C4
	STZ.b !RAM_SMW_Misc_ScratchRAM00
CODE_0283A0:
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l DATA_0283C8,x
	TAY
	JSL.l SMW_GetRand_Main
	AND.b #$01
	BNE.b CODE_0283B7
	LDA.w SMW_OAMBuffer[$03].Tile,y
	EOR.b #$02
	STA.w SMW_OAMBuffer[$03].Tile,y
CODE_0283B7:
	LDA.b #$09
	STA.w SMW_OAMBuffer[$03].Prop,y
	INC.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$04
	BNE.b CODE_0283A0
endif
CODE_0283C4:
	JSR.w CODE_0283CE
	RTL

DATA_0283C8:
	db $00,$04,$08,$0C

DATA_0283CC:
	db $0C,$30

CODE_0283CE:
	LDA.w !RAM_SMW_NorSpr_Table7E1534+$09
	SEC
	SBC.b #$1E
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.w !RAM_SMW_NorSpr_Table7E160E+$09
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDX.b #$01
CODE_0283E0:
	STX.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.w !RAM_SMW_Sprites_MortonAndRoyLeftPillarStatus,x
	BEQ.b CODE_0283F4
	BMI.b CODE_0283F1
	STA.w !RAM_SMW_Player_FreezePlayerFlag
	STA.b !RAM_SMW_Flag_SpritesLocked
	JSR.w CODE_0283F8
CODE_0283F1:
	JSR.w CODE_028439
CODE_0283F4:
	DEX
	BPL.b CODE_0283E0
	RTS

CODE_0283F8:
	LDA.w !RAM_SMW_Sprites_MortonAndRoyLeftPillarYPosition,x
	; Change all 4A bytes (LSR) to EA (NOP), to increase the speed of the walls
	; in Morton/Roy's room when they're crashing down. The more EA bytes, the
	; faster (twice as fast per EA) the walls will come down.
	LSR
	LSR
	LSR
	LSR
	LSR
	SEC
	ADC.w !RAM_SMW_Sprites_MortonAndRoyLeftPillarYPosition,x
	CMP.b #$B0
	BCC.b CODE_028435
	ASL.w !RAM_SMW_Sprites_MortonAndRoyLeftPillarStatus,x
	SEC
	ROR.w !RAM_SMW_Sprites_MortonAndRoyLeftPillarStatus,x
	LDA.b #$30			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	CPX.b #$00
	BNE.b CODE_02842A
	LDA.w !RAM_SMW_Sprites_MortonAndRoyRightPillarStatus
	BNE.b CODE_02842A
	INC.w !RAM_SMW_Sprites_MortonAndRoyRightPillarStatus
	STZ.w !RAM_SMW_Sprites_MortonAndRoyRightPillarYPosition
	BRA.b CODE_028433

CODE_02842A:
	CPX.b #$01
	BNE.b CODE_028433
	STZ.b !RAM_SMW_Flag_SpritesLocked
	STZ.w !RAM_SMW_Player_FreezePlayerFlag
CODE_028433:
	LDA.b #$B0
CODE_028435:
	STA.w !RAM_SMW_Sprites_MortonAndRoyLeftPillarYPosition,x
	RTS

CODE_028439:
	LDA.l DATA_0283CC,x
	TAY
	STZ.b !RAM_SMW_Misc_ScratchRAM00
CODE_028440:
	LDA.b #$F0
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w !RAM_SMW_Sprites_MortonAndRoyLeftPillarYPosition,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	SEC
	SBC.w !RAM_SMW_ShakingLayer1DispYLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$20
	BCC.b Return02848C
	CMP.b #$A4
	BCS.b CODE_02845D
	STA.w SMW_OAMBuffer[$00].YDisp,y
CODE_02845D:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C,x
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.b #$E6
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	BEQ.b CODE_02846A
	LDA.b #$08
CODE_02846A:
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b #$0D
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAX
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	LDX.b !RAM_SMW_Misc_ScratchRAM0F
	INY
	INY
	INY
	INY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$90
	BCC.b CODE_028440
Return02848C:
	RTS
namespace off
endmacro

macro ROUTINE_RT06_SMW_GameMode14_InLevel(Address)
namespace SMW_GameMode14_InLevel
%InsertMacroAtXPosition(<Address>)

DATA_028AA9:
	db $07,$03,$03,$01,$01,$01,$01,$01

; Routine that handles the execution of miscellaneous sprite types, as well
; as the load of regular sprites in-level. From $028AB4 up to $028AD4 is the
; code that handles awarding extra lives. * $028AC9 is the amount of frames
; to wait before awarding each extra life. * $028ACE is the sound effect
; that plays when an extra life is awarded. From $028AD5 up to $028B04 is
; the code that handles the player's sparkle effect, either by having star
; power or by writing to the unused address $18D3. * $028ADB is the amount
; of frames after which star power no longer displays sparkles. From $028B20
; up to $028B64 is the code that handles sprites which respawn (Lakitu and
; Magikoopa in the vanilla game). * $028B4A contains the X offset (towards
; the left) in which the sprites respawn.
Bank02:
	PHB
	PHK
	PLB
	LDA.w !RAM_SMW_Misc_1upHandler
	BEQ.b CODE_028AD5
	LDA.w !RAM_SMW_Timer_Give1up
	BEQ.b CODE_028AC3
	DEC.w !RAM_SMW_Timer_Give1up
	BRA.b CODE_028AD5

CODE_028AC3:
	DEC.w !RAM_SMW_Misc_1upHandler
	BEQ.b CODE_028ACD
	LDA.b #$23
	STA.w !RAM_SMW_Timer_Give1up
CODE_028ACD:
	LDA.b #!Define_SMW_Sound1DFC_1up	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	INC.w !RAM_SMW_Player_CurrentLifeCount
CODE_028AD5:
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario doesn't have star
	BEQ.b CODE_028AEB
	CMP.b #$08
	BCC.b CODE_028AEB
	LSR
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w DATA_028AA9,y
	BRA.b CODE_028AF5

CODE_028AEB:
	LDA.w !RAM_SMW_Timer_UnusedPlayerSparkle
	BEQ.b CODE_028B05
	DEC.w !RAM_SMW_Timer_UnusedPlayerSparkle
	AND.b #$01
CODE_028AF5:
	ORA.b !RAM_SMW_Player_OnScreenPosXHi
	ORA.b !RAM_SMW_Player_OnScreenPosYHi
	BNE.b CODE_028B05
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	CMP.b #$D0
	BCS.b CODE_028B05
	JSL.l SMW_SpawnSparkles_PlayerEntry
CODE_028B05:
	JSR.w SMW_ProcessMinorExtendedSprites_Main		;\ Optimization: Big ugly list of JSRs. All of these plus the one for cluster sprites can be integrated into one routine call.
	JSR.w SMW_ProcessBounceAndSmokeSprites_Main		;| This will save a decent chunk of bytes and cycles.
	JSR.w SMW_ProcessScoreSprites_Main			;|
	JSR.w SMW_ProcessExtendedSprites_Main			;|
	JSR.w SMW_ProcessSpinningCoinSprites_Main		;|
	JSR.w SMW_ProcessShooterSprites_Main			;|
	JSR.w SMW_ProcessGeneratorSprite_Main			;/
	JSR.w SMW_HandleCapeInteraction_Main
	JSR.w SMW_ParseLevelSpriteList_Main
	LDA.w !RAM_SMW_Timer_RespawnSprite			;\ Optimization: Couldn't the respawning sprites be made into a sprite status?
	BEQ.b CODE_028B65					;/ Seems kind of hack-y to put this code in the main level loop.
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Decrement every other frame...
	AND.b #$01
	ORA.b !RAM_SMW_Flag_SpritesLocked	; | ...as long as sprites not locked...
	ORA.w !RAM_SMW_Timer_DisappearingSprite
	BNE.b CODE_028B65
	DEC.w !RAM_SMW_Timer_RespawnSprite
	BNE.b CODE_028B65		; Return if the timer hasn't just run out
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b CODE_028B65
	TYX
	LDA.b #!Define_SMW_NorSprStatus01_Init	; \ Sprite status = Initialization
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.w !RAM_SMW_Sprites_SpriteToRespawn	; \ Sprite = Sprite to respwan
if defined("Define_SMW_SA1")
	; SA-1 Pack: Sprite respawning.
	JSL.l SPRITE_RESPAWN_SET
else
	STA.b !RAM_SMW_NorSpr_SpriteID,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
endif
	SEC
	SBC.b #$20
	AND.b #$EF
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.w !RAM_SMW_Sprites_YPosOfRespawningSpriteLo
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_Sprites_YPosOfRespawningSpriteHi
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Reset sprite tables
CODE_028B65:
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_LoadSublevel(Address)
namespace SMW_LoadSublevel
%InsertMacroAtXPosition(<Address>)

CODE_02A751:
	PHB
	PHK
	PLB
	JSR.w SMW_InitializeAllSpritesOnLevelLoad_Main
	JSR.w SMW_LoadSpritesOnLevelLoad_Main
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	BMI.b CODE_02A763
if defined("Define_SMW_SA1")
	JSL.l SA1_Sprites
else
	JSL.l SMW_ProcessNormalSprites_Main
endif
CODE_02A763:
	LDA.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	BEQ.b CODE_02A771
	LDA.w !RAM_SMW_Flag_PreventYoshiCarryOver
	BNE.b CODE_02A771
	JSL.l SMW_SpawnMountedYoshiOnLevelLoad_Main
CODE_02A771:
	PLB
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_InitializeAllSpritesOnLevelLoad(Address)
namespace SMW_InitializeAllSpritesOnLevelLoad
%InsertMacroAtXPosition(<Address>)

Main:
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_ClearIt
	JML.l SpriteLoading_Label3
else
	LDX.b #$3F				; Glitch: This needs to be #$7F so all sprites can load in the new sublevel.
CODE_02ABF4:
	STZ.w !RAM_SMW_Sprites_LoadStatus,x	; Allow sprite to be reloaded by level loading routine
	DEX
	BPL.b CODE_02ABF4
endif
	LDA.b #$FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b #!Define_SMW_MaxNormalSpriteSlot
CODE_02AC00:
	LDA.b #$FF			; \ Set to permanently erase sprite
	STA.w !RAM_SMW_NorSpr_LoadStatusTableIndex,x
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus0B_Carried
	BEQ.b CODE_02AC11
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	BRA.b CODE_02AC13

CODE_02AC11:
	STX.b !RAM_SMW_Misc_ScratchRAM00
CODE_02AC13:
	DEX
	BPL.b CODE_02AC00
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	; Change from 30 to 80 to fix various glitches that occur when carrying a
	; sprite through a pipe, such as the silver P-switch behaving like a blue
	; one, throw blocks never expiring, and stunned enemies never waking up.
	; Essentially, this skips over a chunk of code that transfers the carried
	; sprite to slot 0 and clears all of its tables, except for $15F6 (the
	; YXPPCCCT data).
	BMI.b CODE_02AC48
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_NorSprStatus0B_Carried	; \ Sprite status = Being carried
	STA.w !RAM_SMW_NorSpr_CurrentStatus
if defined("Define_SMW_SA1")
	; SA-1 Pack: In this case we are moving the current item being carried to
	; slot 0 while going through a pipe. Overwrite this code with out own and
	; set a the address of index 0 in the old table location because the code
	; will be using it for a few other things shortly.
	JML.l ITEM_SLOT_CHANGE
else
	LDA.b !RAM_SMW_NorSpr_SpriteID,x
	STA.b !RAM_SMW_NorSpr_SpriteID
endif
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_NorSpr_XPosLo_AsShipped	; dead under SA-1 Pack, which replaces this code
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_AsShipped,x	; dead under SA-1 Pack, which replaces this code
	STA.b !RAM_SMW_NorSpr_YPosLo_AsShipped	; dead under SA-1 Pack, which replaces this code
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	PHA
	LDX.b #$00
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLA
	STA.w !RAM_SMW_NorSpr_Table7E15F6
CODE_02AC48:
	REP.b #$10			; XY->16
	LDX.w #$027A
CODE_02AC4D:
	STZ.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo,x	; clear ram before entering new stage/area
	DEX
	BPL.b CODE_02AC4D
	SEP.b #$10			; XY->8
	STZ.w !RAM_SMW_L1ScrollSpr_SpriteID
	STZ.w !RAM_SMW_L2ScrollSpr_SpriteID
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_LoadSpritesOnLevelLoad(Address)
namespace SMW_LoadSpritesOnLevelLoad
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	LSR
	BCC.b CODE_02ACA1
	LDA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	PHA
	LDA.b #$01
	STA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	PHA
	SEC
	SBC.b #$60
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	PHA
	SBC.b #$00
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	STZ.w !RAM_SMW_Misc_ScratchRAM7E18B6
CODE_02AC7A:
	JSR.w SMW_ParseLevelSpriteList_Entry2				;\ Optimization: Why is the sprite list routine called twice?
	JSR.w SMW_ParseLevelSpriteList_Entry2				;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	INC.w !RAM_SMW_Misc_ScratchRAM7E18B6
	LDA.w !RAM_SMW_Misc_ScratchRAM7E18B6
	CMP.b #$20
	BCC.b CODE_02AC7A
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	PLA
	STA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	RTS

CODE_02ACA1:
	LDA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	PHA
	LDA.b #$01
	STA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	PHA
	SEC
	SBC.b #$60
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	PHA
	SBC.b #$00
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	STZ.w !RAM_SMW_Misc_ScratchRAM7E18B6
CODE_02ACBA:
	JSR.w SMW_ParseLevelSpriteList_Entry2				;\ Optimization: Why is the sprite list routine called twice?
	JSR.w SMW_ParseLevelSpriteList_Entry2				;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	INC.w !RAM_SMW_Misc_ScratchRAM7E18B6
	LDA.w !RAM_SMW_Misc_ScratchRAM7E18B6
	CMP.b #$20
	BCC.b CODE_02ACBA
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	PLA
	STA.b !RAM_SMW_Camera_Layer1ScrollingDirection
	RTS
namespace off
endmacro

macro ROUTINE_RT06_SMW_RunPlayerBlockCode(Address)
namespace SMW_RunPlayerBlockCode
%InsertMacroAtXPosition(<Address>)

; Cape Mario smashes ground subroutine.
TriggerCapeDiveGroundPound:
	LDA.b #$30			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
	STZ.w !RAM_SMW_UnusedRAM_7E14A9					; Optimization: Unused
	PHB
	PHK
	PLB
	LDX.b #!Define_SMW_MaxNormalSpriteSlot-$02	; Loop over sprites:
KillSprLoopStart:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Skip current sprite if status < 8
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b GroundPoundNextSpr
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Skip current sprite if not on ground
	AND.b #$04
	BEQ.b GroundPoundNextSpr
	LDA.w !RAM_SMW_NorSpr_PropertyBits166E,x	; \ Skip current sprite if...
	AND.b #!Define_SMW_NorSpr_166EProp_ImmuneToCape	; | ...can't be killed by cape...
	ORA.w !RAM_SMW_NorSpr_OnYoshisTongue,x	; | ...or sprite being eaten...
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x	; | ...or interaction disabled
	BNE.b GroundPoundNextSpr
	LDA.b #$35
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	JSR.w SMW_CheckForPlayerAttackToNormalSpriteCollision_CODE_029404
GroundPoundNextSpr:
	DEX
	BPL.b KillSprLoopStart
	PLB
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_YoshiStompRoutine(Address)
namespace SMW_YoshiStompRoutine
%InsertMacroAtXPosition(<Address>)

; Yellow Yoshi earthquake subroutine.
Main:
	LDA.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped
	BNE.b Return0286EC
	PHB
	PHK
	PLB
	JSR.w SMW_InitializeBlockPunchAttack_Main
	LDA.b #$02
	STA.w !RAM_SMW_BounceSpr_Type,y
	LDA.b !RAM_SMW_Player_XPosLo
	STA.w !RAM_SMW_BounceSpr_HitboxXLo,y
	LDA.b !RAM_SMW_Player_XPosHi
	STA.w !RAM_SMW_BounceSpr_HitboxYHi,y
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b #$20
	STA.w !RAM_SMW_BounceSpr_HitboxYLo,y
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_BounceSpr_HitboxYHi,y
	JSR.w SMW_SpawnYoshiStompSmoke_Main
	PLB
Return0286EC:
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SpawnYoshiStompSmoke(Address)
namespace SMW_SpawnYoshiStompSmoke
%InsertMacroAtXPosition(<Address>)

InitialXLo:
	db $08,$F8

InitialXHi:
	db $00,$FF

InitialXSpeed:
	db $18,$E8

Main:
	LDA.b #$05			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	JSR.w SpawnFirstSmoke
	INC.b !RAM_SMW_Misc_ScratchRAM00
SpawnFirstSmoke:
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
Loop:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b SpawnSmoke
	DEY
	BPL.b Loop
	RTS				; / Return if no free slots

SpawnSmoke:
	LDA.b #!Define_SMW_SpriteID_ExtSpr0F_SmokeTrail	; \ Extended sprite = Yoshi stomp smoke
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b #$28
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w InitialXLo,x
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.b !RAM_SMW_Player_XPosHi
	ADC.w InitialXHi,x
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.w InitialXSpeed,x
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
	LDA.b #$15
	STA.w !RAM_SMW_ExtSpr0F_SmokeTrail_DespawnTimer,y
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_GrabThrowBlockBlock(Address)
namespace SMW_GrabThrowBlockBlock
%InsertMacroAtXPosition(<Address>)

; Throw block creation subroutine. $028648 - Change from B5 to A5 to change
; a bug with the throwblock where it may spawn a water splash upon spawn in
; a buoyancy-enabled level. $02864E - Sprite number: Sprite that the Throw
; Block is made from. $028656 - Throw Block timer. Change it to 00 and it
; stays forever.
Main:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return028662
	TYX
if defined("Define_SMW_SA1")
	; SA-1 Pack: When picking up a block we generate a sprite, needs fixing.
	JSL.l PICKUP_BLOCK_SET
	NOP
else
	LDA.b #!Define_SMW_NorSprStatus0B_Carried	; \ Sprite status = Being carried
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
endif
	LDA.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Player_YPosHi
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Player_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b #!Define_SMW_SpriteID_NorSpr053_ThrowBlock	; \ Sprite = Throw Block
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	LDA.b #$08
	STA.w !RAM_SMW_Timer_DisplayPlayerPickUpPose
	STA.w !RAM_SMW_Player_CarryingSomethingFlag2
Return028662:
	RTL

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_ExtendedSpriteOAMIndexes(Address)
namespace SMW_ExtendedSpriteOAMIndexes
%InsertMacroAtXPosition(<Address>)

; OAM indexes for extended sprites.
Main:
	db $90,$94,$98,$9C,$A0,$A4,$A8,$AC
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_SmokeSpriteOAMIndexes(Address)
namespace SMW_SmokeSpriteOAMIndexes
%InsertMacroAtXPosition(<Address>)

; OAM indexes for the smoke images (in the $0200 block).
One:
	db $20,$24,$28,$2C
Two:
	db $90,$94,$98,$9C
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_MinorExtendedSpriteOAMIndexes(Address)
namespace SMW_MinorExtendedSpriteOAMIndexes
%InsertMacroAtXPosition(<Address>)

; OAM indexes for minor extended sprites.
Main:
	db $50,$54,$58,$5C,$60,$64,$68,$6C
	db $70,$74,$78,$7C
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_ClusterSpriteOAMIndexes(Address)
namespace SMW_ClusterSpriteOAMIndexes
%InsertMacroAtXPosition(<Address>)

; OAM indexes of cluster sprites. Apparently can overwrite the coin sprites
; from blocks, sparkles, item box, and fireballs.
Main:
if defined("Define_SMW_SA1")
	; SA-1 Pack: This table contains OAM indices for cluster sprites. Set them
	; to use the highest indices so as not to conflict with ordinary sprites.
	db $E0,$E4,$E8,$EC,$F0,$F4,$F8,$FC
	db $B0,$B4,$B8,$BC,$D0,$D4,$D8,$DC
	db $C0,$C4,$C8,$CC
else
	db $E0,$E4,$E8,$EC,$F0,$F4,$F8,$FC
	db $5C,$58,$54,$50,$4C,$48,$44,$40
	db $3C,$38,$34,$30
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckForPlayerToEnemyClusterSpriteCollision(Address)
namespace SMW_CheckForPlayerToEnemyClusterSpriteCollision
%InsertMacroAtXPosition(<Address>)

; Cluster sprite/player interaction routine. This routine assumes that the
; cluster sprite is approximately 16x16.
Main:
	LDA.b #$14
	BRA.b CODE_02FE77

Entry2:							;\ Note: Unused
	LDA.b #$0C					;/
CODE_02FE77:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ClusterSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$000A
	CMP.b !RAM_SMW_Misc_ScratchRAM02
	SEP.b #$20			; A->8
	BCS.b Return02FEC4
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	ADC.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_ClusterSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM03
	REP.b #$20			; A->16
	LDA.w #$0014
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b SmallPlayer
	LDA.w #$0020
SmallPlayer:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Player_YPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.w #$001C
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	SEP.b #$20			; A->8
	BCS.b Return02FEC4
	JSR.w SMW_ClusterSpr06_SumoBroFlame_CODE_02F9F5				; Optimization: Replace with JMP.w SMW_CheckForMarioToExtendedSpriteCollision_CODE_02A46E. This also removes the dependancy on the Sumo Bro Flames code.
Return02FEC4:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckPlayerPositionRelativeToSprite(Address)
namespace SMW_CheckPlayerPositionRelativeToSprite
%InsertMacroAtXPosition(<Address>)

CopyOfBank02:
.X:
%CheckPlayerPositionRelativeToSpriteSub(RAM_SMW_Player_XPos, RAM_SMW_NorSpr_XPos, !RAM_SMW_Misc_ScratchRAM0F, none)
namespace off
endmacro

macro ROUTINE_RT02_SMW_CheckPlayerPositionRelativeToSprite(Address)
namespace SMW_CheckPlayerPositionRelativeToSprite
%InsertMacroAtXPosition(<Address>)

UNK_02D4F2:
	db $80,$40,$20,$10,$08,$04,$02,$01

Bank02:
.X:
%CheckPlayerPositionRelativeToSpriteSub(RAM_SMW_Player_XPos, RAM_SMW_NorSpr_XPos, !RAM_SMW_Misc_ScratchRAM0F, none)

.Y:
;$02D50C
%CheckPlayerPositionRelativeToSpriteSub(RAM_SMW_Player_YPos, RAM_SMW_NorSpr_YPos, !RAM_SMW_Misc_ScratchRAM0E, none)
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckIfNormalSpriteOffScreen(Address)
namespace SMW_CheckIfNormalSpriteOffScreen
%InsertMacroAtXPosition(<Address>)

CopyOfBank02:
	%INLINEROUTINE_SMW_CheckIfNormalSpriteOffScreen()
namespace off
endmacro

macro ROUTINE_RT02_SMW_CheckIfNormalSpriteOffScreen(Address)
namespace SMW_CheckIfNormalSpriteOffScreen
%InsertMacroAtXPosition(<Address>)

Bank02:
	%INLINEROUTINE_SMW_CheckIfNormalSpriteOffScreen()
namespace off
endmacro

macro ROUTINE_RT01_SMW_SubOffscreen(Address)
namespace SMW_SubOffscreen
%InsertMacroAtXPosition(<Address>)

Bank02:
.DATA_02D003:
	db $40,$B0

.DATA_02D005:
	db $01,$FF

.DATA_02D007:
	db $30,$C0,$A0,$C0,$A0,$70,$60,$B0

.DATA_02D00F:
	db $01,$FF,$01,$FF,$01,$FF,$01,$FF

.Entry4:
	LDA.b #$06			; \ Entry point of routine determines value of $03
	BRA.b .CODE_02D021

.Entry3:
	LDA.b #$04
	BRA.b .CODE_02D021

.Entry2:
	LDA.b #$02
.CODE_02D021:
	STA.b !RAM_SMW_Misc_ScratchRAM03
	BRA.b .CODE_02D027

.Entry1:
	STZ.b !RAM_SMW_Misc_ScratchRAM03
.CODE_02D027:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank02	; \ if sprite is not off screen, return
	BEQ.b .Return02D090
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	; \  vertical level
	AND.b #$01
	BNE.b .VerticalLevel
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CMP.b #$04
	BEQ.b .CODE_02D04D
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$50			; | if the sprite has gone off the bottom of the level...
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	; | (if adding 0x50 to the sprite y position would make the high byte >= 2)
	ADC.b #$00
	CMP.b #$02
	BPL.b .EraseSprite		; /    ...erase the sprite
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ if "process offscreen" flag is set, return
	AND.b #!Define_SMW_NorSpr_167AProp_TrackWhenOffScreen
	BNE.b .Return02D090
.CODE_02D04D:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM01
	TAY
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w .DATA_02D007,y
	ROL.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b !RAM_SMW_NorSpr_XPosLo_x
	PHP
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w .DATA_02D00F,y
	PLP
	SBC.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LSR.b !RAM_SMW_Misc_ScratchRAM01
	BCC.b .CODE_02D076
	EOR.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
.CODE_02D076:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b .Return02D090
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
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x	; Erase sprite
.Return02D090:
	RTS

.VerticalLevel:
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ If "process offscreen" flag is set, return
	AND.b #!Define_SMW_NorSpr_167AProp_TrackWhenOffScreen
	BNE.b .Return02D090
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Return every other frame
	LSR
	BCS.b .Return02D090
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM01
	TAY
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.w .DATA_02D003,y
	ROL.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b !RAM_SMW_NorSpr_YPosLo_x
	PHP
	LDA.w !RAM_SMW_Mirror_CurrentLayer1YPosHi
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w .DATA_02D005,y
	PLP
	SBC.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	BEQ.b .CODE_02D0C3
	EOR.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
.CODE_02D0C3:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b .Return02D090
	BMI.b .EraseSprite
namespace off
endmacro

macro ROUTINE_RT02_SMW_SubOffscreen(Address)
namespace SMW_SubOffscreen
%InsertMacroAtXPosition(<Address>)

;Note: This routine is an unused varient that would have been used by cluster sprites

DATA_02FEC5:
	db $40,$B0

DATA_02FEC7:
	db $01,$FF

DATA_02FEC9:
	db $30,$C0

DATA_02FECB:
	db $01,$FF

ClusterSprites:
.Main:
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	; \ Unreachable
	AND.b #$01
	BNE.b ADDR_02FF1E
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	CLC
	ADC.b #$50
	LDA.w !RAM_SMW_ClusterSpr_YPosHi,x
	ADC.b #$00
	CMP.b #$02
	BPL.b ADDR_02FF0E
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM01
	TAY
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w DATA_02FEC9,y
	ROL.b !RAM_SMW_Misc_ScratchRAM00
	CMP.w !RAM_SMW_ClusterSpr_XPosLo,x
	PHP
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w DATA_02FECB,y
	PLP
	SBC.w !RAM_SMW_ClusterSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LSR.b !RAM_SMW_Misc_ScratchRAM01
	BCC.b ADDR_02FF0A
	EOR.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
ADDR_02FF0A:

	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b Return02FF1D
ADDR_02FF0E:

	LDY.w !RAM_SMW_ClusterSpr_Table7E0F86,x
	CPY.b #$FF
	BEQ.b ADDR_02FF1A
if defined("Define_SMW_SA1")
	JSL.l SpriteLoading_CODE_01AC9C
	NOP
else
	LDA.b #$00			; \ Allow sprite to be reloaded by level loading routine
	STA.w !RAM_SMW_Sprites_LoadStatus,y
endif
ADDR_02FF1A:

	STZ.w !RAM_SMW_ClusterSpr_SpriteID,x
Return02FF1D:

	RTS

ADDR_02FF1E:
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Unreachable, called from above routine
	LSR
	BCS.b Return02FF1D
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM01
	TAY
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w DATA_02FEC5,y
	ROL.b !RAM_SMW_Misc_ScratchRAM00
	CMP.w !RAM_SMW_ClusterSpr_YPosLo,x
	PHP
	LDA.w !RAM_SMW_Mirror_CurrentLayer1YPosHi
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w DATA_02FEC7,y
	PLP
	SBC.w !RAM_SMW_ClusterSpr_YPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	BEQ.b ADDR_02FF4A
	EOR.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
ADDR_02FF4A:

	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b Return02FF1D
	BMI.b ADDR_02FF0E
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnMusicNoteOrZ(Address)
namespace SMW_SpawnMusicNoteOrZ
%InsertMacroAtXPosition(<Address>)

; (Unused) Z tile generation (Rip Van Fish Z tiles).
;
; (Unused) Minor extended tile generation. $02C0CF-$02C0D8 is the routine
; that spawns minor extended sprite 8 (the 8x8 music note seen in GFX 13),
; which is called by the Exploding Turn Block sprite at $02E429 prior to
; being rendered unused by a branch at $02E427. $02C0D9-$02C125 meanwhile,
; handles the generation of Rip Van Fish's Z tiles.
MusicNote: 								;\ Note: Unused
	LDA.b #!Define_SMW_SpriteID_MExtSpr08_UnusedMusicNote		;|
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x				;|
	BEQ.b ADDR_02C0D7						;|
	INC								;|
ADDR_02C0D7:								;|
	BRA.b CODE_02C0DB						;/

; Rip Van Fish Z tiles generation routine
Z:
	LDA.b #!Define_SMW_SpriteID_MExtSpr06_RipVanFishZ
CODE_02C0DB:
	TAY
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x	; \ Return if sprite is offscreen
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b Return02C125
	TYA
	DEC.w !RAM_SMW_NorSpr03D_RipVanFish_ZSpawnTimer,x
	BPL.b Return02C125
	PHA
	LDA.b #$28
	STA.w !RAM_SMW_NorSpr03D_RipVanFish_ZSpawnTimer,x
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot
CODE_02C0F2:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y
	BEQ.b CODE_02C107
	DEY
	BPL.b CODE_02C0F2
	DEC.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
	BPL.b CODE_02C104
	LDA.b #!Define_SMW_MaxMinorExtendedSpriteSlot
	STA.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
CODE_02C104:
	LDY.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
CODE_02C107:
	PLA
	STA.w !RAM_SMW_MExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$06
	STA.w !RAM_SMW_MExtSpr_XPosLo,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$00
	STA.w !RAM_SMW_MExtSpr_YPosLo,y
	LDA.b #$7F
	STA.w !RAM_SMW_MExtSpr_Timer,y
	LDA.b #$FA
	STA.w !RAM_SMW_MExtSpr_XSpeed,y
Return02C125:
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckForAvailableScoreSpriteSlot(Address)
namespace SMW_CheckForAvailableScoreSpriteSlot
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #!Define_SMW_MaxScoreSpriteSlot	; (here css is used to index through the table of score sprites in table at $16E1
CODE_02AD36:
	LDA.w !RAM_SMW_ScoreSpr_SpriteID,y	; for (css=5;css>=0;css--){
	BEQ.b Return02AD4B		;  if (css's type == 0)      --check for empty space
	DEY
	BPL.b CODE_02AD36		; }
	DEC.w !RAM_SMW_ScoreSpr_SlotToOverwriteWhenSlotsFull	; $18f7--;                   --gives LRU
	BPL.b CODE_02AD48		; if ($18f7 <0)
	LDA.b #!Define_SMW_MaxScoreSpriteSlot	;   $18f7=5;
	STA.w !RAM_SMW_ScoreSpr_SlotToOverwriteWhenSlotsFull
CODE_02AD48:
	LDY.w !RAM_SMW_ScoreSpr_SlotToOverwriteWhenSlotsFull	; return $18f7 in Y;
Return02AD4B:
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GivePoints(Address)
namespace SMW_GivePoints
%InsertMacroAtXPosition(<Address>)

Entry2:
	PHX
	TYX
	BRA.b CODE_02ACE6

; The "give points" routine. It ends in RTL, but it JSLs to the main one. To
; use this properly, A should contain one of the following values: 00 = 100
; 01 = 200 02 = 400 03 = 800 04 = 1000 05 = 2000 06 = 4000 07 = 8000 08 =
; 1up 09 = 2up 0A = 3up 0B = 5up (may glitch)
Main:
	PHX				;  takes sprite type -5 as input in A
CODE_02ACE6:
	CLC
	ADC.b #$05			; Add 5 to sprite type (200,400,1up)
	JSL.l CODE_02ACEF		; Set score sprite type/initial position
	PLX
	RTL

; The main score sprite subroutine. Load a value into A and JSL to it to
; give the player points. 00 = ? 01 = 10 02 = 20 03 = 40 04 = 80 05 = 100 06
; = 200 07 = 400 08 = 800 09 = 1000 0A = 2000 0B = 4000 0C = 8000 0D = 1up
; 0E = 2up 0F = 3up 10 = 5up (may glitch)
CODE_02ACEF:
	PHY				;  - note coordinates are level coords, not screen
	PHA				;    sprite type 1=10,2=20,3=40,4=80,5=100,6=200,7=400,8=800,9=1000,A=2000,B=4000,C=8000,D=1up
	JSL.l SMW_CheckForAvailableScoreSpriteSlot_Main	; Get next free position in table($16E1) to add score sprite
	PLA
	STA.w !RAM_SMW_ScoreSpr_SpriteID,y	; Set score sprite type (200,400,1up, etc)
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; Load y position of sprite jumped on
	SEC
	SBC.b #$08			;   - make the score sprite appear a little higher
	STA.w !RAM_SMW_ScoreSpr_YPosLo,y	; Set this as score sprite y-position
	PHA				; save that value
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	; Get y-pos high byte for sprite jumped on
	SBC.b #$00
	STA.w !RAM_SMW_ScoreSpr_YPosHi,y	; Set score sprite y-pos high byte
	PLA				; restore score sprite y-pos to A
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$F0			; |if (score sprite ypos <1C && >=0C)
	BCC.b CODE_02AD22		; |{
	LDA.w !RAM_SMW_ScoreSpr_YPosLo,y
	ADC.b #$10
	STA.w !RAM_SMW_ScoreSpr_YPosLo,y	; |  move score sprite down by #$10
	LDA.w !RAM_SMW_ScoreSpr_YPosHi,y
	ADC.b #$00
	STA.w !RAM_SMW_ScoreSpr_YPosHi,y	; /}
CODE_02AD22:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_ScoreSpr_XPosLo,y	; /Set score sprite x-position
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_ScoreSpr_XPosHi,y	; /Set score sprite x-pos high byte
	LDA.b #$30
	STA.w !RAM_SMW_ScoreSpr_YSpeed,y	; /scoreSpriteSpeed = #$30
	PLY
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnLavaSplash(Address)
namespace SMW_SpawnLavaSplash
%InsertMacroAtXPosition(<Address>)

InitialXSpeed:
	db $04,$FC,$06,$FA,$08,$F8,$0A,$F6

InitialYSpeed:
	db $E0,$E1,$E2,$E3,$E4,$E6,$E8,$EA

InitialAnimationFrameCounter:
	db $1F,$13,$10,$1C,$17,$1A,$0F,$1E

; Lava Splash Subroutine $028540 is the objects to use for lava splash.
Main:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_CopyOfBank02		;\ Optimization: Really? Either remove the latter line or replace the JSR.w SMW_with "LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x" and the following LDA with ORA
	LDA.w !RAM_SMW_NorSpr_YOffscreenFlag,x				;/
	BNE.b SMW_SpawnWaterSplash_Return0284E7
	LDA.b #$04			;\$00 = #$04
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_028536:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_02853F
	DEY
	BPL.b CODE_028536
	RTL				; / Return if no free slots

CODE_02853F:
	LDA.b #!Define_SMW_SpriteID_ExtSpr07_LavaSplash	; \ Extended sprite = Lava splash
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\Set position
	STA.w !RAM_SMW_ExtSpr_YPosLo,y	;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x	;|
	STA.w !RAM_SMW_ExtSpr_YPosHi,y	;|
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;|
	CLC				;|
	ADC.b #$04			;|
	STA.w !RAM_SMW_ExtSpr_XPosLo,y	;|
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;|
	ADC.b #$00			;|
	STA.w !RAM_SMW_ExtSpr_XPosHi,y	;/
	JSL.l SMW_GetRand_Main		;\Spawn with each particles falling in random
	PHX				;|directions
	AND.b #$07			;|
	TAX				;|
	LDA.l InitialXSpeed,x		;|
	STA.w !RAM_SMW_ExtSpr_XSpeed,y	;|
	LDA.w !RAM_SMW_Misc_RandomByte2	;|
	AND.b #$07			;|
	TAX				;|
	LDA.l InitialYSpeed,x		;|
	STA.w !RAM_SMW_ExtSpr_YSpeed,y	;|
	JSL.l SMW_GetRand_Main		;|
	AND.b #$07			;|
	TAX				;|
	LDA.l InitialAnimationFrameCounter,x	;|
	STA.w !RAM_SMW_ExtSpr07_LavaSplash_AnimationFrameCounter,y	;|
	PLX				;|
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;|
	BPL.b CODE_028536		;/
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleExtendedSpriteLevelCollision(Address)
namespace SMW_HandleExtendedSpriteLevelCollision
%InsertMacroAtXPosition(<Address>)

; Object contact subroutine for the player's fireballs.
Main:
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	STZ.b !RAM_SMW_Misc_ScratchRAM0E
	STZ.b !RAM_SMW_Misc_ScratchRAM0B
	STZ.w !RAM_SMW_Sprites_DistanceToSnapDownToNearestTile
	LDA.w !RAM_SMW_Flag_ReznorRoomOAMIndexTimer
	BNE.b CODE_02A5BC
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	BPL.b CODE_02A5BC
	AND.b #$40
	BEQ.b CODE_02A592
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	CMP.b #$C1
	BEQ.b CODE_02A5BC
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x
	CMP.b #$A8
	RTS

CODE_02A592:
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetLo
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetHi
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetLo
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetHi
	JSL.l SMW_CheckForTiltingPlatformCollision_Main
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

CODE_02A5BC:
	JSR.w CODE_02A611
	ROL.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	BPL.b CODE_02A60C
	INC.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x
	PHA
	CLC
	ADC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo
	STA.w !RAM_SMW_ExtSpr_XPosLo,x
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x
	PHA
	ADC.b !RAM_SMW_Misc_SecondLevelLayerXPosHi
	STA.w !RAM_SMW_ExtSpr_XPosHi,x
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x
	PHA
	CLC
	ADC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo
	STA.w !RAM_SMW_ExtSpr_YPosLo,x
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x
	PHA
	ADC.b !RAM_SMW_Misc_SecondLevelLayerYPosHi
	STA.w !RAM_SMW_ExtSpr_YPosHi,x
	JSR.w CODE_02A611
	ROL.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	PLA
	STA.w !RAM_SMW_ExtSpr_YPosHi,x
	PLA
	STA.w !RAM_SMW_ExtSpr_YPosLo,x
	PLA
	STA.w !RAM_SMW_ExtSpr_XPosHi,x
	PLA
	STA.w !RAM_SMW_ExtSpr_XPosLo,x
CODE_02A60C:
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CMP.b #$01
	RTS

CODE_02A611:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	INC
	AND.b !RAM_SMW_Misc_LevelLayoutFlags
	BEQ.b CODE_02A679
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Blocks_YPosLo
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x
	ADC.b #$00
	CMP.b !RAM_SMW_Misc_ScreensInLvl
	BCS.b CODE_02A677
	STA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x
	ADC.b #$00
	CMP.b #$02
	BCS.b CODE_02A677
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_02A660
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L2,x
CODE_02A660:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_02A671
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L2,x
CODE_02A671:
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06
	BRA.b CODE_02A6DB

CODE_02A677:
	CLC
	RTS

CODE_02A679:
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Blocks_YPosLo
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$F0
	BCS.b CODE_02A677
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x
	ADC.b #$00
	CMP.b !RAM_SMW_Misc_ScreensInLvl
	BCS.b CODE_02A677
	STA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_02A6C6
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L2,x
CODE_02A6C6:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_02A6D7
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L2,x
CODE_02A6D7:
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06
CODE_02A6DB:
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	INC.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
#LM000Hijack_ProcessCustomMarioFireballBlockCode:
	JSL.l SMW_ModifyMap16IDForSpecialBlocks_Main
	CMP.b #$00
	BEQ.b CODE_02A729
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	CMP.b #$11
	BCC.b CODE_02A72B
	CMP.b #$6E
	BCC.b CODE_02A727
	CMP.b #$D8
	BCS.b CODE_02A735
	LDY.b !RAM_SMW_Blocks_XPosLo
	STY.b !RAM_SMW_Misc_ScratchRAM0A
	LDY.b !RAM_SMW_Blocks_YPosLo
	STY.b !RAM_SMW_Misc_ScratchRAM0C
	JSL.l SMW_CheckWhatSlopeSpriteIsOn_Main
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$0C
	BCS.b CODE_02A718
	CMP.b [!RAM_SMW_Misc_ScratchRAM05],y
	BCC.b CODE_02A729
CODE_02A718:
	LDA.b [!RAM_SMW_Misc_ScratchRAM05],y
	STA.w !RAM_SMW_Sprites_DistanceToSnapDownToNearestTile
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM08
	LDA.l SMW_SlopeDataTables_SlopeType,x
	PLX
	STA.b !RAM_SMW_Misc_ScratchRAM0B
CODE_02A727:
	SEC
	RTS

CODE_02A729:
	CLC
	RTS

CODE_02A72B:
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.b #$0F
	CMP.b #$06
	BCS.b CODE_02A729
	SEC
	RTS

CODE_02A735:
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.b #$0F
	CMP.b #$06
	BCS.b CODE_02A729
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x
	SEC
	SBC.b #$02
	STA.w !RAM_SMW_ExtSpr_YPosLo,x
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,x
	JMP.w CODE_02A611
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GenericExtendedSpriteGFXRt(Address)
namespace SMW_GenericExtendedSpriteGFXRt
%InsertMacroAtXPosition(<Address>)

; 8x8 fireball GFX subroutine. Is it also used as a base for various other
; extended sprites' graphics (they JSR to it and then change the tile
; numbers and properties) as well as despawning them when they leave the
; screen.
Main:
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x
FireballEntry:
	LDA.w !RAM_SMW_ExtSpr_XSpeed,x	;\$00 = Sign bit in bit 6
	AND.b #$80			;|(%0X000000)
	EOR.b #$80			;|
	LSR				;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;\$01 = X pos on screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x	;\Despawn if offscreen
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;|
	BNE.b EraseSprite		;/
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\$02 = Y pos on screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x	;\Delete if offscreen
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;|
	BNE.b EraseSprite		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\If on the unsceen part
	CMP.b #$F0			;|of the screen at the bottom
	BCS.b EraseSprite		;/also delete
	STA.w SMW_OAMBuffer[$00].YDisp,y	;>OAM Y pos
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\OAM X pos
	STA.w SMW_OAMBuffer[$00].XDisp,y	;/
	LDA.w !RAM_SMW_ExtSpr_Table7E1779,x	;\$01 = Extended sprite behind layers
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/(like if fire mario is behind net tiles shoots fireballs)
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$03
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l FireballTiles,x
else
	LDA.w FireballTiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_02A15F,x
else
	LDA.w DATA_02A15F,x
endif
	EOR.b !RAM_SMW_Misc_ScratchRAM00
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	LDX.b !RAM_SMW_Misc_ScratchRAM01	;\Draw the sprite in front or behind
	BEQ.b CODE_02A204		;|layer depending if it is behind the
	AND.b #$CF			;|layer or not
	ORA.b #$10			;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
CODE_02A204:
	TYA				;\8x8 sprite
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$00			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

EraseSprite:
	LDA.b #$00			; \ Clear extended sprite
	STA.w !RAM_SMW_ExtSpr_SpriteID,x
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_GenericExtendedSpriteGFXRt(Address)
namespace SMW_GenericExtendedSpriteGFXRt
%InsertMacroAtXPosition(<Address>)

; Fireball tile table
FireballTiles:
	db $2C,$2D,$2C,$2D

; Mario's fireball tiles' flip/priority/palette/GFX page, YXPPCCCT format
; (May also affect the small flame left by Hopping Flame).
DATA_02A15F:
	db $04,$04,$C4,$C4
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckForMarioToExtendedSpriteCollision(Address)
namespace SMW_CheckForMarioToExtendedSpriteCollision
%InsertMacroAtXPosition(<Address>)

; Extended sprite/player contact check and interaction subroutine. $02A412
; is the extended sprite interaction for the bonus game cloud. $02A469 is
; the default extended sprite interaction to hurt Mario. $02A4B3 is the
; speed Yoshi runs away when Mario gets hurt by an extended sprite and while
; he is riding yoshi (index: right, left). Change $02A4B3 from [10 F0] to
; [18 E8] to fix an inconsistency where Yoshi runs slower when hurt from an
; extended sprite than hurt from a regular sprite.
Main:
	LDA.w !RAM_SMW_Player_CurrentLayerPriority	;\Mario and extended sprite on different planes
	EOR.w !RAM_SMW_ExtSpr_Table7E1779,x	;|(one of them behind layers), then ignore
	BNE.b Return02A468		;/
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping	;>Get hitbox of cape
	JSR.w SMW_GetExtendedSpriteClipping_Main	;>Get hitbox of extended sprite
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact	;>Check contact
	BCC.b Return02A468		;>Do nothing of no contact
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x	;\If not a coin from the coin cloud game
	CMP.b #!Define_SMW_SpriteID_ExtSpr0A_CloudCoin	;|
	BNE.b CODE_02A469		;/
	JSL.l SMW_GiveCoins_OneCoin	;>If so and was hit by cape, then player collects the coin
	INC.w !RAM_SMW_Counter_PinkBerryCloudCoins	;>Increase the cloud coin collection count
	STZ.w !RAM_SMW_ExtSpr_SpriteID,x	; Clear extended sprite
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot
ADDR_02A41E:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y
	BEQ.b ADDR_02A427
	DEY
	BPL.b ADDR_02A41E
	INY				;>Increment the smoke slot from -1 to 0
ADDR_02A427:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr05_Glitter	;\Generate smoke
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y	;|
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;|
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y	;|
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;|
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y	;|
	LDA.b #$0A			;|
	STA.w !RAM_SMW_SmokeSpr_Timer,y	;/
	JSL.l SMW_CheckForAvailableScoreSpriteSlot_Main	;>Index score sprite
	LDA.b #$05			;\Spawn score sprite
	STA.w !RAM_SMW_ScoreSpr_SpriteID,y	;|
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;|
	STA.w !RAM_SMW_ScoreSpr_YPosLo,y	;|
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x	;|
	STA.w !RAM_SMW_ScoreSpr_YPosHi,y	;|
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;|
	STA.w !RAM_SMW_ScoreSpr_XPosLo,y	;|
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x	;|
	STA.w !RAM_SMW_ScoreSpr_XPosHi,y	;|
	LDA.b #$30			;|
	STA.w !RAM_SMW_ScoreSpr_YSpeed,y	;|
	LDA.b #$00			;|
	STA.w !RAM_SMW_ScoreSpr_LayerIndex,y	;/
Return02A468:
	RTS

CODE_02A469:
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario has star
	BNE.b CODE_02A4B5
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_02A4AE
LoseYoshi:
	PHX
	LDX.w !RAM_SMW_Sprites_YoshiSlotIndex
	LDA.b #$10							; Glitch: Setting !RAM_SMW_Player_InAirFlag to #$24 here would fix the zip bug while in the Iggy/Larry boss fight
	STA.w !RAM_SMW_NorSpr035_Yoshi_DisableSpriteInteraction-$01,x
	LDA.b #!Define_SMW_Sound1DFA_TurnOffYoshiDrum	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
	LDA.b #!Define_SMW_Sound1DFC_LoseYoshi	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$02
	STA.b !RAM_SMW_NorSpr035_Yoshi_CurrentState-$01,x
	STZ.w !RAM_SMW_Player_RidingYoshiFlag
	STZ.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	LDA.b #$C0
	STA.b !RAM_SMW_Player_YSpeed
	STZ.b !RAM_SMW_Player_XSpeed
	LDY.w !RAM_SMW_NorSpr_FacingDirection-$01,x
	LDA.w YoshiXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed-$01,x
	STZ.w !RAM_SMW_NorSpr035_Yoshi_CurrentMouthState-$01,x
	STZ.w !RAM_SMW_NorSpr035_Yoshi_CurrentTongueLength-$01,x
	STZ.w !RAM_SMW_Timer_YoshiTongueInit
	LDA.b #$30
	STA.w !RAM_SMW_Timer_PlayerHurt
	PLX
	RTS

CODE_02A4AE:
	JSL.l SMW_DamagePlayer_Hurt
	RTS

YoshiXSpeed:
	db $10,$F0

CODE_02A4B5:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x
	CMP.b #!Define_SMW_SpriteID_ExtSpr04_Hammer
	BEQ.b CODE_02A4DE
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x
	SEC
	SBC.b #$04
	STA.w !RAM_SMW_ExtSpr_XPosLo,x
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_ExtSpr_XPosHi,x
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x
	SEC
	SBC.b #$04
	STA.w !RAM_SMW_ExtSpr_YPosLo,x
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,x
CODE_02A4DE:
	LDA.b #$07
CODE_02A4E0:
	STA.w !RAM_SMW_ExtSpr_DecrementingTable7E176F,x
	LDA.b #!Define_SMW_SpriteID_ExtSpr01_SmokePuff
	STA.w !RAM_SMW_ExtSpr_SpriteID,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GetExtendedSpriteClipping(Address)
namespace SMW_GetExtendedSpriteClipping
%InsertMacroAtXPosition(<Address>)

; X-offsets for extended sprites $02-$0D's clipping. 12 bytes and they're in
; that order.
DATA_02A4E9:
	db $03,$03,$04,$03,$04,$00
	db $00,$00,$04,$03,$03,$03

; Y-offsets for extended sprites $02-$0D's clipping. 12 bytes and they're in
; that order.
DATA_02A4F3:
	db $03,$03,$04,$03,$04,$00
	db $00,$00,$02,$03,$03,$03

; Width for extended sprites $02-$0D's clipping. 12 bytes and they're in
; that order. Value may not exceed $7F. The clipping 'stretches' from the
; sprite's origin to the right.
DATA_02A4FF:
	db $01,$01,$08,$01,$08,$00
	db $00,$0F,$08,$01,$01,$01

; Height for extended sprites $02-$0D's clipping. 12 bytes and they're in
; that order. Value may not exceed $7F. The clipping 'stretches' from the
; sprite's origin to below.
DATA_02A50B:
	db $01,$01,$08,$01,$08,$00
	db $00,$0F,$0C,$01,$01,$01

; Get extended sprite clipping routine, for extended sprites $02-$0D (for
; Mario and Yoshi's fireballs, see $02A547). It stores the clipping X
; displacement low byte in $04, X displacement high byte in $0A, Y
; displacement low byte in $05, Y displacement high byte in $0B, width in
; $06, height in $07 (so it's equivalent to the "Get sprite clipping A"
; routine). Inputs: - X: extended sprite slot - Data Bank: $02 Y is modified
; by the routine, so it should be preserved before calling it if needed.
Main:
	LDY.w !RAM_SMW_ExtSpr_SpriteID,x
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x
	CLC
	ADC.w DATA_02A4E9-$02,y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w DATA_02A4FF-$02,y
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x
	CLC
	ADC.w DATA_02A4F3-$02,y
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.w DATA_02A50B-$02,y
	STA.b !RAM_SMW_Misc_ScratchRAM07
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_SetNormalSpriteYSpeedBasedOnSlope(Address)
namespace SMW_SetNormalSpriteYSpeedBasedOnSlope
%InsertMacroAtXPosition(<Address>)

Bank02:

	%INLINEROUTINE_SMW_SetNormalSpriteYSpeedBasedOnSlope()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_FindFreeNormalSpriteSlot(Address)
namespace SMW_FindFreeNormalSpriteSlot
%InsertMacroAtXPosition(<Address>)

; Routine to find an empty sprite slot, starting from the highest usable
; slot, minus 2. Returns it in Y. Exclusively used for generators, since
; they don't always need to spawn a sprite. In reality this just sets $0E to
; 2 and then jumps to $02A9E6.
LowPriority:
	LDA.b #!Define_SMW_StockMaxNormalSpriteSlot-$09	; \ Number of slots to leave free = 2
if defined("Define_SMW_SA1")
	; SA-1 Pack: FindFreeSlotLowPri is used by generators in SMW and they all
	; immediately copy the returned index in y to x and start using it to
	; index sprite tables, so hijack it to change the pointer as well.
	JML.l FIND_SPRITE_SLOT_SET
else
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	BRA.b CODE_02A9E6
endif

; Routine to search for free spite slot within the standard sprite slot
; region (as defined by the sprite memory setting). Jumping to $02A9E6 will
; alternatively start searching from the highest available slot minus
; whatever value is in $0E (e.g. if the standard range is 1-9 and $0E =
; 0x03, then it will search only slots 1-6). For a value of 0x02, jump to
; $02A9DE instead.
HighPriority:
	STZ.b !RAM_SMW_Misc_ScratchRAM0E	; Number of slots tp leave free = 0
CODE_02A9E6:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	TYA
	RTL

Sub:
	LDY.w !RAM_SMW_Sprites_SpriteMemorySetting	; \ Subroutine: Return the first free sprite slot in Y (#$FF if not found)
	LDA.w SMW_ParseLevelSpriteList_SpriteSlotStart,y	; | Y = Sprite memory index
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.w SMW_ParseLevelSpriteList_SpriteSlotMax,y
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0E
	TAY
CODE_02A9FE:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	; | If free slot...
	BEQ.b Return02AA0A		; |  ...return
	DEY
	CPY.b !RAM_SMW_Misc_ScratchRAM0F
	BNE.b CODE_02A9FE
	LDY.b #!NullSpriteSlot		; | If no free slots, Y=#$FF
Return02AA0A:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleCapeInteraction(Address)
namespace SMW_HandleCapeInteraction
%InsertMacroAtXPosition(<Address>)

; Routine that processes capespin interaction with sprites, extended
; sprites, and blocks.
Main:
	LDA.w !RAM_SMW_Flag_CapeToSpriteInteraction	;\Cape interaction flag
	BEQ.b Return02950A		;/
	STA.b !RAM_SMW_Misc_ScratchRAM0E	;>Indicate that its not a bounce block
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\If bit 0 (moved to carry) is clear, skip 1st 2 JSRs
	LSR				;|
	BCC.b CODE_029507		;/
	JSR.w SMW_CheckForPlayerAttackToNormalSpriteCollision_CapeSwingEntry	;>interact with sprites (Knock like a bounce block)
	JSR.w SMW_HandleCapeToExtendedSpriteCollision_Main	;>Interact with extended sprites
CODE_029507:
#LMBlockOffset_MarioCape:
	JSR.w SMW_HandleCapeLevelCollision_Main	;>Interact with blocks
Return02950A:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_HandleCapeLevelCollision(Address)
namespace SMW_HandleCapeLevelCollision
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	JSR.w CODE_029540
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	BPL.b Return02953B
	INC.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.w !RAM_SMW_Player_CapeHitboxXLo
	CLC
	ADC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo
	STA.w !RAM_SMW_Player_CapeHitboxXLo
	LDA.w !RAM_SMW_Player_CapeHitboxXHi
	ADC.b !RAM_SMW_Misc_SecondLevelLayerXPosHi
	STA.w !RAM_SMW_Player_CapeHitboxXHi
	LDA.w !RAM_SMW_Player_CapeHitboxYLo
	CLC
	ADC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo
	STA.w !RAM_SMW_Player_CapeHitboxYLo
	LDA.w !RAM_SMW_Player_CapeHitboxYHi
	ADC.b !RAM_SMW_Misc_SecondLevelLayerYPosHi
	STA.w !RAM_SMW_Player_CapeHitboxYHi
	JSR.w CODE_029540
Return02953B:
	RTS

DATA_02953C:
	db $08,$08

DATA_02953E:
	db $02,$0E

CODE_029540:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	INC
	AND.b !RAM_SMW_Misc_LevelLayoutFlags
	BEQ.b CODE_0295AE
	LDA.w !RAM_SMW_Player_CapeHitboxYLo
	CLC
	ADC.w DATA_02953C,y
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_Player_CapeHitboxYHi
	ADC.b #$00
	CMP.b !RAM_SMW_Misc_ScreensInLvl
	BCS.b Return0295AD
	STA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.w !RAM_SMW_Player_CapeHitboxXLo
	CLC
	ADC.w DATA_02953E,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_Player_CapeHitboxXHi
	ADC.b #$00
	CMP.b #$02
	BCS.b Return0295AD
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_029596
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L2,x
CODE_029596:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_0295A7
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L2,x
CODE_0295A7:
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06
	BRA.b CODE_02960D

Return0295AD:
	RTS

CODE_0295AE:
	LDA.w !RAM_SMW_Player_CapeHitboxYLo
	CLC
	ADC.w DATA_02953C,y
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_Player_CapeHitboxYHi
	ADC.b #$00
	CMP.b #$02
	BCS.b Return0295AD
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.w !RAM_SMW_Player_CapeHitboxXLo
	CLC
	ADC.w DATA_02953E,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_Player_CapeHitboxXHi
	ADC.b #$00
	CMP.b !RAM_SMW_Misc_ScreensInLvl
	BCS.b Return0295AD
	STA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_0295F8
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L2,x
CODE_0295F8:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_029609
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L2,x
CODE_029609:
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06
CODE_02960D:
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	INC.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
#LM000Hijack_ProcessCustomCapeBlockCode:
	JSL.l SMW_ModifyMap16IDForSpecialBlocks_Main
	CMP.b #$00
	BEQ.b Return029630
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	STA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	LDY.b #$00
	JSL.l SMW_CheckIfBlockWasHit_Main
Return029630:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_HandleCapeToExtendedSpriteCollision(Address)
namespace SMW_HandleCapeToExtendedSpriteCollision
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #!Define_SMW_MaxExtendedSpriteSlot-$02
CODE_029633:
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x	;\If extended sprite numbers  is less than 2,
	CMP.b #!Define_SMW_SpriteID_ExtSpr02_ReznorFireball	;|next index
	BCC.b CODE_029653		;/
	JSR.w SMW_GetExtendedSpriteClipping_Main	;>Get hitbox of extended sprites (A)
	JSR.w SMW_CheckForPlayerAttackToNormalSpriteCollision_GetCapeSwingOrNetPunchClipping	;>Get cape hitbox (B)
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact	;>Check contact
	BCC.b CODE_029653		;>If no contact, check other sprite index
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x	;\If extended sprite = water bubble,
	CMP.b #!Define_SMW_SpriteID_ExtSpr12_BreathBubble	;|next slot
	BEQ.b CODE_029653		;/
	JSR.w SMW_CheckForMarioToExtendedSpriteCollision_CODE_02A4DE	;>Alter extended sprite
CODE_029653:
	DEX
	BPL.b CODE_029633
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_SpawnSparkles(Address)
namespace SMW_SpawnSparkles
%InsertMacroAtXPosition(<Address>)

; Star Sparkle GFX Subroutine (Doesn't make Mario invincible, but shows
; sparkles.) $0285BA is where the Sprite/Block Star Sparkle GFX Subroutine
; starts (which is also used for Mario).
PlayerEntry:
	LDY.b #$1F			; \ If Big Mario:
	LDX.b #$00			; | Y = #$1F
	LDA.b !RAM_SMW_Player_CurrentPowerUp	; | X = #$00
	BNE.b CODE_02859B		; | Small Mario:
	LDY.b #$0F			; | Y = #$0F
	LDX.b #$10			; / X = #$10
CODE_02859B:
	STX.b !RAM_SMW_Misc_ScratchRAM01
	JSL.l SMW_GetRand_Main
	TYA
	AND.w !RAM_SMW_Misc_RandomByte1
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Misc_RandomByte2
	AND.b #$0F
	CLC
	ADC.b #$FE
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
Main:
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot
CODE_0285BC:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y
	BEQ.b CODE_0285C5
	DEY
	BPL.b CODE_0285BC
	RTL

CODE_0285C5:
	LDA.b #!Define_SMW_SpriteID_MExtSpr05_SmallStar
	STA.w !RAM_SMW_MExtSpr_SpriteID,y
	LDA.b #$00
	STA.w !RAM_SMW_MExtSpr_YSpeed,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_MExtSpr_YPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_MExtSpr_XPosLo,y
	LDA.b #$17
	STA.w !RAM_SMW_MExtSpr_Timer,y
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleHeldPBalloonAndInLakituCloudMovement(Address)
namespace SMW_HandleHeldPBalloonAndInLakituCloudMovement
%InsertMacroAtXPosition(<Address>)

XAcceleration:
	db $01,$FF				;\ Glitch: The code referencing these tables doesn't account for holding left+right at the same time.
						;| Doing so causes the X acceleration value to be $10 and the max X speed to be A5 (although it gets capped to 7F)
; [10] {+16} Horizontal speed limit when pressing Right from the Control
; Pad, when Mario uses the P-balloon or rides the Lakitu cloud. The speed is
; a signed integer. Positive speeds (00..7F) go right. High speeds might
; cause glitches, like allowing Mario to fly inside solid blocks.
MaxXSpeed:					;|
	db $10,$F0				;/

Main:
	LDA.b !RAM_SMW_IO_ControllerHold1	; \ A = flags for left and right from Control Pad
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)	; /     ($01 right, $02 left)
	BNE.b CscGoLeftOrRight		; Branch if player pressing left or right
CscSlowSpeedX:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b CODE_02D226
	BPL.b CODE_02D224
	INC.b !RAM_SMW_NorSpr_XSpeed,x
	INC.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02D224:
	DEC.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02D226:
	BRA.b CscDecideY		; Skip ahead

CscGoLeftOrRight:
	TAY				; Y = flags ($01 right, $02 left)
	CPY.b #!Joypad_DPadR>>8		; \ Branch if player not pressing right
	BNE.b CscGoRight		; /
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	; \ (A = X_speed) <=> -16
	CMP.w MaxXSpeed-$01,y		; /
	BEQ.b CscDecideY		; Branch if ==
	BPL.b CscSlowSpeedX		; Branch if >
	BRA.b CscUnderLimitX		; Branch if <

CscGoRight:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	; \ (A = X_speed) <=> 16
	CMP.w MaxXSpeed-$01,y		; /
	BEQ.b CscDecideY		; Branch if ==
	BMI.b CscSlowSpeedX		; Branch if <
CscUnderLimitX:
	CLC				; \ Sprite is under the speed limit
	ADC.w XAcceleration-$01,y	;  |Increment speed if pressing right
	STA.b !RAM_SMW_NorSpr_XSpeed,x	; / Decrement speed if pressing left
CscDecideY:
	LDY.b #$00			; Y = 0
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch unless sprite is Lakitu cloud
	CMP.b #!Define_SMW_SpriteID_NorSpr087_LakituCloud	;  |
	BNE.b CscNotLakituCloud		; /
	LDA.b !RAM_SMW_IO_ControllerHold1	; \ A = flags for up and down from Control Pad
	AND.b #(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)	; /     ($04 down, $08 up)
	BEQ.b CscHandleY		; Branch if player NOT pressing up or down
	LDY.b #$10			; Y = +16
	AND.b #!Joypad_DPadU>>8		; \ Branch if player pressing down
	BEQ.b CscHandleY		; /
	LDY.b #$F0			; Y = -16
	BRA.b CscHandleY		; Player pressing up

CscNotLakituCloud:
	LDY.b #$F8			; Y = -8
	LDA.b !RAM_SMW_IO_ControllerHold1	; \ A = flags for up and down from Control Pad
	AND.b #(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)	; /     ($04 down, $08 up)
	BEQ.b CscHandleY		; Branch if player NOT pressing up or down
	LDY.b #$F0			; Y = -16
	AND.b #!Joypad_DPadU>>8		; \ Branch if player pressing up
	BNE.b CscHandleY		; /
	LDY.b #$08			; Y = +8
CscHandleY:
	STY.b !RAM_SMW_Misc_ScratchRAM00	; \ Y_speed <=> register Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;  |
	CMP.b !RAM_SMW_Misc_ScratchRAM00	; /
	BEQ.b CODE_02D27F
	BPL.b CODE_02D27D
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	INC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02D27D:
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02D27F:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x	; \ Set the X_speed and the Y_speed of Mario
	STA.b !RAM_SMW_Player_XSpeed	;  |to the speed of the sprite, so that
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;  |Mario stays with the sprite.
	STA.b !RAM_SMW_Player_YSpeed	; /
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnMap16TileFromBounceSprite(Address)
namespace SMW_SpawnMap16TileFromBounceSprite
%InsertMacroAtXPosition(<Address>)

UNK_02919D:
	db $01,$00

; Subroutine used to changed the tile at the current bounce sprite's
; position. Contains a few different entry points: $02919F: The code which
; loads the currently assigned block the bounce sprite should turn into ($9C
; format) and handles whether a multiple coins block should turn into a used
; block. Called when a bounce sprite terminates and becomes a normal block
; again. $0291B8: Spawns an invisible solid block. This is called when a
; bounce sprite has just spawned but also when the bounce sprite collects a
; coin, leading to the solid air tile glitch (see $029265). $0291BA: Spawns
; a tile according to the value in A ($9C format). This is called from
; spinning turn blocks when they become solid.
MultiCoinBlock:
	LDA.w !RAM_SMW_BounceSpr_Map16TileToSpawn,x	; \ If doesn't turn into multiple coin block,
	CMP.b #$0A
	BEQ.b CODE_0291AA
	CMP.b #$0B
	BNE.b CODE_0291B6		; / Block to generate = Bounce sprite block to turn into
CODE_0291AA:
	LDY.w !RAM_SMW_Blocks_MultiCoinBlockTimer
	CPY.b #$01
	BNE.b CODE_0291B6
	STZ.w !RAM_SMW_Blocks_MultiCoinBlockTimer
	LDA.b #$0D			; Block to generate = Used block
CODE_0291B6:
	BRA.b Main

InvisibleSolidBlock:
	LDA.b #$09			; Block to generate = Invisible solid
Main:
	STA.b !RAM_SMW_Blocks_Map16ToGenerate	; Set block to generate
	LDA.w !RAM_SMW_BounceSpr_XPosLo,x	; \ Block Y position = Bounce sprite Y position
	CLC
	ADC.b #$08			; | (Rounded to nearest #$10)
	AND.b #$F0
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_BounceSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.w !RAM_SMW_BounceSpr_YPosLo,x	; \ Block X position = Bounce sprite X position
	CLC
	ADC.b #$08			; | (Rounded to nearest #$10)
	AND.b #$F0
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_BounceSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.w !RAM_SMW_BounceSpr_Properties,x
	ASL
	ROL
	AND.b #$01
	STA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	JSL.l SMW_GenerateTile_Main
Return0291EC:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BounceSpriteGFXRt(Address)
namespace SMW_BounceSpriteGFXRt
%InsertMacroAtXPosition(<Address>)

; OAM indexes for block bounce sprites (in the $0200 block).
OAMIndex:
	db $10,$14,$18,$1C

; Block bounce sprite tiles. $40 - Turn Block (not turning). $6B - Note
; Block. $2A - ?-Block. $42 - Unused Side Bounce Turn Block (change to $40
; to fix the wrong tile that appears when hitting these blocks). $EA - Glass
; Block. $8A - ON/OFF Block. $40 - Turn Block (turning). Note that changing
; this will only affect the tile that appears before the block starts
; spinning.
Tiles:
	db $40			; Turn Block
	db $6B			; Note Block
	db $2A			; ? Block
	db $42			; Sideways Block (Glitch: Should be $40, as this displays the P-switch tile)
	db $EA			; Glass Block
	db $8A			; On/Off Block
	db $40			; Spinning Turn Block

Main:
	LDY.b #$00
	LDA.w !RAM_SMW_BounceSpr_Properties,x
	BPL.b CODE_029201
	LDY.b #$04
CODE_029201:
	LDA.w !RAM_SMW_Mirror_CurrentLayer1YPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Mirror_CurrentLayer1XPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_Mirror_CurrentLayer1YPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_Mirror_CurrentLayer1XPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_BounceSpr_YPosLo,x
	CMP.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_BounceSpr_YPosHi,x
	SBC.b !RAM_SMW_Misc_ScratchRAM04
	BNE.b SMW_SpawnMap16TileFromBounceSprite_Return0291EC
	LDA.w !RAM_SMW_BounceSpr_XPosLo,x
	CMP.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_BounceSpr_XPosHi,x
	SBC.b !RAM_SMW_Misc_ScratchRAM05
	BNE.b SMW_SpawnMap16TileFromBounceSprite_Return0291EC
	LDY.w OAMIndex,x
	LDA.w !RAM_SMW_BounceSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w !RAM_SMW_BounceSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_BounceSpr_YXPPCCCT,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	LDA.w !RAM_SMW_BounceSpr_SpriteID,x
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles-$01,x
else
	LDA.w Tiles-$01,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_AimTowardsPlayer(Address)
namespace SMW_AimTowardsPlayer
%InsertMacroAtXPosition(<Address>)

Bank02:
	%INLINEROUTINE_SMW_AimTowardsPlayer(Bank02)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnWaterSplash(Address)
namespace SMW_SpawnWaterSplash
%InsertMacroAtXPosition(<Address>)

CODE_0284A6:
	STA.b !RAM_SMW_Misc_ScratchRAM03	;>Set $03
	LDA.b #$02			;\Set $01 to #$02
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
CODE_0284AC:
	JSL.l CODE_0284D8
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC				;\adds by whats in $03
	ADC.b !RAM_SMW_Misc_ScratchRAM03	;/
	STA.b !RAM_SMW_Misc_ScratchRAM02	;>And store it back into $02
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;>And decrement $01 by 1
	BPL.b CODE_0284AC		;>If 0 or positive, branch (loop)
	RTL

; Water Splash Subroutine
VerticalCheepCheepEntry:
	LDA.b #$12
	BRA.b CODE_0284C2

Main:
	LDA.b #$00
CODE_0284C2:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM02	;>Clear another scratch ram
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	;\If sprite is dolphin, branch
	CMP.b #!Define_SMW_SpriteID_NorSpr041_LongJumpDolphin	;|
	BEQ.b CODE_0284D0		;/
	CMP.b #!Define_SMW_SpriteID_NorSpr042_ShortJumpDolphin	;\If sprite is another dolphin, branch
	BNE.b CODE_0284D8		;/
CODE_0284D0:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	;\If sprite is going downwards or not moving vertically, return
	BPL.b Return0284E7		;/
	LDA.b #$0A			;>A = #$0A
	BRA.b CODE_0284A6

CODE_0284D8:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_CopyOfBank02	;>Off screen check
	BNE.b Return0284E7		;>If not zero, return
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot	;Y = #$0B
CODE_0284DF:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y	;>Minor extended sprite number
	BEQ.b CODE_0284E8		;>If none exist, branch
	DEY				;\Otherwise look for other slots
	BPL.b CODE_0284DF		;/
Return0284E7:
	RTL

CODE_0284E8:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	;\Set Y pos of minor extended sprite
	CLC				;|based on main sprite
	ADC.b #$00			;|
	AND.b #$F0			;|
	CLC				;|
	ADC.b #$03			;|
	STA.w !RAM_SMW_MExtSpr_YPosLo,y	;|
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;|
	CLC				;|
	ADC.b !RAM_SMW_Misc_ScratchRAM02	;|
	STA.w !RAM_SMW_MExtSpr_XPosLo,y	;|
	LDA.w !RAM_SMW_NorSpr_XPosHi,x	;/
	ADC.b #$00			;\x position
	STA.w !RAM_SMW_MExtSpr_XPosHi,y	;/
	LDA.b #!Define_SMW_SpriteID_MExtSpr07_WaterSplash	;\Extended sprite number = water splash
	STA.w !RAM_SMW_MExtSpr_SpriteID,y	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\Set exist timer
	STA.w !RAM_SMW_MExtSpr_Timer,y	;/
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_SpawnBrickPieces(Address)
namespace SMW_SpawnBrickPieces
%InsertMacroAtXPosition(<Address>)

; Block shatter subroutine. This creates 4 block pieces and plays the
; shatter sound effect, but it does not actually destroy the block; use
; $00BEB0 for that. If A is 00 when calling this, the pieces will be brown
; (e.g. a turnblock), otherwise they will flash palettes (e.g. a
; throwblock). It uses $98-$9B to set the X/Y position, though note that you
; may want to make sure this position is centered on the block first (set
; the low nibble of $98/$9A to 0). Additionally, although this is a JSL
; routine, the data bank must be set to 02 prior to calling.
Main:
	PHX
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b #$03
	LDX.b #!Define_SMW_MaxMinorExtendedSpriteSlot
CODE_02866A:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,x
	BEQ.b CODE_02867F
CODE_02866F:
	DEX
	BPL.b CODE_02866A
	DEC.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
	BPL.b CODE_02867C
	LDA.b #!Define_SMW_MaxMinorExtendedSpriteSlot
	STA.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
CODE_02867C:
	LDX.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
CODE_02867F:
	LDA.b #!Define_SMW_Sound1DFC_BreakBlock
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b #!Define_SMW_SpriteID_MExtSpr01_BrickPiece
	; Change to EA EA EA to disable the Turn Block shattering animation (turn
	; blocks disappear when spin jumped). Also affects sprite 4C.
	STA.w !RAM_SMW_MExtSpr_SpriteID,x
	LDA.b !RAM_SMW_Blocks_XPosLo
	CLC
	ADC.w InitialXPosLo,y
	STA.w !RAM_SMW_MExtSpr_XPosLo,x
	LDA.b !RAM_SMW_Blocks_XPosHi
	ADC.b #$00
	STA.w !RAM_SMW_MExtSpr_XPosHi,x
	LDA.b !RAM_SMW_Blocks_YPosLo
	CLC
	ADC.w InitialYPosLo,y
	STA.w !RAM_SMW_MExtSpr_YPosLo,x
	LDA.b !RAM_SMW_Blocks_YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_MExtSpr_YPosHi,x
	LDA.w InitialYSpeed,y
	STA.w !RAM_SMW_MExtSpr_YSpeed,x
	LDA.w InitialXSpeed,y
	STA.w !RAM_SMW_MExtSpr_XSpeed,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_MExtSpr_Timer,x
	DEY
	BPL.b CODE_02866F
	PLX
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_SpawnBrickPieces(Address)
namespace SMW_SpawnBrickPieces
%InsertMacroAtXPosition(<Address>)

; Y offsets of each shatter particle (when spawned through $028663).
InitialYPosLo:
	db $00,$00,$08,$08

; X offsets of each shatter particle (when spawned through $028663)
InitialXPosLo:
	db $00,$08,$00,$08

; Initial Y speeds of each shatter particle (when spawned through $028663)
InitialYSpeed:
	db $FB,$FB,$FD,$FD

; Initial X speeds of each shatter particle (when spawned through $028663)
InitialXSpeed:
	db $FF,$01,$FF,$01
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_ProcessMinorExtendedSprites(Address)
namespace SMW_ProcessMinorExtendedSprites
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #!Define_SMW_MaxMinorExtendedSpriteSlot
CODE_028B69:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,x
	BEQ.b CODE_028B74
	STX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	JSR.w CODE_028B94
CODE_028B74:
	DEX
	BPL.b CODE_028B69
Return:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ProcessMinorExtendedSprites_Return, SMW_MExtSpr00_Unused_Main)
endmacro

macro ROUTINE_RT01_SMW_ProcessMinorExtendedSprites(Address)
namespace SMW_ProcessMinorExtendedSprites
%InsertMacroAtXPosition(<Address>)

CODE_028B94:
if !SMW_CustomSprites_MinorExtendedWanted == !TRUE
	; The same four bytes as the trampoline call, only where the rows
	; name a custom minor extended sprite. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_MinorExtended
else
	JSL.l SMW_ExecutePtr_Absolute
endif

MinorExtendedSpritesPtrs:
base $000000
; Minor extended sprite pointer table, 2 bytes per sprite.
.MExtSpr00_Unused:		dw SMW_MExtSpr00_Unused_Main
.MExtSpr01_BrickPiece:		dw SMW_MExtSpr01_BrickPiece_Main
.MExtSpr02_SmallStar:		dw SMW_MExtSpr02_SmallStar_Main
.MExtSpr03_EggShell:		dw SMW_MExtSpr03_EggShell_Main
.MExtSpr04_PodobooFire:		dw SMW_MExtSpr04_PodobooFire_Main
.MExtSpr05_SmallStar:		dw SMW_MExtSpr05_SmallStar_Main
.MExtSpr06_RipVanFishZ:		dw SMW_MExtSpr06_RipVanFishZ_Main
.MExtSpr07_WaterSplash:		dw SMW_MExtSpr07_WaterSplash_Main
.MExtSpr08_UnusedMusicNote:	dw SMW_MExtSpr08_UnusedMusicNote_Main
.MExtSpr09_UnusedMusicNote:	dw SMW_MExtSpr09_UnusedMusicNote_Main
.MExtSpr0A_BooStream:		dw SMW_MExtSpr0A_BooStream_Main
.MExtSpr0B_UnusedYoshiSmoke:	dw SMW_MExtSpr0B_UnusedYoshiSmoke_Main
base off
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_ProcessBounceAndSmokeSprites(Address)
namespace SMW_ProcessBounceAndSmokeSprites
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_Blocks_MultiCoinBlockTimer	;\If multiple coin block timer
	CMP.b #$02			;|is less than #$02 (waiting till the last hit before brown)
	BCC.b CODE_02903B		;/then don't decrement
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\Timer shall freeze if $9D is set
	BNE.b CODE_02903B		;/
	DEC.w !RAM_SMW_Blocks_MultiCoinBlockTimer	;>Decrement timer
CODE_02903B:
	LDX.b #!Define_SMW_MaxBounceSpriteSlot	;>Start index loop
CODE_02903D:
	STX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite	;>Write bounce block index current processed
	JSR.w BounceSprites		;>Determine the type of bounce block
	JSR.w SMW_CheckForPlayerAttackToNormalSpriteCollision_Main	;>Interaction
	JSR.w SmokeSprites		;>Not sure if ninendo merged extended sprites with bounce blocks...
	DEX				;>Next index
	BPL.b CODE_02903D		;>Keep looping until slot is invalid
Return02904C:
	RTS

BounceSprites:
	LDA.w !RAM_SMW_BounceSpr_SpriteID,x
	BEQ.b Return02904C
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02905E
	LDY.w !RAM_SMW_BounceSpr_Timer,x	; \ Decrement bounce sprite timer if > 0
	BEQ.b CODE_02905E
	DEC.w !RAM_SMW_BounceSpr_Timer,x
CODE_02905E:
if !SMW_CustomSprites_BounceWanted == !TRUE
	; The same four bytes as the trampoline call, only where the rows
	; name a custom bounce sprite. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Bounce
else
	JSL.l SMW_ExecutePtr_Absolute
endif

BounceSpritePtrs:
base ($000000)
.BounceSpr00_Unused:			dw SMW_BounceSpr00_Unused_Main	; 00 - Nothing (Bypassed above)
.BounceSpr01_TurnBlock:			dw SMW_BounceSpr01_TurnBlock_Main	; 01 - Turn Block without turn
.BounceSpr02_NoteBlock:			dw SMW_BounceSpr02_NoteBlock_Main	; 02 - Music Block
.BounceSpr03_QuestionBlock:		dw SMW_BounceSpr03_QuestionBlock_Main	; 03 - Question Block
.BounceSpr04_SidewaysMovingBlock:	dw SMW_BounceSpr04_SidewaysMovingBlock_Main	; 04 - Sideways Bounce Block
.BounceSpr05_GlassBlock:		dw SMW_BounceSpr05_GlassBlock_Main	; 05 - Translucent Block
.BounceSpr06_OnOffBlock:		dw SMW_BounceSpr06_OnOffBlock_Main	; 06 - On/Off Block
.BounceSpr07_SpinningTurnBlock:		dw SMW_BounceSpr07_SpinningTurnBlock_Main	; 07 - Turn Block
base off

namespace off
	%SetDuplicateOrNullPointer(SMW_ProcessBounceAndSmokeSprites_Return02904C, SMW_BounceSpr00_Unused_Main)
endmacro

macro ROUTINE_RT01_SMW_ProcessBounceAndSmokeSprites(Address)
namespace SMW_ProcessBounceAndSmokeSprites
%InsertMacroAtXPosition(<Address>)

SmokeSprites:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,x	;\If extended sprite is free, return
	BEQ.b Return0296D7		;/
	AND.b #$7F			;>Clear bit 7 (value from #$00 to #$7F)
if !SMW_CustomSprites_SmokeWanted == !TRUE
	; The same four bytes as the trampoline call, only where the rows
	; name a custom smoke sprite. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Smoke
else
	JSL.l SMW_ExecutePtr_Absolute	;>Pointer
endif

SmokeSpritePtrs:
base $000000
; Pointer to the smoke images. ($7E:17F0 - $7E:17FB)
.SmokeSpr00_Unused:			dw SMW_SmokeSpr00_Unused_Main
.SmokeSpr01_PuffOfSmoke:		dw SMW_SmokeSpr01_PuffOfSmoke_Main
.SmokeSpr02_ContactEffect:		dw SMW_SmokeSpr02_ContactEffect_Main
.SmokeSpr03_TurnAroundSmoke:		dw SMW_SmokeSpr03_TurnAroundSmoke_Main
.SmokeSpr04_Unused:			dw SMW_SmokeSpr04_Unused_Main
.SmokeSpr05_Glitter:			dw SMW_SmokeSpr05_Glitter_Main
base off

Return0296D7:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ProcessBounceAndSmokeSprites_Return0296D7, SMW_SmokeSpr00_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ProcessBounceAndSmokeSprites_Return0296D7, SMW_SmokeSpr04_Unused_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_CheckForPlayerAttackToNormalSpriteCollision(Address)
namespace SMW_CheckForPlayerAttackToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

DATA_029392:
	db $F8,$08

CODE_029394:
	STZ.w !RAM_SMW_BounceSpr_Type,x
Return029397:
	RTS

Main:
	LDA.w !RAM_SMW_BounceSpr_Type,x	;\If bounce slot free, return
	BEQ.b Return029397		;/
	DEC.w !RAM_SMW_BounceSpr_InteractTimer,x	;>Decrease interaction timer
	BEQ.b CODE_029394		;>If zero, erase self
	LDA.w !RAM_SMW_BounceSpr_InteractTimer,x	;\if bounce slot timer > $03,
	CMP.b #$03			;|return with no interaction
	BCS.b SMW_GetBounceSpriteLevelCollisionMap16ID_Return029391	;/
	LDY.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite	;>Load curent slot index for current processing slot into Y
	STZ.b !RAM_SMW_Misc_ScratchRAM0E	;>Clear $0E (bounce sprite mode, not cape)
CapeSwingEntry:
	LDX.b #!Define_SMW_MaxNormalSpriteSlot	;>Start sprite slot loop
CODE_0293B0:
	STX.w !RAM_SMW_NorSpr_CurrentSlotID	;>Mark current sprite slot that is processed
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;\If sprite carried, then
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	;|go to the next normal sprite slot
	BEQ.b CODE_0293F7		;/
	CMP.b #!Define_SMW_NorSprStatus08_Normal	;\If sprite is dying in a special way or inital,
	BCC.b CODE_0293F7		;/also go to another slot
	LDA.w !RAM_SMW_NorSpr_PropertyBits166E,x	;\If sprites generally cannot be hit by bounce
	AND.b #!Define_SMW_NorSpr_166EProp_ImmuneToCape	;|sprites, next slot
	ORA.w !RAM_SMW_NorSpr_OnYoshisTongue,x	;|
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x	;|
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E1FE2,x	;|
	BNE.b CODE_0293F7		;/
	LDA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x	;>Behind scenery flag
	PHY				;>protect extended sprite
	LDY.b !RAM_SMW_Player_ClimbingFlag	;\if not climbing, skip scenery flag
	BEQ.b CODE_0293D8		;/
	EOR.b #$01			;>Flip scenery flag
CODE_0293D8:
	PLY				;>Pull out extended sprite
	EOR.w !RAM_SMW_Player_CurrentLayerPriority	;>Flip again
	BNE.b CODE_0293F7		;>if nonzero, next sprite slot
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	LDA.b !RAM_SMW_Misc_ScratchRAM0E	;\$0E determines the type of [B]
	BEQ.b CODE_0293EB		;/if #$00, use hitbox of bounce
	JSR.w GetCapeSwingOrNetPunchClipping	;>hitbox for cape [B]
	BRA.b CODE_0293EE		;>Skip hitbox

CODE_0293EB:
	JSR.w GetBounceSpriteClipping	;>Bounce sprite hitbox [B]
CODE_0293EE:
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact	;>Check if sprite interacts with bounce block
	BCC.b CODE_0293F7		;>Clipping = false - skip flip sprite
	JSR.w CODE_029404		;>Clipping = true - flip sprites
CODE_0293F7:
	LDY.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite	;>Bring Y back to bounce sprite index
	DEX				;>Next sprite index
	BMI.b CODE_029400		;>If all slots checked, return X as bounce index
	JMP.w CODE_0293B0		;>Loop back

CODE_029400:
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite	;>Switch X back into bounce sprite index
	RTS

CODE_029404:
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
if defined("Define_SMW_SA1")
	; SA-1 Pack: When Mario smashes an enemy, either by hitting it with a
	; yoshi ground pound or hitting it on the other side of a net, the code
	; accesses some sprite tables.
	JSL.l MARIO_SMASH_SPRITE_SET
else
	LDA.b !RAM_SMW_NorSpr_SpriteID,x
	CMP.b #!Define_SMW_SpriteID_NorSpr081_ChangingItem
endif
	BNE.b CODE_029427
	LDA.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x
	BEQ.b Return029426
	STZ.b !RAM_SMW_NorSprXXX_PowerUps_StayInPlaceFlag,x
	LDA.b #$C0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$10
	STA.w !RAM_SMW_NorSprXXX_PowerUps_RisingOutOfBlockTimer,x
	STZ.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b #$20
	STA.w !RAM_SMW_NorSprXXX_PowerUps_NoBlockSideInteractionTimer,x
Return029426:
	RTS

CODE_029427:
	CMP.b #!Define_SMW_SpriteID_NorSpr02D_BabyYoshi
	BEQ.b CODE_029448
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x
	AND.b #!Define_SMW_NorSpr_167AProp_InvincibleToMostThings
	BNE.b CODE_0294A2
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_029443
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb
	BEQ.b CODE_029448
	LDA.b !RAM_SMW_NorSpr_Table7E00C2,x
	BEQ.b CODE_029448
CODE_029443:
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
CODE_029448:
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CMP.b #$35
	BEQ.b CODE_029455
	JSL.l SMW_SpawnContactEffectFromSide_Main
CODE_029455:
	LDA.b #$00
	JSL.l SMW_GivePoints_Main
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr01E_Lakitu
	BNE.b CODE_02946B
	LDA.b #$1F							;\ Glitch: (?) Why is this not indexed RAM?
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540+$09		;/
CODE_02946B:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	AND.b #!Define_SMW_NorSpr_1662Prop_FallWhenKilled
	BNE.b CODE_0294A2
	LDA.w !RAM_SMW_NorSpr_PropertyBits1656,x	; \ Branch if can't be jumped on
	AND.b #!Define_SMW_NorSpr_1656Prop_SafeToJumpOn			;\ Optimization: Use BIT.b to avoide needing to reload A
	BEQ.b CODE_0294A2						;|
	LDA.w !RAM_SMW_NorSpr_PropertyBits1656,x			;/
	AND.b #!Define_SMW_NorSpr_1656Prop_DiesWhenJumpedOn
	BNE.b CODE_0294A2
	LDA.b #!Define_SMW_NorSprStatus09_Stunned	; \ Sprite status = Carryable
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	ASL.w !RAM_SMW_NorSpr_Table7E15F6,x
	SEC
	ROR.w !RAM_SMW_NorSpr_Table7E15F6,x
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,x
	AND.b #!Define_SMW_NorSpr_1686Prop_SpawnsNewSprite
	BEQ.b CODE_0294A2
	PHX
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	TAX
	LDA.l SMW_GenericSpriteToSpawnTable_Main,x
	PLX
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_YXPPCCCTAndPropertyTables
CODE_0294A2:
	LDA.b #$C0
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b CODE_0294B0
	LDA.b #$B0
	CPY.b #$02
	BNE.b CODE_0294B0
	LDA.b #$C0
CODE_0294B0:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_CopyOfBank02_X
	LDA.w DATA_029392,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	TYA
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_Table7E157C,x
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckForPlayerAttackToNormalSpriteCollision(Address)
namespace SMW_CheckForPlayerAttackToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

DATA_029657:
	db $FC,$E0

DATA_029658:
	db $FF,$FF

DATA_02965A:
	db $18,$50

DATA_02965C:
	db $FC,$F8

DATA_02965E:
	db $FF,$FF

DATA_029660:
	db $18,$10

; Routine that gets sprite clipping value for quake sprites (i.e. bounce
; sprites and Yoshi's stomp). Takes the place of "sprite clipping B" from
; the standard routines.
GetBounceSpriteClipping:
	PHX
	LDA.w !RAM_SMW_BounceSpr_Type,y
	TAX
	LDA.w !RAM_SMW_BounceSpr_HitboxXLo,y
	CLC
	ADC.w DATA_029657-$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_BounceSpr_HitboxXHi,y
	ADC.w DATA_029658-$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w DATA_02965A-$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_BounceSpr_HitboxYLo,y
	CLC
	ADC.w DATA_02965C-$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_BounceSpr_HitboxYHi,y
	ADC.w DATA_02965E-$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.w DATA_029660-$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PLX
	RTS

; Get the cape hitbox for clipping B. $02969B [$02]: Hitbox horizontal
; displacement (low byte). $0296A2 [$00]: Hitbox horizontal displacement
; (high byte). $0296A5 [$14]: Hitbox width. $0296B4 [$10]: Hitbox height.
; Note that there is no vertical displacement for the cape hitbox.
GetCapeSwingOrNetPunchClipping:
	LDA.w !RAM_SMW_Player_CapeHitboxXLo	;\X position
	SEC				;|
	SBC.b #$02			;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;|
	LDA.w !RAM_SMW_Player_CapeHitboxXHi	;|
	SBC.b #$00			;|
	STA.b !RAM_SMW_Misc_ScratchRAM08	;/
	LDA.b #$14			;\Width
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.w !RAM_SMW_Player_CapeHitboxYLo	;\Y position
	STA.b !RAM_SMW_Misc_ScratchRAM01	;|
	LDA.w !RAM_SMW_Player_CapeHitboxYHi	;|
	STA.b !RAM_SMW_Misc_ScratchRAM09	;/
	LDA.b #$10			;\Height
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessExtendedSprites(Address)
namespace SMW_ProcessExtendedSprites
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #!Define_SMW_MaxExtendedSpriteSlot
CODE_029B0C:
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
	JSR.w CODE_029B16
	DEX
	BPL.b CODE_029B0C
Return029B15:
	RTS

CODE_029B16:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x	;\Free slot if the ID is 0
	BEQ.b Return029B15		;/
	LDY.b !RAM_SMW_Flag_SpritesLocked	;\Freeze the decrementor if $9D is set
	BNE.b CODE_029B27		;/
	LDY.w !RAM_SMW_ExtSpr_DecrementingTable7E176F,x	;>Graphics table/frame counter for fireballs hit an object
	BEQ.b CODE_029B27		;\Acts as a timer that decreases to 0
	DEC.w !RAM_SMW_ExtSpr_DecrementingTable7E176F,x	;/
CODE_029B27:
if !SMW_CustomSprites_ExtendedWanted == !TRUE
	; The same four bytes as the trampoline call, only where the rows
	; name a custom extended sprite. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Extended
else
	JSL.l SMW_ExecutePtr_Absolute	;>And jump based on what the extended sprite number.
endif

ExtendedSpritePtrs:
base ($000000)
; Extended sprite routines (hammer, fireball, etc.)
.ExtSpr00_Unused:		dw SMW_ExtSpr00_Unused_Main	; 00 - Empty slot
.ExtSpr01_SmokePuff:		dw SMW_ExtSpr01_SmokePuff_Main	; 01 - Puff of smoke
.ExtSpr02_ReznorFireball:	dw SMW_ExtSpr02_ReznorFireball_Main	; 02 - Reznor fireball
.ExtSpr03_FlameRemnant:		dw SMW_ExtSpr03_FlameRemnant_Main	; 03 - Tiny flame left by hopping flame
.ExtSpr04_Hammer:		dw SMW_ExtSpr04_Hammer_Main	; 04 - Hammer
.ExtSpr05_MarioFireball:	dw SMW_ExtSpr05_MarioFireball_Main	; 05 - Mario fireball
.ExtSpr06_ThrownBone:		dw SMW_ExtSpr06_ThrownBone_Main	; 06 - Bone
.ExtSpr07_LavaSplash:		dw SMW_ExtSpr07_LavaSplash_Main	; 07 - Lava splash
.ExtSpr08_LauncherArm:		dw SMW_ExtSpr08_LauncherArm_Main	; 08 - Torpedo Ted shooter's arm
.ExtSpr09_Unused:		dw SMW_ExtSpr09_Unused_Main	; 09 - Unused (Red thing that flickers from 16x16 to 8x8)
.ExtSpr0A_CloudCoin:		dw SMW_ExtSpr0A_CloudCoin_Main	; 0A - Coin from cloud game
.ExtSpr0B_PiranhaFireball:	dw SMW_ExtSpr0B_PiranhaFireball_Main	; 0B - Piranha fireball
.ExtSpr0C_VolcanoLotusFire:	dw SMW_ExtSpr0C_VolcanoLotusFire_Main	; 0C - Volcano lotus fire
.ExtSpr0D_Baseball:		dw SMW_ExtSpr0D_Baseball_Main	; 0D - Baseball
.ExtSpr0E_WigglerFlower:	dw SMW_ExtSpr0E_WigglerFlower_Main	; 0E - Flower of Wiggler
.ExtSpr0F_SmokeTrail:		dw SMW_ExtSpr0F_SmokeTrail_Main	; 0F - Trail of smoke
.ExtSpr10_SpinJumpStars:	dw SMW_ExtSpr10_SpinJumpStars_Main	; 10 - Spin Jump stars
.ExtSpr11_YoshiFireball:	dw SMW_ExtSpr11_YoshiFireball_Main	; 11 - Yoshi fireballs
.ExtSpr12_BreathBubble:		dw SMW_ExtSpr12_BreathBubble_Main	; 12 - Water bubble
base off
namespace off
	%SetDuplicateOrNullPointer(SMW_ProcessExtendedSprites_Return029B15, SMW_ExtSpr00_Unused_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessGeneratorSprite(Address)
namespace SMW_ProcessGeneratorSprite
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_GenSpr_SpriteID	;\ if there is no generator, return
	BEQ.b Return02B02A		;/
	LDY.b !RAM_SMW_Flag_SpritesLocked	;\
	BNE.b Return02B02A		;/ if sprites are locked, return
	DEC				; decrement A and use the pointer
if !SMW_CustomSprites_GeneratorWanted == !TRUE
	; The same four bytes as the trampoline call, only where the rows
	; name a custom generator. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Generator
else
	JSL.l SMW_ExecutePtr_Absolute
endif

GeneratorSprPtrs:
base $000002
.GenSpr01_GenerateEerie:		dw SMW_GenSpr01_GenerateEerie_Main	; 00 - Eerie, generator
.GenSpr02_GenParachuteEnemy:		dw SMW_GenSpr02_GenParachuteEnemy_Main	; 01 - Para-Goomba, generator
.GenSpr03_GenParachuteGoomba:		dw SMW_GenSpr03_GenParachuteGoomba_Main	; 02 - Para-Bomb, generator
.GenSpr04_GenParachuteBobOmb:		dw SMW_GenSpr04_GenParachuteBobOmb_Main	; 03 - Para-Bomb and Para-Goomba, generator
.GenSpr05_GenerateLeftDolphins:		dw SMW_GenSpr05_GenerateLeftDolphins_Main	; 04 - Dolphin, left, generator
.GenSpr06_GenerateRightDolphins:	dw SMW_GenSpr06_GenerateRightDolphins_Main	; 05 - Dolphin, right, generator
.GenSpr07_GenerateFish:			dw SMW_GenSpr07_GenerateFish_Main	; 06 - Jumping fish, generator
.GenSpr08_TurnOffRespawningSprite:	dw SMW_GenSpr08_TurnOffRespawningSprite_Main	; 07 - Turn off generator 2 (sprite E5)
.GenSpr09_GenerateSuperKoopa:		dw SMW_GenSpr09_GenerateSuperKoopa_Main	; 08 - Super Koopa, generator
.GenSpr0A_GenerateBubbles:		dw SMW_GenSpr0A_GenerateBubbles_Main	; 09 - Bubble with Goomba and Bob-omb, generator
.GenSpr0B_GenerateBullet:		dw SMW_GenSpr0B_GenerateBullet_Main	; 0A - Bullet Bill, generator
.GenSpr0C_GenerateSurroundingBullets:	dw SMW_GenSpr0C_GenerateSurroundingBullets_Main	; 0B - Bullet Bill surrounded, generator
.GenSpr0D_GenerateDiagnalBullets:	dw SMW_GenSpr0D_GenerateDiagnalBullets_Main	; 0C - Bullet Bill diagonal, generator
.GenSpr0E_GenerateFire:			dw SMW_GenSpr0E_GenerateFire_Main	; 0D - Bowser statue fire breath, generator
.GenSpr0F_TurnOffGenerator:		dw SMW_GenSpr0F_TurnOffGenerator_Main	; 0E - Turn off standard generators
base off

Return02B02A:
	RTS

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessShooterSprites(Address)
namespace SMW_ProcessShooterSprites
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\ if sprites are locked, return
	BNE.b Return02B3AA		;/
	LDX.b #!Define_SMW_MaxShooterSpriteSlot
CODE_02B38D:
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
	LDA.w !RAM_SMW_ShooterSpr_SpriteID,x	;\ if  no shooter is
	BEQ.b CODE_02B3A7		;/ registered, return
	LDY.w !RAM_SMW_ShooterSpr_ShootTimer,x	;\
	BEQ.b CODE_02B3A4		;/ if it's time to shoot, do so
	PHA				; save what shooter it is
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\
	LSR				;|
	BCC.b CODE_02B3A3		;|decrement shooter timer every
	DEC.w !RAM_SMW_ShooterSpr_ShootTimer,x	;/ other frame
CODE_02B3A3:
	PLA				; A = what shooter it is
CODE_02B3A4:
	JSR.w CODE_02B3AB		; shoot
CODE_02B3A7:
	DEX				;\ if haven't handled all sprites,
	BPL.b CODE_02B38D		;/ then keep going
Return02B3AA:
	RTS

CODE_02B3AB:
	DEC				;\ shoot projectile accordingly
if !SMW_CustomSprites_ShooterWanted == !TRUE
	; The same four bytes as the trampoline call, only where the rows
	; name a custom shooter. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Shooter
else
	JSL.l SMW_ExecutePtr_Absolute	;/
endif

ShooterSprPtrs:
base $000000
.ShooterSpr01_BulletBillShooter:	dw SMW_ShooterSpr01_BulletBillShooter_Main	; 00 - Bullet Bill shooter
.ShooterSpr02_TorpedoShooter:		dw SMW_ShooterSpr02_TorpedoShooter_Main	; 01 - Torpedo Ted launcher
.ShooterSpr03_Unused:			dw SMW_ShooterSpr03_Unused_Main	; 02 - Unused
base off
namespace off
	%SetDuplicateOrNullPointer(SMW_ProcessShooterSprites_Return02B3AA, SMW_ShooterSpr03_Unused_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_DrawBigCastleGate(Address)
namespace SMW_DrawBigCastleGate
%InsertMacroAtXPosition(<Address>)

Main:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_DrawBigCastleGate(Address)
namespace SMW_DrawBigCastleGate
%InsertMacroAtXPosition(<Address>)

Sub:
	LDA.w !RAM_SMW_Timer_NoYoshiIntroDoorTimer
	BEQ.b CODE_02F676
	DEC.w !RAM_SMW_Timer_NoYoshiIntroDoorTimer
CODE_02F676:
	CMP.b #$B0
	BNE.b CODE_02F67F
	LDY.b #!Define_SMW_Sound1DFC_Door1	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh3
CODE_02F67F:
	CMP.b #$01
	BNE.b CODE_02F688
	LDY.b #!Define_SMW_Sound1DFC_Door2	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh3
CODE_02F688:
	CMP.b #$30
	BCC.b CODE_02F69A
	CMP.b #$81
	BCC.b CODE_02F698
	CLC
	ADC.b #$4F
	EOR.b #$FF
	INC
	BRA.b CODE_02F69A

CODE_02F698:
	LDA.b #$30
CODE_02F69A:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	JSR.w DrawBigCastleGate
	RTS

XDisp:
	db $00,$10,$20,$00,$10,$20,$00,$10
	db $20,$00,$10,$20

YDisp:
	db $00,$00,$00,$10,$10,$10,$20,$20
	db $20,$30,$30,$30

DrawBigCastleGate:
	LDX.b #$0B
	LDY.b #$B0
CODE_02F6BC:
	LDA.b #$B8
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l XDisp,x
else
	ADC.w XDisp,x
endif
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.b #$50
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l YDisp,x
else
	ADC.w YDisp,x
endif
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b #$A5
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b #$21
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
	BPL.b CODE_02F6BC
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_DrawNoYoshiSign(Address)
namespace SMW_DrawNoYoshiSign
%InsertMacroAtXPosition(<Address>)

; Wrapper to $02F639 which allows you to draw the No-Yoshi sign from any
; bank.
Main:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_DrawNoYoshiSign(Address)
namespace SMW_DrawNoYoshiSign
%InsertMacroAtXPosition(<Address>)

XDisp:
	db $F8,$08,$F8,$08,$00,$00,$00,$00


YDisp:
	db $00,$00,$10,$10,$20,$30,$40,$08


; No Yoshi Signpost Tilemap
Tiles:
	db $C7,$A7,$A7,$C7,$A9,$C9,$C9,$E0


; No-Yoshi Signpost YXPPCCCT properties.
Prop:
	db $A9,$69,$A9,$69,$29,$29,$29,$6B

; Code which draws the No-Yoshi sign during the intro. If you want to access
; it from any bank, jump to $02F58C.
Sub:
	LDX.b #$07
	LDY.b #$B0
ADDR_02F63D:
	LDA.b #$C0
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l XDisp,x
else
	ADC.w XDisp,x
endif
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b #$70
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l YDisp,x
else
	ADC.w YDisp,x
endif
	STA.w SMW_OAMBuffer[$40].YDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Prop,x
else
	LDA.w Prop,x
endif
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
	BPL.b ADDR_02F63D
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_DrawGhostHouseEntranceDoor(Address)
namespace SMW_DrawGhostHouseEntranceDoor
%InsertMacroAtXPosition(<Address>)

Main:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_DrawGhostHouseEntranceDoor(Address)
namespace SMW_DrawGhostHouseEntranceDoor
%InsertMacroAtXPosition(<Address>)

XDisp:
	db $00,$00,$00,$00,$10,$10,$10,$10
	db $00,$00,$00,$00,$10,$10,$10,$10
	db $00,$00,$00,$00,$10,$10,$10,$10
	db $F2,$F2,$F2,$F2,$1E,$1E,$1E,$1E


YDisp:
	db $00,$08,$18,$20,$00,$08,$18,$20


Prop:
	db $7D,$7D,$FD,$FD,$3D,$3D,$BD,$BD


; Ghost House Doors Tilemap
Tiles:
	db $A0,$B0,$B0,$A0,$A0,$B0,$B0,$A0
	db $A3,$B3,$B3,$A3,$A3,$B3,$B3,$A3
	db $A2,$B2,$B2,$A2,$A2,$B2,$B2,$A2
	db $A3,$B3,$B3,$A3,$A3,$B3,$B3,$A3


OAMIndexes:
	db $40,$44,$48,$4C,$F0,$F4,$F8,$FC


AnimationFrame:
	db $00,$01,$02,$03,$03,$03,$03,$03
	db $03,$03,$03,$03,$03,$02,$01,$00

Sub:
	LDA.w !RAM_SMW_Timer_NoYoshiIntroDoorTimer
	BEQ.b CODE_02F761
	DEC.w !RAM_SMW_Timer_NoYoshiIntroDoorTimer
CODE_02F761:
	CMP.b #$76
	BNE.b CODE_02F76A
	LDY.b #!Define_SMW_Sound1DFC_Door1	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh3
CODE_02F76A:
	CMP.b #$08
	BNE.b CODE_02F773
	LDY.b #!Define_SMW_Sound1DFC_Door2	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh3
CODE_02F773:
	LSR
	LSR
	LSR
	TAY
	LDA.w AnimationFrame,y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDX.b #$07
	LDA.b #$B8
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$60
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01

CODE_02F78C:
	STX.b !RAM_SMW_Misc_ScratchRAM02
	LDY.w OAMIndexes,x
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	ASL
	ASL
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	TYA
	BMI.b CODE_02F7D0
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l XDisp,x
else
	ADC.w XDisp,x
endif
	STA.w SMW_OAMBuffer[$40].XDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l YDisp,x
else
	ADC.w YDisp,x
endif
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CMP.b #$03
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Prop,x
else
	LDA.w Prop,x
endif
	BCC.b CODE_02F7C2
	EOR.b #$40
CODE_02F7C2:
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	BRA.b CODE_02F801

CODE_02F7D0:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l XDisp,x
else
	ADC.w XDisp,x
endif
	STA.w SMW_OAMBuffer[$00].XDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l YDisp,x
else
	ADC.w YDisp,x
endif
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CMP.b #$03
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Prop,x
else
	LDA.w Prop,x
endif
	BCC.b CODE_02F7F5
	EOR.b #$40
CODE_02F7F5:
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
CODE_02F801:
	DEX
	BMI.b Return02F807
	JMP.w CODE_02F78C

Return02F807:
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_CheckForPlayerToNormalSpriteCollision(Address)
namespace SMW_CheckForPlayerToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

; A subroutine that turns all sprites on screen into silver coins. Called
; when pressing a silver P switch.
TurnSpritesIntoSilverCoins:
	LDA.b #$02
	STA.w !RAM_SMW_Counter_CurrentSilverCoins
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_02B9C4:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b CODE_02B9D5
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,y
	AND.b #!Define_SMW_NorSpr_190FProp_ImmuneToSilverPSwitch
	BNE.b CODE_02B9D5
	JSR.w CODE_02B9D9
CODE_02B9D5:
	DEY
	BPL.b CODE_02B9C4
	RTL

CODE_02B9D9:
	LDA.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	AND.b #$F1
	ORA.b #$02
	STA.w !RAM_SMW_NorSpr_Table7E15F6,x
	LDA.b #$D8
	STA.w !RAM_SMW_NorSpr_YSpeed,x
	PLX
	RTS
namespace off
endmacro

macro ROUTINE_RT03_SMW_CheckForPlayerToNormalSpriteCollision(Address)
namespace SMW_CheckForPlayerToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

; Change to EA EA EA EA to stop Super Koopas from spawning feathers. (In
; conjunction with $02EB19)
SpawnFeatherFromSuperKoopa:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return02EB26
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr077_Feather
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	TYX
	; Change to EA EA EA EA to prevent Super Koopas from spawning feathers (In
	; conjuction with $02EAF2)
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return02EB26:
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_CheckForPlayerFireballToNormalSpriteCollision(Address)
namespace SMW_CheckForPlayerFireballToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

Main:
	TXA				; \ Return every other frame
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b SMW_ExtSpr05_MarioFireball_Return02A0A8
	PHX
	TXY
	STY.w !RAM_SMW_Misc_ScratchRAM7E185E	; $185E = Y = Extended sprite index
	LDX.b #!Define_SMW_MaxNormalSpriteSlot-$02	; Loop over sprites:
FireRtLoopStart:
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Skip current sprite if status < 8
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b FireRtNextSprite
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ Skip current sprite if...
	AND.b #!Define_SMW_NorSpr_167AProp_InvincibleToMostThings	; | ...invincible to fire/cape/etc
	ORA.w !RAM_SMW_NorSpr_OnYoshisTongue,x	; | ...sprite being eaten...
	ORA.w !RAM_SMW_NorSpr_CurrentLayerPriority,x	; | ...interactions disabled...
	EOR.w !RAM_SMW_ExtSpr05_MarioFireball_CurrentLayerPriority,y
	BNE.b FireRtNextSprite
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSR.w GetPlayerFireballClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b FireRtNextSprite
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y	; \ if Yoshi fireball...
	CMP.b #!Define_SMW_SpriteID_ExtSpr11_YoshiFireball
	BEQ.b CODE_02A0EE
	PHX
	TYX
	JSR.w SMW_ExtSpr05_MarioFireball_CODE_02A045	; | ...?
	PLX
CODE_02A0EE:
	LDA.w !RAM_SMW_NorSpr_PropertyBits166E,x	; \ Skip sprite if fire killing is disabled
	AND.b #!Define_SMW_NorSpr_166EProp_ImmuneToFire
	BNE.b FireRtNextSprite
if defined("Define_SMW_SA1")
	; SA-1 Pack: Fireballs turn sprites into coins and need access to certain
	; sprite tables. Fireballs are extended sprites so there is no need to
	; restore.
	JSL.l FIREBALL_SET
	NOP
else
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,x	; \ Branch if takes 1 fireball to kill
	AND.b #!Define_SMW_NorSpr_190FProp_5FireballHP
endif
	BEQ.b TurnSpriteToCoin
	; Set to BD for unlimited Chargin Chuck fire hp
	INC.w !RAM_SMW_NorSpr_FireballHPCounter,x	; Increase times Chuck hit by fireball
	LDA.w !RAM_SMW_NorSpr_FireballHPCounter,x	; \ If fire count >= 5, kill Chuck:
	CMP.b #$05
	BCC.b FireRtNextSprite
	LDA.b #!Define_SMW_Sound1DF9_Contact	; | Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; | Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$D0			; | Set death Y speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_CopyOfBank02_X
	LDA.w FireKillXSpeed,y		; | Set death X speed
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$04			; | Increase points
	JSL.l SMW_GivePoints_Main
	BRA.b FireRtNextSprite

; Code that turns a sprite into a coin after getting hit by a fireball. -
; $02A125: the sound effect to play when other enemies are killed by
; fireballs. - $02A12A: the sprite fireballed enemies spawn.
TurnSpriteToCoin:
	LDA.b #!Define_SMW_Sound1DF9_KickShell	; \ Turn sprite into coin:
	STA.w !RAM_SMW_IO_SoundCh1	; | Play sound effect
	LDA.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin	; | Sprite = Moving Coin
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; | Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; | Reset sprite tables
	LDA.b #$D0			; | Set upward speed
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_CopyOfBank02_X
	TYA
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_Table7E157C,x
FireRtNextSprite:
	LDY.w !RAM_SMW_Misc_ScratchRAM7E185E
	DEX
	BMI.b CODE_02A14C
	JMP.w FireRtLoopStart

CODE_02A14C:
	PLX				; $15E9 = Sprite index
	STX.w !RAM_SMW_NorSpr_CurrentSlotID	; $15E9 = Sprite index
	RTS

FireKillXSpeed:
	db $F0,$10
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckForPlayerFireballToNormalSpriteCollision(Address)
namespace SMW_CheckForPlayerFireballToNormalSpriteCollision
%InsertMacroAtXPosition(<Address>)

; Get Fireball clipping subroutine. Valid for Yoshi's and Mario's fireballs,
; Stores the clipping X displacement low byte to $00, the clipping X
; displacement high byte to $08, the clipping width (#$0C) to $02, the
; clipping Y displacement low byte to $01, the clipping Y displacement high
; byte to $09, and the clipping height (#$13) to $03 (so it's equivalent to
; the "Get sprite clipping B" routine). Input: - Y: which extended sprite
; slot to get clipping of ($00-07 for Yoshi's fireballs, and $08-09 for
; Mario's)
GetPlayerFireballClipping:
	LDA.w !RAM_SMW_ExtSpr_XPosLo,y
	SEC
	SBC.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ExtSpr_XPosHi,y
	SBC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b #$0C
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_ExtSpr_YPosLo,y
	SEC
	SBC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_ExtSpr_YPosHi,y
	SBC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b #$13
	STA.b !RAM_SMW_Misc_ScratchRAM03
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ParseLevelSpriteList(Address)
namespace SMW_ParseLevelSpriteList
%InsertMacroAtXPosition(<Address>)

; Highest sprite slot number for non-reserved sprites, indexed by the sprite
; memory setting. The routine checks all slots beginning with the value in
; this table and loops until reaching the value in the table at $02A7AC.
SpriteSlotMax:
	db !Define_SMW_StockMaxNormalSpriteSlot-$02,!Define_SMW_StockMaxNormalSpriteSlot-$06,!Define_SMW_StockMaxNormalSpriteSlot-$04
	db !Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$05
	db !Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$05,!Define_SMW_SpriteMemorySetting08_LastSlot
	db !Define_SMW_StockMaxNormalSpriteSlot-$02,!Define_SMW_StockMaxNormalSpriteSlot-$03,!Define_SMW_StockMaxNormalSpriteSlot-$07
	db !Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$04
	db !Define_SMW_StockMaxNormalSpriteSlot-$03,!Define_SMW_StockMaxNormalSpriteSlot-$02,!Define_SMW_StockMaxNormalSpriteSlot-$06
	db !Define_SMW_StockMaxNormalSpriteSlot-$06

; Highest sprite slot number for reserved sprite 1.
SpriteSlotMax1:
	db !Define_SMW_StockMaxNormalSpriteSlot-$02,!Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$04
	db !Define_SMW_StockMaxNormalSpriteSlot-$0A,!Define_SMW_StockMaxNormalSpriteSlot-$0B,!Define_SMW_StockMaxNormalSpriteSlot-$0A
	db !Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$05,!Define_SMW_SpriteMemorySetting08_LastSlot
	db !Define_SMW_StockMaxNormalSpriteSlot-$0B,!Define_SMW_StockMaxNormalSpriteSlot-$09,!Define_SMW_StockMaxNormalSpriteSlot-$0B
	db !Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$0A,!Define_SMW_StockMaxNormalSpriteSlot-$04
	db !Define_SMW_StockMaxNormalSpriteSlot-$03,!Define_SMW_StockMaxNormalSpriteSlot-$02,!Define_SMW_StockMaxNormalSpriteSlot-$04
	db !Define_SMW_StockMaxNormalSpriteSlot-$06

; Highest sprite slot number for reserved sprite 2.
SpriteSlotMax2:
	db !Define_SMW_StockMaxNormalSpriteSlot-$02,!Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$04
	db !Define_SMW_StockMaxNormalSpriteSlot-$0A,!Define_SMW_StockMaxNormalSpriteSlot-$0B,!Define_SMW_StockMaxNormalSpriteSlot-$05
	db !Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$05,!Define_SMW_SpriteMemorySetting08_LastSlot
	db !Define_SMW_StockMaxNormalSpriteSlot-$0B,!Define_SMW_StockMaxNormalSpriteSlot-$09,!Define_SMW_StockMaxNormalSpriteSlot-$0B
	db !Define_SMW_StockMaxNormalSpriteSlot-$04,!Define_SMW_StockMaxNormalSpriteSlot-$0A,!Define_SMW_StockMaxNormalSpriteSlot-$04
	db !Define_SMW_StockMaxNormalSpriteSlot-$03,!Define_SMW_StockMaxNormalSpriteSlot-$02,!Define_SMW_StockMaxNormalSpriteSlot-$04
	db !Define_SMW_StockMaxNormalSpriteSlot-$06

; Lowest sprite slot number for non-reserved sprites, minus 1.
SpriteSlotStart:
	db !NullSpriteSlot,!NullSpriteSlot,!Define_SMW_StockMaxNormalSpriteSlot-$0B
	db !Define_SMW_StockMaxNormalSpriteSlot-$0A,!Define_SMW_StockMaxNormalSpriteSlot-$0B,!Define_SMW_StockMaxNormalSpriteSlot-$0A
	db !NullSpriteSlot,!Define_SMW_StockMaxNormalSpriteSlot-$0A,!NullSpriteSlot
	db !Define_SMW_StockMaxNormalSpriteSlot-$0B,!NullSpriteSlot,!Define_SMW_StockMaxNormalSpriteSlot-$0B
	db !NullSpriteSlot,!Define_SMW_StockMaxNormalSpriteSlot-$0A,!NullSpriteSlot
	db !NullSpriteSlot,!NullSpriteSlot,!NullSpriteSlot
	db !NullSpriteSlot

; Lowest sprite slot number for reserved sprite 1, minus 1. Reserved sprite
; 2 always uses FF.
SpriteSlotStart1:
	db !NullSpriteSlot,!Define_SMW_StockMaxNormalSpriteSlot-$06,!NullSpriteSlot
	db !NullSpriteSlot,!NullSpriteSlot,!NullSpriteSlot
	db !NullSpriteSlot,!Define_SMW_StockMaxNormalSpriteSlot-$0A,!NullSpriteSlot
	db !NullSpriteSlot,!NullSpriteSlot,!NullSpriteSlot
	db !NullSpriteSlot,!NullSpriteSlot,!NullSpriteSlot
	db !NullSpriteSlot,!NullSpriteSlot,!Define_SMW_StockMaxNormalSpriteSlot-$06
	db !NullSpriteSlot

; Reserved sprite number 1. Note that sprite memory setting 12 doesn't
; actually have an entry in this table and uses the first byte of the next
; table instead.
ReservedSprite1:							;\ Info: Sprite memory index...
	db $FF								;| $00
	db !Define_SMW_SpriteID_NorSpr05F_BrownChainedPlatform		;| $01
	db !Define_SMW_SpriteID_NorSpr054_ClimbingNetDoor		;| $02
	db !Define_SMW_SpriteID_NorSpr05E_FloatingOrangePlatform	;| $03
	db !Define_SMW_SpriteID_NorSpr060_FlatPalaceSwitch		;| $04
	db !Define_SMW_SpriteID_NorSpr028_BigBoo			;| $05
	db !Define_SMW_SpriteID_NorSpr088_WingedCage			;| $06
	db $FF								;| $07
	db $FF								;| $08
	db !Define_SMW_SpriteID_NorSpr0C5_BigBooBoss			;| $09
	db !Define_SMW_SpriteID_NorSpr086_Wiggler			;| $0A
	db !Define_SMW_SpriteID_NorSpr028_BigBoo			;| $0B
	db $FF								;| $0C
	db !Define_SMW_SpriteID_NorSpr090_GreenGasBubble		;| $0D
	db $FF								;| $0E
	db $FF								;| $0F
	db $FF								;| $10
	db !Define_SMW_SpriteID_NorSpr0AE_FishinBoo			;/ $11

; Reserved sprite number 2. Note that sprite memory setting 12 doesn't
; actually have an entry in this table and uses the following byte (D0 by
; default) instead.
ReservedSprite2:							;\ Info: Sprite memory index...
	db $FF								;| $00
	db !Define_SMW_SpriteID_NorSpr064_LineGuideRope			;| $01
	db $FF								;| $02
	db $FF								;| $03
	db !Define_SMW_SpriteID_NorSpr09F_BanzaiBill			;| $04
	db $FF								;| $05
	db $FF								;| $06
	db $FF								;| $07
	db $FF								;| $08
	db $FF								;| $09
	db $FF								;| $0A
	db $FF								;| $0B
	db $FF								;| $0C
	db !Define_SMW_SpriteID_NorSpr09F_BanzaiBill			;| $0D
	db $FF								;| $0E
	db $FF								;| $0F
	db $FF								;| $10
	db $FF								;/ $11

DATA_02A7F6:
	db $D0,$00,$20

DATA_02A7F9:
	db $FF,$00,$01

; The routine that loads sprites from the level data. Called every frame;
; $02A802 is also called a few times during level load.
Main:
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Return every other frame
	AND.b #$01
	BNE.b Return02A84B
Entry2:
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_LoadSprites
	RTS
else
	LDY.b !RAM_SMW_Camera_Layer1ScrollingDirection	; >Screen scroll direction (note: Depends if mario's screen x pos is less than/greater-equal to $142A) by Y.
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	; \ Branch if horizontal level
	LSR
endif
	BCC.b CODE_02A817
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	; \ Vertical level:
	CLC				; | $00,$01 = Screen boundary Y + offset
	ADC.w DATA_02A7F6,y
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	BRA.b CODE_02A823

CODE_02A817:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	; \ Horizontal level:
	CLC				; | $00,$01 = Screen boundary X + offset
	ADC.w DATA_02A7F6,y
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
CODE_02A823:
	ADC.w DATA_02A7F9,y
#LM300Hijack_UpdatedSpriteListRt1:
	BMI.b Return02A84B
	STA.b !RAM_SMW_Misc_ScratchRAM01
if defined("Define_SMW_SA1")
	LDY.b #$01
	REP.b #$10
else
	LDX.b #$00			; X = #$00 (Number of sprite in level)
#LM_JMLHere_UpdatedSpriteListRt:
	LDY.b #$01			; Y = #$01 (Index into level data)
endif
LoadSpriteLoopStrt:
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	; Byte format: YYYYEEsy
#LM300Hijack_UpdatedSpriteListRt2:				; LM: Inserts 3 JMLs here. (3.00+)
	CMP.b #$FF			; \ Return when we encounter $FF, as it signals the end
	BEQ.b Return02A84B
	ASL				; \ If 's' is set, $02 = #$10
	ASL				; | Else, $02 = #$00
	ASL
	AND.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM02
	INY				; Next byte
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	; Byte format: XXXXSSSS
	AND.b #$0F			; \ Skip all sprites until we find one at the adjusted screen boundary:
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b !RAM_SMW_Misc_ScratchRAM01	; | If sprite screen (sSSSS) < adjusted screen boundary...
	BCS.b CODE_02A84C		; / ...skip the sprite
LoadNextSprite:
if !Define_SMW_CustomSprites == !TRUE
	; The same five bytes as the plain stride. A custom record may carry
	; extra bytes behind its three, and this is the one advance the spawn
	; seam does not own: every skipped record -- off its screen, or
	; already loaded -- passes here. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_NextRecord
	NOP
else
	INY				; \ Move on to the next sprite
	INY
	INX
	BRA.b LoadSpriteLoopStrt
endif

Return02A84B:
	RTS

CODE_02A84C:
	BNE.b Return02A84B		; Return if sprite screen > adjusted screen boundary
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	; Byte format: XXXXSSSS
	AND.b #$F0			; \ Skip sprite if not right at the screen boundary
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b LoadNextSprite
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_CODE_02A856
	NOP #6
else
	LDA.w !RAM_SMW_Sprites_LoadStatus,x	; \ This table has a flag for every sprite in the level (not just those onscreen)
	BNE.b LoadNextSprite		; / Skip sprite if it's already been loaded/permanently killed
	STX.b !RAM_SMW_Misc_ScratchRAM02	; $02 = Number of sprite in level
	INC.w !RAM_SMW_Sprites_LoadStatus,x	; Mark sprite as loaded
endif
	INY				; Next byte
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	; Byte format: Sprite number
	STA.b !RAM_SMW_Misc_ScratchRAM05	; $05 = Sprite number
	DEY				; Previous byte
	CMP.b #$E7			; \ Branch if sprite number < #$E7
	BCC.b CODE_02A88C
	LDA.w !RAM_SMW_L1ScrollSpr_SpriteID	; \ If scroll command stuff are set, branch
	ORA.w !RAM_SMW_L2ScrollSpr_SpriteID	;  |
	BNE.b CODE_02A88A		; /
	PHY
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM05	; \ $143E = Type of scroll sprite
	SEC				; | (Sprite number - #$E7)
	SBC.b #$E7
	STA.w !RAM_SMW_L1ScrollSpr_SpriteID
	DEY				; Previous byte
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	; Byte format: YYYYEEsy
	LSR				; \Bits 0 and 1 removed...
	LSR				; /
	STA.w !RAM_SMW_L1ScrollSpr_ScrollTypeIndex	;>...And write to scroll command
if defined("Define_SMW_SA1")
	JSL.l SpriteLoading_ScrollSprite
else
	JSL.l SMW_InitializeScrollSprites_Main
endif
	PLX
	PLY
CODE_02A88A:
	BRA.b LoadNextSprite

CODE_02A88C:
	CMP.b #$DE			; \ Branch if sprite number != 5 Eeries
	BNE.b CODE_02A89C
	PHY				; This is so that the Eeries spawn synchronized.
	PHX
	DEY
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_FiveEeriesFix2
	NOP
else
	STY.b !RAM_SMW_Misc_ScratchRAM03
	JSR.w SMW_NorSpr0DE_Load5Eeries_Main
endif
	PLX
	PLY
CODE_02A89A:
	BRA.b LoadNextSprite

CODE_02A89C:
	CMP.b #$E0			; \ Branch if sprite number != 3 Platforms on Chain
	BNE.b CODE_02A8AC
	PHY				; Like the above, this is so that each platform
	PHX				; are equally spaced (in degrees) when they spawn.
	DEY
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_ThreePlatformsFix
	NOP #5
else
	STY.b !RAM_SMW_Misc_ScratchRAM03
	JSR.w SMW_NorSpr0E0_Load3Platforms_Main
	PLX
	PLY
	BRA.b CODE_02A89A		;>Load next sprite
endif

CODE_02A8AC:
	CMP.b #$CB			; \ Branch if sprite number < #$CB
	BCC.b CODE_02A8D4
	CMP.b #$DA			; \ Branch if sprite number >= #$DA
	BCS.b CODE_02A8C0
	SEC				; \ $18B9 = Type of generator
	SBC.b #$CB			; | (Sprite number - #$CA)
	INC
	STA.w !RAM_SMW_GenSpr_SpriteID
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_CODE_02A8BB
	db $DA	; the tail of the BRA.b below, which the hijack leaves unreached
else
	STZ.w !RAM_SMW_Sprites_LoadStatus,x	; Allow sprite to be reloaded by level loading routine
	BRA.b CODE_02A89A		;>load next sprite
endif

CODE_02A8C0:
	CMP.b #$E1			; \ Branch if sprite number < #$E1
	BCC.b CODE_02A8D0
	PHX
	PHY
	DEY
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_SpecialSpriteFix
	NOP
else
	STY.b !RAM_SMW_Misc_ScratchRAM03
	JSR.w SMW_NorSpr0E1_LoadBooCeiling_Main
endif
	PLY
	PLX
	BRA.b CODE_02A89A

CODE_02A8D0:
	LDA.b #$09
	BRA.b CODE_02A8DF

CODE_02A8D4:
	CMP.b #$C9			; \ Branch if sprite number < #$C9
	BCC.b LoadNormalSprite
	JSR.w SMW_NorSprXXX_LoadShooter_Main	;>Shooter if >= #$C9
	BRA.b CODE_02A89A		;>Next sprite

LoadNormalSprite:
	LDA.b #$01			; \ $04 = #$01
CODE_02A8DF:
	STA.b !RAM_SMW_Misc_ScratchRAM04	; / Eventually goes into sprite status
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_NSprite_FixY
	NOP
	RTI
else
	DEY				; Previous byte
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDY.w !RAM_SMW_Sprites_SpriteMemorySetting
endif
	LDX.w SpriteSlotMax,y		;>Use that as the maximum number of sprites (lower slots being contained (mostly 0-9))
	LDA.w SpriteSlotStart,y		;>Sprite slot loop start (valid from 1-11)
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM05	;\Special reserved sprites
	CMP.w ReservedSprite1,y		;|
	BNE.b CODE_02A8FE		;/
	LDX.w SpriteSlotMax1,y
	LDA.w SpriteSlotStart1,y
	STA.b !RAM_SMW_Misc_ScratchRAM06
CODE_02A8FE:
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	CMP.w ReservedSprite2,y
	BNE.b CODE_02A916
	CMP.b #!Define_SMW_SpriteID_NorSpr064_LineGuideRope
	BNE.b CODE_02A90F
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$10
	BEQ.b CODE_02A916
CODE_02A90F:
	LDX.w SpriteSlotMax2,y
	LDA.b #$FF			;\$06 = #$FF
	STA.b !RAM_SMW_Misc_ScratchRAM06	;/
CODE_02A916:
	STX.b !RAM_SMW_Misc_ScratchRAM0F	;>$0F = Sprite slot maximum
CODE_02A918:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;>Sprite status
	BEQ.b CODE_02A93C		;>If 0 (gone = branch)
	DEX				;>Next slot
	CPX.b !RAM_SMW_Misc_ScratchRAM06	;>If $06 isn't #$FF, loop
	BNE.b CODE_02A918
	LDA.b !RAM_SMW_Misc_ScratchRAM05	;>Sprite number
	CMP.b #!Define_SMW_SpriteID_NorSpr07B_GoalTape	;\If other than goal tape, clear load status
	BNE.b CODE_02A936		;/
	LDX.b !RAM_SMW_Misc_ScratchRAM0F	;>Sprite maximum
ADDR_02A92A:
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	;\if not invincible to star/cape/fire/bouncing bricks
	AND.b #!Define_SMW_NorSpr_167AProp_InvincibleToMostThings	;|branch
	BEQ.b CODE_02A93C		;/
	DEX				;>Next slot
	CPX.b !RAM_SMW_Misc_ScratchRAM06	;\If other than #$FF (meaning, other than invalid slot),
	BNE.b ADDR_02A92A		;/loop
CODE_02A936:
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_NSprite_FixY2
	RTS
	NOP
else
	LDX.b !RAM_SMW_Misc_ScratchRAM02	;>Otherwise (invalid slot), load number of sprite in level
	STZ.w !RAM_SMW_Sprites_LoadStatus,x	; Allow sprite to be reloaded by level loading routine
	RTS
endif

CODE_02A93C:
if defined("Define_SMW_SA1")
	; SA-1 Pack: Sprite loading routine.
	JML.l SPRITE_LOAD_HACK
else
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	; \ Branch if horizontal level
endif
	LSR
	BCC.b CODE_02A95B
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	; \ Vertical level:
	PHA				; | Same as below with X and Y coords swapped
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	PLA
if !Define_SMW_CustomSprites == !TRUE
	; The same two bytes, PIXI's mask: the extra bits carry meaning now,
	; and a set one would put the sprite a screen and more away from its
	; record. The seam keeps the bits; a position is not where they ride.
	AND.b #$01
else
	AND.b #$0D
endif
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	BRA.b CODE_02A971

CODE_02A95B:
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	; Byte format: YYYYEEsy
	PHA				; \ Bits 11110000 are low byte of Y position
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA				; \ Bits 00001101 are high byte of Y position
if !Define_SMW_CustomSprites == !TRUE
	; The same two bytes, PIXI's mask -- see the vertical twin above.
	AND.b #$01
else
	AND.b #$0D			; | (Extra bits are stored in Y position)
endif
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; \ X position = adjusted screen boundary
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_XPosHi,x
CODE_02A971:
if !Define_SMW_CustomSprites == !TRUE
	; The same four bytes as the two INYs and the read, at the join both
	; bases pass through -- the pack's own loader re-enters just ahead of
	; it. The stub reads the record's extra bits and its number and
	; leaves them pending for the table initialize below to consume, then
	; repeats the displaced instructions. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_Spawn
else
	INY
	INY
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; \ Sprite status = ??
endif
CustomSpritesReturn:
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
if !Define_SMW_CustomSprites == !TRUE
	; The same four bytes as the compare and the re-read. The seam above
	; left Y past a custom record's extra bytes, so the number is read
	; back from the pending pair the seam kept -- the same byte for a
	; record that carries none. See Config/CustomSprites.asm.
	JML.l SMW_CustomSprites_SpawnNumber
else
	CMP.b #!Define_SMW_NorSprStatus09_Stunned
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	;KKOOPA STORAGE???
endif
SpawnNumberReturn:
	BCC.b CODE_02A984		;NO, IT WAS STATIONARY
	SEC
	SBC.b #$DA			;SUBTRACT DA, FIRST SHELL SPRITE [RED]
	CLC
	ADC.b #!Define_SMW_SpriteID_NorSpr004_GreenKoopa
CODE_02A984:
if defined("Define_SMW_SA1")
	JMP.w SpriteLoading_Label3_J
	NOP
else
	PHY
	LDY.w !RAM_SMW_Overworld_LevelTileSettings+!Define_SMW_LevelID_ChangeKoopaColors
endif
	; Change from 10 to 80 to disable the green and red koopa shells from
	; becoming yellow and blue after the special world is passed
	BPL.b CODE_02A996		;IF POSITIBE, JUST STORE?
	CMP.b #!Define_SMW_SpriteID_NorSpr004_GreenKoopa
	BNE.b CODE_02A990
	LDA.b #!Define_SMW_SpriteID_NorSpr007_YellowKoopa	;WHAT?
CODE_02A990:
	CMP.b #!Define_SMW_SpriteID_NorSpr005_RedKoopa
	BNE.b CODE_02A996
	LDA.b #!Define_SMW_SpriteID_NorSpr006_BlueKoopa	;STORING RED KOOPA SHELL TO SPRITENUM
CODE_02A996:
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	PLY
	LDA.b !RAM_SMW_Misc_ScratchRAM02	; \ $161A,x = index of the sprite in the level
	STA.w !RAM_SMW_NorSpr_LoadStatusTableIndex,x	; / (Number of sprites in level, not just onscreen)
	LDA.w !RAM_SMW_Timer_SilverPSwitch
	; Change to 80 to prevent off screen sprites from turning into silver coins
	; when the silver POW is active (USE WITH $01AB28)
	BEQ.b CODE_02A9C9
	PHX
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	TAX
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_Label4
else
	LDA.l SMW_InitializeNormalSpriteRAMTables_Sprite190FVals,x
endif
	PLX
	AND.b #!Define_SMW_NorSpr_190FProp_ImmuneToSilverPSwitch
	BNE.b CODE_02A9C9
	LDA.b #!Define_SMW_SpriteID_NorSpr021_MovingCoin	; \ Sprite = Moving Coin
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
if defined("Define_SMW_SA1")
	JSL.l SpriteLoading_InitSpriteTablesFix
else
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
endif
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	AND.b #$F1
	ORA.b #$02
	STA.w !RAM_SMW_NorSpr_Table7E15F6,x
	BRA.b CODE_02A9CD

CODE_02A9C9:
if defined("Define_SMW_SA1")
	JSL.l SpriteLoading_InitSpriteTablesFix
else
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Reset sprite tables
endif
CODE_02A9CD:
	LDA.b #$01			; \ Set off screen horizontally
	STA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	LDA.b #$04			; \ ?? $1FE2,X = #$04
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1FE2,x
	INY
	LDX.b !RAM_SMW_Misc_ScratchRAM02
#LM_JMLHere_02A9DA:
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_NSprite_FixY3
else
	INX
	JMP.w LoadSpriteLoopStrt
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UnusedGenTileFromSpr(Address)
namespace SMW_UnusedGenTileFromSpr
%InsertMacroAtXPosition(<Address>)

; This generates a Map16 tile at the position of the sprite currently being
; processed. It can be accessed with a JSL, and A should be set to the value
; of $9C you wish to use.
Main:
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
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UnusedPrepareToAimAtPlayerRoutine(Address)
namespace SMW_UnusedPrepareToAimAtPlayerRoutine
%InsertMacroAtXPosition(<Address>)

Main:
	STA.b !RAM_SMW_Misc_ScratchRAM00	; Unreachable
	LDA.b !RAM_SMW_Player_XPosLo	; \ Save Mario's position
	PHA
	LDA.b !RAM_SMW_Player_XPosHi
	PHA
	LDA.b !RAM_SMW_Player_YPosLo
	PHA
	LDA.b !RAM_SMW_Player_YPosHi
	PHA
	LDA.w !RAM_SMW_NorSpr_XPosLo,y	; \ Mario's position = Sprite position
	STA.b !RAM_SMW_Player_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,y
	STA.b !RAM_SMW_Player_XPosHi
	LDA.w !RAM_SMW_NorSpr_YPosLo,y
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,y
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	JSR.w SMW_AimTowardsPlayer_Bank02
	PLA				; \ Restore Mario's position
	STA.b !RAM_SMW_Player_YPosHi
	PLA
	STA.b !RAM_SMW_Player_YPosLo
	PLA
	STA.b !RAM_SMW_Player_XPosHi
	PLA
	STA.b !RAM_SMW_Player_XPosLo
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_SpawnBounceSprite(Address)
namespace SMW_SpawnBounceSprite
%InsertMacroAtXPosition(<Address>)

; A subroutine for spawning bounce sprites for blocks. It continues into the
; routine at $02887D. Input: $04 - bounce sprite command $05 - value to use
; in $02887D $06 - speed index (see $02873A and $02873E) $07 - value of $9C
; the block will turn into Notable subsections of this routine include:
; $028789 (9 bytes): Block bounce sprite YXPPCCCT table. First 7 values
; match with the value in $04 ($1699 - 1) while the last two are for
; commands 0x10 and 0x11 (coloured turn blocks / !-block bounce animation).
; $028758 (49 bytes): Break turn block routine. $0287B0 (84 bytes): Stops an
; existing bounce animation, if $1699 has no empty slots available to spawn
; a new bounce sprite into $028804 (121 bytes): Portion of the routine to
; actually spawn the bounce sprite
Main:
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CMP.b #$07
	BNE.b NotBreakable
	LDA.w !RAM_SMW_Player_CurrentCharacter	; \ Increase points
	ASL
	ADC.w !RAM_SMW_Player_CurrentCharacter
	TAX
	LDA.w !RAM_SMW_Player_MarioScoreLo,x
	CLC
	ADC.b #$05
	STA.w !RAM_SMW_Player_MarioScoreLo,x
	BCC.b CODE_028773
	INC.w !RAM_SMW_Player_MarioScoreMid,x
	BNE.b CODE_028773
	INC.w !RAM_SMW_Player_MarioScoreHi,x
CODE_028773:
	LDA.b #$D0			; Deflect Mario downward
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b #$00			; for shatter routine?
	JSL.l SMW_SpawnBrickPieces_Main	; Actually break the block
	JSR.w SMW_InitializeBlockPunchAttack_Main	; Handle sprite/block interaction
	LDA.b #$02			; \ Replace block with "nothing" tile
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
	RTL

BlockBounce:
	db $00,$03,$00,$00,$01,$07,$00,$04
	db $0A

NotBreakable:
	LDY.b #!Define_SMW_MaxBounceSpriteSlot	; \ Reset turning block
FindTurningBlkSlot:
	LDA.w !RAM_SMW_BounceSpr_SpriteID,y
	BEQ.b CODE_028807
	DEY
	BPL.b FindTurningBlkSlot
	DEC.w !RAM_SMW_BounceSpr_SlotToOverwriteWhenSlotsFull	;>Switch index of which to overwrite
	BPL.b CODE_0287A6		;>If still valid, skip looping it
	LDA.b #!Define_SMW_MaxBounceSpriteSlot	;\Loop it
	STA.w !RAM_SMW_BounceSpr_SlotToOverwriteWhenSlotsFull	;/
CODE_0287A6:
	LDY.w !RAM_SMW_BounceSpr_SlotToOverwriteWhenSlotsFull	;>Write on that slot.
	LDA.w !RAM_SMW_BounceSpr_SpriteID,y	; \ Branch if not a turn block
	CMP.b #!Define_SMW_SpriteID_BounceSpr07_SpinningTurnBlock
	BNE.b NoResetTurningBlk
	LDA.b !RAM_SMW_Blocks_XPosLo	; \ Save [$98-$9A]
	PHA
	LDA.b !RAM_SMW_Blocks_XPosHi
	PHA
	LDA.b !RAM_SMW_Blocks_YPosLo
	PHA
	LDA.b !RAM_SMW_Blocks_YPosHi
	PHA
	LDA.w !RAM_SMW_BounceSpr_XPosLo,y	; \ Block Y position = Bounce Y sprite position
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_BounceSpr_XPosHi,y
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.w !RAM_SMW_BounceSpr_YPosLo,y	; \ Block X position = Bounce X sprite position
	CLC
	ADC.b #$0C			; | (Round to nearest #$10)
	AND.b #$F0
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_BounceSpr_YPosHi,y
	ADC.b #$00
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.w !RAM_SMW_BounceSpr_Map16TileToSpawn,y	; \ Block to generate = Bounce sprite block
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; \ Save [$04-$07]
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	PHA
	JSL.l SMW_GenerateTile_Main
	PLA				; \ Restore [$04-$07]
	STA.b !RAM_SMW_Misc_ScratchRAM07
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM06
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM05
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM04
	PLA				; \ Restore [$98-$9A]
	STA.b !RAM_SMW_Blocks_YPosHi
	PLA
	STA.b !RAM_SMW_Blocks_YPosLo
	PLA
	STA.b !RAM_SMW_Blocks_XPosHi
	PLA
	STA.b !RAM_SMW_Blocks_XPosLo
NoResetTurningBlk:
	LDY.w !RAM_SMW_BounceSpr_SlotToOverwriteWhenSlotsFull
CODE_028807:
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CMP.b #$10
	BCC.b CODE_028818
	STZ.b !RAM_SMW_Misc_ScratchRAM04
	TAX
	LDA.w BlockBounce-$09,x
	STA.w !RAM_SMW_BounceSpr_YXPPCCCT,y
	BRA.b CODE_02882A

CODE_028818:
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; \ Play on/off sound if appropriate
	CMP.b #$05
	BNE.b CODE_028823
	; Code for one of two sound effects played when the ON/OFF switch block is
	; hit (the other being at $02918C). This one plays first, when the block is
	; actually hit. It also prevents the normal "hit block" sound from playing.
	; To disable this one (thereby restoring the normal block-hit sound
	; effect), change the first two bytes here to [80 03].
	LDX.b #!Define_SMW_Sound1DF9_ONOFFSwitch
	STX.w !RAM_SMW_IO_SoundCh1
CODE_028823:
	TAX
	LDA.w BlockBounce,x
	STA.w !RAM_SMW_BounceSpr_YXPPCCCT,y
CODE_02882A:
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; \ Set block bounce sprite type
	INC
	STA.w !RAM_SMW_BounceSpr_SpriteID,y
	LDA.b #$00			; \ set (times can be hit?)
	STA.w !RAM_SMW_BounceSpr_CurrentStatus,y
	LDA.b !RAM_SMW_Blocks_XPosLo	; \ Set bounce block y position
	STA.w !RAM_SMW_BounceSpr_XPosLo,y
	LDA.b !RAM_SMW_Blocks_XPosHi
	STA.w !RAM_SMW_BounceSpr_XPosHi,y
	LDA.b !RAM_SMW_Blocks_YPosLo	; \ Set bounce block x position
	STA.w !RAM_SMW_BounceSpr_YPosLo,y
	LDA.b !RAM_SMW_Blocks_YPosHi
	STA.w !RAM_SMW_BounceSpr_YPosHi,y
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	LSR
	ROR
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDX.b !RAM_SMW_Misc_ScratchRAM06
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l BlockBounceYSpeed,x
else
	LDA.w BlockBounceYSpeed,x
endif
	STA.w !RAM_SMW_BounceSpr_YSpeed,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l BlockBounceXSpeed,x
else
	LDA.w BlockBounceXSpeed,x
endif
	STA.w !RAM_SMW_BounceSpr_XSpeed,y
	TXA
	ORA.b !RAM_SMW_Misc_ScratchRAM08
	STA.w !RAM_SMW_BounceSpr_Properties,y
	LDA.b !RAM_SMW_Misc_ScratchRAM07	; \ Set tile to turn block into
	STA.w !RAM_SMW_BounceSpr_Map16TileToSpawn,y
	LDA.b #$08			; \ Time to show bouncing block
	STA.w !RAM_SMW_BounceSpr_Timer,y
	LDA.w !RAM_SMW_BounceSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_BounceSpr07_SpinningTurnBlock
	BNE.b CODE_02887A
	LDA.b #$FF
	STA.w !RAM_SMW_BounceSpr07_SpinningTurnBlock_DespawnTimer,y
CODE_02887A:
	JSR.w SMW_InitializeBlockPunchAttack_Main
; Subroutine to spawn an item from a block. What is spawned depends on the
; value of $05; see details for a list. This subroutine can be used in a
; custom block, but the data bank must be 02 and the lower nybbles of $98
; and $9A must be cleared. You should also preserve $1695 and then restore
; it after this routine to prevent a random splash sprite from spawning.
CODE_02887D:
if defined("Define_SMW_SA1")
	JML.l BLOCK_SPRITE_SPAWN_WRAPPER
else
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	BEQ.b Return0288A0
endif
	CMP.b #$0A
	BNE.b CODE_028885
CODE_028885:
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	CMP.b #$08
	BCS.b CODE_0288DC
	CMP.b #$06
	BCC.b CODE_0288DC
	CMP.b #$07
	BNE.b CODE_02889D
	LDA.w !RAM_SMW_Blocks_MultiCoinBlockTimer
	BNE.b CODE_02889D
	LDA.b #$FF
	STA.w !RAM_SMW_Blocks_MultiCoinBlockTimer
CODE_02889D:
	JSR.w SpawnSpinningCoins
Return0288A0:
	RTL

; The sprite which comes out of a Yoshi egg when spawned from a question
; mark block. The first byte is the sprite ID when no Yoshi exists and the
; second byte is the sprite ID when Yoshi does exist. By default, these are
; $35 (Yoshi) and $78 (1-up).
DATA_0288A1:
	db !Define_SMW_SpriteID_NorSpr035_Yoshi
	db !Define_SMW_SpriteID_NorSpr078_1upMushroom

SpriteInBlock:
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	; Sprite that, when Yoshi is not present, comes out of blocks 117, 118,
	; 11F, and 120 when small, and 16B regardless of status. (Mushroom)
	db !Define_SMW_SpriteID_NorSpr074_Mushroom
	; Sprite that comes out of blocks 117 and 11F when big (Flower)
	db !Define_SMW_SpriteID_NorSpr075_FireFlower
	; Sprite that comes out of blocks 119 and 121; also comes out of block 11A
	; (certain X-positions only) and 122 (all X-positions) when invincible
	; (Star)
	db !Define_SMW_SpriteID_NorSpr076_Star
	; Sprite that comes out of blocks 118 and 120 when big, and 16A regardless
	; of status (Feather)
	db !Define_SMW_SpriteID_NorSpr077_Feather
	; Sprite that comes out of block 11A (1up)
	;
	; Sprite that comes out of block 11A, and block 12D if at least 30 coins
	; have been collected. (1up)
	db !Define_SMW_SpriteID_NorSpr078_1upMushroom
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	; Sprite that comes out of block 11A(?) (Vine)
	db !Define_SMW_SpriteID_NorSpr079_VineHead
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	; Sprite that comes out of block 11D (POW)
	db !Define_SMW_SpriteID_NorSpr03E_PSwitch
	; Sprite that comes out of block 125 (Balloon - if changed, it will produce
	; the same sprite regardless of X position)
	db !Define_SMW_SpriteID_NorSpr07D_PBalloon
	; Sprite that comes out of block 126 (Yoshi egg)
	db !Define_SMW_SpriteID_NorSpr02C_YoshiEgg
	; Sprite that comes out of blocks 127 and 128 (Green shell)
	db !Define_SMW_SpriteID_NorSpr004_GreenKoopa
	; Sprite that comes out of block 12C (Changing Item)
	db !Define_SMW_SpriteID_NorSpr081_ChangingItem
	; Sprite that comes out of block 114 (Directional coins)
	db !Define_SMW_SpriteID_NorSpr045_DirectionalCoins
	db !Define_SMW_SpriteID_NorSpr080_Key

UNK_SpriteInBlockPow:
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	; Sprite that, when Yoshi is present, comes out of blocks 117, 118, 11F,
	; and 120 when small, and 16B regardless of status. (Mushroom)
	db !Define_SMW_SpriteID_NorSpr074_Mushroom
	; Sprite that comes out of block 117 when big (Flower), when Yoshi is
	; present.
	db !Define_SMW_SpriteID_NorSpr075_FireFlower
	; Sprite that comes out of block 119 (Star), when Yoshi is present.
	db !Define_SMW_SpriteID_NorSpr076_Star
	; Sprite that comes out of block 118 when big (Feather), when Yoshi is
	; present.
	db !Define_SMW_SpriteID_NorSpr077_Feather
	; Sprite that comes out of block 11A (1up), when Yoshi is present.
	;
	; Sprite that comes out of block 11A, and block 12D if at least 30 coins
	; have been collected, when Yoshi is present. (1up)
	db !Define_SMW_SpriteID_NorSpr078_1upMushroom
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	; Sprite that comes out of block 11A(?) (Vine), when Yoshi is present.
	db !Define_SMW_SpriteID_NorSpr079_VineHead
	db !Define_SMW_SpriteID_NorSpr000_GreenNakedKoopa
	; Sprite that comes out of block 11D (POW), when Yoshi is present.
	db !Define_SMW_SpriteID_NorSpr03E_PSwitch
	; Sprite that comes out of block 125 (Balloon - if changed, it will produce
	; the same sprite regardless of X position), if Yoshi is present.
	db !Define_SMW_SpriteID_NorSpr07D_PBalloon
	; Sprite that comes out of block 126 (Yoshi egg), if Yoshi is present.
	db !Define_SMW_SpriteID_NorSpr02C_YoshiEgg
	; Sprite that comes out of blocks 127 and 128 if Yoshi is present (Green
	; shell)
	db !Define_SMW_SpriteID_NorSpr004_GreenKoopa
	; Sprite that comes out of block 12C (Changing Item), if Yoshi is present.
	db !Define_SMW_SpriteID_NorSpr081_ChangingItem
	; Sprite that comes out of block 114 (Directional coins), if Yoshi is
	; present.
	db !Define_SMW_SpriteID_NorSpr045_DirectionalCoins
	db !Define_SMW_SpriteID_NorSpr080_Key

StatusOfSprInBlk:
	db !Define_SMW_NorSprStatus00_EmptySlot
	; Sprite in block status ($7E14C8 - $7E14D3) table.
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus00_EmptySlot
	db !Define_SMW_NorSprStatus00_EmptySlot
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus00_EmptySlot
	db !Define_SMW_NorSprStatus09_Stunned
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus09_Stunned
	db !Define_SMW_NorSprStatus09_Stunned
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus09_Stunned

; Sprites spawned by key/wings/balloon/shell block, indexed by its X
; position. Note that this table is only 3 bytes long, not 4 bytes; the
; shell actually comes from the key's sprite status.
DATA_0288D6:
	db !Define_SMW_SpriteID_NorSpr080_Key
	db !Define_SMW_SpriteID_NorSpr07E_FlyingRedCoin
	db !Define_SMW_SpriteID_NorSpr07D_PBalloon

; Sprite status of sprite spawned by the key/wings/balloon/shell block,
; indexed by its X position. Note that this table is only 3 bytes long, not
; 4 bytes; the shell is given an invalid sprite status.
DATA_0288D9:
	db !Define_SMW_NorSprStatus09_Stunned
	db !Define_SMW_NorSprStatus08_Normal
	db !Define_SMW_NorSprStatus08_Normal

CODE_0288DC:
	LDY.b !RAM_SMW_Misc_ScratchRAM05
	CPY.b #$0B
	BNE.b CODE_0288EA
	LDA.b !RAM_SMW_Blocks_XPosLo
	AND.b #$30
	CMP.b #$20
	BEQ.b GenSpriteFromBlk
CODE_0288EA:
	CPY.b #$10
	BEQ.b CODE_0288FD
	CPY.b #$08
	BNE.b CODE_0288F9
	LDA.w !RAM_SMW_Sprites_SpriteMemorySetting
	BEQ.b GenSpriteFromBlk
	BNE.b CODE_0288FD
CODE_0288F9:
	CPY.b #$0C
	BNE.b GenSpriteFromBlk
CODE_0288FD:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority
	TYX
	BPL.b CODE_028922
	RTL

; The subroutine that generates a sprite from a block (tile 120 or 125, for
; example). $02895F - Change from F0 to 80 to allow Directional Coins to
; reappear if you activate the block, then leave the area and come back.
GenSpriteFromBlk:
	LDX.b #!Define_SMW_MaxNormalSpriteSlot	; \ Find a last free sprite slot from 00-0B
CODE_028907:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	BEQ.b CODE_028922
	DEX
	CPX.b #$FF
	BNE.b CODE_028907
	DEC.w !RAM_SMW_NorSpr_SlotToOverwriteWhenSlotsFull
	BPL.b CODE_02891B
	LDA.b #!Define_SMW_StockMaxNormalSpriteSlot-$0A
	STA.w !RAM_SMW_NorSpr_SlotToOverwriteWhenSlotsFull
CODE_02891B:
	LDA.w !RAM_SMW_NorSpr_SlotToOverwriteWhenSlotsFull
	CLC
	ADC.b #!Define_SMW_MaxNormalSpriteSlot-$01
	TAX
CODE_028922:
if defined("Define_SMW_SA1")
	; SA-1 Pack: Blocks that spawn sprites need to update the pointer when
	; spawning a new sprite.
	JSL.l BLOCK_SPRITE_SPAWN_HACK
	NOP
else
	STX.w !RAM_SMW_Sprites_PowerUpFromBlockSpriteSlot
	LDY.b !RAM_SMW_Misc_ScratchRAM05
endif
	LDA.w StatusOfSprInBlk,y	; \ Set sprite status
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.w !RAM_SMW_Yoshi_StrayYoshiFlag
	BEQ.b CODE_028937
	TYA
	CLC
	ADC.b #$11
	TAY
CODE_028937:
	STY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	LDA.w SpriteInBlock,y		; \ Set sprite number
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDY.b #!Define_SMW_Sound1DFC_HitItemBlock
	CMP.b #!Define_SMW_SpriteID_NorSpr081_ChangingItem
	BCS.b CODE_02894C
	CMP.b #!Define_SMW_SpriteID_NorSpr079_VineHead
	BCC.b CODE_02894C
	INY								; Note: !Define_SMW_Sound1DFC_HitVineBlock
CODE_02894C:
	STY.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	INC.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr045_DirectionalCoins
	BNE.b CODE_028972
	LDA.w !RAM_SMW_NorSpr045_DirectionalCoins_NoRespawnFlag
	BEQ.b CODE_028967
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	JMP.w CODE_02889D

CODE_028967:
	LDA.b #!Define_SMW_LevelMusic_DirectCoins
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	INC.w !RAM_SMW_NorSpr045_DirectionalCoins_NoRespawnFlag
	STZ.w !RAM_SMW_NorSpr045_DirectionalCoins_DespawnTimer
CODE_028972:
	LDA.b !RAM_SMW_Blocks_XPosLo
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Blocks_XPosHi
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Blocks_YPosLo
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Blocks_YPosHi
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	BEQ.b CODE_0289A5
	LDA.b !RAM_SMW_Blocks_XPosLo
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Blocks_XPosHi
	SBC.b !RAM_SMW_Misc_SecondLevelLayerXPosHi
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Blocks_YPosLo
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Blocks_YPosHi
	SBC.b !RAM_SMW_Misc_SecondLevelLayerYPosHi
	STA.w !RAM_SMW_NorSpr_YPosHi,x
CODE_0289A5:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon
	BNE.b CODE_0289D3
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	AND.b #$30
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA.w DATA_0288D9,y
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.w DATA_0288D6,y
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	PHA
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLA
	CMP.b #!Define_SMW_SpriteID_NorSpr07D_PBalloon
	BNE.b CODE_0289CD
	INC.w !RAM_SMW_NorSpr_Table7E157C,x
	RTL

CODE_0289CD:
	CMP.b #!Define_SMW_SpriteID_NorSpr07E_FlyingRedCoin
	BEQ.b CODE_028A03
	BRA.b CODE_028A01

CODE_0289D3:
	CMP.b #!Define_SMW_SpriteID_NorSpr004_GreenKoopa
	BEQ.b ADDR_028A08
	CMP.b #!Define_SMW_SpriteID_NorSpr03E_PSwitch
	BEQ.b CODE_028A2A
	CMP.b #!Define_SMW_SpriteID_NorSpr02C_YoshiEgg
	BNE.b CODE_028A11
	LDY.b #!Define_SMW_MaxNormalSpriteSlot
CODE_0289E1:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b CODE_0289F3
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr02D_BabyYoshi
	BNE.b CODE_0289F3
CODE_0289EF:
	LDY.b #$01
	BRA.b CODE_0289FB

CODE_0289F3:
	DEY
	BPL.b CODE_0289E1
	LDY.w !RAM_SMW_Yoshi_StrayYoshiFlag
	BNE.b CODE_0289EF
CODE_0289FB:
	LDA.w DATA_0288A1,y
	STA.w !RAM_SMW_NorSpr02C_YoshiEgg_ContentsOfEgg,x
CODE_028A01:
	BRA.b CODE_028A0D

; If you change [F6 C2 F6 C2] to [EA EA EA EA], then tile 125 will spawn a
; flying red coin instead of Yoshi wings on X-coordinate (X&3 = $01).
CODE_028A03:
	INC.b !RAM_SMW_NorSpr_Table7E00C2,x
	INC.b !RAM_SMW_NorSpr_Table7E00C2,x
	RTL

; [A9 FF] Change to [80 03] or [A9 00] to prevent the stun timer of the
; shell spawned from blocks 127 and 128 from ever being set. It will just
; spawn as a plain shell rather than a shell that will "wake up". (Or you
; can change the second byte to a different value to make the stun timer
; shorter.)
ADDR_028A08:
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
CODE_028A0D:
	LDA.b #$D0
	BRA.b CODE_028A18

CODE_028A11:
	LDA.b #$3E
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	LDA.b #$D0
CODE_028A18:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$2C
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,x			;\ Note: !Define_SMW_NorSpr_190FProp_DontGetStuckInWallsWhenCarried
	BPL.b Return028A29						;/
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E15AC,x
Return028A29:
	RTL

CODE_028A2A:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	LSR
	LSR
	LSR
	LSR
	AND.b #$01
	STA.w !RAM_SMW_NorSpr_Table7E151C,x
	TAY
	LDA.w DATA_028A42,y
	STA.w !RAM_SMW_NorSpr_Table7E15F6,x
	JSL.l SMW_SpawnSmokePuff_Main
	BRA.b CODE_028A0D

; Colours of P-Switches (Blue, Silver) when spawned by tile 11D
DATA_028A42:
	db $06,$02
namespace off
endmacro

macro ROUTINE_RT01_SMW_SpawnBounceSprite(Address)
namespace SMW_SpawnBounceSprite
%InsertMacroAtXPosition(<Address>)

; Bounce sprite Y speed table, based on direction (or the value in $06
; during the routine at $028752).
BlockBounceYSpeed:
	db $C0,$00,$00,$40

; Bounce sprite X speed table, based on direction (or the value in $06
; during the routine at $028752).
BlockBounceXSpeed:
	db $00,$40,$C0,$00
namespace off
endmacro

macro ROUTINE_RT02_SMW_SpawnBounceSprite(Address)
namespace SMW_SpawnBounceSprite
%InsertMacroAtXPosition(<Address>)

; Subroutine for spawning the coin that comes out of a ? block (for example
; tile 124). It can be used in a custom block, but the low nybbles of $98
; and $9A must be cleared first. This subroutine ends with RTS, but it may
; be accessed with a JSL to $02889D.
SpawnSpinningCoins:
	LDX.b #!Define_SMW_MaxSpinningCoinSpriteSlot
CODE_028A68:
	LDA.w !RAM_SMW_BlockCoinSpr_SlotID,x
	BEQ.b CODE_028A7D
	DEX
	BPL.b CODE_028A68
	DEC.w !RAM_SMW_BlockCoinSpr_SlotToOverwriteWhenSlotsFull
	BPL.b ADDR_028A7A
	LDA.b #!Define_SMW_MaxSpinningCoinSpriteSlot
	STA.w !RAM_SMW_BlockCoinSpr_SlotToOverwriteWhenSlotsFull
ADDR_028A7A:
	LDX.w !RAM_SMW_BlockCoinSpr_SlotToOverwriteWhenSlotsFull
CODE_028A7D:
	JSL.l SMW_GiveCoins_OneCoin
	INC.w !RAM_SMW_BlockCoinSpr_SlotID,x
	LDA.b !RAM_SMW_Blocks_XPosLo
	STA.w !RAM_SMW_BlockCoinSpr_XPosLo,x
	LDA.b !RAM_SMW_Blocks_XPosHi
	STA.w !RAM_SMW_BlockCoinSpr_XPosHi,x
	LDA.b !RAM_SMW_Blocks_YPosLo
	SEC
	SBC.b #$10
	STA.w !RAM_SMW_BlockCoinSpr_YPosLo,x
	LDA.b !RAM_SMW_Blocks_YPosHi
	SBC.b #$00
	STA.w !RAM_SMW_BlockCoinSpr_YPosHi,x
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	STA.w !RAM_SMW_BlockCoinSpr_LayerIndex,x
	LDA.b #$D0
	STA.w !RAM_SMW_BlockCoinSpr_YSpeed,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnSmokePuff(Address)
namespace SMW_SpawnSmokePuff
%InsertMacroAtXPosition(<Address>)

; Subroutine for generating smoke when hitting a block. You can use this in
; a custom block, but be sure to set up $98 and $9A accordingly.
Main:
	PHX
	LDX.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_028A47:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,x
	BEQ.b CODE_028A50
	DEX
	BPL.b CODE_028A47
	INX
CODE_028A50:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr01_PuffOfSmoke
	STA.w !RAM_SMW_SmokeSpr_SpriteID,x
	LDA.b !RAM_SMW_Blocks_YPosLo
	STA.w !RAM_SMW_SmokeSpr_YPosLo,x
	LDA.b !RAM_SMW_Blocks_XPosLo
	STA.w !RAM_SMW_SmokeSpr_XPosLo,x
	LDA.b #$1B
	STA.w !RAM_SMW_SmokeSpr_Timer,x
	PLX
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeBlockPunchAttack(Address)
namespace SMW_InitializeBlockPunchAttack
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #!Define_SMW_MaxBounceSpriteSlot
CODE_0286EF:
	LDA.w !RAM_SMW_BounceSpr_Type,y
	BEQ.b CODE_0286F8
	DEY
	BPL.b CODE_0286EF
	INY
CODE_0286F8:
	LDA.b !RAM_SMW_Blocks_XPosLo
	STA.w !RAM_SMW_BounceSpr_HitboxXLo,y
	LDA.b !RAM_SMW_Blocks_XPosHi
	STA.w !RAM_SMW_BounceSpr_HitboxXHi,y
	LDA.b !RAM_SMW_Blocks_YPosLo
	STA.w !RAM_SMW_BounceSpr_HitboxYLo,y
	LDA.b !RAM_SMW_Blocks_YPosHi
	STA.w !RAM_SMW_BounceSpr_HitboxYHi,y
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	BEQ.b CODE_02872F
	LDA.b !RAM_SMW_Blocks_XPosLo
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo
	STA.w !RAM_SMW_BounceSpr_HitboxXLo,y
	LDA.b !RAM_SMW_Blocks_XPosHi
	SBC.b !RAM_SMW_Misc_SecondLevelLayerXPosHi
	STA.w !RAM_SMW_BounceSpr_HitboxXHi,y
	LDA.b !RAM_SMW_Blocks_YPosLo
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo
	STA.w !RAM_SMW_BounceSpr_HitboxYLo,y
	LDA.b !RAM_SMW_Blocks_YPosHi
	SBC.b !RAM_SMW_Misc_SecondLevelLayerYPosHi
	STA.w !RAM_SMW_BounceSpr_HitboxYHi,y
CODE_02872F:
	LDA.b #$01
	STA.w !RAM_SMW_BounceSpr_Type,y
	LDA.b #$06
	STA.w !RAM_SMW_BounceSpr_InteractTimer,y
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_BobOmbExplosion(Address)
namespace SMW_BobOmbExplosion
%InsertMacroAtXPosition(<Address>)

; Bob-omb explosion x spacing
BombExplosionX:
	db $00,$08,$06,$FA,$F8,$06,$08,$00
	db $F8,$FA

; Bob-omb explosion y spacing
BombExplosionY:
	db $F8,$FE,$06,$06,$FE,$FA,$02,$08
	db $02,$FA

; Explode Bomb Subroutine. JSL to it each frame to make your sprite explode,
; but remember to load $1540,x with the explosion timer and setting the data
; bank to 02 (or 82) first. $02808E is Bob-omb explosion area $028114 is
; Bob-omb's explosion GFX tile If you change $02811E from 38 to 18 (i.e.
; change SEC to CLC), the Bob-omb explosion will use the first graphics
; page.
Main:
	JSR.w Sub			;BOMB
	RTL

Sub:
	STZ.w !RAM_SMW_NorSpr_PropertyBits1656,x	; Make sprite unstompable
	LDA.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping11	; \ Set new clipping area for explosion
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Increase frame count if sprites not locked
	BNE.b CODE_02809C
	INC.w !RAM_SMW_NorSpr_Table7E1570,x
CODE_02809C:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x	; \ When timer is up free up sprite slot
	BNE.b ExplodeBombGfx
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

ExplodeBombGfx:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	LSR
	AND.b #$03
	CMP.b #$03
	BNE.b CODE_0280C0
	JSR.w ExplodeSprites
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	SEC
	SBC.b #$10
	CMP.b #$20
	BCS.b CODE_0280C0
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
CODE_0280C0:
	LDY.b #$04
	STY.b !RAM_SMW_Misc_ScratchRAM0F
CODE_0280C4:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	LSR
	PHA
	AND.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	PLA
	AND.b #$04
	BEQ.b CODE_0280ED
	TYA
	CLC
	ADC.b #$05
	TAY
CODE_0280ED:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w BombExplosionX,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w BombExplosionY,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	BPL.b CODE_0280ED
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	ASL
	ASL
	ADC.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$BC
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	LSR
	AND.b #$03
	SEC
	ROL
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	DEC.b !RAM_SMW_Misc_ScratchRAM0F
	BPL.b CODE_0280C4
	LDY.b #$00
	LDA.b #$04
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

ExplodeSprites:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02	; \ Loop over sprites:
ExplodeLoopStart:
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID	; | Don't attempt to kill self
	BEQ.b CODE_02814C
	PHY
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	; | Skip sprite if it's already dying/dead
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b CODE_02814B
	JSR.w ExplodeKillSpr		; | Check for contact
CODE_02814B:
	PLY
CODE_02814C:
	DEY				; | Next
	BPL.b ExplodeLoopStart
	RTS

ExplodeKillSpr:
	PHX
	TYX				; \ Return if no sprite contact
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingB
	PLX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return028177
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,y	; \ Return if sprite is invincible
	AND.b #!Define_SMW_NorSpr_167AProp_InvincibleToMostThings	; | to explosions
	BNE.b Return028177
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #$C0			; \ Sprite Y speed = #$C0
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	LDA.b #$00			; \ Sprite X speed = #$00
	STA.w !RAM_SMW_NorSpr_XSpeed,y
Return028177:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr01E_Lakitu_Status08(Address)
namespace SMW_NorSpr01E_Lakitu_Status08
%InsertMacroAtXPosition(<Address>)

LakituFishingLineGFXRt:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSR.w SMW_GetDrawInfo_Bank02
	TYA
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$0D
	STA.w SMW_OAMBuffer[$40].XDisp,y
	SEC
	SBC.b #$08
	STA.w !RAM_SMW_NorSpr01E_Lakitu_FishingLineXDisp
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$02
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w !RAM_SMW_NorSpr01E_Lakitu_FishingLineYDisp
	CLC
	ADC.b #$40
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.b #$AA
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$24
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b #$35
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b #$3A
	STA.w SMW_OAMBuffer[$41].Prop,y
	LDA.b #$01
	LDY.b #$02
	JSR.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BNE.b CODE_02E6EB
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_Player_OnScreenPosXLo
	SEC
	SBC.w SMW_OAMBuffer[$41].XDisp,y
	CLC
	ADC.b #$0C
	CMP.b #$18
	BCS.b CODE_02E6EB
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	SEC
	SBC.w SMW_OAMBuffer[$41].YDisp,y
	CLC
	ADC.b #$0C
	CMP.b #$18
	BCS.b CODE_02E6EB
	STZ.w !RAM_SMW_NorSpr01E_Lakitu_FishingFlag,x
	JSL.l SMW_SpawnScoreSpriteAtPlayerPosition_LakituEntry
CODE_02E6EB:
	PHX
if defined("Define_SMW_SA1")
	; SA-1 Pack: Lakitu should not use a hard-coded OAM index for the fishing
	; line.
	JSL.l fishing_line_fix
	NOP
else
	LDA.b #$38
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
endif
	TAY
	LDX.b #$07
CODE_02E6F4:
	LDA.w !RAM_SMW_NorSpr01E_Lakitu_FishingLineXDisp
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w !RAM_SMW_NorSpr01E_Lakitu_FishingLineYDisp
	STA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_NorSpr01E_Lakitu_FishingLineYDisp
	LDA.b #$89
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$35
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_02E6F4
	PLX
	LDA.b #$07
	LDY.b #$00
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr02B_SumoLightning_Status08(Address)
namespace SMW_NorSpr02B_SumoLightning_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.w !RAM_SMW_NorSpr02B_SumoLightning_SpawnFireTimer,x
	BNE.b CODE_02DEFC
	LDA.b #$30
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.w !RAM_SMW_NorSpr02B_SumoLightning_DisableBlockCollisionTimer,x
	BNE.b CODE_02DEEA
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02DEEA
	LDA.b #!Define_SMW_Sound1DFC_FireSpit	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$22
	STA.w !RAM_SMW_NorSpr02B_SumoLightning_SpawnFireTimer,x
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b CODE_02DEEA
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Blocks_YPosLo
	JSL.l SMW_SpawnSmokePuff_Main
CODE_02DEEA:
	LDA.b #$00
	JSL.l SMW_GenericGFXRtDraw4Tiles8x8Square_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$41].Prop,y
	EOR.b #$C0
	STA.w SMW_OAMBuffer[$41].Prop,y
	RTS

CODE_02DEFC:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b #$01
	BNE.b CODE_02DF05
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
CODE_02DF05:
	AND.b #$0F
	CMP.b #$01
	BNE.b Return02DF21
	STA.w !RAM_SMW_Flag_RunClusterSprites
	JSR.w CODE_02DF2C
	INC.w !RAM_SMW_NorSpr02B_SumoLightning_NumberOfFlamesSpawned,x
	LDA.w !RAM_SMW_NorSpr02B_SumoLightning_NumberOfFlamesSpawned,x
	CMP.b #$01
	BEQ.b Return02DF21
	JSR.w CODE_02DF2C
	INC.w !RAM_SMW_NorSpr02B_SumoLightning_NumberOfFlamesSpawned,x
Return02DF21:
	RTS

FireInitialXPosLo:
	db $FC,$0C,$EC,$1C,$DC

FireInitialXPosHi:
	db $FF,$00,$FF,$00,$FF

CODE_02DF2C:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.b #!Define_SMW_MaxClusterSpriteSlot-$0A
CODE_02DF37:
	LDA.w !RAM_SMW_ClusterSpr_SpriteID,y
	BEQ.b CODE_02DF4C
	DEY
	BPL.b CODE_02DF37
	DEC.w !RAM_SMW_ClusterSpr_SlotToOverwriteWhenSlotsFull
	BPL.b CODE_02DF49
	LDA.b #!Define_SMW_MaxClusterSpriteSlot-$0A
	STA.w !RAM_SMW_ClusterSpr_SlotToOverwriteWhenSlotsFull
CODE_02DF49:
	LDY.w !RAM_SMW_ClusterSpr_SlotToOverwriteWhenSlotsFull
CODE_02DF4C:
	PHX
	LDA.w !RAM_SMW_NorSpr02B_SumoLightning_NumberOfFlamesSpawned,x
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w FireInitialXPosLo,x
	STA.w !RAM_SMW_ClusterSpr_XPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	ADC.w FireInitialXPosHi,x
	STA.w !RAM_SMW_ClusterSpr_XPosHi,y
	PLX
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b #$10
	STA.w !RAM_SMW_ClusterSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SEC
	SBC.b #$00
	STA.w !RAM_SMW_ClusterSpr_YPosHi,y
	LDA.b #$7F
	STA.w !RAM_SMW_ClusterSpr06_SumoBroFlame_DespawnTimer,y
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,y
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.w !RAM_SMW_ClusterSpr_XPosHi,y
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b Return02DF8A
	LDA.b #!Define_SMW_SpriteID_ClusterSpr06_SumoBroFlame
	STA.w !RAM_SMW_ClusterSpr_SpriteID,y
Return02DF8A:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_CheckIfBabyYoshiCanEatNormalSprite(Address)
namespace SMW_CheckIfBabyYoshiCanEatNormalSprite
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot
CODE_02EA50:
	TYA
	CMP.w !RAM_SMW_NorSpr_Table7E160E,x
	BEQ.b CODE_02EA86
	EOR.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCS.b CODE_02EA86
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID
	BEQ.b CODE_02EA86
	STY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b CODE_02EA86
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr070_Pokey
	BEQ.b CODE_02EA86
	CMP.b #!Define_SMW_SpriteID_NorSpr00E_Keyhole
	BEQ.b CODE_02EA86
	CMP.b #!Define_SMW_SpriteID_NorSpr01D_HoppingFlame
	BCC.b CODE_02EA83
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,y
	AND.b #!Define_SMW_NorSpr_1686Prop_Inedible|!Define_SMW_NorSpr_1686Prop_StayInYoshisMouth
	ORA.w !RAM_SMW_GrowingYoshiTimer
	BNE.b CODE_02EA86
CODE_02EA83:
	JSR.w CODE_02EA8A
CODE_02EA86:
	DEY
	BPL.b CODE_02EA50
	RTL

CODE_02EA8A:
	PHX
	TYX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingB
	PLX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return02EACD
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	BEQ.b CODE_02EAA9
	JSL.l BabyYoshiCanEatSprite
	LDA.w !RAM_SMW_GrowingYoshiTimer
	BNE.b ADDR_02EACE
CODE_02EAA9:
	LDA.b #$37
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	LDY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	STA.w !RAM_SMW_NorSpr_CurrentLayerPriority,y
	LDA.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	STA.w !RAM_SMW_NorSpr_Table7E160E,x
	STZ.w !RAM_SMW_NorSpr_Table7E157C,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CMP.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	SBC.w !RAM_SMW_NorSpr_XPosHi,y
	BCC.b Return02EACD
	INC.w !RAM_SMW_NorSpr_Table7E157C,x
Return02EACD:
	RTS

ADDR_02EACE:
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SetBabyYoshiDynamicGraphicsPointer(Address)
namespace SMW_SetBabyYoshiDynamicGraphicsPointer
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w SMW_OAMBuffer[$40].Tile,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$06
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
	SEP.b #$20			; A->8
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_WallFollowers_Status08(Address)
namespace SMW_NorSprXXX_WallFollowers_Status08
%InsertMacroAtXPosition(<Address>)

XSpeed:
	db $08,$00,$F8,$00
	db $F8,$00,$08,$00

YSpeed:
	db $00,$08,$00,$F8
	db $00,$08,$00,$F8

DATA_02BC9F:
	db $01,$FF,$FF,$01
	db $FF,$01,$01,$FF

DATA_02BCA7:
	db $01,$01,$FF,$FF
	db $01,$01,$FF,$FF

DATA_02BCAF:
	db $01,$04,$02,$08
	db $02,$04,$01,$08

SpikeTopAnimationFramesOffset:
	db $00,$02,$00,$02
	db $00,$02,$00,$02
	db $05,$04,$05,$04
	db $05,$04,$05,$04

SpikeTopDirection:
	db $00,$C0,$C0,$00
	db $40,$80,$80,$40
	db $80,$C0,$40,$00
	db $C0,$80,$00,$40

UrchinAnimationFrames:
	db $00,$01,$02,$01

Bank02:
	JSL.l SMW_CheckForNormalSpriteToNormalSpriteCollision_Main
	JSL.l SMW_GetRand_Main
	AND.b #$FF
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02BCEE
	LDA.b #$0C
	STA.w !RAM_SMW_NorSprXXX_WallFollowers_BlinkingAnimationTimer,x
CODE_02BCEE:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if not Spike Top
	CMP.b #!Define_SMW_SpriteID_NorSpr02E_SpikeTop
	BNE.b CODE_02BD23
	LDY.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	LDA.w !RAM_SMW_NorSpr02E_SpikeTop_DiagonalAnimationFrameTimer,x
	BEQ.b CODE_02BD04
	TYA
	CLC
	ADC.b #$08
	TAY
	LDA.b #$00
	BRA.b CODE_02BD0B

CODE_02BD04:
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	AND.b #$01
CODE_02BD0B:
	CLC
	ADC.w SpikeTopAnimationFramesOffset,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	AND.b #$3F
	ORA.w SpikeTopDirection,y
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	BRA.b CODE_02BD2F

CODE_02BD23:
	CMP.b #!Define_SMW_SpriteID_NorSpr0A5_Sparky
	BCC.b CODE_02BD2C
	JSR.w SparkyGFXRt
	BRA.b CODE_02BD2F

CODE_02BD2C:
	JSR.w UrchinGFXRt
CODE_02BD2F:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_02BD3F
	STZ.w !RAM_SMW_NorSprXXX_Urchins_AnimationFrameCounter,x
	LDA.b #$FF
	STA.w !RAM_SMW_NorSprXXX_WallFollowers_BlinkingAnimationTimer,x
	RTL

CODE_02BD3F:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02BD74
	JSR.w SMW_SubOffscreen_Bank02_Entry4
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if Spike Top
	CMP.b #!Define_SMW_SpriteID_NorSpr02E_SpikeTop
	BEQ.b CODE_02BDA7
	CMP.b #!Define_SMW_SpriteID_NorSpr03C_WallFollowUrchin	; \ Branch if Wall-follow Urchin
	BEQ.b CODE_02BDB3
	CMP.b #!Define_SMW_SpriteID_NorSpr0A5_Sparky	; \ Branch if Ground-guided Fuzzball/Sparky
	BEQ.b CODE_02BDB3
	CMP.b #!Define_SMW_SpriteID_NorSpr0A6_Hothead	; \ Branch if Ground-guided Hothead
	BEQ.b CODE_02BDB3
	LDA.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	AND.b #$01
	JSL.l SMW_ExecutePtr_Absolute

UrchinPtrs:
	dw CODE_02BD68
	dw CODE_02BD75

CODE_02BD68:
	LDA.w !RAM_SMW_NorSpr03A_FixedUrchin_PhaseTimer,x
	BNE.b Return02BD74
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr03A_FixedUrchin_PhaseTimer,x
	INC.b !RAM_SMW_NorSpr03A_FixedUrchin_CurrentState,x
Return02BD74:
	RTL

CODE_02BD75:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if Wall-detect Urchin
	CMP.b #!Define_SMW_SpriteID_NorSpr03B_WallDetectUrchin
	BEQ.b CODE_02BD80
	LDA.w !RAM_SMW_NorSpr03A_FixedUrchin_PhaseTimer,x
	BEQ.b CODE_02BD91
CODE_02BD80:
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$0F
	BEQ.b Return02BDA6
CODE_02BD91:
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr03A_FixedUrchin_PhaseTimer,x
	INC.b !RAM_SMW_NorSpr03A_FixedUrchin_CurrentState,x
Return02BDA6:
	RTL

; Code that handles erasing Spike Tops that go offscreen vertically. Set to
; [80 0A] (BRA $0A) to disable this behavior, however keep in mind that this
; means the sprites will be able to walk around the underside of your level.
CODE_02BDA7:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$E0
	BCC.b CODE_02BDB3
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
CODE_02BDB3:
	LDA.w !RAM_SMW_NorSprXXX_WallFollowers_TurnOnCornerTimer,x
	BNE.b CODE_02BDE7
	LDY.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	LDA.w DATA_02BCA7,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.w DATA_02BC9F,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$0F
	BNE.b CODE_02BDE7
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr02E_SpikeTop_DiagonalAnimationFrameTimer,x
	LDA.b #$38
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached	; \ Branch if Wall-follow Urchin
	CPY.b #!Define_SMW_SpriteID_NorSpr03C_WallFollowUrchin
	BEQ.b CODE_02BDE4
	LDA.b #$1A
	CPY.b #!Define_SMW_SpriteID_NorSpr0A5_Sparky
	BNE.b CODE_02BDE4
	LSR
	NOP
CODE_02BDE4:
	STA.w !RAM_SMW_NorSprXXX_WallFollowers_TurnOnCornerTimer,x
CODE_02BDE7:
	LDA.b #$20
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached	; \ Branch if Wall-follow Urchin
	CPY.b #!Define_SMW_SpriteID_NorSpr03C_WallFollowUrchin
	BEQ.b CODE_02BDF7
	LDA.b #$10
	CPY.b #!Define_SMW_SpriteID_NorSpr0A5_Sparky
	BNE.b CODE_02BDF7
	LSR
	NOP
CODE_02BDF7:
	CMP.w !RAM_SMW_NorSprXXX_WallFollowers_TurnOnCornerTimer,x
	BNE.b CODE_02BE0E
	INC.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	LDA.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	CMP.b #$04
	BNE.b CODE_02BE06
	STZ.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
CODE_02BE06:
	CMP.b #$08
	BNE.b CODE_02BE0E
	LDA.b #$04
	STA.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
CODE_02BE0E:
	LDY.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.w DATA_02BCAF,y
	BEQ.b CODE_02BE2F
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr02E_SpikeTop_DiagonalAnimationFrameTimer,x
	DEC.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	LDA.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	BPL.b CODE_02BE27
	LDA.b #$03
	BRA.b CODE_02BE2D

CODE_02BE27:
	CMP.b #$03
	BNE.b CODE_02BE2F
	LDA.b #$07
CODE_02BE2D:
	STA.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
CODE_02BE2F:
	LDY.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	LDA.w YSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	; \ Branch if not Ground-guided Fuzzball/Sparky
	CMP.b #!Define_SMW_SpriteID_NorSpr0A5_Sparky
	BNE.b CODE_02BE45
	ASL.b !RAM_SMW_NorSpr_XSpeed,x
	ASL.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02BE45:
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	RTL

FuzzyProp:
	db $05,$45

SparkyGFXRt:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr0A5_Sparky
	BNE.b HotheadGFXRt
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting
	; Change from "C9 02 D0 17" to "C9 01 F0 17" to make Fuzzies/Sparkies to
	; only use the latter's tilemap in the castle (01) sprite tileset, as
	; opposed to using the sparky's tilemap in every sprite tileset apart from
	; the mushroom (02).
	CMP.b #$02
	BNE.b CODE_02BE79
	PHX
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$01
	TAX
	LDA.b #$C8
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w FuzzyProp,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	RTS

CODE_02BE79:
	LDA.b #$0A
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$0C
	ASL
	ASL
	ASL
	ASL
	EOR.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$40].Prop,y
	RTS

HotheadXDisp:
	db $F8,$08,$F8,$08

HotheadYDisp:
	db $F8,$F8,$08,$08

; Hothead Tilemap
HotheadTiles:
	db $0C,$0E,$0E
	db $0C,$0E,$0C,$0C,$0E

HotheadProp:
	db $05,$05,$C5,$C5
	db $45,$45,$85,$85

HotheadEyesXDisp:
	db $07,$07,$01,$01
	db $01,$01,$07,$07

HotheadEyesYDisp:
	db $00,$08,$08,$00
	db $00,$08,$08,$00

HotheadGFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	TYA
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PHX
	LDX.b #$03
CODE_02BEC9:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w HotheadXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w HotheadYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX
	TXA
	ORA.b !RAM_SMW_Misc_ScratchRAM03
	TAX
	LDA.w HotheadTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w HotheadProp,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_02BEC9
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	PHA
	LDY.b #$02
	LDA.b #$03
	JSR.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM01
	PLA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$09
	LDY.w !RAM_SMW_NorSprXXX_WallFollowers_BlinkingAnimationTimer,x
	BEQ.b CODE_02BF13
	LDA.b #$19
CODE_02BF13:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	SEC
	SBC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	PHX
	LDA.b !RAM_SMW_NorSprXXX_WallFollowers_SideOfBlockSpriteIsOn,x
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w HotheadEyesXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w HotheadEyesYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$05
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	LDY.b #$00
	LDA.b #$00
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

UrchinXDisp:
	db $08,$00,$10,$00,$10

UrchinYDisp:
	db $08,$00,$00,$10,$10

; Urchin YXPPCCCT properties, eyes and body. Order: Eyes, upper left body
; part, upper right, lower left, lower right.
UrchinProp:
	db $37,$37,$77,$B7,$F7

; Urchin's Body Tilemap
UrchinTiles:
	db $C4,$C6,$C8,$C6

UrchinGFXRt:
	LDA.w !RAM_SMW_NorSprXXX_Urchins_AnimationTimer,x
	BNE.b CODE_02BF69
	INC.w !RAM_SMW_NorSprXXX_Urchins_AnimationFrameCounter,x
	LDA.b #$0C
	STA.w !RAM_SMW_NorSprXXX_Urchins_AnimationTimer,x
CODE_02BF69:
	LDA.w !RAM_SMW_NorSprXXX_Urchins_AnimationFrameCounter,x
	AND.b #$03
	TAY
	LDA.w UrchinAnimationFrames,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_GetDrawInfo_Bank02
	STZ.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSprXXX_WallFollowers_BlinkingAnimationTimer,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
CODE_02BF84:
	LDX.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l UrchinXDisp,x
else
	ADC.w UrchinXDisp,x
endif
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l UrchinYDisp,x
else
	ADC.w UrchinYDisp,x
endif
	STA.w SMW_OAMBuffer[$40].YDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l UrchinProp,x
else
	LDA.w UrchinProp,x
endif
	STA.w SMW_OAMBuffer[$40].Prop,y
	CPX.b #$00
	BNE.b CODE_02BFAC
	LDA.b #$CA
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	BEQ.b CODE_02BFAA
	LDA.b #$CC
CODE_02BFAA:
	BRA.b CODE_02BFB1

CODE_02BFAC:
	LDX.b !RAM_SMW_Misc_ScratchRAM02
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l UrchinTiles,x
else
	LDA.w UrchinTiles,x
endif
CODE_02BFB1:
	STA.w SMW_OAMBuffer[$40].Tile,y
	INY
	INY
	INY
	INY
	INC.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	CMP.b #$05
	BNE.b CODE_02BF84
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDY.b #$02
	JMP.w SMW_NorSpr091_CharginChuck_Status08_CODE_02C82B
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr033_Podoboo_Status08(Address)
namespace SMW_NorSpr033_Podoboo_Status08
%InsertMacroAtXPosition(<Address>)

SpawnPodobooFire:
	JSR.w SMW_CheckIfNormalSpriteOffScreen_CopyOfBank02
	BNE.b Return0285EE
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot
CODE_0285E6:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y
	BEQ.b CODE_0285EF
	DEY
	BPL.b CODE_0285E6
Return0285EE:
	RTL

CODE_0285EF:
	JSL.l SMW_GetRand_Main
	LDA.b #!Define_SMW_SpriteID_MExtSpr04_PodobooFire
	STA.w !RAM_SMW_MExtSpr_SpriteID,y
	LDA.b #$00
	STA.w !RAM_SMW_MExtSpr_YSpeed,y
	LDA.w !RAM_SMW_Misc_RandomByte1
	AND.b #$0F
	SEC
	SBC.b #$03
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_MExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_MExtSpr_XPosHi,y
	LDA.w !RAM_SMW_Misc_RandomByte2
	AND.b #$07
	CLC
	ADC.b #$07
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_MExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_MExtSpr_YPosHi,y
	LDA.b #$17
	STA.w !RAM_SMW_MExtSpr_Timer,y
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr035_Yoshi_Status08(Address)
namespace SMW_NorSpr035_Yoshi_Status08
%InsertMacroAtXPosition(<Address>)

; Subroutine called by Yoshi that was originally supposed to show some smoke
; particles when the player mounts him, but it was eventually disabled.
; Change $028BB4 from $B8 to $B9 to re-enable this effect.
SpawnUnusedYoshiSmoke:
	PHB				; \ This routine does nothing at all
	PHK				; | I believe it used to call the below
	PLB				; | routine to add smoke when boarding
	JSR.w .Return			; | Yoshi
	PLB
	RTL

.Return:
	RTS

Sub:
	STZ.b !RAM_SMW_Misc_ScratchRAM00	; \ Display smoke when getting on Yoshi
	JSR.w ADDR_028BC0
	INC.b !RAM_SMW_Misc_ScratchRAM00
ADDR_028BC0:
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot
ADDR_028BC2:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y
	BEQ.b ADDR_028BCB
	DEY
	BPL.b ADDR_028BC2
	RTS

ADDR_028BCB:
	LDA.b #!Define_SMW_SpriteID_MExtSpr0B_UnusedYoshiSmoke
	STA.w !RAM_SMW_MExtSpr_SpriteID,y
	LDA.b #$00
	STA.w !RAM_SMW_MExtSpr_Timer,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$1C
	STA.w !RAM_SMW_MExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_MExtSpr_YPosHi,y
	LDA.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Player_XPosHi
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w DATA_028C09,x
	STA.w !RAM_SMW_MExtSpr_XSpeed,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.w DATA_028C0B,x
	STA.w !RAM_SMW_MExtSpr_XPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	ADC.w DATA_028C0D,x
	STA.w !RAM_SMW_MExtSpr_XPosHi,y
	PLX
	RTS

DATA_028C09:
	db $40,$C0

DATA_028C0B:
	db $0C,$FC

DATA_028C0D:
	db $00,$FF
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr035_Yoshi_Status08(Address)
namespace SMW_NorSpr035_Yoshi_Status08
%InsertMacroAtXPosition(<Address>)

DATA_02BB0B:
	db $02,$FA,$06,$06

DATA_02BB0F:
	db $00,$FF,$00,$00

DATA_02BB13:
	db $10,$08,$10,$08

; Sprite tilemap: Yoshi Wings
Tiles:
	db $5D,$C6,$5D,$C6

; Palette/Gfx page/Priority/Flip of Yoshi Wing tiles
Prop:
	db $46,$46,$06,$06

; Size of Yoshi Wing tiles
TileSize:
	db $00,$02,$00,$02

DrawYoshisWings:
;$02BB23
	; Subroutine for drawing and animating Yoshi's wings.
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_CheckIfNormalSpriteOffScreen_Bank02
	BNE.b Return02BB87
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.b #$F8
	PHX
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.l DATA_02BB0B,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	ADC.l DATA_02BB0F,x
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$00].XDisp,y
	PLA
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b CODE_02BB86
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.l DATA_02BB13,x
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.l Tiles,x
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.l Prop,x
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.l TileSize,x
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
CODE_02BB86:
	PLX
Return02BB87:
	RTL
namespace off
endmacro

macro ROUTINE_RT03_SMW_NorSpr035_Yoshi_Status08(Address)
namespace SMW_NorSpr035_Yoshi_Status08
%InsertMacroAtXPosition(<Address>)

DATA_02D0D0:
	db $14,$FC

DATA_02D0D2:
	db $00,$FF

CheckForBerryTileCollisionWithAdultYoshiMouth:
	LDA.w !RAM_SMW_NorSpr035_Yoshi_SwallowAnimationTimer,x
	BNE.b Return02D0E5
	LDA.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	BPL.b Return02D0E5
	PHB
	PHK
	PLB
	JSR.w CODE_02D0E6
	PLB
Return02D0E5:
	RTL

CODE_02D0E6:
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	BRA.b CODE_02D149

ADDR_02D0EA:								;\ Note: This routine doesn't appear to be used.
	LDA.b !RAM_SMW_NorSpr_YPosLo_x					;| It seems to be a vertical level version of the below routine, but it doesn't quite work correctly.
	CLC								;| Glitch: Speaking of which, Yoshi's berry interaction is buggy in vertical levels.
	ADC.b #$08							;|
	AND.b #$F0							;|
	STA.b !RAM_SMW_Misc_ScratchRAM00				;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x					;|
	ADC.b #$00							;|
	CMP.b !RAM_SMW_Misc_ScreensInLvl				;|
	BCS.b Return02D148						;|
	STA.b !RAM_SMW_Misc_ScratchRAM03				;|
	AND.b #$10							;|
	STA.b !RAM_SMW_Misc_ScratchRAM08				;|
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x				;|
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;|
	CLC								;|
	ADC.w DATA_02D0D0,y						;|
	STA.b !RAM_SMW_Misc_ScratchRAM01				;|
	LDA.w !RAM_SMW_NorSpr_XPosHi,x					;|
	ADC.w DATA_02D0D2,y						;|
	CMP.b #$02							;|
	BCS.b Return02D148						;|
	STA.b !RAM_SMW_Misc_ScratchRAM02				;|
	LDA.b !RAM_SMW_Misc_ScratchRAM01				;|
	LSR								;|
	LSR								;|
	LSR								;|
	LSR								;|
	ORA.b !RAM_SMW_Misc_ScratchRAM00				;|
	STA.b !RAM_SMW_Misc_ScratchRAM00				;|
	LDX.b !RAM_SMW_Misc_ScratchRAM03				;|
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L1,x	;|
	LDY.b !RAM_SMW_Misc_ScratchRAM0F				;|
	BEQ.b ADDR_02D131						;|
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L2,x	;|
ADDR_02D131:								;|
	CLC								;|
	ADC.b !RAM_SMW_Misc_ScratchRAM00				;|
	STA.b !RAM_SMW_Misc_ScratchRAM05				;|
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L1,x	;|
	LDY.b !RAM_SMW_Misc_ScratchRAM0F				;|
	BEQ.b ADDR_02D142						;|
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L2,x	;|
ADDR_02D142:								;|
	ADC.b !RAM_SMW_Misc_ScratchRAM02				;|
	STA.b !RAM_SMW_Misc_ScratchRAM06				;|
	BRA.b CODE_02D1AD						;/

Return02D148:
	RTS

CODE_02D149:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $18B2 = Sprite Y position + #$08
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_Yoshi_YPosLo
	AND.b #$F0			; \ $00 = (Sprite Y position + #$08) rounded down to closest #$10 low byte
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00			; | Return if off screen
	CMP.b #$02
	BCS.b Return02D148
	STA.b !RAM_SMW_Misc_ScratchRAM02	; | $02 = (Sprite Y position + #$08) High byte
	STA.w !RAM_SMW_Yoshi_YPosHi
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x	; \ $18B0 = Sprite X position + $0014/$FFFC
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w DATA_02D0D0,y
	STA.b !RAM_SMW_Misc_ScratchRAM01	; | $01 = (Sprite X position + $0014/$FFFC) Low byte
	STA.w !RAM_SMW_Yoshi_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.w DATA_02D0D2,y
	CMP.b !RAM_SMW_Misc_ScreensInLvl	; | Return if past end of level
	BCS.b Return02D148
	STA.w !RAM_SMW_Yoshi_XPosHi
	STA.b !RAM_SMW_Misc_ScratchRAM03	; / $03 = (Sprite X position + $0014/$FFFC) High byte
	LDA.b !RAM_SMW_Misc_ScratchRAM01	; \ $00 = bits 4-7 of Y position, bits 4-7 of X position
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_02D198
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L2,x
CODE_02D198:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_02D1A9
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L2,x
CODE_02D1A9:
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06
CODE_02D1AD:
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	INC.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	BNE.b Return02D1F0
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	CMP.b #$45
	BCC.b Return02D1F0
	CMP.b #$48
	BCS.b Return02D1F0
	SEC
	SBC.b #$44
	STA.w !RAM_SMW_Yoshi_BerryBeingEaten
	STZ.w !RAM_SMW_Timer_YoshiTongueIsOut
	LDY.w !RAM_SMW_Yoshi_DuckingFlag
	LDA.w DATA_02D1F1,y
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b #$22
	STA.w !RAM_SMW_NorSpr035_Yoshi_SwallowAnimationTimer,x
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.b #$08
	AND.b #$F0
	STA.b !RAM_SMW_Player_YPosLo
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
Return02D1F0:
	RTS

DATA_02D1F1:
	db $00,$04

ChangeBerryIntoBushTile:
	LDA.w !RAM_SMW_Yoshi_XPosLo	; \ Set X position of block
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_Yoshi_XPosHi
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.w !RAM_SMW_Yoshi_YPosLo	; \ Set Y position of block
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_Yoshi_YPosHi
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.b #$04			; \ Block to generate = Tree behind berry
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_CheckForBerryTileCollisionWithYoshiTongue(Address)
namespace SMW_CheckForBerryTileCollisionWithYoshiTongue
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	BRA.b CODE_02BA48

ADDR_02B9FE:								;\ Note: This routine doesn't appear to be used.
	LDA.b !RAM_SMW_Misc_ScratchRAM01				;|
	AND.b #$F0							;|
	STA.b !RAM_SMW_Misc_ScratchRAM04				;|
	LDA.b !RAM_SMW_Misc_ScratchRAM09				;|
	CMP.b !RAM_SMW_Misc_ScreensInLvl				;|
	BCS.b Return02BA47						;|
	STA.b !RAM_SMW_Misc_ScratchRAM05				;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00				;|
	STA.b !RAM_SMW_Misc_ScratchRAM07				;|
	LDA.b !RAM_SMW_Misc_ScratchRAM08				;|
	CMP.b #$02							;|
	BCS.b Return02BA47						;|
	STA.b !RAM_SMW_Misc_ScratchRAM0A				;|
	LDA.b !RAM_SMW_Misc_ScratchRAM07				;|
	LSR								;|
	LSR								;|
	LSR								;|
	LSR								;|
	ORA.b !RAM_SMW_Misc_ScratchRAM04				;|
	STA.b !RAM_SMW_Misc_ScratchRAM04				;|
	LDX.b !RAM_SMW_Misc_ScratchRAM05				;|
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L1,x	;|
	LDY.b !RAM_SMW_Misc_ScratchRAM0F				;|
	BEQ.b ADDR_02BA30						;|
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L2,x	;|
ADDR_02BA30:								;|
	CLC								;|
	ADC.b !RAM_SMW_Misc_ScratchRAM04				;|
	STA.b !RAM_SMW_Misc_ScratchRAM05				;|
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L1,x	;|
	LDY.b !RAM_SMW_Misc_ScratchRAM0F				;|
	BEQ.b ADDR_02BA41						;|
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L2,x	;|
ADDR_02BA41:								;|
	ADC.b !RAM_SMW_Misc_ScratchRAM0A				;|
	STA.b !RAM_SMW_Misc_ScratchRAM06				;|
	BRA.b CODE_02BA92						;/

Return02BA47:
	RTL

CODE_02BA48:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	CMP.b #$02
	BCS.b Return02BA47
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	STA.w !RAM_SMW_Yoshi_YPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	CMP.b !RAM_SMW_Misc_ScreensInLvl
	BCS.b Return02BA47
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDX.b !RAM_SMW_Misc_ScratchRAM07
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_02BA7D
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L2,x
CODE_02BA7D:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_02BA8E
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L2,x
CODE_02BA8E:
	ADC.b !RAM_SMW_Misc_ScratchRAM0D
	STA.b !RAM_SMW_Misc_ScratchRAM06
CODE_02BA92:
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	INC.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	BNE.b Return02BABF
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	CMP.b #$45			; If it is <= the Red Berry map16 tile
	BCC.b Return02BABF
	CMP.b #$48			; If it is => Map16 always turning block
	BCS.b Return02BABF
	SEC
	SBC.b #$44
	STA.w !RAM_SMW_Yoshi_BerryBeingEaten	;Berry Type
	LDY.b #!Define_SMW_MaxNormalSpriteSlot
CODE_02BAB7:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	; \ Find a free sprite slot and branch
	BEQ.b CODE_02BAC0
	DEY
	BPL.b CODE_02BAB7
Return02BABF:
	RTL				; Return if no slots found

CODE_02BAC0:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr074_Mushroom	; \ Sprite number = Mushroom
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; \ Sprite and block X position = $00,$08
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM01	; \ Sprite and block Y position = $01,$09
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	STA.b !RAM_SMW_Blocks_YPosHi
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Reset sprite tables
	INC.w !RAM_SMW_NorSprXXX_PowerUps_IsBerryFlag,x	; ?
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x	; \ Change the index into sprite clipping table
	AND.b #$F0			; | to "resize" the sprite
	ORA.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping0C
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x	; \ No longer gives powerup when eaten
	AND.b #!Define_SMW_NorSpr_167AProp_GivePowerupWhenEaten^$FF
	STA.w !RAM_SMW_NorSpr_PropertyBits167A,x
	PLX
	LDA.b #$04			; \ Block to generate = Tree behind berry
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main	; Generate the tile
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr03D_RipVanFish_Status08(Address)
namespace SMW_NorSpr03D_RipVanFish_Status08
%InsertMacroAtXPosition(<Address>)

MaxSpeed:
	db $10,$F0

Acceleration:
	db $01,$FF

Return02BFCC:
	RTL

Bank02:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02BFCC
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	PHA
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	PHA
	LDY.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario doesn't have star
	BEQ.b CODE_02BFF3
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02BFF3:
	JSR.w SetFacingDirectionBasedOnSpeed
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	PLA
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	PLA
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_02C012
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
CODE_02C012:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$0C
	BEQ.b CODE_02C01B
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_02C01B:
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BNE.b CODE_02C024
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02C024:
	LDA.b !RAM_SMW_NorSpr03D_RipVanFish_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

RipVanFishPtrs:
	dw State00_Sleeping
	dw State01_Awake

State00_Sleeping:
	LDA.b #$02
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_02C044
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BEQ.b CODE_02C044
	BPL.b CODE_02C042
	INC.b !RAM_SMW_NorSpr_XSpeed,x
	BRA.b CODE_02C044

CODE_02C042:
	DEC.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02C044:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02C053
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_YPosLo_x
CODE_02C053:
	JSL.l SMW_SpawnMusicNoteOrZ_Z
	LDA.w !RAM_SMW_Flag_WakeUpRipVanFish
	BNE.b CODE_02C072
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	ADC.b #$30
	CMP.b #$60
	BCS.b CODE_02C07B
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_Y
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ADC.b #$30
	CMP.b #$60
	BCS.b CODE_02C07B
CODE_02C072:
	INC.b !RAM_SMW_NorSpr03D_RipVanFish_CurrentState,x
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr03D_RipVanFish_SwimmingTimer,x
	BRA.b State01_Awake

CODE_02C07B:
	LDY.b #$02
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	AND.b #$30
	BNE.b CODE_02C085
	INY
CODE_02C085:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTL

State01_Awake:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_02C095
	DEC.w !RAM_SMW_NorSpr03D_RipVanFish_SwimmingTimer,x
	BEQ.b CODE_02C0CA
CODE_02C095:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	BNE.b CODE_02C0BB
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxSpeed,y
	BEQ.b CODE_02C0AB
	CLC
	ADC.w Acceleration,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02C0AB:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w MaxSpeed,y
	BEQ.b CODE_02C0BB
	CLC
	ADC.w Acceleration,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02C0BB:
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	AND.b #$04
	BEQ.b CODE_02C0C5
	INY
CODE_02C0C5:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTL

CODE_02C0CA:
	STZ.b !RAM_SMW_NorSpr03D_RipVanFish_CurrentState,x
	JMP.w State00_Sleeping
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr03D_RipVanFish_Status08(Address)
namespace SMW_NorSpr03D_RipVanFish_Status08
%InsertMacroAtXPosition(<Address>)

SetFacingDirectionBasedOnSpeed:
	LDY.b #$00
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BPL.b CODE_02C12D
	INY
CODE_02C12D:
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_Dolphins_Status08(Address)
namespace SMW_NorSprXXX_Dolphins_Status08
%InsertMacroAtXPosition(<Address>)

XAcceleration:
	db $FF,$01,$FF,$01,$00,$00

MaxXSpeed:
	db $E8,$18,$F8,$08,$00,$00

Bank02:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02BBFF
	JSR.w SMW_SubOffscreen_Bank02_Entry2
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$00
	BNE.b CODE_02BBB7
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_02BBB5
	CMP.b #$3F
	BCS.b CODE_02BBB7
CODE_02BBB5:
	INC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02BBB7:
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b CODE_02BBC1
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
CODE_02BBC1:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_02BBFB
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BEQ.b CODE_02BBFB
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BEQ.b CODE_02BBD7
	SEC
	SBC.b #$08
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	BPL.b CODE_02BBD7
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_02BBD7:
	LDA.w !RAM_SMW_NorSprXXX_Dolphins_NoTurnAroundFlag,x
	BNE.b CODE_02BBF7
	LDA.b !RAM_SMW_NorSprXXX_Dolphins_HorizontalMovementDirection,x
	LSR
	PHP
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	SEC
	SBC.b #!Define_SMW_SpriteID_NorSpr041_LongJumpDolphin
	PLP
	ROL
	TAY
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CLC
	ADC.w XAcceleration,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxXSpeed,y
	BNE.b CODE_02BBFB
	INC.b !RAM_SMW_NorSprXXX_Dolphins_HorizontalMovementDirection,x
CODE_02BBF7:
	LDA.b #$C0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02BBFB:
	JSL.l SMW_SolidSpriteBlock_Main
Return02BBFF:
	RTL

CODE_02BC00:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$04
	LSR
	LSR
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	JSL.l SMW_GenericGFXRtDraw2Tiles16x16sStacked_Main
	RTS

; Horizontal Dolphin Tilemap
Tiles1:
	db $E2,$88

Tiles2:
	db $E7,$A8

Tiles3:
	db $E8,$A9

GFXRt:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr043_VerticalDolphin
	BNE.b CODE_02BC1D
	JMP.w CODE_02BC00

CODE_02BC1D:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ASL.b !RAM_SMW_Misc_ScratchRAM02
	PHP
	BCC.b CODE_02BC3C
	STA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$41].XDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$42].XDisp,y
	BRA.b CODE_02BC4E

CODE_02BC3C:
	CLC
	ADC.b #$18
	STA.w SMW_OAMBuffer[$40].XDisp,y
	SEC
	SBC.b #$10
	STA.w SMW_OAMBuffer[$41].XDisp,y
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$42].XDisp,y
CODE_02BC4E:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	STA.w SMW_OAMBuffer[$42].YDisp,y
	PHX
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$08
	LSR
	LSR
	LSR
	TAX
	LDA.w Tiles1,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Tiles2,x
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.w Tiles3,x
	STA.w SMW_OAMBuffer[$42].Tile,y
	PLX
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	PLP
	BCS.b CODE_02BC7F
	ORA.b #$40
CODE_02BC7F:
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	STA.w SMW_OAMBuffer[$42].Prop,y
	LDA.b #$02
	LDY.b #$02
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr044_TorpedoTed_Status08(Address)
namespace SMW_NorSpr044_TorpedoTed_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
#LM300Hijack_Bank02RTL:
	RTL

Sub:
	LDA.b !RAM_SMW_Sprites_TilePriority	; \ Save $64
	PHA
	LDA.w !RAM_SMW_NorSpr044_TorpedoTed_ReleaseAnimationTimer,x	; \ If being launched...
	BEQ.b CODE_02B896		; | ...set $64 = #$10...
	LDA.b #$10			; | ...so it will be drawn behind objects
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_02B896:
	JSR.w GFXRt			; Draw sprite
	PLA				; \ Restore $64
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Return if sprites locked
	BNE.b Return02B8B7
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	LDA.w !RAM_SMW_NorSpr044_TorpedoTed_ReleaseAnimationTimer,x	; \ Branch if not being launched
	BEQ.b CODE_02B8BC
	LDA.b #$08			; \ Sprite Y speed = #$08
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y	; Apply speed to position
	LDA.b #$10			; \ Sprite Y speed = #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return02B8B7:
	RTS

; Max Speed Torpedo Ted can go. (Format = Right, Left) The Left value must
; be over $7F while the Right value must be below $80.
MaxSpeed:
	db $20,$F0

; How fast Torpedo Ted gains speed/accelerates until he reaches max speed.
; (Format = Right, Left) The Left value must be over $7F while the Right
; value must be below $80.
Acceleration:
	db $01,$FF

CODE_02B8BC:
	LDA.b !RAM_SMW_Counter_GlobalFrames					; Glitch: This ought to be set to use !RAM_SMW_Counter_LocalFrames
	AND.b #$03
	BNE.b CODE_02B8D2
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x	; \ If not at maximum, increase X speed
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxSpeed,y
	BEQ.b CODE_02B8D2
	CLC
	ADC.w Acceleration,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02B8D2:
	JSR.w SMW_UpdateNormalSpritePositionBank02_X	; \ Apply speed to position
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x	; \ If sprite has Y speed...
	BEQ.b CODE_02B8E4
	LDA.b !RAM_SMW_Counter_GlobalFrames					; Glitch: Same as above.
	AND.b #$01
	BNE.b CODE_02B8E4
	DEC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02B8E4:
	TXA				; \ Run $02B952 every 8 frames
	CLC
	ADC.b !RAM_SMW_Counter_LocalFrames
	AND.b #$07
	BNE.b Return02B8EF
	JSR.w SpawnSmokePuffTrail
Return02B8EF:
	RTS

XDisp:
	db $10,$00,$10

UnusedTiles:
	db $80,$82

Prop:
	db $40,$00

; Torpedo Ted's GFX routine. $02B92D: [$80] Tile number to use for Torpedo
; Ted's head. $02B937: [$82] Tile number to use for Torpedo Ted's body when
; being lowered by the arm. $02B93F: [$A0] Tile number to use for Torpedo
; Ted's body after being launched (first animation frame). $02B943: [$82]
; Tile number to use for Torpedo Ted's body after being launched (second
; animation frame). $02B94A: [$02] Size for Torpedo Ted's tiles ($00 = 8x8,
; $02 = 16x16).
GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	PHX
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l XDisp,x
else
	ADC.w XDisp,x
endif
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l XDisp+$01,x
else
	ADC.w XDisp+$01,x
endif
	STA.w SMW_OAMBuffer[$41].XDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Prop,x
else
	LDA.w Prop,x
endif
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	PLX
	LDA.b #$80
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w !RAM_SMW_NorSpr044_TorpedoTed_ReleaseAnimationTimer,x
	CMP.b #$01
	LDA.b #$82
	BCS.b CODE_02B944
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LDA.b #$A0
	BCC.b CODE_02B944
	LDA.b #$82
CODE_02B944:
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b #$01
	LDY.b #$02
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

; [$F4 $1C] X offsets (low byte) the Torpedo Ted's smoke is spawned at. The
; first byte is used when the sprite faces the right direction, the second
; when it faces the left direction.
DATA_02B94E:
	db $F4,$1C

; [$FF $00] X offsets (high byte) the Torpedo Ted's smoke is spawned at. The
; first byte is used when the sprite faces the right direction, the second
; when it faces the left direction.
DATA_02B950:
	db $FF,$00

; Torpedo Ted's smoke spawning subroutine. $02B990: [$01] Smoke sprite
; number. $02B99F: [$0F] Smoke timer.
SpawnSmokePuffTrail:
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_02B954:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y
	BEQ.b CODE_02B969
	DEY
	BPL.b CODE_02B954
	DEC.w !RAM_SMW_SmokeSpr_CopyOfSlotToOverwriteWhenSlotsFull
	BPL.b CODE_02B966
	LDA.b #!Define_SMW_MaxSmokeSpriteSlot
	STA.w !RAM_SMW_SmokeSpr_CopyOfSlotToOverwriteWhenSlotsFull
CODE_02B966:
	LDY.w !RAM_SMW_SmokeSpr_CopyOfSlotToOverwriteWhenSlotsFull
CODE_02B969:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	PHX
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_02B94E,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	ADC.w DATA_02B950,x
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	PLA
	PLX
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b Return02B9A3
	LDA.b #!Define_SMW_SpriteID_SmokeSpr01_PuffOfSmoke
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y
	LDA.b #$0F
	STA.w !RAM_SMW_SmokeSpr_Timer,y
Return02B9A3:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr045_DirectionalCoins_Status08(Address)
namespace SMW_NorSpr045_DirectionalCoins_Status08
%InsertMacroAtXPosition(<Address>)

XSpeed:
	db $00,$00,$F0,$10

YSpeed:
	db $F0,$10,$00,$00

DATA_02E201:
	db $00,$03,$02,$00,$01,$03,$02,$00
	db $00,$03,$02,$00,$00,$00,$00,$00

DATA_02E211:
	db $01,$00,$03,$02

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.b !RAM_SMW_Sprites_TilePriority
	PHA
	LDA.w !RAM_SMW_NorSpr045_DirectionalCoins_AppearBehindLayer1Timer,x
	CMP.b #$30
	BCC.b CODE_02E22B
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_02E22B:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	PHA
	CLC
	ADC.b #$01
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	PHA
	ADC.b #$00
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	LDA.w !RAM_SMW_Timer_BluePSwitch
	BNE.b CODE_02E245
	JSL.l SMW_PowerUpAndItemGFXRt_DrawCoinSprite_Main
	BRA.b CODE_02E259

CODE_02E245:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$2E
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_OAMBuffer[$40].Prop,y
	AND.b #$3F
	STA.w SMW_OAMBuffer[$40].Prop,y
CODE_02E259:
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02E2DE
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_02E288
	DEC.w !RAM_SMW_NorSpr045_DirectionalCoins_DespawnTimer
	BNE.b CODE_02E288
CODE_02E271:
	STZ.w !RAM_SMW_NorSpr045_DirectionalCoins_DespawnTimer
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.w !RAM_SMW_Timer_BluePSwitch
	ORA.w !RAM_SMW_Timer_SilverPSwitch
	BNE.b Return02E287
	LDA.w !RAM_SMW_Misc_MusicRegisterBackup
	BMI.b Return02E287
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
Return02E287:
	RTS

CODE_02E288:
	LDY.b !RAM_SMW_NorSpr045_DirectionalCoins_MovementDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w YSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)|(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)
	BEQ.b CODE_02E2B0
	TAY
	LDA.w DATA_02E201,y
	TAY
	LDA.w DATA_02E211,y
	CMP.b !RAM_SMW_NorSpr045_DirectionalCoins_MovementDirection,x
	BEQ.b CODE_02E2B0
	TYA
	STA.w !RAM_SMW_NorSpr045_DirectionalCoins_DirectionToTravelNext,x
CODE_02E2B0:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	AND.b #$0F
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_02E2DE
	LDA.w !RAM_SMW_NorSpr045_DirectionalCoins_DirectionToTravelNext,x
	STA.b !RAM_SMW_NorSpr045_DirectionalCoins_MovementDirection,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $9A = Sprite X position
	STA.b !RAM_SMW_Blocks_XPosLo	; | for block creation
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $98 = Sprite Y position
	STA.b !RAM_SMW_Blocks_YPosLo	; | for block creation
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Blocks_YPosHi
	LDA.b #$06			; \ Block to generate = Coin
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
	RTS

CODE_02E2DE:
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	BNE.b CODE_02E2F3
	LDA.w !RAM_SMW_Sprites_Map16TileBeingTouchedVerticallyHi
	BNE.b CODE_02E2FF
	LDA.w !RAM_SMW_Sprites_Map16TileBeingTouchedVerticallyLo
	CMP.b #$25
	BNE.b CODE_02E2FF
	RTS

CODE_02E2F3:
	LDA.w !RAM_SMW_Sprites_Map16TileBeingTouchedHorizontallyHi
	BNE.b CODE_02E2FF
	LDA.w !RAM_SMW_Sprites_Map16TileBeingTouchedHorizontallyLo
	CMP.b #$25
	BEQ.b Return02E302
CODE_02E2FF:
	JSR.w CODE_02E271
Return02E302:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status08(Address)
namespace SMW_NorSpr047_SwimmingAndJumpingCheepCheep_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02E74B
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDY.b #$00
	JSR.w SMW_NorSprXXX_SuperKoopas_Status08_CODE_02EB3D
	LDA.b !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_CurrentState,x
	AND.b #$01
	JSL.l SMW_ExecutePtr_Absolute

SwimmingAndJumpingCheepCheepPtrs:
	dw Swimming
	dw Jumping

Return02E74B:
	RTS

XSpeed:
	db $14,$EC

Swimming:
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	LDA.w !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnOrJumpTimer,x
	BNE.b Return02E77B
	INC.w !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnAroundCounter,x
	LDY.w !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnAroundCounter,x
	CPY.b #$04
	BEQ.b CODE_02E77C
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b #$20
	CPY.b #$03
	BEQ.b CODE_02E778
	LDA.b #$40
CODE_02E778:
	STA.w !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnOrJumpTimer,x
Return02E77B:
	RTS

CODE_02E77C:
	INC.b !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_CurrentState,x
	LDA.b #$80
	STA.w !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnOrJumpTimer,x
	LDA.b #$A0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	RTS

Jumping:
	LDA.w !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnOrJumpTimer,x
	BEQ.b CODE_02E7A4
	CMP.b #$70
	BCS.b Return02E7A3
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_02E79E
	CMP.b #$30
	BCS.b Return02E7A3
CODE_02E79E:
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return02E7A3:
	RTS

CODE_02E7A4:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	INC.b !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_CurrentState,x
	STZ.w !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnAroundCounter,x
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr047_SwimmingAndJumpingCheepCheep_TurnOrJumpTimer,x
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr048_DigginChuckRock_Status08(Address)
namespace SMW_NorSpr048_DigginChuckRock_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.b !RAM_SMW_Sprites_TilePriority
	PHA
	LDA.w !RAM_SMW_NorSpr048_DigginChuckRock_InGroundTimer,x
	BEQ.b CODE_02E7C9
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
CODE_02E7C9:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02E82C
	LDA.w !RAM_SMW_NorSpr048_DigginChuckRock_InGroundTimer,x
	CMP.b #$08
	BCS.b Return02E82C
	LDY.b #$00
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	JSR.w SMW_NorSprXXX_SuperKoopas_Status08_CODE_02EB3D
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_HandleNormalSpriteGravity_Main
	LDA.w !RAM_SMW_NorSpr048_DigginChuckRock_InGroundTimer,x
	BNE.b CODE_02E828
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_02E7FD
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02E7FD:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$08
	BEQ.b CODE_02E808
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02E808:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02E828
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$38
	LDA.b #$E0
	BCC.b CODE_02E819
	LDA.b #$D0
CODE_02E819:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$08
	LDY.w !RAM_SMW_NorSpr_SlopeSurfaceItsOn,x
	BEQ.b CODE_02E828
	BPL.b CODE_02E826
	LDA.b #$F8
CODE_02E826:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02E828:
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
Return02E82C:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr049_ShiftingPipe_Status08(Address)
namespace SMW_NorSpr049_ShiftingPipe_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

YSpeed:
	db $00,$F0,$00,$10

DATA_02E839:
	db $20,$40,$20,$40

; Tiles left behind by the left (first 4 bytes) and the right (next 4 bytes)
; side of the Growing/Shrinking Pipe, in the format of $7E009C. The order of
; the bytes corresponds to the pipe waiting at the bottom, growing, waiting
; at the top, and shrinking.
LeftTileToSpawn:
	db $00,$14,$00,$02

RightTileToSpawn:
	db $00,$15,$00,$02

Sub:
	LDA.w !RAM_SMW_NorSpr049_ShiftingPipe_InitialClearTileOffset,x
	BMI.b CODE_02E872
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	SEC
	SBC.w !RAM_SMW_NorSpr049_ShiftingPipe_InitialClearTileOffset,x
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDY.b #$03
	JSR.w GrowingPipeGfx
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr049_ShiftingPipe_InitialClearTileOffset,x
	SEC
	SBC.b #$10
	STA.w !RAM_SMW_NorSpr049_ShiftingPipe_InitialClearTileOffset,x
	RTS

CODE_02E872:
	JSR.w GFXRt
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	LDA.b !RAM_SMW_Flag_SpritesLocked
	ORA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BNE.b CODE_02E8B5
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$50
	CMP.b #$A0
	BCS.b CODE_02E8B5
	LDA.b !RAM_SMW_NorSpr049_ShiftingPipe_CurrentMovementPhase,x
	AND.b #$03
	TAY
	INC.w !RAM_SMW_NorSpr049_ShiftingPipe_MovementPhaseTimer,x
	LDA.w !RAM_SMW_NorSpr049_ShiftingPipe_MovementPhaseTimer,x
	CMP.w DATA_02E839,y
	BNE.b CODE_02E8A2
	STZ.w !RAM_SMW_NorSpr049_ShiftingPipe_MovementPhaseTimer,x
	INC.b !RAM_SMW_NorSpr049_ShiftingPipe_CurrentMovementPhase,x
	BRA.b CODE_02E8B5

CODE_02E8A2:
	LDA.w YSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	BEQ.b CODE_02E8B2
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	AND.b #$0F
	BNE.b CODE_02E8B2
	JSR.w GrowingPipeGfx
CODE_02E8B2:
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
CODE_02E8B5:
	JSL.l SMW_SolidSpriteBlock_Main
	RTS

GrowingPipeGfx:
	LDA.w LeftTileToSpawn,y
	STA.w !RAM_SMW_NorSpr049_ShiftingPipe_LeftMap16Tile
	LDA.w RightTileToSpawn,y
	STA.w !RAM_SMW_NorSpr049_ShiftingPipe_RightMap16Tile
	LDA.w !RAM_SMW_NorSpr049_ShiftingPipe_LeftMap16Tile
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
	LDA.w !RAM_SMW_NorSpr049_ShiftingPipe_RightMap16Tile
	STA.b !RAM_SMW_Blocks_Map16ToGenerate	; $9C = tile to generate
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $9A = Sprite X position + #$10
	CLC				; | for block creation
	ADC.b #$10
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $98 = Sprite Y position
	STA.b !RAM_SMW_Blocks_YPosLo	; | for block creation
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Blocks_YPosHi
	JSL.l SMW_GenerateTile_Main	; Generate the tile
	RTS

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	DEC
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.b #$A4
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$A6
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
.PipeLakituEntry:
	LDA.b #$01
	LDY.b #$02
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr04B_PipeLakitu_Status08(Address)
namespace SMW_NorSpr04B_PipeLakitu_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus02_Dead
	BNE.b CODE_02E94C
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JMP.w GFXRt

CODE_02E94C:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02E985
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	LDA.b !RAM_SMW_NorSpr04B_PipeLakitu_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

PipeLakituPtrs:
	dw State00_HidingInPipe
	dw State01_Peeking
	dw State02_Rising
	dw State03_ThrowSpiny
	dw State04_Descend

State00_HidingInPipe:
	LDA.w !RAM_SMW_NorSpr04B_PipeLakitu_PhaseTimer,x
	BNE.b Return02E985
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$13
	CMP.b #$36
	BCC.b Return02E985
	LDA.b #$90
CODE_02E980:
	STA.w !RAM_SMW_NorSpr04B_PipeLakitu_PhaseTimer,x
	INC.b !RAM_SMW_NorSpr04B_PipeLakitu_CurrentState,x
Return02E985:
	RTS

State01_Peeking:
	LDA.w !RAM_SMW_NorSpr04B_PipeLakitu_PhaseTimer,x
	BNE.b CODE_02E996
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b #$0C
	BRA.b CODE_02E980

CODE_02E996:
	CMP.b #$7C
	BCC.b CODE_02E9A2
CODE_02E99A:
	LDA.b #$F8
CODE_02E99C:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	RTS

CODE_02E9A2:
	CMP.b #$50
	BCS.b Return02E9B3
	LDY.b #$00
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$20
	BEQ.b CODE_02E9AF
	INY
CODE_02E9AF:
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
Return02E9B3:
	RTS

State02_Rising:
	LDA.w !RAM_SMW_NorSpr04B_PipeLakitu_PhaseTimer,x
	BNE.b CODE_02E99A
	LDA.b #$80
	BRA.b CODE_02E980

State03_ThrowSpiny:
	LDA.w !RAM_SMW_NorSpr04B_PipeLakitu_PhaseTimer,x
	BNE.b CODE_02E9C6
	LDA.b #$20
	BRA.b CODE_02E980

CODE_02E9C6:
	CMP.b #$40
	BNE.b CODE_02E9CF
	JSL.l SMW_MakeLakituThrowSpiny_Main
	RTS

CODE_02E9CF:
	BCS.b Return02E9D4
	INC.w !RAM_SMW_NorSpr_AnimationFrame,x
Return02E9D4:
	RTS

State04_Descend:
	LDA.w !RAM_SMW_NorSpr04B_PipeLakitu_PhaseTimer,x
	BNE.b CODE_02E9E2
	LDA.b #$50
	JSR.w CODE_02E980
	STZ.b !RAM_SMW_NorSpr04B_PipeLakitu_CurrentState,x
	RTS

CODE_02E9E2:
	LDA.b #$08
	BRA.b CODE_02E99C

; Pipe-Dwelling Lakitu Tilemap
HeadTiles:
	db $EC,$A8,$CE

BodyTiles:					;\ Note: Pipe Lakitu's body never changes...
	db $EE,$EE,$EE				;/

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$41].YDisp,y
	PHX
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	TAX
	LDA.w HeadTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w BodyTiles,x
	STA.w SMW_OAMBuffer[$41].Tile,y
	PLX
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	LSR
	ROR
	LSR
	EOR.b #$5B
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	JMP.w SMW_NorSpr049_ShiftingPipe_Status08_GFXRt_PipeLakituEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr04C_ExplodingBlock_Status08(Address)
namespace SMW_NorSpr04C_ExplodingBlock_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02E462
	BRA.b CODE_02E42D

ADDR_02E429:						;\ Note: Unreachable address
	JSL.l SMW_SpawnMusicNoteOrZ_MusicNote		;/
CODE_02E42D:
	LDY.b #$00
	INC.w !RAM_SMW_NorSpr04C_ExplodingBlock_ShakingAnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr04C_ExplodingBlock_ShakingAnimationFrameCounter,x
	AND.b #$40
	BEQ.b CODE_02E444
	LDY.b #$04
	LDA.w !RAM_SMW_NorSpr04C_ExplodingBlock_ShakingAnimationFrameCounter,x
	AND.b #$04
	BEQ.b CODE_02E444
	LDY.b #$FC
CODE_02E444:
	STY.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$60
	CMP.b #$C0
	BCS.b Return02E462
	LDY.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	BNE.b Return02E462
	JSL.l SMW_ShatterExplodingBlock_Main
Return02E462:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_ShatterExplodingBlock(Address)
namespace SMW_ShatterExplodingBlock
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_NorSpr04C_ExplodingBlock_Contents,x
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	TYA
	STA.w !RAM_SMW_NorSpr_Table7E157C,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Blocks_YPosHi
	PHB
	LDA.b #SMW_SpawnBrickPieces_Main>>16
	PHA
	PLB
	LDA.b #$00
	JSL.l SMW_SpawnBrickPieces_Main
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_JumpingPiranhaPlant_Status08(Address)
namespace SMW_NorSprXXX_JumpingPiranhaPlant_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSL.l SMW_InitializeNormalSpriteRAMTables_YXPPCCCTAndPropertyTables
	LDA.b !RAM_SMW_Sprites_TilePriority
	PHA
	LDA.b #$10
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.w !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_MouthAnimationFrameCounter,x
	AND.b #$08
	LSR
	LSR
	EOR.b #$02
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	LDA.w !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_PropellerAnimationFrameCounter,x
	AND.b #$04
	LSR
	LSR
	INC
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b #$0A
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	LDA.b #$01
	JSL.l SMW_GenericGFXRtDraw4Tiles8x8Square_Main
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA
	STA.b !RAM_SMW_Sprites_TilePriority
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02E158
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

JumpingPiranhaPlantPtrs:
	dw State00_Waiting
	dw State01_Jump
	dw State02_Descend

State00_Waiting:
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	LDA.w !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_WaitBeforeJumping,x
	BNE.b Return02E158
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$1B
	CMP.b #$37
	BCC.b Return02E158
	LDA.b #$C0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	INC.b !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_CurrentState,x
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
Return02E158:
	RTS

State01_Jump:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_02E161
	CMP.b #$40
	BCS.b CODE_02E166
CODE_02E161:
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02E166:
	INC.w !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_MouthAnimationFrameCounter,x
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$F0
	BMI.b Return02E176
	LDA.b #$50
	STA.w !RAM_SMW_NorSpr050_FireSpittingJumpingPiranhaPlant_WaitBeforeFireSpit,x
	INC.b !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_CurrentState,x
Return02E176:
	RTS

State02_Descend:
	INC.w !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_PropellerAnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr050_FireSpittingJumpingPiranhaPlant_WaitBeforeFireSpit,x
	BNE.b CODE_02E1A4
CODE_02E17F:
	INC.w !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_MouthAnimationFrameCounter,x
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$03
	BNE.b CODE_02E191
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$08
	BPL.b CODE_02E191
	INC
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02E191:
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b Return02E176
	STZ.b !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_CurrentState,x
	LDA.b #$40
	STA.w !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_WaitBeforeJumping,x
	RTS

CODE_02E1A4:
	LDY.b !RAM_SMW_NorSpr_SpriteID_x_Cached
	CPY.b #!Define_SMW_SpriteID_NorSpr050_FireSpittingJumpingPiranhaPlant
	BNE.b CODE_02E1F7
	STZ.w !RAM_SMW_NorSprXXX_JumpingPiranhaPlant_MouthAnimationFrameCounter,x
	CMP.b #$40
	BNE.b CODE_02E1F7
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b CODE_02E1F7
	LDA.b #$10
	JSR.w CODE_02E1C0
	LDA.b #$F0
CODE_02E1C0:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_02E1C4:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_02E1CD
	DEY
	BPL.b CODE_02E1C4
	RTS				; / Return if no free slots

CODE_02E1CD:
	LDA.b #!Define_SMW_SpriteID_ExtSpr0B_PiranhaFireball	; \ Extended sprite = Piranha fireball
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDA.b #$D0
	STA.w !RAM_SMW_ExtSpr_YSpeed,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
CODE_02E1F7:
	BRA.b CODE_02E17F
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr052_MovingLedgeHole_Status08(Address)
namespace SMW_NorSpr052_MovingLedgeHole_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02E5D7
	INC.w !RAM_SMW_NorSpr052_MovingLedgeHole_ChangeDirectionTimer,x
	LDY.b #$10
	LDA.w !RAM_SMW_NorSpr052_MovingLedgeHole_ChangeDirectionTimer,x
	AND.b #$80
	BNE.b CODE_02E5D1
	LDY.b #$F0
CODE_02E5D1:
	TYA
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
CODE_02E5D7:
	JSR.w GFXRt
	JSR.w CODE_02E5F7
	LDA.w !RAM_SMW_Player_DisableObjectInteractionFlag
	BEQ.b CODE_02E5E8
	DEC
	CMP.w !RAM_SMW_NorSpr_CurrentSlotID
	BNE.b Return02E5F6
CODE_02E5E8:
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	STZ.w !RAM_SMW_Player_DisableObjectInteractionFlag
	BCC.b Return02E5F6
	INX
	STX.w !RAM_SMW_Player_DisableObjectInteractionFlag
	DEX
Return02E5F6:
	RTS

CODE_02E5F7:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot
CODE_02E5F9:
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID
	BEQ.b CODE_02E633
	TYA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_02E633
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b CODE_02E633
	LDA.w !RAM_SMW_NorSpr_NoLevelCollisionFlag,y
	BEQ.b CODE_02E617
	DEC
	CMP.w !RAM_SMW_NorSpr_CurrentSlotID
	BNE.b CODE_02E633
CODE_02E617:
	TYX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingB
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_NoLevelCollisionFlag,y
	BCC.b CODE_02E633
	TXA
	INC
	STA.w !RAM_SMW_NorSpr_NoLevelCollisionFlag,y
CODE_02E633:
	DEY
	BPL.b CODE_02E5F9
	RTS

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	PHX
	LDX.b #$03					; Optimization: There is no reason why this should be drawing 4 tiles, when 3 is enough to cover the length it uses.
Loop:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b Loop
	PLX
	LDA.b #$03
	LDY.b #$02
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

XDisp:
	db $00,$08,$18,$20

; Ghost House Moving Hole Tilemap
Tiles:
	db $EB,$EA,$EA,$EB

Prop:
	db $71,$31,$31,$31
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr060_FlatPalaceSwitch_Status08(Address)
namespace SMW_NorSpr060_FlatPalaceSwitch_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

XDisp:
	db $00,$08,$10,$18,$00,$08,$10,$18

YDisp:
	db $00,$00,$00,$00,$08,$08,$08,$08

; The tile numbers used by sprite 60, the flat green switch palace switch.
Tile:
	db $00,$01,$01,$00,$10,$11,$11,$10

; YXPPCCCT data for sprite 60, the flat switch palace switch. It contains
; the priority, flip, and tile high byte values. The palettes used by the
; top of the switch are at $02CD55.
Prop:
	db $31,$31,$71,$71,$31,$31,$71,$71

; YXPPCCCT data for sprite 60, the flat switch palace switch. Contains
; palettes: used only for the top of the switch. The table is indexed by the
; value in $7E191E.
Palette:
	db $0A,$04,$06,$08

Sub:
	LDA.w !RAM_SMW_NorSpr060_FlatPalaceSwitch_WaitBeforeEraseSwitchObject,x
	CMP.b #$5E
	BNE.b DontEraseObjectYet
	LDA.b #$1B			; \ Block to generate = #$1B
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b #$10
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Blocks_YPosHi
	JSL.l SMW_GenerateTile_Main
DontEraseObjectYet:
	JSL.l SMW_SolidSpriteBlock_Main
;GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	PHX
	LDX.w !RAM_SMW_Sprites_ColorOfFlatPalaceSwitchToSpawn
	LDA.w Palette,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$07
Loop:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tile,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	CPX.b #$04
	BCS.b BaseTiles						; Info: The base tiles use palette 0, while the top tiles use a palette based on the color of the switch pressed.
	ORA.b !RAM_SMW_Misc_ScratchRAM02
BaseTiles:
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b Loop
	PLX
	LDY.b #$00
	LDA.b #$07
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

Return02CDC4:							;\ Optimization: Unused RTS
	RTS 							;/
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr061_SkullRaft_Status01(Address)
namespace SMW_NorSpr061_SkullRaft_Status01
%InsertMacroAtXPosition(<Address>)

XPosOffset:
	db $10,$20,$30

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	STZ.w !RAM_SMW_Sprites_FloatingSkullSpeed
	INC.b !RAM_SMW_NorSpr061_SkullRaft_FirstPlatformFlag,x
	LDA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM00
Loop:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Branch if no free slots
	BMI.b NoFreeSlot
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr061_SkullRaft
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDX.b !RAM_SMW_Misc_ScratchRAM00
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l XPosOffset,x
else
	LDA.w XPosOffset,x
endif
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
NoFreeSlot:							; Optimization: You know, if there are no free slots available, why bother checking if the remaining skulls can be spawned in?
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b Loop
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr061_SkullRaft_Status08(Address)
namespace SMW_NorSpr061_SkullRaft_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.b !RAM_SMW_NorSpr061_SkullRaft_FirstPlatformFlag,x
	BEQ.b CODE_02EDF6		;IF SKULLS DIEING
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	BNE.b CODE_02EDF6		;IF LIVING, DO BELOW
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_02EDE6:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr061_SkullRaft	;SEARCH OUT OTHERS
	BNE.b CODE_02EDF2
	LDA.b #!Define_SMW_NorSprStatus00_EmptySlot	;ERASE THEM TOO
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
CODE_02EDF2:
	DEY
	BPL.b CODE_02EDE6
Return02EDF5:
	RTS

CODE_02EDF6:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	LSR
	LDA.b #$E0
	BCC.b CODE_02EE09
	LDA.b #$E2
CODE_02EE09:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	CMP.b #$F0
	BCS.b CODE_02EE19
	CLC
	ADC.b #$03
	STA.w SMW_OAMBuffer[$40].YDisp,y
CODE_02EE19:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02EDF5
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_02EE21:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_02EE36
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr061_SkullRaft
	BNE.b CODE_02EE36
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,y
	AND.b #$0F
	BEQ.b CODE_02EE36
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_02EE36:
	DEY
	BPL.b CODE_02EE21
	LDA.w !RAM_SMW_Sprites_FloatingSkullSpeed
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$20
	BMI.b CODE_02EE48
	LDA.b #$20
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02EE48:
	JSL.l SMW_HandleNormalSpriteGravity_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02EE57
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02EE57:
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	BCC.b Return02EEA8
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return02EEA8
	LDA.b #$0C
	STA.w !RAM_SMW_Sprites_FloatingSkullSpeed
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAX
	INC.w SMW_OAMBuffer[$40].YDisp,x
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b #$01
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	STZ.b !RAM_SMW_Player_InAirFlag
	LDA.b #$1C
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_02EE80
	LDA.b #$2C
CODE_02EE80:
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b !RAM_SMW_Player_BlockedFlags
	AND.b #$01
	BNE.b Return02EEA8
	LDY.b #$00
	LDA.w !RAM_SMW_Sprites_PositionDisp
	BPL.b CODE_02EE9E
	DEY
CODE_02EE9E:
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	TYA
	ADC.b !RAM_SMW_Player_XPosHi
	STA.b !RAM_SMW_Player_XPosHi
Return02EEA8:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr06A_CoinGameCloud_Status08(Address)
namespace SMW_NorSpr06A_CoinGameCloud_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Acceleration:
	db $01,$FF

MaxYSpeed:
	db $10,$F0

Sub:
	LDA.b !RAM_SMW_NorSpr06A_CoinGameCloud_ResetCloudCoinCounter,x
	BNE.b CODE_02EEBE
	INC.b !RAM_SMW_NorSpr06A_CoinGameCloud_ResetCloudCoinCounter,x
	STZ.w !RAM_SMW_Counter_PinkBerryCloudCoins
CODE_02EEBE:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02EF1C
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$7F
	BNE.b CODE_02EED5
	LDA.w !RAM_SMW_NorSpr06A_CoinGameCloud_SpawnedCoinCounter,x
	CMP.b #$0B
	BCS.b CODE_02EED5
	INC.w !RAM_SMW_NorSpr06A_CoinGameCloud_SpawnedCoinCounter,x
	JSR.w CODE_02EF67
CODE_02EED5:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$01
	BNE.b CODE_02EF12
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM03
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b !RAM_SMW_Misc_ScratchRAM02
	SEP.b #$20			; A->8
	LDY.b #$00
	BCC.b CODE_02EEF9
	INY
CODE_02EEF9:
	LDA.w !RAM_SMW_NorSpr06A_CoinGameCloud_SpawnedCoinCounter,x
	CMP.b #$0B
	BCC.b CODE_02EF05
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	LDY.b #$01
CODE_02EF05:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w MaxYSpeed,y
	BEQ.b CODE_02EF12
	CLC
	ADC.w Acceleration,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02EF12:
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b #$08
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
CODE_02EF1C:
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	PHA
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$60
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	ASL
	ASL
	ASL
	AND.b #$C0
	ORA.b #$30
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b #$04
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$04
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$4D
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$39
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDY.b #$00
	LDA.b #$00
	JSR.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
	RTS

CODE_02EF67:
	LDA.w !RAM_SMW_Counter_PinkBerryCloudCoins
	CMP.b #$0A
	BCC.b CODE_02EFAA
	LDY.b #!Define_SMW_MaxNormalSpriteSlot
CODE_02EF70:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b CODE_02EF7B
	DEY
	CPY.b #!Define_SMW_MaxNormalSpriteSlot-$02
	BNE.b CODE_02EF70
	RTS

CODE_02EF7B:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr078_1upMushroom
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
	LDA.b #$E0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	INC.w !RAM_SMW_NorSpr_FacingDirection,x
	PLX
	RTS

CODE_02EFAA:
	LDA.w !RAM_SMW_NorSpr06A_CoinGameCloud_SpawnedCoinCounter,x
	CMP.b #$0B
	BCS.b Return02EFBB
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_02EFB3:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_02EFBC
	DEY
	BPL.b CODE_02EFB3
Return02EFBB:
	RTS				; / Return if no free slots

CODE_02EFBC:
	LDA.b #!Define_SMW_SpriteID_ExtSpr0A_CloudCoin	; \ Extended sprite = Cloud game coin
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDA.b #$D0
	STA.w !RAM_SMW_ExtSpr_YSpeed,y
	LDA.b #$00
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
	STA.w !RAM_SMW_ExtSpr0A_CloudCoin_DisableBlockCollisionFlag,y
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_WallSpringboard_Status08(Address)
namespace SMW_NorSprXXX_WallSpringboard_Status08
%InsertMacroAtXPosition(<Address>)

UNK_02CDC5:
	db $00,$07,$F9,$00,$01,$FF

Sub:
;$02CDCB
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02CDFE
	LDA.w !RAM_SMW_NorSprXXX_WallSpringboard_CanBounceHigherTimer,x
	BEQ.b CODE_02CDF1
	DEC.w !RAM_SMW_NorSprXXX_WallSpringboard_CanBounceHigherTimer,x
	BIT.b !RAM_SMW_IO_ControllerHold1
	BPL.b CODE_02CDF1
	STZ.w !RAM_SMW_NorSprXXX_WallSpringboard_CanBounceHigherTimer,x
	LDY.w !RAM_SMW_NorSprXXX_WallSpringboard_MaximumAngle,x
	LDA.w HighBouncePlayerYSpeed,y
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b #!Define_SMW_Sound1DFC_Springboard	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_02CDF1:
	LDA.w !RAM_SMW_NorSprXXX_WallSpringboard_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

PeaBouncerPtrs:
	dw State00_DoNothing
	dw State01_PlayerIsOnTop
	dw State02_Rebound

Return02CDFE:
State00_DoNothing:
	RTL

HighBouncePlayerYSpeed:
	db $B6,$B4,$B0,$A8,$A0,$98,$90,$88

AutoBouncePlayerYSpeed:
	db $00,$00,$E8,$E0,$D0,$C8,$C0,$B8

State01_PlayerIsOnTop:
	LDA.w !RAM_SMW_NorSprXXX_WallSpringboard_WaitBeforeAutoBounce,x
	BEQ.b CODE_02CE20
	DEC
	BNE.b Return02CE1F
	INC.w !RAM_SMW_NorSprXXX_WallSpringboard_CurrentState,x
	LDA.b #$01
	STA.w !RAM_SMW_NorSprXXX_WallSpringboard_ReboundDirectionCounter,x
Return02CE1F:
	RTL

CODE_02CE20:
	LDA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	BMI.b CODE_02CE29
	CMP.w !RAM_SMW_NorSprXXX_WallSpringboard_MaximumAngle,x
	BCS.b CODE_02CE2F
CODE_02CE29:
	CLC
	ADC.b #$01
	STA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	RTL

CODE_02CE2F:
	LDA.w !RAM_SMW_NorSprXXX_WallSpringboard_MaximumAngle,x
	STA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	LDA.b #$08
	STA.w !RAM_SMW_NorSprXXX_WallSpringboard_WaitBeforeAutoBounce,x
	RTL

State02_Rebound:
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	AND.b #$03
	BNE.b CODE_02CE49
	DEC.w !RAM_SMW_NorSprXXX_WallSpringboard_MaximumAngle,x
	BEQ.b CODE_02CE86
CODE_02CE49:
	LDA.w !RAM_SMW_NorSprXXX_WallSpringboard_MaximumAngle,x
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSprXXX_WallSpringboard_ReboundDirectionCounter,x
	AND.b #$01
	BNE.b CODE_02CE70
	LDA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	BMI.b Return02CE66
	CMP.w !RAM_SMW_NorSprXXX_WallSpringboard_MaximumAngle,x
	BCS.b CODE_02CE67
Return02CE66:
	RTL

CODE_02CE67:
	LDA.w !RAM_SMW_NorSprXXX_WallSpringboard_MaximumAngle,x
	STA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	INC.w !RAM_SMW_NorSprXXX_WallSpringboard_ReboundDirectionCounter,x
	RTL

CODE_02CE70:
	LDA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	SEC
	SBC.b #$04
	STA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	BPL.b Return02CE7D
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b CODE_02CE7E
Return02CE7D:
	RTL

CODE_02CE7E:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	INC.w !RAM_SMW_NorSprXXX_WallSpringboard_ReboundDirectionCounter,x
	RTL

CODE_02CE86:
	STZ.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	STZ.w !RAM_SMW_NorSprXXX_WallSpringboard_CurrentState,x
	RTL

ADDR_02CE8C: ; unreachable
	JSR.w GFXRt			; \ Unreachable
	RTL				; / Wrapper for Pea Bouncer gfx routine

XDisp:
	db $00,$08,$10,$18,$20
	db $00,$08,$10,$18,$20
	db $00,$08,$10,$18,$20
	db $00,$08,$10,$18,$1F
	db $00,$08,$10,$17,$1E
	db $00,$08,$0F,$16,$1D
	db $00,$07,$0F,$16,$1C
	db $00,$07,$0E,$15,$1B

YDisp:
	db $00,$00,$00,$00,$00
	db $00,$01,$01,$01,$02
	db $00,$00,$01,$02,$04
	db $00,$01,$02,$04,$06
	db $00,$01,$03,$06,$08
	db $00,$02,$04,$08,$0A
	db $00,$02,$05,$07,$0C
	db $00,$02,$05,$09,$0E

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	SEC
	SBC.b #!Define_SMW_SpriteID_NorSpr06B_LeftWallSpringboard
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	BPL.b CODE_02CEF7
	EOR.b #$FF
	INC
CODE_02CEF7:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
CODE_02CEFC:
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	ASL
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	LSR
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l XDisp,x
else
	LDA.w XDisp,x
endif
	BCC.b CODE_02CF10
	EOR.b #$FF
	INC
CODE_02CF10:
	STA.b !RAM_SMW_Misc_ScratchRAM08
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	ASL
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l YDisp,x
else
	LDA.w YDisp,x
endif
	BCC.b CODE_02CF23
	EOR.b #$FF
	INC
CODE_02CF23:
	STA.b !RAM_SMW_Misc_ScratchRAM09
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$3D
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$0A
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	PHY
	JSR.w HandlePlayerCollision
	PLY
	INY
	INY
	INY
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	BMI.b CODE_02CF4A
	JMP.w CODE_02CEFC

CODE_02CF4A:
	LDY.b #$00
	LDA.b #$04
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

Return02CF51:
	RTS

HandlePlayerCollision:
	LDA.b !RAM_SMW_Player_CurrentState
	CMP.b #!Define_SMW_PlayerState01_PowerDown
	BCS.b Return02CF51
	LDA.b !RAM_SMW_Player_OnScreenPosYHi
	ORA.b !RAM_SMW_Player_OnScreenPosXHi
	ORA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b Return02CF51
	LDA.b !RAM_SMW_Player_OnScreenPosXLo
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	CMP.b #$01
	LDA.b #$10
	BCC.b CODE_02CF76
	LDA.b #$20
CODE_02CF76:
	CLC
	ADC.b !RAM_SMW_Player_OnScreenPosYLo
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.w SMW_OAMBuffer[$40].XDisp,y
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0A
	CLC
	ADC.b #$08
	CMP.b #$14
	BCS.b Return02CFFD
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	CMP.b #$01
	LDA.b #$1A
	BCS.b CODE_02CF92
	LDA.b #$1C
CODE_02CF92:
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0B
	CLC
	ADC.b #$08
	CMP.b !RAM_SMW_Misc_ScratchRAM0F
	BCS.b Return02CFFD
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return02CFFD
	LDA.b #$1F
	PHX
	LDX.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_02CFAF
	LDA.b #$2F
CODE_02CFAF:
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	PLX
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0F
	PHP
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Player_YPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	ADC.b #$00
	PLP
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	STZ.b !RAM_SMW_Player_InAirFlag
	LDA.b #$02
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	LDA.w !RAM_SMW_NorSprXXX_WallSpringboard_CurrentState,x
	BEQ.b CODE_02CFEB
	CMP.b #$02
	BEQ.b CODE_02CFEB
	LDA.w !RAM_SMW_NorSprXXX_WallSpringboard_WaitBeforeAutoBounce,x
	CMP.b #$01
	BNE.b Return02CFEA
	LDA.b #$08
	STA.w !RAM_SMW_NorSprXXX_WallSpringboard_CanBounceHigherTimer,x
	LDY.b !RAM_SMW_NorSprXXX_WallSpringboard_CurrentAngle,x
	LDA.w AutoBouncePlayerYSpeed,y
	STA.b !RAM_SMW_Player_YSpeed
Return02CFEA:
	RTS

CODE_02CFEB:
	STZ.b !RAM_SMW_Player_XSpeed
	LDY.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w MaxAngle,y
	STA.w !RAM_SMW_NorSprXXX_WallSpringboard_MaximumAngle,x
	LDA.b #$01
	STA.w !RAM_SMW_NorSprXXX_WallSpringboard_CurrentState,x
	STZ.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
Return02CFFD:
	RTS

; Bounciness of each part of pea bouncer
MaxAngle:
	db $01,$01,$03,$05,$07
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr070_Pokey_Status08(Address)
namespace SMW_NorSpr070_Pokey_Status08
%InsertMacroAtXPosition(<Address>)

PokeyClipIndex:
	db !Define_SMW_NorSpr_1662Prop_SpriteClipping1B
	db !Define_SMW_NorSpr_1662Prop_SpriteClipping1B
	db !Define_SMW_NorSpr_1662Prop_SpriteClipping1A
	db !Define_SMW_NorSpr_1662Prop_SpriteClipping19
	db !Define_SMW_NorSpr_1662Prop_SpriteClipping18
	db !Define_SMW_NorSpr_1662Prop_SpriteClipping17

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	LDA.b !RAM_SMW_NorSpr070_Pokey_Segments,x	; \ After: Y = number of segments
	PHX				; | $C2,x has a bit set for each segment remaining
	LDX.b #$04			; | for X=0 to X=4...
	LDY.b #$00
PokeyLoopStart:
	LSR
	BCC.b BitNotSet
	INY				; | ...Increment Y if bit X is set
BitNotSet:
	DEX
	BPL.b PokeyLoopStart
	PLX
	LDA.w PokeyClipIndex,y		; \ Update the index into the clipping table
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	PLB
	RTL

DATA_02B653:
	db $01,$02,$04,$08

DATA_02B657:
	db $00,$01,$03,$07

DATA_02B65B:
	db $FF,$FE,$FC,$F8

; X coordinates of Pokey animation
XDisp:
	db $00,$01,$00,$FF

; Pokey's X speed (right, left)
XSpeed:
	db $02,$FE

DATA_02B665:
	db $00,$05,$09,$0C,$0E,$0F,$10,$10
	db $10,$10,$10,$10,$10

Sub:
	LDA.w !RAM_SMW_NorSpr070_Pokey_DeadSegmentFlag,x
	BNE.b CODE_02B681
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	; \ Branch if Status == Normal
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BEQ.b CODE_02B6A7
	JMP.w CODE_02B726

CODE_02B681:
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_NorSpr070_Pokey_Segments,x
	CMP.b #$01
	LDA.b #$8A
	BCC.b CODE_02B692
	LDA.b #$E8
CODE_02B692:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b Return02B6A6
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_SubOffscreen_Bank02_Entry1
Return02B6A6:
	RTS

CODE_02B6A7:
	LDA.b !RAM_SMW_NorSpr070_Pokey_Segments,x	; \ Erase sprite if no segments remain
	BNE.b PokeyAlive
CODE_02B6AB:
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	RTS

PokeyAlive:
	CMP.b #$20
	BCS.b CODE_02B6AB
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02B726
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	INC.w !RAM_SMW_NorSpr070_Pokey_TurnTowardsMarioTimer,x
	LDA.w !RAM_SMW_NorSpr070_Pokey_TurnTowardsMarioTimer,x
	AND.b #$7F
	BNE.b CODE_02B6CF
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	TYA
	STA.w !RAM_SMW_NorSpr070_Pokey_HorizontalMovementDirection,x
CODE_02B6CF:
	LDY.w !RAM_SMW_NorSpr070_Pokey_HorizontalMovementDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$40
	BPL.b CODE_02B6E8
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02B6E8:
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02B6F5
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_02B6F5:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$03
	BEQ.b CODE_02B704
	LDA.w !RAM_SMW_NorSpr070_Pokey_HorizontalMovementDirection,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr070_Pokey_HorizontalMovementDirection,x
CODE_02B704:
	JSR.w CODE_02B7AC
	LDY.b #$00
CODE_02B709:
	LDA.b !RAM_SMW_NorSpr070_Pokey_Segments,x
	AND.w DATA_02B653,y
	BNE.b CODE_02B721
	LDA.b !RAM_SMW_NorSpr070_Pokey_Segments,x
	PHA
	AND.w DATA_02B657,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	PLA
	LSR
	AND.w DATA_02B65B,y
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr070_Pokey_Segments,x
CODE_02B721:
	INY
	CPY.b #$04
	BNE.b CODE_02B709
CODE_02B726:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b #$40
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_NorSpr070_Pokey_Segments,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.w !RAM_SMW_NorSpr070_Pokey_DisconnectedUpperSegments,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDY.w !RAM_SMW_NorSpr070_Pokey_ReconnectBodyTimer,x
	LDA.w DATA_02B665,y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	STZ.b !RAM_SMW_Misc_ScratchRAM05
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	PHX
	LDX.b #$04
CODE_02B74B:
	STX.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM06
	AND.b #$03
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	CMP.b #$01
	BNE.b CODE_02B760
	LDX.b #$00
CODE_02B760:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	LSR.b !RAM_SMW_Misc_ScratchRAM02
	BCC.b CODE_02B781
	LSR.b !RAM_SMW_Misc_ScratchRAM04
	BCS.b CODE_02B77B
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM05
	PLA
CODE_02B77B:
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM05
	STA.w SMW_OAMBuffer[$40].YDisp,y
CODE_02B781:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	LSR
	LDA.b #$E8
	; Change to 90 and Pokey's head will be his body, and the other way round
	BCS.b CODE_02B791
	LDA.b #$8A
CODE_02B791:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$05
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_02B74B
	PLX
	LDA.b #$04
	LDY.b #$02
Bank02SpriteEntry:
	JSL.l SMW_FinishOAMWrite_Main
	RTS

CODE_02B7AC:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
CODE_02B7AE:
	TYA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCS.b CODE_02B7D2
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked
	BNE.b CODE_02B7D2
	PHB
	LDA.b #SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact>>16
	PHA
	PLB
	PHX
	TYX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingB
	PLX
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetSpriteClippingA
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	PLB
	BCS.b CODE_02B7D6
CODE_02B7D2:
	DEY
	BPL.b CODE_02B7AE
Return02B7D5:
	RTS

CODE_02B7D6:
	LDA.w !RAM_SMW_NorSpr070_Pokey_DisableSegmentLossTimer,x
	BNE.b Return02B7D5
	LDA.w !RAM_SMW_NorSpr_YPosLo,y
	SEC
	SBC.b !RAM_SMW_NorSpr_YPosLo_x
	PHY
	STY.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	JSR.w RemovePokeySgmntRt
	PLY
	JSR.w CODE_02B82E
	RTS

RemovePokeySgmntRt:
	LDY.b #$00
	CMP.b #$09
	BMI.b CODE_02B803
	INY
	CMP.b #$19
	BMI.b CODE_02B803
	INY
	CMP.b #$29
	BMI.b CODE_02B803
	INY
	CMP.b #$39
	BMI.b CODE_02B803
	INY
CODE_02B803:
	LDA.b !RAM_SMW_NorSpr070_Pokey_Segments,x	; \ Take away a segment by unsetting a bit
	AND.w PokeyUnsetBit,y
	STA.b !RAM_SMW_NorSpr070_Pokey_Segments,x
	STA.w !RAM_SMW_NorSpr070_Pokey_DisconnectedUpperSegments,x
	LDA.w DATA_02B829,y
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.b #$0C
	STA.w !RAM_SMW_NorSpr070_Pokey_ReconnectBodyTimer,x
	ASL
	STA.w !RAM_SMW_NorSpr070_Pokey_DisableSegmentLossTimer,x
	RTS

RemovePokeySegment:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w RemovePokeySgmntRt
	PLB
	RTL

PokeyUnsetBit:
	db $EF,$F7,$FB,$FD,$FE

DATA_02B829:
	db $E0,$F0,$F8,$FC,$FE

CODE_02B82E:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return02B881
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr070_Pokey
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	PHX
	TYX
if defined("Define_SMW_SA1")
	; SA-1 Pack: Pokey iterates overall sprites looking for shells that
	; collide with it. When one does collide it indexes the shell's sprite
	; tables by x.
	JSL.l POKEY_SET
else
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
endif
	LDX.w !RAM_SMW_Sprites_SecondTrackedSpriteIndex
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	ROR.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	LDA.b #$E0
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	PLX
	LDA.b !RAM_SMW_NorSpr070_Pokey_Segments,x
	AND.b !RAM_SMW_Misc_ScratchRAM0D
	STA.w !RAM_SMW_NorSpr070_Pokey_Segments,y
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr070_Pokey_DeadSegmentFlag,y
	LDA.b #$01
if defined("Define_SMW_SA1")
	JSL.l POKEY_RESTORE
else
	JSL.l SMW_GivePoints_Entry2
endif
Return02B881:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSprXXX_SuperKoopas_Status08(Address)
namespace SMW_NorSprXXX_SuperKoopas_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

NonGroundedKoopaXSpeed:
	db $18,$E8

Sub:
	JSR.w GFXRt
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus02_Dead
	BNE.b CODE_02EB49
	LDY.b #$04
CODE_02EB3D:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$04
	BEQ.b CODE_02EB44
	INY
CODE_02EB44:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

CODE_02EB49:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02EB7C
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr073_GroundSuperKoopa
	BEQ.b CODE_02EB7D
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w NonGroundedKoopaXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w CODE_02EBF8
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b Return02EB7C
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$F0
	BMI.b Return02EB7C
	CLC
	ADC.b #$FF
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return02EB7C:
	RTS

CODE_02EB7D:
	LDA.b !RAM_SMW_NorSpr073_GroundSuperKoopa_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

SuperKoopaPtrs:
	dw GroundedSuperKoopaState00_Running
	dw GroundedSuperKoopaState01_Jumping
	dw GroundedSuperKoopaState02_Flying

MaxXSpeed:
	db $18,$E8

XAcceleration:
	db $01,$FF

GroundedSuperKoopaState00_Running:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxXSpeed,y
	BEQ.b CODE_02EBAB
	CLC
	ADC.w XAcceleration,y
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b CODE_02EBA9
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02EBA9:
	INC.b !RAM_SMW_Misc_ScratchRAM00
CODE_02EBAB:
	INC.w !RAM_SMW_NorSpr073_GroundSuperKoopa_TakeOffTimer,x
	LDA.w !RAM_SMW_NorSpr073_GroundSuperKoopa_TakeOffTimer,x
	CMP.b #$30
	BEQ.b CODE_02EBCA
CODE_02EBB5:
	LDY.b #$00
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$04
	BEQ.b CODE_02EBBE
	INY
CODE_02EBBE:
	TYA
	LDY.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_02EBC6
	CLC
	ADC.b #$06
CODE_02EBC6:
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

CODE_02EBCA:
	INC.b !RAM_SMW_NorSpr073_GroundSuperKoopa_CurrentState,x
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	RTS

GroundedSuperKoopaState01_Jumping:
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$14
	BMI.b CODE_02EBDE
	INC.b !RAM_SMW_NorSpr073_GroundSuperKoopa_CurrentState,x
CODE_02EBDE:
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	JSR.w CODE_02EBB5
	INC.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

GroundedSuperKoopaState02_Flying:
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w MaxXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BEQ.b CODE_02EBF8
	CLC
	ADC.b #$FF
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02EBF8:
	LDY.b #$02
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$04
	BEQ.b CODE_02EC01
	INY
CODE_02EC01:
	TYA
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

XDisp:
	db $08,$08,$10,$00
	db $08,$08,$10,$00
	db $08,$10,$10,$00
	db $08,$10,$10,$00
	db $09,$09,$00,$00
	db $09,$09,$00,$00
	db $08,$10,$00,$00
	db $08,$10,$00,$00
	db $08,$10,$00,$00
	db $00,$00,$F8,$00
	db $00,$00,$F8,$00
	db $00,$F8,$F8,$00
	db $00,$F8,$F8,$00
	db $FF,$FF,$00,$00
	db $FF,$FF,$00,$00
	db $00,$F8,$00,$00
	db $00,$F8,$00,$00
	db $00,$F8,$00,$00

YDisp:
	db $00,$08,$08,$00
	db $00,$08,$08,$00
	db $03,$03,$08,$00
	db $03,$03,$08,$00
	db $FF,$07,$00,$00
	db $FF,$07,$00,$00
	db $FD,$FD,$00,$00
	db $FD,$FD,$00,$00
	db $FD,$FD,$00,$00

; Sprite tiles for sprites 71, 72, and 73: Super Koopa.
Tiles:
	db $C8,$D8,$D0,$E0
	db $C9,$D9,$C0,$E2
	db $E4,$E5,$F2,$E0
	db $F4,$F5,$F2,$E0
	db $DA,$CA,$E0,$CF
	db $DB,$CB,$E0,$CF
	db $E4,$E5,$E0,$CF
	db $F4,$F5,$E2,$CF
	db $E4,$E5,$E2,$CF

; Partial data for the YXPPCCCT of Super Koopa. Bit 1 is used to determine
; whether the tile is part of the Koopa (0) or cape (1). If it is a cape
; tile, then the CCC bits should not be used; edit $02ED39 and $02ED40
; instead. Edit both $02ECA9 and $02ECAD from 00 to 01 to fix garbage tiles
; when a stomped left-flying Super Koopa is falling down.
Prop:
	db $03,$03,$03,$00
	db $03,$03,$03,$00
	db $03,$03,$01,$01
	db $03,$03,$01,$01
	db $83,$83,$80,$00				;\ Glitch: Thesed $00 bytes should be changed to $01 to fix the garbage sprite tiles that appear for these poses.
	db $83,$83,$80,$00				;/
	db $03,$03,$00,$01
	db $03,$03,$00,$01
	db $03,$03,$00,$01

TileSize:
	db $00,$00,$00,$02
	db $00,$00,$00,$02
	db $00,$00,$00,$02
	db $00,$00,$00,$02
	db $00,$00,$02,$00
	db $00,$00,$02,$00
	db $00,$00,$02,$00
	db $00,$00,$02,$00
	db $00,$00,$02,$00

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	AND.b #$0E
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM03
	PHX
	STZ.b !RAM_SMW_Misc_ScratchRAM04
CODE_02ECF7:
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.w TileSize,x
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	LSR
	LDA.w Prop,x
	AND.b #$02
	BEQ.b CODE_02ED4D
	PHP
	PHX
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.w !RAM_SMW_NorSpr073_GroundSuperKoopa_HasFeatherFlag,x
	BEQ.b CODE_02ED3B
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	AND.b #$01
	PHY
	TAY
	LDA.w DATA_02ED39,y
	PLY
	BRA.b CODE_02ED44

; Partial data for the YXPPCCCT of the flashing Super Koopa's cape.
; Specifically, these are the CCC bits (palette).
DATA_02ED39:
	db $10,$0A

CODE_02ED3B:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr072_YellowCapeSuperKoopa
	LDA.b #$08
	BCC.b CODE_02ED44
	LSR
CODE_02ED44:
	PLX
	PLP
	ORA.w Prop,x
	AND.b #$FD
	BRA.b CODE_02ED52

CODE_02ED4D:
	LDA.w Prop,x
	ORA.b !RAM_SMW_Misc_ScratchRAM05
CODE_02ED52:
	ORA.b !RAM_SMW_Sprites_TilePriority
	BCS.b CODE_02ED5F
	PHA
	TXA
	CLC
	ADC.b #$24
	TAX
	PLA
	ORA.b #$40
CODE_02ED5F:
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	INY
	INY
	INY
	INY
	INC.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CMP.b #$04
	BNE.b CODE_02ECF7
	PLX
	LDY.b #$FF
	LDA.b #$03
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr086_Wiggler_Status01(Address)
namespace SMW_NorSpr086_Wiggler_Status01
%InsertMacroAtXPosition(<Address>)

WigglerSegmentTablePointerLo:
	db ((!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable+$0000)-!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable)
	db ((!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable+$0080)-!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable)
	db ((!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable+$0100)-!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable)
	db ((!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable+$0180)-!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable)

WigglerSegmentTablePointerHi:
	db ((!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable+$0000)-!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable)>>8
	db ((!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable+$0080)-!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable)>>8
	db ((!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable+$0100)-!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable)>>8
	db ((!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable+$0180)-!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable)>>8

Bank02:
	PHB
	PHK
	PLB
	JSR.w GetWigglerSegmentPosIndex
	LDY.b #$7E
CODE_02EFFA:
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b [!RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo],y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	INY
	STA.b [!RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo],y
	DEY
	DEY
	DEY
	BPL.b CODE_02EFFA
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	PLB
	RTL

GetWigglerSegmentPosIndex:
	TXA
	AND.b #$03
	TAY
	LDA.b #!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable
	CLC
	ADC.w WigglerSegmentTablePointerLo,y
	STA.b !RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo
	LDA.b #!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable>>8
	ADC.w WigglerSegmentTablePointerHi,y
	STA.b !RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrHi
	LDA.b #!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable>>16
	STA.b !RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrBank
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr086_Wiggler_Status08(Address)
namespace SMW_NorSpr086_Wiggler_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

; Wiggler speed. First 2 bytes: normal speed. Next 2: mad speed
XSpeed:
	db $08,$F8
	db $10,$F0

Sub:
	JSR.w SMW_NorSpr086_Wiggler_Status01_GetWigglerSegmentPosIndex
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_02F03F
	JMP.w CODE_02F0D8

CODE_02F03F:
	JSL.l SMW_CheckForNormalSpriteToNormalSpriteCollision_Main
	LDA.w !RAM_SMW_NorSpr086_Wiggler_StunnedTimer,x
	BEQ.b CODE_02F061
	CMP.b #$01
	BNE.b CODE_02F050
	LDA.b #$08
	BRA.b CODE_02F052

CODE_02F050:
	AND.b #$0E
CODE_02F052:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	AND.b #$F1
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JMP.w CODE_02F0D8

CODE_02F061:
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr086_Wiggler_IsAngryFlag,x
	BEQ.b CODE_02F086
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	INC.w !RAM_SMW_NorSpr086_Wiggler_TurnTowardsMarioWhileAngryTimer,x
	LDA.w !RAM_SMW_NorSpr086_Wiggler_TurnTowardsMarioWhileAngryTimer,x
	AND.b #$3F
	BNE.b CODE_02F086
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
CODE_02F086:
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w !RAM_SMW_NorSpr086_Wiggler_IsAngryFlag,x
	BEQ.b CODE_02F090
	INY
	INY
CODE_02F090:
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if touching object
	AND.b #$03
	BNE.b CODE_02F0AE
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02F0AE
	JSR.w SMW_SetNormalSpriteYSpeedBasedOnSlope_Bank02
	BRA.b CODE_02F0C3

CODE_02F0AE:
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BNE.b CODE_02F0C3
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	STZ.w !RAM_SMW_NorSpr086_Wiggler_FlipSegmentsWhenTurningTimer,x
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
CODE_02F0C3:
	JSR.w CODE_02F0DB
	LDA.w !RAM_SMW_NorSpr086_Wiggler_FlipSegmentsWhenTurningTimer,x
	INC.w !RAM_SMW_NorSpr086_Wiggler_FlipSegmentsWhenTurningTimer,x
	AND.b #$07
	BNE.b CODE_02F0D8
	LDA.b !RAM_SMW_NorSpr086_Wiggler_IndividualSegmentFacingDirectionFlags,x
	ASL
	ORA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_NorSpr086_Wiggler_IndividualSegmentFacingDirectionFlags,x
CODE_02F0D8:
	JMP.w CODE_02F110

CODE_02F0DB:
	PHX
	PHB
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo
	CLC
	ADC.w #$007D
	TAX
	LDA.b !RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo
	CLC
	ADC.w #$007F
	TAY
	LDA.w #$007D
	MVP !RAM_SMW_NorSpr086_Wiggler_SegmentPosTable>>16,!RAM_SMW_NorSpr086_Wiggler_SegmentPosTable>>16
	SEP.b #$30			; AXY->8
	PLB
	PLX
	LDY.b #$00
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b [!RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo],y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	INY
	STA.b [!RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo],y
	RTS

DATA_02F103:
	db $00,$1E,$3E,$5E,$7E

WigglerYDisp:
	db $00,$01,$02,$01

; Wiggler's Body Tilemap
WigglerTiles:
	db $C4,$C6,$C8,$C6

CODE_02F110:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.w !RAM_SMW_NorSpr086_Wiggler_IsAngryFlag,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_NorSpr086_Wiggler_IndividualSegmentFacingDirectionFlags,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TYA
	CLC
	ADC.b #$04
	TAY
	LDX.b #$00
CODE_02F12D:
	PHX
	STX.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	LSR
	LSR
	LSR
	NOP #4
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM05
	AND.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM06
	PHY
	LDY.w DATA_02F103,x
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	BEQ.b CODE_02F14D
	TYA
	LSR
	AND.b #$FE
	TAY
CODE_02F14D:
	STY.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b [!RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo],y
	PLY
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PHY
	LDY.b !RAM_SMW_Misc_ScratchRAM09
	INY
	LDA.b [!RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo],y
	PLY
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDX.b !RAM_SMW_Misc_ScratchRAM06
	SEC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	SBC.l WigglerYDisp,x
else
	SBC.w WigglerYDisp,x
endif
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PLX
	PHX
	LDA.b #$8C
	CPX.b #$00
	BEQ.b CODE_02F178
	LDX.b !RAM_SMW_Misc_ScratchRAM06
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l WigglerTiles,x
else
	LDA.w WigglerTiles,x
endif
CODE_02F178:
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	ORA.b !RAM_SMW_Sprites_TilePriority
	LSR.b !RAM_SMW_Misc_ScratchRAM02
	BCS.b CODE_02F186
	ORA.b #$40
CODE_02F186:
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
	INX
	CPX.b #$05
	BNE.b CODE_02F12D
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	BEQ.b CODE_02F1C7
	PHX
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	TAX
	LDA.w SMW_OAMBuffer[$41].XDisp,y
	CLC
	ADC.w EyeXDisp,x
	PLX
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w SMW_OAMBuffer[$41].YDisp,y
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$88
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_OAMBuffer[$41].Prop,y
	BRA.b CODE_02F1EF

CODE_02F1C7:
	PHX
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	TAX
	LDA.w SMW_OAMBuffer[$41].XDisp,y
	CLC
	ADC.w FlowerXDisp,x
	PLX
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w SMW_OAMBuffer[$41].YDisp,y
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$98
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w SMW_OAMBuffer[$41].Prop,y
	AND.b #$F1
	ORA.b #$0A
CODE_02F1EF:
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	LDA.b #$05
	LDY.b #$FF
	JSR.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w #$0050
	CMP.w #$00A0
	SEP.b #$20			; A->8
	BCS.b Return02F295
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b Return02F295
	LDA.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
CODE_02F22B:
	LDA.w SMW_OAMBuffer[$41].XDisp,y
	SEC
	SBC.b !RAM_SMW_Player_OnScreenPosXLo				;\ Glitch: 8-Bit values being used for the player's on screen position means that this can cause the player to be able to interact with the wiggler at times you shouldn't.
	ADC.b #$0C							;| (Ex. Bounce off a wiggler at Y = 13 by falling into a pit that's directly below it).
	CMP.b #$18							;|
	BCS.b CODE_02F29B						;|
	LDA.w SMW_OAMBuffer[$41].YDisp,y				;|
	SEC								;|
	SBC.b !RAM_SMW_Player_OnScreenPosYLo				;/
	SBC.b #$10
	PHY
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_02F247
	SBC.b #$10
CODE_02F247:
	PLY
	CLC
	ADC.b #$0C
	CMP.b #$18
	BCS.b CODE_02F29B						; Glitch: Because there is no comparison for what priority the player has versus the wiggler, you can still interact with it even if you're behind a net.
									; Glitch: The player can land on the wiggler even if in a state where you normally can't interact with sprites because there is not check for the player's state.
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario has star
	BNE.b ADDR_02F29D
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	ORA.b !RAM_SMW_Player_OnScreenPosYHi
	BNE.b CODE_02F29B
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped
	BNE.b CODE_02F26B
	LDA.b !RAM_SMW_Player_YSpeed
	CMP.b #$08
	BMI.b CODE_02F296
CODE_02F26B:
	LDA.b #!Define_SMW_Sound1DF9_KickShell	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	JSL.l SMW_BoostMarioSpeed_Main
	LDA.w !RAM_SMW_NorSpr086_Wiggler_IsAngryFlag,x
	ORA.w !RAM_SMW_NorSpr_OnYoshisTongue,x
	BNE.b Return02F295
	JSL.l SMW_SpawnContactEffectFromAbove_Main
	LDA.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped		;\ Glitch: There is no cap on this RAM address, meaning that continuously stomping on wigglers will result in glitched score sprites spawning.
	INC.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped		;|
	JSL.l SMW_GivePoints_Main					;/
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr086_Wiggler_StunnedTimer,x
	INC.w !RAM_SMW_NorSpr086_Wiggler_IsAngryFlag,x
	JSR.w CODE_02F2D7
Return02F295:
	RTS

CODE_02F296:
	JSL.l SMW_DamagePlayer_Hurt
	RTS

CODE_02F29B:
	BRA.b CODE_02F2C7

ADDR_02F29D:
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	INC.w !RAM_SMW_Player_StarKillCount
	LDA.w !RAM_SMW_Player_StarKillCount
	CMP.b #$09
	BCC.b ADDR_02F2B5
	LDA.b #$09
	STA.w !RAM_SMW_Player_StarKillCount
ADDR_02F2B5:
	JSL.l SMW_GivePoints_Main
	LDY.w !RAM_SMW_Player_StarKillCount
	CPY.b #$08
	BCS.b Return02F2C6
	LDA.w StompSounds-$01,y		; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
Return02F2C6:
	RTS

CODE_02F2C7:
	INY
	INY
	INY
	INY
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BMI.b Return02F2D2
	JMP.w CODE_02F22B

Return02F2D2:
	RTS

; X placement of flower tile on Wiggler's head (1 byte facing right, 1 byte
; facing left)
FlowerXDisp:
	db $00,$08

; X placement of Wiggler's angry eyes tile (1 byte facing right, 1 byte
; facing left)
EyeXDisp:
	db $04,$04

CODE_02F2D7:
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_02F2D9:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_02F2E2
	DEY
	BPL.b CODE_02F2D9
	RTS				; / Return if no free slots

CODE_02F2E2:
	LDA.b #!Define_SMW_SpriteID_ExtSpr0E_WigglerFlower	; \ Extended sprite = Wiggler flower
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b #$01
	STA.w !RAM_SMW_ExtSpr0E_WigglerFlower_DisableBlockCollisionFlag,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDA.b #$D0
	STA.w !RAM_SMW_ExtSpr_YSpeed,y
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr086_Wiggler_Status08(Address)
namespace SMW_NorSpr086_Wiggler_Status08
%InsertMacroAtXPosition(<Address>)

StompSounds:
	%INLINEDATATABLE_SMW_StompSoundTable()
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr088_WingedCage_Status01(Address)
namespace SMW_NorSpr088_WingedCage_Status01
%InsertMacroAtXPosition(<Address>)

Bank02:
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr088_WingedCage_Status08(Address)
namespace SMW_NorSpr088_WingedCage_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ If sprites not locked,
	BNE.b ADDR_02CC05		; | increment sprite frame counter
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
ADDR_02CC05:
	JSR.w GFXRt
	PHX
	JSL.l SMW_NorSpr088_WingedCage_Status08_SyncLayer3ScrollToLayer1
	PLX
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.w !RAM_SMW_Misc_Layer1XDisp
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Player_CurrentState	; \ Return if Mario animation sequence active
	CMP.b #!Define_SMW_PlayerState01_PowerDown
	BCS.b SMW_NorSpr088_WingedCage_Status01_Bank02
	LDA.w !RAM_SMW_Flag_StandingOnBetaCage
	BEQ.b ADDR_02CC2D
	JSL.l SMW_NorSpr088_WingedCage_Status08_SyncPlayerPositionToLayer1
ADDR_02CC2D:
	LDY.b #$00
	LDA.w !RAM_SMW_Misc_Layer1YDisp
	BPL.b ADDR_02CC35
	DEY
ADDR_02CC35:
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	TYA
	ADC.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ $00 = Sprite X position
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ $02 = Sprite Y position
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_Player_XSpeed
	DEY
	BPL.b ADDR_02CC6C
	CLC
	ADC.w #$0000
	CMP.b !RAM_SMW_Player_XPosLo
	BCC.b ADDR_02CC7F
	STA.b !RAM_SMW_Player_XPosLo
	LDY.b #$00			; \ Mario's X speed = 0
	STY.b !RAM_SMW_Player_XSpeed
	BRA.b ADDR_02CC7F

ADDR_02CC6C:
	CLC
	ADC.w #$0090
	CMP.b !RAM_SMW_Player_XPosLo
	BCS.b ADDR_02CC7F
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w #$0091
	STA.b !RAM_SMW_Player_XPosLo
	LDY.b #$00
	STY.b !RAM_SMW_Player_XSpeed
ADDR_02CC7F:
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	LDY.b !RAM_SMW_Player_YSpeed
	BPL.b ADDR_02CC93
	CLC
	ADC.w #$0020
	CMP.b !RAM_SMW_Player_YPosLo
	BCC.b ADDR_02CCAE
	LDY.b #$00
	STY.b !RAM_SMW_Player_YSpeed
	BRA.b ADDR_02CCAE

ADDR_02CC93:
	CLC
	ADC.w #$0060
	CMP.b !RAM_SMW_Player_YPosLo
	BCS.b ADDR_02CCAE
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	ADC.w #$0061
	STA.b !RAM_SMW_Player_YPosLo
	LDY.b #$00
	STY.b !RAM_SMW_Player_YSpeed
	LDY.b #$01
	STY.w !RAM_SMW_Misc_PlayerOnSolidSprite
	STY.w !RAM_SMW_Flag_StandingOnBetaCage
ADDR_02CCAE:
	SEP.b #$20			; A->8
	RTL

; Unused cage wings: X offsets
XDisp:
	db $00,$30,$60,$90

; Unused cage wings: Y offsets
YDisp:
	db $F8,$00,$F8,$00

GFXRt:
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	STY.b !RAM_SMW_Misc_ScratchRAM02
ADDR_02CCD0:
	LDY.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l XDisp,x
else
	ADC.w XDisp,x
endif
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l YDisp,x
else
	ADC.w YDisp,x
endif
	STA.w SMW_OAMBuffer[$40].YDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LSR
	LSR
	LSR
	EOR.b !RAM_SMW_Misc_ScratchRAM08
	LSR
	LDA.b #$C6
	BCC.b ADDR_02CD01
	LDA.b #$81
ADDR_02CD01:
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$D6
	BCC.b ADDR_02CD0A
	LDA.b #$D7
ADDR_02CD0A:
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b #$70
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM02
	DEC.b !RAM_SMW_Misc_ScratchRAM08
	BPL.b ADDR_02CCD0
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr089_Layer3Smasher_Status08(Address)
namespace SMW_NorSpr089_Layer3Smasher_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	JSL.l UpdateLayer3SmasherPosition
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02D444
	JSR.w CODE_02D49C
	LDY.b #$00
	LDA.w !RAM_SMW_Misc_Layer1XDisp
	BPL.b CODE_02D3FD
	DEY
CODE_02D3FD:
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	TYA
	ADC.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_NorSpr089_Layer3Smasher_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

Layer3SmasherPtrs:
	dw State00_WaitInCeiling
	dw State01_SlowlyDescend
	dw State02_Smashing
	dw State03_WaitToRise
	dw State04_RiseUp

State00_WaitInCeiling:
	LDA.w !RAM_SMW_Timer_DisappearingSprite
	BEQ.b CODE_02D422
	JSR.w SMW_SubOffscreen_Bank02_EraseSprite
	; Change from 60 to 6B to fix the glitch where trying to disable the layer
	; 3 smasher with generator D2 will cause the game to crash.
	RTS								; Crash: This should be an RTL! This will cause the game to crash if you try to remove a layer 3 smasher using Normal sprite 0D2.

CODE_02D422:
	LDA.w !RAM_SMW_NorSpr089_Layer3Smasher_PhaseTimer,x
	BNE.b Return02D444
	INC.b !RAM_SMW_NorSpr089_Layer3Smasher_CurrentState,x
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$68
else
	LDA.b #$80
endif
	STA.w !RAM_SMW_NorSpr089_Layer3Smasher_PhaseTimer,x
	JSL.l SMW_GetRand_Main
	AND.b #$3F
	ORA.b #$80
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b #$FF
	STA.w !RAM_SMW_NorSpr_XPosHi,x
if defined("Define_SMW_SA1")
	JML.l Y_LOW_REMAP7
	NOP
else
	STZ.b !RAM_SMW_NorSpr_YPosLo,x
	STZ.w !RAM_SMW_NorSpr_YPosHi,x
endif
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
Return02D444:
	RTL

State01_SlowlyDescend:
	LDA.w !RAM_SMW_NorSpr089_Layer3Smasher_PhaseTimer,x
	BEQ.b CODE_02D452
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$06
else
	LDA.b #$04
endif
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	RTL

CODE_02D452:
	INC.b !RAM_SMW_NorSpr089_Layer3Smasher_CurrentState,x
	RTL

State02_Smashing:
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b CODE_02D460
if ver_is_pal(!Define_Global_ROMToAssemble)
	CMP.b #$70
else
	CMP.b #$40
endif
	BCS.b CODE_02D465
CODE_02D460:
	CLC
if ver_is_pal(!Define_Global_ROMToAssemble)
	ADC.b #$0A
else
	ADC.b #$07
endif
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02D465:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$A0
	BCC.b Return02D480
	AND.b #$F0
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$50			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr089_Layer3Smasher_PhaseTimer,x
	INC.b !RAM_SMW_NorSpr089_Layer3Smasher_CurrentState,x
Return02D480:
	RTL

State03_WaitToRise:
	LDA.w !RAM_SMW_NorSpr089_Layer3Smasher_PhaseTimer,x
	BNE.b Return02D488
	INC.b !RAM_SMW_NorSpr089_Layer3Smasher_CurrentState,x
Return02D488:
	RTL

State04_RiseUp:
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$D8
else
	LDA.b #$E0
endif
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	BNE.b Return02D49B
	STZ.b !RAM_SMW_NorSpr089_Layer3Smasher_CurrentState,x
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$88
else
	LDA.b #$A0
endif
	STA.w !RAM_SMW_NorSpr089_Layer3Smasher_PhaseTimer,x
Return02D49B:
	RTL

CODE_02D49C:
	LDA.b #$00
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_02D4A8
	LDY.b !RAM_SMW_Player_DuckingFlag
	BNE.b CODE_02D4A8
	LDA.b #$10
CODE_02D4A8:
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b !RAM_SMW_Player_OnScreenPosYLo
	BCC.b CODE_02D4EF
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_OnScreenPosXLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.w #$0030
	CMP.w #$0090
	BCS.b CODE_02D4EF
	SEC
	SBC.w #$0008
	CMP.w #$0080
	SEP.b #$20			; A->8
	BCS.b CODE_02D4E5
	LDA.b !RAM_SMW_Player_InAirFlag			;\ Glitch: Due to the order of events, pressing A/B every frame results in being able to survive under the sprite.
	BNE.b CODE_02D4DC				;/
	JSL.l SMW_DamagePlayer_Hurt
	RTS

CODE_02D4DC:
	STZ.b !RAM_SMW_Player_YSpeed
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b Return02D4E4
	STA.b !RAM_SMW_Player_YSpeed
Return02D4E4:
	RTS

CODE_02D4E5:
	PHP
	LDA.b #$08
	PLP
	BPL.b CODE_02D4ED
	LDA.b #$F8
CODE_02D4ED:
	STA.b !RAM_SMW_Player_XSpeed
CODE_02D4EF:
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr08A_Bird_Status08(Address)
namespace SMW_NorSpr08A_Bird_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
	BEQ.b CODE_02F321
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
CODE_02F321:
	JSR.w GFXRt
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.b #$03
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_NorSpr08A_Bird_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

BirdPtrs:
	dw Hopping
	dw Pecking

Return02F33B:				;\ Note: Unused
	RTS 				;/

DATA_02F33C:
	db $02,$03,$05,$01

XSpeed:
	db $08,$F8

Hopping:
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BMI.b Return02F370
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.b #$E8
	BCC.b Return02F370
	AND.b #$F8
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$F0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$30
	CMP.b #$60
	BCC.b CODE_02F381
	LDA.w !RAM_SMW_NorSpr08A_Bird_ActionCounter,x
	BEQ.b CODE_02F371
	DEC.w !RAM_SMW_NorSpr08A_Bird_ActionCounter,x
Return02F370:
	RTS

CODE_02F371:
	INC.b !RAM_SMW_NorSpr08A_Bird_CurrentState,x
	JSL.l SMW_GetRand_Main
	AND.b #$03
	TAY
	LDA.w DATA_02F33C,y
	STA.w !RAM_SMW_NorSpr08A_Bird_ActionCounter,x
	RTS

CODE_02F381:
	LDA.w !RAM_SMW_NorSpr08A_Bird_ForcedTurnAroundTimer,x
	BNE.b Return02F38E
	JSR.w CODE_02F3C1
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr08A_Bird_ForcedTurnAroundTimer,x
Return02F38E:
	RTS

Pecking:
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr08A_Bird_PeckingTimer,x
	BEQ.b CODE_02F3A3
	CMP.b #$08
	BCS.b Return02F3A2
	INC.w !RAM_SMW_NorSpr_AnimationFrame,x
Return02F3A2:
	RTS

CODE_02F3A3:
	LDA.w !RAM_SMW_NorSpr08A_Bird_ActionCounter,x
	BEQ.b CODE_02F3B7
	DEC.w !RAM_SMW_NorSpr08A_Bird_ActionCounter,x
	JSL.l SMW_GetRand_Main
	AND.b #$1F
	ORA.b #$0A
	STA.w !RAM_SMW_NorSpr08A_Bird_PeckingTimer,x
	RTS

CODE_02F3B7:
	STZ.b !RAM_SMW_NorSpr08A_Bird_CurrentState,x
	JSL.l SMW_GetRand_Main
	AND.b #$01
	BNE.b CODE_02F3CE
CODE_02F3C1:
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b #$0A
	STA.w !RAM_SMW_NorSpr_TurnAroundTimer,x
CODE_02F3CE:
	JSL.l SMW_GetRand_Main
	AND.b #$03
	CLC
	ADC.b #$02
	STA.w !RAM_SMW_NorSpr08A_Bird_ActionCounter,x
	RTS

; Yoshi's House Birds Tilemap
Tiles:
	db $D2,$D3,$D0,$D1,$9B

; Flip of birds' tiles (right, left)
Direction:
	db $71,$31

; Palettes of hopping birds
Palette:
	db $08,$04,$06,$0A

BirdOAMIndex:
	db $30,$34,$48,$3C

GFXRt:
	TXA
	AND.b #$03
	TAY
	LDA.w Palette,y
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	ORA.w Direction,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TXA
	AND.b #$03
	TAY
	LDA.w BirdOAMIndex,y
	TAY
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$00].YDisp,y
	PHX
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr08B_FireplaceSmoke_Status08(Address)
namespace SMW_NorSpr08B_FireplaceSmoke_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	INC.w !RAM_SMW_NorSPr08B_FireplaceSmoke_XSpeedFrameCount,x	;\ Note: This ought to be placed after the checck that prevents the smoke from moving horizontally.
	LDY.b #$04							;|
	LDA.w !RAM_SMW_NorSPr08B_FireplaceSmoke_XSpeedFrameCount,x	;|
	AND.b #$40							;|
	BEQ.b CODE_02F442						;|
	LDY.b #$FE							;|
CODE_02F442:								;|
	STY.b !RAM_SMW_NorSpr_XSpeed,x					;/
	LDA.b #$FC							;\ Optimization: This could be put in the init routine, as this never changes.
	STA.b !RAM_SMW_NorSpr_YSpeed,x					;/
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.w !RAM_SMW_NorSPr08B_FireplaceSmoke_NoHorizontalMovementFlag,x
	BNE.b CODE_02F453
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
CODE_02F453:
	JSR.w GFXRt
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$F0
	BNE.b Return02F462						; Glitch: If the screen is scrolling fast enough vertically, the smoke won't despawn.
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
Return02F462:
	RTS

DATA_02F463:
	db $03,$04,$05,$04,$05,$06,$05,$06
	db $07,$06,$07,$08,$07,$08,$07,$08
	db $07,$08,$07,$08,$07,$08,$07,$08
	db $07

GFXRt:									; Note: This sprite does not call GetDrawInfo
									; Glitch: This sprite does not call FinishOAMWrite, which means its tiles can wrap around the screen
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$0F
	BNE.b CODE_02F485
	INC.w !RAM_SMW_NorSPr08B_FireplaceSmoke_XDispIndex,x		;\ Glitch: This has no cap! If the smoke exists for too long, it will start glitching up!
CODE_02F485:								;|
	LDY.w !RAM_SMW_NorSPr08B_FireplaceSmoke_XDispIndex,x		;/
	LDA.w DATA_02F463,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	PHA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.b #$C5
	STA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b #$05
	STA.w SMW_OAMBuffer[$40].Prop,y
	ORA.b #$40
	STA.w SMW_OAMBuffer[$41].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr08C_SideExitAndFireplace_Status08(Address)
namespace SMW_NorSpr08C_SideExitAndFireplace_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:

	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDA.b #$01							;\ Optimization: This could have been put in the init routine and the sprite could have despawned if it was not set to also be a fireplace
	STA.w !RAM_SMW_Flag_SideExits					;| Glitch: Doing the above will fix a glitch where a sound plays if Yoshi hits this sprite with his tongue.
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	;|
	AND.b #$10							;|
	BNE.b NotAFireplace						;/
	JSR.w GFXRt
	JSR.w SmokeSpawn
NotAFireplace:
	RTS

; Tilemap of flame in Yoshi's House fireplace
TopTile:
	db $D4,$AB

BottomTile:
	db $BB,$9A

GFXRt:										; Note: This sprite does not call GetDrawInfo
										; Glitch: This sprite does not call FinishOAMWrite, which means its tiles can wrap around the screen
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x					;\ Note: Weird OAM index modification
	CLC									;|
	ADC.b #$08								;|
	TAY									;/
	LDA.b #$B8								;\ Glitch: Hardcoded X/Y disposition means that this sprite's tiles are fixed on screen as it scrolls.
	STA.w SMW_OAMBuffer[$40].XDisp,y					;|
	STA.w SMW_OAMBuffer[$41].XDisp,y					;|
	LDA.b #$B0								;|
	STA.w SMW_OAMBuffer[$40].YDisp,y					;|
	LDA.b #$B8								;|
	STA.w SMW_OAMBuffer[$41].YDisp,y					;/
	LDA.b !RAM_SMW_Counter_GlobalFrames
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	AND.b #$07
	BNE.b CODE_02F516
else
	AND.b #$03			;!
	BNE.b CODE_02F516		;!
	PHY				;!
	JSL.l SMW_GetRand_Main		;!
	PLY				;!
	AND.b #$03			;!
	BNE.b CODE_02F516		;!
	INC.b !RAM_SMW_NorSPr08C_SideExitAndFireplace_FrameIndex,x	;!
endif
CODE_02F516:
	PHX
	LDA.b !RAM_SMW_NorSPr08C_SideExitAndFireplace_FrameIndex,x
	AND.b #$01
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l TopTile,x
else
	LDA.w TopTile,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l BottomTile,x
else
	LDA.w BottomTile,x
endif
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b #$35
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
	PLX
	RTS

SmokeSpawn:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$3F
	BNE.b .Return
	JSR.w .CheckForEmptySlot
.Return:
	RTS

.CheckForEmptySlot:
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02
..Loop:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BEQ.b ..EmptySlot
	DEY
	BPL.b ..Loop
	RTS

..EmptySlot:
	LDA.b #!Define_SMW_SpriteID_NorSpr08B_FireplaceSmoke
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b #$BB
if defined("Define_SMW_SA1")
	; SA-1 Pack: Generator for smoke that comes out of the chimney in Yoshi's
	; house.
	JML.l YOSHI_CHIMNEY_SMOKE_FIX
else
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b #$00
endif
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b #$E0
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$20
	STA.w !RAM_SMW_NorSPr08B_FireplaceSmoke_NoHorizontalMovementFlag,x
	PLX
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr08D_GhostHouseDoor_Status08(Address)
namespace SMW_NorSpr08D_GhostHouseDoor_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:

	; Ghost House Exit main pointer. The actual routine is located at $02F5D0;
	; this is merely a wrapper for it, so it can JSL'ed.
	PHB
	PHK
	PLB
	PHX
	JSR.w Sub
	PLX
	PLB
	RTL

DATA_02F59E:
	db $08,$18,$F8,$F8,$F8,$F8,$28,$28
	db $28,$28

DATA_02F5A8:
	db $00,$00,$FF,$FF,$FF,$FF,$00,$00
	db $00,$00

YDisp:
	db $5F,$5F,$8F,$97,$A7,$AF,$8F,$97
	db $A7,$AF

; Ghost House Exit Door tilemap
Tile:
	db $9C,$9E,$A0,$B0,$B0,$A0,$A0,$B0
	db $B0,$A0

Prop:
	db $23,$23,$2D,$2D,$AD,$AD,$6D,$6D
	db $ED,$ED

Sub:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo			;\ Optimzation: If the sprite had called the above routines, this code would be unnecessary (aside from the LDX.b #$09).
	CMP.b #$46							;|
	BCS.b Return02F618						;|
	LDX.b #$09							;|
	LDY.b #$A0							;|
CODE_02F5DA:								;|
	STZ.b !RAM_SMW_Misc_ScratchRAM02				;|
	LDA.w DATA_02F59E,x						;|
	SEC								;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo			;|
	STA.b !RAM_SMW_Misc_ScratchRAM00				;|
	LDA.w DATA_02F5A8,x						;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi			;|
	BEQ.b CODE_02F5ED						;|
	INC.b !RAM_SMW_Misc_ScratchRAM02				;|
CODE_02F5ED:								;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tile,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_02F5DA
Return02F618:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr08E_WarpHole_Status08(Address)
namespace SMW_NorSpr08E_WarpHole_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	BCC.b Return
	STZ.b !RAM_SMW_Player_XSpeed
	LDA.b !RAM_SMW_NorSpr_XPosLo_x			;\ Glitch: This can cause a wall of glitch tiles to appear because the camera will teleport instead of scroll.
	CLC						;|
	ADC.b #$0A					;|
	STA.b !RAM_SMW_Player_XPosLo			;|
	LDA.w !RAM_SMW_NorSpr_XPosHi,x			;|
	ADC.b #$00					;|
	STA.b !RAM_SMW_Player_XPosHi			;/
Return:
	RTS

Return02EAF1:
	RTS ; unused
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr08F_ScalePlatform_Status08(Address)
namespace SMW_NorSpr08F_ScalePlatform_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	PHA
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	PLA
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	RTL

Sub:
	JSR.w SMW_SubOffscreen_Bank02_Entry3
	STZ.w !RAM_SMW_NorSPr08F_ScalePlatform_PlayerIsOnSpriteFlag
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	LDA.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosLo,x
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_NorSPr08F_ScalePlatform_RightPlatformXPosLo,x
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.w !RAM_SMW_NorSPr08F_ScalePlatform_RightPlatformXPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDY.b #$02
	JSR.w CODE_02E524
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	BCC.b CODE_02E4EB
	INC.w !RAM_SMW_NorSPr08F_ScalePlatform_PlayerIsOnSpriteFlag
	LDA.b #$F8
	JSR.w CODE_02E559
CODE_02E4EB:
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	LDY.b #$00
	JSR.w CODE_02E524
	BCC.b CODE_02E503
	INC.w !RAM_SMW_NorSPr08F_ScalePlatform_PlayerIsOnSpriteFlag
	LDA.b #$08
	JSR.w CODE_02E559
CODE_02E503:
	LDA.w !RAM_SMW_NorSPr08F_ScalePlatform_PlayerIsOnSpriteFlag
	BNE.b Return02E51F
	LDY.b #$02
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CMP.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosLo,x
	BEQ.b Return02E51F
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosHi,x
	BMI.b CODE_02E51B
	LDY.b #$FE
CODE_02E51B:
	TYA
	JSR.w CODE_02E559
Return02E51F:
	RTS

; Tiles left behind by mushroom scale platforms (in order of left platform
; sinking; rising, right platform rising; sinking)
MushrmScaleTiles:
	db $02,$07,$07,$02

CODE_02E524:
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	AND.b #$0F
	BNE.b CODE_02E54E
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BEQ.b CODE_02E54E
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BPL.b CODE_02E533
	INY
CODE_02E533:
	LDA.w MushrmScaleTiles,y
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
CODE_02E54E:
	JSR.w GFXRt
	STZ.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	JSL.l SMW_SolidSpriteBlock_Main
	RTS

CODE_02E559:
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02E57D
	PHA
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	PLA
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDY.b #$00
	LDA.w !RAM_SMW_Sprites_PositionDisp
	EOR.b #$FF
	INC
	BPL.b CODE_02E56F
	DEY
CODE_02E56F:
	CLC
	ADC.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosLo,x
	STA.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosLo,x
	TYA
	ADC.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosHi,x
	STA.w !RAM_SMW_NorSPr08F_ScalePlatform_InitialYPosHi,x
Return02E57D:
	RTS

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$10
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	DEC
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.b #$80
	STA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	ORA.b #$40
	STA.w SMW_OAMBuffer[$41].Prop,y
	LDA.b #$01
	LDY.b #$02
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr090_GreenGasBubble_Status08(Address)
namespace SMW_NorSpr090_GreenGasBubble_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

XSpeed:
	db $10,$F0

Acceleration:
	db $01,$FF

MaxYSpeed:
	db $10,$F0

Sub:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02E351
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b Return02E351
	LDY.w !RAM_SMW_NorSpr090_GreenGasBubble_HorizontalMovementDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_02E344
	LDA.b !RAM_SMW_NorSpr090_GreenGasBubble_VerticalDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w Acceleration,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w MaxYSpeed,y
	BNE.b CODE_02E344
	INC.b !RAM_SMW_NorSpr090_GreenGasBubble_VerticalDirection,x
CODE_02E344:
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
Return02E351:
	RTS

DATA_02E352:
	db $00,$10,$20,$30,$00,$10,$20,$30
	db $00,$10,$20,$30,$00,$10,$20,$30

DATA_02E362:
	db $00,$00,$00,$00,$10,$10,$10,$10
	db $20,$20,$20,$20,$30,$30,$30,$30

; Large Green Bubble Tilemap
Tiles:
	db $80,$82,$84,$86,$A0,$A2,$A4,$A6
	db $A0,$A2,$A4,$A6,$80,$82,$84,$86

; The YXPPCCCT properties of each tile in the tilemap of a Large Green
; Bubble ($3B is no flip, $7B is horizontal flip, $BB is vertical flip and
; $FB is horizontal + vertical flip).
Prop:
	db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	db $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB

DATA_02E392:
	db $00,$00,$02,$02,$00,$00,$02,$02
	db $01,$01,$03,$03,$01,$01,$03,$03

DATA_02E3A2:
	db $00,$01,$02,$01

DATA_02E3A6:
	db $02,$01,$00,$01

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	LSR
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w DATA_02E3A2,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w DATA_02E3A6,y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	PHX
	LDX.b #$0F
Loop:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_02E352,x
	PHA
	LDA.w DATA_02E392,x
	AND.b #$02
	BNE.b CODE_02E3DA
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	BRA.b CODE_02E3DE

CODE_02E3DA:
	PLA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
CODE_02E3DE:
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w DATA_02E362,x
	PHA
	LDA.w DATA_02E392,x
	AND.b #$01
	BNE.b CODE_02E3F5
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	BRA.b CODE_02E3F9

CODE_02E3F5:
	PLA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM03
CODE_02E3F9:
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b Loop
	PLX
	LDY.b #$02
	LDA.b #$0F
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr091_CharginChuck_Status08(Address)
namespace SMW_NorSpr091_CharginChuck_Status08
%InsertMacroAtXPosition(<Address>)

DATA_02C132:
	db $30,$20,$0A,$30

DATA_02C136:
	db $05,$0E,$0F,$10

State04_Digging:
	LDA.w !RAM_SMW_NorSpr046_DigginChuck_HeadTurnTimer,x
	BEQ.b CODE_02C156
	CMP.b #$01
	BNE.b CODE_02C150
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr046_DigginChuck_DiggingTimer,x
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr046_DigginChuck_DiggingAnimationFrameCounter,x
	STZ.w !RAM_SMW_NorSpr046_DigginChuck_ShovelAnimationFrame,x
CODE_02C150:
	LDA.b #$02
	STA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x
	RTS

CODE_02C156:
	LDA.w !RAM_SMW_NorSpr046_DigginChuck_DiggingTimer,x
	BNE.b CODE_02C181
	INC.w !RAM_SMW_NorSpr046_DigginChuck_DiggingAnimationFrameCounter,x
	LDA.w !RAM_SMW_NorSpr046_DigginChuck_DiggingAnimationFrameCounter,x
	AND.b #$03
	STA.w !RAM_SMW_NorSpr046_DigginChuck_ShovelAnimationFrame,x
	TAY
	LDA.w DATA_02C132,y
	STA.w !RAM_SMW_NorSpr046_DigginChuck_DiggingTimer,x
	CPY.b #$01
	BNE.b CODE_02C181
	LDA.w !RAM_SMW_NorSpr046_DigginChuck_DiggingAnimationFrameCounter,x
	AND.b #$0C
	BNE.b CODE_02C17E
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr046_DigginChuck_HeadTurnTimer,x
	RTS

CODE_02C17E:
	JSR.w CODE_02C19A
CODE_02C181:
	LDY.w !RAM_SMW_NorSpr046_DigginChuck_ShovelAnimationFrame,x
	LDA.w DATA_02C136,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w DATA_02C1F3,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x
	RTS

DigginChuckRockInitialXPosLo:
	db $14,$EC

DigginChuckRockInitialXPosHi:
	db $00,$FF

DigginChuckRockInitialXSpeed:
	db $08,$F8

CODE_02C19A:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return02C1F2
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr048_DigginChuckRock
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DigginChuckRockInitialXPosLo,x
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	ADC.w DigginChuckRockInitialXPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.w DigginChuckRockInitialXSpeed,x
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	PLX
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$0A
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b #$C0
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	LDA.b #$2C
	STA.w !RAM_SMW_NorSpr048_DigginChuckRock_InGroundTimer,y
Return02C1F2:
	RTS

DATA_02C1F3:
	db $01,$03

Bank02:
	PHB
	PHK
	PLB
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag,x
	PHA
	JSR.w CODE_02C22C
	PLA
	BNE.b CODE_02C211
	CMP.w !RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag,x
	BEQ.b CODE_02C211
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_UnusedLineOfSightTimer,x
	BNE.b CODE_02C211
	LDA.b #$28
	STA.w !RAM_SMW_NorSpr091_CharginChuck_UnusedLineOfSightTimer,x
CODE_02C211:
	PLB
	RTL

DATA_02C213:
	db $01,$02,$03,$02

CODE_02C217:
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w DATA_02C213,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x
	JSR.w GFXRt
	RTS

MaxYSpeed:
	db $40,$10

YAcceleration:
	db $03,$01

CODE_02C22C:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_02C217
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_WaitBeforeChargingTimer,x
	BEQ.b CODE_02C23D
	LDA.b #$05
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
CODE_02C23D:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if on ground
	AND.b #$04
	BNE.b CODE_02C253
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BPL.b CODE_02C253
	LDA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	CMP.b #$05
	BCS.b CODE_02C253
	LDA.b #$06
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
CODE_02C253:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_02C25B
	RTS

CODE_02C25B:
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSR.w ProcessPlayerInteraction
	JSL.l SMW_CheckForNormalSpriteToNormalSpriteCollision_Main
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	AND.b #$08
	BEQ.b CODE_02C274
	LDA.b #$10
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02C274:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not touching object
	AND.b #$03
	BEQ.b CODE_02C2F4
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b CODE_02C2E4
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag,x
	BEQ.b CODE_02C2E4
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.b #$14
	CMP.b #$1C
	BCC.b CODE_02C2E4
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if on ground
	AND.b #$40
	BNE.b CODE_02C2E4
	LDA.w !RAM_SMW_Blocks_CopyOfCurrentlyProcessedMap16TileLo2
	CMP.b #$2E
	BEQ.b CODE_02C2A6
	CMP.b #$1E
	BNE.b CODE_02C2E4
CODE_02C2A6:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02C2F7
	LDA.b !RAM_SMW_Blocks_XPosHi
	PHA
	LDA.b !RAM_SMW_Blocks_XPosLo
	PHA
	LDA.b !RAM_SMW_Blocks_YPosHi
	PHA
	LDA.b !RAM_SMW_Blocks_YPosLo
	PHA
	JSL.l SMW_SpawnBrickPieces_Main
	LDA.b #$02			; \ Block to generate = #$02
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
	PLA
	SEC
	SBC.b #$10
	STA.b !RAM_SMW_Blocks_YPosLo
	PLA
	SBC.b #$00
	STA.b !RAM_SMW_Blocks_YPosHi
	PLA
	STA.b !RAM_SMW_Blocks_XPosLo
	PLA
	STA.b !RAM_SMW_Blocks_XPosHi
	JSL.l SMW_SpawnBrickPieces_Main
	LDA.b #$02			; \ Block to generate = #$02
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
	BRA.b CODE_02C2F4

CODE_02C2E4:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02C2F7
	LDA.b #$C0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	BRA.b CODE_02C301

CODE_02C2F4:
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
CODE_02C2F7:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02C301
	JSR.w CODE_02C579
CODE_02C301:
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDY.w !RAM_SMW_NorSpr_InLiquidFlag,x
	CPY.b #$01
	LDY.b #$00
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	BCC.b CODE_02C31A
	INY
	CMP.b #$00
	BPL.b CODE_02C31A
	CMP.b #$E0
	BCS.b CODE_02C31A
	LDA.b #$E0
CODE_02C31A:
	CLC
	ADC.w YAcceleration,y
	BMI.b CODE_02C328
	CMP.w MaxYSpeed,y
	BCC.b CODE_02C328
	LDA.w MaxYSpeed,y
CODE_02C328:
	TAY
	BMI.b CODE_02C334
	LDY.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	CPY.b #$07
	BNE.b CODE_02C334
	CLC
	ADC.b #$03
CODE_02C334:
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

ChuckPtrs:
	dw State00_LookingSideToSide
	dw State01_Charging
	dw State02_PrepareToCharge
	dw State03_Hurt
	dw State04_Digging
	dw State05_PrepareToJumpOrSplit
	dw State06_Jumping
	dw State07_LandFromJump
	dw State08_Clappin
	dw State09_Puntin
	dw State0A_Pitchin
	dw State0B_WaitToWhistle
	dw State0C_Whistlin

State0B_WaitToWhistle:
	LDA.b #$03
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr_InLiquidFlag,x
	BEQ.b CODE_02C370
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$30
	CMP.b #$60
	BCS.b CODE_02C370
	LDA.b #$0C
	STA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
CODE_02C370:
	JMP.w CODE_02C556

DATA_02C373:
	db $05,$05,$05,$02,$02,$06,$06,$06

State0C_Whistlin:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$3F
	BNE.b CODE_02C386
	LDA.b #!Define_SMW_Sound1DFC_ChuckWhistle	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_02C386:
	LDY.b #$03
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$30
	BEQ.b CODE_02C390
	LDY.b #$06
CODE_02C390:
	TYA
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$07
	TAY
	LDA.w DATA_02C373,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	LSR
	LSR
	LSR
	LSR
	LSR
	LDA.b #!Define_SMW_SpriteID_GenSpr09_GenerateSuperKoopa
	BCC.b CODE_02C3AF
	STA.w !RAM_SMW_GenSpr_SpriteID
CODE_02C3AF:
	STA.w !RAM_SMW_Flag_WakeUpRipVanFish
	RTS

; Timers for Pitchin' Chuck's throwing. This table is indexed by the initial
; sprite X position. The timers themselves are formatted thus: t = $3F +
; $20n, where t is the timer value and n is the number of baseballs thrown
; in a row. So the sprite will throw 2, 4, 6, or 5 baseballs depending on
; its X position. However, this applies only when it is on the ground; if it
; is in the air, then the timing is different.
DATA_02C3B3:
	db $7F,$BF,$FF,$DF

; Pitchin' Chuck's animation frames when throwing baseballs while on the
; ground.
DATA_02C3B7:
	db $18,$19,$14,$14

; Pitchin' Chuck's animation frames when throwing baseballs while jumping.
DATA_02C3BB:
	db $18,$18,$18,$18,$17,$17,$17,$17
	db $17,$17,$16,$15,$15,$16,$16,$16

State0A_Pitchin:
	LDA.w !RAM_SMW_NorSpr098_PitchinChuck_JumpingFlag,x
	BNE.b CODE_02C43A
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_Y
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	BPL.b CODE_02C3E7
	CMP.b #$D0
	BCS.b CODE_02C3E7
	LDA.b #$C8
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$3E
	STA.w !RAM_SMW_NorSpr098_PitchinChuck_PhaseTimer,x
	INC.w !RAM_SMW_NorSpr098_PitchinChuck_JumpingFlag,x
CODE_02C3E7:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	BNE.b CODE_02C3F5
	LDA.w !RAM_SMW_NorSpr098_PitchinChuck_PhaseTimer,x
	BEQ.b CODE_02C3F5
	INC.w !RAM_SMW_NorSpr098_PitchinChuck_PhaseTimer,x
CODE_02C3F5:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$3F
	BNE.b CODE_02C3FE
	JSR.w CODE_02C556
CODE_02C3FE:
	LDA.w !RAM_SMW_NorSpr098_PitchinChuck_PhaseTimer,x
	BNE.b CODE_02C40C
	LDY.w !RAM_SMW_NorSpr098_PitchinChuck_BaseballThrowSetIndex,x
	LDA.w DATA_02C3B3,y
	STA.w !RAM_SMW_NorSpr098_PitchinChuck_PhaseTimer,x
CODE_02C40C:
	LDA.w !RAM_SMW_NorSpr098_PitchinChuck_PhaseTimer,x
	CMP.b #$40
	BCS.b CODE_02C419
	LDA.b #$00
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	RTS

CODE_02C419:
	SEC
	SBC.b #$40
	LSR
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w DATA_02C3B7,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr098_PitchinChuck_PhaseTimer,x
	AND.b #$1F
	CMP.b #$06
	BNE.b Return02C439
	JSR.w CODE_02C466
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr098_PitchinChuck_WaitBeforeThrowingNextBaseball,x
Return02C439:
	RTS

CODE_02C43A:
	LDA.w !RAM_SMW_NorSpr098_PitchinChuck_PhaseTimer,x
	BEQ.b CODE_02C45C
	PHA
	CMP.b #$20
	BCC.b CODE_02C44A
	CMP.b #$30
	BCS.b CODE_02C44A
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_02C44A:
	LSR
	LSR
	TAY
	LDA.w DATA_02C3BB,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	PLA
	CMP.b #$26
	BNE.b Return02C45B
	JSR.w CODE_02C466
Return02C45B:
	RTS

CODE_02C45C:
	STZ.w !RAM_SMW_NorSpr098_PitchinChuck_JumpingFlag,x
	RTS

; Starting X-coordinate of baseball when thrown by Chuck (facing right,
; facing left)
BaseballInitialXPosLo:
	db $10,$F8

BaseballInitialXPosHi:
	db $00,$FF

; X speed of baseball when thrown by Chuck (right, left)
BaseballInitialXSpeed:
	db $18,$E8

CODE_02C466:
	LDA.w !RAM_SMW_NorSpr098_PitchinChuck_WaitBeforeThrowingNextBaseball,x
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b Return02C439
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_02C470:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_02C479
	DEY
	BPL.b CODE_02C470
	RTS				; / Return if no free slots

CODE_02C479:
	LDA.b #!Define_SMW_SpriteID_ExtSpr0D_Baseball	; \ Extended sprite = Baseball
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	CLC
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	PHX
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w BaseballInitialXPosLo,x
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	ADC.w BaseballInitialXPosHi,x
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.w BaseballInitialXSpeed,x
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
	PLX
	RTS

DATA_02C4B5:
	db $00,$00,$11,$11,$11,$11,$00,$00

State09_Puntin:
	STZ.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	TXA
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$7F
	CMP.b #$00
	BNE.b CODE_02C4D5
	PHA
	JSR.w CODE_02C556
	JSL.l SMW_SpawnFootball_Main
	PLA
CODE_02C4D5:
	CMP.b #$20
	BCS.b Return02C4E2
	LSR
	LSR
	TAY
	LDA.w DATA_02C4B5,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
Return02C4E2:
	RTS

State08_Clappin:
	JSR.w CODE_02C556
	LDA.b #$06
	LDY.b !RAM_SMW_NorSpr_YSpeed,x
	CPY.b #$F0
	BMI.b CODE_02C504
	LDY.w !RAM_SMW_NorSpr095_ClappinChuck_JumpingFlag,x
	BEQ.b CODE_02C504
	LDA.w !RAM_SMW_NorSpr095_ClappinChuck_WaitBeforeClapSound,x
	BNE.b CODE_02C502
	LDA.b #!Define_SMW_Sound1DFC_Clap	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr095_ClappinChuck_WaitBeforeClapSound,x
CODE_02C502:
	LDA.b #$07
CODE_02C504:
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b Return02C53B
	STZ.w !RAM_SMW_NorSpr095_ClappinChuck_JumpingFlag,x
	LDA.b #$04
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr095_ClappinChuck_WaitBeforeJumpsOrHops,x
	BNE.b Return02C53B
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr095_ClappinChuck_WaitBeforeJumpsOrHops,x
	LDA.b #$F0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_Y
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	BPL.b Return02C53B
	CMP.b #$D0
	BCS.b Return02C53B
	LDA.b #$C0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	INC.w !RAM_SMW_NorSpr095_ClappinChuck_JumpingFlag,x
CODE_02C536:
	LDA.b #!Define_SMW_Sound1DFC_Springboard	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
Return02C53B:
	RTS

State06_Jumping:
	LDA.b #$06
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b Return02C555
	JSR.w CODE_02C579
	JSR.w CODE_02C556
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	INC.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
Return02C555:
	RTS

CODE_02C556:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w DATA_02C639,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x
	RTS

State07_LandFromJump:
	LDA.b #$03
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	BNE.b CODE_02C579
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b Return02C57D
	LDA.b #$05
	STA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
CODE_02C579:
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
Return02C57D:
	RTS

SplittingInitialXSpeed:
	db $10,$F0

JumpingInitialXSpeed:
	db $20,$E0

State05_PrepareToJumpOrSplit:
	JSR.w CODE_02C556
	LDA.w !RAM_SMW_NorSpr092_SplittinChuck_WaitBeforeSplittin,x
	BEQ.b CODE_02C602
	CMP.b #$01
	BNE.b CODE_02C5FC
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr093_BouncinChuck
	BNE.b CODE_02C5A7
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.w JumpingInitialXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$B0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$06
	STA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	JMP.w CODE_02C536

CODE_02C5A7:
	STZ.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	LDA.b #$50
	STA.w !RAM_SMW_NorSpr092_SplittinChuck_WaitBeforeSplittin,x
	LDA.b #!Define_SMW_Sound1DF9_MagicShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	STZ.w !RAM_SMW_NorSpr092_SplittinChuck_SpawnChuckIndex
	JSR.w CODE_02C5BC
	INC.w !RAM_SMW_NorSpr092_SplittinChuck_SpawnChuckIndex
CODE_02C5BC:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority
	BMI.b CODE_02C5FC
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr091_CharginChuck
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
	LDX.w !RAM_SMW_NorSpr092_SplittinChuck_SpawnChuckIndex
	LDA.w SplittingInitialXSpeed,x
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	PLX
	LDA.b #$C8
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	LDA.b #$50
	STA.w !RAM_SMW_NorSpr092_SplittinChuck_WaitBeforeSplittin,y
CODE_02C5FC:
	LDA.b #$09
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	RTS

CODE_02C602:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CLC
	ADC.b #$50
	CMP.b #$A0
	BCS.b CODE_02C618
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr092_SplittinChuck_WaitBeforeSplittin,x
	RTS

CODE_02C618:
	LDA.b #$03
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$3F
	BNE.b Return02C627
	LDA.b #$E0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
Return02C627:
	RTS

CODE_02C628:
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr091_CharginChuck_WaitBeforeChargingTimer,x
	RTS

DATA_02C62E:
	db $00,$00,$00,$00,$01,$02,$03,$04
	db $04,$04,$04

DATA_02C639:
	db $00,$04

State00_LookingSideToSide:
	LDA.b #$03
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	STZ.w !RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag,x
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	AND.b #$0F
	BNE.b CODE_02C668
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_Y
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CLC
	ADC.b #$28
	CMP.b #$50
	BCS.b CODE_02C668
	JSR.w CODE_02C556
	INC.w !RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag,x
CODE_02C65C:
	LDA.b #$02
	STA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	LDA.b #$18
	STA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	RTS

DATA_02C666:
	db $01,$FF

CODE_02C668:
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	BNE.b CODE_02C677
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	BRA.b CODE_02C65C

CODE_02C677:
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$03
	BNE.b CODE_02C691
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_HeadTurnCounter,x
	AND.b #$01
	TAY
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_HeadAnimationFrameCounter,x
	CLC
	ADC.w DATA_02C666,y
	CMP.b #$0B
	BCS.b CODE_02C69B
	STA.w !RAM_SMW_NorSpr091_CharginChuck_HeadAnimationFrameCounter,x
CODE_02C691:
	LDY.w !RAM_SMW_NorSpr091_CharginChuck_HeadAnimationFrameCounter,x
	LDA.w DATA_02C62E,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x
	RTS

CODE_02C69B:
	INC.w !RAM_SMW_NorSpr091_CharginChuck_HeadTurnCounter,x
	RTS

ChargingXSpeed:
	db $10,$F0,$18,$E8

DATA_02C6A3:
	db $12,$13,$12,$13

State01_Charging:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02C6BA
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_UnusedLineOfSightTimer,x
	CMP.b #$01
	BRA.b CODE_02C6BA

ADDR_02C6B5: ; unreachable, aha! the unused sfx 24
	LDA.b #!Define_SMW_Sound1DF9_Unused	; \ Unreachable
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_02C6BA:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_Y
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CLC
	ADC.b #$30
	CMP.b #$60
	BCS.b CODE_02C6D7
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	TYA
	CMP.w !RAM_SMW_NorSpr_FacingDirection,x
	BNE.b CODE_02C6D7
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	STA.w !RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag,x
CODE_02C6D7:
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	BNE.b CODE_02C6EC
	STZ.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	JSR.w CODE_02C628
	JSL.l SMW_GetRand_Main
	AND.b #$3F
	ORA.b #$40
	STA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
CODE_02C6EC:
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w DATA_02C639,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02C713
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag,x
	BEQ.b CODE_02C70E
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$07
	BNE.b CODE_02C70C
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
CODE_02C70C:
	INY
	INY
CODE_02C70E:
	LDA.w ChargingXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
CODE_02C713:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LDY.w !RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag,x
	BNE.b CODE_02C71B
	LSR
CODE_02C71B:
	LSR
	AND.b #$03
	TAY
	LDA.w DATA_02C6A3,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	RTS

State02_PrepareToCharge:
	LDA.b #$03
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	BNE.b Return02C73C
	JSR.w CODE_02C628
	LDA.b #$01
	STA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	LDA.b #$40
	STA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
Return02C73C:
	RTS

DATA_02C73D:
	db $0A,$0B,$0A,$0C,$0D,$0C

HurtAnimationFrameCounter:
	db $0C,$10,$10,$04,$08,$10,$18

State03_Hurt:
	LDY.w !RAM_SMW_NorSprXXX_Chucks_HurtFrameCounter,x
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	BNE.b CODE_02C760
	INC.w !RAM_SMW_NorSprXXX_Chucks_HurtFrameCounter,x
	INY
	CPY.b #$07
	BEQ.b CODE_02C777
	LDA.w HurtAnimationFrameCounter,y
	STA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
CODE_02C760:
	LDA.w DATA_02C73D,y
	STA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	LDA.b #$02
	CPY.b #$05
	BNE.b CODE_02C773
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	NOP
	AND.b #$02
	INC
CODE_02C773:
	STA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x
	RTS

CODE_02C777:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr094_WhistlinChuck
	BEQ.b CODE_02C794
	CMP.b #!Define_SMW_SpriteID_NorSpr046_DigginChuck
	BNE.b CODE_02C785
	LDA.b #!Define_SMW_SpriteID_NorSpr091_CharginChuck
	STA.b !RAM_SMW_NorSpr_SpriteID_x
CODE_02C785:
	LDA.b #$30
	STA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	LDA.b #$02
	STA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	INC.w !RAM_SMW_NorSpr091_CharginChuck_HasLineOfSightFlag,x
	JMP.w CODE_02C556

CODE_02C794:
	LDA.b #$0C
	STA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	RTS

UNK_02C799:
	db $F0,$10

StompKnockbackXSpeed:
	db $20,$E0

ProcessPlayerInteraction:
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x
	BNE.b Return02C80F
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	BCC.b Return02C80F
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario doesn't have star
	BEQ.b CODE_02C7C4
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02C7B1:
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_Sound1DF9_KickShell	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #$03
	JSL.l SMW_GivePoints_Main
	RTS

CODE_02C7C4:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_Y
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CMP.b #$EC
	BPL.b CODE_02C810
	LDA.b #$05
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x
	LDA.b #!Define_SMW_Sound1DF9_Contact	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	JSL.l SMW_SpawnContactEffectFromAbove_Main
	JSL.l SMW_BoostMarioSpeed_Main
	STZ.w !RAM_SMW_NorSpr091_CharginChuck_UnusedLineOfSightTimer,x
	; change from [B5 C2 C9 03 F0 27] to [EA EA EA EA EA EA] to remove the
	; stomp immunity chucks get briefly when taking a stomp.
	LDA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	CMP.b #$03
	BEQ.b Return02C80F
	; Set to BD for unlimited Chargin Chuck stomping hp
	INC.w !RAM_SMW_NorSprXXX_Chucks_HitCounter,x	; Increase Chuck stomp count
	LDA.w !RAM_SMW_NorSprXXX_Chucks_HitCounter,x	; \ Kill Chuck if stomp count >= 3
	CMP.b #$03
	BCC.b CODE_02C7F6
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; | Sprite Y Speed = 0
	BRA.b CODE_02C7B1

CODE_02C7F6:
	LDA.b #!Define_SMW_Sound1DFC_StunEnemy	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #$03
	STA.b !RAM_SMW_NorSprXXX_Chucks_CurrentState,x
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	STZ.w !RAM_SMW_NorSprXXX_Chucks_HurtFrameCounter,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.w StompKnockbackXSpeed,y
	STA.b !RAM_SMW_Player_XSpeed
Return02C80F:
	RTS

CODE_02C810:
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b Return02C819
	JSL.l SMW_DamagePlayer_Hurt
Return02C819:
	RTS

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	JSR.w DrawHead
	JSR.w DrawBody
	JSR.w DrawExtraTiles
	JSR.w DrawDigginChuckExtraTiles
	LDY.b #$FF
CODE_02C82B:
	LDA.b #$04
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

; Horizontal disposition of Chuck's head (all variations).
HeadXDisp:
	db $F8				; Sittin' left/right
	db $F8				; Unused
	db $F8				; Unused
	db $00				; Sittin' towards screen
	db $00				; Crouchin'
	db $FE				; Sittin' slightly left/right
	db $00				; Whistlin'/Jumpin'
	db $00				; Clappin'
	db $FA				; Unused
	db $00				; Crouchin'
	db $00				;\ Hurt
	db $00				;|
	db $00				;|
	db $00				;/
	db $00				; Diggin' (Put Shovel in Ground)
	db $FD				; Diggin' (Hold Shovel Level)
	db $FD				; Diggin' (Raise Shovel)
	db $F9				; Puntin'
	db $F6				;\ Chargin'
	db $F6				;/
	db $F8				; Wait to throw baseball
	db $FE				;\ Jumpin' to throw baseballs
	db $FC				;|
	db $FA				;/
	db $F8				;\ Throwin' baseballs
	db $FA				;/

; Vertical disposition of Chuck's head (all variations).
HeadYDisp:
	db $F8				; Sittin' left/right
	db $F9				; Unused
	db $F7				; Unused
	db $F8				; Sittin' towards screen
	db $FC				; Crouchin'
	db $F8				; Sittin' slightly left/right
	db $F4				; Whistlin'/Jumpin'
	db $F5				; Clappin'
	db $F5				; Unused
	db $FC				; Crouchin'
	db $FD				;\ Hurt
	db $00				;|
	db $F9				;|
	db $F5				;/
	db $F8				; Diggin' (Put Shovel in Ground)
	db $FA				; Diggin' (Hold Shovel Level)
	db $F6				; Diggin' (Raise Shovel)
	db $F6				; Puntin'
	db $F4				;\ Chargin'
	db $F4				;/
	db $F8				; Wait to throw baseball
	db $F6				;\ Jumpin' to throw baseballs
	db $F6				;|
	db $F8				;/
	db $F8				;\ Throwin' baseballs
	db $F5				;/

HeadOAMIndexOffset:
	db $08				; Sittin' left/right
	db $08				; Unused
	db $08				; Unused
	db $00				; Sittin' towards screen
	db $00				; Crouchin'
	db $00				; Sittin' slightly left/right
	db $08				; Whistlin'/Jumpin'
	db $08				; Clappin'
	db $08				; Unused
	db $00				; Crouchin'
	db $08				;\ Hurt
	db $08				;|
	db $00				;|
	db $00				;/
	db $00				; Diggin' (Put Shovel in Ground)
	db $00				; Diggin' (Hold Shovel Level)
	db $00				; Diggin' (Raise Shovel)
	db $08				; Puntin'
	db $10				;\ Chargin'
	db $10				;/
	db $0C				; Wait to throw baseball
	db $0C				;\ Jumpin' to throw baseballs
	db $0C				;|
	db $0C				;/
	db $0C				;\ Throwin' baseballs
	db $0C				;/

; Sprite tilemap: Chuck Head(All)
HeadTiles:
	db $06				; Right
	db $0A				; Slightly right
	db $0E				; Towards screen
	db $0A				; Slightly left
	db $06				; Left
	db $4B				; Up left
	db $4B				; Up right

HeadProp:
	db $40				; Right
	db $40				; Slightly right
	db $00				; Towards screen
	db $00				; Slightly left
	db $00				; Left
	db $00				; Up left
	db $40				; Up right

DrawHead:
	STZ.b !RAM_SMW_Misc_ScratchRAM07
	LDY.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	STY.b !RAM_SMW_Misc_ScratchRAM04
	CPY.b #$09
	CLC
	BNE.b CODE_02C8AB
	LDA.w !RAM_SMW_NorSpr091_CharginChuck_PhaseTimer,x
	SEC
	SBC.b #$20
	BCC.b CODE_02C8AB
	PHA
	LSR
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM07
	PLA
	LSR
	LSR
CODE_02C8AB:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSprXXX_Chucks_HeadAnimationFrame,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_NorSpr_Table7E15F6,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	STA.b !RAM_SMW_Misc_ScratchRAM05
	CLC
	ADC.w HeadOAMIndexOffset,y
	TAY
	LDX.b !RAM_SMW_Misc_ScratchRAM04
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l HeadXDisp,x
else
	LDA.w HeadXDisp,x
endif
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	BNE.b CODE_02C8D8
	EOR.b #$FF
	INC
CODE_02C8D8:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l HeadYDisp,x
else
	ADC.w HeadYDisp,x
endif
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM07
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM02
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l HeadProp,x
else
	LDA.w HeadProp,x
endif
	ORA.b !RAM_SMW_Misc_ScratchRAM08
	STA.w SMW_OAMBuffer[$40].Prop,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l HeadTiles,x
else
	LDA.w HeadTiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

; Horizontal disposition of Chuck's body (all variations).
BodyXDisp1:
	db $F8				; Sittin' left/right (hand)
	db $F8				; Unused
	db $F8				; Unused
	db $FC				; Sittin' towards screen
	db $FC				; Crouchin'
	db $FC				; Sittin' slightly left/right
	db $FC				; Whistlin'/Jumpin'
	db $F8				; Clappin'
	db $01				; Unused
	db $FC				; Crouchin'
	db $FC				;\ Hurt
	db $FC				;|
	db $FC				;|
	db $FC				;/
	db $FC				; Diggin' (Put Shovel in Ground)
	db $FC				; Diggin' (Hold Shovel Level)
	db $FC				; Diggin' (Raise Shovel)
	db $F8				; Puntin' (Foot)
	db $F8				;\ Chargin'
	db $F8				;/
	db $F8				; Wait to throw baseball (hand)
	db $08				;\ Jumpin' to throw baseballs (hand)
	db $06				;|
	db $F8				;/
	db $F8				;\ Throwin' baseballs (hand)
	db $01				;/

	db $10				; Sittin' left/right (hand)
	db $10				; Unused
	db $10				; Unused
	db $04				; Sittin' towards screen
	db $04				; Crouchin'
	db $04				; Sittin' slightly left/right
	db $04				; Whistlin'/Jumpin'
	db $08				; Clappin'
	db $07				; Unused
	db $04				; Crouchin'
	db $04				;\ Hurt
	db $04				;|
	db $04				;|
	db $04				;/
	db $04				; Diggin' (Put Shovel in Ground)
	db $04				; Diggin' (Hold Shovel Level)
	db $04				; Diggin' (Raise Shovel)
	db $10				; Puntin' (Foot)
	db $08				;\ Chargin'
	db $08				;/
	db $10				; Wait to throw baseball (hand)
	db $00				;\ Jumpin' to throw baseballs (hand)
	db $02				;|
	db $10				;/
	db $10				;\ Throwin' baseballs (hand)
	db $07				;/

BodyXDisp2:
	db $00				; Sittin' left/right (body)
	db $00				; Unused
	db $00				; Unused
	db $04				; Sittin' towards screen
	db $04				; Crouchin'
	db $04				; Sittin' slightly left/right
	db $04				; Whistlin'/Jumpin'
	db $08				; Clappin'
	db $00				; Unused
	db $04				; Crouchin'
	db $04				;\ Hurt
	db $04				;|
	db $04				;|
	db $04				;/
	db $04				; Diggin' (Put Shovel in Ground)
	db $04				; Diggin' (Hold Shovel Level)
	db $04				; Diggin' (Raise Shovel)
	db $00				; Puntin' (body)
	db $00				;\ Chargin'
	db $00				;/
	db $00				; Wait to throw baseball (body)
	db $00				;\ Jumpin' to throw baseballs (body)
	db $00				;|
	db $00				;/
	db $00				;\ Throwin' baseballs (body)
	db $00				;/

	db $00				; Sittin' left/right (body)
	db $00				; Unused
	db $00				; Unused
	db $FC				; Sittin' towards screen
	db $FC				; Crouchin'
	db $FC				; Sittin' slightly left/right
	db $FC				; Whistlin'/Jumpin'
	db $F8				; Clappin'
	db $00				; Unused
	db $FC				; Crouchin'
	db $FC				;\ Hurt
	db $FC				;|
	db $FC				;|
	db $FC				;/
	db $FC				; Diggin' (Put Shovel in Ground)
	db $FC				; Diggin' (Hold Shovel Level)
	db $FC				; Diggin' (Raise Shovel)
	db $00				; Puntin' (body)
	db $00				;\ Chargin'
	db $00				;/
	db $00				; Wait to throw baseball (body)
	db $00				;\ Jumpin' to throw baseballs (body)
	db $00				;|
	db $00				;/
	db $00				;\ Throwin' baseballs (body)
	db $00				;/

; Vertical disposition of Chuck's body (all variations).
BodyYDisp1:
	db $06				; Sittin' left/right (hand)
	db $06				; Unused
	db $06				; Unused
	db $00				; Sittin' towards screen
	db $00				; Crouchin'
	db $00				; Sittin' slightly left/right
	db $00				; Whistlin'/Jumpin'
	db $00				; Clappin'
	db $F8				; Unused
	db $00				; Crouchin'
	db $00				;\ Hurt
	db $00				;|
	db $00				;|
	db $00				;/
	db $00				; Diggin' (Put Shovel in Ground)
	db $00				; Diggin' (Hold Shovel Level)
	db $00				; Diggin' (Raise Shovel)
	db $03				; Puntin' (Foot)
	db $00				;\ Chargin'
	db $00				;/
	db $06				; Wait to throw baseball (hand)
	db $F8				;\ Jumpin' to throw baseballs (hand)
	db $F8				;|
	db $00				;/
	db $00				;\ Throwin' baseballs (hand)
	db $F8				;/

; Sprite tilemap: Chuck Body(All)
BodyTiles1:
	db $0D				; Sittin' left/right (hand)
	db $34				; Unused
	db $35				; Unused
	db $26				; Sittin' towards screen
	db $2D				; Crouchin'
	db $28				; Sittin' slightly left/right
	db $40				; Whistlin'/Jumpin'
	db $42				; Clappin'
	db $5D				; Unused
	db $2D				; Crouchin'
	db $64				;\ Hurt
	db $64				;|
	db $64				;|
	db $64				;/
	db $E7				; Diggin' (Put Shovel in Ground)
	db $28				; Diggin' (Hold Shovel Level)
	db $82				; Diggin' (Raise Shovel)
	db $CB				; Puntin' (Foot)
	db $23				;\ Chargin'
	db $20				;/
	db $0D				; Wait to throw baseball (hand)
	db $0C				;\ Jumpin' to throw baseballs (hand)
	db $5D				;|
	db $BD				;/
	db $BD				;\ Throwin' baseballs (hand)
	db $5D				;/

BodyTiles2:
	db $4E				; Sittin' left/right (body)
	db $0C				; Unused
	db $22				; Unused
	db $26				; Sittin' towards screen
	db $2D				; Crouchin'
	db $29				; Sittin' slightly left/right
	db $40				; Whistlin'/Jumpin'
	db $42				; Clappin'
	db $AE				; Unused
	db $2D				; Crouchin'
	db $64				;\ Hurt
	db $64				;|
	db $64				;|
	db $64				;/
	db $E8				; Diggin' (Put Shovel in Ground)
	db $29				; Diggin' (Hold Shovel Level)
	db $83				; Diggin' (Raise Shovel)
	db $CC				; Puntin' (body)
	db $24				;\ Chargin'
	db $21				;/
	db $4E				; Wait to throw baseball (body)
	db $A0				;\ Jumpin' to throw baseballs (body)
	db $A0				;|
	db $A2				;/
	db $A4				;\ Throwin' baseballs (body)
	db $AE				;/

BodyProp1:
	db $00				; Sittin' left/right (hand)
	db $00				; Unused
	db $00				; Unused
	db $00				; Sittin' towards screen
	db $00				; Crouchin'
	db $00				; Sittin' slightly left/right
	db $00				; Whistlin'/Jumpin'
	db $00				; Clappin'
	db $00				; Unused
	db $00				; Crouchin'
	db $00				;\ Hurt
	db $00				;|
	db $00				;|
	db $00				;/
	db $00				; Diggin' (Put Shovel in Ground)
	db $00				; Diggin' (Hold Shovel Level)
	db $00				; Diggin' (Raise Shovel)
	db $00				; Puntin' (Foot)
	db $00				;\ Chargin'
	db $00				;/
	db $00				; Wait to throw baseball (hand)
	db $40				;\ Jumpin' to throw baseballs (hand)
	db $00				;|
	db $00				;/
	db $00				;\ Throwin' baseballs (hand)
	db $00				;/

BodyProp2:
	db $00				; Sittin' left/right (body)
	db $00				; Unused
	db $00				; Unused
	db $40				; Sittin' towards screen
	db $40				; Crouchin'
	db $00				; Sittin' slightly left/right
	db $40				; Whistlin'/Jumpin'
	db $40				; Clappin'
	db $00				; Unused
	db $40				; Crouchin'
	db $40				;\ Hurt
	db $40				;|
	db $40				;|
	db $40				;/
	db $00				; Diggin' (Put Shovel in Ground)
	db $00				; Diggin' (Hold Shovel Level)
	db $00				; Diggin' (Raise Shovel)
	db $00				; Puntin' (body)
	db $00				;\ Chargin'
	db $00				;/
	db $00				; Wait to throw baseball (body)
	db $00				;\ Jumpin' to throw baseballs (body)
	db $00				;|
	db $00				;/
	db $00				;\ Throwin' baseballs (body)
	db $00				;/

BodyTileSize1:
	db $00				; Sittin' left/right (hand)
	db $00				; Unused
	db $00				; Unused
	db $02				; Sittin' towards screen
	db $02				; Crouchin'
	db $02				; Sittin' slightly left/right
	db $02				; Whistlin'/Jumpin'
	db $02				; Clappin'
	db $00				; Unused
	db $02				; Crouchin'
	db $02				;\ Hurt
	db $02				;|
	db $02				;|
	db $02				;/
	db $02				; Diggin' (Put Shovel in Ground)
	db $02				; Diggin' (Hold Shovel Level)
	db $02				; Diggin' (Raise Shovel)
	db $00				; Puntin' (Foot)
	db $02				;\ Chargin'
	db $02				;/
	db $00				; Wait to throw baseball (hand)
	db $00				;\ Jumpin' to throw baseballs (hand)
	db $00				;|
	db $00				;/
	db $00				;\ Throwin' baseballs (hand)
	db $00				;/

BodyOAMIndexOffset:
	db $00				; Sittin' left/right
	db $00				; Unused
	db $00				; Unused
	db $04				; Sittin' towards screen
	db $04				; Crouchin'
	db $04				; Sittin' slightly left/right
	db $0C				; Whistlin'/Jumpin'
	db $0C				; Clappin'
	db $00				; Unused
	db $08				; Crouchin'
	db $00				;\ Hurt
	db $00				;|
	db $04				;|
	db $04				;/
	db $04				; Diggin' (Put Shovel in Ground)
	db $04				; Diggin' (Hold Shovel Level)
	db $04				; Diggin' (Raise Shovel)
	db $00				; Puntin'
	db $08				;\ Chargin'
	db $08				;/
	db $00				; Wait to throw baseball
	db $00				;\ Jumpin' to throw baseballs
	db $00				;|
	db $00				;/
	db $00				;\ Throwin' baseballs
	db $00				;/

DrawBody:
	STZ.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	BNE.b CODE_02CA36
	CLC
	ADC.b #$1A
	LDX.b #$40
	STX.b !RAM_SMW_Misc_ScratchRAM06
CODE_02CA36:
	TAX
	LDY.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w BodyOAMIndexOffset,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM05
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l BodyXDisp1,x
else
	ADC.w BodyXDisp1,x
endif
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l BodyXDisp2,x
else
	ADC.w BodyXDisp2,x
endif
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l BodyYDisp1,x
else
	ADC.w BodyYDisp1,x
endif
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$41].YDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l BodyTiles1,x
else
	LDA.w BodyTiles1,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l BodyTiles2,x
else
	LDA.w BodyTiles2,x
endif
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	ORA.b !RAM_SMW_Misc_ScratchRAM06
	PHA
if ver_is_japanese(!Define_Global_ROMToAssemble)
	EOR.l BodyProp1,x
else
	EOR.w BodyProp1,x
endif
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
if ver_is_japanese(!Define_Global_ROMToAssemble)
	EOR.l BodyProp2,x
else
	EOR.w BodyProp2,x
endif
	STA.w SMW_OAMBuffer[$41].Prop,y
	TYA
	LSR
	LSR
	TAY
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l BodyTileSize1,x
else
	LDA.w BodyTileSize1,x
endif
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

JumpinChuckLeftHandXDisp:
	db $FA			; Hand
	db $00			; Clappin Arms

JumpinChuckRightHandXDisp:
	db $0E			; Hand
	db $00			; Clappin Arms

; Clappin' Chuck's hand tiles (raised, clapping)
JumpinChuckHandTiles:
	db $0C			; Hand
	db $44			; Clappin Arms

JumpinChuckHandsYDisp:
	db $F8			; Hand
	db $F0			; Clappin Arms

JumpinChuckHandTileSize:
	db $00			; Hand
	db $02			; Clappin Arms

DrawExtraTiles:
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CMP.b #$14
	BCC.b NotPitchinChuckPose
	JMP.w DrawHeldBaseball

NotPitchinChuckPose:
	CMP.b #$12
	BEQ.b DrawCharginShoulder
	CMP.b #$13
	BEQ.b DrawCharginShoulder
	SEC
	SBC.b #$06
	CMP.b #$02
	BCS.b Return02CAF9
	TAX
	LDY.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l JumpinChuckLeftHandXDisp,x
else
	ADC.w JumpinChuckLeftHandXDisp,x
endif
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l JumpinChuckRightHandXDisp,x
else
	ADC.w JumpinChuckRightHandXDisp,x
endif
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l JumpinChuckHandsYDisp,x
else
	ADC.w JumpinChuckHandsYDisp,x
endif
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l JumpinChuckHandTiles,x
else
	LDA.w JumpinChuckHandTiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	STA.w SMW_OAMBuffer[$40].Prop,y
	ORA.b #$40
	STA.w SMW_OAMBuffer[$41].Prop,y
	TYA
	LSR
	LSR
	TAY
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l JumpinChuckHandTileSize,x
else
	LDA.w JumpinChuckHandTileSize,x
endif
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
Return02CAF9:
	RTS

; [47 07] Change to 40 00 to be able to change the palette of Chargin'
; Chucks arm with Tweaker/etc. (USE WITH $02CB2E)
CharginShoulderProp:
	db $47,$07						; Note: Should be $4B,$0B. Likely a leftover of when chargin' chucks were blue instead of green.

DrawCharginShoulder:
	LDY.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	PHX
	TAX
	ASL
	ASL
	ASL
	PHA
	EOR.b #$08
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$41].XDisp,y
	LDA.b #$1C
	STA.w SMW_OAMBuffer[$40].Tile,y
	INC
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	LDA.w CharginShoulderProp,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	TYA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$40].Slot,x
	STZ.w SMW_OAMTileSizeBuffer[$41].Slot,x
	PLX
	RTS

BaseballXDisp:
	db $FA,$0A,$06,$00,$00,$01
	db $0E,$FE,$02,$00,$00,$09

BaseballYDisp:
	db $08,$F4,$F4,$00,$00,$F4

DrawHeldBaseball:
	PHX
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	BNE.b CODE_02CB5E
	CLC
	ADC.b #$06
CODE_02CB5E:
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	CLC
	ADC.b #$08
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w BaseballXDisp-$14,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w BaseballYDisp-$14,x
	BEQ.b CODE_02CB8E
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b #$AD
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$09
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAX
	STZ.w SMW_OAMTileSizeBuffer[$40].Slot,x
CODE_02CB8E:
	PLX
	RTS

DigginChuckXDisp:
	db $FC,$04		; Shoulder
	db $10,$F0		; Level Shovel
	db $12,$EE		; Raised Shovel

DigginChuckProp:
	db $47,$07

DigginChuckYDisp:
	db $F8			; Shoulder
	db $00			; Level Shovel
	db $F8			; Raised Shovel

; Diggin' Chuck's Shoulder and Shovel Tiles
DigginChuckTiles:
	db $CA			; Shoulder
	db $E2			; Level Shovel
	db $A0			; Raised Shovel

DigginChuckTileSize:
	db $00			; Shoulder
	db $02			; Level Shovel
	db $02			; Raised Shovel

DrawDigginChuckExtraTiles:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr046_DigginChuck
	BNE.b Return02CBFB
	LDA.w !RAM_SMW_NorSprXXX_Chucks_BodyAnimationFrame,x
	CMP.b #$05
	BNE.b CODE_02CBB2
	LDA.b #$01
	BRA.b CODE_02CBB9

CODE_02CBB2:
	CMP.b #$0E
	BCC.b Return02CBFB
	SEC
	SBC.b #$0E
CODE_02CBB9:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$0C
	TAY
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	ASL
	ORA.w !RAM_SMW_NorSpr_FacingDirection,x
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DigginChuckXDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	TXA
	AND.b #$01
	TAX
	LDA.w DigginChuckProp,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w DigginChuckYDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w DigginChuckTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDA.w DigginChuckTileSize,x
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLX
Return02CBFB:
	RTS

Return02CBFC:						;\ Optimization: Unused RTS
	RTS 						;/
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr099_VolcanoLotus_Status08(Address)
namespace SMW_NorSpr099_VolcanoLotus_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02DFC8
	STZ.w !RAM_SMW_NorSpr099_VolcanoLotus_FlashingPaletteFlag,x
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$40
	BPL.b CODE_02DFAF
	INC.b !RAM_SMW_NorSpr_YSpeed,x
CODE_02DFAF:
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02DFBC
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
CODE_02DFBC:
	LDA.b !RAM_SMW_NorSpr099_VolcanoLotus_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

VolcanoLotusPtrs:
	dw State00_Waiting
	dw State01_Flashing
	dw State02_Shooting

Return02DFC8:
	RTS

State00_Waiting:
	LDA.w !RAM_SMW_NorSpr099_VolcanoLotus_PhaseTimer,x
	BNE.b CODE_02DFD6
	LDA.b #$40
CODE_02DFD0:
	STA.w !RAM_SMW_NorSpr099_VolcanoLotus_PhaseTimer,x
	INC.b !RAM_SMW_NorSpr099_VolcanoLotus_CurrentState,x
	RTS

CODE_02DFD6:
	LSR
	LSR
	LSR
	AND.b #$01
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

State01_Flashing:
	LDA.w !RAM_SMW_NorSpr099_VolcanoLotus_PhaseTimer,x
	BNE.b CODE_02DFE8
	LDA.b #$40
	BRA.b CODE_02DFD0

CODE_02DFE8:
	LSR
	AND.b #$01
	STA.w !RAM_SMW_NorSpr099_VolcanoLotus_FlashingPaletteFlag,x
	RTS

State02_Shooting:
	LDA.w !RAM_SMW_NorSpr099_VolcanoLotus_PhaseTimer,x
	BNE.b CODE_02DFFB
	LDA.b #$80
	JSR.w CODE_02DFD0
	STZ.b !RAM_SMW_NorSpr099_VolcanoLotus_CurrentState,x
CODE_02DFFB:
	CMP.b #$38
	BNE.b CODE_02E002
	JSR.w CODE_02E079
CODE_02E002:
	LDA.b #$02
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

; Volcano Lotus: Top Tiles
Tiles:
	db $8E,$9E,$E2

GFXRt:
	JSR.w SMW_NorSpr08F_ScalePlatform_Status08_GFXRt
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.b #$CE
	STA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$41].Tile,y
	LDA.w SMW_OAMBuffer[$40].Prop,y
	AND.b #$30
	ORA.b #$0B
	STA.w SMW_OAMBuffer[$40].Prop,y
	ORA.b #$40
	STA.w SMW_OAMBuffer[$41].Prop,y
	LDA.w SMW_OAMBuffer[$40].XDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$42].XDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$43].XDisp,y
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$42].YDisp,y
	STA.w SMW_OAMBuffer[$43].YDisp,y
	PHX
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	TAX
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$42].Tile,y
	INC
	STA.w SMW_OAMBuffer[$43].Tile,y
	PLX
	LDA.w !RAM_SMW_NorSpr099_VolcanoLotus_FlashingPaletteFlag,x
	CMP.b #$01
	LDA.b #$39
	BCC.b CODE_02E05B
	LDA.b #$35
CODE_02E05B:
	STA.w SMW_OAMBuffer[$42].Prop,y
	STA.w SMW_OAMBuffer[$43].Prop,y
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$08
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	LDY.b #$00
	LDA.b #$01
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

FireInitialXSpeed:
	db $10,$F0,$06,$FA

FireInitialYSpeed:
	db $EC,$EC,$E8,$E8

CODE_02E079:
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b Return02E0C4
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_02E085:
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_02E087:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_02E090
	DEY
	BPL.b CODE_02E087
	RTS				; / Return if no free slots

CODE_02E090:
	LDA.b #!Define_SMW_SpriteID_ExtSpr0C_VolcanoLotusFire	; \ Extended sprite = Volcano Lotus fire
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w FireInitialXSpeed,x
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
	LDA.w FireInitialYSpeed,x
	STA.w !RAM_SMW_ExtSpr_YSpeed,y
	PLX
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_02E085
Return02E0C4:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr09A_SumoBro_Status08(Address)
namespace SMW_NorSpr09A_SumoBro_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	JSR.w GFXRt
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02DCE9
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b Return02DCE9
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSL.l SMW_HandleNormalSpriteGravity_Main
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x	; \ Branch if not on ground
	AND.b #$04
	BEQ.b CODE_02DCDB
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
CODE_02DCDB:
	LDA.b !RAM_SMW_NorSpr09A_SumoBro_CurrentState,x
	JSL.l SMW_ExecutePtr_Absolute

SumoBroPtrs:
	dw State00_WaitingToStep
	dw State01_AboutToStep
	dw State02_Stepping
	dw State03_Stomping

Return02DCE9:
	RTS

State00_WaitingToStep:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.w !RAM_SMW_NorSpr09A_SumoBro_PhaseTimer,x
	BNE.b Return02DCFE
	STZ.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b #$03
CODE_02DCF9:
	STA.w !RAM_SMW_NorSpr09A_SumoBro_PhaseTimer,x
	INC.b !RAM_SMW_NorSpr09A_SumoBro_CurrentState,x
Return02DCFE:
	RTS

State01_AboutToStep:
	LDA.w !RAM_SMW_NorSpr09A_SumoBro_PhaseTimer,x
	BNE.b Return02DD0B
	INC.w !RAM_SMW_NorSpr_AnimationFrame,x
	LDA.b #$03
	BRA.b CODE_02DCF9

Return02DD0B:
	RTS

XSpeed:
	db $20,$E0

State02_Stepping:
	LDA.w !RAM_SMW_NorSpr09A_SumoBro_WaitBeforeNextStep,x
	BNE.b CODE_02DD45
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w XSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.w !RAM_SMW_NorSpr09A_SumoBro_PhaseTimer,x
	BNE.b Return02DD44
	INC.w !RAM_SMW_NorSpr09A_SumoBro_StepsTaken,x
	LDA.w !RAM_SMW_NorSpr09A_SumoBro_StepsTaken,x
	AND.b #$01
	BNE.b CODE_02DD2F
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr09A_SumoBro_WaitBeforeNextStep,x
CODE_02DD2F:
	LDA.w !RAM_SMW_NorSpr09A_SumoBro_StepsTaken,x
	CMP.b #$03
	BNE.b CODE_02DD3D
	STZ.w !RAM_SMW_NorSpr09A_SumoBro_StepsTaken,x
	LDA.b #$70
	BRA.b CODE_02DCF9

CODE_02DD3D:
	LDA.b #$03
CODE_02DD3F:
	JSR.w CODE_02DCF9
	STZ.b !RAM_SMW_NorSpr09A_SumoBro_CurrentState,x
Return02DD44:
	RTS

CODE_02DD45:
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

State03_Stomping:
	LDA.b #$03
	LDY.w !RAM_SMW_NorSpr09A_SumoBro_PhaseTimer,x
	BEQ.b CODE_02DD81
	CPY.b #$2E
	BNE.b CODE_02DD6F
	PHA
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	BNE.b CODE_02DD6E
	LDA.b #$30			; \ Set ground shake timer
	STA.w !RAM_SMW_Timer_ShakeLayer1
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	PHY
	JSR.w GenSumoLightning
	PLY
CODE_02DD6E:
	PLA
CODE_02DD6F:
	CPY.b #$30
	BCC.b CODE_02DD7D
	CPY.b #$50
	BCS.b CODE_02DD7D
	INC
	CPY.b #$44
	BCS.b CODE_02DD7D
	INC
CODE_02DD7D:
	STA.w !RAM_SMW_NorSpr_AnimationFrame,x
	RTS

CODE_02DD81:
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.b #$40
	JSR.w CODE_02DD3F
	RTS

GenSumoLightning:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return02DDC5
	LDA.b #!Define_SMW_SpriteID_NorSpr02B_SumoLightning	; \ Sprite = Lightning
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Lightning X position = Sprite X position + #$04
	ADC.b #$04
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ Lightning Y position = Sprite Y position
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX				; \ Reset sprite tables
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b #$10			; \ $1FE2,x = #$10
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1FE2,x	; / Time to not interact with ground??
	PLX
Return02DDC5:
	RTS

XDisp:
	db $FF,$07,$FC,$04,$FF,$07,$FC,$04
	db $FF,$FF,$FC,$04,$FF,$FF,$FC,$04
	db $02,$02,$F4,$04,$02,$02,$F4,$04
	db $09,$01,$04,$FC,$09,$01,$04,$FC
	db $01,$01,$04,$FC,$01,$01,$04,$FC
	db $FF,$FF,$0C,$FC,$FF,$FF,$0C,$FC

YDisp:
	db $F8,$F8,$00,$00,$F8,$F8,$00,$00
	db $F8,$F0,$00,$00,$F8,$F8,$00,$00
	db $F8,$F8,$01,$00,$F8,$F8,$FF,$00

; Sumo Bros Tilemap (Head, Body Arms Up, Head, Body Arms Down)
Tiles:
	db $98,$99,$A7,$A8,$98,$99,$AA,$AB
	db $8A,$66,$AA,$AB,$EE,$EE,$C5,$C6
	; Sumo Bros Tilemap (Head, Head, Body Lift Leg, Head Head, Body Lift Leg)
	db $80,$80,$C1,$C3,$80,$80,$C1,$C3

TileSize:
	db $00,$00,$02,$02,$00,$00,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	LSR
	ROR
	ROR
	AND.b #$40
	EOR.b #$40
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	LDA.w !RAM_SMW_NorSpr_AnimationFrame,x
	ASL
	ASL
	PHX
	TAX
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM05
CODE_02DE5B:
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	BEQ.b CODE_02DE65
	TXA
	CLC
	ADC.b #$18
	TAX
CODE_02DE65:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	CMP.b #$66
	SEC
	BNE.b CODE_02DE84
	CLC
CODE_02DE84:
	LDA.b #$34
	ADC.b !RAM_SMW_Misc_ScratchRAM02
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
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM05
	BPL.b CODE_02DE5B
	PLX
	LDY.b #$FF
	LDA.b #$03
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr09B_HammerBro_Status08(Address)
namespace SMW_NorSpr09B_HammerBro_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
.Return:
	RTL

Sub:
	STZ.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	; [C9 02 D0 0A] (CMP #$02 BNE $0A) Change to [C9 08 B0 0A] (CMP #$08 BCS
	; $0A) to fix the bug where hammer brothers will throw hammers if tossed
	; into lava.
	CMP.b #!Define_SMW_NorSprStatus02_Dead
	BNE.b CODE_02DA6E
	JMP.w GFXRt

; How often Amazing Flyin' Hammer Brother throws hammers on each submap.
HammerFreq:
	db $1F,$0F,$0F,$0F,$0F,$0F,$0F

CODE_02DA6E:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02DAE8
	JSL.l SMW_CheckForPlayerAndNormalSpriteCollisions_Main
	JSR.w SMW_SubOffscreen_Bank02_Entry2
	LDY.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,y
	TAY
	LDA.b !RAM_SMW_Counter_GlobalFrames	; \ Increment $1570,x 3 out of every 4 frames
	AND.b #$03
	BEQ.b CODE_02DA89
	INC.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
CODE_02DA89:
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x
	ASL
	CPY.b #!Define_SMW_Submap_MoreAgressiveHammerBro
	BEQ.b CODE_02DA92
	ASL
CODE_02DA92:
	AND.b #$40
	; Set to EA EA EA to make Amazing Flyin' Hammer Brothers stop turning
	; around.
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	LDA.w !RAM_SMW_NorSpr_AnimationFrameCounter,x	; \ Don't throw if...
	AND.w HammerFreq,y		; | ...not yet time
	ORA.w !RAM_SMW_NorSpr_XOffscreenFlag,x	; | ...sprite offscreen
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,x
	ORA.w !RAM_SMW_NorSpr09B_HammerBro_WaitBeforeThowingNextHammer,x	; | ...we just threw one
	BNE.b Return02DAE8
	LDA.b #$03			; \ Set minimum time in between throws
	STA.w !RAM_SMW_NorSpr09B_HammerBro_WaitBeforeThowingNextHammer,x
	LDY.b #$10			; \ $00 = Hammer X speed,
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x	; | based on sprite's direction
	BNE.b CODE_02DAB6
	LDY.b #$F0
CODE_02DAB6:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slots
CODE_02DABA:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b GenerateHammer
	DEY
	BPL.b CODE_02DABA
	RTS				; / Return if no free slots

GenerateHammer:
	LDA.b #!Define_SMW_SpriteID_ExtSpr04_Hammer	; \ Extended sprite = Hammer
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Hammer X pos = sprite X pos
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ Hammer Y pos = sprite Y pos
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDA.b #$D0			; \ Hammer Y speed = #$D0
	STA.w !RAM_SMW_ExtSpr_YSpeed,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; \ Hammer X speed = $00
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
Return02DAE8:
	RTS

XDisp:
	db $08,$10,$00,$10

YDisp:
	db $F8,$F8,$00,$00

; Sprite tilemap: Amazing Flyin' Hammer Brother
Tiles:
	db $5A,$4A,$46,$48
	db $4A,$5A,$48,$46

TileSize:
	db $00,$00,$02,$02

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PHX
	LDX.b #$03
CODE_02DB08:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	PHA
	ORA.b #$37
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLA
	BEQ.b CODE_02DB2A
	INX
	INX
	INX
	INX
CODE_02DB2A:
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
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
	BPL.b CODE_02DB08
HammerBroPlatformEntry:
	PLX
	LDY.b #$FF
	LDA.b #$03
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr09C_HammerBroPlatform_Status08(Address)
namespace SMW_NorSpr09C_HammerBroPlatform_Status08
%InsertMacroAtXPosition(<Address>)

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

XAcceleration:
	db $01,$FF

MaxXSpeed:
	db $20,$E0

YAcceleration:
	db $02,$FE

MaxYSpeed:
	db $20,$E0

Sub:
	JSR.w GFXRt			; Draw sprite
	LDA.b #$FF										;\ Glitch: Because the platform is constantly checking for a hammer bro to board it, you can't have more than 2 hammer bro platforms on screen if a hammer bro is also present.
	STA.w !RAM_SMW_NorSpr09C_HammerBroPlatform_HammerBroOnPlatformSpriteSlot,x		;/ The fix to this would require the hammer bro to have a flag indicating which platform it belongs to.
	LDY.b #!Define_SMW_MaxNormalSpriteSlot-$02	; \ Check sprite slots 0-9 for Hammer Brother
CODE_02DB66:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b CODE_02DB74
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr09B_HammerBro
	BEQ.b PutHammerBroOnPlat
CODE_02DB74:
	DEY
	BPL.b CODE_02DB66
	BRA.b CODE_02DB9E		; / Branch if no Hammer Brother

PutHammerBroOnPlat:
	TYA				; \ $1594 = index of Hammer Bro
	STA.w !RAM_SMW_NorSpr09C_HammerBroPlatform_HammerBroOnPlatformSpriteSlot,x
	LDA.b !RAM_SMW_NorSpr_XPosLo_x	; \ Hammer Bro X postion = Platform X position
	STA.w !RAM_SMW_NorSpr_XPosLo,y
if defined("Define_SMW_SA1")
	; SA-1 Pack: The hammer brother graphics routine is called by the hammer
	; brother's platform. The OAM index for the hammer brother might not be
	; set correctly so hijack here to set it.
	JSL.l hammer_bro_fix
	NOP
	NOP
else
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
endif
	LDA.b !RAM_SMW_NorSpr_YPosLo_x	; \ Hammer Bro Y position = Platform Y position - #$10
	SEC
	SBC.b #$10
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	SBC.b #$00
if defined("Define_SMW_SA1")
	; SA-1 Pack: Flying hammer brother.
	JML.l HAMMER_BRO_SET
else
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX				; \ Draw Hammer Bro
endif
	TYX
	JSR.w SMW_NorSpr09B_HammerBro_Status08_GFXRt
	PLX
CODE_02DB9E:
if defined("Define_SMW_SA1")
	JML.l HAMMER_BRO_RESTORE
else
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02DC0E
endif
	JSR.w SMW_SubOffscreen_Bank02_Entry2
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_02DBD7
	LDA.w !RAM_SMW_NorSpr09C_HammerBroPlatform_HorizontalDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_XSpeed,x
	CLC
	ADC.w XAcceleration,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	CMP.w MaxXSpeed,y
	BNE.b CODE_02DBC1
	INC.w !RAM_SMW_NorSpr09C_HammerBroPlatform_HorizontalDirection,x
CODE_02DBC1:
	LDA.w !RAM_SMW_NorSpr09C_HammerBroPlatform_VerticalDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w YAcceleration,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w MaxYSpeed,y
	BNE.b CODE_02DBD7
	INC.w !RAM_SMW_NorSpr09C_HammerBroPlatform_VerticalDirection,x
; Set to EA EA EA to disable Amazing Flyin' Hammer Brothers platform
; vertical movement
CODE_02DBD7:
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	; Set to EA EA EA to disable Amazing Flyin' Hammer Brothers platform
	; horizontal movement
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	JSL.l SMW_SolidSpriteBlock_Main
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	BEQ.b Return02DC0E
	LDA.b #$01
	STA.b !RAM_SMW_NorSpr09C_HammerBroPlatform_HitFlag,x
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	CMP.b #$08
	BMI.b CODE_02DBF8
	INC.b !RAM_SMW_NorSpr09C_HammerBroPlatform_HitFlag,x
CODE_02DBF8:
	LDY.w !RAM_SMW_NorSpr09C_HammerBroPlatform_HammerBroOnPlatformSpriteSlot,x
	BMI.b Return02DC0E
	LDA.b #!Define_SMW_NorSprStatus02_Dead	; \ Sprite status = Killed
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #$C0
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	PHX
	TYX
	JSL.l SMW_SpawnContactEffectFromSide_Main
	PLX
Return02DC0E:
	RTS

XDisp:
	db $00,$10,$F2,$1E
	db $00,$10,$FA,$1E

YDisp:
	db $00,$00,$F6,$F6
	db $00,$00,$FE,$FE

; Sprite tilemap: Amazing Flyin' Hammer Brother Platform
Tiles:
	db $40,$40,$C6,$C6
	db $40,$40,$5D,$5D

; Palette/GFX Page of Amazing Flyin' Hammer Brother Platform
Prop:
	db $32,$32,$72,$32
	db $32,$32,$72,$32

TileSize:
	db $02,$02,$02,$02
	db $02,$02,$00,$00

BounceYDisp:
	db $00,$04,$06,$08
	db $08,$06,$04,$00

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_NorSpr09C_HammerBroPlatform_HitFlag,x
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	LSR
	TAY
	LDA.w BounceYDisp,y
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	PHX
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	AND.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b #$03
CODE_02DC5D:
	STX.b !RAM_SMW_Misc_ScratchRAM06
	TXA
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM06
	CPX.b #$02
	BCS.b CODE_02DC8A
	INX
	CPX.b !RAM_SMW_Misc_ScratchRAM07
	BNE.b CODE_02DC8A
	LDA.w SMW_OAMBuffer[$40].YDisp,y			;\ Glitch: This code will only execute once, because the Hit flag will never reset back to 00.
	SEC						;|
	SBC.b !RAM_SMW_Misc_ScratchRAM05		;|
	STA.w SMW_OAMBuffer[$40].YDisp,y			;/
CODE_02DC8A:
	PLX
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
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
	LDX.b !RAM_SMW_Misc_ScratchRAM06
	DEX
	BPL.b CODE_02DC5D
	JMP.w SMW_NorSpr09B_HammerBro_Status08_HammerBroPlatformEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr09D_BubbleWithSprite_Status08(Address)
namespace SMW_NorSpr09D_BubbleWithSprite_Status08
%InsertMacroAtXPosition(<Address>)

; Bubble Sprites Tile Table (2 animation frames with 2 bytes in them. Order:
; Goomba, Bob-Omb, Cheep-Cheep, Mushroom)
BubbleSprTiles1:
	db $A8,$CA,$67,$24

BubbleSprTiles2:
	db $AA,$CC,$69,$24

; Palette/GFX Page Table of Sprites in bubbles (Order: Goomba, Bob-Omb,
; Cheep-Cheep, Mushroom)
BubbleSprGfxProp1:
	db $84,$85,$05,$08

Bank02:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

BubbleSprGfxProp2:
	db $08,$F8

BubbleSprGfxProp3:
	db $01,$FF

BubbleSprGfxProp4:
	db $0C,$F4

Sub:
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$14
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	PHX
	LDA.b !RAM_SMW_NorSpr09D_BubbleWithSprite_Contents,x
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	TAX
	LDA.w BubbleSprGfxProp1,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	ASL
	ASL
	ASL
	LDA.w BubbleSprTiles1,x
	BCC.b CODE_02D8E4
	LDA.w BubbleSprTiles2,x
CODE_02D8E4:
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDA.w !RAM_SMW_NorSpr09D_BubbleWithSprite_TimerUntilPopping,x
	CMP.b #$60
	BCS.b CODE_02D8F3
	AND.b #$02
	BEQ.b CODE_02D8F6
CODE_02D8F3:
	JSR.w GFXRt
CODE_02D8F6:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus02_Dead
	BNE.b CODE_02D904
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	BRA.b CODE_02D96B

CODE_02D904:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02D977
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_02D91D
	DEC.w !RAM_SMW_NorSpr09D_BubbleWithSprite_TimerUntilPopping,x
	LDA.w !RAM_SMW_NorSpr09D_BubbleWithSprite_TimerUntilPopping,x
	CMP.b #$04
	BNE.b CODE_02D91D
	LDA.b #!Define_SMW_Sound1DFC_Clap	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_02D91D:
	LDA.w !RAM_SMW_NorSpr09D_BubbleWithSprite_TimerUntilPopping,x
	DEC
	BEQ.b CODE_02D978
	CMP.b #$07
	BCC.b Return02D977
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSR.w SMW_UpdateNormalSpritePositionBank02_Y
	JSL.l SMW_HandleNormalSpriteLevelCollision_Main
	LDY.w !RAM_SMW_NorSpr09D_BubbleWithSprite_HorizontalDirection,x
	LDA.w BubbleSprGfxProp2,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_02D958
	LDA.w !RAM_SMW_NorSpr09D_BubbleWithSprite_VerticalDirection,x
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CLC
	ADC.w BubbleSprGfxProp3,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.w BubbleSprGfxProp4,y
	BNE.b CODE_02D958
	INC.w !RAM_SMW_NorSpr09D_BubbleWithSprite_VerticalDirection,x
CODE_02D958:
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	BNE.b CODE_02D96B
	JSL.l SMW_CheckForNormalSpriteToNormalSpriteCollision_Main
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	BCC.b Return02D9A0
	STZ.b !RAM_SMW_Player_YSpeed
	STZ.b !RAM_SMW_Player_XSpeed
CODE_02D96B:
	LDA.w !RAM_SMW_NorSpr09D_BubbleWithSprite_TimerUntilPopping,x
	CMP.b #$07
	BCC.b Return02D977
	LDA.b #$06
	STA.w !RAM_SMW_NorSpr09D_BubbleWithSprite_TimerUntilPopping,x
Return02D977:
	RTS

CODE_02D978:
	LDY.b !RAM_SMW_NorSpr09D_BubbleWithSprite_Contents,x
	LDA.w BubbleSprites,y
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	PHA
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLY
	LDA.b #$20
	CPY.b #$74
	BNE.b CODE_02D98D
	LDA.b #$04
CODE_02D98D:
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr00D_BobOmb
	BNE.b CODE_02D999
	DEC.w !RAM_SMW_NorSpr00D_BobOmb_WaitBeforeExplosion,x
CODE_02D999:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_Bank02_X
	TYA
	STA.w !RAM_SMW_NorSpr_Table7E157C,x
Return02D9A0:
	RTS

; Sprites spawned from Bubbles (Goomba, Bob-omb, Cheep-Cheep, Mushroom)
BubbleSprites:
	db !Define_SMW_SpriteID_NorSpr00F_Goomba
	db !Define_SMW_SpriteID_NorSpr00D_BobOmb
	db !Define_SMW_SpriteID_NorSpr015_HorizontalCheepCheep
	db !Define_SMW_SpriteID_NorSpr074_Mushroom

; X Placement of Bubble Tiles, 3 animation frames, each 5 bytes
XDisp:
	db $F8,$08,$F8,$08,$FF,$F9,$07,$F9
	db $07,$00,$FA,$06,$FA,$06,$00

; Y Placement of Bubble Tiles, 3 animation frames, each 5 bytes
YDisp:
	db $F6,$F6,$02,$02,$FC,$F5,$F5,$03
	db $03,$FC,$F4,$F4,$04,$04,$FB

; Bubble Tile Table
Tiles:
	db $A0,$A0,$A0,$A0,$99

; Palette/GFX Page of Bubble Tiles
Prop:
	db $07,$47,$87,$C7,$03

; Bubble Tile Size Table
TileSize:
	db $02,$02,$02,$02,$00

DATA_02D9D2:
	db $00,$05,$0A,$05

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	AND.b #$03
	TAY
	LDA.w DATA_02D9D2,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	SEC
	SBC.b #$14
	STA.w !RAM_SMW_NorSpr_OAMIndex,x
	TAY
	PHX
	LDA.w !RAM_SMW_NorSpr09D_BubbleWithSprite_TimerUntilPopping,x
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDX.b #$04
CODE_02D9F8:
	PHX
	TXA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w XDisp,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w YDisp,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PLX
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w Prop,x
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CMP.b #$06
	BCS.b CODE_02DA37
	CMP.b #$03
	LDA.b #$02
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b #$64
	BCS.b CODE_02DA34
	LDA.b #$66
CODE_02DA34:
	STA.w SMW_OAMBuffer[$40].Tile,y
CODE_02DA37:
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
	BPL.b CODE_02D9F8
	PLX
	LDY.b #$FF
	LDA.b #$04
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr09F_BanzaiBill_Status08(Address)
namespace SMW_NorSpr09F_BanzaiBill_Status08
%InsertMacroAtXPosition(<Address>)

Sub:
	JSR.w GFXRt
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus02_Dead
	BEQ.b Return02D5A3
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return02D5A3
	JSR.w SMW_SubOffscreen_Bank02_Entry1
	LDA.b #$E8
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	JSR.w SMW_UpdateNormalSpritePositionBank02_X
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
Return02D5A3:
	RTS

; X offsets of Banzai Bill's tiles.
XDisp:
	db $00,$10,$20,$30,$00,$10,$20,$30
	db $00,$10,$20,$30,$00,$10,$20,$30

; Y offsets of Banzai Bill's tiles.
YDisp:
	db $00,$00,$00,$00,$10,$10,$10,$10
	db $20,$20,$20,$20,$30,$30,$30,$30

; TTTTTTTT of Banzai Bill's tiles.
Tiles:
	db $80,$82,$84,$86,$A0,$88,$CE,$EE
	db $C0,$C2,$CE,$EE,$8E,$AE,$84,$86

; YXPPCCCT of Banzai Bill's tiles.
Prop:
	db $33,$33,$33,$33,$33,$33,$33,$33
	db $33,$33,$33,$33,$33,$33,$B3,$B3

GFXRt:
	JSR.w SMW_GetDrawInfo_Bank02
	PHX
	LDX.b #$0F
Loop:
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
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b Loop
	PLX
	LDY.b #$02
	LDA.b #$0F
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

Bank02:
	PHB
	PHK
	PLB
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr09F_BanzaiBill
	BNE.b NotBanzaiBill
	JSR.w Sub
	BRA.b IsBanzaiBill

NotBanzaiBill:
	JSR.w SMW_NorSpr0A3_GreyChainedPlatform_Status08_Sub
IsBanzaiBill:
	PLB
	RTL
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr09F_BanzaiBill_Status08_Main, SMW_NorSpr09E_BallNChain_Status08_Main)
	%SetDuplicateOrNullPointer(SMW_NorSpr09F_BanzaiBill_Status08_Main, SMW_NorSpr0A3_GreyChainedPlatform_Status08_Main)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT02_SMW_NorSpr0A3_GreyChainedPlatform_Status08(Address)
namespace SMW_NorSpr0A3_GreyChainedPlatform_Status08
%InsertMacroAtXPosition(<Address>)

Sub:
	JSR.w SMW_SubOffscreen_Bank02_Entry4
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02D653
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	LDY.b #$02
	AND.b #$10
	BNE.b CODE_02D63B
	LDY.b #$FE
CODE_02D63B:
	TYA
	LDY.b #$00
	CMP.b #$00
	BPL.b CODE_02D643
	DEY
CODE_02D643:
	CLC
	ADC.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleLo,x
	STA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleLo,x
	TYA
	ADC.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleHi,x
	AND.b #$01
	STA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleHi,x
CODE_02D653:
	LDA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
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
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/02D689.asm"
namespace SMW_NorSpr0A3_GreyChainedPlatform_Status08
else
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_ChainLength,x
	LDY.b !RAM_SMW_Misc_ScratchRAM05
	BNE.b CODE_02D6A3
	STA.w !REGISTER_Multiplier	; Multplier B
	JSR.w DoNothing6Times
	ASL.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	ADC.b #$00
CODE_02D6A3:
	LSR.b !RAM_SMW_Misc_ScratchRAM01
	BCC.b CODE_02D6AA
	EOR.b #$FF
	INC
CODE_02D6AA:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_ChainLength,x
	LDY.b !RAM_SMW_Misc_ScratchRAM07
	BNE.b CODE_02D6C6
	STA.w !REGISTER_Multiplier	; Multplier B
	JSR.w DoNothing6Times
	ASL.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	ADC.b #$00
endif
CODE_02D6C6:
	LSR.b !RAM_SMW_Misc_ScratchRAM03
	BCC.b CODE_02D6CD
	EOR.b #$FF
	INC
CODE_02D6CD:
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	PHA
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	PHA
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	PHA
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	PHA
	LDY.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_UnknownClusterSpriteRAM,x					; Note: Seems like a leftover or something. I don't think the value loaded in Y is actually used.
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_02D6E8
	DEC.b !RAM_SMW_Misc_ScratchRAM00
CODE_02D6E8:
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	PHP
	PHA
	SEC
	SBC.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_PreviousXPos,x
	STA.w !RAM_SMW_NorSpr_PlayerXSpeedOffset,x
	PLA
	STA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_PreviousXPos,x
	PLP
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	BPL.b CODE_02D70B
	DEC.b !RAM_SMW_Misc_ScratchRAM01
CODE_02D70B:
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	CMP.b #!Define_SMW_SpriteID_NorSpr09E_BallNChain
	BEQ.b CODE_02D750
	JSL.l SMW_SolidSpriteBlock_Main
	BCC.b CODE_02D73D
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_PlayerOnPlatformFlag,x
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b CODE_02D74B
	PHX
	JSL.l SMW_PlayerGFXRt_Main
	PLX
	LDA.b #$FF
	STA.b !RAM_SMW_Player_HidePlayerTileFlags
	BRA.b CODE_02D74B

CODE_02D73D:
	LDA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_PlayerOnPlatformFlag,x
	BEQ.b CODE_02D74B
	STZ.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_PlayerOnPlatformFlag,x
	PHX
	JSL.l SMW_PlayerGFXRt_Main
	PLX
CODE_02D74B:
	JSR.w CODE_02D848
	BRA.b CODE_02D757

CODE_02D750:
	JSL.l SMW_CheckForPlayerToNormalSpriteCollision_Main
	JSR.w CODE_02D813
CODE_02D757:
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	PLA
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	PLA
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	SEC
	SBC.b !RAM_SMW_NorSpr_XPosLo_x
	JSR.w CODE_02D870
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	SEC
	SBC.b !RAM_SMW_NorSpr_YPosLo_x
	JSR.w CODE_02D870
	CLC
	ADC.b !RAM_SMW_NorSpr_YPosLo_x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr_Table7E15C4,x
	BNE.b Return02D806
	LDA.w !RAM_SMW_NorSpr_OAMIndex,x
	CLC
	ADC.b #$10
	TAY
	PHX
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	TAX
	LDA.b #$E8
	CPX.b #!Define_SMW_SpriteID_NorSpr09E_BallNChain
	BEQ.b CODE_02D7AB
	LDA.b #$A2
CODE_02D7AB:
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDX.b #$01
CODE_02D7AF:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$33
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0A
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	ROR.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0A
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0B
	STA.b !RAM_SMW_Misc_ScratchRAM01
	ASL
	ROR.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0B
	STA.b !RAM_SMW_Misc_ScratchRAM01
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_02D7AF
	PLX
	LDY.b #$02
	LDA.b #$05
	JMP.w SMW_NorSpr070_Pokey_Status08_Bank02SpriteEntry

; Tilemap: Ball 'n' Chain's Spiked Ball (Changing this will freeze the
; game!) It's actually a routine which is used to waste time (6 NOPs + RTS)
; for the math registers, but Nintendo uses it for the tilemap, too. A
; typical example of executable tables.
DoNothing6Times:
BallNChainTiles:
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
Return02D806:
	RTS

; X Offsets of Ball n' Chain's Ball tiles. Format: - Top Left ($F8) - Top
; Right ($08) - Bottom Left ($F8) - Bottom Right ($08)
DATA_02D807:
	db $F8,$08,$F8,$08

; Y Offsets of Ball n' Chain's Ball tiles. Format: - Top Left ($F8) - Top
; Right ($F8) - Bottom Left ($08) - Bottom Right ($08)
DATA_02D80B:
	db $F8,$F8,$08,$08

; Ball n' Chain's Ball YXPPCCCT Properties. Format: - Top Left ($33) - Top
; Right ($73) - Bottom Left ($B3) - Bottom Right ($F3)
DATA_02D80F:
	db $33,$73,$B3,$F3

CODE_02D813:
	JSR.w SMW_GetDrawInfo_Bank02
	PHX
	LDX.b #$03
CODE_02D819:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_02D807,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.w DATA_02D80B,x
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w BallNChainTiles,x				; Note: The Ball N' Chain will get its own tile table in the optimized version of this sprite.
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.w DATA_02D80F,x
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_02D819
	PLX
	RTS

DATA_02D840:
	db $00,$F0,$00,$10

; Wooden Platform on Chain Tilemap (Sprites A3 and E0)
WoodPlatformTiles:
	db $A2,$60,$61,$62

CODE_02D848:
	JSR.w SMW_GetDrawInfo_Bank02
	PHX
	LDX.b #$03
CODE_02D84E:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w DATA_02D840,x
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w WoodPlatformTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$33
	STA.w SMW_OAMBuffer[$40].Prop,y
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_02D84E
	PLX
	RTS

CODE_02D870:
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/02D870.asm"
namespace SMW_NorSpr0A3_GreyChainedPlatform_Status08
else
	PHP
	BPL.b CODE_02D876
	EOR.b #$FF
	INC
CODE_02D876:
	STA.w !REGISTER_DividendHi	; Dividend (High-Byte)
	STZ.w !REGISTER_DividendLo	; Dividend (Low Byte)
	LDA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_ChainLength,x
	LSR
	STA.w !REGISTER_Divisor		; Divisor B
	JSR.w DoNothing6Times
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w !REGISTER_QuotientHi	; Quotient of Divide Result (High Byte)
	ASL.b !RAM_SMW_Misc_ScratchRAM0E
	ROL
	ASL.b !RAM_SMW_Misc_ScratchRAM0E
	ROL
	ASL.b !RAM_SMW_Misc_ScratchRAM0E
	ROL
	ASL.b !RAM_SMW_Misc_ScratchRAM0E
	ROL
	PLP
	BPL.b Return02D8A0
	EOR.b #$FF
	INC
Return02D8A0:
	RTS
endif
namespace off
	%SetDuplicateOrNullPointer(SMW_NorSpr0A3_GreyChainedPlatform_Status08_Sub, SMW_NorSpr09E_BallNChain_Status08_Sub)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_LoadShooter(Address)
namespace SMW_NorSprXXX_LoadShooter
%InsertMacroAtXPosition(<Address>)

Main:
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_ShooterFix1
	NOP
else
	STX.b !RAM_SMW_Misc_ScratchRAM02
	DEY
	STY.b !RAM_SMW_Misc_ScratchRAM03
endif
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDX.b #!Define_SMW_MaxShooterSpriteSlot
CODE_02AB81:
	LDA.w !RAM_SMW_ShooterSpr_SpriteID,x
	BEQ.b CODE_02AB9E
	DEX
	BPL.b CODE_02AB81
	DEC.w !RAM_SMW_ShooterSpr_SlotToOverwriteWhenSlotsFull
	BPL.b CODE_02AB93
	LDA.b #!Define_SMW_MaxShooterSpriteSlot
	STA.w !RAM_SMW_ShooterSpr_SlotToOverwriteWhenSlotsFull
CODE_02AB93:
	LDX.w !RAM_SMW_ShooterSpr_SlotToOverwriteWhenSlotsFull
	LDY.w !RAM_SMW_ShooterSpr_UnusedLevelListIndex,x
if defined("Define_SMW_SA1")
	JSL.l SpriteLoading_CODE_01AC9C
	NOP
else
	LDA.b #$00			; \ Allow sprite to be reloaded by level loading routine
	STA.w !RAM_SMW_Sprites_LoadStatus,y
endif
CODE_02AB9E:
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_ShooterFix2
else
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_ScratchRAM04
endif
	SEC
	SBC.b #$C8
	STA.w !RAM_SMW_ShooterSpr_SpriteID,x
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	LSR
	BCC.b CODE_02ABC7
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
	PHA
	AND.b #$F0
	STA.w !RAM_SMW_ShooterSpr_XPosLo,x
	PLA
	AND.b #$01
	STA.w !RAM_SMW_ShooterSpr_XPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_ShooterSpr_YPosLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_ShooterSpr_YPosHi,x
	BRA.b CODE_02ABDF

CODE_02ABC7:
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
	PHA
	AND.b #$F0
	STA.w !RAM_SMW_ShooterSpr_YPosLo,x
	PLA
	AND.b #$01
	STA.w !RAM_SMW_ShooterSpr_YPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_ShooterSpr_XPosLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_ShooterSpr_XPosHi,x
CODE_02ABDF:
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_ShooterSpr_UnusedLevelListIndex,x
	LDA.b #$10
	STA.w !RAM_SMW_ShooterSpr_ShootTimer,x
	INY
	INY
	INY
	LDX.b !RAM_SMW_Misc_ScratchRAM02
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_ShooterFix3
else
	INX
	JMP.w SMW_ParseLevelSpriteList_LoadSpriteLoopStrt
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0DE_Load5Eeries(Address)
namespace SMW_NorSpr0DE_Load5Eeries
%InsertMacroAtXPosition(<Address>)

InitialXPosLo:
	db $E0,$F0,$00,$10,$20

InitialXPosHi:
	db $FF,$FF,$00,$00,$00

InitialYSpeed:
	db $17,$E9,$17,$E9,$17

InitialVerticalDirection:
	db $00,$01,$00,$01,$00

InitialXSpeed:
	db $10,$F0

Main:
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_FiveEeriesFix
else
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
endif
	PHA
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM08
	PLA
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_02AFAF:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return02AFFD
	TYX
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
if defined("Define_SMW_SA1")
	; SA-1 Pack: Loading 5 Eeries.
	JSL.l EIRIE_SET
else
	LDA.b #!Define_SMW_SpriteID_NorSpr039_WavyEerie	; \ Sprite = Wave Eerie
	STA.b !RAM_SMW_NorSpr_SpriteID,x
endif
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDY.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w InitialXPosLo,y
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	ADC.w InitialXPosHi,y
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDA.w InitialYSpeed,y
	STA.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.w InitialVerticalDirection,y
	STA.b !RAM_SMW_NorSprXXX_Eeries_VerticalMovementDirection,x
	CPY.b #$04
	BNE.b CODE_02AFF1
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_NorSpr_LoadStatusTableIndex,x
CODE_02AFF1:
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_CopyOfBank02_X
	LDA.w InitialXSpeed,y
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_02AFAF
Return02AFFD:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0E0_Load3Platforms(Address)
namespace SMW_NorSpr0E0_Load3Platforms
%InsertMacroAtXPosition(<Address>)

; Initial angles of the 3 platforms in the 3 Grey Rotating Platforms sprite.
; Format: - $02AF2D (Low Bytes) - Platform 1 (Default: $00) - Platform 2
; (Default: $AA) - Platform 3 (Default: $54) - $02AF30 (High Bytes) -
; Platform 1 (Default: $00) - Platform 2 (Default: $00) - Platform 3
; (Default: $01)
InitialAngleLo:
	db $00,$AA,$54

InitialAngleHi:
	db $00,$00,$01

Main:
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_ThreePlatformsFix2
else
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
endif
	PHA
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM08
	PLA
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_02AF45:
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ Return if no free slots
	BMI.b Return02AF86
	TYX
	LDA.b #!Define_SMW_NorSprStatus01_Init	; \ Sprite status = Initialization
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
if defined("Define_SMW_SA1")
	; SA-1 Pack: The tripple gray platform on initialization access sprite
	; tables of each individual gray platform.
	JSL.l GRAY_PLATFORM_SET
else
	LDA.b #!Define_SMW_SpriteID_NorSpr0A3_GreyChainedPlatform	; \ Sprite = Grey Platform on Chain
	STA.b !RAM_SMW_NorSpr_SpriteID,x
endif
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	LDY.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w InitialAngleLo,y
	STA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleLo,x
	LDA.w InitialAngleHi,y
	STA.w !RAM_SMW_NorSpr0A3_GreyChainedPlatform_CurrentAngleHi,x
	CPY.b #$02
	BNE.b CODE_02AF82
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_NorSpr_LoadStatusTableIndex,x
CODE_02AF82:
	DEC.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_02AF45
Return02AF86:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0E1_LoadBooCeiling(Address)
namespace SMW_NorSpr0E1_LoadBooCeiling
%InsertMacroAtXPosition(<Address>)

CODE_02AABD:
	JMP.w SMW_NorSpr0E5_LoadDeathBatCeiling_Main

Main:
	LDY.b #$01
	STY.w !RAM_SMW_Flag_RunClusterSprites
	CMP.b #$E4
	BEQ.b CODE_02AABD
	CMP.b #$E6
	BEQ.b SMW_NorSpr0E6_LoadCandleFlames_Main
	CMP.b #$E5
	BEQ.b SMW_NorSpr0E5_LoadReappearingBoo_Main
	CMP.b #$E2
	BCS.b SMW_NorSprXXX_LoadBooRing_Main
	LDX.b #!Define_SMW_MaxClusterSpriteSlot
CODE_02AAD7:
	STZ.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E66,x
	STZ.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F86,x
	LDA.b #!Define_SMW_SpriteID_ClusterSpr03_BooCeiling
	STA.w !RAM_SMW_ClusterSpr_SpriteID,x
	JSL.l SMW_GetRand_Main
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w !RAM_SMW_ClusterSpr_XPosLo,x
	STA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F4A,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ClusterSpr_XPosHi,x
	LDA.w !RAM_SMW_Misc_RandomByte2
	AND.b #$3F
	ADC.b #$08
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ClusterSpr_YPosHi,x
	DEX
	BPL.b CODE_02AAD7
	INC.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownRAM
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSprXXX_LoadBooRing(Address)
namespace SMW_NorSprXXX_LoadBooRing
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.w !RAM_SMW_ClusterSpr04_BooRing_RingIndex
	CPY.b #$02
	BCS.b Return02AB77
	LDY.b #$01
	CMP.b #$E2
	BEQ.b CODE_02AB20
	LDY.b #$FF
CODE_02AB20:
	STY.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b #$09
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDX.b #!Define_SMW_MaxClusterSpriteSlot
CODE_02AB28:
	LDA.w !RAM_SMW_ClusterSpr_SpriteID,x
	BNE.b CODE_02AB71
	LDA.b #!Define_SMW_SpriteID_ClusterSpr04_BooRing
	STA.w !RAM_SMW_ClusterSpr_SpriteID,x
	LDA.w !RAM_SMW_ClusterSpr04_BooRing_RingIndex
	STA.w !RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F86,x
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	STA.w !RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F72,x
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	STA.w !RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F4A,x
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_02AB6D
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_SpriteE2Fix
else
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
endif
	LDY.w !RAM_SMW_ClusterSpr04_BooRing_RingIndex
	PHA
	AND.b #$F0
	STA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterYPosLo,y
	PLA
	AND.b #$01
	STA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterYPosHi,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosHi,y
	LDA.b #$00
	STA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1OffscreenFlag,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02					;\ Optimization: Boo rings are never killed, so this is useless.
	STA.w !RAM_SMW_ClusterSpr04_BooRing_UnusedRing1LevelListIndex,y		;/
CODE_02AB6D:
	DEC.b !RAM_SMW_Misc_ScratchRAM0E
	BMI.b CODE_02AB74
CODE_02AB71:
	DEX
	BPL.b CODE_02AB28
CODE_02AB74:
	INC.w !RAM_SMW_ClusterSpr04_BooRing_RingIndex
Return02AB77:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0E5_LoadDeathBatCeiling(Address)
namespace SMW_NorSpr0E5_LoadDeathBatCeiling
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #!Define_SMW_MaxClusterSpriteSlot-$05	; \ Unreachable
ADDR_02AA35:
	STZ.w !RAM_SMW_ClusterSpr08_DeathBatCeiling_UnknownTable7E1E66,x	; | Loop X = 00 to 0E
	STZ.w !RAM_SMW_ClusterSpr08_DeathBatCeiling_UnknownTable7E0F86,x
	LDA.b #!Define_SMW_SpriteID_ClusterSpr08_DeathBatCeiling
	STA.w !RAM_SMW_ClusterSpr_SpriteID,x
	JSL.l SMW_GetRand_Main
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w !RAM_SMW_ClusterSpr_XPosLo,x
	STA.w !RAM_SMW_ClusterSpr08_DeathBatCeiling_UnknownTable7E0F4A,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ClusterSpr_XPosHi,x
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_SpriteE4Fix
else
	LDY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
endif
	PHA
	AND.b #$F0
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	PLA
	AND.b #$01
	STA.w !RAM_SMW_ClusterSpr_YPosHi,x
	DEX
	BPL.b ADDR_02AA35
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_NorSpr0E5_LoadReappearingBoo(Address)
namespace SMW_NorSpr0E5_LoadReappearingBoo
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Sprites_DisappearingBooFrameCounter
	LDX.b #!Define_SMW_MaxClusterSpriteSlot
CODE_02AA92:
	LDA.b #!Define_SMW_SpriteID_ClusterSpr07_ReappearingBoo
	STA.w !RAM_SMW_ClusterSpr_SpriteID,x
	LDA.w DATA_02AA0B,x
	PHA
	AND.b #$F0
	STA.w !RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E66,x
	PLA
	ASL
	ASL
	ASL
	ASL
	STA.w !RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E52,x
	LDA.w DATA_02AA1F,x
	PHA
	AND.b #$F0
	STA.w !RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E8E,x
	PLA
	ASL
	ASL
	ASL
	ASL
	STA.w !RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E7A,x
	DEX
	BPL.b CODE_02AA92
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr0E5_LoadReappearingBoo(Address)
namespace SMW_NorSpr0E5_LoadReappearingBoo
%InsertMacroAtXPosition(<Address>)

; Position of all Boos in the reappearing ghosts generator, frame 1. Format:
; $xy.
DATA_02AA0B:
	db $31,$71,$A1,$43,$93,$C3,$14,$65
	db $E5,$36,$A7,$39,$99,$F9,$1A,$7A
	db $DA,$4C,$AD,$ED

; Position of all Boos in the reappearing ghosts generator, frame 2. Format:
; $xy.
DATA_02AA1F:
	db $01,$51,$91,$D1,$22,$62,$A2,$73
	db $E3,$C7,$88,$29,$5A,$AA,$EB,$2C
	db $8C,$CC,$FC,$5D
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_NorSpr0E6_LoadCandleFlames(Address)
namespace SMW_NorSpr0E6_LoadCandleFlames
%InsertMacroAtXPosition(<Address>)

InitialXPosLo:
	db $50,$90,$D0,$10

Main:
	LDA.b #!Define_SMW_NorSprStatus07_InLimbo			;\ Glitch: This causes the sprite in slot 03 to disappear and should be removed
	STA.w !RAM_SMW_NorSpr_CurrentStatus+$03				;/
	LDX.b #!Define_SMW_MaxClusterSpriteSlot-$10
CODE_02AA73:
	LDA.b #!Define_SMW_SpriteID_ClusterSpr05_CandleFlame
	STA.w !RAM_SMW_ClusterSpr_SpriteID,x
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l InitialXPosLo,x
else
	LDA.w InitialXPosLo,x
endif
	STA.w !RAM_SMW_ClusterSpr_XPosLo,x
	LDA.b #$F0
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	TXA
	ASL
	ASL
	STA.w !RAM_SMW_ClusterSpr05_CandleFlame_UnknownTable7E0F4A,x
	DEX
	BPL.b CODE_02AA73
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr01_SmokePuff(Address)
namespace SMW_ExtSpr01_SmokePuff
%InsertMacroAtXPosition(<Address>)

EraseSprite1:
	JMP.w SMW_GenericExtendedSpriteGFXRt_EraseSprite

; Dust Cloud Tilemap
Tiles:
	db $66,$64,$60,$62
Prop:
	db $00,$40,$C0,$80

Main:
	LDA.w !RAM_SMW_ExtSpr01_SmokePuff_DespawnTimer,x	;\Different frames of graphics
	BEQ.b EraseSprite1		;/
	LDA.w !RAM_SMW_Flag_ReznorRoomOAMIndexTimer	;\Prevent overwriting the platform's OAM in the reznor fight
	BNE.b CODE_02A362		;/
	LDA.w !RAM_SMW_Misc_NMIToUseFlag	;\Some interactive layer 2 stuff
	BPL.b CODE_02A362		;|
	AND.b #$40			;|
	BNE.b ADDR_02A3B1		;/
CODE_02A362:
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x
	CPX.b #$08			;\If used, try a different index
	BCC.b CODE_02A36C		;/
	LDY.w SMW_ExtSpr05_MarioFireball_DATA_029FAB-$08,x	;>Use different OAM index
CODE_02A36C:
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;\OAM X position
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	CMP.b #$F8			;|
	BCS.b EraseSprite2		;|>Don't draw if offscreen
	STA.w SMW_OAMBuffer[$00].XDisp,y	;/
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\OAM Y position
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	CMP.b #$F0			;|
	BCS.b EraseSprite2		;|
	STA.w SMW_OAMBuffer[$00].YDisp,y	;/
	LDA.w !RAM_SMW_ExtSpr01_SmokePuff_DespawnTimer,x
	LSR
	LSR
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$03
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Prop,x
else
	LDA.w Prop,x
endif
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA				;\16x16 size
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$02			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

EraseSprite2:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	JML.l SMW_GenericExtendedSpriteGFXRt_EraseSprite
else
	JMP.w SMW_GenericExtendedSpriteGFXRt_EraseSprite	;!
endif

ADDR_02A3B1:
	LDY.w SMW_ExtSpr05_MarioFireball_DATA_029FAD-$08,x
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;\X pos
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	CMP.b #$F8			;|
	BCS.b EraseSprite2		;|>if offscreen, no draw
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\Y pos
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	CMP.b #$F0			;|
	BCS.b EraseSprite2		;|>If offscreen no draw
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	LDA.w !RAM_SMW_ExtSpr01_SmokePuff_DespawnTimer,x
	LSR
	LSR
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$03
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Prop,x
else
	LDA.w Prop,x
endif
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	TYA				;\16x16 tile size
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$02			;|
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr02_ReznorFireball(Address)
namespace SMW_ExtSpr02_ReznorFireball
%InsertMacroAtXPosition(<Address>)

; Reznor Fireball Tilemap
Tiles:
	db $26,$2A,$26,$2A

; Reznor fireball tiles' flip/priority/palette/GFX page (YXPPCCCT format).
Prop:
	db $35,$35,$F5,$F5

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\Frozen = no physics
	BNE.b +				;/
	JSR.w SMW_UpdateExtendedSpritePosition_X	;>Destroyed by cape
	JSR.w SMW_UpdateExtendedSpritePosition_Y	;\XY speed
	JSR.w SMW_CheckForMarioToExtendedSpriteCollision_Main	;/
+:
PiranhaFireballEntry:
	LDA.w !RAM_SMW_Misc_NMIToUseFlag			;\ Note: This is why reznor fireballs look like normal ones outside of their mode 7 room.
	; Change to [EA EA] (org $02A17B : NOP #2) to make Reznor's and Jumpin'
	; Piranha Plant's fireballs always large, or to [80 27] (org $02A17B : BRA
	; $27) to make them always small.
	BPL.b SMW_GenericExtendedSpriteGFXRt_Main		;/ Seems like a pointless check if you ask me.
	JSR.w SMW_GenericExtendedSpriteGFXRt_Main
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x
	LDA.b !RAM_SMW_Counter_LocalFrames	;\Different fireball image
	LSR				;|based on frames.
	LSR				;|
	AND.b #$03			;|
	PHX				;|
	TAX				;|
	LDA.w Tiles,x			;|
	STA.w SMW_OAMBuffer[$00].Tile,y	;/
	LDA.w Prop,x			;\YXPPCCCT
	EOR.b !RAM_SMW_Misc_ScratchRAM00	;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	TYA				;\Set size to 16x16.
	LSR				;|
	LSR				;|
	TAX				;|
	LDA.b #$02			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x	;/
	PLX
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr03_FlameRemnant(Address)
namespace SMW_ExtSpr03_FlameRemnant
%InsertMacroAtXPosition(<Address>)

; Small flame left by Hopping Flame Tilemap
Tiles:
	db $AC,$AD

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02A22F
	INC.w !RAM_SMW_ExtSpr03_FlameRemnant_AnimationFrameCounter,x	;>Increment for different graphics
	LDA.w !RAM_SMW_ExtSpr03_FlameRemnant_DespawnTimer,x	;\Graphics handler
	BEQ.b SMW_GenericExtendedSpriteGFXRt_EraseSprite	;|
	CMP.b #$50			;|
	BCS.b CODE_02A22F		;|
	AND.b #$01			;|
	BNE.b Return02A253		;|
	BEQ.b CODE_02A232		;/
CODE_02A22F:
	JSR.w SMW_CheckForMarioToExtendedSpriteCollision_Main	;>Cape destroys the extended sprite
CODE_02A232:
	JSR.w SMW_GenericExtendedSpriteGFXRt_Main	;>OAM base code
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x	;>Get OAM index
	LDA.w !RAM_SMW_ExtSpr03_FlameRemnant_AnimationFrameCounter,x
	LSR
	LSR
	AND.b #$01
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.w SMW_OAMBuffer[$00].Prop,y	;\YXPPCCCT
	AND.b #$3F			;|
	ORA.b #$05			;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
Return02A253:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr04_Hammer(Address)
namespace SMW_ExtSpr04_Hammer
%InsertMacroAtXPosition(<Address>)

; Hammer Tilemap (Also, the flip of Dry Bones' bone)
Tiles:
	db $08,$6D,$6D,$08,$08,$6D,$6D,$08

; Palette/GFX Page of Hammer
Prop:
	db $47,$47,$07,$07,$87,$87,$C7,$C7

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02A30C
	JSR.w SMW_UpdateExtendedSpritePosition_X	;\XY speed
	JSR.w SMW_UpdateExtendedSpritePosition_Y	;/
	LDA.w !RAM_SMW_ExtSpr_YSpeed,x	;\Gravity, until terminal velocity is reached
	CMP.b #$40			;|
	BPL.b CODE_02A306		;|
	INC.w !RAM_SMW_ExtSpr_YSpeed,x	;|
	INC.w !RAM_SMW_ExtSpr_YSpeed,x	;/
CODE_02A306:
	JSR.w SMW_CheckForMarioToExtendedSpriteCollision_Main	;>Destroyed by cape
	INC.w !RAM_SMW_ExtSpr04_Hammer_AnimationFrameCounter,x	;>Alternate graphics
CODE_02A30C:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x	;\If other than Piranha's fireball
	CMP.b #!Define_SMW_SpriteID_ExtSpr0B_PiranhaFireball	;|branch
	BNE.b +				;/
	JSR.w SMW_ExtSpr02_ReznorFireball_PiranhaFireballEntry	;>Go to part of the reznor fireball for code recycling.
	RTS

+:
ThrownBoneEntry:
	JSR.w SMW_GenericExtendedSpriteGFXRt_Main	;>Base code for many extended sprites
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_ExtSpr04_Hammer_AnimationFrameCounter,x
	LSR
	LSR
	LSR
	AND.b #$07
	PHX
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Prop,x
else
	LDA.w Prop,x
endif
	EOR.b !RAM_SMW_Misc_ScratchRAM00
	EOR.b #$40
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA				;\16x16 size
	LSR				;|
	LSR				;|
	TAX				;|
	LDA.b #$02			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x	;/
	PLX				;>Restore extended sprite index.
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtSpr04_Hammer_Main, SMW_ExtSpr0B_PiranhaFireball_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr05_MarioFireball(Address)
namespace SMW_ExtSpr05_MarioFireball
%InsertMacroAtXPosition(<Address>)

; Table of Y speeds to bounce Mario fireball on various slopes (see details
; for order). Change to all zeros to make straight fireballs not fly off of
; slopes at an angle. Use in conjunction with the fireball hit timer at
; $029FE4.
DATA_029F99:
	db $00,$B8,$C0,$C8,$D0,$D8,$E0,$E8
	db $F0

DATA_029FA2:
	db $00,$05,$03,$02,$02,$02,$02,$02
	db $02

; OAM indexes for the player's fireballs.
DATA_029FAB:
	db $F8,$FC

DATA_029FAD:
	db $A0,$A4

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\Frozen
	BNE.b CODE_02A02C		;/
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\If onscreen vertically
	CMP.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x	;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;|
	BEQ.b CODE_029FC2		;/
	JMP.w SMW_GenericExtendedSpriteGFXRt_EraseSprite	;>Delete sprite

CODE_029FC2:
	INC.w !RAM_SMW_ExtSpr_Table7E1765,x	;>Alternate graphics
	JSR.w SMW_CheckForPlayerFireballToNormalSpriteCollision_Main	;>Sprites interacting with fireball
	LDA.w !RAM_SMW_ExtSpr_YSpeed,x	;\Gravity with terminal velocity
	CMP.b #$30			;|
	BPL.b CODE_029FD8		;|
	LDA.w !RAM_SMW_ExtSpr_YSpeed,x	;|
	CLC				;|
	ADC.b #$04			;|
	STA.w !RAM_SMW_ExtSpr_YSpeed,x	;/
CODE_029FD8:
#LMBlockOffset_MarioFireball:
	JSR.w SMW_HandleExtendedSpriteLevelCollision_Main	;>Interact with objects (normally this bounces or hits a wall and disappears)
	; Change to 80 to make the player's fireballs go through objects.
	BCC.b CODE_02A010		;>Branch if no hits occured
	INC.w !RAM_SMW_ExtSpr05_MarioFireball_HitFlag,x	;>Hit flag table
	LDA.w !RAM_SMW_ExtSpr05_MarioFireball_HitFlag,x	;\If hits a wall, dissipates
	CMP.b #$02			;|
	BCS.b CODE_02A042		;/
	LDA.w !RAM_SMW_ExtSpr_XSpeed,x	;\If X speed going rightwards
	BPL.b CODE_029FF3		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	EOR.b #$FF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM0B
CODE_029FF3:
	LDA.b !RAM_SMW_Misc_ScratchRAM0B			;\ Glitch: Conveyor slopes store #$08/#$F8 to !RAM_SMW_Misc_ScratchRAM0B, which underflows the Y index
	CLC						;| This is why fireballs teleport when fired into one.
	ADC.b #$04					;|
	TAY						;|
	LDA.w DATA_029F99,y				;|
	STA.w !RAM_SMW_ExtSpr_YSpeed,x			;|
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x			;|
	SEC						;|
	SBC.w DATA_029FA2,y				;/
	STA.w !RAM_SMW_ExtSpr_YPosLo,x
	BCS.b CODE_02A00E
	DEC.w !RAM_SMW_ExtSpr_YPosHi,x
CODE_02A00E:
	BRA.b CODE_02A013

CODE_02A010:
	STZ.w !RAM_SMW_ExtSpr05_MarioFireball_HitFlag,x
CODE_02A013:
	LDY.b #$00
	LDA.w !RAM_SMW_ExtSpr_XSpeed,x
	BPL.b CODE_02A01B
	DEY
CODE_02A01B:
	CLC
	ADC.w !RAM_SMW_ExtSpr_XPosLo,x
	STA.w !RAM_SMW_ExtSpr_XPosLo,x
	TYA
	ADC.w !RAM_SMW_ExtSpr_XPosHi,x
	STA.w !RAM_SMW_ExtSpr_XPosHi,x
	JSR.w SMW_UpdateExtendedSpritePosition_Y	;>Update Y position
CODE_02A02C:
if defined("Define_SMW_SA1")
	LDA.w !RAM_SMW_Flag_ReznorRoomOAMIndexTimer
	BNE.b CODE_02A03B
	NOP
else
	LDA.b !RAM_SMW_NorSpr_SpriteID+$07
	CMP.b #!Define_SMW_SpriteID_NorSpr0A9_Reznor
	BEQ.b CODE_02A03B
endif
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	BPL.b CODE_02A03B
	AND.b #$40
	BNE.b ADDR_02A04F
CODE_02A03B:
	LDY.w DATA_029FAB-$08,x
	JSR.w SMW_GenericExtendedSpriteGFXRt_FireballEntry
	RTS

CODE_02A042:
	JSR.w CODE_02A02C
CODE_02A045:
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.b #$0F
	JMP.w SMW_CheckForMarioToExtendedSpriteCollision_CODE_02A4E0

ADDR_02A04F:
	LDY.w DATA_029FAD-$08,x		;>Y = OAM index
	LDA.w !RAM_SMW_ExtSpr_XSpeed,x	;\Bit 6 contains the sign bit of sprite speed
	AND.b #$80			;|
	LSR				;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;\OAM Y pos
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	CMP.b #$F8			;|
	BCS.b ADDR_02A0A9		;|
	STA.w SMW_OAMBuffer[$40].XDisp,y	;/
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\OAM Y pos
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	CMP.b #$F0			;|
	BCS.b ADDR_02A0A9		;|
	STA.w SMW_OAMBuffer[$40].YDisp,y	;/
	LDA.w !RAM_SMW_ExtSpr05_MarioFireball_CurrentLayerPriority,x	;\Behind layers
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDA.w !RAM_SMW_ExtSpr_Table7E1765,x	;\Graphics handler
	LSR				;|
	LSR				;|
	AND.b #$03			;|
	TAX				;/
	LDA.w SMW_GenericExtendedSpriteGFXRt_FireballTiles,x	;\Tile number
	STA.w SMW_OAMBuffer[$40].Tile,y	;/
	LDA.w SMW_GenericExtendedSpriteGFXRt_DATA_02A15F,x	;\YXPPCCCT
	EOR.b !RAM_SMW_Misc_ScratchRAM00	;|(probably handles spinning fireball)
	ORA.b !RAM_SMW_Sprites_TilePriority	;|
	STA.w SMW_OAMBuffer[$40].Prop,y	;|
	LDX.b !RAM_SMW_Misc_ScratchRAM01	;|
	BEQ.b ADDR_02A09C		;|
	AND.b #$CF			;|
	ORA.b #$10			;|
	STA.w SMW_OAMBuffer[$40].Prop,y	;/
ADDR_02A09C:
	TYA				;\8x8 sprite
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$00			;|
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y	;/
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
Return02A0A8:
	RTS

ADDR_02A0A9:
	JMP.w SMW_GenericExtendedSpriteGFXRt_EraseSprite
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr06_ThrownBone(Address)
namespace SMW_ExtSpr06_ThrownBone
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02A26A
	JSR.w SMW_UpdateExtendedSpritePosition_X	;>Handle X speed
	INC.w !RAM_SMW_ExtSpr06_ThrownBone_UnknownRAM7E1765,x	;>Graphics alternater
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\Every other frames
	AND.b #$01			;|alternate the tile
	BNE.b CODE_02A267		;/
	INC.w !RAM_SMW_ExtSpr06_ThrownBone_UnknownRAM7E1765,x
CODE_02A267:
	JSR.w SMW_CheckForMarioToExtendedSpriteCollision_Main	;>Destroyed by cape
CODE_02A26A:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x	;\If other than baseball (the only other that reuses this is $06 - bone)
	CMP.b #!Define_SMW_SpriteID_ExtSpr0D_Baseball	;|then branch to "bone" (from dry bones throwing bones)
	BNE.b CODE_02A2C3		;/
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;\$00 = X pos on screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x	;\If baseball travels in a direction away from the side
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;|of the screen, don't delete it. Only delete if heading
	BEQ.b CODE_02A287		;|to the side of the screen opposite direction of it's thrown
	EOR.w !RAM_SMW_ExtSpr_XSpeed,x	;|
	BPL.b EraseSprite		;/
	BMI.b Return02A2BE
CODE_02A287:
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\OAM X pos
	STA.w SMW_OAMBuffer[$00].XDisp,y	;/
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\$01 = Y pos on screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x	;\Delete if offscreen
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;|
	BNE.b EraseSprite		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\OAM Y pos
	STA.w SMW_OAMBuffer[$00].YDisp,y	;/
	LDA.b #$AD			;\Tile number
	STA.w SMW_OAMBuffer[$00].Tile,y	;/
	LDA.b !RAM_SMW_Counter_LocalFrames	;\Tile properties (YXPPCCCT),
	ASL				;|flips through many frames to
	ASL				;|show a "spinning" baseball
	ASL				;|
	ASL				;|
	AND.b #$C0			;|
	ORA.b #$39			;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	TYA				;\make it 8x8.
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$00			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
Return02A2BE:
	RTS

EraseSprite:
	%INLINEROUTINE_SMW_EraseExtendedSprite()

CODE_02A2C3:
	JSR.w SMW_ExtSpr04_Hammer_ThrownBoneEntry	;Get some base code of other
	LDA.w SMW_OAMBuffer[$00].Tile,y
	CMP.b #$26
	LDA.b #$80
	BCS.b CODE_02A2D1
	LDA.b #$82
CODE_02A2D1:
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.w SMW_OAMBuffer[$00].Prop,y	;\YXPPCCCT
	AND.b #$F1			;|
	ORA.b #$02			;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtSpr06_ThrownBone_Main, SMW_ExtSpr0D_Baseball_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr07_LavaSplash(Address)
namespace SMW_ExtSpr07_LavaSplash
%InsertMacroAtXPosition(<Address>)

Tiles:
	%INLINEDATATABLE_SMW_LavaSplashTileNumbers()

Main:
;$029E86
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\Frozen
	BNE.b CODE_029E9D		;/
	JSR.w SMW_UpdateExtendedSpritePosition_X	;\XY speed
	JSR.w SMW_UpdateExtendedSpritePosition_Y	;/
	LDA.w !RAM_SMW_ExtSpr_YSpeed,x	;\Gravity
	CLC				;|
	ADC.b #$02			;|
	STA.w !RAM_SMW_ExtSpr_YSpeed,x	;/
	CMP.b #$30			;\Once reaches terminal velocity
	BPL.b EraseSprite		;/delete the sprite
CODE_029E9D:
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x	;>OAM index in Y
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;\$00 = X pos on screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x	;\Delete extended sprite if offscreen horizontally
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;|
	BNE.b EraseSprite		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\OAM X pos
	STA.w SMW_OAMBuffer[$00].XDisp,y	;/
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\Delete extended sprite if offscreen vertically
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	CMP.b #$F0			;|
	BCS.b EraseSprite		;/
	STA.w SMW_OAMBuffer[$00].YDisp,y	;>OAM Y pos
	LDA.w !RAM_SMW_ExtSpr07_LavaSplash_AnimationFrameCounter,x
	LSR
	LSR
	LSR
	NOP #2									;\ Note: It seems Nintendo may have originally had these particles animate slower.
										;/ Optimization: Of course, NOPs that serve a non-timing purpose are better off removed.
	AND.b #$03
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority	;\YXPPCCCT
	ORA.b #$05			;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	TYA				;\8x8 sprite
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$00			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

EraseSprite:
	%INLINEROUTINE_SMW_EraseExtendedSprite()

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr08_LauncherArm(Address)
namespace SMW_ExtSpr08_LauncherArm
%InsertMacroAtXPosition(<Address>)

YSpeed:
	db $08,$00,$F8

EraseSprite:
	%INLINEROUTINE_SMW_EraseExtendedSprite()

Main:
	LDY.b #$00
	LDA.w !RAM_SMW_ExtSpr08_LauncherArm_VerticalDirectionTimer,x
	BEQ.b EraseSprite
	CMP.b #$60
	BCS.b CODE_029E4E
	INY
	CMP.b #$30
	BCS.b CODE_029E4E
	INY
CODE_029E4E:
	PHY
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\Frozen
	BNE.b CODE_029E5C		;/
	LDA.w YSpeed,y			;\Hand moves up and down
	STA.w !RAM_SMW_ExtSpr_YSpeed,x	;/
	JSR.w SMW_UpdateExtendedSpritePosition_Y	;>Y speed
CODE_029E5C:
	JSR.w SMW_GenericExtendedSpriteGFXRt_Main	;>extended sprite base code
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x	;>Y = OAM index
	PLA				;\What was Y pushed into stack pulled into A
	CMP.b #$01			;|this handles the state of the arm sprite
	LDA.b #$84			;|("grabbing" and "releasing" image)
	BCC.b CODE_029E6B		;|
	LDA.b #$A4			;/
CODE_029E6B:
	STA.w SMW_OAMBuffer[$00].Tile,y	;>Tile number
	LDA.w SMW_OAMBuffer[$00].Prop,y	;\Properties
	AND.b #$00			;|
	ORA.b #$13			;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	TYA				;\16x16 sprite
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$02			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr09_Unused(Address)
namespace SMW_ExtSpr09_Unused
%InsertMacroAtXPosition(<Address>)

DATA_029D5E:
	db $00,$01,$02,$03,$02,$03,$02,$03
	db $03,$02,$03,$02,$03,$02,$01,$00

XDisp:
	db $10,$F8,$03,$10,$F8,$03,$10,$F0
	db $FF,$10,$F0,$FF

YDisp:
	db $02,$02,$EE,$02,$02,$EE,$FE,$FE
	db $E6,$FE,$FE,$E6

Tiles:
	db $B3,$B3,$B1,$B2,$B2,$B0,$8E,$8E
	db $A8,$8C,$8C,$88

Prop:
	db $69,$29,$29

TileSize:
	db $00,$00,$02,$02

EraseSprite:
	%INLINEROUTINE_SMW_EraseExtendedSprite()

Main:
	JSR.w SMW_CheckForMarioToExtendedSpriteCollision_Main
	LDY.w !RAM_SMW_ExtSpr_XSpeed,x
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b EraseSprite
	LDA.w !RAM_SMW_ExtSpr_DecrementingTable7E176F,x
	BEQ.b EraseSprite
	LSR
	LSR
	NOP #2
	TAY
	LDA.w DATA_029D5E,y
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_ExtSpr_Table7E1765,x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	TAY
	STY.b !RAM_SMW_Misc_ScratchRAM03
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x
	CLC
	ADC.w XDisp,y
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x
	CLC
	ADC.w YDisp,y
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x
	CMP.b #$F0
	BCS.b SMW_ExtSpr08_LauncherArm_EraseSprite
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$10
	BCC.b SMW_ExtSpr08_LauncherArm_EraseSprite
	CMP.b #$F0
	BCS.b SMW_ExtSpr08_LauncherArm_EraseSprite
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_ExtSpr_Table7E1765,x
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Prop,x
else
	LDA.w Prop,x
endif
	STA.w SMW_OAMBuffer[$00].Prop,y
	LDX.b !RAM_SMW_Misc_ScratchRAM03
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDX.b !RAM_SMW_Misc_ScratchRAM0F
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l TileSize,x
else
	LDA.w TileSize,x
endif
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Player_OnScreenPosXLo
	CLC
	ADC.b #$04
	CMP.b #$08
	BCS.b Return029E35
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	SEC
	SBC.b !RAM_SMW_Player_OnScreenPosYLo
	SEC
	SBC.b #$10
	CLC
	ADC.b #$10
	CMP.b #$10
	BCS.b Return029E35
	JMP.w SMW_CheckForMarioToExtendedSpriteCollision_CODE_02A469

Return029E35:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr0A_CloudCoin(Address)
namespace SMW_ExtSpr0A_CloudCoin
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_029CF8
	JSR.w SMW_UpdateExtendedSpritePosition_Y	;>Handle Y speed
	LDA.w !RAM_SMW_ExtSpr_YSpeed,x	;\Gravity with terminal velocity
	CMP.b #$30			;|
	BPL.b CODE_029CC9		;|
	CLC				;|
	ADC.b #$02			;|
	STA.w !RAM_SMW_ExtSpr_YSpeed,x	;/
CODE_029CC9:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x	;\If not a flower of wiggler, branch
	CMP.b #!Define_SMW_SpriteID_ExtSpr0E_WigglerFlower	;|
	BNE.b ADDR_029CE3		;/
	LDY.b #$08
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$08
	BEQ.b CODE_029CDA
	LDY.b #$F8
CODE_029CDA:
	TYA
	STA.w !RAM_SMW_ExtSpr_XSpeed,x
	JSR.w SMW_UpdateExtendedSpritePosition_X	;>Give X speed
	BRA.b CODE_029CF8

ADDR_029CE3:
	LDA.w !RAM_SMW_ExtSpr0A_CloudCoin_DisableBlockCollisionFlag,x
	BNE.b ADDR_029CF5
	JSR.w SMW_HandleExtendedSpriteLevelCollision_Main	;>Coin game cloud interacts with floor so that it can bounce
	BCC.b ADDR_029CF5
	LDA.b #$D0			;\Bounce
	STA.w !RAM_SMW_ExtSpr_YSpeed,x	;/
	INC.w !RAM_SMW_ExtSpr0A_CloudCoin_DisableBlockCollisionFlag,x
ADDR_029CF5:
	JSR.w SMW_CheckForMarioToExtendedSpriteCollision_Main	;Cape collects the coin (see $02A412)
CODE_029CF8:
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\$01 = Y pos on screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	CMP.b #$F0			;|
	BCS.b CODE_029D5A		;|
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;\Delete if offscreen vertically
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x	;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;|
	BNE.b Return029D5D		;/
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x	;\Y and $0F = OAM index
	STY.b !RAM_SMW_Misc_ScratchRAM0F	;/
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;\$00 = X pos on screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	STA.w SMW_OAMBuffer[$00].XDisp,y	;>Write OAM X pos
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x	;\Branch if other than wiggler flower
	CMP.b #!Define_SMW_SpriteID_ExtSpr0E_WigglerFlower	;|if it was a coin game cloud
	BNE.b ADDR_029D45		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\OAM Y pos
	SEC				;|
	SBC.b #$05			;|
	STA.w SMW_OAMBuffer[$00].YDisp,y	;/
	LDA.b #$98			;\Tile number
	STA.w SMW_OAMBuffer[$00].Tile,y	;/
	LDA.b #$0B
CODE_029D36:
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA				;\8x8 size
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$00			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
	RTS

ADDR_029D45:
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\OAM Y
	STA.w SMW_OAMBuffer[$00].YDisp,y	;/
	LDA.b #$C2			;\Tile number
	STA.w SMW_OAMBuffer[$00].Tile,y	;/
	LDA.b #$04			;\Reuse code but with A = $04
	JSR.w CODE_029D36		;/
	LDA.b #$02			;\16x16 smiley coin
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
	RTS

CODE_029D5A:
	STZ.w !RAM_SMW_ExtSpr_SpriteID,x	; Clear extended sprite
Return029D5D:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtSpr0A_CloudCoin_Main, SMW_ExtSpr0E_WigglerFlower_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr0C_VolcanoLotusFire(Address)
namespace SMW_ExtSpr0C_VolcanoLotusFire
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_ExtSpr_XPosLo,x	;\$00 = X position relative to screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.w !RAM_SMW_ExtSpr_XPosHi,x	;\Despawn if offscreen
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;|
	BNE.b EraseSprite		;/
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\$01 = Y position relative to screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x	;\Despawn if offscreen
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;|
	BEQ.b CODE_029B76		;|
	BMI.b CODE_029BA5		;|
	BPL.b EraseSprite		;/
CODE_029B76:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\OAM X pos
	STA.w SMW_OAMBuffer[$00].XDisp,y	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\Skip drawing if offscreen
	CMP.b #$F0			;|
	BCS.b CODE_029BA5		;/
	STA.w SMW_OAMBuffer[$00].YDisp,y	;>OAM Y pos
	LDA.b #$09			;\YXPPCCCT
	ORA.b !RAM_SMW_Sprites_TilePriority	;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	EOR.w !RAM_SMW_NorSpr_CurrentSlotID
	LSR
	LSR
	LDA.b #$A6
	BCC.b CODE_029B99
	LDA.b #$B6
CODE_029B99:
	STA.w SMW_OAMBuffer[$00].Tile,y
	TYA				;\Set size bit to 8x8
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$00			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
CODE_029BA5:
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\Don't do physics if frozen
	BNE.b Return029BD9		;/
	JSR.w SMW_CheckForMarioToExtendedSpriteCollision_Main	;>Gets destroyed by cape
	JSR.w SMW_UpdateExtendedSpritePosition_X	;>Give X speed
	JSR.w SMW_UpdateExtendedSpritePosition_Y	;>Give Y speed
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\Branch if frame counter $13
	AND.b #$03			;|is not a multiple of 4
	BNE.b CODE_029BC2		;/
	LDA.w !RAM_SMW_ExtSpr_YSpeed,x	;\Make it descend faster until terminal velocity
	CMP.b #$18			;|
	BPL.b CODE_029BC2		;|
	INC.w !RAM_SMW_ExtSpr_YSpeed,x	;/
CODE_029BC2:
	LDA.w !RAM_SMW_ExtSpr_YSpeed,x	;\If speed negative, done
	BMI.b Return029BD9		;/
	TXA
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Counter_GlobalFrames
	LDY.b #$08
	AND.b #$08
	BNE.b CODE_029BD5
	LDY.b #$F8
CODE_029BD5:
	TYA
	STA.w !RAM_SMW_ExtSpr_XSpeed,x
Return029BD9:
	RTS

EraseSprite:
	%INLINEROUTINE_SMW_EraseExtendedSprite()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr0F_SmokeTrail(Address)
namespace SMW_ExtSpr0F_SmokeTrail
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $66,$64,$62,$60,$60,$60,$60,$60
	db $60,$60,$60

Main:
	JSR.w SMW_GenericExtendedSpriteGFXRt_Main	;>OAM base code
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x	;>OAM Y index
	LDA.w !RAM_SMW_ExtSpr0F_SmokeTrail_DespawnTimer,x	;\Graphics handler
	LSR				;/
	PHX
	TAX
	LDA.b !RAM_SMW_Counter_LocalFrames
	ASL
	ASL
	ASL
	ASL
	AND.b #$C0
	ORA.b #$32
	STA.w SMW_OAMBuffer[$00].Prop,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	TYA				;\16x16 sprite
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$02			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
	PLX
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return029C7E
	LDA.w !RAM_SMW_ExtSpr0F_SmokeTrail_DespawnTimer,x
	BEQ.b EraseSprite
	CMP.b #$06
	BNE.b CODE_029C7B
	LDA.w !RAM_SMW_ExtSpr_XSpeed,x	;\Double speed?
	ASL				;|
	ROR.w !RAM_SMW_ExtSpr_XSpeed,x	;/
CODE_029C7B:
	JSR.w SMW_UpdateExtendedSpritePosition_X	;>Apply X speed
Return029C7E:
	RTS

EraseSprite:
	%INLINEROUTINE_SMW_EraseExtendedSprite()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr10_SpinJumpStars(Address)
namespace SMW_ExtSpr10_SpinJumpStars
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_ExtSpr10_SpinJumpStars_DespawnTimer,x	;\Some graphics handler
	BEQ.b SMW_ExtSpr0F_SmokeTrail_EraseSprite	;/
	JSR.w SMW_GenericExtendedSpriteGFXRt_Main	;>Base code for extended sprites
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x	;>Get OAM index
	LDA.b #$34			;\YXPPCCCT
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	LDA.b #$EF			;\Tile number
	STA.w SMW_OAMBuffer[$00].Tile,y	;/
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\Don't move if frozen
	BNE.b Return029CAF		;/
	LDA.w !RAM_SMW_ExtSpr10_SpinJumpStars_DespawnTimer,x	;\Some graphics handler
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b !RAM_SMW_Counter_GlobalFrames	;|
	AND.w DATA_029CB0,y		;|
	BNE.b Return029CAF		;/
	JSR.w SMW_UpdateExtendedSpritePosition_X	;\XY speed
	JSR.w SMW_UpdateExtendedSpritePosition_Y	;/
Return029CAF:
	RTS

DATA_029CB0:
	db $FF,$07,$01,$00,$00
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr11_YoshiFireball(Address)
namespace SMW_ExtSpr11_YoshiFireball
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\Frozen = no physics
	BNE.b CODE_029F6E		;/
	JSR.w SMW_UpdateExtendedSpritePosition_X	;\XY speed
	JSR.w SMW_UpdateExtendedSpritePosition_Y	;/
	JSR.w SMW_CheckForPlayerFireballToNormalSpriteCollision_Main	;>Handle fireball
CODE_029F6E:
	JSR.w SMW_GenericExtendedSpriteGFXRt_Main	;>Extended sprite base code
	LDA.b !RAM_SMW_Counter_LocalFrames	;\Alternate tiles based on frame counter
	LSR				;|(uses carry flag %FFFFFFFF -> %FFFFF [C:F])
	LSR				;|
	LSR				;/
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x	;>Get OAM index
	LDA.b #$04
	BCC.b CODE_029F7F
	LDA.b #$2B
CODE_029F7F:
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.w !RAM_SMW_ExtSpr_XSpeed,x	;\X-flip the sprite (YXPPCCCT)
	AND.b #$80			;|so that it faces in the direction
	EOR.b #$80			;|it's going
	LSR				;|
	ORA.b #$35			;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	TYA				;\16x16 sprite
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.b #$02			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtSpr12_BreathBubble(Address)
namespace SMW_ExtSpr12_BreathBubble
%InsertMacroAtXPosition(<Address>)

XDisp:
	db $00,$01,$00,$FF

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	;\Frozen
	BNE.b CODE_029F2A		;/
	INC.w !RAM_SMW_ExtSpr12_BreathBubble_AnimationFrameCounter,x	;\Graphics table
	LDA.w !RAM_SMW_ExtSpr12_BreathBubble_AnimationFrameCounter,x	;|
	AND.b #$30			;|
	BEQ.b CODE_029F08		;/
	DEC.w !RAM_SMW_ExtSpr_YPosLo,x
	LDY.w !RAM_SMW_ExtSpr_YPosLo,x
	INY
	BNE.b CODE_029F08
	DEC.w !RAM_SMW_ExtSpr_YPosHi,x
CODE_029F08:
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCS.b CODE_029F2A
	JSR.w SMW_HandleExtendedSpriteLevelCollision_Main	;\Interact with objects (bubble pops when hitting the bottom of blocks)
	BCS.b CODE_029F27		;/
	LDA.b !RAM_SMW_Flag_UnderwaterLevel	;\If the whole level is water
	BNE.b CODE_029F2A		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\Probably handles water tiles
	CMP.b #$06			;|
	BCC.b CODE_029F2A		;|
	LDA.b !RAM_SMW_Misc_ScratchRAM0F	;|
	BEQ.b CODE_029F27		;|
	LDA.b !RAM_SMW_Misc_ScratchRAM0D	;|
	CMP.b #$06			;|
	BCC.b CODE_029F2A		;/
CODE_029F27:
	JMP.w SMW_GenericExtendedSpriteGFXRt_EraseSprite	;>Delete sprite

CODE_029F2A:
	LDA.w !RAM_SMW_ExtSpr_YPosLo,x	;\Delete if offscreen vertically
	CMP.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	LDA.w !RAM_SMW_ExtSpr_YPosHi,x	;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;|
	BNE.b CODE_029F27		;/
	JSR.w SMW_GenericExtendedSpriteGFXRt_Main	;>Extended sprite base code
	LDA.w !RAM_SMW_ExtSpr12_BreathBubble_AnimationFrameCounter,x	;\$00 = horizontal displacement
	AND.b #$0C			;|
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.w XDisp,y			;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDY.w SMW_ExtendedSpriteOAMIndexes_Main,x	;>Y = OAM index
	LDA.w SMW_OAMBuffer[$00].XDisp,y	;\OAM X position
	CLC				;|
	ADC.b !RAM_SMW_Misc_ScratchRAM00	;|
	STA.w SMW_OAMBuffer[$00].XDisp,y	;/
	LDA.w SMW_OAMBuffer[$00].YDisp,y	;\OAM Y position
	CLC				;|
	ADC.b #$05			;|
	STA.w SMW_OAMBuffer[$00].YDisp,y	;/
	LDA.b #$1C			;\Tile number
	STA.w SMW_OAMBuffer[$00].Tile,y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BounceSpr01_TurnBlock(Address)
namespace SMW_BounceSpr01_TurnBlock
%InsertMacroAtXPosition(<Address>)

YAcceleration:
	db $10,$00,$00,$F0

XAcceleration:
	db $00,$F0,$10,$00

DATA_0290D6:
	db $80,$80,$80,$00

DATA_0290DA:
	db $80,$E0,$20,$80

Main:
	JSR.w SMW_BounceSpriteGFXRt_Main
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b SMW_BounceSpr07_SpinningTurnBlock_Return0290CD
	LDA.w !RAM_SMW_BounceSpr_CurrentStatus,x
	BNE.b CODE_02910B
	INC.w !RAM_SMW_BounceSpr_CurrentStatus,x
	JSR.w SMW_GetBounceSpriteLevelCollisionMap16ID_Main
	JSR.w SMW_SpawnMap16TileFromBounceSprite_InvisibleSolidBlock
	LDA.w !RAM_SMW_BounceSpr_Properties,x
	AND.b #$03
	TAY
	LDA.w DATA_0290D6,y
	CMP.b #$80
	BEQ.b CODE_029102
	STA.b !RAM_SMW_Player_YSpeed
CODE_029102:
	LDA.w DATA_0290DA,y
	CMP.b #$80
	BEQ.b CODE_02910B
	STA.b !RAM_SMW_Player_XSpeed
CODE_02910B:
	JSR.w SMW_UpdateBounceSpritePosition_Y
	JSR.w SMW_UpdateBounceSpritePosition_X
	LDA.w !RAM_SMW_BounceSpr_Properties,x
	AND.b #$03
	TAY
	LDA.w !RAM_SMW_BounceSpr_YSpeed,x
	CLC
	ADC.w YAcceleration,y
	STA.w !RAM_SMW_BounceSpr_YSpeed,x
	LDA.w !RAM_SMW_BounceSpr_XSpeed,x
	CLC
	ADC.w XAcceleration,y
	STA.w !RAM_SMW_BounceSpr_XSpeed,x
	LDA.w !RAM_SMW_BounceSpr_Properties,x
	AND.b #$03
	CMP.b #$03
	BNE.b CODE_02915E
	LDA.b !RAM_SMW_Player_CurrentState
	CMP.b #!Define_SMW_PlayerState01_PowerDown
	BCS.b CODE_02915E
	LDA.b #$20
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_029143
	LDA.b #$30
CODE_029143:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_BounceSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Player_YPosLo
	LDA.w !RAM_SMW_BounceSpr_YPosHi,x
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b #$01
	STA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	STA.w !RAM_SMW_Blocks_NoteBlockBounceFlag
	STZ.b !RAM_SMW_Player_YSpeed
CODE_02915E:
	LDA.w !RAM_SMW_BounceSpr_Timer,x
	BNE.b Return02919C
	LDA.w !RAM_SMW_BounceSpr_Properties,x
	AND.b #$03
	CMP.b #$03
	BNE.b CODE_029182
	LDA.b #$A0
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b !RAM_SMW_Player_YPosLo
	SEC
	SBC.b #$02
	STA.b !RAM_SMW_Player_YPosLo
	LDA.b !RAM_SMW_Player_YPosHi
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	LDA.b #!Define_SMW_Sound1DFC_Springboard	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_029182:
	JSR.w SMW_SpawnMap16TileFromBounceSprite_MultiCoinBlock
	LDY.w !RAM_SMW_BounceSpr_SpriteID,x
	CPY.b #!Define_SMW_SpriteID_BounceSpr06_OnOffBlock
	BCC.b NotOnOffBlock
	; Code for one of two sound effects played when the ON/OFF switch block is
	; hit (the other being at $02881E). This one plays second, once the bounce
	; sprite for the switch finishes its animation. To disable this one, change
	; the first two bytes here to [80 03].
	LDA.b #!Define_SMW_Sound1DF9_ONOFFSwitch	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.w !RAM_SMW_Flag_OnOffSwitch	; \ Toggle On/Off
	EOR.b #$01
	STA.w !RAM_SMW_Flag_OnOffSwitch
NotOnOffBlock:
	STZ.w !RAM_SMW_BounceSpr_SpriteID,x
Return02919C:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_BounceSpr01_TurnBlock_Main, SMW_BounceSpr02_NoteBlock_Main)
	%SetDuplicateOrNullPointer(SMW_BounceSpr01_TurnBlock_Main, SMW_BounceSpr03_QuestionBlock_Main)
	%SetDuplicateOrNullPointer(SMW_BounceSpr01_TurnBlock_Main, SMW_BounceSpr04_SidewaysMovingBlock_Main)
	%SetDuplicateOrNullPointer(SMW_BounceSpr01_TurnBlock_Main, SMW_BounceSpr05_GlassBlock_Main)
	%SetDuplicateOrNullPointer(SMW_BounceSpr01_TurnBlock_Main, SMW_BounceSpr06_OnOffBlock_Main)
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_GetBounceSpriteLevelCollisionMap16ID(Address)
namespace SMW_GetBounceSpriteLevelCollisionMap16ID
%InsertMacroAtXPosition(<Address>)

; INIT routine for most bounce sprites. Mainly used to allow bounce sprites
; to collect a coin directly above them, though the feature is unfinished
; and the coin's replacement tile ends up being a solid block instead of
; empty. Changing $0290ED to [AD] will disable this. $029330 identifies
; which block on page 0 can be collected this way. Keep in mind that this is
; independent of the acts like setting and therefore support for other tiles
; has to be implemented manually.
Main:
	LDA.b #$01
	LDY.w !RAM_SMW_BounceSpr_Properties,x
	STY.b !RAM_SMW_Misc_ScratchRAM0F
	BPL.b CODE_02926F
	ASL
CODE_02926F:
	AND.b !RAM_SMW_Misc_LevelLayoutFlags
	BEQ.b CODE_0292CA
	LDA.w !RAM_SMW_BounceSpr_YPosLo,x
	SEC
	SBC.b #$03
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_BounceSpr_YPosHi,x
	SBC.b #$00
	CMP.b !RAM_SMW_Misc_ScreensInLvl
	BCS.b Return0292C9
	STA.b !RAM_SMW_Misc_ScratchRAM03
	AND.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.w !RAM_SMW_BounceSpr_XPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_BounceSpr_XPosHi,x
	CMP.b #$02
	BCS.b Return0292C9
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_0292B2						; Glitch: This should be BPL.b, not BEQ.b. Otherwise, bounce sprites can collect coins that are not on the same layer as the block or 16 screens away.
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L2,x
CODE_0292B2:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_0292C3						; Glitch: Same as above
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L2,x
CODE_0292C3:
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06
	BRA.b CODE_02931A

Return0292C9:
	RTS

CODE_0292CA:
	LDA.w !RAM_SMW_BounceSpr_YPosLo,x
	SEC
	SBC.b #$03
	AND.b #$F0
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_BounceSpr_YPosHi,x
	SBC.b #$00
	CMP.b #$02
	BCS.b Return0292C9
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_BounceSpr_XPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_BounceSpr_XPosHi,x
	CMP.b !RAM_SMW_Misc_ScreensInLvl
	BCS.b Return0292C9
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_029305						; Glitch: Same as above
	LDA.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L2,x
CODE_029305:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L1,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_029316						; Glitch: Same as above
	LDA.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L2,x
CODE_029316:
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM06
CODE_02931A:
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	INC.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	BNE.b Return029355						; Glitch: This routine does not JSL.l to SMW_ModifyMap16IDForSpecialBlocks_Main, which means coin/used block interaction is incorrect when a P-switch is active.
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	CMP.b #$2B
	BNE.b Return029355
	LDA.w !RAM_SMW_BounceSpr_YPosLo,x
	PHA
	SBC.b #$03
	AND.b #$F0
	STA.w !RAM_SMW_BounceSpr_YPosLo,x
	LDA.w !RAM_SMW_BounceSpr_YPosHi,x
	PHA
	SBC.b #$00
	STA.w !RAM_SMW_BounceSpr_YPosHi,x
	JSR.w SMW_SpawnMap16TileFromBounceSprite_InvisibleSolidBlock	;\ Glitch: This causes a bug where coins collected by hitting the block below causes the space occupied by the coin to become solid.
									;/ The fix for this would be to load #$02 into A, then JSR.w to SMW_SpawnMap16TileFromBounceSprite_Main
	JSR.w ADDR_029356
	PLA
	STA.w !RAM_SMW_BounceSpr_YPosHi,x
	PLA
	STA.w !RAM_SMW_BounceSpr_YPosLo,x
Return029355:
	RTS

; Code that generates a spinning coin at the position of a bounce sprite.
; This is used to be able to collect a coin with a bounce block, though this
; routine doesn't handle actual removal of the coin (which is handled
; instead by $0291B8).
ADDR_029356:
	LDY.b #!Define_SMW_MaxSpinningCoinSpriteSlot
ADDR_029358:
	LDA.w !RAM_SMW_BlockCoinSpr_SlotID,y
	BEQ.b ADDR_029361
	DEY
	BPL.b ADDR_029358
	INY
ADDR_029361:
	LDA.b #$01
	STA.w !RAM_SMW_BlockCoinSpr_SlotID,y
	JSL.l SMW_GiveCoins_OneCoin
	LDA.w !RAM_SMW_BounceSpr_XPosLo,x
	STA.w !RAM_SMW_BlockCoinSpr_XPosLo,y
	LDA.w !RAM_SMW_BounceSpr_XPosHi,x
	STA.w !RAM_SMW_BlockCoinSpr_XPosHi,y
	LDA.w !RAM_SMW_BounceSpr_YPosLo,x
	STA.w !RAM_SMW_BlockCoinSpr_YPosLo,y
	LDA.w !RAM_SMW_BounceSpr_YPosHi,x
	STA.w !RAM_SMW_BlockCoinSpr_YPosHi,y
	LDA.w !RAM_SMW_BounceSpr_Properties,x
	ASL
	ROL
	AND.b #$01
	STA.w !RAM_SMW_BlockCoinSpr_LayerIndex,y
	LDA.b #$D0
	STA.w !RAM_SMW_BlockCoinSpr_YSpeed,y
Return029391:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BounceSpr07_SpinningTurnBlock(Address)
namespace SMW_BounceSpr07_SpinningTurnBlock
%InsertMacroAtXPosition(<Address>)

YAcceleration:
	db $13,$00,$00,$ED

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Return if sprites locked
	BNE.b Return0290CD
	LDA.w !RAM_SMW_BounceSpr_CurrentStatus,x	; \ Initialize only once
	BNE.b CODE_029085		; | (Generate invisible tile sprite)
	INC.w !RAM_SMW_BounceSpr_CurrentStatus,x
	JSR.w SMW_SpawnMap16TileFromBounceSprite_InvisibleSolidBlock
CODE_029085:
	LDA.w !RAM_SMW_BounceSpr_Timer,x
	BEQ.b CODE_0290BB
	CMP.b #$01
	BNE.b CODE_0290A8
	LDA.w !RAM_SMW_BounceSpr_YPosLo,x
	CLC
	ADC.b #$08
	AND.b #$F0
	STA.w !RAM_SMW_BounceSpr_YPosLo,x
	LDA.w !RAM_SMW_BounceSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_BounceSpr_YPosHi,x
	LDA.b #$05
	JSR.w SMW_SpawnMap16TileFromBounceSprite_Main
	BRA.b CODE_0290BB

CODE_0290A8:
	JSR.w SMW_UpdateBounceSpritePosition_Y
	LDY.w !RAM_SMW_BounceSpr_Properties,x
	LDA.w !RAM_SMW_BounceSpr_YSpeed,x
	CLC
	ADC.w YAcceleration,y
	STA.w !RAM_SMW_BounceSpr_YSpeed,x
	JSR.w SMW_BounceSpriteGFXRt_Main
CODE_0290BB:
	LDA.w !RAM_SMW_BounceSpr07_SpinningTurnBlock_DespawnTimer,x
	BEQ.b CODE_0290C4
	; Decrements the timers used by spinning turn blocks to determine how long
	; they should spin. Change to [EA EA EA] to make the last four turn blocks
	; Mario has hit spin forever.
	DEC.w !RAM_SMW_BounceSpr07_SpinningTurnBlock_DespawnTimer,x
	RTS

CODE_0290C4:
	LDA.w !RAM_SMW_BounceSpr_Map16TileToSpawn,x
	JSR.w SMW_SpawnMap16TileFromBounceSprite_Main
	STZ.w !RAM_SMW_BounceSpr_SpriteID,x
Return0290CD:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessScoreSprites(Address)
namespace SMW_ProcessScoreSprites
%InsertMacroAtXPosition(<Address>)

LeftTiles:
	db $00		; N/A
	; Tiles used by Floating Point Notations, 1UPs, 2UPs, etc. 1st half.
	db $83		; 10 Points
	db $83		; 20 Points
	db $83		; 40 Points
	db $83		; 80 Points
	db $44		; 100 Points
	db $54		; 200 Points
	db $46		; 400 Points
	db $47		; 800 Points
	db $44		; 1000 Points
	db $54		; 2000 Points
	db $46		; 4000 Points
	db $47		; 8000 Points
	db $56		; 1-Up
	db $29		; 2-Up
	db $39		; 3-Up
	db $38		; 5-Up
	db $5E		; 5 Coins
	db $5E		; 10 Coins
	db $5E		; 15 Coins
	db $5E		; 20 Coins
	db $5E		; 25 Coins

RightTiles:
	db $00		; N/A
	; Tiles used by Floating Point Notations, 1UPs, 2UPs, etc. 2nd half
	db $44		; 10 Points
	db $54		; 20 Points
	db $46		; 40 Points
	db $47		; 80 Points
	db $45		; 100 Points
	db $45		; 200 Points
	db $45		; 400 Points
	db $45		; 800 Points
	db $55		; 1000 Points
	db $55		; 2000 Points
	db $55		; 4000 Points
	db $55		; 8000 Points
	db $57		; 1-Up
	db $57		; 2-Up
	db $57		; 3-Up
	db $57		; 5-Up
	db $4E		; 5 Coins
	db $44		; 10 Coins
	db $4F		; 15 Coins
	db $54		; 20 Coins
	db $5D		; 25 Coins

; Score added from score sprites, divided by 10 (low byte)
PointMultiplierLo:
	db $00		; N/A
	db $01		; 10 Points
	db $02		; 20 Points
	db $04		; 40 Points
	db $08		; 80 Points
	db $0A		; 100 Points
	db $14		; 200 Points
	db $28		; 400 Points
	db $50		; 800 Points
	db $64		; 1000 Points
	db $C8		; 2000 Points
	db $90		; 4000 Points
	db $20		; 8000 Points
	db $00		; 1-Up
	db $00		; 2-Up
	db $00		; 3-Up
	db $00		; 5-Up

; Score added from score sprites, divided by 10 (high byte)
PointMultiplierHi:
	db $00		; N/A
	db $00		; 10 Points
	db $00		; 20 Points
	db $00		; 40 Points
	db $00		; 80 Points
	db $00		; 100 Points
	db $00		; 200 Points
	db $00		; 400 Points
	db $00		; 800 Points
	db $00		; 1000 Points
	db $00		; 2000 Points
	db $01		; 4000 Points
	db $03		; 8000 Points
	db $00		; 1-Up
	db $00		; 2-Up
	db $00		; 3-Up
	db $00		; 5-Up

; point rise speed
UpdateSpeedFrameIndex:
	db $03,$01,$00,$00

; OAM indexes for score sprites.
OAMIndex:
	db $B0,$B8,$C0,$C8,$D0,$D8

Main:
;$02ADA4
	; The main routine for all score sprites. This handles graphics, giving
	; lives/points/1-ups/coins, position updating, etc. $02ADD9 is how many
	; lives 1up Mushrooms give you. $02ADDA is how many lives 2up gives you.
	; $02ADDB is how many lives 3up Moons give you. $02ADDC is how many lives
	; 5up gives you. $02ADDD is how many coins you get from the (unused) x5,
	; x10, x15, x20, and x25 coin sprites. $02ADE2 is the attributes of 2up &
	; 3up score sprites. The unused 5up sprites and coin sprites read past this
	; table. You can change $02AE03 to A9 xx EA to make 1up Mushrooms and 3up
	; Moons give you xx lives.
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_02ADB8
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	CMP.b #$C1
	BEQ.b Return02ADC8
	LDA.b #$F0
	STA.w SMW_OAMBuffer[$01].YDisp
	STA.w SMW_OAMBuffer[$02].YDisp
CODE_02ADB8:
	LDX.b #!Define_SMW_MaxScoreSpriteSlot
CODE_02ADBA:
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
	LDA.w !RAM_SMW_ScoreSpr_SpriteID,x
	BEQ.b CODE_02ADC5
	JSR.w Sub
CODE_02ADC5:
	DEX
	BPL.b CODE_02ADBA
Return02ADC8:
	RTS

Sub:
;$02ADC9
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BEQ.b CODE_02ADD0
	JMP.w CODE_02AE5B

CODE_02ADD0:
	LDA.w !RAM_SMW_ScoreSpr_YSpeed,x
	BNE.b CODE_02ADE4
	STZ.w !RAM_SMW_ScoreSpr_SpriteID,x
	RTS

LivesToGive:
	db $01		; 1up
	db $02		; 2up
	db $03		; 3up
	db $05		; 5up

CoinsToGive:
	db $05		; 5 Coins
	db $0A		; 10 Coins
	db $0F		; 15 Coins
	db $14		; 20 Coins
	db $19		; 25 Coins

TwoUp3UpProp:						;\ Glitch: The 5-up sprite has garbage properties due to this table not being 3 bytes
	db $04,$06					;/ If you're wondering, it used #$DE, which is the hex value of the DEC.w absolute,x opcode below.

CODE_02ADE4:
	DEC.w !RAM_SMW_ScoreSpr_YSpeed,x
	CMP.b #$2A
	BNE.b CODE_02AE38
	LDY.w !RAM_SMW_ScoreSpr_SpriteID,x
	CPY.b #$0D
	BCC.b CODE_02AE12
	CPY.b #$11
	BCC.b CODE_02AE03
	PHX
	PHY
	LDA.w CoinsToGive-$11,y		; Hey, this label might be wrong!
	JSL.l SMW_GiveCoins_MultipleCoins
	PLY
	PLX
	BRA.b CODE_02AE12

CODE_02AE03:
	LDA.w LivesToGive-$0D,y		; Hey, this label might be wrong!
	CLC
	ADC.w !RAM_SMW_Misc_1upHandler
	STA.w !RAM_SMW_Misc_1upHandler
	STZ.w !RAM_SMW_Timer_Give1up
	BRA.b CODE_02AE35

CODE_02AE12:
	LDA.w !RAM_SMW_Player_CurrentCharacter
	ASL
	ADC.w !RAM_SMW_Player_CurrentCharacter
	TAX
	LDA.w !RAM_SMW_Player_MarioScoreLo,x
	CLC
	ADC.w PointMultiplierLo,y
	STA.w !RAM_SMW_Player_MarioScoreLo,x
	LDA.w !RAM_SMW_Player_MarioScoreMid,x
	ADC.w PointMultiplierHi,y
	STA.w !RAM_SMW_Player_MarioScoreMid,x
	LDA.w !RAM_SMW_Player_MarioScoreHi,x
	ADC.b #$00
	STA.w !RAM_SMW_Player_MarioScoreHi,x
CODE_02AE35:
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
CODE_02AE38:
	LDA.w !RAM_SMW_ScoreSpr_YSpeed,x
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w UpdateSpeedFrameIndex,y
	BNE.b CODE_02AE5B
	LDA.w !RAM_SMW_ScoreSpr_YPosLo,x
	TAY
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$04
	BCC.b CODE_02AE5B
	DEC.w !RAM_SMW_ScoreSpr_YPosLo,x
	TYA
	BNE.b CODE_02AE5B
	DEC.w !RAM_SMW_ScoreSpr_YPosHi,x
CODE_02AE5B:
	LDA.w !RAM_SMW_ScoreSpr_LayerIndex,x
	ASL
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Mirror_CurrentLayer1YPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Mirror_CurrentLayer1XPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_ScoreSpr_XPosLo,x
	CLC
	ADC.b #$0C
	PHP
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_ScoreSpr_XPosHi,x
	SBC.b !RAM_SMW_Misc_ScratchRAM05
	PLP
	ADC.b #$00
	BNE.b Return02AEFB
	LDA.w !RAM_SMW_ScoreSpr_XPosLo,x
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_ScoreSpr_XPosHi,x
	SBC.b !RAM_SMW_Misc_ScratchRAM05
	BNE.b Return02AEFB
	LDA.w !RAM_SMW_ScoreSpr_YPosLo,x
	CMP.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_ScoreSpr_YPosHi,x
	SBC.b !RAM_SMW_Misc_ScratchRAM03
	BNE.b Return02AEFB
	LDY.w OAMIndex,x
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_02AEA5
	LDY.b #$04
CODE_02AEA5:
	LDA.w !RAM_SMW_ScoreSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$00].YDisp,y
	STA.w SMW_OAMBuffer[$01].YDisp,y
	LDA.w !RAM_SMW_ScoreSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM04
	STA.w SMW_OAMBuffer[$00].XDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$01].XDisp,y
	PHX
	LDA.w !RAM_SMW_ScoreSpr_SpriteID,x
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l LeftTiles,x
else
	LDA.w LeftTiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l RightTiles,x
else
	LDA.w RightTiles,x
endif
	STA.w SMW_OAMBuffer[$01].Tile,y
	PLX
	PHY
	LDY.w !RAM_SMW_ScoreSpr_SpriteID,x
	CPY.b #$0E
	LDA.b #$08
	BCC.b CODE_02AEDF
	LDA.w TwoUp3UpProp-$0E,y	; Hey, this label might be wrong!
CODE_02AEDF:
	PLY
	ORA.b #$30
	STA.w SMW_OAMBuffer[$00].Prop,y
	STA.w SMW_OAMBuffer[$01].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$01].Slot,y
	LDA.w !RAM_SMW_ScoreSpr_SpriteID,x
	CMP.b #$11
	BCS.b ADDR_02AEFC
Return02AEFB:
	RTS

ADDR_02AEFC:
	LDY.b #$4C
	LDA.w !RAM_SMW_ScoreSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM04
	SEC
	SBC.b #$08
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_ScoreSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b #$5F
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b #$04
	ORA.b #$30
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	RTS

ADDR_02AF29:								; Note: Unused code
	STZ.w !RAM_SMW_ScoreSpr_SpriteID,x	; \ Unreachable
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SmokeSpr01_PuffOfSmoke(Address)
namespace SMW_SmokeSpr01_PuffOfSmoke
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $66,$66,$64,$62,$60,$62,$60

EraseSprite2:
	%INLINEROUTINE_SMW_EraseSmokeSprite()

Main:
;$0296E3
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	BEQ.b EraseSprite2
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,x				;\ Note: Smoke sprite 81 is this sprite during the get cape animation.
	BMI.b CODE_0296F1						;/
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_0296F4
CODE_0296F1:
	DEC.w !RAM_SMW_SmokeSpr_Timer,x
CODE_0296F4:
if defined("Define_SMW_SA1")
	LDA.w !RAM_SMW_Flag_ReznorRoomOAMIndexTimer
	BNE.b CODE_02974A
	NOP
else
	LDA.b !RAM_SMW_NorSpr_SpriteID+$07
	CMP.b #!Define_SMW_SpriteID_NorSpr0A9_Reznor
	BEQ.b CODE_02974A
endif
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	AND.b #$40
	BEQ.b CODE_02974A
	LDY.w SMW_SmokeSpriteOAMIndexes_Two,x
	LDA.w !RAM_SMW_SmokeSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b #$F4
	BCS.b EraseSprite2
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w !RAM_SMW_SmokeSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$E0
	BCS.b EraseSprite2
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	CMP.b #$08
	LDA.b #$00
	BCS.b CODE_02972D
	ASL
	ASL
	ASL
	ASL
	AND.b #$40
CODE_02972D:
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	PHY
	LSR
	LSR
	TAY
	LDA.w Tiles,y
	PLY
	STA.w SMW_OAMBuffer[$40].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	RTS

CODE_02974A:
	LDY.w SMW_SmokeSpriteOAMIndexes_One,x
	LDA.w !RAM_SMW_SmokeSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b #$F4
	BCS.b EraseSprite
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_SmokeSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$E0
	BCS.b EraseSprite
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	CMP.b #$08
	LDA.b #$00
	BCS.b CODE_029776
	ASL
	ASL
	ASL
	ASL
	AND.b #$40
CODE_029776:
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	PHY
	LSR
	LSR
	TAY
	LDA.w Tiles,y
	PLY
	STA.w SMW_OAMBuffer[$00].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	RTS

EraseSprite:
	%INLINEROUTINE_SMW_EraseSmokeSprite()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SmokeSpr02_ContactEffect(Address)
namespace SMW_SmokeSpr02_ContactEffect
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	BEQ.b SMW_SmokeSpr01_PuffOfSmoke_EraseSprite
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_0297A3
	DEC.w !RAM_SMW_SmokeSpr_Timer,x
CODE_0297A3:
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_0297B2
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	CMP.b #$C1
	BEQ.b CODE_0297B2
	JMP.w CODE_029838

CODE_0297B2:
	LDY.b #$F0
	LDA.w !RAM_SMW_SmokeSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b #$F0
	BCS.b SMW_SmokeSpr01_PuffOfSmoke_EraseSprite
	STA.w SMW_OAMBuffer[$00].XDisp,y
	STA.w SMW_OAMBuffer[$02].XDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$01].XDisp,y
	STA.w SMW_OAMBuffer[$03].XDisp,y
	LDA.w !RAM_SMW_SmokeSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$00].YDisp,y
	STA.w SMW_OAMBuffer[$01].YDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$02].YDisp,y
	STA.w SMW_OAMBuffer[$03].YDisp,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	ASL
	ASL
	ASL
	ASL
	ASL
	AND.b #$40
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	STA.w SMW_OAMBuffer[$01].Prop,y
	EOR.b #$C0
	STA.w SMW_OAMBuffer[$02].Prop,y
	STA.w SMW_OAMBuffer[$03].Prop,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	AND.b #$02
	BNE.b CODE_029815
	LDA.b #$7C
	STA.w SMW_OAMBuffer[$00].Tile,y
	STA.w SMW_OAMBuffer[$03].Tile,y
	LDA.b #$7D
	STA.w SMW_OAMBuffer[$01].Tile,y
	STA.w SMW_OAMBuffer[$02].Tile,y
	BRA.b CODE_029825					; Optimization: Move this BRA.b to before the "LDA.b #$7D" and point it 11 bytes ahead to save 6 bytes.

CODE_029815:
	LDA.b #$7D
	STA.w SMW_OAMBuffer[$00].Tile,y
	STA.w SMW_OAMBuffer[$03].Tile,y
	LDA.b #$7C
	STA.w SMW_OAMBuffer[$01].Tile,y
	STA.w SMW_OAMBuffer[$02].Tile,y
CODE_029825:
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$01].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$02].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$03].Slot,y
	RTS

CODE_029838:
	LDY.b #$90
	LDA.w !RAM_SMW_SmokeSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b #$F0
	BCS.b EraseSprite
	STA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$42].XDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$41].XDisp,y
	STA.w SMW_OAMBuffer[$43].XDisp,y
	LDA.w !RAM_SMW_SmokeSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$41].YDisp,y
	CLC
	ADC.b #$08
	STA.w SMW_OAMBuffer[$42].YDisp,y
	STA.w SMW_OAMBuffer[$43].YDisp,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	ASL
	ASL
	ASL
	ASL
	ASL
	AND.b #$40
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$41].Prop,y
	EOR.b #$C0
	STA.w SMW_OAMBuffer[$42].Prop,y
	STA.w SMW_OAMBuffer[$43].Prop,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	AND.b #$02
	BNE.b CODE_02989B
	LDA.b #$7C
	STA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$43].Tile,y
	LDA.b #$7D
	STA.w SMW_OAMBuffer[$41].Tile,y
	STA.w SMW_OAMBuffer[$42].Tile,y
	BRA.b CODE_0298AB					; Optimization: Move this BRA.b to before the "LDA.b #$7D" and point it 11 bytes ahead to save 6 bytes.

CODE_02989B:
	LDA.b #$7D
	STA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$43].Tile,y
	LDA.b #$7C
	STA.w SMW_OAMBuffer[$41].Tile,y
	STA.w SMW_OAMBuffer[$42].Tile,y
CODE_0298AB:
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$41].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$42].Slot,y
	STA.w SMW_OAMTileSizeBuffer[$43].Slot,y
	RTS

EraseSprite:
	%INLINEROUTINE_SMW_EraseSmokeSprite()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SmokeSpr03_TurnAroundSmoke(Address)
namespace SMW_SmokeSpr03_TurnAroundSmoke
%InsertMacroAtXPosition(<Address>)

; Mario/Luigi's trail of smoke tilemap. It uses palette 8.
Tiles:
	db $66,$66,$64,$62,$62

Main:
;$029927
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	BNE.b CODE_029941
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_02993E
	LDA.w !RAM_SMW_Flag_ReznorRoomOAMIndexTimer
	BNE.b CODE_02993E
	LDY.w SMW_SmokeSpriteOAMIndexes_Two,x
	LDA.b #$F0
	STA.w SMW_OAMBuffer[$40].YDisp,y
CODE_02993E:
	JMP.w SMW_SmokeSpr01_PuffOfSmoke_EraseSprite

CODE_029941:
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02994F
	DEC.w !RAM_SMW_SmokeSpr_Timer,x
	AND.b #$07
	BNE.b CODE_02994F
	DEC.w !RAM_SMW_SmokeSpr_YPosLo,x
CODE_02994F:
if defined("Define_SMW_SA1")
	NOP #6
else
	LDA.b !RAM_SMW_NorSpr_SpriteID+$07
	CMP.b #!Define_SMW_SpriteID_NorSpr0A9_Reznor
	BEQ.b CODE_02996C
endif
	LDA.w !RAM_SMW_Flag_ReznorRoomOAMIndexTimer
	BNE.b CODE_02996C
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	BPL.b CODE_02996C
	CMP.b #$C1
	BEQ.b CODE_029967
	AND.b #$40
	BNE.b CODE_02999F
CODE_029967:
	LDY.w SMW_SmokeSpriteOAMIndexes_Two,x
	BRA.b CODE_02996F

CODE_02996C:
	LDY.w SMW_SmokeSpriteOAMIndexes_One,x
CODE_02996F:
	LDA.w !RAM_SMW_SmokeSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_SmokeSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	LSR
	LSR
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	STA.w SMW_OAMBuffer[$00].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	RTS

CODE_02999F:
	LDY.w SMW_SmokeSpriteOAMIndexes_Two,x
	LDA.w !RAM_SMW_SmokeSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w !RAM_SMW_SmokeSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$40].Prop,y
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	LSR
	LSR
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	STA.w SMW_OAMBuffer[$40].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SmokeSpr05_Glitter(Address)
namespace SMW_SmokeSpr05_Glitter
%InsertMacroAtXPosition(<Address>)

DATA_0298C2:
	db $04,$08,$04,$00

DATA_0298C6:
	db $FC,$04,$0C,$04

Main:
;$0298CA
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	BEQ.b SMW_SmokeSpr02_ContactEffect_EraseSprite
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return029921
	DEC.w !RAM_SMW_SmokeSpr_Timer,x
	AND.b #$03
	BNE.b Return029921
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot
CODE_0298DC:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y
	BEQ.b CODE_0298F1
	DEY
	BPL.b CODE_0298DC
	DEC.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
	BPL.b CODE_0298EE
	LDA.b #!Define_SMW_MaxMinorExtendedSpriteSlot
	STA.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
CODE_0298EE:
	LDY.w !RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull
CODE_0298F1:
	LDA.b #!Define_SMW_SpriteID_MExtSpr02_SmallStar
	STA.w !RAM_SMW_MExtSpr_SpriteID,y
	LDA.w !RAM_SMW_SmokeSpr_YPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_SmokeSpr_XPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_SmokeSpr_Timer,x
	LSR
	LSR
	AND.b #$03
	PHX
	TAX
	LDA.w DATA_0298C2,x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_MExtSpr_XPosLo,y
	LDA.w DATA_0298C6,x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_MExtSpr_YPosLo,y
	PLX
	LDA.b #$17
	STA.w !RAM_SMW_MExtSpr_Timer,y
Return029921:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_MExtSpr01_BrickPiece(Address)
namespace SMW_MExtSpr01_BrickPiece
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_028FCA
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BEQ.b CODE_028FAB
	LDY.b #$00
	LDA.w !RAM_SMW_MExtSpr_XSpeed,x
	BPL.b CODE_028F9D
	DEY
CODE_028F9D:
	CLC
	ADC.w !RAM_SMW_MExtSpr_XPosLo,x
	STA.w !RAM_SMW_MExtSpr_XPosLo,x
	TYA
	ADC.w !RAM_SMW_MExtSpr_XPosHi,x
	STA.w !RAM_SMW_MExtSpr_XPosHi,x
CODE_028FAB:
	LDY.b #$00
	LDA.w !RAM_SMW_MExtSpr_YSpeed,x
	BPL.b CODE_028FB3
	DEY
CODE_028FB3:
	CLC
	ADC.w !RAM_SMW_MExtSpr_YPosLo,x
	STA.w !RAM_SMW_MExtSpr_YPosLo,x
	TYA
	ADC.w !RAM_SMW_MExtSpr_YPosHi,x
	STA.w !RAM_SMW_MExtSpr_YPosHi,x
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_028FCA
	INC.w !RAM_SMW_MExtSpr_YSpeed,x
CODE_028FCA:
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_MExtSpr_YPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	BEQ.b CODE_028FDD
	BPL.b SMW_MExtSpr04_PodobooFire_EraseSprite
	BMI.b Return02902C							; Optimization: RTS?

CODE_028FDD:
	LDY.w SMW_MinorExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_MExtSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b SMW_MExtSpr04_PodobooFire_EraseSprite
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$F0
	BCS.b SMW_MExtSpr04_PodobooFire_EraseSprite
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	PHA
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	CLC
	ADC.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	AND.b #$07
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	PLA
	BEQ.b CODE_029018
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$0E
CODE_029018:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	EOR.l Flip,x
else
	EOR.w Flip,x
endif
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
Return02902C:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_MExtSpr01_BrickPiece(Address)
namespace SMW_MExtSpr01_BrickPiece
%InsertMacroAtXPosition(<Address>)

; Sprite mappings for Broken Bricks, Broken Turn blocks, and Broken Throw
; Blocks
Tiles:
	db $3C,$3D,$3D,$3C,$3C,$3D,$3D,$3C

; Broken Brick tile properties, YXPPCCCT format.
Flip:
	db $00,$00,$80,$80,$80,$C0,$40,$00
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MExtSpr02_SmallStar(Address)
namespace SMW_MExtSpr02_SmallStar
%InsertMacroAtXPosition(<Address>)

; Star Mario's Sparkle Tiles
Tiles:
	db $66,$6E,$FF,$6D,$6C,$5C

Main:
;$028ED2
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	BNE.b CODE_028EDA
EraseSprite:
	JMP.w SMW_MExtSpr04_PodobooFire_EraseSprite

CODE_028EDA:
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_028EE1
	DEC.w !RAM_SMW_MExtSpr_Timer,x
CODE_028EE1:
	LDY.w SMW_MinorExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b #$F0
	BCS.b EraseSprite
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$F0
	BCS.b EraseSprite
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w !RAM_SMW_MExtSpr_SpriteID,x
	PHA
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	LSR
	LSR
	LSR
	TAX
	PLA
	CMP.b #!Define_SMW_SpriteID_MExtSpr05_SmallStar
	BNE.b CODE_028F11
	INX
	INX
	INX
CODE_028F11:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$06
	STA.w SMW_OAMBuffer[$00].Prop,y
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_MExtSpr02_SmallStar_Main, SMW_MExtSpr05_SmallStar_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MExtSpr03_EggShell(Address)
namespace SMW_MExtSpr03_EggShell
%InsertMacroAtXPosition(<Address>)

UNK_028E7A:							;\ Note: Seems like this may have been tile Property data for some sprite.
	db $03,$43,$83,$C3					;/

Main:
	DEC.w !RAM_SMW_MExtSpr_Timer,x
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	AND.b #$3F
	BEQ.b SMW_MExtSpr02_SmallStar_EraseSprite
	JSR.w SMW_UpdateMinorExtendedSpritePosition_X
	JSR.w SMW_UpdateMinorExtendedSpritePosition_Y
	INC.w !RAM_SMW_MExtSpr_YSpeed,x
	INC.w !RAM_SMW_MExtSpr_YSpeed,x
	LDY.w SMW_MinorExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$F0
	BCS.b SMW_MExtSpr02_SmallStar_EraseSprite
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b #$F8
	BCS.b SMW_MExtSpr02_SmallStar_EraseSprite
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.b #$6F
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	AND.b #$C0
	ORA.b #$03
	ORA.b !RAM_SMW_Sprites_TilePriority
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MExtSpr04_PodobooFire(Address)
namespace SMW_MExtSpr04_PodobooFire
%InsertMacroAtXPosition(<Address>)

Tiles:
	%INLINEDATATABLE_SMW_LavaSplashTileNumbers()

Main:
;$028F2F
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.w !RAM_SMW_MExtSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b EraseSprite
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	BEQ.b EraseSprite
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_028F4D
	DEC.w !RAM_SMW_MExtSpr_Timer,x
	JSR.w SMW_UpdateMinorExtendedSpritePosition_Y
	INC.w !RAM_SMW_MExtSpr_YSpeed,x
CODE_028F4D:
	LDY.w SMW_MinorExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	CMP.b #$F0
	BCS.b EraseSprite
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	LSR
	LSR
	LSR
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$05
	STA.w SMW_OAMBuffer[$00].Prop,y
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	RTS

EraseSprite:
	%INLINEROUTINE_SMW_EraseMinorExtendedSprite()
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MExtSpr06_RipVanFishZ(Address)
namespace SMW_MExtSpr06_RipVanFishZ
%InsertMacroAtXPosition(<Address>)

; Tiles used by Rip Van Fish's Z's
Tiles:
	db $F1,$F0,$E1,$E0

Main:
;$028DDB
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_028E20
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	BEQ.b CODE_028DE7
	DEC.w !RAM_SMW_MExtSpr_Timer,x
CODE_028DE7:
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	AND.b #$00							;\ Optimization: I don't think this will ever branch...
	BNE.b CODE_028DFE						;/
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	INC.w !RAM_SMW_MExtSpr_XSpeed,x
	AND.b #$10
	BNE.b CODE_028DFE
	DEC.w !RAM_SMW_MExtSpr_XSpeed,x
	DEC.w !RAM_SMW_MExtSpr_XSpeed,x
CODE_028DFE:
	LDA.w !RAM_SMW_MExtSpr_XSpeed,x
	PHA
	LDY.w !RAM_SMW_MExtSpr_SpriteID,x
	CPY.b #!Define_SMW_SpriteID_MExtSpr09_UnusedMusicNote
	BNE.b CODE_028E0F
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_MExtSpr_XSpeed,x
CODE_028E0F:
	JSR.w SMW_UpdateMinorExtendedSpritePosition_X
	PLA
	STA.w !RAM_SMW_MExtSpr_XSpeed,x
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	AND.b #$03
	BNE.b CODE_028E20
	DEC.w !RAM_SMW_MExtSpr_YPosLo,x
CODE_028E20:
	LDY.w SMW_MinorExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b #$08
	BCC.b EraseSprite
	CMP.b #$FC
	BCS.b EraseSprite
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$F0
	BCS.b EraseSprite
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$03
	STA.w SMW_OAMBuffer[$00].Prop,y
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	CMP.b #$14
	BEQ.b EraseSprite
	LDA.w !RAM_SMW_MExtSpr_SpriteID,x
	CMP.b #!Define_SMW_SpriteID_MExtSpr08_UnusedMusicNote
	LDA.b #$7F
	BCS.b CODE_028E66
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	LSR
	LSR
	LSR
	LSR
	LSR
	AND.b #$03
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
CODE_028E66:
	STA.w SMW_OAMBuffer[$00].Tile,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	RTS

EraseSprite:
	%INLINEROUTINE_SMW_EraseMinorExtendedSprite()
namespace off
	%SetDuplicateOrNullPointer(SMW_MExtSpr06_RipVanFishZ_Main, SMW_MExtSpr08_UnusedMusicNote_Main)
	%SetDuplicateOrNullPointer(SMW_MExtSpr06_RipVanFishZ_Main, SMW_MExtSpr09_UnusedMusicNote_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MExtSpr07_WaterSplash(Address)
namespace SMW_MExtSpr07_WaterSplash
%InsertMacroAtXPosition(<Address>)

; Water Splash Tilemap
Tiles:
	db $68,$68,$6A,$6A,$6A,$62,$62,$62
	db $64,$64,$64,$64,$66

Main:
;$028D4F
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.w !RAM_SMW_MExtSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b EraseSprite
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	CMP.b #$20
	BNE.b CODE_028D66
EraseSprite:
	%INLINEROUTINE_SMW_EraseMinorExtendedSprite()

CODE_028D66:
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	CMP.b #$10
	BCC.b CODE_028D8B
	AND.b #$01
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_028D75
	INC.w !RAM_SMW_MExtSpr_YPosLo,x
CODE_028D75:
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	SEC
	SBC.b #$10
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	BCC.b CODE_028D89
	EOR.b #$FF
	INC
CODE_028D89:
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_028D8B:
	LDY.w SMW_MinorExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CMP.b #$F0
	BCS.b EraseSprite
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$E8
	BCS.b EraseSprite
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	LSR
	TAX
	CPX.b #$0C
	BCC.b CODE_028DB6
	LDX.b #$0C
CODE_028DB6:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	LDX.w !RAM_SMW_Sprites_CurrentlyProcessedMiscSprite
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$02
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return028DD6
	INC.w !RAM_SMW_MExtSpr_Timer,x
Return028DD6:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MExtSpr0A_BooStream(Address)
namespace SMW_MExtSpr0A_BooStream
%InsertMacroAtXPosition(<Address>)

; Reflecting Stream of Boo Buddies tilemap (Boos that follow the leader)
Tiles:
	db $88,$A8,$AA,$8C,$8E,$AE,$88,$A8
	db $AA,$8C,$8E,$AE

Main:
;$028CC4
	; The code for the minor extended sprites that make up the Boo stream.
	; $028D34 is palette and GFX page of the following Boos in the Boo stream.
	; (If you use the default palettes, changing this to 03 won't have any
	; effect, since the proper palette setting for the sprite (palette F) uses
	; the same colors as palette 9.)
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_028CFF
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_MExtSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.w !RAM_SMW_MExtSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	LDA.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM06
	STA.b !RAM_SMW_Misc_ScratchRAM07
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b CODE_028CFA
	JSL.l SMW_DamagePlayer_Hurt
CODE_028CFA:
	DEC.w !RAM_SMW_MExtSpr_Timer,x
	BEQ.b SMW_MExtSpr07_WaterSplash_EraseSprite
CODE_028CFF:
	LDY.w SMW_MinorExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_MExtSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b Return028D41
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$F0
	BCS.b SMW_MExtSpr07_WaterSplash_EraseSprite
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.w !RAM_SMW_MExtSpr_XSpeed,x
	LSR
	AND.b #$40
	EOR.b #$40
	ORA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$0F
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
Return028D41:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_MExtSpr0B_UnusedYoshiSmoke(Address)
namespace SMW_MExtSpr0B_UnusedYoshiSmoke
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	BNE.b ADDR_028C61
	LDA.w !RAM_SMW_MExtSpr_XSpeed,x
	BEQ.b EraseSprite
	BPL.b ADDR_028C20
	CLC
	ADC.b #$08
	BRA.b ADDR_028C23

ADDR_028C20:
	SEC
	SBC.b #$08
ADDR_028C23:
	STA.w !RAM_SMW_MExtSpr_XSpeed,x
	JSR.w SMW_UpdateMinorExtendedSpritePosition_X
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b Return028C60
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot
ADDR_028C32:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y
	BEQ.b ADDR_028C3B
	DEY
	BPL.b ADDR_028C32
	RTS

ADDR_028C3B:
	LDA.b #!Define_SMW_SpriteID_MExtSpr0B_UnusedYoshiSmoke
	STA.w !RAM_SMW_MExtSpr_SpriteID,y
	STA.w !RAM_SMW_MExtSpr_YSpeed,y
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	STA.w !RAM_SMW_MExtSpr_XPosLo,y
	LDA.w !RAM_SMW_MExtSpr_XPosHi,x
	STA.w !RAM_SMW_MExtSpr_XPosHi,y
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	STA.w !RAM_SMW_MExtSpr_YPosLo,y
	LDA.w !RAM_SMW_MExtSpr_YPosHi,x
	STA.w !RAM_SMW_MExtSpr_YPosHi,y
	LDA.b #$10
	STA.w !RAM_SMW_MExtSpr_Timer,y
Return028C60:
	RTS

ADDR_028C61:
	DEC.w !RAM_SMW_MExtSpr_Timer,x
	BNE.b ADDR_028C6E
EraseSprite:
	%INLINEROUTINE_SMW_EraseMinorExtendedSprite()

; Table of 4x4 tiles used for the unused "getting on Yoshi" smoke minor
; extended sprite.
Tiles:
	db $66,$66,$64,$62

ADDR_028C6E:
	LDY.w SMW_MinorExtendedSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_MExtSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_MExtSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b EraseSprite
	LDA.w !RAM_SMW_MExtSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_MExtSpr_YPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	BNE.b EraseSprite
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$00].YDisp,y
	PHX
	LDA.w !RAM_SMW_MExtSpr_Timer,x
	LSR
	LSR
	TAX
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$00].Tile,y
	PLX
	LDA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$08
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_ClusterSpr01_1up(Address)
namespace SMW_ClusterSpr01_1up
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_UpdateClusterSpritePosition_Y
	LDA.w !RAM_SMW_ClusterSpr01_1up_YSpeed,x
	CMP.b #$40
	BPL.b CODE_02FDCC
	CLC
	ADC.b #$03
	STA.w !RAM_SMW_ClusterSpr01_1up_YSpeed,x
CODE_02FDCC:
	LDA.w !RAM_SMW_ClusterSpr_YPosHi,x
	BEQ.b CODE_02FDE0
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	CMP.b #$80
	BCC.b CODE_02FDE0
	AND.b #$F0
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	STZ.w !RAM_SMW_ClusterSpr01_1up_YSpeed,x
CODE_02FDE0:
if ver_is_pal(!Define_Global_ROMToAssemble) == 0
	TXA				;!
	EOR.b !RAM_SMW_Counter_GlobalFrames	;!
	LSR				;!
	BCC.b CODE_02FE48		;!
endif
	LDA.w !RAM_SMW_ClusterSpr01_1up_YSpeed,x
	BNE.b CODE_02FE10
	LDA.w !RAM_SMW_ClusterSpr01_1up_XSpeed,x
	CLC
	ADC.w !RAM_SMW_ClusterSpr_XPosLo,x
	STA.w !RAM_SMW_ClusterSpr_XPosLo,x
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	EOR.w !RAM_SMW_ClusterSpr01_1up_XSpeed,x
	BPL.b CODE_02FE10
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	CLC
	ADC.b #$20
	CMP.b #$30
	BCS.b CODE_02FE10
	LDA.w !RAM_SMW_ClusterSpr01_1up_XSpeed,x
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_ClusterSpr01_1up_XSpeed,x
CODE_02FE10:
	LDA.b !RAM_SMW_Player_XPosLo
	SEC
	SBC.w !RAM_SMW_ClusterSpr_XPosLo,x
	CLC
	ADC.b #$0C
	CMP.b #$1E
	BCS.b CODE_02FE48
	LDA.b #$20
	LDY.b !RAM_SMW_Player_DuckingFlag
	BNE.b CODE_02FE29
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_02FE29
	LDA.b #$30
CODE_02FE29:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Player_YPosLo
	SEC
	SBC.w !RAM_SMW_ClusterSpr_YPosLo,x
	CLC
	ADC.b #$20
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BCS.b CODE_02FE48
	STZ.w !RAM_SMW_ClusterSpr_SpriteID,x
	JSR.w SpawnScoreSprite
	DEC.w !RAM_SMW_Counter_RemainingBonusGame1ups
	BNE.b CODE_02FE48
	LDA.b #$58
	STA.w !RAM_SMW_Timer_BonusGameEnd
CODE_02FE48:
	LDY.w OAMIndex,x
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$00].XDisp,y
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b #$24
	STA.w SMW_OAMBuffer[$00].Tile,y
	LDA.b #$3A
	STA.w SMW_OAMBuffer[$00].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_ClusterSpr01_1up(Address)
namespace SMW_ClusterSpr01_1up
%InsertMacroAtXPosition(<Address>)

; OAM indexes of the 1-Ups from the bonus game.
OAMIndex:
	db $90,$94,$98,$9C,$A0,$A4,$A8,$AC

SpawnScoreSprite:
;$02FF6C
	JSL.l SMW_CheckForAvailableScoreSpriteSlot_Main
	LDA.b #$0D
	STA.w !RAM_SMW_ScoreSpr_SpriteID,y
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	SEC
	SBC.b #$08
	STA.w !RAM_SMW_ScoreSpr_YPosLo,y
	LDA.w !RAM_SMW_ClusterSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_ScoreSpr_YPosHi,y
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	STA.w !RAM_SMW_ScoreSpr_XPosLo,y
	LDA.w !RAM_SMW_ClusterSpr_XPosHi,x
	STA.w !RAM_SMW_ScoreSpr_XPosHi,y
	LDA.b #$30
	STA.w !RAM_SMW_ScoreSpr_YSpeed,y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ClusterSpr03_BooCeiling(Address)
namespace SMW_ClusterSpr03_BooCeiling
%InsertMacroAtXPosition(<Address>)

DATA_02FBBB:
	db $01,$FF

DATA_02FBBD:
	db $08,$F8

; Boo Ring Tilemap (used by Sprites E2, E3, and generators E1 and E5)
BooCeilingTiles:
	db $88,$8C,$A8,$8E,$AA,$AE,$88,$8C

Main:
;$02FBC7
	CPX.b #$00
	BEQ.b CODE_02FBCE
	JMP.w CODE_02FC41

CODE_02FBCE:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$07
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02FC3E
	JSL.l SMW_GetRand_Main
	AND.b #$1F
	CMP.b #$14
	BCC.b CODE_02FBE2
	SBC.b #$14
CODE_02FBE2:
	TAX
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F86,x
	BNE.b CODE_02FC3E
	INC.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F86,x
	LDA.b #$20
	STA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F9A,x
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	PHP
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_ClusterSpr_XPosLo,x
	STA.b !RAM_SMW_NorSpr_XPosLo_Slot0
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	ADC.b #$00
	PLP
	ADC.b #$00
	STA.w !RAM_SMW_ClusterSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	STA.b !RAM_SMW_NorSpr_YPosLo_Slot0
	AND.b #$FC
	STA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F72,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ClusterSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi
	PHX
	LDX.b #$00
	LDA.b #$10
	JSR.w SMW_AimTowardsPlayer_Bank02
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ADC.b #$09
	STA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E52,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E66,x
CODE_02FC3E:
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index

CODE_02FC41:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02FC4D
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F9A,x
	BEQ.b CODE_02FC4D
	DEC.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F9A,x
CODE_02FC4D:
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F86,x
	BNE.b CODE_02FC55
	JMP.w CODE_02FCE2

CODE_02FC55:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02FC8D
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F9A,x
	BNE.b CODE_02FC78
	JSR.w SMW_UpdateClusterSpritePosition_X
	JSR.w SMW_UpdateClusterSpritePosition_Y
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_02FC78
	JSR.w SMW_CheckForPlayerToEnemyClusterSpriteCollision_Main
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E52,x
	CMP.b #$E1
	BMI.b CODE_02FC78
	DEC.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E52,x
CODE_02FC78:
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	AND.b #$FC
	CMP.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F72,x
	BNE.b CODE_02FC8D
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E52,x
	BPL.b CODE_02FC8D
	STZ.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F86,x
	STZ.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E66,x
CODE_02FC8D:
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ClusterSpr_XPosHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w #$0040
	CMP.w #$0180
	SEP.b #$20			; A->8
	BCS.b Return02FCD8
	LDA.b #$02
	JSR.w DrawClusterSpriteBoo
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	CLC
	ADC.b #$10
	PHP
	CMP.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.w !RAM_SMW_ClusterSpr_YPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	PLP
	ADC.b #$00
	BNE.b CODE_02FCD9
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.w !RAM_SMW_ClusterSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BEQ.b Return02FCD8
	LDA.w SMW_ClusterSpriteOAMIndexes_Main,x
	LSR
	LSR
	TAY
	LDA.b #$03
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
Return02FCD8:
	RTS

CODE_02FCD9:
	LDY.w SMW_ClusterSpriteOAMIndexes_Main,x
	LDA.b #$F0
	STA.w SMW_OAMBuffer[$40].YDisp,y
	RTS

CODE_02FCE2:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02FD46
	LDA.w !RAM_SMW_ClusterSpr_SpriteID,x
	CMP.b #!Define_SMW_SpriteID_ClusterSpr08_DeathBatCeiling
	BEQ.b CODE_02FD46
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F9A,x
	BNE.b CODE_02FD1A
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$01
	BNE.b CODE_02FD1A
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F4A,x
	AND.b #$01
	TAY
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E66,x
	CLC
	ADC.w DATA_02FBBB,y
	STA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E66,x
	CMP.w DATA_02FBBD,y
	BNE.b CODE_02FD1A
	INC.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F4A,x
	LDA.w !RAM_SMW_Misc_RandomByte1
	AND.b #$FF
	ORA.b #$3F
	STA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F9A,x
CODE_02FD1A:
	JSR.w SMW_UpdateClusterSpritePosition_X
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b CODE_02FD46
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b #$01
	TXA
	ASL
	ASL
	ASL
	ADC.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$40
	BEQ.b CODE_02FD36
	LDY.b #$FF
	DEC.b !RAM_SMW_Misc_ScratchRAM00
CODE_02FD36:
	TYA
	CLC
	ADC.w !RAM_SMW_ClusterSpr_YPosLo,x
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	ADC.w !RAM_SMW_ClusterSpr_YPosHi,x
	STA.w !RAM_SMW_ClusterSpr_YPosHi,x
CODE_02FD46:
	LDA.b #$0E

DrawClusterSpriteBoo:
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDY.w SMW_ClusterSpriteOAMIndexes_Main,x
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	LSR
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM00
	TXA
	AND.b #$03
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	PHX
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l BooCeilingTiles,x
else
	LDA.w BooCeilingTiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E1E66,x
	ASL
	LDA.b #$00
	BCS.b CODE_02FD81
	LDA.b #$40
CODE_02FD81:
	ORA.b #$31
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$40].Prop,y
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	LDA.w !RAM_SMW_ClusterSpr_SpriteID,x
	CMP.b #!Define_SMW_SpriteID_ClusterSpr08_DeathBatCeiling
	BNE.b Return02FDB7
	LDY.w SMW_ClusterSpriteOAMIndexes_Main,x
	LDA.b !RAM_SMW_Counter_LocalFrames
	LSR
	LSR
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ClusterSpr03_BooCeiling_UnknownTable7E0F86,x
	ASL
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	PHX
	TAX
	LDA.w BatCeilingTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b #$37
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
Return02FDB7:
	RTS

; Swooper Death Bat tilemap (change 4th byte to E8 to correct graphics)
BatCeilingTiles:
	db $AE,$AE,$C0,$EB
namespace off
	%SetDuplicateOrNullPointer(SMW_ClusterSpr03_BooCeiling_Main, SMW_ClusterSpr08_DeathBatCeiling_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ClusterSpr04_BooRing(Address)
namespace SMW_ClusterSpr04_BooRing
%InsertMacroAtXPosition(<Address>)

; Ten 16bit values, telling where on the circle the Boo Ring ghosts are.
; #$0200 is 360 degrees.
DATA_02FA84:
	db $00,$00,$28,$00,$50,$00,$78,$00
	db $A0,$00,$C8,$00,$F0,$00,$18,$01
	db $40,$01,$68,$01

Main:
;$02FA98
	; The code for cluster sprite 04, the Boo from a Boo ring. $02FB39 is
	; radius of Boo rings along the X-axis. $02FB5C is radius of Boo rings
	; along the Y-axis.
	LDY.w !RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F86,x
	LDA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1OffscreenFlag,y
	BEQ.b CODE_02FAA4
	STZ.w !RAM_SMW_ClusterSpr_SpriteID,x
	RTS

CODE_02FAA4:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02FAF0
	LDA.w !RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F4A,x
	BEQ.b CODE_02FAF0
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_02FAB3
	DEC.b !RAM_SMW_Misc_ScratchRAM00
CODE_02FAB3:
	CLC
	ADC.w !RAM_SMW_ClusterSpr04_BooRing_Ring1AngleLo,y
	STA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1AngleLo,y
	LDA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1AngleHi,y
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$01
	STA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1AngleHi,y
	LDA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w #$0080
	CMP.w #$0200
	SEP.b #$20			; A->8
	BCC.b CODE_02FAF0
	LDA.b #$01
	STA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1OffscreenFlag,y
	PHX									;\ Optimization: Boo rings are never killed, so this is useless.
	LDX.w !RAM_SMW_ClusterSpr04_BooRing_UnusedRing1LevelListIndex,y		;|
if defined("Define_SMW_SA1")
	JML.l SpriteLoading_CODE_02FAE9
else
	STZ.w !RAM_SMW_Sprites_LoadStatus,x					;|
	PLX									;/
endif
	DEC.w !RAM_SMW_ClusterSpr04_BooRing_RingIndex
CODE_02FAF0:
	PHX
	LDA.w !RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F72,x
	ASL
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_02FA84,x
else
	LDA.w DATA_02FA84,x
endif
	CLC
	ADC.w !RAM_SMW_ClusterSpr04_BooRing_Ring1AngleLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l DATA_02FA84+$01,x
else
	LDA.w DATA_02FA84+$01,x
endif
	ADC.w !RAM_SMW_ClusterSpr04_BooRing_Ring1AngleHi,y
	AND.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM01
	PLX
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
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
incsrc "asm/inline/02FB33.asm"
namespace SMW_ClusterSpr04_BooRing
else
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b #$50
	LDY.b !RAM_SMW_Misc_ScratchRAM05
	BNE.b CODE_02FB4D
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	ASL.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	ADC.b #$00
CODE_02FB4D:
	LSR.b !RAM_SMW_Misc_ScratchRAM01
	BCC.b CODE_02FB54
	EOR.b #$FF
	INC
CODE_02FB54:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.b #$50
	LDY.b !RAM_SMW_Misc_ScratchRAM07
	BNE.b CODE_02FB70
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	ASL.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	ADC.b #$00
CODE_02FB70:
	LSR.b !RAM_SMW_Misc_ScratchRAM03
	BCC.b CODE_02FB77
	EOR.b #$FF
	INC
CODE_02FB77:
	STA.b !RAM_SMW_Misc_ScratchRAM06
endif
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDY.w !RAM_SMW_ClusterSpr04_BooRing_UnknownTable7E0F86,x
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	BPL.b CODE_02FB87
	DEC.b !RAM_SMW_Misc_ScratchRAM00
CODE_02FB87:
	CLC
	ADC.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosLo,y
	STA.w !RAM_SMW_ClusterSpr_XPosLo,x
	LDA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosHi,y
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_ClusterSpr_XPosHi,x
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	BPL.b CODE_02FB9E
	DEC.b !RAM_SMW_Misc_ScratchRAM01
CODE_02FB9E:
	CLC
	ADC.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterYPosLo,y
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	LDA.w !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterYPosHi,y
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_ClusterSpr_YPosHi,x
	JSR.w SMW_ClusterSpr03_BooCeiling_CODE_02FC8D
CODE_02FBB0:
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b Return02FBBA
	JSR.w SMW_CheckForPlayerToEnemyClusterSpriteCollision_Main
Return02FBBA:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ClusterSpr05_CandleFlame(Address)
namespace SMW_ClusterSpr05_CandleFlame
%InsertMacroAtXPosition(<Address>)

DATA_02FA02:
	db $03,$07,$07,$07,$0F,$07,$07,$0F


OAMIndex:
	db $F0,$F4,$F8,$FC

; Sprite tilemap: Castle BG Flame
Tiles:
	db $E2,$E4,$E2,$E4

; YXPPCCCT properties for the Castle BG Flame
Prop:
	db $09,$09,$49,$49

Main:
;$02FA16
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02FA2B
	JSL.l SMW_GetRand_Main
	AND.b #$07
	TAY
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.w DATA_02FA02,y
	BNE.b CODE_02FA2B
	INC.w !RAM_SMW_ClusterSpr05_CandleFlame_UnknownTable7E0F4A,x
CODE_02FA2B:
	LDY.w OAMIndex,x
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	STA.w SMW_OAMBuffer[$40].XDisp,y
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	STA.w SMW_OAMBuffer[$40].YDisp,y
	PHY
	PHX
	LDA.w !RAM_SMW_ClusterSpr05_CandleFlame_UnknownTable7E0F4A,x
	AND.b #$03
	TAX
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Tiles,x
else
	LDA.w Tiles,x
endif
	STA.w SMW_OAMBuffer[$40].Tile,y
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l Prop,x
else
	LDA.w Prop,x
endif
	STA.w SMW_OAMBuffer[$40].Prop,y
	PLX
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y
	PLY
	LDA.w SMW_OAMBuffer[$40].XDisp,y
	CMP.b #$F0
	BCC.b Return02FA83
	LDA.w SMW_OAMBuffer[$40].XDisp,y
	STA.w SMW_OAMBuffer[$7B].XDisp
	LDA.w SMW_OAMBuffer[$40].YDisp,y
	STA.w SMW_OAMBuffer[$7B].YDisp
	LDA.w SMW_OAMBuffer[$40].Tile,y
	STA.w SMW_OAMBuffer[$7B].Tile
	LDA.w SMW_OAMBuffer[$40].Prop,y
	STA.w SMW_OAMBuffer[$7B].Prop
	LDA.b #$03
	STA.w SMW_OAMTileSizeBuffer[$7B].Slot
Return02FA83:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ClusterSpr06_SumoBroFlame(Address)
namespace SMW_ClusterSpr06_SumoBroFlame
%InsertMacroAtXPosition(<Address>)

DATA_02F8FC:
	db $00,$10,$00,$10,$08,$10,$FF,$10

; Sumo Bros' Flame Tilemap
Tiles:
	db $DC,$EC,$CC,$EC,$CC,$DC,$00,$CC

DATA_02F90C:
	db $03,$03,$03,$03,$02,$01,$00,$00
	db $00,$00,$00,$00,$01,$02,$03,$03

Main:
;$02F91C
	LDA.w !RAM_SMW_ClusterSpr06_SumoBroFlame_DespawnTimer,x
	BEQ.b CODE_02F93C
	LDY.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02F928
	DEC.w !RAM_SMW_ClusterSpr06_SumoBroFlame_DespawnTimer,x
CODE_02F928:
	LSR
	LSR
	LSR
	TAY
	LDA.w DATA_02F90C,y
	ASL
	STA.w !RAM_SMW_Sprites_SumoBroFlameScratchRAM7E185E
	JSR.w CheckForPlayerContact
	PHX
	JSR.w CODE_02F940
	PLX
	RTS

CODE_02F93C:
	STZ.w !RAM_SMW_ClusterSpr_SpriteID,x
	RTS

CODE_02F940:								;\ Glitch: What is this? Is this why the Sumo Bro Flames cause the graphical glitches it does?
	TXA								;|
	ASL								;|
	TAY								;|
	LDA.w SMW_ClusterSpriteOAMIndexes_Main,y			;|
	STA.w !RAM_SMW_NorSpr_OAMIndex					;|
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x				;|
	STA.b !RAM_SMW_NorSpr_XPosLo_Slot0	;|
	LDA.w !RAM_SMW_ClusterSpr_XPosHi,x				;|
	STA.w !RAM_SMW_NorSpr_XPosHi					;|
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x				;|
	STA.b !RAM_SMW_NorSpr_YPosLo_Slot0	;|
	LDA.w !RAM_SMW_ClusterSpr_YPosHi,x				;|
	STA.w !RAM_SMW_NorSpr_YPosHi					;|
	TAY								;|
	LDX.b #$00							;|
	JSR.w SMW_GetDrawInfo_Bank02					;|
	LDX.b #$01							;|
CODE_02F967:								;/
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w SMW_OAMBuffer[$40].XDisp,y
	TXA
	ORA.w !RAM_SMW_Sprites_SumoBroFlameScratchRAM7E185E
	TAX
	LDA.w DATA_02F8FC,x
	BMI.b CODE_02F993
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.w SMW_OAMBuffer[$40].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$04
	ASL
	ASL
	ASL
	ASL
	NOP								; Optimization: Useless NOP
	ORA.b !RAM_SMW_Sprites_TilePriority
	ORA.b #$05
	STA.w SMW_OAMBuffer[$40].Prop,y
CODE_02F993:
	PLX
	INY
	INY
	INY
	INY
	DEX
	BPL.b CODE_02F967
	LDX.b #$00
	LDY.b #$02
	LDA.b #$01
	JSL.l SMW_FinishOAMWrite_Main					; Note: It's not everyday you see a non-Normal sprite call this routine.
	RTS

CODE_02F9A6:
	STZ.w !RAM_SMW_ClusterSpr_SpriteID,x
	RTS

DATA_02F9AA:
	db $02,$0A,$12,$1A

CheckForPlayerContact:
	TXA
	EOR.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b Return02F9FE
	LDA.w !RAM_SMW_ClusterSpr06_SumoBroFlame_DespawnTimer,x
	CMP.b #$10
	BCC.b Return02F9FE
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x
	CLC
	ADC.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_ClusterSpr_XPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.b #$0C
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDY.w !RAM_SMW_Sprites_SumoBroFlameScratchRAM7E185E		; Glitch: Mario can be hurt by these flames when far below them because of this. The Extended No Sprite Tile Limits patch fixes this by AND.b #$03 to $185E and transfering the result in Y.
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	CLC
	ADC.w DATA_02F9AA,y
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.b #$14
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.w !RAM_SMW_ClusterSpr_YPosHi,x
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM0B
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_GetMarioClipping
	JSL.l SMW_StandardSpriteToSpriteCollisionChecks_CheckForContact
	BCC.b Return02F9FE
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario has star
	BNE.b CODE_02F9A6
CODE_02F9F5:								;\ Optimization: Replace this with:
	LDA.w !RAM_SMW_Player_RidingYoshiFlag				;|	JMP.w SMW_CheckForMarioToExtendedSpriteCollision_CODE_02A46E
	BNE.b CODE_02F9FF						;|Return02F9FE:
	JSL.l SMW_DamagePlayer_Hurt					;|	RTS
Return02F9FE:								;|
	RTS								;|
									;|
CODE_02F9FF:								;|
	JMP.w SMW_CheckForMarioToExtendedSpriteCollision_LoseYoshi	;/
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ClusterSpr07_ReappearingBoo(Address)
namespace SMW_ClusterSpr07_ReappearingBoo
%InsertMacroAtXPosition(<Address>)

DATA_02F837:
	db $01,$FF

DATA_02F839:
	db $00,$FF,$02,$0E

Main:
;$02F83D
	LDA.w !RAM_SMW_Sprites_DisappearingBooFrameCounter
	STA.w !RAM_SMW_Sprites_CopyOfDisappearingBooFrameCounter
	TXY
	BNE.b CODE_02F855
	DEC.w !RAM_SMW_Sprites_DisappearingBooFrameCounter
	CMP.b #$00
	BNE.b CODE_02F855
	INC.w !RAM_SMW_ClusterSpr07_ReappearingBoo_BooSet
	LDY.b #$FF
	STY.w !RAM_SMW_Sprites_DisappearingBooFrameCounter
CODE_02F855:
	CMP.b #$00
	BNE.b CODE_02F89E
	LDA.w !RAM_SMW_Timer_DisappearingSprite
	BEQ.b CODE_02F865
	STZ.w !RAM_SMW_ClusterSpr_SpriteID,x
	STZ.w !RAM_SMW_ClusterSpr07_ReappearingBoo_BooSet
	RTS

CODE_02F865:
	LDA.w !RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E66,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E52,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_ClusterSpr07_ReappearingBoo_BooSet
	AND.b #$01
	BNE.b CODE_02F880
	LDA.w !RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E8E,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_ClusterSpr07_ReappearingBoo_UnknownTable7E1E7A,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
CODE_02F880:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w !RAM_SMW_ClusterSpr_XPosLo,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ClusterSpr_XPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ClusterSpr_YPosHi,x
CODE_02F89E:
	TXA
	ASL
	ASL
	ADC.b !RAM_SMW_Counter_LocalFrames
	STA.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$07
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_02F8C8
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #$20
	LSR
	LSR
	LSR
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x
	CLC
	ADC.w DATA_02F837,y
	STA.w !RAM_SMW_ClusterSpr_YPosLo,x
	LDA.w !RAM_SMW_ClusterSpr_YPosHi,x
	ADC.w DATA_02F839,y
	STA.w !RAM_SMW_ClusterSpr_YPosHi,x
CODE_02F8C8:
	LDY.w !RAM_SMW_Sprites_CopyOfDisappearingBooFrameCounter
	CPY.b #$20
	BCC.b Return02F8FB
	CPY.b #$40
	BCS.b CODE_02F8D8
	TYA
	SBC.b #$1F
	BRA.b CODE_02F8E2

CODE_02F8D8:
	CPY.b #$E0
	BCC.b CODE_02F8E6
	TYA
	SBC.b #$E0
	EOR.b #$1F
	INC
CODE_02F8E2:
	LSR
	LSR
	BRA.b CODE_02F8EB

CODE_02F8E6:
	JSR.w SMW_ClusterSpr04_BooRing_CODE_02FBB0
	LDA.b #$08
CODE_02F8EB:
	STA.w !RAM_SMW_Sprites_BigBooBossPaletteIndex
	CPX.b #$00
	BNE.b CODE_02F8F6
	JSL.l SMW_FadingBooPaletteAnimation_Main
CODE_02F8F6:
	LDA.b #$0F
	JSR.w SMW_ClusterSpr03_BooCeiling_DrawClusterSpriteBoo
Return02F8FB:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSpr01_GenerateEerie(Address)
namespace SMW_GenSpr01_GenerateEerie
%InsertMacroAtXPosition(<Address>)

InitialXLo:
	db $F0,$FF

InitialXHi:
	db $FF,$00

InitialXSpeed:
	db $10,$F0

Main:
;$02B2D6
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.b #$3F			;|every 4 seconds
	BNE.b Return02B31E		;/
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	;\
	BMI.b Return02B31E		;/ make sure slot is available
	TYX				; X = index to sprite we are creating
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_SpriteID_NorSpr038_StraightEerie	;\Eerie
	STA.b !RAM_SMW_NorSpr_SpriteID_x	;/
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; INIT Eerie
	JSL.l SMW_GetRand_Main		;\
	AND.b #$7F			;|
	ADC.b #$40			;|same process as usual,
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|give random Ypos
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;\
	ADC.b #$00			;|handle Yhipos
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;/
	LDA.w !RAM_SMW_Misc_RandomByte2	;\
	AND.b #$01			;|
	TAY				;|
	LDA.w InitialXLo,y		;|Xpos is F0 or FF
	CLC				;|
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;\
	ADC.w InitialXHi,y		;|handle Xhipos
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
	LDA.w InitialXSpeed,y		;\ Set Xspeed accordingly
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
Return02B31E:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSprXX_GenerateParachuteEnemies(Address)
namespace SMW_GenSprXX_GenerateParachuteEnemies
%InsertMacroAtXPosition(<Address>)

SpriteToSpawn:
	db !Define_SMW_SpriteID_NorSpr03F_ParachuteGoomba
	db !Define_SMW_SpriteID_NorSpr040_ParachuteBobOmb

	db !Define_SMW_SpriteID_NorSpr03F_ParachuteGoomba
	db !Define_SMW_SpriteID_NorSpr03F_ParachuteGoomba

	db !Define_SMW_SpriteID_NorSpr040_ParachuteBobOmb
	db !Define_SMW_SpriteID_NorSpr040_ParachuteBobOmb

InitialXSpeed:
	db $FA,$FB,$FC,$FD

Main:
;$02B329
	LDA.b !RAM_SMW_Counter_LocalFrames	;\01- goomba 02- bomb 03- both
	AND.b #$7F			;| every 8 seconds
	BNE.b Return02B386		;/
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	;\ make sure spot is available
	BMI.b Return02B386		;/
	TYX				; x= index to sprite we are creating
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	JSL.l SMW_GetRand_Main		;\
	LSR				;|
	LDY.w !RAM_SMW_GenSpr_SpriteID	;| if only making bombs, don't add 3 to y
	BCC.b CODE_02B348		;/
	INY				;\
	INY				;|add 3 to Y
	INY				;/
CODE_02B348:
	LDA.w SpriteToSpawn-!Define_SMW_SpriteID_GenSpr02_GenParachuteEnemy,y	;\ 3F, 40, 40,
	STA.b !RAM_SMW_NorSpr_SpriteID_x	;/ Which corresponds to goomba, bomb, bomb.
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; INIT each of those
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;\
	SEC				;|
	SBC.b #$20			;|get the Ypos
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;\
	SBC.b #$00			;|handle the Yhipos
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;/
	LDA.w !RAM_SMW_Misc_RandomByte1	;\
	AND.b #$FF			;|
	CLC				;|get Xpos,
	ADC.b #$30			;
	PHP				;|carries for later
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;/
	PHP				; again, saving the carry
	AND.b #$0E			;\ getting a frame
	STA.w !RAM_SMW_NorSprXXX_ParachutingEnemy_CurrentAngle,x	;/ (probably random)
	LSR				;\
	AND.b #$03			;|
	TAY				;|getting one of 4
	LDA.w InitialXSpeed,y		;|x speeds for the sprite
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;\
	PLP				;|
	ADC.b #$00			;|using the carries that might of been set
	PLP				;|earlier, we now can handle
	ADC.b #$00			;|the Xhipos.
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
Return02B386:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_GenSprXX_GenerateParachuteEnemies_Main, SMW_GenSpr02_GenParachuteEnemy_Main)
	%SetDuplicateOrNullPointer(SMW_GenSprXX_GenerateParachuteEnemies_Main, SMW_GenSpr03_GenParachuteGoomba_Main)
	%SetDuplicateOrNullPointer(SMW_GenSprXX_GenerateParachuteEnemies_Main, SMW_GenSpr04_GenParachuteBobOmb_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSprXX_GenerateDolphins(Address)
namespace SMW_GenSprXX_GenerateDolphins
%InsertMacroAtXPosition(<Address>)

InitialXLo:
	db $10,$E0

InitialXHi:
	db $01,$FF

InitialXSpeed:
	db $E8,$18

InitialYSpeed:
	db $F0,$E0,$00,$10

DATA_02B268:
	db !Define_SMW_StockMaxNormalSpriteSlot-$07,!Define_SMW_StockMaxNormalSpriteSlot-$02

DATA_02B26A:
	db !NullSpriteSlot,!Define_SMW_StockMaxNormalSpriteSlot-$07

Main:
;$02B26C
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.b #$1F			;|every two seconds
	BNE.b Return02B2CF		;/
	LDY.w !RAM_SMW_GenSpr_SpriteID	;\  Y = 04/05
	LDX.w DATA_02B268-!Define_SMW_SpriteID_GenSpr05_GenerateLeftDolphins,y	;| X = 04/09 04 left 05 right
	LDA.w DATA_02B26A-!Define_SMW_SpriteID_GenSpr05_GenerateLeftDolphins,y	;| A = 04/09
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_02B27D:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x	;\if sprite died/does not exist
	BEQ.b CODE_02B288		;/ generate one
	DEX				;\
	CPX.b !RAM_SMW_Misc_ScratchRAM00	;|and do this until you've handled every dolphin.
	BNE.b CODE_02B27D		;/
	RTS

CODE_02B288:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
if defined("Define_SMW_SA1")
	; SA-1 Pack: The dolphin generator is weird and doesn't use
	; FindFreeSlotLowPri so it requires individual attention.
	JSL.l DOLPHIN_GENERATOR_SET
else
	LDA.b #!Define_SMW_SpriteID_NorSpr041_LongJumpDolphin	;\ Dolphin
	STA.b !RAM_SMW_NorSpr_SpriteID,x	;/
endif
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; INIT Dolphin
	JSL.l SMW_GetRand_Main		;\
	AND.b #$7F			;|get a random Ypos for the new sprite
	ADC.b #$40			;|
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;\
	ADC.b #$00			;|handle Yhibyte
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;/
	JSL.l SMW_GetRand_Main		;\ The Y speed will either be
	AND.b #$03			;|F0, E0, or 00
	TAY				;|
	LDA.w InitialYSpeed,y		;|
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
	LDY.w !RAM_SMW_GenSpr_SpriteID	;\
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;| Left generator will end up with 00,
	CLC				;| Right with 10 for the Xpos
	ADC.w InitialXLo-!Define_SMW_SpriteID_GenSpr05_GenerateLeftDolphins,y	;|
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;\
	ADC.w InitialXHi-!Define_SMW_SpriteID_GenSpr05_GenerateLeftDolphins,y	;|handle Xhibyte
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
	LDA.w InitialXSpeed-!Define_SMW_SpriteID_GenSpr05_GenerateLeftDolphins,y	;\
	STA.b !RAM_SMW_NorSpr_XSpeed,x	;| Handle Xspeeds
	INC.w !RAM_SMW_NorSprXXX_Dolphins_NoTurnAroundFlag,x	;/
Return02B2CF:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_GenSprXX_GenerateDolphins_Main, SMW_GenSpr05_GenerateLeftDolphins_Main)
	%SetDuplicateOrNullPointer(SMW_GenSprXX_GenerateDolphins_Main, SMW_GenSpr06_GenerateRightDolphins_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSpr07_GenerateFish(Address)
namespace SMW_GenSpr07_GenerateFish
%InsertMacroAtXPosition(<Address>)

DATA_02B153:
	db $10,$18,$20,$28

DATA_02B157:
	db $18,$1A,$1C,$1E

Main:
;$02B15B
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.b #$1F			;|every two seconds (less actually, but whatever)
	BNE.b Return02B1B7		;/
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	;\ if there is a free spot, then go for it
	BMI.b Return02B1B7		;/
	TYX				; X = index to new sprite
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_SpriteID_NorSpr017_GeneratorCheepCheep	; \ Sprite = Flying Fish
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; INIT the fish
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;\
	CLC				;| generate at a certain Y-place every time
	ADC.b #$C0			;|
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;\
	ADC.b #$00			;| handle High Y byte
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;/
	JSL.l SMW_GetRand_Main		;\
	CMP.b #$00			;/ the result of this operation is pushed twice
	PHP				;\
	PHP				;/ Push the processor flags
	AND.b #$03
	TAY
	LDA.w DATA_02B153,y
	PLP
	BPL.b CODE_02B196
	EOR.b #$FF
CODE_02B196:
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;\
	ADC.b #$00			;|handle Yhibyte
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
	LDA.w !RAM_SMW_Misc_RandomByte2
	AND.b #$03
	TAY
	LDA.w DATA_02B157,y
	PLP
	BPL.b CODE_02B1B1
	EOR.b #$FF
	INC
CODE_02B1B1:
	STA.b !RAM_SMW_NorSpr_XSpeed,x
	LDA.b #$B8			;\Give a basic Yspeed
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/
Return02B1B7:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSpr08_TurnOffRespawningSprite(Address)
namespace SMW_GenSpr08_TurnOffRespawningSprite
%InsertMacroAtXPosition(<Address>)

Main:
	INC.w !RAM_SMW_Timer_DisappearingSprite
	STZ.w !RAM_SMW_Timer_RespawnSprite	; Don't respawn any sprites
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSpr09_GenerateSuperKoopa(Address)
namespace SMW_GenSpr09_GenerateSuperKoopa
%InsertMacroAtXPosition(<Address>)

InitialXLo:
	db $E0,$10			; E0 - Left side enterance, 10 = right side enterance

InitialXHi:
	db $FF,$01

Main:
;$02B1BC
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.b #$3F			;| Every 4 seconds
	BNE.b Return02B206		;/
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	;\ make sure you can generate a sprite
	BMI.b Return02B206		;/
	TYX				; X= index to sprite we are generating
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_SpriteID_NorSpr071_RedCapeSuperKoopa	;\super koopa, or course
	STA.b !RAM_SMW_NorSpr_SpriteID_x	;/
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; INIT super koopas
	JSL.l SMW_GetRand_Main
	PHA				;\
	AND.b #$3F			;|
	ADC.b #$20			;|get random value for the Y position
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;\
	ADC.b #$00			;|
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;/ handle Yhibyte
	LDA.b #$28			;\
	STA.b !RAM_SMW_NorSpr_YSpeed,x	;/ get a normal Y speed
	PLA				; get the random value from before
	AND.b #$01			;\
	TAY				;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	CLC				;|make X pos either
	ADC.w InitialXLo,y		;|
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;\
	ADC.w InitialXHi,y		;|handle Yhibyte
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
	TYA				;\
	STA.w !RAM_SMW_NorSpr_FacingDirection,x	;/ make sure the direction matches where it came in from
Return02B206:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSpr0A_GenerateBubbles(Address)
namespace SMW_GenSpr0A_GenerateBubbles
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.b #$7F			;|every 8 seconds
	BNE.b Return02B259		;/
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	;\
	BMI.b Return02B259		;/ make sure you can generate a sprite
	TYX				; x= index to sprite we are generating
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_SpriteID_NorSpr09D_BubbleWithSprite	;\ Sprite = bubble
	STA.b !RAM_SMW_NorSpr_SpriteID_x	;/
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; INIT bubble
	JSL.l SMW_GetRand_Main		; Get random number
	PHA				; save it for later
	AND.b #$3F			;\
	ADC.b #$20			;|
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|find a Ypos
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;\
	ADC.b #$00			;|handle the Yhibyte
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;/
	PLA				; A = random number we had at first
	AND.b #$01			;\
	TAY				;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|Enter from either left or right
	CLC				;|
	ADC.w SMW_GenSpr09_GenerateSuperKoopa_InitialXLo,y	;|
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;\
	ADC.w SMW_GenSpr09_GenerateSuperKoopa_InitialXHi,y	;|handle Xhibyte
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;/
	TYA				;\ make direction match side entering from
	STA.w !RAM_SMW_NorSpr09D_BubbleWithSprite_HorizontalDirection,x	;/
	JSL.l SMW_GetRand_Main		;\
	AND.b #$03			;|load either 00,01,or 02 for later use
	TAY				;|(very probably for sprite to generate inside
	LDA.w DATA_02B25A,y		;|bubble)
	STA.b !RAM_SMW_NorSpr09D_BubbleWithSprite_Contents,x	;/
Return02B259:
	RTS

DATA_02B25A:
	db $00,$01,$02,$00
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSpr0B_GenerateBullet(Address)
namespace SMW_GenSpr0B_GenerateBullet
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.b #$7F			;| every 8 seconds
	BNE.b Return02B0C8		;/ go forward
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	;\find a free spot if possible
	BMI.b Return02B0C8		;/ (low priority)
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	TYX				; as last time
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_SpriteID_NorSpr01C_BulletBill	; \ Sprite = Bullet Bill
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Initalize the sprite
	JSL.l SMW_GetRand_Main		;\ Generating the placement
	PHA				;| The random number we just got is preserved
	AND.b #$7F			;|\
	ADC.b #$20			;||
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;||
	AND.b #$F0			;|| find a random Y position to put it at
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;||
	ADC.b #$00			;||
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;|/
	PLA				;|random number here
	AND.b #$01			;|AND 01, not much to say
	TAY				;|Now ^ is in Y
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|\\Get the X position to generate it at
	CLC				;|||
	ADC.w SMW_GenSpr09_GenerateSuperKoopa_InitialXLo,y	;|||the Xpos is either left or right
	STA.b !RAM_SMW_NorSpr_XPosLo_x	;||/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;||\
	ADC.w SMW_GenSpr09_GenerateSuperKoopa_InitialXHi,y	;||| handle hiXpos
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;|//
	TYA				;
	STA.b !RAM_SMW_NorSpr01C_BulletBill_FiringDirection,x	;//Save which side it came from for further use (speed determining)
Return02B0C8:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSpr0C_GenerateSurroundingBullets(Address)
namespace SMW_GenSpr0C_GenerateSurroundingBullets
%InsertMacroAtXPosition(<Address>)

DATA_02B0C9:
	db !Define_SMW_StockMaxNormalSpriteSlot-$07,!Define_SMW_StockMaxNormalSpriteSlot-$03

; Number of bullets to spawn from the surrounded Bullet Bill generator,
; minus one. (Don't set this higher than 04, or the tables at
; $02B0FA-$02B114 will underflow.)
DATA_02B0CB:
	db !Define_SMW_StockMaxNormalSpriteSlot-$07,!Define_SMW_StockMaxNormalSpriteSlot-$08

Main:
;$02B0CD
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	LSR				;|
	BCS.b Return02B0F9		;/ every other frame, continue
	LDA.w !RAM_SMW_Sprites_SpecialBulletGeneratorTimer	;\
	INC.w !RAM_SMW_Sprites_SpecialBulletGeneratorTimer	;| Diagonal bullet bill timer, if at A0 then
	CMP.b #$A0			;|make bullet bills
	BNE.b Return02B0F9		;/
	STZ.w !RAM_SMW_Sprites_SpecialBulletGeneratorTimer	; reset the timer
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDY.w !RAM_SMW_GenSpr_SpriteID	;\
	LDA.w DATA_02B0C9-!Define_SMW_SpriteID_GenSpr0C_GenerateSurroundingBullets,y	;| Surrounded shooter wil load 04, diagonal will load 08 to A here.
	LDX.w DATA_02B0CB-!Define_SMW_SpriteID_GenSpr0C_GenerateSurroundingBullets,y	;| Surrounded shooter will load 04, diagonal will load 03 to X here.
	STA.b !RAM_SMW_Misc_ScratchRAM0D	;/ 0D will be useful when determining X positions later
CODE_02B0EF:
	PHX				;\preserve X
	JSR.w GEN_MULTI_BULLET		;|
	DEC.b !RAM_SMW_Misc_ScratchRAM0D	;|
	PLX				;|runs a loop. Surrounded will run 4 times, diagonal 3 times.
	DEX				;| Generates a bullet.
	BPL.b CODE_02B0EF		;/
Return02B0F9:
	RTS

; Initial X position, within screen, of bullets spawned by surrounded Bullet
; Bill generator.
InitialXLo:
	db $00,$00,$40,$C0,$F0,$00,$00,$F0
	db $F0

; Initial Y position, within screen, of bullets spawned by surrounded Bullet
; Bill generator.
InitialYLo:
	db $50,$B0,$E0,$E0,$80,$00,$E0,$E0
	db $00

; Direction of bullets spawned by surrounded Bullet Bill generator. 00 =
; right 01 = left 02 = up 03 = down 04 = up-right 05 = down-right 06 =
; down-left 07 = up-left
InitialFiringDirection:
	db $00,$00,$02,$02,$01,$05,$04,$07
	db $06

GEN_MULTI_BULLET:
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	;\ find a free sprite slot, but on low
	BMI.b Return02B152		;/ priority
	LDA.b #!Define_SMW_SpriteID_NorSpr01C_BulletBill	; \ Sprite = Bullet Bill
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	TYX				; X = index to sprite we just generated
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; init bullet bill
	LDX.b !RAM_SMW_Misc_ScratchRAM0D	;\
	LDA.w InitialXLo,x		;|Surround will generate X wise on
	CLC				;|$00,$00,$40,$C0 + X boundry
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|Diagonal only 00, 00 and 40 + X boundry
	STA.w !RAM_SMW_NorSpr_XPosLo,y	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;\ handle X high byte
	ADC.b #$00			;|
	STA.w !RAM_SMW_NorSpr_XPosHi,y	;/
	LDA.w InitialYLo,x		;\ Surround will generate Y wise on
	CLC				;| $50,$B0,$E0,$E0 + Yboundry, Diagonal on
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;| 50, B0, and E0 only + Yboundry
	STA.w !RAM_SMW_NorSpr_YPosLo,y	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;\
	ADC.b #$00			;| handle Y high byte
	STA.w !RAM_SMW_NorSpr_YPosHi,y	;/
	LDA.w InitialFiringDirection,x	;\ surround will put $00,$00,$02,$02,
	STA.w !RAM_SMW_NorSpr01C_BulletBill_FiringDirection,y	;/ Diagonal just 00 00 and 02 to each bullet generated
Return02B152:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_GenSpr0C_GenerateSurroundingBullets_Main, SMW_GenSpr0D_GenerateDiagnalBullets_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSpr0E_GenerateFire(Address)
namespace SMW_GenSpr0E_GenerateFire
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.b #$7F			;| every 8 seconds (normal sprite seconds
	BNE.b Return02B07B		;|
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	;| if the circumstances are right...
	BMI.b Return02B07B		;/
	TYX				; X now holds the index to the sprite
	LDA.b #!Define_SMW_Sound1DFC_FireSpit	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #!Define_SMW_SpriteID_NorSpr0B3_BowserStatueFire	; \ Sprite = Bowser's Statue Fireball
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	;\ find a random spot to generate the sprite
	JSL.l SMW_GetRand_Main		;| Get a random number..
	AND.b #$7F			;| AND with #$7F
	ADC.b #$20			;| add 20
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;| and the screen boundry
	AND.b #$F0			;| AND again
	STA.b !RAM_SMW_NorSpr_YPosLo_x	;| and make that the Y position
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;|\
	ADC.b #$00			;||
	STA.w !RAM_SMW_NorSpr_YPosHi,x	;||
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;||
	CLC				;||
	ADC.b #$FF			;||handle the high bytes too
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;||
	ADC.b #$00			;||
	STA.w !RAM_SMW_NorSpr_XPosHi,x	;|/
	INC.w !RAM_SMW_NorSpr_FacingDirection,x	;/ Make it go left
Return02B07B:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenSpr0F_TurnOffGenerator(Address)
namespace SMW_GenSpr0F_TurnOffGenerator
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_GenSpr_SpriteID	; Don't generate anything
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ShooterSpr01_BulletBillShooter(Address)
namespace SMW_ShooterSpr01_BulletBillShooter
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_ShooterSpr_ShootTimer,x	; \ Return if it's not time to generate
	BNE.b Return02B4DD
	LDA.b #$60			; \ Set time till next generation = 60
	STA.w !RAM_SMW_ShooterSpr_ShootTimer,x
	LDA.w !RAM_SMW_ShooterSpr_YPosLo,x	; \ Don't generate if off screen vertically
	CMP.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.w !RAM_SMW_ShooterSpr_YPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi
	BNE.b Return02B4DD
	LDA.w !RAM_SMW_ShooterSpr_XPosLo,x	; \ Don't generate if off screen horizontally
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.w !RAM_SMW_ShooterSpr_XPosHi,x
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	BNE.b Return02B4DD
	LDA.w !RAM_SMW_ShooterSpr_XPosLo,x	; \ ?? something else related to x position of generator??
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.b #$10
	CMP.b #$10
	BCC.b Return02B4DD
	; Replace with 80 0A to make the Bullet Bill Shooter keep shooting even if
	; Mario is standing next to the generator.
	LDA.b !RAM_SMW_Player_XPosLo	; \ Don't fire if mario is next to generator
	SBC.w !RAM_SMW_ShooterSpr_XPosLo,x
	CLC
	ADC.b #$11
	CMP.b #$22
	BCC.b Return02B4DD
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	; \ Get an index to an unused sprite slot, return if all slots full
	BMI.b Return02B4DD		; / After: Y has index of sprite being generated
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Only shoot every #$80 frames
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b #!Define_SMW_NorSprStatus01_Init	; \ Sprite status = Initialization
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr01C_BulletBill	; \ New sprite = Bullet Bill
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.w !RAM_SMW_ShooterSpr_XPosLo,x	; \ Set x position for new sprite
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_ShooterSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.w !RAM_SMW_ShooterSpr_YPosLo,x	; \ Set y position for new sprite
	SEC				; | (y position of generator - 1)
	SBC.b #$01
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_ShooterSpr_YPosHi,x
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX				; \ Before: X must have index of sprite being generated
	TYX				; | Routine clears *all* old sprite values...
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; | ...and loads in new values for the 6 main sprite tables
	PLX
	JSR.w ShowShooterSmoke		; Display smoke graphic
Return02B4DD:
	RTS

ShowShooterSmoke:
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot	; \ Find a free slot to display effect
Loop:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y
	BEQ.b SetShooterSmoke
	DEY
	BPL.b Loop
	RTS				; / Return if no free slots

ShooterSmokeDispX:
	db $F4,$0C

SetShooterSmoke:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr01_PuffOfSmoke	; \ Set effect graphic to smoke graphic
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y
	LDA.w !RAM_SMW_ShooterSpr_YPosLo,x	; \ Smoke y position = generator y position
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y
	LDA.b #$1B			; \ Set time to show smoke
	STA.w !RAM_SMW_SmokeSpr_Timer,y
	LDA.w !RAM_SMW_ShooterSpr_XPosLo,x	; \ Load generator x position and store it for later
	PHA
	LDA.b !RAM_SMW_Player_XPosLo	; \ Determine which side of the generator mario is on
	CMP.w !RAM_SMW_ShooterSpr_XPosLo,x
	LDA.b !RAM_SMW_Player_XPosHi
	SBC.w !RAM_SMW_ShooterSpr_XPosHi,x
	LDX.b #$00
	BCC.b CODE_02B50E
	INX
CODE_02B50E:
	PLA				; \ Set smoke x position from generator position
	CLC
if ver_is_japanese(!Define_Global_ROMToAssemble)
	ADC.l ShooterSmokeDispX,x
else
	ADC.w ShooterSmokeDispX,x
endif
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ShooterSpr02_TorpedoShooter(Address)
namespace SMW_ShooterSpr02_TorpedoShooter
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !RAM_SMW_ShooterSpr_ShootTimer,x	;\ If the shooter timer isn't
	BNE.b Return02B42C		;/ 00, return
	LDA.b #$50			;\ reset the timer
	STA.w !RAM_SMW_ShooterSpr_ShootTimer,x	;/
	LDA.w !RAM_SMW_ShooterSpr_YPosLo,x	;\
	CMP.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	LDA.w !RAM_SMW_ShooterSpr_YPosHi,x	;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;| if below the Y screen boundry,
	BNE.b SMW_ProcessShooterSprites_Return02B3AA	;/return
	LDA.w !RAM_SMW_ShooterSpr_XPosLo,x	;\
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|if below the X screen boundry,
	LDA.w !RAM_SMW_ShooterSpr_XPosHi,x	;|return
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;|
	BNE.b SMW_ProcessShooterSprites_Return02B3AA	;/
	LDA.w !RAM_SMW_ShooterSpr_XPosLo,x	;\
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	CLC				;|if a certain amount in front the
	ADC.b #$10			;|X boundry, (close to,)
	CMP.b #$20			;|
	BCC.b Return02B42C		;/return
	JSL.l SMW_FindFreeNormalSpriteSlot_LowPriority	;\ make sure spot is available
	BMI.b Return02B42C		;/
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Sprite status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #!Define_SMW_SpriteID_NorSpr044_TorpedoTed	; \ Sprite = Torpedo Ted
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.w !RAM_SMW_ShooterSpr_XPosLo,x	; \ Sprite position = Shooter position
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_ShooterSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.w !RAM_SMW_ShooterSpr_YPosLo,x
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_ShooterSpr_YPosHi,x
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	PHX
	TYX				; X = sprite index
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Setup sprite tables
	JSR.w SMW_CheckPlayerPositionRelativeToSprite_CopyOfBank02_X	; \ Direction = Towards Mario
	TYA
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	STA.b !RAM_SMW_Misc_ScratchRAM00	; $00 = sprite direction
	LDA.b #$30			; \ Set time to stay behind objects
	STA.w !RAM_SMW_NorSpr044_TorpedoTed_ReleaseAnimationTimer,x
	PLX				; X = shooter index
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_02B424:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_02B42D
	DEY
	BPL.b CODE_02B424
Return02B42C:
	RTS				; / Return if no free slots

CODE_02B42D:
	LDA.b #!Define_SMW_SpriteID_ExtSpr08_LauncherArm	; \ Extended sprite = Torpedo Ted arm
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	LDA.w !RAM_SMW_ShooterSpr_XPosLo,x	;\
	CLC				;|
	ADC.b #$08			;|Make hand a little to the right of the shooter
	STA.w !RAM_SMW_ExtSpr_XPosLo,y	;/ (center hand)
	LDA.w !RAM_SMW_ShooterSpr_XPosHi,x	;\
	ADC.b #$00			;| handle the high byte
	STA.w !RAM_SMW_ExtSpr_XPosHi,y	;/
	LDA.w !RAM_SMW_ShooterSpr_YPosLo,x	;\
	SEC				;|make hand a little below the shooter
	SBC.b #$09			;|
	STA.w !RAM_SMW_ExtSpr_YPosLo,y	;/
	LDA.w !RAM_SMW_ShooterSpr_YPosHi,x	;\
	SBC.b #$00			;| handle the high byte
	STA.w !RAM_SMW_ExtSpr_YPosHi,y	;/
	LDA.b #$90			;\ Fireball hit frame counter?
	STA.w !RAM_SMW_ExtSpr08_LauncherArm_VerticalDirectionTimer,y	;/ what?
	PHX				; preserve X
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w InitialXSpeed,x							;\ Note: The launcher arm doesn't move horizontally, but this seems to have a purpose. Check SMW_GenericExtendedSpriteGFXRt_Main.
	STA.w !RAM_SMW_ExtSpr_XSpeed,y						;/
	PLX
	RTS

InitialXSpeed:
	db $01,$FF

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_ProcessSpinningCoinSprites(Address)
namespace SMW_ProcessSpinningCoinSprites
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #!Define_SMW_MaxSpinningCoinSpriteSlot
CODE_0299D4:
	STX.w !RAM_SMW_NorSpr_CurrentSlotID
	LDA.w !RAM_SMW_BlockCoinSpr_SlotID,x
	BEQ.b CODE_0299DF
	JSR.w Sub
CODE_0299DF:
	DEX
	BPL.b CODE_0299D4
	RTS

CODE_0299E3:
	LDA.b #$00
	STA.w !RAM_SMW_BlockCoinSpr_SlotID,x
	RTS

; OAM indexes for the spinning coins that come out of ? blocks. The next
; index after each of these is also used (the GFX routine will store to
; $0200,y and sometimes to $0204,y as well).
DATA_0299E9:
	db $30,$38,$40,$48,$EC,$EA,$E8,$EC

; Main handling routine for the spinning coins that come out of ? blocks.
; $029A4F is a fourth of the rolling coin tilemap. This tile is 16x16.
; $029A54 is the properties of the rolling coin flying from question blocks.
; $029A6B controls the frames, changing to [D0 00] or [EA EA] will cause all
; 4 frames to only use 1 16x16 tile. Have to combine with $029A4F and
; $029A6E (same tile) for the complete effect. $029A6E is three fourths of
; the tilemap of the rolling coin. These tiles are 8x8, but they're
; duplicated and placed above each other, making it 8x16.
Sub:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_029A08
	JSR.w UpdateSpinningCoinSpriteYPosition	;>Handle speed
	LDA.w !RAM_SMW_BlockCoinSpr_YSpeed,x	;\Gravity
	CLC				;|
	ADC.b #$03			;|
	STA.w !RAM_SMW_BlockCoinSpr_YSpeed,x	;/
	CMP.b #$20			;\If falling not fast enough, branch to following code
	BMI.b CODE_029A08		;/
	JMP.w CODE_029AA8		;>If did fall fast enough, the coin disappears and is collected by player.

CODE_029A08:
	LDA.w !RAM_SMW_BlockCoinSpr_LayerIndex,x	;\Index layer mode into Y register
	ASL				;|
	ASL				;|
	TAY				;/
	LDA.w !RAM_SMW_Mirror_CurrentLayer1YPosLo,y	;\Store layer position into scratch RAM
	STA.b !RAM_SMW_Misc_ScratchRAM02	;|$02 = Y position low
	LDA.w !RAM_SMW_Mirror_CurrentLayer1XPosLo,y	;|$03 = X position low
	STA.b !RAM_SMW_Misc_ScratchRAM03	;|$04 = Y position high
	LDA.w !RAM_SMW_Mirror_CurrentLayer1YPosHi,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM04	;/
	LDA.w !RAM_SMW_BlockCoinSpr_YPosLo,x	;\Check if offscreen vertically, if so,
	CMP.b !RAM_SMW_Misc_ScratchRAM02	;|do nothing
	LDA.w !RAM_SMW_BlockCoinSpr_YPosHi,x	;|
	SBC.b !RAM_SMW_Misc_ScratchRAM04	;|
	BNE.b Return029A6D		;/
	LDA.w !RAM_SMW_BlockCoinSpr_XPosLo,x	;\Check if offscreen horizontally, if so
	SEC				;|erase the sprite (note that this is 8-bit
	SBC.b !RAM_SMW_Misc_ScratchRAM03	;|meaning if it is off the border but in the next/previous
	CMP.b #$F8			;|screen could still assume this is onscreen)
	BCS.b CODE_0299E3		;/
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>$00 = X position (8-bit) within borders of screen.
	LDA.w !RAM_SMW_BlockCoinSpr_YPosLo,x	;\$01 = Y position (8-bit) within borders of screen.
	SEC				;|
	SBC.b !RAM_SMW_Misc_ScratchRAM02	;|
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDY.w DATA_0299E9,x
	STY.b !RAM_SMW_Misc_ScratchRAM0F							;\ Optimization: Store Y into !RAM_SMW_Misc_ScratchRAM0F, then load !RAM_SMW_Misc_ScratchRAM0F into Y?
	LDY.b !RAM_SMW_Misc_ScratchRAM0F							;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\OAM X position
	STA.w SMW_OAMBuffer[$00].XDisp,y	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\OAM Y position
	STA.w SMW_OAMBuffer[$00].YDisp,y	;/
	LDA.b #$E8			;\Tile number
	STA.w SMW_OAMBuffer[$00].Tile,y	;/
	LDA.b #$04			;\YXPPCCCT
	ORA.b !RAM_SMW_Sprites_TilePriority	;|
	STA.w SMW_OAMBuffer[$00].Prop,y	;/
	TYA				;\Handle size bit
	LSR				;|(this will also affect the high bit X)
	LSR				;|
	TAY				;|
	LDA.b #$02			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;/
	TXA											;\ Optimization: If this were moved to be before the TYA, then storing to !RAM_SMW_Misc_ScratchRAM0F would be unncessary
	CLC											;|
	ADC.b !RAM_SMW_Counter_LocalFrames							;|
	LSR											;|
	LSR											;|
	AND.b #$03										;|
	BNE.b GFXRt										;/
Return029A6D:
	RTS

RollingCoinTiles:
	db $EA,$FA,$EA

GFXRt:
	LDY.b !RAM_SMW_Misc_ScratchRAM0F							; Optimization: This !RAM_SMW_Misc_ScratchRAM0F could be removed if the above optimization is done
	PHX				;\Each image of the spinning coin
	TAX				;|have different displacements
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;|as to keep it "centered"
	CLC				;|
	ADC.b #$04			;|
	STA.w SMW_OAMBuffer[$00].XDisp,y	;|
	STA.w SMW_OAMBuffer[$01].XDisp,y	;/>And write the other half of the spinning coin
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\Same as above but for Y
	CLC				;|
	ADC.b #$08			;|
	STA.w SMW_OAMBuffer[$01].YDisp,y	;/
	LDA.l RollingCoinTiles-$01,x
	STA.w SMW_OAMBuffer[$00].Tile,y	;\Write both
	STA.w SMW_OAMBuffer[$01].Tile,y	;/
	LDA.w SMW_OAMBuffer[$00].Prop,y	;\Y-flip the bottom half.
	ORA.b #$80			;|
	STA.w SMW_OAMBuffer[$01].Prop,y	;/
	TYA				;\And set the size of each half
	LSR				;|to 8x8.
	LSR				;|
	TAY				;|
	LDA.b #$00			;|
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y	;|
	STA.w SMW_OAMTileSizeBuffer[$01].Slot,y	;/
	PLX
	RTS

CODE_029AA8:
	JSL.l SMW_CheckForAvailableScoreSpriteSlot_Main	; Find next usable location in score sprite table
	LDA.b #$01
	STA.w !RAM_SMW_ScoreSpr_SpriteID,y	; add a "10" score sprite
	LDA.w !RAM_SMW_BlockCoinSpr_YPosLo,x
	STA.w !RAM_SMW_ScoreSpr_YPosLo,y	; set Yposition low byte
	LDA.w !RAM_SMW_BlockCoinSpr_YPosHi,x
	STA.w !RAM_SMW_ScoreSpr_YPosHi,y	; set Ypos high byte
	LDA.w !RAM_SMW_BlockCoinSpr_XPosLo,x
	STA.w !RAM_SMW_ScoreSpr_XPosLo,y	; set Xpos low byte
	LDA.w !RAM_SMW_BlockCoinSpr_XPosHi,x
	STA.w !RAM_SMW_ScoreSpr_XPosHi,y	; set Xpos high byte
	LDA.b #$30
	STA.w !RAM_SMW_ScoreSpr_YSpeed,y	; set initial speed to 30
	LDA.w !RAM_SMW_BlockCoinSpr_LayerIndex,x
	STA.w !RAM_SMW_ScoreSpr_LayerIndex,y
	JSR.w CODE_029ADA
	JMP.w CODE_0299E3		; Puts #$00 into $17D0 and returns

CODE_029ADA:
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot	; for (c=3;c>=0;c--)
CODE_029ADC:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y	; {
	BEQ.b CODE_029AE5		;  check if there is empty space in smoke/dust sprite table
	DEY
	BPL.b CODE_029ADC		; }
	RTS				;  if no empty space, return

CODE_029AE5:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr05_Glitter	; if there's an empty space, make it 5 (glitter sprite)
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y
	LDA.w !RAM_SMW_BlockCoinSpr_LayerIndex,x	;  nots sure what 17E4 is used for yet - copied from $1933
	LSR				; carryout = $17E4 % 2
	PHP
	LDA.w !RAM_SMW_BlockCoinSpr_XPosLo,x	; get x coordinate low byte
	BCC.b CODE_029AF6		; if carryout == 1
	SBC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo	;   x-coord -= $26
CODE_029AF6:
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y	; store x-coord
	LDA.w !RAM_SMW_BlockCoinSpr_YPosLo,x	; get y coordinate low byte
	PLP
	BCC.b CODE_029B01		; if carryout == 1
	SBC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo	;   y-coord -=$28
CODE_029B01:
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y	; store y-coord
	LDA.b #$10
	STA.w !RAM_SMW_SmokeSpr_Timer,y	; duration = 10
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_ProcessSpinningCoinSprites(Address)
namespace SMW_ProcessSpinningCoinSprites
%InsertMacroAtXPosition(<Address>)

; The subroutine that updates the Y position of the spinning coin coming
; from a ? block.
UpdateSpinningCoinSpriteYPosition:
	LDA.w !RAM_SMW_BlockCoinSpr_YSpeed,x
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC.w !RAM_SMW_BlockCoinSpr_SubYPos,x
	STA.w !RAM_SMW_BlockCoinSpr_SubYPos,x
	PHP
	LDY.b #$00
	LDA.w !RAM_SMW_BlockCoinSpr_YSpeed,x
	LSR
	LSR
	LSR
	LSR
	CMP.b #$08
	BCC.b +
	ORA.b #$F0
	DEY
+:
	PLP
	ADC.w !RAM_SMW_BlockCoinSpr_YPosLo,x
	STA.w !RAM_SMW_BlockCoinSpr_YPosLo,x
	TYA
	ADC.w !RAM_SMW_BlockCoinSpr_YPosHi,x
	STA.w !RAM_SMW_BlockCoinSpr_YPosHi,x
	RTS
namespace off
endmacro

macro INLINEDATATABLE_RT09_SMW_EmptySpace(Address)
!SMW_UBytes = $44 : !SMW_JBytes = $26 : !SMW_E1Bytes = $44 : !SMW_E2Bytes = $44 : !SMASW_UBytes = $44 : !SMASW_EBytes = $44 : !SMW_ARCADEBytes = $44
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 09)
endmacro

macro INLINEDATATABLE_RT10_SMW_EmptySpace(Address)
!SMW_UBytes = $62 : !SMW_JBytes = $46 : !SMW_E1Bytes = $62 : !SMW_E2Bytes = $62 : !SMASW_UBytes = $62 : !SMASW_EBytes = $62 : !SMW_ARCADEBytes = $62
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 10)
endmacro

macro INLINEDATATABLE_RT11_SMW_EmptySpace(Address)
!SMW_UBytes = $1E : !SMW_JBytes = $05 : !SMW_E1Bytes = $24 : !SMW_E2Bytes = $30 : !SMASW_UBytes = $1E : !SMASW_EBytes = $30 : !SMW_ARCADEBytes = $1E
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 11)
endmacro
