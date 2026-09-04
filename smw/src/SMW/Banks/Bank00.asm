;####################################################################
;# Bank00.asm -- boot, main loop, game modes, NMI/IRQ, DMA and status bar.
;#
;# 176 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################

macro SMWBank00Macros(StartBank, EndBank)
%BANK_START(<StartBank>)								; Info: Start addresses of each macro (USA version only)
ROUTINE_RT00_SMW_InitAndMainLoop:	%ROUTINE_RT00_SMW_InitAndMainLoop(NULLROM)					; $008000
ROUTINE_RT00_SMW_HandleSPCUploads:	%ROUTINE_RT00_SMW_HandleSPCUploads(NULLROM)					; $008079
ROUTINE_SMW_VBlankRoutine:		%ROUTINE_SMW_VBlankRoutine(NULLROM)						; $00816A
ROUTINE_SMW_IRQRoutine:			%ROUTINE_SMW_IRQRoutine(NULLROM)						; $008374
ROUTINE_SMW_Mode7Layer1Scroll:		%ROUTINE_SMW_Mode7Layer1Scroll(NULLROM)					; $0083F3
ROUTINE_SMW_SetMode7PPUPointersAndLayer1Scroll:	%ROUTINE_SMW_SetMode7PPUPointersAndLayer1Scroll(NULLROM)			; $008416
ROUTINE_SMW_WaitForHBlank:	%ROUTINE_SMW_WaitForHBlank(NULLROM)						; $008439
ROUTINE_SMW_UploadOAMBuffer:	%ROUTINE_SMW_UploadOAMBuffer(NULLROM)						; $008449
ROUTINE_SMW_CompressOAMTileSizeBuffer:	%ROUTINE_SMW_CompressOAMTileSizeBuffer(NULLROM)				; $008475
ROUTINE_RT00_SMW_LoadStripeImage:	%ROUTINE_RT00_SMW_LoadStripeImage(NULLROM)					; $0084C8
ROUTINE_SMW_ClearLayer3Tilemap:	%ROUTINE_SMW_ClearLayer3Tilemap(NULLROM)					; $0085FA
ROUTINE_SMW_PollJoypadInputs:	%ROUTINE_SMW_PollJoypadInputs(NULLROM)						; $008650
ROUTINE_RT01_SMW_GameMode14_InLevel:	%ROUTINE_RT01_SMW_GameMode14_InLevel(NULLROM)					; $0086C7
ROUTINE_SMW_ExecutePtr:	%ROUTINE_SMW_ExecutePtr(NULLROM)						; $0086DF
ROUTINE_RT01_SMW_LoadStripeImage:	%ROUTINE_RT01_SMW_LoadStripeImage(NULLROM)					; $00871E
ROUTINE_SMW_UploadLevelLayer1And2Tilemaps:	%ROUTINE_SMW_UploadLevelLayer1And2Tilemaps(NULLROM)				; $0087AD
ROUTINE_SMW_InitializeFirst8KBOfRAM:	%ROUTINE_SMW_InitializeFirst8KBOfRAM(NULLROM)					; $008A4E
ROUTINE_SMW_SetStandardPPUSettings:	%ROUTINE_SMW_SetStandardPPUSettings(NULLROM)					; $008A79
ROUTINE_SMW_ManipulateMode7Image:	%ROUTINE_SMW_ManipulateMode7Image(NULLROM)					; $008AB4
DATATABLE_SMW_StatusBarTilemap:	%DATATABLE_SMW_StatusBarTilemap(NULLROM)					; $008C81
ROUTINE_SMW_InitializeStatusBarTilemap:	%ROUTINE_SMW_InitializeStatusBarTilemap(NULLROM)				; $008CFF
ROUTINE_SMW_UploadStatusBarTilemap:	%ROUTINE_SMW_UploadStatusBarTilemap(NULLROM)					; $008DAC
ROUTINE_RT00_SMW_UpdateStatusBarCounters:	%ROUTINE_RT00_SMW_UpdateStatusBarCounters(NULLROM)				; $008DF5
ROUTINE_RT00_SMW_HexToDec:	%ROUTINE_RT00_SMW_HexToDec(NULLROM)						; $009045
ROUTINE_RT01_SMW_UpdateStatusBarCounters:	%ROUTINE_RT01_SMW_UpdateStatusBarCounters(NULLROM)				; $009051
ROUTINE_RT01_SMW_DrawLoadingLetters:	%ROUTINE_RT01_SMW_DrawLoadingLetters(NULLROM)					; $0090D1
ROUTINE_RT01_SMW_GameMode12_PrepareLevel:	%ROUTINE_RT01_SMW_GameMode12_PrepareLevel(NULLROM)				; $00919B
ROUTINE_RT00_SMW_DrawLoadingLetters:	%ROUTINE_RT00_SMW_DrawLoadingLetters(NULLROM)					; $0091B1
ROUTINE_SMW_UpdateEntirePalette:	%ROUTINE_SMW_UpdateEntirePalette(NULLROM)					; $00922F
ROUTINE_SMW_SetupHDMAWindowingEffects:	%ROUTINE_SMW_SetupHDMAWindowingEffects(NULLROM)				; $009250
ROUTINE_SMW_SetEnemyRollcallParallaxHDMA:	%ROUTINE_SMW_SetEnemyRollcallParallaxHDMA(NULLROM)				; $0092B2
ROUTINE_RT01_SMW_InitAndMainLoop:	%ROUTINE_RT01_SMW_InitAndMainLoop(NULLROM)					; $009322
ROUTINE_SMW_TurnOffIO:	%ROUTINE_SMW_TurnOffIO(NULLROM)						; $00937D
ROUTINE_SMW_GameMode00_LoadNintendoPresents:	%ROUTINE_SMW_GameMode00_LoadNintendoPresents(NULLROM)				; $009389
ROUTINE_SMW_SetVisibleLayers:	%ROUTINE_SMW_SetVisibleLayers(NULLROM)						; $0093FD
ROUTINE_SMW_GameMode01_ShowNintendoPresents:	%ROUTINE_SMW_GameMode01_ShowNintendoPresents(NULLROM)				; $00940F
ROUTINE_SMW_GameMode06_CircleEffect:	%ROUTINE_SMW_GameMode06_CircleEffect(NULLROM)					; $00941B
ROUTINE_RT00_SMW_GameMode19_Cutscene:	%ROUTINE_RT00_SMW_GameMode19_Cutscene(NULLROM)					; $009451
ROUTINE_SMW_UploadBigLayer3LettersToVRAM:	%ROUTINE_SMW_UploadBigLayer3LettersToVRAM(NULLROM)				; $00955E
ROUTINE_RT00_SMW_GameMode1D_LoadYoshisHouse:	%ROUTINE_RT00_SMW_GameMode1D_LoadYoshisHouse(NULLROM)				; $009583
ROUTINE_RT00_SMW_GameMode21_DelayEnemyRollcall:	%ROUTINE_RT00_SMW_GameMode21_DelayEnemyRollcall(NULLROM)			; $0095BC
ROUTINE_SMW_GameMode23_LoadEnemyRollcallScreen:	%ROUTINE_SMW_GameMode23_LoadEnemyRollcallScreen(NULLROM)			; $0095C1
ROUTINE_RT00_SMW_GameMode25_ShowEnemyRollcallScreen:	%ROUTINE_RT00_SMW_GameMode25_ShowEnemyRollcallScreen(NULLROM)			; $00962C
ROUTINE_SMW_GameMode27_LoadTheEnd:	%ROUTINE_SMW_GameMode27_LoadTheEnd(NULLROM)					; $00963D
ROUTINE_SMW_GameMode29_DoNothingOnTheEndScreen:	%ROUTINE_SMW_GameMode29_DoNothingOnTheEndScreen(NULLROM)			; $00968D
ROUTINE_SMW_GameMode10_BufferLevelLoadMessage:	%ROUTINE_SMW_GameMode10_BufferLevelLoadMessage(NULLROM)			; $00968E
ROUTINE_RT00_SMW_GameMode11_LoadSublevel:	%ROUTINE_RT00_SMW_GameMode11_LoadSublevel(NULLROM)				; $0096AE
ROUTINE_RT01_SMW_OverworldPrompt03_OverworldLifeExchanger:	%ROUTINE_RT01_SMW_OverworldPrompt03_OverworldLifeExchanger(NULLROM)		; $00974C
ROUTINE_SMW_GameMode16_LoadDeathMessage:	%ROUTINE_SMW_GameMode16_LoadDeathMessage(NULLROM)				; $009750
ROUTINE_SMW_GameMode17_ShowDeathMessage:	%ROUTINE_SMW_GameMode17_ShowDeathMessage(NULLROM)				; $009759
ROUTINE_RT02_SMW_GameMode12_PrepareLevel:	%ROUTINE_RT02_SMW_GameMode12_PrepareLevel(NULLROM)				; $0097BC
ROUTINE_RT02_SMW_GameMode14_InLevel:	%ROUTINE_RT02_SMW_GameMode14_InLevel(NULLROM)					; $009875
ROUTINE_SMW_UploadMode7KoopaBossesAndLavaAnimation:	%ROUTINE_SMW_UploadMode7KoopaBossesAndLavaAnimation(NULLROM)			; $009891
ROUTINE_RT03_SMW_GameMode12_PrepareLevel:	%ROUTINE_RT03_SMW_GameMode12_PrepareLevel(NULLROM)				; $009925
ROUTINE_RT03_SMW_GameMode14_InLevel:	%ROUTINE_RT03_SMW_GameMode14_InLevel(NULLROM)					; $009A4E
ROUTINE_SMW_CheckWhichControllersArePluggedIn:	%ROUTINE_SMW_CheckWhichControllersArePluggedIn(NULLROM)			; $009A74
ROUTINE_RT00_SMW_GameMode04_PrepareTitleScreen:	%ROUTINE_RT00_SMW_GameMode04_PrepareTitleScreen(NULLROM)			; $009A8B
ROUTINE_RT00_SMW_HandleMenuCursor:	%ROUTINE_RT00_SMW_HandleMenuCursor(NULLROM)					; $009AC8
ROUTINE_SMW_GameMode09_EraseFile:	%ROUTINE_SMW_GameMode09_EraseFile(NULLROM)					; $009B17
ROUTINE_SMW_DisplayingContinueEnd:	%ROUTINE_SMW_DisplayingContinueEnd(NULLROM)					; $009B80
ROUTINE_RT01_SMW_OverworldPrompt07_DisplayingSavePrompt:	%ROUTINE_RT01_SMW_OverworldPrompt07_DisplayingSavePrompt(NULLROM)		; $009BA8
ROUTINE_RT01_SMW_OverworldPrompt0B_ShowQuitToTitleScreenPrompt:	%ROUTINE_RT01_SMW_OverworldPrompt0B_ShowQuitToTitleScreenPrompt(NULLROM)	; N/A
ROUTINE_SMW_SaveGame:	%ROUTINE_SMW_SaveGame(NULLROM)							; $009BC9
ROUTINE_SMW_CloseOverworldPrompt:	%ROUTINE_SMW_CloseOverworldPrompt(NULLROM)					; $009C13
ROUTINE_SMW_GameMode07_TitleScreenDemo:	%ROUTINE_SMW_GameMode07_TitleScreenDemo(NULLROM)				; $009C1F
DATATABLE_SMW_SaveFileLocations:	%DATATABLE_SMW_SaveFileLocations(NULLROM)					; $009CCB
ROUTINE_SMW_GameMode08_FileSelect:	%ROUTINE_SMW_GameMode08_FileSelect(NULLROM)					; $009CD1
ROUTINE_SMW_FileSelectColorMath:	%ROUTINE_SMW_FileSelectColorMath(NULLROM)					; $009D30
ROUTINE_SMW_BufferFileSelectText:	%ROUTINE_SMW_BufferFileSelectText(NULLROM)					; $009D38
ROUTINE_SMW_GameMode0A_PlayerSelect:	%ROUTINE_SMW_GameMode0A_PlayerSelect(NULLROM)					; $009DFA
ROUTINE_RT01_SMW_HandleMenuCursor:	%ROUTINE_RT01_SMW_HandleMenuCursor(NULLROM)					; $009E6A
ROUTINE_SMW_InitializeSaveData:	%ROUTINE_SMW_InitializeSaveData(NULLROM)					; $009EE0
ROUTINE_SMW_SetKeepGameModeActiveTimer:	%ROUTINE_SMW_SetKeepGameModeActiveTimer(NULLROM)				; $009F29
ROUTINE_SMW_GameModeXX_FadeInOrOut:	%ROUTINE_SMW_GameModeXX_FadeInOrOut(NULLROM)					; $009F2F
ROUTINE_SMW_GameMode28_ShowTheEnd:	%ROUTINE_SMW_GameMode28_ShowTheEnd(NULLROM)					; $009F7C
ROUTINE_RT00_SMW_InitializeLevelLayer3:	%ROUTINE_RT00_SMW_InitializeLevelLayer3(NULLROM)				; $009F88
ROUTINE_RT00_SMW_GameMode0C_LoadOverworld:	%ROUTINE_RT00_SMW_GameMode0C_LoadOverworld(NULLROM)				; $00A06B
ROUTINE_SMW_LoadSaveBufferData:	%ROUTINE_SMW_LoadSaveBufferData(NULLROM)					; $00A195
ROUTINE_SMW_ClearOverworldAndCutsceneRAM:	%ROUTINE_SMW_ClearOverworldAndCutsceneRAM(NULLROM)				; $00A1A6
ROUTINE_RT00_SMW_GameMode0E_ShowOverworld:	%ROUTINE_RT00_SMW_GameMode0E_ShowOverworld(NULLROM)				; $00A1BE
ROUTINE_RT00_SMW_GameMode14_InLevel:	%ROUTINE_RT00_SMW_GameMode14_InLevel(NULLROM)					; $00A1CE
ROUTINE_SMW_UpdateCurrentPlayerPositionRAM:	%ROUTINE_SMW_UpdateCurrentPlayerPositionRAM(NULLROM)				; $00A2F3
ROUTINE_RT00_SMW_UploadPlayerGFX:	%ROUTINE_RT00_SMW_UploadPlayerGFX(NULLROM)					; $00A300
ROUTINE_SMW_UploadLevelAnimations:	%ROUTINE_SMW_UploadLevelAnimations(NULLROM)					; $00A390
ROUTINE_SMW_RestoreSP1AfterMarioStart:	%ROUTINE_SMW_RestoreSP1AfterMarioStart(NULLROM)				; $00A436
ROUTINE_RT00_SMW_UpdatePaletteFromIndexedTable:	%ROUTINE_RT00_SMW_UpdatePaletteFromIndexedTable(NULLROM)			; $00A47F
ROUTINE_SMW_UploadOverworldAnimations:	%ROUTINE_SMW_UploadOverworldAnimations(NULLROM)				; $00A4E3
ROUTINE_SMW_UploadOverworldLayer1And2Tilemaps:	%ROUTINE_SMW_UploadOverworldLayer1And2Tilemaps(NULLROM)			; $00A521
ROUTINE_RT00_SMW_BufferPalettesRoutines:	%ROUTINE_RT00_SMW_BufferPalettesRoutines(NULLROM)				; $00A594
ROUTINE_RT00_SMW_GameMode12_PrepareLevel:	%ROUTINE_RT00_SMW_GameMode12_PrepareLevel(NULLROM)				; $00A59C
ROUTINE_SMW_InitializeLevelTileAnimations:	%ROUTINE_SMW_InitializeLevelTileAnimations(NULLROM)				; $00A5F9
ROUTINE_SMW_InitializeLevelRAM:	%ROUTINE_SMW_InitializeLevelRAM(NULLROM)					; $00A60D
ROUTINE_RT01_SMW_GameMode11_LoadSublevel:	%ROUTINE_RT01_SMW_GameMode11_LoadSublevel(NULLROM)				; $00A796
ROUTINE_SMW_UploadLoadingLettersTiles:	%ROUTINE_SMW_UploadLoadingLettersTiles(NULLROM)				; $00A7C2
ROUTINE_SMW_BufferLoadingLetterTiles:	%ROUTINE_SMW_BufferLoadingLetterTiles(NULLROM)					; $00A82D
ROUTINE_SMW_UploadGraphicsFiles:	%ROUTINE_SMW_UploadGraphicsFiles(NULLROM)					; $00A8C3
ROUTINE_RT01_SMW_BufferPalettesRoutines:	%ROUTINE_RT01_SMW_BufferPalettesRoutines(NULLROM)				; $00ABD3
ROUTINE_RT01_SMW_UpdatePaletteFromIndexedTable:	%ROUTINE_RT01_SMW_UpdatePaletteFromIndexedTable(NULLROM)			; $00AE41
ROUTINE_SMW_HandlePaletteFades:	%ROUTINE_SMW_HandlePaletteFades(NULLROM)					; $00AE65
ROUTINE_RT02_SMW_OverworldEventProcess04_FadeInLayer2Tile:	%ROUTINE_RT02_SMW_OverworldEventProcess04_FadeInLayer2Tile(NULLROM)		; $00B006
ROUTINE_RT01_SMW_PlayerState00_Normal:	%ROUTINE_RT01_SMW_PlayerState00_Normal(NULLROM)				; $00B03E
INLINEDATATABLE_RT00_SMW_EmptySpace:	%INLINEDATATABLE_RT00_SMW_EmptySpace(NULLROM)					; $00B091
DATATABLE_SMW_GlobalPalettes:	%DATATABLE_SMW_GlobalPalettes(NULLROM)						; $00B0A0
ROUTINE_SMW_GraphicsDecompressionRoutines:	%ROUTINE_SMW_GraphicsDecompressionRoutines(NULLROM)				; $00B882
INLINEDATATABLE_RT01_SMW_EmptySpace:	%INLINEDATATABLE_RT01_SMW_EmptySpace(NULLROM)					; $00BA4D
DATATABLE_SMW_LevelDataLayoutTables:	%DATATABLE_SMW_LevelDataLayoutTables(NULLROM)					; $00BA60
ROUTINE_SMW_GenerateTile:	%ROUTINE_SMW_GenerateTile(NULLROM)						; $00BEB0
ROUTINE_SMW_SetItemMemoryBit:	%ROUTINE_SMW_SetItemMemoryBit(NULLROM)						; $00BFFF
ROUTINE_SMW_GenericPage00Tile:	%ROUTINE_SMW_GenericPage00Tile(NULLROM)					; $00C063
ROUTINE_SMW_GenericPage01Tile:	%ROUTINE_SMW_GenericPage01Tile(NULLROM)					; $00C0AA
ROUTINE_SMW_EraseYoshiCoin:	%ROUTINE_SMW_EraseYoshiCoin(NULLROM)						; $00C1AC
ROUTINE_SMW_ChangeNetDoorTiles:	%ROUTINE_SMW_ChangeNetDoorTiles(NULLROM)					; $00C29E
ROUTINE_SMW_EraseLargeSwitch:	%ROUTINE_SMW_EraseLargeSwitch(NULLROM)						; $00C3D1
INLINEDATATABLE_RT02_SMW_EmptySpace:	%INLINEDATATABLE_RT02_SMW_EmptySpace(NULLROM)					; $00C453
ROUTINE_RT04_SMW_GameMode14_InLevel:	%ROUTINE_RT04_SMW_GameMode14_InLevel(NULLROM)					; $00C460
ROUTINE_SMW_PlayerState0B_RescuedPeach:	%ROUTINE_SMW_PlayerState0B_RescuedPeach(NULLROM)				; $00C5B5
ROUTINE_SMW_PlayerState0C_CastleDestructionMoves:	%ROUTINE_SMW_PlayerState0C_CastleDestructionMoves(NULLROM)			; $00C5E1
ROUTINE_SMW_PlayerState08_WarpToYoshiWingsBonus:	%ROUTINE_SMW_PlayerState08_WarpToYoshiWingsBonus(NULLROM)			; $00C7F9
ROUTINE_SMW_PlayerState0A_NoYoshiCutscene:	%ROUTINE_SMW_PlayerState0A_NoYoshiCutscene(NULLROM)				; $00C848
ROUTINE_RT02_SMW_PlayerState00_Normal:	%ROUTINE_RT02_SMW_PlayerState00_Normal(NULLROM)				; $00C915
ROUTINE_SMW_UpdateHDMAWindowBuffer:	%ROUTINE_SMW_UpdateHDMAWindowBuffer(NULLROM)					; $00CA61
ROUTINE_RT00_SMW_PlayerState00_Normal:	%ROUTINE_RT00_SMW_PlayerState00_Normal(NULLROM)				; $00CC5C
ROUTINE_RT00_SMW_SetPlayerPose:	%ROUTINE_RT00_SMW_SetPlayerPose(NULLROM)					; $00CE79
ROUTINE_SMW_InitializeCapeSwingOrNetPunch:	%ROUTINE_SMW_InitializeCapeSwingOrNetPunch(NULLROM)				; $00D034
ROUTINE_SMW_CheckForPowerUpSpecificPlayerAttacks:	%ROUTINE_SMW_CheckForPowerUpSpecificPlayerAttacks(NULLROM)			; $00D062
ROUTINE_SMW_PlayerState09_Death:	%ROUTINE_SMW_PlayerState09_Death(NULLROM)					; $00D0AE
ROUTINE_SMW_PlayerStateXX_PowerupAnimations:	%ROUTINE_SMW_PlayerStateXX_PowerupAnimations(NULLROM)				; $00D11D
ROUTINE_SMW_PlayerStateXX_EnterPipe:	%ROUTINE_SMW_PlayerStateXX_EnterPipe(NULLROM)					; $00D18D
ROUTINE_SMW_IncrementSublevelsEnteredAndPrepareToLoadSublevel:	%ROUTINE_SMW_IncrementSublevelsEnteredAndPrepareToLoadSublevel(NULLROM)	; $00D273
ROUTINE_SMW_UnusedAddToWarpPipeTimerRoutine:	%ROUTINE_SMW_UnusedAddToWarpPipeTimerRoutine(NULLROM)				; $00D27C
ROUTINE_SMW_PlayerState07_ShootOutOfPipe:	%ROUTINE_SMW_PlayerState07_ShootOutOfPipe(NULLROM)				; $00D287
ROUTINE_SMW_HandlePlayerPhysics:	%ROUTINE_SMW_HandlePlayerPhysics(NULLROM)					; $00D2BD
ROUTINE_SMW_UpdatePlayerSpritePosition:	%ROUTINE_SMW_UpdatePlayerSpritePosition(NULLROM)				; $00DC2D
ROUTINE_RT01_SMW_SetPlayerPose:	%ROUTINE_RT01_SMW_SetPlayerPose(NULLROM)					; $00DC78
ROUTINE_RT00_SMW_PlayerGFXRt:	%ROUTINE_RT00_SMW_PlayerGFXRt(NULLROM)						; $00DCEC
DATATABLE_RT00_SMW_SlopeDataTables:	%DATATABLE_RT00_SMW_SlopeDataTables(NULLROM)					; $00E4B9
ROUTINE_RT02_SMW_InitializeMap16Pointers:	%ROUTINE_RT02_SMW_InitializeMap16Pointers(NULLROM)				; $00E55E
DATATABLE_RT01_SMW_SlopeDataTables:	%DATATABLE_RT01_SMW_SlopeDataTables(NULLROM)					; $00E632
ROUTINE_RT01_SMW_GetPlayerLevelCollisionMap16ID:	%ROUTINE_RT01_SMW_GetPlayerLevelCollisionMap16ID(NULLROM)			; $00E832
ROUTINE_RT01_SMW_RunPlayerBlockCode:	%ROUTINE_RT01_SMW_RunPlayerBlockCode(NULLROM)					; $00E8A4
ROUTINE_SMW_HandlePlayerLevelCollision:	%ROUTINE_SMW_HandlePlayerLevelCollision(NULLROM)				; $00E90A
ROUTINE_SMW_ResetPlayerLevelCollisionRAM:	%ROUTINE_SMW_ResetPlayerLevelCollisionRAM(NULLROM)				; $00EAA6
ROUTINE_RT00_SMW_RunPlayerBlockCode:	%ROUTINE_RT00_SMW_RunPlayerBlockCode(NULLROM)					; $00EAB9
ROUTINE_SMW_CheckForWaterSlope:	%ROUTINE_SMW_CheckForWaterSlope(NULLROM)					; $00F04D
ROUTINE_RT01_SMW_CheckIfBlockWasHit:	%ROUTINE_RT01_SMW_CheckIfBlockWasHit(NULLROM)					; $00F05C
ROUTINE_RT02_SMW_RunPlayerBlockCode:	%ROUTINE_RT02_SMW_RunPlayerBlockCode(NULLROM)					; $00F120
ROUTINE_RT00_SMW_CheckIfBlockWasHit:	%ROUTINE_RT00_SMW_CheckIfBlockWasHit(NULLROM)					; $00F15F
ROUTINE_RT03_SMW_RunPlayerBlockCode:	%ROUTINE_RT03_SMW_RunPlayerBlockCode(NULLROM)					; $00F267
ROUTINE_SMW_SpawnScoreSpriteAtPlayerPosition:	%ROUTINE_SMW_SpawnScoreSpriteAtPlayerPosition(NULLROM)				; $00F388
ROUTINE_RT04_SMW_RunPlayerBlockCode:	%ROUTINE_RT04_SMW_RunPlayerBlockCode(NULLROM)					; $00F3B2
ROUTINE_RT00_SMW_GetPlayerLevelCollisionMap16ID:	%ROUTINE_RT00_SMW_GetPlayerLevelCollisionMap16ID(NULLROM)			; $00F44D
ROUTINE_SMW_ModifyMap16IDForSpecialBlocks:	%ROUTINE_SMW_ModifyMap16IDForSpecialBlocks(NULLROM)				; $00F545
ROUTINE_RT03_SMW_PlayerState00_Normal:	%ROUTINE_RT03_SMW_PlayerState00_Normal(NULLROM)				; $00F595
ROUTINE_SMW_DamagePlayer:	%ROUTINE_SMW_DamagePlayer(NULLROM)						; $00F5B7
ROUTINE_RT01_SMW_PlayerGFXRt:	%ROUTINE_RT01_SMW_PlayerGFXRt(NULLROM)						; $00F636
ROUTINE_SMW_HandleStandardLevelCameraScroll:	%ROUTINE_SMW_HandleStandardLevelCameraScroll(NULLROM)				; $00F69F
ROUTINE_RT04_SMW_PlayerState00_Normal:	%ROUTINE_RT04_SMW_PlayerState00_Normal(NULLROM)				; $00F8DF
INLINEDATATABLE_RT03_SMW_EmptySpace:	%INLINEDATATABLE_RT03_SMW_EmptySpace(NULLROM)					; $00F9F5
ROUTINE_RT01_SMW_ClearOutNormalSpriteSlots:	%ROUTINE_RT01_SMW_ClearOutNormalSpriteSlots(NULLROM)				; $00FA10
ROUTINE_SMW_CheckWhatSlopeSpriteIsOn:	%ROUTINE_SMW_CheckWhatSlopeSpriteIsOn(NULLROM)					; $00FA19
ROUTINE_RT05_SMW_RunPlayerBlockCode:	%ROUTINE_RT05_SMW_RunPlayerBlockCode(NULLROM)					; $00FA45
ROUTINE_RT02_SMW_NorSpr07B_GoalTape_Status08:	%ROUTINE_RT02_SMW_NorSpr07B_GoalTape_Status08(NULLROM)				; $00FA80
ROUTINE_RT01_SMW_NorSprStatus06_GoalCoins:	%ROUTINE_RT01_SMW_NorSprStatus06_GoalCoins(NULLROM)				; $00FBA4
ROUTINE_SMW_UnusedYoshiRelatedRoutine:	%ROUTINE_SMW_UnusedYoshiRelatedRoutine(NULLROM)				; $00FC23
ROUTINE_SMW_SpawnMountedYoshiOnLevelLoad:	%ROUTINE_SMW_SpawnMountedYoshiOnLevelLoad(NULLROM)				; $00FC7A
ROUTINE_RT00_SMW_ClearOutNormalSpriteSlots:	%ROUTINE_RT00_SMW_ClearOutNormalSpriteSlots(NULLROM)				; $00FCEC
ROUTINE_RT01_SMW_NorSpr029_KoopaKid_Status01:	%ROUTINE_RT01_SMW_NorSpr029_KoopaKid_Status01(NULLROM)				; $00FCF5
ROUTINE_SMW_SpawnPlayerBreathBubble:	%ROUTINE_SMW_SpawnPlayerBreathBubble(NULLROM)					; $00FD08
ROUTINE_SMW_SpawnGlitterEffectForCoin:	%ROUTINE_SMW_SpawnGlitterEffectForCoin(NULLROM)				; $00FD5A
ROUTINE_SMW_SpawnPlayerWaterSplashAndManyBreathBubbles:	%ROUTINE_SMW_SpawnPlayerWaterSplashAndManyBreathBubbles(NULLROM)		; $00FD9D
ROUTINE_SMW_SpawnPlayerTurnAroundSmoke:	%ROUTINE_SMW_SpawnPlayerTurnAroundSmoke(NULLROM)				; $00FE4A
ROUTINE_SMW_SpawnPlayerFireball:	%ROUTINE_SMW_SpawnPlayerFireball(NULLROM)					; $00FE94
ROUTINE_RT02_SMW_NorSpr088_WingedCage_Status08:	%ROUTINE_RT02_SMW_NorSpr088_WingedCage_Status08(NULLROM)			; $00FF07
ROUTINE_RT02_SMW_NorSpr089_Layer3Smasher_Status08:	%ROUTINE_RT02_SMW_NorSpr089_Layer3Smasher_Status08(NULLROM)			; $00FF61
INLINEDATATABLE_RT04_SMW_EmptySpace:	%INLINEDATATABLE_RT04_SMW_EmptySpace(NULLROM)					; $00FF93
%BANK_END(<EndBank>)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExecutePtr(Address)
namespace SMW_ExecutePtr
%InsertMacroAtXPosition(<Address>)

; Pointer subroutine: Jump to a 2-byte pointer, the position of the pointer
; used is "Position after the JSL + 1 + (A*2)". The subroutine should always
; be accessed by a JSL.
;
; The table is written inline immediately after that JSL, so the bytes there
; are data and are never executed. A, X and Y must all be 8 bits on entry --
; the PLY below takes one byte off the stack, and with 16-bit index registers
; it would take two and unbalance it. The target is entered with A, X and Y
; 8 bits whatever the caller had, X and Y unchanged, A holding the fetched
; pointer, and scratch $00..$03 clobbered. This never returns to its caller:
; the JSL's return address is consumed to find the table, so an RTL in the
; target returns past it.
Absolute:
	STY.b !RAM_SMW_Misc_ScratchRAM03	; "Push" Y
	PLY				; \ RAM $00 = low byte
	STY.b !RAM_SMW_Misc_ScratchRAM00	; /           of (return address - 1)
	REP.b #$30			; AXY->16
	AND.w #$00FF			; Set high byte of A to zero
	ASL				; \ Y = A * 2 {because table contains
	TAY				; /            2-byte addresses}
	PLA				; \ RAM $01 = high byte
	STA.b !RAM_SMW_Misc_ScratchRAM01	; / RAM $02 = bank byte
	INY				; Y = Y + 1 {to find start of table}
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	; \ RAM $00..$01 = address from table
	STA.b !RAM_SMW_Misc_ScratchRAM00	; /
	SEP.b #$30			; AXY->8
	LDY.b !RAM_SMW_Misc_ScratchRAM03	; "Pull" Y
	JMP.w [!RAM_SMW_Misc_ScratchRAM00]	; Jump to address in RAM $00..$02

Long:
;$0086FA
	; Pointer subroutine: Jump to a 3-byte pointer, the position of the pointer
	; used is "Position after the JSL + 1 + (A*3)". The subroutine should
	; always be accessed by a JSL.
	;
	; Same contract as Absolute above, over a table of 3-byte entries and
	; using scratch $00..$05 instead of $00..$03.
	STY.b !RAM_SMW_Misc_ScratchRAM05	; "Push" Y to RAM $05
	PLY				; \ RAM $02 = low byte
	STY.b !RAM_SMW_Misc_ScratchRAM02	; /           of (return address - 1)
	REP.b #$30			; AXY->16
	AND.w #$00FF			; Clear bits 8..15 of A
	STA.b !RAM_SMW_Misc_ScratchRAM03	; RAM $03 = A
	ASL				; \ Y = A * 3 {because table contains
	ADC.b !RAM_SMW_Misc_ScratchRAM03	;  |{ASL moves bit 15 of A, which is
	TAY				; /  zero, to the carry flag.}
	PLA				; \ RAM $03 = high byte
	STA.b !RAM_SMW_Misc_ScratchRAM03	; / RAM $04 = bank byte
	INY				; Y = Y + 1 {to find start of table}
	LDA.b [!RAM_SMW_Misc_ScratchRAM02],y	; \ RAM $00 = low byte
	STA.b !RAM_SMW_Misc_ScratchRAM00	; / RAM $01 = high byte
	INY				; Y = Y + 1 {for high, bank bytes}
	LDA.b [!RAM_SMW_Misc_ScratchRAM02],y	; \ RAM $01 = high byte {again}
	STA.b !RAM_SMW_Misc_ScratchRAM01	; / RAM $E0 RAM $02 = bank byte
	SEP.b #$30			; AXY->8
	LDY.b !RAM_SMW_Misc_ScratchRAM05	; "Pull" Y from RAM $05
	JMP.w [!RAM_SMW_Misc_ScratchRAM00]	; Jump to adress in RAM $00..$02
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_HandleSPCUploads(Address)
namespace SMW_HandleSPCUploads
%InsertMacroAtXPosition(<Address>)

SPC700UploadLoop:
	PHP
	REP.b #$30			; AXY->16
	LDY.w #$0000
	LDA.w #$BBAA			; Value to check for when the SPC chip is ready.
CODE_008082:
	CMP.w !REGISTER_APUPort0	;\ Wait for the SPC to be ready.
	BNE.b CODE_008082		;/
	SEP.b #$20			; A->8
	LDA.b #$CC			; Byte used to enable SPC block upload.
	BRA.b CODE_0080B3

CODE_00808D:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	;\
	INY				;| Load first byte to upload.
	XBA				;|
	LDA.b #$00			;/ Validation byte for SPC.
	BRA.b CODE_0080A0

CODE_008095:
	XBA
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	;|| Load next byte.
	INY				; Shift the used location appropriately
	XBA				; Make sure the byte of data is put into APU I/O port 1
CODE_00809A:
	CMP.w !REGISTER_APUPort0	;|\ Wait for the SPC to respond from the previous byte.
	BNE.b CODE_00809A
	INC				;| Increment validation byte.
CODE_0080A0:
	REP.b #$20			;|\ A->16
	STA.w !REGISTER_APUPort0	;|| Send byte, plus the validation byte.
	SEP.b #$20			;|/ A->8
	DEX				;\ Repeat this until you have covered the whole block
	BNE.b CODE_008095		;/
CODE_0080AA:
	CMP.w !REGISTER_APUPort0	;\ Wait for the SPC to respond from the last byte of the block.
	BNE.b CODE_0080AA		;/
CODE_0080AF:
	ADC.b #$03			;\ Add 3; if A becomes 0, add 3 once more so it's still positive.
	BEQ.b CODE_0080AF		;/
CODE_0080B3:
	PHA				; Push A
	REP.b #$20			; A->16
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	; Load music data length
	INY				;\ Get ready to load the address
	INY				;/
	TAX				; Put the length in X
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	; Load the address
	INY				;\ Get ready to load the data
	INY				;/
	STA.w !REGISTER_APUPort2	; Store the address to APU I/O ports 2 and 3 (SPC700's)
	SEP.b #$20			; A->8
	CPX.w #$0001			;\
	LDA.b #$00			;| If at the end of the data block, send #$00.
	ROL				;|  Else, send #$01.
	STA.w !REGISTER_APUPort1	;/
	ADC.b #$7F			; Set overflow flag if there are still bytes left to write.
	PLA
	STA.w !REGISTER_APUPort0
CODE_0080D3:
	CMP.w !REGISTER_APUPort0
	BNE.b CODE_0080D3
	BVS.b CODE_00808D		; If the overflow flag was set earlier, jump back to upload additional blocks.
	STZ.w !REGISTER_APUPort0	;\
	STZ.w !REGISTER_APUPort1	;| Clear SPC I/O ports.
	STZ.w !REGISTER_APUPort2	;|
	STZ.w !REGISTER_APUPort3	;/
	PLP				; Return the processor's state back to normal
	RTS

if ver_is_smasw_usa(!Define_Global_ROMToAssemble) == 0
UploadSPCEngine:
	LDA.b #SPC700Engine
if ver_is_japanese(!Define_Global_ROMToAssemble)
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #SPC700Engine>>8
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #SPC700Engine>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
else
	STA.w !RAM_SMW_Misc_ScratchRAM00
	LDA.b #SPC700Engine>>8
	STA.w !RAM_SMW_Misc_ScratchRAM01
	LDA.b #SPC700Engine>>16
	STA.w !RAM_SMW_Misc_ScratchRAM02
endif
UploadDataToSPC:
	SEI				;\
	JSR.w SPC700UploadLoop		;| Upload the data pointed to by $00. Make sure interrupts don't fire during the process.
	CLI				;/
	RTS
endif

UploadSamples:
	LDA.b #SPC700Samples
if ver_is_japanese(!Define_Global_ROMToAssemble)
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #SPC700Samples>>8
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #SPC700Samples>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
else
	STA.w !RAM_SMW_Misc_ScratchRAM00
	LDA.b #SPC700Samples>>8		;| Point $00 to the SPC sample data at $0F8000.
	STA.w !RAM_SMW_Misc_ScratchRAM01
	LDA.b #SPC700Samples>>16
	STA.w !RAM_SMW_Misc_ScratchRAM02
endif
	BRA.b StrtSPCMscUpld		; Upload data.

; OW Music uploader.
UploadOverworldMusicBank:
	LDA.b #OverworldMusicBank
if ver_is_japanese(!Define_Global_ROMToAssemble)
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #OverworldMusicBank>>8
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #OverworldMusicBank>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
else
	STA.w !RAM_SMW_Misc_ScratchRAM00
	LDA.b #OverworldMusicBank>>8	;| Point $00 to the overworld music bank at $0E98B1.
	STA.w !RAM_SMW_Misc_ScratchRAM01
	LDA.b #OverworldMusicBank>>16
	STA.w !RAM_SMW_Misc_ScratchRAM02
endif
StrtSPCMscUpld:
	LDA.b #$FF			;\ Tell the SPC that music data is being sent.
	STA.w !REGISTER_APUPort1	;/
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	SEI
	JSR.w SPC700UploadLoop
	CLI
else
	JSR.w UploadDataToSPC		; Upload data.
endif
	LDX.b #$03
SPC700ZeroLoop:
	STZ.w !REGISTER_APUPort0,x
	STZ.w !RAM_SMW_IO_SoundCh1,x
	STZ.w !RAM_SMW_UnusedRAM_7E1DFD,x
	DEX
	BPL.b SPC700ZeroLoop
CODE_008133:
	RTS

; Uploads level music bank.
CODE_008134:
	LDA.w !RAM_SMW_Flag_ActiveBonusGame	;\
	BNE.b UploadLevelMusicBank	;| Upload the level music bank on one of 3 conditions:
	LDA.w !RAM_SMW_Misc_IntroLevelFlag	;|  1. Going to a bonus game.
	CMP.b #!Define_SMW_LevelID_IntroSublevel	;|  2. Loading the intro level.
	BEQ.b UploadLevelMusicBank	;|  3. Going to a new level (not primary).
	ORA.w !RAM_SMW_Counter_SublevelsEntered	;| If none of these conditions are met, return.
	ORA.w !RAM_SMW_Flag_ShowPlayerStart	;|
	BNE.b CODE_008133		;/
UploadLevelMusicBank:
	LDA.b #LevelMusicBank
if ver_is_japanese(!Define_Global_ROMToAssemble)
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #LevelMusicBank>>8
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #LevelMusicBank>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
else
	STA.w !RAM_SMW_Misc_ScratchRAM00
	LDA.b #LevelMusicBank>>8	;| Point $00 to the level music bank at $0EAED6.
	STA.w !RAM_SMW_Misc_ScratchRAM01
	LDA.b #LevelMusicBank>>16
	STA.w !RAM_SMW_Misc_ScratchRAM02
endif
	BRA.b StrtSPCMscUpld		; Upload the data.

; Credit music uploader.
UploadCreditsMusicBank:
	LDA.b #CreditsMusicBank
if ver_is_japanese(!Define_Global_ROMToAssemble)
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #CreditsMusicBank>>8
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #CreditsMusicBank>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
else
	STA.w !RAM_SMW_Misc_ScratchRAM00
	LDA.b #CreditsMusicBank>>8	;| Point $00 to the credits music bank at $03E400.
	STA.w !RAM_SMW_Misc_ScratchRAM01
	LDA.b #CreditsMusicBank>>16
	STA.w !RAM_SMW_Misc_ScratchRAM02
endif
	BRA.b StrtSPCMscUpld		; Upload the data.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CompressOAMTileSizeBuffer(Address)
namespace SMW_CompressOAMTileSizeBuffer
%InsertMacroAtXPosition(<Address>)

DATA_008475:
	dw $0000,$0008,$0010,$0018	; only even bytes are actually used.
	dw $0020,$0028,$0030,$0038
	dw $0040,$0048,$0050,$0058
	dw $0060,$0068,$0070
	db $78

; Routine responsible for packing the extra OAM bits from $0420 into the
; table at $0400.
Main:
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/008494.asm"
namespace SMW_CompressOAMTileSizeBuffer
else
	LDY.b #$1E
Loop:
	LDX.w DATA_008475,y
	LDA.w SMW_OAMTileSizeBuffer[$03].Slot,x
	ASL
	ASL
	ORA.w SMW_OAMTileSizeBuffer[$02].Slot,x
	ASL
	ASL
	ORA.w SMW_OAMTileSizeBuffer[$01].Slot,x
	ASL
	ASL
	ORA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	STA.w SMW_UpperOAMBuffer[$00].Slot,y
	LDA.w SMW_OAMTileSizeBuffer[$07].Slot,x
	ASL
	ASL
	ORA.w SMW_OAMTileSizeBuffer[$06].Slot,x
	ASL
	ASL
	ORA.w SMW_OAMTileSizeBuffer[$05].Slot,x
	ASL
	ASL
	ORA.w SMW_OAMTileSizeBuffer[$04].Slot,x
	STA.w SMW_UpperOAMBuffer[$01].Slot,y
	DEY
	DEY
	BPL.b Loop
	RTS
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_UpdateStatusBarCounters(Address)
namespace SMW_UpdateStatusBarCounters
%InsertMacroAtXPosition(<Address>)

; The tiles that make up Luigi's name in the status bar.
DATA_008DF5:
	db $40,$41,$42,$43,$44

; Tilemap of reserve item. First byte is mushroom, second is flower, third
; is star, fourth is feather.
ItemBoxItemTile:
	db $24			; Mushroom
	db $26			; Fire Flower
	db $48			; Star (Unused)
	db $0E			; Feather

; YXPPCCCT of stars in the item box. It cycles between the four entries
; every second frame.
StarPaletteFrames:		;\ Glitch: This causes the item box star to use palettes 8,9,A. It should be A and C.
	db $00,$02,$04,$02	;/

; YXPPCCCT data for reserve item. First byte is mushroom, second is flower,
; third is bypassed ($008DFF), fourth is feather.
ItemBoxItemProperties:
	db $08			; Mushroom
	db $0A			; Fire Flower
	db $00			; Star (Unused)
	db $04			; Feather

BonusStarCounterNumberTiles:
	%INLINEDATATABLE_SMW_TallNumberTiles()

; The routine that updates the values of all the addresses used for the
; status bar ($0EF9). Notable spots: $008E28: Change this address to AD to
; disable the timer. $008E2E: Timer speed (use with $008D8B) $008E45: Tile
; that each timer digit resets to after reaching 0. Can be any value from
; $00-$80. (e.g. Change to $0F: 100 -> 0FF -> 0FE ... 0F0 -> 0EF ... etc.)
; $008E5C: Time is Running Out SFX. Change from FF to 00 to stop the music
; from speeding up when time reaches 99. $008E6B: [22 06 F6 00] Change to
; [EA EA EA EA] to not kill Mario when the timer reaches zero. The timer
; will count down normally and stop at zero, but Mario will not die $008EDB:
; Change this and/or $008F09 from 20 12 90 to EA EA EA to disable writing
; the score to the status bar when playing as Mario and/or Luigi,
; respectively. Useful if you want to place another counter in place of the
; score using Smallhacker's Status Bar Editor. Note: This alone will NOT
; stop writing blank tiles if the first N tiles/bytes at $0F29-$0F2E
; contains the value #$00 (the "0" graphic). Warning: Changing this to
; anything higher than 0x7E (127 lives) will remove the life limit entirely!
; Also, if you have more than 99 lives, the life counter will appear
; slightly glitched. $008F45: (Use with $008F41) Maximum life limit, minus
; one. Note that if you have more than 99 lives, the life counter will
; appear slightly glitched. $008F62: Number of bonus stars required to enter
; bonus game $008F67: [8D 25 14] Change to EA EA EA to disable entering
; bonus game when player has 100 bonus stars. $008F6F: Amount of bonus stars
; that will be subtracted when 100 bonus stars are collected. Change to [01]
; to make 99 the maximum amount of bonus stars you can get - to create a
; bonus star wallet effect, use with $008F67. $008F7E: Writes coins to
; status bar. Changing to [EA EA EA EA EA EA] will disable the coins from
; being written to the status bar. $008F95: [09] The X position of the small
; bonus star counter in the status bar. $008FC5: [20 79 90] Change to EA EA
; EA to disable the item GFX in the status bar $008FCE: Length of "LUIGI"
; text (Status bar) $008FE7: [FC] Tile used on the status bar when there's
; no Yoshi coin in that spot. $008FED: [2E] Tile used on the status bar when
; there is a Yoshi coin in that spot. Change to [FC] to visually disable
; collected Yoshi Coins.
Main:
if !SMW_GlobalCode_StatusWanted == !TRUE
	; The same five bytes as the read and the OR below. The project's own
	; status bar code runs first, and the stub repeats the pair so the
	; branch sees the flags it expects. See Config/GlobalCode.asm.
	JML.l SMW_GlobalCode_StatusStub
	NOP
else
	LDA.w !RAM_SMW_Timer_EndLevel	;\
	ORA.b !RAM_SMW_Flag_SpritesLocked	;| Don't decrement the timer if:
endif
GlobalCodeReturn:
	BNE.b CODE_008E6F		;|  - Ending a level
	LDA.w !RAM_SMW_Misc_NMIToUseFlag	;|  - Game frozen
	CMP.b #$C1			;|  - In Bowser
	BEQ.b CODE_008E6F		;|  - A second hasn't passed
	DEC.w !RAM_SMW_Counter_TimerFrames	;|
	BPL.b CODE_008E6F		;/
	LDA.b #!Define_SMW_Counter_TimerFrames	;\
	STA.w !RAM_SMW_Counter_TimerFrames	;/ reset the timer's timer
	LDA.w !RAM_SMW_Counter_TimerHundreds	;\
	ORA.w !RAM_SMW_Counter_TimerTens	;| If timer is already zero, skip "time up".
	ORA.w !RAM_SMW_Counter_TimerOnes	;|
	BEQ.b CODE_008E6F		;/
	LDX.b #$02
CODE_008E3F:
	DEC.w !RAM_SMW_Counter_TimerHundreds,x
	BPL.b CODE_008E4C
	LDA.b #$09
	STA.w !RAM_SMW_Counter_TimerHundreds,x
	DEX
	BPL.b CODE_008E3F
CODE_008E4C:
	LDA.w !RAM_SMW_Counter_TimerHundreds	;\
	BNE.b CODE_008E60		;|
	LDA.w !RAM_SMW_Counter_TimerTens	;|
	AND.w !RAM_SMW_Counter_TimerOnes	;| If time is 99, speed up music.
	CMP.b #$09			;|
	BNE.b CODE_008E60		;|
	LDA.b #!Define_SMW_Sound1DF9_IncreaseMusicTempo	;|\ SFX for the "time is running out!" effect.
	STA.w !RAM_SMW_IO_SoundCh1	;//
CODE_008E60:
	LDA.w !RAM_SMW_Counter_TimerHundreds	;\
	ORA.w !RAM_SMW_Counter_TimerTens	;|
	ORA.w !RAM_SMW_Counter_TimerOnes	;| If time is 0, kill Mario.
	BNE.b CODE_008E6F		;|
	JSL.l SMW_DamagePlayer_Kill	;/
CODE_008E6F:
	LDA.w !RAM_SMW_Counter_TimerHundreds	;\
	STA.w !RAM_SMW_Misc_StatusBar_TimerHundreds	;|
	LDA.w !RAM_SMW_Counter_TimerTens	;| Copy time to status bar tilemap.
	STA.w !RAM_SMW_Misc_StatusBar_TimerTens	;|
	LDA.w !RAM_SMW_Counter_TimerOnes	;|
	STA.w !RAM_SMW_Misc_StatusBar_TimerOnes	;/
	LDX.b #$10							; Optimization: What is the point of this?
	LDY.b #$00
CODE_008E85:
	LDA.w !RAM_SMW_Counter_TimerHundreds,y
	BNE.b CODE_008E95
	LDA.b #$FC
	STA.w !RAM_SMW_Misc_StatusBar_TimerHundreds-$10,x
	INY
	INX
	CPY.b #$02
	BNE.b CODE_008E85
CODE_008E95:
	LDX.b #$03
CODE_008E97:
	LDA.w !RAM_SMW_Player_MarioScoreHi,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	REP.b #$20			; 16 bit A ; Accum (16 bit)
	LDA.w !RAM_SMW_Player_MarioScoreLo,x	;\
	SEC				;|
	SBC.w #$423F			;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;| ...?
	SBC.w #$000F			;|
	BCC.b NotAtMaxScore		;/
	SEP.b #$20			; 8 bit A ; Accum (8 bit)
	LDA.b #$0F
	STA.w !RAM_SMW_Player_MarioScoreHi,x
	LDA.b #$42
	STA.w !RAM_SMW_Player_MarioScoreMid,x
	LDA.b #$3F
	STA.w !RAM_SMW_Player_MarioScoreLo,x
NotAtMaxScore:
	SEP.b #$20			; 8 bit A ; Accum (8 bit)
	DEX				;\
	DEX				;| X = 00 (LDX #$00 anyone?)
	DEX				;/
	BPL.b CODE_008E97
	LDA.w !RAM_SMW_Player_MarioScoreHi	; \ Store high byte of Mario's score in $00
	STA.b !RAM_SMW_Misc_ScratchRAM00	; /
	STZ.b !RAM_SMW_Misc_ScratchRAM01	; Store x00 in $01
	LDA.w !RAM_SMW_Player_MarioScoreMid	; \ Store mid byte of Mario's score in $03
	STA.b !RAM_SMW_Misc_ScratchRAM03	; /
	LDA.w !RAM_SMW_Player_MarioScoreLo	; \ Store low byte of Mario's score in $02
	STA.b !RAM_SMW_Misc_ScratchRAM02	; /
	LDX.b #$14			;\ Status bar position offset from $0F15 to start writing Mario's score to.
	LDY.b #$00			;| Write Mario's score to the status bar.
	JSR.w UpdateStatusBarScoreTiles	;/
	LDX.b #$00
CODE_008EE0:
	LDA.w !RAM_SMW_Misc_StatusBar_ScoreMillions,x
	BNE.b CODE_008EEF
	LDA.b #$FC			;  |Replace all leading zeroes in the score with spaces
	STA.w !RAM_SMW_Misc_StatusBar_ScoreMillions,x
	INX
	CPX.b #$06
	BNE.b CODE_008EE0
CODE_008EEF:
	LDA.w !RAM_SMW_Player_CurrentCharacter	;\ If playing as Mario, branch and don't overwrite with Luigi's score.
	BEQ.b CODE_008F1D		;/
	LDA.w !RAM_SMW_Player_LuigiScoreHi	; \ Store high byte of Luigi's score in $00
	STA.b !RAM_SMW_Misc_ScratchRAM00	; /
	STZ.b !RAM_SMW_Misc_ScratchRAM01	; Store x00 in $01
	LDA.w !RAM_SMW_Player_LuigiScoreMid	; \ Store mid byte of Luigi's score in $03
	STA.b !RAM_SMW_Misc_ScratchRAM03	; /
	LDA.w !RAM_SMW_Player_LuigiScoreLo	; \ Store low byte of Luigi's score in $02
	STA.b !RAM_SMW_Misc_ScratchRAM02	; /
	LDX.b #$14			;\ Status bar position offset from $0F15 to start writing Luigi's score to.
	LDY.b #$00			;| Write Luigi's score to the status bar.
	JSR.w UpdateStatusBarScoreTiles	;/
	LDX.b #$00
CODE_008F0E:
	LDA.w !RAM_SMW_Misc_StatusBar_ScoreMillions,x
	BNE.b CODE_008F1D
	LDA.b #$FC
	STA.w !RAM_SMW_Misc_StatusBar_ScoreMillions,x
	INX
	CPX.b #$06
	BNE.b CODE_008F0E
; Routine that handles actually increasing the player's coin count and
; giving a life from 100 coins, controlled by RAM address $7E13CC.
CODE_008F1D:
	LDA.w !RAM_SMW_Counter_CoinHandler	;\
	BEQ.b CODE_008F3B		;| Add a coin to the player's coin count if applicable.
	DEC.w !RAM_SMW_Counter_CoinHandler	;|
	INC.w !RAM_SMW_Player_CurrentCoinCount	;/
	LDA.w !RAM_SMW_Player_CurrentCoinCount	;\
	CMP.b #$64			;| How many coins the player needs to get a 1up (100).
	BCC.b CODE_008F3B		;/
	INC.w !RAM_SMW_Misc_1upHandler	; Give he player a life.
	LDA.w !RAM_SMW_Player_CurrentCoinCount	;\
	SEC				;|
	SBC.b #$64			;| How many coins to take away after giving the player a 1up (100).
	STA.w !RAM_SMW_Player_CurrentCoinCount	;/
CODE_008F3B:
	LDA.w !RAM_SMW_Player_CurrentLifeCount	;\ If Mario has a negative number of lives (i.e. game over), don't max out the life count.
	BMI.b CODE_008F49		;/
	CMP.b #$62			;\ Maximum number of lives the player can have.
	BCC.b CODE_008F49		;|
	LDA.b #$62			;| Amount of lives to use if the maximum life limit is reached.
	STA.w !RAM_SMW_Player_CurrentLifeCount	;/
CODE_008F49:
	LDA.w !RAM_SMW_Player_CurrentLifeCount	; \
	INC				;  |Get amount of lives in decimal
	JSR.w SMW_HexToDec_Bank00	; /
	TXY
	BNE.b CODE_008F55		;  |If 10s is 0, replace with space
	LDX.b #$FC
CODE_008F55:
	STX.w !RAM_SMW_Misc_StatusBar_LivesHi	; \ Write lives to status bar
	STA.w !RAM_SMW_Misc_StatusBar_LivesLo	; /
	LDX.w !RAM_SMW_Player_CurrentCharacter	;\
	LDA.w !RAM_SMW_Player_MarioBonusStars,x	;|
	CMP.b #$64			;| Number of bonus stars required to enter the bonus game (100).
	BCC.b CODE_008F73		;|
	LDA.b #$FF			;|\ Set the flag to activate the bonus game after the level is beaten.
	STA.w !RAM_SMW_Flag_ActiveBonusGame	;|/
	LDA.w !RAM_SMW_Player_MarioBonusStars,x	;|\
	SEC				;||
	SBC.b #$64			;|| Number of bonus stars to subtract from the counter after getting a bonus game (100).
	STA.w !RAM_SMW_Player_MarioBonusStars,x	;//
CODE_008F73:
	LDA.w !RAM_SMW_Player_CurrentCoinCount	; \ Get amount of coins in decimal
	JSR.w SMW_HexToDec_Bank00	; /
	TXY
	BNE.b CODE_008F7E		;  |If 10s is 0, replace with space
	LDX.b #$FC
CODE_008F7E:
	STA.w !RAM_SMW_Misc_StatusBar_CoinsLo	; \ Write coins to status bar
	STX.w !RAM_SMW_Misc_StatusBar_CoinsHi	; /
	SEP.b #$20			; A->8
	LDX.w !RAM_SMW_Player_CurrentCharacter	; Load Character into X
	STZ.b !RAM_SMW_Misc_ScratchRAM00	;\
	STZ.b !RAM_SMW_Misc_ScratchRAM01	;|
	STZ.b !RAM_SMW_Misc_ScratchRAM03	;/ get rid of the temp. luigi score stuff (!?)
	LDA.w !RAM_SMW_Player_MarioBonusStars,x	;\ bonus stars for character = $02
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDX.b #$09			;\\ Status bar position offset from $0F15 to start writing the current player's bonus stars to.
	LDY.b #$10			;| Write the small bonus stars to the status bar.
	JSR.w CODE_009051		;/
	LDX.b #$00			; Loop-like thing- basically just handling when to put spaces and when to not on the bonus stars
CODE_008F9D:
	LDA.w !RAM_SMW_Misc_StatusBar_BottomBonusStarsHi,x	;\
	BNE.b CODE_008FAF		;|
	LDA.b #$FC			;|| Tile to use for the tens digit of the small bonus stars counter if 0 (blank tile).
	STA.w !RAM_SMW_Misc_StatusBar_BottomBonusStarsHi,x	;|
	STA.w !RAM_SMW_Misc_StatusBar_TopBonusStarsHi,x	;| Write the small counter's digits to the status bar.
	INX				;|
	CPX.b #$01			;|
	BNE.b CODE_008F9D		;/
CODE_008FAF:
	LDA.w !RAM_SMW_Misc_StatusBar_BottomBonusStarsHi,x	;\
	ASL				;| Write the big numbers to the status bar.
	TAY				;|
	LDA.w BonusStarCounterNumberTiles,y	;|\ Write the top of the number.
	STA.w !RAM_SMW_Misc_StatusBar_TopBonusStarsHi,x	;|/
	LDA.w BonusStarCounterNumberTiles+$01,y	;|\ Write the bottom of the number.
	STA.w !RAM_SMW_Misc_StatusBar_BottomBonusStarsHi,x	;|/
	INX				;|
	CPX.b #$02			;|
	BNE.b CODE_008FAF		;/
	JSR.w DrawItemBoxItem		; Draw the reserve item to the status bar.
	LDA.w !RAM_SMW_Player_CurrentCharacter	;\ If playing as Mario, skip.
	BEQ.b CODE_008FD8		;/
	LDX.b #$04
CODE_008FCF:
	LDA.w DATA_008DF5,x
	STA.w !RAM_SMW_Misc_StatusBar_Player,x
	DEX
	BPL.b CODE_008FCF
CODE_008FD8:
	LDA.w !RAM_SMW_Counter_YoshiCoinsToDisplay
	CMP.b #$05			; Number of Yoshi coins to remove the counter from the status bar at.
	BCC.b CODE_008FE1
	LDA.b #$00
CODE_008FE1:
	DEC
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b #$00
CODE_008FE6:
	LDY.b #$FC
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BMI.b CODE_008FEE
	LDY.b #$2E
CODE_008FEE:
	TYA
	STA.w !RAM_SMW_Misc_StatusBar_YoshiCoin1,x
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	INX				;| Prime for next run of loop, unless we're done
	CPX.b #$04			;|
	BNE.b CODE_008FE6		;/
	RTS				; Whew, long routine!

; Table containing six 32-bit numbers representing hexadecimal powers of 10,
; used by the 6-digit HexToDec routine at $009012 used to display the
; player's score. The numbers are not direct 32-bit values, though, and are
; instead two consecutive 16-bit values that are directly concatenated
; together. For instance, the number 100000 (0x186A0 is hex) is represented
; here as [$0001,$86A0].
DATA_008FFA:
	dw $0001,$86A0,$0000,$2710,$0000,$03E8,$0000,$0064	; "100000"
	dw $0000,$000A,$0000,$0001	; "10"

; 6-digit HexToDec subroutine, used to write a player's score into status
; bar (note: although the score is shown in-game as 7 digits, the 7th digit
; is just a static 0 tile). This function calculates the digits by
; repeatedly subtracting powers of 10 (in hexadecimal) from the input number
; until no more can be subtracted. Input: - Y: Set to #$00 - X: Status bar
; position to write to (indexed from $0F15) - $00-$03: Hexadecimal value to
; convert. Note that this is not provided as a normal 32-bit value, though,
; and instead should be provided as two 16-bit values, with $00 being the
; high word and $02 being the low word.
UpdateStatusBarScoreTiles:
Loop2:
	SEP.b #$20			; A->8
	STZ.w !RAM_SMW_Misc_StatusBar_ScoreMillions-$14,x	; Zero the current status bar tile.
Loop1:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	SEC				;|
	SBC.w DATA_008FFA+$02,y		;|
	STA.b !RAM_SMW_Misc_ScratchRAM06	;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;|
	SBC.w DATA_008FFA,y		;| If the current value can not be subtracted from the score, branch.
	STA.b !RAM_SMW_Misc_ScratchRAM04	;|
	BCC.b CODE_009039		;|
	LDA.b !RAM_SMW_Misc_ScratchRAM06	;|
	STA.b !RAM_SMW_Misc_ScratchRAM02	;|
	LDA.b !RAM_SMW_Misc_ScratchRAM04	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	SEP.b #$20			; A->8
	INC.w !RAM_SMW_Misc_StatusBar_ScoreMillions-$14,x	; Increase the current status bar tile's value for each value subtracted.
	BRA.b Loop1			;>Loop and keep counting this digit until you cannot subtract anymore.

CODE_009039:
	INX				;>Next digit tile
	INY				;\And next 10^n as the subtrahend.
	INY				;|
	INY				;|
	INY				;/ Add 4 to Y.. if that makes it 18, then return (ones place done)
	CPY.b #$18			;| otherwise rerun routine
	BNE.b Loop2
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_UpdateStatusBarCounters(Address)
namespace SMW_UpdateStatusBarCounters
%InsertMacroAtXPosition(<Address>)

; Subroutine used to convert the player's bonus stars from hexadecimal to
; decimal, and then write them to the status bar. Note that this only writes
; them as single-tile 8x8 digits, though; the main status bar's code at
; $008FAF is responsible for later converting these small digits to the 8x16
; numbers actually seen in-game.
CODE_009051:
	SEP.b #$20			; A->8
	; Change to EAEAEA to get rid of the small bonus stars. Use in conjunction
	; with address $00:9068
	STZ.w !RAM_SMW_Misc_StatusBar_ScoreMillions-$14,x	; Zero the current status bar tile.
CODE_009056:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	SEC				;|
	SBC.w DATA_008FFA+$02,y		;|
	STA.b !RAM_SMW_Misc_ScratchRAM06	;| If the current value can not be subtracted from the bonus stars, branch.
	BCC.b CODE_00906D		;|
	LDA.b !RAM_SMW_Misc_ScratchRAM06	;|
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	SEP.b #$20			; A->8
	; Change to EAEAEA to get rid of the small bonus stars. Use in conjunction
	; with address $00:9053
	INC.w !RAM_SMW_Misc_StatusBar_ScoreMillions-$14,x	;>...And count how many successful subtractions, eventually this will be the correct digit of the final result.
	BRA.b CODE_009056		;>Loop and keep counting this digit until you cannot subtract anymore.

CODE_00906D:
	INX				;>Next digit to the right
	INY				;\Move from the 10s to the 1s, after the ones, should hit RTS.
	INY				;|
	INY				;|
	INY				;/
	CPY.b #$18
	BNE.b CODE_009051		;>If you haven't finished the 1s, loop again.
	SEP.b #$20			; A->8
	RTS

; Subroutine that draws the power up item to the item box on the status bar
; during levels. $0090AE is the X position of the Item Box item. $0090B3 is
; the Y position of the Item Box item. Note: Those two positions are only
; graphical. It won't change where the item drops from when select is
; pressed. To change that, see $028052 and $028060
DrawItemBoxItem:
	LDY.b #!OAM_SMW_ItemBoxItem_NormalLevel*$04
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_00908E
	LDY.b #!OAM_SMW_ItemBoxItem_BowserReznorMortonRoyRoom
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	CMP.b #$C1
	BEQ.b CODE_00908E
	LDA.b #$F0
	STA.w SMW_OAMBuffer[!OAM_SMW_ItemBoxItem_NormalLevel&$40].YDisp,y
CODE_00908E:
	STY.b !RAM_SMW_Misc_ScratchRAM01
	LDY.w !RAM_SMW_Player_CurrentItemBox
	BEQ.b ItemBoxEmpty
	LDA.w ItemBoxItemProperties-$01,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	CPY.b #$03
	BNE.b NoStarInBox
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	AND.b #$03
	PHY
	TAY
	LDA.w StarPaletteFrames,y
	PLY
	STA.b !RAM_SMW_Misc_ScratchRAM00
NoStarInBox:
	LDY.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #((!RAM_SMW_Misc_StatusBar_ItemBox-!RAM_SMW_Misc_StatusBarTilemap+$01)*$08)+$10	;\ X position of the item box item.
	STA.w SMW_OAMBuffer[!OAM_SMW_ItemBoxItem_NormalLevel&$40].XDisp,y	;/
	LDA.b #$0F			;\ Y position of the item box item.
	STA.w SMW_OAMBuffer[!OAM_SMW_ItemBoxItem_NormalLevel&$40].YDisp,y	;/
	LDA.b #$30			;\
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;| Set YXPPCCCT of the item box item.
	STA.w SMW_OAMBuffer[!OAM_SMW_ItemBoxItem_NormalLevel&$40].Prop,y	;/
	LDX.w !RAM_SMW_Player_CurrentItemBox	;\
	LDA.w ItemBoxItemTile-$01,x	;| Set the tile number for the item box item.
	STA.w SMW_OAMBuffer[!OAM_SMW_ItemBoxItem_NormalLevel&$40].Tile,y	;/
	TYA
	LSR
	LSR
	TAY
	LDA.b #$02
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
ItemBoxEmpty:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_HexToDec(Address)
namespace SMW_HexToDec
%InsertMacroAtXPosition(<Address>)

Bank00:
	%INLINEROUTINE_SMW_HexToDec(X)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_GlobalPalettes(Address)
namespace SMW_GlobalPalettes
%InsertMacroAtXPosition(<Address>)

Main:
if !Define_SMW_Global_UseIndividualPaletteFiles == !FALSE
; Shared background area colour. Back area colour 0 - 7
Sky:
.Setting00:		incbin "palettes/smw.pal":$0..$2
.Setting01:		incbin "palettes/smw.pal":$2..$4
.Setting02:		incbin "palettes/smw.pal":$4..$6
.Setting03:		incbin "palettes/smw.pal":$6..$8
.Setting04:		incbin "palettes/smw.pal":$8..$A
.Setting05:		incbin "palettes/smw.pal":$A..$C
.Setting06:		incbin "palettes/smw.pal":$C..$E
.Setting07:		incbin "palettes/smw.pal":$E..$10

; BG Palette 0
Background:
.Setting00:		incbin "palettes/smw.pal":$10..$28
; BG Palette 1
.Setting01:		incbin "palettes/smw.pal":$28..$40
; BG Palette 2
.Setting02:		incbin "palettes/smw.pal":$40..$58
; BG Palette 3
.Setting03:		incbin "palettes/smw.pal":$58..$70
; BG Palette 4
.Setting04:		incbin "palettes/smw.pal":$70..$88
; BG Palette 5
.Setting05:		incbin "palettes/smw.pal":$88..$A0
; BG Palette 6
.Setting06:		incbin "palettes/smw.pal":$A0..$B8
; BG Palette 7
.Setting07:		incbin "palettes/smw.pal":$B8..$D0

; Palette 0 colours 8-F in levels.
Layer3:			incbin "palettes/smw.pal":$D0..$F0
; Palette 2 colours 2-7, FG Palette 0, in levels.
Foreground:		incbin "palettes/smw.pal":$F0..$1B0
; Palette 4 colours 2-7 in levels.
Objects:		incbin "palettes/smw.pal":$1B0..$1F8
; Ludwig palette, and palette A colours 2-7 in levels.
InitBossFightLudwig:	incbin "palettes/smw.pal":$1F8..$204
; Roy palette, and palette B colours 2-7 in levels.
InitBossFighRoy:	incbin "palettes/smw.pal":$204..$21C
; Morton palette, and palette D colours 2-7 in levels
InitBossFightMorton:	incbin "palettes/smw.pal":$21C..$228
; Mario Palette
Mario:			incbin "palettes/smw.pal":$228..$23C
; Luigi palette. Colours 6-F of palette 8 while small, big, or caped Luigi.
Luigi:			incbin "palettes/smw.pal":$23C..$250
; Fire Mario's palette
MarioFire:		incbin "palettes/smw.pal":$250..$264
; Fire Luigi palette. Colours 6-F of palette 8 while fire Luigi.
LuigiFire:		incbin "palettes/smw.pal":$264..$278
; Sprite palette 0, loaded to palettes E and F.
Sprites:		incbin "palettes/smw.pal":$278..$2CC
InitBossFightReznor:	incbin "palettes/smw.pal":$2CC..$2D8
; Sprite palette 4, loaded to palettes E and F.
InitBossFightBowser:	incbin "palettes/smw.pal":$2D8..$320
; Sprite palette 7, loaded to palettes E and F.
BowserEnd:		incbin "palettes/smw.pal":$320..$338
; YI Overworld Palette 4, Colours 1-7
OW_Areas:		incbin "palettes/smw.pal":$338..$488
OW_Objects:		incbin "palettes/smw.pal":$488..$4DC
OW_Sprites:		incbin "palettes/smw.pal":$4DC..$53E
; Contains the colors for the flashing lightning in Valley of Bowser.
BowserLightningFlash:	incbin "palettes/smw.pal":$53E..$54C
OW_Layer3:		incbin "palettes/smw.pal":$54C..$554
DATA_00B5F4:		incbin "palettes/smw.pal":$554..$56C
Flashing:
	; Colours used in animation of Yoshi coin and yellow map spot.
	; ($02DF,$035F,$27FF,$5FFF,$73FF,$5FFF,$27FF,$035F)
.Yellow:		incbin "palettes/smw.pal":$56C..$57C
	; Colors used in the animation of the red map spot.
	; ($01BF,$001F,$001B,$0018,$0018,$001B,$001F,$01BF)
.Red:			incbin "palettes/smw.pal":$57C..$58C
TS_Layer3:		incbin "palettes/smw.pal":$58C..$59C
DATA_00B63C:		incbin "palettes/smw.pal":$59C..$5AC
UnknownBlueGradient:	incbin "palettes/smw.pal":$5AC..$5BC ; Beta Iggy/Larry platform?
IggyLarryPlatform:	incbin "palettes/smw.pal":$5BC..$5CC
Layer3Smasher:		incbin "palettes/smw.pal":$5CC..$5D4
YoshiBerry:
	; Palettes 2 and 9, colours 9-F.
.Red:			incbin "palettes/smw.pal":$5D4..$5E2
	; Palettes 3 and A, colours 9-F.
.Pink:			incbin "palettes/smw.pal":$5E2..$5F0
	; Palettes 4 and B, colours 9-F.
.Green:			incbin "palettes/smw.pal":$5F0..$5FE

; Bowser palettes (8 palettes, 7 colours each)
Bowser:
.Normal:		incbin "palettes/smw.pal":$5FE..$60C
.Fade01:		incbin "palettes/smw.pal":$60C..$61A
.Fade02:		incbin "palettes/smw.pal":$61A..$628
.Fade03:		incbin "palettes/smw.pal":$628..$636
.Fade04:		incbin "palettes/smw.pal":$636..$644
.Fade05:		incbin "palettes/smw.pal":$644..$652
.Fade06:		incbin "palettes/smw.pal":$652..$660
.Fade07:		incbin "palettes/smw.pal":$660..$66E

; The End palettes (3 palettes, 6 colours each; order is Luigi, Mario,
; Princess)
EndingLuigi:		incbin "palettes/smw.pal":$66E..$67A
EndingMario:		incbin "palettes/smw.pal":$67A..$686
EndingToadstool:	incbin "palettes/smw.pal":$686..$692
OW_AreasPassed:		incbin "palettes/smw.pal":$692..$7E2			; Note: Apparently, Lunar Magic 2.53 doesn't export all the shared palettes.

else

Sky:
.Setting00:		incbin "palettes/Sky.tpl":$6..$8
.Setting01:		incbin "palettes/Sky.tpl":$8..$A
.Setting02:		incbin "palettes/Sky.tpl":$A..$C
.Setting03:		incbin "palettes/Sky.tpl":$C..$E
.Setting04:		incbin "palettes/Sky.tpl":$E..$10
.Setting05:		incbin "palettes/Sky.tpl":$10..$12
.Setting06:		incbin "palettes/Sky.tpl":$12..$14
.Setting07:		incbin "palettes/Sky.tpl":$14..$16

Background:
.Setting00:
	incbin "palettes/Background.tpl":$8..$14
	incbin "palettes/Background.tpl":$28..$34
.Setting01:
	incbin "palettes/Background.tpl":$48..$54
	incbin "palettes/Background.tpl":$68..$74
.Setting02:
	incbin "palettes/Background.tpl":$88..$94
	incbin "palettes/Background.tpl":$A8..$B4
.Setting03:
	incbin "palettes/Background.tpl":$C8..$D4
	incbin "palettes/Background.tpl":$E8..$F4
.Setting04:
	incbin "palettes/Background.tpl":$108..$114
	incbin "palettes/Background.tpl":$128..$134
.Setting05:
	incbin "palettes/Background.tpl":$148..$154
	incbin "palettes/Background.tpl":$168..$174
.Setting06:
	incbin "palettes/Background.tpl":$188..$194
	incbin "palettes/Background.tpl":$1A8..$1B4
.Setting07:
	incbin "palettes/Background.tpl":$1C8..$1D4
	incbin "palettes/Background.tpl":$1E8..$1F4
Layer3:
	incbin "palettes/smw.pal":$D0..$F0
Foreground:
	incbin "palettes/smw.pal":$F0..$1B0
Objects:
	incbin "palettes/smw.pal":$1B0..$1F8
InitBossFightLudwig:
	incbin "palettes/smw.pal":$1F8..$204
InitBossFighRoy:
	incbin "palettes/smw.pal":$204..$21C
InitBossFightMorton:
	incbin "palettes/smw.pal":$21C..$228
Mario:
	incbin "palettes/smw.pal":$228..$23C
Luigi:
	incbin "palettes/smw.pal":$23C..$250
MarioFire:
	incbin "palettes/smw.pal":$250..$264
LuigiFire:
	incbin "palettes/smw.pal":$264..$278
Sprites:
	incbin "palettes/smw.pal":$278..$2CC
InitBossFightReznor:
	incbin "palettes/Mode7.tpl":$6..$12
InitBossFightBowser:
	incbin "palettes/Mode7.tpl":$26..$6E
BowserEnd:
	incbin "palettes/smw.pal":$320..$338
OW_Areas:
	incbin "palettes/smw.pal":$338..$488
OW_Objects:
	incbin "palettes/smw.pal":$488..$4DC
OW_Sprites:
	incbin "palettes/smw.pal":$4DC..$53E
BowserLightningFlash:
	incbin "palettes/Bowser.tpl":$106..$114
OW_Layer3:
	incbin "palettes/smw.pal":$54C..$554
DATA_00B5F4:
	incbin "palettes/smw.pal":$554..$56C
Flashing:
.Yellow:
	incbin "palettes/smw.pal":$56C..$57C
.Red:
	incbin "palettes/smw.pal":$57C..$58C
TS_Layer3:
	incbin "palettes/smw.pal":$58C..$59C
DATA_00B63C:
	incbin "palettes/smw.pal":$59C..$5AC
UnknownBlueGradient:
	incbin "palettes/smw.pal":$5AC..$5BC ; Beta Iggy/Larry platform?
IggyLarryPlatform:
	incbin "palettes/IggyLarryPlatform.tpl":$6..$16
Layer3Smasher:
	incbin "palettes/smw.pal":$5CC..$5D4
YoshiBerry:
.Red:
	incbin "palettes/smw.pal":$5D4..$5E2
.Pink:
	incbin "palettes/smw.pal":$5E2..$5F0
.Green:
	incbin "palettes/smw.pal":$5F0..$5FE

Bowser:
.Normal:
	incbin "palettes/Bowser.tpl":$6..$14
.Fade01:
	incbin "palettes/Bowser.tpl":$26..$34
.Fade02:
	incbin "palettes/Bowser.tpl":$46..$54
.Fade03:
	incbin "palettes/Bowser.tpl":$66..$74
.Fade04:
	incbin "palettes/Bowser.tpl":$86..$94
.Fade05:
	incbin "palettes/Bowser.tpl":$A6..$B4
.Fade06:
	incbin "palettes/Bowser.tpl":$C6..$D4
.Fade07:
	incbin "palettes/Bowser.tpl":$E6..$F4

EndingLuigi:
	incbin "palettes/smw.pal":$66E..$67A
EndingMario:
	incbin "palettes/smw.pal":$67A..$686
EndingToadstool:
	incbin "palettes/smw.pal":$686..$692
OW_AreasPassed:
	incbin "palettes/smw.pal":$692..$7E2
endif
namespace off
endmacro

;---------------------------------------------------------------------------

;Info:
;.LoadColors Parameters
;	!RAM_SMW_Misc_ScratchRAM00 = 16-bit pointer to the above table
;	!RAM_SMW_Misc_ScratchRAM04 = CGRAM address X 2 (.LoadColors)
;	!RAM_SMW_Misc_ScratchRAM06 = Number of colors to buffer
;	!RAM_SMW_Misc_ScratchRAM08 = Skip to next palette row and loop again counter
;.LoadColorInVerticalStrip Parameters
;	!RAM_SMW_Misc_ScratchRAM04 = Color to upload
;	X = CGRAM address X 2

macro ROUTINE_RT00_SMW_BufferPalettesRoutines(Address)
namespace SMW_BufferPalettesRoutines
%InsertMacroAtXPosition(<Address>)

Overworld_Main:
	PHB				; Wrapper
	PHK
	PLB
	JSR.w Overworld_Sub
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_BufferPalettesRoutines(Address)
namespace SMW_BufferPalettesRoutines
%InsertMacroAtXPosition(<Address>)

DATA_00ABD3:
	db $00,$18,$30,$48,$60,$78,$90,$A8	; Offsets for FG, BG, Sprite Palettes
	db $00,$14,$28,$3C		; Offsets for The End Palettes??

DATA_00ABDF:
	dw $0000,$0038,$0070,$00A8,$00E0,$0118,$0150	; Offsets for Overworld Palettes

Levels:
	REP.b #$30			; AXY->16
	LDA.w #$7FDD
	STA.b !RAM_SMW_Misc_ScratchRAM04	; |Set color 1 in all object palettes to white
	LDX.w #$0002
	JSR.w LoadColorInVerticalStrip
	LDA.w #$7FFF
	STA.b !RAM_SMW_Misc_ScratchRAM04	; |Set color 1 in all sprite palettes to white
	LDX.w #$0102
	JSR.w LoadColorInVerticalStrip
	LDA.w #SMW_GlobalPalettes_Layer3
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0010			; |Load colors 8-16 in the first two object palettes from 00/B170
	STA.b !RAM_SMW_Misc_ScratchRAM04	; |(Layer 3 palettes)
	LDA.w #$0007
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_Objects
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0084			; |Load colors 2-7 in palettes 4-D from 00/B250
	STA.b !RAM_SMW_Misc_ScratchRAM04	; |(Object and sprite palettes)
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0009
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w !RAM_SMW_Misc_BackgroundColorSetting
	AND.w #$000F
	ASL				; |Load background color
	TAY
	LDA.w SMW_GlobalPalettes_Sky,y
	STA.w !RAM_SMW_Palettes_BackgroundColorLo
	LDA.w #SMW_GlobalPalettes_Foreground	; \Store base address in $00, ...
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Misc_FGPaletteSetting	; \...get current object palette, ...
	AND.w #$000F
	TAY
	LDA.w DATA_00ABD3,y
	AND.w #$00FF			; |...use it to figure out where to load from, ...
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00	; |...add it to the base address...
	STA.b !RAM_SMW_Misc_ScratchRAM00	; / ...and store it in $00
	LDA.w #$0044
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM06	; |Load colors 2-7 in object palettes 2 and 3 from the address in $00
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_Sprites	; \Store base address in $00, ...
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Misc_SpritePaletteSetting	; \...get current sprite palette, ...
	AND.w #$000F
	TAY
	LDA.w DATA_00ABD3,y
	AND.w #$00FF			; |...use it to figure out where to load from, ...
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00	; |...add it to the base address...
	STA.b !RAM_SMW_Misc_ScratchRAM00	; / ...and store it in $00
	LDA.w #$01C4
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM06	; |Load colors 2-7 in sprite palettes 6 and 7 from the address in $00
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_Background	; \Store bade address in $00, ...
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Misc_BGPaletteSetting	; \...get current background palette, ...
	AND.w #$000F
	TAY
	LDA.w DATA_00ABD3,y
	AND.w #$00FF			; |...use it to figure out where to load from, ...
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00	; |...add it to the base address...
	STA.b !RAM_SMW_Misc_ScratchRAM00	; / ...and store it in $00
	LDA.w #$0004
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM06	; |Load colors 2-7 in object palettes 0 and 1 from the address in $00
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_YoshiBerry
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0052
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0006			; |Load colors 9-F in object palettes 2-4 from 00/B674
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0002
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_YoshiBerry
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0132
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0006			; |Load colors 9-F in sprite palettes 1-3 from 00/B674
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0002
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	SEP.b #$30			; AXY->8
	RTS

LoadColorInVerticalStrip:
	LDY.w #$0007
.Loop:
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w SMW_PaletteMirror[$00].LowByte,x
	TXA
	CLC
	ADC.w #$0020
	TAX
	DEY
	BPL.b .Loop
	RTS

LoadColors:
	LDX.b !RAM_SMW_Misc_ScratchRAM04	; load byte offset (first color number * 2) into X
	LDY.b !RAM_SMW_Misc_ScratchRAM06	; load number of colors into Y
.Loop:
	LDA.b (!RAM_SMW_Misc_ScratchRAM00)	; load pointer to colors into A
	STA.w !RAM_SMW_Palettes_PaletteMirror,x	; Store color into RAM
	INC.b !RAM_SMW_Misc_ScratchRAM00	; \ add 2 to $00, to get next color to load
	INC.b !RAM_SMW_Misc_ScratchRAM00	; /
	INX				; \ add 2 to X, to offset the RAM address
	INX				; /
	DEY				; \ subtract 1 from Y, to decrease remaining color count
	BPL.b .Loop			; / if Y is still positive, branch up to load next color
	LDA.b !RAM_SMW_Misc_ScratchRAM04	; after all colors loaded into this row, load RAM offset into A
	CLC				; \ add 20 to it to move the RAM offset hex 10 colors forward
	ADC.w #$0020			; /
	STA.b !RAM_SMW_Misc_ScratchRAM04	; store offset to $04 again
	DEC.b !RAM_SMW_Misc_ScratchRAM08	; \ decrease number of rows to load
	BPL.b LoadColors		; / if $08 is still positive, branch to LoadColors to load colors into the next row
	RTS

; Palette IDs to use for each submap
DATA_00AD1E:
	dw $0001,$0403,$0503		; Palette Indices for Overworld Maps
	db $02

Overworld_Sub:
;$00AD25
	REP.b #$30			; AXY->16
	LDY.w #SMW_GlobalPalettes_OW_Areas
	LDA.w !RAM_SMW_Overworld_LevelTileSettings+!Define_SMW_LevelID_ChangeOverworldPalette-$01
	BPL.b NoSpecialWorldPassedPalette
	LDY.w #SMW_GlobalPalettes_OW_AreasPassed
NoSpecialWorldPassedPalette:
#LM180Hijack_CustomOverworldPalettes:
	STY.b !RAM_SMW_Misc_ScratchRAM00					;\ LM: Hijacks this if the overworld is set to use a custom palette (1.80+)
	LDA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad			;/
	AND.w #$000F
	DEC
	TAY
	LDA.w DATA_00AD1E,y
	AND.w #$00FF
	ASL
	TAY
	LDA.w DATA_00ABDF,y
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0082
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0006
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0003
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_OW_Objects
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0052
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0006
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_OW_Sprites
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0102
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0006
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0007
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_OW_Layer3
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0007
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	SEP.b #$30			; AXY->8
	RTS

TitleScreen:
;$00ADA6
	REP.b #$30			; AXY->16
	LDA.w #SMW_GlobalPalettes_DATA_00B63C
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0007
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0000
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_TS_Layer3
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0030
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0007
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0000
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	SEP.b #$30			; AXY->8
	RTS

IggyLarryPlatform:
;$00ADD9
	JSR.w Levels
	REP.b #$30			; AXY->16
	LDA.w #$0017
	STA.w !RAM_SMW_Palettes_BackgroundColorLo
	LDA.w #SMW_GlobalPalettes_Layer3
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0007
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0001
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	LDA.w #SMW_GlobalPalettes_IggyLarryPlatform
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0000
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w #$0007
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w #$0000
	STA.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors
	SEP.b #$30			; AXY->8
	RTS

ReznorAndMode7KoopaBosses:
;$00AE15						; Note: Reznor, Ludwig, Roy, Morton, Bowser
	LDA.b #$02			;\
	STA.w !RAM_SMW_Misc_SpritePaletteSetting	;/ set sprite palette settings to 02
	LDA.b #$07			;\
	STA.w !RAM_SMW_Misc_FGPaletteSetting	;/ FG palette settings = 07
	JSR.w Levels			; Load the palette
	REP.b #$30			; AXY->16
	LDA.w #$0017			;\
	STA.w !RAM_SMW_Palettes_BackgroundColorLo	;/ set BGcolor to something very dark
	LDA.w #SMW_GlobalPalettes_DATA_00B5F4
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0018			;\
	STA.b !RAM_SMW_Misc_ScratchRAM04	;/ more init stuff?
	LDA.w #$0003
	STA.b !RAM_SMW_Misc_ScratchRAM06
	STZ.b !RAM_SMW_Misc_ScratchRAM08
	JSR.w LoadColors		; Load the colors (routines use scratch RAM, I assume.)
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UpdatePlayerSpritePosition(Address)
namespace SMW_UpdatePlayerSpritePosition
%InsertMacroAtXPosition(<Address>)

; Routine that updates the player's X and Y position ($94/$13DA and
; $96/$13DC) using their X and Y speed ($7B and $7D). The player's speed is
; actually measured in units of "subpixels" corresponding to 1/16th of a
; full pixel. So a speed of $10 will increase his position by 1 pixel per
; frame, while a speed of $08 will increase his position by 1 pixel every 2
; frames.
Main:
	LDA.b !RAM_SMW_Player_YSpeed	; \ Store Mario's Y speed in $8A
	STA.b !RAM_SMW_Misc_ScratchRAM8A
	LDA.w !RAM_SMW_Player_WallWalkStatus	;\if not wallrunning, skip.
	BEQ.b IsNotRunningUpWall	;/
	LSR
	LDA.b !RAM_SMW_Player_XSpeed
	BCC.b MovingUpLeftWall
	EOR.b #$FF
	INC
MovingUpLeftWall:
	STA.b !RAM_SMW_Player_YSpeed
IsNotRunningUpWall:
	LDX.b #$00			;\handle X and Y speed to move mario
	JSR.w UpdatePosition		;|
	LDX.b #$02			;|
	JSR.w UpdatePosition		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM8A	;\restore Y speed
	STA.b !RAM_SMW_Player_YSpeed	;/
	RTS

UpdatePosition:
	LDA.b !RAM_SMW_Player_XSpeed,x	;!
if ver_is_pal(!Define_Global_ROMToAssemble)
	BPL.b +
	EOR.b #$FF
	INC

+:
	STA.b !RAM_SMW_Misc_ScratchRAM01
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !REGISTER_Multiplicand
	TXA
	BEQ.b +
	LDA.b #$28

+:
	STA.w !REGISTER_Multiplier
	NOP
	REP.b #$20
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w !REGISTER_ProductOrRemainderLo
	LSR
	LSR
	LSR
	LSR
	STZ.b !RAM_SMW_Misc_ScratchRAM02
	BIT.b !RAM_SMW_Player_SubXSpeed,x
	BPL.b +
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	EOR.w #$FFFF
	INC

+:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	SEP.b #$20
	CLC
	ADC.w !RAM_SMW_Player_SubXPos,x
	STA.w !RAM_SMW_Player_SubXPos,x
	REP.b #$20
	LDA.b !RAM_SMW_Misc_ScratchRAM01
else
	ASL				;!
	ASL				;!
	ASL				;!
	ASL				;!
	CLC				;!
	ADC.w !RAM_SMW_Player_SubXPos,x	;!
	STA.w !RAM_SMW_Player_SubXPos,x	;!
	REP.b #$20			;! A->16
	PHP				;!
	LDA.b !RAM_SMW_Player_XSpeed,x	;!
	LSR				;!
	LSR				;!
	LSR				;!
	LSR				;!
	AND.w #$000F			;!
	CMP.w #$0008			;!
	BCC.b +				;!
	ORA.w #$FFF0			;!
+:
	PLP				;!
endif
	ADC.b !RAM_SMW_Player_XPosLo,x	;!
	STA.b !RAM_SMW_Player_XPosLo,x	;!
	SEP.b #$20			;! A->8
	RTS				;!
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_InitAndMainLoop(Address)
; Note: SMW does not initialize all RAM on startup.
namespace SMW_InitAndMainLoop
%InsertMacroAtXPosition(<Address>)

Main:
if ver_is_smasw(!Define_Global_ROMToAssemble)
	JMP.w SMASSMWReset
NMIVector:
	JMP.w SMW_VBlankRoutine_Main
IRQVector:
	JMP.w SMW_IRQRoutine_Main

CODE_308009:
	JML.l SMAS_DisplayCopyDetectionErrorMessage_Main

SMASSMWReset:
if !Define_SMAS_Global_DisableCopyDetection == !FALSE
	NOP #2
	LDA.b #$AA
	STA.l !SRAM_SMAS_Global_CopyDetectionCheck2
	CMP.l !SRAM_SMAS_Global_CopyDetectionCheck1
	BNE.b CODE_308009
	LDA.b #$55
	STA.l !SRAM_SMAS_Global_CopyDetectionCheck2
	CMP.l !SRAM_SMAS_Global_CopyDetectionCheck1
	BNE.b CODE_308009
endif
	SEI
	STZ.w !REGISTER_IRQNMIAndJoypadEnableFlags
	STZ.w !REGISTER_HDMAEnable
	STZ.w !REGISTER_DMAEnable
if ver_is_smasw_europe(!Define_Global_ROMToAssemble)
	STZ.w !REGISTER_APUPort0
	STZ.w !REGISTER_APUPort1
	STZ.w !REGISTER_APUPort2
	STZ.w !REGISTER_APUPort3
endif
	LDA.b #!ScreenDisplayRegister_SetForceBlank|!ScreenDisplayRegister_MinBrightness00
	STA.w !REGISTER_ScreenDisplayRegister
	PHK
	PLB
	REP.b #$38
else
	; This is the starting address of SMW. This takes care of basic
	; initialization such as disabling IRQ, HDMA, DMA, clearing the SPC ports,
	; enabling F-blank, disabling emulation mode, disabling decimal mode,
	; initializing the direct page, and setting up the stack.
	SEI				; Disable IRQ.
	STZ.w !REGISTER_IRQNMIAndJoypadEnableFlags	; Disable IRQ, NMI and joypad reading.
	STZ.w !REGISTER_HDMAEnable	; Disable HDMA.
	STZ.w !REGISTER_DMAEnable	; Disable DMA.
	STZ.w !REGISTER_APUPort0	;\ Clear SPC I/O ports.
	STZ.w !REGISTER_APUPort1	;|
	STZ.w !REGISTER_APUPort2	;|
	STZ.w !REGISTER_APUPort3	;/
	LDA.b #!ScreenDisplayRegister_SetForceBlank|!ScreenDisplayRegister_MinBrightness00	;\ Enable F-blank.
	STA.w !REGISTER_ScreenDisplayRegister	;/
	CLC				;\ Disable emulation mode.
	XCE				;/
	REP.b #$38			; AXY->16, Disable decimal mode.
	LDA.w #!Define_SMW_DirectPageLocation	;\ Initialize the direct page.
	TCD				;/
	LDA.w #!RAM_SMW_Misc_StartOfStack	;\ Initialize the stack pointer.
	TCS				;/
endif
	; This is code is responsible for uploading the OAM clear routine to
	; $7F8000. The uploaded routine is essentially an unrolled loop which
	; stores #$F0 to all of the OAM mirror($0200) Y positions.
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/008027.asm"
namespace SMW_InitAndMainLoop
else
	LDA.w #$F0A9			;\ "LDA #$F0"
	STA.l !RAM_SMW_Sprites_ResetSpriteOAMRt	;/
	LDX.w #$017D
	LDY.w #SMW_OAMBuffer[$7F].YDisp	; Starting address to clear ($03FD).
CODE_008034:
	LDA.w #$008D			;\
	STA.l !RAM_SMW_Sprites_ResetSpriteOAMRt+$02,x	;| "STA $xxxx" for each OAM slot
	TYA				;|
	STA.l !RAM_SMW_Sprites_ResetSpriteOAMRt+$03,x	;/
	SEC
	SBC.w #$0004
	TAY
	DEX
	DEX
	DEX
	BPL.b CODE_008034
endif
	SEP.b #$30			; AXY->8
#LM000Hijack_Bank00RTL:
	LDA.b #$6B			;\ "RTL"
	STA.l !RAM_SMW_Sprites_ResetSpriteOAMRt+$0182	;/
if ver_is_smasw(!Define_Global_ROMToAssemble) == 0
	; This is the main part of the SMW initialization routine. SPC engine
	; upload, sample upload, OAM setup, windowing setup, and RAM clearing all
	; happens here.
	JSR.w SMW_HandleSPCUploads_UploadSPCEngine	; Upload the SPC engine.
endif
	STZ.w !RAM_SMW_Misc_GameMode	; Clear game mode.
	STZ.w !RAM_SMW_Misc_IntroLevelFlag	; Clear OW bypass level number.
	JSR.w SMW_InitializeFirst8KBOfRAM_Main	; Clear out $0000-$1FFF and $7F837B/D.
	JSR.w SMW_HandleSPCUploads_UploadSamples			; Optimization: Why isn't this part of UploadSPCEngine? UploadSamples is only referenced by the upcoming JSR.w.
	JSR.w SMW_SetupHDMAWindowingEffects_Main	; Set up DMA for window settings.
if !SMW_GlobalCode_InitWanted == !TRUE
	; The same five bytes as the OAM pair below. The project's own boot
	; code runs once here, with the RAM cleared and the SPC engine up, and
	; the stub repeats the pair. See Config/GlobalCode.asm.
	JML.l SMW_GlobalCode_InitStub
	NOP
else
	LDA.b #!Define_SMW_GlobalSpriteSizeAndVRAMLocation
	STA.w !REGISTER_OAMSizeAndDataAreaDesignation	; Set OAM character sizes to be 8x8 and 16x16.
endif
GlobalCodeInitReturn:
	INC.b !RAM_SMW_Flag_Lagging	; Bypass the loop the first time
; This is the main game loop of SMW. It is used to wait for V-blank to
; complete before executing the code of the next frame. One of the frame
; counters ($13) is also incremented here.
CODE_00806B:
if defined("Define_SMW_SA1")
	JMP.w ram_main_loop_start
	NOP
else
	LDA.b !RAM_SMW_Flag_Lagging					;\ Optimization: This wait for V_Blank can be improved with a WAI.
	BEQ.b CODE_00806B						;/
endif
#SA1Pack_MainLoopStartLocation:
	CLI				; Enable interrupts.
if ver_is_smasw_europe(!Define_Global_ROMToAssemble)
	LDA.l !SRAM_SMAS_Global_RunningDemoFlag
	BEQ.b CODE_3080D6
	LDA.w !RAM_SMW_IO_ControllerPress1CopyP1
	ORA.w !RAM_SMW_IO_ControllerPress1CopyP2
	ORA.w !RAM_SMW_IO_ControllerPress2CopyP1
	ORA.w !RAM_SMW_IO_ControllerPress2CopyP2
	AND.b #!Joypad_X|(!Joypad_Y>>8)
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_IO_ControllerPress1CopyP1
	ORA.w !RAM_SMW_IO_ControllerPress1CopyP2
	AND.b #!Joypad_Start>>8
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	BEQ.b CODE_3080B2
	JML.l SMAS_CopyOfResetToSMASTitleScreen_Main

CODE_3080B2:
	STZ.w !RAM_SMW_IO_ControllerHold1
	STZ.w !RAM_SMW_IO_ControllerPress1
	STZ.w !RAM_SMW_IO_ControllerHold2
	STZ.w !RAM_SMW_IO_ControllerPress2
	STZ.w !RAM_SMW_IO_ControllerHold1CopyP1
	STZ.w !RAM_SMW_IO_ControllerHold1CopyP2
	STZ.w !RAM_SMW_IO_ControllerHold2CopyP1
	STZ.w !RAM_SMW_IO_ControllerHold2CopyP2
	STZ.w !RAM_SMW_IO_ControllerPress1CopyP1
	STZ.w !RAM_SMW_IO_ControllerPress1CopyP2
	STZ.w !RAM_SMW_IO_ControllerPress2CopyP1
	STZ.w !RAM_SMW_IO_ControllerPress2CopyP2
CODE_3080D6:
endif
	INC.b !RAM_SMW_Counter_GlobalFrames	; Increment global frame counter.
if !SMW_FrameHookWanted == !TRUE
	; The same five bytes as the call and the store below. The project's
	; own frame code runs around the game mode's: the global main routine
	; and the mode's own code first, the displaced call through the RTL
	; below, the mode's end code after. See Config/GlobalCode.asm.
	JML.l SMW_FrameCode_Stub
FrameCodeLanding:
	RTL				;> The RTS return the stub pushes for the call it displaced
else
	JSR.w ProcessGameMode		; Run the game.
	STZ.b !RAM_SMW_Flag_Lagging	; Indicate that the current frame has finished.
endif
FrameCodeReturn:
	BRA.b CODE_00806B

namespace off
endmacro

macro ROUTINE_RT01_SMW_InitAndMainLoop(Address)
namespace SMW_InitAndMainLoop
%InsertMacroAtXPosition(<Address>)

ProcessGameMode:
	LDA.w !RAM_SMW_Misc_GameMode	; Load game mode
	JSL.l SMW_ExecutePtr_Absolute

GameModePtrs:
base $000000
; 16-bit game mode pointers. Indexed by $7E:0100.
.GameMode00_LoadNintendoPresents:		dw SMW_GameMode00_LoadNintendoPresents_Main	; 00 - load nintendo presents
.GameMode01_ShowNintendoPresents:		dw SMW_GameMode01_ShowNintendoPresents_Main	; 01 - nintendo presents
.GameMode02_FadeOutToTitleScreen:		dw SMW_GameMode02_FadeOutToTitleScreen_Main	; 02 - fade out to title screen
.GameMode03_LoadTitleScreenSublevel:		dw SMW_GameMode03_LoadTitleScreenSublevel_Main	; 03 - load title screen
.GameMode04_PrepareTitleScreen:			dw SMW_GameMode04_PrepareTitleScreen_Main	; 04 - prepare title screen
.GameMode05_FadeInToTitleScreen:		dw SMW_GameMode05_FadeInToTitleScreen_Main	; 05 - fade in to title screen
.GameMode06_CircleEffect:			dw SMW_GameMode06_CircleEffect_Main	; 06 - title screen spotlight
.GameMode07_TitleScreenDemo:			dw SMW_GameMode07_TitleScreenDemo_Main	; 07 - title screen
.GameMode08_FileSelect:				dw SMW_GameMode08_FileSelect_Main	; 08 - file select
.GameMode09_EraseFile:				dw SMW_GameMode09_EraseFile_Main	; 09 - file delete
.GameMode0A_PlayerSelect:			dw SMW_GameMode0A_PlayerSelect_Main	; 0A - player select
.GameMode0B_FadeOutToOverworld:			dw SMW_GameMode0B_FadeOutToOverworld_Main	; 0B - fade out to overworld
.GameMode0C_LoadOverworld:			dw SMW_GameMode0C_LoadOverworld_Main	; 0C - load overworld
.GameMode0D_FadeInToOverworld:			dw SMW_GameMode0D_FadeInToOverworld_Main	; 0D - fade in to overworld
.GameMode0E_ShowOverworld:			dw SMW_GameMode0E_ShowOverworld_Main	; 0E - overworld
.GameMode0F_MosaicFadeOutToLevel:		dw SMW_GameMode0F_MosaicFadeOutToLevel_Main	; 0F - fade out to level
.GameMode10_BufferLevelLoadMessage:		dw SMW_GameMode10_BufferLevelLoadMessage_Main	; 10 - finish fade to level
.GameMode11_LoadSublevel:			dw SMW_GameMode11_LoadSublevel_Main	; 11 - load level
.GameMode12_PrepareLevel:			dw SMW_GameMode12_PrepareLevel_Main	; 12 - prepare level
.GameMode13_MosaicFadeInToLevel:		dw SMW_GameMode13_MosaicFadeInToLevel_Main	; 13 - fade in to level
.GameMode14_InLevel:				dw SMW_GameMode14_InLevel_Main	; 14 - level
.GameMode15_FadeOutToDeathMessage:		dw SMW_GameMode15_FadeOutToDeathMessage_Main	; 15 - fade out to game over/time up
.GameMode16_LoadDeathMessage:			dw SMW_GameMode16_LoadDeathMessage_Main	; 16 - load game over/time up
.GameMode17_ShowDeathMessage:			dw SMW_GameMode17_ShowDeathMessage_Main	; 17 - game over/time up
.GameMode18_FadeOutToCutscene:			dw SMW_GameMode18_FadeOutToCutscene_Main	; 18 - fade out to credits
.GameMode19_Cutscene:				dw SMW_GameMode19_Cutscene_Main	; 19 - load castle cutscene/credits
.GameMode1A_FadeOutToCredits:			dw SMW_GameMode1A_FadeOutToCredits_Main	; 1A - fade in to castle cutscene/credits
.GameMode1B_EndingCinema:			dw SMW_GameMode1B_EndingCinema_Main	; 1B - castle cutscene/credits
.GameMode1C_FadeOutToYoshisHouse:		dw SMW_GameMode1C_FadeOutToYoshisHouse_Main	; 1C - fade out to credits yoshi house
.GameMode1D_LoadYoshisHouse:			dw SMW_GameMode1D_LoadYoshisHouse_Main	; 1D - load credits yoshi house
.GameMode1E_FadeInToYoshisHouse:		dw SMW_GameMode1E_FadeInToYoshisHouse_Main	; 1E - fade in to credits yoshi house
.GameMode1F_ShowYoshisHouse:			dw SMW_GameMode1F_ShowYoshisHouse_Main	; 1F - credits yoshi house
.GameMode20_FadeOutToEnemyRollcallDelay:	dw SMW_GameMode20_FadeOutToEnemyRollcallDelay_Main	; 20 - fade out to load credits enemy list
.GameMode21_DelayEnemyRollcall:			dw SMW_GameMode21_DelayEnemyRollcall_Main	; 21 - load credits enemy list
.GameMode22_FadeOutToEnemyRollcall:		dw SMW_GameMode22_FadeOutToEnemyRollcall_Main	; 22 - fade out to credits enemy list
.GameMode23_LoadEnemyRollcallScreen:		dw SMW_GameMode23_LoadEnemyRollcallScreen_Main	; 23 - prepare credits enemy list
.GameMode24_FadeInToEnemyRollcall:		dw SMW_GameMode24_FadeInToEnemyRollcall_Main	; 24 - fade in to credits enemy list
.GameMode25_ShowEnemyRollcallScreen:		dw SMW_GameMode25_ShowEnemyRollcallScreen_Main	; 25 - credits enemy list
.GameMode26_FadeOutToTheEnd:			dw SMW_GameMode26_FadeOutToTheEnd_Main	; 26 - fade out to the end screen
.GameMode27_LoadTheEnd:				dw SMW_GameMode27_LoadTheEnd_Main	; 27 - load the end screen
.GameMode28_ShowTheEnd:				dw SMW_GameMode28_ShowTheEnd_Main	; 28 - fade in to the end screen
.GameMode29_DoNothingOnTheEndScreen:		dw SMW_GameMode29_DoNothingOnTheEndScreen_Main	; 29 - the end screen
base off
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_VBlankRoutine(Address)
namespace SMW_VBlankRoutine
%InsertMacroAtXPosition(<Address>)

Main:
#SA1Pack_NMIHijack:
if ver_is_smasw(!Define_Global_ROMToAssemble)
if ver_is_smasw_europe(!Define_Global_ROMToAssemble)
	LDA.b #Main>>16
	PHA
else
	PHK
endif
	PLB
	LDA.w !REGISTER_NMIEnable
	LDA.l !SRAM_SMAS_Global_RunningDemoFlag
	BNE.b CODE_0081AA
else
	; SMW's NMI routine.
if defined("Define_SMW_SA1")
	JML.l snes_nmi
else
	SEI				; Disable interrupts to prevent interrupting an interrupt.
	PHP							;\ Optimization: PHP/PLP is not necessary here as the interrupt call already preserves the processor flags
								;/ Can be replaced with PHD/PLD to allow the direct page register to be modified safely.
	REP.b #$30			; Make A, X and Y 16-bit (pointless?)
endif
	PHA
	PHX
	PHY
	PHB
#SA1Pack_NMIHijackEnd:
	PHK
	PLB
	SEP.b #$30			; AXY->8
	LDA.w !REGISTER_NMIEnable	; Read to clear the n flag.
endif
	; Handles transfers to and from the SPC700 (I/O). Changing all values to
	; [EA] (NOP) or jumping over the code effectively mutes all sound.
if !SMW_LevelCode_NmiWanted == !TRUE
	; The same five bytes as the read and its branch. The level's own VBlank
	; code runs first, and the stub repeats both -- leaving A holding what the
	; read loaded, which both sides of the branch store back. Only planted
	; when some level declares an nmi:, so a project without one pays nothing
	; in VBlank. See Config/LevelCode.asm.
	JML.l SMW_LevelCode_Nmi
	NOP
else
	LDA.w !RAM_SMW_IO_MusicCh1				;\ Optimization: Waste of V-blank time. This ought to have been done at the start of the frame rather than during V-blank.
	BNE.b NoMusicChange					;|
endif
LevelCodeReturn:
	LDY.w !REGISTER_APUPort2				;|
	CPY.w !RAM_SMW_IO_CopyOfMusicCh1			;|
	BNE.b CODE_00818F					;|
NoMusicChange:							;|
	STA.w !REGISTER_APUPort2				;|
	STA.w !RAM_SMW_IO_CopyOfMusicCh1			;|
	STZ.w !RAM_SMW_IO_MusicCh1				;|
CODE_00818F:							;|
	LDA.w !RAM_SMW_IO_SoundCh1				;|
	STA.w !REGISTER_APUPort0				;|
	LDA.w !RAM_SMW_IO_SoundCh2				;|
	STA.w !REGISTER_APUPort1				;|
	LDA.w !RAM_SMW_IO_SoundCh3				;|
	STA.w !REGISTER_APUPort3				;|
	STZ.w !RAM_SMW_IO_SoundCh1				;|
	STZ.w !RAM_SMW_IO_SoundCh2				;|
	STZ.w !RAM_SMW_IO_SoundCh3				;/
CODE_0081AA:
	LDA.b #!ScreenDisplayRegister_SetForceBlank|!ScreenDisplayRegister_MinBrightness00	;\ Force blank.
	STA.w !REGISTER_ScreenDisplayRegister	;/
	STZ.w !REGISTER_HDMAEnable	; Disable HDMA.
	LDA.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings	;\ Update layer 1 and 2 window mask settings.
	STA.w !REGISTER_BG1And2WindowMaskSettings	;/
	LDA.b !RAM_SMW_Mirror_BG3And4WindowMaskSettings	;\ Update layer 3 and 4 window mask settings.
	STA.w !REGISTER_BG3And4WindowMaskSettings	;/
	LDA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings	;\ Update sprite and color window settings.
	STA.w !REGISTER_ObjectAndColorWindowSettings	;/
	LDA.b !RAM_SMW_Mirror_ColorMathInitialSettings	;\ Initial color addition settings.
	STA.w !REGISTER_ColorMathInitialSettings	;/
	LDA.w !RAM_SMW_Misc_NMIToUseFlag	;\ Check if a regular level.
	BPL.b RegularNMI		;|
	JMP.w Mode7NMI			;/ Otherwise, go to mode 7 routines.

RegularNMI:
	LDA.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
	AND.b #$FB
	STA.w !REGISTER_ColorMathSelectAndEnable	;\ Mode 1 with layer 3 priority.
	LDA.b #!BGModeAndTileSizeSetting_Mode01Enable|!BGModeAndTileSizeSetting_Mode01Layer3Priority	;/
	STA.w !REGISTER_BGModeAndTileSizeSetting
	LDA.b !RAM_SMW_Flag_Lagging	; \ If there isn't any lag,
	BEQ.b RunRegularNMI		; / branch to $81E7
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	LSR
#LM170Hijack_VRAMRearrangement1:
	BEQ.b NMINotSpecialLv
	JMP.w CODE_00827A

RunRegularNMI:
	INC.b !RAM_SMW_Flag_Lagging	; Allow the game loop to run after NMI.
	JSR.w SMW_UpdatePaletteFromIndexedTable_Main	; Upload palette to CGRAM.
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	LSR				;|| Skip down if not either in a regular level, loading message (MARIO START), title screen, or castle cutscene.
	BNE.b CODE_008222
	BCS.b CODE_0081F7		;|\ Draw status bar if in a regular level.
	JSR.w SMW_UploadStatusBarTilemap_Main
CODE_0081F7:
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene	; \
	CMP.b #$08			;  |If the current cutscene isn't the ending,
	BNE.b CODE_008209		; / branch to $8209
	LDA.w !RAM_SMW_Flag_UpdateCreditsBackground	;|| Handle DMA for the background during the credits staff roll, if applicable.
	BEQ.b CODE_00821A
	JSL.l SMW_UpdateCreditsBackground_Main
	BRA.b CODE_00821A

CODE_008209:
#LM170Hijack_VRAMRearrangement2:
	JSL.l SMW_UploadLevelLayer1And2Tilemaps_Main	;| Update Layer 1/2 tilemaps.
	LDA.w !RAM_SMW_Flag_UploadLoadScreenLettersToVRAM
	BEQ.b CODE_008217		;|| If set to do so, upload graphics for black screen messages (MARIO START/GAME OVER/TIME UP/etc).
	JSR.w SMW_UploadLoadingLettersTiles_Main	;||  Then skip way down to the $12 tilemap handling.
	BRA.b CODE_00823D

CODE_008217:
	JSR.w SMW_UploadLevelAnimations_Main
CODE_00821A:
	JSR.w SMW_RestoreSP1AfterMarioStart_Main				; Optimization: Should be removed in the optimized code. This routine is junk
	JSR.w SMW_UploadPlayerGFX_Main	;| Handle DMA for the player/Yoshi/Podoboo tiles.
	BRA.b CODE_00823D

CODE_008222:
	LDA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	CMP.b #$0A
	BNE.b CODE_008237
	LDY.w !RAM_SMW_Overworld_SubmapSwitchProcess	;|| If switching between two submaps on the overworld,
	DEY				;||  and currently updating Layer 1, do exactly that.
	DEY
	CPY.b #$04			;|| Then skip down to controller updating.
	BCS.b CODE_008237
	JSR.w SMW_UploadOverworldLayer1And2Tilemaps_Main
	BRA.b CODE_008243

CODE_008237:
	JSR.w SMW_UploadOverworldAnimations_Main	;| Upload overworld animated tile graphics and animated palettes.
	JSR.w SMW_UploadPlayerGFX_Main	;/ Handle DMA for the player/Yoshi/Podoboo tiles.
CODE_00823D:
	JSR.w SMW_LoadStripeImage_Sub	; Upload tilemap data from $12.
	JSR.w SMW_UploadOAMBuffer_Main	; Upload OAM.
CODE_008243:
	JSR.w SMW_PollJoypadInputs_Main	; Get controller data.
NMINotSpecialLv:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;\
	STA.w !REGISTER_BG1HorizScrollOffset	;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;|
	STA.w !REGISTER_BG1HorizScrollOffset	;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	CLC				;| Upload Layer 1's position.
	ADC.w !RAM_SMW_ShakingLayer1DispYLo	;|
	STA.w !REGISTER_BG1VertScrollOffset	;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;|
	ADC.w !RAM_SMW_ShakingLayer1DispYHi	;|
	STA.w !REGISTER_BG1VertScrollOffset	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo	;\
	STA.w !REGISTER_BG2HorizScrollOffset	;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer2XPosHi	;|
	STA.w !REGISTER_BG2HorizScrollOffset	;| Upload Layer 2's position.
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo	;|
	STA.w !REGISTER_BG2VertScrollOffset	;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosHi	;|
	STA.w !REGISTER_BG2VertScrollOffset	;/
	LDA.w !RAM_SMW_Misc_NMIToUseFlag	; \ If in a normal (not special) level, branch
	BEQ.b CODE_008292		; /
CODE_00827A:
#SA1Pack_IRQTriggerHack1:
if defined("Define_SMW_SA1")
	LDX.b #$81
else
	LDA.b #$81
endif
	LDY.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene	; \
	CPY.b #$08			;  |If not playing ending movie, branch to $82A1
	BNE.b CODE_0082A1		; /
	LDY.w !RAM_SMW_Mirror_ScreenDisplayRegister	; \
	STY.w !REGISTER_ScreenDisplayRegister	; / Set brightness to $0DAE ; Screen Display Register
	LDY.w !RAM_SMW_Mirror_HDMAEnable	; \
	STY.w !REGISTER_HDMAEnable	; / Set HDMA channel enable to $0D9F ; H-DMA Channel Enable
	JMP.w SMW_IRQRoutine_IRQNMIEnding

CODE_008292:
	LDY.b #!Define_SMW_RegularLevelStatusBarScanlineEnd
CODE_008294:
	LDA.w !REGISTER_IRQEnable
	STY.w !REGISTER_VCountTimerLo	;| Enable IRQ #1 on this scanline, for the status bar.
	STZ.w !REGISTER_VCountTimerHi
	STZ.b !RAM_SMW_Flag_IRQToUse
#SA1Pack_IRQTriggerHack2:
if defined("Define_SMW_SA1")
	LDX.b #$A1
CODE_0082A1:
	BRA.b +
	NOP
+
else
	LDA.b #$A1
CODE_0082A1:
	STA.w !REGISTER_IRQNMIAndJoypadEnableFlags	; NMI, V/H Count, and Joypad Enable
endif
	STZ.w !REGISTER_BG3HorizScrollOffset	; \  ; BG 3 Horizontal Scroll Offset- Write twice register
	STZ.w !REGISTER_BG3HorizScrollOffset	;  |Set Layer 3 horizontal and vertical ; BG 3 Horizontal Scroll Offset
	STZ.w !REGISTER_BG3VertScrollOffset	;  |scroll to x00 ; BG 3 Vertical Scroll Offset ; Write twice register
	STZ.w !REGISTER_BG3VertScrollOffset	; /  ; BG 3 Vertical Scroll Offset
	LDA.w !RAM_SMW_Mirror_ScreenDisplayRegister	; \
	STA.w !REGISTER_ScreenDisplayRegister	; / Set brightness to $0DAE ; Screen Display Register
	LDA.w !RAM_SMW_Mirror_HDMAEnable	; \
	STA.w !REGISTER_HDMAEnable	; / Set HDMA channel enable to $0D9F ; H-DMA Channel Enable
if ver_is_smasw(!Define_Global_ROMToAssemble)
EndofVBlank:
	RTL
else
#SA1Pack_EndOfSNESNMI:
if defined("Define_SMW_SA1")
	JML.l snes_nmi_end
else
	REP.b #$30			; \ Pull all ; Index (16 bit) Accum (16 bit)
	PLB				;  |
	PLY				;  |
endif
	PLX				;  |
	PLA				;  |
	PLP				; /
EndofVBlank:
	RTI				; And return
endif

Mode7NMI:
	LDA.b !RAM_SMW_Flag_Lagging	;\ Branch if in a lag frame.
	BNE.b CODE_0082F7		;/
	INC.b !RAM_SMW_Flag_Lagging	; make it lag?
	LDA.w !RAM_SMW_Flag_UploadLoadScreenLettersToVRAM	;\
	BEQ.b CODE_0082D4		;| If set to do so, upload tiles for the MARIO START/TIME UP/GAME OVER messages.
	JSR.w SMW_UploadLoadingLettersTiles_Main	;|  Then skip down to drawing the status bar.
	BRA.b CODE_0082E8		;/

CODE_0082D4:
	JSR.w SMW_RestoreSP1AfterMarioStart_Main				; Optimization: Should be removed in the optimized code. This routine is junk
	JSR.w SMW_UploadPlayerGFX_Main	; Handle DMA for the player/Yoshi/Podoboo tiles.
	BIT.w !RAM_SMW_Misc_NMIToUseFlag	;\
	BVC.b CODE_0082E8		;/ if not on special type of mode, skip the JSR and such
	JSR.w SMW_UploadMode7KoopaBossesAndLavaAnimation_Main
	LDA.w !RAM_SMW_Misc_NMIToUseFlag	;| If in Reznor/Morton/Roy/Ludwig/Bowser's battles, upload their Mode 7 tilemaps and animate their lava.
	LSR				;| If in Iggy/Larry/Reznor/Morton/Roy/Ludwig's battles, draw the status bar.
	BCS.b CODE_0082EB
CODE_0082E8:
	JSR.w SMW_UploadStatusBarTilemap_Main
CODE_0082EB:
	JSR.w SMW_UpdatePaletteFromIndexedTable_Main	; Upload palette to CGRAM.
	JSR.w SMW_LoadStripeImage_Sub	; Upload tilemap data from $12.
	JSR.w SMW_UploadOAMBuffer_Main	; Upload OAM.
	JSR.w SMW_PollJoypadInputs_Main	; Get controller data.
CODE_0082F7:
	LDA.b #!BGModeAndTileSizeSetting_Mode01Enable|!BGModeAndTileSizeSetting_Mode01Layer3Priority	;\ Make it mode 1, and Layer 3 have priority
	STA.w !REGISTER_BGModeAndTileSizeSetting	;/BG Mode and Tile Size Setting
	LDA.b !RAM_SMW_Mirror_M7CenterXPosLo
	CLC				;| Copy over the Mode 7 addresses from their SMW mirrors
	ADC.b #$80
	STA.w !REGISTER_Mode7CenterX	; Mode 7 Center Position X
	LDA.b !RAM_SMW_Mirror_M7CenterXPosHi
	ADC.b #$00
	STA.w !REGISTER_Mode7CenterX	; Mode 7 Center Position X
	LDA.b !RAM_SMW_Mirror_M7CenterYPosLo
	CLC
	ADC.b #$80
	STA.w !REGISTER_Mode7CenterY	; Mode 7 Center Position Y
	LDA.b !RAM_SMW_Mirror_M7CenterYPosHi
	ADC.b #$00
	STA.w !REGISTER_Mode7CenterY	; Mode 7 Center Position Y
	LDA.b !RAM_SMW_Mirror_M7MatrixALo
	STA.w !REGISTER_Mode7MatrixParameterA
	LDA.b !RAM_SMW_Mirror_M7MatrixAHi
	STA.w !REGISTER_Mode7MatrixParameterA
	LDA.b !RAM_SMW_Mirror_M7MatrixBLo
	STA.w !REGISTER_Mode7MatrixParameterB
	LDA.b !RAM_SMW_Mirror_M7MatrixBHi
	STA.w !REGISTER_Mode7MatrixParameterB
	LDA.b !RAM_SMW_Mirror_M7MatrixCLo
	STA.w !REGISTER_Mode7MatrixParameterC
	LDA.b !RAM_SMW_Mirror_M7MatrixCHi
	STA.w !REGISTER_Mode7MatrixParameterC
	LDA.b !RAM_SMW_Mirror_M7MatrixDLo
	STA.w !REGISTER_Mode7MatrixParameterD
	LDA.b !RAM_SMW_Mirror_M7MatrixDHi
	STA.w !REGISTER_Mode7MatrixParameterD
	JSR.w SMW_SetMode7PPUPointersAndLayer1Scroll_Main	;scroll layer 1 accordingly (update layer 1)
	LDA.w !RAM_SMW_Misc_NMIToUseFlag	;\
	LSR				;| Branch if not in Bowser's room.
	BCC.b CODE_00835C		;/
	LDA.w !RAM_SMW_Mirror_ScreenDisplayRegister	;\ update brightness
	STA.w !REGISTER_ScreenDisplayRegister	;/Screen Display Register
	LDA.w !RAM_SMW_Mirror_HDMAEnable	;\
	STA.w !REGISTER_HDMAEnable	;/H-DMA Channel Enable
	LDA.b #$81			;\ Skip the status bar IRQ and immediately prepare the registers after.
	JMP.w SMW_Mode7Layer1Scroll_Main	;/

CODE_00835C:
	LDY.b #!Define_SMW_Mode7RoomStatusBarScanlineEnd	;\ Scanline the status bar ends at in Iggy/Larry/Ludwig/Reznor's rooms.
	BIT.w !RAM_SMW_Misc_NMIToUseFlag	;|
	BVC.b IggyLarryRoom		;|
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBoss	;|
	ASL				;|
	TAX				;|
	LDA.w SMW_PlayerState00_Normal_DATA_00F8E8,x	;|
	CMP.b #$2A			;|
	BNE.b NotMortonOrRoyRoom	;|
	LDY.b #!Define_SMW_MortonRoyRoomStatusBarScanlineEnd	;/ Scanline the status bar ends at in Morton/Roy's rooms.
IggyLarryRoom:
NotMortonOrRoyRoom:
	JMP.w CODE_008294		; Prepare IRQ, and set up a couple more registers.
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_UploadPlayerGFX(Address)
namespace SMW_UploadPlayerGFX
%InsertMacroAtXPosition(<Address>)

Main:
if ver_is_smasw_europe(!Define_Global_ROMToAssemble)
	JSL.l MarioAndLuigi
	RTS
else
	; The routine that handles the graphics that get DMA'd to the first five
	; 16x16 tiles in SP1. It also write the necessary colors to the player's
	; palette (colors 6-F). $00A30A - Mario/Luigi Palette - Starting Index
	; (Changing this will cause Mario/Luigi to flash when the screen fades out
	; after beating a boss) $00A320 - Mario/Luigi Palette - Amount of colours *
	; 2 $00A307 - [F0] Changing this to [80] will skip the player's palette
	; write code, removing palette 8's hardcoded colors.
	REP.b #$20			; A->16
	LDX.b #$04			; We're using DMA channel 2
	LDY.w !RAM_SMW_Player_NumberOfTilesToUpdate
	BEQ.b CODE_00A328
	LDY.b #!CGRAM_SMW_DynamicPlayerPalette	; \ Set Address for CG-RAM Write to x86
	STY.w !REGISTER_CGRAMAddress
	LDA.w #((!REGISTER_WriteToCGRAMPort&$0000FF)<<8)+$00
	STA.w DMA[$02].Parameters	; Parameters for DMA Transfer
	LDA.w !RAM_SMW_Pointer_PlayerPaletteLo	; \ Get location of palette from $0D82-$0D83
	STA.w DMA[$02].SourceLo
	LDY.b #SMW_GlobalPalettes_Mario>>16	; \ Palette is stored in bank x00
	STY.w DMA[$02].SourceBank
	LDA.w #$0014			; \ x14 bytes will be transferred
	STA.w DMA[$02].SizeLo
	STX.w !REGISTER_DMAEnable	; Transfer the colors
CODE_00A328:
	LDY.b #$80			; \ Set VRAM Address Increment Value to x80
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w #((!REGISTER_WriteToVRAMPortLo&$0000FF)<<8)+$01
	STA.w DMA[$02].Parameters	; Parameters for DMA Transfer
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$07F0
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	LDA.w #$0020
	STA.w DMA[$02].SizeLo
	LDA.w !RAM_SMW_Graphics_DynamicSpriteTile7FLo
	LDY.w !RAM_SMW_Player_CurrentCharacter
	BNE.b PlayingAsLuigi
	STA.w DMA[$02].SourceLo
	LDY.b #!RAM_SMW_Graphics_DecompressedGFX32>>16
	STY.w DMA[$02].SourceBank
else
	LDA.w !RAM_SMW_Graphics_DynamicSpriteTile7FLo
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDY.b #!RAM_SMW_Graphics_DecompressedGFX32>>16	; \ Set bank to x7E
	STY.w DMA[$02].SourceBank
	LDA.w #$0020			; \ x20 bytes will be transferred
	STA.w DMA[$02].SizeLo
endif
	STX.w !REGISTER_DMAEnable	; Transfer
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo	; \ Set Address for VRAM Read/Write to x6000
	STA.w !REGISTER_VRAMAddressLo
	LDX.b #$00
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	LDY.b #$04
endif
CODE_00A355:
	LDA.w SMW_DynamicSpritePointersTop[$00].LowByte,x	; \ Get address of graphics to copy
	STA.w DMA[$02].SourceLo
	LDA.w #$0040			; \ x40 bytes will be transferred
	STA.w DMA[$02].SizeLo
if ver_is_smasw_usa(!Define_Global_ROMToAssemble) == 0
	LDY.b #$04			; \ Transfer
endif
	STY.w !REGISTER_DMAEnable
	INX				; \ Move to next address
	INX
	CPX.w !RAM_SMW_Player_NumberOfTilesToUpdate	; \ Repeat last segment while X<$0D84
	BCC.b CODE_00A355
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$0100	; \ Set Address for VRAM Read/Write to x6100
	STA.w !REGISTER_VRAMAddressLo
	LDX.b #$00
CODE_00A375:
	LDA.w SMW_DynamicSpritePointersBottom[$00].LowByte,x	; \ Get address of graphics to copy
	STA.w DMA[$02].SourceLo
	LDA.w #$0040			; \ x40 bytes will be transferred
	STA.w DMA[$02].SizeLo
if ver_is_smasw_usa(!Define_Global_ROMToAssemble) == 0
	LDY.b #$04			; \ Transfer
endif
	STY.w !REGISTER_DMAEnable
	INX				; \ Move to next address
	INX
	CPX.w !RAM_SMW_Player_NumberOfTilesToUpdate	; \ Repeat last segment while X<$0D84
	BCC.b CODE_00A375
	SEP.b #$20			; A->8
	RTS

if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
PlayingAsLuigi:
	JSL.l Luigi
	RTS
endif
endif
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_PollJoypadInputs(Address)
namespace SMW_PollJoypadInputs
%InsertMacroAtXPosition(<Address>)

Main:
if ver_is_smasw(!Define_Global_ROMToAssemble)
	LDA.l !SRAM_SMAS_Global_Controller1PluggedInFlag
	TAX
	LDA.w !REGISTER_Joypad1Lo,x
	AND.b #$F0
	STA.w !RAM_SMW_IO_ControllerHold2CopyP1
	TAY
	EOR.w !RAM_SMW_IO_P1CtrlDisableHi
	AND.w !RAM_SMW_IO_ControllerHold2CopyP1
	STA.w !RAM_SMW_IO_ControllerPress2CopyP1
	STY.w !RAM_SMW_IO_P1CtrlDisableHi
	LDA.w !REGISTER_Joypad1Hi,x
	STA.w !RAM_SMW_IO_ControllerHold1CopyP1
	TAY
	EOR.w !RAM_SMW_IO_P1CtrlDisableLo
	AND.w !RAM_SMW_IO_ControllerHold1CopyP1
	STA.w !RAM_SMW_IO_ControllerPress1CopyP1
	STY.w !RAM_SMW_IO_P1CtrlDisableLo
	LDA.l !SRAM_SMAS_Global_Controller2PluggedInFlag
	TAX
	LDA.w !REGISTER_Joypad1Lo,x
	AND.b #$F0
	STA.w !RAM_SMW_IO_ControllerHold2CopyP2
	TAY
	EOR.w !RAM_SMW_IO_P2CtrlDisableHi
	AND.w !RAM_SMW_IO_ControllerHold2CopyP2
	STA.w !RAM_SMW_IO_ControllerPress2CopyP2
	STY.w !RAM_SMW_IO_P2CtrlDisableHi
	LDA.w !REGISTER_Joypad1Hi,x
	STA.w !RAM_SMW_IO_ControllerHold1CopyP2
	TAY
	EOR.w !RAM_SMW_IO_P2CtrlDisableLo
	AND.w !RAM_SMW_IO_ControllerHold1CopyP2
	STA.w !RAM_SMW_IO_ControllerPress1CopyP2
	STY.w !RAM_SMW_IO_P2CtrlDisableLo
	LDX.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_IO_ControllerHold2CopyP1,x
	AND.b #$C0
	ORA.w !RAM_SMW_IO_ControllerHold1CopyP1,x
	STA.b !RAM_SMW_IO_ControllerHold1
	LDA.w !RAM_SMW_IO_ControllerHold2CopyP1,x
	STA.b !RAM_SMW_IO_ControllerHold2
	LDA.w !RAM_SMW_IO_ControllerPress2CopyP1,x
	AND.b #$40
	ORA.w !RAM_SMW_IO_ControllerPress1CopyP1,x
	STA.b !RAM_SMW_IO_ControllerPress1
	LDA.w !RAM_SMW_IO_ControllerPress2CopyP1,x
	STA.b !RAM_SMW_IO_ControllerPress2
	RTS
else
	; This is the routine that polls the controller and updates $15, $16, $17,
	; $18. $0086A0 (x8A0) - Change to [9C A0 0D AD A0 0D A2 00] to cause both
	; player 1 & 2 to be controlled by controller 1.
	LDA.w !REGISTER_Joypad1Lo	;\\
	AND.b #$F0			;|| Get controller 1 data 2.
	STA.w !RAM_SMW_IO_ControllerHold2CopyP1	;|/
	TAY				;|\
	EOR.w !RAM_SMW_IO_P1CtrlDisableHi	;|| Get controller 1 data 2, one frame.
	AND.w !RAM_SMW_IO_ControllerHold2CopyP1	;||
	STA.w !RAM_SMW_IO_ControllerPress2CopyP1	;||
	STY.w !RAM_SMW_IO_P1CtrlDisableHi	;//
	LDA.w !REGISTER_Joypad1Hi	;\\ Get controller 1 data 1.
	STA.w !RAM_SMW_IO_ControllerHold1CopyP1	;|/
	TAY				;|\
	EOR.w !RAM_SMW_IO_P1CtrlDisableLo	;|| Get controller 1 data 1, one frame.
	AND.w !RAM_SMW_IO_ControllerHold1CopyP1	;||
	STA.w !RAM_SMW_IO_ControllerPress1CopyP1	;||
	STY.w !RAM_SMW_IO_P1CtrlDisableLo	;//
	LDA.w !REGISTER_Joypad2Lo	;\\
	AND.b #$F0			;|| Get controller 2 data 2.
	STA.w !RAM_SMW_IO_ControllerHold2CopyP2	;|/
	TAY				;|\
	EOR.w !RAM_SMW_IO_P2CtrlDisableHi	;|| Get controller 2 data 2, one frame.
	AND.w !RAM_SMW_IO_ControllerHold2CopyP2	;||
	STA.w !RAM_SMW_IO_ControllerPress2CopyP2	;||
	STY.w !RAM_SMW_IO_P2CtrlDisableHi	;//
	LDA.w !REGISTER_Joypad2Hi	;\\ Get controller 2 data 1.
	STA.w !RAM_SMW_IO_ControllerHold1CopyP2	;|/
	TAY				;|\
	EOR.w !RAM_SMW_IO_P2CtrlDisableLo	;|| Get controller 2 data 1, one frame.
	AND.w !RAM_SMW_IO_ControllerHold1CopyP2	;||
	STA.w !RAM_SMW_IO_ControllerPress1CopyP2	;||
	STY.w !RAM_SMW_IO_P2CtrlDisableLo	;//
	LDX.w !RAM_SMW_IO_ControllersPluggedIn	;\
	BPL.b CODE_0086A8		;| If $0DA0 is set to use separate controllers, use the current player number as the controller port to accept input from.
	LDX.w !RAM_SMW_Player_CurrentCharacter	;/
CODE_0086A8:
	LDA.w !RAM_SMW_IO_ControllerHold2CopyP1,x	;\
	AND.b #$C0			;| Set up $15, sharing the top two bits of controller data 2 (for A/X).
	ORA.w !RAM_SMW_IO_ControllerHold1CopyP1,x	;|
	STA.b !RAM_SMW_IO_ControllerHold1	;/
	LDA.w !RAM_SMW_IO_ControllerHold2CopyP1,x	;\ Set up $17.
	STA.b !RAM_SMW_IO_ControllerHold2	;/
	LDA.w !RAM_SMW_IO_ControllerPress2CopyP1,x	;\
	AND.b #$40			;| Set up $16, sharing the top two bits of controller data 2 (for A/X).
	ORA.w !RAM_SMW_IO_ControllerPress1CopyP1,x	;|
	STA.b !RAM_SMW_IO_ControllerPress1	;/
	LDA.w !RAM_SMW_IO_ControllerPress2CopyP1,x	;\ Set up $18.
	STA.b !RAM_SMW_IO_ControllerPress2	;/
	RTS
endif
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UploadOAMBuffer(Address)
namespace SMW_UploadOAMBuffer
%InsertMacroAtXPosition(<Address>)

; Routine responsible for DMAing the sprite OAM data from its RAM mirror at
; $7E0200-$7E041F (544 bytes) to register $2104.
Main:
	STZ.w DMA[!Define_SMW_OAMUploadDMAChannel].Parameters	; Use DMA channel 0; increment, one register write once.
	REP.b #$20			; A->16
	STZ.w !REGISTER_OAMAddressLo	; Clear the sprite OAM index.
	LDA.w #((SMW_OAMBuffer[$00].XDisp&$0000FF)<<8)+(!REGISTER_OAMDataWritePort&$0000FF)	;\
	STA.w DMA[!Define_SMW_OAMUploadDMAChannel].Destination	;| Set channel 0's destination to $2104 (data for OAM write)
	LDA.w #(SMW_OAMBuffer[$00].XDisp&$00FF00)>>8	;| and the source to $000200 (OAM table).
	STA.w DMA[!Define_SMW_OAMUploadDMAChannel].SourceHi		;/
	LDA.w #$0220			;\ Set the size to be 544 bytes.
	STA.w DMA[!Define_SMW_OAMUploadDMAChannel].SizeLo		;/
	LDY.b #($01<<!Define_SMW_OAMUploadDMAChannel)			;\ Begin DMA transfer on channel 0.
	STY.w !REGISTER_DMAEnable	;/
	SEP.b #$20			; A->8
if defined("Define_SMW_SA1")
	; SA-1 Pack: Ignore the $3F behavior on OAM upload.
	RTS
	db $80	; the tail of the LDA.b below, which the hijack leaves unreached
else
	LDA.b #$80			;\ Set OAM object priority bit.
endif
	STA.w !REGISTER_OAMAddressHi	;/
	LDA.b !RAM_SMW_Mirror_OAMAddressLo	;\ Set OAM index to $3F.
	STA.w !REGISTER_OAMAddressLo	;/
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UploadStatusBarTilemap(Address)
namespace SMW_UploadStatusBarTilemap
%InsertMacroAtXPosition(<Address>)

; The routine that draws the status bar onto the screen. It uses DMA to
; write the Layer 3 tiles to VRAM.
Main:
	STZ.w !REGISTER_VRAMAddressIncrementValue	; Set VRAM Address Increment Value to x00 ; VRAM Address Increment Value
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation+$42	; \
	STA.w !REGISTER_VRAMAddressLo	;  |Set Address for VRAM Read/Write to x5042 ; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation>>8	;  |
	STA.w !REGISTER_VRAMAddressHi	; /  ; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008DBB:
	LDA.w PARAMS_StBr1,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008DBB
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			; \ Activate DMA channel 1
	STA.w !REGISTER_DMAEnable	; /  ; Regular DMA Channel Enable
	STZ.w !REGISTER_VRAMAddressIncrementValue	; Set VRAM Address Increment Value to x00 ; VRAM Address Increment Value
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation+$63	; \
	STA.w !REGISTER_VRAMAddressLo	;  |Set Address for VRAM Read/Write to x5063 ; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation>>8	;  |
	STA.w !REGISTER_VRAMAddressHi	; /  ; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008DD8:
	LDA.w PARAMS_StBr2,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008DD8
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			; \ Activate DMA channel 1
	STA.w !REGISTER_DMAEnable	; /  ; Regular DMA Channel Enable
	RTS

PARAMS_StBr1:
	db $00,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Misc_StatusBarTilemap
	dw $001C

PARAMS_StBr2:
	db $00,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Misc_StatusBarTilemap+$1C
	dw $001B
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UploadLoadingLettersTiles(Address)
namespace SMW_UploadLoadingLettersTiles
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$20			; A->16
	LDX.b #$80
	STX.w !REGISTER_VRAMAddressIncrementValue
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w #((!REGISTER_WriteToVRAMPortLo&$0000FF)<<8)+$01
	STA.w DMA[$02].Parameters	; Parameters for DMA Transfer
	LDA.w #!RAM_SMW_Graphics_DecompressedLoadingLetters
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDX.b #!RAM_SMW_Graphics_DecompressedLoadingLetters>>16
	STX.w DMA[$02].SourceBank	; A Address Bank
	LDA.w #$00C0
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	LDX.b #$04
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$0100
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w #!RAM_SMW_Graphics_DecompressedLoadingLetters+$C0
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDA.w #$00C0
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$04A0
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w #!RAM_SMW_Graphics_DecompressedLoadingLetters+$0180
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDA.w #$00C0
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$05A0
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w #!RAM_SMW_Graphics_DecompressedLoadingLetters+$0240
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDA.w #$00C0
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UploadLevelAnimations(Address)
namespace SMW_UploadLevelAnimations
%InsertMacroAtXPosition(<Address>)

; [C2] Change to 60 to disable all animations in levels. This includes
; colour 64. Note: LM will still show the animations.
Main:
#LM160Hijack_UploadLevelExAnimationData:
	REP.b #$20							;\ LM: Hijacks this location if the level ExAnimation feature is used (1.60+)
	LDY.b #$80							;| This routine is for uploading the animation data to VRAM.
	STY.w !REGISTER_VRAMAddressIncrementValue			;/
	LDA.w #((!REGISTER_WriteToVRAMPortLo&$0000FF)<<8)+$01
	STA.w DMA[$02].Parameters	; Parameters for DMA Transfer
	LDY.b #!RAM_SMW_Graphics_DecompressedGFX33>>16
	STY.w DMA[$02].SourceBank	; A Address Bank
	LDX.b #$04
	LDA.w !RAM_SMW_Graphics_TileAnimationVRAMAddress3Lo
	BEQ.b DontUploadAnimation3
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Graphics_TileAnimationSourceAddress3Lo
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDA.w #$0080
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
DontUploadAnimation3:
	LDA.w !RAM_SMW_Graphics_TileAnimationVRAMAddress2Lo
	BEQ.b DontUploadAnimation2
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Graphics_TileAnimationSourceAddress2Lo
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDA.w #$0080
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
DontUploadAnimation2:
	LDA.w !RAM_SMW_Graphics_TileAnimationVRAMAddress1Lo
	BEQ.b CODE_00A418
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	CMP.w #$0800
	BEQ.b CODE_00A3F0
	LDA.w !RAM_SMW_Graphics_TileAnimationSourceAddress1Lo
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDA.w #$0080
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	BRA.b CODE_00A418

CODE_00A3F0:
	LDA.w !RAM_SMW_Graphics_TileAnimationSourceAddress1Lo
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDA.w #$0040
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	LDA.w #!VRAM_SMW_Layer1GFXVRAMLocation+$0900
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Graphics_TileAnimationSourceAddress1Lo
	CLC
	ADC.w #$0040
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDA.w #$0040
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
CODE_00A418:
	SEP.b #$20			; A->8
	; [A9] Changing this to 60 will disable the flashing yellow color in
	; levels, but not on the overworld.
	LDA.b #!CGRAM_SMW_YoshiCoinFlash
HandlePaletteAnimation:
;$00A41C
YellowFlash:
	STZ.b !RAM_SMW_Misc_ScratchRAM00
RedFlash:
	STA.w !REGISTER_CGRAMAddress	; Address for CG-RAM Write
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$1C
	LSR
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAY
	; Changing [B9 0C B6 8D 22 21 B9 0D B6 8D 22 21] to [80 0A EA EA EA EA EA
	; EA EA EA EA EA] will disable the flash animation of colour #64. Make sure
	; that the "View Animation" function in Lunar Magic is disabled. WARNING:
	; Will disable the animated colours on the OW too!
	LDA.w SMW_GlobalPalettes_Flashing,y
	STA.w !REGISTER_WriteToCGRAMPort	; Data for CG-RAM Write
	LDA.w SMW_GlobalPalettes_Flashing+$01,y
	STA.w !REGISTER_WriteToCGRAMPort	; Data for CG-RAM Write
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_RestoreSP1AfterMarioStart(Address)					; Optimization: This routine is trash. All it does is prevent tiles 4A-4F/5A-5F from being 4BPP, slows down level load, and wastes a byte of RAM and the amount of bytes this routine takes up.
namespace SMW_RestoreSP1AfterMarioStart
%InsertMacroAtXPosition(<Address>)

; Routine to restore tiles 4A-4F and 5A-5F after a loading screen message
; (MARIO START, TIME UP, GAME OVER, BONUS GAME) using their decompressed
; data copied to $0BF6. In a hacked ROM, though, Lunar Magic disables this
; routine by having it return immediately.
Main:
	LDA.w !RAM_SMW_Flag_RestoreSP1TilesAfterMarioStart
; Change [F0] (BEQ) to [80] (BRA) to prevent various tiles in SP1 to be
; overwritten (which meant using ExGFX for them would have no effect). This
; does not affect tiles 00-09, 10-19 and 7F of SP1.
#LM221Hijack_DisableSP1VRAMBackup1:
	BEQ.b Return00A47E							; LM: Changes the BEQ.b into BRA.b so this junk routine is skipped over. (2.21+)
	STZ.w !RAM_SMW_Flag_RestoreSP1TilesAfterMarioStart
	REP.b #$20			; A->16
	LDY.b #$80
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$04A0
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w #((!REGISTER_WriteToVRAMPortLo&$0000FF)<<8)+$01
	STA.w DMA[$02].Parameters	; Parameters for DMA Transfer
	LDA.w #!RAM_SMW_Graphics_DecompressedOverworldGFX+$0100
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDY.b #(!RAM_SMW_Graphics_DecompressedOverworldGFX>>16)
	STY.w DMA[$02].SourceBank	; A Address Bank
	LDA.w #$00C0
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	LDX.b #$04
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	LDA.w #!VRAM_SMW_SpriteGFXLocationLo+$05A0
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w #!RAM_SMW_Graphics_DecompressedOverworldGFX+$01C0
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDA.w #$00C0
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	SEP.b #$20			; A->8
Return00A47E:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UploadMode7KoopaBossesAndLavaAnimation(Address)
namespace SMW_UploadMode7KoopaBossesAndLavaAnimation
%InsertMacroAtXPosition(<Address>)

VRAMAddressToUpload:
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$129E,!VRAM_SMW_Layer1GFXVRAMLocation+$121E,!VRAM_SMW_Layer1GFXVRAMLocation+$119E,!VRAM_SMW_Layer1GFXVRAMLocation+$111E	; Morton, Roy, & Ludwig
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$161E,!VRAM_SMW_Layer1GFXVRAMLocation+$159E,!VRAM_SMW_Layer1GFXVRAMLocation+$151E,!VRAM_SMW_Layer1GFXVRAMLocation+$149E	;\ Bowser
	dw !VRAM_SMW_Layer1GFXVRAMLocation+$141E,!VRAM_SMW_Layer1GFXVRAMLocation+$139E,!VRAM_SMW_Layer1GFXVRAMLocation+$131E,!VRAM_SMW_Layer1GFXVRAMLocation+$169E	;/

Main:
	LDA.w !RAM_SMW_Misc_NMIToUseFlag	;\
	LSR				;| Branch if in Bowser's battle (don't animate lava).
	BCS.b CODE_0098E1		;/
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	LSR				;|
	LSR				;| Get frame of animation for the lava.
	AND.b #$06			;|
	TAX				;/
	REP.b #$20			; A->16
	LDY.b #$80
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w #((!REGISTER_WriteToVRAMPortLo&$0000FF)<<8)+$01
	STA.w DMA[$02].Parameters	; Parameters for DMA Transfer
	LDA.w #!VRAM_SMW_Layer1GFXVRAMLocation_Mode7+$0800
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.l SMW_LevelTileAnimations_FrameData_Local1_Frame5,x			; Info: It seems that animated lava tiles are uploaded to SP4 (tiles 480-483) in the Morton, Roy, Reznor(?) and Ludwig rooms.
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	LDY.b #!RAM_SMW_Graphics_DecompressedGFX33>>16
	STY.w DMA[$02].SourceBank	; A Address Bank
	LDA.w #$0080
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	LDY.b #$04
	STY.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	CLC
CODE_0098E1:
	REP.b #$20			; A->16
	LDA.w #$0004			;\ 4 rows of 4 tiles
	LDY.b #$06			;/
	BCC.b CODE_0098EF
	LDA.w #$0008								; Optimization: This could be changed to an ASL to save 2 bytes.
	LDY.b #$16
CODE_0098EF:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #!RAM_SMW_Misc_Mode7BossTilemap
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STZ.w !REGISTER_VRAMAddressIncrementValue
	LDA.w #((!REGISTER_WriteToVRAMPortLo&$0000FF)<<8)+$00
	STA.w DMA[$02].Parameters	; Parameters for DMA Transfer
	LDX.b #!RAM_SMW_Misc_Mode7BossTilemap>>16
	STX.w DMA[$02].SourceBank	; A Address Bank
	LDX.b #$04
CODE_009906:
	LDA.w VRAMAddressToUpload,y
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STX.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	DEY
	DEY
	BPL.b CODE_009906
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_UpdatePaletteFromIndexedTable(Address)
namespace SMW_UpdatePaletteFromIndexedTable
%InsertMacroAtXPosition(<Address>)

DATA_00A47F:
	dl !RAM_SMW_Palettes_DynamicPaletteBytesToUpload
	dl !RAM_SMW_Palettes_CopyOfPaletteMirror
	dl !RAM_SMW_Palettes_PaletteMirror

Main:
	LDY.w !RAM_SMW_Palettes_PaletteUploadTableIndex
	LDX.w DATA_00A47F+$02,y
	STX.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM01
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w DATA_00A47F+$01,y
	XBA
	LDA.w DATA_00A47F,y
	REP.b #$10			; XY->16
	TAY
CODE_00A4A0:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y			; Optimization: The way this is handled means that all 3 palette tables must be in the $000000-$001FFF range.
	BEQ.b CODE_00A4CF
	STX.w DMA[$02].SourceBank	; A Address Bank
	STA.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	STA.b !RAM_SMW_Misc_ScratchRAM03
	STZ.w DMA[$02].SizeHi		; Number Bytes to Transfer (High Byte) (DMA)
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.w !REGISTER_CGRAMAddress	; Address for CG-RAM Write
	REP.b #$20			; A->16
	LDA.w #((!REGISTER_WriteToCGRAMPort&$0000FF)<<8)+$00
	STA.w DMA[$02].Parameters	; Parameters for DMA Transfer
	INY
	TYA
	STA.w DMA[$02].SourceLo		; A Address (Low Byte)
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	TAY
	SEP.b #$20			; A->8
	LDA.b #$04
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	BRA.b CODE_00A4A0

CODE_00A4CF:
	SEP.b #$10			; XY->8
	JSR.w CODE_00AE47
	LDA.w !RAM_SMW_Palettes_PaletteUploadTableIndex
	BNE.b CODE_00A4DF
	STZ.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex
	STZ.w !RAM_SMW_Palettes_DynamicPaletteBytesToUpload
CODE_00A4DF:
	STZ.w !RAM_SMW_Palettes_PaletteUploadTableIndex
Return00A4E2:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_UpdatePaletteFromIndexedTable(Address)
namespace SMW_UpdatePaletteFromIndexedTable
%InsertMacroAtXPosition(<Address>)

DATA_00AE41:
	db $00,$05,$0A

DATA_00AE44:
	db $20,$40,$80

CODE_00AE47:
	LDX.b #$02
CODE_00AE49:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Palettes_BackgroundColorLo
	LDY.w DATA_00AE41,x
CODE_00AE51:
	DEY
	BMI.b CODE_00AE57
	LSR
	BRA.b CODE_00AE51

CODE_00AE57:
	SEP.b #$20			; A->8
	AND.b #$1F
	ORA.w DATA_00AE44,x
	STA.w !REGISTER_FixedColorData
	DEX
	BPL.b CODE_00AE49
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UploadOverworldAnimations(Address)
namespace SMW_UploadOverworldAnimations
%InsertMacroAtXPosition(<Address>)

Main:
#LM240Hijack_UploadOverworldExAnimationData:
	REP.b #$10							;\ LM: Hijacks this location if the overworld ExAnimation feature is used (2.40+)
	LDA.b #$80							;| This routine is for uploading the animation data to VRAM.
	STA.w !REGISTER_VRAMAddressIncrementValue			;/
	LDY.w #!VRAM_SMW_Layer1GFXVRAMLocation+$0750
	STY.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDY.w #((!REGISTER_WriteToVRAMPortLo&$0000FF)<<8)+$01
	STY.w DMA[$02].Parameters	; Parameters for DMA Transfer
	LDY.w #!RAM_SMW_Graphics_DecompressedOverworldGFX
	STY.w DMA[$02].SourceLo		; A Address (Low Byte)
	STZ.w DMA[$02].SourceBank	; A Address Bank
	LDY.w #$0160
	STY.w DMA[$02].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	LDA.b #$04
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	SEP.b #$10			; XY->8
	LDA.w !RAM_SMW_Pointer_CurrentOverworldProcess
	CMP.b #$0A
	BEQ.b SMW_UpdatePaletteFromIndexedTable_Return00A4E2
	LDA.b #!CGRAM_SMW_YellowLevelTile
	JSR.w SMW_UploadLevelAnimations_YellowFlash
	LDA.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #!CGRAM_SMW_RedLevelTile
	JMP.w SMW_UploadLevelAnimations_RedFlash
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UploadOverworldLayer1And2Tilemaps(Address)
namespace SMW_UploadOverworldLayer1And2Tilemaps
%InsertMacroAtXPosition(<Address>)

DATA_00A521:
	db $00,$04,$08,$0C

DATA_00A525:
	db $00,$08,$10,$18

Main:
	LDA.b #$80
	STA.w !REGISTER_VRAMAddressIncrementValue
	STZ.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer2TilemapVRAMLocation>>8
	CLC
	ADC.w DATA_00A521,y
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_00A53C:
	LDA.w PARAMS_00A586,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_00A53C
	LDA.w !RAM_SMW_Player_CurrentCharacterX4Lo
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	BEQ.b NotOnMainMap					; Note: !Define_SMW_Overworld_MainMap
	LDA.b #$60
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SourceHi		; A Address (High Byte)
NotOnMainMap:
	LDA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SourceHi		; A Address (High Byte)
	CLC
	ADC.w DATA_00A525,y
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SourceHi		; A Address (High Byte)
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	LDA.b #$80
	STA.w !REGISTER_VRAMAddressIncrementValue
	STZ.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer1TilemapVRAMLocation>>8
	CLC
	ADC.w DATA_00A521,y
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_00A577:
	LDA.w PARAMS_00A58D,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_00A577
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	RTS

PARAMS_00A586:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Overworld_Layer2Tiles

	dw $0800

PARAMS_00A58D:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0E)

	dw $0800
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_LoadStripeImage(Address)
namespace SMW_LoadStripeImage
%InsertMacroAtXPosition(<Address>)

if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
; JSL wrapper for the stripe image uploader (pointer lies in $12), which can
; be found at $0085D2. Because it upload tiles, it must run in either f- or
; v-blank (e.g. in NMI).
Main:
	PHB				;! This is not used in the J version:
	PHK				;! - Used to change enemy names in the credits after
	PLB				;!   special world is beaten in English verisons.
	JSR.w Sub			;! - Used to clear layer 1/2 tilemaps before every
	PLB				;!   level load in the E1 version.
	RTL				;!
endif

StripeImagePtrs:
	base $000000
; Stripe image pointer table. Each 24-bit pointer here corresponds to a
; value of $12, but only multiples of 3 are used (the first pointer is for
; value $00, the second is for value $03, the third for $06, etc.).
.Variable:			dl SMW_StripeImageUploadTable[$00].LowByte				; $00
#LM000Hijack_CustomTitleScreen:										;
.TitleScreen:			dl SMW_GameMode04_PrepareTitleScreen_TitlescreenLayer3			; $03
.OverworldBorder:		dl SMW_GameMode0C_LoadOverworld_OverworldBorderLayer3			; $06
.RemoveTextBox:			dl SMW_DisplayMessage_RemoveTextBox					; $09
.ContinueEndText:		dl SMW_ContinueEndText_Main						; $0C
.CookieMountainCutsceneBG:	dl SMW_Backgrounds_CastleDestruction_CookieMountain			; $0F
.XPlayerGameText		dl SMW_XPlayerGameText_Main						; $12
.ShowScrollArrows		dl SMW_GameMode0E_ShowOverworld_OverworldScrollArrowsImage		; $15
.RemoveScrollArrows		dl SMW_GameMode0E_ShowOverworld_RemoveOverworldScrollArrowsImage	; $18
.CloseOverworldPrompt		dl SMW_OverworldPrompt02_ExpandPromptWindow_ClearPromptWindowImage	; $1B
.SaveMenuText			dl SMW_SaveMenuText_Main						; $1E
#LM000Hijack_CustomCastleDestructionText:								;\ LM: Edit Boss Sequence Text...
.CastleDestructionText:											;| Lunar Magic will modify these pointers to point to the extended area.
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0							;| Otherwise, there wouldn't be enough room to use all 56 lines.
				dl SMW_CastleDestructionText_BlankLine					;| $21
				dl SMW_CastleDestructionText_Iggy_Line7					;| $24
				dl SMW_CastleDestructionText_Iggy_Line6					;| $27
				dl SMW_CastleDestructionText_Iggy_Line5					;| $2A
endif													;|
				dl SMW_CastleDestructionText_Iggy_Line4					;| $2D
				dl SMW_CastleDestructionText_Iggy_Line3					;| $30
				dl SMW_CastleDestructionText_Iggy_Line2					;| $33
				dl SMW_CastleDestructionText_Iggy_Line1					;| $36
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0							;|
				dl SMW_CastleDestructionText_Morton_Line8				;| $39
				dl SMW_CastleDestructionText_Morton_Line7				;| $3C
				dl SMW_CastleDestructionText_Morton_Line6				;| $3F
				dl SMW_CastleDestructionText_Morton_Line5				;| $42
endif													;|
				dl SMW_CastleDestructionText_Morton_Line4				;| $45
				dl SMW_CastleDestructionText_Morton_Line3				;| $48
				dl SMW_CastleDestructionText_Morton_Line2				;| $4B
				dl SMW_CastleDestructionText_Morton_Line1				;| $4E
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0							;|
				dl SMW_CastleDestructionText_BlankLine					;| $51
				dl SMW_CastleDestructionText_Lemmy_Line7				;| $54
				dl SMW_CastleDestructionText_Lemmy_Line6				;| $57
				dl SMW_CastleDestructionText_Lemmy_Line5				;| $5A
endif													;|
				dl SMW_CastleDestructionText_Lemmy_Line4				;| $5D
				dl SMW_CastleDestructionText_Lemmy_Line3				;| $60
				dl SMW_CastleDestructionText_Lemmy_Line2				;| $63
				dl SMW_CastleDestructionText_Lemmy_Line1				;| $66
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0							;|
				dl SMW_CastleDestructionText_Ludwig_Line8				;| $69
				dl SMW_CastleDestructionText_Ludwig_Line7				;| $6C
				dl SMW_CastleDestructionText_Ludwig_Line6				;| $6F
				dl SMW_CastleDestructionText_Ludwig_Line5				;| $72
endif													;|
				dl SMW_CastleDestructionText_Ludwig_Line4				;| $75
				dl SMW_CastleDestructionText_Ludwig_Line3				;| $78
				dl SMW_CastleDestructionText_Ludwig_Line2				;| $7B
				dl SMW_CastleDestructionText_Ludwig_Line1				;| $7E
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0							;|
				dl SMW_CastleDestructionText_BlankLine					;| $81
				dl SMW_CastleDestructionText_Roy_Line7					;| $84
				dl SMW_CastleDestructionText_Roy_Line6					;| $87
				dl SMW_CastleDestructionText_Roy_Line5					;| $8A
endif													;|
				dl SMW_CastleDestructionText_Roy_Line4					;| $8D
				dl SMW_CastleDestructionText_Roy_Line3					;| $90
				dl SMW_CastleDestructionText_Roy_Line2					;| $93
				dl SMW_CastleDestructionText_Roy_Line1					;| $96
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0							;|
				dl SMW_CastleDestructionText_Wendy_Line8				;| $99
				dl SMW_CastleDestructionText_Wendy_Line7				;| $9C
				dl SMW_CastleDestructionText_Wendy_Line6				;| $9F
				dl SMW_CastleDestructionText_Wendy_Line5				;| $A2
endif													;|
				dl SMW_CastleDestructionText_Wendy_Line4				;| $A5
				dl SMW_CastleDestructionText_Wendy_Line3				;| $A8
				dl SMW_CastleDestructionText_Wendy_Line2				;| $AB
				dl SMW_CastleDestructionText_Wendy_Line1				;| $AE
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0							;|
				dl SMW_CastleDestructionText_Larry_Line8				;| $B1
				dl SMW_CastleDestructionText_Larry_Line7				;| $B4
				dl SMW_CastleDestructionText_Larry_Line6				;| $B7
				dl SMW_CastleDestructionText_Larry_Line5				;| $BA
endif													;|
				dl SMW_CastleDestructionText_Larry_Line4				;| $BD
				dl SMW_CastleDestructionText_Larry_Line3				;| $C0
				dl SMW_CastleDestructionText_Larry_Line2				;| $C3
				dl SMW_CastleDestructionText_Larry_Line1				;/ $C6
.CaveCutsceneBG:		dl SMW_Backgrounds_CastleDestruction_Cave				; $C9
.ChocolatIslandCutsceneBG:	dl SMW_Backgrounds_CastleDestruction_ChocolateIsland			; $CC
.CutsceneCastle:		dl SMW_Backgrounds_CastleDestruction_Castle				; $CF
.CutsceneBorder:		dl SMW_GameMode19_Cutscene_CastleDestructionBorder			; $D2
.TheEndText:			dl SMW_TheEndScreenText_Main						; $D5
.CreditsEnemyNames:		dl SMW_CreditsEnemyNames_Screen01					; $D8
				dl SMW_CreditsEnemyNames_Screen02					; $DB
				dl SMW_CreditsEnemyNames_Screen03					; $DE
				dl SMW_CreditsEnemyNames_Screen04					; $E1
				dl SMW_CreditsEnemyNames_Screen05					; $E4
				dl SMW_CreditsEnemyNames_Screen06					; $E7
				dl SMW_CreditsEnemyNames_Screen07					; $EA
				dl SMW_CreditsEnemyNames_Screen08					; $ED
				dl SMW_CreditsEnemyNames_Screen09					; $F0
				dl SMW_CreditsEnemyNames_Screen10					; $F3
				dl SMW_CreditsEnemyNames_Screen11					; $F6
				dl SMW_CreditsEnemyNames_Screen12					; $F9
				dl SMW_CreditsEnemyNames_Screen13					; $FC
.OverworldCutsceneBG:		dl SMW_Backgrounds_CastleDestruction_Overworld				; $FF
	base off

; Subroutine which uploads the stripe image pointed by $12 to VRAM. The
; pointer is loaded from the table at $0084D0, and then the routine at
; $00871E is called. Afterwards, if $12 is #$00, the stripe image length at
; $7F837B is set to 0 and the terminator $FF is written to the beginning of
; $7F837D. In any case, $12 is reset to 0 before returning. To call this
; routine from outside bank 0 you can JSL to the wrapper at $0084C8. This
; should only be done during a blank period (usually NMI).
Sub:
	LDY.b !RAM_SMW_Graphics_StripeImageToUpload	; 12 = Image loader
	LDA.w StripeImagePtrs,y		; \
	STA.b !RAM_SMW_Misc_ScratchRAM00	;  |
	LDA.w StripeImagePtrs+$01,y	;  |Load pointer
	STA.b !RAM_SMW_Misc_ScratchRAM01	;  |
	LDA.w StripeImagePtrs+$02,y	;  |
	STA.b !RAM_SMW_Misc_ScratchRAM02	; /
	JSR.w UploadToVRAM
	LDA.b !RAM_SMW_Graphics_StripeImageToUpload
	BNE.b CODE_0085F7
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexHi
	DEC
	STA.l SMW_StripeImageUploadTable[$00].LowByte
CODE_0085F7:
	STZ.b !RAM_SMW_Graphics_StripeImageToUpload	; Do not reload the same thing next frame
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_LoadStripeImage(Address)				; Optimization: This routine could be improved. Look at how the equivalent routine is handled in SMAS.
namespace SMW_LoadStripeImage
%InsertMacroAtXPosition(<Address>)

; Stripe Image Uploader. Uses $00-$02 as a 24-bit pointer to tile data. Must
; be run during a blank, usually NMI. To call from a custom routine, do
; this: - Store stripe image pointer (24-bit) to $00-$02 - Push 24-bit
; return address (bank -> mid -> lo) - PHB : LDA #$00 : PHA : PLB - PEA
; $84CD - JSL $00871E
UploadToVRAM:
	REP.b #$10			; XY->16
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SourceBank	; A Address Bank
	LDY.w #$0000			; Set index to 0
CODE_008726:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	;\ Branch if bit 7 isn't set (i.e. end of data).
	BPL.b CODE_00872D		;/
	SEP.b #$30			; AXY->8
	RTS

CODE_00872D:
	STA.b !RAM_SMW_Misc_ScratchRAM04	;\
	INY				;|
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM03	;| $03/$04 = VRAM destination
	INY				;| $07 = direction (0 = horz, 1 = vert)
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	;|
	STZ.b !RAM_SMW_Misc_ScratchRAM07	;|
	ASL				;|
	ROL.b !RAM_SMW_Misc_ScratchRAM07	;/
	LDA.b #!REGISTER_WriteToVRAMPortLo	;\ Set register to $2118.
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Destination	;/
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	; Re-read line header byte 3
	AND.b #$40			; \
	LSR				;  |
	LSR				;  |Store RLE bit << 3 in $05
	LSR				;  |
	STA.b !RAM_SMW_Misc_ScratchRAM05	; /
	STZ.b !RAM_SMW_Misc_ScratchRAM06
	ORA.b #$01
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters	; Parameters for DMA Transfer
#LM170Hijack_VRAMRearrangement3:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM03				;\ Note: Layer GFX locations must be hardcoded due to this routine.
	STA.w !REGISTER_VRAMAddressLo					;/
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	XBA
	AND.w #$3FFF
	TAX
	INX
	INY
	INY
	TYA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SourceLo		; A Address (Low Byte)
	STX.w DMA[!Define_SMW_TilemapUploadDMAChannel].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	LDA.b !RAM_SMW_Misc_ScratchRAM05	;\
	BEQ.b CODE_008795		;|
	SEP.b #$20			;| A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM07	;|
	STA.w !REGISTER_VRAMAddressIncrementValue	;|
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			;|
	STA.w !REGISTER_DMAEnable	;|
	LDA.b #!REGISTER_WriteToVRAMPortHi	;|
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Destination	;| Set up RLE if applicable.
	REP.b #$21			;| A->16, CLC
	LDA.b !RAM_SMW_Misc_ScratchRAM03	;|
	STA.w !REGISTER_VRAMAddressLo	;|
	TYA				;|
	ADC.b !RAM_SMW_Misc_ScratchRAM00	;|
	INC				;|
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SourceLo		;|
	STX.w DMA[!Define_SMW_TilemapUploadDMAChannel].SizeLo		;/
	LDX.w #$0002
CODE_008795:
	STX.b !RAM_SMW_Misc_ScratchRAM03
	TYA
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	TAY
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM07	;\
	ORA.b #$80			;| Set direction.
	STA.w !REGISTER_VRAMAddressIncrementValue	;/
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			;\ Enable DMA on channel 1.
	STA.w !REGISTER_DMAEnable	;/
	JMP.w CODE_008726
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_UploadLevelLayer1And2Tilemaps(Address)
namespace SMW_UploadLevelLayer1And2Tilemaps
%InsertMacroAtXPosition(<Address>)

; This routine is the DMA routine in charge of updating layers one and two
; as needed. This is controlled by the addresses $1BE4 and $1CE6 when they
; are a non-zero value.
Main:
	SEP.b #$30			; AXY->8
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo	;\
	BNE.b ModifyLayer1		;| If $1BE4 is non-zero, update Layer 1. Else, skip to Layer 2.
	JMP.w DoneUpdatingLayer1	;/

ModifyLayer1:
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	;\ Need to update Layer 1.
	AND.b #$01			;| Jump down if in a vertical level.
	BEQ.b HorizontalLayer1Level	;|
	JMP.w VerticalLayer1Leve1	;/

HorizontalLayer1Level:
	LDY.b #$81			; \ Set "VRAM Address Increment Value" to x81
	STY.w !REGISTER_VRAMAddressIncrementValue	; /  ; VRAM Address Increment Value
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_0087D3:
	LDA.w PARAMS_008A16,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_0087D3
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			; \ Enable DMA channel 1
	STA.w !REGISTER_DMAEnable	; /  ; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	CLC
	ADC.b #$08
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_0087F5:
	LDA.w PARAMS_008A1D,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_0087F5
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; \ Enable DMA channel 1 ; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue	; /  ; VRAM Address Increment Value
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	INC
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008815:
	LDA.w PARAMS_008A24,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008815
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			; \ Enable DMA channel 1
	STA.w !REGISTER_DMAEnable	; /  ; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	INC
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	CLC
	ADC.b #$08
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008838:
	LDA.w PARAMS_008A2B,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008838
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			; \ Enable DMA channel 1
	STA.w !REGISTER_DMAEnable	; /  ; Regular DMA Channel Enable
	JMP.w DoneUpdatingLayer1	; Done with Layer 1, skip down to handle Layer 2.

VerticalLayer1Leve1:
	LDY.b #$80
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_00885C:
	LDA.w PARAMS_008A16,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_00885C
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	CLC
	ADC.b #$04
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_00887E:
	LDA.w PARAMS_008A1D,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_00887E
	LDA.b #$40
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	CLC
	ADC.b #$20
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_0088A5:
	LDA.w PARAMS_008A24,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_0088A5
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressHi
	CLC
	ADC.b #$20
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo
	CLC
	ADC.b #$04
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_0088CA:
	LDA.w PARAMS_008A2B,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_0088CA
	LDA.b #$40
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable

DoneUpdatingLayer1:
	LDA.b #$00			;\ Clear update flag for Layer 1.
	STA.w !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo	;/
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo	;\ If $1CE6 is non-zero, update Layer 2.
	BNE.b ModifyLayer2		;/
	JMP.w DoneUpdatingLayer2	; Else, return.

ModifyLayer2:
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	;\ Need to update Layer 2.
	AND.b #$02			;| Jump down if in a vertical level.
	BEQ.b HorizontalLayer2Level	;|
	JMP.w VerticalLayer2Leve1	;/

HorizontalLayer2Level:
	LDY.b #$81
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008906:
	LDA.w PARAMS_008A32,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008906
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			;\
	STA.w !REGISTER_DMAEnable	;/Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	CLC
	ADC.b #$08
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008928:
	LDA.w PARAMS_008A39,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008928
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	INC
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008948:
	LDA.w PARAMS_008A40,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008948
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	INC
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	CLC
	ADC.b #$08
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_00896B:
	LDA.w PARAMS_008A47,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_00896B
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	JMP.w DoneUpdatingLayer2	; Done with Layer 2; return.

VerticalLayer2Leve1:
	LDY.b #$80
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_00898F:
	LDA.w PARAMS_008A32,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_00898F
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	CLC
	ADC.b #$04
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_0089B1:
	LDA.w PARAMS_008A39,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_0089B1
	LDA.b #$40
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	CLC
	ADC.b #$20
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_0089D8:
	LDA.w PARAMS_008A40,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_0089D8
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	STY.w !REGISTER_VRAMAddressIncrementValue
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressHi
	CLC
	ADC.b #$20
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo
	CLC
	ADC.b #$04
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_0089FD:
	LDA.w PARAMS_008A47,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_0089FD
	LDA.b #$40
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].SizeLo		; Number Bytes to Transfer (Low Byte) (DMA)
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Regular DMA Channel Enable

DoneUpdatingLayer2:
	LDA.b #$00							;\ Optimization: STZ?
	STA.w !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo			;/
#SA1Pack_Bank00RTL:
	RTL

PARAMS_008A16:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Blocks_Layer1TilesToUploadBuffer
	dw $0040

PARAMS_008A1D:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Blocks_Layer1TilesToUploadBuffer+$40
	dw $002C

PARAMS_008A24:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Blocks_Layer1TilesToUploadBuffer+$80
	dw $0040

PARAMS_008A2B:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Blocks_Layer1TilesToUploadBuffer+$C0
	dw $002C

PARAMS_008A32:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Blocks_Layer2TilesToUploadBuffer
	dw $0040

PARAMS_008A39:
	db $01,!REGISTER_WriteToVRAMPortLo

	dl !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$40
#LM170Hijack_VRAMRearrangement4:
	dw $002C

PARAMS_008A40:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$80
	dw $0040

PARAMS_008A47:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Blocks_Layer2TilesToUploadBuffer+$C0
#LM170Hijack_VRAMRearrangement5:
	dw $002C
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_IRQRoutine(Address)
namespace SMW_IRQRoutine
%InsertMacroAtXPosition(<Address>)

; Note: Don't use FastROM addressing on this routine! It could mess up time critical code.

Main:
if ver_is_smasw(!Define_Global_ROMToAssemble) == 0
	; SMW's IRQ routine.
	SEI				; Set Interrupt flag so routine can start
if defined("Define_SMW_SA1")
	NOP #4
else
	PHP					; Optimization: Same deal about PHP/PLP as with the NMI routine above.
	REP.b #$30
	PHA
endif
	PHX
	PHY
	PHB
	PHK
	PLB
	SEP.b #$30			; AXY->8
endif
	LDA.w !REGISTER_IRQEnable	; Read the IRQ register, 'unapply' the interrupt
	BPL.b CODE_0083B2		; If "Timer IRQ" is clear, skip the next code block
	LDA.b #$81
	LDY.w !RAM_SMW_Misc_NMIToUseFlag
	BMI.b CODE_0083BA		; If Bit 7 (negative flag) is set, branch to a different IRQ mode
IRQNMIEnding:
	STA.w !REGISTER_IRQNMIAndJoypadEnableFlags	; Enable NMI Interrupt and Automatic Joypad reading
	LDY.b #$1F
SA1Pack_RemoveJSRToWaitForHBlank2:
if defined("Define_SMW_SA1")
	NOP #3
else
	JSR.w SMW_WaitForHBlank_Entry2
endif
	LDA.b !RAM_SMW_Mirror_Layer3XPosLo	;\ Adjust scroll settings for layer 3
	STA.w !REGISTER_BG3HorizScrollOffset	;|
	LDA.b !RAM_SMW_Mirror_Layer3XPosHi	;|
	STA.w !REGISTER_BG3HorizScrollOffset	;|
	LDA.b !RAM_SMW_Mirror_Layer3YPosLo	;|
	STA.w !REGISTER_BG3VertScrollOffset	;|
	LDA.b !RAM_SMW_Mirror_Layer3YPosHi	;|
	STA.w !REGISTER_BG3VertScrollOffset	;/
CODE_0083A8:
	LDA.b !RAM_SMW_Mirror_BGModeAndTileSizeSetting	;\ Set the layer BG sizes, L3 priority, and BG mode
	STA.w !REGISTER_BGModeAndTileSizeSetting	;/ (Effectively, this is the screen mode)
	LDA.b !RAM_SMW_Mirror_ColorMathSelectAndEnable	;\ Write CGADSUB
	STA.w !REGISTER_ColorMathSelectAndEnable	;/
CODE_0083B2:
if ver_is_smasw(!Define_Global_ROMToAssemble)
	RTL
else
#SA1Pack_EndOfSNESIRQ:
if defined("Define_SMW_SA1")
	JML.l snes_nmi_end2
else
	REP.b #$30			; AXY->16
	PLB				;\ Pull everything back
	PLY				;|
endif
	PLX				;|
	PLA				;|
	PLP				;/
	RTI				; And Return
endif

CODE_0083BA:
	BIT.w !RAM_SMW_Misc_NMIToUseFlag	; Get bit 6 of $0D9B
	BVC.b CODE_0083E3		; If clear, skip the next code section
	LDY.b !RAM_SMW_Flag_IRQToUse	;\ Skip if $11 = 0
	BEQ.b CODE_0083D0		;/
	STA.w !REGISTER_IRQNMIAndJoypadEnableFlags	; #$81 -> NMI / Controller Enable reg
	LDY.b #$14
#SA1Pack_RemoveJSRToWaitForHBlank3:
if defined("Define_SMW_SA1")
	NOP #3
else
	JSR.w SMW_WaitForHBlank_Entry2
endif
	JSR.w SMW_SetMode7PPUPointersAndLayer1Scroll_Main
	BRA.b CODE_0083A8

CODE_0083D0:
	INC.b !RAM_SMW_Flag_IRQToUse	; $11++
	LDA.w !REGISTER_IRQEnable	;\ Set up the IRQ routine for layer 3
	LDA.b #!Define_SMW_LudwigMortonRoyRoomMode7ScanlineEnd	;|\ <- Scanline where floor starts in Morton/Roy/Ludwig battles
	SEC				;|| Vertical Counter trigger at 174 - $1888
	SBC.w !RAM_SMW_ShakingLayer1DispYLo	;|/ Oddly enough, $1888 seems to be 16-bit, but the
	STA.w !REGISTER_VCountTimerLo	;| Store to Vertical Counter Timer
	STZ.w !REGISTER_VCountTimerHi	;/ Make the high byte of said timer 0
	LDA.b #$A1			; A = NMI enable, V count enable, joypad automatic read enable, H count disable
CODE_0083E3:
	LDY.w !RAM_SMW_Timer_EndLevel	; if $1493 = 0 skip down
	BEQ.b SMW_Mode7Layer1Scroll_Main
	LDY.w !RAM_SMW_Timer_LevelEndFade	;\ If $1495 is <#$40
	CPY.b #$40			;|
	BCC.b SMW_Mode7Layer1Scroll_Main	;/ Skip down
	LDA.b #$81
	BRA.b IRQNMIEnding		; Jump up to IRQNMIEnding
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_Mode7Layer1Scroll(Address)
namespace SMW_Mode7Layer1Scroll
%InsertMacroAtXPosition(<Address>)

Main:
	STA.w !REGISTER_IRQNMIAndJoypadEnableFlags	; A -> NMI/Joypad Auto-Read/HV-Count Control Register ; NMI, V/H Count, and Joypad Enable
#SA1Pack_RemoveJSRToWaitForHBlank1:
if defined("Define_SMW_SA1")
	NOP #3
else
	JSR.w SMW_WaitForHBlank_Main					; Note: This routine is called during VBlank and IRQ. This JSR.w SMW_is useless if in the former.
endif
	NOP #2
	LDA.b #!BGModeAndTileSizeSetting_Mode07Enable	; \Write Screen register
	STA.w !REGISTER_BGModeAndTileSizeSetting	; / ; BG Mode and Tile Size Setting
	LDA.b !RAM_SMW_Mirror_M7XPosLo	; \ Write L1 Horizontal scroll
	STA.w !REGISTER_BG1HorizScrollOffset	;  | ; BG 1 Horizontal Scroll Offset
	LDA.b !RAM_SMW_Mirror_M7XPosHi	;  |
	STA.w !REGISTER_BG1HorizScrollOffset	; /  ; BG 1 Horizontal Scroll Offset
	LDA.b !RAM_SMW_Mirror_M7YPosLo	; \ Write L1 Vertical Scroll
	STA.w !REGISTER_BG1VertScrollOffset	;  | ; BG 1 Vertical Scroll Offset
	LDA.b !RAM_SMW_Mirror_M7YPosHi	;  |
	STA.w !REGISTER_BG1VertScrollOffset	; /  ; BG 1 Vertical Scroll Offset
	BRA.b SMW_IRQRoutine_CODE_0083B2	; And exit IRQ
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SetMode7PPUPointersAndLayer1Scroll(Address)
namespace SMW_SetMode7PPUPointersAndLayer1Scroll
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #!Define_SMW_Layer1TilemapSize_Mode7|(!Define_SMW_Layer1TilemapVRAMLocation_Mode7<<2)	; \
	STA.w !REGISTER_BG1AddressAndSize	; /Write L1 GFX source address ; BG 1 Address and Size
	LDA.b #!Define_SMW_Layer1GFXVRAMLocation_Mode7|(!Define_SMW_Layer2GFXVRAMLocation<<4)	; \Write L1/L2 Tilemap address
	STA.w !REGISTER_BG1And2TileDataDesignation	; / ; BG 1 & 2 Tile Data Designation
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	; \ Write L1 Horizontal scroll
	STA.w !REGISTER_BG1HorizScrollOffset	;  | ; BG 1 Horizontal Scroll Offset
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi	;  |
	STA.w !REGISTER_BG1HorizScrollOffset	; / ; BG 1 Horizontal Scroll Offset
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	; \ $1C + $1888 -> L1 Vert scroll
	CLC				;  |$1888 = Some sort of vertioffset
	ADC.w !RAM_SMW_ShakingLayer1DispYLo	;  |
	STA.w !REGISTER_BG1VertScrollOffset	; / ; BG 1 Vertical Scroll Offset
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	; \Other half of L1 vert scroll
	STA.w !REGISTER_BG1VertScrollOffset	; / ; BG 1 Vertical Scroll Offset
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_WaitForHBlank(Address)
namespace SMW_WaitForHBlank
%InsertMacroAtXPosition(<Address>)

Main:
FlagSet:
	LDY.b #$20			; <<- Could this be just to waste time?
Entry2:
	BIT.w !REGISTER_HVBlankFlagsAndJoypadStatus	;| If in one already, wait for it to end.
	BVS.b FlagSet			; if in H-Blank, make Y #$20 and try again
FlagClear:
	BIT.w !REGISTER_HVBlankFlagsAndJoypadStatus	;\ Wait until the next H-blank fires.
	BVC.b FlagClear			;/
WasteTimeLoop:
	DEY				;\ Wait until we are far enough into the blank.
	BNE.b WasteTimeLoop		;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode14_InLevel(Address)
namespace SMW_GameMode14_InLevel
%InsertMacroAtXPosition(<Address>)

#LM300Hijack_Unknown00A1CE:							;\ LM: Converts these to be 16-bit values (3.00+)
GrndShakeDispYLo:								;|
	db $FE,$00,$02,$00							;|
										;|
GrndShakeDispYHi:								;|
	db $FF,$00,$00,$00							;/

DATA_00A1D6:
	db $12,$22,$12,$02

Main:
#LM000Hijack_RecordTitleScreenDemo1:
	LDA.w !RAM_SMW_Misc_DisplayMessage	;\  if no message box running, don't run this next routine
	BEQ.b NoActiveMessage		;/
	JSL.l SMW_DisplayMessage_Main	; Run Message box routine
	; Change to 0xEA to keep the game running when a message box is on the
	; screen.
	RTS

NoActiveMessage:
	LDA.w !RAM_SMW_Flag_ActiveBonusGame					;\ Optimization: Wouldn't this have made more sense to be a state for Mario to be in ($7E0071)?
	BEQ.b CODE_00A200							;|
	LDA.w !RAM_SMW_Timer_BonusGameEnd					;|
	BEQ.b CODE_00A200							;|
if ver_is_pal(!Define_Global_ROMToAssemble)	;|
	CMP.b #$48								;|
else										;|
	CMP.b #$40								;|
endif										;|
	BCS.b CODE_00A200							;|
	JSR.w SMW_DamagePlayer_DisableButtons					;|
if ver_is_pal(!Define_Global_ROMToAssemble)	;|
	CMP.b #$24								;|
else										;|
	CMP.b #$1C								;|
endif										;|
	BCS.b CODE_00A200							;|
	JSR.w SMW_PlayerState00_Normal_SetMarioPeaceImg				;|
	LDA.b #!Define_SMW_PlayerState0D_DoAbsolutelyNothing			;|
	STA.b !RAM_SMW_Player_CurrentState					;|
CODE_00A200:									;/
	ORA.b !RAM_SMW_Player_CurrentState	;\ if normal exit time, and Mario's animation is 00,
	ORA.w !RAM_SMW_Timer_EndLevel	;|
	BEQ.b CODE_00A211		;/
	LDA.b #!Joypad_DPadD>>8		;\ mario is holding down
	TRB.b !RAM_SMW_IO_ControllerHold1	;/
	LDA.b #!Joypad_X|(!Joypad_Y>>8)	;\
	TRB.b !RAM_SMW_IO_ControllerPress1	;| and X
	TRB.b !RAM_SMW_IO_ControllerPress2	;/
CODE_00A211:
	LDA.w !RAM_SMW_Timer_PreventPause	;\ if you can pause the game,
	BEQ.b CODE_00A21B		;/
	DEC.w !RAM_SMW_Timer_PreventPause	;\Otherwise decrement it and continue LIKE all those dittos above
	BRA.b CODE_00A242		;/

CODE_00A21B:
	LDA.b !RAM_SMW_IO_ControllerPress1
	AND.b #!Joypad_Start>>8
	; Change from F0 (BEQ) to 80 (BRA) to disable pausing
	BEQ.b CODE_00A242
	LDA.w !RAM_SMW_Timer_EndLevel	;\ if the exit is not regular exit, ^^
	BNE.b CODE_00A242		;/
	LDA.b !RAM_SMW_Player_CurrentState	;\
	CMP.b #!Define_SMW_PlayerState09_Death	;| if some of the technical animations, like level ending, etc
	BCS.b CODE_00A242		;/ continue like those ^^
	LDA.b #$3C			;\ disable pressing pause
	STA.w !RAM_SMW_Timer_PreventPause	;/
	LDY.b #!Define_SMW_Sound1DF9_UnPause
	LDA.w !RAM_SMW_Flag_Pause	;\
	EOR.b #$01			;| and invert the pause flag
	STA.w !RAM_SMW_Flag_Pause	;/
	BEQ.b CODE_00A23F		; if it's now 00, go
	LDY.b #!Define_SMW_Sound1DF9_Pause
CODE_00A23F:
	STY.w !RAM_SMW_IO_SoundCh1
CODE_00A242:
if !SMW_LevelCode_MainWanted == !TRUE
	; The same five bytes as the read and its branch. The stub calls this
	; level's own routine where its row names one -- on a paused frame too,
	; which is where UberASM Tool runs it -- then repeats the read and JMLs
	; to whichever side the flag chose. See Config/LevelCode.asm.
	JML.l SMW_LevelCode_Main
	NOP
else
	LDA.w !RAM_SMW_Flag_Pause	;\ if the pause flag is 00,
	BEQ.b CODE_00A28A		;/
endif
LevelCodePaused:
#Debug_SlowMotion:
	BRA.b CODE_00A25B		; continue running the code
	BIT.w !RAM_SMW_IO_ControllerPress1CopyP2	; \ Unreachable
	BVS.b ADDR_00A259		; | Debug: Slow motion
	LDA.w !RAM_SMW_IO_ControllerHold1CopyP2
	BPL.b CODE_00A25B
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$0F
	BNE.b CODE_00A25B
ADDR_00A259:
	BRA.b CODE_00A28A

CODE_00A25B:
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	; Code to handle leaving the level with Start+Select. DEBUG: Change $00A268
	; to 00 to always allow leaving the level. Change $00A273 to 00 to beat the
	; level by doing that, not just leave it. Holding A or B when doing so will
	; activate the secret exit.
	LDA.b !RAM_SMW_IO_ControllerHold1	;!
	AND.b #!Joypad_Select>>8	;!
	BEQ.b Return00A289		;!
	LDY.w !RAM_SMW_Overworld_LevelNumberLo	;!
	LDA.w !RAM_SMW_Overworld_LevelTileSettings,y	;!
#Debug_BeatLevel1:
	BPL.b Return00A289		;!
	LDA.w !RAM_SMW_Misc_ExitLevelAction	;!
	BEQ.b CODE_00A270		;!
	BPL.b Return00A289		;!
CODE_00A270:
	LDA.b #$80			;!
#Debug_BeatLevel2:
	BRA.b CODE_00A27E		;!
	LDA.b #$01			;! \ Unreachable
	BIT.b !RAM_SMW_IO_ControllerHold1	;! | Debug: Beat level with Start+Select
	BPL.b ADDR_00A27B		;! |
	INC				;! /
ADDR_00A27B:
	STA.w !RAM_SMW_Flag_ActivateOverworldEvent				; Optimization: Junk
CODE_00A27E:
	STA.w !RAM_SMW_Misc_ExitLevelAction	;!
	INC.w !RAM_SMW_Overworld_CheckIfEventPassedFlag				; Optimization: Junk
	LDA.b #!Define_SMW_GameMode0B_FadeOutToOverworld	;!
	STA.w !RAM_SMW_Misc_GameMode	;!
Return00A289:
endif
	RTS				; Done!

LevelCodeReturn:
CODE_00A28A:
	LDA.w !RAM_SMW_Misc_NMIToUseFlag	;\
	BPL.b NotInMode7Level		;/ if "regular" game types and such, don't do these jumps
InMode7Frame:
	JSR.w InMode7Level
	JMP.w NotInNormalLevel							; Optimization: BRA.b?

NotInMode7Level:
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt	; Move all sprites offscreen
	JSL.l SMW_HandleStandardLevelCameraScroll_Main	;>Handle screen scrolling
	JSL.l SMW_HandleScrollSpriteAndLayer3Scrolling_Main
	JSL.l SMW_CheckIfLevelTilemapsNeedScrollUpdate_Main
#LM160Hijack_LevelExAnimations2:
	JSL.l SMW_LevelTileAnimations_Main
NotInNormalLevel:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;\
	PHA				;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;| Save the Y screen boundary to retreive later
	PHA				;/
#LM300Hijack_Unknown00A2AF:
	STZ.w !RAM_SMW_ShakingLayer1DispYLo				;\ LM: Rewrites this code for some unknown reason. (3.00+)
	STZ.w !RAM_SMW_ShakingLayer1DispYHi				;|
	LDA.w !RAM_SMW_Timer_ShakeLayer1				;|
	BEQ.b NoLayer1Shaking						;|
	DEC.w !RAM_SMW_Timer_ShakeLayer1				;|
	AND.b #$03							;|
	TAY								;|
	LDA.w GrndShakeDispYLo,y					;|
	STA.w !RAM_SMW_ShakingLayer1DispYLo				;|
	CLC								;|
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo			;|
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo			;|
	LDA.w GrndShakeDispYHi,y					;|
	STA.w !RAM_SMW_ShakingLayer1DispYHi				;|
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosHi			;|
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi			;/
NoLayer1Shaking:
	JSR.w SMW_UpdateStatusBarCounters_Main
	JSL.l SMW_PlayerGFXRt_Main	;>Mario OAM
	JSR.w SMW_UpdateCurrentPlayerPositionRAM_Main	; Update X/Y pos
	JSR.w SMW_GameMode14_InLevel_CODE_00C47E	;>Mario interaction
	JSL.l SMW_ProcessNormalSprites_Main	;>handle sprites
if defined("Define_SMW_SA1")
	JSL.l level_mode_optimize
else
	JSL.l Bank02			;>misc timers?
endif
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi	;| Return layers to original position
	PLA
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	JMP.w SMW_CompressOAMTileSizeBuffer_Main
namespace off
endmacro

macro ROUTINE_RT01_SMW_GameMode14_InLevel(Address)
namespace SMW_GameMode14_InLevel
%InsertMacroAtXPosition(<Address>)

; Subroutine that initializes the OAM table in Roy, Morton and Ludwig's
; rooms. It first initializes the first 100 tiles to be 16x16 (by setting
; $0420,x to #$02), then jumps in the middle of the standard OAM clear
; routine (JSL $7F812E).
CODE_0086C7:
	REP.b #$30			; AXY->16
	LDX.w #$0062
	LDA.w #$0202
CODE_0086CF:
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,x
	DEX
	DEX
	BPL.b CODE_0086CF
	SEP.b #$30			; AXY->8
	LDA.b #$F0			;\ Clear out OAM.
if defined("Define_SMW_SA1")
	JSL.l oam_clear_invoke
else
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt+$012E	;/
endif
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_GameMode14_InLevel(Address)
namespace SMW_GameMode14_InLevel
%InsertMacroAtXPosition(<Address>)

UNK_009875:
	db $01,$00,$FF,$FF,$40,$00,$C0,$01

InMode7Level:
	JSR.w SMW_ManipulateMode7Image_Main
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_009888
	JMP.w CODE_009A52

CODE_009888:
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt	; Iggy & Larry
	JSL.l CODE_03C0C6		; Draw the top of the lava and handle their platform's movement.
	RTS
namespace off
endmacro

macro ROUTINE_RT03_SMW_GameMode14_InLevel(Address)
namespace SMW_GameMode14_InLevel
%InsertMacroAtXPosition(<Address>)

UNK_009A4E:
	db $FF,$01,$18,$30

CODE_009A52:
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	LSR
	BCS.b CODE_009A6F
	JSL.l SMW_HandleStandardLevelCameraScroll_Main	; Morton, Ludwig, Roy, Reznor
	JSL.l SMW_HandleScrollSpriteAndLayer3Scrolling_Main
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBoss
	CMP.b #$04
	BEQ.b CODE_009A6F
	JSR.w CODE_0086C7		;\ Morton, Ludwig, Roy only
	JSL.l CODE_02827D		;/
	RTS

CODE_009A6F:
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt	; Bowser: just reset OAM and that's it
	RTS
namespace off
endmacro

macro ROUTINE_RT04_SMW_GameMode14_InLevel(Address)
namespace SMW_GameMode14_InLevel
%InsertMacroAtXPosition(<Address>)

UNK_00C460:
	db $80,$40,$20,$10,$08,$04,$02,$01
	db $80,$40,$20,$10,$08,$04,$02,$01

DATA_00C470:
	db $90,$00,$90,$00

DATA_00C474:
	db $04,$FC,$04,$FC

DATA_00C478:
	db $30,$33,$33,$30,$01,$00

CODE_00C47E:
if defined("Define_SMW_SA1")
	JSL.l level_mode_optimize_00C47E
	RTS
else
	STZ.b !RAM_SMW_Player_HidePlayerTileFlags
	LDA.w !RAM_SMW_UnusedRAM_GotInvincibleStarFromGoal			;\ Optimization: Unused function
endif
	BPL.b CODE_00C48C							;|
	JSL.l SMW_GivePlayerStarPower_Main					;|
	STZ.w !RAM_SMW_UnusedRAM_GotInvincibleStarFromGoal			;/
CODE_00C48C:
	LDY.w !RAM_SMW_Timer_EndLevelViaKeyhole	;\ finish this part of the code if the keyhole triggerish thing
	BEQ.b CODE_00C4BA		;/ is 00
	STY.w !RAM_SMW_Player_FreezePlayerFlag	; Otherwise freeze him for as long as it is set
	STY.b !RAM_SMW_Flag_SpritesLocked	; Lock sprites too
	LDX.w !RAM_SMW_Flag_KeyholeAnimationPhase
	LDA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	CMP.w DATA_00C470,x
	BNE.b CODE_00C4BC
	DEY
	BNE.b CODE_00C4B7
	INC.w !RAM_SMW_Flag_KeyholeAnimationPhase
	TXA
	LSR
	BCC.b CODE_00C4F8
	JSR.w SMW_ClearOutNormalSpriteSlots_Main
	LDA.b #$02
	LDY.b #$0B
	JSR.w SMW_PlayerState00_Normal_CODE_00C9FE
	LDY.b #$00
CODE_00C4B7:
	STY.w !RAM_SMW_Timer_EndLevelViaKeyhole
CODE_00C4BA:
	BRA.b CODE_00C4F8

CODE_00C4BC:
	CLC
	ADC.w DATA_00C474,x
	STA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	LDA.b #$22
	STA.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings
	LDA.b #$02
	STA.b !RAM_SMW_Mirror_BG3And4WindowMaskSettings
	LDA.w DATA_00C478,x
	STA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings
	LDA.b #$12
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings
	REP.b #$20			; A->16
	LDA.w #SMW_UpdateHDMAWindowBuffer_KeyholeHDMAData
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STZ.b !RAM_SMW_Misc_ScratchRAM06
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_NorSpr00E_Keyhole_XPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.b #$04
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr00E_Keyhole_YPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM01
	JSR.w SMW_UpdateHDMAWindowBuffer_KeyholeEntry
CODE_00C4F8:
	LDA.w !RAM_SMW_Player_FreezePlayerFlag
	BEQ.b CODE_00C500
	JMP.w CODE_00C58F

CODE_00C500:
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b CODE_00C569
	INC.b !RAM_SMW_Counter_LocalFrames
	LDX.b #$13
CODE_00C508:
	LDA.w !RAM_SMW_Timer_LevelEndFade,x
	BEQ.b CODE_00C510
	DEC.w !RAM_SMW_Timer_LevelEndFade,x
CODE_00C510:
	DEX
	BNE.b CODE_00C508
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$03
	BNE.b CODE_00C569
	LDA.w !RAM_SMW_Flag_ActiveBonusGame
	BEQ.b CODE_00C533
	LDA.w !RAM_SMW_Timer_BonusGameEnd
	CMP.b #$44
	BNE.b CODE_00C52A
	LDY.b #!Define_SMW_LevelMusic_DoneBonusGame
	STY.w !RAM_SMW_IO_MusicCh1	; / Change music
CODE_00C52A:
if ver_is_pal(!Define_Global_ROMToAssemble)
	CMP.b #$08
else
	CMP.b #$01
endif
	BNE.b CODE_00C533
	LDY.b #!Define_SMW_GameMode0B_FadeOutToOverworld
	STY.w !RAM_SMW_Misc_GameMode
CODE_00C533:
	LDY.w !RAM_SMW_Timer_BluePSwitch
	CPY.w !RAM_SMW_Timer_SilverPSwitch
	BCS.b CODE_00C53E
	LDY.w !RAM_SMW_Timer_SilverPSwitch
CODE_00C53E:
	LDA.w !RAM_SMW_Misc_MusicRegisterBackup
	BMI.b CODE_00C54F
	CPY.b #$01
	BNE.b CODE_00C54F
	LDY.w !RAM_SMW_NorSpr045_DirectionalCoins_DespawnTimer
	BNE.b CODE_00C54F
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
CODE_00C54F:
	CMP.b #$FF
	BEQ.b CODE_00C55C
if ver_is_pal(!Define_Global_ROMToAssemble)
	CPY.b #$18
else
	CPY.b #$1E
endif
	BNE.b CODE_00C55C
	LDA.b #!Define_SMW_Sound1DFC_PSwitchRunningOut	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_00C55C:
	LDX.b #$06
CODE_00C55E:
	LDA.w !RAM_SMW_UnusedRAM_7E14A8,x					;\ Optimization: Unused. These references should be increased by 3
	BEQ.b CODE_00C566							;|
	DEC.w !RAM_SMW_UnusedRAM_7E14A8,x					;/
CODE_00C566:
	DEX
	BNE.b CODE_00C55E
CODE_00C569:
	JSR.w HandlePlayerState
	LDA.b !RAM_SMW_IO_ControllerPress1
	AND.b #!Joypad_Select>>8
	; [F0] Change to [80] to make the item not drop when the player presses
	; Select.
	BEQ.b CODE_00C58F
if ver_is_pal(!Define_Global_ROMToAssemble) == 0
	LDA.b !RAM_SMW_IO_ControllerHold1	;!
	AND.b #!Joypad_DPadU>>8		;!
; DEBUG: Powerup select (F0 = enable)
#Debug_PowerUpSelect:
	BRA.b CODE_00C585		;! Change to BEQ to reach debug routine below
	LDA.b !RAM_SMW_Player_CurrentPowerUp	;! \ Unreachable
	INC				;! | Debug: Cycle through powerups
	CMP.b #$04			;! |
	BCC.b ADDR_00C581		;! |
	LDA.b #$00			;! |
ADDR_00C581:
	STA.b !RAM_SMW_Player_CurrentPowerUp	;! |
	BRA.b CODE_00C58F		;! /
endif

CODE_00C585:
	PHB
	LDA.b #SMW_DropReservedItem_Main>>16
	PHA
	PLB
	JSL.l SMW_DropReservedItem_Main
	PLB
CODE_00C58F:
	STZ.w !RAM_SMW_Blocks_NoteBlockBounceFlag
Return00C592:
	RTS

HandlePlayerState:
if defined("Define_SMW_SA1")
	JSL.l level_mode_mario_animation
	RTS
	db $00	; the tail of the JSL.l below, which the hijack leaves unreached
else
	LDA.b !RAM_SMW_Player_CurrentState
	JSL.l SMW_ExecutePtr_Absolute
endif

PlayerStatePtrs:
base $000000
; Pointer to Mario's animation routines. ($7E0071)
.PlayerState00_Normal:			dw SMW_PlayerState00_Normal_Main	; 0 - Reset
.PlayerState01_PowerDown:		dw SMW_PlayerState01_PowerDown_Main	; 1 - Power down
.PlayerState02_Grow:			dw SMW_PlayerState02_Grow_Main	; 2 - Mushroom power up
.PlayerState03_GotCape:			dw SMW_PlayerState03_GotCape_Main	; 3 - Cape power up
.PlayerState04_GotFlower:		dw SMW_PlayerState04_GotFlower_Main	; 4 - Flower power up
.PlayerState05_EnterHorizontalPipe:	dw SMW_PlayerState05_EnterHorizontalPipe_Main	; 5 - Door/Horizontal pipe exit
.PlayerState06_EnterVerticalPipe:	dw SMW_PlayerState06_EnterVerticalPipe_Main	; 6 - Vertical pipe exit
.PlayerState07_ShootOutOfPipe:		dw SMW_PlayerState07_ShootOutOfPipe_Main	; 7 - Shot out of diagonal pipe
.PlayerState08_WarpToYoshiWingsBonus:	dw SMW_PlayerState08_WarpToYoshiWingsBonus_Main	; 8 - Yoshi wings exit
.PlayerState09_Death:			dw SMW_PlayerState09_Death_Main	; 9 - Mario Death
.PlayerState0A_NoYoshiCutscene:		dw SMW_PlayerState0A_NoYoshiCutscene_Main	; A - Enter Castle
.PlayerState0B_RescuedPeach:		dw SMW_PlayerState0B_RescuedPeach_Main	; B - freeze forever
.PlayerState0C_CastleDestructionMoves:	dw SMW_PlayerState0C_CastleDestructionMoves_Main	; C - random movement??
.PlayerState0D_DoAbsolutelyNothing:	dw SMW_PlayerState0D_DoAbsolutelyNothing_Main	; D - freeze forever
base off
namespace off
	%SetDuplicateOrNullPointer(SMW_GameMode14_InLevel_Return00C592, SMW_PlayerState0D_DoAbsolutelyNothing_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeSaveData(Address)			; Note: This macro is not used in the arcade version.
namespace SMW_InitializeSaveData
%InsertMacroAtXPosition(<Address>)

; Initial level flags. This table is made of a pair of bytes where the first
; byte contains the translevel number and the second byte the overworld
; level settings. In an LM-modified ROM, this table is unused, with the
; initial flag data instead being loaded from a table at $05DDA0 that just
; contains one byte per translevel.
InitialLevelFlags:
	db $28,$03,$4D,$01,$52,$01,$53,$01	;! enable left/right on yoshi's house
	db $5B,$08,$5C,$02,$57,$04,$30,$01	;! enable up on star world bottom left star warp

; Initial overworld position data for Mario and Luigi, corresponding to
; addresses $1F11 through $1F26. The values are copied there on creation of
; a new save file.
InitialOWPlayerPos:
	db $01,$01			;!\ initial players submap
	dw $0002,$0002			;!\ initial players animation
	dw $0068,$0078			;!\ initial players position
	dw $0068,$0078			;!/
	dw $0006,$0007			;!\ initial players position / $10
	dw $0006,$0007			;!/

; Routine to initialize RAM for a new save file. This first clears the SRAM
; buffer at $7E1F49, then loads into it the initial level flags (using the
; table at $009EE0) and initial overworld positions for both players (using
; the table at $009EF0).
Main:
	LDX.b #!Define_SMW_Misc_SaveFileSize-$02	;!\
CODE_009F08:
	STZ.w !RAM_SMW_Overworld_SaveBuffer-$01,x	;!| Initialize all values to zero
	DEX				;!|
	BNE.b CODE_009F08		;!/
	LDX.b #$0E			;!\
CODE_009F10:
	LDY.w InitialLevelFlags,x	;!| Unlock movement directions on certain level tiles
	LDA.w InitialLevelFlags+$01,x	;!|
	STA.w !RAM_SMW_Overworld_SaveBuffer,y	;!|
#LM000Hijack_InitLevelFlags:
	DEX				;!|
	DEX
	BPL.b CODE_009F10		;!/
	LDX.b #$15			;!\
CODE_009F1F:
	LDA.w InitialOWPlayerPos,x	;!| Initialize player overworld data
	STA.w !RAM_SMW_Overworld_SaveBuffer+$6F,x	;!|
	DEX				;!|
	BPL.b CODE_009F1F		;!/
	RTS				;!
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_LoadSaveBufferData(Address)			; Optimization: Wouldn't it be better to load the save data stuff from the actual save file? That save file buffer seems like a waste of RAM.
namespace SMW_LoadSaveBufferData
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$10			; XY->16
	LDX.w #!Define_SMW_Misc_SaveFileSize-$03
Loop:
	LDA.w !RAM_SMW_Overworld_SaveBuffer,x
	STA.w !RAM_SMW_Overworld_LevelTileSettings,x
	DEX
	BPL.b Loop
	SEP.b #$10			; XY->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SpawnMountedYoshiOnLevelLoad(Address)
namespace SMW_SpawnMountedYoshiOnLevelLoad
%InsertMacroAtXPosition(<Address>)

; Used in SMW to initialize Yoshi when entering a level, or sublevel. JSLing
; to this will cause a Yoshi to spawn and Mario will be riding him, however
; the Yoshi will not transfer to sublevel or to the overworld. You must set
; $13C7 if you plan to manually JSL to this routine. Changing $00FCCE to
; 0x80 will keep Yoshi from turning blue after grabbing a pair of Yoshi
; wings.
Main:
	LDA.b #!Define_SMW_Sound1DFA_TurnOnYoshiDrum
	STA.w !RAM_SMW_IO_SoundCh2	; / Play sound effect
	LDX.b #!Define_SMW_StockMaxNormalSpriteSlot-$0B
	LDA.w !RAM_SMW_Flag_DisableBonusGameSprite
	BNE.b CODE_00FC98
	LDX.b #$05
	LDA.w !RAM_SMW_Sprites_SpriteMemorySetting
	CMP.b #$0A
	BEQ.b CODE_00FC98
	JSL.l SMW_FindFreeNormalSpriteSlot_HighPriority	; \ X = First free sprite slot, #$03 if none free
	TYX
	BPL.b CODE_00FC98
	LDX.b #!Define_SMW_StockMaxNormalSpriteSlot-$08
CODE_00FC98:
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Status = Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
if defined("Define_SMW_SA1")
	; SA-1 Pack: Regenerating Yoshi when transitioning screens.
	JSL.l YOSHI_SET2
else
	LDA.b #!Define_SMW_SpriteID_NorSpr035_Yoshi	; \ Sprite = Yoshi
	STA.b !RAM_SMW_NorSpr_SpriteID,x
endif
	LDA.b !RAM_SMW_Player_XPosLo	; \ Yoshi X position = Mario X position
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b !RAM_SMW_Player_XPosHi
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Player_YPosLo	; \ Yoshi's Y position = Mario Y position - #$10
	SEC				; | Mario Y position = Mario Y position - #$10
	SBC.b #$10
	STA.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b !RAM_SMW_Player_YPosHi
	SBC.b #$00
	STA.b !RAM_SMW_Player_YPosHi
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main	; Reset sprite tables
	LDA.b #$04
	STA.w !RAM_SMW_NorSpr035_Yoshi_DisableWaterSplashTimer,x
	LDA.w !RAM_SMW_Yoshi_CurrentYoshiColor	; \ Set Yoshi palette
	STA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,x
	LDA.w !RAM_SMW_InYoshiWingsBonusArea
	BEQ.b CODE_00FCD5
	LDA.b #$06
	STA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,x
CODE_00FCD5:
	INC.w !RAM_SMW_Player_RidingYoshiFlag
	INC.b !RAM_SMW_NorSpr035_Yoshi_CurrentState,x
	LDA.b !RAM_SMW_Player_FacingDirection
	EOR.b #$01
	STA.w !RAM_SMW_NorSpr_FacingDirection,x
	DEC.w !RAM_SMW_NorSpr035_Yoshi_SlotOfSpriteBeingEaten,x
	INX
	STX.w !RAM_SMW_Sprites_YoshiSlotIndex
	STX.w !RAM_SMW_Yoshi_StrayYoshiFlag
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_InitializeMap16Pointers(Address)
namespace SMW_InitializeMap16Pointers
%InsertMacroAtXPosition(<Address>)

DATA_00E55E:

	; Indices to the tables at $00E4B9-$00E53D and $00E632, when in any tileset
	; except 0 and 7 (used for upside-down slopes). This table is indexed by
	; Map16 tile number, for the range 16E-1D7. An index to this table is
	; stored at $82.
	db $00,$00									;\ Tiles 16E-16F
	db $00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03		;| Tiles 170-17F
	db $03,$03,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$06,$06,$06,$06		;| Tiles 180-18F
	db $06,$07,$07,$07,$07,$07,$08,$08,$08,$08,$08,$09,$09,$09,$09,$09		;| Tiles 190-19F
	db $0A,$0A,$0A,$0A,$0A,$0B,$0B,$0B,$0B,$0B,$0C,$0C,$0C,$0C,$0C,$0D		;| Tiles 1A0-1AF
	db $0D,$0D,$0D,$0D,$0E,$0F,$10,$11,$03,$03,$04,$04,$09,$09,$0A,$0A		;| Tiles 1B0-1BF
	db $0C,$0C,$0D,$0D,$12,$13,$14,$15,$16,$17,$1C,$1D,$1E,$1F,$18,$19		;| Tiles 1C0-1CF
	db $1A,$1B,$08,$09,$0A,$0B,$0C,$0D						;/ Tiles 1D0-1D7

DATA_00E5C8:

	; Indices to the tables at $00E4B9-$00E53D and $00E632, when in tilesets 0
	; or 7 (used for diagonal pipes). This table is indexed by Map16 tile
	; number, for the range 16E-1D7. An index to this table is stored at $82.
	db $00,$00									;\ Tiles 16E-16F
	db $00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03		;| Tiles 170-17F
	db $03,$03,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$06,$06,$06,$06		;| Tiles 180-18F
	db $06,$07,$07,$07,$07,$07,$08,$08,$08,$08,$08,$09,$09,$09,$09,$09		;| Tiles 190-19F
	db $0A,$0A,$0A,$0A,$0A,$0B,$0B,$0B,$0B,$0B,$0C,$0C,$0C,$0C,$0C,$0D		;| Tiles 1A0-1AF
	db $0D,$0D,$0D,$0D,$0E,$0F,$10,$11,$03,$03,$04,$04,$09,$09,$0A,$0A		;| Tiles 1B0-1BF
	db $0C,$0C,$0D,$0D,$0C,$0D,$0D,$0C,$16,$17,$1C,$1D,$1E,$1F,$18,$19		;| Tiles 1C0-1CF
	db $1A,$1B,$08,$09,$0A,$0B,$0C,$0D						;/ Tiles 1D0-1D7
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GraphicsDecompressionRoutines(Address)
namespace SMW_GraphicsDecompressionRoutines
%InsertMacroAtXPosition(<Address>)

UNK_00B882:
	dl SMW_GFX33
	dl SMW_GFX32

DecompressGFX32And33:
	REP.b #$10			; XY->16
#LM000Hijack_MoveGFX32And33_1:
	LDY.w #SMW_GFX33
	STY.b !RAM_SMW_Misc_ScratchRAM8A	; |Store the address 08/BFC0 at $8A-$8C
#LM000Hijack_MoveGFX32And33_2:
	LDA.b #(SMW_GFX33>>16)
	STA.b !RAM_SMW_Misc_ScratchRAM8C
#LM000Hijack_4BPPGFX33_1:
	LDY.w #!RAM_SMW_Graphics_DecompressedGFX32		; LM: Changes this to point to !RAM_SMW_Graphics_DecompressedGFX33 if the below hijack exists.
	STY.b !RAM_SMW_Misc_ScratchRAM00	; |Store the address 7E/2000 at $00-$02
	LDA.b #!RAM_SMW_Graphics_DecompressedGFX32>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w BeginDecompression	; decompression routine
#LM000Hijack_4BPPGFX33_2:
	LDA.b #!RAM_SMW_Graphics_DecompressedGFX33>>16		;\ LM: This code gets skipped over so that GFX33's graphics can be 4BPP
	STA.b !RAM_SMW_Misc_ScratchRAM8F			;|
	REP.b #$30						;|
	LDA.w #!RAM_SMW_Graphics_DecompressedGFX33+$2FFE	;|
	STA.b !RAM_SMW_Misc_ScratchRAM8D			;|
	LDX.w #$23FF						;|
CODE_00B8AD:							;|
	LDY.w #$0008						;|
CODE_00B8B0:							;|
	LDA.l !RAM_SMW_Graphics_DecompressedGFX32,x		;|
	AND.w #$00FF						;|
	STA.b [!RAM_SMW_Misc_ScratchRAM8D]			;|
	DEX							;|
	DEC.b !RAM_SMW_Misc_ScratchRAM8D			;|
	DEC.b !RAM_SMW_Misc_ScratchRAM8D			;|
	DEY							;|
	BNE.b CODE_00B8B0					;|
	LDY.w #$0008						;|
CODE_00B8C4:							;|
	DEX							;|
	LDA.l !RAM_SMW_Graphics_DecompressedGFX32,x		;|
	STA.b [!RAM_SMW_Misc_ScratchRAM8D]			;|
	DEX							;|
	BMI.b CODE_00B8D7					;|
	DEC.b !RAM_SMW_Misc_ScratchRAM8D			;|
	DEC.b !RAM_SMW_Misc_ScratchRAM8D			;|
	DEY							;|
	BNE.b CODE_00B8C4					;|
	BRA.b CODE_00B8AD					;/

CODE_00B8D7:
#LM000Hijack_MoveGFX32And33_3:
if !Define_SMW_LevelGraphics == !TRUE
	; The same five bytes as the pair below. The stub repeats them and
	; then records that the animated tiles hold GFX33, which the
	; expansion above has just put there. See Config/LevelGraphics.asm.
	JSL.l SMW_LevelGraphics_Boot
	NOP				;> The byte the displaced pair leaves, never anything else
else
	LDA.w #SMW_GFX32
	STA.b !RAM_SMW_Misc_ScratchRAM8A
endif
	SEP.b #$20			; A->8
BeginDecompression:
	REP.b #$10			; XY->16
	LDY.w #$0000			; start at beginning of destination
CODE_00B8E3:
#LM182Hijack_CustomCompressionPatch:
if defined("Define_SMW_SA1")
	JSL.l CodeStart
	RTS
else
	JSR.w ReadByte						;\ LM: Hijacks this when installing either of the optional compression routine hijacks (1.82+)
	CMP.b #$FF						;/
endif
	BNE.b CODE_00B8ED		; |Compressed graphics files ends with xFF IIRC
	SEP.b #$10			; | XY->8
	RTS

CODE_00B8ED:
	STA.b !RAM_SMW_Misc_ScratchRAM8F
	AND.b #$E0
	CMP.b #$E0
	BEQ.b CODE_00B8FF
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM8F
	REP.b #$20			; A->16
	AND.w #$001F
	BRA.b CODE_00B911

CODE_00B8FF:
	LDA.b !RAM_SMW_Misc_ScratchRAM8F
	ASL
	ASL
	ASL
	AND.b #$E0
	PHA
	LDA.b !RAM_SMW_Misc_ScratchRAM8F
	AND.b #$03
	XBA
	JSR.w ReadByte
	REP.b #$20			; A->16
CODE_00B911:
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM8D
	SEP.b #$20			; A->8
	PLA
	BEQ.b CODE_00B930
	BMI.b CODE_00B966
	ASL
	BPL.b CODE_00B93F
	ASL
	BPL.b CODE_00B94C
	JSR.w ReadByte
	LDX.b !RAM_SMW_Misc_ScratchRAM8D
CODE_00B926:
	STA.b [!RAM_SMW_Misc_ScratchRAM00],y
	INC
	INY
	DEX
	BNE.b CODE_00B926
	JMP.w CODE_00B8E3

CODE_00B930:
	JSR.w ReadByte
	STA.b [!RAM_SMW_Misc_ScratchRAM00],y
	INY
	LDX.b !RAM_SMW_Misc_ScratchRAM8D
	DEX
	STX.b !RAM_SMW_Misc_ScratchRAM8D
	BNE.b CODE_00B930
	BRA.b CODE_00B8E3

CODE_00B93F:
	JSR.w ReadByte
	LDX.b !RAM_SMW_Misc_ScratchRAM8D
CODE_00B944:
	STA.b [!RAM_SMW_Misc_ScratchRAM00],y
	INY
	DEX
	BNE.b CODE_00B944
	BRA.b CODE_00B8E3

CODE_00B94C:
	JSR.w ReadByte
	XBA
	JSR.w ReadByte
	LDX.b !RAM_SMW_Misc_ScratchRAM8D
CODE_00B955:
	XBA
	STA.b [!RAM_SMW_Misc_ScratchRAM00],y
	INY
	DEX
	BEQ.b CODE_00B963
	XBA
	STA.b [!RAM_SMW_Misc_ScratchRAM00],y
	INY
	DEX
	BNE.b CODE_00B955
CODE_00B963:
	JMP.w CODE_00B8E3

CODE_00B966:
	JSR.w ReadByte
	XBA
	JSR.w ReadByte
if !Define_Global_ROMToAssemble&(!ROM_SMW_J|!ROM_SMW_E2|!ROM_SMASW_E) != $00
	XBA
endif
	TAX
CODE_00B96E:
	PHY
	TXY
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	TYX
	PLY
	STA.b [!RAM_SMW_Misc_ScratchRAM00],y
	INY
	INX
	REP.b #$20			; A->16
	DEC.b !RAM_SMW_Misc_ScratchRAM8D
	SEP.b #$20			; A->8
	BNE.b CODE_00B96E
	JMP.w CODE_00B8E3

ReadByte:
	LDA.b [!RAM_SMW_Misc_ScratchRAM8A]	; Read the byte
	LDX.b !RAM_SMW_Misc_ScratchRAM8A	; \ Go to next byte
	INX
	BNE.b CODE_00B98F		; |   \
	LDX.w #$8000							; Todo: This could be a potential trap if one uses hirom addressing and inserts their GFX somewhere with 64KB banks.
	INC.b !RAM_SMW_Misc_ScratchRAM8C	; |   /
CODE_00B98F:
	STX.b !RAM_SMW_Misc_ScratchRAM8A
	RTS

; Pointers to GFX00 through GFX31, low byte. Under
; !Define_SMW_ManagedGraphicsMemory these three tables stay here and go
; unread: Main takes every file's pointer off the 256-row table at the head
; of the graphics bank instead.
GraphicsPtrLo:
	db SMW_GFX00,SMW_GFX01,SMW_GFX02,SMW_GFX03,SMW_GFX04,SMW_GFX05,SMW_GFX06,SMW_GFX07
	db SMW_GFX08,SMW_GFX09,SMW_GFX0A,SMW_GFX0B,SMW_GFX0C,SMW_GFX0D,SMW_GFX0E,SMW_GFX0F
	db SMW_GFX10,SMW_GFX11,SMW_GFX12,SMW_GFX13,SMW_GFX14,SMW_GFX15,SMW_GFX16,SMW_GFX17
	db SMW_GFX18,SMW_GFX19,SMW_GFX1A,SMW_GFX1B,SMW_GFX1C,SMW_GFX1D,SMW_GFX1E,SMW_GFX1F
	db SMW_GFX20,SMW_GFX21,SMW_GFX22,SMW_GFX23,SMW_GFX24,SMW_GFX25,SMW_GFX26,SMW_GFX27
	db SMW_GFX28,SMW_GFX29,SMW_GFX2A,SMW_GFX2B,SMW_GFX2C,SMW_GFX2D,SMW_GFX2E,SMW_GFX2F
	db SMW_GFX30,SMW_GFX31

; Pointers to GFX00 through GFX31, high byte
GraphicsPtrHi:
	db SMW_GFX00>>8,SMW_GFX01>>8,SMW_GFX02>>8,SMW_GFX03>>8,SMW_GFX04>>8,SMW_GFX05>>8,SMW_GFX06>>8,SMW_GFX07>>8
	db SMW_GFX08>>8,SMW_GFX09>>8,SMW_GFX0A>>8,SMW_GFX0B>>8,SMW_GFX0C>>8,SMW_GFX0D>>8,SMW_GFX0E>>8,SMW_GFX0F>>8
	db SMW_GFX10>>8,SMW_GFX11>>8,SMW_GFX12>>8,SMW_GFX13>>8,SMW_GFX14>>8,SMW_GFX15>>8,SMW_GFX16>>8,SMW_GFX17>>8
	db SMW_GFX18>>8,SMW_GFX19>>8,SMW_GFX1A>>8,SMW_GFX1B>>8,SMW_GFX1C>>8,SMW_GFX1D>>8,SMW_GFX1E>>8,SMW_GFX1F>>8
	db SMW_GFX20>>8,SMW_GFX21>>8,SMW_GFX22>>8,SMW_GFX23>>8,SMW_GFX24>>8,SMW_GFX25>>8,SMW_GFX26>>8,SMW_GFX27>>8
	db SMW_GFX28>>8,SMW_GFX29>>8,SMW_GFX2A>>8,SMW_GFX2B>>8,SMW_GFX2C>>8,SMW_GFX2D>>8,SMW_GFX2E>>8,SMW_GFX2F>>8
	db SMW_GFX30>>8,SMW_GFX31>>8

; Pointers to GFX00 through GFX31, bank byte
GraphicsPtrBank:
	db SMW_GFX00>>16,SMW_GFX01>>16,SMW_GFX02>>16,SMW_GFX03>>16,SMW_GFX04>>16,SMW_GFX05>>16,SMW_GFX06>>16,SMW_GFX07>>16
	db SMW_GFX08>>16,SMW_GFX09>>16,SMW_GFX0A>>16,SMW_GFX0B>>16,SMW_GFX0C>>16,SMW_GFX0D>>16,SMW_GFX0E>>16,SMW_GFX0F>>16
	db SMW_GFX10>>16,SMW_GFX11>>16,SMW_GFX12>>16,SMW_GFX13>>16,SMW_GFX14>>16,SMW_GFX15>>16,SMW_GFX16>>16,SMW_GFX17>>16
	db SMW_GFX18>>16,SMW_GFX19>>16,SMW_GFX1A>>16,SMW_GFX1B>>16,SMW_GFX1C>>16,SMW_GFX1D>>16,SMW_GFX1E>>16,SMW_GFX1F>>16
	db SMW_GFX20>>16,SMW_GFX21>>16,SMW_GFX22>>16,SMW_GFX23>>16,SMW_GFX24>>16,SMW_GFX25>>16,SMW_GFX26>>16,SMW_GFX27>>16
	db SMW_GFX28>>16,SMW_GFX29>>16,SMW_GFX2A>>16,SMW_GFX2B>>16,SMW_GFX2C>>16,SMW_GFX2D>>16,SMW_GFX2E>>16,SMW_GFX2F>>16
	db SMW_GFX30>>16,SMW_GFX31>>16

Main:
;$00BA28
	PHB				; preserve data bank ; Accum (8 bit)
	PHY				; preserve Y (ExGFX file number)
	PHK				; \ current bank
	PLB				; / -> data bank
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	; The same twenty-seven bytes as the three reads and the six stores
	; below. The stub reads the file's pointer off the 256-row table at
	; the head of the graphics bank, into the same scratch, so a file may
	; be any number up to $FE and lie wherever the packing put it; the
	; three tables below stay, unread. It then writes the destination the
	; file's format byte calls for, which for a file larger than the
	; buffer is the staging area at $7E2000 rather than the buffer the
	; stores below always name. Y is the file number, 8-bit at every
	; caller. See Config/ManagedGraphicsMemory.asm.
	JSL.l SMW_ManagedGraphics_Pointer
	NOP #23				;> The bytes the displaced reads and stores leave, never anything else
else
	LDA.w GraphicsPtrLo,y		; \
	STA.b !RAM_SMW_Misc_ScratchRAM8A	;  | get address of
	LDA.w GraphicsPtrHi,y		;  | ExGFX file from
	STA.b !RAM_SMW_Misc_ScratchRAM8B	;  | pointer tables and
	LDA.w GraphicsPtrBank,y		;  | store to $8A-$8C
	STA.b !RAM_SMW_Misc_ScratchRAM8C	; /
	LDA.b #!RAM_SMW_Graphics_GraphicDecompressionBuffer	; \
	STA.b !RAM_SMW_Misc_ScratchRAM00	;  | store destination
	LDA.b #!RAM_SMW_Graphics_GraphicDecompressionBuffer>>8	;  | for decompressed
	STA.b !RAM_SMW_Misc_ScratchRAM01	;  | ExGFX file (GFX
	LDA.b #!RAM_SMW_Graphics_GraphicDecompressionBuffer>>16	;  | Buffer) to $00-$02
	STA.b !RAM_SMW_Misc_ScratchRAM02	; /
endif
#LM_JMLHere_DecompressAnyGraphics:
	JSR.w BeginDecompression	; GFX decompression routine
	PLY				; restore Y (ExGFX file number)
	PLB				; restore data bank
	RTL
namespace off
endmacro

macro ROUTINE_RT01_SMW_OverworldPrompt03_OverworldLifeExchanger(Address)
namespace SMW_OverworldPrompt03_OverworldLifeExchanger
%InsertMacroAtXPosition(<Address>)

; JSL wrapper for the HexToDec routine at $009045.
CODE_00974C:
	JSR.w SMW_HexToDec_Bank00	;\
	RTL				;/ JSL to this code so that you can use Hex > Decmial routine outside bank 00!
namespace off
endmacro

macro ROUTINE_RT01_SMW_OverworldPrompt07_DisplayingSavePrompt(Address)
namespace SMW_OverworldPrompt07_DisplayingSavePrompt
%InsertMacroAtXPosition(<Address>)

Bank00:
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	PHB				;! Wrapper
	PHK				;!
	PLB				;!
	JSR.w Sub			;!
	PLB				;!
endif
	RTL				;!

if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
Sub:
	LDY.b #$06			;!\ Process save menu
	JSR.w SMW_HandleMenuCursor_Main	;!/ Returning from this routine means A/B/start was pressed
	TXA				;!
	BNE.b NotFirstOption		;! If save was selected
	STZ.w !RAM_SMW_IO_SoundCh3	;!\
	LDA.b #!Define_SMW_Sound1DF9_MidwayPoint	;!| Play a sound
	STA.w !RAM_SMW_IO_SoundCh1	;!/
	JSL.l SMW_SaveGame_Main		;! Save the game
NotFirstOption:
	JSL.l SMW_CloseOverworldPrompt_Main	;! And close the save box
	RTS				;!
endif
namespace off
endmacro

macro ROUTINE_RT01_SMW_OverworldPrompt0B_ShowQuitToTitleScreenPrompt(Address)				; Note: This is a SMAS exclusive routine macro
namespace SMW_OverworldPrompt0B_ShowQuitToTitleScreenPrompt
%InsertMacroAtXPosition(<Address>)

Bank30:
	PHB
	PHK
	PLB
	JSR.w Sub
	PLB
	RTL

Sub:
	LDY.b #$06
	JSR.w SMW_HandleMenuCursor_Main
	TXA
	BEQ.b CODE_309BBC
	JML.l SMAS_ResetToSMASTitleScreen_Main

CODE_309BBC:
	JSL.l SMW_CloseOverworldPrompt_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeStatusBarTilemap(Address)
namespace SMW_InitializeStatusBarTilemap
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$80			; More DMA ; Accum (8 bit)
	STA.w !REGISTER_VRAMAddressIncrementValue	; Increment when $2119 accessed ; VRAM Address Increment Value
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation+$2E	; \VRAM address = #$502E
	STA.w !REGISTER_VRAMAddressLo	;  | ; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation>>8	;  |
	STA.w !REGISTER_VRAMAddressHi	; / ; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008D10:
	LDA.w PARAMS_008D90,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x	; Load up the DMA regs
	DEX				; DMA Source = 8C:8118 (...)
	BPL.b CODE_008D10		; Dest = $2118, Transfer: #$08 bytes
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Do the DMA ; Regular DMA Channel Enable
	LDA.b #$80			; \ Set VRAM mode = same as above
	STA.w !REGISTER_VRAMAddressIncrementValue	;  |Address = #$5042 ; VRAM Address Increment Value
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation+$42	;  |
	STA.w !REGISTER_VRAMAddressLo	;  | ; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation>>8	;  |
	STA.w !REGISTER_VRAMAddressHi	; /  ; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008D2F:
	LDA.w PARAMS_008D97,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008D2F
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)
	STA.w !REGISTER_DMAEnable	; Start DMA ; Regular DMA Channel Enable
	LDA.b #$80			; \prep VRAM for another write
	STA.w !REGISTER_VRAMAddressIncrementValue	;  | ; VRAM Address Increment Value
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation+$63	;  |
	STA.w !REGISTER_VRAMAddressLo	;  | ; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation>>8	;  |
	STA.w !REGISTER_VRAMAddressHi	; / ; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008D4E:
	LDA.w PARAMS_008D9E,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008D4E
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			; \Start Transfer
	STA.w !REGISTER_DMAEnable	; / ; Regular DMA Channel Enable
	LDA.b #$80			; \
	STA.w !REGISTER_VRAMAddressIncrementValue	;  |Set up VRAM once more ; VRAM Address Increment Value
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation+$8E	;  |
	STA.w !REGISTER_VRAMAddressLo	;  | ; Address for VRAM Read/Write (Low Byte)
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation>>8	;  |
	STA.w !REGISTER_VRAMAddressHi	; / ; Address for VRAM Read/Write (High Byte)
	LDX.b #$06
CODE_008D6D:
	LDA.w PARAMS_008DA5,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_008D6D
	LDA.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			; \Transfer
	STA.w !REGISTER_DMAEnable	; / ; Regular DMA Channel Enable
	LDX.b #(SMW_StatusBarTilemap_ThirdRowEnd-SMW_StatusBarTilemap_SecondRow-$02)/2
	LDY.b #SMW_StatusBarTilemap_ThirdRowEnd-SMW_StatusBarTilemap_SecondRow-$02
BufferStatusCounterRAMLoop:
	LDA.w SMW_StatusBarTilemap_SecondRow,y
	STA.w !RAM_SMW_Misc_StatusBarTilemap,x
	DEY
	DEY
	DEX
	BPL.b BufferStatusCounterRAMLoop
	LDA.b #!Define_SMW_Counter_TimerFrames	;\ Number of frames one in game second lasts
	STA.w !RAM_SMW_Counter_TimerFrames	;/
	RTS

; These four tables indicate the DMA settings and the source address to use
; for the status bar tiles (the ones that are uploaded at the very beginning
; of the level). The tables get stored in the order of $43x0-$43x6.
PARAMS_008D90:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl SMW_StatusBarTilemap_TopRow
	dw SMW_StatusBarTilemap_TopRowEnd-SMW_StatusBarTilemap_TopRow

PARAMS_008D97:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl SMW_StatusBarTilemap_SecondRow
	dw SMW_StatusBarTilemap_SecondRowEnd-SMW_StatusBarTilemap_SecondRow

PARAMS_008D9E:
	db $01,!REGISTER_WriteToVRAMPortLo

	dl SMW_StatusBarTilemap_ThirdRow
	dw SMW_StatusBarTilemap_ThirdRowEnd-SMW_StatusBarTilemap_ThirdRow

PARAMS_008DA5:
	db $01,!REGISTER_WriteToVRAMPortLo
	dl SMW_StatusBarTilemap_BottomRow
	dw SMW_StatusBarTilemap_BottomRowEnd-SMW_StatusBarTilemap_BottomRow
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode09_EraseFile(Address)
namespace SMW_GameMode09_EraseFile
%InsertMacroAtXPosition(<Address>)

if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
DATA_009B17:
	db $04,$02,$01			;!
endif

Main:
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	REP.b #$20			;! A->16
	LDA.w #$39C9			;!\ Make the screen darker
	LDY.b #$60			;!|
	JSR.w SMW_FileSelectColorMath_Main	;!/
	LDA.b !RAM_SMW_IO_ControllerPress1	;!\ If Y or X is pressed
	ORA.b !RAM_SMW_IO_ControllerPress2	;!| go back to file select
	AND.b #!Joypad_X|(!Joypad_Y>>8)	;!|
	BEQ.b NotPressingXY		;!/
endif

CODE_009B2C:
	DEC.w !RAM_SMW_Misc_GameMode	;\ Go back 2 game modes
	DEC.w !RAM_SMW_Misc_GameMode	;/ and advance forward 1 later
	JSR.w SMW_HandleMenuCursor_CODE_009B11
	JMP.w SMW_GameMode07_TitleScreenDemo_InitializeSaveData

if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
NotPressingXY:
	LDY.b #$08			;!\ Process erase file menu
	JSR.w SMW_HandleMenuCursor_Main	;!/ Returning from this routine means A/B/start was pressed
	CPX.b #$03			;!
	BNE.b CODE_009B6D		;!
	LDY.b #$02			;! loop over each file
CODE_009B43:
	LSR.w !RAM_SMW_Misc_WhichFileToErase	;!
	BCC.b CODE_009B67		;!
	PHY				;!
	LDA.w SMW_SaveFileLocations_Hi,y	;!\ Get the location of this file
	XBA				;!|
	LDA.w SMW_SaveFileLocations_Lo,y	;!/
	REP.b #$10			;! XY->16
	TAX				;!
	LDY.w #!SRAM_SMW_MarioB_StartLocation-!SRAM_SMW_MarioA_StartLocation	;! Clear all 144 bytes of the save file
	LDA.b #$00			;!
CODE_009B58:
	STA.l !SRAM_SMW_MarioA_StartLocation,x	;!
	STA.l !SRAM_SMW_MarioA_Backup,x	;!
	INX				;!
	DEY				;!
	BNE.b CODE_009B58		;!
	SEP.b #$10			;! XY->8
	PLY				;!
CODE_009B67:
	DEY				;!
	BPL.b CODE_009B43		;!
	JMP.w SMW_GameMode07_TitleScreenDemo_FadeOutToTitleScreen	;\ Note: Seems kind of odd for the code to not jump to CODE_009B2C. This JMP.w is what causes END to cause a fadeout.
									;/ If it jumped to CODE_009B2C instead, then it would be like when you press X/Y.
CODE_009B6D:
	STX.w !RAM_SMW_Misc_BlinkingCursorPos	;!\ Add the selected file to the list
	LDA.w DATA_009B17,x		;!| of files to delete when the erase button is selected
	ORA.w !RAM_SMW_Misc_WhichFileToErase	;!|
	STA.w !RAM_SMW_Misc_WhichFileToErase	;!|
	STA.b !RAM_SMW_Misc_ScratchRAM05	;!/
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDY.b #$0C
else
	LDX.b #$00			;!! Index into stripe images--draw the erase files stripe
endif
	JMP.w SMW_BufferFileSelectText_Entry3	;!
endif
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_SaveFileLocations(Address)
namespace SMW_SaveFileLocations
%InsertMacroAtXPosition(<Address>)

; SRAM starting addresses for each of the three save files, high byte.
Hi:
	db (!Define_SMW_Misc_SaveFileSize*$00)>>8
	db (!Define_SMW_Misc_SaveFileSize*$01)>>8
	db (!Define_SMW_Misc_SaveFileSize*$02)>>8
if ver_is_smasw(!Define_Global_ROMToAssemble)
	db (!Define_SMW_Misc_SaveFileSize*$03)>>8
endif

; SRAM starting addresses for each of the three save files, low byte.
Lo:
	db (!Define_SMW_Misc_SaveFileSize*$00)
	db (!Define_SMW_Misc_SaveFileSize*$01)
	db (!Define_SMW_Misc_SaveFileSize*$02)
if ver_is_smasw(!Define_Global_ROMToAssemble)
	db (!Define_SMW_Misc_SaveFileSize*$03)
endif
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_GameMode08_FileSelect(Address)
namespace SMW_GameMode08_FileSelect
%InsertMacroAtXPosition(<Address>)

if ver_is_arcade(!Define_Global_ROMToAssemble)
InitializeZoneSelectionImage:
	db $52,$06,$C0,$0C
	db $FC,$38
	db $52,$10,$C0,$08
	db $FC,$38
	db $52,$06,$00,$01
	db $FC,$38
	db $FF

ZoneSelectionCursorPos:
	db $06,$46,$86,$C6,$10
	db $50,$90

ZoneSelectionCursorRange:
	db $07,$FF

ZoneSelectionCursorWrapAroundValue:
	db $00,$06
endif

Main:
	REP.b #$20			;! A->16
	LDA.w #$7393			;!\ Brighten the background
	LDY.b #$20			;!|
	JSR.w SMW_FileSelectColorMath_Main	;!/
if ver_is_arcade(!Define_Global_ROMToAssemble)
	LDA.b !RAM_SMW_IO_ControllerPress1
	AND.b #(!Joypad_Start>>8)|(!Joypad_B>>8)
	BNE.b CODE_009C6D
	LDA.b !RAM_SMW_IO_ControllerPress2
	BMI.b CODE_009C6D
	LDA.b !RAM_SMW_IO_ControllerPress1
	AND.b #(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)
	BEQ.b CODE_009C39
	LDY.b #!Define_SMW_Sound1DFC_ShootFireball
	STY.w !RAM_SMW_IO_SoundCh3
	LSR
	LSR
	LSR
	TAX
	LDY.w !RAM_SMW_Misc_ZoneSelectionCursorPos
	INY
	CMP.b #$01
	BNE.b CODE_009C2D
	DEY
	DEY

CODE_009C2D:
	TYA
	CMP.w ZoneSelectionCursorRange,x
	BNE.b CODE_009C36
	LDY.w ZoneSelectionCursorWrapAroundValue,x

CODE_009C36:
	STY.w !RAM_SMW_Misc_ZoneSelectionCursorPos

CODE_009C39:
	REP.b #$10
	LDY.w #$3D2E
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$1F
	CMP.b #$18
	BCC.b CODE_009C49
	LDY.w #$38FC

CODE_009C49:
	LDX.w #$0000

CODE_009C4C:
	LDA.w InitializeZoneSelectionImage,x
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	INX
	CPX.w #$0013
	BNE.b CODE_009C4C
	LDX.w !RAM_SMW_Misc_ZoneSelectionCursorPos
	LDA.w ZoneSelectionCursorPos,x
	STA.l SMW_StripeImageUploadTable[$06].HighByte
	REP.b #$20
	TYA
	STA.l SMW_StripeImageUploadTable[$08].LowByte
	SEP.b #$30
	RTS

CODE_009C6D:
	LDA.b #!Define_SMW_Sound1DFC_Coin
	STA.w !RAM_SMW_IO_SoundCh3
	SEP.b #$10
	LDA.w !RAM_SMW_Misc_ZoneSelectionCursorPos
	BEQ.b CODE_009C7C
	STZ.w !RAM_SMW_Misc_IntroLevelFlag

CODE_009C7C:
	INC.w !RAM_SMW_Misc_GameMode
	JSR.w SMW_InitializeSaveData_Main
elseif ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	INC.w !RAM_SMW_Misc_GameMode
	LDA.l !SRAM_SMAS_Global_CurrentSaveFile
	STA.w !RAM_SMW_Misc_CurrentSaveFile
	TAX
	JSR.w SMW_BufferFileSelectText_CODE_009DB5
	BNE.b +
	STZ.w !RAM_SMW_Misc_IntroLevelFlag
	LDY.w #$0000
-:
	LDA.l !SRAM_SMW_MarioA_StartLocation,x
	STA.w !RAM_SMW_Overworld_SaveBuffer,y
	INX
	INY
	CPY.w #!Define_SMW_Misc_SaveFileSize-$02
	BCC.b -
+:
	SEP.b #$10
else
if ver_is_smasw_europe(!Define_Global_ROMToAssemble)
	INC.w !RAM_SMW_Misc_GameMode
	LDA.l !SRAM_SMAS_Global_CurrentSaveFile
	TAX
	BRA.b CODE_009CEF

else
	LDY.b #$02			;!\ Process file select menu
	JSR.w SMW_HandleMenuCursor_Entry2	;!/ Returning from this routine means A/B/start was pressed
	INC.w !RAM_SMW_Misc_GameMode	;!
	CPX.b #$03			;!\ If the fourth option was selected, enter
	BNE.b CODE_009CEF		;!| file erase mode
endif
	STZ.w !RAM_SMW_Misc_WhichFileToErase	;!|
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDY.b #$0C
else
	LDX.b #$00			;!|! Index into stripe images--draw the erase files stripe
endif
	JMP.w SMW_BufferFileSelectText_Entry2	;!/

CODE_009CEF:
	STX.w !RAM_SMW_Misc_CurrentSaveFile	;!
	JSR.w SMW_BufferFileSelectText_CODE_009DB5	;!\ If save file is corrupted, don't load it
	BNE.b CODE_009D22		;!/
	PHX				;! Y = pointer to copy of save data (potentially corrupt)
	STZ.w !RAM_SMW_Misc_IntroLevelFlag	;! Don't to go intro cutscene
	LDA.b #!SRAM_SMW_MarioB_StartLocation	;!
	STA.b !RAM_SMW_Misc_ScratchRAM00	;!
CODE_009CFF:
	LDA.l !SRAM_SMW_MarioA_StartLocation,x	;!\ Copy the save data in SRAM
	PHX				;!| (potentially fixing corrupted copy)
	TYX				;!|
	STA.l !SRAM_SMW_MarioA_StartLocation,x	;!/
	PLX				;!
	INX				;!
	INY				;!
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;!
	BNE.b CODE_009CFF		;!
	PLX				;!
	LDY.w #$0000			;!
CODE_009D14:
	LDA.l !SRAM_SMW_MarioA_StartLocation,x	;!\ Copy the save data from SRAM to WRAM
	STA.w !RAM_SMW_Overworld_SaveBuffer,y	;!/
	INX				;!
	INY				;!
	CPY.w #!Define_SMW_Misc_SaveFileSize-$02	;!
	BCC.b CODE_009D14		;!
CODE_009D22:
	SEP.b #$10			;! XY->8
endif
	LDY.b #!Define_SMW_StripeImage_XPlayerGameText	; Draw "1/2 player game" stripe image
	INC.w !RAM_SMW_Misc_GameMode
SetStripeImage:							; Note: This label is referenced in other routines.
	STY.b !RAM_SMW_Graphics_StripeImageToUpload
	LDX.b #$00
	JMP.w SMW_HandleMenuCursor_CODE_009ED4
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_FileSelectColorMath(Address)
namespace SMW_FileSelectColorMath
%InsertMacroAtXPosition(<Address>)

; Subroutine used for changing the background color on the titlescreen, when
; entering/exiting the file erase menu. To use, load the color (16-bit) to A
; and a CGADDSUB value (for half-color math) to Y first. Changing the first
; three bytes from [8D 01 07] to [EA EA EA] will disable the titlescreen
; back area color from changing.
Main:
	STA.w !RAM_SMW_Palettes_BackgroundColorLo	; Store A in BG color
	STY.b !RAM_SMW_Mirror_ColorMathSelectAndEnable	; Store Y in CGADSUB
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_BufferFileSelectText(Address)
namespace SMW_BufferFileSelectText
%InsertMacroAtXPosition(<Address>)

if ver_is_arcade(!Define_Global_ROMToAssemble)
Main:
	LDX.b #SMW_FileSelectText_SelectFile-SMW_FileSelectText_Main
	REP.b #$10
	LDY.w #$0000

Loop:
	LDA.l SMW_FileSelectText_Main,x
	PHX
	TYX
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	PLX
	INX
	INY
	CPY.w #$00CC
	BNE.b Loop
	SEP.b #$10
	RTS

UNK_009CB2:
	db $60

elseif ver_is_japanese(!Define_Global_ROMToAssemble)
DATA_009CD2:
	dw $31D4,$38FC,$319D,$38FC
	dw $318D,$38FC,$38FC,$38FC

Main:
Entry2:
	STZ.b !RAM_SMW_Misc_ScratchRAM05
Entry3:
	STY.b !RAM_SMW_Misc_ScratchRAM06
	LDX.b #(SMW_FileSelectText_SelectFileEnd-SMW_FileSelectText_Main)+$02
-:
	LDA.l SMW_FileSelectText_Main-$01,x
	STA.l SMW_StripeImageUploadTable[$00].LowByte-$01,x
	DEX
	BNE.b -
	LDA.b #$76
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b #$02
CODE_009D5B:
	STX.b !RAM_SMW_Misc_ScratchRAM04
	LSR.b !RAM_SMW_Misc_ScratchRAM05
	BCS.b CODE_009DA6
	JSR.w CODE_009DB5
	BNE.b CODE_009DA6
	LDA.l !SRAM_SMW_MarioA_StartLocation+$8C,x
	SEP.b #$10

CODE_009D76:
	JSR.w SMW_HexToDec_Bank00
	TXY
CODE_009D7A:
	LDX.b !RAM_SMW_Misc_ScratchRAM00
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	TYA
	BNE.b CODE_009D85
	LDY.b #$FC
CODE_009D85:
	TYA
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	LDA.b #$38
	STA.l SMW_StripeImageUploadTable[$01].HighByte,x
	STA.l SMW_StripeImageUploadTable[$02].HighByte,x
	REP.b #$20
	LDA.w #$38FC
	STA.l SMW_StripeImageUploadTable[$09].LowByte,x
	LDY.b !RAM_SMW_Misc_ScratchRAM06

-:
	LDA.w DATA_009CD2,y
	STA.l SMW_StripeImageUploadTable[$03].LowByte,x
	INX
	INX
	DEY
	DEY
	DEY
	DEY
	BPL.b -
	SEP.b #$20
CODE_009DA6:
	SEP.b #$10
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b #$2A
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	DEX
	BPL.b CODE_009D5B
	RTS

CODE_009DB5:
	LDA.w SMW_SaveFileLocations_Hi,x
	XBA
	LDA.w SMW_SaveFileLocations_Lo,x
	REP.b #$30
	TAX
	CLC
	ADC.w #!SRAM_SMW_MarioA_Backup-!SRAM_SMW_MarioA_StartLocation	; The backup's offset from the first file: an index, not an address
	TAY
CODE_009DC4:
	PHX
	PHY
	LDA.l !SRAM_SMW_MarioA_StartLocation+(!Define_SMW_Misc_SaveFileSize-$02),x
	STA.b !RAM_SMW_Misc_ScratchRAM8A
	SEP.b #$20
	LDY.w #!Define_SMW_Misc_SaveFileSize-$02
CODE_009DD1:
	LDA.l !SRAM_SMW_MarioA_StartLocation,x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM8A
	STA.b !RAM_SMW_Misc_ScratchRAM8A
	BCC.b CODE_009DDE
	INC.b !RAM_SMW_Misc_ScratchRAM8B
CODE_009DDE:
	INX
	DEY
	BNE.b CODE_009DD1
	REP.b #$20
	PLY
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM8A
	CMP.w #!Define_SMW_ChecksumCompliment
	BEQ.b CODE_009DF7
	CPX.w #!SRAM_SMW_MarioA_Backup-$01
	BCS.b CODE_009DF7
	PHX
	TYX
	PLY
	BRA.b CODE_009DC4
CODE_009DF7:
	SEP.b #$20
	RTS
else
Main:
	LDX.b #SMW_FileSelectText_SelectFile-SMW_FileSelectText_Main	;! Index into stripe images--draw the file select stripe
Entry2:
	STZ.b !RAM_SMW_Misc_ScratchRAM05	;!! Don't erase any files
Entry3:
	REP.b #$10			;! XY->16
	LDY.w #$0000			;!
CODE_009D41:
	LDA.l SMW_FileSelectText_Main,x	;!\ Draw file select or file erase stripe image
	PHX				;!| Depending on what mode we are in
	TYX				;!|
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x	;!/
	PLX				;!
	INX				;!
	INY				;!
	CPY.w #$00CC			;!
	BNE.b CODE_009D41		;!
	SEP.b #$10			;! XY->8
	LDA.b #$84			;!! location within stripe image to write exit count
	STA.b !RAM_SMW_Misc_ScratchRAM00	;!
	LDX.b #$02			;! loop over each file
CODE_009D5B:
	STX.b !RAM_SMW_Misc_ScratchRAM04	;!
	LSR.b !RAM_SMW_Misc_ScratchRAM05	;!\ If this file is marked to be erased
	BCS.b CODE_009DA6		;!/ show it as empty
	JSR.w CODE_009DB5		;!\ If this file is corrupted
	BNE.b CODE_009DA6		;!/ show it as empty
	LDA.l !SRAM_SMW_MarioA_StartLocation+$8C,x	;!
	SEP.b #$10			;! XY->8
	CMP.b #!Define_SMW_Counter_TotalExits	;!! If all the exits are collected
	BCC.b CODE_009D76		;!! use special tiles for the counter next to the file
	LDY.b #$87			;!!
	LDA.b #$88			;!!
	BRA.b CODE_009D7A		;!!

CODE_009D76:
	JSR.w SMW_HexToDec_Bank00	;!\ Otherwise, convert number of exits to decimal
	TXY				;!/
CODE_009D7A:
	LDX.b !RAM_SMW_Misc_ScratchRAM00	;! X = location within stripe image to write exit count
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x	;!
	TYA				;!
	BNE.b CODE_009D85		;!\ Leading zero is a blank space
	LDY.b #$FC			;!/
CODE_009D85:
	TYA				;!
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x	;!
	LDA.b #$38			;!\ Exit count uses different palette
	STA.l SMW_StripeImageUploadTable[$01].HighByte,x	;!|
	STA.l SMW_StripeImageUploadTable[$02].HighByte,x	;!/
	REP.b #$20			;! A->16
	LDY.b #$03			;!!
CODE_009D98:
	LDA.w #$38FC			;!!\ Clear out the rest of the word "empty"
	STA.l SMW_StripeImageUploadTable[$03].LowByte,x	;!!/
	INX				;!!
	INX
	DEY				;!!
	BNE.b CODE_009D98		;!!
	SEP.b #$20			;!! A->8
CODE_009DA6:
	SEP.b #$10			;!! XY->8
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;!\
	SEC				;!| Move to next file
	SBC.b #$24			;!| bytes backward within stripe image
	STA.b !RAM_SMW_Misc_ScratchRAM00	;!|
	LDX.b !RAM_SMW_Misc_ScratchRAM04	;!|
	DEX				;!|
	BPL.b CODE_009D5B		;!/
	RTS				;!

; The subroutine that checks if a saved game file is blank or not. When this
; subroutine returns, if Z = 0, the file is a new one.
CODE_009DB5:
	LDA.w SMW_SaveFileLocations_Hi,x	;!
	XBA				;!
	LDA.w SMW_SaveFileLocations_Lo,x	;!
	REP.b #$30			;! AXY->16
	TAX				;!\ X = pointer to save data
	CLC				;!|
if ver_is_smasw(!Define_Global_ROMToAssemble)
	ADC.w #(!Define_SMW_Misc_SaveFileSize*$04)
else
	ADC.w #(!Define_SMW_Misc_SaveFileSize*$03)	;!|
endif
	TAY				;!/ Y = pointer to the other copy
CODE_009DC4:
	PHX				;!
	PHY				;!
	LDA.l !SRAM_SMW_MarioA_StartLocation+(!Define_SMW_Misc_SaveFileSize-$02),x	;!\ Start with the checksum in the save file
	STA.b !RAM_SMW_Misc_ScratchRAM8A	;!/
	SEP.b #$20			;! A->8
	LDY.w #!Define_SMW_Misc_SaveFileSize-$02	;!
CODE_009DD1:
	LDA.l !SRAM_SMW_MarioA_StartLocation,x	;!\ Add up all the bytes
	CLC				;!|
	ADC.b !RAM_SMW_Misc_ScratchRAM8A	;!|
	STA.b !RAM_SMW_Misc_ScratchRAM8A	;!|
	BCC.b CODE_009DDE		;!| Carry if needed
	INC.b !RAM_SMW_Misc_ScratchRAM8B	;!/
CODE_009DDE:
	INX				;!
	DEY				;!
	BNE.b CODE_009DD1		;!
	REP.b #$20			;! A->16
	PLY				;!
	PLX				;!
	LDA.b !RAM_SMW_Misc_ScratchRAM8A	;!\ Valid result should be this base value
	CMP.w #!Define_SMW_ChecksumCompliment	;!|
	BEQ.b CODE_009DF7		;!/ Exit if the save is valid
if ver_is_smasw(!Define_Global_ROMToAssemble)
	CPX.w #(!Define_SMW_Misc_SaveFileSize*$04)-$01
else
	CPX.w #(!Define_SMW_Misc_SaveFileSize*$03)-$01	;!\
endif
	BCS.b CODE_009DF7		;!/ Exit if both copies are invalid
	PHX				;!\
	TYX				;!| If the first save is invalid, swap X/Y and check the copy
	PLY				;!/
	BRA.b CODE_009DC4		;!
CODE_009DF7:
	SEP.b #$20			;! A->8
	RTS				;!

if ver_is_smasw(!Define_Global_ROMToAssemble)
SMASEntry:
	JSR.w CODE_009DB5
	SEP.b #$10
	RTL
endif
endif
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_GameMode0A_PlayerSelect(Address)
namespace SMW_GameMode0A_PlayerSelect
%InsertMacroAtXPosition(<Address>)

Main:
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_IO_ControllerHold2CopyP1
	ORA.w !RAM_SMW_IO_ControllerHold1CopyP1
	ORA.w !RAM_SMW_IO_ControllerHold2CopyP2
	ORA.w !RAM_SMW_IO_ControllerHold1CopyP2
	AND.b #!Joypad_X|(!Joypad_Y>>8)
	BEQ.b NotPressingXY
	JML.l SMAS_ResetToSMASTitleScreen_Main

elseif ver_is_smasw_europe(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_IO_ControllerPress1CopyP1
	ORA.w !RAM_SMW_IO_ControllerPress1CopyP2
	STA.b !RAM_SMW_IO_ControllerPress1
	LDA.w !RAM_SMW_IO_ControllerPress2CopyP1
	ORA.w !RAM_SMW_IO_ControllerPress2CopyP2
	STA.b !RAM_SMW_IO_ControllerPress2
	ORA.b !RAM_SMW_IO_ControllerPress1
	AND.b #!Joypad_X|(!Joypad_Y>>8)
	BEQ.b NotPressingXY
	JML.l SMAS_CopyOfResetToSMASTitleScreen_Main
else
	LDA.b !RAM_SMW_IO_ControllerPress1	;\
	ORA.b !RAM_SMW_IO_ControllerPress2	;| If X/Y pressed, go back to file select
	AND.b #!Joypad_X|(!Joypad_Y>>8)	;|
	BEQ.b NotPressingXY		;|
	DEC.w !RAM_SMW_Misc_GameMode	;|
	JMP.w SMW_GameMode09_EraseFile_CODE_009B2C	;/
endif
NotPressingXY:
	LDY.b #$04			;\ Process player select menu
	JSR.w SMW_HandleMenuCursor_Entry2	;/ Returning from this routine means A/B/start was pressed
	STX.w !RAM_SMW_Flag_TwoPlayerGame
	JSR.w SMW_LoadSaveBufferData_Main
	JSL.l SMW_LoadOverworldLayer2AndEventsTilemaps_Main
Entry2:								; Info: Called after selecting "Continue" after a game over.
	LDA.b #!Define_SMW_LevelMusic_MusicFade	;\ Fade music
	STA.w !RAM_SMW_IO_MusicCh1	;/
	LDA.b #$FF			;\ Set player 2 lives to -1 first
	STA.w !RAM_SMW_Player_LuigisLives	;/
	LDX.w !RAM_SMW_Flag_TwoPlayerGame
	LDA.b #!Define_SMW_Counter_StartingLives
InitializeLivesTo5Loop:
	STA.w !RAM_SMW_Player_MariosLives,x
	DEX
	BPL.b InitializeLivesTo5Loop
	STA.w !RAM_SMW_Player_CurrentLifeCount	; Current lives is also 4
	STZ.w !RAM_SMW_Player_CurrentCoinCount
	STZ.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	; Set powerups at game start. ($19 = #$00, small Mario.)
	STZ.b !RAM_SMW_Player_CurrentPowerUp
	STZ.w !RAM_SMW_Player_CurrentItemBox
	STZ.w !RAM_SMW_Flag_ShowContinueAndEnd
	REP.b #$20
	STZ.w !RAM_SMW_Player_MariosCoins
	STZ.w !RAM_SMW_Player_MariosPowerUp
	STZ.w !RAM_SMW_Player_MariosYoshi
	STZ.w !RAM_SMW_Player_CurrentItemBox			; Optimization: This should be moved to before/after the REP/SEP so that $0DC3 can be 100% free RAM.
	STZ.w !RAM_SMW_Player_MarioBonusStars
	STZ.w !RAM_SMW_Player_MarioScoreLo
	STZ.w !RAM_SMW_Player_LuigiScoreLo
	SEP.b #$20
	STZ.w !RAM_SMW_Player_MarioScoreHi
	STZ.w !RAM_SMW_Player_LuigiScoreHi
	STZ.w !RAM_SMW_Misc_ExitLevelAction	; Enter overworld normally
	STZ.w !RAM_SMW_Player_CurrentCharacter	; Player 1's turn
CODE_009E62:
	JSR.w SMW_SetKeepGameModeActiveTimer_OneFrame
	LDY.b #!Define_SMW_GameMode0B_FadeOutToOverworld
	JMP.w SMW_GameMode07_TitleScreenDemo_FadeOutToOverworld
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SaveGame(Address)
namespace SMW_SaveGame
%InsertMacroAtXPosition(<Address>)

Main:
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	; Save Game function. (Load Game starts around $009CEF. Last byte used in
	; SRAM seems to be $70:0358.)
	PHB				;!
	PHK				;!
	PLB				;!
	LDX.w !RAM_SMW_Misc_CurrentSaveFile	;!\ Put location of save data in X
	LDA.w SMW_SaveFileLocations_Hi,x	;!|
	XBA				;!|
	LDA.w SMW_SaveFileLocations_Lo,x	;!|
	REP.b #$10			;!| XY->16
	TAX				;!/
CODE_009BD9:
	LDY.w #$0000			;!\ Clear the checksum counter
	STY.b !RAM_SMW_Misc_ScratchRAM8A	;!/
CODE_009BDE:
	LDA.w !RAM_SMW_Overworld_SaveBuffer,y	;!\ Move a byte into SRAM
	STA.l !SRAM_SMW_MarioA_StartLocation,x	;!/
	CLC				;!\
	ADC.b !RAM_SMW_Misc_ScratchRAM8A	;!| Add it to the checksum
	STA.b !RAM_SMW_Misc_ScratchRAM8A	;!|
	BCC.b CODE_009BEE		;!| And carry if needed
	INC.b !RAM_SMW_Misc_ScratchRAM8B	;!/
CODE_009BEE:
	INX				;!\
	INY				;!| Move to next byte
	CPY.w #!Define_SMW_Misc_SaveFileSize-$02	;!/
	BCC.b CODE_009BDE		;! And repeat
	REP.b #$20			;! A->16
	LDA.w #!Define_SMW_ChecksumCompliment	;!\
	SEC				;!| Subtract checksum from base value
	SBC.b !RAM_SMW_Misc_ScratchRAM8A	;!| And write it to the save file
	STA.l !SRAM_SMW_MarioA_StartLocation,x	;!/
if ver_is_smasw(!Define_Global_ROMToAssemble)
	CPX.w #(!Define_SMW_Misc_SaveFileSize*$04)
else
	CPX.w #(!Define_SMW_Misc_SaveFileSize*$03)	;!\ Make a copy of the save file
endif
	BCS.b CODE_009C0F		;!/
	TXA				;!\ By offseting a bit into SRAM
if ver_is_smasw(!Define_Global_ROMToAssemble)
	ADC.w #(!Define_SMW_Misc_SaveFileSize*$03)+$02
else
	ADC.w #(!Define_SMW_Misc_SaveFileSize*$02)+$02	;!|
endif
	TAX				;!/
	SEP.b #$20			;! A->8
	BRA.b CODE_009BD9		;!

CODE_009C0F:
	SEP.b #$30			;! AXY->8
	PLB				;!
endif
	RTL				;!
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DisplayingContinueEnd(Address)
namespace SMW_DisplayingContinueEnd
%InsertMacroAtXPosition(<Address>)

Main:
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	PHB				;! Wrapper
	PHK				;!
	PLB				;!
	JSR.w Sub			;!
	PLB				;!
endif
	RTL				;!

if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
Sub:
	DEC				;!
	JSL.l SMW_ExecutePtr_Absolute	;!

Ptrs009B8D:
	dw Initialize			;!
	dw Display			;!

Initialize:
	LDY.b #!Define_SMW_StripeImage_ContinueEndText	;!\ Draw "Continue/End" stripe image
	JSR.w SMW_GameMode08_FileSelect_SetStripeImage	;!/
	INC.w !RAM_SMW_Flag_ShowContinueAndEnd	;! move to next process
endif
	RTS				;!

if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
Display:
	LDY.b #$00			;!\ Process continue/end menu
	JSR.w SMW_HandleMenuCursor_Main	;!/ Returning from this routine means A/B/start was pressed
	TXA				;!
	BNE.b LoadTitlescreen		;!
	JMP.w SMW_GameMode0A_PlayerSelect_Entry2	;!

LoadTitlescreen:
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	JML.l SMAS_ResetToSMASTitleScreen_Main
elseif ver_is_smasw_europe(!Define_Global_ROMToAssemble)
	JML.l SMAS_CopyOfResetToSMASTitleScreen_Main
else
	JMP.w SMW_GameMode07_TitleScreenDemo_FadeOutToTitleScreen	;!
endif
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode07_TitleScreenDemo(Address)
namespace SMW_GameMode07_TitleScreenDemo
%InsertMacroAtXPosition(<Address>)

ItrCntrlrSqnc:
if ver_is_pal(!Define_Global_ROMToAssemble)
	db $41,$0D,$C1,$30,$00,$10,$42,$26
	db $41,$58,$81,$17,$00,$7A,$82,$0C
	db $00,$34,$C1,$2A,$41,$50,$C1,$0C
	db $00,$30,$01,$20,$E1,$01,$00,$60
	db $41,$30,$80,$10,$00,$30,$41,$4E
	db $00,$20,$60,$01,$00,$30,$60,$01
	db $00,$30,$60,$01,$00,$30,$60,$01
	db $00,$30,$60,$01,$00,$30,$41,$15
	db $C1,$30,$00,$30,$FF
else
	; Mario's movement data on Title Screen. Format: xx yy xx yy xx yy [...]
	; $FF The XXs is the value to store to $15, except that the Select flag
	; (#$20) is instead used to tell if the XY flag (#$40) should be masked
	; away from $16 (if it's set, that bit is stored to $16 unchanged; if
	; clear, that bit is masked away. All other bits are stored to $16.) The
	; YYs is how long to keep that value there. Setting an XX to $FF ends it.
	db $41,$0F,$C1,$30,$00,$10,$42,$20	;!
	db $41,$70,$81,$11,$00,$80,$82,$0C	;!
	db $00,$30,$C1,$30,$41,$60,$C1,$10	;!
	db $00,$40,$01,$30,$E1,$01,$00,$60	;!
	db $41,$4E,$80,$10,$00,$30,$41,$58	;!
	db $00,$20,$60,$01,$00,$30,$60,$01	;!
	db $00,$30,$60,$01,$00,$30,$60,$01	;!
	db $00,$30,$60,$01,$00,$30,$41,$1A	;!
	db $C1,$30,$00,$30,$FF		;!
endif

Main:
	JSR.w SMW_CheckWhichControllersArePluggedIn_Main
	JSR.w CODE_009CBE
	; Change to 80 to open save game menu without pressing a button or Title
	; Screen Playing.
	BNE.b InitializeFileSelect
	JSR.w SMW_DamagePlayer_DisableButtons	; Zero controller RAM mirror
#LM000Hijack_CustomTitleScreenDemo:
	LDX.w !RAM_SMW_Misc_TitleScreenMovementDataIndex	; (Unknown byte) -> X
	DEC.w !RAM_SMW_Timer_TitleScreenInputTimer	; Decrement controller bits time
	BNE.b CODE_009C82		; if !=  0 branch forward
	LDA.w ItrCntrlrSqnc+$01,x	; Load $00/9C20,$1DF4
	STA.w !RAM_SMW_Timer_TitleScreenInputTimer	; And store to $1DF5
	INX
	INX				; $1DF4+=2
	STX.w !RAM_SMW_Misc_TitleScreenMovementDataIndex
; Change to [EA A9 00] to remove title screen movement. Title screen will
; not loop.
CODE_009C82:
	LDA.w ItrCntrlrSqnc-$02,x	; With the +=2 above, this is effectively LDA $9C20,$1DF4
	CMP.b #$FF
	; Change D0 (BNE) to 80 (BRA) to never make the titlescreen loop.
	BNE.b CODE_009C8F
FadeOutToTitleScreen:
	LDY.b #!Define_SMW_GameMode02_FadeOutToTitleScreen	; If = #$FF, switch to game mode #$02...
FadeOutToOverworld:							; Note: This label is called in the GameMode0A code and has nothing to do with the title screen demo
	STY.w !RAM_SMW_Misc_GameMode
	RTS				; ...And finish

CODE_009C8F:
	AND.b #(!Joypad_DPadR>>8)|(!Joypad_DPadL>>8)|(!Joypad_DPadD>>8)|(!Joypad_DPadU>>8)|(!Joypad_Start>>8)|!Joypad_X|(!Joypad_Y>>8)|!Joypad_A|(!Joypad_B>>8)	;\ Write all bits except select button
	STA.b !RAM_SMW_IO_ControllerHold1	;/ to controller held register
	CMP.w ItrCntrlrSqnc-$02,x
	BNE.b CODE_009C9A
	AND.b #(!Joypad_DPadR>>8)|(!Joypad_DPadL>>8)|(!Joypad_DPadD>>8)|(!Joypad_DPadU>>8)|(!Joypad_Start>>8)|(!Joypad_B>>8)
CODE_009C9A:
	STA.b !RAM_SMW_IO_ControllerPress1	; Write to byte 01, Just-pressed variant
	JMP.w SMW_GameMode14_InLevel_Main	; Jump to another section of this routine

InitializeFileSelect:
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	LDA.l !SRAM_SMAS_Global_RunningDemoFlag
	BNE.b +
	LDA.w !RAM_SMW_IO_ControllerHold2CopyP1
	ORA.w !RAM_SMW_IO_ControllerHold1CopyP1
	ORA.w !RAM_SMW_IO_ControllerHold2CopyP2
	ORA.w !RAM_SMW_IO_ControllerHold1CopyP2
	AND.b #!Joypad_X|(!Joypad_Y>>8)
	BEQ.b ++
+:
	JML.l SMAS_ResetToSMASTitleScreen_Main

++:
elseif ver_is_smasw_europe(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_IO_ControllerPress1CopyP1
	ORA.w !RAM_SMW_IO_ControllerPress1CopyP2
	AND.b #!Joypad_Y>>8
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_IO_ControllerPress2CopyP1
	ORA.w !RAM_SMW_IO_ControllerPress2CopyP2
	AND.b #!Joypad_X
	ORA.b !RAM_SMW_Misc_ScratchRAM00
	BEQ.b +
	JML.l SMAS_CopyOfResetToSMASTitleScreen_Main

+:
endif
	; Change from 22 00 80 7F to EA EA EA EA to disable sprites from
	; disappearing on the title screen when pressing a button (opening file
	; select menu)
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt	; Move sprites offscreen (effectively gone)
	LDA.b #$04
	STA.w !REGISTER_MainScreenLayers	; Zero something related to PPU ; Background and Object Enable
	LDA.b #$13
	STA.w !REGISTER_SubScreenLayers	; Sub Screen Designation
if ver_is_japanese(!Define_Global_ROMToAssemble)
elseif ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	; Change '9C 9F 0D' to 'EA EA EA', and, if you happened to have a HDMA
	; effect in the titlescreen, it will not be disabled when you go to the
	; File Menu.
	STZ.w !RAM_SMW_Mirror_HDMAEnable				; Glitch: This disables all HDMA effects you may have active on the title screen when accessing the file select menu.
endif
InitializeSaveData:							; Note: This label is only referenced in the GameMode09 code.
	LDA.b #!Define_SMW_LevelID_IntroSublevel	;\ Upon entering file select,
	STA.w !RAM_SMW_Misc_IntroLevelFlag	;| Set overworld override to intro cutscene
	JSR.w SMW_InitializeSaveData_Main	;/ And initialize save data for new game
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDY.b #$0E
	JSR.w SMW_BufferFileSelectText_Main
	LDA.b #$FF
	STA.l SMW_StripeImageUploadTable[$4E].LowByte
elseif ver_is_smasw(!Define_Global_ROMToAssemble)
else
	JSR.w SMW_BufferFileSelectText_Main	;!
endif
	JMP.w SMW_GameMode01_ShowNintendoPresents_CODE_009417	; Increase the Game mode and return (at jump point)

CODE_009CBE:
if ver_is_smasw(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_IO_ControllerHold2CopyP1
	ORA.w !RAM_SMW_IO_ControllerHold2CopyP2
	AND.b #!Joypad_X|!Joypad_A
	BNE.b Return009CCA
	LDA.w !RAM_SMW_IO_ControllerHold1CopyP1
	ORA.w !RAM_SMW_IO_ControllerHold1CopyP2
else
	LDA.b !RAM_SMW_IO_ControllerHold2
	AND.b #!Joypad_X|!Joypad_A
	BNE.b Return009CCA
	LDA.b !RAM_SMW_IO_ControllerHold1
endif
	AND.b #(!Joypad_Start>>8)|(!Joypad_Select>>8)|!Joypad_X|(!Joypad_Y>>8)|!Joypad_A|(!Joypad_B>>8)
	BNE.b Return009CCA						;\ Optimization: Branch to Z if not 0, otherwise go to Z.
Return009CCA:								;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CloseOverworldPrompt(Address)
namespace SMW_CloseOverworldPrompt
%InsertMacroAtXPosition(<Address>)

Main:
	INC.w !RAM_SMW_Pointer_DisplayOverworldPrompt
	INC.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection
	LDY.b #!Define_SMW_StripeImage_CloseOverworldPrompt
	JSR.w SMW_GameMode08_FileSelect_SetStripeImage
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetEnemyRollcallParallaxHDMA(Address)
namespace SMW_SetEnemyRollcallParallaxHDMA
%InsertMacroAtXPosition(<Address>)

Init:
	LDA.b #$58
	STA.w SMW_ParallaxScrollHDMA[$00].Scanline1	;\
	STA.w SMW_ParallaxScrollHDMA[$01].Scanline1	;|
	STA.w SMW_ParallaxScrollHDMA[$02].Scanline1	;|
	STZ.w SMW_ParallaxScrollHDMA[$00].End	;|seems to be resetting the HDMA effects?
	STZ.w SMW_ParallaxScrollHDMA[$01].End	;|
	STZ.w SMW_ParallaxScrollHDMA[$02].End	;/
	LDX.b #$04
CODE_0092C8:
	LDA.w PARAMS_009313,x
	STA.w HDMA[$05].Parameters,x
	LDA.w PARAMS_009318,x
	STA.w HDMA[$06].Parameters,x
	LDA.w PARAMS_00931D,x
	STA.w HDMA[!Define_SMW_WindowHDMAChannel].Parameters,x
	DEX
	BPL.b CODE_0092C8
	LDA.b #$00			;\ HDMA channels 5,6, and 7 all use data bank 00 and 00 only!
	STA.w HDMA[$05].IndirectSourceBank	;|Data Bank (H-DMA)
	STA.w HDMA[$06].IndirectSourceBank	;|Data Bank (H-DMA)
	STA.w HDMA[!Define_SMW_WindowHDMAChannel].IndirectSourceBank	;/Data Bank (H-DMA)
	LDA.b #($60|($01<<!Define_SMW_WindowHDMAChannel))			;\ Enable HDMAs on channels 5, 6, and 7.
	STA.w !RAM_SMW_Mirror_HDMAEnable	;/
Main:
	REP.b #$30			; AXY->16
	LDY.w #$0008
	LDX.w #$0014
CODE_0092F5:
	LDA.w !RAM_SMW_Mirror_CurrentLayer1XPosLo,y
	STA.w SMW_ParallaxScrollHDMA[$00].PosLo1,x
	STA.w SMW_ParallaxScrollHDMA[$00].PosLo2,x
	LDA.w !RAM_SMW_Misc_Layer1XPosLo,y
	STA.w SMW_ParallaxScrollHDMA[$00].PosLo3,x
	TXA
	SEC
	SBC.w #$000A
	TAX
	DEY
	DEY
	DEY
	DEY
	BPL.b CODE_0092F5
	SEP.b #$30			; AXY->8
	RTS

PARAMS_009313:
	db $02,!REGISTER_BG1HorizScrollOffset
	dl SMW_ParallaxScrollHDMA[$00].Scanline1

PARAMS_009318:
	db $02,!REGISTER_BG2HorizScrollOffset
	dl SMW_ParallaxScrollHDMA[$01].Scanline1

PARAMS_00931D:
	db $02,!REGISTER_BG3HorizScrollOffset
	dl SMW_ParallaxScrollHDMA[$02].Scanline1
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UpdateEntirePalette(Address)
namespace SMW_UpdateEntirePalette
%InsertMacroAtXPosition(<Address>)

; Routine that uploads the entire palette from $0703 to CGRAM. Note that it
; first resets $0703 and $0704 to $0000 (i.e. turns color 0 to black). This
; routine is called during various loading screens (Nintendo Presents, level
; load, overworld load, cutscene load, credits load) but not during
; gameplay.
Main:
	STZ.w !RAM_SMW_Palettes_PaletteMirror	;\
	STZ.w !RAM_SMW_Palettes_PaletteMirror+$01	;| Clear first color of palette data.
	STZ.w !REGISTER_CGRAMAddress	;/
	LDX.b #$06
Loop:
	LDA.w PARAMS_009249,x
	STA.w DMA[$02].Parameters,x
	DEX
	BPL.b Loop
	LDA.b #$04			;\
	STA.w !REGISTER_DMAEnable	;/Regular DMA Channel Enable
	RTS

PARAMS_009249:
	db $00,!REGISTER_WriteToCGRAMPort
	dl !RAM_SMW_Palettes_PaletteMirror
	dw $0200
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckWhichControllersArePluggedIn(Address)
namespace SMW_CheckWhichControllersArePluggedIn
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.w !REGISTER_JoypadSerialPort1	;\
	LSR				;| Connected controllers will read a 1 here
	LDA.w !REGISTER_JoypadSerialPort2	;|
	ROL				;|
	AND.b #$03			;/ Format ------21
	BEQ.b NoControllerPluggedIn	; If no controllers connected, controller 1 data (all 0s) is used
	CMP.b #$03			;\ If there is only one controller connected (in either port)
	BNE.b OneControllerPluggedIn	;/ than that contollers data will be used
	ORA.b #$80			; Set high bit if both controllers present
OneControllerPluggedIn:
	DEC
NoControllerPluggedIn:
	STA.w !RAM_SMW_IO_ControllersPluggedIn
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_DamagePlayer(Address)
namespace SMW_DamagePlayer
%InsertMacroAtXPosition(<Address>)

; Hurt Subroutine (JSL to it to hurt the player). $00:F5B9: Change to F0 to
; make mario invincible. (Will not make him invincible to crushing objects,
; lava or pitfalls). $00:F5C1-$00:F5C3: Change from 0D 93 14 to EA EA EA to
; make Mario die normally when touching an enemy/muncher even after getting
; the goal tape/sphere. $00:F5C6: Change from 9C E3 18 to EA EA EA to
; prevent coin game cloud counter from resetting on hit. $00:F5D7: Change
; this to 80 to have Mario die when touched, regardless of powerup status.
; $00:F5E3: This SFX plays when you get hit when flying. $00:F5ED:
; Invincibility timer when hit while flying. $00:F5F4: Mario shrinking SFX.
; $00:F5F8-$00:F5FB: Set to EA EA EA EA to disable item box auto-falling
; when you get hurt. $00:F5FC-$00:F5FF: Change the "A9 01 85 71" to "EA EA
; EA EA" to disable mario's shrinking animation when hit.
Hurt:
	LDA.b !RAM_SMW_Player_CurrentState	; \ Return if animation sequence activated
	BNE.b Return
	LDA.w !RAM_SMW_Timer_PlayerHurt	; \ If flashing...
	ORA.w !RAM_SMW_Timer_StarPower	; | ...or have star...
	ORA.w !RAM_SMW_Timer_EndLevel	; | ...or level ending...
	BNE.b Return			; / ...return
	STZ.w !RAM_SMW_Counter_PinkBerryCloudCoins
	LDA.w !RAM_SMW_Player_WallWalkStatus	;\
	BEQ.b NotOnWall			;/ if not wall-walking, skip running this routine
	PHB
	PHK
	PLB
	JSR.w SMW_RunPlayerBlockCode_ADDR_00EB42	; Stop wall walking, I beleive
	PLB
NotOnWall:
	LDA.b !RAM_SMW_Player_CurrentPowerUp	; \ If Mario is small, kill him
	BEQ.b Kill
	CMP.b #$02			; \ Branch if not Caped Mario
	BNE.b PowerDown
	LDA.w !RAM_SMW_Player_CapeFlyingPhase	; \ Branch if not soaring
	BEQ.b PowerDown
	LDY.b #!Define_SMW_Sound1DF9_HurtWhileFlying				;\ Glitch: While this doesn't cause problems in the original SMW, the fact that this affects Y instead of A may causes problems in custom code.
	STY.w !RAM_SMW_IO_SoundCh1						;/
	LDA.b #$01			; | (Set spin jump flag)
	STA.w !RAM_SMW_Player_SpinJumpFlag
	LDA.b #$30			; | (Set flashing timer)
	STA.w !RAM_SMW_Timer_PlayerHurt
	BRA.b CODE_00F622

PowerDown:
	LDY.b #!Define_SMW_Sound1DF9_IntoPipe					;\ Glitch: While this doesn't cause problems in the original SMW, the fact that this affects Y instead of A may causes problems in custom code.
	STY.w !RAM_SMW_IO_SoundCh1						;/
	JSL.l SMW_DropReservedItem_Main	; Drop reserved item from box
	LDA.b #!Define_SMW_PlayerState01_PowerDown	; \ Set power down animation
	STA.b !RAM_SMW_Player_CurrentState
	STZ.b !RAM_SMW_Player_CurrentPowerUp	; Mario status = Small
	LDA.b #$2F			;\ set hurt frame timer, lock sprites, etc, for a shortish amount of time
	BRA.b SetHurtAnimationTimer	;/

Kill:
;$00F606
	; Death Subroutine (JSL to it to kill Mario). $00F607 controls the speed at
	; which the player jumps up ($7E007D format). $00F60B controls which music
	; is played when Mario dies. $00F619 can be changed from 0D 14 to 12 14 to
	; make the screen not scroll when the player loses a life. $00F61C controls
	; the amount of time Mario stays on screen before dying. *note that if
	; Mario Falls into a hole, the rom will JSL to $00F60A to skip the death
	; animation
	LDA.b #$90			; \ Mario Y speed = #$90
	STA.b !RAM_SMW_Player_YSpeed
PitFall:
	LDA.b #!Define_SMW_LevelMusic_MarioDied
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	LDA.b #$FF			;\
	STA.w !RAM_SMW_Misc_MusicRegisterBackup	;/ change music some more
	LDA.b #!Define_SMW_PlayerState09_Death	; \ Animation sequence = Kill Mario
	STA.b !RAM_SMW_Player_CurrentState
	STZ.w !RAM_SMW_Player_SpinJumpFlag	; Spin jump flag = 0
	LDA.b #$30
SetHurtAnimationTimer:
	STA.w !RAM_SMW_Player_AnimationTimer	; Set hurt frame timer
	STA.b !RAM_SMW_Flag_SpritesLocked	; set lock sprite timer
CODE_00F622:
	STZ.w !RAM_SMW_Player_CapeFlyingPhase	; Cape status = 0
	STZ.w !RAM_SMW_UnusedRAM_7E188A				; Optimization: This is unused
Return:
	RTL

KillAndDisableButtons:
;$00F629
	JSL.l SMW_DamagePlayer_Kill	; Kill Mario.
DisableButtons:
	STZ.b !RAM_SMW_IO_ControllerHold1	; Zero RAM mirrors for controller Input
	STZ.b !RAM_SMW_IO_ControllerPress1
	STZ.b !RAM_SMW_IO_ControllerHold2
	STZ.b !RAM_SMW_IO_ControllerPress2
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PlayerState09_Death(Address)
namespace SMW_PlayerState09_Death
%InsertMacroAtXPosition(<Address>)

UNK_00D0AE:
	db $7C,$00,$80,$00,$00,$06,$00,$01

; Routine to handle the player's death animation ($71 = 09).
Main:
	STZ.b !RAM_SMW_Player_CurrentPowerUp	; Set powerup to 0
	LDA.b #$3E
	STA.w !RAM_SMW_Player_CurrentPose	; / Set Mario image to death image
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03			; |Decrease "Death fall timer" every four frames
	BNE.b CODE_00D0C6
	DEC.w !RAM_SMW_Player_AnimationTimer
CODE_00D0C6:
	LDA.w !RAM_SMW_Player_AnimationTimer	; \ If Death fall timer isn't #$00,
	BNE.b DeathNotDone		; / branch to $D108
	LDA.b #$80			;\ exit level without activating any events
	STA.w !RAM_SMW_Misc_ExitLevelAction	;/
	LDA.w !RAM_SMW_Flag_PreventYoshiCarryOver	;\ keep reserve item if this flag = 01
	BNE.b CODE_00D0D8		;/
	; Set 9C C1 0D to EA EA EA in order to not lose Yoshi on the OW when you
	; fall down a pit when on top of Yoshi.
	STZ.w !RAM_SMW_Yoshi_CarryOverLevelsFlag	; Set reserve item to 0
; ASM that handles losing lives. Change to [EA EA EA] to not lose a life
; after dying. Change to [80 03 EA] to always go to the Game Over screen
; when dying.
CODE_00D0D8:
	DEC.w !RAM_SMW_Player_CurrentLifeCount	; Decrease amount of lifes
	BPL.b DeathNotGameOver		; If not Game Over, branch to $D0E6
	LDA.b #!Define_SMW_LevelMusic_GameOver
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	LDX.b #SMW_DrawLoadingLetters_TileData_TopTiles_OVER-SMW_DrawLoadingLetters_TileData	; Set X (Death message) to x14 (Game Over)
	BRA.b DeathShowMessage

DeathNotGameOver:
	LDY.b #!Define_SMW_GameMode0B_FadeOutToOverworld	; Set Y (game mode) to x0B (Fade to overworld)
	LDA.w !RAM_SMW_Counter_TimerHundreds						;\ Glitch: If the player dies when the timer is 0, then the time up message will display even if the timer was initially set to 000 on level load.
	ORA.w !RAM_SMW_Counter_TimerTens						;|
	ORA.w !RAM_SMW_Counter_TimerOnes						;|
	; ASM that handles the 'TIME UP!' message. Change 'D0' to '80' to disable
	; it.
	BNE.b DeathNotTimeUp								;/
	LDX.b #SMW_DrawLoadingLetters_TileData_TopTiles_UP-SMW_DrawLoadingLetters_TileData	; Set X (Death message) to x1D (Time Up)
DeathShowMessage:
	STX.w !RAM_SMW_Misc_DeathMessageToDisplay	; Store X in Death message
	; Controls timer for TIME UP/GAME OVER message. Change $00D0F9 from C0 to
	; 00 to remove the animation, and change $00D0FE from FF to whatever you
	; want to shorten the timer (however, 00 is as long as FF; 01 is the
	; shortest).
	LDA.b #$C0			; \ Set Death message animation to xC0
	STA.w !RAM_SMW_Timer_DisplayDeathMessageAnimation	; /(Must be divisable by 4)
	LDA.b #$FF			; \ Set Death message timer to xFF
	STA.w !RAM_SMW_Timer_TimeToDisplayDeathMessage
	LDY.b #!Define_SMW_GameMode15_FadeOutToDeathMessage	; Set Y (game mode) to x15 (Fade to Game Over)
DeathNotTimeUp:
	STY.w !RAM_SMW_Misc_GameMode	; Store Y in Game Mode
	RTS

DeathNotDone:
	CMP.b #$26			; \ If Death fall timer >= x26,
	BCS.b DeathNotDoneEnd		; / return
	STZ.b !RAM_SMW_Player_XSpeed	; Set Mario X speed to 0
	JSR.w SMW_UpdatePlayerSpritePosition_Main
	JSR.w SMW_HandlePlayerPhysics_CODE_00D92E
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	LSR				; |Flip death image every four frames
	AND.b #$01
	; Change [85] to [60] and Mario will not flip X-wise when he dies.
	STA.b !RAM_SMW_Player_FacingDirection
DeathNotDoneEnd:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_SetPlayerPose(Address)
namespace SMW_SetPlayerPose
%InsertMacroAtXPosition(<Address>)

DATA_00CE79:
	db $2A,$2B,$2C,$2D,$2E,$2F

DATA_00CE7F:
	db $2C,$2C,$2C,$2B,$2B,$2C,$2C,$2B
	db $2B,$2C,$2D,$2A,$2A,$2D,$2D,$2A
	db $2A,$2D,$2D,$2A,$2A,$2D,$2E,$2A
	db $2A,$2E

; Spin Jump frame table (00 00 - Mario Standing - Small - Big) (25 44 -
; Mario Back to Screen - Small - Big) (00 00 - Same as first) (0F 45 - Mario
; Facing Screen - Small - Big) They are indexed by the frame counter.
;
; Spin Jump frame table ($00CE99-$00CE9A: 00 00 - Mario Standing - Small -
; Big) ($00CE9B-$00CE9C: 25 44 - Mario Back to Screen - Small - Big)
; ($00CE9D-$00CE9E: 00 00 - Same as first) ($00CE9F-$00CEA0: 0F 45 - Mario
; Facing Screen - Small - Big) They are indexed by the frame counter. Change
; the 4th and 8th bytes - 44 and 45 - for 25 and 0F respectively to fix an
; oversight in which Cape Mario doesn't load its tilemap data when spin
; jumping and cape attacking.
DATA_00CE99:
	db $00,$00,$25,$44,$00,$00,$0F,$45

; Spinjump direction table.
DATA_00CEA1:
	db $00,$00,$00,$00,$01,$01,$01,$01

; Cape spin cape image table. These are run while spin jumping with a cape
; or doing a spin attack. Only these four cape images ($02,$07,$06,$09) seem
; to work with cape contact, and will only work if RAM $14A6 is above zero.
DATA_00CEA9:
	db $02,$07,$06,$09,$02,$07,$06,$09

; The code that updates the player and cape poses, and sets them to $13E0
; and $13DF. It also updates certain other related things such as flipping
; mario's direction when spinjumping.
Main:
	LDA.w !RAM_SMW_Timer_CapeFlapAnimation	; Related to cape animation?
	BNE.b lbl14A2Not0
	LDX.w !RAM_SMW_Player_CapeImage	; Cape image
	LDA.b !RAM_SMW_Player_InAirFlag	; If Mario isn't in air, branch to $CEDE
	BEQ.b MarioAnimAir		; branch to $CEDE
	LDY.b #$04
	BIT.b !RAM_SMW_Player_YSpeed	; \ If Mario is falling (and thus not on ground)
	BPL.b CODE_00CECD		; / branch down
	CMP.b #$0C			; \ If making a "run jump",
	BEQ.b CODE_00CEFD		; / branch to $CEFD
	LDA.b !RAM_SMW_Player_SwimmingFlag	; \ If Mario is in water,
	BNE.b CODE_00CEFD		; |branch to $CEFD
	BRA.b MrioNtInWtr		; / otherwise, branch to $CEE4

CODE_00CECD:
	INX
	CPX.b #$05			; |if X >= #$04 and != #$FF then jump down <- counting the INX
	BCS.b CODE_00CED6
	LDX.b #$05			; X = #$05
	BRA.b CODE_00CF0A		; Branch to $CF04

CODE_00CED6:
	CPX.b #$0B			; \ If X is less than #$0B,
	BCC.b CODE_00CF0A		; / branch to $CF0A
	LDX.b #$07			; X = #$07
	BRA.b CODE_00CF0A		; Mario is not in the air, branch to $CF0A

MarioAnimAir:
	LDA.b !RAM_SMW_Player_XSpeed	; \ If Mario X speed isn't 0,
	BNE.b CODE_00CEF0		; / branch to $CEF0
	LDY.b #$08			; Otherwise Y = #$08
MrioNtInWtr:
	TXA				; A = X = #13DF
	BEQ.b CODE_00CF0A		; If $13DF (now A) = 0 branch to $CF04
	DEX
	CPX.b #$03			; |If X - 1 < #$03 Then Branch $CF04
	BCC.b CODE_00CF0A
	LDX.b #$02			; X = #$02
	BRA.b CODE_00CF0A		; Branch to $CF04

CODE_00CEF0:
	BPL.b CODE_00CEF5
	EOR.b #$FF			; |A = abs(A)
	INC
CODE_00CEF5:
	LSR
	LSR				; |Divide a by 8
	LSR
	TAY				; Y = A
	LDA.w AnimationSpeedTable,y	; A = Mario animation speed? (I didn't know it was a table...)
	TAY				; Load Y with this table
CODE_00CEFD:
	INX
	CPX.b #$03
	BCS.b CODE_00CF04		; |If X is < #$02 and != #$FF <- counting the INX
	LDX.b #$05			; |then X = #$05
CODE_00CF04:
	CPX.b #$07
	BCC.b CODE_00CF0A		; |If X is greater than or equal to #$07 then X = #$03
	LDX.b #$03
CODE_00CF0A:
	STX.w !RAM_SMW_Player_CapeImage	; And X goes right back into $13DF (cape image) after being modified
	TYA				; Now Y goes back into A
	LDY.b !RAM_SMW_Player_SwimmingFlag
	BEQ.b CODE_00CF13		; |If mario is in water then A = 2A
	ASL
CODE_00CF13:
	STA.w !RAM_SMW_Timer_CapeFlapAnimation	; A -> $14A2 (do we know this byte yet?) no.
lbl14A2Not0:
	LDA.w !RAM_SMW_Player_SpinJumpFlag	; A = Spin Jump Flag
	ORA.w !RAM_SMW_Timer_ActiveCapeSpin
	BEQ.b CODE_00CF4E		; If $140D OR $14A6 = 0 then branch to $CF4E
	STZ.b !RAM_SMW_Player_DuckingFlag	; 0 -> Ducking while jumping flag
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$06			; |X = Y = Alternate frame counter AND #$06
	TAX
	TAY
	LDA.b !RAM_SMW_Player_InAirFlag	; \ If on ground branch down
	BEQ.b CODE_00CF2F
	LDA.b !RAM_SMW_Player_YSpeed	; \ If Mario moving upwards branch down
	BMI.b CODE_00CF2F
	INY				; Y = Y + 1
CODE_00CF2F:
	LDA.w DATA_00CEA9,y		; \ After loading from this table,
	STA.w !RAM_SMW_Player_CapeImage	; / Store A in cape image
	LDA.b !RAM_SMW_Player_CurrentPowerUp	; A = Mario's powerup status
	BEQ.b CODE_00CF3A
	INX				; |If not small, increase X
CODE_00CF3A:
	LDA.w DATA_00CEA1,x		; \ Load from another table
	STA.b !RAM_SMW_Player_FacingDirection	; / store to Mario's Direction
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	CPY.b #$02
	BNE.b CODE_00CF48		; |If Mario has cape, JSR
	JSR.w SMW_InitializeCapeSwingOrNetPunch_Main	; |to possibly the graphics handler
CODE_00CF48:
	LDA.w DATA_00CE99,x		; \ Load from a table again
	JMP.w CODE_00D01A		; / And jump

CODE_00CF4E:
	LDA.w !RAM_SMW_Player_SlidingOnGround	; \ If $13ED is #$01 - #$7F then
	BEQ.b CODE_00CF62		; |branch to $CF85
	BPL.b CODE_00CF85
	LDA.w !RAM_SMW_Player_SlopePlayerIsOn1
	LSR
	LSR
	ORA.b !RAM_SMW_Player_FacingDirection
	TAY
	LDA.w DATA_00CE7F,y
	BRA.b CODE_00CF85

CODE_00CF62:
	LDA.b #$3C			; \ Select Case $148F
	LDY.w !RAM_SMW_Player_CarryingSomethingFlag2	; |Case 0:A = #$3C
	BEQ.b CODE_00CF6B		; |Case Else: A = #$1D
	LDA.b #$1D			; |End Select
CODE_00CF6B:
	LDY.b !RAM_SMW_Player_DuckingFlag	; \ If Ducking while jumping
	BNE.b CODE_00CF85		; / Branch to $CF85
	LDA.w !RAM_SMW_Timer_DisplayPlayerShootFireballPose	; \ If (Unknown) = 0
	BEQ.b CODE_00CF7E		; / Branch to $CF7E
	LDA.b #$3F			; A = #$3F
	LDY.b !RAM_SMW_Player_InAirFlag	; \ If Mario isn't in air,
	BEQ.b CODE_00CF85		; |branch to $CF85
	LDA.b #$16			; |Otherwise, set A to #$16 and
	BRA.b CODE_00CF85		; / branch to $CF85

CODE_00CF7E:
	LDA.b #$0E			; A = #$0E
	LDY.w !RAM_SMW_Timer_DisplayPlayerKickingPose	; \ If Time to show Mario's current pose is 00,
	BEQ.b CODE_00CF88		; | Don't jump to $D01A
CODE_00CF85:
	JMP.w CODE_00D01A

CODE_00CF88:
	LDA.b #$1D			; A = #$1D
	LDY.w !RAM_SMW_Timer_DisplayPlayerPickUpPose	; \ If $1499 != 0 then Jump to $D01A
	BNE.b CODE_00CF85
	LDA.b #$0F			; A = #$0F
	LDY.w !RAM_SMW_Timer_DisplayPlayerFaceScreenPose	; \ If $1499 != 0 then Jump to $D01A
	BNE.b CODE_00CF85
	LDA.b #$00			; A = #$00
	LDX.w !RAM_SMW_Flag_PlayerInLakitusCloud	; X = $18C2 (Unknown)
	BNE.b MarioAnimNoAbs1		; If X != 0 then branch down
	LDA.b !RAM_SMW_Player_InAirFlag	; \ If Mario is flying branch down
	BEQ.b CODE_00CFB7
	LDY.w !RAM_SMW_Timer_ShowRunningFramesBeforeTakeOff	; \ If $14A0 != 0 then
	BNE.b CODE_00CFBC		; / Skip down
	LDY.w !RAM_SMW_Player_CapeFlyingPhase	; Spaghetticode(tm)
	BEQ.b CODE_00CFAE
	LDA.w DATA_00CE79-$01,y
CODE_00CFAE:
	LDY.w !RAM_SMW_Player_CarryingSomethingFlag2	; \ If Mario isn't holding something,
	BEQ.b CODE_00D01A		; |branch to $D01A
	LDA.b #$09			; |Otherwise, set A to #$09 and
	BRA.b CODE_00D01A		; / branch to $D01A

CODE_00CFB7:
	LDA.w !RAM_SMW_Player_TurningAroundFlag
	BNE.b CODE_00D01A
CODE_00CFBC:
Entry2:
	LDA.b !RAM_SMW_Player_XSpeed
	BPL.b MarioAnimNoAbs1
	EOR.b #$FF			; |Set A to absolute value of Mario's X speed
	INC
MarioAnimNoAbs1:
	TAX				; Copy A to X
	BNE.b CODE_00CFD4		; If Mario isn't standing still, branch to $CFD4
	XBA				; "Push" A
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #!Joypad_DPadU>>8		; |If player isn't pressing up,
	; Change from [F0] to [80] to disable looking up.
	BEQ.b CODE_00D002		; |branch to $D002
	LDA.b #$03			; |Otherwise, store x03 in $13DE and
	STA.w !RAM_SMW_Player_OverrideWalkingFrames	; |branch to $D002
	BRA.b CODE_00D002

CODE_00CFD4:
	LDA.b !RAM_SMW_Flag_IceLevel	; \ If level isn't slippery,
	BEQ.b CODE_00CFE3		; / branch to $CFE3
	LDA.b !RAM_SMW_IO_ControllerHold1	;\
	AND.b #(!Joypad_DPadR>>8)|(!Joypad_DPadL>>8)	;| if Left/Right not held, branch
	BEQ.b CODE_00D003		;/
	LDA.b #$68			;\ relates to running speed...
	STA.w !RAM_SMW_Player_AnimationSpeedIndex	;/
CODE_00CFE3:
	LDA.w !RAM_SMW_Player_WalkingFrame	; A = $13DB
	LDY.w !RAM_SMW_Player_AnimationTimer	; \ If Mario is hurt (flashing),
	BNE.b CODE_00D003		; / branch to $D003
	DEC				; A = A - 1
	BPL.b CODE_00CFF3		; \If bit 7 is clear,
	LDY.b !RAM_SMW_Player_CurrentPowerUp	; | Load amount of walking frames
	LDA.w WalkingPoseCount,y	; | for current powerup
CODE_00CFF3:
	XBA				; \ >>-This code puts together an index to a table further down-<<
	TXA				; |-\ Above Line: "Push" frame amount
	LSR				; |  |A = X / 8
	LSR				; |  |
	LSR
	ORA.w !RAM_SMW_Player_AnimationSpeedIndex	; |ORA with $13E5
	TAY				; |And store A to Y
	LDA.w AnimationSpeedTable,y
	STA.w !RAM_SMW_Player_AnimationTimer
CODE_00D002:
	XBA				; \ Switch in frame amount and store it to $13DB
CODE_00D003:
	STA.w !RAM_SMW_Player_WalkingFrame
	CLC				; \ Add walking animation type
	ADC.w !RAM_SMW_Player_OverrideWalkingFrames	; / (Walking, running...)
	LDY.w !RAM_SMW_Player_CarryingSomethingFlag2
	BEQ.b CODE_00D014
	CLC				; |If Mario is carrying something, add #$07
	ADC.b #$07
	BRA.b CODE_00D01A

CODE_00D014:
if ver_is_pal(!Define_Global_ROMToAssemble)
	CPX.b #$3A
else
	CPX.b #$2F
endif
	BCC.b CODE_00D01A		; |If X is greater than #$2F, add #$04
	ADC.b #$03			; / <-Carry is always set here, adding #$01 to (#$03 + A)
CODE_00D01A:
	LDY.w !RAM_SMW_Player_WallWalkStatus	; \ If Mario isn't rotated 45 degrees (triangle
	BEQ.b MarioAnimNo45		; / block), branch to $D030
	TYA				; \ Y AND #$01 -> Mario's Direction RAM Byte
	AND.b #$01
	STA.b !RAM_SMW_Player_FacingDirection
	LDA.b #$10
	CPY.b #$06			; |If Y < 6 then
	BCC.b MarioAnimNo45		; |    A = #13DB + $11
	LDA.w !RAM_SMW_Player_WalkingFrame	; |Else
	CLC				; |    A = #$10
	ADC.b #$11			; |End If
MarioAnimNo45:
	STA.w !RAM_SMW_Player_CurrentPose	; Store in Current animation frame
	RTL				; And Finish
namespace off
endmacro

macro ROUTINE_RT01_SMW_SetPlayerPose(Address)
namespace SMW_SetPlayerPose
%InsertMacroAtXPosition(<Address>)

; Number of animation frames to use for walking/running Mario, indexed by
; Mario's status. Ex: db $01,$02,$02,$02 The first byte it for small Mario,
; next is Super (Big) Mario, then Cape Mario, and finally Fire Mario. $01
; means 2 frames for small Mario and $02 means 3 frames for the others.
; Longer animations are possible, but that'd require moving stuff around in
; $13E0, which hasn't been researched yet.
WalkingPoseCount:
	db $01,$02,$02,$02

AnimationSpeedTable:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	db $09,$08,$06,$05,$04,$03,$03,$02
	db $09,$08,$06,$05,$04,$03,$03,$02
	db $09,$08,$06,$05,$04,$03,$03,$02
	db $07,$06,$05,$04,$03,$03,$02,$01
	db $07,$06,$05,$04,$03,$03,$02,$01
	db $05,$04,$04,$03,$03,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $04,$03,$03,$02,$02,$01,$01,$01
	db $04,$03,$03,$02,$02,$01,$01,$01
	db $02,$02,$02,$02,$02,$02,$02,$02
elseif ver_is_pal_rev0(!Define_Global_ROMToAssemble)
	db $0A,$08,$07,$06,$05,$04,$03,$02
	db $0A,$08,$07,$06,$05,$04,$03,$02
	db $0A,$08,$07,$06,$05,$04,$03,$02
	db $08,$07,$06,$05,$04,$03,$02,$01
	db $08,$07,$06,$05,$04,$03,$02,$01
	db $05,$04,$04,$03,$03,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $05,$04,$03,$03,$02,$02,$01,$01
	db $04,$03,$03,$02,$02,$01,$01,$01
	db $04,$03,$03,$02,$02,$01,$01,$01
	db $02,$02,$02,$02,$02,$02,$02,$02
else
	; Animation rates for both Mario's run animation and his cape animation (as
	; it's flapping in the "wind" from running). Indexed by the absolute value
	; of Mario's X speed divided by 8, plus $13E5 (which holds a multiple of
	; 8). Index = |MarioXSpeed| / 8 + $13E5
	db $0A,$08,$06,$04,$03,$02,$01,$01	;!
	db $0A,$08,$06,$04,$03,$02,$01,$01	;!
	db $0A,$08,$06,$04,$03,$02,$01,$01	;!
	db $08,$06,$04,$03,$02,$01,$01,$01	;!
	db $08,$06,$04,$03,$02,$01,$01,$01	;!
	db $05,$04,$03,$02,$01,$01,$01,$01	;!
	db $05,$04,$03,$02,$01,$01,$01,$01	;!
	db $05,$04,$03,$02,$01,$01,$01,$01	;!
	db $05,$04,$03,$02,$01,$01,$01,$01	;!
	db $05,$04,$03,$02,$01,$01,$01,$01	;!
	db $05,$04,$03,$02,$01,$01,$01,$01	;!
	db $04,$03,$02,$01,$01,$01,$01,$01	;!
	db $04,$03,$02,$01,$01,$01,$01,$01	;!
	db $02,$02,$02,$02,$02,$02,$02,$02	;!
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandlePlayerLevelCollision(Address)
namespace SMW_HandlePlayerLevelCollision
%InsertMacroAtXPosition(<Address>)

DATA_00E90A:
	db $01,$02,$11

DATA_00E90D:
	db $FF,$FF,$01,$00

DATA_00E911:
	db $02,$0D

; Table of X speeds that conveyors push Mario with. Each 16 bit value refers
; to one type of conveyor: - $0001: flat right. - $FFFF: flat left. - $0001:
; up right. - $0001: down right. - $FFFF: up left. - $FFFF: down left.
DATA_00E913:
	db $01,$00,$FF,$FF,$01,$00,$01,$00
	db $FF,$FF,$FF,$FF

; Table of Y speeds that conveyors push Mario with. Each 16 bit value refers
; to one type of conveyor: - $0000: flat right. - $0000: flat left. - $FFFF:
; up right. - $0001: down right. - $FFFF: up left. - $0001: down left.
DATA_00E91F:
	db $00,$00,$00,$00,$FF,$FF,$01,$00
	db $FF,$FF,$01,$00

Main:
	JSR.w SMW_ResetPlayerLevelCollisionRAM_Main
	LDA.w !RAM_SMW_Player_DisableObjectInteractionFlag
	BEQ.b CODE_00E938
	JSR.w SMW_RunPlayerBlockCode_CODE_00EE1D
	BRA.b CODE_00E98C

; Code that handles player interaction with layer 1 and 2/3, if enabled.
; $00E944-$00E975 specifically handles layer 2/3 interaction, while
; $00E97B-$00E98B handles Layer 1.
CODE_00E938:
	LDA.w !RAM_SMW_Player_OnGroundFlag
	STA.b !RAM_SMW_Misc_ScratchRAM8D
	STZ.w !RAM_SMW_Player_OnGroundFlag
	LDA.b !RAM_SMW_Player_InAirFlag	;\Backup the airflag to scratch RAM $8F.
	STA.b !RAM_SMW_Misc_ScratchRAM8F	;/
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	BPL.b CODE_00E978
	AND.b #$82
	STA.b !RAM_SMW_Misc_ScratchRAM8E
	LDA.b #$01			;\ process layer 1
	STA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo	;/
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo	;\
	CLC				;|
	ADC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo	;|
	STA.b !RAM_SMW_Player_XPosLo	;|
	LDA.b !RAM_SMW_Player_YPosLo	;|update mario's position, with what I do not know
	CLC				;|
	ADC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo	;|
	STA.b !RAM_SMW_Player_YPosLo	;/
	SEP.b #$20			; A->8
	JSR.w SMW_RunPlayerBlockCode_Main
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo
	STA.b !RAM_SMW_Player_XPosLo
	LDA.b !RAM_SMW_Player_YPosLo
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo
	STA.b !RAM_SMW_Player_YPosLo
	SEP.b #$20			; A->8
CODE_00E978:
	ASL.w !RAM_SMW_Player_OnGroundFlag
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.b #$41
	STA.b !RAM_SMW_Misc_ScratchRAM8E
	ASL
	BMI.b CODE_00E98C
	STZ.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	ASL.b !RAM_SMW_Misc_ScratchRAM8D
	JSR.w SMW_RunPlayerBlockCode_Main
CODE_00E98C:
	LDA.w !RAM_SMW_Flag_SideExits	;\If side exit is false, branch
	BEQ.b NoSideExit		;/to solid sided screen border.
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_OnScreenPosXLo	;\If mario's x pos on-screen is left
	CMP.w #$00FA			;/from #$00FA (near the right edge of screen)
	SEP.b #$20			; A->8
	BCC.b CODE_00E9FB
	JSL.l SMW_DisplayMessage_ExitToOverworldNoEvent
	RTS

NoSideExit:
	LDA.b !RAM_SMW_Player_OnScreenPosXLo	;\If mario is much far to the right of the screen
	CMP.b #$F0			;|(position 1 block left from right edge), branch
	BCS.b CODE_00EA08		;/
	LDA.b !RAM_SMW_Player_BlockedFlags	;\Left/Right blocked status
	AND.b #$03			;|
	BNE.b CODE_00E9FB		;/
	REP.b #$20			; A->16
	LDY.b #$00			;>default Y = #$00
	LDA.w !RAM_SMW_Misc_Layer1XPosLo	;\ScreenPosLvl + #$00E8 and compare with Mario's x pos in level;
	CLC				;|The right border position, where Mario cannot be less than 8
	ADC.w #$00E8			;|pixels from right edge of screen
	CMP.b !RAM_SMW_Player_XPosLo	;/
	BEQ.b CODE_00E9C8		;\If at or below, branch (BMI branches only less than)
	BMI.b CODE_00E9C8		;/
	INY				;>Switch index to #$01
	LDA.b !RAM_SMW_Player_XPosLo	;\The left border position, where mario cannot be less than 8 pixels
	SEC				;|away from left edge of screen.
	SBC.w #$0008			;|
	CMP.w !RAM_SMW_Misc_Layer1XPosLo	;/
CODE_00E9C8:
	SEP.b #$20			; A->8
	BEQ.b CODE_00E9FB		;\Um Nintendo, you don't need a BEQ since BPL branches when A
	BPL.b CODE_00E9FB		;/is more than OR EQUAL to.
	LDA.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting	;\If horizontal scroll enabled, branch
	BNE.b CODE_00E9F6		;/
	LDA.b #$80			;\Set bit 7 of blocked status (the bit that indicates if you
	TSB.b !RAM_SMW_Player_BlockedFlags	;/are touching sides of screen).
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_L1ScrollSpr_XSpeedLo	;\Speed of which the screen scrolls
	LSR				;|
	LSR				;|
	LSR				;|
	LSR				;/
	SEP.b #$20			; A->8
	STA.b !RAM_SMW_Misc_ScratchRAM00	;\Make mario move with the screen when level scrolls.
	SEC				;|(rather than storing directly to $7E0094, have momentum
	SBC.b !RAM_SMW_Player_XSpeed	;|from screen)
	EOR.w DATA_00E90D+$01,y		;|
	BMI.b CODE_00E9F6		;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;|
	STA.b !RAM_SMW_Player_XSpeed	;/
	LDA.w !RAM_SMW_L1ScrollSpr_SubXPosLo	;\Some extra bits of the scrolling screen speed to store
	STA.w !RAM_SMW_Player_SubXPos	;/to fraction bits of player's x speed.
CODE_00E9F6:
	LDA.w DATA_00E90A,y		;\Set blocked status depending on which side of screen
	TSB.b !RAM_SMW_Player_BlockedFlags	;/
CODE_00E9FB:
	LDA.b !RAM_SMW_Player_BlockedFlags
	AND.b #$1C
	CMP.b #$1C
	BNE.b CODE_00EA0D
	LDA.w !RAM_SMW_Misc_PlayerOnSolidSprite
	BNE.b CODE_00EA0D
; Change [20 29 F6] to [EA EA EA] (JSR $F629 to NOP NOP NOP) to prevent the
; player from getting killed when stuck in a block, such as a cement block.
; Instead, they will get thrown downwards.
CODE_00EA08:
	JSR.w SMW_DamagePlayer_KillAndDisableButtons	;>Kill player if attempt to go off screen or crushed in blocks.
	BRA.b CODE_00EA32

CODE_00EA0D:
	LDA.b !RAM_SMW_Player_BlockedFlags	;\If left and right not block, branch
	AND.b #$03			;|
	BEQ.b CODE_00EA34		;/
	AND.b #$02			;>Leave left bit not changed
	TAY				;>Transfer to Y
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo	;\Move mario
	CLC				;|
	ADC.w DATA_00E90D,y		;|
	STA.b !RAM_SMW_Player_XPosLo	;/
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Player_BlockedFlags	;\If Mario touching edge of screen
	BMI.b CODE_00EA34		;/
	LDA.b #$03			;\Frame change animation timer
	STA.w !RAM_SMW_Player_AnimationSpeedIndex	;/
	LDA.b !RAM_SMW_Player_XSpeed
	EOR.w DATA_00E90D,y
	BPL.b CODE_00EA34
CODE_00EA32:
	STZ.b !RAM_SMW_Player_XSpeed
CODE_00EA34:
	LDA.w !RAM_SMW_Player_CurrentLayerPriority
	CMP.b #$01
	BNE.b CODE_00EA42
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	BNE.b CODE_00EA42
	STZ.w !RAM_SMW_Player_CurrentLayerPriority
CODE_00EA42:
	STZ.w !RAM_SMW_Player_CanJumpOutOfWater
	LDA.b !RAM_SMW_Flag_UnderwaterLevel
	BNE.b CODE_00EA5E
	LSR.b !RAM_SMW_Misc_ScratchRAM8A
	BCC.b CODE_00EAA3
	LDA.b !RAM_SMW_Player_SwimmingFlag
	BNE.b CODE_00EA65
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_00EA65
	LSR.b !RAM_SMW_Misc_ScratchRAM8A
	BCC.b Return00EAA5
	JSR.w SMW_SpawnPlayerWaterSplashAndManyBreathBubbles_Main
	STZ.b !RAM_SMW_Player_YSpeed
CODE_00EA5E:
	LDA.b #$01
	STA.b !RAM_SMW_Player_SwimmingFlag
CODE_00EA62:
	JMP.w SMW_SpawnPlayerBreathBubble_Main

CODE_00EA65:
	LSR.b !RAM_SMW_Misc_ScratchRAM8A
	BCS.b CODE_00EA5E
	LDA.b !RAM_SMW_Player_SwimmingFlag
	BEQ.b Return00EAA5
	LDA.b #$FC
	CMP.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_00EA75
	STA.b !RAM_SMW_Player_YSpeed
CODE_00EA75:
	INC.w !RAM_SMW_Player_CanJumpOutOfWater
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #(!Joypad_DPadU>>8)|!Joypad_A|(!Joypad_B>>8)
	CMP.b #(!Joypad_DPadU>>8)|!Joypad_A|(!Joypad_B>>8)
	BNE.b CODE_00EA62
	LDA.b !RAM_SMW_IO_ControllerHold2
	; [10] Change to 80 to disable spin jumping from water
	BPL.b CODE_00EA92
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2
	BNE.b CODE_00EA92
	INC
	STA.w !RAM_SMW_Player_SpinJumpFlag
	LDA.b #!Define_SMW_Sound1DFC_SpinJump	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_00EA92:
	LDA.b !RAM_SMW_Player_BlockedFlags
	AND.b #$08
	BNE.b CODE_00EA62
	JSR.w SMW_SpawnPlayerWaterSplashAndManyBreathBubbles_Main
	LDA.b #$0B
	STA.b !RAM_SMW_Player_InAirFlag
	LDA.b #$AA
	STA.b !RAM_SMW_Player_YSpeed
CODE_00EAA3:
	STZ.b !RAM_SMW_Player_SwimmingFlag
Return00EAA5:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SpawnPlayerWaterSplashAndManyBreathBubbles(Address)
namespace SMW_SpawnPlayerWaterSplashAndManyBreathBubbles
%InsertMacroAtXPosition(<Address>)

; Table of four bytes that are used to determine where the water splash
; sprite Y position for Mario is. Changing $00FD9E from $FC to $00 will fix
; the splash from being one tile above big Mario.
SplashInitialYPosLo:
	db $08,$FC,$10,$04

SplashInitialYPosHi:
	db $00,$FF,$00,$00

Main:
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_00FDB3
	LDY.b #!Define_SMW_MaxMinorExtendedSpriteSlot
CODE_00FDAB:
	LDA.w !RAM_SMW_MExtSpr_SpriteID,y
	BEQ.b CODE_00FDB4
	DEY
	BPL.b CODE_00FDAB
CODE_00FDB3:
	INY
CODE_00FDB4:
	PHX
	LDX.b #$00
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_00FDBC
	INX
CODE_00FDBC:
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_00FDC3
	INX
	INX
CODE_00FDC3:
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.w SplashInitialYPosLo,x
	PHP
	AND.b #$F0
	CLC
	ADC.b #$03
	STA.w !RAM_SMW_MExtSpr_YPosLo,y
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	PLP
	ADC.w SplashInitialYPosHi,x
	STA.w !RAM_SMW_MExtSpr_YPosHi,y
	PLX
	LDA.b !RAM_SMW_Player_XPosLo
	STA.w !RAM_SMW_MExtSpr_XPosLo,y
	LDA.b !RAM_SMW_Player_XPosHi
	STA.w !RAM_SMW_MExtSpr_XPosHi,y
	LDA.b #!Define_SMW_SpriteID_MExtSpr07_WaterSplash
	STA.w !RAM_SMW_MExtSpr_SpriteID,y
	LDA.b #$00
	STA.w !RAM_SMW_MExtSpr_Timer,y
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return00FE0D
	STZ.b !RAM_SMW_Player_YSpeed
	LDY.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_00FDFE
	STZ.b !RAM_SMW_Player_XSpeed
CODE_00FDFE:
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$06
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_00FE05
	DEY
CODE_00FE05:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_00FE16
CODE_00FE0A:
	DEY
	BPL.b CODE_00FE05
Return00FE0D:
	RTS

BubbleInitialYPosLo:
	db $10,$16,$13,$1C

BubbleInitialXPosLo:
	db $00,$04,$0A,$07

CODE_00FE16:
	LDA.b #!Define_SMW_SpriteID_ExtSpr12_BreathBubble	; \ Extended sprite = Water bubble
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	TYA
	ASL
	ASL
	ASL
	ADC.b #$F7
	STA.w !RAM_SMW_ExtSpr12_BreathBubble_AnimationFrameCounter,y
	LDA.b !RAM_SMW_Player_YPosLo
	ADC.w BubbleInitialYPosLo,y
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDA.b !RAM_SMW_Player_XPosLo
	ADC.w BubbleInitialXPosLo,y
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.b !RAM_SMW_Player_XPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	LDA.b #$00
	STA.w !RAM_SMW_ExtSpr_DecrementingTable7E176F,y
	JMP.w CODE_00FE0A
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SpawnPlayerBreathBubble(Address)
namespace SMW_SpawnPlayerBreathBubble
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #$3F
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)|!Joypad_A|(!Joypad_B>>8)
	BNE.b CODE_00FD12
	LDY.b #$7F
CODE_00FD12:
	TYA
	AND.b !RAM_SMW_Counter_LocalFrames
	ORA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return00FD23
	LDX.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_00FD1B:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x
	BEQ.b CODE_00FD26
	DEX
	BPL.b CODE_00FD1B
Return00FD23:
	RTS				; / Return if no free slots

InitialXPosLo:
	db $02,$0A

CODE_00FD26:
	LDA.b #!Define_SMW_SpriteID_ExtSpr12_BreathBubble	; \ Extended sprite = Water buble
	STA.w !RAM_SMW_ExtSpr_SpriteID,x
	LDY.b !RAM_SMW_Player_FacingDirection
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w InitialXPosLo,y
	STA.w !RAM_SMW_ExtSpr_XPosLo,x
	LDA.b !RAM_SMW_Player_XPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_XPosHi,x
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_00FD47
	LDA.b #$04
	LDY.b !RAM_SMW_Player_DuckingFlag
	BEQ.b CODE_00FD49
CODE_00FD47:
	LDA.b #$0C
CODE_00FD49:
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.w !RAM_SMW_ExtSpr_YPosLo,x
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,x
	STZ.w !RAM_SMW_ExtSpr_DecrementingTable7E176F,x
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_ResetPlayerLevelCollisionRAM(Address)
namespace SMW_ResetPlayerLevelCollisionRAM
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Player_AnimationSpeedIndex
	STZ.b !RAM_SMW_Player_BlockedFlags
	STZ.w !RAM_SMW_Player_SlopePlayerIsOn1
	STZ.w !RAM_SMW_Player_SlopePlayerIsOn2
	STZ.b !RAM_SMW_Misc_ScratchRAM8A
	STZ.b !RAM_SMW_Misc_ScratchRAM8B
	STZ.w !RAM_SMW_Sprites_Layer2IsTouchedFlag
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_RunPlayerBlockCode(Address)
namespace SMW_RunPlayerBlockCode
%InsertMacroAtXPosition(<Address>)

DATA_00EAB9:
if ver_is_pal(!Define_Global_ROMToAssemble)
	db $D6,$2B
else
	db $DE,$23			;!
endif

DATA_00EABB:
	db $20,$E0

DATA_00EABD:
	db $08,$00,$F8,$FF

; Table of which slope tiles on Map16 page 1 are in water.
WaterSlopeMap16Numbers:
	db $71,$72,$76,$77,$7B,$7C,$81,$86
	db $8A,$8B,$8F,$90,$94,$95,$99,$9A
	db $9E,$9F,$A3,$A4,$A8,$A9,$AD,$AE
	db $B2,$B3

Main:
;$00EADB
	LDA.b !RAM_SMW_Player_YPosLo
	AND.b #$0F
	STA.b !RAM_SMW_Player_YPosInBlock
	LDA.w !RAM_SMW_Player_WallWalkStatus
	BNE.b CODE_00EAE9
	JMP.w CODE_00EB77

CODE_00EAE9:
	AND.b #$01
	TAY
	LDA.b !RAM_SMW_Player_XSpeed
	SEC
	SBC.w DATA_00EAB9,y
	EOR.w DATA_00EAB9,y
	BMI.b CODE_00EB48
	LDA.b !RAM_SMW_Player_InAirFlag
	ORA.w !RAM_SMW_Player_CarryingSomethingFlag2
	ORA.b !RAM_SMW_Player_DuckingFlag
	ORA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b CODE_00EB48
	LDA.w !RAM_SMW_Player_WallWalkStatus
	CMP.b #$06
	BCS.b CODE_00EB22
	LDX.b !RAM_SMW_Player_YPosInBlock
	CPX.b #$08
	BCC.b Return00EB76
	CMP.b #$04
	BCS.b CODE_00EB73
	ORA.b #$04
	STA.w !RAM_SMW_Player_WallWalkStatus
CODE_00EB19:
	LDA.b !RAM_SMW_Player_XPosLo
	AND.b #$F0
	ORA.b #$08
	STA.b !RAM_SMW_Player_XPosLo
	RTS

CODE_00EB22:
	LDX.b #$60
	TYA
	BEQ.b CODE_00EB29
	LDX.b #$66
CODE_00EB29:
	JSR.w CODE_00EFE8
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BNE.b CODE_00EB34
	INX
	INX
	BRA.b CODE_00EB37

CODE_00EB34:
	JSR.w CODE_00EFE8
CODE_00EB37:
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_WallRun	;>Run player collision points (interact with layer (WallRun offset))
	BNE.b CODE_00EB19
	LDA.b #$02
	TRB.w !RAM_SMW_Player_WallWalkStatus
	RTS

ADDR_00EB42:
	LDA.w !RAM_SMW_Player_WallWalkStatus
	AND.b #$01
	TAY
CODE_00EB48:
	LDA.w DATA_00EABB,y
	STA.b !RAM_SMW_Player_XSpeed
	TYA
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w DATA_00EABD,y
	STA.b !RAM_SMW_Player_XPosLo
	LDA.w #$0008
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_00EB64
	LDA.w #$0010
CODE_00EB64:
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_Player_YPosLo
	SEP.b #$20			; A->8
	LDA.b #$24
	STA.b !RAM_SMW_Player_InAirFlag
	LDA.b #$E0
	STA.b !RAM_SMW_Player_YSpeed
CODE_00EB73:
	STZ.w !RAM_SMW_Player_WallWalkStatus
Return00EB76:
	RTS

CODE_00EB77:
	LDX.b #$00
	; Change to A9 00 to make Super/Fire/Cape Mario have a 16x16 interaction
	; field (like Small Mario) or change it to A9 01 to have a 16x32
	; interaction field (like big Mario) (in conjunction with addresses $01B4C0
	; and $03B67C)
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_00EB83
	LDA.b !RAM_SMW_Player_DuckingFlag
	BNE.b CODE_00EB83
	LDX.b #$18
CODE_00EB83:
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_00EB8D
	TXA
	CLC
	ADC.b #$30
	TAX
CODE_00EB8D:
	LDA.b !RAM_SMW_Player_XPosLo
	AND.b #$0F
	TAY
	CLC
	ADC.b #$08
	AND.b #$0F
	STA.b !RAM_SMW_Player_XPosInBlock
	STZ.b !RAM_SMW_Player_HorizontalSideOfBlockBeingTouched
	CPY.b #$08
	BCC.b CODE_00EBA5
	TXA
	ADC.b #$0B
	TAX
	INC.b !RAM_SMW_Player_HorizontalSideOfBlockBeingTouched
CODE_00EBA5:
	LDA.b !RAM_SMW_Player_YPosInBlock
	CLC
	ADC.w UnknownData00E8A4,x
	AND.b #$0F
	STA.b !RAM_SMW_Player_VerticalDirectionToPushOutOfBlock
#LMBlockOffset_HeadInside:
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_HeadInside	;>Run player collision points (interact with layer (various, MarioBody?))
	BEQ.b CODE_00EBDD
	CPY.b #$11
	BCC.b CODE_00EC24
	CPY.b #$6E
	BCC.b CODE_00EBC9
	TYA
	JSL.l SMW_CheckForWaterSlope_Main
	BCC.b CODE_00EC24
	LDA.b #$01
	TSB.b !RAM_SMW_Misc_ScratchRAM8A
	BRA.b CODE_00EC24

CODE_00EBC9:
	INX
	INX
	INX
	INX
	TYA
	LDY.b #$00
	CMP.b #$1E
	BEQ.b CODE_00EBDA
	CMP.b #$52
	BEQ.b CODE_00EBDA
	LDY.b #$02
CODE_00EBDA:
	JMP.w CODE_00EC6F

; Door interaction routine. Handles boss doors, normal doors and p-switch
; doors. $00EBDE: The Map16 tile of a door which can be entered from any
; position if touched (used for the large castle door). $00EBE5: The tileset
; where the castle door is enterable. $00EBE9: The Map16 tile number for the
; normal door (independent of power up and p-switch). $00EBED: The Map16
; tile number for the small door (enterable when not big, independent of
; p-switch). $00EBF6: The Map16 tile number for the p-switch door
; (independent of power up, p-switch must be active). $00EBFA: The Map16
; tile number for the small p-switch door (enterable when not big, p-switch
; must be active). $00EBFD: Code that checks Mario's powerup state when
; entering doors. Change to [80 02] (BRA $02) to allow small doors can be
; entered even if Mario is big, and normal doors to be entered even if
; riding Yoshi. $00EC01: Checks whether Mario is centered enough to enter a
; non-boss door. Replace it with [$80,$03] to disable this behaviour.
; $00EC09: Replace it with [$00] to allow doors to be enterable in the air.
; $00EC10: Sound effect to play. $00EC11 (8-bit) is the SFX ID and $00EC13
; (16-bit) is the SFX port. See $7E1DF9 to $7E1DFC for more details Note:
; All the Map16 tiles must be located on page 0.
CODE_00EBDD:
	CPY.b #$9C
	BNE.b CODE_00EBE8
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting
	CMP.b #$01
	BEQ.b CODE_00EC06
CODE_00EBE8:
	CPY.b #$20
	BEQ.b CODE_00EC01
	CPY.b #$1F
	BEQ.b CODE_00EBFD
	LDA.w !RAM_SMW_Timer_BluePSwitch
	BEQ.b CODE_00EC21
	CPY.b #$28
	BEQ.b CODE_00EC01
	CPY.b #$27
	BNE.b CODE_00EC21
CODE_00EBFD:
	LDA.b !RAM_SMW_Player_CurrentPowerUp	;\If mario is big, branch
	BNE.b CODE_00EC24		;/
CODE_00EC01:
	JSR.w CODE_00F443		;>Get some fraction-of block bits (modulo of 16)
	BCS.b CODE_00EC24		;>If on right half of block, branch
CODE_00EC06:
	LDA.b !RAM_SMW_Misc_ScratchRAM8F	;\Some scratch ram (Backup of $72; the air flag, see $00E940).
	BNE.b CODE_00EC24		;/If the player is in the air, don't allow entering.
	LDA.b !RAM_SMW_IO_ControllerPress1	;\If not pressing up, branch
	AND.b #!Joypad_DPadU>>8		;|
	BEQ.b CODE_00EC24		;/
	LDA.b #!Define_SMW_Sound1DFC_Door1	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	JSR.w SMW_IncrementSublevelsEnteredAndPrepareToLoadSublevel_Main	;>Load another level
	LDA.b #!Define_SMW_PlayerState0D_DoAbsolutelyNothing	;\Set animation trigger
	STA.b !RAM_SMW_Player_CurrentState	;/
	JSR.w SMW_DamagePlayer_DisableButtons	;>Clear controls
	BRA.b CODE_00EC24

CODE_00EC21:
	JSR.w CODE_00F28C
CODE_00EC24:
#LMBlockOffset_MarioSide:
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_MarioSide	;>Run player collision points (interact with layer (MarioSide))
	BEQ.b CODE_00EC35
	CPY.b #$11
	BCC.b CODE_00EC3A
	CPY.b #$6E
	BCS.b CODE_00EC3A
	INX
	INX
	BRA.b CODE_00EC4E

CODE_00EC35:
	LDA.b #$10
	JSR.w CODE_00F2C9
CODE_00EC3A:
#LMBlockOffset_BodyInside:
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_BodyInside	;>Run player collision points (interact with layer (MarioHead))
	BNE.b CODE_00EC46
	LDA.b #$08
	JSR.w CODE_00F2C9
	BRA.b CODE_00EC8A

CODE_00EC46:
	CPY.b #$11
	BCC.b CODE_00EC8A
	CPY.b #$6E
	BCS.b CODE_00EC8A
CODE_00EC4E:
	LDA.b !RAM_SMW_Player_FacingDirection
	CMP.b !RAM_SMW_Player_HorizontalSideOfBlockBeingTouched
	BEQ.b CODE_00EC5F
	JSR.w CheckIfEnteringHorizontalPipe
	PHX
	JSR.w CheckIfGrabbingThrowBlock
	LDY.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	; Current MAP16 tile number
	PLX
CODE_00EC5F:
	LDA.b #$03
	STA.w !RAM_SMW_Player_AnimationSpeedIndex
	; Code that makes munchers and spikes not to hurt the player if the
	; player's hitbox on the left or right side of the block is next to them.
	; This essentially reduce the hitbox the block by 1 pixel so that it
	; requires the player to move into them to trigger damage.
	LDY.b !RAM_SMW_Player_HorizontalSideOfBlockBeingTouched
	LDA.b !RAM_SMW_Player_XPosLo
	AND.b #$0F
	CMP.w SMW_HandlePlayerLevelCollision_DATA_00E911,y
	BEQ.b CODE_00EC8A
CODE_00EC6F:
	LDA.w !RAM_SMW_Blocks_NoteBlockBounceFlag
	BEQ.b CODE_00EC7B
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	CMP.b #$52
	BEQ.b CODE_00EC8A
CODE_00EC7B:
	LDA.w SMW_HandlePlayerLevelCollision_DATA_00E90A,y
	TSB.b !RAM_SMW_Player_BlockedFlags
	AND.b #$03
	TAY
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	; Current MAP16 tile number
	JSL.l CheckIfPlayerTouchingHurtBlock_IgnoreYoshi
CODE_00EC8A:
#LMBlockOffset_MarioBelow:
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_MarioBelow	;>Run player collision points (interact with layer (MarioBelow))
	BNE.b CODE_00ECB1
	LDA.b #$02
	JSR.w CODE_00F2C2
	LDY.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_00ECA3
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	; Current MAP16 tile number
	CMP.b #$21
	BCC.b CODE_00ECA3
	CMP.b #$25
	BCC.b CODE_00ECA6
CODE_00ECA3:
	JMP.w CODE_00ED4A

CODE_00ECA6:
	SEC
	SBC.b #$04
	LDY.b #$00
	JSL.l SMW_CheckIfBlockWasHit_Entry3
	BRA.b CODE_00ED0D

CODE_00ECB1:
	CPY.b #$11
	BCC.b CODE_00ECA3
	CPY.b #$6E
	BCC.b CODE_00ECFA
	CPY.b #$D8
	BCC.b CODE_00ECDA
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Blocks_YPosLo
	CLC
	ADC.w #$0010
	STA.b !RAM_SMW_Blocks_YPosLo
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_Entry2
	BEQ.b CODE_00ECF8
	CPY.b #$6E
	BCC.b CODE_00ED4A
	CPY.b #$D8
	BCS.b CODE_00ED4A
	LDA.b !RAM_SMW_Player_VerticalDirectionToPushOutOfBlock
	SBC.b #$0F
	STA.b !RAM_SMW_Player_VerticalDirectionToPushOutOfBlock
CODE_00ECDA:
	TYA
	SEC
	SBC.b #$6E
	TAY
	REP.b #$20			; A->16
	LDA.b [!RAM_SMW_Pointer_SlopeSteepnessLo],y
	AND.w #$00FF
	ASL
	ASL
	ASL
	ASL
	SEP.b #$20			; A->8
	ORA.b !RAM_SMW_Player_XPosInBlock
	REP.b #$10			; XY->16
	TAY
	LDA.w SMW_SlopeDataTables_ShapeOfSlope,y
	SEP.b #$10			; XY->8
	BMI.b CODE_00ED0F
CODE_00ECF8:
	BRA.b CODE_00ED4A

CODE_00ECFA:
	LDA.b #$02
	JSR.w CODE_00F3E9
	TYA
	LDY.b #$00
	JSL.l CheckIfPlayerTouchingHurtBlock_IgnoreYoshi
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	; Current MAP16 tile number
	CMP.b #$1E			; \ If block is turn block, branch to $ED3B
	BEQ.b CODE_00ED3B
CODE_00ED0D:
	LDA.b #$F0
CODE_00ED0F:
	CLC
	ADC.b !RAM_SMW_Player_VerticalDirectionToPushOutOfBlock
	BPL.b CODE_00ED4A
	CMP.b #$F9
	BCS.b CODE_00ED28
	LDY.b !RAM_SMW_Player_InAirFlag
	BNE.b CODE_00ED28
	LDA.b !RAM_SMW_Player_BlockedFlags
	AND.b #$FC
	ORA.b #$09
	STA.b !RAM_SMW_Player_BlockedFlags
	STZ.b !RAM_SMW_Player_XSpeed
	BRA.b CODE_00ED3B

CODE_00ED28:
	LDY.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_00ED37
	EOR.b #$FF
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_Player_YPosLo
	BCC.b CODE_00ED37
	INC.b !RAM_SMW_Player_YPosHi
CODE_00ED37:
	LDA.b #$08
	TSB.b !RAM_SMW_Player_BlockedFlags
CODE_00ED3B:
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_00ED4A
	STZ.b !RAM_SMW_Player_YSpeed
	LDA.w !RAM_SMW_IO_SoundCh1				;\ Note: !Define_SMW_Sound1DF9_HitHead
	BNE.b CODE_00ED4A					;|
	INC							;|
	STA.w !RAM_SMW_IO_SoundCh1				;/
CODE_00ED4A:
#LMBlockOffset_MarioAbove:
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_MarioAbove	;>Run player collision points (interact with layer (MarioAbove))
	BNE.b CODE_00ED52
	JMP.w CODE_00EDDB

CODE_00ED52:
	CPY.b #$6E
	BCS.b CODE_00ED5E
	LDA.b #$03
	JSR.w CODE_00F3E9
	JMP.w CODE_00EDF7

CODE_00ED5E:
	CPY.b #$D8
	BCC.b CODE_00ED86
	CPY.b #$FB
	BCC.b CODE_00ED69
	JMP.w SMW_DamagePlayer_KillAndDisableButtons

CODE_00ED69:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Blocks_YPosLo
	SEC
	SBC.w #$0010
	STA.b !RAM_SMW_Blocks_YPosLo
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_Entry2
	BEQ.b CODE_00EDE9
	CPY.b #$6E
	BCC.b CODE_00EDE9
	CPY.b #$D8
	BCS.b CODE_00EDE9
	LDA.b !RAM_SMW_Player_YPosInBlock
	ADC.b #$10
	STA.b !RAM_SMW_Player_YPosInBlock
CODE_00ED86:
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting
	CMP.b #$03
	BEQ.b CODE_00ED91
	CMP.b #$0E
	BNE.b CODE_00ED95
CODE_00ED91:
	CPY.b #$D2
	BCS.b CODE_00EDE9
CODE_00ED95:
	TYA
	SEC
	SBC.b #$6E
	TAY
	LDA.b [!RAM_SMW_Pointer_SlopeSteepnessLo],y
	PHA
	REP.b #$20			; A->16
	AND.w #$00FF
	ASL
	ASL
	ASL
	ASL
	SEP.b #$20			; A->8
	ORA.b !RAM_SMW_Player_XPosInBlock
	PHX
	REP.b #$10			; XY->16
	TAX
	LDA.b !RAM_SMW_Player_YPosInBlock
	SEC
	SBC.w SMW_SlopeDataTables_ShapeOfSlope,x
	BPL.b CODE_00EDB9
	INC.w !RAM_SMW_Player_OnGroundFlag
CODE_00EDB9:
	SEP.b #$10			; XY->8
	PLX
	PLY
	CMP.w SMW_SlopeDataTables_Player_SnapToSlopeDistance,y
	BCS.b CODE_00EDE9
	STA.b !RAM_SMW_Player_VerticalDirectionToPushOutOfBlock
	STZ.b !RAM_SMW_Player_YPosInBlock
	JSR.w CODE_00F005
	CPY.b #$1C
	BCC.b CODE_00EDD5
	LDA.b #$08
	STA.w !RAM_SMW_Timer_PlayerSlidesWhenTuring
	JMP.w CODE_00EED1

CODE_00EDD5:
	JSR.w CODE_00EFBC
	JMP.w CODE_00EE85

CODE_00EDDB:
	CPY.b #$05
	BNE.b CODE_00EDE4
	JSR.w SMW_DamagePlayer_KillAndDisableButtons
	BRA.b CODE_00EDE9

CODE_00EDE4:
	LDA.b #$04
	JSR.w CODE_00F2C2
CODE_00EDE9:
#LMBlockOffset_TopCorner:
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_TopCorner	;>Run player collision points (interact with layer (MarioTopcorner))
	BNE.b CODE_00EDF3
	JSR.w CODE_00F309
	BRA.b CODE_00EE1D

CODE_00EDF3:
	CPY.b #$6E
	BCS.b CODE_00EE1D
CODE_00EDF7:
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b Return00EE39
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting
	CMP.b #$03
	BEQ.b CODE_00EE06
	CMP.b #$0E
	BNE.b CODE_00EE11
CODE_00EE06:
	LDY.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	; $ED3B
	CPY.b #$59
	BCC.b CODE_00EE11
	CPY.b #$5C
	BCC.b CODE_00EE1D
CODE_00EE11:
	LDA.b !RAM_SMW_Player_YPosInBlock
	AND.b #$0F
	STZ.b !RAM_SMW_Player_YPosInBlock
	CMP.b #$08
	STA.b !RAM_SMW_Player_VerticalDirectionToPushOutOfBlock
	BCC.b CODE_00EE3A
CODE_00EE1D:
	LDA.w !RAM_SMW_Misc_PlayerOnSolidSprite	; \ If Mario isn't on a sprite platform,
	BEQ.b CODE_00EE2D		; / branch to $EE2D
	LDA.b !RAM_SMW_Player_YSpeed	; \ If Mario is moving up,
	BMI.b CODE_00EE2D		; / branch to $EE2D
	STZ.b !RAM_SMW_Misc_ScratchRAM8E
	LDY.b #$20
	JMP.w CODE_00EEE1

CODE_00EE2D:
	LDA.b !RAM_SMW_Player_BlockedFlags
	AND.b #$04			; |If Mario is on an edge or in air,
	ORA.b !RAM_SMW_Player_InAirFlag	; |branch to $EE39
	BNE.b Return00EE39
CODE_00EE35:
	LDA.b #$24			; \ Set "In air" to x24 (falling)
	STA.b !RAM_SMW_Player_InAirFlag
Return00EE39:
	RTS

CODE_00EE3A:
	LDY.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	; Current MAP16 tile number
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting	; Tileset
	CMP.b #$02			; \ If tileset is "Rope 1",
	BEQ.b CODE_00EE48		; / branch to $EE48
	CMP.b #$08			; \ If tileset isn't "Rope 3",
	BNE.b CODE_00EE57		; / branch to $EE57
CODE_00EE48:
	TYA
	SEC				; |If the current tile isn't Rope 3's "Conveyor rope",
	SBC.b #$0C			; |branch to $EE57
	CMP.b #$02
	BCS.b CODE_00EE57
	ASL
	TAX
	JSR.w CODE_00EFCD
	BRA.b CODE_00EE83

CODE_00EE57:
	JSR.w CheckIfGrabbingThrowBlock
	LDY.b #$03
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	; Current MAP16 tile number
	CMP.b #$1E			; \ If block isn't "Turn block",
	BNE.b CODE_00EE78		; / branch to $EE78
	LDX.b !RAM_SMW_Misc_ScratchRAM8F
	BEQ.b CODE_00EE83
	LDX.b !RAM_SMW_Player_CurrentPowerUp
	; Change to EA EA (NOP #2) if you want Small Mario to be able to break turn
	; blocks with a spin jump. Alternatively, change this address to 80 18 (BRA
	; $18) if you want turn blocks to not be breakable by spin jumps.
	BEQ.b CODE_00EE83
	LDX.w !RAM_SMW_Player_SpinJumpFlag
	BEQ.b CODE_00EE83
	LDA.b #$21
	JSL.l SMW_CheckIfBlockWasHit_Entry3
	BRA.b CODE_00EE1D

CODE_00EE78:
	CMP.b #$32			; \ If block isn't "Brown block",
	BNE.b CODE_00EE7F		; / branch to $EE7F
	STZ.w !RAM_SMW_Flag_ActiveCreateEatBlock
CODE_00EE7F:
	JSL.l CheckIfPlayerTouchingHurtBlock
CODE_00EE83:
	LDY.b #$20
CODE_00EE85:
	LDA.b !RAM_SMW_Player_YSpeed	; \ If Mario isn't moving up,
	BPL.b CODE_00EE8F		; / branch to $EE8F
	LDA.b !RAM_SMW_Misc_ScratchRAM8D
	CMP.b #$02
	BCC.b Return00EE39
CODE_00EE8F:
	LDX.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed2
	BEQ.b CODE_00EED1
	DEX
	TXA
	AND.b #$03
	BEQ.b CODE_00EEAA
	CMP.b #$02
	BCS.b CODE_00EED1
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Blocks_XPosLo
	SEC
	SBC.w #$0010
	STA.b !RAM_SMW_Blocks_XPosLo
	SEP.b #$20			; A->8
CODE_00EEAA:
	TXA
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_Flag_ActivatedGreenSwitch,x	; \ If switch block is already active,
	BNE.b CODE_00EED1		; / branch to $EED1
	INC				; \ Activate switch block
	STA.w !RAM_SMW_Flag_ActivatedGreenSwitch,x
	STA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1
	PHY
	STX.w !RAM_SMW_Sprites_ColorOfFlatPalaceSwitchToSpawn
	JSR.w SpawnFlatPalaceSwitch
	PLY
	LDA.b #!Define_SMW_LevelMusic_PassedLevel
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
	LDA.b #$FF
	STA.w !RAM_SMW_Misc_MusicRegisterBackup	; / Set music to xFF
	LDA.b #$08
	STA.w !RAM_SMW_Timer_EndLevel
CODE_00EED1:
	INC.w !RAM_SMW_Player_OnGroundFlag
	LDA.b !RAM_SMW_Player_YPosLo
	SEC
	SBC.b !RAM_SMW_Player_VerticalDirectionToPushOutOfBlock
	STA.b !RAM_SMW_Player_YPosLo
	LDA.b !RAM_SMW_Player_YPosHi
	SBC.b !RAM_SMW_Player_YPosInBlock
	STA.b !RAM_SMW_Player_YPosHi
CODE_00EEE1:
	LDA.w SMW_SlopeDataTables_SlopeType,y
	BNE.b CODE_00EEEF
	LDX.w !RAM_SMW_Player_SlidingOnGround
	BEQ.b CODE_00EF05
	LDX.b !RAM_SMW_Player_XSpeed
	BEQ.b CODE_00EF02
CODE_00EEEF:
	STA.w !RAM_SMW_Player_SlopePlayerIsOn2
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #!Joypad_DPadD>>8
	; Change this to [80] to disable sliding on slopes. The slide will instead
	; be changed to ducking like on flat terrain
	BEQ.b CODE_00EF05
	; Change to [EA A9 00] to enable sliding while holding an item.
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2
	ORA.w !RAM_SMW_Player_SlidingOnGround
	BNE.b CODE_00EF05
	LDX.b #$1C
CODE_00EF02:
	STX.w !RAM_SMW_Player_SlidingOnGround
CODE_00EF05:
	LDX.w SMW_SlopeDataTables_Player_SlopeType,y
	STX.w !RAM_SMW_Player_SlopePlayerIsOn1
	CPY.b #$1C
	BCS.b CODE_00EF38
	LDA.b !RAM_SMW_Player_XSpeed
	BEQ.b CODE_00EF31
	LDA.w SMW_SlopeDataTables_SlopeType,y
	BEQ.b CODE_00EF31
	EOR.b !RAM_SMW_Player_XSpeed
	BPL.b CODE_00EF31
	STX.w !RAM_SMW_Player_AnimationSpeedIndex
	LDA.b !RAM_SMW_Player_XSpeed
	BPL.b CODE_00EF26
	EOR.b #$FF
	INC
CODE_00EF26:
if ver_is_pal(!Define_Global_ROMToAssemble)
	CMP.b #$34
else
	CMP.b #$28
endif
	BCC.b CODE_00EF2F
	LDA.w SMW_SlopeDataTables_Player_TowardsPeakYSpeed,y
	BRA.b CODE_00EF60

CODE_00EF2F:
	LDY.b #$20
CODE_00EF31:
	LDA.b !RAM_SMW_Player_YSpeed
	CMP.w SMW_SlopeDataTables_Player_StationaryYSpeed,y
	BCC.b CODE_00EF3B
CODE_00EF38:
	LDA.w SMW_SlopeDataTables_Player_StationaryYSpeed,y
CODE_00EF3B:
	LDX.b !RAM_SMW_Misc_ScratchRAM8E
	BPL.b CODE_00EF60
	INC.w !RAM_SMW_Sprites_Layer2IsTouchedFlag
	PHA
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Misc_Layer2XDisp-$01
	AND.w #$FF00
	BPL.b CODE_00EF50
	ORA.w #$00FF
CODE_00EF50:
	XBA
	EOR.w #$FFFF
	INC
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	SEP.b #$20			; A->8
	PLA
	CLC
	ADC.b #$28
CODE_00EF60:
	STA.b !RAM_SMW_Player_YSpeed
	TAX
	BPL.b CODE_00EF68
	INC.w !RAM_SMW_Player_OnGroundFlag
CODE_00EF68:
	STZ.w !RAM_SMW_Flag_StandingOnBetaCage
	STZ.b !RAM_SMW_Player_InAirFlag
	STZ.b !RAM_SMW_Player_ClimbingFlag
	STZ.w !RAM_SMW_Camera_BounceOffSpringFlag
	STZ.w !RAM_SMW_Player_SpinJumpFlag
	LDA.b #$04
	TSB.b !RAM_SMW_Player_BlockedFlags
	LDY.w !RAM_SMW_Player_CapeFlyingPhase
	BNE.b CODE_00EF99
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_00EF95
	LDA.b !RAM_SMW_Misc_ScratchRAM8F
	BEQ.b CODE_00EF95
	LDA.w !RAM_SMW_Yoshi_StompGroundFlag	; \ If Yoshi has stomp ability,
	BEQ.b CODE_00EF95
	JSL.l SMW_YoshiStompRoutine_Main	; | Run routine
	LDA.b #!Define_SMW_Sound1DFC_YoshiStompsEnemy	; | Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_00EF95:
	STZ.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped
	RTS

CODE_00EF99:
	STZ.w !RAM_SMW_Counter_ConsecutiveEnemiesStomped
	STZ.w !RAM_SMW_Player_CapeFlyingPhase
	CPY.b #$05
	BCS.b CallGroundPound
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	CMP.b #$02
	BNE.b Return00EFAD
	SEC
	ROR.w !RAM_SMW_Player_SlidingOnGround
Return00EFAD:
	RTS

CallGroundPound:
	LDA.b !RAM_SMW_Misc_ScratchRAM8F
	BEQ.b Return00EFBB
	JSL.l TriggerCapeDiveGroundPound
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
Return00EFBB:
	RTS

CODE_00EFBC:
	LDX.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	CPX.b #$CE
	BCC.b Return00EFE7
	CPX.b #$D2
	BCS.b Return00EFE7
	TXA
	SEC
	SBC.b #$CC
	ASL
	TAX
CODE_00EFCD:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	BNE.b Return00EFE7
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w SMW_HandlePlayerLevelCollision_DATA_00E913,x
	STA.b !RAM_SMW_Player_XPosLo
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.w SMW_HandlePlayerLevelCollision_DATA_00E91F,x
	STA.b !RAM_SMW_Player_YPosLo
	SEP.b #$20			; A->8
Return00EFE7:
	RTS

CODE_00EFE8:
	JSR.w SMW_GetPlayerLevelCollisionMap16ID_Main	;>Run player collision points (interact with layer (wallrun offset))
	BNE.b ADDR_00EFF0
	JMP.w CODE_00F309

ADDR_00EFF0:
	CPY.b #$11
	BCC.b Return00F004
	CPY.b #$6E
	BCS.b Return00F004
	TYA
	LDY.b #$00
	JSL.l SMW_CheckIfBlockWasHit_Main
	PLA
	PLA
	JMP.w ADDR_00EB42

Return00F004:
	RTS

CODE_00F005:
	TYA
	SEC
	SBC.b #$0E
	CMP.b #$02
	BCS.b Return00F04C
	EOR.b #$01
	CMP.b !RAM_SMW_Player_FacingDirection
	BNE.b Return00F04C
	TAX
	LSR
	LDA.b !RAM_SMW_Player_XPosInBlock
	BCC.b CODE_00F01B
	EOR.b #$0F
CODE_00F01B:
if ver_is_pal(!Define_Global_ROMToAssemble)
	CMP.b #$09
else
	CMP.b #$08
endif
	BCS.b Return00F04C
	LDA.w !RAM_SMW_Player_RidingYoshiFlag	;\ if not on yoshi,
	BEQ.b CODE_00F035		;/
	LDA.b #!Define_SMW_Sound1DFC_Springboard
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b #$80
	STA.b !RAM_SMW_Player_YSpeed
	STA.w !RAM_SMW_Camera_BounceOffSpringFlag
	PLA
	PLA
	JMP.w CODE_00EE35

CODE_00F035:
	LDA.b !RAM_SMW_Player_XSpeed
	SEC
	SBC.w DATA_00EAB9,x
	EOR.w DATA_00EAB9,x
	BMI.b Return00F04C
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2
	ORA.b !RAM_SMW_Player_DuckingFlag
	BNE.b Return00F04C
	INX
	INX
	STX.w !RAM_SMW_Player_WallWalkStatus
Return00F04C:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_RunPlayerBlockCode(Address)
namespace SMW_RunPlayerBlockCode
%InsertMacroAtXPosition(<Address>)

UnknownData00E8A4:
	db $10,$00,$20,$00,$20,$00,$18,$00
	db $1A,$00,$16,$00,$10,$00,$20,$00
	db $20,$00,$12,$00,$1A,$00,$0F,$00
	db $08,$00,$20,$00,$20,$00,$12,$00
	db $1A,$00,$0F,$00,$08,$00,$20,$00
	db $20,$00,$1D,$00,$28,$00,$19,$00
	db $13,$00,$30,$00,$30,$00,$1D,$00
	db $28,$00,$19,$00,$13,$00,$30,$00
	db $30,$00,$1A,$00,$28,$00,$16,$00
	db $10,$00,$30,$00,$30,$00,$1A,$00
	db $28,$00,$16,$00,$10,$00,$30,$00
	db $30,$00,$18,$00,$18,$00,$18,$00
	db $18,$00,$18,$00,$18,$00
namespace off
endmacro

macro ROUTINE_RT02_SMW_RunPlayerBlockCode(Address)
namespace SMW_RunPlayerBlockCode
%InsertMacroAtXPosition(<Address>)

; Shared Map16 page 1 interaction routine. This handles Munchers, spikes and
; bounce blocks (including but not limited to Note Blocks and ?-blocks).
; This routine is called for most of Mario's interaction points as well as
; carryable sprites and the cape. The order in which the routine goes as
; follows: Check for Yoshi Handle hurt blocks Hande bounce blocks The
; routine can be jumped at various points: $00F120 includes the Yoshi check
; and is used if the player is above a block. $00F127 handles hurt blocks
; regardless whether the player rides Yoshi or not and is used for the other
; sides of a block. $00F160 handles only bounce sprites and is used for the
; invisible blocks and sprite interaction. All these routines take the
; following inputs: A: Map16 tile which is interacted Y: Block direction
; (follows a similar fomat as $7E0077).
CheckIfPlayerTouchingHurtBlock:
	XBA				;>map16numb -> high
	LDA.w !RAM_SMW_Player_RidingYoshiFlag	;\If riding yoshi, skip
	BNE.b SMW_CheckIfBlockWasHit_Entry2	;/
	XBA				;>map16numb -> low byte
.IgnoreYoshi:
	CMP.b #$2F			;\If 2F (muncher),skip
	BEQ.b CODE_00F154		;/
	CMP.b #$59			;\If castle spikes
	BCC.b CODE_00F144		;|
	CMP.b #$5C			;|
	BCS.b CODE_00F140		;/
	XBA				;>map16numb -> high
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting	;\If tileset is #$05 (ghost house), branch
	CMP.b #$05			;|
	BEQ.b CODE_00F154		;/
	CMP.b #$0D			;\Ghost house 2
	BEQ.b CODE_00F154		;/
	XBA				;>map16numb -> low
CODE_00F140:
	CMP.b #$5D			;\if less than #$5D, branch
	BCC.b CODE_00F14C		;/
CODE_00F144:
	CMP.b #$66			;\Bush tiles do nothing?
	BCC.b SMW_CheckIfBlockWasHit_Main	;/
	CMP.b #$6A			;\Some other tiles
	BCS.b SMW_CheckIfBlockWasHit_Main	;/
CODE_00F14C:
	XBA				;>map16numb -> high
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting	;\If tileset setting other than castle 1
	CMP.b #$01			;|skip
	BNE.b SMW_CheckIfBlockWasHit_Entry2	;/
CODE_00F154:
	PHB
	LDA.b #(SMW_DamagePlayer_Hurt>>16)+$01				; Glitch: Why bank 01?
	PHA
	PLB
	JSL.l SMW_DamagePlayer_Hurt	;>block damage the player
	PLB
	RTL
namespace off
endmacro

macro ROUTINE_RT03_SMW_RunPlayerBlockCode(Address)
namespace SMW_RunPlayerBlockCode
%InsertMacroAtXPosition(<Address>)

CheckIfGrabbingThrowBlock:
	CPY.b #$2E
	BNE.b Return00F28B
	BIT.b !RAM_SMW_IO_ControllerPress1
	BVC.b Return00F28B
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2
	ORA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b Return00F28B
	LDA.b #SMW_GrabThrowBlockBlock_Main>>16
	PHA
	PLB
	JSL.l SMW_GrabThrowBlockBlock_Main
	BMI.b CODE_00F289
	LDA.b #$02			; \ Block to generate = #$02
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
CODE_00F289:
	PHK
	PLB
Return00F28B:
	RTS

CODE_00F28C:
	TYA
	SEC
	SBC.b #$6F
	CMP.b #$04
	BCS.b CODE_00F2C0
	CMP.w !RAM_SMW_Counter_1upCheckPointsCollected
	BEQ.b CODE_00F2A8
	INC
	CMP.w !RAM_SMW_Counter_1upCheckPointsCollected
	BEQ.b Return00F2BF
	LDA.w !RAM_SMW_Counter_1upCheckPointsCollected
	CMP.b #$04
	BCS.b Return00F2BF
	LDA.b #$FF
CODE_00F2A8:
	INC
	STA.w !RAM_SMW_Counter_1upCheckPointsCollected
	CMP.b #$04
	BNE.b Return00F2BF
	PHX
	JSL.l SMW_TriggerHidden1up_Main
	JSR.w GetOverworldLevelIndex
	ORA.w !RAM_SMW_Flag_Collected1upCheckpoints,y
	; Change [99 3C 1F] to [EA EA EA] to make the 1up checkpoint work again
	; when reentering a level
	STA.w !RAM_SMW_Flag_Collected1upCheckpoints,y
	PLX
Return00F2BF:
	RTS

; Shared Map16 interaction routine to handle interaction with various tiles
; on page 0. The tile number is passed in Y, and the specific interaction
; point being processed is identified via a value passed in A, using a
; format similar to that of $74. The routine specifically handles
; interaction for the following tiles, in the following order: Liquids
; (000-005) Midpoints (038) Climbable blocks (006-01C) Moons (tile 06E)
; Yoshi coins (tiles 02D, 02E) Normal coins (tiles 02A-02C) The game uses
; multiple entry points to the routine depending on the interaction point
; being processed: $00F2C0: MarioBody. This specifically sets A to #$01.
; $00F2C2: MarioAbove and MarioBelow. $00F2C9: MarioSide and MarioHead. This
; skips liquid interaction. $00F309: TopCorner and WallFeet. This skips
; liquid, midpoint, and climbable block interaction.
CODE_00F2C0:
	LDA.b #$01
CODE_00F2C2:
	CPY.b #$06
	BCS.b CODE_00F2C9
	TSB.b !RAM_SMW_Misc_ScratchRAM8A
	RTS

CODE_00F2C9:
	CPY.b #$38
	BNE.b CODE_00F2EE
	; The code for the midway point tile (Map16 tile 38, not the extended
	; object). - $00F2CE: what tile gets generated after breaking the midway
	; point tape (see $9C; default is 02 - none). - $00F2D5: change to [80 01]
	; to disable the glitter that appears after touching a midpoint. - $00F2E2:
	; change to [80] to disable midway powerups (or [80 01] to make them always
	; make you big, even if you have a better powerup). - $00F2E5: what powerup
	; midway points give you. - $00F2E9: what sound effect midway points play.
	LDA.b #$02			; \ Block to generate = #$02
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
	JSR.w SMW_SpawnGlitterEffectForCoin_Main	; Generate twinkle effect
	LDA.w !RAM_SMW_Misc_MidwayEntranceScreen		;\ Zero, and the level has no midway entrance: the midpoint does not register
#LM000Hijack_Unknown00F2DB:					;|
	BEQ.b CODE_00F2E0					;/
	JSR.w SMW_PlayerState00_Normal_SetMidpointFlag
CODE_00F2E0:
	LDA.b !RAM_SMW_Player_CurrentPowerUp	;\
	BNE.b CODE_00F2E8		;/ if mario isn't small, don't make him big
	LDA.b #$01			;\ make mario big
	STA.b !RAM_SMW_Player_CurrentPowerUp	;/
CODE_00F2E8:
	LDA.b #!Define_SMW_Sound1DF9_MidwayPoint
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	RTS

CODE_00F2EE:
	CPY.b #$06
	BEQ.b CODE_00F2FC
	CPY.b #$07
	BCC.b CODE_00F309
	CPY.b #$1D
	BCS.b CODE_00F309
	ORA.b #$80
CODE_00F2FC:
	CMP.b #$01
	BNE.b CODE_00F302
	ORA.b #$18
CODE_00F302:
	TSB.b !RAM_SMW_Misc_ScratchRAM8B
	LDA.b !RAM_SMW_Player_HorizontalSideOfBlockBeingTouched
	STA.b !RAM_SMW_Misc_ScratchRAM8C
	RTS

CODE_00F309:
	CPY.b #$2F
	BCS.b CODE_00F311
	CPY.b #$2A
	BCS.b CODE_00F32B
CODE_00F311:
	CPY.b #$6E
	BNE.b Return00F376
	LDA.b #$0F
	JSL.l SMW_SpawnScoreSpriteAtPlayerPosition_Main
	INC.w !RAM_SMW_UnusedRAM_3upMoonsCounter			; Optimization: These address would make for some nice free RAM
	PHX
	JSR.w GetOverworldLevelIndex
	ORA.w !RAM_SMW_Flag_CollectedMoons,y
	; Replace '99 EE 1F' with 'EA EA EA' to make moons reappear when you
	; re-enter a level after collecting them.
	STA.w !RAM_SMW_Flag_CollectedMoons,y
	PLX
	BRA.b CODE_00F36B

CODE_00F32B:
	BNE.b CODE_00F332		;YOSHI COIN HANDLER
	LDA.w !RAM_SMW_Timer_BluePSwitch	;\
	BEQ.b Return00F376		;/ if POW timer = 00, return
; The code that handles a Yoshi coin being collected. - $00F333: Map16 tile
; number of the top half of the coin. - $00F33C: offset of the score sprite
; when the top half is collected, relative to the bottom half. - $00F343:
; changing [EE 22 14] to [EA EA EA] will disable the Yoshi Coin counter in
; the status bar. Note that this will also stop them from respawning when
; you've got five of them. - $00F34A: number of Yoshi coins that need to be
; collected to trigger the "collected all" flag. - $00F354: changing [99 2F
; 1F] to [EA EA EA] will make the Yoshi coins reappear even after collecting
; all 5 (or more) of them. - $00F359: Yoshi coin sound. - $00F35E: amount of
; regular coins a Dragon Coin gives you. - $00F364: value stored to $9C when
; the coin is collected.
CODE_00F332:
	CPY.b #$2D
	BEQ.b CODE_00F33F
	BCC.b CODE_00F367
	LDA.b !RAM_SMW_Blocks_YPosLo
	SEC
	SBC.b #$10
	STA.b !RAM_SMW_Blocks_YPosLo
CODE_00F33F:
	JSL.l CODE_00F377
	INC.w !RAM_SMW_Counter_YoshiCoinsToDisplay
	LDA.w !RAM_SMW_Counter_YoshiCoinsToDisplay
	CMP.b #$05
	BCC.b CODE_00F358
	PHX
	JSR.w GetOverworldLevelIndex
	ORA.w !RAM_SMW_Flag_Collected5YoshiCoins,y
	STA.w !RAM_SMW_Flag_Collected5YoshiCoins,y
	PLX
CODE_00F358:
	LDA.b #!Define_SMW_Sound1DF9_YoshiCoin
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	LDA.b #$01
	JSL.l SMW_GiveCoins_MultipleCoins_NoCoinSound
	LDY.b #$18
	BRA.b CODE_00F36D

CODE_00F367:
	JSL.l SMW_GiveCoins_OneCoin
CODE_00F36B:
	LDY.b #$01			; \ Block to generate = #$01
CODE_00F36D:
	STY.b !RAM_SMW_Blocks_Map16ToGenerate
	JSL.l SMW_GenerateTile_Main
	JSR.w SMW_SpawnGlitterEffectForCoin_Main
Return00F376:
	RTS

; The subroutine that handles giving you points/1-ups when collecting Yoshi
; Coins. Changing $00F37A [EE] to [AD] will stop the coins from increasing
; the number of points they give.
CODE_00F377:
	LDA.w !RAM_SMW_Counter_YoshiCoinsCollected
	INC.w !RAM_SMW_Counter_YoshiCoinsCollected
	CLC
	ADC.b #$09
	CMP.b #$0D
	BCC.b CODE_00F386
	LDA.b #$0D
CODE_00F386:
	BRA.b SMW_SpawnScoreSpriteAtPlayerPosition_Main
namespace off
endmacro

macro ROUTINE_RT04_SMW_RunPlayerBlockCode(Address)
namespace SMW_RunPlayerBlockCode
%InsertMacroAtXPosition(<Address>)

; This subroutine gets an index to the "one bit per level" tables ($1F2F,
; $1F3C, $1FEE) depending on the overworld level number ($13BF). When it
; returns, Y holds the byte index to $1F2F and A holds the bit to check/set.
GetOverworldLevelIndex:
	LDA.w !RAM_SMW_Overworld_LevelNumberLo
	LSR
	LSR
	LSR
	TAY
	LDA.w !RAM_SMW_Overworld_LevelNumberLo
	AND.b #$07
	TAX
	LDA.l SMW_BitTable_Bank05,x
	RTS

CheckIfEnteringHorizontalPipe:
	CPY.b #$3F
	BNE.b Return00F376
	LDY.b !RAM_SMW_Misc_ScratchRAM8F
	BEQ.b CODE_00F3CF
	JMP.w CODE_00F43F

CODE_00F3CF:
	PHX
	TAX
	LDA.b !RAM_SMW_Player_XPosLo
	TXY
	BEQ.b CODE_00F3D9
	EOR.b #$FF
	INC
CODE_00F3D9:
	AND.b #$0F
	ASL
	CLC
	ADC.b #$20
	LDY.b #!Define_SMW_PlayerState05_EnterHorizontalPipe
	BRA.b CODE_00F40A

; [0A] Signed offset of the enterable region of the left tile of an
; exit-enabled vertical pipe from the left edge of the tile, in pixels,
; minus 1 Change to #$FF to make up pipes enterable as no matter where you
; hit them. (For use with the hex edit at $00F3F9)
DATA_00F3E3:
	db $0A,$FF

; Which button you have to be pushing in order to enter the 4 kinds of
; pipes. In order: End on right, end on left, end on bottom, end on top.
PIPE_BUTTONS:
	db !Joypad_DPadL>>8,!Joypad_DPadR>>8,!Joypad_DPadU>>8,!Joypad_DPadD>>8	; Format: Button to press to go in pipe: Left, Right, Up, Down, for right facing, left facing, from the top, and from the bottom (normal.)

CODE_00F3E9:
	XBA
	TYA
	SEC
	SBC.b #$37
	CMP.b #$02
	BCS.b Return00F442
	TAY
	LDA.b !RAM_SMW_Player_XPosInBlock
	SBC.w DATA_00F3E3,y
	CMP.b #$05
	BCS.b CODE_00F43F
	PHX
	XBA
	TAX
	LDA.b #$20
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_00F408
	LDA.b #$30
CODE_00F408:
	LDY.b #!Define_SMW_PlayerState06_EnterVerticalPipe
CODE_00F40A:
	STA.b !RAM_SMW_Player_TimerBeforeWarpingInPipe
	LDA.b !RAM_SMW_IO_ControllerHold1	;\
	AND.w PIPE_BUTTONS,x		;| if button to go down pipe is not pressed
	BEQ.b CODE_00F43E		;/
	STA.b !RAM_SMW_Flag_SpritesLocked	; Lock the sprites
	AND.b #$01			;\
	STA.b !RAM_SMW_Player_FacingDirection	;/ correct mario's direction
	STX.b !RAM_SMW_Player_PipeAction
	TXA
	LSR
	TAX
	BNE.b CODE_00F430
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2
	BEQ.b CODE_00F430
	LDA.b !RAM_SMW_Player_FacingDirection	;\
	EOR.b #$01			;| make mario switch directions
	STA.b !RAM_SMW_Player_FacingDirection	;/
	LDA.b #$08			;\
	STA.w !RAM_SMW_Timer_DisplayPlayerFaceScreenPose	;/ make mario face the screen
CODE_00F430:
	INX
	STX.w !RAM_SMW_Yoshi_InPipe
	STY.b !RAM_SMW_Player_CurrentState
	JSR.w SMW_DamagePlayer_DisableButtons	; No buttons
	LDA.b #!Define_SMW_Sound1DF9_IntoPipe
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_00F43E:
	PLX
CODE_00F43F:
	LDY.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
Return00F442:
	RTS

; Subroutine that checks if Mario is in the center of a door. Not used for
; boss doors. $00F44B [08] is the width of the enterable region of the door
; (up to 0x10). $00F447 [04] is how far to offset the enterable region; this
; should be set to half of $00F44B.
CODE_00F443:
	LDA.b !RAM_SMW_Player_XPosLo
	CLC				;>Round half-block up
	ADC.b #$04			;\Get modulo of 16
	AND.b #$0F			;|
	CMP.b #$08			;/
	RTS
namespace off
endmacro

macro ROUTINE_RT05_SMW_RunPlayerBlockCode(Address)
namespace SMW_RunPlayerBlockCode
%InsertMacroAtXPosition(<Address>)

SpawnFlatPalaceSwitch:
	LDA.b #$20			; \ Set "Time to shake ground" to x20
	STA.w !RAM_SMW_Timer_ShakeLayer1
	LDY.b #$02						; Note: It seems that the flat palace switch sprite spawns in a hardcoded slot...
	LDA.b #!Define_SMW_SpriteID_NorSpr060_FlatPalaceSwitch	; |Set sprite x02 to x60 (Flat palace switch)
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	LDA.b #!Define_SMW_NorSprStatus08_Normal	; \ Set sprite's status to x08
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b !RAM_SMW_Blocks_XPosLo
	AND.b #$F0			; |Set sprite X (low) to $9A & 0xF0
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.b !RAM_SMW_Blocks_XPosHi	; \ Set sprite X (high) to $9B
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.b #$F0
	CLC				; |Set sprite Y (low) to ($98 & 0xF0) + 0x10
	ADC.b #$10
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.b !RAM_SMW_Blocks_YPosHi
	ADC.b #$00			; |Set sprite Y (high) to $99 + carry
	STA.w !RAM_SMW_NorSpr_YPosHi,y	; / (Carry carried over from previous addition)
	PHX
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	PLX
	LDA.b #$5F			; \ Set sprite's "Spin Jump Death Frame Counter" to x5F
	STA.w !RAM_SMW_NorSpr060_FlatPalaceSwitch_WaitBeforeEraseSwitchObject,y
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_CheckForWaterSlope(Address)
namespace SMW_CheckForWaterSlope
%InsertMacroAtXPosition(<Address>)

Main:
	PHX
	LDX.b #$19			;>X = #$19
CODE_00F050:
	CMP.l SMW_RunPlayerBlockCode_WaterSlopeMap16Numbers,x	;>Slope tiles
	BEQ.b CODE_00F05A		;>If matches with something, break loop
	DEX				;>Compare next slope
	BPL.b CODE_00F050		;>Loop if 0 or positive
	CLC				;>Set carry if slope mismatch
CODE_00F05A:
	PLX
	RTL
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_RT00_SMW_GetPlayerLevelCollisionMap16ID(Address)
namespace SMW_GetPlayerLevelCollisionMap16ID
%InsertMacroAtXPosition(<Address>)

; Routine used to set up relevant data for Mario's interaction points,
; specifically its position in $98-$9B and the acts-like setting in $1693.
; Automatically increments X by 2 when called.
WallRun:
MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
HeadInside:
BodyInside:
Main:
	INX
	INX
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w DATA_00E832-$02,x
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.w DATA_00E89C,x
	STA.b !RAM_SMW_Blocks_YPosLo
Entry2:
	JSR.w Sub
	RTS

Sub:
	SEP.b #$20			; A->8
	STZ.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed2	;>Clear switch palace sides
	PHX				;>X in stack
	LDA.b !RAM_SMW_Misc_ScratchRAM8E	;\some scratch ram
	BPL.b CODE_00F472		;/
	JMP.w CODE_00F4EC

CODE_00F472:
	BNE.b CODE_00F4A6
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Blocks_YPosLo
#LM300Hijack_CustomLevelDimensions03:
	CMP.w #$01B0			;|of #$01BO, branch
	SEP.b #$20			; A->8
	BCS.b CODE_00F4A0
	AND.b #$F0			;>Round down to nearest 16x16
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>$00 = pixel x position
	LDX.b !RAM_SMW_Blocks_XPosHi	;\If Y pos of collision point beyond the bottom of level, branch
	CPX.b !RAM_SMW_Misc_ScreensInLvl	;|
	BCS.b CODE_00F4A0		;/
	LDA.b !RAM_SMW_Blocks_XPosLo	;\Y position divide by 16 (rounded down, this gets what block the point is on)
	LSR				;|
	LSR				;|
	LSR				;|
	LSR				;/
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;>Get few bits off of $00 (left 4 bits) the y position of blocks as it relates to the $C800 format (YYYYXXXX each screen).
	CLC
#LM300Hijack_CustomLevelDimensions04:
	ADC.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L1,x
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>And store to $00
	LDA.b !RAM_SMW_Blocks_YPosHi
#LM300Hijack_CustomLevelDimensions05:
	ADC.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L1,x
	BRA.b CODE_00F4CD

CODE_00F4A0:
	PLX
	LDY.b #$25							;\ Glitch: Because !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo is not set here, going out of bounds can potentially cause Mario to interact with random map16 tiles on page 00.
CODE_00F4A3:								;|
	LDA.b #$00							;/ LM: Lunar Magic 3.04 fixes this bug
	RTS

CODE_00F4A6:
	LDA.b !RAM_SMW_Blocks_XPosHi	;\If collision point is #$02 or above (downwards on-screen), branch
	CMP.b #$02			;|
	BCS.b CODE_00F4E7		;/
	LDX.b !RAM_SMW_Blocks_YPosHi	;\If collision point is beyond the right edge of screen, branch
	CPX.b !RAM_SMW_Misc_ScreensInLvl	;|
	BCS.b CODE_00F4E7		;/
	LDA.b !RAM_SMW_Blocks_YPosLo	;>collision point x pos
	AND.b #$F0			;>Round down to nearest 16
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>$00 = pixel position
	LDA.b !RAM_SMW_Blocks_XPosLo	;\Y position divided by 16 (rounded down)
	LSR				;|
	LSR				;|
	LSR				;|
	LSR				;/
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;>Get few bits off of $00 (left 4 bits) the y position of blocks as it relates to the $C800 format (YYYYXXXX each screen).
	CLC				;\Add by value to get what map16 it is
	ADC.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L1,x	;/
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>Store to $00
	LDA.b !RAM_SMW_Blocks_XPosHi	;\handle collision point y high byte
	ADC.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L1,x	;/
CODE_00F4CD:
	STA.b !RAM_SMW_Misc_ScratchRAM01	;>Set $01 (x pos?)
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16	;\RAM bank $7E
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]	;>Load the $C800s
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	INC.b !RAM_SMW_Misc_ScratchRAM02	;>Go to RAM bank $7F
	PLX				;>Get x back
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]	;>Load map16 numbers
#LM000Hijack_ProcessCustomPlayerBlockCode:
if !Define_SMW_CustomTiles == !TRUE
	JSL.l SMW_CustomTiles_ActsLikeOf		;> A custom tile as the vanilla tile it acts like, then the stock routine (Config/CustomTiles.asm)
else
	JSL.l SMW_ModifyMap16IDForSpecialBlocks_Main	;>Mario block offset
endif
	LDY.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;\Handle act as/map16 number.
	CMP.b #$00			;/
	RTS

CODE_00F4E7:
	PLX				;\Acts like 25?
	LDY.b #$25			;/
	BRA.b CODE_00F4A3

CODE_00F4EC:
	ASL				;>Left shift (x2)
	BNE.b CODE_00F51B		;>if nonzero, branch
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Blocks_YPosLo
#LM300Hijack_CustomLevelDimensions06:
	CMP.w #$01B0
	SEP.b #$20			; A->8
	BCS.b CODE_00F4E7		;>If x position beyond $01B0, branch
	AND.b #$F0			;>Round down to nearest 16x16
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>$00 = block x pos
	LDX.b !RAM_SMW_Blocks_XPosHi	;\If block y pos is greater than #$10 (8-bit), branch
	CPX.b #$10			;|
	BCS.b CODE_00F4E7		;/
	LDA.b !RAM_SMW_Blocks_XPosLo	;\Divide by 16 (get what block the point is on)
	LSR				;|
	LSR				;|
	LSR				;|
	LSR				;/
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;>Get few bits off of $00 (left 4 bits) the y position of blocks as it relates to the $C800 format (YYYYXXXX each screen).
	CLC
#LM300Hijack_CustomLevelDimensions07:
	ADC.l SMW_LevelDataLayoutTables_EightBitLo_Horizontal_L2,x
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>And store to $00
	LDA.b !RAM_SMW_Blocks_YPosHi
#LM300Hijack_CustomLevelDimensions08:
	ADC.l SMW_LevelDataLayoutTables_EightBitHi_Horizontal_L2,x
	BRA.b CODE_00F4CD		;>Get map16 number (player)

CODE_00F51B:
	LDA.b !RAM_SMW_Blocks_XPosHi	;\If collision point at or below #$02, branch
	CMP.b #$02			;|
	BCS.b CODE_00F4E7		;/
	LDX.b !RAM_SMW_Blocks_YPosHi	;\If collision point at or right #$0E, branch
	CPX.b #$0E			;|
	BCS.b CODE_00F4E7		;/
	LDA.b !RAM_SMW_Blocks_YPosLo	;>Collision point y pos
	AND.b #$F0			;>Round down to nearest 16x16
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>Store block-align into $00
	LDA.b !RAM_SMW_Blocks_XPosLo	;\Divide by 16 (get what block the point is on)
	LSR				;|
	LSR				;|
	LSR				;|
	LSR				;/
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;>ORA it by x position of block
	CLC				;\Add by whats in table
	ADC.l SMW_LevelDataLayoutTables_EightBitLo_Vertical_L2,x	;/
	STA.b !RAM_SMW_Misc_ScratchRAM00	;>And store to $00
	LDA.b !RAM_SMW_Blocks_XPosHi	;\Collision point add by whats in table
	ADC.l SMW_LevelDataLayoutTables_EightBitHi_Vertical_L2,x	;/
	JMP.w CODE_00F4CD		;>Get map16 number (player)
namespace off
endmacro

macro ROUTINE_RT01_SMW_GetPlayerLevelCollisionMap16ID(Address)
namespace SMW_GetPlayerLevelCollisionMap16ID
%InsertMacroAtXPosition(<Address>)

DATA_00E832:
	dw $0008,$000E,$000E,$0008
	dw $0005,$000B,$0008,$0002
	dw $0002,$0008,$000B,$0005
	dw $0008,$000E,$000E,$0008
	dw $0005,$000B,$0008,$0002
	dw $0002,$0008,$000B,$0005
	dw $0008,$000E,$000E,$0008
	dw $0005,$000B,$0008,$0002
	dw $0002,$0008,$000B,$0005
	dw $0008,$000E,$000E,$0008
	dw $0005,$000B,$0008,$0002
	dw $0002,$0008,$000B,$0005
	dw $0010,$0020,$0007,$0000
	dw $FFF0

DATA_00E89C:
	dw $0008,$0018,$001A,$0016
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_ModifyMap16IDForSpecialBlocks(Address)
namespace SMW_ModifyMap16IDForSpecialBlocks
%InsertMacroAtXPosition(<Address>)

; Routine that handles behaviours for various Map16 tiles. For P-Switch
; dependent tiles, this routine only sets the "act as", not the graphics.
; $00F54C: Map16 tile number (low byte) that should act like a ? Coin Block
; when the blue P-Switch is active. Default is ($00)29, the Invisible POW ?
; Coin Block. $00F555: Map16 tile number (low byte) that the Invisible POW ?
; Coin Block should act like when the blue P-Switch is active. Default is
; ($01)24, the ? Coin Block. $00F55B: Map16 tile number (low byte) that
; should act like a Brown "used" Block when the blue P-Switch is active.
; Default is ($00)2B, the Coin. $00F572: Map16 tile number (low byte) that
; Coins should act like when the blue P-Switch is active. Default is
; ($01)32, the Brown "used" Block. $00F561 & $00F563: Range of Map16 tiles
; (page 0) that set the "current Palace Switch being pressed" value in
; $1423. $00F561 (#$EC) is subtracted from the Map16 tile number, then
; compared with $00F563 (#$10). If the result is less than #$10, the value
; gets incremented by 1 and stored to $1423. This makes it so that only
; tiles ($00)EC to ($00)FB, the Palace Switch tiles, set $1423. $00F57B:
; Map16 tile number (low byte) that should act like a Coin when the blue
; P-Switch is active. Default is ($01)32, the Brown "used" Block. $00F585:
; Map16 tile number (low byte) that should act like a Coin when the silver
; P-Switch is active. Default is ($01)2F, the Black Piranha Plant. $00F58E:
; Map16 tile number (low byte) that the Brown "used" Block should act like
; when the blue P-Switch is active, and the Black Piranha Plant should act
; like when the silver P-Switch is active. Default is ($00)2B, the Coin.
Main:
#LM_JMLHere_ModifyMap16IDForSpecialBlocks:
	TAY				;>Transfer map16 pointers into Y
	BNE.b CODE_00F577		;>If nonzero, branch
	LDY.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	; Load MAP16 tile number
	CPY.b #$29			; \ If block isn't "Invisible POW ? block",
	BNE.b PSwitchNotInvQBlk		; / branch to PSwitchNotInvQBlk
	LDY.w !RAM_SMW_Timer_BluePSwitch	;\If timer zero, return
	BEQ.b Return00F594		;/
	LDA.b #$24			;\Set behavor
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;/
	RTL

PSwitchNotInvQBlk:
	CPY.b #$2B			; \ If block is "Coin",
	BEQ.b PSwitchCoinBrown		; / branch to PSwitchCoinBrown
	TYA				;\
	SEC				;| if block is map16 FC and above,
	SBC.b #$EC			;|return
	CMP.b #$10			;|
	BCS.b CODE_00F592		;/
	INC				;\ ?
	STA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed2	;/
	BRA.b CODE_00F571		; Make block brown

PSwitchCoinBrown:
	LDY.w !RAM_SMW_Timer_BluePSwitch	;\ Return if POW is not active
	BEQ.b Return00F594		;/
CODE_00F571:
	LDA.b #$32			;\ make block a brown block
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;/
	RTL

CODE_00F577:
	LDY.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;\ if block not brown block
	CPY.b #$32			;|
	BNE.b CODE_00F584		;/
	LDY.w !RAM_SMW_Timer_BluePSwitch	;\ If POW is #$00, return
	BNE.b CODE_00F58D		;/
	RTL

CODE_00F584:
	CPY.b #$2F			;\ if block is not
	BNE.b Return00F594		;/ muncher, return
	LDY.w !RAM_SMW_Timer_SilverPSwitch	;\ if silver pow timer is 00, return
	BEQ.b Return00F594		;/
CODE_00F58D:
	LDY.b #$2B			;\ make muncher coin
	STY.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo	;/
CODE_00F592:
	LDA.b #$00			; A = 00
Return00F594:
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnScoreSpriteAtPlayerPosition(Address)
namespace SMW_SpawnScoreSpriteAtPlayerPosition
%InsertMacroAtXPosition(<Address>)

; Subroutine used to spawn a score sprites at Mario's position. Calling
; $00F388 will spawn specifically a 1-up score sprite, while calling a bit
; later at $00F38A will allow you to specify the score sprite you want to
; spawn in A; see $16E1 for a list of valid values.
LakituEntry:
	LDA.b #$0D			; Why this isn't after generating the score sprite is beyond me
Main:
	PHA
	JSL.l SMW_CheckForAvailableScoreSpriteSlot_Main	; Generate score sprite? probably, looking at it
	PLA				;/ save A too, since it holds what score sprite it is
	STA.w !RAM_SMW_ScoreSpr_SpriteID,y	;\ Y = index to score sprite
	LDA.b !RAM_SMW_Player_XPosLo	;|
	STA.w !RAM_SMW_ScoreSpr_XPosLo,y	;|
	LDA.b !RAM_SMW_Player_XPosHi	;|
	STA.w !RAM_SMW_ScoreSpr_XPosHi,y	;|
	LDA.b !RAM_SMW_Player_YPosLo	;|
	STA.w !RAM_SMW_ScoreSpr_YPosLo,y	;|
	LDA.b !RAM_SMW_Player_YPosHi	;|
	STA.w !RAM_SMW_ScoreSpr_YPosHi,y	;|
	LDA.b #$30			;|
	STA.w !RAM_SMW_ScoreSpr_YSpeed,y	;/ Score sprite pos is the same as Mario pos (would MVN be easier here?)
	LDA.b #$00			;\
	STA.w !RAM_SMW_ScoreSpr_LayerIndex,y	;/ Hmm, a undocumented score sprite table. Perhaps score sprite timer?
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_OverworldEventProcess04_FadeInLayer2Tile(Address)
namespace SMW_OverworldEventProcess04_FadeInLayer2Tile
%InsertMacroAtXPosition(<Address>)

CODE_00B006:
	PHB				;\ start of a subroutine most likely
	PHK				;|
	PLB				;|
	JSR.w SMW_HandlePaletteFades_CODE_00AFA3	;/
	LDX.w #$006E
CODE_00B00F:
	LDY.w #$0008
CODE_00B012:
	LDA.w SMW_CopyOfPaletteMirror[$01].LowByte,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w SMW_PaletteMirror[$40].LowByte,x
	PHY
	JSR.w SMW_HandlePaletteFades_CODE_00AFC0
	PLY
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w SMW_CopyOfPaletteMirror[$01].LowByte,x
	LDA.w SMW_PaletteMirror[$40].LowByte,x
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM04
	STA.w SMW_CopyOfPaletteMirror[$3A].LowByte,x
	DEX
	DEX
	DEY
	BNE.b CODE_00B012
	TXA
	SEC
	SBC.w #$0010
	TAX
	BPL.b CODE_00B00F
	SEP.b #$30			; AXY->8
	PLB
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ClearLayer3Tilemap(Address)
namespace SMW_ClearLayer3Tilemap
%InsertMacroAtXPosition(<Address>)

; Fills the entire layer 3 tilemap with tile 0x0FC (transparent tile) i.e.
; the code "empties" it. Also wipes the OAM before returning.
Main:
	JSR.w SMW_TurnOffIO_Main
	LDA.b #$FC			;\ Tile to use as the blank tile.
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	STZ.w !REGISTER_VRAMAddressIncrementValue	;] Single byte VRAM upload.
	STZ.w !REGISTER_VRAMAddressLo	;\
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation>>8	;| Upload tilemap to Layer 3.
	STA.w !REGISTER_VRAMAddressHi	;/
	LDX.b #$06
CODE_00860E:
	LDA.w PARAMS_008649,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_00860E
	LDY.b #($01<<!Define_SMW_TilemapUploadDMAChannel)			; DMA something to VRAM, my guess is a tilemap...
	STY.w !REGISTER_DMAEnable	; Regular DMA Channel Enable
	LDA.b #$38			;\ YXPCCCTT to use for the blank tile.
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b #$80			;\ Two byte VRAM upload.
	STA.w !REGISTER_VRAMAddressIncrementValue	;/
	STZ.w !REGISTER_VRAMAddressLo	;\
	LDA.b #!VRAM_SMW_Layer3TilemapVRAMLocation>>8	;| Upload tilemap to Layer 3.
	STA.w !REGISTER_VRAMAddressHi	;/
	LDX.b #$06			; And Repeat the DMA
CODE_00862F:
	LDA.w PARAMS_008649,x
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Parameters,x
	DEX
	BPL.b CODE_00862F
	LDA.b #!REGISTER_WriteToVRAMPortHi	; \but change desination address to $2119
	STA.w DMA[!Define_SMW_TilemapUploadDMAChannel].Destination	; / ; B Address
	STY.w !REGISTER_DMAEnable	; Start DMA ; Regular DMA Channel Enable
	STZ.b !RAM_SMW_Mirror_OAMAddressLo	; Clear the current OAM address.
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt	;\ Clear OAM data.
	JMP.w SMW_UploadOAMBuffer_Main	;/

PARAMS_008649:
	db $08,!REGISTER_WriteToVRAMPortLo
	dl !RAM_SMW_Misc_ScratchRAM00
	dw $1000
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeFirst8KBOfRAM(Address)
namespace SMW_InitializeFirst8KBOfRAM
%InsertMacroAtXPosition(<Address>)

; Clear RAM subroutine. This is part of the reset routine. Specifically, it
; clears ram $00-$FF (direct page), $0200-$1FFF, $0681 and the stripe image
; table (by setting $7F837B to #$0000 and the start of $7F837D to #$FF).
Main:
#LM160Hijack_ClearExAnimationDMASize:
	REP.b #$30				;\ LM: Hijacks here to jump to a routine in the expanded area that clears out the ExAnimation DMA size RAM addresses.
	LDX.w #$1FFE				;/ Most likely used to prevent VRAM corruption
CODE_008A53:
#SA1Pack_VectorJMLsAndClearSA1RAM:
if defined("Define_SMW_SA1")
	JSL.l ClearStack
	RTS
	NOP #4
	JML.l mmc_rom_reset
	; The Super MMC's bank-switch values, read back by the pack's own MMC code.
if !Define_Global_ROMSize > !ROMSize_4MB
	db $04,$05,$06,$07
else
	db $80,$81,$82,$83
endif
else
	STZ.b !RAM_SMW_Misc_ScratchRAM00,x	;>Clears out (in 16-bit) $0000-$0100 and $01FF-$1FFE
CODE_008A55:
	DEX				;\Decrement x twice
	DEX				;/
	CPX.w #!RAM_SMW_Misc_StartOfStack	;\clear out if index or address is $01FF
	BPL.b CODE_008A61		;/or higher
	CPX.w #!RAM_SMW_Misc_EndOfStack	;\if index/address < $01FF and > $0100 ($0100 to $01FF), loop back
	BPL.b CODE_008A55		;/without clearing (pretty inefficient, due to not having a seperate loop).
CODE_008A61:
	CPX.w #$FFFE			;\If index goes invalid (past $0000), break out the loop.
endif
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace off
incsrc "asm/inline/008A64.asm"
namespace SMW_InitializeFirst8KBOfRAM
else
	BNE.b CODE_008A53		;/(and clear selected address)
	LDA.w #$0000			;\
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo	;| Initialize the stripe image and palette upload tables.
	STZ.w !RAM_SMW_Palettes_DynamicPaletteUploadIndex	;| (the palette upload table is unnecessary though since it's cleared above).
	SEP.b #$30			;| AXY->8
	LDA.b #$FF			;|
	STA.l SMW_StripeImageUploadTable[$00].LowByte	;/
endif
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_ClearOverworldAndCutsceneRAM(Address)
namespace SMW_ClearOverworldAndCutsceneRAM
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$10			; XY->16
if defined("Define_SMW_SA1")
	; SA-1 Pack: This is a special hijack used to reset the values in all IRAM
	; sprite tables to 0. It gets called on level load.
	JSL.l SPRITE_IRAM_RESET
	NOP
else
	SEP.b #$20			; A->8
	LDX.w #$00BD
endif
CODE_00A1AD:
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x	; |Clear RAM addresses $1A-$D7
	DEX
	BPL.b CODE_00A1AD
	LDX.w #$07CE
CODE_00A1B5:
	STZ.w !RAM_SMW_Timer_PreventPause,x	; |Clear RAM addresses $13D3-$1BA1
	DEX
	BPL.b CODE_00A1B5
	SEP.b #$10			; XY->8
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSprStatus06_GoalCoins(Address)
namespace SMW_NorSprStatus06_GoalCoins
%InsertMacroAtXPosition(<Address>)

SmokeTiles:
	db $66,$64,$62,$60

UnusedCoinTiles:						;\ Note: A leftover from when the coin sprites used 16x16 tiles for all their frames.
	db $E8,$EA,$EC,$EA					;/

; Routine that handles sprites turned into a coin by the goal tape. It's a
; JSL wrapper to the subroutine at $00FBB4.
Sub:
	PHB
	PHK
	PLB
	JSR.w +
	PLB
	RTL

+:
	; Routine that handles sprites turned into a coin by the goal tape. It
	; first makes the coin appear as a smoke cloud until $1540,x is 0, then it
	; draws the coin, handles its movement and finally it gives Mario a coin,
	; erasing the sprite permanently.
	LDY.b #$00
	LDA.w !RAM_SMW_Misc_Layer1XDisp
	BPL.b CODE_00FBBC
	DEY
CODE_00FBBC:
	CLC
	ADC.b !RAM_SMW_NorSpr_XPosLo_x
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	TYA
	ADC.w !RAM_SMW_NorSpr_XPosHi,x
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.w !RAM_SMW_NorSprStatus06_GoalCoins_WaitBeforeTurningIntoCoin,x
	BEQ.b CODE_00FBF0
	CMP.b #$01
	BNE.b CODE_00FBD5
	LDA.b #$D0
	STA.b !RAM_SMW_NorSpr_YSpeed,x
CODE_00FBD5:
	PHX
	LDA.b #$04			; \ Use Palette A
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JSL.l SMW_GenericGFXRtDraw1Tile16x16_Main
	LDA.w !RAM_SMW_NorSprStatus06_GoalCoins_WaitBeforeTurningIntoCoin,x
	LSR
	LSR
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x	; Y = Index into sprite OAM
	TAX
	LDA.w SmokeTiles,x
	STA.w SMW_OAMBuffer[$40].Tile,y
	PLX
	RTS

CODE_00FBF0:
	INC.w !RAM_SMW_NorSprStatus06_GoalCoins_UnknownRAM,x
	JSL.l SMW_UpdateNormalSpritePositionBank01_Main_Y
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	INC.b !RAM_SMW_NorSpr_YSpeed,x
	LDA.b !RAM_SMW_NorSpr_YSpeed,x
	CMP.b #$20
	BMI.b CODE_00FC1E
	JSL.l SMW_GiveCoins_OneCoin
	LDA.w !RAM_SMW_Counter_GoalCoinPointsIndex
	CMP.b #$0D						;\ Glitch: #$0D should be changed to #$0B to prevent the glitched score sprites from spawning
	BCC.b CODE_00FC0E					;| GivePoints_Main adds #$05 to !RAM_SMW_Counter_GoalCoinPointsIndex's value, resulting in the glitched score sprite 11 (give 5 coins) spawning if at least 7 sprites are turning into coins at a goal
	LDA.b #$0D						;/
CODE_00FC0E:
	JSL.l SMW_GivePoints_Main
	LDA.w !RAM_SMW_Counter_GoalCoinPointsIndex
	CLC
	ADC.b #$02
	STA.w !RAM_SMW_Counter_GoalCoinPointsIndex
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
CODE_00FC1E:
	JSL.l SMW_PowerUpAndItemGFXRt_DrawCoinSprite_Main
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenerateTile(Address)
namespace SMW_GenerateTile
%InsertMacroAtXPosition(<Address>)

; SMW's Map16-tile-generating routine. It uses values of $9C to determine
; which tile to generate, but these values are hardcoded. (See RAM address
; $9C.) This is the main part; $00BFBC runs the codes for each tile.
Main:
	PHP
	REP.b #$30			; AXY->16
	PHX
	LDA.b !RAM_SMW_Blocks_Map16ToGenerate
	AND.w #$00FF
	BNE.b CODE_00BEBE
ADDR_00BEBB:
	JMP.w CODE_00BFB9

CODE_00BEBE:
	LDA.b !RAM_SMW_Blocks_XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.b !RAM_SMW_Blocks_YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w #$0000
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	BEQ.b CODE_00BED6
	LSR.b !RAM_SMW_Misc_ScratchRAM09
CODE_00BED6:
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	AND.b #$01
	BEQ.b CODE_00BEEC
	LDA.b !RAM_SMW_Blocks_XPosHi
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Blocks_YPosHi
	STA.b !RAM_SMW_Blocks_XPosHi
	LDA.b !RAM_SMW_Misc_ScratchRAM00
#LM300Hijack_CustomLevelDimensions10:
	STA.b !RAM_SMW_Blocks_YPosHi
	LDY.b !RAM_SMW_Misc_ScratchRAM0C
CODE_00BEEC:
	CPY.w #$0200
	BCS.b ADDR_00BEBB
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	ASL
	TAX
	LDA.l SMW_LevelDataLayoutTables_LoTablePtrs,x	; Set low byte of pointer
	STA.b !RAM_SMW_Pointer_Layer1DataLo
	LDA.l SMW_LevelDataLayoutTables_LoTablePtrs+$01,x	; Set middle byte of pointer
	STA.b !RAM_SMW_Pointer_Layer1DataHi
if ver_is_smasw(!Define_Global_ROMToAssemble)
	LDA.b #SMW_LevelDataLayoutTables_LoTablePtrs>>16		; Note: Bank 30
	STA.b !RAM_SMW_Pointer_Layer1DataBank
else
	STZ.b !RAM_SMW_Pointer_Layer1DataBank 			; #!BANK_00
endif
	LDA.w !RAM_SMW_Misc_LevelModeSetting
	ASL
	TAY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y
	STA.b !RAM_SMW_Misc_ScratchRAM05
if ver_is_smasw(!Define_Global_ROMToAssemble)
	LDA.b #SMW_LevelDataLayoutTables_LoTablePtrs>>16			; Note: !BANK_30
	STA.b !RAM_SMW_Misc_ScratchRAM06
else
	STZ.b !RAM_SMW_Misc_ScratchRAM06 				; Note: !BANK_00
endif
	LDA.b !RAM_SMW_Blocks_XPosHi
	STA.b !RAM_SMW_Misc_ScratchRAM07
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM07
	TAY
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataBank
	INC
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataBank
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	AND.b #$01
	BEQ.b CODE_00BF41							; LM: Modifies this branch to account for the below hijack
	LDA.b !RAM_SMW_Blocks_YPosHi
	LSR
	LDA.b !RAM_SMW_Blocks_XPosHi
	AND.b #$01								;\ LM: Modifies this area to account for the custom level dimensions
	JMP.w CODE_00BF46							;|
										;|
CODE_00BF41:									;|
	LDA.b !RAM_SMW_Blocks_XPosHi						;|
	LSR									;|
	LDA.b !RAM_SMW_Blocks_YPosHi						;|
CODE_00BF46:									;|
	ROL									;|
	ASL									;|
	ASL									;/
	ORA.b #$20
	STA.b !RAM_SMW_Misc_ScratchRAM04
	CPX.w #$0000
	BEQ.b CODE_00BF57
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_00BF57:
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.b #$F0
	CLC
	ASL
	ROL
	STA.b !RAM_SMW_Misc_ScratchRAM05
	ROL
	AND.b #$03
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Blocks_XPosLo
	AND.b #$F0
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	AND.b #$C0
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM07
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	AND.w #$0001
	BNE.b CODE_00BF9B
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo					;\ LM: Modifies this area to account for the custom level dimensions
	SEC										;|
	SBC.w #$0080									;|
	TAX										;|
	LDY.b !RAM_SMW_Mirror_CurrentLayer1YPosLo					;|
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo				;|
	BEQ.b CODE_00BFB2								;|
	LDX.b !RAM_SMW_Mirror_CurrentLayer2XPosLo					;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo					;|
	SEC										;|
	SBC.w #$0080									;|
	TAY										;|
	JMP.w CODE_00BFB2								;/

CODE_00BF9B:
	LDX.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	SEC
	SBC.w #$0080
	TAY
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	BEQ.b CODE_00BFB2
	LDA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	SEC
	SBC.w #$0080
	TAX
	LDY.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
CODE_00BFB2:
	STX.b !RAM_SMW_Misc_ScratchRAM08
	STY.b !RAM_SMW_Misc_ScratchRAM0A
	JSR.w CODE_00BFBC
CODE_00BFB9:
	PLX
	PLP
	RTL

; A subroutine used with $00BEB0; it runs different codes depending on the
; value of $9C. The pointers for the different values begin at $00BFC9. They
; go from 01 to 1B, although the actual codes are kind of weird...the
; pointers vary depending on which Map16 page the tile is on, whether or not
; item memory should be affected, and if there are special cases (such as
; the Yoshi coin, which generates two tiles simultaneously).
CODE_00BFBC:
	SEP.b #$30			; AXY->8
	LDA.b !RAM_SMW_Blocks_Map16ToGenerate
	DEC
	PHK
	PER.w TileGenerationPtr-$01
if defined("Define_SMW_SA1")
	JML.l CheckForSA1
else
	JML.l SMW_ExecutePtr_Absolute	; $9C - Tile generated
endif

TileGenerationPtr:
	dw SMW_GenericPage00Tile_SetItemMemory		; Empty Tile (Sets Item Memory)
	dw SMW_GenericPage00Tile_Main			; Empty Tile
	dw SMW_GenericPage00Tile_Main			; Vine
	dw SMW_GenericPage00Tile_Main			; Empty Bush Tile
	dw SMW_GenericPage00Tile_Main			; Spinning Turn Block
	dw SMW_GenericPage00Tile_Main			; Coin
	dw SMW_GenericPage00Tile_Main			; Mushroom Stalk
	dw SMW_GenericPage00Tile_Main			; Mole Hole
	dw SMW_GenericPage01Tile_Main			; Invisible Solid Block
	dw SMW_GenericPage01Tile_Main			; Multi Coin Turn Block
	dw SMW_GenericPage01Tile_Main			; Multi Coin Block
	dw SMW_GenericPage01Tile_Main			; Empty Turn Block
	dw SMW_GenericPage01Tile_Main			; Used Block
	dw SMW_GenericPage01Tile_Main			; Note Block
	dw SMW_GenericPage01Tile_Main			; Unused Note Block
	dw SMW_GenericPage01Tile_Main			; 4-way Note Block
	dw SMW_GenericPage01Tile_Main			; Side Bounce Turn Block
	dw SMW_GenericPage01Tile_Main			; Translucent Block
	dw SMW_GenericPage01Tile_Main			; On/Off Block
	dw SMW_GenericPage01Tile_Main			; Left vertical pipe side
	dw SMW_GenericPage01Tile_Main			; Right vertical pipe side
	dw SMW_GenericPage01Tile_SetItemMemory		; Used Block (Sets Item Memory)
	dw SMW_GenericPage01Tile_SetItemMemory		; O Block from 1up game (Sets Item Memory)
	dw SMW_EraseYoshiCoin_Main			; Erase Yoshi coin
	dw SMW_ChangeNetDoorTiles_Main			; Empty net frame
	dw SMW_ChangeNetDoorTiles_Main			; Net door
	dw SMW_EraseLargeSwitch_Main			; Erase Switch Palace Switch
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetItemMemoryBit(Address)
namespace SMW_SetItemMemoryBit
%InsertMacroAtXPosition(<Address>)

DATA_00BFFF:
	dw !RAM_SMW_Misc_ItemMemory0Bits-!RAM_SMW_Misc_ItemMemoryBits
	dw !RAM_SMW_Misc_ItemMemory1Bits-!RAM_SMW_Misc_ItemMemoryBits
	dw !RAM_SMW_Misc_ItemMemory2Bits-!RAM_SMW_Misc_ItemMemoryBits

DATA_00C005:
	db $80,$40,$20,$10,$08,$04,$02,$01

Main:
;$00C00D
	; The subroutine that sets item memory bits. It is called during the
	; subroutine at $00BEB0 for values of $9C that utilize item memory.
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Blocks_XPosLo
	AND.w #$FF00
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Blocks_XPosLo
	AND.w #$0080
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.w #$0100
	BEQ.b CODE_00C03A
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	ORA.w #$0002
	STA.b !RAM_SMW_Misc_ScratchRAM04
CODE_00C03A:
	LDA.w !RAM_SMW_Misc_ItemMemorySetting
	AND.w #$000F
	ASL
	TAX
	LDA.l DATA_00BFFF,x
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Misc_ScratchRAM04
	TAY
	LDA.b !RAM_SMW_Blocks_XPosLo
	AND.w #$0070
	LSR
	LSR
	LSR
	LSR
	TAX
	SEP.b #$20			; A->8
#LM171Hijack_ItemMemory3Revamp1:
	LDA.w !RAM_SMW_Misc_ItemMemoryBits,y			;\ LM: Hijacks here to make item memory index 3 not track items collected (1.71+)
	ORA.l DATA_00C005,x					;/
	STA.w !RAM_SMW_Misc_ItemMemoryBits,y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenericPage00Tile(Address)
namespace SMW_GenericPage00Tile
%InsertMacroAtXPosition(<Address>)

UNK_00C063:
	db $7F,$BF,$DF,$EF,$F7,$FB,$FD,$FE

; Tiles to generate on Map16 page 0, used for values 01-09 of $9C. Note that
; the first byte is unused.
Map16Page00TileLo:
	db $25		; Blank tile (Unused?)
	db $25		; Blank tile
	db $25		; Blank tile
	db $06		; Vine
	db $49		; Empty bush tile
	db $48		; Spinning turn block
	db $2B		; Coin
	db $A2		; Mushroom stalk
	db $C6		; Mole hole

; SMW's subroutine for generating tiles on Map16 page 0. $00C077 is an
; alternate entry point to this routine; if it is used instead, then the
; tile generation will not affect item memory.
SetItemMemory:
	JSR.w SMW_SetItemMemoryBit_Main
Main:
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.w #$01F0
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Blocks_XPosLo
	LSR
	LSR
	LSR
	LSR
	AND.w #$000F
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	TAY
	LDA.b !RAM_SMW_Blocks_Map16ToGenerate	; \ X = index of tile to generate
	AND.w #$00FF
	TAX
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y	; \ Reset #$01 bit
#LM000Hijack_MoreLevelMap16_1:
if !Define_SMW_CustomTiles == !TRUE
	AND.b #$00						;> Page 0 outright: the tile here may be on a custom page (Config/CustomTiles.asm)
else
	AND.b #$FE						; LM: Changes this to AND.b #$00 to prevent issues with map16 IDs above 01FF.
endif
	STA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	LDA.l Map16Page00TileLo,x	; \ Store tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	REP.b #$20			; A->16
	AND.w #$00FF
	ASL
	TAY
	JMP.w SMW_GenericPage01Tile_CODE_00C0FB
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GenericPage01Tile(Address)
namespace SMW_GenericPage01Tile
%InsertMacroAtXPosition(<Address>)

UNK_00C0AA:
	db $80,$40,$20,$10,$08,$04,$02,$01

; Tiles to generate on Map16 page 1, used for values 0A-17 of $9C.
Map16Page01TileLo:
	db $52		; Solid invisible tile
	db $1B		; Turn block with multiple coins
	db $23		; Question block with multiple coins
	db $1E		; Turn block (spins when hit)
	db $32		; Used block
	db $13		; Note block
	db $15		; Unused note block
	db $16		; 4 sided note block
	db $2B		; Turn block (side bounce)
	db $2C		; Glass block
	db $12		; On/Off block
	db $68		; Left vertical pipe side (tileset specific, always green)
	db $69		; Right vertical pipe side (tileset specific, always green)
	db $32		; Used block
	db $5E		; O block (Switch palace tileset)

; A portion of code used in SMW for generating tiles on Map16 page 1.
; $00C0C4 is an alternate entry point to this routine; if it is used
; instead, then the tile generation will not affect item memory.
SetItemMemory:
	JSR.w SMW_SetItemMemoryBit_Main	;;;;;A big part of the block generation routines here!;;;;;;;;;;;;
Main:
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.w #$01F0
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Blocks_XPosLo
	LSR
	LSR
	LSR
	LSR
	AND.w #$000F
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	TAY
	LDA.b !RAM_SMW_Blocks_Map16ToGenerate	; \ X = index of tile to generate
	SEC
	SBC.w #$0009
	AND.w #$00FF
	TAX
	SEP.b #$20			; A->8
	LDA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y	; \ Set #$01 bit
#LM000Hijack_MoreLevelMap16_2:
if !Define_SMW_CustomTiles == !TRUE
	LDA.b #$01						;> Page 1 outright: the tile here may be on a custom page (Config/CustomTiles.asm)
else
	ORA.b #$01						; LM: Changes this to LDA.b #$01 to prevent issues with map16 IDs above 01FF.
endif
	STA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	LDA.l Map16Page01TileLo,x	; \ Store tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	REP.b #$20			; A->16
	AND.w #$00FF
	ORA.w #$0100
	ASL
	TAY
; The portion of code in SMW's Map16-tile-generating routine that changes
; the actual graphics of the tile. Both $00C074 and $00C0C1 use it (the
; former jumps to it, and it immediately follows the latter).
CODE_00C0FB:
if defined("Define_SMW_SA1")
	JSL.l level_mode_stripe_help
else
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	STA.b !RAM_SMW_Misc_ScratchRAM00
endif
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	BEQ.b CODE_00C106
	LSR.b !RAM_SMW_Misc_ScratchRAM00
CODE_00C106:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$0001
	BNE.b CODE_00C127
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	AND.w #$FFF0
	BMI.b CODE_00C11A
	CMP.b !RAM_SMW_Misc_ScratchRAM0C
	BEQ.b CODE_00C13E
	BCS.b CODE_00C124
CODE_00C11A:
	CLC
	ADC.w #$0200
	CMP.b !RAM_SMW_Misc_ScratchRAM0C
	BEQ.b CODE_00C124
	BCS.b CODE_00C13E
CODE_00C124:
	JMP.w Return00C1AB

CODE_00C127:
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.w #$FFF0
	BMI.b CODE_00C134
	CMP.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b CODE_00C13E
	BCS.b Return00C1AB
CODE_00C134:
	CLC
	ADC.w #$0200
	CMP.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b Return00C1AB
	BCC.b Return00C1AB
CODE_00C13E:
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	STA.l SMW_StripeImageUploadTable[$04].LowByte,x
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	STA.l SMW_StripeImageUploadTable[$00].HighByte,x
	CLC
	ADC.b #$20
	STA.l SMW_StripeImageUploadTable[$04].HighByte,x
	LDA.b #$00
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	STA.l SMW_StripeImageUploadTable[$05].LowByte,x
	LDA.b #$03
	STA.l SMW_StripeImageUploadTable[$01].HighByte,x
	STA.l SMW_StripeImageUploadTable[$05].HighByte,x
	LDA.b #$FF
	STA.l SMW_StripeImageUploadTable[$08].LowByte,x
	LDA.b #SMW_Map16Data_Main>>16
	STA.b !RAM_SMW_Misc_ScratchRAM06
#LM000Hijack_Unknown00C17A:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Pointer_Map16Tiles,y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDY.w #$0000
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.l SMW_StripeImageUploadTable[$06].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.l SMW_StripeImageUploadTable[$03].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.l SMW_StripeImageUploadTable[$07].LowByte,x
	TXA
	CLC
	ADC.w #$0010
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
Return00C1AB:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_EraseYoshiCoin(Address)
namespace SMW_EraseYoshiCoin
%InsertMacroAtXPosition(<Address>)

Main:							;\ Glitch: This routine only affects the low byte of the map16 number instead of both the low and high byte.
							;/ This is why duplicating a block over a Yoshi coin causes that tile to turn into 125.
	JSR.w SMW_SetItemMemoryBit_Main
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.w #$01F0
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Blocks_XPosLo
	LSR
	LSR
	LSR
	LSR
	AND.w #$000F
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	TAY
	SEP.b #$20			; A->8
	LDA.b #$25
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	REP.b #$20			; A->16
	TYA						;\ Glitch: This code doesn't account for crossing a screen boundry!
	CLC						;| This is why only half of the coin despawns.
	ADC.w #$0010					;|
	TAY						;/
	SEP.b #$20			; A->8
	LDA.b #$25
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	REP.b #$20			; A->16
	AND.w #$00FF
	ASL
	TAY
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	BEQ.b CODE_00C1EA
	LSR.b !RAM_SMW_Misc_ScratchRAM00
CODE_00C1EA:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$0001
	BNE.b CODE_00C20B
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	AND.w #$FFF0
	BMI.b CODE_00C1FE
	CMP.b !RAM_SMW_Misc_ScratchRAM0C
	BEQ.b CODE_00C222
	BCS.b SMW_GenericPage01Tile_Return00C1AB
CODE_00C1FE:
	CLC
	ADC.w #$0200
	CMP.b !RAM_SMW_Misc_ScratchRAM0C
	BCC.b SMW_GenericPage01Tile_Return00C1AB
	BEQ.b SMW_GenericPage01Tile_Return00C1AB
	JMP.w CODE_00C222

CODE_00C20B:
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.w #$FFF0
	BMI.b CODE_00C218
	CMP.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b CODE_00C222
	BCS.b SMW_GenericPage01Tile_Return00C1AB
CODE_00C218:
	CLC
	ADC.w #$0200
	CMP.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b SMW_GenericPage01Tile_Return00C1AB
	BCC.b SMW_GenericPage01Tile_Return00C1AB
CODE_00C222:
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	STA.l SMW_StripeImageUploadTable[$06].LowByte,x
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	STA.l SMW_StripeImageUploadTable[$00].HighByte,x
	INC
	STA.l SMW_StripeImageUploadTable[$06].HighByte,x
	LDA.b #$80
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	STA.l SMW_StripeImageUploadTable[$07].LowByte,x
	LDA.b #$07
	STA.l SMW_StripeImageUploadTable[$01].HighByte,x
	STA.l SMW_StripeImageUploadTable[$07].HighByte,x
	LDA.b #$FF
	STA.l SMW_StripeImageUploadTable[$0C].LowByte,x
	LDA.b #SMW_Map16Data_Main>>16
	STA.b !RAM_SMW_Misc_ScratchRAM06
#LM000Hijack_Unknown00C25C:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Pointer_Map16Tiles,y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDY.w #$0000
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	STA.l SMW_StripeImageUploadTable[$04].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.l SMW_StripeImageUploadTable[$08].LowByte,x
	STA.l SMW_StripeImageUploadTable[$0A].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.l SMW_StripeImageUploadTable[$03].LowByte,x
	STA.l SMW_StripeImageUploadTable[$05].LowByte,x
	INY
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM04],y
	STA.l SMW_StripeImageUploadTable[$09].LowByte,x
	STA.l SMW_StripeImageUploadTable[$0B].LowByte,x
	TXA
	CLC
	ADC.w #$0018
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ChangeNetDoorTiles(Address)
namespace SMW_ChangeNetDoorTiles
%InsertMacroAtXPosition(<Address>)

; BG Tiles/Palette for Flipped Gate (1)
Open:
	dw $9C99,$1C8B,$1C8B,$1C8B,$1C8B,$DC99		; Info: /----\
	dw $1C9B,$1CF8,$1CF8,$1CF8,$1CF8,$5C9B		;	|    |
	dw $1C9B,$1CF8,$1CF8,$1CF8,$1CF8,$5C9B		;	|    |
	dw $1C9B,$1CF8,$1CF8,$1CF8,$1CF8,$5C9B		;	|    |
	dw $1C9B,$1CF8,$1CF8,$1CF8,$1CF8,$5C9B		;	|    |
	dw $1C99,$9C8B,$9C8B,$9C8B,$9C8B,$5C99		;	\----/

; BG Tiles/Palette for Flipped Gate (2)
Closed:
	dw $9CBA,$1CAB,$1CAB,$1CAB,$1CAB,$DCBA		; Info: /----\
	dw $1CAA,$1C82,$1C82,$1C82,$1C82,$5CAA		;	|XXXX|
	dw $1CAA,$1C82,$1C82,$1C82,$1C82,$5CAA		;	|XXXX|
	dw $1CAA,$1C82,$1C82,$1C82,$1C82,$5CAA		;	|XXXX|
	dw $1CAA,$1C82,$1C82,$1C82,$1C82,$5CAA		;	|XXXX|
	dw $1CBA,$9CAB,$9CAB,$9CAB,$9CAB,$5CBA		;	\----/

DATA_00C32E:
	dl Open
	dl Closed

Main:
	INC.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	CLC
	ADC.b #$20
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Blocks_Map16ToGenerate
	SEC
	SBC.b #$19
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAX
	LDA.l DATA_00C32E+$02,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	REP.b #$30			; AXY->16
	LDA.l DATA_00C32E,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	LDY.w #$0005
CODE_00C365:
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	STA.l SMW_StripeImageUploadTable[$00].HighByte,x
	LDA.b #$00
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	LDA.b #$0B
	STA.l SMW_StripeImageUploadTable[$01].HighByte,x
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	CLC
	ADC.b #$20
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM06
	REP.b #$20			; A->16
	TXA
	CLC
	ADC.w #$0010
	TAX
	DEY
	BPL.b CODE_00C365
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	LDY.w #$0000
CODE_00C39F:
	LDA.w #$0005
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_00C3A4:
	LDA.b [!RAM_SMW_Misc_ScratchRAM02],y
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	INY
	INY
	INX
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_00C3A4
	TXA
	CLC
	ADC.w #$0004
	TAX
	CPY.w #$0048
	BNE.b CODE_00C39F
	LDA.w #$00FF
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	CLC
	ADC.w #$0060
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_EraseLargeSwitch(Address)
namespace SMW_EraseLargeSwitch
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.w #$01F0
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Blocks_XPosLo
	LSR
	LSR
	LSR
	LSR
	AND.w #$000F
	ORA.b !RAM_SMW_Misc_ScratchRAM04
	TAY
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	SEP.b #$20			; A->8
	LDA.b #$25
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	INY
	LDA.b #$25
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	REP.b #$20			; A->16
	TYA
	CLC
	ADC.w #$0010
	TAY
	SEP.b #$20			; A->8
	LDA.b #$25
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	DEY
	LDA.b #$25
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	LDY.w #$0003
CODE_00C40C:
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	STA.l SMW_StripeImageUploadTable[$00].HighByte,x
	LDA.b #$40
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	LDA.b #$06
	STA.l SMW_StripeImageUploadTable[$01].HighByte,x
	REP.b #$20			; A->16
	LDA.w #$18F8
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	TXA
	CLC
	ADC.w #$0006
	TAX
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	CLC
	ADC.b #$20
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	ADC.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM06
	DEY
	BPL.b CODE_00C40C
	LDA.b #$FF
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	REP.b #$20			; A->16
	TXA
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UploadGraphicsFiles(Address)
namespace SMW_UploadGraphicsFiles
%InsertMacroAtXPosition(<Address>)

; 26x4 byte table, Sprite GFX list. Normal levels can use 00-0F, but the
; following values have also been observed: 10: [00 00 00 08] Unused? 11:
; [10 0F 1C 1D] Overworld 12: [00 01 24 22] Morton, Roy, Ludwig 13: [00 01
; 25 22] Iggy, Larry, Reznor 14: [00 22 13 2D] Castle destruction sequence
; 15: [00 01 0F 22] Walking home during the credits 16: [00 26 2E 22]
; Yoshi's House during the credits 17: [21 0B 25 0A] Boss list from the
; credits 18: [00 0D 24 22] Bowser 19: [2C 30 2D 0E] THE END screen
SpriteGFXList:
	db $00,$01,$13,$02		; Tileset 0 (Forest)
	db $00,$01,$12,$03		; Tileset 1 (Castle)
	db $00,$01,$13,$05		; Tileset 2 (Mushroom)
	db $00,$01,$13,$04		; Tileset 3 (Underground)
	db $00,$01,$13,$06		; Tileset 4 (Water)
	db $00,$01,$13,$09		; Tileset 5 (Pokey)
	db $00,$01,$13,$04		; Tileset 6 (Underground 2)
	db $00,$01,$06,$11		; Tileset 7 (Ghost House)
	db $00,$01,$13,$20		; Tileset 8 (Banzai Bill)
	db $00,$01,$13,$0F		; Tileset 9 (Yoshi's House)
	db $00,$01,$13,$23		; Tileset A (Dino-Rhino)
	db $00,$01,$0D,$14		; Tileset B (Switch Palace)
	db $00,$01,$24,$0E		; Tileset C (Mecha-Koopa)
	db $00,$01,$0A,$22		; Tileset D (Wendy/Lemmy)
	db $00,$01,$13,$0E		; Tileset E (Ninji)
	db $00,$01,$13,$14		; Tileset F (Not Used)
	db $00,$00,$00,$08		; Unknown
	db $10,$0F,$1C,$1D		; Overworld
	db $00,$01,$24,$22		; Morton/Roy/Ludwig
	db $00,$01,$25,$22		; Reznor/Iggy/Larry Room
	db $00,$22,$13,$2D		; Castle Destruction Scene
	db $00,$01,$0F,$22		; Credits
	db $00,$26,$2E,$22		; Yoshi's House during Credits
	db $21,$0B,$25,$0A		; Bowser And Koopa Kid Credits Screen
	db $00,$0D,$24,$22		; Bowser Battle
	db $2C,$30,$2D,$0E		; The End screen

; 26x4 byte table, FG/BG GFX list. Normal levels can use 00-0E, but
; cutscenes set this to higher values.
FGAndBGGFXList:
	db $14,$17,$19,$15		; Tileset 0 (Normal 1)
	db $14,$17,$1B,$18		; Tileset 1 (Castle 1)
	db $14,$17,$1B,$16		; Tileset 2 (Rope 1)
	db $14,$17,$0C,$1A		; Tileset 3 (Underground 1)
	db $14,$17,$1B,$08		; Tileset 4 (Switch Palace 1)
	db $14,$17,$0C,$07		; Tileset 5 (Ghost House 1)
	db $14,$17,$0C,$16		; Tileset 6 (Rope 2)
	db $14,$17,$1B,$15		; Tileset 7 (Normal 2)
	db $14,$17,$19,$16		; Tileset 8 (Rope 3)
	db $14,$17,$0D,$1A		; Tileset 9 (Underground 2)
	db $14,$17,$1B,$08		; Tileset A (Switch Palace 2)
	db $14,$17,$1B,$18		; Tileset B (Castle 2)
	db $14,$17,$19,$1F		; Tileset C (Cloud/Forest)
	db $14,$17,$0D,$07		; Tileset D (Ghost House 2)
	db $14,$17,$19,$1A		; Tileset E (Underground 3)
	db $14,$17,$14,$14		; Tileset F (Unused)
	db $0E,$0F,$17,$17		; Unknown
	; Submap Foreground Graphics
	db $1C,$1D,$08,$1E		; Overworld (Main Map)
	db $1C,$1D,$08,$1E		; Overworld (Yoshi's Island)
	db $1C,$1D,$08,$1E		; Overworld (Vanilla Dome)
	db $1C,$1D,$08,$1E		; Overworld (Forest of Illusion)
	db $1C,$1D,$08,$1E		; Overworld (Valley of Bowser)
	db $1C,$1D,$08,$1E		; Overworld (Special World)
	db $1C,$1D,$08,$1E		; Overworld (Star Road)
	db $14,$17,$19,$2C		; Castle Destruction cutscene
	db $19,$17,$1B,$18		; Credits (?)

; Layer 3 GFX28 to 2B upload routine. Pages are uploaded in 64 tile chunks
; in four passes.
Layer3:
	STZ.w !REGISTER_VRAMAddressLo
	LDA.b #!VRAM_SMW_Layer3GFXVRAMLocation>>8	; |Set "Address for VRAM Read/Write" to x4000
	STA.w !REGISTER_VRAMAddressHi
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.b #$28
	STA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_00A9A3:
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	TAY
	JSL.l SMW_GraphicsDecompressionRoutines_Main
	REP.b #$30			; AXY->16
	LDX.w #$03FF
	LDY.w #$0000
CODE_00A9B2:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.w !REGISTER_WriteToVRAMPortLo	; Data for VRAM Write (Low Byte)
	INY
	INY
	DEX
	BPL.b CODE_00A9B2
	SEP.b #$30			; AXY->8
	INC.b !RAM_SMW_Misc_ScratchRAM0E
	DEC.b !RAM_SMW_Misc_ScratchRAM0F
	BPL.b CODE_00A9A3
	STZ.w !REGISTER_VRAMAddressLo
	LDA.b #!VRAM_SMW_SpriteGFXLocationLo>>8	; |Set "Address for VRAM Read/Write" to x6000
	STA.w !REGISTER_VRAMAddressHi
	LDY.b #$00
	JSR.w UploadGFXFile
	RTS

DATA_00A9D2:
	db (!VRAM_SMW_SpriteGFXLocationHi+$0800)>>8
	db (!VRAM_SMW_SpriteGFXLocationHi)>>8
	db (!VRAM_SMW_SpriteGFXLocationLo+$0800)>>8
	db !VRAM_SMW_SpriteGFXLocationLo>>8

DATA_00A9D6:
	db $18,$10,$08,$00

Main:
	LDA.b #$80			; Decompression as well?
	STA.w !REGISTER_VRAMAddressIncrementValue	; VRAM transfer control port
	LDX.b #$03
	LDA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting	; $192B = current sprite GFX list index
	ASL
	ASL				;  }4A -> Y
	TAY
if !Define_SMW_LevelGraphics == !TRUE
	; The same nine bytes as the loop below. The stub repeats the loop
	; and then, on a level load, lays the loading level's own row over the
	; four files it read: a row byte that is not $FF replaces the list's.
	; See Config/LevelGraphics.asm.
	JSL.l SMW_LevelGraphics_Sprites
	NOP #5				;> The bytes the displaced loop leaves, never anything else
else
CODE_00A9E7:
	LDA.w SpriteGFXList,y
	STA.b !RAM_SMW_Misc_ScratchRAM04,x
	INY
	DEX
	BPL.b CODE_00A9E7
endif
	LDA.b #$03			; #$03 -> A -> $0F
	STA.b !RAM_SMW_Misc_ScratchRAM0F
GFXTransferLoop:
	LDX.b !RAM_SMW_Misc_ScratchRAM0F	; $0F -> X
	STZ.w !REGISTER_VRAMAddressLo	; #$00 -> $2116
	LDA.w DATA_00A9D2,x		; My guess: Locations in VRAM to upload GFX to
	STA.w !REGISTER_VRAMAddressHi	; Set VRAM address to $??00
	LDY.b !RAM_SMW_Misc_ScratchRAM04,x	; Y is possibly which GFX file
	LDA.w !RAM_SMW_Misc_CurrentlyLoadedSpriteGraphicsFiles,x	; to upload to a section in VRAM, used in
	CMP.b !RAM_SMW_Misc_ScratchRAM04,x	; the subroutine $00:BA28
#LM000Hijack_AlwaysUploadSpriteGFX:
	BEQ.b DontUploadSpr						; LM: NOPs this branch out so that the Sprite graphics files are always reloaded to prevent issues with the ExAnimation feature
#LMRead_JSRToUploadGFXFileLoc1:
	JSR.w UploadGFXFile		; JSR to a JSL...
DontUploadSpr:
	DEC.b !RAM_SMW_Misc_ScratchRAM0F	; Decrement $0F
	BPL.b GFXTransferLoop		; if >= #$00, continue transfer
	LDX.b #$03
UpdtCrrntSpritGFX:
	LDA.b !RAM_SMW_Misc_ScratchRAM04,x	; |Update $0101-$0104 to reflect the new sprite GFX
	STA.w !RAM_SMW_Misc_CurrentlyLoadedSpriteGraphicsFiles,x	; |That's loaded now.
	DEX
	BPL.b UpdtCrrntSpritGFX
	LDA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad	; LDA Tileset
	CMP.b #$FE
	BCS.b HandleMode7BossGFX	; Branch to a routine that marks every FG/BG slot as holding no file
	LDX.b #$03
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting	; this routine is pretty close to the above
	ASL				; one, I'm guessing this does
	ASL				; object/BG GFX.
	TAY				; 4A -> Y
if !Define_SMW_LevelGraphics == !TRUE
	; The same nine bytes as the loop below, for the layer slots. See
	; Config/LevelGraphics.asm.
	JSL.l SMW_LevelGraphics_Layers
	NOP #5				;> The bytes the displaced loop leaves, never anything else
else
PrepLoadFGBG:
	LDA.w FGAndBGGFXList,y		; FG/BG GFX table
	STA.b !RAM_SMW_Misc_ScratchRAM04,x
	INY
	DEX
	BPL.b PrepLoadFGBG		; FG/Bg to upload -> $04 - $07
endif
	LDA.b #$03
	STA.b !RAM_SMW_Misc_ScratchRAM0F	; #$03 -> $0F
CODE_00AA35:
	LDX.b !RAM_SMW_Misc_ScratchRAM0F	; $0F -> X
	STZ.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDA.w DATA_00A9D6,x		; Load + Store VRAM upload positions
	STA.w !REGISTER_VRAMAddressHi	; Address for VRAM Read/Write (High Byte)
	LDY.b !RAM_SMW_Misc_ScratchRAM04,x
	LDA.w !RAM_SMW_Misc_CurrentlyLoadedLayerGraphicsFiles,x	; Check to see if the file to be uploaded already
	CMP.b !RAM_SMW_Misc_ScratchRAM04,x	; exists in the slot in VRAM - if so,
#LM000Hijack_AlwaysUploadFGAndBGGFX:
	BEQ.b NoUploadFGBG						; LM: NOPs this branch out so that the FG and BG graphics files are always reloaded to prevent issues with the ExAnimation feature
#LMRead_JSRToUploadGFXFileLoc2:
	JSR.w UploadGFXFile		; Upload the GFX file
NoUploadFGBG:
	DEC.b !RAM_SMW_Misc_ScratchRAM0F	; Next GFX file
	BPL.b CODE_00AA35
#LM000Hijack_Unknown00AA50:
	LDX.b #$03							;\ LM: Puts a JSL.l to $0FF780 and skips the rest of the code in indicated by this comment. Purpose currently unknown.
UpdateCurrentFGBG:							;|
	LDA.b !RAM_SMW_Misc_ScratchRAM04,x				;|
	STA.w !RAM_SMW_Misc_CurrentlyLoadedLayerGraphicsFiles,x		;|
	DEX								;|
	BPL.b UpdateCurrentFGBG						;/
	RTS				; Return from uploading the GFX

HandleMode7BossGFX:
	BEQ.b NotIggyLarryOrReznor	; If zero flag set, don't update the tileset
	JSR.w ConvertGFX27IntoNormallFormat
NotIggyLarryOrReznor:
	LDX.b #$03
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	LDA.b #$FF			;> A number no file has: $80 is a file the managed graphics may add, and $FF never is
else
	LDA.b #$80			; my guess is that it gets called in the same set of routines
endif
Store80:
	STA.w !RAM_SMW_Misc_CurrentlyLoadedLayerGraphicsFiles,x
	DEX
	BPL.b Store80
	RTS

UploadGFXFile:
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	; The same four bytes as the JSL below. The stub makes that call, then
	; reads the file's format byte off the table at the head of the
	; graphics bank: a 3bpp file returns here to the expansion below, a
	; 4bpp file is copied to VRAM whole and the stub returns to this
	; routine's caller through UploadGFXFileDone. See
	; Config/ManagedGraphicsMemory.asm.
	JSL.l SMW_ManagedGraphics_Upload
else
	JSL.l SMW_GraphicsDecompressionRoutines_Main			; LM: Changes this JSL.l to point to $0FF160 here. Purpose currently unknown.
endif
	CPY.b #$01
	BNE.b SkipSpecial
	LDA.w !RAM_SMW_Overworld_LevelTileSettings+!Define_SMW_LevelID_ChangeSP2GFX
	; Change from 10 to 80 to disable the Koopas from using different graphics
	; after the special world is passed
	BPL.b SkipSpecial		; handle the post-special world graphics and koopa color swap.
	LDY.b #$31
	JSL.l SMW_GraphicsDecompressionRoutines_Main
	LDY.b #$01
SkipSpecial:
	REP.b #$20			; A->16
	LDA.w #$0000
	LDX.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad	; LDX Tileset
	CPX.b #$11			; CPX #$11
	BCC.b CODE_00AA90		; If Tileset < #$11 skip to lower area
#LM000Hijack_Unknown00AA8C:
	CPY.b #$08			; if Y = #$08 skip to JSR
	BEQ.b JumpTo_____
CODE_00AA90:
#LM000Hijack_Unknown00AA90:
	CPY.b #$1E			; If Y = #$1E then
	BEQ.b JumpTo_____		; JMP otherwise
	BNE.b CODE_00AA99		; don't JMP
JumpTo_____:
	JMP.w FilterSomeRAM

CODE_00AA99:
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w #$FFFF
	CPY.b #$01
	BEQ.b CODE_00AAA9
	CPY.b #$17
	BEQ.b CODE_00AAA9
	LDA.w #$0000
CODE_00AAA9:
	STA.w !RAM_SMW_Flag_Alter3BPPTo4BPPConversion
	LDY.b #$7F
CODE_00AAAE:
	LDA.w !RAM_SMW_Flag_Alter3BPPTo4BPPConversion
	BEQ.b CODE_00AACD
	CPY.b #$7E
	BCC.b CODE_00AABE
CODE_00AAB7:
	LDA.w #$FF00
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	BNE.b CODE_00AACD
CODE_00AABE:
	CPY.b #$6E
	BCC.b CODE_00AAC8
	CPY.b #$70
	BCS.b CODE_00AAC8
	BCC.b CODE_00AAB7
CODE_00AAC8:
	LDA.w #$0000
	STA.b !RAM_SMW_Misc_ScratchRAM0A
CODE_00AACD:
#LM000Hijack_Unknown00AACD:
	LDX.b #$07
CODE_00AACF:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]
	STA.w !REGISTER_WriteToVRAMPortLo	; Data for VRAM Write (Low Byte)
	XBA
	ORA.b [!RAM_SMW_Misc_ScratchRAM00]
	STA.w !RAM_SMW_Graphics_3BPPTo4BPPBuffer,x
	INC.b !RAM_SMW_Misc_ScratchRAM00
	INC.b !RAM_SMW_Misc_ScratchRAM00
	DEX
	BPL.b CODE_00AACF
	LDX.b #$07
CODE_00AAE3:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]
	XBA
	ORA.w !RAM_SMW_Graphics_3BPPTo4BPPBuffer,x
	AND.b !RAM_SMW_Misc_ScratchRAM0A
	ORA.b !RAM_SMW_Misc_ScratchRAM0C
	STA.w !REGISTER_WriteToVRAMPortLo	; Data for VRAM Write (Low Byte)
	INC.b !RAM_SMW_Misc_ScratchRAM00
	DEX
	BPL.b CODE_00AAE3
	DEY
	BPL.b CODE_00AAAE
	SEP.b #$20			; A->8
UploadGFXFileDone:
	RTS

FilterSomeRAM:
	LDA.w #$FF00
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDY.b #$7F
UploadToVRAM:
	CPY.b #$08					;\ Optimization: Useless
#LM000Hijack_4BPPGraphics:				;|
	BCS.b CODE_00AB0D 				;/ LM: Removes this BCS line so it can add a second INC.b !RAM_SMW_Misc_ScratchRAM00 down in the below loop.
CODE_00AB0D:
	LDX.b #$07
AddressWrite1:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]	; \ Okay, so take [$00], store
	STA.w !REGISTER_WriteToVRAMPortLo	; |it to VRAM, then bitwise
	XBA				; |OR the high and low bytes together
	ORA.b [!RAM_SMW_Misc_ScratchRAM00]	; |store in both bytes of A
	STA.w !RAM_SMW_Graphics_3BPPTo4BPPBuffer,x	; /and store to $1BB2,x
	INC.b !RAM_SMW_Misc_ScratchRAM00	; \Increment $7E:0000 by 2
	INC.b !RAM_SMW_Misc_ScratchRAM00
	DEX				; \And continue on another 7 times (or 8 times total)
	BPL.b AddressWrite1
	LDX.b #$07			; hm..  It's like a FOR Y{FOR X{ } } thing ...yeah...
AddressWrite2:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]
	AND.w #$00FF			; A normal byte becomes 2 anti-compressed bytes.
	STA.b !RAM_SMW_Misc_ScratchRAM0C	; I'm going up, to try and find out what's supposed to set $00-$02 for this routine.
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]	; AHA, check $00/BA28.  It writes a RAM address to $00-$02, $7EAD00
	XBA				; So...  Now to find otu what sets *That*
	ORA.w !RAM_SMW_Graphics_3BPPTo4BPPBuffer,x	; ...this place gives me headaches... Can't we work on some other code? :(
	AND.b !RAM_SMW_Misc_ScratchRAM0A	; Sure, go ahead.  anyways, this seems to upload the decompressed GFX
	ORA.b !RAM_SMW_Misc_ScratchRAM0C	; while scrambling it afterwards (o_O).
	STA.w !REGISTER_WriteToVRAMPortLo	; Okay... WHAT THE HELL?
	INC.b !RAM_SMW_Misc_ScratchRAM00	; I'll have nightmares about this routine for a few years. :(
	DEX
	BPL.b AddressWrite2		; Ouch.
	DEY
	BPL.b UploadToVRAM
	SEP.b #$20			; A->8
	RTS

ConvertGFX27IntoNormallFormat:
	LDY.b #$27
#CustomPatch_ConvertGFX27:
	JSL.l SMW_GraphicsDecompressionRoutines_Main
	REP.b #$10			; XY->16
	LDY.w #$0000
	LDX.w #$03FF
CODE_00AB50:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	JSR.w CODE_00ABC4
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	JSR.w CODE_00ABC4
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	STZ.b !RAM_SMW_Misc_ScratchRAM04
	ROL.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM04
	ROL.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM04
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	JSR.w CODE_00ABC4
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	JSR.w CODE_00ABC4
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	STZ.b !RAM_SMW_Misc_ScratchRAM04
	ROL.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM04
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM04
	ROL.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	JSR.w CODE_00ABC4
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	JSR.w CODE_00ABC4
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	INY
	DEX
	BPL.b CODE_00AB50
	LDX.w #$2000
CODE_00ABBB:
	STZ.w !REGISTER_WriteToVRAMPortHi	; Data for VRAM Write (High Byte)
	DEX
	BNE.b CODE_00ABBB
	SEP.b #$10			; XY->8
	RTS

CODE_00ABC4:
	STZ.b !RAM_SMW_Misc_ScratchRAM04
	ROL.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM04
	ROL.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM04
	ROL.b !RAM_SMW_Misc_ScratchRAM0F
	ROL.b !RAM_SMW_Misc_ScratchRAM04
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode29_DoNothingOnTheEndScreen(Address)
namespace SMW_GameMode29_DoNothingOnTheEndScreen
%InsertMacroAtXPosition(<Address>)

Main:
	RTS				; We did it!
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode21_DelayEnemyRollcall(Address)
namespace SMW_GameMode21_DelayEnemyRollcall
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l Bank03			; Fade.
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode19_Cutscene(Address)
namespace SMW_GameMode19_Cutscene
%InsertMacroAtXPosition(<Address>)

; Back area colours to use for each castle destruction scene (One byte per
; movie)
SkyColorSetting:
	db $02,$00,$04,$01,$00,$06,$04,$03

; Palette row (in the range 00-07) used by the castle in each castle
; destruction scene. 1 byte per scene.
BGPaletteSetting:
	db $06,$05,$06,$03,$03,$06,$06,$03

; Stripe image (index to pointers at $0084D0) to load as the background for
; each castle destruction scene.
BGToUse:
	db !Define_SMW_StripeImage_OverworldCutsceneBG		; Iggy (Overworld)
	db !Define_SMW_StripeImage_OverworldCutsceneBG		; Morton (Overworld)
	db !Define_SMW_StripeImage_CaveCutsceneBG		; Lemmy (Underground)
	db !Define_SMW_StripeImage_CookieMountainCutsceneBG	; Ludwig (Cookie Mountain)
	db !Define_SMW_StripeImage_OverworldCutsceneBG		; Roy (Overworld)
	db !Define_SMW_StripeImage_ChocolatIslandCutsceneBG	; Wendy (Chocolate Island)
	db !Define_SMW_StripeImage_CaveCutsceneBG		; Larry (Underground)

Main:
	JSR.w SMW_ClearLayer3Tilemap_Main	; Clean out Layer 3.
	JSR.w SMW_ClearOverworldAndCutsceneRAM_Main	; Clean out a large chunk of RAM.
	JSR.w SMW_SetStandardPPUSettings_Main	; Set up various registers (screen mode, CGADDSUB, windows...).
#LM000Hijack_Unknown009471:
	LDX.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene	; Cutscene number
	LDA.b #$18			;\
	STA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad	;| Set FG/BG and sprite GFX lists.
	LDA.b #$14			;|
	STA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting	;/
	LDA.w SkyColorSetting-$01,x	;\ Set back area color.
	STA.w !RAM_SMW_Misc_BackgroundColorSetting	;/
	LDA.w BGPaletteSetting-$01,x	;\ Set FG palette number.
	STA.w !RAM_SMW_Misc_BGPaletteSetting	;/
	STZ.w !RAM_SMW_Misc_SpritePaletteSetting	; Default sprite palette settings
	LDA.b #$01			;\ BG always uses #$01.
	STA.w !RAM_SMW_Misc_FGPaletteSetting	;/
	CPX.b #$08			;\ Branch if loading a castle destruction scene, not credits.
	BNE.b NotCredits		;/
	JSR.w SMW_UploadBigLayer3LettersToVRAM_Main	;> init the VRAM write
	LDA.b #!Define_SMW_StripeImage_CutsceneBorder	;\
	STA.b !RAM_SMW_Graphics_StripeImageToUpload	;| Turn Layer 3 completely black.
	JSR.w SMW_LoadStripeImage_Sub	;/
	JSR.w SMW_HandleSPCUploads_UploadCreditsMusicBank	; Upload the credits music bank.
	JSL.l SMW_BufferCreditsBackgrounds_Main	; Load the credits backgrounds.
	JSR.w SMW_SetupHDMAWindowingEffects_EndHDMA	; Disable HDMA.
	INC.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad	;\
	INC.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting	;/ +1 to tileset/Sprite GFX
	BRA.b CODE_0094D7

NotCredits:
	LDA.b #!Define_SMW_LevelMusic_RescueEgg	;\ SFX to use for the castle destruction cutscene.
	STA.w !RAM_SMW_IO_MusicCh1	;/
	LDA.w BGToUse-$01,x		;\
	STA.b !RAM_SMW_Graphics_StripeImageToUpload	;| Load BG tilemap.
	JSR.w SMW_LoadStripeImage_Sub	;/
	LDA.b #!Define_SMW_StripeImage_CutsceneCastle	;\
	STA.b !RAM_SMW_Graphics_StripeImageToUpload	;| Load FG tilemap.
	JSR.w SMW_LoadStripeImage_Sub	;/
	REP.b #$20			; A->16
	LDA.w #$0090			;\
	STA.b !RAM_SMW_Player_XPosLo	;|
	LDA.w #$0058			;| move mario offscreen
	STA.b !RAM_SMW_Player_YPosLo	;/ (usually will kill him..)
	SEP.b #$20			; A->8
	INC.w !RAM_SMW_Player_CarryingSomethingFlag2	; Mario is holding an object (Multi Use..?)
CODE_0094D7:
	JSR.w SMW_UploadGraphicsFiles_Main	; Upload GFX files.
	JSR.w SMW_BufferPalettesRoutines_Levels	; Load palettes from ROM to RAM.
	JSR.w SMW_UpdateEntirePalette_Main	; Upload palettes to CGRAM.
	LDX.b #$0B
CODE_0094E2:
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x
	DEX
	BPL.b CODE_0094E2
	LDA.b #$20			;\
	STA.b !RAM_SMW_Sprites_TilePriority	;/ Sprites use same palette
	JSR.w SMW_InitializeLevelRAM_Main
	STZ.b !RAM_SMW_Player_FacingDirection	; Default Direction
	STZ.b !RAM_SMW_Player_InAirFlag	; No flying!
	JSL.l SMW_SetPlayerPose_Main	; Animate Mario (and his cape).
	LDX.b #$17
	LDY.b #$00			; Put all layers and OBJ on the main screen
	JSR.w SMW_GameMode23_LoadEnemyRollcallScreen_CODE_009622
GameMode1BEntry:
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt	; Clear OAM.
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene	;\
	CMP.b #$08			;| Branch down if specifically running the credits.
	BEQ.b CODE_009557		;/
	LDA.b !RAM_SMW_IO_ControllerHold2
#Debug_BossSceneSelect:
	AND.b #!Joypad_None
	CMP.b #!Joypad_L|!Joypad_R
	BNE.b CODE_009529
	LDA.b !RAM_SMW_IO_ControllerHold1	;#\
	AND.b #!Joypad_DPadU>>8		;#|
	BEQ.b ADDR_009523		;#|
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene	;#| If up is also being held,
	INC				;#|  advance to the next boss cutscene.
	CMP.b #$09			;#|
	BCC.b ADDR_009520		;#|
	LDA.b #$01			;#|
ADDR_009520:
	STA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene	;#/
ADDR_009523:
	LDA.b #!Define_SMW_GameMode18_FadeOutToCutscene	;#\ Reload the scene.
	STA.w !RAM_SMW_Misc_GameMode	;#/
	RTS				;#

CODE_009529:
	JSL.l CODE_0CC97E		; Run the general cutscene routines (text writing, sprites, etc.)
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;\
	PHA				;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	PHA				;| Draw Mario/Yoshi relative to Layer 2 rather than Layer 1,
	LDA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo	;|  since Layer 1 is being used for the castle object.
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo	;|
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;/
	SEP.b #$20			; A->8
	JSL.l SMW_PlayerGFXRt_Main	; Draw Mario/Yoshi.
	REP.b #$20			; A->16
	PLA				;\
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;| Restore that position.
	PLA				;|
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;/
	SEP.b #$20			; A->8
	LDA.b #!Define_SMW_PlayerState0C_CastleDestructionMoves	;\ Set Mario's animation routine so that it can be automatically handled.
	STA.b !RAM_SMW_Player_CurrentState	;/
	JSR.w SMW_GameMode14_InLevel_CODE_00C47E	; Handle various gameplay-related routines (e.g. Mario-object interaction).
	JMP.w SMW_CompressOAMTileSizeBuffer_Main	; Prep OAM for upload.

CODE_009557:
	JSL.l SMW_GameMode1B_EndingCinema_Bank0C	; Run the main routine.
	JMP.w SMW_CompressOAMTileSizeBuffer_Main	; Prep OAM for upload.

namespace off
	%SetDuplicateOrNullPointer(SMW_GameMode19_Cutscene_GameMode1BEntry, SMW_GameMode1B_EndingCinema_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PlayerState0C_CastleDestructionMoves(Address)
namespace SMW_PlayerState0C_CastleDestructionMoves
%InsertMacroAtXPosition(<Address>)

; Special poses for the castle destruction scenes, written to $13E0. Used
; when a command from the movement data at $00C5EA has bit 5 set and its
; lower nibble between x7 and xF, with that value then indexing this table.
DATA_00C5E1:
	db $10
	db $30,$31
	db $32,$33,$34
	db $0E

CastleDestructionMovementData:
if ver_is_pal(!Define_Global_ROMToAssemble)
.Iggy:
	db $26,$11,$02,$3E,$00,$60,$01,$09
	db $80,$08,$00,$20,$04,$60,$00,$01
	db $FF
.Morton:
	db $01,$02,$3E,$00,$60,$41,$25,$C1
	db $04,$27,$04,$2F,$08,$25,$01,$2F
	db $04,$27,$04,$00,$08,$41,$16,$C1
	db $04,$27,$04,$2F,$08,$25,$01,$2F
	db $04,$27,$04,$00,$04,$01,$04,$20
	db $01,$01,$04,$00,$08,$41,$14,$81
	db $1A,$00,$40,$82,$10,$02,$20,$00
	db $30,$01,$01,$00,$50,$22,$01,$FF
.Roy:
	db $01,$02,$3E,$00,$60,$01,$09,$80
	db $08,$00,$20,$04,$60,$00,$20,$10
	db $20,$01,$44,$00,$2C,$31,$01,$3A
	db $10,$31,$01,$3A,$10,$31,$01,$3A
	db $20,$28,$A0,$28,$40,$29,$04,$28
	db $04,$29,$04,$28,$04,$29,$04,$28
	db $40,$22,$01,$FF
.Ludwig:
	db $01,$02,$3E,$00,$60,$01,$09,$80
	db $08,$00,$20,$04,$60,$10,$20,$31
	db $01,$18,$60,$31,$01,$3B,$80,$31
	db $01,$3C,$40,$FF
.Lemmy:
	db $01,$02,$3E,$00,$60,$02,$30,$01
	db $6E,$00,$20,$23,$01,$01,$16,$02
	db $20,$20,$01,$01,$20,$02,$20,$01
	db $02,$00,$80,$FF
.Wendy:
	db $01,$02,$3E,$00,$60,$02,$27,$01
	db $69,$00,$28,$24,$01,$02,$01,$00
	db $FF
.Unused:
	db $00,$40,$20,$01,$00,$30,$02,$40
	db $00,$30,$FF
.Larry:
	db $01,$02,$3E,$00,$4C,$01,$43,$00
	db $40,$26,$01,$00,$1E,$20,$01,$00
	db $20,$08,$10,$20,$01,$2D,$18,$00
	db $A0,$20,$01,$2E,$01,$FF
else
.Iggy:
	db $26,$11,$02,$48,$00,$60,$01,$09	;!
	db $80,$08,$00,$20,$04,$60,$00,$01	;!
	db $FF				;!
.Morton:
	db $01,$02,$48,$00,$60,$41,$2C,$C1
	db $04,$27,$04,$2F,$08,$25,$01,$2F
	db $04,$27,$04,$00,$08,$41,$1B,$C1
	db $04,$27,$04,$2F,$08,$25,$01,$2F
	db $04,$27,$04,$00,$04,$01,$08,$20
	db $01,$01,$10,$00,$08,$41,$12,$81
	db $0A,$00,$40,$82,$10,$02,$20,$00
	db $30,$01,$01,$00,$50,$22,$01,$FF
.Roy:
	db $01,$02,$48,$00,$60,$01,$09,$80
	db $08,$00,$20,$04,$60,$00,$20,$10
	db $20,$01,$58,$00,$2C,$31,$01,$3A
	db $10,$31,$01,$3A,$10,$31,$01,$3A
	db $20,$28,$A0,$28,$40,$29,$04,$28
	db $04,$29,$04,$28,$04,$29,$04,$28
	db $40,$22,$01,$FF
.Ludwig:
	db $01,$02,$48,$00,$60,$01,$09,$80
	db $08,$00,$20,$04,$60,$10,$20,$31
	db $01,$18,$60,$31,$01,$3B,$80,$31
	db $01,$3C,$40,$FF
.Lemmy:
	db $01,$02,$48,$00,$60,$02,$30,$01
	db $84,$00,$20,$23,$01,$01,$16,$02
	db $20,$20,$01,$01,$20,$02,$20,$01
	db $02,$00,$80,$FF
.Wendy:
	db $01,$02,$48,$00,$60,$02,$28,$01
	db $83,$00,$28,$24,$01,$02,$01,$00
	db $FF
.Unused:
	db $00,$40,$20,$01,$00,$40,$02,$60	;!
	db $00,$30,$FF			;!
.Larry:
	db $01,$02,$48,$00,$60,$01,$4E,$00
	db $40,$26,$01,$00,$1E,$20,$01,$00
	db $20,$08,$10,$20,$01,$2D,$18,$00
	db $A0,$20,$01,$2E,$01,$FF
endif

UNK_00C6DF:
	db $01									; Todo: I wonder if that $01 is ever actually used?

; Base indices to the data at $00C5E8 for each of the castle destruction
; scenes.
DATA_00C6E0:
	db CastleDestructionMovementData_Iggy-CastleDestructionMovementData
	db CastleDestructionMovementData_Morton-CastleDestructionMovementData-$01
	db CastleDestructionMovementData_Lemmy-CastleDestructionMovementData-$01
	db CastleDestructionMovementData_Ludwig-CastleDestructionMovementData-$01
	db CastleDestructionMovementData_Roy-CastleDestructionMovementData-$01
	db CastleDestructionMovementData_Wendy-CastleDestructionMovementData-$01
	db CastleDestructionMovementData_Larry-CastleDestructionMovementData-$01

Main:
	JSR.w SMW_DamagePlayer_DisableButtons	; No buttons allowed
	STZ.w !RAM_SMW_Player_OverrideWalkingFrames
	JSR.w SMW_UpdatePlayerSpritePosition_Main
	LDA.b !RAM_SMW_Player_YSpeed	; \ Branch if Mario has upward speed
	BMI.b CODE_00C73F
	LDA.b !RAM_SMW_Player_YPosLo	;\
	CMP.b #$58			;| if mario is at the last 2/3 of the screen(two placeslegit,for 2 high bytes)
	BCS.b CODE_00C739		;/
	LDY.b !RAM_SMW_Player_XPosLo
	CPY.b #$40
	BCC.b CODE_00C73F
	CPY.b #$60
	BCC.b CODE_00C71C
	LDY.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	BEQ.b CODE_00C73F
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.b #$1C
	BMI.b CODE_00C73F
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDX.b #$D0
	LDY.b !RAM_SMW_Player_FacingDirection
	BEQ.b CODE_00C730
	LDY.b #$00
	BRA.b CODE_00C72E

CODE_00C71C:
	CMP.b #$4C
	BCC.b CODE_00C73F
	LDA.b #!Define_SMW_Sound1DFC_TNTFuse	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	INC.w !RAM_SMW_Flag_TNTPlungerWasPressed
	LDA.b #$4C
	LDY.b #$F4
	LDX.b #$C0
CODE_00C72E:
	STY.b !RAM_SMW_Player_XSpeed
CODE_00C730:
	STX.b !RAM_SMW_Player_YSpeed
	LDX.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STX.w !RAM_SMW_IO_SoundCh1
	BRA.b CODE_00C73D

CODE_00C739:
	STZ.b !RAM_SMW_Player_InAirFlag
	LDA.b #$58
CODE_00C73D:
	STA.b !RAM_SMW_Player_YPosLo
CODE_00C73F:
	LDX.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	LDA.b !RAM_SMW_Misc_ScratchRAM8F
	CLC
	ADC.w DATA_00C6E0-$01,x
	TAX
	LDA.b !RAM_SMW_Player_CutsceneInputTimer1
	BNE.b CODE_00C764
	INC.b !RAM_SMW_Misc_ScratchRAM8F
	INC.b !RAM_SMW_Misc_ScratchRAM8F
	INX
	INX
	LDA.w CastleDestructionMovementData+$01,x
	STA.b !RAM_SMW_Player_CutsceneInputTimer1
	LDA.w CastleDestructionMovementData,x
	CMP.b #$2D
	BNE.b CODE_00C764
	LDA.b #!Define_SMW_Sound1DF9_PBalloon	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
CODE_00C764:
	LDA.w CastleDestructionMovementData,x
	CMP.b #$FF
	BNE.b CODE_00C76E
	JMP.w Return00C7F8

CODE_00C76E:
	PHA
	AND.b #$10
	BEQ.b CODE_00C777
	JSL.l SMW_DrawQuestionMark_Main
CODE_00C777:
	PLA
	TAY
	AND.b #$20
	BNE.b CODE_00C789
	STY.b !RAM_SMW_IO_ControllerHold1
	TYA
	AND.b #(!Joypad_DPadR>>8)|(!Joypad_DPadL>>8)|(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)|(!Joypad_Start>>8)|(!Joypad_Select>>8)|(!Joypad_B>>8)
	STA.b !RAM_SMW_IO_ControllerPress1
	JSR.w SMW_PlayerState00_Normal_CODE_00CD39
	BRA.b CODE_00C7F6

CODE_00C789:
	TYA
	AND.b #$0F
	CMP.b #$07
	BCS.b CODE_00C7E9
	DEC
	BPL.b CODE_00C7A2
	LDA.w !RAM_SMW_Timer_DisplayPlayerPickUpPose
	BEQ.b CODE_00C79D
	LDA.b #!Define_SMW_Sound1DF9_FlyWithCape	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
CODE_00C79D:
	INC.w !RAM_SMW_Flag_CastleMovementInCutscene
	BRA.b CODE_00C7F6

CODE_00C7A2:
	BNE.b CODE_00C7A9
	INC.w !RAM_SMW_Sprites_QuestionMarkAnimationIndex
	BRA.b CODE_00C7F6

CODE_00C7A9:
	DEC
	BNE.b CODE_00C7B6
	LDA.b #!Define_SMW_Sound1DF9_Swim	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	INC.w !RAM_SMW_Misc_ShowPlayerCough
	BRA.b CODE_00C7F6

CODE_00C7B6:
	DEC
	BNE.b CODE_00C7C0
	LDY.b #$88
	STY.w !RAM_SMW_Sprites_SwingHammerTimer
	BRA.b CODE_00C7F6

CODE_00C7C0:
	DEC
	BNE.b CODE_00C7CE
	LDA.b #$38
	STA.w !RAM_SMW_Sprites_MopYPosLo
	LDA.b #$07
	TRB.b !RAM_SMW_Player_XPosLo
	BRA.b CODE_00C7F6

CODE_00C7CE:
	DEC
	BNE.b CODE_00C7DF
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$D2
else
	LDA.b #$D8
endif
	STA.b !RAM_SMW_Player_XSpeed
	INC.w !RAM_SMW_Flag_DropkickCounter
	BRA.b CODE_00C79D

CODE_00C7DF:
	LDA.b #$20
	STA.w !RAM_SMW_Timer_DisplayPlayerPickUpPose
	INC.w !RAM_SMW_Player_CarryingSomethingFlag2
	BRA.b CODE_00C7F6

CODE_00C7E9:
	TAY
	LDA.w DATA_00C5E1-$07,y
	STA.w !RAM_SMW_Player_CurrentPose
	STZ.w !RAM_SMW_Player_CarryingSomethingFlag2
	JSR.w SMW_HandlePlayerPhysics_InAir
CODE_00C7F6:
	DEC.b !RAM_SMW_Player_CutsceneInputTimer1
Return00C7F8:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UploadBigLayer3LettersToVRAM(Address)
namespace SMW_UploadBigLayer3LettersToVRAM
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #$2F			;\ Decompress GFX2F to RAM.
	JSL.l SMW_GraphicsDecompressionRoutines_Main	;/
	LDA.b #$80
	STA.w !REGISTER_VRAMAddressIncrementValue
	REP.b #$30			; AXY->16
	LDA.w #!VRAM_SMW_Layer3GFXVRAMLocation+$0600
	STA.w !REGISTER_VRAMAddressLo	; Address for VRAM Read/Write (Low Byte)
	LDX.w #$0200
CODE_009574:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]
	STA.w !REGISTER_WriteToVRAMPortLo	; Data for VRAM Write (Low Byte)
	INC.b !RAM_SMW_Misc_ScratchRAM00
	INC.b !RAM_SMW_Misc_ScratchRAM00
	DEX
	BNE.b CODE_009574
	SEP.b #$30			; AXY->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UpdateCurrentPlayerPositionRAM(Address)
namespace SMW_UpdateCurrentPlayerPositionRAM
%InsertMacroAtXPosition(<Address>)

Main:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo	;\
	STA.b !RAM_SMW_Player_CurrentXPosLo	;| Mario's X/Y pos = Mario's X/Y pos current frame
	LDA.b !RAM_SMW_Player_YPosLo	;| (Update X/Ypos)
	STA.b !RAM_SMW_Player_CurrentYPosLo	;/
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetKeepGameModeActiveTimer(Address)
namespace SMW_SetKeepGameModeActiveTimer
%InsertMacroAtXPosition(<Address>)

OneFrame:
	LDA.b #$01
VariableFrames:
	STA.w !RAM_SMW_Timer_KeepGameModeActive
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_InitializeLevelLayer3(Address)
namespace SMW_InitializeLevelLayer3
%InsertMacroAtXPosition(<Address>)

; Layer 3 settings. The table is indexed by 3t + i, where t is the tileset
; number and i is the Layer 3 image setting (00 = variable tide, 01 = low
; tide, 02 = tileset-specific image). It is used by the routine at $009FB8.
; The actual format seems to be: 01 = variable-height tide 02 = fixed-height
; tide 80 = Layer 3 smashers/cage 81 = slow-auto-scrolling background
; (except in tilesets 1 and 3, where it will be a background that scrolls at
; half the rate Layer 1 does) C0 = same as 80, except without the smasher
; palette
DATA_009F88:
	db $01,$02,$C0			; Tileset 0 (Normal 1)
	db $01,$80,$81			; Tileset 1 (Castle 1)
	db $01,$02,$C0			; Tileset 2 (Rope 1)
	db $01,$02,$81			; Tileset 3 (Underground 1)
	db $01,$02,$80			; Tileset 4 (Switch Palace 1)
	db $01,$02,$81			; Tileset 5 (Ghost House 1)
	db $01,$02,$81			; Tileset 6 (Rope 2)
	db $01,$02,$C0			; Tileset 7 (Normal 2)
	db $01,$02,$C0			; Tileset 8 (Rope 3)
	db $01,$02,$81			; Tileset 9 (Underground 2)
	db $01,$02,$80			; Tileset A (Switch Palace 2)
	db $01,$02,$80			; Tileset B (Castle 2)
	db $01,$02,$80			; Tileset C (Cloud/Forest)
	db $01,$02,$81			; Tileset D (Ghost House 2)
	db $01,$02,$81			; Tileset E (Underground 3)
	db $01,$02,$80			; Tileset F (Unused)

; The main Layer 3 handling routine in levels. - $009FDA: Starting Y
; position of the rising/lowering tide. - $009FDF: Y position of the
; fixed-height tide. - $009FF3: One of two tilesets for which the
; tileset-specific Layer 3 background will not auto-scroll. The other is at
; $009FF7. - $009FF7: One of two tilesets for which the tileset-specific
; Layer 3 background will not auto-scroll. The other is at $009FF3. -
; $00A00A: Pointer to the layer 3 crusher palette.
Main:
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting	;\
	ASL				;| Get (Tileset*3), store in $00
	CLC				;|
	ADC.w !RAM_SMW_Misc_LevelTilesetSetting	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.w !RAM_SMW_Misc_LevelLayer3Settings	;\ Branch if the level does not have Layer 3.
	BEQ.b CODE_00A012		;/
	DEC
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	TAX
	LDA.w DATA_009F88,x
	BMI.b CODE_009FEA
	STA.w !RAM_SMW_Flag_Layer3TideLevel
	LSR
	PHP
	JSR.w GenerateInteractiveTideWater
	LDA.b #$70			; Starting Y position of the high/low Layer 3 tide.
	PLP
	BEQ.b CODE_009FE0
	LDA.b #$40			; Y position of the normal Layer 3 tide.
CODE_009FE0:
	STA.b !RAM_SMW_Mirror_Layer3YPosLo
	STZ.b !RAM_SMW_Mirror_Layer3YPosHi
	JSL.l SMW_ScrollSecondInteractiveLayer_Main
	BRA.b CODE_00A01B

CODE_009FEA:
	ASL
	BMI.b CODE_00A012
	BEQ.b CODE_00A007
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting	;\ Tilesets for which the tileset-specific Layer 3 background will not autoscroll
	CMP.b #$01			;|
	BEQ.b CODE_009FFA		;|
	CMP.b #$03			;/
	BNE.b CODE_00A01F
CODE_009FFA:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LSR
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	SEP.b #$20			; A->8
	LDA.b #$C0
	BRA.b CODE_00A017

CODE_00A007:
	LDX.b #$07
CODE_00A009:
	LDA.w SMW_GlobalPalettes_Layer3Smasher,x
	STA.w SMW_PaletteMirror[$0C].LowByte,x
	DEX
	BPL.b CODE_00A009
CODE_00A012:
	INC.w !RAM_SMW_Flag_DisableLayer3Scroll
	LDA.b #$D0
CODE_00A017:
	STA.b !RAM_SMW_Mirror_Layer3YPosLo
	STZ.b !RAM_SMW_Mirror_Layer3YPosHi
CODE_00A01B:
	LDA.b #$04
	TRB.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
CODE_00A01F:
#LM230Hijack_CustomLayer3:
if !Define_SMW_Layer3Settings == !TRUE
	JML.l SMW_Layer3Settings_Init	;\ The level's own Layer 3 settings, then
	NOP				;/ this image (Config/Layer3Settings.asm)
else
	LDA.w !RAM_SMW_Misc_LevelLayer3Settings
	BEQ.b Return00A044
endif
UploadImage:
	DEC
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	ASL
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	TAX
	LDA.l Layer3ImagePtrs,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l Layer3ImagePtrs+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.l Layer3ImagePtrs+$02,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_LoadStripeImage_UploadToVRAM
Return00A044:
	RTS

; The routine that sets the interaction of the Layer 3 tide tiles. Both
; $00A04E and $00A04F are the low byte of the Map16 tile that the tides act
; like; nothing is stored to the high byte, so this is always on page 0.
GenerateInteractiveTideWater:
	REP.b #$30			; AXY->16
	LDX.w #$0100
CODE_00A04A:
	LDY.w #$0058
	LDA.w #$0000
CODE_00A050:
	STA.l !RAM_SMW_Blocks_Map16TableLo+($01B0*$10),x
	INX
	INX
	DEY
	BNE.b CODE_00A050
	TXA
	CLC
	ADC.w #$0100
	TAX
	CPX.w #$1B00
	BCC.b CODE_00A04A
	SEP.b #$30			; AXY->8
	LDA.b #$80
	TSB.b !RAM_SMW_Misc_LevelLayoutFlags
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode27_LoadTheEnd(Address)
namespace SMW_GameMode27_LoadTheEnd
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_ClearLayer3Tilemap_Main	; Clean out Layer 3.
	JSR.w SMW_ClearOverworldAndCutsceneRAM_Main	; Clean out a large chunk of RAM.
	JSR.w SMW_SetStandardPPUSettings_Main	; Set up various registers (screen mode, CGADDSUB, windows...).
	JSR.w SMW_UploadBigLayer3LettersToVRAM_Main
	LDA.b #$19			;\ Set sprite GFX list.
	STA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting	;/
	LDA.b #$03
	STA.w !RAM_SMW_Misc_BackgroundColorSetting
	LDA.b #$03
	STA.w !RAM_SMW_Misc_BGPaletteSetting
	JSR.w SMW_UploadGraphicsFiles_Main	; Upload GFX files.
	JSR.w SMW_BufferPalettesRoutines_Levels
	LDX.b #$0B
CODE_009660:
	LDA.w SMW_GlobalPalettes_EndingLuigi,x
	STA.w SMW_PaletteMirror[$D2].LowByte,x
	LDA.w SMW_GlobalPalettes_EndingMario,x
	STA.w SMW_PaletteMirror[$E2].LowByte,x
	LDA.w SMW_GlobalPalettes_EndingToadstool,x
	STA.w SMW_PaletteMirror[$F2].LowByte,x
	DEX
	BPL.b CODE_009660
	JSR.w SMW_UpdateEntirePalette_Main	; Upload palettes to CGRAM.
	LDA.b #!Define_SMW_StripeImage_TheEndText
	STA.b !RAM_SMW_Graphics_StripeImageToUpload
	JSR.w SMW_LoadStripeImage_Sub	; Upload tilemap data from $12.
	JSL.l SMW_DrawingTheEndMarioLuigiAndPeach_Main
	JSR.w SMW_CompressOAMTileSizeBuffer_Main	; Prep OAM for upload.
	LDX.b #$14
	LDY.b #$00
	JMP.w SMW_GameMode23_LoadEnemyRollcallScreen_CODE_009622
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode1D_LoadYoshisHouse(Address)
namespace SMW_GameMode1D_LoadYoshisHouse
%InsertMacroAtXPosition(<Address>)

Main:
	INC.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	; Which level to use for the Yoshi's House part in the credits. 'A9 28 A0
	; 01'. Do not change A9 and A0. 28 is the low byte of the level (Note:
	; Level number + 24), 01 is the high byte.
	LDA.b #$28			;\
	LDY.b #!Define_SMW_Overworld_YoshisIsland	;| Set to load level 104.
	JSR.w SMW_GameMode11_LoadSublevel_CODE_0096CF	;/
	DEC.w !RAM_SMW_Misc_GameMode
	LDA.b #$16			;\ Set sprite GFX list.
	STA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting	;/
	JSR.w SMW_GameMode12_PrepareLevel_Main	; Load level data.
	DEC.w !RAM_SMW_Misc_GameMode
	JSR.w SMW_TurnOffIO_Main	; Turn off the screen.
	JSR.w SMW_ClearLayer3Tilemap_Main	; Clean out Layer 3.
	JSR.w SMW_UploadGraphicsFiles_Layer3	; Load Layer 3 GFX.
	JSL.l InitializeYoshisHouseSceneRAM	; Initialize misc data?
	JSR.w SMW_GameMode23_LoadEnemyRollcallScreen_CODE_00961E	; Set up screen data (CGADSUB/etc.)
GameMode1FEntry:
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt	; Clear OAM.
	JSL.l Bank0C			; Run main routines.
	INC.b !RAM_SMW_Counter_LocalFrames
#LM160Hijack_LevelExAnimations1:
	JSL.l SMW_LevelTileAnimations_Main	; Handle tile animation.
	JMP.w SMW_CompressOAMTileSizeBuffer_Main	; Prep OAM for upload.
namespace off
	%SetDuplicateOrNullPointer(SMW_GameMode1D_LoadYoshisHouse_GameMode1FEntry, SMW_GameMode1F_ShowYoshisHouse_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode23_LoadEnemyRollcallScreen(Address)
namespace SMW_GameMode23_LoadEnemyRollcallScreen
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_ClearLayer3Tilemap_Main	; Clean out Layer 3.
	JSR.w SMW_ClearOverworldAndCutsceneRAM_Main	; Clean out a large chunk of RAM.
	JSR.w SMW_SetStandardPPUSettings_Main	; Set up various registers (screen mode, CGADDSUB, windows...).
	JSL.l SMW_GetLayer1And2PointersForEnemyRollcall_Main
	JSL.l SMW_LoadSublevel_Main	; Load level data.
	LDA.w !RAM_SMW_Counter_EnemyRollcallScreen
	CMP.b #$0A
	BNE.b NotReznorScreen
	LDA.b #$13
	STA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting
	BRA.b IsReznorScreen

NotReznorScreen:
	CMP.b #$0C
	BNE.b NotBowserScreen
	LDA.b #$17
	STA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting
NotBowserScreen:
IsReznorScreen:
#LM000Hijack_Unknown0095E9:
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	; The same three calls in the order a level makes them, ten bytes
	; either way: the tilemaps first, because a 4bpp file's decompression
	; runs over the Layer 2 background buffer the tilemap upload reads,
	; and this was the one path that uploaded graphics before reading it.
	; See Config/ManagedGraphicsMemory.asm.
	JSL.l SMW_InitializeLevelLayer1And2Tilemaps_Main	; Upload Map16 data to VRAM.
	JSR.w SMW_UploadGraphicsFiles_Main	; Upload GFX files.
	JSR.w SMW_BufferPalettesRoutines_Levels	; Load palette data from ROM to RAM.
else
	JSR.w SMW_UploadGraphicsFiles_Main	; Upload GFX files.
	JSR.w SMW_BufferPalettesRoutines_Levels	; Load palette data from ROM to RAM.
	JSL.l SMW_InitializeLevelLayer1And2Tilemaps_Main	; Upload Map16 data to VRAM.
endif
	JSR.w SMW_InitializeLevelTileAnimations_Main	; Handle animated tiles.
	JSL.l SMW_InitializeEnemyRollcallLayerPositions_Main	; Load the enemy credits scene.
	LDA.w !RAM_SMW_Counter_EnemyRollcallScreen
	CMP.b #$0C
	BNE.b NoBowserScreenPalette
	LDX.b #$0B
BowserScreenPaletteBufferLoop:
	LDA.w SMW_GlobalPalettes_BowserEnd,x
	STA.w SMW_PaletteMirror[$82].LowByte,x
	LDA.w SMW_GlobalPalettes_BowserEnd+$0C,x
	STA.w SMW_PaletteMirror[$92].LowByte,x
	DEX
	BPL.b BowserScreenPaletteBufferLoop
NoBowserScreenPalette:
	JSR.w SMW_UpdateEntirePalette_Main	; Upload palettes to CGRAM.
	JSR.w SMW_SetEnemyRollcallParallaxHDMA_Init	; Initialize HDMA table.
	JSR.w SMW_LoadStripeImage_Sub	; Upload tilemap data from $12.
	JSR.w SMW_GameMode25_ShowEnemyRollcallScreen_Main
CODE_00961E:
	LDX.b #$15
	LDY.b #$02			; Main/sub screen settings.
CODE_009622:
	JSR.w SMW_SetKeepGameModeActiveTimer_OneFrame
	LDA.b #!BGModeAndTileSizeSetting_Mode01Enable|!BGModeAndTileSizeSetting_Mode01Layer3Priority
	STA.b !RAM_SMW_Mirror_BGModeAndTileSizeSetting
	JMP.w SMW_GameMode00_LoadNintendoPresents_CODE_0093EA
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode25_ShowEnemyRollcallScreen(Address)
namespace SMW_GameMode25_ShowEnemyRollcallScreen
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Player_NumberOfTilesToUpdate
	JSR.w SMW_SetEnemyRollcallParallaxHDMA_Main	; Initialize HDMA table.
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt	; Clear OAM.
	JSL.l Bank0C			; Run main routines for the game mode.
	JMP.w SMW_CompressOAMTileSizeBuffer_Main	; Prep OAM for upload.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_LevelDataLayoutTables(Address)
namespace SMW_LevelDataLayoutTables
%InsertMacroAtXPosition(<Address>)

Main:
EightBitLo:
.Horizontal:
..L1:
	; The low byte of a series of Map16 data pointers in horizontal levels. The
	; high bytes are at $00BA9C, and the bank byte is either $7E or $7F. These
	; are indexed by screen number; each byte in this table and the other
	; corresponds to the start of a particular screen's Map16 data (or chunk of
	; 0x1B0 bytes). These are used in various routines that read or write Map16
	; data to find where a particular tile is.
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$00)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$01)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$02)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$03)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$04)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$05)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$06)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$07)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$08)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$09)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$0A)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$0B)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$0C)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$0D)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$0E)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$0F)

..L2:
;$00BA70
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$10)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$11)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$12)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$13)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$14)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$15)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$16)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$17)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$18)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$19)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$1A)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$1B)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$1C)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$1D)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$1E)
	db !RAM_SMW_Blocks_Map16TableLo+($01B0*$1F)

.Vertical:
..L1:
;$00BA80
	; The low byte of a series of Map16 data pointers in vertical levels. The
	; high bytes are at $00BABC, and the bank byte is either $7E or $7F. These
	; are indexed by screen number; each byte in this table and the other
	; corresponds to the start of a particular screen's Map16 data (or chunk of
	; 0x200 bytes, which means that all of these will be 00 in a clean ROM
	; anyway). These are used in various routines that read or write Map16 data
	; to find where a particular tile is.
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$00)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$01)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$02)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$03)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$04)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$05)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$06)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$07)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$08)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$09)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$0A)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$0B)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$0C)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$0D)

..L2:
;$00BA8E
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$0E)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$0F)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$10)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$11)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$12)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$13)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$14)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$15)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$16)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$17)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$18)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$19)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$1A)
	db !RAM_SMW_Blocks_Map16TableLo+($0200*$1B)

EightBitHi:
.Horizontal:
..L1:
;$00BA9C
	; The high byte of a series of Map16 data pointers in horizontal levels.
	; The low bytes are at $00BA60, and the bank byte is either $7E or $7F.
	; These are indexed by screen number; each byte in this table and the other
	; corresponds to the start of a particular screen's Map16 data (or chunk of
	; 0x1B0 bytes). These are used in various routines that read or write Map16
	; data to find where a particular tile is.
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$00))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$01))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$02))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$03))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$04))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$05))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$06))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$07))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$08))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$09))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$0A))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$0B))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$0C))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$0D))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$0E))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$0F))>>8

..L2:
;$00BAAC
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$10))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$11))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$12))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$13))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$14))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$15))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$16))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$17))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$18))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$19))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$1A))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$1B))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$1C))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$1D))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$1E))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($01B0*$1F))>>8

.Vertical:
..L1:
;$00BABC
	; The high byte of a series of Map16 data pointers in vertical levels. The
	; high bytes are at $00BA80, and the bank byte is either $7E or $7F. These
	; are indexed by screen number; each byte in this table and the other
	; corresponds to the start of a particular screen's Map16 data (or chunk of
	; 0x200 bytes, which means that these are all simply multiples of 2 plus
	; #$C8). These are used in various routines that read or write Map16 data
	; to find where a particular tile is.
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$00))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$01))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$02))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$03))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$04))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$05))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$06))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$07))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$08))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$09))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$0A))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$0B))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$0C))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$0D))>>8

..L2:
;$00BACA
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$0E))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$0F))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$10))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$11))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$12))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$13))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$14))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$15))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$16))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$17))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$18))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$19))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$1A))>>8
	db (!RAM_SMW_Blocks_Map16TableLo+($0200*$1B))>>8

TwentyFourBitLo:
.StandardHorizontal:
..L1:
;$00BAD8
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$00)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$01)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$02)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$03)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$04)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$05)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$06)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$07)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$08)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$09)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0A)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0B)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0C)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0D)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0E)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0F)

..L2:
;$00BB08
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$10)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$11)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$12)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$13)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$14)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$15)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$16)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$17)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$18)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$19)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1A)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1B)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1C)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1D)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1E)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1F)

.VertL1HorizL2:
..L1:
;$00BB38
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$00)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$01)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$02)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$03)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$04)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$05)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$06)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$07)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$08)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$09)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0A)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0B)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0C)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0D)

..L2:
;$00BB62
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$10)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$11)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$12)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$13)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$14)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$15)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$16)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$17)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$18)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$19)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1A)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1B)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1C)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1D)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1E)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$1F)

.HorizL1VertL2:
..L1:
;$00BB92
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$00)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$01)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$02)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$03)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$04)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$05)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$06)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$07)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$08)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$09)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0A)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0B)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0C)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0D)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0E)
	dl !RAM_SMW_Blocks_Map16TableLo+($01B0*$0F)

..L2:
;$00BBC2
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0E)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0F)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$10)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$11)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$12)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$13)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$14)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$15)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$16)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$17)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$18)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$19)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$1A)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$1B)

.StandardVertical:
..L1:
;$00BBEC
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$00)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$01)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$02)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$03)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$04)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$05)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$06)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$07)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$08)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$09)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0A)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0B)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0C)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0D)

..L2:
;$00BC16
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0E)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$0F)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$10)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$11)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$12)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$13)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$14)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$15)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$16)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$17)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$18)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$19)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$1A)
	dl !RAM_SMW_Blocks_Map16TableLo+($0200*$1B)

TwentyFourBitHi:
.StandardHorizontal:
..L1:
;$00BC40
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$00)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$01)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$02)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$03)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$04)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$05)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$06)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$07)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$08)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$09)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0A)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0B)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0C)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0D)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0E)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0F)

..L2:
;$00BC70
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$10)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$11)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$12)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$13)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$14)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$15)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$16)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$17)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$18)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$19)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1A)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1B)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1C)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1D)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1E)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1F)

.VertL1HorizL2:
..L1:
;$00BCA0
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$00)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$01)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$02)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$03)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$04)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$05)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$06)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$07)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$08)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$09)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0A)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0B)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0C)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0D)

..L2:
;$00BCC.bA
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$10)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$11)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$12)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$13)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$14)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$15)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$16)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$17)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$18)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$19)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1A)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1B)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1C)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1D)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1E)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$1F)

.HorizL1VertL2:
..L1:
;$00BCFA
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$00)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$01)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$02)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$03)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$04)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$05)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$06)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$07)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$08)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$09)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0A)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0B)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0C)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0D)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0E)
	dl !RAM_SMW_Blocks_Map16TableHi+($01B0*$0F)

..L2:
;$00BD2A
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0E)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0F)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$10)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$11)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$12)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$13)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$14)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$15)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$16)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$17)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$18)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$19)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$1A)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$1B)

.StandardVertical:
..L1:
;$00BD54
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$00)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$01)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$02)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$03)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$04)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$05)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$06)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$07)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$08)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$09)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0A)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0B)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0C)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0D)

..L2:
;$00BD7E
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0E)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$0F)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$10)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$11)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$12)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$13)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$14)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$15)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$16)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$17)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$18)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$19)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$1A)
	dl !RAM_SMW_Blocks_Map16TableHi+($0200*$1B)

Layer1LoPtrs:
;$00BDA8
	dw TwentyFourBitLo_StandardHorizontal_L1		; 00 Horizontal level
	dw TwentyFourBitLo_StandardHorizontal_L1		; 01 Horizontal layer 2 level (no layer 2 interaction)
	dw TwentyFourBitLo_StandardHorizontal_L1		; 02 Horizontal layer 2 level (layer 2 interaction)
	dw TwentyFourBitLo_VertL1HorizL2_L1			; 03 Do not use this level mode!
	dw TwentyFourBitLo_VertL1HorizL2_L1			; 04 Do not use this level mode!
	dw TwentyFourBitLo_HorizL1VertL2_L1			; 05 Do not use this level mode!
	dw TwentyFourBitLo_HorizL1VertL2_L1			; 06 Do not use this level mode!
	dw TwentyFourBitLo_StandardVertical_L1			; 07 Vertical layer 2 level (no layer 2 interaction)
	dw TwentyFourBitLo_StandardVertical_L1			; 08 Vertical layer 2 level (layer 2 interaction)
	dw NullLevelLayoutData					; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	dw TwentyFourBitLo_StandardVertical_L1			; 0A Vertical level
	dw NullLevelLayoutData					; 0B Horizontal boss level (Larry, Iggy)
	dw TwentyFourBitLo_StandardHorizontal_L1		; 0C Horizontal dark BG level
	dw TwentyFourBitLo_StandardVertical_L1			; 0D Vertical dark BG level
	dw TwentyFourBitLo_StandardHorizontal_L1		; 0E Horizontal level
	dw TwentyFourBitLo_StandardHorizontal_L1		; 0F Horizontal layer 2 level (no layer 2 interaction)
	dw NullLevelLayoutData					; 10 Horizontal boss level (Bowser)
	dw TwentyFourBitLo_StandardHorizontal_L1		; 11 Horizontal dark BG level
	dw NullLevelLayoutData					; 12 Cannot use this level mode!
	dw NullLevelLayoutData					; 13 Cannot use this level mode!
	dw NullLevelLayoutData					; 14 Cannot use this level mode!
	dw NullLevelLayoutData					; 15 Cannot use this level mode!
	dw NullLevelLayoutData					; 16 Cannot use this level mode!
	dw NullLevelLayoutData					; 17 Cannot use this level mode!
	dw NullLevelLayoutData					; 18 Cannot use this level mode!
	dw NullLevelLayoutData					; 19 Cannot use this level mode!
	dw NullLevelLayoutData					; 1A Cannot use this level mode!
	dw NullLevelLayoutData					; 1B Cannot use this level mode!
	dw NullLevelLayoutData					; 1C Cannot use this level mode!
	dw NullLevelLayoutData					; 1D Cannot use this level mode!
	dw TwentyFourBitLo_StandardHorizontal_L1		; 1E Horizontal translucent level
	dw TwentyFourBitLo_StandardHorizontal_L1		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

Layer2LoPtrs:
;$00BDE8
	dw TwentyFourBitLo_StandardHorizontal_L2		; 00 Horizontal level
	dw TwentyFourBitLo_StandardHorizontal_L2		; 01 Horizontal layer 2 level (no layer 2 interaction)
	dw TwentyFourBitLo_StandardHorizontal_L2		; 02 Horizontal layer 2 level (layer 2 interaction)
	dw TwentyFourBitLo_VertL1HorizL2_L2			; 03 Do not use this level mode!
	dw TwentyFourBitLo_VertL1HorizL2_L2			; 04 Do not use this level mode!
	dw TwentyFourBitLo_HorizL1VertL2_L2			; 05 Do not use this level mode!
	dw TwentyFourBitLo_HorizL1VertL2_L2			; 06 Do not use this level mode!
	dw TwentyFourBitLo_StandardVertical_L2			; 07 Vertical layer 2 level (no layer 2 interaction)
	dw TwentyFourBitLo_StandardVertical_L2			; 08 Vertical layer 2 level (layer 2 interaction)
	dw NullLevelLayoutData					; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	dw TwentyFourBitLo_StandardVertical_L2			; 0A Vertical level
	dw NullLevelLayoutData					; 0B Horizontal boss level (Larry, Iggy)
	dw TwentyFourBitLo_StandardHorizontal_L2		; 0C Horizontal dark BG level
	dw TwentyFourBitLo_StandardVertical_L2			; 0D Vertical dark BG level
	dw TwentyFourBitLo_StandardHorizontal_L2		; 0E Horizontal level
	dw TwentyFourBitLo_StandardHorizontal_L2		; 0F Horizontal layer 2 level (no layer 2 interaction)
	dw NullLevelLayoutData					; 10 Horizontal boss level (Bowser)
	dw TwentyFourBitLo_StandardHorizontal_L2		; 11 Horizontal dark BG level
	dw NullLevelLayoutData					; 12 Cannot use this level mode!
	dw NullLevelLayoutData					; 13 Cannot use this level mode!
	dw NullLevelLayoutData					; 14 Cannot use this level mode!
	dw NullLevelLayoutData					; 15 Cannot use this level mode!
	dw NullLevelLayoutData					; 16 Cannot use this level mode!
	dw NullLevelLayoutData					; 17 Cannot use this level mode!
	dw NullLevelLayoutData					; 18 Cannot use this level mode!
	dw NullLevelLayoutData					; 19 Cannot use this level mode!
	dw NullLevelLayoutData					; 1A Cannot use this level mode!
	dw NullLevelLayoutData					; 1B Cannot use this level mode!
	dw NullLevelLayoutData					; 1C Cannot use this level mode!
	dw NullLevelLayoutData					; 1D Cannot use this level mode!
	dw TwentyFourBitLo_StandardHorizontal_L2		; 1E Horizontal translucent level
	dw TwentyFourBitLo_StandardHorizontal_L2		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

Layer1HiPtrs:
;$00BE28
	dw TwentyFourBitHi_StandardHorizontal_L1		; 00 Horizontal level
	dw TwentyFourBitHi_StandardHorizontal_L1		; 01 Horizontal layer 2 level (no layer 2 interaction)
	dw TwentyFourBitHi_StandardHorizontal_L1		; 02 Horizontal layer 2 level (layer 2 interaction)
	dw TwentyFourBitHi_VertL1HorizL2_L1			; 03 Do not use this level mode!
	dw TwentyFourBitHi_VertL1HorizL2_L1			; 04 Do not use this level mode!
	dw TwentyFourBitHi_HorizL1VertL2_L1			; 05 Do not use this level mode!
	dw TwentyFourBitHi_HorizL1VertL2_L1			; 06 Do not use this level mode!
	dw TwentyFourBitHi_StandardVertical_L1			; 07 Vertical layer 2 level (no layer 2 interaction)
	dw TwentyFourBitHi_StandardVertical_L1			; 08 Vertical layer 2 level (layer 2 interaction)
	dw NullLevelLayoutData					; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	dw TwentyFourBitHi_StandardVertical_L1			; 0A Vertical level
	dw NullLevelLayoutData					; 0B Horizontal boss level (Larry, Iggy)
	dw TwentyFourBitHi_StandardHorizontal_L1		; 0C Horizontal dark BG level
	dw TwentyFourBitHi_StandardVertical_L1			; 0D Vertical dark BG level
	dw TwentyFourBitHi_StandardHorizontal_L1		; 0E Horizontal level
	dw TwentyFourBitHi_StandardHorizontal_L1		; 0F Horizontal layer 2 level (no layer 2 interaction)
	dw NullLevelLayoutData					; 10 Horizontal boss level (Bowser)
	dw TwentyFourBitHi_StandardHorizontal_L1		; 11 Horizontal dark BG level
	dw NullLevelLayoutData					; 12 Cannot use this level mode!
	dw NullLevelLayoutData					; 13 Cannot use this level mode!
	dw NullLevelLayoutData					; 14 Cannot use this level mode!
	dw NullLevelLayoutData					; 15 Cannot use this level mode!
	dw NullLevelLayoutData					; 16 Cannot use this level mode!
	dw NullLevelLayoutData					; 17 Cannot use this level mode!
	dw NullLevelLayoutData					; 18 Cannot use this level mode!
	dw NullLevelLayoutData					; 19 Cannot use this level mode!
	dw NullLevelLayoutData					; 1A Cannot use this level mode!
	dw NullLevelLayoutData					; 1B Cannot use this level mode!
	dw NullLevelLayoutData					; 1C Cannot use this level mode!
	dw NullLevelLayoutData					; 1D Cannot use this level mode!
	dw TwentyFourBitHi_StandardHorizontal_L1		; 1E Horizontal translucent level
	dw TwentyFourBitHi_StandardHorizontal_L1		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

Layer2HiPtrs:
;$00BE68
	dw TwentyFourBitHi_StandardHorizontal_L2		; 00 Horizontal level
	dw TwentyFourBitHi_StandardHorizontal_L2		; 01 Horizontal layer 2 level (no layer 2 interaction)
	dw TwentyFourBitHi_StandardHorizontal_L2		; 02 Horizontal layer 2 level (layer 2 interaction)
	dw TwentyFourBitHi_VertL1HorizL2_L2			; 03 Do not use this level mode!
	dw TwentyFourBitHi_VertL1HorizL2_L2			; 04 Do not use this level mode!
	dw TwentyFourBitHi_HorizL1VertL2_L2			; 05 Do not use this level mode!
	dw TwentyFourBitHi_HorizL1VertL2_L2			; 06 Do not use this level mode!
	dw TwentyFourBitHi_StandardVertical_L2			; 07 Vertical layer 2 level (no layer 2 interaction)
	dw TwentyFourBitHi_StandardVertical_L2			; 08 Vertical layer 2 level (layer 2 interaction)
	dw NullLevelLayoutData					; 09 Horizontal boss level (Reznor, Ludwig, Roy, Morton)
	dw TwentyFourBitHi_StandardVertical_L2			; 0A Vertical level
	dw NullLevelLayoutData					; 0B Horizontal boss level (Larry, Iggy)
	dw TwentyFourBitHi_StandardHorizontal_L2		; 0C Horizontal dark BG level
	dw TwentyFourBitHi_StandardVertical_L2			; 0D Vertical dark BG level
	dw TwentyFourBitHi_StandardHorizontal_L2		; 0E Horizontal level
	dw TwentyFourBitHi_StandardHorizontal_L2		; 0F Horizontal layer 2 level (no layer 2 interaction)
	dw NullLevelLayoutData					; 10 Horizontal boss level (Bowser)
	dw TwentyFourBitHi_StandardHorizontal_L2		; 11 Horizontal dark BG level
	dw NullLevelLayoutData					; 12 Cannot use this level mode!
	dw NullLevelLayoutData					; 13 Cannot use this level mode!
	dw NullLevelLayoutData					; 14 Cannot use this level mode!
	dw NullLevelLayoutData					; 15 Cannot use this level mode!
	dw NullLevelLayoutData					; 16 Cannot use this level mode!
	dw NullLevelLayoutData					; 17 Cannot use this level mode!
	dw NullLevelLayoutData					; 18 Cannot use this level mode!
	dw NullLevelLayoutData					; 19 Cannot use this level mode!
	dw NullLevelLayoutData					; 1A Cannot use this level mode!
	dw NullLevelLayoutData					; 1B Cannot use this level mode!
	dw NullLevelLayoutData					; 1C Cannot use this level mode!
	dw NullLevelLayoutData					; 1D Cannot use this level mode!
	dw TwentyFourBitHi_StandardHorizontal_L2		; 1E Horizontal translucent level
	dw TwentyFourBitHi_StandardHorizontal_L2		; 1F Horizontal layer 2 translucent level (layer 2 interaction)

LoTablePtrs:
;$00BEA8
	dw Layer1LoPtrs
	dw Layer2LoPtrs

HiTablePtrs:
;$00BEAC
	dw Layer1HiPtrs
	dw Layer2HiPtrs
namespace off
	%SetDuplicateOrNullPointer($000000, SMW_LevelDataLayoutTables_NullLevelLayoutData)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode04_PrepareTitleScreen(Address)
namespace SMW_GameMode04_PrepareTitleScreen
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_CheckWhichControllersArePluggedIn_Main	; Get the current controller port to accept data from.
	JSR.w SMW_GameMode12_PrepareLevel_Main	; Load the title screen level.
	STZ.w !RAM_SMW_Counter_TimerHundreds	; Set the time limit to 0.
	JSR.w SMW_ClearLayer3Tilemap_Main	; Clean out Layer 3.
	LDA.b #!Define_SMW_StripeImage_TitleScreenLayer3	;\
	STA.b !RAM_SMW_Graphics_StripeImageToUpload	;| Upload the title screen stripe image.
	JSR.w SMW_LoadStripeImage_Sub	;/
	JSR.w SMW_BufferPalettesRoutines_TitleScreen	; Load palettes to RAM.
	JSR.w SMW_UpdateEntirePalette_Main	; Upload palettes to CGRAM.
	JSL.l SMW_LoadOverworldSprites_Main				;\ Glitch: This can cause glitch tiles to appear when the title screen is fading in.
									;/ Why this is here and not in the overworld loading code is anyones' guess.
	LDA.b #$01			; \ Set special level to x01
	STA.w !RAM_SMW_Misc_NMIToUseFlag	; /
	; Change from [A9 33 85] to [4C C0 9A] to disable the circle fade in from
	; Title screen. Use in conjunction with address $009436.
	LDA.b #$33
	STA.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings
	LDA.b #$00
	STA.b !RAM_SMW_Mirror_BG3And4WindowMaskSettings	;| Set up window and math settings for the title screen circle.
	LDA.b #$23
	STA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings
	LDA.b #$12
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings
	JSR.w SMW_GameMode06_CircleEffect_CODE_009443
	LDA.b #$10
	STA.w !RAM_SMW_Timer_TitleScreenInputTimer
	JMP.w SMW_GameMode00_LoadNintendoPresents_Mode04Finish	; Re-enable NMI and auto-joypad read.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode0E_ShowOverworld(Address)
namespace SMW_GameMode0E_ShowOverworld
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_CheckWhichControllersArePluggedIn_Main
	INC.b !RAM_SMW_Counter_LocalFrames	; Increase alternate frame counter
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt
if defined("Define_SMW_SA1")
	JSL.l overworld_main
else
	JSL.l Bank04			; (Bank 4.asm)
endif
	JMP.w SMW_CompressOAMTileSizeBuffer_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_DrawLoadingLetters(Address)
namespace SMW_DrawLoadingLetters
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_BufferLoadingLetterTiles_Main	; Load "MARIO/LUIGI START !" tiles.
	LDX.b #TileData_TopTiles_START-TileData	;\ Load "MARIO START !".
	LDA.b #$B0			;/ X position of the rightmost tile of the "MARIO START !" message.
	LDY.w !RAM_SMW_Flag_ActiveBonusGame	;\
	BEQ.b CODE_0091CA		;| If loading a bonus game, change the text display to "BONUS GAME".
	STZ.w !RAM_SMW_Counter_TimerHundreds	;|\
	STZ.w !RAM_SMW_Counter_TimerTens	;|| Clear the timer.
	STZ.w !RAM_SMW_Counter_TimerOnes	;|/
	LDX.b #TileData_TopTiles_BONUSGAME-TileData	;|
	LDA.b #$A4			;/ X position of the rightmost tile of the "BONUS GAME" message.
CODE_0091CA:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STZ.b !RAM_SMW_Misc_ScratchRAM01	; $01 = 00
	LDY.b #$70			; Number of tiles to draw, x8.
CODE_0091D0:
	JSR.w GFXRt			; Draw the message to the screen.
	INX
	CPX.b #(TileData_TopTiles_MARIO)-TileData
	BNE.b CODE_0091DF
	LDA.w !RAM_SMW_Player_CurrentCharacter
	; Change it to D0 to switch the "Mario/Luigi Start"
	BEQ.b CODE_0091DF
	LDX.b #TileData_TopTiles_LUIGI-TileData
CODE_0091DF:
	TYA				;\
	SEC				;| Move to next letter.
	SBC.b #$08			;|
	TAY				;/
	BNE.b CODE_0091D0
	JMP.w SMW_CompressOAMTileSizeBuffer_Main	; Prep OAM for upload.

GFXRt:
	LDA.w TileData_TopProp,x	;\
	STA.w SMW_OAMBuffer[$42].Prop,y	;| Store the YXPPCCCT properties to OAM.
	LDA.w TileData_BottomProp,x	;|
	STA.w SMW_OAMBuffer[$43].Prop,y	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.w SMW_OAMBuffer[$42].XDisp,y	;| Set the X position of each letter to OAM.
	STA.w SMW_OAMBuffer[$43].XDisp,y	;/
	SEC				;\
	SBC.b #$08			;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;| Move next letter 8 pixels to the left.
	BCS.b CODE_009206		;|
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;/
CODE_009206:
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\
	AND.b #$01			;| Set size.
	STA.w SMW_OAMTileSizeBuffer[$42].Slot,y	;|
	STA.w SMW_OAMTileSizeBuffer[$43].Slot,y	;/
	PLY
	LDA.w TileData_TopTiles,x	;\
	BMI.b Return00922E		;|
	STA.w SMW_OAMBuffer[$42].Tile,y	;| Store the tile numbers to OAM.
	LDA.w TileData_BottomTiles,x	;|
	STA.w SMW_OAMBuffer[$43].Tile,y	;/
	LDA.b #$68			;\ Y position of the top half of the loading screen messages.
	STA.w SMW_OAMBuffer[$42].YDisp,y	;/
	LDA.b #$70			;\ Y position of the bottom half of the loading screen messages.
	STA.w SMW_OAMBuffer[$43].YDisp,y	;/
Return00922E:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_DrawLoadingLetters(Address)
namespace SMW_DrawLoadingLetters
%InsertMacroAtXPosition(<Address>)

TileData:
.TopTiles:							; Note: The below 4 tables store their data in reverse order (ex. "! TRATS")
..START:
	; Tile numbers for 'MARIO START' and various similar messages. $0090EE is
	; for the top half of Time Up. $009122 is for the bottom half of Time Up.
	db $00,$FF,$4D,$4C,$03,$4D,$5D,$FF	; " START!" top
..MARIO:
	db $03,$00,$4C,$03,$04,$15	; "MARIO" top
..LUIGI:
	db $00,$02,$00,$4A,$4E,$FF	; "LUIGI" top
..OVER:
	db $4C,$4B,$4A,$03		; "GAME OVER" top
..GAME:
	db $5F,$05,$04,$03,$02
..UP:
	db $00,$FF,$01,$4A		; "TIME UP" top
..TIME:
	db $5F,$05,$04,$00,$4D
..BONUSGAME:
	db $5D,$03,$02,$01,$00,$FF,$5B,$14			;\ Note: These tile numbers correspond to different graphics than the other sets of loading letters.
	db $5F,$01,$5E,$FF,$FF,$FF				;/ Also, these last 3 $FFs seem to have been a leftover. They're still used however.

.BottomTiles:
..START:
	db $10,$FF,$00,$5C,$13,$00,$5D,$FF	; " START!" bottom
..MARIO:
	db $03,$00,$5C,$13,$14,$15	; "MARIO" bottom
..LUIGI:
	db $00,$12,$00,$03,$5E,$FF	; "LUIGI" bottom
..OVER:
	db $5C,$4B,$5A,$03		; "GAME OVER" bottom
..GAME:
	db $5F,$05,$14,$13,$12
..UP:
	db $10,$FF,$11,$03		; "TIME UP" bottom
..TIME:
	db $5F,$05,$14,$00,$00
..BONUSGAME:
	db $5D,$03,$12,$11,$10,$FF,$5B,$01			;\ Note: Same deal as above.
	db $5F,$01,$5E,$FF,$FF,$FF				;/

.TopProp:
..START:
; YXPPCCCT properties for 'MARIO START' and various similar messages. Change
; $00913F from 30 to 34 and $009170 from F0 to F4 to fix the S in
; "Mario/Luigi Start". $009156 is for the top half of 'TIME UP".
#LM182Hijack_SPaletteFix1:
	db $34,$00,$34,$34,$34,$34,$30,$00			; Glitch: Change the $30 to $34 fix the S's palette in Mario/Luigi Start! (LM: Which Lunar Magic does for you. (1.82+))
..MARIO:
	db $34,$34,$34,$34,$74,$34	; "MARIO" top
..LUIGI:
	db $34,$34,$34,$34,$34,$00	; "LUIGI" top
..OVER:
	db $34,$34,$34,$34		; "GAME OVER" top
..GAME:
	db $34,$34,$34,$34,$34
..UP:
	db $34,$00,$34,$34		; "TIME UP" top
..TIME:
	db $34,$34,$34,$34,$34
..BONUSGAME:
	db $34,$34,$34,$34,$34,$34,$34,$34	; "BONUS GAME" top
	db $34,$34,$34

.BottomProp:
..START:
#LM182Hijack_SPaletteFix2:
	db $34,$00,$B4,$34,$34,$B4,$F0,$00			; Glitch: Change the $F0 to $F4 to fix the S's palette in Mario/Luigi Start! (LM: Which Lunar Magic does for you. (1.82+))
..MARIO:
	db $B4,$B4,$34,$34,$74,$B4	; "MARIO" bottom
..LUIGI:
	db $B4,$34,$B4,$B4,$34,$00	; "LUIGI" bottom
..OVER:
	db $34,$B4,$34,$B4		; "GAME OVER" bottom
..GAME:
	db $B4,$B4,$34,$34,$34
..UP:
	db $34,$00,$34,$B4		; "TIME UP" bottom
..TIME:
	db $B4,$B4,$34,$B4,$B4
..BONUSGAME:
	db $B4,$B4,$34,$34,$34,$34,$F4,$B4	; "BONUS GAME" bottom
	db $F4,$B4,$B4
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_BufferLoadingLetterTiles(Address)
namespace SMW_BufferLoadingLetterTiles
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #$0F
#LM000Hijack_DecompressAndConverGFXTo3BPP1:
	JSL.l SMW_GraphicsDecompressionRoutines_Main				; LM: Changes this to a JSL.l to $0EFC00
	LDA.w !RAM_SMW_Flag_ActiveBonusGame
	REP.b #$30			; AXY->16
	BEQ.b CODE_00A842
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0030
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_00A842:
	LDX.w #$0000
CODE_00A845:
	LDY.w #$0008
CODE_00A848:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]
	STA.l !RAM_SMW_Graphics_DecompressedLoadingLetters,x
	INX
	INX
	INC.b !RAM_SMW_Misc_ScratchRAM00
	INC.b !RAM_SMW_Misc_ScratchRAM00
	DEY
	BNE.b CODE_00A848
	LDY.w #$0008
CODE_00A85A:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]
	AND.w #$00FF
	STA.l !RAM_SMW_Graphics_DecompressedLoadingLetters,x
	INX
	INX
	INC.b !RAM_SMW_Misc_ScratchRAM00
	DEY
	BNE.b CODE_00A85A
	CPX.w #$0300
	BCC.b CODE_00A845
	SEP.b #$30			; AXY->8
	LDY.b #$00
#LM221Hijack_DisableSP1VRAMBackup2:
	JSL.l SMW_GraphicsDecompressionRoutines_Main				;\ LM: Skips the code indicated by this comment block. (2.21+)
	REP.b #$30								;| This part of the routine is responsible for preserving tiles 4A-4F/5A-5F so they can be restored after the loading letters are done displaying
	LDA.w #SMW_GraphicDecompressionBuffer[$4A].Tile				;| However, this is unnecessary in ROM hacks because Lunar Magic forces the graphics to reload regardless of which ones were loaded previously, meaning the loading letters will always be overwritten before the level fades in.
	STA.b !RAM_SMW_Misc_ScratchRAM00					;| In the original SMW, it's unnecesary 99% of the time because switching between the overworld/levels will cause SP1 to load GFX 0F/00 and thus cause it to reload.
	LDA.w #(SMW_GraphicDecompressionBuffer[$4A].Tile)>>8			;| The exception to this is if you go to the Bonus Game, since you're going from a level to another level. Because SP1 won't get reloaded, if you were to disable this buffering code, then a couple of Mario's flying poses would have glitch tiles in levels 000/100.
	STA.b !RAM_SMW_Misc_ScratchRAM01					;|
	LDX.w #$0000								;|
CODE_00A886:									;|
	LDY.w #$0008								;|
CODE_00A889:									;|
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]					;|
	STA.w !RAM_SMW_Graphics_DecompressedOverworldGFX+$0100,x		;|
	INX									;|
	INX									;|
	INC.b !RAM_SMW_Misc_ScratchRAM00					;|
	INC.b !RAM_SMW_Misc_ScratchRAM00					;|
	DEY									;|
	BNE.b CODE_00A889							;|
	LDY.w #$0008								;|
CODE_00A89A:									;|
	LDA.b [!RAM_SMW_Misc_ScratchRAM00]					;|
	AND.w #$00FF								;|
	STA.w !RAM_SMW_Graphics_DecompressedOverworldGFX+$0100,x		;|
	INX									;|
	INX									;|
	INC.b !RAM_SMW_Misc_ScratchRAM00					;|
	DEY									;|
	BNE.b CODE_00A89A							;|
	CPX.w #$00C0								;|
	BNE.b CODE_00A8B3							;|
	LDA.w #(SMW_GraphicDecompressionBuffer[$5A].Tile)			;|
	STA.b !RAM_SMW_Misc_ScratchRAM00					;|
CODE_00A8B3:									;|
	CPX.w #$0180								;|
	BCC.b CODE_00A886							;|
	SEP.b #$30								;/
	LDA.b #$01
	STA.w !RAM_SMW_Flag_UploadLoadScreenLettersToVRAM
	STA.w !RAM_SMW_Flag_RestoreSP1TilesAfterMarioStart			; Optimization: Junk
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode17_ShowDeathMessage(Address)
namespace SMW_GameMode17_ShowDeathMessage
%InsertMacroAtXPosition(<Address>)

Main:
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt	; Clear OAM.
	LDA.w !RAM_SMW_Timer_DisplayDeathMessageAnimation
	BNE.b CODE_00978B
	DEC.w !RAM_SMW_Timer_TimeToDisplayDeathMessage
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDY.w !RAM_SMW_Timer_TimeToDisplayDeathMessage
	CPY.b #$30
	BCS.b CODE_00978E
else
	BNE.b CODE_00978E		;! GAME OVER disappears when timer hits $00
endif
	LDA.w !RAM_SMW_Player_CurrentLifeCount	;\ Branch out if the player is not out of lives yet.
	BPL.b CODE_009788		;/
	STZ.w !RAM_SMW_Yoshi_CarryOverLevelsFlag	; Get rid of Yoshi for this player
	LDA.w !RAM_SMW_Player_MariosLives	;\ Branch out if this was a game over,
	ORA.w !RAM_SMW_Player_LuigisLives	;|  but the other player still has lives left.
	BPL.b CODE_009788		;/
	LDX.b #$0C
CODE_009779:
	STZ.w !RAM_SMW_Flag_Collected5YoshiCoins,x	;| Clear all Dragon Coin, checkpoint 1up, and 3up moon flags.
if ver_is_japanese(!Define_Global_ROMToAssemble)
	STZ.w !RAM_SMW_Flag_Collected1upCheckpoints,x
else
	STZ.w !RAM_SMW_Misc_ScratchRAM06,x				; Glitch: Why was this changed in the USA version?
endif
	STZ.w !RAM_SMW_Flag_CollectedMoons,x
	DEX
	BPL.b CODE_009779
	INC.w !RAM_SMW_Flag_ShowContinueAndEnd
CODE_009788:
	JMP.w SMW_GameMode0A_PlayerSelect_CODE_009E62

CODE_00978B:
	SEC				;\
	SBC.b #$04			;// Speed at which the "GAME OVER" / "TIME UP !" messages slide together.
CODE_00978E:
	STA.w !RAM_SMW_Timer_DisplayDeathMessageAnimation	;\
	CLC				;| Set X position for the right half of the message.
	ADC.b #$A0			;| X position of the right side of the "OVER" / "UP !" half of the messages when they slide together.
	STA.b !RAM_SMW_Misc_ScratchRAM00	;|
	ROL.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDX.w !RAM_SMW_Misc_DeathMessageToDisplay
	LDY.b #$48
CODE_00979D:
	CPY.b #$28			;\ Branch if currently loading the right half of the message.
	BNE.b CODE_0097AE		;/
	LDA.b #$78			;\ X position of the right side of the "GAME " / "TIME " half of the messages when they slide together.
	SEC				;|
	SBC.w !RAM_SMW_Timer_DisplayDeathMessageAnimation	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;| Set X position for the left half of the message.
	ROL				;|
	EOR.b #$01			;|
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
CODE_0097AE:
	JSR.w SMW_DrawLoadingLetters_GFXRt	; Load the selected death screen message.
	INX
	TYA				;\
	SEC				;|
	SBC.b #$08			;| Move to next letter.
	TAY				;|
	BNE.b CODE_00979D		;/
	JMP.w SMW_CompressOAMTileSizeBuffer_Main	; Prep OAM for upload.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode16_LoadDeathMessage(Address)
namespace SMW_GameMode16_LoadDeathMessage
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_ClearLayer3Tilemap_Main	; Clean out Layer 3.
	JSR.w SMW_BufferLoadingLetterTiles_Main	; Load TIME UP/GAME OVER tiles.
	JMP.w SMW_GameMode00_LoadNintendoPresents_CODE_0093CA	; Load palettes and initialize screen settings.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode00_LoadNintendoPresents(Address)
namespace SMW_GameMode00_LoadNintendoPresents
%InsertMacroAtXPosition(<Address>)

; X position of the "Nintendo Presents" tiles
XDisp:
	db $60,$70,$80,$90

; Nintendo Presents logo tilemap
Tiles:
	db $02,$04,$06,$08		; Nintendo Presents tilemap

Main:
	JSR.w SMW_ClearLayer3Tilemap_Main	; Clean out Layer 3.
	JSR.w SMW_SetStandardPPUSettings_Main	; Set up various registers (screen mode, CGADDSUB, windows...).
	JSR.w SMW_UploadGraphicsFiles_Layer3	; Load Layer 3 GFX.
if ver_is_smasw(!Define_Global_ROMToAssemble) == 0
	LDY.b #$0C
	LDX.b #$03
CODE_00939E:
	LDA.w XDisp,x
	STA.w SMW_OAMBuffer[!OAM_SMW_NintendoPresents&$7F].XDisp,y
	LDA.b #$70
	STA.w SMW_OAMBuffer[!OAM_SMW_NintendoPresents&$7F].YDisp,y
	LDA.w Tiles,x
	STA.w SMW_OAMBuffer[!OAM_SMW_NintendoPresents&$7F].Tile,y
	LDA.b #$30
	STA.w SMW_OAMBuffer[!OAM_SMW_NintendoPresents&$7F].Prop,y
	DEY
	DEY
	DEY
	DEY
	DEX
	BPL.b CODE_00939E
	LDA.b #$AA			;\ Make OBJs 16x16
	STA.w SMW_UpperOAMBuffer[!OAM_SMW_NintendoPresents&$7F].Slot	;/
	; Code responsible for the "Nintendo Presents" logo sound effect. $0093C1
	; (1 byte) is the sound effect ID ($01). $0093C3 (2 bytes) is the port
	; ($1DFC).
	LDA.b #!Define_SMW_Sound1DFC_Coin	;\ Play "Bing" sound
	STA.w !RAM_SMW_IO_SoundCh3	;/
	LDA.b #!Define_SMW_Timer_DisplayNintendoPresents	; \ Set timer to x40
	STA.w !RAM_SMW_Timer_DisplayNintendoPresents	; /
endif
CODE_0093CA:
	LDA.b #!ScreenDisplayRegister_MaxBrightness0F	;\ Set brightness to max
	STA.w !RAM_SMW_Mirror_ScreenDisplayRegister	;/
	LDA.b #$01			;\
	STA.w !RAM_SMW_Misc_MosaicDirection	;/ Set mosaic to growing
	STZ.w !RAM_SMW_Misc_SpritePaletteSetting	; Sprite palette setting = 0
	JSR.w SMW_BufferPalettesRoutines_Levels	; Load palettes from ROM to RAM.
	STZ.w !RAM_SMW_Palettes_BackgroundColorLo	;\ Black background
	STZ.w !RAM_SMW_Palettes_BackgroundColorHi	;/
	JSR.w SMW_UpdateEntirePalette_Main	; Init for the DMA of the Nintendo Presents?
	STZ.w !RAM_SMW_Misc_BlinkingCursorPos	; Set menu pointer position to 0
	LDX.b #$10			; Enable sprites, disable layers
	LDY.b #$04			; Set Layer 3 to subscreen
CODE_0093EA:
	LDA.b #$01			;\
	STA.w !RAM_SMW_Misc_NMIToUseFlag	;/ Mini-mode select, now set for the DMA sort of stuff
	LDA.b #$20			; CGADSUB = 20
	JSR.w SMW_SetVisibleLayers_Main	; Set up CGADSUB, main/sub screen designation, and windowing.
CODE_0093F4:
	INC.w !RAM_SMW_Misc_GameMode	; Move on to Game Mode 01
Mode04Finish:
#LM221Hijack_TurnOnScreenTimingFix:
	LDA.b #$81			;\ Enable NMI and auto-joypad reading.
	STA.w !REGISTER_IRQNMIAndJoypadEnableFlags	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode10_BufferLevelLoadMessage(Address)
namespace SMW_GameMode10_BufferLevelLoadMessage
%InsertMacroAtXPosition(<Address>)

; This is the beginning of the code that is executed for game mode 10 (the
; black period between fadeout from the OW and Mario Start). $0096A5 is
; which Layer 1 tile on the overworld will prevent the "Mario Start!" from
; appearing if the player is on it. (Default is $56, the Yoshi's House
; tile.) Change $0096A6 to EA EA to make MARIO START! appear on the Yoshi's
; house OW tile number, or to 80 03 to make the MARIO START! never appear.
Main:
	JSR.w SMW_ClearLayer3Tilemap_Main	; Clean out Layer 3.
	LDA.w !RAM_SMW_Flag_ActiveBonusGame	;\ Branch if bonus game should be loaded.
	BNE.b CODE_0096A8		;/
	LDA.w !RAM_SMW_Counter_SublevelsEntered
	ORA.w !RAM_SMW_Flag_ShowPlayerStart
	ORA.w !RAM_SMW_Misc_IntroLevelFlag
	BNE.b CODE_0096AB
	LDA.w !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo
	CMP.b #$56							; Note: If the player is standing on Yoshi's house, then don't display "Mario Start!".
	BEQ.b CODE_0096AB
CODE_0096A8:
	JSR.w SMW_DrawLoadingLetters_Main	; Show MARIO START!
CODE_0096AB:
	JMP.w SMW_GameMode00_LoadNintendoPresents_CODE_0093CA	; Load palettes and initialize screen settings.
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_TurnOffIO(Address)
namespace SMW_TurnOffIO
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !REGISTER_IRQNMIAndJoypadEnableFlags	; Disable interupts.
	STZ.w !REGISTER_HDMAEnable	; Disable HDMA.
	LDA.b #!ScreenDisplayRegister_SetForceBlank|!ScreenDisplayRegister_MinBrightness00	;\ Force blank (turn the screen off).
	STA.w !REGISTER_ScreenDisplayRegister	;/
	RTS				; And return
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode0C_LoadOverworld(Address)
namespace SMW_GameMode0C_LoadOverworld
%InsertMacroAtXPosition(<Address>)

; 16-bit X-coordinates for each of the seven submaps. The main map has
; values of 0, and is overridden elsewhere.
DATA_00A06B:
	dw $0000		; Main Map
	dw $FFEF		; Yoshi's Island
	dw $FFEF		; Vanilla Dome
	dw $FFEF		; Forest of Illusion
	dw $00F0		; Valley of Bowser
	dw $00F0		; Special World
	dw $00F0		; Star World

; 16-bit Y-coordinates for each of the seven submaps. The main map has
; values of 0, and is overridden elsewhere.
DATA_00A079:
	dw $0000		; Main Map
	dw $FFD8		; Yoshi's Island
	dw $0080		; Vanilla Dome
	dw $0128		; Forest of Illusion
	dw $FFD8		; Valley of Bowser
	dw $0080		; Special World
	dw $0128		; Star World

Main:
	JSR.w SMW_TurnOffIO_Main
	LDA.w !RAM_SMW_Overworld_WarpingOnPipeOrStarFlag
	BEQ.b CODE_00A093
	JSL.l SMW_HandleOverworldStarPipeWarp_SetPlayerDestination
CODE_00A093:
	JSR.w SMW_ClearOverworldAndCutsceneRAM_Main
	LDA.w !RAM_SMW_Misc_IntroLevelFlag	;\ Branch unless using RAM $0109
	BEQ.b CODE_00A0B0		;/   to bypass the world map.
	LDA.b #!Define_SMW_Timer_DisplayIntroMessage
	STA.w !RAM_SMW_Timer_DisplaySpecialMessage
#LM000Hijack_Unknown00A0A0:
	STZ.w !RAM_SMW_Overworld_MarioMap					; Note: !Define_SMW_Overworld_MainMap
	LDA.b #!MosaicSizeAndBGEnable_PixelSize16x16
	STA.w !RAM_SMW_Mirror_MosaicSizeAndBGEnable
	LDA.b #!Define_SMW_GameMode10_BufferLevelLoadMessage
	STA.w !RAM_SMW_Misc_GameMode
	JMP.w SMW_GameMode00_LoadNintendoPresents_Mode04Finish

CODE_00A0B0:
	JSR.w SMW_ClearLayer3Tilemap_Main
	JSR.w SMW_HandleSPCUploads_UploadOverworldMusicBank	; <-
	JSR.w SMW_SetStandardPPUSettings_Main	; Set up the screen
	STZ.w !RAM_SMW_Misc_MusicRegisterBackup	; No music
	LDX.w !RAM_SMW_Player_CurrentCharacter	; X = 0 if Mario, X = 1 if Luigi
	LDA.w !RAM_SMW_Player_CurrentLifeCount
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	BPL.b CODE_00A0C7		;!
	INC.w !RAM_SMW_Pointer_DisplayOverworldPrompt	;!
CODE_00A0C7:
endif
	STA.w !RAM_SMW_Player_MariosLives,x
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	; Saves Mario/Luigi's powerups based on which one you are using for the
	; level
	STA.w !RAM_SMW_Player_MariosPowerUp,x
	LDA.w !RAM_SMW_Player_CurrentCoinCount
	STA.w !RAM_SMW_Player_MariosCoins,x
	LDA.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	BEQ.b CODE_00A0DD
	LDA.w !RAM_SMW_Yoshi_CurrentYoshiColor
CODE_00A0DD:
	STA.w !RAM_SMW_Player_MariosYoshi,x
	LDA.w !RAM_SMW_Player_CurrentItemBox	;\Update the reserved item.
	STA.w !RAM_SMW_Player_MariosItemBox,x	;/
	LDA.b #$03			;\Turn off color windows for color math.
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings	;/Enable "fixed color", "direct select".
	LDA.b #$30			;\Screen settings if skipping ahead
	LDX.b #$15			;/
	LDY.w !RAM_SMW_Flag_ShowContinueAndEnd	;\Skip ahead unless returning to
	BEQ.b CODE_00A11B		;/  world map after Game Over.
if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
	JSR.w SMW_LoadSaveBufferData_Main	;!
	LDA.w !RAM_SMW_Counter_EventsTriggered	;!
	; Part of the routine that runs after dying with zero lives. If # of levels
	; beat is zero, then it will take you back to the intro screen, if levels
	; beat is positive, it will take you back to the last place you saved on
	; the OW and bring up the Continue/End dialog. Change this byte to BRA
	; ($80) to cause it to not send you to the intro screen and bring up the
	; Continue/End dialog if you haven't saved for the first time. (In other
	; words, it will take you back to Yoshi's House on an unedited overworld.)
	BNE.b CODE_00A101		;!
endif
	JSR.w SMW_GameMode07_TitleScreenDemo_FadeOutToTitleScreen	;!
	JMP.w SMW_GameMode00_LoadNintendoPresents_CODE_0093F4	;!

if ver_is_arcade(!Define_Global_ROMToAssemble) == 0
CODE_00A101:
	JSL.l SMW_LoadOverworldLayer2AndEventsTilemaps_Main	;!
	REP.b #$20			;! A->16
	LDA.w #$318C			;!
	STA.w !RAM_SMW_Palettes_BackgroundColorLo	;!
	SEP.b #$20			;! A->8
	LDA.b #$30			;!
	STA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings	;!
	LDA.b #$20			;!
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings	;!
	LDA.b #$B3			;!
	LDX.b #$17			;!
endif
CODE_00A11B:
	LDY.b #$02
	JSR.w SMW_SetVisibleLayers_Main
	STX.w !REGISTER_MainScreenWindowMask	; Window Mask Designation for Main Screen
	STY.w !REGISTER_SubScreenWindowMask	; Window Mask Designation for Sub Screen
	JSL.l SMW_LoadOverworldLayer1AndEvents_Main	; Load all layers of world map
	LDX.w !RAM_SMW_Player_CurrentCharacter
	LDA.w !RAM_SMW_Overworld_MarioMap,x
	ASL
	TAX
	REP.b #$20			; A->16
	LDA.w DATA_00A06B,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	LDA.w DATA_00A079,x
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
#LM000Hijack_Unknown00A140:
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	SEP.b #$20			; A->8
	JSR.w SMW_UploadGraphicsFiles_Main
	LDY.b #$14
#LM000Hijack_Unknown00A149:
	JSL.l SMW_GraphicsDecompressionRoutines_Main
	JSR.w SMW_BufferPalettesRoutines_Overworld_Sub
	JSR.w SMW_UpdateEntirePalette_Main
#LM000Hijack_Unknown00A153:
	LDA.b #!Define_SMW_StripeImage_OverworldBorder	; \ Load overworld border
	STA.b !RAM_SMW_Graphics_StripeImageToUpload
	JSR.w SMW_LoadStripeImage_Sub
	; Call to the routine to draw the number of lives on the overworld border.
	; Change to [80 02] (BRA $02) to disable the amount of lives from being
	; shown in the overworld border. Use with $04A530.
	JSL.l SMW_LoadOverworldLifeCounter_Main
	JSR.w SMW_LoadStripeImage_Sub
	JSL.l CODE_048D91
	JSL.l SMW_InitializeOverworldTilemaps_Main
	LDA.b #$F0
	STA.b !RAM_SMW_Mirror_OAMAddressLo
	JSR.w SMW_CompressOAMTileSizeBuffer_Main
	JSR.w SMW_LoadStripeImage_Sub
	STZ.w !RAM_SMW_Pointer_CurrentOverworldProcess
	JSR.w SMW_SetKeepGameModeActiveTimer_OneFrame
	LDA.b #$02
	STA.w !RAM_SMW_Misc_NMIToUseFlag
	REP.b #$10			; XY->16
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDX.w #$01DE
else
	LDX.w #$01BE
endif
	LDA.b #$FF
CODE_00A185:
	STZ.w !RAM_SMW_Misc_HDMAWindowEffectTable,x
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$01,x
	DEX
	DEX
	BPL.b CODE_00A185
	JSR.w SMW_SetupHDMAWindowingEffects_CODE_0092A0
	JMP.w SMW_GameMode00_LoadNintendoPresents_CODE_0093F4
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

; Info: See "Player Poses.png" to see what the player poses look like.
; This image was taken from the smw wiki.

macro ROUTINE_RT00_SMW_PlayerGFXRt(Address)
namespace SMW_PlayerGFXRt
%InsertMacroAtXPosition(<Address>)

PlayerXYDispIndexIndex:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $02,$04,$04,$04,$0E,$08,$00,$00
	db $00,$00,$00,$00,$00,$00,$08,$08
	db $08,$08,$08,$08,$00,$00,$00,$00
	db $0C,$10,$12,$14,$16,$18,$1A,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$06,$00,$00
	db $00,$00,$00,$0A,$00,$00

PlayerXYDispIndex:
	db $00,$08					; Running
	db $10,$14					; Diagonal
	db $18,$1E					; Sideways
	db $24,$24					; Hurt
	db $28,$30					; ClimbingAndRideYoshi
	db $38,$3E					; BigPBallon
	db $44,$4A					; PointWhileOnYoshi1
	db $50,$54					; VictoryOnYoshi
	db $58,$58					; PointWhileOnYoshi2
	db $5C,$60					; CapeFlight1
	db $64,$68					; CapeFlight2
	db $6C,$70					; CapeFlight3
	db $74,$78					; CapeFlight4
	db $7C,$80					; CapeFlight5

XDisp:
.Running
	; X positions of Mario's tiles in various poses, two bytes per tile.
	dw $0000,$0000,$0010,$0010
	dw $0000,$0000,$FFF8,$FFF8
.Diagonal
	dw $000E,$0006
	dw $FFF2,$FFFA
.Sideways
	dw $0017,$0007,$000F
	dw $FFEA,$FFFA,$FFFA
.Hurt
	dw $0000,$0000
.ClimbingAndRideYoshi
	dw $0000,$0000,$0010,$0010
	dw $0000,$0000,$FFF8,$FFF8
.BigPBallon
	dw $0000,$FFF8,$0008
	dw $0000,$0008,$FFF8
.PointWhileOnYoshi1
	dw $0000,$0000,$FFF8
	dw $0000,$0000,$0010
.VictoryOnYoshi
	dw $0002,$0000
	dw $FFFE,$0000
.PointWhileOnYoshi2
	dw $0000,$0000
.CapeFlight1
	dw $FFFC,$0005
	dw $0004,$FFFB
.CapeFlight2
	dw $FFFB,$0006
	dw $0005,$FFFA
.CapeFlight3
	dw $FFF9,$0009
	dw $0007,$FFF7
.CapeFlight4
	dw $FFFD,$FFFD
	dw $0003,$0003
.CapeFlight5
	dw $FFFF,$0007
	dw $0001,$FFF9

.Cape01
	dw $000A
	dw $FFF6
.Cape02
	dw $0008
	dw $FFF8
.Cape03
	dw $0008
	dw $FFF8
.Cape04
	; X offset of cape when climbing.
	dw $0000
.Cape05
	dw $0004
	dw $FFFC
.Cape06
	dw $FFFE
	dw $0002
.Cape07
	dw $000B
	dw $FFF5
.Cape08
	dw $0014
	dw $FFEC
.Cape09
	dw $000E
	dw $FFF3
.Cape10
	dw $0008
	dw $FFF8
.Cape11
	dw $000C,$0014,$FFFD
	dw $FFF4,$FFF4,$000B
.Cape12
	dw $000B,$0003,$0013
	dw $FFF5,$0005,$FFF5
.Cape13
	dw $0009,$0001,$0001
	dw $FFF7,$0007,$0007
.Cape14
	dw $0005,$000D,$000D
	dw $FFFB,$FFFB,$FFFB
.Cape15
	dw $FFFF,$000F
	dw $0001,$FFF9
.Cape16
	dw $0000

YDisp:
.Running
	; Y positions of Mario's tiles in various poses, two bytes per tile.
	dw $0001,$0011,$0011,$0019
	dw $0001,$0011,$0011,$0019
.Diagonal
	dw $000C,$0014
	dw $000C,$0014
.Sideways
	dw $0018,$0018,$0028
	dw $0018,$0018,$0028
.Hurt
	dw $0006,$0016
.ClimbingAndRideYoshi
	dw $0001,$0011,$0009,$0011
	dw $0001,$0011,$0009,$0011
.BigPBallon
	dw $0001,$0011,$0011
	dw $0001,$0011,$0011
.PointWhileOnYoshi1
	dw $0001,$0011,$0011
	dw $0001,$0011,$0011
.VictoryOnYoshi
	dw $0001,$0011
	dw $0001,$0011
.PointWhileOnYoshi2
	dw $0011,$0005
.CapeFlight1
	dw $0004,$0014
	dw $0004,$0014
.CapeFlight2
	dw $000C,$0014
	dw $000C,$0014
.CapeFlight3
	dw $0010,$0010
	dw $0010,$0010
.CapeFlight4
	dw $0010,$0000
	dw $0010,$0000
.CapeFlight5
	dw $0010,$0000
	dw $0010,$0000

.Cape01
	dw $000B
	dw $000B
.Cape02
	dw $0011
	dw $0011
.Cape03
	dw $FFFF
	dw $FFFF
.Cape04
	; Y offset of cape when climbing.
	dw $0010
.Cape05
	dw $0010
	dw $0010
.Cape06
	dw $0010
	dw $0010
.Cape07
	dw $0010
	dw $0010
.Cape08
	dw $0015
	dw $0015
.Cape09
	dw $0025
	dw $0025
.Cape10
	dw $0004
	dw $0004
.Cape11
	dw $0004,$0014,$0014
	dw $0004,$0014,$0014
.Cape12
	dw $0004,$0004,$0014
	dw $0004,$0004,$0014
.Cape13
	dw $0000,$0008,$0000
	dw $0000,$0008,$0000
.Cape14
	dw $0000,$0010,$0018
	dw $0000,$0010,$0018
.Cape15
	dw $0000,$0010
	dw $0000,$0010
.Cape16
	dw $FFF8

; Tileset to use for Mario, paged by status ($7E0019)
PowerupTilesetIndex:
	db $00,$46,$83,$46

TilesIndex:
.Small
	; Tile expansion pointer table (Small Mario)
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$28,$00,$00
.Big
.Fire
	; Tile expansion pointer table (Big Mario)
	db $00,$00,$00,$00,$04,$04,$04,$00
	db $00,$00,$00,$00,$08,$00,$00,$00
	db $00,$0C,$0C,$0C,$00,$00,$10,$10
	db $14,$14,$18,$18,$00,$00,$1C,$00
	db $00,$00,$00,$20,$00,$00,$00,$00
	db $24,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00
.Cape
	db $00,$00,$00,$00,$04,$04,$04,$00
	db $00,$00,$00,$00,$08,$00,$00,$00
	db $00,$0C,$0C,$0C,$00,$00,$10,$10
	db $14,$14,$18,$18,$00,$00,$1C,$00
	db $00,$00,$00,$20,$00,$00,$00,$00
	db $24,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00
; Tile expansion table (8x8 tiles in GFX00 used by Mario)
Tiles:
	db $00,$02,$80,$80
	db $00,$02,$0C,$80
	db $00,$02,$1A,$1B
	db $00,$02,$0D,$80
	db $00,$02,$22,$23
	db $00,$02,$32,$33
	db $00,$02,$0A,$0B
	db $00,$02,$30,$31
	db $00,$02,$20,$21
	db $00,$02,$7E,$80
	db $00,$02,$02,$80
	db $04,$7F,$4A,$5B

UNK_00E00A:
	db $4B,$5A

HeadTilePointerIndex:
.Small
	; Mario upper tile.
	db $50,$50,$50,$09,$50,$50,$50,$50
	db $50,$50,$09,$2B,$50,$2D,$50,$D5
	db $2E,$C4,$C4,$C4,$D6,$B6,$50,$50
	db $50,$50,$50,$50,$50,$C5,$D7,$2A
	db $E0,$50,$D5,$29,$2C,$B6,$D6,$28
	db $E0,$E0,$C5,$C5,$C5,$C5,$C5,$C5
	db $5C,$5C,$50,$5A,$B6,$50,$28,$28
	db $C5,$D7,$28,$70,$C5,$70,$1C,$93
	db $C5,$C5,$0B,$85,$90,$84
.Big
.Fire
	db $70,$70,$70,$A0,$70,$70,$70,$70
	db $70,$70,$A0,$74,$70,$80,$70,$84
	db $17,$A4,$A4,$A4,$B3,$B0,$70,$70
	db $70,$70,$70,$70,$70,$E2,$72,$0F
	db $61,$70,$63,$82,$C7,$90,$B3,$D4
	db $A5,$C0,$08,$54,$0C,$0E,$1B,$51
	db $49,$4A,$48,$4B,$4C,$5D,$5E,$5F
	db $E3,$90,$5F,$5F,$C5
.Cape
	db $70,$70,$70,$A0,$70,$70,$70,$70
	db $70,$70,$A0,$74,$70,$80,$70,$84
	db $17,$A4,$A4,$A4,$B3,$B0,$70,$70
	db $70,$70,$70,$70,$70,$E2,$72,$0F
	db $61,$70,$63,$82,$C7,$90,$B3,$D4
	db $A5,$C0,$08,$64,$0C,$0E,$1B,$51
	db $49,$4A,$48,$4B,$4C,$5D,$5E,$5F
	db $E3,$90,$5F,$5F,$C5

BodyTilePointerIndex:
.Small
	; Mario lower tile.
	db $71,$60,$60,$19,$94,$96,$96,$A2
	db $97,$97,$18,$3B,$B4,$3D,$A7,$E5
	db $2F,$D3,$C3,$C3,$F6,$D0,$B1,$81
	db $B2,$86,$B4,$87,$A6,$D1,$F7,$3A
	db $F0,$F4,$F5,$39,$3C,$C6,$E6,$38
	db $F1,$F0,$C5,$C5,$C5,$C5,$C5,$C5
	db $6C,$4D,$71,$6A,$6B,$60,$38,$F1
	db $5B,$69,$F1,$F1,$4E,$E1,$1D,$A3
	db $C5,$C5,$1A,$95,$10,$07
.Big
.Fire
	db $02,$01,$00,$02,$14,$13,$12,$30
	db $27,$26,$30,$03,$15,$04,$31,$07
	db $E7,$25,$24,$23,$62,$36,$33,$91
	db $34,$92,$35,$A1,$32,$F2,$73,$1F
	db $C0,$C1,$C2,$83,$D2,$10,$B7,$E4
	db $B5,$61,$0A,$55,$0D,$75,$77,$1E
	db $59,$59,$58,$02,$02,$6D,$6E,$6F
	db $F3,$68,$6F,$6F,$06
.Cape
	db $02,$01,$00,$02,$14,$13,$12,$30
	db $27,$26,$30,$03,$15,$04,$31,$07
	db $E7,$25,$24,$23,$62,$36,$33,$91
	db $34,$92,$35,$A1,$32,$F2,$73,$1F
	db $C0,$C1,$C2,$83,$D2,$10,$B7,$E4
	db $B5,$61,$0A,$55,$0D,$75,$77,$1E
	db $59,$59,$58,$02,$02,$6D,$6E,$6F
	db $F3,$68,$6F,$6F,$06

; This is a two byte table used to index the player's palette based on the
; direction the player is facing.
TileXFlip:
	db $00,$40

; Cape tilemap indices. That table controls the additional tiles used by the
; cape powerup, indexed by $7E13E0.
DATA_00E18E:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$0D,$00,$10
	db $13,$22,$25,$28,$00,$16,$00,$00
	db $00,$00,$00,$00,$00,$08,$19,$1C
	db $04,$1F,$10,$10,$00,$16,$10,$06
	db $04,$08,$2B,$30,$35,$3A,$3F,$43
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $16,$16,$00,$00,$08,$00,$00,$00
	db $00,$00,$00,$10,$04,$00

; Miscellaneous table to the cape tiles. The values in the table is indexed
; by $00E18E which in turn is indexed by $7E13E0. Stored in this order are
; the hidden tiles flags (see $7E0078 for more information), 3rd player tile
; / cape image (equivalent to the tile number on page 9 in Lunar Magic),
; index to the 3rd tile offset, index to the 8x8 tile image (same formula as
; with 3rd image) and index to 8x8 tile number. The data has got no clear
; separation (that is, multiple tilemap data are interleaved) and indices
; can only be derived from $00E18E. Note that if the third tile image is
; loaded, values 0x00 - 0x03 is used together with $7E13DF * 4 as an index
; to the tables $00E23A and $00E266 instead.
DATA_00E1D4:
	db $06,$00,$06,$00,$86
	db $02,$06,$03,$06,$01
	db $06,$CE,$06,$06,$40
	db $00,$06,$2C,$06,$06
	db $44,$0E,$86,$2C,$06
	db $86,$2C,$0A,$86,$84
	db $08,$06,$0A,$02,$06
	db $AC,$10,$06,$CC,$10
	db $06,$AE,$10,$00,$8C
	db $14,$80,$2E,$00,$CA
	db $16,$91,$2F,$00,$8E
	db $18,$81,$30,$00,$EB
	db $1A,$90,$31,$04,$ED
	db $1C,$82,$06,$92,$1E

CapeXYDispIndex:
	db $84,$86
	db $88,$8A
	db $8C,$8E
	db $90,$90
	db $92,$94
	db $96,$98
	db $9A,$9C
	db $9E,$A0
	db $A2,$A4
	db $A6,$A8
	db $AA,$B0
	db $B6,$BC
	db $C2,$C8
	db $CE,$D4
	db $DA,$DE
	db $E2,$E2

; Cape tile map
CapeTilePointerIndex:
	db $0A,$0A,$84,$0A,$88,$88,$88,$88
	db $8A,$8A,$8A,$8A,$44,$44,$44,$44
	db $42,$42,$42,$42,$40,$40,$40,$40
	db $22,$22,$22,$22,$A4,$A4,$A4,$A4
	db $A6,$A6,$A6,$A6,$86,$86,$86,$86
	db $6E,$6E,$6E,$6E

; cape offsets
DATA_00E266:
	db $02,$02,$02,$0C,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$04,$12,$04,$04
	db $04,$12,$04,$04,$04,$12,$04,$04
	db $04,$12,$04,$04

; Table used to determine when to draw Mario while he is flashing (when
; being hurt). It's set up so Mario will blink faster as the invulnerability
; timer gets closer to 0. Indexed by $1497 divided by 8, it determines how
; frequently Mario will be drawn on screen (lower values = more frequently),
; but in some situations he will be drawn nonetheless (specifically, when
; $9D or $13FB are set). The values in the table should all be powers of 2.
DATA_00E292:
	db $01,$01,$01,$01,$02,$02,$02,$02
	db $04,$04,$04,$04,$08,$08,$08,$08

; Table of 16-bit pointers to the player palettes for each powerup,
; alternating between Mario and Luigi's palette in the order of $19.
PalettePointers:
	dw SMW_GlobalPalettes_Mario,SMW_GlobalPalettes_Luigi,SMW_GlobalPalettes_Mario,SMW_GlobalPalettes_Luigi
	dw SMW_GlobalPalettes_Mario,SMW_GlobalPalettes_Luigi,SMW_GlobalPalettes_MarioFire,SMW_GlobalPalettes_LuigiFire

PlayerStartingOAMIndex:
	db $10			; Normal
	db $D4			; Behind climbing Net
	db $10			; Enter/exit pipe
	db $E8			; Overworld Border/Mode 7 room

CapeStartingOAMIndex:
	db $08			; Normal
	db $CC			; Behind climbing Net
	db $08			; Enter/exit pipe
	db $E0			; Overworld Border/Mode 7 room

TilePriority:
				; Normal (controlled by !RAM_SMW_Sprites_TilePriority)
	db $10			; Behind climbing Net
	db $10			; Enter/exit pipe
	db $30			; Overworld Border/Mode 7 room

Main:
if defined("Define_SMW_SA1")
	JML.l level_mode_optimize_00E2BD
	db $78	; the tail of the LDA.b below, which the hijack leaves unreached
else
	PHB				;\
	PHK				;|start of a routine?
	PLB				;/
	LDA.b !RAM_SMW_Player_HidePlayerTileFlags	;\
endif
	CMP.b #$FF			;| If mario is completely
	BEQ.b CODE_00E2CA		;/ disappeared
	JSL.l CODE_01EA70
CODE_00E2CA:
	LDY.w !RAM_SMW_Timer_PlayerPaletteCycle	;\ if flashing palette timer is not 00, go
	BNE.b CODE_00E308		;/
	LDY.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario doesn't have star
#Debug_InfiniteStar:
	BEQ.b CODE_00E314
	LDA.b !RAM_SMW_Player_HidePlayerTileFlags	;\
	CMP.b #$FF			;| if mario is completely disappeared NOW, don't decrement star counter
	BEQ.b CODE_00E2E3		;/
	LDA.b !RAM_SMW_Counter_LocalFrames	;\
	AND.b #$03			;| quite often, don't decrement the star counter
	BNE.b CODE_00E2E3		;/
	DEC.w !RAM_SMW_Timer_StarPower	; Decrease star timer
CODE_00E2E3:
	LDA.b !RAM_SMW_Counter_GlobalFrames	; A = Frame counter
if ver_is_pal(!Define_Global_ROMToAssemble)
	CPY.b #$18
else
	CPY.b #$1E
endif
	BCC.b CODE_00E30A
	BNE.b CODE_00E30C		; If it's simply still running, go to palette handler
	LDA.w !RAM_SMW_Misc_MusicRegisterBackup	;\
	CMP.b #$FF			;| if no music is playing (?)
	BEQ.b CODE_00E308		;/
	AND.b #$7F			;| otherwise set the music to certain values (check later?)
	STA.w !RAM_SMW_Misc_MusicRegisterBackup
	TAX				; the new 0DDA = A
	LDA.w !RAM_SMW_Timer_BluePSwitch	;\
	ORA.w !RAM_SMW_Timer_SilverPSwitch	;| if POW timers and dicrectional coin timers are all 00,
	ORA.w !RAM_SMW_NorSpr045_DirectionalCoins_DespawnTimer	;| Make music Whatever 0DDA is
	BEQ.b CODE_00E305		;/
	LDX.b #!Define_SMW_LevelMusic_DirectCoins	; Otherwise, Music = Directional coins
CODE_00E305:
	STX.w !RAM_SMW_IO_MusicCh1	; / Change music
CODE_00E308:
	LDA.b !RAM_SMW_Counter_GlobalFrames
CODE_00E30A:
	LSR
	LSR
CODE_00E30C:
	AND.b #$03
	INC
	INC
	INC
	INC
	BRA.b CODE_00E31A

CODE_00E314:
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	ASL
	ORA.w !RAM_SMW_Player_CurrentCharacter
CODE_00E31A:
	ASL
	TAY
	REP.b #$20			; A->16
	LDA.w PalettePointers,y		;\ set the palette
	STA.w !RAM_SMW_Pointer_PlayerPaletteLo	;/
	SEP.b #$20			; A->8
	LDX.w !RAM_SMW_Player_CurrentPose	; Probably init X
	LDA.b #$05			;\
	CMP.w !RAM_SMW_Player_WallWalkStatus	;| if mario is coming up the right wall,
	BCS.b CODE_00E33E		;/
	LDA.w !RAM_SMW_Player_WallWalkStatus	;\ ;;;;;;;;;;;;;;GET PLAYER'S Y-POSITON, ETC;;;;;;;;;;;;;;;;;;;;;;
	LDY.b !RAM_SMW_Player_CurrentPowerUp	;| if not wall-walking, don't worry about mario's frame being 13
	BEQ.b CODE_00E33B		;/
	CPX.b #$13			;\ if mario's frame = 13,
	BNE.b CODE_00E33D		;/ do not invert bit 1
CODE_00E33B:
	EOR.b #$01
CODE_00E33D:
	LSR
CODE_00E33E:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo	;\
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_Player_OnScreenPosXLo	;/ and with this, we have mario's X screen position.
	LDA.w !RAM_SMW_Player_RelativeYPositionDuringScreenShake	;\
	AND.w #$00FF			;| inverting something that has to do with the Ypos, high byte
	CLC				;| and then adding the regular Ypos to it.
	ADC.b !RAM_SMW_Player_YPosLo	;/
	; Change to EA EA EA EA (NOP #4) and all forms of Big Mario will not go
	; into the ground a few pixels.
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	CPY.b #$01			;| If mario's powerup is firey or caped,
	LDY.b #$01			;| do not dec A/Y
	BCS.b CODE_00E359
	DEC				;|\ adjust for small mario disposition
	DEY
CODE_00E359:
	CPX.b #$0A			;| if frame is 0A
	BCS.b CODE_00E360		;| don't subtract the screen boundaries
	; Change to $EA,$EA,$EA (NOP #3) to cancel out Mario moving up and down one
	; pixel while walking and running. This is useful if you are using more
	; than three animation frames for walking/running, and thus can be worked
	; into your GFX/tilemap accordingly.
	CPY.w !RAM_SMW_Player_WalkingFrame	; Could have something to do with the extra bits of the positions?
CODE_00E360:
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CPX.b #$1C			;| if frame is 1C
	; Change to $80 (BRA) to disable Mario from being offset vertically by one
	; pixel while running on the wall (using the purple triangles). This should
	; be combined with $00E34F and $00E35D for the complete effect.
	BNE.b CODE_00E369		;/ don't add 1
	ADC.w #$0001			; +1, with the carry.
CODE_00E369:
	STA.b !RAM_SMW_Player_OnScreenPosYLo	;/ store to Ypos.
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Timer_PlayerHurt	;\ if not flashing invincible,
	BEQ.b CODE_00E385		;/
	LSR				;\
	LSR				;|Y = Flashing invincible timer, but "shrunk"
	LSR				;|
	TAY				;/
	LDA.w DATA_00E292,y		;\
	AND.w !RAM_SMW_Timer_PlayerHurt	;| every now and then for the flashing invincible timer, branch to
	ORA.b !RAM_SMW_Flag_SpritesLocked	;| adding in sprites locked, and if mario is frozen.
	ORA.w !RAM_SMW_Player_FreezePlayerFlag	;|
	BNE.b CODE_00E385		;/
	PLB				;\
	RTL				;/Return

; Mario GFX routine. $00E3AA controls which poses for $13E0 depend on
; Mario's powerup state. Pose IDs below this value may differ for each
; powerup while those above are shared (default: 3D). $00E3FE defines the
; powerup that draws Mario's cape (default: 02). Setting $00E400 to 00 will
; allow it to be displayed in any powerup state (including small Mario).
CODE_00E385:
	LDA.b #$C8
	CPX.b #$43
	BNE.b CODE_00E38D
	LDA.b #$E8
CODE_00E38D:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	CPX.b #$29			;\
	BNE.b CODE_00E399		;/ if frame is 29, don't check if mario is small or not and such
	LDA.b !RAM_SMW_Player_CurrentPowerUp	;\
	BNE.b CODE_00E399		;| if powerup is not small, do not make X 20
	LDX.b #$20			;/
CODE_00E399:
	LDA.w PlayerXYDispIndexIndex,x	;\
	ORA.b !RAM_SMW_Player_FacingDirection	;| now we have the (frame?) to show in Y
	TAY				;/
	LDA.w PlayerXYDispIndex,y	;\ Something indexed by the frame in $05
	STA.b !RAM_SMW_Misc_ScratchRAM05	;/
	LDY.b !RAM_SMW_Player_CurrentPowerUp	; Y = powerup
	LDA.w !RAM_SMW_Player_CurrentPose	;\
	CMP.b #$3D			;| if mario's frame is 3D and up, do not add the tileset index + powerup
	BCS.b CODE_00E3B0		;|
	ADC.w PowerupTilesetIndex,y	;/
CODE_00E3B0:
	TAY				; Frame = Y, perhaps Tileset+Frame = Y
	LDA.w TilesIndex,y		;\ tile exspansion+ frame is $06
	STA.b !RAM_SMW_Misc_ScratchRAM06	;/
	LDA.w HeadTilePointerIndex,y	;\ some table...? is $0A
	STA.b !RAM_SMW_Misc_ScratchRAM0A	;/
	LDA.w BodyTilePointerIndex,y	;\ some large table..? is $0B
	STA.b !RAM_SMW_Misc_ScratchRAM0B	;/
	LDA.b !RAM_SMW_Sprites_TilePriority	;\ load mario properties?
	LDX.w !RAM_SMW_Player_CurrentLayerPriority	;| if properties = 0, do not make A = A table plus the behind scenery flag
	BEQ.b CODE_00E3CA		;/
	LDA.w TilePriority-$01,x
CODE_00E3CA:
	LDY.w PlayerStartingOAMIndex,x	;\
	LDX.b !RAM_SMW_Player_FacingDirection	;|
	ORA.w TileXFlip,x		;|
	STA.w SMW_OAMBuffer[$40].Prop,y	;|
	STA.w SMW_OAMBuffer[$41].Prop,y	;|
	STA.w SMW_OAMBuffer[$43].Prop,y	;|
	STA.w SMW_OAMBuffer[$44].Prop,y	;| Handling parts of Mario's OAM
	STA.w SMW_OAMBuffer[$3E].Prop,y	;|
	STA.w SMW_OAMBuffer[$3F].Prop,y	;/
	LDX.b !RAM_SMW_Misc_ScratchRAM04	;\ If E8 (if frame is not 43,) is $04, do not EOR with #$40
	CPX.b #$E8			;|
	BNE.b CODE_00E3EC		;/
	EOR.b #$40
CODE_00E3EC:
	STA.w SMW_OAMBuffer[$42].Prop,y	;\
	JSR.w CODE_00E45D		;|
	JSR.w CODE_00E45D		;| more OAM stuff
	JSR.w CODE_00E45D		;|
	JSR.w CODE_00E45D		;/
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	CMP.b #$02
	BNE.b CODE_00E458
	PHY
	LDA.b #$2C
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDX.w !RAM_SMW_Player_CurrentPose
	LDA.w DATA_00E18E,x
	TAX
	LDA.w DATA_00E1D4+$03,x
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.w DATA_00E1D4+$04,x
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w DATA_00E1D4+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	CMP.b #$04
	BCS.b CODE_00E432
	LDA.w !RAM_SMW_Player_CapeImage
	ASL
	ASL
	ORA.b !RAM_SMW_Misc_ScratchRAM0C
	TAY
	LDA.w CapeTilePointerIndex,y
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.w DATA_00E266,y
	BRA.b CODE_00E435

CODE_00E432:
	LDA.w DATA_00E1D4+$02,x
CODE_00E435:
	ORA.b !RAM_SMW_Player_FacingDirection
	TAY
	LDA.w CapeXYDispIndex,y
	STA.b !RAM_SMW_Misc_ScratchRAM05
	PLY
	LDA.w DATA_00E1D4,x
	TSB.b !RAM_SMW_Player_HidePlayerTileFlags
	BMI.b CODE_00E448
	JSR.w CODE_00E45D
CODE_00E448:
	LDX.w !RAM_SMW_Player_CurrentLayerPriority
	LDY.w CapeStartingOAMIndex,x
	JSR.w CODE_00E45D
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	STA.b !RAM_SMW_Misc_ScratchRAM06
	JSR.w CODE_00E45D
CODE_00E458:
	JSR.w CODE_00F636
	PLB
	RTL

CODE_00E45D:
	LSR.b !RAM_SMW_Player_HidePlayerTileFlags
	BCS.b CODE_00E49F
	LDX.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w Tiles,x
	BMI.b CODE_00E49F
	STA.w SMW_OAMBuffer[$40].Tile,y
	LDX.b !RAM_SMW_Misc_ScratchRAM05
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	CLC
	ADC.w YDisp,x
	PHA
	CLC
	ADC.w #$0010
	CMP.w #$0100
	PLA
	SEP.b #$20			; A->8
	BCS.b CODE_00E49F
	STA.w SMW_OAMBuffer[$40].YDisp,y
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_OnScreenPosXLo
	CLC
	ADC.w XDisp,x
	PHA
	CLC
	ADC.w #$0080
	CMP.w #$0200
	PLA
	SEP.b #$20			; A->8
	BCS.b CODE_00E49F
	STA.w SMW_OAMBuffer[$40].XDisp,y
	XBA
	LSR
CODE_00E49F:
	PHP
	TYA
	LSR
	LSR
	TAX
	ASL.b !RAM_SMW_Misc_ScratchRAM04
	ROL
	PLP
	ROL
	AND.b #$03
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,x
	INY
	INY
	INY
	INY
	INC.b !RAM_SMW_Misc_ScratchRAM05
	INC.b !RAM_SMW_Misc_ScratchRAM05
	INC.b !RAM_SMW_Misc_ScratchRAM06
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_PlayerGFXRt(Address)
namespace SMW_PlayerGFXRt
%InsertMacroAtXPosition(<Address>)

CODE_00F636:
	REP.b #$20			; A->16
	LDX.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM0A-$01
	ORA.w #$0800
	CMP.b !RAM_SMW_Misc_ScratchRAM0A-$01
	BEQ.b CODE_00F644
	CLC
CODE_00F644:
	AND.w #$F700
	ROR
	LSR
	ADC.w #!RAM_SMW_Graphics_DecompressedGFX32
	STA.w SMW_DynamicSpritePointersTop[$00].LowByte
	CLC
	ADC.w #$0200
	STA.w SMW_DynamicSpritePointersBottom[$00].LowByte
	LDX.b #$00
	LDA.b !RAM_SMW_Misc_ScratchRAM0B-$01
	ORA.w #$0800
	CMP.b !RAM_SMW_Misc_ScratchRAM0B-$01
	BEQ.b CODE_00F662
	CLC
CODE_00F662:
	AND.w #$F700
	ROR
	LSR
	ADC.w #!RAM_SMW_Graphics_DecompressedGFX32
	STA.w SMW_DynamicSpritePointersTop[$01].LowByte
	CLC
	ADC.w #$0200
	STA.w SMW_DynamicSpritePointersBottom[$01].LowByte
	LDA.b !RAM_SMW_Misc_ScratchRAM0C-$01
	AND.w #$FF00
	LSR
	LSR
	LSR
	ADC.w #!RAM_SMW_Graphics_DecompressedGFX32
	STA.w SMW_DynamicSpritePointersTop[$02].LowByte
	CLC
	ADC.w #$0200
	STA.w SMW_DynamicSpritePointersBottom[$02].LowByte
	LDA.b !RAM_SMW_Misc_ScratchRAM0D-$01
	AND.w #$FF00
	LSR
	LSR
	LSR
	ADC.w #!RAM_SMW_Graphics_DecompressedGFX32
	STA.w !RAM_SMW_Graphics_DynamicSpriteTile7FLo
	SEP.b #$20			; A->8
	LDA.b #$0A
	STA.w !RAM_SMW_Player_NumberOfTilesToUpdate
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandlePlayerPhysics(Address)
namespace SMW_HandlePlayerPhysics
%InsertMacroAtXPosition(<Address>)

; Mario's jump height. The earlier ones are when Mario is moving slowly (or
; standing still); the latter is when he's moving faster. Even entries are
; normal jump, odd are spin.
JumpHeightTable:		; Glitch: X speeds in the 40-C0 range will use garbage Y speed values.
	db $B0,$B6		; X Speed 00-07/FF-F9
	db $AE,$B4		; X Speed 08-0F/F8-F1
	db $AB,$B2		; X Speed 10-17/F0-E9
	db $A9,$B0		; X Speed 18-1F/E8-E1
	db $A6,$AE		; X Speed 20-27/E0-D9
	db $A4,$AB		; X Speed 28-2F/D8-D1
	db $A1,$A9		; X Speed 30-37/D0-C9
	db $9F,$A6		; X Speed 38-3F/C8-C1

if ver_is_pal(!Define_Global_ROMToAssemble)
DATA_00D2CD:
	dw $FEC0,$0140,$FEC0,$0140
	dw $FEC0,$0140,$FE20,$00F0
	dw $FF10,$01E0,$FD80,$0050
	dw $FFB0,$0280,$FD80,$0050
	dw $FD80,$0050,$FFB0,$0280
	dw $FFB0,$0280,$FB00,$FEC0
	dw $0140,$0500,$FEC0,$0140
	dw $FEC0,$0140

DATA_00D309:
	dw $FFD8,$0028,$FFD8,$0028
	dw $FFD8,$0028,$FFB0,$0028
	dw $FFD8,$0050,$FF60,$0028
	dw $FFD8,$00A0,$FF60,$0028
	dw $FF60,$0028,$FFD8,$00A0
	dw $FFD8,$00A0,$FD80,$FF60
	dw $00A0,$0280,$FEC0,$0140
	dw $FEC0,$0140

MarioAccel:
	db $20,$FE,$20,$FE,$E0,$01,$E0,$01
	db $20,$FE,$20,$FE,$E0,$01,$E0,$01
	db $20,$FE,$20,$FE,$E0,$01,$E0,$01
	db $20,$FE,$20,$FE,$90,$01,$90,$01
	db $70,$FE,$70,$FE,$E0,$01,$E0,$01
	db $20,$FE,$20,$FE,$40,$01,$40,$01
	db $C0,$FE,$C0,$FE,$E0,$01,$E0,$01
	db $20,$FE,$20,$FE,$40,$01,$40,$01
	db $20,$FE,$20,$FE,$40,$01,$40,$01
	db $C0,$FE,$C0,$FE,$E0,$01,$E0,$01
	db $C0,$FE,$C0,$FE,$E0,$01,$E0,$01
	db $00,$FB,$00,$FB,$40,$FC,$40,$FC
	db $C0,$03,$C0,$03,$00,$05,$00,$05
	db $00,$FB,$00,$FB,$80,$07,$80,$07
	db $80,$F8,$80,$F8,$00,$05,$00,$05
	db $60,$FF,$A0,$00,$C0,$FE,$40,$01
	db $20,$FE,$E0,$01,$20,$FE,$20,$FE
	db $E0,$01,$E0,$01,$20,$FE,$20,$03
	db $E0,$FC,$C0,$F9,$20,$03,$40,$06
	db $E0,$FC,$C0,$F9,$20,$03,$40,$06
	db $E0,$FC,$C0,$F9,$20,$03,$40,$06
	db $90,$FC,$20,$F9,$D0,$02,$A0,$05
	db $C0,$FD,$20,$F9,$70,$03,$E0,$06
	db $40,$FC,$80,$F8,$80,$02,$00,$05
	db $80,$FD,$00,$FB,$C0,$03,$80,$07
	db $40,$FC,$80,$F8,$80,$02,$00,$05
	db $40,$FC,$80,$F8,$80,$02,$00,$05
	db $80,$FD,$00,$FB,$C0,$03,$80,$07
	db $80,$FD,$00,$FB,$C0,$03,$80,$07
	db $40,$FC,$80,$F8,$40,$FC,$80,$F8
	db $C0,$03,$80,$07,$C0,$03,$80,$07

DATA_00D43D:
	db $60,$FF,$20,$FE,$A0,$00,$E0,$01
	db $60,$FF,$20,$FE,$A0,$00,$E0,$01
	db $60,$FF,$20,$FE,$A0,$00,$E0,$01
	db $20,$FE,$20,$FE,$A0,$00,$90,$01
	db $60,$FF,$70,$FE,$E0,$01,$E0,$01
	db $20,$FE,$20,$FE,$A0,$00,$40,$01
	db $60,$FF,$C0,$FE,$E0,$01,$E0,$01
	db $20,$FE,$20,$FE,$A0,$00,$40,$01
	db $20,$FE,$20,$FE,$A0,$00,$40,$01
	db $60,$FF,$C0,$FE,$E0,$01,$E0,$01
	db $60,$FF,$C0,$FE,$E0,$01,$E0,$01
	db $00,$FB,$00,$FB,$80,$FD,$40,$FC
	db $C0,$03,$C0,$03,$00,$05,$00,$05
	db $00,$FB,$00,$FB,$A0,$00,$A0,$00
	db $60,$FF,$60,$FF,$00,$05,$00,$05
	db $60,$FF,$A0,$00,$C0,$FE,$40,$01
	db $20,$FE,$E0,$01,$20,$FE,$20,$FE
	db $E0,$01,$E0,$01,$20,$FE,$20,$03
	db $B0,$FF,$E0,$FC,$50,$00,$20,$03
	db $B0,$FF,$E0,$FC,$50,$00,$20,$03
	db $B0,$FF,$E0,$FC,$50,$00,$20,$03
	db $60,$FF,$90,$FC,$50,$00,$D0,$02
	db $B0,$FF,$30,$FD,$A0,$00,$70,$03
	db $40,$FC,$40,$FC,$50,$00,$80,$02
	db $B0,$FF,$80,$FD,$C0,$03,$C0,$03
	db $40,$FC,$40,$FC,$50,$00,$80,$02
	db $40,$FC,$40,$FC,$50,$00,$80,$02
	db $B0,$FF,$80,$FD,$C0,$03,$C0,$03
	db $B0,$FF,$80,$FD,$C0,$03,$C0,$03
	db $40,$FC,$40,$FC,$40,$FC,$40,$FC
	db $C0,$03,$C0,$03,$C0,$03,$C0,$03

DATA_00D535:
	db $E7,$19,$D3,$2D,$D3,$2D,$C4,$3C
	db $E7,$19,$D3,$2D,$D3,$2D,$C4,$3C
	db $E7,$19,$D3,$2D,$D3,$2D,$C4,$3C
	db $E2,$16,$D3,$28,$D3,$28,$C4,$38
	db $EA,$1E,$D8,$2D,$D8,$2D,$C8,$3C
	db $D3,$14,$D3,$23,$D3,$23,$C4,$34
	db $EC,$2D,$DD,$2D,$DD,$2D,$CC,$3C
	db $D3,$14,$D3,$23,$D3,$23,$C4,$34
	db $D3,$14,$D3,$23,$D3,$23,$C4,$34
	db $EC,$2D,$DD,$2D,$DD,$2D,$CC,$3C
	db $EC,$2D,$DD,$2D,$DD,$2D,$CC,$3C
	db $D3,$EC,$D3,$F6,$D3,$F6,$C4,$FC
	db $14,$2D,$0A,$2D,$0A,$2D,$05,$3C
	db $C4,$0A,$C4,$0A,$C4,$0A,$C4,$0A
	db $F6,$3C,$F6,$3C,$F6,$3C,$F6,$3C
	db $F6,$0A,$EC,$14,$F1,$05,$E2,$0A
	db $EC,$14,$D8,$28,$E7,$0F,$CE,$1E
	db $CE,$32,$C9,$37,$C4,$3C,$C4,$C4
	db $3C,$3C,$D8,$28

DATA_00D5C9:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$EC,$00,$14,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$D8
	db $00,$28,$00,$00,$00,$00,$00,$EC
	db $00,$F6
else
; Player deceleration table for each type of slope, in the order of $13E1.
; This table contains two 16-bit values for each slope type to
; accelerate/decelerate the player towards the slope's base speed (see
; $00D5C9). The first value is used when the X speed is above the slope's
; base speed (so decrease the player's X speed) while the second is used
; when below the slope's base speed (so increase it). The first two entries
; of this table (for flat ground) are also used when Mario is swimming as
; well. Additionally, they get used when the player is not on the ground,
; but is above their maximum X speed and left/right is being held. When on
; the ground in a slippery level, the table at $00D309 is used instead.
DATA_00D2CD:
	dw $FF00,$0100,$FF00,$0100	;!
	dw $FF00,$0100,$FE80,$00C0	;!
	dw $FF40,$0180,$FE00,$0040	;!
	dw $FFC0,$0200,$FE00,$0040	;!
	dw $FE00,$0040,$FFC0,$0200	;!
	dw $FFC0,$0200,$FC00,$FF00	;!
	dw $0100,$0400,$FF00,$0100	;!
	dw $FF00,$0100			;!

; Player deceleration table in slippery levels for each type of slope. For
; more details on its format, see its non-slippery variant at $00D2CD.
DATA_00D309:
	dw $FFE0,$0020,$FFE0,$0020	;!
	dw $FFE0,$0020,$FFC0,$0020	;!
	dw $FFE0,$0040,$FF80,$0020	;!
	dw $FFE0,$0080,$FF80,$0020	;!
	dw $FF80,$0020,$FFE0,$0080	;!
	dw $FFE0,$0080,$FE00,$FF80	;!
	dw $0080,$0200,$FF00,$0100	;!
	dw $FF00,$0100			;!

; Accelerations for Mario in a non-slippery level, or in a slippery level
; while in midair. The table is split into sets of four 16-bit values each,
; in the order of $13E1. The values in these sets are ordered as: walking
; (no X/Y) left, running (X/Y held) left, walking right, running right.
MarioAccel:
	db $80,$FE,$80,$FE,$80,$01,$80,$01	;!
	db $80,$FE,$80,$FE,$80,$01,$80,$01	;!
	db $80,$FE,$80,$FE,$80,$01,$80,$01	;!
	db $80,$FE,$80,$FE,$40,$01,$40,$01	;!
	db $C0,$FE,$C0,$FE,$80,$01,$80,$01	;!
	db $80,$FE,$80,$FE,$00,$01,$00,$01	;!
	db $00,$FF,$00,$FF,$80,$01,$80,$01	;!
	db $80,$FE,$80,$FE,$00,$01,$00,$01	;!
	db $80,$FE,$80,$FE,$00,$01,$00,$01	;!
	db $00,$FF,$00,$FF,$80,$01,$80,$01	;!
	db $00,$FF,$00,$FF,$80,$01,$80,$01	;!
	db $00,$FC,$00,$FC,$00,$FD,$00,$FD	;!
	db $00,$03,$00,$03,$00,$04,$00,$04	;!
	; Accelerations for Mario when flying. Consists of 16-bit values in two
	; sets (facing left/right) of two groups (moving left/right) with two
	; values each (no X/Y and X/Y held).
	db $00,$FC,$00,$FC,$00,$06,$00,$06	;!
	db $00,$FA,$00,$FA,$00,$04,$00,$04	;!
	; Sliding accelerations on slopes in a non-slippery level. Each value is
	; 16-bit, in the same order as $13E1 (excluding flat ground).
	db $80,$FF,$80,$00,$00,$FF,$00,$01	;!
	db $80,$FE,$80,$01,$80,$FE,$80,$FE	;!
	db $80,$01,$80,$01,$80,$FE,$80,$02	;!
	; Turning decelerations for Mario in a non-slippery level, or in a slippery
	; level while in midair. The table is split into sets of four 16-bit values
	; each, in the order of $13E1. The values in these sets are ordered as:
	; walking (no X/Y) left, running (X/Y held) left, walking right, running
	; right.
	db $80,$FD,$00,$FB,$80,$02,$00,$05	;!
	db $80,$FD,$00,$FB,$80,$02,$00,$05	;!
	db $80,$FD,$00,$FB,$80,$02,$00,$05	;!
	db $40,$FD,$80,$FA,$40,$02,$80,$04	;!
	db $C0,$FD,$80,$FB,$C0,$02,$80,$05	;!
	db $00,$FD,$00,$FA,$00,$02,$00,$04	;!
	db $00,$FE,$00,$FC,$00,$03,$00,$06	;!
	db $00,$FD,$00,$FA,$00,$02,$00,$04	;!
	db $00,$FD,$00,$FA,$00,$02,$00,$04	;!
	db $00,$FE,$00,$FC,$00,$03,$00,$06	;!
	db $00,$FE,$00,$FC,$00,$03,$00,$06	;!
	db $00,$FD,$00,$FA,$00,$FD,$00,$FA	;!
	db $00,$03,$00,$06,$00,$03,$00,$06	;!

; Accelerations for Mario in a slippery level. The table is split into sets
; of four 16-bit values, in the order of $13E1. The values in these sets are
; ordered as: walking (no X/Y) left, running (X/Y held) left, walking right,
; running right.
DATA_00D43D:
	db $80,$FF,$80,$FE,$80,$00,$80,$01	;!
	db $80,$FF,$80,$FE,$80,$00,$80,$01	;!
	db $80,$FF,$80,$FE,$80,$00,$80,$01	;!
	db $80,$FE,$80,$FE,$80,$00,$40,$01	;!
	db $80,$FF,$C0,$FE,$80,$01,$80,$01	;!
	db $80,$FE,$80,$FE,$80,$00,$00,$01	;!
	db $80,$FF,$00,$FF,$80,$01,$80,$01	;!
	db $80,$FE,$80,$FE,$80,$00,$00,$01	;!
	db $80,$FE,$80,$FE,$80,$00,$00,$01	;!
	db $80,$FF,$00,$FF,$80,$01,$80,$01	;!
	db $80,$FF,$00,$FF,$80,$01,$80,$01	;!
	db $00,$FC,$00,$FC,$00,$FE,$00,$FD	;!
	db $00,$03,$00,$03,$00,$04,$00,$04	;!
	db $00,$FC,$00,$FC,$80,$00,$80,$00	;!
	db $80,$FF,$80,$FF,$00,$04,$00,$04	;!
	; Sliding accelerations on slopes in a slippery level. Each value is
	; 16-bit, in the same order as $13E1 (excluding flat ground).
	db $80,$FF,$80,$00,$00,$FF,$00,$01	;!
	db $80,$FE,$80,$01,$80,$FE,$80,$FE	;!
	db $80,$01,$80,$01,$80,$FE,$80,$02	;!
	; Turning decelerations for Mario in a slippery level. The table is split
	; into sets of four 16-bit values, in the order of $13E1. The values in
	; these sets are ordered as: walking (no X/Y) left, running (X/Y held)
	; left, walking right, running right.
	db $C0,$FF,$80,$FD,$40,$00,$80,$02	;!
	db $C0,$FF,$80,$FD,$40,$00,$80,$02	;!
	db $C0,$FF,$80,$FD,$40,$00,$80,$02	;!
	db $80,$FF,$40,$FD,$40,$00,$40,$02	;!
	db $C0,$FF,$C0,$FD,$80,$00,$C0,$02	;!
	db $00,$FD,$00,$FD,$40,$00,$00,$02	;!
	db $C0,$FF,$00,$FE,$00,$03,$00,$03	;!
	db $00,$FD,$00,$FD,$40,$00,$00,$02	;!
	db $00,$FD,$00,$FD,$40,$00,$00,$02	;!
	db $C0,$FF,$00,$FE,$00,$03,$00,$03	;!
	db $C0,$FF,$00,$FE,$00,$03,$00,$03	;!
	db $00,$FD,$00,$FD,$00,$FD,$00,$FD	;!
	db $00,$03,$00,$03,$00,$03,$00,$03	;!

; Mario's maximum X speeds on flat ground and on slopes. The table consists
; of sets of 8 bytes, in the order of $13E1. Each of these sets then
; consists of four groups of two bytes each (for max left and max right), in
; the order: walking, running, running fast, sprinting. The "running fast"
; values get used when running faster than #$23 (defined at $00D723) and
; either on the ground or shot out of a diagonal pipe.
DATA_00D535:
	db $EC,$14,$DC,$24,$DC,$24,$D0,$30	;!
	db $EC,$14,$DC,$24,$DC,$24,$D0,$30	;!
	db $EC,$14,$DC,$24,$DC,$24,$D0,$30	;!
	db $E8,$12,$DC,$20,$DC,$20,$D0,$2C	;!
	db $EE,$18,$E0,$24,$E0,$24,$D4,$30	;!
	db $DC,$10,$DC,$1C,$DC,$1C,$D0,$28	;!
	db $F0,$24,$E4,$24,$E4,$24,$D8,$30	;!
	db $DC,$10,$DC,$1C,$DC,$1C,$D0,$28	;!
	db $DC,$10,$DC,$1C,$DC,$1C,$D0,$28	;!
	db $F0,$24,$E4,$24,$E4,$24,$D8,$30	;!
	db $F0,$24,$E4,$24,$E4,$24,$D8,$30	;!
	db $DC,$F0,$DC,$F8,$DC,$F8,$D0,$FC	;!
	db $10,$24,$08,$24,$08,$24,$04,$30	;!
	; Mario's maximum X speeds while flying. The first 8 bytes are facing
	; right, the second 8 are facing left. Each of these sets are split into
	; four groups of two bytes each (for maximum left and right speeds). Only
	; the first two groups are actually used, for flying without X/Y and flying
	; with X/Y respectively. Also, in case it's not clear, the maximum speeds
	; in the direction opposite of Mario's are from pressing that direction
	; with B to slow down (e.g. <+B when facing right).
	db $D0,$08,$D0,$08,$D0,$08,$D0,$08	;!
	db $F8,$30,$F8,$30,$F8,$30,$F8,$30	;!
	; Mario's maximum X speeds in water. The first set of 8 bytes is for when
	; Mario isn't carrying an item, while the second set is with one. Each set
	; consists of four groups of two bytes each (for max left and max right),
	; in the order: on ground, swimming, on ground in a tide, swimming in a
	; tide.
	db $F8,$08,$F0,$10,$F4,$04,$E8,$08	;!
	db $F0,$10,$E0,$20,$EC,$0C,$D8,$18	;!
	; Mario's maximum X speeds when sliding down slopes with the down button.
	; In the order of $13E1, without flat ground or flying included.
	db $D8,$28,$D4,$2C,$D0,$30,$D0,$D0	;!
	db $30,$30,$E0,$20		;!

; Base X speeds (16-bit) for the player when standing on each type of slope,
; in the order of $13E1. When the player is standing on a slope without
; holding left or right, the game will accelerate/decelerate them towards
; the slope's corresponding value here. See $00D2CD for corresponding
; acceleration speeds.
DATA_00D5C9:
	db $00,$00,$00,$00,$00,$00,$00,$00	;!
	db $00,$00,$00,$F0,$00,$10,$00,$00	;!
	db $00,$00,$00,$00,$00,$00,$00,$E0	;!
	db $00,$20,$00,$00,$00,$00,$00,$F0	;!
	; Value added to the player's X speed as they're in water and on the ground
	; in a level where a Layer 3 tide is active. The value is 16-bit, with the
	; high byte corresponding to Mario's regular X speed ($7B), and the low
	; byte corresponding to the accumulating fraction bits ($7A).
	db $00,$F8			;!
endif

DATA_00D5EB:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	db $FF,$FF,$03
else
	db $FF,$FF,$02			;!
endif

DATA_00D5EE:
	db $68,$70

DATA_00D5F0:
	db $1C,$0C

Main:
	LDA.b !RAM_SMW_Player_InAirFlag	;\ if mario is not flying, continue on your way
	BEQ.b CODE_00D5F9		;/
	JMP.w CODE_00D682		; go

CODE_00D5F9:
	STZ.b !RAM_SMW_Player_DuckingFlag	; Mario isn't ducking anymore
	LDA.w !RAM_SMW_Player_SlidingOnGround	;\ if mario is sliding and such, don't check him to start sliding
	BNE.b CODE_00D60B		;/
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #!Joypad_DPadD>>8
	; Change from F0 (BEQ) to 80 (BRA) to disable ducking. Note that setting
	; $01EB16 to [EA EA A5 73] (NOP #2 : LDA $73) is a good idea if you're
	; using this.
	BEQ.b CODE_00D60B
	STA.b !RAM_SMW_Player_DuckingFlag	; Mario isn't ducking anymore
	STZ.w !RAM_SMW_Flag_CapeToSpriteInteraction	; Don't run interaction with cape
CODE_00D60B:
	LDA.w !RAM_SMW_Misc_PlayerOnSolidSprite	;\
	CMP.b #$02			;| if mario is on a sinking platform,
	BEQ.b CODE_00D61E		;/ don't check for being blocked and such
	LDA.b !RAM_SMW_Player_BlockedFlags	;\
	AND.b #$08			;| if blocked from above,
	BNE.b CODE_00D61E		;/ don't check
	LDA.b !RAM_SMW_IO_ControllerPress1
	ORA.b !RAM_SMW_IO_ControllerPress2
	; Change from 30 12 to EA EA to disable jumping.
	BMI.b PlayerIsJumping
CODE_00D61E:
	LDA.b !RAM_SMW_Player_DuckingFlag	;\ if not ducking, go to
	BEQ.b CODE_00D682		;/
	LDA.b !RAM_SMW_Player_XSpeed	;\ if mario is not moving Xwise,
	BEQ.b CODE_00D62D		;/ don't bother on checking if it's a slippery level
	LDA.b !RAM_SMW_Flag_IceLevel	;\ if it's slippery, don't JSR to next routine
	BNE.b CODE_00D62D		;/
	JSR.w SMW_SpawnPlayerTurnAroundSmoke_Main	; some routine..? handling sliding..?
CODE_00D62D:
	JMP.w CODE_00D764		; and move on

PlayerIsJumping:
	LDA.b !RAM_SMW_Player_XSpeed
	BPL.b CODE_00D637
	EOR.b #$FF
	INC
CODE_00D637:
	LSR
	LSR
	AND.b #$FE
	TAX
	LDA.b !RAM_SMW_IO_ControllerPress2
	; Change from 10 to 80 to disable Spin Jump.
	BPL.b CODE_00D65E
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2	;\ If mario is holding a object
	BNE.b CODE_00D65E		;/ Don't spinjump, go to jump routine
	; Change this from "1A" to "60" to disable spin jumping. Unlike 0583E (SNES
	; $00:D63E) from "10" to "80", changing this address does not make the "A"
	; button do the regular jump, but it disables spin jumping altogether. This
	; way, you can use the "A" button for something else without it jumping
	; automatically. Note: Still allows you to spinjump out of the water and
	; dismount Yoshi.
	INC				;\
	STA.w !RAM_SMW_Player_SpinJumpFlag	;/ Make mario spinjump if he's not holding a object+ A held
	LDA.b #!Define_SMW_Sound1DFC_SpinJump	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	LDY.b !RAM_SMW_Player_FacingDirection	;\
	LDA.w DATA_00D5F0,y		;| Handle spinjump fireball timer or something of that sort
	STA.w !RAM_SMW_Player_SpinjumpFireballTimer	;/
	LDA.w !RAM_SMW_Player_RidingYoshiFlag	;\ If mario is on yoshi handle that
	BNE.b CODE_00D682		;/
	INX				; +1
	BRA.b CODE_00D663		; Go to some routine save making a sound

; Mario jumping routine. (Sound effect + store to Mario Y speed.) $00D65F is
; the Sound effect for Mario jumping. $00D661 is the bank for the sound
; effect. By default it uses $1DFA, but you can make it use $1DFC by
; changing $00D661 to FC or $1DF9 by changing it to F9.
CODE_00D65E:
	LDA.b #!Define_SMW_Sound1DFA_Jump	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
CODE_00D663:
	LDA.w JumpHeightTable,x		;\ Oh look, the X speed determines the "gravity"
	STA.b !RAM_SMW_Player_YSpeed	;/
	LDA.b #$0B			; Sounds like a loop setup.
	LDY.w !RAM_SMW_Player_PMeter
	CPY.b #!Define_SMW_Physics_PMeterMax
	; Change to 80 to disable Cape Flight and Jumping High while dashing.
	; Interestingly enough, changing it to A9 will make Mario do a dash jump
	; with every jump, even at a standstill, and will allow him to gain speed
	; in the air. In addition, doing so will have the effect of causing every
	; Jump performed by Cape Mario to become a Cape Flight.
	BCC.b CODE_00D67D
	LDA.w !RAM_SMW_Timer_WaitBeforeCapeFlightBegins
	; [D0] Change to 80 to prevent the player from flying with a cape. The
	; player will still be able to float, cape-spin, and jump higher when
	; running but will never "take off".
	BNE.b CODE_00D67B
	LDA.b #$50			;\ Set screen scrolling to be allowed for x50
	STA.w !RAM_SMW_Timer_WaitBeforeCapeFlightBegins	;/
CODE_00D67B:
	LDA.b #$0C
CODE_00D67D:
	STA.b !RAM_SMW_Player_InAirFlag
	STZ.w !RAM_SMW_Player_SlidingOnGround	; Mario isn't sliding anymore
CODE_00D682:
	LDA.w !RAM_SMW_Player_SlidingOnGround	;\
	BMI.b CODE_00D692		;/ If not sliding continue on with game
	LDA.b !RAM_SMW_IO_ControllerHold1	;\If Left OR Right pressed
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)	;|>#%00000011
	BNE.b CODE_00D6B1		;/branch
CODE_00D68D:
	LDA.w !RAM_SMW_Player_SlidingOnGround	;\
	BEQ.b CODE_00D6AE		;/ if mario isn't sliding
CODE_00D692:
	JSR.w SMW_SpawnPlayerTurnAroundSmoke_Main	; Make smoke appear on mario ( smoke effect from when mario slides)
	LDA.w !RAM_SMW_Player_SlopePlayerIsOn2	;\ If slope is not set
	BEQ.b CODE_00D6AE		;/ continue on with game
	JSR.w UpdatePMeter_Decrement
	LDA.w !RAM_SMW_Player_SlopePlayerIsOn1
	LSR				;\Right shift to toss out bit 0 and 1
	LSR				;/
	TAY				;>And transfer to Y
	ADC.b #$76			;>While the shifted A is added
	TAX				;>And transfer that to X
	TYA				;>Transfer Y back into A since...
	LSR				;>..LSR only affects A
	ADC.b #$87			;>Add that by #$87
	TAY				;>Transfer back to Y
	JMP.w CODE_00D742

CODE_00D6AE:
	JMP.w CODE_00D764

CODE_00D6B1:
	STZ.w !RAM_SMW_Player_SlidingOnGround	;>Stop sliding
	AND.b #!Joypad_DPadR>>8		;>Clear bits 1-7 (zero is left out, is 1 if holding right)
	LDY.w !RAM_SMW_Player_CapeFlyingPhase	;\If not cape flying, skip
	BEQ.b CODE_00D6D5		;/
	CMP.b !RAM_SMW_Player_FacingDirection	;\If facing left, skip
	BEQ.b CODE_00D6C3		;/
	LDY.b !RAM_SMW_IO_ControllerPress1	;\If B button pressed (one frame)
	BPL.b CODE_00D68D		;/Then skip
CODE_00D6C3:
	LDX.b !RAM_SMW_Player_FacingDirection	;>Index facing direction
	LDY.w DATA_00D5EE,x		;>Load data depending on direction into Y
	STY.w !RAM_SMW_Player_SlopePlayerIsOn1	;>And store to slope type
	STA.b !RAM_SMW_Misc_ScratchRAM01	;>Store controller into $01
	ASL				;\Left shift 2x
	ASL				;/
	ORA.w !RAM_SMW_Player_SlopePlayerIsOn1	;>OR it with slope type
	TAX				;>Transfer to X index
	BRA.b CODE_00D713		;>And skip the following code

CODE_00D6D5:
	LDY.b !RAM_SMW_Player_FacingDirection	;>Load Facing direction into Y
	CMP.b !RAM_SMW_Player_FacingDirection	;>Compare controller with facing direction
	BEQ.b CODE_00D6EC		;>If holding right AND facing direction (both of these can only be 0 or 1) is same, branch
	LDY.w !RAM_SMW_Player_CarryingSomethingFlag2	;\If not carrying something, branch
	BEQ.b CODE_00D6EA		;/
	LDY.w !RAM_SMW_Timer_DisplayPlayerFaceScreenPose	;>Load face camera timer
	BNE.b CODE_00D6EC		;>If currently turning, return
	LDY.b #$08			;\Set facing camera timer (this is what happens if you press to turn around
	STY.w !RAM_SMW_Timer_DisplayPlayerFaceScreenPose	;/while holding something).
CODE_00D6EA:
	STA.b !RAM_SMW_Player_FacingDirection	;>Set facing direction (depend on controller)
CODE_00D6EC:
	STA.b !RAM_SMW_Misc_ScratchRAM01	;>And $01 for later for backup
	ASL				;\move bits left 2 spaces
	ASL				;/
	ORA.w !RAM_SMW_Player_SlopePlayerIsOn1	;>OR it with slope status
	TAX				;>Transfer it to X
	LDA.b !RAM_SMW_Player_XSpeed	;\If mario's x speed is none (not moving left or right)
	BEQ.b CODE_00D713		;/branch
	EOR.w MarioAccel+$01,x		;>Invert certain bits depending on what type of slope
	BPL.b CODE_00D713		;>OR If the leftmost bit (bit 7) is set, branch
	LDA.w !RAM_SMW_Timer_PlayerSlidesWhenTuring	;>Load turn around timer
	BNE.b CODE_00D713		;>OR if Mario is turning around, branch
	LDA.b !RAM_SMW_Flag_IceLevel	;\If slippery, branch to different physics
	BNE.b CODE_00D70E		;/
	LDA.b #$0D			;\Set turn around pose
	STA.w !RAM_SMW_Player_TurningAroundFlag	;/
	JSR.w SMW_SpawnPlayerTurnAroundSmoke_Main	;>Crouch sliding subroutine
CODE_00D70E:
	TXA				;>Slope status
	CLC				;\Use a new set of values based on status
	ADC.b #$90			;/
	TAX				;>Transfer it back into X since CLC ADC works only on A
CODE_00D713:
	LDY.b #$00			;>default Y = #$00
	BIT.b !RAM_SMW_IO_ControllerHold1	;>Semi-AND with Controller (not changes to A)
	; Change [50] to [80] to disable running and cause Mario to never run. The
	; Y (or X) button will not cause Mario to run. This does not affect other
	; uses of the Y button, like shooting fireballs or carrying sprites.
	BVC.b CODE_00D737		;>If bit 6 is clear (Y button), skip
	INX				;\Go to a different slope status
	INX				;/
	INY				;>And use a different Y
	LDA.b !RAM_SMW_Player_XSpeed	;\If moving rightwards (0 or positive)
	BPL.b CODE_00D723		;/don't invert
	EOR.b #$FF			;\Invert
	INC				;/
CODE_00D723:
if ver_is_pal(!Define_Global_ROMToAssemble)
	CMP.b #$2C
else
	CMP.b #$23
endif
	BMI.b CODE_00D737
	LDA.b !RAM_SMW_Player_InAirFlag	;\If in the air, skip
	BNE.b CODE_00D732		;/
	LDA.b #$10			;\Set running frames
	STA.w !RAM_SMW_Timer_ShowRunningFramesBeforeTakeOff	;/
	BRA.b CODE_00D736		;>And skip.

CODE_00D732:
	CMP.b #$0C			;\If other than long-jumping, skip
	BNE.b CODE_00D737		;/
CODE_00D736:
	INY				;>Increase Y again
CODE_00D737:
	JSR.w UpdatePMeter_Variable	;>Dash timer subroutine
	TYA				;>Transfer maxed/not maxed dash status
	ASL				;>Left shift it
	ORA.w !RAM_SMW_Player_SlopePlayerIsOn1	;>Again with the slope
	ORA.b !RAM_SMW_Misc_ScratchRAM01	;>OR it with facing direction
	TAY				;>And transfer it back into Y
CODE_00D742:
	LDA.b !RAM_SMW_Player_XSpeed	;\Mario's maximum speed (walking or running), branches to $00D76B if exceeds.
	SEC				;|\This would subtract to go towards/past 0 (AA subtract by a number the same sign as AA)
	SBC.w DATA_00D535,y		;|/
	BEQ.b CODE_00D76B		;|>If subtracts to exactly 0, branch as "exceeding the max"
	EOR.w DATA_00D535,y		;|>Make it so that it results positive when exceeding max speed (toggling bit 7)
	BPL.b CODE_00D76B		;/>if positive (exceed max speed), branch as "exceeding the max"
	REP.b #$20			; A->16
	LDA.w MarioAccel,x		;>Load acceleration tables based on slope
	LDY.b !RAM_SMW_Flag_IceLevel	;\If not slippery, branch.
	BEQ.b CODE_00D75F		;/
	LDY.b !RAM_SMW_Player_InAirFlag	;\If mario is in midair, skip loading table
	BNE.b CODE_00D75F		;/
	LDA.w DATA_00D43D,x		;>Load something based on slope status
CODE_00D75F:
	CLC				;\Accelerate mario
	ADC.b !RAM_SMW_Player_SubXSpeed	;/
	BRA.b CODE_00D7A0		;>And don't run whats below

CODE_00D764:
	JSR.w UpdatePMeter_Decrement	;>Dash timer subroutine
	LDA.b !RAM_SMW_Player_InAirFlag	;\If in midair, done.
	BNE.b Return00D7A4		;/
CODE_00D76B:
	LDA.w !RAM_SMW_Player_SlopePlayerIsOn1	;>Slope status
	LSR				;>Adjust it (right shift)
	TAY				;>Transfer shifted slope into Y
	LSR				;>a double-right shift
	TAX				;>Into X
CODE_00D772:
	LDA.b !RAM_SMW_Player_XSpeed	;\Player moves by slope
	SEC				;|
	SBC.w DATA_00D5C9+$01,x		;|
	BPL.b CODE_00D77C		;/>if positive, thats normal value
	INY				;\Adjust part of the slope index
	INY				;/
CODE_00D77C:
	LDA.w !RAM_SMW_Timer_EndLevel	;>If completing a level
	ORA.b !RAM_SMW_Player_InAirFlag	;>Or if in midair
	REP.b #$20			; A->16
	BNE.b CODE_00D78C		;>Go somewhere else
	LDA.w DATA_00D309,y		;>Load data based on slope
	BIT.b !RAM_SMW_Flag_IceLevel-$01	;\Check negative flag of water flag
	BMI.b CODE_00D78F		;/
CODE_00D78C:
	LDA.w DATA_00D2CD,y
CODE_00D78F:
	CLC
	ADC.b !RAM_SMW_Player_SubXSpeed
	STA.b !RAM_SMW_Player_SubXSpeed
	SEC
	SBC.w DATA_00D5C9,x		;>autoslide slope speeds
	EOR.w DATA_00D2CD,y		;>Decelerate x speeds
	BMI.b CODE_00D7A2		;>If negative, don't set x speed at all (leave it be).
	LDA.w DATA_00D5C9,x		;>autoslide slope speeds
CODE_00D7A0:
	STA.b !RAM_SMW_Player_SubXSpeed	;>Set speed
CODE_00D7A2:
	SEP.b #$20			; A->8
Return00D7A4:
	RTS

DATA_00D7A5:
if ver_is_pal(!Define_Global_ROMToAssemble)
	dw $06E6,$0373,$0499,$1266
	dw $F220,$0126,$0373,$0499
	dw $05C0,$06E6

DATA_00D7AF:
	dw $4000,$4000,$2000,$4000
	dw $4000,$4000,$4000,$4000
	dw $4000,$4000

DATA_00D7B9:
	db $10,$C8,$E0,$02,$03,$03,$04,$03
	db $02,$00,$01,$00,$00,$00

DATA_00D7C8:
	dw $0100,$1000,$3000,$3000
	dw $3800,$3800,$4000
else
	; Gravity. The first byte is when not holding B (or A), the second is
	; gravity when holding B/A, and the third is when riding on a winged Yoshi.
	db $06,$03,$04,$10,$F4,$01,$03,$04	;!
	db $05,$06			;!

; Falling maximum speed (without button held)
DATA_00D7AF:
	db $40,$40,$20,$40,$40,$40,$40,$40	;!
	db $40,$40			;!

; The speed at which Mario falls with a cape. Set it lower to make him float
; slower, higher to float faster, and over D0 to enable unlimited jumping in
; midair with the cape.
DATA_00D7B9:
	db $10,$C8,$E0,$02,$03,$03,$04,$03	;!
	db $02,$00,$01,$00,$00,$00,$00	;!

; Maximum falling speed for cape mario, index by RAM address $1407 (cape
; phase).
DATA_00D7C8:
	db $01,$10,$30,$30,$38,$38,$40	;!
endif

; cape speed
CapeSpeed:
	db $FF,$01,$01,$FF,$FF

DATA_00D7D4:
	db $01,$06,$03,$01,$00

DATA_00D7D9:
	db $00,$00,$00,$F8,$F8,$F8,$F4,$F0
	db $C8,$02,$01

InAir:
	LDY.w !RAM_SMW_Player_CapeFlyingPhase
	BNE.b CODE_00D824
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_00D811
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2
	ORA.w !RAM_SMW_Player_RidingYoshiFlag
	ORA.w !RAM_SMW_Player_SpinJumpFlag
	BNE.b CODE_00D811
	LDA.w !RAM_SMW_Player_SlidingOnGround
	BMI.b CODE_00D7FF
	BNE.b CODE_00D811
CODE_00D7FF:
	STZ.w !RAM_SMW_Player_SlidingOnGround
	LDX.b !RAM_SMW_Player_CurrentPowerUp
	CPX.b #$02
	BNE.b CODE_00D811
	LDA.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_00D811
	LDA.w !RAM_SMW_Timer_WaitBeforeCapeFlightBegins
	BNE.b CODE_00D814
CODE_00D811:
	JMP.w CODE_00D8CD

CODE_00D814:
	STZ.b !RAM_SMW_Player_DuckingFlag
	LDA.b #$0B			;| sort of flying
	STA.b !RAM_SMW_Player_InAirFlag
	STZ.w !RAM_SMW_Player_FurthestCapeDiveStage	;| time to fly up= none?
	JSR.w CODE_00D94F		; Handling flying up time
	LDX.b #$02			;\
	BRA.b CODE_00D85B		;/ continue

CODE_00D824:
	CPY.b #$02
	BCC.b CODE_00D82B
	JSR.w CODE_00D94F
CODE_00D82B:
	LDX.w !RAM_SMW_Player_CapeGlideIndex
	CPX.b #$04
	BEQ.b CODE_00D856
	LDX.b #$03
	LDY.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_00D856
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)
	TAY
	BNE.b CODE_00D849
	LDA.w !RAM_SMW_Player_CapeFlyingPhase
	CMP.b #$04
	BCS.b CODE_00D856
	DEX
	BRA.b CODE_00D856

CODE_00D849:
	LSR
	LDY.b !RAM_SMW_Player_FacingDirection
	BEQ.b CODE_00D850
	EOR.b #!Joypad_DPadR>>8
CODE_00D850:
	TAX
	CPX.w !RAM_SMW_Player_CapeGlideIndex
	BNE.b CODE_00D85B
CODE_00D856:
	LDA.w !RAM_SMW_Timer_ChangeDivingState	;\If timer phase not 0, branch
	BNE.b CODE_00D87E		;/
CODE_00D85B:
	BIT.b !RAM_SMW_IO_ControllerHold1
	BVS.b CODE_00D861
	LDX.b #$04
CODE_00D861:
	LDA.w !RAM_SMW_Player_CapeFlyingPhase
	CMP.w DATA_00D7D4,x
	BEQ.b CODE_00D87E
	CLC
	ADC.w CapeSpeed,x
	STA.w !RAM_SMW_Player_CapeFlyingPhase
	LDA.b #$08
	LDY.w !RAM_SMW_Player_FurthestCapeDiveStage	;\Skip writing A with #$02 if furthest stage flight is
	CPY.b #$C8			;|other than #$C8.
	BNE.b CODE_00D87B		;/
	LDA.b #$02
CODE_00D87B:
	STA.w !RAM_SMW_Timer_ChangeDivingState	;>Set timer for advance stage
CODE_00D87E:
	STX.w !RAM_SMW_Player_CapeGlideIndex	;>Set cape state (not phase, this holds the next step in cape phase)
	LDY.w !RAM_SMW_Player_CapeFlyingPhase	;>$1407 = cape phase
	BEQ.b CODE_00D8CD		;>If not flying, treat as if mario isn't cape-flying
if ver_is_pal(!Define_Global_ROMToAssemble)
	PHY
	TYA
	ASL
	TAY
	REP.b #$20
	LDA.b !RAM_SMW_Player_SubYSpeed
	BPL.b CODE_00D892
	CMP.w #$00C8
	BCS.b CODE_00D89A
	LDA.w #$00C8
else
	LDA.b !RAM_SMW_Player_YSpeed	;!
	BPL.b CODE_00D892		;!
	CMP.b #$C8			;!
	BCS.b CODE_00D89A		;!
	LDA.b #$C8			;!
endif
	BRA.b CODE_00D89A		;!

CODE_00D892:
	CMP.w DATA_00D7C8,y		;!
	BCC.b CODE_00D89A		;!
	LDA.w DATA_00D7C8,y		;!
CODE_00D89A:
if ver_is_pal(!Define_Global_ROMToAssemble)
	PLY
	PHA
	SEP.b #$20
else
	PHA				;!
endif
	CPY.b #$01			;!
	BNE.b CODE_00D8C6		;!
	LDX.w !RAM_SMW_Player_FurthestCapeDiveStage	;!
	BEQ.b CODE_00D8C4		;!
	LDA.b !RAM_SMW_Player_YSpeed	;!
	BMI.b CODE_00D8AF		;!
	LDA.b #!Define_SMW_Sound1DF9_FlyWithCape	;! \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1	;! /
	BRA.b CODE_00D8B9		;!

CODE_00D8AF:
	CMP.w !RAM_SMW_Player_FurthestCapeDiveStage	;!
	BCS.b CODE_00D8B9		;!
	STX.b !RAM_SMW_Player_YSpeed	;!
	STZ.w !RAM_SMW_Player_FurthestCapeDiveStage	;!
CODE_00D8B9:
	LDX.b !RAM_SMW_Player_FacingDirection	;!
	LDA.b !RAM_SMW_Player_XSpeed	;!
	BEQ.b CODE_00D8C4		;!
	EOR.w DATA_00D535,x		;!
	BPL.b CODE_00D8C6		;!
CODE_00D8C4:
	LDY.b #$02			;!
CODE_00D8C6:
if ver_is_pal(!Define_Global_ROMToAssemble)
	INY
	INY
	INY
	TYA
	ASL
	TAY
	REP.b #$20
	PLA
else
	PLA				;!
	INY				;!
	INY				;!
	INY				;!
endif
	JMP.w CODE_00D948

CODE_00D8CD:
	LDA.b !RAM_SMW_Player_InAirFlag	; \ Branch if not flying
	BEQ.b CODE_00D928
	LDX.b #$00			; X = #$00
	LDA.w !RAM_SMW_Player_RidingYoshiFlag	; \ Branch if not on Yoshi
	BEQ.b CODE_00D8E7
	LDA.w !RAM_SMW_Yoshi_YoshiHasWings	; \ Branch if not winged Yoshi
	LSR
	BEQ.b CODE_00D8E7
	LDY.b #$02			; \ Branch if not Caped Mario
	CPY.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_00D8E5
	INX				; X= #$01
CODE_00D8E5:
	BRA.b CODE_00D8FF

CODE_00D8E7:
	LDA.b !RAM_SMW_Player_CurrentPowerUp	; \ Branch if not Caped Mario
	CMP.b #$02
	BNE.b CODE_00D928
	LDA.b !RAM_SMW_Player_InAirFlag	; \ Branch if $72 != 0C
	CMP.b #$0C
	BNE.b CODE_00D8FD
	LDY.b #$01
	CPY.w !RAM_SMW_Timer_WaitBeforeCapeFlightBegins	;\Cape sinking/rising
	BCC.b CODE_00D8FF		;/
	INC.w !RAM_SMW_Timer_WaitBeforeCapeFlightBegins
CODE_00D8FD:
	LDY.b #$00
CODE_00D8FF:
	LDA.w !RAM_SMW_Timer_TimeToFloatAfterCapeFlight	;\Floating timer
	BNE.b CODE_00D90D		;/
	LDA.b !RAM_SMW_IO_ControllerHold1,x	;\If holding dash
	BPL.b CODE_00D924		;/
	LDA.b #$10			;\Set timer
	STA.w !RAM_SMW_Timer_TimeToFloatAfterCapeFlight	;/
CODE_00D90D:
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_00D91B
	LDX.w DATA_00D7B9,y
	BPL.b CODE_00D924
	CMP.w DATA_00D7B9,y
	BCC.b CODE_00D924
CODE_00D91B:
	LDA.w DATA_00D7B9,y
	CMP.b !RAM_SMW_Player_YSpeed
	BEQ.b CODE_00D94C
	BMI.b CODE_00D94C
CODE_00D924:
	CPY.b #$02
	BEQ.b +
CODE_00D928:
	LDY.b #$01
	LDA.b !RAM_SMW_IO_ControllerHold1	;\If holding jump, then leave Y as is.
	BMI.b +				;/
CODE_00D92E:
	LDY.b #$00
if ver_is_pal(!Define_Global_ROMToAssemble)
+:
	TYA
	ASL
	TAY
	REP.b #$20
	LDA.b !RAM_SMW_Player_SubYSpeed
else
+:
	LDA.b !RAM_SMW_Player_YSpeed	;! \ If Mario's Y speed is negative (up),
endif
	BMI.b CODE_00D948		;! / branch to $D948
	CMP.w DATA_00D7AF,y		;!
	BCC.b CODE_00D93C		;!
	LDA.w DATA_00D7AF,y		;!
CODE_00D93C:
	LDX.b !RAM_SMW_Player_InAirFlag	;!
	BEQ.b CODE_00D948		;!
	CPX.b #$0B			;!
	BNE.b CODE_00D948		;!
	LDX.b #$24			;!
	STX.b !RAM_SMW_Player_InAirFlag	;!
CODE_00D948:
	CLC				;!
	ADC.w DATA_00D7A5,y		;!
if ver_is_pal(!Define_Global_ROMToAssemble)
	SEP.b #$20
	STA.b !RAM_SMW_Player_SubYSpeed
	XBA
endif
CODE_00D94C:
	STA.b !RAM_SMW_Player_YSpeed
	RTS

CODE_00D94F:
	STZ.w !RAM_SMW_UnusedRAM_7E140A			; Optimization: This is unused
	LDA.b !RAM_SMW_Player_YSpeed	;\ if mario is moving to the right, keep A
	BPL.b CODE_00D958		;/
	LDA.b #$00			; reset A
CODE_00D958:
	LSR				;\
	LSR				;|
	LSR				;|
	TAY				;|handle flying up time, I think
	LDA.w DATA_00D7D9,y		;|
	CMP.w !RAM_SMW_Player_FurthestCapeDiveStage	;|
	BPL.b Return00D967		;|
	STA.w !RAM_SMW_Player_FurthestCapeDiveStage	;/
Return00D967:
	RTS

UpdatePMeter:
.Decrement:
	LDY.b #$00			;>Default Y = #$00
.Variable:
	LDA.w !RAM_SMW_Player_PMeter	;\Dash timer increases/decreases depending
	CLC				;|on Y
	ADC.w DATA_00D5EB,y		;/
	BPL.b .CODE_00D975		;>if 0 or positive, skip
	LDA.b #$00			;>Prevent dash timer continuously going down.
.CODE_00D975:
	CMP.b #!Define_SMW_Physics_PMeterMax	;>Compare the maximum dash timer
	BCC.b .CODE_00D97C		;>If less than, leave it
	INY				;>Switch dash status
	LDA.b #!Define_SMW_Physics_PMeterMax
.CODE_00D97C:
	STA.w !RAM_SMW_Player_PMeter
	RTS

SwimPoses:
	db $16,$1A,$1A,$18

SwimYSpeed:
	db $E8,$F8,$D0,$D0

Swimming:
	STZ.w !RAM_SMW_Player_SlidingOnGround	;>Disable sliding on slopes
	STZ.b !RAM_SMW_Player_DuckingFlag	;>Prevent ducking (when not touching ground)
	STZ.w !RAM_SMW_Player_CapeFlyingPhase	;>Disable cape gliding
	STZ.w !RAM_SMW_Player_SpinJumpFlag	;>No spinjumping
	LDY.b !RAM_SMW_Player_YSpeed	;>Y = player's Y speed
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2
	; Change this from [F0] (BEQ) to [80] (BRA) so that when the player is
	; carrying an item while swimming, his Y speed won't be affected (the
	; player will sink normally). Also, if you change this to [D0] (BNE), the
	; player will float if carrying nothing and sink if carrying an item.
	BEQ.b CODE_00D9EB
	LDA.b !RAM_SMW_Player_InAirFlag	;\If mario isn't touching the ground
	BNE.b CODE_00D9AF		;/
	LDA.b !RAM_SMW_IO_ControllerPress1	;\If pressing jump or spinjump, make mario
	ORA.b !RAM_SMW_IO_ControllerPress2	;|paddle to swim upward
	BPL.b CODE_00D9AF		;/
	LDA.b #$0B			;\Flag that mario is going upward.
	STA.b !RAM_SMW_Player_InAirFlag	;/
	STZ.w !RAM_SMW_Player_SlidingOnGround	;>Disable slope sliding
	LDY.b #$F0			;>Subsitute Y with #$F0
	BRA.b CODE_00D9B5

CODE_00D9AF:
	LDA.b !RAM_SMW_IO_ControllerHold1	;\Pressing down
	AND.b #!Joypad_DPadD>>8		;|
	BEQ.b CODE_00D9BD		;/
CODE_00D9B5:
	JSR.w CODE_00DAA9		;>Some sound effects
	TYA				;>Transfer player Y speed in Y register to A
	CLC				;\Add by #$08
	ADC.b #$08			;/
	TAY				;>Transfer back to Y
CODE_00D9BD:
	INY				;>Increment it
	LDA.w !RAM_SMW_Player_CanJumpOutOfWater	;\Check if the player can jump out of the water
	BNE.b CODE_00D9CC		;/
	DEY				;>Decrement Y back down
	LDA.b !RAM_SMW_Counter_LocalFrames	;>Frame counter
	AND.b #$03			;\Every 4th frame (AND #%00000011 = x MOD 4)
	BNE.b CODE_00D9CC		;/
	DEY				;\Decrement Y by 2
	DEY				;/
CODE_00D9CC:
	TYA				;>Transfer to A
	BMI.b CODE_00D9D7		;>If the resulting Y speed is upward (up is negative)
	CMP.b #$10			;\if player's y speed is #$00-#$0F
	BCC.b CODE_00D9DD		;/
	LDA.b #$10			;\A = #$10 (limit it)
	BRA.b CODE_00D9DD		;/

CODE_00D9D7:
	CMP.b #$F0			;\A reversed version of $00D9CF (#$F0-#$FF)
	BCS.b CODE_00D9DD		;/
	LDA.b #$F0
CODE_00D9DD:
	STA.b !RAM_SMW_Player_YSpeed
	LDY.b #$80			;>Y = #$80
	LDA.b !RAM_SMW_IO_ControllerHold1	;\Check if the player is pressing left or right to move the player
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)	;|horizontally
	BNE.b CODE_00DA48		;/
	LDA.b !RAM_SMW_Player_FacingDirection	;>player's facing
	BRA.b CODE_00DA46

CODE_00D9EB:
	LDA.b !RAM_SMW_IO_ControllerPress1	;\If player is pressing jump/spinjump
	ORA.b !RAM_SMW_IO_ControllerPress2	;|
	BPL.b CODE_00DA0B		;/
	LDA.w !RAM_SMW_Player_CanJumpOutOfWater	;\Check if the player can jump out of water
	BNE.b CODE_00DA0B		;/
	JSR.w CODE_00DAA9		;>sfx stuff
	LDA.b !RAM_SMW_Player_InAirFlag	;\If mario is not on the ground
	BNE.b CODE_00DA06		;/
	LDA.b #$0B			;\flag as rising upward
	STA.b !RAM_SMW_Player_InAirFlag	;/
	STZ.w !RAM_SMW_Player_SlidingOnGround	;>No sliding pose
	LDY.b #$F0			;Y = #$F0
CODE_00DA06:
	TYA				;>Y transfer to A
	SEC				;\Subtract by #$20
	SBC.b #$20			;/
	TAY				;>Transfer back to Y
CODE_00DA0B:
	LDA.b !RAM_SMW_Counter_LocalFrames	;\Check if forth frame
	AND.b #$03			;|
	BNE.b CODE_00DA13		;/
	INY				;\Y + 2
	INY				;/
CODE_00DA13:
	LDA.b !RAM_SMW_IO_ControllerHold1	;>Controller data: byetUDLR
	AND.b #(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)	;>0000UD00
	LSR				;\000000UD, basically check if the player is
	LSR				;/holding up or down to alter how fast the player swims up or down when hitting B or A
	TAX				;>Transfer to index
	TYA				;>Transfer Y to A
	BMI.b CODE_00DA25		;>Check if negative
	CMP.b #$40			;\if #$00-#$3F
	BCC.b CODE_00DA2D		;/
	LDA.b #$40			;\otherwise limit it
	BRA.b CODE_00DA2D		;/

CODE_00DA25:
	CMP.w SwimYSpeed,x
	BCS.b CODE_00DA2D
	LDA.w SwimYSpeed,x
CODE_00DA2D:
	STA.b !RAM_SMW_Player_YSpeed
	LDA.b !RAM_SMW_Player_InAirFlag	;\If not on ground
	BNE.b CODE_00DA40		;/
	LDA.b !RAM_SMW_IO_ControllerHold1	;>byetUDLR
	AND.b #!Joypad_DPadD>>8		;>00000D00
	; Change to 80 to disable ducking underwater, can be used in conjunction
	; with $00D604 hex edit.
	BEQ.b CODE_00DA40		;>Check if down is pressed.
	STZ.w !RAM_SMW_Flag_CapeToSpriteInteraction	;>No interaction with capes with sprites (cancel cape)
	INC.b !RAM_SMW_Player_DuckingFlag	;>make mario duck (water version)
	BRA.b CODE_00DA69

CODE_00DA40:
	LDA.b !RAM_SMW_IO_ControllerHold1	;>byetUDLR
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)	;>000000LR
	BEQ.b CODE_00DA69		;>If pressing none
CODE_00DA46:
	LDY.b #$78
CODE_00DA48:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	AND.b #!Joypad_DPadR>>8		;>0000000R
	STA.b !RAM_SMW_Player_FacingDirection	;>Set player facing (face foward from pressing direction)
	PHA				;>Save controller bits for R
	ASL				;\00000R00
	ASL				;/
	TAX				;>Transfer to X
	PLA				;>Restore controller for R
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;>OR it with whats Y written (depends if $00D9E5 is used)
	; Mario's horizontal water interaction routine.
	LDY.w !RAM_SMW_Flag_Layer3TideLevel	;>Y = layer 3 tide setting
	BEQ.b CODE_00DA5D		;>if none, don't push the player
	CLC				;\Add A by #$04
	ADC.b #$04			;/
CODE_00DA5D:
	TAY				;>Transfer to index
	LDA.b !RAM_SMW_Player_InAirFlag	;\If mario is on ground
	BEQ.b CODE_00DA64		;/
	INY				;\Y + 2
	INY				;/
CODE_00DA64:
	JSR.w CODE_00D742		;>Some ground physics stuff
	BRA.b CODE_00DA7C

CODE_00DA69:
	LDY.b #$00			;>Y = #$00
	TYX				;>Transfer to X
	LDA.w !RAM_SMW_Flag_Layer3TideLevel	;\check if layer 3 tide is active
	BEQ.b CODE_00DA79		;/
	LDX.b #$1E			;>X = #$1E
	LDA.b !RAM_SMW_Player_InAirFlag	;\Check if not touching the ground
	BNE.b CODE_00DA79		;/
	INX				;\X + 2
	INX				;/
CODE_00DA79:
	JSR.w CODE_00D772		;>Slope stuff
CODE_00DA7C:
	JSR.w SMW_CheckForPowerUpSpecificPlayerAttacks_Main	;>Air physics?
	JSL.l SMW_SetPlayerPose_Main	;>cape animation
	LDA.w !RAM_SMW_Timer_ActiveCapeSpin	;\if cape spin running, return
	BNE.b Return00DA8C		;/
	LDA.b !RAM_SMW_Player_InAirFlag	;\if not on ground...
	BNE.b DisplaySwimPoses		;/
Return00DA8C:
	RTS

DisplaySwimPoses:
	LDA.b #$18			;>A = #$18
	LDY.w !RAM_SMW_Timer_DisplayPlayerShootFireballPose	;>Y = fireball shoot pose
	BNE.b CODE_00DA9F		;>if still running, branch
	LDA.w !RAM_SMW_Player_AnimationTimer
	LSR				;\Divide by 4
	LSR				;/
	AND.b #$03			;>Modulo by 4
	TAY				;>transfer to Y
	LDA.w SwimPoses,y		;>Pose table
CODE_00DA9F:
	LDY.w !RAM_SMW_Player_CarryingSomethingFlag2	;\if not holding a sprite
	BEQ.b CODE_00DAA5		;/
	INC				;>increment to next pose
CODE_00DAA5:
	STA.w !RAM_SMW_Player_CurrentPose	;>set pose
	RTS

CODE_00DAA9:
	LDA.b #!Define_SMW_Sound1DF9_Swim	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	LDA.w !RAM_SMW_Player_AnimationTimer			;\ Glitch: This can potentially run on the same frame the player gets hurt, thus messing up the hurt animation.
	ORA.b #$10						;|
	STA.w !RAM_SMW_Player_AnimationTimer			;/
	RTS

; Vine climbing speed 1 (right and down)
ClimbingSpeed:
	db $10,$08,$F0,$F8

JumpFromVineYSpeed:
	db $B0,$F0

DATA_00DABD:
	db $00,$01,$00,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$01,$01,$01,$01

SwingOnNetDoorPoses:
	db $22,$15,$22,$15,$21,$1F,$20,$20
	db $20,$20,$1F,$21,$1F,$21

ClimbingPoses:
	db $15		; In front of net
	db $22		; Behind net

NetPunchingPoses:
	db $1E		; In front of net
	db $23		; Behind net

DATA_00DADF:
	db $10,$0F,$0E,$0D,$0C,$0B,$0A,$09
	db $08,$07,$06,$05,$05,$05,$05,$05
	db $05,$05

DATA_00DAF1:
	dw $0120,$0140,$012A,$012A
	dw $0130,$0133,$0132,$0134
	dw $0136,$0138,$013A,$013B
	dw $0145,$0145,$0145,$0145
	dw $0145,$0145

UNK_00DB15:
	db $08,$F8

Climbing:
	STZ.b !RAM_SMW_Player_InAirFlag
	STZ.b !RAM_SMW_Player_YSpeed
	STZ.w !RAM_SMW_Player_CapeImage
	STZ.w !RAM_SMW_Player_SpinJumpFlag
	LDY.w !RAM_SMW_Timer_OnSwingingClimbingNetDoor
	BEQ.b CODE_00DB7D
	LDA.w !RAM_SMW_Sprites_PlayerXSpeedOnSwingingNetDoor
	BPL.b CODE_00DB2E
	EOR.b #$FF
	INC
CODE_00DB2E:
	TAX
	CPY.b #$1E
	BCC.b CODE_00DB45
	LDA.w DATA_00DADF,x
	BIT.w !RAM_SMW_Sprites_PlayerXSpeedOnSwingingNetDoor
	BPL.b CODE_00DB3E
	EOR.b #$FF
	INC
CODE_00DB3E:
	STA.b !RAM_SMW_Player_XSpeed
	STZ.b !RAM_SMW_Player_SubXSpeed
	STZ.w !RAM_SMW_Player_SubXPos
CODE_00DB45:
	TXA
	ASL
	TAX
	LDA.w !RAM_SMW_Sprites_PlayerXSpeedOnSwingingNetDoor
	CPY.b #$08
	BCS.b CODE_00DB51
	EOR.b #$80
CODE_00DB51:
	ASL
	REP.b #$20			; A->16
	LDA.w DATA_00DAF1,x
	BCS.b CODE_00DB5D
	EOR.w #$FFFF
	INC
CODE_00DB5D:
	CLC
	ADC.b !RAM_SMW_Player_SubXSpeed
	STA.b !RAM_SMW_Player_SubXSpeed
	SEP.b #$20			; A->8
	TYA
	LSR
	AND.b #$0E
	ORA.w !RAM_SMW_Player_FacingDirectionOnNetDoor
	TAY
	LDA.w DATA_00DABD,y
	BIT.w !RAM_SMW_Sprites_PlayerXSpeedOnSwingingNetDoor
	BMI.b CODE_00DB76
	EOR.b #$01
CODE_00DB76:
	STA.b !RAM_SMW_Player_FacingDirection
	LDA.w SwingOnNetDoorPoses,y
	BRA.b CODE_00DB92

CODE_00DB7D:
	STZ.b !RAM_SMW_Player_XSpeed
	STZ.b !RAM_SMW_Player_SubXSpeed
	LDX.w !RAM_SMW_Player_CurrentLayerPriority
	LDA.w !RAM_SMW_Timer_DisplayPlayerNetPunchPose
	BEQ.b CODE_00DB96
	TXA
	INC
	INC
	JSR.w SMW_InitializeCapeSwingOrNetPunch_Main
	LDA.w NetPunchingPoses,x
CODE_00DB92:
	STA.w !RAM_SMW_Player_CurrentPose
	RTS

CODE_00DB96:
	LDY.b !RAM_SMW_Player_SwimmingFlag	; Mario is in Water flag
	BIT.b !RAM_SMW_IO_ControllerPress1
	; [10] Change to 80 to disable jumping while climbing.
	BPL.b CODE_00DBAC
	LDA.b #$0B			;\ Certain amount of flying meter
	STA.b !RAM_SMW_Player_InAirFlag	;/
	LDA.w JumpFromVineYSpeed,y	;\ Gravity I suppose
	STA.b !RAM_SMW_Player_YSpeed	;/
	LDA.b #!Define_SMW_Sound1DFA_Jump	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
	BRA.b CODE_00DC00

CODE_00DBAC:
	BVC.b CODE_00DBCA
	LDA.b !RAM_SMW_Player_ClimbingFlag
	BPL.b CODE_00DBCA
	LDA.b #!Define_SMW_Sound1DF9_HitHead	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
	STX.w !RAM_SMW_Player_FacingDirectionOnNetDoor
	LDA.b !RAM_SMW_Player_XPosLo	; Mario X
	AND.b #$08
	LSR
	LSR
	LSR
	EOR.b #$01
	STA.b !RAM_SMW_Player_FacingDirection	; Mario's Direction
	LDA.b #$08
	STA.w !RAM_SMW_Timer_DisplayPlayerNetPunchPose
CODE_00DBCA:
	LDA.w ClimbingPoses,x
	STA.w !RAM_SMW_Player_CurrentPose	; Store A in Mario image
	LDA.b !RAM_SMW_IO_ControllerHold1	;\
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)	;| If Left/Right not pressed ignore this
	BEQ.b CODE_00DBF2		;/
	LSR
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	AND.b #$18
	CMP.b #$18
	BEQ.b CODE_00DBE8
	LDA.b !RAM_SMW_Player_ClimbingFlag	;\ If climbing make him stop and return
	BPL.b CODE_00DC00		;/
	CPX.b !RAM_SMW_Misc_ScratchRAM8C
	BEQ.b CODE_00DBF2
CODE_00DBE8:
	TXA				;\
	ASL				;| Index to Xspeed
	ORA.b !RAM_SMW_Player_SwimmingFlag	;|
	TAX				;/
	LDA.w ClimbingSpeed,x		;\$10,$08,$F0,$F8
	STA.b !RAM_SMW_Player_XSpeed	;/
CODE_00DBF2:
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)	; |If up or down isn't pressed, branch to $DC16
	BEQ.b CODE_00DC16
	AND.b #!Joypad_DPadU>>8		; \ If up is pressed, branch to $DC03
	BNE.b CODE_00DC03
	LSR.b !RAM_SMW_Misc_ScratchRAM8B
	BCS.b CODE_00DC0B
CODE_00DC00:
	STZ.b !RAM_SMW_Player_ClimbingFlag	; Mario isn't climbing
	RTS

CODE_00DC03:
	INY
	INY
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	AND.b #$02
	BEQ.b CODE_00DC16
CODE_00DC0B:
	LDA.b !RAM_SMW_Player_ClimbingFlag
	BMI.b CODE_00DC11
	STZ.b !RAM_SMW_Player_XSpeed
CODE_00DC11:
	LDA.w ClimbingSpeed,y
	STA.b !RAM_SMW_Player_YSpeed
CODE_00DC16:
	ORA.b !RAM_SMW_Player_XSpeed
	BEQ.b Return00DC2C
	LDA.w !RAM_SMW_Player_AnimationTimer
	ORA.b #$08
	STA.w !RAM_SMW_Player_AnimationTimer
	AND.b #$07
	BNE.b Return00DC2C
	LDA.b !RAM_SMW_Player_FacingDirection
	EOR.b #$01
	STA.b !RAM_SMW_Player_FacingDirection
Return00DC2C:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckForPowerUpSpecificPlayerAttacks(Address)
namespace SMW_CheckForPowerUpSpecificPlayerAttacks
%InsertMacroAtXPosition(<Address>)

; Cape Swing routine. $00D065: Which powerup allows the player to capespin.
; Change $00D067 to 00 instead to allow capespinning with any powerup.
; $00D077: How long the capespin lasts. $00D07C: Sound effect for
; capespinning.
Main:
	LDA.b !RAM_SMW_Player_CurrentPowerUp	;\
	CMP.b #$02			;| if mario is not caped,
	BNE.b CODE_00D081		;/
	BIT.b !RAM_SMW_IO_ControllerPress1	;\ if X/Y not held, return
	BVC.b Return00D0AD		;/
	LDA.b !RAM_SMW_Player_DuckingFlag	;\
	ORA.w !RAM_SMW_Player_RidingYoshiFlag	;| if mario is ducking, on yoshi, or spinjumping,
	ORA.w !RAM_SMW_Player_SpinJumpFlag	;|return
	BNE.b Return00D0AD		;/
	LDA.b #$12			;\
	STA.w !RAM_SMW_Timer_ActiveCapeSpin	;/ make mario spin
	LDA.b #!Define_SMW_Sound1DFC_SpinJump	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
	RTS

; Fireball throwing routine. $00D082 is the power-up that can throw
; fireballs. Change $00D084 to 00 to let Mario throw fireballs in all forms.
; Change $00D085 from A5 73 to A9 00 to enable throwing fireballs while
; ducking. Change $00D087 from 0D 7A 18 to EA EA EA to enable throwing
; fireballs while on Yoshi. Change $00D08A to 80 do disable throwing
; fireballs. Change $00D093 from F0 to 80 to disable throwing fireballs
; while spin jumping.
CODE_00D081:
	CMP.b #$03			;\ if mario not firey, return
	BNE.b Return00D0AD		;/
	LDA.b !RAM_SMW_Player_DuckingFlag	;\
	ORA.w !RAM_SMW_Player_RidingYoshiFlag	;| ducking, or on yoshi? Return.
	BNE.b Return00D0AD		;/
	BIT.b !RAM_SMW_IO_ControllerPress1	;\ if X/Y pressed, shoot fireball
	BVS.b CODE_00D0AA		;/
	LDA.w !RAM_SMW_Player_SpinJumpFlag	;\ if not on a spinjump, return
	BEQ.b Return00D0AD		;/
	INC.w !RAM_SMW_Player_SpinjumpFireballTimer
	LDA.w !RAM_SMW_Player_SpinjumpFireballTimer
	AND.b #$0F
	BNE.b Return00D0AD
	TAY
	LDA.w !RAM_SMW_Player_SpinjumpFireballTimer
	AND.b #$10
	BEQ.b CODE_00D0A8
	INY
CODE_00D0A8:
	STY.b !RAM_SMW_Player_FacingDirection
CODE_00D0AA:
	JSR.w SMW_SpawnPlayerFireball_Main	; haha, I read this as "FEAR" at first
Return00D0AD:
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_SpawnPlayerFireball(Address)
namespace SMW_SpawnPlayerFireball
%InsertMacroAtXPosition(<Address>)

; Initial fireball X speed facing left
InitialXSpeed:
	db $FD,$03

; X-position of Mario's fireball (left)
InitialXPosLo:
	db $00,$08
	; X-position of Mario's fireball when on Yoshi (left). Only relevant if you
	; enable the debug code at $00D087.
	db $F8,$10
	; X-position of Mario's fireball when on Yoshi and ducking (left). Only
	; relevant if you enable the debug code at $00D087.
	db $F8,$10

; X-position of Mario's fireball (left), high byte.
InitialXPosHi:
	db $00,$00
	; X-position of Mario's fireball when on Yoshi (left), high byte. Only
	; relevant if you enable the debug code at $00D087.
	db $FF,$00
	; X-position of Mario's fireball when on Yoshi and ducking (left), high
	; byte. Only relevant if you enable the debug code at $00D087.
	db $FF,$00

; Y-Position for Mario's Fireballs (Left)
InitialYPosLo:
	db $08,$08
	; Y-position of Mario's fireball when on Yoshi (left). Only relevant if you
	; enable the debug code at $00D087
	db $0C,$0C
	; Y-position of Mario's fireball when on Yoshi and ducking (left). Only
	; relevant if you enable the debug code at $00D087.
	db $14,$14

Main:
	LDX.b #!Define_SMW_MaxExtendedSpriteSlot	; \ Find a free fireball slot (08-09)
CODE_00FEAA:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,x
	BEQ.b CODE_00FEB5
	DEX
	CPX.b #!Define_SMW_MaxExtendedSpriteSlot-$02
	BNE.b CODE_00FEAA
	RTS				; / Return if no free slots

CODE_00FEB5:
	LDA.b #!Define_SMW_Sound1DFC_ShootFireball
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	LDA.b #$0A
	STA.w !RAM_SMW_Timer_DisplayPlayerShootFireballPose
	LDA.b #!Define_SMW_SpriteID_ExtSpr05_MarioFireball	; \ Extended sprite = Mario fireball
	STA.w !RAM_SMW_ExtSpr_SpriteID,x
	LDA.b #$30
	STA.w !RAM_SMW_ExtSpr_YSpeed,x
	LDY.b !RAM_SMW_Player_FacingDirection
	LDA.w InitialXSpeed,y
	STA.w !RAM_SMW_ExtSpr_XSpeed,x
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_00FEDF
	INY							;\ Note: It's impossible to throw fireballs on Yoshi normally, so this code goes unused.
	INY							;|
	LDA.w !RAM_SMW_Yoshi_DuckingFlag			;|
	BEQ.b CODE_00FEDF					;|
	INY							;|
	INY							;|
CODE_00FEDF:							;/
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w InitialXPosLo,y
	STA.w !RAM_SMW_ExtSpr_XPosLo,x
	LDA.b !RAM_SMW_Player_XPosHi
	ADC.w InitialXPosHi,y
	STA.w !RAM_SMW_ExtSpr_XPosHi,x
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.w InitialYPosLo,y
	STA.w !RAM_SMW_ExtSpr_YPosLo,x
	LDA.b !RAM_SMW_Player_YPosHi
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,x
	LDA.w !RAM_SMW_Player_CurrentLayerPriority
	STA.w !RAM_SMW_ExtSpr05_MarioFireball_CurrentLayerPriority,x
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleStandardLevelCameraScroll(Address)
namespace SMW_HandleStandardLevelCameraScroll
%InsertMacroAtXPosition(<Address>)

; Where Mario has to be vertically on-screen for the game to consider the
; screen "caught up" with him in a particular direction, thereby stopping it
; from scrolling. The first two bytes are for scrolling upwards, while the
; second two are scrolling down.
DATA_00F69F:
	dw $0064,$007C

DATA_00F6A3:
	dw $0000,$FFFF

; How fast the camera "catches up" to Mario when scrolling vertically. The
; first two bytes are when scrolling upwards, while the second two are
; scrolling down. The third entry is a bit strange, and for the most part
; unused. If the level is set to "no vertical scroll unless
; flying/climbing/etc.", then it gets used as the upwards scroll speed of
; the screen when it's below the point where the screen "locks" vertical
; scrolling. Since this is normally at the bottom of a level where the
; screen can't scroll any further down, it can only really get used in
; vertical levels.
DATA_00F6A7:
	dw $FFFD,$0005,$FFFA

; Vertical limits for scrolling the screen. The first two bytes are the
; highest distance the screen can scroll upwards; essentially, it's the top
; of the level. The second two are the highest distance the screen can
; scroll upwards... when the screen is stationary or moving downwards.
; Recommended to keep it identical to the first two bytes. The third entry
; is where the screen's vertical scrolling locks in a level with the "no
; vertical scroll unless flying/climbing/etc." option. The screen can
; actually still scroll vertically if it goes below this point, but it can't
; scroll up past it unless one of the special conditions is met.
DATA_00F6AD:
	dw $0000,$0000,$00C0

; 16-bit values for the maximum X position the game should move the static
; camera region towards when the screen is scrolling in the direction Mario
; is facing. They're used to position the camera slightly in front of where
; Mario is running. The first is for moving left, the second is for moving
; right.
DATA_00F6B3:
	dw $0090,$0060,$0000,$0000
	dw $0000,$0000

DATA_00F6BF:
	dw $0000,$FFFE,$0002,$0000

; How quickly the screen scrolls horizontally when "catching up" to Mario
; while he's walking around normally. The first two bytes are right, while
; the second are left.
DATA_00F6C7:
	dw $FFFE,$0002

DATA_00F6CB:
	dw $0000,$0020

DATA_00F6CF:
	dw $00D0,$0000,$0020,$00D0

DATA_00F6D7:
	dw $0001,$FFFF

; Level camera handling routine. This routine handles camera movement with
; the player. $00F713 - Horizontal scroll handler in horizontal levels.
; $00F766 - Horizontal scroll handler in vertical levels. $00F7F4 - Vertical
; scroll handler, for both horizontal and vertical levels. $00F8AB -
; Subroutine to handle scrolling the screen in the direction the player is
; moving, for shifting the screen slightly ahead. $00F79D - Handler for
; scrolling Layer 2 (mainly background), which determines the scrolling rate
; in relation with layer 1.
Main:
	PHB				;\Save bank into stack
	PHK				;|
	PLB				;/
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo
	SEC
#LM170Hijack_VRAMRearrangement7:
	SBC.w #$000C
	STA.w !RAM_SMW_Camera_RelativePositionNeededToScrollScreenRightLo
	CLC				;\Create right scroll line from center.
	ADC.w #$0018			;|
	STA.w !RAM_SMW_Camera_RelativePositionNeededToScrollScreenLeftLo	;/
	LDA.w !RAM_SMW_Misc_Layer1XPosLo	;\Make previous screen position up to date
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|with current frame.
	LDA.w !RAM_SMW_Misc_Layer1YPosLo	;|
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;/
	LDA.w !RAM_SMW_Misc_Layer2XPosLo	;\Make previous layer 2 position update
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo	;|with current frame.
	LDA.w !RAM_SMW_Misc_Layer2YPosLo	;|
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo	;/
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	;\If vertical level = false, skip
	LSR				;|
	BCC.b CODE_00F70D		;/
	JMP.w CODE_00F75C		;>Vertical level code

CODE_00F70D:
	LDA.w #$00C0			;>The lowest Y position the screen is allowed to scroll down in horizontal levels.
	JSR.w CODE_00F7F4		;>Handle vertical scrolling.
	LDY.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting	;\if horizontal scroll is disabled, skip to a jump to layer 2 scrolling
	BEQ.b CODE_00F75A		;/
	LDY.b #$02			;>default Y = #$02
	LDA.b !RAM_SMW_Player_XPosLo	;\$00 and A = Mario's x position on-screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	CMP.w !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo	;\If mario is right side of the static camera region (right side of the area
	BPL.b CODE_00F728		;/that doesn't scroll the screen horizontally), leave Y = #$02
	LDY.b #$00			;>Otherwise, rewrite Y = #$00
CODE_00F728:
	STY.b !RAM_SMW_Camera_Layer1ScrollingDirection	;\Set scrolling direction
	STY.b !RAM_SMW_Camera_Layer2ScrollingDirection	;/
	SEC				;\Find distance between mario and the center of the static cam region
	SBC.w !RAM_SMW_Camera_RelativePositionNeededToScrollScreenRightLo,y	;|
	BEQ.b CODE_00F75A		;/>if zero, skip
	STA.b !RAM_SMW_Misc_ScratchRAM02	;>Store distance into $02
	EOR.w DATA_00F6A3,y		;>Invert if mario is on right side (due to subtracting by a bigger value = negative)
	BPL.b CODE_00F75A		;>If positive, skip
	JSR.w CODE_00F8AB
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\Distance from the scroll lines to mario
	CLC				;|going from the left edge of the screen...
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;/
	BPL.b CODE_00F746		;>if not past the left edge, good.
	LDA.w #$0000
CODE_00F746:
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	LDA.b !RAM_SMW_Camera_LastScreenHoriz
	DEC
	XBA
	AND.w #$FF00
	BPL.b CODE_00F754
	LDA.w #$0080
CODE_00F754:
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	BPL.b CODE_00F75A
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
CODE_00F75A:
	BRA.b CODE_00F79D		;>Go to layer 2 scrolling

CODE_00F75C:
	LDA.b !RAM_SMW_Camera_LastScreenVert	;>Last screen of vertical level
	DEC				;>Minus 1
	XBA				;>Screen number is actually the high byte of screen position.
	AND.w #$FF00			;>Ignore low byte
	JSR.w CODE_00F7F4		;>Handle vertical scrolling
	LDY.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting	;\If horizontal scroll is disabled,
	BEQ.b CODE_00F79D		;/skip (go to layer 2 scrolling)
	LDY.b #$00			;>default Y = #$00
	LDA.b !RAM_SMW_Player_XPosLo	;\$00 and A = mario's x position on-screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	CMP.w !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo	;\If mario is left side of the static camera region (between 2 lines that moves camera left or right)
	BMI.b CODE_00F77B		;/then branch (leaving Y = #$00)
	LDY.b #$02			;>Y=#$02 if mario is on right side
CODE_00F77B:
	SEC				;\$02 = distance between the middle of the static cam region and mario
	SBC.w !RAM_SMW_Camera_RelativePositionNeededToScrollScreenRightLo,y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	EOR.w DATA_00F6A3,y		;>Invert if mario is right side of middle of the static camera region (due to the fact that subtract by bigger = negative)
	BPL.b CODE_00F79D		;>Go to layer 2 scrolling
	JSR.w CODE_00F8AB
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;>Load distance
	CLC				;\..going right from left edge of screen
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;/
	BPL.b CODE_00F793		;>if not past left edge of screen, branch
	LDA.w #$0000			;>Load #$0000 to prevent screen from scrolling past left edge of level.
CODE_00F793:
	CMP.w #$0101			;\Is nintendo stupid? Because you load a fixed value, compare it to a fixed
	BMI.b CODE_00F79B		;/means that the branch will not change at all.
	LDA.w #$0100			;>The furthest right the screen can scroll rightwards
CODE_00F79B:
	STA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;>Store screen position (this is how Mario moves the screen horizontally, vertical levels only)
; Code that handles the Layer 2 horizontal scroll settings (LM's "Layer 2
; (BG) Scrolling Rate").
CODE_00F79D:
if !Define_SMW_LunarMagicLevels == !TRUE
	JML.l SMW_LunarMagicLevels_ScrollLayer2	;\ Both axes, for every setting Lunar Magic
	NOP					;/ knows (Config/LunarMagicLevels.asm)
else
	LDY.w !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting	;\if horizontal scrolling layer 2 is clear (none), make it scroll with the screen
	BEQ.b CODE_00F7AA		;/
endif
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;>A = screen x position
	DEY				;\>Lower $1413 index for type of scrolling (1-1=0)
	BEQ.b CODE_00F7A8		;/>if its zero, skip (constant) (Layer2Xpos = ScreenXPos)
	LSR
CODE_00F7A8:
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
; Code that handles the Layer 2 vertical scroll settings (LM's "Layer 2 (BG)
; Scrolling Rate").
CODE_00F7AA:
	LDY.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting	;\If vertical scrolling for layer 2 is clear (none), make it scroll with the screen
	BEQ.b CODE_00F7C2		;/(layer 2 y pos not set)
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;>A = screen Y position
	DEY				;>Lower $1414 index for checking for type of scrolling (1-1=0)
	BEQ.b CODE_00F7BC		;>if zero, skip  (constant) (Layer2Ypos = ScreenYPos)
	LSR				;>Layer2Ypos = ScreenYpos/2
	DEY				;>lower $1414 index for checking for type of scrolling (2-2=0)
	BEQ.b CODE_00F7BC		;>if zero, skip (variable)
	LSR				;\This is a slower scrolling for vertical layer 2,
	LSR				;|Layer2Ypos = ScreenYpos/16
	LSR				;|
	LSR				;/
CODE_00F7BC:
	CLC				;\Offset the layer 2 from layer 1 Y pos (mainly noticeable with inital Y pos)
	ADC.w !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo	;/
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo	;>set Layer 2 y position.
CODE_00F7C2:
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;\Find distance on how much the screen scrolled horizontally
	SEC				;|current frame from its previous frame.
	SBC.w !RAM_SMW_Misc_Layer1XPosLo	;|
	STA.w !RAM_SMW_Misc_Layer1XDisp	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;\Same as above, but for vertical scrolling.
	SEC				;|
	SBC.w !RAM_SMW_Misc_Layer1YPosLo	;|
	STA.w !RAM_SMW_Misc_Layer1YDisp	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo	;\Find distance on how much layer 2 has scrolled horizontally
	SEC				;|current frame from its previous frame (remember that moving left
	SBC.w !RAM_SMW_Misc_Layer2XPosLo	;|is a positive direction for layer 2).
	STA.w !RAM_SMW_Misc_Layer2XDisp	;/
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo	;\Same as above but for vertical scrolling
	SEC				;|(remember that moving up is a positive direction)
	SBC.w !RAM_SMW_Misc_Layer2YPosLo	;|
	STA.w !RAM_SMW_Misc_Layer2YDisp	;/
#LM170Hijack_VRAMRearrangement8:
	LDX.b #$07			;>X = #$07 for loop
CODE_00F7EA:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x	;\Make previous layer position up to date with
	STA.w !RAM_SMW_Misc_Layer1XPosLo,x	;/current frame (Moves "interactive position" (like the edge of screen))
	DEX				;\Next index for loop (until X = #$FF)
	BPL.b CODE_00F7EA		;/
	PLB				;>Restore bank
	RTL

CODE_00F7F4:
	LDX.w !RAM_SMW_Flag_Layer1VerticalScrollLevelSetting	;\Allow vertical scrolling when enabled
	BNE.b CODE_00F7FA		;/
	RTS

CODE_00F7FA:
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDY.b #$00			;>default Y = #$00
	LDA.b !RAM_SMW_Player_YPosLo	;\$00 = Mario Y pos on-screen
	SEC				;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	CMP.w #$0070			;\If mario positioned above to make screen
	BMI.b CODE_00F80C		;/scroll up, leave Y = #$00
	LDY.b #$02			;>Otherwise change it to #$02
CODE_00F80C:
	STY.b !RAM_SMW_Camera_Layer1ScrollingDirection	;\Set scrolling direction (#$00 is up,
	STY.b !RAM_SMW_Camera_Layer2ScrollingDirection	;/#$02 = down)
	SEC				;\Subtract by #$0064 if up, #$007C if down.
	SBC.w DATA_00F69F,y		;/
	STA.b !RAM_SMW_Misc_ScratchRAM02	;>Save adjusted Mario's Y position into $02
	EOR.w DATA_00F6A3,y		;>Invert value if going down (so screen doesn't scroll down if you're above the screen)
	BMI.b CODE_00F81F		;>Since in unsigned interger, -1 in a 16-bit is #$FFFF, which is very far below the screen.
	LDY.b #$02			;>Otherwise set Y index to #$02
	STZ.b !RAM_SMW_Misc_ScratchRAM02	;>and clear Y position value in $02
CODE_00F81F:
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\If Y position value is negative...
	BMI.b CODE_00F82A		;/then don't clear free vertical scroll
	LDX.b #$00			;\Clear free vertical scroll (making the
	STX.w !RAM_SMW_Flag_ScrollUpToPlayer	;/screen wait till mario is on a higher platform).
	BRA.b CODE_00F883

CODE_00F82A:
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_Player_WallWalkStatus	;\If compleatly wall running, skip
	CMP.b #$06			;|
	BCS.b CODE_00F845		;/
	LDA.w !RAM_SMW_Flag_DisplayYoshisWings	; \ If winged Yoshi...
	LSR
	ORA.w !RAM_SMW_Timer_WaitBeforeCapeFlightBegins
	ORA.b !RAM_SMW_Player_ClimbingFlag	; | ...or climbing
	ORA.w !RAM_SMW_Timer_InflateFromPBalloon
	ORA.w !RAM_SMW_Flag_PlayerInLakitusCloud
	ORA.w !RAM_SMW_Camera_BounceOffSpringFlag
CODE_00F845:
	TAX				;>Save it to X
	REP.b #$20			; A->16
	BNE.b CODE_00F869		;>Then skip scrolling upwards
	LDX.w !RAM_SMW_Player_RidingYoshiFlag	;>Rewrite X with on yoshi flag
	BEQ.b CODE_00F856		;>if not on yoshi, skip
	LDX.w !RAM_SMW_Yoshi_YoshiHasWings	; \ Branch if 141E >= #$02
	CPX.b #$02
	BCS.b CODE_00F869
CODE_00F856:
	LDX.b !RAM_SMW_Player_SwimmingFlag	;\If swimming, allow screen scroll up
	BEQ.b CODE_00F85E		;/
	LDX.b !RAM_SMW_Player_InAirFlag	;\If air flag is set, allow screen scroll up
	BNE.b CODE_00F869		;/(with ground check)
CODE_00F85E:
	LDX.w !RAM_SMW_Flag_Layer1VerticalScrollLevelSetting	;\If vertical scroll settings -1 = #$00
	DEX				;|skip
	BEQ.b CODE_00F875		;/
	LDX.w !RAM_SMW_Flag_EnableVerticalScroll	;\If vertical scroll enable flag is set,
	BNE.b CODE_00F875		;/then allow scrolling vertically
CODE_00F869:
	STX.w !RAM_SMW_Flag_EnableVerticalScroll	;>used when air flag is set.
	LDX.w !RAM_SMW_Flag_EnableVerticalScroll	;\Here we go again with checking vertical scroll settings.
	BNE.b CODE_00F881		;/
	LDY.b #$04			;>Rewrite Y to be #$04 (#$00 would be scroll up, #$02 scroll down,
	BRA.b CODE_00F881		;#$04 = misc scrolling the screen up).

CODE_00F875:
	LDX.w !RAM_SMW_Flag_ScrollUpToPlayer
	; Change from D0 to 80 to activate free vertical scrolling. This will
	; bypass the routine that checks whether Mario is standing on solid ground
	; or not (RAM address $72) and sets the scrolling flag accordingly. The
	; camera follows Mario instead of waiting for him to land on something.
	BNE.b CODE_00F881
	LDX.b !RAM_SMW_Player_InAirFlag	;\while waiting till mario is on platform, if mario is in the air,
	BNE.b Return00F8AA		;/return
	INC.w !RAM_SMW_Flag_ScrollUpToPlayer	;>Otherwise make it scroll up
CODE_00F881:
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;>Mario's altered Y position on-screen
CODE_00F883:
	SEC				;\subtract by #$FFFD for scrolling up, #$0005 for down,
	SBC.w DATA_00F6A7,y		;/and #$FFFA for misc.
	EOR.w DATA_00F6A7,y		;>#%1111111111111101 for up, #%0000000000000101 for down, #%1111111111111010 for misc.
	ASL				;>Left shift for carry
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;Load adjusted Y pos into A
	BCS.b CODE_00F892		;>If the leftshift of bit 15 is set, branch
	LDA.w DATA_00F6A7,y
CODE_00F892:
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CMP.w DATA_00F6AD,y		;>Compare with #$00, unless if misc upwards scrolling, #$00C0
	BPL.b CODE_00F89D		;>If below that point scroll the screen downwards.
	LDA.w DATA_00F6AD,y
CODE_00F89D:
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LDA.b !RAM_SMW_Misc_ScratchRAM04	;\Last screen for vertical level check
	CMP.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	BPL.b Return00F8AA		;/If screen positioned above the bottommost, allow downscroll
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;>otherwise, prevent scrolling past the last screen in vertical level.
	STZ.w !RAM_SMW_Flag_EnableVerticalScroll		; Optimization: This affects unused RAM $7E13F2
Return00F8AA:
	RTS

CODE_00F8AB:
	LDY.w !RAM_SMW_Flag_LRScrollFlag	;\If L/R scrolling, return
	BNE.b Return00F8DE		;/
	SEP.b #$20			; A->8
	LDX.w !RAM_SMW_Player_FacingDirectionX2	;>Load player facing direction
	REP.b #$20			; A->16
	LDY.b #$08			;>rewrite Y with #$08
	LDA.w !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo	;\>Scroll line that moves the screen left/right
	CMP.w DATA_00F6B3,x		;|compare with #$0090, #$0060, #$0000 (more #$0000
	BPL.b CODE_00F8C3		;/ahead), if scroll line to the right, branch
	LDY.b #$0A			;>Otherwise replace Y with #$0A
CODE_00F8C3:
	LDA.w DATA_00F6C7-$08,y		;>Load #$0000, #$FFFE, #$0002, $0000
	EOR.b !RAM_SMW_Misc_ScratchRAM02	;>invert by distance between mario and the scroll lines
	BPL.b Return00F8DE		;>if positive, return
	LDA.w DATA_00F6BF,x		;\Same as above but for a different index
	EOR.b !RAM_SMW_Misc_ScratchRAM02	;|
	BPL.b Return00F8DE		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\Distance added by #$00D0, #$0000, #$0020, or #$00D0
	CLC				;|
	ADC.w DATA_00F6D7-$08,y		;/
	BEQ.b Return00F8DE		;>if zero return
	STA.b !RAM_SMW_Misc_ScratchRAM02	;>based on table above to define the distance between mario and the lines.
	STY.w !RAM_SMW_Camera_LRScrollMoveFlag	;>Camera adjustments of looking ahead
Return00F8DE:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeCapeSwingOrNetPunch(Address)
namespace SMW_InitializeCapeSwingOrNetPunch
%InsertMacroAtXPosition(<Address>)

; Cape Collision X (Horizontal) Offsets: Two bytes for right and left, on
; ground and in air. The first two sets are for when Mario is on the ground
; while spinning ($0C,$00- right; $F4,$FF left), and the second two are
; while he is in the air ($08,$00 - right; $F8,$FF - left) The first byte in
; each set determines the position per pixel, the second sets whether it is
; in front or behind him ($FF is behind, $00 is in front) Use $FF-$80 for
; the behind byte($FF), and $00-$79 for the in front byte ($00) This does
; not effect the image offsets.
DATA_00D034:
	dw $000C,$FFF4,$0008,$FFF8

; Cape Collision Y (Vertical) Offsets: 2 bytes for right and left, on ground
; and in air. The first two sets are for when Mario is on the ground while
; spinning ($10,$00 - right; $10,$00 - left), and the second two are while
; he is in the air ($02,$00 - right; $02,$00 - left) The first byte in each
; set determines the position per pixel, the second sets whether it is above
; him or below him ($FF is below his feet, $00 is from his feet up) Use
; $FF-$80 for the below byte ($FF), and $00-$79 for the above byte ($00)
; This does not effect the image offsets.
DATA_00D03C:
	dw $0010,$0010,$0002,$0002

; Routine that does the actual calculation for cape-interaction. Uses the
; two tables at $00:D034 and $00:D03C.
Main:
	LDY.b #$01			;\ maybe setting a flag?
	STY.w !RAM_SMW_Flag_CapeToSpriteInteraction	;|
	ASL				;|
	TAY				;/
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w DATA_00D034,y
	STA.w !RAM_SMW_Player_CapeHitboxXLo	; |Set cape<->sprite collision coordinates
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.w DATA_00D03C,y
	STA.w !RAM_SMW_Player_CapeHitboxYLo
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode11_LoadSublevel(Address)
namespace SMW_GameMode11_LoadSublevel
%InsertMacroAtXPosition(<Address>)

; This is the code that is executed by game mode 03 (Load title). Game mode
; 11 (Mario Start) also uses parts of this code. The shared parts starts at
; $0096D5. - $0096C4: music bank used for the Title Screen. 0E = Overworld
; Music, 48 = Level Music, 59 = Ending Music. - $0096C7: title screen (level
; C7) song ID. - $0096CC: title screen level number + $24. - $009724: intro
; screen (level C5) music. - $009725: changing it to [9C FB 1D] will allow
; you to change the music for the intro via Lunar Magic. - $009737: Bowser
; phase 1 song ID.
GameMode03Entry:
	STZ.w !REGISTER_IRQNMIAndJoypadEnableFlags	; NMI, V/H Count, and Joypad Enable
	JSR.w SMW_InitializeFirst8KBOfRAM_Main	; Clear out $0000-$1FFF and $7F837B/D.
	LDX.b #$07
	LDA.b #$FF
CODE_0096B8:
	STA.w !RAM_SMW_Misc_CurrentlyLoadedSpriteGraphicsFiles,x
	DEX
	BPL.b CODE_0096B8
	LDA.w !RAM_SMW_Misc_IntroLevelFlag
	BNE.b CODE_0096CB
	JSR.w SMW_HandleSPCUploads_UploadOverworldMusicBank
	LDA.b #!Define_SMW_OverworldMusic_TitleScreen	;\ Set title screen music
	STA.w !RAM_SMW_IO_MusicCh1	;/
CODE_0096CB:
	LDA.b #!Define_SMW_LevelID_TitleScreenSublevel
	LDY.b #!Define_SMW_Overworld_MainMap
CODE_0096CF:
	STA.w !RAM_SMW_Misc_IntroLevelFlag
	STY.w !RAM_SMW_Overworld_MarioMap
Main:
#SA1Pack_OptimizeThisRoutine1:
	STZ.w !REGISTER_IRQNMIAndJoypadEnableFlags	; NMI, V/H Count, and Joypad Enable
	JSR.w SMW_DamagePlayer_DisableButtons	; Disable input.
	LDA.w !RAM_SMW_Counter_SublevelsEntered			;\ Optimization: What is the point of this?
	BNE.b CODE_0096E9					;| Is this a remnant of the idea for having the titlescreen show the overworld?
	LDA.w !RAM_SMW_Flag_ShowPlayerStart			;|
	BEQ.b CODE_0096E9					;|
	JSL.l SMW_LoadOverworldLayer1AndEvents_Main		;/
CODE_0096E9:
	STZ.w !RAM_SMW_Flag_DisableLayer3Scroll
	STZ.w !RAM_SMW_Pointer_CurrentLevelEndProcess	; disable mario actions from the OW
	LDA.b #$50			;\ Initialize the end-level drumroll timer.
	STA.w !RAM_SMW_Timer_WaitBeforeScoreTally	;/
	JSL.l SMW_SpecifySublevelToLoad_Main	; Load primary header data.
	LDX.b #$07
CODE_0096FA:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo,x
	STA.w !RAM_SMW_Misc_Layer1XPosLo,x
	DEX
	BPL.b CODE_0096FA
#SA1Pack_OptimizeThisRoutine2:
	JSR.w SMW_HandleSPCUploads_CODE_008134	; Upload the level's music.
	JSR.w SMW_InitializeLevelRAM_Main	; Initialize RAM, prepare Mario's entrance animation.
#LM300Hijack_HorizontalScrollFixAndInitialFaceLeft:
	LDA.b #$20			;\ Set maximum screen number to 0x20.
	STA.b !RAM_SMW_Camera_LastScreenHoriz	;/
	JSR.w CODE_00A796		; Get initial Layer 2 scroll positions.
	INC.w !RAM_SMW_Flag_ScrollUpToPlayer	; Enable "vertical scroll at will" by default.
	JSL.l SMW_HandleStandardLevelCameraScroll_Main	; Reset layer positions.
	JSL.l SMW_LoadSublevel_Main	; Load level data.
	LDA.w !RAM_SMW_Misc_IntroLevelFlag	;\ Branch if there is not OW override set
	BEQ.b CODE_009728		;/
	CMP.b #!Define_SMW_LevelID_IntroSublevel	;\ Branch if not intro level
	BNE.b CODE_009740		;/
	LDA.b #!Define_SMW_LevelMusic_Welcome	;\ Set intro level music
	STA.w !RAM_SMW_Misc_MusicRegisterBackup	;/
CODE_009728:
	LDA.w !RAM_SMW_Misc_MusicRegisterBackup	;\
	CMP.b #$40			;| If music is playing (question: most values covered by the BCS are unused, so why in the world did they start with 40? Possibly extra music was planned?
	BCS.b CODE_00973B		;/
	LDY.w !RAM_SMW_Misc_NMIToUseFlag	;\
	CPY.b #$C1			;| Branch if mode is not browser fight
	BNE.b CODE_009738		;/
	LDA.b #!Define_SMW_LevelMusic_FightBowser2
CODE_009738:
	STA.w !RAM_SMW_IO_MusicCh1
CODE_00973B:
	AND.b #$BF			;\ Bit 6 must be removed from the music number (?)
	STA.w !RAM_SMW_Misc_MusicRegisterBackup	;/
CODE_009740:
	STZ.w !RAM_SMW_Mirror_ScreenDisplayRegister			; Note: !ScreenDisplayRegister_MinBrightness00
	STZ.w !RAM_SMW_Misc_MosaicDirection	; Default mosaic effect
	INC.w !RAM_SMW_Misc_GameMode	; Move on
#SA1Pack_OptimizeThisRoutine3:
	JMP.w SMW_GameMode00_LoadNintendoPresents_Mode04Finish	; Re-enable NMI and auto-joypad read.
namespace off
	%SetDuplicateOrNullPointer(SMW_GameMode11_LoadSublevel_GameMode03Entry, SMW_GameMode03_LoadTitleScreenSublevel_Main)
endmacro

macro ROUTINE_RT01_SMW_GameMode11_LoadSublevel(Address)
namespace SMW_GameMode11_LoadSublevel
%InsertMacroAtXPosition(<Address>)

CODE_00A796:
if !Define_SMW_LunarMagicLevels == !TRUE
	JML.l SMW_LunarMagicLevels_InitialOffset	;\ The whole routine, for every setting Lunar
	NOP						;/ Magic knows (Config/LunarMagicLevels.asm)
else
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
endif
	BEQ.b CODE_00A7B9
	DEY
	BNE.b CODE_00A7A7
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	BRA.b CODE_00A7B6

CODE_00A7A7:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	LSR
	DEY
	BEQ.b CODE_00A7AF
	LSR
	LSR
CODE_00A7AF:
	EOR.w #$FFFF
	INC
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
CODE_00A7B6:
	STA.w !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo
CODE_00A7B9:
	LDA.w #$0080			;\Initalize position of static
	STA.w !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo	;/camera region
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GameMode12_PrepareLevel(Address)
namespace SMW_GameMode12_PrepareLevel
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_ClearLayer3Tilemap_Main	; gah, stupid keyboard >_<
	JSR.w SMW_DamagePlayer_DisableButtons
#LM170Hijack_VRAMRearrangement6:
	STZ.w !RAM_SMW_Flag_UploadLoadScreenLettersToVRAM
	JSR.w SMW_SetStandardPPUSettings_Main
	JSR.w SMW_InitializeStatusBarTilemap_Main
	JSL.l SMW_InitializeLevelLayer1And2Tilemaps_Main	; ->here
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	BPL.b PrepareNormalLevel
	JSR.w PrepareMode7Level		; Working on this routine
	BRA.b CODE_00A5CF

PrepareNormalLevel:
	JSR.w SMW_UploadGraphicsFiles_Main
	JSR.w SMW_BufferPalettesRoutines_Levels
#LM000Hijack_CustomLevelPalettes:
if !Define_SMW_LevelCustomPalettes == !TRUE
	; The same four bytes as the JSL below. The stub copies the loaded
	; level's own palette over the mirror the buffering just built -- when
	; its pointer-table row holds one -- and tail-calls InitializeLayer3RAM,
	; whose RTL returns here. This is the one palette-buffering caller that
	; is a level being prepared, which is what scopes the copy: the
	; cutscenes, "The End" and the enemy rollcall stay stock, and the Mode 7
	; rooms branched away above. See Config/LevelCustomPalettes.asm.
	JSL.l SMW_LevelCustomPalettes_Apply
else
	JSL.l InitializeLayer3RAM
endif
	JSR.w SMW_InitializeLevelLayer3_Main
	JSR.w SMW_InitializeLevelTileAnimations_Main
	JSR.w SMW_SetupHDMAWindowingEffects_EndHDMA
	JSR.w CODE_009860
CODE_00A5CF:
	JSR.w SMW_UpdateEntirePalette_Main
	JSR.w SMW_SetKeepGameModeActiveTimer_OneFrame
	JSR.w SMW_UpdateStatusBarCounters_Main
	REP.b #$30			; AXY->16
	PHB
	LDX.w #!RAM_SMW_Palettes_PaletteMirror
	LDY.w #!RAM_SMW_Palettes_CopyOfPaletteMirror
#LM000Hijack_Unknown00A5E1:
	LDA.w #$01EF
	MVN !RAM_SMW_Palettes_CopyOfPaletteMirror>>16,!RAM_SMW_Palettes_PaletteMirror>>16
	PLB
	LDX.w !RAM_SMW_Palettes_BackgroundColorLo
	STX.w !RAM_SMW_Palettes_CopyOfBackgroundColorLo
	SEP.b #$30			; AXY->8
if !SMW_LevelCode_InitWanted == !TRUE
	; The same six bytes as the two JSRs. The level's own init code runs
	; once the level is prepared, and the stub then makes both displaced
	; calls in turn, each coming back through the RTL below. See
	; Config/LevelCode.asm.
	JML.l SMW_LevelCode_Init
LevelCodeLanding:
	RTL				;> The RTS return the stub pushes for the calls it displaced
	NOP				;> The sixth byte, never reached
else
LevelCodeLanding:			;> Named either way, so the stub assembles; only reached above
	JSR.w CODE_00919B
	JSR.w SMW_CompressOAMTileSizeBuffer_Main
endif
LevelCodeReturn:
	JMP.w SMW_GameMode00_LoadNintendoPresents_CODE_0093F4
namespace off
endmacro

macro ROUTINE_RT01_SMW_GameMode12_PrepareLevel(Address)
namespace SMW_GameMode12_PrepareLevel
%InsertMacroAtXPosition(<Address>)

CODE_00919B:
	LDA.b !RAM_SMW_Player_CurrentState	;\
	CMP.b #!Define_SMW_PlayerState0A_NoYoshiCutscene	;| If performing a No Yoshi entrance, prepare the scene.
	BNE.b CODE_0091A6		;|
	JSR.w SMW_GameMode14_InLevel_HandlePlayerState	;/
	BRA.b Return0091B0

CODE_0091A6:
	LDA.w !RAM_SMW_Counter_SublevelsEntered	;\
	BNE.b Return0091B0		;| Reset coin counter for the green star block only when entering the main level (not sublevels).
	LDA.b #$1E			;| Amount of coins needed to get 1up from green star block.
	STA.w !RAM_SMW_Counter_GreenStarBlock	;/
Return0091B0:
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_GameMode12_PrepareLevel(Address)
namespace SMW_GameMode12_PrepareLevel
%InsertMacroAtXPosition(<Address>)

PrepareMode7Level:
	LDA.b #!ScreenDisplayRegister_MaxBrightness0F
	STA.w !RAM_SMW_Mirror_ScreenDisplayRegister	; Set brightness to full (RAM mirror)
	STZ.w !RAM_SMW_Mirror_MosaicSizeAndBGEnable				; Note: !MosaicSizeAndBGEnable_PixelSize1x1
	JSR.w SMW_GameModeXX_FadeInOrOut_GMMosaic	; Run mosaic
	LDA.b #$20			;\
	STA.b !RAM_SMW_Misc_M7AngleLo	;| Set X and Y scale to 1.0
	STA.b !RAM_SMW_Misc_M7AngleHi	;/
	STZ.w !RAM_SMW_ShakingLayer1DispYLo
	JSR.w SMW_ClearLayer3Tilemap_Main						; Optimization: This is called earlier in the code.
	LDA.b #$FF
	STA.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad
	JSL.l UploadTiltingPlatformTilemap
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_009801
	JSR.w PrepareNonIggyLarryRoom
	LDY.w !RAM_SMW_Misc_CurrentlyActiveBoss
	CPY.b #$03
	BCC.b CODE_0097F1
	BNE.b CODE_00983B
	LDA.b #$18
	BRA.b CODE_0097FC

CODE_0097F1:
	LDA.b #$03
	STA.w !RAM_SMW_Player_CurrentLayerPriority	; Disable player interaction with sprites
	LDA.b #$C8			;\
	STA.b !RAM_SMW_Mirror_OAMAddressLo	;/ OAM slot 100 gets highest priority
	LDA.b #$12
CODE_0097FC:
	DEC.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad	; ObjectTileset = !ObjTileset_RoyMortonLudwig
	BRA.b CODE_00983D

CODE_009801:
	JSR.w SMW_BufferPalettesRoutines_IggyLarryPlatform
	JSR.w SMW_SetupHDMAWindowingEffects_CODE_0092A8
	LDX.b #$50			;\ Y Position of floor
	JSR.w CODE_009A3D		;/
	REP.b #$20			; A->16
	LDA.w #$0050			;\
	STA.b !RAM_SMW_Player_XPosLo	;| Player starting position
	LDA.w #$FFD0			;| (80, -48)
	STA.b !RAM_SMW_Player_YPosLo	;/
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo	;\
	STZ.w !RAM_SMW_Misc_Layer1XPosLo	;| Camera starting position
	LDA.w #$FF90			;| (0, -112)
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|
	STA.w !RAM_SMW_Misc_Layer1YPosLo	;/
	LDA.w #$0080			;\
	STA.b !RAM_SMW_Mirror_M7CenterXPosLo	;| Mode 7 center point
	LDA.w #$0050			;| (256, 208)
	STA.b !RAM_SMW_Mirror_M7CenterYPosLo	;/
	LDA.w #$0080			;\
	STA.b !RAM_SMW_Mirror_M7XPosLo	;| Mode 7 scroll position
	LDA.w #$0010			;| (128, 16)
	STA.b !RAM_SMW_Mirror_M7YPosLo	;/
	SEP.b #$20			; A->8
CODE_00983B:
	LDA.b #$13
CODE_00983D:
	STA.w !RAM_SMW_Graphics_LevelSpriteGraphicsSetting
	JSR.w SMW_UploadGraphicsFiles_Main
	LDA.b #$11
	STA.w !REGISTER_MainScreenWindowMask	; Window Mask Designation for Main Screen
	STZ.w !REGISTER_SubScreenLayers	; Sub Screen Designation
	STZ.w !REGISTER_SubScreenWindowMask	; Window Mask Designation for Sub Screen
	LDA.b #$02
	STA.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings	; Enable Window 1 on BG1, OBJ, & Color Window
	LDA.b #$32
	STA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings	; Color Window is inverted for lava
	LDA.b #$20			;\ Turn on Color Window for sub screen
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings	;/
	JSR.w SMW_InitializeStatusBarTilemap_Main
	JSR.w SMW_ManipulateMode7Image_Main
CODE_009860:
	JSL.l SMW_PlayerGFXRt_Main
	JSR.w SMW_UpdateCurrentPlayerPositionRAM_Main
	JSR.w SMW_GameMode14_InLevel_HandlePlayerState
	STZ.b !RAM_SMW_Player_YSpeed	; Y speed = 0
	JSL.l SMW_ProcessNormalSprites_Main
	JSL.l !RAM_SMW_Sprites_ResetSpriteOAMRt
	RTS
namespace off
endmacro

macro ROUTINE_RT03_SMW_GameMode12_PrepareLevel(Address)
namespace SMW_GameMode12_PrepareLevel
%InsertMacroAtXPosition(<Address>)

PrepareNonIggyLarryRoom:
	STZ.b !RAM_SMW_Player_YPosHi
	REP.b #$20			; A->16
	LDA.w #$0020
	STA.b !RAM_SMW_Player_XPosLo
	STZ.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STZ.w !RAM_SMW_Misc_Layer1XPosLo
	STZ.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STZ.w !RAM_SMW_Misc_Layer1YPosLo
	LDA.w #$0080			;\
	STA.b !RAM_SMW_Mirror_M7CenterXPosLo	;| Pivot point of M7 bosses
	LDA.w #$00A0			;| (256, 288)
	STA.b !RAM_SMW_Mirror_M7CenterYPosLo	;/
	SEP.b #$20			; A->8
	JSR.w SMW_BufferPalettesRoutines_ReznorAndMode7KoopaBosses
	JSL.l SMW_ProcessNormalSprites_Main	; Run normal sprite routines
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	LSR
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDX.b #$D0
	LDA.b #$B0
else
	LDX.b #$C0			; Y position of floor
	LDA.b #$A0			; Y position of Mario
endif
	BCC.b CODE_00995B
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting	;\ Bowser has no ceiling or lava
	JMP.w CODE_009A17		;/

CODE_00995B:
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBoss
	AND.w #$00FF
	ASL
	TAX
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDY.w #$0300
else
	LDY.w #$02C0			; ceiling offset for Morton & Roy
endif
	LDA.w SMW_PlayerState00_Normal_DATA_00F8E8,x
	BPL.b CODE_009970		; if not Reznor, branch
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDY.w #$FBC0
else
	LDY.w #$FB80			; ceiling offset for Reznor
endif
CODE_009970:
	CMP.w #$0012			;\ if not Ludwig, branch
	BNE.b CODE_009978		;/
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDY.w #$0360
else
	LDY.w #$0320			; ceiling offset for Ludwig
endif
CODE_009978:
	STY.b !RAM_SMW_Misc_ScratchRAM00
	LDX.w #$0000
	LDA.w #$C05A			; $5AC0 = VRAM address of bridge tiles
CODE_009980:
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x	; Write location of top of bridge
	XBA
	CLC
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	ADC.w #$00C0
else
	ADC.w #$0080			; Y position of lava + ceiling
endif
	XBA
	STA.l SMW_StripeImageUploadTable[$42].LowByte,x	; Write location of top of lava
	XBA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	XBA
	STA.l SMW_StripeImageUploadTable[$84].LowByte,x	; Write location of ceiling
	LDA.w #$7F00			; 64 tiles (2 rows of 32)
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	STA.l SMW_StripeImageUploadTable[$43].LowByte,x
	STA.l SMW_StripeImageUploadTable[$85].LowByte,x
	LDY.w #$0010			; Write tiles in pairs (32 pairs of 2)
CODE_0099A9:
	LDA.w #$38A2			;\ Write bridge tiles
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x	;|
	INC				;|
	STA.l SMW_StripeImageUploadTable[$03].LowByte,x	;|
	LDA.w #$38B2			;|
	STA.l SMW_StripeImageUploadTable[$22].LowByte,x	;|
	INC				;|
	STA.l SMW_StripeImageUploadTable[$23].LowByte,x	;/
	LDA.w #$2C80			;\ Write lava tiles
	STA.l SMW_StripeImageUploadTable[$44].LowByte,x	;|
	INC				;|
	STA.l SMW_StripeImageUploadTable[$45].LowByte,x	;|
	INC				;|
	STA.l SMW_StripeImageUploadTable[$64].LowByte,x	;|
	INC				;|
	STA.l SMW_StripeImageUploadTable[$65].LowByte,x	;/
	LDA.w #$28A0			;\ Write brick ceiling tiles
	STA.l SMW_StripeImageUploadTable[$86].LowByte,x	;|
	INC				;|
	STA.l SMW_StripeImageUploadTable[$87].LowByte,x	;|
	LDA.w #$28B0			;|
	STA.l SMW_StripeImageUploadTable[$A6].LowByte,x	;|
	INC				;|
	STA.l SMW_StripeImageUploadTable[$A7].LowByte,x	;/
	INX
	INX
	INX
	INX
	DEY
	BNE.b CODE_0099A9
	TXA				;\ Advance to next screen
	CLC				;|
	ADC.w #$014C			;|
	TAX				;/
	LDA.w #$C05E			; $5EC0 = VRAM address of bridge tiles
	CPX.w #$0318			;\ Branch out when done
	BCS.b CODE_009A07		;/
	JMP.w CODE_009980		; Draw the second screen

CODE_009A07:
	LDA.w #$00FF			;\ Write sentinel
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x	;/
	SEP.b #$30			; AXY->8
	JSR.w SMW_LoadStripeImage_Sub
	LDX.b #$B0			; Y position of floor
	LDA.b #$90			; Y position of Mario
CODE_009A17:
	STA.b !RAM_SMW_Player_YPosLo
	JSR.w CODE_009A1F
	JMP.w SMW_SetupHDMAWindowingEffects_CODE_009283

; Writes the Map16 data for Ludwig/Morton/Roy's boss battle room. $009A40 is
; what tile the lava tiles in the Morton/Ludwig/Roy battles act like (by
; default: 05). Only Map16 page 00 is usable.
CODE_009A1F:
	LDY.b #$10			;\ 16 * 2 tiles of floor
	LDA.b #$32			;/
CODE_009A23:
	STA.l !RAM_SMW_Blocks_Map16TableLo+($01B0*$00),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($01B0*$01),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$00),x
	STA.l !RAM_SMW_Blocks_Map16TableHi+($01B0*$01),x
	INX
	DEY
	BNE.b CODE_009A23
	CPX.b #$C0			;\ Branch if not Ludwig, Roy, Morton, Reznor
	BNE.b Return009A4D		;/
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDX.b #$E0
else
	LDX.b #$D0			; Y position of lava collision
endif
CODE_009A3D:
	LDY.b #$10			;\ 16 * 2 tiles of lava
	LDA.b #$05			;/
CODE_009A41:
	STA.l !RAM_SMW_Blocks_Map16TableLo+($01B0*$00),x
	STA.l !RAM_SMW_Blocks_Map16TableLo+($01B0*$01),x
	INX
	DEY
	BNE.b CODE_009A41
Return009A4D:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeLevelTileAnimations(Address)
namespace SMW_InitializeLevelTileAnimations
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$E7
	TRB.b !RAM_SMW_Counter_LocalFrames
-:
#LM160Hijack_LevelExAnimations3:
	JSL.l SMW_LevelTileAnimations_Main
	JSR.w SMW_UploadLevelAnimations_Main
	INC.b !RAM_SMW_Counter_LocalFrames
	LDA.b !RAM_SMW_Counter_LocalFrames
	AND.b #$07
	BNE.b -
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameModeXX_FadeInOrOut(Address)
namespace SMW_GameModeXX_FadeInOrOut
%InsertMacroAtXPosition(<Address>)

; Change from 01 to 0F to stop fadeout on entering level, new area, and back
; to submap. (Use with $00:9F59)
DATA_009F2F:
	db $01,$FF

DATA_009F31:
	db $F0,$10

DATA_009F33:
	db !ScreenDisplayRegister_MaxBrightness0F,!ScreenDisplayRegister_MinBrightness00

UNK_009F35:
	db $00,$F0

; Fading/mosaic routine. Change $009F59 from D0 to 90 to eliminate all
; fadeouts. (use in conjunction with $009F2F). Mod note: I've heard that
; this one is buggy. Use on your own risk. $009F67 controls which layers are
; affected by the mosaic effect. Format: xxxx4321. The numbers present the
; layer numbers to add mosaic on. So 1 = Layer 1, 2 = Layer 2, etc.
; The two directions are a matched pair, and each one assumes the other ran
; first. A fade in steps the mosaic size down by $10 and the brightness up by
; $01; a fade out does the reverse. Both stop on the brightness alone, and
; fifteen steps carry it across its whole range -- so the size only lands back
; on 1x1 if it entered at 16x16, which is what the fade out leaves behind.
; Beginning a fade in from any other size leaves that much mosaic on layers 1
; and 2 for as long as the level lasts: the only other write to $2106 is the
; one the level's register setup makes before any of this runs.
MosaicFade:
	DEC.w !RAM_SMW_Timer_KeepGameModeActive	; \Exit unless the decrement went
	BPL.b Return009F6E		; /negative: one step every other frame.
	JSR.w SMW_SetKeepGameModeActiveTimer_OneFrame	; #$01 -> $0DB1
	LDY.w !RAM_SMW_Misc_MosaicDirection	;\
	LDA.w !RAM_SMW_Mirror_MosaicSizeAndBGEnable	;| Adjust mosaic size
	CLC				;|
	ADC.w DATA_009F31,y		;|
	STA.w !RAM_SMW_Mirror_MosaicSizeAndBGEnable	;/
CODE_009F4C:
	LDA.w !RAM_SMW_Mirror_ScreenDisplayRegister	;\
	CLC				;| Adjust brightness
	ADC.w DATA_009F2F,y		;|
	STA.w !RAM_SMW_Mirror_ScreenDisplayRegister	;/
	CMP.w DATA_009F33,y		; \Ends on the brightness reaching its limit;
	BNE.b CODE_009F66		; /the mosaic size is never tested.
GMMosaic:
	INC.w !RAM_SMW_Misc_GameMode	; Go to next game mode
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_Misc_GameMode
	CMP.b #!Define_SMW_GameMode03_LoadTitleScreenSublevel
	BNE.b +
	LDA.l !SRAM_SMAS_Global_RunningDemoFlag
	BEQ.b +
	JML.l SMAS_ResetToSMASTitleScreen_Main
+:
elseif ver_is_smasw_europe(!Define_Global_ROMToAssemble)
	LDA.l !SRAM_SMAS_Global_RunningDemoFlag
	BEQ.b +
	LDA.w !RAM_SMW_Misc_GameMode
	CMP.b #!Define_SMW_GameMode03_LoadTitleScreenSublevel
	BNE.b +
	JML.l SMAS_CopyOfResetToSMASTitleScreen_Main
+:
endif
	LDA.w !RAM_SMW_Misc_MosaicDirection	;\ Reverse direction of mosaic
	EOR.b #$01			;|
	STA.w !RAM_SMW_Misc_MosaicDirection	;/
CODE_009F66:
	LDA.b #!MosaicSizeAndBGEnable_Layer1|!MosaicSizeAndBGEnable_Layer2	;\ Apply the mosaic
	ORA.w !RAM_SMW_Mirror_MosaicSizeAndBGEnable	;| to BG1 and BG2 only
	STA.w !REGISTER_MosaicSizeAndBGEnable	;/
Return009F6E:
	RTS				; I think we're done here

Main:
	DEC.w !RAM_SMW_Timer_KeepGameModeActive	; \Exit unless the decrement went
	BPL.b Return009F6E		; /negative: one step every other frame.
	JSR.w SMW_SetKeepGameModeActiveTimer_OneFrame	; Remain in this mode
CODE_009F77:
	LDY.w !RAM_SMW_Misc_MosaicDirection	; $0DAF -> Y,
	BRA.b CODE_009F4C		; Adjust brightness but not mosaic
namespace off
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_MosaicFade, SMW_GameMode0F_MosaicFadeOutToLevel_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_MosaicFade, SMW_GameMode13_MosaicFadeInToLevel_Main)

	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode02_FadeOutToTitleScreen_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode05_FadeInToTitleScreen_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode0B_FadeOutToOverworld_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode0D_FadeInToOverworld_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode15_FadeOutToDeathMessage_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode18_FadeOutToCutscene_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode1A_FadeOutToCredits_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode1C_FadeOutToYoshisHouse_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode1E_FadeInToYoshisHouse_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode20_FadeOutToEnemyRollcallDelay_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode22_FadeOutToEnemyRollcall_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode24_FadeInToEnemyRollcall_Main)
	%SetDuplicateOrNullPointer(SMW_GameModeXX_FadeInOrOut_Main, SMW_GameMode26_FadeOutToTheEnd_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode28_ShowTheEnd(Address)
namespace SMW_GameMode28_ShowTheEnd
%InsertMacroAtXPosition(<Address>)

Main:
	DEC.w !RAM_SMW_Timer_KeepGameModeActive	; same as TransitionFade but it takes 8 frames
	BPL.b SMW_GameModeXX_FadeInOrOut_Return009F6E	; per increase in brightness level
	LDA.b #$08			;\
	JSR.w SMW_SetKeepGameModeActiveTimer_VariableFrames	;| Keep some mode active, then do the fade control routine
	BRA.b SMW_GameModeXX_FadeInOrOut_CODE_009F77	;/ (The end of this routine adds one to the game mode. This means it will go to END, which simply returns and returns. This is clear at the "THE END" screen since it just sits there (the image upload is never cleared.)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode06_CircleEffect(Address)
namespace SMW_GameMode06_CircleEffect
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_CheckWhichControllersArePluggedIn_Main	; Get the current controller port to accept data from.
	JSR.w SMW_GameMode07_TitleScreenDemo_CODE_009CBE	;\ Branch if A/B/X/Y is not pressed.
	BEQ.b CODE_00942E		;/
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	LDA.l !SRAM_SMAS_Global_RunningDemoFlag
	BNE.b CODE_3093EF
	LDA.w !RAM_SMW_IO_ControllerHold2CopyP1
	ORA.w !RAM_SMW_IO_ControllerHold1CopyP1
	ORA.w !RAM_SMW_IO_ControllerHold2CopyP2
	ORA.w !RAM_SMW_IO_ControllerHold1CopyP2
	AND.b #!Joypad_X|(!Joypad_Y>>8)
	BEQ.b CODE_3093F3

CODE_3093EF:
	JML.l SMAS_ResetToSMASTitleScreen_Main

CODE_3093F3:
endif
	LDA.b #$EC			;\ Size to make the window if the opening animation is skipped with A/B/X/Y.
	JSR.w CODE_009440		;/
	INC.w !RAM_SMW_Misc_GameMode	;\ Prepare the file select menu.
	JMP.w SMW_GameMode07_TitleScreenDemo_InitializeFileSelect	;/

CODE_00942E:
	DEC.w !RAM_SMW_Timer_TitleScreenInputTimer	; A/B/X/Y is not pressed, handle the window.
	BNE.b SMW_GameMode01_ShowNintendoPresents_Return00941A	;\ Return if not time to grow the window yet.
	INC.w !RAM_SMW_Timer_TitleScreenInputTimer	;/
	; Change from [AD 33 14] to [4C 17 94] to disable the circle fade in from
	; Title screen. Use in conjunction with address $009AAD.
	LDA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	CLC
	ADC.b #$04
	CMP.b #$F0
	BCS.b SMW_GameMode01_ShowNintendoPresents_CODE_009417	;| Increase the size of the title screen window.
CODE_009440:
	STA.w !RAM_SMW_Timer_HDMAWindowScalingFactor	; otherwise continue
CODE_009443:
	JSR.w SMW_UpdateHDMAWindowBuffer_SetCircleHDMAPointer
	LDA.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM00
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDA.b #$78
else
	LDA.b #$70
endif
	STA.b !RAM_SMW_Misc_ScratchRAM01
	JMP.w SMW_UpdateHDMAWindowBuffer_TitleScreenEntry
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GameMode01_ShowNintendoPresents(Address)
namespace SMW_GameMode01_ShowNintendoPresents
%InsertMacroAtXPosition(<Address>)

Main:
if ver_is_smasw(!Define_Global_ROMToAssemble)
	JSR.w SMW_GraphicsDecompressionRoutines_DecompressGFX32And33
	JSL.l SMAS_CheckWhichControllersArePluggedIn_Main
	INC.w !RAM_SMW_Misc_GameMode
else
	DEC.w !RAM_SMW_Timer_DisplayNintendoPresents	;\ Return if not time for the logo to fade away.
	BNE.b Return00941A		;/
	JSR.w SMW_GraphicsDecompressionRoutines_DecompressGFX32And33	; Decompress GFX32/GFX33.
endif
CODE_009417:
	INC.w !RAM_SMW_Misc_GameMode	;  |Move on to Game Mode 02
Return00941A:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetStandardPPUSettings(Address)
namespace SMW_SetStandardPPUSettings
%InsertMacroAtXPosition(<Address>)

Main:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDA.b #!InitialScreenSettings_EnableOverscanFlag
	STA.w !REGISTER_InitialScreenSettings
else
	; The routine that sets up certain VRAM-related registers in normal levels.
	; - $008A80: Default value for $2107 [23]. - $008A85: Default value for
	; $2108 [33]. - $008A8A: Default value for $2109 [53]. - $008A8F: Default
	; value for $210B [00]. - $008A94: Default value for $210C [04]. - $008AAB:
	; Default value for $2130 [02], although it's actually stored to the mirror
	; here (i.e. $44). $210A is never set, since it is only ever used in Mode
	; 0.
	STZ.w !REGISTER_InitialScreenSettings	;! 224 lines (vertical resolution)
endif
	STZ.w !REGISTER_MosaicSizeAndBGEnable			; Note: !MosaicSizeAndBGEnable_PixelSize1x1
	LDA.b #!Define_SMW_Layer1TilemapSize|(!Define_SMW_Layer1TilemapVRAMLocation<<2)
	STA.w !REGISTER_BG1AddressAndSize	; Layer 1 tilemap VRAM address and size
	LDA.b #!Define_SMW_Layer2TilemapSize|(!Define_SMW_Layer2TilemapVRAMLocation<<2)
	STA.w !REGISTER_BG2AddressAndSize	; Layer 2 tilemap VRAM address and size
	LDA.b #!Define_SMW_Layer3TilemapSize|(!Define_SMW_Layer3TilemapVRAMLocation<<2)
	STA.w !REGISTER_BG3AddressAndSize	; Layer 3 tilemap VRAM address and size
	LDA.b #!Define_SMW_Layer1GFXVRAMLocation|(!Define_SMW_Layer2GFXVRAMLocation<<4)
	STA.w !REGISTER_BG1And2TileDataDesignation	; Base VRAM address for Layer 1/2 GFX files
	LDA.b #!Define_SMW_Layer3GFXVRAMLocation|(!Define_SMW_Layer4GFXVRAMLocation<<4)
	STA.w !REGISTER_BG3And4TileDataDesignation	; Base address for Layer 3/4 GFX files
	STZ.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings	;\
	STZ.b !RAM_SMW_Mirror_BG3And4WindowMaskSettings	;| also, no weird windowing, masks,etc
	STZ.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings	;/
	STZ.w !REGISTER_BGWindowLogicSettings	; BG 1, 2, 3 and 4 Window Logic Settings
	STZ.w !REGISTER_ColorAndObjectWindowLogicSettings	; Color and OBJ Window Logic Settings
	STZ.w !REGISTER_MainScreenWindowMask	; Window Mask Designation for Main Screen
	STZ.w !REGISTER_SubScreenWindowMask	; Window Mask Designation for Sub Screen
	LDA.b #$02			;\ Color addition - add subscreen.
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings	;/
	LDA.b #$80			;\ Set Mode7 "Screen Over" to %10000000, disable Mode7 flipping
	STA.w !REGISTER_Mode7TilemapSettings	;/
	RTS

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ManipulateMode7Image(Address)
namespace SMW_ManipulateMode7Image
%InsertMacroAtXPosition(<Address>)

DATA_008AB4:
	dw $0000,$00FE,$0000,$00FE

DATA_008ABC:
	dw $0000,$0002,$0000,$0002

UNK_008AC4:
	db $00,$00,$00,$01,$FF,$FF,$00,$10	; unused table?
	db $F0

; Routine that updates the mode 7 matrix parameters mirrors at $2E-$34 using
; the rotation and scale parameters at $36-$38. SMW calls it every frame in
; mode 7 bosses (when $0D9B is >= #$80), and the "Easy Mode 7 patch" calls
; it every frame in mode 7 levels, but you may need to call it manually if
; you're using mode 7 in special situations (for example, on the Overworld).
; On SA-1 roms, this must be called when running on the SNES CPU.
Main:
	LDA.b !RAM_SMW_Misc_M7AngleHi	;\ Prep Y Scale value
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	REP.b #$30			; AXY->16
	JSR.w CODE_008AE8		; Calculate Y axis basis vector first, then X axis
	LDA.b !RAM_SMW_Misc_M7AngleLo	;\ Prep X Scale value
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Mirror_M7MatrixALo	;\ D <- A
	STA.b !RAM_SMW_Mirror_M7MatrixDLo	;| C <- -B
	LDA.b !RAM_SMW_Mirror_M7MatrixBLo	;| Essentially converting values from X axis to Y axis by rotating by 90 degrees.
	EOR.w #$FFFF			;|  Since the same subroutine is used for both axes.
	INC				;|
	STA.b !RAM_SMW_Mirror_M7MatrixCLo	;/
CODE_008AE8:
	LDA.b !RAM_SMW_Misc_M7RotationLo	; A value of $0200 here equals 360 degrees.
	ASL				;\
	PHA				;| Y = quadrant of angle
	XBA				;|
	AND.w #$0003			;|
	ASL				;|
	TAY				;/
	PLA				;\
	AND.w #$00FE			;| X = angle from the X axis * 2
	EOR.w DATA_008AB4,y		;|  Q1 & Q3 angles are positive
	CLC				;|  Q2 & Q4 angles are negative
	ADC.w DATA_008ABC,y		;| Angle is * 2 because M7SineWave entries are 2 bytes wide
	TAX				;/
	JSR.w CODE_008B2B
	CPY.w #$0004
	BCC.b CODE_008B0A
	EOR.w #$FFFF
	INC
CODE_008B0A:
	STA.b !RAM_SMW_Mirror_M7MatrixBLo
	TXA				;\
	EOR.w #$00FE			;| Now negate the angle and find its value
	CLC				;|
	ADC.w #$0002			;|
	AND.w #$01FF			;|
	TAX				;/
	JSR.w CODE_008B2B
	DEY
	DEY
	CPY.w #$0004
	BCS.b CODE_008B26
	EOR.w #$FFFF
	INC
CODE_008B26:
	STA.b !RAM_SMW_Mirror_M7MatrixALo
	SEP.b #$30			; AXY->8
	RTS

CODE_008B2B:
	SEP.b #$20			; A->8
	LDA.w DATA_008B57+$01,x
	BEQ.b CODE_008B34
	LDA.b !RAM_SMW_Misc_ScratchRAM00
CODE_008B34:
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w DATA_008B57,x		;\ sin(angle) * scale = result
	STA.w !REGISTER_Multiplicand	;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;|
	STA.w !REGISTER_Multiplier	;/
	NOP #4
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	CLC				;\ If sin(angle) is more than 8 bits, the only result is $0100 = 1.0.
	ADC.b !RAM_SMW_Misc_ScratchRAM01	;/ Therefore, the result is just the scale.
	XBA
	LDA.w !REGISTER_ProductOrRemainderLo	; Product/Remainder Result (Low Byte)
	REP.b #$20			; A->16
	LSR				; Scale of $20 = 1.0
	LSR
	LSR
	LSR
	LSR
	RTS

DATA_008B57:
	dw $0000,$0003,$0006,$0009,$000C,$000F,$0012,$0015
	dw $0019,$001C,$001F,$0022,$0025,$0028,$002B,$002E
	dw $0031,$0035,$0038,$003B,$003E,$0041,$0044,$0047
	dw $004A,$004D,$0050,$0053,$0056,$0059,$005C,$005F
	dw $0061,$0064,$0067,$006A,$006D,$0070,$0073,$0075
	dw $0078,$007B,$007E,$0080,$0083,$0086,$0088,$008B
	dw $008E,$0090,$0093,$0095,$0098,$009B,$009D,$009F
	dw $00A2,$00A4,$00A7,$00A9,$00AB,$00AE,$00B0,$00B2
	dw $00B5,$00B7,$00B9,$00BB,$00BD,$00BF,$00C1,$00C3
	dw $00C5,$00C7,$00C9,$00CB,$00CD,$00CF,$00D1,$00D3
	dw $00D4,$00D6,$00D8,$00D9,$00DB,$00DD,$00DE,$00E0
	dw $00E1,$00E3,$00E4,$00E6,$00E7,$00E8,$00EA,$00EB
	dw $00EC,$00ED,$00EE,$00EF,$00F1,$00F2,$00F3,$00F4
	dw $00F4,$00F5,$00F6,$00F7,$00F8,$00F9,$00F9,$00FA
	dw $00FB,$00FB,$00FC,$00FC,$00FD,$00FD,$00FE,$00FE
	dw $00FE,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF
	dw $0100,$3CB7,$BCB7,$3CB8,$3CB9,$3CBA,$3CBB,$3CBA
	dw $BCBA,$3CBC,$3CBD,$3CBE,$3CBF,$3CC0,$BCB7,$3CC1
	dw $3CB9,$3CC2,$BCC2,$3CB7,$FCC0
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetVisibleLayers(Address)
namespace SMW_SetVisibleLayers
%InsertMacroAtXPosition(<Address>)

Main:
	STA.w !REGISTER_ColorMathSelectAndEnable	;\ Set CGADSUB.
	STA.b !RAM_SMW_Mirror_ColorMathSelectAndEnable	;/
	STX.w !REGISTER_MainScreenLayers	;\ Set main/sub screen settings.
	STY.w !REGISTER_SubScreenLayers	;/
	STZ.w !REGISTER_MainScreenWindowMask	;\ Disable windowing.
	STZ.w !REGISTER_SubScreenWindowMask	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PlayerState07_ShootOutOfPipe(Address)
namespace SMW_PlayerState07_ShootOutOfPipe
%InsertMacroAtXPosition(<Address>)

Main:
	JSR.w SMW_DamagePlayer_DisableButtons	; No buttons!
	LDA.b #$02			;\ put mario behind sprites
	STA.w !RAM_SMW_Player_CurrentLayerPriority	;/
	LDA.b #$0C			;\ make mario fly-sortof
	STA.b !RAM_SMW_Player_InAirFlag	;/
	JSR.w SMW_PlayerState00_Normal_CODE_00CD8B
	DEC.b !RAM_SMW_Player_TimerBeforeWarpingInPipe	; Handle timer?
	BNE.b CODE_00D29D		; if not at 00, play init sounds for coming out of pipe cannon
	JMP.w SMW_PlayerStateXX_EnterPipe_CODE_00D26A	; handle like entering a new level (which you are)

CODE_00D29D:
	LDA.b !RAM_SMW_Player_TimerBeforeWarpingInPipe	;\
	CMP.b #$18			;| if close to finishing, don't play sound effect
	BCC.b CODE_00D2AA		;/ or, play sound effect once only
	BNE.b CODE_00D2B2
	LDA.b #!Define_SMW_Sound1DFC_BulletShoot	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh3
CODE_00D2AA:
	STZ.w !RAM_SMW_Player_CurrentLayerPriority	;\ make mario in front scenery, with no yoshi in pipe
	STZ.w !RAM_SMW_Yoshi_InPipe	;/
	STZ.b !RAM_SMW_Flag_SpritesLocked	; Set sprites not locked
CODE_00D2B2:
#LM300Hijack_ShootingDirectionOnLevelLoad:
if !Define_SMW_LunarMagicLevels == !TRUE
	LDA.b !RAM_SMW_LM_Misc_PipeShootDirection	;> #$40, or #$C0 for an entrance facing left (Config/LunarMagicLevels.asm)
else
	LDA.b #$40			; \ X speed = #$40
endif
	STA.b !RAM_SMW_Player_XSpeed
	LDA.b #$C0			; \ Y speed = #$C0
	STA.b !RAM_SMW_Player_YSpeed
	JMP.w SMW_UpdatePlayerSpritePosition_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PlayerState08_WarpToYoshiWingsBonus(Address)
namespace SMW_PlayerState08_WarpToYoshiWingsBonus
%InsertMacroAtXPosition(<Address>)

DATA_00C7F9:
	dw $FFC0,$00A0

Main:
	JSR.w SMW_DamagePlayer_DisableButtons
	LDA.b #$0B
	STA.b !RAM_SMW_Player_InAirFlag
	JSR.w SMW_HandlePlayerPhysics_InAir
	LDA.b !RAM_SMW_Player_YSpeed	; \ Branch if Mario has downward speed
	BPL.b CODE_00C80F
	CMP.b #$90			; \ Branch if Y speed < #$90
	BCC.b CODE_00C814
CODE_00C80F:
	SEC				; \ Y Speed -= #$0D
if ver_is_pal(!Define_Global_ROMToAssemble)
	SBC.b #$0F
else
	SBC.b #$0D
endif
	STA.b !RAM_SMW_Player_YSpeed
CODE_00C814:
	LDA.b #$02
	LDY.b !RAM_SMW_Player_XSpeed
	BEQ.b CODE_00C827
	BMI.b CODE_00C81E
	LDA.b #$FE
CODE_00C81E:
	CLC
	ADC.b !RAM_SMW_Player_XSpeed
	STA.b !RAM_SMW_Player_XSpeed
	BVC.b CODE_00C827
	STZ.b !RAM_SMW_Player_XSpeed
CODE_00C827:
	JSR.w SMW_UpdatePlayerSpritePosition_Main
	REP.b #$20			; A->16
	LDY.w !RAM_SMW_InYoshiWingsBonusArea
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	CMP.w DATA_00C7F9,y
	SEP.b #$20			; A->8
	BPL.b CODE_00C845
	STZ.b !RAM_SMW_Player_CurrentState
	TYA
	BNE.b CODE_00C845
	INY
	INY
	STY.w !RAM_SMW_InYoshiWingsBonusArea
	JSR.w SMW_IncrementSublevelsEnteredAndPrepareToLoadSublevel_Main
CODE_00C845:
	JMP.w SMW_PlayerState00_Normal_CODE_00CD8F
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PlayerState0A_NoYoshiCutscene(Address)
namespace SMW_PlayerState0A_NoYoshiCutscene
%InsertMacroAtXPosition(<Address>)

DATA_00C848:
if ver_is_pal(!Define_Global_ROMToAssemble)
	db $01,$4C,$00,$30,$08,$30,$00,$20
	db $40,$01,$00,$30,$01,$80,$FF,$01
	db $2C,$00,$30,$20,$01,$80,$06,$00
	db $3A,$01,$30,$00,$30,$08,$30,$00
	db $20,$40,$01,$00,$30,$01,$80,$FF
else
	; Table that holds controller input data for the No Yoshi cutscenes, used
	; by the routine at $00C870. The table is divided in two parts: the first
	; (15 bytes) is used when the player doesn't have a Yoshi, the second (25
	; bytes) is used when there's Yoshi. The table is formatted as a sequence
	; of two bytes chunks: the first is used as the input data, which first is
	; ANDed with #$DF and then copied to $15 (so the third highest bit is
	; ignored). When the value equals #$20, #$80 is stored to $18, to force an
	; A press and dismount Yoshi. Instead, when the value has the second
	; highest bit set (#$40), the entrance door starts animating. The second
	; byte is the number of frames that the current input will be used, before
	; passing on to the next. $88 is used as an index for the current entry
	; being used, while $89 is used for the timer. Both parts of the table end
	; with a $FF byte which makes the cutscene end when reached.
	db $01,$5F,$00,$30,$08,$30,$00,$20	;!
	db $40,$01,$00,$30,$01,$80,$FF,$01	;!
	db $3F,$00,$30,$20,$01,$80,$06,$00	;!
	db $3A,$01,$38,$00,$30,$08,$30,$00	;!
	db $20,$40,$01,$00,$30,$01,$80,$FF	;!
endif

; Routine that handles No Yoshi cutscenes, run whenever $71 is #$0A. The
; routine first sets up sprite data depending on the current cutscene type
; (ghost house, rope or castle). Then, it checks if A or B are pressed: in
; this case, the cutscene ends immediately. Otherwise, the player's controls
; are disabled, and the player's movement is handled by using the table at
; $00C848 (follow the link for more details on this). The entrance door
; animation is handled once a certain value in the table (#$40) is reached.
; During the entire process the code at $00CD82 is jumped to to handle some
; of Mario's physics (jump, cape spinning, throwing fireballs, cape flying)
; and animations. Once the value #$FF is read from the table (or the player
; presses A/B), the cutscene ends and the gamemode is changed to #$0F (fade
; to level).
Main:
	STZ.w !RAM_SMW_Player_SpinjumpFireballTimer	; Timer of some sort
	LDX.w !RAM_SMW_Misc_LevelTilesetSetting	;\
	BIT.w SMW_InitializeLevelRAM_DATA_00A625,x	;|
	BMI.b CastleCutscene		;| Probably what GFX/Tileset music to load
	BVS.b MushroomCutscene		;/
	JSL.l SMW_DrawGhostHouseEntranceDoor_Main
	BRA.b CODE_00C88D

MushroomCutscene:
	JSL.l SMW_DrawNoYoshiSign_Main
	BRA.b CODE_00C88D

CastleCutscene:
	JSL.l SMW_DrawBigCastleGate_Main
CODE_00C88D:
	LDX.b !RAM_SMW_Player_CutsceneInputTimer1
	LDA.b !RAM_SMW_IO_ControllerPress1
	ORA.b !RAM_SMW_IO_ControllerPress2
	JSR.w SMW_DamagePlayer_DisableButtons
	BMI.b CODE_00C8FB
	STZ.w !RAM_SMW_Player_OverrideWalkingFrames
	DEC.b !RAM_SMW_Player_CutsceneInputTimer2
	BNE.b CODE_00C8A8
	INX
	INX
	STX.b !RAM_SMW_Player_CutsceneInputTimer1
	LDA.w DATA_00C848-$01,x
	STA.b !RAM_SMW_Player_CutsceneInputTimer2
CODE_00C8A8:
	LDA.w DATA_00C848-$02,x
	CMP.b #$FF
	BEQ.b CODE_00C8FB
	AND.b #(!Joypad_DPadR>>8)|(!Joypad_DPadL>>8)|(!Joypad_DPadD>>8)|(!Joypad_DPadU>>8)|(!Joypad_Start>>8)|(!Joypad_X)|(!Joypad_Y>>8)|!Joypad_A|(!Joypad_B>>8)
	STA.b !RAM_SMW_IO_ControllerHold1
	CMP.w DATA_00C848-$02,x
	BEQ.b CODE_00C8BC
	LDY.b #!Joypad_A
	STY.b !RAM_SMW_IO_ControllerPress2
CODE_00C8BC:
	ASL
	BPL.b CODE_00C8D1
	JSR.w SMW_DamagePlayer_DisableButtons
	LDY.b #$B0
	LDX.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad
	BIT.w SMW_InitializeLevelRAM_DATA_00A625,x
	BMI.b CODE_00C8CE
	LDY.b #$7F
CODE_00C8CE:
	STY.w !RAM_SMW_Timer_NoYoshiIntroDoorTimer
CODE_00C8D1:
	JSR.w SMW_UpdatePlayerSpritePosition_Main
	LDA.b #$24
	STA.b !RAM_SMW_Player_InAirFlag
	LDA.b #$6F
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_00C8E1
	LDA.b #$5F
CODE_00C8E1:
	LDX.w !RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad
	BIT.w SMW_InitializeLevelRAM_DATA_00A625,x
	BVC.b CODE_00C8EC
	SEC
	SBC.b #$10
CODE_00C8EC:
	CMP.b !RAM_SMW_Player_YPosLo
	BCS.b CODE_00C8F8
	INC
	STA.b !RAM_SMW_Player_YPosLo
	STZ.b !RAM_SMW_Player_InAirFlag
	STZ.w !RAM_SMW_Player_SpinJumpFlag
CODE_00C8F8:
	JMP.w SMW_PlayerState00_Normal_CODE_00CD82

CODE_00C8FB:
	INC.w !RAM_SMW_Flag_ShowPlayerStart
	LDA.b #!Define_SMW_GameMode0F_MosaicFadeOutToLevel
	STA.w !RAM_SMW_Misc_GameMode
	CPX.b #$11
	BCC.b CODE_00C90A
	INC.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
CODE_00C90A:
	LDA.b #$01
	STA.w !RAM_SMW_Flag_PreventYoshiCarryOver
	LDA.b #!Define_SMW_Sound1DFA_TurnOffYoshiDrum	; \ Play sound effect
	STA.w !RAM_SMW_IO_SoundCh2
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeLevelRAM(Address)
namespace SMW_InitializeLevelRAM
%InsertMacroAtXPosition(<Address>)

DATA_00A60D:
	db $00,$01,$01,$01

DATA_00A611:
	dw $000D,$FFF3,$FFFE,$FFFE

DATA_00A619:
	dw $0000,$0000,$000A,$0000

DATA_00A621:
	db $1A,$1A,$0A,$0A

DATA_00A625:
	db $00,$80,$40,$00,$01,$02,$40,$00
	db $40,$00,$00,$00,$00,$02,$00,$00

; Routine responsible for initializing various things during loading of
; levels and castle destruction cutscenes. This includes: - Resetting
; P-switch, star, and directional coin timers, as well as resetting their
; music. - Controlling the flag for whether the coinblock bonus room
; minigame is still playable. - Clearing RAM addresses $71-$93 and
; $13DA-$1410. - Preventing Yoshi from spawning if the level has a No-Yoshi
; entrance. - Preparing Mario's entrance action (as defined by $192A) for
; both regular levels and No-Yoshi entrances. $00A6B6: Initialization of a
; No-Yoshi level. $00A6CC: Initialization of a regular level.
Main:
	LDA.w !RAM_SMW_Timer_BluePSwitch	; If blue pow...
	ORA.w !RAM_SMW_Timer_SilverPSwitch	; ...or silver pow...
	ORA.w !RAM_SMW_NorSpr045_DirectionalCoins_DespawnTimer	; or coin timer...
	BNE.b CODE_00A64A		; is on, go don't worry about positive music
	LDA.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario doesn't have star
	BEQ.b CODE_00A660
	LDA.w !RAM_SMW_Misc_MusicRegisterBackup	;\
	BPL.b CODE_00A64F		;/ if normal music is playing,  don't screw with music
CODE_00A64A:
	LDA.w !RAM_SMW_Misc_MusicRegisterBackup
	AND.b #$7F
CODE_00A64F:
	ORA.b #$40
	STA.w !RAM_SMW_Misc_MusicRegisterBackup
	STZ.w !RAM_SMW_Timer_BluePSwitch	; Zero out POW timer
	STZ.w !RAM_SMW_Timer_SilverPSwitch	; Zero out silver POW timer
	STZ.w !RAM_SMW_NorSpr045_DirectionalCoins_DespawnTimer	; Zero out coin timer
	STZ.w !RAM_SMW_Timer_StarPower	; Zero out star timer
CODE_00A660:
	LDA.w !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1	;\
	ORA.w !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow2	;| Misc. Level flags all = 00,
	ORA.w !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow3	;|
	ORA.w !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow4	;|
	ORA.w !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow5	;|
	BEQ.b CODE_00A674		;/
	STA.w !RAM_SMW_Flag_PreventCoinBonusGameReplay	;/ Store to some address :\ (special level effects on/off flag?)
CODE_00A674:
	LDX.b #$23
CODE_00A676:
	STZ.b !RAM_SMW_Player_CurrentState-$01,x
	DEX
	BNE.b CODE_00A676
	LDX.b #$37
CODE_00A67D:
	STZ.w !RAM_SMW_Player_SubXPos-$01,x
	DEX
	BNE.b CODE_00A67D
	ASL.w !RAM_SMW_UnusedRAM_GotInvincibleStarFromGoal		; Optimization: Unused RAM
	STZ.w !RAM_SMW_Timer_DisplayPlayerKickingPose	;\
	STZ.w !RAM_SMW_Timer_DisplayPlayerPickUpPose	;|
	STZ.w !RAM_SMW_Timer_LevelEndFade	;|clear more lefteover flags
	STZ.w !RAM_SMW_Yoshi_InPipe	;/
	LDY.b #$01
	LDX.w !RAM_SMW_Misc_LevelTilesetSetting	;\ if Tileset > 10, go away
	CPX.b #$10			;/
	BCS.b CODE_00A6CC
	LDA.w DATA_00A625,x
	LSR
	BEQ.b CODE_00A6CC
	LDA.w !RAM_SMW_Flag_ShowPlayerStart
	ORA.w !RAM_SMW_Counter_SublevelsEntered
	ORA.w !RAM_SMW_Flag_DisableNoYoshiIntro
	BNE.b CODE_00A6CC
	LDA.w !RAM_SMW_Flag_OverrideNoYoshiIntroForMidwayEntrance
	BEQ.b CODE_00A6B6
	JSR.w SMW_PlayerState0A_NoYoshiCutscene_CODE_00C90A
	BRA.b CODE_00A6CC

CODE_00A6B6:
	STZ.b !RAM_SMW_Player_InAirFlag
#LM000Hijack_ClearSublevelNumber:
	STY.b !RAM_SMW_Player_FacingDirection
	STY.b !RAM_SMW_Player_PipeAction
	LDX.b #!Define_SMW_PlayerState0A_NoYoshiCutscene
	LDY.b #$00
	LDA.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	BEQ.b CODE_00A6C7
	LDY.b #$0F
CODE_00A6C7:
	STX.b !RAM_SMW_Player_CurrentState
	STY.b !RAM_SMW_Player_TimerBeforeWarpingInPipe
	RTS

CODE_00A6CC:
#LM000Hijack_JSLTo05DD00:
if !Define_SMW_LunarMagicLevels == !TRUE
	JSL.l SMW_LunarMagicLevels_EntranceFlags		;> The level's slippery and water flags (Config/LunarMagicLevels.asm)
else
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo			;\ LM: Inserts a JSL.l SMW_$05DD00 here.
	CMP.b #$C0							;/
endif
	BEQ.b CODE_00A6D5
	INC.w !RAM_SMW_Flag_EnableVerticalScroll
CODE_00A6D5:
	LDA.w !RAM_SMW_Misc_LevelHeaderEntranceSettings
	BEQ.b CODE_00A6E0
	CMP.b #$05
	BNE.b CODE_00A716
	ROR.b !RAM_SMW_Flag_IceLevel
CODE_00A6E0:
	STY.b !RAM_SMW_Player_FacingDirection
	LDA.b #$24
	STA.b !RAM_SMW_Player_InAirFlag
	STZ.b !RAM_SMW_Flag_SpritesLocked
	LDA.w !RAM_SMW_Timer_EndLevelViaKeyhole				;\ Todo: What exactly is this code for?
	BEQ.b CODE_00A704						;| Does !RAM_SMW_Timer_EndLevelViaKeyhole have an extra function or is this leftover code?
	LDA.w !RAM_SMW_Misc_MusicRegisterBackup				;|
	ORA.b #$7F							;|
	STA.w !RAM_SMW_Misc_MusicRegisterBackup				;|
	LDA.b !RAM_SMW_Player_XPosLo					;|
	ORA.b #$04							;|
	STA.w !RAM_SMW_NorSpr00E_Keyhole_XPosLo				;|
	LDA.b !RAM_SMW_Player_YPosLo					;|
	CLC								;|
	ADC.b #$10							;|
	STA.w !RAM_SMW_NorSpr00E_Keyhole_YPosLo				;|
CODE_00A704:								;/
	LDA.w !RAM_SMW_InYoshiWingsBonusArea
	BEQ.b Return00A715
	LDA.b #!Define_SMW_PlayerState08_WarpToYoshiWingsBonus	; \ Animation = Rise off screen,
	STA.b !RAM_SMW_Player_CurrentState	; / for Yoshi Wing bonus stage
	LDA.b #$A0
	STA.b !RAM_SMW_Player_YPosLo
	LDA.b #$90			; \ Set upward speed, #$90
	STA.b !RAM_SMW_Player_YSpeed
Return00A715:
	RTS

CODE_00A716:
	CMP.b #$06
	BCC.b CODE_00A740
	BNE.b CODE_00A734
	STY.b !RAM_SMW_Player_FacingDirection
	STY.w !RAM_SMW_Player_CapeImage
	LDA.b #$FF
	STA.w !RAM_SMW_Yoshi_InPipe
	LDA.b #$08
	TSB.b !RAM_SMW_Player_XPosLo
	LDA.b #$02
	TSB.b !RAM_SMW_Player_YPosLo
	LDX.b #!Define_SMW_PlayerState07_ShootOutOfPipe
	LDY.b #$20
	BRA.b CODE_00A6C7

CODE_00A734:
	STY.b !RAM_SMW_Flag_UnderwaterLevel
	LDA.w !RAM_SMW_Flag_OverrideNoYoshiIntroForMidwayEntrance
	ORA.w !RAM_SMW_Timer_EndLevelViaKeyhole
	BNE.b CODE_00A6E0
	LDA.b #$04
CODE_00A740:
	CLC
	ADC.b #$03
	STA.b !RAM_SMW_Player_PipeAction
	TAY
	LSR
	DEC
	STA.w !RAM_SMW_Yoshi_InPipe
	LDA.w DATA_00A60D-$04,y
	STA.b !RAM_SMW_Player_FacingDirection
	LDX.b #!Define_SMW_PlayerState05_EnterHorizontalPipe
	CPY.b #$06
	BCC.b CODE_00A768
	LDA.b #$08
	TSB.b !RAM_SMW_Player_XPosLo
	LDX.b #!Define_SMW_PlayerState06_EnterVerticalPipe
	CPY.b #$07
	LDY.b #$1E
	BCC.b CODE_00A76A
	LDY.b #$0F
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_00A76A
CODE_00A768:
	LDY.b #$1C			; \ Set downward speed, #$1C
CODE_00A76A:
	STY.b !RAM_SMW_Player_YSpeed
	JSR.w CODE_00A6C7
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b Return00A795
	LDX.b !RAM_SMW_Player_PipeAction
	LDA.b !RAM_SMW_Player_TimerBeforeWarpingInPipe
	CLC
	ADC.w DATA_00A621-$04,x
	STA.b !RAM_SMW_Player_TimerBeforeWarpingInPipe
	TXA
	ASL
	TAX
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w DATA_00A611-$08,x
	STA.b !RAM_SMW_Player_XPosLo
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.w DATA_00A619-$08,x
	STA.b !RAM_SMW_Player_YPosLo
	SEP.b #$20			; A->8
Return00A795:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_PlayerState00_Normal(Address)
namespace SMW_PlayerState00_Normal
%InsertMacroAtXPosition(<Address>)

FreeMovementDebugPlayerSpeed:
	dw $0000,$0000
	dw $0002,$0006
	dw $FFFE,$FFFA

Main:
if !Define_Global_ROMToAssemble&(!ROM_SMW_E1|!ROM_SMW_E2) == $00
if ver_is_smasw_europe(!Define_Global_ROMToAssemble)
#Debug_FreeMovementAndPowerUpSelect:
	BRA.b CODE_00CCBB
	LDA.b !RAM_SMW_IO_ControllerPress2
	AND.b #!Joypad_L
	BEQ.b +
	LDA.w !RAM_SMW_Debug_FreeMovement
	EOR.b #$02
	STA.w !RAM_SMW_Debug_FreeMovement
	BEQ.b +
	LDA.b #$01
	STA.b !RAM_SMW_Player_CurrentPowerUp

+:
	LDA.w !RAM_SMW_Debug_FreeMovement
	BEQ.b CODE_00CCBB
	LSR
	BEQ.b ADDR_00CCB3
	LDA.b !RAM_SMW_IO_ControllerPress2
	AND.b #!Joypad_A
	BEQ.b +
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	INC
	AND.b #$03
	STA.b !RAM_SMW_Player_CurrentPowerUp
+
else
	LDA.b !RAM_SMW_IO_ControllerHold2	;!
	AND.b #!Joypad_L		;!
	BEQ.b CODE_00CC81		;!
	LDA.b !RAM_SMW_IO_ControllerPress2	;!
	CMP.b #!Joypad_A		;!
	BNE.b CODE_00CC81		;!
	INC.w !RAM_SMW_Debug_FreeMovement	;!
	LDA.w !RAM_SMW_Debug_FreeMovement	;!
	CMP.b #$03			;!
	BCC.b CODE_00CC81		;!
	STZ.w !RAM_SMW_Debug_FreeMovement	;!
CODE_00CC81:
	LDA.w !RAM_SMW_Debug_FreeMovement	;!
; DEBUG: Change from [$80] to [$F0] to enable free roam mode. When enabled,
; hold A and press L to cycle the mode between normal, P-speed, and no-clip.
; See $7E1E01 for more details.
#Debug_FreeMovement:
	BRA.b CODE_00CCBB		;! Change to BEQ to enable debug code below
	LSR				;! \ Unreachable
	BEQ.b ADDR_00CCB3		;! | Debug: Free roaming mode
endif
	LDA.b #$FF			;! |
	STA.w !RAM_SMW_Timer_PlayerHurt	;! |
	LDA.b !RAM_SMW_IO_ControllerHold1	;! |
	AND.b #(!Joypad_DPadL>>8)|(!Joypad_DPadR>>8)	;! |
	ASL				;! |
	ASL				;! |
	LDX.b #$00			;! |
	JSR.w ADDR_00CC9F		;! |
	LDA.b !RAM_SMW_IO_ControllerHold1	;! |
	AND.b #(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)	;! |
	LDX.b #$02			;! |
ADDR_00CC9F:
	BIT.b !RAM_SMW_IO_ControllerHold1	;! |
	BVC.b ADDR_00CCA5		;! |
	ORA.b #$02			;! |
ADDR_00CCA5:
	TAY				;! |
	REP.b #$20			;! | A->16
	LDA.b !RAM_SMW_Player_XPosLo,x	;! |
	CLC				;! |
	ADC.w FreeMovementDebugPlayerSpeed,y	;! |
	STA.b !RAM_SMW_Player_XPosLo,x	;! |
	SEP.b #$20			;! | A->8
	RTS				;! /

ADDR_00CCB3:
	LDA.b #!Define_SMW_Physics_PMeterMax	;!
	STA.w !RAM_SMW_Player_PMeter	;!
	STA.w !RAM_SMW_Timer_WaitBeforeCapeFlightBegins	;!
CODE_00CCBB:
endif
	LDA.w !RAM_SMW_Timer_EndLevel
	BEQ.b CODE_00CCC3
	JMP.w HandleEndOfLevel

CODE_00CCC3:
	JSR.w HandleLRScrolling
	LDA.b !RAM_SMW_Flag_SpritesLocked	; \ Branch if sprites locked
	BNE.b Return00CCDF
	STZ.w !RAM_SMW_Flag_CapeToSpriteInteraction	; don't run interation with cape
	STZ.w !RAM_SMW_Player_OverrideWalkingFrames
	LDA.w !RAM_SMW_Timer_StunPlayer	; \ If lock Mario timer is set...
	BEQ.b CODE_00CCE0
	DEC.w !RAM_SMW_Timer_StunPlayer	; | Decrease the timer
	STZ.b !RAM_SMW_Player_XSpeed	; | X speed = 0
	LDA.b #$0F			; | Mario's image = Going down tube
	STA.w !RAM_SMW_Player_CurrentPose
Return00CCDF:
	RTS

CODE_00CCE0:
	LDA.w !RAM_SMW_Misc_NMIToUseFlag	;\ if running game and not on bosses and such
	BPL.b CODE_00CD24		;/
	LSR
	BCS.b CODE_00CD24
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVS.b CODE_00CD1C
	LDA.b !RAM_SMW_Player_InAirFlag	; \If mario is flying jump
	BNE.b CODE_00CD1C		; /to
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Player_OnTiltingPlatformXPosLo	;\Set Marios position to
	STA.b !RAM_SMW_Player_XPosLo	;|the keyhole position(16bit)
	LDA.w !RAM_SMW_Player_OnTiltingPlatformYPosLo	;|
	STA.b !RAM_SMW_Player_YPosLo	;/
	SEP.b #$20			; A->8
	JSR.w SMW_UpdatePlayerSpritePosition_Main
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo	;\
	STA.w !RAM_SMW_Player_OnTiltingPlatformXPosLo	;|Set the x,y position
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetLo	;|to keyhole position
	LDA.b !RAM_SMW_Player_YPosLo	;|But only transfer first
	AND.w #$FFF0			;|12 bits of y position.
	STA.w !RAM_SMW_Player_OnTiltingPlatformYPosLo	;|
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetLo	;/
	JSR.w CODE_00F9C9
	BRA.b CODE_00CD1F

CODE_00CD1C:
	JSR.w SMW_UpdatePlayerSpritePosition_Main
CODE_00CD1F:
	JSR.w CODE_00F8F2
	BRA.b CODE_00CD36

CODE_00CD24:
	LDA.b !RAM_SMW_Player_YSpeed	; \ Branch if Mario has downward speed
	BPL.b CODE_00CD30		; | Skip checking is mario is blocked vertically.
	LDA.b !RAM_SMW_Player_BlockedFlags	; |load mario's colision with objects to check
	AND.b #$08			; |If mario isn't blocked upward so he can
	BEQ.b CODE_00CD30		; |retain his Y speed (to keep wall walking?).
	STZ.b !RAM_SMW_Player_YSpeed	; Y speed = 0
CODE_00CD30:
	JSR.w SMW_UpdatePlayerSpritePosition_Main	; |set mario's Y speed using his x acceleration?
	JSR.w SMW_HandlePlayerLevelCollision_Main
CODE_00CD36:
	JSR.w CheckForPlayerPitFall
CODE_00CD39:
	STZ.w !RAM_SMW_Player_TurningAroundFlag
	LDY.w !RAM_SMW_Timer_InflateFromPBalloon
	BNE.b CODE_00CD95
	LDA.w !RAM_SMW_Flag_PlayerClimbOnAir
	BEQ.b CODE_00CD4A
	LDA.b #$1F
	STA.b !RAM_SMW_Misc_ScratchRAM8B
CODE_00CD4A:
	LDA.b !RAM_SMW_Player_ClimbingFlag
	BNE.b CODE_00CD72
	; [AD 8F 14 0D] Change to [EA EA EA AD] to enable climbing while holding an
	; item
	LDA.w !RAM_SMW_Player_CarryingSomethingFlag2
	ORA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b CODE_00CD79
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	AND.b #$1B
	CMP.b #$1B
	BNE.b CODE_00CD79
	LDA.b !RAM_SMW_IO_ControllerHold1
	AND.b #(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)
	BEQ.b CODE_00CD79
	LDY.b !RAM_SMW_Player_InAirFlag
	BNE.b CODE_00CD72
	AND.b #!Joypad_DPadU>>8
	BNE.b CODE_00CD72
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	AND.b #$04
	BEQ.b CODE_00CD79
CODE_00CD72:
	LDA.b !RAM_SMW_Misc_ScratchRAM8B
	STA.b !RAM_SMW_Player_ClimbingFlag
	JMP.w SMW_HandlePlayerPhysics_Climbing

CODE_00CD79:
	LDA.b !RAM_SMW_Player_SwimmingFlag	;\If Mario is not swimming
	BEQ.b CODE_00CD82		;|do more status tests
	JSR.w SMW_HandlePlayerPhysics_Swimming	;|if not do status checks for underwater situations
	BRA.b CODE_00CD8F		;/and jump to a yoshi check

CODE_00CD82:
	JSR.w SMW_HandlePlayerPhysics_Main	;|Generic check/physic
	JSR.w SMW_CheckForPowerUpSpecificPlayerAttacks_Main	;|powerup specific checks/physics
	JSR.w SMW_HandlePlayerPhysics_InAir	;|Flying checks/physics
CODE_00CD8B:
	JSL.l SMW_SetPlayerPose_Main	;|Decompiling Glitch???
CODE_00CD8F:
	LDY.w !RAM_SMW_Player_RidingYoshiFlag	;|Jump to yoshi-specific code
	BNE.b CODE_00CDAD		;|if currently riding yoshi.
	RTS

CODE_00CD95:
	LDA.b #$42
	LDX.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_00CD9D
	LDA.b #$43
CODE_00CD9D:
	DEY
	BEQ.b CODE_00CDA5
	STY.w !RAM_SMW_Timer_InflateFromPBalloon
	LDA.b #$0F			; \ Mario's image = Going down tube
CODE_00CDA5:
	STA.w !RAM_SMW_Player_CurrentPose
	RTS

; Mario riding on Yoshi animations
OnYoshiAnimations:
	db $20,$21,$27,$28

CODE_00CDAD:
	LDX.w !RAM_SMW_Timer_YoshiTongueIsOut
	BEQ.b CODE_00CDBA
	LDY.b #$03
	CPX.b #$0C
	BCS.b CODE_00CDBA
	LDY.b #$04
CODE_00CDBA:
	LDA.w OnYoshiAnimations-$01,y
	DEY
	BNE.b CODE_00CDC6
	LDY.b !RAM_SMW_Player_DuckingFlag
	BEQ.b CODE_00CDC6
	LDA.b #$1D			; \ Mario's image = Picking up object
CODE_00CDC6:
	STA.w !RAM_SMW_Player_CurrentPose
	LDA.w !RAM_SMW_Yoshi_YoshiHasWings	; \ Check Yoshi wing ability address for #$01,
	CMP.b #$01			; / but this is an impossible value
	BNE.b Return00CDDC 					;\ Note: This will always branch in the original SMW.
	BIT.b !RAM_SMW_IO_ControllerPress1			;/ If it didn't, then you could shoot fireballs while on Yoshi.
	BVC.b Return00CDDC
	LDA.b #$08						;\ Optimization: Should be commented out so that 18DB can be used as free RAM.
	STA.w !RAM_SMW_UnusedRAM_7E18DB				;/
	JSR.w SMW_SpawnPlayerFireball_Main
Return00CDDC:
	RTS

; Camera horizontal panning routine. Handles L/R scrolling and updating the
; position of the static camera region ($142A). Not to be confused with the
; code around $00F6DB, which sets the actual screen position. Note that by
; default, this subroutine is only called when the player's animation state
; ($71) is 0.
HandleLRScrolling:
	LDA.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	BEQ.b Return00CDDC
	LDY.w !RAM_SMW_Misc_LRScrollDirection
	LDA.w !RAM_SMW_Flag_LRScrollFlag
	STA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b CODE_00CE4C
	LDA.w !RAM_SMW_Camera_LRScrollMoveFlag
	BEQ.b CODE_00CDF6
	STZ.w !RAM_SMW_Misc_LRScrollDirection
	BRA.b CODE_00CE48

; L & R scrolling routine. Change $00CDFC from D0 to 80 to disable L & R
; scrolling. Or change to [EA EA] to allow scrolling even if the player is
; holding multiple buttons (works best if $00CE12 is set to 01). $00CE12 is
; the number of frames L or R must be held before screen scrolling occurs.
; $00CE40 is the screen scroll sound effect.
CODE_00CDF6:
	LDA.b !RAM_SMW_IO_ControllerHold2	; \ Branch if anything besides L/R being held
	AND.b #!Joypad_X|!Joypad_A|$0F
	ORA.b !RAM_SMW_IO_ControllerHold1
	BNE.b CODE_00CE49
	LDA.b !RAM_SMW_IO_ControllerHold2	; \ Branch if L/R not being held
	AND.b #!Joypad_L|!Joypad_R
	BEQ.b CODE_00CE49
	CMP.b #!Joypad_L|!Joypad_R
	BEQ.b CODE_00CE49
	LSR				;\make it #%00000110
	LSR				;|
	LSR				;/
	INC.w !RAM_SMW_Timer_TimeBeforeLRScroll	;>Increment LR scroll timer
	LDX.w !RAM_SMW_Timer_TimeBeforeLRScroll	;\If didn't increment all the way,
	CPX.b #$10			;|cancel
	BCC.b CODE_00CE4C		;/
	TAX				;>Transfer Controller B into X
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo	;\Load static cam region position
	CMP.w SMW_HandleStandardLevelCameraScroll_DATA_00F6CB,x	;/and compare with depending on LR timer
	SEP.b #$20			; A->8
	BEQ.b CODE_00CE4C		;>if they equal, skip
	LDA.b #$01			;\Clear bit 0 of position of the
	TRB.w !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo	;/static camera region
	INC.w !RAM_SMW_Flag_LRScrollFlag	;>Indicate that the game is frozen at scrolling
	LDA.b #$00			;\compare X with #$02 (R button), if not holding
	CPX.b #$02			;|branch.
	BNE.b CODE_00CE33		;/
	LDA.b !RAM_SMW_Camera_LastScreenHoriz
	DEC
CODE_00CE33:
	REP.b #$20			; A->16
	XBA
	AND.w #$FF00
	CMP.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	SEP.b #$20			; A->8
	BEQ.b CODE_00CE44		;/check if going past the right edge of stage
	LDY.b #!Define_SMW_Sound1DFC_LRScroll	; \ Play sound effect
	STY.w !RAM_SMW_IO_SoundCh3
CODE_00CE44:
	TXA				;>Transfer controller B to A
	STA.w !RAM_SMW_Misc_LRScrollDirection	;>Set LR scrolling
CODE_00CE48:
	TAY				;>Transfer controller to Y
CODE_00CE49:
	STZ.w !RAM_SMW_Timer_TimeBeforeLRScroll	;>Clear LR scrolling timer
CODE_00CE4C:
	LDX.b #$00			;>default X = #$00
	LDA.b !RAM_SMW_Player_FacingDirection	;\Create another ram for index for Mario's facing
	ASL				;|
	STA.w !RAM_SMW_Player_FacingDirectionX2	;/
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo	;>Static cam region position
	CMP.w SMW_HandleStandardLevelCameraScroll_DATA_00F6CB,y	;\compare with #$0000 or #$0020 depending
	BEQ.b CODE_00CE6D		;/on if L or R
	CLC				;\Add by #$0000, #$FFFE, #$0002, #$0000, #$FFFE, #$0002
	ADC.w SMW_HandleStandardLevelCameraScroll_DATA_00F6BF,y	;/depending on L or R (the value to increment/decrement to move the screen).
	LDY.w !RAM_SMW_Player_FacingDirectionX2	;>Load player direction into Y
	CMP.w SMW_HandleStandardLevelCameraScroll_DATA_00F6B3,y	;>Compare with #$0090, #$0060, #$0000, #$0000...
	BNE.b CODE_00CE70		;>If A (static cam pos) not equal to the values, skip.
	STX.w !RAM_SMW_Misc_LRScrollDirection
CODE_00CE6D:
	STX.w !RAM_SMW_Flag_LRScrollFlag	;>freeze for moving camera
CODE_00CE70:
	STA.w !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo	;>Adjust static cam region
	STX.w !RAM_SMW_Camera_LRScrollMoveFlag	;>camera scroll type
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_PlayerState00_Normal(Address)
namespace SMW_PlayerState00_Normal
%InsertMacroAtXPosition(<Address>)

CODE_00B03E:
	JSR.w SMW_HandlePaletteFades_CODE_00AF35
	LDA.w !RAM_SMW_Palettes_PaletteUploadTableIndex
	CMP.b #$03
	BNE.b Return00B090
	LDA.b #SMW_GlobalPalettes_Mario>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
	REP.b #$30			; AXY->16
	LDA.w !RAM_SMW_Pointer_PlayerPaletteLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w #$0014
CODE_00B056:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.w SMW_CopyOfPaletteMirror[!CGRAM_SMW_DynamicPlayerPalette].LowByte,y
	DEY
	DEY
	BPL.b CODE_00B056
	LDA.w #$81EE
	STA.w SMW_CopyOfPaletteMirror[$80].LowByte
	LDX.w #$00CE
CODE_00B068:
	LDA.w #$0007
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_00B06D:
	LDA.w SMW_CopyOfPaletteMirror[$90].LowByte,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w SMW_PaletteMirror[$90].LowByte,x
	JSR.w SMW_HandlePaletteFades_CODE_00AFC0
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w SMW_CopyOfPaletteMirror[$90].LowByte,x
	DEX
	DEX
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_00B06D
	TXA
	SEC
	SBC.w #$0012
	TAX
	BPL.b CODE_00B068
	SEP.b #$30			; AXY->8
	STZ.w !RAM_SMW_UnusedRAM_7E0AF5				; Optimization: This should be removed.
Return00B090:
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_PlayerState00_Normal(Address)
namespace SMW_PlayerState00_Normal
%InsertMacroAtXPosition(<Address>)

HandleEndOfLevel:
	JSR.w SMW_DamagePlayer_DisableButtons
	STZ.w !RAM_SMW_Flag_PlayerInLakitusCloud
	STZ.w !RAM_SMW_Player_OverrideWalkingFrames
	STZ.w !RAM_SMW_Player_SlidingOnGround
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	LSR
	BCS.b CODE_00C944
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	ORA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1
	; [F0 3D] Change to [EA EA] to prevent Mario walking after touching goal
	; spheres or the goal tape.
	BEQ.b CODE_00C96B
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_00C935
	JSR.w CODE_00CCE0
CODE_00C935:
	LDA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1
	BNE.b CODE_00C948
	JSR.w CODE_00B03E
	LDA.w !RAM_SMW_Timer_LevelEndFade
	CMP.b #$40
	BCC.b Return00C96A
CODE_00C944:
	JSL.l SMW_ProcessLevelEndRoutines_Main
CODE_00C948:
	LDY.b #$01
	STY.b !RAM_SMW_Flag_SpritesLocked
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	BCC.b Return00C96A
	DEC.w !RAM_SMW_Timer_EndLevel
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_Timer_EndLevel
	CMP.b #$50
	BCS.b Return00C96A
else
	BNE.b Return00C96A		;!
endif
	LDA.w !RAM_SMW_Misc_ColorOfPalaceSwitchPressed1
	BNE.b CODE_00C962
CODE_00C95B:
	LDY.b #$0B
	LDA.b #$01
	JMP.w CODE_00C9FE

CODE_00C962:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.b #$70
elseif ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$6A
else
	LDA.b #$A0
endif
	STA.w !RAM_SMW_Timer_DisplaySpecialMessage
	INC.w !RAM_SMW_Misc_DisplayMessage
Return00C96A:
	RTS

CODE_00C96B:
	JSR.w SMW_HandlePaletteFades_Main
	LDA.w !RAM_SMW_Flag_ShowVictoryPoseDuringLevelEnd
	BNE.b CODE_00C9AF
	LDA.w !RAM_SMW_Timer_EndLevel
#LM253Hijack_VictoryPoseTimingFix:
if ver_is_pal(!Define_Global_ROMToAssemble)
	CMP.b #$50
else
	CMP.b #$28						; LM: Changes this to #$38 to fix the timing of Mario showing his victory pose in non-SA-1 ROMs (2.53+)
endif
	BCC.b CODE_00C984
	LDA.b #!Joypad_DPadR>>8
	STA.b !RAM_SMW_Player_FacingDirection
	STA.b !RAM_SMW_IO_ControllerHold1
	LDA.b #$05
	STA.b !RAM_SMW_Player_XSpeed
CODE_00C984:
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_00C98B
	JSR.w SMW_HandlePlayerPhysics_CODE_00D76B
CODE_00C98B:
	LDA.b !RAM_SMW_Player_XSpeed
	BNE.b CODE_00C9A4
	STZ.w !RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting
	JSR.w CODE_00CA3E
	INC.w !RAM_SMW_Flag_ShowVictoryPoseDuringLevelEnd
if ver_is_pal(!Define_Global_ROMToAssemble)
	LDA.b #$6E
	STA.w !RAM_SMW_Timer_ShowVictoryPose
	LDA.b #$80
else
	LDA.b #$40
	STA.w !RAM_SMW_Timer_ShowVictoryPose
	ASL				;!
endif
	STA.w !RAM_SMW_Palettes_LevelEndColorFadeDirection
	STZ.w !RAM_SMW_Timer_LevelEndFade
CODE_00C9A4:
	JMP.w CODE_00CD24

; The level numbers that triggers the seven castle destruction sequences and
; the credits scene. The first byte is for scene 1, the second is for scene
; 2, and so on, while the last byte is for the level which triggers the
; credits (specifically, as Front Door; back door can be found at $00CA13).
LevelsThatTriggerCutscenes:
	db !Define_SMW_LevelID_IggysCastle
	db !Define_SMW_LevelID_MortonsCastle
	db !Define_SMW_LevelID_LemmysCastle
	db !Define_SMW_LevelID_LudwigsCastle
	db !Define_SMW_LevelID_RoysCastle
	db !Define_SMW_LevelID_WendysCastle
	db !Define_SMW_LevelID_LarrysCastle
	db !Define_SMW_LevelID_BackDoor

CODE_00C9AF:
	JSR.w SetMarioPeaceImg
	LDA.w !RAM_SMW_Timer_ShowVictoryPose
	BEQ.b CODE_00C9C2
	DEC.w !RAM_SMW_Timer_ShowVictoryPose
	BNE.b Return00C9C1
	LDA.b #!Define_SMW_LevelMusic_ZoomIn
	STA.w !RAM_SMW_IO_MusicCh1	; / Change music
Return00C9C1:
	RTS

CODE_00C9C2:
	JSR.w CODE_00CA44
	LDA.b #!Joypad_DPadR>>8
	STA.b !RAM_SMW_IO_ControllerHold1
	JSR.w CODE_00CD24
	LDA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	BNE.b Return00CA30
	LDA.w !RAM_SMW_Flag_SecretGoalSprite	; \ Branch if Goal Tape extra bits == #$02
	INC				; | (never happens)
	CMP.b #$03
	BNE.b CODE_00C9DF
	LDA.b #!Define_SMW_Overworld_YoshisIsland	; \ Unreachable
	STA.w !RAM_SMW_Overworld_MarioMap	; | Set submap to be Yoshi's Island
	LSR
CODE_00C9DF:
	LDY.b #!Define_SMW_GameMode0C_LoadOverworld
	LDX.w !RAM_SMW_Flag_ActiveBonusGame
	BEQ.b CODE_00C9F8
	LDX.b #$FF
	STX.w !RAM_SMW_Flag_ActiveBonusGame
	LDX.b #!MosaicSizeAndBGEnable_PixelSize16x16
	STX.w !RAM_SMW_Mirror_MosaicSizeAndBGEnable
	STZ.w !RAM_SMW_Timer_EndLevel
	STZ.w !RAM_SMW_Misc_MusicRegisterBackup
	LDY.b #!Define_SMW_GameMode10_BufferLevelLoadMessage
CODE_00C9F8:
	STZ.w !RAM_SMW_Mirror_ScreenDisplayRegister				; Note: !ScreenDisplayRegister_MinBrightness00
	STZ.w !RAM_SMW_Misc_MosaicDirection
; [8D D5 0D] The code itself stores either 01 or 02 to $0DD5. Change to [EA
; EA EA] to make it possible to set the normal/secret exit info through
; $0DD5 via LevelASM, sprites, etc. (Note: To activate any exit at all,
; $0DD5 has to be explicitly set to 01, 02, 03 or 04. Leaving it as 00 will
; cause no exit to be activated at all, and values 05-FF should not be
; used.)
CODE_00C9FE:
	STA.w !RAM_SMW_Misc_ExitLevelAction	; Store secret/normal exit info
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	BEQ.b CODE_00CA25
	LDX.b #$08
	LDA.w !RAM_SMW_Overworld_LevelNumberLo
	CMP.b #!Define_SMW_LevelID_UseSecretExitForBoss
	BNE.b CODE_00CA12
	INC.w !RAM_SMW_Misc_ExitLevelAction
; [C9 31] Changing this to [80 11] will prevent any "boss defeated" scenes
; from ever being played. $00CA13 is one of the two level numbers that
; triggers the credits scene. The other is at $00C9AE.
CODE_00CA12:
	CMP.b #!Define_SMW_LevelID_FrontDoor
	BEQ.b CODE_00CA20
CODE_00CA16:
	CMP.w LevelsThatTriggerCutscenes-$01,x
	BEQ.b CODE_00CA20
	DEX
	BNE.b CODE_00CA16
	BRA.b CODE_00CA25

CODE_00CA20:
	STX.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	LDY.b #!Define_SMW_GameMode18_FadeOutToCutscene
CODE_00CA25:
	STY.w !RAM_SMW_Misc_GameMode
	INC.w !RAM_SMW_Overworld_CheckIfEventPassedFlag			; Optimization: Change this to an RTS to both prevent !RAM_SMW_Overworld_CheckIfEventPassedFlag and !RAM_SMW_Flag_GotMidpoint from being set when exiting to the overworld (both of which don't need to be set).
SetMidpointFlag:
	LDA.b #$01							;\ Note: This is also mistakenly used on the overworld to activate an event.
	STA.w !RAM_SMW_Flag_GotMidpoint					;/
Return00CA30:
	RTS

; Set the "peace" pose for the player depending on whether they're on Yoshi
; or not.
SetMarioPeaceImg:
	LDA.b #$26			; \ Mario's image = Peace Sign, or
	LDY.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_00CA3A
	LDA.b #$14			; | Mario's image = Peace Sign on Yoshi
CODE_00CA3A:
	STA.w !RAM_SMW_Player_CurrentPose
	RTS

CODE_00CA3E:
	LDA.b #$F0
	STA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	RTS

CODE_00CA44:
	LDA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	BNE.b CODE_00CA4A
	RTS

CODE_00CA4A:
	JSR.w SMW_UpdateHDMAWindowBuffer_SetCircleHDMAPointer
	LDA.b #$FC
	JSR.w SMW_UpdateHDMAWindowBuffer_IrisInOnPlayerEntry
	LDA.b #$33
	STA.b !RAM_SMW_Mirror_BG1And2WindowMaskSettings
	STA.b !RAM_SMW_Mirror_ObjectAndColorWindowSettings
	LDA.b #$03
	STA.b !RAM_SMW_Mirror_BG3And4WindowMaskSettings
	LDA.b #$22
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings
	RTS
namespace off
endmacro

macro ROUTINE_RT03_SMW_PlayerState00_Normal(Address)
namespace SMW_PlayerState00_Normal
%InsertMacroAtXPosition(<Address>)

CheckForPlayerPitFall:
	REP.b #$20			; A->16
	LDA.w #$FF80			;\;;;;;;Handling falling below the screen death!;;;
	CLC				;|
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;|Set a screen barrier ceiling to prevent mario from
	CMP.b !RAM_SMW_Player_YPosLo	;|going too far above the screen.
	BMI.b CODE_00F5A3		;|
	STA.b !RAM_SMW_Player_YPosLo	;/
CODE_00F5A3:
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Player_OnScreenPosYHi	;\
	DEC				;| and if mario Yhipos = 01, kill mario, unless..
	BMI.b Return00F5B6		;/
	LDA.w !RAM_SMW_InYoshiWingsBonusArea
	; Change to 80 03 (BRA $03) to make it so falling into a pit results in
	; death even in Yoshi wings levels, or to 80 00 (BRA $00) to make it so
	; falling into a pit will always activate the normal exit.
	BEQ.b Kill
	JMP.w CODE_00C95B		; if at a special level, finish the level, actually.

Kill:
	JSL.l SMW_DamagePlayer_PitFall	; Go to part of the kill mario routine
Return00F5B6:
	RTS
namespace off
endmacro

macro ROUTINE_RT04_SMW_PlayerState00_Normal(Address)
namespace SMW_PlayerState00_Normal
%InsertMacroAtXPosition(<Address>)

DATA_00F8DF:
	db $0C,$0C,$08,$00,$20,$04,$0A,$0D
	db $0D

DATA_00F8E8:
	dw $002A		; Morton
	dw $002A		; Roy
	dw $0012		; Ludwig
	dw $0000		; Bowser
	dw $FFED		; Reznor

CODE_00F8F2:
	JSR.w SMW_ResetPlayerLevelCollisionRAM_Main
	BIT.w !RAM_SMW_Misc_NMIToUseFlag
	BVC.b CODE_00F94E
	JSR.w SMW_HandlePlayerLevelCollision_Main
	LDA.w !RAM_SMW_Misc_CurrentlyActiveBoss
	ASL
	TAX
	PHX
	LDY.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_00F91E
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_YPosLo
	CMP.w DATA_00F8E8,x
	BPL.b CODE_00F91E
	LDA.w DATA_00F8E8,x
	STA.b !RAM_SMW_Player_YPosLo
	SEP.b #$20			; A->8
	STZ.b !RAM_SMW_Player_YSpeed
	LDA.b #!Define_SMW_Sound1DF9_HitHead
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
CODE_00F91E:
	SEP.b #$20			; A->8
	PLX
	LDA.w DATA_00F8E8,x
	CMP.b #$2A
	BNE.b Return00F94D
	REP.b #$20			; A->16
	LDY.b #$00
	LDA.w !RAM_SMW_NorSpr_Table7E160E+$09
	AND.w #$00FF
	INC
	CMP.b !RAM_SMW_Player_XPosLo
	BEQ.b CODE_00F94A
	BMI.b CODE_00F94A
	LDA.w !RAM_SMW_NorSpr_Table7E1534+$09
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INY
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w #$000F
	CMP.b !RAM_SMW_Misc_ScratchRAM00
CODE_00F94A:
	JMP.w SMW_HandlePlayerLevelCollision_CODE_00E9C8

Return00F94D:
	RTS

CODE_00F94E:
	LDY.b #$00
	LDA.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_00F957
	JMP.w CODE_00F997

CODE_00F957:
	JSR.w CODE_00F9A8
	BCS.b CODE_00F962
	JSR.w SMW_RunPlayerBlockCode_CODE_00EE1D
	JMP.w CODE_00F997

CODE_00F962:
	LDA.b !RAM_SMW_Player_InAirFlag
	BEQ.b CODE_00F983
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileXPosLo
	AND.w #$00FF
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetLo
	STA.w !RAM_SMW_Player_OnTiltingPlatformXPosLo
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileYPosLo
	AND.w #$00F0
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetLo
	STA.w !RAM_SMW_Player_OnTiltingPlatformYPosLo
	JSR.w CODE_00F9C9
CODE_00F983:
	LDA.b !RAM_SMW_Misc_M7RotationLo
	CLC
	ADC.b #$48
	LSR
	LSR
	LSR
	LSR
	TAX
	LDY.w DATA_00F8DF,x
	LDA.b #$80
	STA.b !RAM_SMW_Misc_ScratchRAM8E
	JSR.w SMW_RunPlayerBlockCode_CODE_00EEE1
CODE_00F997:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	CMP.w #$00AE
	SEP.b #$20			; A->8
	BMI.b CODE_00F9A5
	JSR.w SMW_DamagePlayer_KillAndDisableButtons
CODE_00F9A5:
	JMP.w SMW_HandlePlayerLevelCollision_CODE_00E98C

CODE_00F9A8:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_XPosLo
	CLC
	ADC.w #$0008
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformXOffsetLo
	LDA.b !RAM_SMW_Player_YPosLo
	CLC
	ADC.w #$0020							; Glitch: This code fails to account for Yoshi, resulting in the player sinking into the platform while riding him.
	STA.w !RAM_SMW_Sprites_OnTiltingPlatformYOffsetLo
CODE_00F9BC:
	SEP.b #$20			; A->8
	PHB
	LDA.b #SMW_CheckForTiltingPlatformCollision_Main>>16
	PHA
	PLB
	JSL.l SMW_CheckForTiltingPlatformCollision_Main
	PLB
	RTS

CODE_00F9C9:
	LDA.b !RAM_SMW_Misc_M7RotationLo
	PHA
	EOR.w #$FFFF
	INC
	STA.b !RAM_SMW_Misc_M7RotationLo
	JSR.w CODE_00F9BC
	REP.b #$20			; A->16
	PLA
	STA.b !RAM_SMW_Misc_M7RotationLo
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileXPosLo
	AND.w #$00FF
	SEC
	SBC.w #$0008
	STA.b !RAM_SMW_Player_XPosLo
	LDA.w !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileYPosLo
	AND.w #$00FF
	SEC
	SBC.w #$0020							; Glitch: This code fails to account for Yoshi, resulting in the player sinking into the platform while riding him.
	STA.b !RAM_SMW_Player_YPosLo
	SEP.b #$20			; A->8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PlayerStateXX_PowerupAnimations(Address)
namespace SMW_PlayerStateXX_PowerupAnimations
%InsertMacroAtXPosition(<Address>)

; Mario Shrinking Animation poses (uses RAM $13E0).
GrowingAniImgs:
	db $00,$3D,$00,$3D,$00,$3D,$46,$3D
	db $46,$3D,$46,$3D

PowerDownEntry:
	LDA.w !RAM_SMW_Player_AnimationTimer	;\ if mario's hurt frame counter isn't done yet,
	BEQ.b CODE_00D140		;/ set mario flashing, stop the sprites locked counter, and make mario look normal, and return
	LSR
	LSR
CODE_00D130:
	TAY
	LDA.w GrowingAniImgs,y		; \ Set Mario's image
	STA.w !RAM_SMW_Player_CurrentPose
DecrementAnimationTimer:
	LDA.w !RAM_SMW_Player_AnimationTimer	;\
	BEQ.b Return00D13F		;/ if the hurt frame counter is at 00 now, return
	DEC.w !RAM_SMW_Player_AnimationTimer	; decrement it
Return00D13F:
	RTS

CODE_00D140:
	LDA.b #$7F			;\ make mario flash for ~8 seconds
	STA.w !RAM_SMW_Timer_PlayerHurt	;/
	BRA.b CODE_00D158		; Return after doing a few things

GrowAnimationEntry:
	LDA.w !RAM_SMW_Player_AnimationTimer	;\ if hurt frame is 00, make mario big and return
	BEQ.b CODE_00D156		;/
	LSR				;\
	LSR				;|set mario's image according to the frame counter
	EOR.b #$FF			;|
	INC				;|
	CLC				;|
	ADC.b #$0B			;|
	BRA.b CODE_00D130		;/

; Change to EE E4 18 EA 64 to turn the Mushroom into a 1up, but it'll still
; play the animation
CODE_00D156:
	INC.b !RAM_SMW_Player_CurrentPowerUp	; Powerup+1
CODE_00D158:
	LDA.b #!Define_SMW_PlayerState00_Normal	;\ set mario to default
	STA.b !RAM_SMW_Player_CurrentState	;/
	STZ.b !RAM_SMW_Flag_SpritesLocked	; Let sprites go again
Return00D15E:
	RTS

GotCapeAnimationEntry:
	LDA.b #$7F			;\ make mario invisible
	STA.b !RAM_SMW_Player_HidePlayerTileFlags	;/
	DEC.w !RAM_SMW_Player_AnimationTimer	; decrement hurt frame counter
	BNE.b Return00D15E		; if not at 00 yet, return
	LDA.b !RAM_SMW_Player_CurrentPowerUp	;\
	LSR				;| if Mario is big or small, make him flash and stuff, but return
	BEQ.b CODE_00D140		;/
	BNE.b CODE_00D158		;/ if he's flowery or cape, it's basically the same thing, but without the flash.
GotFlowerAnimationEntry:
	LDA.w !RAM_SMW_Player_SlidingOnGround	;\
	AND.b #$80			;|
	ORA.w !RAM_SMW_Player_CapeFlyingPhase	;| if not flying or sliding (I think?) then don't slow him down and such
	BEQ.b CODE_00D187		;/
	STZ.w !RAM_SMW_Player_CapeFlyingPhase	;\ stop flying,
	LDA.w !RAM_SMW_Player_SlidingOnGround	;| stop sliding?
	AND.b #$7F			;|
	STA.w !RAM_SMW_Player_SlidingOnGround	;/
	STZ.w !RAM_SMW_Player_CurrentPose	; Make mario default again
CODE_00D187:
	DEC.w !RAM_SMW_Timer_PlayerPaletteCycle	; and decrement the flashing palette timer.
	BEQ.b CODE_00D158
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_PlayerStateXX_PowerupAnimations_PowerDownEntry, SMW_PlayerState01_PowerDown_Main)
	%SetDuplicateOrNullPointer(SMW_PlayerStateXX_PowerupAnimations_GrowAnimationEntry, SMW_PlayerState02_Grow_Main)
	%SetDuplicateOrNullPointer(SMW_PlayerStateXX_PowerupAnimations_GotCapeAnimationEntry, SMW_PlayerState03_GotCape_Main)
	%SetDuplicateOrNullPointer(SMW_PlayerStateXX_PowerupAnimations_GotFlowerAnimationEntry, SMW_PlayerState04_GotFlower_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandlePaletteFades(Address)
namespace SMW_HandlePaletteFades
%InsertMacroAtXPosition(<Address>)

DATA_00AE65:
	dw $001F,$03E0,$7C00

DATA_00AE6B:
	dw $FFFF,$FFE0,$FC00

DATA_00AE71:
	dw $0001,$0020,$0400

DATA_00AE77:
	dw $0000,$0000
	dw $0001,$0000
	dw $8000,$8000
	dw $8020,$0400
	dw $8080,$8080
	dw $8208,$1040
	dw $8420,$8420
	dw $8844,$2210
	dw $8888,$8888
	dw $9122,$4488
	dw $9248,$9248
	dw $A492,$4924
	dw $A4A4,$A4A4
	dw $A949,$5294
	dw $AAAA,$5294
	dw $AAAA,$5554
	dw $AAAA,$AAAA
	dw $D5AA,$AAAA
	dw $D5AA,$D5AA
	dw $D6B5,$AD6A
	dw $DADA,$DADA
	dw $DB6D,$B6DA
	dw $EDB6,$EDB6
	dw $EEDD,$BB76
	dw $EEEE,$EEEE
	dw $F7BB,$DDEE
	dw $FBDE,$FBDE
	dw $FDF7,$EFBE
	dw $FEFE,$FEFE
	dw $FFDF,$FBFE
	dw $FFFE,$FFFE
	dw $FFFF,$FFFE

DATA_00AEF7:
	dw $8000,$4000,$2000,$1000
	dw $0800,$0400,$0200,$0100
	dw $0080,$0040,$0020,$0010
	dw $0008,$0004,$0002,$0001

Main:
	LDY.w !RAM_SMW_Timer_EndLevel	;\
	LDA.b !RAM_SMW_Counter_GlobalFrames	;|
	LSR				;|
	BCC.b CODE_00AF25		;| every other frame
	DEY				;| decrement level end timer
	BEQ.b CODE_00AF25		;|
	STY.w !RAM_SMW_Timer_EndLevel	;/
CODE_00AF25:
if ver_is_pal(!Define_Global_ROMToAssemble)
	CPY.b #$B0
else
	CPY.b #$A0
endif
	BCS.b CODE_00AF35
	LDA.b #$04
	TRB.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
	LDA.b #!BGModeAndTileSizeSetting_Mode01Enable|!BGModeAndTileSizeSetting_Mode01Layer3Priority
	STA.b !RAM_SMW_Mirror_BGModeAndTileSizeSetting
	JSL.l SMW_ProcessLevelEndRoutines_Main
; Change to 4C 91 B0 EA to completely disable the fade-out only when beating
; a level. (USE WITH $00:B091).
CODE_00AF35:
	LDA.b !RAM_SMW_Counter_GlobalFrames
	AND.b #$03
	; Change to 80 to completely disable the fade-out when beating a level.
	; Warning: Boss fights including Reznor will glitch out and not send you
	; back to the overworld when doing this.
	BNE.b Return00AFA2
	LDA.w !RAM_SMW_Timer_LevelEndFade
	CMP.b #$40
	BCS.b Return00AFA2
	JSR.w CODE_00AFA3
	LDA.w #$01FE
	STA.w SMW_CopyOfPaletteMirror[$00].LowByte
#LM170Hijack_FadeFix1:
	LDX.w #$00EE						; LM: Changed to LDX.w #$00FE as part of the fade fix hijacks (1.70+)
CODE_00AF4E:
#LM170Hijack_FadeFix2:
	LDA.w #$0007						; LM: Changed to LDA.w #$000F as part of the fade fix hijacks (1.70+)
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_00AF53:
	LDA.w SMW_CopyOfPaletteMirror[$00].LowByte,x
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w SMW_PaletteMirror[$00].LowByte,x
	JSR.w CODE_00AFC0
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w SMW_CopyOfPaletteMirror[$00].LowByte,x
	DEX
	DEX
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_00AF53
	TXA
	SEC
#LM170Hijack_FadeFix3:
	SBC.w #$0012						; LM: Changed to SBC.w #$0002 as part of the fade fix hijacks (1.70+)
	TAX
	BPL.b CODE_00AF4E
#LM170Hijack_FadeFix4:
	LDX.w #$0004						;\ LM: Puts a JSL.l to the expanded area and skips this loop to prevent the status bar colors from fading out (1.70+)
CODE_00AF74:							;|
	LDA.w SMW_CopyOfPaletteMirror[$0D].LowByte,x		;|
	STA.b !RAM_SMW_Misc_ScratchRAM02			;|
	LDA.w SMW_PaletteMirror[$0D].LowByte,x			;|
	JSR.w CODE_00AFC0					;|
	LDA.b !RAM_SMW_Misc_ScratchRAM04			;|
	STA.w SMW_CopyOfPaletteMirror[$0D].LowByte,x		;|
	DEX							;|
	DEX							;|
	BPL.b CODE_00AF74					;/
	LDA.w !RAM_SMW_Palettes_BackgroundColorLo
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_Palettes_CopyOfBackgroundColorLo
	JSR.w CODE_00AFC0
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !RAM_SMW_Palettes_BackgroundColorLo
	SEP.b #$30			; AXY->8
	STZ.w SMW_CopyOfPaletteMirror[$80].LowByte
	LDA.b #$03
	STA.w !RAM_SMW_Palettes_PaletteUploadTableIndex
Return00AFA2:
	RTS

CODE_00AFA3:
	TAY
	INC
	INC
	STA.w !RAM_SMW_Timer_LevelEndFade
	TYA
	LSR
	LSR
	LSR
	LSR
	REP.b #$30			; AXY->16
	AND.w #$0002
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	TYA
	AND.w #$001E
	TAY
	; Change from B9 F7 AE [LDA $AEF7,y] to A9 00 00 [LDA #$0000] to disable
	; fading completely, even in boss levels. WARNING: When end level scorecard
	; pops up in boss levels, mode 7 stuff will disappear due to the mode being
	; changed to 1 so layer 3 stuff shows up.
	LDA.w DATA_00AEF7,y
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	RTS

CODE_00AFC0:
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.w #$001F
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.w #$03E0
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	AND.w #$007C
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	STZ.b !RAM_SMW_Misc_ScratchRAM04
	LDY.w #$0004
CODE_00AFDF:
	PHY
	LDA.w !RAM_SMW_Misc_ScratchRAM06,y
	ORA.b !RAM_SMW_Misc_ScratchRAM0C
	TAY
	LDA.w DATA_00AE77,y
	PLY
	AND.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b CODE_00AFF9
	LDA.w DATA_00AE6B,y
	BIT.w !RAM_SMW_Palettes_LevelEndColorFadeDirection-$01
	BPL.b CODE_00AFF9
	LDA.w DATA_00AE71,y
CODE_00AFF9:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	AND.w DATA_00AE65,y
	TSB.b !RAM_SMW_Misc_ScratchRAM04
	DEY
	DEY
	BPL.b CODE_00AFDF
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetupHDMAWindowingEffects(Address)
namespace SMW_SetupHDMAWindowingEffects
%InsertMacroAtXPosition(<Address>)

; Routine that initializes the windowing HDMA parameters. It sets the window
; to use HDMA channel 7 (or 1, if using SA-1 pack v1.35+) and to use $04A0
; as the source. It also initializes that buffer to all $FF00 (i.e. no
; window is shown). This is only called on game reset.
Main:
	LDX.b #$04			; Index for DMA set up
-:
	LDA.w PARAMS_009277,x		;\ Set up DMA settings for $4370-$4374.
	STA.w HDMA[!Define_SMW_WindowHDMAChannel].Parameters,x	;|  (controls, destination, source)
	DEX				;|
	BPL.b -				;/
	LDA.b #$00			; Set HDMA data bank to $00.
	STA.w HDMA[!Define_SMW_WindowHDMAChannel].IndirectSourceBank	; Data Bank (H-DMA)
EndHDMA:
	STZ.w !RAM_SMW_Mirror_HDMAEnable	; Disable HDMA.
ClearWindowTable:
	REP.b #$10			; XY->16
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDX.w #$01DE
else
	LDX.w #$01BE
endif
	LDA.b #$FF
-:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable,x
	STZ.w !RAM_SMW_Misc_HDMAWindowEffectTable+$01,x
	DEX
	DEX
	BPL.b -
	SEP.b #$10			; XY->8
	RTS

PARAMS_009277:
	db $41,!REGISTER_Window1LeftPositionDesignation
	dl DATA_00927C

DATA_00927C:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	db $F8
	dw !RAM_SMW_Misc_HDMAWindowEffectTable
	db $F8
	dw !RAM_SMW_Misc_HDMAWindowEffectTable+$F0
	db $00
else
	db $F0				;! Screen is split into two halves
	dw !RAM_SMW_Misc_HDMAWindowEffectTable	;! Each $F0 lines long
	db $F0				;!
	dw !RAM_SMW_Misc_HDMAWindowEffectTable+$E0	;!
	db $00				;!
endif

CODE_009283:
	JSR.w ClearWindowTable		; Clear out the windowing table.
	LDA.w !RAM_SMW_Misc_NMIToUseFlag
	LSR				;| If running a level, overworld, or non-Bowser battle...
	BCS.b CODE_0092A0
	REP.b #$10			;| XY->16
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	LDX.w #$01DE
else
	LDX.w #$01BE
endif
WindowHDMAenable:
	STZ.w !RAM_SMW_Misc_HDMAWindowEffectTable,x	; out?
	LDA.b #$FF
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$01,x	; ...  This is, uh, strange.  It pastes $00FF into the $04A0,x table
	INX				;|| Set the HDMA table values to 0x00FF (full screen).
	INX
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	CPX.w #$01E0
else
	CPX.w #$01C0
endif
	BCC.b WindowHDMAenable
CODE_0092A0:
	LDA.b #($01<<!Define_SMW_WindowHDMAChannel)			;\ Enable HDMA on channel 7.
	STA.w !RAM_SMW_Mirror_HDMAEnable	;/
	SEP.b #$10			; XY->8
	RTS

CODE_0092A8:
	JSR.w ClearWindowTable		; these are somewhat the same subroutine, but also not >_>
	REP.b #$10			; XY->16
	LDX.w #$0198			;\ Scanline (x2) where the solid lava color in Iggy/Larry's fight begins.
	BRA.b WindowHDMAenable		;/

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_HandleMenuCursor(Address)
namespace SMW_HandleMenuCursor
%InsertMacroAtXPosition(<Address>)

DATA_009AC8:
	db $01,$FF,$FF			; Values are down/select, up, and both.

; The cursor routine used in file selection, player selection, and erase
; file. $009AD3 - If you change this to EA EA EA, the cursor arrow will
; never be shown in front of the game-start menus. (It will still act as
; though it were there, though.) $009AE4 - SFX that comes up when you select
; a game at the title screen. $009AFA - SFX played when you change an option
; at the title screen and overworld menus.
Entry2:
	PHY
	JSR.w SMW_CheckWhichControllersArePluggedIn_Main
	PLY
Main:
	INC.w !RAM_SMW_Counter_BlinkingCursorFrame	; Blinking cursor frame counter (file select, save prompt, etc)
	JSR.w CODE_009E82
	LDX.w !RAM_SMW_Misc_BlinkingCursorPos
if ver_is_smasw_usa(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_Misc_GameMode
	CMP.b #!Define_SMW_GameMode0A_PlayerSelect
	BNE.b +
	LDA.b !RAM_SMW_IO_ControllerPress1
	ORA.w !RAM_SMW_IO_ControllerPress1CopyP2
	STA.b !RAM_SMW_IO_ControllerPress1
+:
endif
	LDA.b !RAM_SMW_IO_ControllerPress1	;\
	AND.b #(!Joypad_Start>>8)|(!Joypad_B>>8)	;| If A, B, or start is pressed
	BNE.b CODE_009AE3		;|
	LDA.b !RAM_SMW_IO_ControllerPress2	;|
	BPL.b CODE_009AEA		;/
CODE_009AE3:
	LDA.b #!Define_SMW_Sound1DFC_Coin	;\ Play coin sound effect
	STA.w !RAM_SMW_IO_SoundCh3	;/
	BRA.b CODE_009B11

CODE_009AEA:
	PLA							;\ Note: Destructive return
	PLA							;/
	LDA.b !RAM_SMW_IO_ControllerPress1
	AND.b #!Joypad_Select>>8
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_IO_ControllerPress1
	AND.b #(!Joypad_DPadU>>8)|(!Joypad_DPadD>>8)
	BEQ.b Return009B16
	LDY.b #!Define_SMW_Sound1DFC_ShootFireball	;\ Play fireball sound effect
	STY.w !RAM_SMW_IO_SoundCh3	;/
	STZ.w !RAM_SMW_Counter_BlinkingCursorFrame
	LSR
	LSR
	TAY
	TXA
	ADC.w DATA_009AC8-$01,y		; Add offset to cursor index
	BPL.b CODE_009B0D
	LDA.b !RAM_SMW_Misc_ScratchRAM8A	;| Wrap if necessary
	DEC
CODE_009B0D:
	CMP.b !RAM_SMW_Misc_ScratchRAM8A
	BCC.b CODE_009B13
CODE_009B11:
	LDA.b #$00
CODE_009B13:
	STA.w !RAM_SMW_Misc_BlinkingCursorPos	;/ Store cursor index
Return009B16:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_HandleMenuCursor(Address)
namespace SMW_HandleMenuCursor
%InsertMacroAtXPosition(<Address>)

; Table containing the number of possible options for different menus, in 16
; bit format. The entries are as follows: - $0002: unused - $0004: file
; select menu - $0002: player select menu - $0002: unused - $0004: file
; erase menu
DATA_009E6A:
	dw $0002,$0004,$0002,$0002,$0004

DATA_009E74:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	dw $51CC,$5208,$5228,$5208,$5208
elseif ver_is_arcade(!Define_Global_ROMToAssemble)
	dw $51CB,$5208,$5208,$51C4,$5205
else
	; The entries are as follows: - $51CB: unused - $51E8: file select menu -
	; $5208: player select menu - $51C4: unused - $51E5: file erase menu
	dw $51CB,$51E8,$5208,$51C4,$51E5	;! continue/end
endif

; Table of four bitwise values ($01,$02,$04,$08) indexed by $1B92 and used
; in the cursor draw routine to determine on which row to actually draw it.
DATA_009E7E:
	db $01,$02,$04,$08

; Routine that draws the cursor on the screen for different menus (file
; select, player select, file erase). It uses $1B92 to determine on which
; row to draw it, and $1B91 to skip drawing it every so often to create the
; blinking effect. $009EBA ($FC) holds the tile that's drawn in the rows
; that aren't supposed to show the cursor. $009EBB ($38) holds its YXPCCCTT
; properties. $009EC1 ($2E) holds the cursor tile number. $009EC2 ($3D)
; holds its YXPCCCTT properties.
CODE_009E82:
	LDX.w !RAM_SMW_Misc_BlinkingCursorPos	;\ Convert cursor index into bitmask
	LDA.w DATA_009E7E,x		;|
	TAX				;/
	LDA.w !RAM_SMW_Counter_BlinkingCursorFrame
	EOR.b #$1F
	AND.b #$18
	BNE.b CODE_009E94
	LDX.b #$00
CODE_009E94:
	STX.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	REP.b #$20			; A->16
	LDA.w DATA_009E6A,y
	STA.b !RAM_SMW_Misc_ScratchRAM8A
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w DATA_009E74,y
CODE_009EA7:
	XBA
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x	; Write VRAM address of stripe image
	XBA
	CLC				;\ Advance 64 tiles per cursor slot
	ADC.w #$0040			;/
	PHA
	LDA.w #$0100			;\ Stripe image payload is 2 bytes
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x	;/
	LDA.w #$38FC
	LSR.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b CODE_009EC3
	LDA.w #$3D2E
CODE_009EC3:
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	PLA
	INX				; Each stripe image is 6 bytes long
	INX
	INX
	INX
	INX
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b CODE_009EA7
	SEP.b #$20			; A->8
CODE_009ED4:
	TXA				;\ Preserve length of dynamic stripe image buffer
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo	;/
	LDA.b #$FF			;\ Write sentinel value
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PlayerState0B_RescuedPeach(Address)
namespace SMW_PlayerState0B_RescuedPeach
%InsertMacroAtXPosition(<Address>)

Main:
	STZ.w !RAM_SMW_Player_OverrideWalkingFrames	;\
	STZ.w !RAM_SMW_Player_SlidingOnGround	;/ these disable things I think
	LDA.w !RAM_SMW_Timer_EndLevel	;\
	BEQ.b CODE_00C5CE		;/ if not ending level,
	JSL.l SMW_CreditsFadeOut_Main
	LDA.w !RAM_SMW_Misc_GameMode	;\
	CMP.b #!Define_SMW_GameMode14_InLevel	;| if at a level,
	BEQ.b CODE_00C5D1		;/
	JMP.w SMW_PlayerState00_Normal_CODE_00C95B

; [9C 9F 0D] This address disables HDMA effects when player animation #$0B
; (Freeze) is triggered. To fix this, change to [EA EA EA] (NOP #3).
CODE_00C5CE:
	STZ.w !RAM_SMW_Mirror_HDMAEnable	; no HDMA!
CODE_00C5D1:
	LDA.b #$01			;\
	STA.w !RAM_SMW_Flag_MessageWindowSizeChangeDirection	;/ message box is expanding
	LDA.b #$07
	STA.w !RAM_SMW_Unknown_7E1928
	JSR.w SMW_DamagePlayer_DisableButtons	; No pressing buttons
	JMP.w SMW_PlayerState00_Normal_CODE_00CD24	; Mario speeds stuff over there

namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnGlitterEffectForCoin(Address)
namespace SMW_SpawnGlitterEffectForCoin
%InsertMacroAtXPosition(<Address>)

; SMW's glitter trail subroutine, called when you collect a coin or Yoshi
; coin. Change $00FD6B to EA EA EA EA EA (NOP #5) to disable showing a
; glitter effect when a coin is collected.
Main:
	LDA.b !RAM_SMW_Player_OnScreenPosXHi	;\
	ORA.b !RAM_SMW_Player_OnScreenPosYHi	;| if mario is on lower-left part of screen return
	BNE.b Return00FD6A		;/
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_00FD62:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y
	BEQ.b CODE_00FD6B
	DEY
	BPL.b CODE_00FD62
Return00FD6A:
	RTS

CODE_00FD6B:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr05_Glitter
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y
	LDA.b !RAM_SMW_Blocks_XPosLo
	AND.b #$F0
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.b #$F0
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y
	LDA.w !RAM_SMW_Misc_CurrentLayerBeingProcessedLo
	BEQ.b CODE_00FD97
	LDA.b !RAM_SMW_Blocks_XPosLo
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerXPosLo
	AND.b #$F0
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y
	LDA.b !RAM_SMW_Blocks_YPosLo
	SEC
	SBC.b !RAM_SMW_Misc_SecondLevelLayerYPosLo
	AND.b #$F0
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y
CODE_00FD97:
	LDA.b #$10
	STA.w !RAM_SMW_SmokeSpr_Timer,y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnPlayerTurnAroundSmoke(Address)
namespace SMW_SpawnPlayerTurnAroundSmoke
%InsertMacroAtXPosition(<Address>)

; Routine to show little puff of smoke when the player turns around.
Main:
	LDA.b !RAM_SMW_Counter_GlobalFrames	;\
	AND.b #$03			;|
	ORA.b !RAM_SMW_Player_InAirFlag	;| If sprites are locked, or every once in a while (short times)
	ORA.b !RAM_SMW_Player_OnScreenPosXHi	;|
	ORA.b !RAM_SMW_Player_OnScreenPosYHi	;|or mario has a high byte in the position
	ORA.b !RAM_SMW_Flag_SpritesLocked	;|
	BNE.b Return00FE71		;/ Return
	LDA.b !RAM_SMW_IO_ControllerHold1	;\
	AND.b #!Joypad_DPadD>>8		;| If down not pressed,
	BEQ.b CODE_00FE67		;/
	LDA.b !RAM_SMW_Player_XSpeed	;\
	CLC				;|
	ADC.b #$08			;| If mario was going extrordinarily slow
	CMP.b #$10			;| Return
	BCC.b Return00FE71		;/
CODE_00FE67:
	LDY.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_00FE69:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,y
	BEQ.b CODE_00FE72
	DEY
	BNE.b CODE_00FE69
Return00FE71:
	RTS

CODE_00FE72:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr03_TurnAroundSmoke
	STA.w !RAM_SMW_SmokeSpr_SpriteID,y
	LDA.b !RAM_SMW_Player_XPosLo
	ADC.b #$04
	STA.w !RAM_SMW_SmokeSpr_XPosLo,y
	LDA.b !RAM_SMW_Player_YPosLo
	ADC.b #$1A
	PHX
	LDX.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_00FE8A
	ADC.b #$10
CODE_00FE8A:
	STA.w !RAM_SMW_SmokeSpr_YPosLo,y
	PLX
	LDA.b #$13
	STA.w !RAM_SMW_SmokeSpr_Timer,y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UnusedYoshiRelatedRoutine(Address)
namespace SMW_UnusedYoshiRelatedRoutine
%InsertMacroAtXPosition(<Address>)

; An unused routine. When called, if there's a Yoshi spawned in the level
; and Mario is not riding him, it'll teleport him to the left edge of the
; screen running towards the right, and move him to Mario's Y position. If
; there's no Yoshi spawned, nothing happens. No matter what, the Yoshi will
; be turned to green and without wings. Note that the routine overwrites the
; Y register. $00F6CE: [$10] X speed given to Yoshi.
Main:
	LDY.b #!Define_SMW_StockMaxNormalSpriteSlot	; \ Unreachable instructions
ADDR_00FC25:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	; / Status = Carried
	CMP.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b ADDR_00FC73
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr035_Yoshi
	BNE.b ADDR_00FC73
	LDA.b #$01
	STA.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	STZ.w !RAM_SMW_Yoshi_YoshiHasWings	; No Yoshi wings
	LDA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,y
	AND.b #$F1
	ORA.b #$0A
	STA.w !RAM_SMW_NorSpr035_Yoshi_YoshiColor,y
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BNE.b Return00FC72
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	SEC
	SBC.b #$10
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.b !RAM_SMW_Player_YPosLo
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.b !RAM_SMW_Player_YPosHi
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b #$03
	STA.w !RAM_SMW_NorSpr035_Yoshi_CurrentState,y
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_FacingDirection,y
	LDA.b #$10
	STA.w !RAM_SMW_NorSpr_XSpeed,y
Return00FC72:
	RTL

ADDR_00FC73:
	DEY
	BPL.b ADDR_00FC25
	STZ.w !RAM_SMW_Yoshi_CarryOverLevelsFlag
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_ClearOutNormalSpriteSlots(Address)
namespace SMW_ClearOutNormalSpriteSlots
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #!Define_SMW_MaxNormalSpriteSlot
-:
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x
	DEX
	BPL.b -
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_ClearOutNormalSpriteSlots(Address)
namespace SMW_ClearOutNormalSpriteSlots
%InsertMacroAtXPosition(<Address>)

; Unreachable, but can be JSL'ed to clear out the sprite status table.
ADDR_00FA10: 						;\ Note: Unused RTL varient of above routine.
	LDX.b #!Define_SMW_StockMaxNormalSpriteSlot		;|
-:							;|
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x		;|
	DEX						;|
	BPL.b -						;|
	RTL						;/
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PlayerStateXX_EnterPipe(Address)
namespace SMW_PlayerStateXX_EnterPipe
%InsertMacroAtXPosition(<Address>)

; Speed at which Mario enters/exits a pipe. The first two bytes are
; horizontal speed when entering/exiting a horizontal pipe. The next two
; bytes are both horizontal speed in vertical pipes, and vertical speed in
; horizontal pipes. The last two are the vertical speed in vertical pipes.
PipeXSpeed:
	db $F8,$08			; horizontal pipe X speed

PipeYSpeed:
if ver_is_pal(!Define_Global_ROMToAssemble)
	db $00,$00,$F2,$0E
else
	db $00,$00,$F0,$10		; horizontal pipe Y speed, vertical pipe X speed
endif

HIDEPIPESETS:
	db $00,$63,$1C,$00

Horizontal:
	JSR.w SMW_DamagePlayer_DisableButtons	; No buttons
	STZ.w !RAM_SMW_Player_OverrideWalkingFrames	;Animation(?) = Default
	JSL.l SMW_SetPlayerPose_Main	;\
	JSL.l SMW_SetPlayerPose_Entry2	;| :\
	JSR.w CODE_00D1F4		;/
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b CODE_00D1B2
	LDA.b #$29			; \ Mario's image = Entering horizontal pipe on Yoshi
	STA.w !RAM_SMW_Player_CurrentPose
CODE_00D1B2:
	REP.b #$20			; A->16
	LDA.b !RAM_SMW_Player_YPosLo	;\
	SEC				;|
	SBC.w #$0008			;|
	AND.w #$FFF0			;|Correct Ypos to fit pipe
	ORA.w #$000E			;|
	STA.b !RAM_SMW_Player_YPosLo	;/
	SEP.b #$20			; A->8
	LDA.b !RAM_SMW_Player_PipeAction	;\
	LSR				;|
	TAY				;|
	INY				;| Set face screen timer only if on certain kinds of pipes
	LDA.w HIDEPIPESETS-$01,y	;|
	LDX.w !RAM_SMW_Player_CarryingSomethingFlag2	;|
	BEQ.b CODE_00D1DB		;|
	EOR.b #$1C			;|
	DEC.w !RAM_SMW_Timer_DisplayPlayerFaceScreenPose	;|\
	BPL.b CODE_00D1DB		;|| handle face camera timer
	INC.w !RAM_SMW_Timer_DisplayPlayerFaceScreenPose	;//
CODE_00D1DB:
	LDX.b !RAM_SMW_Player_TimerBeforeWarpingInPipe	;\
	CPX.b #$1D			;| if it'll be a while before mario warps while in the pipe
	BCS.b CODE_00D1F0		;/ handle hiding mario to work with it and such
	CPY.b #$03			;\ if entering a pipe, don't make mario move up
	BCC.b CODE_00D1ED		;/
	REP.b #$20			; A->16
	INC.b !RAM_SMW_Player_YPosLo	;\ make mario move up
	INC.b !RAM_SMW_Player_YPosLo	;/
	SEP.b #$20			; A->8
CODE_00D1ED:
	LDA.w HIDEPIPESETS,y
CODE_00D1F0:
	STA.b !RAM_SMW_Player_HidePlayerTileFlags
	BRA.b CODE_00D22D

CODE_00D1F4:
	LDA.w !RAM_SMW_Timer_CapeFlapAnimation	;\
	BEQ.b CODE_00D1FC		;| handle some RAM address, make it a timer at least
	DEC.w !RAM_SMW_Timer_CapeFlapAnimation	;/
CODE_00D1FC:
	JMP.w SMW_PlayerStateXX_PowerupAnimations_DecrementAnimationTimer	; handle hurt frame counter and stuff

PipeCntrBoundryX:
	db $0A,$06

PipeCntringSpeed:
	db $FF,$01

Vertical:
	JSR.w SMW_DamagePlayer_DisableButtons	; No pressing buttons!
	STZ.w !RAM_SMW_Player_CapeImage	; Make the cape image default
	LDA.b #$0F			;\
	LDY.w !RAM_SMW_Player_RidingYoshiFlag	;| set mario's image to going down pipe w/ yoshi if you have to
	BEQ.b CODE_00D22A		;/
	LDX.b #$00
	LDY.b !RAM_SMW_Player_FacingDirection
	LDA.b !RAM_SMW_Player_XPosLo	; | If not relativly centered on the pipe...
	AND.b #$0F
	CMP.w PipeCntrBoundryX,y
	BEQ.b CODE_00D228
	BPL.b CODE_00D220
	INX
CODE_00D220:
	LDA.b !RAM_SMW_Player_XPosLo	; | ...adjust Mario's X postion
	CLC
	ADC.w PipeCntringSpeed,x
	STA.b !RAM_SMW_Player_XPosLo
CODE_00D228:
	LDA.b #$21			; \ Mario's image = going down pipe
CODE_00D22A:
	STA.w !RAM_SMW_Player_CurrentPose
CODE_00D22D:
	LDA.b #!Joypad_X|(!Joypad_Y>>8)	; \ Set holding X/Y on controller
	STA.b !RAM_SMW_IO_ControllerHold1
	; Change (A9 02 8D F9 13) to EA EA EA EA EA to remove Mario's priority when
	; he's going into a pipe.
	LDA.b #$02			; \ Set behind scenery flag
	STA.w !RAM_SMW_Player_CurrentLayerPriority
	LDA.b !RAM_SMW_Player_PipeAction	;\
	CMP.b #$04			;| If mario is exiting from a left-facing pipe,
	LDY.b !RAM_SMW_Player_TimerBeforeWarpingInPipe	;| go somewhere..?
	BEQ.b CODE_00D268		;/
	AND.b #$03			;\
	TAY				;/ Y holds if mario entered a pipe.
	DEC.b !RAM_SMW_Player_TimerBeforeWarpingInPipe	; Decrement 88.
	BNE.b CODE_00D24E
	BCS.b CODE_00D24E
	LDA.b #$7F			;\ hide mario
	STA.b !RAM_SMW_Player_HidePlayerTileFlags	;/
	INC.w !RAM_SMW_Flag_AboutToWarpInPipe	; some timer?
CODE_00D24E:
	LDA.b !RAM_SMW_Player_XSpeed	; \ If Mario has no speed...
	ORA.b !RAM_SMW_Player_YSpeed
	BNE.b CODE_00D259
	LDA.b #!Define_SMW_Sound1DF9_IntoPipe	; | ...play sound effect
	STA.w !RAM_SMW_IO_SoundCh1
CODE_00D259:
	LDA.w PipeXSpeed,y		; \ Set X speed
	STA.b !RAM_SMW_Player_XSpeed
	LDA.w PipeYSpeed,y		; \ Set Y speed
	STA.b !RAM_SMW_Player_YSpeed
	STZ.b !RAM_SMW_Player_InAirFlag	; Mario flying = false
	JMP.w SMW_UpdatePlayerSpritePosition_Main

CODE_00D268:
	BCC.b SMW_IncrementSublevelsEnteredAndPrepareToLoadSublevel_Main
CODE_00D26A:
	STZ.w !RAM_SMW_Player_CurrentLayerPriority	; \ In new level, reset values
	STZ.w !RAM_SMW_Yoshi_InPipe
	JMP.w SMW_PlayerStateXX_PowerupAnimations_CODE_00D158	; Set mario to default, let sprites go, return

namespace off
	%SetDuplicateOrNullPointer(SMW_PlayerStateXX_EnterPipe_Horizontal, SMW_PlayerState05_EnterHorizontalPipe_Main)
	%SetDuplicateOrNullPointer(SMW_PlayerStateXX_EnterPipe_Vertical, SMW_PlayerState06_EnterVerticalPipe_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_IncrementSublevelsEnteredAndPrepareToLoadSublevel(Address)
namespace SMW_IncrementSublevelsEnteredAndPrepareToLoadSublevel
%InsertMacroAtXPosition(<Address>)

Main:
	INC.w !RAM_SMW_Counter_SublevelsEntered	;\
	LDA.b #!Define_SMW_GameMode0F_MosaicFadeOutToLevel	;| load new level?
	STA.w !RAM_SMW_Misc_GameMode	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UnusedAddToWarpPipeTimerRoutine(Address)
namespace SMW_UnusedAddToWarpPipeTimerRoutine
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Player_YPosLo	; \ Unreachable
	SEC
	SBC.b !RAM_SMW_Player_CurrentYPosLo
	CLC
	ADC.b !RAM_SMW_Player_TimerBeforeWarpingInPipe
	STA.b !RAM_SMW_Player_TimerBeforeWarpingInPipe
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UpdateHDMAWindowBuffer(Address)
namespace SMW_UpdateHDMAWindowBuffer
%InsertMacroAtXPosition(<Address>)

SetCircleHDMAPointer:
	REP.b #$20			; A->16
	LDA.w #CircleHDMAData
	STA.b !RAM_SMW_Misc_ScratchRAM04	; |Load xCB12 into $04 and $06
	STA.b !RAM_SMW_Misc_ScratchRAM06
	SEP.b #$20			; A->8
	RTS

IrisInOnPlayerEntry:
	CLC
	ADC.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	STA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	LDA.b !RAM_SMW_Player_OnScreenPosXLo
	CLC
	ADC.b #$08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$18
	LDY.b !RAM_SMW_Player_CurrentPowerUp
	BEQ.b CODE_00CA83
	LDA.b #$10
CODE_00CA83:
	CLC
	ADC.b !RAM_SMW_Player_OnScreenPosYLo
	STA.b !RAM_SMW_Misc_ScratchRAM01
TitleScreenEntry:
KeyholeEntry:
#SA1Pack_OptimizeThisRoutine:
if defined("Define_SMW_SA1")
	JSL.l Circle_SwitchCPU
	RTS
else
	REP.b #$30			; AXY->16
	AND.w #$00FF			; Keep lower byte of A
endif
	ASL
	DEC				; |Set Y to ((2A-1)*2)
	ASL
	TAY
	SEP.b #$20			; A->8
	LDX.w #$0000
CODE_00CA96:
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	CMP.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	BCC.b CODE_00CABD
	LDA.b #$FF
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable,x
	STZ.w !RAM_SMW_Misc_HDMAWindowEffectTable+$01,x
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	CPY.w #$01E0
else
	CPY.w #$01C0
endif
	BCS.b CODE_00CAB1
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable,y
	INC
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$01,y
CODE_00CAB1:
	INX
	INX
	DEY
	DEY
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BEQ.b CODE_00CB0A
	DEC.b !RAM_SMW_Misc_ScratchRAM01
	BRA.b CODE_00CA96

CODE_00CABD:
	JSR.w CODE_00CC14
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b CODE_00CAC7
	LDA.b #$FF
CODE_00CAC7:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$01,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM02
	BCS.b CODE_00CAD3
	LDA.b #$00
CODE_00CAD3:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable,x
	CPY.w #$01E0
	BCS.b CODE_00CAFE
	LDA.b !RAM_SMW_Misc_ScratchRAM07
	BNE.b CODE_00CAE7
	LDA.b #$00
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$01,y
	DEC
	BRA.b CODE_00CAFB

CODE_00CAE7:
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b CODE_00CAEF
	LDA.b #$FF
CODE_00CAEF:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable+$01,y
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM03
	BCS.b CODE_00CAFB
	LDA.b #$00
CODE_00CAFB:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable,y
CODE_00CAFE:
	INX
	INX
	DEY
	DEY
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	BEQ.b CODE_00CB0A
	DEC.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b CODE_00CABD
CODE_00CB0A:
	LDA.b #($01<<!Define_SMW_WindowHDMAChannel)
	; Change from '8D' to '0C' to not make HDMA gradients act strangely at the
	; end of the level (goal tape). Of course, you should still avoid using
	; HDMA channel 7 if this is all you change.
	STA.w !RAM_SMW_Mirror_HDMAEnable
	SEP.b #$10			; XY->8
	RTS

; Opening window data. $00CBA3 - Change 4B to 49 to fix a misplaced tile on
; the keyhole "iris in" effect.
CircleHDMAData:
	incbin "geometry/shapes/circle.bin"

KeyholeHDMAData:
	incbin "geometry/shapes/keyhole.bin"

CODE_00CC14:
if defined("Define_SMW_SA1")
	; SA-1 Pack's own code sits here, from the vendored tree.
namespace Circle
incsrc "asm/inline/00CC14.asm"
namespace SMW_UpdateHDMAWindowBuffer
else
	PHY
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !REGISTER_DividendHi	; Dividend (High-Byte)
	STZ.w !REGISTER_DividendLo	; Dividend (Low Byte)
	LDA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	STA.w !REGISTER_Divisor		; Divisor B
	NOP #6
	REP.b #$20			; A->16
	LDA.w !REGISTER_QuotientLo	; Quotient of Divide Result (Low Byte)
	LSR
	TAY
	SEP.b #$20			; A->8
	LDA.b (!RAM_SMW_Misc_ScratchRAM06),y
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b (!RAM_SMW_Misc_ScratchRAM04),y
	STA.w !REGISTER_Multiplicand	; Multiplicand A
	LDA.w !RAM_SMW_Timer_HDMAWindowScalingFactor
	STA.w !REGISTER_Multiplier	; Multplier B
	NOP #4
	LDA.w !REGISTER_ProductOrRemainderHi	; Product/Remainder Result (High Byte)
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PLY
	RTS
endif
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_RT00_SMW_SlopeDataTables(Address)
namespace SMW_SlopeDataTables
%InsertMacroAtXPosition(<Address>)

; Values stored to $13E1 for each slope tile. Rather than being indexed by
; the tile's actual Map16 tile number, this table is instead indexed first
; by the type of slope and then the tiles within that slope from
; left-to-right. For instance, the gradual slopes have four tiles spanning
; their surface, so they each get four bytes in this table; the steep slopes
; meanwhile span 1 tile horizontally, so they only get a single byte each.
; See the details for more information about the order.
Player:
.SlopeType:
	db $08,$08,$08,$08,$10,$10,$10,$10	; Gradual slope
	db $18,$18,$20,$20			; Normal slope
	db $28,$30				; Steep slope
	db $08,$10				; Purple triangle
	db $00,$00				; Very steep slope ledge edge
	db $28,$00				; Upside-down steep slope
	db $00,$00,$00,$00			; Upside down normal slope
	db $38,$50,$48,$40			; Conveyor slope
	db $58,$58,$60,$60			; Very steep slope
	db $00					; Flat ground

; Y speeds to give Mario when standing stationary or walking down on various
; slope tiles. These values are ordered the same way as $00E4B9.
.StationaryYSpeed:
	db $10,$10,$10,$10,$10,$10,$10,$10	; Gradual slope
	db $20,$20,$20,$20			; Normal slope
	db $30,$30				; Steep slope
	db $40,$30				; Purple triangle
	db $30,$30				; Very steep slope ledge edge
	db $30,$00				; Upside-down steep slope
	db $00,$00,$00,$00			; Upside down normal slope
	db $30,$30,$30,$30			; Conveyor slope
	db $40,$40,$40,$40			; Very steep slope
	db $00					; Flat ground

; Y speeds to give Mario when moving up various slope tiles (i.e. towards
; its "peak"). These values are ordered the same way as $00E4B9, though the
; "flat ground" value is unused.
.TowardsPeakYSpeed:
	db $00,$00,$00,$00,$00,$00,$00,$00	; Gradual slope
	db $EC,$EC,$EE,$EE			; Normal slope
	db $DA,$DA				; Steep slope
	db $00,$00				; Purple triangle
	db $00,$00				; Very steep slope ledge edge
	db $00,$00				; Upside-down steep slope
	db $00,$00,$00,$00			; Upside down normal slope
	db $DA,$DA,$DA,$DA			; Conveyor slope
	db $00,$00,$00,$00			; Very steep slope
	db $00					; Flat ground

; Sizes of the "top" area on various slope tiles; if Mario is moving
; downwards while within this distance from the top of the ledge/slope, he
; will be pushed on top of it. These values are ordered the same way as
; $00E4B9.
.SnapToSlopeDistance:
	db $08,$08,$08,$08,$08,$08,$08,$08	; Gradual slope
	db $09,$09,$09,$09			; Normal slope
	db $0B,$0B				; Steep slope
	db $0B,$0B				; Purple triangle
	db $0B,$0B				; Very steep slope ledge edge
	db $0B,$00				; Upside-down steep slope
	db $00,$00,$00,$00			; Upside down normal slope
	db $0B,$0B,$0B,$0B			; Conveyor slope
	db $14,$14,$14,$14			; Very steep slope
	db $06

; Values stored to $13EE/$15B8 for each slope tile. These values are ordered
; the same way as $00E4B9, although the upside-down slope values actually do
; get used (perhaps unintentionally) for fireballs.
SlopeType:
	db $FF,$FF,$FF,$FF,$01,$01,$01,$01	; Gradual slope
	db $FE,$FE,$02,$02			; Normal slope
	db $FD,$03				; Steep slope
	db $FD,$03				; Purple triangle
	db $FD,$03				; Very steep slope ledge edge
	db $FD,$00				; Upside-down steep slope
	db $00,$00,$00,$00			; Upside down normal slope
	db $08,$08,$F8,$F8			; Conveyor slope
	db $FC,$FC,$04,$04			; Very steep slope
	db $00					; Flat ground
namespace off
endmacro

macro DATATABLE_RT01_SMW_SlopeDataTables(Address)
namespace SMW_SlopeDataTables
%InsertMacroAtXPosition(<Address>)

; Values stored to $1694 for slopes, to indicate how far the top of the
; slope is from the top of the actual tile at any given X position;
; essentially, these values define the actual shape of each slope. The
; indices to this table are the same as $00E4B9 (excluding flat ground),
; except multiplied by #$10 and with the sprite's X position within the tile
; (from $9A) added to it.
ShapeOfSlope:
	db $0F,$0F,$0F,$0F,$0E,$0E,$0E,$0E,$0D,$0D,$0D,$0D,$0C,$0C,$0C,$0C		; Gradual slope left tile 1
	db $0B,$0B,$0B,$0B,$0A,$0A,$0A,$0A,$09,$09,$09,$09,$08,$08,$08,$08		; Gradual slope left tile 2
	db $07,$07,$07,$07,$06,$06,$06,$06,$05,$05,$05,$05,$04,$04,$04,$04		; Gradual slope left tile 3
	db $03,$03,$03,$03,$02,$02,$02,$02,$01,$01,$01,$01,$00,$00,$00,$00		; Gradual slope left tile 4
	db $00,$00,$00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03		; Gradual slope right tile 1
	db $04,$04,$04,$04,$05,$05,$05,$05,$06,$06,$06,$06,$07,$07,$07,$07		; Gradual slope right tile 2
	db $08,$08,$08,$08,$09,$09,$09,$09,$0A,$0A,$0A,$0A,$0B,$0B,$0B,$0B		; Gradual slope right tile 3
	db $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D,$0E,$0E,$0E,$0E,$0F,$0F,$0F,$0F		; Gradual slope right tile 4
	db $0F,$0F,$0E,$0E,$0D,$0D,$0C,$0C,$0B,$0B,$0A,$0A,$09,$09,$08,$08		; Normal slope left tile 1
	db $07,$07,$06,$06,$05,$05,$04,$04,$03,$03,$02,$02,$01,$01,$00,$00		; Normal slope left tile 2
	db $00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07		; Normal slope right tile 1
	db $08,$08,$09,$09,$0A,$0A,$0B,$0B,$0C,$0C,$0D,$0D,$0E,$0E,$0F,$0F		; Normal slope right tile 2
	db $0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00		; Steep slope left tile
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F		; Steep slope right tile
	db $0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00		; Left facing purple triangle
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F		; Right facing purple triangle
	db $08,$06,$04,$03,$02,$02,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00		; Solid left, very steep top left slope
	db $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$02,$02,$03,$04,$06,$08		; Solid right, very steep top right slope
	db $FF,$FE,$FD,$FC,$FB,$FA,$F9,$F8,$F7,$F6,$F5,$F4,$F3,$F2,$F1,$F0		; Steep slope left upside down
	db $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF		; Steep slope right upside down
	db $FF,$FF,$FE,$FE,$FD,$FD,$FC,$FC,$FB,$FB,$FA,$FA,$F9,$F9,$F8,$F8		; Normal slope left upside down tile 1
	db $F7,$F7,$F6,$F6,$F5,$F5,$F4,$F4,$F3,$F3,$F2,$F2,$F1,$F1,$F0,$F0		; Normal slope left upside down tile 2
	db $F0,$F0,$F1,$F1,$F2,$F2,$F3,$F3,$F4,$F4,$F5,$F5,$F6,$F6,$F7,$F7		; Normal slope right upside down tile 1
	db $F8,$F8,$F9,$F9,$FA,$FA,$FB,$FB,$FC,$FC,$FD,$FD,$FE,$FE,$FF,$FF		; Normal slope right upside down tile 2
	db $0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00		; Left facing up conveyor
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F		; Right facing down conveyor
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F		; Right facing up conveyor
	db $0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00		; Left facing down conveyor
	db $10,$10,$10,$10,$10,$10,$10,$10,$0E,$0C,$0A,$08,$06,$04,$02,$00		; Very steep left slope (Top half)
	db $0E,$0C,$0A,$08,$06,$04,$02,$00,$FE,$FC,$FA,$F8,$F6,$F4,$F2,$F0		; Very steep left slope (Bottom half)
	db $00,$02,$04,$06,$08,$0A,$0C,$0E,$10,$10,$10,$10,$10,$10,$10,$10		; Very steep right slope (Top half)
	db $F0,$F2,$F4,$F6,$F8,$FA,$FC,$FE,$00,$02,$04,$06,$08,$0A,$0C,$0E		; Very steep left slope (Bottom half)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CheckWhatSlopeSpriteIsOn(Address)
namespace SMW_CheckWhatSlopeSpriteIsOn
%InsertMacroAtXPosition(<Address>)

; Load slope information. This is a subroutine which gets the slope
; information for the current tile which means slope type and height of the
; ground for the current X position. It's used to load the slope info for
; sprites. Input: Map16 tile ID low byte $0A: X position of the interaction
; point $0C: Y position of the interaction point Output: Y: Index to the
; ground height table, calculated with from $08 * 4 + $0A & #$0F. $00: Y
; position of the current interaction within the block, calculated from $0C
; & #$0F. $05-$07: 24-bit pointer to the ground height table $00E632. $08:
; Slope type.
Main:
	LDY.b #SMW_SlopeDataTables_ShapeOfSlope	;\Some slope pointers?
	STY.b !RAM_SMW_Misc_ScratchRAM05	;|
	LDY.b #SMW_SlopeDataTables_ShapeOfSlope>>8	;|
	STY.b !RAM_SMW_Misc_ScratchRAM06	;|
	LDY.b #SMW_SlopeDataTables_ShapeOfSlope>>16	;|
	STY.b !RAM_SMW_Misc_ScratchRAM07	;|
	SEC				;|
	SBC.b #$6E			;|
	TAY				;|
	LDA.b [!RAM_SMW_Pointer_SlopeSteepnessLo],y	;|
	STA.b !RAM_SMW_Misc_ScratchRAM08	;/
	ASL				;\Multipy by 16
	ASL				;|
	ASL				;|
	ASL				;/
	STA.b !RAM_SMW_Misc_ScratchRAM01	;>And store the units of 16x16 blocks at $01
	BCC.b CODE_00FA37		;>If large enough to fill the carry after multiplying, skip incrementing $06
	INC.b !RAM_SMW_Misc_ScratchRAM06
CODE_00FA37:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\Store y position rounded down to the nearest 16 to $00
	AND.b #$0F			;|
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM0A	;\Do the same with X?
	AND.b #$0F			;/
	ORA.b !RAM_SMW_Misc_ScratchRAM01	;>set bit to use every odd byte?
	TAY
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_CheckIfBlockWasHit(Address)
namespace SMW_CheckIfBlockWasHit
%InsertMacroAtXPosition(<Address>)

Entry2:
	XBA				;>map16numb -> low
; Routine used to trigger SMW blocks, used for example by kicked sprites to
; make ON/OFF blocks, Note blocks, etc. activate when hitting them. Inputs:
; - $98: 16-bit Y position of the block. - $9A: 16-bit X position of the
; block. - $1933: which layer the block is in. - Y: must be #$00. - A: map16
; number low byte (high byte is always #$01, since all the blocks that can
; be triggered by this are in map16 page 1).
Main:
	SEC				;\Various map16 numbers?
	SBC.b #$11			;|
	CMP.b #$1D			;|
	BCC.b Entry3			;/
	XBA				;>map16numb -> high
	PHX
	LDX.w !RAM_SMW_Misc_LevelTilesetSetting	;>level settings from header
	LDA.l SMW_InitializeLevelRAM_DATA_00A625,x	;>Probably how page 1 and 2 of m16 change depending on tileset setting.
	PLX
	AND.b #$03			;>Modulo by 4
	BEQ.b CODE_00F176		;>If 0, then do additional checkings for the rest of the tiles
	RTL

; Green Star Block code. $00:F1E9 - FG/BG Tileset in which coin question
; blocks' behavior are changed for the 3-block 1up bonus game. $00:F1EA -
; Change from F0 0D to EA EA to disable the 3-block 1up bonus game, allowing
; you to use coin question blocks in levels with the switch palace tileset
; (4), and freeing up the 5 bytes at RAM address $13F4 for custom use.
CODE_00F176:
	XBA				;>map16numb -> low
	SBC.b #$59			;\Another group of map16 tiles to return
	CMP.b #$02			;|
	BCS.b Return00F1F8		;/
	ADC.b #$22
Entry3:
	PHX				;>Push X
	PHA				;>Push A
	TYX
	LDA.l DATA_00F0EC,x
	PLX				;>pushed A pull out as X
	AND.l DATA_00F0A4,x
	BEQ.b CODE_00F1F6
	STY.b !RAM_SMW_Misc_ScratchRAM06	;\Set bounce block settings
	LDA.l DATA_00F0C8,x		;|
	STA.b !RAM_SMW_Misc_ScratchRAM07	;|
	LDA.l DATA_00F05C,x		;|\which bounce block sprite is shown when the block is hit
	STA.b !RAM_SMW_Misc_ScratchRAM04	;//
	LDA.l DATA_00F080,x		;\Table for several Map16 blocks that handles which powerup is spawned out of the block when it's hit.
	BPL.b CODE_00F1BA		;/
	CMP.b #$FF
	BNE.b CODE_00F1AE
	LDA.b #$05
	LDY.w !RAM_SMW_Counter_GreenStarBlock
	BEQ.b CODE_00F1D0
	BRA.b CODE_00F1CE

CODE_00F1AE:
	LSR
	LDA.b !RAM_SMW_Blocks_XPosLo	;\I believe that this is so that special ? blocks
	ROR				;|spawn different sprites depending on the block's
	LSR				;|x position (like tile $11A, $11D, $125, etc.)
	LSR				;|
	LSR				;|
	TAX				;|
	LDA.l DATA_00F100,x		;/
CODE_00F1BA:
	LSR				;\Depending on the map16, spawns different bounce blocks.
	BCC.b CODE_00F1D0		;|
	CMP.b #$03			;|
	BEQ.b CODE_00F1C9		;|
	LDY.b !RAM_SMW_Player_CurrentPowerUp	;|
	BNE.b CODE_00F1D0		;|
	LDA.b #$01			;|
	BRA.b CODE_00F1D0		;/

CODE_00F1C9:
	LDY.w !RAM_SMW_Timer_StarPower	; \ Branch if Mario has star
	BNE.b CODE_00F1D0
CODE_00F1CE:
	LDA.b #$06			;>Otherwise use #$06 instead
CODE_00F1D0:
	STA.b !RAM_SMW_Misc_ScratchRAM05	;>value to use in $02887D
	CMP.b #$05
	BNE.b CODE_00F1DA
	LDA.b #$16
	STA.b !RAM_SMW_Misc_ScratchRAM07	;>value of $9C that the block will turn into
CODE_00F1DA:
	TAY
	LDA.b #$0F			;\Align with block grid
	TRB.b !RAM_SMW_Blocks_XPosLo	;|
	TRB.b !RAM_SMW_Blocks_YPosLo	;/
	CPY.b #$06
	BNE.b CODE_00F1EC
	LDY.w !RAM_SMW_Misc_LevelTilesetSetting	;>Tileset setting from level header
	CPY.b #$04			;\If switch palace, branch
	BEQ.b CODE_00F1F9		;/
CODE_00F1EC:
	PHB
	LDA.b #SMW_SpawnBounceSprite_Main>>16	;\Switch to bank 2
	PHA				;|
	PLB				;/
	JSL.l SMW_SpawnBounceSprite_Main
	PLB
CODE_00F1F6:
	PLX
	CLC
Return00F1F8:
	RTL

CODE_00F1F9:
	LDA.b !RAM_SMW_Blocks_YPosHi
	LSR
	LDA.b !RAM_SMW_Blocks_YPosLo
	AND.b #$C0
	ROL
	ROL
	ROL
	TAY
	LDA.b !RAM_SMW_Blocks_XPosLo
	LSR
	LSR
	LSR
	LSR
	TAX
	LDA.w !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1-$01,y
	ORA.l DATA_00F0EC,x
	LDX.w !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1-$01,y
	STA.w !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1-$01,y
	CMP.b #$FF
	BNE.b CODE_00F226
	LDA.b #$05
	STA.b !RAM_SMW_Misc_ScratchRAM05
CODE_00F220:
	LDA.b #$17
	STA.b !RAM_SMW_Misc_ScratchRAM07
	BRA.b CODE_00F1EC

CODE_00F226:
	LDA.w !RAM_SMW_Flag_PreventCoinBonusGameReplay
	BNE.b CODE_00F236
	TXA
	BEQ.b CODE_00F230
	LDA.b #$02
CODE_00F230:
	EOR.b #$03
	AND.b !RAM_SMW_Counter_GlobalFrames
	BNE.b CODE_00F220
CODE_00F236:
	LDA.b #!Define_SMW_Sound1DFC_Wrong
	STA.w !RAM_SMW_IO_SoundCh3	; / Play sound effect
	PHY
	STZ.b !RAM_SMW_Misc_ScratchRAM05
	PHB
	LDA.b #SMW_SpawnBounceSprite_Main>>16	; \ Set data bank = $02
	PHA
	PLB
	JSL.l SMW_SpawnBounceSprite_Main
	PLB
	PLY
	LDX.b #$07
	LDA.w !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1-$01,y
CODE_00F24E:
	LSR
	BCS.b CODE_00F261
	PHA
	LDA.b #$0D			; \ Block to generate = Used block
	STA.b !RAM_SMW_Blocks_Map16ToGenerate
	LDA.l DATA_00F0F8,x
	STA.b !RAM_SMW_Blocks_XPosLo
	JSL.l SMW_GenerateTile_Main
	PLA
CODE_00F261:
	DEX
	BPL.b CODE_00F24E
	JMP.w CODE_00F1F6
namespace off
endmacro

macro ROUTINE_RT01_SMW_CheckIfBlockWasHit(Address)
namespace SMW_CheckIfBlockWasHit
%InsertMacroAtXPosition(<Address>)

; Table for several Map16 blocks that handles which bounce block sprite is
; shown when the block is hit. Block order is as follows: 00-1C: Tiles
; 111-12D 1D-20: Tiles 021-024 21: Broken turnblock 22: Green ! block 23:
; Yellow ! block
DATA_00F05C:
	db $01,$05,$01,$02,$01,$01,$00,$00
	db $00,$00,$00,$00,$00,$06,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02
	db $02,$03,$03,$04,$02,$02,$02,$01
	db $01,$07,$11,$10

; Block order is the same as $00F05C.
DATA_00F080:
	db $80,$00,$00,$1E,$00,$00,$05,$09
	db $06,$81,$0E,$0C,$14,$00,$05,$09
	db $06,$07,$0E,$0C,$16,$18,$1A,$1A
	db $00,$09,$00,$00,$FF,$0C,$0A,$00
	db $00,$00,$08,$02

; Table for several Map16 blocks that handles from which sides the block is
; activated, in ----btrl format. - = unused, b = bottom, t = top, r = right,
; l = left Block order is the same as $00F05C.
DATA_00F0A4:
	db $0C,$08,$0C,$08,$0C,$0F,$08,$08
	db $08,$08,$08,$08,$08,$08,$08,$08
	db $08,$08,$08,$08,$08,$08,$08,$08
	db $08,$03,$03,$08,$08,$08,$08,$08
	db $08,$04,$08,$08

; Table for several Map16 blocks that handles which tiles to generate (the
; value stored to $9C) when the block is hit. Block order is the same as
; $00F05C.
DATA_00F0C8:
	db $0E,$13,$0E,$0D,$0E,$10,$0D,$0D
	db $0D,$0D,$0A,$0D,$0D,$0C,$0D,$0D
	db $0D,$0D,$0B,$0D,$0D,$16,$0D,$0D
	db $0D,$11,$11,$12,$0D,$0D,$0D,$0E
	db $0F,$0C,$0D,$0D

DATA_00F0EC:
	db $08,$01,$02,$04,$ED,$F6,$00,$7D
	db $BE,$00,$6F,$B7

DATA_00F0F8:
	db $40,$50,$00,$70,$80,$00,$A0,$B0

DATA_00F100:
	db $05,$09,$06,$05,$09,$06,$05,$09
	db $06,$05,$09,$06,$05,$09,$06,$05
	db $07,$0A,$10,$07,$0A,$10,$07,$0A
	db $10,$07,$0A,$10,$07,$0A,$10,$07
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_StatusBarTilemap(Address)
namespace SMW_StatusBarTilemap
%InsertMacroAtXPosition(<Address>)

; Info: |             "/~~\"		   |
;       | "MARIO       |  | TIME   @x  0"  |
;       |  "x 0   *x   |  |  ##0       0"  |
;       |             "\~~/"               |

; Base status bar tilemap. Two bytes per tile, in the form %TTTTTTTT
; %YXPCCCTT $008C81-$008C88: Top line (4 top tiles of the item box)
; $008C89-$008CC0: Second line $008CC1-$008CF6: Third line $008CF7-$008CFE:
; Bottom line (4 bottom tiles of item box) This data is uploaded to VRAM on
; level load. The middle two rows are also copied to $7E0EF9, which is then
; re-uploaded to VRAM every frame thereafter.
Main:
TopRow:
	dw $383A,$383B,$383B,$783A			; Info: "/~~\"
TopRowEnd:

SecondRow:						; Info: "MARIO       |  | TIME   @x  0"
.Mario:
	dw $2830,$2831,$2832,$2833	; Second line of the status bar.
	dw $2834
.Blank1:
	dw $38FC
.YoshiCoins:
	dw $3CFC,$3CFC,$3CFC,$3CFC
.BonusStarNumbers:
	dw $38FC,$38FC
.ItemBox:
	dw $384A,$38FC,$38FC,$784A
.Blank2:
	dw $38FC
.Time:
	dw $3C3D,$3C3E,$3C3F
.Blank3:
	dw $38FC,$38FC,$38FC
.Coins:
	dw $3C2E,$3826,$38FC,$38FC
	dw $3800
SecondRowEnd:

ThirdRow:						; Info: "x 0   *x   |  |  ##0       0"
.Lives:
	dw $3826,$38FC,$3800
.Blank1:
	dw $38FC,$38FC,$38FC
.Stars:
	dw $2864,$3826
.Blank2:
	dw $38FC
.BonusStarNumbers:
	dw $38FC,$38FC
.ItemBox:
	dw $384A,$38FC,$38FC,$784A
.Blank3:
	dw $38FC
.Time:
	dw $3CFE,$3CFE,$3C00
.Blank4:
	dw $38FC
.Score:
	dw $38FC,$38FC,$38FC,$38FC
	dw $38FC,$38FC,$3800
ThirdRowEnd:

BottomRow:						; Info: "\~~/"
	dw $B83A,$B83B,$B83B,$F83A
BottomRowEnd:
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr029_KoopaKid_Status01(Address)
namespace SMW_NorSpr029_KoopaKids_Status01
%InsertMacroAtXPosition(<Address>)

SetPlatformKoopaKidsInitialPosition:
	LDA.b #$A0
	STA.b !RAM_SMW_NorSpr_XPosLo_x
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b #$00
	STA.b !RAM_SMW_NorSpr_YPosLo_x
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr07B_GoalTape_Status08(Address)
namespace SMW_NorSpr07B_GoalTape_Status08
%InsertMacroAtXPosition(<Address>)

; The routine which triggers the goal tape. $00FABF - [06] The state which
; sprites are put into when the goal tape is triggered. Can be set to any of
; the valid values for RAM address $14C8.
TriggerGoalTape:
	STZ.w !RAM_SMW_Timer_InflateFromPBalloon
	STZ.w !RAM_SMW_Timer_PlayerHasPBalloon
	STZ.w !RAM_SMW_Timer_RespawnSprite	; Don't respawn sprites
if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
	STZ.w !RAM_SMW_GenSpr_SpriteID	;!
endif
	STZ.w !RAM_SMW_Counter_GoalCoinPointsIndex
	LDY.b #!Define_SMW_MaxNormalSpriteSlot	; Loop over sprites:
LvlEndSprLoopStrt:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y	; \ If sprite status < 8,
	CMP.b #!Define_SMW_NorSprStatus08_Normal	; | skip the current sprite
	BCC.b LvlEndNextSprite
	CMP.b #!Define_SMW_NorSprStatus0B_Carried	; \ If Mario carries a sprite past the goal,
	BNE.b CODE_00FAA3
	PHX
	JSR.w LvlEndPowerUp		; | he gets a powerup
	PLX
	BRA.b LvlEndNextSprite

CODE_00FAA3:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ Branch if goal tape
	CMP.b #!Define_SMW_SpriteID_NorSpr07B_GoalTape
	BEQ.b CODE_00FAB2
	LDA.w !RAM_SMW_NorSpr_XOffscreenFlag,y	; \ If sprite on screen...
	ORA.w !RAM_SMW_NorSpr_YOffscreenFlag,y
	BNE.b CODE_00FAC5
CODE_00FAB2:
	LDA.w !RAM_SMW_NorSpr_PropertyBits1686,y	; | ...and "don't turn into coin" not set,
	AND.b #!Define_SMW_NorSpr_1686Prop_DontBecomeCoinOnGoalTapeTrigger
	BNE.b CODE_00FAC5
	LDA.b #$10			; | Set coin animation timer = #$10
	STA.w !RAM_SMW_NorSprStatus06_GoalCoins_WaitBeforeTurningIntoCoin,y
	LDA.b #!Define_SMW_NorSprStatus06_GoalCoins	; | Sprite status = Level end, turn to coins
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	BRA.b LvlEndNextSprite

CODE_00FAC5:
	LDA.w !RAM_SMW_NorSpr_PropertyBits190F,y	; \ If "don't erase" not set,
	AND.b #!Define_SMW_NorSpr_190FProp_DontDespawnOnLevelEnd
	BNE.b LvlEndNextSprite
	LDA.b #!Define_SMW_NorSprStatus00_EmptySlot	; | Erase sprite
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
LvlEndNextSprite:
	DEY				; \ Goto next sprite
	BPL.b LvlEndSprLoopStrt
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02
	LDA.b #$00			; | Clear out all extended sprites
CODE_00FAD8:
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	DEY
	BPL.b CODE_00FAD8
	RTL

; Table of the various sprites Mario receives for carrying different items
; past the goal tape. The table itself is divided into four 7-byte sections:
; P-switches and springboards will use the second section, keys will use the
; third, baby Yoshi will use the fourth, and anything else will use the
; first. Each section is then indexed by Mario's current state, in the
; order: small, big, cape, fire, with star power, on Yoshi, and unused. The
; star power index is essentially unused, however, because the counter
; always gets cleared before the table gets loaded from. If the value
; returned is E0-EF, Mario will receive the sprite written at $00FB50 (1-up
; by default). If it's F0-FF, he'll receive the sprite at $00FB54 (...also a
; 1-up by default). In both cases, it'll also store the lower four bits to
; $1594, which for a 1up, will affect the number of lives it gives (0 = 1
; life, 1 = 2 lives, 2 = 3 lives, 3 = 5 lives). It's 0 in every obtainable
; case, though, so the feature is effectively unused. Additionally, $00FB40
; is the sprite to spawn if Mario already has the sprite in his item box
; (again, 1-up by default). Lastly, you can re-enable factoring star power
; into the table by changing $01C0FE to EA EA EA.
DATA_00FADF:
	db !Define_SMW_SpriteID_NorSpr074_Mushroom
	db !Define_SMW_SpriteID_NorSpr074_Mushroom
	db !Define_SMW_SpriteID_NorSpr077_Feather
	db !Define_SMW_SpriteID_NorSpr075_FireFlower
	db !Define_SMW_SpriteID_NorSpr076_Star
	db $E0
	db $F0
	db !Define_SMW_SpriteID_NorSpr074_Mushroom
	db !Define_SMW_SpriteID_NorSpr074_Mushroom
	db !Define_SMW_SpriteID_NorSpr077_Feather
	db !Define_SMW_SpriteID_NorSpr075_FireFlower
	db !Define_SMW_SpriteID_NorSpr076_Star
	db $E0
	db $F1
	db $F0
	db $F0
	db $F0
	db $F0
	db $F1
	db $E0
	db $F2
	db $E0
	db $E0
	db $E0
	db $E0
	db $F1
	db $E0
	db $E4

DATA_00FAFB:
	db $FF
	db $74
	db !Define_SMW_SpriteID_NorSpr075_FireFlower
	db !Define_SMW_SpriteID_NorSpr076_Star
	db !Define_SMW_SpriteID_NorSpr077_Feather

LvlEndPowerUp:
	LDX.b !RAM_SMW_Player_CurrentPowerUp	; X = Mario's power up status
	LDA.w !RAM_SMW_Timer_StarPower			;\ Note: Unused goal star
	BEQ.b CODE_00FB09				;|
	LDX.b #$04					;/
CODE_00FB09:
	LDA.w !RAM_SMW_Player_RidingYoshiFlag	; \ If Mario on Yoshi, X = #$05
	BEQ.b CODE_00FB10
	LDX.b #$05
CODE_00FB10:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y	; \ If Spring Board, X += #$07
	CMP.b #!Define_SMW_SpriteID_NorSpr02F_PortableSpringboard
	BEQ.b CODE_00FB2D
	CMP.b #!Define_SMW_SpriteID_NorSpr03E_PSwitch	; \ If P Switch, X += #$07
	BEQ.b CODE_00FB2D
	CMP.b #!Define_SMW_SpriteID_NorSpr080_Key	; \ If Key, X += #$0E
	BEQ.b ADDR_00FB28
	CMP.b #!Define_SMW_SpriteID_NorSpr02D_BabyYoshi	; \ If Baby Yoshi, X += #$15
	BNE.b CODE_00FB32
	TXA
	CLC
	ADC.b #$07
	TAX
ADDR_00FB28:
	TXA
	CLC
	ADC.b #$07
	TAX
CODE_00FB2D:
	TXA
	CLC
	ADC.b #$07
	TAX
CODE_00FB32:
	LDA.l DATA_00FADF,x
	LDX.w !RAM_SMW_Player_CurrentItemBox
	CMP.l DATA_00FAFB,x
	BNE.b CODE_00FB41
	LDA.b #!Define_SMW_SpriteID_NorSpr078_1upMushroom
CODE_00FB41:
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	CMP.b #$E0
	BCC.b LvlEndStoreSpr
	PHA
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	PLA
	CMP.b #$F0
	LDA.b #!Define_SMW_SpriteID_NorSpr078_1upMushroom		;\ Optimization: This branch is meaningless.
	BCS.b LvlEndStoreSpr					;|
	; Change to EA EA EA EA EA to prevent the 1UPs being spawned at the goal
	; point. $00:FB54 controls the sprite number that Baby Yoshi (Green, Red,
	; Yellow, Blue) will turn into when it reaches the goal point.
	LDA.b #!Define_SMW_SpriteID_NorSpr078_1upMushroom		;/
LvlEndStoreSpr:
	STA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr076_Star			;\ Optimization: Unused star prize
	BNE.b CODE_00FB5F 					;|
	INC.w !RAM_SMW_UnusedRAM_GotInvincibleStarFromGoal		;/
CODE_00FB5F:
	TYX
	JSL.l SMW_InitializeNormalSpriteRAMTables_Main
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	STA.w !RAM_SMW_NorSpr_Table7E1594,y
	LDA.b #!Define_SMW_NorSprStatus0C_GoalPowerUp	; \ Sprite status = Goal tape power up
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #$D0
	STA.w !RAM_SMW_NorSpr_YSpeed,y
	LDA.b #$05
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	LDA.b #$20
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E154C,y
	LDA.b #!Define_SMW_Sound1DF9_CarryItemToGoal
	STA.w !RAM_SMW_IO_SoundCh1	; / Play sound effect
	LDX.b #!Define_SMW_MaxSmokeSpriteSlot
CODE_00FB84:
	LDA.w !RAM_SMW_SmokeSpr_SpriteID,x
	BEQ.b CODE_00FB8D
	DEX
	BPL.b CODE_00FB84
	RTS

CODE_00FB8D:
	LDA.b #!Define_SMW_SpriteID_SmokeSpr01_PuffOfSmoke
	STA.w !RAM_SMW_SmokeSpr_SpriteID,x
	LDA.w !RAM_SMW_NorSpr_YPosLo,y
	STA.w !RAM_SMW_SmokeSpr_YPosLo,x
	LDA.w !RAM_SMW_NorSpr_XPosLo,y
	STA.w !RAM_SMW_SmokeSpr_XPosLo,x
	LDA.b #$1B
	STA.w !RAM_SMW_SmokeSpr_Timer,x
	RTS
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr088_WingedCage_Status08(Address)
namespace SMW_NorSpr088_WingedCage_Status08
%InsertMacroAtXPosition(<Address>)

SyncPlayerPositionToLayer1:
	REP.b #$20			; A->16
	LDA.w !RAM_SMW_Misc_Layer1XDisp-$01
	AND.w #$FF00
	BPL.b ADDR_00FF14
	ORA.w #$00FF
ADDR_00FF14:
	XBA
	CLC
	ADC.b !RAM_SMW_Player_XPosLo
	STA.b !RAM_SMW_Player_XPosLo
	LDA.w !RAM_SMW_Misc_Layer1YDisp-$01
	AND.w #$FF00
	BPL.b ADDR_00FF25
	ORA.w #$00FF
ADDR_00FF25:
	XBA
	EOR.w #$FFFF
	INC
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	STA.b !RAM_SMW_Player_YPosLo
	SEP.b #$20			; A->8
	RTL

SyncLayer3ScrollToLayer1:
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	XBA
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	REP.b #$20			; A->16
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0030
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	XBA
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	REP.b #$20			; A->16
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0100
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Mirror_Layer3YPosLo
	SEP.b #$20			; A->8
	RTL
namespace off
endmacro

macro ROUTINE_RT02_SMW_NorSpr089_Layer3Smasher_Status08(Address)
namespace SMW_NorSpr089_Layer3Smasher_Status08
%InsertMacroAtXPosition(<Address>)

UpdateLayer3SmasherPosition:
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	XBA
	LDA.b !RAM_SMW_NorSpr_XPosLo_x
	REP.b #$20			; A->16
	CMP.w #$FF00
	BMI.b CODE_00FF73
	CMP.w #$0100
	BMI.b CODE_00FF76
CODE_00FF73:
	LDA.w #$0100
CODE_00FF76:
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	SEP.b #$20			; A->8
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	XBA
	LDA.b !RAM_SMW_NorSpr_YPosLo_x
	REP.b #$20			; A->16
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$00A0
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w !RAM_SMW_ShakingLayer1DispYLo
	STA.b !RAM_SMW_Mirror_Layer3YPosLo
	SEP.b #$20			; A->8
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro INLINEDATATABLE_RT00_SMW_EmptySpace(Address)
!SMW_UBytes = $0F : !SMW_JBytes = $11 : !SMW_E1Bytes = $1D : !SMW_E2Bytes = $1B : !SMASW_UBytes = $04 : !SMASW_EBytes = $06 : !SMW_ARCADEBytes = $36
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 00)
endmacro

macro INLINEDATATABLE_RT01_SMW_EmptySpace(Address)
!SMW_UBytes = $13 : !SMW_JBytes = $12 : !SMW_E1Bytes = $00 : !SMW_E2Bytes = $00 : !SMASW_UBytes = $03 : !SMASW_EBytes = $02 : !SMW_ARCADEBytes = $03

; LM: Lunar Magic inserts some custom code here:
; $00BA4E - JML to the VBlank routine. Used by the FastROM patch
; $00BA52 - JML to handle setting !REGISTER_EnableFastROM. Used by the FastROM patch

	%SMW_FitOriginalFreespace(<Address>, !ROMID, 01)
endmacro

macro INLINEDATATABLE_RT02_SMW_EmptySpace(Address)
!SMW_UBytes = $0D : !SMW_JBytes = $0D : !SMW_E1Bytes = $0D : !SMW_E2Bytes = $0C : !SMASW_UBytes = $09 : !SMASW_EBytes = $19 : !SMW_ARCADEBytes = $0D
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 02)
endmacro

macro INLINEDATATABLE_RT03_SMW_EmptySpace(Address)
!SMW_UBytes = $1B : !SMW_JBytes = $1B : !SMW_E1Bytes = $4D : !SMW_E2Bytes = $4D : !SMASW_UBytes = $1B : !SMASW_EBytes = $2E : !SMW_ARCADEBytes = $1B
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 03)
endmacro

macro INLINEDATATABLE_RT04_SMW_EmptySpace(Address)
!SMW_UBytes = $2D : !SMW_JBytes = $90 : !SMW_E1Bytes = $0B : !SMW_E2Bytes = $0B : !SMASW_UBytes = $6D : !SMASW_EBytes = $1D : !SMW_ARCADEBytes = $2D
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 04)
endmacro
